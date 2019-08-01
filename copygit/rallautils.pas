unit rallautils;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils;
const vahvatverbiluokat=[52..63,76];
const vahvatnominiluokat=[1..31,76];
const rimis=64;
type string31=string[31];
type tlka=record esim:string;kot,ekasis,vikasis:word;vahva:boolean;vikasana:word;end;
type tloppuvoks=record ekaav,vikaav:word;sis:string[8];vikasana,lk:word;end;
type trunko=record san:string[15];akon:string[4];takavok:boolean;konlka:word;end;
//type tsan=record san:string[15];akon:string[4];takavok:boolean;av:word;end;
type tkonso=record ekasana,takia,vikasana,sis:word;h,v,av:string[1];end;  //lis‰‰ viek‰ .takia - se josta etuvokaalit alkavat

const nexamples:array[1..49] of ansistring=('ukko','hiomo','avio','elikko','h‰kki','seteli','kaikki','nukke','ankka','fokka','itara','urea','aluna','ulappa','upea','kumpi','keruu','j‰‰','suo','bukee','gay','buffet','lohi','uni','liemi','veri','mesi','j‰lsi','lapsi','peitsi','yksi','tyt‰r','asetin','hapan','l‰mmin','alin','vasen','ˆinen','ajos','etuus','rakas','mies','immyt','kev‰t','sadas','tuhat','mennyt','hake','kinner');
const nendings:array[0..33] of ansistring =('','a','n','ssa','sta','lla','lta','lle','ksi','tta','na','n','t','issa','ista','illa','ilta','ille','iksi','itta','in','ina','a','ja','ita','in','in','ihin','en','en','iden','itten','in','ten');
const nsijesims:array[0..33]of ansistring =('ilo','iloa','ilon','ilossa','ilosta','ilolla','ilolta','ilolle','iloksi','ilotta','ilona','iloon','ilot','iloissa','iloista','iloilla','iloilta','iloille','iloiksi','iloitta','iloin','iloina','iloja','iloja','omenoita','omeniin','uniin','iloihin','ilojen','ilojen','omenoiden','omenoitten','ulappain','unten');
const nsijnams:array[0..33]of ansistring =('NNomSg','NParSg','NGenSg','NIneSg','NElaSg','NAdeSg','NAblSg','NAllSg','NTraSg','NAbeSg','NEssSg','NIllSg','NNomPl','NInePl','NElaPl','NAdePl','NAblPl','NAllPl','NTraPl','NAbePl','NInsPl','NEssPl','NParPl','NParPl','NParPl','NIllPl','NIllPl','NIllPl','NGenPl','NGenPl','NGenPl','NGenPl','NGenPl','NGenPl');
const nvahvanvahvat =[0,1,10,11,21,22,23,25,27,28,32];
const nheikonheikot=[0,1,33];
const vluokkia=24;vsikoja=66;
const nluokkia=48;nsikoja=33;
const VprotoLOPut:array[0..11] of ansistring =('a','a', 'n', '', 'a', 'ut', 'i', 'tu', 'en', 'isi', 'kaa', 'emme');
const
vvahvanheikot =[5,6,7,8,9,10,13,14,15,24,25,26,27,29,30,31,32,33,34,35,36];
vheikonheikot=[0,1,2,3,4,13,14,15,16,17,18,19,20,21,22,29,30,31,32,33,34,35,36,37,38,62,63,64,65];
vsijanimet:array[0..66] of ansistring =
  ('V Inf1 Lat ','V Inf1 Act Tra Sg PxPl1 ','V Inf1 Act Tra Sg PxSg1 ','V Inf1 Act Tra Sg PxPl2 ','V Inf1 Act Tra Sg PxSg2 ','V Impv Act Sg2 ','V Prs Act ConNeg ','V Prs Act Pl1 ','V Prs Act Sg1 ','V Prs Act Sg2 ','V Prs Act Pl2 ','V Prs Act Pl3 ','V Prs Act Sg3 ','V Prs Pass ConNeg ','V Prs Pass Pe4 ','PrfPrc Pass Pos Nom Pl ','V Pot Act Sg3 ','V Pot Act Pl1 ','V Pot Act Sg1 ','V Pot Act Sg2 ','V Pot Act Pl2 ','V Pot Act Pl3 ','PrfPrc Act Pos Nom Sg ','V Pst Act Sg3 ','V Pst Act Pl1 ','V Pst Act Sg1 ','V Pst Act Sg2 ','V Pst Act Pl2 ','V Pst Act Pl3 ','V Inf2 Pass Ine ','V Cond Pass Pe4 ','V Impv Pass Pe4 ','V Inf3 Pass Ins ','V Pot Pass Pe4 ','PrsPrc Pass Pos Nom Sg ','V Pst Pass Pe4 ','V Pst Pass ConNeg ','V Inf2 Act Ins ','V Inf2 Act Ine Sg ','V Cond Act Sg3 ','V Cond Act Pl1 ','V Cond Act Sg1 ','V Cond Act Sg2 ','V Cond Act Pl2 ','V Cond Act Pl3 ','AgPrc Pos Nom Sg ','AgPrc Pos Ill Sg ','V Act Inf5 Px3 ','V Act Inf5 PxPl1 ','V Act Inf5 PxSg1 ','V Act Inf5 PxPl2 ','V Act Inf5 PxSg2 ','V Inf3 Ade ','V Inf3 Man ','V Inf3 Ine ','V Inf3 Ela ','V Inf3 Abe ','V N Nom Sg ','V N Par Sg ','V N Par Sg ','PrsPrc Act Pos Nom Sg ','PrsPrc Act Pos Nom Pl ','V Impv Act Pl2 ','V Impv Act Pl1 ','V Impv Act Sg3','V Impv Act Pl3','V Act Inf5 Px3 ');
vsijaesim:array[0..66] of ansistring = ('kehua','kehuaksemme','kehuakseni','kehuaksenne','kehuaksesi','kehu',{'VIRHE',}'kehu','kehumme','kehun','kehut','kehutte','kehuvat','kehuu','kehuta','kehutaan','kehutut','kehunee','kehunemme','kehunen','kehunet','kehunette','kehunevat','kehunut','kehui','kehuimme','kehuin','kehuit','kehuitte','kehuivat','kehuttaessa','kehuttaisiin','kehuttakoon','kehuttaman','kehuttaneen','kehuttava','kehuttiin','kehuttu','kehuen','kehuessa','kehuisi','kehuisimme','kehuisin','kehuisit','kehuisitte','kehuisivat','kehuma','kehumaan','kehumaisillaan','kehumaisillamme','kehumaisillani','kehumaisillanne','kehumaisillasi','kehumalla','kehuman','kehumassa','kehumasta','kehumatta','kehuminen','kehumista','kehumista','kehuva','kehuvat','kehukaa','kehukaamme','koon','koot','kehumaisillansa');
vesims: array[1..27] of ansistring =('sanoa', 'sulaa', 'pieks‰‰', 'soutaa', 'jauhaa', 'kaataa', 'laskea', 'tuntea', 'l‰hte‰', 'kolhia', 'naida', 'saada', 'vied‰', 'k‰yd‰', 'p‰‰st‰', 'puhella', 'aterioida', 'suudita', 'piest‰', 'n‰hd‰', 'parata', 'niiata', 'kasketa', 'nimet‰', 'taitaa', 'kumajaa', 'kaikaa');

//function luenominiloput(fn:string):tstringlist;  //hanskaa samalla sijojen luonti luettavat sisuskalut on 1/1 sijoihin (todin kuin verbeill‰, joilla on "protot")
//function lueverbiloput(fn:string):tstringlist;  //hanskaa samalla sijojen luonti luettavat sisuskalut on 1/1 sijoihin (todin kuin verbeill‰, joilla on "protot")
function IFs(cond:boolean;st1,st2:ansistring):ansistring;

implementation
function IFs(cond:boolean;st1,st2:ansistring):ansistring;
     begin
      if cond then result:=st1 else result:=st2;
     end;


end.

