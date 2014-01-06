ctopT["mstack"] = function(nn,n,p) {
    var al=n.getAttribute("stackalign")||"decimalpoint";
    if(al=="decimalpoint") al=n.getAttribute("decimalpoint")||".";
    var mt=ctopE("mtable");
    mt.setAttribute("columnspacing","0em");
    var c=ctopChildren(n);
    if(n.localName=="mlongdiv" && c.length>2){
	var divisor=c[0].cloneNode(true);
	var result =c[1].cloneNode(true);
	var dividend =c[2].cloneNode(true);
	var ms=ctopE("msrow");
	var mr=ctopE("mrow");
	var mr2=ctopE("mrow");
	var lds=n.getAttribute("longdivstyle");
	if(lds=='left/\\right') {
	    mr2.appendChild(divisor);
	    ms.appendChild(mr2);
	    ctopAppendTok(ms,"mo","/");
	    ms.appendChild(dividend);
	    ctopAppendTok(ms,"mo","\\");
	    mr.appendChild(result);
	    ms.appendChild(mr);
	    c[0]=null;
	    c[1]=null;
	    ms.setAttribute("position",-2);
	    c[2]=ms;
	} else if(lds=='left)(right') {
	    mr2.appendChild(divisor);
	    ms.appendChild(mr2);
	    ctopAppendTok(ms,"mo",")");
	    ms.appendChild(dividend);
	    ctopAppendTok(ms,"mo","(");
	    mr.appendChild(result);
	    ms.appendChild(mr);
	    c[0]=null;
	    c[1]=null;
	    ms.setAttribute("position",-2);
	    c[2]=ms;
	} else if(lds=='right=right') {
	    ms.appendChild(dividend);
	    ctopAppendTok(ms,"mo",":");
	    mr2.appendChild(divisor);
	    ctopAppendTok(mr2,"mo","=");
	    mr2.appendChild(result);
	    ms.appendChild(mr2);
	    c[0]=null;
	    c[1]=null;
	    ms.setAttribute("position",-2);
	    c[2]=ms;
	} else {
	    mr.appendChild(divisor);
	    ms.appendChild(mr);
	    ctopAppendTok(ms,"mo",")");
	    ms.appendChild(dividend);
	    var ml=ctopE("msline");
	    ml.setAttribute("length",(dividend.textContent.trim()).length);
	    c[0]=result;
	    c[1]=ml;
	    c[2]=ms;
	}	
	ctopMsgroup(mt,c,0,0,al);
    } else {
	ctopMsgroup(mt,c,0,0,al);
    }
    var rs=ctopChildren(mt);
    var maxl=0, maxr=0,thisl,thisr,thisc;
    for(var i=0;i<rs.length;i++){
	thisl=Number(rs[i].getAttribute("l"));
	if(thisl>maxl) maxl=thisl;
	thisr=Number(rs[i].getAttribute("r"));
	if(thisr>maxr) maxr=thisr;
    }
    for(var i=0;i<rs.length;i++){
	thisc=rs[i].getAttribute("class");
	thisl=Number(rs[i].getAttribute("l"));
	thisr=Number(rs[i].getAttribute("r"));
	if(thisc=="msline" && thisl==0 && thisr==0){
	    rs[i].firstChild.setAttribute("columnspan",maxl+maxr);
	} else {
	    while(thisl<maxl){
		var mtd=ctopE("mtd");
//		ctopAppendTok(mtd,'mi','`'); // debug only
		rs[i].insertBefore(mtd, rs[i].firstChild);
		thisl++;
	    }
	    while(thisr<maxr){
		var mtd=ctopE("mtd");
//		ctopAppendTok(mtd,'mi','`'); // debug only
		rs[i].appendChild(mtd);
		thisr++;
	    }
	}
    }
    nn.appendChild(mt);
}

ctopT["mlongdiv"] = ctopT["mstack"];

function ctopMsrow (nn,c,psn,al){
    var mtr=ctopE("mtr");
    var l=-1;
    var t=0;
    for(var i=0;i<c.length;i++){
	if(c[i].localName=="mn"){
	    var ds=c[i].textContent.trim();
	    for(var j=0;j<ds.length;j++){
		var mtd=ctopE("mtd");
		var mn=ctopE("mn");
		mn.textContent=ds.charAt(j);
		t++
		if((l<0&&ds.charAt(j)==al)){
		    l=t-1;
		} else if(al=='right'){
		    l=t;
		}		    
	    
		mtd.appendChild(mn);
		mtr.appendChild(mtd);
	    }
	} else {
	    var mtd=ctopE("mtd");
	    t++
	    if(al=='right'){
		l=t;
	    }		    
	    if(c[i].localName!='none'){
		ctopAT(mtd,c[i],0);
	    }
	    mtr.appendChild(mtd);
	}
    }
    if(l<0&& al.length==1){
	l=t;
    }		    
    mtr.setAttribute("l", psn+l);
    mtr.setAttribute("r", ((al=='left')?t:t-l)- psn);
    nn.appendChild(mtr);
}


function ctopMsgroup(nn,c,gp,gs,al) {
    for(var i=0;i<c.length;i++){
	if(c[i]!=null){
	if(c[i].localName=="msrow"){
	    var rc=ctopChildren(c[i]);
	    ctopMsrow(nn,rc,(Number(c[i].getAttribute("position"))||0)+gp + i*gs,al);
	} else if(c[i].localName=="mscarries"){
// fix me
	} else if(c[i].localName=="msline"){
	    var m=ctopE("mtd");
	    m.setAttribute("style","border-style: solid; border-width: 0 0 .15em 0");
	    var len=Number(c[i].getAttribute("length"))||0;
	    var psn = (Number(c[i].getAttribute("position"))||0)+gp + i*gs;
	    m.setAttribute("columnspan",len);
	    var mr=ctopE("mtr");
	    mr.appendChild(m);
	    if(len==0){
		mr.setAttribute("l","0");
		mr.setAttribute("r","0");
	    } else if(al=='left') {
		mr.setAttribute("l", psn);
		mr.setAttribute("r",len - psn);
	    } else {
		mr.setAttribute("l",len + psn);
		mr.setAttribute("r",len - psn);
	    }
	    mr.setAttribute("class","msline");
	    nn.appendChild(mr);
	} else if(c[i].localName=="msgroup"){
	    ctopMsgroup(nn,
			ctopChildren(c[i]),
			(Number(c[i].getAttribute("position"))||0)+gp+i*gs,
			(Number(c[i].getAttribute("shift"))||0),
			al
		       );
        } else{
	    var rc = [c[i]];
	    ctopMsrow(nn,rc,gp+i*gs,al);
	}
	}
    }
}


	    
	
