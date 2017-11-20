{*******************************************************}
{                                                       }
{                       Delphi.Log                      }
{        https://github.com/androschuk/D.Logger         }
{                                                       }
{             This software is open source,             }
{       licensed under the The MIT License (MIT).       }
{                                                       }
{*******************************************************}

unit Logger.FileStorage;

interface

uses
  System.Classes, Logger.Intf, System.SysUtils, System.SyncObjs;

type
  IFileStorageSettings = interface
  ['{35540151-A695-48C2-A820-C033F7B7722E}']
    function GetLogPath: WideString; safecall;
    procedure SetLogPath(ALogPath: WideString); safecall;
    function GetDateTimeFormat: WideString; safecall;
    procedure SetDateTimeFormat(ADateTimeFormat: WideString); safecall;

    procedure SetDefaults;safecall;
    procedure Load; safecall;

    property LogPath: WideString read GetLogPath write SetLogPath;
    property DateTimeFormat: WideString read GetDateTimeFormat write SetDateTimeFormat;
  end;

  IFileStorage = interface
  ['{7E7E3F52-CA9D-4B42-AEE4-138F078DA04E}']
    function GetSettings: IFileStorageSettings; safecall;

    property Settings: IFileStorageSettings read GetSettings;
  end;

  TFileStorageSettings = class(TInterfacedObject, IFileStorageSettings)
  private
    FConfigPath: string;
    FDateTimeFormat: WideString;
    FLogPath: string;
  protected
    {IFileStorageSettings}
    procedure Load; safecall;
    procedure SetDefaults; safecall;
    function GetLogPath: WideString; safecall;
    procedure SetLogPath(ALogPath: WideString); safecall;
    function GetDateTimeFormat: WideString; safecall;
    procedure SetDateTimeFormat(ADateTimeFormat: WideString); safecall;
  public
    constructor Create(AConfigPath: string); reintroduce;
  end;

  TFileStorage = class(TInterfacedObject, IStorage, IFileStorage)
  private
    FLocker: TCriticalSection;
    FConfig: IFileStorageSettings;
    FStreamWriter: TStreamWriter;
    FInitialized: Boolean;
    procedure InitFile;
    procedure FinalizeFile;
  protected
    {IStorage}
    procedure Write(Args: ILogArgument); safecall;
    function Equal(AStorage: IStorage): Boolean; safecall;
    function ClassName: WideString; safecall;
    function GetSettings: IFileStorageSettings; safecall;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
  Logger.Utils, IniFiles, Windows;

{ TFileWriter }
function GetLogFileName: string;
begin
   Result := ChangeFileExt(GetAppName, '.log');
end;

function GetConfigFileName: string;
begin
   Result := 'Logger.Config.ini';
end;

function GetLogFilePath: string;
begin
  Result :=  GetAppPath + GetLogFileName;
end;

function GetConfigFilePath: string;
begin
  Result :=  GetAppPath + GetConfigFileName;
end;

function TFileStorage.ClassName: WideString;
begin
  Result := inherited ClassName;
end;

constructor TFileStorage.Create;
begin
  inherited Create;

  FLocker := TCriticalSection.Create;
  FInitialized := False;

  FConfig := TFileStorageSettings.Create(GetConfigFilePath);
  FConfig.Load;
end;

destructor TFileStorage.Destroy;
begin
  FinalizeFile;
  FreeAndNil(FLocker);

  inherited;
end;

function TFileStorage.Equal(AStorage: IStorage): Boolean;
var
  FileStorage: IFileStorage;
begin
  if not Supports(AStorage, IFileStorage, FileStorage) then
    Exit(False);

  Result := SameText(FConfig.LogPath, FileStorage.Settings.LogPath);
end;

procedure TFileStorage.FinalizeFile;
begin
  if Assigned(FStreamWriter) then
  begin
    FStreamWriter.Close;
    FreeAndNil(FStreamWriter);
  end;
end;

function TFileStorage.GetSettings: IFileStorageSettings;
begin
  Result := FConfig;
end;

procedure TFileStorage.InitFile;
var
  Mode: Word;
  FileStream: TFileStream;
  LogFilePath: WideString;
begin
  FLocker.Enter;
  try
    if FInitialized then
      Exit;

    OutputDebugString(PWideChar(' - InitFile'));

    LogFilePath := FConfig.LogPath;

    if FileExists(LogFilePath) then
      Mode := fmOpenReadWrite or fmShareDenyWrite
    else
      Mode := fmCreate or fmOpenWrite or fmShareDenyWrite;
                   //TBufferedFileStream
    FileStream := TBufferedFileStream.Create(LogFilePath, Mode);
    FileStream.Seek(0, soEnd);
    FStreamWriter := TStreamWriter.Create(FileStream);
    FStreamWriter.OwnStream;

    FInitialized := True;
  finally
    FLocker.Leave;
  end;
end;

procedure TFileStorageSettings.SetDefaults;
begin
  FLogPath :=  GetLogFilePath;
  FDateTimeFormat := 'YYYY.MM.DD HH:NN:SS:ZZZ';
end;

procedure TFileStorage.Write(Args: ILogArgument);
begin
  if Not FInitialized then
    InitFile;

  FLocker.Enter;
  try
    OutputDebugString(PWideChar(Format(' - [Write] Source: %s write: %s',
     [Args.SourceName, Args.LogMessage])));

    FStreamWriter.Write(Format('%s|%s|%s|%s' + sLineBreak,[
        FormatDateTime(FConfig.DateTimeFormat, Args.TimeStamp),
        Args.SourceName,
        Args.LogLevel.ToString,
        Args.LogMessage]));
  finally
    FLocker.Leave;
  end;
end;

{ TFileStorageConfig }

constructor TFileStorageSettings.Create(AConfigPath: string);
begin
  FConfigPath := AConfigPath;
  SetDefaults;
end;

procedure TFileStorageSettings.SetDateTimeFormat(ADateTimeFormat: WideString);
begin
  FDateTimeFormat := ADateTimeFormat;
end;

procedure TFileStorageSettings.SetLogPath(ALogPath: WideString);
begin
  FLogPath := ALogPath;
end;

function TFileStorageSettings.GetDateTimeFormat: WideString;
begin
  Result := FDateTimeFormat;
end;

function TFileStorageSettings.GetLogPath: WideString;
begin
  Result := FLogPath;
end;

procedure TFileStorageSettings.Load;
var
  Config : TMemIniFile;
begin
  Config := TMemIniFile.Create(FConfigPath);
  try
    FLogPath := Config.ReadString(Self.ClassName, 'LogFilePath', FLogPath);
    FDateTimeFormat := Config.ReadString(Self.ClassName, 'DateTimeFormat', FDateTimeFormat);
  finally
    FreeAndNil(Config);
  end;
end;

end.
