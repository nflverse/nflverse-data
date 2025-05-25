print(
  nflreadr::nflverse_sitrep(
    c("nflversedata", "nflreadr", "piggyback")
  )
)

purrr::walk(
  piggyback::pb_releases("nflverse/nflverse-data")$tag_name,
  \(x) nflversedata::.nflverse_download_assets(
    release_tag = x,
    file_type = ".rds",
    download_dir = file.path("archives", "archive", format(Sys.Date()), "rds")
  )
)

purrr::walk(
  piggyback::pb_releases("nflverse/nflverse-data")$tag_name,
  \(x) nflversedata::.nflverse_download_assets(
    release_tag = x,
    file_type = ".parquet",
    download_dir = file.path("archives", "archive", format(Sys.Date()), "parquet")
  )
)

aws.s3::s3sync(
  path = "archives",
  bucket = "nflverse",
  region = "",
  direction = "upload",
  multipart = TRUE
)
