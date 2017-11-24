{*******************************************************}
{                                                       }
{                       Delphi.Log                      }
{        https://github.com/androschuk/D.Logger         }
{                                                       }
{             This software is open source,             }
{       licensed under the The MIT License (MIT).       }
{                                                       }
{*******************************************************}

unit Logger.Utils;

interface

uses
  Logger.Intf, System.SyncObjs, System.SysUtils;

function GetAppPath: string;
function GetAppName: string;

procedure InternalLogFmt(const AMessage: string; Args: array of const);
procedure InternalLog(const AMessage: string);

procedure InitCriticalSection(var ACriticalSection: TCriticalSection); inline;

type
  TLogLevelHelper = record helper for TLogLevel
    function ToString : string;
  end;

function StringToLogLevel(Value: string): TLogLevel;

implementation

uses
  TypInfo, Winapi.Windows;

procedure InitCriticalSection(var ACriticalSection: TCriticalSection); inline;
var
  CriticalSection : TCriticalSection;
begin
  if not Assigned(ACriticalSection) then
  begin
    CriticalSection := TCriticalSection.Create;
    InternalLog(' [*] TLogManager.CriticalSection.Create');

    // It's possible another thread also created one.
    // Only one of us will be able to set the AObject singleton variable
    if TInterlocked.CompareExchange<TCriticalSection>(ACriticalSection, CriticalSection, Nil) <> Nil then
    begin
        InternalLog(' [x] CriticalSection.Destroy; Reason: [duplicate]');
        FreeAndNil(CriticalSection);
    end;
  end;
end;

procedure InternalLog(const AMessage: string); inline;
begin
  {$IFDEF DEBUG}
    OutputDebugString(PWideChar(AMessage));
  {$ENDIF}
end;

procedure InternalLogFmt(const AMessage: string; Args: array of const);
begin
  InternalLog(Format(AMessage, Args));
end;

function GetAppPath: string;
begin
  Result := ExtractFilePath(ParamStr(0));
end;

function GetAppName: string;
begin
  Result := ExtractFileName(GetModuleName(HInstance));
end;

function StringToLogLevel(Value: string): TLogLevel;
begin
  Result := TLogLevel(GetEnumValue(TypeInfo(TLogLevel), Value))
end;

{ TLogLevelHelper }

function TLogLevelHelper.ToString: string;
begin
   Result := GetEnumName(TypeInfo(TLogLevel), Integer(Self))
end;

end.
