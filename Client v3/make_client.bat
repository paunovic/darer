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


REM ----------------------------------------------------------------------------------------------
REM --- RESOURCE COMPILE
REM ----------------------------------------------------------------------------------------------
:CMP_RESOURCES
ECHO.
ECHO Compiling resources...
GOTO CMP_RS_DARER

:CMP_RS_DARER
SET /P var = ".  - Client... " < nul
CALL Client\_resources\compile Client\_resources\resources.rc > nul
IF NOT (%ERRORLEVEL%) == (0)	GOTO CMP_RS_COMPILE_ERROR
ECHO done!
GOTO CMP_PROJECTS

:CMP_RS_COMPILE_ERROR
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
SET /P var = ".  - Client... " < nul
CALL compile Client\Client.v3.dpr ..\_bin
IF NOT (%ERRORLEVEL%) == (0)	GOTO CMP_PR_COMPILE_ERROR
DEL _bin\Client.v3.map > nul
DEL _bin\Client.v3.drc > nul
DEL _bin\Darer.exe > nul
REN _bin\Client.v3.exe Darer.exe > nul
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