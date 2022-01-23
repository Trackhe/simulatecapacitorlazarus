program simulator;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, tachartlazaruspkg, help_form, valuetable_form, main, simthread
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TMainFrame, MainFrame);
  Application.CreateForm(THelpForm, HelpForm);
  Application.CreateForm(TValuetableForm, ValuetableForm);
  Application.Run;
end.

