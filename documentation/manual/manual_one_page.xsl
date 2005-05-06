<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  version='1.0'>

<xsl:import href="http://docbook.sourceforge.net/release/xsl/current/xhtml/docbook.xsl"/>

<xsl:param name="navig.graphics" select="0"/>
<xsl:param name="navig.showtitles" select="1"/>
<xsl:param name="generate.section.toc.level" select="2"/>
<xsl:param name="toc.section.depth" select="3"/>

<xsl:param name="section.autolabel" select="1"/>

<xsl:param name="section.label.includes.component.label" select="1"/>
<xsl:param name="graphic.default.extension" select="'png'"/>

<xsl:template match="index">
  <xsl:if test="count(*)&gt;0 or $generate.index != '0'">
    <div class="{name(.)}">
      <xsl:if test="$generate.id.attributes != 0">
        <xsl:attribute name="id">
          <xsl:call-template name="object.id"/>
        </xsl:attribute>
      </xsl:if>

      <xsl:call-template name="index.titlepage"/>
      <xsl:choose>
        <xsl:when test="count(indexentry)!=0">
          <dl>
            <xsl:apply-templates/>
          </dl>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="count(indexentry) = 0 and count(indexdiv) = 0">
        <xsl:call-template name="generate-index">
          <xsl:with-param name="scope" select="(ancestor::book|/)[last()]"/>
        </xsl:call-template>
      </xsl:if>

      <xsl:if test="not(parent::article)">
        <xsl:call-template name="process.footnotes"/>
      </xsl:if>
    </div>
  </xsl:if>
</xsl:template>


</xsl:stylesheet>
