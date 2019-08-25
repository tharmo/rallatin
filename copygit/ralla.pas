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
 nsijat:array[0..33] of tsija;
 vsijat:array[0..66] of tsija;
 pronot:array[0..19]  of tprono;
 //nluokkat:array[1..48] of tluokkasija;
 //vluokkat:array[52..78] of tluokkasija;
 vluokkasijat:array[52..78] of array[0..66] of tluokkasija;
 nluokkaSIJAT:array[1..48] of array[0..33] of tluokkasija;
 procedure luekaikki;
 function luenomsijat(fn:string):tstringlist; //hanskaa samalla sijojen luonti luettavat sisuskalut on 1/1 sijoihin (todin kuin verbeill‰, joilla on "protot")
 procedure lueverbisijat(fn:string);
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
   lsij,llk,lvok,lkon,lrun,YHDYS:tstringlist;  //muutetaan joskus omaksi luokakseen, nyt temppuillaan stringlistan objecteilla
   alksija:tluokkasija;      hit:string;
   ssan,svok,skon,slis:string;
   eietu,eitaka:boolean;
function _getsan(sa:string):boolean;var i,j:word;
begin
  for i:=akon.ekasana to akon.vikasana do
  begin
  try
   arunko:=rungot[i];
   ssan:=arunko.san;
   //if alk.kot in [62,76] then writeln('<li>runko:', ssan,':<em>(L:',slis,'/v:', svok+'/k:'+skon,',)</em> <b>',sa,'</b>');
      //                                  runko::              (L:eeni     /v:a/       k:n,)
   //if ssan='' then writeln('SANALOPPU:',arunko.koko,'/',arunko.san,i);
   //if (ssan='') or (pos(ssan,sa)=111) or (pos(sa,ssan)=1) then writeln('<li>HIT:',
   if (ssan=sa)  then
    //if (arunko.takavok and eitaka) then exit else
   //if ((not arunko.takavok) and eietu) then exit else
   begin
     hit:=hit+reversestring(slis+'.'+svok+'.'+skon+'.'+ssan)+'  ' +asij.name+' '+inttostr(alk.kot)+' '+inttostr(i)+ifs(arunko.takavok,'T','E');
   end
   else if  ((length(ssan)>2) and (length(sa)>2) and (length(ssan)-length(sa)>3) and (pos(sa,ssan)=1)) then //writeln('<em style="color:blue">',reversestring(copy(ssan,length(sa)+1)),'|</em>',rungot[i].koko)
   else if  ((length(ssan)>2)  and (length(sa)-length(ssan)>3) and (pos(ssan,sa)=1)) then
   BEGIN
   //  writeln('<em style="color:brown">[>>',rungot[i].koko,']</em>')
     YHDYS.ADD(rungot[i].koko+' '+reversestring(slis+''+svok+''+skon+''+ssan+'|'+copy(sa,length(ssan)+1)));
   END;
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
   //if alk.kot in [52] then writeln('<li>','kons;', akon.v,akon.h,':',skon,alksija.eatkon,alksija.lisuke,':', akon.ekasana,  reversestring(sane),' <em>(', skon+'.'+sa,')</em> ');
   if ssan<>'' then ssan:=copy(ssan,length(skon)+1);
   ssan:=sa;
   if alksija.eatkon  then begin skon:='';//delete(ssan,1,1);
   end;
   if (skon='') or (pos(skon,sa)=1) then
   begin
     //+asij.name+' ',alk.kot,' ',(rungot[akon.ekasana].koko),akon.ekasana);
     //if alk.kot=28 then writeln('<li>???:',svok,'|',sa,'>',ssan,'|<b>',skon,'</b>:',skon,alk.kot, '. ',rungot[akon.ekasana].koko,' ',' <b>(', reversestring(asij.ending+'.'+slis+'.'+svok+'.'+skon+'.'+ssan),')</b> ');
    //for i:=akon.ekasana to aakon.cikasana do
    _getsan(copy(ssan,length(skon)+1));
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
      except writeln('failslis????',slis,'/',sa);end;
      try
       for i:=alk.ekasis to alk.vikasis do //
       begin
          avok:=siss[i];
          svok:=siss[i].sis;
         //writeln('(',avok.sis,')');
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
         //if lksi.lnum in [52] then if lksi.snum<10 then writeln('<li>getvoks:',(sa),'<b>[',svok,']</b>=',lksi.reqnext,' ',lksi.notricks,alksija.sija.name);// //alk.esim,alk.ekasis,'..',alk.vikasis,
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
   var isi,ilk,i:integer;lksi:tluokkasija; orig:string;ii,jj,kk:word;
       //findone(
begin
  // vsijat[0].ending:='a';
  orig:=sane;
  lsij:=tstringlist.create;llk:=tstringlist.create;lvok:=tstringlist.create;lkon:=tstringlist.create;
  lrun:=tstringlist.create;YHDYS:=tstringlist.create;
    sane:=string(voktakarev(sane,eietu,eitaka));
  writeln('<li><b>',orig,'/',sane,'</b>::',lsij.commatext);//,orig,eietu,eitaka);
  for ii:=0 to 33 do
   if pos(nsijat[ii].ending,sane)=1 then
   begin
    //writeln('<li>',ii,nsijat[ii].ending,'?',copy(sane,length(nsijat[ii].ending)+1),'::');
     for jj:=0 to 19 do
     begin //write('[',jj,pronot[jj].lisukkeet[ii],']');
     if pos(pronot[jj].lisukkeet[ii]+pronot[jj].runko,copy(sane,length(nsijat[ii].ending)+1))=1 then
     begin
          writeln('<b title="',pronot[jj].lemma+'">:',reversestring(nsijat[ii].ending+''+pronot[jj].lisukkeet[ii]+''+pronot[jj].runko+pronot[jj].alkon),'</b>');
          //writeln('(',pronot[jj].lisukkeet[ii]+pronot[jj].runko,'=',copy(sane,length(nsijat[ii].ending)+1));

      end
         ;// else writeln('-',jj,pronot[jj].lemma,'/',pronot[jj].lisukkeet[ii]);
     end;
   end;
  exit;
  matchnomsijat(sane,lsij);
 // matchverbisijat(sane,lsij);
  hit:='';
  for i:=0 to lsij.Count-1 do
  begin
    try
    lksi:=tluokkasija(lsij.objects[i]);
    _getvoks(lsij[i],lksi);
    except writeln('!!!!!!!!!!!!');end;
  end;

  exit;
  if hit<>'' then writeln('<b style="color:green">',  orig,'</b> ')
  else writeln('<b style="color:red">',orig,'</b> ' );
  for i:=0 to yhdys.count-1 do writeln('<li>',yhdys[i]);
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
  hakust:='naisi,taisi,maustevoilla,lasten,lapsien,lapsi,jaahan,hakkuissa,jaihin,teehen,oisiin,happamien,koolla,koilla,kannen,kumpaan,keruuseen,keruihin,soihin,soista,suohon,tuttareen,tutarten,tutarta,asettimilla,liemiin,kantten,uhden,uksien,soitten,soiden,suolla,suolia';
  hakust:='sousi,souti,yˆ,tˆill‰,tekiv‰t,puhella,surivat,surisi,surra,surisivat,pure,puri,purree,pierret,piereskelev‰t,l‰hdettu,lahdatut,pullauttanee';
  hakust:='viisastua,s‰ilˆ‰';
  hakust:='kinuun,r‰nt‰,hulle,hommatta,seit‰,venen,kuta,noiksisiksi,min‰';
  haku.commatext:=hakust;
  //haku.loadfromfile('haku.txt');
  writeln('<li>HAU:',haku.commatext);
  haku.text:=ansilowercase(haku.text);
  for i:=0 to haku.count-1 do
   findone(haku[i]);
 //listaa;
 except  writeln('<li>findfail');end;


end;
constructor tsanasto.create;
var i,j:word;
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
var  sanalista,osalista,prevosat:tstringlist;i,j,dif,pdif,ahits,vhits:word;//p_vo,p_av,p_lk:string;
 //var turha:string;
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
      //turha:=osalista[1];    if (turha<>'') and (pos(turha[1],konsonantit)>0) then delete(turha,1,1);    if length(turha)>1 then if isdifto(turha[2],turha[1]) then writeln('+',turha) else writeln('-',turha);

      siss[cvok].sis:=(osalista[1]);//itse loppuvokaalit
      siss[cvok].lk:=clka;  //luokka on jo kasvatettu, t‰m‰ kuuluu siihen uuteen
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
 var lksija:tluokkasija;m:byte; var sikoja:byte;  OLIJO:boolean;
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
   // t‰‰ oli v‰‰rin tiedostossa: rungot[csan].takavok:=osalista[4]='1';
   rungot[csan].takavok:=ontaka(osalista[5]);
   rungot[csan].koko:=osalista[5];

   {try if pos(rungot[csan].san[1],konsonantit)<1 then
    if (kons[ckon].v='') or (kons[ckon].h='') then
    if isdifto(rungot[csan].san[1],siss[cvok].sis[length(siss[cvok].sis)]) then
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
  //lks[1].ekasis:=0;
  //for clka:=52 to 78 do
  //for clka:=1 to 49 do
end;

procedure tsanasto.listaa;
var csan,cvok,ckon,clka,i,j,k,m:word;
   ssan,svok,skon,slis,SVAHVA,SHEIKKO:string;
   msan,mvok,mkon,mlis,xtra,koko,sofar:string;olijo:word;KALERT,vokalert:boolean;
   lksija:tluokkasija;luokka:tlka; maxv,maxc:byte;perustavu,oletustavu:INTEGER;
   tavus:tstringlist;
   tavuc:byte;tavucs:array[0..79] of array[0..66] of array[0..8] of word;
   maxtavut:tstringlist;
//var  //sanalista,osalista,prevosat:tstringlist;i,j,dif,pdif,ahits,vhits:word;//p_vo,p_av,p_lk:string;
 begin
   maxtavut:=tstringlist.create;
   maxtavut.loadfromfile('vtavuja.plus');
   for i:=52 to 78 do writeln('<li>',maxtavut[i-51]);
   fillchar(tavucs,sizeof(tavucs),0);
   //writeln('testaasijattu',lks[1].ekasis);
   //for clka:=1 to 78 do begin writeln(i,nluokkasijat[clka-51,1].lisuke,nluokkasijat[clka-51,1].muotoja,' ');end;
   tavus:=tstringlist.Create;
   writeln(hyphenfi('hie',tavus),tavus.commatext);

   //for clka:=1 to 48 do begin writeln(nluokkasijat[clka,1].lisuke,@lks[clka]=(nluokkasijat[clka,1].luokka),' ');end;
   //writeln('<hr>');
   //for clka:=1 to 78 do begin lksija:=getluokkasija(clka,1);writeln(lksija.lisuke,lksija.luokka^.ekasis,'=',lks[clka].ekasis,' ');end;
   //writeln('<hr>');
   writeln('testaasissit:');
  // for i:=1 to 48 do writeln('\',getluokkasija(i,1).luokka.ekasis);
  // clka:=1 to  48 do //78 do
  for clka:=52 to  78 do
   begin
   try
   //if  (clka in [22,49,50,51]) then begin continue; end;
   //if clka>62 then break;
   try
   writeln('<li>LKA::',clka,' ',lks[clka].vahva,': ',lks[clka].ekasis,' //');//,maxtavut[clka] );
   except write('paska');end;
   try
   //writeln('<li>listaa:',clka,': ');
   //if clka<>28 then if clka<>67 then continue; //sikoja:=33 else begin
     // sikoja:=65;//continue;end;
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
       //for j in [0,5,9,12,13,16,23,36,37,39,45] do
       //for j in [0,5,11,23] do
       for j:=0 to 66 do  //sijat
       begin
         try
         //if j>10 then continue;
         //if not (j in [23..28]) then continue;
         //if clka<50 then if j>33 then continue;//if not ( j in [0,1,2,11,12,13,15,20..33]) then continue;
         //if not (j in [0,5,9,12,13,16,23,36,37,39,45]) then continue;
         lksija:=getluokkasija(clka,j);
         if lksija=nil then writeln('fail nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn:',clka,' ',j);
         slis:=lksija.lisuke;
         mlis:=slis;
         if slis='!' then continue;
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
                 if lksija.tuplavok then begin mlis:=mvok[1]+mlis; end;
             //  if lksija.tuplavok then begin mlis:=mlis+mvok[length(mvok)]; end;
             if lksija.copyvok then begin mlis:=mlis+mvok[1]; end;
             //if lksija.copyvok then begin mlis:=mvok[1]+mlis+'x'; end;
             if lksija.eat2vok  then begin mvok:=copy(mvok,1,1);end;
             if lksija.eatvok  then begin mvok:=copy(mvok,2);end;
             if lksija.eatkon  then begin delete(mkon,1,1);end;
          //if clka=48 then if j=11 then writeln(' <b>',lksija.sija.ending+'.'+mlis+'.',mvok+'.',mkon+'</b>',slis,'.',svok);
         //if kalert then kalert:=pos(slis+
         except writeln('((fail!!!))');end;
         try
         //writeln('[',clka,',',j,' ',lksija.muotoja,'] ');//,nluokkasijat[clka,j].muotoja);
        // continue;
         for csan:=kons[ckon].ekasana to kons[ckon].vikasana do
         for m:=1 to 1 do //lksija.muotoja do
         begin
            try
            try
             //if   length(rungot[csan].san)>7 then continue;
             msan:=rungot[csan].san;
             if m=2 then lksija:=lksija.toinenmuoto;
                //if lksija.eatsanaa then delete(msan,1,1);end;
             // if clka<50 then lksija:=nomluokkasijat[clka,j] else  lksija:=verbluokkasijat[clka,j];
             //if lksija.muotoja=0 then continue;
            except writeln('<li>noeatkon::',j,'.',m);raise;end;
            try
             koko:=reversestring(lksija.sija.ending+''+mlis+mvok+mkon+msan);
             if kalert then if clka>65 then if mvok<>'' then
             begin
             kalert:=pos(mvok,vokaalit)>0;// else writeln('!*!*!*!*');
             end;
             sofar:=reversestring(lksija.sija.ending+''+mlis+mvok);
             tavus.clear;
             tavuc:=hyphenfi(koko,tavus);
             //if clka=6 then      writeln('<li> ',koko,tavuc,tavus.commatext);//,lksija.vahva,svahva,'.',sheikko);
            except writeln('failtavu:',clka,'_',j);end;
            try
             oletustavu:=strtointdef(maxtavut[clka-51][j+1],-2)-1;
             if j=0 then rungot[csan].tavus:=tavuc;
             perustavu:=rungot[csan].tavus;
             if length(sheikko+svahva)<>1 then inc(tavucs[clka,j,max(0,tavuc-perustavu+1)]);
             //if j=5 then write('##',tavuc-perustavu+1,'/',tavucs[clka,j,max(0,tavuc-perustavu)+1]);
             if j=0 then if tavuc-perustavu<>0 then writeln('<li>mit‰vittuu');
             //writeln('*',koko);
             except writeln('failtavu2:',clka,'_',j);end;
             try
             if kalert //(kons[ckon].v+kons[ckon].h='k')
             then if (not (lksija.vahva=(clka in vahvatluokat))) then  //vsahvoilla heikot, heikoilla VAHVAT
             if (not (lksija.vahva)) then
             begin //vahvan heikot
                 if  (not LKSIJA.VAHVA) And (pos(rungot[csan].san[1],vokaalit)>0) then
                 if  (isdifto(rungot[csan].san[1],sofar[1])) and ((pos(rungot[csan].san[2],vokaalit)<1) and (pos(sofar[2],vokaalit)<1))     then
                 if clka in vahvatluokat then
                 begin
                   tavuc:=tavuc+1
                   ;//else oletustavu:=oletustavu+1;
                   writeln('+');
                 end
             end else  //heikon vanvat  ikeen iXen
             begin
               if kalert then
                 if (pos(rungot[csan].san[1],vokaalit)>0) then
                  //if svok<>'' then  //huom verbeiss‰ ei toimi
                  //jos perusmuodossa ei ollut tavurajaa lis‰tyn koon sijasta
                  if ((svok<>'') and (isdifto(rungot[csan].san[1],svok[length(svok)])))      //‰es v:e s1a
                  AND not ( (pos(rungot[csan].san[1],vokaalit)>0) and (pos(rungot[csan].san[2],vokaalit)>0))//  kolmoisvok
                 then                                                                 //kiu-as kiu-kaan
                 begin
                   //if clka in vahvatluokat then tavuc:=tavuc+1
                   ;//else oletustavu:=oletustavu+1;
                   tavuc:=tavuc-1;
                   writeln('+');
                 end;
             end;               //ies ‰es
              except writeln('<li>fail k-alert');end;
              try
              //if csan=kons[ckon].ekasana then
               if tavuc-perustavu<>oletustavu then writeln('<em style="color:red">' ,koko,'</em>/ ',tavuc,'\',oletustavu,'/p:',perustavu,'.',j) //
               //,copy(rungot[csan].san,1,2));//,sofar[1],lksija.vahva,kalert,rungot[csan].san[1],svok[1]);//,isdifto(rungot[csan].san[1]),svok)
               else if (clka=71)  then if j<964 then              writeln(' <em style="color:green">' ,koko,'</em>',tavuc,'\',oletustavu,'/p:',perustavu,'.',j);//,copy(rungot[csan].san,1,2),sofar[1],lksija.vahva);
              except writeln('<li>fail write');end;
             // if j=5 then writeln('{o:',oletustavu,'/p:',perustavu,'/c',tavuc,'}');
             except writeln('<li>failSIJA:<b>',clka,'#',j,lksija.sija.ending,'</b>',mlis,'/',lksija.sija.num,' \tv',lksija.tuplavok,' tk',lksija.tuplakon,' ev',lksija.eatvok,' e2',lksija.eat2vok,' cv',lksija.copyvok,'!</li>');end;
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
   writeln('<pre>');
   tavus.Clear;tavus.add('');
   //for i:=1 to 48 do
   for i:=52 to 78 do
   begin
     //writeln:((('<tr>');
     write(^j,i:3,'  ');
     koko:='';
     for j:=0 to 66 do
     begin maxv:=0;maxc:=0;for k:=0 to 8 do if tavucs[i][j][k]>maxv then begin maxv:=tavucs[i][j][k];maxc:=k;end;
     if getluokkasija(i,j).lisuke='!' then write('!     ') else write(maxc,'     ');
     //write(maxc,'     ');
     if getluokkasija(i,j).lisuke='!' then koko:=KOKO+'!'
     ELSE koko:=koko+inttostr(maxc);     //yht‰ isompi ett‰ valtet‰‰n miinuksia.. ynn‰tty jo laskuvaiheessa
     //write(tavucs[i][j][maxc]:4,' ');
     end;
     if i mod 10=1 then
      begin
        write(^j,' ');
        //for j:=0 to 33 do
        for j:=0 to 66 do
          write(reversestring(nsijat[j].ending):6);
       //write(tavucs[i][j][maxc]:4,' ');
      end;
     //writeln('</tr>');
     tavus.add(koko);
   end;
   writeln('</pre>');
   tavus.savetofile('vtavuja.plus');
   end;
end.

