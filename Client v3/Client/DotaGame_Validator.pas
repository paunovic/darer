unit DotaGame_Validator;

interface

uses
  Windows, DotaParser_Types;

const
// times are in milliseconds!
  MIN_MODE_CHOOSE_GAME_END_DURATION    = 10 * 60 * 1000;
  MIN_MODE_CHOOSE_CREEP_SPAWN_DURATION = 80 * 1000;
  MIN_T1_TO_T2_TO_T3_TOWER_DURATION    = 7 * 1000;
  MIN_T3_TOWER_TO_BASE_TOWER_DURATION  = 10 * 1000;
  MIN_BASE_TOWER_TO_THRONE_DURATION    = 1 * 1000;

function IsDotaGameValid(const ADotaGameData : TDotaGame_Data) : Integer;

implementation

uses
  SharedFunctions, MainWin, SysUtils;

function CheckSideTowerTimes(const ATowers : TDotaGame_SideTowers; const ABaseTower1, ABaseTower2, AThrone : DWORD) : Boolean;
begin
//  MainWindow.memo.Lines.Add(Format('TIMES : TOWERS : %d, %d, %d : BASE : %d, %d : THRONE : %d', [ATowers.First, ATowers.Second, ATowers.Third, ABaseTower1, ABaseTower2, AThrone]));

  result := (CompareTimesAscending([ATowers.First, ATowers.Second, ATowers.Third], MIN_T1_TO_T2_TO_T3_TOWER_DURATION)) and
            (CompareTimesAscending([ATowers.Third, ABaseTower1], MIN_T3_TOWER_TO_BASE_TOWER_DURATION)) and
            (CompareTimesAscending([ATowers.Third, ABaseTower2], MIN_T3_TOWER_TO_BASE_TOWER_DURATION)) and
            (CompareTimesAscending([ABaseTower1, AThrone], MIN_BASE_TOWER_TO_THRONE_DURATION)) and
            (CompareTimesAscending([ABaseTower2, AThrone], MIN_BASE_TOWER_TO_THRONE_DURATION));
end;

function CheckBuildingTimes(const ABuildings : TDotaGame_AllianceTimes) : Boolean;
begin
  result := (ABuildings.Throne.Count > 0) and
            ((CheckSideTowerTimes(ABuildings.Towers.Top, ABuildings.Towers.Base1, ABuildings.Towers.Base2, ABuildings.Throne.Percents[0].Time)) or
             (CheckSideTowerTimes(ABuildings.Towers.Mid, ABuildings.Towers.Base1, ABuildings.Towers.Base2, ABuildings.Throne.Percents[0].Time)) or
             (CheckSideTowerTimes(ABuildings.Towers.Bot, ABuildings.Towers.Base1, ABuildings.Towers.Base2, ABuildings.Throne.Percents[0].Time)));
end;

function CheckThronePercents(const AThronePercents : TDotaGame_ThronePercents) : Boolean;
var
  C1 : Integer;
begin
  result := TRUE;
  For C1 := Low(AThronePercents.Percents) to High(AThronePercents.Percents) - 1 Do
    If AThronePercents.Percents[C1].Time > AThronePercents.Percents[C1 + 1].Time Then
    Begin
      result := FALSE;
      Break;
    End;
end;

function IsDotaGameValid(const ADotaGameData : TDotaGame_Data) : Integer;
begin
//  MainWindow.memo.Lines.Add(Format('TIMES : MODECHOOSED : %d : GAMEEND : %d : FIRSTCREEP : %d', [ADotaGameData.Times.ModeChoosed, ADotaGameData.Times.GameEnd, ADotaGameData.Times.FirstCreepWaveSpawned]));

  result := 10;

  If CompareTimesAscending([ADotaGameData.Times.ModeChoosed, ADotaGameData.Times.GameEnd], MIN_MODE_CHOOSE_GAME_END_DURATION) Then // check game duration
  Begin
    result := 9;
    If CompareTimesAscending([ADotaGameData.Times.ModeChoosed, ADotaGameData.Times.FirstCreepWaveSpawned], MIN_MODE_CHOOSE_CREEP_SPAWN_DURATION) Then // check duration between mode choose and first creep spawn (should be 1min 30secs)
    Begin
      result := 8;

      If ADotaGameData.Winner = dwSentinel Then
      Begin
        result := 7;
        If CheckBuildingTimes(ADotaGameData.Times.Scourge) Then
        Begin
          result := 6;
          If CheckThronePercents(ADotaGameData.Times.Scourge.Throne) Then
          Begin
            result := 0;
          End;
        End;
      End;

      If ADotaGameData.Winner = dwScourge Then
      Begin
        result := 5;
        If CheckBuildingTimes(ADotaGameData.Times.Sentinel) Then
        Begin
          result := 4;
          If CheckThronePercents(ADotaGameData.Times.Sentinel.Throne) Then
          Begin
            result := 0;
          End;
        End;
      End;



{
      If ((ADotaGameData.Winner = dwSentinel) and // check the looser side field towers, base towers and throne/tree times
          (CheckBuildingTimes(ADotaGameData.Times.Scourge)) and
          (CheckThronePercents(ADotaGameData.Times.Scourge.Throne))) or
         ((ADotaGameData.Winner = dwScourge) and
          (CheckBuildingTimes(ADotaGameData.Times.Sentinel)) and
          (CheckThronePercents(ADotaGameData.Times.Sentinel.Throne))) Then
      Begin
        result := 0;
      End;}
    End;
  End;
end;

end.
