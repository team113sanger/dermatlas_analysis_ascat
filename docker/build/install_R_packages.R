CRAN_URL <- "https://cloud.r-project.org"
BIOCONDUCTOR_URL <- "https://bioconductor.org/packages/3.16/bioc"

# GitHub Installs
devtools::install_github('VanLoo-lab/ascat/ASCAT', ref="v3.1.2")

# CRAN Installs
devtools::install_version("dplyr", version="1.1.2", repos=CRAN_URL, upgrade="never")
devtools::install_version("optparse", version="1.7.4", repos=CRAN_URL, upgrade="never")
devtools::install_version("valr", version="0.7.0", repos=CRAN_URL, upgrade="never")
devtools::install_version("ggplot2", version="3.4.2", repos=CRAN_URL, upgrade="never")
devtools::install_version("tidyverse", version = "2.0.0", repos=CRAN_URL, upgrade="never")
devtools::install_version("stringr", version = "1.5.0", repos=CRAN_URL, upgrade="never")

# Bioconductor Installs
devtools::install_version("IRanges", version = "2.32.0", repos=BIOCONDUCTOR_URL, upgrade="never")
devtools::install_version("GenomicRanges", version = "1.50.2", repos=BIOCONDUCTOR_URL, upgrade="never")
