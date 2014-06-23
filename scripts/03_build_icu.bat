@echo off
echo ------ ICU -----


powershell scripts\deletedir -dir2del "%ROOTDIR%\icu"
IF ERRORLEVEL 1 GOTO ERROR

pause

CALL bsdtar xvfz %PKGDIR%\icu4c-%ICU_VERSION2%-src.tgz
IF ERRORLEVEL 1 GOTO ERROR

cd icu

echo.
ECHO "...... upgrading solution ........."
echo.

CALL devenv.exe /upgrade source\allinone\allinone.sln
IF ERRORLEVEL 1 GOTO ERROR

ECHO "solution upgraded"


echo building release AND debug
echo A boost build bug that tests for existence of *debug* version of ICU even when building release only version of boost. 
echo http://devwiki.neosys.com/index.php/Building_Boost_32/64_on_Windows
pause

ECHO building ... DEBUG
CALL msbuild source\allinone\allinone.sln /t:Rebuild  /p:Configuration="Debug" /p:Platform=%BUILDPLATFORM% >%ROOTDIR%\build_icu-%ICU_VERSION%-debug.log
IF ERRORLEVEL 1 GOTO ERROR

ECHO building ... RELEASE
CALL msbuild source\allinone\allinone.sln /t:Rebuild  /p:Configuration="Release" /p:Platform=%BUILDPLATFORM% >%ROOTDIR%\build_icu-%ICU_VERSION%-release.log
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR ICU --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%