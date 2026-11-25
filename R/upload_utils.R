# Helpers for gh_cli_release_upload(): run the gh cli, retry, and pace uploads.

.upload_max_times <- function() {
  if (tolower(Sys.getenv("NFLVERSE.UPLOAD.INSIST", "true")) == "false") return(1L)
  max_times <- suppressWarnings(as.integer(Sys.getenv("NFLVERSE.UPLOAD.MAX_TIMES", "6")))
  if (is.na(max_times) || max_times < 1L) 6L else max_times
}

.upload_quiet <- function() {
  isTRUE(as.logical(Sys.getenv("NFLVERSE.UPLOAD.QUIET", "false")))
}

# Runs `gh release upload` and returns list(ok, output) instead of erroring.
# stderr is captured as well, so the error message ends up in our logs.
.gh_cli_upload <- function(files, tag, repo, overwrite) {
  args <- c(
    "release", "upload", shQuote(tag), shQuote(files),
    "-R", shQuote(repo),
    if (isTRUE(overwrite)) "--clobber"
  )
  out <- suppressWarnings(system2("gh", args, stdout = TRUE, stderr = TRUE))
  status <- attr(out, "status") %||% 0L
  list(
    ok = identical(as.integer(status), 0L),
    output = paste(out, collapse = "\n")
  )
}

.is_rate_limit_error <- function(output) {
  grepl("rate limit|HTTP 429", output, ignore.case = TRUE)
}

# The primary rate limit (5,000 requests per hour for a user token) says
# "API rate limit exceeded for user ID ...". Unlike the secondary rate limit, it
# only clears when the hourly window resets.
.is_primary_rate_limit_error <- function(output) {
  grepl("API rate limit exceeded", output, ignore.case = TRUE)
}

# Time when the primary (core) rate limit resets, or NULL if unknown. Querying
# rate_limit doesn't count against the primary rate limit.
.core_rate_limit_reset <- function() {
  out <- suppressWarnings(system2(
    "gh", c("api", "rate_limit", "--jq", ".resources.core.reset"),
    stdout = TRUE, stderr = FALSE
  ))
  reset <- suppressWarnings(as.numeric(out[1]))
  if (length(reset) == 0 || is.na(reset)) return(NULL)
  as.POSIXct(reset, origin = "1970-01-01", tz = "UTC")
}

# GitHub asks clients to wait at least one minute after a secondary rate limit
# error and to back off exponentially if it keeps failing.
# Rate limit: 60s, 120s, 240s, 480s, 900s, ...
# Other errors (e.g. random server issues): 5s, 10s, 20s, 40s, 60s, ...
.upload_retry_wait <- function(attempt, rate_limited) {
  wait <- if (isTRUE(rate_limited)) {
    min(900, 60 * 2^(attempt - 1))
  } else {
    min(60, 5 * 2^(attempt - 1))
  }
  wait + stats::runif(1, 0, 0.1 * wait)
}

# When an upload of `n_writes` content-creating requests that started at
# `started` is "paid for" under the budget NFLVERSE.UPLOAD.WRITES_PER_HOUR.
.upload_pace_until <- function(started, n_writes) {
  per_hour <- suppressWarnings(
    as.numeric(Sys.getenv("NFLVERSE.UPLOAD.WRITES_PER_HOUR", ""))
  )
  if (is.na(per_hour) || per_hour <= 0) return(started)
  started + n_writes * 3600 / per_hour
}

.sleep_until <- function(time, reason, quiet = FALSE) {
  secs <- as.numeric(difftime(time, Sys.time(), units = "secs"))
  if (secs <= 0) return(invisible(0))
  if (!quiet) cli::cli_alert_info("{reason}: sleeping {round(secs)}s")
  Sys.sleep(secs)
  invisible(secs)
}

# Returns the subset of `files` that is not in the release as a complete asset
# of the same size uploaded after `since`. If the release can't be queried,
# all `files` are returned so they are uploaded again.
.files_not_in_release <- function(files, tag, repo, since) {
  assets <- tryCatch(
    {
      release_id <- system2(
        "gh",
        c("api", shQuote(paste0("repos/", repo, "/releases/tags/", tag)), "--jq", ".id"),
        stdout = TRUE, stderr = FALSE
      )
      lines <- system2(
        "gh",
        c(
          "api", "--paginate",
          shQuote(paste0("repos/", repo, "/releases/", release_id[[1]], "/assets?per_page=100")),
          "--jq", shQuote('.[] | [.name, .size, .state, .updated_at] | @tsv')
        ),
        stdout = TRUE, stderr = FALSE
      )
      if (!is.null(attr(lines, "status"))) stop("gh api failed")
      parts <- strsplit(lines, "\t", fixed = TRUE)
      data.frame(
        name = vapply(parts, `[`, character(1), 1),
        size = as.numeric(vapply(parts, `[`, character(1), 2)),
        state = vapply(parts, `[`, character(1), 3),
        updated = as.POSIXct(
          vapply(parts, `[`, character(1), 4),
          format = "%Y-%m-%dT%H:%M:%SZ", tz = "UTC"
        )
      )
    },
    error = function(e) NULL,
    warning = function(w) NULL
  )
  if (is.null(assets) || nrow(assets) == 0) return(files)

  i <- match(basename(files), assets$name)
  done <- !is.na(i) &
    assets$state[i] %in% "uploaded" &
    assets$size[i] == file.size(files) &
    # small tolerance for clock differences between runner and GitHub
    assets$updated[i] >= since - 5
  done[is.na(done)] <- FALSE
  files[!done]
}
