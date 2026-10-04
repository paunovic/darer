unit Localization;

interface

uses
  Classes;

var
  RS_EXIT_DARER_TEXT                   : String = 'Are you sure you want to exit Darer ?';
  RS_EXIT_DARER_CAPTION                : String = 'Exit';
  RS_USER_SEARCH                       : String = 'Search users...';
  RS_ADMIN_REQUIRED                    : String = 'Administrator rights required';
  RS_LOGIN                             : String = 'Login';
  RS_STR_REGISTER                      : String = 'Register';
  RS_ADMINLOGIN_WINDOWSPOLICY_ERROR    : String = 'Windows security policy prevents launching processes under accounts with no password set. Please manually relog to %s account and launch Darer';
  RS_LOGIN_CONNECTING                  : String = 'Connecting...';
  RS_STARTING_GPROXY                   : String = 'Starting GProxy...';
  RS_GPROXY_START_ERROR                : String = 'Cannot start GProxy'#13#10'(%s)';
  RS_AUTHENTICATING                    : String = 'Authenticating...';
  RS_CANNOT_RETRIEVE_USERNAME          : String = 'Cannot retrieve username';
  RS_LOGGED_IN                         : String = 'Welcome, %s';
  RS_INVALID_USERNAME                  : String = 'Invalid username';
  RS_INVALID_PASSWORD                  : String = 'Invalid password';
  RS_CHECKING_UPDATES                  : String = 'Checking for updates...';
  RS_CLIENT_UPDATING                   : String = 'Updating...';
  RS_CANNOT_CONNECT_UPDATE             : String = 'Cannot connect to update server';  
  RS_LICENSE_AGREE_TEXT                : String = 'You must agree to user''s licence agreements';
  RS_REGISTRATION                      : String = 'Registration';
  RS_PASSWORD_TOO_SHORT                : String = 'Password too short';
  RS_USER_TOO_SHORT                    : String = 'Username too short';
  RS_REG_CAPTION                       : String = 'Registration';
  RS_COULD_NOT_SEND_EMAIL              : String = 'Could not send E-Mail';
  RS_USERNAME_TAKEN                    : String = 'Username already taken';
  RS_EMAIL_TAKEN                       : String = 'E-Mail already in use';
  RS_INVALID_EMAIL                     : String = 'Invalid E-Mail address';
  RS_PASSWORDS_MISMATCH                : String = 'Passwords mismatch';
  RS_INVALID_CAPTCHA                   : String = 'Invalid CAPTCHA';
  RS_CONTACT_TYPE_BUG                  : String = 'Report a bug';
  RS_CONTACT_TYPE_SUPPORT              : String = 'Contact support';
  RS_SEARCH_FRIENDS                    : String = 'Search friends...';
  RS_PING_TO                           : String = 'Ping to %s : %s ms';
  RS_MY_LATENCY                        : String = 'Your ping : %s ms';
  RS_ONLINE_ADMINS                     : String = 'Admins online: %s';
  RS_NO_ONLINE_ADMINS                  : String = 'There are no admins online';
  RS_AVAILABLE_GAMES                   : String = 'Available games:';
  RS_SELECT_WC3                        : String = 'Select Warcraft III directory';
  RS_BOT_INVALID_PARAMS                : String = 'Invalid parameters';
  RS_ERROR_UNKNOWN_COMMAND             : String = 'Unknown command';
  RS_ERROR_USER_NOT_LOGGED             : String = 'User not logged on';
  RS_GAME_HOSTED                       : String = 'Game hosted';
  RS_GAME_ALREADY_HOSTED               : String = 'Game already hosted';
  RS_GAME_UNHOSTED                     : String = 'Game unhosted';
  RS_GAME_UNHOST                       : String = 'Unhost game';
  RS_GAME_HOST                         : String = 'Host game';
  RS_HOSTING_GAME                      : String = 'Hosting game...';
  RS_UNHOSTING_GAME                    : String = 'Unhosting game...';
  RS_ERROR                             : String = 'Error';
  RS_CHAT_SESSION_HEADER               : String = 'Chat with %s started on %s at %s';
  RS_GAME_FREE                         : String = 'Free';
  RS_GAME_LADDER                       : String = 'Ladder';
  RS_GAME_OPEN                         : String = 'Open';
  RS_GAME_STARTED                      : String = 'Started';
  RS_SERVER_INFO                       : String = 'INFO';
  RS_SERVER_ERROR                      : String = 'ERROR';
  RS_SEARCH_GAMES                      : String = 'Search games...';
  RS_REMOVE_FROM_FRIENDS               : String = 'Remove from friends';
  RS_ADD_TO_FRIENDS                    : String = 'Add to friends';
  RS_GAMETYPE_FREE                     : String = 'Free';
  RS_GAMETYPE_LADDER                   : String = 'Ladder';
  RS_GAMETYPE_CHALLENGE                : String = 'Challenge';
  RS_CHAN_ADD_TO_FAVS                  : String = 'Add channel to favorites';
  RS_CHAN_REMOVE_FROM_FAVS             : String = 'Remove channel from favorites';
  RS_CHAN_JOIN                         : String = 'Join';
  RS_CHAN_CREATE                       : String = 'Create';
  RS_CHAN_CAPTION_JOIN                 : String = 'Join channel';
  RS_CHAN_CAPTION_CREATE               : String = 'Create channel';
  RS_GAME_PASSWORD                     : String = 'Game password:';
  RS_CHALLENGE_FEE                     : String = 'Challenge fee:';
  RS_EXIT_INGAME_TEXT                  : String = 'Cannot close client while ingame';
  RS_EXIT_INGAME_CAPTION               : String = 'Exit';
  RS_LOGOUT_INGAME_TEXT                : String = 'Cannot logout while ingame';
  RS_LOGOUT_INGAME_CAPTION             : String = 'Logout';
  RS_TOUR_GAME_STARTS_IN               : String = 'A game from %s starts in';
  RS_TOUR_GAME_HAS_STARTED             : String = 'Game from %s has started! Join now!';
  RS_BLOCK_USER                        : String = 'Block';
  RS_UNBLOCK_USER                      : String = 'Unblock';
  RS_FRIEND_ACCEPTED                   : String = 'User %s accepted your friend request';
  RS_FRIEND_DECLINED                   : String = 'User %s declined your friend request';
  RS_FRIEND_REMOVED                    : String = 'User %s removed you from friendlist';
  RS_FRIEND_NAME                       : String = '%s wants to be friends';
  RS_SERVER_BROADCAST                  : String = 'BROADCAST';
  RS_UNABLE_TO_HOST_GAME               : String = 'Hosting failed (bots may be down)';
  RS_USER_MESSAGES                     : String = 'Messages (%d new)';
  RS_USER_REQUESTS                     : String = 'Pending requests (%d)';
  RS_TIME_YEAR_AGO                     : String = '1 year ago';
  RS_TIME_YEARS_AGO                    : String = '%d years ago';
  RS_TIME_MONTH_AGO                    : String = '1 month ago';
  RS_TIME_MONTHS_AGO                   : String = '%d months ago';
  RS_TIME_DAY_AGO                      : String = '1 day ago';
  RS_TIME_DAYS_AGO                     : String = '%d days ago';
  RS_TIME_HOUR_AGO                     : String = '1 hour ago';
  RS_TIME_HOURS_AGO                    : String = '%d hours ago';
  RS_TIME_MINUTE_AGO                   : String = '1 minute ago';
  RS_TIME_MINUTES_AGO                  : String = '%d minutes ago';
  RS_TIME_SECOND_AGO                   : String = '1 second ago';
  RS_TIME_SECONDS_AGO                  : String = '%d seconds ago';
  RS_REPAIR_CHECKING_FILES             : String = 'Checking files (%d%%)';
  RS_REPAIR_REPAIRING_FILES            : String = 'Repairing files (%d%%)';
  RS_REPAIR_ERROR                      : String = 'Error while repairing';
  RS_REPAIR_DONE                       : String = 'Files successfully repaired';
  RS_REPAIR_FILES_MISSING              : String = 'Warcraft III files missing, please repair';
  RS_REPAIR_CLOSE                      : String = 'Close';
  RS_REPAIR_FILES_OK                   : String = 'No need for repair';
  RS_WARCRAFT_PATCHING                 : String = 'Patching Warcraft III (%d%%)';
  RS_WARCRAFT_PATCHING_DONE            : String = 'Patching done';
  RS_WARCRAFT_PATCHING_ERROR           : String = 'Error while patching';
  RS_REPLAY_DOWNLOADING                : String = 'Downloading replay (%d%%)';
  RS_REPLAY_RUNNING                    : String = 'Running replay';
  RS_REPLAY_DOWNLOAD_ERROR             : String = 'Download error';
  RS_REPLAY_PATCH_NOT_FOUND            : String = 'Patch not found';
  RS_UPDATE_DOWNLOADING                : String = 'Downloading update (%d%%)';
  RS_UPDATE_UNABLE_TO_DOWNLOAD         : String = 'Unable to download update';
  RS_UPDATE_INVALID_FILE               : String = 'Invalid update file';
  RS_UPDATE_ERROR_INSTALL              : String = 'Error during installation';
  RS_UPDATE_INSTALLING                 : String = 'Installing update (%d%%)';
  RS_UPDATE_ERROR_DOWNLOAD             : String = 'Error during download';
  RS_UPDATE_AVAILABLE                  : String = 'New client version available';
  RS_UPDATE_NOW                        : String = 'Click here to update now!';
  RS_DOWNLOADING_MAP                   : String = 'Downloading map (%d%%)';
  RS_RESPONSE_UNKNOWN                  : String = 'Unknown response (%s%d)';
  RS_RESPONSE_REGISTER_EMAIL_SENT      : String = 'Registration successful! Please check your inbox for confirmation e-mail';
  RS_RESPONSE_CHANNEL_ADDED            : String = 'Channel added';
  RS_RESPONSE_CHANNEL_PASSWORD_CHANGED : String = 'Channel password changed';
  RS_RESPONSE_REQUEST_SENT             : String = 'Request sent';
  RS_RESPONSE_CONFIRMED_REQUEST        : String = 'Confirmed request';
  RS_RESPONSE_USER_UNBLOCKED           : String = 'Unblocked user';
  RS_RESPONSE_USER_BLOCKED             : String = 'User blocked';
  RS_RESPONSE_COULD_NOT_SEND_EMAIL     : String = 'Could not send an email';
  RS_RESPONSE_USERNAME_TAKEN           : String = 'Username already taken';
  RS_RESPONSE_EMAIL_ALREADY_USED       : String = 'E-Mail already in use';
  RS_RESPONSE_CAPTCHA_ERROR            : String = 'Invalid CAPTCHA';
  RS_RESPONSE_REQ_LIMIT_REACHED        : String = 'Request limit reached';
  RS_RESPONSE_INVALID_KEY              : String = 'Invalid key';
  RS_RESPONSE_INVALID_USERNAME         : String = 'Invalid username';
  RS_RESPONSE_ALREADY_A_FRIEND         : String = 'Already a friend';
  RS_RESPONSE_INVALID_CONFIRMATION     : String = 'Invalid confirmation';
  RS_RESPONSE_INVALID_POSTS            : String = 'Invalid posts';
  RS_RESPONSE_INVALID_USER             : String = 'Invalid user';
  RS_RESPONSE_NOT_CHANNEL_OWNER        : String = 'You''re not owner of the channel';
  RS_RESPONSE_INVALID_USERPASS         : String = 'Invalid username or password';
  RS_RESPONSE_ALREADY_SENT_REQ         : String = 'Request already sent';
  RS_BUTTON_REPAIR                     : String = 'Repair';
  RS_RESPONSE_CHANNEL_RESERVED         : String = 'Channel is reserved';
  RS_RESPONSE_ACCOUNT_NOT_ACTIVATED    : String = 'Account not activated\nPlease check your E-Mail inbox for activation mail';
  RS_GAME_LANGUAGE_ENGLISH             : String = 'English';
  RS_GAME_LANGUAGE_RUSSIAN             : String = 'Russian';
  RS_GAME_LANGUAGE_CHINESE_TRAD        : String = 'Chinese (traditional)';
  RS_ENTER_ADMIN_USERPASS              : String = 'Administrator rights required\nPlease enter administrator username and password';
  RS_PLAYER_LEVEL                      : String = 'Level %d';
  RS_PLAYER_LEVEL_HINT                 : String = '%d/%d experience until next level';
  RS_CHANNEL_NO_ACCESS                 : String = 'You don''t have access to that channel';

type
  TLanguage = record
                Name         : String;
                Path         : String;
                LangFilePath : String;
                FlagResCode  : String;
                Author       : String;
              end;

  TLanguages = record
                 Count : Integer;
                 Items : Array of TLanguage;
               end;

  TCommandsTextItem = record
                        IsCommand     : Boolean;
                        IsHeader      : Boolean;
                        Command, Line : String;
                      end;
  TCommandsText = record
                    Count : Integer;
                    Lines : Array of TCommandsTextItem;
                  end;

var
  Language      : Integer;
  Languages     : TLanguages;
  LanguagesPath : String;
  CommandsText  : TCommandsText;


procedure LanguagesInit;
function GetLanguage : TLanguage;
procedure LocalizeResourceStrings;
procedure LocalizeCommandsText;
function SetLanguage(const ALanguage : Integer) : Boolean; overload;
function SetLanguage(const ALanguage : String) : Boolean; overload;
function Localize(const AComponent : TComponent) : Boolean;
procedure LoadLanguages(ALangDir : String = '');

implementation

uses
  SysUtils, INIFiles, TypInfo, SharedData;

procedure LanguagesInit;
begin
  CommandsText.Count := 0;

  LanguagesPath := SelfPath + ITB('Languages');
  Languages.Count := 0;
  SetLength(Languages.Items, Languages.Count);
  LoadLanguages;
end;

function GetLanguage : TLanguage;
begin
  If (Language >= 0) and (Language < Languages.Count) Then
    result := Languages.Items[Language]
  else
  Begin
    result.Name := '';
    result.Path := '';
    result.LangFilePath := '';
    result.FlagResCode := '';
  End;
end;

function SetLanguage(const ALanguage : Integer) : Boolean;
begin
  result := (Language >= 0) and (Language < Languages.Count);
  If result Then
    Language := ALanguage;
end;

function SetLanguage(const ALanguage : String) : Boolean;
var
  C1 : Integer;
begin
  result := FALSE;
  For C1 := 0 to Languages.Count - 1 Do
    If LowerCase(Languages.Items[C1].Name) = LowerCase(ALanguage) Then
    Begin
      result := SetLanguage(C1);
      Break;
    End;
end;

procedure LoadLanguages(ALangDir : String = '');
var
  SearchRec : TSearchRec;
  IsFound   : Boolean;
  langFile  : String;
  INI       : TINIFile;
begin
  If ALangDir = '' Then
    ALangDir := LanguagesPath;

  IsFound := FindFirst(ALangDir + '*.*', faAnyFile, SearchRec) = 0;
  While IsFound Do
  Begin
    If (SearchRec.Name <> '.') and (SearchRec.Name <> '..') Then
    Begin
      If SearchRec.Attr and faDirectory = faDirectory Then
        LoadLanguages(ITB(ALangDir + SearchRec.Name))
      else
        If LowerCase(ExtractFileExt(SearchRec.Name)) = '.dlf' Then
        Begin
          langFile := ALangDir + SearchRec.Name;
          If FileExists(langFile) Then
          Begin
            Inc(Languages.Count);
            SetLength(Languages.Items, Languages.Count);

            Languages.Items[Languages.Count - 1].Path := ALangDir;
            Languages.Items[Languages.Count - 1].LangFilePath := langFile;

            INI := TINIFile.Create(langFile);
            Languages.Items[Languages.Count - 1].Name := INI.ReadString('info', 'LanguageName', SearchRec.Name);

            Languages.Items[Languages.Count - 1].FlagResCode := INI.ReadString('info', 'CountryCode', '');
            Languages.Items[Languages.Count - 1].Author := INI.ReadString('info', 'Author', '');
            INI.Free;
          End;
        End;
    End;
    IsFound := FindNext(SearchRec) = 0;
  End;
  FindClose(SearchRec);
end;

function PrepareString(const AString : String) : String;
begin
  result := AString;
  result := StringReplace(result, '\n', #13#10, [rfReplaceAll]);
  result := StringReplace(result, '\_', ' ', [rfReplaceAll]);
end;

function Localize(const AComponent : TComponent) : Boolean;
const
  DATASECTION = 'data';
var
  INI      : TINIFile;
  ident    : TStringList;
  values   : TStringList;
  objects  : TStringList;
  C1       : Integer;
  fcomp    : TComponent;
  PropInfo : PPropInfo;
  isHint   : Boolean;
  objStr   : String;
begin
  If Assigned(AComponent) Then
  Begin
    result := TRUE;
    LocalizeResourceStrings;

    If FileExists(GetLanguage.LangFilePath) Then
    Begin
      INI := TINIFile.Create(GetLanguage.LangFilePath);
      If INI.SectionExists(DATASECTION) Then
      Begin
        ident := TStringList.Create;
        values := TStringList.Create;
        INI.ReadSection(DATASECTION, ident);
        INI.ReadSectionValues(DATASECTION, values);
        For C1 := 0 to values.Count - 1 Do
          values.Strings[C1] := Trim(Copy(values.Strings[C1], Pos('=', values.Strings[C1]) + 1, Length(values.Strings[C1]) - Pos('=', values.Strings[C1])));

        objects := TStringList.Create;
        If ident.Count = values.Count Then
          For C1 := 0 to ident.Count - 1 Do
          Begin
            Split('.', ident.Strings[C1], objects);
            If objects.Count > 0 Then
            Begin
              objStr := objects.Strings[0];
              isHint := objStr[1] = '#';
              If isHint Then
                Delete(objStr, 1, 1);

              If LowerCase(objStr) = LowerCase(AComponent.Name) Then
              Begin
                objects.Delete(0);
                fcomp := AComponent;
                While (objects.Count > 0) and
                      (fcomp <> nil) Do
                Begin
                  fcomp := fcomp.FindComponent(objects.Strings[0]);
                  objects.Delete(0);
                End;
                If fcomp <> nil Then
                Begin
                  If isHint Then
                    PropInfo := GetPropInfo(fcomp, 'Hint')
                  else
                  Begin
                    PropInfo := GetPropInfo(fcomp, 'Caption');
                    If PropInfo = nil Then
                      PropInfo := GetPropInfo(fcomp, 'Text');
                  End;
                      
                  If PropInfo <> nil Then
                    SetStrProp(fcomp, PropInfo, PrepareString(values.Strings[C1]));
                End;
              End;  
            End;
          End;
        objects.Free;

        values.Free;
        ident.Free;
      End;
      INI.Free;
    End;
  End
  else
    result := FALSE;
end;

procedure LocalizeResourceStrings;
const
  SECTION = 'strresources';
var
  INI : TINIFile;
begin
  If FileExists(GetLanguage.LangFilePath) Then
  Begin
    INI := TINIFile.Create(GetLanguage.LangFilePath);

    RS_EXIT_DARER_TEXT := PrepareString(INI.ReadString(SECTION, 'RS_EXIT_DARER_TEXT', RS_EXIT_DARER_TEXT));
    RS_EXIT_DARER_CAPTION := PrepareString(INI.ReadString(SECTION, 'RS_EXIT_DARER_CAPTION', RS_EXIT_DARER_CAPTION));
    RS_USER_SEARCH := PrepareString(INI.ReadString(SECTION, 'RS_USER_SEARCH', RS_USER_SEARCH));
    RS_ADMIN_REQUIRED  := PrepareString(INI.ReadString(SECTION, 'RS_ADMIN_REQUIRED', RS_ADMIN_REQUIRED));
    RS_LOGIN := PrepareString(INI.ReadString(SECTION, 'RS_LOGIN', RS_LOGIN));
    RS_STR_REGISTER := PrepareString(INI.ReadString(SECTION, 'RS_STR_REGISTER', RS_STR_REGISTER));
    RS_ADMINLOGIN_WINDOWSPOLICY_ERROR := PrepareString(INI.ReadString(SECTION, 'RS_ADMINLOGIN_WINDOWSPOLICY_ERROR', RS_ADMINLOGIN_WINDOWSPOLICY_ERROR));
    RS_LOGIN_CONNECTING := PrepareString(INI.ReadString(SECTION, 'RS_LOGIN_CONNECTING', RS_LOGIN_CONNECTING));
    RS_STARTING_GPROXY := PrepareString(INI.ReadString(SECTION, 'RS_STARTING_GPROXY', RS_STARTING_GPROXY));
    RS_GPROXY_START_ERROR := PrepareString(INI.ReadString(SECTION, 'RS_GPROXY_START_ERROR', RS_GPROXY_START_ERROR));
    RS_AUTHENTICATING := PrepareString(INI.ReadString(SECTION, 'RS_AUTHENTICATING', RS_AUTHENTICATING));
    RS_CANNOT_RETRIEVE_USERNAME := PrepareString(INI.ReadString(SECTION, 'RS_CANNOT_RETRIEVE_USERNAME', RS_CANNOT_RETRIEVE_USERNAME));
    RS_LOGGED_IN := PrepareString(INI.ReadString(SECTION, 'RS_LOGGED_IN', RS_LOGGED_IN));
    RS_INVALID_USERNAME := PrepareString(INI.ReadString(SECTION, 'RS_INVALID_USERNAME', RS_INVALID_USERNAME));
    RS_INVALID_PASSWORD := PrepareString(INI.ReadString(SECTION, 'RS_INVALID_PASSWORD', RS_INVALID_PASSWORD));
    RS_CHECKING_UPDATES := PrepareString(INI.ReadString(SECTION, 'RS_CHECKING_UPDATES', RS_CHECKING_UPDATES));
    RS_CLIENT_UPDATING := PrepareString(INI.ReadString(SECTION, 'RS_CLIENT_UPDATING', RS_CLIENT_UPDATING));
    RS_CANNOT_CONNECT_UPDATE := PrepareString(INI.ReadString(SECTION, 'RS_CANNOT_CONNECT_UPDATE', RS_CANNOT_CONNECT_UPDATE));
    RS_LICENSE_AGREE_TEXT := PrepareString(INI.ReadString(SECTION, 'RS_LICENSE_AGREE_TEXT', RS_LICENSE_AGREE_TEXT));
    RS_REGISTRATION := PrepareString(INI.ReadString(SECTION, 'RS_REGISTRATION', RS_REGISTRATION));
    RS_PASSWORD_TOO_SHORT := PrepareString(INI.ReadString(SECTION, 'RS_PASSWORD_TOO_SHORT', RS_PASSWORD_TOO_SHORT));
    RS_USER_TOO_SHORT := PrepareString(INI.ReadString(SECTION, 'RS_USER_TOO_SHORT', RS_USER_TOO_SHORT));
    RS_REG_CAPTION := PrepareString(INI.ReadString(SECTION, 'RS_REG_CAPTION', RS_REG_CAPTION));
    RS_COULD_NOT_SEND_EMAIL := PrepareString(INI.ReadString(SECTION, 'RS_COULD_NOT_SEND_EMAIL', RS_COULD_NOT_SEND_EMAIL));
    RS_USERNAME_TAKEN := PrepareString(INI.ReadString(SECTION, 'RS_USERNAME_TAKEN', RS_USERNAME_TAKEN));
    RS_EMAIL_TAKEN := PrepareString(INI.ReadString(SECTION, 'RS_EMAIL_TAKEN', RS_EMAIL_TAKEN));
    RS_INVALID_EMAIL := PrepareString(INI.ReadString(SECTION, 'RS_INVALID_EMAIL', RS_INVALID_EMAIL));
    RS_PASSWORDS_MISMATCH := PrepareString(INI.ReadString(SECTION, 'RS_PASSWORDS_MISMATCH', RS_PASSWORDS_MISMATCH));
    RS_INVALID_CAPTCHA := PrepareString(INI.ReadString(SECTION, 'RS_INVALID_CAPTCHA', RS_INVALID_CAPTCHA));
    RS_CONTACT_TYPE_BUG := PrepareString(INI.ReadString(SECTION, 'RS_CONTACT_TYPE_BUG', RS_CONTACT_TYPE_BUG));
    RS_CONTACT_TYPE_SUPPORT := PrepareString(INI.ReadString(SECTION, 'RS_CONTACT_TYPE_SUPPORT', RS_CONTACT_TYPE_SUPPORT));
    RS_SEARCH_FRIENDS := PrepareString(INI.ReadString(SECTION, 'RS_SEARCH_FRIENDS', RS_SEARCH_FRIENDS));
    RS_PING_TO := PrepareString(INI.ReadString(SECTION, 'RS_PING_TO', RS_PING_TO));
    RS_MY_LATENCY := PrepareString(INI.ReadString(SECTION, 'RS_MY_LATENCY', RS_MY_LATENCY));
    RS_ONLINE_ADMINS := PrepareString(INI.ReadString(SECTION, 'RS_ONLINE_ADMINS', RS_ONLINE_ADMINS));
    RS_NO_ONLINE_ADMINS := PrepareString(INI.ReadString(SECTION, 'RS_NO_ONLINE_ADMINS', RS_NO_ONLINE_ADMINS));
    RS_AVAILABLE_GAMES := PrepareString(INI.ReadString(SECTION, 'RS_AVAILABLE_GAMES', RS_AVAILABLE_GAMES));
    RS_SELECT_WC3 := PrepareString(INI.ReadString(SECTION, 'RS_SELECT_WC3', RS_SELECT_WC3));
    RS_BOT_INVALID_PARAMS := PrepareString(INI.ReadString(SECTION, 'RS_BOT_INVALID_PARAMS', RS_BOT_INVALID_PARAMS));
    RS_SERVER_ERROR := PrepareString(INI.ReadString(SECTION, 'RS_SERVER_ERROR', RS_SERVER_ERROR));
    RS_ERROR_UNKNOWN_COMMAND := PrepareString(INI.ReadString(SECTION, 'RS_ERROR_UNKNOWN_COMMAND', RS_ERROR_UNKNOWN_COMMAND));
    RS_ERROR_USER_NOT_LOGGED := PrepareString(INI.ReadString(SECTION, 'RS_ERROR_USER_NOT_LOGGED', RS_ERROR_USER_NOT_LOGGED));
    RS_GAME_HOSTED := PrepareString(INI.ReadString(SECTION, 'RS_GAME_HOSTED', RS_GAME_HOSTED));
    RS_GAME_ALREADY_HOSTED := PrepareString(INI.ReadString(SECTION, 'RS_GAME_ALREADY_HOSTED', RS_GAME_ALREADY_HOSTED));
    RS_GAME_UNHOSTED := PrepareString(INI.ReadString(SECTION, 'RS_GAME_UNHOSTED', RS_GAME_UNHOSTED));
    RS_GAME_UNHOST := PrepareString(INI.ReadString(SECTION, 'RS_GAME_UNHOST', RS_GAME_UNHOST));
    RS_GAME_HOST := PrepareString(INI.ReadString(SECTION, 'RS_GAME_HOST', RS_GAME_HOST));
    RS_ERROR := PrepareString(INI.ReadString(SECTION, 'RS_ERROR', RS_ERROR));
    RS_CHAT_SESSION_HEADER := PrepareString(INI.ReadString(SECTION, 'RS_CHAT_SESSION_HEADER', RS_CHAT_SESSION_HEADER));
    RS_GAME_FREE := PrepareString(INI.ReadString(SECTION, 'RS_GAME_FREE', RS_GAME_FREE));
    RS_GAME_LADDER := PrepareString(INI.ReadString(SECTION, 'RS_GAME_LADDER', RS_GAME_LADDER));
    RS_GAME_OPEN := PrepareString(INI.ReadString(SECTION, 'RS_GAME_OPEN', RS_GAME_OPEN));
    RS_GAME_STARTED := PrepareString(INI.ReadString(SECTION, 'RS_GAME_STARTED', RS_GAME_STARTED));
    RS_SERVER_INFO := PrepareString(INI.ReadString(SECTION, 'RS_SERVER_INFO', RS_SERVER_INFO));
    RS_SEARCH_GAMES := PrepareString(INI.ReadString(SECTION, 'RS_SEARCH_GAMES', RS_SEARCH_GAMES));
    RS_REMOVE_FROM_FRIENDS := PrepareString(INI.ReadString(SECTION, 'RS_REMOVE_FROM_FRIENDS', RS_REMOVE_FROM_FRIENDS));
    RS_ADD_TO_FRIENDS := PrepareString(INI.ReadString(SECTION, 'RS_ADD_TO_FRIENDS', RS_ADD_TO_FRIENDS));
    RS_GAMETYPE_FREE := PrepareString(INI.ReadString(SECTION, 'RS_GAMETYPE_FREE', RS_GAMETYPE_FREE));
    RS_GAMETYPE_LADDER := PrepareString(INI.ReadString(SECTION, 'RS_GAMETYPE_LADDER', RS_GAMETYPE_LADDER));
    RS_GAMETYPE_CHALLENGE := PrepareString(INI.ReadString(SECTION, 'RS_GAMETYPE_CHALLENGE', RS_GAMETYPE_CHALLENGE));
    RS_CHAN_ADD_TO_FAVS := PrepareString(INI.ReadString(SECTION, 'RS_CHAN_ADD_TO_FAVS', RS_CHAN_ADD_TO_FAVS));
    RS_CHAN_REMOVE_FROM_FAVS := PrepareString(INI.ReadString(SECTION, 'RS_CHAN_REMOVE_FROM_FAVS', RS_CHAN_REMOVE_FROM_FAVS));
    RS_CHAN_CAPTION_JOIN := PrepareString(INI.ReadString(SECTION, 'RS_CHAN_CAPTION_JOIN', RS_CHAN_CAPTION_JOIN));
    RS_CHAN_CAPTION_CREATE := PrepareString(INI.ReadString(SECTION, 'RS_CHAN_CAPTION_CREATE', RS_CHAN_CAPTION_CREATE));
    RS_GAME_PASSWORD := PrepareString(INI.ReadString(SECTION, 'RS_GAME_PASSWORD', RS_GAME_PASSWORD));
    RS_CHALLENGE_FEE := PrepareString(INI.ReadString(SECTION, 'RS_CHALLENGE_FEE', RS_CHALLENGE_FEE));
    RS_EXIT_INGAME_TEXT := PrepareString(INI.ReadString(SECTION, 'RS_EXIT_INGAME_TEXT', RS_EXIT_INGAME_TEXT));
    RS_EXIT_INGAME_CAPTION := PrepareString(INI.ReadString(SECTION, 'RS_EXIT_INGAME_CAPTION', RS_EXIT_INGAME_CAPTION));
    RS_LOGOUT_INGAME_TEXT := PrepareString(INI.ReadString(SECTION, 'RS_LOGOUT_INGAME_TEXT', RS_LOGOUT_INGAME_TEXT));
    RS_LOGOUT_INGAME_CAPTION := PrepareString(INI.ReadString(SECTION, 'RS_LOGOUT_INGAME_CAPTION', RS_LOGOUT_INGAME_CAPTION));
    RS_TOUR_GAME_STARTS_IN := PrepareString(INI.ReadString(SECTION, 'RS_TOUR_GAME_STARTS_IN', RS_TOUR_GAME_STARTS_IN));
    RS_TOUR_GAME_HAS_STARTED := PrepareString(INI.ReadString(SECTION, 'RS_TOUR_GAME_HAS_STARTED', RS_TOUR_GAME_HAS_STARTED));
    RS_BLOCK_USER := PrepareString(INI.ReadString(SECTION, 'RS_BLOCK_USER', RS_BLOCK_USER));
    RS_UNBLOCK_USER := PrepareString(INI.ReadString(SECTION, 'RS_UNBLOCK_USER', RS_UNBLOCK_USER));
    RS_FRIEND_ACCEPTED := PrepareString(INI.ReadString(SECTION, 'RS_FRIEND_ACCEPTED', RS_FRIEND_ACCEPTED));
    RS_FRIEND_DECLINED := PrepareString(INI.ReadString(SECTION, 'RS_FRIEND_DECLINED', RS_FRIEND_DECLINED));
    RS_FRIEND_REMOVED := PrepareString(INI.ReadString(SECTION, 'RS_FRIEND_REMOVED', RS_FRIEND_REMOVED));
    RS_FRIEND_NAME := PrepareString(INI.ReadString(SECTION, 'RS_FRIEND_NAME', RS_FRIEND_NAME));
    RS_UNABLE_TO_HOST_GAME := PrepareString(INI.ReadString(SECTION, 'RS_UNABLE_TO_HOST_GAME', RS_UNABLE_TO_HOST_GAME));
    RS_CHAN_JOIN := PrepareString(INI.ReadString(SECTION, 'RS_CHAN_JOIN', RS_CHAN_JOIN));
    RS_CHAN_CREATE := PrepareString(INI.ReadString(SECTION, 'RS_CHAN_CREATE', RS_CHAN_CREATE));
    RS_HOSTING_GAME := PrepareString(INI.ReadString(SECTION, 'RS_HOSTING_GAME', RS_HOSTING_GAME));
    RS_UNHOSTING_GAME := PrepareString(INI.ReadString(SECTION, 'RS_UNHOSTING_GAME', RS_UNHOSTING_GAME));
    RS_USER_MESSAGES  := PrepareString(INI.ReadString(SECTION, 'RS_USER_MESSAGES', RS_USER_MESSAGES));
    RS_USER_REQUESTS := PrepareString(INI.ReadString(SECTION, 'RS_USER_REQUESTS', RS_USER_REQUESTS));
    RS_REPAIR_CHECKING_FILES := PrepareString(INI.ReadString(SECTION, 'RS_REPAIR_CHECKING_FILES', RS_REPAIR_CHECKING_FILES));
    RS_REPAIR_REPAIRING_FILES := PrepareString(INI.ReadString(SECTION, 'RS_REPAIR_REPAIRING_FILES', RS_REPAIR_REPAIRING_FILES));
    RS_REPAIR_ERROR := PrepareString(INI.ReadString(SECTION, 'RS_REPAIR_ERROR', RS_REPAIR_ERROR));
    RS_REPAIR_DONE := PrepareString(INI.ReadString(SECTION, 'RS_REPAIR_DONE', RS_REPAIR_DONE));
    RS_REPAIR_FILES_MISSING := PrepareString(INI.ReadString(SECTION, 'RS_REPAIR_FILES_MISSING', RS_REPAIR_FILES_MISSING));
    RS_REPAIR_CLOSE := PrepareString(INI.ReadString(SECTION, 'RS_REPAIR_CLOSE', RS_REPAIR_CLOSE));
    RS_REPAIR_FILES_OK := PrepareString(INI.ReadString(SECTION, 'RS_REPAIR_FILES_OK', RS_REPAIR_FILES_OK));
    RS_REPLAY_DOWNLOADING := PrepareString(INI.ReadString(SECTION, 'RS_REPLAY_DOWNLOADING', RS_REPLAY_DOWNLOADING));
    RS_REPLAY_RUNNING := PrepareString(INI.ReadString(SECTION, 'RS_REPLAY_RUNNING', RS_REPLAY_RUNNING));
    RS_REPLAY_DOWNLOAD_ERROR := PrepareString(INI.ReadString(SECTION, 'RS_REPLAY_DOWNLOAD_ERROR', RS_REPLAY_DOWNLOAD_ERROR));
    RS_REPLAY_PATCH_NOT_FOUND := PrepareString(INI.ReadString(SECTION, 'RS_REPLAY_PATCH_NOT_FOUND', RS_REPLAY_PATCH_NOT_FOUND));
    RS_WARCRAFT_PATCHING := PrepareString(INI.ReadString(SECTION, 'RS_WARCRAFT_PATCHING', RS_WARCRAFT_PATCHING));
    RS_WARCRAFT_PATCHING_DONE := PrepareString(INI.ReadString(SECTION, 'RS_WARCRAFT_PATCHING_DONE', RS_WARCRAFT_PATCHING_DONE));
    RS_WARCRAFT_PATCHING_ERROR := PrepareString(INI.ReadString(SECTION, 'RS_WARCRAFT_PATCHING_ERROR', RS_WARCRAFT_PATCHING_ERROR));
    RS_UPDATE_DOWNLOADING := PrepareString(INI.ReadString(SECTION, 'RS_UPDATE_DOWNLOADING', RS_UPDATE_DOWNLOADING));
    RS_UPDATE_UNABLE_TO_DOWNLOAD := PrepareString(INI.ReadString(SECTION, 'RS_UPDATE_UNABLE_TO_DOWNLOAD', RS_UPDATE_UNABLE_TO_DOWNLOAD));
    RS_UPDATE_INVALID_FILE := PrepareString(INI.ReadString(SECTION, 'RS_UPDATE_INVALID_FILE', RS_UPDATE_INVALID_FILE));
    RS_UPDATE_ERROR_INSTALL := PrepareString(INI.ReadString(SECTION, 'RS_UPDATE_ERROR_INSTALL', RS_UPDATE_ERROR_INSTALL));
    RS_UPDATE_INSTALLING := PrepareString(INI.ReadString(SECTION, 'RS_UPDATE_INSTALLING', RS_UPDATE_INSTALLING));
    RS_UPDATE_ERROR_DOWNLOAD := PrepareString(INI.ReadString(SECTION, 'RS_UPDATE_ERROR_DOWNLOAD', RS_UPDATE_ERROR_DOWNLOAD));
    RS_UPDATE_AVAILABLE := PrepareString(INI.ReadString(SECTION, 'RS_UPDATE_AVAILABLE', RS_UPDATE_AVAILABLE));
    RS_UPDATE_NOW := PrepareString(INI.ReadString(SECTION, 'RS_UPDATE_NOW', RS_UPDATE_NOW));
    RS_DOWNLOADING_MAP := PrepareString(INI.ReadString(SECTION, 'RS_DOWNLOADING_MAP', RS_DOWNLOADING_MAP));
    RS_BUTTON_REPAIR := PrepareString(INI.ReadString(SECTION, 'RS_BUTTON_REPAIR', RS_BUTTON_REPAIR));
    RS_RESPONSE_CHANNEL_RESERVED := PrepareString(INI.ReadString(SECTION, 'RS_RESPONSE_CHANNEL_RESERVED', RS_RESPONSE_CHANNEL_RESERVED));
    RS_RESPONSE_ACCOUNT_NOT_ACTIVATED := PrepareString(INI.ReadString(SECTION, 'RS_RESPONSE_ACCOUNT_NOT_ACTIVATED', RS_RESPONSE_ACCOUNT_NOT_ACTIVATED));
    RS_GAME_LANGUAGE_ENGLISH := PrepareString(INI.ReadString(SECTION, 'RS_GAME_LANGUAGE_ENGLISH', RS_GAME_LANGUAGE_ENGLISH));
    RS_GAME_LANGUAGE_RUSSIAN := PrepareString(INI.ReadString(SECTION, 'RS_GAME_LANGUAGE_RUSSIAN', RS_GAME_LANGUAGE_RUSSIAN));
    RS_GAME_LANGUAGE_CHINESE_TRAD := PrepareString(INI.ReadString(SECTION, 'RS_GAME_LANGUAGE_CHINESE_TRAD', RS_GAME_LANGUAGE_CHINESE_TRAD));
    RS_ENTER_ADMIN_USERPASS := PrepareString(INI.ReadString(SECTION, 'RS_ENTER_ADMIN_USERPASS', RS_ENTER_ADMIN_USERPASS));
    RS_PLAYER_LEVEL := PrepareString(INI.ReadString(SECTION, 'RS_PLAYER_LEVEL', RS_PLAYER_LEVEL));
    RS_PLAYER_LEVEL_HINT := PrepareString(INI.ReadString(SECTION, 'RS_PLAYER_LEVEL_HINT', RS_PLAYER_LEVEL_HINT));
    RS_CHANNEL_NO_ACCESS := PrepareString(INI.ReadString(SECTION, 'RS_CHANNEL_NO_ACCESS', RS_CHANNEL_NO_ACCESS));

    INI.Free;
  End;
end;

procedure LocalizeCommandsText;
const
  SECTION = 'commandstext';
var
  INI            : TINIFile;
  idents, values : TStringList;
  C1             : Integer;
  tmpstr         : String;
begin
  If FileExists(GetLanguage.LangFilePath) Then
  Begin
    INI := TINIFile.Create(GetLanguage.LangFilePath);

    idents := TStringList.Create;
    values := TStringList.Create;
    INI.ReadSection(SECTION, idents);
    INI.ReadSectionValues(SECTION, values);
    For C1 := 0 to values.Count - 1 Do
    Begin
      tmpstr := values[C1];
      Delete(tmpstr, 1, Pos('=', tmpstr));
      values[C1] := tmpstr;
    End;

    CommandsText.Count := 0;
    SetLength(CommandsText.Lines, CommandsText.Count);
    C1 := 0;
    While C1 < idents.Count Do
    Begin
      Inc(CommandsText.Count);
      SetLength(CommandsText.Lines, CommandsText.Count);

      Case idents.Strings[C1][1] of
        'C' : Begin
                CommandsText.Lines[CommandsText.Count - 1].IsCommand := TRUE;
                CommandsText.Lines[CommandsText.Count - 1].Command := values[C1];
                Inc(C1);
              End;
        'H' : Begin
                CommandsText.Lines[CommandsText.Count - 1].IsHeader := TRUE;
              End;
      End;

      CommandsText.Lines[CommandsText.Count - 1].Line := values[C1];
      Inc(C1);
    End;

    values.Free;
    idents.Free;

    INI.Free;
  End;
end;

end.
