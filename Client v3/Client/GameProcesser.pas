unit GameProcesser;

interface

uses
  Classes;

type
  TNewReplayEvent         = procedure(const AReplayFile : String) of object;
  TTempReplayCreatedEvent = procedure(const ATempReplay : String) of object;
  TTempReplayDeletedEvent = procedure(const ATempReplay : String) of object;

  TGameProcesser = class(TThread)
                   private
                     FReplayFile       : String;
                     FTempReplay       : String;
                     FReplayHash       : String;
                     FTempReplayExists : Boolean;
                     FCheckHash        : Boolean;

                     FOnNewReplay         : TNewReplayEvent;
                     FOnTempReplayCreated : TTempReplayCreatedEvent;
                     FOnTempReplayDeleted : TTempReplayDeletedEvent;

                     procedure syncOnNewReplay;
                     procedure syncOnTempReplayCreated;
                     procedure syncOnTempReplayDeleted;

                     procedure SetCheckHash(const AValue : Boolean);
                   protected
                     procedure Execute; override;
                   public
                     property ReplayFile  : String read FReplayFile write FReplayFile;
                     property TempReplay  : String read FTempReplay write FTempReplay;
                     property CheckHash   : Boolean read FCheckHash write SetCheckHash;

                     property OnNewReplay         : TNewReplayEvent read FOnNewReplay write FOnNewReplay;
                     property OnTempReplayCreated : TTempReplayCreatedEvent read FOnTempReplayCreated write FOnTempReplayCreated;
                     property OnTempReplayDeleted : TTempReplayDeletedEvent read FOnTempReplayDeleted write FOnTempReplayDeleted;
                   end;

implementation

uses
  SysUtils, SharedFunctions;


procedure TGameProcesser.Execute;
var
  newHash : String;
begin
  FReplayHash := LowerCase(MD5File(FReplayFile));
  FTempReplayExists := FileExists(FTempReplay);

  while not Terminated do
  begin
    if FCheckHash then
    begin
      newHash := LowerCase(MD5File(FReplayFile));
      if newHash <> FReplayHash then
      begin
        if Assigned(FOnNewReplay) then
          Synchronize(syncOnNewReplay);

        FReplayHash := newHash;
      end;
    end;

    if not FTempReplayExists then
    begin
      if FileExists(FTempReplay) then
      begin
        FTempReplayExists := TRUE;
        if Assigned(FOnTempReplayCreated) then
          Synchronize(syncOnTempReplayCreated);
      end;
    end
    else
    begin
      if not FileExists(FTempReplay) then
      begin
        FTempReplayExists := FALSE;
        if Assigned(FOnTempReplayDeleted) then
          Synchronize(syncOnTempReplayDeleted);
      end;
    end;

    Sleep(500);
  end;
end;

procedure TGameProcesser.syncOnNewReplay;
begin
  FOnNewReplay(FReplayFile);
end;

procedure TGameProcesser.syncOnTempReplayCreated;
begin
  FOnTempReplayCreated(FTempReplay);
end;

procedure TGameProcesser.syncOnTempReplayDeleted;
begin
  FOnTempReplayDeleted(FTempReplay);
end;

procedure TGameProcesser.SetCheckHash(const AValue : Boolean);
begin
  if (AValue) and
     (not FCheckHash) then
    FReplayHash := LowerCase(MD5File(FReplayFile));

  FCheckHash := AValue;
end;



end.
