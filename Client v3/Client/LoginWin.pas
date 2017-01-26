unit LoginWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, DynamicSkinForm,
  Controls, Forms, LoginFrame, pngimage, ExtCtrls, SharedVars, RegisterFrame,
  UpdateFrame, Localization, StdCtrls, ComCtrls, SkinCtrls, SkinBoxCtrls;

{$I defines.inc}

type
  TLoginWindow = class(TForm, ILocalizationChanged)
    SkinForm: TspDynamicSkinForm;
    frLogin: TfrLogin;
    imgLogo: TImage;
    frRegister: TfrRegister;
    frUpdate: TfrUpdate;
    procedure FormCreate(Sender: TObject);
    procedure frLoginebUsernameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    procedure ApplyLocalizationChange;
    procedure WMAfterShow(var Msg: TMessage); message WM_AFTER_SHOW;
  public
  end;

var
  LoginWindow: TLoginWindow;

implementation

{$R *.dfm}

uses
  ComponentContainerUnit, SharedFunctions, JvTypes, OverbyteIcsHttpProt,
  LocalizationStr, Dialogs;

procedure TLoginWindow.FormCreate(Sender: TObject);
const
  DEFAULT_WIDTH  = 261;
  DEFAULT_HEIGHT = 442;
var
  FRAMES : Array[0..2] of TFrame;
  C1     : Integer;
begin
  DbgLn('TLoginWindow.FormCreate()');

  ComponentContainer.Localizer.Localize(self);

  InstallURLProtocol;

  ClientWidth := DEFAULT_WIDTH;
  ClientHeight := DEFAULT_HEIGHT;

  imgLogo.Top := 0;
  imgLogo.Left := 4;

  FRAMES[0] := frLogin;
  FRAMES[1] := frRegister;
  FRAMES[2] := frUpdate;

  For C1 := Low(FRAMES) to High(FRAMES) Do
  Begin
    FRAMES[C1].Width := DEFAULT_WIDTH;
    FRAMES[C1].Height := DEFAULT_HEIGHT - imgLogo.Height;
    FRAMES[C1].Left := 0;
    FRAMES[C1].Top := imgLogo.Top + imgLogo.Height;
    FRAMES[C1].Visible := FALSE;
    CreateGradient(FRAMES[C1], grVertical, $004D443A, $00342D28, alClient);
  End;

  frLogin.ebUsername.Text := Options.Username;
  frLogin.ebPassword.Text := TrimRight(Decrypt(Options.Password, GetLocalEncryptionKey));
  frLogin.chbRemember.Checked := frLogin.ebPassword.Text <> '';
  frLogin.chbAutoLogin.Checked := Options.AutoLogin;
  frLogin.Visible := TRUE;

  ComponentContainer.pmTrayLogout.Visible := FALSE;

  Caption := CLIENT_VERSION;

  frRegister.FillCountryNames;

  if not IsUserAnAdmin then
    ComponentContainer.skinMsgBox.MessageDlg(RS_RUN_CLIENT_AS_ADMIN, mtError, [mbOk], 0);
end;

procedure TLoginWindow.frLoginebUsernameKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Case Key of
    vk_RETURN : Begin
                  If ActiveControl = frLogin.ebPassword Then
                    frLogin.btLogin.OnClick(Sender)
                  else
                    SelectNext(ActiveControl as TWinControl, TRUE, TRUE);
                End;
  End;
end;

procedure TLoginWindow.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  DbgLn('TLoginWindow.FormCloseQuery()');

  If (not ComponentContainer.CanExit) and
     (frLogin.LoggingIn) Then
  Begin
    If frUpdate.Visible Then
    Begin
      If Assigned(frUpdate.ThreadDownloader) Then
        frUpdate.TerminateThread;
      frUpdate.Hide;
    End;

    frLogin.ShowLoginFrame(TRUE);

    If frLogin.httpLogin.State <> httpReady Then
      frLogin.httpLogin.Close;
    CanClose := FALSE;
  End;
end;

procedure TLoginWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DbgLn('TLoginWindow.FormClose()');

  Options.AutoLogin := frLogin.chbAutoLogin.Checked;
  If frLogin.chbRemember.Checked Then
    Options.Password := Encrypt(frLogin.ebPassword.Text, GetLocalEncryptionKey)
  else
    Options.Password := '';

  Action := caFree;
end;

procedure TLoginWindow.FormShow(Sender: TObject);
begin
  PostMessage(Self.Handle, WM_AFTER_SHOW, 0, 0);
end;

procedure TLoginWindow.WMAfterShow(var Msg: TMessage);
begin
  DbgLn('TLoginWindow.WMAfterShow()');

  If IsIconic(Application.Handle) Then
    ComponentContainer.HideClient;

  If (not ComponentContainer.NoAutoLogin) and
     ((frLogin.chbAutoLogin.Checked) or
      (ComponentContainer.LoginSwitch)) Then
  Begin
    If ComponentContainer.LoginSwitch Then
    Begin
      frLogin.ebUsername.Text := ComponentContainer.LoginUsername;
      frLogin.ebPassword.Text := ComponentContainer.LoginPassword;
      ComponentContainer.LoginSwitch := FALSE;
    End;

    frLogin.btLogin.OnClick(LoginWindow);
  End
  else
    ComponentContainer.NoAutoLogin := FALSE;
end;

procedure TLoginWindow.ApplyLocalizationChange;
begin
//
end;

end.
