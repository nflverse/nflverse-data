.onLoad <- function(lib, pkg) {
  if (Sys.getenv("NFLVERSE.UPLOAD.INSIST", "true") == "true"){
    pause_base <- Sys.getenv("NFLVERSE.UPLOAD.PAUSE_BASE", 0.05) |> as.numeric()
    pause_min <- Sys.getenv("NFLVERSE.UPLOAD.PAUSE_MIN", 1) |> as.numeric()
    max_times <- Sys.getenv("NFLVERSE.UPLOAD.MAX_TIMES", 10) |> as.numeric()
    quiet <- Sys.getenv("NFLVERSE.UPLOAD.QUIET", TRUE) |> as.logical()

    retry_rate <- purrr::rate_backoff(
      pause_base = pause_base,
      pause_min = pause_min,
      max_times = max_times
    )

    assign(
      x = "nflverse_upload",
      value = purrr::insistently(nflverse_upload, rate = retry_rate, quiet = quiet),
      envir = rlang::ns_env("nflversedata")
    )

    assign(
      x = "update_release_timestamp",
      value = purrr::insistently(update_release_timestamp, rate = retry_rate, quiet = quiet),
      envir = rlang::ns_env("nflversedata")
    )
  }
}
