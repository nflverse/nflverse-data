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
  x <- tempdir(check = TRUE)
  on.exit(file.remove(file.path(x,"timestamp.txt")), add = TRUE)

  update_time <- format(Sys.time(),tz = "America/Toronto",usetz = TRUE)
  writeLines(update_time, file.path(x,"timestamp.txt"))

  list(last_updated = update_time) |> jsonlite::toJSON(auto_unbox = TRUE) |> writeLines(file.path(x,"timestamp.json"))

  piggyback::pb_upload(file.path(x,"timestamp.txt"), repo = "nflverse/nflverse-data", tag = tag, overwrite = TRUE)
  piggyback::pb_upload(file.path(x,"timestamp.json"), repo = "nflverse/nflverse-data", tag = tag, overwrite = TRUE)

  # current_release <- httr::GET(glue::glue("https://api.github.com/repos/nflverse/nflverse-data/releases/tags/{tag}")) |>
  #   httr::content()
  #
  # current_body <- current_release$body
  #
  # new_body <- gsub("Last Updated: .*$", "",x = current_body) |> paste0("Last Updated: ",update_time)
  #
  # update_result <- httr::PATCH(glue::glue("https://api.github.com/repos/nflverse/nflverse-data/releases/{current_release$id}"),
  #             httr::add_headers(Authorization = paste("token",gh::gh_token())),
  #             body = jsonlite::toJSON(list(body = new_body),auto_unbox = TRUE))

  invisible(NULL)
}