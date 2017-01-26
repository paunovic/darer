unit RegisterFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, SkinBoxCtrls, SkinCtrls, SkinExCtrls, pngimage,
  ExtCtrls, jpeg, DynamicSkinForm, JvComponentBase, JvThread, ImgList,
  PngImageList, OverbyteIcsWndControl, OverbyteIcsHttpProt, JvExControls,
  JvAnimatedImage, JvGIFCtrl, Localization;

type
  TfrRegister = class(TFrame, ILocalizationChanged)
    lbEmail: TspSkinShadowLabel;
    ebEmail: TspSkinEdit;
    lbHeader: TspSkinShadowLabel;
    lbPassword: TspSkinShadowLabel;
    lbPasswordConfirm: TspSkinShadowLabel;
    lbUsername: TspSkinShadowLabel;
    ebUsername: TspSkinEdit;
    lbCountry: TspSkinShadowLabel;
    ebPasswordConfirm: TspSkinPasswordEdit;
    ebPassword: TspSkinPasswordEdit;
    lbCaptcha: TspSkinShadowLabel;
    ebCAPTCHA: TspSkinEdit;
    btCancel: TspSkinButton;
    btRegisterNow: TspSkinButton;
    imgCaptcha: TImage;
    bevelLine: TspSkinBevel;
    SkinFrame: TspSkinFrame;
    httpCaptcha: THttpCli;
    cbCountry: TspSkinComboBoxEx;
    gifLoadingCaptcha: TJvGIFAnimator;
    chbUserLicense: TspSkinCheckRadioBox;
    lbLicenseURL: TspSkinLinkLabel;
    httpRegister: THttpCli;
    lbCAPTCHAError: TspSkinShadowLabel;
    procedure btCancelClick(Sender: TObject);
    procedure btRegisterNowClick(Sender: TObject);
    procedure cbCountryCloseUp(Sender: TObject);
    procedure cbCountryChange(Sender: TObject);
    procedure httpCaptchaRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure lbLicenseURLClick(Sender: TObject);
    procedure httpCaptchaCookie(Sender: TObject; const Data: string; var Accept: Boolean);
    procedure httpCaptchaStateChange(Sender: TObject);
    procedure lbCAPTCHAErrorClick(Sender: TObject);
  private
    procedure ResetCAPTCHA;
    function PasswordsMatch : Boolean;
    function IsValidData : Boolean;
    procedure ApplyLocalizationChange;
  public
    procedure Reset;
    procedure FillCountryNames;
  end;

implementation

uses LoginWin, ComponentContainerUnit, SharedFunctions, SharedVars, LocalizationStr;

{$R *.dfm}

procedure TfrRegister.btCancelClick(Sender: TObject);
begin
  Hide;
  LoginWindow.frLogin.Show;
end;

procedure TfrRegister.btRegisterNowClick(Sender: TObject);
begin
  If IsValidData Then
  Begin
  End;
end;

procedure TfrRegister.cbCountryChange(Sender: TObject);
begin
  cbCountry.Hint := cbCountry.Text;
end;

procedure TfrRegister.cbCountryCloseUp(Sender: TObject);
begin
  cbCountry.Hint := cbCountry.Text;
end;

procedure TfrRegister.ResetCAPTCHA;
begin
  lbCAPTCHAError.Hide;
  lbCAPTCHAError.Font.Color := clRed;
  imgCaptcha.Picture := nil;
  gifLoadingCaptcha.FrameIndex := 0;
  gifLoadingCaptcha.Visible := TRUE;
  gifLoadingCaptcha.Animate := TRUE;

  If httpCaptcha.State <> httpReady Then
  Begin
    httpCaptcha.CloseAsync;
    httpCaptcha.OnStateChange := httpCaptchaStateChange;
  End
  else
    httpPostRequest(httpCaptcha, URL_CAPTCHA, '');
end;

procedure TfrRegister.Reset;
begin
  ebEmail.Clear;
  ebPassword.Clear;
  ebPasswordConfirm.Clear;
  ebUsername.Clear;
  cbCountry.ItemIndex := 0;
  ebCAPTCHA.Clear;

  ebEmail.SetFocus;

  ResetCAPTCHA;
end;

procedure TfrRegister.lbCAPTCHAErrorClick(Sender: TObject);
begin
  ResetCAPTCHA;
end;

procedure TfrRegister.lbLicenseURLClick(Sender: TObject);
begin
  ShellOpen('http://www.darer.com/index/terms');
end;

procedure TfrRegister.FillCountryNames;
var
  C1   : Integer;
  item : TspComboExItem;
begin
  cbCountry.Items.Clear;
  For C1 := 1 to COUNTRY_LIST_COUNT - 1 Do
  Begin
    item := cbCountry.ItemsEx.Add;
    item.Caption := COUNTRY_LIST[C1].Name;
    item.ImageIndex := FindImage(ComponentContainer.ilFlags, COUNTRY_LIST[C1].Name);
  End;
  cbCountry.ItemIndex := 0;
end;

procedure TfrRegister.httpCaptchaCookie(Sender: TObject; const Data: string; var Accept: Boolean);
begin
  httpRegister.Cookie := Data;
  Accept := TRUE;
end;

procedure TfrRegister.httpCaptchaRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  png : TPNGImage;
begin
  If (ErrCode <> 0) or
     (THTTPCli(Sender).StatusCode <> 200) or
     (THTTPCli(Sender).RcvdCount <= 0) Then
  Begin
    lbCAPTCHAError.Show;
  End
  else
  Begin
    THTTPCli(Sender).RcvdStream.Position := 0;
    png := TPNGImage.Create;
    png.LoadFromStream(THTTPCli(Sender).RcvdStream);
    imgCaptcha.Picture.Assign(png);
    png.Free;
    imgCaptcha.Refresh;
  End;

  httpFree(THTTPCli(Sender));
  gifLoadingCaptcha.Animate := FALSE;
  gifLoadingCaptcha.Visible := FALSE;
end;

procedure TfrRegister.httpCaptchaStateChange(Sender: TObject);
begin
  If httpCaptcha.State = httpReady Then
  Begin
    httpPostRequest(httpCaptcha, URL_CAPTCHA, '');
    httpCaptcha.OnStateChange := nil;
  End;
end;

function TfrRegister.PasswordsMatch : Boolean;
begin
  result := ebPassword.Text = ebPasswordConfirm.Text;
end;

function TfrRegister.IsValidData : Boolean;
const
  MIN_PASS_LENGTH = 5;
  MIN_USER_LENGTH = 4;
var
  response : String;
  dlgType  : TMsgDlgType;
begin
  response := '';
  dlgType := mtError;

  If (ebEmail.Text = '') or
     (ebPassword.Text = '') or
     (ebPasswordConfirm.Text = '') or
     (ebUsername.Text = '') or
     (ebCAPTCHA.Text = '') Then
  Begin
    If ebEmail.Text = '' Then
      ebEmail.SetFocus
    else
      If ebPassword.Text = '' Then
        ebPassword.SetFocus
      else
        If ebPasswordConfirm.Text = '' Then
          ebPasswordConfirm.SetFocus
        else
          If ebUsername.Text = '' Then
            ebUsername.SetFocus
          else
            If ebCAPTCHA.Text = '' Then
              ebCAPTCHA.SetFocus;

    response := RS_FILL_ALL_FIELDS;
    dlgType := mtError;
    result := FALSE;
  End
  else
    If not IsValidEmail(ebEmail.Text) Then
    Begin
      response := RS_INVALID_EMAIL;
      dlgType := mtError;
      result := FALSE;
    End
    else
      If not PasswordsMatch Then
      Begin
        response := RS_PASSWORD_MISMATCH;
        dlgType := mtError;
        ebPassword.SetFocus;
        result := FALSE;
      End
      else
        If Length(ebPassword.Text) < MIN_PASS_LENGTH Then
        Begin
          response := Format(RS_PASSWORD_TOO_SHORT, [MIN_PASS_LENGTH]);
          dlgType := mtError;
          ebPassword.SetFocus;
          result := FALSE;
        End
        else
          If Length(ebUsername.Text) < MIN_USER_LENGTH Then
          Begin
            response := Format(RS_USERNAME_TOO_SHORT, [MIN_USER_LENGTH]);
            dlgType := mtError;
            ebUsername.SetFocus;
            result := FALSE;
          End
          else
            If not chbUserLicense.Checked Then
            Begin
              response := RS_AGREE_TO_TERMS;
              dlgType := mtError;
              result := FALSE;
            end
            else
              result := TRUE;

  If (not result) and
     (response <> '') Then
    ComponentContainer.skinMsgBox.MessageDlg(response, dlgType, [mbOk], 0)
end;

procedure TfrRegister.ApplyLocalizationChange;
var
  font                   : TFont;
  textWidth1, textWidth2 : Integer;
begin
  font := TFont.Create;
  font.Name := chbUserLicense.FontName;
  font.Style := chbUserLicense.FontStyle;
  font.Height := chbUserLicense.FontHeight;
  font.Color := chbUserLicense.FontColor;
  textWidth1 := GetTextWidth(chbUserLicense.Caption, font);
  textWidth2 := GetTextWidth(lbLicenseURL.Caption, lbLicenseURL.Font);

  chbUserLicense.Width := 25 + textWidth1;
  lbLicenseURL.Width := textWidth2;

  chbUserLicense.Left := (self.Width - chbUserLicense.Width - lbLicenseURL.Width - 1) div 2;
  lbLicenseURL.Left := chbUserLicense.Left + chbUserLicense.Width + 1;

  chbUserLicense.Refresh;
  lbLicenseURL.Refresh;
end;


end.
