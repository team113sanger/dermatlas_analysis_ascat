# CONSTANT FOR PACKAGES
REQUIRED_PACKAGES <- c(
  "VanLoo-lab/ascat/ASCAT@v3.1.2", # Install specific version of ASCAT from GitHub
  "dplyr@1.1.2",           # Install specific version of dplyr from CRAN
  "optparse@1.7.4",        # Install specific version of optparse from CRAN
  "ggplot2@3.4.2",         # Install specific version of ggplot2 from CRAN
#   "tidyverse@2.0.0",       # Install specific version of tidyverse from CRAN
  "stringr@1.5.0",         # Install specific version of stringr from CRAN
  "bioc::IRanges@2.32.0",  # Install specific version of IRanges from Bioconductor
  "bioc::GenomicRanges@1.50.2", # Install specific version of GenomicRanges from Bioconductor
  "bioc::rtracklayer@1.58.0",      # Needed for valr
  "valr@0.7.0"             # Install specific version of valr from CRAN
)
BIOCONDUCTOR_VERSION <- "3.16"

# UPDATE THE RENV SETTINGS
if (requireNamespace("renv", quietly = TRUE)) {
    renv::settings$bioconductor.version(BIOCONDUCTOR_VERSION)
    renv::settings$snapshot.type("all")
} else {
  message("renv is not installed. Please install renv and try again.")
  quit(status = 1)
}
