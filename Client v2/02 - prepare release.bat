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
REM --- VERSION INPUT
REM ----------------------------------------------------------------------------------------------
:VERSION_INPUT
SET ClientVersion=
SET /P ClientVersion=Version: 

REM ----------------------------------------------------------------------------------------------
REM --- PREPARATION
REM ----------------------------------------------------------------------------------------------
:PREPARATION
ECHO.
SET /P var = Preparing... < nul
RMDIR /S /Q _final > nul
MKDIR _final > nul
ECHO done!


REM ----------------------------------------------------------------------------------------------
REM --- RELEASE COMPRESSION
REM ----------------------------------------------------------------------------------------------
:COMPRESS_RELEASE
ECHO.
SET /P var = "Compressing release... " < nul
CD _release
..\_tools\7z\7z.exe a -r -tzip ..\_final\%ClientVersion%.FULL > nul
IF NOT (%ERRORLEVEL%) == (0)	GOTO COMPRESS_RELEASE_ERROR
ECHO done!
GOTO INNO_SETUP_BUILD

:COMPRESS_RELEASE_ERROR
ECHO error! [%ERRORLEVEL%]
GOTO ONERROR

REM ----------------------------------------------------------------------------------------------
REM --- SETUP CREATION
REM ----------------------------------------------------------------------------------------------
:INNO_SETUP_BUILD
ECHO.
SET /P var = "Creating setup... " < nul
CD ..
"%PROGRAMFILES(x86)%\Inno Setup 5\ISCC.exe" /o"_final" /f"install_darer" _setup\setup.iss > nul
IF NOT (%ERRORLEVEL%) == (0)	GOTO INNO_SETUP_BUILD_ERROR
MOVE _setup\install_darer.exe _final\install_darer.exe > nul
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