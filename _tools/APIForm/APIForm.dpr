program APIForm;

uses
  Forms,
  SharedData in '..\..\_libs\SharedData.pas',
  SharedVars in '..\..\_libs\SharedVars.pas',
  MainWin in 'MainWin.pas' {MainWindow};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainWindow, MainWindow);
  Application.Run;
end.
