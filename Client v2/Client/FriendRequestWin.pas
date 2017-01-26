unit FriendRequestWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, SkinCtrls, SkinExCtrls, sppngimagelist,
  ExtCtrls, ImgList;

type
  TFriendRequestWindow = class(TForm)
    SkinForm: TspDynamicSkinForm;
    pasTFriendRequest: TspSkinPanel;
    paFriendInfo: TspSkinPanel;
    pasTUserInfoAvatar: TspSkinPanel;
    pasRUserInfoAvatar: TspSkinPanel;
    pasLUserInfoAvatar: TspSkinPanel;
    pasBUserInfoAvatar: TspSkinPanel;
    paFriendInfoButtons: TspSkinPanel;
    btUserBlock: TspSkinButton;
    paInUserInfoAvatar: TspSkinPanel;
    imgUserInfoAvatar: TspPngImageView;
    paFriendRequestButtons: TspSkinPanel;
    btDecline: TspSkinButton;
    btAccept: TspSkinButton;
    pasRFriendRequest: TspSkinPanel;
    pasLFriendRequest: TspSkinPanel;
    pasLFriendInfoButtons: TspSkinPanel;
    paFriendName: TspSkinPanel;
    lbFriendName: TspSkinShadowLabel;
    tiAvatarCheck: TTimer;
    ilUserAvatar: TspPngImageList;
    btDeclineAll: TspSkinButton;
    pasRFriendInfoButtons: TspSkinPanel;
    procedure LocalLocalize;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure SetRequestID(const AID : Integer);
    procedure SetAvatar(const APath : String);
    procedure tiAvatarCheckTimer(Sender: TObject);
    procedure btDeclineClick(Sender: TObject);
    procedure btAcceptClick(Sender: TObject);
    procedure btUserBlockClick(Sender: TObject);
    procedure btDeclineAllClick(Sender: TObject);
  private
    Nick  : String;
    ReqID : String;
  public
  end;

var
  FriendRequestWindow: TFriendRequestWindow;

implementation

{$R *.dfm}

uses
  Localization, ComponentModule, SharedData, Cache, MainWin, imageen, hyiedefs, Misc;

procedure TFriendRequestWindow.LocalLocalize;
begin
//
end;

procedure TFriendRequestWindow.FormClose(Sender: TObject; var Action: TCloseAction);
var
  index1, index2 : Integer;
begin
  If (UserDetails.FriendRequests_IDs.Find(ReqID, index1)) and
     (UserDetails.FriendRequests_Names.Find(Nick, index2)) and
     (index1 = index2) Then
    UserDetails.FriendRequests_Processed.Strings[index1] := '1';

  Action := caFREE;
end;

procedure TFriendRequestWindow.FormCreate(Sender: TObject);
begin
  Localize(self);
  LocalLocalize;

  btDeclineAll.Caption := Format(btDeclineAll.Caption, [UserDetails.FriendRequests_IDs.Count]);
end;

procedure TFriendRequestWindow.SetAvatar(const APath : String);
var
  img : TspPngImageItem;
begin
  ilUserAvatar.PngWidth := imgUserInfoAvatar.Width;
  ilUserAvatar.PngHeight := imgUserInfoAvatar.Height;

  img := TspPngImageItem(ilUserAvatar.PngImages.Add);
  img.PngImage.LoadFromFile(APath);

  imgUserInfoAvatar.ImageIndex := img.Index;
end;

procedure TFriendRequestWindow.SetRequestID(const AID : Integer);
begin
  Nick := UserDetails.FriendRequests_Names.Strings[AID];
  ReqID := UserDetails.FriendRequests_IDs.Strings[AID];

  lbFriendName.Caption := Format(RS_FRIEND_NAME, [Nick]);

  MainWindow.AddUserToPostQueue(MainWindow.UsernameQueue, Nick);
  MainWindow.tiUsernameDelayedQueue.OnTimer(self);
  tiAvatarCheck.Enabled := TRUE;
end;

procedure TFriendRequestWindow.tiAvatarCheckTimer(Sender: TObject);
var
  avatarPath : String;
  uid        : Integer;
begin
  uid := FindUser(Nick);
  If (uid <> -1) and
     (cache_GetAvatar(Users.Items[uid].Avatar, atBig, avatarPath)) Then
  Begin
    SetAvatar(avatarPath);
    tiAvatarCheck.Enabled := FALSE;
  End;
end;

procedure TFriendRequestWindow.btDeclineClick(Sender: TObject);
begin
  MainWindow.DeclineFriend(ReqID, Nick);
  Close;
end;

procedure TFriendRequestWindow.btAcceptClick(Sender: TObject);
begin
  MainWindow.ConfirmFriend(ReqID, Nick);
  Close;
end;

procedure TFriendRequestWindow.btUserBlockClick(Sender: TObject);
begin
  MainWindow.BlockUser(Nick);
  Close;
end;

procedure TFriendRequestWindow.btDeclineAllClick(Sender: TObject);
var
  reqs : String;
  C1   : Integer;
begin
  For C1 := 0 to UserDetails.FriendRequests_IDs.Count - 1 Do
  Begin
    reqs := reqs + UserDetails.FriendRequests_IDs.Strings[C1] + ',';
    UserDetails.FriendRequests_Processed.Strings[C1] := '1';
  End;
  Delete(reqs, Length(reqs), 1);

  MainWindow.DeclineFriend(reqs, '');

  Close;
end;

end.
