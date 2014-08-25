@echo off
echo ----------- boost ---------

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

:: ensure python is around
if NOT EXIST C:/Python27/python.exe ( echo "Missing C:/Python27/python.exe" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download boost_1_%BOOST_VERSION%_0.tar.bz2
IF ERRORLEVEL 1 GOTO ERROR

if EXIST boost_1_%BOOST_VERSION%_0 (
  echo found extracted sources
)

if NOT EXIST boost_1_%BOOST_VERSION%_0 (
  echo extracting
  CALL bsdtar xzf %PKGDIR%/boost_1_%BOOST_VERSION%_0.tar.bz2
  IF ERRORLEVEL 1 GOTO ERROR
)

cd boost_1_%BOOST_VERSION%_0

if "%TARGET_ARCH%"=="64" (
  echo !!!!!!!!!
  echo USE x86 COMMANDPROMPT!!!!!!!!
  ::http://www.boost.org/boost-build2/doc/html/bbv2/reference/tools.html#v2.reference.tools.compiler.msvc.64
  :: If you provide a path to the compiler explicitly, provide the path to the 32-bit compiler. If you try to specify the path to any of 64-bit compilers, configuration will not work.
  echo !!!!!!!!
)

echo using python : 2.7 : C:/Python27/python.exe ; >> user-config.jam

if NOT EXIST b2.exe (
  echo calling bootstrap bat
  CALL bootstrap.bat --with-toolset=msvc-12.0
  IF ERRORLEVEL 1 GOTO ERROR
)

::http://dominoc925.blogspot.co.at/2013/04/how-i-build-boost-for-64-bit-windows.html

::patching has_icu_test.cpp
::http://stackoverflow.com/a/16304738

::I was building boost with the bjam -q option.
::When I build using the bjam -q option the build stops on the above error and
::does not build the libraries.
::I removed the -q and it ignored the above error, as you explained, and
::everything built fine. 

::http://www.boost.org/boost-build2/doc/html/bbv2/overview/invocation.html
::http://www.boost.org/doc/libs/1_55_0/more/getting_started/windows.html#or-build-binaries-from-source
::http://www.boost.org/doc/libs/1_55_0/libs/regex/doc/html/boost_regex/install.html
::http://devwiki.neosys.com/index.php/Building_Boost_32/64_on_Windows


::VS2010/MSBuild 10: toolset=msvc-10.0 
::VS2012/MSBuild 11: toolset=msvc-11.0
::VS2013/MSBuild 12: toolset=msvc-12.0
::64bit: http://stackoverflow.com/a/2326485

:: HINT: problems with icu configure check?
:: cat bin.v2/config.log to see problems

::CALL b2 toolset=msvc-12.0 --clean
CALL b2 -j%NUMBER_OF_PROCESSORS% ^
  -d0 release stage ^
  --build-type=minimal toolset=msvc-12.0 -q ^
  runtime-link=shared link=static ^
  address-model=%BOOSTADDRESSMODEL% ^
  --with-thread --with-filesystem  ^
  --with-date_time --with-system ^
  --with-program_options --with-regex ^
  --disable-filesystem2 ^
  -sHAVE_ICU=1 -sICU_PATH=%PKGDIR%\\icu -sICU_LINK=%PKGDIR%\\icu\\lib\\icuuc.lib
  
IF ERRORLEVEL 1 GOTO ERROR

:: build boost_python now
:: we do this separately because
:: we want to dynamically link python
CALL b2 -j%NUMBER_OF_PROCESSORS% ^
  -d0 release stage ^
  --build-type=minimal toolset=msvc-12.0 -q ^
  runtime-link=shared link=shared ^
  address-model=%BOOSTADDRESSMODEL% ^
  --with-python python=2.7

IF ERRORLEVEL 1 GOTO ERROR


::icu: lib64\
:: -a rebuild everything
:: -q stop at first error
:: --reconfigure rerun all configuration checks

::this seems to be necessary to get all types regex libs
::even when -sICU_PATH is specified
::SET INCLUDE=%ROOTDIR%\icu\include;%INCLUDE%

:: SEEMS THAT ONLY SINGLE BACKSLASH IS VALID FOR -sICU_PATH
:: NO DOUBLE BACKSLASH. STILL HAVE TO VERIY
::echo building python %BOOSTADDRESSMODEL%
::CALL b2 -j%NUMBER_OF_PROCESSORS%  ^
::  -d1 -q ^
::  toolset=msvc-12.0 address-model=%BOOSTADDRESSMODEL%  ^
::  --prefix=..\\%BOOST_PREFIX% --with-python python=2.7 release link=shared stage install
::>%ROOTDIR%\build_boost-%BOOST_VERSION%.log 2>&1

::echo building python 64 BIT
::CALL b2 -d1 -q toolset=msvc-12.0 address-model=%BOOSTADDRESSMODEL% -a --prefix=..\\%BOOST_PREFIX% --with-python python=2.7 release link=shared
::>%ROOTDIR%\build_boost-%BOOST_VERSION%.log 2>&1
IF ERRORLEVEL 1 GOTO ERROR

::if you need python
::note for VS2012, use toolset=msvc-11.0 and VS2010 use toolset=msvc-10.0 
::echo bjamming (python) ....
::CALL bjam toolset=msvc-12.0 --prefix=..\\%BOOST_PREFIX% --with-python python=2.7 release link=static --build-type=complete install
::IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo =========== ERROR boost =========

:DONE
cd %ROOTDIR%
EXIT /b %ERRORLEVEL%
