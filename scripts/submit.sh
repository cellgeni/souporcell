#!/bin/bash

set -euo pipefail

#run this from work directory

script=../actions/spoon.sh #selecting souporcell script to run
sf=../actions/samples.txt #selecting sample file

cpu=8 #selecting cpus
mem=35000 #selecting memory 
group="cellgeni" #selecting group to submit with
que="long" #selecting queue to submit to

k=3 #selecting number of donors

###################### DONT CHANGE OPTIONS BELOW THIS LINE ###########################

if true; then
  mkdir -p logs
  cat $sf | while read name; do  
    bsub -n $cpu -Rspan[hosts=1] -M $mem -a "memlimit=True" -G $group -q $que -o logs/ooo.$name.%J.txt -e logs/eee.$name.%J.txt $script $cpu $name $k  
  done
fi
