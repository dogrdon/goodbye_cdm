###data and data processing explanation for MCNY Ephemera

####About this collection
The New York Milk Committee Ephemera Collection contains materials issued between 1910 and 1917 or 1918 by the New York Milk Committee and its Committee for the Reduction of Infant Mortality, dealing with their work in the Blue Front milk stations in New York City where they distributed milk and educated mothers. Currently it can be found [here](http://cdm16268.contentdm.oclc.org/cdm/landingpage/collection/p4129coll7)

#####in this file
* MCNY\_ephemera\_custom-xml-processed.csv
* 

####MCNY\_ephemera\_custom-xml-processed

This is a processed version of the custom xml export from contentdm 6.8. The options selected were that repeated fields would be combined into one element. 

This file was brought into Google Refine and the `relation` column was used to create a column called `related_to` as we have compound objects and we want to be able to match this column 1-to-1 with the `identifier` column by having both fields expressed as a .jpg file as the `relation` column was expressed in a string like 'back of mke10122.jpg' and we only wanted 'mke10122.jpg'

There are 126 records

Of which 67 are compound objects (with more than one page)



