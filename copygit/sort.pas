unit sort;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,otus;
type  TCompareFunc = function (elem1, elem2:pointer): Integer;
procedure AnySort(var Arr:pointer; Count: Integer; Stride: Integer; CompareFunc: TCompareFunc);

implementation
uses math;
procedure spart(var Arr:pointer; idxL, idxH: Integer; Stride: Integer; CompareFunc: TCompareFunc; var SwapBuf);
var
  lss,hss,i : Integer;
  li,hi : Integer;
  newlo,newhi : Integer;
  ti    : Integer;
  tss    : Integer;
  pb    : PByteArray;
  //lw,hw,tw:pointer;
  pw:pword;
  procedure swap(a,b:integer);
  begin       //write('/',a,b,'\');
  Move((arr+a*stride)^, SwapBuf, Stride);
  Move((arr+b*stride)^, (arr+a*stride)^, Stride);
  Move(SwapBuf, (arr+b*stride)^, Stride);
 end;
begin
  try
  //pb:=@Arr;
  li:=idxL;
  hi:=idxH;
  ti:=(li+hi) div 2;
  lss:=li*Stride;
  //hss:=hi*Stride;
  //tss:=ti*Stride;
  //tw:=arr+ti*stride;//pb^[ls]);
  //lw:=(arr+li*stride);//pb^[ls]);
  //hw:=arr+hi;//pb^[ls]);
  //write(^j'  :#############################/hi:',hi,'/lo:',li,':::          ');
  // for i:=li to hi do begin pw:=@(arr+4*i)^;write(pw^,':',(pw+1)^,' ');end;
  repeat
    newlo:=999;newhi:=-1;
    //try
 //    write(^j^j'    (',li,'/',ti,'/',hi,')');

    //write(' ',idxl,'.',idxh ,';;  ',ls,':', aw^,'  /  ',ms,':',bw^);
    for i:=li to ti-1 do if CompareFunc(arr+i*stride, arr+ti*stride)<=0 then begin newlo:=i;break;end;    //onko alapuolella pienempiä
    //write('/L',newlo);
    for i:=hi downto ti+1 do if CompareFunc(arr+i*stride, arr+ti*stride)>0 then begin newhi:=i;break;end; //yläällä isompia?
    //write('/H',newhi);

    if newhi>newlo then begin //write('<>',newlo,newhi);
     swap(newlo,newhi);inc(li);dec(hi); end //vaihdetaan jonojen hänniltä, jatketaan

    else if newhi>ti then  //alapää kunnossa,kohde vaihdetaan ja jatketaan yläosan kanssa
       begin
       //write('>',ti,newhi);
         swap(ti,newhi);li:=ti;ti:=newhi;hi:=ti;
     end
    else if newlo<ti then  //yläpää kunnossa (koska ei jäänyt edellisiin testeihin)
       begin swap(ti,newlo);
        hi:=ti-1;
        ti:=newlo; //tutkitaan alassiirrettyä kohdearvoa, onko sen yläpuolella isompia
        li:=ti; //ei etsitä enää pienempiä mistään
        //; write('<',newlo,ti)
       end
    else break;//begin li:=min(ti,li);hi:=max(ti,hi);break; end;//kummatkin kunnossa
    //write(^j'     /hi:',hi,'/lo:',li,'::');
      //for i:=0 to 4 do begin pw:=@(arr+4*i)^;write(pw^,':',(pw+1)^,' ');end;
    //write('/hi:',hi,'/lo:',li);
  until li>hi;
  //write(^j,'   ### ');
  //for i:=0 to 4 do begin pw:=@(arr+4*i)^;write(pw^,':',(pw+1)^,' ');end;
  //write(' /hi:',hi,'/lo:',li,' @',ti,'!');
  //write('>>>>>>>>>');
  if ti-1>idxL then begin spart(Arr, idxL, ti-1, Stride, CompareFunc, SwapBuf);end;
  if ti+1<idxH then begin spart(Arr, ti+1, idxH, Stride, CompareFunc, SwapBuf);end;
  except writeln('---');end;
end;

procedure AnySort(var Arr:pointer; Count: Integer; Stride: Integer; CompareFunc: TCompareFunc);
var
  buf: array of byte;i:integer;  p:pword;
begin
  try
  //writeln(^j'sort***',word((arr)^),word((arr+2)^),word((arr+4)^),'#',count,'***');
  //for i:=0 to count-1 do begin p:=@(arr+i*4)^;writeln(p^, ':',(p+1)^,' ');end;
  //for i:=0 to count do writeln(word((arr+i)^), ' ',word((arr+i+2)^));
  SetLength(buf, Stride);
  spart(Arr, 0, Count-1, Stride, compareFunc, buf[0]);
  except on e:exception do begin write(^j,e.message);raise;end;end;
end;

end.
while true do  begin
   write(' (?',li,'/',mi,')');
   if CompareFunc(lw, tw) <=0 then break;
   inc(ls, Stride);
  write(' (+',li,')');
  inc(li);
  lw:=(arr+ls);//pb^[ls]);
end;
write(' //low:',li);
while true do  begin
   write(' (?',mi,'/',hi,')');
  if CompareFunc( mw,hw ) <= 0 then break;
   dec(hs, Stride);
   dec(hi);
   hw:=arr+hs;//pb^[ls]);
 end;
write(' //high:',hi);
except on e:exception do begin write(^j,e.message);raise;end;end;
if ls <= hs then begin
  if ls=ts then begin swap(hi,loend;
// swapataan ja kasvatetaan hilow
  write(' \LO:',li,'\HI:',hi,' ');
  inc(ls, Stride); inc(li);
  lw:=(arr+ls);//pb^[ls]);
  dec(hs, Stride); dec(hi);
  hw:=(arr+hs);//pb^[ls]);
  write(' \LO:',li,'\HI',hi,' ');
  //writeln;
end;
