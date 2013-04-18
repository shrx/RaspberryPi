from __future__ import print_function
import csv
import itertools
import operator
from math import modf, floor

def column(matrix, i):
    return [row[i] for row in matrix]

def mean(numberList):
	if len(numberList):
		return float(sum(numberList)) / len(numberList)
	else:
		return 0.0

def flatten(x):
	return [item for sublist in x for item in sublist]

def meanByHour(list):
	y = list
	h1 = y[1][0][-3]
	hi = 1
	while hi < len(y):
		if (y[hi][0][-3] - h1) % 24 != 1:
			y.insert(hi, [[ y[hi-1][-1][0], (y[hi-1][-1][-3] + 1) % 24, 0, y[hi-1][-1][-1] ]] )
		h1 = y[hi][0][-3]
		hi = hi+1

	mblist = []
	for x in y:
		if x[0][-2] != 0:
			x.insert(0, flatten([ x[0][:-2], [0], [x[0][-1]] ]))
		i = 1
		while (i < len(x)-1):
			if x[i][-2] != i*5:
				x.insert(i, flatten([ x[i-1][:-2], [i*5], [x[i-1][-1]] ]))
			i = i+1
			if 	i == 11:
				break
		last = x[-1][-2]
		if last != 55:
			table = []
			while (last < 55):
				last = last+5
				table.append(flatten([ x[-1][:-2], [last], [x[-1][-1]] ]))
			x = x + table
		mblist.append([ x[0][0], x[0][1], mean(column(x,-1)) ])
	return mblist

def result(x6,absMax,absMin):
	max = sorted(x6,key=operator.itemgetter(1))
	max = [list(group) for key,group in itertools.groupby(max,operator.itemgetter(1))][-1][0]
	min = sorted(x6,key=operator.itemgetter(1))
	min = [list(group) for key,group in itertools.groupby(min,operator.itemgetter(1))][0][0]
	if max[1] > absMax[1]+0.004 or max[0] == absMax[0]:
		print(max[0],"%.2f" % max[1],sep=",")
	else:
		print(absMax[0],"%.2f" % absMax[1],sep=",")
	if min[1] < absMin[1]-0.004 or min[0] == absMin[0]:
		print(min[0],"%.2f" % min[1],sep=",")
	else:
		print(absMin[0],"%.2f" % absMin[1],sep=",")

def resultAbs(x6):
	max = sorted(x6,key=operator.itemgetter(1))
	max = [list(group) for key,group in itertools.groupby(max,operator.itemgetter(1))][-1][0]
	min = sorted(x6,key=operator.itemgetter(1))
	min = [list(group) for key,group in itertools.groupby(min,operator.itemgetter(1))][0][0]
	print(max[0],"%.2f" % max[1],sep=",")
	print(min[0],"%.2f" % min[1],sep=",")

def csvExport(file,data):
	with open(file, 'w') as csvfile:
		datawriter = csv.writer(csvfile, delimiter=',',
								quotechar='"', quoting=csv.QUOTE_MINIMAL)
		datawriter.writerow(["date","value"])
		datawriter.writerows(data)

"""
File    quantile.py
Desc    computes sample quantiles
Author  Ernesto P. Adorio, PhD.
        UPDEPP (U.P. at Clarkfield)
Version 0.0.1 August 7. 2009
"""

def quantile(x, q,  qtype = 7, issorted = False):
    """
    Args:
       x - input data
       q - quantile
       qtype - algorithm
       issorted- True if x already sorted.

    Compute quantiles from input array x given q.For median,
    specify q=0.5.

    References:
       http://reference.wolfram.com/mathematica/ref/Quantile.html
       http://wiki.r-project.org/rwiki/doku.php?id=rdoc:stats:quantile

    Author:
	Ernesto P.Adorio Ph.D.
	UP Extension Program in Pampanga, Clark Field.
    """
    if not issorted:
        y = sorted(x)
    else:
        y = x
    if not (1 <= qtype <= 9):
       return None  # error!

    # Parameters for the Hyndman and Fan algorithm
    abcd = [(0,   0, 1, 0), # inverse empirical distrib.function., R type 1
            (0.5, 0, 1, 0), # similar to type 1, averaged, R type 2
            (0.5, 0, 0, 0), # nearest order statistic,(SAS) R type 3

            (0,   0, 0, 1), # California linear interpolation, R type 4
            (0.5, 0, 0, 1), # hydrologists method, R type 5
            (0,   1, 0, 1), # mean-based estimate(Weibull method), (SPSS,Minitab), type 6
            (1,  -1, 0, 1), # mode-based method,(S, S-Plus), R type 7
            (1.0/3, 1.0/3, 0, 1), # median-unbiased ,  R type 8
            (3/8.0, 0.25, 0, 1)   # normal-unbiased, R type 9.
           ]

    a, b, c, d = abcd[qtype-1]
    n = len(x)
    g, j = modf( a + (n+b) * q -1)
    if j < 0:
        return y[0]
    elif j >= n:
        return y[n-1]   # oct. 8, 2010 y[n]???!! uncaught  off by 1 error!!!

    j = int(floor(j))
    if g ==  0:
       return y[j]
    else:
       return y[j] + (y[j+1]- y[j])* (c + d * g)


