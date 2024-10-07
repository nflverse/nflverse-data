.onLoad <- function(lib, pkg) {
  if (Sys.getenv("NFLVERSE.UPLOAD.INSIST", "true") == "true"){
    pause_base <- Sys.getenv("NFLVERSE.UPLOAD.PAUSE_BASE", 0.05) |> as.numeric()
    pause_min <- Sys.getenv("NFLVERSE.UPLOAD.PAUSE_MIN", 1) |> as.numeric()
    max_times <- Sys.getenv("NFLVERSE.UPLOAD.MAX_TIMES", 10) |> as.numeric()
    quiet <- Sys.getenv("NFLVERSE.UPLOAD.QUIET", "false") |> as.logical()

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
  }

  # PIGGYBACK seems to be using the GITHUB_PAT env var while the GitHub cli
  # uses GH_TOKEN. Since many of our workflows set GITHUB_PAT we catch
  # this problem here. We do this only in non interactive sessions to avoid
  # messing around with env vars on dev machines
  if (Sys.getenv("GH_TOKEN", unset = "") == "" && !interactive()){
    Sys.setenv("GH_TOKEN" = Sys.getenv("GITHUB_PAT"))
  }
}
