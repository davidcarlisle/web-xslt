var mmlns = "http://www.w3.org/1998/Math/MathML";
var ctopT= [];
var ctopTapply = [];


function ctop (){
    var mm = document.getElementsByTagName('math');
    for (var i = 0; i< mm.length;i++){
	ctopAT (mm[i],0); 
    }
}

function ctopAT(n,p) {
    if (n.nodeType==1) {
	if(ctopT[n.localName]) {
	    ctopT[n.localName](n,p);
	} else if (n.childNodes.length==0) {
	    ctopMI(n,n.localName);
	} else {
	    for(var j=0;j<n.childNodes.length; j++ ) {
		ctopAT(n.childNodes[j],p);
	    }
	}
    }
}


ctopT["ci"] = function(n,p) {
    ctopToken(n,'mi');
}

ctopT["csymbol"] = function(n,p) {
    if(ctopG[n.textContent]){
	ctopMI(n,ctopG[n.textContent]);
    } else {
	ctopToken(n,'mi');
    }
}
var ctopG=[];
ctopG['gamma']='\u03B3';


function ctopToken(n,s) {
    var np=n.parentNode;
    if(n.childNodes.length==1 && n.childNodes[0].nodeType==3) {
	var m=document.createElementNS(mmlns,s);
	m.textContent=n.textContent;
	np.replaceChild(m,n);
    } else {
	var mrow=document.createElementNS(mmlns,'mrow');
	np.replaceChild(mrow,n);
	for(var j=0;j<n.childNodes.length; j++ ) {
	    if (n.childNodes[j].nodeType==3) {
		var m=document.createElementNS(mmlns,s);
		m.textContent=n.childNodes[j].textContent;
		mrow.appendChild(m);
	    }else{
  		mrow.appendChild(n.childNodes[j])
		ctopAT(mrow.childNodes[j],0);
	    }
	}
    }
}



ctopT["apply"] = function(n,p) {
    var f=null;
    var a=[];
    for(var j=0;j<n.childNodes.length; j++ ) {
	if(n.childNodes[j].nodeType==1) {
	    if(f==null){
		f=n.childNodes[j];		
	    } else {
		a[a.length]=n.childNodes[j];
	    }
	}
    }
    if(f) {
	var nm = f.localName;
	nm=(nm=="csymbol") ? f.textContent : nm;
	if(ctopTapply[nm]) {
	    ctopTapply[nm](n,f,a,p);
	} else {
	    var mrow=document.createElementNS(mmlns,'mrow');
	    n.parentNode.replaceChild(mrow,n);
	    var mi=document.createElementNS(mmlns,'mi');
	    mi.textContent=nm;
	    mrow.appendChild(mi);
	    mrow.appendChild(ctopfa.cloneNode(true));
	    mrow.appendChild(ctopMF(a,'(',')'));
	}
    } else {
	var mrow=document.createElementNS(mmlns,'mrow');
	n.parentNode.replaceChild(mrow,n);
    }
}

ctopT["reln"] = ctopT["apply"];

function ctopMF(a,o,c) {
    var mf = document.createElementNS(mmlns,'mfenced');
    mf.setAttribute('open',o);
    mf.setAttribute('close',c);
    for(var j=0;j<a.length; j++ ) {
	var z= a[j].cloneNode(true);
  	mf.appendChild(z)
	ctopAT(z,0);
    }
    return mf;
}



var ctopfa=document.createElementNS(mmlns,'mo');
ctopfa.textContent='\u2061';



function ctopB(n,tp,p,m,a) {
    var mf = document.createElementNS(mmlns,'mrow');
    if(tp>p || (tp==p && m=="-")) {
        var mo=ctopfa.cloneNode(true);
	mo.textContent="(";
	mf.appendChild(mo);
    }
    if(a.length>2){
	var z= a[0].cloneNode(true);
	mf.appendChild(z)
	ctopAT(z,p);
    }
    
    var mo=ctopfa.cloneNode(true);
    mo.textContent=m;
    mf.appendChild(mo);

    if(a.length>1){
	var z= a[(a.length==1)?0:1].cloneNode(true);
	mf.appendChild(z)
	ctopAT(z,p);
    }
    
    if(tp>p || (tp==p && m=="-")) {
	var mo=ctopfa.cloneNode(true);
	mo.textContent=")";
	mf.appendChild(mo);
    }
    n.parentNode.replaceChild(mf,n);
}





ctopTapply["divide"] = function(n,f,a,p)  {ctopB(n,3,p,"/",a)}
ctopTapply["minus"] = function(n,f,a,p)  {ctopB(n,2,p,"-",a)}
ctopTapply["rem"] = function(n,f,a,p)  {ctopB(n,3,p,"mod",a)}
ctopTapply["implies"] = function(n,f,a,p)  {ctopB(n,3,p,"\u21D2",a)}
ctopTapply["factorof"] = function(n,f,a,p)  {ctopB(n,3,p,"\u21D2",a)}
ctopTapply["in"] = function(n,f,a,p)  {ctopB(n,3,p,"\u2208",a)}
ctopTapply["notin"] = function(n,f,a,p)  {ctopB(n,3,p,"\u2209",a)}
ctopTapply["notsubset"] = function(n,f,a,p)  {ctopB(n,2,p,"\u2288",a)}
ctopTapply["notprsubset"] = function(n,f,a,p)  {ctopB(n,2,p,"\u2284",a)}
ctopTapply["setdiff"] = function(n,f,a,p)  {ctopB(n,2,p,"\u2216",a)}
ctopTapply["tendsto"] = function(n,f,a,p)  {
    var t;
    if(f.localName=='tendsto') {
	t=f.getAttribute('type');
    } else {
	t=a[0].textContent;
	a[0]=a[1];
	a[1]=a[2];
    }
    var m = (t=='above')? '\u2198' :
        (t=='below')? '\u2198' : '\u2192' ;
    ctopB(n,2,p,m,a);
}



ctopTapply["complex-cartesian"] = function(n,f,a,p)  {
    var mf = document.createElementNS(mmlns,'mrow');
    var z= a[0].cloneNode(true);
    mf.appendChild(z)
    ctopAT(z,0);
    var mo=ctopfa.cloneNode(true);
    mo.textContent="+";
    mf.appendChild(mo);
    var z= a[1].cloneNode(true);
    mf.appendChild(z)
    ctopAT(z,0);
    var mo=ctopfa.cloneNode(true);
    mo.textContent="\u2062";
	mf.appendChild(mo);
    var mi = document.createElementNS(mmlns,'mi');
    mi.textContent="i";
    mf.appendChild(mi);
    n.parentNode.replaceChild(mf,n);
}
ctopTapply["complex-polar"] = function(n,f,a,p)  {
    var mf = document.createElementNS(mmlns,'mrow');
    var z= a[0].cloneNode(true);
    mf.appendChild(z)
    ctopAT(z,0);
    var mo=ctopfa.cloneNode(true);
    mo.textContent="\u2062";
    mf.appendChild(mo);
    var s = document.createElementNS(mmlns,'msup');
    var mi = document.createElementNS(mmlns,'mi');
    var mr = document.createElementNS(mmlns,'mrow');
    mi.textContent="e";
    s.appendChild(mi);
    var z= a[1].cloneNode(true);
    mr.appendChild(z)
    ctopAT(z,0);
    mr.appendChild(mo.cloneNode(true))
    mi=mi.cloneNode(mi);
    mi.textContent="i";
    mr.appendChild(mi);
    s.appendChild(mr);
    mf.appendChild(s);
    n.parentNode.replaceChild(mf,n);
}


ctopTapply["integer"] = function(n,f,a,p)  {
    n.parentNode.replaceChild(a[0],n);
    ctopAT(a[0]);
}

ctopTapply["based-integer"] = function(n,f,a,p)  {
    var s = document.createElementNS(mmlns,'msub');
    var z= a[1].cloneNode(true);
    s.appendChild(z)
    ctopAT(z,p);
    var z= a[0].cloneNode(true);
    s.appendChild(z)
    ctopAT(z,p);
    n.parentNode.replaceChild(s,n);
}

ctopTapply["rational"] = function(n,f,a,p)  {
    var s = document.createElementNS(mmlns,'mfrac');
    var z= a[0].cloneNode(true);
    s.appendChild(z)
    ctopAT(z,p);
    var z= a[1].cloneNode(true);
    s.appendChild(z)
    ctopAT(z,p);
    n.parentNode.replaceChild(s,n);
}


ctopT["cn"] = function(n,p) {
    var t=n.getAttribute("type");
    var b=n.getAttribute("base");
    if(t||b) {
	var ap = document.createElementNS(mmlns,'apply');
	var mrow = document.createElementNS(mmlns,'mrow');
	var c;
	if( b) {
	    t='based-integer';
	    c = document.createElementNS(mmlns,t);
	    ap.appendChild(c);
	    mn = document.createElementNS(mmlns,'mn');
	    mn.textContent=b;
	    ap.appendChild(mn);
	} else {
	    c = document.createElementNS(mmlns,t);
	    ap.appendChild(c);
	}
	for(var j=0;j<n.childNodes.length; j++ ) {
	    if (n.childNodes[j].nodeType==3) {
		var m=document.createElementNS(mmlns,'cn');
		m.textContent=n.childNodes[j].textContent;
		mrow.appendChild(m);
	    }else if (n.childNodes[j].localName=='sep'){
		ap.appendChild(mrow);
		mrow = document.createElementNS(mmlns,'mrow');
	    } else {
  		mrow.appendChild(n.childNodes[j])
	    }
	}
	ap.appendChild(mrow);
	n.parentNode.replaceChild(ap,n);
	ctopAT(ap,0);
    } else {   
	ctopToken(n,'mn');
    }
}


function ctopMI (n,s){
    m = document.createElementNS(mmlns,'mi');
    m.textContent=s;
    n.parentNode.replaceChild(m,n);
}

ctopT["naturalnumbers"] = function(n,p) {ctopMI(n,"\u2115")}
ctopT["integers"] = function(n,p) {ctopMI(n,"\u2115")}
ctopT["reals"] = function(n,p) {ctopMI(n,"\u211D")}
ctopT["rationals"] = function(n,p) {ctopMI(n,"\u211A")}
ctopT["complexes"] = function(n,p) {ctopMI(n,"\u2102")}
ctopT["primes"] = function(n,p) {ctopMI(n,"\u2119")}
ctopT["exponentiale"] = function(n,p) {ctopMI(n,"e")}
ctopT["imaginaryi"] = function(n,p) {ctopMI(n,"i")}
ctopT["notanumber"] = function(n,p) {ctopMI(n,"NaN")}
ctopT["eulergamma"] = function(n,p) {ctopMI(n,"\u03B3")}
ctopT["gamma"] = function(n,p) {ctopMI(n,"\u0263")}
ctopT["pi"] = function(n,p) {ctopMI(n,"\u03C0")}
ctopT["infinity"] = function(n,p) {ctopMI(n,"\u221E")}
ctopT["emptyset"] = function(n,p) {ctopMI(n,"\u2205")}
ctopT["true"] = function(n,p) {ctopMI(n,"true")}
ctopT["false"] = function(n,p) {ctopMI(n,"false")}





ctopI = function(n,f,a,p,tp,s)  {
    var mf = document.createElementNS(mmlns,'mrow');
    if(p>tp) {
        var mo=ctopfa.cloneNode(true);
	mo.textContent="(";
	mf.appendChild(mo);
    }
    for(var j=0;j<a.length; j++ ) {
	var z= a[j].cloneNode(true);
	if(j>0) {
            var mo=ctopfa.cloneNode(true);
	    mo.textContent=s;
	    mf.appendChild(mo);
	}
  	mf.appendChild(z)
	ctopAT(z,tp);
    }
    if(p>tp) {
        var mo=ctopfa.cloneNode(true);
	mo.textContent=")";
	mf.appendChild(mo);
    }
    n.parentNode.replaceChild(mf,n);
}

ctopTapply["plus"] = function(n,f,a,p) {ctopI(n,f,a,p,2,"+")}
ctopTapply["eq"] = function(n,f,a,p) {ctopI(n,f,a,p,1,"=")}
ctopTapply["compose"] = function(n,f,a,p) {ctopI(n,f,a,p,1,"\u2218")}
ctopTapply["left_compose"] = function(n,f,a,p) {ctopI(n,f,a,p,1,"\u2218")}
ctopTapply["and"] = function(n,f,a,p) {ctopI(n,f,a,p,2,"\u2227")}
ctopTapply["or"] = function(n,f,a,p) {ctopI(n,f,a,p,3,"\u2228")}
ctopTapply["xor"] = function(n,f,a,p) {ctopI(n,f,a,p,3,"xor")}
ctopTapply["neq"] = function(n,f,a,p) {ctopI(n,f,a,p,1,"\u2260")}
ctopTapply["gt"] = function(n,f,a,p) {ctopI(n,f,a,p,1,"<")}
ctopTapply["lt"] = function(n,f,a,p) {ctopI(n,f,a,p,1,">")}
ctopTapply["geq"] = function(n,f,a,p) {ctopI(n,f,a,p,1,"\u2265")}
ctopTapply["leq"] = function(n,f,a,p) {ctopI(n,f,a,p,1,"\u2264")}
ctopTapply["equivalent"] = function(n,f,a,p) {ctopI(n,f,a,p,1,"\u2261")}
ctopTapply["approx"] = function(n,f,a,p) {ctopI(n,f,a,p,1,"\u2243")}
ctopTapply["union"] = function(n,f,a,p) {ctopI(n,f,a,p,2,"\u222A")}
ctopTapply["intersect"] = function(n,f,a,p) {ctopI(n,f,a,p,3,"\u2229")}
ctopTapply["subset"] = function(n,f,a,p) {ctopI(n,f,a,p,2,"\u2286")}
ctopTapply["prsubset"] = function(n,f,a,p) {ctopI(n,f,a,p,2,"\u2282")}
ctopTapply["cartesianproduct"] = function(n,f,a,p) {ctopI(n,f,a,p,2,"\u00D7")}
ctopTapply["cartesian_product"] = function(n,f,a,p) {ctopI(n,f,a,p,2,"\u00D7")}
ctopTapply["vectorproduct"] = function(n,f,a,p) {ctopI(n,f,a,p,2,"\u00D7")}
ctopTapply["scalarproduct"] = function(n,f,a,p) {ctopI(n,f,a,p,2,".")}
ctopTapply["outerproduct"] = function(n,f,a,p) {ctopI(n,f,a,p,2,"\u2297")}


ctopT["set"] = function(n,p) {ctopS(n,n.children,'{','}')};
ctopTapply["set"] = function(n,f,a,p) {ctopS(n,a,'{','}')};
ctopT["list"] = function(n,p) {ctopS(n,n.children,'(',')')};
ctopTapply["list"] = function(n,f,a,p) {ctopS(n,a,'(',')')};


function ctopS (n,a,o,c){
    n.parentNode.replaceChild(ctopMF(a,o,c),n);
}


				   

ctopT["piecewise"] = function(n,p)  {
    var mr = document.createElementNS(mmlns,'mrow');
    var mo=ctopfa.cloneNode(true);
    mo.textContent="{";
    mr.appendChild(mo);
    var mt = document.createElementNS(mmlns,'mtable');
    mr.appendChild(mt);
    for(var i=0;i<n.children.length;i++){
	var z= n.children[i].cloneNode(true);
	mt.appendChild(z)
	ctopAT(z,0);
    }
    n.parentNode.replaceChild(mr,n);
}

ctopT["piece"] = function(n,p) {
    var mtr = document.createElementNS(mmlns,'mtr');
    for(i=0;i<n.children.length;i++){
	var mtd = document.createElementNS(mmlns,'mtd');
	mtr.appendChild(mtd);
	var z= n.children[i].cloneNode(true);
	mtd.appendChild(z)
	ctopAT(z,0);
	if(i==0){
	var mtd = document.createElementNS(mmlns,'mtd');
	    mtd.textContent="\u00A0if\u00A0";
	    mtr.appendChild(mtd);
	}
    }
    n.parentNode.replaceChild(mtr,n);
};

ctopT["otherwise"] = function(n,p) {
    var mtr = document.createElementNS(mmlns,'mtr');
    if(n.children.length>0){
	var mtd = document.createElementNS(mmlns,'mtd');
	mtr.appendChild(mtd);
	var z= n.children[0].cloneNode(true);
	mtd.appendChild(z)
	ctopAT(z,0);
	var mtd = document.createElementNS(mmlns,'mtd');
	mtd.setAttribute('columnspan','2');
	mtd.textContent="\u00A0otherwise";
	mtr.appendChild(mtd);
    }
    n.parentNode.replaceChild(mtr,n);
};