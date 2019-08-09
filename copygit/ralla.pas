unit ralla;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils,strutils,rallautils;

{etsiminen
 yksi sanamuoto kerrallaan : m‰ts‰t‰‰n taivutusmuoto, jos onnaa niin taivluokat, sitten luppuvok, jos .. niin avkons, sitten sanat
 sanajoukolle: karsitaan  koko joukosta osajoukkoja yksi askel kerrallaan
}

type tsija=record
  vv,hv:boolean;
  num,vparad,hparad:byte;
  vmuomids,hmuomids:array[1..16] of byte;
  ending:string[15];
  onverbi:boolean;
  name,esim:string[32];
end;
type tsanaluokka=class(tobject)

end;
type tluokkasija=class(tobject)
   //luokka:^tlka;
   sija:tsija;
   lnum,snum:word;
   muotoja:byte;
   lisuke,ineffect,reqnext:string;
   vahva:boolean;
   eatvok,eat2vok,tuplakon,tuplavok,copyvok,eatkon,eatsanaa,notricks:boolean;
   toinenmuoto:tluokkasija;
   function match(var haku:string):boolean;
   constructor create(var lka:tlka;var sij:tsija;tpl:string);
  // constructor createnull;
end;
type tsanasto=class(tobject)
 vcount,ncount:integer;
 nlvoks,vlvoks:tstringlist;
 nsijat:array[1..33] of tsija;
 vsijat:array[1..66] of tsija;
 //nluokkat:array[1..48] of tluokkasija;
 //vluokkat:array[52..78] of tluokkasija;
 vluokkasijat:array[52..78] of array[0..66] of tluokkasija;
 nluokkaSIJAT:array[1..48] of array[0..33] of tluokkasija;
 procedure luekaikki;
 function luenomsijat(fn:string):tstringlist; //hanskaa samalla sijojen luonti luettavat sisuskalut on 1/1 sijoihin (todin kuin verbeill‰, joilla on "protot")
 procedure lueverbisijat(fn:string);
 procedure luesanat(fn:string);
 function lueverbiprotot(fn:string):tstringlist;
 FUNCTION GETLUOKKASIJA(LK,SIJ:WORD):tluokkasija;
 constructor create;
 procedure savebin;
 procedure readbin;
 procedure listaa;
 function findone(sane:string):tstringlist;
 end;
  {etsiminen
 yksi sanamuoto kerrallaan : m‰ts‰t‰‰n taivutusmuoto, jos onnaa niin taivluokat, sitten luppuvok, jos .. niin avkons, sitten sanat
 sanajoukolle: karsitaan  koko joukosta osajoukkoja yksi askel kerrallaan

 verbit/nominit?
}

var sanasto:tsanaSTO;

implementation
uses //riimitys,
  math;
{$I 'sanasto.inc'}
//type thakutulos=class(tobject)    sijn,vokn,konn,runn:word;    kokosan,end;

{function _matchlkasija(lk,si:word;hakuwrd:string):boolean; //vois olla tluokkasijan metodi.. mut siit ehk tulee revord
var lks:tluokkasija;   // siirr‰ tluokkasijan metodiksi
begin try
     //writeln('<small>?',nluokkasijat[lk,si].lisuke,'/',hakuwrd,'</small>');
     //lks:=nluokkasijat[lk,si];
     ineffect:=lisuke;
     if  notricks  then
     begin
     if (lisuke='') or (pos(lisuke,hakuwrd)=1) then result:=true else result:=false;
     end else
     begin //uskoon nooksu < *, sija.end:n   inef:=no  kehuun >inef=nu, rest=keh
           //loheen neehol < ee-  inef
          if tuplavok then begin mvok:=mvok[1]+mvok; end;    //*     raka (k*) 41,a,k*,kar,0,rakas

                if lksija.copyvok then begin mlis:=mvok[1]+mlis; end;
                if lksija.eat2vok  then begin mvok:=copy(mvok,1,1);end;
                if lksija.eatvok  then begin mvok:=copy(mvok,2);end;
                if lksija.eatkon  then begin delete(mkon,1,1);end;
                writeln(' ',reversestring(lksija.sija.ending+''+mlis+mvok+mkon+msan));//,lksija.vahva,svahva,'.',sheikko);
         lks.ineffect:=
     end;
     except writeln(lk,'FFF',si);end;
 end;}

function tluokkasija.match(var haku:string):boolean;
var isi,ilk:word;stogo:string;  ok:boolean;hakupala,uus,apu:string;i:word;
 //var  lks:tluokkasija;
begin  //palauttaa tidon m‰ts‰‰kˆ, ja muuttaa inefectin‰ mats‰‰v‰n osan hakusanasta
    //writeln('<li>?<b>',reversestring(haku),'</b> to ', reversestring(sija.ending),'/',lisuke,' //',sija.name,' lka:',lnum,notricks,'</b>:',copyvok,muotoja);
    //lks:=nluokkasijat[lk,si];
   try
   try
    result:=false;
    reqnext:='';
    if muotoja=0 then exit;
    hakupala:=copy(haku,length(sija.ending)+1);
    //if  notricks  then
    //if lnum in [18] then if snum=11 then
    //writeln('<li>V.O.K/',lnum,' /',hakupala,'/',lisuke,'/',tuplavok,copyvok);// //alk.esim,alk.ekasis,'..',alk.vikasis,
    except writeln('faihaku:',haku,'[',sija.ending,']');end;
    //if not (tuplavok or copyvok) then
    if not (tuplavok) then
    begin
      //write('?',lisuke,'/',hakupala,'.');
      if (lisuke='') or (pos(lisuke,hakupala)=1) then result:=true else result:=false;
      uus:=lisuke;
    end else
    begin //uskoon nooksu < *, sija.end:n   inef:=no  kehuun >inef=nu, rest=keh
     try
          //loheen neehol < ee-  inef
               if tuplavok then                // h* j‰‰h‰n - jaaha lisuke:h, tuplavok > ha > halutaan: ah
                begin
                  //if (hakupala[1]<>hakupala[2]) or (pos(hakupala[1],vokaalit)<1) then result:=false

                  for i:=1 to min(3,length(hakupala)) do if pos(hakupala[i],vokaalit)>0 then begin apu:=hakupala[i];break;end;
                  uus:=apu+lisuke;
                  if (pos(uus,hakupala)<>1) then result:=false
                   else begin result:=true;end;  //a+h
                   reqnext:=apu;
                   //if lnum in [18,41] then if snum=11 then  writeln('<li>',lnum,'::::::::',(hakupala),'<b>[',uus,'/',lisuke,']</b> ',reqnext,' ',result);// //alk.esim,alk.ekasis,'..',alk.vikasis,
                                                                          // eheet                  eh       h
                end
                else if copyvok then  //  ? // altis / altti.isee|n /41 see? +n .. i tuplaa >ineffect: isee
                    // raka|s akar see? aas //rakkaa.see //n.ees.aakkar  halutaan "asee" "esee"
                begin      //rakkaas|en
                   //apu:='';
                   //apu:=copy(hakupala,length(lisuke)+1); // ees//aakkar
                   //  V.O.K/41 /eesaakkar/ees/FALSETRUE
                   //  CVOK:41((eees/eesaakkar))FALSEe
                   //if lisuke<>'' then uus:=hakupala[2]+lisuke else
                   uus:=lisuke;//'';//hakupala[1];

                   //if (apu[1]<>apu[2]) or (pos(apu[1],vokaalit)<1) then result:=false
                   if pos(uus,hakupala)<>1 then result:=false
                   else begin result:=pos(uus,hakupala)=1; end;  //
                   //     oopyvok: apu=   aakkar/hakupala:  eesaakkar  /  aees   FALSE
                   reqnext:=hakupala[1];
                   //if lnum in [18,41] then if snum=11 then


                end;
       except writeln('failtricks');end;
        //lks.ineffect:=
    end;
   // writeln('<li>CVOK:',lnum,'((',uus,'/',hakupala,'))',result,reqnext);// //alk.esim,alk.ekasis,'..',alk.vikasis,
    if result then
    begin try
   // ineffect:=sija.ending+uus;
    ineffect:=sija.ending+uus;
      //writeln('sijaending ineffect: <b>',string(ineffect+'</b>|'+copy(hAKUPALA,length(uus)+1)),result,reqnext,'!');
    except writeln('<li>failzzz',hakupala,'/',lnum,'#',snum,'!</li>');end;
    end;
   except writeln('<li>failmatchsija',hakupala,'/',lnum,'#',snum,'!</li>');end;
 end;


function tsanasto.findone(sane:string):tstringlist;
var csij,clk,cvok,ckon,crun:word;asij:tsija;alk:tlka;avok:tloppuvoks;arunko:trunko;akon:tkonso;
   lsij,llk,lvok,lkon,lrun:tstringlist;  //muutetaan joskus omaksi luokakseen, nyt temppuillaan stringlistan objecteilla
   alksija:tluokkasija;      hit:string;
   ssan,svok,skon,slis:string;
function _getsan(sa:string):boolean;var i,j:word;
begin
  for i:=akon.ekasana to akon.vikasana do
  begin
  try
   arunko:=rungot[i];
   ssan:=arunko.san;
   //if ssan='' then writeln('SANALOPPU:',arunko.koko,'/',arunko.san,i);
   //if (ssan='') or (pos(ssan,sa)=111) or (pos(sa,ssan)=1) then writeln('<li>HIT:',
   if (ssan=sa)  then hit:=hit+reversestring(slis+'.'+svok+'.'+skon+'.'+ssan)+'  ' +asij.name+' '+inttostr(alk.kot)+' ';
   ;//else if (pos(ssan,sa)=1) or (pos(sa,ssan)=1) then writeln('--',reversestring(ssan+'/'+sa));
    //  if alk.kot=28 then writeln('<li>???:',svok,'|',sa,'>',ssan,'|<b>',skon,'</b>:',skon,alk.kot, '. ',rungot[akon.ekasana].koko,' ',' <b>(', reversestring(asij.ending+'.'+slis+'.'+svok+'.'+skon+'.'+ssan),')</b> ');

   except writeln('----',sa);end;
  end;
end;
function _getkons(sa:string):boolean;var i,j:word;
begin

  for i:=avok.ekaav to avok.vikaav do
  begin
  try
   akon:=kons[i];
   if alksija.vahva then skon:=akon.v else  skon:=akon.h;
   ssan:=sa;
   if alksija.eatkon  then begin delete(ssan,1,1);end;
    if ssan<>'' then ssan:=copy(ssan,length(skon)+1);
   if (skon='') or (pos(skon,sa)=1) then
   begin
      //writeln('<li>kons;',    reversestring(sane),' <em>(', reversestring(asij.ending+'.'+slis+'.'+svok+'.'+skon+'.'+ssan),')</em> '
     //+asij.name+' ',alk.kot,' ',(rungot[akon.ekasana].koko),akon.ekasana);
     //if alk.kot=28 then writeln('<li>???:',svok,'|',sa,'>',ssan,'|<b>',skon,'</b>:',skon,alk.kot, '. ',rungot[akon.ekasana].koko,' ',' <b>(', reversestring(asij.ending+'.'+slis+'.'+svok+'.'+skon+'.'+ssan),')</b> ');
    //for i:=akon.ekasana to aakon.cikasana do
    _getsan(ssan);
   end;// else writeln('nok:',akon.v,akon.h,'/',sa);
   except writeln('----',sa);end;
  end;
end;
   function _getvoks(sa:string;lksi:tluokkasija):boolean;var i,j:word;
   begin  //palauttaa listan mats‰‰vien sijojen j‰ljellev‰ist' hakusanoista ja sijanumerot
     try
      alk:=lks[lksi.lnum];
      alksija:=lksi;
      //,'<ul>');
      try //writeln(lksi.lnum,'_',lksi.snum);

           //alksija:=tluokkasija(lsij.objects[i]);
       asij:=lksi.sija;
       slis:=lksi.ineffect;//lisuk  //t‰‰ ei oikeesti kuulu voks-hanskaukseen, vaan kub kaikista muodoista ei tied‰ ennen kuin vokaalit on n‰hty...
       //if alk.kot in [18,41] then  writeln('<li><b>[req,lisuke:',lksi.reqnext,',',slis,']</b>',lksi.copyvok,'<b>LS',lksi.lnum,'#',asij.num,'</b>',alk.ekasis,'...',alk.vikasis,' ');
       {try
       if slis<>'' then if not lksi.copyvok then if pos(slis,sa)<>1 then
       begin writeln('nogo:',slis,'/',sa,'/',lksi.lisuke);exit; end; //suo,soita ja rakas,rakkaan sanoa,sanoo viel‰ miettim‰tt‰
                  //  nogo:  neh   /  eet /   h
       xvok:='';
       if not lksi.copyvok then sa:=copy(SA,length(slis)+1) else xvok:=lksi.reqnext;
       except writeln('<li>FAILCV:/sa:',sa,'/slis:',slis,lksi.reqnext);end;
       }//writeln('V',alk.ekasis);
      except writeln('failslis????',slis,'/',sa);end;
      try
       for i:=alk.ekasis to alk.vikasis do //
       begin
          avok:=siss[i];
          svok:=siss[i].sis;
         //writeln('(',avok.sis,')');
         // writeln('<li>getvoks:',(sa),'<b>[',svok,']</b>=',lksi.reqnext,' ',lksi.copyvok,lksi.tuplavok,xvok);// //alk.esim,alk.ekasis,'..',alk.vikasis,
         if not lksi.notricks then
         begin
            if lksi.tuplakon then begin svok:=svok[1]+svok; end else//????
            if lksi.copyvok then begin svok:=svok[1]+svok; end else//????
          //if lksi.tuplavok then begin svok:=svok[1]+svok; end else//????
          //if lksi.copyvok then begin svok:=svok[1]+slis;if alk.kot=18 then writeln('???',asij.num,'/',svok,'/',sa); end else//????
          //if lksi.tuplavok then begin svok:=sa[1]+svok; end;
          if lksi.reqnext<>'' then if svok[1]<>lksi.reqnext then
            begin continue;writeln('-',svok[1],lksi.reqnext);continue  end;
          if lksi.eat2vok  then begin svok:=copy(svok,1,1);end;
          if lksi.eatvok  then begin svok:=copy(svok,2);end;
        end;
        //writeln('<li>vok?',svok,'=',sa,'?');
        if (svok='') or (pos(svok,sa)=1) then
        _getkons(copy(sa,length(svok)+1));
        end;
     except writeln('failmid????',alk.kot,'#',lksi.sija.num,lksi.sija.name,lksi.sija.ending,'/svok:',svok,'/sa:',sa,'/slis:',slis);end;
     finally writeln('</ul>');end;
   end;
   function matchverbisijat(s:string;var res:tstringlist):boolean;
   var isi,ilk,m:word;lksi:tluokkasija;
   begin
     for isi:=0 to 66 do  //if isi<>11 then continue else
       if (vsijat[isi].ending='') or (pos(vsijat[isi].ending,sane)=1)  then
       for ilk:=52 to 78 do
         if ilk in [22,50,51] then continue else
       begin
         try
          //if not (ilk in [18,41]) then continue;//if asij.num=11 then writeln('<b>[',siss[i].sis,']</b>',lksi.tuplakon);
          lksi:=vluokkasijat[ilk,isi];
          for m:=1 to lksi.muotoja do
          begin
          try
           if m=2 then lksi:=lksi.toinenmuoto;
          //if ilk>50 then writeln(lksi.lisuke,ilk,'.',isi);
          except writeln('failvsija:',isi,'.',ilk); end;
          if lksi.match(sane) then
          begin
            lsij.addobject(copy(sane,length(lksi.ineffect)+1),lksi);
          end ;//else        writeln('-',ilk);
          end;
        except writeln('<li>!failverbl;',isi,'/',ilk,'</li>'); end;
     end;// else writeln('--',isi,nsijat[isi].ending);

   end;
   function matchnomsijat(s:string;var res:tstringlist):boolean;
   var isi,ilk,m:word;lksi:tluokkasija;
   begin
     for isi:=0 to 33 do  //if isi<>11 then continue else
       if (nsijat[isi].ending='') or (pos(nsijat[isi].ending,sane)=1)  then
       for ilk:=1 to 49 do
         if ilk in [22,50,51] then continue else
       begin
         try
          if ilk<50 then lksi:=nluokkasijat[ilk,isi] else lksi:=vluokkasijat[ilk,isi];
          for m:=1 to lksi.muotoja do
          begin
              try
               if m=2 then lksi:=lksi.toinenmuoto;
              except writeln('failvsija:',isi,'.',ilk); end;
              if lksi.match(sane) then
              begin
                lsij.addobject(copy(sane,length(lksi.ineffect)+1),lksi);
              end ;//else        writeln('-',ilk);
         end;
         except writeln('<li>!failnoml;',isi,'/',ilk,'</li>'); end;
     end;// else writeln('--',isi,nsijat[isi].ending);

   end;
   var isi,ilk,i:integer;lksi:tluokkasija;
begin
   //writeln('**************',rungot[2].koko);   exit;
  lsij:=tstringlist.create;llk:=tstringlist.create;lvok:=tstringlist.create;lkon:=tstringlist.create;lrun:=tstringlist.create;
  writeln('<li><b>;;;',sane,'</b>::');
  sane:=reversestring(sane);
  matchnomsijat(sane,lsij);
  matchverbisijat(sane,lsij);
  hit:='';
  for i:=0 to lsij.Count-1 do
  begin
    try
    _getvoks(lsij[i],tluokkasija(lsij.objects[i]));
    except writeln('!!!!!!!!!!!!');end;
  end;
  if hit<>'' then writeln('<b style="color:green">',  hit,'</b> ' )
  else writeln('<b style="color:red">',lsij.commatext,  hit,'</b> ' )
end;
constructor tsanasto.create;
var i,j:word;haku:tstringlist;hakust:string;
begin
 for i:=1 to 58 do
 begin
    //lks[i].esim:=nom;
 end;
 try
 luekaikki;
 //listaa;
 //savebin;
 //readbin;
  haku:=tstringlist.create;
  hakust:='maustevoilla,lasten,lapsien,lapsi,jaahan,hakkuissa,jaihin,teehen,oisiin,happamien,koolla,koilla,kannen,kumpaan,keruuseen,keruihin,soihin,soista,suohon,tuttareen,tutarten,tutarta,asettimilla,liemiin,kantten,uhden,uksien,soitten,soiden,suolla,suolia';
  hakust:='laksi,lahti,kavi,itaroissa,itarissa,veista,uhteen,menneeseen';
  //hakust:='uhteen,yhdes';
  haku.commatext:=hakust;
 for i:=0 to haku.count-1 do
   findone(haku[i]);
 //listaa;
  writeln('findok');
 except writeln('failed..noharm?');   end;
  //lks:array[0..80] of tlka; siss:array[0..2047] of tloppuvoks; kons:array[0..2047] of tkonso; rungot:array[0..65535] of trunko;
end;
procedure tsanasto.savebin;
var data:pointer;datasize:longword; datafile:file;datastream:tmemorystream;fstream:tfilestream;//memorystream;
begin
//datafile:=
 writeln('<li>trywrite');
datasize:=sizeof(lks)+sizeof(siss)+sizeof(kons)+sizeof(rungot);
//datasize:=1024;
data:=@lks[0];
assign(datafile,'arrays.bin');
rewrite(datafile,1);
try
blockwrite(datafile,lks[0],datasize);
//datastream:=tmemorystream.Create('arrays.bin',fmcreate);
//fstream:=tfilestream.Create('arrays.bin',fmcreate);
//datasize:=10000;
//fstream.WriteBuffer(data,datasize);
except on e:exception do writeln('<li>eiEionnaa:',e.Message,' ',datasize);;end;
//fstream.free;
close(datafile);
end;

procedure tsanasto.readbin;
var data:pointer;datasize:longword; datafile:file;datastream:tmemorystream;fstream:tfilestream;//memorystream;
begin
//datafile:=
 writeln('<li>read');
datasize:=sizeof(lks)+sizeof(siss)+sizeof(kons)+sizeof(rungot);
//datasize:=1024;
data:=@lks[0];
assign(datafile,'arrays.bin');
reset(datafile,1);
try
blockread(datafile,lks[0],datasize);
//datastream:=tmemorystream.Create('arrays.bin',fmcreate);
//fstream:=tfilestream.Create('arrays.bin',fmcreate);
//datasize:=10000;
//fstream.WriteBuffer(data,datasize);
except on e:exception do writeln('<li>eiEionnaa:',e.Message,' ',datasize);;end;
//fstream.free;
close(datafile);
end;

 procedure tsanasto.luesanat(fn:string);
var csan,cvok,ckon,clka:word;
   ssan,svok,skon,SVAHVA,SHEIKKO:string;
   msan,mvok,mkon,mlis,xtra:string;
var  sanalista,osalista,prevosat:tstringlist;i,j,dif,pdif,ahits,vhits:word;//p_vo,p_av,p_lk:string;
    procedure uusavkon;
      begin
       try
        kons[ckon].vikasana:=csan;
        ckon:=ckon+1;
        kons[ckon].ekasana:=csan+1;
        kons[ckon].sis:=cvok; //mink‰ loppuvokaalin alla on ("sis" nimi oiis hyv‰ muuttaa joskus "lvok" tms
            EXCEPT WRITELN('failavkon1:',ckon,'/',osalista.count,'/',length(kons));END;
        try
        if length(osalista[2])=2 then
         begin
            if osalista[2][1]='_' then
             begin
               kons[ckon].v:=osalista[2][2];
               kons[ckon].h:=osalista[2][2];

            end
            else
            begin
              kons[ckon].v:=osalista[2][1];
              if osalista[2][2]='*' then begin kons[ckon].h:='';   end
              else kons[ckon].h:=osalista[2][2];
            end;
          end
          else if osalista[2]='' then begin  kons[ckon].v:=''; kons[ckon].h:='';end;;
          //writeln('<b>[',kons[ckon].v, kons[ckon].h,']</b>');
        EXCEPT WRITELN('failavkon:',ckon,'/',osalista.count,'/',length(kons));END;
    end;
    procedure uusloppuvok;
      begin
       TRY
       try
      //write('<li>',clka,' voks:',cvok,' ',osalista[1],':::  ',osalista.commatext,' \\ ',prevosat.commatext);
      siss[cvok].vikasana:=csan; //edellisten loppuvokaalien vika sana
      siss[cvok].vikaav:=ckon;  // edellisten loppuvokaalien vikat avkonsonantit
      inc(cvok);
      siss[cvok].ekaav:=ckon+1; //avkons ei viel‰ inkrementoitu
      siss[cvok].sis:=(osalista[1]);//itse loppuvokaalit
      siss[cvok].lk:=clka;  //luokka on jo kasvatettu, t‰m‰ kuuluu siihen uuteen
      //write('==',clka,' :',cvok,siss[cvok].sis);
      EXCEPT WRITELN('failsis:',cvok,'/',osalista.count,'/',length(siss));END;
         //if osalista[2]='k*' then
          //if clka=73 then              writeln('<li>VOK:<b>',osalista.CommaText,'</b> [',avs[ckon].v,avs[ckon].h,']');
      finally writeln('');end;
    end;
    procedure uusluokka;
  var kot:integer;
begin
  try
     lks[clka].vikasis:=cvok;
     lks[clka].vikasana:=csan;
     clka:=strtointdef(osalista[0],99);
     //clka:=clka+1;
     try
     lks[clka].ekasis:=cvok+1; // ei viel‰ kasvatettu
     //writeln('<li>LKA:',clka,'>',lks[clka].ekasis,':',osalista.commatext,'<ul>');
     //try lks[clka].esim:=sl[7];except lks[clka].esim:='x'+inttostr(sl.count)+'x';end;
     kot:=strtointdef(osalista[0],99);//clka+51;
     lks[clka].kot:=kot;//clka+51;
     if (kot in vahvatverbiluokat+vahvatnominiluokat) then   lks[clka].vahva:=true else  lks[clka].vahva:=false;

  except writeln('failreadlka');end;
  finally writeln('</ul>');end;
end;
 var lksija:tluokkasija;m:byte; var sikoja:byte;  OLIJO:boolean;
begin
  //verbit.listsijat;
  //exit;                             sizeof
  //ongelmia .. collie, zombie 05 ei i-loppu..  veks?'
  //Y÷ paloiteltu v‰‰rin
 writeln('testaasijat<ul>');
  cvok:=0;ckon:=0;csan:=0;clka:=1;
  sanalista:=tstringlist.create;
  osalista:=tstringlist.create;
  osalista.delimiter:=',';
  prevosat:=tstringlist.create;
  prevosat.delimiter:=',';
  sanalista.loadfromfile('uuskaavas.lst');
  sanalista.sort; //oli kai valmiiksikin
  pdif:=2;
  ahits:=0;
  vhits:=0;
  kons[0].ekasana:=2;
  prevosat.delimitedtext:=sanalista[0];
  //writeln('<ul><li>luesanat:',prevosat.commatext,'<ul style="margin:0en;padding:0em;border:1px solid red"><li>loukka:');
  //  ,prevosat[0],'<ul><li>vok:',prevosat[1],':<ul><li>kon;',prevosat[2],':ekasana',prevosat[3],':');
  for i:=0 to sanalista.count-1 do
  begin
    try
    osalista.delimitedtext:=sanalista[i];
    dif:=3;
    if i=0 then dif:=0 else for j:=0 to 2 do if osalista[j]<>prevosat[j] then begin dif:=j;break;end; //2
    //if i=1 then write('\',dif);
    if dif=0 then uusluokka;
    if dif<2 then uusloppuvok;
    if dif<3 then uusavkon ;
     //itse rivin sana
    csan:=csan+1;
    rungot[csan].konlka:=ckon;
    rungot[csan].san:=osalista[3];
    rungot[csan].takavok:=osalista[4]='0';
    rungot[csan].koko:=osalista[5];
    //UUSNO sans[csan].akon:=(sl[6]);
    //if sl[4]='0' then avs[ckon].takia:=avs[ckon].takia+1;  //lasketaan takavokaalisten m‰‰r‰‰ av-luokassa hakujen tehostamiseksi
    //if osalista[0]='73' then if osalista[2]='k*' then     writeln('<li>KKK',osalista.CommaText,' [',avs[ckon].v,',',avs[ckon].h,']');
    prevosat.delimitedtext:=sanalista[i];

    ;
    except writeln('!!!',osalista.commatext,'(',dif,')',prevosat.commatext,prevosat.count);end;
 end;
  //writeln('</ul></ul></ul><h3>luettu:',clka,' ',cvok,' ',ckon,' ',csan,'</h3> ',lks[1].ekasis,'/',siss[1].sis);
  lks[clka].vikasis:=cvok;
  siss[cvok].vikaav:=ckon;
  kons[ckon].vikasana:=csan;
  //lks[1].ekasis:=0;
  //for clka:=52 to 78 do
  //for clka:=1 to 49 do
end;

procedure tsanasto.listaa;
var csan,cvok,ckon,clka,i,j,m:word;
   ssan,svok,skon,SVAHVA,SHEIKKO:string;
   msan,mvok,mkon,mlis,xtra:string;olijo:boolean;
   lksija:tluokkasija;luokka:tlka;
//var  //sanalista,osalista,prevosat:tstringlist;i,j,dif,pdif,ahits,vhits:word;//p_vo,p_av,p_lk:string;
 begin
   writeln('testaasijattu',lks[1].ekasis);
   //for clka:=1 to 78 do begin writeln(i,nluokkasijat[clka-51,1].lisuke,nluokkasijat[clka-51,1].muotoja,' ');end;
   writeln('<hr>');
      // writeln(luokka=@lka);

   //for clka:=1 to 48 do begin writeln(nluokkasijat[clka,1].lisuke,@lks[clka]=(nluokkasijat[clka,1].luokka),' ');end;
   //writeln('<hr>');
   //for clka:=1 to 78 do begin lksija:=getluokkasija(clka,1);writeln(lksija.lisuke,lksija.luokka^.ekasis,'=',lks[clka].ekasis,' ');end;
   //writeln('<hr>');
   writeln('testaasissit:');
  // for i:=1 to 48 do writeln('\',getluokkasija(i,1).luokka.ekasis);
   for clka:=1 to 78 do
   begin
   try
   if  (clka in [22,49,50,51]) then begin continue; end;
   //if clka<52 then continue;
   writeln('<li>LKA:',clka,' ',lks[clka].vahva,': ',lks[clka].ekasis );
   try
   //writeln('<li>listaa:',clka,': ');
   //if clka<>28 then if clka<>67 then continue; //sikoja:=33 else begin
     // sikoja:=65;//continue;end;
   for cvok:=lks[clka].ekasis to lks[clka].vikasis do writeln(' <b>:',siss[cvok].sis,'</b>');
   writeln('<ul>');
   for cvok:=lks[clka].ekasis to lks[clka].vikasis do
   begin
     writeln('<li><b>',cvok,'{',siss[cvok].sis,'}</b><ul>');//,'<ul>');
     sVOK:=siss[cvok].sis;
     olijo:=false;
     for ckon:=siss[cvok].ekaav to siss[cvok].vikaav do
     begin
       SVAHVA:=kons[ckon].V;
       SHEIKKO:=kons[ckon].H;
       if sVAHVA=SHEIKKO THEN if olijo then  CONTINUE else  OLIJO:=TRUE;
       writeln('<b>[',kons[ckon].v,kons[ckon].h,']</b> ');
       //for j:=kons[ckon].ekasana to min(10+kons[ckon].ekasana,kons[ckon].vikasana)  do      writeln(' ',reversestring(rungot[j].san));
       //for j in [0,1,2,11,12,13,15,20..33] do
       //for j in [0,5,9,12,13,16,23,36,37,39,45] do
       //for j in [0,5,11,23] do
       for j:=0 to 66 do
       begin
         try
         //if not (j in [23..28]) then continue;
         if clka<50 then if not ( j in [0,1,2,11,12,13,15,20..33]) then continue;
         if clka>50 then
          if not (j in [0,23,24,28]) then continue;
         //if not (j in [0,5,9,12,13,16,23,36,37,39,45]) then continue;
         lksija:=getluokkasija(clka,j);
         if lksija=nil then writeln('nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn:',clka,' ',j);
         except writeln('((!!!))');end;
         try
         //writeln('[',clka,',',j,' ',lksija.muotoja,'] ');//,nluokkasijat[clka,j].muotoja);
        // continue;
         for m:=1 to lksija.muotoja do
         begin
            try
            try
             msan:=rungot[kons[ckon].ekasana].san;
             if m=2 then lksija:=lksija.toinenmuoto;
                //if lksija.eatsanaa then delete(msan,1,1);end;
             // if clka<50 then lksija:=nomluokkasijat[clka,j] else  lksija:=verbluokkasijat[clka,j];
             //if lksija.muotoja=0 then continue;
             mlis:=lksija.lisuke;
            except writeln('<li>noeatkon::',j,'.',m);raise;end;
            try
             mkon:=ifs(lksija.vahva,svahva,sheikko);
             mvok:=svok;
             xtra:='';

             //if lksiJA.eatvok then delete(mvok,1,1);
             if lksija.tuplakon then if clka=28 then  begin mvok:=mvok+mvok[1];end
             else begin mlis:=mvok[1]+mlis;end;
             except writeln('fuck',clka,' ',j);raise;end;
             //28,,_n,ak,0,kansi
             except writeln('<li>faillisue:<b>',clka,'#',j,j,'</b> ','/vok:',mvok,mlis,'/kon:',mkon,'/msan:',msan,'/',lksija.sija.num,' \tv',lksija.tuplavok,' tk',lksija.tuplakon,' ev',lksija.eatvok,' e2',lksija.eat2vok,' cv',lksija.copyvok,'</li>');end;
             try
             if lksija.tuplavok then begin mvok:=mvok[1]+mvok; end;
             if lksija.copyvok then begin mlis:=mvok[1]+mlis; end;
             if lksija.eat2vok  then begin mvok:=copy(mvok,1,1);end;
             if lksija.eatvok  then begin mvok:=copy(mvok,2);end;
             if lksija.eatkon  then begin delete(mkon,1,1);end;
             writeln(' ',reversestring(lksija.sija.ending+''+mlis+mvok+mkon+msan));//,lksija.vahva,svahva,'.',sheikko);
             //writeln(' ',j,'/',lksija.sija.vparad,':',reversestring(lksija.sija.ending+xtra+''+mlis+''+mvok+mkon+msan));//,lksija.vahva,svahva,sheikko);
             except writeln('<li>failSIJA:<b>',clka,'#',j,lksija.sija.ending,'</b>',mlis,'/',lksija.sija.num,' \tv',lksija.tuplavok,' tk',lksija.tuplakon,' ev',lksija.eatvok,' e2',lksija.eat2vok,' cv',lksija.copyvok,'</li>');end;
         end;
         //EI AV  62 63 64 65 68 69 70 71 77
         except writeln('FAILSIJAT',m,'/',lksija=nil,'!!');end;
       end;
    end;
    writeln('</ul>');
   end;
   except writeln('<li>faillka:',clka);end;
   finally writeln('</ul>');end;
   end;
  end;
end.

