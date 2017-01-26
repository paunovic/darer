unit ComponentModule;

interface

uses
  SysUtils, Classes, SkinData, JvComponentBase, JvAppStorage,
  JvAppIniStorage, GProxy, CoolTrayIcon, spTrayIcon, Menus, SkinMenus,
  TntMenus, spMessages, ImgList, sppngimagelist, DB, JvThread,
  OverbyteIcsWndControl, OverbyteIcsWSocket, Controls, Graphics,
  JvImageList, SkinBoxCtrls, SkinExCtrls;

type
  TComponentModuleWindow = class(TDataModule)
    sppMain: TspSkinData;
    sppLogin: TspSkinData;
    Settings: TJvAppIniFileStorage;
    TrayIcon: TCoolTrayIcon;
    spMessage: TspSkinMessage;
    ilLoginLogo: TspPngImageList;
    pmTray: TTntPopupMenu;
    pmShowClient: TTntMenuItem;
    N2: TTntMenuItem;
    pmLogout: TTntMenuItem;
    pmExit: TTntMenuItem;
    pmLanguage: TTntMenuItem;
    N1: TTntMenuItem;
    ilFlags: TspPngImageList;
    thdFlags: TJvThread;
    pvpgnUDPClient: TWSocket;
    pvpgnUDPServer: TWSocket;
    tcpServer: TWSocket;
    tcpClient: TWSocket;
    spsMain: TspCompressedStoredSkin;
    spsLogin: TspCompressedStoredSkin;
    ilUserInfo: TspPngImageList;
    ilTrayIcons: TJvImageList;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
    procedure TerminateProxy;
    procedure pmShowClientClick(Sender: TObject);
    procedure pmLogoutClick(Sender: TObject);
    procedure pmExitClick(Sender: TObject);
    function TryLogout : Boolean;
    function FindCountryImage(const ACountry : String) : Integer;
    procedure thdFlagsExecute(Sender: TObject; Params: Pointer);
    procedure thdFlagsFinish(Sender: TObject);
    procedure FillGameLanguages(const AComboBox : TspSkinComboBox);
  private
  public
    GProxy : TGProxy;
  end;

var
  ComponentModuleWindow: TComponentModuleWindow;

implementation

{$R *.dfm}

uses
  Windows, Forms, MainWin, LoginWin, SharedData, Localization, Dialogs,
  OptionsWin, ContactWin, Misc, TutorialWin, CommandsWin, WinSock, SkinEngine,
  FriendRequestWin, SharedVars;

procedure TComponentModuleWindow.DataModuleCreate(Sender: TObject);
begin
  ForceDirectories(ExtractFilePath(Settings.FullFileName));
  LoadSettings;
  LoadSkin(Options.Customize.Skin, sppLogin, sppMain, spsLogin, spsMain);
  thdFlags.Execute(nil);
end;

procedure TComponentModuleWindow.DataModuleDestroy(Sender: TObject);
begin
  Settings.WriteString('client\language', GetLanguage.Name);
  SaveSettings;

  TrayIcon.Free;
  GProxy.Free;

  SysUtils.DeleteFile('login.dsk');
  SysUtils.DeleteFile('main.dsk');

  thdFlags.TerminateWaitFor;
end;

procedure TComponentModuleWindow.TrayIconClick(Sender: TObject);
begin
  Application.Restore;
  Application.BringToFront;
  TrayIcon.ShowMainForm;
  Application.MainForm.Show;
end;

procedure TComponentModuleWindow.pmShowClientClick(Sender: TObject);
begin
  TrayIconClick(Sender);
end;

procedure TComponentModuleWindow.TerminateProxy;
begin
  While not GProxy.Terminated Do
    GProxy.Terminate;
end;

function TComponentModuleWindow.TryLogout : Boolean;

  procedure CloseMainWindow;
  begin
    SetAsMainForm(LoginWindow);
    MainWindow.Close;
    MainWindow := nil;
  end;

var
  canexit : Boolean;
begin
  If Assigned(MainWindow) Then
  Begin
    canexit := not ((Assigned(MainWindow)) and
                    (MainWindow.Ingame) and
                    (ComponentModuleWindow.spMessage.MessageDlg2(RS_LOGOUT_INGAME_TEXT, RS_LOGOUT_INGAME_CAPTION, mtInformation, [mbOk], 0) = mrOk));

    If canexit Then
    Begin
      MainWindow.MinimizeOnClose := FALSE;
      If MainWindow.CanClose Then
      Begin
        CloseMainWindow;
        TerminateProxy;
        result := TRUE;
      End
      else
      Begin
        If Assigned(OptionsWindow) Then
        Begin
          OptionsWindow.Close;
          OptionsWindow := nil;
        End;

        If Assigned(TutorialWindow) Then
        Begin
          TutorialWindow.Close;
          TutorialWindow := nil;
        End;

        If Assigned(ContactWindow) Then
        Begin
          ContactWindow.Close;
          ContactWindow := nil;
        End;

        If Assigned(CommandsWindow) Then
        Begin
          CommandsWindow.Close;
          CommandsWindow := nil;
        End;

        If Assigned(FriendRequestWindow) Then
        Begin
          FriendRequestWindow.Close;
          FriendRequestWindow := nil;
        End;

        If MainWindow.CanClose Then
        Begin
          CloseMainWindow;
          TerminateProxy;
          result := TRUE;
        End
        else
        Begin
          MainWindow.MinimizeOnClose := TRUE;
          result := FALSE;
        End;
      End;
    End
    else
      result := FALSE;
  End
  else
  Begin
    TerminateProxy;
    result := TRUE;
  End;

  If result Then
  Begin
    Users.Count := 0;
    SetLength(Users.Items, Users.Count);

    ProtectedChannels.Count := 0;
    SetLength(ProtectedChannels.Items, ProtectedChannels.Count);
    
    Blocklist.Clear;
  End;
end;

procedure TComponentModuleWindow.pmLogoutClick(Sender: TObject);
begin
  If TryLogout Then
  Begin
    pmLogout.Visible := FALSE;

    If Application.MainForm <> LoginWindow Then
      SetAsMainForm(LoginWindow);
    LoginWindow.Show;
  End;
end;

procedure TComponentModuleWindow.pmExitClick(Sender: TObject);
var
  canexit : Boolean;
begin
  canexit := not ((Assigned(MainWindow)) and
                  (MainWindow.Ingame) and
                  (ComponentModuleWindow.spMessage.MessageDlg2(RS_EXIT_INGAME_TEXT, RS_EXIT_INGAME_CAPTION, mtInformation, [mbOk], 0) = mrOk));

  If canexit Then
  Begin
  //  If ComponentModuleWindow.spMessage.MessageDlg2(EXIT_DARER_TEXT, EXIT_DARER_CAPTION, mtConfirmation, [mbYes, mbNo], 0) = mrYes Then
    TerminateProxy;

    If Assigned(MainWindow) Then
      MainWindow.SaveSettings;

    Free;
    ExitProcess(0);
  End;  
end;

function TComponentModuleWindow.FindCountryImage(const ACountry : String) : Integer;
var
  C1 : Integer;
begin
  result := 0;
  For C1 := 0 to ilFlags.PngImages.Count - 1 Do
    If ilFlags.PngImages[C1].Name = 'imgFlag' + ACountry Then
    Begin
      result := C1;
      Break;
    End;
end;

procedure TComponentModuleWindow.thdFlagsExecute(Sender: TObject; Params: Pointer);
var
  C1      : Integer;
  resName : String;
  resId   : Integer;
  index   : Integer;
begin
  ilFlags.PngImages.Clear;

  For C1 := 0 to COUNTRY_LIST_COUNT - 1 Do
  Begin
    index := ilFlags.PngImages.Add.Index;

    ilFlags.PngImages[index].Name := 'imgFlag' + COUNTRY_LIST[C1].Code;

    resName := StringReplace(COUNTRY_LIST[C1].Name, ' ', '_', [rfReplaceAll]);
    resId := FindResource(HInstance, PChar(resName), RT_RCDATA);
    If resId <> 0 Then
    Begin
      ilFlags.PngImages[index].PngImage.Canvas.Lock;
      try
        ilFlags.PngImages[index].PngImage.LoadFromResourceName(HInstance, resName);
      finally
        ilFlags.PngImages[index].PngImage.Canvas.Unlock;
      end;
    End;

    If thdFlags.Terminated Then
      Break;
  End;
end;

procedure TComponentModuleWindow.thdFlagsFinish(Sender: TObject);
begin
  If Assigned(LoginWindow) Then
  Begin
    LoginWindow.frRegister.PopulateCountryList;
    LoginWindow.PopulateLanguageFlags;
  End;
end;

procedure TComponentModuleWindow.FillGameLanguages(const AComboBox : TspSkinComboBox);
begin
  AComboBox.Items.Clear;
  AComboBox.Items.Add(RS_GAME_LANGUAGE_ENGLISH);
  AComboBox.Items.Add(RS_GAME_LANGUAGE_RUSSIAN);
  AComboBox.Items.Add(RS_GAME_LANGUAGE_CHINESE_TRAD);
end;

end.
