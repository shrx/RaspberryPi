#!/bin/bash

~/cronskripte/load.sh;
~/cronskripte/temp.sh;
~/cronskripte/bmp085-p.sh;
#~/cronskripte/hh10d.sh;
~/cronskripte/dht22.sh;
# rpi2: windspeed, winddir, rainfall
timeout 45s rsync -avPq -e ssh "pi2@pi2:/home/pi2/stran/data/windspeed.csv /home/pi2/stran/data/winddir.csv /home/pi2/stran/data/rainfall.csv /home/pi2/stran/data/zdej-ws.csv /home/pi2/stran/data/zdej-wd.csv /home/pi2/stran/data/zdej-rf.csv /home/pi2/stran/data/dezevnidnevi.csv" /home/pi/stran/data/;
#ws=$(tail -1 ~/stran/data/windspeed.csv)
#echo ${ws#*,} > ~/stran/data/zdej-ws.csv;
~/cronskripte/windchillStrayantemp.sh;

#wd=$(tail -1 ~/stran/data/winddir.csv)
#echo ${wd##*,} > ~/stran/data/zdej-wd.csv;

#rf=$(tail -1 ~/stran/data/rainfall.csv)
#echo ${rf##*,} > ~/stran/data/zdej-rf.csv;

~/cronskripte/joinLoads.sh;

~/cronskripte/napoved.py ~/stran/data/napoved-t.csv > ~/stran/data/zdej-t.csv;
~/cronskripte/napoved.py ~/stran/data/napoved-p.csv > ~/stran/data/zdej-p.csv;
# echo $(tail -1 ~/stran/data/napoved-h.csv) > ~/stran/data/zdej-h.csv;
~/cronskripte/napoved-dp.sh;
~/cronskripte/napoved-hi.sh;

exit 0
