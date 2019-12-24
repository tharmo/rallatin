program rallatin;

{$mode objfpc}{$H+}
                    {$R+}{$Q+}
uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,
  ralla, rallautils, otus, sort
  { you can add units after this };

type

  { Trallatin }

  Trallatin = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

{ Trallatin }

procedure Trallatin.DoRun;
var
  ErrorMsg: String;
begin
  // quick check parameters
  ErrorMsg:=CheckOptions('h', 'help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;
   try
   if paramstr(1)='hae' then
   begin
     writeln('hauhau:</pre>');
     //etsiyhdys;terminate;exit;
     sanasto:=tsanasto.create;
     //sanasto.luokaavat;exit;
     //terminate;exit;
     //sanasto.pikakelaa;
     writeln('<li>luotu.');
     sanasto.haelista;
     writeln('LISTAAV');
     //sanaSTO.listaa;
     sanasto.free;
     terminate;exit;
   end;
   if paramstr(1)='pronominit' then
   begin
     sanasto:=tsanasto.create;
     writeln('HANSKAAPRONOMIT');
     //sanasto.pronominit;
    // sanasto.free;
   end;
   if paramstr(1)='sema' then
   begin
     writeln('semantiikka trallatin dorun');
     coocs;

     write('didcoocs');
     terminate;exit;
    // sanasto.free;
   end;
   if paramstr(1)='relas' then
   begin
     writeln('semantiikka trallatin dorun');
     gutrelas;

     write('didcoocs');
     terminate;exit;
    // sanasto.free;
   end;
   if paramstr(1)='list' then
   begin
     writeln('listamat');
     listamat;
     write('didcoocs');
     terminate;exit;
    // sanasto.free;
   end;
  { add your program here }
  // stop program loop
   except writeln('!!!failkaikki');end;
  Terminate;
end;

constructor Trallatin.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor Trallatin.Destroy;
begin
  inherited Destroy;
end;

procedure Trallatin.WriteHelp;
begin
  { add your help code here }
  writeln('Usage: ', ExeName, ' -h');
end;

var
  Application: Trallatin;
begin
  Application:=Trallatin.Create(nil);
  Application.Run;
  Application.Free;
end.

