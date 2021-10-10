unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, TASources, TAChartCombos, TAGraph;

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
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
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

    procedure FormCreate(Sender: TObject);
    procedure TabelleClick(Sender: TObject);
  private
    procedure ShowStatus(Status: string);
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
 tsim:=TSimmulation.Create(true);
 tsim.OnShowStatus := @ShowStatus;
 tsim.FreeOnTerminate:=true;
 tsim.Resume;
end;

procedure TVoltUnitLabel.TabelleClick(Sender: TObject);
var
 tsim: TSimmulation;
begin
 tsim:=TSimmulation.Create(true);
 tsim.OnShowStatus := @ShowStatus;
 tsim.FreeOnTerminate:=true;
 tsim.Resume;
end;

procedure TVoltUnitLabel.ShowStatus(Status: string);
begin
 CircuitVolt.Caption := Status;
end;

end.

