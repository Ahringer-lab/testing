#!/bin/bash
#
#SBATCH --job-name=star_kallisto
#SBATCH --output=slurm_out/star_kallisto.%N.%j.out
#SBATCH --error=slurm_err/star_kallisto.%N.%j.err
#SBATCH --ntasks=1
#SBATCH -N 1
#SBATCH -n 6
#SBATCH --mem-per-cpu=4000
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=aft36@cam.ac.uk

#this code makes STAR aligned bigwig tracks and gives a "final.out" file that tells you the #reads and #uniquely mapped reads
#NB I use kallisto for the DESeq analysis (aligns to transcriptome, whilst STAR aligns to genome)

outdir=/mnt/home3/ahringer/sw2154/out/
genome_chr=/mnt/home3/ahringer/sw2154/references/built_genomes/star/c.elegans.latest
fastq_dir=/mnt/home3/ahringer/sw2154/data/
star_index=/mnt/home3/ahringer/sw2154/references/built_genomes/star/c.elegans.latest
THREADS=1

options=$(getopt -o '' -l threads: -l path: -l id: -l holdinput -l -- "$@") || exit_with_bad_args

eval set -- "$options"
while true; do
    case "$1" in
        --threads)
            shift
            THREADS="$1"
            ;;
        --path)
            shift
            fastq_dir="$1"
            ;;
        --id)
            shift
            RUNID="$1"
            ;;
        --holdinput)
           HOLDINPUT="true"
           echo "Holding input fastq files in inputs folder"
           ;;
         --)
            shift
            break
            ;;
    esac
    shift
done

analysis_out_dir=${outdir}/${RUNID}

declare -A FILES

for f in $fastq_dir/*fastq.gz; do                  # search the files with the suffix
    base=${f%_L001_*}                        # remove after "_L001_" To make sample ID the hash key
    if [[ $f == $base* ]] && [[ $f == *"R1"* ]]; then    # if the variable is the current sample ID and is forward
        FILES[$base]=$f                  # then store the filename
    elif [[ $f == $base* ]] && [[ $f == *"R2"* ]]; then # if the variable is the current sample and is reverse
        FILES[$base]+=" $f"
    fi
done

for base in "${!FILES[@]}"; do 
echo "${base}_L001_R1_001.fastq.gz"
echo "${base}_L001_R2_001.fastq.gz"
 
 mkdir ${analysis_out_dir}/${RUNID}/${base}/fastq

 cd ${analysis_out_dir}/${RUNID}/${base}/fastq

fastq ${base}_L001_R1_001.fastq.gz ${base}_L001_R2_001.fastq.gz

done



# ~/wigToBigWig_tool/wigToBigWig $outdir_star/$sample.Signal.UniqueMultiple.str1.out.wig $genome_chr $outdir_star/$sample.Signal.UniqueMultiple.str1.out.bw
# ~/wigToBigWig_tool/wigToBigWig $outdir_star/$sample.Signal.UniqueMultiple.str2.out.wig $genome_chr $outdir_star/$sample.Signal.UniqueMultiple.str2.out.bw
# ~/wigToBigWig_tool/wigToBigWig $outdir_star/$sample.Signal.Unique.str1.out.wig $genome_chr $outdir_star/$sample.Signal.Unique.str1.out.bw
# ~/wigToBigWig_tool/wigToBigWig $outdir_star/$sample.Signal.Unique.str2.out.wig $genome_chr $outdir_star/$sample.Signal.Unique.str2.out.bw

#echo "$sample complete"
#done
