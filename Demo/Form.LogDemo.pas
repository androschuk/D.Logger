unit Form.LogDemo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Logger.Manager, Logger.Intf;

type
  TfrmLogDemo = class(TForm)
    rgLogLevel: TRadioGroup;
    btnWrite: TButton;
    mmoLogMessage: TMemo;
    lblLogMessage: TLabel;
    btnGetLogger: TButton;
    btnOutputDbgStr: TButton;
    btnTwoLoggerOneStorage: TButton;
    procedure btnWriteClick(Sender: TObject);
    procedure btnGetLoggerClick(Sender: TObject);
    procedure btnOutputDbgStrClick(Sender: TObject);
    procedure btnTwoLoggerOneStorageClick(Sender: TObject);
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
  Logger.Utils, Logger.OutputDebugString;

{ TfrmLogDemo }

procedure TfrmLogDemo.btnGetLoggerClick(Sender: TObject);
var
  Logger : ILogger;
  I: Integer;
begin
  Logger :=  LogManager.GetLogger('Demo Logger 2');

  for I := 0 to 20000 do
  begin
    Logger.Warning('Some message' + IntToStr(I));
  end;
end;

procedure TfrmLogDemo.btnOutputDbgStrClick(Sender: TObject);
var
  LogLevel: TLogLevel;
  MessageText: string;
  Logger: ILogger;
begin
  if rgLogLevel.ItemIndex = -1 then
  begin
    ShowMessage('Please select "Log Level"');
    exit;
  end;

  Logger := LogManager.GetCustomLogger('SomeLogger', [TOutputDebugStringStorage.Create]);

  LogLevel := StringToLogLevel(rgLogLevel.Items[rgLogLevel.ItemIndex]);

  MessageText := Trim(mmoLogMessage.Text);

  case LogLevel of
    Off: {// Do nothing} ;
    Fatal: Logger.Fatal(MessageText);
    Error: Logger.Error(MessageText);
    Warning: Logger.Warning(MessageText);
    Info: Logger.Info(MessageText);
    Debug: Logger.Debug(MessageText);
    Trace: Logger.Trace(MessageText);
  end;
end;

procedure TfrmLogDemo.btnTwoLoggerOneStorageClick(Sender: TObject);
begin
  LogManager.GetLogger('Logger1').Warning('Some Warning 1');
  LogManager.GetLogger('Logger2').Warning('Some Warning 2');
end;

procedure TfrmLogDemo.btnWriteClick(Sender: TObject);
var
  LogLevel: TLogLevel;
  MessageText: string;
begin
  if rgLogLevel.ItemIndex = -1 then
  begin
    ShowMessage('Please select "Log Level"');
    exit;
  end;

  LogLevel := StringToLogLevel(rgLogLevel.Items[rgLogLevel.ItemIndex]);

  MessageText := Trim(mmoLogMessage.Text);

  case LogLevel of
    Off: {// Do nothing} ;
    Fatal: FLogger.Fatal(MessageText);
    Error: FLogger.Error(MessageText);
    Warning: FLogger.Warning(MessageText);
    Info: FLogger.Info(MessageText);
    Debug: FLogger.Debug(MessageText);
    Trace: FLogger.Trace(MessageText);
  end;
end;

constructor TfrmLogDemo.Create(AOwner: TComponent);
begin
  inherited;

  FLogger := LogManager.GetLogger('Demo Logger');

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
begin
  for I := Low(TLogLevel) to High(TLogLevel) do
    rgLogLevel.Items.Add(I.ToString);
end;

end.
