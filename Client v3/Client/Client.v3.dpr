program Client.v3;

{$I defines.inc}

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  DotaParser in 'DotaParser.pas',
  DotaParser_Types in 'DotaParser_Types.pas',
  DotaGame_Validator in 'DotaGame_Validator.pas',
  W3GParser in '_libs\W3GParser\W3GParser.pas',
  W3GParser_Types in '_libs\W3GParser\W3GParser_Types.pas',
  Socktypes in 'Socktypes.pas',
  Localization in '_libs\Localization.pas',
  superobject in '_libs\SuperObject\superobject.pas',
  LoginWin in 'LoginWin.pas' {LoginWindow},
  ComponentContainerUnit in 'ComponentContainerUnit.pas' {ComponentContainer: TDataModule},
  LoginFrame in 'LoginFrame.pas' {frLogin: TFrame},
  SharedFunctions in '_libs\SharedFunctions.pas',
  SharedVars in '_libs\SharedVars.pas',
  LocalizationStr in '_libs\LocalizationStr.pas',
  MainWin in 'MainWin.pas' {MainWindow},
  SettingsWin in 'SettingsWin.pas' {SettingsWindow},
  FileDownloadWin in 'FileDownloadWin.pas' {FileDownloadWindow},
  IPCSharedMemory in 'IPCSharedMemory.pas',
  RegisterFrame in 'RegisterFrame.pas' {frRegister: TFrame},
  UpdateFrame in 'UpdateFrame.pas' {frUpdate: TFrame},
  W3GSParser in '_libs\W3GSParser\W3GSParser.pas',
  W3GSParser_Types in '_libs\W3GSParser\W3GSParser_Types.pas',
  GamingPlatform in 'GamingPlatform.pas' {$R *.res},
  GameProcesser in 'GameProcesser.pas';

{$R _resources\resources.res}

begin
  Application.Initialize;
  Application.Title := 'Darer ' + CLIENT_VERSION;
  Application.CreateForm(TComponentContainer, ComponentContainer);
  Application.CreateForm(TLoginWindow, LoginWindow);
  Application.Run;
end.



