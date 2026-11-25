.onLoad <- function(lib, pkg) {
  # Upload retries live in gh_cli_release_upload(). They used to be done here
  # with purrr::insistently(), which retried the whole upload within seconds
  # and made GitHub's secondary rate limit worse.

  # PIGGYBACK seems to be using the GITHUB_PAT env var while the GitHub cli
  # uses GH_TOKEN. Since many of our workflows set GITHUB_PAT we catch
  # this problem here. We do this only in non interactive sessions to avoid
  # messing around with env vars on dev machines
  if (Sys.getenv("GH_TOKEN", unset = "") == "" && !interactive()){
    Sys.setenv("GH_TOKEN" = Sys.getenv("GITHUB_PAT"))
  }
}
