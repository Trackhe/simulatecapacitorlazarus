unit main;

{$mode objfpc}{$H+}

interface

uses
  {$IF defined(windows)}
  Windows,
  {$ELSEIF defined(freebsd) or defined(darwin)}
  ctypes, sysctl,
  {$ELSEIF defined(linux)}
  {$linklib c}
  ctypes,
  {$ENDIF}
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, TASources, TAChartCombos, TAGraph, TASeries, TAChartListbox,
  TAFuncSeries, Math, Process, LazLogger, INIFiles, DateUtils;

type

  { TMainFrame }

  TMainFrame = class(TForm)

    //All Definitions for the Form
    CalcAccuracyInput1: TTrackBar;
    CalcAccuracyInputLabel1: TLabel;
    Chart1: TChart;
    Chart1BSplineSeries1: TBSplineSeries;
    Chart1CubicSplineSeries1: TCubicSplineSeries;
    Chart1LineSeries1: TLineSeries;
    ChartListbox1: TChartListbox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;


    Circuit: TImage;
    CircuitTitle: TLabel;
    CircuitMessuredVoltage: TLabel;
    CircuitMessuredCurrent: TLabel;
    CircuitResistor: TLabel;
    CircuitVolt: TLabel;
    CalcAccuracyInputLabel: TLabel;

    CreatedBy: TLabel;
    CalcPercentage: TLabel;
    CircuitSwitch: TLabel;
    CalcAccuracyLabel: TLabel;
    Beenden: TButton;
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

    //All Funktions that called from the Form
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure InVoltageInputChange(Sender: TObject);
    procedure CapacityInputChange(Sender: TObject);
    procedure ResistorInputChange(Sender: TObject);
    procedure CalcAccuracyInputChange(Sender: TObject);
    procedure CalcAccuracyInput1Change(Sender: TObject);



    procedure TabelleClick(Sender: TObject);
    procedure LoadUnloadClick(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure BeendenClick(Sender: TObject);

    //Picture Lever
    procedure LoadClick(Sender: TObject);
    procedure UnLoadClick(Sender: TObject);


  private
    ValueTable: array[1..2] of array of double;

    procedure SetAccuracyInput;
    procedure SetAccuracyInput1;
    procedure InVoltageInputChangeOperation;
    procedure CapacityInputChangeOperation;
    procedure ResistorInputChangeOperation;
    procedure SetCheckBox1;
    procedure SetCheckBox2;

    procedure CancelProzess;
    procedure StartCalculation;
    procedure ShowStatus(Status1: string; Status2: string; Status3: string; Status4: string);
    procedure TCShowStatus(Result: double);
    procedure TCShowStatus1(Result: double; t: double);

  public
    Debug: Boolean;
    TableIsLoaded:Boolean;
    terminate: Boolean;

  end;

var
  MainFrame: TMainFrame;//Main Frame
  SAVE: TINIFile;//Config File
  //Setup vars
  //Debug: Boolean;//CheckBox1.Checked
  //Already defined InVoltageInput.position,CapacityInput.position,ResistorInput.position,CalcAccuracyInput.position,CalcAccuracyInput1.position;

  calcres: double;
  calcres1: double;
  calcres2: double;
  crsitc: int64;
  crs: UInt64;
  ProcInfo: TProcess;

implementation

uses valuetable_form, simthread;

{$R *.lfm}

var
  tsim: TSimmulation;


procedure TMainFrame.FormCreate(Sender: TObject);
begin
  terminate:=false;



  //Create circuit simulation.
  tsim := TSimmulation.Create(True);

  //Build and/read Config and state save
  SAVE := TINIFile.Create('save.ini');
  Debug := SAVE.ReadBool('DEBUG', 'Debug', false);
  SAVE.WriteBool('DEBUG', 'Debug', Debug);
  CheckBox2.Checked := SAVE.ReadBool('SimulationSettings', 'Settings', false);
  SAVE.WriteBool('SimulationSettings', 'Settings', CheckBox2.Checked);

  if Debug then
  begin
    debugln('Guten Morgen!');
    debugln('Reading Config.');
    debugln('DEBUG:Debug = True');
  end;
  InVoltageInput.position := SAVE.ReadInteger('SimulationSettings', 'InputVoltage', 0);
  SAVE.WriteInteger('SimulationSettings', 'InputVoltage', InVoltageInput.position);
  CapacityInput.position := SAVE.ReadInteger('SimulationSettings', 'CapacitorCapacity', 0);
  SAVE.WriteInteger('SimulationSettings', 'CapacitorCapacity', CapacityInput.position);
  ResistorInput.position := SAVE.ReadInteger('SimulationSettings', 'DischargeResistor', 0);
  SAVE.WriteInteger('SimulationSettings', 'DischargeResistor', ResistorInput.position);
  if Debug then
  begin
    debugln('SimulationSettings:InputVoltage = ' + Inttostr(InVoltageInput.position));
    debugln('SimulationSettings:CapacitorCapacity = ' + Inttostr(CapacityInput.position));
    debugln('SimulationSettings:DischargeResistor = ' + Inttostr(ResistorInput.position));
    debugln('SimulationSettings:Settings = ' + Booltostr(CheckBox2.Checked));
  end;
  CalcAccuracyInput.position := SAVE.ReadInteger('DrawSettings', 'DrawnYPrecison', 1);
  SAVE.WriteInteger('DrawSettings', 'DrawnYPrecison', CalcAccuracyInput.position);
  CalcAccuracyInput1.position := SAVE.ReadInteger('DrawSettings', 'DrawnXPrecison', 1);
  SAVE.WriteInteger('DrawSettings', 'DrawnXPrecison', CalcAccuracyInput1.position);
  CheckBox1.Checked := SAVE.ReadBool('DrawSettings', 'FastDraw', false);
  SAVE.WriteBool('DrawSettings', 'FastDraw', CheckBox1.Checked);
  if Debug then
  begin
    debugln('DrawSettings:DrawnYPrecison = ' + Inttostr(InVoltageInput.position));
    debugln('DrawSettings:DrawnXPrecison = ' + Inttostr(CapacityInput.position));
    debugln('DrawSettings:FastDraw = ' + Booltostr(CheckBox1.Checked));
  end;

  //Be sure all variables are Updated
  InVoltageInputChangeOperation;
  CapacityInputChangeOperation;
  ResistorInputChangeOperation;
  SetAccuracyInput;
  SetAccuracyInput1;
  SetCheckBox2;

  CalcAccuracyLabel.Visible:=CheckBox2.Checked;
  CalcAccuracyInput.Visible:=CheckBox2.Checked;
  CalcAccuracyInputLabel.Visible:=CheckBox2.Checked;
  CalcAccuracyInput1.Visible:=CheckBox2.Checked;
  CalcAccuracyInputLabel1.Visible:=CheckBox2.Checked;

  //Start circuit simulation.
  tsim.OnShowStatus := @ShowStatus;
  tsim.PTSCapacity := CapacityInput.position;
  tsim.PTSState_time := DateTimeToUnix(Now);
  tsim.PTSResistor := ResistorInput.position;
  tsim.PTSCapacity := CapacityInput.position;
  tsim.PTSVoltage := Round(InVoltageInput.position);
  tsim.PTSRes := CalcAccuracyInput.position;
  tsim.PTSRes0 := CalcAccuracyInput1.position;
  tsim.PTSState := False;
  tsim.FreeOnTerminate := True;
  tsim.Start;
  //debugln(Booltostr(TableIsLoaded));

end;

//Update Dynamic UI
procedure TMainFrame.ShowStatus(Status1: string; Status2: string; Status3: string; Status4: string);
begin
  CircuitMessuredVoltage.Caption := Status1;
  //CapacitorCapacity.Caption := Status3;
  //Label4.Caption:=Status4;
  //CircuitMessuredCurrent.Caption := Status2;
end;


//Update Static UI
procedure TMainFrame.InVoltageInputChange(Sender: TObject);
begin
  InVoltageInputChangeOperation;
end;

procedure TMainFrame.CapacityInputChange(Sender: TObject);
begin
  CapacityInputChangeOperation;
end;

procedure TMainFrame.ResistorInputChange(Sender: TObject);
begin
  ResistorInputChangeOperation;
end;

procedure TMainFrame.CalcAccuracyInputChange(Sender: TObject);
begin
  SetAccuracyInput;
end;

procedure TMainFrame.CalcAccuracyInput1Change(Sender: TObject);
begin
  SetAccuracyInput1;
end;

procedure TMainFrame.TabelleClick(Sender: TObject);
begin
  ValuetableForm.Show;
end;

procedure TMainFrame.CheckBox1Change(Sender: TObject);
begin
  SetCheckBox1;
end;

procedure TMainFrame.CheckBox2Change(Sender: TObject);
begin
  SetCheckBox2;
end;

//Update methods
procedure TMainFrame.InVoltageInputChangeOperation;
begin
  SAVE.WriteInteger('SimulationSettings', 'InputVoltage', InVoltageInput.position);
  VoltageUnitLabel.Caption := IntToStr(InVoltageInput.position) + 'V';
  CircuitVolt.Caption := IntToStr(InVoltageInput.position) + 'V';

  if not (ResistorInput.position = 0) and not (CapacityInput.position = 0) and
    not (InVoltageInput.position = 0) then
    LoadUnload.Enabled := True
  else
    LoadUnload.Enabled := False;

  if (LoadUnload.Caption = 'Abbrechen') then
  begin
   CancelProzess;
  end;
  tsim.PTSVoltage := Round(InVoltageInput.position);
  tsim.PTSState_time := DateTimeToUnix(Now);


  Load.Visible := True;
  UnLoad.Visible := False;
  CircuitSwitch.Caption := 'Laden';
  tsim.PTSState := False;
  LoadUnload.Caption := 'Entladen';

  Chart1LineSeries1.Clear;
  MainFrame.ChartListbox1.Clear;
  if TableIsLoaded then ValuetableForm.StringGrid1.Clear;
end;

procedure TMainFrame.CapacityInputChangeOperation;
begin
  SAVE.WriteInteger('SimulationSettings', 'CapacitorCapacity', CapacityInput.position);
  CapacityUnitLabel.Caption := IntToStr(CapacityInput.position) + 'F';
  //CapacitorCapacity.Caption := IntToStr(CapacityInput.position) + 'F';

  if not (ResistorInput.position = 0) and not (CapacityInput.position = 0) and
    not (InVoltageInput.position = 0) then
    LoadUnload.Enabled := True
  else
    LoadUnload.Enabled := False;

  if (LoadUnload.Caption = 'Abbrechen') then
  begin
   CancelProzess;
  end;
  tsim.PTSCapacity := Round(CapacityInput.position);
  tsim.PTSState_time := DateTimeToUnix(Now);

  Load.Visible := True;
  UnLoad.Visible := False;
  CircuitSwitch.Caption := 'Laden';
  tsim.PTSState := False;
  LoadUnload.Caption := 'Entladen';

  Chart1LineSeries1.Clear;
  MainFrame.ChartListbox1.Clear;
  if TableIsLoaded then ValuetableForm.StringGrid1.Clear;
end;

procedure TMainFrame.ResistorInputChangeOperation;
begin
  SAVE.WriteInteger('SimulationSettings', 'DischargeResistor', ResistorInput.position);
  ResistorUnitLabel.Caption := IntToStr(ResistorInput.position) + 'Ohm';
  CircuitResistor.Caption := IntToStr(ResistorInput.position) + 'Ohm';

  if not (ResistorInput.position = 0) and not (CapacityInput.position = 0) and
    not (InVoltageInput.position = 0) then
    LoadUnload.Enabled := True
  else
    LoadUnload.Enabled := False;

  if (LoadUnload.Caption = 'Abbrechen') then
  begin
   CancelProzess;
  end;
  tsim.PTSResistor := Round(ResistorInput.position);
  tsim.PTSState_time := DateTimeToUnix(Now);

  Load.Visible := True;
  UnLoad.Visible := False;
  CircuitSwitch.Caption := 'Laden';
  tsim.PTSState := False;
  LoadUnload.Caption := 'Entladen';

  Chart1LineSeries1.Clear;
  MainFrame.ChartListbox1.Clear;
  if TableIsLoaded then ValuetableForm.StringGrid1.Clear;
end;

procedure TMainFrame.SetAccuracyInput;
begin
    SAVE.WriteInteger('DrawSettings', 'DrawnYPrecison', CalcAccuracyInput.position);
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
  CalcAccuracyInputLabel.Caption := floattostr(calcres) + 'F';
end;

procedure TMainFrame.SetAccuracyInput1;
begin
  SAVE.WriteInteger('DrawSettings', 'DrawnXPrecison', CalcAccuracyInput1.position);
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
  CalcAccuracyInputLabel1.Caption := floattostr(calcres1) + 's';
end;

procedure TMainFrame.SetCheckBox1;
begin
  SAVE.WriteBool('DrawSettings', 'FastDraw', CheckBox1.Checked);
end;

procedure TMainFrame.SetCheckBox2;
begin
  SAVE.WriteBool('SimulationSettings', 'Settings', CheckBox2.Checked);
  CalcAccuracyLabel.Visible:=CheckBox2.Checked;
  CalcAccuracyInput.Visible:=CheckBox2.Checked;
  CalcAccuracyInputLabel.Visible:=CheckBox2.Checked;
  CalcAccuracyInput1.Visible:=CheckBox2.Checked;
  CalcAccuracyInputLabel1.Visible:=CheckBox2.Checked;
end;








//Max Time Calc.
//ln(RES/U_0)*R*C

//The first thread is only created to calculate the max time
//The second threads startet with an amount of calculations that need to be done. (they calculate all steps)

var
  tcalc: TCalculator;//Thread to calculate the max unload time with arguments
  tcalc1: TCalculator;//Thread to calculate all the steps between

//Buttons to unload and load
procedure TMainFrame.LoadClick(Sender: TObject);
begin
  if LoadUnload.Enabled then StartCalculation;
end;

procedure TMainFrame.UnLoadClick(Sender: TObject);
begin
  if LoadUnload.Caption = 'Abbrechen' then StartCalculation;//Cancel
  StartCalculation;//Load
end;

procedure TMainFrame.LoadUnloadClick(Sender: TObject);
begin
  StartCalculation;
end;


//Step One, calculate the max calculation count.
procedure TMainFrame.StartCalculation;
begin
     if (LoadUnload.Caption = 'Entladen') then//Check the state.
     begin
      if not (ResistorInput.position = 0) and not (CapacityInput.position = 0) and not (InVoltageInput.position = 0) then
      begin
        Load.Visible := False;
        UnLoad.Visible := True;
        CircuitSwitch.Caption := 'Entladen';
        LoadUnload.Caption := 'Abbrechen';
        if Debug then debugln('---------------------------');
        if Debug then debugln('Calc the max Unload Time.');

        tsim.PTSState := True;
        //GetLogicalCpuCount();
        tcalc := TCalculator.Create(True);
        tcalc.TCOnShowStatus := @TCShowStatus;
        tcalc.FreeOnTerminate := True;
        //Max Time Calc.
        //ln(RES/U_0)*R*C
        tcalc.PTResistor := ResistorInput.position;//gg R
        tcalc.PTCapacity := CapacityInput.position;//gg C
        tcalc.PTVoltage := InVoltageInput.position;//gg  U_0
        tcalc.PTRes := calcres;//2 means 0.01
        tcalc.PTMode := 0;//0 = Max Time Calc
        tcalc.Start;
      end;
     end else if (LoadUnload.Caption = 'Laden') then
     begin
      Chart1LineSeries1.Clear;
      Chart1BSplineSeries1.Clear;
      Chart1CubicSplineSeries1.Clear;
      MainFrame.ChartListbox1.Clear;
      ValuetableForm.StringGrid1.Clear;
      Load.Visible := True;
      UnLoad.Visible := False;
      CircuitSwitch.Caption := 'Laden';
      tsim.PTSState := False;
      LoadUnload.Caption := 'Entladen';
     end else if (LoadUnload.Caption = 'Abbrechen') then
     begin
      CancelProzess;
     end;
end;

procedure TMainFrame.CancelProzess;
begin
     tcalc1.Terminate;
     CalcPercentage.Caption := 'Abgebrochen';
     LoadUnload.Caption := 'Laden';
end;

procedure TMainFrame.BeendenClick(Sender: TObject);
begin
  terminate:=true;
  if (LoadUnload.Caption = 'Abbrechen') then
  begin
    tcalc1.Terminate;
  end;
  Application.Terminate;
end;




//Step two, split the calculations in to threads.
procedure TMainFrame.TCShowStatus(Result: double);
var
  ci: UInt64;
  crstcountpart: UInt64;
  crstcountpartrest: UInt64;
  ProcAFMask, SysAFMask: QWord;
  CPUcores: set of 0..31;
  cpucount: int64;
begin
  if Debug then debugln('Max Unload Time: ' + Floattostr(Result));


  cpucount := 1;
  { Get the current values }
  //GetProcessAffinityMask( GetCurrentProcess, ProcAFMask, SysAFMask);
  { Manipulate }
  //SysAFMAsk := $00000001; // Set this process to run on CPU 1 only
  { Set the Process Affinity Mask }
  //SetProcessAffinityMask( GetCurrentProcess, SysAFMAsk);

  CPUcores := []; //0 .. 63

  //ceil(Result) = sekunden bis genauigkeit 0 erreicht ist.
  //CreatedBy.Caption:=floattostr(Result * calcres2);
  crs := ceil(Result * calcres2);//anzahl der endgültigen berechnungen
  if Debug then debugln('Max Calculations: ' + Inttostr(crs));

  //Showmessage(inttostr(crs));
  SetLength(ValueTable[1], crs + 1);
  SetLength(ValueTable[2], crs + 1);

  //zero_load_time:=Result;//Zeit
  crsitc := 0;
  crstcountpart := crs div cpucount;
  crstcountpartrest := crs mod cpucount;
  if Debug then debugln('CPU Count: ' + Inttostr(cpucount));
  if Debug then debugln('Calculations Parts: ' + Inttostr(cpucount));
  if Debug then debugln(Floattostr((crstcountpart * cpucount) + crstcountpartrest) + ':' + Inttostr(crs));

  Chart1.Extent.YMax := InVoltageInput.position;
  Chart1.Extent.XMax := Result;

  for ci := 1 to cpucount do //CPU Core Count
  begin
    CPUcores := CPUcores + [ci];
    tcalc1 := TCalculator.Create(True);
    tcalc1.AffinityMask := dword(CPUcores);
    tcalc1.TCOnShowStatus1 := @TCShowStatus1;
    tcalc1.FreeOnTerminate := True;
    tcalc1.PTResistor := ResistorInput.position;//gg R
    tcalc1.PTCapacity := CapacityInput.position;//gg C
    tcalc1.PTVoltage := InVoltageInput.position;//gg  U_0
    tcalc1.PTRes := ci;
    tcalc1.PTRes0 := calcres1;
    tcalc1.PTRes1 := calcres;
    tcalc1.PTMode := 1;
    tcalc1.PTCountPart := crstcountpart;
    tcalc1.PTRestCountPart := crstcountpartrest;
    tcalc1.Start;
  end;
end;




//Step three, take the results.
procedure TMainFrame.TCShowStatus1(Result: double; t: double);
var
  i: UInt64;
  chartdrawing:Boolean=true;
begin
  if Debug then debugln('Result: ' + Floattostr(Result));
  if Debug then debugln('t: ' + Floattostr(t));

  crsitc := crsitc + 1;//Count function calls

  ValueTable[1][ceil(t)] := t * calcres1;//Timestamp
  ValueTable[2][ceil(t)] := Result;//Currentvalue

  CalcPercentage.Caption := floattostrf(crsitc / ((crs + 1) / 100), fffixed, 4, 0) + '% ' + Inttostr(crsitc) + ':' + Inttostr(crs + 1);
  Application.ProcessMessages;


  if crsitc = crs + 1 then
  begin
    ValuetableForm.StringGrid1.ColCount := crsitc + 1;
    ValuetableForm.StringGrid1.RowCount := 3;
    ValuetableForm.StringGrid1.Cells[0, 0] := 'T in s';
    ValuetableForm.StringGrid1.Cells[0, 1] := 'V in v';
    ValuetableForm.StringGrid1.Cells[0, 2] := 'C in F';

    if Debug then debugln('Fastdraw: ' + Booltostr(CheckBox1.Checked));

    for i := 0 to High(ValueTable[1]) do
    begin

      if CheckBox1.Checked and chartdrawing then
      begin
        Chart1.DisableRedrawing;
        chartdrawing:=false;
      end else if not CheckBox1.Checked and not chartdrawing then
      begin
        Chart1.EnableRedrawing;
        chartdrawing:=true;
      end;

      if (LoadUnload.Caption = 'Abbrechen') and not terminate then
      begin
        //Chart1LineSeries1.AddXY(ValueTable[1][i], ValueTable[2][i]);
        Chart1BSplineSeries1.AddXY(ValueTable[1][i], ValueTable[2][i]);
        //Chart1CubicSplineSeries1.AddXY(ValueTable[1][i], ValueTable[2][i]);
        ValuetableForm.StringGrid1.Cells[i + 1, 0] := Floattostr(ValueTable[1][i]);
        ValuetableForm.StringGrid1.Cells[i + 1, 1] := Floattostr(ValueTable[2][i]);
        ValuetableForm.StringGrid1.Cells[i + 1, 2] := Floattostr(ValueTable[2][i]);
        Application.ProcessMessages;
      end;

    end;

    if not chartdrawing then
    begin
      Chart1.EnableRedrawing;
      Chart1.Repaint;
      chartdrawing:=true;
    end;

    if not (LoadUnload.Caption = 'Laden') then
    begin
      CalcPercentage.Caption := 'Abgeschlossen';
      LoadUnload.Caption := 'Laden';
    end;
  end;

end;



procedure TMainFrame.HelpClick(Sender: TObject);
begin

end;


end.
//Todo: Von Strommessung auf Spannungsmessung
//Help Site
//Kreise mit plus Minus als Spannungsquelle
//Slider anpassen.
//Kapazotätsslider von 0F bis 1F












