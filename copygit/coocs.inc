procedure list2grams;
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
        except write('failx',wn1*64+i,'/');end;;END;
    end;
  end;


