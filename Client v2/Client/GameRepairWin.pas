unit GameRepairWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, SkinCtrls, SkinExCtrls, JvComponentBase,
  JvThread, ZipForge, OverbyteIcsWndControl, OverbyteIcsHttpProt, ExtCtrls, SharedVars;

type
  TGameRepairWindow = class(TForm)
    SkinForm: TspDynamicSkinForm;
    gaugeRepair: TspSkinGauge;
    lbStatus: TspSkinShadowLabel;
    btStart: TspSkinButton;
    httpRepair: THttpCli;
    ZipForge: TZipForge;
    thdRepair: TJvThread;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure httpRepairDocBegin(Sender: TObject);
    procedure httpRepairDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
    procedure btStartClick_Repair(Sender: TObject);
    procedure btStartClick_Close(Sender: TObject);
    procedure thdRepairExecute(Sender: TObject; Params: Pointer);
    procedure thdRepairFinish(Sender: TObject);
    procedure thdRepairBegin(Sender: TObject);
    procedure Sync;
    procedure FormShow(Sender: TObject);
  private
    InvalidFiles : TStringList;
    GaugeValue   : Integer;
    StatusText   : String;
    StatusColor  : TColor;
  public
    StartAutomatically : Boolean;
    CloseAutomatically : Boolean;
    Hashes             : TWarcraftHashVersion;

    VRS_REPAIR_REPAIRING_FILES,
    VRS_REPAIR_CHECKING_FILES,
    VRS_REPAIR_FILES_OK,
    VRS_REPAIR_DONE,
    VRS_REPAIR_CLOSE,
    VRS_REPAIR_ERROR            : String;

    procedure LocalLocalize;
  end;

var
  GameRepairWindow: TGameRepairWindow;

implementation

{$R *.dfm}

uses
  SharedData, Localization, ComponentModule, GameLanguageWin;

procedure TGameRepairWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  thdRepair.TerminateWaitFor;
  Action := caFree;
end;

procedure TGameRepairWindow.LocalLocalize;
begin
  VRS_REPAIR_REPAIRING_FILES := RS_REPAIR_REPAIRING_FILES;
  VRS_REPAIR_CHECKING_FILES := RS_REPAIR_CHECKING_FILES;
  VRS_REPAIR_FILES_OK := RS_REPAIR_FILES_OK;
  VRS_REPAIR_DONE := RS_REPAIR_DONE;
  VRS_REPAIR_CLOSE := RS_REPAIR_CLOSE;
  VRS_REPAIR_ERROR := RS_REPAIR_ERROR;
end;

procedure TGameRepairWindow.FormCreate(Sender: TObject);
begin
  Localize(self);
  LocalLocalize;
end;

procedure TGameRepairWindow.Sync;
begin
  gaugeRepair.Value := GaugeValue;
  lbStatus.Font.Color := StatusColor;
  lbStatus.Caption := StatusText;
end;

procedure TGameRepairWindow.httpRepairDocBegin(Sender: TObject);
begin
  GaugeValue := 0;
  StatusText := Format(VRS_REPAIR_REPAIRING_FILES, [GaugeValue]);
  StatusColor := clWhite;
  Sync;
end;

procedure TGameRepairWindow.httpRepairDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
begin
  If thdRepair.Terminated Then
    THTTPCli(Sender).Close
  else
    If THTTPCli(Sender).ContentLength > 0 Then
    Begin
      GaugeValue := Round(((THTTPCli(Sender).Tag / InvalidFiles.Count) * 100) + (THTTPCli(Sender).RcvdCount / THTTPCli(Sender).ContentLength) * (1 / InvalidFiles.Count) * 100);
      StatusText := Format(VRS_REPAIR_REPAIRING_FILES, [GaugeValue]);
      StatusColor := clWhite;
      Sync;
    End;
end;

procedure TGameRepairWindow.btStartClick_Repair(Sender: TObject);
begin
  thdRepair.Execute(self);
end;

procedure TGameRepairWindow.btStartClick_Close(Sender: TObject);
begin
  Close;
end;

procedure TGameRepairWindow.thdRepairExecute(Sender: TObject; Params: Pointer);
var
  res         : Boolean;
  C1          : Integer;
  patchDir    : String;
  countryCode : String;
begin
  InvalidFiles := TStringList.Create;
  InvalidFiles.Sorted := TRUE;
  InvalidFiles.Duplicates := dupIgnore;

  GaugeValue := 0;
  StatusText := Format(VRS_REPAIR_CHECKING_FILES, [GaugeValue]);
  StatusColor := clWhite;
  thdRepair.Synchronize(TGameRepairWindow(params).Sync);

  countryCode := 'EN';
  If Options.WC3.Language = RS_GAME_LANGUAGE_RUSSIAN Then
    countryCode := 'RU';
  If Options.WC3.Language = RS_GAME_LANGUAGE_CHINESE_TRAD Then
    countryCode := 'TW';

  For C1 := 0 to Length(Hashes.Hashes) - 1 Do
  Begin
    If thdRepair.Terminated Then
      Exit;

    If Hashes.Hashes[C1].Filename <> '' Then
      If (Hashes.Version <> '?') and
         (FileExists(ITB(Options.WC3.Path) + Hashes.Hashes[C1].Filename)) Then
      Begin
        If md5File(ITB(Options.WC3.Path) + Hashes.Hashes[C1].Filename) <> Hashes.Hashes[C1].Hash Then
          InvalidFiles.Add(Hashes.Hashes[C1].Filename);
      End
      else
        InvalidFiles.Add(Hashes.Hashes[C1].Filename);

    GaugeValue :=  Round(((C1 + 1) / Length(Hashes.Hashes)) * 100);
    StatusText := Format(VRS_REPAIR_CHECKING_FILES, [GaugeValue]);
    StatusColor := clWhite;
    thdRepair.Synchronize(TGameRepairWindow(params).Sync);
  End;

  GaugeValue := 0;
  StatusText := Format(VRS_REPAIR_REPAIRING_FILES, [GaugeValue]);
  StatusColor := clWhite;
  thdRepair.Synchronize(TGameRepairWindow(params).Sync);

  patchDir := ITB(ITB(ExpandEnvString(PATCH_DIR)) + ITB(countryCode) + Hashes.Version);
  If not DirectoryExists(patchDir) Then
    ForceDirectories(patchDir);

  res := TRUE;
  For C1 := 0 to InvalidFiles.Count - 1 Do
  Begin
    res := TRUE;
    If thdRepair.Terminated Then
      Break;

    httpRepair.Tag := C1;

    If not FileExists(patchDir + InvalidFiles.Strings[C1]) Then
    Begin
      ZipForge.InMemory := TRUE;
      ZipForge.FileName := '';
      httpRepair.RcvdStream := TMemoryStream.Create;
      
      httpRepair.URL := Format('http://update.darer.com/patch/%s/%s/%s', [countryCode, Hashes.Version, InvalidFiles.Strings[C1]]);
      httpRepair.GetAsync;

      While httpRepair.State <> httpReady Do
        Sleep(1);

      If not DirectoryExists(patchDir) Then
        ForceDirectories(patchDir);

      try
        ZipForge.OpenArchive(httpRepair.RcvdStream, FALSE);
        ZipForge.BaseDir := patchDir;
        ZipForge.ExtractFiles('*.*');
        ZipForge.CloseArchive;
      except
        res := FALSE;
        Break;
      end;

      httpFree(httpRepair);
    End;

    If not CopyFile(PChar(patchDir + InvalidFiles.Strings[C1]), PChar(ITB(Options.WC3.Path) + InvalidFiles.Strings[C1]), FALSE) Then
    Begin
      ShowMessage('Unable to repair! Please make sure that you closed Warcraft III before repair and that you run client as administrator');
      Break;
    End;

    GaugeValue := Round(((C1 + 1) / InvalidFiles.Count) * 100);
    StatusText := Format(VRS_REPAIR_REPAIRING_FILES, [GaugeValue]);
    StatusColor := clWhite;
    thdRepair.Synchronize(TGameRepairWindow(params).Sync);
  End;

  If not thdRepair.Terminated Then
  Begin
    If InvalidFiles.Count = 0 Then
    Begin
      GaugeValue := 100;
      StatusText := VRS_REPAIR_FILES_OK;
      StatusColor := clLime;
      thdRepair.Synchronize(TGameRepairWindow(params).Sync);
    End
    else
      If res Then
      Begin
        GaugeValue := 100;
        StatusText := VRS_REPAIR_DONE;
        StatusColor := clLime;
        thdRepair.Synchronize(TGameRepairWindow(params).Sync);
      End
      else
      Begin
        GaugeValue := 0;
        StatusText := VRS_REPAIR_ERROR;
        StatusColor := clRed;
        thdRepair.Synchronize(TGameRepairWindow(params).Sync);
      End;
  End;

  InvalidFiles.Free;
end;

procedure TGameRepairWindow.thdRepairFinish(Sender: TObject);
begin
  btStart.Caption := VRS_REPAIR_CLOSE;
  btStart.Enabled := TRUE;
  btStart.OnClick := btStartClick_Close;
  
  If CloseAutomatically Then
    btStart.OnClick(Sender);
end;

procedure TGameRepairWindow.thdRepairBegin(Sender: TObject);
begin
  btStart.Enabled := FALSE;
end;

procedure TGameRepairWindow.FormShow(Sender: TObject);
begin
  If StartAutomatically Then
    btStart.OnClick(Sender);
end;

end.
