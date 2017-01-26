{$I ..\defines.inc}

unit MainWin;

interface             

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, SkinCtrls, ExtCtrls, StdCtrls, GProxy, 
  RVScroll, RichView, RVStyle, Menus, TntMenus, ImgList, ComCtrls, SkinTabs, Mask,
  SkinBoxCtrls, SkinExCtrls, sppngimagelist, JvComponentBase, JvThread,
  SkinMenus, GraphicEx, imageen, OverbyteIcsWndControl, OverbyteIcsHttpProt,
  TntStdCtrls, RVTable, SkinGrids, SkinHint, JvAppEvent, JvThreadTimer, SharedData;

type
  TTabType = (ctUnknown, ctIRC_Raw, ctIRC_Channel, ctIRC_User, ctPVPGN_Raw, ctPVPGN_Channel, ctPVPGN_User);
  TTabInfo = record
               TabType        : TTabType;
               Data           : WideString;
               ChatHistory    : Array of WideString;
               ChatHistoryPos : Integer;
               TabControl     : TWinControl;
               Flashing       : Boolean;
             end;

  TTabInfos = record
                Count : Integer;
                Items : Array of TTabInfo;
              end;

  TGameCount = record
                 All       : Integer;
                 Free      : Integer;
                 Ladder    : Integer;
                 Challenge : Integer;
                 Running   : Integer;
                 Today     : Integer;
               end;

  TGameStatus = (gsOpen, gsStarted);
  TGameType   = (gtFree, gtLadder, gtUnknown);

  TGame     = record
                UniqID    : Integer;
                Status    : TGameStatus;
                Type_     : TGameType;
                Country   : String;
                FlagIndex : Integer;
                Host      : String;
                Slots     : String;
                Mode      : String;
              end;

  TGameList = record
                Count : Integer;
                Items : Array of TGame;
              end;

  TMainWindow = class(TForm)
    SkinForm: TspDynamicSkinForm;
    mmMenu: TTntMainMenu;
    smExit: TTntMenuItem;
    smLogout: TTntMenuItem;
    mmHelp: TTntMenuItem;
    mmLanguage: TTntMenuItem;
    mmOptions: TTntMenuItem;
    mmFile: TTntMenuItem;
    smAbout: TTntMenuItem;
    N6: TTntMenuItem;
    smSupport: TTntMenuItem;
    smReportBug: TTntMenuItem;
    N5: TTntMenuItem;
    smTutorial: TTntMenuItem;
    styleChatbox: TRVStyle;
    StatusBar: TspSkinStatusBar;
    paCntRight: TspSkinPanel;
    paInCntRight: TspSkinPanel;
    paServerStatistics: TspSkinPanel;
    paGames: TspSkinPanel;
    paGamesAll: TspSkinPanel;
    lbGamesAllVal: TspSkinShadowLabel;
    lbGamesAll: TspSkinShadowLabel;
    paGamesLadder: TspSkinPanel;
    lbGamesLadder: TspSkinShadowLabel;
    lbGamesLadderVal: TspSkinShadowLabel;
    paGamesFree: TspSkinPanel;
    lbGamesFree: TspSkinShadowLabel;
    lbGamesFreeVal: TspSkinShadowLabel;
    paGamesChallenge: TspSkinPanel;
    lbGamesChallenge: TspSkinShadowLabel;
    lbGamesChallengeVal: TspSkinShadowLabel;
    paOnline: TspSkinPanel;
    paOnlinePlayers: TspSkinPanel;
    lbOnlinePlayersVal: TspSkinShadowLabel;
    lbOnlinePlayers: TspSkinShadowLabel;
    paOnlineFriends: TspSkinPanel;
    lbOnlineFriends: TspSkinShadowLabel;
    lbOnlineFriendsVal: TspSkinShadowLabel;
    paGame: TspSkinPanel;
    pcGame: TspSkinPageControl;
    tsGame: TspSkinTabSheet;
    paGameType: TspSkinPanel;
    paInGameType: TspSkinPanel;
    lbGameType: TspSkinShadowLabel;
    cbGameType: TspSkinComboBox;
    paGameMode: TspSkinPanel;
    paInGameMode: TspSkinPanel;
    lbGameMode: TspSkinShadowLabel;
    cbGameMode: TspSkinComboBox;
    paGameDefault: TspSkinPanel;
    paCntLeft: TspSkinPanel;
    paFriends: TspSkinPanel;
    paPlayerInfo: TspSkinPanel;
    paCntCenter: TspSkinPanel;
    paChat: TspSkinPanel;
    cntChat: TspSkinPageControl;
    paBanner: TspSkinPanel;
    imgMainBanner: TspPngImageView;
    ilMainBanner: TspPngImageList;
    paPlayerInfoStatistic: TspSkinPanel;
    paMyAvatar: TspSkinPanel;
    pcFriends: TspSkinPageControl;
    tsFriends: TspSkinTabSheet;
    pmUsersListbox: TspSkinPopupMenu;
    smChat: TMenuItem;
    N7891: TMenuItem;
    smAddToFriends: TMenuItem;
    N1: TMenuItem;
    smKick: TMenuItem;
    smBan: TMenuItem;
    smPing: TMenuItem;
    pasLFriends: TspSkinPanel;
    pasRFriends: TspSkinPanel;
    paInFriends: TspSkinPanel;
    paSearchFriends: TspSkinPanel;
    ebSearchFriends: TspSkinEdit;
    tiPVPGNUsersUpdate: TTimer;
    pasRAvatar: TspSkinPanel;
    pasLAvatar: TspSkinPanel;
    pasTAvatar: TspSkinPanel;
    pasBAvatar: TspSkinPanel;
    pmChatBox: TspSkinPopupMenu;
    smCopy: TMenuItem;
    N2: TMenuItem;
    smOnlineAdmins: TMenuItem;
    smPingToServer: TMenuItem;
    N3: TMenuItem;
    smShowFriendJoin: TMenuItem;
    smShowFriendLeave: TMenuItem;
    N7: TMenuItem;
    smClear: TMenuItem;
    paCntTop: TspSkinPanel;
    paMainMenu: TspSkinPanel;
    mmBar: TspSkinMainMenuBar;
    paGameButtons: TspSkinPanel;
    ilTabIcons: TspPngImageList;
    paUserInfo: TspSkinPanel;
    paUserInfoAvatar: TspSkinPanel;
    pasTUserInfoAvatar: TspSkinPanel;
    pasRUserInfoAvatar: TspSkinPanel;
    pasBUserInfoAvatar: TspSkinPanel;
    paUserInfoPersonal: TspSkinPanel;
    pasBUserInfo: TspSkinPanel;
    pasTUserInfoPersonal: TspSkinPanel;
    paUserInfoPersonalLeaves: TspSkinPanel;
    imgUserInfoPersonalLeaves: TspPngImageView;
    paUserInfoPersonalLosses: TspSkinPanel;
    imgUserInfoPersonalLosses: TspPngImageView;
    paUserInfoPersonalWins: TspSkinPanel;
    imgUserInfoPersonalWins: TspPngImageView;
    paUserInfoPersonalRating: TspSkinPanel;
    imgUserInfoPersonalRating: TspPngImageView;
    paUserInfoPersonalRank: TspSkinPanel;
    imgUserInfoPersonalRank: TspPngImageView;
    ilUserInfoStats: TspPngImageList;
    pasMUserInfoPersonal1: TspSkinPanel;
    pasMUserInfoPersonal3: TspSkinPanel;
    pasMUserInfoPersonal4: TspSkinPanel;
    pasMUserInfoPersonal5: TspSkinPanel;
    pasLUserInfoPersonalRank: TspSkinPanel;
    pasLUserInfoPersonalRating: TspSkinPanel;
    pasLUserInfoPersonalWins: TspSkinPanel;
    pasLUserInfoPersonalLosses: TspSkinPanel;
    pasLUserInfoPersonalLeaves: TspSkinPanel;
    lbUserInfoPersonalRank: TspSkinShadowLabel;
    lbUserInfoPersonalRating: TspSkinShadowLabel;
    lbUserInfoPersonalWins: TspSkinShadowLabel;
    lbUserInfoPersonalLosses: TspSkinShadowLabel;
    lbUserInfoPersonalLeaves: TspSkinShadowLabel;
    paUserInfoButtons: TspSkinPanel;
    btUserChat: TspSkinButton;
    btUserFriends: TspSkinButton;
    btUserBlock: TspSkinButton;
    btUserStatistics: TspSkinButton;
    tsGames: TspSkinTabSheet;
    paUserInfoPersonalPoints: TspSkinPanel;
    imgUserInfoPersonalPoints: TspPngImageView;
    lbUserInfoPersonalPoints: TspSkinShadowLabel;
    pasLUserInfoPersonalPoints: TspSkinPanel;
    pasMUserInfoPersonal2: TspSkinPanel;
    paGamesStarted: TspSkinPanel;
    lbGamesRunning: TspSkinShadowLabel;
    lbGamesRunningVal: TspSkinShadowLabel;
    paGamesToday: TspSkinPanel;
    lbGamesToday: TspSkinShadowLabel;
    lbGamesTodayVal: TspSkinShadowLabel;
    paInGamePassword: TspSkinPanel;
    lbGamePassword: TspSkinShadowLabel;
    paInGameObs: TspSkinPanel;
    chbGameObs: TspSkinCheckRadioBox;
    btGameHost: TspSkinButton;
    ilColorBoxes: TspPngImageList;
    ilUserBanner: TspPngImageList;
    paUserInfoBanner: TspSkinPanel;
    imgUserInfoBanner: TspPngImageView;
    tiHostTimeout: TTimer;
    paPlayerStatPoints: TspSkinPanel;
    imgPlayerStatPoints: TspPngImageView;
    lbPlayerStatPoints: TspSkinShadowLabel;
    pasLPlayerStatPoints: TspSkinPanel;
    paPlayerStatPersonalRank: TspSkinPanel;
    imgPlayerStatRank: TspPngImageView;
    lbPlayerStatRank: TspSkinShadowLabel;
    pasLPlayerStatRank: TspSkinPanel;
    paPlayerStatRating: TspSkinPanel;
    imgPlayerStatRating: TspPngImageView;
    lbPlayerStatRating: TspSkinShadowLabel;
    pasLPlayerStatRating: TspSkinPanel;
    pasMPlayerInfoStatistics: TspSkinPanel;
    paInMyAvatar: TspSkinPanel;
    imgMyAvatar: TspPngImageView;
    btGameStart: TspSkinSpeedButton;
    paGamesHeader: TspSkinPanel;
    lbGamesHost: TspSkinShadowLabel;
    lbGamesType: TspSkinShadowLabel;
    lbGamesMode: TspSkinShadowLabel;
    lbGamesSlots: TspSkinShadowLabel;
    lbGamesStatus: TspSkinShadowLabel;
    bevelGames: TspSkinBevel;
    pasTGames: TspSkinPanel;
    paGameList: TspSkinPanel;
    sgGameList: TspSkinStringGrid;
    paGameListScroll: TspSkinPanel;
    sbGameList: TspSkinScrollBar;
    paGamesFooter: TspSkinPanel;
    imgSortStatus: TspPngImageView;
    imgSortType: TspPngImageView;
    imgSortHost: TspPngImageView;
    imgSortSlots: TspPngImageView;
    imgSortMode: TspPngImageView;
    ilSortButtons: TspPngImageList;
    ebSearchGames: TspSkinEdit;
    tiMaphackCode: TTimer;
    lboxFriends: TspSkinOfficeListBox;
    pmFriends: TspSkinPopupMenu;
    smFChat: TMenuItem;
    smFPing: TMenuItem;
    MenuItem8: TMenuItem;
    smFWhereis: TMenuItem;
    N8: TMenuItem;
    smFRemoveFromFriends: TMenuItem;
    paInUserInfoAvatar: TspSkinPanel;
    imgUserInfoAvatar: TspPngImageView;
    ilMyAvatar: TspPngImageList;
    ilAvatars35: TspPngImageList;
    mmLogout: TTntMenuItem;
    mmReportBug: TTntMenuItem;
    appEvents: TJvAppEvents;
    smCommands: TTntMenuItem;
    pmMyselfListBox: TspSkinPopupMenu;
    smMyselfPing: TMenuItem;
    imgMyStatus: TspPngImageView;
    lbMyTitle: TspSkinShadowLabel;
    lbMyUsername: TspSkinShadowLabel;
    imgUserInfoStatus: TspPngImageView;
    lbUserInfoTitle: TspSkinShadowLabel;
    lbUserInfoUsername: TspSkinShadowLabel;
    SkinHint: TspSkinHint;
    ilAvatars145: TspPngImageList;
    tiUserStatsHide: TTimer;
    httpUserData: THttpCli;
    tiUsernameDelayedQueue: TTimer;
    ilUserAvatar: TspPngImageList;
    ilUserStatus: TspPngImageList;
    httpMainBanner: THttpCli;
    httpUserBanner: THttpCli;
    tiAvatarsUpdate: TTimer;
    httpBigAvatar: THttpCli;
    httpSmallAvatar: THttpCli;
    tiAvatarsRefresh: TTimer;
    thdAvatarRefresh: TJvThread;
    tiGameHostCaptionHide: TTimer;
    tsChannels: TspSkinTabSheet;
    lboxChannels: TspSkinListBox;
    paChannelButtons: TspSkinPanel;
    btJoinChannel: TspSkinButton;
    btCreateChannel: TspSkinButton;
    pasTChannelButtons: TspSkinPanel;
    pasBChannelButtons: TspSkinPanel;
    pasRChannelButtons: TspSkinPanel;
    pasLChannelButtons: TspSkinPanel;
    smAddChannelToFavs: TMenuItem;
    pmChannels: TspSkinPopupMenu;
    smRemoveFromFavs: TMenuItem;
    smJoin: TMenuItem;
    N9: TMenuItem;
    paInGamePasswordValues: TspSkinPanel;
    ebPassword: TspSkinEdit;
    ebChallengeFee: TspSkinNumericEdit;
    tiSendCriteria: TTimer;
    tiMyDetailsUpdate: TTimer;
    httpMyDetails: THttpCli;
    httpQuickAPI: THttpCli;
    tiFriendRequests: TTimer;
    mmBlocklist: TTntMenuItem;
    smBlock: TMenuItem;
    N10: TMenuItem;
    httpFriendAPI: THttpCli;
    pmUserStatus: TspSkinPopupMenu;
    smUserStatusOnline: TMenuItem;
    smUserStatusDND: TMenuItem;
    tiGameAutoMinimize: TTimer;
    paClientNotifications: TspSkinPanel;
    paClientNotificationIcon: TspSkinPanel;
    pasRNotificationIcon: TspSkinPanel;
    pasLNotificationIcon: TspSkinPanel;
    pasTNotificationIcon: TspSkinPanel;
    pasBNotificationIcon: TspSkinPanel;
    paInNotificationIcon: TspSkinPanel;
    imgNotificationIcon: TspPngImageView;
    paClientNotificationText: TspSkinPanel;
    lbNotificationHeader: TspSkinShadowLabel;
    ilNotifications: TspPngImageList;
    lbNotificationFooter: TspSkinShadowLabel;
    paProfileButtons: TspSkinPanel;
    ilRefreshIcon: TspPngImageList;
    btMessages: TspSkinButton;
    btRequests: TspSkinButton;
    paMessages: TspSkinPanel;
    lboxMessages: TspSkinOfficeListBox;
    tiMyStatsRefresh: TTimer;
    lbSeeAllMessages: TspSkinShadowLabel;
    paRequests: TspSkinPanel;
    lboxNotifications: TspSkinOfficeListBox;
    N11: TTntMenuItem;
    N4: TTntMenuItem;
    smRepair: TTntMenuItem;
    lbSeeAllRequests: TspSkinShadowLabel;
    pasPlayerInfo: TspSkinPanel;
    paPlayerStatPanel: TspSkinPanel;
    spSkinPanel1: TspSkinPanel;
    spSkinPanel2: TspSkinPanel;
    spSkinPanel3: TspSkinPanel;
    imgRefresh: TspPngImageView;
    tiImgRefreshRotate: TTimer;
    ilNotificationsBig: TspPngImageList;
    imgNotificationSeparator: TspPngImageView;
    ilNotificationSeparator: TspPngImageList;
    lbAnnouncement: TspSkinShadowLabel;
    lbHostingInfo: TspSkinShadowLabel;
    imgHSepWhois: TspPngImageView;
    ilHorizontalSeparator: TspPngImageList;
    imgHSep3: TspPngImageView;
    imgHSep2: TspPngImageView;
    imgHSep1: TspPngImageView;
    imgHSep5: TspPngImageView;
    spSkinPanel4: TspSkinPanel;
    spSkinPanel5: TspSkinPanel;
    spSkinPanel6: TspSkinPanel;
    ilVertStatusDiv: TspPngImageList;
    imgMyNickVertStatusDiv: TspPngImageView;
    imgUserNickVertStatusDiv: TspPngImageView;
    pasTFriendsSearch: TspSkinPanel;
    pasBGames: TspSkinPanel;
    pasLUserButtons: TspSkinPanel;
    spSkinPanel7: TspSkinPanel;
    spSkinPanel8: TspSkinPanel;
    spSkinPanel9: TspSkinPanel;
    spSkinPanel10: TspSkinPanel;
    spSkinPanel11: TspSkinPanel;
    spSkinPanel12: TspSkinPanel;
    spSkinPanel13: TspSkinPanel;
    spSkinBevel1: TspSkinBevel;
    spSkinPanel16: TspSkinPanel;
    spSkinPanel17: TspSkinPanel;
    spSkinPanel18: TspSkinPanel;
    spSkinPanel19: TspSkinPanel;
    spSkinPanel20: TspSkinPanel;
    spSkinPanel21: TspSkinPanel;
    scbLegend: TspSkinScrollBox;
    paLegendFree: TspSkinPanel;
    imgLegendFree: TspPngImageView;
    lbLegendFree: TspSkinShadowLabel;
    paLegendPassword: TspSkinPanel;
    lbLegendPassword: TspSkinShadowLabel;
    imgLegendPassword: TspPngImageView;
    paLegendLadder: TspSkinPanel;
    lbLegendLadder: TspSkinShadowLabel;
    imgLegendLadder: TspPngImageView;
    paLegendTournament: TspSkinPanel;
    lbLegendTournament: TspSkinShadowLabel;
    imgLegendTournament: TspPngImageView;
    paLegendChallenge: TspSkinPanel;
    lbLegendChallenge: TspSkinShadowLabel;
    imgLegendChallenge: TspPngImageView;
    lbGameDefaultSettings: TspSkinShadowLabel;
    spSkinBevel2: TspSkinBevel;
    spSkinPanel22: TspSkinPanel;
    spPngImageView1: TspPngImageView;
    spSkinPanel23: TspSkinPanel;
    spSkinPanel24: TspSkinPanel;
    spSkinPanel25: TspSkinPanel;
    tiMaphackCodeJoin: TTimer;
    paPlayerStatCoins: TspSkinPanel;
    imgPlayerStatCoins: TspPngImageView;
    lbPlayerStatCoins: TspSkinShadowLabel;
    pasLPlayerStatCoins: TspSkinPanel;
    paPlayerInfoLevel: TspSkinPanel;
    gaugeLevel: TspSkinGauge;
    spSkinPanel14: TspSkinPanel;
    spSkinPanel15: TspSkinPanel;
    spSkinPanel26: TspSkinPanel;
    spSkinPanel27: TspSkinPanel;
    spSkinPanel28: TspSkinPanel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure SkinFormMinimize(Sender: TObject);
    procedure AddUserToListbox(const AChatTab : TTabSheet; const ANickname : String);
    procedure RemoveUserFromListbox(const AChatTab : TTabSheet; const ANickname : String);
    procedure OnUDPRead(ASender : TGProxy; const AString : WideString);
    procedure OnCommand(ASender : TGProxy; const ACommand, AParams : WideString);
    procedure OnUserJoin(ASender : TGProxy; const ANickname : WideString);
    procedure OnUserLeave(ASender : TGProxy; const ANickname : WideString);
    procedure OnGetUserList(ASender : TGProxy);
    procedure ebSearchUserChange(Sender: TObject);
    procedure ebSearchUserEnter(Sender: TObject);
    procedure ebSearchUserExit(Sender: TObject);
    procedure smAboutClick(Sender: TObject);
    procedure smSupportClick(Sender: TObject);
    procedure smReportBugClick(Sender: TObject);
    procedure smLogoutClick(Sender: TObject);
    procedure smExitClick(Sender: TObject);
    procedure LocalLocalize;
    function GetChatTabInfo(const AChatTab : TTabSheet) : TTabInfo;
    function DeleteChatTabInfo(const AChatTab : TTabSheet) : Boolean;
    function AddLineToChatTab(const AChatTab : TTabSheet; const ANick, ALine : WideString; const ANickStyle, ALineStyle : Integer) : Boolean;
    procedure mmOptionsClick(Sender: TObject);
    function CanClose : Boolean;
    procedure ircDarerIRCMotd(Sender: TObject; Line: String; EndOfMotd: Boolean);
    procedure ircDarerAfterJoined(Sender: TObject; Channelname: String);
    procedure SendMaphackCode;
    procedure ircDarerServerQuote(Sender: TObject; Command: String);
    procedure ebChatKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ircDarerIRCNickInUse(Sender: TObject; Nickname: String);
    procedure tmpScrollBarChange(Sender: TObject);
    procedure tmpChatboxVScrolled(Sender: TObject);
    procedure cntChatChange(Sender: TObject);
    procedure ebMinRatingKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure lbUsersMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    function GetChatTab(const ACaption : WideString; const ATabType : TTabType) : TTabSheet;
    function CreateChatTab(const ACaption : WideString; const ATabType : TTabType) : TTabSheet;
    function GetPVPGNTab(const ATabType : TTabType; const ACaption : WideString = '') : TTabSheet;
    procedure OnChannelJoin(ASender : TGProxy; const AChannel : WideString);
    procedure cntChatClose(Sender: TObject; var CanClose: Boolean);
    procedure smChatClick(Sender: TObject);
    procedure ebSearchUserKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lbUsersDblClick(Sender: TObject);
    procedure lbUsersKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure smPingClick(Sender: TObject);
    function GetDisconnectPercent(const AUserID : Integer) : Integer;
    procedure ebSearchFriendsExit(Sender: TObject);
    procedure RefreshUserListHeader(const AChatTab : TTabSheet);
    procedure tiPVPGNUsersUpdateTimer(Sender: TObject);
    procedure OnCHATE(ASender : TGProxy; const ACommand, AParams : WideString);
    procedure SaveSettings;
    procedure LoadSettings;
    procedure RealignListBox;
    procedure setUserStatsHints;
    procedure UpdateGameCount;
    procedure smClearClick(Sender: TObject);
    procedure smCopyClick(Sender: TObject);
    procedure smOnlineAdminsClick(Sender: TObject);
    procedure smPingToServerClick(Sender: TObject);
    procedure ChatBoxClick(Sender: TObject);
    function OpenPVPGNUserChat(const AUser : WideString; const AFocus : Boolean) : TTabSheet;
    procedure ChatBoxExit(Sender: TObject);
    procedure OnChannelChat(ASender : TGProxy; const AUser, ALine : WideString);
    procedure OnWhisper(ASender : TGProxy; const AUser, ALine : WideString);
    procedure OnOutWhisper(ASender : TGProxy; const AUser, ALine : WideString);
    procedure SendDebugData;
    procedure OnClick_Update(Sender : TObject);
    procedure RefreshBanners;
    procedure btGameStartClick(Sender: TObject);
    procedure cntChatAfterClose(Sender: TObject);
    procedure BlockUser(const AUser : String);
    procedure DeclineFriend(const AReqID, AUsername : String);
    function PSoundWrapper(const ASound : TSound) : Boolean;
    procedure SendBlocklist;
    procedure smTutorialClick(Sender: TObject);
    procedure JoinCheckRoom(const AChannel : String);
    procedure FlashTab(const AChatTab : TTabSheet; const AFlashing : Boolean = TRUE);
    procedure btGameHostClick(Sender: TObject);
    procedure OnNonCommand(ASender : TGProxy; const APrefix, ALine : WideString);
    procedure lbUsersClick(Sender: TObject);
    procedure ResetBanner;
    procedure ShowBanner;
    procedure ActivateForm;
    procedure lbGameDefaultSettingsClick(Sender: TObject);
    procedure imgUserInfoBannerClick(Sender: TObject);
    procedure imgMainBannerClick(Sender: TObject);
    procedure btCloseChatClick(Sender: TObject);
    procedure tiHostTimeoutTimer(Sender: TObject);
    procedure ShowRequests;
    procedure UpdateGameList;
    procedure UpdateStringGridSize;
    procedure sgGameListDrawCell(Sender: TObject; ACol, ARow: Integer; ARect: TRect; State: TGridDrawState);
    procedure sbGameListChange(Sender: TObject);
    procedure sgGameListSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure smKickClick(Sender: TObject);
    procedure lbGamesStatusClick(Sender: TObject);
    procedure GameListSwap(const ARow1, ARow2 : Integer);
    procedure FillRequestList;
    procedure SortGameList(const AColumn : Integer; const AAscending : Boolean);
    procedure lbGamesTypeClick(Sender: TObject);
    procedure lbGamesHostClick(Sender: TObject);
    procedure ResizeLabel(const ALabel : TspSkinShadowLabel);
    procedure lbGamesSlotsClick(Sender: TObject);
    procedure lbGamesModeClick(Sender: TObject);
    procedure ShowSortButton(const AImage : TspPngImageView; const AIndex : Integer);
    procedure ebSearchGamesChange(Sender: TObject);
    procedure ebSearchGamesExit(Sender: TObject);
    procedure tiMaphackodeTimer(Sender: TObject);
    procedure RefreshAnnouncement;
    procedure lboxFriendsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure lboxFriendsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure lboxFriendsClick(Sender: TObject);
    procedure smFChatClick(Sender: TObject);
    procedure lboxFriendsDblClick(Sender: TObject);
    procedure smFPingClick(Sender: TObject);
    procedure smFWhereisClick(Sender: TObject);
    procedure ShowUserStats(const AUserID : Integer);
    procedure btMyStatisticsClick(Sender: TObject);
    procedure btUserChatClick(Sender: TObject);
    procedure cntChatMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure appEventsShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure smCommandsClick(Sender: TObject);
    procedure SetMyTitle(const ATitle : String);
    procedure SetUserTitle(const ATitle, AName : String);
    procedure ShowPopup(const AHeader, AText : String; const ATimeout : Integer = 5000);
    function GetUserInfo(const AUsername : String; var AUserInfo : TUserInfo) : Boolean;
    procedure PopulateGameTypeCombobox;
    procedure SetUserInfoAvatar(const AUserID : Integer);
    procedure ShowMessages;
    function FindMessage(const AUser, AText : String; var AIndex : Integer) : Boolean;
    function FindRequest(const AUser, AText : String; var AIndex : Integer) : Boolean;
    procedure tiUserStatsHideTimer(Sender: TObject);
    procedure AddUserToPostQueue(const AStringList : TStringList; const AUsername : String);
    procedure PostUserQueue;
    function SetUserInfo_Area(const AUsername : String; const AArea : Integer) : Boolean;
    procedure httpUserDataRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure SetFriendItem(const AListboxIndex : Integer; const AUserID : Integer);
    procedure RefreshFriendList;
    procedure smAddToFriendsClick(Sender: TObject);
    procedure smFRemoveFromFriendsClick(Sender: TObject);
    procedure RemoveFromFriends(const AUsername : String);
    procedure AddToFriends(const AUsername : String);
    procedure ConfirmFriend(const AReqID, AUsername : String);
    procedure SortFriendList;
    procedure SwapLboxFriends(const AIndex1, AIndex2 : Integer);
    procedure ShowMyStats;
    procedure rvChatBoxMouseUp(Sender: TCustomRichView; Button: TMouseButton; Shift: TShiftState; ItemNo, X, Y: Integer);
    procedure EnableHostSettings(const AEnable : Boolean);
    procedure tiUsernameDelayedQueueTimer(Sender: TObject);
    function GetUserStatusIndex(const AStatus : TUserStatus) : Integer;
    function GetUserStatusIndexFromArea(const AArea : Integer) : Integer;
    function FindUserInList(const lbox : TspSkinOfficeListBox; const ANick : WideString) : Integer;
    procedure httpMainBannerRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure httpUserBannerRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure tcpServerDataAvailable(Sender: TObject; ErrCode: Word);
    procedure UnblockUser(const AUser : String);
    procedure LoadAvatarFromFile(const AAvatarPath : String; const AAvatarType : TAvatarType; const AUserID : Integer);
    procedure tiAvatarsUpdateTimer(Sender: TObject);
    procedure httpBigAvatarRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure httpSmallAvatarRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure tiAvatarsRefreshTimer(Sender: TObject);
    function RefreshListboxAvatars(const AListbox : TspSkinOfficeListBox) : Boolean;
    procedure thdAvatarRefreshExecute(Sender: TObject; Params: Pointer);
    procedure thdAvatarRefreshFinish(Sender: TObject);
    procedure imgMyAvatarClick(Sender: TObject);
    procedure tiGameHostCaptionHideTimer(Sender: TObject);
    procedure SetGameHostCaption(const ACaption : String; const AColor : TColor = $0000BB00);
    procedure lboxChannelsListBoxDblClick(Sender: TObject);
    procedure PopulateChannelList;
    procedure AddAvatar(const AImageList : TspPngImageList; const AAvatar : TMemoryStream; const AUserID : Integer; const AAvatarType : TAvatarType);
    procedure smAddChannelToFavsClick(Sender: TObject);
    procedure AddChannelToFavs(const AChannel : String);
    procedure RemoveChannelFromFavs(const AChannel : String);
    function IsChannelFavorite(const AChannel : String) : Integer;
    procedure RefreshChannelMenu;
    procedure pmChatBoxPopup(Sender: TObject);
    procedure SetCriteria(const ARoomNumber, AGameType, AModeType, ARating, ATeamID, ADisc, AChallenge, ARegion, ACountry : Integer; const APassword : String = '~~');
    procedure HostGame(const ARoomNumber, AGameType, AModeType, AMinRating, AMaxRating, ATeamId, ADiscLimit, AChallenge, ARegion, ACountry : Integer; const AGameName, APassword : String; AObservers : Boolean);
    procedure UnhostGame;
    procedure btCreateChannelClick(Sender: TObject);
    procedure btJoinChannelClick(Sender: TObject);
    procedure lboxChannelsListBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure smJoinClick(Sender: TObject);
    procedure smRemoveFromFavsClick(Sender: TObject);
    procedure cbGameTypeChange(Sender: TObject);
    procedure LocalizeChallengeLabel;
    procedure ParseBotWhisper(ASender : TGProxy; const AUser, ALine : WideString);
    procedure ebPasswordChange(Sender: TObject);
    procedure tiSendCriteriaTimer(Sender: TObject);
    procedure ebMinRatingChange(Sender: TObject);
    procedure cbGameModeChange(Sender: TObject);
    procedure JoinChannel(const AChannel : String);
    function IsProtectedChannel(const AChannel : String; var APassword : String) : Boolean;
    procedure FillMessageList;
    procedure tiMyDetailsUpdateTimer(Sender: TObject);
    procedure httpMyDetailsRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure tiFriendRequestsTimer(Sender: TObject);
    procedure mmBlocklistClick(Sender: TObject);
    procedure smBlockClick(Sender: TObject);
    procedure btUserFriendsClick(Sender: TObject);
    procedure btUserBlockClick(Sender: TObject);
    procedure httpFriendAPIRequestDone(Sender: TObject;  RqType: THttpRequest; ErrCode: Word);
    procedure btUserStatisticsClick(Sender: TObject);
    procedure imgMyStatusClick(Sender: TObject);
    procedure smUserStatusOnlineClick(Sender: TObject);
    procedure smUserStatusDNDClick(Sender: TObject);
    procedure smUserStatusOfflineClick(Sender: TObject);
    procedure tiGameAutoMinimizeTimer(Sender: TObject);
    procedure btMessagesClick(Sender: TObject);
    procedure AddNotificationForUser(const AUser : String);
    procedure lboxMessagesMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure mmBarMouseLeave(Sender: TObject);
    procedure btRequestsClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure appEventsMinimize(Sender: TObject);
    procedure appEventsRestore(Sender: TObject);
    procedure appEventsActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lboxMessagesDblClick(Sender: TObject);
    procedure tiMyStatsRefreshTimer(Sender: TObject);
    procedure lbSeeAllMessagesClick(Sender: TObject);
    procedure lbMyUsernameClick(Sender: TObject);
    procedure RepairWarcraftIII1Click(Sender: TObject);
    procedure lbSeeAllRequestsClick(Sender: TObject);
    procedure imgRefreshClick(Sender: TObject);
    procedure tiImgRefreshRotateTimer(Sender: TObject);
    procedure lboxNotificationsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure lboxNotificationsDblClick(Sender: TObject);
    procedure httpQuickAPIRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure tiMaphackCodeJoinTimer(Sender: TObject);
    procedure Label1Click(Sender: TObject);
  private
    SelectedUser          : Integer;
    SelectedChannel       : Integer;
    SelectedFriend        : Integer;
    SelectedMessage       : Integer;
    SelectedRequest       : Integer;
    GamesCount            : TGameCount;
    ChatEditCaretPos      : Integer;
    AfterCloseIndex       : Integer;
    GameHosted            : Boolean;
    GameName              : String;
    TempGameName          : String;
    GameListSortColumn    : Integer;
    GameListSortAscending : Boolean;
    LastTabClick          : DWORD;
    LastTabClickIndex     : Integer;
    UsernameQueueDelayed  : TStringList;
    HK1, HK2              : Integer;
    MyStatus              : TUserStatus;
    MyDND                 : Boolean;
    IsMinimized           : Boolean;
    WarProcessInfo        : TProcessInformation;
    NotificationUsers     : TStringList;
    LobbyFull             : Boolean;
    DebugMode             : Boolean;
    LastP2PAction         : DWORD;

    DebugTime_GetUserDetails   : DWORD;
    DebugStatus_GetUserDetails : String;

    procedure WMHotkey(var Msg : TWMHotkey); message WM_HOTKEY;
  public
    MinimizeOnClose : Boolean;
    ChatTabs        : TTabInfos;
    GameList        : TGameList;
    Ingame          : Boolean;
    UsernameQueue   : TStringList;
  end;

var
  MainWindow: TMainWindow;

implementation

{$R *.dfm}

uses
  ComponentModule, Localization, LoginWin, ContactWin, OptionsWin, ShellAPI, hyiedefs, AntiMaphack, Misc, TutorialWin,
  OverbyteIcsUrl, superobject, CommandsWin, Cache, imageenio, CRVFData, P2P, WinSock, OverbyteIcsWSocket, ChannelWin, SkinEngine,
  BlocklistWin, FriendRequestWin, RVItem, TrayPopupWin, GameRepairWin, VersionPatcher, SharedVars;

const
  STYLE_TIMESTAMP       = 0;
  STYLE_USER_MSG        = 1;
  STYLE_USER_SND        = 2;
  STYLE_INFO_MSG        = 3;
  STYLE_INFO_SND        = 4;
  STYLE_MY_MSG          = 5;
  STYLE_MY_SND          = 6;
  STYLE_BOT_MSG         = 7;
  STYLE_BOT_SND         = 8;
  STYLE_ERROR_MSG       = 9;
  STYLE_ERROR_SND       = 10;
  STYLE_HIGHLIGHTED_MSG = 11;
  STYLE_HIGHLIGHTED_SND = 12;
  STYLE_BROADCAST_SND   = 13;
  STYLE_BROADCAST_MSG   = 14;
  STYLE_COLORED_MSG     = 15;
  STYLE_COLORED_SND     = 16;


procedure TMainWindow.SendMaphackCode;
var
  code                 : String;
  mhcode               : String;
  hour, min, sec, msec : Word;
begin
{$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: SendMaphackCode() :: BEGIN');  {$ENDIF}

  If (ClientSettings.AntiMaphack) and
     (IsMaphackInstalled(mhcode)) Then
  Begin
    httpPostRequest(httpQuickAPI, URL_API + 'maphackPlayer', Format('key=%s&code=%s', [UserDetails.Key, mhcode]));
    code := '2'
  End
  else
  Begin
    DecodeTime(Now, hour, min, sec, msec);
    code := Format('%d%d%d', [min div 10, (min + 1) mod 2, min mod 10]);
  End;

  ComponentModuleWindow.GProxy.Send(Format('s1 %s', [code]));

{$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: SendMaphackCode(' + code + ') :: END');  {$ENDIF}
end;

function GetChatTabUserList(const AControl : TWinControl) : TspSkinOfficeListBox;
var
  C1 : Integer;
begin
  result := nil;
  For C1 := 0 to AControl.ControlCount - 1 Do
    If not Assigned(result) Then
      If AControl.Controls[C1] is TspSkinOfficeListBox Then
      Begin
        result := TspSkinOfficeListBox(AControl.Controls[C1]);
        Break;
      End
      else
        If AControl.Controls[C1] is TspSkinPanel Then
          result := GetChatTabUserList(TWinControl(AControl.Controls[C1]));
end;

function GetChatTabScrollBar(const AControl : TWinControl) : TspSkinScrollBar;
var
  C1 : Integer;
begin
  result := nil;
  For C1 := 0 to AControl.ControlCount - 1 Do
    If not Assigned(result) Then
      If AControl.Controls[C1] is TspSkinScrollBar Then
      Begin
        result := TspSkinScrollBar(AControl.Controls[C1]);
        Break;
      End
      else
        If AControl.Controls[C1] is TspSkinPanel Then
          result := GetChatTabScrollBar(TWinControl(AControl.Controls[C1]));
end;

function GetChatTabChatBox(const AControl : TWinControl) : TRichView;
var
  C1 : Integer;
begin
  result := nil;
  For C1 := 0 to AControl.ControlCount - 1 Do
    If not Assigned(result) Then
      If AControl.Controls[C1] is TRichView Then
      Begin
        result := TRichView(AControl.Controls[C1]);
        Break;
      End
      else
        If AControl.Controls[C1] is TspSkinPanel Then
          result := GetChatTabChatBox(TWinControl(AControl.Controls[C1]));
end;

function GetChatTabEdit(const AControl : TWinControl; const ATag : Integer) : TspSkinEdit;
var
  C1 : Integer;
begin
  result := nil;
  For C1 := 0 to AControl.ControlCount - 1 Do
    If not Assigned(result) Then
      If (AControl.Controls[C1] is TspSkinEdit) and
         (AControl.Controls[C1].Tag = ATag) Then
      Begin
        result := TspSkinEdit(AControl.Controls[C1]);
        Break;
      End
      else
        If AControl.Controls[C1] is TspSkinPanel Then
          result := GetChatTabEdit(TWinControl(AControl.Controls[C1]), ATag);
end;

function GetChatTabLabel(const AControl : TWinControl; const ATag : Integer) : TspSkinShadowLabel;
var
  C1 : Integer;
begin
  result := nil;
  For C1 := 0 to AControl.ControlCount - 1 Do
    If not Assigned(result) Then
      If (AControl.Controls[C1] is TspSkinShadowLabel) and
         (AControl.Controls[C1].Tag = ATag) Then
      Begin
        result := TspSkinShadowLabel(AControl.Controls[C1]);
        Break;
      End
      else
        If AControl.Controls[C1] is TspSkinPanel Then
          result := GetChatTabLabel(TWinControl(AControl.Controls[C1]), ATag);
end;

function GetCountryNameFromCode(const ACode : String) : String;
var
  C1 : Integer;
begin
  result := '';
  For C1 := 0 to COUNTRY_LIST_COUNT - 1 Do
    If COUNTRY_LIST[C1].Code = ACode Then
    Begin
      result := COUNTRY_LIST[C1].Name;
      Break;
    End;
end;

procedure TMainWindow.SaveSettings;
begin
  If SkinForm.WindowState <> wsMaximized Then
  Begin
    ComponentModuleWindow.Settings.WriteInteger('client\width', Width);
    ComponentModuleWindow.Settings.WriteInteger('client\height', Height);
  End;

  ComponentModuleWindow.Settings.WriteBoolean('client\maximized', (SkinForm.WindowState = wsMaximized));
end;

procedure TMainWindow.LoadSettings;
var
  maximized : Boolean;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: LoadSettings() :: BEGIN');  {$ENDIF}

  Width := ComponentModuleWindow.Settings.ReadInteger('client\width', Width);
  Height := ComponentModuleWindow.Settings.ReadInteger('client\height', Height);
  maximized := FALSE;
  maximized := ComponentModuleWindow.Settings.ReadBoolean('client\maximized', maximized);
  If maximized Then
    SkinForm.WindowState := wsMaximized;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: LoadSettings() :: END');  {$ENDIF}
end;

function TMainWindow.PSoundWrapper(const ASound : TSound) : Boolean;
begin
  result := FALSE;
  If (not Options.Sounds.SurpressIngame) or
     (not Ingame) Then
    result := PSound(ASound);
end;

procedure HideBotWhispers;
begin
  ComponentModuleWindow.GProxy.OnOutWhisper := nil;
end;

procedure ShowBotWhispers;
begin
  ComponentModuleWindow.GProxy.OnOutWhisper := MainWindow.OnOutWhisper;
end;

procedure TMainWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: FormClose() :: BEGIN');  {$ENDIF}

  If Assigned(ComponentModuleWindow.GProxy) Then
  Begin
    ComponentModuleWindow.GProxy.OnUDPRead := nil;
    ComponentModuleWindow.GProxy.OnUserJoin := nil;
    ComponentModuleWindow.GProxy.OnUserLeave := nil;
    ComponentModuleWindow.GProxy.OnGetUserList := nil;
    ComponentModuleWindow.GProxy.OnChannelJoin := nil;
    ComponentModuleWindow.GProxy.OnCommand := nil;
    ComponentModuleWindow.GProxy.OnCHATE := nil;
    ComponentModuleWindow.GProxy.OnChannelChat := nil;
    ComponentModuleWindow.GProxy.OnWhisper := nil;
    ComponentModuleWindow.GProxy.OnOutWhisper := nil;
    ComponentModuleWindow.GProxy.OnNonCommand := nil;
  End;

//  ircDarer.Disconnect(FALSE, CLIENT_VERSION);

  SaveSettings;

  UnRegisterHotKey(Handle, HK1);
  GlobalDeleteAtom(HK1);
  UnRegisterHotKey(Handle, HK2);
  GlobalDeleteAtom(HK2);

  Application.Title := 'Darer';

  Users.Count := 0;
  SetLength(Users.Items, Users.Count);
  SetLength(Users.Avatar, Users.Count);

  LoginWindow.PreventAutologin := TRUE;

  Action := caFREE;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: FormClose() :: END');  {$ENDIF}
end;

procedure TMainWindow.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: FormCloseQuery() :: BEGIN');  {$ENDIF}

  CanClose := MainWindow.CanClose;

  If not CanClose Then
  Begin
    Application.Minimize;
    SkinFormMinimize(Sender);
  End;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: FormCloseQuery() :: END');  {$ENDIF}
end;

function TMainWindow.GetUserStatusIndexFromArea(const AArea : Integer) : Integer;
begin
  Case AArea of
    0       : result := GetUserStatusIndex(usOffline);
    1, 2    : result := GetUserStatusIndex(usOnline);
    3, 4, 5 : result := GetUserStatusIndex(usBusy);
  else
    result := GetUserStatusIndex(usOnline);
  End;
end;

procedure SetBanner(const AImageList : TspPngImageList; const AImage : TspPngImageView; const AMemoryStream : TMemoryStream);
var
  pngX, pngY : Integer;
  ID         : Integer;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: SetBanner() :: BEGIN');  {$ENDIF}

  AMemoryStream.Position := 0;
  GetPNGDimensions(AMemoryStream, pngX, pngY);
  AImageList.PngImages.Clear;
  AImageList.Width := pngX;
  AImageList.Height := pngY;
  ID := AImageList.PngImages.Add.Index;
  AMemoryStream.Position := 0;
  AImageList.PngImages[ID].PngImage.LoadFromStream(AMemoryStream);
  AImage.ImageIndex := ID;
  AImage.Refresh;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: SetBanner() :: END');  {$ENDIF}
end;

procedure TMainWindow.PopulateChannelList;
var
  chans     : String;
  chanslist : TStringList;
  C1        : Integer;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: PopulateChannelList() :: BEGIN');  {$ENDIF}

  lboxChannels.Clear;
  lboxChannels.Items.Add('Beginners');
  lboxChannels.Items.Add('Advanced');
  lboxChannels.Items.Add('Experts');
  lboxChannels.Items.Add('Challenge');
  lboxChannels.Items.Add(GetCountryNameFromCode(UserDetails.Country));

  chans := ComponentModuleWindow.Settings.ReadString('client\channels', '');
  chanslist := TStringList.Create;
  chanslist.Duplicates := dupIgnore;
  Split(',', chans, chanslist);
  For C1 := 0 to chanslist.Count - 1 Do
    lboxChannels.Items.Add(chanslist[C1]);
  chanslist.Free;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: PopulateChannelList() :: END');  {$ENDIF}
end;

procedure TMainWindow.SendBlocklist;
var
  C1 : Integer;
  s  : String;
begin
  s := '';
  For C1 := 0 to Blocklist.Count - 1 Do
    s := s + Blocklist.Strings[C1] + ',';
  For C1 := 0 to OthersBlocklist.Count - 1 Do
    s := s + OthersBlocklist.Strings[C1] + ',';

  If s <> '' Then
    ComponentModuleWindow.GProxy.Send(LowerCase(Format('bl %s', [s])))
  else
    ComponentModuleWindow.GProxy.Send('blc');
end;

procedure TMainWindow.FormCreate(Sender: TObject);
var
  C1        : Integer;
  item      : TMenuItem;
  pngimg    : TspPngImageItem;
  ImageEn   : TImageEn;
  memStream : TMemoryStream;
  resStream : TResourceStream;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: FormCreate() :: BEGIN');  {$ENDIF}

  SkinForm.AlphaBlendAnimation := Options.Customize.FadeInEffect;

  Localize(self);
  LocalLocalize;

  LoadSettings;

  DebugTime_GetUserDetails := GetTickCount;
  DebugMode := FALSE;

  SkinForm.MinHeight := 636;
  SkinForm.MinWidth := 984;
  MainWindow.Constraints.MinWidth := 984;
  MainWindow.Constraints.MinHeight := 636;

  Application.Title := Format('Darer - %s', [UserDetails.Username]);

  MinimizeOnClose := TRUE;

  IsMinimized := FALSE;

  SetProcPrivileges(GetCurrentProcessId, 'SeDebugPrivilege');

  cache_Init;

  sgGameList.SelectAll := FALSE;

  ChatTabs.Count := 0;
  SetLength(ChatTabs.Items, ChatTabs.Count);
//  CreateChatTab('Raw', ctPVPGN_Raw);

  GameListSortAscending := TRUE;

  UsernameQueue := TStringList.Create;
  UsernameQueueDelayed := TStringList.Create;

  UsernameQueue.Duplicates := dupIgnore;
  UsernameQueueDelayed.Duplicates := dupIgnore;

  If Assigned(ComponentModuleWindow.GProxy) Then
  Begin
    ComponentModuleWindow.GProxy.OnUDPRead := OnUDPRead;
    ComponentModuleWindow.GProxy.OnUserJoin := OnUserJoin;
    ComponentModuleWindow.GProxy.OnUserLeave := OnUserLeave;
    ComponentModuleWindow.GProxy.OnGetUserList := OnGetUserList;
    ComponentModuleWindow.GProxy.OnChannelJoin := OnChannelJoin;
    ComponentModuleWindow.GProxy.OnCommand := OnCommand;
    ComponentModuleWindow.GProxy.OnCHATE := OnCHATE;
    ComponentModuleWindow.GProxy.OnChannelChat := OnChannelChat;
    ComponentModuleWindow.GProxy.OnWhisper := OnWhisper;
    ComponentModuleWindow.GProxy.OnOutWhisper := OnOutWhisper;
    ComponentModuleWindow.GProxy.OnNonCommand := OnNonCommand;
  End;

//  ircDarer.CtcpOptions.VersionReply := CLIENT_VERSION;
//  ircDarer.AuthOptions.Ident := CLIENT_VERSION;

  SendMaphackCode;

//  ircDarer.Connect;

  Caption := CLIENT_VERSION;

  lbMyUsername.Caption := UserDetails.Username;
  SetMyTitle('');

  PopulateGameTypeCombobox;

  mmLanguage.Clear;
  For C1 := 0 to ComponentModuleWindow.pmLanguage.Count - 1 Do
  Begin
    item := TMenuItem.Create(mmLanguage);
    item.Caption := ComponentModuleWindow.pmLanguage.Items[C1].Caption;
    item.Checked := ComponentModuleWindow.pmLanguage.Items[C1].Checked;
    item.Default := ComponentModuleWindow.pmLanguage.Items[C1].Default;
    item.Enabled := ComponentModuleWindow.pmLanguage.Items[C1].Enabled;
    item.GroupIndex := ComponentModuleWindow.pmLanguage.Items[C1].GroupIndex;
    item.ImageIndex := ComponentModuleWindow.pmLanguage.Items[C1].ImageIndex;
    item.RadioItem := ComponentModuleWindow.pmLanguage.Items[C1].RadioItem;
    item.ShortCut := ComponentModuleWindow.pmLanguage.Items[C1].ShortCut;
    item.Tag := ComponentModuleWindow.pmLanguage.Items[C1].Tag;
    item.Visible := ComponentModuleWindow.pmLanguage.Items[C1].Visible;
    item.OnClick := ComponentModuleWindow.pmLanguage.Items[C1].OnClick;
    mmLanguage.Add(item);
  End;

  NotificationUsers := TStringList.Create;
  NotificationUsers.Sorted := TRUE;
  NotificationUsers.Duplicates := dupIgnore;

  ilMyAvatar.PngWidth := imgMyAvatar.Width;
  ilMyAvatar.PngHeight := imgMyAvatar.Height;
  ilMyAvatar.PngImages.Clear;

  ilUserAvatar.PngWidth := imgUserInfoAvatar.Width;
  ilUserAvatar.PngHeight := imgUserInfoAvatar.Height;
  ilUserAvatar.PngImages.Clear;

  ImageEn := TImageEn.Create(nil);
  memStream := TMemoryStream.Create;

  resStream := TResourceStream.Create(HInstance, 'AVATAR_EMPTY_145', RT_RCDATA);
  ImageEn.IO.LoadFromStream(resStream);
  resStream.Free;

  memStream.Position := 0;
  ImageEn.IO.SaveToStreamPNG(memStream);
  pngimg := TspPngImageItem(ilAvatars145.PngImages.Add);
  memStream.Position := 0;
  pngimg.PngImage.LoadFromStream(memStream);
  memStream.Clear;

  ImageEn.Proc.Resample(ilMyAvatar.Width, ilMyAvatar.Height, rfLanczos3);
  memStream.Position := 0;
  ImageEn.IO.SaveToStreamPNG(memStream);
  pngimg := TspPngImageItem(ilMyAvatar.PngImages.Add);
  memStream.Position := 0;
  pngimg.PngImage.LoadFromStream(memStream);
  memStream.Clear;

  resStream := TResourceStream.Create(HInstance, 'AVATAR_EMPTY_32', RT_RCDATA);
  ImageEn.IO.LoadFromStream(resStream);
  resStream.Free;

  ImageEn.Proc.Resample(ilAvatars35.Width, ilAvatars35.Height, rfLanczos3);
  memStream.Position := 0;
  ImageEn.IO.SaveToStreamPNG(memStream);
  pngimg := TspPngImageItem(ilAvatars35.PngImages.Add);
  memStream.Position := 0;
  pngimg.PngImage.LoadFromStream(memStream);

  memStream.Free;
  ImageEn.Free;

  imgMyAvatar.ImageIndex := 0;
  imgUserInfoAvatar.ImageIndex := 0;

  MyStatus := usOnline;
  MyDND := FALSE;

  SendBlocklist;

  P2PTYPE := p2pPVPGN;

  UpdateStringGridSize;

  ShowMyStats;
  PopulateChannelList;
  RefreshFriendList;
  RefreshBanners;
  RefreshAnnouncement;

  smUserStatusOnline.ImageIndex := GetUserStatusIndex(usOnline);
  smUserStatusDND.ImageIndex := GetUserStatusIndex(usBusy);

  HK1 := GlobalAddAtom('DarerHK-HostGame');
  RegisterHotKey(Handle, HK1, MOD_CONTROL, Ord('H'));

  HK2 := GlobalAddAtom('DarerHK-UnhostGame');
  RegisterHotKey(Handle, HK2, MOD_CONTROL, Ord('U'));

  ComponentModuleWindow.GProxy.Send(Format('mc %s', [UserDetails.Country]));

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: FormCreate() :: END');  {$ENDIF}
end;

procedure TMainWindow.SetMyTitle(const ATitle : String);
begin
  lbMyTitle.Caption := ATitle;
  lbMyUsername.Left := lbMyTitle.Left + lbMyTitle.Width - 5;
end;

procedure TMainWindow.SetUserTitle(const ATitle, AName : String);
begin
  lbUserInfoTitle.Caption := ATitle;
  lbUserInfoUsername.Caption := AName;
  lbUserInfoUsername.Left := lbUserInfoTitle.Left + lbUserInfoTitle.Width - 5;
end;

procedure TMainWindow.SkinFormMinimize(Sender: TObject);
begin
  If ComponentModuleWindow.TrayIcon.MinimizeToTray Then
    ComponentModuleWindow.TrayIcon.HideTaskbarIcon;
end;

procedure TMainWindow.OnUDPRead(ASender : TGProxy; const AString : WideString);
begin
//  AddLineToChatTab(GetPVPGNTab(ctPVPGN_Raw), '', AString, STYLE_USER_SND, STYLE_USER_MSG);
end;

procedure TMainWindow.UpdateGameCount;
begin
  lbGamesAllVal.Caption := IntToStr(GamesCount.All);
  lbGamesFreeVal.Caption := IntToStr(GamesCount.Free);
  lbGamesLadderVal.Caption := IntToStr(GamesCount.Ladder);
  lbGamesChallengeVal.Caption := IntToStr(GamesCount.Challenge);
  lbGamesRunningVal.Caption := IntToStr(GamesCount.Running);
  lbGamesTodayVal.Caption := IntToStr(GamesCount.Today);
end;

procedure TMainWindow.OnCommand(ASender : TGProxy; const ACommand, AParams : WideString);
var
  cmd                : WideString;
  nick, status, area : WideString;
  narea, nstatus     : Integer;
  error              : Boolean;
  fronline           : Integer;
  C1, C2             : Integer;
  userinfo           : TUserInfo;
  postqueue          : Boolean;
  sC, sT             : Integer;
  uniqid             : Integer;
  gameid             : Integer;
begin
  If ACommand = 'adg' Then // game count
  Begin
    GamesCount.Free := StrToIntDef(GetParam(AParams, 1), 0);
    GamesCount.Ladder := StrToIntDef(GetParam(AParams, 0), 0);
    GamesCount.Challenge := StrToIntDef(GetParam(AParams, 2), 0);
    GamesCount.All := GamesCount.Free + GamesCount.Ladder + GamesCount.Challenge;
    GamesCount.Running := StrToIntDef(GetParam(AParams, 3), 0);
    GamesCount.Today := StrToIntDef(GetParam(AParams, 4), 0);
    UpdateGameCount;
  End;

  If ACommand = 'lpc' Then // game create
  Begin
    tiMaphackCodeJoin.Enabled := FALSE;
    tiMaphackCodeJoin.Enabled := TRUE;
    Ingame := TRUE;
  End;

  If ACommand = 'lpd' Then // game end
  Begin
    Ingame := FALSE;

    GameName := '';
    GameHosted := FALSE;
    tiHostTimeout.Enabled := FALSE;
    btGameHost.Caption := RS_GAME_HOST;
    btGameHost.Enabled := TRUE;
    EnableHostSettings(TRUE);
  End;

  If ACommand = 'fr' Then // pvpgn friend request
    tiMyDetailsUpdate.OnTimer(self);

  If ACommand = 'friends' Then // pvpgn friend list
  Begin
    postqueue := FALSE;
    cmd := AParams;

    fronline := 0;
    error := FALSE;
    While not error Do
    Begin
      nick := Copy(cmd, 1, Pos(',', cmd) - 1);
      Delete(cmd, 1, Pos(',', cmd));
      status := Copy(cmd, 1, Pos(',', cmd) - 1);
      Delete(cmd, 1, Pos(',', cmd));
      area := Copy(cmd, 1, Pos(',', cmd) - 1);
      Delete(cmd, 1, Pos(',', cmd));

      If nick <> '' Then
      Begin
        If narea > 0 Then
          Inc(fronline);

        If (TryStrToInt(status, nstatus)) and
           (TryStrToInt(area, narea)) Then
        Begin
          If GetUserInfo(nick, userinfo) Then
          Begin
            SetUserInfo_Area(nick, narea);
            SetUserInfo_Friend_PVPGN(nick, TRUE);
          End;
        End
        else
          error := TRUE;
      End
      else
        error := TRUE;
    End;

    lbOnlineFriendsVal.Caption := IntToStr(fronline);

    For C1 := 0 to Users.Count - 1 Do
      If (Users.Items[C1].IsFriend_Site) and
         (not Users.Items[C1].IsFriend_PVPGN) Then
      Begin
        ComponentModuleWindow.GProxy.Command(Format('f add %s', [Users.Items[C1].Username]));
        Users.Items[C1].IsFriend_PVPGN := TRUE;
      End;

    If postqueue Then
      tiUsernameDelayedQueue.OnTimer(self);

    RefreshFriendList;
  End;

  If ACommand = 'dg' Then
  Begin
    cmd := AParams;

    // unique game id
    uniqid := StrToIntDef(cmd, 0);

    For C1 := 0 to GameList.Count - 1 Do
      If GameList.Items[C1].UniqID = uniqid Then
      Begin
        For C2 := C1 to GameList.Count - 2 Do
          GameList.Items[C2] := GameList.Items[C2 + 1];
        Dec(GameList.Count);
        SetLength(GameList.Items, GameList.Count);
        Break;
      End;
  End;

  If ACommand = 'ug' Then
  Begin
    cmd := AParams;

    Delete(cmd, 1, Pos(' ', cmd));

    // unique game id
    uniqid := StrToIntDef(Copy(cmd, 1, Pos(' ', cmd) - 1), 0);
    Delete(cmd, 1, Pos(' ', cmd));

    For C1 := 0 to GameList.Count - 1 Do
      If GameList.Items[C1].UniqID = uniqid Then
      Begin
        // room number
        Delete(cmd, 1, Pos(' ', cmd));

        // gametype2
        Case StrToInt(Copy(cmd, 1, Pos(' ', cmd) - 1)) of
          0 : GameList.Items[C1].Type_ := gtFree;
          1 : GameList.Items[C1].Type_ := gtLadder;
        else
          GameList.Items[C1].Type_ := gtUnknown;
        End;

        GameList.Items[C1].Status := gsOpen;

        Delete(cmd, 1, Pos(' ', cmd));

        sC := StrToIntDef(Copy(cmd, 1, Pos(' ', cmd) - 1), 0);
        Delete(cmd, 1, Pos(' ', cmd));
        sT := StrToIntDef(Copy(cmd, 1, Pos(' ', cmd) - 1), 0);
        Delete(cmd, 1, Pos(' ', cmd));

        Case sT of
          10 : sC := 11 - sC;
          12 : sC := 12 - sC;
        End;

        // slotsopen
        GameList.Items[C1].Slots := Format('%d/%d', [sC, sT]);

        // modetype
        If StrToIntDef(Copy(cmd, 1, Pos(' ', cmd) - 1), -1) in [0..cbGameMode.Items.Count - 1] Then
          GameList.Items[C1].Mode := cbGameMode.Items[StrToIntDef(Copy(cmd, 1, Pos(' ', cmd) - 1), 0)];

        Delete(cmd, 1, Pos(' ', cmd));

        // minrating
        Delete(cmd, 1, Pos(' ', cmd));

        // maxrating
        Delete(cmd, 1, Pos(' ', cmd));

        // disconnectlimit
        Delete(cmd, 1, Pos(' ', cmd));

        // pass
        Delete(cmd, 1, Pos(' ', cmd));

        // gamename
        GameList.Items[C1].Host := cmd;

        If MatchStrings('??.* | *', GameList.Items[C1].Host, FALSE) Then
          GameList.Items[C1].Country := Copy(GameList.Items[C1].Host, 1, 2)
        else
          GameList.Items[C1].Country := 'World';

        GameList.Items[C1].FlagIndex := ComponentModuleWindow.FindCountryImage(GameList.Items[C1].Country);

        UpdateGameList;
        
        Break;
      End;
  End;
  
  If ACommand = 'ag' Then
  Begin
    cmd := AParams;

    uniqid := StrToIntDef(Copy(cmd, 1, Pos(' ', cmd) - 1), 0);
    Delete(cmd, 1, Pos(' ', cmd));

    gameid := GameList.Count;
    For C1 := 0 to GameList.Count - 1 Do
      If GameList.Items[C1].UniqID = uniqid Then
      Begin
        gameid := C1;
        Break;
      End;

    If gameid > GameList.Count - 1 Then
    Begin
      Inc(GameList.Count);
      SetLength(GameList.Items, GameList.Count);
    End;

    // unique game id
    GameList.Items[gameid].UniqID := uniqid;

    // room number
    Delete(cmd, 1, Pos(' ', cmd));

    // gametype2
    Case StrToInt(Copy(cmd, 1, Pos(' ', cmd) - 1)) of
      0 : GameList.Items[gameid].Type_ := gtFree;
      1 : GameList.Items[gameid].Type_ := gtLadder;
    else
      GameList.Items[gameid].Type_ := gtUnknown;
    End;
    GameList.Items[gameid].Status := gsOpen;

    Delete(cmd, 1, Pos(' ', cmd));

    sC := StrToIntDef(Copy(cmd, 1, Pos(' ', cmd) - 1), 0);
    Delete(cmd, 1, Pos(' ', cmd));
    sT := StrToIntDef(Copy(cmd, 1, Pos(' ', cmd) - 1), 0);
    Delete(cmd, 1, Pos(' ', cmd));

    Case sT of
      10 : sC := 12 - sC - 1;
      12 : sC := 12 - sC;
    End;

    // slotsopen
    GameList.Items[gameid].Slots := Format('%d/%d', [sC, sT]);

    // modetype
    If StrToIntDef(Copy(cmd, 1, Pos(' ', cmd) - 1), -1) in [0..cbGameMode.Items.Count - 1] Then
      GameList.Items[gameid].Mode := cbGameMode.Items[StrToIntDef(Copy(cmd, 1, Pos(' ', cmd)), 0)];

    Delete(cmd, 1, Pos(' ', cmd));

    // minrating
    Delete(cmd, 1, Pos(' ', cmd));

    // maxrating
    Delete(cmd, 1, Pos(' ', cmd));

    // disconnectlimit
    Delete(cmd, 1, Pos(' ', cmd));

    // pass
    Delete(cmd, 1, Pos(' ', cmd));

    // gamename
    GameList.Items[gameid].Host := cmd;

    If MatchStrings('??.?? | *', GameList.Items[gameid].Host, FALSE) Then
      GameList.Items[gameid].Country := Copy(GameList.Items[gameid].Host, 1, 2)
    else
      GameList.Items[gameid].Country := 'World';

    GameList.Items[gameid].FlagIndex := ComponentModuleWindow.FindCountryImage(GameList.Items[gameid].Country);

    UpdateGamelist;
  End;

  If ACommand = 'cg' Then
  Begin
    GameList.Count := 0;
    SetLength(GameList.Items, GameList.Count);
  End;

  If ACommand = 'oc' Then
  Begin
    cmd := AParams;

    sC := StrToIntDef(Copy(cmd, 1, Pos(' ', cmd) - 1), -1);
    Delete(cmd, 1, Pos(' ', cmd));
    Delete(cmd, 1, Pos(' ', cmd));
    sT := StrToIntDef(cmd, -1);

    If (sC <> -1) and
       (sT <> -1) Then
    Begin
      If (sT = sC) and
         (not LobbyFull) Then
      Begin
        PSound(Options.Sounds.LobbyFull);
        LobbyFull := TRUE;
      End
      else
        LobbyFull := FALSE;
    End;
  End;
end;

function TMainWindow.GetUserStatusIndex(const AStatus : TUserStatus) : Integer;
begin
  Case AStatus of
    usOffline : result := Options.Customize.StatusIcons * 3 + 0;
    usOnline  : result := Options.Customize.StatusIcons * 3 + 2;
    usBusy    : result := Options.Customize.StatusIcons * 3 + 1;
  else
    result := 2;
  End;
end;

procedure TMainWindow.AddUserToListBox(const AChatTab : TTabSheet; const ANickname : String);
var
  item     : TspSkinOfficeItem;
  lb       : TspSkinOfficeListBox;
  userInfo : TUserInfo;
  C1       : Integer;
  exists   : Boolean;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: AddUserToListbox() :: BEGIN');  {$ENDIF}

  lb := GetChatTabUserList(AChatTab);
  If Assigned(lb) Then
  Begin
    exists := FALSE;
    For C1 := 0 to lb.Items.Count - 1 Do
      If lb.Items[C1].Title = ANickname Then
      Begin
        exists := TRUE;
        Break;
      End;

    If not exists Then
    Begin
      item := lb.Items.Add;

      If cache_getUser(ANickname, userInfo) Then
      Begin
        item.Title := userInfo.Username;
        item.Caption := ' ';
        item.TitleColor := clWhite;
        item.TextColor := clGray;
        item.StatusIndex := GetUserStatusIndex(usOnline);
        item.ImageIndex := 0;
        item.FlagIndex := -1;
      End
      else
      Begin
        item.Title := ANickname;
        item.TitleColor := clWhite;
        item.TextColor := clGray;
        item.Caption := ' ';
        item.StatusIndex := GetUserStatusIndex(usOnline);
        item.ImageIndex := 0;
        item.FlagIndex := -1;
      End;

      RefreshUserListHeader(AChatTab);
      lb.Refresh;
    End;  
  End;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: AddUserToListbox() :: END');  {$ENDIF}
end;

procedure TMainWindow.RemoveUserFromListBox(const AChatTab : TTabSheet; const ANickname : String);
var
  C1 : Integer;
  lb : TspSkinOfficeListBox;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: RemoveUserFromListbox() :: BEGIN');  {$ENDIF}

  lb := GetChatTabUserList(AChatTab);
  If Assigned(lb) Then
  Begin
    For C1 := 0 to lb.Items.Count - 1 Do
      If lb.Items[C1].Title = ANickname Then
      Begin
        lb.Items.Delete(C1);
        Break;
      End;

    RefreshUserListHeader(AChatTab);
    lb.Refresh;
  End;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: RemoveUserFromListbox() :: END');  {$ENDIF}
end;

function TMainWindow.GetPVPGNTab(const ATabType : TTabType; const ACaption : WideString = '') : TTabSheet;
var
  C1 : Integer;
begin
  result := nil;
  For C1 := 0 to ChatTabs.Count - 1 Do
    If (ChatTabs.Items[C1].TabType = ATabType) and
       ((ACaption = '') or
        (TTabSheet(ChatTabs.Items[C1].TabControl).Caption = ACaption)) Then
    Begin
      result := TTabSheet(ChatTabs.Items[C1].TabControl);
      Break;
    End
end;

procedure TMainWindow.OnUserJoin(ASender : TGProxy; const ANickname : WideString);
begin
  AddUserToListbox(GetPVPGNTab(ctPVPGN_Channel), ANickname);
//  AddUserToPostQueue(UsernameQueue, ANickname);
end;

procedure TMainWindow.OnUserLeave(ASender : TGProxy; const ANickname : WideString);
begin
  RemoveUserFromListbox(GetPVPGNTab(ctPVPGN_Channel), ANickname);
end;

procedure TMainWindow.OnGetUserList(ASender : TGProxy);
var
  C1       : Integer;
  lb       : TspSkinOfficeListBox;
  ts       : TTabSheet;
//  userInfo : TUserInfo;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: OnGetUserList() :: BEGIN');  {$ENDIF}

  ts := GetPVPGNTab(ctPVPGN_Channel);
  If Assigned(ts) Then
  Begin
    lb := GetChatTabUserList(ts);
    If Assigned(lb) Then
    Begin
      UsernameQueueDelayed.Clear;
      lb.Items.Clear;
      lb.BeginUpdateItems;
      For C1 := 0 to ASender.ChannelUsers.Count - 1 Do
      Begin
        AddUserToListbox(ts, ASender.ChannelUsers[C1]);
//        AddUserToPostQueue(UsernameQueueDelayed, ASender.ChannelUsers[C1])
      End;
      lb.EndUpdateItems;
      RefreshUserListHeader(ts);
    End;
  End;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: OnGetUserList() :: END');  {$ENDIF}
end;

procedure TMainWindow.RefreshUserListHeader(const AChatTab : TTabSheet);
var
  lbox   : TspSkinOfficeListBox;
  lbel   : TspSkinShadowLabel;
  ucount : Integer;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: RefreshUserListHeader() :: BEGIN');  {$ENDIF}

  lbox := GetChatTabUserList(AChatTab);
  If (Assigned(lbox)) and
     (not lbox.InUpdateItems) Then
  Begin
    lbel := GetChatTabLabel(AChatTab, 2);
    If Assigned(lbel) Then
    Begin
      ucount := lbox.Items.Count;
      If ucount = 0 Then
        ucount := 1;
      lbel.Caption := IntToStr(ucount);
    End;
    lbel := GetChatTabLabel(AChatTab, 1);
    If Assigned(lbel) Then
      lbel.Caption := '# ' + AChatTab.Caption;
  End;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: RefreshUserListHeader() :: END');  {$ENDIF}
end;

procedure TMainWindow.OnChannelJoin(ASender : TGproxy; const AChannel : WideString);
var
  ctab : TTabSheet;
  ebox : TspSkinEdit;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: OnChannelJoin() :: BEGIN');  {$ENDIF}

  ctab := GetChatTab('', ctPVPGN_Channel);
  If Assigned(ctab) Then
  Begin
    If ctab.Caption <> AChannel Then
    Begin
      DeleteChatTabInfo(ctab);
      ctab.Free;
    End;
  End;

  ctab := CreateChatTab(AChannel, ctPVPGN_Channel);
  If Assigned(ctab) Then
  Begin
    cntChat.ActivePageIndex := ctab.TabIndex;
    cntChat.ActivePage.SetFocus;
    ebox := GetChatTabEdit(cntChat.ActivePage, 1);
    If Assigned(ebox) Then
      ebox.SetFocus;
    RefreshUserListHeader(cntChat.ActivePage);
  End;

  ComponentModuleWindow.GProxy.UpdateUsers;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: OnChannelJoin() :: END');  {$ENDIF}
end;

function TMainWindow.FindUserInList(const lbox : TspSkinOfficeListBox; const ANick : WideString) : Integer;
var
  C1 : Integer;
begin
  result := -1;
  If Assigned(lbox) Then
  Begin
    If ANick <> '' Then
    Begin
      For C1 := 0 to lbox.Items.Count - 1 Do
        If MatchStrings(ANick, lbox.Items[C1].Title, FALSE) Then
        Begin
          result := C1;
          Break;
        End;
    End;
  End;
end;

procedure TMainWindow.ebSearchUserChange(Sender: TObject);
var
  lb  : TspSkinOfficeListBox;
  res : Integer;
begin
  lb := GetChatTabUserList(TspSkinEdit(Sender).Parent.Parent);
  If Assigned(lb) Then
  Begin
    res := FindUserInList(lb, '*' + TspSkinEdit(Sender).Text + '*');
    If res <> -1 Then
    Begin
      lb.ItemIndex := res;
      SelectedUser := lb.Items[res].ID;
    End;
  End;
end;

procedure TMainWindow.ebSearchUserEnter(Sender: TObject);
begin
  TspSkinEdit(Sender).Clear;
end;

procedure TMainWindow.ebSearchUserExit(Sender: TObject);
begin
  TspSkinEdit(Sender).Text := RS_USER_SEARCH;
end;

procedure TMainWindow.smAboutClick(Sender: TObject);
begin
  BrowseURL('http://www.darer.com/index/aboutus');
end;

procedure TMainWindow.smSupportClick(Sender: TObject);
begin
  Application.CreateForm(TContactWindow, ContactWindow);
  ContactWindow.cbType.ItemIndex := 1;
  ContactWindow.ShowModal;
  ContactWindow := nil;
end;


procedure TMainWindow.smReportBugClick(Sender: TObject);
begin
  Application.CreateForm(TContactWindow, ContactWindow);
  ContactWindow.cbType.ItemIndex := 0;
  ContactWindow.ShowModal;
  ContactWindow := nil;
end;

procedure TMainWindow.smLogoutClick(Sender: TObject);
begin
  ComponentModuleWindow.pmLogoutClick(Sender);
end;

procedure TMainWindow.smExitClick(Sender: TObject);
begin
  ComponentModuleWindow.pmExitClick(Sender);
end;

procedure TMainWindow.LocalLocalize;
var
  C1 : Integer;
  eb : TspSkinEdit;
begin
  If MainWindow.mmBar.Visible Then
    MainWindow.mmBar.Refresh;

  For C1 := 0 to cntChat.PageCount - 1 Do
  Begin
    eb := GetChatTabEdit(cntChat.Pages[C1], 2);
    If (Assigned(eb)) and
       (not eb.Focused) Then
      eb.Text := RS_USER_SEARCH;
  End;

  If not ebSearchFriends.Focused Then
    ebSearchFriends.Text := RS_SEARCH_FRIENDS;

  If not ebSearchGames.Focused Then
    ebSearchGames.Text := RS_SEARCH_GAMES;

  LocalizeChallengeLabel;
  
  setUserStatsHints;
end;

function TMainWindow.GetChatTab(const ACaption : WideString; const ATabType : TTabType) : TTabSheet;
var
  C1 : Integer;
begin
  result := nil;
  For C1 := 0 to ChatTabs.Count - 1 Do
    If ((ChatTabs.Items[C1].TabType = ATabType) or
        (ATabType = ctUnknown)) and
       ((LowerCase(ChatTabs.Items[C1].Data) = LowerCase(ACaption)) or
        (ACaption = '')) Then
    Begin
      result := TTabSheet(ChatTabs.Items[C1].TabControl);
      Break;
    End;
end;

function CreatePanel(const AOwner : TComponent; const AName : String; const AAlign : TAlign; const AWidth : Integer = 100; const AHeight : Integer = 50; const ASkinDataName : String = 'panel') : TspSkinPanel;
var
  tmpPanel : TspSkinPanel;
begin
  tmpPanel := TspSkinPanel.Create(AOwner);
  tmpPanel.Parent := TWinControl(AOwner);
  tmpPanel.Name := AName;
  tmpPanel.Align := AAlign;
  tmpPanel.Width := AWidth;
  tmpPanel.Height := AHeight;
  tmpPanel.BorderStyle := bvNone;
  tmpPanel.SkinData := ComponentModuleWindow.sppMain;
  tmpPanel.SkinDataName := ASkinDataName;

  result := tmpPanel;
end;

function CreateLabel(const AOwner : TComponent; const AName, ACaption : String; const AAlign : TAlign; const AWidth : Integer = 100; const AHeight : Integer = 50; const AFontColor : TColor = $00AC9266; const AFontSize : Integer = 8; const AFontStyle : TFontStyles = [fsBold]) : TspSkinShadowLabel;
var
  tmpLabel : TspSkinShadowLabel;
begin
  tmpLabel := TspSkinShadowLabel.Create(AOwner);
  tmpLabel.Parent := TWinControL(AOwner);
  tmpLabel.Name := AName;
  tmpLabel.Align := AAlign;
  tmpLabel.AutoSize := TRUE;
  tmpLabel.Caption := ACaption;
  tmpLabel.Font.Name := 'Tahoma';
  tmpLabel.Font.Color := AFontColor;
  tmpLabel.Font.Size := AFontSize;
  tmpLabel.Font.Style := AFontStyle;

  result := tmpLabel;
end;

function CreateEdit(const AOwner : TComponent; const AName : String; const AAlign : TAlign; const AJustify : TAlignment = taLeftJustify; const AWidth : Integer = 100; const AHeight : Integer = 50; const ASkinDataName : String = 'edit') : TspSkinEdit;
var
  tmpEdit : TspSkinEdit;
begin
  tmpEdit := TspSkinEdit.Create(AOwner);
  tmpEdit.Parent := TWinControl(AOwner);
  tmpEdit.Name := AName;
  tmpEdit.Align := AAlign;
  tmpEdit.Alignment := AJustify;
  tmpEdit.Width := AWidth;
  tmpEdit.Height := AHeight;
  tmpEdit.Font.Color := clWhite;
  tmpEdit.Clear;
  tmpEdit.SkinData := ComponentModuleWindow.sppMain;
  tmpEdit.SkinDataName := ASkinDataName;

  result := tmpEdit;
end;

function TMainWindow.CreateChatTab(const ACaption : WideString; const ATabType : TTabType) : TTabSheet;
var
  ChatTab    : TTabSheet;
  mainPanel  : TspSkinPanel;
  tmpPanel   : TspSkinPanel;
  tmpPanel1  : TspSkinPanel;
  tmpListBox : TspSkinOfficeListBox;
  tmpScroll  : TspSkinScrollBar;
  tmpEdit    : TspSkinEdit;
  tmpChatbox : TRichView;
  tmpButton  : TspSkinSpeedButton;
  tmpLabel   : TspSkinShadowLabel;
begin
  result := GetChatTab(ACaption, ATabType);
  If Assigned(result) Then
    Exit;

  ChatTab := TspSkinTabSheet.Create(cntChat);
  ChatTab.Caption := ACaption;
  ChatTab.TabVisible := TRUE;
  ChatTab.PageControl := cntChat;

  CreatePanel(ChatTab, 'pasTCntChat' + IntToStr(ChatTab.TabIndex), alTop, 0, 3);
  CreatePanel(ChatTab, 'pasBCntChat' + IntToStr(ChatTab.TabIndex), alBottom, 0, 2);
  CreatePanel(ChatTab, 'pasLCntChat' + IntToStr(ChatTab.TabIndex), alLeft, 4);

  mainPanel := CreatePanel(ChatTab, 'paInCntChat' + IntToStr(ChatTab.TabIndex), alClient, 0, 0);

  tmpEdit := CreateEdit(mainPanel, 'ebChat' + IntToStr(ChatTab.TabIndex), alBottom);
  tmpEdit.OnExit := ChatBoxExit;
  tmpEdit.OnKeyDown := ebChatKeyDown;
  tmpEdit.Tag := 1;
  tmpEdit.TabOrder := 0;
  tmpEdit.TabStop := TRUE;

  CreatePanel(mainPanel, 'pasMCntChat' + IntToStr(ChatTab.TabIndex), alBottom, 0, 5);

  tmpScroll := TspSkinScrollBar.Create(mainPanel);
  tmpScroll.Parent := mainPanel;
  tmpScroll.Name := 'sbChat' + IntToStr(ChatTab.TabIndex);
  tmpScroll.Kind := sbVertical;
  tmpScroll.Align := alRight;
  tmpScroll.Width := 19;
  tmpScroll.SkinData := ComponentModuleWindow.sppMain;
  tmpScroll.OnChange := tmpScrollBarChange;
  tmpScroll.SkinDataName := 'vscrollbar';
  tmpScroll.Min := 0;
  tmpScroll.Max := 100;
  tmpScroll.PageSize := 1;

  tmpChatBox := TRichView.Create(mainPanel);
  tmpChatBox.Parent := mainPanel;
  tmpChatBox.Name := 'chatBox' + IntToStr(ChatTab.TabIndex);
  tmpChatBox.Align := alClient;
  tmpChatBox.BorderStyle := bsNone;
  tmpChatBox.Style := styleChatbox;
  tmpChatBox.RTFReadProperties.UnicodeMode := rvruMixed;
  tmpChatBox.OnVScrolled := tmpChatBoxVScrolled;
  tmpChatBox.LeftMargin := 1;
  tmpChatBox.RightMargin := 1;
  tmpChatBox.TabStop := FALSE;
  tmpChatBox.PopupMenu := pmChatBox;
  tmpChatBox.VScrollVisible := FALSE;
  tmpChatBox.HScrollVisible := FALSE;
  tmpChatBox.Color := $D0CdC9;
  tmpChatBox.OnClick := ChatBoxClick;
  tmpChatBox.OnRVMouseUp := rvChatBoxMouseUp;

  mainPanel.TabStop := TRUE;
  mainPanel.TabOrder := 0;
  tmpChatBox.TabStop := FALSE;

  If ATabType in [ctIRC_Channel, ctPVPGN_Channel] Then
  Begin
    // User list panels and separators
    tmpPanel := CreatePanel(ChatTab, 'paCntUsers' + IntToStr(ChatTab.TabIndex), alRight, 200);
    CreatePanel(tmpPanel, 'pasLCntUsers' + IntToStr(ChatTab.TabIndex), alLeft, 3);
    CreatePanel(tmpPanel, 'pasRCntUsers' + IntToStr(ChatTab.TabIndex), alRight, 1);
    tmpPanel := CreatePanel(tmpPanel, 'paInCntUsers' + IntToStr(ChatTab.TabIndex), alClient);

    // User list search
    tmpEdit := CreateEdit(tmpPanel, 'ebSearchUser' + IntToStr(ChatTab.TabIndex), alBottom, taLeftJustify, 0, 20);
    tmpEdit.Tag := 2;
    tmpEdit.Text := RS_USER_SEARCH;
    tmpEdit.OnChange := ebSearchUserChange;
    tmpEdit.MaxLength := 15;
    tmpEdit.OnEnter := ebSearchUserEnter;
    tmpEdit.OnExit := ebSearchUserExit;
    tmpEdit.OnKeyDown := ebSearchUserKeyDown;
    tmpEdit.TabStop := TRUE;
    tmpEdit.TabOrder := 0;

    // Middle user list separator
    CreatePanel(tmpPanel, 'pasMCntUsers' + IntToStr(ChatTab.TabIndex), alBottom, 0, 3);

    // User list header
    tmpPanel1 := CreatePanel(tmpPanel, 'paHeader' + IntToStr(ChatTab.TabIndex), alTop, 10, 19, 'panel4');
    tmpPanel1.BorderStyle := bvFrame;
    tmpLabel := CreateLabel(tmpPanel1, 'lbHeaderChannel' + IntToStr(ChatTab.TabIndex), ACaption, alLeft, 0, 0, $00AC9266);
    tmpLabel.Tag := 1;
    tmpLabel.Font.Name := 'Tahoma';
    tmpLabel.Font.Size := 7;

    CreatePanel(tmpPanel1, 'pasTHeader' + IntToStr(ChatTab.TabIndex), alTop, 10, 1, 'panel4');

    tmpLabel := CreateLabel(tmpPanel1, 'lbHeaderUsersVal' + IntToStr(ChatTab.TabIndex), '0', alRight, 0, 0, $00AC9266);
    tmpLabel.Alignment := taRightJustify;
    tmpLabel.Tag := 2;
    tmpLabel.Font.Name := 'Tahoma';
    tmpLabel.Font.Size := 7;

    // User list
    tmpListBox := TspSkinOfficeListBox.Create(tmpPanel);
    tmpListBox.Parent := tmpPanel;
    tmpListBox.Name := 'lbUsers' + IntToStr(ChatTab.TabIndex);
    tmpListBox.Align := alClient;
    tmpListBox.StatusImages := ilUserStatus;
    tmpListBox.Images := ilAvatars35;
    tmpListBox.PopupMenu := pmUsersListbox;
    tmpListBox.ShowItemTitles := FALSE;
    tmpListBox.ShowLines := TRUE;
    tmpListBox.DrawDefault := FALSE;
    tmpListBox.ItemHeight := 40;
    tmpListBox.SkinData := ComponentModuleWindow.sppMain;
    tmpListBox.SkinDataName := 'listbox1';
    tmpListBox.ItemSkinDataName := 'listbox1';
    tmpListBox.OnMouseDown := lbUsersMouseDown;
    tmpListBox.OnDblClick := lbUsersDblClick;
    tmpListBox.OnClick := lbUsersClick;
    tmpListBox.OnKeyDown := lbUsersKeyDown;
    tmpListBox.TabStop := FALSE;
  End;

  If ATabType in [ctPVPGN_User, ctIRC_User] Then
  Begin
    tmpPanel := CreatePanel(mainPanel, 'paChatHeader' + IntToStr(ChatTab.TabIndex), alTop, 0, 25);
    tmpEdit := CreateEdit(tmpPanel, 'ebChatHeader' + IntToStr(ChatTab.TabIndex), alClient);
    tmpEdit.ReadOnly := TRUE;
    tmpEdit.Tag := 3;

    tmpButton := TspSkinSpeedButton.Create(tmpPanel);
    tmpButton.Parent := tmpPanel;
    tmpButton.Name := 'btChatHeaderClose' + IntToStr(ChatTab.TabIndex);
    tmpButton.Align := alRight;
    tmpButton.ImageList := ilTabIcons;
    tmpButton.ImageIndex := 5;
    tmpButton.Width := 25;
    tmpButton.SkinData := ComponentModuleWindow.sppMain;
    tmpButton.SkinDataName := 'hostgamebutton';
    tmpButton.OnClick := btCloseChatClick;
  End;

  Inc(ChatTabs.Count);
  SetLength(ChatTabs.Items, ChatTabs.Count);
  ChatTabs.Items[ChatTabs.Count - 1].TabType := ATabType;
  ChatTabs.Items[ChatTabs.Count - 1].Data := ACaption;
  SetLength(ChatTabs.Items[ChatTabs.Count - 1].ChatHistory, 0);
  ChatTabs.Items[ChatTabs.Count - 1].ChatHistoryPos := 0;
  ChatTabs.Items[ChatTabs.Count - 1].TabControl := ChatTab;
  ChatTabs.Items[ChatTabs.Count - 1].Flashing := FALSE;

  Case ChatTabs.Items[ChatTabs.Count - 1].TabType of
    ctPVPGN_Channel, ctIRC_Channel : TTabSheet(ChatTabs.Items[ChatTabs.Count - 1].TabControl).ImageIndex := 0;
    ctPVPGN_User, ctIRC_User : TTabSheet(ChatTabs.Items[ChatTabs.Count - 1].TabControl).ImageIndex := 3;
  else
    TTabSheet(ChatTabs.Items[ChatTabs.Count - 1].TabControl).ImageIndex := -1;
  End;


  result := ChatTab;
end;

function TMainWindow.GetChatTabInfo(const AChatTab : TTabSheet) : TTabInfo;
var
  C1 : Integer;
begin
  result.TabType := ctUnknown;
  result.TabControl := nil;
  SetLength(result.ChatHistory, 0);
  result.ChatHistoryPos := 0;
  result.Data := '';

  For C1 := 0 to ChatTabs.Count - 1 Do
    If ChatTabs.Items[C1].TabControl = AChatTab Then
    Begin
      result := ChatTabs.Items[C1];
      Break;
    End;
end;

function TMainWindow.DeleteChatTabInfo(const AChatTab : TTabSheet) : Boolean;
var
  C1, C2 : Integer;
begin
  result := FALSE;
  For C1 := 0 to ChatTabs.Count - 1 Do
    If ChatTabs.Items[C1].TabControl = AChatTab Then
    Begin
      For C2 := C1 to ChatTabs.Count - 2 Do
        ChatTabs.Items[C2] := ChatTabs.Items[C2 + 1];
      Dec(ChatTabs.Count);
      SetLength(ChatTabs.Items, ChatTabs.Count);
      result := TRUE;
      Break;
    End;
end;

procedure TMainWindow.mmOptionsClick(Sender: TObject);
var
  C1, C2    : Integer;
  lb        : TspSkinOfficeListBox;
  userInfo  : TUserInfo;
  oldSIcons : Integer;
  oldSkin   : String;
begin
  oldSkin := Options.Customize.Skin;
  oldSIcons := Options.Customize.StatusIcons;
  Application.CreateForm(TOptionsWindow, OptionsWindow);
  OptionsWindow.ShowModal;
  OptionsWindow := nil;

  If oldSkin <> Options.Customize.Skin Then
    LoadSkin(Options.Customize.Skin, ComponentModuleWindow.sppLogin, ComponentModuleWindow.sppMain, ComponentModuleWindow.spsLogin, ComponentModuleWindow.spsMain);

  If oldSIcons <> Options.Customize.StatusIcons Then
  Begin
    RefreshFriendList;

    For C1 := 0 to cntChat.PageCount - 1 Do
    Begin
      lb := GetChatTabUserList(cntChat.Pages[C1]);
      If Assigned(lb) Then
      Begin
        lb.BeginUpdateItems;
        For C2 := 0 to lb.Items.Count - 1 Do
          If C2 < lb.Items.Count Then
          Begin
            If GetUserInfo(lb.Items[C2].Title, userInfo) Then
              lb.Items[C2].StatusIndex := GetUserStatusIndexFromArea(userInfo.Area)
            else
              lb.Items[C2].StatusIndex :=  GetUserStatusIndex(usOnline);
          End
          else
            Break;
        lb.EndUpdateItems;
      End;
    End;

    tiAvatarsRefresh.OnTimer(Sender);

    smUserStatusOnline.ImageIndex := GetUserStatusIndex(usOnline);
    smUserStatusDND.ImageIndex := GetUserStatusIndex(usBusy);

    ShowMyStats; 
  End;
end;

function TMainWindow.CanClose : Boolean;
begin
  result := (not MinimizeOnClose) and
            (not Assigned(ContactWindow)) and
            (not Assigned(OptionsWindow)) and
            (not Assigned(TutorialWindow)) and
            (not Assigned(CommandsWindow)) and
            (not Assigned(FriendRequestWindow));
end;

procedure TMainWindow.ircDarerIRCMotd(Sender: TObject; Line: String; EndOfMotd: Boolean);
begin
//  ircDarer.Join('#delphi');
end;

procedure TMainWindow.ircDarerAfterJoined(Sender: TObject; Channelname: String);
begin
  CreateChatTab(Channelname, ctIRC_Channel);
end;

function TMainWindow.AddLineToChatTab(const AChatTab : TTabSheet; const ANick, ALine : WideString; const ANickStyle, ALineStyle : Integer) : Boolean;
var
  ChatBox  : TRichView;
  scroll   : TspSkinScrollBar;
  tmpTable : TRVTableItemInfo;
  fmtTime  : TFormatSettings;
begin
  result := FALSE;
  If Assigned(AChatTab) Then
  Begin
    ChatBox := GetChatTabChatBox(AChatTab);

    If Assigned(ChatBox) Then
    Begin
      If ChatBox.ItemCount >= Options.Client.ScrollbackLines Then
        ChatBox.DeleteParas(0, ChatBox.ItemCount - Options.Client.ScrollbackLines);

      fmtTime.LongTimeFormat := 'HH:MM:SS';
      fmtTime.TimeSeparator := ':';

      tmpTable := TRVTableItemInfo.CreateEx(1, 3, ChatBox.RVData);
      tmpTable.BorderWidth := 0;
      tmpTable.CellVPadding := 0;
      tmpTable.CellBorderWidth := 0;
      tmpTable.CellVSpacing := 0;
      tmpTable.BorderVSpacing := 0;
      tmpTable.Color := clNone;
      tmpTable.Options := [rvtoColSizing, rvtoRTFAllowAutofit];
      tmpTable.Cells[0, 0].BestWidth := 135;
      tmpTable.Cells[0, 2].BestWidth := 55;
      tmpTable.Cells[0, 0].Clear;
      tmpTable.Cells[0, 1].Clear;
      tmpTable.Cells[0, 2].Clear;

      tmpTable.Cells[0, 0].AddFmt('%s:', [ANick], ANickStyle, 0);
      tmpTable.Cells[0, 1].AddFmt(ALine, [], ALineStyle, 1);

      fmtTime.LongTimeFormat := 'HH:MM:SS';
      fmtTime.TimeSeparator := ':';
      tmpTable.Cells[0, 2].AddFmt(TimeToStr(Time, fmtTime), [], STYLE_TIMESTAMP, 2);

      ChatBox.AddItem('', tmpTable);

      scroll := GetChatTabScrollBar(AChatTab);
      If Assigned(scroll) Then
      Begin
        scroll.Max := ChatBox.VScrollMax;
        scroll.Position := ChatBox.VScrollPos;
        scroll.SmallChange := ChatBox.VSmallStep;
      End;

      If ChatBox.VScrollPos < ChatBox.VScrollMax Then
        ChatBox.Format
      else
        ChatBox.FormatTail;
      result := TRUE;

    End;

    If cntChat.ActivePage <> AChatTab Then
      FlashTab(AChatTab);
  End;
end;

procedure TMainWindow.ircDarerServerQuote(Sender: TObject; Command: String);
begin
//  AddLineToChatTab(CreateChatTab('Raw', ctIRC_Raw), '', Command, 0, 0);
end;

procedure TMainWindow.ebChatKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
const
  MAX_CHAT_HISTORY = 20;
var
  C1        : Integer;
  tabid     : Integer;
  IsCommand : Boolean;
  cmd       : WideString;
  nick, msg : WideString;
  prefix    : Char;
begin
  tabid := -1;
  For C1 := 0 to ChatTabs.Count - 1 Do
    If ChatTabs.Items[C1].TabControl = cntChat.ActivePage Then
    Begin
      tabid := C1;
      Break;
    End;

  If tabid <> -1 Then
    Case Key of
      vk_RETURN : Begin
                    If TspSkinEdit(Sender).Text <> '' Then
                    Begin
                      If Length(ChatTabs.Items[tabid].ChatHistory) = MAX_CHAT_HISTORY Then
                      Begin
                        For C1 := 0 to MAX_CHAT_HISTORY - 2 Do
                          ChatTabs.Items[tabid].ChatHistory[C1] := ChatTabs.Items[tabid].ChatHistory[C1 + 1];
                      End
                      else
                        SetLength(ChatTabs.Items[tabid].ChatHistory, Length(ChatTabs.Items[tabid].ChatHistory) + 1);
                      ChatTabs.Items[tabid].ChatHistory[Length(ChatTabs.Items[tabid].ChatHistory) - 1] := TspSkinEdit(Sender).Text;
                      ChatTabs.Items[tabid].ChatHistoryPos := Length(ChatTabs.Items[tabid].ChatHistory);

                      IsCommand := TspSkinEdit(Sender).Text[1] = '/';

                      If UserDetails.Colored Then
                        prefix := 'c'
                      else
                        prefix := 'n';

                      If not IsCommand Then
                      Begin
                        Case ChatTabs.Items[tabid].TabType of
                          ctIRC_Raw, ctIRC_Channel, ctIRC_User : ;
                          ctPVPGN_Raw                          : ;
                          ctPVPGN_Channel                      : Begin
                                                                   ComponentModuleWindow.GProxy.Say(prefix + TspSkinEdit(Sender).Text);

                                                                   If UserDetails.Colored Then
                                                                     AddLineToChatTab(cntChat.ActivePage, UserDetails.Username, TspSkinEdit(Sender).Text,
                                                                                      STYLE_COLORED_SND, STYLE_COLORED_MSG)
                                                                   else
                                                                     AddLineToChatTab(cntChat.ActivePage, UserDetails.Username, TspSkinEdit(Sender).Text,
                                                                                      STYLE_MY_SND, STYLE_MY_MSG);
                                                                 End;
                          ctPVPGN_User                         : Begin
                                                                   ComponentModuleWindow.GProxy.Whisper(GetChatTabInfo(cntChat.ActivePage).Data, prefix + TspSkinEdit(Sender).Text);
                                                                 End;
                        End;
                      End
                      else
                      Begin
                        If (Pos('/join ', LowerCase(TspSkinEdit(Sender).Text)) = 1) or
                           (Pos('/channel ', LowerCase(TspSkinEdit(Sender).Text)) = 1) Then
                        Begin
                          cmd := TspSkinEdit(Sender).Text;
                          Delete(cmd, 1, Pos(' ', cmd));
                          JoinChannel(cmd);
                        End
                        else
                          If ((Pos('/f ', LowerCase(TspSkinEdit(Sender).Text)) = 1) and
                              (Pos('/f msg ', LowerCase(TspSkinEdit(Sender).Text)) = 0)) or
                             ((Pos('/friends ', LowerCase(TspSkinEdit(Sender).Text)) = 1) and
                              (Pos('/friends msg ', LowerCase(TspSkinEdit(Sender).Text)) = 0)) Then
                          Begin
                          End
                          else
                            If (Pos('/w ', LowerCase(TspSkinEdit(Sender).Text)) = 1) or
                               (Pos('/m ', LowerCase(TspSkinEdit(Sender).Text)) = 1) or
                               (Pos('/whisper ', LowerCase(TspSkinEdit(Sender).Text)) = 1) or
                               (Pos('/msg ', LowerCase(TspSkinEdit(Sender).Text)) = 1) Then
                            Begin
                              cmd := TspSkinEdit(Sender).Text;
                              Delete(cmd, 1, Pos(' ', cmd));
                              nick := Copy(cmd, 1, Pos(' ', cmd) - 1);
                              If nick <> '' Then
                              Begin
                                Delete(cmd, 1, Pos(' ', cmd));
                                msg := cmd;
                                If msg <> '' Then
                                  msg := prefix + msg;

                                ComponentModuleWindow.GProxy.Whisper(nick, msg);
                              End;
                            End
                            else
                              If LowerCase(TspSkinEdit(Sender).Text) = '/debug' Then
                              Begin
                                DebugMode := not DebugMode;

                                If DebugMode Then
                                Begin
                                  AddLineToChatTab(cntChat.ActivePage, 'DEBUG', 'ON', STYLE_USER_SND, STYLE_BOT_MSG);
                                  SendDebugData;
                                End
                                else
                                  AddLineToChatTab(cntChat.ActivePage, 'DEBUG', 'OFF', STYLE_USER_SND, STYLE_ERROR_MSG);
                              End
                              else
                                ComponentModuleWindow.GProxy.Say(TspSkinEdit(Sender).Text);
                      End;

                      TspSkinEdit(Sender).Clear;
                    End;
                  End;
      VK_UP,
      VK_DOWN    : Begin
                    If Key = VK_UP Then
                      Dec(ChatTabs.Items[tabid].ChatHistoryPos)
                    else
                      Inc(ChatTabs.Items[tabid].ChatHistoryPos);

                    If (ChatTabs.Items[tabid].ChatHistoryPos < 0) Then
                      Inc(ChatTabs.Items[tabid].ChatHistoryPos);

                    If (ChatTabs.Items[tabid].ChatHistoryPos > Length(ChatTabs.Items[tabid].ChatHistory) - 1) Then
                    Begin
                      Dec(ChatTabs.Items[tabid].ChatHistoryPos);
                      TspSkinEdit(Sender).Clear;
                    End
                    else
                      If (ChatTabs.Items[tabid].ChatHistoryPos >= 0) and
                         (ChatTabs.Items[tabid].ChatHistoryPos < Length(ChatTabs.Items[tabid].ChatHistory)) Then
                      Begin
                        TspSkinEdit(Sender).Text := ChatTabs.Items[tabid].ChatHistory[ChatTabs.Items[tabid].ChatHistoryPos];
                        TspSkinEdit(Sender).SelStart := Length(TspSkinEdit(Sender).Text)
                      End;
                  End;
    End;
end;

procedure TMainWindow.SendDebugData;
begin
  If DebugMode Then
  Begin
    AddLineToChatTab(cntChat.ActivePage, 'DEBUG', Format('User details call: %d seconds ago', [(GetTickCount - DebugTime_GetUserDetails) div 1000]), STYLE_USER_SND, STYLE_USER_MSG);
    AddLineToChatTab(cntChat.ActivePage, 'DEBUG', Format('TGID = %d', [UserDetails.Tour.TGID]), STYLE_USER_SND, STYLE_USER_MSG);
    AddLineToChatTab(cntChat.ActivePage, 'DEBUG', Format('CS = %d', [UserDetails.Tour.CS]), STYLE_USER_SND, STYLE_USER_MSG);
    AddLineToChatTab(cntChat.ActivePage, 'DEBUG', Format('TD = %d', [UserDetails.Tour.TD]), STYLE_USER_SND, STYLE_USER_MSG);
    AddLineToChatTab(cntChat.ActivePage, 'DEBUG', Format('TN = %s', [UserDetails.Tour.TN]), STYLE_USER_SND, STYLE_USER_MSG);
  End;
end;

procedure TMainWindow.ircDarerIRCNickInUse(Sender: TObject; Nickname: String);
begin
//  ircDarer.Nick(Nickname + '^');
end;

procedure TMainWindow.tmpScrollBarChange(Sender: TObject);
var
  cbox : TRichView;
begin
  cbox := GetChatTabChatBox(TspSkinScrollBar(Sender).Parent);
  If Assigned(cbox) Then
  Begin
    cbox.VScrollPos := TspSkinScrollBar(Sender).Position;
    If TspSkinScrollBar(Sender).Position = TspSkinScrollBar(Sender).Max Then
      cbox.VScrollPos := cbox.VScrollMax;
  End;
end;

procedure TMainWindow.tmpChatboxVScrolled(Sender: TObject);
var
  scbar : TspSkinScrollBar;
begin
  scbar := GetChatTabScrollBar(TRichView(Sender).Parent);
  If Assigned(scbar) Then
    scbar.Position := TRichView(Sender).VScrollPos;
end;

procedure TMainWindow.FlashTab(const AChatTab : TTabSheet; const AFlashing : Boolean = TRUE);
var
  C1 : Integer;
begin
  For C1 := 0 to ChatTabs.Count - 1 Do
    If ChatTabs.Items[C1].TabControl = AChatTab Then
    Begin
      ChatTabs.Items[C1].Flashing := AFlashing;
      If ChatTabs.Items[C1].Flashing Then
      Begin
        If TTabSheet(ChatTabs.Items[C1].TabControl).ImageIndex = 0 Then
          TTabSheet(ChatTabs.Items[C1].TabControl).ImageIndex := 1
        else
          If TTabSheet(ChatTabs.Items[C1].TabControl).ImageIndex = 2 Then
            TTabSheet(ChatTabs.Items[C1].TabControl).ImageIndex := 3;
      End
      else
        If TTabSheet(ChatTabs.Items[C1].TabControl).ImageIndex = 1 Then
          TTabSheet(ChatTabs.Items[C1].TabControl).ImageIndex := 0
        else
          If TTabSheet(ChatTabs.Items[C1].TabControl).ImageIndex = 3 Then
            TTabSheet(ChatTabs.Items[C1].TabControl).ImageIndex := 2;
      Break;
    End;
end;

procedure TMainWindow.cntChatChange(Sender: TObject);
var
  ebox : TspSkinEdit;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: cntChatChange() :: BEGIN');  {$ENDIF}

  RefreshUserListHeader(cntChat.ActivePage);
  FlashTab(cntChat.ActivePage, FALSE);
  ebox := GetChatTabEdit(cntChat.ActivePage, 1);
  If Assigned(ebox) Then
  Begin
    ebox.SetFocus;
    ebox.SelStart := Length(ebox.Text);
    ChatEditCaretPos := ebox.SelStart;
  End;

  RefreshChannelMenu;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: cntChatChange() :: END');  {$ENDIF}
end;

procedure TMainWindow.RefreshChannelMenu;
var
  ctab : TTabSheet;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: RefreshChannelMenu() :: BEGIN');  {$ENDIF}

  ctab := GetChatTab('', ctPVPGN_Channel);
  If (Assigned(ctab)) and
     (ctab.TabIndex = cntChat.TabIndex) Then
  Begin
    smAddChannelToFavs.Visible := TRUE;
    Case IsChannelFavorite(ctab.Caption) of
      0 : smAddChannelToFavs.Caption := RS_CHAN_ADD_TO_FAVS;
      1 : smAddChannelToFavs.Caption := RS_CHAN_REMOVE_FROM_FAVS;
      2 : smAddChannelToFavs.Visible := FALSE;
    End;
  End
  else
    smAddChannelToFavs.Visible := FALSE;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: RefreshChannelMenu() :: END');  {$ENDIF}
end;

procedure TMainWindow.ebMinRatingKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Case Key of
    vk_RETURN : SelectNext(ActiveControl as TWinControl, TRUE, TRUE);
  End;
end;

procedure TMainWindow.RealignListBox;
var
  lb : TspSkinOfficeListBox;
begin
  If Assigned(cntChat.ActivePage) Then
  Begin
    lb := GetChatTabUserList(cntChat.ActivePage);
    If Assigned(lb) Then
      lb.Realign;
  End;
end;

procedure TMainWindow.FormResize(Sender: TObject);
begin
  RealignListBox;
  UpdateStringGridSize;

  lbSeeAllRequests.Left := paBanner.Width - lbSeeAllRequests.Width - 15;
  lbSeeAllMessages.Left := paBanner.Width - lbSeeAllMessages.Width - 15;

  If paClientNotifications.Visible Then
  Begin
    ResizeLabel(lbNotificationHeader);
    ResizeLabel(lbNotificationFooter);
  End;
end;

procedure TMainWindow.lbUsersMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  itemindex : Integer;
  userInfo  : TUserInfo;
  index     : Integer;
begin
  Case Button of
    mbRight, mbLeft : Begin
                        If TspSkinOfficeListBox(Sender).ItemAtPos(X, Y) = -1 Then
                          SelectedUser := -1
                        else
                        Begin
                          itemindex := TspSkinOfficeListBox(Sender).ItemAtPos(X, Y);
                          TspSkinOfficeListBox(Sender).ItemIndex := itemindex;
                          SelectedUser := TspSkinOfficeListBox(Sender).Items[itemindex].ID;
                          If TspSkinOfficeListBox(Sender).Items[itemindex].Title = UserDetails.Username Then
                            TspSkinOfficeListBox(Sender).PopupMenu := pmMyselfListBox
                          else
                          Begin
                            TspSkinOfficeListBox(Sender).PopupMenu := pmUsersListbox;
                            If (GetUserInfo(TspSkinOfficeListBox(Sender).Items[itemindex].Title, userInfo)) and
                               (userInfo.IsFriend_Site) or
                               (userinfo.IsFriend_PVPGN) Then
                              smAddToFriends.Caption := RS_REMOVE_FROM_FRIENDS
                            else
                              smAddToFriends.Caption := RS_ADD_TO_FRIENDS;

                            If Blocklist.Find(TspSkinOfficeListBox(Sender).Items[itemindex].Title, index) Then
                              smBlock.Caption := RS_UNBLOCK_USER
                            else
                              smBlock.Caption := RS_BLOCK_USER;
                          End;
                        End;
                      End;
  End;
end;

procedure TMainWindow.cntChatClose(Sender: TObject; var CanClose: Boolean);
begin
  Case GetChatTabInfo(TTabSheet(Sender)).TabType of
    ctPVPGN_User, ctIRC_User : CanClose := TRUE
  else
    CanClose := FALSE;
  End;

  If CanClose Then
  Begin
    DeleteChatTabInfo(TTabSheet(Sender));
    AfterCloseIndex := TTabSheet(Sender).TabIndex;
  End;
end;

procedure TMainWindow.smChatClick(Sender: TObject);
var
  lb   : TspSkinOfficeListBox;
  item : TCollectionItem;
begin
  lb := GetChatTabUserList(cntChat.ActivePage);
  If Assigned(lb) Then
  Begin
    item := lb.Items.FindItemID(SelectedUser);
    If (Assigned(item)) and
       (TspSkinOfficeItem(item).Title <> UserDetails.Username) Then
      OpenPVPGNUserChat(TspSkinOfficeItem(item).Title, TRUE);
  End;
end;

procedure TMainWindow.ebSearchUserKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Case Key of
    vk_RETURN : smChat.Click;
  End;
end;

procedure TMainWindow.lbUsersDblClick(Sender: TObject);
begin
  smChat.Click;
end;

procedure TMainWindow.lbUsersKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  SelectedUser := TspSkinOfficeListBox(Sender).Items[TspSkinOfficeListBox(Sender).ItemIndex].ID;
end;

procedure TMainWindow.smPingClick(Sender: TObject);
var
  lb   : TspSkinOfficeListBox;
  item : TCollectionItem;
begin
  lb := GetChatTabUserList(cntChat.ActivePage);
  If Assigned(lb) Then
  Begin
    item := lb.Items.FindItemID(SelectedUser);
    If Assigned(item) Then
      ComponentModuleWindow.GProxy.Command(Format('ping %s', [TspSkinOfficeItem(item).Title]));
  End;
end;

procedure TMainWindow.ebSearchFriendsExit(Sender: TObject);
begin
  TspSkinEdit(Sender).Text := RS_SEARCH_FRIENDS;
end;

procedure TMainWindow.tiPVPGNUsersUpdateTimer(Sender: TObject);
begin
  ComponentModuleWindow.GProxy.UpdateUsers;
end;

procedure TMainWindow.PopulateGameTypeCombobox;
var
  index : Integer;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: PopulateGameTypeCombobox() :: BEGIN');  {$ENDIF}

  index := cbGameType.ItemIndex;

  cbGameType.Items.Clear;
  cbGameType.Items.Add(RS_GAMETYPE_FREE);
  cbGameType.Items.Add(RS_GAMETYPE_LADDER);
  cbGameType.Items.Add(RS_GAMETYPE_CHALLENGE);

  If (index >= 0) and
     (index < cbGameType.Items.Count) Then
    cbGameType.ItemIndex := index
  else
    cbGameType.ItemIndex := 1;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: PopulateGameTypeCombobox() :: END');  {$ENDIF}
end;

procedure TMainWindow.OnCHATE(ASender : TGProxy; const ACommand, AParams : WideString);
var
  s      : WideString;
  newdnd : Boolean;
  admins : TStringList;
  index  : Integer;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: OnCHATE() :: BEGIN');  {$ENDIF}

  If ACommand = 'INFO' Then
  Begin
    // There are currently 786 users online, in 143 games and 39 channels.
    //   0    1      2      3    4      5     6  7    8    9  10    11
    // There are currently 587 user(s) in 94 games of Warcraft III Frozen Throne
    //   0    1      2      3    4     5  6    7    8     9     10   11     12
    If (MatchStrings('There are currently * users online, in * games and * channels.', AParams, TRUE)) or
       (MatchStrings('There are currently * user(s) in * games of Warcraft III Frozen Throne', AParams, TRUE)) Then
      lbOnlinePlayersVal.Caption := GetParam(AParams, 3)
    else
    // <user> latency <latency>
    //    0      1        2
      If MatchStrings('* latency *', AParams, TRUE) Then
      Begin
        If (GetParam(AParams, 0) = UserDetails.Username) or
           (GetParam(AParams, 0) = 'Your') Then
          AddLineToChatTab(cntChat.ActivePage, RS_SERVER_INFO, Format(RS_MY_LATENCY, [GetParam(AParams, 2)]),
                           STYLE_INFO_SND, STYLE_INFO_MSG)

        else
          AddLineToChatTab(cntChat.ActivePage, RS_SERVER_INFO, Format(RS_PING_TO, [GetParam(AParams, 0), GetParam(AParams, 2)]),
                           STYLE_INFO_SND, STYLE_INFO_MSG);
      End
      else
        // Currently logged on Administrators: etheria.one psionic.one SoulCollector
        //     0        1    2        3
        If MatchStrings('Currently logged on Administrators: *', AParams, TRUE) Then
        Begin
          s := AParams;
          Delete(s, 1, 36);
          s := Trim(s);

          admins := TStringList.Create;
          admins.Sorted := TRUE;
          admins.Duplicates := dupIgnore;

          Split(' ', s, admins);
          If admins.Find('psi', index) Then
            admins.Delete(index);

          s := '';
          While admins.Count > 0 Do
          Begin
            s := s + admins.Strings[0] + ' ';
            admins.Delete(0);
          End;
          s := Trim(s);

          If Length(s) > 0 Then
            AddLineToChatTab(cntChat.ActivePage, RS_SERVER_INFO, Format(RS_ONLINE_ADMINS, [s]), STYLE_INFO_SND, STYLE_INFO_MSG)
          else
            AddLineToChatTab(cntChat.ActivePage, RS_SERVER_INFO, RS_NO_ONLINE_ADMINS, STYLE_INFO_SND, STYLE_INFO_MSG);
        End
        else
          If (AParams = 'No one hears you.') or
             (AParams = 'you are now tempOP for this channel') Then
          Begin
          End
          else
          Begin
            newdnd := FALSE;

            If (AParams = 'Do Not Disturb mode engaged.') Then
            Begin
              MyDND := TRUE;
              newdnd := TRUE;
            End;

            If (AParams = 'Do Not Disturb mode cancelled.') Then
            Begin
              MyDND := FALSE;
              newdnd := TRUE;
            End;

            If newdnd Then
            Begin
              If MyDND Then
                MyStatus := usBusy
              else
                MyStatus := usOnline;
                
              ShowMyStats;
            End;

            AddLineToChatTab(cntChat.ActivePage, RS_SERVER_INFO, AParams, STYLE_INFO_SND, STYLE_INFO_MSG);
          End;

  End;

  If ACommand = 'BROADCAST' Then
  Begin
    //  Announcement from psi: Available Games:  Fun: RU | SD | mW.Slander.int(1/10) TR | AP | MazI(9/10) PL | AP | kanitel17(4/10)
    If (MatchStrings('Announcement from *: Available Games: *', AParams, TRUE)) Then
    Begin
      s := AParams;
      Delete(s, 1, Pos('Available Games: ', s) + 17);
      s := Trim(s);

      s := Format('%s %s', [RS_AVAILABLE_GAMES, s]);
    End
    else
      AddLineToChatTab(cntChat.ActivePage, RS_SERVER_BROADCAST, AParams, STYLE_BROADCAST_SND, STYLE_BROADCAST_MSG);
  End;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: OnCHATE() :: END');  {$ENDIF}
end;

procedure TMainWindow.smClearClick(Sender: TObject);
var
  cbox : TRichView;
begin
  cbox := GetChatTabChatBox(cntChat.ActivePage);
  If Assigned(cbox) Then
  Begin
    cbox.Clear;
    cbox.VScrollPos := cbox.VScrollMax;
    cbox.OnVScrolled(cbox);
    cbox.Refresh;
  End;
end;

procedure TMainWindow.smCopyClick(Sender: TObject);
var
  cbox : TRichView;
begin
  cbox := GetChatTabChatBox(cntChat.ActivePage);
  If Assigned(cbox) Then
    cbox.Copy;
end;

procedure TMainWindow.smOnlineAdminsClick(Sender: TObject);
begin
  ComponentModuleWindow.GProxy.Command('admins');
end;

procedure TMainWindow.smPingToServerClick(Sender: TObject);
begin
  ComponentModuleWindow.GProxy.Command(Format('ping %s', [UserDetails.Username]));
end;

procedure TMainWindow.ChatBoxClick(Sender: TObject);
begin
{
   Commented this because if user cant select chatbox, he cant scroll it with scroll button on mouse
   Find a way around this, either disable it or detect somehow if user is scrolling and mouse cursor is over chatbox and simulate that with code
}

//  GetChatTabEdit(TWinControl(Sender).Parent, 1).SetFocus;
//  GetChatTabEdit(TWinControl(Sender).Parent, 1).SelStart := ChatEditCaretPos;
end;

procedure TMainWindow.ChatBoxExit(Sender: TObject);
begin
  ChatEditCaretPos := TspSkinEdit(Sender).SelStart;
end;

procedure TMainWindow.OnChannelChat(ASender : TGProxy; const AUser, ALine : WideString);
var
  newLine : WideString;
begin
  newLine := ALine;
  Delete(newLine, 1, 1);

  If Pos(LowerCase(UserDetails.Username), LowerCase(ALine)) = 0 Then
  Begin
    If Length(ALine) > 0 Then
      Case ALine[1] of
        'c' : AddLineToChatTab(GetPVPGNTab(ctPVPGN_Channel), AUser, newLine, STYLE_COLORED_SND, STYLE_COLORED_MSG);
        'n' : AddLineToChatTab(GetPVPGNTab(ctPVPGN_Channel), AUser, newLine, STYLE_USER_SND, STYLE_USER_MSG);
      else
        AddLineToChatTab(GetPVPGNTab(ctPVPGN_Channel), AUser, ALine, STYLE_USER_SND, STYLE_USER_MSG);
      End;
  End
  else
  Begin
    AddLineToChatTab(GetPVPGNTab(ctPVPGN_Channel), AUser, newLine, STYLE_HIGHLIGHTED_SND, STYLE_HIGHLIGHTED_MSG);
    PSoundWrapper(Options.Sounds.Highlighted);
  End;
end;

function GetGamesListItemPanel(const AControl : TWinControl) : TspSkinPanel;
var
  C1 : Integer;
begin
  result := nil;
  If Assigned(AControl) Then
    For C1 := 0 to AControl.ControlCount - 1 Do
      If (AControl.Controls[C1] is TspSkinPanel) and
         (AControl.Controls[C1].Tag = 1) Then
      Begin
        result := TspSkinPanel(AControl.Controls[C1]);
        Break;
      End;
end;

procedure TMainWindow.UpdateStringGridSize;
begin
  sgGameList.ColWidths[0] := lbGamesStatus.Width;
  sgGameList.ColWidths[1] := lbGamesType.Width;
  sgGameList.ColWidths[2] := lbGamesHost.Width;
  sgGameList.ColWidths[3] := lbGamesSlots.Width;
  sgGameList.ColWidths[4] := lbGamesMode.Width;

  imgSortHost.Left := lbGamesHost.Left + (lbGamesHost.Width - Canvas.TextWidth(lbGamesHost.Caption)) div 2 - imgSortHost.Width - 8;
  imgSortSlots.Left := lbGamesSlots.Left + (lbGamesSlots.Width - Canvas.TextWidth(lbGamesSlots.Caption)) div 2 - imgSortSlots.Width - 8;
  imgSortMode.Left := lbGamesMode.Left + (lbGamesMode.Width - Canvas.TextWidth(lbGamesMode.Caption)) div 2 - imgSortMode.Width - 8;
end;

procedure TMainWindow.UpdateGameList;
var
  C1  : Integer;
  tmp : String;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: UpdateGameList() :: BEGIN');  {$ENDIF}

  sgGameList.RowCount := 1;
  sgGameList.Rows[0].Clear;

  For C1 := 0 to GameList.Count - 1 Do
  Begin
    If C1 > 0 Then
      sgGameList.RowCount := sgGameList.RowCount + 1;

    Case GameList.Items[C1].Status of
      gsOpen    : tmp := RS_GAME_OPEN;
      gsStarted : tmp := RS_GAME_STARTED;
    End;
    sgGameList.Cells[0, C1] := tmp;

    Case GameList.Items[C1].Type_ of
      gtFree    : tmp := RS_GAME_FREE;
      gtLadder  : tmp := RS_GAME_LADDER;
      gtUnknown : tmp := '?';
    End;
    sgGameList.Cells[1, C1] := tmp;

    sgGameList.Cells[2, C1] := GameList.Items[C1].Host;
    sgGameList.Cells[3, C1] := GameList.Items[C1].Slots;
    sgGameList.Cells[4, C1] := GameList.Items[C1].Mode;
    sgGameList.ColAligns[0] := taCenter;
    sgGameList.ColAligns[1] := taCenter;
    sgGameList.ColAligns[2] := taLeftJustify;
    sgGameList.ColAligns[3] := taCenter;
    sgGameList.ColAligns[4] := taCenter;
  End;

  sbGameList.Max := sgGameList.RowCount - sgGameList.Height div sgGameList.DefaultRowHeight + 1;
  If sbGameList.Max < 0 Then
    sbGameList.Max := 0;
  If sbGameList.Max > 0 Then
    sbGameList.Position := 0;

  SortGameList(GameListSortColumn, GameListSortAscending);

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: UpdateGameList() :: END');  {$ENDIF}
end;

procedure TMainWindow.OnOutWhisper(ASender : TGProxy; const AUser, ALine : WideString);
var
  C1      : Integer;
  bot     : Boolean;
  newLine : WideString;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: OnOutWhisper() :: BEGIN');  {$ENDIF}

  If (AUser = '') or
     (ALine = '') Then
    Exit;

  bot := FALSE;
  For C1 := 0 to BOTS_COUNT - 1 Do
    If MatchStrings(AUser, BOTS_NAMES[C1], TRUE) Then
    Begin
      bot := TRUE;
      Break;
    End;

  If not bot Then
  Begin
    If not P2P_ValidString(ALine) Then
    Begin
      newLine := ALine;
      Delete(newLine, 1, 1);

      If not Assigned(GetChatTab(AUser, ctPVPGN_User)) Then
      Begin
        If Length(ALine) > 0 Then
          Case ALine[1] of
            'c' : AddLineToChatTab(OpenPVPGNUserChat(AUser, TRUE), UserDetails.Username, newLine, STYLE_COLORED_SND, STYLE_COLORED_MSG);
            'n' : AddLineToChatTab(OpenPVPGNUserChat(AUser, TRUE), UserDetails.Username, newLine, STYLE_USER_SND, STYLE_USER_MSG);
          else
            AddLineToChatTab(OpenPVPGNUserChat(AUser, TRUE), UserDetails.Username, ALine, STYLE_USER_SND, STYLE_USER_MSG);
          End;
      End
      else
      Begin
        If Length(ALine) > 0 Then
          Case ALine[1] of
            'c' : AddLineToChatTab(GetChatTab(AUser, ctPVPGN_User), UserDetails.Username, newLine, STYLE_COLORED_SND, STYLE_COLORED_MSG);
            'n' : AddLineToChatTab(GetChatTab(AUser, ctPVPGN_User), UserDetails.Username, newLine, STYLE_USER_SND, STYLE_USER_MSG);
          else
            AddLineToChatTab(GetChatTab(AUser, ctPVPGN_User), UserDetails.Username, ALine, STYLE_USER_SND, STYLE_USER_MSG);
          End;
      End;
    End;
  End
  else
    AddLineToChatTab(cntChat.ActivePage, Format('%s > %s', [UserDetails.Username, AUser]), ALine, STYLE_USER_SND, STYLE_BOT_MSG);

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: OnOutWhisper() :: END');  {$ENDIF}
end;

procedure TMainWindow.ParseBotWhisper(ASender : TGProxy; const AUser, ALine : WideString);
var
  quiet : Boolean;
Begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: ParseBotWhisper() :: BEGIN');  {$ENDIF}

  quiet := FALSE;
  If (MatchStrings('unhosting game on bot*', ALine, TRUE)) or
     (MatchStrings('Unhosting game [*].', ALine, TRUE)) or
     (MatchStrings('Your friend * has entered the game *', ALine, TRUE)) or
     (MatchStrings('Your friend * has left the game *', ALine, TRUE)) or
     ((AUser = 'psi') and
      (MatchStrings('EG * * *', ALine, TRUE))) Then
    quiet := TRUE
  else
    If MatchStrings('Invalid parameters!*', ALine, TRUE) Then
      AddLineToChatTab(cntChat.ActivePage, AUser, RS_BOT_INVALID_PARAMS, STYLE_BOT_SND, STYLE_BOT_MSG)
    else
      If MatchStrings('HG * * *', ALine, TRUE) Then
      Begin
        GameHosted := TRUE;
        GameName := TempGameName;
        tiHostTimeout.Enabled := FALSE;
        btGameHost.Caption := RS_GAME_UNHOST;
        btGameHost.Enabled := TRUE;
        SetGameHostCaption(RS_GAME_HOSTED);
        quiet := TRUE;
      End
      else
        If MatchStrings('You are already hosting a game on bot*', ALine, TRUE) Then
        Begin
          GameHosted := TRUE;
          tiHostTimeout.Enabled := FALSE;
          btGameHost.Caption := RS_GAME_UNHOST;
          btGameHost.Enabled := TRUE;
          SetGameHostCaption(RS_GAME_ALREADY_HOSTED);
          quiet := TRUE;
        End
        else
          If MatchStrings('UHG * * *', ALine, TRUE) Then
          Begin
            SetGameHostCaption(RS_GAME_UNHOSTED);
            GameName := '';
            GameHosted := FALSE;
            tiHostTimeout.Enabled := FALSE;
            btGameHost.Caption := RS_GAME_HOST;
            btGameHost.Enabled := TRUE;
            EnableHostSettings(TRUE);
            quiet := TRUE;
          End
          else
            If MatchStrings('Game [* : * : * : *] is over.', ALine, TRUE) Then
            Begin
              GameName := '';
              GameHosted := FALSE;
              tiHostTimeout.Enabled := FALSE;
              btGameHost.Caption := RS_GAME_HOST;
              btGameHost.Enabled := TRUE;
              EnableHostSettings(TRUE);
              quiet := TRUE;
            End
            else
              If (AUser = 'psi') and
                 ((MatchStrings('* active - * today, bot*=*, bot*=*, bot*=*, bot*=*', ALine, TRUE)) or
                  (MatchStrings('*bot*=*, bot*=*', ALine, TRUE))) Then
              Begin
                quiet := TRUE;
                GameList.Count := 0;
                SetLength(GameList.Items, GameList.Count);
              End
              else
              // Your friend iDC-AnGeul- has entered a Warcraft III Frozen Throne game named "BY.AP | Super-8".
                If (AUser = 'System') Then
                Begin
                  If (MatchStrings('Your friend * has entered a Warcraft III Frozen Throne game named "*".', ALine, TRUE)) Then
                  Begin
                    If Options.Client.ShowFriendGameMsgs Then
                    Begin
                      quiet := FALSE;
                      AddLineToChatTab(cntChat.ActivePage, AUser, ALine, STYLE_BOT_SND, STYLE_BOT_MSG);
  //                    PSoundWrapper(Options.Sounds.FriendGameEnter);
                    End
                    else
                      quiet := TRUE;
                  End
                  else
                    If MatchStrings('Your friend * has left a Warcraft III Frozen Throne game.', ALine, TRUE) Then
                    Begin
                      If Options.Client.ShowFriendGameMsgs Then
                      Begin
                        quiet := FALSE;
                        AddLineToChatTab(cntChat.ActivePage, AUser, ALine, STYLE_BOT_SND, STYLE_BOT_MSG);
  //                      PSoundWrapper(Options.Sounds.FriendGameLeave);
                      End
                      else
                        quiet := TRUE;
                    End
                    else
                      If MatchStrings('Your friend * has left Darer', ALine, TRUE) Then
                      Begin
                        quiet := TRUE;
                        If Options.Client.ShowFriendOnlineMsgs Then
                        Begin
                          AddLineToChatTab(cntChat.ActivePage, AUser, ALine, STYLE_BOT_SND, STYLE_BOT_MSG);
                          PSoundWrapper(Options.Sounds.FriendOff);
                        End;
                      End
                      else
                        If MatchStrings('Your friend * has entered Darer', ALine, TRUE) Then
                        Begin
                          quiet := TRUE;
                          If Options.Client.ShowFriendOnlineMsgs Then
                          Begin
                            AddLineToChatTab(cntChat.ActivePage, AUser, ALine, STYLE_BOT_SND, STYLE_BOT_MSG);
                            PSoundWrapper(Options.Sounds.FriendOn);
                          End;
                        End;
                End
                else
                  AddLineToChatTab(cntChat.ActivePage, AUser, ALine, STYLE_BOT_SND, STYLE_BOT_MSG);

  If not quiet Then
    PSoundWrapper(Options.Sounds.BotPM);

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: ParseBotWhisper() :: END');  {$ENDIF}
end;

procedure TMainWindow.OnWhisper(ASender : TGProxy; const AUser, ALine : WideString);
var
  ass          : Boolean;
  C1           : Integer;
  bot          : Boolean;
  params       : String;
  uid          : Integer;
  newLine      : WideString;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: OnWhisper() :: BEGIN');  {$ENDIF}

  ass := Assigned(GetChatTab(AUser, ctPVPGN_User));

  bot := FALSE;
  For C1 := 0 to BOTS_COUNT - 1 Do
    If MatchStrings(AUser, BOTS_NAMES[C1], TRUE) Then
    Begin
      bot := TRUE;
      Break;
    End;

  If bot Then
    ParseBotWhisper(ASender, AUser, ALine)
  else
  Begin
    Case P2P_Process(ALine, params) of
      -1                 : Begin
                             newLine := ALine;
                             Delete(newLine, 1, 1);

                             If Length(ALine) > 0 Then
                               Case ALine[1] of
                                 'c' : AddLineToChatTab(OpenPVPGNUserChat(AUser, FALSE), AUser, newLine, STYLE_COLORED_SND, STYLE_COLORED_MSG);
                                 'n' : AddLineToChatTab(OpenPVPGNUserChat(AUser, FALSE), AUser, newLine, STYLE_USER_SND, STYLE_USER_MSG);
                               else
                                 AddLineToChatTab(OpenPVPGNUserChat(AUser, FALSE), AUser, ALine, STYLE_USER_SND, STYLE_USER_MSG);
                               End;

                             If ass Then
                               PSoundWrapper(Options.Sounds.PM)
                             else
                               PSoundWrapper(Options.Sounds.NewPM);

                             If FindControl(GetForegroundWindow) = nil Then
                             Begin
                               AddNotificationForUser(AUser);

                               If (Options.Client.ShowPopups) and
                                  (MainWindow.IsMinimized) and
                                  (not Ingame) Then
                                 ShowPopup(AUser, newLine);
                             End;
                           End;

      P2P_RPL_USERSTATS : Begin
                            If paUserInfo.Tag >= 0 Then
                            Begin
                              If Users.Items[paUserInfo.Tag].Username = params Then
                                ShowUserStats(paUserInfo.Tag);
                            End;
                          End;

      P2P_RPL_FRIENDSHIP, P2P_RPL_REFRESH_STATS : Begin
                                                    tiMyDetailsUpdate.Interval := 2000;
                                                    tiMyDetailsUpdate.Enabled := FALSE;
                                                    tiMyDetailsUpdate.Enabled := TRUE;
                                                  End;

      P2P_RPL_ACCEPTFRIEND : Begin
                               tiMyDetailsUpdate.Interval := 2000;
                               tiMyDetailsUpdate.Enabled := FALSE;
                               tiMyDetailsUpdate.Enabled := TRUE;

                               ComponentModuleWindow.GProxy.Command(Format('f add %s', [params]));
                               
                               AddLineToChatTab(cntChat.ActivePage, RS_SERVER_INFO, Format(RS_FRIEND_ACCEPTED, [params]), STYLE_BOT_SND, STYLE_BOT_MSG);
                             End;

      P2P_RPL_REMOVEFRIEND : Begin
                               uid := FindUser(params);
                               If uid <> -1 Then
                               Begin
                                 Users.Items[uid].IsFriend_PVPGN := FALSE;
                                 Users.Items[uid].IsFriend_Site := FALSE;
                               End;
                               ComponentModuleWindow.GProxy.Command(Format('f del %s', [params]));

                               AddLineToChatTab(cntChat.ActivePage, RS_SERVER_INFO, Format(RS_FRIEND_REMOVED, [params]), STYLE_BOT_SND, STYLE_BOT_MSG);
                             End;
      P2P_RPL_DECLINEFRIEND : Begin
                               AddLineToChatTab(cntChat.ActivePage, RS_SERVER_INFO, Format(RS_FRIEND_DECLINED, [params]), STYLE_BOT_SND, STYLE_BOT_MSG);
                              End;
    End;
  End;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: OnWhisper() :: END');  {$ENDIF}
end;

procedure TMainWindow.btGameStartClick(Sender: TObject);
var
  hWC3     : THandle;
  params   : TStringList;
  sparams  : String;
  executed : Boolean;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: btGameStartClick() :: BEGIN');  {$ENDIF}

  hWC3 := FindWindow(nil, 'Warcraft III');

  If hWC3 = 0 Then
  Begin
    If not IsLatestVersion Then
    Begin
      Application.CreateForm(TGameRepairWindow, GameRepairWindow);
      GameRepairWindow.Hashes := GetGameHashes;
      GameRepairWindow.StartAutomatically := TRUE;
      GameRepairWindow.CloseAutomatically := TRUE;
      GameRepairWindow.ShowModal;
    End;

    If IsLatestVersion Then
    Begin
      If not IsValidWC3Path Then
      Begin
        executed := AskForWC3Path;
        If executed Then
          btGameStartClick(Sender);
      End
      else
      Begin
        params := TStringList.Create;
        If Options.WC3.Windowed Then
          params.Add('-window');
        If Options.WC3.OpenGL Then
          params.Add('-opengl');

        sparams := '';
        While params.Count > 0 Do
        Begin
          sparams := sparams + params[0] + ' ';
          params.Delete(0);
        End;
        sparams := Trim(sparams);

        ExecuteFile(Options.WC3.Exe, Format('"%s" %s', [Options.WC3.Exe, sparams]), Format('%s', [Options.WC3.Path]), 0, SW_SHOW, WarProcessInfo);
        If Options.Client.GameAutoMinimize Then
        Begin
          Close;
          tiGameAutoMinimize.Enabled := TRUE;
        End;
        WaitForSingleObject(WarProcessInfo.hProcess, 1000);

        If (Options.WC3.Windowed) and
           (Options.WC3.Maximize) Then
        Begin
          hWC3 := FindWindow(nil, 'Warcraft III');
          SendMessage(hWC3, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
        End;
      End;
    End;
  End
  else
    ShowWindow(hWC3, SW_RESTORE);

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: btGameStartClick() :: END');  {$ENDIF}
end;

procedure TMainWindow.cntChatAfterClose(Sender: TObject);
begin
  If AfterCloseIndex >= cntChat.PageCount Then
    AfterCloseIndex := cntChat.PageCount - 1;
  If AfterCloseIndex < 0 Then
    AfterCloseIndex := 0;

  cntChat.ActivePageIndex := AfterCloseIndex;
end;

procedure TMainWindow.smTutorialClick(Sender: TObject);
begin
  Application.CreateForm(TTutorialWindow, TutorialWindow);
  TutorialWindow.ShowModal;
  TutorialWindow := nil;
end;

procedure TMainWindow.EnableHostSettings(const AEnable : Boolean);
begin
  cbGameType.Enabled := AEnable;
  cbGameMode.Enabled := AEnable;
  ebChallengeFee.Enabled := AEnable;
  ebPassword.Enabled := AEnable;
  chbGameObs.Enabled := AEnable;
  lbGameDefaultSettings.Enabled := AEnable;
end;

procedure TMainWindow.SetCriteria(const ARoomNumber, AGameType, AModeType, ARating, ATeamID, ADisc, AChallenge, ARegion, ACountry : Integer; const APassword : String = '~~');
var
  params : String;
  pass   : String;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: SetCriteria() :: BEGIN');  {$ENDIF}

  If APassword = '' Then
    pass := '~~'
  else
    pass := APassword;

  params := Format('%d %d %d %d %d %d %d %d %d %d %s', [ARoomNumber, AGameType, AModeType, ARating, ARating, ATeamID, ADisc, AChallenge, ARegion, ACountry, pass]);
  ComponentModuleWindow.GProxy.Send(Trim(Format('criteria %s', [params])));

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: SetCriteria() :: END');  {$ENDIF}
end;

procedure TMainWindow.HostGame(const ARoomNumber, AGameType, AModeType, AMinRating, AMaxRating, ATeamId, ADiscLimit, AChallenge, ARegion, ACountry : Integer; const AGameName, APassword : String; AObservers : Boolean);
var
  pass : String;
  ch   : String;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: HostGame() :: BEGIN');  {$ENDIF}

  If APassword = '' Then
    pass := '~~'
  else
    pass := APassword;

  HideBotWhispers;

  If AObservers Then
    ComponentModuleWindow.GProxy.Whisper('psi', '.mapo dota')
  else
    ComponentModuleWindow.GProxy.Whisper('psi', '.map dota');

  ch := ComponentModuleWindow.GProxy.CurrentChannel;

  SetCriteria(0, AGameType, AModeType, Users.Items[0].Stats.Rating, 0, ADiscLimit, AChallenge, ARegion, ACountry, pass);

  ComponentModuleWindow.GProxy.Whisper('psi', Trim(Format('.puc %d %d %d %d %d %d %d %d %d %d %s %d %s %s', [ARoomNumber, AGameType, AModeType, AMinRating, AMaxRating, ATeamId, ADiscLimit, AChallenge, ARegion, ACountry, pass, Length(ch), ch, AGameName])));

  ShowBotWhispers;

  EnableHostSettings(FALSE);

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: HostGame() :: END');  {$ENDIF}
end;

function TMainWindow.GetDisconnectPercent(const AUserID : Integer) : Integer;
begin
  If (Users.Items[AUserID].Stats.Wins + Users.Items[0].Stats.Losses) = 0 Then
    result := 0
  else
    result := Trunc((Users.Items[0].Stats.LeaveCount / (Users.Items[0].Stats.LeaveCount + Users.Items[0].Stats.Wins + Users.Items[0].Stats.Losses)) * 100);
end;

procedure TMainWindow.UnhostGame;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: UnostGame() :: BEGIN');  {$ENDIF}

  HideBotWhispers;
  ComponentModuleWindow.GProxy.Whisper('psi', '.unhost');
  SetCriteria(0, 0, 0, Users.Items[0].Stats.Rating, 0, GetDisconnectPercent(0), 0, 0, 0);
  ShowBotWhispers;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: UnostGame() :: END');  {$ENDIF}
end;

procedure TMainWindow.btGameHostClick(Sender: TObject);
var
  valChallenge : Integer;
  gameType     : Integer;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: btGameHostClick() :: BEGIN');  {$ENDIF}

  If btGameHost.Enabled Then
    If not GameHosted Then
    Begin
      btGameHost.Caption := RS_HOSTING_GAME;
      btGameHost.Enabled := FALSE;
      SetGameHostCaption(RS_HOSTING_GAME);

      TempGameName := Format('%s.%s | %s', [UserDetails.Country, cbGameMode.Text, UserDetails.Username]);

      valChallenge := 0;
      If cbGameType.ItemIndex = 2 Then
      Begin
        valChallenge := Trunc(ebChallengeFee.Value);
        TempGameName := Format('%s [%d]', [TempGameName, valChallenge]);
      End;

      gameType := cbGameType.ItemIndex;
      If cbGameType.ItemIndex = 2 Then
        gameType := 3;

      HostGame(0, gameType, cbGameMode.ItemIndex, GetMinRating(Users.Items[0].Stats.Rating), GetMaxRating(Users.Items[0].Stats.Rating), 0, 0, valChallenge, 0, 0, TempGameName, ebPassword.Text, chbGameObs.Checked);
      tiHostTimeout.Enabled := FALSE;
      tiHostTimeout.Enabled := TRUE;
    End
    else
    Begin
      btGameHost.Caption := RS_UNHOSTING_GAME;
      SetGameHostCaption(RS_UNHOSTING_GAME);

      btGameHost.Enabled := FALSE;
      UnhostGame;
    End;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: btGameHostClick() :: END');  {$ENDIF}
end;

procedure TMainWindow.OnNonCommand(ASender : TGProxy; const APrefix, ALine : WideString);
var
  errString : String;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: OnNonCommand() :: BEGIN');  {$ENDIF}

  If APrefix = 'ERROR' Then
  Begin
    errString := ALine;
    If errString = 'Unknown command.' Then
      errString := RS_ERROR_UNKNOWN_COMMAND;
    If errString = 'That user is not logged on.' Then
      errString := RS_ERROR_USER_NOT_LOGGED;

    AddLineToChatTab(cntChat.ActivePage, RS_SERVER_ERROR, errString, STYLE_ERROR_SND, STYLE_ERROR_MSG);

    PSoundWrapper(Options.Sounds.ErrorMessage);
  End;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: OnNonCommand() :: END');  {$ENDIF}
end;

procedure TMainWindow.lbUsersClick(Sender: TObject);
var
  lb       : TspSkinOfficeListBox;
  item     : TCollectionItem;
  uid      : Integer;
  userinfo : TUserInfo;
begin
  lb := GetChatTabUserList(cntChat.ActivePage);
  If Assigned(lb) Then
  Begin
    item := lb.Items.FindItemID(SelectedUser);
    If Assigned(item) Then
    Begin
      If (UserDetails.Username <> TspSkinOfficeItem(item).Title) and
         (GetTickCount - LastP2PAction > 1000) Then
      Begin
        LastP2PAction := GetTickCount;
        P2P_RequestUserStats(UserDetails.Username, TspSkinOfficeItem(item).Title);
      End;

      uid := FindUser(TspSkinOfficeItem(item).Title);
      If uid = -1 Then
      Begin
        ZeroMemory(@userinfo, SizeOf(TUserInfo));
        userinfo.Username := TspSkinOfficeItem(item).Title;
        AddUserToList(userinfo);
        uid := FindUser(userinfo.Username);
      End;

      ShowUserStats(uid);
    End;
  End;
end;

procedure TMainWindow.lbGameDefaultSettingsClick(Sender: TObject);
begin
  cbGameType.ItemIndex := 1;
  cbGameMode.ItemIndex := 1;
  ebPassword.Clear;
  chbGameObs.Checked := FALSE;

  tiSendCriteria.Enabled := TRUE;
end;

procedure TMainWindow.imgUserInfoBannerClick(Sender: TObject);
begin
  BrowseURL(ClientSettings.UserBanner.Link);
end;

procedure TMainWindow.imgMainBannerClick(Sender: TObject);
begin
  BrowseURL(ClientSettings.MainBanner.Link);
end;

procedure TMainWindow.btCloseChatClick(Sender: TObject);
begin
  cntChat.DoClose;
end;


procedure TMainWindow.tiHostTimeoutTimer(Sender: TObject);
begin
  GameHosted := FALSE;
  btGameHost.Caption := RS_GAME_HOST;
  btGameHost.Enabled := TRUE;
  tiHostTimeout.Enabled := FALSE;
  EnableHostSettings(TRUE);

  SetGameHostCaption(RS_UNABLE_TO_HOST_GAME, clRed)
end;

procedure TMainWindow.sgGameListDrawCell(Sender: TObject; ACol, ARow: Integer; ARect: TRect; State: TGridDrawState);
var
  C1       : Integer;
  index    : Integer;
  rectFlag : TRect;
begin                          
  If GameList.Count > 0 Then
    If ACol = 2 Then
    Begin
      index := 0;
      For C1 := 0 to GameList.Count - 1 Do
        If Trim(GameList.Items[C1].Host) = Trim(sgGameList.Cells[ACol, ARow]) Then
        Begin
          index := GameList.Items[C1].FlagIndex;
          Break;
        End;

      rectFlag.Left := ARect.Left + 5;
      rectFlag.Top := ARect.Top + (ARect.Bottom - ARect.Top) div 2 - ComponentModuleWindow.ilFlags.PngImages[index].PngImage.Height div 2 + 2;
      rectFlag.Right := rectFlag.Left + ComponentModuleWindow.ilFlags.PngImages[index].PngImage.Width;
      rectFlag.Bottom := rectFlag.Top + ComponentModuleWindow.ilFlags.PngImages[index].PngImage.Height - 3;

      sgGameList.Canvas.CopyRect(rectFlag,
                                 ComponentModuleWindow.ilFlags.PngImages[index].PngImage.Canvas,
                                 Classes.Rect(0, 1, ComponentModuleWindow.ilFlags.PngImages[index].PngImage.Width, ComponentModuleWindow.ilFlags.PngImages[index].PngImage.Height - 3));

      If Pos('       ', sgGameList.Cells[ACol, ARow]) <> 1 Then
        sgGameList.Cells[ACol, ARow] := '       ' + sgGameList.Cells[ACol, ARow];
    End;
end;

procedure TMainWindow.sbGameListChange(Sender: TObject);
begin
  sgGameList.TopRow := sbGameList.Position;
end;

procedure TMainWindow.sgGameListSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  If sgGameList.TopRow > sbGameList.Max Then
    sbGameList.Position := sbGameList.Max
  else
    sbGameList.Position := sgGameList.TopRow;
end;

procedure TMainWindow.smKickClick(Sender: TObject);
var
  lb   : TspSkinOfficeListBox;
  item : TCollectionItem;
begin
  lb := GetChatTabUserList(cntChat.ActivePage);
  If Assigned(lb) Then
  Begin
    item := lb.Items.FindItemID(SelectedUser);
    If (Assigned(item)) and
       (TspSkinOfficeItem(item).Title <> UserDetails.Username) Then
      ComponentModuleWindow.GProxy.Command(Format('kick %s', [TspSkinOfficeItem(item).Title]));
  End;
end;

procedure TMainWindow.GameListSwap(const ARow1, ARow2 : Integer);
var
  row : TStrings;
begin
  row := TStringList.Create;
  row.Assign(sgGameList.Rows[ARow1]);
  sgGameList.Rows[ARow1].Assign(sgGameList.Rows[ARow2]);
  sgGameList.Rows[ARow2].Assign(row);
  row.Free;
end;

procedure TMainWindow.SortGameList(const AColumn : Integer; const AAscending : Boolean);
var
  C1, C2 : Integer;
begin
  GameListSortColumn := AColumn;
  GameListSortAscending := AAscending;

  For C1 := 0 to sgGameList.RowCount - 2 Do
    For C2 := C1 + 1 to sgGameList.RowCount - 1 Do
      If GameListSortAscending Then
      Begin
        If sgGameList.Cells[GameListSortColumn, C2] < sgGameList.Cells[GameListSortColumn, C1] Then
          GameListSwap(C1, C2);
      End
      else
        If sgGameList.Cells[GameListSortColumn, C2] > sgGameList.Cells[GameListSortColumn, C1] Then
          GameListSwap(C1, C2);
end;

procedure TMainWindow.ShowSortButton(const AImage : TspPngImageView; const AIndex : Integer);
begin
  imgSortStatus.Visible := FALSE;
  imgSortType.Visible := FALSE;
  imgSortHost.Visible := FALSE;
  imgSortSlots.Visible := FALSE;
  imgSortMode.Visible := FALSE;

  AImage.ImageIndex := AIndex;
  AImage.Visible := TRUE;
end;

procedure TMainWindow.lbGamesStatusClick(Sender: TObject);
begin
  SortGameList(0, lbGamesStatus.Tag = 1);
  ShowSortButton(imgSortStatus, lbGamesStatus.Tag);
  lbGamesStatus.Tag := Abs(lbGamesStatus.Tag - 1);
end;

procedure TMainWindow.lbGamesTypeClick(Sender: TObject);
begin
  SortGameList(1, lbGamesType.Tag = 1);
  ShowSortButton(imgSortType, lbGamesType.Tag);
  lbGamesType.Tag := Abs(lbGamesType.Tag - 1);
end;

procedure TMainWindow.lbGamesHostClick(Sender: TObject);
begin
  SortGameList(2, lbGamesHost.Tag = 1);
  ShowSortButton(imgSortHost, lbGamesHost.Tag);
  lbGamesHost.Tag := Abs(lbGamesHost.Tag - 1);
end;

procedure TMainWindow.lbGamesSlotsClick(Sender: TObject);
begin
  SortGameList(3, lbGamesSlots.Tag = 1);
  ShowSortButton(imgSortSlots, lbGamesSlots.Tag);
  lbGamesSlots.Tag := Abs(lbGamesSlots.Tag - 1);
end;

procedure TMainWindow.lbGamesModeClick(Sender: TObject);
begin
  SortGameList(4, lbGamesMode.Tag = 1);
  ShowSortButton(imgSortMode, lbGamesMode.Tag);
  lbGamesMode.Tag := Abs(lbGamesMode.Tag - 1);
end;

procedure TMainWindow.ebSearchGamesChange(Sender: TObject);
var
  C1   : Integer;
  text : WideString;
begin
  If TspSkinEdit(Sender).Text <> '' Then
  Begin
    text := '*' + TspSkinEdit(Sender).Text + '*';
    For C1 := 0 to sgGameList.RowCount - 1 Do
      If MatchStrings(text, sgGameList.Cells[2, C1], FALSE) Then
      Begin
        sgGameList.Row := C1;
        Break;
      End;
  End;
end;

procedure TMainWindow.ebSearchGamesExit(Sender: TObject);
begin
  TspSkinEdit(Sender).Text := RS_SEARCH_GAMES;
end;

procedure TMainWindow.tiMaphackodeTimer(Sender: TObject);
begin
  SendMaphackCode;
end;

procedure TMainWindow.lboxFriendsKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  SelectedUser := TspSkinOfficeListBox(Sender).Items[TspSkinOfficeListBox(Sender).ItemIndex].ID;
end;

procedure TMainWindow.lboxFriendsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  itemindex : Integer;
begin
  Case Button of
    mbRight, mbLeft : Begin
                        If TspSkinOfficeListBox(Sender).ItemAtPos(X, Y) = -1 Then
                          SelectedFriend := -1
                        else
                        Begin
                          itemindex := TspSkinOfficeListBox(Sender).ItemAtPos(X, Y);
                          TspSkinOfficeListBox(Sender).ItemIndex := itemindex;
                          SelectedFriend := TspSkinOfficeListBox(Sender).Items[itemindex].ID;
                        End;

                        If Button = mbRight Then
                          lboxFriends.OnClick(Sender);
                      End;
  End;
end;

procedure TMainWindow.setUserStatsHints;
begin
  Case btUserFriends.ImageIndex of
    1 : btUserFriends.Hint := RS_REMOVE_FROM_FRIENDS;
    0 : btUserFriends.Hint := RS_ADD_TO_FRIENDS;
  End;

  Case btUserBlock.ImageIndex of
    3 : btUserBlock.Hint := RS_BLOCK_USER;
    7 : btUserBlock.Hint := RS_UNBLOCK_USER;
  End;
end;

procedure TMainWindow.ShowUserStats(const AUserID : Integer);
var
  totalGames : Integer;
  index      : Integer;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: ShowUserStats() :: BEGIN');  {$ENDIF}

  ShowBanner;
  If (AUserID >= 0) and
     (AUserID < Users.Count) Then
  Begin
    paUserInfo.Show;

    paUserInfo.Tag := AUserID;
    lbUserInfoPersonalRank.Caption := Format('%d', [Users.Items[AUserID].Stats.Rank]);
    lbUserInfoPersonalPoints.Caption := Format('%d', [Users.Items[AUserID].Stats.RatingPro]);
    lbUserInfoPersonalRating.Caption := Format('%d', [Users.Items[AUserID].Stats.Rating]);;

    totalGames := Users.Items[AUserID].Stats.Wins + Users.Items[AUserID].Stats.Losses + Users.Items[AUserID].Stats.LeaveCount;
    If totalGames > 0 Then
    Begin
      lbUserInfoPersonalWins.Caption := Format('%d (%f%%)', [Users.Items[AUserID].Stats.Wins, (Users.Items[AUserID].Stats.Wins * 100) / totalGames]);;
      lbUserInfoPersonalLosses.Caption := Format('%d (%f%%)', [Users.Items[AUserID].Stats.Losses, (Users.Items[AUserID].Stats.Losses * 100) / totalGames]);;
      lbUserInfoPersonalLeaves.Caption := Format('%d (%f%%)', [Users.Items[AUserID].Stats.LeaveCount, (Users.Items[AUserID].Stats.LeaveCount * 100) / totalGames]);;
    End
    else
    Begin
      lbUserInfoPersonalWins.Caption := Format('%d (%f%%)', [0, 0.0]);;
      lbUserInfoPersonalLosses.Caption := Format('%d (%f%%)', [0, 0.0]);;
      lbUserInfoPersonalLeaves.Caption := Format('%d (%f%%)', [0, 0.0]);;
    End;

    imgUserInfoStatus.ImageIndex := GetUserStatusIndexFromArea(Users.Items[AUserID].Area);

    btUserFriends.ImageIndex := 0;
    btUserFriends.Enabled := FALSE;
    btUserChat.Enabled := FALSE;
    btUserBlock.ImageIndex := 3;
    btUserBlock.Enabled := FALSE;

    If not Users.Items[AUserID].IsMyself Then
    Begin
      btUserFriends.Enabled := TRUE;
      btUserChat.Enabled := TRUE;
      btUserBlock.Enabled := TRUE;
    End;

    If (Users.Items[AUserID].IsFriend_Site) or
       (Users.Items[AUserID].IsFriend_PVPGN) Then
      btUserFriends.ImageIndex := 1;

    If Blocklist.Find(Users.Items[AUserID].Username, index) Then
      btUserBlock.ImageIndex := 7;

    setUserStatsHints;

    imgUserInfoStatus.Visible := TRUE;
    imgUserNickVertStatusDiv.Visible := TRUE;
    lbUserInfoTitle.Visible := TRUE;
    lbUserInfoUsername.Visible := TRUE;
    SetUserTitle(Users.Items[AUserID].Stats.Title, Users.Items[AUserID].Username);

    SetUserInfoAvatar(AUserID);

    tiUserStatsHide.Interval := 60000;
    tiUserStatsHide.Enabled := FALSE;
    tiUserStatsHide.Enabled := TRUE;
  End;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: ShowUserStats() :: END');  {$ENDIF}
end;

procedure TMainWindow.SetUserInfoAvatar(const AUserID : Integer);
var
  memStream  : TMemoryStream;
  imageen    : TImageEn;
  iid        : Integer;
  img        : TspPngImageItem;
begin
  iid := Users.Avatar[AUserID].ID145;
  If iid = -1 Then
    iid := 0;

  ilUserAvatar.PngImages.Clear;
  ilUserAvatar.PngWidth := imgUserInfoAvatar.Width;
  ilUserAvatar.PngHeight := imgUserInfoAvatar.Height;

  memStream := TMemoryStream.Create;
  imageen := TImageEn.Create(nil);
  ilAvatars145.PngImages[iid].PngImage.SaveToStream(memStream);
  memStream.Position := 0;
  imageen.IO.LoadFromStream(memStream);
  imageen.Proc.Resample(ilUserAvatar.PngWidth, ilUserAvatar.PngHeight, rfLanczos3);
  memStream.Position := 0;
  imageen.IO.SaveToStreamPNG(memStream);
  imageen.Free;

  img := TspPngImageItem(ilUserAvatar.PngImages.Add);
  memStream.Position := 0;
  img.PngImage.LoadFromStream(memStream);
  memStream.Free;

  imgUserInfoAvatar.ImageIndex := img.Index;
  imgUserInfoAvatar.Tag := Users.Avatar[AUserID].ID145;

  imgUserInfoAvatar.Flag := ComponentModuleWindow.ilFlags;
  imgUserInfoAvatar.FlagIndex := ComponentModuleWindow.FindCountryImage(Users.Items[AUserID].Country);
  imgUserInfoAvatar.DrawFlag := TRUE;
end;

procedure TMainWindow.lboxFriendsClick(Sender: TObject);
var
  item : TCollectionItem;
  uid  : Integer;
begin
  item := lboxFriends.Items.FindItemID(SelectedFriend);
  If Assigned(item) Then
  Begin
    uid := FindUser(TspSkinOfficeItem(item).Title);
    If uid <> -1 Then
      ShowUserStats(uid);
  End;
end;

function TMainWindow.OpenPVPGNUserChat(const AUser : WideString; const AFocus : Boolean) : TTabSheet;
var
  ebox : TspSkinEdit;
  ct   : TTabSheet;
begin
  ct := CreateChatTab(AUser, ctPVPGN_User);
  If Assigned(ct) Then
  Begin
    ebox := GetChatTabEdit(ct, 3);
    If Assigned(ebox) Then
      ebox.Text := Format(RS_CHAT_SESSION_HEADER, [AUser, DateToStr(Now), TimeToStr(Now)]);

    If AFocus Then
    Begin
      cntChat.ActivePageIndex := ct.TabIndex;
      cntChat.OnChange(ct);
    End;
  End;
  result := ct;
end;

procedure TMainWindow.smFChatClick(Sender: TObject);
var
  item : TCollectionItem;
begin
  item := lboxFriends.Items.FindItemID(SelectedFriend);
  If Assigned(item) Then
    OpenPVPGNUserChat(TspSkinOfficeItem(item).Title, TRUE);
end;

procedure TMainWindow.lboxFriendsDblClick(Sender: TObject);
begin
  smFChat.Click;
end;

procedure TMainWindow.smFPingClick(Sender: TObject);
var
  item : TCollectionItem;
begin
  item := lboxFriends.Items.FindItemID(SelectedFriend);
  If Assigned(item) Then
    ComponentModuleWindow.GProxy.Command(Format('ping %s', [TspSkinOfficeItem(item).Title]));
end;

procedure TMainWindow.smFWhereisClick(Sender: TObject);
var
  item : TCollectionItem;
begin
  item := lboxFriends.Items.FindItemID(SelectedFriend);
  If Assigned(item) Then
    ComponentModuleWindow.GProxy.Command(Format('whereis %s', [TspSkinOfficeItem(item).Title]));
end;

procedure TMainWindow.btMyStatisticsClick(Sender: TObject);
begin
  ShowUserStats(0);
end;

procedure TMainWindow.btUserChatClick(Sender: TObject);
begin
  If paUserInfo.Tag > 0 Then
    OpenPVPGNUserChat(Users.Items[paUserInfo.Tag].Username, TRUE);
end;

procedure TMainWindow.cntChatMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Case Button of
    mbLeft : If (GetTickCount - LastTabClick < 200) and
                (cntChat.ActivePage.TabIndex = LastTabClickIndex) Then
               cntChat.DoClose
             else
             Begin
               LastTabClick := GetTickCount;
               LastTabClickIndex := cntChat.ActivePage.TabIndex;
             End;
  End;
end;

procedure TMainWindow.appEventsShortCut(var Msg: TWMKey; var Handled: Boolean);
var
  ebox : TspSkinEdit;
  lbox : TspSkinOfficeListBox;
  res  : Integer;
begin
  If Screen.ActiveForm = MainWindow Then
  Begin
    ebox := GetChatTabEdit(cntChat.ActivePage, 1);
    lbox := GetChatTabUserList(cntChat.ActivePage);
    If (msg.Charcode = VK_TAB) and
       (Assigned(ebox)) and
       (MainWindow.ActiveControl = ebox) and
       (Assigned(lbox)) Then
    Begin
      If ebox.Text <> '' Then
      Begin
        res := FindUserInList(lbox, ebox.Text + '*');
        If res <> -1 Then
        Begin
          ebox.Text := Format('%s: ', [lbox.Items[res].Title]);
          ebox.SelStart := Length(ebox.Text);
        End;
      End;
      Handled := TRUE;
    End;

    If (Msg.CharCode = Ord('W')) and
       (GetKeyState(VK_CONTROL) < 0) Then
    Begin
      cntChat.DoClose;
      Handled := TRUE;
    End;
  End;
end;

procedure TMainWindow.smCommandsClick(Sender: TObject);
begin
  Application.CreateForm(TCommandsWindow, CommandsWindow);
  CommandsWindow.ShowModal;
  CommandsWindow := nil;
end;

function TMainWindow.GetUserInfo(const AUsername : String; var AUserInfo : TUserInfo) : Boolean;
var
  C1 : Integer;
begin
  result := FALSE;
  For C1 := 0 to Users.Count - 1 Do
    If Users.Items[C1].Username = AUsername Then
    Begin
      AUserInfo := Users.Items[C1];
      result := TRUE;
      Break;
    End;
end;

procedure TMainWindow.tiUserStatsHideTimer(Sender: TObject);
begin
  ShowBanner;
end;

procedure TMainWindow.SetFriendItem(const AListboxIndex : Integer; const AUserID : Integer);
begin
  lboxFriends.Items[AListboxIndex].Title := Users.Items[AUserID].Username;

  If Users.Items[AUserID].Stats.Title <> '' Then
    lboxFriends.Items[AListboxIndex].Caption := Users.Items[AUserID].Stats.Title
  else
    lboxFriends.Items[AListboxIndex].Caption := ' ';

  lboxFriends.Items[AListboxIndex].FlagIndex := -1;
  lboxFriends.Items[AListboxIndex].StatusIndex := GetUserStatusIndexFromArea(Users.Items[AUserID].Area);
  If Users.Avatar[AUserID].ID35 = -1 Then
    lboxFriends.Items[AListboxIndex].ImageIndex := 0
  else
    lboxFriends.Items[AListboxIndex].ImageIndex := Users.Avatar[AUserID].ID35;
  lboxFriends.Items[AListboxIndex].TitleColor := clWhite;
  lboxFriends.Items[AListboxIndex].TextColor := clGray;

  lboxFriends.Items[AListboxIndex].Grayed := not (Users.Items[AUserID].Area in [1, 2]);
  lboxFriends.Items[AListboxIndex].Enabled := TRUE;
end;

procedure TMainWindow.RefreshFriendList;
var
  C1, C2 : Integer;
  exists : Boolean;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: RefreshFriendList() :: BEGIN');  {$ENDIF}

  lboxFriends.BeginUpdateItems;

  C1 := 0;
  While C1 < lboxFriends.Items.Count Do
  Begin
    exists := FALSE;
    For C2 := 0 to Users.Count - 1 Do
      If ((Users.Items[C2].IsFriend_PVPGN) or
          (Users.Items[C2].IsFriend_Site)) and
         (Users.Items[C2].Username = lboxFriends.Items[C1].Title) Then
      Begin
        exists := TRUE;
        SetFriendItem(C1, C2);
        Break;
      End;

    If not exists Then
      lboxFriends.Items.Delete(C1)
    else
      Inc(C1);
  End;

  For C1 := 0 to Users.Count - 1 Do
    If (Users.Items[C1].IsFriend_Site) or
       (Users.Items[C1].IsFriend_PVPGN) Then
    Begin
      exists := FALSE;

      For C2 := 0 to lboxFriends.Items.Count - 1 Do
        If C2 < lboxFriends.Items.Count Then
          If Users.Items[C1].Username = lboxFriends.Items[C2].Title Then
          Begin
            exists := TRUE;
            Break;
          End;

      If not exists Then
        SetFriendItem(lboxFriends.Items.Add.Index, C1);
    End;
  lboxFriends.EndUpdateItems;

  SortFriendList;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: RefreshFriendList() :: END');  {$ENDIF}
end;

function TMainWindow.SetUserInfo_Area(const AUsername : String; const AArea : Integer) : Boolean;
var
  C1 : Integer;
begin
  result := FALSE;
  For C1 := 0 to Users.Count - 1 Do
    If Users.Items[C1].Username = AUsername Then
    Begin
      Users.Items[C1].Area := AArea;
      result := TRUE;
      Break;
    End;
end;

procedure TMainWindow.AddUserToPostQueue(const AStringList : TStringList; const AUsername : String);
begin
  AStringList.Add(AUsername);
end;

procedure TMainWindow.PostUserQueue;
var
  postparams : String;
  C1         : Integer;
begin
  If (UsernameQueue.Count > 0) and
     (httpUserData.State = httpReady) Then
  Begin
    postparams := Format('key=%s&usernames=', [UserDetails.Key]);
    For C1 := 0 to UsernameQueue.Count - 1 Do
      postparams := postparams + UsernameQueue.Strings[C1] + ',';
    UsernameQueue.Clear;
    Delete(postparams, Length(postparams), 1);

    httpPostRequest(httpUserData, URL_API + 'getUsersStatistics', postparams);
  End;
end;

procedure TMainWindow.httpUserDataRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  JSON     : ISuperObject;
  JSTMP    : ISuperObject;
  response : WideString;
  jsitem   : TSuperObjectIter;
  userinfo : TUserInfo;
  respType : Char;
  respCode : Integer;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: httpUserDataRequestDone() :: BEGIN');  {$ENDIF}

  If ErrCode <> 0 Then
  else
  Begin
    If THTTPCli(Sender).StatusCode <> 200 Then
    else
      If THTTPCli(Sender).RcvdCount > 0 Then
      Begin
        THTTPCli(Sender).RcvdStream.Position := 0;
        JSON := TSuperObject.ParseStream(THTTPCli(Sender).RcvdStream, FALSE);
        response := JSON.S['result'];

        If not ParseResponse(response, respType, respCode) Then
        Begin
          JSON := TSuperObject.ParseString(Addr(response[1]), FALSE);

          If ObjectFindFirst(JSON, jsitem) Then
          Begin
            repeat
              userinfo.Username := jsitem.key;
              userinfo.Area := 2;
              userinfo.Country := jsitem.val.S['country'];
              userinfo.Avatar := jsitem.val.S['avatar'];
              userinfo.Coins := jsitem.val.I['coins'];
              userinfo.IsFriend_Site := FALSE;
              userinfo.IsFriend_PVPGN := FALSE;
              userinfo.IsMyself := FALSE;
              userinfo.Color := JSTMP.B['colour'];

              JSTMP := TSuperObject.ParseString(Addr(jsitem.val.S['date'][1]), FALSE);
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

              AddUserToList(userinfo);
              cache_PutUser(userinfo);
            until not ObjectFindNext(jsitem);
            ObjectFindClose(jsitem);
          End;

          RefreshFriendList;
          SetMyTitle(Users.Items[0].Stats.Title);
          ShowMyStats;

          tiAvatarsRefresh.OnTimer(httpUserData);
        End;

        JSON := nil;
      End;
  End;

  httpFree(httpUserData);

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: httpUserDataRequestDone() :: END');  {$ENDIF}
end;

procedure TMainWindow.smAddToFriendsClick(Sender: TObject);
var
  lb   : TspSkinOfficeListBox;
  item : TCollectionItem;
begin
  lb := GetChatTabUserList(cntChat.ActivePage);
  If Assigned(lb) Then
  Begin
    item := lb.Items.FindItemID(SelectedUser);
    If Assigned(item) Then
    Begin
      If smAddToFriends.Caption = RS_ADD_TO_FRIENDS Then
        AddToFriends(TspSkinOfficeItem(item).Title)
      else
        If smAddToFriends.Caption = RS_REMOVE_FROM_FRIENDS Then
          RemoveFromFriends(TspSkinOfficeItem(item).Title);
    End;
  End;
end;

procedure TMainWindow.smFRemoveFromFriendsClick(Sender: TObject);
var
  item : TCollectionItem;
begin
  item := lboxFriends.Items.FindItemID(SelectedFriend);
  If Assigned(item) Then
    RemoveFromFriends(TspSkinOfficeItem(item).Title);
end;

procedure TMainWindow.AddToFriends(const AUsername : String);
begin
  httpPostRequest(httpFriendAPI, URL_API + 'friends/add', Format('key=%s&to=%s', [UserDetails.Key, AUsername]));
  
  P2P_RequestRefreshStats(UserDetails.Username, AUsername);
end;

procedure TMainWindow.ConfirmFriend(const AReqID, AUsername : String);
begin
  ComponentModuleWindow.GProxy.Command(Format('f add %s', [AUsername]));
  httpPostRequest(httpFriendAPI, URL_API + 'friends/confirmadd', Format('key=%s&to=%s&reqid=%s', [UserDetails.Key, AUsername, AReqID]));

  P2P_AcceptFriendship(UserDetails.Username, AUsername);
end;

procedure TMainWindow.DeclineFriend(const AReqID, AUsername : String);
begin
  httpPostRequest(httpFriendAPI, URL_API + 'friends/declinerequest', Format('key=%s&reqid=%s', [UserDetails.Key, AReqID]));

  If AUsername <> '' Then
    P2P_DeclineFriendship(UserDetails.Username, AUsername);
end;

procedure TMainWindow.RemoveFromFriends(const AUsername : String);
var
  uid : Integer;
begin
  ComponentModuleWindow.GProxy.Command(Format('f del %s', [AUsername]));
  httpPostRequest(httpFriendAPI, URL_API + 'friends/delete', Format('key=%s&second=%s', [UserDetails.Key, AUsername]));

  uid := FindUser(AUsername);
  If uid <> -1 Then
  Begin
    Users.Items[uid].IsFriend_PVPGN := FALSE;
    Users.Items[uid].IsFriend_Site := FALSE;
    If Users.Items[uid].Area > 0 Then
      P2P_RemoveFriendship(UserDetails.Username, AUsername);
  End;
end;

procedure TMainWindow.SwapLboxFriends(const AIndex1, AIndex2 : Integer);
var
  C1, u1, u2 : Integer;
begin
  u1 := -1;
  For C1 := 0 to Users.Count - 1 Do
    If Users.Items[C1].Username = lboxFriends.Items[AIndex1].Title Then
    Begin
      u1 := C1;
      Break;
    End;

  If u1 <> -1 Then
  Begin
    u2 := -1;
    For C1 := 0 to Users.Count - 1 Do
      If Users.Items[C1].Username = lboxFriends.Items[AIndex2].Title Then
      Begin
        u2 := C1;
        Break;
      End;

    If u2 <> -1 Then
    Begin
      SetFriendItem(AIndex1, u2);
      SetFriendItem(AIndex2, u1);
    End;
  End;
end;

procedure TMainWindow.SortFriendList;
var
  C1, C2 : Integer;
begin
  lboxFriends.BeginUpdateItems;
  For C1 := 0 to lboxFriends.Items.Count - 2 Do
    For C2 := C1 + 1 to lboxFriends.Items.Count - 1 Do
      If lboxFriends.Items[C1].StatusIndex < lboxFriends.Items[C2].StatusIndex Then
        SwapLboxFriends(C1, C2);
  lboxFriends.EndUpdateItems;
end;

procedure TMainWindow.ShowMyStats;
var
  C1 : Integer;
begin
  lbPlayerStatRank.Caption := IntToStr(Users.Items[0].Stats.Rank);
  lbPlayerStatPoints.Caption := IntToStr(Users.Items[0].Stats.RatingPro);
  lbPlayerStatRating.Caption := IntToStr(Users.Items[0].Stats.Rating);
  lbPlayerStatCoins.Caption := IntToStr(Users.Items[0].Coins);

  imgMyStatus.ImageIndex := GetUserStatusIndex(MyStatus);

  PopulateGameTypeCombobox;

  gaugeLevel.ProgressText := Format(RS_PLAYER_LEVEL, [UserDetails.Level]);
  gaugeLevel.MinValue := 0;
  gaugeLevel.MaxValue := UserDetails.NextLevelExp;
  gaugeLevel.Value := UserDetails.Experience;
  gaugeLevel.Hint := Format(RS_PLAYER_LEVEL_HINT, [UserDetails.Experience, UserDetails.NextLevelExp]);

  lbNotificationFooter.OnClick := nil;
  If ((ClientSettings.CurrentVersion <> CLIENT_VERSION) and
      (ClientSettings.CurrentVersion <> '') and
      (ClientSettings.CurrentVersion <> 'DISABLED')) or
     ((ClientSettings.GProxyHash <> '') and
      (ClientSettings.GProxyHash <> 'DISABLED') and
      (ClientSettings.GProxyHash <> md5File(SelfPath + GPROXY_EXE))) Then
  Begin
    paClientNotifications.Visible := TRUE;
    lbNotificationHeader.Caption := RS_UPDATE_AVAILABLE;
    lbNotificationFooter.Caption := RS_UPDATE_NOW;
    lbNotificationFooter.Cursor := crHandPoint;
    lbNotificationFooter.OnClick := OnClick_Update;
  End
  else
    If UserDetails.Tour.TGID <> 0 Then
    Begin
      paClientNotifications.Visible := TRUE;
      If UserDetails.Tour.TD > 0 Then
      Begin
        lbNotificationHeader.Caption := Format(RS_TOUR_GAME_STARTS_IN, [UserDetails.Tour.TN]);
        lbNotificationFooter.Caption := Format('%d minutes', [UserDetails.Tour.TD]);
      End
      else
      Begin
        lbNotificationHeader.Caption := Format(RS_TOUR_GAME_HAS_STARTED, [UserDetails.Tour.TN]);
        lbNotificationFooter.Caption := '';
      End;

      ResizeLabel(lbNotificationHeader);
      ResizeLabel(lbNotificationFooter);

      tiMyDetailsUpdate.Interval := 1000 * 60; // 1 min

      ComponentModuleWindow.GProxy.Send(Format('tids %d', [UserDetails.Tour.TGID]));

      If UserDetails.Tour.CS <> 0 Then
        ComponentModuleWindow.GProxy.Send(Format('cst %d', [UserDetails.Tour.CS]));
    End
    else
    Begin
      paClientNotifications.Visible := FALSE;
      ComponentModuleWindow.GProxy.Send('tidsc');
    End;

  SetMyTitle(Users.Items[0].Stats.Title);

  FillRequestList;
  If UserDetails.Requests.Count > 0 Then
    MainWindow.btRequests.ImageIndex := 1
  else
    MainWindow.btRequests.ImageIndex := 0;

  FillMessageList;
  MainWindow.btMessages.ImageIndex := 2;
  For C1 := 0 to UserDetails.Messages.Count - 1 Do
    If UserDetails.Messages.Items[C1].Unread Then
    Begin
      MainWindow.btMessages.ImageIndex := 3;
      Break;
    End;

  tiSendCriteria.OnTimer(self);
end;

procedure TMainWindow.ResizeLabel(const ALabel : TspSkinShadowLabel);
var
  words    : TStringList;
  repeatit : Boolean;
  C1       : Integer;
  font     : TFont;
begin
  font := TFont.Create;
  font.Assign(ALabel.Font);
  font.Size := 24;
  words := TStringList.Create;
  Split(' ', ALabel.Caption, words);
  repeat
    repeatit := FALSE;
    For C1 := 0 to words.Count - 1 Do
      If (GetTextWidth(words[C1], font) >= ALabel.Width) and
         (font.Size > 4) Then
      Begin
        font.Size := font.Size - 1;
        repeatit := TRUE;
        Break;
      End;
  until not repeatit;

  While GetTextHeight('A', font) * GetWrapLinesNumber(words, ALabel.Width, font) >= ALabel.Height - GetWrapLinesNumber(words, ALabel.Width, font) * 5 Do
    font.Size := font.Size - 1; 

  words.Free;
  ALabel.Font.Size := font.Size;
  font.Free;
end;

procedure TMainWindow.rvChatBoxMouseUp(Sender: TCustomRichView; Button: TMouseButton; Shift: TShiftState; ItemNo, X, Y: Integer);
var
  pt                       : TPoint;
  RVData                   : TCustomRVFormattedData;
  LItemNo, LOffs, Row, Col : Integer;
  Table                    : TRVTableItemInfo;
  Cell                     : TRVTableCellData;
  Nick                     : String;
  C1                       : Integer;
  lbox                     : TspSkinOfficeListBox;
  bot                      : Boolean;
begin
  If not Sender.SelectionExists Then
  Begin
    pt := Sender.ClientToDocument(Point(X,Y));
    If (Sender.GetItemAt(pt.X, pt.Y, RVData, LItemNo, LOffs, True)) and
       (RVData.GetSourceRVData is TRVTableCellData) Then
    Begin
      Cell := TRVTableCellData(RVData.GetSourceRVData);
      Table := Cell.GetTable;
      Table.GetCellPosition(Cell, Row, Col);
      If Col = 0 Then
      Begin
        Nick := Table.Cells[Row, Col].GetItemText(0);
        Delete(Nick, Length(Nick), 1);
        If (Nick <> RS_SERVER_INFO) and
           (Nick <> RS_SERVER_ERROR) Then
        Begin
          bot := FALSE;
          For C1 := 0 to BOTS_COUNT - 1 Do
            If MatchStrings(Nick, BOTS_NAMES[C1], TRUE) Then
            Begin
              bot := TRUE;
              Break;
            End;

          If not bot Then
          Begin
            lbox := GetChatTabUserList(cntChat.ActivePage);
            If Assigned(lbox) Then
              For C1 := 0 to lbox.Items.Count - 1 Do
                If lbox.Items[C1].Title = Nick Then
                Begin
                  lbox.ItemIndex := C1;
                  If GetTickCount - LastP2PAction > 1000 Then
                  Begin
                    P2P_RequestUserStats(UserDetails.Username, lbox.Items[lbox.ItemIndex].Title);
                    LastP2PAction := GetTickCount;
                  End;
                  ShowUserStats(FindUser(Nick));
                  Break;
                End;
          End;
        End;
      End;
    End;
  End;
end;

procedure TMainWindow.tiUsernameDelayedQueueTimer(Sender: TObject);
begin
  While UsernameQueueDelayed.Count > 0 Do
  Begin
    AddUserToPostQueue(UsernameQueue, UsernameQueueDelayed.Strings[UsernameQueueDelayed.Count - 1]);
    UsernameQueueDelayed.Delete(UsernameQueueDelayed.Count - 1);
  End;
  PostUserQueue;
end;

procedure TMainWindow.httpMainBannerRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
begin
  cache_PutFile(TMemoryStream(httpMainBanner.RcvdStream), 'mainbanner.png');
  SetBanner(ilMainBanner, imgMainBanner, TMemoryStream(httpMainBanner.RcvdStream));

  httpFree(httpMainBanner);
end;

procedure TMainWindow.httpUserBannerRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
begin
  cache_PutFile(TMemoryStream(httpUserBanner.RcvdStream), 'userbanner.png');
  SetBanner(ilUserBanner, imgUserInfoBanner, TMemoryStream(httpUserBanner.RcvdStream));

  httpFree(httpUserBanner);
end;

procedure TMainWindow.tcpServerDataAvailable(Sender: TObject; ErrCode: Word);
const
  BUF_SIZE = 1024 * 16;
var
  Buffer : Array[0..BUF_SIZE - 1] of Char;
  Len    : Integer;
  Src    : TSockAddrIn;
  SrcLen : Integer;
  Data   : String;
  params : String;
begin
  SrcLen := SizeOf(Src);
  Len := TWSocket(Sender).ReceiveFrom(@Buffer, BUF_SIZE, Src, SrcLen);
  If Len >= 0 Then
  Begin
    Data := StrPas(Buffer);
    P2P_Process(Data, params);
  End;
end;

procedure TMainWindow.LoadAvatarFromFile(const AAvatarPath : String; const AAvatarType : TAvatarType; const AUserID : Integer);
var
  img : TspPngImageItem;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: LoadAvatarFromFile() :: BEGIN');  {$ENDIF}

  img := nil;
  Case AAvatarType of
    atBig   : Begin
                img := TspPngImageItem(ilAvatars145.PngImages.Add);
                Users.Avatar[AUserID].ID145 := img.Index;
              End;
    atSmall : Begin
                img := TspPngImageItem(ilAvatars35.PngImages.Add);
                Users.Avatar[AUserID].ID35 := img.Index;
              End;
  End;

  If Assigned(img) Then
    img.PngImage.LoadFromFile(AAvatarPath);

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: LoadAvatarFromFile() :: END');  {$ENDIF}
end;


procedure TMainWindow.tiAvatarsUpdateTimer(Sender: TObject);
var
  C1         : Integer;
  avatarPath : String;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: tiAvatarsUpdateTimer() :: BEGIN');  {$ENDIF}

  For C1 := 0 to Users.Count - 1 Do
  Begin
    If (Users.Avatar[C1].ID145 = -1) and
       (Users.Avatar[C1].LastUpdated145 <> Users.Items[C1].Avatar) Then
      If cache_GetAvatar(Users.Items[C1].Avatar, atBig, avatarPath) Then
      Begin
        LoadAvatarFromFile(avatarPath, atBig, C1);
        Users.Avatar[C1].LastUpdated145 := ExtractFileName(avatarPath);
      End
      else
      Begin
        If (Users.Items[C1].Avatar <> '') and
           (httpBigAvatar.State = httpReady) Then
        Begin
          httpBigAvatar.Tag := C1;
          Users.Avatar[C1].LastUpdated145 := Users.Items[C1].Avatar;
          httpGetRequest(httpBigAvatar, URL_USER_AVATAR_145 + Users.Items[C1].Avatar);
        End;
      End;

    If (Users.Avatar[C1].ID35 = -1) and
       (Users.Avatar[C1].LastUpdated35 <> Users.Items[C1].Avatar) Then
      If cache_GetAvatar(Users.Items[C1].Avatar, atSmall, avatarPath) Then
      Begin
        LoadAvatarFromFile(avatarPath, atSmall, C1);
        Users.Avatar[C1].LastUpdated35 := ExtractFileName(avatarPath);
      End
      else
      Begin
        If (Users.Items[C1].Avatar <> '') and
           (httpSmallAvatar.State = httpReady) Then
        Begin
          httpSmallAvatar.Tag := C1;
          Users.Avatar[C1].LastUpdated35 := Users.Items[C1].Avatar;
          httpGetRequest(httpSmallAvatar, URL_USER_AVATAR_35 + Users.Items[C1].Avatar);
        End;
      End;
  End;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: tiAvatarsUpdateTimer() :: END');  {$ENDIF}
end;

procedure TMainWindow.AddAvatar(const AImageList : TspPngImageList; const AAvatar : TMemoryStream; const AUserID : Integer; const AAvatarType : TAvatarType);
var
  avatarPath : String;
  imageen    : TImageEn;
begin
  imageen := TImageEn.Create(nil);
  AAvatar.Position := 0;
  imageen.IO.LoadFromStream(AAvatar);
  imageen.Proc.AddInnerShadow(3);

  If (imageen.Width <> AImageList.PngWidth) or
     (imageen.Height <> AImageList.PngHeight) Then
    imageen.Proc.Resample(AImageList.PngWidth, AImageList.PngHeight, rfLanczos3);

  AAvatar.Position := 0;

  try
    imageen.IO.SaveToStreamPNG(AAvatar);
  except
    Users.Items[AUserID].Avatar := 'nopic';
  end;

  cache_PutAvatar(AAvatar, Users.Items[AUserID].Avatar, AAvatarType);

  imageen.Free;

  If cache_GetAvatar(Users.Items[AUserID].Avatar, AAvatarType, avatarPath) Then
    LoadAvatarFromFile(avatarPath, AAvatarType, AUserID);
end;

procedure TMainWindow.httpBigAvatarRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: httpBigAvatarRequestDone() :: BEGIN');  {$ENDIF}

  If ErrCode <> 0 Then
  else
    If THTTPCli(Sender).StatusCode <> 200 Then
    else
      If THTTPCli(Sender).RcvdCount > 0 Then
        AddAvatar(ilAvatars145, TMemoryStream(THTTPCli(Sender).RcvdStream), THTTPCli(Sender).Tag, atBig);

  httpFree(httpBigAvatar);

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: httpBigAvatarRequestDone() :: BEGIN');  {$ENDIF}
end;

procedure TMainWindow.httpSmallAvatarRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: httpSmallAvatarRequestDone() :: BEGIN');  {$ENDIF}

  If ErrCode <> 0 Then
  else
    If THTTPCli(Sender).StatusCode <> 200 Then
    else
      If THTTPCli(Sender).RcvdCount > 0 Then
        AddAvatar(ilAvatars35, TMemoryStream(THTTPCli(Sender).RcvdStream), THTTPCli(Sender).Tag, atSmall);

  httpFree(httpSmallAvatar);

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: httpSmallAvatarRequestDone() :: END');  {$ENDIF}
end;

procedure TMainWindow.tiAvatarsRefreshTimer(Sender: TObject);
begin
  thdAvatarRefresh.Execute(nil);
  tiAvatarsRefresh.Enabled := FALSE;
end;

function TMainWindow.RefreshListboxAvatars(const AListbox : TspSkinOfficeListBox) : Boolean;
var
  C1       : Integer;
  uid, iid : Integer;
begin
  result := TRUE;
  For C1 := 0 to AListbox.Items.Count - 1 Do
    If C1 < AListbox.Items.Count Then
    Begin
      uid := FindUser(AListbox.Items[C1].Title);
      If uid <> -1 Then
      Begin
        If AListbox.Items[C1].ImageIndex <> Users.Avatar[uid].ID35 Then
        Begin
          iid := Users.Avatar[uid].ID35;
          If iid = -1 Then
            iid := 0;

          If AListbox.Items[C1].ImageIndex <> iid Then
          Begin
            AListbox.Items[C1].ImageIndex := Users.Avatar[uid].ID35;
            result := FALSE;
          End;
        End;
      End;
    End
    else
      Break;
end;

procedure TMainWindow.thdAvatarRefreshExecute(Sender: TObject; Params: Pointer);
var
  imageen    : TImageEn;
  memStream  : TMemoryStream;
  iid        : Integer;
  img        : TspPngImageItem;
  lbox       : TspSkinOfficeListBox;
  loadedall  : Boolean;
begin
  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: thdAvatarRefreshExecute() :: BEGIN');  {$ENDIF}

  loadedall := TRUE;
  If (Users.Count >= 0) and
     (imgMyAvatar.Tag <> Users.Avatar[0].ID145) Then
  Begin
    iid := Users.Avatar[0].ID145;
    If iid = -1 Then
      iid := 0;

    memStream := TMemoryStream.Create;
    imageen := TImageEn.Create(nil);
    ilAvatars145.PngImages[iid].PngImage.SaveToStream(memStream);
    memStream.Position := 0;
    imageen.IO.LoadFromStream(memStream);
    imageen.Proc.Resample(ilMyAvatar.PngWidth, ilMyAvatar.PngHeight, rfLanczos3);
    memStream.Position := 0;
    imageen.IO.SaveToStreamPNG(memStream);
    imageen.Free;

    imgMyAvatar.ImageIndex := 0;
    While ilMyAvatar.PngImages.Count > 1 Do
      ilMyAvatar.PngImages.Delete(ilMyAvatar.PngImages.Count - 1);

    img := TspPngImageItem(ilMyAvatar.PngImages.Add);
    memStream.Position := 0;
    img.PngImage.LoadFromStream(memStream);
    memStream.Free;

    imgMyAvatar.Tag := Users.Avatar[0].ID145;
    imgMyAvatar.ImageIndex := img.Index;

    loadedall := FALSE;
  End;

  lbox := GetChatTabUserList(cntChat.ActivePage);
  If Assigned(lbox) Then
    If not RefreshListboxAvatars(lbox) Then
      loadedall := FALSE;

  If not RefreshListboxAvatars(lboxFriends) Then
    loadedall := FALSE;

  If not RefreshListboxAvatars(lboxMessages) Then
    loadedall := FALSE;
  If not RefreshListboxAvatars(lboxNotifications) Then
    loadedall := FALSE;

  If (paUserInfo.Tag >= 0) and
     (paUserInfo.Tag < Users.Count) and
     (paUserInfo.Visible) and
     (imgUserInfoAvatar.Tag <> Users.Avatar[paUserInfo.Tag].ID145) Then
  Begin
    SetUserInfoAvatar(paUserInfo.Tag);
    imgUserInfoAvatar.Refresh;
  End;

  If loadedall Then
    tiAvatarsRefresh.Interval := 5000
  else
    tiAvatarsRefresh.Interval := 1000;

  {$IFDEF DEBUG_MAIN} DbgLn('MainWindow :: thdAvatarRefreshExecute() :: END');  {$ENDIF}
end;

procedure TMainWindow.thdAvatarRefreshFinish(Sender: TObject);
begin
  tiAvatarsRefresh.Enabled := TRUE;
end;

procedure TMainWindow.imgMyAvatarClick(Sender: TObject);
begin
  ShowUserStats(0);
end;

procedure TMainWindow.tiGameHostCaptionHideTimer(Sender: TObject);
begin
  lbHostingInfo.Caption := '';
  lbHostingInfo.Visible := FALSE;
  tiGameHostcaptionHide.Enabled := FALSE;
end;

procedure TMainWindow.SetGameHostCaption(const ACaption : String; const AColor : TColor = $0000BB00);
begin
  lbHostingInfo.Width := paInCntRight.Width - 30;
  lbHostingInfo.Font.Color := AColor;
  If GetTextWidth(ACaption, lbHostingInfo.Font) > lbHostingInfo.Width Then
    lbHostingInfo.Width := GetTextWidth(ACaption, lbHostingInfo.Font) + 10;
  lbHostingInfo.Left := paCntRight.Left + 14;
  If lbHostingInfo.Left + lbHostingInfo.Width > MainWindow.Width Then
    lbHostingInfo.Left := MainWindow.Width - lbHostingInfo.Width - 20;
  lbHostingInfo.Caption := ACaption;
  lbHostingInfo.Visible := TRUE;
  tiGameHostCaptionHide.Enabled := FALSE;
  tiGameHostCaptionHide.Enabled := TRUE;
end;

function TMainWindow.IsProtectedChannel(const AChannel : String; var APassword : String) : Boolean;
var
  C1 : Integer;
begin
  result := FALSE;
  For C1 := 0 to ProtectedChannels.Count - 1 Do
    If LowerCase(ProtectedChannels.Items[C1].Channel) = LowerCase(AChannel) Then
    Begin
      result := TRUE;
      APassword := ProtectedChannels.Items[C1].Password;
      Break;
    End;
end;

procedure TMainWindow.JoinChannel(const AChannel : String);
var
  join : Boolean;
  pass : String;
begin
  join := TRUE;

  If IsProtectedChannel(AChannel, pass) Then
  Begin
    join := FALSE;
    While not join Do
    Begin
      Application.CreateForm(TChannelWindow, ChannelWindow);
      ChannelWindow.Caption := RS_CHAN_CAPTION_JOIN;
      ChannelWindow.ebChannelName.Text := AChannel;
      ChannelWindow.ebChannelName.ReadOnly := TRUE;
      ChannelWindow.ebChannelName.TabStop := FALSE;
      ChannelWindow.btOk.Caption := RS_CHAN_JOIN;
      ChannelWindow.ShowModal;
      Case ChannelWindow.ModalResult of
        mrOK     : join := md5String(ChannelWindow.ebPassword.Text) = pass;
        mrCancel : Break;
      End;
    End;
    ChannelWindow := nil;
  End;

  If join Then
    JoinCheckRoom(AChannel);
end;

procedure TMainWindow.lboxChannelsListBoxDblClick(Sender: TObject);
var
  ctab : TTabSheet;
begin
  ctab := GetChatTab('', ctPVPGN_Channel);
  If (not Assigned(ctab)) or
     (ctab.Caption <> lboxChannels.Items[lboxChannels.ItemIndex]) Then
    JoinChannel(lboxChannels.Items[lboxChannels.ItemIndex]);
end;

procedure TMainWindow.smAddChannelToFavsClick(Sender: TObject);
begin
  If smAddChannelToFavs.Caption = RS_CHAN_ADD_TO_FAVS Then
    AddChannelToFavs(cntChat.ActivePage.Caption)
  else
    If smAddChannelToFavs.Caption = RS_CHAN_REMOVE_FROM_FAVS Then
      RemoveChannelFromFavs(cntChat.ActivePage.Caption);
end;

procedure TMainWindow.AddChannelToFavs(const AChannel : String);
var
  chans     : String;
  chanslist : TStringList;
  C1        : Integer;
begin
  chans := ComponentModuleWindow.Settings.ReadString('client\channels', '');
  chanslist := TStringList.Create;
  chanslist.Duplicates := dupIgnore;
  Split(',', chans, chanslist);
  chanslist.Add(AChannel);
  chans := '';
  For C1 := 0 to chanslist.Count - 1 Do
    chans := chans + chanslist[C1] + ',';
  chanslist.Free;

  Delete(chans, Length(chans), 1);
  ComponentModuleWindow.Settings.WriteString('client\channels', chans);

  PopulateChannelList;
end;

procedure TMainWindow.RemoveChannelFromFavs(const AChannel : String);
var
  chans     : String;
  chanslist : TStringList;
  index     : Integer;
  C1        : Integer;
begin
  chans := ComponentModuleWindow.Settings.ReadString('client\channels', '');
  chanslist := TStringList.Create;
  chanslist.Sorted := TRUE;
  chanslist.Duplicates := dupIgnore;
  Split(',', chans, chanslist);

  If chanslist.Find(AChannel, index) Then
  Begin
    chanslist.Delete(index);
    chans := '';
    For C1 := 0 to chanslist.Count - 1 Do
      chans := chans + chanslist[C1] + ',';
    Delete(chans, Length(chans), 1);
    ComponentModuleWindow.Settings.WriteString('client\channels', chans);
    PopulateChannelList;
  End;
  chanslist.Free;
end;
                                                              
function TMainWindow.IsChannelFavorite(const AChannel : String) : Integer;
var
  chans     : String;
  chanslist : TStringList;
  C1        : Integer;
begin
  result := 0;
  
  If (LowerCase(AChannel) = 'general') or
     (LowerCase(AChannel) = 'challenge') or
     (LowerCase(AChannel) = LowerCase(UserDetails.NativeChannel)) or
     (LowerCase(AChannel) = LowerCase(GetCountryNameFromCode(UserDetails.Country))) Then
    result := 2
  else
  Begin
    chans := ComponentModuleWindow.Settings.ReadString('client\channels', '');
    chanslist := TStringList.Create;
    chanslist.Duplicates := dupIgnore;
    Split(',', chans, chanslist);
    For C1 := 0 to chanslist.Count - 1 Do
      If LowerCase(chanslist[C1]) = LowerCase(AChannel) Then
      Begin
        result := 1;
        Break;
      End;
    chanslist.Free;
  End;
end;

procedure TMainWindow.pmChatBoxPopup(Sender: TObject);
begin
  RefreshChannelMenu;
end;

procedure TMainWindow.btCreateChannelClick(Sender: TObject);
begin
  Application.CreateForm(TChannelWindow, ChannelWindow);
  ChannelWindow.Caption := RS_CHAN_CAPTION_CREATE;
  ChannelWindow.btOk.Caption := RS_CHAN_CREATE;
  ChannelWindow.ShowModal;

  Case ChannelWindow.ModalResult of
    mrOK : httpPostRequest(httpQuickAPI, URL_API + 'createProtectedChannel', Format('key=%s&channel=%s&password=%s&server=%s', [UserDetails.Key, ChannelWindow.ebChannelName.Text, md5String(ChannelWindow.ebPassword.Text), 'EU']));
  End;

  ChannelWindow := nil;
end;

procedure TMainWindow.btJoinChannelClick(Sender: TObject);
var
  join       : Boolean;
  chan, pass : String;
begin
  join := FALSE;
  While not join Do
  Begin
    Application.CreateForm(TChannelWindow, ChannelWindow);
    ChannelWindow.Caption := RS_CHAN_CAPTION_JOIN;
    ChannelWindow.btOk.Caption := RS_CHAN_JOIN;
    ChannelWindow.ShowModal;
    Case ChannelWindow.ModalResult of
      mrOK     : Begin
                   chan := ChannelWindow.ebChannelName.Text;
                   If IsProtectedChannel(chan, pass) Then
                     join := md5String(ChannelWindow.ebPassword.Text) = pass
                   else
                     join := TRUE;
                 End;
      mrCancel : Break;
    End;
  End;
  ChannelWindow := nil;

  If join Then
    JoinCheckRoom(chan);
end;

procedure TMainWindow.JoinCheckRoom(const AChannel : String);
var
  error : String;
begin
  If IsValidRoom(Users.Items[0].Stats.Rating, AChannel, error) Then
    ComponentModuleWindow.GProxy.Command(Format('join %s', [AChannel]))
  else
  Begin
    If error <> '' Then
      AddLineToChatTab(cntChat.ActivePage, RS_SERVER_ERROR, error, STYLE_ERROR_SND, STYLE_ERROR_MSG);
  End;
end;

procedure TMainWindow.lboxChannelsListBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ctab : TTabSheet;
begin
  Case Button of
    mbRight, mbLeft : Begin
                        If TspSkinListBox(Sender).ItemAtPos(Point(X, Y), TRUE) = -1 Then
                          SelectedChannel := -1
                        else
                        Begin
                          SelectedChannel := TspSkinListBox(Sender).ItemAtPos(Point(X, Y), TRUE);
                          TspSkinListBox(Sender).ItemIndex := SelectedChannel;
                        End;

                        If SelectedChannel <> -1 Then
                        Begin
                          TspSkinListBox(Sender).PopupMenu := pmChannels;

                          smRemoveFromFavs.Visible := not (SelectedChannel in [0, 1, 2, 3, 4]);
                          N9.Visible := smRemoveFromFavs.Visible;

                          ctab := GetPVPGNTab(ctPVPGN_Channel, '');
                          If Assigned(ctab) Then
                          Begin
                            If TspSkinListBox(Sender).Items[SelectedChannel] = ctab.Caption Then
                            Begin
                              smJoin.Visible := FALSE;
                              N9.Visible := FALSE;
                            End
                            else
                            Begin
                              smJoin.Visible := TRUE;
                              If smRemoveFromFavs.Visible Then
                                N9.Visible := TRUE;
                            End;
                          End;

                          If (not smJoin.Visible) and
                             (not smRemoveFromFavs.Visible) Then
                            TspSkinListBox(Sender).PopupMenu := nil;
                        End
                        else
                          TspSkinListBox(Sender).PopupMenu := nil;
                      End;
  End;
end;

procedure TMainWindow.smJoinClick(Sender: TObject);
begin
  If SelectedChannel <> -1 Then
    JoinChannel(lboxChannels.Items[SelectedChannel]);
end;

procedure TMainWindow.smRemoveFromFavsClick(Sender: TObject);
begin
  If SelectedChannel <> -1 Then
    RemoveChannelFromFavs(lboxChannels.Items[SelectedChannel]);
end;

procedure TMainWindow.LocalizeChallengeLabel;
begin
  If cbGameType.ItemIndex = 2 Then
    lbGamePassword.Caption := RS_CHALLENGE_FEE
  else
    lbGamePassword.Caption := RS_GAME_PASSWORD;
end;

procedure TMainWindow.cbGameTypeChange(Sender: TObject);
begin
  LocalizeChallengeLabel;

  ebChallengeFee.Visible := cbGameType.ItemIndex = 2;
  ebPassword.Visible := not ebChallengeFee.Visible;

  tiSendCriteria.Enabled := TRUE;
end;

procedure TMainWindow.ebPasswordChange(Sender: TObject);
begin
  tiSendCriteria.Enabled := TRUE;
end;

procedure TMainWindow.tiSendCriteriaTimer(Sender: TObject);
var
  valChallenge, gameType : Integer;
begin
  valChallenge := 0;
  If cbGameType.ItemIndex = 2 Then
    valChallenge := Trunc(ebChallengeFee.Value);

  gameType := cbGameType.ItemIndex;
  If cbGameType.ItemIndex = 2 Then
    gameType := 3;

  SetCriteria(UserDetails.Tour.TGID, gameType, cbGameMode.ItemIndex, Users.Items[0].Stats.Rating, 0, GetDisconnectPercent(0), valChallenge, 0, 0, ebPassword.Text);

  tiSendCriteria.Enabled := FALSE;
end;

procedure TMainWindow.ebMinRatingChange(Sender: TObject);
begin
  tiSendCriteria.Enabled := TRUE;
end;

procedure TMainWindow.cbGameModeChange(Sender: TObject);
begin
  tiSendCriteria.Enabled := TRUE;
end;

procedure TMainWindow.tiMyDetailsUpdateTimer(Sender: TObject);
begin
  If httpMyDetails.State = httpReady Then
  Begin
    httpPostRequest(httpMyDetails, URL_API + 'getUserDetails', Format('key=%s&server=%s&mess_no=%d&notif_no=%d', [UserDetails.Key, UserDetails.Server, 4, 4]));

    If UserDetails.Tour.TGID <> 0 Then
      tiMyDetailsUpdate.Interval := 1000 * 60 // 1 min
    else
      tiMyDetailsUpdate.Interval := 1000 * 60 * 5; // 5 mins

    tiImgRefreshRotate.Enabled := FALSE;
    tiImgRefreshRotate.Enabled := TRUE;
    imgRefresh.Tag := 0;
    imgRefresh.ImageIndex := 6;
  End
  else
    httpMyDetails.Close;  
end;

procedure TMainWindow.httpMyDetailsRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  JSON     : ISuperObject;
  response : WideString;
  respType : Char;
  respCode : Integer;
begin
  DebugTime_GetUserDetails := GetTickCount;
  If ErrCode <> 0 Then
    DebugStatus_GetUserDetails := 'ErrCode: 200'
  else
  Begin
    If THTTPCli(Sender).StatusCode <> 200 Then
      DebugStatus_GetUserDetails := 'StatusCode: 200'
    else
    Begin
      THTTPCli(Sender).RcvdStream.Position := 0;
      JSON := TSuperObject.ParseStream(THTTPCli(Sender).RcvdStream, FALSE);
      response := JSON.S['result'];
      JSON := nil;

      If not ParseResponse(response, respType, respCode) Then
      Begin
        ParseMyDetails(response);

        RefreshAnnouncement;
        RefreshBanners;
        ShowMyStats;
        RefreshFriendList;
        DebugStatus_GetUserDetails := 'OK';
      End
      else
        DebugStatus_GetUserDetails := Format('Response parsing failed [%s]', [response]);
    End;
  End;

  httpFree(THTTPCli(Sender));

  tiImgRefreshRotate.Tag := 1;
  tiMyStatsRefresh.Enabled := FALSE;
  tiMyStatsRefresh.Enabled := TRUE;

  SendDebugData;
end;

procedure TMainWindow.RefreshAnnouncement;
begin
  lbAnnouncement.Caption := ClientSettings.AnnouncementText;
  lbAnnouncement.Font.Color := ClientSettings.AnnouncementColor;
  lbAnnouncement.Visible := TRUE;
end;

procedure TMainWindow.RefreshBanners;
var
  memStream : TMemoryStream;
begin
  If (md5File(cache_GetFilePath('mainbanner.png')) = ClientSettings.MainBanner.Hash) and
     (cache_FileExists('mainbanner.png')) Then
  Begin
    memStream := TMemoryStream.Create;
    memStream.LoadFromFile(cache_GetFilePath('mainbanner.png'));
    SetBanner(ilMainBanner, imgMainBanner, memStream);
    memStream.Free;
  End
  else
    httpGetRequest(httpMainBanner, ClientSettings.MainBanner.Image);


  If (md5File(cache_GetFilePath('userbanner.png')) = ClientSettings.UserBanner.Hash) and
     (cache_FileExists('userbanner.png')) Then
  Begin
    memStream := TMemoryStream.Create;
    memStream.LoadFromFile(cache_GetFilePath('userbanner.png'));
    SetBanner(ilUserBanner, imgUserInfoBanner, memStream);
    memStream.Free;
  End
  else
    httpGetRequest(httpUserBanner, ClientSettings.UserBanner.Image);
end;

procedure TMainWindow.tiFriendRequestsTimer(Sender: TObject);
var
  C1 : Integer;
begin
  If (Options.Client.ShowFriendRequests) and
     (Assigned(UserDetails.FriendRequests_IDs)) and
     (Assigned(UserDetails.FriendRequests_Names)) and
     (UserDetails.FriendRequests_IDs.Count > 0) and
     (UserDetails.FriendRequests_IDs.Count = UserDetails.FriendRequests_Names.Count) and
     (UserDetails.FriendRequests_IDs.Strings[0] <> '0') Then
  Begin
    For C1 := 0 to UserDetails.FriendRequests_IDs.Count - 1 Do
      If UserDetails.FriendRequests_Processed.Strings[C1] = '0' Then
      Begin
        If not Assigned(FriendRequestWindow) Then
        Begin
          Application.CreateForm(TFriendRequestWindow, FriendRequestWindow);
          FriendRequestWindow.SetRequestID(C1);
          FriendRequestWindow.ShowModal;
          FriendRequestWindow := nil;
        End;                        
      End;
  End;
end;

procedure TMainWindow.mmBlocklistClick(Sender: TObject);
begin
  Application.CreateForm(TBlocklistWindow, BlocklistWindow);
  BlocklistWindow.ShowModal;
  BlocklistWindow := nil;
end;

procedure TMainWindow.BlockUser(const AUser : String);
var
  params : String;
begin
  If LowerCase(AUser) <> LowerCase(UserDetails.Username) Then
  Begin
    params := Format('key=%s&to=%s', [UserDetails.Key, AUser]);
    httpPostRequest(httpQuickAPI, URL_API + 'blockUser', params);
    Blocklist.Add(AUser);
    SendBlocklist;

    If (paUserInfo.Tag >= 0) and
       (paUserInfo.Visible) and
       (Users.Items[paUserInfo.Tag].Username = AUser) Then
      ShowUserStats(paUserInfo.Tag);
  End;
end;

procedure TMainWindow.UnblockUser(const AUser : String);
var
  index  : Integer;
  params : String;
begin
  If LowerCase(AUser) <> LowerCase(UserDetails.Username) Then
  Begin
    params := Format('key=%s&to=%s', [UserDetails.Key, AUser]);
    httpPostRequest(httpQuickAPI, URL_API + 'unblockUser', params);
    If Blocklist.Find(AUser, index) Then
      Blocklist.Delete(index);
    SendBlocklist;

    If (paUserInfo.Tag >= 0) and
       (paUserInfo.Visible) and
       (Users.Items[paUserInfo.Tag].Username = AUser) Then
      ShowUserStats(paUserInfo.Tag);
  End;
end;

procedure TMainWindow.smBlockClick(Sender: TObject);
var
  lb   : TspSkinOfficeListBox;
  item : TspSkinOfficeItem;
begin
  lb := GetChatTabUserList(cntChat.ActivePage);
  If Assigned(lb) Then
  Begin
    item := TspSkinOfficeItem(lb.Items.FindItemID(SelectedUser));
    If Assigned(item) Then
      If smBlock.Caption = RS_BLOCK_USER Then
        BlockUser(item.Title)
      else
        If smBlock.Caption = RS_UNBLOCK_USER Then
          UnblockUser(item.Title);
  End;
end;

procedure TMainWindow.btUserFriendsClick(Sender: TObject);
begin
  If (Users.Items[paUserInfo.Tag].IsFriend_Site) or
     (Users.Items[paUserInfo.Tag].IsFriend_PVPGN) Then
  Begin
    RemoveFromFriends(Users.Items[paUserInfo.Tag].Username);
  End
  else
  Begin
    AddToFriends(Users.Items[paUserInfo.Tag].Username);
  End;
end;

procedure TMainWindow.btUserBlockClick(Sender: TObject);
begin
  Case btUserBlock.ImageIndex of
    3 : BlockUser(Users.Items[paUserInfo.Tag].Username);
    7 : UnblockUser(Users.Items[paUserInfo.Tag].Username);
  End;
end;

procedure TMainWindow.httpFriendAPIRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  respType : Char;
  respCode : Integer;
  JSON     : ISuperObject;
  response : WideString;
begin
  If ErrCode <> 0 Then
  else
    If THTTPCli(Sender).StatusCode <> 200 Then
    else
      If THTTPCli(Sender).RcvdCount > 0 Then
      Begin
        THTTPCli(Sender).RcvdStream.Position := 0;
        JSON := TSuperObject.ParseStream(THTTPCli(Sender).RcvdStream, FALSE);
        response := JSON.S['result'];
        JSON := nil;

        If ParseResponse(response, respType, respCode) Then
          AddLineToChatTab(cntChat.ActivePage, RS_SERVER_INFO, TranslateResponse(respType, respCode), STYLE_INFO_SND, STYLE_INFO_MSG);
      End;

  tiMyDetailsUpdate.Interval := 2000;
  tiMyDetailsUpdate.Enabled := FALSE;
  tiMyDetailsUpdate.Enabled := TRUE;
end;

procedure TMainWindow.WMHotkey(var Msg : TWMHotkey);
begin
  If msg.HotKey = HK1 Then
  Begin
    If not GameHosted Then
      btGameHost.OnClick(self);
  End;

  If msg.HotKey = HK2 Then
  Begin
    If GameHosted Then
      btGameHost.OnClick(self);
  End;
end;

procedure TMainWindow.btUserStatisticsClick(Sender: TObject);
begin
  BrowseURL(Format('http://www.darer.com/index/lookup/%s', [Users.Items[paUserInfo.Tag].Username]));
end;

procedure TMainWindow.imgMyStatusClick(Sender: TObject);
begin
  imgMyStatus.PopupMenu.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TMainWindow.smUserStatusOnlineClick(Sender: TObject);
begin
  If MyDND Then
    ComponentModuleWindow.GProxy.Command('dnd')
  else
  Begin
    MyStatus := usOnline;
    ShowMyStats;
  End;
end;

procedure TMainWindow.smUserStatusDNDClick(Sender: TObject);
begin
  If not MyDND Then
    ComponentModuleWindow.GProxy.Command('dnd')
  else
  Begin
    MyStatus := usBusy;
    ShowMyStats;
  End;
end;

procedure TMainWindow.smUserStatusOfflineClick(Sender: TObject);
begin
  MyStatus := usOffline;

  ShowMyStats;
end;

procedure TMainWindow.tiGameAutoMinimizeTimer(Sender: TObject);
begin
  If Options.Client.GameAutoMinimize Then
  Begin
    If WaitForSingleObject(WarProcessInfo.hProcess, 0) = WAIT_OBJECT_0 Then
    Begin
      ComponentModuleWindow.TrayIconClick(Sender);
      tiGameAutoMinimize.Enabled := FALSE;
    End;
  End;
end;

procedure TMainWindow.btMessagesClick(Sender: TObject);
begin
  btRequests.Down := FALSE;

  ResetBanner;
  If btMessages.Down Then
    ShowMessages
  else
    ShowBanner;
end;

procedure TMainWindow.lboxMessagesMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  itemindex : Integer;
begin
  Case Button of
    mbRight, mbLeft : Begin
                        If TspSkinOfficeListBox(Sender).ItemAtPos(X, Y) = -1 Then
                          SelectedMessage := -1
                        else
                        Begin
                          itemindex := TspSkinOfficeListBox(Sender).ItemAtPos(X, Y);
                          TspSkinOfficeListBox(Sender).ItemIndex := itemindex;
                          SelectedMessage := TspSkinOfficeListBox(Sender).Items[itemindex].ID;
                        End;
                      End;
  End;
end;

procedure TMainWindow.ShowMessages;
var
  C1, unread : Integer;
begin
  imgUserInfoStatus.Visible := FALSE;
  lbUserInfoUsername.Visible := FALSE;
  imgUserNickVertStatusDiv.Visible := FALSE;

  unread := 0;
  For C1 := 0 to UserDetails.Messages.Count - 1 Do
    If UserDetails.Messages.Items[C1].Unread Then
      Inc(unread);
  lbUserInfoTitle.Caption := Format(RS_USER_MESSAGES, [unread]);
  lbUserInfoTitle.Visible := TRUE;

  lbSeeAllMessages.Visible := TRUE;

  paMessages.Visible := TRUE;
  paBanner.Caption := '';

  tiUserStatsHide.Interval := 60000;
  tiUserStatsHide.Enabled := FALSE;
  tiUserStatsHide.Enabled := TRUE;
end;

procedure TMainWindow.ShowRequests;
begin
  imgUserInfoStatus.Visible := FALSE;
  lbUserInfoUsername.Visible := FALSE;
  imgUserNickVertStatusDiv.Visible := FALSE;

  lbUserInfoTitle.Caption := Format(RS_USER_REQUESTS, [UserDetails.Requests.Count]);
  lbUserInfoTitle.Visible := TRUE;

  lbSeeAllRequests.Visible := TRUE;

  paRequests.Visible := TRUE;
  paBanner.Caption := '';

  tiUserStatsHide.Interval := 60000;
  tiUserStatsHide.Enabled := FALSE;
  tiUserStatsHide.Enabled := TRUE;
end;

procedure TMainWindow.ResetBanner;
begin
  imgUserInfoStatus.Visible := FALSE;
  lbUserInfoTitle.Visible := FALSE;
  lbUserInfoUsername.Visible := FALSE;
  imgUserNickVertStatusDiv.Visible := FALSE;
  lbSeeAllMessages.Visible := FALSE;
  lbSeeAllRequests.Visible := FALSE;
  imgMainBanner.Visible := FALSE;
  paUserInfo.Hide;
  paMessages.Hide;
  paRequests.Hide;
  paClientNotifications.Hide;
  paBanner.Caption := '';
end;

procedure TMainWindow.ShowBanner;
begin
  ResetBanner;

  paBanner.Visible := TRUE;
  If UserDetails.Tour.TGID <> 0 Then
    paClientNotifications.Visible := TRUE;
  imgMainBanner.Visible := TRUE;

  btRequests.Down := FALSE;
  btMessages.Down := FALSE;
end;

procedure TMainWindow.mmBarMouseLeave(Sender: TObject);
begin
  mmBar.UpdateItems;
end;

procedure TMainWindow.btRequestsClick(Sender: TObject);
begin
  btMessages.Down := FALSE;

  ResetBanner;
  If btRequests.Down Then
    ShowRequests
  else
    ShowBanner;
end;

procedure TMainWindow.ShowPopup(const AHeader, AText : String; const ATimeout : Integer = 5000);
begin
  If not Assigned(TrayPopupWindow) Then
  Begin
    Application.CreateForm(TTrayPopupWindow, TrayPopupWindow);
    TrayPopupWindow.Reset(ATimeout, AHeader, AText);
    TrayPopupWindow.ShowFadeIn;
  End
  else
  Begin
    TrayPopupWindow.SetLabels(AHeader, AText);
    TrayPopupWindow.tiTimeout.Enabled := FALSE;
    TrayPopupWindow.tiTimeout.Enabled := TRUE;
  End;
end;

procedure TMainWindow.FormActivate(Sender: TObject);
begin
  ActivateForm;
end;

procedure TMainWindow.appEventsMinimize(Sender: TObject);
begin
  IsMinimized := TRUE;
end;

procedure TMainWindow.appEventsRestore(Sender: TObject);
begin
  IsMinimized := FALSE;

  ActivateForm;
end;

procedure TMainWindow.ActivateForm;
begin
  NotificationUsers.Clear;

  If ComponentModuleWindow.TrayIcon.IconIndex <> 0 Then
    ComponentModuleWindow.TrayIcon.IconIndex := 0;

  If Assigned(TrayPopupWindow) Then
    TrayPopupWindow.Close;
end;

procedure TMainWindow.appEventsActivate(Sender: TObject);
begin
  ActivateForm;
end;

procedure TMainWindow.FormShow(Sender: TObject);
begin
  ActivateForm;
end;

procedure TMainWindow.AddNotificationForUser(const AUser : String);
var
  index : Integer;
  icon  : Integer;
begin
  If not NotificationUsers.Find(AUser, index) Then
  Begin
    NotificationUsers.Add(AUser);
    icon := NotificationUsers.Count;
    If icon > ComponentModuleWindow.TrayIcon.IconList.Count - 1 Then
      icon := ComponentModuleWindow.TrayIcon.IconList.Count - 1;
    ComponentModuleWindow.TrayIcon.IconIndex := icon;
  End;
end;

procedure TMainWindow.FillMessageList;
var
  C1                : Integer;
  item              : TspSkinOfficeItem;
  uid               : Integer;
  iid               : Integer;
  text              : String;
  Y, MO, D, H, M, S : Integer;
begin
  lboxMessages.Items.Clear;
  For C1 := 0 to UserDetails.Messages.Count - 1 Do
  Begin
    item := lboxMessages.Items.Add;

    text := UserDetails.Messages.Items[C1].Text;
    While GetTextWidth(text, lboxMessages.Font) > lboxMessages.Width - lboxMessages.Images.Width - 30 Do
      Delete(text, Length(text), 1);

    If text <> UserDetails.Messages.Items[C1].Text Then
      text := text + '...';

    item.Title := UserDetails.Messages.Items[C1].Username;
    item.Caption := text;
    item.ImageIndex := 0;
    If UserDetails.Messages.Items[C1].Unread Then
    Begin
      item.TitleColor := clRed;
      item.TextColor := $008080FF;
    End
    else
    Begin
      item.TitleColor := $00AC9266;
      item.TextColor := clWhite;
    End;
    CalculateTimeDifference(UserDetails.Messages.Items[C1].ServerDateTime, UserDetails.Messages.Items[C1].MessageDateTime, Y, MO, D, H, M, S);
    item.Time := FormatTimeDifference(Y, MO, D, H, M, S);
    uid := FindUser(UserDetails.Messages.Items[C1].Username);
    If uid <> -1 Then
    Begin
      iid := Users.Avatar[uid].ID35;
      If iid = -1 Then
        iid := 0;

      If item.ImageIndex <> iid Then
        item.ImageIndex := Users.Avatar[uid].ID35;
    End;
  End;

  If lboxMessages.Items.Count > 4 Then
    lboxMessages.ShowScrollBar
  else
    lboxMessages.HideScrollBar;

  If paMessages.Visible Then
    ShowMessages;
end;

procedure TMainWindow.FillRequestList;
var
  C1                : Integer;
  item              : TspSkinOfficeItem;
  text              : String;
  Y, MO, D, H, M, S : Integer;
  uid, iid          : Integer;
begin
  lboxNotifications.Items.Clear;
  For C1 := 0 to UserDetails.Requests.Count - 1 Do
  Begin
    item := lboxNotifications.Items.Add;

    text := UserDetails.Requests.Items[C1].Text;
    While GetTextWidth(text, lboxNotifications.Font) > lboxNotifications.Width - lboxNotifications.Images.Width - 30 Do
      Delete(text, Length(text), 1);

    If text <> UserDetails.Requests.Items[C1].Text Then
      text := text + '...';

    item.Title := UserDetails.Requests.Items[C1].Username;
    item.Caption := text;
    item.ImageIndex := 0;
    item.TitleColor := clRed;
    item.TextColor := $008080FF;
    CalculateTimeDifference(UserDetails.Requests.Items[C1].ServerDateTime, UserDetails.Requests.Items[C1].MessageDateTime, Y, MO, D, H, M, S);
    item.Time := FormatTimeDifference(Y, MO, D, H, M, S);

    uid := FindUser(UserDetails.Requests.Items[C1].Username);
    If uid <> -1 Then
    Begin
      iid := Users.Avatar[uid].ID35;
      If iid = -1 Then
        iid := 0;

      If item.ImageIndex <> iid Then
        item.ImageIndex := Users.Avatar[uid].ID35;
    End;
  End;

  If lboxNotifications.Items.Count > 4 Then
    lboxNotifications.ShowScrollBar
  else
    lboxNotifications.HideScrollBar;

  If paRequests.Visible Then
    ShowRequests;
end;

function TMainWindow.FindMessage(const AUser, AText : String; var AIndex : Integer) : Boolean;
var
  C1 : Integer;
begin
  result := FALSE;
  For C1 := 0 to UserDetails.Messages.Count - 1 Do
    If (MatchStrings(UserDetails.Messages.Items[C1].Username, AUser, FALSE)) and
       (MatchStrings(UserDetails.Messages.Items[C1].Text, AText, FALSE)) Then
    Begin
      result := TRUE;
      AIndex := C1;
      Break;
    End;
end;

function TMainWindow.FindRequest(const AUser, AText : String; var AIndex : Integer) : Boolean;
var
  C1 : Integer;
begin
  result := FALSE;
  For C1 := 0 to UserDetails.Requests.Count - 1 Do
    If (MatchStrings(UserDetails.Requests.Items[C1].Username, AUser, FALSE)) and
       (MatchStrings(UserDetails.Requests.Items[C1].Text, AText, FALSE)) Then
    Begin
      result := TRUE;
      AIndex := C1;
      Break;
    End;
end;

procedure TMainWindow.lboxMessagesDblClick(Sender: TObject);
var
  item  : TCollectionItem;
  index : Integer;
begin
  item := lboxMessages.Items.FindItemID(SelectedMessage);
  If (Assigned(item)) and
     (FindMessage(TspSkinOfficeItem(item).Title, TspSkinOfficeItem(item).Caption, index)) Then
  Begin
    BrowseURL(Format('http://www.darer.com/%s/messages/read/%d', [UserDetails.Username, UserDetails.Messages.Items[index].UID]));

    If UserDetails.Messages.Items[index].Unread Then
    Begin
      UserDetails.Messages.Items[index].Unread := FALSE;
      ShowMyStats;
    End;
  End;
end;

procedure TMainWindow.tiMyStatsRefreshTimer(Sender: TObject);
begin
  imgRefresh.ImageIndex := 0;
  tiMyStatsRefresh.Enabled := FALSE;
end;

procedure TMainWindow.lbSeeAllMessagesClick(Sender: TObject);
begin
  BrowseURL(Format('http://www.darer.com/%s/messages', [UserDetails.Username]));
end;

procedure TMainWindow.lbMyUsernameClick(Sender: TObject);
begin
  BrowseURL('http://www.darer.com/profile');
end;

procedure TMainWindow.RepairWarcraftIII1Click(Sender: TObject);
begin
  Application.CreateForm(TGameRepairWindow, GameRepairWindow);
  GameRepairWindow.Hashes := GetGameHashes;
  GameRepairWindow.StartAutomatically := TRUE;
  GameRepairWindow.CloseAutomatically := FALSE;
  GameRepairWindow.ShowModal;
end;

procedure TMainWindow.lbSeeAllRequestsClick(Sender: TObject);
begin
  BrowseURL(Format('http://www.darer.com/%s/userequests', [UserDetails.Username]));
end;

procedure TMainWindow.imgRefreshClick(Sender: TObject);
begin
  If (not tiMyStatsRefresh.Enabled) and
     (not tiImgRefreshRotate.Enabled) Then
    tiMyDetailsUpdate.OnTimer(Sender);
end;

procedure TMainWindow.tiImgRefreshRotateTimer(Sender: TObject);
var
  imgIndex : Integer;
begin
  imgIndex := imgRefresh.ImageIndex;
  Inc(imgIndex);

  If imgIndex > ilRefreshIcon.PngImages.Count - 2 Then
  Begin
    imgIndex := 1;
    imgRefresh.Tag := imgRefresh.Tag + 1;

    If (tiImgRefreshRotate.Tag = 1) or
       (imgRefresh.Tag = 20) Then // 20 spins
    Begin
      tiImgRefreshRotate.Tag := 0;
      imgRefresh.Tag := 0;
      tiImgRefreshRotate.Enabled := FALSE;
      imgIndex := ilRefreshIcon.PngImages.Count - 1;
    End;
  End;

  imgRefresh.ImageIndex := imgIndex;
end;

procedure TMainWindow.OnClick_Update(Sender : TObject);
begin
  LoginWindow.frLogin.ebUsername.Text := UserDetails.EMail;
  LoginWindow.frLogin.ebPassword.Text := UserDetails.Password;
  LoginWindow.AutoLoginUpdate := TRUE;
  ComponentModuleWindow.pmLogoutClick(Sender);
end;

procedure TMainWindow.lboxNotificationsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  itemindex : Integer;
begin
  Case Button of
    mbRight, mbLeft : Begin
                        If TspSkinOfficeListBox(Sender).ItemAtPos(X, Y) = -1 Then
                          SelectedRequest := -1
                        else
                        Begin
                          itemindex := TspSkinOfficeListBox(Sender).ItemAtPos(X, Y);
                          TspSkinOfficeListBox(Sender).ItemIndex := itemindex;
                          SelectedRequest := TspSkinOfficeListBox(Sender).Items[itemindex].ID;
                        End;
                      End;
  End;
end;

procedure TMainWindow.lboxNotificationsDblClick(Sender: TObject);
var
  item  : TCollectionItem;
  index : Integer;
  C1    : Integer;
begin
  item := lboxNotifications.Items.FindItemID(SelectedRequest);
  If (Assigned(item)) and
     (FindRequest(TspSkinOfficeItem(item).Title, TspSkinOfficeItem(item).Caption, index)) Then
  Begin
    Case UserDetails.Requests.Items[index].RequestType of
      rtFriend : Begin
                   For C1 := 0 to UserDetails.FriendRequests_Names.Count - 1 Do
                     If UserDetails.FriendRequests_Names.Strings[C1] = UserDetails.Requests.Items[index].Username Then
                     Begin
                       Application.CreateForm(TFriendRequestWindow, FriendRequestWindow);
                       FriendRequestWindow.SetRequestID(C1);
                       FriendRequestWindow.ShowModal;
                       FriendRequestWindow := nil;
                       Break;
                     End;
                 End;
    else
      lbSeeAllRequests.OnClick(Sender);
    End;
  End;
end;

procedure TMainWindow.httpQuickAPIRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  respType : Char;
  respCode : Integer;
  JSON     : ISuperObject;
  response : WideString;
  respChat : String;
begin
  If ErrCode <> 0 Then
  else
    If THTTPCli(Sender).StatusCode <> 200 Then
    else
      If THTTPCli(Sender).RcvdCount > 0 Then
      Begin
        THTTPCli(Sender).RcvdStream.Position := 0;
        JSON := TSuperObject.ParseStream(THTTPCli(Sender).RcvdStream, FALSE);
        response := JSON.S['result'];
        JSON := nil;

        If ParseResponse(response, respType, respCode) Then
        Begin
          respChat := TranslateResponse(respType, respCode);
          If respChat <> '' Then
            AddLineToChatTab(cntChat.ActivePage, RS_SERVER_INFO, respChat, STYLE_INFO_SND, STYLE_INFO_MSG);
        End;
      End;
end;

procedure TMainWindow.tiMaphackCodeJoinTimer(Sender: TObject);
begin
  SendMaphackCode;
  tiMaphackCodeJoin.Enabled := FALSE;
end;

procedure TMainWindow.Label1Click(Sender: TObject);
var
  level, currexp, nextexp : Integer;
begin
  level := CalculateLevel(Users.Items[0].Stats.Wins, Users.Items[0].Stats.Losses, currexp, nextexp);
  ShowMessage(IntToStr(level) + ' > ' + IntToStr(currexp) + ' / ' + IntToStr(nextexp));
end;

end.

