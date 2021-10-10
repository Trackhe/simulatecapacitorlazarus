unit simthread;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Windows;

type
  TShowStatusEvent = procedure(Status: String) of Object;
  TSimmulation = class(TThread)
  private
    fStatusText : string;
    FOnShowStatus: TShowStatusEvent;
    procedure ShowStatus;
  protected
    procedure Execute; override;
  public
    property OnShowStatus: TShowStatusEvent read FOnShowStatus write FOnShowStatus;
    Constructor Create(CreateSuspended : boolean);
  end;

  TCalculator = class(TThread)
  private
    fStatusText : string;
    FOnShowStatus: TShowStatusEvent;
    procedure ShowStatus;
  protected
    procedure Execute; override;
  public
    property OnShowStatus: TShowStatusEvent read FOnShowStatus write FOnShowStatus;
    Constructor Create(CreateSuspended : boolean, x : UInt64, y : UInt64, ); //UInt64 same as QWord biggest possible Number Type.
  end;

implementation

uses main;

{ TSimmulation }

constructor TSimmulation.Create(CreateSuspended : boolean);
begin
  inherited Create(CreateSuspended);
end;

procedure TSimmulation.ShowStatus;
begin
  if Assigned(FOnShowStatus) then
  begin
    FOnShowStatus(fStatusText);
  end;
end;

procedure TSimmulation.Execute;
var
  newStatus : string;
begin
  fStatusText := 'TMyThread Starting...';
  Synchronize(@Showstatus);
  while (not Terminated) do
  begin
    if NewStatus <> fStatusText then
      begin
        //fStatusText := newStatus;
        //Synchronize(@Showstatus);
      end;
  end;
end;

{ TCalculator }

constructor TCalculator.Create(CreateSuspended : boolean, );
begin
  inherited Create(CreateSuspended);
end;

procedure TCalculator.ShowStatus;
begin
  if Assigned(FOnShowStatus) then
  begin
    FOnShowStatus(fStatusText);
  end;
end;

procedure TCalculator.Execute;
var
  newStatus : string;
begin
  while (not Terminated) do
  begin
    if NewStatus <> fStatusText then
      begin
        //fStatusText := newStatus;
        //Synchronize(@Showstatus);
      end;
  end;
end;

end.

