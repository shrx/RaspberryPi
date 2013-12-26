#!/bin/bash
LC_NUMERIC=C
datum=$(date '+%Y/%m/%d %H:%M:%S')

fileWC="/home/pi/stran/data/windchill.csv"
fileST="/home/pi/stran/data/strayantemp.csv"

T=$(</home/pi/stran/data/zdej-t.csv)
T=${T%%,*}
RH=$(</home/pi/stran/data/zdej-h.csv)
ws=$(</home/pi/stran/data/zdej-ws.csv)
ws=${ws%,*}

function windchill {
	T=$1
	ws=$2

	if [ -n "$T" -a -n "$ws" ]; then
		if [[ $(echo $T'<=10.0' | bc -l) -eq 1 && $(echo $ws'>4.8' | bc -l) -eq 1 ]]; then
			wsPower=$(gawk "BEGIN {print $ws ** 0.16};")
			windchill=$(echo "13.12 + 0.6215 * $T - 11.37 * ${wsPower/,/.} + 0.3965 * $T * ${wsPower/,/.}" | bc -l)
			#echo $windchill | python -c "print round(float(raw_input()),4)"
			printf "%.2f\n" "$windchill"
		else
			echo ""
		fi
	else
		echo ""
	fi
}

function strayanApparentTemp {
	T=$1
	RH=$2
	ws=$3

	if [ -n "$T" -a -n "$RH" -a -n "$ws" ]; then
		appTemp=$(echo "$T + 0.33 * ( ($RH/100.) * 6.105 ) * e( (17.27 * $T)/(237.7 + $T) ) - 0.7 * $ws * 1000./3600. - 4." | bc -l)
		#echo $appTemp | python -c "print round(float(raw_input()),4)"
		printf "%.2f\n" "$appTemp"
	else
		echo ""
	fi
}

# -------------------------- windchill -------------------------

a=$(wc -l "$fileWC")
l=$(echo ${a%% *})
l1=$((($l-1)))

p=$(sed -n "$l1""p" "$fileWC")
pred=$(echo ${p#*,})

z=$(sed -n "$l""p" "$fileWC")
zad=$(echo ${z#*,})
datumzad=$(echo ${z%%:*})

WC=$(windchill $T $ws)

if [ -n "$WC" ]; then
	WCr=${WC%.*}
	dec=${WC#*.}
	if [ $dec -le 25 ]; then
		WC=$WCr
	elif [ $dec -le 75 ]; then
		WC=$WCr".5"
	else
		if [ $WCr -lt 0 -o $WCr == "-0" ]; then
			WC=$(($WCr-1))
		else
			WC=$(($WCr+1))
		fi
	fi
fi

hour=$(date '+%H')
if [ $hour -eq 0 -o $hour -eq 1 ]; then
	datumzdej=$(date '+%Y/%m/%d %H')
	if [ "$datumzdej" == "$datumzad" ]; then
		if [ "$pred" == "$zad" -a "$zad" == "$WC" ]; then
			sed -i "$l""d" "$fileWC"
		fi
	fi
else
	if [ "$pred" == "$zad" -a "$zad" == "$WC" ]; then
		sed -i "$l""d" "$fileWC"
	fi
fi

echo "$datum,$WC" >> "$fileWC"

pocutje=""
if [ -n "$WC" ]; then
	if [ $(echo "$WC <= -60." | bc) -eq 1 ]; then
		pocutje="Velika nevarnost ozeblin."
	elif [ $(echo "$WC <= -35." | bc) -eq 1 ]; then
		pocutje="Nevarnost ozeblin."
	elif [ $(echo "$WC <= -25." | bc) -eq 1 ]; then
		pocutje="Zelo mrzlo."
	fi
fi

echo "$WC,$pocutje" > "/home/pi/stran/data/zdej-wc.csv"

# ------------------------- strayanTemp ------------------------

a=$(wc -l "$fileST")
l=$(echo ${a%% *})
l1=$((($l-1)))

p=$(sed -n "$l1""p" "$fileST")
pred=$(echo ${p#*,})

z=$(sed -n "$l""p" "$fileST")
zad=$(echo ${z#*,})
datumzad=$(echo ${z%%:*})

ST=$(strayanApparentTemp $T $RH $ws)

STr=${ST%.*}
dec=${ST#*.}
if [ $dec -le 25 ]; then
	ST=$STr
elif [ $dec -le 75 ]; then
	ST=$STr".5"
else
	if [ $STr -lt 0 -o $STr == "-0" ]; then
		ST=$(($STr-1))
	else
		ST=$(($STr+1))
	fi
fi

hour=$(date '+%H')
if [ $hour -eq 0 -o $hour -eq 1 ]; then
	datumzdej=$(date '+%Y/%m/%d %H')
	if [ "$datumzdej" == "$datumzad" ]; then
		if [ "$pred" == "$zad" -a "$zad" == "$ST" ]; then
			sed -i "$l""d" "$fileST"
		fi
	fi
else
	if [ "$pred" == "$zad" -a "$zad" == "$ST" ]; then
		sed -i "$l""d" "$fileST"
	fi
fi

echo "$datum,$ST" >> "$fileST"
echo "$ST" > "/home/pi/stran/data/zdej-st.csv"

# --------------------------------------------------------------

# for T in {-20..20..5}; do
# 	for ws in {0..50..5}; do
#  		echo -n $(windchill $(echo "$T+0.5"|bc -l) $(echo "$ws+0.5"|bc -l))"  "
# 	done
# 	echo ""
# done
# echo ""
# for T in {-20..40..5}; do
# 	for ws in {0..50..5}; do
#  		echo -n $(strayanApparentTemp $(echo "$T+0.5"|bc -l) 50 $(echo "$ws+0.5"|bc -l))"  "
# 	done
# 	echo ""
# done