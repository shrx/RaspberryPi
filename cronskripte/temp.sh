#!/bin/bash

# -------- skupaj --------

file="/home/pi/stran/data/temp.csv"
fileNap="/home/pi/stran/data/napoved-t.csv"

a=$(wc -l "$file")
l=$(echo ${a%% *})
l1=$((($l-1)))

p=$(sed -n "$l1""p" "$file")
pred=$(echo ${p#*,})

z=$(sed -n "$l""p" "$file")
zad=$(echo ${z#*,})
datumzad=$(echo ${z%%:*})

# -------- bmp085 --------

ac5=24288
ac6=18782
mc=-11075
md=2432

temp=101
while [ ${temp%%.*} -gt 100 ]; do
	#set read ut
	/usr/sbin/i2cset -y 0 0x77 0xf4 0x2e
	sleep 0.05

	hexraw=$(/usr/sbin/i2cget -y 0 0x77 0xf6 w)

	datum=$(date '+%Y/%m/%d %H:%M:%S')

	hexraw2=$(/usr/sbin/i2cget -y 0 0x48 0x00 w)	# tmp102

	msb=$(echo ${hexraw:4:2})
	lsb=$(echo ${hexraw:2:2})
	ut=$(printf "%d\n" "0x$msb$lsb")

	x1=$(echo "scale=4; ($ut-$ac6)*$ac5/(2^15)" | bc)
	x2=$(echo "scale=4; $mc*2^11/($x1+$md)" | bc)
	b5=$(echo "scale=4; $x1+$x2" | bc)
	t=$(echo "scale=4; ($b5+8)/(2^4)" | bc)
	temp=$(echo "scale=4; $t/10" | bc)
	temp=$(printf "%.1f\n" "$temp")
done

# -------- tmp102 --------

msb=$(echo ${hexraw2:4:2})
lsb=$(echo ${hexraw2:2:1})
dec=$(printf "%d\n" "0x$msb$lsb")

temp2=$(echo "scale=4; $dec*0.0625" | bc)
if [ ${temp2%%.*} -ge 127 ]; then
	temp2=$(echo "scale=4; $temp2-255" | bc)
fi

# kalibracija
temp2=$(echo "scale=4; 1.11994+0.97737*$temp2" | bc)

temp2=$(printf "%.1f\n" "$temp2")

# -------- skupaj --------

hour=$(date '+%H')
if [ $hour -eq 23 -o $hour -eq 0 ]; then
	datumzdej=$(date '+%Y/%m/%d %H')
	if [ "$datumzdej" == "$datumzad" ]; then
		if [ "$pred" == "$zad" -a "$zad" == "$temp2,$temp" ]; then
			sed -i "$l""d" "$file"
		fi
	fi
else
	if [ "$pred" == "$zad" -a "$zad" == "$temp2,$temp" ]; then
		sed -i "$l""d" "$file"
	fi
fi

echo "$datum,$temp2,$temp" >> "$file"

echo "$temp2,$temp" >> "$fileNap"

x=$(wc -l "$fileNap")
tock=$(echo ${x%% *})
if [ $tock -gt 14 ]; then
	sed -i "1d" "$fileNap"
fi