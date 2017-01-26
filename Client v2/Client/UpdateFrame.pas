unit UpdateFrame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, SkinCtrls, sppngimagelist, SkinExCtrls,
  ZipForge, JvComponentBase, JvThread, OverbyteIcsWndControl,
  OverbyteIcsHttpProt, ExtCtrls;

type
  TfrUpdate = class(TFrame)
    imLogo: TspPngImageView;
    gaugeUpdateProgress: TspSkinGauge;
    SkinFrame: TspSkinFrame;
    lbStatus: TspSkinShadowLabel;
    ZipForge: TZipForge;
    httpUpdate: THttpCli;
    tiHideUpdateFrame: TTimer;
    procedure UpdateExit;
    procedure SetStatus(const AText : String; const AColor : TColor = $00BFBAAE);
    procedure ZipForgeProcessFileFailure(Sender: TObject; FileName: WideString; Operation: TZFProcessOperation; NativeError, ErrorCode: Integer; ErrorMessage: WideString; var Action: TZFAction);
    procedure CopyDirectory(const AFrom, ATo, AMask : String; const ATotalFiles : Integer; var ACurrentFiles : Integer; var ABatchFileList : TStringList);
    procedure httpUpdateDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
    procedure httpUpdateDocBegin(Sender: TObject);
    procedure DoUpdate;
    procedure DoGProxyUpdate;
    procedure tiHideUpdateFrameTimer(Sender: TObject);
    procedure ZipForgeOverallProgress(Sender: TObject; Progress: Double; Operation: TZFProcessOperation; ProgressPhase: TZFProgressPhase; var Cancel: Boolean);
    procedure ZipForgeDiskFull(Sender: TObject; VolumeNumber: Integer;
      VolumeFileName: WideString; var Cancel: Boolean);
  private
  public
    Updating  : Boolean;
  end;

implementation

{$R *.dfm}

uses
  ComponentModule, SharedData, SharedVars, Localization, LoginWin, ShellAPI,
  LoginFrame;

procedure TfrUpdate.UpdateExit;
begin
  ComponentModuleWindow.Free;
  ExitProcess(0);
end;

procedure TfrUpdate.SetStatus(const AText : String; const AColor : TColor = $00BFBAAE);
begin
  If lbStatus.Font.Color <> AColor Then
    lbStatus.Font.Color := AColor;

  If lbStatus.Caption <> AText Then
    lbStatus.Caption := AText;
end;

procedure TfrUpdate.CopyDirectory(const AFrom, ATo, AMask : String; const ATotalFiles : Integer; var ACurrentFiles : Integer; var ABatchFileList : TStringList);
var
  SearchRec  : TSearchRec;
  IsFound    : Boolean;
  littlefile : String;
begin
  If not DirectoryExists(ATo) Then
    ForceDirectories(ATo);

  IsFound := FindFirst(ITB(AFrom) + '*.*', faAnyFile, SearchRec) = 0;
  While IsFound Do
  Begin
    If (SearchRec.Name <> '.') and (SearchRec.Name <> '..') Then
    Begin
      If SearchRec.Attr and faDirectory = faDirectory Then
        CopyDirectory(ITB(ITB(AFrom) + SearchRec.Name), ITB(ITB(ATo) + SearchRec.Name), AMask, ATotalFiles, ACurrentFiles, ABatchFileList)
      else
        If MatchStrings(AMask, SearchRec.Name, FALSE) Then
        Begin
          littlefile := ITB(AFrom) + SearchRec.Name;
          If FileExists(littlefile) Then
          Begin
            If not CopyFile(PChar(littlefile), PChar(ITB(ATo) + SearchRec.Name), FALSE) Then
              ABatchFileList.Add(Format('COPY /Y "%s" "%s"', [littlefile, ITB(ATo) + SearchRec.Name]));
            Inc(ACurrentFiles);
            gaugeUpdateProgress.Value := 50 + Round((ACurrentFiles / ATotalFiles) * 50);
            SetStatus(Format(RS_UPDATE_INSTALLING, [gaugeUpdateProgress.Value]), clWhite);
            Application.ProcessMessages;
          End;
        End;
    End;
    IsFound := FindNext(SearchRec) = 0;
  End;
  FindClose(SearchRec);
end;

procedure TfrUpdate.ZipForgeProcessFileFailure(Sender: TObject; FileName: WideString; Operation: TZFProcessOperation; NativeError, ErrorCode: Integer; ErrorMessage: WideString; var Action: TZFAction);
begin
  SetStatus(ErrorMessage, clRed);
end;

procedure TfrUpdate.httpUpdateDocData(Sender: TObject; Buffer: Pointer; Len: Integer);
begin
  If THTTPCli(Sender).ContentLength > 0 Then
  Begin
    gaugeUpdateProgress.Value := 100 * THTTPCli(Sender).RcvdCount div THTTPCli(Sender).ContentLength;
    SetStatus(Format(RS_UPDATE_DOWNLOADING, [gaugeUpdateProgress.Value]), clWhite);
  End;
end;

procedure TfrUpdate.httpUpdateDocBegin(Sender: TObject);
begin
  SetStatus(Format(RS_UPDATE_DOWNLOADING, [0]), clWhite);
  gaugeUpdateProgress.Value := 0;
end;

procedure TfrUpdate.DoGProxyUpdate;
var
  dirUpdate : String;
  batchFile : String;
  updateok  : Boolean;
  pinfo     : TProcessInformation;
  gotUpdate : Boolean;
  currfiles : Integer;
  batchlist : TStringList;
  TFile     : TextFile;
  C1        : Integer;
begin
  gaugeUpdateProgress.Show;

  repeat
    dirUpdate := SelfPath + MakeRandomString(16);
  until not DirectoryExists(dirUpdate);

  If not FileExists(ClientSettings.GProxyURL) Then
  Begin
    ZipForge.InMemory := TRUE;
    ZipForge.FileName := '';

    gotUpdate := FALSE;
    httpUpdate.RcvdStream := TMemoryStream.Create;
    httpUpdate.URL := ClientSettings.GProxyURL;
    try
      httpUpdate.Get;
      gotUpdate := TRUE;
    except
      httpUpdate.Close;
      SetStatus(RS_UPDATE_ERROR_DOWNLOAD, clRed);
    end;
  End
  else
  Begin
    ZipForge.FileName := ClientSettings.GProxyURL;
    gotUpdate := TRUE;
  End;

  If gotUpdate Then
  Begin
    Updating := TRUE;
    gaugeUpdateProgress.Value := 0;
    SetStatus(Format(RS_UPDATE_INSTALLING, [gaugeUpdateProgress.Value]), clWhite);
    Application.ProcessMessages;

    updateok := FALSE;

    If (ZipForge.FileName = '') or
       (ZipForge.IsValidArchiveFile) Then
    Begin
      If ZipForge.InMemory Then
        ZipForge.OpenArchive(httpUpdate.RcvdStream, FALSE)
      else
        ZipForge.OpenArchive;

      try
        ZipForge.BaseDir := dirUpdate;
        ZipForge.ExtractFiles('*.*');
        ZipForge.CloseArchive;
        updateok := TRUE;
      except
        SetStatus(RS_UPDATE_ERROR_INSTALL, clRed);
      end;
    End
    else
      SetStatus(RS_UPDATE_INVALID_FILE, clRed);

    If updateok Then
    Begin
      gaugeUpdateProgress.Value := 50;
      SetStatus(Format(RS_UPDATE_INSTALLING, [gaugeUpdateProgress.Value]), clWhite);
      currfiles := 0;
      batchlist := TStringList.Create;
      batchlist.Clear;
      CopyDirectory(dirUpdate, SelfPath + ExtractFilePath(GPROXY_EXE), '*.*', EnumerateFiles(dirUpdate, '*.*'), currfiles, batchlist);

      If batchlist.Count > 0 Then
      Begin
        repeat
          batchFile := SelfPath + MakeRandomString(16) + '.bat';
        until not FileExists(batchFile);

        AssignFile(TFile, batchFile);
        Rewrite(TFile);
          WriteLn(TFile, 'PING 1.1.1.1 -n 1 -w 1000'); // 1 sec delay before we start overwriting files
          For C1 := 0 to batchlist.Count - 1 Do
            WriteLn(TFile, batchlist.Strings[C1]);
          WriteLn(TFile, Format('START "" "%s" -autologin', [SelfExe]));
          WriteLn(TFile, Format('RMDIR /S /Q "%s"', [dirUpdate]));
          WriteLn(TFile, Format('DEL "%s"', [batchFile]));
        CloseFile(TFile);
        batchlist.Free;
        ExecuteFile(batchFile, Format('"%s"', [batchFile]), SelfPath, 0, SW_HIDE, pinfo);
        UpdateExit;
      End
      else
      Begin
        batchlist.Free;
        DeleteDirectory(dirUpdate);
        Hide;
      End;
    End;
    Updating := FALSE;
  End
  else
    SetStatus(RS_UPDATE_UNABLE_TO_DOWNLOAD, clRed);

  httpFree(httpUpdate);

  tiHideUpdateFrame.Enabled := TRUE;
  gaugeUpdateProgress.Hide;
end;

procedure TfrUpdate.DoUpdate;
var
  dirUpdate : String;
  batchFile : String;
  updateok  : Boolean;
  pinfo     : TProcessInformation;
  gotUpdate : Boolean;
  currfiles : Integer;
  batchlist : TStringList;
  TFile     : TextFile;
  C1        : Integer;
begin
  gaugeUpdateProgress.Show;
  
  repeat
    dirUpdate := SelfPath + MakeRandomString(16);
  until not DirectoryExists(dirUpdate);

  If not FileExists(ClientSettings.FullClient) Then
  Begin
    ZipForge.InMemory := TRUE;
    ZipForge.FileName := '';

    gotUpdate := FALSE;
    httpUpdate.RcvdStream := TMemoryStream.Create;
    httpUpdate.URL := ClientSettings.FullClient;
    try
      httpUpdate.Get;
      gotUpdate := TRUE;
    except
      httpUpdate.Close;
      SetStatus(RS_UPDATE_ERROR_DOWNLOAD, clRed);
    end;
  End
  else
  Begin
    ZipForge.FileName := ClientSettings.FullClient;
    gotUpdate := TRUE;
  End;

  If gotUpdate Then
  Begin
    Updating := TRUE;
    gaugeUpdateProgress.Value := 0;
    SetStatus(Format(RS_UPDATE_INSTALLING, [gaugeUpdateProgress.Value]), clWhite);
    Application.ProcessMessages;

    updateok := FALSE;

    If (ZipForge.FileName = '') or
       (ZipForge.IsValidArchiveFile) Then
    Begin
      If ZipForge.InMemory Then
        ZipForge.OpenArchive(httpUpdate.RcvdStream, FALSE)
      else
        ZipForge.OpenArchive;

      try
        ZipForge.BaseDir := dirUpdate;
        ZipForge.ExtractFiles('*.*');
        ZipForge.CloseArchive;
        updateok := TRUE;
      except
        SetStatus(RS_UPDATE_ERROR_INSTALL, clRed);
      end;
    End
    else
      SetStatus(RS_UPDATE_INVALID_FILE, clRed);

    If updateok Then
    Begin
      gaugeUpdateProgress.Value := 50;
      SetStatus(Format(RS_UPDATE_INSTALLING, [gaugeUpdateProgress.Value]), clWhite);
      currfiles := 0;
      batchlist := TStringList.Create;
      batchlist.Clear;
      CopyDirectory(dirUpdate, SelfPath, '*.*', EnumerateFiles(dirUpdate, '*.*'), currfiles, batchlist);

      If batchlist.Count > 0 Then
      Begin
        repeat
          batchFile := SelfPath + MakeRandomString(16) + '.bat';
        until not FileExists(batchFile);

        AssignFile(TFile, batchFile);
        Rewrite(TFile);
          WriteLn(TFile, 'PING 1.1.1.1 -n 1 -w 1000'); // 1 sec delay before we start overwriting files
          For C1 := 0 to batchlist.Count - 1 Do
            WriteLn(TFile, batchlist.Strings[C1]);
          WriteLn(TFile, Format('START "" "%s" -autologin', [SelfExe]));
          WriteLn(TFile, Format('RMDIR /S /Q "%s"', [dirUpdate]));
          WriteLn(TFile, Format('DEL "%s"', [batchFile]));
        CloseFile(TFile);
        batchlist.Free;
        ExecuteFile(batchFile, Format('"%s"', [batchFile]), SelfPath, 0, SW_HIDE, pinfo);
        UpdateExit;
      End
      else
      Begin
        batchlist.Free;
        DeleteDirectory(dirUpdate);
        DestroyInstanceMutex;
        ExecuteFile(SelfExe, Format('"%s"', [SelfExe]), SelfPath, 0, SW_SHOW, pinfo);
        UpdateExit;
      End;
    End;
    Updating := FALSE;
  End
  else
    SetStatus(RS_UPDATE_UNABLE_TO_DOWNLOAD, clRed);

  httpFree(httpUpdate);

  tiHideUpdateFrame.Enabled := TRUE;
  gaugeUpdateProgress.Hide;
end;

procedure TfrUpdate.tiHideUpdateFrameTimer(Sender: TObject);
begin
  Hide;
  LoginWindow.frLogin.Show;
  tiHideUpdateFrame.Enabled := FALSE;
end;

procedure TfrUpdate.ZipForgeOverallProgress(Sender: TObject; Progress: Double; Operation: TZFProcessOperation; ProgressPhase: TZFProgressPhase; var Cancel: Boolean);
begin
  gaugeUpdateProgress.Value := Round(Progress / 2);
  SetStatus(Format(RS_UPDATE_INSTALLING, [gaugeUpdateProgress.Value]), clWhite);
end;

procedure TfrUpdate.ZipForgeDiskFull(Sender: TObject; VolumeNumber: Integer; VolumeFileName: WideString; var Cancel: Boolean);
begin
  ShowMessage('Unable to update. Please run client as administrator!');
end;

end.
