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
i=0
while [ ${temp%%.*} -gt 100 ] && [ $i -le 5 ]; do
	i=$(($i+1))
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

temp2=$(echo "scale=5; $dec*0.0625" | bc)
if [ ${temp2%%.*} -ge 127 ]; then
	temp2=$(echo "scale=5; $temp2-256" | bc)
fi

# kalibracija 16. 9. 2:15
#temp2=$(echo "scale=4; 1.11994+0.97737*$temp2-0.1" | bc)
# kalibracija 10. 12. 2012 01:21
#temp2=$(echo "scale=4; -0.0905923+1.00713*$temp2" | bc)
# skupaj:
#temp2=$(echo "scale=4; 0.93662+0.984339*$temp2" | bc)   konec kalib. 7. feb 2013 20:42

temp2=$(printf "%.1f\n" "$temp2")

# -------- dht22 --------

fileNapRH="/home/pi/stran/data/napoved-h.csv"

dht=$(sudo /usr/local/bin/loldht)

rh=${dht##*Humidity = }
rh=${rh%% *}
RH=$(printf "%.0f\n" "$rh")

temp3=${dht##*Temperature = }
temp3=${temp3%% *}
temp3=$(printf "%.1f\n" "$temp3")

echo "$RH" > ~/stran/data/zdej-h.csv
echo "$RH" >> "$fileNapRH"

x=$(wc -l "$fileNapRH")
tock=$(echo ${x%% *})
if [ $tock -gt 14 ]; then
	sed -i "1d" "$fileNapRH"
fi

# -------- skupaj --------

hour=$(date '+%H')
if [ $hour -eq 0 -o $hour -eq 1 ]; then
	datumzdej=$(date '+%Y/%m/%d %H')
	if [ "$datumzdej" == "$datumzad" ]; then
		if [ "$pred" == "$zad" -a "$zad" == "$temp2,$temp,$temp3" ]; then
			sed -i "$l""d" "$file"
		fi
	fi
else
	if [ "$pred" == "$zad" -a "$zad" == "$temp2,$temp,$temp3" ]; then
		sed -i "$l""d" "$file"
	fi
fi

echo "$datum,$temp2,$temp,$temp3" >> "$file"

echo "$temp2,$temp,$temp3" >> "$fileNap"

x=$(wc -l "$fileNap")
tock=$(echo ${x%% *})
if [ $tock -gt 14 ]; then
	sed -i "1d" "$fileNap"
fi