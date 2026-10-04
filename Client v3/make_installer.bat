@ECHO OFF

REM ----------------------------------------------------------------------------------------------
REM --- 
REM --- DARER CLIENT MAKEFILE
REM ---
REM ---                                                                  (c) 2011, Marko Paunovic
REM ---
REM ----------------------------------------------------------------------------------------------


:BEGIN
TITLE Release preparation

REM ----------------------------------------------------------------------------------------------
REM --- PREPARATION
REM ----------------------------------------------------------------------------------------------
:PREPARATION
SET /P var = Preparing... < nul
RMDIR /S /Q _release > nul
MKDIR _release > nul
ECHO done!

REM ----------------------------------------------------------------------------------------------
REM --- SETUP CREATION
REM ----------------------------------------------------------------------------------------------
:INNO_SETUP_BUILD
ECHO.
SET /P var = "Creating setup... " < nul
"%PROGRAMFILES(x86)%\Inno Setup 5\ISCC.exe" /o"_release" /f"install_darer" _setup\setup.iss > nul
IF NOT (%ERRORLEVEL%) == (0)	GOTO INNO_SETUP_BUILD_ERROR

ECHO done!
GOTO END

:INNO_SETUP_BUILD_ERROR
ECHO error! [%ERRORLEVEL%]
GOTO ONERROR

:ONERROR
TITLE Done with errors !
ECHO.
ECHO ERROR: %ERRORLEVEL%
PAUSE
EXIT /B %ERRORLEVEL%

:END
TITLE Done !
ECHO.
ECHO Release preparation successful !
EXIT /B 0