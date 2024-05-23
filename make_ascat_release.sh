#!/bin/bash

PROJECTDIR=$1
input_dir=$2
target_dir=$3

# Check scripts directory for maf2xlsx.R script

if [[ -z $PROJECTDIR || -z $input_dir || -z $target_dir ]]; then
	echo -e "\nThis script copies relevant ASCAT files (for release) to a target directory (e.g. your local git repository)\n"
    echo -e "Usage: $0 project_directory input_directory target_directory\n"
	echo -e "Example: $0 /my/project/path/ /my/project/path/analysis/ASCAT/release_v1 /my/git/path/project/copy_number/ascat/release_v1\n"
    exit 1
fi

#elif [[ ! -e $PROJECTDIR/scripts/MAF/maf2xlsx.R ]]; then
#    echo "Cannot find required script $PROJECTDIR/scripts/MAF/maf2xlsx.R"
#    exit 1
#fi

# Farm22

RSCRIPT=/software/team113/dermatlas/R/R-4.2.2/bin/Rscript
export R_LIBS=/software/team113/dermatlas/R/R-4.2.2/lib/R/library/

if [[ ! -d $PROJECTDIR || ! -w $PROJECTDIR ]]; then
	echo "No project directory $PROJECTDIR or not writeable"
	exit 1
elif [[ ! -d $input_dir || ! -w $input_dir ]]; then
	echo "No input directory $input_dir or not writeable"
	exit 1
elif [ ! -d $target_dir ] || [ ! -w $target_dir ]; then
	echo "No target directory $target_dir or not writeable"
	exit 1
fi

cd $input_dir
echo "PWD is $PWD"


# Make lists of samples used

for f in `find | grep PLOTS_ | grep -v PLOTS_ALL | grep -v cn-loh | grep segments.tsv`; do
	outdir=`dirname $f`
	cut -f 1 $f | grep -v Sample | sort -u > $outdir/samples.list
done


## Convert files with gene names into xlsx


for file in `find $input_dir |grep tsv`; do 
	echo $file
	$RSCRIPT ${PROJECTDIR}/scripts/tsv2xlsx.R $file
done


# Make a README file

cat > README_ASCAT_FILES.txt << END

These directories contain a summary of the results from ASCAT.

# Subdirectories:

PLOTS_INDEPENDENT_TUMOURS - penetrance plots include multiple, independent tumours from all patients (IF APPLICABALE)
PLOTS_ONE_PER_PATIENT - penetrance plots include one tumour per patient


# Files in each subdirectory:
*_segments.tsv - segments from all samples included in the plots
*_cn-loh_segments.tsv - segments with cn-LOH
*CNfreq.pdf - penetrane plot of CN gain/loss
*CNfreq.tsv - counts of CN gain/loss in 1Mb windows (used to draw the plots)
*cn-loh.pdf - frequency plot of copy-neutral loss of heterozygosity
*cn-loh.tsv - counts of cn-LOH ini 1Mb windows (used to draw the plots)
samples.list - list of samples included in plots
ascat_low_qual.list - list of samples excluded due to goodness-of-fit < 90
ascat_stats.tsv - ploidy, purity, XX/XY estimates from ASCAT


END

# Copy files to git repository

rsync  -av --exclude *ascat_estimate_files.list* --exclude *_segfiles.list* --exclude *sample_purity_ploidy.tsv* --exclude *samples2sex* README.txt PLOTS_INDEPENDENT PLOTS_ONE_PER_PATIENT $target_dir
