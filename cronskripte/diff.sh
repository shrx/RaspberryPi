#!/bin/bash

#file="/home/pi/stran/data/napoved-p.csv"
file=$1

#out="/home/pi/stran/data/delta-p.csv"
out=$2

datum=$(date '+%Y/%m/%d %H:%M:%S')

index=0
while read line; do
	list[$index]="$line"
	index=$(($index+1))
done < "$file"

total=0
for val in $(eval echo "{0..$(($index-2))}"); do
	delta=$(echo "scale=4; a=${list[$val]}-${list[$(($val+1))]}; if(0>a)a*=-1; a" | bc)
	total=$(echo "scale=4; $total+$delta" | bc)
done

echo "$datum,$total" >> "$out"