unit Form.LogDemo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Delphi.Logger.Impl, Delphi.Logger.Intf;

type
  TfrmLogDemo = class(TForm)
    rgLogLevel: TRadioGroup;
    btnWrite: TButton;
    mmoLogMessage: TMemo;
    lblLogMessage: TLabel;
    procedure btnWriteClick(Sender: TObject);
  private
    FLogger : ILogger;
    procedure FillLogLevel;
  public
    constructor Create(AOwner: TComponent); Override;
    destructor Destroy; override;
  end;

var
  frmLogDemo: TfrmLogDemo;

implementation

{$R *.dfm}

uses
  System.TypInfo;

{ TfrmLogDemo }

procedure TfrmLogDemo.btnWriteClick(Sender: TObject);
var
  LogLevel: TLogLevel;
begin
  if rgLogLevel.ItemIndex = -1 then
  begin
    ShowMessage('Please select "Log Level"');
    exit;
  end;

  LogLevel := TLogLevel(GetEnumValue(TypeInfo(TLogLevel), rgLogLevel.Items[rgLogLevel.ItemIndex]));

  case LogLevel of
    Off: ;
    Fatal: FLogger.Fatal(mmoLogMessage.Text);
    Error: ;
    Warning: ;
    Info: ;
    Debug: ;
    Trace: ;
  end;
end;

constructor TfrmLogDemo.Create(AOwner: TComponent);
begin
  inherited;

  FLogger := LogManager.CreateLogger('Demo Logger');

  FillLogLevel;
end;

destructor TfrmLogDemo.Destroy;
begin
  FLogger := Nil;

  inherited;
end;

procedure TfrmLogDemo.FillLogLevel;
var
  I: TLogLevel;
  EnumName : string;
begin
  for I := Low(TLogLevel) to High(TLogLevel) do
  begin
    EnumName := GetEnumName(TypeInfo(TLogLevel), Integer(I));
    rgLogLevel.Items.Add(EnumName);
  end;
end;

end.
