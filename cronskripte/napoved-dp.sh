#!/bin/bash

dp=$(tail -1 "/home/pi/stran/data/napoved-dp.csv")

if [ $(echo "$dp > 26" | bc) -eq 1 ]; then
	pocutje="Smrtno nevarno!"
elif [ $(echo "$dp > 24" | bc) -eq 1 ]; then
	pocutje="Ekstremno neprijetno."
elif [ $(echo "$dp > 21" | bc) -eq 1 ]; then
	pocutje="Zelo neprijetno."
elif [ $(echo "$dp > 18" | bc) -eq 1 ]; then
	pocutje="Nekoliko neprijetno."
elif [ $(echo "$dp > 16" | bc) -eq 1 ]; then
	pocutje="Občutno vlažno."
elif [ $(echo "$dp > 13" | bc) -eq 1 ]; then
	pocutje="Prijetno."
elif [ $(echo "$dp > 10" | bc) -eq 1 ]; then
	pocutje="Zelo prijetno."
elif [ $(echo "$dp > -30" | bc) -eq 1 ]; then
	pocutje="Nekoliko suho."
else
	pocutje="Zelo suho."
fi

echo "$dp,$pocutje" > "/home/pi/stran/data/zdej-dp.csv"