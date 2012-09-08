#!/bin/bash

hexraw=$(i2cget -y 0 0x48 0x00 w)
echo $hexraw

msb=$(echo ${hexraw:4:2})
lsb=$(echo ${hexraw:2:1})
dec=$(printf "%d\n" "0x$msb$lsb")

echo "scale=4; $dec*0.0625" | bc