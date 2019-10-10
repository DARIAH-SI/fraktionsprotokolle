<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs tei"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <!-- XSLT multi-pass technique -->
    <xsl:template match="/">
        <xsl:variable name="var1">
            <xsl:apply-templates mode="pass1"/>
        </xsl:variable>
        <xsl:variable name="var2">
            <xsl:apply-templates select="$var1" mode="pass2"/>
        </xsl:variable>
        <xsl:copy-of select="$var2"/>
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
            <xsl:if test="preceding-sibling::tei:p[@rend='epf_Dok_Nummer']">
                <xsl:attribute name="n">
                    <xsl:value-of select="preceding-sibling::tei:p[@rend='epf_Dok_Nummer']"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates mode="pass1"/>
        </head>
    </xsl:template>
    
    <xsl:template match="tei:p[@rend='epf_Dok_Nummer']" mode="pass1">
        <!-- remove number proccessed with title -->
    </xsl:template>
    
    <xsl:template match="tei:hi[contains(@style,'font-size:')]" mode="pass1">
        <!-- remove font-size without semantic meaning -->
    </xsl:template>
    
    <xsl:template match="tei:p[@rend='epf_Dok_Kopf']" mode="pass1">
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
    
    <xsl:template match="tei:p[@rend='epf_SVP_Überschrift']" mode="pass1">
        <list type="agenda">
            <head>
                <xsl:apply-templates mode="pass1"/>
            </head>
            <xsl:for-each select="following-sibling::tei:p[@rend='epf_SVP'] | following-sibling::tei:p[@rend='epf_SVP_Ende']">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </list>
    </xsl:template>
    
    <xsl:template match="tei:p[@rend='epf_SVP'] | tei:p[@rend='epf_SVP_Ende']" mode="pass1">
        <!-- remove this paragraphs, processed in tei:p[@rend='epf_SVP_Überschrift'] template -->
    </xsl:template>
    
    <xsl:template match="tei:p[@rend='epf_SVP_Anker']" mode="pass1">
        <milestone unit="section" n="{.}">
            <xsl:attribute name="xml:id">
                <!-- ali je identifikator vedno velika črka? -->
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
    
    <xsl:template match="tei:list[@type='agenda']/tei:head[@rend]" mode="pass2">
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
    
    
    
    
</xsl:stylesheet>