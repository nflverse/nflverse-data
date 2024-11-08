# See cli manual at https://cli.github.com/manual/

# This functions tries the gh command in a terminal. If it errors, the gh cli
# isn't available on the machine or at least not on the PATH variable
gh_cli_available <- function(){
  gh_test <- try(system("gh", intern = TRUE), silent = TRUE)

  if ( inherits(gh_test, "try-error") ){
    cli::cli_abort("The Github Command Line Interface is not available on your machine! \\
                   Please visit {.url https://github.com/cli/cli#installation} \\
                   for install instructions.")
  }

  invisible(TRUE)
}

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

  # create command for the shell
  cli_command <- paste(
    "gh release upload",
    tag,
    paste(files, collapse = " "),
    "-R", repo,
    if(isTRUE(overwrite)) "--clobber" else ""
  )
  # Start shell command
  cli::cli_progress_step("Start upload of {cli::no(length(files))} file{?s} to \\
                         {.url {paste0('https://github.com/', repo, '/releases')}} \\
                         @ {.field {tag}}")

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

  cli::cli_progress_done()

  invisible(TRUE)
}

gh_cli_release_tags <- function(repo = "nflverse/nflverse-data"){
  # see https://cli.github.com/manual/gh_release_list

  # Make sure the gh cli is available
  gh_cli_available()

  # create command for the shell
  cli_command <- paste(
    "gh release list",
    "-R", repo
  )

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

  out <- strsplit(out$result, "\t", fixed = TRUE)
  # x[[3]] is the tagName
  vapply(out, function(x) x[[3]], FUN.VALUE = character(1L))
}

#' @import data.table
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

  # regex shamelessly stolen from crayon::strip_style
  ansi_regex <-"(?:(?:\\x{001b}\\[)|\\x{009b})(?:(?:[0-9]{1,3})?(?:(?:;[0-9]{0,3})*)?[A-M|f-m])|\\x{001b}[A-M]"
  out <- gsub(ansi_regex, "", out$result, perl = TRUE, useBytes = TRUE) |>
    paste0(collapse = "") |>
    jsonlite::parse_json(simplifyVector = TRUE) |>
    getElement("assets")

  setDT(out)

  ret <- out[,list(name, size, downloads = downloadCount, last_update = updatedAt, url)][
    , size_string := as.character(rlang::as_bytes(size))
  ]
  ret <- ret[!grepl("timestamp", name)]

  setDF(ret)
  ret
}

