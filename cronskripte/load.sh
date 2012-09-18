#!/bin/bash

file="/home/pi/stran/data/load.csv"

a=$(wc -l "$file")
l=$(echo ${a%% *})
l1=$((($l-1)))

p=$(sed -n "$l1""p" "$file")
pred=$(echo ${p##*,})

z=$(sed -n "$l""p" "$file")
zad=$(echo ${z##*,})

datum=$(date '+%Y/%m/%d %H:%M:%S')

x=$(uptime)
y=$(echo ${x##*: })
load=$(echo ${y#*, })
load=$(echo "${load%%,*}*100" | bc)
load=$(printf "%0.f" $load)

if [ "$pred" == "$zad" -a "$zad" == "$load" ]; then
	sed -i "$l""d" "$file"
fi

#x=$(cat ~/stran/data/load.csv|wc -l)
#tock=$(echo ${x% *})
#if [ $tock -ge 1000 ]; then
#	sed -i "2d" ~/stran/data/load.csv
#fi

echo "$datum,$load" >> "$file"