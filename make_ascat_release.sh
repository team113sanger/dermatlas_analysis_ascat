#!/bin/bash

# This script is run after completing ASCAT, plotting and summary steps.
# TSV files are coverted to *.xlsx, a README file is created and files
# rsync'ed to the target directory.

PROJECTDIR=$1
input_dir=$2
target_dir=$3

# Check arguments, scripts and directories

if [[ -z $PROJECTDIR || -z $input_dir || -z $target_dir ]]; then
	echo -e "\nThis script copies relevant ASCAT files (for release) to a target directory (e.g. your local git repository)\n"
	echo -e "Usage: $0 project_directory input_directory target_directory\n"
	echo -e "Example: $0 /my/project/path/ /my/project/path/analysis/ASCAT/release_v1 /my/git/path/project/copy_number/ascat/release_v1\n"
	exit 1
fi

if [[ ! -e $PROJECTDIR/scripts/MAF/tsv2xlsx.R ]]; then
	echo "Cannot find required script $PROJECTDIR/scripts/MAF/tsv2xlsx.R"
	exit 1
fi


if [[ ! -d $PROJECTDIR || ! -w $PROJECTDIR ]]; then
	echo "No project directory $PROJECTDIR or not writeable"
	exit 1
elif [[ ! -d $input_dir || ! -w $input_dir ]]; then
	echo "No input directory $input_dir or not writeable"
	exit 1
elif [[ ! -d $target_dir || ! -w $target_dir ]]; then
	echo "No target directory $target_dir or not writeable"
	exit 1
fi

cd $input_dir
echo "PWD is $PWD"

# R version

if which Rscript &> /dev/null; then
	echo "Using Rscript:"
	which Rscript
	Rscript --version
	echo "Using R_LIBS"
	echo $R_LIBS
else
	echo "Not found: Rscript."
	exit 1;
fi


# Make lists of samples used

for f in `find | grep PLOTS_ | grep -v PLOTS_ALL | grep -v cn-loh | grep segments.tsv`; do
	outdir=`dirname $f`
	cut -f 1 $f | grep -v Sample | sort -u > $outdir/samples.list
done


## Convert files with gene names into xlsx


for file in `find $input_dir |grep tsv`; do 
	echo $file
	Rscript ${PROJECTDIR}/scripts/MAF/tsv2xlsx.R $file
done


# Make a README file

cat > README_ASCAT_FILES.txt << END

These directories contain a summary of the results from ASCAT.

# Subdirectories:

PLOTS_INDEPENDENT_TUMOURS - penetrance plots include multiple, independent tumours from all patients (IF APPLICABALE)
PLOTS_ONE_PER_PATIENT - penetrance plots include one tumour per patient


# Files in each subdirectory:

README_ASCAT_FILES.txt - this file

# From all samples used to run ASCAT:
ascat_excluded_unmatched.tsv - unmatched samples that were excluded
ascat_low_qual.list - list of samples excluded due to goodness-of-fit < 90

# For one tumour per patient and independent tumours
# TSV files are also converted to xlsx files for
# convenience

ascat_stats.tsv - ploidy, purity, XX/XY estimates from ASCAT
sample_purity_ploidy.tsv - ASCAT sample estimated purity and ploidy
ascat_estimate_files.list - files used to get the ASCAT estimates
samples2sex.tsv - patient sex from the metadata

# Directories with plots and segment files:

PLOTS_ONE_PER_PATIENT/
PLOTS_INDEPENDENT/ (if applicable)

*CNfreq.pdf - penetrane plot of CN gain/loss
*CNfreq.tsv - counts of CN gain/loss in 1Mb windows (used to draw the plots)
*cn-loh.pdf - frequency plot of copy-neutral loss of heterozygosity
*cn-loh.tsv - counts of cn-LOH ini 1Mb windows (used to draw the plots)

samples.list - list of samples included in plots
*_segments.tsv - segments from all samples included in the plots
*_cn-loh_segments.tsv - segments with cn-LOH
*_segfiles.list - files used to draw the CN plots



END

# Copy files to git repository

rsync -av $input_dir $target_dir
