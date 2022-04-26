#!/bin/bash

set -euo pipefail

#run this from work directory

script=../actions/spoon.sh #selecting souporcell script to run
mem=35000  #selecting memory 
cpu=8 #selecting cpus
sf=../actions/samples.txt #selecting sample file
k=3 #selecting number of donors

###################### DONT CHANGE OPTIONS BELOW THIS LINE ###########################

if true; then
  mkdir -p logs
  cat $sf | head -n 1 | while read name; do  
    bsub -n $cpu -Rspan[hosts=1] -e logs/eee.$name.%J.txt -o logs/ooo.$name.%J.txt -q long -M $mem -a "memlimit=True" $script $cpu $name $k  
  done
fi
