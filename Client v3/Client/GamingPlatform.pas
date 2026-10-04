unit GamingPlatform;

interface

type
  TGamingPlatformItem = (gpUnknown, gpGarena, gpBNet, gpICCup, gpDotalicious, gpRGC);

  TGamingPlatform = class
                    private
                      type
                        TPlatformValue = record
                                           Platform_ : TGamingPlatformItem;
                                           Hostmask  : String;
                                           Value     : Integer;
                                         end;
                        TPlatformValues = Array[1..2] of TPlatformValue;
                      var
                        FPlatform       : TGamingPlatformItem;
                        FPlatformValues : TPlatformValues;
                    public
                      constructor Create;
                      destructor Destroy; override;

                      procedure Reset;
                      procedure Feed(const AHostname : String);

                      property CurrentPlatform : TGamingPlatformItem read FPlatform;
                    end;

implementation

uses
  SharedFunctions, SysUtils;

constructor TGamingPlatform.Create;
begin
  Reset;
end;

destructor TGamingPlatform.Destroy;
begin

  inherited;
end;

procedure TGamingPlatform.Reset;
begin
  FPlatformValues[1].Platform_ := gpBNet;
  FPlatformValues[1].Hostmask := '*.battle.net';
  FPlatformValues[1].Value := 0;

  FPlatformValues[2].Platform_ := gpICCup;
  FPlatformValues[2].Hostmask := 'wc3.theabyss.ru';
  FPlatformValues[2].Value := 0;
end;

procedure TGamingPlatform.Feed(const AHostname: String);
var
  C1       : Integer;
  maxindex : Integer;
begin
  For C1 := Low(FPlatformValues) to High(FPlatformValues) Do
    If MatchStrings(AHostname, FPlatformValues[C1].Hostmask, FALSE) Then
      Inc(FPlatformValues[C1].Value);

  maxindex := 1;
  For C1 := Low(FPlatformValues) to High(FPlatformValues) Do
    If FPlatformValues[C1].Value > FPlatformValues[maxindex].Value Then
      maxindex := C1;

  If FPlatformValues[maxindex].Value > 0 Then
    FPlatform := FPlatformValues[maxindex].Platform_
  else
  Begin
    FPlatform := gpUnknown;

    If LowerCase(GetProcessName(GetParentProcess(GetProcessID('war3.exe')))) = 'garena_room.exe' Then
      FPlatform := gpGarena;

    If LowerCase(GetProcessName(GetParentProcess(GetProcessID('war3.exe')))) = 'garena.exe' Then
      FPlatform := gpGarena;

    If LowerCase(GetProcessName(GetParentProcess(GetProcessID('war3.exe')))) = 'launcher.exe' Then
      FPlatform := gpICCup;

    If LowerCase(GetProcessName(GetParentProcess(GetProcessID('client.exe')))) = 'wrapper.exe' Then
      FPlatform := gpDotalicious;

    If LowerCase(GetProcessName(GetParentProcess(GetProcessID('war3.exe')))) = 'rgc.exe' Then
      FPlatform := gpRGC;
  End;
end;

end.
