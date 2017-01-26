{$I ..\defines.inc}

unit GProxy;

interface

uses
  Windows, Classes;

type
  TGProxy = class;

  TGProxyUDPReadEvent = procedure(ASender : TGProxy; const AString : WideString) of object;

  TGProxyBNetConnect         = procedure(ASender : TGProxy) of object;
  TGProxyNonCommand          = procedure(ASender : TGProxy; const APrefix, ALine : WideString) of object;
  TGProxyCommand             = procedure(ASender : TGProxy; const ACommand, AParams : WideString) of object;
  TGProxyBNetInvalidPassword = procedure(ASender : TGProxy) of object;
  TGProxyBNetInvalidUsername = procedure(ASender : TGProxy) of object;
  TGProxyUserJoin            = procedure(ASender : TGProxy; const ANickname : WideString) of object;
  TGProxyUserLeave           = procedure(ASender : TGProxy; const ANickname : WideString) of object;
  TGProxyGetUserList         = procedure(ASender : TGProxy) of object;
  TGProxyChannelJoin         = procedure(ASender : TGProxy; const AChannel : WideString) of object;
  TGProxyCHATE               = procedure(ASender : TGProxy; const ACommand, AParams : WideString) of object;
  TGProxyOnChannelChat       = procedure(ASender : TGProxy; const AUser, ALine : WideString) of object;
  TGProxyOnWhisper           = procedure(ASender : TGProxy; const AUser, ALine : WideString) of object;
  TGProxyOnOutWhisper        = procedure(ASender : TGProxy; const AUser, ALine : WideString) of object;

  TGProxy = class
            private
              FSettingsPath : String;
              FExePath      : String;
              ProcInfo      : TProcessInformation;
              FConnected    : Boolean;

              FCurrentChannel : String;

              FChannelUsers : TStringList;

              FOnUDPRead             : TGProxyUDPReadEvent;
              FOnBNetConnect         : TGProxyBNetConnect;
              FOnNonCommand          : TGProxyNonCommand;
              FOnCommand             : TGProxyCommand;
              FOnBNetInvalidPassword : TGProxyBNetInvalidPassword;
              FOnBNetInvalidUsername : TGProxyBNetInvalidUsername;
              FOnUserLeave           : TGProxyUserLeave;
              FOnUserJoin            : TGProxyUserJoin;
              FOnGetUserList         : TGProxyGetUserList;
              FOnChannelJoin         : TGProxyChannelJoin;
              FOnCHATE               : TGProxyCHATE;
              FOnChannelChat         : TGProxyOnChannelChat;
              FOnWhisper             : TGProxyOnWhisper;
              FOnOutWhisper          : TGProxyOnOutWhisper;

              procedure pvpgnUDPServerDataAvailable(Sender: TObject; ErrCode: Word);
              procedure ProcessCommand(const ACommand, AParams : WideString);
              procedure ResetUDPServer;
              procedure ResetUDPClient;
            public
              constructor Create(const AFilename : String);
              destructor Destroy; override;

              function ReadString(const AName : String) : String;
              procedure WriteString(const AName, AValue : String);

              function Start : Integer;
              function Terminate : Boolean;

              procedure Send(const ACommand : WideString);

              procedure Command(const ACommand : WideString);
              procedure Whisper(const AUser, ACommand : WideString);
              procedure Say(const ACommand : WideString);

              procedure UpdateUsers;
              function GetTerminated : Boolean;
              procedure CreateConfig;
            published
              property ExePath      : String read FExePath;
              property SettingsPath : String read FSettingsPath write FSettingsPath;
              property Connected    : Boolean read FConnected;

              property ChannelUsers : TStringList read FChannelUsers;
              property Terminated : Boolean read GetTerminated;

              property CurrentChannel : String read FCurrentChannel;

              property OnUDPRead              : TGProxyUDPReadEvent read FOnUDPRead write FOnUDPRead;
              property OnBNetConnect          : TGProxyBNetConnect read FOnBNetConnect write FOnBNetConnect;
              property OnNonCommand           : TGProxyNonCommand read FOnNonCommand write FOnNonCommand;
              property OnCommand              : TGProxyCommand read FOnCommand write FOnCommand;
              property OnBNetInvalidPassword  : TGProxyBNetInvalidPassword read FOnBNetInvalidPassword write FOnBNetInvalidPassword;
              property OnBNetInvalidUsername  : TGProxyBNetInvalidUsername read FOnBNetInvalidUsername write FOnBNetInvalidUsername;
              property OnUserLeave            : TGProxyUserLeave read FOnUserLeave write FOnUserLeave;
              property OnUserJoin             : TGProxyUserJoin read FOnUserJoin write FOnUserJoin;
              property OnGetUserList          : TGProxyGetUserList read FOnGetUserList write FOnGetUserList;
              property OnChannelJoin          : TGProxyChannelJoin read FOnChannelJoin write FOnChannelJoin;
              property OnCHATE                : TGProxyCHATE read FOnCHATE write FOnCHATE;
              property OnChannelChat          : TGProxyOnChannelChat read FOnChannelChat write FOnChannelChat;
              property OnWhisper              : TGProxyOnWhisper read FOnWhisper write FOnWhisper;
              property OnOutWhisper           : TGProxyOnOutWhisper read FOnOutWhisper write FOnOutWhisper;
            end;

implementation

uses
  SysUtils, SharedData, SharedVars, ComponentModule, WinSock, OverbyteIcsWSocket;



procedure TGProxy.ResetUDPServer;
begin
  ComponentModuleWindow.pvpgnUDPServer.Proto := 'udp';
  ComponentModuleWindow.pvpgnUDPServer.Port := ReadString('udp_guiport');
  If ComponentModuleWindow.pvpgnUDPServer.Port = '' Then
    ComponentModuleWindow.pvpgnUDPServer.Port := '3458';
  ComponentModuleWindow.pvpgnUDPServer.Addr := '127.0.0.1';
  ComponentModuleWindow.pvpgnUDPServer.OnDataAvailable := pvpgnUDPServerDataAvailable;
end;

procedure TGProxy.ResetUDPClient;
begin
  ComponentModuleWindow.pvpgnUDPClient.Proto := 'udp';
  ComponentModuleWindow.pvpgnUDPClient.Port := ReadString('udp_cmdport');
  If ComponentModuleWindow.pvpgnUDPClient.Port = '' Then
    ComponentModuleWindow.pvpgnUDPClient.Port := '3459';
  ComponentModuleWindow.pvpgnUDPClient.Addr := '127.0.0.1';
  ComponentModuleWindow.pvpgnUDPClient.LocalAddr := '127.0.0.1';
  ComponentModuleWindow.pvpgnUDPClient.LocalPort := '0';
end;


constructor TGProxy.Create(const AFilename : String);
begin
  FExePath := AFilename;
  ForceDirectories(ExpandEnvString(GPROXY_CFG));
  FSettingsPath := ITB(ExpandEnvString(GPROXY_CFG)) + 'gproxy.cfg';
  If not FileExists(FSettingsPath) Then
    CreateConfig;

  WriteString('war3path', Options.WC3.Path);

  FChannelUsers := TStringList.Create;
end;

destructor TGProxy.Destroy;
begin
  Terminate;

  FChannelUsers.Free;

  inherited;
end;

procedure TGproxy.CreateConfig;
var
  TFile : TextFile;
begin
  ForceDirectories(ExtractFilePath(FSettingsPath));
  AssignFile(TFile, FSettingsPath);
  Rewrite(TFile);
    WriteLn(TFile, Format('%s = %s', ['war3path', ITB(Options.WC3.Path)]));
    WriteLn(TFile, Format('%s = %s', ['cdkeyroc', 'FFFFFFFFFFFFFFFFFFFFFFFFFF']));
    WriteLn(TFile, Format('%s = %s', ['cdkeytft', 'FFFFFFFFFFFFFFFFFFFFFFFFFF']));
    WriteLn(TFile, Format('%s = %s', ['bnet_port', '']));
    WriteLn(TFile, Format('%s = %s', ['server', '']));
    WriteLn(TFile, Format('%s = %s', ['username', '']));
    WriteLn(TFile, Format('%s = %s', ['password', '']));
    WriteLn(TFile, Format('%s = %s', ['channel', 'General']));
    WriteLn(TFile, Format('%s = %s', ['passwordhashtype', 'pvpgn']));
    WriteLn(TFile, Format('%s = %s', ['filtergproxy', '1']));
    WriteLn(TFile, Format('%s = %s', ['publicgames', '1']));
    WriteLn(TFile, Format('%s = %s', ['port', '3457']));
    WriteLn(TFile, Format('%s = %s', ['udp_guiport', '3458']));
    WriteLn(TFile, Format('%s = %s', ['udp_cmdport', '3459']));
    WriteLn(TFile, Format('%s = %s', ['udp_console', '1']));
    WriteLn(TFile, Format('%s = %s', ['udp_password', '']));
    WriteLn(TFile, Format('%s = %s', ['war3version', '']));
    WriteLn(TFile, Format('%s = %s', ['exeversion', '']));
    WriteLn(TFile, Format('%s = %s', ['exeversionhash', '']));
    WriteLn(TFile, Format('%s = %s', ['filterhosts', '']));
    WriteLn(TFile, Format('%s = %s', ['hidewhispersfrom', '']));
    {$IFDEF GPROXY_LOG}
    WriteLn(TFile, Format('%s = %s', ['log', 'log.txt']));
    {$ENDIF}
  CloseFile(TFile);
end;

function GetPrefix(const ALine : String) : String;
begin
  result := Trim(Copy(ALine, 1, Pos('=', ALine) - 1));
end;

function GetPostfix(const ALine : String) : String;
begin
  result := Trim(Copy(ALine, Pos('=', ALine) + 1, Length(ALine) - Pos('=', ALine)));
end;

function TGproxy.ReadString(const AName : String) : String;
var
  SFile : TextFile;
  FLine : String;
begin
  result := '';
  If FileExists(FSettingsPath) Then
  Begin
    AssignFile(SFile, FSettingsPath);
    Reset(SFile);
      While not EOF(SFile) Do
      Begin
        ReadLn(SFile, FLine);
        If LowerCase(Trim(AName)) = LowerCase(GetPrefix(FLine)) Then
        Begin
          result := GetPostfix(FLine);
          Break;
        End;
      End;
    CloseFile(SFile);
  End;
end;

procedure TGProxy.WriteString(const AName, AValue : String);
var
  SFile, TFile : TextFile;
  FLine        : String;
  FTmp         : String;
  written      : Boolean;
begin
  If FileExists(FSettingsPath) Then
  Begin
    AssignFile(SFile, FSettingsPath);
    Reset(SFile);
    repeat
      FTmp := FSettingsPath + '~';
    until not FileExists(FTmp);
    AssignFile(TFile, FTmp);
    Rewrite(TFile);
      written := FALSE;
      While not EOF(SFile) Do
      Begin
        ReadLn(SFile, FLine);
        If LowerCase(Trim(AName)) = LowerCase(GetPrefix(FLine)) Then
        Begin
          FLine := AName + ' = ' + AValue;
          written := TRUE;
        End;
        WriteLn(TFile, FLine);
      End;
      If not written Then
      Begin
        FLine := AName + ' = ' + AValue;
        WriteLn(TFile, FLine);
      End;
    CloseFile(TFile);
    CloseFile(SFile);

    DeleteFile(FSettingsPath);
    RenameFile(FTmp, FSettingsPath);
  End;
end;

function TGProxy.Start : Integer;
var
  exitCode : DWORD;
begin
  result := ERROR_SUCCESS;
  exitCode := 0;
  If (not GetExitCodeProcess(ProcInfo.hProcess, exitCode)) or
     (exitCode <> STILL_ACTIVE) Then
  Begin
    result := ExecuteFile(FExePath, Format('"%s" "%s"', [FExePath, FSettingsPath]), ExtractFilePath(FExePath), CREATE_NO_WINDOW, SW_HIDE, ProcInfo);

    ResetUDPServer;
    ResetUDPClient;

    ComponentModuleWindow.pvpgnUDPServer.Listen;
    ComponentModuleWindow.pvpgnUDPClient.Connect;
  End;
end;

function TGProxy.Terminate : Boolean;
begin
  ComponentModuleWindow.pvpgnUDPServer.Close;
  ComponentModuleWindow.pvpgnUDPClient.Close;
  ComponentModuleWindow.pvpgnUDPServer.OnDataAvailable := nil;

  If not Assigned(ChannelUsers) Then
    FChannelUsers := TStringList.Create;

  FChannelUsers.Clear;
  FChannelUsers.Sorted := TRUE;
  result := TerminateProcess(ProcInfo.hProcess, 0);
end;

procedure TGProxy.ProcessCommand(const ACommand, AParams : WideString);
var
  Index  : Integer;
  C1     : Integer;
  CmdLen : Integer;
  Cmd    : WideString;
  Params : WideString;
begin
  If ACommand = 'bnetconnected' Then
    If Assigned(FOnBNetConnect) Then
      FOnBNetConnect(self);

  If ACommand = 'bnetinvalidpassword' Then
    If Assigned(FOnBNetInvalidPassword) Then
      FOnBNetInvalidPassword(self);

  If ACommand = 'bnetinvalidusername' Then
    If Assigned(FOnBNetInvalidUsername) Then
      FOnBNetInvalidUsername(self);

  If ACommand = 'channelusers' Then
  Begin
    Split(',', AParams, ChannelUsers);
    C1 := 0;
    While C1 < ChannelUsers.Count Do
      If ChannelUsers.Strings[C1] = '' Then
        ChannelUsers.Delete(C1)
      else
        Inc(C1);

    If Assigned(FOnGetUserList) Then
      FOnGetUserList(self);
  End;

  If ACommand = 'channeljoin' Then
  Begin
    ChannelUsers.Add(AParams);
    If Assigned(FOnUserJoin) Then
      FOnUserJoin(self, AParams);
  End;

  If ACommand = 'channelleave' Then
  Begin
    If ChannelUsers.Find(AParams, Index) Then
      ChannelUsers.Delete(Index);
    If Assigned(FOnUserLeave) Then
      FOnUserLeave(self, AParams);
  End;

  If ACommand = 'cjoined' Then
  Begin
    FCurrentChannel := AParams;
    If Assigned(FOnChannelJoin) Then
      FOnChannelJoin(self, AParams);
  End;

  If ACommand = 'chate' Then
  Begin
    Cmd := Copy(AParams, Pos(' ', AParams) + 1, Length(AParams) - Pos(' ', AParams));
    CmdLen := StrToIntDef(Copy(AParams, 1, Pos(' ', AParams) - 1), 0);
    If CmdLen <> 0 Then
    Begin
      Params := Cmd;
      Cmd := Copy(Cmd, 1, Pos(' ', Cmd) - 1);
      Delete(Params, 1, Pos(' ', Params));

      If Length(Cmd) = CmdLen Then
      Begin
        If Assigned(FOnCHATE) Then
          FOnCHATE(self, Cmd, Params);
      End;
    End;
  End;

  If ACommand = 'chat' Then
  Begin
    Cmd := Copy(AParams, Pos(' ', AParams) + 1, Length(AParams) - Pos(' ', AParams));
    CmdLen := StrToIntDef(Copy(AParams, 1, Pos(' ', AParams) - 1), 0);
    If CmdLen <> 0 Then
    Begin
      Params := Cmd;
      Cmd := Copy(Cmd, 1, Pos(' ', Cmd) - 1);
      Delete(Params, 1, Pos(' ', Params));

      If Length(Cmd) = CmdLen Then
      Begin
        If Assigned(FOnChannelChat) Then
          FOnChannelChat(self, Cmd, Params);
      End;
    End;
  End;

  If ACommand = 'chatw' Then
  Begin
    Cmd := Copy(AParams, Pos(' ', AParams) + 1, Length(AParams) - Pos(' ', AParams));
    CmdLen := StrToIntDef(Copy(AParams, 1, Pos(' ', AParams) - 1), 0);
    If CmdLen <> 0 Then
    Begin
      Params := Cmd;
      Cmd := Copy(Cmd, 1, Pos(' ', Cmd) - 1);
      Delete(Params, 1, Pos(' ', Params));

      If Length(Cmd) = CmdLen Then
      Begin
        If Assigned(FOnWhisper) Then
          FOnWhisper(self, Cmd, Params);
      End;
    End;
  End;
end;

procedure TGProxy.pvpgnUDPServerDataAvailable(Sender: TObject; ErrCode: Word);
const
  BUF_SIZE = 1024 * 16;
var
    Buffer          : Array[0..BUF_SIZE - 1] of Char;
    Len             : Integer;
    Src             : TSockAddrIn;
    SrcLen          : Integer;
    GLine           : String;
    Command, Params : String;
begin
  SrcLen := SizeOf(Src);
  Len := TWSocket(Sender).ReceiveFrom(@Buffer, BUF_SIZE, Src, SrcLen);
  If Len >= 0 Then
  Begin
    GLine := StrPas(Buffer);

    If Assigned(FOnUDPRead) Then
      FOnUDPRead(self, GLine);

    If GLine[1] = '|' Then

    Begin
      GLine := GLine + ' ';
      Command := LowerCase(Copy(GLine, 2, Pos(' ', GLine) - 2));
      Params := Copy(GLine, Length(Command) + 3, Length(GLine) - Length(Command) - 3);

      If Assigned(FOnCommand) Then
        FOnCommand(self, Command, Params);

      ProcessCommand(Command, Params);
    End
    else
      If GLine[1] = '[' Then
      Begin
        Command := Trim(Copy(GLine, 2, Pos(']', GLine) - 2));
        Params := Trim(Copy(GLine, Pos(']', GLine) + 1, Length(GLine) - Pos(']', GLine)));
        If Assigned(FOnNonCommand) Then
          FOnNonCommand(self, Command, Params);
      End;
  End;
end;

procedure TGProxy.Send(const ACommand : WideString);
var
  wcmd, wuser, wmsg : WideString;
begin
  ComponentModuleWindow.pvpgnUDPClient.SendStr('||127.0.0.1 ' + ACommand);

  If (Assigned(FOnOutWhisper)) and
     ((Pos('say /whisper', LowerCase(ACommand)) = 1) or
      (Pos('say /w', LowerCase(ACommand)) = 1) or
      (Pos('say /msg', LowerCase(ACommand)) = 1)) Then
  Begin
    wcmd := ACommand;
    Delete(wcmd, 1, 5);
    Delete(wcmd, 1, Pos(' ', wcmd));
    wuser := Copy(wcmd, 1, Pos(' ', wcmd) - 1);
    Delete(wcmd, 1, Pos(' ', wcmd));
    wmsg := wcmd;

    FOnOutWhisper(self, wuser, wmsg);
  End;
end;

procedure TGProxy.UpdateUsers;
begin
  Command('users');
end;

procedure TGProxy.Command(const ACommand : WideString);
begin
  Send(Format('say /%s', [ACommand]));
end;

procedure TGProxy.Whisper(const AUser, ACommand : WideString);
begin
  Command(Format('whisper %s %s', [AUser, ACommand]));
end;

procedure TGProxy.Say(const ACommand : WideString);
begin
  Send(Format('say %s', [ACommand]));
end;

function TGProxy.GetTerminated : Boolean;
var
  exitCode : DWORD;
begin
  exitCode := 0;
  result := (ProcInfo.hProcess = 0) or
            (not GetExitCodeProcess(ProcInfo.hProcess, exitCode)) or
            (exitCode <> STILL_ACTIVE);
end;

end.



