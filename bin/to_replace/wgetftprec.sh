#!/bin/bash

# see wgetrec.sh 
# only different arg is "--no-remove-listing --timestamping" instead of "--noclobber"
wget -r -l5  --no-remove-listing --timestamping --no-parent                   	\
    --no-verbose --background -a wget-`date +%Y%m%d`.log 	\
    -erobots=off --wait=0.5 --random-wait --limit-rate=100	\
    $@