uses
  Windows, Misc;

procedure ProcessParam(const AParam : String);
var
  tmp, tmp1, tmp2 : String;
  pinfo           : TProcessInformation;
  stype           : Integer;
  res             : Integer;
begin
  If MatchStrings('/exec? *', AParam) Then
  Begin
    tmp := AParam;

    Case AParam[6] of
      's' : stype := SW_SHOW;
      'h' : stype := SW_HIDE;
    else
      stype := SW_SHOW;
    End;

    Delete(tmp, 1, Pos(' ', tmp));

    If Pos('|', tmp) > 0 Then
    Begin
      tmp1 := Copy(tmp, 1, Pos('|', tmp) - 1);
      tmp2 := tmp;
      Delete(tmp2, 1, Pos('|', tmp2));
    End
    else
    Begin
      tmp1 := tmp;
      tmp2 := '';
    End;

    If tmp2 <> '' Then
      res := ExecuteFile(PWideChar(tmp1), PWideChar(tmp2), nil, SW_HIDE, 0, pinfo)
    else
      res := ExecuteFile(PWideChar(tmp1), nil, nil, SW_HIDE, 0, pinfo);

    If (res = ERROR_SUCCESS) and
       (stype = SW_HIDE) Then
      ShowWindow(pinfo.hProcess, SW_HIDE);
  End;
end;

procedure ProcessParameters(AParams : String);
var
  C1     : Integer;
  params : String;
begin
  For C1 := 1 to ParamCountEx(AParams) Do
    If (ParamStrEx(C1, AParams) <> '') and
       (ParamStrEx(C1, AParams)[1] = '/') Then
    Begin
      If params <> '' Then
        ProcessParam(params);
      params := ParamStrEx(C1, AParams);
    End
    else
      params := params + ' ' + ParamStrEx(C1, AParams);

  ProcessParam(params);
end;

begin
  ProcessParameters(GetCommandLine);
end.
