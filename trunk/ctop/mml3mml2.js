ctopT["mstack"] = function(nn,n,p) {
    var al=n.getAttribute("stackalign")||"decimalpoint";
    if(al=="decimalpoint") al=n.getAttribute("decimalpoint")||".";
    var mt=ctopE("mtable");
    mt.setAttribute("columnspacing","0em");
    var c=ctopChildren(n);
    for(var i=0;i<c.length;i++){
	if(c[i].localName=="msrow"){
	    var rc=ctopChildren(c[i]);
	    ctopMsrow(mt,rc,Number(c[i].getAttribute("position"))||0,al);
	} else if(c[i].localName=="msline"){
	    var m=ctopE("mtd");
	    m.setAttribute("style","border-style: solid; border-width: 0 0 .15em 0");
	    var mr=ctopE("mtr");
	    mr.appendChild(m);
	    mr.setAttribute("l","0");
	    mr.setAttribute("r","0");
	    mr.setAttribute("class","msline");
	    mt.appendChild(mr);
	} else {
	    var rc = [c[i]];
	    ctopMsrow(mt,rc,0,al);
	}
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
	if(thisc=="msline"){
	    rs[i].firstChild.setAttribute("columnspan",maxl+maxr);
	} else {
	    thisl=Number(rs[i].getAttribute("l"));
	    while(thisl<maxl){
		var mtd=ctopE("mtd");
		rs[i].insertBefore(mtd, rs[i].firstChild);
		thisl++;
	    }
	    thisr=Number(rs[i].getAttribute("r"));
	    while(thisr<maxr){
		var mtd=ctopE("mtd");
		rs[i].appendChild(mtd);
		thisr++;
	    }
	}
    }
    nn.appendChild(mt);
}


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
    mtr.setAttribute("r", (al=='left')?t:t-l);
    nn.appendChild(mtr);
}



	    
	
