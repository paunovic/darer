unit ComponentContainerUnit;

interface

uses
  Windows, Forms, SysUtils, Controls, Classes, SkinData, Localization, Registry, Graphics, JvComponentBase,
  JvAppStorage, JvAppRegistryStorage, PngImageList, ImgList, Menus, ExtCtrls, IPCSharedMemory,
  spMessages, OverbyteIcsWndControl, OverbyteIcsHttpProt, CoolTrayIcon;

{$I defines.inc}

type
  TComponentContainer = class(TDataModule, ILocalizationChanged)
    sppLogin: TspSkinData;
    spsLogin: TspCompressedStoredSkin;
    Settings: TJvAppRegistryStorage;
    sppMain: TspSkinData;
    spsMain: TspCompressedStoredSkin;
    pmTray: TPopupMenu;
    pmTraySettings: TMenuItem;
    pmTrayLanguage: TMenuItem;
    N4: TMenuItem;
    pmTrayLogout: TMenuItem;
    pmTrayExit: TMenuItem;
    ilGlyphs48: TPngImageList;
    ilGlyphs16: TPngImageList;
    skinMsgBox: TspSkinMessage;
    ilFlags: TPngImageList;
    httpErrorReporter: THttpCli;
    timerHide: TTimer;
    TrayIcon: TCoolTrayIcon;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure pmTrayExitClick(Sender: TObject);
    procedure pmTrayLogoutClick(Sender: TObject);
    procedure pmTraySettingsClick(Sender: TObject);
    procedure pmLanguageSubitemClick(Sender: TObject);
    procedure httpErrorReporterRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure timerHideTimer(Sender: TObject);
    procedure TrayIconMinimizeToTray(Sender: TObject);
  private
    procedure IPCReceiveString(const AString : String);
    procedure ProcessURLParams(const AParams : String);
    procedure ProcessParams(AParams : String);
    procedure ProcessParam(const AParam : String; const AIPC : Boolean);
    procedure LoadLanguageFlags;
    procedure ApplyLocalizationChange;
  public
    Localizer         : TLocalizer;
    NoAutoLogin       : Boolean;
    CanExit           : Boolean;
    ReplayDownloading : Boolean;
    IPC               : TIPCSharedMemory;
    LoginSwitch       : Boolean;
    LoginUsername     : String;
    LoginPassword     : String;
    AutoUpdateSwitch  : Boolean;
    AutoUpdateParams  : String;
    HideSwitch        : Boolean;

    procedure ShowClient;
    procedure HideClient;
    procedure Logout;
    function CanClose : Boolean;
    procedure FillLanguageSubitems;
    procedure Relocalize;
    procedure Close;
    function LogoutAndUpdate : Boolean;
    procedure ChangeLanguage(const ALanguage : String);
  end;

var
  ComponentContainer: TComponentContainer;

implementation

{$R *.dfm}

uses
  LoginWin, MainWin, SharedFunctions, SettingsWin, SharedVars, Messages,
  FileDownloadWin, Dialogs, LocalizationStr;


procedure TComponentContainer.DataModuleCreate(Sender: TObject);
var
  C1     : Integer;
  params : String;
  AlreadyExists : Boolean;
begin
  DbgLn('TComponentContainer.DataModuleCreate()');

  Randomize;

  {$IFDEF DEBUGSWITCH}
  Debug := TRUE;
  {$ENDIF}

  LoadSettings;
  SetProcPrivileges(GetCurrentProcessID, 'SeDebugPrivilege');

  Localizer := TLocalizer.Create(ITB(SelfPath) + DIR_LANGUAGES, '*.dlf');
  If (Options.LanguageFile = '') and
     (Localizer.LanguageList.Count > 0) Then
    Options.LanguageFile := Localizer.LanguageList[0];
  Localizer.LanguageFile := Options.LanguageFile;
  Localizer.LocalizeResourceStrings;

  Localizer.Localize(self);

  IPC := TIPCSharedMemory.Create;
  IPC.Open('DarerIPCSpace', 16 * 1024, AlreadyExists);
  If AlreadyExists Then
  Begin
    params := '';
    If ParamCount > 0 Then
    Begin
      For C1 := 1 to ParamCountEx(GetCommandLine) Do
        If (ParamStrEx(C1, GetCommandLine) <> '') and
           (ParamStrEx(C1, GetCommandLine)[1] = '/') Then
        Begin
          If params <> '' Then
            IPC.WriteString(params);
          params := ParamStrEx(C1, GetCommandLine);
        End
        else
          params := params + ' ' + ParamStrEx(C1, GetCommandLine);
      If params <> '' Then
        IPC.WriteString(params);
    End
    else
      IPC.WriteString('/show');

    CanExit := TRUE;
    Close;
  End
  else
  Begin
    NoAutoLogin := FALSE;
    CanExit := FALSE;

    TrayIcon.Icon.Assign(Application.Icon);
    TrayIcon.IconVisible := TRUE;
    TrayIcon.Hint := 'Darer';

    LoadLanguageFlags;
    FillLanguageSubitems;

    GetNetworkInterfaces(NetworkInterfaces);

    IPC.OnReceiveString := IPCReceiveString;
    IPC.SignalThread.Start;
                         {
    if IsServiceRunning(nil, 'MpsSvc') then
      AddExceptionToFirewall('Darer Client', SelfExe);
                                                           }
    ProcessParams(GetCommandLine);

    CreateMutex(nil, FALSE, INSTANCE_MUTEX);
  End;
end;

procedure TComponentContainer.ProcessURLParams(const AParams : String);
var
  paramType, paramStr : String;
  minimized           : Boolean;
begin
  DbgLn(Format('TComponentContainer.ProcessURLParams(%s)', [AParams]));

  If MatchStrings('*=*', AParams, FALSE) Then
  Begin
    paramType := LowerCase(Copy(AParams, 1, Pos('=', AParams) - 1));
    paramStr := AParams;
    Delete(paramStr, 1, Pos('=', paramStr));

    If paramType = 'replay' Then
    Begin
      If paramStr <> '' Then
      Begin
        If (ReplayDownloading) and
           (Assigned(FileDownloadWindow)) Then
        Begin
          FileDownloadWindow.Close;
          FreeAndNil(FileDownloadWindow);
        End;

        If not Assigned(FileDownloadWindow) Then
        Begin
          If Copy(paramStr, Length(paramStr), 1) = '/' Then
            Delete(paramStr, Length(paramStr), 1);

          minimized := IsMinimized(Application.Handle);
          ShowClient;
          ReplayDownloading := TRUE;
          Case OpenReplayEx(paramStr) of
            0 : ;
            1 : skinMsgBox.MessageDlg(RS_WARCRAFT_REPLAY_NOT_ASSOCIATED, mtError, [mbOk], 0);
            2 : skinMsgBox.MessageDlg(RS_STARCRAFT_REPLAY_NOT_ASSOCIATED, mtError, [mbOk], 0);
          End;
          ReplayDownloading := FALSE;
          If minimized Then
            HideClient;
        End;
      End;
    End;
  End;
end;

procedure TComponentContainer.ProcessParams(AParams : String);
var
  C1     : Integer;
  params : String;
begin
  For C1 := 1 to ParamCountEx(AParams) Do
    If (ParamStrEx(C1, AParams) <> '') and
       (ParamStrEx(C1, AParams)[1] = '/') Then
    Begin
      If params <> '' Then
        ProcessParam(params, FALSE);
      params := ParamStrEx(C1, AParams);
    End
    else
      params := params + ' ' + ParamStrEx(C1, AParams);

  ProcessParam(params, FALSE);
end;

procedure TComponentContainer.ProcessParam(const AParam : String; const AIPC : Boolean);
var
  tmp : String;
begin
  If AParam = '/hide' Then
    timerHide.Enabled := TRUE;

  If AParam = '/show' Then
    ComponentContainer.ShowClient;

  {$IFDEF DEBUGSWITCH}
  If AParam = '/debug' Then
    Debug := TRUE;
  {$ENDIF}

  If MatchStrings('/replay *', AParam, TRUE) Then
  Begin
    If (ReplayDownloading) and
       (Assigned(FileDownloadWindow)) Then
    Begin
      FileDownloadWindow.Close;
      FreeAndNil(FileDownloadWindow);
    End;

    tmp := AParam;
    Delete(tmp, 1, Pos(' ', tmp));
    ShowClient;
    ReplayDownloading := TRUE;
    Case OpenReplayEx(tmp) of
      0 : ;
      1 : skinMsgBox.MessageDlg(RS_WARCRAFT_REPLAY_NOT_ASSOCIATED, mtError, [mbOk], 0);
      2 : skinMsgBox.MessageDlg(RS_STARCRAFT_REPLAY_NOT_ASSOCIATED, mtError, [mbOk], 0);
    End;
    ReplayDownloading := FALSE;
  End;

  If MatchStrings('/urlprotocol darer://*', AParam, TRUE) Then
  Begin
    tmp := AParam;
    Delete(tmp, 1, Pos('://', tmp) + 2);
    ProcessURLParams(tmp);
  End;

  If AParam = '/close' Then
  Begin
    If not AIPC Then
    Begin
      ComponentContainer.CanExit := TRUE;
      ComponentContainer.Close;
    End;
  End;

  If MatchStrings('/login * *', AParam, TRUE) Then
  Begin
    LoginSwitch := TRUE;
    tmp := AParam;
    Delete(tmp, 1, Pos(' ', tmp));
    LoginUsername := Copy(tmp, 1, Pos(' ', tmp) - 1);
    Delete(tmp, 1, Pos(' ', tmp));
    LoginPassword := tmp;
  End;
end;

procedure TComponentContainer.IPCReceiveString(const AString : String);
begin
  ProcessParam(AString, TRUE);
end;

procedure TComponentContainer.DataModuleDestroy(Sender: TObject);
begin
  DbgLn('TComponentContainer.DataModuleDestroy()');

  SaveSettings;

  TrayIcon.Free;

  If Assigned(Localizer) Then
    Localizer.Free;

  If Assigned(IPC) Then
    IPC.Free;
end;

procedure TComponentContainer.ShowClient;
begin
  DbgLn('TComponentContainer.ShowClient()');

  Application.Restore;
  Application.BringToFront;
  TrayIcon.ShowMainForm;
                           {
  SendMessage(Application.Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
  SetForegroundWindow(Application.Handle);

  ShowWindow(Application.Handle, SW_SHOW);
  If Assigned(MainWindow) Then
    ShowWindow(MainWindow.Handle, SW_SHOW);}
end;

procedure TComponentContainer.timerHideTimer(Sender: TObject);
begin
  HideClient;
  HideSwitch := TRUE;
  timerHide.Enabled := FALSE;
end;

procedure TComponentContainer.HideClient;
begin
  DbgLn('TComponentContainer.HideClient()');

  Application.Minimize;
  TrayIcon.HideMainForm;
  TrayIcon.HideTaskbarIcon;
end;

procedure TComponentContainer.httpErrorReporterRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  response : TStringStream;
begin
  response := TStringStream.Create;
  If ErrCode <> 0 Then
  Begin
  End
  else
  Begin
    If THTTPCli(Sender).StatusCode <> 200 Then
    Begin
    End
    else
    Begin
      If THTTPCli(Sender).RcvdCount > 0 Then
      Begin
        response.LoadFromStream(THTTPCli(Sender).RcvdStream);
        ShowMessage(response.DataString);
      End;
    End;
  End;
end;

procedure TComponentContainer.TrayIconClick(Sender: TObject);
begin
  DbgLn('TComponentContainer.TrayIconClick()');

  ShowClient;
end;

procedure TComponentContainer.TrayIconMinimizeToTray(Sender: TObject);
begin
  TrayIcon.HideTaskbarIcon;
end;

procedure TComponentContainer.pmTrayExitClick(Sender: TObject);
begin
  DbgLn('TComponentContainer.pmTrayExitClick()');

  CanExit := TRUE;
  Close;
end;

function TComponentContainer.CanClose : Boolean;
begin
  DbgLn('TComponentContainer.CanClose()');

  result := CanExit;
end;

procedure TComponentContainer.Logout;
begin
  DbgLn('TComponentContainer.Logout()');

  If Assigned(SettingsWindow) Then
    SettingsWindow.SetFocus
  else
  Begin
    NoAutoLogin := TRUE;
    If not Assigned(LoginWindow) Then
      Application.CreateForm(TLoginWindow, LoginWindow);
    SetAsMainForm(LoginWindow);

    If Assigned(MainWindow) Then
    Begin
      MainWindow.CloseForm;
      MainWindow.Close;
      FreeAndNil(MainWindow);
    End;

    LoginWindow.Show;
    ShowClient;
  End;
end;

function TComponentContainer.LogoutAndUpdate : Boolean;
begin
  DbgLn('TComponentContainer.LogoutAndUpdate()');

  If Assigned(SettingsWindow) Then
    result := FALSE
  else
  Begin
    If not Assigned(LoginWindow) Then
      Application.CreateForm(TLoginWindow, LoginWindow);
    SetAsMainForm(LoginWindow);

    LoginWindow.frLogin.ebUsername.Text := MainWindow.UserData.EMail;
    LoginWindow.frLogin.ebPassword.Text := MainWindow.UserData.Password;

    If Assigned(MainWindow) Then
    Begin
      MainWindow.CloseForm;
      MainWindow.Close;
      FreeAndNil(MainWindow);
    End;

    AutoUpdateSwitch := TRUE;
    AutoUpdateParams := Format('/login %s %s /hide', [LoginWindow.frLogin.ebUsername.Text, LoginWindow.frLogin.ebPassword.Text]);
    LoginWindow.frLogin.btLogin.OnClick(LoginWindow);
    result := TRUE;
  End;
end;

procedure TComponentContainer.pmTrayLogoutClick(Sender: TObject);
begin
  DbgLn('TComponentContainer.pmTrayLogoutClick()');

  TrayIcon.PopupMenu := nil;
  Logout;
  TrayIcon.PopupMenu := pmTray;
end;

procedure TComponentContainer.pmTraySettingsClick(Sender: TObject);
begin
  DbgLn('TComponentContainer.pmTraySettingsClick()');

  If not Assigned(SettingsWindow) Then
  Begin
    Application.CreateForm(TSettingsWindow, SettingsWindow);
    SettingsWindow.ShowModal;
    FreeAndNil(SettingsWindow);
    LoadSettings;
  End;
end;

procedure TComponentContainer.FillLanguageSubitems;
var
  C1       : Integer;
  item     : TMenuItem;
  langInfo : TLanguageInfo;
  index    : Integer;
begin
  DbgLn('TComponentContainer.FillLanguageSubitems()');

  pmTrayLanguage.Clear;
  For C1 := 0 to Localizer.LanguageList.Count - 1 Do
  Begin
    langInfo := Localizer.GetLanguageInfo(Localizer.LanguageList[C1]);

    item := TMenuItem.Create(pmTrayLanguage);
    item.AutoHotkeys := maManual;
    item.Caption := langInfo.LocalName;

    index := FindCountryIndex(langInfo.CountryCode);
    If index in [Low(COUNTRY_LIST)..High(COUNTRY_LIST)] Then
      item.ImageIndex := FindImage(ilGlyphs16, Format('imgFlag%s', [COUNTRY_LIST[index].Code]));
    item.RadioItem := TRUE;
    item.GroupIndex := 1;
    If LowerCase(Localizer.LanguageFile) = LowerCase(Localizer.LanguageList[C1]) Then
    Begin
      item.Default := TRUE;
      pmTrayLanguage.ImageIndex := item.ImageIndex;
    End;
    item.OnClick := pmLanguageSubitemClick;
    pmTrayLanguage.Add(item);
  End;

  AddDummyImage(ilGlyphs16);
end;

procedure TComponentContainer.LoadLanguageFlags;
var
  C1       : Integer;
  index    : Integer;
  langInfo : TLanguageInfo;
begin
  For C1 := 0 to Localizer.LanguageList.Count - 1 Do
  Begin
    langInfo := Localizer.GetLanguageInfo(Localizer.LanguageList[C1]);
    index := FindCountryIndex(langInfo.CountryCode);
    If index in [Low(COUNTRY_LIST)..High(COUNTRY_LIST)] Then
      CopyImage(ilFlags, FindImage(ilFlags, COUNTRY_LIST[index].Name), ilGlyphs16, Format('imgFlag%s', [langInfo.CountryCode]));
  End;
end;

procedure TComponentContainer.ChangeLanguage(const ALanguage : String);
var
  index, C1 : Integer;
begin
  If Localizer.FindLanguageByName(ALanguage, index) then
  Begin
    Options.LanguageFile := Localizer.LanguageList[index];
    Localizer.LanguageFile := Localizer.LanguageList[index];
    For C1 := 0 to pmTrayLanguage.Count - 1 Do
      pmTrayLanguage.Items[C1].Default := pmTrayLanguage.Items[C1].Caption = ALanguage;
    pmTrayLanguage.ImageIndex := FindImage(ilGlyphs16, Format('imgFlag%s', [Localizer.GetLanguageInfo(Options.LanguageFile).CountryCode]));

    if Assigned(SettingsWindow) then
      SettingsWindow.SelectComboboxLanguage;

    Relocalize;
  End;
end;

procedure TComponentContainer.pmLanguageSubitemClick(Sender: TObject);
begin
  DbgLn('TComponentContainer.pmLanguageSubitemClick()');

  ChangeLanguage(TMenuItem(Sender).Caption);
end;

procedure TComponentContainer.Relocalize;
var
  C1        : Integer;
  formiface : ILocalizationChanged;
begin
  DbgLn('TComponentContainer.Relocalize()');

  Localizer.Localize(self);

  For C1 := 0 to Screen.FormCount - 1 Do
    If Supports(Screen.Forms[C1], ILocalizationChanged, formiface) Then
      ComponentContainer.Localizer.Localize(Screen.Forms[C1]);
end;

procedure TComponentContainer.Close;
begin
  If Assigned(Application.MainForm) Then
    Application.MainForm.Close
  else
    Application.Terminate;
end;

procedure TComponentContainer.ApplyLocalizationChange;
begin
  Localizer.LocalizeResourceStrings;
end;

end.



