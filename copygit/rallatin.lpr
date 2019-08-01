program rallatin;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, SysUtils, CustApp,
  ralla, rallautils
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
   sanasto:=tsanasto.create;
  { add your program here }

  // stop program loop
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
  Application.Title:='rallatin';
  Application.Run;
  Application.Free;
end.

