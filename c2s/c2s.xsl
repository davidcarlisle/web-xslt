<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- Copyright Robert Miner 2010 

Use and distribution of this code are permitted under the terms of the <a
href="http://www.w3.org/Consortium/Legal/copyright-software-19980720"
>W3C Software Notice and License</a>.-->

<xsl:stylesheet version="2.0"
               xmlns:dsi="http://www.dessci.com"
               xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
               xmlns:xs="http://www.w3.org/2001/XMLSchema"
               xmlns:m="http://www.w3.org/1998/Math/MathML"
               xmlns="http://www.w3.org/1998/Math/MathML"
	       xmlns:saxon="http://saxon.sf.net/"
	       xpath-default-namespace="http://www.w3.org/1998/Math/MathML"
               exclude-result-prefixes="dsi xs m saxon">

<xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
<xsl:output name="oxml" method="xml" indent="yes" omit-xml-declaration="yes"/>
<xsl:strip-space elements="*"/>
<xsl:variable name="debug">false</xsl:variable>

<!-- templates for the runc2s test harness -->
<xsl:template name="m">
  <xsl:variable name="x">
    <xsl:apply-templates select="/"/>
  </xsl:variable>
  <xsl:copy-of select="$x/descendant::m:math[last()]"/> 
</xsl:template>

<xsl:template name="d">
<xsl:variable name="x">
  <xsl:variable name="x">
    <xsl:apply-templates select="/"/>
  </xsl:variable>
<xsl:copy-of select="$x/descendant::m:math[last()]"/> 
</xsl:variable>
<xsl:variable name="new" select="$x/descendant::m:math[last()]"/>
<xsl:variable name="old" select="doc(replace(document-uri(/),'/Content/','/StrictContent/'))/*"/>
<xsl:if test="not(dsi:deep-equal($new,$old))">
<div>
<b>
<xsl:value-of select="substring-after(document-uri(/),'main/')"/>
</b>
<table>
<tr>
<td>old (om2cmml)</td>
<td>new (c2s)</td>
</tr>
<tr xsl:use-when="function-available('saxon:serialize')">
<td>
<pre style="border: solid thin">
<xsl:value-of select="saxon:serialize($old,'oxml')"/>
</pre>
</td>
<td>
<pre style="border: solid thin">
<xsl:value-of select="saxon:serialize($new,'oxml')"/>
</pre>
</td>
</tr>
</table>
</div>
</xsl:if>
</xsl:template>



<xsl:template name="c2sroot" match="/">

<xsl:if test="$debug='true'">
<xsl:text>
====== Pass 1 (normalize non-strict bind) =======
</xsl:text>
</xsl:if>

      <xsl:variable name="p1r">
	<xsl:apply-templates mode="pass1"/>
      </xsl:variable>

<xsl:if test="$debug='true'">
<xsl:copy-of select="$p1r"/>
<xsl:text>
====== Pass 2 (Apply special case rules for operators using qualifiers idiomatically) =======
</xsl:text>
</xsl:if>

      <xsl:variable name="p2r">
	<xsl:apply-templates select="$p1r/*" mode="pass2"/>
      </xsl:variable>

<xsl:if test="$debug='true'">
<xsl:copy-of select="$p2r"/>
<xsl:text>
====== Pass 3 (rewrite qualifiers as DOAs) =======
</xsl:text>
</xsl:if>

      <xsl:variable name="p3r">
	<xsl:apply-templates select="$p2r/*" mode="pass3"/>
      </xsl:variable>

<xsl:if test="$debug='true'">
<xsl:copy-of select="$p3r"/>
<xsl:text>
====== Pass 4 (rewrite container markup, assuming all qualifiers have be rewritten to DOAs) =======
</xsl:text>
</xsl:if>

      <xsl:variable name="p4r">
	<xsl:apply-templates select="$p3r/*" mode="pass4"/>
      </xsl:variable>

<xsl:if test="$debug='true'">
<xsl:copy-of select="$p4r"/>
<xsl:text>
====== Pass 5 (Apply rules for operators using DOA qualifiers) =======
</xsl:text>
</xsl:if>

      <xsl:variable name="p5r">
	<xsl:apply-templates select="$p4r/*" mode="pass5"/>
      </xsl:variable>
      
<xsl:if test="$debug='true'">
<xsl:copy-of select="$p5r"/>
<xsl:text>
====== Pass 6 (Eliminate remaining domainofapplication) =======
</xsl:text>
</xsl:if>

      <xsl:variable name="p6r">
	<xsl:apply-templates select="$p5r/*" mode="pass6"/>
      </xsl:variable>

<xsl:if test="$debug='true'">
<xsl:copy-of select="$p6r"/>
<xsl:text>
====== Pass 7 (deal with non-strict cn's, other non-strict tokens) =======
</xsl:text>
</xsl:if>

      <xsl:variable name="p7r">
	<xsl:apply-templates select="$p6r/*" mode="pass7"/>
      </xsl:variable>

<xsl:if test="$debug='true'">
<xsl:copy-of select="$p7r"/>
<xsl:text>
====== Pass 8 (rewrite operator elements as csymbols ) =======
</xsl:text>
</xsl:if>

      <xsl:variable name="p8ar">
	<xsl:apply-templates select="$p7r/*" mode="pass8"/>
      </xsl:variable>
      <xsl:variable name="p8r">
	<xsl:apply-templates select="$p8ar/*" mode="pass8b"/>
      </xsl:variable>

<xsl:if test="$debug='true'">
<xsl:copy-of select="$p8r"/>
<xsl:text>
====== Pass 9 (rewrite type, definitionURL, non-strict attributes ) =======
</xsl:text>
</xsl:if>

      <xsl:variable name="p9r">
	<xsl:apply-templates select="$p8r/*" mode="pass9"/>
      </xsl:variable>

<xsl:choose>
  <xsl:when test="$debug='true'">
      <xsl:variable name="p10r">
	<xsl:apply-templates select="$p9r/*" mode="pass10"/>
      </xsl:variable>
      <xsl:copy-of select="$p10r"/>
  </xsl:when>
  <xsl:otherwise>
      <xsl:copy-of select="$p9r"/>
  </xsl:otherwise>
</xsl:choose>

</xsl:template>

<!-- DEBUG ONLY: take back out type annotations for easier comparison -->
<xsl:template match="semantics" mode="pass10">
  <xsl:choose>
    <xsl:when test="ci[1]/string()='tendsto'">
      <xsl:apply-templates select="."/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="./*[1]"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- 
1. Normalize non-strict bind: Change the outer bind tags in binding 
expressions to apply if they have qualifiers or multiple children. 

TBD: should also switch to apply for missing binding op in position 1?
-->
<xsl:template match="bind" mode="pass1">
  <xsl:variable name="followingBvar" select="count(bvar[last()]/following-sibling::*)"/>
  <xsl:choose>
    <xsl:when test="domainofapplication|condition|interval|lowlimit|uplimit">
      <xsl:element name="apply">
	<xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="$followingBvar&gt;1">
      <xsl:element name="apply">
	<xsl:apply-templates mode="#current"/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="bind">
	<xsl:apply-templates mode="#current"/>
      </xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- rewrite reln -->
<xsl:template match="reln" mode="pass1">
  <xsl:element name="apply">
    <xsl:apply-templates mode="#current"/>
  </xsl:element>
</xsl:template>

<!-- remove fn -->
<xsl:template match="fn" mode="pass1"><xsl:apply-templates mode="#current"/></xsl:template>

<!--
2. Apply Special Case Operator Rules for non-DOA qualifiers: 
a. Rewrite derivatives with rules Rewrite: diff, Rewrite: nthdiff, and Rewrite: 
   partialdiffdegree to explicate the binding status of the variables involved.
b. Rewrite integrals with the rules Rewrite: int and Rewrite: int limits to 
   disambiguate the status of bound and free variables and of the orientation of 
   the range of integration if it is given as a lowlimit/uplimit pair.
c. Rewrite limits as described in Rewrite: tendsto and Rewrite: limits condition.
d. Rewrite sums and products as described in Section 4.4.6.1 Sum <sum/> and 
   Section 4.4.6.2 Product <product/>.  
e. Rewrite roots as described in Section 4.4.2.11 Root <root/>.
f. Rewrite logarithms as described in Section 4.4.7.4 Logarithm <log/>.
g. Rewrite moments as described in Section 4.4.8.6 Moment (<moment/>, <momentabout>).

Removed
h. forall w/condition
i. set operators w/condition
j. ??? selector, rewrite order of arguments
k. ??? set|list w/condition

-->

<!-- Case 2a: rewrite derivatives etc. -->
<xsl:template match="apply[diff][bvar]" mode="pass2">
  <xsl:element name="apply">
    <xsl:element name="apply">
      <xsl:choose>
	<xsl:when test="bvar[degree]">  <!-- nth diff-->
	  <xsl:element name="csymbol"><xsl:attribute name="cd">calculus1</xsl:attribute>nthdiff</xsl:element>
	  <xsl:apply-templates select="bvar/degree/node()" mode="#current"/><!-- n -->
	  <xsl:element name="bind">
	    <xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
	    <xsl:element name="bvar">
	      <xsl:apply-templates select="bvar/node()[name()!='degree']" mode="#current"/><!-- x -->
	    </xsl:element>
	    <xsl:apply-templates select="bvar/following-sibling::*" mode="#current"/><!-- expr in x -->
	  </xsl:element>
	</xsl:when>
	<xsl:otherwise> <!-- plain diff -->
	  <xsl:element name="csymbol"><xsl:attribute name="cd">calculus1</xsl:attribute>diff</xsl:element>
	  <xsl:element name="bind">
	    <xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
	    <xsl:element name="bvar">
	      <xsl:apply-templates select="bvar/node()" mode="#current"/><!-- x -->	    
	    </xsl:element>
	    <xsl:apply-templates select="bvar/following-sibling::*" mode="#current"/><!-- expr in x -->
	  </xsl:element>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:element><!-- /apply -->
    <xsl:apply-templates select="bvar/node()[name()!='degree']" mode="#current"/><!-- x -->	    
  </xsl:element><!-- /apply -->
</xsl:template>

<xsl:template match="apply[partialdiff][bvar]" mode="pass2">
  <xsl:element name="apply">
    <xsl:element name="apply">
      <xsl:element name="csymbol"><xsl:attribute name="cd">calculus1</xsl:attribute>partialdiffdegree</xsl:element>
      <xsl:element name="apply"><!-- list of degrees -->
	<xsl:element name="csymbol"><xsl:attribute name="cd">list1</xsl:attribute>list</xsl:element>
	<xsl:for-each select="bvar"><!-- n1 - nk, default to 1 if not specified -->
	  <xsl:choose>
	    <xsl:when test="degree"><xsl:apply-templates select="degree/node()" mode="#current"/></xsl:when>
	    <xsl:otherwise><xsl:element name="cn">1</xsl:element></xsl:otherwise>
	  </xsl:choose>
	</xsl:for-each>
      </xsl:element>
      <xsl:choose><!-- total degree -->
	<xsl:when test="degree"><!-- explicit total degree -->
	  <xsl:apply-templates select="degree/node()" mode="#current"/>
	</xsl:when>
	<xsl:otherwise><!-- formal sum of individual degrees -->
	  <xsl:element name="apply">
	    <xsl:element name="csymbol"><xsl:attribute name="cd">arith1</xsl:attribute>plus</xsl:element>
	    <xsl:for-each select="bvar"><!-- n1 - nk, default to 1 if not specified -->
	      <xsl:choose>
		<xsl:when test="degree"><xsl:apply-templates select="degree/node()" mode="#current"/></xsl:when>
		<xsl:otherwise><xsl:element name="cn">1</xsl:element></xsl:otherwise>
	      </xsl:choose>
	    </xsl:for-each>
	  </xsl:element>
	</xsl:otherwise>
      </xsl:choose>
      <xsl:element name="bind"><!-- lambda function to be differentiated -->
	<xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
	<xsl:for-each select="bvar">
	  <xsl:element name="bvar">
	    <xsl:apply-templates select="node()[name()!='degree']" mode="#current"/><!-- x1 ...xk -->	    
	  </xsl:element>
	</xsl:for-each>
	<!-- expr in x -->	
	<xsl:apply-templates select="(bvar|degree)[position()=last()]/following-sibling::*" mode="#current"/>
      </xsl:element>
    </xsl:element>
    <xsl:for-each select="bvar"><!-- apply to variables to make them free again -->
      <xsl:apply-templates select="node()[name()!='degree']" mode="#current"/><!-- x1 ...xk -->	    
    </xsl:for-each>
  </xsl:element><!-- /apply -->
</xsl:template>

<!-- Case 2b: rewrite integrals -->
<xsl:template match="apply[int][bvar]" mode="pass2">
  <xsl:choose>
    <xsl:when test="lowlimit and uplimit"><!-- apply int bvar lowlimit uplimit expr -->
      <xsl:element name="apply">
	<xsl:element name="csymbol"><xsl:attribute name="cd">calculus1</xsl:attribute>defint</xsl:element>
	<xsl:element name="apply">
	  <xsl:element name="csymbol"><xsl:attribute name="cd">interval1</xsl:attribute>oriented_interval</xsl:element>
	  <xsl:apply-templates select="lowlimit/node()" mode="#current"/>
	  <xsl:apply-templates select="uplimit/node()" mode="#current"/>
	</xsl:element>
	<xsl:element name="bind"><!-- lambda function to be integrated -->
	  <xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
	  <xsl:element name="bvar">
	    <xsl:apply-templates select="bvar/node()" mode="#current"/>
	  </xsl:element>
	  <xsl:apply-templates select="(bvar|uplimit|lowlimit)[position()=last()]/following-sibling::*" 
			       mode="#current"/><!-- expr in x -->	
	</xsl:element>
      </xsl:element>    
    </xsl:when>
    <xsl:when test="condition"><!-- apply int bvar condition expr -->
      <xsl:element name="apply">
	<xsl:element name="csymbol"><xsl:attribute name="cd">calculus1</xsl:attribute>defint</xsl:element>
	<xsl:element name="apply"><!-- set constructed by condition-->
	  <xsl:element name="csymbol"><xsl:attribute name="cd">set1</xsl:attribute>suchthat</xsl:element>
	  <xsl:element name="ci">R</xsl:element>
	  <xsl:element name="bind">
	    <xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
	    <xsl:apply-templates select="bvar" mode="#current"/>
	    <xsl:choose>
	      <xsl:when test="count(condition)=1">
		<xsl:apply-templates select="condition/*" mode="#current"/>
	      </xsl:when>
	      <xsl:when test="count(condition)>1">
		<xsl:element name="apply">      
		  <xsl:element name="csymbol"><xsl:attribute name="cd">logic1</xsl:attribute>and</xsl:element>
		  <xsl:apply-templates select="condition/*" mode="#current"/>
		</xsl:element>
	      </xsl:when>
	    </xsl:choose>
	  </xsl:element><!-- /bind -->
	</xsl:element><!-- suchthat apply-->
	<xsl:element name="bind"><!-- lambda function to be integrated -->
	  <xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
	  <xsl:element name="bvar">
	    <xsl:apply-templates select="bvar/node()" mode="#current"/>
	  </xsl:element>
	  <xsl:apply-templates select="(bvar|condition)[position()=last()]/following-sibling::*" 
			       mode="#current"/><!-- expr in x -->	
	</xsl:element>
      </xsl:element>    
    </xsl:when>
    <xsl:when test="domainofapplication|interval"><!-- leave d-o-a intact for a later pass -->
      <xsl:copy-of select="."/>
    </xsl:when>
    <xsl:otherwise><!-- apply int expr -->
      <xsl:element name="apply">
	<xsl:element name="apply">
	  <xsl:element name="csymbol"><xsl:attribute name="cd">calculus1</xsl:attribute>int</xsl:element>
	  <xsl:element name="bind"><!-- lambda function to be integrated -->
	    <xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
	    <xsl:element name="bvar">
	      <xsl:apply-templates select="bvar/node()" mode="#current"/>
	    </xsl:element>
	    <xsl:apply-templates select="(bvar|uplimit|lowlimit)[position()=last()]/following-sibling::*" 
				 mode="#current"/><!-- expr in x -->	
	  </xsl:element>
	</xsl:element>    
	<xsl:apply-templates select="bvar/node()" mode="#current"/><!-- x -->
      </xsl:element>    
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- Case 2c: rewrite limits -->
<xsl:template match="apply[limit]" mode="pass2">
  <xsl:element name="apply">
    <xsl:element name="csymbol"><xsl:attribute name="cd">limit1</xsl:attribute>limit</xsl:element>
    <xsl:choose><!-- limiting value -->
      <xsl:when test="condition/apply/tendsto">
	<xsl:apply-templates select="condition/apply/child::*[position()=last()]" mode="#current"/>
      </xsl:when>
      <xsl:when test="lowlimit">
	<xsl:apply-templates select="lowlimit/*" mode="#current"/>
      </xsl:when>
    </xsl:choose>
    <!-- type of approach -->
    <xsl:choose>
      <xsl:when test="condition/apply/tendsto/@type='above'">
	<xsl:element name="csymbol"><xsl:attribute name="cd">limit1</xsl:attribute>above</xsl:element>
      </xsl:when>
      <xsl:when test="condition/apply/tendsto/@type='below'">
	<xsl:element name="csymbol"><xsl:attribute name="cd">limit1</xsl:attribute>below</xsl:element>
      </xsl:when>
      <xsl:when test="condition/apply/tendsto/@type='both_sides'">
	<xsl:element name="csymbol"><xsl:attribute name="cd">limit1</xsl:attribute>both_sides</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="csymbol"><xsl:attribute name="cd">limit1</xsl:attribute>null</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
    <!-- lambda expr -->
    <xsl:element name="bind">
      <xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
      <xsl:apply-templates select="bvar" mode="#current"/><!-- bvar(s) -->
      <!-- expr in bvars -->
      <xsl:apply-templates select="(condition|bvar|lowlimit)[position()=last()]/following-sibling::*" mode="#current"/>
    </xsl:element>
  </xsl:element>    
</xsl:template>

<!-- idiomatic <tendsto/> -->
<xsl:template match="apply[tendsto]" mode="pass2">
  <xsl:element name="apply">
    <xsl:for-each select="./*">
      <xsl:choose>
	<xsl:when test="name()='tendsto'">
	  <xsl:element name="semantics">
	    <xsl:element name="ci">tendsto</xsl:element>
	    <xsl:element name="annotation-xml"><xsl:attribute name="encoding">MathML-Content</xsl:attribute>
	      <xsl:element name="tendsto"/>
	    </xsl:element>
	  </xsl:element>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:apply-templates select="." mode="#current"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:element>
</xsl:template>

<!-- Case 2d: rewrite sums, products. -->
<xsl:template match="apply[sum|product][bvar][lowlimit][uplimit]" mode="pass2">
  <xsl:element name="apply">
    <xsl:choose><!-- head term -->
      <xsl:when test="sum">
	<xsl:element name="csymbol"><xsl:attribute name="cd">arith1</xsl:attribute>sum</xsl:element>
      </xsl:when>
      <xsl:when test="product">
	<xsl:element name="csymbol"><xsl:attribute name="cd">arith1</xsl:attribute>product</xsl:element>
      </xsl:when>
    </xsl:choose>
    <xsl:element name="apply"><!-- integer interval -->
      <xsl:element name="csymbol"><xsl:attribute name="cd">interval1</xsl:attribute>integer_interval</xsl:element>
      <xsl:apply-templates select="lowlimit/*" mode="#current"/>
      <xsl:apply-templates select="uplimit/*" mode="#current"/>
    </xsl:element>
    <xsl:element name="bind"><!-- lambda expr -->
      <xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
      <xsl:apply-templates select="bvar" mode="#current"/>
      <xsl:apply-templates select="(bvar|lowlimit|uplimit)[position()=last()]/following-sibling::*" mode="#current"/>
    </xsl:element>
  </xsl:element>    
</xsl:template>

<!-- Case 2e: rewrite roots -->
<xsl:template match="apply[root]" mode="pass2">
  <xsl:element name="apply">
    <xsl:element name="csymbol"><xsl:attribute name="cd">arith1</xsl:attribute>root</xsl:element>
    <xsl:apply-templates select="(degree|root)[position()=last()]/following-sibling::*" mode="#current"/>
    <xsl:choose>
      <xsl:when test="degree">
	<xsl:apply-templates select="degree/*" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="cn"><xsl:attribute name="type">integer</xsl:attribute>2</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:element>    
</xsl:template>

<!-- Case 2f: rewrite logs -->
<xsl:template match="apply[log]" mode="pass2">
  <xsl:element name="apply">
    <xsl:element name="csymbol"><xsl:attribute name="cd">transc1</xsl:attribute>log</xsl:element>
    <xsl:choose>
      <xsl:when test="logbase">
	<xsl:apply-templates select="logbase/*" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="cn"><xsl:attribute name="type">integer</xsl:attribute>10</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="./*[position()=last()]" mode="#current"/>
   </xsl:element>    
</xsl:template>


<!-- Case 2g: rewrite moments -->
<xsl:template match="apply[moment]" mode="pass2">
  <xsl:element name="apply">
    <xsl:element name="csymbol"><xsl:attribute name="cd">s_dist1</xsl:attribute>moment</xsl:element>
    <xsl:choose><!-- degree -->
      <xsl:when test="degree">
	<xsl:apply-templates select="degree/*" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="cn"><xsl:attribute name="type">integer</xsl:attribute>1</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose><!-- point -->
      <xsl:when test="momentabout">
	<xsl:apply-templates select="momentabout/*" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="cn"><xsl:attribute name="type">integer</xsl:attribute>0</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="(momentabout|degree)[position()=last()]/following-sibling::*" mode="#current"/>
  </xsl:element>    
</xsl:template>


<!-- ============================================================================
3. Rewrite qualifiers to use DOA
-->

<!-- Case 3a: rewrite interval qualifiers -->
<xsl:template match="apply[bvar][lowlimit][uplimit]" mode="pass3">
  <xsl:element name="apply">
    <xsl:apply-templates select="child::*[position()=1]" mode="#current"/>
    <xsl:element name="domainofapplication">
      <xsl:element name="apply">
	<xsl:element name="csymbol"><xsl:attribute name="cd">interval1</xsl:attribute>interval</xsl:element>
	<xsl:apply-templates select="lowlimit/*" mode="#current"/>
	<xsl:apply-templates select="uplimit/*" mode="#current"/>
      </xsl:element>
    </xsl:element><!-- /doa -->
    <xsl:apply-templates select="(bvar|lowlimit|uplimit)[position()=last()]/following-sibling::*" mode="#current"/>
  </xsl:element><!-- /apply -->
</xsl:template>

<!-- interval qualifiers for int, sum, product, as per Rewrite: interval qualifier -->
<xsl:template match="apply[int|sum|product][interval]" mode="pass3">
  <xsl:element name="apply">
    <xsl:apply-templates select="interval/preceding-sibling::*" mode="#current"/>
    <xsl:element name="domainofapplication">
      <xsl:element name="apply">
	<xsl:element name="csymbol"><xsl:attribute name="cd">interval1</xsl:attribute>interval</xsl:element>
	<xsl:apply-templates select="interval/*[1]" mode="#current"/>
	<xsl:apply-templates select="interval/*[2]" mode="#current"/>
      </xsl:element>
    </xsl:element><!-- /doa -->
    <xsl:apply-templates select="interval/following-sibling::*" mode="#current"/>
  </xsl:element><!-- /apply -->
</xsl:template>


<!-- Case 3b: rewrite condition -->
<xsl:template match="*[bvar][condition]" mode="pass3">
  <xsl:copy>
    <xsl:apply-templates select="bvar[position()=1]/preceding-sibling::node()" mode="#current"/><!-- head term -->
    <xsl:apply-templates select="bvar" mode="#current"/>
    <xsl:element name="domainofapplication">
      <xsl:element name="apply">
	<xsl:element name="csymbol"><xsl:attribute name="cd">set1</xsl:attribute>suchthat</xsl:element>
	<!-- TBD there are further rules for determining the domain-->
	<xsl:element name="ci">R</xsl:element>
	<xsl:element name="bind">
	  <xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
	  <xsl:apply-templates select="bvar" mode="#current"/>
	  <xsl:choose>
	    <xsl:when test="count(condition)=1">
	      <xsl:apply-templates select="condition/*" mode="#current"/>
	    </xsl:when>
	    <xsl:when test="count(condition)>1">
	      <xsl:element name="apply">      
		<xsl:element name="csymbol"><xsl:attribute name="cd">logic1</xsl:attribute>and</xsl:element>
		<xsl:apply-templates select="condition/*" mode="#current"/>
	      </xsl:element>
	    </xsl:when>
	  </xsl:choose>
	</xsl:element><!-- bind -->
      </xsl:element><!-- suchthat apply-->
    </xsl:element><!-- /doa -->
    <xsl:apply-templates select="condition[position()=last()]/following-sibling::node()" mode="#current"/>
  </xsl:copy>
</xsl:template>

<!-- Case 3c: rewrite multiple domainsofapplication -->
<xsl:template match="apply[domainofapplication]" mode="pass3">
  <xsl:element name="apply">
    <xsl:apply-templates select="domainofapplication[position()=1]/preceding-sibling::node()" mode="#current"/>
    <xsl:choose>
      <xsl:when test="count(domainofapplication)=1">
	<xsl:apply-templates select="domainofapplication" mode="#current"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="domainofapplication">
	  <xsl:element name="csymbol"><xsl:attribute name="cd">set1</xsl:attribute>intersection</xsl:element>
	  <xsl:apply-templates select="domainofapplication/*" mode="#current"/>      
	</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="domainofapplication[position()=last()]/following-sibling::node()" mode="#current"/>
  </xsl:element>
</xsl:template>


<!--
4. Normalize Container Markup:
a. Rewrite sets and lists by the rule Rewrite: n-ary setlist domainofapplication.
b. Rewrite interval, vectors, matrices, and matrix rows as described in Section 4.4.1.1 
   Interval <interval>, Section 4.4.9.1 Vector <vector>, Section 4.4.9.2 Matrix <matrix> 
   and Section 4.4.9.3 Matrix row <matrixrow>.
c. Rewrite lambda expressions by the rules Rewrite: lambda and Rewrite: lambda domainofapplication
d. Rewrite piecewise functions as described in Section 4.4.1.9 Piecewise declaration 
   (<piecewise>, <piece>, <otherwise>).
-->

<!-- Rewrite sets and lists -->
<xsl:template match="set|list" mode="pass4">
  <xsl:choose>
    <xsl:when test="bvar and domainofapplication">
      <xsl:variable name="bvar" select="bvar/*"/>
      <xsl:variable name="func" select="child::*[position()>2]"/>
      <xsl:choose>
	<!-- the child of the d-o-a is already a strict set contructed earlier -->
	<xsl:when test="domainofapplication/apply/csymbol[string()='suchthat'] and
			domainofapplication/apply/csymbol[@cd=concat(name(),'1')] and
			count(bvar/node())=1 and
			dsi:deep-equal($bvar, $func)">
	  <xsl:apply-templates select="domainofapplication/*" mode="#current"/>
	</xsl:when>
	<!-- construct a strict set or list-->
	<xsl:otherwise>
	  <xsl:element name="apply">
	    <xsl:element name="csymbol">
	      <xsl:choose>
		<xsl:when test="name()='set'"><xsl:attribute name="cd">set1</xsl:attribute></xsl:when>
		<xsl:otherwise><xsl:attribute name="cd">list1</xsl:attribute></xsl:otherwise>
	      </xsl:choose>map</xsl:element>
	    <xsl:element name="bind">
	      <xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
	      <xsl:apply-templates select="bvar" mode="#current"/>
	      <xsl:apply-templates select="child::*[position()>2]" mode="#current"/>
	    </xsl:element>
	    <xsl:apply-templates select="domainofapplication/*" mode="#current"/>
	  </xsl:element>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise><!-- elements are enumerated -->
      <xsl:element name="apply">
	<xsl:choose>
	  <xsl:when test="name()='set'">
	    <xsl:element name="csymbol"><xsl:attribute name="cd">set1</xsl:attribute>set</xsl:element>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:element name="csymbol"><xsl:attribute name="cd">list1</xsl:attribute>list</xsl:element>
	  </xsl:otherwise>
	</xsl:choose>
	<xsl:apply-templates select="child::*" mode="#current"/>
      </xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Rewrite intervals, vectors, matrices -->
<xsl:template match="interval" mode="pass4">
  <xsl:element name="apply">
    <xsl:element name="csymbol"><xsl:attribute name="cd">interval1</xsl:attribute>
      <xsl:choose>
	<xsl:when test="@closure='open'">interval_oo</xsl:when>
	<xsl:when test="@closure='closed'">interval_cc</xsl:when>
	<xsl:when test="@closure='closed-open'">interval_co</xsl:when>
	<xsl:when test="@closure='open-closed'">interval_oc</xsl:when>
	<xsl:otherwise>interval_cc</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <xsl:apply-templates mode="#current"/>
  </xsl:element>
</xsl:template>

<xsl:template match="vector|matrix|matrixrow" mode="pass4">
  <xsl:element name="apply">
    <xsl:element name="csymbol">
      <xsl:attribute name="cd">linalg2</xsl:attribute>
      <xsl:value-of select="name()"/>
    </xsl:element>
    <xsl:apply-templates mode="#current"/>
  </xsl:element>
</xsl:template>

<!-- Rewrite lambda expressions -->
<xsl:template match="lambda[bvar]" mode="pass4">
  <xsl:choose>

    <!-- no domainofapplication case -->
    <xsl:when test="count(./domainofapplication)=0">
      <xsl:element name="bind">
	<xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
	<xsl:apply-templates mode="#current"/>
      </xsl:element>
    </xsl:when>

    <!-- bvar + domainofapplication expr case -->
    <xsl:otherwise>
      <xsl:element name="apply">
	<xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>restriction</xsl:element>
	<xsl:element name="bind">
	  <xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
	  <xsl:apply-templates select="bvar" mode="#current"/>
	  <!-- this is pretty fragile -->
	  <xsl:apply-templates select="domainofapplication/following-sibling::*" mode="#current"/>
	</xsl:element>
	<xsl:apply-templates select="domainofapplication/*" mode="#current"/>
      </xsl:element>
    </xsl:otherwise>

  </xsl:choose>
</xsl:template>

<!-- Rewrite piecewise -->
<xsl:template match="piecewise" mode="pass4">
  <xsl:element name="apply">
    <xsl:element name="csymbol"><xsl:attribute name="cd">piece1</xsl:attribute>piecewise</xsl:element>
    <xsl:apply-templates mode="#current"/>
  </xsl:element>
</xsl:template>

<xsl:template match="piece" mode="pass4">
  <xsl:element name="apply">
    <xsl:element name="csymbol"><xsl:attribute name="cd">piece1</xsl:attribute>piece</xsl:element>
    <xsl:apply-templates mode="#current"/>
  </xsl:element>
</xsl:template>

<xsl:template match="otherwise" mode="pass4">
  <xsl:element name="apply">
    <xsl:element name="csymbol"><xsl:attribute name="cd">piece1</xsl:attribute>otherwise</xsl:element>
    <xsl:apply-templates mode="#current"/>
  </xsl:element>
</xsl:template>

<!--
5. Apply Special Case Operator Rules for DOA qualifiers: 
a. Rewrite min, max, mean and similar n-ary/unary operators by the rules 
   Rewrite: n-ary unary set, Rewrite: n-ary unary domainofapplication and 
   Rewrite: n-ary unary single.
b. Rewrite the quantifiers forall and exists used with d-o-a to expressions 
   using implication and conjunction by the rule Rewrite: quantifier.
c. Rewrite int used with d-o-a (with or without a bvar)
d. Rewrite sum | product used with d-o-a (with or without a bvar)
-->

<!-- Case 5a: rewrite min, max, etc. -->
<xsl:template match="apply[min|max|mean|sdev|variance|median|mode]" mode="pass5">
  <xsl:variable name="opname"><xsl:value-of select="*[position()=1]/name()"/></xsl:variable>
  <xsl:choose>
    <!-- n-ary unary domainofapplication [apply max bvar doa expr /apply]-->
    <xsl:when test="bvar and domainofapplication and count(*) >= 4">
      <xsl:element name="apply">
	<xsl:element name="csymbol">
	  <xsl:attribute name="cd"><xsl:value-of select="$symbols//element/op[string()=$opname]/../cd"/></xsl:attribute>
	  <xsl:value-of select="*[position()=1]/name()"/>
        </xsl:element>
	<xsl:variable name="bvar" select="bvar/*"/>
	<xsl:variable name="func" select="(bvar|domainofapplication)[position()=last()]/following-sibling::*"/>
	<xsl:choose>
	  <!-- the child of the d-o-a is already a strict set contructed earlier -->
	  <xsl:when test="domainofapplication/apply/csymbol[string()='suchthat'] and
			  domainofapplication/apply/csymbol[@cd='set1'] and
			  count(bvar/node())=1 and
			  dsi:deep-equal($bvar, $func)">
	    <xsl:apply-templates select="domainofapplication/*" mode="#current"/>
	  </xsl:when>
	  <!-- construct a strict set -->
	  <xsl:otherwise>
	    <xsl:element name="apply">
	      <xsl:element name="csymbol"><xsl:attribute name="cd">set1</xsl:attribute>map</xsl:element>
	      <xsl:element name="bind">
		<xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
		<xsl:apply-templates select="bvar" mode="#current"/>
		<xsl:apply-templates select="(bvar|domainofapplication)[position()=last()]/following-sibling::*" 
				     mode="#current"/>
	      </xsl:element>
	      <xsl:apply-templates select="domainofapplication/*" mode="#current"/>
	    </xsl:element>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:element>
    </xsl:when>
    <!-- n-ary unary set [apply min a b ... /apply] -->
    <xsl:when test="count(*) != 2 and count(bvar)=0 and count(domainofapplication)=0">
      <xsl:element name="apply">
	<xsl:element name="csymbol">
	  <xsl:attribute name="cd"><xsl:value-of select="$symbols//element/op[string()=$opname]/../cd"/></xsl:attribute>
	  <xsl:value-of select="*[position()=1]/name()"/>
        </xsl:element>
        <xsl:element name="apply">
	  <xsl:element name="csymbol"><xsl:attribute name="cd">set1</xsl:attribute>set</xsl:element>
	  <xsl:apply-templates select="./*[position()>1]" mode="#current"/>
	</xsl:element>
      </xsl:element>
    </xsl:when>
    <!-- n-ary unary single, min A with A a set --> 
    <xsl:when test="count(*)=2">
      <xsl:element name="apply">
	<xsl:element name="csymbol">
	  <xsl:attribute name="cd"><xsl:value-of select="$symbols//element/op[string()=$opname]/../cd"/></xsl:attribute>
	  <xsl:value-of select="*[position()=1]/name()"/>
        </xsl:element>
	<xsl:apply-templates select="./*[position()>1]" mode="#current"/>
      </xsl:element>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<!-- Case 5b: rewrite forall, exists -->
<xsl:template match="apply[forall|exists]" mode="pass5">
  <xsl:choose>
    <xsl:when test="bvar">
      <xsl:element name="bind">
	<xsl:choose>
	  <xsl:when test="exists">
	    <xsl:element name="csymbol"><xsl:attribute name="cd">quant1</xsl:attribute>exists</xsl:element>
	  </xsl:when>
	  <xsl:when test="forall">
	    <xsl:element name="csymbol"><xsl:attribute name="cd">quant1</xsl:attribute>forall</xsl:element>
	  </xsl:when>
	</xsl:choose>
	<xsl:apply-templates select="./bvar" mode="#current"/>
	<xsl:choose>
	  <xsl:when test="domainofapplication"><!-- doa is present -->      
	    <xsl:element name="apply">
	      <xsl:element name="csymbol"><xsl:attribute name="cd">logic1</xsl:attribute>
		<xsl:choose>
		  <xsl:when test="exists">and</xsl:when>
		  <xsl:when test="forall">implies</xsl:when>
		</xsl:choose>
	      </xsl:element>
	      <xsl:element name="apply">
		<xsl:element name="csymbol"><xsl:attribute name="cd">set1</xsl:attribute>in</xsl:element>
		<xsl:apply-templates select="./bvar/*" mode="#current"/>
		<xsl:apply-templates select="./domainofapplication/*" mode="#current"/>
	      </xsl:element>
	      <xsl:apply-templates select="(bvar|domainofapplication)[position()=last()]/following-sibling::*" 
				   mode="#current"/>
	    </xsl:element>
	  </xsl:when>
	  <xsl:otherwise><!-- just dump out the expr-in-x -->
	    <xsl:apply-templates select="(bvar|domainofapplication)[position()=last()]/following-sibling::*" 
				 mode="#current"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise><!-- no bvar, this is probably always an error -->
      <xsl:element name="bind">
	<xsl:choose>
	  <xsl:when test="exists">
	    <xsl:element name="csymbol"><xsl:attribute name="cd">quant1</xsl:attribute>exists</xsl:element>
	  </xsl:when>
	  <xsl:when test="forall">
	    <xsl:element name="csymbol"><xsl:attribute name="cd">quant1</xsl:attribute>forall</xsl:element>
	  </xsl:when>
	</xsl:choose>
	<xsl:choose>
	  <xsl:when test="domainofapplication"><!-- doa is present -->      
	    <xsl:element name="apply">
	      <xsl:element name="csymbol"><xsl:attribute name="cd">logic1</xsl:attribute>
		<xsl:choose>
		  <xsl:when test="exists">and</xsl:when>
		  <xsl:when test="forall">implies</xsl:when>
		</xsl:choose>
	      </xsl:element>
	      <xsl:apply-templates select="./domainofapplication/*" mode="#current"/>
	      <xsl:apply-templates select="(bvar|domainofapplication)[position()=last()]/following-sibling::*" 
				   mode="#current"/>
	    </xsl:element>
	  </xsl:when>
	  <xsl:otherwise><!-- just dump out the expr -->
	    <xsl:apply-templates select="(bvar|domainofapplication)[position()=last()]/following-sibling::*" 
				 mode="#current"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- int with DOA, Rewrite:int, and also without bvar -->
<xsl:template match="apply[int][domainofapplication]" mode="pass5">
  <xsl:choose>
    <xsl:when test="bvar">
      <xsl:element name="apply">
	<xsl:element name="csymbol"><xsl:attribute name="cd">calculus1</xsl:attribute>defint</xsl:element>
	<xsl:apply-templates select="domainofapplication/node()" mode="#current"/>
	<xsl:element name="bind"><!-- lambda function to be integrated -->
	  <xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
	  <xsl:element name="bvar">
	    <xsl:apply-templates select="bvar/node()" mode="#current"/>
	  </xsl:element>
	  <xsl:apply-templates select="(bvar|domainofapplication)[position()=last()]/following-sibling::*" 
			       mode="#current"/><!-- expr in x -->	
	</xsl:element><!-- bind -->
      </xsl:element><!-- defint apply -->    
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="apply">
	<xsl:element name="csymbol"><xsl:attribute name="cd">calculus1</xsl:attribute>defint</xsl:element>
	<xsl:apply-templates select="domainofapplication/node()" mode="#current"/>
	<xsl:apply-templates select="(bvar|domainofapplication)[position()=last()]/following-sibling::*" 
			     mode="#current"/><!-- expr w/no bvar, e.g. 'f' -->	
      </xsl:element><!-- defint apply -->    
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- sum | product with DOA, with or without bvar -->
<xsl:template match="apply[sum|product][domainofapplication]" mode="pass5">
  <xsl:element name="apply">
    <xsl:choose>
      <xsl:when test="sum">
	<xsl:element name="csymbol"><xsl:attribute name="cd">arith1</xsl:attribute>sum</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="csymbol"><xsl:attribute name="cd">arith1</xsl:attribute>product</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="domainofapplication/node()" mode="#current"/>
    <xsl:choose>
      <xsl:when test="bvar">
	<xsl:element name="bind"><!-- lambda function -->
	  <xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
	  <xsl:element name="bvar">
	    <xsl:apply-templates select="bvar/node()" mode="#current"/>
	  </xsl:element>
	  <xsl:apply-templates select="(bvar|domainofapplication)[position()=last()]/following-sibling::*" 
			       mode="#current"/><!-- expr in x -->	
	</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:apply-templates select="(sum|product|domainofapplication)[position()=last()]/following-sibling::*" 
			     mode="#current"/><!-- expr, no bvar, e.g. 'f' -->	
      </xsl:otherwise>
    </xsl:choose>
  </xsl:element>    
</xsl:template>

<!--
6. Eliminate domainofapplication: At this stage, any apply has at most
   one domainofapplication child. As domainofapplication is not Strict 
   Content MathML, it is rewritten 

   a. into an application of a restricted function via the rule 
      Rewrite: restriction if the apply does not contain a bvar child.
   b. into an application of the predicate_on_list symbol via the
      rules Rewrite: n-ary relations and Rewrite: n-ary relations bvar 
      if used with a relation.
   c. into a construction with the apply_to_list symbol via the
      general rule Rewrite: n-ary domainofapplication for general
      n-ary operators.
   d. into a construction using the suchthat symbol from the set1
      content dictionary in an apply with bound variables via the
      Rewrite: apply bvar domainofapplication rule. 
-->

<xsl:template match="apply[domainofapplication]" mode="pass6">
  <xsl:choose>

    <!-- case 6a, restriction -->
    <xsl:when test="count(bvar)=0">
      <xsl:element name="apply">
	<xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>restriction</xsl:element>
	<xsl:apply-templates select="child::*[position()=1]" mode="#current"/><!-- head term -->
	<xsl:apply-templates select="domainofapplication/node()" mode="#current"/><!-- domain -->
      </xsl:element>    
      <xsl:apply-templates select="domainofapplication/following-sibling::*" mode="#current"/><!-- args -->
    </xsl:when>

    <!-- case 6b, predicate_on_list using Rewrite: n-ary relations bvar-->
    <xsl:when test="dsi:is-nary-reln(.) or dsi:is-nary-set-reln(.)">
      <!-- Should we special case when we did just create a strict list??? -->
      <xsl:element name="apply">
	<xsl:element name="csymbol"><xsl:attribute name="cd">fns2</xsl:attribute>predicate_on_list</xsl:element>
	<!-- head term, TBD: choose CD based on whether type=set|multiset -->
	<xsl:apply-templates select="node()[position()=1]" mode="#current"/>
	<xsl:element name="apply">
	  <xsl:element name="csymbol"><xsl:attribute name="cd">list1</xsl:attribute>map</xsl:element>
	  <xsl:element name="bind"><!-- lambda function -->
	    <xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
	    <xsl:element name="bvar">
	      <xsl:apply-templates select="bvar/node()" mode="#current"/>
	    </xsl:element>
	    <xsl:apply-templates select="(bvar|domainofapplication)[position()=last()]/following-sibling::*" 
				 mode="#current"/><!-- expr in x -->	
	  </xsl:element>
	  <xsl:apply-templates select="domainofapplication/node()" mode="#current"/><!-- domain -->
	</xsl:element>    
      </xsl:element>    
    </xsl:when>

    <!-- case 6c, apply_to_list, using Rewrite: n-ary set -->
    <xsl:when test="dsi:is-nary-set(.)">
      <xsl:element name="apply">
      <!-- Should we special case when we did just create a strict list??? -->
	<xsl:element name="csymbol"><xsl:attribute name="cd">fns2</xsl:attribute>apply_to_list</xsl:element>
	<!-- head term, TBD: choose CD based on whether type=set|multiset -->
	<xsl:apply-templates select="node()[position()=1]" mode="#current"/>
	<xsl:element name="apply">
	  <xsl:element name="csymbol"><xsl:attribute name="cd">list1</xsl:attribute>map</xsl:element>
	  <xsl:element name="bind"><!-- lambda function -->
	    <xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
	    <xsl:element name="bvar">
	      <xsl:apply-templates select="bvar/node()" mode="#current"/>
	    </xsl:element>
	    <xsl:apply-templates select="(bvar|domainofapplication)[position()=last()]/following-sibling::*" 
				 mode="#current"/><!-- expr in x -->	
	  </xsl:element>
	  <xsl:apply-templates select="domainofapplication/node()" mode="#current"/><!-- domain -->
	</xsl:element>    
      </xsl:element>    
    </xsl:when>

    <!-- case 6d, such that constructs using Rewrite: apply bvar doa -->
    <xsl:otherwise>
      <xsl:element name="apply">
	<xsl:apply-templates select="node()[position()=1]" mode="#current"/> <!-- head term -->
	<xsl:apply-templates select="domainofapplication/node()" mode="#current"/><!-- domain -->
	<xsl:variable name="bvars" select="bvar"/>
	<xsl:for-each select="(bvar|domainofapplication)[position()=last()]/following-sibling::*">
	  <xsl:element name="bind"><!-- lambda function -->
	    <xsl:element name="csymbol"><xsl:attribute name="cd">fns1</xsl:attribute>lambda</xsl:element>
	    <xsl:value-of select="$bvars"/>
	    <xsl:apply-templates select="." mode="#current"/><!-- expr_i -->
	  </xsl:element>
	</xsl:for-each>
      </xsl:element>    
    </xsl:otherwise>

  </xsl:choose>
</xsl:template>

<!-- Rewrite: n-ary relations - This doesn't actually have to do with eliminating 
     doa's but since we are rewriting nary set relations with doas, this is a 
     reasonable place to deal with this case as well.
     match: apply nary-reln ch1 ch2 ch3 ...
-->
<xsl:template match="apply[count(domainofapplication)=0]
		     [dsi:is-nary-reln(*[1])='true']
		     [count(node())>3]" mode="pass6">
  <xsl:element name="apply">
    <xsl:element name="csymbol"><xsl:attribute name="cd">fns2</xsl:attribute>predicate_on_list</xsl:element>
    <!-- head term, TBD: choose CD based on whether type=set|multiset -->
    <xsl:apply-templates select="node()[position()=1]" mode="#current"/>
    <xsl:element name="apply">
      <xsl:element name="csymbol"><xsl:attribute name="cd">list1</xsl:attribute>list</xsl:element>
      <xsl:apply-templates select="node()[position()>1]" mode="#current"/>
    </xsl:element>
  </xsl:element>
</xsl:template>


<!-- ============================================================================
7. a Rewrite non-strict cn's
   b Rewrite content tokens ci, cn, csymbol containing mmlp using 
     Rewrite: cn presentation mml, Rewrite: ci presentation mml, and 
     analogously for csymbol
 -->

<!-- Rewrite: cn sep -->
<xsl:template match="cn[sep]" mode="pass7">
  <xsl:element name="apply">
    <xsl:element name="csymbol">
      <xsl:choose>
	<xsl:when test="@type='rational'"><xsl:attribute name="cd">nums1</xsl:attribute>rational</xsl:when>
      	<xsl:when test="@type='e-notation'"><xsl:attribute name="cd">nums1</xsl:attribute>bigfloat</xsl:when>
	<xsl:when test="@type='complex-cartesian'"><xsl:attribute name="cd">complex1</xsl:attribute>complex_cartesian</xsl:when>
	<xsl:when test="@type='complex-polar'"><xsl:attribute name="cd">complex1</xsl:attribute>complex_polar</xsl:when>
      </xsl:choose>
    </xsl:element>
    <xsl:element name="cn">
      <xsl:if test="@base"><xsl:attribute name="base"><xsl:value-of select="@base"/></xsl:attribute></xsl:if>
      <xsl:value-of select="normalize-space(sep/preceding-sibling::node())"/>
    </xsl:element>
    <xsl:element name="cn">
      <xsl:if test="@base"><xsl:attribute name="base"><xsl:value-of select="@base"/></xsl:attribute></xsl:if>
      <xsl:value-of select="normalize-space(sep/following-sibling::node())"/>
      <!--<xsl:apply-templates select="sep/following-sibling::node()" mode="#current"/>-->
    </xsl:element>
  </xsl:element>
</xsl:template>

<!-- Rewrite: cn based_integer -->
<xsl:template match="cn[@base][count(sep)=0]" mode="pass7" priority="10">
  <xsl:element name="apply">
    <xsl:element name="csymbol"><xsl:attribute name="cd">nums1</xsl:attribute>
      <xsl:choose>
	<xsl:when test="@type='integer' or (count(@type)=0 and dsi:is-integer(.))">based_integer</xsl:when>
	<xsl:otherwise>based_float</xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    <xsl:element name="cn">
      <xsl:attribute name="type">integer</xsl:attribute>
      <xsl:value-of select="@base"/></xsl:element>
    <xsl:element name="cs"><xsl:value-of select="normalize-space(.)"/></xsl:element>
  </xsl:element>
</xsl:template>

<!-- Rewrite: cn constant -->
<xsl:template match="cn" mode="pass7"><!-- should have @type='constant' -->
  <xsl:variable name="cnval"><xsl:value-of select="normalize-space(.)"/></xsl:variable>
  <xsl:choose>
    <xsl:when test="$cnval='&#x03C0;' or $cnval='&#x2147;' or 
		    $cnval='&#x2148;' or $cnval='&#x03B3;' or $cnval='&#x221E;'">
      <xsl:element name="csymbol"><xsl:attribute name="cd">nums1</xsl:attribute>
	<xsl:choose>
	  <xsl:when test="$cnval='&#x03C0;'">pi</xsl:when>
	  <xsl:when test="$cnval='&#x2147;'">e</xsl:when>
	  <xsl:when test="$cnval='&#x2148;'">i</xsl:when>
	  <xsl:when test="$cnval='&#x03B3;'">gamma</xsl:when>
	  <xsl:when test="$cnval='&#x221E;'">infinity</xsl:when>
	</xsl:choose>
      </xsl:element>
    </xsl:when>
    <xsl:when test="not(matches($cnval,'^[0-9.,-]*$'))">
      <xsl:element name="ci"><xsl:copy-of select="@*"/><xsl:value-of select="normalize-space(.)"/></xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy><xsl:copy-of select="@*"/><xsl:value-of select="$cnval"/></xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- ci or csymbol containing mmlp -->
<xsl:template match="ci|csymbol" mode="pass7">
  <xsl:choose>
    <xsl:when test="dsi:contains-mmlp(.)='true'">
      <xsl:element name="semantics">
	<xsl:choose>
	  <xsl:when test="name()='ci'">
	    <xsl:element name="ci"><xsl:value-of select="dsi:name-from-mmlp(.)"/></xsl:element>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:element name="csymbol"><xsl:value-of select="dsi:name-from-mmlp(.)"/></xsl:element>
	  </xsl:otherwise>
	</xsl:choose>
	<xsl:element name="annotation-xml">
	  <xsl:attribute name="encoding">MathML-Presentation</xsl:attribute>
	  <xsl:apply-templates select="./node()" mode="#current"/>      
	</xsl:element>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
	<xsl:copy-of select="@*"/>
	<xsl:value-of select="normalize-space(.)"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- cn containing mmlp -->
<xsl:template match="cn[dsi:contains-mmlp(.)='true']" mode="pass7">
  <xsl:element name="semantics">
    <xsl:element name="ci"><xsl:value-of select="dsi:name-from-mmlp(.)"/></xsl:element>
    <xsl:element name="annotation-xml"><xsl:attribute name="encoding">MathML-Presentation</xsl:attribute>
      <xsl:apply-templates select="./node()" mode="#current"/>
    </xsl:element>
  </xsl:element>
</xsl:template>


<!-- ============================================================================
8. Rewrite empty operator elements as csymbols, via Rewrite: element
 -->

<!-- unary and binary minus -->
<xsl:template match="minus" mode="pass8" priority="1">
  <xsl:element name="csymbol">
    <xsl:choose>
      <xsl:when test="count(following-sibling::*) = 1">
	<xsl:attribute name="cd"><xsl:value-of select="$symbols//element/op[string()='unary_minus']/../cd"/>	</xsl:attribute>
	<xsl:value-of select="$symbols//element/op[string()='unary_minus']/../name"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:attribute name="cd"><xsl:value-of select="$symbols//element/op[string()='minus']/../cd"/></xsl:attribute>
	<xsl:value-of select="$symbols//element/op[string()='minus']/../name"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:element>
</xsl:template>


<!-- rewrite selector args in other order -->
<xsl:template match="apply[selector]" mode="pass8" priority="1">
  <xsl:element name="apply">
    <xsl:choose>
      <xsl:when test="matrix or count(./*) > 3">
	<xsl:element name="csymbol"><xsl:attribute name="cd">linalg1</xsl:attribute>matrix_selector</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:element name="csymbol"><xsl:attribute name="cd">linagl1</xsl:attribute>vector_selector</xsl:element>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="*[position()>2]"/>
    <xsl:apply-templates select="*[2]"/>
  </xsl:element>
</xsl:template>

<!-- TBD special cases
     set/multiset handling for: emptyset, setdiff, card, in, notin, notsubset, notprsubset
     data/dist handling for: moment, mean, sdev, variance, 
  -->


<!-- generic empty operator elements -->
<xsl:template match="*[count( child::node() )=0]" mode="pass8">
  <xsl:variable name="opname"><xsl:value-of select="name()"/></xsl:variable>
  <xsl:choose>
    <xsl:when test="count($symbols//element/op[string()=$opname])>0">
       <xsl:element name="csymbol">
	 <xsl:attribute name="cd"><xsl:value-of select="$symbols//element/op[string()=$opname]/../cd"/></xsl:attribute>
	 <xsl:value-of select="$symbols//element/op[string()=$opname]/../name"/>
       </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy>
	<xsl:copy-of select="@*"/>
	<xsl:apply-templates mode="#current"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<!-- ============================================================================
9. a Rewrite type attributes to annotations using Rewrite: ci type annotation
   b Rewrite definitionURL and encoding attributes on csymbols to (cd, name) 
   c Rewrite non-strict and foreign attributes. By this point, all idiomatic 
     non-strict MathML attributes should have been rewritten, leaving only 
     the generic MathML attributes (other, definitionURL, style, class)
     and completely foreign namespace attrbiutes.
 -->

<xsl:template match="ci[count(@type)>0]|cn[count(@type)>0]" mode="pass9">
  <xsl:element name="semantics">
    <xsl:variable name="eltname"><xsl:value-of select="name(.)"/></xsl:variable>
    <xsl:element name="{$eltname}"><xsl:value-of select="normalize-space(.)"/></xsl:element>
    <xsl:element name="annotation-xml">
      <xsl:attribute name="cd">mathmltypes</xsl:attribute>
      <xsl:attribute name="name">type</xsl:attribute>
      <xsl:attribute name="encoding">MathML-Content</xsl:attribute>
      <xsl:element name="ci"><xsl:value-of select="@type"/></xsl:element>
    </xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="csymbol[@definitionURL|@encoding]" mode="pass9" priority="10">
  <!-- TBD, convert @encoding, work out precedence between cd, defnURL, encoding -->
  <xsl:choose>
    <!-- seems to indicate a cd and name --> 
    <xsl:when test="matches(@definitionURL,'http://.*/([^/]*)#(.*)' )">
      <xsl:variable name="cd">
	<xsl:value-of select='replace(@definitionURL, "http://.*/([^/]*).htm.#.*", "$1")'/>
      </xsl:variable>
      <xsl:variable name="name">
	<xsl:value-of select='replace(@definitionURL,"http://.*/([^/]*)#(.*)", "$2")'/>
      </xsl:variable>
      <xsl:element name="csymbol">
	<xsl:attribute name="cd"><xsl:value-of select="$cd"/></xsl:attribute>
	<xsl:value-of select="$name"/>
      </xsl:element>
    </xsl:when>
    <!-- some other kinds of definitionURL --> 
    <xsl:otherwise>
      <xsl:copy>
	<xsl:copy-of select="@*"/>
	<xsl:apply-templates mode="#current"/>
      </xsl:copy>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*[@other|@definitionURL|@style|@class] | *[@*[contains(name(),':')]]" mode="pass9b">
  <xsl:element name="semantics">
    <!-- reconstruct the token w/o the non-strict MML attrs -->
    <xsl:copy>
      <xsl:for-each select="@*">
	<xsl:choose>
	  <xsl:when test="name()='other' or name()='definitionURL' or name()='encoding' or
                          name()='class' or name()='style' or contains(name(),':')" >
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:copy-of select="normalize-space(string(.))"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:for-each>
      <xsl:choose>
	<xsl:when test="string-length(.)>0">
	  <xsl:value-of select="normalize-space(.)"/><!-- ci's content -->
	</xsl:when>
	<xsl:otherwise>
	  <!-- <xsl:value-of select="name(.)"/>empty op element-->
	</xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
    <!-- add non-strict MML attrs as annotations-->
    <xsl:for-each select="@*[name()='other' or name()='definitionURL' or name()='class' or name()='style']">
      <xsl:element name="annotation">
	<xsl:attribute name="cd">mathmlattr</xsl:attribute>
	<xsl:attribute name="name"><xsl:value-of select="name(.)"/></xsl:attribute>
	<xsl:attribute name="encoding">text/plain</xsl:attribute>
	<xsl:apply-templates select="." mode="#current"/>
      </xsl:element>
    </xsl:for-each>
    <!-- add foreign namespace attrs as annotations-->
    <xsl:for-each select="@*[contains(name(),':')]">
      <xsl:element name="annotation">
	<xsl:attribute name="cd">mathmlattr</xsl:attribute>
	<xsl:attribute name="name">foreign</xsl:attribute>
	<xsl:attribute name="encoding">MathML-Content</xsl:attribute>
	<xsl:element name="apply">
	  <xsl:element name="csymbol"><xsl:attribute name="cd">mathmlattr</xsl:attribute>foreign_attribute</xsl:element>
	  <xsl:element name="cs"><xsl:value-of select="namespace-uri(.)"/></xsl:element>
	  <xsl:element name="cs"><xsl:value-of select="substring-before(name(),':')"/></xsl:element>
	  <xsl:element name="cs"><xsl:value-of select="substring-after(name(),':')"/></xsl:element>
	  <xsl:element name="cs"><xsl:apply-templates select="." mode="#current"/></xsl:element>
	</xsl:element>
      </xsl:element>
    </xsl:for-each>
  </xsl:element>
</xsl:template>



<!-- ============================================================================
Utility functions
 -->

<xsl:function name="dsi:is-nary-reln" as="xs:string">
  <xsl:param name="elt"/>
  <xsl:choose>
    <xsl:when test="$elt/name()='eq' or $elt/name()='gt' or $elt/name()='geq' 
		    or $elt/name()='lt' or $elt/name()='leq'">true</xsl:when>
    <xsl:otherwise>false</xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="dsi:is-nary-set-reln" as="xs:string">
  <xsl:param name="elt"/>
  <xsl:choose>
    <xsl:when test="$elt/name()='prsubset' or $elt/name()='subset'">true</xsl:when>
    <xsl:otherwise>false</xsl:otherwise>
  </xsl:choose>
</xsl:function>


<xsl:function name="dsi:is-nary-set" as="xs:string">
  <xsl:param name="elt"/>
  <xsl:choose>
    <xsl:when test="$elt/name()='union' or $elt/name()='intersection' or $elt/name()='cartesianproduct'">true</xsl:when>
    <xsl:otherwise>false</xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="dsi:is-integer" as="xs:string">
  <xsl:param name="elt"/>
  <xsl:variable name="num"><xsl:value-of select="$elt"/></xsl:variable>
  <xsl:choose>
    <!-- true iff the content of the element just consists of the characters [a-zA-Z0-9] and white space -->
    <xsl:when test="matches($num, '([a-z]|[A-Z]|[0-9])*' )">true</xsl:when>
    <xsl:otherwise>false</xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="dsi:contains-mmlp" as="xs:string">
  <xsl:param name="elt"/>
  <!-- this test could be improved, but it is hard to imagine a meaningful 
       presentation without tokens, so it's probably good enough in practice -->
  <xsl:choose>
    <xsl:when test="$elt//(mi|mn|mo|ms|mglyph|mspace)">true</xsl:when>
    <xsl:otherwise>false</xsl:otherwise>
  </xsl:choose>
</xsl:function>

<xsl:function name="dsi:name-from-mmlp" as="xs:string">
  <xsl:param name="elt"/>
  <!-- kind of cumbersome, but pretty solid -->
  <xsl:variable name="ret"><xsl:value-of select="translate(normalize-space($elt),' ','')"/><xsl:text>-</xsl:text><xsl:for-each select="$elt//node()"><xsl:value-of select="name()"/></xsl:for-each>
  </xsl:variable>
  <xsl:value-of select="$ret"/>
</xsl:function>

<xsl:function name="dsi:deep-equal" as="xs:boolean">
 <xsl:param name="new"/>
 <xsl:param name="old"/>
 <xsl:sequence use-when="function-available('saxon:deep-equal')"
	       select="saxon:deep-equal($new,$old,(),'w?')"/>
 <xsl:sequence use-when="not(function-available('saxon:deep-equal'))"
	       select="deep-equal($new,$old)"/>
</xsl:function>


<!-- ============================================================================
Data structure containing operator elements and their OM symbols
-->

<xsl:variable name="symbols">
  <elements>
    <element><op>inverse</op>         <cd>fns1</cd>            <name>inverse</name></element>
    <element><op>compose</op>         <cd>fns1</cd>            <name>left_compose</name></element>
    <element><op>ident</op>           <cd>fns1</cd>            <name>identity</name></element>
    <element><op>domain</op>          <cd>fns1</cd>            <name>domain</name></element>
    <element><op>codomain</op>        <cd>fns1</cd>            <name>range</name></element>
    <element><op>image</op>           <cd>fns1</cd>            <name>image</name></element>
    <element><op>quotient</op>        <cd>integer1</cd>        <name>quotient</name></element>
    <element><op>factorial</op>       <cd>integer1</cd>        <name>factorial</name></element>
    <element><op>divide</op>          <cd>arith1</cd>          <name>divide</name></element>
    <element><op>max</op>             <cd>minmax1</cd>         <name>max</name></element>
    <element><op>min</op>             <cd>minmax1</cd>         <name>min</name></element>
    <element><op>plus</op>            <cd>arith1</cd>          <name>plus</name></element>
    <element><op>power</op>           <cd>arith1</cd>          <name>power</name></element>
    <element><op>rem</op>             <cd>integer1</cd>        <name>remainder</name></element>
    <element><op>times</op>           <cd>arith1</cd>          <name>times</name></element>
    <element><op>root</op>            <cd>arith1</cd>          <name>root</name></element>
    <element><op>gcd</op>             <cd>arith1</cd>          <name>gcd</name></element>
    <element><op>and</op>             <cd>logic1</cd>          <name>and</name></element>
    <element><op>or</op>              <cd>logic1</cd>          <name>or</name></element>
    <element><op>xor</op>             <cd>logic1</cd>          <name>xor</name></element>
    <element><op>not</op>             <cd>logic1</cd>          <name>not</name></element>
    <element><op>implies</op>         <cd>logic1</cd>          <name>implies</name></element>
    <element><op>abs</op>             <cd>arith1</cd>          <name>abs</name></element>
    <element><op>conjugate</op>       <cd>complex1</cd>        <name>conjugate</name></element>
    <element><op>arg</op>             <cd>complex1</cd>        <name>argument</name></element>
    <element><op>real</op>            <cd>complex1</cd>        <name>real</name></element>
    <element><op>imaginary</op>       <cd>complex1</cd>        <name>imaginary</name></element>
    <element><op>lcm</op>             <cd>arith1</cd>          <name>lcm</name></element>
    <element><op>floor</op>           <cd>rounding1</cd>       <name>floor</name></element>
    <element><op>ceiling</op>         <cd>rounding1</cd>       <name>ceiling</name></element>
    <element><op>eq</op>              <cd>relation1</cd>       <name>eq</name></element>
    <element><op>neq</op>             <cd>relation1</cd>       <name>neq</name></element>
    <element><op>gt</op>              <cd>relation1</cd>       <name>gt</name></element>
    <element><op>lt</op>              <cd>relation1</cd>       <name>lt</name></element>
    <element><op>geq</op>             <cd>relation1</cd>       <name>geq</name></element>
    <element><op>leq</op>             <cd>relation1</cd>       <name>leq</name></element>
    <element><op>equivalent</op>      <cd>logic1</cd>          <name>equivalent</name></element>
    <element><op>approx</op>          <cd>relation1</cd>       <name>approx</name></element>
    <element><op>factorof</op>        <cd>integer1</cd>        <name>factorof</name></element>
    <element><op>diff</op>            <cd>calculus1</cd>       <name>diff</name></element>
    <element><op>divergence</op>      <cd>veccalc1</cd>        <name>divergence</name></element>
    <element><op>grad</op>            <cd>veccalc1</cd>        <name>grad</name></element>
    <element><op>curl</op>            <cd>veccalc1</cd>        <name>curl</name></element>
    <element><op>laplacian</op>       <cd>veccalc1</cd>        <name>Laplacian</name></element>
    <element><op>set</op>             <cd>set1</cd>            <name>set</name></element>
    <element><op>emptyset</op>        <cd>set1</cd>            <name>emptyset</name></element>
    <element><op>union</op>           <cd>set1</cd>            <name>union</name></element>
    <element><op>intersect</op>       <cd>set1</cd>            <name>intersect</name></element>
    <element><op>in</op>              <cd>set1</cd>            <name>in</name></element>
    <element><op>notin</op>           <cd>set1</cd>            <name>notin</name></element>
    <element><op>subset</op>          <cd>set1</cd>            <name>subset</name></element>
    <element><op>prsubset</op>        <cd>set1</cd>            <name>prsubset</name></element>
    <element><op>notsubset</op>       <cd>set1</cd>            <name>notsubset</name></element>
    <element><op>notprsubset</op>     <cd>set1</cd>            <name>notprsubset</name></element>
    <element><op>cartesianproduct</op><cd>set1</cd>            <name>cartesian_product</name></element>
    <element><op>sum</op>             <cd>arith1</cd>          <name>sum</name></element>
    <element><op>product</op>         <cd>arith1</cd>          <name>product</name></element>
    <element><op>sin</op>             <cd>transc1</cd>         <name>sin</name></element>
    <element><op>cos</op>             <cd>transc1</cd>         <name>cos</name></element>
    <element><op>tan</op>             <cd>transc1</cd>         <name>tan</name></element>
    <element><op>cot</op>             <cd>transc1</cd>         <name>cot</name></element>
    <element><op>sec</op>             <cd>transc1</cd>         <name>sec</name></element>
    <element><op>csc</op>             <cd>transc1</cd>         <name>csc</name></element>
    <element><op>sinh</op>            <cd>transc1</cd>         <name>sinh</name></element>
    <element><op>cosh</op>            <cd>transc1</cd>         <name>cosh</name></element>
    <element><op>tanh</op>            <cd>transc1</cd>         <name>tanh</name></element>
    <element><op>coth</op>            <cd>transc1</cd>         <name>coth</name></element>
    <element><op>sech</op>            <cd>transc1</cd>         <name>sech</name></element>
    <element><op>csch</op>            <cd>transc1</cd>         <name>csch</name></element>
    <element><op>arcsin</op>          <cd>transc1</cd>         <name>arcsin</name></element>
    <element><op>arccos</op>          <cd>transc1</cd>         <name>arccos</name></element>
    <element><op>arctan</op>          <cd>transc1</cd>         <name>arctan</name></element>
    <element><op>arccot</op>          <cd>transc1</cd>         <name>arccot</name></element>
    <element><op>arcsec</op>          <cd>transc1</cd>         <name>arcsec</name></element>
    <element><op>arccsc</op>          <cd>transc1</cd>         <name>arccsc</name></element>
    <element><op>arcsinh</op>         <cd>transc1</cd>         <name>arcsinh</name></element>
    <element><op>arccosh</op>         <cd>transc1</cd>         <name>arccosh</name></element>
    <element><op>arctanh</op>         <cd>transc1</cd>         <name>arctanh</name></element>
    <element><op>arccoth</op>         <cd>transc1</cd>         <name>arccoth</name></element>
    <element><op>arcsech</op>         <cd>transc1</cd>         <name>arcsech</name></element>
    <element><op>arccsch</op>         <cd>transc1</cd>         <name>arccsch</name></element>
    <element><op>exp</op>             <cd>transc1</cd>         <name>exp</name></element>
    <element><op>ln</op>              <cd>transc1</cd>         <name>ln</name></element>
    <element><op>log</op>             <cd>transc1</cd>         <name>log</name></element>
    <element><op>median</op>          <cd>s_data1</cd>         <name>median</name></element>
    <element><op>mode</op>            <cd>s_data1</cd>         <name>mode</name></element>
    <element><op>mean</op>            <cd>s_data1</cd>         <name>mean</name></element>
    <element><op>sdev</op>            <cd>s_data1</cd>         <name>sdev</name></element>
    <element><op>variance</op>        <cd>s_data1</cd>         <name>variance</name></element>
    <element><op>setdiff</op>         <cd>set1</cd>            <name>setdiff</name></element>
    <element><op>card</op>            <cd>set1</cd>            <name>size</name></element>
    <element><op>determinant</op>     <cd>linalg1</cd>         <name>determinant</name></element>
    <element><op>transpose</op>       <cd>linalg1</cd>         <name>transpose</name></element>
    <element><op>vectorproduct</op>   <cd>linalg1</cd>         <name>vectorproduct</name></element>
    <element><op>scalarproduct</op>   <cd>linalg1</cd>         <name>scalarproduct</name></element>
    <element><op>outerproduct</op>    <cd>linalg1</cd>         <name>outerproduct</name></element>
    <element><op>matrix_selector</op> <cd>linalg1</cd>         <name>matrix_selector</name></element>
    <element><op>selector</op>        <cd>linalg1</cd>         <name>vector_selector</name></element>
    <element><op>integers</op>        <cd>setname1</cd>        <name>Z</name></element>
    <element><op>reals</op>           <cd>setname1</cd>        <name>R</name></element>
    <element><op>rationals</op>       <cd>setname1</cd>        <name>Q</name></element>
    <element><op>naturalnumbers</op>  <cd>setname1</cd>        <name>N</name></element>
    <element><op>complexes</op>       <cd>setname1</cd>        <name>C</name></element>
    <element><op>primes</op>          <cd>setname1</cd>        <name>P</name></element>
    <element><op>true</op>            <cd>logic1</cd>          <name>true</name></element>
    <element><op>false</op>           <cd>logic1</cd>          <name>false</name></element>
    <element><op>exponentiale</op>    <cd>nums1</cd>           <name>e</name></element>
    <element><op>imaginaryi</op>      <cd>nums1</cd>           <name>i</name></element>
    <element><op>notanumber</op>      <cd>nums1</cd>           <name>NaN</name></element>
    <element><op>pi</op>              <cd>nums1</cd>           <name>pi</name></element>
    <element><op>eulergamma</op>      <cd>nums1</cd>           <name>gamma</name></element>
    <element><op>infinity</op>        <cd>nums1</cd>           <name>infinity</name></element>
    <!-- <element><op></op>           <cd></cd><name></name></element> -->
    
    <element><op>minus</op>           <cd>arith1</cd><name>minus</name></element>
    <element><op>unary_minus</op>           <cd>arith1</cd><name>unary_minus</name></element>

  </elements>
</xsl:variable>

<!-- ============================================================================
default node processing 
-->

<xsl:template match="*" mode="#all">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates mode="#current"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
