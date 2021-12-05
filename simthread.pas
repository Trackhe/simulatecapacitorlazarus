unit simthread;

{$mode objfpc}{$H+}

interface

uses
  {$ifdef unix}
    cthreads,
    //cmem,
  {$endif}
  {$IF defined(windows)}
  Windows,
  {$ELSEIF defined(freebsd) or defined(darwin)}
  ctypes, sysctl,
  {$ELSEIF defined(linux)}
  {$linklib c}
  ctypes,
  {$ENDIF}
  Classes, Dialogs, SysUtils, Math, StdCtrls, LazLogger;


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
  TCShowStatusEvent1 = procedure(Result: Double; t: Double) of Object;
  TCalculator = class(TThread)
  private
    Result: Double;
    t: Double;
    e:Extended;
    FCOnShowStatus: TCShowStatusEvent;
    FCOnShowStatus1: TCShowStatusEvent1;
    TResistor: UInt64;
    TCapacity: UInt64;
    TVoltage: UInt64;
    TRes: Double;
    TRes0: Double;
    TRes1: Double;
    TMode: UInt64;
    TCountPart: UInt64;
    TRestCountPart: UInt64;
    //t = -ln((Uc(t))/(U_0))RC
    //?=V0.01/R //Immer 2 Kommastellen genauer als Zeiteinstellung
    //Zeit zum Entladen brauch man R C U und U(t) <- gibt die genauigkeit
    FAffinityMask: dWord;
    procedure TCShowStatus;
    procedure TCShowStatus1;
    procedure SetAffinity(const Value: dWord);
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
    property PTRes0: Double read TRes0 write TRes0;
    property PTRes1: Double read TRes1 write TRes1;
    property PTMode: UInt64 read TMode write TMode;
    property PTCountPart: UInt64 read TCountPart write TCountPart;
    property PTRestCountPart: UInt64 read TRestCountPart write TRestCountPart;
    property AffinityMask : dWord read FAffinityMask write SetAffinity;
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
  NewStatus : string;
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
    FCOnShowStatus1(Result, t);
  end;
end;

procedure TCalculator.Execute;
var
  i: DWord;
  roundtoi: int32;
begin

 //TResistor//R
 //TCapacity//C
 //TVoltage//U_0
 //TRes//
 //TMode//Max Time Calc
  //SetThreadAffinty(0);
  if(TRes1 = 0.01)
  then roundtoi:=2
  else if(TRes1 = 0.001)
  then roundtoi:=3
  else if(TRes1 = 0.1)
  then roundtoi:=1
  else roundtoi:=0;


  if (not Terminated) then
  begin
    if TMode = 0 then
    begin
      //Max Time Calc.
      //ln(RES/U_0)*R*C
      Result:=RoundTo(-ln(TRes/TVoltage)*TResistor*TCapacity, -roundtoi);
      Synchronize(@TCShowstatus);
    end
    else if Tmode = 1 then
    begin

      if (TRes = 1) then
      begin
        TRestCountPart:=0;
      end;
      //debugln(Floattostr(ceil((TCountPart * (TRes - 1)))) + ' bis' + Floattostr(ceil((TCountPart * TRes) + TRestCountPart)));
      for i:= ceil((TCountPart * (TRes - 1)) + TRestCountPart) to ceil((TCountPart * TRes) + TRestCountPart) do
      begin
        if (not Terminated) then
        begin
           e:=Exp(1);
           //U_0*e^-(t/(r*c))

           Result:=RoundTo(TVoltage*Power(e, -( (i * TRes0) /(TResistor*TCapacity))), -roundtoi);
           t:=i;
           Synchronize(@TCShowstatus1);
        end;
      end;




    end;
  end;
end;

procedure TCalculator.SetAffinity(const Value: dWord);
begin
  //FAffinityMask := SetThreadAffinityMask(Handle,Value);
  //if FAffinityMask = 0 then raise Exception.Create('Error setting thread affinity mask : ' + IntToStr(GetLastError));
end;

end.

