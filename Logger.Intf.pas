{*******************************************************}
{                                                       }
{                       Delphi.Log                      }
{        https://github.com/androschuk/D.Logger         }
{                                                       }
{             This software is open source,             }
{       licensed under the The MIT License (MIT).       }
{                                                       }
{*******************************************************}

unit Logger.Intf;

interface

uses
  System.SysUtils;

type
  TLogLevel = (Off, Fatal, Error, Warning, Info, Debug, Trace);

  ILogger = interface
  ['{0981673E-0A05-4A11-9F5F-5078FF6C457D}']
    procedure Fatal(AMessage: WideString); safecall;
    procedure FatalFmt(AMessage: WideString; Args: array of const); safecall;

    procedure Error(AMessage: WideString); safecall;
    procedure ErrorFmt(AMessage: WideString; Args: array of const); safecall;

    procedure Warning(AMessage: WideString); safecall;
    procedure WarningFmt(AMessage: WideString; Args: array of const); safecall;

    procedure Info(AMessage: WideString); safecall;
    procedure InfoFmt(AMessage: WideString; Args: array of const); safecall;

    procedure Debug(AMessage: WideString); safecall;
    procedure DebugFmt(AMessage: WideString; Args: array of const); safecall;

    procedure Trace(AMessage: WideString); safecall;
    procedure TraceFmt(AMessage: WideString; Args: array of const); safecall;

    function SourceName: WideString; safecall;
  end;

  ILoggerSettings = interface
  ['{49AC54D5-B7BC-49A6-849D-83DFD9B1B9C4}']
  end;

  ILogArgument = interface
  ['{ABC4E531-D079-4052-89F2-59780D0663C5}']
    function GetSourceName: WideString; safecall;
    function GetLogLevel: TLogLevel; safecall;
    function GetLogMessage: WideString; safecall;
    function GetTimeStamp: TDateTime;safecall;

    property SourceName: WideString read GetSourceName;
    property LogLevel: TLogLevel read GetLogLevel;
    property LogMessage: WideString read GetLogMessage;
    property TimeStamp: TDateTime read GetTimeStamp;
  end;

  IStorage = interface
  ['{3C670B2D-ED78-4B75-8D69-3EF3004C4CAD}']
    procedure Write(Args: ILogArgument); safecall;
    function Equal(AStorage: IStorage): Boolean; safecall;
    function StorageClassName: WideString; safecall;
  end;

  ILogManager = interface
  ['{BFBD0D5F-164F-471F-B901-11B74F5CC6D2}']
    function GetLogger(ASourceName: WideString) : ILogger; safecall;
    function GetCustomLogger(ASourceName: WideString; Storages: TArray<IStorage>) : ILogger; safecall;
  end;

implementation

end.
