#' Upload to nflverse release
#'
#' @param files vector of filepaths to upload
#' @param tag release name
#' @param ... other args passed to `piggyback::pb_upload()`
#'
#' @export
nflverse_upload <- function(files, tag, ...){
  cli::cli_alert("Uploading {length(files)} files!")
  # upload files
  piggyback::pb_upload(files, repo = "nflverse/nflverse-data", tag = tag, ...)
  update_release_timestamp(tag)
  cli::cli_alert("Uploaded {length(files)} to nflverse/nflverse-data @ {tag} on {Sys.time()}")
}

update_release_timestamp <- function(tag){
  temp_dir <- tempdir(check = TRUE)

  update_time <- format(Sys.time(), tz = "America/Toronto", usetz = TRUE)
  writeLines(update_time, file.path(temp_dir, "timestamp.txt"))

  list(last_updated = update_time) |>
    jsonlite::toJSON(auto_unbox = TRUE) |>
    writeLines(file.path(temp_dir,"timestamp.json"))

  piggyback::pb_upload(file.path(temp_dir,"timestamp.txt"), repo = "nflverse/nflverse-data", tag = tag, overwrite = TRUE)
  piggyback::pb_upload(file.path(temp_dir,"timestamp.json"), repo = "nflverse/nflverse-data", tag = tag, overwrite = TRUE)

  invisible(NULL)
}

#' Save files to nflverse release
#'
#' This functions attaches nflverse attributes like type and timestamp, saves
#' data to a temporary directory in all four of csv, rds, parquet, and qs formats,
#' and then uploads to nflverse-data repository for a specified release tag.
#'
#' @param data_frame data_frame to save
#' @param file_name file_name to upload as, without the file extension
#' @param nflverse_type metadata: name/information to add to data
#' @param release_tag name of release to upload to
#' @param .token a GitHub token, defaults to gh::gh_token()
#'
#' @export
nflverse_save <- function(data_frame,
                          file_name,
                          nflverse_type,
                          release_tag,
                          .token = gh::gh_token(),
                          include_gz = FALSE
                          ){

  stopifnot(
    is.data.frame(data_frame),
    is.character(file_name),
    is.character(nflverse_type),
    is.character(release_tag),
    is.character(.token),
    length(file_name) == 1,
    length(nflverse_type) == 1,
    length(release_tag) == 1,
    length(.token) == 1
  )

  attr(data_frame,"nflverse_type") <- nflverse_type
  attr(data_frame,"nflverse_timestamp") <- Sys.time()

  temp_dir <- tempdir(check = TRUE)

  saveRDS(data_frame,file.path(temp_dir,paste0(file_name,".rds")))
  data.table::fwrite(data_frame, file.path(temp_dir,paste0(file_name,".csv")))
  if(include_gz) data.table::fwrite(data_frame, file.path(temp_dir,paste0(file_name,".csv.gz")))
  arrow::write_parquet(data_frame, file.path(temp_dir, paste0(file_name,".parquet")))
  qs::qsave(data_frame,
            file.path(temp_dir,paste0(file_name,".qs")),
            preset = "custom",
            algorithm = "zstd_stream",
            compress_level = 22,
            shuffle_control = 15)

  .filetypes <- if(include_gz) c(".rds",".csv",".csv.gz",".parquet",".qs") else c(".rds",".csv",".parquet",".qs")

  .file_names <- file.path(temp_dir, paste0(file_name,.filetypes))

  nflverse_upload(.file_names,tag = release_tag, .token = .token)
}
