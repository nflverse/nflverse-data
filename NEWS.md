# nflversedata 0.0.18

* `gh_cli_release_upload()` (and therefore `nflverse_upload()` and `nflverse_save()`) now retries failed uploads itself instead of wrapping `nflverse_upload()` in `purrr::insistently()`. After a GitHub rate limit error it waits at least one minute, backing off up to 15 minutes, and uploads only the files that are not in the release yet. Other errors are retried after 5 to 60 seconds. The gh cli error message is now included in the logs. `NFLVERSE.UPLOAD.INSIST`, `NFLVERSE.UPLOAD.MAX_TIMES` (now defaults to 6) and `NFLVERSE.UPLOAD.QUIET` still work, `NFLVERSE.UPLOAD.PAUSE_BASE` and `NFLVERSE.UPLOAD.PAUSE_MIN` are no longer used.
* New environment variable `NFLVERSE.UPLOAD.WRITES_PER_HOUR` paces uploads to stay below GitHub's secondary rate limit of 500 content-creating requests per hour during large rebuilds.
* `nflverse_upload()` and `nflverse_save()` gained the argument `timestamp`. Set it to `FALSE` and call the new `nflverse_upload_timestamp()` once to avoid uploading the timestamp files with every single dataset.

# nflversedata 0.0.16

* dropped qs support as the dependency was removed from CRAN on 2026-01-17. (#87)

# nflversedata 0.0.7

* `nflverse_upload()` uses `purrr::insistently()` to retry on failure because of random GitHub server issues. 

# nflversedata 0.0.5 

* Added file_types argument which takes a vector of file types and defaults to `c("csv","rds","qs","parquet")`

# nflversedata 0.0.4

* Added `nflverse_archive()` which automates archiving the rds version of every nflverse-data release asset and pushes it to https://github.com/nflverse/nflverse-data-archives

# nflversedata 0.0.3

* Added `nflverse_save()` which automates saving to the four main supported file formats (csv, rds, parquet, qs) and uploading to a specified release tag.

# nflversedata 0.0.2

* Added a `NEWS.md` file to track changes to the package.
* Added timestamp.json to experiment with shields.io badges

# nflversedata 0.0.1

* Added data upload wrapper function (`nflverse_upload()`) including timestamp updates.
