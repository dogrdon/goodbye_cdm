#!/usr/bin/env python

'''After we have pulled down our images, we notice that some refer to .cpd files, 
which are xml files that give metadata for the images associated to compound cdm 
objects, we want to parse out that data to a more workable format like a .csv file'''


import os
import csv
from lxml import etree

doc = etree.parse("../capsule/mcny_ephemera/cpd/15.cpd")

for s in doc.xpath("//cpd/type"):
	print 'type:', s.text

for t in doc.xpath("//cpd/page"):
	print 'part:', t.xpath('pagetitle')[0].text
	print 'id:', t.xpath('pageptr')[0].text


	