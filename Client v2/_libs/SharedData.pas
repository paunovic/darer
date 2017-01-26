{$I ..\defines.inc}

unit SharedData;

interface

uses
  Windows, SharedVars, Forms, Graphics, Classes, sppngimagelist, OverbyteIcsWndControl, OverbyteIcsHttpProt, StrUtils;

type
  TUserMessage = record
                   UID             : Integer;
                   Username        : String;
                   MessageDateTime,
                   ServerDateTime  : TDateTime;
                   Avatar          : String;
                   Text            : String;
                   Unread          : Boolean;
                 end;

  TUserMessages = record
                    Count : Integer;
                    Items : Array of TUserMessage;
                  end;

  TRequestType  = (rtFriend, rtTeam, rtTournament);
  TUserRequest  = record
                     ReqID            : Integer;
                     FromID           : Integer;
                     Username         : String;
                     MessageDateTime,
                     ServerDateTime   : TDateTime;
                     Text             : String;
                     RequestType      : TRequestType;
                   end;

  TUserRequests = record
                    Count : Integer;
                    Items : Array of TUserRequest;
                  end;

  TUserDetails = record
                   EMail         : String;
                   Key           : String;
                   Server        : String;
                   Username      : String;
                   Password      : String;
                   FirstName     : String;
                   LastName      : String;
                   Sex           : String;
                   Birthday      : String;
                   Country       : String;
                   Avatar        : String;
                   Coins         : Integer;
                   Colored       : Boolean;
                   NativeChannel : String;
                   Level         : Integer;
                   Experience    : Integer;
                   NextLevelExp  : Integer;

                   FriendRequests_IDs       : TStringList;
                   FriendRequests_Names     : TStringList;
                   FriendRequests_Processed : TStringList;

                   Messages : TUserMessages;
                   Requests : TUserRequests;

                   Tour     : record
                                CS, TGID, TD : Integer;
                                TN           : String;
                              end;
                 end;

  TSound = record
             Path    : String;
             Enabled : Boolean;
           end;

  TClientSettings = record
                      CurrentVersion, FullClient : String;
                      AnnouncementText           : String;
                      GProxyHash, GProxyURL      : String;
                      AnnouncementColor          : TColor;
                      MainBanner, UserBanner     : record
                                                     Hash  : String;
                                                     Image : String;
                                                     Link  : String;
                                                   end;
                      AntiMaphack                : Boolean;
                    end;

  TOptions = record
               Client : record
                          MinimizeToSystray,
                          ShowFriendRequests,
                          ShowFriendGameMsgs,
                          ShowFriendOnlineMsgs,
                          ShowPopups,
                          AssociateReplays,
                          GameAutoMinimize     : Boolean;
                          ScrollbackLines      : Integer;
                        end;
               Sounds : record
                          Enabled, SurpressIngame   : Boolean;
                          PM, NewPM, BotPM,
                          FriendOn, FriendOff,
                          LobbyFull,
                          ErrorMessage, Highlighted : TSound;
                        end;
               WC3    : record
                          Path     : String;
                          Exe      : String;
                          Params   : String;
                          Windowed : Boolean;
                          OpenGL   : Boolean;
                          Maximize : Boolean;
                          Language : String;
                        end;

               Customize : record
                             StatusIcons  : Integer;
                             Skin         : String;
                             FadeInEffect : Boolean;
                           end;
             end;


  TUserStats = record
                 Wins       : Integer;
                 Losses     : Integer;
                 Kills      : Integer;
                 LeaveCount : Integer;
                 Rating     : Integer;
                 RatingPro  : Integer;
                 TotalGames : Integer;
                 Title      : String[20];
                 Rank       : Integer;
                 Deaths     : Integer;
                 RatingD    : Double;
               end;

  TAvatarType = (atSmall, atBig);

  TUserAvatar = record
                  ID145, ID35, IDMY : Integer;
                  LastUpdated145,
                  LastUpdated35     : String;
                end;

  TUserInfo = record
                Username       : String[15];
                Country        : String[10];
                Area           : Integer;
                Color          : Boolean;
                Avatar         : String[30];
                IsFriend_PVPGN : Boolean;
                IsFriend_Site  : Boolean;
                IsMyself       : Boolean;
                Coins          : Integer;
                Stats          : TUserStats;
              end;

  TUserStatus = (usOffline, usOnline, usBusy);

  TUsers = record
             Count  : Integer;
             Items  : Array of TUserInfo;
             Avatar : Array of TUserAvatar;
           end;

  TProtectedChannels = record
                         Count : Integer;
                         Items : Array of record
                                   Channel  : String;
                                   Password : String;
                                 end;
                       end;


var
  SelfPath, SelfExe    : String;
  hSingleInstanceMutex : THandle;
  Countries            : TStringList;
  UserDetails          : TUserDetails;
  ProtectedChannels    : TProtectedChannels;
  Options              : TOptions;
  BlockList            : TStringList;
  OthersBlocklist      : TStringList;
  Users                : TUsers;
  ClientSettings       : TClientSettings;
  AuthorHardcode       : String;

{$IFDEF DEBUG}
procedure DbgLn(const AString : String = '');
procedure Dbg(const AString : String; const AIncludeTime : Boolean);
{$ENDIF}

function ExecuteFile(const AFileName, AParameters, ADirectory : String; const AFlags, AType : Integer; var AProcessInfo : TProcessInformation) : Integer;
procedure SetAsMainForm(AForm : TForm);
function GetWC3Path : String;
procedure WMSendString(const AReceiverHandle, ASenderHandle : THandle; const AString : String);
function IsUserAnAdmin : Boolean;
function RunAs(const ADomain, AUsername, APassword, ACommandLine : String; var AProcessInfo : TProcessInformation) : Integer;
procedure CreateInstanceMutex;
procedure DestroyInstanceMutex;
function IsAlphaInstance : Boolean;
procedure Split(const ADelimiter : Char; const AInput : String; const AStrings : TStrings);
function MatchStrings(const AStr1, AStr2 : String; const ACaseSensitive : Boolean) : Boolean;
function IsValidEmail(EMail : String) : Boolean;
function md5File(const AFile : String) : String;
function md5String(const AString : String) : String;
procedure BrowseURL(const URL : String);
function ITB(const AString : String) : String;
function GetPNGDimensions(const AStream : TMemoryStream; var AWidth, AHeight : Integer) : Boolean;
function GetParam(const AString : WideString; const APos : Integer; const ADelimiter : WideChar = ' ') : WideString;
function PSound(const AFile : String) : Boolean; overload;
function PSound(const ASound : TSound) : Boolean; overload;
function IsValidWC3Path : Boolean;
function SetProcPrivileges(const APID : Cardinal; const APrivilege : String) : Integer;
function GetProcessID(const AName : String) : Integer;
procedure httpPostRequest(const AHTTP : THTTPCli; const AURL, AParams : String);
procedure httpGetRequest(const AHTTP : THTTPCli; const AURL : String);
procedure httpFree(const AHTTP : THTTPCli);
function blowfishEncrypt(const AString : String; const AKey : String = CRYPT_PASS) : String;
function blowfishDecrypt(const AString : String; const AKey : String = CRYPT_PASS) : String;
function GetFullPathFromPID(PID : DWORD) : String;
function GetDomainAndUser(APID : DWORD; var ADomainUser : String) : Boolean;
function KillProcess(const APID : DWORD) : Integer;
function GetTextWidth(const AText : String; AFont : TFont) : Integer;
function GetTextHeight(const AText : String; AFont : TFont) : Integer;
function MakeRandomString(const ALength : Integer; const ACharSequence : String = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890') : String;
function EnumerateFiles(const ADir, AMask : String) : Integer;
procedure DeleteDirectory(ADir : String);
function GetTaskBarHeight : Integer;
procedure CalculateTimeDifference(const ANow, AThen : TDateTime; var AYears, AMonths, ADays, AHours, AMinutes, ASeconds : Integer);
function HexToColor(AColor : String) : TColor;
function ExpandEnvString(const ASource : String) : String;
function RegWriteString(AHKEY : HKEY; APath, AValue, AData : String) : DWORD;
function GetWrapLinesNumber(const AWords : TStringList; const AWidth : Integer; const AFont : TFont) : Integer;
function GetMinRating(const ARating : Integer) : Integer;
function GetMaxRating(const ARating : Integer) : Integer;
function GetUserRoom(const ARating : Integer) : Integer;

implementation

uses
  SysUtils, Registry, Messages, ShellAPI, DCPcrypt2, DCPmd5, MMSystem, TlHelp32, DCPblowfish, DCPsha1, PsApi, DateUtils, Dialogs;

{$IFDEF DEBUG}
const
  DEBUG_FILE = 'debug.txt';

procedure DbgLn(const AString : String = '');
var
  TFile : TextFile;
begin
  AssignFile(TFile, DEBUG_FILE);
  If FileExists(DEBUG_FILE) Then
    Append(TFile)
  else
    Rewrite(TFile);

    WriteLn(TFile, TimeToStr(Now), #9#9, AString);

  CloseFile(TFile);
end;

procedure Dbg(const AString : String; const AIncludeTime : Boolean);
var
  TFile : TextFile;
begin
  AssignFile(TFile, DEBUG_FILE);
  If FileExists(DEBUG_FILE) Then
    Append(TFile)
  else
    Rewrite(TFile);

    If AIncludeTime Then
      Write(TFile, TimeToStr(Now), #9#9, AString)
    else
      Write(TFile, AString);

  CloseFile(TFile);
end;
{$ENDIF}

function ExecuteFile(const AFileName, AParameters, ADirectory : String; const AFlags, AType : Integer; var AProcessInfo : TProcessInformation) : Integer;
var
  sInfo : TStartupInfo;
  pInfo : TProcessInformation;
begin
  FillChar(pinfo, SizeOf(TProcessInformation), 0);

  FillChar(sInfo, SizeOf(TStartupInfo), 0);
  With sInfo Do
  Begin
    cb := SizeOf(TStartupInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := AType;
  End;

  If CreateProcess(PChar(AFileName),
                   PChar(AParameters),
                   nil,
                   nil,
                   FALSE,
                   NORMAL_PRIORITY_CLASS or CREATE_NEW_CONSOLE or AFlags,
                   nil,
                   PChar(ADirectory),
                   sInfo,
                   pInfo) Then
  Begin
    result := ERROR_SUCCESS;
    AProcessInfo := pinfo;
  End
  else
    result := GetLastError;
end;

procedure SetAsMainForm(AForm : TForm);
var
  p : pointer;
begin
  p := @Application.MainForm;
  pointer(p^) := AForm;
end;

function GetWC3Path : String;
var
  reg : TRegistry;
begin
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CURRENT_USER;
  If reg.OpenKey('\SOFTWARE\Blizzard Entertainment\Warcraft III', FALSE) Then
  Begin
    result := reg.ReadString('InstallPath');
    If result = '' Then
      result := reg.ReadString('InstallPathX');
    If result = '' Then
      result := ExtractFilePath(reg.ReadString('Program'));
    If result = '' Then
      result := ExtractFilePath(reg.ReadString('ProgramX'));
    reg.CloseKey;
  End
  else
    result := '';
  reg.Free;
end;

procedure WMSendString(const AReceiverHandle, ASenderHandle : THandle; const AString : String);
var
  copyDataStruct : TCopyDataStruct;
begin
  copyDataStruct.dwData := 0;
  copyDataStruct.cbData := Length(AString) + 1;
  copyDataStruct.lpData := PChar(AString);

  SendMessage(AReceiverHandle, WM_COPYDATA, Integer(ASenderHandle), Integer(@copyDataStruct));
end;

function IsUserAnAdmin : Boolean;
const
  SECURITY_NT_AUTHORITY       : TSIDIdentifierAuthority = (Value : (0, 0, 0, 0, 0, 5));
  SECURITY_BUILTIN_DOMAIN_RID = $00000020;
  DOMAIN_ALIAS_RID_ADMINS     = $00000220;
var
  hAccessToken       : THandle;
  ptgGroups          : PTokenGroups;
  dwInfoBufferSize   : DWORD;
  psidAdministrators : PSID;
  C1                 : Integer;
  bSuccess           : BOOL;
begin
 result := FALSE;

 If (OpenThreadToken(GetCurrentThread, TOKEN_QUERY, True, hAccessToken)) or
    ((GetLastError = ERROR_NO_TOKEN) and
     (OpenProcessToken(GetCurrentProcess, TOKEN_QUERY, hAccessToken))) Then
 Begin
   GetMem(ptgGroups, 1024);

   bSuccess := GetTokenInformation(hAccessToken, TokenGroups, ptgGroups, 1024, dwInfoBufferSize);

   CloseHandle(hAccessToken);

   If bSuccess Then
   Begin
     AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 2, SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0, psidAdministrators);

     For C1 := 0 to ptgGroups.GroupCount - 1 Do
       If EqualSid(psidAdministrators, ptgGroups.Groups[C1].Sid) Then
       Begin
         result := TRUE;
         Break;
       End;

     FreeSid(psidAdministrators);
   End;

   FreeMem(ptgGroups);
 End;
end;


//
// Run process as specified user
//
function RunAs(const ADomain, AUsername, APassword, ACommandLine : String; var AProcessInfo : TProcessInformation) : Integer;
const
  LOGON_WITH_PROFILE = $00000001;

  LIB_COUNT = 2;
  LIB_NAMES : Array[0..LIB_COUNT - 1] of String = ('advapi32.dll', 'userenv.dll');
var
  startupInfo     : TStartupInfo;
  hToken          : THandle;
  userProfileC    : Array[0..MAX_PATH] of Char;
  userProfileSize : DWORD;
  WUserProfile,
  WDomain,
  WUsername,
  WPassword,
  WCommandLine    : Array[0..MAX_PATH] of WideChar;
  C1              : Integer;
  LIB_HANDLES     : Array[0..LIB_COUNT - 1] of THandle;

  CreateProcessWithLogonW  : function(lpUsername, lpDomain, lpPassword: LPCWSTR; dwLogonFlags: DWORD; lpApplicationName: LPCWSTR; lpCommandLine: LPWSTR;
                                      dwCreationFlags: DWORD; lpEnvironment: pointer; lpCurrentDirectory: LPCWSTR;  const lpStartupInfo: TStartupInfo;
                                      var lpProcessInformation: PROCESS_INFORMATION): BOOL; stdcall; // external 'advapi32.dll';
  GetUserProfileDirectoryA : function(hToken: THandle; lpProfileDir: pchar; var lpcchSize: dword): longbool; stdcall; // external 'userenv.dll';
//  CreateEnvironmentBlock   : function(var lpEnvironment: pointer; hToken: THandle; bInherit: BOOL): BOOL; stdcall; // external 'userenv.dll';
//  DestroyEnvironmentBlock  : function(lpEnvironment: pointer): BOOL; stdcall; // external 'userenv.dll';
//  LoadUserProfileA         : function(hToken : THandle; var profileInfo : TProfileInfo) : BOOL; stdcall; // external 'userenv.dll';
//  UnloadUserProfile        : function(hToken, HKEY : THandle) : BOOL; stdcall; // external 'userenv.dll';
begin
  result := 0;

  For C1 := 0 to LIB_COUNT - 1 Do
  Begin
    LIB_HANDLES[C1] := LoadLibrary(PChar(LIB_NAMES[C1]));
    If LIB_HANDLES[C1] = 0 Then
    Begin
      result := GetLastError;
      Break;
    End;
  End;

  If result = 0 Then
  Begin
    CreateProcessWithLogonW := GetProcAddress(LIB_HANDLES[0], 'CreateProcessWithLogonW');
    If Assigned(CreateProcessWithLogonW) Then
    Begin
      GetUserProfileDirectoryA := GetProcAddress(LIB_HANDLES[1], 'GetUserProfileDirectoryA');
      If Assigned(GetUserProfileDirectoryA) Then
      Begin
        ZeroMemory(@WDomain, SizeOf(WDomain));
        ZeroMemory(@WUsername, SizeOf(WUsername));
        ZeroMemory(@WPassword, SizeOf(WPassword));
        StringToWideChar(ADomain, WDomain, SizeOf(WDomain));
        StringToWideChar(AUsername, WUsername, SizeOf(WUsername));
        StringToWideChar(APassword, WPassword, SizeOf(WPassword));
        If LogonUserW(WUsername, WDomain, WPassword, LOGON32_LOGON_INTERACTIVE, LOGON32_PROVIDER_DEFAULT, hToken) Then
        Begin
          userProfileSize := SizeOf(userProfileC) div SizeOf(WideChar);
          If GetUserProfileDirectoryA(hToken, @userProfileC[0], userProfileSize) Then
          Begin
            StringToWideChar(StrPas(userProfileC), WUserProfile, userProfileSize);
            StringToWideChar(ACommandLine, WCommandLine, SizeOf(WCommandLine));
            ZeroMemory(@AProcessInfo, SizeOf(TProcessInformation));
            ZeroMemory(@startupInfo, SizeOf(TStartupInfo));
            If not CreateProcessWithLogonW(WUsername, WDomain, WPassword, LOGON_WITH_PROFILE, nil, WCommandLine, CREATE_UNICODE_ENVIRONMENT, nil, WUserProfile, startupInfo, AProcessInfo) Then
              result := GetLastError;
          End
          else
            result := GetLastError;
        End
        else
          result := GetLastError;
      End
      else
        result := GetLastError;
    End
    else
      result := GetLastError;
  End;

  For C1 := 0 to LIB_COUNT - 1 Do
    If LIB_HANDLES[C1] <> 0 Then
      FreeLibrary(LIB_HANDLES[C1]);
end;

procedure CreateInstanceMutex;
begin
  hSingleInstanceMutex := CreateMutex(nil, FALSE, CLIENT_INSTANCEMUTEX);
end;

procedure DestroyInstanceMutex;
begin
  ReleaseMutex(hSingleInstanceMutex);
end;

function IsAlphaInstance : Boolean;
begin
  result := WaitForSingleObject(hSingleInstanceMutex, 0) <> WAIT_TIMEOUT;
end;

procedure Split(const ADelimiter : Char; const AInput : String; const AStrings : TStrings);
begin
  If Assigned(AStrings) Then
  Begin
    AStrings.Clear;
    AStrings.Delimiter := ADelimiter;
    AStrings.DelimitedText := AInput;
  End;
end;

//
// Uporedjuje dva stringa (*, ? wildcardi)
//
function MatchStrings(const AStr1, AStr2 : String; const ACaseSensitive : Boolean) : Boolean;

  function MatchPattern(str1, str2 : PAnsiChar) : Boolean;
  begin
    If StrComp(str2, '*') = 0 Then
      result := TRUE
    else
      If (str1^ = #0) and
         (str2^ <> #0) Then
        result := FALSE
      else
        If str1^ = #0 Then
          result := TRUE
        else
          Case str2^ of
            '*': If MatchPattern(str1, @str2[1]) Then
                   result := TRUE
                 else
                   result := MatchPattern(@str1[1], str2);
            '?': result := MatchPattern(@str1[1], @str2[1]);
          else
            If str1^ = str2^ Then
              result := MatchPattern(@str1[1], @str2[1])
            else
              result := FALSE;
          end;
  end;

begin
  If ACaseSensitive Then
    result := MatchPattern(PAnsiChar(AStr1), PAnsiChar(AStr2)) or
              MatchPattern(PAnsiChar(AStr2), PAnsiChar(AStr1))
  else
    result := MatchPattern(PAnsiChar(LowerCase(AStr1)), PAnsiChar(LowerCase(AStr2))) or
              MatchPattern(PAnsiChar(LowerCase(AStr2)), PAnsiChar(LowerCase(AStr1)));
end;

function IsValidEmail(EMail : String) : Boolean;
const
  atom_chars = [#33..#255] - ['(', ')', '<', '>', '@', ',', ';', ':', '\', '/', '"', '.', '[', ']', #127]; // Valid characters in an "atom"
  quoted_string_chars = [#0..#255] - ['"', #13, '\']; // Valid characters in a "quoted-string"
  letters = ['A'..'Z', 'a'..'z']; // Valid characters in a subdomain
  letters_digits = ['0'..'9', 'A'..'Z', 'a'..'z'];
  subdomain_chars = ['-', '0'..'9', 'A'..'Z', 'a'..'z'];
type
  States = (STATE_BEGIN, STATE_ATOM, STATE_QTEXT, STATE_QCHAR, STATE_QUOTE, STATE_LOCAL_PERIOD, STATE_EXPECTING_SUBDOMAIN, STATE_SUBDOMAIN, STATE_HYPHEN);
var
  State: States;
  i, n, subdomains: integer;
  c: char;
begin
  State := STATE_BEGIN;
  n := Length(email);
  i := 1;
  subdomains := 1;
  while (i <= n) do begin
    c := email[i];
    case State of
    STATE_BEGIN:
      if c in atom_chars then
        State := STATE_ATOM
      else if c = '"' then
        State := STATE_QTEXT
      else
        break;
    STATE_ATOM:
      if c = '@' then
        State := STATE_EXPECTING_SUBDOMAIN
      else if c = '.' then
        State := STATE_LOCAL_PERIOD
      else if not (c in atom_chars) then
        break;
    STATE_QTEXT:
      if c = '\' then
        State := STATE_QCHAR
      else if c = '"' then
        State := STATE_QUOTE
      else if not (c in quoted_string_chars) then
        break;
    STATE_QCHAR:
      State := STATE_QTEXT;
    STATE_QUOTE:
      if c = '@' then
        State := STATE_EXPECTING_SUBDOMAIN
      else if c = '.' then
        State := STATE_LOCAL_PERIOD
      else
        break;
    STATE_LOCAL_PERIOD:
      if c in atom_chars then
        State := STATE_ATOM
      else if c = '"' then
        State := STATE_QTEXT
      else
        break;
    STATE_EXPECTING_SUBDOMAIN:
      if c in letters then
        State := STATE_SUBDOMAIN
      else
        break;
    STATE_SUBDOMAIN:
      if c = '.' then begin
        inc(subdomains);
        State := STATE_EXPECTING_SUBDOMAIN
      end else if c = '-' then
        State := STATE_HYPHEN
      else if not (c in letters_digits) then
        break;
    STATE_HYPHEN:
      if c in letters_digits then
        State := STATE_SUBDOMAIN
      else if c <> '-' then
        break;
    end;
    inc(i);
  end;
  if i <= n then
    Result := False
  else
    Result := (State = STATE_SUBDOMAIN) and (subdomains >= 2);
end;

function md5File(const AFile : String) : String;
const
  BUF_SIZE = 262144;
var
  md5        : TDCP_MD5;
  strmInput  : TFileStream;
  buffer     : Array[0..BUF_SIZE - 1] of Byte;
  bread      : Integer;
  HashDigest : Array of Byte;
  C1         : Integer;
begin
  If FileExists(AFile) Then
  Begin
    md5 := TDCP_MD5.Create(nil);
    md5.Init;

    strmInput := TFileStream.Create(AFile, fmOpenRead or fmShareDenyNone);
    repeat
      bread := strmInput.Read(buffer, BUF_SIZE);
      md5.Update(buffer, bread);
    until bread <> BUF_SIZE;
    strmInput.Free;
    SetLength(HashDigest, md5.HashSize div 8);
    md5.Final(HashDigest[0]);
    result := '';
    For C1 := 0 to Length(HashDigest) - 1 Do
      result := result + IntToHex(HashDigest[C1], 2);
    md5.Burn;
    md5.Free;
  End
  else
    result := '';
end;

function md5String(const AString : String) : String;
var
  md5        : TDCP_MD5;
  HashDigest : Array of Byte;
  C1         : Integer;
begin
  md5 := TDCP_MD5.Create(nil);
  md5.Init;
  md5.UpdateStr(AString);
  SetLength(HashDigest, md5.HashSize div 8);
  md5.Final(HashDigest[0]);
  result := '';
  For C1 := 0 to Length(HashDigest) - 1 Do
    result := result + IntToHex(HashDigest[C1], 2);
  result := LowerCase(result);  
  md5.Burn;
  md5.Free;
end;

procedure BrowseURL(const URL : String);
begin
  If URL <> '' Then
    ShellExecute(0, 'open', PChar(URL), nil, nil, SW_SHOW);
end;

function ITB(const AString : String) : String;
begin
  result := AString;
  If Copy(result, Length(result), 1) <> '\' Then
    result := result + '\';
end;

function GetPNGDimensions(const AStream : TMemoryStream; var AWidth, AHeight : Integer) : Boolean;

  function ReadMWord : Word;
  type
     TMotorolaWord = record
                       Case Byte of
                         0 : (Value : Word);
                         1 : (Byte1, Byte2 : Byte);
                       End;
  var
     MW : TMotorolaWord;
  begin
     AStream.read(MW.Byte2, SizeOf(Byte));
     AStream.read(MW.Byte1, SizeOf(Byte));
     result := MW.Value;
  end;

type
   TPNGSig = Array[0..7] of Byte;
const
   ValidSig : TPNGSig = (137, 80, 78, 71, 13, 10, 26, 10);
var
   Sig : TPNGSig;
   C1  : integer;
begin
   result := FALSE;
   FillChar(Sig, SizeOf(Sig), #0);
   AStream.Read(Sig[0], SizeOf(Sig));
   For C1 := Low(Sig) to High(Sig) Do
     If Sig[C1] <> ValidSig[C1] Then
       Exit;
   AStream.Seek(18, 0);
   AWidth := ReadMWord;
   AStream.Seek(22, 0);
   AHeight := ReadMWord;
   result := TRUE;
end;

function GetParam(const AString : WideString; const APos : Integer; const ADelimiter : WideChar = ' ') : WideString;
var
  tmp  : WideString;
  tpos : Integer;
begin
  tmp := AString;
  tpos := APos;
  While (Pos(ADelimiter, tmp) > 0) and
        (tpos > 0) Do
  Begin
    Delete(tmp, 1, Pos(ADelimiter, tmp));
    While Pos(ADelimiter, tmp) = 1 Do
      Delete(tmp, 1, 1);
    Dec(tpos);
  End;
  If Pos(ADelimiter, tmp) = 0 Then
    tmp := tmp + ADelimiter;
  result := Copy(tmp, 1, Pos(ADelimiter, tmp) - 1);
end;

function PSound(const AFile : String) : Boolean;
var
  sfile : String;
begin
  try
    sfile := AFile;
    If not FileExists(sfile) Then
      sfile := ITB(SelfPath) + SOUND_DIR + sfile;

    PlaySound(PAnsiChar(sfile), 0, SND_ASYNC);
    result := TRUE;
  except
    result := FALSE;
  end;
end;

function PSound(const ASound : TSound) : Boolean;
begin
  If (Options.Sounds.Enabled) and
     (ASound.Enabled) Then
    result := PSound(ASound.Path)
  else
    result := FALSE;
end;

function IsValidWC3Path : Boolean;
begin
  result := DirectoryExists(Options.WC3.Path) and FileExists(Options.WC3.Exe);
end;

function SetProcPrivileges(const APID : Cardinal; const APrivilege : String) : Integer;
var
  hToken  : THandle;
  tkp     : TTokenPrivileges;
  retval  : DWORD;
  ProcHnd : THandle;
begin
  ProcHnd := OpenProcess(PROCESS_ALL_ACCESS, FALSE, APID);
  If (ProcHnd <> 0) and
     (OpenProcessToken(ProcHnd, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken)) Then
  Begin
    LookupPrivilegeValue(nil, PAnsiChar(APrivilege), tkp.Privileges[0].Luid);
    tkp.PrivilegeCount := 1;
    tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
    AdjustTokenPrivileges(hToken, FALSE, tkp, 0, nil, retval);
    result := GetLastError;
    CloseHandle(ProcHnd);
  End
  else
    result := GetLastError;
end;

function GetProcessID(const AName : String) : Integer;
var
  procData   : TProcessEntry32;
  snapHandle : THandle;
begin
  result := 0;

  snapHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);

  If snapHandle <> 0 Then
  Begin
    procData.dwSize := SizeOf(TProcessEntry32);
    If Process32First(snapHandle, procData) Then
    Begin
      If LowerCase(StrPas(procData.szExeFile)) = LowerCase(AName) Then
        result := procData.th32ProcessID
      else
        While Process32Next(snapHandle, procData) Do
          If LowerCase(StrPas(procData.szExeFile)) = LowerCase(AName) Then
          Begin
            result := procData.th32ProcessID;
            Break;
          End;
    End;
    CloseHandle(snapHandle);
  End
end;

procedure httpPostRequest(const AHTTP : THTTPCli; const AURL, AParams : String);
begin
  AHTTP.SendStream := TMemoryStream.Create;
  AHTTP.SendStream.Write(AParams[1], Length(AParams));
  AHTTP.SendStream.Seek(0, 0);
  AHTTP.RcvdStream := TMemoryStream.Create;
  AHTTP.URL := AURL;
  AHTTP.ContentTypePost := 'application/x-www-form-urlencoded';
  AHTTP.PostAsync;
end;

procedure httpGetRequest(const AHTTP : THTTPCli; const AURL : String);
begin
  AHTTP.RcvdStream := TMemoryStream.Create;
  AHTTP.URL := AURL;
  AHTTP.ContentTypePost := 'application/x-www-form-urlencoded';
  AHTTP.GetAsync;
end;

procedure httpFree(const AHTTP : THTTPCli);
begin
  If Assigned(AHTTP) Then
  Begin
    If Assigned(AHTTP.SendStream) Then
    Begin
      AHTTP.SendStream.Free;
      AHTTP.SendStream := nil;
    End;

    If Assigned(AHTTP.RcvdStream) Then
    Begin
      AHTTP.RcvdStream.Free;
      AHTTP.RcvdStream := nil;
    End;
  End;
end;


function blowfishEncrypt(const AString : String; const AKey : String = CRYPT_PASS) : String;
var
  blowfish : TDCP_blowfish;
begin
  blowfish := TDCP_blowfish.Create(nil);
  blowfish.InitStr(AKey, TDCP_sha1);
  result := blowfish.EncryptString(AString);
  blowfish.Burn;
  blowfish.Free;
end;

function blowfishDecrypt(const AString : String; const AKey : String = CRYPT_PASS) : String;
var
  blowfish : TDCP_blowfish;
begin
  blowfish := TDCP_blowfish.Create(nil);
  blowfish.InitStr(AKey, TDCP_sha1);
  result := blowfish.DecryptString(AString);
  blowfish.Burn;
  blowfish.Free;
end;

function GetFullPathFromPID(PID : DWORD) : String;
var
   hProcess : THandle;
   ModName  : Array[0..MAX_PATH - 1] of Char;
begin
  result := '';
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, FALSE, PID);
  If (hProcess <> 0) and
     (GetModuleFileNameEx(hProcess, 0, ModName, MAX_PATH) <> 0) Then
    result := ModName;
  CloseHandle(hProcess);
end;

function GetDomainAndUser(APID : DWORD; var ADomainUser : String) : Boolean;
type
  PTOKEN_USER = ^_TOKEN_USER;
  _TOKEN_USER = record
                  User : TSidAndAttributes;
                end;
var
  hToken        : THandle;
  cbBuf         : Cardinal;
  ptiUser       : PTOKEN_USER;
  snu           : DWORD;
  ProcessHandle : THandle;
  UserSize      : DWORD;
  DomainSize    : DWORD;
  bSuccess      : Boolean;
  tmpUser       : String;
  tmpDomain     : String;
begin
  result := FALSE;

  ProcessHandle := OpenProcess(PROCESS_QUERY_INFORMATION, FALSE, APID);
  If ProcessHandle <> 0 Then
  Begin
    result := OpenProcessToken(ProcessHandle, TOKEN_QUERY, hToken);
    If result Then
    Begin
      bSuccess := GetTokenInformation(hToken, TokenUser, nil, 0, cbBuf);
      ptiUser := nil;
      While (not bSuccess) and
            (GetLastError = ERROR_INSUFFICIENT_BUFFER) Do
      Begin
        ReallocMem(ptiUser, cbBuf);
        bSuccess := GetTokenInformation(hToken, TokenUser, ptiUser, cbBuf, cbBuf);
      End;
      CloseHandle(hToken);

      If not bSuccess Then
      Begin
        result := FALSE;
        Exit;
      End;

      UserSize := 0;
      DomainSize := 0;
      LookupAccountSid(nil, ptiUser.User.Sid, nil, UserSize, nil, DomainSize, snu);
      result := (UserSize <> 0) and (DomainSize <> 0);
      If result Then
      Begin
        SetLength(tmpUser, UserSize);
        SetLength(tmpDomain, DomainSize);
        result := LookupAccountSid(nil, ptiUser.User.Sid, PAnsiChar(tmpUser), UserSize, PAnsiChar(tmpDomain), DomainSize, snu);
        If result Then
          ADomainUser := Trim(tmpDomain) + '\' + Trim(tmpUser);
      End;

      If bSuccess then
        FreeMem(ptiUser);

      CloseHandle(ProcessHandle);
    End;
  End;
end;

function KillProcess(const APID : DWORD) : Integer;
var
  procHandle         : THandle;
begin
  procHandle := OpenProcess(PROCESS_TERMINATE, FALSE, APID);
  If procHandle <> 0 Then
  Begin
    If TerminateProcess(procHandle, 0) Then
      result := ERROR_SUCCESS
    else
      result := GetLastError;
    CloseHandle(procHandle);
  End
  else
    result := GetLastError;
end;

function GetTextWidth(const AText : String; AFont : TFont) : Integer;
var
  bmp : TBitmap;
begin
  bmp := TBitmap.Create;
  try
    Bmp.Canvas.Font := aFont;
    result := bmp.Canvas.TextWidth(AText);
  finally
    bmp.Free;
  end;
end;

function GetTextHeight(const AText : String; AFont : TFont) : Integer;
var
  bmp : TBitmap;
begin
  bmp := TBitmap.Create;
  try
    Bmp.Canvas.Font := aFont;
    result := bmp.Canvas.TextHeight(AText);
  finally
    bmp.Free;
  end;
end;

function MakeRandomString(const ALength : Integer; const ACharSequence : String = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890') : String;
var
  C1 : Integer;
begin
  result := '';

  For C1 := 1 to ALength Do
    result := result + ACharSequence[Random(Length(ACharSequence)) + 1];
end;

function EnumerateFiles(const ADir, AMask : String) : Integer;
var
  SearchRec : TSearchRec;
  IsFound   : Boolean;
begin
  result := 0;
  IsFound := FindFirst(ITB(ADir) + '*.*', faAnyFile, SearchRec) = 0;
  While IsFound Do
  Begin
    If (SearchRec.Name <> '.') and (SearchRec.Name <> '..') Then
    Begin
      If SearchRec.Attr and faDirectory = faDirectory Then
        Inc(result, EnumerateFiles(ITB(ITB(ADir) + SearchRec.Name),  AMask))
      else
        If MatchStrings(AMask, SearchRec.Name, FALSE) Then
          Inc(result);
    End;
    IsFound := FindNext(SearchRec) = 0;
  End;
  FindClose(SearchRec);
end;

procedure DeleteDirectory(ADir : String);
var
  SearchRec : TSearchRec;
  IsFound   : Boolean;
begin
  IsFound := FindFirst(ITB(ADir) + '*.*', faAnyFile, SearchRec) = 0;
  While IsFound Do
  Begin
    If (SearchRec.Name <> '.') and (SearchRec.Name <> '..') Then
    Begin
      If SearchRec.Attr and faDirectory = faDirectory Then
        DeleteDirectory(ITB(ITB(ADir) + SearchRec.Name))
      else
      Begin
        DeleteFile(ITB(ADir) + SearchRec.Name);
      End;
    End;
    IsFound := FindNext(SearchRec) = 0;
  End;
  RemoveDir(ADir);
  FindClose(SearchRec);
end;

function GetTaskBarHeight : Integer;
var
  hTB    : HWND;
  TBRect : TRect;
begin
  hTB := FindWindow('Shell_TrayWnd', '');
  If hTB = 0 Then
    result := 0
  else
  begin
    GetWindowRect(hTB, TBRect);
    result := TBRect.Bottom - TBRect.Top;
  end;
end;

procedure CalculateTimeDifference(const ANow, AThen : TDateTime; var AYears, AMonths, ADays, AHours, AMinutes, ASeconds : Integer);
const
  SECONDS_IN_MINUTE = 60;
  SECONDS_IN_HOUR   = SECONDS_IN_MINUTE * 60;
  SECONDS_IN_DAY    = SECONDS_IN_HOUR * 24;
  SECONDS_IN_MONTH  = SECONDS_IN_DAY * 30;
  SECONDS_IN_YEAR   = SECONDS_IN_MONTH * 12;
var
  seconds : Double;
begin
  seconds := DaySpan(ANow, AThen) * SECONDS_IN_DAY;

  AYears := Trunc(seconds / SECONDS_IN_YEAR);
  seconds := seconds - AYears * SECONDS_IN_YEAR;

  AMonths := Trunc(seconds / SECONDS_IN_MONTH);
  seconds := seconds - AMonths * SECONDS_IN_MONTH;

  ADays := Trunc(seconds / SECONDS_IN_DAY);
  seconds := seconds - ADays * SECONDS_IN_DAY;

  AHours := Trunc(seconds / SECONDS_IN_HOUR);
  seconds := seconds - AHours * SECONDS_IN_HOUR;

  AMinutes := Trunc(seconds / SECONDS_IN_MINUTE);
  seconds := seconds - AMinutes * SECONDS_IN_MINUTE;

  ASeconds := Trunc(seconds);
end;

function HexToColor(AColor : String) : TColor;
begin
  result := RGB(StrToIntDef('$' + Copy(AColor, 1, 2), $FF), StrToIntDef('$' + Copy(AColor, 3, 2), $FF), StrToIntDef('$' + Copy(AColor, 5, 2), $FF));
end;

function ExpandEnvString(const ASource : String) : String;
begin
  result := '';
  If ASource = '' Then
    Exit;

  SetLength(result, MAX_PATH);
  FillChar(result[1], MAX_PATH, 0);
  SetLength(result, ExpandEnvironmentStrings(PAnsiChar(ASource), PAnsiChar(result), MAX_PATH));
  result := String(PAnsiChar(result));
end;

function RegWriteString(AHKEY : HKEY; APath, AValue, AData : String) : DWORD;
var
  hndKey : HKEY;
  val    : PAnsiChar;
begin
  If RegCreateKeyEx(AHKEY, PAnsiChar(APath), 0, nil, REG_OPTION_NON_VOLATILE,
                    KEY_ALL_ACCESS, nil, hndKey, nil) = ERROR_SUCCESS Then
  Begin
    val := PAnsiChar(AValue);
    If val = '' Then
      val := nil;
    RegSetValueEx(hndKey, val, 0, REG_SZ, PAnsiChar(AData), Length(AData));
    RegCloseKey(hndKey);
    result := GetLastError;
  End
  else
    result := GetLastError;
end;

function GetWrapLinesNumber(const AWords : TStringList; const AWidth : Integer; const AFont : TFont) : Integer;
var
  C1   : Integer;
  line : String;
begin
  line := '';
  result := 1;
  C1 := 0;
  While C1 < AWords.Count Do
  Begin
    If line <> '' Then
      line := line + ' ';
    line := line + AWords[C1];

    If GetTextWidth(line, AFont) >= AWidth Then
    Begin
      C1 := C1 - 1;
      Inc(result);
      line := '';
    End;

    Inc(C1);
  End;
end;

function GetMinRating(const ARating : Integer) : Integer;
begin
  result := 0;
{  If ARating >= 1600 Then
    result := 1600;
  If ARating >= 1900 Then
    result := 1900;}
end;

function GetMaxRating(const ARating : Integer) : Integer;
begin
  result := 9999;
end;

function GetUserRoom(const ARating : Integer) : Integer;
begin
  result := 0;
  If ARating >= 1600 Then
    result := 1;
  If ARating >= 1900 Then
    result := 2;
end;

initialization
  SelfPath := ITB(ExtractFilePath(ParamStr(0)));
  SelfExe := ParamStr(0);

  Options.WC3.Exe := Options.WC3.Path + 'war3.exe';
  If not IsValidWC3Path Then
  Begin
    Options.WC3.Path := ITB(GetWC3Path);
    If Options.WC3.Path <> '' Then
      Options.WC3.Exe := Options.WC3.Path + 'war3.exe';
    If not IsValidWC3Path Then
    Begin
      Options.WC3.Path := '';
      Options.WC3.Exe := '';
    End;
  End;

  Countries := TStringList.Create;
  Countries.Clear;

  Blocklist := TStringList.Create;
  Blocklist.Clear;
  Blocklist.Duplicates := dupIgnore;
  Blocklist.Sorted := TRUE;

  OthersBlocklist := TStringList.Create;
  OthersBlocklist.Clear;
  OthersBlocklist.Duplicates := dupIgnore;
  OthersBlocklist.Sorted := TRUE;

  ProtectedChannels.Count := 0;
  SetLength(ProtectedChannels.Items, ProtectedChannels.Count);

  AuthorHardcode := 'Author: Marko Paunovic, paunovic@gmail.com';

end.
