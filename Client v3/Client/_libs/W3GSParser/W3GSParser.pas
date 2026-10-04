unit W3GSParser;

interface

uses
  Windows, Classes, Socktypes, Winsock2;

type
  PJoinItem = ^TJoinItem;
  TJoinItem = record
                Name         : String;
                IAddr, EAddr : sockaddr_in;
                PID          : Integer;
              end;

  TW3GSSlotInfo = record
                    PID            : Integer;
                    DownloadStatus : Integer;
                    SlotStatus     : Integer;
                    Controller     : Integer;
                    Team           : Integer;
                    Color          : Integer;
                    Race           : Integer;
                    ControllerType : Integer;
                    Handicap       : Integer;
                    Name           : String;
                  end;

  TW3GSSlots    = Array[1..10] of TW3GSSlotInfo;

  PUserItem = ^TUserItem;
  TUserItem = record
                Nick  : String;
                Value : Integer;
              end;


  {$M+}
  TW3GSParser = class(TObject)
                private
                  FJoinList  : TList;
                  FUserNick  : String;
                  FUsersList : TList;

                  function FindPlayerById(const AId : Integer; var ASlotID : Integer; const ASlots : TW3GSSlots) : Boolean;
                  procedure DisposeJoinList;
                  procedure DisposeUsersList;
                  procedure UsersListAdd(const AName : String);

                  function ParseREQJOIN(const AStream : TMemoryStream; const APacketSize : Word; const AHeader : THdrIP) : Boolean;
                  function ParseSLOTINFO(const AStream : TMemoryStream; const APacketSize : Word; const AHeader : THdrIP) : Boolean;
                  function ParseSLOTINFOJOIN(const AStream : TMemoryStream; const APacketSize : Word; const AHeader : THdrIP) : Boolean;
                  function ParsePLAYERINFO(const AStream : TMemoryStream; const APacketSize : Word; const AHeader : THdrIP) : Boolean;
                public
                  Slots : TW3GSSlots;

                  constructor Create;
                  destructor Destroy; override;

                  procedure Reset;
                  function Parse(const AStream : TMemoryStream; const AHeader : THdrIP) : Boolean;
                  function GetMaxUser(const AIndex : Integer) : TUserItem;

                  property UserNick : String read FUserNick;
                  property UsersList : TList read FUsersList;
                published
                end;
  {$M-}

implementation

uses
  W3GSParser_Types, SharedFunctions, SysUtils;

constructor TW3GSParser.Create;
begin
  inherited;

  FJoinList := TList.Create;
  FUsersList := TList.Create;
  Reset;
end;

destructor TW3GSParser.Destroy;
begin
  DisposeJoinList;
  DisposeUsersList;
  FJoinList.Free;

  inherited;
end;

procedure TW3GSParser.DisposeJoinList;
var
  C1 : Integer;
begin
  For C1 := 0 to FJoinList.Count - 1 Do
    Dispose(PJoinItem(FJoinList[C1]));
  FJoinList.Clear;
end;

procedure TW3GSParser.DisposeUsersList;
var
  C1 : Integer;
begin
  For C1 := 0 to FUsersList.Count - 1 Do
    Dispose(PUserItem(FUsersList[C1]));
  FUsersList.Clear;
end;


function TW3GSParser.Parse(const AStream : TMemoryStream; const AHeader : THdrIP) : Boolean;
var
  packetSignature : Byte;
  packetSize      : Word;
begin
  result := FALSE;
  While AStream.Position < AStream.Size - 1 Do
    If ReadByte(AStream, FALSE) = W3GS_SIGNATURE Then
    Begin
      packetSignature := ReadByte(AStream, FALSE);
      packetSize := ReadWord(AStream, FALSE);
      Case packetSignature of
        W3GS_PLAYERLEAVE_OTHERS : ;
        W3GS_LEAVEREQ           : ;
        W3GS_SEARCHGAME         : ;
        W3GS_CREATEGAME         : ;
        W3GS_REFRESHGAME        : ;
        W3GS_DECREATEGAME       : ;
        W3GS_GAMEINFO           : ;
        W3GS_REQJOIN            : result := ParseREQJOIN(AStream, packetSize, AHeader);
        W3GS_REJECTJOIN         : ;
        W3GS_SLOTINFOJOIN       : result := ParseSLOTINFOJOIN(AStream, packetSize, AHeader);
        W3GS_SLOTINFO           : result := ParseSLOTINFO(AStream, packetSize, AHeader);
        W3GS_PLAYERINFO         : result := ParsePLAYERINFO(AStream, packetSize, AHeader);
        W3GS_MAPCHECK           : ;
        W3GS_MAPSIZE            : ;
        W3GS_STARTDOWNLOAD      : ;
        W3GS_MAPPART            : ;
        W3GS_MAPPARTOK          : ;
      End;
    End;
end;

function TW3GSParser.ParseREQJOIN(const AStream : TMemoryStream; const APacketSize : Word; const AHeader : THdrIP) : Boolean;
var
  packetSignature         : Byte;
  packetSize, extGamePort : Word;
  joinGameCounter, getTC  : DWORD;
  gameJCcounter           : DWORD;
  clientName              : AnsiString;
  clientAddr              : sockaddr_in;
  joinItem                : PJoinItem;
begin
  result := FALSE;
  joinGameCounter := ReadDWORD(AStream, FALSE);
  getTC := ReadDWORD(AStream, FALSE);
  If ReadByte(AStream, FALSE) = 0 Then
  Begin
    extGamePort := ReadWord(AStream, FALSE);
    gameJCcounter := ReadDWORD(AStream, FALSE);
    clientName := ReadNullTerminatedString(AStream);
    ReadWord(AStream, FALSE);
    AStream.Read(clientAddr, SizeOf(sockaddr_in));

    UsersListAdd(clientName);

    If (clientName <> '') and
       ((AHeader.daddr.S_addr = clientAddr.sin_addr.S_addr) or
        (AHeader.saddr.S_addr = clientAddr.sin_addr.S_addr)) Then
      FUserNick := String(clientName);

    New(joinItem);
    joinItem^.Name := String(clientName);
    joinItem^.IAddr := clientAddr;
    joinItem^.EAddr := clientAddr;
    joinItem^.PID := -1;
    FJoinList.Add(joinItem);

    ReadDWORD(AStream, FALSE);
    ReadDWORD(AStream, FALSE);
    result := TRUE;
  End;
end;

function TW3GSParser.ParseSLOTINFO(const AStream : TMemoryStream; const APacketSize : Word; const AHeader : THdrIP) : Boolean;
var
  packetSignature         : Byte;
  packetSize, slotsSize   : Word;
  slotsCount, slotsCount1 : Byte;
  getTC                   : DWORD;
  C1                      : Integer;
  pid, pidHTC             : Byte;
  downloadStatus          : Byte;
  slotStatus, controller  : Byte;
  teamNum, colorNum       : Byte;
  raceFlags               : Byte;
  controllerType          : Byte;
  handicapFrom            : Byte;
  clientAddr              : sockaddr_in;
  slotid                  : Integer;
  oldslots                : TW3GSSlots;
  joinItem                : PJoinItem;
begin
  result := FALSE;
  slotsSize := ReadWord(AStream, FALSE);
  If slotsSize <> 0 Then
  Begin
    slotsCount := ReadByte(AStream, FALSE);
    If slotsCount <= 10 Then
    Begin
      oldslots := Slots;

      For C1 := 1 to slotsCount Do
      Begin
        pid := ReadByte(AStream, FALSE);
        If pid > 10 Then
          Break;

        downloadStatus := ReadByte(AStream, FALSE);
        slotStatus := ReadByte(AStream, FALSE);
        controller := ReadByte(AStream, FALSE);
        teamNum := ReadByte(AStream, FALSE);
        colorNum := ReadByte(AStream, FALSE);
        raceFlags := ReadByte(AStream, FALSE);
        controllerType := ReadByte(AStream, FALSE);
        handicapFrom := ReadByte(AStream, FALSE);

        Slots[C1].PID := pid;
        Slots[C1].DownloadStatus := downloadStatus;
        Slots[C1].Controller := controller;
        Slots[C1].Team := teamNum;
        Slots[C1].Color := colorNum;
        Slots[C1].Race := raceFlags;
        Slots[C1].ControllerType := controllerType;
        Slots[C1].Handicap := handicapFrom;
      End;

      For C1 := 0 to FJoinList.Count - 1 Do
        If FindPlayerById(PJoinItem(FJoinList[C1])^.PID, slotid, Slots) Then
        Begin
          Slots[slotid].Name := PJoinItem(FJoinList[C1])^.Name;
          Slots[slotid].PID := PJoinItem(FJoinList[C1])^.PID;
          FJoinList.Delete(C1);
          Break;
        End;

      For C1 := Low(Slots) to High(Slots) Do
        If FindPlayerById(Slots[C1].PID, slotid, oldslots) Then
          Slots[C1].Name := oldslots[slotid].Name;

      getTC := ReadDWORD(AStream, FALSE);
      ReadByte(AStream, FALSE);
      slotsCount1 := ReadByte(AStream, FALSE);
    End;
  End;

  result := TRUE;
end;

function TW3GSParser.ParseSLOTINFOJOIN(const AStream: TMemoryStream; const APacketSize: Word; const AHeader : THdrIP) : Boolean;
var
  packetSignature         : Byte;
  packetSize, slotsSize   : Word;
  slotsCount, slotsCount1 : Byte;
  getTC                   : DWORD;
  C1                      : Integer;
  pid, pidHTC             : Byte;
  downloadStatus          : Byte;
  slotStatus, controller  : Byte;
  teamNum, colorNum       : Byte;
  raceFlags               : Byte;
  controllerType          : Byte;
  handicapFrom            : Byte;
  clientAddr              : sockaddr_in;
  slotid                  : Integer;
  oldslots                : TW3GSSlots;
  joinItem                : PJoinItem;
begin
  result := FALSE;
  slotsSize := ReadWord(AStream, FALSE);
  If slotsSize <> 0 Then
  Begin
    slotsCount := ReadByte(AStream, FALSE);
    If slotsCount <= 10 Then
    Begin
      oldslots := Slots;

      For C1 := 1 to slotsCount Do
      Begin
        pid := ReadByte(AStream, FALSE);
        If pid > 10 Then
          Break;

        downloadStatus := ReadByte(AStream, FALSE);
        slotStatus := ReadByte(AStream, FALSE);
        controller := ReadByte(AStream, FALSE);
        teamNum := ReadByte(AStream, FALSE);
        colorNum := ReadByte(AStream, FALSE);
        raceFlags := ReadByte(AStream, FALSE);
        controllerType := ReadByte(AStream, FALSE);
        handicapFrom := ReadByte(AStream, FALSE);

        Slots[C1].PID := pid;
        Slots[C1].DownloadStatus := downloadStatus;
        Slots[C1].Controller := controller;
        Slots[C1].Team := teamNum;
        Slots[C1].Color := colorNum;
        Slots[C1].Race := raceFlags;
        Slots[C1].ControllerType := controllerType;
        Slots[C1].Handicap := handicapFrom;
      End;

      For C1 := 0 to FJoinList.Count - 1 Do
        If FindPlayerById(PJoinItem(FJoinList[C1])^.PID, slotid, Slots) Then
        Begin
          Slots[slotid].Name := PJoinItem(FJoinList[C1])^.Name;
          Slots[slotid].PID := PJoinItem(FJoinList[C1])^.PID;
          FJoinList.Delete(C1);
          Break;
        End;

      For C1 := Low(Slots) to High(Slots) Do
        If FindPlayerById(Slots[C1].PID, slotid, oldslots) Then
          Slots[C1].Name := oldslots[slotid].Name;

      getTC := ReadDWORD(AStream, FALSE);
      ReadByte(AStream, FALSE);
      slotsCount1 := ReadByte(AStream, FALSE);
    End;
  End;

  pidHTC := ReadByte(AStream, FALSE);
  If (pidHTC >= 1) and
     (pidHTC <= 10) Then
  Begin
    AStream.Read(clientAddr, SizeOf(sockaddr_in));
    ReadDWORD(AStream, FALSE);
    ReadDWORD(AStream, FALSE);

    For C1 := 0 to FJoinList.Count - 1 Do
      If (TJoinItem(FJoinList[C1]^).EAddr.sin_addr.S_addr = clientAddr.sin_addr.S_addr) or
         (TJoinItem(FJoinList[C1]^).IAddr.sin_addr.S_addr = clientAddr.sin_addr.S_addr) Then
      Begin
        joinItem := FJoinList[C1];
        joinItem^.PID := pidHTC;
      End;
  End;
end;

procedure TW3GSParser.Reset;
begin
  DisposeJoinList;
  DisposeUsersList;
  FUserNick := '';
  FillChar(Slots, SizeOf(TW3GSSlots), 0);
end;

procedure TW3GSParser.UsersListAdd(const AName: String);

  function CompareValues(const AItem1, AItem2 : PUserItem) : Integer;
  begin
    If AItem1^.Value > AItem2.Value Then
      result := -1
    else
      If AItem1^.Value < AItem2.Value Then
        result := 1
      else
        result := 0;
  end;

var
  C1       : Integer;
  userItem : PUserItem;
  added    : Boolean;
begin
  If AName <> '' Then
  Begin
    added := FALSE;
    For C1 := 0 to FUsersList.Count - 1 Do
    Begin
      userItem := PUserItem(FUsersList[C1]);
      If LowerCase(userItem^.Nick) = LowerCase(AName) Then
      Begin
        Inc(userItem^.Value);
        added := TRUE;
      End;
    End;

    If not added Then
    Begin
      New(userItem);
      userItem^.Nick := AName;
      userItem^.Value := 1;
      FUsersList.Add(userItem);
    End;
  End;

  FUsersList.Sort(@CompareValues);
end;

function TW3GSParser.ParsePLAYERINFO(const AStream : TMemoryStream; const APacketSize : Word; const AHeader : THdrIP) : Boolean;
var
  playerJCcounter : DWORD;
  pid             : Byte;
  playerName      : AnsiString;
  externAddr,
  internAddr      : sockaddr_in;
  slotid          : Integer;
  joinItem        : PJoinItem;
begin
  playerJCcounter := ReadDWORD(AStream, FALSE);
  pid := ReadByte(AStream, FALSE);

  If (pid >= 1) and
     (pid <= 10) Then
  Begin
    playerName := ReadNullTerminatedString(AStream);
    If ReadWord(AStream, FALSE) = 1 Then
    Begin
      UsersListAdd(playerName);
      AStream.Read(externAddr, SizeOf(sockaddr_in));
      ReadDWORD(AStream, FALSE);
      ReadDWORD(AStream, FALSE);
      AStream.Read(internAddr, SizeOf(sockaddr_in));
      ReadDWORD(AStream, FALSE);

      New(joinItem);
      joinItem^.Name := String(playerName);
      joinItem^.IAddr := internAddr;
      joinItem^.EAddr := externAddr;
      joinItem^.PID := -1;
      FJoinList.Add(joinItem);

      If FindPlayerById(pid, slotid, Slots) Then
        Slots[slotid].Name := String(playerName);
    End;
  End;

  result := TRUE;
end;

function TW3GSParser.FindPlayerById(const AId : Integer; var ASlotID : Integer; const ASlots : TW3GSSlots) : Boolean;
var
  C1 : Integer;
begin
  result := FALSE;
  For C1 := Low(ASlots) to High(ASlots) Do
    If ASlots[C1].PID = AId Then
    Begin
      result := TRUE;
      ASlotID := C1;
      Break;
    End;
end;

function TW3GSParser.GetMaxUser(const AIndex: Integer): TUserItem;
begin
  result := TUserItem(FUsersList[AIndex]^);
end;

end.
