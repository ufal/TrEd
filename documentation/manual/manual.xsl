<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version='1.0'>

<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/html/chunk.xsl"/>

<xsl:param name="encoding" select="'iso-8859-2'"/>   
<xsl:param name="default.encoding" select="'iso-8859-2'"/>
<xsl:param name="navig.graphics" select="0"/>
<xsl:param name="navig.showtitles" select="1"/>
<xsl:param name="generate.section.toc.level" select="2"/>
<xsl:param name="toc.section.depth" select="3"/>
<xsl:param name="chunk.tocs.and.lots" select="1"/>


<xsl:output method="html" encoding="iso-8859-2" indent="yes"/>  

<xsl:param name="section.autolabel" select="1"/>

<xsl:param name="section.label.includes.component.label" select="1"/>
<xsl:param name="graphic.default.extension" select="'png'"/>

</xsl:stylesheet>
