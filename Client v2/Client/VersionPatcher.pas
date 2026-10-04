unit VersionPatcher;

interface

uses
  SharedVars;

type
  TReplayVersion = record
                     VersionNumber, BuildNumber : Integer;
                   end;

function IsValidPatch(const ADir : String; const AReplayVersion  : TReplayVersion) : Boolean;
function GetPatchDir(const AReplayVersion : TReplayVersion) : String;
procedure ApplyPatch(const APatchDir : String);
procedure OpenReplay(const AReplayFile : String);
function GetGameVersion : String;
function EncodeReplayVersion(const AVersion, ABuild : Integer) : String;
function IsLatestVersion : Boolean;
function GetGameHashes : TWarcraftHashVersion;
function RecognizeGameLanguage : Boolean;
function GetGameHashesAll : TWarhashes;

implementation

uses
  Windows, Classes, SysUtils, SharedData, INIFiles, madTools, Localization;

function IsValidPatch(const ADir : String; const AReplayVersion  : TReplayVersion) : Boolean;
var
  INI : TINIFile;
begin
  result := FALSE;
  If FileExists(ITB(ADir) + 'info.txt') Then
  Begin
    INI := TINIFile.Create(ITB(ADir) + 'info.txt');
    result := INI.ReadString('main', 'replay', '') = Format('%d.%d', [AReplayVersion.VersionNumber, AReplayVersion.BuildNumber]);
    INI.Free;
  End;
end;

function GetPatchDir(const AReplayVersion : TReplayVersion) : String;
var
  SearchRec : TSearchRec;
  IsFound   : Boolean;
begin
  result := '';
  IsFound := FindFirst(ITB(ExpandEnvString(PATCH_DIR)) + '*.*', faAnyFile, SearchRec) = 0;
  While IsFound Do
  Begin
    If (SearchRec.Name <> '.') and (SearchRec.Name <> '..') and
       (SearchRec.Attr and faDirectory = faDirectory) Then
      If IsValidPatch(ITB(ExpandEnvString(PATCH_DIR)) + SearchRec.Name, AReplayVersion) Then
      Begin
        result := ITB(ExpandEnvString(PATCH_DIR)) + SearchRec.Name;
        Break;
      End;
    IsFound := FindNext(SearchRec) = 0;
  End;
  FindClose(SearchRec);
end;

procedure ApplyPatch(const APatchDir : String);
const
  FILES_COUNT = 4;
  FILE_LIST   : Array[0..FILES_COUNT - 1] of String = ('game.dll', 'storm.dll', 'war3.exe', 'War3Patch.mpq');
var
  C1 : Integer;
begin
  For C1 := 0 to FILES_COUNT - 1 Do
    If md5File(ITB(APatchDir) + FILE_LIST[C1]) <> md5File(ITB(Options.WC3.Path) + FILE_LIST[C1]) Then
      CopyFile(PChar(ITB(APatchDir) + FILE_LIST[C1]), PChar(ITB(Options.WC3.Path) + FILE_LIST[C1]), FALSE);
end;

procedure OpenReplay(const AReplayFile : String);
var
  pinfo : TProcessInformation;
begin
  ExecuteFile(Options.WC3.Exe, Format('"%s" -loadfile "%s"', [Options.WC3.Exe, AReplayFile]), Options.WC3.Path, 0, SW_SHOW, pinfo);
end;

function GetGameVersion : String;
type
  TGameVersion = record
                   Native, Fancy : String;
                 end;
const
  GAME_VERSIONS_COUNT = 3;
  GAME_VERSIONS       : Array[0..GAME_VERSIONS_COUNT - 1] of TGameVersion = ((Native: '1.24.4.6387'; Fancy: '1.24e'),
                                                                             (Native: '1.25.1.6397'; Fancy: '1.25b'),
                                                                             (Native: '1.26.0.6401'; Fancy: '1.26a'));

var
  ver : String;
  C1  : Integer;
begin
  result := '';
  ver := FileVersionToStr(GetFileVersion(Options.WC3.Exe));

  For C1 := 0 to GAME_VERSIONS_COUNT - 1 Do
    If ver = GAME_VERSIONS[C1].Native Then
    Begin
      result := GAME_VERSIONS[C1].Fancy;
      Break;
    End;
end;

function EncodeReplayVersion(const AVersion, ABuild : Integer) : String;
begin
  Case AVersion of
    24 : Case ABuild of
           6059 : result := '1.24e';
         End;
    25 : Case ABuild of
           6059 : result := '1.25b';
         End;
    26 : Case ABuild of
           6059 : result := '1.26a';
         End;
  End;
end;

function GetGameHashes : TWarcraftHashVersion;
begin
  result.Version := '';
  If Options.WC3.Language = RS_GAME_LANGUAGE_ENGLISH Then
    result := WARHASHES_EN[0];
  If Options.WC3.Language = RS_GAME_LANGUAGE_RUSSIAN Then
    result := WARHASHES_RU[0];
  If Options.WC3.Language = RS_GAME_LANGUAGE_CHINESE_TRAD Then
    result := WARHASHES_TW[0];
end;

function GetGameHashesAll : TWarhashes;
begin
  If Options.WC3.Language = RS_GAME_LANGUAGE_ENGLISH Then
    result := WARHASHES_EN;
  If Options.WC3.Language = RS_GAME_LANGUAGE_RUSSIAN Then
    result := WARHASHES_RU;
  If Options.WC3.Language = RS_GAME_LANGUAGE_CHINESE_TRAD Then
    result := WARHASHES_TW;
end;

function IsLatestVersion : Boolean;
var
  C1      : Integer;
  shashes : TWarcraftHashVersion;
begin
  shashes := GetGameHashes;

  If shashes.Version <> '' Then
  Begin
    result := TRUE;
    For C1 := 0 to Length(shashes.Hashes) - 1 Do
      If shashes.Hashes[C1].Hash <> md5File(ITB(Options.WC3.Path) + shashes.Hashes[C1].Filename) Then
      Begin
        result := FALSE;
        Break;
      End;
  End
  else
    result := FALSE;
end;

function RecognizeGameLanguage : Boolean;
var
  C1       : Integer;
  C2       : Integer;
  patchMD5 : String;
begin
  result := FALSE;

  patchMD5 := md5File(ITB(Options.WC3.Path) + HASHES_FILE_WAR3PATCH);

  For C1 := 0 to WARHASHES_COUNT - 1 Do
    For C2 := 0 to Length(WARHASHES_EN[C1].Hashes) - 1 Do
      If WARHASHES_EN[C1].Hashes[C2].Filename = HASHES_FILE_WAR3PATCH Then
      Begin
        If WARHASHES_EN[C1].Hashes[C2].Hash = patchMD5 Then
        Begin
          Options.WC3.Language := RS_GAME_LANGUAGE_ENGLISH;
          result := TRUE;
          Exit;
        End;
      End;

  For C1 := 0 to WARHASHES_COUNT - 1 Do
    For C2 := 0 to Length(WARHASHES_RU[C1].Hashes) - 1 Do
      If WARHASHES_RU[C1].Hashes[C2].Filename = HASHES_FILE_WAR3PATCH Then
      Begin
        If WARHASHES_RU[C1].Hashes[C2].Hash = patchMD5 Then
        Begin
          Options.WC3.Language := RS_GAME_LANGUAGE_RUSSIAN;
          result := TRUE;
          Exit;
        End;
      End;

  For C1 := 0 to WARHASHES_COUNT - 1 Do
    For C2 := 0 to Length(WARHASHES_TW[C1].Hashes) - 1 Do
      If WARHASHES_TW[C1].Hashes[C2].Filename = HASHES_FILE_WAR3PATCH Then
      Begin
        If WARHASHES_TW[C1].Hashes[C2].Hash = patchMD5 Then
        Begin
          Options.WC3.Language := RS_GAME_LANGUAGE_CHINESE_TRAD;
          result := TRUE;
          Exit;
        End;
      End;
end;

end.
