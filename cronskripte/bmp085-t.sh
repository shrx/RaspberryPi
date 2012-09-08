#!/bin/bash

#file="/home/pi/stran/data/bmp085-t.csv"
file="/home/pi/stran/data/temp.csv"
fileNap="/home/pi/stran/data/napoved-t.csv"

a=$(wc -l "$file")
l=$(echo ${a%% *})
l1=$((($l-1)))

p=$(sed -n "$l1""p" "$file")
pred=$(echo ${p#*,})

z=$(sed -n "$l""p" "$file")
zad=$(echo ${z#*,})

OSS=3

ac1=10110
ac2=-1064
ac3=-14574
ac4=34174
ac5=24288
ac6=18782
b1=5498
b2=55
mb=-32768
mc=-11075
md=2432

temp=101
while [ ${temp%%.*} -gt 100 ]; do
	#set read ut
	/usr/sbin/i2cset -y 0 0x77 0xf4 0x2e
	sleep 0.05

	hexraw=$(/usr/sbin/i2cget -y 0 0x77 0xf6 w)

	datum=$(date '+%Y/%m/%d %H:%M:%S')

	msb=$(echo ${hexraw:4:2})
	lsb=$(echo ${hexraw:2:2})
	ut=$(printf "%d\n" "0x$msb$lsb")

	x1=$(echo "scale=4; ($ut-$ac6)*$ac5/(2^15)" | bc)
	x2=$(echo "scale=4; $mc*2^11/($x1+$md)" | bc)
	b5=$(echo "scale=4; $x1+$x2" | bc)
	t=$(echo "scale=4; ($b5+8)/(2^4)" | bc)
	temp=$(echo "scale=1; $t/10" | bc)
done

if [ "$pred" == "$zad" -a "$zad" == ",$temp" ]; then
	sed -i "$l""d" "$file"
fi

#x=$(cat ~/stran/data/tmp102.csv|wc -l)
#tock=$(echo ${x% *})
#if [ $tock -ge 1000 ]; then
#	sed -i "2d" ~/stran/data/tmp102.csv
#fi

#echo "$datum,$temp" >> "$file"
echo "$datum,,$temp" >> "$file"

echo ",$temp" >> "$fileNap"

x=$(wc -l "$fileNap")
tock=$(echo ${x%% *})
if [ $tock -gt 70 ]; then
	sed -i "1d" "$fileNap"
fi