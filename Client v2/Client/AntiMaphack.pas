{$I ..\defines.inc}

unit AntiMaphack;

interface

{$IFDEF CHECK_WC3_HASHES}
var
  MD5_WAR3_EXE  : String;
  MD5_GAME_DLL  : String;
  MD5_STORM_DLL : String;
{$ENDIF}

function IsMaphackInstalled(var ACode : String) : Boolean;

implementation

uses
  Windows, SysUtils, SharedData, PsApi, TlHelp32;

{$IFDEF CHECK_PROCESSES}
function CheckProcessesChecksums(var ACode : String) : Boolean;
const
  INVALID_CHECKSUMS_COUNT = 4;
  INVALID_CHECKSUMS       : Array[0..INVALID_CHECKSUMS_COUNT - 1] of String = (
                                                                               '96348F961948D1582524D3ADFB67BBF7', // Darer 170911 hack (Darer_Hack.exe)
                                                                               'A588EBC3D0F453CEAF054685BAD5E6E6', // Garena Master
                                                                               'D2196171672ED0FA763685F219C62215', // WAR3 1.26a MX by BlackWolf
                                                                               '4385BBAE41E45BB0D41F14B497FB8921'  // Garena Universal MH v13
                                                                              );

var
  cUsername : String;

  function CheckProcess(const AEntry : TProcessEntry32) : Boolean;
  var
    pUsername : String;
    pChecksum : String;
    pPath     : String;
    C1        : Integer;
  begin
    {$IFDEF DEBUG_MAPHACK} Dbg('AntiMaphack :: CheckProcess() :: BEGIN [AEntry.szExeFile = ' + StrPas(AEntry.szExeFile) + ']', TRUE);  {$ENDIF}

    result := TRUE;
    If (GetDomainAndUser(AEntry.th32ProcessID, pUsername)) and
       (pUsername = cUsername) Then
    Begin
      pPath := GetFullPathFromPID(AEntry.th32ProcessID);
      If FileExists(pPath) Then
      Begin
        try
          pChecksum := md5File(pPath);
        finally
          For C1 := 0 to INVALID_CHECKSUMS_COUNT - 1 Do
            If INVALID_CHECKSUMS[C1] = pChecksum Then
            Begin
              {$IFDEF DEBUG_MAPHACK} DbgLn(' :: MATCHES INVALID_CHECKSUMS !');  {$ENDIF}
              result := FALSE;
              ACode := pChecksum;
              Break;
            End;
        end;
      End;
    End;

    {$IFDEF DEBUG_MAPHACK} DbgLn(' :: END');  {$ENDIF}
  end;

var
  hSnapshot : THandle;
  pEntry    : TProcessEntry32;

begin
  {$IFDEF DEBUG_MAPHACK} DbgLn('AntiMaphack :: CheckProcessesChecksums() :: BEGIN');  {$ENDIF}

  result := TRUE;
  If GetDomainAndUser(GetCurrentProcessID, cUsername) Then
  Begin
    hSnapshot := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
    pEntry.dwSize := SizeOf(TProcessEntry32);
    If Process32First(hSnapshot, pEntry) Then
    Begin
      result := CheckProcess(pEntry);
      While (result) and
            (Process32Next(hSnapshot, pEntry)) Do
        result := CheckProcess(pEntry);
    End;
  End;

  {$IFDEF DEBUG_MAPHACK} DbgLn('AntiMaphack :: CheckProcessesChecksums() :: END [result = ' + BoolToStr(result) + ']');  {$ENDIF}
end;
{$ENDIF}

{$IFDEF CHECK_MODULES}
function CheckModules(var ACode : String) : Boolean;
const
  FORBIDDEN_STRINGS_COUNT = 2;
  FORBIDDEN_STRINGS       : Array[0..FORBIDDEN_STRINGS_COUNT - 1] of String = ('.flt', '.mix');
var
  hProcess : THandle;
  szModule : Array[0..MAX_PATH] of Char;
  C1       : Integer;
  memInfo  : MEMORY_BASIC_INFORMATION;
  baseAddr : DWORD;
  bSize    : DWORD;
  modName  : String;
begin
  {$IFDEF DEBUG_MAPHACK} DbgLn('AntiMaphack :: CheckModules() :: BEGIN');  {$ENDIF}

  result := TRUE;
  hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, FALSE, GetProcessID('war3.exe'));
  If hProcess <> 0 Then
  Begin
    baseAddr := 0;
    repeat
      bSize := VirtualQueryEx(hProcess, pointer(baseAddr), memInfo, SizeOf(memInfo));
      If bSize <> 0 Then
      Begin
        If (memInfo.Type_9 = MEM_MAPPED) or
           (memInfo.Type_9 = MEM_IMAGE) and
           (GetMappedFileName(hProcess, pointer(baseAddr), szModule, SizeOf(szModule) div SizeOf(Char)) > 0) Then
        Begin
          modName := LowerCase(StrPas(szModule));
          If Pos('redist\miles\reverb3.flt', modName) = 0 Then
            For C1 := 0 to FORBIDDEN_STRINGS_COUNT - 1 Do
              If Pos(FORBIDDEN_STRINGS[C1], modName) > 0 Then
              Begin
                {$IFDEF DEBUG_MAPHACK} DbgLn('AntiMaphack :: CheckModules() :: MATCHES FORBIDDEN_STRINGS ! modName = ' + modName);  {$ENDIF}
                result := FALSE;
                ACode := modName;
                Break;
              End;
        End;
        Inc(baseAddr, memInfo.RegionSize);
      End;
    until (bSize = 0) or (not result);

    CloseHandle(hProcess);
  End;

  {$IFDEF DEBUG_MAPHACK} DbgLn('AntiMaphack :: CheckModules() :: END [result = ' + BoolToStr(result) + ']');  {$ENDIF}
end;
{$ENDIF}

function IsMaphackInstalled(var ACode : String) : Boolean;
var
  code : String;
begin
  {$IFDEF DEBUG_MAPHACK} DbgLn('AntiMaphack :: IsMaphackInstalled() :: BEGIN');  {$ENDIF}

  result := FALSE;
  ACode := '';

  {$IFDEF ANTI_MAPHACK}
    {$IFDEF CHECK_MODULES}
    If not result Then
      result := not CheckModules(code);
    {$ENDIF}

    {$IFDEF CHECK_PROCESSES}
    If not result Then
      result := not CheckProcessesChecksums(code);
    {$ENDIF}

    {$IFDEF DEBUG_MAPHACK} DbgLn('AntiMaphack :: IsMaphackInstalled() :: END [result = ' + BoolToStr(result) + ']');  {$ENDIF}
  {$ENDIF}
end;

end.
