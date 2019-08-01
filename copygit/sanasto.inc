
procedure tsanasto.luekaikki;
 var i,j:integer;protolist,nomsijat:tstringlist;tpl:string; proto:byte;lk:tlka;si:tsija;
 begin
    //nloput:=luenominiloput('nommuodot.csv');
    //vloput:=lueverbiloput('vmids.csv');
    lueverbisijat('vsijat.csv');
    protolist:=lueverbiprotot('vmids.csv');
    for i:=1 to 80 do begin lks[i].kot:=i;lks[i].vahva:=i in [1..30,52..65];end;
    writeln('<table border="1"><tr><td></td>');
    for j:=0 to 66 do    //verbiluokat
     writeln('<td>',j,' (',vsijaesim[j],')</td>');
    writeln('</tr><tr><td></td>');
    for j:=0 to 66 do    //verbiluokat
     writeln('<td>',j,' (',vsijanimet[j],')</td>');
    writeln('</tr><tr>');
    for i:=1 to 27 do    //verbiluokat
    begin
     lk:=lks[i+51];
      writeln('<tr><td>',i+51,' (',vesims[i],')</td>');
      for j:=0 to 66 do
      begin
        si:=vsijat[j];
       if lk.vahva then proto:=si.vparad else proto:=si.hparad;
       proto:=si.vparad;
       tpl:=reversestring(tstringlist(protolist.objects[i])[proto+1]);
       vluokkasijat[i,j]:=tluokkasija.create(lks[i+51],vsijat[j],tpl);
       writeln('<td>',proto,(tpl));
       writeln('</td>');

     end;
      writeln('<td>',i,'</td></tr>');
    end;
    writeln('</table>');
    nomsijat:=luenomsijat('nommuodot.csv');
    //for i:=0 to nomsijat.count-1 do writeln('<li>',tstringlist(nomsijat.objects[i]).commatext);
    writeln('***',nomsijat.count,'<table border="1"><tr><td></td>');
    for j:=0 to 33 do    //nominiluokat
      writeln('<td>',j,' (',nsijesims[j],')</td>');
    writeln('</tr><tr><td></td>');
    for i:=1 to 48 do    //nominiluokat
    begin
     //writeln('<td><td colspan="33">',i,tstringlist(nomsijat.objects[i]).commatext,'</td></tr>');
     lk:=lks[i];
      writeln('<tr><td>',i,' (',nexamples[i],')</td>');
      for j:=0 to 33 do
      begin
       try
        si:=nsijat[j];
       //if lk.vahva then proto:=si.vparad else proto:=si.hparad;
       tpl:=tstringlist(nomsijat.objects[i])[j];
       except tpl:='?'+inttostr(i)+'/'+inttostr(j);end;
       nluokkasijat[i,j]:=tluokkasija.create(lks[i],nsijat[j],reversestring(tpl));
      // tluokkasija.create(lks[i],nsijat[j],tpl);
       writeln('<td>',j,(tpl),'/',nluokkasijat[i,j].lisuke);
       writeln('</td>');

     end;
      writeln('<td>',i,'</td></tr>');
    end;
    writeln('</table>');
    luesanat('uuskaavas.lst');
end;

procedure tsanasto.lueverbisijat(fn:string);
var i,j:integer;
 vheikot,hheikot,vvahvat,hvahvat:string;
 slist,tl,protolist:tstringlist;
 //sijat:array of tsija;
 num:byte;
begin
 writeln('VERBILUE,',fn);
 protolist:=lueverbiprotot('vmids.csv');
 slist:=tstringlist.create;
 tl:=tstringlist.create;
 slist.loadfromfile(fn);//'vsijat.csv');
 for i:=0 to slist.count-1 do     // 0..65
 begin
   tl.commatext:=slist[i];
   num:=strtointdef(tl[0],90);
   vsijat[i].num:=num;
   vsijat[i].vparad:=strtointdef(tl[1],255);
   vsijat[i].hparad:=strtointdef(tl[3],255);
   vsijat[i].vv:=tl[2]='v1';
   vsijat[i].hv:=tl[4]='h1';
   vsijat[i].ending:=reversestring(tl[5]);
   vsijat[i].onverbi:=true;
   vsijat[i].name:=vsijanimet[num];
   vsijat[i].esim:=vsijaesim[num];
   writeln('<li>',i,':<b>',vsijat[i].vparad,'</b> ',slist[i],' /// ',vsijanimet[i],' ;',vsijaesim[i]);
  // createsija(i,slist[i]);
  //if sijat[i].vv then  vvahvat:=vvahvat+','+inttostr(i) else vheikot:=vheikot+','+inttostr(i);
  //if sijat[i].hv then hvahvat:=hvahvat+','+inttostr(i) else hheikot:=hheikot+','+inttostr(i);
  //writeln('<li>',i,':',vsijanimet[i],'/',vsijaesim[i],' <b>',reversestring(sijat[i].ending),'</b>');
  {for j:=0 to 27 do  //verbiluokat
  //if (j<12) or (j>24) then
  if (j+52<64) or (j+52=76) then
   lmmids[j,si]:=reversestring(protomids[j,sijat[si].vparad])
 else //for j:=12 to 27 do
   lmmids[j,si]:=reversestring(protomids[j,sijat[si].hparad]);
   }
 end;
 slist.free;
 tl.free;
end;
constructor tluokkasija.create(lka:tlka;sij:tsija;tpl:string);
var i,j:word;
begin
    //writeln('<li>xreate:',lka.kot,'/',sij.num,sij.esim,'//ok');
  try
    luokka:=lka;
    lnum:=luokka.kot;
    sija:=sij;
    snum:=sij.num;
    lisuke:=tpl;
    muotoja:=1;
    eatvok:=false;   tuplavok:=false;TUPLAKON:=FALSE;COPYVOK:=FALSE;EAT2VOK:=FALSE;eatkon:=false;
    if lisuke='!' then muotoja:=0;
    if pos('/',lisuke)>0 then  begin
      muotoja:=2;
      //writeln('<li>lisukkeita:',copy(lisuke,1,pos('/',lisuke)-1),':::',copy(lisuke,pos('/',lisuke)+1),'!');
      toinenmuoto:=tluokkasija.create(lka,sij,copy(lisuke,pos('/',lisuke)+1)); //pathetic!
       if lnum=60 then toinenmuoto.eatsanaa:=true;
      lisuke:=copy(lisuke,1,pos('/',lisuke)-1);
    end; // sousi souti yms
    //vahva:=sija.vv;
    if luokka.vahva then vahva:=sija.vv else vahva:=sija.hv;
     if pos('-',lisuke)=1 then begin lisuke:=copy(lisuke,2);eatvok:=true;end;  //VOKAALIVEX häkkI häkeissä
     if pos('*',lisuke)=1 then  begin lisuke:=copy(lisuke,2);  tuplavok:=true;end // VOKAALI kahdentuu ukko ukoon akka akkaan
     else if pos('*',lisuke)>0 then begin  lisuke:=copy(lisuke,1,length(lisuke)-1);copyvok:=true;end;  //välivokaali kopioidaan loppuun..suO suOhOn JäÄ jäÄhÄn
     if pos('+',lisuke)=1 then begin lisuke:=copy(lisuke,2);tuplakon:=true;end; //konsonatti tuplataan kaNsi kaNNen
     if pos('#',lisuke)=1 then begin lisuke:=copy(lisuke,2,99);eat2vok:=true;end;
     if pos('_',lisuke)=1 then begin lisuke:=copy(lisuke,2,99);eatkon:=true;end;
     if lnum<3 then

     writeln('<li>sija:',lnum, '/' ,sij.num,' ',tpl,'><b>[',lisuke,']</b> ',reversestring(sij.ending),' ',ifs(vahva,'V','H'),muotoja,ifs(sija.vv,'V','H'),luokka.vahva);
     //writeln('<li>xreate:',lka.kot,'/',sij.num,sij.esim,'//',);

    except writeln('FAILSIJALUOKKA',lka.kot,':',sij.num,sij.ending);end;
end;

function tsanasto.lueverbiprotot(fn:string):tstringlist;
var i,j:integer;
 slist,mlist:tstringlist;
begin
slist:=tstringlist.create;
  slist.loadfromfile(fn);//'vmids.csv');
  slist.delete(0);  slist.delete(0);  slist.delete(0);  //slist.delete(0);
  for i:=0 to slist.count-1 do
  begin
     mlist:=tstringlist.create;
     mlist.commatext:=slist[i];
     try
       mlist.delete(4);  // imperatiivi on turhaan joukossa, se taipuu samoin kuin prs akt P1 & p2
       slist.objects[i]:=mlist;  //0 = esim
      //for j:=1 to 10 do
      //protomids[i,j]:=trim(mlist[j+1]);
     except writeln('<li>failread lka:',I+52,slist[I]);end;
  end;
  result:=slist;
end;

function tsanasto.luenomsijat(fn:string):tstringlist;  //hanskaa samalla sijojen luonti luettavat sisuskalut on 1/1 sijoihin (todin kuin verbeillä, joilla on "protot")
var i,j,num:integer;
 slist,mlist:tstringlist;
 begin
 slist:=tstringlist.create;
  slist.loadfromfile(fn);//'nmids.csv');
  slist.delete(0); slist.delete(0);
  slist.delete(0); //slist.delete(0);
  for i:=0 to slist.count-1 do
  begin
   mlist:=tstringlist.create;
     mlist.delimitedtext:=slist[i];
     mlist.delete(0);
     mlist.delete(0);
     slist.objects[i]:=mlist;
   end;
  writeln('nominitluettu');
  result:=slist;
  for i:=0 to 33 do
  begin

   nsijat[i].num:=i;
   nsijat[i].ending:=reversestring(nendings[i]);
   nsijat[i].esim:=nsijesims[i];
   nsijat[i].name:=nsijnams[i];
   nsijat[i].onverbi:=false;
   nsijat[i].vv:= (i in nvahvanvahvat);
   nsijat[i].hv:=not (i in nheikonheikot);
  end;
end;

FUNCTION tsanasto.GETLUOKKASIJA(LK,SIJ:WORD):tluokkasija;
begin
     try
     if lk<50 then result:=nluokkasijat[lk,sij]
     else if lk>51 then result:=vluokkasijat[lk-51,sij];
     except writeln('eilöydysijaamajatalosta',lk,'!!!',sij);end;

end;


