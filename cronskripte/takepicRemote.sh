#!/bin/bash

d=$(date +"%m.%d.%y-%H.%M.%S")
bannerWidth=1650
bannerHeight=$((1944*$bannerWidth/2592))
pipe=/home/pi2/mmpipe

ssh pi2@pi2 <<-EOF
	raspistill -vf -hf -o pic-$d.jpg
	raspistill -vf -hf -o banner.jpg -w $bannerWidth -h $bannerHeight
	#/usr/bin/wolfram -script /home/pi2/mathematica/bannercrop.m &> /dev/null
	echo "<</home/pi2/mathematica/bannercropQuiet.m">$pipe
	exit
EOF

rsync -e ssh pi2@pi2:/home/pi2/pic-$d.jpg :/home/pi2/mala.jpg :/home/pi2/banner.jpg ~/slike/
# :/home/pi/rgb.png :/home/pi/hsv.png :/home/pi/xyz.png

ssh pi2@pi2 <<-EOF
	rm pic-$d.jpg
#	rm banner.jpg
#	rm mala.jpg
#	rm rgb.png
#	rm hsv.png
#	rm xyz.png
	exit
EOF

exit
