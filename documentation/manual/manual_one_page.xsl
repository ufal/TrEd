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

<xsl:template match="*[@revisionflag]">
  <xsl:choose>
    <xsl:when test="$show.revisionflag=1">
      <xsl:choose>
        <xsl:when test="local-name(.) = 'para'
                     or local-name(.) = 'simpara'
                     or local-name(.) = 'formalpara'
                     or local-name(.) = 'section'
                     or local-name(.) = 'sect1'
                     or local-name(.) = 'sect2'
                     or local-name(.) = 'sect3'
                     or local-name(.) = 'sect4'
                     or local-name(.) = 'sect5'
                     or local-name(.) = 'chapter'
                     or local-name(.) = 'preface'
                     or local-name(.) = 'itemizedlist'
                     or local-name(.) = 'varlistentry'
                     or local-name(.) = 'glossary'
                     or local-name(.) = 'bibliography'
                     or local-name(.) = 'index'
                     or local-name(.) = 'appendix'">
          <div class="{@revisionflag}">
            <xsl:apply-imports/>
          </div>
        </xsl:when>
        <xsl:when test="local-name(.) = 'phrase'
                     or local-name(.) = 'ulink'
                     or local-name(.) = 'link'
                     or local-name(.) = 'filename'
                     or local-name(.) = 'literal'
                     or local-name(.) = 'member'
                     or local-name(.) = 'glossterm'
                     or local-name(.) = 'sgmltag'
                     or local-name(.) = 'quote'
                     or local-name(.) = 'emphasis'
                     or local-name(.) = 'command'
                     or local-name(.) = 'xref'">
          <span class="{@revisionflag}">
            <xsl:apply-imports/>
          </span>
        </xsl:when>
        <xsl:when test="local-name(.) = 'listitem'
                     or local-name(.) = 'entry'
                     or local-name(.) = 'title'">
          <!-- nop; these are handled directly in the stylesheet -->
          <xsl:apply-imports/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>
            <xsl:text>Revisionflag on unexpected element: </xsl:text>
            <xsl:value-of select="local-name(.)"/>
            <xsl:text> (Assuming block)</xsl:text>
          </xsl:message>
          <div class="{@revisionflag}">
            <xsl:apply-imports/>
          </div>
        </xsl:otherwise>      
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-imports/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:param name="appendix.autolabel" select="0"/>

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
