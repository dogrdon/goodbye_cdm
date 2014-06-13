<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:fits="http://hul.harvard.edu/ois/xml/ns/fits/fits_output"
    xmlns:mets="http://www.loc.gov/mets/" xmlns:premis="http://www.loc.gov/standards/premis"
    xmlns:marc="http://www.loc.gov/marc2apple/slim" xmlns:mix="http://www.loc.gov/mix/v20"
    xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="xs" version="2.0">


    <!-- In the spirit of not reinventing the wheel, this XSL stylesheet has been forked and modified from https://github.com/little9/cdm_transformations-->

    <xsl:strip-space elements="*"/>
    <xsl:output method="xml" encoding="UTF-8"/>

    <xsl:variable name="vUpper" select="'AÁÀBCDEÉÈFGHIÍJKLMNÑOÓPQRSTUÚÜVWXYZ'"/>
    <xsl:variable name="vLower" select="'aáàbcdeéèfghiíjklmnñoópqrstuúüvwxyz'"/>
    <xsl:variable name="vQuote">"</xsl:variable>
    
    <xsl:param name="pFitsPath"></xsl:param>
    <xsl:param name="pCdmPath"></xsl:param>
    
    <xsl:variable name="vFitsList" select="document($pFitsPath)"/>
    <xsl:variable name="vCdmMetadata" select="document($pCdmPath)"/>
    <xsl:param name="pCollectionId"></xsl:param>
    
    <xsl:template match="/">
        <mets:mets xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:mets="http://www.loc.gov/METS/"
            xmlns:mods="http://www.loc.gov/mods/v3"
            xmlns:premis="http://www.loc.gov/standards/premis"
            xmlns:fits="http://hul.harvard.edu/ois/xml/ns/fits/fits_output"
            xmlns:mix="http://www.loc.gov/mix/v20"
            xsi:schemaLocation="http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/mets.xsd http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/mods.xsd http://www.loc.gov/standards/premis/v2 http://www.loc.gov/standards/premis/premis.xsd">

            <mets:metsHdr>
                <mets:agent ROLE="CREATOR" TYPE="ORGANIZATION">
                    <mets:name>NYAM Center for History of Medicine and Public Health</mets:name>
                </mets:agent>
            </mets:metsHdr>

            <xsl:if test="$vCdmMetadata/collection/descendant::node()[name()='singleItem' or name()='objectRecord']">
                <xsl:for-each 
                    select="$vCdmMetadata/collection/descendant::node()[name()='singleItem' or name()='objectRecord']">                    
                    <xsl:variable name="vId" select="if (self::node()[name()='singleItem']/field[@name='archive']!='') 
                        then self::node()[name()='singleItem']/field[@name='archive']
                        else (self::node()[name()='objectRecord']/field[@name='objectid' or @name='objectno.'])"/>                    
                    <xsl:variable name="vPosCount1" select="position()"/>
                    <mets:dmdSec>
                        <xsl:for-each select="$vId">
                            <xsl:attribute name="ID">                                
                                <xsl:choose>
                                    <xsl:when test=".=''">
                                        <xsl:value-of select="concat('WARNING_',$vPosCount1)"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="if (contains(.,'.')) 
                                            then concat('DMD',substring-before(substring(.,4),'.')) 
                                            else (concat('DMD',substring(.,4)))"/>
                                    </xsl:otherwise>
                                </xsl:choose>                                
                            </xsl:attribute>    
                        </xsl:for-each>                        
                        <mets:mdWrap MDTYPE="MODS">
                            <mets:xmlData>                                                                 
                                <mods:mods version="3.5">
                                    <xsl:call-template name="tModsMaker"/>                                                                                                                                                                                                                      
                                </mods:mods>                                                                    
                            </mets:xmlData>
                        </mets:mdWrap>
                    </mets:dmdSec>
                    <xsl:for-each select="self::node()[name()='objectRecord']/following-sibling::pageRecord">
                        <xsl:variable name="vId" select="field[@name='archive'][.!='']"/>
                        <xsl:variable name="vPosCount2" select="position()"/>                        
                        <mets:dmdSec>
                            <xsl:for-each select="$vId">
                                <xsl:attribute name="ID">
                                    <xsl:value-of select="if (contains(.,'.')) 
                                        then concat('DMD',substring-before(substring(.,4),'.')) 
                                        else (concat('DMD',substring(.,4)))"/>
                                </xsl:attribute>    
                            </xsl:for-each>
                            <mets:mdWrap MDTYPE="MODS">
                                <mets:xmlData>                                                                 
                                    <mods:mods version="3.5">
                                        <xsl:call-template name="tModsMaker">
                                            <xsl:with-param name="pRelatedOrig">false</xsl:with-param>                                
                                        </xsl:call-template>                                                                                                       
                                    </mods:mods>                                                                    
                                </mets:xmlData>
                            </mets:mdWrap>
                        </mets:dmdSec>                                                                                                                                         
                    </xsl:for-each>    
                </xsl:for-each>                
            </xsl:if>            

            <mets:amdSec>
                <xsl:for-each select="$vFitsList/fitsFiles/fitsFile[not(contains(@filename,'.mtf'))]">
                    <xsl:variable name="vPosCount" select="position()"/>  
                    <xsl:for-each select="document(@filename)/fits:fits">                        
                        <xsl:variable name="vFitsFileName"
                            select="fits:fileinfo/fits:filename"/>                        
                        <mets:techMD ID="{concat('AMD',substring-before(substring($vFitsFileName,4),'.'))}">
                            <mets:mdWrap MDTYPE="OTHER">
                                <xsl:if test="fits:metadata//mix:mix">
                                    <xsl:attribute name="LABEL" select="'MIX'"/>    
                                </xsl:if>                                
                                <mets:xmlData>
                                    <xsl:copy-of select="fits:metadata" copy-namespaces="no"/>
                                </mets:xmlData>
                            </mets:mdWrap>
                        </mets:techMD>                        
                    </xsl:for-each>
                </xsl:for-each>
            </mets:amdSec>

            <mets:fileSec>
                <mets:fileGrp ID="FG1" USE="master">                                         
                    <xsl:for-each select="$vFitsList/fitsFiles/fitsFile[not(contains(@filename,'.mtf'))]">
                        <xsl:variable name="vPosCount" select="position()"/>
                        <xsl:for-each select="document(@filename)/fits:fits">
                            <xsl:variable name="vFitsFileName"
                                select="fits:fileinfo/fits:filename"/>   
                            <xsl:variable name="vDate" select="concat('','2002-10-10T12:00:00-05:00')"/>                            
                            <mets:file>
                                <xsl:attribute name="ID" select="concat('OBJ',substring-before(substring($vFitsFileName,4),'.'))"/>                                        
                                <xsl:attribute name="MIMETYPE" select="fits:identification/fits:identity/@mimetype"/>
                                <xsl:attribute name="CREATED" select="$vDate"/>
                                <xsl:attribute name="SIZE" select="fits:fileinfo/fits:size"/>
                                <xsl:attribute name="CHECKSUMTYPE" select="'MD5'"/>
                                <xsl:attribute name="CHECKSUM" select="fits:fileinfo/fits:md5checksum"/>                                        
                                <mets:FLocat LOCTYPE="OTHER" OTHERLOCTYPE="SYSTEM"
                                    xlink:href="{fits:fileinfo/fits:filepath}"/>
                            </mets:file>                            
                        </xsl:for-each>
                    </xsl:for-each>                    
                </mets:fileGrp>
                <xsl:if test="$vCdmMetadata/collection/descendant::node()[name()='singleItem' or name()='pageRecord']/field[@name='fulltext'][.!='']">
                    <mets:fileGrp ID="FG2" USE="ocr">                                         
                        <xsl:for-each select="$vCdmMetadata/collection/descendant::node()[name()='singleItem' or name()='pageRecord']/field[@name='fulltext']">
                            <xsl:variable name="vPosCount" select="position()"/>                                       
                            <xsl:if test="../field[@name='archive'][.!=''][not(contains(.,'.url'))]">
                                <xsl:result-document href="{if (contains(../field[@name='archive'],'.')) 
                                    then concat('ocr/',substring-before(../field[@name='archive'],'.'),'.txt') 
                                    else (concat('ocr/',../field[@name='archive']),'.txt')}"
                                    indent="yes" method="text" encoding="UTF-8">
                                    <xsl:value-of select="normalize-space(.)"/>                            
                                </xsl:result-document>
                                <mets:file>
                                    <xsl:attribute name="ID" select="if (contains(../field[@name='archive'],'.')) 
                                                             then substring-before(concat('TXT',substring(../field[@name='archive'],4)),'.') 
                                                             else (concat('TXT',substring(../field[@name='archive'],4)))"/>                                        
                                    <xsl:attribute name="MIMETYPE" select="'text/plain'"/>                                                                                               
                                    <mets:FLocat LOCTYPE="OTHER" OTHERLOCTYPE="SYSTEM"
                                        xlink:href="{if (contains(../field[@name='archive'],'.')) 
                                        then concat('ocr/',substring-before(../field[@name='archive'],'.'),'.txt') 
                                        else (concat('ocr/',../field[@name='archive']),'.txt')}"/>
                                </mets:file>
                            </xsl:if>                                                       
                        </xsl:for-each>                                       
                    </mets:fileGrp>
                </xsl:if>                
            </mets:fileSec>

            <xsl:choose>
                <xsl:when test="$vCdmMetadata/collection/descendant::node()[name()='singleItem' or name()='objectRecord']">
                    <mets:structMap ID="SM1" TYPE="physical">
                        <mets:div>
                            <xsl:attribute name="ORDER" select="'1'"/>
                            <xsl:attribute name="ID" select="'SM1.1'"/>
                            <xsl:attribute name="TYPE" select="'collection'"/>                        
                            <xsl:attribute name="LABEL" select="distinct-values($vCdmMetadata/collection/descendant::field[@name='collectiontitle' or @name='collection'])"/>
                            <xsl:for-each select="$vCdmMetadata/collection/child::node()">
                                <mets:div>
                                    <xsl:attribute name="ORDER" select="position()"/>
                                    <xsl:attribute name="TYPE" select="descendant::field[@name='genre'][1]"/>
                                    <xsl:for-each select="descendant::field[@name='objectid' or @name='objectno.'][1]">
                                        <xsl:variable name="vObjId" select="substring(.,4)"/>                            
                                        <xsl:attribute name="DMDID" select="concat('DMD',$vObjId)"/>                            
                                    </xsl:for-each>
                                    <xsl:for-each select="descendant::field[@name='digitalid'][1][not(../field[@name='objectid' or @name='objectno.'][.!=''])]">
                                        <xsl:variable name="vDigId" select="substring(.,4)"/>                            
                                        <xsl:attribute name="DMDID" select="concat('DMD',$vDigId)"/>
                                        <xsl:attribute name="ADMID" select="concat('AMD',$vDigId)"/>
                                    </xsl:for-each>
                                    <xsl:attribute name="LABEL" select="descendant::field[@name='title'][1]"/>                                                                                                                                
                                    <xsl:choose>
                                        <xsl:when test="pageRecord">
                                            <xsl:for-each select="pageRecord">
                                                <mets:div>
                                                    <xsl:attribute name="ORDER" select="position()"/>
                                                    <!-- NB: might want to change the @TYPE attribute dynamically to reflect the actual content type. -->
                                                    <xsl:attribute name="TYPE" select="'item'"/>
                                                    <xsl:attribute name="LABEL" select="field[@name='title']"/>
                                                    <xsl:for-each select="field[@name='digitalid'][1][not(../field[@name='objectid' or @name='objectno.'][.!=''])]">
                                                        <xsl:variable name="vDigId" select="substring(.,4)"/>                            
                                                        <xsl:attribute name="DMDID" select="concat('DMD',$vDigId)"/>
                                                        <xsl:attribute name="ADMID" select="concat('AMD',$vDigId)"/>
                                                    </xsl:for-each>
                                                    <xsl:choose>
                                                        <xsl:when test="field[@name='archive'][not(contains(.,'.url'))]!='' and string-length(field[@name='archive'][not(contains(.,'.url'))])&gt;13">
                                                            <mets:fptr FILEID="{concat('OBJ',substring-before(substring(field[@name='archive'],4),'.'))}"/>
                                                            <xsl:if test="$vCdmMetadata/collection/descendant::node()[name()='singleItem' or name()='pageRecord']/field[@name='fulltext'][.!='']">
                                                                <mets:fptr FILEID="{concat('TXT',substring-before(substring(field[@name='archive'],4),'.'))}"/>
                                                            </xsl:if>        
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <mets:fptr FILEID="{concat('OBJ',substring-before(substring(field[@name='digitalid'],4),'.'))}"/>
                                                            <xsl:if test="$vCdmMetadata/collection/descendant::node()[name()='singleItem' or name()='pageRecord']/field[@name='fulltext'][.!='']">
                                                                <mets:fptr FILEID="{concat('TXT',substring(field[@name='digitalid'],4))}"/>
                                                            </xsl:if>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </mets:div>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:attribute name="TYPE" select="field[@name='genre']"/>
                                            <xsl:attribute name="LABEL" select="field[@name='title']"/>
                                            <xsl:choose>
                                                <xsl:when test="field[@name='archive'][not(contains(.,'.url'))]!='' and string-length(field[@name='archive'][not(contains(.,'.url'))])&gt;13">
                                                    <mets:fptr FILEID="{concat('OBJ',substring-before(substring(field[@name='archive'],4),'.'))}"/>
                                                    <xsl:if test="$vCdmMetadata/collection/descendant::node()[name()='singleItem' or name()='pageRecord']/field[@name='fulltext'][.!='']">
                                                        <mets:fptr FILEID="{concat('TXT',substring-before(substring(field[@name='archive'],4),'.'))}"/>
                                                    </xsl:if>        
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <mets:fptr FILEID="{concat('OBJ',substring-before(substring(field[@name='archive'],4),'.'))}"/>
                                                    <xsl:if test="$vCdmMetadata/collection/descendant::node()[name()='singleItem' or name()='pageRecord']/field[@name='fulltext'][.!='']">
                                                        <mets:fptr FILEID="{concat('TXT',substring(field[@name='digitalid'],4))}"/>
                                                    </xsl:if>
                                                </xsl:otherwise>
                                            </xsl:choose>                                                                                
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </mets:div>
                            </xsl:for-each>
                        </mets:div>
                    </mets:structMap>
                </xsl:when>
                <xsl:otherwise>
                    <mets:structMap ID="SM1" TYPE="physical">
                        <mets:div>
                            <xsl:attribute name="ORDER" select="'1'"/>
                            <xsl:attribute name="ID" select="'SM1.1'"/>
                            <xsl:attribute name="TYPE" select="'collection'"/>                        
                            <xsl:attribute name="LABEL" select="'Collection without descriptive metadata'"/>
                            <xsl:for-each select="$vFitsList/fitsFiles/fitsFile[not(contains(@filename,'.mtf'))]">
                                <xsl:variable name="vPosCount" select="position()"/>
                                <xsl:for-each select="document(@filename)/fits:fits">
                                    <xsl:variable name="vFitsFileName"
                                        select="fits:fileinfo/fits:filename"/>                                
                                    <mets:div>
                                        <xsl:attribute name="ORDER">
                                            <xsl:value-of select="$vPosCount"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="TYPE" select="'file'"/>
                                        <mets:fptr FILEID="{concat('OBJ',substring(substring-before($vFitsFileName,'.'),4))}"/>
                                    </mets:div>                                                                                                                                 
                                </xsl:for-each>
                            </xsl:for-each>                                                
                        </mets:div>
                    </mets:structMap>
                </xsl:otherwise>
            </xsl:choose>                                       
        </mets:mets>
    </xsl:template>
    
    <xsl:template name="tModsMaker" exclude-result-prefixes="#all">
        <xsl:param name="pRelatedOrig">true</xsl:param>        
        <!-- Title -->
        <mods:titleInfo>
            <mods:title>
                <xsl:value-of select="field[@name='title']"/>
            </mods:title>
        </mods:titleInfo>
        <xsl:for-each select="field[@name='translatedtitle'][.!='']|field[@name='alternatetitle'][.!='']|field[@name='alternativetitle'][.!='']">
            <mods:titleInfo type="alternative">
                <mods:title>
                    <xsl:value-of select="normalize-space(.)"/>
                </mods:title>
            </mods:titleInfo>
        </xsl:for-each>
        <!-- For each creator... -->
        <xsl:for-each
            select="field[@name='architect']|field[@name='author']|field[@name='creator'][.!='']|field[@name='contibutors'][.!='']|field[@name='composer'][.!='']|field[@name='costumedesigner'][.!='']|field[@name='interviewer'][.!='']|field[@name='speakers'][.!='']|field[@name='interviewee'][.!='']|field[@name='director'][.!='']|field[@name='posterdesigner'][.!='']|field[@name='producer'][.!='']|field[@name='photographer'][.!='']|field[@name='sender'][.!='']|field[@name='setdesigner'][.!='']">                                                                               
            <xsl:variable name="nameVal" select="@name"/>                                    
            <xsl:choose>
                <xsl:when test="@name='speakers'">
                    <xsl:choose>
                        <xsl:when test="contains(.,';')">
                            <xsl:for-each select="tokenize(.,';')">                                                                                                                        
                                <mods:name>
                                    <mods:namePart>
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </mods:namePart>
                                    <mods:role>
                                        <mods:roleTerm>
                                            <xsl:value-of
                                                select="'speaker'"/>
                                        </mods:roleTerm>
                                    </mods:role>
                                </mods:name>                                                           
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <mods:name>
                                <mods:namePart>
                                    <xsl:value-of select="normalize-space(.)"/>
                                </mods:namePart>
                                <mods:role>
                                    <mods:roleTerm>
                                        <xsl:value-of
                                            select="'speaker'"/>
                                    </mods:roleTerm>
                                </mods:role>
                            </mods:name>     
                        </xsl:otherwise>
                    </xsl:choose>                                                  
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="contains(.,'; ')">
                            <xsl:for-each select="tokenize(.,';')">                                                                                                                                                                                                                                                    
                                <mods:name>
                                    <mods:namePart>
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </mods:namePart>
                                    <mods:role>
                                        <mods:roleTerm>
                                            <xsl:value-of
                                                select="normalize-space($nameVal)"/>
                                        </mods:roleTerm>
                                    </mods:role>
                                </mods:name>                                                                                                                                                                                                                                                                                                                                          
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <mods:name>
                                <mods:namePart>
                                    <xsl:value-of select="normalize-space(.)"/>
                                </mods:namePart>
                                <mods:role>
                                    <mods:roleTerm>
                                        <xsl:value-of
                                            select="normalize-space($nameVal)"/>
                                    </mods:roleTerm>
                                </mods:role>
                            </mods:name>                                                            
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>                                        
        </xsl:for-each>      
        <!-- For each contributor... -->
        <xsl:for-each
            select="field[@name='arranger'][.!='']|field[@name='cast'][.!='']|field[@name='contributor'][.!='']|field[@name='contributors'][.!='']|field[@name='curator'][.!='']|field[@name='lyricist'][.!='']|field[@name='recipient'][.!='']|field[@name='technician'][.!='']|field[@name='theatercompany'][.!='']|field[@name='transcriber'][.!='']|field[@name='translator'][.!='']|field[@name='videographer'][.!='']">
            <xsl:variable name="nameVal" select="@name"/>                                        
            <xsl:choose>
                <xsl:when test="contains(.,';')">
                    <xsl:for-each select="tokenize(.,';')">                                                                                                                                                                                                                   
                        <mods:name>
                            <mods:namePart>
                                <xsl:value-of select="normalize-space(.)"/>
                            </mods:namePart>
                            <mods:role>
                                <mods:roleTerm>
                                    <xsl:value-of
                                        select="normalize-space($nameVal)"/>
                                </mods:roleTerm>
                            </mods:role>
                        </mods:name>                                                                                                            
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>                                                                                                                      
                    <mods:name>
                        <mods:namePart>
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:namePart>
                        <mods:role>
                            <mods:roleTerm>
                                <xsl:value-of
                                    select="normalize-space($nameVal)"/>
                            </mods:roleTerm>
                        </mods:role>
                    </mods:name>                                                                                                                                                        
                </xsl:otherwise>
            </xsl:choose>  
        </xsl:for-each>
        <xsl:for-each select="field[@name='host'][.!='']">
            <xsl:variable name="hostName" select="."/>
            <xsl:variable name="nameVal" select="@name"/>
            <xsl:choose>
                <xsl:when test="contains(.,';')">
                    <xsl:for-each select="tokenize(.,';')">
                        <mods:name>
                            <mods:namePart>
                                <xsl:value-of select="normalize-space($hostName)"/>
                            </mods:namePart>
                            <mods:role>
                                <mods:roleTerm>
                                    <xsl:value-of
                                        select="normalize-space($nameVal)"/>
                                </mods:roleTerm>
                            </mods:role>
                        </mods:name>                                                        
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <mods:name>
                        <mods:namePart>
                            <xsl:value-of select="normalize-space($hostName)"/>
                        </mods:namePart>
                        <mods:role>
                            <mods:roleTerm>
                                <xsl:value-of
                                    select="normalize-space($nameVal)"/>
                            </mods:roleTerm>
                        </mods:role>
                    </mods:name>    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>   
        <!-- For each subject... -->
        <xsl:for-each select="field[@name='subject'][.!='']">
            <xsl:choose>
                <xsl:when test="contains(.,';')">
                    <xsl:for-each select="tokenize(.,';')">
                        <mods:subject>                                                        
                            <mods:topic>
                                <xsl:value-of select="normalize-space(.)"/>
                            </mods:topic>
                        </mods:subject>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <mods:subject>                                                    
                        <mods:topic>
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:topic>
                    </mods:subject>
                </xsl:otherwise>
            </xsl:choose>                                            
        </xsl:for-each>                                    
        <!-- For each genre... -->
        <xsl:for-each select="field[@name='genre'][.!='']">
            <xsl:choose>
                <xsl:when test="contains(.,';')">
                    <xsl:for-each select="tokenize(.,';')">
                        <mods:genre>
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:genre>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <mods:genre>
                        <xsl:value-of select="normalize-space(.)"/>
                    </mods:genre>
                </xsl:otherwise>
            </xsl:choose>                                            
        </xsl:for-each>
        <!-- For each type... -->
        <xsl:for-each select="field[@name='type'][.!='']">
            <xsl:choose>
                <xsl:when test="contains(.,';')">
                    <xsl:for-each select="tokenize(.,';')">
                        <mods:typeOfResource>
                            <!-- Conditions for matching MODS vocab. -->
                            <xsl:choose>
                                <xsl:when test="normalize-space(lower-case(.))='image'">
                                    <xsl:value-of select="'still image'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="normalize-space(lower-case(.))"/>
                                </xsl:otherwise>
                            </xsl:choose>                            
                        </mods:typeOfResource>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <mods:typeOfResource>
                        <!-- Conditions for matching MODS vocab. -->
                        <xsl:choose>
                            <xsl:when test="normalize-space(lower-case(.))='image'">
                                <xsl:value-of select="'still image'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(lower-case(.))"/>
                            </xsl:otherwise>
                        </xsl:choose>   
                    </mods:typeOfResource>
                </xsl:otherwise>
            </xsl:choose>                                            
        </xsl:for-each>
        <!-- For each geo subject... -->
        <xsl:for-each select="field[@name='coveragespatial'][.!='']|field[@name='coveragespaital'][.!='']|field[@name='geographicsubject'][.!='']">
            <xsl:choose>
                <xsl:when test="contains(.,';')">
                    <xsl:for-each select="tokenize(.,';')">
                        <mods:subject>
                            <mods:geographic>
                                <xsl:value-of select="tokenize(.,';')"/>
                            </mods:geographic>
                        </mods:subject>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <mods:subject>
                        <mods:geographic>
                            <xsl:value-of select="tokenize(.,';')"/>
                        </mods:geographic>
                    </mods:subject>
                </xsl:otherwise>
            </xsl:choose>                                            
        </xsl:for-each>
        <!-- For each time period/coverage temp... -->
        <xsl:for-each select="field[@name='coveragetemporal'][.!='']|field[@name='timeperiod'][.!='']">
            <xsl:choose>
                <xsl:when test="contains(.,';')">
                    <xsl:for-each select="tokenize(.,';')">
                        <mods:subject>
                            <mods:temporal>
                                <xsl:value-of select="normalize-space(.)"/>
                            </mods:temporal>
                        </mods:subject>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <mods:subject>
                        <mods:temporal>
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:temporal>
                    </mods:subject>
                </xsl:otherwise>
            </xsl:choose>                                            
        </xsl:for-each>
        <!-- Origin info of digital object -->                                    
        <mods:originInfo>
            <xsl:for-each select="field[@name='datecreated'][.!=''][not(following-sibling::field[@name='datecreated'][.!=''])]">
                <xsl:choose>
                    <xsl:when test="contains(.,';')">
                        <xsl:for-each select="tokenize(.,';')">
                            <mods:dateOther>
                                <xsl:attribute name="type">
                                    <xsl:value-of select="'digital'"/>
                                </xsl:attribute>                                                            
                                <xsl:value-of select="normalize-space(.)"/>
                            </mods:dateOther>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <mods:dateOther>
                            <xsl:attribute name="type">
                                <xsl:value-of select="'digital'"/>
                            </xsl:attribute>
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:dateOther>
                    </xsl:otherwise>
                </xsl:choose>                                            
            </xsl:for-each>
            <xsl:for-each select="field[@name='datemodified'][.!='']">
                <xsl:choose>
                    <xsl:when test="contains(.,';')">
                        <xsl:for-each select="tokenize(.,';')">
                            <mods:dateOther>
                                <xsl:attribute name="type">
                                    <xsl:value-of select="'modified'"/>
                                </xsl:attribute>                                                            
                                <xsl:value-of select="normalize-space(.)"/>
                            </mods:dateOther>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <mods:dateOther>
                            <xsl:attribute name="type">
                                <xsl:value-of select="'modified'"/>
                            </xsl:attribute>
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:dateOther>
                    </xsl:otherwise>
                </xsl:choose>                                            
            </xsl:for-each>
        </mods:originInfo>                                    
        <!-- Correspondence Note -->
        <xsl:for-each select="field[@name='correspondencenote'][.!='']">
            <xsl:choose>
                <xsl:when test="contains(.,';')">
                    <xsl:for-each select="tokenize(.,';')">
                        <mods:note>
                            <xsl:attribute name="type" select="'correspondence'"/>
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:note>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <mods:note>
                        <xsl:attribute name="type" select="'correspondence'"/>
                        <xsl:value-of select="normalize-space(.)"/>
                    </mods:note>
                </xsl:otherwise>
            </xsl:choose>                                            
        </xsl:for-each>                                                                                                                
        <!-- Summary -->
        <xsl:if test="field[@name='summary'][.!='']">
            <mods:abstract>
                <xsl:value-of select="field[@name='summary']"/>
            </mods:abstract>
        </xsl:if>
        <!-- Note -->
        <xsl:for-each select="field[@name='note'][.!='']|field[@name='notes'][.!='']|field[@name='generalnote'][.!='']">
            <xsl:choose>
                <xsl:when test="contains(.,';')">
                    <xsl:for-each select="tokenize(.,';')">
                        <mods:note>
                            <xsl:attribute name="type" select="'content'"/>
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:note>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <mods:note>
                        <xsl:attribute name="type" select="'content'"/>
                        <xsl:value-of select="normalize-space(.)"/>
                    </mods:note>
                </xsl:otherwise>
            </xsl:choose>                                            
        </xsl:for-each>                                                           
        <!-- Language -->
        <xsl:for-each select="field[@name='language'][.!='']">
            <xsl:choose>
                <xsl:when test="contains(.,';')">
                    <xsl:for-each select="tokenize(.,';')">
                        <mods:language>
                            <mods:languageTerm>
                                <xsl:attribute name="authority" select="'iso639-2b'"/>
                                <xsl:value-of select="normalize-space(.)"/>
                            </mods:languageTerm>
                        </mods:language>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <mods:language>
                        <mods:languageTerm>
                            <xsl:attribute name="authority" select="'iso639-2b'"/>
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:languageTerm>
                    </mods:language>
                </xsl:otherwise>
            </xsl:choose>                                            
        </xsl:for-each>                                                                                                                                                
        <!-- Physical description of digital object -->                                    
        <mods:physicalDescription>
            <!-- Format/MIME type -->
            <xsl:for-each select="field[@name='format'][.!='']">
                <xsl:choose>
                    <xsl:when test="contains(.,';')">
                        <xsl:for-each select="tokenize(.,';')">
                            <mods:internetMediaType>
                                <xsl:value-of select="normalize-space(.)"/>
                            </mods:internetMediaType>                                                               
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <mods:internetMediaType>
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:internetMediaType>
                    </xsl:otherwise>
                </xsl:choose>   
            </xsl:for-each>
            <xsl:if test="field[@name='source'][.!=''] or field[@name='originalsource'][.!='']">
                <mods:digitalOrigin>
                    <xsl:text>reformatted digital</xsl:text>
                </mods:digitalOrigin>    
            </xsl:if>            
        </mods:physicalDescription>                                                                        
        <!-- External links -->
        <xsl:if test="field[@name='website'][.!='']">
            <mods:relatedItem type="references">
                <location>
                    <url>
                        <xsl:value-of select="normalize-space(.)"/>
                    </url>
                </location>
            </mods:relatedItem>
        </xsl:if>                                    
        <!-- Sponsor -->                                                                         
        <xsl:for-each select="field[@name='sponsor'][.!='']">
            <xsl:choose>
                <xsl:when test="contains(.,';')">
                    <xsl:for-each select="tokenize(.,';')">
                        <mods:note type="sponsor">
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:note>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <mods:note type="sponsor">
                        <xsl:value-of select="normalize-space(.)"/>
                    </mods:note>
                </xsl:otherwise>
            </xsl:choose>                                            
        </xsl:for-each>                                    
        <xsl:for-each select="field[@name='attention'][.!='']">
            <xsl:choose>
                <xsl:when test="contains(.,';')">
                    <xsl:for-each select="tokenize(.,';')">
                        <mods:note type="attention">
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:note>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <mods:note type="attention">
                        <xsl:value-of select="normalize-space(.)"/>
                    </mods:note>
                </xsl:otherwise>
            </xsl:choose>                                            
        </xsl:for-each>
        <xsl:for-each select="field[@name='editor'][.!='']">
            <mods:recordInfo>
                <xsl:choose>
                    <xsl:when test="contains(.,';')">
                        <xsl:for-each select="tokenize(.,';')">                                                        
                            <mods:recordContentSource>
                                <xsl:value-of select="normalize-space(.)"/>
                            </mods:recordContentSource>                                                        
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>                        
                        <mods:recordContentSource>
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:recordContentSource>                        
                    </xsl:otherwise>
                </xsl:choose>
            </mods:recordInfo>                                            
        </xsl:for-each>
        <!-- Rights and Copyright -->
        <xsl:if test="field[@name='copyright'][.!=''] or field[@name='rights'][.!='']">
            <mods:accessCondition>  
                <xsl:choose>
                    <xsl:when test="contains(field[@name='copyright'],'http')">
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="normalize-space(field[@name='copyright'])"/>    
                        </xsl:attribute>    
                    </xsl:when>
                    <xsl:when test="contains(field[@name='rights'],'http')">
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="normalize-space(field[@name='rights'])"/>    
                        </xsl:attribute>    
                    </xsl:when>
                    <xsl:otherwise>                                                    
                        <xsl:value-of select="normalize-space(field[@name='rights'])"/>                                                            
                    </xsl:otherwise>
                </xsl:choose>                                                                                                                                                                                                                                
            </mods:accessCondition>
        </xsl:if>             
        <!-- Local identifiers -->
        <!-- Object ID -->
        <xsl:if test="field[@name='objectid'][.!='']">
            <mods:identifier type="object">
                <xsl:value-of select="normalize-space(field[@name='objectid'])"/>
            </mods:identifier>    
        </xsl:if>
        <xsl:if test="field[@name='digitalid'][.!='']">
            <mods:identifier type="digital">
                <xsl:value-of select="normalize-space(field[@name='digitalid'])"/>
            </mods:identifier>    
        </xsl:if>
        <xsl:if test="field[@name='uploadid'][.!='']">
            <mods:identifier type="upload">
                <xsl:value-of select="normalize-space(field[@name='uploadid'])"/>
            </mods:identifier>    
        </xsl:if>
        <xsl:if test="field[@name='archive'][.!='']">
            <mods:identifier type="archive">
                <xsl:value-of select="normalize-space(field[@name='archive'])"/>
            </mods:identifier>    
        </xsl:if>
        <!-- Original object -->         
        <xsl:if test="$pRelatedOrig='true'">
            <mods:relatedItem type="original">
                <xsl:if test="field[@name='publisher'][.!=''] or field[@name='date'][.!='']|field[@name='datecreated'][.!=''][following-sibling::field[@name='datecreated']]|field[@name='dateoriginal'][.!=''] or field[@name='datepublished'][.!='']">
                    <mods:originInfo>
                        <!-- Publisher -->
                        <xsl:for-each select="field[@name='publisher'][.!='']">
                            <xsl:choose>
                                <xsl:when test="contains(.,';')">
                                    <xsl:for-each select="tokenize(.,';')">
                                        <mods:publisher>
                                            <xsl:value-of select="normalize-space(.)"/>
                                        </mods:publisher>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <mods:publisher>
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </mods:publisher>
                                </xsl:otherwise>
                            </xsl:choose>                                            
                        </xsl:for-each>                                            
                        <!-- Date elements -->
                        <xsl:for-each select="field[@name='date'][.!='']|field[@name='datecreated'][.!=''][following-sibling::field[@name='datecreated']]|field[@name='dateoriginal'][.!='']">
                            <xsl:choose>
                                <xsl:when test="contains(.,';')">
                                    <xsl:for-each select="tokenize(.,';')">
                                        <mods:dateCreated>
                                            <xsl:value-of select="normalize-space(.)"/>
                                        </mods:dateCreated>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <mods:dateCreated>
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </mods:dateCreated>
                                </xsl:otherwise>
                            </xsl:choose>                                            
                        </xsl:for-each>
                        <xsl:for-each select="field[@name='datepublished'][.!='']">
                            <xsl:choose>
                                <xsl:when test="contains(.,';')">
                                    <xsl:for-each select="tokenize(.,';')">
                                        <mods:dateIssued>
                                            <xsl:value-of select="normalize-space(.)"/>
                                        </mods:dateIssued>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <mods:dateIssued>
                                        <xsl:value-of select="normalize-space(.)"/>
                                    </mods:dateIssued>
                                </xsl:otherwise>
                            </xsl:choose>                                            
                        </xsl:for-each>
                        <xsl:for-each select="field[@name='creationplace'][.!='']|field[@name='place'][.!='']|field[@name='publicationplace'][.!='']">
                            <xsl:choose>
                                <xsl:when test="contains(.,';')">
                                    <xsl:for-each select="tokenize(.,';')">
                                        <mods:place>
                                            <mods:placeTerm type="text">
                                                <xsl:value-of select="normalize-space(.)"/>
                                            </mods:placeTerm>                                                                
                                        </mods:place>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <mods:place>
                                        <mods:placeTerm type="text">
                                            <xsl:value-of select="normalize-space(.)"/>
                                        </mods:placeTerm>                                                                
                                    </mods:place>
                                </xsl:otherwise>
                            </xsl:choose>                                            
                        </xsl:for-each>                                            
                    </mods:originInfo>
                </xsl:if>
                <!-- Physical description of original object -->
                <xsl:for-each select="field[@name='physicaldescription'][.!='']">                    
                    <mods:physicalDescription>
                        <mods:extent>
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:extent>
                    </mods:physicalDescription>                                                               
                </xsl:for-each>
                <xsl:for-each select="field[@name='donor'][.!='']">
                    <xsl:choose>
                        <xsl:when test="contains(.,';')">
                            <xsl:for-each select="tokenize(.,';')">
                                <mods:note type="donor">
                                    <xsl:value-of select="normalize-space(.)"/>
                                </mods:note>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <mods:note type="donor">
                                <xsl:value-of select="normalize-space(.)"/>
                            </mods:note>
                        </xsl:otherwise>
                    </xsl:choose>                                            
                </xsl:for-each>
                <xsl:for-each select="field[@name='provenance'][.!='']">
                    <xsl:choose>
                        <xsl:when test="contains(.,';')">
                            <xsl:for-each select="tokenize(.,';')">
                                <mods:note type="provenance">
                                    <xsl:value-of select="normalize-space(.)"/>
                                </mods:note>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <mods:note type="provenance">
                                <xsl:value-of select="normalize-space(.)"/>
                            </mods:note>
                        </xsl:otherwise>
                    </xsl:choose>                                            
                </xsl:for-each>
                <xsl:if test="field[@name='ibiswebcataloglink'][.!=''] or field[@name='callno.'][.!='']">                                            
                    <xsl:for-each select="field[@name='callno.']">
                        <mods:classification authority="lcc">
                            <xsl:value-of select="normalize-space(.)"/>
                        </mods:classification>
                    </xsl:for-each>
                    <xsl:for-each select="field[@name='ibiswebcataloglink'][.!='']">
                        <location>
                            <url>
                                <xsl:value-of select="normalize-space(.)"/>
                            </url>
                        </location>    
                    </xsl:for-each>                                                                                        
                </xsl:if>
                <xsl:if test="field[@name='oclcno.'][.!='']">                                            
                    <mods:identifier type="oclc">
                        <xsl:value-of select="normalize-space(field[@name='oclcno.'])"/>
                    </mods:identifier>                                                                                                                                   
                </xsl:if> 
                <!-- Repository -->
                <xsl:if test="field[@name='repository'][.!='']">
                    <mods:location>
                        <mods:physicalLocation>
                            <xsl:value-of select="field[@name='repository']"/>
                        </mods:physicalLocation>
                    </mods:location>
                </xsl:if>
                <!-- Collection Number, Collection Title, Series Title, Container -->
                <xsl:if test="field[@name='collectiontitle'][.!=''] or field[@name='collection'][.!='']">
                    <mods:relatedItem type="host">
                        <mods:titleInfo>                                                
                            <xsl:for-each select="field[@name='collectiontitle'][.!='']|field[@name='collection'][.!='']">                                                                                        
                                <mods:title>
                                    <xsl:value-of select="normalize-space(.)"/>
                                </mods:title>                                                    
                            </xsl:for-each>
                            <xsl:for-each select="field[@name='series'][.!='']">
                                <mods:subTitle>
                                    <xsl:value-of select="normalize-space(.)"/>
                                </mods:subTitle>
                            </xsl:for-each>                                                
                        </mods:titleInfo>
                        <xsl:for-each select="field[@name='collectionno.'][.!='']">
                            <mods:identifier>
                                <xsl:attribute name="type" select="'local'"/>
                                <xsl:value-of select="normalize-space(.)"/>
                            </mods:identifier>
                        </xsl:for-each>
                        <xsl:if test="field[@name='container'][.!='']">
                            <mods:location>
                                <mods:holdingSimple>
                                    <mods:copyInformation>
                                        <mods:shelfLocator>
                                            <xsl:value-of select="field[@name='container']"/>
                                        </mods:shelfLocator>                                                            
                                    </mods:copyInformation>
                                </mods:holdingSimple>
                            </mods:location>
                        </xsl:if>
                    </mods:relatedItem>
                </xsl:if>
            </mods:relatedItem>
            <xsl:for-each select="self::node()[name()='objectRecord']/following-sibling::pageRecord">                
                <xsl:variable name="vId" select="field[@name='archive'][.!='']"/>
                <mods:relatedItem type="constituent">
                    <xsl:for-each select="$vId">
                        <xsl:attribute name="xlink:href" select="if (contains(.,'.')) 
                                                         then concat('#DMD',substring-before(substring(.,4),'.')) 
                                                         else (concat('#DMD',substring(.,4)))"/>                                                        
                    </xsl:for-each>                    
                </mods:relatedItem>
            </xsl:for-each>
        </xsl:if>        
    </xsl:template>

</xsl:stylesheet>
