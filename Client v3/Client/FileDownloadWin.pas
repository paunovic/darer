unit FileDownloadWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, StdCtrls, SkinCtrls, OverbyteIcsWndControl,
  OverbyteIcsHttpProt, SharedVars, pngimage, ExtCtrls, Localization;

type
  TFileDownloadWindow = class;

  TThreadDownloader = class(TThread)
  private
    procedure SyncFunc;
  protected
    procedure Execute; override;
  public
    AutoStart, AutoClose : Boolean;
    URL, Filename,
    CPT_Downloading      : TStringList;
    CurrentDownload      : Integer;
    httpClient           : THTTPCli;
    Form                 : TFileDownloadWindow;

    constructor Create(ACreateSuspended : Boolean);
    destructor Destroy; override;
  end;

  TFileDownloadWindow = class(TForm, ILocalizationChanged)
    SkinForm: TspDynamicSkinForm;
    lbInfo: TspSkinStdLabel;
    gaugeDownload: TspSkinGauge;
    httpClient: THttpCli;
    imgBackground: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure httpClientDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
    procedure httpClientDocBegin(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure httpClientSessionClosed(Sender: TObject);
  private
    LOCAL_RS_DOWNLOAD_DOWNLOADING : String;

    minValue, maxValue : Integer;

    procedure ApplyLocalizationChange;
  public
    thdDownloader : TThreadDownloader;
    Result        : Integer;
  end;

var
  FileDownloadWindow: TFileDownloadWindow;

implementation

{$R *.dfm}

uses
  ComponentContainerUnit, LocalizationStr, SharedFunctions;

procedure TFileDownloadWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  If httpClient.State <> httpReady Then
    httpClient.Close;

  If Assigned(thdDownloader) Then
  Begin
    If not thdDownloader.Terminated Then
    Begin
      thdDownloader.Terminate;
      thdDownloader.WaitFor;
    End;
    thdDownloader.Free;
  End;

  Action := caFree;
end;

procedure TFileDownloadWindow.FormCreate(Sender: TObject);
begin
  self.Result := 0;
  thdDownloader := TThreadDownloader.Create(TRUE);
  thdDownloader.Form := self;
  thdDownloader.httpClient := httpClient;
  thdDownloader.AutoStart := TRUE;
  thdDownloader.AutoClose := TRUE;

  ComponentContainer.Localizer.Localize(self);
end;

procedure TFileDownloadWindow.ApplyLocalizationChange;
begin
  If (thdDownloader.CurrentDownload >= 0) and
     (thdDownloader.CurrentDownload < thdDownloader.CPT_Downloading.Count) and
     (thdDownloader.CPT_Downloading.Strings[thdDownloader.CurrentDownload] <> '') Then
    self.LOCAL_RS_DOWNLOAD_DOWNLOADING := thdDownloader.CPT_Downloading.Strings[thdDownloader.CurrentDownload]
  else
    self.LOCAL_RS_DOWNLOAD_DOWNLOADING := RS_DOWNLOAD_DOWNLOADING;
end;


procedure TFileDownloadWindow.FormShow(Sender: TObject);
begin
  If thdDownloader.AutoStart Then
    thdDownloader.Start;
end;

procedure TFileDownloadWindow.httpClientDocBegin(Sender: TObject);
begin
  minValue := Round((thdDownloader.CurrentDownload / thdDownloader.URL.Count) * 100);
  maxValue := Round(((thdDownloader.CurrentDownload + 1) / thdDownloader.URL.Count) * 100);

  gaugeDownload.Value := minValue;
  lbInfo.Caption := LOCAL_RS_DOWNLOAD_DOWNLOADING;
  lbInfo.Color := clWhite;
end;

procedure TFileDownloadWindow.httpClientDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
begin
  If THTTPCli(Sender).ContentLength > 0 Then
  Begin
    gaugeDownload.Value := minValue + Round((THTTPCli(Sender).RcvdCount / THTTPCli(Sender).ContentLength) * (maxValue - minValue));
    lbInfo.Caption := LOCAL_RS_DOWNLOAD_DOWNLOADING;
    lbInfo.Color := clWhite;
  End;
end;

procedure TFileDownloadWindow.httpClientSessionClosed(Sender: TObject);
begin
  If THTTPCli(Sender).RcvdCount = THTTPCli(Sender).ContentLength Then
  Begin
    ForceDirectories(ExtractFilePath(thdDownloader.Filename.Strings[thdDownloader.CurrentDownload]));
    DeleteFile(thdDownloader.Filename.Strings[thdDownloader.CurrentDownload]);
    TMemoryStream(THTTPCli(Sender).RcvdStream).SaveToFile(thdDownloader.Filename.Strings[thdDownloader.CurrentDownload]);
    If FileExists(thdDownloader.Filename.Strings[thdDownloader.CurrentDownload]) Then
      Inc(self.Result);
  End;
end;

constructor TThreadDownloader.Create(ACreateSuspended: Boolean);
begin
  inherited;

  URL := TStringList.Create;
  Filename := TStringList.Create;
  CPT_Downloading := TStringList.Create;
end;

destructor TThreadDownloader.Destroy;
begin
  URL.Free;
  Filename.Free;
  CPT_Downloading.Free;

  inherited;
end;

procedure TThreadDownloader.SyncFunc;
begin
  If AutoClose Then
    Form.Close;
end;

procedure TThreadDownloader.Execute;
begin
  inherited;

  CurrentDownload := 0;
  httpClient.RcvdStream := TMemoryStream.Create;
  While (CurrentDownload < URL.Count) and
        (not Terminated) Do
  Begin
    TMemoryStream(httpClient.RcvdStream).Clear;
    httpClient.URL := URL.Strings[CurrentDownload];
    httpClient.ContentTypePost := 'application/x-www-form-urlencoded';
    httpClient.Get;

    Inc(CurrentDownload);
  End;
  httpClient.RcvdStream.Free;

  Synchronize(SyncFunc);
end;

end.
