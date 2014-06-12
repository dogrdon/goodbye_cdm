<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
    version="2.0"
    xmlns:seventrain="http://cdlib.org/7train/"
    xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" 
    xmlns:nsdl_dc="http://ns.nsdl.org/nsdl_dc_v1.02/"
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:mets="http://www.loc.gov/METS/" 
    xmlns:xw="http://cdlib.org/example"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
   exclude-result-prefixes="xsl xw oai_dc xsi seventrain nsdl_dc oai">

  <xsl:import href="../7train.xsl"/>
  
  <xsl:variable name="base-element" select="QName('http://www.openarchives.org/OAI/2.0/','record')"/>

  <xsl:template match="oai:record" mode="seventrain:output-filename">
    <xsl:text>oai_</xsl:text><xsl:value-of select="translate(oai:header/oai:identifier,'/','_')"/>
  </xsl:template>

  <xsl:template match="oai:record" mode="seventrain:mets-metsHdr-agent">
    <mets:agent
	ROLE="EDITOR" 
	TYPE="ORGANIZATION">
      <mets:name>California Digital Library</mets:name>
    </mets:agent>
  </xsl:template>

  <xsl:template match="oai:record" mode="seventrain:mets-dmdSec">
    <mets:dmdSec ID="DC">
      <mets:mdWrap MIMETYPE="text/xml" MDTYPE="DC" LABEL="DC">    
	<mets:xmlData>
	  <xsl:copy-of copy-namespaces="no"
	      select="oai:metadata/oai_dc:dc/dc:* | oai:metadata/nsdl_dc:nsdl_dc/dc:*"/>
	  </mets:xmlData>
      </mets:mdWrap>
    </mets:dmdSec>
  </xsl:template>

  <xsl:template match="oai:record" mode="seventrain:mets.OBJID">
    <xsl:value-of select="oai:header/oai:identifier"/>
  </xsl:template>
  
  <xsl:template match="oai:record" mode="seventrain:mets-fileSec">
    <xsl:variable name="url">
      <xsl:value-of select="replace (oai:header/oai:identifier, 
			    '^oai:(.*)$', 'http://$1/')"/>
    </xsl:variable>

    <mets:fileSec ID="{seventrain:generate-random-id()}">
      <mets:fileGrp>
	<mets:file ID="{generate-id()}">
	  <mets:FLocat LOCTYPE="DOI" xlink:href="{oai:header/oai:identifier}"/>
	  <mets:FLocat LOCTYPE="URL" xlink:href="{$url}"/>
	</mets:file>
      </mets:fileGrp>
    </mets:fileSec>
  </xsl:template>

  <xsl:template match="oai:record"
		mode="seventrain:mets-structMap">
    <mets:structMap
	ID="{seventrain:generate-random-id()}" >
      <mets:div ID="{seventrain:generate-random-id()}">
	<mets:fptr ID="{seventrain:generate-random-id()}" FILEID="{generate-id()}"/>
      </mets:div>
    </mets:structMap>
  </xsl:template>

</xsl:transform>
