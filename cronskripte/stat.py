#!/usr/bin/env python
# -*- coding: UTF-8 -*-
from __future__ import print_function
import csv
import sys
import itertools
import operator
from funkcije import *
import datetime
from calendar import monthrange

now = datetime.datetime.now()
yesterday = now - datetime.timedelta(days=1)
daysInMonth=monthrange(yesterday.year, yesterday.month)[1]

f = open(sys.argv[1], 'rt')
mycsv = csv.reader(f)
mycsv.next()
mycsvlist = list(mycsv)
f.close()

val = []
for row in mycsvlist:
	val.append([row[0],float(row[1].split("#")[0])])
mycsvlist = val

if str(sys.argv[1]).split("/")[-1] == "bmp085-p.csv":
	statFile="stat-p.csv"
else:
	statFile="stat-h.csv"

f = open("/home/pi/stran/data/"+statFile, 'r')
statCsv = csv.reader(f)
statCsvList = list(statCsv)
f.close()

absMax=[statCsvList[1][0],float(statCsvList[1][1])]
absMin=[statCsvList[2][0],float(statCsvList[2][1])]
deltaMax=[statCsvList[3][0],float(statCsvList[3][1])]
dayMax=[statCsvList[8][0],float(statCsvList[8][1])]
dayMin=[statCsvList[9][0],float(statCsvList[9][1])]
monthMax=[statCsvList[11][0],float(statCsvList[11][1])]
monthMin=[statCsvList[12][0],float(statCsvList[12][1])]
yearMax=[statCsvList[14][0],float(statCsvList[14][1])]
yearMin=[statCsvList[15][0],float(statCsvList[15][1])]

# print(absMax)
# print(absMin)
# print(deltaMax)
# print(dayMax)
# print(dayMin)
# print(monthMax)
# print(monthMin)

# abs

max = sorted(mycsvlist[-301:],key=operator.itemgetter(1))	# s prestopno uro = 25 ur * 12 meritev na uro = 300 meritev
max = [list(group) for key,group in itertools.groupby(max,operator.itemgetter(1))][-1][0]
min = sorted(mycsvlist[-301:],key=operator.itemgetter(1))
min = [list(group) for key,group in itertools.groupby(min,operator.itemgetter(1))][0][0]

x1 = []

# if str(sys.argv[1]).split("/")[-1].split(".")[0] == "dht22":
# 	for row in mycsvlist:
# 		dda=row[0].split(" ",1)[0]
# 		dd=(int(dda.split("/")[0]),int(dda.split("/")[1]),int(dda.split("/")[2]))
# 		if (2013,1,10) <= dd <= (2013,1,31):
# 			pass
# 		else:
#  			x1.append([ row[0].split(" ",1)[0], row[1] ])
# else:
for row in mycsvlist[-601:]:		# cel prejšnji dan
	if (now.day - int(row[0].split(" ",1)[0].split("/")[-1])) % daysInMonth == 1:
		x1.append([ row[0].split(" ",1)[0], row[1] ])

x2 = [list(group) for key,group in itertools.groupby(x1,operator.itemgetter(0))]

x3 = []
for row in x2:
	sort = sorted(row,key=operator.itemgetter(-1))
	x3.append([ row[0][0], sort[-1][1]-sort[0][1] ])
x4 = sorted(x3,key=operator.itemgetter(-1))
x4 = [list(group) for key,group in itertools.groupby(x4,operator.itemgetter(1))][-1][0]

print("abs")
if max[1] > absMax[1]:
	print(max[0],"%.2f" % max[1],sep=",")
else:
	print(absMax[0],"%.2f" % absMax[1],sep=",")
if min[1] < absMin[1]:
	print(min[0],"%.2f" % min[1],sep=",")
else:
	print(absMin[0],"%.2f" % absMin[1],sep=",")
if x4[1] > deltaMax[1]:
	print(x4[0],"%.2f" % x4[1],sep=",")
else:
	print(deltaMax[0],"%.2f" % deltaMax[1],sep=",")

# ure

x1 = []
i = 0
for row in mycsvlist:
	j = 1
	part = row[0].split(" ",1)[1].split(":",2)

	if i != 0:
		lastHour = x1[i-1][1]
		hour = int(part[0])
		if hour == 0 and lastHour == 23:
			hour = 24

		while lastHour < hour-1:
			lastHour = lastHour+1
			x1.append([ x1[i-1][0], lastHour, 0, x1[i-1][-1] ])
			j = j+1

	x1.append([ int(row[0].split(" ",1)[0].split("/",2)[-1]), int(part[0]), int(part[1]), row[1] ])
	i = i+j

x2 = [list(group) for key,group in itertools.groupby(x1,operator.itemgetter(-3))][1:-1]
x3 = meanByHour(x2)
x4 = [list(group) for key,group in itertools.groupby(x3,operator.itemgetter(0))]

min = []
for row in x4:
	min.append(sorted(row,key=operator.itemgetter(-1))[0][1])
min1 = zip(min,map(min.count,min))
min2 = sorted(min1,key=operator.itemgetter(-1))[-1][0]

max = []
for row in x4:
	max.append(sorted(row,key=operator.itemgetter(-1))[-1][1])
max1 = zip(max,map(max.count,max))
max2 = sorted(max1,key=operator.itemgetter(-1))[-1][0]

print("ure")
print(max2)
print(min2)

# dnevi

x1 = []
i = 0
for row in mycsvlist[-601:]:
	if (now.day - int(row[0].split(" ",1)[0].split("/")[-1])) % daysInMonth == 1:
		j = 1
		part = row[0].split(" ",1)[1].split(":",2)

		if i != 0:
			lastHour = x1[i-1][1]
			hour = int(part[0])
			if hour == 0 and lastHour == 23:
				hour = 24

			while lastHour < hour-1:
				lastHour = lastHour+1
				x1.append([ x1[i-1][0], lastHour, 0, x1[i-1][-1] ])
				j = j+1

		x1.append([ row[0].split(" ",1)[0], int(part[0]), int(part[1]), row[1] ])
		i = i+j
x2 = [list(group) for key,group in itertools.groupby(x1,operator.itemgetter(-3))]
x2 = [list(group) for key,group in itertools.groupby(x1,operator.itemgetter(-3))][1:-1]
x3 = meanByHour(x2)
x4 = sorted(x3,key=operator.itemgetter(0))
x5 = [list(group) for key,group in itertools.groupby(x4,operator.itemgetter(0))]
x6 = []
for row in x5:
	x6.append([row[0][0],mean(column(row,-1))])
# x7= []
# for row in x6:
# 	x7.append([row[0],"%.2f" % row[1]])
#
#csvExport("/home/pi/stran/data/"+str(sys.argv[1]).split("/")[-1].split(".")[0]+"-d.csv",x7)
print("dnevi")
result(x6,dayMax,dayMin)

# meseci

if now.day == 1:
	x1 = []
	i = 0
	for row in mycsvlist[-18150:]:		# (31*2) * 24 * 12 + 24 * 12 = 18150 meritev (cel prejšnji mesec + prestopna ura)
		if (now.month - int(row[0].split("/",2)[1])) % 12 == 1:
			j = 1
			part = row[0].split(" ",1)[1].split(":",2)

			if i != 0:
				lastHour = x1[i-1][1]
				hour = int(part[0])
				if hour == 0 and lastHour == 23:
					hour = 24

				while lastHour < hour-1:
					lastHour = lastHour+1
					x1.append([ x1[i-1][0], lastHour, 0, x1[i-1][-1] ])
					j = j+1

			x1.append([ int(row[0].split("/",2)[1]), int(part[0]), int(part[1]), row[1] ])
			i = i+j
	x2 = [list(group) for key,group in itertools.groupby(x1,operator.itemgetter(-3))]
	x2 = [list(group) for key,group in itertools.groupby(x1,operator.itemgetter(-3))][1:-1]
	x3 = meanByHour(x2)
	x4 = sorted(x3,key=operator.itemgetter(0))
	x5 = [list(group) for key,group in itertools.groupby(x4,operator.itemgetter(0))]
	x6 = []
	for row in x5:
		x6.append([row[0][0],mean(column(row,-1))])
	#x7= []
	# for row in x6:
	# 	x7.append([row[0],"%.2f" % row[1]])
	#
	# csvExport("/home/pi/stran/data/"+str(sys.argv[1]).split("/")[-1].split(".")[0]+"-m.csv",x7)
	print("meseci")
	result(x6,monthMax,monthMin)

# leta

if now.month == 1 and now.day == 1:
	x1 = []
	i = 0
	for row in mycsvlist:
		if now.year - int(row[0].split("/",1)[0]) == 0:
			j = 1
			part = row[0].split(" ",1)[1].split(":",2)

			if i != 0:
				lastHour = x1[i-1][1]
				hour = int(part[0])
				if hour == 0 and lastHour == 23:
					hour = 24

				while lastHour < hour-1:
					lastHour = lastHour+1
					x1.append([ x1[i-1][0], lastHour, 0, x1[i-1][-1] ])
					j = j+1

			x1.append([ int(row[0].split("/",1)[0]), int(part[0]), int(part[1]), row[1] ])
			i = i+j

	x2 = [list(group) for key,group in itertools.groupby(x1,operator.itemgetter(-3))]
	x2 = [list(group) for key,group in itertools.groupby(x1,operator.itemgetter(-3))][1:-1]
	x3 = meanByHour(x2)
	x4 = sorted(x3,key=operator.itemgetter(0))
	x5 = [list(group) for key,group in itertools.groupby(x4,operator.itemgetter(0))]
	x6 = []
	for row in x5:
		x6.append([row[0][0],mean(column(row,-1))])
	# x7= []
	# for row in x6:
	# 	x7.append([row[0],"%.2f" % row[1]])
	#
	# csvExport("/home/pi/stran/data/"+str(sys.argv[1]).split("/")[-1].split(".")[0]+"-y.csv",x7)
	print("leta")
	result(x6,yearMax,yearMin)