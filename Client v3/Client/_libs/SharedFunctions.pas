unit SharedFunctions;

{$I defines.inc}

interface

uses
  Windows, Forms, SysUtils, ShellAPI, Classes, SharedVars, OverbyteIcsHttpProt, WinSock2,
  IpHlpApi, IpTypes, Graphics, JvGradient, Controls, JvTypes, pngimagelist, SkinCtrls, SkinExCtrls;

function ITB(const AString : String) : String;
function ETB(const AString : String) : String;
procedure SetAsMainForm(AForm : TForm);
function PrepareString(const AString : String) : String;
procedure Split(const ADelimiter : Char; const AInput : String; const AStrings : TStrings);
procedure ShellOpen(const AFileName : String; const AParams : PChar = nil; const ADirectory : PChar = nil);
procedure httpPostRequest(const AHTTP : THTTPCli; const AURL : String; const AParams : String);
procedure httpGetRequest(const AHTTP : THTTPCli; const AURL : String);
procedure httpFree(const AHTTP : THTTPCli);
function TranslateMessage(const AMessage : String; var ATranslatedMessage : String) : Boolean;
function MatchStrings(const AStr1, AStr2 : String; const ACaseSensitive : Boolean) : Boolean;
function GetLocalEncryptionKey : String;
function md5File(const AFile : String) : String;
function md5String(const AString : String) : String;
function ExpandEnvString(const ASource : String) : String;
function GetShortcutTarget(const AShortcut : String) : String;
function DetectWarcraftExe : String;
function EnumerateFiles(const APath, AFilemask : String; const ASearchSubdirs : Boolean; var AFiles : TStringList) : Integer;
function GetNetworkInterfaces(var ANetworkInterfaces : TNetworkInterfaces) : Integer;
function GetUnicastIP(AFirstUnicastAddress : PIP_ADAPTER_UNICAST_ADDRESS) : String;
procedure SaveSettings;
procedure LoadSettings;
procedure StartupInstall;
procedure StartupUninstall;
procedure MSecToTime(AMSec : Int64; var AMinutes, ASeconds : Integer);
function GetFileSize(const AFilePath : String) : DWORD;
function IsFileInUse(const AFilename : String) : Boolean;
function IsUserAnAdmin : Boolean;
function ParamCountEx(const AParams : String) : Integer;
function ParamStrEx(Index : Integer; const AParams : String) : String;
function GetFullPathFromPID(const APID : DWORD) : String;
function SetProcPrivileges(const APID : Cardinal; const APrivilege : String) : Integer;
procedure Dbg(const AString : String);
procedure DbgLn(const AString : String);
function GetTextWidth(const AText : String; AFont : TFont) : Integer;
function CreateGradient(const AOwner : TComponent; const AStyle : TJvGradientStyle; const AFromColor, AToColor : TColor; const AAlign : TAlign) : TJvGradient;
procedure AddDummyImage(const AImageList : TPngImageList);
function ExecuteFile(const AFileName, AParameters, ADirectory : PChar; const AType, AFlags : Integer; var AProcessInfo : TProcessInformation) : Integer; overload;
function ExecuteFile(const AFileName : PChar; AParameters : PChar = nil; ADirectory : PChar = nil; const AType : Integer = SW_SHOW; const AFlags : Integer = 0) : Integer; overload;
function GetReplayType(const AReplayFile : String) : TReplayType;
function OpenReplay(const AReplayFile : String) : Integer;
function OpenReplayEx(const AReplay : String) : Integer;
function InstallURLProtocol : Boolean;
function UninstallURLProtocol : Boolean;
function DownloadFileGUI(const AURL, AFilename : String; const ACaption_Downloading : String = '') : Boolean;
function DownloadFilesGUI(const AURLs, AFilenames, ACaptions_Downloading : TStringList) : Integer;
function MakeRandomStr(const ALength : Integer; const ACharSequence : String = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890') : String;
function CompareTimesAscending(const AArgs : Array of const; const AMinimumTimeSpan : Integer = 0) : Boolean;
function IncPointer(const APointer : pointer; const AValue : Integer) : pointer;
function SetForegroundWindow98(const Wnd: THandle): Boolean;
function IsMinimized(const AHandle : HWND) : Boolean;
function ShellFindExecutable(const AFileName : String) : String;
function IsValidEmail(AEMail : String) : Boolean;
function FindCountryIndex(const ACountry : String) : Integer;
function CopyImage(const ASource : TPngImageList; const AIndex : Integer; const ATarget : TPngImageList; const AName : String) : Integer;
function FindImage(const AImageList : TPngImageList; const AName : String) : Integer;
function ReadNullTerminatedString(const AStream : TMemoryStream) : AnsiString;
function IPToStr(AIPAddr : TInAddr) : String;
function ReadByte(const AStream : TMemoryStream; const AResetPosition : Boolean = TRUE) : Byte;
function ReadWord(const AStream : TMemoryStream; const AResetPosition : Boolean = TRUE) : Word;
function ReadDWORD(const AStream : TMemoryStream; const AResetPosition : Boolean = TRUE) : DWORD;
function RemoveBackslashes(const AString : String) : String;
function IsProcessRunning(const AProcesses : Array of String) : Boolean;
function IsGarenaRunning : Boolean;
function GetProcAddressEx(const ALibName, AProcName : String; out AProcAddress : pointer; const AUnloadLibrary : Boolean = FALSE) : Integer;
function GetParentProcess(const AID : DWORD) : DWORD;
function GetProcessName(const AID : DWORD) : String;
function GetProcessID(const AName : String) : DWORD;
function Encrypt(const AString : String; const AKey : String = CRYPT_KEY; const AIV : String = CRYPT_IV): String;
function Decrypt(const AString : String; const AKey : String = CRYPT_KEY; const AIV : String = CRYPT_IV): String;
function SafeEncode(const AString : String) : String;
procedure AddExceptionToFirewall(Const Caption, Executable: String);
function IsServiceRunning(sMachine, sService: PChar): Boolean;
function SafeASCII(const AString : String) : String;

implementation

uses
  DCPmd5, LocalizationStr, Registry, ShlObj, ActiveX, ComponentContainerUnit,
  Messages, PsApi, TlHelp32, FileDownloadWin, OverbyteIcsHTTPSrv,
  SBSymmetricCrypto, SBHashFunction, SBUtils, SBConstants, SBEncoding, ComObj,
  WinSvc;



function ITB(const AString : String) : String;
begin
  result := AString;
  If Copy(result, Length(result), 1) <> '\' Then
    result := result + '\';
end;

function ETB(const AString : String) : String;
begin
  result := AString;
  If Copy(result, Length(result), 1) = '\' Then
    Delete(result, Length(result), 1);
end;

procedure SetAsMainForm(AForm : TForm);
var
  p : pointer;
begin
  If Assigned(AForm) Then
    DbgLn(Format('SetAsMainForm(%s)', [AForm.Name]));

  p := @Application.MainForm;
  pointer(p^) := AForm;
end;

function PrepareString(const AString : String) : String;
begin
  result := AString;
  result := StringReplace(result, '\n', #13#10, [rfReplaceAll]);
  result := StringReplace(result, '\_', ' ', [rfReplaceAll]);
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

procedure ShellOpen(const AFileName : String; const AParams : PChar = nil; const ADirectory : PChar = nil);
begin
  DbgLn(Format('ShellOpen(%s, %s)', [AFileName, String(AParams)]));

  ShellExecute(0, 'open', PChar(AFileName), AParams, ADirectory, SW_SHOW);
end;

procedure httpPostRequest(const AHTTP : THTTPCli; const AURL : String; const AParams : String);
begin
  DbgLn(Format('httpPostRequest(%s, %s, %s)', [AHTTP.Name, AURL, AParams]));

  AHTTP.SendStream := TStringStream.Create(AParams);
  AHTTP.RcvdStream := TMemoryStream.Create;
  AHTTP.URL := AURL;
  AHTTP.ContentTypePost := 'application/x-www-form-urlencoded';
  AHTTP.PostAsync;
end;

procedure httpGetRequest(const AHTTP : THTTPCli; const AURL : String);
begin
  DbgLn(Format('httpGetRequest(%s, %s)', [AHTTP.Name,AURL]));

  AHTTP.RcvdStream := TMemoryStream.Create;
  AHTTP.URL := AURL;
  AHTTP.ContentTypePost := 'application/x-www-form-urlencoded';
  AHTTP.GetAsync;
end;

procedure httpFree(const AHTTP : THTTPCli);
begin
  If Assigned(AHTTP) Then
  Begin
    DbgLn(Format('httpFree(%s)', [AHTTP.Name]));
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

function IsCodedResponse(const AResponse : String; var AType : Char; var ACode : Integer) : Boolean;
begin
  result := FALSE;
  If Length(AResponse) = 5 Then
  Begin
    AType := AResponse[1];
    ACode := StrToIntDef(Copy(AResponse, 2, 4), 0);

    result := (CharInSet(AType, ['A', 'E'])) and (ACode > 0);
  End;
end;

function TranslateMessage(const AMessage : String; var ATranslatedMessage : String) : Boolean;
var
  msgType : String;
  msgCode : Integer;
  C1      : Char;
begin
  msgType := AMessage;
  msgCode := 0;
  For C1 := '0' to '9' Do
    While Pos(C1, msgType) > 0 Do
    Begin
      msgCode := msgCode * 10 + StrToInt(C1);
      Delete(msgType, Pos(C1, msgType), 1);
    End;

  If msgType = 'ERR' Then
    Case msgCode of
      0001 : ATranslatedMessage := RS_RESPONSE_INVALID_USERPASS;

      1001 : ATranslatedMessage := RS_RESPONSE_NOT_UPDATED;
      1002 : ATranslatedMessage := RS_RESPONSE_NO_SANDBOX_VER;
      1003 : ATranslatedMessage := RS_RESPONSE_INVALID_FILE_DOWNLOAD;
    End;

  result := ATranslatedMessage <> '';
end;


function MatchStrings(const AStr1, AStr2 : String; const ACaseSensitive : Boolean) : Boolean;

  function MatchPattern(str1, str2 : PWideChar) : Boolean;
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
    result := MatchPattern(PWideChar(AStr1), PWideChar(AStr2)) or
              MatchPattern(PWideChar(AStr2), PWideChar(AStr1))
  else
    result := MatchPattern(PWideChar(LowerCase(AStr1)), PWideChar(LowerCase(AStr2))) or
              MatchPattern(PWideChar(LowerCase(AStr2)), PWideChar(LowerCase(AStr1)));
end;

function GetLocalEncryptionKey : String;
const
  KEY_WOW64_32KEY = $0200;
  KEY_WOW64_64KEY = $0100;

  function GetInstallDate(const AAlternateKey : DWORD) : DWORD;
  var
    hndKey : HKEY;
    vSize  : Integer;
  begin
    result := 0;
    If RegOpenKeyEx(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows NT\CurrentVersion', 0, KEY_QUERY_VALUE or AAlternateKey, hndKey) = ERROR_SUCCESS Then
    Begin
      If (RegQueryValueEx(hndKey, 'InstallDate', nil, nil, nil, @vSize) = ERROR_SUCCESS) and
         (vSize = SizeOf(DWORD)) Then
        RegQueryValueEx(hndKey, 'InstallDate', nil, nil, @result, @vSize);
      RegCloseKey(hndKey);
    End;
  end;

var
  res : DWORD;
begin
  DbgLn('GetLocalEncryptionKey()');

  res := GetInstallDate(KEY_WOW64_32KEY);
  If res = 0 Then
    res := GetInstallDate(KEY_WOW64_64KEY);

  If res <> 0 Then
    result := md5String(IntToHex(res, 16))
  else
    result := CRYPT_KEY;
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

function ExpandEnvString(const ASource : String) : String;
begin
  result := '';
  If ASource = '' Then
    Exit;

  SetLength(result, MAX_PATH);
  FillChar(result[1], MAX_PATH, 0);
  SetLength(result, ExpandEnvironmentStrings(PWideChar(ASource), PWideChar(result), MAX_PATH));
  result := String(PWideChar(result));
end;

function GetShortcutTarget(const AShortcut : String) : String;
var
   psl      : IShellLink;
   ppf      : IPersistFile;
   WidePath : Array[0..260] of WideChar;
   Info     : Array[0..MAX_PATH] of Char;
   wfs      : TWin32FindData;
begin
  DbgLn(Format('GetShortcutTarget(%s)', [AShortcut]));

  CoCreateInstance(CLSID_ShellLink, nil, CLSCTX_INPROC_SERVER, IShellLink, psl);
  If psl.QueryInterface(IPersistFile, ppf) = 0 Then
  Begin
    MultiByteToWideChar(CP_ACP, MB_PRECOMPOSED, PAnsiChar(AnsiString(AShortcut)), -1, @WidePath, MAX_PATH);
    ppf.Load(WidePath, STGM_READ);
    psl.GetPath(@info, MAX_PATH, wfs, SLGP_UNCPRIORITY);
    result := info;
  End
  else
    result := '';
end;

function DetectWarcraftExe : String;

  function IsValidDir(const ADirectory : String) : Boolean;
  begin
    result := (ADirectory <> '') and
              (FileExists(ITB(ADirectory) + 'war3.exe')) and
              (DirectoryExists(ITB(ADirectory) + 'replay'));
  end;

  function CheckProcess(const AEntry : TProcessEntry32) : String;
  var
    pPath : String;
  begin
    result := '';
    If StrPas(AEntry.szExeFile) = 'war3.exe' Then
    Begin
      pPath := GetFullPathFromPID(AEntry.th32ProcessID);
      If FileExists(pPath) Then
        result := ExtractFilePath(pPath);
    End;
  end;

  function SearchDirectory(const ADirectory : String) : String;
  var
    shortcutList : TStringList;
    shortcutFile : String;
    C1           : Integer;
    shortcutFileName : String;
  begin
    If DirectoryExists(ADirectory) Then
    Begin
      shortcutList := TStringList.Create;
      shortcutList.Clear;
      shortcutList.Sorted := TRUE;
      EnumerateFiles(ADirectory, '*.lnk', TRUE, shortcutList);
      For C1 := 0 to shortcutList.Count - 1 Do
      Begin
        shortcutFile := GetShortcutTarget(shortcutList.Strings[C1]);
        shortcutFilename := LowerCase(ExtractFilename(shortcutFile));
        If ((shortcutFilename = 'war3.exe') or
            (shortcutFilename = 'frozen throne.exe')) and
           (IsValidDir(ExtractFilePath(shortcutFile))) Then 
        Begin
          result := ExtractFilePath(shortcutFile);
          Break;
        End;
      End;
      shortcutList.Free;
    End;
  end;

  function CheckRegistry : String;
  var
    reg : TRegistry;
  begin
    reg := TRegistry.Create;
    reg.RootKey := HKEY_CURRENT_USER;
    If reg.OpenKey('\SOFTWARE\Blizzard Entertainment\Warcraft III', FALSE) Then
    Begin
      result := reg.ReadString('InstallPath');
      If not IsValidDir(result) Then
        result := reg.ReadString('InstallPathX');
      If not IsValidDir(result) Then
        result := ExtractFilePath(reg.ReadString('Program'));
      If not IsValidDir(result) Then
        result := ExtractFilePath(reg.ReadString('ProgramX'));
      reg.CloseKey;
    End
    else
      result := '';
    reg.Free;
  end;

  function CheckProcesses : String;
  var
    hSnapshot : THandle;
    pEntry    : TProcessEntry32;
  begin
    result := '';
    hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
    pEntry.dwSize := SizeOf(TProcessEntry32);
    If Process32First(hSnapshot, pEntry) Then
    Begin
      result := CheckProcess(pEntry);
      While (not IsValidDir(result)) and
            (Process32Next(hSnapshot, pEntry)) Do
        result := CheckProcess(pEntry);
    End;
    CloseHandle(hSnapshot);
  end;

  function CheckProgramFiles : String;
  var
    dir : String;
  begin
    result := '';
    dir := ExpandEnvString('%ProgramFiles%\Warcraft III');
    If IsValidDir(dir) Then
      result := dir
    else
    Begin
      dir := ExpandEnvString('%ProgramFiles(x86)%\Warcraft III');
      If IsValidDir(dir) Then
        result := dir;
    End;
  end;

begin
  DbgLn('DetectWarcraftExe()');

  result := CheckRegistry;

  If not IsValidDir(result) Then
    result := CheckProcesses;

  If not IsValidDir(result) Then
    result := SearchDirectory(ExpandEnvString('%UserProfile%\Desktop'));

  If not IsValidDir(result) Then
    result := SearchDirectory(ExpandEnvString('%ProgramData%\Microsoft\Windows\Start Menu\Programs'));

  If not IsValidDir(result) Then
    result := CheckProgramFiles;

  If IsValidDir(result) Then
    result := ITB(result) + 'war3.exe';
end;

function EnumerateFiles(const APath, AFilemask : String; const ASearchSubdirs : Boolean; var AFiles : TStringList) : Integer;
var
  SearchRec : TSearchRec;
  IsFound   : Boolean;
begin
  DbgLn(Format('EnumerateFiles(%s, %s, %s)', [APath, AFilemask, BoolToStr(ASearchSubdirs, TRUE)]));

  result := 0;
  IsFound := FindFirst(ITB(APath) + '*.*', faAnyFile, SearchRec) = 0;
  While IsFound Do
  Begin
    If (SearchRec.Name <> '.') and (SearchRec.Name <> '..') Then
    Begin
      If (ASearchSubdirs) and
         (SearchRec.Attr and faDirectory = faDirectory) Then
        Inc(result, EnumerateFiles(ITB(APath) + SearchRec.Name, AFilemask, ASearchSubdirs, AFiles))
      else
        If MatchStrings(ExtractFileExt(SearchRec.Name), AFilemask, FALSE) Then
        Begin
          AFiles.Add(ITB(APath) + SearchRec.Name);
          Inc(result);
        End;
    End;
    IsFound := FindNext(SearchRec) = 0;
  End;
  FindClose(SearchRec);
end;

function GetNetworkInterfaces(var ANetworkInterfaces : TNetworkInterfaces) : Integer;
var
  pAdapterAddresses : PIP_ADAPTER_ADDRESSES;
  Status            : DWORD;
  BufLen            : DWORD;
  C1                : Integer;
  WSAData           : TWSAData;
begin
  DbgLn('GetNetworkInterfaces()');

  For C1 := 0 to ANetworkInterfaces.Count - 1 Do
    If Assigned(ANetworkInterfaces.Items[C1]) Then
      FreeMem(ANetworkInterfaces.Items[C1], SizeOf(IP_ADAPTER_ADDRESSES));

  ANetworkInterfaces.Count := 0;
  SetLength(ANetworkInterfaces.Items, ANetworkInterfaces.Count);

  WSAStartup(MAKEWORD(2, 2), WSAData);

  BufLen := 0;
  Status := GetAdaptersAddresses(0, 0, nil, nil, @BufLen);
  If Status = ERROR_BUFFER_OVERFLOW Then
  Begin
    pAdapterAddresses := AllocMem(BufLen);
    If GetAdaptersAddresses(0, 0, nil, pAdapterAddresses, @BufLen) = ERROR_SUCCESS Then
    Begin
      While Assigned(pAdapterAddresses) Do
      Begin
        If GetUnicastIP(pAdapterAddresses^.FirstUnicastAddress) <> '' Then
        Begin
          Inc(ANetworkInterfaces.Count);
          SetLength(ANetworkInterfaces.Items, ANetworkInterfaces.Count);
          ANetworkInterfaces.Items[ANetworkInterfaces.Count - 1] := AllocMem(SizeOf(IP_ADAPTER_ADDRESSES));
          Move(pAdapterAddresses^, ANetworkInterfaces.Items[ANetworkInterfaces.Count - 1]^, SizeOf(IP_ADAPTER_ADDRESSES));
        End;
        pAdapterAddresses := pAdapterAddresses^.Next;
      End;
    End;
    FreeMem(pAdapterAddresses, BufLen);
  End;

  WSACleanup;

  result := ANetworkInterfaces.Count;
end;

function GetUnicastIP(AFirstUnicastAddress : PIP_ADAPTER_UNICAST_ADDRESS) : String;
var
  addr    : Array[0..MAX_PATH - 1] of Char;
  addrLen : DWORD;
begin
  DbgLn('GetUnicastIP()');

  result := '';
  While Assigned(AFirstUnicastAddress) Do
  Begin
    If AFirstUnicastAddress.Address.lpSockaddr.sa_family = AF_INET Then
    Begin
      addrlen := SizeOf(addr);
      If WSAAddressToString(WinSock2.TSockAddr(AFirstUnicastAddress.Address.lpSockaddr^), AFirstUnicastAddress.Address.iSockaddrLength, nil, addr, addrLen) = ERROR_SUCCESS Then
      Begin
        result := Copy(addr, 0, addrLen - 1);
        Break;
      End;
    End;
    AFirstUnicastAddress := AFirstUnicastAddress.Next;
  End;
end;

procedure SaveSettings;
begin
  DbgLn('SaveSettings()');

  ComponentContainer.Settings.WriteString(SETTINGS_LANGUAGE, Options.LanguageFile);
  ComponentContainer.Settings.WriteString(SETTINGS_WAR3EXE, Options.WarcraftExe);
  ComponentContainer.Settings.WriteString(SETTINGS_USERNAME, Options.Username);
  ComponentContainer.Settings.WriteString(SETTINGS_PASSWORD, Options.Password);
  ComponentContainer.Settings.WriteBoolean(SETTINGS_AUTOLOGIN, Options.AutoLogin);

  ComponentContainer.Settings.WriteBoolean(SETTINGS_STARTUP, Options.StartupWindows);
  If Options.StartupWindows Then
    StartupInstall
  else
    StartupUninstall;

  ComponentContainer.Settings.WriteBoolean(SETTINGS_MINIMIZEONLOGIN, Options.MinimizeOnLogin);
  ComponentContainer.Settings.WriteString(SETTINGS_VERSIONID, Options.VersionId);
  ComponentContainer.Settings.WriteBoolean(SETTINGS_ADMESSAGE, Options.AdMessage);
end;

procedure LoadSettings;
begin
  DbgLn('LoadSettings()');
  
  Options.LanguageFile := ComponentContainer.Settings.ReadString(SETTINGS_LANGUAGE, '');

  Options.WarcraftExe := ComponentContainer.Settings.ReadString(SETTINGS_WAR3EXE, '');
  If not FileExists(Options.WarcraftExe) Then
    Options.WarcraftExe := DetectWarcraftExe;

  Options.Username := ComponentContainer.Settings.ReadString(SETTINGS_USERNAME, '');
  Options.Password := ComponentContainer.Settings.ReadString(SETTINGS_PASSWORD, '');
  Options.AutoLogin := ComponentContainer.Settings.ReadBoolean(SETTINGS_AUTOLOGIN, FALSE);
  Options.StartupWindows := ComponentContainer.Settings.ReadBoolean(SETTINGS_STARTUP, TRUE);
  Options.MinimizeOnLogin := ComponentContainer.Settings.ReadBoolean(SETTINGS_MINIMIZEONLOGIN, TRUE);
  Options.VersionID := ComponentContainer.Settings.ReadString(SETTINGS_VERSIONID, 'dummy');
  If Options.VersionId = '' Then
    Options.VersionId := 'dummy';
  Options.AdMessage := ComponentContainer.Settings.ReadBoolean(SETTINGS_ADMESSAGE, TRUE);
end;

procedure StartupInstall;
var
  reg : TRegistry;
begin
  DbgLn('StartupInstall()');

  reg := TRegistry.Create;
  reg.RootKey := HKEY_CURRENT_USER;
  If reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', TRUE) Then
  Begin
    reg.WriteString('Darer Client', Format('"%s"', [SelfExe]));
    reg.CloseKey;
  End;
end;

procedure StartupUninstall;
var
  reg : TRegistry;
begin
  DbgLn('StartupUninstall()');

  reg := TRegistry.Create;
  reg.RootKey := HKEY_CURRENT_USER;
  If reg.OpenKey('\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', TRUE) Then
  Begin
    reg.DeleteValue('Darer Client');
    reg.CloseKey;
  End;
end;

procedure MSecToTime(AMSec : Int64; var AMinutes, ASeconds : Integer);
begin
  AMinutes := (AMSec div MSecsPerSec) div SecsPerMin;
  ASeconds := (AMSec div MSecsPerSec) - (AMinutes * SecsPerMin)
end;

function GetFileSize(const AFilePath : String) : DWORD;
var
  fHandle : THandle;
  ofstr   : TOfStruct;
begin
  fHandle := OpenFile(PAnsiChar(AnsiString(AFilePath)), ofstr, OF_READ);
  If fHandle = HFILE_ERROR Then
    result := 0
  else
  Begin
    result := Windows.GetFileSize(fHandle, nil);
    CloseHandle(fHandle);
  End;
end;

function IsFileInUse(const AFilename : String) : Boolean;
var
  hFile : THandle;
begin
  DbgLn(Format('IsFileInUse(%s)', [AFilename]));
  
  hFile := CreateFile(PChar(AFileName), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  If hFile <> INVALID_HANDLE_VALUE Then
  Begin
    result := FALSE;
    CloseHandle(hFile);
  End
  else
    result := TRUE;
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
  DbgLn('IsUserAnAdmin()');

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

function GetParamStr(P: PChar; var Param: string): PChar;
var
  i, Len: Integer;
  Start, S, Q: PChar;
begin
  while True do
  begin
    while (P[0] <> #0) and (P[0] <= ' ') do
      P := CharNext(P);
    if (P[0] = '"') and (P[1] = '"') then Inc(P, 2) else Break;
  end;
  Len := 0;
  Start := P;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      P := CharNext(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        Q := CharNext(P);
        Inc(Len, Q - P);
        P := Q;
      end;
      if P[0] <> #0 then
        P := CharNext(P);
    end
    else
    begin
      Q := CharNext(P);
      Inc(Len, Q - P);
      P := Q;
    end;
  end;

  SetLength(Param, Len);

  P := Start;
  S := Pointer(Param);
  i := 0;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      P := CharNext(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        Q := CharNext(P);
        while P < Q do
        begin
          S[i] := P^;
          Inc(P);
          Inc(i);
        end;
      end;
      if P[0] <> #0 then P := CharNext(P);
    end
    else
    begin
      Q := CharNext(P);
      while P < Q do
      begin
        S[i] := P^;
        Inc(P);
        Inc(i);
      end;
    end;
  end;

  Result := P;
end;

function ParamCountEx(const AParams : String) : Integer;
var
  P: PChar;
  S: string;
begin
  Result := 0;
  P := GetParamStr(PChar(AParams), S);
  while True do
  begin
    P := GetParamStr(P, S);
    if S = '' then Break;
    Inc(Result);
  end;
end;

function ParamStrEx(Index : Integer; const AParams : String) : String;
var
  P: PChar;
  Buffer: array[0..260] of Char;
begin
  Result := '';
  if Index = 0 then
    SetString(Result, Buffer, GetModuleFileName(0, Buffer, SizeOf(Buffer)))
  else
  begin
    P := PChar(AParams);
    while True do
    begin
      P := GetParamStr(P, Result);
      if (Index = 0) or (Result = '') then Break;
      Dec(Index);
    end;
  end;
end;

function GetFullPathFromPID(const APID : DWORD) : String;
var
   hProcess : THandle;
   ModName  : Array[0..MAX_PATH - 1] of Char;
begin
  DbgLn(Format('GetFullPathFromPID(%d)', [APID]));

  result := '';
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, FALSE, APID);
  If hProcess <> 0 Then
  Begin
    If GetModuleFileNameEx(hProcess, 0, ModName, MAX_PATH) <> 0 Then
      result := StrPas(ModName);
    CloseHandle(hProcess);
  End;
end;

function SetProcPrivileges(const APID : Cardinal; const APrivilege : String) : Integer;
var
  hToken  : THandle;
  tkp     : TTokenPrivileges;
  retval  : DWORD;
  ProcHnd : THandle;
begin
  DbgLn(Format('SetProcPrivileges(%d, %s)', [APID, APrivilege]));

  ProcHnd := OpenProcess(PROCESS_ALL_ACCESS, FALSE, APID);
  If ProcHnd <> 0 Then
  Begin
    If OpenProcessToken(ProcHnd, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) Then
    Begin
      LookupPrivilegeValue(nil, PWideChar(APrivilege), tkp.Privileges[0].Luid);
      tkp.PrivilegeCount := 1;
      tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
      AdjustTokenPrivileges(hToken, FALSE, tkp, 0, nil, retval);
      result := GetLastError;
    End
    else
      result := GetLastError;

    CloseHandle(ProcHnd);
  End
  else
    result := GetLastError;
end;

procedure Dbg(const AString : String);
const
  DEBUG_FILE = 'debug.txt';
var
  hFile    : THandle;
  DbgStr   : AnsiString;
  bWritten : DWORD;
begin
  {$IFDEF DEBUGSWITCH}
  If not Debug Then
    Exit;

  hFile := CreateFile(PChar(DEBUG_FILE), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
  If hFile <> INVALID_HANDLE_VALUE Then
  Begin
    DbgStr := AnsiString(Format('%s > %s', [DateTimeToStr(Now), AString]));

    SetFilePointer(hFile, 0, nil, FILE_END);
    WriteFile(hFile, DbgStr[1], Length(DbgStr), bWritten, nil);
    CloseHandle(hFile);
  End;
  {$ENDIF}
end;

procedure DbgLn(const AString : String);
begin
  Dbg(AString + #13#10);
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

function CreateGradient(const AOwner : TComponent; const AStyle : TJvGradientStyle; const AFromColor, AToColor : TColor; const AAlign : TAlign) : TJvGradient;
begin
  result := TJvGradient.Create(AOwner);
  result.Parent := TWinControl(AOwner);
  result.Style := AStyle;
  result.StartColor := AFromColor;
  result.EndColor := AToColor;
  result.Align := AAlign;
  result.SendToBack;
end;

procedure AddDummyImage(const AImageList : TPngImageList);
begin
  AImageList.PngImages.Add(TRUE);
end;

function ExecuteFile(const AFileName, AParameters, ADirectory : PChar; const AType, AFlags : Integer; var AProcessInfo : TProcessInformation) : Integer;
var
  sInfo         : TStartupInfo;
  pInfo         : TProcessInformation;
  fname, params : String;
begin
  FillChar(pinfo, SizeOf(TProcessInformation), 0);

  FillChar(sInfo, SizeOf(TStartupInfo), 0);
  With sInfo Do
  Begin
    cb := SizeOf(TStartupInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := AType;
  End;

  fname := AFilename;
  params := AParameters;
  If CreateProcess(nil,
                   PChar(Format('"%s" %s', [fname, params])),
                   nil,
                   nil,
                   FALSE,
                   NORMAL_PRIORITY_CLASS or CREATE_NEW_CONSOLE or AFlags,
                   nil,
                   ADirectory,
                   sInfo,
                   pInfo) Then
  Begin
    result := ERROR_SUCCESS;
    AProcessInfo := pinfo;
  End
  else
    result := GetLastError;
end;

function ExecuteFile(const AFileName : PChar; AParameters : PChar = nil; ADirectory : PChar = nil; const AType : Integer = SW_SHOW; const AFlags : Integer = 0) : Integer; overload;
var
  pInfo : TProcessInformation;
begin
  result := ExecuteFile(AFileName, AParameters, ADirectory, AType, AFlags, pInfo);
end;

function GetReplayType(const AReplayFile : String) : TReplayType;
var
  fileExt : String;
begin
  result := rtUnknown;

  fileExt := LowerCase(ExtractFileExt(AReplayFile));

  If fileExt = '.w3g' Then
    result := rtWarcraft;

  If fileExt = '.sc2replay' Then
    result := rtStarcraft2;
end;

function OpenReplay(const AReplayFile : String) : Integer;
var
  replayType : TReplayType;
begin
  replayType := GetReplayType(AReplayFile);

  Case replayType of
    rtWarcraft   : Begin
                     If ShellFindExecutable(AReplayFile) <> '' Then
                     Begin
                       ShellExecute(0, 'open', PWideChar(AReplayFile), nil, nil, SW_SHOW);
                       result := 0;
                     End
                     else
                       result := 1;
                   End;
    rtStarcraft2 : Begin
                     If ShellFindExecutable(AReplayFile) <> '' Then
                     Begin
                       ShellExecute(0, 'open', PWideChar(AReplayFile), nil, nil, SW_SHOW);
                       result := 0;
                     End
                     else
                       result := 2;
                   End;
  else
    result := 3;
  End;
end;

function OpenReplayEx(const AReplay : String) : Integer;
var
  replayFile : String;
begin
  result := -1;
  replayFile := URLDecode(AReplay);
  If FileExists(replayFile) Then
    result := OpenReplay(replayFile)
  else
  Begin
    replayFile := ITB(SelfPath) + 'replay' + ExtractFileExt(URLDecode(AReplay));
    If DownloadFileGUI(AReplay, replayFile, RS_REPLAY_DOWNLOADING) Then
      result := OpenReplay(replayFile)
  End;
end;

function InstallURLProtocol : Boolean;
var
  reg : TRegistry;
begin
  result := FALSE;
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CLASSES_ROOT;
  If reg.OpenKey('Darer', TRUE) Then
  Begin
    reg.WriteString('URL Protocol', '');
    If reg.OpenKey('shell\open\command', TRUE) Then
    Begin
      reg.WriteString('', Format('"%s" /urlprotocol "%%1" /close', [SelfExe]));
      result := TRUE;
    End;
    reg.CloseKey
  End;
  reg.Free;
end;

function UninstallURLProtocol : Boolean;
var
  reg : TRegistry;
begin
  reg := TRegistry.Create;
  reg.RootKey := HKEY_CLASSES_ROOT;
  reg.DeleteKey('Darer');
  result := not reg.KeyExists('Darer');
  reg.Free;
end;

function DownloadFileGUI(const AURL, AFilename : String; const ACaption_Downloading : String = '') : Boolean;
begin
  Application.CreateForm(TFileDownloadWindow, FileDownloadWindow);
  FileDownloadWindow.thdDownloader.URL.Add(AURL);
  FileDownloadWindow.thdDownloader.Filename.Add(AFilename);
  FileDownloadWindow.thdDownloader.CPT_Downloading.Add(ACaption_Downloading);

  FileDownloadWindow.ShowModal;
  result := FileDownloadWindow.Result = 1;
  FreeAndNil(FileDownloadWindow);
end;

function DownloadFilesGUI(const AURLs, AFilenames, ACaptions_Downloading : TStringList) : Integer;
begin
  Application.CreateForm(TFileDownloadWindow, FileDownloadWindow);
  FileDownloadWindow.thdDownloader.URL.Assign(AURLs);
  FileDownloadWindow.thdDownloader.Filename.Assign(AFilenames);
  FileDownloadWindow.thdDownloader.CPT_Downloading.Assign(ACaptions_Downloading);

  FileDownloadWindow.ShowModal;
  result := FileDownloadWindow.Result;
  FreeAndNil(FileDownloadWindow);
end;


function MakeRandomStr(const ALength : Integer; const ACharSequence : String = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890') : String;
var
  C1 : Integer;
begin
  result := '';

  For C1 := 1 to ALength Do
    result := result + ACharSequence[Random(Length(ACharSequence)) + 1];
end;

function CompareTimesAscending(const AArgs : Array of const; const AMinimumTimeSpan : Integer = 0) : Boolean;
var
  C1 : Integer;
begin
  result := TRUE;
  For C1 := Low(AArgs) to High(AArgs) - 1 Do
    If AArgs[C1].VType = AArgs[C1 + 1].VType Then
      Case AArgs[C1].VType of
        vtInteger : If (AArgs[C1].VInteger > AArgs[C1 + 1].VInteger) or
                       (AArgs[C1 + 1].VInteger - AArgs[C1].VInteger < AMinimumTimeSpan) Then
                    Begin
                      result := FALSE;
                      Break;
                    End;
      End;
end;

function IncPointer(const APointer : pointer; const AValue : Integer) : pointer;
begin
  result := pointer(Integer(APointer) + AValue);
end;

function SetForegroundWindow98(const Wnd: THandle): Boolean;
var
  ForeThreadID, NewThreadID: DWORD;
begin
  if GetForegroundWindow <> Wnd then
  begin
    ForeThreadID := GetWindowThreadProcessId(GetForegroundWindow, nil);
    NewThreadID := GetWindowThreadProcessId(Wnd, nil);
    if ForeThreadID <> NewThreadID then
    begin
      AttachThreadInput(ForeThreadID, NewThreadID, True);
      Result := SetForegroundWindow(Wnd);
      AttachThreadInput(ForeThreadID, NewThreadID, False);
      if Result then
        Result := SetForegroundWindow(Wnd);
    end
    else
      Result := SetForegroundWindow(Wnd);
  end
  else
    Result := True;
end;

function IsMinimized(const AHandle : HWND) : Boolean;
var
  info : WINDOWPLACEMENT;
begin
  info.length := SizeOf(TWindowPlacement);
  GetWindowPlacement(AHandle, @info);
  result := (info.showCmd = SW_SHOWMINIMIZED) or (info.showCmd = SW_SHOWMINNOACTIVE);
end;

function ShellFindExecutable(const AFileName : String) : String;
var
  buffer : Array[0..MAX_PATH - 1] of Char;
begin
  result := '';
  FillChar(buffer, SizeOf(buffer), #0);
  If FindExecutable(PChar(AFileName), '', buffer) > 32 Then
    result := buffer;
end;

function IsValidEmail(AEMail : String) : Boolean;
const
  ATOM_CHARS          = [#33..#255] - ['(', ')', '<', '>', '@', ',', ';', ':', '\', '/', '"', '.', '[', ']', #127]; // Valid characters in an "atom"
  QUOTED_STRING_CHARS = [#0..#255] - ['"', #13, '\']; // Valid characters in a "quoted-string"
  LETTERS             = ['A'..'Z', 'a'..'z']; // Valid characters in a subdomain
  LETTERS_DIGITS      = ['0'..'9', 'A'..'Z', 'a'..'z'];
type
  States = (STATE_BEGIN, STATE_ATOM, STATE_QTEXT, STATE_QCHAR, STATE_QUOTE, STATE_LOCAL_PERIOD, STATE_EXPECTING_SUBDOMAIN, STATE_SUBDOMAIN, STATE_HYPHEN);
var
  State             : States;
  C1, n, subdomains : Integer;
begin
  State := STATE_BEGIN;
  n := Length(AEMail);
  C1 := 1;
  subdomains := 1;
  While (C1 <= n) Do
  Begin
    Case State of
      STATE_BEGIN : If CharInSet(AEMail[C1], ATOM_CHARS) Then
                      State := STATE_ATOM
                    else
                      If AEMail[C1] = '"' Then
                        State := STATE_QTEXT
                      else
                        Break;

      STATE_ATOM  : If AEMail[C1] = '@' Then
                      State := STATE_EXPECTING_SUBDOMAIN
                    else
                      If AEMail[C1] = '.' Then
                        State := STATE_LOCAL_PERIOD
                      else
                        If not CharInSet(AEMail[C1], ATOM_CHARS) Then
                          Break;

      STATE_QTEXT : If AEMail[C1] = '\' Then
                      State := STATE_QCHAR
                    else
                      If AEMail[C1] = '"' Then
                        State := STATE_QUOTE
                      else
                        If not CharInSet(AEMail[C1], QUOTED_STRING_CHARS) Then
                          Break;

      STATE_QCHAR : State := STATE_QTEXT;

      STATE_QUOTE : If AEMail[C1] = '@' Then
                      State := STATE_EXPECTING_SUBDOMAIN
                    else
                      If AEMail[C1] = '.' Then
                        State := STATE_LOCAL_PERIOD
                      else
                        Break;

      STATE_LOCAL_PERIOD : If CharInSet(AEMail[C1], ATOM_CHARS) Then
                             State := STATE_ATOM
                           else
                             If AEMail[C1] = '"' Then
                               State := STATE_QTEXT
                             else
                               Break;
      STATE_EXPECTING_SUBDOMAIN : If CharInSet(AEMail[C1], LETTERS) Then
                                    State := STATE_SUBDOMAIN
                                  else
                                    Break;
      STATE_SUBDOMAIN           : If AEMail[C1] = '.' Then
                                  Begin
                                    Inc(subdomains);
                                    State := STATE_EXPECTING_SUBDOMAIN;
                                  End
                                  else
                                    If AEMail[C1] = '-' Then
                                      State := STATE_HYPHEN
                                    else
                                      If not CharInSet(AEMail[C1], LETTERS_DIGITS) Then
                                        Break;
      STATE_HYPHEN              : If CharInSet(AEMail[C1], LETTERS_DIGITS) Then
                                    State := STATE_SUBDOMAIN
                                  else
                                    If AEMail[C1] <> '-' Then
                                      Break;
    End;
    Inc(C1);
  End;

  If C1 <= n Then
    result := FALSE
  else
    result := (State = STATE_SUBDOMAIN) and (subdomains >= 2);
end;

function FindCountryIndex(const ACountry : String) : Integer;
var
  C1 : Integer;
begin
  DbgLn(Format('FindCountryIndex(%s)', [ACountry]));

  result := -1;
  For C1 := 0 to COUNTRY_LIST_COUNT - 1 Do
    If (COUNTRY_LIST[C1].Name = ACountry) or
       (COUNTRY_LIST[C1].Code = ACountry) Then
    Begin
      result := C1;
      Break;
    End;
end;

function CopyImage(const ASource : TPngImageList; const AIndex : Integer; const ATarget : TPngImageList; const AName : String) : Integer;
begin
  DbgLn(Format('CopyImage(%s, %d -> %s)', [ASource.Name, AIndex, ATarget.Name]));

  result := ATarget.PngImages.Add.Index;
  ATarget.PngImages[result].PngImage.Assign(ASource.PngImages[AIndex].PngImage);
  ATarget.PngImages[result].Name := AName;
end;

function FindImage(const AImageList : TPngImageList; const AName : String) : Integer;
var
  C1 : Integer;
begin
  result := -1;
  For C1 := 0 to AImageList.PngImages.Count - 1 Do
    If AImageList.PngImages[C1].Name = AName Then
    Begin
      result := C1;
      Break;
    End;
end;

function ReadNullTerminatedString(const AStream : TMemoryStream) : AnsiString;
var
  c : AnsiChar;
begin
  result := '';
  repeat
    AStream.Read(c, SizeOf(c));
    result := result + c;
  until (c = #0) or
        (AStream.Position >= AStream.Size);
  result := StrPas(PAnsiChar(result));
end;

function IPToStr(AIPAddr : TInAddr) : String;
begin
  With AIPAddr.S_un_b Do
    result := IntToStr(Ord(s_b1)) + '.' + IntToStr(Ord(s_b2)) + '.' + IntToStr(Ord(s_b3)) + '.' + IntToStr(Ord(s_b4));
end;

function ReadByte(const AStream : TMemoryStream; const AResetPosition : Boolean = TRUE) : Byte;
begin
  AStream.Read(result, SizeOf(result));

  If AResetPosition Then
    AStream.Seek(-SizeOf(result), soFromCurrent);
end;

function ReadWord(const AStream : TMemoryStream; const AResetPosition : Boolean = TRUE) : Word;
begin
  AStream.Read(result, SizeOf(result));

  If AResetPosition Then
    AStream.Seek(-SizeOf(result), soFromCurrent);
end;

function ReadDWORD(const AStream : TMemoryStream; const AResetPosition : Boolean = TRUE) : DWORD;
begin
  AStream.Read(result, SizeOf(result));

  If AResetPosition Then
    AStream.Seek(-SizeOf(result), soFromCurrent);
end;

function RemoveBackslashes(const AString : String) : String;
begin
  result := AString;
  While Pos('\', result) > 0 Do
    Delete(result, Pos('\', result), 1);
  If result = '/' Then
    result := '';
end;

function IsProcessRunning(const AProcesses : Array of String) : Boolean;

  function CheckProcess(const AEntry : TProcessEntry32) : Boolean;
  var
    C1 : Integer;
  begin
    result := FALSE;
    For C1 := Low(AProcesses) to High(AProcesses) Do
        If MatchStrings(StrPas(AEntry.szExeFile), String(AProcesses[C1]), FALSE) Then
        Begin
          result := TRUE;
          Break;
        End;
  end;

  function CheckProcesses : Boolean;
  var
    hSnapshot : THandle;
    pEntry    : TProcessEntry32;
  begin
    result := FALSE;
    hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
    pEntry.dwSize := SizeOf(TProcessEntry32);
    If Process32First(hSnapshot, pEntry) Then
    Begin
      result := CheckProcess(pEntry);
      While (not result) and
            (Process32Next(hSnapshot, pEntry)) Do
        result := CheckProcess(pEntry);
    End;
    CloseHandle(hSnapshot);
  end;

begin
  result := CheckProcesses;
end;

function IsGarenaRunning : Boolean;
begin
  result := IsProcessRunning(['garena_room.exe', 'garena.exe']);
end;

function GetProcAddressEx(const ALibName, AProcName : String; out AProcAddress : pointer; const AUnloadLibrary : Boolean = FALSE) : Integer;
var
  libHandle   : THandle;
  AfterLoaded : Boolean;
begin
  libHandle := GetModuleHandle(PChar(ALibName));
  If libHandle = 0 Then
  Begin
    libHandle := LoadLibrary(PChar(ALibName));
    AfterLoaded := TRUE;
  End
  else
    AfterLoaded := FALSE;

  If libHandle = 0 Then
  Begin
    result := GetLastError;
    Exit;
  End;

  AProcAddress := GetProcAddress(libHandle, PChar(AProcName));

  If Assigned(AProcAddress) Then
  Begin
    result := ERROR_SUCCESS;
    If (AUnloadLibrary) and
       (AfterLoaded) Then
      FreeLibrary(libHandle);
  End
  else
  Begin
    result := GetLastError;
    FreeLibrary(libHandle);
  End;
end;

function GetParentProcess(const AID : DWORD) : DWORD;
var
  hSnapshot : THandle;
  pEntry    : TProcessEntry32;
begin
  result := 0;
  hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
  pEntry.dwSize := SizeOf(TProcessEntry32);
  If Process32First(hSnapshot, pEntry) Then
  Begin
    If pEntry.th32ProcessID = AID Then
      result := pEntry.th32ParentProcessID
    else
      While (result = 0) and
            (Process32Next(hSnapshot, pEntry)) Do
        If pEntry.th32ProcessID = AID Then
          result := pEntry.th32ParentProcessID;
  End;
  CloseHandle(hSnapshot);
end;

function GetProcessName(const AID : DWORD) : String;
var
  hSnapshot : THandle;
  pEntry    : TProcessEntry32;
begin
  result := '';
  hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
  pEntry.dwSize := SizeOf(TProcessEntry32);
  If Process32First(hSnapshot, pEntry) Then
  Begin
    If pEntry.th32ProcessID = AID Then
      result := StrPas(pEntry.szExeFile)
    else
      While (result = '') and
            (Process32Next(hSnapshot, pEntry)) Do
        If pEntry.th32ProcessID = AID Then
          result := StrPas(pEntry.szExeFile);
  End;
  CloseHandle(hSnapshot);
end;

function GetProcessID(const AName : String) : DWORD;
var
  hSnapshot : THandle;
  pEntry    : TProcessEntry32;
begin
  result := 0;
  hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
  pEntry.dwSize := SizeOf(TProcessEntry32);
  If Process32First(hSnapshot, pEntry) Then
  Begin
    If MatchStrings(StrPas(pEntry.szExeFile), AName, FALSE) Then
      result := pEntry.th32ProcessID
    else
      While (result = 0) and
            (Process32Next(hSnapshot, pEntry)) Do
        If MatchStrings(StrPas(pEntry.szExeFile), AName, FALSE) Then
          result := pEntry.th32ProcessID;
  End;
  CloseHandle(hSnapshot);
end;

function GenerateKeyMaterial(const Key, IV: string): TElSymmetricKeyMaterial;
begin
  Result := TElSymmetricKeyMaterial.Create;
  Result.Key := SBUtils.BytesOfString(Key);
  Result.IV := SBUtils.BytesOfString(IV);
end;

function Decrypt(const AString : String; const AKey : String = CRYPT_KEY; const AIV : String = CRYPT_IV): String;
var
  Factory: TElSymmetricCryptoFactory;
  Crypto: TELSymmetricCrypto;
  Bytes: TBytes;
  InBuf, OutBuf: ByteArray;
  OutSize: Integer;
begin
  Factory := TElSymmetricCryptoFactory.Create;
  try
    Crypto := Factory.CreateInstance(SB_ALGORITHM_CNT_AES256, cmECB);
    Crypto.Padding := cpPKCS5;
    Crypto.KeyMaterial := GenerateKeyMaterial(AKey, AIV);

    InBuf := SBEncoding.Base64DecodeArray(AString);

    OutSize := 0;
    Crypto.Decrypt(@InBuf[0], Length(InBuf), nil, OutSize);
    SetLength(OutBuf, OutSize);
    Crypto.Decrypt(@InBuf[0], Length(InBuf), @OutBuf[0], OutSize);

    SetLength(Bytes, OutSize);
    Move(OutBuf[0], Bytes[0], OutSize);

    Result := TEncoding.UTF8.GetString(Bytes);
  finally
    Factory.Free;
  end;
end;

function Encrypt(const AString : String; const AKey : String = CRYPT_KEY; const AIV : String = CRYPT_IV): String;
var
  Factory: TElSymmetricCryptoFactory;
  Crypto: TELSymmetricCrypto;
  Bytes: TBytes;
  InBuf : TBytes;
  FinBuf, OutBuf: ByteArray;
  FinSize, OutSize: Integer;
begin
  Factory := TElSymmetricCryptoFactory.Create;
  try
    Crypto := Factory.CreateInstance(SB_ALGORITHM_CNT_AES256, cmECB);
    Crypto.Padding := cpPKCS5;
    Crypto.KeyMaterial := GenerateKeyMaterial(AKey, AIV);

    InBuf := TEncoding.UTF8.GetBytes(AString);

    OutSize := 0;
    Crypto.Encrypt(@InBuf[0], Length(InBuf), nil, OutSize);
    SetLength(OutBuf, OutSize);
    Crypto.Encrypt(@InBuf[0], Length(InBuf), @OutBuf[0], OutSize);

    SetLength(FinBuf, OutSize * 2);
    SBEncoding.Base64Encode(@OutBuf[0], OutSize, @FinBuf[0], FinSize);

    SetLength(Bytes, Length(FinBuf));
    Move(FinBuf[0], Bytes[0], Length(FinBuf));

    Result := TEncoding.UTF8.GetString(Bytes);
  finally
    Factory.Free;
  end;
end;

function SafeEncode(const AString : String) : String;
begin
  result := StringReplace(AString, '+', '-', [rfReplaceAll]);
  result := StringReplace(result, '/', '_', [rfReplaceAll]);
  result := StringReplace(result, '=', '', [rfReplaceAll]);
end;

procedure AddExceptionToFirewall(Const Caption, Executable: String);
const
  NET_FW_PROFILE2_DOMAIN  = 1;
  NET_FW_PROFILE2_PRIVATE = 2;
  NET_FW_PROFILE2_PUBLIC  = 4;
  NET_FW_IP_PROTOCOL_TCP  = 6;
  NET_FW_ACTION_ALLOW     = 1;
var
  fwPolicy2   : OleVariant;
  RulesObject : OleVariant;
  Profile     : Integer;
  NewRule     : OleVariant;
  objFirewall : OleVariant;
begin
  try
    objFirewall := CreateOleObject('HNetCfg.FwMgr');
    if objFirewall.LocalPolicy.CurrentProfile.FirewallEnabled then
    begin
      Profile             := NET_FW_PROFILE2_PRIVATE OR NET_FW_PROFILE2_PUBLIC;
      fwPolicy2           := CreateOleObject('HNetCfg.FwPolicy2');
      RulesObject         := fwPolicy2.Rules;
      NewRule             := CreateOleObject('HNetCfg.FWRule');
      NewRule.Name        := Caption;
      NewRule.Description := Caption;
      NewRule.Applicationname := Executable;
      NewRule.Protocol := NET_FW_IP_PROTOCOL_TCP;
      NewRule.Enabled := TRUE;
      NewRule.Profiles := Profile;
      NewRule.Action := NET_FW_ACTION_ALLOW;
      RulesObject.Add(NewRule);
    end;
  finally

  end;
end;

function ServiceGetStatus(sMachine, sService: PChar): DWORD;
   {******************************************}
   {*** Parameters: ***}
   {*** sService: specifies the name of the service to open
   {*** sMachine: specifies the name of the target computer
   {*** ***}
   {*** Return Values: ***}
   {*** -1 = Error opening service ***}
   {*** 1 = SERVICE_STOPPED ***}
   {*** 2 = SERVICE_START_PENDING ***}
   {*** 3 = SERVICE_STOP_PENDING ***}
   {*** 4 = SERVICE_RUNNING ***}
   {*** 5 = SERVICE_CONTINUE_PENDING ***}
   {*** 6 = SERVICE_PAUSE_PENDING ***}
   {*** 7 = SERVICE_PAUSED ***}
   {******************************************}
var
   SCManHandle, SvcHandle: SC_Handle;
   SS: TServiceStatus;
   dwStat: DWORD;
begin
   dwStat := 0;
   // Open service manager handle.
   SCManHandle := OpenSCManager(sMachine, nil, SC_MANAGER_CONNECT);
   if (SCManHandle > 0) then
   begin
     SvcHandle := OpenService(SCManHandle, sService, SERVICE_QUERY_STATUS);
     // if Service installed
     if (SvcHandle > 0) then
     begin
       // SS structure holds the service status (TServiceStatus);
       if (QueryServiceStatus(SvcHandle, SS)) then
         dwStat := ss.dwCurrentState;
       CloseServiceHandle(SvcHandle);
     end;
     CloseServiceHandle(SCManHandle);
   end;
   Result := dwStat;
end;

function IsServiceRunning(sMachine, sService: PChar): Boolean;
begin
   Result := SERVICE_RUNNING = ServiceGetStatus(sMachine, sService);
end;

function SafeASCII(const AString : String) : String;
var
  C1 : Integer;
begin
  result := '';
  for C1 := 1 to Length(AString) do
    if not CharInSet(AString[C1], [#$00..#$08, #$0B..#$1F]) then
      result := result + AString[C1];
end;

end.
