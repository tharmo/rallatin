
procedure tsanasto.luekaikki;
 var i,j:integer;protolist,nomsijat:tstringlist;tpl:string; proto:byte;lk:tlka;testlk,t2:^tlka;si:tsija;
 begin
    //nloput:=luenominiloput('nommuodot.csv');
    //vloput:=lueverbiloput('vmids.csv');
    lueverbisijat('vsijat.csv');
    protolist:=lueverbiprotot('vmids.csv');
    for i:=1 to 80 do begin lks[i].kot:=i;lks[i].vahva:=i in [1..30,52..65];end;
    for i:=1 to 27 do    //verbiluokat
    begin
     lk:=lks[i+51];
      for j:=0 to 66 do
      begin
       try
        si:=vsijat[j];
       if lk.vahva then proto:=si.vparad else proto:=si.hparad;
       proto:=si.vparad;
       tpl:=reversestring(tstringlist(protolist.objects[i])[proto+1]);
       vluokkasijat[51+i,j]:=tluokkasija.create(lks[i+51],vsijat[j],tpl);
       if (i+51=71) and (j in [23,28]) then vluokkasijat[i+51,j].lisuke:='k';
       except writeln('eionnaa',i+51,j);end;
     end;
    end;
    writeln('verisijat luettu, nyt nominit');
    nomsijat:=luenomsijat('nommuodot.csv');
    //for i:=0 to nomsijat.count-1 do writeln('<li>',tstringlist(nomsijat.objects[i]).commatext);
    for i:=1 to 49 do    //nominiluokat
    begin
     lk:=lks[i];
      for j:=0 to 33 do
      begin
       try
        si:=nsijat[j];
       //if lk.vahva then proto:=si.vparad else proto:=si.hparad;
       tpl:=tstringlist(nomsijat.objects[i])[j];
       except tpl:='?'+inttostr(i)+'/'+inttostr(j);end;
       nluokkasijat[i,j]:=tluokkasija.create(lks[i],nsijat[j],reversestring(tpl));

     end;
    end;
    luesanat('uuskaavas.lst');
    // for i:=1 to 48 do begin writeln(nluokkasijat[i,1].lisuke,@lks[i]=(nluokkasijat[i,1].luokka),' ');end;
    writeln('luesanat valmis');

    //readbin;
    {writeln('<h1>testaaa</h1>');
    nluokkasijat[1,1].luokka:=@lks[1];
    testlk:=@lks[1];
    lks[1].esim:='huihai';
    //t2:=testlk;
    //testlk.esim:='huihai';
     //writeln('<li>',lks[1].esim,' /',testlk^.esim,'!');
    }
end;

procedure tsanasto.lueverbisijat(fn:string);
var i,j:integer;
 vheikot,hheikot,vvahvat,hvahvat:string;
 slist,tl,protolist:tstringlist;
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
   //writeln('<li>',i,':<b>',vsijat[i].vparad,'</b> ',slist[i],' /// ',vsijanimet[i],' ;',vsijaesim[i]);
 end;
 slist.free;
 tl.free;
 writeln('VERBItLUEttu,',fn);
end;

constructor tluokkasija.create(var lka:tlka;var sij:tsija;tpl:string);
var i,j:word;var luokka:tlka;
begin
  try
    luokka:=lka;
    //writeln('<li>xreate:',lka.kot,'/',sij.num,sij.esim,'//ok',luokka^=lka^);

    lnum:=lka.kot;
    sija:=sij;
    snum:=sij.num;
    lisuke:=tpl;
     //if lka.kot=41 then writeln('<li>lisuke:::',sija.name,'=[',lisuke,']');
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
     notricks:=false;
     if luokka.vahva then vahva:=sija.vv else vahva:=sija.hv;
     if pos('-',lisuke)=1 then begin lisuke:=copy(lisuke,2);eatvok:=true;end  //VOKAALIVEX häkkI häkeissä
     else if pos('*',lisuke)=1 then  begin lisuke:=copy(lisuke,2);  tuplavok:=true;end // VOKAALI kahdentuu ukko ukoon akka akkaan
     else if pos('?',lisuke)=1 then begin  lisuke:=copy(lisuke,2);copyvok:=true;end  //välivokaali kopioidaan loppuun..suO suOhOn JäÄ jäÄhÄn
     else if pos('+',lisuke)=1 then begin lisuke:=copy(lisuke,2);tuplakon:=true;end //konsonatti tuplataan kaNsi kaNNen
     else if pos('#',lisuke)=1 then begin lisuke:=copy(lisuke,2,99);eat2vok:=true;end
     else if pos('_',lisuke)=1 then begin lisuke:=copy(lisuke,2,99);eatkon:=true;end
     else notricks:=true;
     //if lka.kot=41 then writeln('<li>lisuke:',sija.name,'=[',lisuke,']');
     //if lnum<3 then     writeln('<li>sija:',lnum, '/' ,sij.num,' ',tpl,'><b>[',lisuke,']</b> ',reversestring(sij.ending),' ',ifs(vahva,'V','H'),muotoja,ifs(sija.vv,'V','H'),luokka.vahva);
    except writeln('FAILSIJALUOKKA',lka.kot,':',sij.num,sij.ending);end;
    //writeln(luokka=@lka);
    // hake e,k*,ah   < see? hak.k.ee. see.n
    // kiiru u,rr,iik < see? kii.r.uu see.n  //tu
    // rakas, kallis  41,i,_l,lak,0,kallis <see?
    //18,aa,_j,,0,jää  < h*   ..j.aaa.hn
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
      //for j:=1 to 10 do   //protomids[i,j]:=trim(mlist[j+1]);
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
  slist.delete(0); slist.delete(0);   slist.delete(0); //slist.delete(0);
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
     else if lk>51 then result:=vluokkasijat[lk,sij];
     except writeln('eilöydysijaamajatalosta',lk,'!!!',sij);end;
end;


