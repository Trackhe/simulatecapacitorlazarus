unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, TASources, TAChartCombos, TAGraph, Math;

type

  { TVoltUnitLabel }

  TVoltUnitLabel = class(TForm)
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

    procedure CapacityInputChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure InVoltageInputChange(Sender: TObject);
    procedure ResistorInputChange(Sender: TObject);
    procedure TabelleClick(Sender: TObject);
  private
    procedure ShowStatus(Status: string);
    procedure TCShowStatus(Result: Double);
  public

  end;

var
  VoltUnitLabel: TVoltUnitLabel;





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

procedure TVoltUnitLabel.ResistorInputChange(Sender: TObject);
begin
 ResistorUnitLabel.caption:=Inttostr(ResistorInput.position) + 'Ohm';
 CircuitResistor.caption:=Inttostr(ResistorInput.position) + 'Ohm';
end;


















// Threading






procedure TVoltUnitLabel.TabelleClick(Sender: TObject);
var
 tcalc: TCalculator;
begin
 tcalc:=TCalculator.Create(true);
 tcalc.TCOnShowStatus := @TCShowStatus;
 tcalc.FreeOnTerminate:=true;
 //Max Time Calc.
 //ln(RES/U_0)*R*C
 tcalc.PTResistor:=ResistorInput.position;//gg R
 tcalc.PTCapacity:=CapacityInput.position;//gg C
 tcalc.PTVoltage:=InVoltageInput.position;//gg  U_0
 tcalc.PTRes:=2;//2 means 0.01
 tcalc.PTMode:=0;//0 = Max Time Calc
 tcalc.Resume;

end;

procedure TVoltUnitLabel.TCShowStatus(Result: Double);
begin
 ShowMessage('hiho');
 Label1.Caption:=floattostr(Result);
end;





procedure TVoltUnitLabel.HelpClick(Sender: TObject);
begin
  //Showmessage(Inttostr(tcalc.PTResistor));
end;


end.

