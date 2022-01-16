unit valuetable_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  ExtCtrls, TASources, TAChartListbox;

type

  { TValuetableForm }

  TValuetableForm = class(TForm)
    StringGrid1: TStringGrid;

    procedure FormCreate(Sender: TObject);
    procedure Label1Click(Sender: TObject);

  private
  public

  end;

var
  ValuetableForm: TValuetableForm;

implementation

uses main;


{$R *.lfm}

{ TValuetableForm }

procedure TValuetableForm.FormCreate(Sender: TObject);
begin
     MainFrame.TableIsLoaded:=true;

end;

procedure TValuetableForm.Label1Click(Sender: TObject);
begin

end;

end.

