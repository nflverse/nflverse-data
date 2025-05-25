logger::log_info("JOB START")
options(verbose = TRUE)
print(
  nflreadr::nflverse_sitrep(
    c("nflversedata", "nflreadr", "piggyback")
  )
)
logger::log_info("Downloading rds files from nflverse-data releases")
purrr::walk(
  piggyback::pb_releases("nflverse/nflverse-data")$tag_name,
  \(x) nflversedata::.nflverse_download_assets(
    release_tag = x,
    file_type = ".rds",
    download_dir = file.path("archive", "archive", format(Sys.Date()), "rds")
  )
)

logger::log_info("Downloading parquet files from nflverse-data releases")
purrr::walk(
  piggyback::pb_releases("nflverse/nflverse-data")$tag_name,
  \(x) nflversedata::.nflverse_download_assets(
    release_tag = x,
    file_type = ".parquet",
    download_dir = file.path("archive", "archive", format(Sys.Date()), "parquet")
  )
)

logger::log_info("Syncing files to S3")
aws.s3::s3sync(
  path = "archive",
  bucket = "nflverse",
  region = "",
  verbose = TRUE,
  multipart = TRUE
)
logger::log_info("JOB COMPLETE")
