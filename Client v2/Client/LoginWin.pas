unit LoginWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ImgList, sppngimagelist, DynamicSkinForm, SkinCtrls, SkinBoxCtrls,
  StdCtrls, Mask, SkinExCtrls, ExtCtrls, GProxy, Menus,
  JvComponentBase, JvThread, spMessages, RegisterFrame, LoginFrame, AdminElevatorFrame,
  SkinMenus, SkinData, spSkinShellCtrls, OverbyteIcsWndControl,
  OverbyteIcsHttpProt, UpdateFrame;

type
  TLoginWindow = class(TForm)
    SkinForm: TspDynamicSkinForm;
    thdLogin: TJvThread;
    frRegister: TfrRegister;
    frLogin: TfrLogin;
    frAdminElevator: TfrAdminElevator;
    frUpdate: TfrUpdate;
    tiAutoLoginUpdate: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure frRegisterbtCancelClick(Sender: TObject);
    procedure frLoginbtRegisterClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DoStuff;
    procedure LangItemClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure frLoginbtLoginClick(Sender: TObject);
    procedure thdLoginExecute(Sender: TObject; Params: Pointer);
    procedure httpUpdateCheckSocksError(Sender: TObject; Error: Integer; Msg: String);
    procedure PopulateLanguageFlags;
    procedure tiAutoLoginUpdateTimer(Sender: TObject);
    procedure SkinFormActivate(Sender: TObject);
  private
    procedure WMCopyData(var Msg : TWMCopyData); message WM_COPYDATA;
  public
    AutoLoginUpdate      : Boolean;
    AutoLoginAfterUpdate : Boolean;
    PreventAutoLogin     : Boolean;
  end;

var
  LoginWindow: TLoginWindow;

implementation

{$R *.dfm}

uses
  ComponentModule, SharedData, MainWin, Localization, ContactWin, PsApi, TlHelp32,
  OptionsWin, Misc, CommandsWin, TutorialWin, INIFiles, AntiMaphack, SkinEngine, VersionPatcher, SharedVars,
  GameRepairWin, GameLanguageWin;


procedure TLoginWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveSettings;
  ComponentModuleWindow.Settings.WriteBoolean('login\autologin', frLogin.chbAutoLogin.Checked);  
  ComponentModuleWindow.Free;
  ExitProcess(0);
  Action := caFREE;
end;

procedure TLoginWindow.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Case Key of
    vk_RETURN : SelectNext(ActiveControl as TWinControl, TRUE, TRUE);
  End;
end;

procedure TerminateGProxy;
var
  cUsername : String;
  gproxymd5 : String;

  procedure CheckProcess(const AProcess : TProcessEntry32);
  var
    pUsername : String;
    pChecksum : String;
    pPath     : String;
  begin
    If (GetDomainAndUser(AProcess.th32ProcessID, pUsername)) and
       (pUsername = cUsername) Then
    Begin
      pPath := GetFullPathFromPID(AProcess.th32ProcessID);
      If FileExists(pPath) Then
      Begin
        try
          pChecksum := md5File(pPath);
        finally
          If pChecksum = gproxymd5 Then
            KillProcess(AProcess.th32ProcessID);
        end;
      End;
    End;  
  end;

var
  hSnapshot : THandle;
  pEntry    : TProcessEntry32;
begin
  If GetDomainAndUser(GetCurrentProcessID, cUsername) Then
  Begin
    hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
    pEntry.dwSize := SizeOf(TProcessEntry32);
    If Process32First(hSnapshot, pEntry) Then
    Begin
      gproxymd5 := md5File(ComponentModuleWindow.GProxy.ExePath);
      CheckProcess(pEntry);
      While Process32Next(hSnapshot, pEntry) Do
        CheckProcess(pEntry);
    End;
  End;
end;

procedure TLoginWindow.FormCreate(Sender: TObject);
var
  C1   : Integer;
  item : TMenuItem;
begin
  ClientWidth := 261;
  ClientHeight := 442;

  frRegister.Align := alClient;
  frLogin.Align := alClient;
  frAdminElevator.Align := alClient;
  frUpdate.Align := alClient;

  SetLanguage(ComponentModuleWindow.Settings.ReadString('client\language', 'English'));

  Localize(ComponentModuleWindow);

  Caption := CLIENT_VERSION;

  PreventAutologin := FALSE;

  ComponentModuleWindow.pmLanguage.Clear;
  For C1 := 0 to Languages.Count - 1 Do
  Begin
    item := TMenuItem.Create(ComponentModuleWindow.pmLanguage);
    item.AutoHotkeys := maManual;
    item.Caption := Languages.Items[C1].Name;
    item.ImageIndex := -1;
    item.RadioItem := TRUE;
    item.GroupIndex := 1;
    item.Checked := Language = C1;
    item.OnClick := LangItemClick;
    item.Tag := C1;

    ComponentModuleWindow.pmLanguage.Add(item);
  End;
end;

procedure TLoginWindow.DoStuff;
begin
  If IsUserAnAdmin Then
  Begin
    If not Assigned(ComponentModuleWindow.GProxy) Then
      ComponentModuleWindow.GProxy := TGProxy.Create(SelfPath + GPROXY_EXE);

    TerminateGProxy;

    InstallURLProtocol;

    frLogin.LoadUserData;
    frLogin.chbRemember.Checked := (frLogin.ebUsername.Text <> '') and (frLogin.ebPassword.Text <> '');
    frLogin.chbAutoLogin.Checked := ComponentModuleWindow.Settings.ReadBoolean('login\autologin', FALSE);

    frLogin.Show;

    RecognizeGameLanguage;
    ComponentModuleWindow.Settings.WriteString('wc3\language', Options.WC3.Language);

    If (DirectoryExists(Options.WC3.Path)) and
       (not IsLatestVersion) Then
    Begin
      frLogin.SetStatus(RS_REPAIR_FILES_MISSING, -1, clRed);
      frLogin.btLogin.Caption := RS_BUTTON_REPAIR;
    End
    else
    Begin
      frLogin.btLogin.Enabled := TRUE;
      frLogin.btLogin.Caption := RS_LOGIN;

      If ((frLogin.chbAutoLogin.Checked) and
          (not PreventAutoLogin)) or
         (AutoLoginUpdate) or
         (AutoLoginAfterUpdate) Then
      Begin
        AutoLoginUpdate := FALSE;
        AutoLoginAfterUpdate := FALSE;

        If AutoLoginUpdate Then
        Begin
          frLogin.Hide;
          frUpdate.Show;
          tiAutoLoginUpdate.Enabled := TRUE;
        End
        else
          frLogin.btLogin.OnClick(nil);
      End;
    End;
  End
  else
  Begin
    frAdminElevator.LoadAdminData;

    If (frAdminElevator.ebUsername.Text <> '') and (frAdminElevator.ebPassword.Text <> '') Then
      frAdminElevator.Login;

    frAdminElevator.SetStatus(RS_ENTER_ADMIN_USERPASS, -1);

    frAdminElevator.Show;
  End;
end;

procedure TLoginWindow.WMCopyData(var Msg : TWMCopyData);
var
  sMsg : String;
begin
  sMsg := PChar(Msg.CopyDataStruct.lpData);
  If sMsg = 'focus' Then
    ComponentModuleWindow.TrayIcon.OnClick(nil);
end;

procedure TLoginWindow.frRegisterbtCancelClick(Sender: TObject);
begin
  If frRegister.gettingCaptcha Then
    frRegister.httpRegister.Close;
    
  frRegister.Hide;
  frLogin.Show;
end;

procedure TLoginWindow.frLoginbtRegisterClick(Sender: TObject);
begin
  frRegister.ResetFrame;
  If (not frRegister.gotCaptcha) and
     (not frRegister.gettingCaptcha) Then
  Begin
    frRegister.gettingCaptcha := TRUE;
    httpPostRequest(frRegister.httpCaptcha, URL_CAPTCHA, '');
  End;
  frLogin.Hide;
  frRegister.Show;
  frRegister.ebEmail.SetFocus;
end;

procedure TLoginWindow.FormShow(Sender: TObject);
begin
  Localize(self);
  MainWindow := nil;

  ComponentModuleWindow.tcpServer.Close;
  ComponentModuleWindow.tcpServer.OnDataAvailable := nil;

  frRegister.Hide;
  frLogin.Show;
  frLogin.ShowLoginAnimation(FALSE);

  DoStuff;
end;

procedure TLoginWindow.LangItemClick(Sender: TObject);
begin
  If SetLanguage(TMenuItem(Sender).Caption) Then
  Begin
    TMenuItem(Sender).Checked := TRUE;
    Localize(self);
    Localize(ComponentModuleWindow);

    If Localize(MainWindow) Then
    Begin
      MainWindow.LocalLocalize;
      MainWindow.mmLanguage.Find(TMenuItem(Sender).Caption).Checked := TRUE;
    End;

    If Localize(ContactWindow) Then
      ContactWindow.LocalLocalize;

    If Localize(OptionsWindow) Then
      OptionsWindow.LocalLocalize;

    If Localize(CommandsWindow) Then
      CommandsWindow.LocalLocalize;

    If Localize(TutorialWindow) Then
      TutorialWindow.LocalLocalize;
  End;
end;

procedure TLoginWindow.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  noclose : Boolean;
begin
  If frAdminElevator.Visible Then
    CanClose := TRUE
  else
  Begin
    noclose := not ComponentModuleWindow.GProxy.GetTerminated;
    CanClose := ComponentModuleWindow.TryLogout;

    If noclose Then
    Begin
      CanClose := FALSE;
      frLogin.tiLoginTimeout.OnTimer(Sender);
    End;
  End;   
end;

procedure TLoginWindow.frLoginbtLoginClick(Sender: TObject);
var
  executed : Boolean;
begin
  If frLogin.btLogin.Caption = RS_BUTTON_REPAIR Then
  Begin
    If Options.WC3.Language = '' Then
    Begin
      Application.CreateForm(TGameLanguageWindow, GameLanguageWindow);
      GameLanguageWindow.ShowModal;
      GameLanguageWindow := nil;
    End;

    Application.CreateForm(TGameRepairWindow, GameRepairWindow);
    GameRepairWindow.Hashes := GetGameHashes;
    GameRepairWindow.StartAutomatically := TRUE;
    GameRepairWindow.CloseAutomatically := TRUE;
    GameRepairWindow.ShowModal;
    frLogin.SetStatus('', -1);
    LoginWindow.DoStuff;
  End
  else
    If not IsValidWC3Path Then
    Begin
      frLogin.SetStatus(RS_SELECT_WC3, -1, clWhite);
      executed := AskForWC3Path;
      frLogin.SetStatus('', 0, clWhite);

      If executed Then
        frLoginbtLoginClick(Sender);
    End
    else
    Begin
      frLogin.btLogin.Enabled := FALSE;
      If frLogin.chbRemember.Checked Then
        frLogin.SaveUserData
      else
        frLogin.DeleteUserData;

      ComponentModuleWindow.Settings.WriteBoolean('login\autologin', frLogin.chbAutoLogin.Checked);

      thdLogin.Execute(nil);
      frLogin.btLogin.Enabled := TRUE;
    End;
end;

procedure TLoginWindow.thdLoginExecute(Sender: TObject; Params: Pointer);
begin
  frLogin.tiLoginTimeout.Enabled := FALSE;
  frLogin.tiLoginTimeout.Enabled := TRUE;
  frLogin.Login;
end;

procedure TLoginWindow.httpUpdateCheckSocksError(Sender: TObject; Error: Integer; Msg: String);
begin
  frLogin.SetStatus(Format('[%d] %s', [Error, Msg]), -1, clRed);
end;

procedure TLoginWindow.PopulateLanguageFlags;
var
  C1 : Integer;
begin
  For C1 := 0 to ComponentModuleWindow.pmLanguage.Count - 1 Do
    ComponentModuleWindow.pmLanguage.Items[C1].ImageIndex := ComponentModuleWindow.FindCountryImage(Languages.Items[ComponentModuleWindow.pmLanguage.Items[C1].Tag].FlagResCode);

  If Assigned(MainWindow) Then
    For C1 := 0 to MainWindow.mmLanguage.Count - 1 Do
      MainWindow.mmLanguage.Items[C1].ImageIndex := ComponentModuleWindow.FindCountryImage(Languages.Items[MainWindow.mmLanguage.Items[C1].Tag].FlagResCode);
end;

procedure TLoginWindow.tiAutoLoginUpdateTimer(Sender: TObject);
begin
  tiAutoLoginUpdate.Enabled := FALSE;
  AutoLoginUpdate := FALSE;
  frLogin.CheckForVersion;
end;

procedure TLoginWindow.SkinFormActivate(Sender: TObject);
begin
  ComponentModuleWindow.TrayIcon.IconVisible := TRUE;
end;

end.
