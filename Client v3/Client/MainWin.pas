unit MainWin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DynamicSkinForm, SharedVars, SkinHint, JvComponentBase,
  StdCtrls, SkinBoxCtrls, SkinExCtrls, SkinCtrls, superobject, OverbyteIcsWndControl,
  OverbyteIcsHttpProt, ExtCtrls, Localization, GameProcesser, OverbyteIcsWSocket,
  GamingPlatform, DotaParser, W3GSParser, W3GParser, W3GParser_Types, DotaParser_Types,
  Generics.Collections;

{$I defines.inc}

type
  TUserData = record
                EMail    : String;
                Password : String;
                Username : String;
                ID       : String;
              end;

  TMainWindow = class(TForm, ILocalizationChanged)
    SkinForm: TspDynamicSkinForm;
    btSettings: TspSkinSpeedButton;
    SkinHint: TspSkinHint;
    btLogout: TspSkinSpeedButton;
    timerUpdateCheck: TTimer;
    httpUpdateCheck: THttpCli;
    Button1: TButton;
    timerGamepost: TTimer;
    httpGamepost: THttpCli;
    paTextContainer: TspSkinPanel;
    spSkinPanel1: TspSkinPanel;
    spSkinPanel2: TspSkinPanel;
    spSkinPanel3: TspSkinPanel;
    bevelTextDivider: TspSkinBevel;
    lbTips: TspSkinStdLabel;
    lbHowItWorks: TspSkinStdLabel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure SkinFormMinimize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure pmExitButtonExitClick(Sender: TObject);
    procedure btSettingsClick(Sender: TObject);
    procedure btLogoutClick(Sender: TObject);
    procedure timerUpdateCheckTimer(Sender: TObject);
    procedure httpUpdateCheckRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure WSocketError(Sender: TObject);
    procedure WSocketReverseDnsLookupDone(Sender: TObject; Error: Word);
    procedure WSocketDataAvailable(Sender: TObject; ErrCode: Word);
    procedure Button1Click(Sender: TObject);
    procedure timerGamepostTimer(Sender: TObject);
    procedure httpGamepostRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
    procedure lbTipsClick(Sender: TObject);
    procedure lbHowItWorksClick(Sender: TObject);
  private
    type
      TIPItem = record
                  IP    : String;
                  RDNS  : String;
                end;
    var
      WSockets        : Array of TWSocket;
      FGameProcesser  : TGameProcesser;
      FGamingPlatform : TGamingPlatform;
      FDotaParser     : TDotaParser;
      FW3GSParser     : TW3GSParser;
      GamepostData    : String;
      FIPTable        : TList<TIPItem>;

    fuckingHash : String;

    procedure ApplyLocalizationChange;
    procedure WMAfterShow(var Msg: TMessage); message WM_AFTER_SHOW;
    function CloseListener(const AIndex : Integer) : Boolean;
    procedure CreateListeners;
    procedure CloseListeners;
    function ListenedAdapters : Integer;
    procedure OnNewReplay(const AReplayFile : String);
    procedure ProcessGame(const AReplayFile : String);
    procedure UpdateGUI;
    function GetWinner(const AReplayParser : TW3GParser; const ADotaParser : TDotaParser) : TDotaGame_Winner;
    function GetFFWinner(const AReplayParser: TW3GParser): TDotaGame_Winner;
    function MakeJSON(const AReplayInfo : TW3GParser; var AError : String) : ISuperObject;
    procedure ReportError(const AType, AError : String; const AData : String = '');
    procedure OnTempReplayCreated(const ATempReplay : String);
    procedure OnTempReplayDeleted(const ATempReplay : String);
    procedure CopyAdMessage;
    procedure DotaOnModeChoosed(const AMode : String);
    procedure DotaOnGameEnded;
    function SearchIPTableItem(const AIP: String; var AItem: TIPItem): Boolean;
  public
    UserData : TUserData;

    procedure CloseForm;
  end;

var
  MainWindow : TMainWindow;

implementation

{$R *.dfm}

uses
  ComponentContainerUnit, SharedFunctions, LocalizationStr, Winsock2, Socktypes,
  SBEncoding, Clipbrd;

const
  HEADER_COLOR_CONNECTING       = $00BFBAAE;
  HEADER_COLOR_GAME_WAITING     = $00BFBAAE;
  HEADER_COLOR_GAME_IN_PROGRESS = $00BFBAAE;
  HEADER_COLOR_GAME_ENDED       = $00BFBAAE;
  HEADER_COLOR_ERROR            = clRed;

procedure TMainWindow.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  DbgLn('TMainWindow.FormCloseQuery()');

  If ComponentContainer.CanClose Then
    CanClose := TRUE
  else
  Begin
    Application.Minimize;
    ComponentContainer.HideClient;
    CanClose := FALSE;
  End;
end;

procedure TMainWindow.SkinFormMinimize(Sender: TObject);
begin
  DbgLn('TMainWindow.SkinFormMinimize()');

  ComponentContainer.HideClient;
end;

procedure TMainWindow.timerGamepostTimer(Sender: TObject);
begin
  If GamepostData <> '' Then
  Begin
    httpGamepost.Agent := UserData.Username;
    httpPostRequest(httpGamepost, URL_GAMEPOST, GamepostData);

    GamepostData := '';
  End;

  timerGamepost.Enabled := FALSE;
end;

procedure TMainWindow.timerUpdateCheckTimer(Sender: TObject);
begin
  If httpUpdateCheck.State = httpReady Then
    httpGetRequest(httpUpdateCheck, Format(URL_UPDATECHECK, [Options.VersionID]));
end;

procedure TMainWindow.FormCreate(Sender: TObject);
begin
  DbgLn('TMainWindow.FormCreate()');

  ComponentContainer.Localizer.Localize(self);

  ComponentContainer.pmTrayLogout.Visible := TRUE;
  LoadSettings;

  FIPTable := TList<TIPItem>.Create;
end;

procedure TMainWindow.CloseForm;
begin
  DbgLn('TMainWindow.CloseForm()');

  CloseListeners;

  FGamingPlatform.Free;
  FDotaParser.Free;
  FW3GSParser.Free;

  FGameProcesser.Terminate;
  FGameProcesser.WaitFor;
  FGameProcesser.Free;

  FIPTable.Free;
end;

procedure TMainWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  DbgLn('TMainWindow.FormClose()');

  CloseForm;
  Action := caFree;
end;

procedure TMainWindow.WMAfterShow(var Msg: TMessage);
begin
  DbgLn('TMainWindow.WMAfterShow()');

  If (Options.MinimizeOnLogin) or
     (ComponentContainer.HideSwitch) Then
  Begin
    Application.Minimize;
    ComponentContainer.TrayIcon.HideTaskbarIcon;
    ComponentContainer.HideSwitch := FALSE;
  End;

  FGameProcesser := TGameProcesser.Create(TRUE);
  FGameProcesser.ReplayFile := ITB(ExtractFilePath(Options.WarcraftExe)) + 'replay\LastReplay.w3g';
  FGameProcesser.TempReplay := ITB(ExtractFilePath(Options.WarcraftExe)) + 'TempReplay.w3g';
  FGameProcesser.CheckHash := FALSE;
  FGameProcesser.OnNewReplay := OnNewReplay;
  FGameProcesser.OnTempReplayCreated := OnTempReplayCreated;
  FGameProcesser.OnTempReplayDeleted := OnTempReplayDeleted;
  FGameProcesser.Start;

  FGamingPlatform := TGamingPlatform.Create;
  FDotaParser := TDotaParser.Create;
  FDotaParser.OnModeChoosed := DotaOnModeChoosed;
  FDotaParser.OnGameEnded := DotaOnGameEnded;

  FW3GSParser := TW3GSParser.Create;

  CreateListeners;
end;

procedure TMainWindow.FormShow(Sender: TObject);
begin
  PostMessage(Self.Handle, WM_AFTER_SHOW, 0, 0);
end;

procedure TMainWindow.httpGamepostRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  JSON     : ISuperObject;
  response : TStringStream;
begin
  DbgLn(Format('TMainWindow.httpGamepostRequestDone(StatusCode=%d, ErrCode=%d)', [THTTPCli(Sender).StatusCode, ErrCode]));

  response := TStringStream.Create;
  If ErrCode <> 0 Then
  Begin
    (THTTPCli(Sender).RcvdStream as TMemoryStream).Position := 0;
    ReportError('Gamepost API', Format('request done, ErrCode = %d', [ErrCode]));
//    memo.Text := 'errcode = ' + IntToStr(ErrCode);
  End
  else
  Begin
    If THTTPCli(Sender).StatusCode <> 200 Then
    Begin
      ReportError('Gamepost API', Format('request done, StatusCode = %d', [THTTPCli(Sender).StatusCode]));
//      memo.Lines.Add('statuscode = ' + IntToStr(THTTPCli(Sender).StatusCode) + '. Check C:\statuscode.txt');
//      (THTTPCli(Sender).RcvdStream as TMemoryStream).SaveToFile('C:\statuscode.txt');
    End
    else
    Begin
      If THTTPCli(Sender).RcvdCount > 0 Then
      Begin
        response.LoadFromStream(THTTPCli(Sender).RcvdStream);

        {$IFDEF DEBUGSWITCH}
        if Debug then
          response.SaveToFile('C:\' + fuckingHash + '-response-gamepost.txt');
        {$ENDIF}
//        TMemoryStream(THTTPCli(Sender).RcvdStream).SaveToFile('C:\' + fuckingHash + '.txt');
{        JSON := TSuperObject.ParseStream(THTTPCli(Sender).RcvdStream, FALSE);
        response := JSON.AsString;}
//        memo.Text := response;
        JSON := nil;
      End
      else
      Begin
        ReportError('Gamepost API', 'request done, blank response');
      End;
    End;
  End;
  response.Free;

  httpFree(THTTPCli(Sender));
end;

procedure TMainWindow.httpUpdateCheckRequestDone(Sender: TObject; RqType: THttpRequest; ErrCode: Word);
var
  JSON : ISuperObject;
begin
  DbgLn(Format('TMainWindow.httpUpdateCheckRequestDone(StatusCode=%d, ErrCode=%d)', [THTTPCli(Sender).StatusCode, ErrCode]));

  If ErrCode <> 0 Then
  Begin
  End
  else
  Begin
    If THTTPCli(Sender).StatusCode <> 200 Then
    Begin
    End
    else
    Begin
      If THTTPCli(Sender).RcvdCount > 0 Then
      Begin
        THTTPCli(Sender).RcvdStream.Position := 0;
        JSON := TSuperObject.ParseStream(THTTPCli(Sender).RcvdStream, FALSE);
        If JSON['result'].S['version'] <> '' Then
        Begin
          DbgLn(Format('TMainWindow.httpUpdateCheckRequestDone(Current Version: %s, Server Version: %s)', [Options.VersionId, JSON['result'].S['version']]));
          If JSON['result'].S['version'] = Options.VersionId Then
          Begin
            // right version...
          End
          else
          Begin
            if not IsProcessRunning(['war3.exe']) then
              ComponentContainer.LogoutAndUpdate;
          End;
        End
        else
        Begin
          // blank version ID ???
        End;
      End;
    End;
  End;
end;

procedure TMainWindow.lbTipsClick(Sender: TObject);
begin
  CopyAdMessage;
end;

procedure TMainWindow.lbHowItWorksClick(Sender: TObject);
begin
  ShellOpen(Format('http://www.darer.com/%s/dota/statistics', [UserData.Username]));
end;

procedure TMainWindow.pmExitButtonExitClick(Sender: TObject);
begin
  DbgLn('TMainWindow.pmExitButtonExitClick()');

  MainWindow.Enabled := FALSE;
  ComponentContainer.pmTrayExit.Click;

  If Assigned(MainWindow) Then
    MainWindow.Enabled := TRUE;
end;

procedure TMainWindow.btLogoutClick(Sender: TObject);
begin
  DbgLn('TMainWindow.btLogoutClick()');

  MainWindow.Enabled := FALSE;
  ComponentContainer.pmTrayLogout.Click;

  If Assigned(MainWindow) Then
    MainWindow.Enabled := TRUE;
end;

procedure TMainWindow.btSettingsClick(Sender: TObject);
begin
  DbgLn('TMainWindow.btSettingsClick()');

  ComponentContainer.pmTraySettings.Click;
end;

procedure TMainWindow.Button1Click(Sender: TObject);

  procedure PostGame(const AFile : String);
  var
    SFile : TextFile;
    text  : String;
  begin
    AssignFile(SFile, AFile);
    Reset(SFile);
    Read(SFile, text);
    CloseFile(SFile);

    httpPostRequest(httpGamepost, URL_GAMEPOST, 'data=' + text);
  end;

var
  replayParser : TW3GParser;
  C1, C2       : Integer;
  newv         : Integer;
begin     {
  replayParser := TW3GParser.Create;

  for C1 := 1 to 14 do
  begin
    replayParser.ReplayFile := Format('D:\1\%d.w3g', [C1]);
    if replayParser.Parse then
    begin
      for C2 := Low(replayParser.ReplayInfo.Slots) to High(replayParser.ReplayInfo.Slots) do
      begin
        If CheckAndModifyValue(C2, newv) then
        begin
          memo1.Lines.Add(Format('[%d]: %s [%d/%d/%d]', [C2, replayParser.ReplayInfo.Slots[C2].Name, replayParser.DotaParser.GameData.PlayersEnd[newv].Kills,
          replayParser.DotaParser.GameData.PlayersEnd[newv].Deaths, replayParser.DotaParser.GameData.PlayersEnd[newv].Assists]));
        end;
      end;
    end;
  end;

  replayParser.Free;   }

//  PostGame('C:\lastgame-enc.txt');
end;

procedure TMainWindow.ApplyLocalizationChange;
begin
//
end;

procedure TMainWindow.CreateListeners;
var
  C1 : Integer;
begin
  DbgLn('TMainWindow.CreateListeners()');

  SetLength(WSockets, NetworkInterfaces.Count);
  For C1 := Low(NetworkInterfaces.Items) to High(NetworkInterfaces.Items) Do
  Begin
    WSockets[C1] := TWSocket.Create(MainWindow);
    With WSockets[C1] Do
    Begin
      Proto := 'raw_ip';
      ComponentOptions := [wsoSIO_RCVALL];
      Addr := GetUnicastIP(NetworkInterfaces.Items[C1].FirstUnicastAddress);
      Port := '0';
      OnError := WSocketError;
      OnDataAvailable := WSocketDataAvailable;
      OnDnsLookupDone := WSocketReverseDnsLookupDone;

      Listen;
    End;
  End;
end;

function TMainWindow.CloseListener(const AIndex : Integer) : Boolean;
begin
  DbgLn(Format('TMainWindow.CloseListener(%d)', [AIndex]));

  result := FALSE;
  If (AIndex >= 0) and
     (AIndex <= High(WSockets)) and
     (Assigned(WSockets[AIndex])) Then
  Begin
    WSockets[AIndex].Close;
    FreeAndNil(WSockets[AIndex]);
    result := TRUE;
  End;
end;

procedure TMainWindow.CloseListeners;
var
  C1 : Integer;
begin
  DbgLn('TMainWindow.CloseListeners()');

  For C1 := Low(WSockets) to High(WSockets) Do
    CloseListener(C1);

  SetLength(WSockets, 0);
end;

function TMainWindow.ListenedAdapters : Integer;
var
  C1 : Integer;
begin
  DbgLn('TMainWindow.ListenedAdapters()');

  result := 0;
  For C1 := Low(WSockets) to High(WSockets) Do
    If (Assigned(WSockets[C1])) and
       (WSockets[C1].State <> wsClosed) Then
      Inc(result);
end;

procedure TMainWindow.WSocketError(Sender: TObject);
var
  C1 : Integer;
begin
  DbgLn(Format('TMainWindow.WSocketError(%d)', [WSAGetLastError]));

  For C1 := Low(WSockets) to High(WSockets) Do
    If WSockets[C1] = TWSocket(Sender) Then
      CloseListener(C1);
end;

procedure TMainWindow.WSocketReverseDnsLookupDone(Sender: TObject; Error: Word);
var
  item: TIPItem;
begin
  item.IP := TWSocket(Sender).Addr;
  item.RDNS := TWSocket(Sender).DnsResult;
  FIPtable.Add(item);

  DbgLn(Format('TMainWindow.WSocketReverseDnsLookupDone(%s > %s)', [item.IP, item.RDNS]));

  FGamingPlatform.Feed(item.RDNS);
end;

procedure TMainWindow.WSocketDataAvailable(Sender: TObject; ErrCode: Word);
const
  BUF_SIZE = 1024 * 64;
var
  IPHeader  : PHdrIP;
  memStream : TMemoryStream;
  buffer    : Array[0..BUF_SIZE - 1] of AnsiChar;
  len       : Integer;
  C1        : Integer;
  dataPos   : Int64;
  tmp       : String;
  item      : TIPItem;
begin
  memStream := TMemoryStream.Create;

  len := TWSocket(Sender).Receive(@buffer[0], BUF_SIZE);
  If Len > 0 Then
  Begin
    memStream.Clear;
    memStream.Write(buffer[0], len);
    memStream.Seek(0, soFromBeginning);

    IPHeader := AllocMem(SizeOf(THdrIP));
    memStream.ReadBuffer(IPHeader^, SizeOf(THdrIP));

    dataPos := memStream.Position;
    If (FDotaParser.Parse(memStream, IPHeader^)) and
       (ListenedAdapters > 1) Then
      For C1 := Low(WSockets) to High(WSockets) Do
        If (Assigned(WSockets[C1])) and
           (WSockets[C1].State <> wsClosed) and
           (WSockets[C1] <> TWSocket(Sender)) Then
          CloseListener(C1);

    If FDotaParser.GameData.Times.ModeChoosed = 0 Then
    Begin
      memStream.Position := dataPos;
      FW3GSParser.Parse(memStream, IPHeader^);
    End
    else
    begin
      tmp := IpToStr(IPHeader.saddr);

      if (tmp <> '127.0.0.1') and
         (not MatchStrings(tmp, '192.168.*.*', FALSE)) then
        if SearchIPTableItem(tmp, item) then
          FGamingPlatform.Feed(item.RDNS)
        else
          TWSocket(Sender).ReverseDnsLookup(tmp);
    end;

    FreeMem(IPHeader, SizeOf(THdrIP));
  end;

  memStream.Free;

  UpdateGUI;
end;

function TMainWindow.SearchIPTableItem(const AIP: String; var AItem: TIPItem): Boolean;
var
  C1  : Integer;
  item: TIPItem;
begin
  DbgLn(Format('TMainWindow.SearchIPTableItem(%s)', [AIP]));

  for C1 := 0 to FIPTable.Count - 1 do
  begin
    item := FIPTable[C1];

    if item.IP = AIP then
    begin
      DbgLn(Format('TMainWindow.SearchIPTableItem(FOUND, %s)', [AIP]));

      AItem := item;
      Exit(TRUE);
    end;
  end;

  Exit(FALSE);
end;

procedure TMainWindow.UpdateGUI;
//  mins, secs    : Integer;
begin
  If FDotaParser.GameData.Times.ModeChoosed = 0 Then
  Begin
//    headerCaption := RS_WAITING_FOR_GAME;
//    headerColor := HEADER_COLOR_GAME_WAITING;
  End
  else
  Begin
    If FDotaParser.GameData.Winner = dwUnknown Then
    Begin
      if FDotaParser.GameData.Times.FirstCreepWaveSpawned = 0 then
      begin
//        headerCaption := RS_GAME_PRECREEPS;
//        headerColor := HEADER_COLOR_GAME_IN_PROGRESS;
      end
      else
      begin
//        MSecToTime(GetTickCount - FDotaParser.GameData.Times.FirstCreepWaveSpawned, mins, secs);
//        headerCaption := Format(RS_GAME_IN_PROGRESS, [mins, secs]);
//        headerColor := HEADER_COLOR_GAME_IN_PROGRESS;
      end;
    End
    else
      if FDotaParser.GameData.Times.GameEnd <> 0 then
      Begin
//        headerCaption := RS_GAME_ENDED;
//        headerColor := HEADER_COLOR_GAME_ENDED;

        CloseListeners;
      End;
  End;
end;

procedure TMainWindow.OnNewReplay(const AReplayFile: String);
begin
  DbgLn(Format('TMainWindow.OnNewReplay(%s)', [AReplayFile]));

  FGameProcesser.CheckHash := FALSE;

  CloseListeners;
  ProcessGame(AReplayFile);
  FDotaParser.FlushGame;
  FW3GSParser.Reset;
  FGamingPlatform.Reset;
  CreateListeners;
end;

procedure TMainWindow.ProcessGame(const AReplayFile : String);
var
  replayParser : TW3GParser;
  jsonServer   : ISuperObject;
  error        : String;
  ID           : Integer;
  C1           : Integer;
  data         : String;
  tfile        : TextFile;
begin
  DbgLn(Format('TMainWindow.ProcessGame(ENTRY, %s)', [AReplayFile]));

  replayParser := TW3GParser.Create;
  replayParser.ReplayFile := AReplayFile;

  DbgLn('TMainWindow.ProcessGame(Parsing Replay)');
  if replayParser.Parse then
  begin
    DbgLn('TMainWindow.ProcessGame(OK, Making JSON)');
    jsonServer := MakeJSON(replayParser, error);
    if error = '' then
    begin
      ID := 0;
      For C1 := Low(replayParser.ReplayInfo.Slots) to High(replayParser.ReplayInfo.Slots) Do
        If replayParser.ReplayInfo.Slots[C1].Name = jsonServer.S['uploadernickname'] Then
        Begin
          ID := C1;
          Break;
        End;
      If ID = 0 Then
        ID := Random(15);

      DbgLn(Format('TMainWindow.ProcessGame(OK, Posting with %dms delay)', [ID * 1000]));

      {$IFDEF DEBUGSWITCH}
      data := SafeEncode(TrimRight(Encrypt(SafeASCII(jsonServer.AsString))));
      jsonServer.SaveTo('C:\' + fuckingHash + '-json.txt');
      {$ENDIF}

      GamepostData := 'data=' + data;
      timerGamepost.Interval := ID * 1000;
      timerGamepost.Enabled := TRUE;

      {$IFDEF DEBUGSWITCH}
      if Debug then
      begin
        AssignFile(tfile, 'C:\' + fuckingHash + '-lastgame-enc.txt');
        Rewrite(tfile);
        Write(tfile, GamepostData);
        CloseFile(tfile);
      end;
      {$ENDIF DEBUGSWITCH}
    end
    else
    begin
      DbgLn(Format('TMainWindow.ProcessGame(FAIL, %s)', [error]));
      ReportError('ProcessGame', 'JSON error', error);

      {$IFDEF DEBUGSWITCH}
      if Debug then
        jsonServer.SaveTo('C:\' + fuckingHash + '-json-error.txt');
      {$ENDIF}
    end;
  end
  else
  begin
    DbgLn('TMainWindow.ProcessGame(FAIL)');
    ReportError('ProcessGame', 'Unable to parse replay');
  end;
end;

function TMainWindow.GetWinner(const AReplayParser : TW3GParser; const ADotaParser : TDotaParser) : TDotaGame_Winner;
begin
  result := dwUnknown;

  If (Assigned(ADotaParser)) and
     (ADotaParser.GameData.Winner <> dwUnknown) Then
    result := ADotaParser.GameData.Winner
  else
    If (Assigned(AReplayParser)) and
       (AReplayParser.DotaParser.GameData.Winner <> dwUnknown) Then
      result := AReplayParser.DotaParser.GameData.Winner;
end;


function TMainWindow.GetFFWinner(const AReplayParser: TW3GParser): TDotaGame_Winner;
var
  C1, C2, C3   : Integer;
  tmp          : String;
  tmpint       : Integer;
  iccT1, iccT2 : Integer;
  pid          : Integer;
begin
  result := dwUnknown;

  // dlg
  For C1 := 0 to AReplayParser.ReplayInfo.Chat.Count - 1 Do
    If (AReplayParser.ReplayInfo.Slots[AReplayParser.FindPlayerID(AReplayParser.ReplayInfo.Chat.Items[C1].PlayerID)].Name = 'Mr. Referee') and
       (MatchStrings(String(AReplayParser.ReplayInfo.Chat.Items[C1].Text), 'The whole team has forfeited! The game ends. You may now leave! No further statistics will be recorded.', TRUE)) Then
    Begin
      For C2 := C1 - 1 downto 0 Do
        If (AReplayParser.ReplayInfo.Slots[AReplayParser.FindPlayerID(AReplayParser.ReplayInfo.Chat.Items[C2].PlayerID)].Name = 'Mr. Referee') and
           (MatchStrings(String(AReplayParser.ReplayInfo.Chat.Items[C2].Text), 'Player [*] just forfeited! (?/?)', TRUE)) Then
        Begin
          tmp := String(AReplayParser.ReplayInfo.Chat.Items[C2].Text);
          Delete(tmp, 1, Pos('[', tmp));
          tmpint := Pos('] just forfeited! (', tmp);
          Delete(tmp, tmpint, Length(tmp) - tmpint + 1);

          tmpint := -1;
          For C3 := Low(AReplayParser.ReplayInfo.Slots) to High(AReplayParser.ReplayInfo.Slots) Do
            If AReplayParser.ReplayInfo.Slots[C3].Name = tmp Then
            Begin
              tmpint := AReplayParser.ReplayInfo.Slots[C3].ID;
              Break;
            End;

          If (tmpint = -1) and
             (C2 > 0) Then
            tmpint := AReplayParser.FindPlayerID(AReplayParser.ReplayInfo.Chat.Items[C2 - 1].PlayerID);

          tmpint := AReplayParser.FindPlayerID(tmpint);

          If (tmpint >= 1) and (tmpint <= 5) Then
            result := dwScourge;
          If (tmpint >= 7) and (tmpint <= 11) Then
            result := dwSentinel;
        End;
      Break;
    End;

  // #dotapickup
  {
    (56:51) iDs.aDn: The Scourge ffed this game. Winner is The Sentinel.
    (56:51) iDs.aDn: This game will automatically close in 2 minutes.
    (56:52) iDs.aDn: ----------------------------------------------------------------------------------------------
    (56:52) iDs.aDn: This game was hosted by #dotapickup.hosting
    (56:52) iDs.aDn: Rate this bot on irc with the command !rate 2 x, where x is between 1 and 10
    (56:52) iDs.aDn: ----------------------------------------------------------------------------------------------
  }
  For C1 := 0 to AReplayParser.ReplayInfo.Chat.Count - 6 Do
    If (MatchStrings(String(AReplayParser.ReplayInfo.Chat.Items[C1 + 0].Text), 'The * ffed this game. Winner is The *', TRUE)) and
       (MatchStrings(String(AReplayParser.ReplayInfo.Chat.Items[C1 + 1].Text), 'This game will automatically close in 2 minutes.', TRUE)) and
       (MatchStrings(String(AReplayParser.ReplayInfo.Chat.Items[C1 + 2].Text), '----------------------------------------------------------------------------------------------', TRUE)) and
       (MatchStrings(String(AReplayParser.ReplayInfo.Chat.Items[C1 + 3].Text), 'This game was hosted by #dotapickup.hosting', TRUE)) and
       (MatchStrings(String(AReplayParser.ReplayInfo.Chat.Items[C1 + 4].Text), 'Rate this bot on irc with the command !rate ? x, where x is between 1 and 10', TRUE)) and
       (MatchStrings(String(AReplayParser.ReplayInfo.Chat.Items[C1 + 5].Text), '----------------------------------------------------------------------------------------------', TRUE)) Then
    Begin
      tmp := String(AReplayParser.ReplayInfo.Chat.Items[C1 + 0].Text);
      Delete(tmp, 1, Pos(' ', tmp));
      tmp := Copy(tmp, 1, Pos(' ', tmp) - 1);

      If tmp = 'Scourge' Then
        result := dwSentinel;
      If tmp = 'Sentinel' Then
        result := dwScourge;

      Break;
    End;

  // iccup
  // first, count players that stayed till end in game
  {
    (25:49 / Allied) reiser: -ff
    (25:50) west-s1de: Player reiser has voted for fast finish.
  }
  iccT1 := 5;
  iccT2 := 5;
  For C1 := Low(AReplayParser.ReplayInfo.Slots) to High(AReplayParser.ReplayInfo.Slots) Do
  Begin
    If (AReplayParser.ReplayInfo.Slots[C1].LeftTime < AReplayParser.ReplayInfo.Duration - 10) and
       (AReplayParser.ReplayInfo.Slots[C1].LeftTime > 0) Then
    Begin
      pid := AReplayParser.FindPlayerID(AReplayParser.ReplayInfo.Chat.Items[C1].PlayerID);
      If pid <> -1 Then
      Begin
        If (pid >= 1) and (pid <= 5) Then
          Dec(iccT1);
        If (pid >= 7) and (pid <= 11) Then
          Dec(iccT2);
      End;
    End;
  End;

  // on each ff, decrement appropriate team variable by 1
  For C1 := 0 to AReplayParser.ReplayInfo.Chat.Count - 1 Do
  Begin
    If (AReplayParser.ReplayInfo.Chat.Items[C1].Time >= 600) and
       (MatchStrings(String(AReplayParser.ReplayInfo.Chat.Items[C1].Text), 'Player * has voted for fast finish.', TRUE)) Then
    Begin
      tmp := String(AReplayParser.ReplayInfo.Chat.Items[C1].Text);
      Delete(tmp, 1, Pos(' ', tmp));
      tmp := Copy(tmp, 1, Pos(' ', tmp) - 1);

      tmpint := -1;
      For C2 := Low(AReplayParser.ReplayInfo.Slots) to High(AReplayParser.ReplayInfo.Slots) Do
        If AReplayParser.ReplayInfo.Slots[C2].Name = tmp Then
        Begin
          tmpint := AReplayParser.ReplayInfo.Slots[C2].ID;
          Break;
        End;
      pid := AReplayParser.FindPlayerID(tmpint);

      If pid <> -1 Then
      Begin
        If (pid >= 1) and (pid <= 5) Then
          Dec(iccT1);
        If (pid >= 7) and (pid <= 11) Then
          Dec(iccT2);
      End;
    End;
  End;

  // find disconnect strings, and check lower team variable
  {
    (51:04) reiser: You have been disconnected from the server.
    (51:04) reiser: Attempting to reconnect... (120 seconds remain)
    (51:04) reiser: Reconnection rejected by server!
  }
  For C1 := 0 to AReplayParser.ReplayInfo.Chat.Count - 3 Do
    If (MatchStrings(String(AReplayParser.ReplayInfo.Chat.Items[C1 + 0].Text), 'You have been disconnected*', TRUE)) and
       (MatchStrings(String(AReplayParser.ReplayInfo.Chat.Items[C1 + 1].Text), 'Attempting to reconnect... (* seconds remain)', TRUE)) and
       (MatchStrings(String(AReplayParser.ReplayInfo.Chat.Items[C1 + 2].Text), 'Reconnection rejected by server!', TRUE)) Then
    Begin
      If iccT1 < iccT2 Then
        result := dwScourge;
      If iccT2 < iccT1 Then
        result := dwSentinel;

      Break;
    End;

  // rgc
  For C1 := 0 to AReplayParser.ReplayInfo.Chat.Count - 3 Do
      If (AReplayParser.ReplayInfo.Slots[AReplayParser.FindPlayerID(AReplayParser.ReplayInfo.Chat.Items[C1 + 0].PlayerID)].Name = '|cFFFF0000RGC') and
         (MatchStrings(String(AReplayParser.ReplayInfo.Chat.Items[C1 + 0].Text), '[*] has just FF''d the game.', TRUE)) and
         (AReplayParser.ReplayInfo.Slots[AReplayParser.FindPlayerID(AReplayParser.ReplayInfo.Chat.Items[C1 + 1].PlayerID)].Name = '|cFFFF0000RGC') and
         (MatchStrings(String(AReplayParser.ReplayInfo.Chat.Items[C1 + 1].Text), '?/? from the * have FF''d the game.', TRUE)) and
         (AReplayParser.ReplayInfo.Slots[AReplayParser.FindPlayerID(AReplayParser.ReplayInfo.Chat.Items[C1 + 2].PlayerID)].Name = '|cFFFF0000RGC') and
         (MatchStrings(String(AReplayParser.ReplayInfo.Chat.Items[C1 + 2].Text), 'The * have FF''d the game.', TRUE)) Then
      Begin
        tmp := String(AReplayParser.ReplayInfo.Chat.Items[C1 + 2].Text);
        Delete(tmp, 1, Pos(' ', tmp));
        tmp := Copy(tmp, 1, Pos(' ', tmp) - 1);

        If tmp = 'Scourge' Then
          result := dwSentinel;
        If tmp = 'Sentinel' Then
          result := dwScourge;
      End;
end;

function MatchReplayData(const AGameEnded : Boolean; const ASniffInfoLive, ASniffInfoEnd : TDotaGame_PlayerInfo; const AReplayInfo : TW3GReplay_SlotInfo; const AReplayDotaInfo : TDotaGame_PlayerInfo; var ASlotInfo : TDotaGame_PlayerInfo) : Integer;
begin
  result := 100;

  ASlotInfo := ASniffInfoLive;

  if AReplayDotaInfo.HeroCode <> '' then
    ASlotInfo.HeroCode := AReplayDotaInfo.HeroCode;

  If (AReplayDotaInfo.Kills <> 0) or
     (AReplayDotaInfo.Deaths <> 0) or
     (AReplayDotaInfo.Assists <> 0) or
     (AReplayDotaInfo.CreepKills <> 0) or
     (AReplayDotaInfo.CreepDenies <> 0) or
     (AReplayDotaInfo.CreepNeutrals <> 0) or
     (AReplayDotaInfo.ItemCodes[1] <> '') or
     (AReplayDotaInfo.ItemCodes[2] <> '') or
     (AReplayDotaInfo.ItemCodes[3] <> '') or
     (AReplayDotaInfo.ItemCodes[4] <> '') or
     (AReplayDotaInfo.ItemCodes[5] <> '') or
     (AReplayDotaInfo.ItemCodes[6] <> '') Then
  Begin
    ASlotInfo.Kills := AReplayDotaInfo.Kills;
    ASlotInfo.Deaths := AReplayDotaInfo.Deaths;
    ASlotInfo.Assists := AReplayDotaInfo.Assists;
    ASlotInfo.CreepKills := AReplayDotaInfo.CreepKills;
    ASlotInfo.CreepDenies := AReplayDotaInfo.CreepDenies;
    ASlotInfo.CreepNeutrals := AReplayDotaInfo.CreepNeutrals;
    ASlotInfo.ItemCodes := AReplayDotaInfo.ItemCodes;
  End
  else
  Begin
    If AGameEnded Then
    Begin
      ASlotInfo.Kills := ASniffInfoEnd.Kills;
      ASlotInfo.Deaths := ASniffInfoEnd.Kills;
      ASlotInfo.Assists := ASniffInfoEnd.Kills;
      ASlotInfo.CreepKills := ASniffInfoEnd.Kills;
      ASlotInfo.CreepDenies := ASniffInfoEnd.Kills;
      ASlotInfo.CreepNeutrals := ASniffInfoEnd.Kills;
      ASlotInfo.Gold := ASniffInfoEnd.Kills;
      ASlotInfo.HeroCode := ASniffInfoEnd.HeroCode;
      ASlotInfo.ItemCodes := ASniffInfoEnd.ItemCodes;
    End;
  End;

  If ASlotInfo.Kills > 100 Then
  Begin
    ASlotInfo.Kills := 0;
    Dec(result, 5);
  End;

  If ASlotInfo.Deaths > 100 Then
  Begin
    ASlotInfo.Deaths := 0;
    Dec(result, 5);
  End;

  If ASlotInfo.Assists > 200 Then
  Begin
    ASlotInfo.Assists := 0;
    Dec(result, 5);
  End;

  If ASlotInfo.CreepKills > 1500 Then
  Begin
    ASlotInfo.CreepKills := 0;
    Dec(result, 5);
  End;

  If ASlotInfo.CreepDenies > 1500 Then
  Begin
    ASlotInfo.CreepDenies := 0;
    Dec(result, 5);
  End;

  If ASlotInfo.CreepNeutrals > 1000 Then
  Begin
    ASlotInfo.CreepNeutrals := 0;
    Dec(result, 5);
  End;

  If ASlotInfo.TowerKills > 11 Then
  Begin
    ASlotInfo.TowerKills := 0;
    Dec(result, 15);
  End;

  If ASlotInfo.TowerDenies > 11 Then
  Begin
    ASlotInfo.TowerKills := 0;
    Dec(result, 15);
  End;

  If ASlotInfo.RaxKills > 6 Then
  Begin
    ASlotInfo.RaxKills := 0;
    Dec(result, 15);
  End;

  If ASlotInfo.RaxDenies > 6 Then
  Begin
    ASlotInfo.RaxDenies := 0;
    Dec(result, 15);
  End;

  If ASlotInfo.CourierKills > 100 Then
  Begin
    ASlotInfo.CourierKills := 0;
    Dec(result, 5);
  End;

  If (ASlotInfo.Level <> AReplayDotaInfo.Level) and
     (AReplayDotaInfo.Level >= 1) and
     (AReplayDotaInfo.Level <= 25) Then
  Begin
    ASlotInfo.Level := AReplayDotaInfo.Level;
    Dec(result, 25);
  End;

//  DbgLn(Format('TMainWindow.MatchReplayData(%d percent)', [result]));
end;

function TMainWindow.MakeJSON(const AReplayInfo : TW3GParser; var AError : String) : ISuperObject;
var
  jsonPlayers,
  jsonPlayer   : ISuperObject;
  C1, C2       : Integer;
  pID          : Integer;
  slotInfo     : TDotaGame_PlayerInfo;
  hashString   : String;
begin
  result := SO();
  jsonPlayers := SO();

  hashString := '';
  For C1 := 1 to 12 Do
    If CheckAndModifyValue(C1, pID) Then
    Begin
      ZeroMemory(@slotInfo, SizeOf(TDotaGame_PlayerInfo));

      MatchReplayData(FDotaParser.GameData.Times.GameEnd <> 0, FDotaParser.GameData.PlayersLive[pID], FDotaParser.GameData.PlayersEnd[pID],
                      AReplayInfo.ReplayInfo.Slots[C1], AReplayInfo.DotaParser.GameData.PlayersEnd[pID], slotInfo);

      jsonPlayer := SO();
      jsonPlayer.S['name'] := AReplayInfo.ReplayInfo.Slots[C1].Name;

      jsonPlayer.I['team'] := 0;
      If pID in [1..5] Then
        jsonPlayer.I['team'] := 1;
      If pID in [6..10] Then
        jsonPlayer.I['team'] := 2;

      jsonPlayer.I['level'] := slotInfo.Level;
      jsonPlayer.S['hero'] := Trim(slotInfo.HeroCode);
      jsonPlayer.I['apm'] := AReplayInfo.ReplayInfo.Slots[C1].APM;
      jsonPlayer.I['kills'] := slotInfo.Kills;
      jsonPlayer.I['deaths'] := slotInfo.Deaths;
      jsonPlayer.I['assists'] := slotInfo.Assists;
      jsonPlayer.I['creepkills'] := slotInfo.CreepKills;
      jsonPlayer.I['creepdenies'] := slotInfo.CreepDenies;
      jsonPlayer.I['neutralkills'] := slotInfo.CreepNeutrals;
      jsonPlayer.I['towerkills'] := slotInfo.TowerKills;
      jsonPlayer.I['towerdenies'] := slotInfo.TowerDenies;
      jsonPlayer.I['courierkills'] := slotInfo.CourierKills;

      If (AReplayInfo.ReplayInfo.Slots[C1].LeftTime = 0) or
         (AReplayInfo.ReplayInfo.Slots[C1].LeftTime > AReplayInfo.ReplayInfo.Duration - 60) Then
        jsonPlayer.S['leave'] := 'false'
      else
        jsonPlayer.S['leave'] := 'true';

      jsonPlayer.I['leavetime'] := AReplayInfo.ReplayInfo.Slots[C1].LeftTime;

      For C2 := 1 to 6 Do
        jsonPlayer.S['item' + IntToStr(C2)] := Trim(slotInfo.ItemCodes[C2]);

      hashString := hashString + jsonPlayer.S['hero'] + IntToStr(jsonPlayer.I['team']) + jsonPlayer.S['item1'] + IntToStr(jsonPlayer.I['kills']) + IntToStr(jsonPlayer.I['deaths']);

      jsonPlayers.O[IntToStr(pID)] := jsonPlayer;
    End;

  result.O['players'] := jsonPlayers;

  result.S['gamename'] := AReplayInfo.ReplayInfo.Gamename;
  result.S['gamehost'] := AReplayInfo.ReplayInfo.CreatorName;
  result.S['mapname'] := ExtractFileName(AReplayInfo.ReplayInfo.MapName);
  result.S['gamemode'] := FDotaParser.GameData.Mode;
  result.I['gamelength'] := AReplayInfo.ReplayInfo.Duration;

  Case GetWinner(AReplayInfo, FDotaParser) of
    dwSentinel : result.I['winner'] := 1;
    dwScourge  : result.I['winner'] := 2;
  else
    Case GetFFWinner(AReplayInfo) of
      dwSentinel : result.I['winner'] := 1;
      dwScourge  : result.I['winner'] := 2;
    else
      result.I['winner'] := 0;
    End;
  End;

  Case FGamingPlatform.CurrentPlatform of
    gpBNet        : result.S['platform'] := 'bnet';
    gpGarena      : result.S['platform'] := 'garena';
    gpICCup       : result.S['platform'] := 'iccup';
    gpDotalicious : result.S['platform'] := 'dotalicious';
    gpRGC         : result.S['platform'] := 'rgc';
  else
    result.S['platform'] := '';
  End;

  result.S['uploaderid'] := UserData.ID;

  result.S['uploadernickname'] := '';
  If AReplayInfo.ReplayInfo.SaverID <> -1 Then
    result.S['uploadernickname'] := AReplayInfo.ReplayInfo.Slots[AReplayInfo.ReplayInfo.SaverID].Name
  else
    If FW3GSParser.UserNick <> '' Then
      result.S['uploadernickname'] := FW3GSParser.UserNick;

  hashString := result.S['gamemode'] + result.S['platform'] + hashString;
  fuckingHash := MD5String(hashString);

  result.S['gamehash'] := fuckingHash;

  result.I['admessage'] := 0;
  for C1 := 0 to AReplayInfo.ReplayInfo.Chat.Count - 1 do
    if (AReplayInfo.ReplayInfo.Chat.Items[C1].ChatType = ctAll) and
       (AReplayInfo.ReplayInfo.Chat.Items[C1].Text = AD_MESSAGE) then
    begin
      result.I['admessage'] := 1;
      Break;
    end;

  AError := '';
  if result.S['uploaderid'] = '' then
    AError := 'UploaderID = unknown, ';

  if result.S['platform'] = '' then
    AError := AError + 'Platform = unknown, ';

  for jsonPlayer in result['players'] do
    if (jsonPlayer.S['name'] = '') or
       (jsonPlayer.S['hero'] = '') then
    begin
      AError := AError + 'invalid players, ';
      Break;
    end;

  if result.I['gamelength'] < 600 then
    AError := AError + Format('Game duration = %ds, ', [result.I['gamelength']]);

  If Length(AError) > 0 Then
    Delete(AError, Length(AError) - 1, 2);
end;


procedure TMainWindow.ReportError(const AType, AError : String; const AData : String = '');
var
  JSON : ISuperObject;
begin
  JSON := SO();

  JSON.S['username'] := UserData.Username;
  JSON.B['compressed'] := FALSE;

  If AData <> '' Then
    JSON.S['content'] := Format('%s :: %s -> %s', [AType, AError, AData])
  else
    JSON.S['content'] := Format('%s :: %s', [AType, AError]);

  httpPostRequest(ComponentContainer.httpErrorReporter, URL_ERRORREPORT, Format('data=%s', [SBEncoding.Base64EncodeString(JSON.AsString)]));

  JSON := nil;
end;

procedure TMainWindow.OnTempReplayCreated(const ATempReplay: String);
begin
  if Options.AdMessage then
    CopyAdMessage;

  FGameProcesser.CheckHash := TRUE;
end;

procedure TMainWindow.DotaOnModeChoosed(const AMode: String);
begin
  if Options.AdMessage then
    CopyAdMessage;

  FGameProcesser.CheckHash := TRUE;
end;

procedure TMainWindow.OnTempReplayDeleted(const ATempReplay: String);
begin
//
end;

procedure TMainWindow.DotaOnGameEnded;
begin
//
end;

procedure TMainWindow.CopyAdMessage;
begin
  Clipboard.AsText := AD_MESSAGE;
end;

end.

