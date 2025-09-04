
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

| Data | Status | Last Updated |
|:---|:---|:---|
| pbp_raw | []() | [![raw pbp data](https://img.shields.io/github/last-commit/nflverse/nflfastR-raw?label=Raw%20PBP%20Updated&style=flat-square)]() |
| pbp | [![pbp and ps](https://img.shields.io/github/actions/workflow/status/nflverse/nflverse-pbp/update_data.yaml?label=pbp_status&style=flat-square)]() | [![pbp](https://img.shields.io/badge/dynamic/json?color=blue&label=load_pbp&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/pbp/timestamp.json)](https://github.com/nflverse/nflverse-data/releases/tag/pbp) |
| player_stats | [![pbp and ps](https://img.shields.io/github/actions/workflow/status/nflverse/nflverse-pbp/update_data.yaml?label=ps_status&style=flat-square)]() | [![player_stats](https://img.shields.io/badge/dynamic/json?color=blue&label=load_player_stats&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/player_stats/timestamp.json)](https://github.com/nflverse/nflverse-data/releases/tag/player_stats) |
| rosters | [![rosters](https://img.shields.io/github/actions/workflow/status/nflverse/nflverse-rosters/update_rosters.yaml?label=rosters_status&style=flat-square)]() | [![rosters](https://img.shields.io/badge/dynamic/json?color=blue&label=load_rosters&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/rosters/timestamp.json)](https://github.com/nflverse/nflverse-data/releases/tag/rosters) |
| players | [![players](https://img.shields.io/github/actions/workflow/status/nflverse/nflverse-players/update_players.yaml?label=players_status&style=flat-square)]() | [![players](https://img.shields.io/badge/dynamic/json?color=blue&label=load_players&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/players/timestamp.json)](https://github.com/nflverse/nflverse-data/releases/tag/players) |
| snap_counts | [![snap_counts](https://img.shields.io/github/actions/workflow/status/nflverse/pfr_scrapR/update_snap_counts.yaml?label=snaps_status&style=flat-square)]() | [![snap_counts](https://img.shields.io/badge/dynamic/json?color=blue&label=load_snap_counts&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/snap_counts/timestamp.json)](https://github.com/nflverse/nflverse-data/releases/tag/snap_counts) |
| draft_picks | [![snap_counts](https://img.shields.io/github/actions/workflow/status/nflverse/pfr_scrapR/update_draft_picks.yaml?label=draft_status&style=flat-square)]() | [![draft_picks](https://img.shields.io/badge/dynamic/json?color=blue&label=load_draft_picks&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/draft_picks/timestamp.json)](https://github.com/nflverse/nflverse-data/releases/tag/draft_picks) |
| pfr_advstats | [![adv_stats](https://img.shields.io/github/actions/workflow/status/nflverse/pfr_scrapR/update_advanced_stats.yaml?label=advstats_status&style=flat-square)]() | [![pfr_advstats](https://img.shields.io/badge/dynamic/json?color=blue&label=load_pfr_advstats&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/pfr_advstats/timestamp.json)](https://github.com/nflverse/nflverse-data/releases/tag/pfr_advstats) |
| nextgen_stats | [![ngs](https://img.shields.io/github/actions/workflow/status/nflverse/ngs-data/update_ngs.yaml?label=ngs_status&style=flat-square)]() | [![nextgen_stats](https://img.shields.io/badge/dynamic/json?color=blue&label=load_nextgen_stats&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/nextgen_stats/timestamp.json)](https://github.com/nflverse/nflverse-data/releases/tag/nextgen_stats) |
| injuries | [![injuries](https://img.shields.io/github/actions/workflow/status/nflverse/nflverse-rosters/update_injuries.yaml?label=injuries_status&style=flat-square)]() | [![injuries](https://img.shields.io/badge/dynamic/json?color=blue&label=load_injuries&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/injuries/timestamp.json)](https://github.com/nflverse/nflverse-data/releases/tag/injuries) |
| depth_charts | [![depthcharts](https://img.shields.io/github/actions/workflow/status/nflverse/nflverse-rosters/update_depth_charts.yaml?label=depth_charts_status&style=flat-square)]() | [![depth_charts](https://img.shields.io/badge/dynamic/json?color=blue&label=load_depth_charts&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/depth_charts/timestamp.json)](https://github.com/nflverse/nflverse-data/releases/tag/depth_charts) |
| combine | [![combine](https://img.shields.io/github/actions/workflow/status/nflverse/pfr_scrapR/update_combine.yaml?label=combine_status&style=flat-square)]() | [![combine](https://img.shields.io/badge/dynamic/json?color=blue&label=load_combine&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/combine/timestamp.json)](https://github.com/nflverse/nflverse-data/releases/tag/combine) |
| nfl4th | [![nfl4th](https://img.shields.io/github/actions/workflow/status/nflverse/nfl4th/update_precompute.yaml?label=nfl4th_precompute&style=flat-square)]() |  |
| ffverse player IDs | [![weekly-playerids](https://img.shields.io/github/actions/workflow/status/dynastyprocess/data/weekly-playerids.yml?label=ff_playerids&style=flat-square)]() |  |
| ffverse rankings | [![weekly-fantasypros](https://img.shields.io/github/actions/workflow/status/dynastyprocess/data/weekly-fantasypros.yml?label=rankings&style=flat-square)]() |  |
| contracts | [![contracts](https://img.shields.io/github/actions/workflow/status/nflverse/rotc/update_otc.yaml?label=contracts&style=flat-square)]() | [![contracts](https://img.shields.io/badge/dynamic/json?color=blue&label=load_contracts&query=last_updated&style=flat-square&url=https://github.com/nflverse/nflverse-data/releases/download/contracts/timestamp.json)](https://github.com/nflverse/nflverse-data/releases/tag/contracts) |
