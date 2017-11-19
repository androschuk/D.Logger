# D.Logger
Simple logging system for Delphi

## How to use

```
program ConsoleApp;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Logger.Manager,
  Logger.Intf;

var
  Logger: ILogger;

begin
  try
    Logger := LogManager.GetLogger('Console Logger');

    Logger.Fatal('Fatal message');
    Logger.Error('Error message');
    Logger.Warning('Warning message');
    Logger.Info('Info message');
    Logger.Debug('Debug message');
    Logger.Trace('Trace message');

    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
```

Output:
```
<DateTime>|<Logger Name>|Fatal|Fatal message
<DateTime>|<Source Name>|Error|Error message
<DateTime>|<Source Name>|Warning|Warning message
<DateTime>|<Source Name>|Info|Info message
<DateTime>|<Source Name>|Debug|Debug message
<DateTime>|<Source Name>|Trace|Trace message
```
