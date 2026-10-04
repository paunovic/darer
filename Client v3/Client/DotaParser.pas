unit DotaParser;

interface

uses
  Windows, Classes, DotaParser_Types, Socktypes;

type
  TModeChoosedEvent = procedure(const AMode : String) of object;
  TGameEndedEvent   = procedure of object;

  TDotaParser = class
                private
                  FGameData      : TDotaGame_Data;
                  FOnModeChoosed : TModeChoosedEvent;
                  FOnGameEnded   : TGameEndedEvent;
                public
                  constructor Create;
                  destructor Destroy; override;

                  procedure FlushGame;
                  function Parse(const AStream : TMemoryStream; const AHeader : THdrIP) : Boolean;
                  function IsDataValid : Integer;

                  function ParseGlobalString(const AKey : String; const AValue : DWORD) : Boolean;
                  function ParseDataString(const AKey : String; const AValue : DWORD) : Boolean;
                  function ParseEndGameString(const APlayer : Integer; const AKey : String; const AValue : DWORD) : Boolean;

                  property GameData : TDotaGame_Data read FGameData;

                  property OnModeChoosed : TModeChoosedEvent read FOnModeChoosed write FOnModeChoosed;
                  property OnGameEnded   : TGameEndedEvent read FOnGameEnded write FOnGameEnded;
                end;

implementation

uses
  WinSock2, SysUtils, SharedFunctions, MainWin, DotaGame_Validator, W3GParser_Types;

constructor TDotaParser.Create;
begin
  FlushGame;
end;

destructor TDotaParser.Destroy;
begin
  inherited;
end;

function TDotaParser.ParseDataString(const AKey : String; const AValue : DWORD) : Boolean;
var
  tmpRaxAlliance,
  tmpRaxSide,
  tmpRaxType,
  tmpTowerAlliance,
  tmpTowerSide,
  tmpTowerLevel     : Integer;
  tmpVal            : Integer;
  tmpString         : String;
  tmpInt            : Integer;
  C1                : Integer;
begin
  result := FALSE;

  If (Pos('Mode', AKey) = 1) and // Mode choosed
     (Length(AKey) >= 5) Then
  Begin
    FGameData.Times.ModeChoosed := GetTickCount;
    FGameData.Mode := AKey;
    Delete(FGameData.Mode, 1, 4);

    If Assigned(FOnModeChoosed) Then
      FOnModeChoosed(FGameData.Mode);

    result := TRUE;
  End;

  If AKey = 'GameStart' Then // First creep wave is spawned
  Begin
    FGameData.Times.FirstCreepWaveSpawned := GetTickCount;

    result := TRUE;
  End;

  If Pos('Courier', AKey) = 1 Then // Courier kill
  Begin
    If CheckAndModifyValue(AValue, tmpVal) Then
      Inc(FGameData.PlayersLive[tmpVal].CourierKills);

    result := TRUE;
  End;

  If (Pos('Hero', AKey) = 1) and // Hero kill
     (Length(AKey) >= 5) Then
  Begin
    tmpString := AKey;
    Delete(tmpString, 1, 4);

    If (TryStrToInt(tmpString, tmpInt)) and
       (CheckAndModifyValue(tmpInt, tmpVal)) Then
    Begin
      tmpInt := tmpVal;
      If CheckAndModifyValue(AValue, tmpVal) Then
      Begin
        If FGameData.Times.FirstBlood = 0 Then
          FGameData.Times.FirstBlood := GetTickCount;

        Inc(FGameData.PlayersLive[tmpVal].Kills);
      End;

      Inc(FGameData.PlayersLive[tmpInt].Deaths);
      result := TRUE;
    End;
  End;

  If (Pos('Assist', AKey) = 1) and // Hero kill assist
     (Length(AKey) >= 7) Then
  Begin
    tmpString := AKey;
    Delete(tmpString, 1, 6);

    If (TryStrToInt(tmpString, tmpInt)) and
       (CheckAndModifyValue(tmpInt, tmpVal)) Then
    Begin
      tmpInt := tmpVal;
      If CheckAndModifyValue(AValue, tmpVal) Then
        Inc(FGameData.PlayersLive[tmpInt].Assists);
      result := TRUE;
    End;
  End;

  If (Pos('Tower', AKey) = 1) and // Tower kill
     (Length(AKey) >= 8) Then
  Begin
    If ((AValue = 0) or
        (CheckAndModifyValue(AValue, tmpVal))) and
       (TryStrToInt(AKey[6], tmpTowerAlliance)) and
       (TryStrToInt(AKey[7], tmpTowerLevel)) and
       (TryStrToInt(AKey[8], tmpTowerSide)) Then
    Begin
      Case tmpTowerAlliance of
        0 : Begin
              Case tmpTowerSide of
                0 : Case tmpTowerLevel of
                      1 : FGameData.Times.Sentinel.Towers.Top.First := GetTickCount;
                      2 : FGameData.Times.Sentinel.Towers.Top.Second := GetTickCount;
                      3 : FGameData.Times.Sentinel.Towers.Top.Third := GetTickCount;
                    End;
                1 : Case tmpTowerLevel of
                      1 : FGameData.Times.Sentinel.Towers.Mid.First := GetTickCount;
                      2 : FGameData.Times.Sentinel.Towers.Mid.Second := GetTickCount;
                      3 : FGameData.Times.Sentinel.Towers.Mid.Third := GetTickCount;
                      4 : If FGameData.Times.Sentinel.Towers.Base1 = 0 Then
                            FGameData.Times.Sentinel.Towers.Base1 := GetTickCount
                          else
                            If FGameData.Times.Sentinel.Towers.Base2 = 0 Then
                              FGameData.Times.Sentinel.Towers.Base2 := GetTickCount
                    End;
                2 : Case tmpTowerLevel of
                      1 : FGameData.Times.Sentinel.Towers.Bot.First := GetTickCount;
                      2 : FGameData.Times.Sentinel.Towers.Bot.Second := GetTickCount;
                      3 : FGameData.Times.Sentinel.Towers.Bot.Third := GetTickCount;
                    End;
              End;

              If tmpVal in [1..5] Then
                Inc(FGameData.PlayersLive[tmpVal].TowerDenies)
              else
                Inc(FGameData.PlayersLive[tmpVal].TowerKills);
                
              result := TRUE;
            End;
        1 : Begin
              Case tmpTowerSide of
                0 : Case tmpTowerLevel of
                      1 : FGameData.Times.Scourge.Towers.Top.First := GetTickCount;
                      2 : FGameData.Times.Scourge.Towers.Top.Second := GetTickCount;
                      3 : FGameData.Times.Scourge.Towers.Top.Third := GetTickCount;
                    End;
                1 : Case tmpTowerLevel of
                      1 : FGameData.Times.Scourge.Towers.Mid.First := GetTickCount;
                      2 : FGameData.Times.Scourge.Towers.Mid.Second := GetTickCount;
                      3 : FGameData.Times.Scourge.Towers.Mid.Third := GetTickCount;
                      4 : If FGameData.Times.Scourge.Towers.Base1 = 0 Then
                            FGameData.Times.Scourge.Towers.Base1 := GetTickCount
                          else
                            If FGameData.Times.Scourge.Towers.Base2 = 0 Then
                              FGameData.Times.Scourge.Towers.Base2 := GetTickCount
                    End;
                2 : Case tmpTowerLevel of
                      1 : FGameData.Times.Scourge.Towers.Bot.First := GetTickCount;
                      2 : FGameData.Times.Scourge.Towers.Bot.Second := GetTickCount;
                      3 : FGameData.Times.Scourge.Towers.Bot.Third := GetTickCount;
                    End;
              End;

              If AValue <> 0 Then
                If tmpVal in [6..10] Then
                  Inc(FGameData.PlayersLive[tmpVal].TowerDenies)
                else
                  Inc(FGameData.PlayersLive[tmpVal].TowerKills);

              result := TRUE;
            End;
      End;
    End;
  End;

  If (Pos('Rax', AKey) = 1) and // Rax kill
     (Length(AKey) >= 6) Then
  Begin
    If ((AValue = 0) or
        (CheckAndModifyValue(AValue, tmpVal))) and
       (TryStrToInt(AKey[4], tmpRaxAlliance)) and
       (TryStrToInt(AKey[5], tmpRaxSide)) and
       (TryStrToInt(AKey[6], tmpRaxType)) Then
    Begin
      Case tmpRaxAlliance of
        0 : Begin
              Case tmpRaxSide of
                0 : Case tmpRaxType of
                      0 : FGameData.Times.Sentinel.Raxes.Top.Melee := GetTickCount;
                      1 : FGameData.Times.Sentinel.Raxes.Top.Ranged := GetTickCount;
                    End;
                1 : Case tmpRaxType of
                      0 : FGameData.Times.Sentinel.Raxes.Mid.Melee := GetTickCount;
                      1 : FGameData.Times.Sentinel.Raxes.Mid.Ranged := GetTickCount;
                    End;
                2 : Case tmpRaxType of
                      0 : FGameData.Times.Sentinel.Raxes.Bot.Melee := GetTickCount;
                      1 : FGameData.Times.Sentinel.Raxes.Bot.Ranged := GetTickCount;
                    End;
              End;

              If tmpVal in [1..5] Then
                Inc(FGameData.PlayersLive[tmpVal].RaxDenies)
              else
                Inc(FGameData.PlayersLive[tmpVal].RaxKills);

              result := TRUE;
            End;
        1 : Begin
              Case tmpRaxSide of
                0 : Case tmpRaxType of
                      0 : FGameData.Times.Scourge.Raxes.Top.Melee := GetTickCount;
                      1 : FGameData.Times.Scourge.Raxes.Top.Ranged := GetTickCount;
                    End;
                1 : Case tmpRaxType of
                      0 : FGameData.Times.Scourge.Raxes.Mid.Melee := GetTickCount;
                      1 : FGameData.Times.Scourge.Raxes.Mid.Ranged := GetTickCount;
                    End;
                2 : Case tmpRaxType of
                      0 : FGameData.Times.Scourge.Raxes.Bot.Melee := GetTickCount;
                      1 : FGameData.Times.Scourge.Raxes.Bot.Ranged := GetTickCount;
                    End;
              End;

              If AValue <> 0 Then
                If tmpVal in [6..10] Then
                  Inc(FGameData.PlayersLive[tmpVal].RaxDenies)
                else
                  Inc(FGameData.PlayersLive[tmpVal].RaxKills);

              result := TRUE;
            End;
      End;
    End;
  End;

  If (Pos('Throne', AKey) = 1) and // Throne damaged - scourge
     (Length(AKey) >= 6) Then
  Begin
    Inc(FGameData.Times.Scourge.Throne.Count);
    SetLength(FGameData.Times.Scourge.Throne.Percents, FGameData.Times.Scourge.Throne.Count);
    With FGameData.Times.Scourge.Throne.Percents[FGameData.Times.Scourge.Throne.Count - 1] Do
    Begin
      Time := GetTickCount;
      Percent := AValue;
    End;

    result := TRUE;
  End;

  If (Pos('Tree', AKey) = 1) and // Tree damaged - sentinel
     (Length(AKey) >= 4) Then
  Begin
    Inc(FGameData.Times.Sentinel.Throne.Count);
    SetLength(FGameData.Times.Sentinel.Throne.Percents, FGameData.Times.Sentinel.Throne.Count);
    With FGameData.Times.Sentinel.Throne.Percents[FGameData.Times.Sentinel.Throne.Count - 1] Do
    Begin
      Time := GetTickCount;
      Percent := AValue;
    End;

    result := TRUE;
  End;

  If (Pos('CK', AKey) = 1) and // Player disconnected
     (Length(AKey) >= 2) and
     (CheckAndModifyValue(AValue, tmpVal)) Then
  Begin
    tmpString := AKey;
    Delete(tmpString, 1, 2);
    If MatchStrings('K*D*N*', tmpString, FALSE) Then
    Begin
      Delete(tmpString, 1, 1);
      FGameData.PlayersLive[tmpVal].CreepKills := StrToIntDef(Copy(tmpString, 1, Pos('D', tmpString) - 1), 0);
      Delete(tmpString, 1, Pos('D', tmpString));
      FGameData.PlayersLive[tmpVal].CreepDenies := StrToIntDef(Copy(tmpString, 1, Pos('N', tmpString) - 1), 0);
      Delete(tmpString, 1, Pos('N', tmpString));
      FGameData.PlayersLive[tmpVal].CreepNeutrals := StrToIntDef(tmpString, 0);

      FGameData.PlayersLive[tmpVal].Disconnected := GetTickCount;
      result := TRUE;
    End;
  End;

  If (Pos('Level', AKey) = 1) and // Player got level
     (Length(AKey) >= 5) Then
  Begin
    tmpString := AKey;
    Delete(tmpString, 1, 5);

    If (TryStrToInt(tmpString, tmpInt)) and
       (CheckAndModifyValue(AValue, tmpVal)) Then
    Begin
      FGameData.PlayersLive[tmpVal].Level := tmpInt;

      result := TRUE;
    End;
  End;

  If (Pos('PUI_', AKey) = 1) and // Player picks up an item
     (Length(AKey) >= 5) Then
  Begin
    tmpString := AKey;
    Delete(tmpString, 1, 4);

    If (TryStrToInt(tmpString, tmpInt)) and
       (CheckAndModifyValue(tmpInt, tmpVal)) Then
    Begin
      For C1 := 1 to 6 Do
        If FGameData.PlayersLive[tmpVal].ItemCodes[C1] = '' Then
        Begin
          FGameData.PlayersLive[tmpVal].ItemCodes[C1] := ConvertValueToWC3String(AValue);
          If Length(FGameData.PlayersLive[tmpVal].ItemCodes[C1]) <> 4 Then
            FGameData.PlayersLive[tmpVal].ItemCodes[C1] := '';
          Break;
        End;
      result := TRUE;
    End;
  End;

  If (Pos('DRI_', AKey) = 1) and // Player drops an item
     (Length(AKey) >= 5) Then
  Begin
    tmpString := AKey;
    Delete(tmpString, 1, 4);

    If (TryStrToInt(tmpString, tmpInt)) and
       (CheckAndModifyValue(tmpInt, tmpVal)) Then
    Begin
      tmpString := ConvertValueToWC3String(AValue);
      If Length(tmpString) = 4 Then
      Begin
        For C1 := 1 to 6 Do
          If FGameData.PlayersLive[tmpVal].ItemCodes[C1] = tmpString Then
          Begin
            FGameData.PlayersLive[tmpVal].ItemCodes[C1] := '';
            Break;
          End;
        result := TRUE;
      End;
    End;
  End;

  If (Pos('CSK', AKey) = 1) and // Creep kills
     (Length(AKey) >= 4) Then
  Begin
    tmpString := AKey;
    Delete(tmpString, 1, 3);

    If (TryStrToInt(tmpString, tmpInt)) and
       (CheckAndModifyValue(tmpInt, tmpVal)) Then
    Begin
      FGameData.PlayersLive[tmpVal].CreepKills := AValue;
      result := TRUE;
    End;
  End;

  If (Pos('CSD', AKey) = 1) and // Creep denies
     (Length(AKey) >= 4) Then
  Begin
    tmpString := AKey;
    Delete(tmpString, 1, 3);

    If (TryStrToInt(tmpString, tmpInt)) and
       (CheckAndModifyValue(tmpInt, tmpVal)) Then
    Begin
      FGameData.PlayersLive[tmpVal].CreepDenies := AValue;
      result := TRUE;
    End;
  End;

  If (Pos('NK', AKey) = 1) and // Neutral kills
     (Length(AKey) >= 3) Then
  Begin
    tmpString := AKey;
    Delete(tmpString, 1, 2);

    If (TryStrToInt(tmpString, tmpInt)) and
       (CheckAndModifyValue(tmpInt, tmpVal)) Then
    Begin
      FGameData.PlayersLive[tmpVal].CreepNeutrals := AValue;
      result := TRUE;
    End;
  End;

  If (Pos('RuneStore', AKey) = 1) and // Rune stored
     (Length(AKey) >= 10) Then
  Begin
    tmpString := AKey;
    Delete(tmpString, 1, 9);

    If (TryStrToInt(tmpString, tmpInt)) and
       (tmpInt in [1..5]) and
       (CheckAndModifyValue(AValue, tmpVal)) Then
    Begin
      Case tmpInt of
        1 : Inc(FGameData.PlayersLive[tmpVal].RunesStored.DoubleDamage);
        2 : Inc(FGameData.PlayersLive[tmpVal].RunesStored.Invisibility);
        3 : Inc(FGameData.PlayersLive[tmpVal].RunesStored.Illusions);
        4 : Inc(FGameData.PlayersLive[tmpVal].RunesStored.Haste);
        5 : Inc(FGameData.PlayersLive[tmpVal].RunesStored.Regeneration);
      End;
      result := TRUE;
    End;
  End;

  If (Pos('RuneUse', AKey) = 1) and // Rune used
     (Length(AKey) >= 8) Then
  Begin
    tmpString := AKey;
    Delete(tmpString, 1, 7);

    If (TryStrToInt(tmpString, tmpInt)) and
       (tmpInt in [1..5]) and
       (CheckAndModifyValue(AValue, tmpVal)) Then
    Begin
      Case tmpInt of
        1 : Inc(FGameData.PlayersLive[tmpVal].RunesUsed.DoubleDamage);
        2 : Inc(FGameData.PlayersLive[tmpVal].RunesUsed.Invisibility);
        3 : Inc(FGameData.PlayersLive[tmpVal].RunesUsed.Illusions);
        4 : Inc(FGameData.PlayersLive[tmpVal].RunesUsed.Haste);
        5 : Inc(FGameData.PlayersLive[tmpVal].RunesUsed.Regeneration);
      End;
      result := TRUE;
    End;
  End;
end;

function TDotaParser.ParseGlobalString(const AKey : String; const AValue : DWORD) : Boolean;
begin
  result := FALSE;

  If AKey = 'Winner' Then
  Begin
    Case AValue of
      1 : FGameData.Winner := dwSentinel;
      2 : FGameData.Winner := dwScourge;
    else
      FGameData.Winner := dwUnknown;
    End;
    result := TRUE;
  End;

  If AKey = 'm' Then // length - minutes
  Begin
    FGameData.Times.GameDurationMinutes := AValue;
    result := TRUE;
  End;

  If AKey = 's' Then // length - seconds
  Begin
    FGameData.Times.GameDurationSeconds := AValue;
    result := TRUE;
  End;
end;

function TDotaParser.ParseEndGameString(const APlayer : Integer; const AKey : String; const AValue : DWORD) : Boolean;
var
  valInt : Integer;
begin
  result := FALSE;

  If TryStrToInt(AKey, valInt) Then
  Begin
    Case valInt of
      1 : Begin
            If APlayer = 1 Then // this is the first string that is send at the end of the game
              FGameData.Times.GameEndFirstString := GetTickCount;
              
            FGameData.PlayersEnd[APlayer].Kills := AValue;
            result := TRUE;
          End;
      2 : Begin
            FGameData.PlayersEnd[APlayer].Deaths := AValue;
            result := TRUE;
          End;
      3 : Begin
            FGameData.PlayersEnd[APlayer].CreepKills := AValue;
            result := TRUE;
          End;
      4 : Begin
            FGameData.PlayersEnd[APlayer].CreepDenies := AValue;
            result := TRUE;
          End;
      5 : Begin
            FGameData.PlayersEnd[APlayer].Assists := AValue;
            result := TRUE;
          End;
      6 : Begin
            FGameData.PlayersEnd[APlayer].Gold := AValue;
            result := TRUE;
          End;
      7 : Begin
            FGameData.PlayersEnd[APlayer].CreepNeutrals := AValue;
            result := TRUE;
          End;
      9 : Begin
            FGameData.PlayersLive[APlayer].HeroCode := ConvertValueToWC3String(AValue);
            FGameData.PlayersEnd[APlayer].HeroCode := ConvertValueToWC3String(AValue);
            result := TRUE;
          End;
    End
  End
  else
  Begin
    If (MatchStrings(AKey, '8_?', FALSE)) and
       (TryStrToInt(AKey[3], valInt)) and
       (valInt in [0..5]) Then
    Begin
      FGameData.PlayersEnd[APlayer].ItemCodes[valInt + 1] := ConvertValueToWC3String(AValue);
      If Length(FGameData.PlayersLive[APlayer].ItemCodes[valInt + 1]) <> 4 Then
        FGameData.PlayersLive[APlayer].ItemCodes[valInt + 1] := ''
      else
        result := TRUE;
    End;

    If AKey = 'id' Then
    Begin
      result := TRUE;
    End;
  End;
end;

function TDotaParser.Parse(const AStream : TMemoryStream; const AHeader : THdrIP) : Boolean;
var
  firstString  : String;
  secondString : String;
  value        : DWORD;
  valueInt     : Integer;
  C1           : Integer;
begin
  result := FALSE;
  While AStream.Position < AStream.Size - 7 Do
    If (ReadByte(AStream, FALSE) = $6B) and
       (ReadByte(AStream, FALSE) = Ord('d')) and
       (ReadByte(AStream, FALSE) = Ord('r')) and
       (ReadByte(AStream, FALSE) = Ord('.')) and
       (ReadByte(AStream, FALSE) = Ord('x')) and
       (ReadByte(AStream, FALSE) = $00) Then
    Begin
      firstString := String(ReadNullTerminatedString(AStream));

      If (firstString = 'Data') or // first null terminated string can be Data, Global or player ID
         (firstString = 'Global') or
         (StrToIntDef(firstString, -1) >= 0) Then
      Begin
        secondString := String(ReadNullTerminatedString(AStream));

        value := ReadDWORD(AStream, FALSE);

        DbgLn(Format('DOTA :: Parsing string [%s, %s, %d]', [firstString, secondString, value]));

        If firstString = 'Data' Then
          result := ParseDataString(secondString, value);

        If firstString = 'Global' Then
          result := ParseGlobalString(secondString, value);

        If CheckAndModifyValue(StrToIntDef(firstString, -1), valueInt) Then
        Begin
          DbgLn(Format('DOTA :: Parsing end game string [%s, %s, %d]', [firstString, secondString, valueInt]));
          result := ParseEndGameString(valueInt, secondString, value);
        End;
      End;
    End;

  If (FGameData.Times.GameEndFirstString > 0) and
     (GetTickCount - FGameData.Times.GameEndFirstString > 3000) Then // wait 5 seconds after first endgame string is received
  Begin
    DbgLn('DOTA :: Game Ended!');
    For C1 := 1 to 10 Do
    Begin
      FGameData.PlayersEnd[C1].Level := FGameData.PlayersLive[C1].Level;
      FGameData.PlayersEnd[C1].TowerKills := FGameData.PlayersLive[C1].TowerKills;
      FGameData.PlayersEnd[C1].TowerDenies := FGameData.PlayersLive[C1].TowerDenies;
      FGameData.PlayersEnd[C1].RaxKills := FGameData.PlayersLive[C1].RaxKills;
      FGameData.PlayersEnd[C1].RaxDenies := FGameData.PlayersLive[C1].RaxDenies;
    End;
    FGameData.Times.GameEnd := GetTickCount; // set the game status as ended

    if Assigned(FOnGameEnded) then
      FOnGameEnded;
  End;
end;

procedure TDotaParser.FlushGame;
begin
  ZeroMemory(@FGameData, SizeOf(TDotaGame_Data));
end;

function TDotaParser.IsDataValid : Integer;
begin
  result := IsDotaGameValid(FGameData);
end;

end.

