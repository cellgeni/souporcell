#!/bin/bash

set -euo pipefail

#run this from data directory

sf=../actions/irods.txt
barcode_path=filtered_feature_bc_matrix/barcodes.tsv.gz
bam_file=gex_possorted_bam.bam
index_file=gex_possorted_bam.bam.bai

###################### DONT CHANGE OPTIONS BELOW THIS LINE ###########################

cat $sf | while read name path; do
  mkdir -p $name
  ( cd $name
    echo "-- $path"
    iget -f -v -N 4 -K $path/$barcode_path
    echo "✓"
    iget -f -v -N 4 -K $path/$bam_file
    iget -f -v -N 4 -K $path/$index_file
  )
done
