<?xml version="1.0" encoding="utf-8"?>
<!-- -*- mode: xsl; coding: utf8; -*- -->
<!-- Author: pajas@ufal.ms.mff.cuni.cz -->

<xsl:stylesheet
  xmlns:xsl='http://www.w3.org/1999/XSL/Transform' 
  xmlns:pod='http://axkit.org/ns/2000/pod2xml'
  version='1.0'>
<xsl:output method="xml" encoding="utf-8"/>

<xsl:param name="title"/>

<xsl:template match="/">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="pod:head">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="pod:pod">
  <article>
    <xsl:apply-templates/>
  </article>
</xsl:template>

<xsl:template match="pod:list">
  <variablelist>
    <xsl:apply-templates select="pod:item"/>
  </variablelist>
</xsl:template>
 
<xsl:template match="pod:item">
  <varlistentry>
    <xsl:apply-templates select="pod:itemtext"/>
    <listitem>
      <xsl:apply-templates select="node()[local-name()!='itemtext']"/>
      <xsl:apply-templates select="following-sibling::pod:*[not(self::pod:item) and (count(preceding-sibling::pod:item)=count(current()/preceding-sibling::pod:item)+1)]"/>
    </listitem>
  </varlistentry>
</xsl:template>

<xsl:template match="pod:itemtext">
  <term><xsl:apply-templates/></term>
</xsl:template>

<xsl:template match="pod:strong">
  <emphasis><xsl:apply-templates/></emphasis>
</xsl:template>

<xsl:template match="pod:para[pod:code and count(node()[normalize-space(.)!=' ' and normalize-space(.)!=''])=count(pod:code)]">
  <literallayout><xsl:apply-templates select="pod:code"/></literallayout>
</xsl:template>

<xsl:template match="pod:code">
  <literal><xsl:apply-templates/></literal>
</xsl:template>

<xsl:template match="pod:*">
  <xsl:element name="{local-name()}">
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="pod:*[starts-with(local-name(),'sect')]">
  <xsl:element name="section">
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>


<xsl:template match="pod:link/@xref">
  <xsl:attribute name="linkend">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="@*">
  <xsl:copy-of select="."/>
</xsl:template>


</xsl:stylesheet>
