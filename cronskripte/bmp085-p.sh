#!/bin/bash

file="/home/pi/stran/data/bmp085-p.csv"
fileNap="/home/pi/stran/data/napoved-p.csv"

a=$(wc -l "$file")
l=$(echo ${a%% *})
l1=$((($l-1)))

p=$(sed -n "$l1""p" "$file")
pred=$(echo ${p#*,})

z=$(sed -n "$l""p" "$file")
zad=$(echo ${z#*,})
datumzad=$(echo ${z%%:*})

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

pres=69
while [ ${pres%%.*} -lt 70 -o ${pres%%.*} -gt 120 ]; do
	#set read ut
	/usr/sbin/i2cset -y 0 0x77 0xf4 0x2e
	sleep 0.05

	hexraw=$(/usr/sbin/i2cget -y 0 0x77 0xf6 w)
	msb=$(echo ${hexraw:4:2})
	lsb=$(echo ${hexraw:2:2})
	ut=$(printf "%d\n" "0x$msb$lsb")

	x1=$(echo "scale=4; ($ut-$ac6)*$ac5/(2^15)" | bc)
	x2=$(echo "scale=4; $mc*2^11/($x1+$md)" | bc)
	b5=$(echo "scale=4; $x1+$x2" | bc)

	#set read up (OSS=3)
	/usr/sbin/i2cset -y 0 0x77 0xf4 0xf4
	sleep 0.05

	msb=$(/usr/sbin/i2cget -y 0 0x77 0xf6)
	lsb=$(/usr/sbin/i2cget -y 0 0x77 0xf7)
	xlsb=$(/usr/sbin/i2cget -y 0 0x77 0xf8)

	datum=$(date '+%Y/%m/%d %H:%M:%S')

	up="${msb##*x}${lsb##*x}${xlsb##*x}"
	up=$(printf "%d\n" "0x$up")
	up=$(echo "scale=4; $up/2^(8-$OSS)" | bc)

	b6=$(echo "scale=4; $b5-4000" | bc)
	x1=$(echo "scale=4; ($b2*($b6^2)/(2^12))/2^11" | bc)
	x2=$(echo "scale=4; ($ac2*$b6)/2^11" | bc)
	x3=$(echo "scale=4; $x1+$x2" | bc)
	b3=$(echo "scale=4; ($ac1*4+$x3+2)*2" | bc) #http://mitat.tuu.fi/?p=78
	x1=$(echo "scale=4; ($ac3*$b6)/2^13" | bc)
	x2=$(echo "scale=4; ($b1*($b6^2)/2^12)/2^16" | bc)
	x3=$(echo "scale=4; ($x1+$x2+2)/4" | bc)
	b4=$(echo "scale=4; ($ac4*($x3+32768))/2^15" | bc)
	b7=$(echo "scale=4; ($up-$b3)*(50000/(2^$OSS))" | bc)
	if [ ${b7%%.*} -lt 2147483648 ]; then
		p=$(echo "scale=4; ($b7*2)/$b4" | bc)
	else
		p=$(echo "scale=4; ($b7/$b4)*2" | bc)
	fi
	x1=$(echo "scale=4; ($p/2^8)^2" | bc)
	x1=$(echo "scale=4; ($x1*3038)/2^16" | bc)
	x2=$(echo "scale=4; (-7357*$p)/2^16" | bc)
	presPa=$(echo "scale=0; $p+($x1+$x2+3791)/2^4" | bc)
	pres=$(echo "scale=2; $presPa/1000" | bc)
done

spike=$(echo "($pred-$zad)*100" | bc)
spike=$(echo ${spike#-})
base=$(echo "($pred-$pres)*100" | bc)
base=$(echo ${base#-})

if [ $(date '+%Y/%m/%d %H') == "$datumzad" ]; then
	if [ "$pred" == "$zad" -a "$zad" == "$pres" ] || [ ${spike%%.*} -ge 7 -a ${base%%.*} -le 3 ]; then
		sed -i "$l""d" "$file"
	fi
fi

echo "$datum,$pres" >> "$file"

echo "$presPa" >> "$fileNap"

x=$(wc -l "$fileNap")
tock=$(echo ${x%% *})
if [ $tock -gt 14 ]; then
	sed -i "1d" "$fileNap"
fi
