#!/usr/bin/env python

'''After we have pulled down our images, we notice that some refer to .cpd files, 
which are xml files that give metadata for the images associated to compound cdm 
objects, we want to parse out that data to a more workable format like a .csv file'''


import os
import csv
from lxml import etree

_CPD_PATH = '../capsule/mcny_ephemera/cpd/'

def get_cpd_data(path):

	files = os.listdir(path)


	for f in files:
		
		resource = _CPD_PATH+f
	
		doc = etree.parse(resource)


		print '===', f, '===='


		for s in doc.xpath("//cpd/type"):
			print 'type:', s.text

		for t in doc.xpath("//cpd/page"):
			print 'part:', t.xpath('pagetitle')[0].text
			print 'id:', t.xpath('pageptr')[0].text
	


if __name__ == "__main__":

	get_cpd_data(_CPD_PATH)
	