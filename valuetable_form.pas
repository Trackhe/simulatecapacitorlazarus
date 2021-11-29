unit valuetable_form;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids,
  ExtCtrls, TASources, TAChartListbox;

type

  { TForm3 }

  TForm3 = class(TForm)
    StringGrid1: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private

  public

  end;

var
  Form3: TForm3;

implementation

uses main;


{$R *.lfm}

{ TForm3 }

procedure TForm3.FormCreate(Sender: TObject);
begin

end;

procedure TForm3.Label1Click(Sender: TObject);
begin

end;

end.

