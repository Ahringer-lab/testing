#!/bin/bash

#######################################################################################################
############################## Sequencing lane merger #################################################
# This script will merge fastq files from multiple lanes
# Inputs:
#           --dir   The directory where the fastq files are located, default is ~/data
#           --lanes The number of lanes to merge across, default is 2
#           --output Change the output directory, default is ~/output
# This script is run locally, it is not set up to run on the cluster
# Author Steve Walsh May 20224
#######################################################################################################

#Set tht defaults

DIR=~/data
LANES=2
RUNID="PipelineRun-$(date '+%Y-%m-%d-%R')"
OUTDIR=~/output

#Set the possible input options
options=$(getopt -o '' -l dir: -l lanes: -l output: -- "$@") || exit_with_bad_args

#Get the inputs
eval set -- "$options"
while true; do
    case "$1" in
        --dir)
            shift
            DIR="$1"
            ;;
        --lanes)
            shift
            LANES="$1"
            ;;
        --output)
            shift
            OUTDIR="$1"
            ;;
         --)
            shift
            break
            ;;
    esac
    shift
done

cd $DIR
#OUTDIR=${OUTDIR}/${RUNID}

# Make array to store fastq name
declare -A FILES

#Get all fastq names from input folder
for f in *fastq.gz; do                  # search the files with the suffix
    base=${f%_L00*_*}                        # remove after "_L00*_" To make sample ID the hash key (Lane number is wildard here)
    if [[ $f == $base* ]] && [[ $f == *"R1"* ]]; then    # if the variable is the current sample ID and is forward
        FILES[$base]=$f                  # then store the filename
    elif [[ $f == $base* ]] && [[ $f == *"R2"* ]]; then # if the variable is the current sample and is reverse
        FILES[$base]+=" $f"
    fi
done

for base in "${!FILES[@]}"; do
    echo "${base}"
    cat ${base}_L001_R1_001.fastq.gz ${base}_L002_R1_001.fastq.gz > ${base}_R1_merged.fastq.gz
    cat ${base}_L001_R2_001.fastq.gz ${base}_L002_R2_001.fastq.gz > ${base}_R2_merged.fastq.gz
done