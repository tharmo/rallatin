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
  perustavs:byte;
end;
type tsanaluokka=class(tobject)

end;

type tprono=record
   //luokka:^tlka;
   sija:tsija;
   num,snum:word;
   //muotoja:byte;
   runko,alkon,lemma:string;
   etuv:boolean;
   lisukkeet:array[0..33] of string[31];
   //toinenmuoto:tpronosija;
   //function match(var haku:string):boolean;
   //constructor create(var lka:tlka;var sij:tsija;tpl:string);
  // constructor createnull;
end;
    type tluokkasija=class(tobject)
       //luokka:^tlka;
       sija:tsija;
       lnum,snum:word;
       muotoja:byte;
       lisuke,ineffect,reqnext,kokok:string;
       vahva:boolean;
       eatvok,eat2vok,tuplakon,tuplavok,copyvok,eatkon,eatsanaa,notricks:boolean;
       toinenmuoto:tluokkasija;
       xtavut:shortint;
       function match(var haku:string):boolean;
       constructor create(var lka:tlka;var sij:tsija;tpl:string);
      // constructor createnull;
    end;
type tsanasto=class(tobject)
 scount,vcount,ncount:integer;
 nlvoks,vlvoks:tstringlist;
 nsijat:array[0..33] of tsija;
 vsijat:array[0..66] of tsija;
 pronot:array[0..19]  of tprono;
 vokcount,konscount,runkcount:word;
 adverbit:tstringlist;
 //nluokkat:array[1..48] of tluokkasija;
 //vluokkat:array[52..78] of tluokkasija;
 vluokkasijat:array[52..78] of array[0..66] of tluokkasija;
 nluokkaSIJAT:array[1..48] of array[0..33] of tluokkasija;
 procedure luekaikki;
 function luenomsijat(fn:string):tstringlist; //hanskaa samalla sijojen luonti luettavat sisuskalut on 1/1 sijoihin (todin kuin verbeill‰, joilla on "protot")
 procedure lueverbisijat(fn:string;var protolist:tstringlist);
 procedure luepronsijat(fn:string);
 procedure luesanat(fn:string);
 function lueverbiprotot(fn:string):tstringlist;
 FUNCTION GETLUOKKASIJA(LK,SIJ:WORD):tluokkasija;
 constructor create;
 procedure savebin;
 procedure readbin;
 procedure listaa;
 procedure haelista;
 procedure pronominit;
 procedure luokaavat;
 procedure pikakelaa;
 procedure lueadverbit;
 function findone(sane:string):tstringlist;
 //function generateone(sa,si:word):string;
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
    if  notricks  then
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
                begin      //rakkaas|en
                   uus:=lisuke;//'';//hakupala[1];
                   if pos(uus,hakupala)<>1 then result:=false
                   else begin result:=pos(uus,hakupala)=1; end;  //
                   reqnext:=hakupala[1];

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
     //if lnum in [62,76] then if snum=16 then       writeln('<li>V.O.K/',lnum,' /',hakupala,'/',lisuke,'/',ineffect,'/',uus,'!');// //alk.esim,alk.ekasis,'..',alk.vikasis,
    except writeln('<li>failzzz',hakupala,'/',lnum,'#',snum,'!</li>');end;
    end;
   except writeln('<li>failmatchsija',hakupala,'/',lnum,'#',snum,'!</li>');end;
 end;


function tsanasto.findone(sane:string):tstringlist;
var csij,clk,cvok,ckon,crun:word;asij:tsija;alk:tlka;avok:tloppuvoks;arunko:trunko;akon:tkonso;
   lsij,tuttavut,hakutavut:tstringlist;//,xllk,xlvok,xlkon,xlrun,xYHDYS:tstringlist;  //muutetaan joskus omaksi luokakseen, nyt temppuillaan stringlistan objecteilla
   alksija:tluokkasija;      hit:string;
   ssan,svok,skon,slis,hakuakon:string;
   tuttavuc,hakutavuc:word;lendif:integer;
   turha:string;
   jatke:string;
   eietu,eitaka:boolean;
var hitti:string;  hittavuc:word;   riimiok:boolean;

function riimaako(testattava,kohde:string;kohteentavuc:byte):byte;   //paljonko riimi ontuu ... 0..5
var i,ttc,lent,lenk:word;  //ekaan (lopusta vikaan) vokaalin asti samoiksi todetuille sanoille
 //alkukonsonantit p‰tk‰isty pois ja sanat k‰‰nnetty
begin
   result:=0;
   if testattava=kohde then exit;
   if pos(testattava,kohde)=1 then jatke:=copy(kohde,length(testattava)) //vika yhteinen + jatko-osa
   else if pos(kohde,testattava)=1 then jatke:=copy(testattava,length(kohde))
   else begin inc(result,2);exit;end; //vois kyll‰ laskea jotain melkeinriimaavuuksia

   //lenk:=length(kohde);       lent:=length(testattava);


   if tuplavok(jatke[2],jatke[1]) then inc(result,1);  //tapa aapa
   ttc:=hyphenfi(reversestring(testattava),nil);
  if  (abs(kohteentavuc-ttc)<3) //jos jompikumpi pitk‰ ei tartte parillisuudesta v‰litt‰‰
    then if (hakutavuc mod 2<>ttc mod 2) then inc(result);// satama, kama  ---raaka puolisointu

end;


function _getsan(sa,sofar:string):boolean;var i,j:word;
begin
  for i:=akon.ekasana to akon.vikasana do
  begin
  try
   arunko:=rungot[i];
   ssan:=arunko.san;
   //if length(ssan)>7 then continue;
      //                                  runko::              (L:eeni     /v:a/       k:n,)
   //if ssan='' then writeln('SANALOPPU:',arunko.koko,'/',arunko.san,i);
   //if (arunko.koko='susi') or (arunko.koko='jousi') then //begin  writeln(';;;',sa,'/','+',arunko.san,'!',arunko.koko,'/',sofar);// end;// else//????
   if (ssan=sa) then riimiok:=true
   else if  (sa='') and (not tuplavok(ssan[length(sa)+1],sofar[length(sofar)])) then riimiok:=true
   else if  (ssan='') and (not tuplavok(sa[length(ssan)+1],sofar[length(sofar)])) then riimiok:=true
   else if  (pos(sa,ssan)=1) and (not tuplavok(ssan[length(sa)+1],ssan[length(sa)])) then riimiok:=true
   else if (pos(ssan,sa)=1) and (not tuplavok(sa[length(ssan)+1],sa[length(ssan)])) then begin riimiok:=true;end
   else riimiok:=false;
     //writeln('<li>runko:<b>', ssan,':</b><em>(L:',slis,'/v:', svok+'/k:'+skon,',)</em>',reversestring(ssan+arunko.akon),' <b>',sa,'</b>',hakutavuc,hittavuc);
   //if alk.kot in [67] then if asij.num>62 then //writeln('<li>getkons:',(sa),'<b>[',svok,']</b>=',' ');// //alk.esim,alk.ekasis,'..',alk.vikasis,
    //writeln('<li>','kons[', ' <em>(', sa+'.'+ssan,riimiok,')</em> ');

   //if (ssan='') or (pos(ssan,sa)=1) or (pos(sa,ssan)=1) then //writeln('<li>HIT:',
   //if (ssan=sa)  then
   if (arunko.takavok and eitaka) then CONTINUE else
   if ((not arunko.takavok) and eietu) then CONTINUE else
   if riimiok then
   begin
     hitti:=reversestring(slis+svok+skon+ssan);
     if not arunko.takavok then
     hitti:=etu(hitti);
     hittavuc:=hyphenfi(hitti,nil);
     //continue;
     if  abs(hittavuc-hakutavuc)<3 then //jos jompikumpi pitk‰ ei tartte parillisuudesta v‰litt‰‰
          if (hakutavuc mod 2)<>hittavuc mod 2 then continue;
     //sovitatavut(sane+hakuakon,slis+svok+skon+ssan);
     //if (hakutavuc mod 2)<>hittavuc mod 2 then begin  writeln('!!!!!!!!!');end;
     hit:=hit+reversestring(slis+'.'+svok+'.'+skon+'.'+ssan)+'  ' +asij.name+' '+inttostr(alk.kot)+' '+inttostr(i)+ifs(arunko.takavok,'T','E');
     if (hakutavuc mod 2)<>hittavuc mod 2 then
     //writeln('<b style="color:red">',arunko.akon+hitti,'</b>',hittavuc,hakutavuc)
     else //if turha<>'' then
      writeln('<b style="color:green" title="'+inttostr(alk.kot)+' '+asij.name+inttostr(asij.num)+'">',arunko.akon+hitti,'</b> ');//,asij.name,' ',asij.esim);
   end
   else if  ((length(ssan)>2) and (length(sa)>2) and (length(ssan)-length(sa)>3) and (pos(sa,ssan)=1)) then //writeln('<em style="color:blue">',reversestring(copy(ssan,length(sa)+1)),'|</em>',rungot[i].koko)
   else if  ((length(ssan)>2)  and (length(sa)-length(ssan)>3) and (pos(ssan,sa)=1)) then
   BEGIN
     //YHDYS.ADD(rungot[i].koko+' '+reversestring(slis+''+svok+''+skon+''+ssan+'|'+copy(sa,length(ssan)+1)));
   END;
   //  if alk.kot=28 then writeln('<li>???:',svok,'|',sa,'>',ssan,'|<b>',skon,'</b>:',skon,alk.kot, '. ',rungot[akon.ekasana].koko,' ',' <b>(', reversestring(asij.ending+'.'+slis+'.'+svok+'.'+skon+'.'+ssan),')</b> ');

   except writeln('failsan----',sa);end;
  end;
end;
function _getkons(sa,sofar:string):boolean;var i,j:word;
begin

  for i:=avok.ekaav to avok.vikaav do
  begin
  try
   akon:=kons[i];
   if alksija.vahva then skon:=akon.v else  skon:=akon.h;
   //if ssan<>'' then ssan:=copy(ssan,length(skon)+1);
   ssan:=sa;
   if alk.kot=28 then writeln('____',sa,'/',sofar,'!');
   //if alksija.tuplakon then begin skon:=skon[1]+skon;writeln(':::',skon,'/',svok,'/',sa,'!',AKON.EKASANA-akon.vikasana); end;// else//????
   if alksija.eatkon  then begin skon:='';//delete(ssan,1,1);
   end;
   if (skon='') or (sa='') or (pos(skon,sa)=1) then
   begin
     //+asij.name+' ',alk.kot,' ',(rungot[akon.ekasana].koko),akon.ekasana);
     //if alk.kot=1 then writeln('<li>vok:',svok,'/sa:',sa,'>',ssan,'|<b>kon:',skon,'</b>:', '. ',rungot[akon.ekasana].koko,' ',' <b>(', reversestring(asij.ending+'.'+slis+'.'+svok+'.'+skon+':'+ssan),')</b> </li>');
    //for i:=akon.ekasana to aakon.cikasana do
    _getsan(copy(ssan,length(skon)+1),sofar+skon);
   end;// else writeln('nok:',akon.v,akon.h,'/',sa);

   except writeln('failkon----',sa);end;
  end;
 end;
   function _getvoks(sa,sofar:string;lksi:tluokkasija):boolean;var i,j:word;
   begin  //palauttaa listan mats‰‰vien sijojen j‰ljellev‰ist' hakusanoista ja sijanumerot
     try
      alk:=lks[lksi.lnum];
      alksija:=lksi;
      //,'<ul>');
      try //writeln(lksi.lnum,'_',lksi.snum,sa);

           //alksija:=tluokkasija(lsij.objects[i]);
       asij:=lksi.sija;
       slis:=lksi.ineffect;//lisuk  //t‰‰ ei oikeesti kuulu voks-hanskaukseen, vaan kub kaikista muodoista ei tied‰ ennen kuin vokaalit on n‰hty...
      except writeln('failslis????',slis,'/',sa);end;
      try
       for i:=alk.ekasis to alk.vikasis do //
       begin
          avok:=siss[i];
          svok:=siss[i].sis;
         //  if lksi.lnum=67 then writeln('(*',svok,'*');
         //writeln('(',avok.sis,')');
         if not lksi.notricks then
         begin
           //if lksi.tuplakon then begin svok:=svok[1]+svok; end else//????
           if lksi.tuplakon then begin svok:=svok[1]+svok;//writeln('???',alk.kot,'/',svok,'/',sa,'!');
            end else//????
            if lksi.copyvok then begin svok:=svok[1]+svok; end else//????
          //if lksi.tuplavok then begin svok:=svok[1]+svok; end else//????
          //if lksi.copyvok then begin svok:=svok[1]+slis;if alk.kot=18 then writeln('???',asij.num,'/',svok,'/',sa); end else//????
          //if lksi.tuplavok then begin svok:=sa[1]+svok; end;
          if lksi.reqnext<>'' then if svok[1]<>lksi.reqnext then
            begin continue;writeln('-',svok[1],lksi.reqnext);continue  end;
          if lksi.eat2vok  then begin svok:=copy(svok,1,1);end;
          if lksi.eatvok  then begin svok:=copy(svok,2);end;
        end;
        //writeln('<li>vok?',svok,'=',sa,'?',pos(svok,sa));
         //if lksi.tuplakon then begin writeln('///',alk.kot,'/',svok,'/',sa,'!',svok=''); end else//????

         if (svok='') or (pos(svok,sa)=1) then
         try
          //if lksi.lnum=67 then if writeln('<li>>>',copy(sa,length(svok)+1),'/',sofar,'+',svok,'!');
          //if (svok='') or (fitvok(svok,sa)=1) then
        _getkons(copy(sa,length(svok)+1),sofar+svok);
         except writeln('<li>failget:',svok,'/',alk.kot,'#',alksija.kokok,asij.num,ASIJ.ending);end;
        end;
     except writeln('failmid????',alk.kot,'#',lksi.sija.num,lksi.sija.name,lksi.sija.ending,'/svok:',svok,'/sa:',sa,'/slis:',slis);end;
     finally //writeln('</ul>');
     end;
   end;
   function matchverbisijat(s:string;var res:tstringlist):boolean;
   var isi,ilk,m:word;lksi:tluokkasija;
   begin
     for isi:=0 to 65 do  //if isi<>11 then continue else
     begin
       //if isi<5 then writeln('<li>',isi,vsijat[isi].ending,'?',sane,'-',s);
       if (vsijat[isi].ending='') or (pos(vsijat[isi].ending,sane)=1)  then
       for ilk:=52 to 78 do
       begin
         try
          //if not (ilk in [18,41]) then continue;//if asij.num=11 then writeln('<b>[',siss[i].sis,']</b>',lksi.tuplakon);
          lksi:=vluokkasijat[ilk,isi];
          //if ilk in [52] then if isi<55 then writeln('<li>zzz',isi,copy(sane,length(lksi.ineffect)+1),'/',lksi.ineffect,'!',lksi.sija.name,lksi.muotoja);
          for m:=1 to lksi.muotoja do
          begin
            try
             if m=2 then lksi:=lksi.toinenmuoto;
            //if ilk>50 then writeln(lksi.lisuke,ilk,'.',isi);
            except writeln('failvsija:',isi,'.',ilk); end;
            if lksi.match(sane) then
            begin

              lsij.addobject(copy(sane,length(lksi.ineffect)+1),lksi);
              //if ilk=67 then if isi>60 then write('***',ilk,isi);
            end ;//else        writeln('-',ilk);
          end;
        except writeln('<li>!failverbl;',isi,'/',ilk,'</li>'); end;
     end;// else writeln('--',isi,nsijat[isi].ending);
    end;
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
   var isi,ilk,i:integer;lksi:tluokkasija; orig:string;ii,jj,kk:word;s1,s2,alkkon:string;riimaus:byte;
       //findone(
begin
  // vsijat[0].ending:='a';

   writeln('<hr>');
  orig:=sane;
   while (sane<>'') and (pos(sane[1],vokaalit)<1) do begin hakuakon:=hakuakon+sane[i];delete(sane,1,1);end;
  hakutavut:=tstringlist.create;
  tuttavut:=tstringlist.create;
  hakutavuc:=hyphenfi(sane,hakutavut);
  // tuttavuc:=hyphenfirev(reversestring(orig),tuttavut,alkkon);
  //writeln('<li><b>',tuttavut.commatext,' </b>',hakutavut.commatext);  exit;
  hakuakon:='';
  lsij:=tstringlist.create;//xllk:=tstringlist.create;xlvok:=tstringlist.create;xlkon:=tstringlist.create;xlrun:=tstringlist.create;xYHDYS:=tstringlist.create;
  while (sane<>'') and (pos(sane[1],vokaalit)<1) do begin hakuakon:=hakuakon+sane[i];delete(sane,1,1);end;
  sane:=string(voktakarev(sane,eietu,eitaka));

  writeln('<li><b>',orig,'</b>:: ');//,hakutavut.commatext,hakutavuc);//,lsij.commatext);//,orig,eietu,eitaka);
  for ii:=0 to 33 do  //PRONOMINIT
   if pos(nsijat[ii].ending,sane)=1 then
   begin
    try
     clk:=ii;
      //writeln('<li>',ii,nsijat[ii].ending,'?',copy(sane,length(nsijat[ii].ending)+1),'::');
     for jj:=0 to 19 do
     begin //write('[',jj,pronot[jj].lisukkeet[ii],']');
        S1:=nsijat[ii].ending+''+pronot[jj].lisukkeet[ii]+''+pronot[jj].runko;//+pronot[jj].alkon
        //if pos(pronot[jj].lisukkeet[ii]+pronot[jj].runko,copy(sane,length(nsijat[ii].ending)+1))=1 then
        riimaus:=RIIMAAKO(s1,sane,hakutavuc);
        if riimaus=0 then
           writeln('<b style="color:blue" title="',pronot[jj].lemma+'">:',reversestring(s1+pronot[jj].alkon),'</b>')
          ;//else writeln('<b style="color:pink" title="',pronot[jj].lemma+'">:',reversestring(nsijat[ii].ending+''+pronot[jj].lisukkeet[ii]+''+pronot[jj].runko+pronot[jj].alkon),'</b>',riimaus);
     end;
     except writeln('failprono ',orig);end;
   end;
  matchnomsijat(sane,lsij);
  matchverbisijat(sane,lsij);
  hit:='';
  for i:=0 to lsij.Count-1 do
  begin
    try
    lksi:=tluokkasija(lsij.objects[i]);
    //writeln('<small>',lksi.lnum,lsij[i],'</small>');
    //if lksi.lnum>1 then continue;
    _getvoks(lsij[i],lksi.sija.ending+lksi.lisuke,lksi);
    except writeln('!!!!!!!!!!!!');end;
  end;
  lsij.free;
  //exit;
  if hit<>'' then writeln(' <b>++',  orig,'</b> ')
  else writeln('<b style="color:red">',orig,'</b> ' );
  //for i:=0 to xyhdys.count-1 do writeln('<li>',xyhdys[i]);
end;

procedure tsanasto.pronominit;
var prons,apron:tstringlist;i,j,m,c:word;rev,prevsan:string; b1,b2:boolean;
   maxlen,maxi:integer;ntab,nsans:array[1..100] of array[0..34] of string;
   lems:array[0..70] of string;
   runks:array[0..70] of string; runk,pro:string;rlen,ekaspace:word;
   sa:word;pers,dem,refl,qnt,interr,rel,ALL,lemma,plemma,muoto,sana,moni:string;ALPRO:TSTRINGLIST;
   tupla:boolean;
begin
  prons:=tstringlist.create;
  apron:=tstringlist.create;
  apron.StrictDelimiter:=true;
  apron.Delimiter:=',';
  writeln('vitunpronominit');
  prons.loadfromfile('pronominit.taivu');
  writeln('pronominit.taivu',prons.count);
  for i:=0 to prons.count-1 do
  begin
    try
   apron.DelimitedText:=prons[i];
   //writeln('<li>PRO:::',prons[i],':::',apron.count);
   for j:=0 to apron.count-1 do
   begin
    ekaspace:=pos(':',apron[j]);
    sana:=copy(apron[j],1,ekaspace-1);
    if j=0 then begin lemma:=sana;lems[i]:=sana;writeln('{',i,lems[i],'}');end;
    muoto:=copy(apron[j],ekaspace+1);
    rev:=voktakarev(sana,b1,b2);
    //writeln('<li>onko:',apron[i],'>',sana,'|',muoto,'| ',rev);
    maxlen:=-1;maxi:=-1;
    for m:=0 to 33 do
    begin
       //if pos(copy(nsijat[j].name,2,12),muoto)>0 then
     //writeln('?',nsijnams[m]);
       if nsijnams[m]=muoto then
       begin
         if (nsijat[m].ending='') or (pos(nsijat[m].ending,rev)=1) then
           begin
            //writeln('=',nsijat[m].ending);
           if (length(nsijat[m].ending)>maxlen) or (maxlen<0) then
              begin
                maxlen:=length(nsijat[m].ending);maxi:=m;
              end;
           end
         ;//else writeln('<li>EIEI[',j,nsijat[j].ending,'/',sana,']',nsijnams[m]);
       end;
     end;
     if maxi<0 then writeln('<li>eimuoto ///<b>',apron[j],'</b>') else
     begin
     //writeln(maxi,nsijat[maxi].name,' <b>',nsijat[maxi].ending,'</b> ',apron[2]);
     ntab[i,maxi]:=copy(sana,1,length(sana)-maxlen);
     nsans[i,maxi]:=sana;//+'|'+reversestring(NSIJAT[MAXI].ending);
     writeln(' ::<b>[',i,'/',maxi,']</b> ',ntab[i,maxi],':: ');
     end;
    end;
    except writeln('failnommuoto:',i,'#',prons[i]);end;

  end;
  writeln('<hr>donene');
 {  exit;
  aLpro:=tstringlist.create;
  //prons.sorted:=true;
  //prons.loadfromfile('pron3.tmp');
  Pers:='min‰,me,sin‰,te,h‰n,he';
  Dem:='t‰m‰,n‰m‰,tuo,nuo,se,ne';
  Refl:='itse';
  Qnt:='jompikumpi,jompi,kukin,mikin,mik‰‰n,joku,jokin';
  moni:=',me,te,he,n‰m‰,nuo,ne,';
  Interr:='kuka,mik‰';
  //Qnt:='muu,jompikumpi,kaikki,kumpikin,kumpikaan,kumpainenkaan,kukin,kukaan,mikin,mik‰‰n,er‰s,joku,jokin,moni,mones,molemmat,usea,jokainen,toinen,muutama,sama,yksi';
  //Interr:='kuka,kumpainen,kumpi,mik‰';
  Rel:='joka,mik‰';
  ALL:='!Pers,'+pers+',!Dem,'+dem+',!Refl,'+refl+',!Qnt,'+qnt+',Interr,'+interr+','+rel;
  writeln('taivuteta pronominit',all);
  alpro.COMMAText:=all;
  for i:=0 to alpro.COunt-1 do
  if pos('!',alpro[i])=1 then
  begin
    pro:=' Pron '+copy(alpro[i],2);
  end   else
  begin
  for j:=0 to 33 do   if (j=0) or (nhfstnams[j]<>nhfstnams[j-1]) then
   //writeln('<li>',alpro[i]+pro,copy(nhfstnams[j],2));
   prons.add(alpro[i]+pro+copy(nhfstnams[j],2));
  end;
  prons.savetofile('pronominit.tohfst');
  if not fileexists('pronominit.ana') then begin writeln('<li>run fiana to pronominit.ana first');exit;;end;
  prons.LoadFromFile('pronominit.ana');
  writeln('taivutetut pronominit ladattu');
  apron:=tstringlist.create;
  apron.StrictDelimiter:=true;
  apron.Delimiter:=chr(9);
  //writeln(prons.text,prons.count);
  //exit;
   sa:=0;
   tupla:=false;
   for i:=0 to prons.count-1 do
   begin
     if prons[i]='' then begin tupla:=false;continue;end;
     apron.DelimitedText:=prons[i];
     ekaspace:=pos(' ',apron[0]);
     lemma:=copy(apron[0],1,ekaspace-1);
      muoto:=copy(apron[0],ekaspace+1);
     if pos(','+lemma+',',moni)>0 then muoto:=replacestr(muoto,'Pl','Sg');//muoto:=copy(muoto,length(muoto)-2
     //if pos(','+lemma+',',moni)>0 then writeln('<h4>xxx',lemma,' ',muoto,'</h4>');;//muoto:=copy(muoto,length(muoto)-2
     if lemma<>plemma then inc(sa);
     lems[sa]:=lemma;
     plemma:=lemma;
     //sana:=copy(apron[1],1,5);//pos(' ',apron[1])-1);
     sana:=apron[1];
    // writeln('<li>',apron.commatext,' #',sa,': ');
     //continue;
     //if apron[0]<>prevsan then begin inc(sa);lems[sa]:=apron[0];IF ALPro.indexof(apron[0])<0 then writeln('<h1>******',apron[0],'</h1>');end;
     prevsan:=apron[0];
     if pos('?',apron[1])>0 then continue;
     rev:=voktakarev(apron[1],b1,b2);
     maxlen:=0;maxi:=0;
     for j:=0 to 33 do
     begin
       //if pos(copy(nsijat[j].name,2,12),muoto)>0 then

       if pos(copy(nhfstnams[j],3,12),muoto)>0 then
       begin
        if pos(nsijat[j].ending,rev)=1 then
           begin
           if (length(nsijat[j].ending)>maxlen) or (maxlen=0) then
              begin
                maxlen:=length(nsijat[j].ending);maxi:=j;
              // writeln('<li>[',j,nsijat[j].ending,'/',rev,maxi,']');

              end;
           end;
       end;
     end;
     if tupla then writeln(' ///<b>',apron[1],'</b>') else
     writeln('<li><b>',lemma,'</b> ',muoto,':<b>',sana,'</b> #',sa,':',maxi,': ');
     //writeln(maxi,nsijat[maxi].name,' <b>',nsijat[maxi].ending,'</b> ',apron[2]);
     ntab[SA,maxi]:=copy(sana,1,length(sana)-maxlen);
     nsans[SA,maxi]:=sana;//+'|'+reversestring(NSIJAT[MAXI].ending);
     tupla:=true;
  end;
  }
   for i:=0 to prons.count-1 do
   begin
     runk:=lems[i];rlen:=length(runk);
     writeln('(',runk,'#',i,')');
     for j:=0 to 33 do
     begin
       if ntab[i,j]='!' then  continue;
       if ntab[i,j]='' then  continue;
      write('(',ntab[i,0],')');
      try
      for c:=1 to rlen do if runk[c]<>ntab[i,j][c] then begin runk:=copy(runk,1,c-1);rlen:=length(runk)end;// else write(runk[c]);
      //writeln(ntab[i,j],' <b>',runk,'</b>');
      runks[i]:=runk;
     except writeln('<li>failrunk:',i,'/',j,'@',c,'/',ntab[i,j],'\',runk,'!');end;
     end;
  end;

   writeln('RUNSDONE<style type="text/css"> td { contenteditable:"true"} </style><table border="1">');
   apron.clear;
  for i:=0 to prons.count-1 do
  begin
    writeln('<tr><td>',lems[i],' </td><td>',runks[i],'</td>');
    for j:=0 to 33 do    if ntab[i,j]='' then writeln('<td>!</td>') else
    writeln('<td>',copy(ntab[i,j],length(runks[i])+1),'</td>');//,'<small> ',reversestring(nsijat[j].ending),'</small></td>');
    writeln('</tr>');
    {
    writeln('<tr><td></td>');
    for j:=0 to 33 do
    begin
      if nsans[i,j]='' then writeln('<td>!') else    writeln('<td><b>',nsans[i,j],'</b>');
    writeln(' <br><b>',reversestring(nsijat[j].ending),' </b>',nsijat[j].name,'</td>');//,'<small> ',reversestring(nsijat[j].ending),'</small></td>');
    end;
    writeln('</tr>');
    writeln('<tr><td></td>');
    writeln('</tr>');
    }
  end;
  writeln('</table>');

end;
procedure tsanasto.haelista;
var i,j:word;haku:tstringlist;hakust:string;
begin
  try
  writeln('</pre>');
  haku:=tstringlist.create;
 //FOR I:=0 to 66 do      writeln('<li>',i,reversestring(vsijat[i].ending),' /',vsijat[i].name,'/',vsijat[i].esim);

  hakust:='sousi,souti,yˆ,tˆill‰,tekiv‰t,puhella,surivat,surisi,surra,surisivat,pure,puri,purree,pierret,piereskelev‰t,l‰hdetty,lahdatut,pullauttanee,oli,aito,k‰sin,toisin,sousi';

  hakust:=hakust+',minusta,minun,t‰h‰n,sihen,siihen,tuota,tota';
  hakust:=hakust+',kansi,korren,kantta,puhella,leikell‰,leikkeli,pelkoon,mutustelkoon';
    hakust:=hakust+',sousi,susi,limatauti,tuskattomasti,huonommin,';
  hakust:='poutii,tuntee,tiet‰‰,sontii,l‰htee,';
  haku.commatext:=hakust;
  //haku.loadfromfile('haku.txt');
  //writeln('<li>HAU:',haku.commatext);
  haku.text:=ansilowercase(haku.text);

  //for j:=1 to 1000 do
  //for i:=0 to 65 do   findone(vsijaesim[i]);
  for i:=0 to haku.count-1 do
   findone(haku[i]);
 //listaa;
 except  writeln('<li>findfail');end;


end;
constructor tsanasto.create;
var i,j:word;
begin
writeln('LUEKAIKKI');
 //etsiyhdys;exit;
 luekaikki;
 //pikakelaa;
 for i:=9991 to 78 do
 begin
    writeln('<li>',i, getluokkasija(i,2).lisuke);
 end;
 try
 //listaa;
 //savebin;
 //readbin;
  //pronominit;
  exit;
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
var  sanalista,osalista,prevosat,kaikkikokot:tstringlist;i,j,dif,pdif,ahits,vhits:word;//p_vo,p_av,p_lk:string;
 //var turha:string;
    procedure uusavkon;
      begin
       try
        kons[ckon].vikasana:=csan;
        //writeln('<small>',cvok,'/',ckon,'</small>');
        ckon:=ckon+1;
        kons[ckon].ekasana:=csan+1;

        kons[ckon].voklka:=cvok; //mink‰ loppuvokaalin alla on ("sis" nimi oiis hyv‰ muuttaa joskus "lvok" tms
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
      writeln(siss[cvok].ekaav);
      //turha:=osalista[1];    if (turha<>'') and (pos(turha[1],konsonantit)>0) then delete(turha,1,1);    if length(turha)>1 then if tuplavok(turha[2],turha[1]) then writeln('+',turha) else writeln('-',turha);

      siss[cvok].sis:=(osalista[1]);//itse loppuvokaalit
      siss[cvok].lklka:=clka;  //luokka on jo kasvatettu, t‰m‰ kuuluu siihen uuteen
      //write('==',clka,' :',cvok,siss[cvok].sis);
      EXCEPT WRITELN('failsis:',cvok,'/',osalista.count,'/',length(siss));END;
         //if osalista[2]='k*' then
          //if clka=73 then              writeln('<li>VOK:<b>',osalista.CommaText,'</b> [',avs[ckon].v,avs[ckon].h,']');
      finally //writeln('')
      ;end;
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
  finally //writeln('</ul>');
  end;
end;
 var lksija:tluokkasija;m:byte; var sikoja:byte;  OLIJO:boolean;   k,ks:word;
begin
  //verbit.listsijat;
  //exit;                             sizeof
  //ongelmia .. collie, zombie 05 ei i-loppu..  veks?'
  //Y÷ paloiteltu v‰‰rin
 writeln('LUEsijat<ul>');
  cvok:=0;ckon:=0;csan:=0;clka:=1;
  sanalista:=tstringlist.create;
  osalista:=tstringlist.create;
  osalista.delimiter:=',';
  prevosat:=tstringlist.create;
  prevosat.delimiter:=',';
  sanalista.loadfromfile('uuskaavas3.lst');
  sanalista.sort; //oli kai valmiiksikin
  pdif:=2;
  ahits:=0;
  vhits:=0;
  scount:=0;
  kons[0].ekasana:=2;
  prevosat.delimitedtext:=sanalista[0];
  //writeln('<ul><li>luesanat:',prevosat.commatext,'<ul style="margin:0en;padding:0em;border:1px solid red"><li>loukka:');
  //  ,prevosat[0],'<ul><li>vok:',prevosat[1],':<ul><li>kon;',prevosat[2],':ekasana',prevosat[3],':');
  kaikkikokot:=tstringlist.create;kaikkikokot.sorted:=true;
  for i:=0 to sanalista.count-1 do
  begin
    try
    osalista.delimitedtext:=sanalista[i];
    kaikkikokot.add(osalista[6]);
    {//if length(osalista[3])>1 then  continue;
    //ks:=0;for k:=1 to length(osalista[5]) do if pos(osalista[5][k],vokaalit)>0 then break else inc(ks);
    //if  pos(osalista[5][1vokaalit)>0 then continue;
    //if (length(osalista[3])<2) //or  (ks>1)  //halutaan poimia sanat joiden alkukons ei ole rungossa
    if (osalista[2]<>'_') and (osalista[2]<>'') then continue;
     writeln('<li>__',sanalista[i]);
    //if (length(osalista[2])>1) and (osalista[2][1]='_') then continue;
    //writeln('<li>__<b>',sanalista[i],'</b>',osalista[2]);
    continue;}
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
   // t‰‰ oli v‰‰rin tiedostossa: rungot[csan].takavok:=osalista[4]='1';
   rungot[csan].takavok:=osalista[5]='0';
   rungot[csan].akon:=osalista[4];
   rungot[csan].koko:=osalista[6];
   {try if pos(rungot[csan].san[1],konsonantit)<1 then
    if (kons[ckon].v='') or (kons[ckon].h='') then
    if tuplavok(rungot[csan].san[1],siss[cvok].sis[length(siss[cvok].sis)]) then
    if clka<>67 then
    writeln(reversestring(siss[cvok].sis+'.'+kons[ckon].v+'.'+rungot[csan].san),'<b>[',kons[ckon].v, kons[ckon].h,']</b>',clka);
   except writeln('<li>',sanalista[i]);end;}
    //UUSNO sans[csan].akon:=(sl[6]);
    //if sl[4]='0' then avs[ckon].takia:=avs[ckon].takia+1;  //lasketaan takavokaalisten m‰‰r‰‰ av-luokassa hakujen tehostamiseksi
    //if osalista[0]='73' then if osalista[2]='k*' then     writeln('<li>KKK',osalista.CommaText,' [',avs[ckon].v,',',avs[ckon].h,']');
    prevosat.delimitedtext:=sanalista[i];
   // if i mod 100=0 then writeln(hyphenfi(osalISTA[5],OSALISTA),OSALISTA.COMMATEXT);
    except writeln('!!!',sanalista[i],'(',dif,')',prevosat.commatext,prevosat.count);end;
 end;
  //writeln('</ul></ul></ul><h3>luettu:',clka,' ',cvok,' ',ckon,' ',csan,'</h3> ',lks[1].ekasis,'/',siss[1].sis);
  lks[clka].vikasis:=cvok;
  siss[cvok].vikaav:=ckon;
  kons[ckon].vikasana:=csan;
  scount:=csan;
  vokcount:=cvok;konscount:=ckon;
  writeln('<li>');
   FOR I:=0 to vokcount-1 do    writeln(' ',siss[i].ekaav);
   //tilap‰inen viritys yhdyssanohen etsimseen
 kaikkikokot.savetofile('kaikki.kok');
 // etsiyhdys(kaikkikokot);
  //lks[1].ekasis:=0;
  //for clka:=52 to 78 do
  //for clka:=1 to 49 do
end;

procedure tsanasto.listaa;
var csan,cvok,ckon,clka,i,j,k,mm:word;
   ssan,svok,skon,slis,SVAHVA,SHEIKKO:string;
   msan,mvok,mkon,mlis,xtra,koko,sofar:string;olijo:word;KALERT,vokalert:boolean;
   lksija:tluokkasija;luokka:tlka; maxv,maxc:byte;perustavu,oletustavu:INTEGER;
   tavus:tstringlist;
   tavuc:byte;tavucs:array[0..79] of array[0..65] of array[0..8] of word;
   testi,maxtavut:tstringlist;
//var  //sanalista,osalista,prevosat:tstringlist;i,j,dif,pdif,ahits,vhits:word;//p_vo,p_av,p_lk:string;
 begin
 //maxtavut.loadfromfile('
 for clka:=1 to 48 do
 begin
   //writeln('<li>LKA:',nexamples[i]);
   for j in [0,1,2,11,12,13,15,20..33] do
   begin
   lksija:=getluokkasija(clka,j);
    writeln(' ',reversestring(lksija.sija.ending+'.'+lksija.lisuke));
   end;
 end;
   for clka:=1 to  78 do
   begin
   try
   if  (clka in [22,49,50,51]) then begin continue; end;
   //if clka>62 then break;
   try
   writeln('<li>LKA::',clka,' ',lks[clka].vahva,': ',lks[clka].ekasis,' //');//,maxtavut[clka] );
   except write('paska');end;
   try
   for cvok:=lks[clka].ekasis to lks[clka].vikasis do writeln(' <b>:',siss[cvok].sis,'</b>');
   writeln('<ul>');
   for cvok:=lks[clka].ekasis to lks[clka].vikasis do
   begin
     writeln('<li><b>','{',siss[cvok].sis,'}</b><ul>');//,'<ul>');
     sVOK:=siss[cvok].sis;
     olijo:=0;
     for ckon:=siss[cvok].ekaav to siss[cvok].vikaav do
     begin
       SVAHVA:=kons[ckon].V;
       SHEIKKO:=kons[ckon].H;
       kalert:=(svahva+sheikko='k');//if not kalert then continue;
       if sVAHVA=SHEIKKO THEN if olijo>1 then  CONTINUE else if not kalert then inc(OLIJO);
       writeln('<b>[',kons[ckon].v,kons[ckon].h,']</b> ');
       //for j:=kons[ckon].ekasana to min(10+kons[ckon].ekasana,kons[ckon].vikasana)  do      writeln(' ',reversestring(rungot[j].san));
       //for j in [0,1,2,11,12,13,15,20..33] do
       //for j in [0,5,12,15,22,28,36,38,44,61] do
       //for j in [0,5,11,23] do
       for j:=0 to 66 do  //sijat
       begin
       if clka in [21,50,51] then continue;
       if clka<50 then if not (j in [0,1,2,11,12,13,15,20..33]) then continue;
       if clka>50 then if (clka<>71) and (not (j in [0,5,10,11,12,15,22,27,28,36,38,44,61])) then continue;
        if j=12 then if not lks[clka].vahvA then continue;
         lksija:=getluokkasija(clka,j);
         for mm:=1 to lksija.muotoja do
         //if mm<>1 then CONTINUE ELSE
         BEGIN
           try
             if mm=2 then lksija:=lksija.toinenmuoto;
             if lksija=nil then writeln('fail nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn:',clka,' ',j);
             slis:=lksija.lisuke;
             mlis:=slis;
             if slis='!' then continue;
             try
                 mkon:=ifs(lksija.vahva,svahva,sheikko);
                 mvok:=svok;
                 xtra:='';
                 if lksija.tuplakon then if clka=28 then  begin mvok:=mvok+mvok[1];end
                 else begin mlis:=mvok[1]+mlis;end;
                 except writeln('fuck',clka,' ',j);raise;end;
                 except writeln('<li>faillisue:<b>',clka,'#',j,j,'</b> ','/vok:',mvok,mlis,'/kon:',mkon,'/msan:',msan,'/',lksija.sija.num,' \tv',lksija.tuplavok,' tk',lksija.tuplakon,' ev',lksija.eatvok,' e2',lksija.eat2vok,' cv',lksija.copyvok,'</li>');end;
                 try
                     if lksija.tuplavok then begin mlis:=mvok[1]+mlis; end;
                 if lksija.copyvok then begin mlis:=mlis+mvok[1]; end;
                 if lksija.eat2vok  then begin mvok:=copy(mvok,1,1);end;
                 if lksija.eatvok  then begin mvok:=copy(mvok,2);end;
                 if lksija.eatkon  then begin delete(mkon,1,1);end;
             except writeln('((fail!!!))');end;
             try
             for csan:=kons[ckon].ekasana to kons[ckon].ekasana do //vikasana do
             begin
                try
                try
                 //if   length(rungot[csan].san)>7 then continue;

                 msan:=rungot[csan].san;
                except writeln('<li>noeatkon::',j,'.',mm);raise;end;
                try
                 koko:=rungot[csan].akon+reversestring(lksija.sija.ending+''+mlis+mvok+mkon+msan);
                except writeln('failtavu:',clka,'_',j);end;
                try
                 if not rungot[csan].takavok then koko:=etu(koko);
                  writeln(koko);
                 //if (tavuc-perustavu<>oletustavu) or (svahva+sheikko='') then
                 //writeln('<em style="color:red">',mm ,koko,'</em>/ ') //
                   //,copy(rungot[csan].san,1,2));//,sofar[1],lksija.vahva,kalert,rungot[csan].san[1],svok[1]);//,tuplavok(rungot[csan].san[1]),svok)
                   //else if clka=71 then                    writeln(' <em style="color:green">',mm, koko+'</em>');//,tavuc,'\',oletustavu,'/p:',perustavu,'.',j);//,copy(rungot[csan].san,1,2),sofar[1],lksija.vahva);
                  except writeln('<li>fail write');end;
                 except writeln('<li>failSIJA:<b>',clka,'#',j,lksija.sija.ending,'</b>',mlis,'/',lksija.sija.num,' \tv',lksija.tuplavok,' tk',lksija.tuplakon,' ev',lksija.eatvok,' e2',lksija.eat2vok,' cv',lksija.copyvok,'!</li>');end;
             end;
         //EI AV  62 63 64 65 68 69 70 71 77
         //END
         except writeln('FAILSIJAT',mm,'/',lksija=nil,'!!');end;
         IF LKSIJA.MUOTOJA=2 THEN writeln('<b style="color:red">///',mm,'</B>');
         END;
       end;
    end;
    writeln('</ul>');
   end;
   except writeln('<li>faillka:',clka);end;
   finally writeln('</ul>');end;

   end;


 end;

procedure tsanasto.luokaavat;
   function aste(koodi:char):string;
   var av:string;
   begin
   case koodi of
   'A': av:='k*' ;
   'B':  av:='p*' ;
   'C':   av:='t*' ;
   'D':  av:='k*' ;
   'E':  av:='pv' ;
   'F':  av:='td' ;
   'G': av:='kg' ;
   'H':  av:='pm' ;
   'I':  av:='tl' ;
   'J':  av:='tn' ;
   'K':  av:='tr' ;
   'L':  av:='kj' ;
   'M':  av:='kv' ;
   '0': av:='--';
   else av:='xxx';
  end;
   result:=av;
   // katoavat konsonantit kpt - pt vai pp->p tt>t; k usean eri konsonantin kanssa, mutta myˆs yksitt‰in koko ->koon aie aikeen
   // poimitaan erikseen yksitt‰isen koon katoamiset koko koo katoaa

 end;
   // Koko 1D      kokko 1A   tuhka 10D kokko ja tuhka k‰ytt‰ytyv‰t samoin, koko eri..
   var osat,tavut,sanakaavat,muotokaavat:tstringlist;  lkasofar:word;prevlka,rivi,cut,lkmid:string;lksij:tluokkasija;
   //mfile:text;
   procedure testt(st:string);
   begin
      writeln('<li>',st,hyphenfi(st,osat),osat.commatext);
   end;
   var f:text;s,sss,prevav:string; n:word;    i,j,k,jj,slen:word;olia,prevlk,ordo:word;
         pALA:WORD; sanaav,muotoav,myvok,mymid,color,takasana:string;
     var s_v,s_a,s_s,s_x,s_ak:string;
          outo,vahva:boolean;
          xxx:tstringlist;
          olietu:word;
          LKSIJA:TLUOKKASIJA;
     ylimvok:string;
   begin
   writeln('<h1>luokkkaavat</h1>');//<table border="1"><tr>');
   osat:=tstringlist.create;
   muotokaavat:=tstringlist.create;
   tavut:=tstringlist.create;
   sanakaavat:=tstringlist.create;
   sanakaavat.sorted:=true;
   //testt('aiettakaan');    testt('traiettakaan');   testt('hauilla');   testt('aieoittra');  exit;
//////////test;
//assign(f,'nomsall.lst');
ordo:=0;
assign(f,'uussanat2.all');
 reset(f);
 while not eof(f) do
 begin
   readln(f,s);
   //s:=taka(s);
   osat.commatext:=s;
   n:=strtointdef(osat[0],999);
   if n<>prevlk then begin prevav:='x';end;
   prevlk:=n;
   if (n>49) AND (N<52) THEN CONTINUE;
   //if n<50 then lkmid:=nominit.lmmids[n,0] else lkmid:=verbit.lmmids[n-52,0]  ;
   lksij:=getluokkasija(n,0);
   lkmid:=lksij.lisuke;
   takasana:=taka(osat[2]);
   if n>50 then takasana:=copy(takasana,1,length(takasana)-1);
   try

  // writeln(n,nominit.lmmids[n,0],pos(nominit.lmmids[n,0],osat[2]));
    //if lkmid='' then
    ylimvok:='';
   if lkmid<>'' then if pos(lkmid,vokaalit)>0 then  ylimvok:=lkmid[1];//verbien tuplavok-loppu sanoa palaa
   //sss:=reversestring(copy(takasana,1,length(takasana)-length(lkmid))); //purk ->krup  sanoa ->san
   sss:=reversestring(copy(takasana,1,length(takasana)-length(lkmid))); //purk ->krup  sanoa ->san
   //if ylimvok<>'' then writeln(sss);
   if ylimvok<>'' then sss:=ylimvok+sss; //en tajuuu, mutta toimii. verbien tuplavok pit‰‰ tilap‰isesti panna mukaan analysoitavaksi
   slen:=length(sss);
   //continue;
   PALA:=0;
   s_v:='';//ss[1];
   s_a:='';s_s:='';s_x:='';
   //if length(ss)>6 then continue;
   //writeln('<li>:',S,'!',ss);   continue;       //ruis IUR,
   cut:='?';

   if 1=1 then if lksij.tuplakon then //RUMAA  puhella, purra
   begin
     try
     CUT:='X';
     s_v:=copy(sss,1,1);
     //s_v:=s_v+s_v;
     //if osat[1]='D' then s_v:=s /
     sss:=copy(sss,3);  //jael|la  jute|l     kansi i| nak
     slen:=slen-2;

     except      writeln('!!!fail{',sss,'/',s_v,'}');end;
   end;// else
   try                                                   //n /ak
   //if n=28 then begin writeln('........',s,'..[',sss,']');s_v:=sss[1];s_s:=copy(sss,2);cut:='L'; writeln('/',s_v,'/..[',s_s,']')end else
   if n=28 then   writeln('<li>',cut ,'<b>[[',reversestring(sss),'/',s_v,'(',osat[1],')',s_s,']]</b>');

   if (osat[1]='D') and ((n>31) and (n<50) or (n>65)) then
   begin
       try
        //::67 [c] e,k*,aj \67 D jaella [+]: k*((k*)) ja..0 {ledhalia}
       cut:='Kvex';
       if  pos(sss[1],konsonantit)>0 then
        begin s_v:=s_v+copy(sss,1,2);s_s:=copy(sss,3); end
             else begin s_v:=s_v+copy(sss,1,1);s_s:=copy(sss,2); end;
        s_a:='';
     except writeln('<li>failK:');end;
   end   else
     //if (n>50) and (pos(ss[1],konsonantit)>0) and (not lksij.tuplakon)  then begin  s_v:='';s_a:=ss[1];s_s:=copy(ss,2);cut:='x';end
   if (slen=1) or (pos((sss)[2],konsonantit)>0) then
     begin  //Kun perusmuodon p‰Âte ja luokkasijan vakio (jos ei vokaali) poistettu, vika on vok ja tokavika kon: ukko-''  hapan-'n'
        // purkaa ->purka -> ss=krup       --> vok:''  s_a:k* s_s:rup
       //if lkvok='' then   antaa >tna
        try
        cut:='KV:';
        s_v:=s_v+sss[1];  //k       t
        if slen>1 then s_a:=sss[2];  //r           n
        s_s:=copy(sss,3);//up       a
        except writeln('failxx!!!');raise;END;
     end //else                                        //       k         r
   else
     if (length(sss)>1) and (isvokraja(sss[2],sss[1])) then
     begin cut:='vokvok';s_v:=sss[1]+s_v;s_a:='';s_s:=copy(sss,2);
     end //  VOK-tavuraja lopussa     .. l‰hte‰ eth-‰l
//??   else if (length(sss)<3) then begin cut:='d';s_v:=s_v+copy(sss,1,1);s_a:='';s_s:=copy(sss,2);end  //  lyhyt runko (kun lka syˆnti vex)
   else if (length(sss)>1) and (pos(sss[2],konsonantit)>0) then
    begin
       cut:='vkon'; //ei oo?

       s_v:=s_v+copy(sss,1,2);s_a:=copy(sss,3,1);s_s:=copy(sss,4);   //kons lopussa kun syˆty
    end //+inttostr(length(s_s)
   else if (length(sss)>2) and (pos(sss[3],konsonantit)>0) then
    begin s_v:=s_v+copy(sss,1,2);s_s:=copy(sss,4);cut:='DFT';s_a:=sss[3];
    end      //ei esiinny???
   else begin ////   diftongi
     cut:='dftv';s_v:=s_v+copy(sss,1,2);s_a:='';s_s:=copy(sss,3); end; //rangaista ts-iagnar
   except writeln('fAILPILKO1:',S,'!',sss,slen);END;
   except writeln('fAILPILKO2:',S);END;
   try
   if ylimvok<>'' then delete(s_v,1,1);       //2*vok verbs   aakkostaa.. miksi tonne oli tullut tuo ylim‰‰r‰inen

  sanaav:=aste(osat[1][1]);
  if pos(osat[1],'ABC')>0 then   //kk,pp,tt
    IF ((n>31) and (n<50))  //heikko nomini
     or (n>=67) then if pos(s_s[1],konsonantit)<199 then //heikko verbi
       s_s:=sanaav[1]+s_s ;//laitetaan av-tuplakons itse sanaan
  except writeln('<li>failx',s);end;
   try
   //mit‰ vittuu ... if n>31 then if (s_s='') or (pos(s_s[1],konsonantit)<1) then s_s:=s_a+s_s;
   // if (s_s='') and (osat[1]='0') then begin s_s:=s_a;s_a:='';end;
   if length(takasana)=2 then begin writeln('<li>yˆyˆy:',osat[2]);sanaav:='';s_v:=reversestring(takasana);s_s:='';end; //Y÷
   //62 eiav 63 64 65 68 69 70 71 77
   //if  lksij.tuplakon then writeln('<b>{',ss,'/',s_v,'}</b>');
   //if s_s='' then if
   if sanaav='--' then sanaav:='_'+s_a;

   if n=28 then   writeln(2,cut ,'<b>{{',reversestring(sss),'/',s_v,'(',sanaav,')',s_s,'}}</b>');
   //if cut='d' then   writeln(2,cut ,'<h2>',reversestring(sss),'/',s_v,'(',sanaav,')',s_s,'}}',s,'</h2>');
   s_ak:='';
   if   s_s='' then begin if length(sanaav)>1 then s_Ak:=sanaav[2];sanaav:=''; end
     else for k:=length(s_s) downto 1 do if pos(s_s[k],vokaalit)>0 then break else begin s_ak:=s_ak+s_s[k];delete(s_s,length(s_s),1);end;

   if ontaka(osat[2]) then olietu:=0 else olietu:=1;
  //        WRITELN(OSAT[2],olietu);
   sanakaavat.Add(AddChar('0', inttostr(n),2)+','+(s_v+','+sanaav+','+s_s)+','+s_ak+','+inttostr(olietu)+','+osat[2]);
   //if n=6 then writeln('<li><b>vok:',s_v,'/asv:',s_a,'/san:',s_s,'//',reversestring(sss),'</b>',s_ak);
   except writeln('<li>failwrite',s);end;
   //if pos(osat[1],'ABCD')>0 then
   //if (osat[1]<>'0') or ((pos('_',sanaav)=1) and (length(sanaav)=2))
   //if pos(osat[1],'ABC')<1 then continue;
   //if pos(s_s[1],konsonantit)>0 then continue;
   //if sanaav='_' then
   //if n in  [60,66] then
   //if lkmid<>'' then if pos(lkmid,vokaalit)>0 then
   //if   s_s='' then
          //if length(sanaav)=2 then if sanaav[1]<>'_' then
          //   writeln('<li>:::',inttostr(n)+' <b>[',cut,reversestring(sss),']</b> ',s_v+'('+sanaav+')'+s_s+','+','+osat[2]);
   continue;
     if mymid='!' then
     writeln('<small style="color:#4cc">',reversestring(nsijat[j].ending+mymid+myvok+muotoav+s_s),'</small>')
     else writeln(reversestring(nsijat[j].ending+'.'+string(mymid)+'.'+myvok+muotoav+s_s),j);//,'<sub><sup>',j,muotoav,'</sup></sub>');

   end;

   //continue;
  // if osat[0]+<>prevlka then
 sanakaavat.SaveToFile('uuskaavas4.lst');
 prevlka:='';
end;
end.

//JƒTETƒƒN MY÷HEMMƒKSI, JA EHKƒ SILLOIN ALKUSOITUJEN ETSIMISEN YHTEYTEEN TAI SEMANTTISESTI VALITTUJEN SANOJEN YHDISTƒMISEEN
function vertaatav(st1,st2:string):word;
var akon1,vok1,lkon1,akon2,vok2,lkon2:string;  //ei riitt‰ne yksiulotteinen mora-laskuri
   i,j,valku,kalku,len:word;
   procedure pilko(var st,akon,vok,lkon:string);
   var i,j:word;len:byte;
   begin
     try
     len:=length(st);
     for i:=1 to len do if pos(st[i],vokaalit)>0 then
     begin akon:=copy(st,1,i-1);
       for j:=i+1 to len do if pos(st[j],vokaalit)<1 then
       begin
        vok:=copy(st,i+1,j-1);akon:=copy(st,j+1);
        break;
       end;
     end;
     except writeln('failpilko');end;
   end;
begin //0:avoin lyhyt;2:pehme‰stio suljettu avoin lyhyt,3:avoin 2-vok;4:avoin
 pilko(st1,akon1, vok1,lkon1);
 pilko(st2,akon2,vok2,lkon2);
 writeln(' [',st1,':',akon1,'.',vok1,lkon1,' //',st2,':',akon2,'.',vok2,lkon2,'] ');
end;


function sovitatavut(haettu,tutkittava:string):word;
//function kovalk(ta:string):boolean; begin end;
//function pehmoalk(ta:string):boolean; begin end;
{tavutyyppej‰ Avoimet suljetut lyh/pitvok,kova/pehme‰ lopkon
mora: 1:avoin 2:suljettu ai avoin 2-vok 3:sujettu 2-vokaalinen
  koitetaans; painolliset tavut pit‰‰ m‰ts‰t‰, painottomissa sama mora-- kast = kuis
}
  function mora(st:string):word;
  var i:word;
  begin
    result:=length(st);
     for i:=1 to length(st) do if pos(st[i],vokaalit)>0 then break else result:=result-1;
  end;
  var  i,j:word; pit,lyh:string; alkkon,tutrev:string;  sopi:boolean;ero:integer;penaltti:word;
begin              //1  2   3     4   5
  try              //a  aa  ai ak aak aik .. yksi miinus jokaisesta poikkeamasta.. ehk‰ viel‰ loppukons kovuus vaikuttaa (
   result:=0;
   if length(tutkittava)>7 then exit;
   tuttavuc:=hyphenfirev(tutkittava,tuttavut,alkkon);
   ero:=abs(tuttavuc-hakutavuc);
   //if tuttavuc>hakutavuc then begin pit:=tuttavut;lyh:=hakutavut;end else begin lyh:=tuttavut;pit:=hakutavut;end;
   if length(tutkittava)>length(haettu) then begin pit:=tutkittava;lyh:=haettu;end else begin lyh:=tutkittava;pit:=haettu;end;
   //arunko.koko,' ',reversestring(tutkittava),':',tuttavut.commatext,tuttavuc,':: ');
  // writeln('<li>---',alkkon+'_',tutkittava,' / ',haettu,' :');   exit;
   //for i:=0 to min(tuttavuc,hakutavuc)-1 do //wnto 0 do //vertaatav(tuttavut[i],hakutavut[i]);
   penaltti:=0;
   for i:=0 to length(lyh) do //wnto 0 do //vertaatav(tuttavut[i],hakutavut[i]);
   begin
       //if (pos(haettu[i],vokaalit)>0) <> (pos(tutkittava[i],vokaalit)>0) then begin inc(penaltti);end;
       if (pos(haettu[i],vokaalit)>0) <> (pos(tutkittava[i],vokaalit)>0) then begin inc(penaltti);end;
       if (pos(haettu[i],vokaalit)>0) then if haettu[i]<>tutkittava[i]then inc(penaltti);
       //if penaltti>1 then break;
    end;

   if pos(pit[length(lyh)+1],vokaalit)>0 then inc(penaltti);
  // writeln('<small>[',pit[i+ero],'/',lyh[i],']</small>');//except writeln('fail!',i);end;
   // if i in [1,3] then if tut
   if penaltti<1 then
   writeln(' ',arunko.akon+reversestring(tutkittava))
  ;//else  writeln(' <b>',arunko.akon+reversestring(tutkittava),'</b>');
   exit;
   if  (abs(hakutavuc-tuttavuc)<3) //jos jompikumpi pitk‰ ei tartte parillisuudesta v‰litt‰‰
     then if (hakutavuc mod 2<>tuttavuc mod 2) then inc(result,2);// satama, kama  ---raaka puolisointu
   //for i:=0 to lyh.count-1 do  if lyh[i]<>pit[i] then
   begin  //lasketaan penaltteja poikkeamista

   end;
   //writeln('<li>?:[',haettu,']',hakutavuc,hakutavut.commatext,' / [',tutkittava,']', tuttavuc,tuttavut.commatext,result);
   except writeln('failtavusov!');end;
end;
function fitvok(vok,sa:string):word;
var myvok:string;i:word;
begin
  try

   result:=1;
   try

   if (vok='') or (pos(vok,sa)=1) then begin result:=1;exit;end;
   if (diftongi(sa[2],sa[1])) and (diftongi(vok[2],vok[1])) then
       begin result:=1;end;
   except writeln('_');end;
   //if pos(vok,konsonantit)>0 then if pos(sa[1],konsonantit)>0 then begin try writeln('!',sa);turha:=vok+'/'+sa;delete(vok,1,1);delete(sa,1,1);except writeln('failekon:',vok,'/',sa); end end else exit;
   //if length(vok)=1 then if //pos(sa[1],vokaalit)>0 then begin result:=1;if sa[1]<>vok then turha:=sa[1]+'\'+vok;end;
   //  sa[1]=vok[1] then result:=1;
   //if length(vok)=2 then if pos(sa[1],vokaalit)>0 then  if pos(sa[2],vokaalit)>0 then begin writeln('§',sa);turha:='X';result:=1;exit;end;
//   if length(vok)=2 then if length(sa)>1 then if sa[1]<>sa[2] then if pos(sa[2],vok)>0 then if pos(sa[1],vok)>0 then//tuplavok(sa[2],sa[i])  then
//    begin writeln('#',sa[2],sa[1]);result:=1;turha:=turha+':'+vok+'/'+sa;end;
   //for i:=1 to length(sa) do if pos(sa[i],vokaalit)<1 then break else if myvok:=myvok+sa[i];
   //if length(myvok)=length(sa) then result:=1;
   except writeln('fixthis:',clk,vok,'@',sa);end;
end;

