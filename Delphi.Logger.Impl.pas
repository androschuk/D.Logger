unit Delphi.Logger.Impl;

interface

uses
  Delphi.Logger.Intf;

function LogManager : ILogManager;

implementation

uses
  System.SyncObjs, System.SysUtils, Winapi.Windows,  Delphi.Loger.Files;

type
  TLogManager = class(TInterfacedObject, ILogManager)
  strict private
    class var FLogManager : TLogManager;
  protected
    {ILogManager}
    function CreateLogger(AName: WideString) : ILogger; safecall; //overload;
//    function CreateLogger(ALoggerSettings: ILoggerSettings) : ILogger; safecall; overload;
  public
    class function Instance : ILogManager;
    destructor Destroy; override;
  end;

function LogManager : ILogManager;
begin
  Result := TLogManager.Instance;
end;

function TLogManager.CreateLogger(AName: WideString): ILogger;
begin
  Result := TFileLogger.Create(AName);
end;

//function TLogManager.CreateLogger(ALoggerSettings: ILoggerSettings): ILogger;
//begin
//   Result := TLogger.Create('<settings not implemented>');
//end;

destructor TLogManager.Destroy;
begin
  FLogManager := Nil;

  inherited;
end;

class function TLogManager.Instance : ILogManager;
var
   LogManager: TLogManager;
begin
  if Not Assigned(FLogManager) then
  begin
    LogManager := TLogManager.Create;

    // It's possible another thread also created one.
    // Only one of us will be able to set the AObject singleton variable
    if TInterlocked.CompareExchange(Pointer(FLogManager), Pointer(LogManager), nil) <> nil then
    begin
         // The other beat us. Destroy our newly created object and use theirs.
         LogManager := Nil;
    end;
  end;

//  Supports(FLogManager, ILogManager, Result);
  Result := FLogManager as ILogManager;
end;

end.
