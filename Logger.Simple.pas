{*******************************************************}
{                                                       }
{                       Delphi.Log                      }
{        https://github.com/androschuk/D.Logger         }
{                                                       }
{             This software is open source,             }
{       licensed under the The MIT License (MIT).       }
{                                                       }
{*******************************************************}

unit Logger.Simple;

interface

uses
  Logger.Intf;

function Logger: ILogger;
procedure Fatal(const AMessage: string);
procedure Error(const AMessage: string);
procedure Warning(const AMessage: string);
procedure Info(const AMessage: string);
procedure Debug(const AMessage: string);
procedure Trace(const AMessage: string);

procedure FatalFmt(const AMessage: string; Args: array of const);
procedure ErrorFmt(const AMessage: string; Args: array of const);
procedure WarningFmt(const AMessage: string; Args: array of const);
procedure InfoFmt(const AMessage: string; Args: array of const);
procedure DebugFmt(const AMessage: string; Args: array of const);
procedure TraceFmt(const AMessage: string; Args: array of const);

implementation

uses
  Logger.Manager;

const
  cSimpleLoggerName = 'Logger';

function Logger: ILogger;
begin
  Result := LogManager.GetLogger(cSimpleLoggerName);
end;

procedure Fatal(const AMessage: string);
begin
  Logger.Fatal(AMessage);
end;

procedure Error(const AMessage: string);
begin
  Logger.Error(AMessage);
end;

procedure Warning(const AMessage: string);
begin
  Logger.Warning(AMessage);
end;

procedure Info(const AMessage: string);
begin
  Logger.Info(AMessage);
end;

procedure Debug(const AMessage: string);
begin
  Logger.Debug(AMessage);
end;

procedure Trace(const AMessage: string);
begin
  Logger.Trace(AMessage);
end;

procedure FatalFmt(const AMessage: string; Args: array of const);
begin
  Logger.FatalFmt(AMessage, Args);
end;

procedure ErrorFmt(const AMessage: string; Args: array of const);
begin
  Logger.ErrorFmt(AMessage, Args);
end;

procedure WarningFmt(const AMessage: string; Args: array of const);
begin
  Logger.WarningFmt(AMessage, Args);
end;

procedure InfoFmt(const AMessage: string; Args: array of const);
begin
  Logger.InfoFmt(AMessage, Args);
end;

procedure DebugFmt(const AMessage: string; Args: array of const);
begin
  Logger.DebugFmt(AMessage, Args);
end;

procedure TraceFmt(const AMessage: string; Args: array of const);
begin
  Logger.TraceFmt(AMessage, Args);
end;

end.
