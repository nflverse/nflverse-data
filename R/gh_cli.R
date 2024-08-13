# See cli manual at https://cli.github.com/manual/

# This functions tries the gh command in a terminal. If it errors, the gh cli
# isn't available on the machine or at least not on the PATH variable
gh_cli_available <- function(){
  gh_test <- try(system2("gh", stderr = TRUE, stdout = FALSE), silent = TRUE)

  if ( inherits(gh_test, "try-error") ){
    cli::cli_alert_warning("The gh cli is not available on your machine!")
    return(FALSE)
  } else {
    return(TRUE)
  }
}

gh_cli_release_upload <- function(files,
                                  tag,
                                  ...,
                                  repo = "nflverse/nflverse-data",
                                  overwrite = TRUE){
  # see https://cli.github.com/manual/gh_release_upload

  # validate file paths
  file_available <- file.exists(files)
  if ( !all(file_available) ){
    cli::cli_abort("The following file{?s} {?is/are} missing: {.path {files[!file_available]}}")
  }

  # Make sure the gh cli is available
  if ( !gh_cli_available() ) return(invisible(FALSE))

  # create command for the shell
  cli_command <- paste(
    "gh release upload",
    tag,
    paste(files, collapse = " "),
    "-R", repo,
    if(isTRUE(overwrite)) "--clobber" else ""
  )
  # Start shell command
  cli::cli_progress_step("Start upload of {cli::no(length(files))} file{?s}")

  # This command will error if any error occurs.
  shell(cli_command, mustWork = TRUE)

  cli::cli_progress_done()

  invisible(TRUE)
}

