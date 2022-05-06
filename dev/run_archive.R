pkgload::load_all()
piggyback::pb_releases("nflverse/nflverse-data")$tag_name |>
  lapply(nflversedata::nflverse_archive)
