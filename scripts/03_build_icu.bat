@echo off
echo ------ ICU -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %~dp0\download icu4c-%ICU_VERSION2%-src.tgz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST icu (
  echo found extracted sources
)

if NOT EXIST icu (
  echo extracting
  CALL bsdtar xfz %PKGDIR%\icu4c-%ICU_VERSION2%-src.tgz
  IF ERRORLEVEL 1 GOTO ERROR
)

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
::pause

ECHO building ... DEBUG
CALL msbuild source\allinone\allinone.sln /t:Rebuild  /p:Configuration="Debug" /p:Platform=%BUILDPLATFORM%
IF ERRORLEVEL 1 GOTO ERROR

ECHO building ... RELEASE
CALL msbuild source\allinone\allinone.sln /t:Rebuild  /p:Configuration="Release" /p:Platform=%BUILDPLATFORM%
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR ICU --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%