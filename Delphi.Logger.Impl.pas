{*******************************************************}
{                                                       }
{                       Delphi.Log                      }
{        https://github.com/androschuk/D.Logger         }
{                                                       }
{             This software is open source,             }
{       licensed under the The MIT License (MIT).       }
{                                                       }
{*******************************************************}

unit Delphi.Logger.Impl;

interface

uses
  Delphi.Logger.Intf;

function LogManager : ILogManager;

implementation

uses
  System.SyncObjs, System.SysUtils, Winapi.Windows, Delphi.Logger.Files,
  System.Classes;

type
  TLogManager = class(TInterfacedObject, ILogManager)
  strict private
    class var FLogManager : ILogManager;
    FLoggerList: IInterfaceList;
    FListLocker: TMultiReadExclusiveWriteSynchronizer;
  private
    function GetLoggerByName(AName: string): ILogger;
    function CreateLogger(AName: string): ILogger;
  protected
    {ILogManager}
    function GetLogger(AName: WideString) : ILogger; safecall; //overload;
//    function CreateLogger(ALoggerSettings: ILoggerSettings) : ILogger; safecall; overload;
  public
    class function Create : ILogManager;
    class destructor Destroy;// override;

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

function LogManager : ILogManager;
begin
  Result := TLogManager.Create;
end;

function TLogManager.GetLogger(AName: WideString): ILogger;
begin
  Result := GetLoggerByName(AName);

  if Assigned(Result) then
    Exit;

  Result := CreateLogger(AName);
end;

function TLogManager.CreateLogger(AName: string): ILogger;
begin
  FListLocker.BeginWrite;
  try
    Result := TFileLogger.Create(AName);

    FLoggerList.Add(Result);
  finally
    FListLocker.EndWrite;
  end;
end;


function TLogManager.GetLoggerByName(AName: string): ILogger;
var
  I: Integer;
  Logger: ILogger;
begin
  Result := Nil;

  FListLocker.BeginRead;
  try
    for I := 0 to FLoggerList.Count - 1 do
    begin
      if Supports(FLoggerList.Items[I], ILogger, Logger) And SameText(Logger.Name, AName) then
      begin
        Exit(Logger);
      end;
    end;
  finally
    FListLocker.EndRead;
  end;
end;

//function TLogManager.CreateLogger(ALoggerSettings: ILoggerSettings): ILogger;
//begin
//   Result := TLogger.Create('<settings not implemented>');
//end;

class destructor TLogManager.Destroy;
begin
  FreeAndNil(FListLocker);

//  FLoggerList := Nil;
  inherited;
end;

procedure TLogManager.AfterConstruction;
begin
  inherited;

  FLoggerList := TInterfaceList.Create;
  FListLocker := TMultiReadExclusiveWriteSynchronizer.Create;
end;

procedure TLogManager.BeforeDestruction;
begin
  inherited;

  FLoggerList := Nil;
end;

class function TLogManager.Create : ILogManager;
var
   LogManager: ILogManager;
begin
  if Not Assigned(FLogManager) then
  begin
    LogManager :=  inherited Create as Self;

    // It's possible another thread also created one.
    // Only one of us will be able to set the AObject singleton variable
    if TInterlocked.CompareExchange(Pointer(FLogManager), Pointer(LogManager), nil) <> nil then
    begin
         // The other beat us. Destroy our newly created object and use theirs.
         FreeAndNil(LogManager);
    end;

    FLogManager._AddRef;
  end;
  Result := FLogManager;
end;

end.
