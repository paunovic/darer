unit Misc;

interface

uses
  Windows, SharedData;

procedure LoadSettings;
procedure SaveSettings;
function AskForWC3Path : Boolean;
procedure ParseMyDetails(const ADetails : WideString);
function FormatTimeDifference(const AYears, AMonths, ADays, AHours, AMinutes, ASeconds : Integer) : String;
function InstallURLProtocol : DWORD;
procedure UninstallURLProtocol;
procedure RegisterReplayExtension;
procedure UnregisterReplayExtension;
function IsReplaysAssociated : Boolean;
procedure AddUserToList(const AUserInfo : TUserInfo);
function FindUser(const AUsername : String) : Integer;
function SetUserInfo_Friend_Site(const AUsername : String; const AFriend : Boolean) : Boolean;
function SetUserInfo_Friend_PVPGN(const AUsername : String; const AFriend : Boolean) : Boolean;
function ParseResponse(const AResponse : String; var AType : Char; var ACode : Integer) : Boolean;
function TranslateResponse(const AType : Char; const ACode : Integer) : String;
function CalculateLevel(const AWins, ALosses : Integer; var ACurrentExperience, ANextExperience : Integer) : Integer;
function IsValidRoom(const ARating : Integer; const ARoom : String; var AError : String) : Boolean;

implementation

uses
  Forms, SysUtils, Cache, Classes, ComponentModule, spSkinShellCtrls, Localization, superobject, MainWin, Registry, Math, SharedVars, P2P;

  

procedure LoadSettings;
begin
  // Client
  Options.Client.MinimizeToSystray := ComponentModuleWindow.Settings.ReadBoolean('client\systray', TRUE);
  Options.Client.ScrollbackLines := ComponentModuleWindow.Settings.ReadInteger('client\scrollbacklines', 500);
  Options.Client.ShowFriendRequests := ComponentModuleWindow.Settings.ReadBoolean('client\showfriendrequests', TRUE);
  ComponentModuleWindow.TrayIcon.MinimizeToTray := Options.Client.MinimizeToSystray;
  Options.Client.ShowFriendGameMsgs := ComponentModuleWindow.Settings.ReadBoolean('client\showfriendgamemsgs', FALSE);
  Options.Client.ShowFriendOnlineMsgs := ComponentModuleWindow.Settings.ReadBoolean('client\showfriendonlinemsgs', TRUE);
  Options.Client.GameAutoMinimize := ComponentModuleWindow.Settings.ReadBoolean('client\gameautominimize', TRUE);
  Options.Client.ShowPopups := ComponentModuleWindow.Settings.ReadBoolean('client\showpopups', TRUE);
  Options.Client.AssociateReplays := IsReplaysAssociated;

  // Sounds
  Options.Sounds.Enabled := ComponentModuleWindow.Settings.ReadBoolean('sounds\enabled', TRUE);
  Options.Sounds.SurpressIngame := ComponentModuleWindow.Settings.ReadBoolean('sounds\surpressingame', TRUE);

  Options.Sounds.PM.Enabled := ComponentModuleWindow.Settings.ReadBoolean('sounds\privatemessage_on', TRUE);
  Options.Sounds.PM.Path := ComponentModuleWindow.Settings.ReadString('sounds\privatemessage', 'pm.wav');

  Options.Sounds.NewPM.Enabled := ComponentModuleWindow.Settings.ReadBoolean('sounds\newprivatemessage_on', TRUE);
  Options.Sounds.NewPM.Path := ComponentModuleWindow.Settings.ReadString('sounds\newprivatemessage', 'newpm.wav');

  Options.Sounds.BotPM.Enabled := ComponentModuleWindow.Settings.ReadBoolean('sounds\botpm_on', TRUE);
  Options.Sounds.BotPM.Path := ComponentModuleWindow.Settings.ReadString('sounds\botpm', 'botpm.wav');

  Options.Sounds.ErrorMessage.Enabled := ComponentModuleWindow.Settings.ReadBoolean('sounds\errormsg_on', TRUE);
  Options.Sounds.ErrorMessage.Path := ComponentModuleWindow.Settings.ReadString('sounds\errormsg', 'errormsg.wav');

  Options.Sounds.FriendOn.Enabled := ComponentModuleWindow.Settings.ReadBoolean('sounds\friendonline_on', TRUE);
  Options.Sounds.FriendOn.Path := ComponentModuleWindow.Settings.ReadString('sounds\friendonline', 'friendon.wav');

  Options.Sounds.FriendOff.Enabled := ComponentModuleWindow.Settings.ReadBoolean('sounds\friendoffline_off', TRUE);
  Options.Sounds.FriendOff.Path := ComponentModuleWindow.Settings.ReadString('sounds\friendoffline', 'friendoff.wav');

  Options.Sounds.Highlighted.Enabled := ComponentModuleWindow.Settings.ReadBoolean('sounds\highlighted_on', TRUE);
  Options.Sounds.Highlighted.Path := ComponentModuleWindow.Settings.ReadString('sounds\highlighted', 'highlighted.wav');

  Options.Sounds.LobbyFull.Enabled := ComponentModuleWindow.Settings.ReadBoolean('sounds\lobbyfull_on', TRUE);
  Options.Sounds.LobbyFull.Path := ComponentModuleWindow.Settings.ReadString('sounds\lobbyfull', 'lobbyfull.wav');

  // Warcraft III
  Options.WC3.Path := ComponentModuleWindow.Settings.ReadString('wc3\path', Options.WC3.Path);
  Options.WC3.Exe := ITB(Options.WC3.Path) + 'war3.exe';
  Options.WC3.Params := ComponentModuleWindow.Settings.ReadString('wc3\params', '');
  Options.WC3.Windowed := ComponentModuleWindow.Settings.ReadBoolean('wc3\windowed', FALSE);
  Options.WC3.OpenGL := ComponentModuleWindow.Settings.ReadBoolean('wc3\opengl', FALSE);
  Options.WC3.Maximize := ComponentModuleWindow.Settings.ReadBoolean('wc3\maximize', FALSE);
  Options.WC3.Language := ComponentModuleWindow.Settings.ReadString('wc3\language', '');

  // Customize panel
  Options.Customize.Skin := ComponentModuleWindow.Settings.ReadString('client\skin', 'Default');
  Options.Customize.StatusIcons := ComponentModuleWindow.Settings.ReadInteger('client\statusicons', 0);
  Options.Customize.FadeInEffect := ComponentModuleWindow.Settings.ReadBoolean('client\fadeineffect', FALSE);
end;

procedure SaveSettings;
begin
  // Client
  ComponentModuleWindow.Settings.WriteBoolean('client\systray', Options.Client.MinimizeToSystray);
  ComponentModuleWindow.Settings.WriteInteger('client\scrollbacklines', Options.Client.ScrollbackLines);
  ComponentModuleWindow.Settings.WriteBoolean('client\showfriendrequests', Options.Client.ShowFriendRequests);
  ComponentModuleWindow.Settings.WriteBoolean('client\showfriendgamemsgs', Options.Client.ShowFriendGameMsgs);
  ComponentModuleWindow.Settings.WriteBoolean('client\showfriendonlinemsgs', Options.Client.ShowFriendOnlineMsgs);
  ComponentModuleWindow.Settings.WriteBoolean('client\gameautominimize', Options.Client.GameAutoMinimize);
  ComponentModuleWindow.Settings.WriteBoolean('client\showpopups', Options.Client.ShowPopups);
  If Options.Client.AssociateReplays Then
    RegisterReplayExtension
  else
    UnregisterReplayExtension;

  // Sounds
  ComponentModuleWindow.Settings.WriteBoolean('sounds\enabled', Options.Sounds.Enabled);
  ComponentModuleWindow.Settings.WriteBoolean('sounds\surpressingame', Options.Sounds.SurpressIngame);

  ComponentModuleWindow.Settings.WriteBoolean('sounds\privatemessage_on', Options.Sounds.PM.Enabled);
  ComponentModuleWindow.Settings.WriteString('sounds\privatemessage', Options.Sounds.PM.Path);

  ComponentModuleWindow.Settings.WriteBoolean('sounds\newprivatemessage_on', Options.Sounds.NewPM.Enabled);
  ComponentModuleWindow.Settings.WriteString('sounds\newprivatemessage', Options.Sounds.NewPM.Path);

  ComponentModuleWindow.Settings.WriteBoolean('sounds\botpm_on', Options.Sounds.BotPM.Enabled);
  ComponentModuleWindow.Settings.WriteString('sounds\botpm', Options.Sounds.BotPM.Path);

  ComponentModuleWindow.Settings.WriteBoolean('sounds\errormsg_on', Options.Sounds.ErrorMessage.Enabled);
  ComponentModuleWindow.Settings.WriteString('sounds\errormsg', Options.Sounds.ErrorMessage.Path);

  ComponentModuleWindow.Settings.WriteBoolean('sounds\friendonline_on', Options.Sounds.FriendOn.Enabled);
  ComponentModuleWindow.Settings.WriteString('sounds\friendonline', Options.Sounds.FriendOn.Path);

  ComponentModuleWindow.Settings.WriteBoolean('sounds\friendoffline_off', Options.Sounds.FriendOff.Enabled);
  ComponentModuleWindow.Settings.WriteString('sounds\friendoffline', Options.Sounds.FriendOff.Path);

  ComponentModuleWindow.Settings.WriteBoolean('sounds\highlighted_on', Options.Sounds.Highlighted.Enabled);
  ComponentModuleWindow.Settings.WriteString('sounds\highlighted', Options.Sounds.Highlighted.Path);

  ComponentModuleWindow.Settings.WriteBoolean('sounds\lobbyfull_on', Options.Sounds.LobbyFull.Enabled);
  ComponentModuleWindow.Settings.WriteString('sounds\lobbyfull', Options.Sounds.LobbyFull.Path);

  // Warcraft III
  ComponentModuleWindow.Settings.WriteString('wc3\path', Options.WC3.Path);
  ComponentModuleWindow.Settings.WriteString('wc3\params', Options.WC3.Params);
  ComponentModuleWindow.Settings.WriteBoolean('wc3\windowed', Options.WC3.Windowed);
  ComponentModuleWindow.Settings.WriteBoolean('wc3\opengl', Options.WC3.OpenGL);
  ComponentModuleWindow.Settings.WriteBoolean('wc3\maximize', Options.WC3.Maximize);
  ComponentModuleWindow.Settings.WriteString('wc3\language', Options.WC3.Language);

  // Customize panel
  ComponentModuleWindow.Settings.WriteString('client\skin', Options.Customize.Skin);
  ComponentModuleWindow.Settings.WriteInteger('client\statusicons', Options.Customize.StatusIcons);
  ComponentModuleWindow.Settings.WriteBoolean('client\fadeineffect', Options.Customize.FadeInEffect);
end;

function AskForWC3Path : Boolean;
var
  diSelectWC3 : TspSkinSelectDirectoryDialog;
begin
  diSelectWC3 := TspSkinSelectDirectoryDialog.Create(nil);
  diSelectWC3.CtrlSkinData := ComponentModuleWindow.sppMain;
  diSelectWC3.SkinData := ComponentModuleWindow.sppMain;
  diSelectWC3.Directory := Options.WC3.Path;
  diSelectWC3.Title := RS_SELECT_WC3;
  result := diSelectWC3.Execute;
  Options.WC3.Path := diSelectWC3.Directory;
  Options.WC3.Exe := ITB(Options.WC3.Path) + 'war3.exe';
  diSelectWC3.Free;
end;

procedure SortMessages;
var
  C1, C2 : Integer;
  tmp    : TUserMessage;
begin
  For C1 := 0 to UserDetails.Messages.Count - 2 Do
    For C2 := C1 + 1 to UserDetails.Messages.Count - 1 Do
      If UserDetails.Messages.Items[C1].MessageDateTime < UserDetails.Messages.Items[C2].MessageDateTime Then
      Begin
        tmp := UserDetails.Messages.Items[C1];
        UserDetails.Messages.Items[C1] := UserDetails.Messages.Items[C2];
        UserDetails.Messages.Items[C2] := tmp;
      End;
end;

procedure SortRequests;
var
  C1, C2 : Integer;
  tmp    : TUserRequest;
begin
  For C1 := 0 to UserDetails.Requests.Count - 2 Do
    For C2 := C1 + 1 to UserDetails.Requests.Count - 1 Do
      If UserDetails.Requests.Items[C1].MessageDateTime < UserDetails.Requests.Items[C2].MessageDateTime Then
      Begin
        tmp := UserDetails.Requests.Items[C1];
        UserDetails.Requests.Items[C1] := UserDetails.Requests.Items[C2];
        UserDetails.Requests.Items[C2] := tmp;
      End;
end;


procedure ParseMyDetails(const ADetails : WideString);
type
  TRequestConst = record
                    AS_STRING : String;
                    AS_TYPE   : TRequestType;
                  end;
const
  REQ_TYPES_COUNT = 3;
  REQ_TYPES       : Array[0..REQ_TYPES_COUNT - 1] of TRequestConst = ((AS_STRING: 'friendrequests'; AS_TYPE: rtFriend),
                                                                      (AS_STRING: 'teamrequests'; AS_TYPE: rtTeam),
                                                                      (AS_STRING: 'tournamentrequests'; AS_TYPE: rtTournament));
var
  JSON        : ISuperObject;
  JSTMP       : ISuperObject;
  JSTMP1      : ISuperObject;
  jsitem      : TSuperObjectIter;
  response    : WideString;
  userinfo    : TUserInfo;
  C1          : Integer;
  dup         : Boolean;
  fmtSett     : TFormatSettings;
  name, value : String;
begin
  JSON := TSuperObject.ParseString(Addr(ADetails[1]), FALSE);

  UserDetails.Username := JSON.S['username'];
  UserDetails.EMail := JSON.S['email'];
  UserDetails.FirstName := JSON.S['first_name'];
  UserDetails.LastName := JSON.S['last_name'];
  UserDetails.Sex := JSON.S['sex'];
  UserDetails.Birthday := JSON.S['birthday'];
  UserDetails.Country := JSON.S['country'];
  UserDetails.Avatar := JSON.S['avatar'];
  UserDetails.Coins := JSON.I['coins'];
  UserDetails.Colored := JSON.S['colour'] = 'TRUE';

  userinfo.Username := UserDetails.Username;
  userinfo.Country := UserDetails.Country;
  userinfo.Area := 2;
  userinfo.Avatar := UserDetails.Avatar;
  userinfo.IsFriend_PVPGN := FALSE;
  userinfo.IsFriend_Site := FALSE;
  userinfo.IsMyself := TRUE;
  userinfo.Coins := UserDetails.Coins;
  response := JSON.S['user_stats'];
  JSTMP := TSuperObject.ParseString(Addr(response[1]), FALSE);
  userinfo.Stats.Wins := JSTMP.I['wins'];
  userinfo.Stats.Losses := JSTMP.I['losses'];
  userinfo.Stats.Kills := JSTMP.I['kills'];
  userinfo.Stats.LeaveCount := JSTMP.I['leavecount'];
  userinfo.Stats.Rating := JSTMP.I['rating'];
  userinfo.Stats.RatingPro := JSTMP.I['ratingpro'];
  userinfo.Stats.TotalGames := JSTMP.I['totalgames'];
  userinfo.Stats.Title := JSTMP.S['title'];
  userinfo.Stats.Rank := JSTMP.I['rank'];
  userinfo.Stats.Deaths := JSTMP.I['deaths'];
  userinfo.Stats.RatingD := JSTMP.D['ratingd'];
  JSTMP := nil;

  UserDetails.NativeChannel := ROOMS[GetUserRoom(userinfo.Stats.Rating)];
  UserDetails.Level := CalculateLevel(userinfo.Stats.Wins, userinfo.Stats.Losses, UserDetails.Experience, UserDetails.NextLevelExp);

  AddUserToList(userinfo);

  If not Assigned(UserDetails.FriendRequests_IDs) Then
    UserDetails.FriendRequests_IDs := TStringList.Create;
  If not Assigned(UserDetails.FriendRequests_Names) Then
    UserDetails.FriendRequests_Names := TStringList.Create;
  If not Assigned(UserDetails.FriendRequests_Processed) Then
    UserDetails.FriendRequests_Processed := TStringList.Create;
{
  UserDetails.FriendRequests_IDs.Clear;
  UserDetails.FriendRequests_Names.Clear;
  UserDetails.FriendRequests_Processed.Clear;
}
  response := JSON.S['friend_requests'];
  JSTMP := TSuperObject.ParseString(Addr(response[1]), FALSE);
  If ObjectFindFirst(JSTMP, jsitem) Then
  Begin
    repeat
      dup := FALSE;
      For C1 := 0 to UserDetails.FriendRequests_Names.Count - 1 Do
        If UserDetails.FriendRequests_Names.Strings[C1] = jsitem.val.AsString Then
        Begin
          dup := TRUE;
          Break;
        End;

      If not dup Then
      Begin
        UserDetails.FriendRequests_IDs.Add(jsitem.key);
        UserDetails.FriendRequests_Names.Add(jsitem.val.AsString);
        UserDetails.FriendRequests_Processed.Add('0');
      End;
    until not ObjectFindNext(jsitem);
    ObjectFindClose(jsitem);
  End;
  JSTMP := nil;

  For C1 := 0 to Users.Count - 1 Do
  Begin
    Users.Items[C1].IsFriend_PVPGN := FALSE;
    Users.Items[C1].IsFriend_Site := FALSE;
  End;

  response := JSON.S['friend_list'];
  JSTMP := TSuperObject.ParseString(Addr(response[1]), FALSE);
  If ObjectFindFirst(JSTMP, jsitem) Then
  Begin
    repeat
      ZeroMemory(@userinfo, SizeOf(TUserInfo));

      userinfo.Username := jsitem.key;
      userinfo.Country := jsitem.val.S['country'];
      userinfo.Area := 0;
      userinfo.Avatar := jsitem.val.S['avatar'];
      userinfo.IsFriend_PVPGN := FALSE;
      userinfo.IsFriend_Site := TRUE;
      userinfo.IsMyself := FALSE;
      userinfo.Coins := 0;

      userinfo.Stats.Wins := jsitem.val.I['wins'];
      userinfo.Stats.Losses := jsitem.val.I['losses'];
      userinfo.Stats.Kills := jsitem.val.I['kills'];
      userinfo.Stats.LeaveCount := jsitem.val.I['leavecount'];
      userinfo.Stats.Rating := jsitem.val.I['rating'];
      userinfo.Stats.RatingPro := jsitem.val.I['ratingpro'];
      userinfo.Stats.TotalGames := jsitem.val.I['totalgames'];
      userinfo.Stats.Title := jsitem.val.S['title'];
      userinfo.Stats.Rank := jsitem.val.I['rank'];
      userinfo.Stats.Deaths := jsitem.val.I['deaths'];
      userinfo.Stats.RatingD := jsitem.val.D['ratingd'];

      AddUserToList(userinfo);
      SetUserInfo_Friend_PVPGN(userinfo.Username, FALSE);
      SetUserInfo_Friend_Site(userinfo.Username, TRUE);
    until not ObjectFindNext(jsitem);
    ObjectFindClose(jsitem);
  End;
  JSTMP := nil;

  ProtectedChannels.Count := 0;
  SetLength(ProtectedChannels.Items, ProtectedChannels.Count);
  response := JSON.S['protected_chann'];
  JSTMP := TSuperObject.ParseString(Addr(response[1]), FALSE);
  If ObjectFindFirst(JSTMP, jsitem) Then
  Begin
    repeat
      Inc(ProtectedChannels.Count);
      SetLength(ProtectedChannels.Items, ProtectedChannels.Count);
      ProtectedChannels.Items[ProtectedChannels.Count - 1].Channel := jsitem.val.S['name'];
      ProtectedChannels.Items[ProtectedChannels.Count - 1].Password := jsitem.val.S['password'];
    until not ObjectFindNext(jsitem);
    ObjectFindClose(jsitem);
  End;
  JSTMP := nil;

  Blocklist.Clear;
  OthersBlocklist.Clear;
  
  response := JSON.S['my_block_list'];
  JSTMP := TSuperObject.ParseString(Addr(response[1]), FALSE);
  If ObjectFindFirst(JSTMP, jsitem) Then
  Begin
    repeat
      BlockList.Add(jsitem.val.AsString);
    until not ObjectFindNext(jsitem);
    ObjectFindClose(jsitem);
  End;
  JSTMP := nil;

  response := JSON.S['others_block_list'];
  JSTMP := TSuperObject.ParseString(Addr(response[1]), FALSE);
  If ObjectFindFirst(JSTMP, jsitem) Then
  Begin
    repeat
      OthersBlockList.Add(jsitem.val.AsString);
    until not ObjectFindNext(jsitem);
    ObjectFindClose(jsitem);
  End;
  JSTMP := nil;

  UserDetails.Tour.CS := JSON.I['cs'];
  UserDetails.Tour.TGID := JSON.I['tgid'];
  UserDetails.Tour.TD := JSON.I['td'];
  UserDetails.Tour.TN := JSON.S['tn'];

  UserDetails.Messages.Count := 0;
  SetLength(UserDetails.Messages.Items, UserDetails.Messages.Count);
  fmtSett.DateSeparator := '-';
  fmtSett.TimeSeparator := ':';
  fmtSett.ShortDateFormat := 'YYYY MM DD';
  fmtSett.LongTimeFormat := 'HH MM SS';
  response := JSON.S['messages'];
  JSTMP := TSuperObject.ParseString(Addr(response[1]), FALSE);
  If ObjectFindFirst(JSTMP, jsitem) Then
  Begin
    repeat
      Inc(UserDetails.Messages.Count);
      SetLength(UserDetails.Messages.Items, UserDetails.Messages.Count);
      UserDetails.Messages.Items[UserDetails.Messages.Count - 1].UID := jsitem.val.I['user_id'];
      UserDetails.Messages.Items[UserDetails.Messages.Count - 1].Username := jsitem.val.S['username'];
      UserDetails.Messages.Items[UserDetails.Messages.Count - 1].Avatar := jsitem.val.S['avatar'];
      UserDetails.Messages.Items[UserDetails.Messages.Count - 1].Text := jsitem.val.S['message'];
      UserDetails.Messages.Items[UserDetails.Messages.Count - 1].MessageDateTime := StrToDateTime(jsitem.val.S['date'], fmtSett);
      UserDetails.Messages.Items[UserDetails.Messages.Count - 1].ServerDateTime := StrToDateTime(jsitem.val.S['server_time'], fmtSett);
      UserDetails.Messages.Items[UserDetails.Messages.Count - 1].Unread := LowerCase(jsitem.val.S['status']) = 'no';
    until not ObjectFindNext(jsitem);
    ObjectFindClose(jsitem);
  End;
  JSTMP := nil;
  SortMessages;

  UserDetails.Requests.Count := 0;
  SetLength(UserDetails.Requests.Items, UserDetails.Requests.Count);
  response := JSON.S['requests'];
  JSTMP := TSuperObject.ParseString(Addr(response[1]), FALSE);

  For C1 := 0 to REQ_TYPES_COUNT - 1 Do
  Begin
    JSTMP1 := TSuperObject.ParseString(Addr(JSTMP.S[REQ_TYPES[C1].AS_STRING][1]), FALSE);
    If ObjectFindFirst(JSTMP1, jsitem) Then
    Begin
      repeat
        Inc(UserDetails.Requests.Count);
        SetLength(UserDetails.Requests.Items, UserDetails.Requests.Count);
        UserDetails.Requests.Items[UserDetails.Requests.Count - 1].RequestType := REQ_TYPES[C1].AS_TYPE;
        UserDetails.Requests.Items[UserDetails.Requests.Count - 1].ReqID := jsitem.val.I['id'];
        UserDetails.Requests.Items[UserDetails.Requests.Count - 1].FromID := jsitem.val.I['fromid'];
        UserDetails.Requests.Items[UserDetails.Requests.Count - 1].Username := jsitem.val.S['username'];
        UserDetails.Requests.Items[UserDetails.Requests.Count - 1].Text := jsitem.val.S['message'];
        UserDetails.Requests.Items[UserDetails.Requests.Count - 1].MessageDateTime := StrToDateTime(jsitem.val.S['date'], fmtSett);
        UserDetails.Requests.Items[UserDetails.Requests.Count - 1].ServerDateTime := StrToDateTime(jsitem.val.S['server_time'], fmtSett);
      until not ObjectFindNext(jsitem);
      ObjectFindClose(jsitem);
    End;
    JSTMP1 := nil;
  End;
  JSTMP := nil;
  SortRequests;

  response := JSON.S['settings'];
  JSTMP := TSuperObject.ParseString(Addr(response[1]), FALSE);
  If ObjectFindFirst(JSTMP, jsitem) Then
  Begin
    repeat
      name := jsitem.val.S['name'];
      value := jsitem.val.S['value'];

      If name = 'currentversion' Then
        ClientSettings.CurrentVersion := value;
      If name = 'fullclient' Then
        ClientSettings.FullClient := value;
      If name = 'mainbanner' Then
        ClientSettings.MainBanner.Image := value;
      If name = 'mainbannerurl' Then
        ClientSettings.MainBanner.Link := value;
      If name = 'mainbannerhash' Then
        ClientSettings.MainBanner.Hash := value;
      If name = 'userbanner' Then
        ClientSettings.UserBanner.Image := value;
      If name = 'userbannerurl' Then
        ClientSettings.UserBanner.Link := value;
      If name = 'userbannerhash' Then
        ClientSettings.UserBanner.Hash := value;
      If name = 'announcement' Then
        ClientSettings.AnnouncementText := value;
      If name = 'announcementcolor' Then
        ClientSettings.AnnouncementColor := HexToColor(value);
      If name = 'gproxy_hash' Then
        ClientSettings.GProxyHash := value;
      If name = 'gproxy_url' Then
        ClientSettings.GProxyURL := value;
      If name = 'antimh' Then
        ClientSettings.AntiMaphack := value = '1';
      If name = 'peertopeer' Then
        Case StrToIntDef(value, 0) of
          0 : P2PTYPE := p2pNone;
          1 : P2PTYPE := p2pPVPGN;
        End;
    until not ObjectFindNext(jsitem);
    ObjectFindClose(jsitem);
  End;
  JSTMP := nil;

  JSON := nil;
end;

function FormatTimeDifference(const AYears, AMonths, ADays, AHours, AMinutes, ASeconds : Integer) : String;
begin
  If AYears > 0 Then
    If AYears = 1 Then
      result := RS_TIME_YEAR_AGO
    else
      result := Format(RS_TIME_YEARS_AGO, [AYears])
  else
    If AMonths > 0 Then
      If AMonths = 1 Then
        result := RS_TIME_MONTH_AGO
      else
        result := Format(RS_TIME_MONTHS_AGO, [AMonths])
    else
      If ADays > 0 Then
        If ADays = 1 Then
          result := RS_TIME_DAY_AGO
        else
          result := Format(RS_TIME_DAYS_AGO, [ADays])
      else
        If AHours > 0 Then
          If AHours = 1 Then
            result := RS_TIME_HOUR_AGO
          else
            result := Format(RS_TIME_HOURS_AGO, [AHours])
        else
          If AMinutes > 0 Then
            If AMinutes = 1 Then
              result := RS_TIME_MINUTE_AGO
            else
              result := Format(RS_TIME_MINUTES_AGO, [AMinutes])
          else
            If ASeconds > 0 Then
              If ASeconds = 1 Then
                result := RS_TIME_SECOND_AGO
              else
                result := Format(RS_TIME_SECONDS_AGO, [ASeconds]);
end;

function InstallURLProtocol : DWORD;
begin
  result := RegWriteString(HKEY_CLASSES_ROOT, 'Darer', 'URL Protocol', '');
  If result = ERROR_SUCCESS Then
    result := RegWriteString(HKEY_CLASSES_ROOT, 'Darer\shell\open\command', '', Format('"%s" "%%1"', [SelfExe]))
end;

procedure UninstallURLProtocol;
var
  reg : TRegistry;
begin
  reg := TRegistry.Create;
  try
    reg.RootKey := HKEY_CLASSES_ROOT;
    reg.DeleteKey('Darer');
  finally
    reg.Free;
  end;
end;

procedure RegisterReplayExtension;
var
  reg : TRegistry;
  str : String;
begin
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CLASSES_ROOT;
  If reg.OpenKey('.w3g', TRUE) Then
  Begin
    str := reg.ReadString('');
    If str = '' Then
    Begin
      str := 'Warcraft3.Replay';
      reg.WriteString('', str);
    End;
    reg.CloseKey;

    If reg.OpenKey(Format('%s\shell\open\command', [str]), TRUE) Then
    Begin
      reg.WriteString('', Format('"%s" -replay "%%1"', [SelfExe]));
      reg.CloseKey;
    End;
  End;
  reg.Free;
end;

procedure UnregisterReplayExtension;
var
  reg : TRegistry;
  str : String;
begin
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CLASSES_ROOT;
  If reg.OpenKey('.w3g', TRUE) Then
  Begin
    str := reg.ReadString('');
    If str = '' Then
    Begin
      str := 'Warcraft3.Replay';
      reg.WriteString('', str);
    End;
    reg.CloseKey;

    If reg.OpenKey(Format('%s\shell\open\command', [str]), TRUE) Then
    Begin
      reg.WriteString('', Format('"%s" -loadfile "%%1"', [Options.WC3.Exe]));
      reg.CloseKey;
    End;
  End;
  reg.Free;
end;

function IsReplaysAssociated : Boolean;
var
  reg : TRegistry;
  str : String;
begin
  result := FALSE;
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CLASSES_ROOT;
  If reg.OpenKey('.w3g', TRUE) Then
  Begin
    str := reg.ReadString('');
    If str = '' Then
    Begin
      str := 'Warcraft3.Replay';
      reg.WriteString('', str);
    End;
    reg.CloseKey;

    If reg.OpenKey(Format('%s\shell\open\command', [str]), TRUE) Then
    Begin
      result := reg.ReadString('') = Format('"%s" -replay "%%1"', [SelfExe]);
      reg.CloseKey;
    End;
  End;
  reg.Free;
end;

procedure AddUserToList(const AUserInfo : TUserInfo);
var
  index    : Integer;
  oldInfo  : TUserInfo;
  newUser  : Boolean;
begin
  newUser := FALSE;
  index := FindUser(AUserInfo.Username);

  If index = -1 Then
  Begin
    Inc(Users.Count);
    SetLength(Users.Items, Users.Count);
    SetLength(Users.Avatar, Users.Count);
    index := Users.Count - 1;
    Users.Avatar[index].ID145 := -1;
    Users.Avatar[index].ID35 := -1;
    newUser := TRUE;
  End;

  oldInfo := Users.Items[index];

  Users.Items[index] := AUserInfo;

  If not newUser Then
  Begin
    Users.Items[index].IsFriend_Site := oldInfo.IsFriend_Site;
    Users.Items[index].IsFriend_PVPGN := oldInfo.IsFriend_PVPGN;
    Users.Items[index].Area := oldinfo.Area;
  End;

  If UserDetails.Username = AUserInfo.Username Then
    Users.Items[index].IsMyself := TRUE;
end;

function FindUser(const AUsername : String) : Integer;
var
  C1 : Integer;
begin
  result := -1;
  For C1 := 0 to Users.Count - 1 Do
    If Users.Items[C1].Username = AUsername Then
    Begin
      result := C1;
      Break;
    End;
end;


function SetUserInfo_Friend_Site(const AUsername : String; const AFriend : Boolean) : Boolean;
var
  C1 : Integer;
begin
  result := FALSE;
  For C1 := 0 to Users.Count - 1 Do
    If Users.Items[C1].Username = AUsername Then
    Begin
      Users.Items[C1].IsFriend_Site := AFriend;
      result := TRUE;
      Break;
    End;
end;

function SetUserInfo_Friend_PVPGN(const AUsername : String; const AFriend : Boolean) : Boolean;
var
  C1 : Integer;
begin
  result := FALSE;
  For C1 := 0 to Users.Count - 1 Do
    If Users.Items[C1].Username = AUsername Then
    Begin
      Users.Items[C1].IsFriend_PVPGN := AFriend;
      result := TRUE;
      Break;
    End;
end;

function ParseResponse(const AResponse : String; var AType : Char; var ACode : Integer) : Boolean;
begin
  result := FALSE;
  If Length(AResponse) = 5 Then
  Begin
    AType := AResponse[1];
    ACode := StrToIntDef(Copy(AResponse, 2, 4), 0);

    result := (AType in ['A', 'E']) and (ACode > 0);
  End;
end;

function TranslateResponse(const AType : Char; const ACode : Integer) : String;
begin
  result := Format(RS_RESPONSE_UNKNOWN, [AType, ACode]);
  Case AType of
    'A' : Case ACode of
            0001 : result := RS_RESPONSE_REGISTER_EMAIL_SENT;
            0002 : result := RS_RESPONSE_CHANNEL_ADDED;
            0003 : result := RS_RESPONSE_CHANNEL_PASSWORD_CHANGED;
            0004 : result := RS_RESPONSE_REQUEST_SENT;
            0005 : result := RS_RESPONSE_CONFIRMED_REQUEST;
            0006 : result := RS_RESPONSE_USER_UNBLOCKED;
            0007 : result := RS_RESPONSE_USER_BLOCKED;
            0008 : result := '';
          End;
    'E' : Case ACode of
            0001 : result := RS_RESPONSE_COULD_NOT_SEND_EMAIL;
            0002 : result := RS_RESPONSE_USERNAME_TAKEN;
            0003 : result := RS_RESPONSE_EMAIL_ALREADY_USED;
            0004 : result := RS_RESPONSE_CAPTCHA_ERROR;
            0005 : result := RS_RESPONSE_REQ_LIMIT_REACHED;
            0006 : result := RS_RESPONSE_INVALID_KEY;
            0007 : result := RS_RESPONSE_INVALID_USERNAME;
            0008 : result := RS_RESPONSE_ALREADY_A_FRIEND;
            0009 : result := RS_RESPONSE_INVALID_CONFIRMATION;
            0010 : result := RS_RESPONSE_INVALID_POSTS;
            0011 : result := RS_RESPONSE_INVALID_USER;
            0012 : result := RS_RESPONSE_NOT_CHANNEL_OWNER;
            0015 : result := RS_RESPONSE_INVALID_USERPASS;
            0016 : result := RS_RESPONSE_ALREADY_SENT_REQ;
            0017 : result := RS_RESPONSE_CHANNEL_RESERVED;
            0018 : result := RS_RESPONSE_ACCOUNT_NOT_ACTIVATED;
          End;
  End;
end;

function CalculateLevelExperience(const ALevel : Integer) : Integer;
begin
  result := Trunc(VAR_LEVEL_BASE * Power(ALevel, VAR_LEVEL_POWER));
end;

function CalculateLevel(const AWins, ALosses : Integer; var ACurrentExperience, ANextExperience : Integer) : Integer;
var
  totalExp : Integer;
  levelExp : Integer;
begin
  totalExp := AWins * 30 + ALosses * 10;
  result := Trunc(Power(totalExp / VAR_LEVEL_BASE, 1 / VAR_LEVEL_POWER));
  If result = 0 Then
    result := 1;
  levelExp := CalculateLevelExperience(result);
  ACurrentExperience := totalExp - levelExp;
  ANextExperience := CalculateLevelExperience(result + 1) - levelExp;
end;

function IsValidRoom(const ARating : Integer; const ARoom : String; var AError : String) : Boolean;
var
  C1 : Integer;
begin
  result := TRUE;

  For C1 := GetUserRoom(ARating) + 1 to ROOM_COUNT - 1 Do
    If LowerCase(ROOMS[C1]) = LowerCase(ARoom) Then
    Begin
      result := FALSE;
      AError := RS_CHANNEL_NO_ACCESS;
      Break;
    End;

  If ARoom = '' Then
  Begin
    result := FALSE;
    AError := '';
  End;
end;

end.

