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

    Writeln('Complete...OK');
    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
