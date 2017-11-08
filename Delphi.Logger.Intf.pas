unit Delphi.Logger.Intf;

interface

type
  TLogLevel = (Off, Fatal, Error, Warning, Info, Debug, Trace);

  ILogger = interface
  ['{0981673E-0A05-4A11-9F5F-5078FF6C457D}']
    procedure Fatal(AMessage: WideString); safecall;
    procedure FatalFmt(AMessage: WideString; Args: array of const); safecall;
  end;

  ILoggerSettings = interface
  ['{49AC54D5-B7BC-49A6-849D-83DFD9B1B9C4}']
  end;

  ILogManager = interface
  ['{BFBD0D5F-164F-471F-B901-11B74F5CC6D2}']
    function CreateLogger(AName: WideString) : ILogger; safecall; //overload;
//    function CreateLogger(ALoggerSettings: ILoggerSettings) : ILogger; safecall; overload;
  end;

implementation

end.
