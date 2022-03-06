
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nflverse-data

<!-- badges: start -->
<!-- badges: end -->

This repository holds automated data releases for nflverse projects
(i.e. all of the data powered/scraped via GitHub Actions).

## Usage

You can download data hosted here with the `{nflreadr}` package, or
manually download and access the
[releases](https://github.com/nflverse/nflverse-data/releases) page.
Releases are roughly organized along the [main
functions](https://nflreadr.nflverse.com/reference/) of nflreadr.

## Automation Status

The following table reports on the status and last update times of
nflverse data pipelines.

| Data               | Status                                                                                                                                                     | Last Updated                                                                                                                                                                                                                       |
|:-------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| pbp\_raw           |                                                                                                                                                            | ![raw pbp data](https://img.shields.io/github/last-commit/nflverse/nflfastR-raw?label=Raw%20PBP%20Updated&style=flat-square)                                                                                                       |
| pbp                | ![pbp and ps](https://img.shields.io/github/workflow/status/nflverse/nflfastR-data/update_current_season_pbp_and_stats?label=pbp_status&style=flat-square) | ![pbp](https://img.shields.io/badge/dynamic/json?color=blue&label=load_pbp&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/pbp/timestamp.json)                                |
| player\_stats      | ![pbp and ps](https://img.shields.io/github/workflow/status/nflverse/nflfastR-data/update_current_season_pbp_and_stats?label=ps_status&style=flat-square)  | ![player\_stats](https://img.shields.io/badge/dynamic/json?color=blue&label=load_player_stats&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/player_stats/timestamp.json)    |
| rosters            | ![rosters](https://img.shields.io/github/workflow/status/nflverse/nflfastR-roster/update_rosters?label=rosters_status&style=flat-square)                   | ![rosters](https://img.shields.io/badge/dynamic/json?color=blue&label=load_rosters&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/rosters/timestamp.json)                    |
| snap\_counts       | ![snap\_counts](https://img.shields.io/github/workflow/status/nflverse/pfr_scrapR/update_snap_counts?label=snaps_status&style=flat-square)                 | ![snap\_counts](https://img.shields.io/badge/dynamic/json?color=blue&label=load_snap_counts&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/snap_counts/timestamp.json)       |
| pfr\_advstats      | ![adv\_stats](https://img.shields.io/github/workflow/status/nflverse/pfr_scrapR/update_adv_stats?label=advstats_status&style=flat-square)                  | ![pfr\_advstats](https://img.shields.io/badge/dynamic/json?color=blue&label=load_pfr_advstats&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/pfr_advstats/timestamp.json)    |
| nextgen\_stats     | ![ngs](https://img.shields.io/github/workflow/status/nflverse/ngs-data/update_ngs?label=ngs_status&style=flat-square)                                      | ![nextgen\_stats](https://img.shields.io/badge/dynamic/json?color=blue&label=load_nextgen_stats&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/nextgen_stats/timestamp.json) |
| injuries           |                                                                                                                                                            | ![injuries](https://img.shields.io/badge/dynamic/json?color=blue&label=load_injuries&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/injuries/timestamp.json)                 |
| depth\_charts      |                                                                                                                                                            | ![depth\_charts](https://img.shields.io/badge/dynamic/json?color=blue&label=load_depth_charts&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/depth_charts/timestamp.json)    |
| combine            |                                                                                                                                                            | ![combine](https://img.shields.io/badge/dynamic/json?color=blue&label=load_combine&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/combine/timestamp.json)                    |
| nfl4th             | ![nfl4th](https://img.shields.io/github/workflow/status/nflverse/nfl4th/update-computed-numbers?label=nfl4th_precompute&style=flat-square)                 |                                                                                                                                                                                                                                    |
| ffverse player IDs | ![weekly-playerids](https://img.shields.io/github/workflow/status/dynastyprocess/data/weekly-playerids?label=ff_playerids&style=flat-square)               |                                                                                                                                                                                                                                    |
| ffverse rankings   | ![weekly-fantasypros](https://img.shields.io/github/workflow/status/dynastyprocess/data/weekly-fantasypros?label=rankings&style=flat-square)               |                                                                                                                                                                                                                                    |
