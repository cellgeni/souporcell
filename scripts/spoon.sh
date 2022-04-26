#!/bin/bash

set -euo pipefail

fa=/nfs/cellgeni/STAR/human/2020A_plus_Pf_3D7/combo.fa  #change to approriate genome
im=/nfs/cellgeni/singularity/images/souporcell.sif #souporcell singularity image 
cv=/lustre/scratch117/cellgen/cellgeni/simon/altered_vcfs/chr_filtered_2p_1kgenomes_GRCh38.vcf #change to appropriate vcf

CPU=${1?Need CPU count} #cpu number inputted from submit.sh
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

echo $dir ok
mkdir $outdir

singularity exec -B /lustre -B /nfs \
      $im souporcell_pipeline.py \
      -i $psb                 \
      -b $bcd                 \
      -f $fa                  \
      -k $thek                \
      --common_variants $cv   \
      -t $CPU -o $outdir      \
      --skip_remap $remap     \
      --no_umi $umi
