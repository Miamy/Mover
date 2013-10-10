unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TformMain = class(TForm)
    imageScreen1: TImage;
    imageScreen2: TImage;
    listBoxPrograms: TListBox;
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
    procedure FillProgramsList;
    procedure FillMonitorsList;
  public
    { Public declarations }
  end;

var
  formMain: TformMain;

implementation

{$R *.dfm}

procedure TformMain.FillMonitorsList;
begin

end;

procedure TformMain.FillProgramsList;
begin

end;

procedure TformMain.FormActivate(Sender: TObject);
begin
  //
end;

end.
