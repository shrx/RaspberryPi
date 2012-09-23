#!/bin/bash

file="/home/pi/stran/data/load.csv"

a=$(wc -l "$file")
l=$(echo ${a%% *})
l1=$((($l-1)))

p=$(sed -n "$l1""p" "$file")
pred=$(echo ${p#*,})

z=$(sed -n "$l""p" "$file")
zad=$(echo ${z#*,})

datum=$(date '+%Y/%m/%d %H:%M:%S')

load=$(uptime)
temp=$(/opt/vc/bin/vcgencmd measure_temp)

load=$(echo ${load##*: })
load=$(echo ${load#*, })
load=$(echo "${load%%,*}*100" | bc)
load=$(printf "%0.f" $load)

temp=$(echo ${temp##*=})
temp=$(echo ${temp%%\'*})

if [ "$pred" == "$zad" -a "$zad" == "$load,$temp" ]; then
	sed -i "$l""d" "$file"
fi

echo "$datum,$load,$temp" >> "$file"