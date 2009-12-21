
<!-- saved from url=(0014)about:internet -->
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:h="http://www.w3.org/1999/xhtml"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="h xlink"
>

<xsl:template match="h:html">
 <html>
  <xsl:copy-of select="@*"/>
  <xsl:apply-templates/>
 </html>
</xsl:template>

<xsl:template match="h:head">
 <xsl:copy>
  <xsl:choose>
   <xsl:when test="system-property('xsl:vendor')='Microsoft'">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <object id="mmlFactory" 
	    classid="clsid:32F66A20-7614-11D4-BD11-00104BD3F987">
    </object>
    <xsl:processing-instruction name="import">namespace="mml" implementation="#mmlFactory"</xsl:processing-instruction>
   </xsl:when>
  <xsl:when test="system-property('xsl:vendor')='Transformiix'">
<script type="text/javascript">
function init() {
var lists = document.getElementsByClassName("mmlhref");
for (var i = 0; i &lt; lists.length; i++) {
    lists[i].onclick = function(){window.location=this.getAttribute('href')};
}
}
window.onload = init; 

</script>
   </xsl:when>
   <xsl:when  test="system-property('xsl:vendor')='Opera' or system-property('xsl:vendor')='libxslt'">
    <link rel="stylesheet" href="pmathml/pmathmlcss.css" type="text/css"/>
   </xsl:when>
  </xsl:choose>
  <xsl:copy-of select="node()"/>

 </xsl:copy>
</xsl:template>
 

<xsl:template match="*">
 <xsl:copy>
  <xsl:copy-of select="@*"/>
  <xsl:apply-templates/>
 </xsl:copy>
</xsl:template>

<xsl:template match="h:br|h:hr">
 <xsl:choose>
  <xsl:when test="system-property('xsl:vendor')='Microsoft'">
   <xsl:value-of disable-output-escaping="yes" select="concat('&lt;',local-name(.))"/>
   <xsl:apply-templates mode="verb" select="@*"/>
   <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
  </xsl:when>
  <xsl:otherwise>
   <xsl:element name="{local-name(.)}">
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
   </xsl:element>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template match="mml:*">
 <xsl:element name="mml:{local-name(.)}">
  <xsl:copy-of select="@*"/>
  <xsl:apply-templates/>
 </xsl:element>
</xsl:template>


<xsl:template match="mml:math">
 <xsl:choose>
  <xsl:when test="system-property('xsl:vendor')='Opera'">
   <xsl:apply-templates select="." mode="opera"/>
    </xsl:when>
    <xsl:when test="system-property('xsl:vendor')='libxslt'">
     <xsl:apply-templates select="." mode="opera"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:element name="mml:{local-name(.)}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
     </xsl:element>
    </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template match="mml:mo[.='&#8289;']">
 <xsl:choose>
  <xsl:when test="system-property('xsl:vendor')='Microsoft'">
   <mml:mo>&#8200;</mml:mo>
  </xsl:when>
  <xsl:otherwise>
   <mml:mo>&#8289;</mml:mo>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- GRRRR Firefox 3.x removed xlink support -->

<xsl:template match="mml:maction[@actiontype='link']">
 <xsl:choose>
  <xsl:when test="system-property('xsl:vendor')='Transformiix'">
   <mml:mrow>
   <a style="text-decoration:none" href="{@xlink:href}" xmlns:xlink="http://www.w3.org/1999/xlink">
    <xsl:apply-templates select="*[1]"/>
   </a>
   </mml:mrow>
  </xsl:when>
  <xsl:otherwise>
   <mml:maction>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates/>
   </mml:maction>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<xsl:template match="*[@href|@xlink:href]">
 <xsl:choose>
 <xsl:when test="system-property('xsl:vendor')='Transformiix'">
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name()='href')]"/>
      <xsl:attribute name="href">
	<xsl:value-of select="@href|xlink:href"/>
      </xsl:attribute>
      <xsl:attribute name="class">
	<xsl:text>mmlhref </xsl:text>
	<xsl:value-of select="@class"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:when>
  <xsl:otherwise>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:otherwise>
 </xsl:choose>
</xsl:template>

<!-- restructure for CSS implementation of MathML -->


<xsl:template match="mml:*" mode="opera">
 <xsl:element name="{local-name(.)}">
  <xsl:copy-of select="@*"/>
  <xsl:apply-templates mode="opera"/>
 </xsl:element>
</xsl:template>

<xsl:template match="mml:*[@href|@xlink:href]" mode="opera" priority="10">
  <a style="text-decoration:none" href="{@href|@xlink:href}">
    <xsl:element name="{local-name(.)}">
      <xsl:copy-of select="@*[not(local-name()='href')]"/>
      <xsl:for-each select="node()">
	<mrow>
	  <xsl:apply-templates mode="opera" select="."/>
	</mrow>
      </xsl:for-each>
    </xsl:element>
  </a>
</xsl:template>

<xsl:template match="mml:mfrac" mode="opera">
 <xsl:element name="{local-name(.)}">
  <xsl:copy-of select="@*"/>
  <mrow><xsl:apply-templates mode="opera" select="*[1]"/></mrow>
  <mrow><xsl:apply-templates mode="opera" select="*[2]"/></mrow>
 </xsl:element>
</xsl:template>

<xsl:template match="mml:msub" mode="opera">
 <xsl:element name="{local-name(.)}">
  <xsl:copy-of select="@*"/>
  <mrow><xsl:apply-templates mode="opera" select="*[1]"/></mrow>
  <mrow><xsl:apply-templates mode="opera" select="*[2]"/></mrow>
 </xsl:element>
</xsl:template>

<xsl:template match="mml:mfenced[not(.//mml:mtable or .//mml:mfrac)]" mode="opera" priority="2">
 <mrow>
  <mo>
   <xsl:choose>
    <xsl:when test="@open"><xsl:value-of select="@open"/></xsl:when>
    <xsl:otherwise>(</xsl:otherwise>
   </xsl:choose>
  </mo>
  <xsl:for-each select="*">
   <xsl:apply-templates mode="opera" select="."/>
   <xsl:if test="not(@separators='') and position()!=last()">
    <mo><xsl:value-of select="../@separators"/></mo>
   </xsl:if>
  </xsl:for-each>
  <mo>
   <xsl:choose>
    <xsl:when test="@close"><xsl:value-of select="@close"/></xsl:when>
    <xsl:otherwise>)</xsl:otherwise>
   </xsl:choose>
  </mo>
 </mrow>
</xsl:template>

<xsl:template match="mml:mfenced" mode="opera">
 <xsl:element name="{local-name(.)}">
  <xsl:copy-of select="@*"/>
  <xsl:attribute name="separators"/>
  <mrow>
   <xsl:for-each select="*">
    <xsl:apply-templates mode="opera" select="."/>
    <xsl:if test="not(@separators='') and position()!=last()">
     <mo><xsl:value-of select="../@separators"/></mo>
    </xsl:if>
   </xsl:for-each>
  </mrow>
 </xsl:element>
</xsl:template>

<xsl:template match="mml:mfenced[@open='&#8214;' and @close='&#8214;']" mode="opera">
 <mrow class="vert">
  <mrow class="vert">
  <xsl:apply-templates mode="opera" select="*"/></mrow>
 </mrow>
</xsl:template>

<xsl:template match="mml:mi" mode="opera">
 <xsl:element name="{local-name(.)}">
  <xsl:copy-of select="@*"/>
  <xsl:if test="not(@mathvariant) and string-length(.)=1">
   <xsl:attribute name="mathvariant">italic</xsl:attribute>
  </xsl:if>
  <xsl:if test="@mathvariant='bold' and string-length(.)=1">
   <xsl:attribute name="mathvariant">bold-italic</xsl:attribute>
  </xsl:if>
  <xsl:if test="not(@style) and @mathcolor">
   <xsl:attribute name="style">color: <xsl:value-of select="@mathcolor"/>;</xsl:attribute>
  </xsl:if>
  <xsl:apply-templates mode="opera" select="node()"/>
 </xsl:element>
</xsl:template>

<xsl:template match="mml:mo[.='&#8289;']" mode="opera">
 <mo><xsl:text> </xsl:text></mo>
</xsl:template>

<xsl:template match="mml:maction[@actiontype='link']" mode="opera">
 <a style="text-decoration: none;"  href="{@xlink:href}">
  <xsl:apply-templates mode="opera" select="*"/>
 </a>
</xsl:template>

</xsl:stylesheet>

