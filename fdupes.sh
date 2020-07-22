#!/bin/sh 
dirname=$1
fdupes -r $dirname --sameline > unfilteredDuplicates.txt