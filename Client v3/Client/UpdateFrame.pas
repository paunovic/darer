unit UpdateFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, SkinCtrls, StdCtrls, SkinExCtrls, OverbyteIcsWndControl,
  OverbyteIcsHttpProt, SharedVars;

type
  TfrUpdate = class;

  TThreadDownloader = class(TThread)
  private
    FCurrentItem      : TUpdateFileInfo;
    FCurrentIndex     : Integer;
    FNewVersionID     : String;
    FAutoUpdateSwitch : Boolean;
    FAutoUpdateParams : String;

    procedure SyncExit;
    procedure SyncHide;
    procedure PostUpdate;
  protected
    procedure Execute; override;
  public
    UpdateList     : TList;
    PostUpdateList : TStringList;
    Frame          : TfrUpdate;
    httpClient     : THTTPCli;

    destructor Destroy; override;

    property CurrentItem : TUpdateFileInfo read FCurrentItem;
    property CurrentIndex : Integer read FCurrentIndex;
    property NewVersionId : String read FNewVersionId write FNewVersionId;
    property AutoUpdateSwitch : Boolean read FAutoUpdateSwitch write FAutoUpdateSwitch;
    property AutoUpdateParams : String read FAutoUpdateParams write FAutoUpdateParams;
  end;

  TfrUpdate = class(TFrame)
    gaugeDownload: TspSkinGauge;
    lbStatus: TspSkinShadowLabel;
    httpDownloader: THttpCli;
    procedure httpDownloaderDocBegin(Sender: TObject);
    procedure httpDownloaderDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
    procedure httpDownloaderRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
  private
    FNewVersionId  : String;
    FUpdateList    : TList;
    FthdDownloader : TThreadDownloader;

    minValue, maxValue : Integer;

    function UpdateItem(const AItem : TUpdateFileInfo; const AFilename : String) : Boolean;
  public
    procedure DoUpdate(const ANewVersionId : String);
    procedure TerminateThread;

    property UpdateList : TList read FUpdateList write FUpdateList;
    property ThreadDownloader : TThreadDownloader read FthdDownloader write FthdDownloader;
  end;

implementation

{$R *.dfm}

uses
  ComponentContainerUnit, SharedFunctions, LoginWin;

procedure DisposeList(AList : TList);
var
  C1 : Integer;
begin
  For C1 := 0 to AList.Count - 1 Do
    Dispose(PUpdateFileInfo(AList[C1]));
  AList.Clear;
  FreeAndNil(AList);
end;

procedure TfrUpdate.DoUpdate(const ANewVersionId : String);
begin
  minValue := 0;
  maxValue := 100;
  gaugeDownload.Value := 0;

  FNewVersionId := ANewVersionId;
  FthdDownloader := TThreadDownloader.Create(TRUE);
  FthdDownloader.NewVersionId := FNewVersionId;
  FthdDownloader.AutoUpdateSwitch := ComponentContainer.AutoUpdateSwitch;
  FthdDownloader.AutoUpdateParams := ComponentContainer.AutoUpdateParams;
  FthdDownloader.UpdateList := TList.Create;
  FthdDownloader.UpdateList.Assign(updateList);
  FthdDownloader.PostUpdateList := TStringList.Create;
  FthdDownloader.httpClient := httpDownloader;
  FthdDownloader.Frame := self;
  FthdDownloader.Start;
end;

procedure TfrUpdate.httpDownloaderDocBegin(Sender: TObject);
begin
  minValue := Round((FthdDownloader.CurrentIndex / FthdDownloader.UpdateList.Count) * 100);
  maxValue := Round(((FthdDownloader.CurrentIndex + 1) / FthdDownloader.UpdateList.Count) * 100);

  gaugeDownload.Value := minValue;
end;

procedure TfrUpdate.httpDownloaderDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
begin
  If THTTPCli(Sender).ContentLength > 0 Then
    gaugeDownload.Value := minValue + Round((THTTPCli(Sender).RcvdCount / THTTPCli(Sender).ContentLength) * (maxValue - minValue));
end;

procedure TfrUpdate.httpDownloaderRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  fileName : String;
begin
  If THTTPCli(Sender).RcvdCount = THTTPCli(Sender).ContentLength Then
  Begin
    fileName := ITB(ITB(SelfPath) + FNewVersionId) + FthdDownloader.CurrentItem.Name;
    ForceDirectories(ExtractFilePath(fileName));
    TMemoryStream(THTTPCli(Sender).RcvdStream).Position := 0;
    TMemoryStream(THTTPCli(Sender).RcvdStream).SaveToFile(fileName + '.new');
    If FileExists(fileName + '.new') Then
    Begin
      DeleteFile(fileName);
      RenameFile(fileName + '.new', fileName);
      UpdateItem(FthdDownloader.CurrentItem, fileName);
    End;
  End;
end;

procedure TfrUpdate.TerminateThread;
begin
  httpDownloader.Close;
  FthdDownloader.Terminate;
  FthdDownloader.WaitFor;
  FreeAndNil(FthdDownloader);
end;

destructor TThreadDownloader.Destroy;
begin
  DisposeList(UpdateList);
  PostUpdateList.Free;

  inherited;
end;

procedure TThreadDownloader.Execute;
var
  C1    : Integer;
  fname : String;
begin
  httpClient.RcvdStream := TMemoryStream.Create;
  For C1 := 0 to UpdateList.Count - 1 Do
  Begin
    If Terminated Then
      Break;

    FCurrentItem := TUpdateFileInfo(UpdateList[C1]^);
    FCurrentIndex := C1;

    fname := ETB(SelfPath) + ITB(RemoveBackslashes(FCurrentItem.Path)) + FCurrentItem.Name;
    If Pos('.patch', fname) > 0 Then
      Delete(fname, Pos('.patch', fname), 6);

    If LowerCase(MD5File(fname)) = LowerCase(FCurrentItem.Hash) Then
      Continue;

    TMemoryStream(httpClient.RcvdStream).Clear;
    httpClient.URL := 'update.darer.com/ipn/download/' + FCurrentItem.URL;
    httpClient.ContentTypePost := 'application/x-www-form-urlencoded';
    httpClient.Get;
  End;
  httpClient.RcvdStream.Free;

  If not Terminated Then
    PostUpdate;
end;

procedure TThreadDownloader.SyncExit;
begin
  ComponentContainer.CanExit := TRUE;
  ComponentContainer.Close;
end;

procedure TThreadDownloader.SyncHide;
begin
  Options.VersionId := FNewVersionId;
  SaveSettings;
  LoginWindow.frUpdate.Hide;
  LoginWindow.frLogin.btLogin.OnClick(LoginWindow);
end;

procedure TThreadDownloader.PostUpdate;
var
  batchFile : String;
  TFile     : TextFile;
begin
  If PostUpdateList.Count > 0 Then
  Begin
    repeat
      batchFile := ITB(SelfPath) + MakeRandomStr(12) + '.bat';
    until not FileExists(batchFile);

    AssignFile(TFile, batchFile);
    Rewrite(TFile);
    WriteLn(TFile, 'PING 1.1.1.1 -n 1 -w 1000'); // 1 sec delay before we start overwriting files

    WriteLn(TFile, ':PROCESS_CHECK'); // loop while Darer.exe is running
    WriteLn(TFile, 'TASKLIST /FI "IMAGENAME eq Darer.exe" 2>nul | find /I /N "Darer.exe">nul');
    WriteLn(TFile, 'IF "%ERRORLEVEL%"=="0" GOTO PROCESS_CHECK');

    While (PostUpdateList.Count > 0) and
          (not Terminated) Do
    Begin
      WriteLn(TFile, PostUpdateList[0]);
      PostUpdateList.Delete(0);
    End;

    WriteLn(TFile, Format('RMDIR /S /Q "%s"', [ITB(SelfPath) + FNewVersionId]));

    If FAutoUpdateSwitch Then
      WriteLn(TFile, Format('%sUpdater.exe /exech "%s|%s"', [ITB(SelfPath), SelfExe, FAutoUpdateParams]))
    else
      WriteLn(TFile, Format('%sUpdater.exe /execs "%s"', [ITB(SelfPath), SelfExe]));

    WriteLn(TFile, Format('DEL "%s"', [batchFile]));
    CloseFile(TFile);
    ExecuteFile(PWideChar(batchFile), nil, PWideChar(ExtractFilePath(batchFile)), SW_HIDE);
    Synchronize(SyncExit);
  End
  else
  Begin
    RemoveDir(ITB(SelfPath) + FNewVersionId);
    Synchronize(SyncHide);
  End;
end;

function TfrUpdate.UpdateItem(const AItem: TUpdateFileInfo; const AFilename: String): Boolean;
var
  oldFileName, newFileName : String;
begin
  result := FALSE;
  Case AItem.FileType of
    ftFile  : Begin
                oldFileName := ETB(SelfPath) + ITB(RemoveBackslashes(AItem.Path)) + AItem.Name;
                ForceDirectories(ExtractFilePath(oldFileName));
                CopyFile(PChar(AFilename), PChar(oldFileName), FALSE);
                result := LowerCase(MD5File(oldFileName)) = LowerCase(AItem.Hash);
                If (not FileExists(oldFileName)) or
                   (not result) Then
                Begin
                  FthdDownloader.PostUpdateList.Add(Format('COPY /Y "%s" "%s"', [AFilename, oldFileName]));
                  FthdDownloader.PostUpdateList.Add(Format('DEL "%s"', [AFilename]));
                End
                else
                  DeleteFile(AFilename);
              End;
    ftPatch : Begin
                oldFileName := ETB(SelfPath) + ITB(RemoveBackslashes(AItem.Path)) + AItem.Name;
                If Pos('.patch', oldFileName) > 0 Then
                  Delete(oldFileName, Pos('.patch', oldFileName), 6);
                newFileName := oldFileName + '.new';
                DeleteFile(newFileName);
                ForceDirectories(ExtractFilePath(newFileName));
                ExecuteFile(PWideChar(ITB(SelfPath) + 'bspatch.exe'), PWideChar(Format('"%s" "%s" "%s"', [oldFileName, newFileName, AFilename])), nil, SW_HIDE);
                If FileExists(newFileName) Then
                Begin
                  ForceDirectories(ExtractFilePath(oldFileName));
                  CopyFile(PWideChar(newFileName), PWideChar(oldFileName), FALSE);
                  result := MD5File(oldFileName) = MD5File(newFileName);
                  If (not FileExists(oldFileName)) or
                     (not result) Then
                  Begin
                    FthdDownloader.PostUpdateList.Add(Format('COPY /Y "%s" "%s"', [newFilename, oldFilename]));
                    FthdDownloader.PostUpdateList.Add(Format('DEL "%s"', [newFilename]));
                  End
                  else
                  Begin
                    DeleteFile(newFileName);
                    DeleteFile(AFilename);
                  End;
                End
                else
                Begin
                  FthdDownloader.PostUpdateList.Add(Format('START /B "" "%sbspatch.exe" "%s" "%s" "%s"', [ITB(SelfPath), oldFilename, newFilename, AFilename]));
                  FthdDownloader.PostUpdateList.Add('PING 1.1.1.1 -n 1 -w 1000');
                  FthdDownloader.PostUpdateList.Add(Format('COPY /Y "%s" "%s"', [newFilename, oldFilename]));
                  FthdDownloader.PostUpdateList.Add(Format('DEL "%s"', [newFilename]));
                End;
              End;
  End;
end;


end.
