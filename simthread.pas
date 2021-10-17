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
  TCalculator = class(TThread)
  private
    Result: Double;
    FCOnShowStatus: TCShowStatusEvent;

    TResistor: UInt64;
    TCapacity: UInt64;
    TVoltage: UInt64;
    TRes: UInt8;
    TMode: UInt64;
    //t = -ln((Uc(t))/(U_0))RC
    //?=V0.01/R //Immer 2 Kommastellen genauer als Zeiteinstellung
    //Zeit zum Entladen brauch man R C U und U(t) <- gibt die genauigkeit
    procedure TCShowStatus;
  protected
    procedure Execute; override;
  public
    property TCOnShowStatus: TCShowStatusEvent read FCOnShowStatus write FCOnShowStatus;
    Constructor Create(CreateSuspended : boolean); //UInt64 same as QWord biggest possible Number Type.
    property PTResistor: UInt64 read TResistor write TResistor;
    property PTCapacity: UInt64 read TCapacity write TCapacity;
    property PTVoltage: UInt64 read TVoltage write TVoltage;
    property PTRes: UInt8 read TRes write TRes;
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

procedure TCalculator.Execute;
var
  calcres : Single;
begin

 //tcalc.PTResistor//R
 //tcalc.PTCapacity//C
 //tcalc.PTVoltage//U_0
 //tcalc.PTRes//
 //tcalc.PTMode//Max Time Calc

  Result:=0.01;
  Synchronize(@TCShowstatus);

  if TMode = 0 then
   begin
    //Max Time Calc.
    //ln(RES/U_0)*R*C
    case TRes of
      0:
        calcres := 1.0;
      1:
        calcres := 0.1;
      2:
        calcres := 0.01;
      3:
        calcres := 0.001;
      else
        calcres := 0.01;
    end;
    Result:=RoundTo(ln(calcres/TVoltage)*TResistor*TCapacity, -2);
    Synchronize(@TCShowstatus);
   end;



end;

end.

