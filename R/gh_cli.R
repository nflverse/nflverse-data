# See cli manual at https://cli.github.com/manual/

#' This functions tries the gh command in a terminal. If it errors, the gh cli
#' isn't available on the machine or at least not on the PATH variable
#' @export
gh_cli_available <- function(){
  gh_test <- try(system("gh", intern = TRUE), silent = TRUE)

  if ( inherits(gh_test, "try-error") ){
    cli::cli_abort("The Github Command Line Interface is not available on your machine! \\
                   Please visit {.url https://github.com/cli/cli#installation} \\
                   for install instructions.")
  }

  invisible(TRUE)
}

#' Upload files to a GitHub release with the gh cli
#'
#' Uploads `files` to release `tag` of `repo` and retries failed uploads.
#'
#' Replacing an existing release asset (`overwrite = TRUE`) costs two
#' requests (delete + upload). Many uploads at the same moment, e.g. from a lot
#' of parallel workflow jobs, can trigger GitHub's secondary rate limit. After a
#' rate limit error this function waits at least one minute (as GitHub asks
#' clients to do), doubling up to 15 minutes, and then uploads only the files
#' that didn't make it. If the primary rate limit (5,000 requests per hour) is
#' exhausted, it waits until the limit resets. Every uploaded file costs about 3
#' requests of the primary rate limit.
#'
#' The behavior can be configured with environment variables:
#' - `NFLVERSE.UPLOAD.INSIST`: `"false"` disables retries.
#' - `NFLVERSE.UPLOAD.MAX_TIMES`: maximum number of attempts, default `6`.
#' - `NFLVERSE.UPLOAD.QUIET`: `"true"` silences retry messages.
#' - `NFLVERSE.UPLOAD.WRITES_PER_HOUR`: optional. If set, pace uploads so this
#'   R session makes no more than this many delete/upload requests per hour.
#'   After an upload, the function waits until the upload's share of the budget
#'   has passed. Unset (the default) means no pacing. Usually limiting the
#'   number of parallel jobs is enough.
#'
#' @param files vector of file paths to upload
#' @param tag release tag
#' @param ... currently not used
#' @param repo repository to upload to, default: `"nflverse/nflverse-data"`
#' @param overwrite If `TRUE` (the default) existing assets are replaced
#'
#' @return invisible `TRUE` on success, `FALSE` if there was nothing to upload.
#'   Errors if the upload still fails after the last attempt.
#' @export
gh_cli_release_upload <- function(files,
                                  tag,
                                  ...,
                                  repo = "nflverse/nflverse-data",
                                  overwrite = TRUE){
  # see https://cli.github.com/manual/gh_release_upload

  # validate file paths
  file_available <- file.exists(files)

  # if files are missing, warn the user and update the files vector to keep
  # valid file paths only. If there are no valid file paths, exit the function.
  if ( !all(file_available) ){
    cli::cli_alert_warning("The following file{?s} {?is/are} missing: {.path {files[!file_available]}}")

    if (all(file_available == FALSE)){
      cli::cli_alert_warning("There's nothing left to upload. Exiting!")
      return(invisible(FALSE))
    }
  }
  # keep valid file paths
  files <- files[file_available]

  # Make sure the gh cli is available
  gh_cli_available()

  cli::cli_alert_info(
    "Start upload of {cli::no(length(files))} file{?s} to \\
    {.url {paste0('https://github.com/', repo, '/releases')}} \\
    @ {.field {tag}}",
    wrap = TRUE
  )

  max_times <- .upload_max_times()
  quiet <- .upload_quiet()
  first_start <- Sys.time()
  to_upload <- files

  for (attempt in seq_len(max_times)) {
    started <- Sys.time()
    res <- .gh_cli_upload(to_upload, tag = tag, repo = repo, overwrite = overwrite)
    # delete + upload for every replaced asset
    n_writes <- length(to_upload) * (1L + isTRUE(overwrite))
    pace_until <- .upload_pace_until(started, n_writes)

    if (res$ok) {
      .sleep_until(pace_until, "Pacing uploads", quiet = quiet)
      cli::cli_alert_success("Upload successfully completed.")
      return(invisible(TRUE))
    }

    if (attempt == max_times) {
      cli::cli_abort(
        "The GitHub cli failed to upload {.val {basename(to_upload)}} to \\
        {.field {tag}} after {max_times} attempt{?s}. Last message: \\
        {.val {res$output}}",
        call = NULL
      )
    }

    wait <- .upload_retry_wait(attempt, rate_limited = .is_rate_limit_error(res$output))
    if (.is_primary_rate_limit_error(res$output)) {
      # wait for the hourly reset (+ a few seconds), at most a bit over an hour
      reset <- .core_rate_limit_reset()
      if (!is.null(reset)) {
        until_reset <- as.numeric(difftime(reset, started, units = "secs")) + 5
        wait <- max(wait, min(until_reset, 3700))
      }
    }
    if (!quiet) {
      cli::cli_alert_warning(
        "Upload attempt {attempt}/{max_times} failed: {.val {res$output}}"
      )
    }
    .sleep_until(max(started + wait, pace_until), "Waiting before retry", quiet = quiet)

    # gh uploads files one by one, so some of them may have made it. Retry only
    # the rest to avoid deleting and uploading those again.
    to_upload <- .files_not_in_release(to_upload, tag = tag, repo = repo, since = first_start)
    if (length(to_upload) == 0) {
      cli::cli_alert_success("All files are in the release after all. Upload completed.")
      return(invisible(TRUE))
    }
  }
}

#' @export
gh_cli_release_tags <- function(repo = "nflverse/nflverse-data"){
  # see https://cli.github.com/manual/gh_release_list

  # Make sure the gh cli is available
  gh_cli_available()

  # create command for the shell
  cli_command <- paste(
    "gh release list",
    "-R", repo,
    "--json tagName"
  )

  cli_output <- .invoke_cli_command(cli_command = cli_command)

  .cli_parse_json(cli_output = cli_output)[["tagName"]]
}

#' @import data.table
#' @export
gh_cli_release_assets <- function(tag, ..., repo = "nflverse/nflverse-data"){
  # see https://cli.github.com/manual/gh_release_view

  # Make sure the gh cli is available
  gh_cli_available()

  # create command for the shell
  cli_command <- paste(
    "gh release view",
    tag,
    "-R", repo,
    "--json assets"
  )

  cli_output <- .invoke_cli_command(cli_command = cli_command)

  out <- .cli_parse_json(cli_output = cli_output)[["assets"]]

  setDT(out)
  ret <- out[
    ,list(name, size, downloads = downloadCount, last_update = updatedAt, url)
  ][, size_string := as.character(rlang::as_bytes(size))
  ][!grepl("timestamp", name)]
  setDF(ret)
  ret
}

#' @export
gh_cli_release_delete_asset <- function(
  asset_name,
  tag,
  ...,
  repo = "nflverse/nflverse-data"
) {
  # see https://cli.github.com/manual/gh_release_delete-asset

  # Make sure the gh cli is available
  gh_cli_available()

  # The gh cli can't delete more than 1 asset per call
  stopifnot(
    "Can't handle more than 1 tag" = length(tag) == 1,
    "Can't handle more than 1 asset" = length(asset_name) == 1
  )

  cli::cli_progress_step(
    "Delete {.val {asset_name}} from {.pkg {paste0(repo, '/releases')}}@{.field {tag}}"
  )

  # create command for the shell
  cli_command <- paste(
    "gh release delete-asset",
    tag,
    asset_name,
    "-R",
    repo,
    "--yes"
  )

  cli_output <- .invoke_cli_command(cli_command = cli_command)

  cli::cli_progress_done()

  invisible(TRUE)
}

#' @export
gh_cli_rate_limits <- function(verbose = TRUE){
  # Make sure the gh cli is available
  gh_cli_available()

  # create command for the shell
  cli_command <- "gh api rate_limit"

  cli_output <- .invoke_cli_command(cli_command = cli_command)

  all_rates <- .cli_parse_json(cli_output = cli_output)
  rate <- all_rates$rate

  rate$reset_parsed <- format(as.POSIXct(rate$reset, origin = "1970-01-01", tz = "UTC"), usetz = TRUE)

  if (isTRUE(verbose)) cli::cli_ul(paste0(names(rate), " : ", rate))

  invisible(all_rates)
}

#' @export
.invoke_cli_command <- function(cli_command){
  # This command will error regularly on R error and also errors on warnings
  # because some failures raise a warning only and we want workflows to fail
  # if somethings didn't work
  out <- purrr::quietly(system)(cli_command, intern = TRUE)
  if (length(out$warnings)) {
    cli::cli_abort(
      "The GitHub cli errored with the following message: {.val {out$result}}. \\
      Here is the R message: {.val {out$warnings}}",
      call = NULL
    )
  }
  out$result
}

#' @export
.cli_parse_json <- function(cli_output){
  # regex shamelessly stolen from crayon::strip_style
  ansi_regex <-"(?:(?:\\x{001b}\\[)|\\x{009b})(?:(?:[0-9]{1,3})?(?:(?:;[0-9]{0,3})*)?[A-M|f-m])|\\x{001b}[A-M]"
  gsub(ansi_regex, "", cli_output, perl = TRUE, useBytes = TRUE) |>
    paste0(collapse = "") |>
    jsonlite::parse_json(simplifyVector = TRUE)
}
