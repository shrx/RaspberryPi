from __future__ import print_function
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

def meanByHour(x):
	if x[0][-2] != 0:
		x.insert(0, flatten([ x[0][:-2], [0], [x[0][-1]] ]))
	i = 1
	while (i < len(x)-1):
		if x[i][-2] != i*5:
			x.insert(i, flatten([ x[i-1][:-2], [i*5], [x[i-1][-1]] ]))
		i = i+1
	last = x[-1][-2]
	if last != 55:
		table = []
		while (last < 55):
			last = last+5
			table.append(flatten([ x[-1][:-2], [last], [x[-1][-1]] ]))
		x = x + table
	return [ x[0][0], x[0][1], mean(column(x,-1)) ]

def result(x6):
	max = sorted(x6,key=operator.itemgetter(1))[-1]
	min = sorted(x6,key=operator.itemgetter(1))[0]
	print(max[0],"%.2f" % max[1],sep=",")
	print(min[0],"%.2f" % min[1],sep=",")

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


