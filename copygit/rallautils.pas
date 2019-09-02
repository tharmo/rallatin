unit rallautils;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils,math;
const vahvatverbiluokat=[52..63,76];                         const vahvatnominiluokat=[1..31];
const vahvatluokat=[1..31,52..63,76];
const rimis=64;
type string31=string[31];
type tlka=record esim:string;kot,ekasis,vikasis:word;vahva:boolean;vikasana:word;xtav:byte;end;
type tloppuvoks=record ekaav,vikaav:word;sis:string[8];vikasana,lk:word;end;
type trunko=record san:string[15];akon:string[4];takavok:boolean;konlka:word;koko:string;tavus:byte;end;
//type tsan=record san:string[15];akon:string[4];takavok:boolean;av:word;end;
type tkonso=record ekasana,takia,vikasana,sis:word;h,v,av:string[1];end;  //lisää viekä .takia - se josta etuvokaalit alkavat
const konsonantit ='bcdfghjklmnpqrstvwxz'''; vokaalit='aeiouyäö';
const pronexamples:array[1..18] of string=('minä','me','sinä','te','hän','he',    'tämä','nämä','tuo','nuo','se','ne',  'itse','jompikumpi','joku','kuka','mikä','joka');
const prontypes:array[1..18] of string=('Pers','Pers','Pers','Pers','Pers','Pers','Dem', 'Den', 'Dem','Dem','Dem','Dem','Refl',       'Qnt','','Inter','Inter','Rel');
const nexamples:array[1..49] of ansistring=('ukko','hiomo','avio','elikko','häkki','seteli','kaikki','nukke','ankka','fokka','itara','urea','aluna','ulappa','upea','kumpi','keruu','jää','suo','bukee','gay','buffet','lohi','uni','liemi','veri','mesi','jälsi','lapsi','peitsi','yksi','tytär','asetin','hapan','lämmin','alin','vasen','öinen','ajos','etuus','rakas','mies','immyt','kevät','sadas','tuhat','mennyt','hake','kinner');
const nendings:array[0..33] of ansistring =('','a','n','ssa','sta','lla','lta','lle','ksi','tta','na','n','t','issa','ista','illa','ilta','ille','iksi','itta','in','ina','a','ja','ita','in','in','ihin','en','en','iden','itten','in','ten');
const nsijesims:array[0..33]of ansistring =('ilo','iloa','ilon','ilossa','ilosta','ilolla','ilolta','ilolle','iloksi','ilotta','ilona','iloon','ilot','iloissa','iloista','iloilla','iloilta','iloille','iloiksi','iloitta','iloin','iloina','iloja','iloja','omenoita','omeniin','uniin','iloihin','ilojen','ilojen','omenoiden','omenoitten','ulappain','unten');
const nsijnams:array[0..33]of ansistring =('NNomSg',   'NParSg',  'NGenSg',  'NIneSg',  'NElaSg',   'NAdeSg',  'NAblSg',  'NAllSg',  'NTraSg',  'NAbeSg',  'NEssSg',  'NIllSg',  'NNomPl',  'NInePl',  'NElaPl',  'NAdePl',   'NAblPl',  'NAllPl', 'NTraPl',  'NAbePl',  'NInsPl',  'NEssPl',  'NParPl',  'NParPl',  'NParPl','NIllPl',   'NIllPl',   'NIllPl','NGenPl',    'NGenPl',  'NGenPl',  'NGenPl','NGenPl','NGenPl');
const nhfstnams:array[0..33]of ansistring =('N Nom Sg','N Par Sg','N Gen Sg','N Ine Sg','N Ela Sg','N Ade Sg','N Abl Sg','N All Sg','N Tra Sg','N Abe Sg','N Ess Sg','N Ill Sg','N Nom Pl','N Ine Pl','N Ela Pl','N Ade Pl','N Abl Pl','N All Pl','N Tra Pl','N Abe Pl','N Ins Pl','N Ess Pl','N Par Pl','N Par Pl','N Par Pl','N Ill Pl','N Ill Pl','N Ill Pl','N Gen Pl','N Gen Pl','N Gen Pl','N Gen Pl','N Gen Pl','N Gen Pl');
const nvahvanvahvat =[0,1,10,11,21,22,23,25,27,28,32];
const nheikonheikot=[0,1,33];
const vluokkia=24;vsikoja=66;
const nluokkia=48;nsikoja=33;
const VprotoLOPut:array[0..11] of ansistring =('a','a', 'n', '', 'a', 'ut', 'i', 'tu', 'en', 'isi', 'kaa', 'emme');
const
//vvahvanheikot =[5,6,7,8,9,10,13,14,15,24,25,26,27,29,30,31,32,33,34,35,36];
//vheikonheikot=[0,1,2,3,4,13,14,15,16,17,18,19,20,21,22,29,30,31,32,33,34,35,36,37,38,62,63,64,65];
vsijanimet:array[0..66] of ansistring =
  ('V Inf1 Lat ','V Inf1 Act Tra Sg PxPl1 ','V Inf1 Act Tra Sg PxSg1 ','V Inf1 Act Tra Sg PxPl2 ','V Inf1 Act Tra Sg PxSg2 ','V Impv Act Sg2 ','V Prs Act ConNeg ','V Prs Act Pl1 ','V Prs Act Sg1 ','V Prs Act Sg2 ','V Prs Act Pl2 ','V Prs Act Pl3 ','V Prs Act Sg3 ','V Prs Pass ConNeg ','V Prs Pass Pe4 ','PrfPrc Pass Pos Nom Pl ','V Pot Act Sg3 ','V Pot Act Pl1 ','V Pot Act Sg1 ','V Pot Act Sg2 ','V Pot Act Pl2 ','V Pot Act Pl3 ','PrfPrc Act Pos Nom Sg ','V Pst Act Sg3 ','V Pst Act Pl1 ','V Pst Act Sg1 ','V Pst Act Sg2 ','V Pst Act Pl2 ','V Pst Act Pl3 ','V Inf2 Pass Ine ','V Cond Pass Pe4 ','V Impv Pass Pe4 ','V Inf3 Pass Ins ','V Pot Pass Pe4 ','PrsPrc Pass Pos Nom Sg ','V Pst Pass Pe4 ','V Pst Pass ConNeg ','V Inf2 Act Ins ','V Inf2 Act Ine Sg ','V Cond Act Sg3 ','V Cond Act Pl1 ','V Cond Act Sg1 ','V Cond Act Sg2 ','V Cond Act Pl2 ','V Cond Act Pl3 ','AgPrc Pos Nom Sg ','AgPrc Pos Ill Sg ','V Act Inf5 Px3 ','V Act Inf5 PxPl1 ','V Act Inf5 PxSg1 ','V Act Inf5 PxPl2 ','V Act Inf5 PxSg2 ','V Inf3 Ade ','V Inf3 Man ','V Inf3 Ine ','V Inf3 Ela ','V Inf3 Abe ','V N Nom Sg ','V N Par Sg ','V N Par Sg ','PrsPrc Act Pos Nom Sg ','PrsPrc Act Pos Nom Pl ','V Impv Act Pl2 ','V Impv Act Pl1 ','V Impv Act Sg3','V Impv Act Pl3','V Act Inf5 Px3 ');
vsijaesim:array[0..66] of ansistring = ('kehua','kehuaksemme','kehuakseni','kehuaksenne','kehuaksesi','kehu',{'VIRHE',}'kehu','kehumme','kehun','kehut','kehutte','kehuvat','kehuu','kehuta','kehutaan','kehutut','kehunee','kehunemme','kehunen','kehunet','kehunette','kehunevat','kehunut','kehui','kehuimme','kehuin','kehuit','kehuitte','kehuivat','kehuttaessa','kehuttaisiin','kehuttakoon','kehuttaman','kehuttaneen','kehuttava','kehuttiin','kehuttu','kehuen','kehuessa','kehuisi','kehuisimme','kehuisin','kehuisit','kehuisitte','kehuisivat','kehuma','kehumaan','kehumaisillaan','kehumaisillamme','kehumaisillani','kehumaisillanne','kehumaisillasi','kehumalla','kehuman','kehumassa','kehumasta','kehumatta','kehuminen','kehumista','kehumista','kehuva','kehuvat','kehukaa','kehukaamme','koon','koot','kehumaisillansa');
vesims: array[1..27] of ansistring =('sanoa', 'sulaa', 'pieksää', 'soutaa', 'jauhaa', 'kaataa', 'laskea', 'tuntea', 'lähteä', 'kolhia', 'naida', 'saada', 'viedä', 'käydä', 'päästä', 'puhella', 'aterioida', 'suudita', 'piestä', 'nähdä', 'parata', 'niiata', 'kasketa', 'nimetä', 'taitaa', 'kumajaa', 'kaikaa');
var
 lks:array[0..80] of tlka;
 siss:array[0..2047] of tloppuvoks;
 kons:array[0..2047] of tkonso;
 rungot:array[0..65535] of trunko;

//function luenominiloput(fn:string):tstringlist;  //hanskaa samalla sijojen luonti luettavat sisuskalut on 1/1 sijoihin (todin kuin verbeillä, joilla on "protot")
//function lueverbiloput(fn:string):tstringlist;  //hanskaa samalla sijojen luonti luettavat sisuskalut on 1/1 sijoihin (todin kuin verbeillä, joilla on "protot")
function IFs(cond:boolean;st1,st2:ansistring):ansistring;
function voktakarev(sana:string;vAR eietu,eitaka:boolean):string;
function ontaka(sana:string):boolean;
function taka(sana:string):string;
function etu(sana:string):string;
function hyphenfi(w:ansistring;tavus:tstringlist):word;
function isdifto(c1,c2:ansichar):boolean;
function isvokraja(c1,c2:ansichar):boolean;
function takax(st:string;var x:word):string;

implementation
function ontaka(sana:string):boolean;
var i:word;
begin
   result:=false;
   for i:=1 to length(sana) do if pos(sana[i],'aou')>0 then result:=true;
end;

function takax(st:string;var x:word):string;
 var i:byte;st2:ansistring;
 function c(s:ansichar):ansichar;
 begin

     if pos(s,'aou')>0 then begin result:=s;x:=0;end else
     if s='ä' then  result:='a' else
     if s='ö' then result:='o' else
     if s='y' then result:='u'  else result:=s;
  end;
 begin
    write(st);
  x:=1;
  result:='';
  for i:=1 to length(st) do st[i]:=c(st[i]);
  result:=st;
  writeln(x);
 end;


function IFs(cond:boolean;st1,st2:ansistring):ansistring;
     begin
      if cond then result:=st1 else result:=st2;
     end;
function isdifto(c1,c2:ansichar):boolean;
 begin
  result:=false;
  if c1=c2 then result:=true else                       //arv  i o i da                ae ao ea eo ia io oa oe ua ue
  case c1 of
   'a': if pos(c2,'iu')>0 then result:=true;
   'e','i': if pos(c2,'ieuy')>0 then result:=true;
   'o','u': if pos(c2,'iuo')>0 then result:=true;
   'y','ö': if pos(c2,'iyö')>0 then result:=true;
   'ä': if pos(c2,'iy')>0 then result:=true;
  end;
 // if not result then write('*');
 end;

function hyphenfi(w:ansistring;tavus:tstringlist):word;
  var i,k,len,vpos:integer;hy,alkkon:ansistring;ch,chprev:ansichar;lasttag:ansistring;
   voks:word;
begin
 {
 konsonantti vokaalin edellä - tavuraja ennen kons
 yhteensopimattomat vokaalit - tavuraja väliin
 kolme vokaalia - tr ennen kolmatta

 }
 // writeln('<li><b>',w,'</b><ul>');
  if tavus<>nil then tavus.clear;
  len:=length(w);
  result:=0;//w[len];   duuoon  noouu
 if len=0 then exit;
 chprev:='R';//w[len];   //o
 alkkon:='';
 if (pos(w[1],konsonantit)>0) then
 begin
  if len=1 then alkkon:=w[1] else
 for i:=2 to max(len,3) do if (pos(w[i],konsonantit)>0) then alkkon:=alkkon+w[i-1] else break;
 if alkkon<>'' then w:=ansilowercase(copy(w,length(alkkon)+1,99));
 len:=length(w);          //uuoon
 end;
 voks:=0;
 for i:=len downto 1 do
 begin
    ch:=w[i];
    if voks>0 then
    begin        //a ie  prev:e nyt:i  ie on dift
      if (pos(ch,konsonantit)>0)  then
      begin
         inc(result);
         voks:=0;
         if tavus<>nil then tavus.insert(0,ch+hy);hy:='';ch:=' ';
      end
      else
      begin //vokaali
         if voks>1 then   //tripla
          begin
             inc(result);
             if tavus<>nil then tavus.insert(0,hy);
             voks:=1;
             hy:=ch;
          end
          else  //ed vokaali, nyt vokaali
          if (not isdifto(ch,chprev)) then //tavurajavokaali
          begin
            inc(result);
            if tavus<>nil then tavus.insert(0,hy);
            hy:=ch; //chprev:='y';//                     //  as-il a a is | os
            voks:=1;
          end else //diftonki, ei tavurajaa
          begin
               hy:=ch+hy; inc(voks);
          end; //ignoroi kolmoiskons - mukana vain ei-yhd.sanojen perusmuodot,
     end;
   end else // edellinen aloitti tavun tai oli sen loppukons
   begin
    if pos(ch,vokaalit)>0 then inc(voks);
    hy:=ch+hy;
   end;
   if i=1 then
   begin
      if hy<>'' then begin inc(result);if tavus<>nil then tavus.insert(0,hy);end;
   end else
   chprev:=ch;
 end;
 //HUOM: NÄÄ ON JOSKUS HALUTTU / YLIM ALKUKONONANTIT ERI TAVUNA, ei kuitenkaan lasketa resulttiin
 if alkkon<>'' then if tavus<>nil then tavus.insert(0,alkkon+'');
 //else tavus.insert(0,'');
 //result:=alkkon+'_'+result;
 // result:=tavus.commatext;
 //if w='eaksemme' then write('***',result);
end;

function isvokraja(c1,c2:ansichar):boolean;
   begin
    result:=true;
    if pos(c2,konsonantit)>0 then result:=false else
    if pos(c1,konsonantit)>0 then result:=false else
    if c1=c2 then result:=false else                       //arv  i o i da                ae ao ea eo ia io oa oe ua ue
    case c1 of
     'a': if pos(c2,'iu')>0 then begin result:=false;;end;
     'e','i': if pos(c2,'ieuy')>0 then result:=false;
     'o','u': if pos(c2,'iuo')>0 then result:=false;
     'y','ö': if pos(c2,'iyö')>0 then result:=false;
     'ä': if pos(c2,'iy')>0 then result:=false;
    end;
 // if not result then;
 end;

function voktakarev(sana:string;vAR eietu,eitaka:boolean):string;
var i:word;
BEGIN
try
  result:='';
  eietu:=false;eitaka:=false;
  for i:=1 to length(sana) do
  begin
      if pos(sana[i],'aou')>0 then begin eietu:=true;result:=sana[i]+result;end
      else    if pos(sana[i],'äöy')>0 then begin eitaka:=true; result:='aou'[pos(sana[i],'äöy')]+result; end
      else result:=sana[i]+result;
  end;
  //if eitaka and eietu then begin  eietu:=false;eitaka:=false;end;
except writeln('failcvoksointu');raise;end;
 //writeln('%%',sana,eietu,eitaka);
end;
function taka(sana:string):string;
var i:word;
BEGIN
try
  result:='';
  for i:=1 to length(sana) do
  begin
      if pos(sana[i],'äöy')>0 then begin result:=result+'aou'[pos(sana[i],'äöy')]; end
      else result:=result+sana[i];
  end;
  //if eitaka and eietu then begin  eietu:=false;eitaka:=false;end;
except writeln('failcvoksointu');raise;end;
 //writeln('%%',sana,eietu,eitaka);
end;
function etu(sana:string):string;
var i:word;
BEGIN
try
  result:='';
  for i:=1 to length(sana) do
      if pos(sana[i],'aou')>0 then begin result:=result+'äöy'[pos(sana[i],'aou')]; end
      else result:=result+sana[i];
except writeln('failcvoksointu');raise;end;
end;

end.

