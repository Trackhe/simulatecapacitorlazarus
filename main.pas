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
  ComCtrls, TASources, TAChartCombos, TAGraph, TASeries, TAChartListbox, Math,
  Process, LazLogger, INIFiles, DateUtils;




type

  { TMainFrame }

  TMainFrame = class(TForm)
    CalcAccuracyInput1: TTrackBar;
    CalcAccuracyInputLabel1: TLabel;
    Chart1: TChart;
    Chart1LineSeries1: TLineSeries;
    ChartListbox1: TChartListbox;
    CheckBox1: TCheckBox;


    Circuit: TImage;
    CircuitTitle: TLabel;
    CircuitMessuredVoltage: TLabel;
    CircuitMessuredCurrent: TLabel;
    CircuitResistor: TLabel;
    CircuitVolt: TLabel;
    CalcAccuracyInputLabel: TLabel;

    CapacitorCapacity: TLabel;
    CreatedBy: TLabel;
    CalcPercentage: TLabel;
    Label4: TLabel;
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

{    function GetSystemThreadCount: integer;
    procedure CallLocalProc(AProc, Frame: Pointer; Param1: PtrInt;
    Param2, Param3: Pointer); inline;
}
    procedure BeendenClick(Sender: TObject);
    procedure CalcAccuracyInput1Change(Sender: TObject);
    procedure CalcAccuracyInputChange(Sender: TObject);
    procedure CapacityInputChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HelpClick(Sender: TObject);
    procedure InVoltageInputChange(Sender: TObject);
    procedure LoadClick(Sender: TObject);
    procedure LoadUnloadClick(Sender: TObject);
    procedure ResistorInputChange(Sender: TObject);
    procedure TabelleClick(Sender: TObject);
    procedure UnLoadClick(Sender: TObject);
  private
    ValueTable: array[1..2] of array of Double;
    procedure ShowStatus(Status1: String; Status2: String; Status3: String);
    procedure TCShowStatus(Result: Double);
    procedure TCShowStatus1(Result: Double; t: Double);
  public

  end;

var
  MainFrame: TMainFrame;
  calcres: Double;
  calcres1: Double;
  calcres2: Double;
  crsitc: Int64;
  crs: UInt64;
  ProcInfo: TProcess;
  SAVE: TINIFile;

implementation

uses simthread, valuetable_form;

{$R *.lfm}

var
   tsim: TSimmulation;


procedure TMainFrame.FormCreate(Sender: TObject);
var
 SAVE_TEST: String;
begin
 //SetProcessAffinityMask(ProcInfo.hProcess, 0);
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
 CalcAccuracyInputLabel1.caption:=floattostr(calcres1)+'s';



 // Start Circuit simulation.
 tsim:=TSimmulation.Create(true);
 tsim.OnShowStatus := @ShowStatus;
 tsim.PTSCapacity:=CapacityInput.position;//gg C
 tsim.PTSState_time:=DateTimeToUnix(Now);
 tsim.PTSResistor:=ResistorInput.position;
 tsim.PTSCapacity:=CapacityInput.position;
 tsim.PTSVoltage:=Round(InVoltageInput.position * 12);
 tsim.PTSRes:=CalcAccuracyInput.position;
 tsim.PTSRes0:=CalcAccuracyInput1.position;
 tsim.PTSState:=false;


 tsim.FreeOnTerminate:=true;
 tsim.Resume;

 SAVE:= TINIFile.Create('save.ini');
 SAVE.WriteString('HIHO', 'test', '234.2434');
end;

// Update Dynamic UI
procedure TMainFrame.ShowStatus(Status1: String; Status2: String; Status3: String);
begin
 CircuitMessuredVoltage.Caption := Status1;
 CapacitorCapacity.Caption := Status3;
 CircuitMessuredCurrent.Caption := Status2;
end;


// Update Static UI

procedure TMainFrame.InVoltageInputChange(Sender: TObject);
begin
 VoltageUnitLabel.caption:=Inttostr(InVoltageInput.position * 12) + 'V';
 CircuitVolt.caption:=Inttostr(InVoltageInput.position * 12) + 'V';
 if not (ResistorInput.position = 0) and not (CapacityInput.position = 0) and not (InVoltageInput.position = 0)
 then LoadUnload.Enabled:=true
 else LoadUnload.Enabled:=false;
 tsim.PTSVoltage:=Round(InVoltageInput.position * 12);
 tsim.PTSState_time:=DateTimeToUnix(Now);
   Chart1LineSeries1.clear;
   MainFrame.ChartListbox1.Clear;
   ValuetableForm.StringGrid1.Clear;
   Load.Visible:=true;
   UnLoad.Visible:=false;
   CircuitSwitch.Caption:='Laden';
   tsim.PTSState:=false;
   LoadUnload.Caption:= 'Entladen';
end;

procedure TMainFrame.CapacityInputChange(Sender: TObject);
begin
 CapacityUnitLabel.caption:=Inttostr(CapacityInput.position) + 'F';
 CapacitorCapacity.caption:=Inttostr(CapacityInput.position) + 'F';
 if not (ResistorInput.position = 0) and not (CapacityInput.position = 0) and not (InVoltageInput.position = 0)
 then LoadUnload.Enabled:=true
 else LoadUnload.Enabled:=false;
 tsim.PTSCapacity:=Round(CapacityInput.position);
 tsim.PTSState_time:=DateTimeToUnix(Now);
   Chart1LineSeries1.clear;
   MainFrame.ChartListbox1.Clear;
   ValuetableForm.StringGrid1.Clear;
   Load.Visible:=true;
   UnLoad.Visible:=false;
   CircuitSwitch.Caption:='Laden';
   tsim.PTSState:=false;
   LoadUnload.Caption:= 'Entladen';
end;

procedure TMainFrame.ResistorInputChange(Sender: TObject);
begin
 ResistorUnitLabel.caption:=Inttostr(ResistorInput.position) + 'Ohm';
 CircuitResistor.caption:=Inttostr(ResistorInput.position) + 'Ohm';
 if not (ResistorInput.position = 0) and not (CapacityInput.position = 0) and not (InVoltageInput.position = 0)
 then LoadUnload.Enabled:=true
 else LoadUnload.Enabled:=false;
 tsim.PTSResistor:=Round(ResistorInput.position);
 tsim.PTSState_time:=DateTimeToUnix(Now);
   Chart1LineSeries1.clear;
   MainFrame.ChartListbox1.Clear;
   ValuetableForm.StringGrid1.Clear;
   Load.Visible:=true;
   UnLoad.Visible:=false;
   CircuitSwitch.Caption:='Laden';
   tsim.PTSState:=false;
   LoadUnload.Caption:= 'Entladen';
end;

procedure TMainFrame.CalcAccuracyInputChange(Sender: TObject);
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

procedure TMainFrame.CalcAccuracyInput1Change(Sender: TObject);
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
 CalcAccuracyInputLabel1.caption:=floattostr(calcres1)+'s';
end;

procedure TMainFrame.TabelleClick(Sender: TObject);
begin
  ValuetableForm.Show;
end;













// Threading
{
{$IFDEF Linux}
const _SC_NPROCESSORS_ONLN = 83;
function sysconf(i: cint): clong; cdecl; external name 'sysconf';
{$ENDIF}

function GetSystemThreadCount: integer;
   // returns a good default for the number of threads on this system
   {$IF defined(windows)}
   //returns total number of processors available to system including logical hyperthreaded processors
   var
     i: Integer;
     ProcessAffinityMask, SystemAffinityMask: DWORD_PTR;
     Mask: DWORD;
     SystemInfo: SYSTEM_INFO;
   begin
     if GetProcessAffinityMask(GetCurrentProcess, ProcessAffinityMask, SystemAffinityMask)
     then begin
       Result := 0;
       for i := 0 to 31 do begin
         Mask := DWord(1) shl i;
         if (ProcessAffinityMask and Mask)<>0 then
           inc(Result);
       end;
     end else begin
       //can't get the affinity mask so we just report the total number of processors
       GetSystemInfo(SystemInfo);
       Result := SystemInfo.dwNumberOfProcessors;
     end;
   end;
   {$ELSEIF defined(UNTESTEDsolaris)}
     begin
       t = sysconf(_SC_NPROC_ONLN);
     end;
   {$ELSEIF defined(freebsd) or defined(darwin)}
   type
     PSysCtl = {$IF FPC_FULLVERSION>30300}pcint{$ELSE}pchar{$ENDIF};
   var
     mib: array[0..1] of cint;
     len: csize_t;
     t: cint;
   begin
     mib[0] := CTL_HW;
     mib[1] := HW_NCPU;
     len := sizeof(t);
     fpsysctl(PSysCtl(@mib), 2, @t, @len, Nil, 0);
     Result:=t;
   end;
   {$ELSEIF defined(linux)}
     begin
       Result:=sysconf(_SC_NPROCESSORS_ONLN);
     end;
   {$ELSE}
     begin
       Result:=1;
     end;
   {$ENDIF}

procedure CallLocalProc(AProc, Frame: Pointer; Param1: PtrInt;
     Param2, Param3: Pointer); inline;
   type
     PointerLocal = procedure(_EBP: Pointer; Param1: PtrInt;
                              Param2, Param3: Pointer);
  begin
    PointerLocal(AProc)(Frame, Param1, Param2, Param3);
   end;
}

//Max Time Calc.
//ln(RES/U_0)*R*C

var
   tcalc1: TCalculator;
   tcalc: TCalculator;

procedure TMainFrame.UnLoadClick(Sender: TObject);
begin
   if not (LoadUnload.Caption = 'Abbrechen') then
   begin
       Chart1LineSeries1.clear;
       MainFrame.ChartListbox1.Clear;
       ValuetableForm.StringGrid1.Clear;
       Load.Visible:=true;
       UnLoad.Visible:=false;
       CircuitSwitch.Caption:='Laden';
       tsim.PTSState:=false;
       LoadUnload.Caption:='Entladen';
   end;
end;

procedure TMainFrame.LoadClick(Sender: TObject);
begin
  if LoadUnload.Enabled then
  begin
    if not (ResistorInput.position = 0) and not (CapacityInput.position = 0) and not (InVoltageInput.position = 0) then
    begin
    Load.Visible:=false;
    UnLoad.Visible:=true;
    CircuitSwitch.Caption:='Entladen';
    tsim.PTSState:=true;
    //GetLogicalCpuCount();
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
    tcalc.Start;
    LoadUnload.Caption:='Abbrechen';
    end;
  end;
end;


//Step One, calculate the max calculation count.
procedure TMainFrame.LoadUnloadClick(Sender: TObject);
var
 tcalc: TCalculator;
begin
 if (LoadUnload.Caption = 'Entladen') then
 begin
   if not (ResistorInput.position = 0) and not (CapacityInput.position = 0) and not (InVoltageInput.position = 0) then
   begin
   Load.Visible:=false;
   UnLoad.Visible:=true;
   CircuitSwitch.Caption:='Entladen';
   tsim.PTSState:=true;
   //GetLogicalCpuCount();
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
   tcalc.Start;
   LoadUnload.Caption:='Abbrechen';
   end;
 end
 else if (LoadUnload.Caption = 'Laden') then
 begin
   Chart1LineSeries1.clear;
   MainFrame.ChartListbox1.Clear;
   ValuetableForm.StringGrid1.Clear;
   Load.Visible:=true;
   UnLoad.Visible:=false;
   CircuitSwitch.Caption:='Laden';
   tsim.PTSState:=false;
   LoadUnload.Caption:= 'Entladen';
 end
 else if (LoadUnload.Caption = 'Abbrechen') then
 begin
   tcalc1.Terminate;
   LoadUnload.Caption:= 'Laden';
 end;
end;


procedure TMainFrame.BeendenClick(Sender: TObject);
begin
   if (LoadUnload.Caption = 'Abbrechen') then
   begin
     tcalc1.Terminate;
   end;
  Application.Terminate;
end;






//Step two, split the calculations in to threads.
procedure TMainFrame.TCShowStatus(Result: Double);
var
 ci : UInt64;
 crstcountpart: UInt64;
 crstcountpartrest: UInt64;
 ProcAFMask,
 SysAFMask  : QWord;
 CPUcores: set of 0..31;
 cpucount: Int64;
begin
 cpucount := 1;
 { Get the current values }
 //GetProcessAffinityMask( GetCurrentProcess, ProcAFMask, SysAFMask);
 { Manipulate }
 //SysAFMAsk := $00000001; // Set this process to run on CPU 1 only
 { Set the Process Affinity Mask }
 //SetProcessAffinityMask( GetCurrentProcess, SysAFMAsk);

 CPUcores:=[]; //0 .. 63

 //ceil(Result) = sekunden bis genauigkeit 0 erreicht ist.
 //CreatedBy.Caption:=floattostr(Result * calcres2);
 crs:=ceil(Result*calcres2);//anzahl der endgültigen berechnungen

 //Showmessage(inttostr(crs));
 SetLength(ValueTable[1],crs);
 SetLength(ValueTable[2],crs);

 //zero_load_time:=Result;//Zeit
 crsitc:=0;
 crstcountpart:= crs div cpucount;
 crstcountpartrest:= crs mod cpucount;

 ShowMessage(Floattostr((crstcountpart * cpucount) + crstcountpartrest));

 Chart1.Extent.YMax:=InVoltageInput.position * 12;
 Chart1.Extent.XMax:=Result;

 for ci:=1 to cpucount do //CPU Core Count
 begin
   CPUcores:=CPUcores+[ci];
   tcalc1:=TCalculator.Create(true);
   tcalc1.AffinityMask:=dword(CPUcores);
   tcalc1.TCOnShowStatus1 := @TCShowStatus1;
   tcalc1.FreeOnTerminate:=true;
   tcalc1.PTResistor:=ResistorInput.position;//gg R
   tcalc1.PTCapacity:=CapacityInput.position;//gg C
   tcalc1.PTVoltage:=InVoltageInput.position * 12;//gg  U_0
   tcalc1.PTRes:=ci;
   tcalc1.PTRes0:=calcres1;
   tcalc1.PTRes1:=calcres;
   tcalc1.PTMode:=1;
   tcalc1.PTCountPart:=crstcountpart;
   tcalc1.PTRestCountPart:=crstcountpartrest;
   tcalc1.Start;
 end;
end;











//Step three, take the results.
procedure TMainFrame.TCShowStatus1(Result: Double; t: Double);
var
 i:UInt64;
begin
   crsitc:=crsitc + 1;
   ValueTable[1][ceil(t)]:=t * calcres1;//Zeitpunkt
   ValueTable[2][ceil(t)]:=Result;//Ladungswert
  CalcPercentage.Caption:=floattostrf(crsitc / (crs / 100), fffixed, 4, 0) + '%';
  Application.ProcessMessages;


   if crsitc = crs then
   begin
     ValuetableForm.StringGrid1.ColCount:=crsitc;
     ValuetableForm.StringGrid1.RowCount:=3;
     ValuetableForm.StringGrid1.Cells[0, 0]:='T in s';
     ValuetableForm.StringGrid1.Cells[0, 1]:='V in v';
     ValuetableForm.StringGrid1.Cells[0, 2]:='C in F';
     if CheckBox1.Checked
     then Chart1.DisableRedrawing;
     for i:= 0 to High(ValueTable[1]) - 1 do
     begin
      if not (LoadUnload.Caption = 'Laden') then
      begin
        Chart1LineSeries1.AddXY(ValueTable[1][i],ValueTable[2][i]);
        ValuetableForm.StringGrid1.Cells[i + 1, 0]:=Floattostr(ValueTable[1][i]);
        ValuetableForm.StringGrid1.Cells[i + 1, 1]:=Floattostr(ValueTable[2][i]);
        ValuetableForm.StringGrid1.Cells[i + 1, 2]:=Floattostr(ValueTable[2][i]);
        Application.ProcessMessages;
      end;
     end;
     if CheckBox1.Checked
     then Chart1.EnableRedrawing;
     Chart1.Repaint;
     if not (LoadUnload.Caption = 'Laden') then
     begin
      CalcPercentage.Caption:='';
      LoadUnload.Caption:='Laden';
     end;
   end;
end;



procedure TMainFrame.HelpClick(Sender: TObject);
begin

end;


end.


//Todo: beenden button muss entladungsaufzeichnung beenden und schließen.
//Todo: Alle Ergebnisse aufeinmal Zeichnen.











