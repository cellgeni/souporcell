#!/bin/bash

set -euo pipefail

fa=  #add to approriate genome i.e. /nfs/cellgeni/STAR/human/2020A/GRCh38_v32_modified.fa
im=/nfs/cellgeni/singularity/images/souporcell.sif #souporcell singularity image 
vcf= #add to appropriate vcf i.e. /nfs/cellgeni/pipeline-files/souporcell/reference_vcfs/chr_filtered_2p_1kgenomes_GRCh38.vcf

# by default the pipeline will use common variant loci or known variant loci vcf
known_genotypes='false' # to use known genotypes per clone in population vcf mode to 'true'

cpu=${1?Need CPU count} #cpu number inputted from submit.sh
dir=${2?Need directory} #sample ID that is also directory
thek=${3?Need k} #donor number inputted from submit.sh

cd ../data/$dir #change to sample directory

psb=possorted_bam.bam #bam filename
bcd=barcodes.tsv #barcodes filename
outdir=soc #souporcell output dir name
remap=True
umi=True

###################### DONT CHANGE OPTIONS BELOW THIS LINE ###########################

[[ ! -e "$psb" ]] && echo "No $psb in $dir" && false
[[ ! -e "$bcd" ]] && echo "No $bcd in $dir" && false

common_or_known="--common_variants"
if [[ "$known_genotypes" = true ]]; then
    common_or_known="--known_genotypes"
fi
common_or_known="$common_or_known $vcf"

echo $dir ok
mkdir $outdir

/software/singularity-v3.6.4/bin/singularity exec -B /lustre -B /nfs \
      $im souporcell_pipeline.py \
      -i $psb                 \
      -b $bcd                 \
      -f $fa                  \
      -k $thek                \
      $common_or_known        \
      -t $cpu -o $outdir      \
      --skip_remap $remap     \
      --no_umi $umi

