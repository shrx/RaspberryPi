#!/bin/bash

hex0="c0"
dec0=$(printf "%d\n" "0x$hex0")
hex1="f5"
dec1=$(printf "%d\n" "0x$hex1")
echo $dec0
echo $dec1
let "r=$dec1 << 8"
echo $r
let "temperature=$r | $dec0"
echo $temperature
let "temperature=$temperature >> 4"
echo $temperature
bin=$(echo "obase=2;$temperature" | bc)
echo $bin
len=$(echo $bin | wc -m)
echo $len #da bo na 11. mestu 1 mora bit dolžina =>12 (začetnih 0 ne izpiše)

if [ $len -ge 12 ]; then
#	b11=$(echo ${bin:(($len-2)):1})
#	echo $b11
#	if [ $b11 == 1 ]; then
#		let "temperature=$temperature | 63488"
#	fi
	echo "scale=4; $temperature*0.0625-255" | bc
else
	echo "scale=4; $temperature*0.0625" | bc
fi

t=155.0346
if [ ${t%%.*} -ge 127 ]; then
	echo "več"
else
	echo "manj"
fi