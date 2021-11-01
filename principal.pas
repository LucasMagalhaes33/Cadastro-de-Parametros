unit Principal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, Menus,
  DBGrids, TDIClass, BCPanel;

type

  { TfrmPrincipal }

  TfrmPrincipal = class(TForm)
    BCPanel1: TBCPanel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    Lucas: TMenuItem;
    TabSheet1: TTabSheet;
    TDINoteBook1: TTDINoteBook;
    procedure LucasClick(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure TDINoteBook1Change(Sender: TObject);
  private

  public

  end;

var
  frmPrincipal: TfrmPrincipal;

implementation
uses CadLocal, ucadParam;
{$R *.lfm}

{ TfrmPrincipal }

procedure TfrmPrincipal.TDINoteBook1Change(Sender: TObject);
begin

end;

procedure TfrmPrincipal.MenuItem2Click(Sender: TObject);
begin
    if not Assigned(frmCadLocal) then
     frmCadLocal := TfrmCadLocal.Create(Application);

  TDINoteBook1.ShowFormInPage(frmCadLocal, 0);
end;

procedure TfrmPrincipal.LucasClick(Sender: TObject);
begin
     if not Assigned(frmCadParam) then
     frmCadParam := TfrmCadParam.Create(Application);

  TDINoteBook1.ShowFormInPage(frmCadParam, 0);
end;

end.

