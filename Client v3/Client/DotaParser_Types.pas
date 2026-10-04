unit DotaParser_Types;

interface

uses
  Windows;


type
  TDotaGame_Winner = (dwUnknown, dwSentinel, dwScourge);

  TDotaGame_Runes = record
                      DoubleDamage, Invisibility, Illusions, Haste, Regeneration : Integer;
                    end;

  TDotaGame_PlayerInfo = record
                           Kills         : Integer;
                           Deaths        : Integer;
                           Assists       : Integer;
                           CreepKills    : Integer;
                           CreepDenies   : Integer;
                           CreepNeutrals : Integer;
                           Gold          : Integer;
                           ItemCodes     : Array[1..6] of String;
                           RunesStored   : TDotaGame_Runes;
                           RunesUsed     : TDotaGame_Runes;
                           HeroCode      : String;
                           TowerKills    : Integer;
                           TowerDenies   : Integer;
                           RaxKills      : Integer;
                           RaxDenies     : Integer;
                           CourierKills  : Integer;
                           Level         : Integer;
                           Disconnected  : DWORD;
                         end;

  TDotaGame_SideTowers = record
                           First, Second, Third : DWORD;
                         end;

  TDotaGame_AllianceTowers = record
                               Top, Mid, Bot : TDotaGame_SideTowers;
                               Base1, Base2  : DWORD;
                             end;

  TDotaGame_SideRaxes = record
                          Melee, Ranged : DWORD;
                        end;

  TDotaGame_AllianceRaxes = record
                              Top, Mid, Bot : TDotaGame_SideRaxes;
                            end;

  TDotaGame_ThronePercent = record
                              Time    : DWORD;
                              Percent : Integer;
                            end;

  TDotaGame_ThronePercents = record
                               Count    : Integer;
                               Percents : Array of TDotaGame_ThronePercent;
                             end;

  TDotaGame_AllianceTimes = record
                              Towers : TDotaGame_AllianceTowers;
                              Raxes  : TDotaGame_AllianceRaxes;
                              Throne : TDotaGame_ThronePercents;
                            end;


  TDotaGame_Times = record
                      ModeChoosed           : DWORD;
                      FirstCreepWaveSpawned : DWORD;
                      FirstBlood            : DWORD;
                      GameEndFirstString    : DWORD;
                      GameEnd               : DWORD;
                      GameDurationMinutes   : DWORD;
                      GameDurationSeconds   : DWORD;
                      Sentinel, Scourge     : TDotaGame_AllianceTimes;
                    end;

  TDotaGame_Data = record
                     PlayersLive, PlayersEnd : Array[1..10] of TDotaGame_PlayerInfo;
                     Times                   : TDotaGame_Times;
                     Winner                  : TDotaGame_Winner;
                     Mode                    : String;
                   end;

function TranslateDotaItem(const AItemCode : String; var AItemName : String) : Boolean;
function TranslateDotaHero(const AHeroCode : String; var AHeroName : String) : Boolean;

implementation

function TranslateDotaItem(const AItemCode : String; var AItemName : String) : Boolean;
begin
  result := TRUE;
end;

function TranslateDotaHero(const AHeroCode : String; var AHeroName : String) : Boolean;
begin
  result := TRUE;
end;

end.
