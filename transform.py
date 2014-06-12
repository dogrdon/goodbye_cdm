#!/usr/bin/env python

from lxml import etree as ElementTree
import os

docs = os.listdir('./sample_input')


xml_file = docs[0]
xsl_file = './vendor/seventrain/cdm.xsl'

doc = ElementTree.parse(xml_file)

stylesheet = ElementTree.parse(xsl_file)

transform = ElementTree.xslt(stylesheet)

newdoc = transform(doc)

print(ElementTree.tostring(newdoc, pretty_print=True))
