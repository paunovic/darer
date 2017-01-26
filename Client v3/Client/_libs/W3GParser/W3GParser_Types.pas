unit W3GParser_Types;

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
  TW3GReplay_ChatType = (ctAll, ctAllies, ctObservers, ctSpecificPlayer);

  TW3GReplay_SlotInfo = record
                          ID           : Integer;
                          Status       : TW3GReplay_SlotStatus;
                          Name         : String;
                          IsHost       : Boolean;
                          Race         : TW3GReplay_Race;
                          AIStrength   : TW3GReplay_ComputerAIStrength;
                          Handicap     : Byte;
                          LeftReason   : DWORD;
                          LeftResult   : DWORD;
                          LeftTime     : DWORD;
                          Disconnected : DWORD;
                          TotalActions : DWORD;
                          APM          : DWORD;
                        end;

  TW3GReplay_Slots = Array[0..12] of TW3GReplay_SlotInfo;

  TW3GReplay_ChatLine = record
                          PlayerID : Byte;
                          Flags    : Byte;
                          ChatType : TW3GReplay_ChatType;
                          ToPlayer : Integer;
                          Text     : AnsiString;
                          Time     : DWORD;
                        end;
  TW3GReplay_Chat = record
                      Count : Integer;
                      Items : Array of TW3GReplay_ChatLine;
                    end;

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
                 MapChecksum           : String;
                 CreatorName           : String;
                 RandomSeed            : DWORD;
                 Chat                  : TW3GReplay_Chat;
                 TransferHack          : Boolean;
                 SaverID               : Integer;
                 WinnerTeam            : Integer;
                 PlayersCount          : Integer;
               end;



type
  TWC3_Header = record
                  RecordedGame              : Array[0..27] of AnsiChar;
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
                        VersionString : Array[0..3] of AnsiChar;
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

const
  W3G_BLOCK_FIRST_STARTBLOCK      = $1A;
  W3G_BLOCK_SECOND_STARTBLOCK     = $1B;
  W3G_BLOCK_THIRD_STARTBLOCK      = $1C;
  W3G_BLOCK_LEAVEGAME             = $17;
  W3G_BLOCK_PLAYERCHAT            = $20;
  W3G_BLOCK_TIMESLOT1             = $1E;
  W3G_BLOCK_TIMESLOT2             = $1F;
  W3G_BLOCK_TIMESLOT_SEED         = $22;
  W3G_BLOCK_LEAVEGAME_PREFIX      = $23;
  W3G_BLOCK_FORCED_GAMEEND        = $2F;

  W3G_ACTION_PAUSEGAME            = $01;
  W3G_ACTION_RESUMEGAME           = $02;
  W3G_ACTION_SETGAMESPEED         = $03;
  W3G_ACTION_INCREASEGAMESPEED    = $04;
  W3G_ACTION_DECREASEGAMESPEED    = $05;
  W3G_ACTION_SAVEGAME             = $06;
  W3G_ACTION_SAVEGAMEFINISHED     = $07;
  W3G_ACTION_ABILITY              = $10;
  W3G_ACTION_ABILITY_TARPOS       = $11;
  W3G_ACTION_ABILITY_TARPOSID     = $12;
  W3G_ACTION_GIVEDROPITEM         = $13;
  W3G_ACTION_ABILITY_TWOTARPOSID  = $14;
  W3G_ACTION_CHANGESELECTION      = $16;
  W3G_ACTION_ASSIGNHOTKEY         = $17;
  W3G_ACTION_SELECTHOTKEY         = $18;
  W3G_ACTION_SELECTSUBGROUP       = $19;
  W3G_ACTION_PRESUBSELECTION      = $1A;
  W3G_ACTION_UNKNOWN1             = $1B;
  W3G_ACTION_SELECTGROUNDITEM     = $1C;
  W3G_ACTION_CANCELHEROREVIVAL    = $1D;
  W3G_ACTION_REMOVEUNITFROMQUEUE  = $1E;
  W3G_ACTION_UNKNOWN2             = $21;
  W3G_ACTION_CHEATS               = [$20, $22..$32];
  W3G_ACTION_CHANGEALLYOPTIONS    = $50;
  W3G_ACTION_TRANSFERRESOURCES    = $51;
  W3G_ACTION_MAPTRIGGERCHATCMD    = $60;
  W3G_ACTION_ESCPRESSED           = $61;
  W3G_ACTION_SCENARIOTRIGGER      = $62;
  W3G_ACTION_MENU_CHOOSEHEROSKILL = $66;
  W3G_ACTION_MENU_CHOOSEBUILDING  = $67;
  W3G_ACTION_MINIMAPSIGNAL        = $68;
  W3G_ACTION_CONTINUEGAME_B       = $69;
  W3G_ACTION_CONTINUEGAME_A       = $6A;
  W3G_ACTION_SYNCSTOREDINTEGER    = $6B;
  W3G_ACTION_UNKNOWN3             = $70;
  W3G_ACTION_UNKNOWN4             = $75;

  W3G_ACTION_CHANGESELECTION_ADD  = $1001;
  W3G_ACTION_CHANGESELECTION_REM  = $1002;
  W3G_ACTION_CHEAT                = $1003;

function CheckAndModifyValue(const AValue : Integer; var ANewValue : Integer) : Boolean;
function ConvertValueToWC3String(const AValue : DWORD) : String;

implementation

uses
  SysUtils, StrUtils;

function CheckAndModifyValue(const AValue : Integer; var ANewValue : Integer) : Boolean;
begin
  If AValue in [1..5, 7..11] Then
  Begin
    ANewValue := AValue;
    If ANewValue in [7..11] Then
      Dec(ANewValue);
    result := TRUE;
  End
  else
    result := FALSE;
end;

function ConvertValueToWC3String(const AValue : DWORD) : String;
var
  tmpString : AnsiString;
begin
  SetLength(tmpString, SizeOf(DWORD));
  Move(AValue, tmpString[1], SizeOf(DWORD));
  result := UpperCase(ReverseString(String(tmpString)));
end;

end.
