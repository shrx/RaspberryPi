#!/bin/bash

~/cronskripte/load.sh;
~/cronskripte/temp.sh;
~/cronskripte/bmp085-p.sh;
~/cronskripte/hh10d.sh;

~/cronskripte/napoved.py ~/stran/data/napoved-t.csv > ~/stran/data/zdej-t.csv;
~/cronskripte/napoved.py ~/stran/data/napoved-p.csv > ~/stran/data/zdej-p.csv;
echo $(tail -1 ~/stran/data/napoved-h.csv) > ~/stran/data/zdej-h.csv;
~/cronskripte/napoved-dp.sh;
~/cronskripte/napoved-hi.sh;

exit 0