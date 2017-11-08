unit Delphi.Loger.Files;

interface

uses
    Delphi.Logger.Intf, System.Classes;

const
  cMaxFileSize = 1024 * 1024 * 5; //5MB;
  cMaxFileCount = 5;

type
  TFileWtiter = class(TThread)
  protected
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TFileLogger = class(TInterfacedObject, ILogger)
  strict private
    FName: WideString;
    FLogLevel: TLogLevel;
  protected
    procedure Log(ALogLevel: TLogLevel; Value: WideString); virtual;

    {ILogger}
    procedure Fatal(AMessage: WideString); safecall;
    procedure FatalFmt(AMessage: WideString; Args: array of const); safecall;
  public
    constructor Create(AName: WideString); reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils;

{ TFileLogger }

constructor TFileLogger.Create(AName: WideString);
begin
  inherited Create;

  FName := AName;
  FLogLevel := TLogLevel.Info;

//  FWriter := TRollingFileWriter.Create;
//  FWriter.FileName := ExtractFilePath(ParamStr(0)) + ExtractFileName(ChangeFileExt(GetModuleName(HInstance), '_log.log'));
//  FWriter.MaxFileSize := AMaxFileSize;
//  FWriter.MaxFileNumber := AMaxFileNumber;
//  FWriter.StartThread;

end;

destructor TFileLogger.Destroy;
begin
//  FreeAndNil(FWriter);

  inherited;
end;

procedure TFileLogger.Fatal(AMessage: WideString);
begin
  Log(TLogLevel.Fatal, AMessage);
end;

procedure TFileLogger.FatalFmt(AMessage: WideString; Args: array of const);
begin
  Log(TLogLevel.Fatal, Format(AMessage, Args));
end;

procedure TFileLogger.Log(ALogLevel: TLogLevel; Value: WideString);
begin
  if ALogLevel >= FLogLevel  then
  begin
//    vFullMessage := Format('%s %s %s - %s', [GetTimeStamp, GetLogLevelName(Level), FName, Value]);
//    FWriter.Log(vFullMessage)
  end;
end;

{ TFileWtiter }

constructor TFileWtiter.Create;
begin
//  TQueue.
//  TThreadedQueue<T>.Create(1000, MaxLongint, 100);
//  FQueue :=
end;

destructor TFileWtiter.Destroy;
begin

  inherited;
end;

end.
