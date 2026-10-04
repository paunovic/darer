unit W3GParser;

interface

uses
  Windows;

type
  TW3GReplay_Race = (wrUnknown, wrHuman, wrOrc, wrNightelf, wrUndead, wrDaemon, wrRandom, wrFixed);
  TW3GReplay_GameSpeed = (gsSlow, gsNormal, gsFast);
  TW3GReplay_Visibility = (gvHideTerrain, gvMapExplored, gvAlwaysVisible, gvDefault);
  TW3GReplay_Observers = (goNoObservers, goObserversOnDefeat, goFullObservers, goReferees);
  TW3GReplay_GameType = (gtUnknown, gtLadder, gtCustomScenario, gtCustomPublic, gtCustomPrivate, gtSinglePlayer, gtLadderTeam);
  TW3GReplay_SlotStatus = (ssOpen, ssClosed, ssHuman, ssComputer);
  TW3GReplay_ComputerAIStrength = (aiEasy, aiNormal, aiInsane);

  TW3GReplay_SlotInfo = record
                          Status      : TW3GReplay_SlotStatus;
                          Name        : String;
                          IsHost      : Boolean;
                          Race        : TW3GReplay_Race;
                          AIStrength  : TW3GReplay_ComputerAIStrength;
                          Handicap    : Byte;
                        end;

  TW3GReplay_Slots = Array[0..12] of TW3GReplay_SlotInfo;

  TW3GReplay = record
                 Gamename              : String;
                 Duration              : DWORD;
                 Ladder                : Boolean;
                 GameType              : TW3GReplay_GameType;
                 Version               : record
                                           Major, Build : Integer;
                                         end;
                 Slots                 : TW3GReplay_Slots;
                 GameSpeed             : TW3GReplay_GameSpeed;
                 Visiblity             : TW3GReplay_Visibility;
                 Observers             : TW3GReplay_Observers;
                 TeamsTogether         : Boolean;
                 FixedTeams            : Boolean;
                 FullSharedUnitControl : Boolean;
                 RandomHero            : Boolean;
                 RandomRaces           : Boolean;
                 MapName               : String;
                 MapChecksum           : String[4];
                 CreatorName           : String;
               end;

function ParseReplay(const AReplay : String; var AReplayInfo : TW3GReplay) : Boolean;

implementation

uses
  Classes, SysUtils, ZLibEx, ZLibExApi;

type
  TWC3_Header = record
                  RecordedGame              : Array[0..27] of Char;
                  DataBlockOffset           : DWORD;
                  OverallFileSize           : DWORD;
                  HeaderVersion             : DWORD;
                  OverallDataSize           : DWORD;
                  CompressedDataBlocksCount : DWORD;
                end;

  TWC3_Subheader_V0 = record
                        Unknown       : Word;
                        VersionNumber : Word;
                        BuildNumber   : Word;
                        Flags         : Word;
                        MsecReplayLen : DWORD;
                        HeaderCRC32   : DWORD;
                      end;

  TWC3_Subheader_V1 = record
                        VersionString : Array[0..3] of Char;
                        VersionNumber : DWORD;
                        BuildNumber   : Word;
                        Flags         : Word;
                        MsecReplayLen : DWORD;
                        HeaderCRC32   : DWORD;
                      end;

  TWC3_DataBlock_Header = record
                            CompressedSize   : Word;
                            DecompressedSize : Word;
                            Checksum         : DWORD;
                          end;

  TWC3_SlotRecord = record
                      PlayerID            : Byte;
                      MapDownloadPercent  : Byte;
                      SlotStatus          : Byte;
                      ComputerPlayerFlags : Byte;
                      TeamNumber          : Byte;
                      Color               : Byte;
                      PlayerRaceFlags     : Byte;
                      ComputerAIStrength  : Byte;
                      PlayerHandicap      : Byte;
                    end;

  TW3GReplay_SlotInfoIntern = record
                                ID     : Byte;
                                Name   : String;
                                IsHost : Boolean;
                                Race   : TW3GReplay_Race;
                              end;

  TW3GReplay_Players = record
                         Count : Integer;
                         Items : Array of TW3GReplay_SlotInfoIntern;
                       end;

procedure AddPlayer(var AStream : TMemoryStream; var APlayers : TW3GReplay_Players);
var
  tmpByte : Byte;
begin
  Inc(APlayers.Count);
  SetLength(APlayers.Items, APlayers.Count);


  AStream.Read(tmpByte, SizeOf(Byte));
  APlayers.Items[APlayers.Count - 1].IsHost := tmpByte = 0;

  AStream.Read(APlayers.Items[APlayers.Count - 1].ID, SizeOf(Byte));

  APlayers.Items[APlayers.Count - 1].Name := PChar(pointer(Integer(AStream.Memory) + AStream.Position));
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
end;

function ParseReplay(const AReplay : String; var AReplayInfo : TW3GReplay) : Boolean;
var
  wc3header          : TWC3_Header;
  wc3sh0             : TWC3_Subheader_V0;
  wc3sh1             : TWC3_Subheader_V1;
  blockHeader        : TWC3_DataBlock_Header;
  fileStream         : TFileStream;
  compressedStream   : TMemoryStream;
  decompressedStream : TZDecompressionStream;
  finalStream        : TMemoryStream;
  tmpByte            : Byte;
  tmpByte1           : Byte;
  tmpString          : String;
  slots              : Byte;
  slotRecord         : TWC3_SlotRecord;
  players            : TW3GReplay_Players;
  mask               : Byte;
  C1, C2             : Integer;
begin
  players.Count := 0;
  SetLength(players.Items, players.Count);

  fileStream := TFileStream.Create(AReplay, fmOpenRead);

  fileStream.ReadBuffer(wc3header, SizeOf(TWC3_Header));
  If wc3header.HeaderVersion in [0, 1] Then
  Begin
    Case wc3header.HeaderVersion of
      0 : Begin
            fileStream.ReadBuffer(wc3sh0, SizeOf(TWC3_Subheader_V0));
            AReplayInfo.Version.Major := wc3sh0.VersionNumber;
            AReplayInfo.Version.Build := wc3sh0.BuildNumber;
            AReplayInfo.Duration := wc3sh0.MsecReplayLen;
          End;
      1 : Begin
            fileStream.ReadBuffer(wc3sh1, SizeOf(TWC3_Subheader_V1));
            AReplayInfo.Version.Major := wc3sh1.VersionNumber;
            AReplayInfo.Version.Build := wc3sh1.BuildNumber;
            AReplayInfo.Duration := wc3sh1.MsecReplayLen;
          End;
    End;
  End;

  fileStream.Seek(wc3header.DataBlockOffset, soBeginning);
  fileStream.ReadBuffer(blockHeader, SizeOf(TWC3_DataBlock_Header));

  compressedStream := TMemoryStream.Create;
  compressedStream.CopyFrom(fileStream, blockheader.CompressedSize);
  fileStream.Free;

  decompressedStream := TZDecompressionStream.Create(compressedStream);
  decompressedStream.Position := 0;
  try
    finalStream := TMemoryStream.Create;
    finalStream.CopyFrom(decompressedStream, blockheader.DecompressedSize);
  finally
    decompressedStream.Free;
  end;
  compressedStream.Free;

  finalStream.Position := 4;

  AddPlayer(finalStream, players);

  AReplayInfo.Gamename := PChar(pointer(Integer(finalStream.Memory) + finalStream.Position));
  finalStream.Seek(Length(AReplayInfo.Gamename) + 2, soFromCurrent);

  mask := 0;
  tmpString := '';
  C1 := 0;
  finalStream.Read(tmpByte, 1);
  While tmpByte <> 0 Do
  Begin
    If C1 mod 8 = 0 Then
      mask := tmpByte
    else
      If mask and ($01 shl (C1 mod 8)) = 0 Then
        tmpString := tmpString + Chr(tmpByte - 1)
      else
        tmpString := tmpString + Chr(tmpByte);
    finalStream.Read(tmpByte, 1);
    Inc(C1);
  End;

  Case Ord(tmpString[1]) of
    0 : AReplayInfo.GameSpeed := gsSlow;
    1 : AReplayInfo.GameSpeed := gsNormal;
    2 : AReplayInfo.GameSpeed := gsFast;
  End;

  If Ord(tmpString[2]) and 1 = 1 Then
    AReplayInfo.Visiblity := gvHideTerrain
  else
    If Ord(tmpString[2]) and 2 = 2 Then
      AReplayInfo.Visiblity := gvMapExplored
    else
      If Ord(tmpString[2]) and 4 = 4 Then
        AReplayInfo.Visiblity := gvAlwaysVisible
      else
        If Ord(tmpString[2]) and 8 = 8 Then
          AReplayInfo.Visiblity := gvDefault;

  tmpByte := 0;
  If Ord(tmpString[2]) and 16 = 16 Then
    Inc(tmpByte);
  If Ord(tmpString[2]) and 32 = 32 Then
    Inc(tmpByte, 2);

  If Ord(tmpString[4]) and 64 = 64 Then
    tmpByte := 4;

  Case tmpByte of
    0 : AReplayInfo.Observers := goNoObservers;
    2 : AReplayInfo.Observers := goObserversOnDefeat;
    3 : AReplayInfo.Observers := goFullObservers;
    4 : AReplayInfo.Observers := goReferees;
  End;

  AReplayInfo.TeamsTogether := Ord(tmpString[2]) and 64 = 64;
  AReplayInfo.FixedTeams := Ord(tmpString[3]) = 3;
  AReplayInfo.FullSharedUnitControl := Ord(tmpString[4]) and 1 = 1;
  AReplayInfo.RandomHero := Ord(tmpString[4]) and 2 = 2;
  AReplayInfo.RandomRaces := Ord(tmpString[4]) and 4 = 4;

  AReplayInfo.MapChecksum := Copy(tmpString, 10, 4);

  Delete(tmpString, 1, 13);
  AReplayInfo.MapName := PChar(tmpString);
  Delete(tmpString, 1, Pos(#0, tmpString));
  AReplayInfo.CreatorName := PChar(tmpString);

  finalStream.Seek(4, soFromCurrent);

  finalStream.Read(tmpByte, SizeOf(tmpByte));
  finalStream.Read(tmpByte1, SizeOf(tmpByte1));
  Case tmpByte of
    $00 : AReplayInfo.GameType := gtUnknown;
    $01 : AReplayInfo.GameType := gtLadder;
    $02 : AReplayInfo.GameType := gtCustomScenario;
    $09 : Begin
            AReplayInfo.GameType := gtCustomPublic;
            Case tmpByte1 of
              $00 : AReplayInfo.GameType := gtCustomPublic;
              $08 : AReplayInfo.GameType := gtCustomPrivate;
            End;
          End;
    $1D : AReplayInfo.GameType := gtSinglePlayer;
    $20 : AReplayInfo.GameType := gtLadderTeam;
  End;
  finalStream.Seek(6, soFromCurrent);

  finalStream.Read(tmpByte, SizeOf(Byte));
  finalStream.Seek(-1, soFromCurrent);
  While tmpByte = $16 Do
  Begin
    AddPlayer(finalStream, players);

    finalStream.Seek(4, soFromCurrent);
    finalStream.Read(tmpByte, 1);
    finalStream.Seek(-1, soFromCurrent);
  End;

  finalStream.Seek(SizeOf(Byte) + SizeOf(Word), soFromCurrent);
  finalStream.Read(slots, SizeOf(slots));

  ZeroMemory(@AReplayInfo.Slots, SizeOf(AReplayInfo.Slots)); 
  For C1 := 1 to slots Do
  Begin
    finalStream.Read(slotRecord, SizeOf(TWC3_SlotRecord));

    For C2 := 0 to players.Count - 1 Do
      If slotRecord.PlayerID = players.Items[C2].ID Then
      Begin
        AReplayInfo.Slots[slotRecord.Color].Name := players.Items[C2].Name;
        AReplayInfo.Slots[slotRecord.Color].IsHost := players.Items[C2].IsHost;
        AReplayInfo.Slots[slotRecord.Color].Race := players.Items[C2].Race;
        Break;
      End;

    Case slotRecord.SlotStatus of
      $00 : AReplayInfo.Slots[slotRecord.Color].Status := ssOpen;
      $01 : AReplayInfo.Slots[slotRecord.Color].Status := ssClosed;
      $02 : Case slotRecord.ComputerPlayerFlags of
              $00 : AReplayInfo.Slots[slotRecord.Color].Status := ssHuman;
              $01 : AReplayInfo.Slots[slotRecord.Color].Status := ssComputer;
            End;
    End;

    Case slotRecord.ComputerAIStrength of
      $00 : AReplayInfo.Slots[slotRecord.Color].AIStrength := aiEasy;
      $01 : AReplayInfo.Slots[slotRecord.Color].AIStrength := aiNormal;
      $02 : AReplayInfo.Slots[slotRecord.Color].AIStrength := aiInsane;
    End;

    AReplayInfo.Slots[slotRecord.Color].Handicap := slotRecord.PlayerHandicap;
  End;

  finalStream.Free;
  result := TRUE;
end;

end.

