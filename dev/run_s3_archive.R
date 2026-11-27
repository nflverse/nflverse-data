logger::log_info("JOB START")
print(
  nflreadr::nflverse_sitrep(
    c("nflversedata", "nflreadr", "piggyback")
  )
)
logger::log_info("Downloading rds files from nflverse-data releases")
purrr::walk(
  nflversedata::gh_cli_release_tags(),
  \(x) nflversedata::.nflverse_download_assets(
    release_tag = x,
    file_type = ".rds",
    download_dir = file.path("archive", format(Sys.Date()), "rds")
  )
)

# Upload to S3 happens in the workflow's rclone step
logger::log_info("JOB COMPLETE")
