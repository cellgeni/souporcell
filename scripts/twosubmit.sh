#!/bin/bash

set -eou pipefail

#run this from shared_samples directory

script=../actions/twospoon.sh #script that runs shared_samples.py from souporcell
sf=../actions/samples.txt #file containing samples
n=3 #donor number

###################### DONT CHANGE OPTIONS BELOW THIS LINE ###########################

cat $sf | while read s1; do
  cat $sf | while read s2; do
    $script $s1 $s2 $n
    done
  done
