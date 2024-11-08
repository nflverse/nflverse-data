tag <- Sys.getenv("NFLVERSE_ARCHIVE_TAG", unset = NA_character_)
archive_tag <- Sys.getenv("NFLVERSE_ARCHIVE_TO", unset = NA_character_)

if (is.na(tag) || is.na(archive_tag)){
  cli::cli_abort("Can't find the release tag to archive!")
} else {
  nflversedata::nflverse_archive(release_name = tag, archive_tag = archive_tag)
}

# Create tag list for workflow file
# all_tags <- piggyback::pb_releases("nflverse/nflverse-data")$tag_name
# cli::cli_bullets(paste("-", sort(all_tags)))
