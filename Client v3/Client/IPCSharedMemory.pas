unit IPCSharedMemory;

interface

uses
  Windows, Classes;

const
  IPC_STRINGS_MAX    = 100;

type
  {$M+}
  TIPCSharedMemory = class;
  {$M-}

  TIPCHeader = record
                 StringSizes : Array[0..IPC_STRINGS_MAX - 1] of Integer;
               end;

  TSignalListenerThread = class(TThread)
                          private
                            FString : String;
                            FIPC    : TIPCSharedMemory;

                            procedure Synchronization;
                          protected
                            procedure Execute; override;
                          public
                            constructor Create;
                            destructor Destroy; override;
                          end;

  TOnReceiveString = procedure(const AString : String) of object;

  {$M+}
  TIPCSharedMemory = class
                     private
                       FHMapping            : THandle;
                       FHSignal1, FHSignal2 : THandle;
                       FMapName             : String;
                       FBufferSize          : DWORD;
                       FListening           : Boolean;
                       FSignalThread        : TSignalListenerThread;

                       FOnReceiveString : TOnReceiveString;

                       function IsInitialized : Boolean;
                       function GetStringCount : Integer;
                     public
                       constructor Create;
                       destructor Destroy; override;

                       function Open(const AMapName : String; const ABufferSize : DWORD; var AAlreadyExists : Boolean) : Integer;
                       procedure Close;
                       function ClearMemory : Integer;
                       function WriteString(const AString : String) : Integer;
                       function ReadLastString : String;
                       function RemoveLastString : Integer;
                     published
                       property HMapping        : THandle read FHMapping;
                       property HSignal1        : THandle read FHSignal1;
                       property HSignal2        : THandle read FHSignal2;
                       property Initialized     : Boolean read IsInitialized;
                       property StringCount     : Integer read GetStringCount;
                       property Listening       : Boolean read FListening;
                       property SignalThread    : TSignalListenerThread read FSignalThread;
                       property OnReceiveString : TOnReceiveString read FOnReceiveString write FOnReceiveString;
                     end;
  {$M-}

implementation

uses
  SharedFunctions;

procedure TSignalListenerThread.Synchronization;
begin
  If Assigned(FIPC.OnReceiveString) Then
    FIPC.OnReceiveString(FString);
end;

procedure TSignalListenerThread.Execute;
begin
  repeat
    SetEvent(FIPC.FHSignal1);
    WaitForSingleObject(FIPC.FHSignal2, INFINITE);

    while FIPC.StringCount > 0 do
    begin
      FString := FIPC.ReadLastString;
      FIPC.RemoveLastString;
      Synchronize(Synchronization);
    end;
  until Terminated;
end;

constructor TSignalListenerThread.Create;
begin
  inherited Create(TRUE);

  FreeOnTerminate := TRUE;
end;

destructor TSignalListenerThread.Destroy;
begin
  inherited;
end;

constructor TIPCSharedMemory.Create;
begin
  FHMapping := 0;
  FSignalThread := TSignalListenerThread.Create;
  FSignalThread.FIPC := self;
end;

destructor TIPCSharedMemory.Destroy;
begin
  Close;

  If not FSignalThread.Terminated Then
    FSignalThread.Terminate;

  inherited;
end;

function TIPCSharedMemory.IsInitialized : Boolean;
begin
  result := FHMapping <> 0;
end;

function TIPCSharedMemory.Open(const AMapName : String; const ABufferSize : DWORD; var AAlreadyExists : Boolean) : Integer;
begin
  FHMapping := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0, SizeOf(TIPCHeader) + ABufferSize, PWideChar(AMapName));
  If FHMapping = 0 Then
    result := GetLastError
  else
  Begin
    AAlreadyExists := GetLastError = ERROR_ALREADY_EXISTS;
    ClearMemory;
    FHSignal1 := CreateEvent(nil, FALSE, FALSE, 'Global\DarerIPCSignal1');
    FHSignal2 := CreateEvent(nil, FALSE, FALSE, 'Global\DarerIPCSignal2');
    FMapName := AMapName;
    FBufferSize := SizeOf(TIPCHeader) + ABufferSize;
    result := 0;
  End;
end;

procedure TIPCSharedMemory.Close;
begin
  If IsInitialized Then
  Begin
    CloseHandle(FHMapping);
    CloseHandle(FHSignal1);
    CloseHandle(FHSignal2);
  End;
end;

function TIPCSharedMemory.ClearMemory : Integer;
var
  hMapView  : pointer;
  IPCHeader : TIPCHeader;
begin
  result := -1;
  If IsInitialized Then
  Begin
    hMapView := MapViewOfFile(FHMapping, FILE_MAP_ALL_ACCESS, 0, 0, FBufferSize);
    If Assigned(hMapView) Then
    Begin
      FillChar(IPCHeader, SizeOf(TIPCHeader), #0);
      CopyMemory(hMapView, @IPCHeader, SizeOf(TIPCHeader));
      UnmapViewOfFile(hMapView);
      result := ERROR_SUCCESS;
    End;
  End
  else
    result := GetLastError;
end;

function TIPCSharedMemory.GetStringCount : Integer;
var
  hMapView  : pointer;
  IPCHeader : TIPCHeader;
  C1        : Integer;
begin
  result := -1;
  If IsInitialized Then
  Begin
    hMapView := MapViewOfFile(FHMapping, FILE_MAP_ALL_ACCESS, 0, 0, FBufferSize);
    If Assigned(hMapView) Then
    Begin
      CopyMemory(@IPCHeader, hMapView, SizeOf(TIPCHeader));

      For C1 := 0 to IPC_STRINGS_MAX - 1 Do
        If IPCHeader.StringSizes[C1] = 0 Then
        Begin
          result := C1;
          Break;
        End;

      UnmapViewOfFile(hMapView);
    End;
  End;
end;

function TIPCSharedMemory.WriteString(const AString : String) : Integer;
var
  hMapView   : pointer;
  hMapViewEx : pointer;
  IPCHeader  : TIPCHeader;
  C1         : Integer;
begin
  result := -1;
  If IsInitialized Then
  Begin
    hMapView := MapViewOfFile(FHMapping, FILE_MAP_ALL_ACCESS, 0, 0, FBufferSize);
    If Assigned(hMapView) Then
    Begin
      WaitForSingleObject(FHSignal1, INFINITE);
      CopyMemory(@IPCHeader, hMapView, SizeOf(TIPCHeader));
      IPCHeader.StringSizes[StringCount] := Length(AString);
      CopyMemory(hMapView, @IPCHeader, SizeOf(TIPCHeader));

      hMapViewEx := IncPointer(hMapView, SizeOf(TIPCHeader));
      For C1 := 0 to StringCount - 2 Do
        hMapViewEx := IncPointer(hMapViewEx, IPCHeader.StringSizes[C1] * SizeOf(Char));
      CopyMemory(hMapViewEx, PChar(AString), Length(AString) * SizeOf(Char));
      UnmapViewOfFile(hMapView);
      result := ERROR_SUCCESS;
      SetEvent(FHSignal2);
    End;
  End
  else
    result := GetLastError;
end;

function TIPCSharedMemory.ReadLastString : String;
var
  hMapView   : pointer;
  hMapViewEx : pointer;
  IPCHeader  : TIPCHeader;
  C1         : Integer;
begin
  result := '';
  If IsInitialized Then
  Begin
    hMapView := MapViewOfFile(FHMapping, FILE_MAP_ALL_ACCESS, 0, 0, FBufferSize);
    If Assigned(hMapView) Then
    Begin
      CopyMemory(@IPCHeader, hMapView, SizeOf(TIPCHeader));

      hMapViewEx := IncPointer(hMapView, SizeOf(TIPCHeader));
      If StringCount > 0 Then
      Begin
        For C1 := 0 to StringCount - 2 Do
          hMapViewEx := IncPointer(hMapViewEx, IPCHeader.StringSizes[C1] * SizeOf(Char));
        SetLength(result, IPCHeader.StringSizes[StringCount - 1]);
        CopyMemory(@result[1], hMapViewEx, Length(result) * SizeOf(Char));
      End;
      UnmapViewOfFile(hMapView);
    End;
  End;
end;

function TIPCSharedMemory.RemoveLastString : Integer;
var
  hMapView  : pointer;
  IPCHeader : TIPCHeader;
begin
  result := -1;
  If IsInitialized Then
  Begin
    hMapView := MapViewOfFile(FHMapping, FILE_MAP_ALL_ACCESS, 0, 0, FBufferSize);
    If Assigned(hMapView) Then
    Begin
      CopyMemory(@IPCHeader, hMapView, SizeOf(TIPCHeader));
      If StringCount > 0 Then
      Begin
        IPCHeader.StringSizes[StringCount - 1] := 0;
        CopyMemory(hMapView, @IPCHeader, SizeOf(TIPCHeader));
      End;
      UnmapViewOfFile(hMapView);
      result := ERROR_SUCCESS;
    End;
  End
  else
    result := GetLastError;
end;

end.
