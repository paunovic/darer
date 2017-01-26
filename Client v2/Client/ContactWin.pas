unit ContactWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, SkinCtrls, SkinBoxCtrls, StdCtrls, Mask,
  SkinExCtrls, sppngimagelist, ImgList, JvComponentBase, JvThread,
  OverbyteIcsWndControl, OverbyteIcsHttpProt;

type
  TContactWindow = class(TForm)
    SkinForm: TspDynamicSkinForm;
    ebSubject: TspSkinEdit;
    lbType: TspSkinShadowLabel;
    cbType: TspSkinComboBox;
    lbSubject: TspSkinShadowLabel;
    lbMessage: TspSkinShadowLabel;
    memoMessage: TspSkinMemo;
    btSubmit: TspSkinButton;
    btCancel: TspSkinButton;
    sbMessage: TspSkinScrollBar;
    http: THttpCli;
    spSkinPanel1: TspSkinPanel;
    procedure FormCreate(Sender: TObject);
    procedure CaptchaThreadExecute(Sender: TObject; Params: Pointer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btCancelClick(Sender: TObject);
    procedure LocalLocalize;
    procedure httpRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure btSubmitClick(Sender: TObject);
  private
  public
  end;

var
  ContactWindow: TContactWindow;

implementation

{$R *.dfm}

uses
  ComponentModule, SharedData, Localization, superobject, SharedVars;

procedure TContactWindow.LocalLocalize;
var
  index : Integer;
begin
  index := cbType.ItemIndex;
  cbType.Items.Clear;
  cbType.Items.Add(RS_CONTACT_TYPE_BUG);
  cbType.Items.Add(RS_CONTACT_TYPE_SUPPORT);
  cbType.ItemIndex := index;
  cbType.Refresh;
end;

procedure TContactWindow.FormCreate(Sender: TObject);
begin
  SkinForm.AlphaBlendAnimation := Options.Customize.FadeInEffect;

  Localize(self);
  LocalLocalize;
end;

procedure TContactWindow.CaptchaThreadExecute(Sender: TObject; Params: Pointer);
begin
  httpGetRequest(http, URL_CAPTCHA);
end;

procedure TContactWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  try
    http.Close;
  except
  end;  
  
  Action := caFREE;
end;

procedure TContactWindow.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Case Key of
    vk_RETURN : SelectNext(ActiveControl as TWinControl, TRUE, TRUE);
    vk_ESCAPE : Close;
  End;
end;

procedure TContactWindow.btCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TContactWindow.httpRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
begin
  If ErrCode <> 0 Then
    ComponentModuleWindow.spMessage.MessageDlg(SysErrorMessage(ErrCode), mtError, [mbOk], 0)
  else
  Begin
    If THTTPCli(Sender).StatusCode <> 200 Then
      ComponentModuleWindow.spMessage.MessageDlg(Format('[%d] %s', [THTTPCli(Sender).StatusCode, THTTPCli(Sender).ReasonPhrase]), mtError, [mbOk], 0)
    else
    Begin
      Close;
    End;
  End;

  httpFree(THTTPCli(Sender));
end;

procedure TContactWindow.btSubmitClick(Sender: TObject);
var
  params : String;
begin
  If (ebSubject.Text <> '') and
     (Length(memoMessage.Text) > 1) Then
  Begin
    params := Format('key=%s&subject=%s&message=%s&type=%d', [UserDetails.Key, Format('(%s) - %s', [CLIENT_VERSION, ebSubject.Text]), memoMessage.Text, cbType.ItemIndex]);
    httpPostRequest(http, URL_API + 'sendSupportMsg', params);
  End;
end;

end.
