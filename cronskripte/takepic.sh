#!/bin/bash

#ura=$(date +"%H")
#if [ $ura -ge 5 -a $ura -le 23 ]; then
	/home/pi/cronskripte/takepicRemote.sh &> /dev/null

	cd /home/pi/slike/
	mv banner.jpg /home/pi/stran/slike/
	mv mala.jpg /home/pi/stran/slike/
#	mv rgb.png /home/pi/stran/slike/
#	mv hsv.png /home/pi/stran/slike/
#	mv xyz.png /home/pi/stran/slike/
	newpic=$(ls -tc | head -1)
	/usr/local/bin/dropbox_uploader upload $newpic rpislike/$newpic &> /dev/null

	npics=$(ls -1 | wc -l)
	if [ $npics -gt 10 ]; then
		lastpic=$(ls -tc | tail -1)
		rm $lastpic
	fi
#fi
