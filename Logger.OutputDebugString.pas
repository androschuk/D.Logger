{*******************************************************}
{                                                       }
{                       Delphi.Log                      }
{        https://github.com/androschuk/D.Logger         }
{                                                       }
{             This software is open source,             }
{       licensed under the The MIT License (MIT).       }
{                                                       }
{*******************************************************}

unit Logger.OutputDebugString;

interface

uses
  System.Classes, Logger.Intf, System.SysUtils, System.SyncObjs, Logger.Storage.Core;

type
  IOutputDebugStringStorageSettings = interface
  ['{67EF620B-D5EC-4B20-8B01-04C410655F29}']
    function GetDateTimeFormat: WideString; safecall;
    procedure SetDateTimeFormat(ADateTimeFormat: WideString); safecall;

    procedure SetDefaults; safecall;
    procedure Load; safecall;

    property DateTimeFormat: WideString read GetDateTimeFormat write SetDateTimeFormat;
  end;

  TOutputDebugStringStorageSettings = class(TInterfacedObject, IOutputDebugStringStorageSettings)
  private
    FConfigPath: string;
    FDateTimeFormat: WideString;
  protected
    {IConfig}
    procedure Load; safecall;
    procedure SetDefaults; safecall;

    function GetDateTimeFormat: WideString; safecall;
    procedure SetDateTimeFormat(ADateTimeFormat: WideString); safecall;
  public
    constructor Create(AConfigPath: string); reintroduce;
  end;

  TOutputDebugStringStorage = class(TStorage)
  private
    FConfig: IOutputDebugStringStorageSettings;
  protected
    {IStorage}
    procedure Write(Args: ILogArgument); override; safecall;
    function Equal(AStorage: IStorage): Boolean; override; safecall;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
  Logger.Utils, IniFiles, Winapi.Windows;

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

{ TOutputDebugStringStorage }

constructor TOutputDebugStringStorage.Create;
begin
  FConfig := TOutputDebugStringStorageSettings.Create(GetConfigFilePath);
  FConfig.Load;
end;

destructor TOutputDebugStringStorage.Destroy;
begin

  inherited;
end;

function TOutputDebugStringStorage.Equal(AStorage: IStorage): Boolean;
begin
  Result := SameText(Self.ClassName, AStorage.StorageClassName);
end;

procedure TOutputDebugStringStorage.Write(Args: ILogArgument);
var
  LogMessage: string;
begin
  LogMessage :=  Format('%s|%s|%s|%s',[
      FormatDateTime(FConfig.DateTimeFormat, Args.TimeStamp),
      Args.SourceName,
      Args.LogLevel.ToString,
      Args.LogMessage]);

  OutputDebugString(PChar(LogMessage));
end;

{ TOutputDebugStringStorageSettings }

constructor TOutputDebugStringStorageSettings.Create(AConfigPath: string);
begin
  FConfigPath := AConfigPath;

  SetDefaults;
end;

function TOutputDebugStringStorageSettings.GetDateTimeFormat: WideString;
begin
  Result := FDateTimeFormat;
end;

procedure TOutputDebugStringStorageSettings.SetDateTimeFormat(ADateTimeFormat: WideString);
begin
  FDateTimeFormat := ADateTimeFormat;
end;

procedure TOutputDebugStringStorageSettings.SetDefaults;
begin
  FDateTimeFormat := 'YYYY.MM.DD HH:NN:SS:ZZZ';
end;

procedure TOutputDebugStringStorageSettings.Load;
var
  Config : TMemIniFile;
begin
  Config := TMemIniFile.Create(FConfigPath);
  try
    FDateTimeFormat := Config.ReadString(Self.ClassName, 'DateTimeFormat', FDateTimeFormat);
  finally
    FreeAndNil(Config);
  end;
end;

end.
