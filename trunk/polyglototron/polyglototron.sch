<?xml version="1.0" encoding="UTF-8"?>

<!--
     polyglototron
-->

<!-- Copyright 2010 David Carlisle.
     This stylesheet may be used under the conditions of the W3C Software licence or the MIT licence.
 -->

<!--


 Not checked 
=============

6.3.3 Attribute Values

Polyglot markup requires the case used for characters in the values of
the following attributes to be consistent between markup, DOM APIs,
and CSS when these attributes are used on HTML elements.

7. Attributes
Within an attribute's value, polyglot markup represents tabs, line
feeds, and carriage returns as numeric character references rather
than by using literal characters. For example, within an attribute's
value, polyglot markup uses &#x9; for a tab rather than the literal
character '\t'. This is because of attribute-value normalization in
XML [XML10].

-->


<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
	    queryBinding="xslt2" >
 <sch:title>polyglot tests</sch:title>
 
 <sch:ns prefix="h" uri="http://www.w3.org/1999/xhtml"/>
 <sch:ns prefix="m" uri="http://www.w3.org/1998/Math/MathML"/>
 <sch:ns prefix="s" uri="http://www.w3.org/2000/svg"/>

 
<sch:let name="svgmc" value="('altGlyph','altGlyphDef','altGlyphItem','animateColor','animateMotion','animateTransform','clipPath','feBlend','feColorMatrix','feComponentTransfer','feComposite','feConvolveMatrix','feDiffuseLighting','feDisplacementMap','feDistantLight','feFlood','feFuncA','feFuncB','feFuncG','feFuncR','feGaussianBlur','feImage','feMerge','feMergeNode','feMorphology','feOffset','fePointLight','feSpecularLighting','feSpotLight','feTile','feTurbulence','foreignObject','glyphRef','linearGradient','radialGradient','textPath')"/>

<sch:let name="svglc" value="for $i in $svgmc return lower-case($i)"/>

<sch:let name="svgatmc" value="('attributeName','attributeType','baseFrequency','baseProfile','calcMode','clipPathUnits','contentScriptType','contentStyleType','diffuseConstant','edgeMode','externalResourcesRequired','filterRes','filterUnits','glyphRef','gradientTransform','gradientUnits','kernelMatrix','kernelUnitLength','keyPoints','keySplines','keyTimes','lengthAdjust','limitingConeAngle','markerHeight','markerUnits','markerWidth','maskContentUnits','maskUnits','numOctaves','pathLength','patternContentUnits','patternTransform','patternUnits','pointsAtX','pointsAtY','pointsAtZ','preserveAlpha','preserveAspectRatio','primitiveUnits','refX','refY','repeatCount','repeatDur','requiredExtensions','requiredFeatures','specularConstant','specularExponent','spreadMethod','startOffset','stdDeviation','stitchTiles','surfaceScale','systemLanguage','tableValues','targetX','targetY','textLength','viewBox','viewTarget','xChannelSelector','yChannelSelector','zoomAndPan')"/>

<sch:let name="svgatlc" value="for $i in $svgatmc return lower-case($i)"/>

<sch:let name="mmlatmc" value="'definitionURL'"/>
<sch:let name="mmlatlc" value="'definitionurl'"/>


 <sch:pattern>
  <sch:rule context="h:meta[@charset]">
   <sch:assert test="lower-case(@charset)='utf-8'"
	       >If meta/@charset is used, it must specify utf-8.</sch:assert>
  </sch:rule>
 </sch:pattern>


 <sch:pattern>
  <sch:rule context="/">
   <sch:assert test="h:html"
	       >Document element should be html in the xhtml namespace</sch:assert>
  </sch:rule>
 </sch:pattern>

 <sch:pattern>
  <sch:rule context="h:html">
   <sch:assert test="*[1][self::h:head]"
	       >document should have an explicit head</sch:assert>
   <sch:assert test="*[2][self::h:body]"
	       >document should have an explicit body</sch:assert>
  </sch:rule>
 </sch:pattern>

 <sch:pattern>
  <sch:rule context="*[lower-case(name())=$svglc]">
   <sch:assert test="name()=$svgmc"
	       >SVG Mixed case element names should be used (<sch:value-of select="name()"/>)</sch:assert>
  </sch:rule>
  <sch:rule context="*">
   <sch:assert test="matches(name(),'^[a-z1-6]+$')"
	       >elements should use lower case names (<sch:value-of select="name()"/>)
   </sch:assert>
  </sch:rule>

 </sch:pattern>
 <sch:pattern>
  <sch:rule context="*:math|math">
   <sch:assert test="namespace-uri()='http://www.w3.org/1998/Math/MathML'"
	       >math should be in the mathml namespace</sch:assert>
  </sch:rule>

 </sch:pattern>

 <sch:pattern>
  <sch:rule context="*:svg|svg">
   <sch:assert test="namespace-uri()='http://www.w3.org/2000/svg'"
	       >svg should be in the svg namespace</sch:assert>
  </sch:rule>

 </sch:pattern>

 <sch:pattern>
  <sch:rule context="*:html|html">
   <sch:assert test="namespace-uri()='http://www.w3.org/1999/xhtml'"
	       >html should be in the xhtml namespace</sch:assert>
  </sch:rule>

  <sch:rule context="m:mi|m:mn|m:mo|m:mtext|m:annotation-xml[@encoding=('text/hml','application/xhtml+xml')]">
   <sch:assert test="*/namespace-uri()='http://www.w3.org/1999/xhtml'"
	       >Children of MathML tokens should be in the xhtml namespace</sch:assert>
  </sch:rule>
 </sch:pattern>

<sch:pattern>
<sch:rule context="s:*">
  <sch:assert test="every $a in @*/name()[lower-case(.)=$svgatlc] satisfies $a=$svgatmc"
	      >SVG attribute names should use the specified mixed case form (<sch:value-of select="@*/name()[lower-case(.)=$svgatlc][not(.=$svgatmc)]"/>)</sch:assert>
</sch:rule>
</sch:pattern>
<sch:pattern>

<sch:rule context="m:*">
  <sch:assert test="every $a in @*/name()[lower-case(.)=$svgatlc] satisfies $a=$mmlatmc"
	      >MathML attribute names should use the specified mixed case form (<sch:value-of select="@*/name()[lower-case(.)=$mmlatlc][not(.=$mmlatmc)]"/>)</sch:assert>
</sch:rule>
</sch:pattern>

 <sch:pattern>
  <sch:rule context="h:tr">
   <sch:assert test="parent::h:tbody or parent::h:thead or parent::h:foot"
	       >Table rows should be in an explict thead, tbody or tfoot</sch:assert>
  </sch:rule>
 </sch:pattern>

 <sch:pattern>
  <sch:rule context="h:col">
   <sch:assert test="parent::h:colgroup"
	       >col elements should be in an explict colgroup</sch:assert>
  </sch:rule>
 </sch:pattern>


 <sch:pattern>
  <sch:rule context="h:noscript">
   <sch:assert test="false()"
	       >noscript elements should not be used.</sch:assert>
  </sch:rule>
 </sch:pattern>

 <sch:pattern>
  <sch:rule context="h:textarea|h:pre">
   <sch:assert test="not(matches(.,'^[&#10;&#13;]'))"
	       >textarea and pre should not start with newline</sch:assert>
  </sch:rule>
 </sch:pattern>


 <sch:pattern>
  <sch:rule context="*[@lang|@xml:lang]">
   <sch:assert test="@xml:lang and @lang and @xml:lang=@lang"
	       >xml:lang and lang should both be used</sch:assert>
  </sch:rule>
 </sch:pattern>


 <sch:pattern>
  <sch:rule context="h:script|h:style">
   <sch:assert test="not(matches(.,'[&lt;&amp;]'))"
	       >script and style should not use &amp; or &lt;</sch:assert>
  </sch:rule>
 </sch:pattern>


 <sch:pattern>
  <sch:rule context="/|*">
   <sch:assert test="not(comment()[matches(.,'^->?')])"
	       >comments should not start with - or -&gt;</sch:assert>
  </sch:rule>
 </sch:pattern>



</sch:schema>
