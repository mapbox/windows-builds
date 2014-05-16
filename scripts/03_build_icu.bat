@echo off
echo ------ ICU -----

CALL bsdtar xvfz %PKGDIR%\icu4c-4_8_1_1-src.tgz
IF ERRORLEVEL 1 GOTO ERROR

cd icu/
ECHO upgrading solution
CALL devenv.exe /upgrade source\allinone\allinone.sln
IF ERRORLEVEL 1 GOTO ERROR

ECHO building ...
msbuild source\allinone\allinone.sln /t:Rebuild  /p:Configuration="Release" /p:Platform=%BUILDPLATFORM%
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR ICU --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%