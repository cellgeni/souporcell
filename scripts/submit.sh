#!/bin/bash

set -euo pipefail

#run this from work directory

script=../actions/spoon.sh #selecting souporcell script to run
sf=../actions/samples.txt #selecting sample file

CPU=8 #selecting cpus
MEM=35000 #selecting memory 
GROUP="cellgeni" #selecting group to submit with
QUE="long" #selecting queue to submit to

k=3 #selecting number of donors

###################### DONT CHANGE OPTIONS BELOW THIS LINE ###########################

if true; then
  mkdir -p logs
  cat $sf | while read name; do  
    bsub -n $CPU -Rspan[hosts=1] -M $MEM -R"select[mem>${MEM}] rusage[mem=${MEM}]" -G $GROUP -q $QUE -o logs/ooo.$name.%J.txt -e logs/eee.$name.%J.txt $script $CPU $name $k  
  done
fi
