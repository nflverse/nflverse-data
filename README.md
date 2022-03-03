# nflverse-data

This repository holds automated data releases for nflverse projects. 

## Usage

You can download data hosted here with the `{nflreadr}` package, or manually download and access the [releases](https://github.com/nflverse/nflverse-data/releases) page. Releases are roughly organized along the [main functions](https://nflreadr.nflverse.com/reference/) of nflreadr.

## Automation Status

This page reports the schedule and status of nflverse data pipelines.

### Play by Play

![raw](https://img.shields.io/github/last-commit/nflverse/nflfastR-raw?label=Raw%20PBP%20Updated&style=flat-square)

Raw JSON should appear 1-2 hours after each game.

![pbp and ps](https://img.shields.io/github/workflow/status/nflverse/nflfastR-data/update_current_season_pbp_and_stats?label=PBP%20%26%20Player%20Stats&style=flat-square)

PBP and PS are updated at 9:00 UTC each day from September to February

### Rosters
![rosters](https://img.shields.io/github/workflow/status/nflverse/nflfastR-roster/update_rosters?label=Rosters&style=flat-square)

Rosters are updated at 7:00 UTC each day.

### Snap Counts
![snap_counts](https://img.shields.io/github/workflow/status/nflverse/pfr_scrapR/update_snap_counts?label=Snap%20Counts&style=flat-square)

Snap counts are polled four times a day for new data.

### Advanced Pass/Rush/Rec/Def Stats

![adv_stats](https://img.shields.io/github/workflow/status/nflverse/pfr_scrapR/update_adv_stats?label=PFR%20Adv%20Stats&style=flat-square)

Advanced Stats are polled four times a day for new data.

### Next Gen Stats

![ngs](https://img.shields.io/github/workflow/status/nflverse/ngs-data/update_ngs?label=NGS%20data&style=flat-square)

NGS is polled every day at 7:00 UTC from September to February.

### nfl4th

![nfl4th](https://img.shields.io/github/workflow/status/nflverse/nfl4th/update-computed-numbers?label=nfl4th_precompute&style=flat-square)

nfl4th's precomputed numbers are rebuilt each day at 7:00 UTC from September to February.

### ffverse player IDs
![weekly-playerids](https://img.shields.io/github/workflow/status/dynastyprocess/data/weekly-playerids?label=ff_playerids&style=flat-square)

This is updated on a weekly basis.

### ffverse rankings
![weekly-fantasypros](https://img.shields.io/github/workflow/status/dynastyprocess/data/weekly-fantasypros?label=rankings&style=flat-square)

This is updated on Thursdays at 7:00 pm ET. 
