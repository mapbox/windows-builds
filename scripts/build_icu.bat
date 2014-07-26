@echo off
echo ------ ICU -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

:: http://blog.pcitron.fr/2014/03/25/compiling-icu-with-visual-studio-2013/

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download icu4c-%ICU_VERSION2%-src.tgz
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
IF ERRORLEVEL 1 GOTO ERROR

call msbuild source\allinone\allinone.sln /m /target:Build /toolsversion:12.0 /p:PlatformToolset=v120 /p:Configuration="Release" /p:Platform=%BUILDPLATFORM%
IF ERRORLEVEL 1 GOTO ERROR

::echo building release AND debug
::echo A boost build bug that tests for existence of *debug* version of ICU even when building release only version of boost. 
::echo http://devwiki.neosys.com/index.php/Building_Boost_32/64_on_Windows

::ECHO building ... DEBUG
::CALL msbuild source\allinone\allinone.sln /t:Rebuild  /p:Configuration="Debug" /p:Platform=%BUILDPLATFORM%
::IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR ICU --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%