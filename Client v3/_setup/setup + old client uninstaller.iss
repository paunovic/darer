[Setup]
AppName=Darer Client
AppVersion=3.00f
DefaultDirName={userappdata}\Darer
DefaultGroupName=Darer Entertainment
UninstallDisplayIcon={app}\Darer.exe
Compression=lzma2                     
SolidCompression=yes
OutputDir=.\..\_release
OutputBaseFilename=install_darer
AppMutex=DarerClientInstanceMutex
UninstallDisplayName=Darer Client
WizardImageFile=_material\wizardimg.bmp
WizardSmallImageFile=_material\smallimg.bmp
DisableProgramGroupPage=yes
PrivilegesRequired=admin
UninstallFilesDir={app}\uninst

[Files]
Source: "..\_bin\*.*"; DestDir: "{app}"
Source: "..\_bin\Languages\*.*"; DestDir: "{app}\Languages"

[Icons]
Name: "{group}\Darer"; Filename: "{app}\Darer.exe"
Name: "{commondesktop}\Darer"; Filename: "{app}\Darer.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\Darer"; Filename: "{app}\Darer.exe"; Tasks: quicklaunchicon

[Tasks]
Name: desktopicon; Description: "Create a desktop icon"; GroupDescription: "Icons"
Name: quicklaunchicon; Description: "Create a Quick Launch icon"; GroupDescription: "Icons"; Flags: unchecked
Name: startupinstall; Description: "Launch automatically when Windows starts up"; GroupDescription: "Additional"

[Run]
Filename: "{app}\Darer.exe"; Description: "Launch the client"; Flags: postinstall nowait skipifsilent

[Registry]
Root: HKCU; Subkey: "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "Darer Client"; ValueData: """{app}\Darer.exe"""; Flags: uninsdeletevalue; Tasks: startupinstall
Root: HKCU; Subkey: "SOFTWARE\Darer Entertainment\Client"; ValueType: string; ValueName: "StartupWindows"; ValueData: "TRUE"; Tasks: startupinstall
Root: HKCU; Subkey: "SOFTWARE\Darer Entertainment\Client"; ValueType: string; ValueName: "VersionId"; ValueData: "4f5b277f51c265e45a000003"

      
[code]
function PrepareToInstall(var NeedsRestart : Boolean) : String;
var
  resCode         : Integer;
  fileUninstaller : String;
begin
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Darer_is1', 'UninstallString', fileUninstaller) then
  begin
    fileUninstaller := RemoveQuotes(fileUninstaller);
    if FileExists(fileUninstaller) then
      Exec(fileUninstaller, '/silent /norestart', ExtractFilePath(fileUninstaller), SW_SHOW, ewWaitUntilTerminated, resCode);
  end;

  NeedsRestart := FALSE;
  result := '';  
end;