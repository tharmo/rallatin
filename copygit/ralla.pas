unit ralla;

{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils,strutils,rallautils;

// procedure add(gsana:string31;nnum,nlka,nsija:word;nsanalka:byte);
// constructor create(n:word);
//type tverlvok=record ekaav,vikaav:word;vok:array[0..1] of char;end;
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
   luokka:tlka;sija:tsija;
   lnum,snum:word;
   muotoja:byte;
   lisuke:string;
   vahva:boolean;
   eatvok,eat2vok,tuplakon,tuplavok,copyvok,eatkon,eatsanaa:boolean;
   toinenmuoto:tluokkasija;
  // procedure match(alku:string);
   constructor create(lka:tlka;sij:tsija;tpl:string);
  // constructor createnull;
end;
type tsanasto=class(tobject)
 vcount,ncount:integer;
 lks:array[0..80] of tlka;
 siss:array[0..2047] of tloppuvoks;
 kons:array[0..2047] of tkonso;
 rungot:array[0..65535] of trunko;
 nlvoks,vlvoks:tstringlist;
 nsijat:array[1..33] of tsija;
 vsijat:array[1..66] of tsija;
 nluokkat:array[1..48] of tluokkasija;
 vluokkat:array[52..78] of tluokkasija;
 vluokkasijat:array[52..78] of array[0..66] of tluokkasija;
 nluokkaSIJAT:array[1..48] of array[0..33] of tluokkasija;
 procedure luekaikki;
 function luenomsijat(fn:string):tstringlist; //hanskaa samalla sijojen luonti luettavat sisuskalut on 1/1 sijoihin (todin kuin verbeill‰, joilla on "protot")
 procedure lueverbisijat(fn:string);
 procedure luesanat(fn:string);
 function lueverbiprotot(fn:string):tstringlist;
 FUNCTION GETLUOKKASIJA(LK,SIJ:WORD):tluokkasija;
 constructor create;
 end;
var sanasto:tsanaSTO;

implementation
uses //riimitys,
  math;
{$I 'sanasto.inc'}

constructor tsanasto.create;
var i,j:word;
begin
 for i:=1 to 58 do
 begin
    //lks[i].esim:=nom;
 end;
 luekaikki;

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
      //write('<li>',clka,' voks:',cvok,' ',dif,osalista[1],':::  ',osalista.commatext,' \\ ',prevosat.commatext);
      siss[cvok].vikasana:=csan; //edellisten loppuvokaalien vika sana
      siss[cvok].vikaav:=ckon;  // edellisten loppuvokaalien vikat avkonsonantit
      inc(cvok);
      siss[cvok].ekaav:=ckon+1; //avkons ei viel‰ inkrementoitu
      siss[cvok].sis:=(osalista[1]);//itse loppuvokaalit
      siss[cvok].lk:=clka;  //luokka on jo kasvatettu, t‰m‰ kuuluu siihen uuteen
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
     //writeln('<li>LKA:',clka,osalista.commatext,'<ul>');
     try
     lks[clka].ekasis:=cvok+1; // ei viel‰ kasvatettu
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
  //exit;
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
  prevosat.delimitedtext:=sanalista[0];
  writeln('<ul>');//<li>sanatkladattu',sanalista.count,'<ul style="margin:0en;padding:0em;border:1px solid red"><li>loukka:'
  //  ,prevosat[0],'<ul><li>vok:',prevosat[1],':<ul><li>kon;',prevosat[2],':ekasana',prevosat[3],':');
  for i:=1 to sanalista.count-1 do
  begin
    try
    osalista.delimitedtext:=sanalista[i];
    dif:=3;
    for j:=0 to 2 do if osalista[j]<>prevosat[j] then begin dif:=j;break;end; //2
    //write('\',dif);
    if dif=0 then uusluokka;
    if dif<2 then uusloppuvok;
    if dif<3 then uusavkon ;
     //itse rivin sana
    csan:=csan+1;
    rungot[csan].konlka:=ckon;
    rungot[csan].san:=osalista[3];
    rungot[csan].takavok:=osalista[4]='0';
    //UUSNO sans[csan].akon:=(sl[6]);
    //if sl[4]='0' then avs[ckon].takia:=avs[ckon].takia+1;  //lasketaan takavokaalisten m‰‰r‰‰ av-luokassa hakujen tehostamiseksi
    //if osalista[0]='73' then if osalista[2]='k*' then     writeln('<li>KKK',osalista.CommaText,' [',avs[ckon].v,',',avs[ckon].h,']');
    prevosat.delimitedtext:=sanalista[i];

    ;
    except writeln('!!!',osalista.commatext,'(',dif,')',prevosat.commatext,prevosat.count);end;
 end;
  lks[clka].vikasis:=cvok;
  siss[cvok].vikaav:=ckon;
  kons[ckon].vikasana:=csan;
  lks[1].ekasis:=0;
  //for clka:=52 to 78 do
  //for clka:=1 to 49 do
  for clka:=1 to 78 do
  begin
    try
    if  (clka in [22,49,50,51]) then begin continue; end;
    if clka<52 then continue;
    writeln('<li>LKA:',clka,' ',lks[clka].vahva,': ');
    try
    writeln('<li>testaa:',clka,': ');
    //if clka<>28 then if clka<>67 then continue; //sikoja:=33 else begin
       sikoja:=65;//continue;end;
    for cvok:=lks[clka].ekasis to lks[clka].vikasis do writeln(' <b>',siss[cvok].sis,'</b>');
    writeln('ok?<ul>');
    for cvok:=lks[clka].ekasis to lks[clka].vikasis do
    begin
      writeln('<li><b>','{',siss[cvok].sis,'}</b><ul>');//,'<ul>');
      sVOK:=siss[cvok].sis;
      olijo:=false;
      for ckon:=siss[cvok].ekaav to siss[cvok].vikaav do
      begin
        SVAHVA:=kons[ckon].V;
        SHEIKKO:=kons[ckon].H;
        if sVAHVA=SHEIKKO THEN if olijo then  CONTINUE else  OLIJO:=TRUE;
        writeln('<b>[',kons[ckon].v,kons[ckon].h,']</b> ');
        //for j in [0,1,2,11,12,13,15,20..33] do
        //for j in [0,5,9,12,13,16,23,36,37,39,45] do
        //for j in [0,5,11,23] do
        for j:=0 to 66 do
        begin
          try
          if not (j in [23..28]) then continue;
          if clka<50 then if not ( j in [0,1,2,11,12,13,15,20..33]) then continue;
          if clka>50 then
          //if not (j in [0,5,9,12,13,16,23,36,37,39,45]) then continue;
          lksija:=getluokkasija(clka,j);
          if lksija=nil then writeln('nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn:',clka,' ',j);
          except writeln('((!!!))');end;
          try
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
  writeln('testaasijattu');
end;


end.

