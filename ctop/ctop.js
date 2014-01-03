
var ctopT= {};
var ctopTapply = {};


function ctop (){
    var mm = document.getElementsByTagName('math');
    for (var i = 0; i< mm.length;i++){
	var nn=mm[i].cloneNode(false);
	for(var j=0;j<mm[i].childNodes.length; j++ ) {
	    ctopAT(nn,mm[i].childNodes[j],0);
	}
	mm[i].parentNode.replaceChild(nn,mm[i]); 
    }
}

function ctopE (e) {
return document.createElementNS("http://www.w3.org/1998/Math/MathML",e);
}


// .children causes problems in IE and is a pain
// as it's a live list
function ctopChildren(n) {
    var c=[];
    for(var j=0;j<n.childNodes.length; j++ ) {
	if(n.childNodes[j].nodeType==1) {
	    c[c.length]=n.childNodes[j];
	}
    }
    return c;
}

function ctopAT(nn,n,p) {
    if (n.nodeType==1) {
	if(ctopT[n.localName]) {
	    ctopT[n.localName](nn,n,p);
	} else if (n.childNodes.length==0) {
	    ctopAppendTok(nn,'mi',n.localName);
	} else {
            var nnn=n.cloneNode(false);
	    nn.appendChild(nnn);
	    for(var j=0;j<n.childNodes.length; j++ ) {
		ctopAT(nnn,n.childNodes[j],p);
	    }
	}
    } else if (n.nodeType==3) {
	nn.appendChild(n.cloneNode(false));
    }
}


ctopT["ci"] = function(nn,n,p) {
    ctopToken(nn,n,'mi');
}

ctopT["cs"] = function(nn,n,p) {
    ctopToken(nn,n,'ms');
}
ctopT["csymbol"] = function(nn,n,p) {
    if(ctopG[n.textContent]){
	ctopAppendTok(nn,ctopG[n.textContent]);
    } else {
	ctopToken(nn,n,'mi');
    }
}
var ctopG={};
ctopG['gamma']='\u03B3';


function ctopToken(nn,n,s) {
    if(n.childNodes.length==1 && n.childNodes[0].nodeType==3) {
	ctopAppendTok(nn,s,n.textContent);
    } else {
	var mrow=ctopE('mrow');
	nn.appendChild(mrow);
	for(var j=0;j<n.childNodes.length; j++ ) {
	    if (n.childNodes[j].nodeType==3) {
		ctopAppendTok(nn,s,n.childNodes[j].textContent);
	    }else{
		ctopAT(mrow,n.childNodes[j],0);
	    }
	}
    }
}



ctopT["apply"] = function(nn,n,p) {
    var f=null;
    var a=[],b=[],q=[];
    for(var j=0;j<n.childNodes.length; j++ ) {
	if(n.childNodes[j].nodeType==1) {
	    var nd=nm=n.childNodes[j], nm=nd.localName;
	    if(nm=='bvar'){
		b[b.length]=nd;
	    } else if(nm=='condition'||
		      nm=='degree'||
		      nm=='logbase'||
		      nm=='lowlimit'||
		      nm=='uplimit'||
		      (nm=='interval' && !(a.length))||
		      nm=='domainofapplication') {
		q[q.length]=nd;
	    } else if(f==null){
		f=nd;		
	    } else {
		a[a.length]=nd;
	    }
	}
    }
    if(f) {
	var nm = f.localName;
	nm=(nm=="csymbol") ? f.textContent : nm;
	if(ctopTapply[nm]) {
	    ctopTapply[nm](nn,n,f,a,b,q,p);
	} else {
	    var mrow=ctopE('mrow');
	    nn.appendChild(mrow);
	    if(f.childNodes.length){
		ctopAT(mrow,f,0);
	    } else {
		ctopAppendTok(mrow,'mi',nm);
	    }
	    mrow.appendChild(ctopfa.cloneNode(true));
	    mrow.appendChild(ctopMF(a,'(',')'));
	}
    } else {
	nn.appendchild(ctopE('mrow'));
    }
}

ctopT["reln"] = ctopT["apply"];
ctopT["bind"] = ctopT["apply"];

function ctopMF(a,o,c) {
    var mf = ctopE('mfenced');
    mf.setAttribute('open',o);
    mf.setAttribute('close',c);
    for(var j=0;j<a.length; j++ ) {
	ctopAT(mf,a[j],0);
    }
    return mf;
}



var ctopfa=ctopE('mo');
ctopfa.textContent='\u2061';



function ctopB(nn,n,tp,p,m,a) {
    var mf = ctopE('mrow');
    if(tp<p || (tp==p && m=="-")) {
        var mo=ctopfa.cloneNode(true);
	mo.textContent="(";
	mf.appendChild(mo);
    }
    if(a.length>1){
	ctopAT(mf,a[0],p);
    }
    
    var mo=ctopfa.cloneNode(true);
    mo.textContent=m;
    mf.appendChild(mo);

    if(a.length>0){
	var z= a[(a.length==1)?0:1];
	ctopAT(mf,z,p);
    }
    
    if(tp<p || (tp==p && m=="-")) {
	var mo=ctopfa.cloneNode(true);
	mo.textContent=")";
	mf.appendChild(mo);
    }
    nn.appendChild(mf);
}




ctopTapply["rem"] = function(nn,n,f,a,b,q,p)  {ctopB(nn,n,3,p,"mod",a)}

ctopTapply["divide"] = function(nn,n,f,a,b,q,p)  {ctopB(nn,n,3,p,"/",a)}
ctopTapply["remainder"] = function(nn,n,f,a,b,q,p)  {ctopB(nn,n,3,p,"mod",a)}
ctopTapply["implies"] = function(nn,n,f,a,b,q,p)  {ctopB(nn,n,3,p,"\u21D2",a)}
ctopTapply["factorof"] = function(nn,n,f,a,b,q,p)  {ctopB(nn,n,3,p,"\u21D2",a)}
ctopTapply["in"] = function(nn,n,f,a,b,q,p)  {ctopB(nn,n,3,p,"\u2208",a)}
ctopTapply["notin"] = function(nn,n,f,a,b,q,p)  {ctopB(nn,n,3,p,"\u2209",a)}
ctopTapply["notsubset"] = function(nn,n,f,a,b,q,p)  {ctopB(nn,n,2,p,"\u2288",a)}
ctopTapply["notprsubset"] = function(nn,n,f,a,b,q,p)  {ctopB(nn,n,2,p,"\u2284",a)}
ctopTapply["setdiff"] = function(nn,n,f,a,b,q,p)  {ctopB(nn,n,2,p,"\u2216",a)}
ctopTapply["tendsto"] = function(nn,n,f,a,b,q,p)  {
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
    ctopB(nn,n,2,p,m,a);
}


ctopTapply["minus"] = function(nn,n,f,a,b,q,p)  {
    if(a.length==1) {
	ctopB(nn,n,5,p,"-",a);
    } else {
	ctopB(nn,n,2,p,"-",a);
    }
}




ctopTapply["complex-cartesian"] = function(nn,n,f,a,b,q,p)  {
    var mf = ctopE('mrow');
    ctopAT(mf,a[0],0);
    ctopAppendTok(mf,'mo','+');
    ctopAT(mf,a[1],0);
    ctopAppendTok(mf,'mo','\u2062');
    ctopAppendTok(mf,'mi','i');
    nn.appendChild(mf);
}


ctopTapply["complex-polar"] = function(nn,n,f,a,b,q,p)  {
    var mf = ctopE('mrow');
    ctopAT(mf,a[0],0);
    ctopAppendTok(mf,'mo','\u2062');
    var s = ctopE('msup');
    ctopAppendTok(s,'mi','e');
    var mr = ctopE('mrow');
    ctopAT(mr,a[1],0);
    ctopAppendTok(mr,'mo','\u2062');
    ctopAppendTok(mr,'mi','i');
    s.appendChild(mr);
    mf.appendChild(s);
    nn.appendChild(mf);
}


ctopTapply["integer"] = function(nn,n,f,a,b,q,p)  {
    ctopAT(nn,a[0],0);
}

ctopTapply["based-integer"] = function(nn,n,f,a,b,q,p)  {
    var s = ctopE('msub');
    ctopAT(s,a[1],0);
    ctopAT(s,a[0],0);
    nn.appendChild(s);
}

ctopTapply["rational"] = function(nn,n,f,a,b,q,p)  {
    var s = ctopE('mfrac');
    ctopAT(s,a[0],0);
    ctopAT(s,a[1],0);
    nn.appendChild(s);
}


ctopT["cn"] = function(nn,n,p) {
    var t=n.getAttribute("type");
    var b=n.getAttribute("base");
    if(t||b) {
	var ap = ctopE('apply');
	var mrow = ctopE('mrow');
	var c;
	if( b) {
	    t='based-integer';
	    c = ctopE(t);
	    ap.appendChild(c);
            ctopAppendTok(ap,'mn',b);
	} else {
	    c = ctopE(t);
	    ap.appendChild(c);
	}
	for(var j=0;j<n.childNodes.length; j++ ) {
	    if (n.childNodes[j].nodeType==3) {
		ctopAppendTok(mrow,'cn',n.childNodes[j].textContent);
	    }else if (n.childNodes[j].localName=='sep'){
		ap.appendChild(mrow);
		mrow = ctopE('mrow');
	    } else {
  		mrow.appendChild(n.childNodes[j].cloneNode(true));
	    }
	}
	ap.appendChild(mrow);
	ctopAT(nn,ap,0);
    } else {   
	ctopToken(nn,n,'mn');
    }
}


function ctopAppendTok (n,t,s){
    m = ctopE(t);
    m.textContent=s;
    n.appendChild(m);
}



ctopT["naturalnumbers"] = function(nn,n,p) {ctopAppendTok(nn,"mi","\u2115")}
ctopT["integers"] = function(nn,n,p) {ctopAppendTok(nn,"mi","\u2124")}
ctopT["reals"] = function(nn,n,p) {ctopAppendTok(nn,"mi","\u211D")}
ctopT["rationals"] = function(nn,n,p) {ctopAppendTok(nn,"mi","\u211A")}
ctopT["complexes"] = function(nn,n,p) {ctopAppendTok(nn,"mi","\u2102")}
ctopT["primes"] = function(nn,n,p) {ctopAppendTok(nn,"mi","\u2119")}
ctopT["exponentiale"] = function(nn,n,p) {ctopAppendTok(nn,"mi","e")}
ctopT["imaginaryi"] = function(nn,n,p) {ctopAppendTok(nn,"mi","i")}
ctopT["notanumber"] = function(nn,n,p) {ctopAppendTok(nn,"mi","NaN")}
ctopT["eulergamma"] = function(nn,n,p) {ctopAppendTok(nn,"mi","\u03B3")}
ctopT["gamma"] = function(nn,n,p) {ctopAppendTok(nn,"mi","\u0263")}
ctopT["pi"] = function(nn,n,p) {ctopAppendTok(nn,"mi","\u03C0")}
ctopT["infinity"] = function(nn,n,p) {ctopAppendTok(nn,"mi","\u221E")}
ctopT["emptyset"] = function(nn,n,p) {ctopAppendTok(nn,"mi","\u2205")}
ctopT["true"] = function(nn,n,p) {ctopAppendTok(nn,"mi","true")}
ctopT["false"] = function(nn,n,p) {ctopAppendTok(nn,"mi","false")}






ctopTapply["times"] = function(nn,n,f,a,b,q,p) {
    var mf = ctopE('mrow');
    if(p>3) {
	ctopAppendTok(mf,'mo','(');
    }
    for(var j=0;j<a.length; j++ ) {
	if(j>0) {
	    ctopAppendTok(mf,'mo',(a[j].localName=='cn') ? "\u00D7" :"\u2062");
	}
	ctopAT(mf,a[j],3);
    }
    if(p>3) {
	ctopAppendTok(mf,'mo',')');
    }
    nn.appendChild(mf);
}


ctopTapply["plus"] = function(nn,n,f,a,b,q,p) {
    var mf = ctopE('mrow');
    if(p>2) {
	ctopAppendTok(mf,'mo','(');
    }
    for(var j=0;j<a.length; j++ ) {
	var z= a[j];
	var c=ctopChildren(z);
	if(j>0) {
	    if(z.localName=='cn' && !(c.length) && Number(z.textContent) <0) {
		ctopAppendTok(mf,'mo','\u2212');
		ctopAppendTok(mf,'mn', -1 * Number(a[j].textContent));
	    } else if(z.localName=='apply' && c.length==2 && c[0].localName=='minus') {
		ctopAppendTok(mf,'mo','\u2212');
		ctopAT(mf,c[1],3);
	    } else if(a[j].localName=='apply' && c.length>2 && c[0].localName=='times' && c[1].localName=='cn' &&( Number(c[1].textContent) < 0)) {
		ctopAppendTok(mf,'mo','\u2212');
		c[1].textContent=-(Number(c[1].textContent));// fix me: modifying document
		ctopAT(mf,z,3);
	    } else{
		ctopAppendTok(mf,'mo','+');
		ctopAT(mf,z,3);
	    }
	} else {
	    ctopAT(mf,z,3);	}
    }
    if(p>2) {
	ctopAppendTok(mf,'mo',')');
    }
    nn.appendChild(mf);
}


ctopI = function(nn,f,a,p,tp,s)  {
    var mf = ctopE('mrow');
    if(p>tp) {
	ctopAppendTok(mf,'mo','(');
    }
    for(var j=0;j<a.length; j++ ) {
	if(j>0) {
	    ctopAppendTok(mf,'mo',s);
	}
	ctopAT(mf,a[j],tp);
    }
    if(p>tp) {
	ctopAppendTok(mf,'mo',')');
    }
    nn.appendChild(mf);
}


ctopTapply["eq"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,1,"=")}
ctopTapply["compose"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,1,"\u2218")}
ctopTapply["left_compose"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,1,"\u2218")}
ctopTapply["and"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,2,"\u2227")}
ctopTapply["or"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,3,"\u2228")}
ctopTapply["xor"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,3,"xor")}
ctopTapply["neq"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,1,"\u2260")}
ctopTapply["gt"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,1,"<")}
ctopTapply["lt"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,1,">")}
ctopTapply["geq"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,1,"\u2265")}
ctopTapply["leq"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,1,"\u2264")}
ctopTapply["equivalent"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,1,"\u2261")}
ctopTapply["approx"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,1,"\u2243")}
ctopTapply["union"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,2,"\u222A")}
ctopTapply["intersect"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,3,"\u2229")}
ctopTapply["subset"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,2,"\u2286")}
ctopTapply["prsubset"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,2,"\u2282")}
ctopTapply["cartesianproduct"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,2,"\u00D7")}
ctopTapply["cartesian_product"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,2,"\u00D7")}
ctopTapply["vectorproduct"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,2,"\u00D7")}
ctopTapply["scalarproduct"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,2,".")}
ctopTapply["outerproduct"] = function(nn,n,f,a,b,q,p) {ctopI(nn,f,a,p,2,"\u2297")}


ctopT["set"] = function(nn,n,p) {ctopS(nn,ctopChildren(n),'{','}')};
ctopTapply["set"] = function(nn,n,f,a,b,q,p) {ctopS(nn,a,'{','}')};
ctopT["list"] = function(nn,n,p) {ctopS(nn,ctopChildren(n),'(',')')};
ctopTapply["list"] = function(nn,n,f,a,b,q,p) {ctopS(nn,a,'(',')')};

ctopT["interval"] = function(nn,n,p) {
    var c=n.getAttribute('closure');
    ctopS(nn,ctopChildren(n),
	  (c=='open' || c=='open-closed')?'(':'[',
	  (c=='open' || c=='closed-open')?')':']'
	 )};

function ctopS (nn,a,o,c){
    nn.appendChild(ctopMF(a,o,c));
}

				   

ctopT["piecewise"] = function(nn,n,p)  {
    var mr = ctopE('mrow');
    ctopAppendTok(mr,'mo','{');
    var mt = ctopE('mtable');
    mr.appendChild(mt);
    var c=ctopChildren(n);
    for(var i=0;i<c.length;i++){
	ctopAT(mt,c[i],0);
    }
    nn.appendChild(mr);
}

ctopT["piece"] = function(nn,n,p) {
    var mtr = ctopE('mtr');
    var c=ctopChildren(n);
    for(i=0;i<c.length;i++){
	var mtd = ctopE('mtd');
	mtr.appendChild(mtd);
	ctopAT(mtd,c[i],0);
	if(i==0){
	var mtd = ctopE('mtd');
	    ctopAppendTok(mtd,"mtext","\u00A0if\u00A0");
	    mtr.appendChild(mtd);
	}
    }
    nn.appendChild(mtr);
};

ctopT["otherwise"] = function(nn,n,p) {
    var mtr = ctopE('mtr');
    var c=ctopChildren(n);
    if(c.length){
	var mtd = ctopE('mtd');
	mtr.appendChild(mtd);
	ctopAT(mtd,c[0],0);
	var mtd = ctopE('mtd');
	mtd.setAttribute('columnspan','2');
	ctopAppendTok(mtd,"mtext","\u00A0otherwise");
	mtr.appendChild(mtd);
    }
    nn.appendChild(mtr);
};

ctopT["matrix"] = function(nn,n,p) {
    var a=[],b=[],q=[];
    for(var j=0;j<n.childNodes.length; j++ ) {
	var c=n.childNodes[j]
	if(c.nodeType==1) {
	    if(c.localName=='condition' || c.localName=='domainofapplication' ) {
		q[q.length]=c;
	    } else if(c.localName=='bvar') {
		b[b.length]=c;
	    } else {
		a[a.length]=c;
	    }
	}
    }
    if(b.length||q.length){
	var mr = ctopE('mrow');
	ctopAppendTok(mr,"mo","[");
	var ms = ctopE('msub');
	ctopAppendTok(ms,'mi','m');
	var mr2 = ctopE('mrow');
	for(var i=0;i<b.length;i++){
	    if(i!=0){
		ctopAppendTok(mr2,'mo',',');
	    }	
            ctopAT(mr2,b[i].childNodes[0],0);
	}
	ms.appendChild(mr2);
	mr.appendChild(ms);
	var ms2=ms.cloneNode(true);
	ctopAppendTok(mr,'mo','|');
	mr.appendChild(ms2);
	ctopAppendTok(mr,'mo','=');
	for(var i=0;i<a.length;i++){
	    if(i!=0){
		ctopAppendTok(mr,'mo',',');
	    }	
            ctopAT(mr,a[i],0);
	}
	ctopAppendTok(mr,'mo',';');
	for(var i=0;i<q.length;i++){
	    if(i!=0){
		ctopAppendTok(mr,'mo',',');
	    }	
            ctopAT(mr,q[i],0);
	}
	ctopAppendTok(mr,'mo',']');
      	nn.appendChild(mr);
    } else {
	var mf = ctopE('mfenced');
	var mt = ctopE('mtable');
	for(var i=0;i<a.length;i++){
	    ctopAT(mt,a[i],0);
	}
      	mf.appendChild(mt);
      	nn.appendChild(mf);
    }
}
	  

ctopT["matrixrow"] = function(nn,n,p){
    var mtr = ctopE('mtr');
    var c=ctopChildren(n);
    for(var i=0;i<c.length;i++){
	var mtd = ctopE('mtd');
	ctopAT(mtd,c[i],0);
	mtr.appendChild(mtd);
    }
    nn.appendChild(mtr);
}


ctopTapply["power"] = function(nn,n,f,a,b,q,p)  {
    var s = ctopE('msup');
    ctopAT(s,a[0],p);
    ctopAT(s,a[1],p);
    nn.appendChild(s);
}


ctopT["condition"] = function(nn,n,p)  {
    var mr = ctopE('mrow');
    var c=ctopChildren(n);
    for(var i=0;i<c.length;i++){
	ctopAT(mr,c[i],0);
    }
    nn.appendChild(mr);
}


ctopTapply["selector"] = function(nn,n,f,a,b,q,p){
    var ms = ctopE('msub');
    var z=(a)? a[0]: ctopE('mrow');
    ctopAT(ms,z,0);
    var mr2 = ctopE('mrow');
    for(var i=1;i<a.length;i++){
	if(i!=1){
	    ctopAppendTok(mr2,'mo',',');
	}	
	ctopAT(mr2,a[i],0);
    }
    ms.appendChild(mr2);
    nn.appendChild(ms);
}



ctopTapply["log"] = function(nn,n,f,a,b,q,p)  {
    var mr = ctopE('mrow');
    var mi = ctopE('mi');
    mi.textContent='log';
    if(q.length &&q[0].localName=='logbase'){
	var ms = ctopE('msub');
	ms.appendChild(mi);
	ctopAT(ms,ctopChildren(q[0])[0],0);
	mr.appendChild(ms);
    } else {
	mr.appendChild(mi);
    }
    ctopAT(mr,a[0],7);
    nn.appendChild(mr);
}


ctopTapply["int"] = function(nn,n,f,a,b,q,p)  {
    var mr = ctopE('mrow');
    var mo = ctopE('mo');
    mo.textContent='\u222B';
    var mss=ctopE('msubsup');
    mss.appendChild(mo);
    var mr1 = ctopE('mrow');
    for(var i=0; i<q.length;i++){
	if(q[i].localName=='lowlimit'||
	   q[i].localName=='condition'||
	   q[i].localName=='domainofapplication')
	{
	    var qc=ctopChildren(q[i]);
	    for(var j=0;j<qc.length;j++){
		ctopAT(mr1,qc[j],0);
	    }
	} else {
	    var qc=ctopChildren(q[i]);
	    if (q[i].localName=='interval' && qc.length==2) {
		ctopAT(mr1,qc[0],0);
	    }
	}
    }
    mss.appendChild(mr1);
    var mr2 = ctopE('mrow');
    for(var i=0; i<q.length;i++){
	if(q[i].localName=='uplimit'){
	    var qc=ctopChildren(q[i]);
	    for(j=0;j<qc.length;j++){
		ctopAT(mr2,qc[j],0);
	    }
	    break;
	} else if(q[i].localName=='interval' ){
	    var qc=ctopChildren(q[i]);
	    ctopAT(mr2,qc[qc.length -1],0);
	    break;
	}
    }
    mss.appendChild(mr2);
    mr.appendChild(mss);
    for(var i=0; i<a.length;i++){
	ctopAT(mr,a[i],0);
    }
    for(var i=0; i<b.length;i++){
	var z=b[i];
	var zc=ctopChildren(z);
	if(zc.length){
	    var mr3=ctopE("mrow");
	    ctopAppendTok(mr3,'mi','d');
	    ctopAT(mr3,zc[0],0);
	    mr.appendChild(mr3);
	}
    }
    nn.appendChild(mr);
}



function ctopO(nn,f,a,b,q,p,s)  {
    var mr = ctopE('mrow');
    var mo = ctopE('mo');
    mo.textContent=s;
    var mss=ctopE('munderover');
    mss.appendChild(mo);
    var mr1 = ctopE('mrow');
    for(var i=0; i<q.length;i++){
	if(q[i].localName=='lowlimit'||
	   q[i].localName=='condition'||
	   q[i].localName=='domainofapplication')
	{
	    if(q[i].localName=='lowlimit'){
		for(var j=0; j<b.length;j++){
		    var z=b[j];
		    var zc=ctopChildren(z);
		    if(zc.length){
			mr1.appendChild(zc[0]);
			ctopAT(z,0);
		    }
		}
		if(b.length){
		    ctopAppendTok(mr1,"mo","=");
		}
	    }
	    var qc=ctopChildren(q[i]);
	    for(j=0;j<qc.length;j++){
		ctopAT(mr1,qc[j],0);
	    }
	} else {
	    var qc=ctopChildren(q[i]);
	    if (q[i].localName=='interval' && qc.length==2) {
		for(var j=0; j<b.length;j++){
		    var z=b[j];
		    var zc=ctopChildren(z);
		    if(zc.length){
			ctopAT(mr1,zc[0],0);
		    }
		}
		if(b.length){
		    ctopAppendTok(mr1,"mo","=");
		}
		ctopAT(mr1,ctopChildren(q[i])[0],0);
	    }
	}
    }
    mss.appendChild(mr1);
    var mr2 = ctopE('mjrow');
    for(var i=0; i<q.length;i++){
	if(q[i].localName=='uplimit' ||q[i].localName=='interval' )
	{
	    var qc=ctopChildren(q[i]);
	    for(j=0;j<qc.length;j++){
		ctopAT(mr2,qc[j],0);
	    }
	}
    }
    mss.appendChild(mr2);
    mr.appendChild(mss);
    for(var i=0; i<a.length;i++){
	ctopAT(mr,a[i],0);
    }
    nn.appendChild(mr);
}


ctopTapply["sum"] = function (nn,n,f,a,b,q,p){ctopO(nn,f,a,b,q,p,'\u2211')};

ctopTapply["product"] = function (nn,n,f,a,b,q,p){ctopO(nn,f,a,b,q,p,'\u220F')};


function ctopBd(nn,f,a,b,q,p,s)  {
    var mr = ctopE('mrow');
    ctopAppendTok(mr,'mo',s);
    var cnd=0,qc=[];
    for(var i=0; i<q.length;i++){
	if(q[i].localName=='condition')	{
	    cnd=1;
	    qc=ctopChildren(q[i]);
	    for(var j=0;j<qc.length;j++){
		ctopAT(mr,qc[j],0);
	    }
	}
    }
    if(cnd==0){
	for(var j=0; j<b.length;j++){
	    var z=b[j];
	    var zc=ctopChildren(z);
	    if(zc.length){
		ctopAT(mr,zc[0],0);
	    }
	}
    }
    for(var i=0; i<q.length;i++){
	if(q[i].localName!='condition')	{
            ctopAppendTok(mr,'mo','\u2208');
	    qc=ctopChildren(q[i]);
	    for(var j=0;j<qc.length;j++){
		ctopAT(mr,qc[j],0);
	    }
	}
    }
    if(b.length||qc.length){
        ctopAppendTok(mr,'mo','.');
    }
    for(var i=0; i<a.length;i++){
	ctopAT(mr,a[i],0);
    }
    nn.appendChild(mr);
}

ctopTapply["forall"] = function (nn,n,f,a,b,q,p){ctopBd(nn,f,a,b,q,p,'\u2200')};
ctopTapply["exists"] = function (nn,n,f,a,b,q,p){ctopBd(nn,f,a,b,q,p,'\u2203')};
ctopTapply["lambda"] = function (nn,n,f,a,b,q,p){ctopBd(nn,f,a,b,q,p,'\u03BB')};

ctopT["lambda"] = function (nn,n,p) {
    var f=ctopE('lambda');
    var a=[],b=[],q=[];
    for(var j=0;j<n.childNodes.length; j++ ) {
	if(n.childNodes[j].nodeType==1) {
	    var nd=nm=n.childNodes[j], nm=nd.localName;
	    if(nm=='bvar'){
		b[b.length]=nd;
	    } else if(nm=='condition'||
		      nm=='degree'||
		      nm=='logbase'||
		      nm=='lowlimit'||
		      nm=='uplimit'||
		      (nm=='interval' && !(a.length))||
		      nm=='domainofapplication') {
		q[q.length]=nd;
	    } else if(f==null){
		f=nd;		
	    } else {
		a[a.length]=nd;
	    }
	}
    }
    if(b.length){
	ctopTapply["lambda"](nn,n,f,a,b,q,p);
    } else {
	var mr=ctopE('mrow');
	for(var i=0;i<a.length;i++){
	    ctopAT(mr,a[i],0);
	}
	if(q.length){
	    var ms=ctopE('msub');
	    ctopAppendTok(ms,'mo','|');
	    var mr2=ctopE('mrow');
	    for(var i=0;i<q.length;i++){
		var c=ctopChildren(q[i]);
		for(var j=0;j<c.length;j++){
		    ctopAT(mr2,c[j],0);
		}
	    }
	    ms.appendChild(mr2);
	    mr.appendChild(ms);
	}
    nn.appendChild(mr);
    }
}


ctopTapply["inverse"] = function(nn,n,f,a,b,q,p)  {
    var s = ctopE('msup');
    var z= (a.length)? a[0]:ctopE('mrow');
    ctopAT(s,z,p);
    var mf=ctopE('mfenced');
    ctopAppendTok(mf,'mn','-1');
    s.appendChild(mf);
    nn.appendChild(s);
}


ctopT["ident"] = function(nn,n,p) {ctopAppendTok(nn,"mi","id")}

ctopT["domainofapplication"] = function(nn,n,p) {
    var me=ctopE('merror');
    ctopAppendTok(me,'mtext','unexpected domainofapplication');
    nn.appendChild(me);
}

ctopT["share"] = function(nn,n,p) {
    var mi=ctopE('mi');
    mi.setAttribute('href',n.getAttribute('href'));
    mi.textContent="share" + n.getAttribute('href');
    nn.appendChild(mi);
}


ctopT["cerror"] = function(nn,n,p) {
    var me=ctopE('merror');
    var c=ctopChildren(n);
    for(var i=0;i<c.length;i++){
	ctopAT(me,c[i],0);
    }
    nn.appendChild(me);
}


ctopTapply["quotient"] = function(nn,n,f,a,b,q,p)  {
    var mr=ctopE('mrow');
    ctopAppendTok(mr,'mo','\u230A');
    if(a.length) {
	ctopAT(mr,a[0],0);
	ctopAppendTok(mr,'mo','/');
	if(a.length>1){
	    ctopAT(mr,a[1],0);
	}
    }
    ctopAppendTok(mr,'mo','\u230B');
    nn.appendChild(mr);
}


ctopTapply["factorial"] = function(nn,n,f,a,b,q,p)  {
    var mr=ctopE('mrow');
    ctopAT(mr,a[0],0);
    ctopAppendTok(mr,'mo','!');
    nn.appendChild(mr);
}


ctopTapply["root"] = function(nn,n,f,a,b,q,p)  {
    var mr;
    if(f.localName=='root' && (q.length==0 || (q[0].localName=='degree' && q[0].textContent=='2'))){
	mr=ctopE('msqrt');
	for(var i=0;i<a.length;i++){
	    ctopAT(mr,a[i],0);
	}
    } else {
	mr=ctopE('mroot');
	ctopAT(mr,a[0],0);
	var z=(f.localName=='root') ? q[0].childNodes[0] : a[1];
	ctopAT(mr,z,0);
    }
    nn.appendChild(mr);
}


ctopTapply["diff"] = function(nn,n,f,a,b,q,p)  {
    var m;
    var mr1=ctopE('mrow');
    if(b.length){
	m=ctopE('mfrac');
	var ms,ms2,bv;
	mi=ctopE('mi');
	mi.textContent='d';
	var bc=ctopChildren(b[0]);
	for(var j=0;j<bc.length;j++){
	    if(bc[j].localName=='degree'){
		var z=ctopChildren(bc[j])[0];
		if(z.textContent!='1'){
		    ms=ctopE('msup');
		    ms.appendChild(mi);
		    ctopAT(ms,z,0);
		}
	    } else {
		bv=ctopChildren(b[0])[j];
	    }
	}
	mr1.appendChild(ms||mi);
	if(a.length){
	    ctopAT(mr1,a[0],0);
	}
	m.appendChild(mr1);
	mr1=ctopE('mrow');
	ctopAppendTok(mr1,'mi','d');
	if(ms){
	    var ms2=ms.cloneNode(true);
	    ms2.replaceChild(bv,ms2.childNodes[0]); // fix me
	    mr1.appendChild(ms2);
	    //ctopAT(bv,0);
	} else {
	    ctopAT(mr1,bv,0);
	}
	m.appendChild(mr1);
    } else {
	m=ctopE('msup');
	m.appendChild(mr1);
	ctopAT(mr1,a[0],0); 
	ctopAppendTok(m,'mo','\u2032');
    }
    nn.appendChild(m);
}




ctopTapply["partialdiff"] = function(nn,n,f,a,b,q,p)  {
    var m,mi,ms,mr,mo,z;
    if(b.length==0 && a.length==2 && a[0].localName=='list'){
	if(a[1].localName=='lambda') {
	    m=ctopE('mfrac');
            ms=ctopE('msup');
	    ctopAppendTok(ms,'mo','\u2202');
	    ctopAppendTok(ms,'mn',ctopChildren(a[0]).length);
            mr=ctopE('mrow');
	    mr.appendChild(ms);
	    z=ctopChildren(a[1])[ctopChildren(a[1]).length - 1];
	    ctopAT(mr,z,0);
	    m.appendChild(mr);
            mr=ctopE('mrow');
	    var bv=[];
	    var lc=ctopChildren(a[1]);
	    var ls=ctopChildren(a[0]);
	    for(var i=0;i<lc.length;i++){
		if(lc[i].localName=='bvar'){
		    bv[bv.length]=ctopChildren(lc[i])[0];
		}
	    }
	    for(var i=0;i<ls.length;i++){
		ctopAppendTok(mr,'mo','\u2202');
		z=bv[Number(ls[i].textContent)-1];
		ctopAT(mr,z,0);
	    }
	    m.appendChild(mr);
	    nn.appendChild(m);
	} else {
            m=ctopE('mrow');
            ms=ctopE('msub');
	    ctopAppendTok(ms,'mi','D');
	    z=ctopChildren(a[0]);
	    ms.appendChild(ctopMF(z,'',''));
	    m.appendChild(ms);
	    ctopAT(m,a[1],0);
	    nn.appendChild(m);
	}
    } else {
        m=ctopE('mfrac');
        ms=ctopE('msup');
	ctopAppendTok(ms,'mo','\u2202');
        mr=ctopE('mrow');
	if(q.length && q[0].localName=='degree' && ctopChildren(q[0]).length){
            z=ctopChildren(q[0])[0];
	    ctopAT(mr,z,0);
	} else {
	    d=0;
	    var f=false;
	    for(var i=0;i<b.length;i++){
		var z=ctopChildren(b[i]);
		if(z.length==2){
		    for(j=0;j<2;j++){
			if(z[j].localName=='degree'){
			    if(/^\s*\d+\s*$/.test(z[j].textContent)){
				d+=Number(z[j].textContent);
			    } else
				if(f){
				    ctopAppendTok(mr,'mo','+');
				}
			    f=true;
			    var zz=ctopChildren(z[j])[0];
			    ctopAT(mr,zz,0);
			}
		    }
		} else {
		d++;
		}
	    }
	    if(d>0){
		if(f){
		    ctopAppendTok(mr,'mo','+');
		}   
		ctopAppendTok(mr,'mn',d);
	    }
	}
	ms.appendChild(mr);
	mr=ctopE('mrow');
	mr.appendChild(ms);
	if(a.length){
	    ctopAT(mr,a[0],0);
	}
	m.appendChild(mr);
	mr=ctopE('mrow');
	for(var i=0;i<b.length;i++){
	    ctopAppendTok(mr,'mo','\u2202');
	    var z=ctopChildren(b[i]);
		if(z.length==2){
		    for(j=0;j<2;j++){
			if(z[j].localName=='degree'){
			    ms=ctopE('msup');
			    ctopAT(ms,z[1-j],0);
			    zz=ctopChildren(z[j])[0];
			    ctopAT(ms,zz,0);
			    mr.appendChild(ms);
			}
		    }
		} else if(z.length==1) {
		    ctopAT(mr,z[0],0);
		}
	    }
	m.appendChild(mr);
	nn.appendChild(m);
    }
}




ctopT["semantics"] = function(nn,n,p)  {
    var mr = ctopE('mrow');
    var c=ctopChildren(n);
    if(c.length){
	var z =c[0];
	for(var i=0;i<c.length;i++){
            if(c[i].localName=='annotation-xml' && c[i].getAttribute('encoding')=='MathML-Presentation'){
		z=c[i];
		break;
	    }
	}
	ctopAT(mr,z,0);
    }
    nn.appendChild(mr);
}

ctopT["annotation-xml"] = function(nn,n,p)  {
    var mr = ctopE('mrow');
    var c=ctopChildren(n);
    for(var i=0;i<c.length;i++){
	ctopAT(mr,c[i],0);
    }
    nn.appendChild(mr);
}


