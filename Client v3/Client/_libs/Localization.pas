unit Localization;

interface

uses
  Classes;

type
  TLanguageInfo = record
                    Name        : String;
                    LocalName   : String;
                    CountryCode : String;
                    Author      : String;
                  end;

  ILocalizationChanged = interface['{3FFF9AC0-EEEC-4047-BB36-FD70621343E3}']
                           procedure ApplyLocalizationChange;
                         end;
  {$M+}
  TLocalizer = class
               private
                 FLanguageFile      : String;
                 FLanguageList      : TStringList;
                 FLanguagesDir      : String;
                 FLanguagesFileMask : String;
               public
                 constructor Create(const ALanguagesDir : String = ''; const ALanguagesFilemask : String = '*.*');
                 destructor Destroy; override;

                 procedure Localize(const AComponent : TComponent);
                 procedure LocalizeResourceStrings;

                 procedure RefreshLanguageList;
                 function GetLanguageInfo(const ALanguageFile : String) : TLanguageInfo;
                 function FindLanguageByName(const ALanguageName : String; var AIndex : Integer) : Boolean;
               published
                 property LanguageFile : String read FLanguageFile write FLanguageFile;
                 property LanguageList : TStringList read FLanguageList;
                 property LanguagesDir : String read FLanguagesDir write FLanguagesDir;
               end;
  {$M-}


implementation

uses
  SysUtils, INIFiles, TypInfo, SharedFunctions, LocalizationStr, Forms;

constructor TLocalizer.Create(const ALanguagesDir : String = ''; const ALanguagesFilemask : String = '*.*');
begin
  DbgLn('TLocalizer.Create()');

  FLanguageFile := '';
  FLanguagesDir := ALanguagesDir;
  FLanguagesFilemask := ALanguagesFilemask;

  FLanguageList := TStringList.Create;
  FLanguageList.Clear;
  FLanguageList.Sorted := TRUE;
  RefreshLanguageList;
end;

destructor TLocalizer.Destroy;
begin
  DbgLn('TLocalizer.Destroy()');

  FLanguageList.Free;

  inherited;
end;

procedure TLocalizer.Localize(const AComponent : TComponent);
const
  DATASECTION = 'data';
var
  INI      : TMemINIFile;
  ident    : TStringList;
  values   : TStringList;
  objects  : TStringList;
  C1       : Integer;
  fcomp    : TComponent;
  PropInfo : PPropInfo;
  isHint   : Boolean;
  objStr   : String;
  iface    : ILocalizationChanged;
begin
  If Assigned(AComponent) Then
  Begin
    DbgLn(Format('TLocalizer.Localize(%s)', [AComponent.Name]));

    If FileExists(FLanguageFile) Then
    Begin
      INI := TMemINIFile.Create(FLanguageFile, TEncoding.UTF8);
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

    If Supports(AComponent, ILocalizationChanged, iface) Then
      iface.ApplyLocalizationChange;
  End;

  For C1 := 0 to AComponent.ComponentCount - 1 Do
    If (AComponent.Components[C1] is TFrame) and
       (Supports(AComponent.Components[C1], ILocalizationChanged, iface)) Then
      Localize(AComponent.Components[C1]);
end;

procedure TLocalizer.LocalizeResourceStrings;
const
  SECTION = 'strresources';
var
  INI : TMemINIFile;
begin
  DbgLn('TLocalizer.LocalizeResourceStrings()');

  If FileExists(FLanguageFile) Then
  Begin
    INI := TMemINIFile.Create(FLanguageFile, TEncoding.UTF8);

    RS_AUTHENTICATING := PrepareString(INI.ReadString(SECTION, 'RS_AUTHENTICATING', RS_AUTHENTICATING));
    RS_RUN_CLIENT_AS_ADMIN := PrepareString(INI.ReadString(SECTION, 'RS_RUN_CLIENT_AS_ADMIN', RS_RUN_CLIENT_AS_ADMIN));
    RS_WARDIALOG_TITLE := PrepareString(INI.ReadString(SECTION, 'RS_WARDIALOG_TITLE', RS_WARDIALOG_TITLE));
    RS_NO_RESPONSE_FROM_SERVER := PrepareString(INI.ReadString(SECTION, 'RS_NO_RESPONSE_FROM_SERVER', RS_NO_RESPONSE_FROM_SERVER));
    RS_DOWNLOAD_DOWNLOADING := PrepareString(INI.ReadString(SECTION, 'RS_DOWNLOAD_DOWNLOADING', RS_DOWNLOAD_DOWNLOADING));
    RS_WARCRAFT_REPLAY_NOT_ASSOCIATED := PrepareString(INI.ReadString(SECTION, 'RS_WARCRAFT_REPLAY_NOT_ASSOCIATED', RS_WARCRAFT_REPLAY_NOT_ASSOCIATED));
    RS_STARCRAFT_REPLAY_NOT_ASSOCIATED := PrepareString(INI.ReadString(SECTION, 'RS_STARCRAFT_REPLAY_NOT_ASSOCIATED', RS_STARCRAFT_REPLAY_NOT_ASSOCIATED));
    RS_INVALID_EMAIL := PrepareString(INI.ReadString(SECTION, 'RS_INVALID_EMAIL', RS_INVALID_EMAIL));
    RS_PASSWORD_MISMATCH := PrepareString(INI.ReadString(SECTION, 'RS_PASSWORD_MISMATCH', RS_PASSWORD_MISMATCH));
    RS_FILL_ALL_FIELDS := PrepareString(INI.ReadString(SECTION, 'RS_FILL_ALL_FIELDS', RS_FILL_ALL_FIELDS));
    RS_PASSWORD_TOO_SHORT := PrepareString(INI.ReadString(SECTION, 'RS_PASSWORD_TOO_SHORT', RS_PASSWORD_TOO_SHORT));
    RS_USERNAME_TOO_SHORT := PrepareString(INI.ReadString(SECTION, 'RS_USERNAME_TOO_SHORT', RS_USERNAME_TOO_SHORT));
    RS_CHECKING_FOR_UPDATES := PrepareString(INI.ReadString(SECTION, 'RS_CHECKING_FOR_UPDATES', RS_CHECKING_FOR_UPDATES));
    RS_REPLAY_DOWNLOADING := PrepareString(INI.ReadString(SECTION, 'RS_REPLAY_DOWNLOADING', RS_REPLAY_DOWNLOADING));
    RS_UPDATE_DOWNLOADING := PrepareString(INI.ReadString(SECTION, 'RS_UPDATE_DOWNLOADING', RS_UPDATE_DOWNLOADING));
    RS_AGREE_TO_TERMS := PrepareString(INI.ReadString(SECTION, 'RS_AGREE_TO_TERMS', RS_AGREE_TO_TERMS));

    INI.Free;
  End;
end;

function TLocalizer.GetLanguageInfo(const ALanguageFile : String) : TLanguageInfo;
var
  INI : TMemINIFile;
begin
  DbgLn(Format('TLocalizer.GetLanguageInfo(%s)', [ALanguageFile]));

  If FileExists(ALanguageFile) Then
  Begin
    INI := TMemINIFile.Create(ALanguageFile, TEncoding.UTF8);
    result.Name := INI.ReadString('info', 'LanguageName', '');
    result.LocalName := INI.ReadString('info', 'LocalLanguageName', '');
    result.CountryCode := INI.ReadString('info', 'CountryCode', '');
    result.Author := INI.ReadString('info', 'Author', '');
    INI.Free;
  End;
end;

procedure TLocalizer.RefreshLanguageList;
begin
  DbgLn('TLocalizer.RefreshLanguageList()');

  LanguageList.Clear;
  EnumerateFiles(FLanguagesDir, FLanguagesFilemask, TRUE, FLanguageList);
end;

function TLocalizer.FindLanguageByName(const ALanguageName : String; var AIndex : Integer) : Boolean;
var
  C1       : Integer;
  langInfo : TLanguageInfo;
begin
  DbgLn(Format('TLocalizer.FindLanguageByName(%s, %d)', [ALanguageName, AIndex]));

  result := FALSE;
  AIndex := -1;

  For C1 := 0 to FLanguageList.Count - 1 Do
  Begin
    langInfo := GetLanguageInfo(FLanguageList.Strings[C1]);
    If (langInfo.Name = ALanguageName) or
       (langInfo.LocalName = ALanguageName) Then
    Begin
      AIndex := C1;
      result := TRUE;
      Break;
    End;
  End;
end;

end.
