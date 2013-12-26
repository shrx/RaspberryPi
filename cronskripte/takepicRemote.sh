#!/bin/bash

d=$(date +"%m.%d.%y-%H.%M.%S")
bannerWidth=1650
bannerHeight=$((1944*$bannerWidth/2592))

ssh pi@pi2 <<-EOF
	raspistill -o pic-$d.jpg
	raspistill -o banner.jpg -w $bannerWidth -h $bannerHeight
	/opt/Wolfram/Mathematica/10.0/Executables/Linux-ARM/math -script /home/pi/mathematica/bannercrop.m &> /dev/null
	exit
EOF

rsync -e ssh pi@pi2:/home/pi/pic-$d.jpg :/home/pi/mala.jpg :/home/pi/banner.jpg ~/slike/
# :/home/pi/rgb.png :/home/pi/hsv.png :/home/pi/xyz.png

ssh pi@pi2 <<-EOF
	rm pic-$d.jpg
#	rm banner.jpg
#	rm mala.jpg
#	rm rgb.png
#	rm hsv.png
#	rm xyz.png
	exit
EOF

exit
