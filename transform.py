#!/usr/bin/env python

from lxml import etree as ElementTree
import os


file_path = './sample_input/'

docs = os.listdir(file_path)


xml_file = file_path + docs[0]
xsl_file = './vendor/cdm_transformations/cdm2mets.xsl'

print xml_file

doc = ElementTree.parse(xml_file)

stylesheet = ElementTree.parse(xsl_file)

transform = ElementTree.XSLT(stylesheet) #currently this fails w/ lxml.etree.XSLTParseError: Invalid expression

newdoc = transform(doc)

print(ElementTree.tostring(newdoc, pretty_print=True))
