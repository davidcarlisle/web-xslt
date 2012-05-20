<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:m="http://www.w3.org/1998/Math/MathML"
		xmlns:c="http://exslt.org/common"
		exclude-result-prefixes="m c">

<xsl:template match="*">
<xsl:copy>
 <xsl:copy-of select="@*"/>
<xsl:apply-templates/>
</xsl:copy>
</xsl:template>

<xsl:template match="*[@dir='rtl']"  priority="10">
<!--starting rtl <xsl:value-of select="name()"/>.-->
  <xsl:apply-templates mode="rtl" select="."/>
</xsl:template>

<xsl:template match="@*" mode="rtl">
  <xsl:copy-of select="."/>
</xsl:template>
<xsl:template match="*" mode="rtl">
 <xsl:copy>
    <xsl:apply-templates select="@*" mode="rtl"/>
    <xsl:for-each select="node()">
      <xsl:sort data-type="number" order="descending" select="position()"/>
<!--child <xsl:value-of select="name()"/>, <xsl:value-of select="position()"/> of <xsl:value-of select="name(..)"/>-->
<xsl:text> </xsl:text>
      <xsl:apply-templates mode="rtl" select="."/>
    </xsl:for-each>
  </xsl:copy>
</xsl:template>

<xsl:template match="@open" mode="rtl">
    <xsl:attribute name="close"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@open[.='(']" mode="rtl">
    <xsl:attribute name="close">)</xsl:attribute>
</xsl:template>

<xsl:template match="@open[.=')']" mode="rtl">
    <xsl:attribute name="close">(</xsl:attribute>
</xsl:template>


<xsl:template match="@open[.='[']" mode="rtl">
    <xsl:attribute name="close">]</xsl:attribute>
</xsl:template>


<xsl:template match="@open[.=']']" mode="rtl">
    <xsl:attribute name="close">[</xsl:attribute>
</xsl:template>


<xsl:template match="@open[.='{']" mode="rtl">
    <xsl:attribute name="close">}</xsl:attribute>
</xsl:template>


<xsl:template match="@open[.='}']" mode="rtl">
    <xsl:attribute name="close">{</xsl:attribute>
</xsl:template>


<xsl:template match="@close" mode="rtl">
    <xsl:attribute name="open"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="@close[.='(']" mode="rtl">
    <xsl:attribute name="open">)</xsl:attribute>
</xsl:template>

<xsl:template match="@close[.=')']" mode="rtl">
    <xsl:attribute name="open">(</xsl:attribute>
</xsl:template>


<xsl:template match="@close[.='[']" mode="rtl">
    <xsl:attribute name="open">]</xsl:attribute>
</xsl:template>


<xsl:template match="@close[.=']']" mode="rtl">
    <xsl:attribute name="open">[</xsl:attribute>
</xsl:template>


<xsl:template match="@close[.='{']" mode="rtl">
    <xsl:attribute name="open">}</xsl:attribute>
</xsl:template>


<xsl:template match="@close[.='}']" mode="rtl">
    <xsl:attribute name="open">{</xsl:attribute>
</xsl:template>

<xsl:template match="m:mfrac[@bevelled='true']" mode="rtl">
<m:mrow>
<m:msub><m:mi></m:mi><xsl:apply-templates select="*[2]" mode="rtl"/></m:msub>
<m:mo>&#x5c;</m:mo>
<m:msup><m:mi></m:mi><xsl:apply-templates select="*[1]" mode="rtl"/></m:msup>
</m:mrow>
</xsl:template>

<xsl:template match="m:mfrac" mode="rtl">
<xsl:copy>
 <xsl:apply-templates mode="rtl" select="@*|*"/>
</xsl:copy>
</xsl:template>



<xsl:template match="m:mroot" mode="rtl">
<m:msup>
<m:menclose notation="top right">
 <xsl:apply-templates mode="rtl" select="@*|*[1]"/>
</m:menclose>
<xsl:apply-templates mode="rtl" select="*[2]"/>
</m:msup>
</xsl:template>


<xsl:template match="m:msqrt" mode="rtl">
<m:menclose notation="top right">
 <xsl:apply-templates mode="rtl" select="@*|*[1]"/>
</m:menclose>
</xsl:template>

<xsl:template match="m:mtable|m:munder|m:mover|m:munderover" mode="rtl" priority="2">
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
    <xsl:for-each  select="m:mprescripts/following-sibling::*[position() mod 2 = 1]">
      <xsl:sort data-type="number" order="descending" select="position()"/>
      <xsl:apply-templates select="."  mode="rtl"/>
      <xsl:apply-templates select="following-sibling::*[1]"  mode="rtl"/>
    </xsl:for-each>
    <m:mprescripts/>
    <xsl:for-each  select="m:mprescripts/preceding-sibling::*[position()!=last()][position() mod 2 = 0]">
      <xsl:sort data-type="number" order="descending" select="position()"/>
      <xsl:apply-templates select="."  mode="rtl"/>
      <xsl:apply-templates select="following-sibling::*[1]"  mode="rtl"/>
    </xsl:for-each>
  </m:mmultiscripts>
</xsl:template>
<xsl:template match="m:mmultiscripts[not(m:mprescripts)]" mode="rtl" priority="3">
  <m:mmultiscripts>
    <xsl:apply-templates select="*[1]" mode="rtl"/>
    <m:mprescripts/>
    <xsl:for-each  select="*[position() mod 2 = 0]">
      <xsl:sort data-type="number" order="descending" select="position()"/>
      <xsl:apply-templates select="."  mode="rtl"/>
      <xsl:apply-templates select="following-sibling::*[1]"  mode="rtl"/>
    </xsl:for-each>
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

<xsl:template match="@notation[.='radical']" mode="rtl">
<xsl:attribute name="notation">top right</xsl:attribute>
</xsl:template>


<!-- attributes-->
<xsl:template name="mml2attrib">
<!--
  <xsl:copy-of select="@*[not(local-name()='href')]"/>
-->
  <xsl:copy-of select="@*[not(local-name()='href')]"/>
  <xsl:attribute name="style">
    <xsl:if test="@style"><xsl:value-of select="@style"/>;</xsl:if>
    <xsl:if test="@mathcolor">color:<xsl:value-of select="@mathcolor"/>;</xsl:if>
    <xsl:if test="@mathbackground">background-color:<xsl:value-of select="@mathbackground"/>;</xsl:if>
  </xsl:attribute>
</xsl:template>

<!-- links -->
<!--
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
-->
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
   <xsl:apply-templates select="*" mode="mstack1"/>
  </xsl:variable>
  <xsl:variable name="maxl">
   <xsl:for-each select="c:node-set($t)/*/@l">
    <xsl:sort data-type="number" order="descending"/>
    <xsl:if test="position()=1">
     <xsl:value-of select="."/>
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>
  <xsl:for-each select="c:node-set($t)/*">
   <xsl:text>&#10;</xsl:text>
   <m:mtr l="{@l}">
    <xsl:variable name="offset" select="$maxl - @l"/>
    <xsl:choose>
     <xsl:when test="@class='msline' and (string(*[1]/@columnspan)='' or string(*[1]/@columnspan)='0')">
      <m:mtd columnspan="{$maxl}">
      <xsl:copy-of select="*/@style"/></m:mtd>
     </xsl:when>
     <xsl:otherwise>
      <xsl:for-each select="(//*)[position()&lt;= $offset]"><m:mtd/></xsl:for-each>
      <xsl:copy-of select="*"/>
     </xsl:otherwise>
    </xsl:choose>
   </m:mtr>
  </xsl:for-each>
 </m:mtable>
</xsl:template>

<xsl:template mode="mstack1" match="*">
 <xsl:param name="maxl" select="0"/>
 <m:mtr l="1"><!-- @l = number of entries to left of alignment -->
  <xsl:if test="ancestor::mstack[1]/@stackalign='left'">
   <xsl:attribute name="l">0</xsl:attribute>
  </xsl:if>
  <m:mtd><xsl:apply-templates select="."/></m:mtd>
 </m:mtr>
</xsl:template>

<!-- l is number of entries except left of  alignment -->
<xsl:template mode="mstack1" match="m:msrow">
 <xsl:param name="maxl" select="0"/>
 <xsl:variable name="row">
  <xsl:apply-templates mode="mstack1" select="*"/>
 </xsl:variable>
 <xsl:text>&#10;</xsl:text>
 <xsl:variable name="l1">
  <xsl:choose>
   <xsl:when test="m:mn">
    <xsl:for-each select="c:node-set($row)/m:mtr[m:mtd/m:mn][1]">
     <xsl:value-of select="sum(@l)+count(preceding-sibling::*/@l)"/>
    </xsl:for-each>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="c:node-set($row)/m:mtr[1]/@l"/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <m:mtr class="msrow">
  <xsl:attribute name="l">
   <xsl:choose>
    <xsl:when test="@position">0000<xsl:text/>
    <xsl:value-of select="$l1 + @position"/>
    </xsl:when>
    <xsl:otherwise>000<xsl:text/>
    <xsl:value-of select="$l1"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:attribute>
  <xsl:copy-of select="c:node-set($row)/m:mtr/*"/>
 </m:mtr>
</xsl:template>

<xsl:template mode="mstack1" match="m:mn">
 <xsl:variable  name="align1" select="ancestor::m:mstack[1]/@stackalign"/>
 <xsl:variable name="align">
  <xsl:choose>
   <xsl:when test="string($align1)=''">decimalpoint</xsl:when>
   <xsl:otherwise><xsl:value-of select="$align1"/></xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <m:mtr l="0"><!-- @l = number of entries to leftof alignment -->
  <xsl:variable name="mn" select="normalize-space(.)"/>
  <xsl:variable name="len" select="string-length($mn)"/>
  <xsl:choose>
   <xsl:when test="$align='right' or ($align='decimalpoint' and not(contains($mn,'.')))">
    <xsl:attribute name="l">00<xsl:value-of select="$len"/></xsl:attribute>
   </xsl:when>
   <xsl:when test="$align='decimalpoint'">
    <xsl:attribute name="l"><xsl:value-of select="string-length(substring-before($mn,'.'))"/></xsl:attribute>
   </xsl:when>
  </xsl:choose>

  <xsl:for-each select="(//node())[position() &lt;=$len]">
   <xsl:variable name="p" select="position()"/>
   <m:mtd><m:mn><xsl:value-of select="substring($mn,$p,1)"/></m:mn></m:mtd>
  </xsl:for-each>
 </m:mtr>
</xsl:template>


<xsl:template match="m:msgroup" mode="mstack1">
 <xsl:variable name="g">
  <xsl:apply-templates select="*" mode="mstack1"/>
 </xsl:variable>
 <xsl:choose>
  <xsl:when test="@shift or @position">
   <xsl:variable name="s" select="sum(@shift)"/>
   <xsl:variable name="p" select="sum(@position)"/>
   <xsl:for-each select="c:node-set($g)/*">
    <xsl:copy>
     <xsl:copy-of select="@*"/>
     <xsl:attribute name="l"><xsl:value-of select="number(sum(@l)) + (position() - 1)*number($s) + number($p)"/></xsl:attribute>
     <xsl:copy-of select="*"/>
    </xsl:copy>
   </xsl:for-each>
  </xsl:when>
  <xsl:otherwise>
   <xsl:copy-of select="$g"/>
  </xsl:otherwise>
 </xsl:choose>

</xsl:template>


<xsl:template match="m:msline" mode="mstack1">
 <xsl:variable  name="align1" select="ancestor::m:mstack[1]/@stackalign"/>
 <xsl:variable name="align">
  <xsl:choose>
   <xsl:when test="string($align1)=''">decimalpoint</xsl:when>
   <xsl:otherwise><xsl:value-of select="$align1"/></xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <m:mtr class="msline">
  <xsl:attribute name="l">
   <xsl:choose>
    <xsl:when test="string($align)='right' or string($align)='decimalpoint' "><xsl:value-of select="@length"/></xsl:when>
    <xsl:otherwise>0</xsl:otherwise>
   </xsl:choose>
  </xsl:attribute>
  <m:mtd class="msline" columnspan="{@length}">
   <xsl:copy-of select="@position"/>
   <xsl:variable name="w">
    <xsl:choose>
     <xsl:when test="@mslinethickness='thin'">0.1em</xsl:when>
     <xsl:when test="@mslinethickness='medium'">0.15em</xsl:when>
     <xsl:when test="@mslinethickness='thick'">0.2em</xsl:when>
     <xsl:when test="@mslinethickness"><xsl:value-of select="@mslinethickness"/></xsl:when>
     <xsl:otherwise>0.15em</xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <xsl:attribute name="style">
    <xsl:value-of select="concat('border-style: solid; border-width: 0 0 ',$w,' 0')"/>
   </xsl:attribute>
  </m:mtd>
 </m:mtr>
</xsl:template>


<xsl:template match="m:mscarries" mode="mstack1">
 <xsl:variable  name="align1" select="ancestor::m:mstack[1]/@stackalign"/>
 <xsl:variable name="l1">
  <xsl:choose>
   <xsl:when test="string($align1)='left'">0</xsl:when>
   <xsl:otherwise><xsl:value-of select="count(*)"/></xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <m:mtr class="mscarries">
  <xsl:attribute name="l">
   <xsl:choose>
    <xsl:when test="@position">
     <xsl:value-of select="$l1 + @position"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="$l1"/>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:attribute>
  <xsl:apply-templates select="*" mode="msc"/>
 </m:mtr>
</xsl:template>

<xsl:template match="*" mode="msc">
 <m:mtd><m:mstyle mathsize="70%"><xsl:apply-templates select="."/></m:mstyle></m:mtd>
</xsl:template>


<xsl:template match="m:mlongdiv">
 <xsl:variable name="ms">
  <m:mstack>
   <xsl:copy-of select="*[2]"/>
   <m:msline/>
   <m:msrow>
    <m:mrow><xsl:copy-of select="*[1]"/></m:mrow>
    <m:mo>)</m:mo>
    <xsl:copy-of select="*[3]"/>
   </m:msrow>
   <xsl:copy-of select="*[position()&gt;3]"/>
  </m:mstack>
 </xsl:variable>
 <xsl:apply-templates select="c:node-set($ms)"/>
</xsl:template>



<!-- madruwb -->
<xsl:template match="m:menclose[@notation='madruwb']" mode="rtl">
<m:menclose notation="bottom right">
 <xsl:apply-templates mode="rtl"/>
</m:menclose>
</xsl:template>

</xsl:stylesheet>
