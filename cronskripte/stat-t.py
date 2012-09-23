#!/usr/bin/env python
# -*- coding: UTF-8 -*-
from __future__ import print_function
import csv
import sys
import itertools
import operator
from funkcije import *

f = open(sys.argv[1], 'rt')
mycsv = csv.reader(f)
mycsv.next()
mycsvlist = list(mycsv)

val = []
for row in mycsvlist[1988:]:
	if len(row) == 3:
		if row[2]:
			val.append([row[0],float(row[2])])
mycsvlist = val

# abs

max = sorted(mycsvlist,key=operator.itemgetter(1))[-1]
min = sorted(mycsvlist,key=operator.itemgetter(1))[0]

x1 = []
for row in mycsvlist:
	x1.append([ row[0].split(" ",1)[0], row[1] ])
x2 = [list(group) for key,group in itertools.groupby(x1,operator.itemgetter(0))][1:-1]

x3 = []
for row in x2:
	sort = sorted(row,key=operator.itemgetter(-1))
	x3.append([ row[0][0], sort[-1][1]-sort[0][1] ])
x4 = sorted(x3,key=operator.itemgetter(-1))[-1]

print("abs")
print(max[0],"%.2f" % max[1],sep=",")
print(min[0],"%.2f" % min[1],sep=",")
print(x4[0],"%.2f" % x4[1],sep=",")

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
x3 = []
for row in x2:
	x3.append(meanByHour(row)) # meanByHour
x4 = [list(group) for key,group in itertools.groupby(x3,operator.itemgetter(0))] # splitby[hour]

min = []
for row in x4:
	min.append(sorted(row,key=operator.itemgetter(-1))[0][1])

min1 = zip(min,map(min.count,min)) # tally
min2 = sorted(min1,key=operator.itemgetter(-1))[-1][0] #sortBy[last]

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

	x1.append([ row[0].split(" ",1)[0], int(part[0]), int(part[1]), row[1] ])
	i = i+j

x2 = [list(group) for key,group in itertools.groupby(x1,operator.itemgetter(-3))][1:-1]
x3 = []
for row in x2:
	x3.append(meanByHour(row))
x4 = sorted(x3,key=operator.itemgetter(0))
x5 = [list(group) for key,group in itertools.groupby(x4,operator.itemgetter(0))]
x6 = []
for row in x5:
	x6.append([row[0][0],"%.2f" % mean(column(row,-1))])

csvExport("/home/pi/stran/data/"+str(sys.argv[1]).split("/")[-1].split(".")[0]+"-d.csv",x6)
print("dnevi")
result(x6)

# meseci

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

	x1.append([ int(row[0].split("/",2)[1]), int(part[0]), int(part[1]), row[1] ])
	i = i+j

x2 = [list(group) for key,group in itertools.groupby(x1,operator.itemgetter(-3))][1:-1]
x3 = []
for row in x2:
	x3.append(meanByHour(row))
x4 = sorted(x3,key=operator.itemgetter(0))
x5 = [list(group) for key,group in itertools.groupby(x4,operator.itemgetter(0))]
x6 = []
for row in x5:
	x6.append([row[0][0],"%.2f" % mean(column(row,-1))])

csvExport("/home/pi/stran/data/"+str(sys.argv[1]).split("/")[-1].split(".")[0]+"-m.csv",x6)
print("meseci")
result(x6)

# leta

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

	x1.append([ int(row[0].split("/",1)[0]), int(part[0]), int(part[1]), row[1] ])
	i = i+j

x2 = [list(group) for key,group in itertools.groupby(x1,operator.itemgetter(-3))][1:-1]
x3 = []
for row in x2:
	x3.append(meanByHour(row))
x4 = sorted(x3,key=operator.itemgetter(0))
x5 = [list(group) for key,group in itertools.groupby(x4,operator.itemgetter(0))]
x6 = []
for row in x5:
	x6.append([row[0][0],"%.2f" % mean(column(row,-1))])

csvExport("/home/pi/stran/data/"+str(sys.argv[1]).split("/")[-1].split(".")[0]+"-y.csv",x6)
print("leta")
result(x6)

f.close()
