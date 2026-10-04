unit W3GParser;

interface

uses
  Windows, Classes, W3GParser_Types, W3GSParser_Types, DotaParser;

type
  {$M+}
  TW3GParser = class(TObject)
               private
                 FReplayFile   : String;
                 FReplayInfo   : TW3GReplay;
                 FCurrentTime  : DWORD;
//                 FPaused       : Boolean;
                 FLastAction   : Integer;
                 FDotaParser   : TDotaParser;
                 FContinueGame : Boolean;
                 FLeaveUnknown : Integer;
                 FLeaves       : Integer;

                 function ReverseTeam(const ATeam : Integer) : Integer;
                 function GetTeamIndex(const APID : Integer) : Integer;
                 procedure AddPlayer(var AStream : TMemoryStream; var APlayers : TW3GReplay_Players);

                 function ParseBlock(var ABlockStream : TMemoryStream) : Boolean;
                 function ParseHeaderBlock(var ABlockStream : TMemoryStream) : Boolean;
                 function ParseLeaveBlock(var ABlockStream : TMemoryStream) : Boolean;
                 function ParseChatBlock(var ABlockStream : TMemoryStream) : Boolean;
                 function ParseTimeBlock(var ABlockStream : TMemoryStream) : Boolean;
                 function ParseCommandData(const ABlockStream : TMemoryStream) : Boolean;
                 function ParseAction_SaveGame(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_ChangeSelection(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_AssignHotkey(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_MapTriggerChatCommand(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_SyncStoredInteger(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_Unknown3(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_Cheats(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_Ability(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_AbilityTarPos(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_AbilityTarPosId(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_GiveDropItem(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_AbilityTwoTarPosId(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_SelectHotkey(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_SelectSubgroup(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_SelectGroundItem(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_CancelHeroRevival(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_RemoveUnitFromQueue(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_ChangeAllyOptions(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_TransferResources(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_ScenarioTrigger(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_MinimapSignal(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_ContinueGameB(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_ContinueGameA(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_EscPressed(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_ChooseHeroSkill(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
                 function ParseAction_ChooseBuilding(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
               public
                 constructor Create;
                 destructor Destroy; override;

                 procedure Reset;
                 function Parse : Boolean;
                 function FindPlayerID(const AID : Integer) : Integer;
               published
                 property ReplayFile : String read FReplayFile write FReplayFile;
                 property ReplayInfo : TW3GReplay read FReplayInfo;
                 property DotaParser : TDotaParser read FDotaParser;
               end;
  {$M-}



implementation

uses
  SysUtils, ZLib, SharedFunctions, DotaParser_Types;


constructor TW3GParser.Create;
begin
  inherited;

  FDotaParser := TDotaParser.Create;
end;

destructor TW3GParser.Destroy;
begin
  FDotaParser.Free;

  inherited;
end;

function TW3GParser.GetTeamIndex(const APID: Integer): Integer;
begin
  result := 0;
  If (APID >= 1) and
     (APID <= 5) Then
    result := 1
  else
    If (APID >= 7) and
       (APID <= 11) Then
      result := 2;
end;

function TW3GParser.Parse : Boolean;
var
  fileStream         : TFileStream;
  wc3header          : TWC3_Header;
  wc3sh0             : TWC3_Subheader_V0;
  wc3sh1             : TWC3_Subheader_V1;
  blockHeader        : TWC3_DataBlock_Header;
  blockStream        : TMemoryStream;
  compressedStream   : TMemoryStream;
  decompressedStream : TZDecompressionStream;
  C1                 : DWORD;
  apmDivider         : Double;
begin
  result := FALSE;

  Reset;

  try
    fileStream := TFileStream.Create(FReplayFile, fmOpenRead or fmShareDenyWrite);
  except
    Exit;
  end;

  fileStream.ReadBuffer(wc3header, SizeOf(TWC3_Header));
  If wc3header.HeaderVersion in [0, 1] Then
  Begin
    Case wc3header.HeaderVersion of
      0 : Begin
            fileStream.ReadBuffer(wc3sh0, SizeOf(TWC3_Subheader_V0));
            FReplayInfo.Version.Major := wc3sh0.VersionNumber;
            FReplayInfo.Version.Build := wc3sh0.BuildNumber;
            FReplayInfo.Duration := wc3sh0.MsecReplayLen div 1000;
          End;
      1 : Begin
            fileStream.ReadBuffer(wc3sh1, SizeOf(TWC3_Subheader_V1));
            FReplayInfo.Version.Major := wc3sh1.VersionNumber;
            FReplayInfo.Version.Build := wc3sh1.BuildNumber;
            FReplayInfo.Duration := wc3sh1.MsecReplayLen div 1000;
          End;
    End;
  End;

  blockStream := TMemoryStream.Create;
  blockStream.Clear;

  compressedStream := TMemoryStream.Create;

  fileStream.Seek(wc3header.DataBlockOffset, soBeginning);

  For C1 := 1 to wc3header.CompressedDataBlocksCount Do
  Begin
    fileStream.ReadBuffer(blockHeader, SizeOf(TWC3_DataBlock_Header));
    compressedStream.Clear;
    compressedStream.CopyFrom(fileStream, blockheader.CompressedSize);
    decompressedStream := TZDecompressionStream.Create(compressedStream);
    decompressedStream.Seek(0, soFromBeginning);
    If decompressedStream.Size = blockheader.DecompressedSize Then
      blockStream.CopyFrom(decompressedStream, blockheader.DecompressedSize);
    decompressedStream.Free;
  End;

  blockStream.Seek(0, soFromBeginning);
  ParseHeaderBlock(blockStream);

  While (blockStream.Position < blockStream.Size) Do
    If not ParseBlock(blockStream) Then
      blockStream.Seek(1, soFromCurrent);

  compressedStream.Free;
  blockStream.Free;
  fileStream.Free;

  apmDivider := ReplayInfo.Duration / 60;
  If apmDivider <> 0 Then
    For C1 := Low(FReplayInfo.Slots) to High(FReplayInfo.Slots) Do
      FReplayInfo.Slots[C1].APM := Round(FReplayInfo.Slots[C1].TotalActions / apmDivider);

  result := TRUE;
end;

procedure TW3GParser.Reset;
begin
  ZeroMemory(@FReplayInfo, SizeOf(TW3GReplay));
  FReplayInfo.SaverID := -1;
  FLeaveUnknown := -1;
  FLastAction := -1;
  FContinueGame := FALSE;
  FLeaves := 0;
  FCurrentTime := 0;
  FDotaParser.FlushGame;
end;

function TW3GParser.ReverseTeam(const ATeam: Integer): Integer;
begin
  Case ATeam of
    1 : result := 2;
    2 : result := 1;
  else
    result := 0;
  End;
end;

procedure TW3GParser.AddPlayer(var AStream : TMemoryStream; var APlayers : TW3GReplay_Players);
var
  tmpByte : Byte;
begin
  Inc(APlayers.Count);
  SetLength(APlayers.Items, APlayers.Count);

  AStream.Read(tmpByte, SizeOf(Byte));
  APlayers.Items[APlayers.Count - 1].IsHost := tmpByte = 0;

  AStream.Read(APlayers.Items[APlayers.Count - 1].ID, SizeOf(Byte));

  APlayers.Items[APlayers.Count - 1].Name := String(PAnsiChar(pointer(Integer(AStream.Memory) + AStream.Position)));
  AStream.Seek(Length(APlayers.Items[APlayers.Count - 1].Name) + 1, soFromCurrent);

  APlayers.Items[APlayers.Count - 1].Race := wrUnknown;
  AStream.ReadBuffer(tmpByte, SizeOf(tmpByte));
  If tmpByte = $08 Then
  Begin
    AStream.Seek(SizeOf(DWORD), soFromCurrent);
    AStream.Read(tmpByte, SizeOf(tmpByte));
    Case tmpByte of
      $01 : APlayers.Items[APlayers.Count - 1].Race := wrHuman;
      $02 : APlayers.Items[APlayers.Count - 1].Race := wrOrc;
      $04 : APlayers.Items[APlayers.Count - 1].Race := wrNightElf;
      $08 : APlayers.Items[APlayers.Count - 1].Race := wrUndead;
      $10 : APlayers.Items[APlayers.Count - 1].Race := wrDaemon;
      $20 : APlayers.Items[APlayers.Count - 1].Race := wrRandom;
      $40 : APlayers.Items[APlayers.Count - 1].Race := wrFixed;
   End;
  End
  else
    AStream.Seek(1, soFromCurrent);

  Inc(FReplayInfo.PlayersCount);
end;

function TW3GParser.ParseBlock(var ABlockStream : TMemoryStream) : Boolean;
var
  blockType : Integer;
begin
  result := TRUE;
  blockType := ReadByte(ABlockStream);
  Case blockType of
    W3G_BLOCK_FIRST_STARTBLOCK,
    W3G_BLOCK_SECOND_STARTBLOCK,
    W3G_BLOCK_THIRD_STARTBLOCK  : ABlockStream.Seek(5, soFromCurrent);

    W3G_BLOCK_TIMESLOT1,
    W3G_BLOCK_TIMESLOT2         : ParseTimeBlock(ABlockStream);
    W3G_BLOCK_TIMESLOT_SEED     : ABlockStream.Seek(6, soFromCurrent);

    W3G_BLOCK_LEAVEGAME_PREFIX  : ABlockStream.Seek(11, soFromCurrent);
    W3G_BLOCK_LEAVEGAME         : ParseLeaveBlock(ABlockStream);

    W3G_BLOCK_PLAYERCHAT        : ParseChatBlock(ABlockStream);
    W3G_BLOCK_FORCED_GAMEEND    : ABlockStream.Seek(9, soFromCurrent);
  else
    result := FALSE;
  End;
end;

function TW3GParser.ParseHeaderBlock(var ABlockStream : TMemoryStream) : Boolean;
var
  tmpByte    : Byte;
  tmpByte1   : Byte;
  tmpString  : String;
  slots      : Byte;
  slotRecord : TWC3_SlotRecord;
  players    : TW3GReplay_Players;
  mask       : Byte;
  C1, C2     : Integer;
begin
  players.Count := 0;
  SetLength(players.Items, players.Count);

  ABlockStream.Position := 4;

  AddPlayer(ABlockStream, players);

  FReplayInfo.Gamename := String(PAnsiChar(pointer(Integer(ABlockStream.Memory) + ABlockStream.Position)));
  ABlockStream.Seek(Length(FReplayInfo.Gamename) + 2, soFromCurrent);

  mask := 0;
  tmpString := '';
  C1 := 0;
  ABlockStream.Read(tmpByte, 1);
  While tmpByte <> 0 Do
  Begin
    If C1 mod 8 = 0 Then
      mask := tmpByte
    else
      If mask and ($01 shl (C1 mod 8)) = 0 Then
        tmpString := Concat(tmpString, Chr(tmpByte - 1))
      else
        tmpString := Concat(tmpString, Chr(tmpByte));
    ABlockStream.Read(tmpByte, 1);
    Inc(C1);
  End;

  Case Ord(tmpString[1]) of
    0 : FReplayInfo.GameSpeed := gsSlow;
    1 : FReplayInfo.GameSpeed := gsNormal;
    2 : FReplayInfo.GameSpeed := gsFast;
  End;

  If Ord(tmpString[2]) and 1 = 1 Then
    FReplayInfo.Visiblity := gvHideTerrain
  else
    If Ord(tmpString[2]) and 2 = 2 Then
      FReplayInfo.Visiblity := gvMapExplored
    else
      If Ord(tmpString[2]) and 4 = 4 Then
        FReplayInfo.Visiblity := gvAlwaysVisible
      else
        If Ord(tmpString[2]) and 8 = 8 Then
          FReplayInfo.Visiblity := gvDefault;

  tmpByte := 0;
  If Ord(tmpString[2]) and 16 = 16 Then
    Inc(tmpByte);
  If Ord(tmpString[2]) and 32 = 32 Then
    Inc(tmpByte, 2);

  If Ord(tmpString[4]) and 64 = 64 Then
    tmpByte := 4;

  Case tmpByte of
    0 : FReplayInfo.Observers := goNoObservers;
    2 : FReplayInfo.Observers := goObserversOnDefeat;
    3 : FReplayInfo.Observers := goFullObservers;
    4 : FReplayInfo.Observers := goReferees;
  End;

  FReplayInfo.TeamsTogether := Ord(tmpString[2]) and 64 = 64;
  FReplayInfo.FixedTeams := Ord(tmpString[3]) = 3;
  FReplayInfo.FullSharedUnitControl := Ord(tmpString[4]) and 1 = 1;
  FReplayInfo.RandomHero := Ord(tmpString[4]) and 2 = 2;
  FReplayInfo.RandomRaces := Ord(tmpString[4]) and 4 = 4;

  FReplayInfo.MapChecksum := Copy(tmpString, 10, 4);

  Delete(tmpString, 1, 13);
  FReplayInfo.MapName := StrPas(PChar(tmpString));
  Delete(tmpString, 1, Pos(#0, tmpString));
  FReplayInfo.CreatorName := StrPas(PChar(tmpString));

  ABlockStream.Seek(4, soFromCurrent);

  ABlockStream.Read(tmpByte, SizeOf(tmpByte));
  ABlockStream.Read(tmpByte1, SizeOf(tmpByte1));
  Case tmpByte of
    $00 : FReplayInfo.GameType := gtUnknown;
    $01 : FReplayInfo.GameType := gtLadder;
    $02 : FReplayInfo.GameType := gtCustomScenario;
    $09 : Begin
            FReplayInfo.GameType := gtCustomPublic;
            Case tmpByte1 of
              $00 : FReplayInfo.GameType := gtCustomPublic;
              $08 : FReplayInfo.GameType := gtCustomPrivate;
            End;
          End;
    $1D : FReplayInfo.GameType := gtSinglePlayer;
    $20 : FReplayInfo.GameType := gtLadderTeam;
  End;
  ABlockStream.Seek(6, soFromCurrent);

  ABlockStream.Read(tmpByte, SizeOf(Byte));
  ABlockStream.Seek(-1, soFromCurrent);
  While tmpByte = $16 Do
  Begin
    AddPlayer(ABlockStream, players);

    ABlockStream.Seek(4, soFromCurrent);
    ABlockStream.Read(tmpByte, 1);
    ABlockStream.Seek(-1, soFromCurrent);
  End;

  ABlockStream.Seek(SizeOf(Byte) + SizeOf(Word), soFromCurrent);
  ABlockStream.Read(slots, SizeOf(slots));

  ZeroMemory(@FReplayInfo.Slots, SizeOf(FReplayInfo.Slots));
  For C1 := 1 to slots Do
  Begin
    ABlockStream.Read(slotRecord, SizeOf(TWC3_SlotRecord));

    For C2 := 0 to players.Count - 1 Do
      If slotRecord.PlayerID = players.Items[C2].ID Then
      Begin
        FReplayInfo.Slots[slotRecord.Color].Name := players.Items[C2].Name;
        FReplayInfo.Slots[slotRecord.Color].IsHost := players.Items[C2].IsHost;
        FReplayInfo.Slots[slotRecord.Color].Race := players.Items[C2].Race;
        FReplayInfo.Slots[slotRecord.Color].ID := slotRecord.PlayerID;
        Break;
      End;

    Case slotRecord.SlotStatus of
      $00 : FReplayInfo.Slots[slotRecord.Color].Status := ssOpen;
      $01 : FReplayInfo.Slots[slotRecord.Color].Status := ssClosed;
      $02 : Case slotRecord.ComputerPlayerFlags of
              $00 : FReplayInfo.Slots[slotRecord.Color].Status := ssHuman;
              $01 : FReplayInfo.Slots[slotRecord.Color].Status := ssComputer;
            End;
    End;

    Case slotRecord.ComputerAIStrength of
      $00 : FReplayInfo.Slots[slotRecord.Color].AIStrength := aiEasy;
      $01 : FReplayInfo.Slots[slotRecord.Color].AIStrength := aiNormal;
      $02 : FReplayInfo.Slots[slotRecord.Color].AIStrength := aiInsane;
    End;

    FReplayInfo.Slots[slotRecord.Color].Handicap := slotRecord.PlayerHandicap;
  End;

  ABlockStream.Read(FReplayInfo.RandomSeed, SizeOf(FReplayInfo.RandomSeed));
  ABlockStream.Seek(2, soFromCurrent);

  result := TRUE;
end;

function TW3GParser.FindPlayerID(const AID : Integer) : Integer;
var
  C1 : Integer;
begin
  result := -1;
  For C1 := Low(FReplayInfo.Slots) to High(FReplayInfo.Slots) Do
    If FReplayInfo.Slots[C1].ID = AID Then
    Begin
      result := C1;
      Break;
    End;
end;

function TW3GParser.ParseLeaveBlock(var ABlockStream : TMemoryStream) : Boolean;
var
  reason, res, unknown : DWORD;
  pid                  : Byte;
  slotID               : Integer;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_BLOCK_LEAVEGAME Then
  Begin
    Inc(FLeaves);

    ABlockStream.Read(reason, SizeOf(reason));
    ABlockStream.Read(pid, SizeOf(pid));
    ABlockStream.Read(res, SizeOf(res));
    ABlockStream.Read(unknown, SizeOf(unknown));

    slotID := FindPlayerID(pid);
    If slotID <> -1 Then
    Begin
      FReplayInfo.Slots[slotID].LeftReason := reason;
      FReplayInfo.Slots[slotID].LeftResult := res;
      FReplayInfo.Slots[slotID].LeftTime := FCurrentTime div 1000;

      If FLeaveUnknown <> -1 Then
        FLeaveUnknown := Integer(unknown) - FLeaveUnknown;

      If FLeaves = FReplayInfo.PlayersCount Then
        FReplayInfo.SaverID := slotID;

      Case reason of
        $01 : Case res of
                $08 : FReplayInfo.WinnerTeam := ReverseTeam(GetTeamIndex(slotID));
                $09 : FReplayInfo.WinnerTeam := GetTeamIndex(slotID); // won
              End;
        $0C : Begin
                If FReplayInfo.SaverID = -1 Then
                  FReplayInfo.SaverID := slotID
                else
                Begin
                  Case res of
                    $01 : ; // saver disconnected
                    $07 : Begin
                            If (FLeaveUnknown > 0) and
                               (FContinueGame) Then
                              FReplayInfo.WinnerTeam := GetTeamIndex(slotID) // saver won
                            else
                              FReplayInfo.WinnerTeam := ReverseTeam(GetTeamIndex(slotID)); // saver lost
                          End;

                    $08 : FReplayInfo.WinnerTeam := ReverseTeam(GetTeamIndex(slotID)); // saver lost
                    $09 : FReplayInfo.WinnerTeam := GetTeamIndex(slotID); // saver won
                    $0B : If FLeaveUnknown > 0 Then
                            FReplayInfo.WinnerTeam := GetTeamIndex(slotID); // saver won
                  End;
                End;
              End;
      End;
      FLeaveUnknown := unknown;
    End;

    result := TRUE;
  End;
end;

function TW3GParser.ParseChatBlock(var ABlockStream : TMemoryStream) : Boolean;
var
  n        : Word;
  chatMode : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_BLOCK_PLAYERCHAT Then
  Begin
    Inc(FReplayInfo.Chat.Count);
    SetLength(FReplayInfo.Chat.Items, FReplayInfo.Chat.Count);

    With FReplayInfo.Chat.Items[FReplayInfo.Chat.Count - 1] Do
    Begin
      ABlockStream.Read(PlayerID, SizeOf(PlayerID));
      ABlockStream.Read(n, SizeOf(n));
      ABlockStream.Read(Flags, SizeOf(Flags));

      If flags = $20 Then
      Begin
        ABlockStream.Read(chatMode, SizeOf(chatMode));
        Case chatMode of
          $00 : ChatType := ctAll;
          $01 : ChatType := ctAllies;
          $02 : ChatType := ctObservers;
        else
          ChatType := ctSpecificPlayer;
          ToPlayer := chatMode - $03;
        End;
      End;

      If n > 5 Then
      Begin
        SetLength(Text, n - 5);
        ABlockStream.Read(Text[1], n - 5);
        Text := StrPas(PAnsiChar(Text));
      End
      else
        Text := '';

      Time := FCurrentTime div 1000;

      result := TRUE;
    End;
  End;
end;

function TW3GParser.ParseCommandData(const ABlockStream : TMemoryStream) : Boolean;
var
  pid               : Byte;
  actionBlockLength : Word;
  actionType        : Byte;
  oldPos            : Int64;
  slotID            : Integer;
begin
  result := TRUE;

  ABlockStream.Read(pid, SizeOf(pid));
  ABlockStream.Read(actionBlockLength, SizeOf(actionBlockLength));

  slotID := FindPlayerID(pid);
  FLastAction := -1;
  oldPos := ABlockStream.Position;

  While ABlockStream.Position < oldPos + actionBlockLength Do
  Begin
    actionType := ReadByte(ABlockStream);

    Case actionType of
      W3G_ACTION_PAUSEGAME            : ABlockStream.Seek(1, soFromCurrent);
      W3G_ACTION_RESUMEGAME           : ABlockStream.Seek(1, soFromCurrent);
      W3G_ACTION_SETGAMESPEED         : ABlockStream.Seek(2, soFromCurrent);
      W3G_ACTION_INCREASEGAMESPEED    : ABlockStream.Seek(1, soFromCurrent);
      W3G_ACTION_DECREASEGAMESPEED    : ABlockStream.Seek(1, soFromCurrent);
      W3G_ACTION_SAVEGAME             : ParseAction_SaveGame(ABlockStream, slotID);
      W3G_ACTION_SAVEGAMEFINISHED     : ABlockStream.Seek(5, soFromCurrent);
      W3G_ACTION_ABILITY              : ParseAction_Ability(ABlockStream, slotID);
      W3G_ACTION_ABILITY_TARPOS       : ParseAction_AbilityTarPos(ABlockStream, slotID);
      W3G_ACTION_ABILITY_TARPOSID     : ParseAction_AbilityTarPosId(ABlockStream, slotID);
      W3G_ACTION_GIVEDROPITEM         : ParseAction_GiveDropItem(ABlockStream, slotID);
      W3G_ACTION_ABILITY_TWOTARPOSID  : ParseAction_AbilityTwoTarPosId(ABlockStream, slotID);
      W3G_ACTION_CHANGESELECTION      : ParseAction_ChangeSelection(ABlockStream, slotID);
      W3G_ACTION_ASSIGNHOTKEY         : ParseAction_AssignHotkey(ABlockStream, slotID);
      W3G_ACTION_SELECTHOTKEY         : ParseAction_SelectHotkey(ABlockStream, slotID);
      W3G_ACTION_SELECTSUBGROUP       : ParseAction_SelectSubgroup(ABlockStream, slotID);
      W3G_ACTION_PRESUBSELECTION      : ABlockStream.Seek(1, soFromCurrent);
      W3G_ACTION_UNKNOWN1             : ABlockStream.Seek(10, soFromCurrent);
      W3G_ACTION_SELECTGROUNDITEM     : ParseAction_SelectGroundItem(ABlockStream, slotID);
      W3G_ACTION_CANCELHEROREVIVAL    : ParseAction_CancelHeroRevival(ABlockStream, slotID);
      W3G_ACTION_REMOVEUNITFROMQUEUE  : ParseAction_RemoveUnitFromQueue(ABlockStream, slotID);
      W3G_ACTION_UNKNOWN2             : ABlockStream.Seek(9, soFromCurrent);
      W3G_ACTION_CHANGEALLYOPTIONS    : ParseAction_ChangeAllyOptions(ABlockStream, slotID);
      W3G_ACTION_TRANSFERRESOURCES    : ParseAction_TransferResources(ABlockStream, slotID);
      W3G_ACTION_MAPTRIGGERCHATCMD    : ParseAction_MapTriggerChatCommand(ABlockStream, slotID);
      W3G_ACTION_ESCPRESSED           : ParseAction_EscPressed(ABlockStream, slotID);
      W3G_ACTION_SCENARIOTRIGGER      : ParseAction_ScenarioTrigger(ABlockStream, slotID);
      W3G_ACTION_MENU_CHOOSEHEROSKILL : ParseAction_ChooseHeroSkill(ABlockStream, slotID);
      W3G_ACTION_MENU_CHOOSEBUILDING  : ParseAction_ChooseBuilding(ABlockStream, slotID);
      W3G_ACTION_MINIMAPSIGNAL        : ParseAction_MinimapSignal(ABlockStream, slotID);
      W3G_ACTION_CONTINUEGAME_B       : ParseAction_ContinueGameB(ABlockStream, slotID);
      W3G_ACTION_CONTINUEGAME_A       : ParseAction_ContinueGameA(ABlockStream, slotID);
      W3G_ACTION_SYNCSTOREDINTEGER    : ParseAction_SyncStoredInteger(ABlockStream, slotID);
      W3G_ACTION_UNKNOWN3             : ParseAction_Unknown3(ABlockStream, slotID);
      W3G_ACTION_UNKNOWN4             : ABlockStream.Seek(2, soFromCurrent);
    else
      If actionType in W3G_ACTION_CHEATS Then
        ParseAction_Cheats(ABlockStream, slotID)
      else
        result := FALSE;
    End;
  End;
end;

function TW3GParser.ParseTimeBlock(var ABlockStream : TMemoryStream) : Boolean;
var
  n, timeInc : Word;
  oldPos     : Int64;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) in [W3G_BLOCK_TIMESLOT1, W3G_BLOCK_TIMESLOT2] Then
  Begin
    ABlockStream.Read(n, SizeOf(n));
    ABlockStream.Read(timeInc, SizeOf(timeInc));

    oldPos := ABlockStream.Position;
    While ABlockStream.Position < oldPos + n - 2 Do
      ParseCommandData(ABlockStream);

    Inc(FCurrentTime, timeInc);

    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_SaveGame(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  saveName : AnsiString;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_SAVEGAME Then
  Begin
    saveName := ReadNullTerminatedString(ABlockStream);

    FLastAction := W3G_ACTION_SAVEGAME;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_ChangeSelection(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  mode       : Byte;
  n          : Word;
  C1         : Integer;
  obj1, obj2 : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_CHANGESELECTION Then
  Begin
    ABlockStream.Read(mode, SizeOf(mode));
    ABlockStream.Read(n, SizeOf(n));

    For C1 := 1 to n Do
    Begin
      ABlockStream.Read(obj1, SizeOf(obj1));
      ABlockStream.Read(obj2, SizeOf(obj2));
    End;

    If FLastAction <> W3G_ACTION_CHANGESELECTION_REM Then
      Inc(FReplayInfo.Slots[ASlotID].TotalActions);

    Case mode of
      $01 : FLastAction := W3G_ACTION_CHANGESELECTION_ADD;
      $02 : FLastAction := W3G_ACTION_CHANGESELECTION_REM;
    End;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_AssignHotkey(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  groupNum   : Byte;
  n          : Word;
  C1         : Integer;
  obj1, obj2 : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_ASSIGNHOTKEY Then
  Begin
    ABlockStream.Read(groupNum, SizeOf(groupNum));
    ABlockStream.Read(n, SizeOf(n));

    For C1 := 1 to n Do
    Begin
      ABlockStream.Read(obj1, SizeOf(obj1));
      ABlockStream.Read(obj2, SizeOf(obj2));
    End;

    Inc(FReplayInfo.Slots[ASlotID].TotalActions);

    FLastAction := W3G_ACTION_ASSIGNHOTKEY;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_MapTriggerChatCommand(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  tmpA, tmpB : DWORD;
  cmd        : AnsiString;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_MAPTRIGGERCHATCMD Then
  Begin
    ABlockStream.Read(tmpA, SizeOf(tmpA));
    ABlockStream.Read(tmpB, SizeOf(tmpB));

    cmd := ReadNullTerminatedString(ABlockStream);

    FLastAction := W3G_ACTION_MAPTRIGGERCHATCMD;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_SyncStoredInteger(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  GameCache, MissionKey, Key : AnsiString;
  value                      : DWORD;
  tmpInt                     : Integer;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_SYNCSTOREDINTEGER Then
  Begin
    GameCache := ReadNullTerminatedString(ABlockStream);
    MissionKey := ReadNullTerminatedString(ABlockStream);
    Key := ReadNullTerminatedString(ABlockStream);
    ABlockStream.Read(value, SizeOf(value));

    If (GameCache = 'dr.x') Then
    Begin
      If MissionKey = 'Data' Then
        FDotaParser.ParseDataString(String(Key), value);

      If MissionKey = 'Global' Then
        FDotaParser.ParseGlobalString(String(Key), value);

      If CheckAndModifyValue(StrToIntDef(String(MissionKey), -1), tmpInt) Then
        FDotaParser.ParseEndGameString(tmpInt, String(Key), value);
    End;

    FLastAction := W3G_ACTION_SYNCSTOREDINTEGER;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_Unknown3(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  tmp1, tmp2, tmp3 : AnsiString;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_UNKNOWN3 Then
  Begin
    tmp1 := ReadNullTerminatedString(ABlockStream);
    tmp2 := ReadNullTerminatedString(ABlockStream);
    tmp3 := ReadNullTerminatedString(ABlockStream);

    FLastAction := W3G_ACTION_UNKNOWN3;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_Cheats(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  actionType : Integer;
  tmpByte    : Byte;
  tmpDWORD   : DWORD;
  tmpSingle  : Single;
begin
  result := FALSE;

  actionType := ReadByte(ABlockStream, FALSE);
  If actionType in W3G_ACTION_CHEATS Then
  Begin
    Case actionType of
      $20 : ; // TheDudeAbides
      $22 : ; // SomebodySetUpUsTheBomb
      $23 : ; // WarpTen
      $24 : ; // IocainePowder
      $25 : ; // PointBreak
      $26 : ; // WhosYourDaddy
      $27 : Begin // KeyserSoze [amount]
              ABlockStream.Read(tmpByte, SizeOf(tmpByte));
              ABlockStream.Read(tmpDWORD, SizeOf(tmpDWORD));
            End;
      $28 : Begin // LeafitToMe [amount]
              ABlockStream.Read(tmpByte, SizeOf(tmpByte));
              ABlockStream.Read(tmpDWORD, SizeOf(tmpDWORD));
            End;
      $29 : ; // ThereIsNoSpoon
      $2A : ; // StrengthAndHonor
      $2B : ; // ItVexesMe
      $2C : ; // WhoIsJohnGalt
      $2D : Begin // GreedIsGood [amount]
              ABlockStream.Read(tmpByte, SizeOf(tmpByte));
              ABlockStream.Read(tmpDWORD, SizeOf(tmpDWORD));
            End;
      $2E : ABlockStream.Read(tmpSingle, SizeOf(tmpSingle)); // DayLightSavings [time]=
      $2F : ; // ISeeDeadPeople
      $30 : ; // Synergy
      $31 : ; // SharpAndShiny
      $32 : ; // AllYourBaseAreBelongToUs
    End;

    FLastAction := W3G_ACTION_CHEAT;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_Ability(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  AbilityFlags : Word;
  ItemID       : DWORD;
  tmpA, tmpB   : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_ABILITY Then
  Begin
    ABlockStream.Read(AbilityFlags, SizeOf(AbilityFlags));

    ABlockStream.Read(ItemID, SizeOf(ItemID));

    ABlockStream.Read(tmpA, Sizeof(tmpA));
    ABlockStream.Read(tmpB, Sizeof(tmpB));

    Inc(FReplayInfo.Slots[ASlotID].TotalActions);

    FLastAction := W3G_ACTION_ABILITY;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_AbilityTarPos(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  AbilityFlags : Word;
  ItemID       : DWORD;
  tmpA, tmpB   : DWORD;
  locX, locY   : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_ABILITY_TARPOS Then
  Begin
    ABlockStream.Read(AbilityFlags, SizeOf(AbilityFlags));

    ABlockStream.Read(ItemID, SizeOf(ItemID));
    ABlockStream.Read(tmpA, Sizeof(tmpA));
    ABlockStream.Read(tmpB, Sizeof(tmpB));

    ABlockStream.Read(locX, Sizeof(locX));
    ABlockStream.Read(locY, Sizeof(locY));

    Inc(FReplayInfo.Slots[ASlotID].TotalActions);

    FLastAction := W3G_ACTION_ABILITY_TARPOS;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_AbilityTarPosId(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  AbilityFlags : Word;
  ItemID       : DWORD;
  tmpA, tmpB   : DWORD;
  locX, locY   : DWORD;
  obj1, obj2   : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_ABILITY_TARPOSID Then
  Begin
    ABlockStream.Read(AbilityFlags, SizeOf(AbilityFlags));

    ABlockStream.Read(ItemID, SizeOf(ItemID));
    ABlockStream.Read(tmpA, Sizeof(tmpA));
    ABlockStream.Read(tmpB, Sizeof(tmpB));

    ABlockStream.Read(locX, Sizeof(locX));
    ABlockStream.Read(locY, Sizeof(locY));

    ABlockStream.Read(obj1, Sizeof(obj1));
    ABlockStream.Read(obj2, Sizeof(obj2));

    Inc(FReplayInfo.Slots[ASlotID].TotalActions);

    FLastAction := W3G_ACTION_ABILITY_TARPOSID;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_GiveDropItem(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  AbilityFlags : Word;
  ItemID       : DWORD;
  tmpA, tmpB   : DWORD;
  locX, locY   : DWORD;
  tobj1, tobj2 : DWORD;
  iobj1, iobj2 : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_GIVEDROPITEM Then
  Begin
    ABlockStream.Read(AbilityFlags, SizeOf(AbilityFlags));

    ABlockStream.Read(ItemID, SizeOf(ItemID));
    ABlockStream.Read(tmpA, Sizeof(tmpA));
    ABlockStream.Read(tmpB, Sizeof(tmpB));

    ABlockStream.Read(locX, Sizeof(locX));
    ABlockStream.Read(locY, Sizeof(locY));

    ABlockStream.Read(tobj1, Sizeof(tobj1));
    ABlockStream.Read(tobj2, Sizeof(tobj2));

    ABlockStream.Read(iobj1, Sizeof(iobj1));
    ABlockStream.Read(iobj2, Sizeof(iobj2));

    Inc(FReplayInfo.Slots[ASlotID].TotalActions);

    FLastAction := W3G_ACTION_GIVEDROPITEM;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_AbilityTwoTarPosId(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  AbilityFlags : Word;
  iidA, iiDB   : DWORD;
  tmpA, tmpB   : DWORD;
  locAX, locAY : DWORD;
  locBX, locBY : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_ABILITY_TWOTARPOSID Then
  Begin
    ABlockStream.Read(AbilityFlags, SizeOf(AbilityFlags));

    ABlockStream.Read(iidA, SizeOf(iidA));

    ABlockStream.Read(tmpA, Sizeof(tmpA));
    ABlockStream.Read(tmpB, Sizeof(tmpB));

    ABlockStream.Read(locAX, Sizeof(locAX));
    ABlockStream.Read(locAY, Sizeof(locAY));

    ABlockStream.Read(iidB, SizeOf(iidB));

    ABlockStream.Seek(9, soFromCurrent);

    ABlockStream.Read(locBX, Sizeof(locBX));
    ABlockStream.Read(locBY, Sizeof(locBY));

    Inc(FReplayInfo.Slots[ASlotID].TotalActions);

    FLastAction := W3G_ACTION_ABILITY_TWOTARPOSID;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_SelectHotkey(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  groupNumber : Byte;
  unknown     : Byte;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_SELECTHOTKEY Then
  Begin
    ABlockStream.Read(groupNumber, SizeOf(groupNumber));
    ABlockStream.Read(unknown, SizeOf(unknown));

    Inc(FReplayInfo.Slots[ASlotID].TotalActions);

    FLastAction := W3G_ACTION_SELECTHOTKEY;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_SelectSubgroup(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  iid        : DWORD;
  obj1, obj2 : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_SELECTSUBGROUP Then
  Begin
    ABlockStream.Read(iid, SizeOf(iid));
    ABlockStream.Read(obj1, SizeOf(obj1));
    ABlockStream.Read(obj2, SizeOf(obj2));

//    Inc(FReplayInfo.Slots[ASlotID].TotalActions);

    FLastAction := W3G_ACTION_SELECTSUBGROUP;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_SelectGroundItem(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  unknown    : Byte;
  obj1, obj2 : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_SELECTGROUNDITEM Then
  Begin
    ABlockStream.Read(unknown, SizeOf(unknown));
    ABlockStream.Read(obj1, SizeOf(obj1));
    ABlockStream.Read(obj2, SizeOf(obj2));

    Inc(FReplayInfo.Slots[ASlotID].TotalActions);

    FLastAction := W3G_ACTION_SELECTGROUNDITEM;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_CancelHeroRevival(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  uid1, uid2 : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_CANCELHEROREVIVAL Then
  Begin
    ABlockStream.Read(uid1, SizeOf(uid1));
    ABlockStream.Read(uid2, SizeOf(uid2));

    Inc(FReplayInfo.Slots[ASlotID].TotalActions);

    FLastAction := W3G_ACTION_CANCELHEROREVIVAL;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_RemoveUnitFromQueue(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  slot : Byte;
  iid  : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_REMOVEUNITFROMQUEUE Then
  Begin
    ABlockStream.Read(slot, SizeOf(slot));
    ABlockStream.Read(iid, SizeOf(iid));

    Inc(FReplayInfo.Slots[ASlotID].TotalActions);

    FLastAction := W3G_ACTION_REMOVEUNITFROMQUEUE;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_ChangeAllyOptions(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  slot  : Byte;
  flags : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_CHANGEALLYOPTIONS Then
  Begin
    ABlockStream.Read(slot, SizeOf(slot));
    ABlockStream.Read(flags, SizeOf(flags));

    FLastAction := W3G_ACTION_CHANGEALLYOPTIONS;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_TransferResources(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  slot   : Byte;
  gold   : DWORD;
  lumber : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_TRANSFERRESOURCES Then
  Begin
    ABlockStream.Read(slot, SizeOf(slot));
    ABlockStream.Read(gold, SizeOf(gold));
    ABlockStream.Read(lumber, SizeOf(lumber));

    FReplayInfo.TransferHack := TRUE;

    FLastAction := W3G_ACTION_TRANSFERRESOURCES;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_ScenarioTrigger(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  tmpA, tmpB, tmpC : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_SCENARIOTRIGGER Then
  Begin
    ABlockStream.Read(tmpA, SizeOf(tmpA));
    ABlockStream.Read(tmpB, SizeOf(tmpB));
    ABlockStream.Read(tmpC, SizeOf(tmpC));

    FLastAction := W3G_ACTION_SCENARIOTRIGGER;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_MinimapSignal(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  tmp        : DWORD;
  locX, locY : Single;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_MINIMAPSIGNAL Then
  Begin
    ABlockStream.Read(locX, SizeOf(locX));
    ABlockStream.Read(locY, SizeOf(locY));
    ABlockStream.Read(tmp, SizeOf(tmp));

    FLastAction := W3G_ACTION_MINIMAPSIGNAL;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_ContinueGameB(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  tmpA, tmpB, tmpC, tmpD : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_CONTINUEGAME_B Then
  Begin
    ABlockStream.Read(tmpA, SizeOf(tmpA));
    ABlockStream.Read(tmpB, SizeOf(tmpB));
    ABlockStream.Read(tmpC, SizeOf(tmpC));
    ABlockStream.Read(tmpD, SizeOf(tmpD));

    FLastAction := W3G_ACTION_CONTINUEGAME_B;
    FContinueGame := TRUE;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_ContinueGameA(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
var
  tmpA, tmpB, tmpC, tmpD : DWORD;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_CONTINUEGAME_A Then
  Begin
    ABlockStream.Read(tmpA, SizeOf(tmpA));
    ABlockStream.Read(tmpB, SizeOf(tmpB));
    ABlockStream.Read(tmpC, SizeOf(tmpC));
    ABlockStream.Read(tmpD, SizeOf(tmpD));

    FLastAction := W3G_ACTION_CONTINUEGAME_A;
    FContinueGame := TRUE;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_EscPressed(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_ESCPRESSED Then
  Begin
    Inc(FReplayInfo.Slots[ASlotID].TotalActions);

    FLastAction := W3G_ACTION_ESCPRESSED;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_ChooseHeroSkill(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_MENU_CHOOSEHEROSKILL Then
  Begin
    Inc(FReplayInfo.Slots[ASlotID].TotalActions);

    FLastAction := W3G_ACTION_MENU_CHOOSEHEROSKILL;
    result := TRUE;
  End;
end;

function TW3GParser.ParseAction_ChooseBuilding(const ABlockStream : TMemoryStream; const ASlotID : Integer) : Boolean;
begin
  result := FALSE;

  If ReadByte(ABlockStream, FALSE) = W3G_ACTION_MENU_CHOOSEBUILDING Then
  Begin
    Inc(FReplayInfo.Slots[ASlotID].TotalActions);

    FLastAction := W3G_ACTION_MENU_CHOOSEBUILDING;
    result := TRUE;
  End;
end;


end.

