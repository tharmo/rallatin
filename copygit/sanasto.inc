
procedure tsanasto.luekaikki;
 var i,j:integer;protolist,nomsijat,rlist:tstringlist;tpl,line:string; proto:byte;lk:tlka;testlk,t2:^tlka;si:tsija;
  function p12(st:string):string;
  begin
      result:=copy(st+'                       ',1,12)+',';
  end;
 begin
    //nloput:=luenominiloput('nommuodot.csv');
    //vloput:=lueverbiloput('vmids.csv');
   protolist:=lueverbiprotot('vmids.csv');
    lueverbisijat('vsijat.csv',protolist);
    writeln('LUEKAKKI');
    for i:=1 to 80 do begin lks[i].kot:=i;lks[i].vahva:=i in [1..30,52..65,76];end;
    // writeln('<table border="1">');
   rlist:=tstringlist.create;
   line:=''; for j:=0 to 65 do    line:=line+p12(inttostr(j));rlist.add(line);
   line:=''; for j:=0 to 65 do    line:=line+p12(vsijat[j].name);rlist.add(line);
   line:=''; for j:=0 to 65 do    line:=line+p12(vsijat[j].ending);rlist.add(line);

    for i:=1 to 27 do    //verbiluokat
    begin
     lk:=lks[i+51];
     //writeln('<tr><td>',i+51,'</td>');
     line:=p12(inttostr(i))+p12(string(vesims[i]));
      for j:=0 to 65 do
      begin
       try
        si:=vsijat[j];
       if lk.vahva then proto:=si.vparad else proto:=si.hparad;
       proto:=si.vparad;
       tpl:=reversestring(tstringlist(protolist.objects[i])[proto+1]);
       vluokkasijat[51+i,j]:=tluokkasija.create(lks[i+51],vsijat[j],tpl);
       if (i+51=71) and (j in [22,27]) then vluokkasijat[i+51,j].lisuke:='k';
       if (i+51=71) and (j in [10]) then vluokkasijat[i+51,j].lisuke:='ek';
       if j=0 then lks[i+51].xtav:=vluokkasijat[i+51,0].xtavut;
       //if j=0 then  writeln('<li>iNF:',i+51,' ',vluokkasijat[i+51,j].lisuke,' ',proto,'==',lks[i+51].xtav,'</li>');
         line:=line+(p12(reversestring(vluokkasijat[i+51,j].lisuke)));
        //if j=0 then writeln('<li>x:',i+51,' ',vluokkasijat[i+51,0].xtavut,' ',reversestring(vsijat[0].ending+'.'+vluokkasijat[i+51,0].lisuke),'. ',vesims[i]);
//         for i:=52 to 78 do writeln('<li>x:',vluokkasijat[i,0].xtavut);//perusgetluokkasija[;
  //       for i:=52 to 78 do lks[i].xtav:=vluokkasijat[i,0].xtavut;//perusgetluokkasija[;
    //     except  writeln('<li>failXTAVUT');end;

       except writeln('eionnaa',i+51,j);end;
     end;
    end;
    //writeln('</table>');
   // rlist.savetofile('turha');
   WRITELN('VERBIT LUIETTU');
   nomsijat:=luenomsijat('nommuodot.csv');//,protolist);
   //for i:=0 to nomsijat.count-1 do writeln('<li>N::',tstringlist(nomsijat.objects[i]).commatext);
   WRITELN('NOMINIT LUIETTU',nomsijat.count);
    for i:=1 to 49 do    //nominiluokat
    begin
     writeln('<li>nom:',i,': ');
     lk:=lks[i];
      for j:=0 to 33 do
      begin
       try
        si:=nsijat[j];
       //if lk.vahva then proto:=si.vparad else proto:=si.hparad;
       tpl:=tstringlist(nomsijat.objects[i])[j];
       if j in [0,1,2,11,12,13,15,20..33] then writeln(j,tpl);
       except tpl:='?'+inttostr(i)+'\\\\'+inttostr(j);end;
       nluokkasijat[i,j]:=tluokkasija.create(lks[i],nsijat[j],reversestring(tpl));
       //if j=0 then writeln('!!!',i,' ',nluokkasijat[i,j].lisuke,' ');
     end;
    end;
//!    luepronsijat('prono.csv');
//!    writeln('lueprono valmis');
  // luokaavat;
    luesanat('uuskaavas2.lst');
    // for i:=1 to 48 do begin writeln(nluokkasijat[i,1].lisuke,@lks[i]=(nluokkasijat[i,1].luokka),' ');end;
    writeln('luesanat valmis. VALMIS');

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


procedure tsanasto.luepronsijat(fn:string);  //hanskaa samalla sijojen luonti luettavat sisuskalut on 1/1 sijoihin (todin kuin verbeillä, joilla on "protot")
var i,j,num:integer;
 slist,mlist:tstringlist; sps:word;
 akon,runk:string; eiet,eitak:boolean;
 begin
  slist:=tstringlist.create;
  slist.loadfromfile(fn);//'nmids.csv');
  writeln('<li>luepronomitin',slist.Count);
  mlist:=tstringlist.create;
  mlist.delimiter:=' ';
  for i:=0 to slist.count-1 do
  begin
    try
    mlist.delimitedtext:=slist[i];
    runk:=mlist[1];
    akon:='';
    //writeln('<li>',mlist.CommaText);
    while (runk<>'') and (pos(runk[1],konsonantit)>0) do begin akon:=runk[1]+akon;delete(runk,1,1);end;
    runk:=voktakarev(runk,eiet,eitak);
    pronot[i].etuv:=not(eiet);
    pronot[i].lemma:=mlist[0];
    for j:=2 to mlist.count-1 do  pronot[i].lisukkeet[j-2]:=ifs(mlist[j]='.','',reversestring(taka(mlist[j])));
    //for j:=2 to mlist.count-1 do  pronot[i].lisukkeet[j-2]:=reversestring(taka(mlist[j]));
    except writeln('<li>failpron:',i,'#',j);end;
    pronot[i].runko:=runk;
    pronot[i].alkon:=akon;
    //writeln('<li>',mlist[0],'/',pronot[i].runko,'.',pronot[i].alkon,' ::');
    //for j:=0 to 33 do writeln(pronot[i].lisukkeet[j]);
   end;
  writeln('<li>pronominitluettu:<ul>');
  exit;
  for i:=0 to slist.count-1 do
  begin
    writeln('<li>','[',pronot[i].runko,']',pronot[i].alkon,':<b>',reversestring(ifs(pronot[i].etuv,etu(pronot[i].runko),pronot[i].runko)+pronot[i].ALKON),'</b>:::') ;
    for j:=0 to 33 do
    begin
      if pronot[i].lisukkeet[j]<>'!' then
      write('('+reversestring(nsijat[j].ending+''+pronot[i].lisukkeet[j]+''+pronot[i].runko+pronot[i].alkon),') ');
    end;

  end;
end;

procedure tsanasto.lueverbisijat(fn:string;var protolist:tstringlist);
var i,j:integer;
 vheikot,hheikot,vvahvat,hvahvat:string;
 slist,rlist,tl:tstringlist;
 num:byte;
begin
 writeln('VERBILUE,',fn);
 //protolist:=lueverbiprotot('vmids.csv');
 slist:=tstringlist.create;
 rlist:=tstringlist.create;
 tl:=tstringlist.create;
 slist.loadfromfile(fn);//'vsijat.csv');
 //slist.loadfromfile('vsijat.csv');
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
   //writeln('<li>',i,':<b>',vsijat[i].ending,'</b> ',slist[i],' /// ',vsijanimet[i],' ;',vsijaesim[i],'//',slist[i]);
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
    kokok:=tpl;
    //if snum=0 then writeln('<li>lisuke:::',sija.name,'=[',lisuke,']');
    muotoja:=1;
    eatvok:=false;   tuplavok:=false;TUPLAKON:=FALSE;COPYVOK:=FALSE;EAT2VOK:=FALSE;eatkon:=false;
    if lisuke='!' then muotoja:=0;
    if pos('/',lisuke)>0 then  begin
      muotoja:=2;
      //writeln('<li>lisukkeita:',copy(lisuke,1,pos('/',lisuke)-1),':::',copy(lisuke,pos('/',lisuke)+1),'!');
      toinenmuoto:=tluokkasija.create(lka,sij,copy(lisuke,pos('/',lisuke)+1)); //pathetic!
       if lnum=60 then toinenmuoto.eatsanaa:=true;
       toinenmuoto.muotoja:=2;
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
    // hake e,k*,ah   < see? hak.k.ee. see.n
    // kiiru u,rr,iik < see? kii.r.uu see.n  //tu
    // rakas, kallis  41,i,_l,lak,0,kallis <see?
    //18,aa,_j,,0,jää  < h*   ..j.aaa.hn
    xtavut:=hyphenfi(reversestring(sij.ending+lisuke),nil);
    //if snum=0 then
    //if lnum=65 then writeln('<li>XXX',hyphenfi(reversestring(sij.ending+lisuke),nil),reversestring(sij.ending+'.'+lisuke));
end;

function tsanasto.lueverbiprotot(fn:string):tstringlist;
var i,j:integer;
 slist,mlist,rlist:tstringlist;
   function p12(st:string):string;
  begin
      result:=copy(st+'                       ',1,12)+',';
  end;

begin
 slist:=tstringlist.create;
 rlist:=tstringlist.create;
 slist.loadfromfile(fn);//'vmids.csv');
 {for i:=0 to slist.count-1 do
 begin
    mlist:=tstringlist.create;
    mlist.StrictDelimiter:=true;
    mlist.commatext:=slist[i];
    try
      //mlist.delete(4);  // imperatiivi on turhaan joukossa, se taipuu samoin kuin prs akt P1 & p2
      rlist.add('');//p12(inttostr(i)));  //0 = esim
      writeln('<li>');
      for j:=0 to 10 do  rlist[i]:=rlist[i]+p12(mlist[j]); //protomids[i,j]:=trim(mlist[j+1]);
    except writeln('<li>failread lka:',I+52,slist[I]);end;
 end;
  rlist.savetofile('turha2');}
  slist.delete(0);  slist.delete(0);  slist.delete(0);  //slist.delete(0);
  for i:=0 to slist.count-1 do
  begin
     mlist:=tstringlist.create;
     mlist.commatext:=slist[i];
     try
       //mlist.delete(4);  // imperatiivi on turhaan joukossa, se taipuu samoin kuin prs akt P1 & p2
       slist.objects[i]:=mlist;  //0 = esim
       //writeln('<li>',i+51,'::::: ');
       //for j:=0 to 10 do  writeln(' //',j,'/',mlist[j]); //protomids[i,j]:=trim(mlist[j+1]);
     except writeln('<li>failread lka:',I+52,slist[I]);end;
  end;
  writeln('<hr>');
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
   //writeln('<li>',i,')',vsijat[0].ending,'!');
   nsijat[i].esim:=nsijesims[i];
   nsijat[i].name:=nsijnams[i];
   nsijat[i].onverbi:=false;
   nsijat[i].vv:= (i in nvahvanvahvat);
   nsijat[i].hv:=not (i in nheikonheikot);
  end;
  //for i:=0 to 65 do   writeln('<li>',i,')',vsijat[i].ending,'!');
end;
FUNCTION tsanasto.GETLUOKKASIJA(LK,SIJ:WORD):tluokkasija;
begin
     try
     if lk<50 then result:=nluokkasijat[lk,sij]
     else if lk>51 then result:=vluokkasijat[lk,sij];
     except writeln('eilöydysijaamajatalosta',lk,'!!!',sij);end;
end;


