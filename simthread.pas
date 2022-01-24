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
  Classes, Dialogs, SysUtils, Math, StdCtrls, LazLogger, DateUtils;


type
  TShowStatusEvent = procedure(Status1: String; Status2: String; Status3: String; String4: String) of Object;
  TSimmulation = class(TThread)
  private
    fStatusText : array[1..4] of String;
    FOnShowStatus: TShowStatusEvent;


    TSResistor: UInt64;
    TSCapacity: UInt64;
    TSVoltage: UInt64;
    TSRes: Int32;
    TSRes0: Int32;
    TSState: Boolean;
    TSState_time: LongInt;

    procedure ShowStatus;
  protected
    procedure Execute; override;
  public
    property OnShowStatus: TShowStatusEvent read FOnShowStatus write FOnShowStatus;
    Constructor Create(CreateSuspended : boolean);
    property PTSResistor: UInt64 read TSResistor write TSResistor;
    property PTSCapacity: UInt64 read TSCapacity write TSCapacity;
    property PTSVoltage: UInt64 read TSVoltage write TSVoltage;
    property PTSRes: Int32 read TSRes write TSRes;
    property PTSRes0: Int32 read TSRes0 write TSRes0;
    property PTSState: Boolean read TSState write TSState;
    property PTSState_time: LongInt read TSState_time write TSState_time;

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
    Constructor Create(CreateSuspended : boolean); //UInt64 same as QWord biggest possible Number Type.
    property TCOnShowStatus: TCShowStatusEvent read FCOnShowStatus write FCOnShowStatus;
    property TCOnShowStatus1: TCShowStatusEvent1 read FCOnShowStatus1 write FCOnShowStatus1;
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
    FOnShowStatus(fStatusText[1], fStatusText[2], fStatusText[3], fStatusText[4]);
  end;
end;

procedure TSimmulation.Execute;
var
  NewStatus : array[1..4] of String;
  TSSVoltage,TSSVoltage_i,TSSVoltage_e : Int64;
  TSSTimestamp,TSSTimestamp_v : LongInt;
  TSSAmpere,TSSLadung,TSSLadung_e: Double;
  Is_Update : Boolean = false;
  arrayi: Int32;
  delay_time: Int32 = 200;
begin


  //fStatusText:='moin';
  //Synchronize(@Showstatus);
  while (not Terminated) do
  begin

  //TSState_time == timestamp in ms
  TSSTimestamp_v:=(floor(ln(TSVoltage)*TSResistor*TSCapacity) - Round((DateTimeToUnix(Now) - TSState_time)));
  if(TSSTimestamp_v <= 0)
  then TSSTimestamp := 0
  else TSSTimestamp := TSSTimestamp_v;

    //[1]
    if not TSSVoltage = TSVoltage then
    begin

      TSSVoltage_i:= TSSVoltage_i + 1;

      //((10s * 1000) / delay_time) == TSSVoltage_i

      TSSVoltage_e:=Round(  TSSVoltage_i *  (  (TSVoltage - TSSVoltage) / ((1000 * 1000) / delay_time)  ));

      //TSSVoltage := Round(Power(time, 2) * );
    end
    else
    begin
      TSSVoltage_e := TSVoltage;
      TSSVoltage_i:=0;
    end;

    //NewStatus [1] = TSVoltage
    //[1]
    NewStatus[1]:=floattostrf(TSSVoltage_e, fffixed, 10, 0) + 'V';

    //NewStatus [2] == TSAmpere
    //[2]
    if TSState then //TSState Entladen:Laden
    begin
     //TSState_time == timestamp in ms


     //A = U/R
     //U = TVoltage*Power(Exp(1), -((TSSTimestamp)/(TResistor*TCapacity))


     //I(t) in A = -(U_0*e^-(t/(r*c))/r)
     TSSAmpere:=RoundTo((-(TSVoltage*Power(Exp(1), -((TSSTimestamp)/(TSResistor*TSCapacity))))/TSResistor), -TSRes);
     NewStatus[2]:=floattostrf(TSVoltage+TSSAmpere, fffixed, 6, TSRes) + 'V';
    end
    else
    begin
     NewStatus[2]:='NA';
    end;

    //NewStatus [3] == TSColomb
    //[3]
    if TSState then //TSState Entladen:Laden
    begin

     //C in F = -(t/ln(U_0*e^-(t/(r*c))/U_0)*r)
     TSSLadung:=RoundTo(-(TSSTimestamp/(ln((TSVoltage*Power(Exp(1), -((TSSTimestamp)/(TSResistor*TSCapacity))))/TSVoltage)*TSResistor)), -2);

     if(TSSLadung <= 0) then TSSLadung_e := 0
     else TSSLadung_e := TSSLadung;

     NewStatus[3]:=floattostrf(TSSLadung_e, fffixed, 6, TSRes) + '/' + inttostr(TSCapacity) + 'F';
    end
    else
    begin
     NewStatus[3]:='NA';
    end;

    //NewStatus [4] == Load%
    //[4]
    if TSState then //TSState Entladen:Laden
    begin
     if MainFrame.Debug then debugln('TSSLadung_e: ' + Floattostr(TSSLadung_e) + ' TSCapacity: ' + Inttostr(TSCapacity * 100));
     NewStatus[4]:=floattostrf((TSSLadung_e / TSCapacity * 100), fffixed, 6, TSRes) + '%';
    end
    else
    begin
     NewStatus[4]:='NA%';
    end;



    for arrayi:=1 to 4 do
    begin
      if not (fStatusText[arrayi] = NewStatus[arrayi]) then
      begin
        fStatusText[arrayi]:= NewStatus[arrayi];
        Is_Update := true;
      end;
    end;
    if Is_Update then Synchronize(@Showstatus);
    Is_Update := false;
    sleep(delay_time);

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
      if MainFrame.Debug then debugln('TRes:' + Floattostr(TRes) + 'TVoltage:' + Inttostr(TVoltage) + 'TResistor:' + Inttostr(TResistor) + 'TCapacity:' + Inttostr(TCapacity) + 'roundtoi:' + Floattostr(roundtoi));
      Result:=RoundTo(-ln(TRes/TVoltage)*TResistor*TCapacity, -roundtoi);
      if MainFrame.Debug then debugln('Result:' + Floattostr(Result));
      Synchronize(@TCShowstatus);
    end
    else if Tmode = 1 then
    begin

      if (TRes = 1) then
      begin
        TRestCountPart:=0;
      end;
      if MainFrame.Debug then debugln(Floattostr(ceil((TCountPart * (TRes - 1)))) + ' bis ' + Floattostr(ceil((TCountPart * TRes) + TRestCountPart)));
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

