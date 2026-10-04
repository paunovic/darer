unit RegisterFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SkinCtrls, SkinBoxCtrls, StdCtrls, Mask, SkinExCtrls,
  DynamicSkinForm, ExtCtrls, sppngimagelist, ImgList, JvThread, 
  OverbyteIcsWndControl, OverbyteIcsUrl, OverbyteIcsLogger, OverbyteIcsWSocket,
  OverbyteIcsHttpProt;

type
  TfrRegister = class(TFrame)
    ebEmail: TspSkinEdit;
    lbTitle: TspSkinShadowLabel;
    lbPassword: TspSkinShadowLabel;
    lbConfirmPassword: TspSkinShadowLabel;
    btCancel: TspSkinButton;
    btRegister: TspSkinButton;
    lbCountry: TspSkinShadowLabel;
    lbEMail: TspSkinShadowLabel;
    ebPassword: TspSkinPasswordEdit;
    ebConfirmPassword: TspSkinPasswordEdit;
    spBevel: TspSkinBevel;
    imCaptcha: TspPngImageView;
    ilCaptcha: TspPngImageList;
    chbLicense: TspSkinCheckRadioBox;
    lbLicenseLink: TspSkinLinkLabel;
    lbSecurityInput: TspSkinShadowLabel;
    ebCaptcha: TspSkinEdit;
    lbLicense: TspSkinShadowLabel;
    SkinFrame: TspSkinFrame;
    imLogo: TspPngImageView;
    lbUsername: TspSkinShadowLabel;
    ebUsername: TspSkinEdit;
    cbCountry: TspSkinComboBoxEx;
    httpCaptcha: THttpCli;
    httpRegister: THttpCli;
    procedure PopulateCountryList;
    procedure ResetFrame;
    procedure btRegisterClick(Sender: TObject);
    function CheckUserData : Boolean;
    procedure chbLicenseClick(Sender: TObject);
    procedure chbLicenseKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ebEmailChange(Sender: TObject);
    procedure PopulateComboBox;
    procedure httpRegisterRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure httpCaptchaRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure httpCaptchaCookie(Sender: TObject; const Data: String; var Accept: Boolean);
  private
  public
    gettingCaptcha, gotCaptcha : Boolean;
  end;

implementation

{$R *.dfm}

uses
  ComponentModule, LoginWin, DateUtils, SharedData, Localization, superobject, LoginFrame, SharedVars, Misc;

procedure TfrRegister.PopulateCountryList;
var
  C1, C2 : Integer;
  item   : TspComboExItem;
begin
  For C1 := 1 to COUNTRY_LIST_COUNT - 1 Do
  Begin
    item := nil;
    For C2 := 0 to cbCountry.ItemsEx.Count - 1 Do
      If cbCountry.ItemsEx.Items[C2].Caption = COUNTRY_LIST[C1].Name Then
      Begin
        item := cbCountry.ItemsEx.Items[C2];
        Break;
      End;

    If not Assigned(item) Then
      item := cbCountry.ItemsEx.Add;

    item.Caption := COUNTRY_LIST[C1].Name;
    item.ImageIndex := ComponentModuleWindow.FindCountryImage(COUNTRY_LIST[C1].Code);
  End;

  cbCountry.Refresh;
end;

procedure TfrRegister.ResetFrame;
begin
  PopulateCountryList;
  
  ebEmail.Clear;
  ebPassword.Clear;
  ebConfirmPassword.Clear;
  ebUsername.Clear;
  cbCountry.ItemIndex := 0;
  ebCaptcha.Clear;
  chbLicense.Checked := FALSE;

  If (not gettingCaptcha) and
     (not gotCaptcha) Then
  Begin
    ilCaptcha.PngImages.Clear;
    imCaptcha.ImageIndex := -1;
    imCaptcha.Refresh;
  End;
end;

procedure TfrRegister.btRegisterClick(Sender: TObject);
const
  MIN_PASS_LENGTH = 5;
  MIN_USER_LENGTH = 4;
var
  params : String;
begin
  If not IsValidEmail(ebEmail.Text) Then
  Begin
    ComponentModuleWindow.spMessage.MessageDlg2(RS_INVALID_EMAIL, RS_REGISTRATION, mtError, [mbOk], 0);
    ebEMail.SetFocus;
  End
  else
    If Length(ebUsername.Text) < MIN_USER_LENGTH Then
    Begin
      ComponentModuleWindow.spMessage.MessageDlg2(RS_USER_TOO_SHORT, RS_REGISTRATION, mtError, [mbOk], 0);
      ebUsername.SetFocus;
    End
    else
      If Length(ebPassword.Text) < MIN_PASS_LENGTH Then
      Begin
        ComponentModuleWindow.spMessage.MessageDlg2(RS_PASSWORD_TOO_SHORT, RS_REGISTRATION, mtError, [mbOk], 0);
        ebPassword.SetFocus;
      End
      else
        If ebPassword.Text <> ebConfirmPassword.Text Then
        Begin
          ComponentModuleWindow.spMessage.MessageDlg2(RS_PASSWORDS_MISMATCH, RS_REGISTRATION, mtError, [mbOk], 0);
          ebPassword.SetFocus;
        End
        else
          If not chbLicense.Checked Then
          Begin
            ComponentModuleWindow.spMessage.MessageDlg2(RS_LICENSE_AGREE_TEXT, RS_REGISTRATION, mtError, [mbOk], 0);
            chbLicense.SetFocus;
          End
          else
          Begin
            params := Format('captcha=%s&email=%s&password=%s&first_name=%s&last_name=%s&username=%s&country=%s&favorite_game=%s&sex=%s&month=%d&day=%d&year=%d',
                             [Trim(ebCaptcha.Text), Trim(ebEmail.Text), ebPassword.Text, 'Unknown', 'Unknown', ebUsername.Text, cbCountry.Text, 'dota', 'male', 1, 1, 1980]);
            httpPostRequest(httpRegister, URL_API + 'register', params);
          End;

end;

function TfrRegister.CheckUserData : Boolean;
begin
  result := (ebEmail.Text <> '') and
            (ebPassword.Text <> '') and
            (chbLicense.Checked) and
            (gotCaptcha);
  btRegister.Enabled := result;
end;

procedure TfrRegister.chbLicenseClick(Sender: TObject);
begin
  CheckUserData;
end;

procedure TfrRegister.chbLicenseKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  CheckUserData;
end;

procedure TfrRegister.ebEmailChange(Sender: TObject);
begin
  CheckUserData;
end;

procedure TfrRegister.PopulateComboBox;
begin
  cbCountry.Items.Assign(Countries);
  cbCountry.ItemIndex := 0;
end;

procedure TfrRegister.httpRegisterRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  response : String;
  JSON     : ISuperObject;
  resptype : Char;
  respcode : Integer;
begin
  If ErrCode <> 0 Then
    ComponentModuleWindow.spMessage.MessageDlg(SysErrorMessage(ErrCode), mtError, [mbOk], 0)
  else
  Begin
    If THTTPCli(Sender).StatusCode <> 200 Then
      ComponentModuleWindow.spMessage.MessageDlg(Format('[%d] %s', [THTTPCli(Sender).StatusCode, THTTPCli(Sender).ReasonPhrase]), mtError, [mbOk], 0)
    else
    Begin
      If (Assigned(THTTPCli(Sender).RcvdStream)) and
         (THTTPCli(Sender).RcvdStream.Size > 0) Then
      Begin
        THTTPCli(Sender).RcvdStream.Position := 0;
        JSON := TSuperObject.ParseStream(THTTPCli(Sender).RcvdStream, FALSE);
        response := JSON.S['result'];
        JSON := nil;
        ParseResponse(response, respType, respCode);
        ComponentModuleWindow.spMessage.MessageDlg2(TranslateResponse(respType, respCode), RS_REG_CAPTION, mtInformation, [mbOk], 0);
        Case respType of
          'A' : If respCode = 1 Then
                  LoginWindow.frRegisterbtCancelClick(nil);
          'E' : Begin
                  Case respCode of
                    0002 : ebUsername.SetFocus;
                    0003 : ebEMail.SetFocus;
                    0004 : Begin
                             ebCaptcha.Clear;
                             ebCaptcha.SetFocus;
                           End;
                  End;
                End;
        End;
      End;
    End;
  End;

  httpFree(THTTPCli(Sender));
end;

procedure TfrRegister.httpCaptchaRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  ID : Integer;
begin
  THTTPCli(Sender).RcvdStream.Position := 0;
  ID := ilCaptcha.PngImages.Add.Index;
  ilCaptcha.PngImages[ID].PngImage.LoadFromStream(THTTPCli(Sender).RcvdStream);
  imCaptcha.PngImageList := ilCaptcha;
  imCaptcha.ImageIndex := ID;
  imCaptcha.Refresh;
  gotCaptcha := TRUE;
  gettingCaptcha := FALSE;

  httpFree(THTTPCli(Sender));
end;

procedure TfrRegister.httpCaptchaCookie(Sender: TObject; const Data: String; var Accept: Boolean);
begin
  httpRegister.Cookie := Data;
  Accept := TRUE;
end;

end.


