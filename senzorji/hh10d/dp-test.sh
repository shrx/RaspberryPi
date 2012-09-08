#!/bin/bash

filet="/home/pi/stran/data/napoved-t.csv"

b=18.678
c=257.14
d=234.5

T=30.5
RH=12

gama=$(echo "l( ($RH/100) * e( ($b-($T/$d))*($T/($c+$T)) ) )" | bc -l)

DP=$(echo "scale=3; ($c*$gama)/($b-($gama))" | bc)


DP=$(printf "%.2f\n" "$DP")

dec=${DP#*.}
if [ $dec -le 25 ]; then
	DP=${DP%.*}
elif [ $dec -le 75 ]; then
	DP=${DP%.*}".5"
else
	DP=$((${DP%.*}+1))
fi

echo $DP