@ECHO OFF

REM ----------------------------------------------------------------------------------------------
REM --- 
REM --- DARER CLIENT MAKEFILE
REM ---
REM ---                                                                  (c) 2011, Marko Paunovic
REM ---
REM ----------------------------------------------------------------------------------------------



REM ----------------------------------------------------------------------------------------------
REM --- PREPARATION
REM ----------------------------------------------------------------------------------------------
:BEGIN
TITLE Building project...
SET /P var = Preparing... < nul
REM RMDIR /S /Q _bin > nul
MKDIR _bin  > nul

:PREPARATION

ECHO done!
GOTO CMP_PROJECTS

REM ----------------------------------------------------------------------------------------------
REM --- PROJECT COMPILE
REM ----------------------------------------------------------------------------------------------
:CMP_PROJECTS
ECHO.
ECHO Compiling projects...
GOTO CMP_PR_UPDATER

:CMP_PR_UPDATER
SET /P var = ".  - Updater... " < nul
CALL compile Updater\Updater.dpr ..\_bin
IF NOT (%ERRORLEVEL%) == (0)	GOTO CMP_PR_COMPILE_ERROR
ECHO done!
GOTO END

:CMP_PR_COMPILE_ERROR
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