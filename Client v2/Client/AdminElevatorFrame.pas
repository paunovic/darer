unit AdminElevatorFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, SkinCtrls, SkinBoxCtrls, StdCtrls, Mask,
  SkinExCtrls, ExtCtrls, sppngimagelist, ImgList;

type
  TfrAdminElevator = class(TFrame)
    tiStatus: TTimer;
    lbUsername: TspSkinShadowLabel;
    ebUsername: TspSkinEdit;
    lbPassword: TspSkinShadowLabel;
    ebPassword: TspSkinPasswordEdit;
    chbRemember: TspSkinCheckRadioBox;
    btLogin: TspSkinButton;
    lbStatus: TspSkinShadowLabel;
    SkinFrame: TspSkinFrame;
    imLogo: TspPngImageView;
    procedure SetStatus(const AText : String; const ATimeout : Integer = -1; const AColor : TColor = $00BFBAAE);
    procedure SaveAdminData;
    procedure LoadAdminData;
    procedure Login;
    procedure btLoginClick(Sender: TObject);
    procedure tiStatusTimer(Sender: TObject);
  private
  public
  end;

implementation

{$R *.dfm}

uses
  ComponentModule, SharedData, DCPblowfish, DCPsha1, LoginWin, Localization;


procedure TfrAdminElevator.SaveAdminData;
var
  user, pass : String;
begin
  If chbRemember.Checked Then
  Begin
    user := blowfishEncrypt(ebUsername.Text);
    pass := blowfishEncrypt(ebPassword.Text);
  End
  else
  Begin
    user := '';
    pass := '';
  End;

  ComponentModuleWindow.Settings.WriteString('admin\user', user);
  ComponentModuleWindow.Settings.WriteString('admin\pass', pass);
end;

procedure TfrAdminElevator.LoadAdminData;
begin
  ebUsername.Text := blowfishDecrypt(ComponentModuleWindow.Settings.ReadString('admin\user', ''));
  ebPassword.Text := blowfishDecrypt(ComponentModuleWindow.Settings.ReadString('admin\pass', ''));
end;

procedure TfrAdminElevator.SetStatus(const AText : String; const ATimeout : Integer = -1; const AColor : TColor = $00BFBAAE);
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

procedure TfrAdminElevator.Login;
var
  pinfo : TProcessInformation;
  res   : Integer;
begin
  DestroyInstanceMutex;
  res := RunAs('.', ebUsername.Text, ebPassword.Text, ParamStr(0), pinfo);
  If res = 0 Then
  Begin
    ComponentModuleWindow.Free;
    ExitProcess(0);
  End
  else
  Begin
    CreateInstanceMutex;
    If res = 1327 Then
      SetStatus(Format(RS_ADMINLOGIN_WINDOWSPOLICY_ERROR, [ebUsername.Text]), 0, clRed)
    else
      SetStatus(SysErrorMessage(res), 0, clRed);
  End;
end;

procedure TfrAdminElevator.btLoginClick(Sender: TObject);
begin
  SaveAdminData;

  Login;
end;

procedure TfrAdminElevator.tiStatusTimer(Sender: TObject);
begin
  lbStatus.Hide;
  tiStatus.Enabled := FALSE;
end;

end.
