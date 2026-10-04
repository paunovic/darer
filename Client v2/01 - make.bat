@ECHO OFF

REM ----------------------------------------------------------------------------------------------
REM --- 
REM --- DARER CLIENT MAKEFILE
REM ---
REM ---                                                                  (c) 2011, Marko Paunovic
REM ---
REM ----------------------------------------------------------------------------------------------



:BEGIN
TITLE Building project...

:PREPARATION
SET /P var = Preparing... < nul
RMDIR /S /Q _release > nul
MKDIR _release\GProxy > nul

COPY /Y Client\GProxy\gproxy.exe _release\gproxy\gproxy.exe > nul
COPY /Y Client\GProxy\bncsutil.dll _release\gproxy\bncsutil.dll > nul
COPY /Y Client\GProxy\pdcurses.dll _release\gproxy\pdcurses.dll > nul
ECHO D | XCOPY /E /Q /Y Client\Languages _release\Languages > nul
ECHO D | XCOPY /E /Q /Y Client\Sounds _release\Sounds > nul
ECHO done!



REM ----------------------------------------------------------------------------------------------
REM --- RESOURCE COMPILE
REM ----------------------------------------------------------------------------------------------
:CMP_RESOURCES
ECHO.
ECHO Compiling resources...
GOTO CMP_RS_DARER

:CMP_RS_DARER
SET /P var = ".  - Darer... " < nul
CALL _resources\compile _resources\client\resources.rc > nul
IF NOT (%ERRORLEVEL%) == (0)	GOTO CMP_RS_DARER_ERROR
ECHO done!
GOTO CMP_PROJECTS

:CMP_RS_DARER_ERROR
ECHO error! [%ERRORLEVEL%]
GOTO CMP_PROJECTS


REM ----------------------------------------------------------------------------------------------
REM --- PROJECT COMPILE
REM ----------------------------------------------------------------------------------------------
:CMP_PROJECTS
ECHO.
ECHO Compiling projects...
GOTO CMP_PR_DARER

:CMP_PR_DARER
SET /P var = ".  - Darer... " < nul
CALL compile Client\Darer ..\_release
IF NOT (%ERRORLEVEL%) == (0)	GOTO CMP_PR_DARER_ERROR
DEL _release\Darer.map
ECHO done!
GOTO END

:CMP_PR_DARER_ERROR
ECHO error! [%ERRORLEVEL%]
GOTO ONERROR


REM ----------------------------------------------------------------------------------------------
REM --- END BLOCK
REM ----------------------------------------------------------------------------------------------
:ONERROR
TITLE Done with errors !
ECHO.
ECHO ERROR: %ERRORLEVEL%
PAUSE
EXIT /B %ERRORLEVEL%

:END
TITLE Done !
ECHO.
ECHO Compile successful !
EXIT /B 0