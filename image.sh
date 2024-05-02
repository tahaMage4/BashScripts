#!/bin/bash

while IFS="," read -r rec_column1 rec_column2
do
 ( mkdir -p "$rec_column1" && cd "$rec_column1" && wget $rec_column2 )
done < <(tail -n +2 image1.csv)