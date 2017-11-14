{*******************************************************}
{                                                       }
{                       Delphi.Log                      }
{        https://github.com/androschuk/D.Logger         }
{                                                       }
{             This software is open source,             }
{       licensed under the The MIT License (MIT).       }
{                                                       }
{*******************************************************}

unit Delphi.Logger.Files;

interface

uses
    Delphi.Logger.Intf, System.Classes, Generics.Collections, Winapi.Windows;

const
  cMaxFileSize = 1024 * 1024 * 2; //2MB;
  cMaxFileCount = 10;

type
  TFileLogger = class(TInterfacedObject, ILogger)
  strict private
    FName: WideString;
    FLogLevel: TLogLevel;
  private
    type
      TFileWriterThread = class(TThread)
      strict private
        FFilePath : string;
        FStreamWriter: TStreamWriter;
    //    FMaxFileSize: Int64;
    //    FMaxFileCount: Integer;
        FQueue: TThreadedQueue<string>;
      private
        procedure InitFile;
        procedure FinalizeFile;
      protected
        procedure Execute; override;
      public
        constructor Create;
        destructor Destroy; override;

        procedure Log(AText: string);

        property FilePath: string read FFilePath write FFilePath;
    //    property MaxFileSize: Int64 read FMaxFileSize write FMaxFileSize;
    //    property MaxFileCount: Integer read FMaxFileCount write FMaxFileCount;
      end;
    var
      FWriter : TFileWriterThread;
  protected
    procedure Log(ALogLevel: TLogLevel; AMessage: WideString); virtual;

    {ILogger}
    function Name: WideString; safecall;

    procedure Fatal(AMessage: WideString); safecall;
    procedure FatalFmt(AMessage: WideString; Args: array of const); safecall;

    procedure Error(AMessage: WideString); safecall;
    procedure Warning(AMessage: WideString); safecall;
    procedure Info(AMessage: WideString); safecall;
    procedure Debug(AMessage: WideString); safecall;
    procedure Trace(AMessage: WideString); safecall;
  public
    constructor Create(AName: WideString); reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils, System.SyncObjs, System.TypInfo;

{ TFileLogger }

constructor TFileLogger.Create(AName: WideString);

  function GetAppPath: string;
  begin
    Result := ExtractFilePath(ParamStr(0));
  end;

  function GetAppName: string;
  begin
    Result := ExtractFileName(GetModuleName(HInstance));
  end;

  function GetLogFileName: string;
  begin
     Result := ChangeFileExt(GetAppName, '.log');
  end;

  function GetLogFilePath: string;
  begin
    Result :=  GetAppPath + GetLogFileName;
  end;

begin
  inherited Create;

  FName := AName;
  FLogLevel := TLogLevel.Info;

  FWriter := TFileWriterThread.Create;
  FWriter.FilePath := GetLogFilePath;

  Debug(Self.ClassName + ' initialized');

//  FWriter.MaxFileSize := cMaxFileSize;
//  FWriter.MaxFileCount := cMaxFileCount;
end;

procedure TFileLogger.Debug(AMessage: WideString);
begin
  Log(TLogLevel.Debug, AMessage);
end;

destructor TFileLogger.Destroy;
begin
  FreeAndNil(FWriter);

  inherited;
end;

procedure TFileLogger.Error(AMessage: WideString);
begin
  Log(TLogLevel.Error, AMessage);
end;

procedure TFileLogger.Fatal(AMessage: WideString);
begin
  Log(TLogLevel.Fatal, AMessage);
end;

procedure TFileLogger.FatalFmt(AMessage: WideString; Args: array of const);
begin
  Log(TLogLevel.Fatal, Format(AMessage, Args));
end;

procedure TFileLogger.Info(AMessage: WideString);
begin
  Log(TLogLevel.Info, AMessage);
end;

procedure TFileLogger.Log(ALogLevel: TLogLevel; AMessage: WideString);

  function GetTimeStamp: string;
  begin
    Result := FormatDateTime('yyyy-mm-dd hh:nn:ss:zzz', now);
  end;

begin
  if ALogLevel <= FLogLevel then
    FWriter.Log(Format('%s|%s|%s|%s',[
      GetTimeStamp,
      FName,
      GetEnumName(TypeInfo(TLogLevel), Integer(ALogLevel)),
      AMessage]));
end;

function TFileLogger.Name: WideString;
begin
  Result := FName;
end;

procedure TFileLogger.Trace(AMessage: WideString);
begin
  Log(TLogLevel.Trace, AMessage);
end;

procedure TFileLogger.Warning(AMessage: WideString);
begin
  Log(TLogLevel.Warning, AMessage);
end;

{ TFileWtiter }

constructor TFileLogger.TFileWriterThread.Create;
begin
  inherited Create(False);

  FreeOnTerminate := False;

  FQueue := TThreadedQueue<string>.Create(1500, MaxLongint, 100);
end;

destructor TFileLogger.TFileWriterThread.Destroy;
begin
  Terminate;
  WaitFor;

  FreeAndNil(FQueue);

  inherited;
end;

procedure TFileLogger.TFileWriterThread.Execute;
var
  value: string;

begin
  NameThreadForDebugging('Delphi.Logger.Files.TFileWriter');
  InitFile;
  try
    repeat
      while FQueue.PopItem(value) <> TWaitResult.wrTimeout do
        FStreamWriter.Write(value + #13#10);
    until Terminated;
  finally
    FinalizeFile;
  end;
end;

procedure TFileLogger.TFileWriterThread.FinalizeFile;
begin
  if Assigned(FStreamWriter) then
  begin
    FStreamWriter.Close;
    FreeAndNil(FStreamWriter);
  end;
end;

procedure TFileLogger.TFileWriterThread.InitFile;
var
  Mode: Word;
  FileStream: TFileStream;
begin
  if FileExists(FilePath) then
    Mode := fmOpenReadWrite or fmShareDenyWrite
  else
    Mode := fmCreate or fmOpenWrite or fmShareDenyWrite;

  FileStream := TFileStream.Create(FilePath, Mode);
  FileStream.Seek(0, soEnd);
  FStreamWriter := TStreamWriter.Create(FileStream, TEncoding.UTF8);
  FStreamWriter.OwnStream;
end;

procedure TFileLogger.TFileWriterThread.Log(AText: string);
begin
  FQueue.PushItem(AText);
end;

end.
