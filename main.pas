unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, TASources, TAChartCombos, TAGraph, Math;

type

  { TVoltUnitLabel }

  TVoltUnitLabel = class(TForm)
    CalcAccuracyInput1: TTrackBar;
    CalcAccuracyInputLabel1: TLabel;
    CalcAccuracyLabel1: TLabel;
    Chart1: TChart;


    Circuit: TImage;
    CircuitTitle: TLabel;
    CircuitMessuredVoltage: TLabel;
    CircuitMeasuredCurrent: TLabel;
    CircuitResistor: TLabel;
    CircuitVolt: TLabel;
    CalcAccuracyInputLabel: TLabel;
    Label1: TLabel;
    Label4: TLabel;
    CapacitorCapacity: TLabel;
    Label7: TLabel;
    CircuitSwitch: TLabel;
    CalcAccuracyLabel: TLabel;
    ResistorUnitLabel: TLabel;
    ResistorLabel: TLabel;
    Load: TImage;
    InVoltageInput: TTrackBar;
    CapacityInput: TTrackBar;
    ResistorInput: TTrackBar;
    CalcAccuracyInput: TTrackBar;
    UnLoad: TImage;

    Tabelle: TButton;
    LoadUnload: TButton;
    Help: TButton;

    VoltageUnitLabel: TLabel;
    AppHeadline: TLabel;
    AppSubHeadline: TLabel;
    InVoltageLabel: TLabel;
    CapacityLabel: TLabel;
    CapacityUnitLabel: TLabel;



    procedure CalcAccuracyInput1Change(Sender: TObject);
    procedure CalcAccuracyInputChange(Sender: TObject);
    procedure CapacityInputChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure InVoltageInputChange(Sender: TObject);
    procedure LoadUnloadClick(Sender: TObject);
    procedure ResistorInputChange(Sender: TObject);
  private
    ValueTable: array[1..2] of array of Double;
    procedure ShowStatus(Status: string);
    procedure TCShowStatus(Result: Double);
    procedure TCShowStatus1(Result: Double; t: Double);
  public

  end;

var
  VoltUnitLabel: TVoltUnitLabel;
  calcres: Double;
  calcres1: Double;
  calcres2: Double;




implementation

uses simthread;

{$R *.lfm}



procedure TVoltUnitLabel.FormCreate(Sender: TObject);
var
 tsim: TSimmulation;
begin
 // Init Defualt State
 VoltageUnitLabel.caption:=Inttostr(InVoltageInput.position * 12) + 'V';
 CircuitVolt.caption:=Inttostr(InVoltageInput.position * 12) + 'V';

 CapacityUnitLabel.caption:=Inttostr(CapacityInput.position) + 'F';
 CapacitorCapacity.caption:=Inttostr(CapacityInput.position) + 'F';

 ResistorUnitLabel.caption:=Inttostr(ResistorInput.position) + 'Ohm';
 CircuitResistor.caption:=Inttostr(ResistorInput.position) + 'Ohm';


 ResistorInput.position:=0;
 CapacityInput.position:=0;
 InVoltageInput.position:=0;
 calcres:=1.0;
 calcres1:=1.0;
 calcres2:=1;
 CalcAccuracyInputLabel.caption:=floattostr(calcres1)+'F';
 CalcAccuracyInputLabel1.caption:=floattostr(calcres1)+'F';



 // Start Circuit simulation.
 tsim:=TSimmulation.Create(true);
 tsim.OnShowStatus := @ShowStatus;
 tsim.FreeOnTerminate:=true;
 tsim.Resume;
end;



// Update Dynamic UI
procedure TVoltUnitLabel.ShowStatus(Status: string);
begin
 CircuitVolt.Caption := Status;
end;


// Update Static UI

procedure TVoltUnitLabel.InVoltageInputChange(Sender: TObject);
begin
 VoltageUnitLabel.caption:=Inttostr(InVoltageInput.position * 12) + 'V';
 CircuitVolt.caption:=Inttostr(InVoltageInput.position * 12) + 'V';
end;

procedure TVoltUnitLabel.CapacityInputChange(Sender: TObject);
begin
 CapacityUnitLabel.caption:=Inttostr(CapacityInput.position) + 'F';
 CapacitorCapacity.caption:=Inttostr(CapacityInput.position) + 'F';
end;

procedure TVoltUnitLabel.CalcAccuracyInputChange(Sender: TObject);
begin
 case CalcAccuracyInput.position of
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
 CalcAccuracyInputLabel.caption:=floattostr(calcres)+'F';
end;

procedure TVoltUnitLabel.CalcAccuracyInput1Change(Sender: TObject);
begin
 case CalcAccuracyInput1.position of
  0:
    begin
      calcres1 := 1;//*1
      calcres2 := 1;
    end;
  1:
    begin
      calcres1 := 0.1;//*10
      calcres2 := 10;
    end;
  2:
    begin
      calcres1 := 0.01;//*100
      calcres2 := 100;
    end;
  3:
    begin
      calcres1 := 0.001;//*1000
      calcres2 := 1000;
    end;
  else
    begin
      calcres1 := 0.1;//*10
      calcres2 := 10;
    end;
    calcres1 := 0.01;//*100
    calcres2 := 100;
 end;
 CalcAccuracyInputLabel1.caption:=floattostr(calcres)+'s';
end;

procedure TVoltUnitLabel.ResistorInputChange(Sender: TObject);
begin
 ResistorUnitLabel.caption:=Inttostr(ResistorInput.position) + 'Ohm';
 CircuitResistor.caption:=Inttostr(ResistorInput.position) + 'Ohm';
end;


















// Threading






procedure TVoltUnitLabel.LoadUnloadClick(Sender: TObject);
var
 tcalc: TCalculator;
begin
 if not(ResistorInput.position = 0 and CapacityInput.position = 0 and InVoltageInput.position = 0) then
 begin
 tcalc:=TCalculator.Create(true);
 tcalc.TCOnShowStatus := @TCShowStatus;
 tcalc.FreeOnTerminate:=true;
 //Max Time Calc.
 //ln(RES/U_0)*R*C
 tcalc.PTResistor:=ResistorInput.position;//gg R
 tcalc.PTCapacity:=CapacityInput.position;//gg C
 tcalc.PTVoltage:=InVoltageInput.position * 12;//gg  U_0
 tcalc.PTRes:=calcres;//2 means 0.01
 tcalc.PTMode:=0;//0 = Max Time Calc
 tcalc.Resume;
 end;
end;

procedure TVoltUnitLabel.TCShowStatus(Result: Double);
var
 ci : UInt64=1;
 tcalc1: TCalculator;
 crs: UInt64;
begin
 //ceil(Result) = sekunden bis genauigkeit 0 erreicht ist.
 Label1.Caption:=floattostr(Result * calcres2);
 crs:=Round(ceil(Result)*calcres2);
 Showmessage(inttostr(crs));
 SetLength(ValueTable[1],crs + 1);
 SetLength(ValueTable[2],crs + 1);
 ValueTable[1][crs + 1]:=crs;//Zeit
 ValueTable[2][crs + 1]:=0;//Ladung
 for ci:=1 to crs do
 begin
   tcalc1:=TCalculator.Create(true);
   tcalc1.TCOnShowStatus1 := @TCShowStatus1;
   tcalc1.FreeOnTerminate:=true;
   //Max Time Calc.
   //ln(RES/U_0)*R*C
   tcalc1.PTResistor:=ResistorInput.position;//gg R
   tcalc1.PTCapacity:=CapacityInput.position;//gg C
   tcalc1.PTVoltage:=InVoltageInput.position * 12;//gg  U_0
   tcalc1.PTRes:=ci;
   tcalc1.PTMode:=1;
   tcalc1.Resume;
 end;
end;

procedure TVoltUnitLabel.TCShowStatus1(Result: Double; t: Double);
begin
   ValueTable[1][ceil(t)]:=t/calcres2;
   ValueTable[2][ceil(t)]:=Result;
end;



procedure TVoltUnitLabel.HelpClick(Sender: TObject);
begin
  //Showmessage(Inttostr(tcalc.PTResistor));
end;


end.

