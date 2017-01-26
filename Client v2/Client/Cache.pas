unit Cache;

interface

uses
  Classes, SharedData;

procedure cache_Init;
function cache_FileExists(AFileName : String) : Boolean;
function cache_GetFilePath(AFileName : String) : String;
function cache_PutFile(AMemStream : TMemoryStream; const AFileName : String) : Boolean;
function cache_PutUser(const AUserInfo : TUserInfo) : Boolean;
function cache_GetUser(const AUsername : String; var AUserInfo : TUserInfo) : Boolean;
function cache_GetAvatarName(const AAvatarName : String; const AAvatarType : TAvatarType) : String;
function cache_PutAvatar(const AMemStream : TMemoryStream; const AAvatarName : String; const AAvatarType : TAvatarType) : Boolean;
function cache_GetAvatar(const AAvatar : String; const AAvatarType : TAvatarType; var APath : String) : Boolean;

implementation

uses
  SysUtils, SharedVars;

procedure cache_Init;
begin
  ForceDirectories(ITB(ExpandEnvString(CACHE_DIR)));
end;

function cache_FileExists(AFileName : String) : Boolean;
begin
  result := FileExists(ITB(ExpandEnvString(CACHE_DIR)) + AFileName);
end;

function cache_GetFilePath(AFileName : String) : String;
begin
  result := ITB(ExpandEnvString(CACHE_DIR)) + AFileName;
end;

function cache_PutFile(AMemStream : TMemoryStream; const AFileName : String) : Boolean;
begin
  AMemStream.SaveToFile(ITB(ExpandEnvString(CACHE_DIR)) + AFileName);
  result := TRUE;
end;

function cache_PutUser(const AUserInfo : TUserInfo) : Boolean;
var
  TFile : File of TUserInfo;
begin
  AssignFile(TFile, ITB(ExpandEnvString(CACHE_DIR)) + AUserInfo.Username);
  Rewrite(TFile);
    Write(TFile, AUserInfo);
  CloseFile(TFile);

  result := TRUE;
end;

function cache_GetUser(const AUsername : String; var AUserInfo : TUserInfo) : Boolean;
var
  SFile : File of TUserInfo;
begin
  result := FALSE;

  If cache_FileExists(AUsername) Then
  Begin
    AssignFile(SFile, ITB(ExpandEnvString(CACHE_DIR)) + AUsername);
    {$I-}
    Reset(SFile);
      Read(SFile, AUserInfo);
    CloseFile(SFile);
    {$I+}
    result := IOResult = 0;
  End;
end;

function cache_GetAvatarName(const AAvatarName : String; const AAvatarType : TAvatarType) : String;
var
  avatarType : String;
begin
  Case AAvatarType of
    atSmall : avatarType := 'small';
    atBig   : avatarType := 'big';
  End;

  result := Format('%s_%s', [AAvatarName, avatarType]);
end;

function cache_PutAvatar(const AMemStream : TMemoryStream; const AAvatarName : String; const AAvatarType : TAvatarType) : Boolean;
begin
  AMemStream.SaveToFile(ITB(ExpandEnvString(CACHE_DIR)) + cache_GetAvatarName(AAvatarName, AAvatarType));
  result := TRUE;
end;

function cache_GetAvatar(const AAvatar : String; const AAvatarType : TAvatarType; var APath : String) : Boolean;
var
  avatarPath : String;
begin
  avatarPath := cache_GetAvatarName(AAvatar, AAvatarType);
  If cache_FileExists(avatarPath) Then
  Begin
    APath := ITB(ExpandEnvString(CACHE_DIR)) + avatarPath;
    result := TRUE;
  End
  else
    result := FALSE;
end;

end.
