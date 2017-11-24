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
