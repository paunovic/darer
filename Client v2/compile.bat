IF (%1) == ()	EXIT /B -1

SET TDIR=%cd%
CHDIR %~dp1 > nul

SET CP=%ProgramFiles(x86)%
SET CPM=%CP%\madCollection
SET CDP=%CP%\Delphi7SE
SET CDPC=%CDP%\Components

dcc32.exe -B -E"%2" -U"%CP%\ComponentAce\ZipForge\Lib\Delphi 7;%CDP%\Lib;%CDP%\Bin;%CDP%\Imports;%CDP%\Projects\Bpl;%CPM%\madBasic\Delphi 7;%CPM%\madDisAsm\Delphi 7;%CPM%\madExcept\Delphi 7;%CPM%\madRemote\Delphi 7;%CPM%\madKernel\Delphi 7;%CPM%\madCodeHook\Delphi 7;%CPM%\madSecurity\Delphi 7;%CPM%\madShell\Delphi 7;%CDPC%\CoolTrayIcon;%CDPC%\FastCode;%CDPC%\JSON SuperObject;%CDPC%\jcl\lib\d7;%CDPC%\jcl\source\include;%CP%\TntWare\Delphi Unicode Controls\Source;%CDPC%\SkinFeature;%CDPC%\OverbyteICS\Delphi\Vc32;%CDPC%\DCPCrypt;%CDPC%\DCPCrypt\Ciphers;%CDPC%\DCPCrypt\Hashes;%CDPC%\Vortex;%CDPC%\TRichView\Units\D7;%CDPC%\GraphicEx;%CDPC%\ImageEn;%CDPC%\jvcl\lib\d7;%CDPC%\jvcl\common" -R"%CDPC%\jvcl\resources" %~nx1 > nul

SET CERR=%ERRORLEVEL%
CHDIR %TDIR% > nul
EXIT /B %CERR%

