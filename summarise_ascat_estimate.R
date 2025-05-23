#!/usr/bin/env Rscript
library(dplyr)
library(purrr)
library(tidyr)
library(optparse)

option_list <- list(
  make_option(c("--estimates_path"), 
                action = "store_true", 
                default = NA, 
                type = "character", 
                help = "Path to a set of ASCAT_estimates files."))

arguments <- parse_args(OptionParser(option_list = option_list), positional_arguments = 0)

args <- arguments$options

estimates <- args$estimates_path

estimate_files <- list.files(
  path = estimates,
  full.names = TRUE,
  recursive = TRUE,
  pattern = "ASCAT.*.tsv"
)

names(estimate_files) <- basename(estimate_files)

read_stats_file <- function(file) {
  read.delim(file,
    sep = "\t", header = FALSE,
    col.names = c("key", "value")
  )
}

stats_table <- map_dfr(estimate_files, read_stats_file, .id = "File") |>
  tidyr::pivot_wider(names_from = key, values_from = value) |>
  dplyr::mutate(Sample_ID = gsub(pattern = ".*ASCAT_estimates_",  File, replacement = "")) |>
  dplyr::mutate(Sample_ID = gsub(pattern = "_PD.*.tsv", Sample_ID, replacement = "")) |>
  dplyr::mutate(File = paste0(File))
  
stats_table |>
  write.table("ascat_stats.tsv",
    sep = "\t", quote = FALSE, row.names = FALSE
  )

stats_table |>
  dplyr::select(Sample_ID, Purity, Ploidy) |> 
  write.table("sample_purity_ploidy.tsv",
    sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE
  )

stats_table |>
  dplyr::select(Sample_ID, Sex) |> 
  write.table("samples2sex.tsv",
    sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE
  )
  
stats_table |>
  dplyr::filter(`Goodness-of-fit` < 90) |>
  dplyr::select(Sample_ID) |> 
  write.table("ascat_low_qual.list",
    sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE
  )
