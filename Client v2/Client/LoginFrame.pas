{$I ..\defines.inc}

unit LoginFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SkinCtrls, SkinBoxCtrls, StdCtrls, Mask, SkinExCtrls,
  sppngimagelist, DynamicSkinForm, spSkinShellCtrls, ExtCtrls, ImgList, GProxy,
  OverbyteIcsWndControl, OverbyteIcsHttpProt, OverbyteIcsUrl, JvExControls,
  JvAnimatedImage, JvGIFCtrl;

type
  TfrLogin = class(TFrame)
    lbEmail: TspSkinShadowLabel;
    ebUsername: TspSkinEdit;
    lbPassword: TspSkinShadowLabel;
    ebPassword: TspSkinPasswordEdit;
    lbServer: TspSkinShadowLabel;
    cbServer: TspSkinComboBox;
    lbStatus: TspSkinShadowLabel;
    btLogin: TspSkinButton;
    btRegister: TspSkinButton;
    tiStatus: TTimer;
    SkinFrame: TspSkinFrame;
    imLogo: TspPngImageView;
    chbRemember: TspSkinCheckRadioBox;
    chbAutoLogin: TspSkinCheckRadioBox;
    httpUserDetails: THttpCli;
    gifImage: TJvGIFAnimator;
    tiLoginTimeout: TTimer;
    httpLogin: THttpCli;
    procedure OnBNetConnect(ASender : TGProxy);
    procedure OnInvalidPassword(ASender : TGProxy);
    procedure OnInvalidUsername(ASender : TGProxy);
    procedure OnNonCommand(ASender : TGProxy; const APrefix, ALine : WideString);
    procedure SetStatus(const AText : String; const ATimeout : Integer = -1; const AColor : TColor = $00BFBAAE);
    procedure Login;
    procedure tiStatusTimer(Sender: TObject);
    procedure SaveUserData;
    procedure LoadUserData;
    procedure DeleteUserData;
    procedure httpUserDetailsRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure httpUserDetailsSocksError(Sender: TObject; Error: Integer; Msg: String);
    procedure ShowLoginAnimation(const AShow : Boolean);
    procedure tiLoginTimeoutTimer(Sender: TObject);
    function CheckForVersion : Boolean;
    procedure httpLoginRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
  private
  public
  end;

implementation

{$R *.dfm}

uses
  ComponentModule, superobject, SharedData, MainWin, DCPblowfish, DCPsha1,
  LoginWin, Localization, P2P, Misc, GameRepairWin, SharedVars,
  UpdateFrame;

procedure TfrLogin.SetStatus(const AText : String; const ATimeout : Integer = -1; const AColor : TColor = $00BFBAAE);
begin
  lbStatus.Font.Color := AColor;
  lbStatus.Caption := AText;
  lbStatus.Show;

  If ATimeout <> -1 Then
  Begin
    If ATimeout = 0 Then
      tiStatus.Interval := (Length(lbStatus.Caption) div 8 + 1) * 1000
    else
      tiStatus.Interval := ATimeout;

    tiStatus.OnTimer := tiStatusTimer;

    tiStatus.Enabled := FALSE;
    tiStatus.Enabled := TRUE;
  End
  else
    tiStatus.Enabled := FALSE;
end;

procedure TfrLogin.Login;
begin
  If IsValidEmail(ebUsername.Text) Then
  Begin
    ShowLoginAnimation(TRUE);

    SetStatus(RS_LOGIN_CONNECTING, -1);
    Application.ProcessMessages;

    ZeroMemory(@UserDetails, SizeOf(TUserDetails));
    httpPostRequest(httpLogin, URL_API + 'login', Format('username=%s&password=%s', [ebUsername.Text, Trim(ebPassword.Text)]));
  End
  else
  Begin
    SetStatus(RS_INVALID_EMAIL, 0, clRed);
    ebUsername.SetFocus;
  End;
end;

procedure TfrLogin.OnBNetConnect(ASender : TGProxy);
begin
  SetStatus(Format(RS_LOGGED_IN, [UserDetails.Username]), -1, $00FF9933);
  Application.ProcessMessages;

  tiLoginTimeout.Enabled := FALSE;

  ComponentModuleWindow.pmLogout.Visible := TRUE;

  If Assigned(MainWindow) Then
    FreeAndNil(MainWindow);
                             
  If Assigned(ASender) Then
  Begin
    TGProxy(ASender).OnBNetConnect := nil;
    TGProxy(ASender).OnBNetInvalidPassword := nil;
    TGProxy(ASender).OnBNetInvalidUsername := nil;
    TGProxy(ASender).OnNonCommand := nil;
  End;

  TGProxy(ASender).Send('upfr');
{
  ComponentModuleWindow.tcpServer.Port  := IntToStr(P2P_TCP_PORT);
  ComponentModuleWindow.tcpServer.Proto := 'tcp';
  ComponentModuleWindow.tcpServer.Addr  := '0.0.0.0';
  ComponentModuleWindow.tcpServer.OnDataAvailable := MainWindow.tcpServerDataAvailable;
  ComponentModuleWindow.tcpServer.Listen;
}
  If not chbRemember.Checked Then
    ebPassword.Text := '';

  Application.CreateForm(TMainWindow, MainWindow);
  SetAsMainForm(MainWindow);
  MainWindow.Show;

  lbStatus.Hide;
  LoginWindow.Hide;

  MainWindow.SetFocus;

  ShowLoginAnimation(FALSE);
end;

procedure TfrLogin.OnInvalidPassword(ASender : TGProxy);
begin
  SetStatus(RS_INVALID_PASSWORD, 0, clRed);
  ComponentModuleWindow.GProxy.OnNonCommand := nil;
  While not ComponentModuleWindow.GProxy.Terminated Do
    ComponentModuleWindow.GProxy.Terminate;
  ShowLoginAnimation(FALSE);
  ebPassword.SetFocus;
end;

procedure TfrLogin.OnInvalidUsername(ASender : TGProxy);
begin
  SetStatus(RS_INVALID_USERNAME, 0, clRed);
  ComponentModuleWindow.GProxy.OnNonCommand := nil;
  While not ComponentModuleWindow.GProxy.Terminated Do
    ComponentModuleWindow.GProxy.Terminate;
  ShowLoginAnimation(FALSE);
  ebUsername.SetFocus;
end;

procedure TfrLogin.OnNonCommand(ASender : TGProxy; const APrefix, ALine : WideString);
begin
//  SetStatus(ALine, 0);
end;

procedure TfrLogin.tiStatusTimer(Sender: TObject);
begin
  lbStatus.Hide;
  tiStatus.Enabled := FALSE;
end;

procedure TfrLogin.SaveUserData;
var
  blowfish : TDCP_blowfish;
begin
  blowfish := TDCP_blowfish.Create(nil);
  blowfish.InitStr(CRYPT_PASS, TDCP_sha1);
  ComponentModuleWindow.Settings.WriteString('login\email', blowfish.EncryptString(ebUsername.Text));
  ComponentModuleWindow.Settings.WriteString('login\password', blowfish.EncryptString(ebPassword.Text));
  ComponentModuleWindow.Settings.WriteInteger('login\server', cbServer.ItemIndex);
  blowfish.Burn;
  blowfish.Free;
end;

procedure TfrLogin.LoadUserData;
var
  blowfish : TDCP_blowfish;
begin
  blowfish := TDCP_blowfish.Create(nil);
  blowfish.InitStr(CRYPT_PASS, TDCP_sha1);
  ebUsername.Text := blowfish.DecryptString(ComponentModuleWindow.Settings.ReadString('login\email', ''));
  ebPassword.Text := blowfish.DecryptString(ComponentModuleWindow.Settings.ReadString('login\password', ''));
  cbServer.ItemIndex := ComponentModuleWindow.Settings.ReadInteger('login\server');
  blowfish.Burn;
  blowfish.Free;
end;

procedure TfrLogin.DeleteUserData;
begin
  ComponentModuleWindow.Settings.DeleteValue('login\password');
end;

function TfrLogin.CheckForVersion : Boolean;
begin
  result := TRUE;

  If (ClientSettings.CurrentVersion <> 'DISABLED') and
     (ClientSettings.CurrentVersion <> '') and
     (ClientSettings.CurrentVersion <> CLIENT_VERSION) Then
  Begin
    SetStatus(RS_CLIENT_UPDATING, -1);

    LoginWindow.frUpdate.gaugeUpdateProgress.Value := 0;
    LoginWindow.frUpdate.lbStatus.Caption := '';
    Hide;
    LoginWindow.frUpdate.Show;
    LoginWindow.frUpdate.DoUpdate;
    result := FALSE;
  End;

  {$IFDEF GPROXY_CHECK}
  If (result) and
     (ClientSettings.GProxyHash <> 'DISABLED') and
     (ClientSettings.GProxyHash <> '') and
     (md5File(SelfPath + GPROXY_EXE) <> ClientSettings.GProxyHash) Then
  Begin
    SetStatus(RS_CLIENT_UPDATING, -1);

    LoginWindow.frUpdate.gaugeUpdateProgress.Value := 0;
    LoginWindow.frUpdate.lbStatus.Caption := '';
    Hide;
    LoginWindow.frUpdate.Show;
    LoginWindow.frUpdate.DoGProxyUpdate;
    While LoginWindow.frUpdate.Updating Do
      Sleep(1);
    Show;
    result := TRUE;
  End;
  {$ENDIF}
end;

procedure TfrLogin.httpUserDetailsRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  JSON            : ISuperObject;
  InvalidUsername : Boolean;
  server          : String;
  res             : Integer;
  response        : WideString;
  loggedin        : Boolean;
  respType        : Char;
  respCode        : Integer;
begin
  loggedin := FALSE;

  If ErrCode <> 0 Then
    SetStatus(SysErrorMessage(ErrCode), 0, clRed)
  else
  Begin
    If THTTPCli(Sender).StatusCode <> 200 Then
      SetStatus(Format('[%d] %s', [THTTPCli(Sender).StatusCode, THTTPCli(Sender).ReasonPhrase]), 0, clRed)
    else
    Begin
      If THTTPCli(Sender).RcvdCount > 0 Then
      Begin
        THTTPCli(Sender).RcvdStream.Position := 0;
        JSON := TSuperObject.ParseStream(THTTPCli(Sender).RcvdStream, FALSE);
        response := JSON.S['result'];
        JSON := nil;

        Users.Count := 0;
        SetLength(Users.Items, Users.Count);
        SetLength(Users.Avatar, Users.Count);

        If not ParseResponse(response, respType, respCode) Then
          ParseMyDetails(response);

        If CheckForVersion Then
        Begin
          If (UserDetails.Username <> '') and
             (UserDetails.Username <> '0') Then
          Begin
            InvalidUsername := FALSE;

            Case cbServer.ItemIndex of
              0 : server := 'bnet.eu.darer.com';
              1 : server := 'bnet.sg.darer.com';
            End;

            SetStatus(RS_STARTING_GPROXY, -1);
            Application.ProcessMessages;

            ComponentModuleWindow.GProxy.CreateConfig;
            ComponentModuleWindow.GProxy.WriteString('server', server);

            ComponentModuleWindow.GProxy.WriteString('channel', UserDetails.NativeChannel);
            ComponentModuleWindow.GProxy.WriteString('username', UserDetails.Username);
            ComponentModuleWindow.GProxy.WriteString('password', ebPassword.Text);

            While not ComponentModuleWindow.GProxy.Terminated Do
              ComponentModuleWindow.GProxy.Terminate;
            res := ComponentModuleWindow.GProxy.Start;
            If res <> ERROR_SUCCESS Then
              SetStatus(Format(RS_GPROXY_START_ERROR, [SysErrorMessage(res)]), 0, clRed)
            else
            Begin
              SetStatus(RS_AUTHENTICATING, -1);

              UserDetails.Password := ebPassword.Text;

              ComponentModuleWindow.GProxy.OnBNetConnect := OnBNetConnect;
              ComponentModuleWindow.GProxy.OnBNetInvalidPassword := OnInvalidPassword;
              ComponentModuleWindow.GProxy.OnBNetInvalidUsername := OnInvalidUsername;
              ComponentModuleWindow.GProxy.OnNonCommand := OnNonCommand;

              loggedin := TRUE;
            End;
          End
          else
            InvalidUsername := TRUE;
            
          If InvalidUsername Then
          Begin
            SetStatus(RS_CANNOT_RETRIEVE_USERNAME, 0, clRed);
            ShowLoginAnimation(FALSE);
            ebUsername.SetFocus;
          End;
        End;
      End;
    End;
  End;

  httpFree(THTTPCli(Sender));
  
  If (not loggedin) and
     (not LoginWindow.frUpdate.Updating) Then
  Begin
    If Assigned(MainWindow) Then
      FreeAndNil(MainWindow);
    ShowLoginAnimation(FALSE);
  End;
end;

procedure TfrLogin.ShowLoginAnimation(const AShow : Boolean);
begin
  btLogin.Visible := not AShow;
  btRegister.Visible := not AShow;
  cbServer.Visible := not AShow;
  lbServer.Visible := not AShow;
  chbRemember.Visible := not AShow;
  chbAutoLogin.Visible := not AShow;
  ebPassword.Visible := not AShow;
  lbPassword.Visible := not AShow;
  ebUsername.Visible := not AShow;
  lbEmail.Visible := not AShow;
  gifImage.FrameIndex := 0;
  gifImage.Visible := AShow;
end;

procedure TfrLogin.httpUserDetailsSocksError(Sender: TObject; Error: Integer; Msg: String);
begin
  SetStatus(Format('[%d] %s', [Error, Msg]), -1, clRed);
  THTTPCli(Sender).Close;
  ShowLoginAnimation(FALSE);
end;

procedure TfrLogin.tiLoginTimeoutTimer(Sender: TObject);
begin
  SetStatus('');
  ComponentModuleWindow.GProxy.OnNonCommand := nil;
  While not ComponentModuleWindow.GProxy.Terminated Do
    ComponentModuleWindow.GProxy.Terminate;
  ShowLoginAnimation(FALSE);
  If httpUserDetails.State <> httpReady Then
    httpUserDetails.Close;
  ebUsername.SetFocus;
  tiLoginTimeout.Enabled := FALSE;
end;

procedure TfrLogin.httpLoginRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  JSON     : ISuperObject;
  response : WideString;
  respType : Char;
  respCode : Integer;
begin
  If ErrCode <> 0 Then
    SetStatus(SysErrorMessage(ErrCode), 0, clRed)
  else
  Begin
    If THTTPCli(Sender).StatusCode <> 200 Then
      SetStatus(Format('[%d] %s', [THTTPCli(Sender).StatusCode, THTTPCli(Sender).ReasonPhrase]), 0, clRed)
    else
    Begin
      If THTTPCli(Sender).RcvdCount > 0 Then
      Begin
        THTTPCli(Sender).RcvdStream.Position := 0;
        JSON := TSuperObject.ParseStream(THTTPCli(Sender).RcvdStream, FALSE);
        response := JSON.S['result'];

        If not ParseResponse(response, respType, respCode) Then
        Begin
          JSON := TSuperObject.ParseString(Addr(response[1]), FALSE);
          UserDetails.Key := JSON.S['key'];
          Case cbServer.ItemIndex of
            0 : UserDetails.Server := 'EU';
            1 : UserDetails.Server := 'SG';
          End;
          httpPostRequest(httpUserDetails, URL_API + 'getUserDetails', Format('key=%s&server=%s&mess_no=4&notif_no=4', [UserDetails.Key, UserDetails.Server]));
        End
        else
        Begin
          SetStatus(TranslateResponse(respType, respCode), 0, clRed);
          ShowLoginAnimation(FALSE);
          ebUsername.SetFocus;
        End;
        JSON := nil;


      End;
    End;
  End;

  httpFree(THTTPCli(Sender));
end;

end.
