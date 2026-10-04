program MD5Calculator;

uses
  Forms,
  SharedData in '..\_libs\SharedData.pas',
  MainWin in 'MainWin.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
