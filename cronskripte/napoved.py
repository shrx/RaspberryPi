#!/usr/bin/env python
# -*- coding: UTF-8 -*-
from __future__ import print_function
import csv
import sys
from funkcije import mean, flatten#, quantile

# f = open(sys.argv[1], 'rt')
# mycsv = csv.reader(f)
# mycsv.next()
# mycsvlist = list(mycsv)
#
# f.close()
#
# val = []
# for row in mycsvlist:
# 	val.append(float(row[1]))
# mycsvlist = val
#
# q0 = quantile(mycsvlist, 0.1)

f = open(sys.argv[1], 'r')		# f = open(sys.argv[2], 'rt')
mycsv = csv.reader(f)
mycsvlist = list(mycsv)

f.close()

val = []
for row in mycsvlist:
	val.append(float(row[-1]))
mycsvlist = val

zadnja = mycsvlist[-1]
if (sys.argv[1] == "/home/pi/stran/data/napoved-p.csv"):
	q1 = 20			# spremembe vrednosti senzorjev
	q3 = 60
	q0 = 10 #234.569				# mathematica: delta-x.csv
	zadnja = zadnja/1000
elif (sys.argv[1] == "/home/pi/stran/data/napoved-t.csv"):
	q1 = 0.1 + 0.1
	q3 = 0.4 + 0.1
	q0 = 0.1 #0.4

# delta = 0
# for i in range(0, len(mycsvlist)-2):
# 	delta = delta + abs(mycsvlist[i]-mycsvlist[i+1])

h1 = mean(mycsvlist[:5])
zdej = mean(mycsvlist[-5:])
raz = zdej - h1
delta = abs(raz)

# print(h1)
# print(zdej)
# print(raz)
# print(delta)

if (delta <= q0):
	kako = ", stabilno"
elif (delta < q1):
	kako = ", počasi"
elif (delta > q3):
	kako = ", hitro"
else:
	kako = ","

if (delta < q0):
	kaj = ""
elif (raz < 0):
	kaj = " pada"
else:
	kaj = " raste"

print("%.2f" % zadnja,kako,kaj,sep=",")
