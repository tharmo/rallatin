unit otus;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,math,twmat;
{
 sortattava (tai indeksoitu?) lista jossa lukuja ja niihin liittyvi‰ arvoja
 low.level muistinsiirtoja

}
var debug:boolean;
VAR oliso:boolean;

//type twv=record w,v:word;end;

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
type tocmat=class(tobject)  //VAIHDETAAN TƒHƒN
    wrds:array of tintlist;
end;
type tvvmat=class(tobject)  //VAIHDETAAN TƒHƒN
  mx:array of twv; //EIKU TEHDƒƒN VAAN YKSI ISO DATABLOCKKI JOHON VIITATAAN POINTTEREILLA
  rows,cols:word;
  //len:word;  //joka rivin eka twv kertoo sanan ja rivin pituuden?
  sanat:tstringlist;
  onjo:array of byte;//isot
  maxval:longword;
  dotmat:tvvmat;
  clusters: array of twv;static;
  ccount:word;static;
  procedure karsiklust(limi:word);
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
  function getwv(i,j:word):twv;
  procedure setwv(const i,j:word);
  function mply:tvvmat;
  procedure mply2;//:tvvmat;
  procedure wikimply;//:tvvmat;
  procedure savemat(fn:string);
  procedure readmat(fn:string);
  procedure norm;
  Property Items[i,j : word]: twv  Read getwv ; Default; //Write setwv;
  function veivaa:tvvmat;
  function counts:tvvmat;
  procedure sanatklus;
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

procedure tvvmat.sanatklus;
var dota,dotb:tvvmat;i,j,ii,iii,jj,jjj,c,incls:word;lis:string;  sum:longword;aii,ajj:twv;
   bigit:array[0..7] of twv;
   clusw,clusw2:array of word; //muutetaan twviski myˆs;
   cluslens,cluslens2,cluscors:array of word;//twv;
   cocs:array of word; wclus,wclus2:array of word;
   function bb(w,v:word):word;
   var p:word;
   begin
     try
     result:=0;if v=0 then exit;
     if bigit[7].v>=v then exit;
     //write('+');
     //write(^j,v,':');     for p:=1 to 7 do write('_',bigit[p].w);
     for p:=1 to 7 do if v>bigit[p].v then begin result:=p;break; end;
     if result=0 then exit;
     if result>7 then exit;
     try
     if result<7 then move(bigit[result].w,bigit[result+1].w,(7-result)*4);
     except write('fail:',v,'=',result,' '); end;
     bigit[result].w:=w;
     bigit[result].v:=v;
     //write(' =',result);//,':',w,'_',v,' ');
     except write('failBB',v,'=',result,' ');end;
   end;
   procedure addw(w,clu:word);
   begin
   end;
var ival,iival,jval,kompis,i2,j2,f1,f2,s1,s2:integer; acor,amin,tries:longword;   apust:string;
begin
  writeln('xxxxxxxxxxxxxxxxxx');
    //for j:=1 to ccount do  begin   write(' ',clusters[j*64].v);end;//  for jj:=0 to 2 do   write(' ,',sanat[clusters[j*64+jj].w],clusters[j*64+jj].v); end;
  //for i:=1 to rows-1 do  if mx[i*cols+2].w<1 then list(i);exit;
  setlength(cluscors,ccount*ccount);
  setlength(wclus,rows);
  setlength(wclus2,rows);
  setlength(cluslens,ccount+1);
  setlength(clusw,(ccount+1)*128);
  setlength(cluslens2,ccount+1);
  setlength(clusw2,(ccount+1)*128);
  {for i:=1 to ccount-1 do    //korrelaatiot klustereiden v‰lill‰
  begin
    write(^j^j,sanat[clusters[i*64].w]);
    //for j:=1 to ccount-1 do if clusters[i*64].w=0 then break else  write('.');
    for j:=1 to ccount-1 do //if i<>j then
    begin
     try
      acor:=0;
      apust:=' ';
      tries:=0;
     except write('(?)');end;
      for i2:=1 to 30 do  if clusters[i*64+i2].w>0 then
      for j2:=1 to 30 do if clusters[j*64+j2].w>0 then
      begin
        amin:=min(clusters[i*64+i].v,clusters[j*64+j2].v);
        //if amin<10 then  continue;
        s1:=clusters[i*64+i2].w;
        s2:=clusters[j*64+j2].w;
        for f1:=1 to 20 do if mx[s1*cols+f1].w>0 then
        for f2:=1 to 20 do if mx[s2*cols+f2].w>0 then
        //try
         if mx[s1*cols+f1].w=mx[s2*cols+f2].w then
         begin
           //inc(acor,min(amin,min(mx[s1*cols+f1].v,mx[s2*cols+f2].v)) div 10);
           inc(acor);
           //if pos(' '+sanat[mx[s2*cols+f2].w]+' ',apust)=0 then
           //apust:=apust+' '+sanat[mx[s2*cols+f2].w]+' ';//+inttostr(min(mx[s1*cols+f1].v,mx[s2*cols+f2].v));
           //if pos(' '+sanat[clusters[i*64+i2].w]+'.'+sanat[clusters[j*64+j2].w]+' ',apust)=0 then
           //apust:=apust+' '+sanat[clusters[i*64+i2].w]+'.'+sanat[clusters[j*64+j2].w]+' ';//+inttostr(min(mx[s1*cols+f1].v,mx[s2*cols+f2].v));
         end else inc(tries);
         //WRITE('.');
        //except write('(?',mx[s1*cols+f1].w,' ',mx[s2*cols+f2].w,')',tries);end;
      end;
      iF ACOR>0 THEN write(' ',round(10000*(acor/TRIES)));
      end;
      if acor>0 then write(^j^j,sanat[clusters[i*64].w],sanat[clusters[j*64].w],'.',acor,':',apust);
      write('==',ACOR,'/'tries);
    end;
       //if clusters[i*64+i2].w= clusters[j*64+j2].w then
       //write(^j,sanat[clusters[i*64].w],sanat[clusters[j*64].w],'.',sanat[clusters[i*64+i2].w]);
  exit;}

  //incls:=0; for j:=1 to ccount-1 do for jj:=1 to 63 do if clusters[j*64+jj].w=0 then break else inc(incls);  writeln('inclusts:',incls);exit;
  for i:=1 to rows do
  begin
      if mx[i*cols+1].v<10 then begin write(''); continue; end;
      setlength(cocs,(1+ccount)*(1+ccount));
      //if onjo[i]<>0 then    continue;
      fillchar(bigit[0],4*8,0);
      for j:=2 to ccount do
      begin
         try
          sum:=0;
          if clusters[j*64].w<1 then break;
          if 1=0 then if clusters[j*64].w=i then
          begin ;//inc(sum,clusters[j*64].v);//write(' =',sum);
           continue;
          end;     //debuggausta.. etsdi ne klusterit joihin sana itse kuuluu
          if clusters[j*64].w<1 then break;
          //write('+');
          //jval:=(clusters[j*64].v div 100)+100;  // nollasolun vali = valien summa...  500 ..10000 nyt 5..1000
          for ii:=1 to 30 do  if mx[I*cols+ii].w=0 then break else
          begin  //sanan kaikki komppikset
            begin
              kompis:=mx[I*cols+ii].w;
              //if 1=0 then if clusters[j*64].w=kompis then        begin      inc(sum,clusters[j*64].v);     continue;      end;     //debuggausta.. etsdi ne klusterit joihin sana itse kuuluu
              try
              for jj:=1 to 30 do if clusters[j*64+jj].w=0 then break else
              begin
                if mx[I*cols+ii].w=clusters[j*64+jj].w then
                begin
                //inc(sum,min(mx[I*cols+ii].v,clusters[j*64+jj].v));
                inc(sum,5);//clusters[j*64+jj].v);
                 end;
                for iii:=1 to 15 do if mx[kompis*cols+iii].w=0 then break else //i:n kompiksen kompis
                  if mx[kompis*cols+iii].w=clusters[j*64+jj].w then
                  begin
                   inc(sum);//,clusters[j*64+jj].v div 2);
                        // write('~');
                  end;
              end;
              except writeln(^j,'fail:isoksmen');end;
            end;
          end;
         finally
         //sum:=sum div 10;
          //if sum>20 then   // bb(j,sum)=1 then
           TRY bb(j,1000*sum div (clusters[j*64].v+1));
           EXCEPT WRITE('failsortrow:',ccount,'?',sum,'/',clusters[j*64].v+1,'#',1000*sum div (clusters[j*64].v+1));end;//=1 then
          //write(' /',sum,'.',clusters[j*64].v);
         end;
      end;
 //if i mod 500=0 then
     //try
      //for c:=2 to 7 do if bigit[c].v>bigit[c-1].v then begin writeln('errororfer');readln;end;

    // write(^j,sanat[i],'/',SANAT[CLUSters[BIGIT[1].W*64].w],
     // BIGIT[1].v,'/',SANAT[CLUSters[BIGIT[2].W*64].w],
     // BIGIT[2].v,'!');
     //except write('-----');end;
     //write('x');
     TRY
     if bigit[1].w<1 then continue;
      if bigit[1].v<300 then continue;
     wclus[i]:=bigit[1].W;
     if bigit[1].v>1500  then
       write(sanat[i],'/',sanat[clusters[bigit[1].w*64].w],bigit[1].v,' ');
     //write('#',bigit[1].v);
      if bigit[2].v<100 then continue;
      if bigit[1].v<bigit[2].v*2 then wclus2[i]:=bigit[2].W;
      EXCEPT write('XXXXXXXXXXX');END;
  end;
   for i:=1 to rows-1 do
   begin try

    if wclus[i]=0 then continue; //write(wclus[i],'.',cluslens[wclus[i]],' ');
    if wclus[i]=wclus2[i] then    write('+?');
    if wclus[i]>=ccount then continue;
    if cluslens[wclus[i]]>127 then begin write(^j,'FULL:',sanat[clusters[wclus[i]*64].w]);CONTINUE;end;
    inc(cluslens[wclus[i]]);
    clusw[wclus[i]*128+cluslens[WCLUS[i]]]:=i;
    write(^j,';',sanat[i],'>',sanat[clusters[wclus[i]*64].w],'/');
    //addtoc(
    //write(wclus[i],'.',cluslens[wclus[i]],' ');
    if wclus2[i]=0 then continue; //write(wclus[i],'.',cluslens[wclus[i]],' ');
    //if wclus2[i]<wclus[0 then continue; //write(wclus[i],'.',cluslens[wclus[i]],' ');
    if wclus2[i]>=ccount then continue;
    inc(cluslens2[wclus2[i]]);
    clusw2[wclus2[i]*128+cluslens2[WCLUS2[i]]]:=i;
   except WRITE('!!!faILLIST',I,'/',WCLUS[i],'!!!',cluslens[WCLUS[i]],' ');END;
   end;
   write('aaaaaaa');
   //for i:=1 to ccount-1 do WRITE(' ',cluslens[i]);
   for i:=1 to ccount-1 do
   begin
       try
      write(^j^j,sanat[clusters[i*64].w],clusters[i*64].v,':; ');
      IF CLUSLENS[I]<=1 THEN continue;
      write(^j^j);
      for j:=1 to cluslens[i] do
       if clusw[i*128+j]>0 then write(' ',sanat[clusw[i*128+j]]);
        except writeln('fail!?!XXXXXX',i);end;
       write(^j,'::  ');
      try
      for j:=1 to cluslens2[i] do
       if clusw2[i*128+j]=0 then break else  write(' ',sanat[clusw2[i*128+j]]);
      writeln(^j,'-----------------------------------');
      for j:=1 to ccount do
       if clusters[i*64+j].w=0 then break else  write(' ',sanat[clusters[i*64+j].w]);
      except writeln('fail!?!',i,'/',j,'"',cluslens[i],'#',clusw2[i*128+j],'#');end;
      writeln(' (.',cluslens[i],'/',clusters[i*64].v,')');
   end;
   exit;
   for i:=1 to ccount do
   begin
     if cocs[i*ccount+i]>1 then
     write(^j,i,sanat[clusters[i*64].w],clusters[i*64].v,': ');
    for j:=1 to ccount do if cocs[i*ccount+j]>1 then
     write('  ',sanat[clusters[j*64].w],cocs[i*ccount+j]);
   end;
end;

function tvvmat.veivaa:tvvmat;
var ORIGx,dota,dotb:tvvmat;i,j,ii,jj,c,cc,oldc:word;lis:string;  jval,sum:longword;
begin
  writeln('ihmevoeivi');
 //for i:=1 to rows do
 //list(0); exit;
 // mply2;exit;
 //dotmat:=tvvmat.create(rows,cols,sanat);
 //ORIG:=tvvmat.create(rows,cols,sanat);
 //ORIG.readmat('dotx.mat');
 setlength(clusters,512*64);  ccount:=0;
 //dotb:=tvvmat.create(rows,cols);
 //dota:=self;//
 //dota:=
 if 1=1 then
 begin
   write(^j^j,'^mply1');//,dotmat=nil);
   //karsiklust; writeln('kertomaton matriisi'); exit;
   mply2;
   write(^j^j^j,'^did mply2');//,dotmat=nil);
   //dotmat.savemat('dotx'+'.mat');
   dotmat.savemat('synx'+'.mat');
   writeln('SAVED');
   //dotmat.list(0);
   exit;
   mply2;
   write(^j^j^j,'^did mply2');//,dotmat=nil);
   dotmat.dotmat.savemat('synxx'+'.mat');
   //dotmat.dotmat.savemat('dotxx'+'.mat');
   writeln('SAVED');
   exit;
  end;
 //dotmat.karsiklust(10000);
 //dotmat.readmat('dotx'+'.mat');

// if 1=2 then
 // skaalaus meni mplyss‰ pieleen, ruma korjaus;
 oldc:=0;
 for i:=1 to 40 do
 begin
    c:=0;
    //write('karsi');
    karsiklust(1);
    for j:=1 to rows-1 do if onjo[j]>0  then inc(c);
    for ii:=oldc+1 to ccount do
    begin
      write(^j,^j,sanat[clusters[ii*64].w],' ',clusters[ii*64].v,' ');  //lieko nollasolu laskettu?
      for j:=1 to 64 do if clusters[ii*64+j].w=0 then begin write(' ==',j-1);break; end else
        write(sanat[clusters[ii*64+j].w],' ',clusters[ii*64+j].v,' ');  //lieko nollasolu laskettu?
    end;
    if oldc=ccount then break;
    oldc:=ccount;
    //write('karsittu');
    writeln(^j,c,'********** ',i,' ******************************** ',ccount,^j,'::');
    if ccount>511 then break;
 end;
 writeln(^j^j,c,'CLUSTERS ',ccount,'::',c,^j);
 exit;
 for i:=1 to ccount do
 begin jval:=0;
   try
   write(^j^j,i,' ',sanat[clusters[i*64].w],' ',clusters[i*64].v,': ');  //lieko nollasolu laskettu?
   for j:=1 to 64 do
   begin
      if clusters[i*64+j].w=0 then break;
      if clusters[i*64+j].v=0 then break;
     write(sanat[clusters[i*64+j].w],' ',clusters[i*64+j].v,' ');  //lieko nollasolu laskettu?
     if j<10 then inc(jval,clusters[i*64+j].v+1);
     //write(sanat[clusters[i*64+j].w],' ');
     {for jj:=1 to 64 do  if mx[66*cols+jj].w=0 then continue
     else if mx[66*cols+jj].w=clusters[i*64+j].w then}
     //write('%',sanat[mx[66*cols+jj].w],sanat[clusters[i*64].w]);

   end;
   write(' ===',jval div 1);//, ' / ',clusters[i*32].v div 100);
   clusters[i*64].v:=jval div 100;
   except write('failval:',jval,'+',sanat[clusters[i*64+j].w]);end;
 end;
 exit;
 //readln;
 sanatklus;
 //list(0);
 exit;
 dota:=tvvmat.create(rows,cols,sanat);
 dota.readmat('dot0'+'.mat');
    dota.sanatklus; exit;
 for i:=1 to ccount do
 if clusters[i*32].w=0 then break else
 begin
  WRITELN(sanat[clusters[i*32].w],'::');
     for j:=0 to 32 do if clusters[i*32+j].w=0 then break else write(' ',sanat[clusters[i*32+j].w],clusters[i*32+j].v);
  writeln(^j);
 end;



 exit;
 dotmat.dotmat.onjo:=dotmat.onjo;
 dotmat.karsiklust(500);
 dotmat.onjo:=dotmat.dotmat.onjo;
 //FILLCHAR(DOTMAT.DOTMAT[0],COLS*ROWS*4,0);
 dotmat.karsiklust(5);
 dotmat.onjo:=dotmat.dotmat.onjo;
 dotmat.karsiklust(5);
 write(^j,'OK1 kerrottu matriisi');//,dotmat=nil);

 exit;
 //dotmat.list(0);
 //dota.dotmat:=tvvmat.create(rows,cols,sanat);
 //dotmat.mply2;
 write('ok2');
 dotmat.dotmat.karsiklust(5000);
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
   if i=4 then dotb.karsiklust(5000);
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



function tvvmat.getwv(i,j:word):twv;begin try result:=mx[i*cols+j];except write('-ng');end;end;
procedure tvvmat.setwv(const i,j:word);begin end;

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

procedure tvvmat.karsiklust(limi:word);
var //s,rs,cs,cc,alku,loppu,i:word; hits:longword;
  maxis,maxis2:array of twv;

  function bigs(w:word;v:word;mm:pword;picks:word):word;
  var j,k:word;pw:pword; //mmax:
   begin
    try
    //v:=min(65000,v);
    result:=0;
    //v:=v div 100;
    for j:=1 to picks-1 do
    if (mm+j*2+1)^<v then
    begin
        try
         pw:=mm+(j*2);
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
var i,j,v1,j2,i2,c,posi,cluscount,counted:word;rsum,CCSUM,usum:longword;newoli:array of byte;//onjot:tlist;
  bval:longword;
begin
 //write('try');
 setlength(newoli,rows);
 for i:=1 to rows-1 do newoli[i]:=onjo[i];
 setlength(maxis,256);
 setlength(maxis2,128);
 for i:=2 to rows-1 do     //sortataan painon mukaan
 iF OnJO[i]=0 then
  begin
   //write(' ',sanat[i]);
   rsum:=0;c:=0;
   if mx[i*cols].w=0 then continue;
   // if v1<mx[s*cols+2].v then;
   for j:=2 to min(50,62) do        //kuinka tiiviit‰/kuinka isoja klustereita halutaan
   if mx[i*cols+j].w=0 then break else
   //if mx[i*cols+j].w<>i then
   begin       // TRY dec(rsum,2+mx[i*cols+j].v div 10);;continue;EXCEPT WRITE('');END;    end else //HJOSKUS MENEE PIELEEN L. MIINUSMER
    try
      if onjo[mx[i*cols+j].w]<1 then  //t‰n kierroksen uusia ei viel huomioida... vanhoista penalttii?
      begin //if mx[s*cols+i1].v*3<vi1 then break else
      try
        inc(rsum,mx[i*cols+j].v div 1);
        inc(c);
        except WRITE('FAILSORT');end;
       end;
    except WRITE('FAILSORT2');end;
    //if limi>50000 then   begin  // if rsum<10 then continue;   end;
    //if c<4 then continue;
    //if posi=1 then
    //write(sanat[maxis[posi].w],i,'.',rsum,' ');
   end;
   posi:=bigs(i,rsum div 100,@maxis[0],128);//,maxis);
  end;
  //for i:=1 to 12 do if maxis[i].w>0 then write(sanat[mx[maxis[i].w*cols].w],maxis[i].v,' ');
  for i:=1 to 127 do
  //if i in [4,29,31] then
  begin
     ccsum:=0;  //sum of words  shared with previous
     usum:=0;  //sum of previously unused
      if newoli[maxis[i].w]>0 then continue; //NYT UUDETKIN HUOMIOIDAAN
      ccsum:=0;usum:=0;
      for j:=1 to 62 do if  NEWOLI[mx[maxis[i].w*cols+j].w]<1 then inc(usum,round(log2(mx[maxis[i].w*cols+j].v+1))) else inc(ccsum,mx[maxis[i].w*cols+j].v);
      //if usum<limi then continue;
      //if usum>limi then
      try
      //write(' ',usum);
      if maxis[i].w=0 then posi:=0 else
      posi:=bigs(mx[maxis[i].w*cols].w,usum div 100,@maxis2[0],30);
      //if onjo[mx[maxis[i].w*cols+j].w]<1 then
     except write('fail///',sanat[mx[maxis[i].w*cols].w],':',usum,' ');end;
     try
      bval:=mx[maxis[i+2].w*cols+2].v;
      counted:=0;
      for j:=1 to 63 do if mx[maxis[i].w*cols+j].w=0 then BREAK ELSE //30 isointa merkataan k‰ytetyiksi
      begin
        if mx[maxis[i].w*cols+j].v<bval div 5 then break else //mik‰ ois hyv‰ kynnysarvo?
        begin
          inc(NEWOLI[mx[maxis[i].w*cols+j].w]);
          counted:=j;
        end;// else break;
      end;// else write('.');
     except write('fail !?!');end;
  end;
  //write('++++++++++++++++++');
  for i:=0 to 8 do     //n parasta klusteria kun p‰‰llekk‰isyydet poistettu pienemmist‰
  begin
    try
    if maxis2[i].w=0 then continue;
    bval:=mx[maxis2[i].w*cols+3].v;
    ccsum:=0;
    c:=0;
    inc(ccount);  //aloitetaan ykkˆsest
    if ccount>511 then exit;
    except write('nono1');end;
    try
    //write(^j^j,'??',bval,sanat[maxis2[i].w],maxis2[i].v,' (',counted,'):');//list(maxis2[i].w);
    for j:=1 to 63 do if mx[maxis2[i].w*cols+j].w=0 then break else  //mit‰ laitetaan mukaan klusteriin
    if onjo[mx[maxis2[i].w*cols+j].w]=0 then
    //if (10*mx[maxis2[i].w*cols+j].v>bval) or (c<5)  then
    begin
      inc(c);
      if (10*mx[maxis2[i].w*cols+j].v>bval) then inc(ONJO[mx[maxis2[i].w*cols+j].w]) else break;
      //csum:=0;
      //write(' .',sanat[mx[maxis2[i].w*cols+j].w],mx[maxis2[i].w*cols+j].v div 1);
      //if c>15 then break;
      //begin
      clusters[ccount*64+c].w:=mx[maxis2[i].w*cols+j].w;
      clusters[ccount*64+c].v:=mx[maxis2[i].w*cols+j].v div 1;
      inc(ccsum,mx[maxis2[i].w*cols+j].v div 1);
      //if c>40 then break;
      //end;
    end;
    clusters[ccount*64].w:=mx[maxis2[i].w*cols].w;
    clusters[ccount*64].v:=min(65000,ccsum div 100);
    //write('===!',ccsum);
  except write(^j'nono:',ccsum,sanat[mx[maxis2[i].w*cols+j].w],mx[maxis2[i].w*cols+j].v div 1);end;
  end;
  writeln('DID');
end;

{for i2:=1 to 255 do //if ii2 then //write('') else // begin onjot.add(pointer(mx[maxis[i].w].w*cols));end else
begin
   rsum:=0;
   if i=i2 then continue;
   //if mx[maxis[i].w*cols+i2].w=0 then break;
   for j:=1 to 63 do
       //if onjot.indexof(pointer(mx[maxis[i].w*cols+j].w))>0 then  write('') else
//      if onjo[mx[maxis[i].w*cols+j].w]=0 then  //write('.') else
   begin
       //inc(usum,mx[maxis[i].w*cols+j].v);
      for j2:=1 to 63 do
      if mx[maxis[i].w*cols+j].w=mx[maxis[i2].w*cols+j2].w then
      begin //write('?');
            inc(rsum,min(mx[maxis[i].w*cols+j].v,mx[maxis[i2].w*cols+j2].v));
      end;
   end;
   //csum:=csum+rsum;
   //write('!',rsum);
   if rsum>5000 then  write(' [',i,' ',i2,sanat[maxis[i2].w],'/',rsum ,'] ');
 end;}

procedure tvvmat.wikimply;//:tvvmat;
var lista:tintlist;i,j,k,j2,sanam,hits,misses:word;
  sanaj,sanak,sanaj2:twv;oli,toti:word;  //mik‰ er0?
begin
  // sana sanalta kˆyd‰‰n kaikkien sananyymien kaikki sanayymit ja sortataan sitten esiintymien m‰‰r‰n mukaan
   lista:=tintlist.create;    ///nyt viel‰ vakimittainen, staattisella arraylla, Yhden sanan kumppanilista
   writeln('********!*********::');
   for i:=2 to rows do
   begin
    if sanat[i]<>'kuolema' then continue;
     write(^j'X*******************************************:',sanat[i],mx[i*cols].v,'::');
     toti:=0;
     if 1=0 then
     for j:=1 to cols do if mx[i*cols+j].w=0 then break else
     begin sanaj:=mx[i*cols+j];inc(toti,mx[i*cols+j].v);write(^j^j,' ',sanat[sanaj.w],'\',sanaj.v,': ');
     for j2:=1 to cols do if mx[sanaj.w*cols+j2].w=0 then break else write(' ',sanat[mx[sanaj.w*cols+j2].w],'\',mx[sanaj.w*cols+j2].v,': ');

     end;
     writeln(^j'=',toti);
     lista.clear;
      try

     for j:=1 to cols do      //kaikki sanam kumppanit
     begin
       sanaj:=mx[i*cols+j];
       if sanaj.w=0 then break;
       //sanam:=(1000*sanaj.v) div toti;
       write(^j'  +',sanat[sanaj.w],sanaj.v);//,'/',sanam,'!  ');
       //lista.incr(sana.w,sana.v);

       for j2:=1 to cols do //sanan muut kumppanit
       begin //if j2>16 then break;
         try
         if j2=j then continue;
         sanaj2:=mx[i*cols+j2];
         if sanaj2.w=0 then break;
         //write(^j,'    ',sanat[sanaj2.w]);
         // sanam:=min(sanam,(1000*sanaj.v) div mx[sanaj2.w*cols].v);
         for k:=1 to cols do //esiintyykˆ toka kumppani ekan kumppani kumppanilistassa
         begin //if k>16 then break;
           sanak:=mx[sanaj2.w*cols+k]; //if k<10 then write('(',sanat[sanak.w],')');
           if sanak.w=0 then break;
           if sanak.w<>sanaj.w then continue;
           sanam:=min(sanam,(1000*sanak.v) div mx[sanaj.w*cols].v);
           hits:=0;
           //if sanaj2.w<>sanak.w then continue;
             //sanan kumppani esiintyy toisen kumppanin listassa
             //if sanat[sanak.w]='ura' then
             write('  [',sanaj.v,'>',sanat[sanak.w],sanak.v,'<',sanat[sanaj2.w],sanaj2.v,']');//,'/',mx[sanaj2.w*cols].v,' ');
             sanam:=min(sanam,(1000*sanaj2.v) div mx[i*cols].v);
             //sanam:=min(sanam,sanaj2.v);
             //write('+',sanat[sanak.w],min(sanak.v,sanaj.v));
             //if lista.len<256 then
             try
             inc(hits,sanam);//sanam); eieiei pit‰is kasvattaa vain jos toi sana oli noteerattava
             //if sanat[sanak.w]='kaviaari' then writeln(^j,'@@@',sanat[i],' ',sanat[sanaj.w],' ',sanat[sanak.w],' ',sanat[sanak2.w],' ',hits);
             //lista.incr(sanak2.w,sanam);//sanam);
             except writeln(^j'\\\NONo:',sanat[i],j2,'.',lista.len,'_',hits);end;
           end;
         //write('+',sanat[sanak.w],min(sanak.v,sanaj.v));
         //if sanat[sanak.w]='ura' then writeln(^j,'###',sanat[i],' ',sanat[sanaj.w],' ',sanat[sanak.w],' ',hits);
         except write(^j,'nonono:',hits);end;

         lista.incr(sanak.w,hits);
       end;
     end;
    except writeln(^j^j'nomply***');end;
    continue;
    try
     lista.sortv;
     for j:=1 to lista.len do
       write('_',sanat[lista.items[j].w],lista.items[j].v);
     writeln;
     exit;
     for j:=1 to lista.len do
     begin
       sanaj:=lista.items[j];oli:=0;
       if lista.items[j].w=0 then continue;
       if lista.items[j].v<1 then continue;
       misses:=0;hits:=0;
       write(^j'  !',sanat[sanaj.w],sanaj.v);
       for k:=1 to cols do //moniko tark sanan kumppaneista
       begin
          sanak:=mx[sanaj.w*cols+k];
          if sanak.w=0 then break;
          write(^j'    ??',sanat[sanak.w],sanak.v);
          oli:=0;
          {for j2:=1 to lista.len do if j=j2 then continue else
           begin if sanak.w=lista.items[j2].w then
            begin write('+',lista.items[j2].v,' ******');oli:=sanaj.v;break;end;
           end;//onko kump kump itse kump
          if oli>0 then inc(hits,oli div 100) else inc(misses,sanaj.v div 100);//mx[sanak.w*cols].v+1);
          }
          for j2:=1 to cols do //if j=j2 then continue else
           begin sanaj2:=mx[i*cols+j2];
              if sanaj2.w=0 then break;
             //write('-',sanat[sanaj2.w]);
             if sanak.w=sanaj2.w then
             begin write('+',lista.items[j2].v,' ******');oli:=sanaj.v;break;end;
           end;//onko kump kump itse kump
          if oli>0 then inc(hits,oli div 100) else inc(misses,sanaj.v div 100);//mx[sanak.w*cols].v+1);
        end;
        write(^j'                                       ___',sanat[lista.items[j].w],'.',hits,'.',misses,'/');
     end;
    except writeln('***');end;
    writeln('------------------------------');
  end;

end;
procedure tvvmat.mply2;//:tvvmat;
var cs,cc:word;eidotmat:tvvmat; posi,arlen,s,i1,i2,j1,j2,ii,lim,vi1,v12,vj1,vj2,wi1,k,hits:integer;
  vms,vmi1,vmi2,vmj1,vmj2  //marginaaleihin suhteutetut arvot
  :longint;
 marg1,marg2, vtot:longword;

  rs,ri1,ri2,rj1,rj2:^twv;
isomat:array of word;
isosca,isotasx,isotbs:array of twv;
rst,rst2:string;      rl:tlist;

  procedure _list;
   var i,j:word;  rs1,RS2,RS3:string;oliw,oliv:integer;
  begin
    RS1:='';RS2:='';RS3:='';rl.clear;hits:=0;
    for i:=1 to 62 do if isosca[i].w=0 then continue else
    begin   //kaikki dotmatriisin korrelaatit
      OLIW:=-1;
      for j:=0 to 62 do if mx[s*cols+j].w<1 then continue else if isosca[i].w=mx[s*cols+j].w then begin if j=62 then write(^j'FULL');oliw:=j;break;end;// else write('');
      // oliko myˆs alkmatriisissa
       //if oliw>=0 then begin rs1:=rs1+' '+sanat[isosca[i].w]+inttostr(isosca[i].v)+'/'+inttostr(mx[s*cols+oliw].v)+'/'
       //+inttostr(mx[isosca[i].w*cols].v);
       // oliko myˆs alkmatriisissa
        if oliw>=0 then begin rs1:=rs1+'  '+sanat[isosca[i].w]+inttostr(isosca[i].v)+'/'+ inttostr(mx[s*cols+oliw].v);
       end else begin inc(hits);rs2:=rs2+' '+sanat[isosca[i].w]+inttostr(isosca[i].v);end;//*100 div mx[isosca[i].w*cols].v) ;end;
       //if oliw=0 then write('.',);
    end;
    //write(^j^j,s,':::',sanat[s],';;  ');
    for i:=1 to 62 do if mx[s*cols+i].w<1 then continue else
    begin    //etsi mx:st‰ ne jotka eiv‰t tulleet mukaan..
      oliw:=-1;
      for j:=0 to 62 do if isosca[j].w=0 then continue else if isosca[j].w=mx[s*cols+i].w then begin oliw:=j;break;end;
      if oliw<0 then begin rl.add(pointer(mx[s*cols+i].w));rs3:=rs3+' '+sanat[mx[s*cols+i].w]+inttostr(mx[s*cols+i].v)+'/'+inttostr(mx[mx[s*cols+i].w*cols].v);end;
        //write(oliw);
    end;
    //if s=20524 then for i:=0 to 20 do write('* ',sanat[isosca[i].w]+inttostr(isosca[i].v)+'/'+inttostr(mx[s*cols+i].v) );
    //if rs3+rs2<>'' then
    begin
    write(^j,sanat[s],'=',rs1,']',^j'+',rs2,^j'-',rs3,':',^j);
    //writeln('MX:');    for i:=0 to 62 do if mx[s*cols+i].w>0 then write('~',i,sanat[mx[s*cols+i].w],mx[s*cols+i].v);
    //writeln('Mult:');       for i:=0 to 62 do if isosca[i].w>0 then write(' ^',i,sanat[isosca[i].w],isosca[i].v);
  // if rs3<>'' then readln;
    exit;
    //writeln('***',
    if rl.count>0 then
    for i:=0 to rl.count-1 do begin
    write(^j,'    ---',sanat[mx[integer(pointer(rl[i]))*cols].w],':');
     for j:=0 to 62 do if mx[integer(pointer(rl[i]))*cols+j].w<1 then continue else
     begin          //if mx[integer(pointer(rl[i]))*cols+j].w=s then continue;

        write(' ',j,sanat[mx[integer(pointer(rl[i]))*cols+j].w],'',mx[integer(pointer(rl[i]))*cols+j].v,'');
         if pos(sanat[mx[integer(pointer(rl[i]))*cols+j].w],rs2)>0 then write('**  ');
         if pos(sanat[mx[integer(pointer(rl[i]))*cols+j].w],rs1)>0 then write('&&');
     end;
    end;write(^j,'');
    //for j:=0 to 15 do if isosca[j].w<1 then continue else write(' ',sanat[isosca[j].w]);
    end;
  end;
  var asan,ahit,targ:word;    vmin:longword;  a:word;  d,olijo:boolean;
begin
  write(^j,'try:',paramstr(2));
  a:=0;
  {for s:=1 to rows-1 do
  begin
   for i1:=1 to 62 do
   begin
     asan:=mx[s*cols+i1].w;
     if asan=0 then continue;
     ahit:=0;
     for j1:=1 to 60 do if mx[asan*cols+j1].w=s then begin ahit:=j1;break;end;
     if ahit=0 then write(^j,s,sanat[s]+',',sanat[asan]);

   end;
  end;
  write('didid');
  exit;}
  d:=paramstr(2)<>'';
 rl:=tlist.create;
 //try
 lim:=62;
 setlength(isomat,rows);
 setlength(isosca,cols);
 //setlength(isotas,cols);
 dotmat:=tvvmat.create(rows,cols,sanat);
  if paramstr(2)<>'' then targ:=sanat.IndexOf(paramstr(2)) else targ:=0;
 if d then write(^j'^mply2:',rows,'/',cols,'@',targ,paramstr(2));
 for s:=1 to rows-2 do
 //for s:=1222 to 1222 do
 begin
  if targ<>0 then if s<>targ then continue;
   fillchar(isomat[0],length(isomat)*2,0);
   //if (sanat[s]<>'siekailematon') and (sanat[s]<>'julkea') then continue;
   //continue;
   rs:=@mx[s*cols];
   vms:=rs[0].v;
  if d then  write(^j^j'***',sanat[s],vms,':  ');
   vtot:=0;
   write(^j,' ',sanat[s]);
   //continue;
   for i1:=1 to lim do
   begin
     ri1:=@mx[rs[i1].w*cols];
     if rs[i1].w=0 then break;
   //   IF ri1[0].w=s THEN begin writeln(^j'"""');continue;end;
     vmi1:=1000*rs[i1].v div vms;
     //vmi1:=rs[i1].v;
  if d then write(^j^j' &&',sanat[mx[s*cols+i1].w],'/',vmi1,': ');
     //if vi1<50 then continue;
   //  continue;
     wi1:=rs[i1].w;
     if rs[i1].w=s then continue;
     for i2:=1 to //i1-1 do //
      lim-1 do
     begin
       olijo:=false;
       //Vi1:=rs[i1].v;  // vi1 on aina pienempi, olivat sortattuja
       if i1=i2 then begin continue;inc(isomat[rs[i2].w], rs[i2].v*2);continue; end;
       if rs[i2].w<1 then break;
       //if i2=i1 then continue;                         if onjo[rs[i2].w]=1 then break;
       ri2:=@mx[rs[i2].w*cols];
       IF ri1[0].w=s THEN break;
       vmi2:=1000*rs[i2].v div vms;
       //vmi2:=rs[i2].v;
       vmin:=min(vmi1,vmi2);
       try
       //vmi2:=5000*ri2[0].v div (vms+1);
       //vmi2:=ri2[0].v;
       rst:='';
       except write(^j,'fail ',i2,sanat[s],sanat[rs[i2].w],(5000*ri2[0].v),'/',(vms),^j);end;
       for j1:=1 to lim do // j1=0 or j1=1 ???
       begin
         //if s=17 then if i1=35 then if i2=34 then write('?',i2);//,',',mx[rs[i2].w*cols].w,',',mx[rs[i2].w*cols].v,' ',i1);
         //if s=17 then if i1=35 then if i2=34 then write(^j,'XX:',i1,',',mx[rs[i2].w*cols].w,',',mx[rs[i2].w*cols].v,' ',j1,'!');
         IF ri1[j1].w=s THEN continue;
         IF ri1[j1].w=0 THEN break;
         IF ri1[j1].w=s THEN CONTINUE;  //pit‰is olla symmetrisia

         //rj1:=@mx[ri1[j1].w*cols];
         //vmj1:=min(vmi1,5000*ri1[j1].v div ri1[0].v);
         vmj1:=(1000*ri1[j1].v div (ri1[0].v+1));
         //vmj1:=(ri1[j1].v);
         vmin:=min(vmj1,vmin);
         //Vj1:=min(vi1,1000*ri1[i1+j1].v div );
         if vmj1<1 then break;
         for j2:=1 to lim-1 do
         if ri2[j2].w=0 then continue else
         begin
           if ri1[j1].w<>ri2[j2].w then continue;
           if j1=0 then if i2=0 then continue;
           //vj2:=min(vj1,ri2[j2].v) div 100;//rj2:=@mx[ri2[j2].w*cols];
           try
           // vj2:=MIN(1000,round(sqrt(vj2+1)));
           //vj2:=min(vj1,ri2[j2].v);//rj2:=@mx[ri2[j2].w*cols];
           vmj2:=1000*ri2[j2].v div (ri2[0].v+1);
           vmin:=min(vmj1,min(vmj2,min(vmi1,vmi2)));
           rst:=rst+(' +'+sanat[ri1[j1].w]+'\'+inttostr(vmin));//+'/'+inttostr(vmi1)+'/'+inttostr(vmi2)+'/'+inttostr(vmj1)+'/'+inttostr(vmj2));    //    continue;
           ;//else rst:=rst+(' +'+sanat[ri1[j1].w]+inttostr(j1)+inttostr(i2)+'\'+inttostr(vmin));//vmj1,'/',vmj2);    //    continue;
           //vmj2:=min(vmj1,100*ri2[j2].v div ri2[0].v);
           //vmj2:=min(vmj1,ri2[j2].v);
           //if vj2<10 then break;
           inc(vtot,vmin);
           //write(vmj2,' ');
           TRY
           //if vj2>100 then write(^j,sanat[s],^j);
           //if (i2=0) and
           if (ri1[j1].w=s) then
           inc(isomat[ri1[0].w], vmin)
           else inc(isomat[ri1[j1].w], vmin);

          // if ri2[j2].v>30000 then
           if d then if not olijo then write(^j'     :',ansiuppercase(sanat[rs[i2].w]),':');       //for j1:=0 to lim-1 do if ri2[j1].w=0 then continue else write('_',sanat[rs[j1].w]);
           if d then write(' ',sanat[ri1[j1].w],vmin);
           olijo:=true;
           except write(' yyy:',vmj2,'/',ri1[j1].w,'/',isomat[ri1[j1].w],sanat[ri2[j1].w],'/',sanat[ri2[i2].w],sanat[ri1[i1].w],vj2,' ',vj2);end;
           except write(' XXX:',isomat[ri1[j1].w],sanat[s],sanat[ri2[j1].w],'/',min(vj1,ri2[j2].v));end;
         end;

       end;
        //   if rst<>'' then  write(^j,'***  ',sanat[s],'  ',sanat[rs[i1].w],vmi1,':',sanat[rs[i2].w],vmi2,':',rst);

     end;
   end;
   //if vtot>1 then write(^j,'----',vtot,'-');
   //if posi=0 then continue;
   //if vtot<500000 then
   fillchar(isosca[0],4*cols,0);//length(isosca)*2,0);
   //if s mod 1000=0 then write(sanat[s],' ');//^j^j,posi,' ',vtot,'/',dotmat.mx[s*cols].v,'=',vtot div (dotmat.mx[s*cols].v+1),'   ',sanat[s],':',rst);
  // continue;
   //setlength(isosca,0);  setlength(isosca,cols);
   for i1:=1 to rows-1 do
   begin
     //if isomat[i1]<iso then continue else
     //!!for j1:=1 to cols-2 do
     //if sanat[s]='ankara' then
     //if sanat[i1]='kiivas' then write(^j'   !!!',sanat[i1],isomat[i1]);
     if isomat[i1]<1 then continue;
     if isosca[lim-1].v>isomat[i1] then continue;   //ei kantsu kokeilla
     for j1:=1 to lim-1 do
     begin
         //if sanat[s]='ankara' then      if j1=lim-1 then begin write(^j,'*************************************************',sanat[i1],isomat[i1],':::');
        //   for j2:=1 to lim-1 do write(' ',sanat[isosca[j2].w],isosca[j2].v);      end;
         if isosca[j1].v>=isomat[i1] then continue;
          try
           move(isosca[j1],isosca[j1+1],(cols-j1-2)*4);
           isosca[j1].v:=isomat[i1];
           isosca[j1].w:=i1;
           //write('%  ',j1,sanat[isosca[j1].w],isosca[j1].v);
           //for k:=1 to 10 do if isosca[k].w=0 then break else write('/',sanat[isosca[k].w],isosca[k].v);
           //writeln('!!!');
           break;

           except writeln(^j'!fail');end;
     end;
   end;
   vtot:=0;
   rst:='';
   //if isosca[2].w>0 then
   _list; //listataan vain jos tarpeeksi
   for i1:=1 to cols-1 do if isosca[i1].w<1 then break else
   begin //inc(vtot,isosca[i1].v div 10);
      //rst:=rst+(' '+sanat[isosca[i1].w]+inttostr(isosca[i1].v div 1));
      vtot:=vtot+isosca[i1].v;
     // for k:=1 to cols do if mx[s*cols+k].w=isosca[i1].w then write('+',k);
   end;
    //write(' ',sanat[s],'/',vtot);//,sanat[rs[i1].w]);//, '::',sanat[ri1[j1].w]);
   for i1:=1 to cols-1 do
   begin
      //if dotmat.mx[s*cols+i1].w=0 then continue;
      if isosca[i1].w=0 then continue;
      //write('+');
       dotmat.mx[s*cols+i1].v:=isosca[i1].v;
       dotmat.mx[s*cols+i1].w:=isosca[i1].w;
   end;
   dotmat.mx[s*cols].w:=s;
    //   if s=17 then write('&????',vtot);//,i2);//,',',mx[rs[i2].w*cols].w,',',mx[rs[i2].w*cols].v,' ',i1);
   vtot:=min(vtot,65000);
   dotmat.mx[s*cols].v:=vtot;
      //list(s);
      //dotmat.list(s);
      // if vtot/(mx[s*cols].v+1)>0.10 then write('  ',sanat[s],'-',vtot,'-',mx[s*cols].v);
      //continue;                            ;
//     if //((vtot>3*(mx[s*cols].v+1))) //paino korostunut kerrottaessa
//      (5*vtot<(mx[s*cols].v+1))      // ei korostunut
      //then
//      posi:=isoko(mx[s*cols].v,s,cols,@isotas[0]);
      //if posi<0 then
 end;
 writeln(^j^j'veivivalmis.. loppun asti mentiin');
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
      //writeln(^j^j,'.   ..',sanat[s],mx[s*cols].v);
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
var rs,cs,cc,alku,loppu,i:word; hits,hiti:longword;maxis:array of twv;newolis:array of byte;
  //function unibits

  function bigs(w:word;v:longword):word;
  var j,k:word;p:pointer;
   begin
    try
    v:=v div 10;
    //write('#',sanat[w],v,' ');
    for j:=1 to 80 do
    if maxis[j].v<v then
    begin
         try
         p:=@maxis[j];
         move(p^,(p+4)^,(99-j)*4);
         except write('NOMove: #',j,sanat[maxis[j].w],maxis[j].v);end;
         try
         maxis[j].v:=v;
         maxis[j].w:=w;
         except write('NOMAX: ',j,sanat[maxis[j].w],maxis[j].v,'/',v);end;
         //for k:=1 to 3 do
         //if j<5 then  begin  write(^j,sanat[w],v,'>',j);for k:=1 to 10 do write(' ',sanat[maxis[k].w]);end;
         break;
    end;
    except writeln('failbig');end;
   end;
  var w1,w2,pre:word;uusii,vanhoi:longword; this:word;
begin
   setlength(maxis,100);
   if w=0 then begin alku:=1;loppu:=rows;end else begin alku:=w;loppu:=w;end;

    //if alku=loppu then
    //writeln(^j,'list ',rows,'*',cols,' ',alku,'...',loppu);
    //writeln;
    loppu:=rows;//100;
    for rs:=alku to loppu do
    begin
      hiti:=0;
      hits:=0;
      cc:=mx[rs*cols].v;
      //if cc<100 then continue;
      write(^j^j,rs,'/',mx[rs*cols].w,sanat[rs],' ',cc,'::');
      if mx[rs*cols].v<1 then continue;
      //if alku=loppu then
      //if len(rs)>30 then
      for cs:=1 to cols do //cols-1 do //min(len(rs),cols) do
      begin
        //if cs>9 then break;
        try
        if mx[rs*cols+cs].w=0 then break;
        //if mx[rs*cols+cs].v>pre then
        pre:=mx[rs*cols+cs].v;
        //inc(hits,mx[rs*cols+cs].v);
        //if mx[rs*cols+cs].v=1000 then
        inc(hits,mx[rs*cols+cs].v);
        inc(hiti);
        //if alku=loppu then
        write(' (',sanat[mx[rs*cols+cs].w],')',pre);//,'[',indexof(rs,mx[rs*cols+cs].w));
        except write('failmx:',rs,'/',cs,':',mx[rs*cols+cs].w);end;
      end;
      write(' ==',hits,'/',hiti);
      try
      //if alku=loppu then
      bigs(rs,hits);
      except writeln('nobigdeal:',rs,':',hits); end;
    end;
    //if alku=loppu then
    //exit;
    writeln('-----------------------');
  exit;
 //setlength(mx,0);
 //setlength(arr,64);
 //len:=0;
 //writeln(^j^j);
 for rs:=1 to 30 do
 begin
    w1:=maxis[rs].w;
    uusii:=0;vanhoi:=0;
    write(^j,'',sanat[w1],' ',maxis[rs].v,'  :');//,mx[w1*cols].v,'::');
      for cs:=1 to 25 do //cols-1 do
          if mx[w1*cols+cs].w=0 then continue else
          begin
              if onjo[mx[w1*cols+cs].w]<1 then inc(uusii,mx[w1*cols+cs].v) else inc(vanhoi,mx[w1*cols+cs].v);
            if onjo[mx[w1*cols+cs].w]<255 then inc (onjo[mx[w1*cols+cs].w]);
            write(' ',sanat[mx[w1*cols+cs].w],mx[w1*cols+cs].v);//,':',mx[w1*cols+cs].v);//,'[',indexof(rs,mx[rs*cols+cs].w));
            //write(' ',sanat[mx[w1*cols+cs].w],onjo[mx[w1*cols+cs].w]);//,':',mx[w1*cols+cs].v);//,'[',indexof(rs,mx[rs*cols+cs].w));
       end;
       write(^j,' == ',uusii,' / ',vanhoi);
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
  //i1 : twv absolute d1;
  //i2 : twv absolute d2;
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

