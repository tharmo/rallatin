unit otus;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,math;
{
 sortattava (tai indeksoitu?) lista jossa lukuja ja niihin liittyviä arvoja
 low.level muistinsiirtoja

}
type trec=record w,v:word;end;
{type tvvarray=class(tobject)
  arr:array of trec;  len:word;
  ind:array of word;
  procedure sort;
  procedure add(vari,vali:word);
  function indexof(vari:word):word;
  function newitem(r,l:word):word;
  function incr(vari,vali:word):word;
  procedure clear;
  constructor create;
end; }
type tvvmat=class(tobject)  //VAIHDETAAN TÄHÄN
  mx:array of trec; //EIKU TEHDÄÄN VAAN YKSI ISO DATABLOCKKI JOHON VIITATAAN POINTTEREILLA
  rows,cols:word;
  //len:word;  //joka rivin eka trec kertoo sanan ja rivin pituuden?
  sanat:tstringlist;
  //ind:array of word;
  function len(rivi:word):word;
  procedure sortrow(rivi:word);
  procedure add(RIVI,vari,vali:word);
  function indexof(RIVI,vari:word):word;
  function newitem(RIVI,r,l:word):word;
  function incr(RIVI,vari,vali:word):word;
  procedure clear;
  procedure list;
  constructor create(r,c:WORD);
  function getrec(i,j:word):trec;
  procedure setrec(const i,j:word);
  procedure mply;
  Property Items[i,j : word]: trec  Read getrec ; Default; //Write setrec;
end;


implementation
uses sort;
function tvvmat.getrec(i,j:word):trec;begin end;
procedure tvvmat.setrec(const i,j:word);begin end;

function tvvmat.indexof(rivi,vari:word):word;
var i,xlen:word;
begin
 result:=0;
 xlen:=mx[cols*rivi].v;
 for i:=1 to xlen do //implement some sort of binary search later
        if mx[rivi*cols].w=vari then begin result:=i;break;end;
end;
function tvvmat.len(rivi:word):word;
var i:word;
begin
  result:=mx[rivi*cols].v;
end;

function tvvmat.incr(rivi,vari,vali:word):word;
var posi:word;
begin
    posi:=indexof(rivi,vari);
    if posi=0 then
    add(rivi,vari,vali) else
       mx[rivi*cols+posi].w:=mx[rivi*cols+posi].v+vali;
end;
procedure tvvmat.clear;
begin
 //setlength(mx,0);
 //setlength(arr,64);
 //len:=0;
end;

procedure tvvmat.mply;
var rs,cs,cc:word;dotmat:tvvmat; s,i1,i2,j1,j2,ii,lim,hits:word;
  //acoi1,acoi2,acoj1,acoj2:word;
  rst,asana:string;
  ps,pi1,pi2,pj1,pj2, //pointeri yhteen sanaan rivillä
    wrs,wri1,wri2:pword; //pointeri sanan riviin
begin
  dotmat:=tvvmat.create(1,63);
 lim:=32;
 //for s:=2 to rows-1 do//kaikkii sanojen lista
 for s:=24600 to 24602 do//kaikkii sanojen lista
    begin
       //fillchar(mutuals[0],64*4,0);
       //rst:=(^j+sanat[s]+':;');
       //write(rst);
       //continue;
       wrs:=@mx[s*cols];  //s-sanan coco-listan alku
       rst:='';
       for i1:=1 to lim do  //yksi s:n cooc
       begin
          pi1:=@(wrs+i1*2)^; //i-sanan i's cooc  (joka toinen on sanan numero, joka toinen paino) 3,5,7,...
          if pi1^=s then continue;
          if pi1^ =0 then break;
          //rst:=rst+('_'+sanat[pi1^]);
          //wri1:=@mx[pi2^*cols];  //ptr
          wri1:=@mx[pi1^*cols];  //ptr
          //wri1:=@mx[pi1^*cols];  //ptr
          //write(' ',sanat[pi1^]);
          for i2:=1 to lim do  //toinen s-sanan cooc
          begin
               //continue;
               try
               pi2:=@(wrs+i2*2)^; //i-sanan i's cooc
               if pi2^=0 then break;
               if pi2^=s then continue;
               if (pi2^=pi1^) then continue;  //voi harkita otetaanko mukaan
               wri2:=@mx[pi2^*cols];  //ptr
               //rst:='     '+sanat[pi1^]+'/'+sanat[pi2^]+': ';hits:=0;
               except write('""""');end;
               for j1:=1 to lim do  //
               begin  //i-sanan ekan coocin eka coocci
                 try
                 pj1:=wri1+j1*2;  //
                 if pj1^=0 then break;
                 if pj1^=s then continue;
                 asana:=sanat[pj1^];

                 except write('J1');end;
                 for j2:=1 to lim do  //
                 begin  //i-sanan ekan coocin eka coocci
                   try
                   pj2:=@(wri2+j2*2)^;  //
                   if pj2^=0 then break;
                   if pj1^=pj2^ THEN
                   begin
                     rst:=rst+' '+asana;
                     inc(hits);
                     //reg;
                   end;
                   except write('J2');end;
                 end;
               end;
          end;  //i2
       end; //i1
       if hits>0 then write(^j^j^j,sanat[s],':',rst);

      end;  //yksi sana
end;
procedure tvvmat.list;
var rs,cs,cc:word;
begin
  write(^j,'list ',rows,'*',cols);
    for rs:=1 to rows do
    begin   cc:=mx[rs*cols].w;
      //if cc<200 then continue;
      write(^j^j,sanat[rs],'(',cc,')');
      //if len(rs)>30 then
      for cs:=1 to min(len(rs),cols) do
      begin
        try
        write(' ',sanat[mx[rs*cols+cs].w],':',mx[rs*cols+cs].v);
        except write('failmx:',rs,'/',cs,':',mx[rs*cols+cs].w);end;
      end;

    end;
 //setlength(mx,0);
 //setlength(arr,64);
 //len:=0;
end;
procedure tvvmat.add(rivi,vari,vali:word);
var posi:word;
begin
    try
    inc(mx[rivi*cols].v);
    posi:=mx[rivi*cols].v;
    mx[rivi*cols+posi].w:=vari;mx[rivi*cols+posi].v:=vali;
    //write(posi,' ');//rivi,':',vari,'=',vali,'  ');
    except write('failadd',rivi,':',vari,'=',vali);end;
end;

function Compareval(var d1,d2:pointer): integer;
var    p1,p2:pword;
  i1 : word;//(d1^);
  i2 : word;// absolute d2;
  //i1 : trec absolute d1;
  //i2 : trec absolute d2;
  //ii:word absolute d2;
begin
    p1:=@(d1+2)^;p2:=@(d2+2)^;
 i1:=word((p1)^);
 i2:=word((p2)^);
    try
  if i1=i2 then Result:=0
  else if i1<i2 then Result:=-1
  else Result:=+1;
   //write('  ?',i1,'.',i2,'=',result);
    except on e:exception do begin write(^j,'???eivittu');;end;end;

end;

procedure tvvmat.Sortrow(rivi:word);
VAR AP:POINTER;
begin
  //write(^j,'sort1:',arr[1].vr,' ',len,':');
  try
    AP:=@mx[rivi*cols+1];
 AnySort(AP,len(rivi), 4, @Compareval);
 except write(^j,'///sort2:',len(rivi),' ');    end;
end;



function tvvmat.newitem(rivi,r,l:word):word;
begin
    inc(mx[rivi*cols].v);
    mx[rivi*cols+mx[rivi*cols].v].w:=r;
    mx[rivi*cols+mx[rivi*cols].v].v:=l;
end;

constructor tvvmat.create(R,C:WORD);
begin
 ROWS:=R;cols:=c;
  setlength(mx,(R+1)*(C+1));
  //len:=0;
  //add(1,1);
end;
end.

function tvvarray.indexof(vari:word):word;
var i:word;
begin
    result:=0;
    for i:=1 to len do //implement some sort of binary search later
           if arr[i].vr=vari then begin result:=i;break;end;
end;

function tvvarray.incr(vari,vali:word):word;
var posi:word;
begin
    posi:=indexof(vari);
    if posi=0 then
    add(vari,vali) else arr[posi].vr:=arr[posi].vl+vali;
end;
procedure tvvarray.clear;
begin
 setlength(arr,0);
 setlength(arr,64);
 len:=0;
end;
procedure tvvarray.add(vari,vali:word);
var posi:word;
begin
    inc(len);
    arr[len].vr:=vari;arr[len].vl:=vali;
end;

function Compareval(var d1,d2:pointer): integer;
var    p1,p2:pword;
  i1 : word;//(d1^);
  i2 : word;// absolute d2;
  //i1 : trec absolute d1;
  //i2 : trec absolute d2;
  //ii:word absolute d2;
begin
    p1:=@(d1+2)^;p2:=@(d2+2)^;
 i1:=word((p1)^);
 i2:=word((p2)^);
    try
  if i1=i2 then Result:=0
  else if i1<i2 then Result:=-1
  else Result:=+1;
   //write('  ?',i1,'.',i2,'=',result);
    except on e:exception do begin write(^j,'???eivittu');;end;end;

end;

procedure tvvarray.Sort;
VAR AP:POINTER;
begin
  //write(^j,'sort1:',arr[1].vr,' ',len,':');
  try
    AP:=@ARR[1];
 AnySort(AP,len, 4, @Compareval);
 except write(^j,'///sort2:',len,' ');    end;
end;



function tvvarray.newitem(r,l:word):word;
begin
    inc(len);
    arr[len].vr:=r;arr[len].vl:=l;
end;

constructor tvvarray.create;
begin
  setlength(arr,64);
  len:=0;
  //add(1,1);
end;
end.

