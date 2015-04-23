@echo off
SETLOCAL
SET EL=0
echo ----------- boost ---------

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download boost_1_%BOOST_VERSION%_0.tar.bz2
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST boost_1_%BOOST_VERSION%_0 (
  echo found extracted sources
)

if NOT EXIST boost (
  echo extracting
  CALL bsdtar xzf %PKGDIR%/boost_1_%BOOST_VERSION%_0.tar.bz2
  IF %ERRORLEVEL% NEQ 0 GOTO ERROR
  rename boost_1_%BOOST_VERSION%_0 boost
  IF %ERRORLEVEL% NEQ 0 GOTO ERROR
)

cd boost
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::ohhh, how i LOVE commandline. CANNOT set path when using parentheses e.g. IF EXIST xyz ( SET PATH=bla;%PATH% )
::%PATH% would get evaluated as a command and bail out of BAT with unexpected ERROR
::e.g. "\Microsoft was unexpected at this time."
if "%BOOSTADDRESSMODEL%"=="32" if EXIST %ROOTDIR%\tmp-bin\python2-x86-32 SET PATH=%ROOTDIR%\tmp-bin\python2-x86-32;%PATH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
if "%BOOSTADDRESSMODEL%"=="64" if EXIST %ROOTDIR%\tmp-bin\python2 SET PATH=%ROOTDIR%\tmp-bin\python2;%PATH%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if "%BOOSTADDRESSMODEL%"=="64" (
  IF %BUILD_TYPE% EQU Release (
    SET ICU_LINK=%PKGDIR%\icu\lib64\icuuc.lib
  ) ELSE (
    SET ICU_LINK=%PKGDIR%\icu\lib64\icuucd.lib
  )
  echo !!!!!!!!!
  echo USING x86 COMMANDPROMPT!!!!!!!!
  REM ::http://www.boost.org/boost-build2/doc/html/bbv2/reference/tools.html#v2.reference.tools.compiler.msvc.64
  REM ::If you provide a path to the compiler explicitly, provide the path to the 32-bit compiler. If you try to specify the path to any of 64-bit
  echo !!!!!!!!

  ::use x86 command prompt
  if "%TOOLS_VERSION%" == "12.0" (
    CALL "C:/Program Files (x86)/Microsoft Visual Studio 12.0/VC/vcvarsall.bat" x86
  )
  if "%TOOLS_VERSION%" == "14.0" (
    CALL "C:/Program Files (x86)/Microsoft Visual Studio 14.0/VC/vcvarsall.bat" x86
  )
) ELSE (
  IF %BUILD_TYPE% EQU Release (
    SET ICU_LINK=%PKGDIR%\icu\lib\icuuc.lib
  ) ELSE (
    SET ICU_LINK=%PKGDIR%\icu\lib\icuucd.lib
  )
)

ECHO ICU_LINK %ICU_LINK%

::NOTE: you cannot have both pythons installed otherwise it appears bjam will still find the 64 bit one

if NOT EXIST b2.exe (
  echo calling bootstrap bat
  CALL bootstrap.bat --with-toolset=msvc-%TOOLS_VERSION%
  IF %ERRORLEVEL% NEQ 0 GOTO ERROR
)

::VS2010/MSBuild 10: toolset=msvc-10.0
::VS2012/MSBuild 11: toolset=msvc-11.0
::VS2013/MSBuild 12: toolset=msvc-12.0
::64bit: http://stackoverflow.com/a/2326485

:: HINT: problems with icu configure check?
:: cat bin.v2/config.log to see problems

::CALL b2 toolset=msvc-12.0 --clean

IF %BUILD_TYPE% EQU Release (
  SET BOOST_BUILD_TYPE=release
) ELSE (
  REM debug-store=database (to create pdb files) does not work for static libs
  REM debug-store=object directly embeds the symbol information into the .lib file
  SET BOOST_BUILD_TYPE=variant=debug debug-symbols=on debug-store=object
)

ECHO BOOST_BUILD_TYPE %BOOST_BUILD_TYPE%

CALL b2 -j%NUMBER_OF_PROCESSORS% ^
-d2 %BOOST_BUILD_TYPE% stage ^
--build-type=minimal ^
toolset=msvc-%TOOLS_VERSION% -q ^
runtime-link=shared ^
link=static ^
address-model=%BOOSTADDRESSMODEL% ^
--with-iostreams ^
--with-test ^
--with-thread ^
--with-filesystem  ^
--with-date_time ^
--with-system ^
--with-program_options ^
--with-regex ^
--disable-filesystem2 ^
cxxflags="-DBOOST_MSVC_ENABLE_2014_JUN_CTP" ^
-sHAVE_ICU=1 ^
-sICU_PATH=%PKGDIR%\\icu ^
-sICU_LINK=%ICU_LINK% ^
-sZLIB_SOURCE=%PKGDIR%\zlib ^
-sBUILD=boost_unit_test_framework

IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: build boost_python now
:: we do this separately because
:: we want to dynamically link python

CALL b2 -j%NUMBER_OF_PROCESSORS% ^
  -d2 %BOOST_BUILD_TYPE% stage ^
  --build-type=minimal toolset=msvc-%TOOLS_VERSION% -q ^
  runtime-link=shared link=shared ^
  cxxflags="-DBOOST_MSVC_ENABLE_2014_JUN_CTP" ^
  address-model=%BOOSTADDRESSMODEL% ^
  --with-python python=2.7

IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo =========== ERROR boost =========

:DONE

::reset x64 command prompt
if "%BOOSTADDRESSMODEL%"=="64" (
  if "%TOOLS_VERSION%" == "12.0" (
    CALL "C:/Program Files (x86)/Microsoft Visual Studio 12.0/VC/vcvarsall.bat" amd64
  )
  if "%TOOLS_VERSION%" == "14.0" (
    CALL "C:/Program Files (x86)/Microsoft Visual Studio 14.0/VC/vcvarsall.bat" amd64
  )
)

cd %ROOTDIR%
EXIT /b %EL%
