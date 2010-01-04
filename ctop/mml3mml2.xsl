<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:m="http://www.w3.org/1998/Math/MathML"
		xmlns:e="http://exslt.org/strings"
		xmlns:c="http://exslt.org/common">


<xsl:template match="*[@dir='rtl']" >
  <xsl:copy>
    <xsl:apply-templates select="@*|node()" mode="rtl"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="@*" mode="rtl">
  <xsl:copy-of select="."/>
</xsl:template>
<xsl:template match="*" mode="rtl">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="rtl"/>
    <xsl:apply-templates mode="rtl">
      <xsl:sort data-type="number" order="descending" select="position()"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>
<xsl:template match="mfenced" mode="rtl">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="rtl"/>
    <xsl:attribute name="open">
      <xsl:apply-templates select="@close" mode="rtl"/>
    </xsl:attribute>
    <xsl:attribute name="close">
      <xsl:apply-templates select="@open" mode="rtl"/>
    </xsl:attribute>
    <xsl:apply-templates mode="rtl">
      <xsl:sort data-type="number" order="descending" select="position()"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>
<xsl:template match="m:mtable|m:munder|m:over|m:munderover" mode="rtl" priority="2">
  <xsl:copy>
    <xsl:apply-templates select="@*" mode="rtl"/>
    <xsl:apply-templates mode="rtl">
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>
<xsl:template match="m:msup" mode="rtl" priority="2">
  <m:mmultiscripts>
    <xsl:apply-templates select="*[1]" mode="rtl"/>
    <m:mprescripts/>
    <m:none/>
    <xsl:apply-templates select="*[2]" mode="rtl"/>
  </m:mmultiscripts>
</xsl:template>
<xsl:template match="m:msub" mode="rtl" priority="2">
  <m:mmultiscripts>
    <xsl:apply-templates select="*[1]" mode="rtl"/>
    <m:mprescripts/>
    <xsl:apply-templates select="*[2]" mode="rtl"/>
    <m:none/>
  </m:mmultiscripts>
</xsl:template>
<xsl:template match="m:msubsup" mode="rtl" priority="2">
  <m:mmultiscripts>
    <xsl:apply-templates select="*[1]" mode="rtl"/>
    <m:mprescripts/>
    <xsl:apply-templates select="*[2]" mode="rtl"/>
    <xsl:apply-templates select="*[3]" mode="rtl"/>
  </m:mmultiscripts>
</xsl:template>
<xsl:template match="m:mmultiscripts" mode="rtl" priority="2">
  <m:mmultiscripts>
    <xsl:apply-templates select="*[1]" mode="rtl"/>
    <xsl:apply-templates select="m:mprescripts/following-sibling::*" mode="rtl">
      <xsl:sort data-type="number" order="descending" select="position()"/>
    </xsl:apply-templates>
    <m:mprescripts/>
    <xsl:apply-templates select="m:mprescripts/preceding-sibling::*[position()!=last()]" mode="rtl">
      <xsl:sort data-type="number" order="descending" select="position()"/>
    </xsl:apply-templates>
  </m:mmultiscripts>
</xsl:template>
<xsl:template match="text()[.='(']" mode="rtl">)</xsl:template>
<xsl:template match="text()[.=')']" mode="rtl">(</xsl:template>
<xsl:template match="text()[.='{']" mode="rtl">}</xsl:template>
<xsl:template match="text()[.='}']" mode="rtl">{</xsl:template>
<xsl:template match="text()[.='&lt;']" mode="rtl">&gt;</xsl:template>
<xsl:template match="text()[.='&gt;']" mode="rtl">&lt;</xsl:template>
<xsl:template match="text()[.='&#x2208;']" mode="rtl">&#x220b;</xsl:template>
<xsl:template match="text()[.='&#x220b;']" mode="rtl">&#x2208;</xsl:template>
<xsl:template match="text()[.='&#x2211;']|text()[.='&#x222b;']" mode="rtl">
  <svg width="20" height="20" version="1.1" xmlns="http://www.w3.org/2000/svg">
    <g transform="matrix(-1 0 0 1 0 0 )">
      <text id="TextElement" x="-20" y="15" >
	<xsl:value-of select="."/>
      </text>
    </g>
  </svg>
</xsl:template>

<!-- attributes-->
<xsl:template name="mml2attrib">
  <xsl:copy-of select="@*[not(local-name()='href')]"/>
  <xsl:attribute name="style">
    <xsl:if test="@style"><xsl:value-of select="@style"/>;</xsl:if>
    <xsl:if test="@mathcolor">color:<xsl:value-of select="@mathcolor"/>;</xsl:if>
    <xsl:if test="@mathbackground">background-color:<xsl:value-of select="@mathbackground"/>;</xsl:if>
  </xsl:attribute>
</xsl:template>

<!-- links -->

<xsl:template match="*[@href]" priority="3">
  <a xmlns="http://www.w3.org/1999/xhtml" style="text-decoration: none" href="{@href}">
    <xsl:copy>
      <xsl:call-template name="mml2attrib"/>
      <xsl:attribute name="class">
	<xsl:text>mmlhref </xsl:text>
	<xsl:value-of select="@class"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </a>
</xsl:template>

<xsl:template match="*[@mathcolor|@mathbackground]">
  <xsl:copy>
    <xsl:call-template name="mml2attrib"/>
    <xsl:apply-templates/>
  </xsl:copy>
</xsl:template>


<!-- mstack -->

<xsl:template match="m:mstack">
<m:mtable columnspacing="0em">
<xsl:variable name="t">
<xsl:apply-templates select="*" mode="mst"/>
</xsl:variable>
<xsl:apply-templates mode="p" select="c:node-set($t)/*">
  <xsl:with-param name="c" select="10"/>
</xsl:apply-templates>
</m:mtable>
</xsl:template>

<xsl:template match="m:mtr" mode="p">
<xsl:param name="c"/>
<xsl:copy>
<xsl:copy-of select="@*"/>
<xsl:variable name="n" select="$c - count(*)"/>
<xsl:for-each select="(//*)[position() &lt;= $n]">
  <m:mtd></m:mtd>
</xsl:for-each>
<xsl:copy-of select="*"/>
</xsl:copy>
</xsl:template>
<xsl:template match="*" mode="mst">
<m:mtr>
<xsl:apply-templates select="." mode="ms"/>
</m:mtr>
</xsl:template>

<xsl:template match="m:mn" mode="ms">
<xsl:for-each select="e:tokenize(.,'')">
<m:mtd><m:mn><xsl:value-of select="."/></m:mn></m:mtd>
</xsl:for-each>
</xsl:template>

<xsl:template match="m:msrow" mode="ms">
<xsl:apply-templates select="*" mode="ms"/>
</xsl:template>

<xsl:template match="*" mode="ms">
<m:mtd><xsl:apply-templates select="."/></m:mtd>
</xsl:template>

<xsl:template match="m:msline" mode="ms">
<xsl:attribute name="style">border: solid black thin</xsl:attribute>
<m:mtd>
<xsl:attribute name="style">border: solid black thin</xsl:attribute>
</m:mtd>
</xsl:template>


<xsl:template match="m:mscarries" mode="ms">
<xsl:apply-templates select="*" mode="msc"/>
</xsl:template>

<xsl:template match="*" mode="msc">
<m:mtd mathfontsize="0.7"><xsl:apply-templates select="."/></m:mtd>
</xsl:template>



<xsl:template match="m:msgroup" mode="mst">
<xsl:for-each select="*">
<m:mtr>
<xsl:apply-templates select="." mode="ms"/>
<xsl:if test="../@shift">
<xsl:variable name="n" select="position() * ../@shift"/>
<xsl:for-each select="(//*)[position() &lt;= $n]">
<m:mtd></m:mtd>
</xsl:for-each>
</xsl:if>
</m:mtr>
</xsl:for-each>
</xsl:template>


<xsl:template match="m:mlongdiv">
<m:mtable columnspacing="0em">
<xsl:variable name="t">
<xsl:apply-templates select="*[position()&gt;2]" mode="mst"/>
</xsl:variable>
<xsl:apply-templates mode="p" select="c:node-set($t)/*">
  <xsl:with-param name="c" select="10"/>
</xsl:apply-templates>
</m:mtable>
</xsl:template>

</xsl:stylesheet>
