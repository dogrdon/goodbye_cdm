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
 		Local installations can customize this process by creating a stylesheet that imports 7train.xsl and 
 		overrides certain templates.  This stylesheet (cdm.xsl) is an example of a local installation designed to 
 		transform a specific XML file (CONTENTdm export) into a specific kind of METS.  
 		See Customizing.txt for more information and for specific examples.
-->
<xsl:transform 
	version="2.0" 
	xmlns:xlink="http://www.w3.org/1999/xlink"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:mets="http://www.loc.gov/METS/" 
	xmlns:seventrain="http://cdlib.org/7train/"
	xmlns:local="http://example.org/local/" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	exclude-result-prefixes="#all">
	
	<!-- Import main stylesheet -->
	<xsl:import href="7train.xsl"/>
	<!-- Declare output type -->
	<xsl:output name="output1" method="xml" indent="yes" encoding="utf-8"/>
	
	<xsl:strip-space elements="*"/>
	
	<!-- Import mapping files into variables -->
	<!-- Check for  existence of files first -->
	<xsl:variable name="institutionmap">
		<xsl:choose>
			<xsl:when test="doc-available('drivers/institutions.xml')">
				<xsl:copy-of select="document('drivers/institutions.xml')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>empty</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="idmap">
		<xsl:choose>
			<xsl:when test="doc-available('drivers/idmap.xml')">
				<xsl:copy-of select="document('drivers/idmap.xml')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>empty</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- Extract the ARK for the finding aid this object belongs to from the institution map-->
	<xsl:function name="local:eadark" as="xs:string">
		<xsl:param name="instCode" as="xs:string"/>
		<xsl:value-of select="$institutionmap/institutions/institution[@marccode=$instCode]/@eadark"/>
	</xsl:function>
	
	<!-- Extract the Labe/Title of the finding aid this object belongs to from the institution map-->
	<xsl:function name="local:eadlabel" as="xs:string">
		<xsl:param name="instCode" as="xs:string"/>
		<xsl:value-of
			select="$institutionmap/institutions/institution[@marccode=$instCode]/@eadlabel"/>
	</xsl:function>
	
	<!-- Extract the ARK for the owning/holding institution from the institution map -->
	<xsl:function name="local:instark" as="xs:string">
		<xsl:param name="instCode" as="xs:string"/>
		<xsl:value-of select="$institutionmap/institutions/institution[@marccode=$instCode]/@ark"/>
	</xsl:function>
	
	<!-- Extract the URL for the owning/holding institution's web page from the institution map-->
	<xsl:function name="local:url" as="xs:string">
		<xsl:param name="instCode" as="xs:string"/>
		<xsl:value-of select="$institutionmap/institutions/institution[@marccode=$instCode]/@url"/>
	</xsl:function>
	
	<!-- Extract the MARC code for the institution from the institution map -->
	<xsl:function name="local:marccode" as="xs:string">
		<xsl:param name="record" as="node()"/>
		<xsl:value-of
			select="$institutionmap/institutions/institution[@name=$record/publisher]/@marccode"/>
	</xsl:function>
	
	<!-- Extract the ARK from the id map -->
	<xsl:function name="local:arkfull" as="xs:string">
		<xsl:param name="record" as="node()"/>
		<xsl:value-of select="$idmap/objects/obj[@localid=$record/identifier[1]]/@uniqueid"/>
	</xsl:function>
	
	<!-- Calculate the ARK "stub" from the full ARK -->
	<xsl:function name="local:arkstub" as="xs:string">
		<xsl:param name="record" as="node()"/>
		<xsl:value-of select="replace($idmap/objects/obj[@localid=$record/identifier[1]]/@uniqueid,
			'^.+/([a-z0-9]+)$','$1')"/>
	</xsl:function>
	
	<!-- Calculate the institution code from the identifier base -->
	<xsl:function name="local:instCode" as="xs:string">
		<xsl:param name="record" as="node()"/>
		<xsl:value-of select="lower-case(replace($record/identifier[1],'^(.+)_[0-9]+$','$1'))"/>
	</xsl:function>
	
	<!-- Calculate the authoritative institution name from the institution map -->
	<xsl:function name="local:instName" as="xs:string">
		<xsl:param name="instCode" as="xs:string"/>
		<xsl:value-of select="$institutionmap/institutions/institution[@marccode=$instCode]/@name"/>
	</xsl:function>
	
	<!-- Controlled vocabulary map for the fileGrp@USE or file@USE attribute -->
	<xsl:variable name="cdmtype2usagetype">
		<local:metstype cdmtype="thumbnail">thumbnail image</local:metstype>
		<local:metstype cdmtype="master">archive image</local:metstype>
		<local:metstype cdmtype="access">reference image</local:metstype>
	</xsl:variable>
	
	<!-- Controlled vocabulary map for the file@MIMETYPE attribute -->
	<xsl:variable name="ext2mimetype">
		<local:mimetype ext="jpg">image/jpeg</local:mimetype>
		<local:mimetype ext="jpeg">image/jpeg</local:mimetype>
		<local:mimetype ext="gif">image/gif</local:mimetype>
		<local:mimetype ext="tif">image/tiff</local:mimetype>
		<local:mimetype ext="tiff">image/tiff</local:mimetype>
	</xsl:variable>
	
	<!-- Controlled vocabulary map for the mets@TYPE attribute -->
	<xsl:variable name="dcType2metsType">
		<local:metstype cdmtype="">image</local:metstype>
		<local:metstype cdmtype="image">image</local:metstype>
		<local:metstype cdmtype="text;">facsimile text</local:metstype>
		<local:metstype cdmtype="text">facsimile text</local:metstype>
		<local:metstype cdmtype="physicalobject">image</local:metstype>
		<local:metstype cdmtype="physical object">image</local:metstype>
	</xsl:variable>
	
	<xsl:variable name="base-element" select="QName('','record')"/>
	
	<!-- Record the local ID as the altRecordID, but only if there is a valid value in the idmap -->
	<xsl:template match="record" mode="seventrain:mets-metsHdr-altRecordID">
		<xsl:choose>
			<xsl:when test="normalize-space($idmap) eq 'empty'"/>
			<xsl:when test="string-length(local:arkstub(.)) = 0"/>
			<xsl:otherwise>
				<mets:altRecordID>
					<xsl:value-of select="identifier[1]"/>
				</mets:altRecordID>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Use the Title of the object as the mets@LABEL attribute -->
	<xsl:template match="record" mode="seventrain:mets.LABEL">
		<xsl:value-of select="title"/>
	</xsl:template>

	<!-- Map the mets@TYPE attribute from the value in the export -->
	<xsl:template match="record" mode="seventrain:mets.TYPE">
		<xsl:variable name="dcType" select="lower-case(type[1])"/>
		<xsl:variable name="metsType" select="$dcType2metsType/local:metstype[@cdmtype=$dcType]"/>
		<xsl:choose>
			<xsl:when test="empty($metsType)">
				<xsl:text>image</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$metsType"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Populate the mets@OBJID attribute -->
	<xsl:template match="record" mode="seventrain:mets.OBJID">
		<xsl:choose>
			<!-- use the identifier from the export if there is no idmap -->
			<xsl:when test="normalize-space($idmap) eq 'empty'">
				<xsl:value-of select="identifier[1]"/>
			</xsl:when>
			<!-- use the identifier from the export if there is no match in the idmap -->
			<xsl:when test="string-length(local:arkstub(.)) = 0">
				<xsl:value-of select="identifier[1]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="local:arkfull(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Define the output file name using the ARK stub -->
	<xsl:template match="record" mode="seventrain:output-filename">
		<!-- xsl:text>../output/</xsl:text -->
		<xsl:choose>
			<!-- Use a random ID when the identifier is empty, but warn the user -->
			<xsl:when test="string-length(identifier[1]) = 0">
				<xsl:variable name="random-id" select="seventrain:generate-random-id()"/>
				<xsl:value-of select="$random-id"/>
				<xsl:message><xsl:text>The file contains an object without an identifier! Writing as: </xsl:text><xsl:value-of select="$random-id"/></xsl:message>
			</xsl:when>
			<!-- use the identifier from the export if there is no idmap -->
			<xsl:when test="normalize-space($idmap) eq 'empty'">
				<xsl:value-of select="identifier[1]"/>
			</xsl:when>
			<!-- use the identifier from the export if there is no match in the idmap -->
			<xsl:when test="string-length(local:arkstub(.)) = 0">
				<xsl:value-of select="identifier[1]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="local:arkstub(.)"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text>.mets.xml</xsl:text>
	</xsl:template>
	
	<xsl:template match="record" mode="seventrain:mets-metsHdr-agent">
		<mets:agent ROLE="EDITOR" TYPE="ORGANIZATION">
			<mets:name>California Digital Library</mets:name>
			<mets:note>Record created by conversion of CONTENTdm XML metadata</mets:note>
			<mets:note>Created using 7train</mets:note>
		</mets:agent>
	</xsl:template>

	<!-- Define METS profile -->
	<xsl:template match="record" mode="seventrain:mets.PROFILE">
		<!-- xsl:text>http://ark.cdlib.org/mets/profiles/7trainProfile.xml</xsl:text -->
		<xsl:text>http://www.loc.gov/mets/profiles/00000010.xml</xsl:text>
	</xsl:template>
	
	<!-- Build the primary dmdSec of the METS;
		  Call the crosswalker and process the record - this calls xwalker.xsl which contains the logic for 
			  processing the mappings, with the specific mappings defined in the $xwalk-file parameter -->
	<xsl:template match="record" mode="seventrain:mets-dmdSec">
		<mets:dmdSec ID="DC" CREATED="{current-dateTime()}">
			<mets:mdWrap MIMETYPE="text/xml" MDTYPE="DC" LABEL="DC">
				<mets:xmlData>
					<xsl:call-template name="seventrain:xwalker">
						<xsl:with-param name="input" select="."/>
						<xsl:with-param name="xwalk-file" select="'cdmmd2dc.xwalk'"/>
					</xsl:call-template>
				</mets:xmlData>
			</mets:mdWrap>
		</mets:dmdSec>
		<xsl:call-template name="local:dmdSec"/>
	</xsl:template>
	
	<!-- Build the EAD and Repository dmdSecs -->
	<xsl:template name="local:dmdSec">
		<xsl:variable name="instCode">
			<xsl:value-of select="local:instCode(.)"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="normalize-space($institutionmap) eq 'empty'"/>
			<xsl:otherwise>
				<mets:dmdSec ID="ead">
					<mets:mdRef LOCTYPE="URL" MDTYPE="EAD">
						<xsl:attribute name="ID">
							<xsl:value-of select="local:eadark($instCode)"/>
						</xsl:attribute>
						<xsl:attribute name="LABEL">
							<xsl:value-of select="local:eadlabel($instCode)"/>
						</xsl:attribute>
						<xsl:attribute name="xlink:href">
							<xsl:text>http://www.oac.cdlib.org/findaid/ark:/13030/</xsl:text>
							<xsl:value-of select="local:eadark($instCode)"/>
						</xsl:attribute>
					</mets:mdRef>
				</mets:dmdSec>
				<mets:dmdSec ID="repo">
					<mets:mdWrap MIMETYPE="text/xml" MDTYPE="DC" LABEL="Repository">
						<mets:xmlData>
							<dc:title>
								<xsl:value-of select="local:instName($instCode)"/>
							</dc:title>
							<dc:identifier>
								<xsl:value-of select="local:instark($instCode)"/>
							</dc:identifier>
							<dc:identifier>
								<xsl:value-of select="local:url($instCode)"/>
							</dc:identifier>
						</mets:xmlData>
					</mets:mdWrap>
				</mets:dmdSec>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Build fileSec -->
	<xsl:template match="record" mode="seventrain:mets-fileSec">
		<mets:fileSec ID="{seventrain:generate-random-id()}">
			<xsl:apply-templates select="thumbnailURL" mode="seventrain:mets-fileSec"/>
			<xsl:apply-templates select="structure" mode="seventrain:mets-fileSec"/>
			<xsl:apply-templates select="fullResolution" mode="seventrain:mets-fileSec"/>
		</mets:fileSec>
	</xsl:template>
	
	<!-- Build thumbnail fileGrp for simple objects.
		Checks for thumbnail urls which do not have a complex <structure> sibling, i.e. <structure> that is a text node. -->
	<xsl:template match="thumbnailURL[../structure[text()]]" mode="seventrain:mets-fileSec">
		<mets:fileGrp USE="thumbnail image">
			<xsl:call-template name="local:file-from-url">
				<xsl:with-param name="url" select="."/>
				<xsl:with-param name="cdm-type" select="'thumbnail'"/>
				<!-- xsl:with-param name="title" select="../title"/ -->
			</xsl:call-template>
		</mets:fileGrp>
	</xsl:template>

	<!-- Suppress output of fileSec group for complex objects. -->
	<xsl:template match="thumbnailURL[not(../structure[text()])]" mode="seventrain:mets-fileSec"/>

	<!-- Build reference image fileGrp for simple objects -->
	<xsl:template match="structure[text()]" mode="seventrain:mets-fileSec">
		<mets:fileGrp USE="reference image">
			<xsl:call-template name="local:file-from-url">
				<xsl:with-param name="url" select="."/>
				<xsl:with-param name="cdm-type" select="'access'"/>
				<!-- xsl:with-param name="title" select="../title"/ -->
			</xsl:call-template>
		</mets:fileGrp>
	</xsl:template>
	
	<!-- Build archive image fileGrp for simple objects -->
	<xsl:template match="fullResolution[../structure[text()]]" mode="seventrain:mets-fileSec">
		<xsl:if test="normalize-space(.) ne ''">
			<mets:fileGrp USE="archive image">
				<xsl:call-template name="local:file-from-url">
					<xsl:with-param name="url" select="."/>
					<xsl:with-param name="cdm-type" select="'master'"/>
					<!-- xsl:with-param name="title" select="../title"/ -->
				</xsl:call-template>
			</mets:fileGrp>
		</xsl:if>
	</xsl:template>
	
	<!-- Build the fileGrps for complex objects, using each pagefile -->
	<xsl:template match="structure" mode="seventrain:mets-fileSec">
		<xsl:for-each-group select=".//page/pagefile" group-by="pagefiletype">
			<mets:fileGrp>
				<xsl:attribute name="USE">
					<xsl:value-of select="$cdmtype2usagetype/local:metstype[@cdmtype=current-grouping-key()]"/>
				</xsl:attribute>
				<xsl:apply-templates select="current-group()" mode="seventrain:mets-fileSec"/>
			</mets:fileGrp>
		</xsl:for-each-group>
		<xsl:if test="normalize-space(string-join(.//page/pagetext, '')) ne ''">
			<mets:fileGrp USE="transcription">
				<xsl:apply-templates select=".//page/pagetext" mode="seventrain:mets-fileSec"/>
			</mets:fileGrp>
		</xsl:if>
	</xsl:template>
	
	<!-- Grab the text transcription and build an FContent wrapping the XML, if not empty -->
	<xsl:template match="pagetext" mode="seventrain:mets-fileSec">
		<xsl:if test="normalize-space(string-join(., '')) ne ''">
			<mets:file ID="{generate-id()}" MIMETYPE="text/xml" GROUPID="{../pagetitle}">
				<mets:FContent>
					<mets:xmlData>
						<transcription>
							<xsl:value-of select="normalize-space(.)"/>
						</transcription>
					</mets:xmlData>
				</mets:FContent>
			</mets:file>
		</xsl:if>
	</xsl:template>
	
	<!-- Set the parameters and call the template that creates the file and FLocat elements -->
	<xsl:template match="pagefile" mode="seventrain:mets-fileSec">
		<xsl:call-template name="local:file-from-url">
			<xsl:with-param name="url" select="pagefilelocation"/>
			<xsl:with-param name="cdm-type" select="pagefiletype"/>
			<xsl:with-param name="title" select="../pagetitle"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- Build the file and FLocat elements -->
	<xsl:template name="local:file-from-url">
		<xsl:param name="url"/>
		<xsl:param name="cdm-type"/>
		<xsl:param name="title"/>
		<xsl:variable name="file-ext" select="lower-case(replace($url, '^.+\.([a-zA-Z0-9]+)$','$1'))"/>
		<xsl:variable name="mimetype" select="$ext2mimetype/local:mimetype[@ext=$file-ext]"/>

		<!-- Do not build file & FLocat if there is no URL content -->
		<xsl:if test="normalize-space($url) ne ''">
			<xsl:call-template name="local:build-file-element">
				<xsl:with-param name="url" select="$url"/>
				<xsl:with-param name="groupid" select="$title"/>
				<xsl:with-param name="xlink-role" select="$cdm-type"/>
				<xsl:with-param name="mimetype" select="$mimetype"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template name="local:build-file-element">
		<xsl:param name="url"/>
		<xsl:param name="groupid"/>
		<xsl:param name="mimetype"/>
		<xsl:param name="xlink-role"/>
		<xsl:param name="id" select="generate-id()"/>

		<mets:file ID="{$id}">
			<xsl:if test="normalize-space($groupid) ne ''">
				<xsl:attribute name="GROUPID">
					<xsl:value-of select="$groupid"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="$mimetype ne ''">
				<xsl:attribute name="MIMETYPE">
					<xsl:value-of select="$mimetype"/>
				</xsl:attribute>
			</xsl:if>			
			<mets:FLocat LOCTYPE="URL">
			<xsl:if test="$xlink-role ne ''">
				<xsl:attribute name="xlink:role">
					<xsl:value-of select="$xlink-role"/>
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="xlink:href">
				<xsl:value-of select="$url"/>
			</xsl:attribute>
			</mets:FLocat>
		</mets:file>
	</xsl:template>
	
	<!-- Build the structMap and top-level div for all objects (simple and complex)-->
	<xsl:template match="record" mode="seventrain:mets-structMap">
		<mets:structMap>
			<mets:div ID="{seventrain:generate-random-id()}" DMDID="DC">
				<xsl:attribute name="LABEL">
					<xsl:value-of select="title"/>
				</xsl:attribute>
				<xsl:apply-templates select="structure" mode="seventrain:mets-structMap"/>
			</mets:div>
		</mets:structMap>
	</xsl:template>
	
	<!-- *For simple objects only* (matching a text node for structure):
			call templates to build thumbnail and master image divs and 
			build reference/access image div-->
	<xsl:template match="structure[text()]" mode="seventrain:mets-structMap">
		<xsl:apply-templates select="../thumbnailURL" mode="seventrain:mets-structMap"/>
		<mets:div ID="{seventrain:generate-random-id()}" TYPE="reference image">
			<mets:fptr ID="{seventrain:generate-random-id()}" FILEID="{generate-id()}"/>
		</mets:div>
		<xsl:apply-templates select="../fullResolution" mode="seventrain:mets-structMap"/>
	</xsl:template>
	
	<!-- Build the thumbnail div and fptr for simple objects -->
	<xsl:template match="thumbnailURL" mode="seventrain:mets-structMap">
		<mets:div ID="{seventrain:generate-random-id()}" TYPE="thumbnail image">
			<mets:fptr ID="{seventrain:generate-random-id()}" FILEID="{generate-id()}"/>
		</mets:div>
	</xsl:template>
	
	<!-- Build the master image div and fptr for simple objects; omit if there is no URL content -->
	<xsl:template match="fullResolution" mode="seventrain:mets-structMap">
		<xsl:if test="normalize-space(.) ne ''">
			<mets:div ID="{seventrain:generate-random-id()}" TYPE="archive image">
				<mets:fptr ID="{seventrain:generate-random-id()}" FILEID="{generate-id()}"/>
			</mets:div>
		</xsl:if>
	</xsl:template>
	
	<!-- *For complex objects only* (matching an element node for structure):
			Determine the type (degree of complexity) of complex object -->
	<xsl:template match="structure" mode="seventrain:mets-structMap">
		<xsl:choose>
			<xsl:when test="exists(node[2])">
				<xsl:apply-templates select="node" mode="seventrain:mets-structMap"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="page" mode="seventrain:mets-structMap"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Build mid-level div structure for complex objects; skip first empty node element -->
	<xsl:template match="node" mode="seventrain:mets-structMap">
		<xsl:choose>
			<xsl:when test="position() = 1"/>
			<xsl:otherwise>
				<mets:div ID="{seventrain:generate-random-id()}">
					<xsl:attribute name="LABEL">
						<xsl:value-of select="nodetitle"/>
					</xsl:attribute>
					<xsl:apply-templates select="page" mode="seventrain:mets-structMap"/>
				</mets:div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Build lower-level div for complex objects; call template to build lowest-level div and fptr -->
	<xsl:template match="page" mode="seventrain:mets-structMap">
		<mets:div ID="{seventrain:generate-random-id()}" LABEL="{pagetitle}">
			<xsl:apply-templates select="pagefile|pagetext" mode="seventrain:mets-structMap"/>
		</mets:div>
	</xsl:template>
	
	<!-- Build lowest-level div and fptr for complex objects; determine div@TYPE; 
			repress building of div if URL is missing-->
	<xsl:template match="pagefile" mode="seventrain:mets-structMap">
		<xsl:if test="pagefilelocation ne ''">
			<xsl:variable name="pagefiletype" select="pagefiletype"/>
			<xsl:variable name="label" select="$cdmtype2usagetype/local:metstype[@cdmtype=$pagefiletype]"/>
			<!-- xsl:variable name="type">
				<xsl:choose>
					<xsl:when test="$label='thumbnail image'">thumbnail image</xsl:when>
					<xsl:when test="$label='reference image'">reference image</xsl:when>
					<xsl:when test="$label='archive image'">hidden</xsl:when>
				</xsl:choose>
			</xsl:variable -->
			<mets:div ID="{seventrain:generate-random-id()}" TYPE="{$label}">
				<mets:fptr FILEID="{generate-id()}"/>
			</mets:div>
		</xsl:if>
	</xsl:template>
	
	<!-- Build div and fptr for text transcriptions -->
	<xsl:template match="pagetext[normalize-space(.) ne '']" mode="seventrain:mets-structMap">
		<mets:div ID="{seventrain:generate-random-id()}" TYPE="transcription">
			<mets:fptr FILEID="{generate-id()}"/>
		</mets:div>
	</xsl:template>
	
	<!-- Build amdSec -->
	<xsl:template match="record" mode="seventrain:mets-amdSec"/>
	
</xsl:transform>
