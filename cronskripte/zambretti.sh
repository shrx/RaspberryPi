#!/bin/bash

# if [ $# -ne 4 ]; then
# 	echo "število parametrov ne ustreza (≠4)"
# 	exit
# fi
#
# pritisk=$1
# mesec=$2
# veter=$3
# trend=$4

kje=1
pritiskMax=$(echo "scale=0; 1017*100856/100000" | bc ) #1038 izola-vreme.info (od feb 2011 do avg 2012)
pritiskMin=$(echo "scale=0; 990*100856/100000" | bc ) #985 izola-vreme.info (od feb 2011 do avg 2012)

# uporaba: napoved $pritisk $mesec $veter $trend $kje $pritiskMax $pritiskMin
# pritisk: pritisk korigiran na nadmorsko višino 0 v hPa (mbar)
# mesec: številka meseca od 1 do 12
# veter: smer vetra npr: J, SV, ZSZ ... če ni vetra pošlji 0
# trend: spreminjanje pritiska. 0=ni sprememb 1=raste 2=pada
# kje: 1=sever 2=jug
# pritiskMax: lokalni maksimum (1050 hPa za UK)
# pritiskMin: lokalni minimum (950 hPa za UK)

function napoved {

napovedi=("Ustaljeno jasno" "Jasno" "Postaja jasno" "Jasno se slabša" "Jasno možne plohe" "Pretežno jasno se izboljšuje" "Pretežno jasno prej možne plohe" "Pretežno jasno kasneje možne plohe" "Prej plohe se izboljšuje" "Spremenljivo se izboljšuje" "Pretežno jasno verjetne plohe" "Nestabilno sledi izboljšanje" "Nestabilno verjetno sledi izboljšanje" "Plohe z intervali jasnega vremena" "Plohe se slabša" "Spremenljivo nekaj dežja" "Nestabilno kratki intervali jasnega vremena" "Nestabilno kasneje dež" "Nestabilno nekaj dežja" "Zelo nestabilno" "Občasen dež se slabša" "Občasen dež zelo nestabilno" "Dež v pogostih intervalih" "Dež zelo nestabilno" "Nevihte možno izboljšanje" "Nevihte veliko dežja")

# equivalents of Zambretti 'dial window' letters A - Z
opcijeRast=[25,25,25,24,24,19,16,12,11,9,8,6,5,2,1,1,0,0,0,0,0,0]
opcijeStabilno=[25,25,25,25,25,25,23,23,22,18,15,13,10,4,1,1,0,0,0,0,0,0]
opcijePadanje=[25,25,25,25,25,25,25,25,23,23,21,20,17,14,7,3,1,1,1,0,0,0]

let "range=pritiskMax-pritiskMin"
konstanta=$(echo "scale=3; $range/22" | bc)

if [ $mesec -ge 4 -a $mesec -le 9 ]; then	# true=poletje, false=zima
	letniCas=true
else
	letniCas=false
fi

if [ $kje -eq 1 ]; then	# =sever
	case $veter in
		"S")
			pritisk=$(echo "scale=1; $pritisk + $range*6/100" | bc);;
		"SSV")
			pritisk=$(echo "scale=1; $pritisk + $range*5/100" | bc);;
		"SV")
			pritisk=$(echo "scale=1; $pritisk + $range*5/100" | bc);;	# +=4*...
		"VSV")
			pritisk=$(echo "scale=1; $pritisk + $range*2/100" | bc);;
		"V")
			pritisk=$(echo "scale=1; $pritisk - $range*0.5/100" | bc);;
		"VJV")
			pritisk=$(echo "scale=1; $pritisk - $range*2/100" | bc);;	# -=3*...
		"JV")
			pritisk=$(echo "scale=1; $pritisk - $range*5/100" | bc);;
		"JJV")
			pritisk=$(echo "scale=1; $pritisk - $range*8.5/100" | bc);;
		"J")
			pritisk=$(echo "scale=1; $pritisk - $range*12/100" | bc);;	# -=11*...
		"JJZ")
			pritisk=$(echo "scale=1; $pritisk - $range*10/100" | bc);;
		"JZ")
			pritisk=$(echo "scale=1; $pritisk - $range*6/100" | bc);;
		"ZJZ")
			pritisk=$(echo "scale=1; $pritisk - $range*4.5/100" | bc);;
		"Z")
			pritisk=$(echo "scale=1; $pritisk - $range*3/100" | bc);;
		"ZSZ")
			pritisk=$(echo "scale=1; $pritisk - $range*0.5/100" | bc);;
		"SZ")
			pritisk=$(echo "scale=1; $pritisk + $range*1.5/100" | bc);;
		"SSZ")
			pritisk=$(echo "scale=1; $pritisk + $range*3/100" | bc);;
	esac
	if $letniCas; then	# =poletje
		if [ $trend -eq 1 ]; then	# =raste
			pritisk=$(echo "scale=1; $pritisk + $range*7/100" | bc)
		elif [ $trend -eq 2 ]; then	# =pada
			pritisk=$(echo "scale=1; $pritisk - $range*7/100" | bc)
		fi
	fi
else	# =jug
	case $veter in
		"J")
			pritisk=$(echo "scale=1; $pritisk + $range*6/100" | bc);;
		"JJZ")
			pritisk=$(echo "scale=1; $pritisk + $range*5/100" | bc);;
		"JZ")
			pritisk=$(echo "scale=1; $pritisk + $range*5/100" | bc);;	# +=4*...
		"ZJZ")
			pritisk=$(echo "scale=1; $pritisk + $range*2/100" | bc);;
		"Z")
			pritisk=$(echo "scale=1; $pritisk - $range*0.5/100" | bc);;
		"ZSZ")
			pritisk=$(echo "scale=1; $pritisk - $range*2/100" | bc);;	# -=3*...
		"SZ")
			pritisk=$(echo "scale=1; $pritisk - $range*5/100" | bc);;
		"SSZ")
			pritisk=$(echo "scale=1; $pritisk - $range*8.5/100" | bc);;
		"S")
			pritisk=$(echo "scale=1; $pritisk - $range*12/100" | bc);;	# -=11*...
		"SSV")
			pritisk=$(echo "scale=1; $pritisk - $range*10/100" | bc);;
		"SV")
			pritisk=$(echo "scale=1; $pritisk - $range*6/100" | bc);;
		"VSV")
			pritisk=$(echo "scale=1; $pritisk - $range*4.5/100" | bc);;
		"V")
			pritisk=$(echo "scale=1; $pritisk - $range*3/100" | bc);;
		"VJV")
			pritisk=$(echo "scale=1; $pritisk - $range*0.5/100" | bc);;
		"JV")
			pritisk=$(echo "scale=1; $pritisk + $range*1.5/100" | bc);;
		"JJV")
			pritisk=$(echo "scale=1; $pritisk + $range*3/100" | bc);;
	esac
	if [ ! $letniCas ]; then	# =zima
		if [ $trend -eq 1 ]; then	# =raste
			pritisk=$(echo "scale=1; $pritisk + $range*7/100" | bc)
		elif [ $trend -eq 2 ]; then	# =pada
			pritisk=$(echo "scale=1; $pritisk - $range*7/100" | bc)
		fi
	fi
fi

if [ ${pritisk%%.*} -eq $pritiskMax ]; then
	let "pritisk=pritiskMax-1"
fi
opcija=$(echo "scale=0; ($pritisk - $pritiskMin)/$konstanta" | bc)

if [ $opcija -lt 0 ]; then
	opcija=0
	out="Izredno vreme! "
fi
if [ $opcija -gt 21 ]; then
	opcija=21
	out="Izredno vreme! "
fi

if [ $trend -eq 1 ]; then
	out="$out${napovedi[${opcijeRast[$opcija]}]}"
elif [ $trend -eq 2 ]; then
	out="$out${napovedi[${opcijePadanje[$opcija]}]}"
else
	out="$out${napovedi[${opcijeStabilno[$opcija]}]}"
fi

echo "$out"

}

p=$(cat "/home/pi/stran/data/zdej-p.csv")
prit=${p%%,*}
pritisk=$(echo "scale=1; $prit*10*1.00856" | bc )	# popravek na nadmorsko višino 0m. http://en.wikipedia.org/wiki/Sea_level_pressure#Altitude_atmospheric_pressure_variation (h=(52 + 74 + 109 + 48 + 97 + 51)/6)
if [ "${p##*,}" == " pada" ]; then
	trend=2
elif [ "${p##*,}" == " raste" ]; then
	trend=1
else
	trend=0
fi

mesec=$(date +%m)

# v=$(curl --silent http://193.95.233.105/econova1/?mesto=Koper | awk 'NR==162')
# vet=${v##*(}
# veter=${vet%%)*}

v=$(curl --silent http://www.arso.gov.si/vreme/napovedi%20in%20podatki/vreme_avt.html | grep "Koper Kapitanija")
v2=${v#*online}
v3=${v2#*online}
v4=${v3#*online}
v5=${v4#*onlinedesno\">}
veter=${v5%%<*}

# echo $pritisk
# echo $trend
# echo $mesec
# echo $veter

nap=$(napoved $pritisk $mesec $veter $trend $kje $pritiskMax $pritiskMin)
datum=$(date +"%e. %m. %Y, %H:%M")

echo "$datum,$nap"

exit
