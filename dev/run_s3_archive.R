pkgload::load_all()
print(
  nflreadr::nflverse_sitrep(
    c("nflversedata", "nflreadr", "piggyback")
  )
)

purrr::walk(
  piggyback::pb_releases("nflverse/nflverse-data")$tag_name,
  .nflverse_download_assets,
  file_type = ".rds",
  download_dir = file.path("archive", "rds", format(Sys.Date()))
)

purrr::walk(
  piggyback::pb_releases("nflverse/nflverse-data")$tag_name,
  .nflverse_download_assets,
  file_type = ".parquet",
  download_dir = file.path("archive", "parquet", format(Sys.Date()))
)

aws.s3::s3sync(
  path = "archive",
  bucket = "nflverse",
  region = "",
  direction = "upload",
  multipart = TRUE
)
