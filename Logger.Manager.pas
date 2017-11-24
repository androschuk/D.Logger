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
  System.Classes, System.SysUtils, System.SyncObjs, Winapi.Windows, Generics.Collections,
  Logger.Core, Logger.FileStorage, Logger.Utils;

type
  TLogManager = class(TInterfacedObject, ILogManager)
  strict private
    class var FLogManager : ILogManager;
    class var Lock: TCriticalSection;

    FLoggerList: TThreadList<ILogger>;
    FStorageCache: TThreadList<IStorage>;
  private
    function GetLoggerByName(const ASourceName: string): ILogger;
    function CreateLogger(const ASourceName: string; Storages: TArray<IStorage>): ILogger;
    function GetCachedStorages(AStorages: TArray<IStorage>): TArray<IStorage>;
    function GetCachedStorage(AStorage: IStorage): IStorage;
  protected
    {ILogManager}
    function GetLogger(ASourceName: WideString) : ILogger; safecall;
    function GetCustomLogger(ASourceName: WideString; Storages: TArray<IStorage>) : ILogger; safecall;
  public
    class function Create : ILogManager;
    class destructor Destroy;

    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
  end;

// Singletone
function LogManager : ILogManager;
begin
  Result := TLogManager.Create;
end;

{ TLogManager }

class function TLogManager.Create : ILogManager;
begin
  InitCriticalSection(Lock);

  Lock.Enter;
  try
    if Not Assigned(FLogManager) then
    begin
      FLogManager :=  inherited Create as TLogManager;
      FLogManager._AddRef;

      InternalLog(' => LogManager created');
    end;
    Result := FLogManager;
  finally
    Lock.Leave;
  end;
end;

procedure TLogManager.AfterConstruction;
begin
  inherited;

  InternalLog(' - class TLogManager.AfterConstruction');

  FLoggerList := TThreadList<ILogger>.Create;
  FStorageCache := TThreadList<IStorage>.Create;
end;

class destructor TLogManager.Destroy;
begin
  if Assigned(FLogManager) then
  begin
    FLogManager._Release;
    InternalLog(' <= class LogManager.Destroy');
  end;

  inherited;
end;

procedure TLogManager.BeforeDestruction;
begin
  inherited;

  InternalLog(' <= LogManager.BeforeDestruction');

  FreeAndNil(FLoggerList);
  FreeAndNil(FStorageCache);

  FreeAndNil(Lock);
end;

function TLogManager.GetCustomLogger(ASourceName: WideString; Storages: TArray<IStorage>): ILogger;
begin
  try
    Result := GetLoggerByName(ASourceName);

    if Assigned(Result) then
    begin
      InternalLog(' - logger [' + ASourceName +'] found in cache' );
      Exit;
    end;

    Result := CreateLogger(ASourceName, Storages);
  finally
    Lock.Leave;
  end;
end;

function TLogManager.GetLogger(ASourceName: WideString): ILogger;
begin
  Lock.Enter;
  try
    Result := GetLoggerByName(ASourceName);

    if Assigned(Result) then
    begin
      InternalLog(' - logger [' + ASourceName +'] found in cache' );
      Exit;
    end;

    Result := CreateLogger(ASourceName, [TFileStorage.Create]);
  finally
    Lock.Leave;
  end;
end;

function TLogManager.CreateLogger(const ASourceName: string; Storages: TArray<IStorage>): ILogger;
var
  CachedStorages: TArray<IStorage>;
  LoggeList: TList<ILogger>;
begin
  CachedStorages := GetCachedStorages(Storages);

  Result := TLogger.Create(ASourceName, CachedStorages);
  InternalLog(' - logger [' + ASourceName +'] created' );

  LoggeList := FLoggerList.LockList;
  try
    LoggeList.Add(Result);
  finally
    FLoggerList.UnlockList;
  end;
end;

function TLogManager.GetCachedStorages(AStorages: TArray<IStorage>): TArray<IStorage>;
var
  Storage: IStorage;
  CachedStorage: IStorage;
  I: Integer;
  StorageList: TList<IStorage>;
begin
  SetLength(Result, Length(AStorages));

  for I := 0 to Length(AStorages) - 1 do
  begin
    Storage := AStorages[I];
    CachedStorage := GetCachedStorage(Storage);

    if Assigned(CachedStorage) then
    begin
      InternalLogFmt(' - use existing storage [%s] from cache', [CachedStorage.StorageClassName] );
      Result[I] := CachedStorage
    end
    else
    begin
      InternalLogFmt(' - add storege [%s] to cache', [Storage.StorageClassName]);
      Result[I] := Storage;

      StorageList := FStorageCache.LockList;
      try
        StorageList.Add(Storage);
      finally
        FStorageCache.UnlockList;
      end;
    end;
  end;
end;

function TLogManager.GetCachedStorage(AStorage: IStorage): IStorage;
var
  StorageList: TList<IStorage>;
  Storage: IStorage;
begin
  Result := Nil;

  StorageList := FStorageCache.LockList;
  try
    for Storage in StorageList do
    begin
      if Storage.Equal(AStorage) then
        Exit(Storage);
    end;
  finally
    FStorageCache.UnlockList;
  end;
end;

function TLogManager.GetLoggerByName(const ASourceName: string): ILogger;
var
  LoggeList: TList<ILogger>;
  Logger: ILogger;
begin
  Result := Nil;

  LoggeList := FLoggerList.LockList;
  try
    for Logger in LoggeList do
    begin
      if SameText(Logger.SourceName, ASourceName) then
        Exit(Logger);
    end;
  finally
    FLoggerList.UnlockList;
  end;
end;

end.
