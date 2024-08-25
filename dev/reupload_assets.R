# REUPLOAD PBP ------------------------------------------------------------

# save rds files to this local path
path_to_save_rds <- file.path("dev", "pbp", "download")
# run this in console
paste("gh release download pbp -p '*.rds' --dir", path_to_save_rds)
# list of loaded files
file_list <- list.files(path_to_save_rds, pattern = ".rds", full.names = TRUE)
# adjust as necessary
purrr::walk(file_list, function(x){
  cli::cli_progress_step("Adjust {.val {x}}")
  pbp <- readRDS(x)
  attr(pbp, "nflverse_timestamp") <- format(attr(pbp, "nflverse_timestamp"), tz = nflreadr::nflverse_data_timezone, usetz = TRUE)
  attr(pbp, "nflfastR_version") <- as.character(attr(pbp, "nflfastR_version"))
  save_to <- basename(x) |> tools::file_path_sans_ext()
  arrow::write_parquet(pbp, file.path("dev", "pbp", "upload", paste0(save_to, ".parquet")))
  cli::cli_progress_done()
})
# Files to upload live here
path_to_new_data <- file.path("dev", "pbp", "upload")
# I want all parquet files for now
new_file_list <- list.files(path_to_new_data, pattern = ".parquet", full.names = TRUE)
# upload with nflversedata to adjust the timestamp
nflversedata::nflverse_upload(files = new_file_list, tag = "pbp")
