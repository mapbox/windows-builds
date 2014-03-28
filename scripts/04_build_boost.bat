@echo off
echo ----------- boost ---------

echo extracting
CALL bsdtar xzf %PKGDIR%/boost_1_%BOOST_VERSION%_0.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

cd boost_1_%BOOST_VERSION%_0

::set to -vc110 if using MSVC 2012
SET BOOST_PREFIX=boost-%BOOST_VERSION%-vc120
echo calling bootstrap bat
CALL bootstrap.bat
IF ERRORLEVEL 1 GOTO ERROR

::note for VS2012, use toolset=msvc-11.0 and VS2010 use toolset=msvc-10.0 
echo bjamming ....
CALL bjam toolset=msvc-12.0 --prefix=..\\%BOOST_PREFIX% --with-thread --with-filesystem --with-date_time --with-system --with-program_options --with-regex --with-chrono --disable-filesystem2 -sHAVE_ICU=1 -sICU_PATH=%ROOTDIR%\\icu -sICU_LINK=%ROOTDIR%\\icu\\lib\\icuuc.lib release link=static install --build-type=complete
IF ERRORLEVEL 1 GOTO ERROR

::if you need python
::note for VS2012, use toolset=msvc-11.0 and VS2010 use toolset=msvc-10.0 
echo bjamming (pyhton) ....
bjam toolset=msvc-12.0 --prefix=..\\%BOOST_PREFIX% --with-python python=2.7 release link=static --build-type=complete install
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo =========== ERROR boost =========

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%
