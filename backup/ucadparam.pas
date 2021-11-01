unit ucadParam;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BufDataset, DB, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons, ZDataset, ZConnection, DBCtrls, ExtCtrls,
  DBGrids, ZSqlUpdate, ComCtrls, LCLType, BCPanel, ColorSpeedButton, Messages;

type

  { TfrmCadParam }

  TfrmCadParam = class(TForm)
    sbtInlcuir: TColorSpeedButton;
    sbtAlterar: TColorSpeedButton;
    sbtExcluir: TColorSpeedButton;
    sbtSair: TColorSpeedButton;
    DBGrid1: TDBGrid;
    imgBackgound: TImage;
    pPrincipal: TBCPanel;
    StatusBar1: TStatusBar;
    procedure sbtAlterarClick(Sender: TObject);
    procedure sbtExcluirClick(Sender: TObject);
    procedure sbtInlcuirClick(Sender: TObject);
    procedure DBGrid1ColEnter(Sender: TObject);
    procedure DBGrid1Enter(Sender: TObject);
    procedure DBGrid1Exit(Sender: TObject);
    procedure DBGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure sbtSairClick(Sender: TObject);
  private
    { Private declarations }
    WTDESC   : smallint;
    procedure PreencheQuery;
    procedure ClassificaDescricao;
    procedure Grava_Local;
    function Existe_id(id: String): Boolean;
    function Existe_Descricao(id, Descricao: String): Boolean;
  public
    procedure ShowModal(DataSource: TDataSource; TabInterna: String); reintroduce;
//    constructor Create(AOwner: TComponent; TipoDesc:integer);
  end;

var
  frmCadParam: TfrmCadParam;
  Tabela: ^TZQuery;
  DSource: TDataSource;
  TabelaINT: String;

  flagC : SmallInt;
  codPrw : SmallInt;
  descPrw : string;

implementation
  uses DMDados;
{$R *.lfm}

{ TfrmCadParam }
procedure TfrmCadParam.ShowModal(DataSource: TDataSource; TabInterna: String);
begin
  Tabela    :=  @DataSource.DataSet;
  DSource   :=  DataSource;
  TabelaINT :=  TabInterna;
  DBGrid1.DataSource := DSource;

  inherited  ShowModal;
end;
procedure TfrmCadParam.FormKeyPress(Sender: TObject; var Key: char);
begin
  {
  if (key = #13) and not (ActiveControl is TMemo) then
     begin
          Key := #0;
          Perform(WM_NEXTDLGCTL,0,0);
     end;
     }
end;

procedure TfrmCadParam.FormShow(Sender: TObject);
begin
  if not (DM.zConexao.Connected) then
    DM.zConexao.Connected := true;

  statusbar1.font.style:=[fsBold, fsItalic];
  statusbar1.Font.Name := 'Arial Narrow';
  statusbar1.Font.Size := 10;

  ClassificaDescricao;
  PreencheQuery;
  DBGrid1.DataSource := DM.dtsLocal;
  DBGrid1.SetFocus;
end;

procedure TfrmCadParam.sbtSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCadParam.DBGrid1Enter(Sender: TObject);
begin
  KeyPreview := false;
  DBGrid1.SelectedIndex := 0;
end;

procedure TfrmCadParam.DBGrid1ColEnter(Sender: TObject);
begin
  if (DBGrid1.SelectedIndex = 0) and (DBGrid1.DataSource.DataSet.Fields[0].IsNull) then
     begin
          self.close;
          exit;
     end;

  if DM.zqLocal.state = dsbrowse then DM.zqLocal.Edit;

{if (DBGrid1.SelectedIndex = 0) and (DM.zqLocal.state = dsInsert) then
    begin
          if Existe_Descricao(DBGrid1.DataSource.DataSet.Fields[0].AsString) then
          begin
               showmessage('Descrição já Cadastrada');
               DM.zqLocal.Cancel;
               DM.zqLocal.append;
               DBGrid1.SelectedIndex := 0;
          end;
     end;}
end;
procedure TfrmCadParam.sbtAlterarClick(Sender: TObject);
begin
  //  if not Acessa(Tag, (Sender as TSpeedButton).Tag) then Exit;
  DM.zqLocal.Edit;
  DBGrid1.SelectedIndex := 0;
end;

procedure TfrmCadParam.sbtExcluirClick(Sender: TObject);
begin
  if DM.zqLocal.RecordCount = 0 then
    begin
      Application.MessageBox('Não Existe Registro para Excluir!', 'Erro', MB_OK + MB_ICONERROR);
      exit;
    end;
  if Application.MessageBox('Confirma Exclusão?', 'Exclusão', MB_OKCANCEL + MB_ICONQUESTION) = IDOK then
    begin
     DM.zqLocal.Delete;
     DM.zqLocal.ApplyUpdates;
    end;

  StatusBar1.SimpleText:= ' Total de Registros Cadastrados..: '+IntToStr(DM.zqLocal.RecordCount);
  DBGrid1.SetFocus;
end;

procedure TfrmCadParam.sbtInlcuirClick(Sender: TObject);
begin
  DM.zqLocal.Append;
  DBGrid1.SetFocus;
  DBGrid1.SelectedIndex:= 0;
end;
procedure TfrmCadParam.DBGrid1Exit(Sender: TObject);
begin
  KeyPreview  := True;
end;

procedure TfrmCadParam.DBGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
    VK_F1     : sbtInlcuir.Click;
    VK_F2     : sbtAlterar.Click;
    VK_F3     : sbtExcluir.Click;
    VK_ESCAPE : sbtSair.Click;
//    VK_DOWN   : if Tabela. in [dsinsert, dsEdit] then Key:= VK_RETURN;
   VK_DOWN   : if DM.zqLocal.State in [dsInsert, dsEdit] then Key:= VK_RETURN;
   VK_RETURN : begin Application.ProcessMessages;
                         case DBGrid1.SelectedIndex of
                             0: DBGrid1.SelectedIndex := 0;
                             1 :begin
                                     if DBGrid1.DataSource.DataSet.Fields[0].IsNull then
                                     begin
                                          DBGrid1.SelectedIndex := 0;
                                          exit;
                                     end;
                                     if not DBGrid1.DataSource.DataSet.Fields[0].IsNull
                                     then
                                         begin
                                              Grava_Local;
                                              dm.zqLocal.Append;
                                              DBGrid1.SelectedIndex := 0;
                                              StatusBar1.SimpleText:= ' Total de Registros Cadastrados..: '+IntToStr(DM.zqLocal.RecordCount);
                                         end
                                     else
                                     DBgrid1.SelectedIndex := 0;
                                end;
                          end;
                    end;
        VK_INSERT : key := 0;
        VK_TAB    : key := 0;
        VK_END    : key := 0;
        VK_UP     : if (DBGrid1.DataSource.DataSet.Fields[0].IsNull) or (DM.zqLocal.State in [dsInsert, dsEdit]) then DM.zqLocal.Cancel;
     end;
end;
procedure TfrmCadParam.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  if DM.zqLocal.Active then
    DM.zqLocal.Close;
end;
procedure TfrmCadParam.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     case key of
          vk_escape : sbtSair.click;
     end;
end;

procedure TfrmCadParam.PreencheQuery;
begin
  try
    DM.zqLocal.Close;
    DM.zqLocal.SQL.Clear;
    DM.zqLocal.SQL.Add('select * from public.tb_local order by descricao');
    DM.zqLocal.Open;
    DM.zqLocal.FetchAll;

  finally
    StatusBar1.SimpleText:= ' Total de Registros Cadastrados..: '+IntToStr(DM.zqLocal.RecordCount);
  end;

end;
function TfrmCadParam.Existe_Descricao(id, Descricao: String): Boolean;
begin

  DM.zqLocal.Close;
  DM.zqLocal.SQL.Clear;
  DM.zqLocal.SQL.Add('select * from public.tb_local');
  DM.zqLocal.SQL.Add('where (descricao = '''+ UpperCase(Descricao)+''') and id <> '+id);
  DM.zqLocal.Open;

  Result := DM.zqLocal.RecordCount > 0;

end;
procedure TfrmCadParam.Grava_Local;
begin
  try
    DM.zqLocal.ApplyUpdates;
  except on E:Exception do
    begin
      DM.zqLocal.CancelUpdates;
      Application.MessageBox(PChar('Erro na Gravação' + sLineBreak + 'Erro: ' + E.Message),'Atenção',MB_ICONERROR+MB_OK);
    end;
  end;
end;
function TfrmCadParam.Existe_id(id: String): Boolean;
begin
    DM.zqLocal.Close;
    DM.zqLocal.SQL.Clear;
    DM.zqLocal.SQL.Add('select * from public.tb_local');
    DM.zqLocal.SQL.Add('where id = '+id);
    DM.zqLocal.Open;

    Result := DM.zqLocal.RecordCount > 0;
end;

procedure TfrmCadParam.ClassificaDescricao;
begin
  try
    DM.zqLocal.Close;
    DM.zqLocal.SQL.Clear;
    DM.zqLocal.SQL.Add('select * from public.tb_local order by id');
    DM.zqLocal.Open;

  finally
    StatusBar1.SimpleText:= ' Total de Registros Cadastrados..: '+IntToStr(dm.zqLocal.RecordCount);

  end;

end;

end.

