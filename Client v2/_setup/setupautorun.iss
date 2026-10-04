[Setup]
AppName=Darer
AppVersion=2.0.000
DefaultDirName={pf}\Darer
DefaultGroupName=Darer
UninstallDisplayIcon={app}\Darer.exe
Compression=lzma2
SolidCompression=yes
OutputDir=.\
OutputBaseFilename=DarerSetup
AppMutex=DarerClientInstanceMutex
UninstallDisplayName=Darer
WizardImageFile=_material\wizardimg.bmp
WizardSmallImageFile=_material\smallimg.bmp
DisableProgramGroupPage=yes
UninstallFilesDir={app}\uninst

[Files]
Source: "..\_release\*.*"; DestDir: "{app}"
Source: "..\_release\GProxy\*.*"; DestDir: "{app}\GProxy"
Source: "..\_release\Languages\*.*"; DestDir: "{app}\Languages"
Source: "..\_release\Sounds\*.*"; DestDir: "{app}\Sounds"
Source: "_material\vcredist_x86.exe"; DestDir: "{app}\bin"

[Icons]
Name: "{group}\Darer"; Filename: "{app}\Darer.exe"
Name: "{commondesktop}\Darer"; Filename: "{app}\Darer.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\Darer"; Filename: "{app}\Darer.exe"; Tasks: quicklaunchicon

[Tasks]
Name: desktopicon; Description: "Create a desktop icon"; GroupDescription: "Icons";
Name: quicklaunchicon; Description: "Create a Quick Launch icon"; GroupDescription: "Icons"; Flags: unchecked
Name: associate; Description: "&Associate Darer client with Warcraft III replays"; GroupDescription: "Client"

[Run]
Filename: "{app}\bin\vcredist_x86.exe"; Parameters: "/qb"
Filename: "{app}\Darer.exe"; Description: "Launch the client"; Flags: postinstall nowait skipifsilent
Filename: "{app}\Darer.exe"; Parameters: "-installandrun"; Tasks: associate; Flags: nowait

[UninstallRun]
Filename: "{app}\Darer.exe"; Parameters: "-uninstall"

[UninstallDelete]
Type: files; Name: "{app}\GProxy\gproxy.cfg"

[code]
function PrepareToInstall(var NeedsRestart : Boolean) : String;
var
  resCode         : Integer;
  fileUninstaller : String;
begin
  If (RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Darer', 'UninstallString', fileUninstaller)) and
     (FileExists(fileUninstaller)) Then
    Exec(fileUninstaller, '/hide /silent', ExtractFilePath(fileUninstaller), SW_SHOW, ewWaitUntilTerminated, resCode)
  else
    If (RegQueryStringValue(HKEY_CURRENT_USER, 'SOFTWARE\Darer', 'UninstallString', fileUninstaller)) and
       (FileExists(fileUninstaller)) Then
      Exec(fileUninstaller, '/hide /silent', ExtractFilePath(fileUninstaller), SW_SHOW, ewWaitUntilTerminated, resCode);

  NeedsRestart := FALSE;
  result := '';  
end;