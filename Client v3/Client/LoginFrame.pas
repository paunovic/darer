unit LoginFrame;

interface

{$I defines.inc}

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, SkinBoxCtrls, DynamicSkinForm, ExtCtrls,
  OverbyteIcsWndControl, OverbyteIcsHttpProt, SkinCtrls, SkinExCtrls,
  JvExControls, JvAnimatedImage, JvGIFCtrl, Localization;

type
  TfrLogin = class(TFrame, ILocalizationChanged)
    SkinFrame: TspSkinFrame;
    gifLogin: TJvGIFAnimator;
    paLogin: TspSkinPanel;
    chbRemember: TspSkinCheckRadioBox;
    chbAutoLogin: TspSkinCheckRadioBox;
    ebPassword: TspSkinPasswordEdit;
    lbPassword: TspSkinShadowLabel;
    ebUsername: TspSkinEdit;
    lbEmail: TspSkinShadowLabel;
    btLogin: TspSkinButton;
    lbStatus: TspSkinShadowLabel;
    btRegister: TspSkinButton;
    httpLogin: THttpCli;
    tiStatus: TTimer;
    httpUpdateCheck: THttpCli;
    procedure btLoginClick(Sender: TObject);
    procedure btRegisterClick(Sender: TObject);
    procedure httpLoginRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure httpLoginSocksError(Sender: TObject; Error: Integer; Msg: String);
    procedure tiStatusTimer(Sender: TObject);
    function DoLogin(const AUsername, AID : String) : Boolean;
    procedure httpUpdateCheckRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
  private
    procedure SetStatus(const AText : String; const ATimeout : Integer = -1; const AColor : TColor = $00BFBAAE);
  public
    LoggingIn : Boolean;

    procedure ApplyLocalizationChange;
    procedure ShowLoginFrame(const AValue : Boolean);
  end;

implementation

{$R *.dfm}

uses
  ComponentContainerUnit, SharedFunctions, SharedVars, SuperObject, LocalizationStr,
  MainWin, LoginWin;

procedure TfrLogin.SetStatus(const AText : String; const ATimeout : Integer = -1; const AColor : TColor = $00BFBAAE);
begin
  lbStatus.Font.Color := AColor;
  lbStatus.Caption := AText;
  lbStatus.Show;
  lbStatus.Refresh;

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

procedure TfrLogin.ApplyLocalizationChange;
var
  font      : TFont;
  textWidth : Integer;
begin
  font := TFont.Create;
  font.Name := chbAutoLogin.FontName;
  font.Style := chbAutoLogin.FontStyle;
  font.Height := chbAutoLogin.FontHeight;
  font.Color := chbAutoLogin.FontColor;
  textWidth := GetTextWidth(chbAutoLogin.Caption, font);
  font.Free;
  chbAutoLogin.Left := ebPassword.Left + ebPassword.Width - 25 - textWidth;
  chbAutoLogin.Width := textWidth + 25;
end;

procedure TfrLogin.ShowLoginFrame(const AValue : Boolean);
begin
  DbgLn(Format('TfrLogin.ShowLoginFrame(%s)', [BoolToStr(AValue)]));

  gifLogin.Animate := not AValue;
  gifLogin.FrameIndex := 0;
  gifLogin.Visible := not AValue;
  lbStatus.Visible := not AValue;
  paLogin.Visible := AValue;

  If paLogin.Visible Then
    ebUsername.SetFocus;

  LoggingIn := not AValue;
end;

procedure TfrLogin.btLoginClick(Sender: TObject);
begin
  DbgLn('TSettingsWindow.btLoginClick()');

  ShowLoginFrame(FALSE);

  SetStatus(RS_CHECKING_FOR_UPDATES, -1, clLtGray);

  httpGetRequest(httpUpdateCheck, Format(URL_UPDATECHECK, ['dummy']));
end;

procedure TfrLogin.btRegisterClick(Sender: TObject);
begin
  DbgLn('TSettingsWindow.btRegisterClick()');
{
  Hide;
  LoginWindow.frRegister.Show;
  LoginWindow.frRegister.Reset;
}
  ShellOpen('http://www.darer.com/register');
end;

function TfrLogin.DoLogin(const AUsername, AID : String) : Boolean;
begin
  DbgLn('TfrLogin.DoLogin()');

  If chbRemember.Checked Then
    Options.Password := TrimRight(Encrypt(ebPassword.Text, GetLocalEncryptionKey))
  else
    Options.Password := '';
  Options.Username := ebUsername.Text;
  Options.AutoLogin := chbAutoLogin.Checked;
  SaveSettings;

  If (AUsername <> '') and
     (AID <> '') Then
  Begin
    SetStatus(RS_AUTHENTICATING, -1, clLime);
    Application.CreateForm(TMainWindow, MainWindow);
    SetAsMainForm(MainWindow);
    MainWindow.UserData.EMail := Options.Username;
    MainWindow.UserData.Password := ebPassword.Text;
    MainWindow.UserData.Username := AUsername;
    MainWindow.UserData.ID := AID;
    MainWindow.Show;
    LoggingIn := FALSE;
    LoginWindow.Close;
    FreeAndNil(LoginWindow);
    result := TRUE;
  End
  else
    result := FALSE;
end;

procedure TfrLogin.httpLoginRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  JSON : ISuperObject;
  msg  : String;
begin
  DbgLn(Format('TfrLogin.httpLoginRequestDone(StatusCode=%d, ErrCode=%d)', [THTTPCli(Sender).StatusCode, ErrCode]));

  If ErrCode <> 0 Then
  Begin
    ShowLoginFrame(TRUE);
    SetStatus(SysErrorMessage(ErrCode), 0, clRed)
  End
  else
  Begin
    If THTTPCli(Sender).StatusCode <> 200 Then
    Begin
      ShowLoginFrame(TRUE);
      SetStatus(Format('[%d] %s', [THTTPCli(Sender).StatusCode, THTTPCli(Sender).ReasonPhrase]), 0, clRed)
    End
    else
    Begin
      If THTTPCli(Sender).RcvdCount > 0 Then
      Begin
        THTTPCli(Sender).RcvdStream.Position := 0;
        JSON := TSuperObject.ParseStream(THTTPCli(Sender).RcvdStream, FALSE);
        If not DoLogin(JSON['result'].S['username'], JSON['result'].S['userid']) Then
        Begin
          ShowLoginFrame(TRUE);
          If not TranslateMessage(JSON.S['result'], msg) Then
            msg := JSON.S['result'];

          SetStatus(msg, 0, clRed);
        End;
        JSON := nil;
      End
      else
      Begin
        ShowLoginFrame(TRUE);
        SetStatus(RS_NO_RESPONSE_FROM_SERVER, 0, clRed);
      End;
    End;
  End;

  httpFree(THTTPCli(Sender));
end;

procedure TfrLogin.httpLoginSocksError(Sender: TObject; Error: Integer; Msg: String);
begin
  DbgLn(Format('TfrLogin.httpLoginSocksError(%d, %s)', [Error, Msg]));

  SetStatus(Format('[%d] %s', [Error, Msg]), 0, clRed);
  ShowLoginFrame(TRUE);
end;

procedure TfrLogin.httpUpdateCheckRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  JSON       : ISuperObject;
  jsonItem   : ISuperObject;
  updateItem : PUpdateFileInfo;
  msg        : String;
begin
  DbgLn(Format('TfrLogin.httpUpdateCheckRequestDone(StatusCode=%d, ErrCode=%d)', [THTTPCli(Sender).StatusCode, ErrCode]));

  If ErrCode <> 0 Then
  Begin
    ShowLoginFrame(TRUE);
    SetStatus(SysErrorMessage(ErrCode), 0, clRed)
  End
  else
  Begin
    If THTTPCli(Sender).StatusCode <> 200 Then
    Begin
      ShowLoginFrame(TRUE);
      SetStatus(Format('[%d] %s', [THTTPCli(Sender).StatusCode, THTTPCli(Sender).ReasonPhrase]), 0, clRed)
    End
    else
    Begin
      If THTTPCli(Sender).RcvdCount > 0 Then
      Begin
        THTTPCli(Sender).RcvdStream.Position := 0;
        JSON := TSuperObject.ParseStream(THTTPCli(Sender).RcvdStream, FALSE);

        {$IFDEF DEBUGSWITCH}
        if Debug then
          JSON.SaveTo('debug_updaterequest.txt');
        {$ENDIF}

        If JSON['result'].S['version'] <> '' Then
        Begin
          If JSON['result'].S['version'] = Options.VersionId Then
          Begin
            SetStatus(RS_AUTHENTICATING, -1, clLtGray);
            httpPostRequest(httpLogin, URL_LOGIN, Format('email=%s&password=%s', [ebUsername.Text, ebPassword.Text]));
          End
          else
          Begin
            LoginWindow.frUpdate.UpdateList := TList.Create;

            For jsonItem in JSON['result']['items'] Do
            Begin
              New(updateItem);

              If jsonItem.S['type'] = 'patch' Then
                updateItem^.FileType := ftPatch
              else
                If jsonItem.S['type'] = 'new' Then
                  updateItem^.FileType := ftFile
                else
                Begin
                  Dispose(updateItem);
                  Continue;
                End;

              updateItem^.Path := jsonItem.S['path'];
              updateItem^.Name := jsonItem.S['filename'];
              updateItem^.Hash := jsonItem.S['hash'];
              updateItem^.URL := jsonItem.S['url'];

              LoginWindow.frUpdate.UpdateList.Add(updateItem);
            End;

            LoginWindow.frUpdate.Show;
            LoginWindow.frUpdate.DoUpdate(JSON['result'].S['version']);
          End;
        End
        else
        Begin
          If not TranslateMessage(JSON.S['result'], msg) Then
            msg := JSON.S['result'];

          ShowLoginFrame(TRUE);
          SetStatus(msg, 0, clRed);
        End;
      End
      else
        ShowLoginFrame(TRUE);
    End;
  End;
end;

procedure TfrLogin.tiStatusTimer(Sender: TObject);
begin
  lbStatus.Hide;
  tiStatus.Enabled := FALSE;
end;

end.
