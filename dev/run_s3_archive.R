logger::log_info("JOB START")
print(
  nflreadr::nflverse_sitrep(
    c("nflversedata", "nflreadr", "piggyback", "minioclient")
  )
)
logger::log_info("Downloading rds files from nflverse-data releases")
purrr::walk(
  piggyback::pb_releases("nflverse/nflverse-data")$tag_name,
  \(x) nflversedata::.nflverse_download_assets(
    release_tag = x,
    file_type = ".rds",
    download_dir = file.path("archive", format(Sys.Date()), "rds")
  )
)

logger::log_info("Downloading parquet files from nflverse-data releases")
purrr::walk(
  piggyback::pb_releases("nflverse/nflverse-data")$tag_name,
  \(x) nflversedata::.nflverse_download_assets(
    release_tag = x,
    file_type = ".parquet",
    download_dir = file.path("archive", format(Sys.Date()), "parquet")
  )
)

logger::log_info("Syncing files to S3 via minioclient")
minioclient::install_mc()
minioclient::mc_alias_set(alias = "nfl_cf")

minioclient::mc_cp(
  "archive",
  "nfl_cf/nflverse",
  recursive = TRUE,
  verbose = TRUE
)

logger::log_info("JOB COMPLETE")
