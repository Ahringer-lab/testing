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
options=$(getopt -o '' -l dir: -l lanes: -l output:-- "$@") || exit_with_bad_args

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
OUTDIR=${OUTDIR}/${RUNID}

for base in "${!FILES[@]}"; do 
    echo "${base}_L001_R1_001.fastq.gz"
    echo "${base}_L001_R2_001.fastq.gz"

    mkdir ${analysis_out_dir}/${base} 
    mkdir ${analysis_out_dir}/${base}/fastq


done