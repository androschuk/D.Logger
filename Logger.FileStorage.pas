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
  System.Classes, Logger.Intf, System.SysUtils, System.SyncObjs, Logger.Storage.Core;

type
  IFileStorageSettings = interface
  ['{35540151-A695-48C2-A820-C033F7B7722E}']
    function GetLogPath: WideString; safecall;
    procedure SetLogPath(ALogPath: WideString); safecall;
    function GetDateTimeFormat: WideString; safecall;
    procedure SetDateTimeFormat(ADateTimeFormat: WideString); safecall;
    function GetMaxFileSize: Int64; safecall;
    procedure SetMaxFileSize(AFileSize: Int64); safecall;
    function GetFilesCount: Integer; safecall;
    procedure SetFilesCount(AFilesCount: Integer); safecall;

    procedure SetDefaults;safecall;
    procedure Load; safecall;

    property LogPath: WideString read GetLogPath write SetLogPath;
    property DateTimeFormat: WideString read GetDateTimeFormat write SetDateTimeFormat;
    property MaxFileSize: Int64 read GetMaxFileSize write SetMaxFileSize;
    property FilesCount: Integer read GetFilesCount write SetFilesCount;
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
    FMaxFileSize: Int64;
    FFilesCount: Integer;
  protected
    {IFileStorageSettings}
    procedure Load; safecall;
    procedure SetDefaults; safecall;
    function GetLogPath: WideString; safecall;
    procedure SetLogPath(ALogPath: WideString); safecall;
    function GetDateTimeFormat: WideString; safecall;
    procedure SetDateTimeFormat(ADateTimeFormat: WideString); safecall;
    function GetMaxFileSize: Int64; safecall;
    procedure SetMaxFileSize(AFileSize: Int64); safecall;
    function GetFilesCount: Integer; safecall;
    procedure SetFilesCount(AFilesCount: Integer); safecall;
  public
    constructor Create(AConfigPath: string); reintroduce;
  end;

  TPathWorker = class
  private
    FPath: string;
    FConfig: IFileStorageSettings;
    FCurFileNum: Integer;
    FNumbersOweflow: Boolean;
  public
    // Validations
    function IsFileSizeOwerflow(const ASize: Int64): Boolean;

    procedure UseNextFile;
    function WorkingFilePath: string;

    constructor Create(AConfig: IFileStorageSettings);
    destructor Destroy; override;
  end;

  TFileStorage = class(TAsyncStorage, IFileStorage)
  private
    FConfig: IFileStorageSettings;
    FStreamWriter: TStreamWriter;
    FInitialized: Boolean;
    PathWorker: TPathWorker;
    procedure InitFile(const AFileName: string);
    procedure FinalizeFile;
  protected
    {IStorage}
    procedure AsyncWriteHandler(Args: ILogArgument); override;
    function Equal(AStorage: IStorage): Boolean; override; safecall;
    {IFileStorage}
    function GetSettings: IFileStorageSettings; safecall;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
  Windows, IniFiles, Logger.Utils, IOUtils;

const
  cUnlimitedFileSize = 0;
  cOneFile = 1;

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

constructor TFileStorage.Create;
begin
  inherited Create;

  InternalLogFmt(' -> %s.Create', [Self.ClassName]);

  FInitialized := False;

  FConfig := TFileStorageSettings.Create(GetConfigFilePath);
  FConfig.Load;

  PathWorker := TPathWorker.Create(FConfig);
end;

destructor TFileStorage.Destroy;
begin
  FinalizeFile;
  FreeAndNil(PathWorker);

  InternalLogFmt(' <- %s.Destroy', [Self.ClassName]);

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
    FStreamWriter.Flush;
    FStreamWriter.Close;
    FreeAndNil(FStreamWriter);
  end;

  FInitialized := False;
end;

function TFileStorage.GetSettings: IFileStorageSettings;
begin
  Result := FConfig;
end;

procedure TFileStorage.InitFile(const AFileName: string);
var
  Mode: Word;
  FileStream: TFileStream;
begin
  if FInitialized then
    Exit;

  InternalLog('- InitFile');

  if FileExists(AFileName) then
    Mode := fmOpenReadWrite or fmShareDenyWrite
  else
    Mode := fmCreate or fmOpenWrite or fmShareDenyWrite;
                 //TBufferedFileStream
  FileStream := TFileStream.Create(AFileName, Mode);
  FileStream.Seek(0, soEnd);
  FStreamWriter := TStreamWriter.Create(FileStream);
  FStreamWriter.OwnStream;

  FInitialized := True;
end;

procedure TFileStorageSettings.SetDefaults;
begin
  FLogPath :=  GetLogFilePath;
  FDateTimeFormat := 'YYYY.MM.DD HH:NN:SS:ZZZ';
  FMaxFileSize := cUnlimitedFileSize;
  FFilesCount := cOneFile;
end;

procedure TFileStorageSettings.SetFilesCount(AFilesCount: Integer);
begin
  FFilesCount := AFilesCount;
end;

procedure TFileStorageSettings.SetMaxFileSize(AFileSize: Int64);
begin
  FMaxFileSize := AFileSize;
end;

procedure TFileStorage.AsyncWriteHandler(Args: ILogArgument);
begin
  if Not FInitialized then
    InitFile(PathWorker.WorkingFilePath);

  while PathWorker.IsFileSizeOwerflow(FStreamWriter.BaseStream.Size) do
  begin
    FinalizeFile;
    PathWorker.UseNextFile;
    InitFile(PathWorker.WorkingFilePath);
  end;

  InternalLogFmt(' - [Write] Source: %s write: %s', [Args.SourceName, Args.LogMessage]);

  FStreamWriter.Write(Format('%s|%s|%s|%s' + sLineBreak,[
      FormatDateTime(FConfig.DateTimeFormat, Args.TimeStamp),
      Args.SourceName,
      Args.LogLevel.ToString,
      Args.LogMessage]));
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

function TFileStorageSettings.GetFilesCount: Integer;
begin
  Result := FFilesCount;
end;

function TFileStorageSettings.GetMaxFileSize: Int64;
begin
  Result := FMaxFileSize;
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
    FMaxFileSize := StrToInt64Def(Config.ReadString(Self.ClassName, 'MaxFileSize' , IntToStr(FMaxFileSize)), 0);
    FFilesCount := Config.ReadInteger(Self.ClassName, 'FilesCount' , FFilesCount);
  finally
    FreeAndNil(Config);
  end;
end;

{ TPathStrategy }

constructor TPathWorker.Create(AConfig: IFileStorageSettings);
begin
  inherited Create;

  FPath := AConfig.LogPath;
  FConfig := AConfig;
  FCurFileNum := 1;
  FNumbersOweflow := False;
end;

destructor TPathWorker.Destroy;
begin

  inherited;
end;

function TPathWorker.IsFileSizeOwerflow(const ASize: Int64): Boolean;
begin
  if FConfig.MaxFileSize = cUnlimitedFileSize then
     Exit(False);

  Result := ASize > FConfig.MaxFileSize;
end;

procedure TPathWorker.UseNextFile;
begin
  if FCurFileNum < FConfig.FilesCount then
    Inc(FCurFileNum)
  else
  begin
    FNumbersOweflow := true;
    FCurFileNum := 1;
  end;
end;

function TPathWorker.WorkingFilePath: string;

  function BuildMultipleLogPath(AFileNum: integer): WideString;
  var
    FilePath: string;
    FileName: string;
    FileExt: string;
  begin
    FilePath := ExtractFilePath(FPath);
    FileName := TPath.GetFileNameWithoutExtension(FPath);
    FileExt := ExtractFileExt(FPath);
    Result := Format('%s%s #%.3d%s', [FilePath, FileName, AFileNum, FileExt])
  end;

  function GetFilePath: WideString;
  begin
    if FConfig.FilesCount > cOneFile then
      Result := BuildMultipleLogPath(FCurFileNum)
    else
      Result := FPath;
  end;

begin
  Result := GetFilePath;

  InternalLogFmt(' - UseNextFile: %s', [Result]);

    if FNumbersOweflow and FileExists(Result) then
        TFile.Delete(Result);
end;

end.
