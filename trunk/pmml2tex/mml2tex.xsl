<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:saxon="http://saxon.sf.net/"
		xmlns="http://www.w3.org/1998/Math/MathML"
		xmlns:om="http://www.openmath.org/OpenMath"
		xmlns:m="http://www.w3.org/1998/Math/MathML"
		exclude-result-prefixes="saxon om xs m"
		>
  
<xsl:preserve-space elements="m:mtext"/>

<xsl:param name="matches"/>
<xsl:param name="posn"/>
 
<xsl:variable  name="badpng" select="(
'Presentation/ScriptsAndLimits/msubsup/msubsupBsize2', 
'Presentation/ScriptsAndLimits/munder/munder1', 
'Presentation/ScriptsAndLimits/munder/munder2', 
'Presentation/TablesAndMatrices/mtable/maligngroup1', 
'Presentation/TablesAndMatrices/mtable/mtable2', 
'Presentation/TablesAndMatrices/mtable/mtableAwidth1', 
'Presentation/TablesAndMatrices/mtable/mtableBspan3', 
'Presentation/TablesAndMatrices/nested/nestedAwidth1', 
'Presentation/TokenElements/mi/mimathvariant14', 
'Topics/EmbellishedOp/embStretch1', 
'Topics/LineBreak/goodbreak/goodbreak1', 
'Topics/LineBreak/linebreak1', 
'Topics/LineBreak/newline/indent1', 
'Topics/LineBreak/newline/indent2', 
'Topics/LineBreak/newline/mixed4', 
'Topics/LineBreak/newline/newline1', 
'Topics/LineBreak/newline/newline2', 
'Topics/Primes/primes1', 
'Topics/WhiteSpace/white3'
)"/>

<xsl:output encoding="US-ASCII" omit-xml-declaration="yes" indent="yes"/>
<xsl:strip-space elements="*"/>

<xsl:template match="m:entityRef[@index]" mode="cmml2om">
  <xsl:value-of select="codepoints-to-string(m:hexfromstring(substring-after(@index,'x')))"/>
</xsl:template>

<xsl:template name="main" match="/">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Presentation MathML</title>
<style>
div {border: solid black thin; margin-top:1em;}
</style>
</head>
<body>
<xsl:for-each select="//file[$matches='' or (matches(@path, $matches))]
		            [$posn='' or $posn=position()]">
<xsl:variable name="passed" select="@passed"/>
<xsl:variable name="last" select="last()"/>
<xsl:for-each select="saxon:discard-document(doc(replace(@path,'^testsuite(.*)\.xml','../../w3c/WWW/Math/testsuite/build/main$1.mml')))">
<!--
collection('../w3c/WWW/Math/testsuite/build/main/?select=*.mml;recurse=yes;on-error=warn')/saxon:discard-document(.)
[not(matches(document-uri(.),'Characters|Topics|EntityName|Torture|ErrorHandling'))]
-->


  <xsl:variable name="pmml">
<!--
      <xsl:apply-templates select="$o/*"/>
-->
   <xsl:copy-of select="."/>
  </xsl:variable>

<div class="testcase">
  <xsl:variable name="t" select="substring-after(document-uri(.),'build/main/')"/>
  <h3><xsl:value-of select="$t"/></h3>
  <p>status: <b><xsl:value-of select="$passed"/></b></p>
<xsl:if test="not(substring-before($t,'.mml')=$badpng)">
  <p>Reference image:</p>
     <img src="../../w3c/WWW/Math/testsuite/build/main/{replace(replace(substring-after(document-uri(.),'build/main/'),'\.mml','.png'),'StrictContent','Content')}"/>
</xsl:if>
 <hr/>
 <p>TeX Rendering:</p>
  <xsl:copy-of select="$pmml" copy-namespaces="no"/>
 <hr/>
 <p>MathML:</p>
 <pre>
  <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
  <xsl:apply-templates mode="clean" select="/"/>
  <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
 </pre>
</div>
</xsl:for-each>
</xsl:for-each>
</body>
</html>
</xsl:template>

<xsl:template match="m:bvar" mode="om2pmml">
 <merror><mtext>bad bvar</mtext></merror>
</xsl:template>

<xsl:function name="m:hexfromstring">
<xsl:param name="x"/>
   <xsl:sequence select="(
         m:hex(
           for $i in string-to-codepoints(upper-case($x))
           return if ($i &gt; 64) then $i - 55 else $i - 48))"/>
</xsl:function>

<xsl:function name="m:hex">
<xsl:param name="x"/>
  <xsl:sequence
    select="if (empty($x)) then 0 else ($x[last()] + 16* m:hex($x[position()!=last()]))"/>
</xsl:function>




<xsl:template match="m:math" mode="clean">
<xsl:copy>
 <xsl:copy-of select="@*"/>
<xsl:variable name="x">
<xsl:apply-templates mode="clean"/>
</xsl:variable>
<xsl:variable name="y">
<xsl:apply-templates mode="clean" select="$x"/>
</xsl:variable>
<xsl:apply-templates mode="pindent" select="$y"/>
</xsl:copy>
</xsl:template>

<xsl:template match="*" mode="clean">
<xsl:copy>
 <xsl:copy-of select="@*"/>
 <xsl:apply-templates mode="clean"/>
</xsl:copy>
</xsl:template>

<xsl:template match="m:mfenced[not(*[2])][mrow]" mode="clean">
  <xsl:copy>
   <xsl:copy-of select="@*"/>
   <xsl:attribute name="separators"/>
   <xsl:apply-templates select="m:mrow/*" mode="clean"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="m:mrow[* and not(*[2])][not(@*)]" mode="clean">
 <xsl:apply-templates select="*" mode="clean"/>
</xsl:template>

<xsl:template match="*|/" mode="pindent">
  <xsl:text>&#10;</xsl:text>
  <xsl:for-each select="ancestor::*"><xsl:text> </xsl:text></xsl:for-each>
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:choose>
      <xsl:when test="not((descendant::*/(.,@*))[6]) or text()[normalize-space()]">
	<xsl:copy-of select="node()"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates mode="pindent"/>
	<xsl:text>&#10;</xsl:text>
	<xsl:for-each select="ancestor::*"><xsl:text> </xsl:text></xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>