unit TrayPopupWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, SkinCtrls, JvComponentBase, JvThread,
  SkinExCtrls, sppngimagelist, ImgList, ExtCtrls, StdCtrls;

type
  TTrayPopupWindow = class(TForm)
    SkinForm: TspDynamicSkinForm;
    thdFadeOut: TJvThread;
    tiTimeout: TTimer;
    paBBorder: TspSkinPanel;
    paRBorder: TspSkinPanel;
    paLBorder: TspSkinPanel;
    thdFadeIn: TJvThread;
    paTBorder: TspSkinPanel;
    thdStayOnTop: TJvThread;
    imgAvatar: TspPngImageView;
    lbCaption: TspSkinStdLabel;
    lbText: TspSkinStdLabel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure thdFadeOutExecute(Sender: TObject; Params: Pointer);
    procedure FormCreate(Sender: TObject);
    procedure tiTimeoutTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lbTextClick(Sender: TObject);
    procedure thdFadeInExecute(Sender: TObject; Params: Pointer);
    procedure ShowFadeIn;
    procedure thdStayOnTopExecute(Sender: TObject; Params: Pointer);
    procedure thdStayOnTopFinish(Sender: TObject);
  private
    CanExit : Boolean;
  public
    procedure Reset(const ATimeout : Integer; const AHeader, AText : String);
    procedure SetLabels(const AHeader, AText : String);
    procedure FadeOut;
    procedure FadeIn;
  end;

var
  TrayPopupWindow: TTrayPopupWindow;

implementation

{$R *.dfm}

uses
  SharedData, ComponentModule, MainWin, Misc, ComCtrls;

procedure TTrayPopupWindow.Reset(const ATimeout : Integer; const AHeader, AText : String);
begin
  Left := Screen.Width - Width;
  Top := Screen.Height - GetTaskBarHeight - Height;

  SetLabels(AHeader, AText);

  tiTimeout.Interval := ATimeout;
  tiTimeout.Enabled := FALSE;
  tiTimeout.Enabled := TRUE;
end;

procedure TTrayPopupWindow.SetLabels(const AHeader, AText : String);
var
  uid, aid : Integer;
begin
  lbCaption.Caption := AHeader;
  lbText.Caption := AText;

  aid := 0;
  uid := FindUser(AHeader);
  If (uid <> -1) and
     (Users.Avatar[uid].ID35 > 0) Then
    aid := Users.Avatar[uid].ID35;
  If imgAvatar.ImageIndex <> aid Then
    imgAvatar.ImageIndex := aid;
end;

procedure TTrayPopupWindow.FadeOut;
begin
  SkinForm.AlphaBlendValue := 255;
  SkinForm.AlphaBlend := TRUE;

  While SkinForm.AlphaBlendValue > 0 Do
  Begin
    SkinForm.AlphaBlendValue := SkinForm.AlphaBlendValue - 1;
    Sleep(2);
  End;

  thdStayOnTop.Terminate;
end;

procedure TTrayPopupWindow.FadeIn;
begin
  SkinForm.AlphaBlendValue := 0;
  SkinForm.AlphaBlend := TRUE;

  While SkinForm.AlphaBlendValue < 255 Do
  Begin
    SkinForm.AlphaBlendValue := SkinForm.AlphaBlendValue + 1;
    Sleep(1);
  End;
end;

procedure TTrayPopupWindow.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  If CanExit Then
    CanClose := TRUE
  else
  Begin
    CanClose := FALSE;

    thdFadeOut.Execute(nil);
  End;
end;

procedure TTrayPopupWindow.thdFadeOutExecute(Sender: TObject; Params: Pointer);
begin
  FadeOut;
end;

procedure TTrayPopupWindow.FormCreate(Sender: TObject);
begin
  CanExit := FALSE;
end;

procedure TTrayPopupWindow.tiTimeoutTimer(Sender: TObject);
begin
  Close;
end;

procedure TTrayPopupWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  TrayPopupWindow := nil;
end;

procedure TTrayPopupWindow.lbTextClick(Sender: TObject);
var
  ctab : TTabSheet;
begin
  Close;
  ComponentModuleWindow.TrayIconClick(Sender);

  ctab := MainWindow.GetChatTab(lbCaption.Caption, ctPVPGN_User);
  If Assigned(ctab) Then
    MainWindow.cntChat.ActivePage := ctab;
end;

procedure TTrayPopupWindow.thdFadeInExecute(Sender: TObject; Params: Pointer);
begin
  FadeIn;
end;

procedure TTrayPopupWindow.ShowFadeIn;
begin
  thdFadeIn.Execute(nil);
  thdStayOnTop.Execute(nil);
  ShowWindow(Handle, SW_SHOWNA);
end;

procedure TTrayPopupWindow.thdStayOnTopExecute(Sender: TObject; Params: Pointer);
begin
  repeat
    SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE or SWP_NOOWNERZORDER);
  until thdStayOnTop.Terminated;
end;

procedure TTrayPopupWindow.thdStayOnTopFinish(Sender: TObject);
begin
  CanExit := TRUE;
  Close;
end;

end.
