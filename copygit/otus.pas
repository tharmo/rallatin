unit otus;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,math;
{
 sortattava (tai indeksoitu?) lista jossa lukuja ja niihin liittyvi‰ arvoja
 low.level muistinsiirtoja

}
var debug:boolean;
VAR oliso:boolean;

type trec=record w,v:word;end;

type twarray=class(tobject)
  arr:array of word;
  len:word;
  rowsums:array of longword;
  sanat:tstringlist;  //procedure sort;
  procedure add(vari,vali:word);
  function cindexof(vari:word):word;
  function newitem(r,l:word):word;
  procedure clear;
  constructor create(le:word;sa:tstringlist);
end;
type tvvmat=class(tobject)  //VAIHDETAAN TƒHƒN
  mx:array of trec; //EIKU TEHDƒƒN VAAN YKSI ISO DATABLOCKKI JOHON VIITATAAN POINTTEREILLA
  rows,cols:word;
  //len:word;  //joka rivin eka trec kertoo sanan ja rivin pituuden?
  sanat:tstringlist;
  onjo:array of byte;//isot
  maxval:longword;
  dotmat:tvvmat;
  procedure karsiklust;
  function rlen(rivi:word):word;
  function tot(rivi:word):longword;
  procedure sortrow(rivi,arlen:word);
  function cadd(RIVI,vari,vali:word):word;
  function cindexof(RIVI,vari:word):word;
  function newitem(RIVI,r,l:word):word;
  function incr(RIVI,vari,vali,ivar:word):string;
  procedure clear;
  procedure list(w:word);
  constructor create(r,c:WORD;sans:tstringlist);
  function getrec(i,j:word):trec;
  procedure setrec(const i,j:word);
  function mply:tvvmat;
  procedure mply2;//:tvvmat;
  procedure savemat(fn:string);
  procedure readmat(fn:string);
  procedure norm;
  Property Items[i,j : word]: trec  Read getrec ; Default; //Write setrec;
  function veivaa:tvvmat;
  function counts:tvvmat;
end;

procedure testsort(var ap: word;len:word);

implementation
uses sort;

procedure tvvmat.savemat(fn:string);
var f:file;
begin
 assign(f,fn);
 rewrite(f,1);
 //writeln('blockerite from:',length(mx)*4,' file',(dotmat.rows+1)*(dotmat.cols+1)*4);
 blockwrite(f,mx[0],length(mx)*4);
 close(f);

 write('didsave');
end;
procedure tvvmat.readmat(fn:string);
var f:file;
begin
 assign(f,fn);
 reset(f,1);
 //writeln('blockerite from:',length(mx)*4,' file',(dotmat.rows+1)*(dotmat.cols+1)*4);
 blockread(f,mx[0],length(mx)*4);
 close(f);

 write('didread');
end;

procedure tvvmat.norm;
var i,j:word;sum:longword;
begin
 exit;
 for i:=1 to rows-1 do
 begin
   sum:=0;
   for j:=1 to cols-1 do sum:=sum+mx[i*cols+j].v;
   mx[i*cols].v:=max(1,sum div 10);
   //write(mx[i*cols].v,' ');
  end;
end;

function tvvmat.veivaa:tvvmat;
var dota,dotb:tvvmat;i:word;lis:string;
begin
 //for i:=1 to rows do list(i);exit;
 dotmat:=tvvmat.create(rows,cols,sanat);
 //dotb:=tvvmat.create(rows,cols);
 //dota:=self;//
 //dota:=
 write(^j,'^mply');//,dotmat=nil);
 //karsiklust; writeln('kertomaton matriisi'); exit;
 mply2;
 dotmat.karsiklust;
 write(^j,'OK1 kerrottu matriisi');//,dotmat=nil);
 exit;
 //dotmat.list(0);
 //dota.dotmat:=tvvmat.create(rows,cols,sanat);
 dotmat.mply2;
 write('ok2');
 dotmat.dotmat.karsiklust;
 //dotb.list(0);
 //dotmat.dotmat.mply2;
 exit;

 norm;
 lis:='';
 for i:=1 to 4 do
 begin
   dota.dotmat:=tvvmat.create(rows,cols,sanat);
   writeln('****************************yksveivi',i);
   try
   dota.mply2;
   except   on e:exception do
     writeln('exception ... why???',e.message, ' ****************************veiviviiras',i,dota.rows);//dotb.list(0);
   end;
   dotb:=dota.dotmat;
   //writeln('dotx.savemat(dot+'+lis+inttostr(i)+'.mat');
   //dotb.savemat('dot'+lis+inttostr(i)+'.mat');

   //dotb.list(0);
   //exit;
   //dota.clear;
   writeln('****************************veivattu',i);
   if i=4 then dotb.karsiklust;
   dota.onjo:=dotb.onjo;
   //setlength(dotb.onjo,0);
   //setlength(dotb.onjo,rows);
 end;
write('didveivi');
//dotmat.list(0);
exit;
//dotmat:=tvvmat.create(vvmat.rows,vvmat.cols);
//dotmat.sanat:=sanat;
//debug:=false;
//ddot:=dotmat.mply;
//ddot.save
end;



function tvvmat.getrec(i,j:word):trec;begin try result:=mx[i*cols+j];except write('-ng');end;end;
procedure tvvmat.setrec(const i,j:word);begin end;

function tvvmat.cindexof(rivi,vari:word):word;
var i,xw:word;
begin
 result:=0;
 //xlen:=mx[cols*rivi].v;
 //write(^j,'?',sanat[vari],':');
 for i:=1 to cols do begin //implement some sort of binary search later
   //write('=',sanat[mx[rivi*cols+i].w]);
        xw:=mx[rivi*cols+i].w;
        if xw=0 then break else if xw=vari then
        begin //write(' ',mx[rivi*cols+i].w);
          result:=i;break;
        end;

 end;

   //if result=0 then  write('-');

end;
function tvvmat.rlen(rivi:word):word;
var i:word;
begin
  //result:=mx[rivi*cols].v;
 result:=cols-1;
 for i:=1 to cols-1 do if mx[rivi*cols+i].w=0 then begin result:=i-1;break;end;
 //write(^j,' -',rivi,':',mx[rivi*cols+1].w, '_',mx[rivi*cols+2].w, '_',mx[rivi*cols+3].w,'...',result);
end;
function tvvmat.tot(rivi:word):longword;
var i:word;
begin
 try
  result:=0;
 for i:=1 to cols-1 do if mx[rivi*cols+i].w=0 then break else result:=result+mx[rivi*cols+i].v;
 if result>64000 then result:=64000;
  except write('nontot',result);raise;end;
end;
procedure tvvmat.clear;
var olen:longword;
begin
  olen:=length(mx);
  setlength(mx,0);
  setlength(mx,olen);
 //len:=0;
end;

type tmutmat=array[0..63] of array[0..63] of integer;  //outs, polish later
var mutuals:tmutmat; turhA:WORD; //outs, polish later
  margs:array[0..63] of word;
  //mist‰ vanhoista uudet ovat saaneet voimansa? vai miten vanhat lkinkkaavat kesken‰‰n? vai uudet? vai kaikki kolme matriisia?

function tvvmat.incr(rivi,vari,vali,ivar:word):string;
  var posi,posix,oval:word;
  begin            //write('?');
    try
      posi:=cindexof(rivi,vari);
       oval:=0;
      if posi=0 then begin posi:=cadd(rivi,vari,min(vali,60000)); end else
      begin
         oval:=mx[rivi*cols+posi].v;
         //write('"');
         mx[rivi*cols+posi].v:=min(60000,oval+vali);
         //result:=('+'+inttostr(mx[rivi*cols+posi].v)+'@'+inttostr(posi)+' ');
       end;
      try
      posix:=iVAR;//ndexof(rivi,ivar);
      if (sanat[VARI]='tyhm‰') or (sanat[VARI]='typer‰') then
             write(^j,'#',sanat[vari],'/',sanat[TURHA],'  @:',posi,'/',VALI);
       except write('eionnaa:',ivar);end;
      inc(mutuals[posi,posix],vali);
        if oval<999 then if oval+vali>=1000 then
        begin OLISO:=TRUE;//write('+',posi,sanat[vari]);
          //dotmat.
          onjo[vari]:=1;
        end;

        //if isot.indexof(pointer(vari))<0 then begin isot.add(pointer(vari));write(' ',isot.count);;end;
      //if posi=0 then result:='-';//('&'+inttostr(mx[rivi*cols+posi].v));
          except write(' fail!+',posi,'_',vari,'_',vali,'=',mx[rivi*cols+posi].v,'//',ivar,'!',SANAT[TURHA]);end;

  end;


function minimulti(var maks:longword):tmutmat;
var i,j,k:word;  ss,s1,s2:longword;
 begin
   writeln(^j^j,'mutmat');
   fillchar(result[0],sizeof(result),0);
   for i:=1 to 63 do
   begin
     try
     for j:=1 to 63 do
       for k:=1 to 63 do  begin
       inc(result[j,k],min(mutuals[i,k],min(mutuals[i,j],mutuals[j,k])));
       //inc(result[j,k],(mutuals[i,j]*mutuals[i,k] div margs[i]));// div margs[k] );
     //write('+',result[j,k]);
       end;
     except write(^j,'fail*',mutuals[i,j],'*', mutuals[j,k],'/i:',  margs[i] ,'*j:', margs[j] )end;
   end;
   maks:=0;
 //for i:=0 to 63 do for j:=0 to 63 do   write(mutuals[i,j],' ');
 exit;
 for j:=1 to 63 do  //experim, very clumsy, etsii suuruusluokkaa
 begin ss:=0;for k:=1 to 63 do inc(ss,1);//result[j,k] div 100);
     if maks<ss then maks:=ss;
 end;
 end;

function isoko(vali,vari,cols:word;mat:pointer):word;
var i,j:word;nmat,xmat:pword; w1,w2:pword;
begin
 result:=0;
 for i:=1 to cols do
    //if word((mat+i*4)^)=0 then// break else
    if word((mat+i*4+2)^)<vali then //test vai pient .. mkorjaa
    begin
      try
      result:=i;
       move(   (mat+i*4)^,  (mat+i*4+4)^,  (cols-i)*4 );
      except writeln(^j'!fail');end;
       move(vari,(mat+i*4)^,2);//^:=vari;
       move(vali,(mat+i*4+2)^,2);//^:=vari;
       //writeln(^j,vari,'.',vali,'=',result,'!!!                  ',word(mat));
       //for j:=1 to 13 do  write(' ',word((mat+j*4)^),'/',word((mat+j*4+2)^));
       break;

    end;// else if i=cols then write('-',vali);// FULL:',word(mat+i*4+2),'/',vali);

end;

procedure tvvmat.karsiklust;
var //s,rs,cs,cc,alku,loppu,i:word; hits:longword;
  maxis,maxis2:array of trec;

  function bigs(w:word;v:word;mm:pword;picks:word):word;
  var j,k:word;p:pointer;pw:pword; //mmax:
   begin
    try
    result:=0;
    //v:=v div 100;
    for j:=0 to picks do
    if (mm+j*2+1)^<v then
    begin
        try
         pw:=mm+j*2;
         //p:= @maxis[j];
         //move(p^,(p+4)^,(63-j)*4);
         move(pw^,(pw+2)^,(picks-j)*4);
         pw^:=word(w);
        (pw+1)^:=word(v);
         except write('NOMAX: ',j,sanat[maxis[j].w],maxis[j].v);end;
         //maxis[j].v:=v;
         //maxis[j].w:=w;
         result:=j;
         break;
    end;
    except writeln('failbig');end;
   end;
var i,j,v1,j2,i2,posi:word;rsum,csum,usum:longword;onjot:tlist;
begin
 writeln('karsi');
 setlength(maxis,128);
 setlength(maxis2,128);
  for i:=2 to rows-1 do     //sortataan painon mukaan
  begin
   rsum:=0;
   if mx[i*cols].w=0 then continue;
   //write(sanat[i],'..clust ');
   // if v1<mx[s*cols+2].v then;
   for j:=2 to 20 do        //1 vai 0 ... k‰ki kukkuu
      if mx[i*cols+j].w=0 then break else
      if mx[i*cols+j].w=i then begin write('&%');continue;end else
       //if mx[s*cols+i1].v*3<vi1 then break else
        inc(rsum,mx[i*cols+j].v div 100);
   if rsum<10 then continue;
   bigs(i,rsum,@maxis[0],128);//,maxis);
  end;

  for i:=991 to 63 do          //listataan clusteriparien yhdeteisest sanat
  // if i in [4,29,31] then
  begin
     write(^j^j,i,'::',sanat[mx[maxis[i].w*cols].w],maxis[i].v,': ');
     for j:=1 to cols do
         if mx[maxis[i].w*cols+j].w>1 then
       write(sanat[mx[maxis[i].w*cols+j].w],mx[maxis[i].w*cols+j].v div 100,' ');
  end;
  write('******************\\\\\\\\\\\\');
  onjot:=tlist.create;
  for i:=1 to 127 do
  //if i in [4,29,31] then
  begin
     try
     csum:=0;  //sum of words  shared with previous
     usum:=0;  //sum of previously unused
     write(^j^j,'||',i,' ',maxis[i].w ,sanat[mx[maxis[i].w*cols+1].w],maxis[i].v,': ');
     for i2:=1 to 127 do if i=i2 then write('') else // begin onjot.add(pointer(mx[maxis[i].w].w*cols));end else
      //if i2 in [4,29,31] then
      if maxis[i].w=mx[maxis[i].w*cols+i2].w then continue else
      begin
        rsum:=0;
        if mx[maxis[i].w*cols+i2].w=0 then break;
        for j:=1 to 63 do
          if onjot.indexof(pointer(mx[maxis[i].w*cols+j].w))>0 then  write('') else
            begin
            //inc(usum,mx[maxis[i].w*cols+j].v);
            for j2:=1 to 63 do
              if mx[maxis[i].w*cols+j].w=mx[maxis[i2].w*cols+j2].w then begin write('');
              inc(rsum,min(mx[maxis[i].w*cols+j].v,mx[maxis[i2].w*cols+j2].v));
            end;
        end;
        //csum:=csum+rsum;
        //write('+',rsum);
        if rsum>3000 then    write(^j,' [',i2,sanat[mx[maxis[i2].w*cols].w],'/',rsum ,'] ');
      end;
      csum:=0;usum:=0;
      for j:=1 to 62 do if  onjot.indexof(pointer(mx[maxis[i].w*cols+j].w))<0 then inc(usum,mx[maxis[i].w*cols+j].v) else inc(csum,mx[maxis[i].w*cols+j].v);
      writeln(^j' === shared;',csum,' /unique: ',usum div 1);
      for j:=1 to 62 do if  onjot.indexof(pointer(mx[maxis[i].w*cols+j].w))<0 then
               //if mx[maxis[i].w*cols+j].v>300 then //if mx[maxis[i].w*cols+j].w=300 then
      if usum>5000 then
       begin onjot.add(pointer(mx[maxis[i].w*cols+j].w));
         write('+',sanat[integer(onjot[onjot.count-1])],mx[maxis[i].w*cols+j].v);
       end else write('.');
       if usum>5000 then posi:=bigs(mx[maxis[i].w*cols].w,usum div 1,@maxis2[0],40);
       write('[[[',posi,sanat[mx[maxis[i].w*cols].w],']]]');
     except write('!?!');end;
  end;
  write('////////******************!');
  for i:=0 to 63 do begin try
    write(^j^j,sanat[maxis2[i].w],maxis2[i].v,':');//list(maxis2[i].w);
    for j:=1 to 63 do if mx[maxis2[i].w*cols+j].w=0 then break else write(' ',sanat[mx[maxis2[i].w*cols+j].w]);
    except write('nono');end;
  end;
end;
procedure tvvmat.mply2;//:tvvmat;
var cs,cc:word;eidotmat:tvvmat; posi,arlen,s,i1,i2,j1,j2,ii,lim,vi1,v12,vj1,vj2,wi1,k:word;
 hits, vtot:longword;
  rs,ri1,ri2,rj1,rj2:^trec;
isomat:array of word;
isosca,isotasx,isotbs:array of trec;
rst:string;
begin
 //try
 lim:=18;
 setlength(isomat,rows);
 setlength(isosca,cols);
 //setlength(isotas,cols);
 dotmat:=tvvmat.create(rows,cols,sanat);
 write('^mply2:',rows,'/',cols);

 //for s:=1 to 10 do begin isosca[s].v:=100-s*10;isosca[s].w:=s;end;
 //isoko(4263,2,cols,@isosca[0]);
 //isoko(2743,3,cols,@isosca[0]);
 //isoko(5,997,cols,@isosca[0]);
 write('onksioso');
 for s:=2 to rows-2 do
 begin
  //if s mod 1000=2 then
  try
     // if mx[s*cols].v>200 then continue;
//    if mx[s*cols].v<25000 then continue;
//  posi:=isoko(mx[s*cols].v,s,cols,@isotas[0]);
  //if mx[s*cols].v>3000 then posi:=1 else posi:=0;
  except writeln('failiso',s);end;
   fillchar(isomat[0],length(isomat)*2,0);

   //continue;
   rs:=@mx[s*cols];
   vtot:=0;
   //write(' ',s);
   //continue;
   for i1:=1 to lim-1 do
   begin
     ri1:=@mx[rs[i1].w*cols];
     Vi1:=rs[i1].v;
     if vi1<200 then continue;
     wi1:=rs[i1].w;
     //write(^j,'   *',i1,sanat[rs[i1].w],ri1[i1].w,':');

     for i2:=1 to i1-1 do //lim-1 do
     begin
       if rs[i2].v<100 then continue; // vi1 on aina pienempi, olivat sortattuja
       ri2:=@mx[rs[i2].w*cols];
       //write(^j,'       ',i2,sanat[rs[i2].w]);
       for j1:=1 to lim-1 do
       begin
         rj1:=@mx[ri1[j1].w*cols];
         Vj1:=min(ri1[i1].v,vi1);
         if vj1<100 then continue;
         for j2:=1 to lim-1 do
         begin
           try
           if ri2[j2].w<>ri1[j1].w then continue;
           vj2:=min(vj1,ri2[j2].v);//rj2:=@mx[ri2[j2].w*cols];
           if vj2<10 then continue;
           //write(^j,sanat[r1s[i1].w],'/',sanat[rs[i2].w], '::',sanat[ri1[j1].w]);
           inc(vtot,vj2);
           inc(isomat[ri1[j1].w], vj2 div 10);
           except write(' XXX:',isomat[ri1[j1].w],sanat[ri2[j1].w],'/',min(vj1,ri2[j2].v));end;
         end;

       end;
     end;
   end;
   //write(^j,'----',vtot,'-');
   //if posi=0 then continue;
   //if vtot<500000 then
   fillchar(isosca[0],4*cols,0);//length(isosca)*2,0);
   if s mod 1000=0 then write(sanat[s],' ');//^j^j,posi,' ',vtot,'/',dotmat.mx[s*cols].v,'=',vtot div (dotmat.mx[s*cols].v+1),'   ',sanat[s],':',rst);
  // continue;
   //setlength(isosca,0);  setlength(isosca,cols);
   for i1:=1 to rows-1 do
   if isomat[i1]<100 then continue else
   for j1:=1 to cols-2 do
      if isosca[j1].v<isomat[i1] then
      begin
        try
         move(isosca[j1],isosca[j1+1],(cols-j1-2)*4);
         isosca[j1].v:=isomat[i1];
         isosca[j1].w:=i1;
         //write('  ',j1,sanat[isosca[j1].w],isosca[j1].v);
         //for k:=1 to 10 do if isosca[k].w=0 then break else write('/',sanat[isosca[k].w],isosca[k].v);
         //writeln('!!!');
         break;

         except writeln(^j'!fail');end;
      end;
     vtot:=0;
     rst:='';
      for i1:=1 to cols-1 do if isosca[i1].w<1 then break else
      begin //inc(vtot,isosca[i1].v div 10);
        rst:=rst+(' '+sanat[isosca[i1].w]+inttostr(isosca[i1].v div 1));
        vtot:=vtot+isosca[i1].v;
       // for k:=1 to cols do if mx[s*cols+k].w=isosca[i1].w then write('+',k);
      end;
      //write(^j,sanat[s],'///');//,sanat[rs[i1].w]);//, '::',sanat[ri1[j1].w]);
      for i1:=1 to cols-1 do dotmat.mx[s*cols+i1].v:=isosca[i1].v;
      for i1:=1 to cols-1 do dotmat.mx[s*cols+i1].w:=isosca[i1].w;
      dotmat.mx[s*cols].w:=s;
      dotmat.mx[s*cols].v:=vtot;
      //continue;                            ;
//     if //((vtot>3*(mx[s*cols].v+1))) //paino korostunut kerrottaessa
//      (5*vtot<(mx[s*cols].v+1))      // ei korostunut
      //then
//      posi:=isoko(mx[s*cols].v,s,cols,@isotas[0]);
      //if posi<0 then
 end;
 writeln('veivivalmis.. loppun asti mentiin');
 //finally //result:=dotmat;     end;
 //dotmat.karsiklust;
end;
function tvvmat.mply:tvvmat;
var rs,cs,cc:word;eidotmat:tvvmat; arlen,s,i1,i2,j1,j2,ii,lim,hits,vtot:word;
  //acoi1,acoi2,acoj1,acoj2:word;
  xrst,arst,asana:string;
  ps,pi1,pi2,pj1,pj2,p0, //pointeri yhteen sanaan rivill‰
    wrs,wri1,wri2:pword; //pointeri sanan riviin
  vi1,vi2,vj1,vj2:word; //correlations
  //si1,si2,vj1,vj2:word; //correlations
   clusw2:tstringlist;
   inf,outf:file;
   clusn:tlist;clusw:tstringlist;
   toti:word;
   maks:longword;
   multidot:tmutmat;
   isomat:array of word;
begin
 try
  dotmat:=tvvmat.create(rows,cols,sanat);
  setlength(isomat,rows);
     //isot.clear;
     //clusn:=tlist.create; clusw:=tstringlist.create;//clusw.loadfromfile('clusws.lst'); clusw2:=tstringlist.create;//clusw.loadfromfile('clusws2.lst');
     //clusw.addstrings(clusw2);
     //for s:=0 to clusw.count-1 do clusn.add(pointer(strtointdef(clusw[s],0)));
     //for s:=0 to clusn.count-1 do write(sanat[integer(pointer(clusn[s]))],' ');
 //dotmat.sanat:=sanat;
 //setlength(multidot,);
   write(^j^j'onjot:',length(dotmat.mx)); for i1:=1 to rows-1 do if onjo[i1]=1 then write(sanat[i1],'+ ');
 lim:=16;
    //for s:=2 to rows-1 do write(' ',mx[s*cols].w,'/',s);
 //for s:=2 to rows-1 do//kaikkii sanojen lista
 for s:=1 to rows do//aasi
    begin
//               if onjo[s]=1 then begin dotmat.onjo[pi2^]:=1;continue;end;
      write('+?');
       fillchar(mutuals[0], sizeof(mutuals),0);
       //writeln('aaaaaaaaaaaaaa',s,'_',sanat.count);
      //if oliso then begin
      //for i2:=1 to ROWS-1 do if dotmat.isot[i2]=1 then write('>',sanat[i2]);     end;
      oliso:=fALSE; //debuggausta varten, n‰ytet‰‰n muutoksert
        //if s<>2 then if s<>20205 then continue;
       if s mod 1000=0 then write(s,' ');
       //if debug then list(s);
       // dotmat.clear;
       //fillchar(mutuals[0],64*4,0);
       //rst:=(^j^j+'**********************'+^j+sanat[s]+':;');
       wrs:=@mx[s*cols];  //s-sanan coco-listan alku
      //writeln(^j^j,'...',sanat[s],mx[s*cols].v);
       //toti:=(wrs+1)^ div 100;
      // if toti<1 then continue;
      //if tot(s)>10000 then continue;
       //rst:='';
       try
       for i1:=1 to lim do  //yksi s:n cooc
       begin
         pi1:=@(wrs+i1*2)^; //2,4 i-sanan i's cooc-sana  (joka toinen on sanan numero, joka toinen paino) 3,5,7,...
         try
         if i1=0 then vi1:=100 else vi1:=1000*(wrs+i1*2+1)^ div max((wrs+1)^,1); //3,5,7 s-sanan i.'n coocn arvo
         except         write(' fail_',(wrs+i1*2+1)^,'_',max((wrs+1)^,1)); end;
         //write(' ',(wrs+i1*2+1)^,'_',vi1);
         //continue;
                 //if clusn.indexof(pointer(pi1^))>=0 then continue;//begin write('');continue;end;
         if vi1<1 then continue;
                  //if pi1^=s then continue;
                  //rst:=rst+(^j+'     '+sanat[pi1^]);
                  //wri1:=@mx[pi2^*cols];  //ptr
          if pi1^=0 then break;
                // write('#',sanat[pi1^]);

          wri1:=@mx[pi1^*cols];  //ptr
                //wri1:=@mx[pi1^*cols];  //ptr
          for i2:=1 to lim do  //toinen s-sanan cooc
          begin
               //continue;
               try
               hits:=0;
               pi2:=@(wrs+i2*2)^; //i-sanan i's cooc
               if pi2^=0 then break;
               //write('?',length(onjo));
               //if clusn.indexof(pointer(pi2^))>=0 then begin continue;write(',');continue;end;
//               if onjo[pi2^]=1 then begin dotmat.onjo[pi2^]:=1;continue;end;
               // **********************************************
               //    if pi2^=s then continue;
                if (pi2^=pi1^) then continue;  //voi harkita otetaanko mukaan
                   //write('//',sanat[pi2^]);
               vi2:=min(vi1,(wrs+i2*2+1)^ div 10);
               if vi2<1 then continue;
               wri2:=@mx[pi2^*cols];  //ptr
               except write('""""',length(dotmat.onjo),'/',pi2^);end;
               for j1:=1 to lim do  //
               begin  //i-sanan ekan coocin eka coocci
                 try
                 pj1:=wri1+j1*2;  //
//****************                 if onjo[pj1^]=1 then begin dotmat.onjo[pj1^]:=1;continue;end;
                   //if clusn.indexof(pointer(pj1^))>=0 then begin write('');continue;end;
                 //write('.',sanat[pj1^],(wri1+j1*2+1)^);
                 if pj1^=0 then continue;
      //           if pj1^=s then continue;  //s-sana itse , mit‰ tehd‰?
                 //if j1=0 then vj1:=vi2 else ????
                 vj1:=min(vi2,(wri1+j1*2+1)^ div 10);
                 if vj1<1 then continue;
                 asana:=sanat[pj1^];
                 except write('J1');end;
                 for j2:=1 to lim do  //
                 begin  //i-sanan ekan coocin eka coocci
                   pj2:=@(wri2+j2*2)^;  //
                   if pj2^=0 then break;
 //                  if vj2<10 then continue;
                   if pj1^=pj2^ THEN
                   begin
                    vj2:=min(vi2,(wri2+j2*2+1)^ div 10);
                    if sanat[pj2^]='tyhm‰' then write(^j'###',sanat[pi1^],vj2);
                    if vj2<1 then continue;
                      try
                      //if j2=0 then vj2:=vj1 else
//                     if hits=0 then rst:=rst+^j+'XXX  '+sanat[pi1^]+'/'+sanat[pi2^]+': ';hits:=0;
                     //rst:=rst+'_'+asana+inttostr(round(sqrt(vj2)));
//                     if j1=0 then rst:=rst+' '+'****'+inttostr(vj2);
                     //if vj2<4 then continue;
                     inc(hits);

                     //dotmat.incr(1,pj2^,1);//max(1,min(vi1,min(vi2,min(vj1,vj2))) div 10));
                     try
                       TURHA:=PI1^;
                     dotmat.incr(s,pj2^,50*vj2,i1);//toti);//;round(sqrt(vj2)));
                     except  write(' //',toti,'\',dotmat[s,pj2^].v);end;
                      except  write('J2:',vi1,'.',vi2,'.',vj1,'.',vj2,'.');raise;end;
                   end;
                 end;
               end;
          end;  //i2
       end; //i1
       write('\?');
       dotmat.mx[s*cols].w:=s;
       dotmat.mx[s*cols].v:=dotmat.tot(s);
       except writeln(^j,'failtot:-',sanat[s]);raise;end;
       arlen:=dotmat.rlen(s);
       try
       list(s);
       DOTMAT.list(s);
       writeln(^j'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
       for i1:=0 to 63 do begin vi1:=dotmat[s,i1].w;margs[i1]:=dotmat.mx[vi1*cols].v;if margs[i1]=0 then write('NOVAL:',sanat[vi1])end;
       //for i1:=0 to 63 do begin vi1:=dotmat[s,i1].w;write(^j,sanat[vi1],' ###',margs[i1]);//,  mx[mx[s*cols]w].w]*cols+mx[s*cols
        //end;     //  exit;
       multidot:=minimulti(maks);      //kertoo viel‰ globaali-muuttujan mutuals
       for i1:=1 to 63 do
       begin
          write(^j,'*',sanat[dotmat[s,i1].w]);
          for i2:=1 to 63 do
          if multidot[i1,i2]>0 then
          begin
             //if multidot[i1,i2]*3>maks then
             write('  |',sanat[dotmat[s,i2].w],' ',multidot[i1,i2]);
            //   if multidot[
          end;
       end;
       //readln;
       //dotmat.sortrow(s,arlen);
       except writeln('fyucksort');end;
          //if hits>0 then      dotmat.list(s);
          // if dotmat.mx[s*cols].v>20000 then begin write(^j'####',sanat[s]);dotmat.list(s);readln;end;
           //debug:=true;//false;//true;
          //if  dotmat.len(s)>5 then//debug then
      //if  dotmat[s,2].v>25 then//debug then
    end;  //yksi sana
  exit;
    result:=dotmat;
   //dotmat.mply;
   finally

     writeln(^j^j'counts:');
     //dotmAT.counts;
     writeln(^j^j'isoja:');
     //for i1:=1 to rows-1 do if dotmat.onjo[i1]=1 then begin write(sanat[i1],':');onjo.[i1]:=1;end;
     for i1:=1 to rows-1 do if onjo[i1]=1 then begin dotmat.onjo.[i1]:=1;end;
     //clusn.free;    clusw.free;     clusw2.free;
     //setlength(onjo,0);
     //onjo:=isot;
   end;
end;
function valcompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
 result:=longword(pointer(list.objects[index2]))-longword(pointer(list.objects[index1]));
end;

function tvvmat.counts:tvvmat;
var ocs:array of longword;i,j,avar,va1,maks:longword;clusws:tstringlist;top20:tstringlist;
begin
 try
 writeln(^j^j'docounts:');
 setlength(ocs,rows);
 top20:=tstringlist.create;
 for i:=1 to rows do
 begin
   //va1:=mx[i*cols+1].v div 10;
   for j:=1 to 40 do
   if mx[i*cols+j].v<500 then break else
   begin
       avar:=mx[i*cols+j].w;
       if avar=0  then break;
       inc(ocs[avar]);
       if ocs[avar]>1 then  write(' ',ocs[avar]);
    end;
 end;
 maks:=0;
 writeln('gotocs');
 for i:=1 to rows-1 do if ocs[i]>1 then
 begin if maks<ocs[i] then begin write(^j,'+++',sanat[i],ocs[i]);maks:=ocs[i];end;
 top20.addobject(sanat[i],tobject(pointer(ocs[i])));
 end;
 writeln('gottops');
  if top20.count>2 then top20.customsort(@valcompare);
  for i:=1 to top20.Count-1 do write(' <' ,top20[i]);
 //write('xxxxxxxxxxxxxxxxx ',sanat.count,'OK???');
 //for i:=1 to rows-1 do  write(' ',ocs[i]);

 //for i:=1 to rows-1 do if ocs[i]>100 then clusws.add(inttostr(format('[%10d]',i)));//write(' ',sanat[i],ocs[i]);
 //clusws.savetofile('clusws2.lst');
 //for i:=writeln(clusws.commatext);
 top20.free;
 setlength(ocs,0);
 writeln(^j^j'didcounts:');
 except writeln('**************************************************');end;
end;

procedure tvvmat.list(w:word);
var rs,cs,cc,alku,loppu,i:word; hits:longword;maxis:array of trec;


  function bigs(w:word;v:longword):word;
  var j,k:word;p:pointer;
   begin
    try
    //v:=v div 100;
    //write('#',sanat[w],v,' ');
    for j:=1 to 80 do
    if maxis[j].v<v then
    begin
         try
         p:=@maxis[j];
         move(p^,(p+4)^,(99-j)*4);
         maxis[j].v:=v;
         maxis[j].w:=w;
         //for k:=1 to 3 do
         //if j=1 then
         //write(^j,sanat[w],v,'>',j);
         except write('NOMAX: ',j,sanat[maxis[j].w],maxis[j].v);end;
         break;
    end;
    except writeln('failbig');end;
   end;
  var w1,w2,pre:word;
begin
   setlength(maxis,100);
   if w=0 then begin alku:=1;loppu:=rows;end else begin alku:=w;loppu:=w;end;

    //if alku=loppu then
    //writeln(^j,'list ',rows,'*',cols,' ',alku,'...',loppu);
    writeln;
    for rs:=alku to loppu do
    begin
      hits:=1;
      cc:=mx[rs*cols].v;
      //if cc<100 then continue;
      if mx[rs*cols].v<1 then continue;
      if alku=loppu then
      write(^j,' ',sanat[rs],'::','(',cc,')');
      //if len(rs)>30 then
      for cs:=1 to cols-1 do //min(len(rs),cols) do
      begin
        //if cs>9 then break;
        try
        if mx[rs*cols+cs].w=0 then break;
        //if mx[rs*cols+cs].v>pre then
        pre:=mx[rs*cols+cs].v;
        //inc(hits,mx[rs*cols+cs].v);
        //if mx[rs*cols+cs].v=1000 then
        inc(hits,mx[rs*cols+cs].v);
        if alku=loppu then
        write(' |',sanat[mx[rs*cols+cs].w],':',pre);//,'[',indexof(rs,mx[rs*cols+cs].w));
        except write('failmx:',rs,'/',cs,':',mx[rs*cols+cs].w);end;
      end;
      write(' ==',hits);
      try
      //if alku=loppu then
      bigs(rs,hits);
      except writeln('nobigdeal:',rs,':',hits); end;
    end;
    if alku=loppu then exit;
    writeln('-----------------------');
  //exit;
 //setlength(mx,0);
 //setlength(arr,64);
 //len:=0;
 //writeln(^j^j);
 for rs:=1 to 70 do
 begin
    w1:=maxis[rs].w;
    write(^j^j,rs,'**',sanat[w1],maxis[rs].v,'/',mx[w1*cols].v,'::');
      for cs:=1 to 20 do
          //if mx[w1*cols+cs].w=0 then continue else
           write(' ',sanat[mx[w1*cols+cs].w],':',mx[w1*cols+cs].v);//,'[',indexof(rs,mx[rs*cols+cs].w));

 end;
end;
function tvvmat.cadd(rivi,vari,vali:word):word;
var posi,len,i:word;
begin
    try
    result:=0;
    //if mx[rivi*cols].v>=cols then exit; //liikaa seuraajia (yleisyysj‰rjestys, ei haittaa kun harvinaiset j‰‰ pois)
    //if mx[rivi*cols].w=0 then exit;
    posi:=rlen(rivi)+1;//mx[rivi*cols].v+1;           //0
    result:=posi;
    if posi>=cols then exit;//begin if vali>50 then exit;//write('-!',sanat[vari],vali);exit;end; //ei pit‰is tapahtua
    //write('+',sanat[vARI]);
     //write(posi);
    //inc(mx[rivi*cols].v,vali);
    mx[rivi*cols+posi].w:=vari;
    mx[rivi*cols+posi].v:=vali;
    if maxval<mx[rivi*cols+posi].v then begin
    maxval:=mx[rivi*cols+posi].v;
    //writeln(' (',posi,'\',sanat[rivi],':',sanat[vari],'=',vali, '/',maxval,')' );
    end;
    //if mx[rivi*cols+posi].v>500 then begin write('!',sanat[vari]);isot[vari]:=1;end;
    except write('failadd:',rivi,':',vari,'=',vali,'/',mx[rivi*cols].v,' ',cols);end;
end;

function Compareval(d1,d2:pointer): integer;
var    p1,p2:pword;
  i1 : word;//(d1^);
  i2 : word;// absolute d2;
  //i1 : trec absolute d1;
  //i2 : trec absolute d2;
  //ii:word absolute d2;
begin
    p1:=@(d1+2)^;p2:=@(d2+2)^;
 i1:=word((p1)^);
 i2:=word((p2)^);
    try
  if i1=i2 then Result:=0
  else if i1<i2 then Result:=-1
  else Result:=+1;
  // write('  [?',word((p1-1)^),'.',i1,' ',word((p2-1)^),'.',i2,'=',result,']');
    except on e:exception do begin write(^j,'???eivittu');;end;end;

end;

procedure tvvmat.Sortrow(rivi,arlen:word);
VAR AP:POINTER;
begin
  try
  //write(^j,'sort1:',rivi,'/fucking',arlen,':',rlen(rivi));
    AP:=@mx[rivi*cols];
 AnySort(AP,arlen, 4, @Compareval);
 except write(^j,'///sort2:',arlen,' ');    end;
end;

procedure testsort(var ap:word;len:word);
VAR APp:POINTER;i:word;pw:pword;
begin
 app:=@ap;
 // write(^j,'sort1:',ap,' ',len,':');
  try
//    AP:=@mx[rivi*cols+1];
 AnySort(APP,len, 4, @Compareval);
 //write(^j,'XXX:');
 //for i:=0 to 2 do begin pw:=(app+(4*i));write(pw^,':',(pw+1)^,' ');end;

 except write(^j,'///sort2:',len,' ');    end;
end;



function tvvmat.newitem(rivi,r,l:word):word;
begin
    inc(mx[rivi*cols].v);
    mx[rivi*cols+mx[rivi*cols].v].w:=r;
    mx[rivi*cols+mx[rivi*cols].v].v:=l;
end;

constructor tvvmat.create(R,C:WORd;sans:tstringlist);
begin
   ROWS:=R;cols:=c;
  setlength(mx,(R+1)*(C+1));
  maxval:=0;
  setlength(onjo,rows);
  sanat:=sans;
  //setlength(isot,rows);
  //isot:=tlist.create;
  //onjolist.
  //len:=0;
  //add(1,1);
end;


procedure twarray.add(vari,vali:word);
var i:word;
begin
end;

function twarray.cindexof(vari:word):word;
var i:word;
begin
end;
function twarray.newitem(r,l:word):word;
var i:word;
begin
end;

procedure twarray.clear;
var i:word;
begin
end;

constructor twarray.create(le:word;sa:tstringlist);
var i:word;
begin
 setlength(arr,le);
 sanat:=sa;
end;

end.

