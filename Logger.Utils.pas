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
  Logger.Intf;

function GetAppPath: string;
function GetAppName: string;

type
  TLogLevelHelper = record helper for TLogLevel
    function ToString : string;
  end;

function StringToLogLevel(Value: string): TLogLevel;

implementation

uses
  System.SysUtils, TypInfo;

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
