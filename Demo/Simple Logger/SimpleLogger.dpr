program SimpleLogger;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  ThreadWorker in 'ThreadWorker.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
