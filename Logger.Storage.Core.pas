unit Logger.Storage.Core;

interface

uses
  Logger.Intf, System.Generics.Collections, System.Classes;

type
  TStorage = class(TInterfacedObject, IStorage)
  protected
    {IStorage}
    procedure Write(Args: ILogArgument); virtual; safecall; abstract;
    function Equal(AStorage: IStorage): Boolean; virtual; safecall; abstract;
    function StorageClassName: WideString; virtual; safecall;
  end;

  TLogWriteEvent = procedure(Args: ILogArgument) of object;

  TAsyncStorage = class(TStorage)
  private
    type
      TAsyncWritter = class(TThread)
      private
        FQueue: TThreadedQueue<ILogArgument>;
        FOnWriteEvent: TLogWriteEvent;
      protected
        procedure Add(Args: ILogArgument);
        procedure Execute; override;
      public
        constructor Create(AWriteEvent: TLogWriteEvent);
        destructor Destroy; override;
      end;
    var
      FAsyncWriter: TAsyncWritter;
  protected
    procedure AsyncWriteHandler(Args: ILogArgument); virtual; abstract;
    procedure Write(Args: ILogArgument); override; safecall;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils, Logger.Utils, System.Types;

{ TStorage }

function TStorage.StorageClassName: WideString;
begin
  Result := Self.ClassName;
end;

{ TAsyncStorage }

constructor TAsyncStorage.Create;
begin
  FAsyncWriter := TAsyncWritter.Create(AsyncWriteHandler);

  InternalLog(Self.ClassName + ' initialized');
end;

destructor TAsyncStorage.Destroy;
begin
  FAsyncWriter.Terminate;
  FAsyncWriter.WaitFor;
  FreeAndNil(FAsyncWriter);

  InternalLog(Self.ClassName + ' finalized');

  inherited;
end;

procedure TAsyncStorage.Write(Args: ILogArgument);
begin
  FAsyncWriter.Add(Args);
end;

{ TAsyncWritter }

constructor TAsyncStorage.TAsyncWritter.Create(AWriteEvent: TLogWriteEvent);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FQueue := TThreadedQueue<ILogArgument>.Create(1500, MaxLongint, 100);
  FOnWriteEvent := AWriteEvent;
end;

destructor TAsyncStorage.TAsyncWritter.Destroy;
begin
//  Terminate;
//  WaitFor;

  FreeAndNil(FQueue);

  inherited;
end;

procedure TAsyncStorage.TAsyncWritter.Execute;
var
  LogItem: ILogArgument;
begin
  NameThreadForDebugging(Self.ClassName);

  if not Assigned(FOnWriteEvent) then
    Exit;

  repeat
    while FQueue.PopItem(LogItem) = TWaitResult.wrSignaled do
    begin
      InternalLogFmt(' - Source: %s write: %s', [LogItem.SourceName ,LogItem.LogMessage]);

      if Assigned(FOnWriteEvent) then
        FOnWriteEvent(LogItem);
    end;
  until Terminated;
end;

procedure TAsyncStorage.TAsyncWritter.Add(Args: ILogArgument);
begin
  FQueue.PushItem(Args);
end;

end.
