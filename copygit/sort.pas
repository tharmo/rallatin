unit sort;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils,otus;
type  TCompareFunc = function (var elem1, elem2:pointer): Integer;
procedure AnySort(var Arr:pointer; Count: Integer; Stride: Integer; CompareFunc: TCompareFunc);

implementation
procedure AnyQuickSort(var Arr:pointer; idxL, idxH: Integer; Stride: Integer; CompareFunc: TCompareFunc; var SwapBuf);
var
  ls,hs,i : Integer;
  li,hi : Integer;
  mi    : Integer;
  ms    : Integer;
  pb    : PByteArray;
  lw,hw,mw:pointer;
  pw:pword;
begin
  try
  //pb:=@Arr;
  li:=idxL;
  hi:=idxH;
  mi:=(li+hi) div 2;
  ls:=li*Stride;
  hs:=hi*Stride;
  ms:=mi*Stride;
  mw:=arr+ms;//pb^[ls]);
  lw:=(arr+ls);//pb^[ls]);
  hw:=arr+hs;//pb^[ls]);
  repeat
    try
    // try    write(^j^j' (',li+1,'/',mi+1,'/',hi+1,')');except writeln('NOGO');end;
    //write(' ',idxl,'.',idxh ,';;  ',ls,':', aw^,'  /  ',ms,':',bw^);
    while CompareFunc(lw, mw) > 0 do begin
      inc(ls, Stride);
      //write(' (+',li+1,')');
      inc(li);
      lw:=(arr+ls);//pb^[ls]);
    end;
    //write(' //low:',li);
    while CompareFunc( mw,hw ) > 0 do begin
      //write(' (-',hi+1,')');
      dec(hs, Stride);
      dec(hi);
      hw:=arr+hs;//pb^[ls]);

    end;
    //write(' //hi:',hi);
    except on e:exception do begin write(^j,e.message);raise;end;end;
    if ls <= hs then begin
      //write(' *',li+1,'/',hi+1,' ');
      Move((arr+ls)^, SwapBuf, Stride);
      Move((arr+hs)^, (arr+ls)^, Stride);
      Move(SwapBuf, (arr+hs)^, Stride);
      inc(ls, Stride); inc(li);
      lw:=(arr+ls);//pb^[ls]);
      dec(hs, Stride); dec(hi);
      hw:=(arr+hs);//pb^[ls]);
      //writeln;
      //for i:=0 to 7 do begin pw:=@(arr+4*i)^;write(pw^,':',(pw+1)^,' ');end;
    end;
  until ls>hs;
  //write('>>>>>>>>>');
  if hi>idxL then AnyQuickSort(Arr, idxL, hi, Stride, CompareFunc, SwapBuf);
  if li<idxH then AnyQuickSort(Arr, li, idxH, Stride, CompareFunc, SwapBuf);
  except writeln('---');end;
end;

procedure AnySort(var Arr:pointer; Count: Integer; Stride: Integer; CompareFunc: TCompareFunc);
var
  buf: array of byte;i:integer;  p:pword;
begin
  try
  //writeln(^j'sort***',word((arr+2)^),'#',count,'***');
  //for i:=0 to count-1 do begin p:=@(arr+i*4)^;writeln(p^, ':',(p+1)^,' ');end;
  //for i:=0 to count do writeln(word((arr+i)^), ' ',word((arr+i+2)^));
  SetLength(buf, Stride);
  AnyQuickSort(Arr, 0, Count-1, Stride, compareFunc, buf[0]);
  except on e:exception do begin write(^j,e.message);raise;end;end;
end;

end.

