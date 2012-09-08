#!/bin/bash

file="/home/pi/stran/data/tmp102.csv"

a=$(wc -l "$file")
l=$(echo ${a%% *})
l1=$((($l-1)))

p=$(sed -n "$l1""p" "$file")
pred=$(echo ${p##*,})

z=$(sed -n "$l""p" "$file")
zad=$(echo ${z##*,})

datum=$(date '+%Y/%m/%d %H:%M:%S')

hexraw=$(/usr/sbin/i2cget -y 0 0x48 0x00 w)

msb=$(echo ${hexraw:4:2})
lsb=$(echo ${hexraw:2:1})
dec=$(printf "%d\n" "0x$msb$lsb")

temperature=$(echo "scale=4; $dec*0.0625" | bc)
if [ ${temperature%%.*} -ge 127 ]; then
	temperature=$(echo "scale=4; $temperature-255" | bc)
fi

if [ "$pred" == "$zad" -a "$zad" == "$temperature" ]; then
	sed -i "$l""d" "$file"
fi

#x=$(cat ~/stran/data/tmp102.csv|wc -l)
#tock=$(echo ${x% *})
#if [ $tock -ge 1000 ]; then
#	sed -i "2d" ~/stran/data/tmp102.csv
#fi

echo "$datum,$temperature" >> "$file"