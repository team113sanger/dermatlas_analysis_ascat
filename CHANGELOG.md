# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.7.0] - 2025-06-29
# Fixed
- Fixed paths created in 0.6.0 for ref files

## [0.6.0] 
# Changed - 2025-06-29
- Replaced paths of bedfile and ref file to `resources` directory
- Eventually merge functionalities with `run_ascat_exome_nr.R` (see tag 0.5.0)

## [Unreleased]
## [0.5.0] Jan 2025
# Changed
- Dockerised analysis + added dev tools
- Added helpers for running in nextflow as part of `dermatlas_copy_number_nf` wrapper. 
- `run_ascat_exome_nf.R` removes the hard-coded bedfile + ref file from run `run_ascat_exome.R` and assumed location of GC and REF files all sitting within one project dir. To merge functionalities of these scripts eventually.
- `summarise_ascat_estimate.R` temporarily covers same functionality as `summarise_ascat_estimates.pl` to simplify down to a single language for early nextflow. Can either merge or discard

## [0.4.0] Publishable Unit 4
# Changed
- Change scripts to rely on environment files `source_me_*.sh` for setting up
  environment variables.
- Refact hard-coded R paths in scripts.

# Removed
- Removed `overlap_maf_ascat_cn.R` as it is encapsulated in other scripts.

## [0.3.0] Publishable Unit 3

### Removed
- Redundant `submit_ascat_jobs.PU1.sh` -- if needed checkout to earlier tag

## [0.2.0] Publishable Unit 2
### Added
- Add new `submit_ascat_jobs.sh`

### Changed
- Renamed `submit_ascat_jobs.sh` to `submit_ascat_jobs.PU1.sh`
- Other minor changes

## [0.1.0] Publishable Unit 1
### Added
- Add `CHANGELOG.md` and `README.md`
- Add initial R script `calc_cn_proportion.R`, `overlap_maf_ascat_cn.R`,
  `plot_ascat_cna_and_loh.R` and `run_ascat_exome.R`
- Add initial shell script `submit_ascat_jobs.PU1.sh` and `make_ascat_release.sh`
- Add initial Perl script `summarise_ascat_estimates.pl`
