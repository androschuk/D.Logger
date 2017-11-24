unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TMainForm = class(TForm)
    btnExecute: TButton;
    mmoResult: TMemo;
    pnlButtons: TPanel;
    procedure btnExecuteClick(Sender: TObject);
  private
    procedure OnStatusChangeHandler(const S: string);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  ThreadWorker;

procedure TMainForm.OnStatusChangeHandler(const S: string);
begin
  mmoResult.Lines.Add(S);
end;

procedure TMainForm.btnExecuteClick(Sender: TObject);
begin
  ExecuteTasks(4, 5000, OnStatusChangeHandler);
end;

end.
