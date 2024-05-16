#!/usr/bin/env Rscript

library(argparser, quietly=TRUE)

description = cat(
    "Execute ASCAT\n",
    "Requires ~32G memory\n\n"
)

# create parser
p <- arg_parser(description)

# Add required params
p <- add_argument(p, "tum_bam", help="Tumour aligned reads")
p <- add_argument(p, "norm_bam", help="Normal aligned reads")
p <- add_argument(p, "tum_name", help="Tumour sample name")
p <- add_argument(p, "norm_name", help="Normal sample name")
p <- add_argument(p, "sex", help="Sex in form XX or XY")

p <- add_argument(p, "ref", help="Path to reference sequence")
p <- add_argument(p, "--alleles", help="ASCAT allele stub path", default="alleles/1kg.phase3.v5a_GRCh38nounref_allele_index_chr")
p <- add_argument(p, "--loci", help="ASCAT allele stub path", default="loci/1kg.phase3.v5a_GRCh38nounref_loci_chr")
p <- add_argument(p, "gc", help="GC correction file")
p <- add_argument(p, "rt", help="RT correction file")

p <- add_argument(p, "--bed", help="Exome baits", default=NA)
p <- add_argument(p, "--testing", help="Fix seed for testing purposes", flag=TRUE)

# Parse the command line arguments
argv <- parse_args(p)

tum_bam <- argv$tum_bam
norm_bam <- argv$norm_bam
tum_name <- argv$tum_name
norm_name <- argv$norm_name
sex <- argv$sex

ref_file <- argv$ref

# Exome regions
bed_file <-argv$bed # "exome.nochr.noY.bed"

alleles <- argv$alleles
loci <- argv$loci

# # GC and RT correction files; parsed from Battenberg genome files
gc_file <- argv$gc # "1000G_GC_exome_chr.txt"
rt_file <- argv$rt # "1000G_RT_exome_chr.txt"

suppressPackageStartupMessages(library(ASCAT))

allelecounter_exe = "alleleCounter"

##### Run ASCAT #####

# Get logR and BAF from sequencing data

seedPrepHts = 1677037616
if (! argv$testing) {
    seedPrepHts = as.integer(Sys.time())
}

ascat.prepareHTS(
       tumourseqfile = tum_bam,
       normalseqfile = norm_bam,
       tumourname = tum_name,
       normalname = norm_name,
       allelecounter_exe = allelecounter_exe,
       alleles.prefix = alleles,
       loci.prefix = loci,
	   gender = sex,
       genomeVersion = "hg38",
       nthreads = 8,
       tumourLogR_file = NA,
       tumourBAF_file = NA,
       normalLogR_file = NA,
       normalBAF_file = NA,
       minCounts = 10,
       BED_file = bed_file,
       probloci_file = NA,
       chrom_names = c(1:22, "X"),
       min_base_qual = 20,
       min_map_qual = 35,
       ref.fasta = ref_file,
       skip_allele_counting_tumour = F,
       skip_allele_counting_normal = F,
       seed = seedPrepHts
)


# Load the data

ascat.bc = ascat.loadData(Tumor_LogR_file = paste0(tum_name, "_tumourLogR.txt"),
			Tumor_BAF_file = paste0(tum_name, "_tumourBAF.txt"),
			Germline_LogR_file = paste0(tum_name, "_normalLogR.txt"),
			Germline_BAF_file = paste0(tum_name, "_normalBAF.txt"),
			gender = sex , genomeVersion = "hg38")


# Plot logR before and after GC and RT correction

ascat.plotRawData(ascat.bc, img.prefix = "Before_correction_")

ascat.bc = ascat.correctLogR(ascat.bc, GCcontentfile = gc_file, replictimingfile = rt_file)

ascat.plotRawData(ascat.bc, img.prefix = "After_correction_")


# Generate the ASPCF and segment plots

seedAspcf = 174628459
if (! argv$testing) {
    seedAspcf = as.integer(Sys.time())
}

ascat.bc = ascat.aspcf(ascat.bc, penalty = 70, seed = seedAspcf)

ascat.plotSegmentedData(ascat.bc)


# Run ASCAT and write out segmentation file; gamma = 1 for exomes

ascat.output = ascat.runAscat(ascat.bc, gamma = 1, write_segments = T)


# Get QC metrics

QC = ascat.metrics(ascat.bc, ascat.output)


# Save session

save(ascat.bc, ascat.output, QC, file = 'ASCAT_objects.Rdata')
