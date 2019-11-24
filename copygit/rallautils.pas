unit rallautils;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils,math,  fgl,sort;

const vahvatverbiluokat=[52..63,76];                         const vahvatnominiluokat=[1..31];
const vahvatluokat=[1..31,52..63,76];
const rimis=64;
type string31=string[31];
type tlka=record esim:string;kot,ekasis,vikasis:word;vahva:boolean;vikasana:word;xtav:byte;end;
type tloppuvoks=record ekaav,vikaav:word;sis:string[8];vikasana,lklka:word;end;
type tkonso=record ekasana,vikasana,voklka:word;h,v,av:string[1];end;  //lisää viekä .takia - se josta etuvokaalit alkavat     .. ehkä, nyt ei sortattu
type trunko=record san:string[15];akon:string[4];takavok:boolean;konlka:word;koko:string;tavus:byte;end;
//type tsan=record san:string[15];akon:string[4];takavok:boolean;av:word;end;
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
  ('V Inf1 Lat ','V Inf1 Act Tra Sg PxPl1 ','V Inf1 Act Tra Sg PxSg1 ','V Inf1 Act Tra Sg PxPl2 ','V Inf1 Act Tra Sg PxSg2 ','V Impv Act Sg2xx ',{'V Prs Act ConNeg ',}'V Prs Act Pl1x ','V Prs Act Sg1 ','V Prs Act Sg2 ','V Prs Act Pl2 ','V Prs Act Pl3 ','V Prs Act Sg3 ','V Prs Pass ConNeg ','V Prs Pass Pe4 ','PrfPrc Pass Pos Nom Pl ','V Pot Act Sg3 ','V Pot Act Pl1 ','V Pot Act Sg1 ','V Pot Act Sg2 ','V Pot Act Pl2 ','V Pot Act Pl3 ','PrfPrc Act Pos Nom Sg ','V Pst Act Sg3 ','V Pst Act Pl1 ','V Pst Act Sg1 ','V Pst Act Sg2 ','V Pst Act Pl2 ','V Pst Act Pl3 ','V Inf2 Pass Ine ','V Cond Pass Pe4 ','V Impv Pass Pe4 ','V Inf3 Pass Ins ','V Pot Pass Pe4 ','PrsPrc Pass Pos Nom Sg ','V Pst Pass Pe4 ','V Pst Pass ConNeg ','V Inf2 Act Ins ','V Inf2 Act Ine Sg ','V Cond Act Sg3 ','V Cond Act Pl1 ','V Cond Act Sg1 ','V Cond Act Sg2 ','V Cond Act Pl2 ','V Cond Act Pl3 ','AgPrc Pos Nom Sg ','AgPrc Pos Ill Sg ','V Act Inf5 Px3 ','V Act Inf5 PxPl1 ','V Act Inf5 PxSg1 ','V Act Inf5 PxPl2 ','V Act Inf5 PxSg2 ','V Inf3 Ade ','V Inf3 Man ','V Inf3 Ine ','V Inf3 Ela ','V Inf3 Abe ','V N Nom Sg ','V N Par Sg ','V N Par Sg ','PrsPrc Act Pos Nom Sg ','PrsPrc Act Pos Nom Pl ','V Impv Act Pl2 ','V Impv Act Pl1 ','V Impv Act Sg3','V Impv Act Pl3','V Act Inf5 Px3 ','turha');
vsijaesim:array[0..66] of ansistring = ('kehua','kehuaksemme','kehuakseni','kehuaksenne','kehuaksesi','kehu',{'VIRHE','kehu',}'kehumme','kehun','kehut','kehutte','kehuvat','kehuu','kehuta','kehutaan','kehutut','kehunee','kehunemme','kehunen','kehunet','kehunette','kehunevat','kehunut','kehui','kehuimme','kehuin','kehuit','kehuitte','kehuivat','kehuttaessa','kehuttaisiin','kehuttakoon','kehuttaman','kehuttaneen','kehuttava','kehuttiin','kehuttu','kehuen','kehuessa','kehuisi','kehuisimme','kehuisin','kehuisit','kehuisitte','kehuisivat','kehuma','kehumaan','kehumaisillaan','kehumaisillamme','kehumaisillani','kehumaisillanne','kehumaisillasi','kehumalla','kehuman','kehumassa','kehumasta','kehumatta','kehuminen','kehumista','kehumista','kehuva','kehuvat','kehukaa','kehukaamme','koon','koot','kehumaisillansa','sekokseko');
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
function hyphenfirev(w:ansistring;tavus:tstringlist;var alkkon:string):word;
function tuplavok(c1,c2:ansichar):boolean;
function diftongi(c1,c2:ansichar):boolean;
function isvokraja(c1,c2:ansichar):boolean;
//function istavuraja(c1,c2:ansichar):boolean;
function takax(st:string;var x:word):string;
procedure etsiyhdys;
procedure coocs;
function big64(bigs,bigvals:pword;bwrd,wrd,freq:word):word;


type
// for {$mode objfpc}
  TIntegerList = specialize TFPGList<Integer>;
// for {$mode delphi}
//  TIntegerList = TFPGList<Integer>;
implementation
uses otus;
type binriv=bitpacked array[0..40000] of  boolean;

type TCO=record w,f:word;end;
type TCOline=array[0..63] of tco;


  function obcompare(List: TStringList; Index1, Index2: Integer): Integer;
  begin
   result:=integer(pointer(list.objects[index2]))-integer(pointer(list.objects[index1]));
end;


function gutrelas:tvvmat;
  var f:text;//aco:tco;
    //scos,i1cos,i2cos,j1cos,j2cos:tcoline;
    //acoi1,acoi2,acoj1,acoj2:tco;
    i1val,i2val,j1val,j2val:longword;
    vvmat,dotmat,ddot:tvvmat;
    //cos:array of tvvarray;
     maxmutv,maxmutn:word;
    line:string;cost,sanat:tstringlist; base:word;
    i1,i2,j1,j2,ii:word;scount:word;
    mutut:tstringlist;  asana,rst:string; AVAL:WORD;lim:word;
    apos,jcount:integer;
    outf,inf:file;
    tot:longword;
    //mutuals:array 0..32 of word;
  begin
  lim:=16;
  mutut:=tstringlist.create;
   assign(f,'both2.spar');
   reset(f);
   cost:=tstringlist.create;
   sanat:=tstringlist.create;
   sanat.loadfromfile('kaavoitetut');
   scount:=sanat.count;
   vvmat:=tvvmat.create(scount+1,63,sanat);
   sanat.insert(0,'eka');
   vvmat.sanat:=sanat;
//   vvmat.readmat('dot1.mat');
 //  vvmat.list(0);
  // exit;
   cost.Delimiter:=',';
   cost.StrictDelimiter:=true;
   //setlength(cos,sanat.count);
   while not eof(f) do
   begin
    try
     readln(f,line);
     if line='' then continue;
     cost.delimitedtext:=line;
     if cost.count<3 then continue;
     //if cost.Count<3 then continue;
     base:=strtointdef(cost[0],0);
     //write(^j,sanat[base]);
     //coline:=cospars[base];
     vvmat.mx[base*vvmat.cols].w:=base;
     //try      vvmat.mx[base*vvmat.cols].v:=strtointdef(cost[1],0) div 100;
     //except write(^j'***',cost[0],' ',cost.commatext,'!');end;
     for i1:=1 to min(63,(cost.Count-2) div 2) do  //3->1 5->2
     begin
      ii:=i1*2;
      //write('\',vvmat.mx[base*vvmat.cols].v);
      //if cost[ii+1]='0' then break;      //if ii>vvmat.cols then break;
      try
        if cost[ii]<>cost[0] then
       //writeln(base,strtointdef(cost[ii],0),strtointdef(cost[ii+1],0))
        vvmat.cadd(base,strtointdef(cost[ii],0),strtointdef(cost[ii+1],0));
        //write('\',vvmat.len(base));
      except  writeln(^j,' #',sanat[base],ii,'@',strtointdef(cost[ii],0),'#',cost.count);end;
     end;
     //write(^j,sanat[base],vvmat.len(base),' ',(cost.count-2) div 2,':::');
      //for i1:=1 to vvmat.len(base)-1 do  write(sanat[vvmat[base,i1].w],' ');
       vvmat.mx[base*vvmat.cols].v:=vvmat.tot(base);
     except write(^j,' failline:',base,'.');end;
   end;
   writeln('didsofar:::',scount);
   result:=vvmat;
   vvmat.savemat('dot0.mat');
   vvmat.list(0);
  end;

//for i1:=1 to vvmat.len(s)-1 do write(' ',sanat[vvmat[s,i1*2].w]);


procedure relas;
var f:text;//aco:tco;
  scos,i1cos,i2cos,j1cos,j2cos:tcoline;
  acoi1,acoi2,acoj1,acoj2:tco;
  i1val,i2val,j1val,j2val:longword;
  cospars,mutuals:array of tcoline;
   maxmutv,maxmutn:word;
  vvmat:tvvmat;
  line:string;cost,sanat:tstringlist; base:word;
  i1,i2,j1,j2,ii,s:word;scount:word;
  kerrotut,mutut:tstringlist;  asana,rst:string; AVAL:WORD;lim:word;
  apos,jcount:integer;
  procedure reg;//(asna:string;w,c1,c2,c3,c4:word);
               begin//write(' ',sanat[acok.w]) else write('.');
                apos:=kerrotut.indexof(inttostr(acoj2.w));
                aval:=min(acoi1.f,min(acoi2.f,min(acoj1.f,acoj2.f)));
                //if aval>0 then write(sanat[acoj1.w],'.');
                //if apos<0 then  kerrotut.addobject(asana,tobject(pointer(aval))) // KERr0?
                mutuals[i1,i2].f:=mutuals[i1,i2].f+1;
                if apos<0 then  kerrotut.addobject(inttostr(acoj1.w),tobject(pointer(1))) // KERr0?
                else
                BEGIN
                  AVAL:=aval+INTEGER(POINTER(kerrotut.objects[apos]));
//                  AVAL:=1+INTEGER(POINTER(kerrotut.objects[apos]));
                  kerrotut.objects[apos]:=tobject(pointer(AVAL));
                  //apos:=kerrotut.count-1;
                  //write('-',asana);
                END;
               // writeln(apos,asana,kerrotut.indexof(inttostr(acoj1.w)),sanat[acoj1.w],acoj1.w,': [',kerrotut.commatext,']');


                //if aval>1 then write('-',kerrotut.count);
              end;
vAR Ab:ARRAY[0..7] of trec;oioi:string;
const aset=[1,9,3,4,5,6,7,2,8];

   //a:array[0..7] of word;
begin
 // setlength(vvs,8);
 oioi:='193456728';
  lim:=32;
  kerrotut:=tstringlist.create;
  mutut:=tstringlist.create;
   assign(f,'rela.nums');
   reset(f);
   cost:=tstringlist.create;
   sanat:=tstringlist.create;
   sanat.loadfromfile('kaavoitetut');
   scount:=sanat.count;
   vvmat:=tvvmat.create(scount+1,63,sanat);
   sanat.insert(0,'eka');
   cost.Delimiter:=' ';
   cost.StrictDelimiter:=true;
   setlength(cospars,sanat.count);
   setlength(mutuals,64*64);
   while not eof(f) do
   begin
    try
     readln(f,line);
     if line='' then continue;
     cost.delimitedtext:=line;
     base:=strtointdef(cost[0],base);
     //write(^j,' ',sanat[base]);
     //coline:=cospars[base];
     for i1:=1 to (cost.Count-1) div 2 do  //3->1 5->2
     begin
      ii:=i1*2-1;
      if ii>31 then continue;
     cospars[base][i1].w:=strtointdef(cost[ii],0);
     cospars[base][i1].f:=strtointdef(cost[ii+1],0);
     end;
     except write(' failline:',line,'.');end;
   end;
   writeln('didsofar',scount);

   for s:=1 to scount do//kaikkii sanojen lista
   begin
      //fillchar(mutuals[0],64*4,0);
      rst:=(^j+sanat[s]+':;');
      //write(^j,s,sanat[s]+':;');
      //continue;
      scos:=cospars[s];  //s-sanan coco-lista
      for i1:=1 to lim do  //yksi s:n cooc
      begin
        begin
         acoi1:=scos[i1]; //i-sanan muut coocit
         if acoi1.w=s then continue;
         if acoi1.w =0 then begin break;end;
//         vvs.add(acoi1.w,acoi1.f);
         mutuals[i1,0].w:=acoi1.w;
         rst:=rst+('_'+sanat[acoi1.w]);
         jcount:=i1-1;  //pannaan muistiin debuggausta varten
         //if acoj.w =i then continue;
         i1cos:=cospars[acoi1.w];  //ptr
         for i2:=1 to lim do  //toinen s-sanan cooc
         begin
          //continue;
          acoi2:=scos[i2];  // yksii toisista cooceista
          if acoi2.w=0 then break;
          mutuals[i2,0].w:=acoi2.w;
          //TRY
          if (acoi2.w=0) OR  (acoi1.w=ACOI2.W) then continue;
          i2cos:=cospars[acoi2.w];;
          if acoi2.w=0 then break;
          for j1:=1 to lim do  //
          begin  //i-sanan ekan coocin eka coocci
            acoj1:=i1cos[j1];  //
            if acoj1.w=0 then break;
            asana:=sanat[acoj1.w];
            for j2:=1 to lim do  //
            begin  //i-sanan ekan coocin eka coocci
              acoj2:=i2cos[j2];  //
              if acoj2.w=0 then break;
              if ACOj1.W=ACOj2.W THEN
              begin
                //write(',',sanat[acoj1.w],asana);
                reg;
              end;
            end;
          end;
       end;  //i2
      end; //i1

     end;  //yksi sana
 //exit;
 write(^j^j,sanat[s],'::',kerrotut.count);
 try
     //if kerrotut.count>0 then for i1:=1 to kerrotut.count-1 do       write('   ',i1-1,':',strtointdef(kerrotut[i1],0)   ,'_'    ,integer(pointer(kerrotut.objects[i1])));
     if kerrotut.count<1 then continue;
      if kerrotut.count>0 then for i1:=1 to kerrotut.count-1 do
        vvmat.cadd(s,strtointdef(kerrotut[i1],0),integer(pointer(kerrotut.objects[i1])));
 try vvmat.sortrow(s,20);except writeln('^^FAILSORT');end;
 for i1:=1 to kerrotut.count-1  do write('/ ',sanat[vvmat[s,i1].v],'/',vvmat[s,i1].v);
 //vvmat.clearrow(;
     try
      if kerrotut.count>9991 then
      begin
        kerrotut.customsort(@obcompare);
{        for i1:=0 to min(20,kerrotut.count-1) do
        //if kerrotut[i1]='0' then break else
        begin
          acoi1.w:=strtointdef(kerrotut[i1],0);
          write('?',kerrotut[i1]);
          for i2:=0 to  min(20,kerrotut.count-1) do
          if kerrotut[i2]='' then break else
          begin
            acoi2.w:=strtointdef(kerrotut[i2],0);
            try
           // mutuals[i1][i2].w:=cospars[acoi1.w,acoi2.w].w;
            //mutuals[i1][i2].f:=cospars[acoi1.w,acoi2.w].f;
            except write('failX',acoi1.w,'/',acoi2.w,'_');end;
          end;
        end;
}        {maxmutv:=0;
        for i1:=0 to kerrotut.count-1 do
          for i2:=0 to kerrotut.count-1 do
           if maxmutv<mutuals[i1,i2].f then begin maxmutv:=mutuals[i1,i2].f;write('+',sanat[mutuals[i1,i2].w]); end;
         //write(^j^j,sanat[s],': ',rst);
        write(rst,'!');
        }
        //if abs(jcount-kerrotut.count)>3 then
        //if jcount>kerrotut.count+4 then
        //if s<>strtointdef
        base:=(integer(pointer(kerrotut.objects[1])));
        begin
        WRITE(^j,//jcount,'>',kerrotut.count,'::',
        sanat[s]);
        for ii:=0 to kerrotut.count-1 do //if integer(pointer(kerrotut.objects[ii]))<1 then break else
        if 20*integer(pointer(kerrotut.objects[ii]))>base then
        write(' ',sanat[strtointdef(kerrotut[ii],0)],integer(pointer(kerrotut.objects[ii])));
        writeln;
        end;
      end;
     except writeln('failsort'); end;
     finally  KERROTUT.CLEAR;end;
      //write('+',kerrotut.count,'???');
   end;
   close(f);
end;

procedure synosana;
var sanat,rivi:tstringlist;f:text; issyn:array of binriv;arivi:string;fpos:integer;i,j,wn1,wn2,maxi,ss:integer;
 hit:array[0..63] of word;hits:word;w1,w2:string;rel:boolean;
begin
   setlength(issyn,40000);
   sanat:=tstringlist.create;
   rivi:=tstringlist.create;
   rivi.StrictDelimiter:=true;
   rivi.Delimiter:=',';
   sanat.CaseSensitive:=true;
   sanat.sorted:=true;
   sanat.loadfromfile('kaavoitetut');
   //for i:=0 to 30000 do       write(^j,sanat[i],':');
   //setlength(i
   assign(f,'synt_all.iso');reset(f);
   fpos:=0;
   maxi:=0;
   writeln('HITSZ:',sizeof(hit));
   while not eof(f) do
   begin
    try;
     readln(f,arivi);
     if arivi='' then continue;
     //inc(fpos);if fpos>4000 then break; //testing speed
     rivi.delimitedtext:=arivi;
     w1:=rivi[1];
     write(^j^j,w1,rivi.count);
     hits:=0;
     wn1:=sanAT.INDEXof(w1);if wn1<1 then continue else
     for j:=2 to rivi.count-1 do
     begin         //rel:=false;
         w2:=rivi[j];
         if w2='' then continue;
         if w2[1]='#' then begin write(^j,w1,' ####',w2);rel:=w2='#rel';continue;end;
         if rel then begin inc(ss);continue;end;
         wn2:=sanAT.INDEXof(w2);
         if wn2<0 then continue;// else
         //write(' ',w2);
         hit[hits]:=wn2;
         inc(hits);

     end;
     for i:=0 to hits do
     for j:=0 to hits do
     issyn[hit[i],hit[j]]:=true;
     //write(' ',ss);
     //if ss>63 then begin writeln(^j,ss,w1);maxi:=ss;readln;end;
     except writeln('xfailaarivi');end;
  end;
end;
type tacoc=packed record w:word;f:byte;end;
type tcocs=record cnt:word;sana:word;margin:longword;bigs:array[0..63] of tacoc;end;

function addifbig(var arec:tcocs;nw:word;nv:byte):byte;
var i:word;npos:byte;ptr:^byte;   //
begin             // jätetään nollasloti huomiotta  ettei aivo nyrjähdä.. 63 paikka siis käytettävissä
 if nv=0 then exit;
 //ptr:=@arec.bigs[0];
 with arec do
 begin
   try
   if cnt=0 then begin  bigs[1].f:=nv;  bigs[1].w:=nw;;cnt:=1;exit;end;
   npos:=1; //oletus:alkuun
   for i:=cnt {max=63} downto 1 do  //mieluummin lopusta, pieniä yrittäjiä on paljon
     if bigs[i].f>nv then begin npos:=i+1;break;end;  //löytyi isompi, sen jälkeen pitäisi laitaa. jos heti, npos=63
   if npos>=63 then exit;  //ei mahdu
   move(bigs[npos], bigs[npos+1],(63-npos)*3 );//*(@bigs-npos-1));
    bigs[npos].f:=nv;  bigs[npos].w:=nw;
    if cnt<63 then inc(cnt);
    except    write(' !!!',cnt,'/',bigs[1].F,'/',nv,'\',npos,' ');
end;
  end;
end;
procedure skumppafreqs;
begin

end;
procedure listgutmat;
var i,j,k,yposi1,yposi2:word;
   margins:array of longword;
   ole,tot,ac:qword;
   oli:integer;
   ylemat:file;
   ylensana,sananyle:array of word;
   ylet,sanat:tstringlist;
   posi,ylecount,sanacount:integer;
   cocrivi:array of byte;
    ycoc:array of word;wn1,wn2,y1,y2:word;
     //nvars,nvals:array of word;
    bigcoocs: array of tcocs;
   acocs:tcocs;
   rel:extended;
   ylepos,ylemarg:longword;
begin
    writeln('gutgutgut');
    ylet:=tstringlist.create;
    ylet.CaseSensitive:=true;
    ylet.sorted:=true;
    ylet.loadfromfile('ylesanat.lst');
    sanat:=tstringlist.create;
    sanat.CaseSensitive:=true;
    sanat.sorted:=true;
    sanat.loadfromfile('kaavoitetut');
    sanacount:=sanat.count+1;
    writeln('gutgut');
    ylecount:=ylet.count;
    setlength(ylensana,ylecount);
    setlength(sananyle,sanacount);
    setlength(bigcoocs,sanacount*64);
    //setlength(nvars,sanacount*64);
    //setlength(nvals,sanacount*64);
    setlength(ycoc,ylecount*ylecount);
    writeln('gutgutgut');
    setlength(cocrivi,sanacount);
    writeln('gut');
    setlength(margins,sanacount);
    writeln('sanat:',sanacount);
    writeln('ylet:',ylecount);


    assign(ylemat,'gutyle.bin');
    reset(ylemat,length(ycoc)*2);
    writeln('fileet ylemat????',length(ycoc));
    try
     blockread(ylemat,ycoc[0],1);
    //fstream.free;
    writeln('fileet ylemat!');
    close(ylemat);
    except on e:exception do writeln('<li>eiEionnaa:',e.Message,' ');;end;
    writeln('fileet ylemarg?');



    assign(ylemat,'gutmarg.bin');
    reset(ylemat,length(margins)*4);
     try
     blockread(ylemat,margins[0],1);
    except on e:exception do writeln('<li>eiEionnaa:',e.Message,' ',length(margins)*2);;end;
    //fstream.free;
    close(ylemat);
   for wn1:=0 to ylecount-1 do tot:=tot+margins[wn1];
   //for i:=0 to sanacount-1 do write(' .',margins[i]);
   for i:=0 to ylecount-1 do
   begin try
     posi:=sanat.indexof(ylet[i]);
     ylensana[i]:=posi+1;
     sananyle[posi]:=i+1;
     if posi<0 then writeln(' ',i,'/',posi,sanat[ylensana[i]],' ',ylet[i],' #',margins[ylensana[i]]);
     except writeln('###',i,'=',ylet[i],ylensana[i]);end;
   end;
   writeln('gogo');
   assign(ylemat,'gutall.bin');
   reset(ylemat,sanacount);
   writeln('fileet ylemarg?');
   writeln('fileet allmat????',length(cocrivi));
   try
    //blockread(ylemat,ycoc[0],1);
   //fstream.free;
   //writeln('fileet ylemat!');
   //close(ylemat);
   except on e:exception do writeln('<li>eiEionnaa:',e.Message,' ');;end;
   //for i:=1 to sanacount-1 do
     //begin blockread(ylemat,ycoc[0],1);        if i mod 1000=0 then write(i,' ');     end;
   //exit;
   //tot:=tot div 2;
   writeln(^j^j,'*************************',tot);
   for wn1:=0 to sanacount-1 do
    begin
      blockread(ylemat,cocrivi[0],1);
      yposi1:=sananyle[wn1];
      acocs:=bigcoocs[wn1];
      if yposi1>0 then write(^j,'********************************') else writeln;;
      write(^j,wn1,' ',margins[wn1],' ',sanat[wn1],' ',yposi1,': ');
      //if margins[wn1]<10 then continue;
      //for wn2:=0 to ylecount-1 do
      for wn2:=0 to sanacount-1 do
      begin
        yposi2:=sananyle[wn2];
        oli:=(cocrivi[wn2]-1);   //vähä handikappia kovin pienille
        try
          if (yposi1>0) and (yposi2>0) then oli:=ycoc[(yposi1-1)*ylecount+yposi2-1];
        except writeln('failiso:',yposi1-1,' ',yposi2);end;
        if oli<2 then continue;
        //oli:=5*(ycoc[ylecount*wn1+wn2]);
        try
        ole:=0000+margins[wn1] * margins[wn2];          //hiukka rangaistaan harvinaisia.. aika kova tuo 15000?
        except writeln('nomargins:',ylet[wn2],y2,' ',sanat[y2]);end;
        try
        //ac:=min(255,round(log2(100*oli+1) / (ole / 100+1)));
        //ac:=round(100000*oli) div (1+ole div 10000);
        if ole>0 then rel:=tot*(oli / (ole)) else continue;
        ac:=min(255,round(4*rel));
        if ac<2 then continue;// then  write(' ',sanat[wn2],'=',oli);continue;
        //ac:=min(round(log2(ac));
        //write(^j,wn1,':',ylemarg[wn1],'/',wn2,':',ylemarg[wn2],'=',oli,'/',ole,'>',ac);
        //if ac>5000 then begin writeln(cors,ac,' ',ylet[wn1],ylemarg[wn1],' ',ylet[wn2],ylemarg[wn2],'=',oli,'/',(ole));end;
        //if ac>10000 then writeln(^j'***',ylet[wn2],'/m2:',ylemarg[wn2],'
        //if ac>
        addifbig(acocs,wn2,ac);
        //big64(@nvars[wn1*64],@nvals[wn1*64],wn1,wn2,ac);   //sqrt?
        except writeln('fail ex:',ole,' ob:',oli);end;
      end;
      for i:=1 to 63 do
        if (acocs.bigs[i].w<1) or (acocs.bigs[i].f<1) then begin write(':::',i);break;end
      //if (nvars[wn1*64+i]<0) or (nvals[wn1*64+i]<=0) then begin write(':::',i);break;end
      else BEGIN try write(' ',sanat[acocs.bigs[i].w],acocs.bigs[i].f);// cocrivi[acocs.bigs[i].w],'/',margins[acocs.bigs[i].w] div 10);//,
       //else BEGIN try write(' ',sanat[nvars[wn1*64+i]],':', cocrivi[nvars[wn1*64+i]],'/',margins[nvars[wn1*64+i]] div 10);//,
        //(nvals[wn1*64+i]));
        except write('failxx',wn1*64+i,'/');end;;END;
    end;
  end;


PROCEDURE gutcoocs;
var sanat:tstringlist;f:text; arivi,resrivi:string;fpos:integer;i,j,wn1,wn2,y1,y2,maxi,ss:integer;
               coc:array of byte;
               asent,asentyle:array [0..63] of integer;
               aco,ayle:word;
               nvars,nvals:array of word;

               //e1,e2:extended;t1,t2,d1:qword;
               dist:array[0..255] of longword;
               ac:longword;
               //ccs:tstringlist;
               cors:text;
               margins:array of longword;
               ole,oli,tot:qword;
               ylemat:file;
               ylet:tstringlist; ylecount,sanacount:integer;
                ycoc:array of word;
begin
   //ccs:=tstringlist.create;
  {for i:=0 to 500 do
  begin
   t1:=1+100*i;
   write(^j,t1,'  ', round(log2(t1)));//,' ',ln(t1),log10(t1));
   for j:=90 to 10 do
   begin
    try
    if j<i then begin write(' ':16);continue end;
    t2:=10**j;
    e1:=256*t1/t2;
    d1:=round(log2(e1*2**8));
    write(round(e1):12,'/',ceil(log10(t2)):3);
    except write('!!!':12);end;
   end;
   writeln;
  end;
  exit;}
  sanat:=tstringlist.create;
  sanat.CaseSensitive:=true;
  sanat.sorted:=true;
  sanat.loadfromfile('kaavoitetut');
  sanacount:=sanat.count+1;
  writeln('sanat:',sanacount);
  setlength(coc,sanacount*sanacount);

  ylet:=tstringlist.create;
  ylet.CaseSensitive:=true;
  ylet.sorted:=true;
  ylet.loadfromfile('ylesanat.lst');
  ylecount:=ylet.count;
  writeln('ylet:',ylecount,'S:',length(coc));
  setlength(ycoc,ylecount*ylecount);
  setlength(margins,sanacount);
  setlength(nvars,ylecount*64);
  setlength(nvals,ylecount*64);
  writeln(^j,'sanasana:',length(coc),'ylesanat:',length(ycoc),'/marg:',length(margins));
  assign(cors,'cors.lst');rewrite(cors);
  assign(f,'gutsents.iso');reset(f);
  writeln('ylet:',ylecount);
   fpos:=0;
   maxi:=0;      ss:=0;tot:=0;
   writeln('gutaaaaaaaa:');
   while not eof(f) do
   begin
    try;
     readln(f,arivi);
     if arivi='olla' then continue;
     //writeln(arivi);
     inc(fpos);
     //if fpos mod 10000=1 then     //write(fpos,' ');
     //if length(arivi)<1 then if ss>1 then begin writeln(resrivi);resrivi:='';ss:=0;continue;end;
     if length(arivi)<1 then if ss>1 then
     begin
       try
       for i:=0 to  ss-1 do
       if asent[i]>0 then
       begin
         y1:=asentyle[i];
         if asent[i]>0 then
         for j:=0 to ss do  //to i
         begin
           try
           //if (y1>0) then     //nyt marginaalit lasketaan kahteen kertaan
           if i<>j then
           if (asentyle[j]>0) and (y1>0) then
           begin
             try
             inc(ycoc[ylecount*(y1-1)+asentyle[j]-1]);
             //inc(ycoc[ylecount*(asentyle[j]-1)+y1-1]);
            // inc(margins[y1-1]);
             inc(margins[asent[j]-1]);   //write(asent[i],'+ ');
             //coc[sanacount*(asent[i]-1)+(asent[j]-1)]:=255;
             //inc(ylemarg[asentyle[j]-1]);
             inc(tot);
             except write(^j,'failyle:',asent[i],':',asent[j],' yle:',asentyle[i],':',asentyle[j],'!');end;
             //write(ylet[asentyle[i]],y1,'/',ylet[asentyle[j]-1],asentyle[j]-1,'+ ');
           end else
           if asent[j]>0 then
           begin
             //continue; //nyt vain yleisille
             inc(margins[asent[j]-1]);
             try
             aco:=coc[sanacount*(asent[i]-1)+asent[j]-1];
             except write(^j,'failharva:',asent[i],':',asent[j],' ',sanat[asent[i]-1]
              ,'::',sanat[asent[j]-1],'\\',sanacount*(asent[i]-1)+(asent[j]-1),'#',length(coc),'!');end;
             //if aco=254 then write(sanat[asent[i]],' ',sanat[asent[j]]);
             if aco<255 then inc(coc[sanacount*(asent[i]-1)+(asent[j]-1)])
             ;//else write(' --',sanat[asent[i]-1],' ',sanat[asent[j]-1]);
           end;
           except write(^j,'failJII:',asent[i],':',asent[j],' yle:',asentyle[i],':',asentyle[j],'!');end;
         end;
        end;
       except write(^j,'**********failjotain:',i,'/',asent[i],':',j,'/',asent[j],' yle:',asentyle[i],':',asentyle[j]);end;
       ss:=0;fillchar(asent[0],64,0); fillchar(asentyle[0],128,0);
     end
     ;//else
     begin //ei ollut tyhjä rivi (lauseen päätös)
       wn1:=sanAT.INDEXof(arivi)+1;
       y1:=ylet.INDEXof(arivi)+1;
      //if y1<1 then continue;//NYT ei VAIN YLEISILLE
      if wn1<1 then continue;//NYT ei VAIN YLEISILLE
       //if wn1<1 then continue;//begin //resrivi:=resrivi+',';continue;end;
      // inc(fpos);if fpos>100000 then break; //testing speed
       //resrivi:=resrivi+','+arivi;
       //write('(',arivi,length(arivi),')');
       try   asent[ss]:=wn1; except writeln('toolong',ss);end;
       try asentyle[ss]:=y1; except writeln('yfailyleset:',y1);end;
       inc(ss);  //0-base
     end;
     except writeln('fail****************');end;
    end;
   //for wn1:=0 to ylecount-1 do   writeln(wn1,ylet[wn1],' ',ylemarg[wn1]);
   //data:=@lks[0];
      for i:=0 to sanacount-1 do //if margins[i]>1000 then //<>0 then write(' --',sanat[i],margins[i]);
      begin write(^j^j,i,sanat[i],margins[i],': ');
        for j:=0 to sanacount-1 do if coc[i*sanacount+j]>50 then write(' ',sanat[j]);
      end;
    exit;
   assign(ylemat,'gutyle.bin');
   rewrite(ylemat,length(ycoc)*2);
   try
    blockwrite(ylemat,ycoc[0],1);
   except on e:exception do writeln('<li>eiEionnaa: gutyle',e.Message,' ',length(ycoc)*2);;end;
//fstream.free;
   close(ylemat);
   assign(ylemat,'gutall.bin');
   rewrite(ylemat,length(coc));
   try
    blockwrite(ylemat,coc[0],1);
   except on e:exception do writeln('<li>eiEionnaa gutall:',e.Message,' ',length(ycoc)*2);;end;
//fstream.free;
   close(ylemat);
   assign(ylemat,'gutmarg.bin');
   rewrite(ylemat,length(margins)*4);
   try
    blockwrite(ylemat,margins[0],1);
   except on e:exception do writeln('<li>eiEionnaa2:',e.Message,' ',length(margins)*4);;end;
//fstream.free;
   close(ylemat);
end;


procedure finwnsyno;
var sanat,rivi:tstringlist;f:text; arivi,resrivi:string;fpos:integer;i,j,wn1,wn2,maxi,ss:integer;
 hit:array[0..63] of word;hits:word;w1,w2:string;rel,eka:boolean;
issyn:array of binriv;
asyns:array of word;
begin
setlength(issyn,40000);
setlength(asyns,40000);
   sanat:=tstringlist.create;
   rivi:=tstringlist.create;
   rivi.StrictDelimiter:=true;
   rivi.Delimiter:=',';
   sanat.CaseSensitive:=true;
   sanat.sorted:=true;
   sanat.loadfromfile('kaavoitetut');
   //for i:=0 to 30000 do       write(^j,sanat[i],':');
   //setlength(i
   //assign(f,'finwn.semrel2');reset(f);
   assign(f,'synt_all.lst');reset(f);
   fpos:=0;
   maxi:=0;
   writeln('finwn:',sanat.count);
   eka:=true;
   while not eof(f) do
   begin
    try;
     readln(f,arivi);
     //if eof(f) then if eka then begin eka:=false;close(f);assign(f,'finwn.syno2');reset(f); end;
     //write(^j,arivi);
     if arivi='' then continue;
     //inc(fpos);if fpos>4000 then break; //testing speed
     rivi.delimitedtext:=arivi;
     //w1:=trim(rivi[0]);
     //if pos(' ',w1)>0 then continue;
     resrivi:=rivi[1]+': ';
     ss:=0;
     //wn1:=sanAT.INDEXof(w1);if wn1<1 then continue else
     for j:=2 to rivi.count-1 do
     begin         //rel:=false;
        try
         w2:=trim(rivi[j]);
         if pos(' ',w2)>0 then continue;
         wn2:=sanAT.INDEXof(w2);
         if wn2<0 then continue else
         //write('(',w2,')');
         resrivi:=resrivi+','+w2;
         //hit[ss]:=wn2;
         inc(ss);
         except writeln('failaasana');end;
     end;
     //for i:=0 to ss do for j:=0 to ss do  issyn[hit[i],hit[j]]:=true; //aika turha...
     if ss>1 then writeln(^j,resrivi);
     //if ss>63 then begin writeln(^j,ss,w1);maxi:=ss;readln;end;
     except writeln('failaarivi');end;
  end;
   for wn1:=1 to 30000 do
   begin
    try
     write(^j^j,sanat[wn1],wn1,': ');
     for wn2:=0 to 30000 do begin if issyn[wn1][wn2] then if issyn[wn2][wn1] then write(sanat[wn2],' ')else write(' *****',wn1,sanat[wn2],wn2,' ');;end;//else issyn[
    except write('!!!failsana ',wn1,' ',wn2);   end;
   end;
   write('xxxxxxxxxxxxxxxxx ');
end;
procedure syno;
var sanat,rivi:tstringlist;f:text; issyn:array of binriv;arivi:string;fpos:integer;i,j,wn1,wn2:integer;
 hit:array[0..63] of word;hits:word;
begin
   setlength(issyn,40000);
   sanat:=tstringlist.create;
   rivi:=tstringlist.create;
   sanat.sorted:=true;
   sanat.loadfromfile('kaavoitetut');
   //for i:=0 to 30000 do       write(^j,sanat[i],':');
   //setlength(i
   assign(f,'test.syn');reset(f);
   fpos:=0;
   writeln('HITSZ:',sizeof(hit));
   while not eof(f) do
   begin
    try;
     readln(f,arivi);
     if arivi='' then continue;
     //inc(fpos);if fpos>4000 then break; //testing speed
     rivi.commatext:=arivi;
     //if rivi[1]='aarnio' then writeln('###########',arivi);
     //fillchar(hit[0],sizeof(hit),0);
     for i:=0 to 63 do hit[i]:=0;
     if rivi.count<3 then continue;
     hits:=0;
     for i:=1 to rivi.count-1 do
     begin if rivi[i]='' then writeln('nogofuckingemptywordshit');
     try wn1:=sanAT.INDEXof(rivi[i]);if wn1<1 then continue else
      begin hit[hits]:=wn1;inc(hits);end; except  writeln(' &&&&&&&&&&&&&&& ',hits);end;
     end;
     //if wn1<1 then continue; //vain ekan sana huomioidaan, ei tokien sanojen yhteisesiintymiä (VIELÄ)
     if hits>40 then continue;//writeln(^j,hits,'!!!!!!!!!!!!!',rivi.commatext,rivi.count,' ');
     if hits>1 then;
     for i:=0 to hits-1 do
     begin try
        begin
          for j:=0 to hits-1 do
            issyn[hit[i],hit[j]]:=true; //both ways
        end;
        except write('???fail: ',wn1,'\',wn2);end;end;//else issyn[
     except write('!!!failrivi ', hits,' ',i,'/',j,'::',arivi);   end;
   end;
   write('xxxxxxxxxxxxxxxxx ');
   for wn1:=1 to 30000 do
   begin
    try
     write(^j^j,sanat[wn1],':');
     for wn2:=0 to 30000 do begin if issyn[wn1][wn2] then if issyn[wn2][wn1] then write(sanat[wn2],' ')else write(' *****',wn1,sanat[wn2],wn2,' ');;end;//else issyn[
    except write('!!!failsana ',wn1,' ',wn2);   end;
   end;
   write('xxxxxxxxxxxxxxxxx ');
end;

function createmat:tvvmat;
var sanat:tstringlist;vvmat:tvvmat;
begin

sanat:=tstringlist.create;
sanat.loadfromfile('kaavoitetut');
vvmat:=tvvmat.create(sanat.count+1,63,sanat);
sanat.insert(0,'eka');
vvmat.readmat('dot.mat');
//vvmat.readmat('dot0.mat');
//vvmat.norm;
vvmat.sanat:=sanat;
//vvmat.counts;exit;
//vvmat.list(0);exit;
//vvmat.list(0);exit;
//writeln('laske:',sanat.count, '/',vvmat.sanat.count,'.OK?');
//vvmat.counts;
//vvmat.veivaa;
//vvmat.list(0);
//exit;
writeln('VEIVAA');
//vvmat.list(0);exit;
vvmat.veivaa;

exit;
debug:=true;
vvmat.mply;
//vvmat.list(0);
end;
procedure coocs;
var f,outf:text;kaverit,sanat:tstringlist; i:longword;j:word;line:string;
     vars,vals,nvars,nvals:array of word;nvars2,nvals2:array of word;
     w1num,w2num,w1freq,wwfreq,w1tot,prev,wcount:integer;
       n:word;
begin
 line:='0915243146';
// 0/9- 1/5- 2/4- 3/1- 4/6
 // 0/0- 1/1- 2/5- 3/3- 4/0nvars

   { n:=61;
    setlength(nvars,n*2);
    randomize;
    //for i:=0 to n-1 do begin nvars[i*2]:=strtointdef(line[i*2+1],0);Nvars[i*2+1]:=strtointdef(line[i*2+2],0);end;//random(10);end;
    for i:=0 to n-1 do begin nvars[i*2]:=i;Nvars[i*2+1]:=random(1000);end;//random(10);end;
   // for i:=0 to n-1 do begin write('- ',nvars[i*2],'/',Nvars[i*2+1]);end;

    //writeln('nvars');
    testSort(nvars[0],n);
    writeln(^j,'*************');
    for i:=0 to n-1 do begin write('  ',nvars[i*2],'\',Nvars[i*2+1]);if prev<Nvars[i*2+1] then write(^j'WWWWWW');prev:=Nvars[i*2+1];end;
    writeln(^j,'*************');
    exit;
    }
    writeln('coocs');
    createmat;exit;
    //gutcoocs;
    //gutrelas;exit;
   // finwnsyno;writeln('did');exit;
     //listgutmat;exit;

    exit;
    finwnsyno;writeln('did');
    synosana;exit;
assign(f,'skumppanit.lst');
reset(f);
assign(outf,'skumpkarsi.lst');
rewrite(outf);
  kaverit:=tstringlist.create;
  //kaverit.sorted:=true;
  kaverit.delimiter:=',';
  kaverit.StrictDelimiter:=true;
  //kaverit.quotechar:='';
  sanat:=tstringlist.create;
  sanat.sorted:=true;
  sanat.loadfromfile('kaavoitetut');
  writeln(eof(f),'zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz:::::::::::',sanat.count);
  setlength(vars,40001*64);
setlength(vals,40001*64);
setlength(nvars,40001*64);
setlength(nvals,40001*64);
while not eof(f) do
begin
  readln(f,line);
  kaverit.commatext:=line;
  readln(f,line);
  w1tot:=strtointdef(copy(line,4),0);
  //writeln(^j^j^j,kaverit.count,':',kaverit.commatext);
  //if pos('_',kaverit[0])<1 then
  w1num:=sanat.indexof(kaverit[0]);
  //if w1num<>prev+1 then writeln(w1num,kaverit[0]);    prev:=w1num;
  if w1num<0 then continue;
  nvals[w1num*64]:=w1tot;
  nvars[w1num*64]:=w1num;
  //if w1tot>5500000 then writeln(kaverit[0],sanat[nvars[w1num*64]],nvals[w1num*64],' ');
end;
 reset(f);
  wcount:=0;
  while not eof(f) do
  begin
    try
    readln(f,line);
    kaverit.commatext:=line;
    readln(f,line);
    //if pos('===',line)<1 then begin writeln('eieieieiie');readln;continue;end; //do smthg with this later
    w1tot:=strtointdef(copy(line,4),0);
    //writeln(^j^j^j,kaverit.count,':',kaverit.commatext);
    //if pos('_',kaverit[0])<1 then
    w1num:=sanat.indexof(kaverit[0]);
    //if w1num<>prev+1 then writeln(w1num,kaverit[0]);    prev:=w1num;
    if w1num<0 then continue;
    //nvals[w1num*64]:=w1tot;
    nvars[w1num*64]:=w1num;
    inc(wcount);//if i>100 then break;
    write(outf,^j,kaverit[0],',',w1num);
    //write(^j^j,kaverit[0],nvals[w1num*64],'/');
    for j:=1 to (kaverit.count-1) div 2 do
    begin
      w2num:=sanat.indexof(kaverit[j*2-1]);
      if w2num<=0 then continue;
      wwfreq:=strtointdef(kaverit[j*2],0);
      if (w2num>=0) // or (pos('_',kaverit[j*2-1])>0)   //then  write(outf,',',kaverit[j*2-1],',',kaverit[j*2])
      then write(outf,',',kaverit[j*2-1],',',kaverit[j*2]);
      if w2num>40000 then writeln('toobig:',kaverit[j],w2num,'/',j,'/',j*2-1);
      big64(@nvars[w1num*64],@nvals[w1num*64],w1num,w2num,round(10000*wwfreq / (nvals[w2num*64]+20)));   //sqrt?
    end;
    //write(^j^j,sanat[w1num],'(',w1tot,'): ' );
    //for j:=1 to min(8,kaverit.count-1) do try write(' ',sanat[nvars[w1num*64+j]],nvals[w1num*64+j]);except writeln('nonono',nvars[w1num*64+j],' ');end;
    except writeln('vitut',line);end;
  end;

  close(outf);
  close(f);
  assign(outf,'skump.lst');
  rewrite(outf);
  for i:=1 to sanat.count-1 do
  begin
    w1num:=nvars[i*64];
    write(^j^j,sanat[w1num],nvals[i*64],':');
    write(outf,^j,sanat[nvars[i*64]],nvals[i*64]);
     for j:=1 to 10 do
     begin try
       w2num:=nvars[i*64+j];if nvals[w2num*64]<1 then break;
       write(outf,',',sanat[w2num],',',nvals[w2num*64]);
       write(' ',sanat[w2num],',',nvals[w1num*64+j]);
        //round((100*nvals[i*64+j]) / ((sqrt(nvals[w2num*64])))));
     except write('!!')end;
     end;
  end;
  close(outf);
  writeln('did:',wcount);
end;

function big64(bigs,bigvals:pword;bwrd,wrd,freq:word):word;
var i,j,posi,fils:word;d:boolean;slots:word;
begin
   slots:=64;//fils:=0;
   posi:=64;
   try
   if wrd>40000 then writeln('<li>TOOBIG',wrd);
   begin
   for j:=1 to slots-1 do
    begin
     if freq>=(bigvals+j)^ then
     begin //if d then writeln(j,'.',(bigs+j)^);
       //write('+ ',j);
       posi:=j;break;end;
    end;
   end;

   //if posi=0 then
   //write(sl[wrd],freq,'=',posi,'?/??');
   if posi<slots then
   begin
    move((bigs+posi)^,   (bigs   +posi+1)^,  2*(slots-posi-1));
    move((bigvals+posi)^,(bigvals+posi+1)^,2*(slots-posi-1));
    (bigs+posi)^:=wrd;
    (bigvals+posi)^:=freq;
    //write(' ',posi);
   end;
   result:=posi;
   //if wrd=7305 then writeln('<li>',sl[wrd],freq,'@',posi,'|||');
   except writeln('*******************nopiso',wrd,'/',freq);end;
end;

procedure etsiyhdys;//(sanat:tstringlist);
var i,j,k:word; alut:array[0..31] of string;res:tstringlist;slen:byte;sana,s2:string;sanat,vertsanat,palat:tstringlist;
 f:text;
begin
 sanat:=tstringlist.create;
 palat:=tstringlist.create;
 palat.delimiter:=' ';
 sanat.loadfromfile('uussanat.all');
 //sanat.loadfromfile('uussanat.all');
 vertsanat:=tstringlist.create;
 vertsanat.loadfromfile('yhdys.uus');
 vertsanat.sort;
 res:=tstringlist.create;
 res.sorted:=true;
 writeln('<xmp>');
 for i:=0 to sanat.count-1 do
 begin
   palat.DelimitedText:=sanat[i];

   if vertsanat.indexof(palat[2])>=0 then continue else if length(palat[2])>15 then writeln(palat[2]) else res.add(sanat[i]);

 end;
 res.savetofile('uussanat2.all');
  exit;
  sanat:=tstringlist.create;
  //sanat.loadfromfile('kotussanat.lst');
  assign(f,'kotussanat.lst');
  reset(f);
  vertsanat:=tstringlist.create;
  vertsanat.loadfromfile('kaikki.kok');
  i:=0;
  while not eof(f) do
  begin
     inc(i);if i mod 1000=1 then writeln(i);
     readln(f,sana);
     slen:=length(sana);
     if slen>23 then continue;
     for j:=3 to min(15,slen) do
     if  alut[j]<>'' then
       if pos(alut[j],sana)=1 then
       begin
        if slen>j+1 then if vertsanat.indexof(copy(sana,j+1))>0 then res.add(copy(sana,j+1)+' '+alut[j]);
       end else alut[j]:='';
       alut[slen]:=sana;
  end;
   res.savetofile('yhdys.kot');
end;

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
function tuplavok(c1,c2:ansichar):boolean;
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
function diftongi(c1,c2:ansichar):boolean;
 begin
  result:=false;
  if c1=c2 then result:=false else                       //arv  i o i da                ae ao ea eo ia io oa oe ua ue
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
          if (not tuplavok(ch,chprev)) then //tavurajavokaali
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
function hyphenfirev(w:ansistring;tavus:tstringlist;var alkkon:string):word;
  var i,k,len,vpos:integer;hy:ansistring;ch,chprev:ansichar;lasttag:ansistring;
   voks:word;
begin
 {
 konsonantti vokaalin edellä - tavuraja ennen kons
 yhteensopimattomat vokaalit - tavuraja väliin
 kolme vokaalia - tr ennen kolmatta

 }
  if tavus<>nil then tavus.clear;
  len:=length(w);
  result:=0;//w[len];   duuoon  noouu
 if len=0 then exit;
 chprev:='R';//w[len];   //o
 alkkon:='';
 for i:=len downto 1 do if (pos(w[i],konsonantit)>0) then len:=len-1 else break;
 alkkon:=copy(w,len+1);
 if len<length(W) Then w:=copy(w,1,len);
 voks:=0;
 for i:=1 to len do
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
          if (not tuplavok(ch,chprev)) then //tavurajavokaali
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
   if i=len then
   begin
      if hy<>'' then begin inc(result);if tavus<>nil then tavus.insert(0,hy);end;
   end else
   chprev:=ch;
 end;
 //HUOM: NÄÄ ON JOSKUS HALUTTU / YLIM ALKUKONONANTIT ERI TAVUNA, ei kuitenkaan lasketa resulttiin
 //if alkkon<>'' then if tavus<>nil then tavus[0]:=alkkon+tavus[0];//
 //tavus.insert(0,alkkon+'');
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

