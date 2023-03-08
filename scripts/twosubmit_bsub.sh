#!/bin/bash

set -eou pipefail

#run this from shared_samples directory

script=../actions/souporcell/scripts/twospoon2_atac.sh #script that runs shared_samples.py from souporcell
sf=../actions/twosamples.txt #file containing samples

CPU=2 #selecting cpus
MEM=15000 #selecting memory 
GROUP="cellgeni" #selecting group to submit with
QUE="normal" #selecting queue to submit to


###################### DONT CHANGE OPTIONS BELOW THIS LINE ###########################

cat $sf | while read s1 s2 n; do
    name1=`ls -1 ../data/ | grep $s1`
    name2=`ls -1 ../data/ | grep $s2`
    bsub -n $CPU -Rspan[hosts=1] -M $MEM -R"select[mem>${MEM}] rusage[mem=${MEM}]" -G $GROUP -q $QUE -o ooo.twospoon.$name1-$name2.%J.txt -e eee.twospoon.$name1-$name2.%J.txt $script $name1 $name2 $n
  done
