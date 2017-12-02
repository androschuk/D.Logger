# D.Logger
Simple logging system for Delphi

## Log levels
The following are the allowed log levels (in descending order):

 * Off - turn off logging
 * Fatal
 * Error
 * Warning
 * Info
 * Debug
 * Trace
 
## How to use

### Quick logging
```delphi
program MinimumApp;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Logger.Simple;

begin
  try
    Fatal('Fatal message');
    Error('Error message');
    Warning('Warning message');
    Info('Info message');
    Debug('Debug message');
    Trace('Trace message');

    Writeln('Complete...OK');
    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
```
### Flexible logging
```delphi
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
