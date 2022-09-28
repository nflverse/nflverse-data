#' Upload to nflverse release
#'
# @param files vector of filepaths to upload
# @param tag release name
#' @param ... other args passed to `piggyback::pb_upload()`
#'
#' @importFrom purrr insistently rate_backoff
#' @export
nflverse_upload <- purrr::insistently(function(files, tag, ...){
  cli::cli_alert("Uploading {length(files)} files!")
  # upload files
  piggyback::pb_upload(files, repo = "nflverse/nflverse-data", tag = tag, ...)
  update_release_timestamp(tag)
  cli::cli_alert("Uploaded {length(files)} to nflverse/nflverse-data @ {tag} on {Sys.time()}")
}, rate = purrr::rate_backoff(pause_base = 0.05, pause_min = 1, max_times = 10))

update_release_timestamp <- purrr::insistently(function(tag){
  temp_dir <- tempdir(check = TRUE)

  update_time <- format(Sys.time(), tz = "America/Toronto", usetz = TRUE)
  writeLines(update_time, file.path(temp_dir, "timestamp.txt"))

  list(last_updated = update_time) |>
    jsonlite::toJSON(auto_unbox = TRUE) |>
    writeLines(file.path(temp_dir,"timestamp.json"))

  piggyback::pb_upload(file.path(temp_dir,"timestamp.txt"), repo = "nflverse/nflverse-data", tag = tag, overwrite = TRUE)
  piggyback::pb_upload(file.path(temp_dir,"timestamp.json"), repo = "nflverse/nflverse-data", tag = tag, overwrite = TRUE)

  invisible(NULL)
}, rate = purrr::rate_backoff(pause_base = 0.05, pause_min = 1, max_times = 10))

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
#' @param file_types one or more of c("rds","csv","parquet","qs","csv.gz")
#'
#' @export
nflverse_save <- function(data_frame,
                          file_name,
                          nflverse_type,
                          release_tag,
                          .token = gh::gh_token(),
                          file_types = c("rds","csv","parquet","qs")
){

  stopifnot(
    is.data.frame(data_frame),
    is.character(file_name),
    is.character(nflverse_type),
    is.character(release_tag),
    is.character(.token),
    is.character(file_types),
    length(file_name) == 1,
    length(nflverse_type) == 1,
    length(release_tag) == 1,
    length(.token) == 1,
    length(file_types) >= 1
  )

  if("season" %in% names(data_frame)) data_frame$season <- as.integer(data_frame$season)
  if("week" %in% names(data_frame)) data_frame$week <- as.integer(data_frame$week)
  attr(data_frame,"nflverse_type") <- nflverse_type
  attr(data_frame,"nflverse_timestamp") <- Sys.time()

  temp_dir <- tempdir(check = TRUE)
  ft <- rlang::arg_match(file_types,
                         values = c("rds","csv","csv.gz","parquet","qs"),
                         multiple = TRUE)

  if("rds" %in% ft) saveRDS(data_frame,file.path(temp_dir,paste0(file_name,".rds")))
  if("csv" %in% ft) data.table::fwrite(data_frame, file.path(temp_dir,paste0(file_name,".csv")))
  if("csv.gz" %in% ft) data.table::fwrite(data_frame, file.path(temp_dir,paste0(file_name,".csv.gz")))
  if("parquet" %in% ft) arrow::write_parquet(data_frame, file.path(temp_dir, paste0(file_name,".parquet")))
  if("qs" %in% ft){
    qs::qsave(data_frame,
              file.path(temp_dir,paste0(file_name,".qs")),
              preset = "custom",
              algorithm = "zstd_stream",
              compress_level = 22,
              shuffle_control = 15)
  }

  .filetypes <- paste0(".",ft)

  .file_names <- file.path(temp_dir, paste0(file_name,.filetypes))

  nflverse_upload(.file_names,tag = release_tag, .token = .token)
}
