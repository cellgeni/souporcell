#!/bin/bash

set -euo pipefail

im=/nfs/cellgeni/singularity/images/souporcell.sif #souporcell singularity image
mnt=/lustre #which filesystems to mount

s1=${1?Need sample1} #sample1 (inputted from twosubmit.sh)
s2=${2?Need sample2} #sample2 (inputted from twosubmit.sh)
nshared=${3?Need nshared} #donor number (inputted from twosubmit.sh)

dir1=../data/$s1/soc #souporcell output directory for sample 1
dir2=../data/$s2/soc #souporcell output directory for sample 2

###################### DONT CHANGE OPTIONS BELOW THIS LINE ###########################

[[ ! -d $dir1 ]] && echo "Not a directory $dir1" && false
[[ ! -d $dir2 ]] && echo "Not a directory $dir2" && false

singularity exec -B $mnt $im shared_samples.py -1 $dir1 -2 $dir2 -n $nshared > out$nshared.$s1-$s2 2> err$nshared.$s1-$s2

