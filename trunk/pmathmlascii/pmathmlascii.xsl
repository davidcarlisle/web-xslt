
<!--
$id: pmathmlascii.xsl,v 1.6 2004/11/01 13:44:32 davidc Exp $

Copyright David Carlisle 2004.

Use and distribution of this code are permitted under the terms of the <a
href="http://www.w3.org/Consortium/Legal/copyright-software-19980720"
>W3C Software Notice and License</a>.
-->

<xsl:stylesheet
   version="2.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:x="data:,x"
  exclude-result-prefixes="x m xs"
>


<!-- FUNCTIONS -->

<xsl:function name="x:pad">
<!--
  make a string consisting of $n copies of the string $c
-->
 <xsl:param name="c" />
 <xsl:param name="n" />
 <xsl:value-of select="string-join(for $i in 1 to xs:integer($n) return $c,'')"/>
</xsl:function>



<xsl:function name="x:align">
<!--
  Take a block $b and return a (document node containing a) sequence of
  l nodes set to width $w and aligned as specified by $align, with a
  left margin of $margin space characters.
  If the b node has an hstretch attribute the l node returned will
  contain a string with the streched character to the right of any
  specified margin.
-->
  <xsl:param name="b"/>
  <xsl:param name="w"/>
  <xsl:param name="align"/>
  <xsl:param name="margin"/>
<xsl:variable name="l1" select="
  if     ($align='left') then ($margin)
  else if ($align='right') then (xs:integer($w - $b[1]/@width))
  else ($margin + xs:integer($w - $margin[1] - $b[1]/@width) idiv 2)
"/>
<xsl:choose>
  <xsl:when test="$b/@hstretch">
    <xsl:variable name="i" select="tokenize($b/@hstretch,' ')"/>
    <xsl:variable name="l2" select="xs:integer($w - $margin - string-length($i[2])) idiv 2"/>
    <l><xsl:value-of select="
        concat(x:pad(' ',$margin),
          x:pad($i[1],$l2),
          $i[2],
          x:pad($i[1],$w - $margin - string-length($i[2]) - $l2))
    "/></l>
  </xsl:when>
  <xsl:otherwise>
    <xsl:for-each select="$b/l">
      <l>
       <xsl:value-of select="concat(x:pad(' ',$l1),.,x:pad(' ',$w - $b/@width -$l1))"/>
      </l>
    </xsl:for-each>      
  </xsl:otherwise>
</xsl:choose>
</xsl:function>


<xsl:function name="x:stretch">
<!--
  Vertically stretch characters, currently a lookup using xsl:choose,
  should probably use a subsidiary XML data structure and probably
  xsl:key to do the lookup.

  Either way the function takes a block $b representing a character
  (via its @mo attribute) and a desired size $s and returns a (root
  node containing a) b element with @height and @depth both set to $s
  and a representation of the stretched character.
 
-->
  <xsl:param name="b"/>
  <xsl:param name="s"/>
  <xsl:choose>
    <xsl:when test="$b/@mo and $b/l=']' and $s &gt;0">
      <b height="{$s}" depth="{$s}" width="3">
        <l> --</l>
        <xsl:for-each select="1 to xs:integer(2 * $s - 1)"><l>  |</l></xsl:for-each>
        <l> --</l>
      </b>
    </xsl:when>
    <xsl:when test="$b/@mo and $b/l=('|','&#8739;')">
      <b height="{$s}" depth="{$s}" width="3">
        <xsl:for-each select="1 to xs:integer(2 * $s + 1)"><l> | </l></xsl:for-each>
      </b>
    </xsl:when>
    <xsl:when test="$b/@mo and $b/l='[' and $s &gt;0">
      <b height="{$s}" depth="{$s}" width="3">
        <l>-- </l>
        <xsl:for-each select="1 to xs:integer(2 * $s - 1)"><l>|  </l></xsl:for-each>
        <l>-- </l>
      </b>
    </xsl:when>
    <xsl:when test="$b/@mo and $b/l='{' and $s &gt;0">
      <b height="{$s}" depth="{$s}" width="3">
        <l>  /</l>
        <xsl:for-each select="1 to xs:integer($s - 1)"><l> { </l></xsl:for-each>
        <l> { </l>
        <xsl:for-each select="1 to xs:integer($s - 1)"><l> { </l></xsl:for-each>
        <l>  \</l>
      </b>
    </xsl:when>
    <xsl:when test="$b/@mo and $b/l='}' and $s &gt;0">
      <b height="{$s}" depth="{$s}" width="3">
        <l>\  </l>
        <xsl:for-each select="1 to xs:integer($s - 1)"><l> } </l></xsl:for-each>
        <l> } </l>
        <xsl:for-each select="1 to xs:integer($s - 1)"><l> } </l></xsl:for-each>
        <l>/  </l>
      </b>
    </xsl:when>
    <xsl:when test="$b/@mo and $b/l='(' and $s &gt;0">
      <b height="{$s}" depth="{$s}" width="3">
        <l>  /</l>
        <xsl:for-each select="1 to xs:integer(2*$s - 1)"><l> | </l></xsl:for-each>
        <l>  \</l>
      </b>
    </xsl:when>
    <xsl:when test="$b/@mo and $b/l=')' and $s &gt;0">
      <b height="{$s}" depth="{$s}" width="3">
        <l>\  </l>
        <xsl:for-each select="1 to xs:integer(2*$s - 1)"><l> | </l></xsl:for-each>
        <l>/  </l>
      </b>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$b"/>
    </xsl:otherwise>
  </xsl:choose>
  
</xsl:function>


<!-- TEMPLATES: Default mode-->

<xsl:template match="m:math">
<!--
 Top level switch to mml2a mode which does all the main work.
-->
 <xsl:apply-templates mode="mml2a" select="."/>
</xsl:template>



<!-- TEMPLATES: mml2a mode-->

<xsl:template mode="mml2a" match="m:math">
<!--
  All intermediate ascii art results consist of a top level block (b)
  element containing a list of line (l)  elements, each of which
  contains a text node with a string of length specified by the width
  attribute of the b element. Thiis top level template unpacks the
  XML structure and just returns the text from the l elements,
  separated by newlines.
-->
  <xsl:variable name="x">
  <xsl:call-template name="mrow"/>
  </xsl:variable>
    <xsl:text>&#10;</xsl:text>
  <xsl:value-of  select="$x/b/l" separator="&#10;"/>
</xsl:template>


<xsl:template mode="mml2a" match="m:maction">
 <xsl:variable name="x">
  <xsl:call-template name="mrow"/>
  </xsl:variable>
  <xsl:copy-of select="$x"/>
</xsl:template>

<xsl:template mode="mml2a" match="m:menclose">
  <xsl:variable name="x">
  <xsl:call-template name="mrow"/>
  </xsl:variable>
  <xsl:copy-of select="$x"/>
</xsl:template>

<xsl:template mode="mml2a" match="m:menclose[@notation=('box','roundedbox','circle')]">
  <xsl:variable name="x">
  <xsl:call-template name="mrow"/>
  </xsl:variable>
  <b height="{$x/b/@height+1}" width="{$x/b/@width+2}" depth="{$x/b/@depth+1}">
     <l><xsl:value-of select="x:pad('-',$x/b/@width+2)"/></l>
    <xsl:for-each select="$x/b/l">
      <l>|<xsl:value-of select="."/>|</l>
    </xsl:for-each>
     <l><xsl:value-of select="x:pad('-',$x/b/@width+2)"/></l>
  </b>
</xsl:template>

<xsl:template mode="mml2a" match="m:menclose[@notation='left']">
  <xsl:variable name="x">
  <xsl:call-template name="mrow"/>
  </xsl:variable>
  <b height="{$x/b/@height}" width="{$x/b/@width+1}" depth="{$x/b/@depth}">
    <xsl:for-each select="$x/b/l">
      <l>|<xsl:value-of select="."/></l>
    </xsl:for-each>
  </b>
</xsl:template>

<xsl:template mode="mml2a" match="m:menclose[@notation='right']">
  <xsl:variable name="x">
  <xsl:call-template name="mrow"/>
  </xsl:variable>
  <b height="{$x/b/@height}" width="{$x/b/@width+1}" depth="{$x/b/@depth}">
    <xsl:for-each select="$x/b/l">
      <l><xsl:value-of select="."/>|</l>
    </xsl:for-each>
  </b>
</xsl:template>

<xsl:template mode="mml2a" match="m:menclose[@notation='top']">
  <xsl:variable name="x">
  <xsl:call-template name="mrow"/>
  </xsl:variable>
  <b height="{$x/b/@height+1}" width="{$x/b/@width}" depth="{$x/b/@depth}">
     <l><xsl:value-of select="x:pad('-',$x/b/@width)"/></l>
    <xsl:copy-of select="$x/b/l"/>
  </b>
</xsl:template>

<xsl:template mode="mml2a" match="m:menclose[@notation='bottom']">
  <xsl:variable name="x">
  <xsl:call-template name="mrow"/>
  </xsl:variable>
  <b height="{$x/b/@height}" width="{$x/b/@width}" depth="{$x/b/@depth+1}">
    <xsl:copy-of select="$x/b/l"/>
     <l><xsl:value-of select="x:pad('-',$x/b/@width)"/></l>
  </b>
</xsl:template>


<xsl:template mode="mml2a" match="m:menclose[@notation='radical']">
  <xsl:call-template name="msqrt"/>
</xsl:template>

<xsl:template mode="mml2a" match="m:mphantom">
  <xsl:variable name="x">
  <xsl:call-template name="mrow"/>
  </xsl:variable>
  <b>
    <xsl:copy-of select="$x/b/(@height|@depth|@width)"/>
    <xsl:variable name="l" select="x:pad(' ',$x/b/@width)"/>
    <xsl:for-each select="$x/b/l">
      <l><xsl:value-of select="$l"/></l>
    </xsl:for-each>
  </b>
</xsl:template>


<xsl:template mode="mml2a" match="m:merror">
  <xsl:variable name="x">
  <xsl:call-template name="mrow"/>
  </xsl:variable>
  <xsl:copy-of select="$x"/>
</xsl:template>

<xsl:template mode="mml2a" match="m:semantics">
  <xsl:choose>
    <xsl:when test="m:annotation-xml[@encoding='MathML-Presentation']">
      <xsl:call-template name="mrow">
        <xsl:with-param name="x">     
        <xsl:apply-templates mode="mml2a"  select="m:annotation-xml[@encoding='MathML-Presentation']/node()"/>  
      </xsl:with-param>     
    </xsl:call-template>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates mode="mml2a"  select="*[1]"/>  
  </xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template mode="mml2a" match="m:*">
  <xsl:message>[mml2a*{<xsl:value-of select="namespace-uri()"/>}<xsl:value-of select="local-name()"/>]</xsl:message>
</xsl:template>

<xsl:template mode="mml2a" match="m:mspace">
<b width="1" height="0" depth="0"><l> </l></b>
</xsl:template>

<xsl:template  mode="mml2a" match="m:mi|m:mn|m:mtext">
  <xsl:variable name="x" select="normalize-space(.)"/>
  <xsl:variable name="y" select="$lookup/b[@f=$x]"/>
  <xsl:choose>
    <xsl:when test="$y"><xsl:copy-of select="$y"/> </xsl:when>
    <xsl:otherwise>
   <b width="{string-length($x)}" height="0" depth="0">
     <l><xsl:value-of select="$x"/></l>
   </b>  
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template  mode="mml2a" match="m:ms">
  <xsl:variable name="x" select="normalize-space(.)"/>
   <b width="{string-length($x)+2}" height="0" depth="0">
     <l>"<xsl:value-of select="$x"/>"</l>
   </b>  
</xsl:template>

<!-- If the mo isn't in the lookup table, just copy it as-is, with a space either side -->
<xsl:template  mode="mml2a" match="m:mo">
  <xsl:variable name="x" select="normalize-space(.)"/>
  <xsl:variable name="y" select="$lookup/b[@f=$x]"/>
  <xsl:choose>
    <xsl:when test="$y"><xsl:copy-of select="$y"/> </xsl:when>
    <xsl:otherwise>
   <b mo="yes" width="{2+string-length($x)}" height="0" depth="0">
     <l><xsl:text> </xsl:text><xsl:value-of select="$x"/><xsl:text> </xsl:text></l>
   </b>  
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:variable name="lookup">
  <b f="=" width="3" height="0" depth="0"><l> = </l></b>
  <b f="+" width="3" height="0" depth="0"><l> + </l></b>
  <b f="-" width="3" height="0" depth="0"><l> - </l></b>
  <b f="&#x000B1;" width="5" height="0" depth="0"><l> +/- </l></b>
  <b f="&#x2032;" width="1" height="0" depth="0"><l>'</l></b>

  <b f="&#x3B1;" width="5" height="0" depth="0"><l>alpha</l></b>
  <b f="&#x3B2;" width="4" height="0" depth="0"><l>beta</l></b>
  <b f="&#x3C7;" width="3" height="0" depth="0"><l>chi</l></b>
  <b f="&#x394;" width="5" height="0" depth="0"><l>Delta</l></b>
  <b f="&#x3B4;" width="5" height="0" depth="0"><l>delta</l></b>
  <b f="&#x3F5;" width="9" height="0" depth="0"><l> epsilon </l></b>
  <b f="&#x3B5;" width="9" height="0" depth="0"><l> epsilon </l></b>
  <b f="&#x3B7;" width="3" height="0" depth="0"><l>eta</l></b>
  <b f="&#x393;" width="4" height="0" depth="0"><l>Gamma</l></b>
  <b f="&#x3B3;" width="4" height="0" depth="0"><l>gamma</l></b>
  <b f="&#x3DC;" width="5" height="0" depth="0"><l>Gammad</l></b>
  <b f="&#x3DD;" width="5" height="0" depth="0"><l>gammad</l></b>
  <b f="&#x3B9;" width="4" height="0" depth="0"><l>iota</l></b>
  <b f="&#x3BA;" width="5" height="0" depth="0"><l>kappa</l></b>
  <b f="&#x3F0;" width="5" height="0" depth="0"><l>kappa</l></b>
  <b f="&#x39B;" width="6" height="0" depth="0"><l>Lambda</l></b>
  <b f="&#x3BB;" width="6" height="0" depth="0"><l>lambda</l></b>
  <b f="&#x3BC;" width="2" height="0" depth="0"><l>mu</l></b>
  <b f="&#x3BD;" width="2" height="0" depth="0"><l>nu</l></b>
  <b f="&#x3A9;" width="5" height="0" depth="0"><l>Omega</l></b>
  <b f="&#x3C9;" width="5" height="0" depth="0"><l>omega</l></b>
  <b f="&#x3A6;" width="3" height="0" depth="0"><l>Phi</l></b>
  <b f="&#x3D5;" width="3" height="0" depth="0"><l>phi</l></b>
  <b f="&#x3C6;" width="4" height="0" depth="0"><l>phiv</l></b>
  <b f="&#x3A0;" width="2" height="0" depth="0"><l>Pi</l></b>
  <b f="&#x3C0;" width="4" height="0" depth="0"><l> pi </l></b>
  <b f="&#x3D6;" width="3" height="0" depth="0"><l>piv</l></b>
  <b f="&#x3A8;" width="3" height="0" depth="0"><l>Psi</l></b>
  <b f="&#x3C8;" width="3" height="0" depth="0"><l>psi</l></b>
  <b f="&#x3C1;" width="3" height="0" depth="0"><l>rho</l></b>
  <b f="&#x3F1;" width="4" height="0" depth="0"><l>rhov</l></b>
  <b f="&#x3A3;" width="5" height="0" depth="0"><l>Sigma</l></b>
  <b f="&#x3C3;" width="5" height="0" depth="0"><l>sigma</l></b>
  <b f="&#x3C2;" width="6" height="0" depth="0"><l>sigmav</l></b>
  <b f="&#x3C4;" width="3" height="0" depth="0"><l>tau</l></b>
  <b f="&#x398;" width="5" height="0" depth="0"><l>Theta</l></b>
  <b f="&#x3B8;" width="5" height="0" depth="0"><l>theta</l></b>
  <b f="&#x3D1;" width="6" height="0" depth="0"><l>thetav</l></b>
  <b f="&#x3D2;" width="4" height="0" depth="0"><l>Upsi</l></b>
  <b f="&#x3C5;" width="4" height="0" depth="0"><l>upsi</l></b>
  <b f="&#x39E;" width="2" height="0" depth="0"><l>Xi</l></b>
  <b f="&#x3BE;" width="2" height="0" depth="0"><l>xi</l></b>
  <b f="&#x3B6;" width="4" height="0" depth="0"><l>zeta</l></b>

  <b f="&#x2003;" width="1" height="0" depth="0"><l> </l></b>
  <b f="&#x2026;" width="5" height="0" depth="0"><l> ... </l></b>
  <b f="&#x211D;" width="1" height="0" depth="0"><l>R</l></b>
  <b f="&#x2192;" width="4" height="0" depth="0"><l> -&gt; </l></b>
  <b f="&#x21D0;" width="4" height="0" depth="0"><l> &lt;= </l></b>
  <b f="&#x21D2;" width="4" height="0" depth="0"><l> =&gt; </l></b>
  <b f="&#x21D4;" width="5" height="0" depth="0"><l> &lt;=&gt; </l></b>
  <b f="&#x2202;" width="1" height="0" depth="0"><l>d</l></b>
  <b f="&#x2208;" width="4" height="0" depth="0"><l> in </l></b>
  <b f="&#x221E;" width="8" height="0" depth="0"><l>infinity</l></b>
  <b f="&#x2243;" width="3" height="1" depth="0">
   <l> ~ </l>
   <l> - </l>
  </b>
  <b f="&#x2245;" width="3" height="1" depth="0">
   <l> ~ </l>
   <l> = </l>
  </b>
  <b f="&#x22ee;" width="3" height="1" depth="1">
   <l> . </l>
   <l> . </l>
   <l> . </l>
  </b>
  <b f="&#x2261;" width="3" height="1" depth="0">
   <l> _ </l>
   <l> = </l>
  </b>
  <b f="&#x2264;" width="4" height="0" depth="0"><l> &lt;= </l> </b>
  <b f="&#x2265;" width="4" height="0" depth="0"><l> &gt;= </l> </b>
  <b f="&#x22EF;" width="5" height="0" depth="0"><l> ... </l></b>
  <b f="&#8518;" width="1" height="0" depth="0"><l>d</l></b>
  <b f="&#8519;" width="1" height="0" depth="0"><l>e</l></b>
  <b f="&#8290;" width="0" height="0" depth="0"><l></l></b>
  <b f="&#8747;" width="1" height="1" depth="1">
   <l>/</l>
   <l>|</l>
   <l>/</l>
</b>
<b f="&#8721;" width="4" height="2" depth="2">
<l>----</l>
<l> \  </l>
<l>  ) </l>
<l> /  </l>
<l>----</l>
</b>
<b hstretch="_ /\ _" f="&#65079;" width="4" height="0" depth="0">
  <l>_/\_</l>
</b>
<b hstretch="- \/ -" f="&#65080;" width="4" height="0" depth="0">
  <l>-\/-</l>
</b>
<b hstretch="_ _ _" f="&#175;" width="1" height="0" depth="0">
  <l>_</l>
</b>
<b hstretch="_ _ _" f="&#818;" width="1" height="0" depth="0">
  <l>_</l>
</b>
</xsl:variable>

<xsl:template  mode="mml2a" match="m:msub">
  <xsl:variable name="b">
     <xsl:apply-templates mode="mml2a" select="*[1]"/>
  </xsl:variable>
  <xsl:variable name="s">
     <xsl:apply-templates mode="mml2a" select="*[2]"/>
  </xsl:variable>
  <xsl:variable name="w" select="xs:integer($b/b/@width + $s/b/@width)"/>
<b width="{$w}" height="{$b/b/@height}"
         depth="{$b/b/@depth + $s/b/@height + $s/b/@depth +1}">
 <xsl:copy-of select="x:align($b/b,$w,'left',0),
                      x:align($s/b,$w,'left',$b/b/@width)"/> 
   </b>
</xsl:template>

<xsl:template  mode="mml2a" match="m:msup">
  <xsl:variable name="b">
     <xsl:apply-templates mode="mml2a" select="*[1]"/>
  </xsl:variable>
  <xsl:variable name="s">
     <xsl:apply-templates mode="mml2a" select="*[2]"/>
  </xsl:variable>
  <xsl:variable name="w" select="xs:integer($b/b/@width + $s/b/@width)"/>
<b width="{$w}" depth="{$b/b/@depth}"
         height="{$b/b/@height + $s/b/@height + $s/b/@depth +1}">
 <xsl:copy-of select="x:align($s/b,$w,'left',$b/b/@width), 
                      x:align($b/b,$w,'left',0)"/> 
   </b>
</xsl:template>

<xsl:template  mode="mml2a" match="m:msubsup">
  <xsl:variable name="b">
     <xsl:apply-templates mode="mml2a" select="*[1]"/>
  </xsl:variable>
  <xsl:variable name="sb">
     <xsl:apply-templates mode="mml2a" select="*[2]"/>
  </xsl:variable>
  <xsl:variable name="sp">
     <xsl:apply-templates mode="mml2a" select="*[3]"/>
  </xsl:variable>
  <xsl:variable name="w" select="xs:integer($b/b/@width + max(($sb|$sp)/b/@width))"/>
  <b width="{$w}"
    height="{$b/b/@height + $sp/b/@height + $sp/b/@depth +1}"
    depth="{$b/b/@depth + $sb/b/@height + $sb/b/@depth +1}">
 <xsl:copy-of select="x:align($sp/b,$w,'left',$b/b/@width)"/> 
 <xsl:copy-of select="x:align($b/b,$w,'left',0)"/> 
 <xsl:copy-of select="x:align($sb/b,$w,'left',$b/b/@width)"/> 
   </b>
</xsl:template>


<xsl:template  mode="mml2a" match="m:mprescripts"/>

<xsl:template  mode="mml2a" match="m:mmultiscripts">
  <xsl:variable name="b">
     <xsl:apply-templates mode="mml2a" select="*[1]"/>
  </xsl:variable>
  <xsl:variable name="sb">
     <xsl:apply-templates mode="mml2a" select="*[position() mod 2 = 0][not(preceding-sibling::m:mprescripts)]"/>
  </xsl:variable>
  <xsl:variable name="sp">
     <xsl:apply-templates mode="mml2a" select="*[position() mod 2 = 1 and position()!=1][not(preceding-sibling::m:mprescripts)]"/>
  </xsl:variable>
  <xsl:variable name="psb">
    <xsl:apply-templates mode="mml2a" select="m:mprescripts/following-sibling::*[position() mod 2 = 1]"/>
  </xsl:variable>
  <xsl:variable name="psp">
     <xsl:apply-templates mode="mml2a" select="m:mprescripts/following-sibling::*[position() mod 2 = 0]"/>
  </xsl:variable>

  <xsl:variable name="ws" select="for $i in 1 to count($sb/b) 
                                  return max(($sb/b[$i]|$sp/b[$i])/@width)"/>
  <xsl:variable name="pws" select="for $i in 1 to count($psb/b) 
                                  return max(($psb/b[$i]|$psp/b[$i])/@width)"/>
  <xsl:call-template name="mrow">
    <xsl:with-param name="x">
      <xsl:for-each select="$psb/b">
        <xsl:variable name="c" select="position()"/>
        <b width="{$pws[$c]}"
    height="{$b/b/@height + @height + @depth +1}"
    depth="{$b/b/@depth + $psb/b[$c]/@height + $psb/b[$c]/@depth +1}">
 <xsl:copy-of select="x:align($psp/b[$c],$pws[$c],'left',0)"/> 
 <xsl:for-each select="$b/b/l">
   <l><xsl:value-of select="x:pad(' ',$pws[$c])"/></l>
 </xsl:for-each>
 <xsl:copy-of select="x:align($psb/b[$c],$pws[$c],'left',0)"/> 
   </b>
     </xsl:for-each>
      <xsl:copy-of select="$b/b"/>
      <xsl:for-each select="$sb/b">
        <xsl:variable name="c" select="position()"/>
        <b width="{$ws[$c]}"
    height="{$b/b/@height + @height + @depth +1}"
    depth="{$b/b/@depth + $sb/b[$c]/@height + $sb/b[$c]/@depth +1}">
 <xsl:copy-of select="x:align($sp/b[$c],$ws[$c],'left',0)"/> 
 <xsl:for-each select="$b/b/l">
   <l><xsl:value-of select="x:pad(' ',$ws[$c])"/></l>
 </xsl:for-each>
 <xsl:copy-of select="x:align($sb/b[$c],$ws[$c],'left',0)"/> 
   </b>
     </xsl:for-each>
    </xsl:with-param>    
  </xsl:call-template>
</xsl:template>

<xsl:template mode="mml2a" match="m:none">
  <b height="0" width="0" depth="0"><l/></b>
</xsl:template>

<xsl:template  mode="mml2a" match="m:munderover">
  <xsl:variable name="b">
     <xsl:apply-templates mode="mml2a" select="*[1]"/>
  </xsl:variable>
  <xsl:variable name="sb">
     <xsl:apply-templates mode="mml2a" select="*[2]"/>
  </xsl:variable>
  <xsl:variable name="sp">
     <xsl:apply-templates mode="mml2a" select="*[3]"/>
  </xsl:variable>
  <xsl:variable name="w" select="max(($b|$sb|$sp)/b/@width)"/>
  <b width="{$w}"
    height="{$b/b/@height + $sp/b/@height + $sp/b/@depth +1}"
    depth="{$b/b/@depth + $sb/b/@height + $sb/b/@depth +1}">
 <xsl:copy-of select="(x:align($sp/b,$w,'center',0),
                       x:align($b/b,$w,'center',0),
                       x:align($sb/b,$w,'center',0))"/> 
   </b>
</xsl:template>

<xsl:template  mode="mml2a" match="m:munder">
  <xsl:variable name="b">
     <xsl:apply-templates mode="mml2a" select="*[1]"/>
  </xsl:variable>
  <xsl:variable name="sb">
     <xsl:apply-templates mode="mml2a" select="*[2]"/>
  </xsl:variable>
  <xsl:variable name="w" select="max(($b|$sb)/b/@width)"/>
  <b width="{$w}"
    height="{$b/b/@height}"
    depth="{$b/b/@depth + $sb/b/@height + $sb/b/@depth +1}">
 <xsl:copy-of select="(x:align($b/b,$w,'center',0),
                       x:align($sb/b,$w,'center',0))"/> 
   </b>
</xsl:template>

<xsl:template  mode="mml2a" match="m:mover">
  <xsl:variable name="b">
     <xsl:apply-templates mode="mml2a" select="*[1]"/>
  </xsl:variable>
  <xsl:variable name="sp">
     <xsl:apply-templates mode="mml2a" select="*[2]"/>
  </xsl:variable>
  <xsl:variable name="w" select="max(($b|$sp)/b/@width)"/>
  <b width="{$w}"
    height="{$b/b/@height + $sp/b/@height + $sp/b/@depth +1}"
    depth="{$b/b/@depth}">
 <xsl:copy-of select="(x:align($sp/b,$w,'center',0),
                       x:align($b/b,$w,'center',0))"/> 
   </b>
</xsl:template>



<xsl:template  mode="mml2a" match="m:msqrt" name="msqrt">
  <xsl:variable name="b">
    <xsl:call-template name="mrow"/>
  </xsl:variable>
<b width="{$b/b/@width + 4}" depth="{$b/b/@depth}"
         height="{$b/b/@height +1}">
<l>
<xsl:text>   </xsl:text>
<xsl:value-of select="x:pad('_',$b/b/@width)"/>
<xsl:text> </xsl:text>
</l>
 <xsl:for-each select="$b/b/l">
<l>
<xsl:value-of select="if (position()=last()-1) then ('_ |')
else if (position()=last()) then (' \|') else '  |'
"/>
<xsl:value-of select="."/>
<xsl:text> </xsl:text>
</l>
</xsl:for-each>
</b>
</xsl:template>

<xsl:template  mode="mml2a" match="m:mroot">
  <xsl:variable name="b">
     <xsl:apply-templates mode="mml2a" select="*[1]"/>
  </xsl:variable>
  <xsl:variable name="s">
     <xsl:apply-templates mode="mml2a" select="*[2]"/>
  </xsl:variable>
<xsl:call-template name="mrow">
 <xsl:with-param name="x">
  <b width="{$s/b/@width}" depth="0" height="{$s/b/@height + $s/b/@depth + 2}">
  <xsl:copy-of select="$s/b/l"/>
  <l><xsl:value-of select="x:pad(' ',$s/b/@width - 1)"/>_</l>
  <l><xsl:value-of select="x:pad(' ',$s/b/@width )"/></l>
</b>
<b width="{$b/b/@width + 2}" depth="{$b/b/@depth}"
         height="{$b/b/@height +1}">
<l>
<xsl:text>  </xsl:text>
<xsl:value-of select="x:pad('_',$b/b/@width)"/>
</l>
 <xsl:for-each select="$b/b/l">
<l>
<xsl:value-of select="if (position()=last()-1) then (' |')
else if (position()=last()) then ('\|') else '  '
"/>
<xsl:value-of select="."/>
</l>
</xsl:for-each>
</b>
</xsl:with-param>
</xsl:call-template>
</xsl:template>


<xsl:template  mode="mml2a" match="m:mfrac">
  <xsl:variable name="n">
     <xsl:apply-templates mode="mml2a" select="*[1]"/>
  </xsl:variable>
  <xsl:variable name="d">
     <xsl:apply-templates mode="mml2a" select="*[2]"/>
  </xsl:variable>
  <xsl:variable name="w" select="max(($n|$d)/b/@width)"/>
<b width="{$w}" height="{$n/b/@height+$n/b/@depth +1}"
         depth="{$d/b/@height+$d/b/@depth +1}">
 <xsl:copy-of select="x:align($n/b,$w,'center',0)"/>
 <l><xsl:value-of select="x:pad('-',$w)"/></l>
 <xsl:copy-of select="x:align($d/b,$w,'center',0)"/>
</b>
</xsl:template>

<xsl:template mode="mml2a" match="m:mrow" name="mrow">
<xsl:param name="x">
  <xsl:apply-templates mode="mml2a" select="*"/>
</xsl:param>
<xsl:choose>
<xsl:when test="*">
<xsl:variable name="s" select="max($x/b/(@height|@depth))"/>
<xsl:variable name="xx" select="for $b in $x/b return x:stretch($b,$s)"/>
<!-- bug avoid, where is empty width comming from... -->
<xsl:variable name="w" select="xs:integer(0+sum((0,$xx/@width[.!=''])))"/>
<xsl:variable name="h" select="xs:integer(max((0,$xx/@height)))"/>
<xsl:variable name="d" select="xs:integer(max((0,$xx/@depth)))"/>
<b height="{$h}" width="{$w}" depth="{$d}">
<xsl:for-each select="1 to $h">
<xsl:variable name="l" select="position()"/>
<l>
  <xsl:for-each select="$xx">
<xsl:variable name="ll" select="$l+ @height - $h"/>
<xsl:value-of select="
 if (l[$ll]) then (l[$ll]) else (x:pad(' ',@width))
 "/>
</xsl:for-each>
</l>
</xsl:for-each>
<l>
  <xsl:for-each select="$xx">
<xsl:value-of select="l[number(current()/@height)+1]"/>
</xsl:for-each>
</l>
<xsl:for-each select="1 to $d">
<xsl:variable name="l" select="position()"/>
<l>
  <xsl:for-each select="$xx">
<xsl:variable name="ll" select="@height + 1 + $l "/>
<xsl:value-of select="
 if (l[$ll]) then (l[$ll]) else (x:pad(' ',@width))
 "/>
</xsl:for-each>
</l>
</xsl:for-each>
</b>
</xsl:when>
<xsl:otherwise>
    <b width="0" height="0" depth="0"><l/></b>
</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template mode="mml2a" match="m:mfenced">
  <xsl:variable name="s" select="if (not(@separators)) then (',') else translate(@separators,' ','')"/>
  <xsl:variable name="sl" select="string-length($s)"/>
 <xsl:variable name="x">
   <m:mrow>
     <m:mo><xsl:value-of select="if (@open) then (@open) else '('"/></m:mo>
     <xsl:for-each select="*">
       <xsl:copy-of select="."/>
       <xsl:if test="position()!=last() and not(../@separators='')"><m:mo><xsl:value-of select="substring($s,min(($sl,position())),1)"/></m:mo></xsl:if>
    </xsl:for-each>
     <m:mo><xsl:value-of select="if (@close) then (@close) else ')'"/></m:mo>
  </m:mrow>
 </xsl:variable>
 <xsl:apply-templates mode="mml2a" select="$x/*"/>
</xsl:template>


<xsl:template mode="mml2a" match="m:mtable">
<!--
  mtr and mtd produced (in TeX-speak) unset boxes, which consist of b
  elements representing the natural width of each of the elements
  packaged in a d element which specifes the alignment and spanning
  each row is represented by an r element which wraps the d elements
  corresponding to that rows cells.

  This template then just needs to find the required width of each
  column and then call x:align() to repackage each cell to the
  required width and call the mrow template on each row.
  On every column except the first, a margin of 1 is used to ensure
  column spearation.

  Using mrow here should be fixed: as it doesn't allow row spanning
  to be supported, currently only column spanning is supported.
  Currently assumes that every column has, in some row, a cell that
  gives the width of the column. If there is a column that _only_ has
  spanned entries, the code will go wrong. If spanned entries are
  wider than the columns so spanned things won't go as wrong but the
  ascii art alignment will go astray.

  The table baseline is vertically centered (ie @height = @depth +/- 1)
-->
<xsl:variable name="x">
 <xsl:apply-templates mode="mml2a" select="m:mtr"/>
</xsl:variable>
<xsl:variable name="rls" select="if (@rowlines) then (tokenize(@rowlines,' +')) else ('none')"/>
<xsl:variable name="ws" select="for $i in 1 to max( for $r in $x/r
return count($r/d)) return
                                max($x/r/d[not(@columnwidth)][$i]/b/@width)"/>
<!--
<xsl:message>
<xsl:copy-of select="$x"/>
count: <xsl:value-of select="count($ws)"/>
c: <xsl:for-each select="$x/r">
|<xsl:value-of select="position()"
/>: <xsl:value-of select="count(d)"/>
</xsl:for-each>
</xsl:message>
-->
<xsl:variable name="y">
<xsl:for-each select="$x/r">
    <xsl:variable name="r" select="position()"/>
    <xsl:variable name="rl" select="if ($r=last()) then ('none') else ($rls[min(($r,count($rls)))])"/>
<xsl:call-template name="mrow">
 <xsl:with-param name="x">
  <xsl:for-each select="d[not(@span)]">
    <xsl:variable name="c" select="position()"/>
    <xsl:variable name="w" select="xs:integer(
  (if (@columnspan)
   then (@columnspan -1 + sum($ws[position()=$c to xs:integer($c + current()/@columnspan - 1)]))
   else ($ws[$c]))
  +(if ($c=1) then (0) else (1)))"/>
    <b width="{$w}" depth="{b/@depth+(if ($rl='none') then (0) else (1))}">
      <xsl:copy-of select="b/@* except b/(@width|@depth)"/>
      <xsl:copy-of select="x:align(b,$w,@a,if ($c=1) then (0) else (1))"/>
      <xsl:choose>
      <xsl:when test="$rl='solid'">
      <l><xsl:value-of select="x:pad('_',$w)"/></l>
      </xsl:when>
      <xsl:when test="$rl='dashed'">
      <l><xsl:value-of select="x:pad('.',$w)"/></l>
      </xsl:when>
      </xsl:choose>
    </b>
  </xsl:for-each>
  <xsl:if test="count(d) &lt; count($ws)">
    <xsl:variable name="ww" select="count($ws) - count(current()/d) + sum($ws[position()&gt;count(current()/d)])"/>
    <b width="{$ww}" height="0" depth="0">
      <l><xsl:value-of select="x:pad(' ',$ww)"/></l>
    </b>
  </xsl:if>
 </xsl:with-param>
</xsl:call-template>
</xsl:for-each>
</xsl:variable>
<xsl:variable name="h" select="sum($y/b/@height|$y/b/@depth)+count($y/b) -1"/>
<b height="{$h idiv 2}"
   depth="{$h - ($h idiv 2)}"
   width="{$y/b[1]/@width}">
<xsl:copy-of select="$y/b/l"/>
</b>
</xsl:template>

<xsl:template mode="mml2a" match="m:mtr">
<r>
 <xsl:apply-templates mode="mml2a" select="m:mtd"/>
</r>
</xsl:template>

<xsl:template mode="mml2a" match="m:mtd">
    <xsl:variable name="c" select="position()"/>
    <xsl:variable name="ca" select="tokenize((((../..|..|.)/@columnalign)[last()],'center')[1],' +')"/>
  <d a="{$ca[min((last(),$c))]}">
    <xsl:copy-of select="@columnspan"/>
   <xsl:call-template name="mrow"/>
  </d>
  <xsl:if test="@columnspan">
<!--
  Add fake column entries so that the max col width calculation can
  easily determine the columns, but add span attribute so this
  element isn't actually used in the implied mrow (othewise the 1
  character margin would spoil the alignment). See test for @span above.
-->
    <xsl:for-each select="1 to xs:integer(@columnspan -1)">
      <d span="yes"><b height="0" width="0" depth="0"><l/></b></d>
    </xsl:for-each>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
