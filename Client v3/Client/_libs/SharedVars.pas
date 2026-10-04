unit SharedVars;

interface

uses
  Windows, Messages, Classes, IpTypes;

{$I defines.inc}
{$I countries.inc}

const
  CLIENT_VERSION           = 'v3.01b';

  CRYPT_KEY                = 'p6m5_e3$9--#HLTI{a-rG-]J8@%-k203';
  CRYPT_IV                 = '${L54vl_M-kd:0_!';

  SETTINGS_LANGUAGE        = 'Language';
  SETTINGS_AUTOLOGIN       = 'AutoLogin';
  SETTINGS_USERNAME        = 'Username';
  SETTINGS_PASSWORD        = 'Password';
  SETTINGS_WAR3EXE         = 'WarcraftExe';
  SETTINGS_STARTUP         = 'StartupWindows';
  SETTINGS_MINIMIZEONLOGIN = 'MinimizeOnLogin';
  SETTINGS_VERSIONID       = 'VersionId';

  INSTANCE_MUTEX           = 'DarerClientInstanceMutex';
  SETTINGS_ADMESSAGE       = 'AdMessage';

  AD_MESSAGE               = 'After the game go to www.darer.com and search your nickname to see your statistics and rating.';

  DIR_APPDATA              = '%APPDATA%\Darer';
  DIR_LANGUAGES            = 'Languages';

  URL_CAPTCHA              = 'http://www.darer.com/captcha/default';
  URL_API                  = 'http://www.darer.com/gateway';
  URL_UPDATE               = 'http://update.darer.com/ipn';
  URL_UPDATECHECK          = URL_UPDATE + '/check/%s';
  URL_ERRORREPORT          = URL_UPDATE + '/alerts';
  URL_LOGIN                = URL_API + '/login';
  URL_GAMEPOST             = URL_API + '/put';

  WM_AFTER_SHOW            = WM_USER + 300;

type
  PNetworkInterfaces = ^TNetworkInterfaces;
  TNetworkInterfaces = record
                         Count : Integer;
                         Items : Array of PIP_ADAPTER_ADDRESSES;
                       end;

  TOptions = record
               WarcraftExe     : String;
               StartupWindows  : Boolean;
               Username        : String;
               Password        : String;
               AutoLogin       : Boolean;
               MinimizeOnLogin : Boolean;
               LanguageFile    : String;
               VersionId       : String;
               AdMessage       : Boolean;
             end;

  TReplayType = (rtUnknown, rtWarcraft, rtStarcraft2);

  TUpdateFileType = (ftFile, ftPatch);

  PUpdateFileInfo = ^TUpdateFileInfo;
  TUpdateFileInfo = record
                      FileType : TUpdateFileType;
                      Path     : String;
                      Name     : String;
                      Hash     : String;
                      URL      : String;
                    end;

var
  Options           : TOptions;
  SelfPath          : String;
  SelfExe           : String;
  AppData           : String;
  NetworkInterfaces : TNetworkInterfaces;

  {$IFDEF DEBUGSWITCH}
  Debug             : Boolean;
  {$ENDIF}

implementation

uses
  SysUtils, SharedFunctions;

initialization
  {$IFDEF DEBUGSWITCH}
  Debug := FALSE;
  {$ENDIF}

  SelfExe := ParamStr(0);
  SelfPath := ExtractFilePath(SelfExe);
  AppData := ExpandEnvString(DIR_APPDATA);

end.
