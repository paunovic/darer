IF (%1) == ()	EXIT /B -1

_tools\upx.exe --best %1

SET CERR=%ERRORLEVEL%
IF NOT (%CERR%) == (0)	GOTO END

ECHO.
ECHO Patching %~nx1...

:LOOP
IF (%2) == () GOTO END
IF (%3) == () GOTO END

ECHO   - offset %2 [%3 bytes]
_tools\patcher.exe %1 %2 %3 0

SHIFT /2
SHIFT /2

GOTO LOOP


:END
EXIT /B %CERR%