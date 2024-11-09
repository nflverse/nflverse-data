#' Archive nflverse
#'
#' @param release_name Name of the release. Must be available in `repo`
#' @param archive_tag The release tag to which data from `release_name` should
#' be uploaded
#' @param ... Currently not in use
#' @param file_type The file type that should be archived. In most cases this
#' should be `".rds"`
#' @param repo The repo we want to download assets from.
#'
#' @export
nflverse_archive <- function(release_name,
                             archive_tag,
                             ...,
                             file_type = ".rds",
                             repo = "nflverse/nflverse-data"){
  cli::cli_alert_info("Archiving {release_name}")

  file_list <- .nflverse_download_assets(release_name)

  gh_cli_release_upload(
    files = file_list,
    tag = archive_tag,
    repo = "nflverse/nflverse-data-archives",
    overwrite = TRUE
  )

  # Get rid of temporary downloaded files
  unlink(unique(dirname(file_list)), recursive = TRUE)
  cli::cli_alert_success("DONE")
  invisible(TRUE)
}

.nflverse_download_assets <- function(release_tag,
                                      file_type = ".rds",
                                      repo = "nflverse/nflverse-data"){
  # Query table of assets in release tag
  assets <- gh_cli_release_assets(tag = tag, repo = repo)
  # Filter down to file_types we want
  assets_to_load <- assets[grepl(file_type, assets$url),]
  # These are the urls we need to download the files from
  load_from <- assets_to_load$url
  # Create temp directory to save the assets to
  save_dir <- file.path(tempdir(), release_tag)
  if (!dir.exists(save_dir)) dir.create(save_dir)
  # Vector of file_paths. We need to pass this to curl multidownload
  save_to <- file.path(save_dir, assets_to_load$name)
  # Some log messages
  cli::cli_alert_info("Going to download the following {cli::qty(nrow(assets_to_load))}file{?s}:")
  cli::cli_ul(paste0(assets_to_load$name, " (", assets_to_load$size_string, ")"))
  # Trigger the download
  download <- curl::multi_download(load_from, save_to)
  # Rteurn the paths to the successfully downloaded files
  list.files(save_dir, pattern = file_type, full.names = TRUE)
}
