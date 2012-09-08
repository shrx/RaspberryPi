#!/bin/bash

# n << x = n*2^x
# n >> x = n/2^x

OSS=3

ac1=10110   # msb->lsb		pres
ac2=-1064   # msb->lsb		pres
ac3=-14574  # msb->lsb		pres
ac4=34174   # msb->lsb		pres
ac5=24288   # msb->lsb temp
ac6=18782   # msb->lsb temp
b1=5498     # msb->lsb		pres
b2=55       # msb->lsb		pres
mb=-32768   # msb->lsb
mc=-11075   # msb->lsb temp
md=2432     # msb->lsb temp

#-------------------------------------

#set read ut
/usr/sbin/i2cset -y 0 0x77 0xf4 0x2e
sleep 0.1

hexraw=$(/usr/sbin/i2cget -y 0 0x77 0xf6 w)
msb=$(echo ${hexraw:4:2})
lsb=$(echo ${hexraw:2:2})
echo "ut=0x$msb$lsb"
ut=$(printf "%d\n" "0x$msb$lsb")
echo "ut=$ut"

x1=$(echo "scale=4; ($ut-$ac6)*$ac5/(2^15)" | bc)
echo "x1=$x1"

x2=$(echo "scale=4; $mc*2^11/($x1+$md)" | bc)
echo "x2=$x2"

b5=$(echo "scale=4; $x1+$x2" | bc)
echo "b5=$b5"

t=$(echo "scale=4; ($b5+8)/(2^4)" | bc)
echo "t=$t"

temp=$(echo "scale=4; $t/10" | bc)
echo "temp=$temp"

echo "-------------------------------------"

#set read up (OSS=3)
/usr/sbin/i2cset -y 0 0x77 0xf4 0xf4
sleep 0.1

msb=$(/usr/sbin/i2cget -y 0 0x77 0xf6)
lsb=$(/usr/sbin/i2cget -y 0 0x77 0xf7)
xlsb=$(/usr/sbin/i2cget -y 0 0x77 0xf8)

up="${msb##*x}${lsb##*x}${xlsb##*x}"
echo "up=0x$up"
up=$(printf "%d\n" "0x$up")
echo "up=$up"

up=$(echo "scale=4; $up/2^(8-$OSS)" | bc)
echo "up=$up"

b6=$(echo "scale=4; $b5-4000" | bc)
echo "b6=$b6"

x1=$(echo "scale=4; ($b2*($b6^2)/(2^12))/2^11" | bc)
echo "x1=$x1"

x2=$(echo "scale=4; ($ac2*$b6)/2^11" | bc)
echo "x2=$x2"

x3=$(echo "scale=4; $x1+$x2" | bc)
echo "x3=$x3"

b3=$(echo "scale=4; ($ac1*4+$x3+2)*2" | bc) #http://mitat.tuu.fi/?p=78
echo "b3=$b3"

x1=$(echo "scale=4; ($ac3*$b6)/2^13" | bc)
echo "x1=$x1"

x2=$(echo "scale=4; ($b1*($b6^2)/2^12)/2^16" | bc)
echo "x2=$x2"

x3=$(echo "scale=4; ($x1+$x2+2)/4" | bc)
echo "x3=$x3"

b4=$(echo "scale=4; ($ac4*($x3+32768))/2^15" | bc)
echo "b4=$b4"

b7=$(echo "scale=4; ($up-$b3)*(50000/(2^$OSS))" | bc)
echo "b7=$b7"

if [ ${b7%%.*} -lt 2147483648 ]; then
	p=$(echo "scale=4; ($b7*2)/$b4" | bc)
else
	p=$(echo "scale=4; ($b7/$b4)*2" | bc)
fi
echo "p=$p"

x1=$(echo "scale=4; ($p/2^8)^2" | bc)
echo "x1=$x1"

x1=$(echo "scale=4; ($x1*3038)/2^16" | bc)
echo "x1=$x1"

x2=$(echo "scale=4; (-7357*$p)/2^16" | bc)
echo "x2=$x2"

pres=$(echo "scale=4; $p+($x1+$x2+3791)/2^4" | bc)
echo "pres=$pres"