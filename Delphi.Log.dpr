program Delphi.Log;

uses
  Vcl.Forms,
  Delphi.Logger.Intf in 'Delphi.Logger.Intf.pas',
  Delphi.Logger.Files in 'Delphi.Logger.Files.pas',
  Delphi.Logger.Impl in 'Delphi.Logger.Impl.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.
