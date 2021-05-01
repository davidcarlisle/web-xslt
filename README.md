web-xslt
========

A collection of XSLT stylesheets designed for processing MathML (mainly) but also HTML and perhaps OpenMath. Mostly they will be documented on the blog, tagged with [googlecode](http://dpcarlisle.blogspot.com/search/label/googlecode).

Currently this collection comprises of the following

*   **[c2s](http://code.google.com/p/web-xslt/source/browse/trunk/c2s)**, documentation tagged [c2s](http://dpcarlisle.blogspot.com/search/label/c2s)  
    XSLT (by Robert Miner mostly) to convert Content MathML into the Strict Content MathML form, using the algorithm detailed in Chapter 4 of the [MathML3](http://www.w3.org/TR/MathML3/) spec.  
*   **[ctop](http://code.google.com/p/web-xslt/source/browse/trunk/ctop)**, documentation tagged [ctop](http://dpcarlisle.blogspot.com/search/label/ctop)  
    Stylesheet converting Content MathML to Presentation MathML. This is XSLT 1.0, to allow use within a browser. This code may also be used under the [Apache 2](http://opensource.org/licenses/Apache-2.0), [W3C Software Notice and License](http://www.w3.org/Consortium/Legal/copyright-software-19980720) or [MPL version 1.1 or 2.0](http://www.mozilla.org/MPL/) as alternatives to the MIT licence under which the web-xslt collection is distributed.  
*   **[htmlparse](http://code.google.com/p/web-xslt/source/browse/trunk/htmlparse)**, documentation tagged [htmlparse](http://dpcarlisle.blogspot.com/search/label/htmlparse)  
    HTML parser, implemented in XSLT 2.0.  
*   **[node-set](http://code.google.com/p/web-xslt/source/browse/trunk/node-set)**, documentation tagged [nodeset](http://dpcarlisle.blogspot.com/search/label/nodeset)  
    XSLT 1.0 (extended) stylesheet giving cross browser support for the EXSLT node-set extension.  
*   **[pmathml](http://code.google.com/p/web-xslt/source/browse/trunk/pmathml)**, documentation tagged [pmathml](http://dpcarlisle.blogspot.com/search/label/pmathml)  
    XSLT 1 stylesheet enabling MathML support in various browsers.  
*   **[pmathmlascii](http://code.google.com/p/web-xslt/source/browse/trunk/pmathmlascii)**, documentation tagged [pmathmlascii](http://dpcarlisle.blogspot.com/search/label/pmathmlascii)  
    XSLT 2.0 stylesheet displaying MathML as ASCII-art in a style similar to older terminal interfaces of computer algebra systems.  
*   **[pmml2tex](http://code.google.com/p/web-xslt/source/browse/trunk/pmml2tex)**, documentation tagged [pmml2tex](http://dpcarlisle.blogspot.com/search/label/pml2tex)  
    XSLT 2 stylesheet converting Presentation MathML to TeX for rendering to pdf, etc.  
*   **[mmlclipboard](http://code.google.com/p/web-xslt/source/browse/trunk/mmlclipboard)**, documentation tagged [mmlclipboard](http://dpcarlisle.blogspot.com/search/label/mmlclipboard)  
    Small C# code example for a windows form application that displays any XML on the windows clipboard tagged with the MathML flavor.  
*   **[polyglototron](http://code.google.com/p/web-xslt/source/browse/trunk/polyglototron)**, documentation tagged [polyglot](http://dpcarlisle.blogspot.com/search/label/polyglot)  
    Schematron file to check the constraints in the HTML5 polyglot spec (html/xhtml compatibility). This check assumes that the input is well formed XML and valid HTML(5) and then checks constraints such that that compatible parse trees should result.
