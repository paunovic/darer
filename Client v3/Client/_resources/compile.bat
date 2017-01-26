IF (%1) == ()	EXIT /B -1

SET TDIR=%cd%
CHDIR %~dp1 > nul

ECHO Building %1...
brcc32 %~nx1 > nul

SET CERR=%ERRORLEVEL%
CHDIR %TDIR% > nul
EXIT /B %CERR%