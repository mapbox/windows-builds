@echo off
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

if NOT EXIST boost_1_%BOOST_VERSION%_0 (
  echo extracting
  CALL bsdtar xzf %PKGDIR%/boost_1_%BOOST_VERSION%_0.tar.bz2
  IF %ERRORLEVEL% NEQ 0 GOTO ERROR
)

cd boost_1_%BOOST_VERSION%_0

if "%BOOSTADDRESSMODEL%"=="64" (
  SET ICU_LINK=%PKGDIR%\icu\lib64\icuuc.lib
  echo !!!!!!!!!
  echo USE x86 COMMANDPROMPT!!!!!!!!
  ::http://www.boost.org/boost-build2/doc/html/bbv2/reference/tools.html#v2.reference.tools.compiler.msvc.64
  :: If you provide a path to the compiler explicitly, provide the path to the 32-bit compiler. If you try to specify the path to any of 64-bit compilers, configuration will not work.
  echo !!!!!!!!

::use x86 command prompt
  if "%TOOLS_VERSION%" == "12.0" (
    CALL "C:/Program Files (x86)/Microsoft Visual Studio 12.0/VC/vcvarsall.bat" x86
  )
  if "%TOOLS_VERSION%" == "14.0" (
    CALL "C:/Program Files (x86)/Microsoft Visual Studio 14.0/VC/vcvarsall.bat" x86
  )

  if EXIST c:/tools/python2 (
      echo using python : 2.7 : c:/tools/python2/python.exe ; > user-config.jam
  )
) ELSE (
  SET ICU_LINK=%PKGDIR%\icu\lib\icuuc.lib
  :: use cint python location
  if EXIST c:/tools/python2-x86-32 (
      echo using python : 2.7 : c:/tools/python2-x86-32/python.exe ; > user-config.jam
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
CALL b2 -j%NUMBER_OF_PROCESSORS% ^
  -d0 release stage ^
  --build-type=minimal toolset=msvc-%TOOLS_VERSION% -q ^
  runtime-link=shared link=static ^
  address-model=%BOOSTADDRESSMODEL% ^
  --with-thread --with-filesystem  ^
  --with-date_time --with-system ^
  --with-program_options --with-regex ^
  --disable-filesystem2 ^
  -sHAVE_ICU=1 -sICU_PATH=%PKGDIR%\\icu -sICU_LINK=%ICU_LINK%
  
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:: build boost_python now
:: we do this separately because
:: we want to dynamically link python

CALL b2 -j%NUMBER_OF_PROCESSORS% ^
  -d0 release stage ^
  --build-type=minimal toolset=msvc-%TOOLS_VERSION% -q ^
  runtime-link=shared link=shared ^
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
