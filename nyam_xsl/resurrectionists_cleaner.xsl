<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
        
    </xsl:template>
    
    <xsl:template match="/metadata/record/identifier[.='RB']">
        <xsl:for-each select=".">
            
            <xsl:element name="identifier"><xsl:text>RB-</xsl:text><xsl:value-of select="current()/../cdmid"/></xsl:element>    
            
        </xsl:for-each>
        
        
    </xsl:template>
    
    
</xsl:stylesheet>