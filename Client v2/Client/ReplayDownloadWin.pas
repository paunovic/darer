unit ReplayDownloadWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, SkinCtrls, SkinExCtrls, OverbyteIcsWndControl,
  OverbyteIcsHttpProt, JvComponentBase, JvThread;

type
  TReplayDownloadWindow = class(TForm)
    SkinForm: TspDynamicSkinForm;
    lbStatus: TspSkinShadowLabel;
    gaugeDownload: TspSkinGauge;
    btCancel: TspSkinButton;
    httpDownload: THttpCli;
    httpDownloadMap: THttpCli;
    procedure Sync;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure httpDownloadDocBegin(Sender: TObject);
    procedure httpDownloadDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btCancelClick(Sender: TObject);
    procedure CloseForm;
    procedure RunReplay(const AReplay : String);
    procedure ProcessReplay(const AReplayFile : String);
    procedure httpDownloadSessionClosed(Sender: TObject);
    procedure httpDownloadMapDocBegin(Sender: TObject);
    procedure httpDownloadMapDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
    procedure httpDownloadMapSessionClosed(Sender: TObject);
  private
    GaugeValue    : Integer;
    StatusText    : String;
    StatusColor   : TColor;
    Terminating   : Boolean;
    MapPath       : String;
    MapReplayFile : String;
  public
    ReplayFile : String;
  end;

var
  ReplayDownloadWindow: TReplayDownloadWindow;

implementation

{$R *.dfm}

uses
  ComponentModule, SharedData, Localization, VersionPatcher, GameRepairWin, SharedVars, W3GParser;

procedure TReplayDownloadWindow.Sync;
begin
  gaugeDownload.Value := GaugeValue;
  lbStatus.Font.Color := StatusColor;
  lbStatus.Caption := StatusText;
end;

procedure TReplayDownloadWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TReplayDownloadWindow.httpDownloadDocBegin(Sender: TObject);
begin
  GaugeValue := 0;
  StatusText := Format(RS_REPLAY_DOWNLOADING, [gaugeDownload.Value]);
  StatusColor := clWhite;
  Sync;
end;

procedure TReplayDownloadWindow.httpDownloadDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
begin
  If THTTPCli(Sender).ContentLength > 0 Then
  Begin
    GaugeValue := Round((THTTPCli(Sender).RcvdCount / THTTPCli(Sender).ContentLength) * 100);
    StatusText := Format(RS_REPLAY_DOWNLOADING, [gaugeDownload.Value]);
    StatusColor := clWhite;
    Sync;
  End;
end;

procedure TReplayDownloadWindow.FormCreate(Sender: TObject);
begin
  Localize(self);
end;

procedure TReplayDownloadWindow.CloseForm;
begin
  ComponentModuleWindow.Free;
  Close;
end;

procedure TReplayDownloadWindow.FormShow(Sender: TObject);
begin
  If FileExists(ReplayFile) Then
    ProcessReplay(ReplayFile)
  else
  Begin
    Terminating := FALSE;
    httpGetRequest(httpDownload, ReplayFile);
  end;
end;

procedure TReplayDownloadWindow.btCancelClick(Sender: TObject);
begin
  Terminating := TRUE;
  httpDownload.Close;
  httpDownloadMap.Close;
  CloseForm;
end;

procedure TReplayDownloadWindow.RunReplay(const AReplay : String);
begin
  GaugeValue := 100;
  StatusText := RS_REPLAY_RUNNING;
  StatusColor := clWhite;
  Sync;

  OpenReplay(AReplay);
  Close;
  ExitProcess(0);
end;

procedure TReplayDownloadWindow.ProcessReplay(const AReplayFile : String);
var
  parsedReplay   : TW3GReplay;
  replayFancyVer : String;
  C1             : Integer;
  dontRun        : Boolean;
  allhashes      : TWarhashes;
begin
  dontRun := FALSE;
  If ParseReplay(AReplayFile, parsedReplay) Then
  Begin
    replayFancyVer := EncodeReplayVersion(parsedReplay.Version.Major, parsedReplay.Version.Build);
    If replayFancyVer <> GetGameVersion Then
    Begin
      Application.CreateForm(TGameRepairWindow, GameRepairWindow);

      GameRepairWindow.VRS_REPAIR_REPAIRING_FILES := RS_WARCRAFT_PATCHING;
      GameRepairWindow.VRS_REPAIR_DONE := RS_WARCRAFT_PATCHING_DONE;
      GameRepairWindow.VRS_REPAIR_ERROR := RS_WARCRAFT_PATCHING_ERROR;

      GameRepairWindow.Hashes := GetGameHashes;
      GameRepairWindow.Hashes.Version := '?';
      allhashes := GetGameHashesAll;
      For C1 := 0 to WARHASHES_COUNT - 1 Do
        If replayFancyVer = allhashes[C1].Version Then
        Begin
          GameRepairWindow.Hashes := allhashes[C1];
          Break;
        End;
      If GameRepairWindow.Hashes.Version <> '?' Then
      Begin
        GameRepairWindow.StartAutomatically := TRUE;
        GameRepairWindow.CloseAutomatically := TRUE;
        GameRepairWindow.ShowModal;
      End
      else
      Begin
        GaugeValue := 100;
        StatusText := RS_REPLAY_PATCH_NOT_FOUND;
        StatusColor := clRed;
        Sync;
      End;
    End;

    If not FileExists(ITB(Options.WC3.Path) + parsedReplay.MapName) Then
      For C1 := 0 to DOWNLOAD_MAPS_COUNT - 1 Do
        If LowerCase(DOWNLOAD_MAPS[C1]) = LowerCase(ExtractFileName(parsedReplay.MapName)) Then
        Begin
          dontRun := TRUE;
          MapPath := parsedReplay.MapName;
          MapReplayFile := AReplayFile;
          httpGetRequest(httpDownloadMap, StringReplace(DOWNLOAD_MAPS_LINK + DOWNLOAD_MAPS[C1], ' ', '%20', [rfReplaceAll]));
          Break;
        End;
  End;

  If not dontRun Then
    RunReplay(AReplayFile);
end;

procedure TReplayDownloadWindow.httpDownloadSessionClosed(Sender: TObject);
var
  replayFile : String;
begin
  If not Terminating Then
  Begin
    replayFile := ITB(ExpandEnvString(CACHE_DIR)) + 'tempreplay.w3g';
    TMemoryStream(httpDownload.RcvdStream).SaveToFile(replayFile);
    httpFree(httpDownload);

    ProcessReplay(replayFile);
  End;
end;

procedure TReplayDownloadWindow.httpDownloadMapDocBegin(Sender: TObject);
begin
  GaugeValue := 0;
  StatusText := Format(RS_DOWNLOADING_MAP, [gaugeDownload.Value]);
  StatusColor := clWhite;
  Sync;
end;

procedure TReplayDownloadWindow.httpDownloadMapDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
begin
  If THTTPCli(Sender).ContentLength > 0 Then
  Begin
    GaugeValue := Round((THTTPCli(Sender).RcvdCount / THTTPCli(Sender).ContentLength) * 100);
    StatusText := Format(RS_DOWNLOADING_MAP, [gaugeDownload.Value]);
    StatusColor := clWhite;
    Sync;
  End;
end;

procedure TReplayDownloadWindow.httpDownloadMapSessionClosed(Sender: TObject);
begin
  If not Terminating Then
  Begin
    ForceDirectories(ExtractFilePath(ITB(Options.WC3.Path) + MapPath));
    TMemoryStream(httpDownloadMap.RcvdStream).SaveToFile(ITB(Options.WC3.Path) + MapPath);
    httpFree(httpDownloadMap);
  End;

  RunReplay(MapReplayFile);
end;

end.
