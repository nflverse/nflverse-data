#' Archive nflverse
#'
#' @param release_name Name of the release
#' @param archive_tag The release tag to which data from `release_name` should
#' be uploaded
#'
#' @export
nflverse_archive <- function(release_name, archive_tag){
  cli::cli_alert_info("Archiving {release_name}")
  temp_dir <- tempdir()
  nflreadr::nflverse_download(!!release_name, folder_path = temp_dir, file_type = "rds")

  file_list <- list.files(file.path(temp_dir,release_name))

  fs::file_move(
    file.path(temp_dir,release_name,file_list),
    file.path(temp_dir,release_name, paste0(release_name,"_",file_list))
  )

  # cli::cli_alert_info("Uploading Files to {.path nflverse/nflverse-data-archives@{archive_tag}}")
  gh_cli_release_upload(
    files = list.files(file.path(temp_dir, release_name), full.names = TRUE),
    tag = archive_tag,
    repo = "nflverse/nflverse-data-archives",
    overwrite = TRUE
  )

  cli::cli_alert_success("Successfully archived {release_name}")
  invisible(NULL)
}
