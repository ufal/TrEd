<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version='1.0'>

<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/xhtml/chunk.xsl"/>

<xsl:param name="navig.graphics" select="0"/>
<xsl:param name="navig.showtitles" select="1"/>
<xsl:param name="generate.section.toc.level" select="2"/>
<xsl:param name="toc.section.depth" select="3"/>
<xsl:param name="chunk.tocs.and.lots" select="1"/>
<!--
<xsl:param name="encoding" select="'utf-8'"/>   
<xsl:param name="default.encoding" select="'utf-8'"/>
<xsl:param name="chunker.output.doctype-public" select="'-//W3C//DTD HTML 4.0 Transitional//EN'"/>
<xsl:output method="html" encoding="utf-8" doctype-public="-//W3C//DTD HTML 4.0 Transitional//EN" indent="yes"/>  
-->

<xsl:param name="section.autolabel" select="1"/>

<xsl:param name="section.label.includes.component.label" select="1"/>
<xsl:param name="graphic.default.extension" select="'png'"/>

</xsl:stylesheet>
