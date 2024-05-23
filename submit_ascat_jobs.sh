#!/bin/bash

# This script will create bsub commands for a DERMATLAS
# cohort and submit the jobs to the farm

PROJECTDIR=$1
OUTDIR=$2

SCRIPTDIR=$PROJECTDIR/scripts
MEM=35000

# Check positional arguments

if [[ -z $PROJECTDIR || -z $OUTDIR ]]; then
	echo -e "\nThis script parses the study metadata file to determine sample pairs,\nsex and submit ASCAT jobs to the farm\n\n"
	echo -e "\tUsage: $0 /path/to/project/dir /path/to/output/dir\n"
	exit
fi


# Check if directories and Rscript exist

for dir in $PROJECTDIR $OUTDIR $SCRIPTDIR $PROJECTDIR/bams; do
	if [[ ! -d $dir ]]; then
		echo "No such directory: $dir"
		exit;
	fi
done

if [[ ! -e $SCRIPTDIR/ASCAT/run_ascat_exome.R ]]; then
	echo "Can't find $SCRIPTDIR/ASCAT/run_ascat_exome.R"
	exit
fi

# R version
#
if which Rscript &> /dev/null; then
	echo "Using Rscript:"
	which Rscript
	Rscript --version
#	echo "Using R_LIBS"
#	echo $R_LIBS
#	echo "Using R_LIBS_USER"
#	echo $R_LIBS_USER
else
    echo "Not found: Rscript"
    exit 1;
fi

# Get a list of samples that passed QC

sample_list=(`dir $PROJECTDIR/metadata/*-analysed_matched.tsv`)

if [[ ${#sample_list[@]} > 1 ]]; then
	echo "Found more than one list of submitted samples $samplelist"
	exit
elif [[ ${#sample_list[@]} == 0 ]]; then
	echo "File not found: $PROJECTDIR/metadata/*-analysed_matched.tsv"
	exit
else
	sample_list=${sample_list[0]}
	echo "sample_list file: $sample_list"
fi

# Check metadata file

metadata_file=(`dir $PROJECTDIR/metadata/*_METADATA_*.t*`)

if [[ ${#metadata_file[@]} > 1 ]]; then
	echo "Found more than one metadata file $metadata_file"
	exit
elif [[ ${#metadata_file[@]} == 0 ]]; then
	echo "File not found: $PROJECTDIR/metadata/*_METADATA_*.t*"
	exit
else
	metadata_file=${metadata_file[0]}
	echo "metadata_file file: $metadata_file"
fi


# Get a list of sample and sex

info=$PROJECTDIR/metadata/allsamples2sex.tsv

if [[ ! -e $info ]]; then
	echo -e "Required file missing: $info. Creating file from $metadata_file.\n"

	pheno_col=`awk -v RS='\t' '/Phenotype/{print NR; exit}' $metadata_file`
	sex_col=`awk -v RS='\t' '/Sex/{print NR; exit}' $metadata_file`
	id_col=`awk -v RS='\t' '/DNA_ID/{print NR; exit}' $metadata_file`
	ok_col=`awk -v RS='\t' '/analyse_DNA/{print NR; exit}' $metadata_file`

	if [[ -z $id_col ]]; then
		id_col=`awk -v RS='\t' '/DNA ID/{print NR; exit}' $metadata_file`
	fi
	if [[ -z $pheno_col ]]; then
		echo "Cannot find 'Phenotype' column in metadata file $metadata_file"
	elif [[ -z $sex_col ]]; then
		echo "Cannot find 'Sex' column in metadata file $metadata_file"
	elif [[ -z $id_col ]]; then
		echo "Cannot find DNA ID or DNA_ID column in metadata file $metadata_file"
	elif [[ -z $ok_col ]]; then
		echo "Cannot find 'OK_to_analyse_DNA?' column in metadata file $metadata_file"
	fi

	awk -v col1=$pheno_col -v col2=$sex_col -v col3=$id_col -v col4=$ok_col 'BEGIN{OFS=FS="\t"} {print $col1,$col2,$col3,$col4}' $metadata_file > $info
	awk '$2=="F"' $info | cut -f 3 | xargs -i grep {} $sample_list | sort -u > $OUTDIR/ascat_pairs_female.tsv 
	awk '$2=="M"' $info | cut -f 3 | xargs -i grep {} $sample_list | sort -u > $OUTDIR/ascat_pairs_male.tsv
fi

if [[ -e $info ]]; then
	awk '$2=="F"' $info | cut -f 3 | xargs -i grep {} $sample_list | sort -u | grep -v PDv38is_wes_v2 > $OUTDIR/ascat_pairs_female.tsv
	awk '$2=="M"' $info | cut -f 3 | xargs -i grep {} $sample_list | sort -u | grep -v PDv38is_wes_v2 > $OUTDIR/ascat_pairs_male.tsv
	cat  $info | cut -f 3 | xargs -i grep {} $sample_list | sort -u | grep PDv38is_wes_v2 > $OUTDIR/ascat_excluded_unmatched.tsv
else
	echo "Problem: cannot locate or create: $info"
	exit
fi

# Submit ASCAT jobs from output directory

cd $OUTDIR

for sex in male female; do 
	for tum in `cut -f 1 ascat_pairs_${sex}.tsv`; do
		norm=`grep $tum ascat_pairs_${sex}.tsv | cut -f 2`
		if [[ -z "$norm" ]]; then
			echo "Can't find normal for $tum"
			exit
		fi
		mkdir -p $tum-$norm/logs
		cd $tum-$norm
		
		# Check that BAMs exist
		tumbam=$PROJECTDIR/bams/$tum/$tum.sample.dupmarked.bam
		normbam=$PROJECTDIR/bams/$norm/$norm.sample.dupmarked.bam
		if [[ ! -e $tumbam || ! -e $normbam ]]; then
			echo "Missing one or more BAMs: $tumbam $normbam"
			exit
		fi
	
		if [[ $sex == "male" ]]; then
			sexchr="XY"
			echo "$sex XY"
		else
			sexchr="XX"
			echo "$sex XX"
		fi

		cmd="Rscript $SCRIPTDIR/ASCAT/run_ascat_exome.R --tum_bam $tumbam --norm_bam $normbam --tum_name $tum --norm_name $norm --sex $sexchr --outdir $OUTDIR/$tum-$norm --project_dir $PROJECTDIR"

		echo $cmd

		bsub -e logs/$tum-$norm.e -o logs/$tum-$norm.o -q normal -M $MEM -R "select[mem>$MEM] rusage[mem=$MEM]" "$cmd"
		cd $OUTDIR
	done
done

