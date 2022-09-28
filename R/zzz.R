.onLoad <- function(lib, pkg) {
  retry_rate <- purrr::rate_backoff(pause_base = 0.05, pause_min = 1, max_times = 10)

  assign(
    x = "nflverse_upload",
    value = purrr::insistently(nflverse_upload, rate = retry_rate),
    envir = parent.env(environment())
    )

  assign(
    x = "update_release_timestamp",
    value = purrr::insistently(update_release_timestamp, rate = retry_rate),
    envir = parent.env(environment())
    )
}
