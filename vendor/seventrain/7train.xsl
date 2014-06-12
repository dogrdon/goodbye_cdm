<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 	General:
 	The 7train transformation process is designed to produce METS objects from standardized XML files.  
 		This scenario was composed by Paul Fogel and Erik Hetzner at the California Digital Library (CDL) and 
 		is copyright the University of California Regents.
 		
 	Requirements:
 	7train requires the use of Saxon 8, as it is composed using XSL version 2.0.  It also requires that
 		2 working directories be created.  These directories are used for holding the data that 
 		a.) will be transformed and b.) saved as the result of the transformation.  These need to be 
 		named: "input" and "output" and need to be created at the same level as this stylesheet.  The 
 		"input" directory contains both exports to be transformed as well as map files used to associate data 
 		not included in the export.  The resulting METS output from the transformation will be saved in "output".
 		See InstallAndRun.txt for more information.
 	
 	Customization:
 	7train.xsl is the base stylesheet in the transformation and defines the basic elements and structure of a METS file.
 		Local installations can customize this process by creating a primary stylesheet that imports "7train.xsl" and 
 		overrides certain templates.  An example of this is provided in the distribution: "cdm.xsl."
 		See Customization.txt for more information and examples.
 -->
 <xsl:transform
    version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:seventrain="http://cdlib.org/7train/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:mets="http://www.loc.gov/METS/" 
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    exclude-result-prefixes="xsl seventrain">
  
  <xsl:import href="xwalker.xsl"/>
  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" indent="yes"/>

  <!-- Templates have mode names according to the following formula:
       -->
  <!-- * ‘element.attribute’ -->
  <!-- * ‘element-childElement’; -->
  <!-- * ‘element-childElement.attribute’ -->
  <!-- So, for example, if you wish to override default generation of
       the OBJID attribute of the toplevel mets element, make a
       template which matches your input document’s root object
       element with the mode mets. -->

  <!-- The $base-element contains the qualified name of the element
       which is to serve as the base element for each record which is
       transformed to METS. This is to say that for each instance of
       this element, a separate METS output file will be created.-->

  <xsl:function name="seventrain:generate-random-id" as="xs:string">
    <xsl:variable name="id-generator">
      <xsl:element name="seventrain:junk"/>
    </xsl:variable>
    <xsl:value-of select="generate-id($id-generator)"/>
  </xsl:function>

  <xsl:variable name="dc-xwalk" select="'****EMPTY****'"/>

  <!-- If the outputdir param is not passed in, it is output into the
       directory named "output." -->
  <xsl:param name="outputdir"
	    select="replace (base-uri(), '^file:/*(/.*/)?[^/]+$', '$1')"/>	

  <xsl:param name="translate-path" select="'no'"/>

  <!-- The root template begins the extraction process. -->
  <xsl:template match="/">
    <xsl:message><xsl:text>Finding </xsl:text> <xsl:value-of
    select="$base-element"/></xsl:message>
    <xsl:apply-templates select="//*[node-name(.)=$base-element]" mode="seventrain:mets"/>
  </xsl:template>
  
  <!-- This template MUST be overridden to generate the filename to
       which the record is writen. -->
  <xsl:template match="*[node-name(.)=$base-element]" mode="seventrain:output-filename">
    <xsl:message terminate="yes">
      <xsl:text>Stylesheet must override seventrain:output-filename.</xsl:text>
    </xsl:message>
  </xsl:template>

  <!-- This is the main template for generating a METS file. It should not be overridden. -->
  <xsl:template match="*[node-name(.)=$base-element]" mode="seventrain:mets">

    <!-- First we generate the output file name. -->
    <xsl:variable name="output-file">
      <xsl:apply-templates select="." mode="seventrain:output-filename"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$output-file eq ''">
	<xsl:message>
	  <xsl:text>Not outputting record.</xsl:text>
	</xsl:message>
      </xsl:when>
      <xsl:otherwise>
	<xsl:variable name="full-output-file">
	  <xsl:variable name="use-iri-to-uri"
			select="function-available('iri-to-uri')"/>
	  <xsl:choose>
	    <xsl:when test="$translate-path='yes'">
	      <!-- iri-to-uri is new -->
	      <xsl:value-of use-when="function-available('iri-to-uri')"
			    select="iri-to-uri(translate (concat('file:///', 
				    $outputdir , '/', $output-file),
				    '\', '/'))"/>
	      <xsl:if test="not($use-iri-to-uri)">
	      <xsl:value-of use-when="function-available('escape-uri')"
			    select="escape-uri(translate (concat('file:///', 
				    $outputdir , '/', $output-file),
				    '\', '/'),false())"/>
	      </xsl:if>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of use-when="function-available('iri-to-uri')"
			    select="iri-to-uri(concat('file:///', 
				    $outputdir , '/', $output-file))"/>
	      <xsl:if test="not($use-iri-to-uri)">
	      <xsl:value-of use-when="function-available('escape-uri')"
			    select="escape-uri(concat('file:///', 
				    $outputdir , '/', $output-file),false())"/>
	      </xsl:if>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>

	<xsl:message>
	  <xsl:text>Outputting to: </xsl:text>
	  <xsl:value-of select="$full-output-file"/>
	</xsl:message>
	
	<xsl:result-document href="{$full-output-file}">

	  <!-- The meat of 7train. Begins our mets file, calls each
	       template which may be overridden. -->
	  <mets:mets>
	    <xsl:attribute name="xsi:schemaLocation">http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd</xsl:attribute>
	    <xsl:variable name="OBJID-value">
	      <xsl:apply-templates select="." mode="seventrain:mets.OBJID"/>
	    </xsl:variable>
	    <xsl:if test="string-length($OBJID-value) > 0">
	      <xsl:attribute name="OBJID">
		<xsl:value-of select="$OBJID-value"/>
	      </xsl:attribute>
	    </xsl:if>

	    <!-- xsl:attribute name="ID">
		 <xsl:apply-templates select="." mode="seventrain:mets.ID"/>
		 </xsl:attribute -->

	    <xsl:variable name="LABEL-value">
	      <xsl:apply-templates select="." mode="seventrain:mets.LABEL"/>
	    </xsl:variable>
	    <xsl:if test="string-length($LABEL-value) > 0">
	      <xsl:attribute name="LABEL">
		<xsl:value-of select="$LABEL-value"/>
	      </xsl:attribute>
	    </xsl:if>

	    <xsl:variable name="TYPE-value">
	      <xsl:apply-templates select="." mode="seventrain:mets.TYPE"/>
	    </xsl:variable>
	    <xsl:if test="string-length($TYPE-value) > 0">
	      <xsl:attribute name="TYPE">
		<xsl:value-of select="$TYPE-value"/>
	      </xsl:attribute>
	    </xsl:if>

	    <xsl:variable name="PROFILE-value">
	      <xsl:apply-templates select="." mode="seventrain:mets.PROFILE"/>
	    </xsl:variable>
	    <xsl:if test="string-length($PROFILE-value) > 0">
	      <xsl:attribute name="PROFILE">
		<xsl:value-of select="$PROFILE-value"/>
	      </xsl:attribute>
	    </xsl:if>
	    
	    <!-- Now generate each of the parts of the METS file in
	         order. It is the author's responsibility to be
	         certain that non repeatable elements are not
	         repeatable. -->
	    <xsl:apply-templates select="." mode="seventrain:mets-metsHdr"/>
	    <xsl:apply-templates select="." mode="seventrain:mets-dmdSec"/>
	    <xsl:apply-templates select="." mode="seventrain:mets-amdSec"/>
	    <xsl:apply-templates select="." mode="seventrain:mets-fileSec"/>
	    <xsl:apply-templates select="." mode="seventrain:mets-structMap"/>
	  </mets:mets>
	</xsl:result-document>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Override this template to change the OBJID attribute of the <mets>
       element. -->
  <xsl:template match="*[node-name(.)=$base-element]" mode="seventrain:mets.OBJID"/>


  <!-- Override this template to change the ID attribute of the <mets>
       element. -->
  <xsl:template match="*[node-name(.)=$base-element]" mode="seventrain:mets.ID">
    <xsl:value-of select="seventrain:generate-random-id()"/>
  </xsl:template>

  <!-- Override this template to change the LABEL attribute of the <mets>
       element. -->
  <xsl:template match="*[node-name(.)=$base-element]" mode="seventrain:mets.LABEL"/>

  <!-- Override this template to change the TYPE attribute of the <mets>
       element. -->
  <xsl:template match="*[node-name(.)=$base-element]" mode="seventrain:mets.TYPE"/>

  <!-- Override this template to change the PROFILE attribute of the <mets>
       element. -->
  <xsl:template match="*[node-name(.)=$base-element]" 
		mode="seventrain:mets.PROFILE"/>

  <!-- This template generates the metsHdr section. You shouldn't need
       to override this template, just it's children.-->
  <xsl:template match="*[node-name(.)=$base-element]" 
		mode="seventrain:mets-metsHdr">
    <mets:metsHdr>
      <xsl:attribute name="CREATEDATE">
	<xsl:apply-templates select="." mode="seventrain:mets-metsHdr.CREATEDATE"/>
      </xsl:attribute>
      <xsl:attribute name="LASTMODDATE">
	<xsl:apply-templates select="." 
			     mode="seventrain:mets-metsHdr.LASTMODDATE"/>
      </xsl:attribute>
      <xsl:attribute name="RECORDSTATUS">
	<xsl:apply-templates select="." 
			     mode="seventrain:mets-metsHdr.RECORDSTATUS"/>
      </xsl:attribute>
      <xsl:attribute name="ID">
	<xsl:apply-templates select="." mode="seventrain:mets-metsHdr.ID"/>
      </xsl:attribute>
      <xsl:apply-templates select="." mode="seventrain:mets-metsHdr-agent"/>
      <xsl:apply-templates select="."
			   mode="seventrain:mets-metsHdr-altRecordID"/>
    </mets:metsHdr>
  </xsl:template>

  <!-- Override this template to change the ID attribute of the
       <metsHdr>. -->
  <xsl:template match="*[node-name(.)=$base-element]" 
		mode="seventrain:mets-metsHdr.ID">
    <xsl:value-of select="seventrain:generate-random-id()"/>
  </xsl:template>

  <!-- Override this template to change the CREATEDATE attribute of the
       <metsHdr>. -->
  <xsl:template match="*[node-name(.)=$base-element]" 
		mode="seventrain:mets-metsHdr.CREATEDATE">
    <xsl:value-of select="current-dateTime()"/>
  </xsl:template>

  <!-- Override this template to change the LASTMODDATE attribute of
       the <metsHdr>. -->
  <xsl:template match="*[node-name(.)=$base-element]" 
		mode="seventrain:mets-metsHdr.LASTMODDATE">
    <xsl:value-of select="current-dateTime()"/>
  </xsl:template>

  <!-- Override this template to change the RECORDSTATUS attribute of
       the <metsHdr>. -->
  <xsl:template match="*[node-name(.)=$base-element]" 
		mode="seventrain:mets-metsHdr.RECORDSTATUS">
    <xsl:text>NEW</xsl:text>
  </xsl:template>

  <!-- Override this template to change the <altRecordId> element of
       the <metsHdr>. -->
  <xsl:template match="*[node-name(.)=$base-element]" 
		mode="seventrain:mets-metsHdr-altRecordID"/>

  <!-- Override this template to change the <agent> element of the
       <metsHdr>. -->
  <xsl:template match="*[node-name(.)=$base-element]" 
		mode="seventrain:mets-metsHdr-agent"/>
  
  <!-- Override this template to generate your <dmdSec>. -->
  <xsl:template match="*[node-name(.)=$base-element]" 
		mode="seventrain:mets-dmdSec"/>

  <!-- Override this template to generate your <amdSec>. -->
  <xsl:template match="*[node-name(.)=$base-element]" 
		mode="seventrain:mets-amdSec"/>
  
  <!-- Override this template to generate your <fileSec>. -->
  <xsl:template match="*[node-name(.)=$base-element]" 
		mode="seventrain:mets-fileSec"/>

  <!-- Override this template to change the structMap of the METS
       file. One would almost certainly want to override this
       template. -->
  <xsl:template match="*[node-name(.)=$base-element]" 
		mode="seventrain:mets-structMap">
    <mets:structMap>
      <mets:div/>
    </mets:structMap>
  </xsl:template>
  
  <!-- By default we don't want to pass through just any text which we
       encounter. -->
  <xsl:template match="text()"/>
  
</xsl:transform>
