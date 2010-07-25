<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:saxon="http://saxon.sf.net/"
		xmlns="http://www.w3.org/1998/Math/MathML"
		xmlns:om="http://www.openmath.org/OpenMath"
		xmlns:m="http://www.w3.org/1998/Math/MathML"
		xmlns:h="http://www.w3.org/1999/xhtml"
		exclude-result-prefixes="saxon om xs m h"
		>

<xsl:import href="pmml2texfrag.xsl"/>

<xsl:output encoding="US-ASCII" method="text" omit-xml-declaration="yes" indent="no"/>



<xsl:template match="h:html">
\documentclass[12pt,a4paper]{article}
\topmargin0pt
\headheight0pt
\headsep0pt
\voffset-1cm

\usepackage[T1]{fontenc}
\usepackage{bm}

\textheight0.6\textheight
\paperheight0.6\paperheight



\usepackage{amssymb,amsmath}
\setcounter{MaxMatrixCols}{25}
\usepackage{color,graphics,array,csscolor}
\extrarowheight4pt
\usepackage{pmml-new}
\begin{document}
<xsl:apply-templates select="h:body/h:div"/>
\end{document}
</xsl:template>

<xsl:template match="h:body/h:div">

\vbox to .7\textheight{
<xsl:apply-templates/>
\endgraf
\vss
}

\clearpage
</xsl:template>

<xsl:template match="h:h3">

[\verb|<xsl:value-of select="."/>|]


</xsl:template>

<xsl:template match="h:p">
  <xsl:text>&#10;&#10;</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>&#10;&#10;</xsl:text>
</xsl:template>

<xsl:template match="h:hr">

\endgraf
\smallskip
\hrule
\smallskip
\endgraf

</xsl:template>

<xsl:template match="h:img">

\includegraphics{../../w3c/WWW/<!--../w3c/WWW/<xsl:text/>
<xsl:value-of select="substring-after(@src,'w3c/WWW/')"/>--><xsl:value-of select="@src"/>
<xsl:text>}

</xsl:text>
</xsl:template>


<xsl:template match="h:img[contains(@src,'/Characters/')]"/>
<xsl:template match="h:img[contains(@src,'TortureTests/Size')]"/>
<xsl:template match="h:img[contains(@src,'TortureTests/Complexity')]"/>
<xsl:template match="h:img[ends-with(@src,'/multinewline3.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/int2.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/int5.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/abs1.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/mid1.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/mid2.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/linebreakString1.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/linebreakRow1.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/linebreakNum1.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/linebreakFrac.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/noChildPresentation.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/mrootE2.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/arccos3.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/clipboard1.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/mactionSmixed3.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/mactionSmixed4.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/mfracZComp1.png')]"/>
<xsl:template match="h:img[ends-with(@src,'/rec-mcolumn6.png')]"/>

<xsl:template match="m:math">

\[\let\par\empty

<xsl:variable name="tex">
  <xsl:apply-templates mode="pmml2tex"/>
</xsl:variable>
<xsl:if test="$tex">
	    <xsl:value-of select="for $c in string-to-codepoints(replace($tex,' *&#10;\s+','&#10;')) return
				  if ($c gt 127) then ('\unicode{',$c,'}') else codepoints-to-string($c)"
			  separator=""/>
</xsl:if>

\]

</xsl:template>


<xsl:template match="h:pre">
\begin{verbatim}
<xsl:apply-templates mode="pmml2tex"/>
\end{verbatim}
</xsl:template>

</xsl:stylesheet>