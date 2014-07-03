#!/usr/bin/env python

import urllib
import os
import csv

'''Those pesky contentdm images have been lost and you just want to grab them off the server...well their shruken derivatives that is, just so you can develop. This will go through a processed set of records exported from cdm and get their images from off the server, that's all'''


path_to_csv = "../capsule/mcny_ephemera/metadata/" #hardwired for now
csv_file = "nymc_ephemera_cdm-ref-processed.csv"
image_path = "../capsule/mcny_ephemera/images/"


_FILE = path_to_csv + csv_file



with open(_FILE, 'rb') as f:
	r = csv.reader(f)

	r.next()

	for row in r:

		image_dest = image_path + row[3]

		urllib.urlretrieve(row[1], image_dest)
			
