{*******************************************************}
{                                                       }
{                       Delphi.Log                      }
{        https://github.com/androschuk/D.Logger         }
{                                                       }
{             This software is open source,             }
{       licensed under the The MIT License (MIT).       }
{                                                       }
{*******************************************************}

unit Logger.Manager;

interface

uses
  Logger.Intf;

function LogManager : ILogManager;

implementation

uses
  System.SyncObjs, System.SysUtils, Winapi.Windows, Logger.Core, System.Classes, Logger.FileStorage;

type
  TLogManager = class(TInterfacedObject, ILogManager)
  strict private
    class var FLogManager : ILogManager;
    FLoggerList: IInterfaceList;
    FStorageCache: IInterfaceList;
    FStorageLocker: TCriticalSection;
    FListLocker: TMultiReadExclusiveWriteSynchronizer;
  private
    function GetLoggerByName(ASourceName: string): ILogger;
    function CreateLogger(ASourceName: string; Storages: TArray<IStorage>): ILogger;
    function GetCachedStorages(AStorages: TArray<IStorage>): TArray<IStorage>;
    function GetCachedStorage(AStorage: IStorage): IStorage;
  protected
    {ILogManager}
    function GetLogger(ASourceName: WideString) : ILogger; safecall; //overload;
    function GetCustomLogger(ASourceName: WideString; Storages: TArray<IStorage>) : ILogger; safecall; //overload;
  public
    class function Create : ILogManager;
    class destructor Destroy;// override;

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

// Singletone
function LogManager : ILogManager;
begin
  Result := TLogManager.Create;
end;

function TLogManager.GetCustomLogger(ASourceName: WideString;
  Storages: TArray<IStorage>): ILogger;
begin
  Result := GetLoggerByName(ASourceName);

  if Assigned(Result) then
    Exit;

  Result := CreateLogger(ASourceName, Storages);
end;

function TLogManager.GetLogger(ASourceName: WideString): ILogger;
begin
  Result := GetLoggerByName(ASourceName);

  if Assigned(Result) then
  begin
    OutputDebugString(PWideChar(' - logger [' + ASourceName +'] found in cache' ));
    Exit;
  end;

  Result := CreateLogger(ASourceName, [TFileStorage.Create]);
end;

function TLogManager.CreateLogger(ASourceName: string; Storages: TArray<IStorage>): ILogger;
var
  CachedStorages: TArray<IStorage>;
begin
  FListLocker.BeginWrite;
  try
    CachedStorages := GetCachedStorages(Storages);

    Result := TLogger.Create(ASourceName, CachedStorages);
    OutputDebugString(PWideChar(' - logger [' + ASourceName +'] created' ));

    FLoggerList.Add(Result);
  finally
    FListLocker.EndWrite;
  end;
end;

function TLogManager.GetCachedStorages(AStorages: TArray<IStorage>): TArray<IStorage>;
var
  Storage: IStorage;
  CachedStorage: IStorage;
  I: Integer;
begin
    SetLength(Result, Length(AStorages));

//  FStorageLocker.Enter;
  try
    for I := 0 to Length(AStorages) - 1 do
    begin
      Storage := AStorages[I];
      CachedStorage := GetCachedStorage(Storage);

      if Assigned(CachedStorage) then
      begin
        OutputDebugString(PWideChar(' - use existing storage ['+ CachedStorage.ClassName+'] from cache' ));
        Result[I] := CachedStorage
      end
      else
      begin
        OutputDebugString(PWideChar(' - add storege ['+ Storage.ClassName+'] to cache' ));
        Result[I] := Storage;
        FStorageCache.Add(Storage);
      end;
    end;
  finally
//    FStorageLocker.Leave;
  end;
end;

function TLogManager.GetCachedStorage(AStorage: IStorage): IStorage;
var
  Storage: IStorage;
  I: Integer;
begin
  Result := Nil;

  for I := 0 to FStorageCache.Count - 1 do
  begin
    if not Supports(FStorageCache.Items[I], IStorage, Storage) then
      Continue;

    if Storage.Equal(AStorage) then
      Exit(Storage);
  end;
end;

function TLogManager.GetLoggerByName(ASourceName: string): ILogger;
var
  I: Integer;
  Logger: ILogger;
begin
  Result := Nil;

  FListLocker.BeginRead;
  try
    for I := 0 to FLoggerList.Count - 1 do
    begin
      if Supports(FLoggerList.Items[I], ILogger, Logger) And SameText(Logger.SourceName, ASourceName) then
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
  FreeAndNil(FStorageLocker);

  OutputDebugString(PWideChar(' <= class LogManager.Destroy'));

  inherited;
end;

procedure TLogManager.AfterConstruction;
begin
  inherited;

  FLoggerList := TInterfaceList.Create;
  FStorageCache := TInterfaceList.Create;
  FListLocker := TMultiReadExclusiveWriteSynchronizer.Create;
  FStorageLocker := TCriticalSection.Create;
end;

procedure TLogManager.BeforeDestruction;
begin
  inherited;

  OutputDebugString(PWideChar(' <= LogManager.BeforeDestruction'));
  FLoggerList := Nil;
  FStorageCache := Nil;
end;

var
  Locker: TCriticalSection = Nil;

class function TLogManager.Create : ILogManager;
var
   LogManager: ILogManager;
begin
  Locker.Enter;
  try
    if Not Assigned(FLogManager) then
    begin
      LogManager :=  inherited Create as Self;
      OutputDebugString(PWideChar(' => LogManager created'));

      // It's possible another thread also created one.
      // Only one of us will be able to set the AObject singleton variable
      if TInterlocked.CompareExchange(Pointer(FLogManager), Pointer(LogManager), pointer(nil)) <> nil then
      begin
           // The other beat us. Destroy our newly created object and use theirs.
           LogManager := Nil;

           OutputDebugString(PWideChar('[x] LogManager'));
      end;

      FLogManager._AddRef;
    end;
    Result := FLogManager;
  finally
    Locker.Leave;
  end;
end;

initialization
  Locker := TCriticalSection.Create;
finalization
  FreeAndNil(Locker);

end.
