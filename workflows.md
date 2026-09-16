# nflverse workflow overview

THIS IS FOR INTERNAL USAGE

This file lists all (or at least most) of the scheduled github action workflows 
across nflverse repos. Information as of Wed, Sep 16, 2026. Might be outdated 
when checking in a couple years. We needed this to decide how to handle delays
in scheduled gh action workflows.

## nflverse-pbp-internal

### release_raw_pbp.yaml

Releases raw pbp of the latest finished games and commits released game IDs to `released_games.csv`.

``` yaml
# Runs every 15 minutes from September through February
cron:  '*/15 * * 1,2,9-12 *'
```

``` sh
gh workflow run release_raw_pbp.yaml -R nflverse/nflverse-pbp-internal
```

### refresh_raw_pbp.yaml

Refreshes raw pbp of the last week (last \~16 games) to incorporate stat corrections during the week.

``` yaml
# Runs at 02:00 AM UTC on Wednesday from September through February
cron:  '0 2 * 1,2,9-12 3'
```

``` sh
gh workflow run refresh_raw_pbp.yaml -R nflverse/nflverse-pbp-internal
```

## nflverse-pbp

### update_data.yaml

Releases parsed pbp, playstats summaries and stats. Workflow accepts season_rebuild and full_rebuild arguments but the default falls back to current season only.

``` yaml
# Every day at 9:00 UTC/5:00 ET
cron:  '0 9 * 1,2,9-12 *'
# TNF 5:30 AM UTC / 12:30 AM ET
cron:  '0 5 * 1,2,9-12 5'
# Early window: 10:00 PM UTC / 5:00 PM ET
cron:  '0 22 * 1,2,9-12 0'
# Late window: 0:00 UTC / 8:00 ET
cron:  '0 0 * 1,2,9-12 1'
# SNF/MNF: 5:30 UTC / 12:30 ET
cron:  '30 5 * 1,2,9-12 1'
cron:  '30 5 * 1,2,9-12 2'
```

``` sh
gh workflow run update_data.yaml -R nflverse/nflverse-pbp
```

## nflverse-rosters

### update_depth_charts.yaml

``` yaml
# every day at 7:00 AM UTC
cron:  '0 7 * * *'
```

``` sh
gh workflow run update_depth_charts.yaml -R nflverse/nflverse-rosters
```

### update_injuries.yaml

``` yaml
# runs every day at 7:00 AM UTC from Sep to Feb
cron:  '0 7 * 1,2,9,10,11,12 *'
```

``` sh
gh workflow run update_injuries.yaml -R nflverse/nflverse-rosters
```

### update_rosters.yaml

``` yaml
# every day at 7:00 AM UTC
cron:  '0 7 * * *'
```

``` sh
gh workflow run update_rosters.yaml -R nflverse/nflverse-rosters
```

## nflverse-pfr

Skipping combine and draft workflows because they aren't an issue at the moment.

### update_advanced_stats.yaml

``` yaml
# runs every day at 0,6,12,18 UTC in Sep-Jan
cron: '0 */6 * 9-12,1 *'
# runs every day at 0,6,12,18 UTC in Feb 1st through 15th
cron: '0 */6 1-15 2 *'
```

``` sh
gh workflow run update_advanced_stats.yaml -R nflverse/nflverse-pfr
```

### update_snap_counts.yaml

``` yaml
# runs every day at 0,6,12,18 UTC in Sep-Jan
cron: '0 */6 * 9-12,1 *'
# runs every day at 0,6,12,18 UTC in Feb 1st through 15th
cron: '0 */6 1-15 2 *'
```

``` sh
gh workflow run update_snap_counts.yaml -R nflverse/nflverse-pfr
```

## nflverse-ftn

Workflows in this repo aren't an issue at the moment. Listing the most important
one only.

### update_ftn.yaml

``` yaml
# every six hours Sep - Feb
cron: '0 */6 * 9-12,1-2 *'
```

``` sh
gh workflow run update_ftn.yaml -R nflverse/nflverse-ftn
```

## ngs-data

Workflows in this repo aren't an issue at the moment. Listing the most important
one only.

### update_ngs.yaml

``` yaml
# runs every day at 7:00 AM UTC Sep - Feb
cron:  '0 7 * 1,2,9-12 *'
```

``` sh
gh workflow run update_ngs.yaml -R nflverse/ngs-data
```
