unit CadLocal;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, DBGrids, Buttons,
  BCPanel,LCLType, DBCtrls, ExtCtrls, DB;

type

  { TfrmCadLocal }

  TfrmCadLocal = class(TForm)
    BCPanel1: TBCPanel;
    DBGrid1: TDBGrid;
    sbtIncluir: TSpeedButton;
    sbtExcluir: TSpeedButton;
    procedure BCPanel1Exit(Sender: TObject);
    procedure DBGrid1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure sbtExcluirClick(Sender: TObject);
    procedure sbtIncluirClick(Sender: TObject);

  private
    procedure Grava_Area;
    function Existe_Descricao(Descricao: String): Boolean;
  public

  end;

var
  frmCadLocal: TfrmCadLocal;

implementation
uses dmdados;
{$R *.lfm}

{ TfrmCadLocal }

function TfrmCadLocal.Existe_Descricao(Descricao: String): Boolean;
begin
     with dmdados.DM.zqComandos, SQL do
     begin
          close;
          Clear;
          Add('select * from public.tb_Local');
          Add('where (Descricao = '''+UppCase(Descricao)+''')');  //and id <>'+Codigo);
          open;
          Result:= RecordCount>0
    end;
    ShowMessage(DESCRICAO);
end;


procedure TfrmCadLocal.FormShow(Sender: TObject);
begin
 with dmdados.DM.zqLocal,SQL do
  begin
    close;
    clear;
    Add('select * from public.tb_Local ');
    open
   end;
 dbgrid1.setfocus;
end;

procedure TfrmCadLocal.sbtExcluirClick(Sender: TObject);
begin
//     if not Acessa(Tag, (Sender as TSpeedButton).Tag) then Exit;
     if dmdados.DM.zqLocal.RecordCount = 0 then
     begin
          Application.MessageBox('Não existe Registro para Excluir !',
                                 'Êrro', mb_ok + mb_Iconerror);
          exit;
    end;

    if Application.MessageBox('Confirma Exclusão ? ', 'Exclusão',
                              MB_OKCANCEL +  MB_ICONQUESTION) = IDOK then
    begin
       dmdados.DM.zqLocal.delete;
    end;
//    StatusBar1.SimpleText:= ' Total de Registros Cadastrados..: '+IntToStr(Tabela.RecordCount);
    DBGrid1.SetFocus;
end;



procedure TfrmCadLocal.sbtIncluirClick(Sender: TObject);
begin
  dmdados.DM.zqLocal.Append;
  dbgrid1.setfocus;
end;


procedure TfrmCadLocal.BCPanel1Exit(Sender: TObject);
begin
  if dmdados.DM.zqLocal.Active then
     dmdados.DM.zqLocal.close;
end;

procedure TfrmCadLocal.DBGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
    case key of
        VK_F1     : sbtIncluir.Click;
 //      VK_RETURN : if TRIM(DBGrid1.Columns[0].Field.ToString) = '' then
        VK_RETURN : if (DBGrid1.DataSource.DataSet.State in [dsInsert, dsEdit]) and (DBGrid1.SelectedColumn.Field.FieldName = 'descricao') then
                       Grava_Area;
       VK_ESCAPE :  begin
                       Close;
                       exit;
                     end;

    end;
end;


procedure TfrmCadLocal.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  CloseAction := caFree;
  frmCadLocal := nil;

end;

 procedure TfrmCadLocal.Grava_Area;
 begin
  try
    dmdados.DM.zqLocal.ApplyUpdates;

    dmdados.DM.zqLocal.Append;
    DBGrid1.SetFocus;
  except
     on E:EDescricao do
     begin
      dmdados.DM.zqLocal.CancelUpdates;
      Self.Close;
     end;

{     on E:Exception do
     begin
      //=================================================================
      //Detectar descrição duplicada via Banco de Dados
      if Pos('unq_descricao', E.Message) > 0 then
      begin
        Application.MessageBox(PChar('Erro: Descrição já cadastrada!'), 'Atenção', MB_OK+MB_ICONINFORMATION);
        dmdados.DM.zqLocal.CancelUpdates;
        dmdados.DM.zqLocal.Append;
        DBGrid1.SetFocus;
      end
      else
      begin
        Application.MessageBox(PChar('Erro: ' + E.Message), 'Atenção', MB_OK+MB_ICONINFORMATION);
        dmdados.DM.zqLocal.CancelUpdates;
      end;

    end;       }
    on E:ERepetido do
    begin
      Application.MessageBox(PChar('Erro: ' + E.Message), 'Atenção', MB_OK+MB_ICONINFORMATION);
      dmdados.DM.zqLocal.CancelUpdates;
      dmdados.DM.zqLocal.Append;
      DBGrid1.SetFocus;
    end;

   end;
 end;
end.

