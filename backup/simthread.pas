unit simthread;

{$mode objfpc}{$H+}

interface

uses
  {$ifdef unix}
    cthreads,
    //cmem,
  {$endif}
  Classes, Dialogs, SysUtils, Math;//,Windows

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

  TCShowStatusEvent = procedure(Result: Double) of Object;
  TCShowStatusEvent1 = procedure() of Object;
  TCalculator = class(TThread)
  private
    Result: Double;
    e:Extended;
    FCOnShowStatus: TCShowStatusEvent;
    FCOnShowStatus1: TCShowStatusEvent1;
    TResistor: UInt64;
    TCapacity: UInt64;
    TVoltage: UInt64;
    TRes: Double;
    TMode: UInt64;
    //t = -ln((Uc(t))/(U_0))RC
    //?=V0.01/R //Immer 2 Kommastellen genauer als Zeiteinstellung
    //Zeit zum Entladen brauch man R C U und U(t) <- gibt die genauigkeit
    procedure TCShowStatus;
    procedure TCShowStatus1;
  protected
    procedure Execute; override;
  public
    property TCOnShowStatus: TCShowStatusEvent read FCOnShowStatus write FCOnShowStatus;
    property TCOnShowStatus1: TCShowStatusEvent1 read FCOnShowStatus1 write FCOnShowStatus1;
    Constructor Create(CreateSuspended : boolean); //UInt64 same as QWord biggest possible Number Type.
    property PTResistor: UInt64 read TResistor write TResistor;
    property PTCapacity: UInt64 read TCapacity write TCapacity;
    property PTVoltage: UInt64 read TVoltage write TVoltage;
    property PTRes: Double read TRes write TRes;
    property PTMode: UInt64 read TMode write TMode;
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
  fStatusText:='moin';
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

constructor TCalculator.Create(CreateSuspended : boolean);
begin
  inherited Create(CreateSuspended);
end;

procedure TCalculator.TCShowStatus;
begin
  if Assigned(FCOnShowStatus) then
  begin
    FCOnShowStatus(Result);
  end;
end;

procedure TCalculator.TCShowStatus1;
begin
  if Assigned(FCOnShowStatus1) then
  begin
    FCOnShowStatus1();
  end;
end;

procedure TCalculator.Execute;
begin

 //TResistor//R
 //TCapacity//C
 //TVoltage//U_0
 //TRes//
 //TMode//Max Time Calc

  if TMode = 0 then
   begin
    //Max Time Calc.
    //ln(RES/U_0)*R*C
    Result:=RoundTo(-ln(TRes/TVoltage)*TResistor*TCapacity, -2);
    Synchronize(@TCShowstatus);
   end
  else if Tmode = 1 then
   begin
    e:=Exp(1);
    //U_0*e^-(t/(r*c))
    Result:=RoundTo(TVoltage*Power(e, -(TRes/(TResistor*TCapacity))), -2);
    Synchronize(@TCShowstatus1);
   end;



end;

end.

