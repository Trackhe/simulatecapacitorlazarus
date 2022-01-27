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
  ComCtrls, Menus, TASources, TAChartCombos, TAGraph, TASeries, TAChartListbox,
  TAFuncSeries, Math, Process, LazLogger, INIFiles, DateUtils;

type

  { TMainFrame }

  TMainFrame = class(TForm)

    //All Definitions for the Form
    CalcAccuracyInput1: TTrackBar;
    CalcAccuracyInputLabel1: TLabel;
    Label1: TLabel;
    ResistorInputE: TComboBox;
    InVoltageInputE: TComboBox;
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
    CircuitMessuredCurrent0: TLabel;
    CircuitResistor: TLabel;
    CircuitVolt: TLabel;
    CalcAccuracyInputLabel: TLabel;
    CapacityInputE: TComboBox;

    CreatedBy: TLabel;
    CalcPercentage: TLabel;
    CircuitSwitch: TLabel;
    CalcAccuracyLabel: TLabel;
    Beenden: TButton;
    CapacityInput: TEdit;
    ResistorInput: TEdit;
    InVoltageInput: TEdit;
    ResistorLabel: TLabel;
    Load: TImage;
    CalcAccuracyInput: TTrackBar;
    UnLoad: TImage;

    Tabelle: TButton;
    LoadUnload: TButton;
    Help: TButton;

    AppHeadline: TLabel;
    AppSubHeadline: TLabel;
    InVoltageLabel: TLabel;
    CapacityLabel: TLabel;

    //All functions that called from the Form

    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure InVoltageInputChange(Sender: TObject);
    procedure CapacityInputChange(Sender: TObject);
    procedure CapacityInputEChange(Sender: TObject);
    procedure InVoltageInputEChange(Sender: TObject);
    procedure ResistorInputChange(Sender: TObject);
    procedure CalcAccuracyInputChange(Sender: TObject);
    procedure CalcAccuracyInput1Change(Sender: TObject);
    procedure ResistorInputEChange(Sender: TObject);



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
    procedure InputChangeOperation(What: Int32; E: Int32);
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
  CUnitMultiplicator,VUnitMultiplicator,RUnitMultiplicator: Real;
  InputCapacity,InputVoltage,InputResistor:Real;

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
var i,ia:int32;
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

  InVoltageInput.caption := Floattostr(SAVE.ReadFloat('SimulationSettings', 'InputVoltage', 0.0));
  SAVE.WriteFloat('SimulationSettings', 'InputVoltage', Strtofloat(InVoltageInput.text));
  InVoltageInputE.ItemIndex := SAVE.ReadInteger('SimulationSettings', 'InputVoltageUnit', 0);
  SAVE.WriteInteger('SimulationSettings', 'InputVoltageUnit', InVoltageInputE.ItemIndex);

  CapacityInput.caption := Floattostr(SAVE.ReadFloat('SimulationSettings', 'CapacitorCapacity', 0.0));
  SAVE.WriteFloat('SimulationSettings', 'CapacitorCapacity', Strtofloat(CapacityInput.text));
  CapacityInputE.ItemIndex := SAVE.ReadInteger('SimulationSettings', 'CapacitorCapacityUnit', -1);
  SAVE.WriteInteger('SimulationSettings', 'CapacitorCapacityUnit', CapacityInputE.ItemIndex);

  ResistorInput.caption := Floattostr(SAVE.ReadFloat('SimulationSettings', 'DischargeResistor', 0.0));
  SAVE.WriteFloat('SimulationSettings', 'DischargeResistor', Strtofloat(ResistorInput.text));
  ResistorInputE.ItemIndex := SAVE.ReadInteger('SimulationSettings', 'DischargeResistorUnit', 0);
  SAVE.WriteInteger('SimulationSettings', 'DischargeResistorUnit', ResistorInputE.ItemIndex);

  if Debug then
  begin
    debugln('SimulationSettings:InputVoltage = ' + InVoltageInput.text);
    debugln('SimulationSettings:InputVoltageUnit = ' + Inttostr(InVoltageInputE.ItemIndex));
    debugln('SimulationSettings:CapacitorCapacity = ' + CapacityInput.text);
    debugln('SimulationSettings:CapacitorCapacityUnit = ' + Inttostr(CapacityInputE.ItemIndex));
    debugln('SimulationSettings:DischargeResistor = ' + ResistorInput.text);
    debugln('SimulationSettings:DischargeResistorUnit = ' + Inttostr(ResistorInputE.ItemIndex));
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
    debugln('DrawSettings:DrawnYPrecison = ' + Inttostr(CalcAccuracyInput.position));
    debugln('DrawSettings:DrawnXPrecison = ' + Inttostr(CalcAccuracyInput1.position));
    debugln('DrawSettings:FastDraw = ' + Booltostr(CheckBox1.Checked));
  end;

  //Be sure all variables are Updated
  for i:= 0 to 2 do begin
    for ia:= 0 to 1 do begin
        InputChangeOperation(i, ia);
    end;
  end;

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
  tsim.PTSState_time := DateTimeToUnix(Now);
  tsim.PTSResistor := InputResistor * RUnitMultiplicator;
  tsim.PTSCapacity := InputCapacity * CUnitMultiplicator;
  tsim.PTSVoltage := InputVoltage * VUnitMultiplicator;
  tsim.PTSRes := CalcAccuracyInput.position;
  tsim.PTSRes0 := CalcAccuracyInput1.position;
  tsim.PTSState := False;
  tsim.FreeOnTerminate := True;
  tsim.Start;

end;

//Update Dynamic UI
procedure TMainFrame.ShowStatus(Status1: string; Status2: string; Status3: string; Status4: string);
begin
  CircuitMessuredVoltage.Caption := Status1;
  //CapacitorCapacity.Caption := Status3;
  //Label4.Caption:=Status4;
  CircuitMessuredCurrent0.Caption := Status2;
end;


//Update Static UI
procedure TMainFrame.InVoltageInputChange(Sender: TObject);
begin
  //InVoltageInputChangeOperation; //#0
  InputChangeOperation(0, 0);
end;

procedure TMainFrame.InVoltageInputEChange(Sender: TObject);
begin
  InputChangeOperation(0, 1);
end;

procedure TMainFrame.CapacityInputChange(Sender: TObject);
begin
  //CapacityInputChangeOperation; //#1
  InputChangeOperation(1, 0);
end;

procedure TMainFrame.CapacityInputEChange(Sender: TObject);
begin
  InputChangeOperation(1, 1);
end;

procedure TMainFrame.ResistorInputChange(Sender: TObject);
begin
  //ResistorInputChangeOperation; //#2
  InputChangeOperation(2, 0);
end;

procedure TMainFrame.ResistorInputEChange(Sender: TObject);
begin
  InputChangeOperation(2, 1);
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

//Update methods //#0 Voltage //#1 Capacity Input //#2 CapacityUnit //#3 Resistor
procedure TMainFrame.InputChangeOperation(What: Int32; E: Int32);
var
  valbool:Boolean=false;
  error_input:Int32;
begin
  if Debug then debugln(Inttostr(What) + ':' + Inttostr(E));
  case What of
  0:
  begin
    if not (E = 1) then
      begin
      Val(InVoltageInput.text, InputVoltage,error_input);
      if error_input<>0 then
      begin
         if Debug then debugln('Eingabefehler an der Stelle:' + Inttostr(error_input));
         //ShowMessage('Eingabefehler an der Stelle:' + Inttostr(error_input));
      end
      else
      begin
        SAVE.WriteFloat('SimulationSettings', 'InputVoltage', InputVoltage);
        CircuitVolt.Caption := InVoltageInput.text + 'V';
        //if not InputVoltage = Strtofloat(InVoltageInput.text) then
        //begin
        //  debugln('Val to Voltage macht nicht seinen Job');
        //  InputVoltage:=Strtofloat(InVoltageInput.text);
        //end;

        valbool:=true;
      end;
      end
      else
      begin
        if Debug then debugln('Update Volt Unit');
        SAVE.WriteInteger('SimulationSettings', 'InputVoltageUnit', InVoltageInputE.ItemIndex);
        if (InVoltageInputE.ItemIndex <> -1) then
           InVoltageInput.Enabled:= true
        else
           InVoltageInput.Enabled:= false;

        case InVoltageInputE.ItemIndex of
        0:
          VUnitMultiplicator := 1.0;
        else
          VUnitMultiplicator := 1.0;
        end;

        valbool:=true;
      end;
  end;
  1:
  begin

    debugln(Inttostr(E));

    if not (E = 1) then
    begin
      Val(CapacityInput.text, InputCapacity,error_input);
      if (error_input<>0) then
      begin
         if Debug then debugln('Eingabefehler an der Stelle:' + Inttostr(error_input));
      end
      else
      begin
      if Debug then debugln('Update Capacity');
      SAVE.WriteFloat('SimulationSettings', 'CapacitorCapacity', InputCapacity);
      valbool:=true;
      end;
    end
    else
    begin
      if Debug then debugln('Update Capacity Unit');
      SAVE.WriteInteger('SimulationSettings', 'CapacitorCapacityUnit', CapacityInputE.ItemIndex);
      if (CapacityInputE.ItemIndex <> -1) then
         CapacityInput.Enabled:= true
      else
         CapacityInput.Enabled:= false;

      case CapacityInputE.ItemIndex of
      0:
        CUnitMultiplicator := 1.0;
      1:
        CUnitMultiplicator := 0.001;
      2:
        CUnitMultiplicator := 0.000001;
      3:
        CUnitMultiplicator := 0.000000001;
      4:
        CUnitMultiplicator := 0.000000000001;
      else
        CUnitMultiplicator := 1.0;
      end;

      valbool:=true;
    end;
  end;
  2:
  begin
    if not (E = 1) then
    begin
      Val(ResistorInput.text, InputResistor,error_input);
      if error_input<>0 then
      begin
         if Debug then debugln('Eingabefehler an der Stelle:' + Inttostr(error_input));
      end
      else
      begin
        if Debug then debugln('Update Resistor Size');
        SAVE.WriteFloat('SimulationSettings', 'DischargeResistor', InputResistor);
        CircuitResistor.Caption := ResistorInput.text + 'Ohm';
        valbool:=true;
      end;
    end
    else
    begin
      if Debug then debugln('Update Resistor Unit');
      SAVE.WriteInteger('SimulationSettings', 'DischargeResistorUnit', ResistorInputE.ItemIndex);
      if (ResistorInputE.ItemIndex <> -1) then
         ResistorInput.Enabled:= true
      else
         ResistorInput.Enabled:= false;

      case ResistorInputE.ItemIndex of
      0:
        RUnitMultiplicator := 1.0;
      else
        RUnitMultiplicator := 1.0;
      end;

      valbool:=true;
    end;
  end
  else
    debugln('Input Change Operation without ID. not Possible.');
  end;

  if valbool then
  begin
    if Debug then debugln('R:' + Floattostr(RUnitMultiplicator) + ': C:' + Floattostr(CUnitMultiplicator) + ': V:' + Floattostr(VUnitMultiplicator));
    if Debug then debugln('R:' + Floattostr(InputResistor) + ': C:' + Floattostr(InputCapacity) + ': V:' + Floattostr(InputVoltage));
    if Debug then debugln('R:' + Floattostr(InputResistor * RUnitMultiplicator) + ': C:' + Floattostr(InputCapacity * CUnitMultiplicator) + ': V:' + Floattostr(InputVoltage * VUnitMultiplicator));
    if not (InputResistor = 0) and not (InputCapacity <= 0) and
      not (InputVoltage = 0) and not (CapacityInputE.ItemIndex = -1) and
      not (InVoltageInputE.ItemIndex = -1) and not (ResistorInputE.ItemIndex = -1) then
      LoadUnload.Enabled := True
    else
      LoadUnload.Enabled := False;
  end
  else
  begin
    LoadUnload.Enabled := False;
  end;

  if (LoadUnload.Caption = 'Abbrechen') then
  begin
   CancelProzess;
  end;

  if valbool then
  begin
    tsim.PTSVoltage := InputVoltage * VUnitMultiplicator;
    tsim.PTSState_time := DateTimeToUnix(Now);
    tsim.PTSCapacity := InputCapacity * CUnitMultiplicator;
    tsim.PTSResistor := InputResistor * RUnitMultiplicator;
  end;

  Load.Visible := True;
  UnLoad.Visible := False;
  CircuitSwitch.Caption := 'Laden';
  tsim.PTSState := False;
  LoadUnload.Caption := 'Entladen';


  Label1.Caption:='';
  //Chart1LineSeries1.Clear;
  Chart1BSplineSeries1.Clear;
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
      if not (InputResistor * RUnitMultiplicator <= 0) and not (InputCapacity * CUnitMultiplicator <= 0) and not (InputVoltage * VUnitMultiplicator <= 0) then
      begin
        Load.Visible := False;
        UnLoad.Visible := True;
        CircuitSwitch.Caption := 'Entladen';
        LoadUnload.Caption := 'Abbrechen';
        if Debug then debugln('---------------------------');
        if Debug then debugln('Calc the max Unload Time.');

        tsim.PTSState := True;
        tsim.PTSState_time := DateTimeToUnix(Now);
        //GetLogicalCpuCount();
        tcalc := TCalculator.Create(True);
        tcalc.TCOnShowStatus := @TCShowStatus;
        tcalc.FreeOnTerminate := True;
        //Max Time Calc.
        //ln(RES/U_0)*R*C
        tcalc.PTResistor := InputResistor * RUnitMultiplicator;
        tcalc.PTCapacity := InputCapacity * CUnitMultiplicator;
        tcalc.PTVoltage := InputVoltage * VUnitMultiplicator;
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
  Label1.Caption:='Max Unload Time: ' + Floattostr(Result) + 's';

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

  Chart1.Extent.YMax := InputVoltage;
  Chart1.Extent.XMax := Result;

  for ci := 1 to cpucount do //CPU Core Count
  begin
    CPUcores := CPUcores + [ci];
    tcalc1 := TCalculator.Create(True);
    tcalc1.AffinityMask := dword(CPUcores);
    tcalc1.TCOnShowStatus1 := @TCShowStatus1;
    tcalc1.FreeOnTerminate := True;
    tcalc1.PTResistor := InputResistor * RUnitMultiplicator;
    tcalc1.PTCapacity := InputCapacity * CUnitMultiplicator;
    tcalc1.PTVoltage := InputVoltage * VUnitMultiplicator;
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
  ib: UInt64;
  chartdrawing:Boolean=true;
begin
  if Debug then debugln('Result: ' + Floattostr(Result));
  if Debug then debugln('t: ' + Floattostr(t));

  crsitc := crsitc + 1;//Count function calls

  ValueTable[1][ceil(t)] := t * calcres1;//Timestamp
  ValueTable[2][ceil(t)] := Result;//Currentvalue

  CalcPercentage.Caption := floattostrf(crsitc / ((crs + 1) / 100), fffixed, 4, 0) + '% ' + Inttostr(crsitc) + ':' + Inttostr(crs + 1);
  Application.ProcessMessages;

  ib:=0;
  if crsitc = crs + 1 then
  begin
    ValuetableForm.StringGrid1.ColCount := crsitc + 1;
    ValuetableForm.StringGrid1.RowCount := 2;
    ValuetableForm.StringGrid1.Cells[0, 0] := 'T in s';
    ValuetableForm.StringGrid1.Cells[0, 1] := 'V in v';
    //ValuetableForm.StringGrid1.Cells[0, 2] := 'C in F';

    if Debug then debugln('Fastdraw: ' + Booltostr(CheckBox1.Checked));

    for i := 0 to High(ValueTable[1]) do
    begin
      if not (ValueTable[2][(i - 1)] = ValueTable[2][i]) then
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
          ValuetableForm.StringGrid1.Cells[ib + 1, 0] := Floattostr(ValueTable[1][i]);
          ValuetableForm.StringGrid1.Cells[ib + 1, 1] := Floattostr(ValueTable[2][i]);
          //ValuetableForm.StringGrid1.Cells[i + 1, 2] := Floattostr(ValueTable[2][i]);
          ib:=ib + 1;
          Application.ProcessMessages;
        end;
      end;
    end;
    ValuetableForm.StringGrid1.ColCount:= ib + 1;

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
//Help Site
//Test Config und Lösche Config wenn Wrong













