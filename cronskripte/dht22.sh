#! /bin/bash
LC_NUMERIC=C

file="/home/pi/stran/data/dht22.csv"
# fileNap="/home/pi/stran/data/napoved-h.csv"

a=$(wc -l "$file")
l=$(echo ${a%% *})
l1=$((($l-1)))

p=$(sed -n "$l1""p" "$file")
pred=$(echo ${p#*,})

z=$(sed -n "$l""p" "$file")
zad=$(echo ${z#*,})
datumzad=$(echo ${z%%:*})

# dht=$(sudo /usr/local/bin/loldht)
RH=$(<stran/data/zdej-h.csv)
datum=$(date '+%Y/%m/%d %H:%M:%S')
# dht=${dht##*Humidity = }
# mean=${dht%% *}
# RH=$(printf "%.0f\n" "$mean")

hour=$(date '+%H')
if [ $hour -eq 0 -o $hour -eq 1 ]; then
	datumzdej=$(date '+%Y/%m/%d %H')
	if [ "$datumzdej" == "$datumzad" ]; then
		if [ "$pred" == "$zad" -a "$zad" == "$RH""$comment" ]; then
			sed -i "$l""d" "$file"
		fi
	fi
else
	if [ "$pred" == "$zad" -a "$zad" == "$RH""$comment" ]; then
		sed -i "$l""d" "$file"
	fi
fi

echo "$datum,$RH$comment" >> "$file"

# echo "$RH" >> "$fileNap"
#
# x=$(wc -l "$fileNap")
# tock=$(echo ${x%% *})
# if [ $tock -gt 14 ]; then
# 	sed -i "1d" "$fileNap"
# fi

# ---------- Dew Point ----------

filet="/home/pi/stran/data/zdej-t.csv"
fileDP="/home/pi/stran/data/DP.csv"
fileDPNap="/home/pi/stran/data/napoved-dp.csv"

b=18.678
c=257.14
d=234.5

T=$(head -1 "$filet")
T=${T%%,*}

gama=$(echo "l( ($RH/100) * e( ($b-($T/$d))*($T/($c+($T))) ) )" | bc -l)
DP=$(echo "scale=3; ($c*$gama)/($b-($gama))" | bc)
DP=$(printf "%.2f\n" "$DP")

dpr=${DP%.*}
dec=${DP#*.}
if [ $dec -le 25 ]; then
	DP=$dpr
elif [ $dec -le 75 ]; then
	DP=$dpr".5"
else
	if [ $dpr -lt 0 -o $dpr == "-0" ]; then
		DP=$(($dpr-1))
	else
		DP=$(($dpr+1))
	fi
fi

a=$(wc -l "$fileDP")
l=$(echo ${a%% *})
l1=$((($l-1)))

p=$(sed -n "$l1""p" "$fileDP")
pred=$(echo ${p#*,})

z=$(sed -n "$l""p" "$fileDP")
zad=$(echo ${z#*,})
datumzad=$(echo ${z%%:*})

hour=$(date '+%H')
if [ $hour -eq 0 -o $hour -eq 1 ]; then
	datumzdej=$(date '+%Y/%m/%d %H')
	if [ "$datumzdej" == "$datumzad" ]; then
		if [ "$pred" == "$zad" -a "$zad" == "$DP" ]; then
			sed -i "$l""d" "$fileDP"
		fi
	fi
else
	if [ "$pred" == "$zad" -a "$zad" == "$DP" ]; then
		sed -i "$l""d" "$fileDP"
	fi
fi

echo "$datum,$DP" >> "$fileDP"

echo "$DP" >> "$fileDPNap"

x=$(wc -l "$fileDPNap")
tock=$(echo ${x%% *})
if [ $tock -gt 14 ]; then
	sed -i "1d" "$fileDPNap"
fi

# ---------- Heat Index ----------

fileHI="/home/pi/stran/data/HI.csv"
fileHINap="/home/pi/stran/data/napoved-hi.csv"

T=$(echo "$T*9./5. + 32" | bc -l)

if [ ${T%%.*} -ge 80 -a $RH -ge 40 ]; then

	c1=16.923
	c2=0.185212
	c3=5.37941
	c4=-0.100254
	c5=0.00941695
	c6=0.00728898
	c7=0.000345372
	c8=-0.000814971
	c9=0.0000102102
	c10=-0.000038646
	c11=0.0000291583
	c12=0.00000142721
	c13=0.000000197483
	c14=-0.0000000218429
	c15=0.000000000843296
	c16=-0.0000000000481975

	HI=$(echo "$c1 + $c2*$T + $c3*$RH + $c4*$T*$RH + $c5*$T^2 + $c6*$RH^2 + $c7*$T^2*$RH + $c8*$T*$RH^2 + $c9*$T^2*$RH^2 + $c10*$T^3 + $c11*$RH^3 + $c12*$T^3*$RH + $c13*$T*$RH^3 + $c14*$T^3*$RH^2 + $c15*$T^2*$RH^3 + $c16*$T^3*$RH^3" | bc -l)
	HI=$(echo "scale=2; ($HI-32)*5/9" | bc)

	hir=${HI%.*}
	dec=${HI#*.}
	if [ $dec -le 25 ]; then
		HI=$hir
	elif [ $dec -le 75 ]; then
		HI=$hir".5"
	else
		HI=$(($hir+1))
	fi
else
	HI="null"
fi

a=$(wc -l "$fileHI")
l=$(echo ${a%% *})
l1=$((($l-1)))

p=$(sed -n "$l1""p" "$fileHI")
pred=$(echo ${p#*,})

z=$(sed -n "$l""p" "$fileHI")
zad=$(echo ${z#*,})
datumzad=$(echo ${z%%:*})

hour=$(date '+%H')
if [ $hour -eq 0 -o $hour -eq 1 ]; then
	datumzdej=$(date '+%Y/%m/%d %H')
	if [ "$datumzdej" == "$datumzad" ]; then
		if [ "$pred" == "$zad" -a "$zad" == "$HI" ]; then
			sed -i "$l""d" "$fileHI"
		fi
	fi
else
	if [ "$pred" == "$zad" -a "$zad" == "$HI" ]; then
		sed -i "$l""d" "$fileHI"
	fi
fi

echo "$datum,$HI" >> "$fileHI"

echo "$HI" >> "$fileHINap"

x=$(wc -l "$fileHINap")
tock=$(echo ${x%% *})
if [ $tock -gt 14 ]; then
	sed -i "1d" "$fileHINap"
fi
