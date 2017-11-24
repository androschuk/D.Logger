{*******************************************************}
{                                                       }
{                       Delphi.Log                      }
{        https://github.com/androschuk/D.Logger         }
{                                                       }
{             This software is open source,             }
{       licensed under the The MIT License (MIT).       }
{                                                       }
{*******************************************************}

unit Logger.Core;

interface

uses
    Logger.Intf, System.Classes, Generics.Collections, Winapi.Windows;

type
  ILoggerSettings = interface
  ['{E183ABA3-3FC4-4CBE-A93B-C84283D30D61}']
    function GetLogLevel: TLogLevel; safecall;
    procedure SetLogLevel(ALogLevel: TLogLevel); safecall;

    procedure SetDefaults; safecall;
    procedure Load; safecall;

    property LogLevel: TLogLevel read GetLogLevel write SetLogLevel;
  end;

  TLogArgument = class(TInterfacedObject, ILogArgument)
  private
    FLogLevel: TLogLevel;
    FLogMessage: WideString;
    FSourceName: WideString;
    FTimeStamp: TDateTime;
  protected
    {IStorageArgument}
    function GetSourceName: WideString; safecall;
    function GetLogLevel: TLogLevel; safecall;
    function GetLogMessage: WideString; safecall;
    function GetTimeStamp: TDateTime; safecall;
  public
    constructor Create(ASourceName: WideString; ALogLevel: TLogLevel; ALogMessage: WideString); reintroduce;
    destructor Destroy; override;
  end;

  TLoggerSettings = class(TInterfacedObject, ILoggerSettings)
  private
    FConfigPath: string;
    FLogLevel: TLogLevel;
  protected
    {ILoggerSettings}
    function GetLogLevel: TLogLevel; safecall;
    procedure SetLogLevel(ALogLevel: TLogLevel); safecall;

    procedure SetDefaults; safecall;
    procedure Load; safecall;
  public
    constructor Create(AConfigPath: string); reintroduce;
  end;

  TLogger = class(TInterfacedObject, ILogger)
  strict private
    FConfig: ILoggerSettings;
    FSourceName: String;
    FStorages: TArray<IStorage>;
  protected
    procedure Log(ALogLevel: TLogLevel; AMessage: WideString); virtual;

    {ILogger}
    function SourceName: WideString; safecall;
    procedure Fatal(AMessage: WideString); safecall;
    procedure FatalFmt(AMessage: WideString; Args: array of const); safecall;
    procedure Error(AMessage: WideString); safecall;
    procedure Warning(AMessage: WideString); safecall;
    procedure Info(AMessage: WideString); safecall;
    procedure Debug(AMessage: WideString); safecall;
    procedure Trace(AMessage: WideString); safecall;
  public
    constructor Create(ASourceName: WideString; AStorages: TArray<IStorage>); reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils, System.SyncObjs, System.TypInfo, IniFiles, Logger.Utils;

{ TFileLogger }
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

constructor TLogger.Create(ASourceName: WideString; AStorages: TArray<IStorage>);
begin
  inherited Create;

  FConfig := TLoggerSettings.Create(GetConfigFilePath);
  FConfig.Load;

  FSourceName := ASourceName;
  FStorages := AStorages;

  Debug(Self.ClassName + ' initialized');
  InternalLogFmt(' => %s.Create(Source: %s)', [Self.ClassName, ASourceName]);
end;

procedure TLogger.Debug(AMessage: WideString);
begin
  Log(TLogLevel.Debug, AMessage);
end;

destructor TLogger.Destroy;
begin
  InternalLogFmt(' <= %s.Destroy(Source: %s)', [Self.ClassName, FSourceName]);
  inherited;
end;

procedure TLogger.Error(AMessage: WideString);
begin
  Log(TLogLevel.Error, AMessage);
end;

procedure TLogger.Fatal(AMessage: WideString);
begin
  Log(TLogLevel.Fatal, AMessage);
end;

procedure TLogger.FatalFmt(AMessage: WideString; Args: array of const);
begin
  Log(TLogLevel.Fatal, Format(AMessage, Args));
end;

procedure TLogger.Info(AMessage: WideString);
begin
  Log(TLogLevel.Info, AMessage);
end;

procedure TLogger.Log(ALogLevel: TLogLevel; AMessage: WideString);

  function GetTimeStamp: string;
  begin
    Result := FormatDateTime('yyyy-mm-dd hh:nn:ss:zzz', now);
  end;

var
  Storage: IStorage;
  LogItem: ILogArgument;
begin
  if ALogLevel <= FConfig.LogLevel then
  begin
    LogItem := TLogArgument.Create(SourceName, ALogLevel, AMessage);

    for Storage in FStorages do
      Storage.Write(LogItem);
  end;
end;

function TLogger.SourceName: WideString;
begin
  Result := FSourceName;
end;

procedure TLogger.Trace(AMessage: WideString);
begin
  Log(TLogLevel.Trace, AMessage);
end;

procedure TLogger.Warning(AMessage: WideString);
begin
  Log(TLogLevel.Warning, AMessage);
end;

{ TStorageArgument }

constructor TLogArgument.Create(ASourceName: WideString; ALogLevel: TLogLevel; ALogMessage: WideString);
begin
  FTimeStamp := Now;
  FLogLevel := ALogLevel;
  FLogMessage := ALogMessage;
  FSourceName := ASourceName;

  InternalLogFmt('  [+] %s.Create; Source: %s; Msg: %s', [Self.ClassName, FSourceName, FLogMessage]);
end;

destructor TLogArgument.Destroy;
begin
  InternalLogFmt('  [-] %s.Destroy; Source: %s; Msg: %s', [Self.ClassName, FSourceName, FLogMessage]);
  inherited;
end;

function TLogArgument.GetLogLevel: TLogLevel;
begin
  Result := FLogLevel;
end;

function TLogArgument.GetLogMessage: WideString;
begin
  Result := FLogMessage;
end;

function TLogArgument.GetSourceName: WideString;
begin
  Result := FSourceName;
end;

function TLogArgument.GetTimeStamp: TDateTime;
begin
  Result := FTimeStamp;
end;

{ TLoggerSettings }

constructor TLoggerSettings.Create(AConfigPath: string);
begin
  FConfigPath := AConfigPath;
  SetDefaults;
end;

function TLoggerSettings.GetLogLevel: TLogLevel;
begin
  Result := FLogLevel;
end;

procedure TLoggerSettings.Load;
var
  Config: TMemIniFile;
  LogLevelStr: string;
begin
  Config := TMemIniFile.Create(FConfigPath);
  try
    LogLevelStr := Config.ReadString(Self.ClassName, 'LogLevel', FLogLevel.ToString);
    FLogLevel := StringToLogLevel(LogLevelStr);
  finally
    FreeAndNil(Config);
  end;
end;

procedure TLoggerSettings.SetDefaults;
begin
  FLogLevel := TLogLevel.Info;
end;

procedure TLoggerSettings.SetLogLevel(ALogLevel: TLogLevel);
begin
  FLogLevel := ALogLevel;
end;

end.
