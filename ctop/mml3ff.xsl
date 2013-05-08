<!--

Copyright David Carlisle 2008-2012.

Use and distribution of this code are permitted under the terms of the <a
href="http://www.w3.org/Consortium/Legal/copyright-software-19980720"
>W3C Software Notice and License</a>.
Or the Apache 2, MIT or MPL 1.1 or MPL 2.0 licences.
-->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:m="http://www.w3.org/1998/Math/MathML"
		xmlns="http://www.w3.org/1998/Math/MathML"
		xmlns:c="http://exslt.org/common"
		exclude-result-prefixes="m c">

<xsl:output indent="yes" omit-xml-declaration="yes"/>

<xsl:template match="*">
 <xsl:copy>
  <xsl:copy-of select="@*"/>
  <xsl:apply-templates/>
 </xsl:copy>
</xsl:template>


<!-- mlabeledtr-->
<xsl:template match="m:mlabeledtr">
<mtr>
<xsl:copy-of select="@*"/>
<xsl:apply-templates select="*[position()!=1]"/>
<mtd><mspace width="3em"/><xsl:apply-templates select="*[1]/*"/></mtd>
</mtr>
</xsl:template>

<xsl:template match="m:mtable[m:mlabeledtr]/m:mtr">
<mtr>
<xsl:copy-of select="@*"/>
<xsl:apply-templates select="*[position()!=1]"/>
<mtd></mtd>
</mtr>
</xsl:template>


<!-- mstack -->
<xsl:param name="hascolspan" select="true()"/>

<xsl:template match="m:mstack">
 <mtable columnspacing="0em">
  <xsl:variable name="t">
   <xsl:apply-templates select="*" mode="mstack1">
    <xsl:with-param name="p" select="0"/>
   </xsl:apply-templates>
  </xsl:variable>
  <xsl:variable name="maxl">
   <xsl:for-each select="c:node-set($t)/*/@l">
    <xsl:sort data-type="number" order="descending"/>
    <xsl:if test="position()=1">
     <xsl:value-of select="."/>
    </xsl:if>
   </xsl:for-each>
  </xsl:variable>
  <xsl:for-each select="c:node-set($t)/*[not(@class='mscarries') or following-sibling::*[1]/@class='mscarries']">
<xsl:variable name="c" select="preceding-sibling::*[1][@class='mscarries']"/>
   <xsl:text>&#10;</xsl:text>
   <mtr>
    <xsl:variable name="offset" select="$maxl - @l"/>
    <xsl:choose>
     <xsl:when test="$hascolspan and @class='msline' and (string(*[1]/@columnspan)='' or string(*[1]/@columnspan)='0')">
      <mtd columnspan="{$maxl}">
      <xsl:copy-of select="*/@style"/></mtd>
     </xsl:when>
     <xsl:when test="@class='msline' and @l='*'">
      <xsl:variable name="msl" select="*[1]"/>
      <xsl:for-each select="(//node())[position()&lt;=$maxl]">
       <xsl:copy-of select="$msl"/>
      </xsl:for-each>
     </xsl:when>
     <xsl:when test="$c">
      <xsl:variable name="ldiff" select="$c/@l - @l"/>
      <xsl:variable name="loffset" select="$maxl - $c/@l"/>
      <xsl:for-each select="(//*)[position()&lt;= $offset]">
       <xsl:variable name="pn" select="position()"/>
       <xsl:variable name="cy" select="$c/*[position()=$pn - $loffset]"/>
	 <mtd>
	  <xsl:if test="$cy/*"/>
	  <mover><mphantom><mn>0</mn></mphantom><mpadded width="0em" lspace="-0.5width"><xsl:copy-of select="$cy/*/*"/></mpadded></mover>
	 </mtd>
      </xsl:for-each>
      <xsl:for-each select="*">
       <xsl:variable name="pn" select="position()"/>
       <xsl:variable name="cy" select="$c/*[position()=$pn + $ldiff]"/>
       <xsl:copy>
	<xsl:copy-of select="@*"/>
	<xsl:variable name="b">
	 <xsl:choose>
	  <xsl:when test="not(string($cy/@crossout) or $cy/@crossout='none')"><xsl:copy-of select="*"/></xsl:when>
	  <xsl:otherwise>
	   <menclose notation="{$cy/@crossout}"><xsl:copy-of select="*"/></menclose>
	  </xsl:otherwise>
	 </xsl:choose>
	</xsl:variable>
	<xsl:choose>
	 <xsl:when test="$cy/*/m:none or not($cy/*/*)"><xsl:copy-of select="$b"/></xsl:when>
	 <xsl:when test="not(string($cy/@location)) or $cy/@location='n'">
	  <mover><xsl:copy-of select="$b"/><mpadded width="0em" lspace="-0.5width"><xsl:copy-of select="$cy/*/*"/></mpadded></mover>
	 </xsl:when>
	 <xsl:when test="$cy/@location='nw'">
	  <mmultiscripts><xsl:copy-of select="$b"/><mprescripts/><none/><mpadded lspace="-1width" width="0em"><xsl:copy-of select="$cy/*/*"/></mpadded></mmultiscripts>
	 </xsl:when>
	 <xsl:when test="$cy/@location='s'">
	  <munder><xsl:copy-of select="$b"/><mpadded width="0em" lspace="-0.5width"><xsl:copy-of select="$cy/*/*"/></mpadded></munder>
	 </xsl:when>
	 <xsl:when test="$cy/@location='sw'">
	  <mmultiscripts><xsl:copy-of select="$b"/><mprescripts/><mpadded lspace="-1width" width="0em"><xsl:copy-of select="$cy/*/*"/></mpadded><none/></mmultiscripts>
	 </xsl:when>
	 <xsl:when test="$cy/@location='ne'">
	  <msup><xsl:copy-of select="$b"/><mpadded width="0em"><xsl:copy-of select="$cy/*/*"/></mpadded></msup>
	 </xsl:when>
	 <xsl:when test="$cy/@location='se'">
	  <msub><xsl:copy-of select="$b"/><mpadded width="0em"><xsl:copy-of select="$cy/*/*"/></mpadded></msub>
	 </xsl:when>
	 <xsl:when test="$cy/@location='w'">
	  <msup><mrow/><mpadded lspace="-1width" width="0em"><xsl:copy-of select="$cy/*/*"/></mpadded></msup>
	  <xsl:copy-of select="$b"/>
	 </xsl:when>
	 <xsl:when test="$cy/@location='e'">
	  <xsl:copy-of select="$b"/>
	  <msup><mrow/><mpadded width="0em"><xsl:copy-of select="$cy/*/*"/></mpadded></msup>
	 </xsl:when>
	 <xsl:otherwise>
	  <xsl:copy-of select="$b"/>
	 </xsl:otherwise>
	</xsl:choose>
       </xsl:copy>
      </xsl:for-each>
     </xsl:when>
     <xsl:otherwise>
      <xsl:for-each select="(//*)[position()&lt;= $offset]"><mtd/></xsl:for-each>
      <xsl:copy-of select="*"/>
     </xsl:otherwise>
    </xsl:choose>
   </mtr>
  </xsl:for-each>
 </mtable>
</xsl:template>

<xsl:template mode="mstack1" match="*">
 <xsl:param name="p"/>
 <xsl:param name="maxl" select="0"/>
 <mtr l="{1 + $p}">
  <xsl:if test="ancestor::mstack[1]/@stackalign='left'">
   <xsl:attribute name="l"><xsl:value-of  select="$p"/></xsl:attribute>
  </xsl:if>
  <mtd><xsl:apply-templates select="."/></mtd>
 </mtr>
</xsl:template>

<!-- l is number of entries except left of  alignment -->
<xsl:template mode="mstack1" match="m:msrow">
 <xsl:param name="p"/>
 <xsl:param name="maxl" select="0"/>
 <xsl:variable  name="align1" select="ancestor::m:mstack[1]/@stackalign"/>
 <xsl:variable name="align">
  <xsl:choose>
   <xsl:when test="string($align1)=''">decimalpoint</xsl:when>
   <xsl:otherwise><xsl:value-of select="$align1"/></xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <xsl:variable name="row">
  <xsl:apply-templates mode="mstack1" select="*">
   <xsl:with-param name="p" select="0"/>
  </xsl:apply-templates>
 </xsl:variable>
 <xsl:text>&#10;</xsl:text>
 <xsl:variable name="l1">
  <xsl:choose>
   <xsl:when test="$align='decimalpoint' and m:mn">
    <xsl:for-each select="c:node-set($row)/m:mtr[m:mtd/m:mn][1]">
     <xsl:value-of select="number(sum(@l))+count(preceding-sibling::*/@l)"/>
    </xsl:for-each>
   </xsl:when>
   <xsl:when test="$align='right' or $align='decimalpoint'">
    <xsl:value-of select="count(c:node-set($row)/m:mtr/m:mtd)"/>
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="0"/>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <mtr class="msrow" l="{number($l1) + number(sum(@position)) +$p}">
  <xsl:copy-of select="c:node-set($row)/m:mtr/*"/>
 </mtr>
</xsl:template>

<xsl:template mode="mstack1" match="m:mn">
 <xsl:param name="p"/>
 <xsl:variable name="align1" select="ancestor::m:mstack[1]/@stackalign"/>
 <xsl:variable name="dp1" select="ancestor::*[@decimalpoint][1]/@decimalpoint"/>
 <xsl:variable name="align">
  <xsl:choose>
   <xsl:when test="string($align1)=''">decimalpoint</xsl:when>
   <xsl:otherwise><xsl:value-of select="$align1"/></xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <xsl:variable name="dp">
  <xsl:choose>
   <xsl:when test="string($dp1)=''">.</xsl:when>
   <xsl:otherwise><xsl:value-of select="$dp1"/></xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <mtr l="$p">
  <xsl:variable name="mn" select="normalize-space(.)"/>
  <xsl:variable name="len" select="string-length($mn)"/>
  <xsl:choose>
   <xsl:when test="$align='right' or ($align='decimalpoint' and not(contains($mn,$dp)))">
    <xsl:attribute name="l"><xsl:value-of select="$p + $len"/></xsl:attribute>
   </xsl:when>
   <xsl:when test="$align='decimalpoint'">
    <xsl:attribute name="l"><xsl:value-of select="$p + string-length(substring-before($mn,$dp))"/></xsl:attribute>
   </xsl:when>
  </xsl:choose>

  <xsl:for-each select="(//node())[position() &lt;=$len]">
   <xsl:variable name="pos" select="position()"/>
   <mtd><mn><xsl:value-of select="substring($mn,$pos,1)"/></mn></mtd>
  </xsl:for-each>
 </mtr>
</xsl:template>


<xsl:template match="m:msgroup" mode="mstack1">
 <xsl:param name="p"/>
 <xsl:variable name="s" select="number(sum(@shift))"/>
 <xsl:variable name="thisp" select="number(sum(@position))"/>
 <xsl:for-each select="*">
  <xsl:apply-templates mode="mstack1" select=".">
   <xsl:with-param name="p" select="number($p)+$thisp+(position()-1)*$s"/>
  </xsl:apply-templates>
 </xsl:for-each>
</xsl:template>




<xsl:template match="m:msline" mode="mstack1">
 <xsl:param name="p"/>
 <xsl:variable  name="align1" select="ancestor::m:mstack[1]/@stackalign"/>
 <xsl:variable name="align">
  <xsl:choose>
   <xsl:when test="string($align1)=''">decimalpoint</xsl:when>
   <xsl:otherwise><xsl:value-of select="$align1"/></xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <mtr class="msline">
  <xsl:attribute name="l">
   <xsl:choose>
    <xsl:when test="not(string(@length)) or @length=0">*</xsl:when>
    <xsl:when test="string($align)='right' or string($align)='decimalpoint' "><xsl:value-of select="$p+ @length"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="$p"/></xsl:otherwise>
   </xsl:choose>
  </xsl:attribute>
  <xsl:variable name="w">
   <xsl:choose>
    <xsl:when test="@mslinethickness='thin'">0.1em</xsl:when>
    <xsl:when test="@mslinethickness='medium'">0.15em</xsl:when>
    <xsl:when test="@mslinethickness='thick'">0.2em</xsl:when>
    <xsl:when test="@mslinethickness"><xsl:value-of select="@mslinethickness"/></xsl:when>
    <xsl:otherwise>0.15em</xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:choose>
   <xsl:when test="$hascolspan">
    <mtd class="msline" columnspan="{@length}">
     <xsl:copy-of select="@position"/>
     <xsl:attribute name="style">
      <xsl:value-of select="concat('border-style: solid; border-width: 0 0 ',$w,' 0')"/>
     </xsl:attribute>
    </mtd>
   </xsl:when>
   <xsl:when test="not(string(@length)) or @length=0">
    <mtd class="mslinemax">
     <mpadded lspace="-0.5em" width="0em" height="0em">
      <mfrac linethickness="{$w}">
       <mspace width="1em"/>
       <mrow/>
      </mfrac>
     </mpadded>
    </mtd>
   </xsl:when>
   <xsl:otherwise>
    <xsl:variable name="l" select="@length"/>
    <xsl:for-each select="(//node())[position()&lt;=$l]">
     <mtd class="msline">
      <mpadded lspace="-0.5em" width="0em" height="0em">
       <mfrac linethickness="{$w}">
	<mspace width="1em"/>
	<mrow/>
       </mfrac>
      </mpadded>
     </mtd>
    </xsl:for-each>
   </xsl:otherwise>
  </xsl:choose>
 </mtr>
</xsl:template>


<xsl:template match="m:mscarries" mode="mstack1">
 <xsl:param name="p"/>
 <xsl:variable  name="align1" select="ancestor::m:mstack[1]/@stackalign"/>
 <xsl:variable name="l1">
  <xsl:choose>
   <xsl:when test="string($align1)='left'">0</xsl:when>
   <xsl:otherwise><xsl:value-of select="count(*)"/></xsl:otherwise>
  </xsl:choose>
 </xsl:variable>
 <mtr class="mscarries" l="{$p + $l1 + sum(@position)}">
  <xsl:apply-templates select="*" mode="msc"/>
 </mtr>
</xsl:template>

<xsl:template match="*" mode="msc">
 <mtd>
 <xsl:copy-of select="../@location|../@crossout"/>
 <mstyle mathsize="70%"><xsl:apply-templates select="."/></mstyle></mtd>
</xsl:template>

<xsl:template match="m:mscarry" mode="msc">
 <mtd>
 <xsl:copy-of select="@location|@crossout"/>
 <mstyle mathsize="70%"><xsl:apply-templates select="*"/></mstyle></mtd>
</xsl:template>


<xsl:template match="m:mlongdiv">
 <xsl:variable name="ms">
  <mstack>
   <xsl:copy-of select="(ancestor-or-self::*/@decimalpoint)[last()]"/>
   <xsl:choose>
    <xsl:when test="@longdivstyle='left/\right'">
     <msrow>
      <mrow><xsl:copy-of select="*[1]"/></mrow>
      <mo>/</mo>
      <xsl:copy-of select="*[3]"/>
      <mo>\</mo>
      <xsl:copy-of select="*[2]"/>
     </msrow>
    </xsl:when>
    <xsl:when test="@longdivstyle='left)(right'">
     <msrow>
      <mrow><xsl:copy-of select="*[1]"/></mrow>
      <mo>)</mo>
      <xsl:copy-of select="*[3]"/>
      <mo>(</mo>
      <xsl:copy-of select="*[2]"/>
     </msrow>
    </xsl:when>
    <xsl:when test="@longdivstyle=':right=right'">
     <msrow>
      <xsl:copy-of select="*[3]"/>
      <mo>:</mo>
      <xsl:copy-of select="*[1]"/>
      <mo>=</mo>
      <xsl:copy-of select="*[2]"/>
     </msrow>
    </xsl:when>
    <xsl:otherwise>
     <xsl:copy-of select="*[2]"/>
     <msline length="{string-length(*[3])}"/>
     <msrow>
      <mrow><xsl:copy-of select="*[1]"/></mrow>
      <mo>)</mo>
      <xsl:copy-of select="*[3]"/>
     </msrow>
    </xsl:otherwise>
   </xsl:choose>
   <xsl:copy-of select="*[position()&gt;3]"/>
  </mstack>
 </xsl:variable>
 <xsl:apply-templates select="c:node-set($ms)"/>
</xsl:template>



</xsl:stylesheet>
