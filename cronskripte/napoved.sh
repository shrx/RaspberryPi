#!/bin/bash

#p0=101325
#alt=(52 + 74 + 109 + 48 + 97 + 51) / 6
#pexp=p0*(1-alt*2.25577*10^-5)^5.25588
pexp=100465
echo $pexp

fileNap="/home/pi/stran/data/napoved-p.csv"

h1=$(head -n 5 "$fileNap")
now=$(tail -n 5 "$fileNap")

n=0
sum=0
for i in $h1
do
  sum=$(echo "scale=4; $sum+$i" | bc)
  n=$(expr $n + 1)
done
h1mean=$(echo "scale=0; $sum/$n" | bc)

n=0
sum=0
for i in $now
do
  sum=$(echo "scale=4; $sum+$i" | bc)
  n=$(expr $n + 1)
done
nowmean=$(echo "scale=0; $sum/$n" | bc)

echo $h1mean
echo $nowmean

popravek=-115

difexp=$(expr $nowmean - $pexp - $popravek)
echo $difexp
dif=$(expr $nowmean - $h1mean)
echo $dif

if [ $difexp -gt 250 ]; then
	echo "Sončno"
elif [ $difexp -le 250 -a $difexp -ge -250 ]; then
	echo "Delno oblačno"
elif [ $dif -ge -50 ]; then
	echo "Oblačno"
elif [ $dif -ge -250 ]; then
	echo "Deževno"
else
	echo "Nevihtno"
fi
