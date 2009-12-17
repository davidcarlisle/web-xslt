<xsl:stylesheet version="1.0" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:exslt="http://exslt.org/common"
		xmlns:msxsl="urn:schemas-microsoft-com:xslt"
		exclude-result-prefixes="exslt msxsl">
  

<msxsl:script language="JScript" implements-prefix="exslt">
 this['node-set'] =  function (x) {
  return x;
  }
</msxsl:script>


<xsl:variable name="x">
  <y/>
</xsl:variable>

<xsl:template match="x">
  <html>
    <head><title>test exslt node set</title></head>
    <body>
      <xsl:apply-templates select="exslt:node-set($x)/*"/>
    </body>
  </html>
</xsl:template>

<xsl:template match="y">
  <p>node set!</p>
</xsl:template>

</xsl:stylesheet>