#!/bin/bash

hi=$(tail -1 "/home/pi/stran/data/napoved-hi.csv")

if [ $(echo "$hi >= 54" | bc) -eq 1 ]; then
	pocutje="Velika verjetnost vročinske kapi."
elif [ $(echo "$hi >= 41" | bc) -eq 1 ]; then
	pocutje="Verjetni vročinski krči in sončarica. Dolgotrajna aktivnost verjetno povzroči vročinsko kap."
elif [ $(echo "$hi >= 32" | bc) -eq 1 ]; then
	pocutje="Možni vročinski krči in sončarica. Dolgotrajna aktivnost lahko povzroči vročinsko kap."
elif [ $(echo "$hi >= 27" | bc) -eq 1 ]; then
	pocutje="Možna utrujenost in vročinski krči ob dolgotrajni aktivnosti."
fi

echo "$hi,$pocutje" > "/home/pi/stran/data/zdej-hi.csv"