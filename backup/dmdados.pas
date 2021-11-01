unit DMDados;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, DB, ZConnection, ZDataset, ZDbcIntfs, Dialogs;

type

  EDescricao = Class( Exception );

  ERepetido = Class(Exception);

  { TDM }

  TDM = class(TDataModule)
    dtsLocal: TDataSource;
    ZConexao: TZConnection;
    zqLocal: TZQuery;
    zqComandos: TZQuery;
    zqLocaldescricao: TStringField;
    zqLocalid: TLongintField;
    procedure ZConexaoAfterConnect(Sender: TObject);
    procedure ZConexaoBeforeConnect(Sender: TObject);
    procedure zqLocalBeforePost(DataSet: TDataSet);
//    procedure zqLocaldescricaoSetText(Sender: TField; const aText: string);
  private

  public

  end;

  function  UPPCASE(Tx: String): String;

var
  DM: TDM;

implementation

{$R *.lfm}

{ TDM }

procedure TDM.ZConexaoBeforeConnect(Sender: TObject);
begin
{  zconexao.Database:='Equipamentos';
  zconexao.HostName:='192.168.0.11';
  zconexao.LibLocation:= 'C:\SistemasLazarus\PGLibs\64\Libpq.dll';
  zconexao.LoginPrompt:=False;
  zconexao.Protocol:= 'postgresql';
  zconexao.User:= 'equipamentos';
  zconexao.Password:= '123456';
  zconexao.TransactIsolationLevel:=tiReadCommitted;
  zconexao.SQLHourGlass:=True;
  zconexao.AutoCommit:=true; }
//---------------------------------------------------
  zconexao.Database:='postgres';
  zconexao.HostName:='localhost';
  zconexao.LibLocation:= 'C:\SistemasLazarus\PGLibs\32\Libpq.dll';
  zconexao.LoginPrompt:=False;
  zconexao.Protocol:= 'postgresql';
  zconexao.User:= 'postgres';
  zconexao.Password:= 'visual';
  zconexao.TransactIsolationLevel:=tiReadCommitted;
  zconexao.SQLHourGlass:=True;
  zconexao.AutoCommit:=true;
end;

procedure TDM.zqLocalBeforePost(DataSet: TDataSet);
begin
  if (zqLocaldescricao.IsNull) or (zqLocaldescricao.AsString = '') then
     raise EDescricao.Create('Erro');

   zqLocaldescricao.AsString := UpperCase(zqLocaldescricao.AsString);
   //============================================================================
   //Usar caso não tenha Unique no Banco de dados

   try
     with dmdados.DM.zqComandos, SQL do
     begin
          close;
          Clear;
          Add('select * from public.tb_Local');
            Add('where (Descricao = '''+UppCase(zqLocaldescricao.AsString)+''')');  //and id <>'+Codigo);
          open;
     end;

     if dmdados.DM.zqComandos.RecordCount > 0 then
       raise ERepetido.Create('Descricao já cadastrada!');

   finally
     if dmdados.DM.zqComandos.active then
       dmdados.DM.zqComandos.Close;
   end;


  end;

{procedure TDM.zqLocaldescricaoSetText(Sender: TField; const aText: string);
begin
  //showmessage('eu estou aqui');
end;}

procedure TDM.ZConexaoAfterConnect(Sender: TObject);
begin

end;

function UPPCASE(Tx: String): String;
//Converte as letras de um texto em maiúsculas, incluíndo "Ç" e acentuados
const
     MAIUS = 'ABCDEFGHIJKLMNOPQRSTUVXYZWYKÇÁÓÉÃÕÀÈÒÔÊÂ';
     MINUS = 'abcdefghijklmnopqrstuvxyzwykçáóéãõàèòôêâ';
var
   A, B: Integer;
   St: String;
begin
     St:= Tx;
     A:= 1;
     while A <= Length(St) Do
     begin
          B:= Pos(St[A], MINUS);
          if (B <> 0) and (Pos(St[A], MINUS) <> 0) Then St[A]:= MAIUS[B];
          Inc(A);
     end;
     Result:= St;
     SHOWMESSAGE(ST);
end;

end.

