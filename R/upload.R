#' Upload to nflverse release
#'
#' @param files vector of filepaths to upload
#' @param tag release name
#' @param ... currently not used
#' @param repo repository to upload to, default: `"nflverse/nflverse-data"`
#' @param overwrite If `TRUE` (the default) existing files will be overwritten
#'
#' @export
nflverse_upload <- function(files, tag, ..., repo = "nflverse/nflverse-data", overwrite = TRUE){
  # create timestamp_files in a temp folder
  timestamp_files <- create_timestamp_file()

  # append timestamp files to the actual files to upload
  # timestamp will be right BEFORE the upload begins instead of afterwards
  # but it won't be released at all if the upload breaks
  files <- c(files, timestamp_files)

  gh_cli_release_upload(files = files, tag = tag, repo = repo, overwrite = overwrite)
}

create_timestamp_file <- function(){
  temp_dir <- tempdir(check = TRUE)

  update_time <- format(Sys.time(), tz = nflreadr::nflverse_data_timezone, usetz = TRUE)
  writeLines(update_time, file.path(temp_dir, "timestamp.txt"))

  list(last_updated = update_time) |>
    jsonlite::toJSON(auto_unbox = TRUE) |>
    writeLines(file.path(temp_dir,"timestamp.json"))

  timestamp_files <- file.path(temp_dir, c("timestamp.txt", "timestamp.json"))

  timestamp_files
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
#' @param file_types one or more of `"rds", "csv", "parquet", "qs", "csv.gz"`
#' @param repo repository to upload to, default: `"nflverse/nflverse-data"`
#'
#' @export
nflverse_save <- function(data_frame,
                          file_name,
                          nflverse_type,
                          release_tag,
                          file_types = c("rds", "csv", "parquet", "qs", "csv.gz"),
                          repo = "nflverse/nflverse-data") {
  stopifnot(
    is.data.frame(data_frame),
    is.character(file_name) && length(file_name) == 1,
    is.character(nflverse_type) && length(nflverse_type) == 1,
    is.character(release_tag) && length(release_tag) == 1,
    is.character(file_types) && length(file_types) >= 1,
    is.character(repo) && length(repo) == 1
  )

  if ("season" %in% names(data_frame)) data_frame$season <- as.integer(data_frame$season)
  if ("week" %in% names(data_frame)) data_frame$week <- as.integer(data_frame$week)

  attr(data_frame, "nflverse_type") <- nflverse_type
  attr(data_frame, "nflverse_timestamp") <- format(Sys.time(), tz = nflreadr::nflverse_data_timezone, usetz = TRUE)

  temp_dir <- tempdir(check = TRUE)
  ft <- rlang::arg_match(file_types,
    values = c("rds", "csv", "csv.gz", "parquet", "qs"),
    multiple = TRUE
  )

  if ("rds" %in% ft) saveRDS(data_frame, file.path(temp_dir, paste0(file_name, ".rds")))
  if ("csv" %in% ft) data.table::fwrite(data_frame, file.path(temp_dir, paste0(file_name, ".csv")))
  if ("csv.gz" %in% ft) data.table::fwrite(data_frame, file.path(temp_dir, paste0(file_name, ".csv.gz")))
  if ("parquet" %in% ft) arrow::write_parquet(data_frame, file.path(temp_dir, paste0(file_name, ".parquet")))
  if ("qs" %in% ft) {
    qs::qsave(data_frame,
      file.path(temp_dir, paste0(file_name, ".qs")),
      preset = "custom",
      algorithm = "zstd_stream",
      compress_level = 22,
      shuffle_control = 15
    )
  }

  .filetypes <- paste0(".", ft)

  .file_names <- file.path(temp_dir, paste0(file_name, .filetypes))

  nflverse_upload(.file_names, tag = release_tag, repo = repo)
}
