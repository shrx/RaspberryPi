#!/bin/bash
originFile="/home/pi2/stran/data/load.csv"
app=$(timeout 30s ssh pi2@pi2 tail -1 "$originFile")
append=","${app#*,}
datumapp=${app%:*}

targetFile="/home/pi/stran/data/load.csv"
z=$(tail -1 "$targetFile")
datumz=${z%:*}
datumzad=$(echo "$datumz" | sed 's./.\\/.g' | sed 's. .\\ .g')

IFS=$'Š'
if [ -z $( grep $datumapp "$targetFile") ]; then								# datum je samo v origin (pi2)
	echo ${app%%,*}",,"$append >> "$targetFile"
elif [ -z $(timeout 30s ssh pi2@pi2 "egrep '$datumz' '$originFile'") ]; then	# datum je samo v target (pi)
	sed --posix -i '${s/$/,,/}' "$targetFile"
else																			# oba datuma sta v fajlih
	#zad=${z#*,}
	#datumzad=$(echo "2013/12/15 19:35" | sed 's./.\\/.g' | sed 's. .\\ .g')
	#echo "$datumzad"
	if [ $(echo "$z" | tr -cd . | wc -c) -eq 1 ]; then
		sed --posix -i -E "s/($datumzad.*)/\1$append/" "$targetFile"
	fi
fi
unset IFS

