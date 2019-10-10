<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <!-- We need the value of this variable if we want to get any metadata from the filename. -->
    <xsl:variable name="document-uri" select="document-uri(.)"/>
    <xsl:variable name="filename" select="(tokenize($document-uri,'/'))[last()]"/>
    <xsl:variable name="date">
        <xsl:analyze-string select="$filename" regex="\d{{4}}-\d{{2}}-\d{{2}}">
            <xsl:matching-substring>
                <xsl:value-of select="."/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:variable>
    
    <!-- XSLT multi-pass technique -->
    <xsl:template match="/">
        <xsl:result-document href="../tei-v2/{$filename}">
            <xsl:variable name="var1">
                <xsl:apply-templates mode="pass1"/>
            </xsl:variable>
            <xsl:variable name="var2">
                <xsl:apply-templates select="$var1" mode="pass2"/>
            </xsl:variable>
            <xsl:variable name="var3">
                <xsl:apply-templates select="$var2" mode="pass3"/>
            </xsl:variable>
            <xsl:variable name="var4">
                <xsl:apply-templates select="$var3" mode="pass4"/>
            </xsl:variable>
            <xsl:variable name="var5">
                <xsl:apply-templates select="$var4" mode="pass5"/>
            </xsl:variable>
            <xsl:apply-templates select="$var5" mode="pass6"/>
        </xsl:result-document>
    </xsl:template>
    
    <!-- Identity Transform: Pass 1 -->
    <xsl:template match="@* | node()" mode="pass1">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="pass1"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:body" mode="pass1">
        <body>
            <div>
                <xsl:apply-templates mode="pass1"/>
            </div>
        </body>
    </xsl:template>
    
    <xsl:template match="tei:p[@rend='epf_Dok_Titel']" mode="pass1">
        <head>
            <xsl:if test="preceding-sibling::tei:p[@rend='epf_Dok_Nummer'] | preceding-sibling::tei:p[@rend='Doknummer']">
                <xsl:attribute name="n">
                    <xsl:value-of select="preceding-sibling::tei:p[@rend='epf_Dok_Nummer'] | preceding-sibling::tei:p[@rend='Doknummer']"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates mode="pass1"/>
        </head>
    </xsl:template>
    
    <xsl:template match="tei:p[@rend='epf_Dok_Nummer'] | tei:p[@rend='Doknummer']" mode="pass1">
        <xsl:choose>
            <xsl:when test="following-sibling::tei:p[@rend='epf_Dok_Titel']">
                <!-- remove number proccessed with title -->
            </xsl:when>
            <xsl:otherwise>
                <head>
                    <xsl:apply-templates mode="pass1"/>
                </head>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:hi[contains(@style,'font-size:')]" mode="pass1">
        <!-- remove font-size without semantic meaning -->
    </xsl:template>
    
    <xsl:template match="tei:p[@rend='epf_Dok_Kopf'] | tei:p[@rend='Dokumkopf']" mode="pass1">
        <opener>
            <xsl:apply-templates mode="pass1"/>
        </opener>
    </xsl:template>
    
    <xsl:template match="tei:p[@rend='footnote text']" mode="pass1">
        <xsl:choose>
            <xsl:when test=" preceding-sibling::tei:p or following-sibling::tei:p">
                <p>
                    <xsl:apply-templates mode="pass1"/>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="pass1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:p[@rend='epf_SVP_Überschrift'] | tei:p[@rend='Sitzungsverlauf'][not(preceding-sibling::tei:p[@rend='Sitzungsverlauf'])]" mode="pass1">
        <list type="agenda">
            <head>
                <xsl:apply-templates mode="pass1"/>
            </head>
            <xsl:for-each select="following-sibling::tei:p[@rend='epf_SVP'] | following-sibling::tei:p[@rend='epf_SVP_Ende'] | following-sibling::tei:p[@rend='Sitzungsverlauf']">
                <item>
                    <xsl:apply-templates mode="pass1"/>
                </item>
            </xsl:for-each>
        </list>
    </xsl:template>
    
    <xsl:template match="tei:p[@rend='epf_SVP' or @rend='epf_SVP_Ende'] | tei:p[@rend='Sitzungsverlauf'][preceding-sibling::tei:p[@rend='Sitzungsverlauf']]" mode="pass1">
        <!-- remove this paragraphs, processed in tei:p[@rend='epf_SVP_Überschrift'] template -->
    </xsl:template>
    
    <xsl:template match="tei:p[@rend='epf_SVP_Anker']" mode="pass1">
        <milestone unit="section" n="{.}">
            <xsl:attribute name="xml:id">
                <!-- Is the identifier always a capital letter? -->
                <xsl:analyze-string select="." regex="[A-Z]+">
                    <xsl:matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:attribute>
        </milestone>
    </xsl:template>
    
    <!-- The anchor may not be labeled with the epf_SVP_Anker Word style, so we will label them according to their record in square brackets. -->
    <xsl:template match="tei:p[@rend='epf_Grundtext' or @rend='Grundtext'][matches(.,'^\[[A-Z]+\.\]$')]" mode="pass1">
        <milestone unit="section" n="{.}">
            <xsl:attribute name="xml:id">
                <xsl:analyze-string select="." regex="[A-Z]+">
                    <xsl:matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:attribute>
        </milestone>
    </xsl:template>
    
    
    <!-- Identity Transform: Pass 2 -->
    <xsl:template match="@* | node()" mode="pass2">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="pass2"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:list[@type='agenda']/tei:item" mode="pass2">
        <item>
            <xsl:attribute name="corresp">
                <xsl:analyze-string select=" normalize-space(.)" regex="^([A-Z]+)(\.)">
                    <xsl:matching-substring>
                        <xsl:value-of select="concat('#',regex-group(1))"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:attribute>
            <xsl:apply-templates mode="pass2"/>
        </item>
    </xsl:template>
    
    <xsl:template match="tei:opener" mode="pass2">
        <xsl:variable name="metadata-tex" select="text()"/>
        <opener>
            <xsl:analyze-string select="normalize-space(text())" regex="^(.*?)(\sTitel:\s)(».*?«)(\.\sBeginn:\s)(.*)(\sUhr\.\sAufnahmedauer:\s)(.*?)(\.\sVorsitz:\s)(.*?)(\.)$">
                <xsl:matching-substring>
                    <idno>
                        <xsl:value-of select="regex-group(1)"/>
                    </idno>
                    <xsl:value-of select="regex-group(2)"/>
                    <title>
                        <xsl:value-of select="regex-group(3)"/>
                    </title>
                    <xsl:value-of select=" regex-group(4)"/>
                    <time>
                        <xsl:variable name="time" select="translate(regex-group(5),'.',':')"/>
                        <xsl:variable name="time-h" select="tokenize($time,':')[1]"/>
                        <xsl:variable name="time-m" select="tokenize($time,':')[2]"/>
                        <xsl:variable name="time-s" select="tokenize($time,':')[3]"/>
                        <xsl:attribute name="when">
                            <xsl:value-of select="concat($date,'T',format-number(number($time-h),'00'))"/>
                            <xsl:value-of select="if (string-length($time-m) gt 0) then concat(':',format-number(number($time-m),'00')) else ':00'"/>
                            <xsl:value-of select="if (string-length($time-s) gt 0) then concat(':',format-number(number($time-s),'00')) else ':00'"/>
                        </xsl:attribute>
                        <xsl:value-of select="regex-group(5)"/>
                    </time>
                    <xsl:value-of select="regex-group(6)"/>
                    <time>
                        <xsl:variable name="duration-H" select="tokenize(regex-group(7),':')[1]"/>
                        <xsl:variable name="duration-M" select="tokenize(regex-group(7),':')[2]"/>
                        <xsl:variable name="duration-S" select="tokenize(regex-group(7),':')[3]"/>
                        <xsl:attribute name="dur">
                            <xsl:value-of select="concat('PT',$duration-H,'H',$duration-M,'M',$duration-S,'S')"/>
                        </xsl:attribute>
                        <xsl:value-of select="regex-group(7)"/>
                    </time>
                    <xsl:value-of select="regex-group(8)"/>
                    <persName type="chair">
                        <xsl:value-of select="regex-group(9)"/>
                    </persName>
                    <xsl:value-of select="regex-group(10)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="."/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
            <!-- apply only element nodes without text() node -->
            <xsl:apply-templates select="*" mode="pass2"/>
        </opener>
    </xsl:template>
    
    <xsl:template match="@* | node()" mode="pass3">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="pass3"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:body/tei:div" mode="pass3">
        <div>
            <xsl:for-each-group select="*" group-starting-with="self::tei:p[@rend='epf_Grundtext' or @rend='Grundtext'][tei:hi[@rend='bold']]">
                <u>
                    <xsl:for-each select="current-group()">
                        <xsl:element name="{name()}">
                            <xsl:apply-templates select="@*" mode="pass3"/>
                            <xsl:apply-templates mode="pass3"/>
                        </xsl:element>
                    </xsl:for-each>
                </u>
            </xsl:for-each-group>
        </div>
    </xsl:template>
    
    <xsl:template match="@* | node()" mode="pass4">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="pass4"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:div/tei:u[1]" mode="pass4">
        <xsl:apply-templates mode="pass4"/>
    </xsl:template>
    
    <xsl:template match="tei:u/tei:p" mode="pass4">
        <seg>
            <xsl:apply-templates mode="pass4"/>
        </seg>
    </xsl:template>
    
    <xsl:template match="tei:u/tei:p/tei:hi[@rend='bold']" mode="pass4">
        <xsl:apply-templates mode="pass4"/>
    </xsl:template>
    
    <xsl:template match="tei:u/tei:p/tei:hi[@rend='italic']" mode="pass4">
        <persName>
            <xsl:apply-templates mode="pass4"/>
        </persName>
    </xsl:template>
    
    <xsl:template match="@* | node()" mode="pass5">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="pass5"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:u" mode="pass5">
        <u>
            <note type="speaker">
                <xsl:analyze-string select="tei:seg[1]" regex="(^.*?:)(\s)">
                    <xsl:matching-substring>
                        <xsl:value-of select="regex-group(1)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </note>
            <xsl:apply-templates mode="pass5"/>
        </u>
    </xsl:template>
    
    <xsl:template match="tei:u/tei:seg[1]/text()[1]" mode="pass5">
        <xsl:analyze-string select="." regex="(^.*?:)(\s)">
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:template match="@* | node()" mode="pass6">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" mode="pass6"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:seg" mode="pass6">
        <xsl:choose>
            <xsl:when test="matches(normalize-space(.),'^\(.*?\)$')">
                <note type="comment">
                    <xsl:apply-templates mode="pass6"/>
                </note>
            </xsl:when>
            <xsl:otherwise>
                <seg>
                    <xsl:apply-templates mode="pass6"/>
                </seg>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>