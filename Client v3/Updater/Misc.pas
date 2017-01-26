unit Misc;

interface

uses
  Windows;

function ParamCountEx(const AParams : String) : Integer;
function ParamStrEx(Index : Integer; const AParams : String) : String;
function MatchStrings(const AStr1, AStr2 : String; const ACaseSensitive : Boolean = FALSE) : Boolean;
function ExecuteFile(const AFileName, AParameters, ADirectory : PChar; const AType, AFlags : Integer; var AProcessInfo : TProcessInformation) : Integer; overload;
function ExecuteFile(const AFileName : PChar; AParameters : PChar = nil; ADirectory : PChar = nil; const AType : Integer = SW_SHOW; const AFlags : Integer = 0) : Integer; overload;

implementation

uses
  SysUtils;

function GetParamStr(P: PChar; var Param: string): PChar;
var
  i, Len: Integer;
  Start, S, Q: PChar;
begin
  while True do
  begin
    while (P[0] <> #0) and (P[0] <= ' ') do
      P := CharNext(P);
    if (P[0] = '"') and (P[1] = '"') then Inc(P, 2) else Break;
  end;
  Len := 0;
  Start := P;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      P := CharNext(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        Q := CharNext(P);
        Inc(Len, Q - P);
        P := Q;
      end;
      if P[0] <> #0 then
        P := CharNext(P);
    end
    else
    begin
      Q := CharNext(P);
      Inc(Len, Q - P);
      P := Q;
    end;
  end;

  SetLength(Param, Len);

  P := Start;
  S := Pointer(Param);
  i := 0;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      P := CharNext(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        Q := CharNext(P);
        while P < Q do
        begin
          S[i] := P^;
          Inc(P);
          Inc(i);
        end;
      end;
      if P[0] <> #0 then P := CharNext(P);
    end
    else
    begin
      Q := CharNext(P);
      while P < Q do
      begin
        S[i] := P^;
        Inc(P);
        Inc(i);
      end;
    end;
  end;

  Result := P;
end;

function ParamCountEx(const AParams : String) : Integer;
var
  P: PChar;
  S: string;
begin
  Result := 0;
  P := GetParamStr(PChar(AParams), S);
  while True do
  begin
    P := GetParamStr(P, S);
    if S = '' then Break;
    Inc(Result);
  end;
end;

function ParamStrEx(Index : Integer; const AParams : String) : String;
var
  P: PChar;
  Buffer: array[0..260] of Char;
begin
  Result := '';
  if Index = 0 then
    SetString(Result, Buffer, GetModuleFileName(0, Buffer, SizeOf(Buffer)))
  else
  begin
    P := PChar(AParams);
    while True do
    begin
      P := GetParamStr(P, Result);
      if (Index = 0) or (Result = '') then Break;
      Dec(Index);
    end;
  end;
end;

function MatchStrings(const AStr1, AStr2 : String; const ACaseSensitive : Boolean) : Boolean;

  function MatchPattern(str1, str2 : PWideChar) : Boolean;
  begin
    If StrComp(str2, '*') = 0 Then
      result := TRUE
    else
      If (str1^ = #0) and
         (str2^ <> #0) Then
        result := FALSE
      else
        If str1^ = #0 Then
          result := TRUE
        else
          Case str2^ of
            '*': If MatchPattern(str1, @str2[1]) Then
                   result := TRUE
                 else
                   result := MatchPattern(@str1[1], str2);
            '?': result := MatchPattern(@str1[1], @str2[1]);
          else
            If str1^ = str2^ Then
              result := MatchPattern(@str1[1], @str2[1])
            else
              result := FALSE;
          end;
  end;

begin
  If ACaseSensitive Then
    result := MatchPattern(PWideChar(AStr1), PWideChar(AStr2)) or
              MatchPattern(PWideChar(AStr2), PWideChar(AStr1))
  else
    result := MatchPattern(PWideChar(LowerCase(AStr1)), PWideChar(LowerCase(AStr2))) or
              MatchPattern(PWideChar(LowerCase(AStr2)), PWideChar(LowerCase(AStr1)));
end;


function ExecuteFile(const AFileName, AParameters, ADirectory : PChar; const AType, AFlags : Integer; var AProcessInfo : TProcessInformation) : Integer;
var
  sInfo         : TStartupInfo;
  pInfo         : TProcessInformation;
  fname, params : String;
begin
  FillChar(pinfo, SizeOf(TProcessInformation), 0);

  FillChar(sInfo, SizeOf(TStartupInfo), 0);
  With sInfo Do
  Begin
    cb := SizeOf(TStartupInfo);
    dwFlags := STARTF_USESHOWWINDOW;
    wShowWindow := AType;
  End;

  fname := AFilename;
  params := AParameters;
  If CreateProcess(nil,
                   PChar(Format('"%s" %s', [fname, params])),
                   nil,
                   nil,
                   FALSE,
                   NORMAL_PRIORITY_CLASS or CREATE_NEW_CONSOLE or AFlags,
                   nil,
                   ADirectory,
                   sInfo,
                   pInfo) Then
  Begin
    result := ERROR_SUCCESS;
    AProcessInfo := pinfo;
  End
  else
    result := GetLastError;
end;

function ExecuteFile(const AFileName : PChar; AParameters : PChar = nil; ADirectory : PChar = nil; const AType : Integer = SW_SHOW; const AFlags : Integer = 0) : Integer; overload;
var
  pInfo : TProcessInformation;
begin
  result := ExecuteFile(AFileName, AParameters, ADirectory, AType, AFlags, pInfo);
end;

end.
