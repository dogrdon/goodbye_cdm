<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform
    version="2.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:seventrain="http://cdlib.org/7train/">

  <xsl:param name="xwalk"/>
  
  <!-- This template transforms metadata from one xml format to another
       using very simple (simplistic) "cross-walks" which consist, at
       the top level, of elements to match, and beneath, with what to
       replace it with. See either cdmmd2dc.xwalk or look in
       minimal.xsl to get an idea of what these look like.-->

  <xsl:template match="/">
    <xsl:apply-templates mode="seventrain:walker">
      <xsl:with-param name="xwalk-template" select="document($xwalk)"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="seventrain:children" mode="seventrain:template-walker">
    <xsl:param name="original"/>
    <xsl:param name="xwalk-template"/>
    <xsl:apply-templates mode="seventrain:walker" select="$original">
      <xsl:with-param name="xwalk-template" select="$xwalk-template"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="seventrain:value" mode="seventrain:template-walker">
    <xsl:param name="original"/>
    <xsl:param name="xwalk-template"/>
    <xsl:value-of select="$original"/>
  </xsl:template>

  <!-- This is a callback, of sorts; if we encounter a
       <seventrain:apply-templates/> child of a template, an
       <xsl:apply-templates/> is called with the matching node. For
       instance, if we have a xwalk template like: -->

  <!-- <publisher> -->
  <!-- <seventrain:apply-templates/> -->
  <!-- </publisher> -->
  
  <!-- and a template in the .xsl file: -->

  <!-- <xsl:template match="publisher"> -->
  <!-- </xsl:template> -->
  
  <!-- that template will be processed, with the current context of
       the publisher node in the original. -->

  <xsl:template match="seventrain:apply-templates" mode="seventrain:template-walker">
    <xsl:param name="original"/>
    <xsl:param name="xwalk-template"/>
    <xsl:apply-templates select="$original/.."/>
  </xsl:template>

  <xsl:template match="seventrain:split" mode="seventrain:template-walker">
    <!-- Used to split ugly “XML” which splits multiple values with a
         delimiter instead of using different elements. -->
    <xsl:param name="original"/>
    <xsl:param name="xwalk-template"/>
    
    <xsl:variable name="value-list" 
		  select="tokenize ($original, @on)"/>
    
    <xsl:variable name="which-element" select="@into"/>
    <xsl:variable name="new-elements">
      <xsl:for-each select="tokenize ($original, @on)">
	<xsl:element name="{$which-element}">
	  <xsl:value-of select="."/>
	</xsl:element>
      </xsl:for-each>
    </xsl:variable>
 
   <xsl:apply-templates mode="seventrain:walker"
			 select="$new-elements">
      <xsl:with-param name="xwalk-template" select="$xwalk-template"/>
    </xsl:apply-templates>
  </xsl:template>

  
  <xsl:template match="seventrain:*" mode="seventrain:template-walker"/>
  <xsl:template match="@seventrain:*" mode="seventrain:template-walker"/>
  
  <xsl:template match="@*|node()" mode="seventrain:template-walker">
    <xsl:param name="original"/>
    <xsl:param name="xwalk-template"/>
    
    <xsl:if test="count($original) > 0">
      <xsl:copy copy-namespaces="no">
	<xsl:apply-templates select="node()|@*" 
			     mode="seventrain:template-walker">
	  <xsl:with-param name="original" select="$original"/>
	  <xsl:with-param name="xwalk-template" select="$xwalk-template"/>
	</xsl:apply-templates>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template name="seventrain:xwalker">
    <xsl:param name="input"/>
    <xsl:param name="xwalk-file"/>
    <xsl:apply-templates select="$input" mode="seventrain:walker">
      <xsl:with-param name="xwalk-template" select="document($xwalk-file)"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="*" mode="seventrain:walker">
    <xsl:param name="xwalk-template"/>
    
    <xsl:variable name="in-element" select="node-name(.)"/>
    <xsl:variable name="original" select="node()"/>
    <xsl:variable 
	name="template-part" 
	select="$xwalk-template/seventrain:xwalk/*[node-name(.)=$in-element]/*"/>
    <xsl:if test="$template-part">
      <xsl:apply-templates select="$template-part" 
			   mode="seventrain:template-walker">
	<xsl:with-param name="xwalk-template" select="$xwalk-template"/>
	<xsl:with-param name="original" select="$original"/>
      </xsl:apply-templates>
    </xsl:if>
    
  </xsl:template>
</xsl:transform>
