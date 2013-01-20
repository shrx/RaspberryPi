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
pritiskMax=$(echo "1038" | bc ) #1038 izola-vreme.info (od feb 2011 do avg 2012, MSL) ##*1.00856
pritiskMax=$(printf %.0f "$pritiskMax")
pritiskMin=$(echo "985" | bc ) #985 izola-vreme.info (od feb 2011 do avg 2012, MSL) ##*1.00856
pritiskMin=$(printf %.0f "$pritiskMin")

# uporaba: napoved $pritisk $mesec $veter $trend $kje $pritiskMax $pritiskMin
# pritisk: pritisk korigiran na nadmorsko višino 0 v hPa (mbar)
# mesec: številka meseca od 1 do 12
# veter: smer vetra npr: J, SV, ZSZ ... če ni vetra pošlji 0
# trend: spreminjanje pritiska. 0=ni sprememb 1=raste 2=pada
# kje: 1=sever 2=jug
# pritiskMax: lokalni maksimum (1050 hPa za UK)
# pritiskMin: lokalni minimum (950 hPa za UK)

function napoved {

napovedi=("Ustaljeno lepo vreme." "Lepo vreme." "Postaja lepo." "Lepo vreme& se slabša." "Lepo vreme& možne plohe." "Pretežno lepo vreme& se izboljšuje." "Pretežno lepo vreme& prej možne plohe." "Pretežno lepo vreme& kasneje možne plohe." "Prej plohe& se izboljšuje." "Spremenljivo& se izboljšuje." "Pretežno lepo vreme& verjetne plohe." "Nestabilno& sledi izboljšanje." "Nestabilno& verjetno sledi izboljšanje." "Plohe z intervali lepšega vremena." "Plohe& se slabša." "Spremenljivo& nekaj dežja." "Nestabilno& kratki intervali lepšega vremena." "Nestabilno& kasneje dež." "Nestabilno& nekaj dežja." "Zelo nestabilno." "Občasen dež& se slabša." "Občasen dež& zelo nestabilno." "Dež v pogostih intervalih." "Dež& zelo nestabilno." "Nevihte& možno izboljšanje." "Nevihte& veliko dežja.")

# equivalents of Zambretti 'dial window' letters A - Z
opcijeRast=(25 25 25 24 24 19 16 12 11 9 8 6 5 2 1 1 0 0 0 0 0 0)
opcijeStabilno=(25 25 25 25 25 25 23 23 22 18 15 13 10 4 1 1 0 0 0 0 0 0)
opcijePadanje=(25 25 25 25 25 25 25 25 23 23 21 20 17 14 7 3 1 1 1 0 0 0)

let "range=$pritiskMax-$pritiskMin"
konstanta=$(echo "$range/22" | bc)

if [ $mesec -ge 4 -a $mesec -le 9 ]; then	# true=poletje, false=zima
	letniCas=true
else
	letniCas=false
fi

if [ $kje -eq 1 ]; then	# =sever
	case $veter in
		"S")
			pritisk=$(echo "$pritisk + $range*6./100" | bc);;
		"SSV")
			pritisk=$(echo "$pritisk + $range*5./100" | bc);;
		"SV")
			pritisk=$(echo "$pritisk + $range*5./100" | bc);;	# +=4*...
		"VSV")
			pritisk=$(echo "$pritisk + $range*2./100" | bc);;
		"V")
			pritisk=$(echo "$pritisk - $range*0.5/100" | bc);;
		"VJV")
			pritisk=$(echo "$pritisk - $range*2./100" | bc);;	# -=3*...
		"JV")
			pritisk=$(echo "$pritisk - $range*5./100" | bc);;
		"JJV")
			pritisk=$(echo "$pritisk - $range*8.5/100" | bc);;
		"J")
			pritisk=$(echo "$pritisk - $range*12./100" | bc);;	# -=11*...
		"JJZ")
			pritisk=$(echo "$pritisk - $range*10./100" | bc);;
		"JZ")
			pritisk=$(echo "$pritisk - $range*6./100" | bc);;
		"ZJZ")
			pritisk=$(echo "$pritisk - $range*4.5/100" | bc);;
		"Z")
			pritisk=$(echo "$pritisk - $range*3./100" | bc);;
		"ZSZ")
			pritisk=$(echo "$pritisk - $range*0.5/100" | bc);;
		"SZ")
			pritisk=$(echo "$pritisk + $range*1.5/100" | bc);;
		"SSZ")
			pritisk=$(echo "$pritisk + $range*3./100" | bc);;
	esac
	if $letniCas; then	# =poletje
		if [ $trend -eq 1 ]; then	# =raste
			pritisk=$(echo "$pritisk + $range*7./100" | bc)
		elif [ $trend -eq 2 ]; then	# =pada
			pritisk=$(echo "$pritisk - $range*7./100" | bc)
		fi
	fi
else	# =jug
	case $veter in
		"J")
			pritisk=$(echo "$pritisk + $range*6/100" | bc);;
		"JJZ")
			pritisk=$(echo "$pritisk + $range*5/100" | bc);;
		"JZ")
			pritisk=$(echo "$pritisk + $range*5/100" | bc);;	# +=4*...
		"ZJZ")
			pritisk=$(echo "$pritisk + $range*2/100" | bc);;
		"Z")
			pritisk=$(echo "$pritisk - $range*0.5/100" | bc);;
		"ZSZ")
			pritisk=$(echo "$pritisk - $range*2/100" | bc);;	# -=3*...
		"SZ")
			pritisk=$(echo "$pritisk - $range*5/100" | bc);;
		"SSZ")
			pritisk=$(echo "$pritisk - $range*8.5/100" | bc);;
		"S")
			pritisk=$(echo "$pritisk - $range*12/100" | bc);;	# -=11*...
		"SSV")
			pritisk=$(echo "$pritisk - $range*10/100" | bc);;
		"SV")
			pritisk=$(echo "$pritisk - $range*6/100" | bc);;
		"VSV")
			pritisk=$(echo "$pritisk - $range*4.5/100" | bc);;
		"V")
			pritisk=$(echo "$pritisk - $range*3/100" | bc);;
		"VJV")
			pritisk=$(echo "$pritisk - $range*0.5/100" | bc);;
		"JV")
			pritisk=$(echo "$pritisk + $range*1.5/100" | bc);;
		"JJV")
			pritisk=$(echo "$pritisk + $range*3/100" | bc);;
	esac
	if [ ! $letniCas ]; then	# =zima
		if [ $trend -eq 1 ]; then	# =raste
			pritisk=$(echo "$pritisk + $range*7/100" | bc)
		elif [ $trend -eq 2 ]; then	# =pada
			pritisk=$(echo "$pritisk - $range*7/100" | bc)
		fi
	fi
fi
pritisk=$(printf %.0f "$pritisk")

if [ $pritisk -eq $pritiskMax ]; then
	let "pritisk=$pritiskMax-1"
fi
opcija=$(echo "($pritisk - $pritiskMin)/$konstanta-1" | bc)
opcija=$(printf %.0f "$opcija")

if [ $opcija -lt 0 ]; then
	opcija=0
	out="Izredno vreme! "
fi
if [ $opcija -gt 21 ]; then
	opcija=21
	out="Izredno vreme! "
fi

if [ $trend -eq 1 ]; then
	izbira=${opcijePadanje[$opcija]}
elif [ $trend -eq 2 ]; then
	izbira=${opcijeRast[$opcija]}
else
	izbira=${opcijeStabilno[$opcija]}
fi
out="$out${napovedi[$izbira]}"

echo "$out"",$izbira"

}

p=$(cat "/home/pi/stran/data/zdej-p.csv")
prit=${p%%,*}
pritisk=$(echo "$prit*10*1.00856" | bc )	# popravek na nadmorsko višino 0m. http://en.wikipedia.org/wiki/Sea_level_pressure#Altitude_atmospheric_pressure_variation (h=(52 + 74 + 109 + 48 + 97 + 51)/6)
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
v=${v#*online}
v=${v#*online}
v=${v#*online}
v=${v#*onlinedesno\">}
veter=${v%%<*}

# echo $pritisk
# echo $trend
# echo $mesec
# echo $veter

nap=$(napoved $pritisk $mesec $veter $trend $kje $pritiskMax $pritiskMin)
izbira=${nap##*,}
nap=${nap%,*}
datum=$(date +"%e. %m. %Y, %H:%M")

# ------ sneg ------
# info: http://people.uleth.ca/~stefan.kienzle/Documents/Kienzle_HP_SnowTemp_2008.pdf

T=$(cat "/home/pi/stran/data/zdej-t.csv")
T=${T%%,*}

Fmts () {
	Tmts=$(echo "$1 + $1*s(($mesec+2)/1.91)" | bc -l)
	result=$(echo 0.'>'$Tmts | bc -l)
	if [ $result -eq "1" ]; then
		Tmts=0.
	fi
	echo $Tmts
}

Fmrs () {
	Tmrs=$(echo "$1*(0.55+s($mesec+4))*0.6" | bc -l)
	result=$(echo 0.'>'$Tmrs | bc -l)
	if [ $result -eq "1" ]; then
		Tmrs=0.
	fi
	if [ $mesec -eq 1 ]; then
		Tmrs=$(echo "$Tmrs+0.1" | bc -l)
	fi
	echo $Tmrs
}

Frain () {
	result=$(echo $3'>'$1 | bc -l)
	if [ $result -eq 1 ]; then
		Prain=$(echo "5*(($1-$3)/(1.4*$2))^3+6.76*(($1-$3)/(1.4*$2))^2+3.19*(($1-$3)/(1.4*$2))+0.5" | bc -l)
		if [ ${Prain:0:1} == "-" ]; then
			Prain=0.
		fi
	else
		Prain=$(echo "5*(($1-$3)/(1.4*$2))^3-6.76*(($1-$3)/(1.4*$2))^2+3.19*(($1-$3)/(1.4*$2))+0.5" | bc -l)
		result=$(echo $Prain'>'1. | bc -l)
		if [ $result -eq "1" ]; then
			Prain=1.
		fi
	fi
	echo $Prain
}

Tmts=$(Fmts 2)
Tmrs=$(Fmrs 13)

Prain=$(Frain $T $Tmrs $Tmts)

result=$(echo $(echo 0.5'<'$Prain | bc -l) + $(echo $Prain'<='0.99 | bc -l)'=='2 | bc -l)
if [ $result -eq "1" ]; then
	if [ $izbira -ge 3 ]; then
		nap="$nap"" Možnost sneženja."
	fi
fi

result=$(echo $Prain'<='0.5 | bc -l)
if [ $result -eq "1" ]; then
	nap=$(echo $nap | sed 's/plohe/snežne plohe/g')
	nap=$(echo $nap | sed 's/Plohe/Snežne plohe/g')
	nap=$(echo $nap | sed 's/dežja/snega/g')
	nap=$(echo $nap | sed 's/dež/sneg/g')
	nap=$(echo $nap | sed 's/Dež/Sneg/g')
fi

# ------ /sneg ------

echo "$datum,$nap"

exit
