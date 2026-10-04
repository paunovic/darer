{$I ..\defines.inc}

program Darer;

uses
  FastMM4 in '..\_libs\FastMM\FastMM4.pas',
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  FastMM4Messages in '..\_libs\FastMM\FastMM4Messages.pas',
  FastCode,
  Windows,
  Forms,
  Messages,
  SysUtils,
  SharedData in '..\_libs\SharedData.pas',
  GProxy in 'GProxy.pas',
  superobject in '..\_libs\JSON\superobject.pas',
  ComponentModule in 'ComponentModule.pas' {ComponentModuleWindow: TDataModule},
  MainWin in 'MainWin.pas' {MainWindow},
  LoginWin in 'LoginWin.pas' {LoginWindow},
  RegisterFrame in 'RegisterFrame.pas' {frRegister: TFrame},
  LoginFrame in 'LoginFrame.pas' {frLogin: TFrame},
  AdminElevatorFrame in 'AdminElevatorFrame.pas' {frAdminElevator: TFrame},
  Localization in '..\_libs\Localization.pas',
  ContactWin in 'ContactWin.pas' {ContactWindow},
  OptionsWin in 'OptionsWin.pas' {OptionsWindow},
  AntiMaphack in 'AntiMaphack.pas',
  Misc in 'Misc.pas',
  TutorialWin in 'TutorialWin.pas' {TutorialWindow},
  CommandsWin in 'CommandsWin.pas' {CommandsWindow},
  Cache in 'Cache.pas',
  P2P in 'P2P.pas',
  ChannelWin in 'ChannelWin.pas' {ChannelWindow},
  SkinEngine in 'SkinEngine.pas',
  BlocklistWin in 'BlocklistWin.pas' {BlocklistWindow},
  FriendRequestWin in 'FriendRequestWin.pas' {FriendRequestWindow},
  UpdateFrame in 'UpdateFrame.pas' {frUpdate: TFrame},
  TrayPopupWin in 'TrayPopupWin.pas' {TrayPopupWindow},
  GameRepairWin in 'GameRepairWin.pas' {GameRepairWindow},
  ReplayDownloadWin in 'ReplayDownloadWin.pas' {ReplayDownloadWindow},
  VersionPatcher in 'VersionPatcher.pas',
  HotkeyMapWin in 'HotkeyMapWin.pas' {HotkeyMapWindow},
  SharedVars in '..\_libs\SharedVars.pas',
  ZLibEx in '..\_libs\ZLib\ZLibEx.pas',
  ZLibExApi in '..\_libs\ZLib\ZLibExAPi.pas',
  ZLibExGZ in '..\_libs\ZLib\ZLibExGZ.pas',
  W3GParser in 'W3GParser.pas',
  GameLanguageWin in 'GameLanguageWin.pas' {GameLanguageWindow};

{$R ..\_resources\client\resources.res}

var
  CreateLoginForm : Boolean;
  Uninstall       : Boolean;
  paramAutoLogin  : Boolean;

procedure ProcessParameters;
var
  param, param_type : String;
  paramReplay       : Boolean;
  paramUninstall    : Boolean;
  paramInstall      : Boolean;
  paramInstallRun   : Boolean;
begin
  paramUninstall := FALSE;
  paramInstall := FALSE;
  paramInstallRun := FALSE;

  If MatchStrings('darer://*=*', ParamStr(1), FALSE) Then
  Begin
    param := ParamStr(1);
    Delete(param, 1, 8);
    param_type := Copy(param, 1, Pos('=', param) - 1);
    Delete(param, 1, Pos('=', param));

    paramReplay := param_type = 'REPLAY';
  End
  else
  Begin
    paramReplay := ParamStr(1) = '-replay';
    paramUninstall := ParamStr(1) = '-uninstall';
    paramInstall := ParamStr(1) = '-install';
    paramInstallRun := ParamStr(1) = '-installandrun';
    paramAutoLogin := ParamStr(1) = '-autologin';
    param := ParamStr(2);
  End;

  If paramReplay Then
  Begin
    Application.Title := 'Darer Replay';
    Application.CreateForm(TReplayDownloadWindow, ReplayDownloadWindow);
    ReplayDownloadWindow.ReplayFile := param;
    CreateLoginForm := FALSE;
  End;

  If paramUninstall Then
  Begin
    UninstallURLProtocol;
    UnregisterReplayExtension;
    CreateLoginForm := FALSE;
    Uninstall := TRUE;
  End;

  If paramInstall Then
  Begin
    If IsUserAnAdmin Then
      RegisterReplayExtension;
    CreateLoginForm := FALSE;
  End;

  If paramInstallRun Then
    RegisterReplayExtension;
end;

begin
  Application.Initialize;
  Application.Title := 'Darer';

  LanguagesInit;

  CreateLoginForm := TRUE;
  ProcessParameters;

  Application.CreateForm(TComponentModuleWindow, ComponentModuleWindow);
  
  If CreateLoginForm Then
  Begin
    CreateInstanceMutex;
    If not IsAlphaInstance Then
    Begin
      WMSendString(FindWindow('TLoginWindow', nil), Application.Handle, 'focus');
      SetForegroundWindow(FindWindow('TLoginWindow', nil));
      ExitProcess(0);
    End;

    If CreateLoginForm Then
    Begin
      Application.CreateForm(TLoginWindow, LoginWindow);
      SetAsMainForm(LoginWindow);
      LoginWindow.AutoLoginAfterUpdate := paramAutoLogin;
    End;
  End;

  Application.Run;
end.

