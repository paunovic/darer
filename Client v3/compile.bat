IF (%1) == ()	EXIT /B -1

SET TDIR=%cd%
CHDIR %~dp1 > nul

SET MAD=%ProgramFiles(x86)%\madCollection
SET RAD=%ProgramFiles(x86)%\Embarcadero\RAD Studio\8.0
SET RADUSR=C:\Users\Public\Documents\RAD Studio\8.0
SET CMP=%RADUSR%\Components
SET JCL=%CMP%\jcl-2.4.0.4397
SET JVCL=%CMP%\jvcl3-2012-03-15

"%RAD%\bin\dcc32.exe" -I"%JVCL%\common" -R"%JCL%\source\common;%JVCL%\resources" -U"%MAD%\madBasic\BDS8;%MAD%\madExcept\BDS8;%MAD%\madDisAsm\BDS8;%CMP%\SkinFeature;%JVCL%\lib\d15;%CMP%\PngComponents\D15\release;%CMP%\OverbyteICS\Delphi\Vc32;%JCL%\lib\d15;%CMP%\DCPCrypt;%CMP%\DCPCrypt\Hashes;%CMP%\DCPCrypt\Ciphers;C:\Program Files (x86)\Eldos\SecureBlackbox\Units\Delphi15;%CMP%\Cooltray" -B -E"%2" %~nx1

SET CERR=%ERRORLEVEL%
CHDIR %TDIR% > nul
EXIT /B %CERR%

