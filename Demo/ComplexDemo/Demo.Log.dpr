program Demo.Log;

uses
  Vcl.Forms,
  Form.LogDemo in 'Form.LogDemo.pas' {frmLogDemo};

{$R *.res}

begin
//  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmLogDemo, frmLogDemo);
  Application.Run;
end.
