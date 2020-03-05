unit twmat;

{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils;
type twv=record w,v:word;end;

type tintlist=class(tobject)
  len:word;
  items:array[0..255] of twv;
  function getit(w:word):twv;
procedure setit(w,v:word);
procedure incr(w,v:word);
procedure clear;
procedure sortw;
procedure sortv;
  public
 // property Item [i : word] : word Read getit Write SetIt;default;
  constructor create;
end;
procedure joutava;

implementation
uses sort;
type  TCompareFunc = function (elem1, elem2:pointer): Integer;
  function Compareval(d1,d2:pointer): integer;
   var    p1,p2:pword;
     i1 : word;//(d1^);
     i2 : word;// absolute d2;
   begin
    try
     p1:=@(d1+2)^;p2:=@(d2+2)^;
    i1:=word((p1)^);
    i2:=word((p2)^);
     if i1=i2 then Result:=0
     else if i1<i2 then Result:=-1
     else Result:=+1;
       except on e:exception do begin write(^j,'???failsortval');;end;end;

   end;

  function Comparevar(d1,d2:pointer): integer;
   var    p1,p2:pword;   i1,i2 : word;
   begin
    try
     p1:=@(d1)^;p2:=@(d2)^;
    i1:=word((p1)^);
    i2:=word((p2)^);
     if i1=i2 then Result:=0
     else if i1<i2 then Result:=-1
     else Result:=+1;
       except on e:exception do begin write(^j,'???failsortvar');;end;end;

   end;


procedure  tintlist.clear;
var p:pointer;
begin
  fillchar(items[0],len*4,0);
  len:=0;
end;
procedure  tintlist.sortw;
var p:pointer;
begin
  p:=@items[1];
  AnySort(p, len, 4, @Comparevar);
end;
procedure  tintlist.sortv;
var p:pointer;
begin
  p:=@items[1];
  AnySort(p, len, 4, @Compareval);
end;
  constructor tintlist.create;
  begin
    //setlength(item,255);
   len:=0;
  end;
function tintlist.getit(w:word):twv;
var posi,i:word;t:twv;
begin
posi:=0;
for i:=1 to len do if items[i].w=w then begin posi:=i;break;end;// else if
if posi=0 then result.w:=0 else result:=items[posi];
end;
  procedure tintlist.incr(w,v:word);
  var posi,i:word;t:twv;
  begin
    try
    posi:=0;
    for i:=1 to len do if items[i].w=0 then break else if items[i].w=w then begin posi:=i;break;end;
    if posi>0 then inc(items[posi].v,v) else
    if len<255 then begin
      inc(len);
      items[len].w:=w;
      items[len].v:=v;
      posi:=len;
    end;
    //t:=items[len];
   except write(' !',posi,'/',len);end;
  end;
  procedure tintlist.setit(w,v:word);
  var posi,i:word;//t:twv;
  begin
    posi:=0;
    for i:=1 to len do if items[i].w=w then begin posi:=i;break;end;
    if posi>0 then inc(items[posi].v)
  end;
procedure joutava;
var lista:tintlist; i,j,k,w,v:word;  a:twv;
begin
  randomize;
 lista:=tintlist.create;
 for i:=1 to 10 do
 begin
 w:=random(8)+2;
 v:=random(10);
 write(w,'/',v,' ');
 lista.incr(w,v);
 end;
 writeln(^j,'ORIG******************************');
 for i:=1 to 10 do begin a:=lista.items[i];writeln(i,':',a.w,' ',a.v);end;
 writeln(^j,'VALS:******************************');
 lista.sortv;
 for i:=1 to 10 do begin a:=lista.items[i];writeln(i,':',a.w,' ',a.v);end;
 writeln(^j,'VARS:******************************');
 lista.sortw;
 for i:=1 to 10 do begin a:=lista.items[i];writeln(i,':',a.w,' ',a.v);end;
end;
end.

