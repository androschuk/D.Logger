program Delphi.Log;

uses
  Vcl.Forms,
  Logger.Intf in 'Logger.Intf.pas',
  Logger.Manager in 'Logger.Manager.pas',
  Logger.FileStorage in 'Logger.FileStorage.pas',
  Logger.Core in 'Logger.Core.pas',
  Logger.Utils in 'Logger.Utils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Run;
end.
