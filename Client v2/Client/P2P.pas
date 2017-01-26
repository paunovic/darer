unit P2P;

interface

uses
  SharedData, Classes;

const
  P2P_HEADER   = 'DCP2P';
  P2P_TCP_PORT = 25199;

  P2P_RPL_FRIENDSHIP    = 1001;
  P2P_RPL_REFRESH_STATS = 1002;
  P2P_RPL_REMOVEFRIEND  = 1003;
  P2P_RPL_DECLINEFRIEND = 1004;
  P2P_RPL_ACCEPTFRIEND  = 1005;
  P2P_RPL_USERSTATS     = 1006;

type
  TP2PTYPE = (p2pTCP, p2pPVPGN, p2pNone);

var
  P2PTYPE : TP2PType = p2pNone;

function P2P_ValidString(const ALine : String) : Boolean;
function P2P_Process(const ALine : String; var params : String) : Integer;
function P2P_RequestUserStats(const AFrom, AUsername : String) : Boolean;
function P2P_ReturnUserStats(const ATo : String; const AStats : TUserInfo; const AAvatar : TMemoryStream) : Boolean;
function P2P_RequestRefreshStats(const AFrom, ATo : String) : Boolean;
function P2P_AcceptFriendship(const AFrom, ATo : String) : Boolean;
function P2P_DeclineFriendship(const AFrom, ATo : String) : Boolean;
function P2P_RemoveFriendship(const AFrom, ATo : String) : Boolean;

type
  TP2PClass = class
              private
                p2pstring : String;

                procedure tcpClientSessionConnected(Sender: TObject; ErrCode: Word);
                procedure tcpClientSessionClosed(Sender: TObject; ErrCode: Word);
              end;

implementation

uses
  SysUtils, ComponentModule, OverbyteIcsWSocket, Misc, Cache;

var
  p2pclass : TP2PClass;

function P2P_ValidString(const ALine : String) : Boolean;
begin
  result := Pos(P2P_HEADER, blowfishDecrypt(ALine)) = 1;
end;

function P2P_TCPSendStr(const AIP, AString : String) : Boolean;
begin
  If ComponentModuleWindow.tcpClient.State in [wsClosed] Then
  Begin
    p2pclass.p2pstring := AString;

    ComponentModuleWindow.tcpClient.Addr  := AIP;
    ComponentModuleWindow.tcpClient.Port  := IntToStr(P2P_TCP_PORT);
    ComponentModuleWindow.tcpClient.Proto := 'tcp';
    ComponentModuleWindow.tcpClient.OnSessionConnected := p2pclass.tcpClientSessionConnected;
    ComponentModuleWindow.tcpClient.OnSessionClosed := p2pclass.tcpClientSessionClosed;
    ComponentModuleWindow.tcpClient.Connect;
    result := TRUE;
  End
  else
    result := FALSE;
end;

function P2P_Process(const ALine : String; var params : String) : Integer;
var
  line, cmd : String;
  userInfo  : TUserInfo;
begin
  result := -1;

  line := blowfishDecrypt(ALine);
  If Pos(P2P_HEADER, line) = 1 Then
  Begin
    Delete(line, 1, Length(P2P_HEADER));
    line := Trim(line);

    cmd := Copy(line, 1, Pos(' ', line) - 1);
    Delete(line, 1, Pos(' ', line));
    line := Trim(line);

    If cmd = 'GET_STATS' Then  
    Begin
      P2P_ReturnUserStats(GetParam(line, 0), Users.Items[0], nil);
      result := 0;
    End;

    If cmd = 'RPL_STATS' Then
    Begin
      userInfo.Username := GetParam(line, 0);
      userInfo.Country := GetParam(line, 1);
      userInfo.Area := StrToIntDef(GetParam(line, 2), 0);
      userInfo.Avatar := GetParam(line, 3);
      userInfo.Stats.Wins := StrToIntDef(GetParam(line, 4), 0);
      userInfo.Stats.Losses := StrToIntDef(GetParam(line, 5), 0);
      userInfo.Stats.Kills := StrToIntDef(GetParam(line, 6), 0);
      userInfo.Stats.LeaveCount := StrToIntDef(GetParam(line, 7), 0);
      userInfo.Stats.Rating := StrToIntDef(GetParam(line, 8), 0);
      userInfo.Stats.RatingPro := StrToIntDef(GetParam(line, 9), 0);
      userInfo.Stats.TotalGames := StrToIntDef(GetParam(line, 10), 0);
      userInfo.Stats.Title := GetParam(line, 11);
      userInfo.Stats.Rank := StrToIntDef(GetParam(line, 12), 0);
      userInfo.Stats.Deaths := StrToIntDef(GetParam(line, 13), 0);
      userInfo.Stats.RatingD := StrToFloatDef(GetParam(line, 14), 0);
      AddUserToList(userInfo);
      params := userinfo.Username;
      cache_PutUser(userinfo);
      result := P2P_RPL_USERSTATS;
    End;

    If cmd = 'REFRESH_STATS' Then
      result := P2P_RPL_REFRESH_STATS;

    If cmd = 'ASK_FRIENDSHIP' Then
      result := P2P_RPL_FRIENDSHIP;

    If cmd = 'ACCEPT_FRIENDSHIP' Then
    Begin
      params := GetParam(line, 0);
      result := P2P_RPL_ACCEPTFRIEND;
    End;

    If cmd = 'DECLINE_FRIENDSHIP' Then
    Begin
      params := GetParam(line, 0);
      result := P2P_RPL_DECLINEFRIEND;
    End;

    If cmd = 'REMOVE_FRIENDSHIP' Then
    Begin
      params := GetParam(line, 0);
      result := P2P_RPL_REMOVEFRIEND;
    End;
  End
end;

function P2P_RequestUserStats(const AFrom, AUsername : String) : Boolean;
var
  cmdUserstats : String;
begin
  cmdUserstats := blowfishEncrypt(Format('%s GET_STATS %s', [P2P_HEADER, AFrom]));
  Case P2PTYPE of
    p2pTCP   : Begin
                 result := P2P_TCPSendStr('ausername.ip', cmdUserstats);
               End;
    p2pPVPGN : Begin
                 ComponentModuleWindow.GProxy.Whisper(AUsername, cmdUserstats);
                 result := TRUE;
               End;
  else
    result := FALSE;
  End;
end;

function P2P_ReturnUserStats(const ATo : String; const AStats : TUserInfo; const AAvatar : TMemoryStream) : Boolean;
var
  cmdUserstats : String;
begin
  cmdUserstats := blowfishEncrypt(Format('%s RPL_STATS %s %s %d %s %d %d %d %d %d %d %d %s %d %d %f',
                                         [P2P_HEADER, AStats.Username, AStats.Country, AStats.Area, AStats.Avatar, AStats.Stats.Wins,
                                         AStats.Stats.Losses, AStats.Stats.Kills, AStats.Stats.LeaveCount, AStats.Stats.Rating, AStats.Stats.RatingPro, AStats.Stats.TotalGames,
                                         AStats.Stats.Title, AStats.Stats.Rank, AStats.Stats.Deaths, AStats.Stats.RatingD]));
  Case P2PTYPE of
    p2pTCP   : Begin
                 result := P2P_TCPSendStr('ato.ip', cmdUserstats);
//                 ComponentModuleWindow.tcpClient.Send(AStats.
               End;
    p2pPVPGN : Begin
                 ComponentModuleWindow.GProxy.Whisper(ATo, cmdUserstats);
                 result := TRUE;
               End;
  else
    result := FALSE;
 End;
end;

function P2P_RequestRefreshStats(const AFrom, ATo : String) : Boolean;
var
  cmd : String;
begin
  cmd := blowfishEncrypt(Format('%s REFRESH_STATS %s', [P2P_HEADER, AFrom]));

  Case P2PTYPE of
    p2pTCP   : Begin
                 result := P2P_TCPSendStr('ato.ip', cmd);
               End;
    p2pPVPGN : Begin
                 ComponentModuleWindow.GProxy.Whisper(ATo, cmd);
                 result := TRUE;
               End;
  else
    result := FALSE;
  End;
end;

function P2P_AcceptFriendship(const AFrom, ATo : String) : Boolean;
var
  cmd : String;
begin
  cmd := blowfishEncrypt(Format('%s ACCEPT_FRIENDSHIP %s', [P2P_HEADER, AFrom]));

  Case P2PTYPE of
    p2pTCP   : Begin
                 result := P2P_TCPSendStr('ato.ip', cmd);
               End;
    p2pNone,
    p2pPVPGN : Begin
                 ComponentModuleWindow.GProxy.Whisper(ATo, cmd);
                 result := TRUE;
               End;
  else
    result := FALSE;
  End;
end;

function P2P_DeclineFriendship(const AFrom, ATo : String) : Boolean;
var
  cmd : String;
begin
  cmd := blowfishEncrypt(Format('%s DECLINE_FRIENDSHIP %s', [P2P_HEADER, AFrom]));

  Case P2PTYPE of
    p2pTCP   : Begin
                 result := P2P_TCPSendStr('ato.ip', cmd);
               End;
    p2pNone,
    p2pPVPGN : Begin
                 ComponentModuleWindow.GProxy.Whisper(ATo, cmd);
                 result := TRUE;
               End;
  else
    result := FALSE;
  End;
end;

function P2P_RemoveFriendship(const AFrom, ATo : String) : Boolean;
var
  cmd : String;
begin
  cmd := blowfishEncrypt(Format('%s REMOVE_FRIENDSHIP %s', [P2P_HEADER, AFrom]));

  Case P2PTYPE of
    p2pTCP   : Begin
                 result := P2P_TCPSendStr('ato.ip', cmd);
               End;
    p2pNone,
    p2pPVPGN : Begin
                 ComponentModuleWindow.GProxy.Whisper(ATo, cmd);
                 result := TRUE;
               End;
  else
    result := FALSE;
  End;
end;


procedure TP2PClass.tcpClientSessionConnected(Sender: TObject; ErrCode: Word);
begin
  ComponentModuleWindow.tcpClient.SendStr(p2pstring);
//  ComponentModuleWindow.tcpClient.Send(avatar)
  ComponentModuleWindow.tcpClient.Close;
end;

procedure TP2PClass.tcpClientSessionClosed(Sender: TObject; ErrCode: Word);
begin
  ComponentModuleWindow.tcpClient.OnSessionAvailable := nil;
  ComponentModuleWindow.tcpClient.OnSessionClosed := nil;
end;

initialization
  p2pclass := TP2PClass.Create;

finalization
  p2pclass.Free;

end.
