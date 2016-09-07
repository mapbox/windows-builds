@echo off
SETLOCAL
SET EL=0
ECHO ~~~~~~~~~~~~~~~~~~~ %~f0 ~~~~~~~~~~~~~~~~~~~

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

:: http://w858rkbfg.homepage.t-online.de/files/9213/9317/6402/ragel-vs2012.7z

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download harfbuzz-%HARFBUZZ_VERSION%.tar.bz2
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF EXIST harfbuzz ECHO found extracted sources && GOTO SRC_EXTRACTED

ECHO extracting
CALL bsdtar xfz harfbuzz-%HARFBUZZ_VERSION%.tar.bz2
rename harfbuzz-%HARFBUZZ_VERSION% harfbuzz
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

:SRC_EXTRACTED

CD %PKGDIR%\harfbuzz\win32
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::build scripts seem to need lower case CFG
IF "%BUILD_TYPE%"=="Release" SET HB_CFG=release
IF "%BUILD_TYPE%"=="Debug" SET HB_CFG=debug

CALL nmake /A /F Makefile.vc CFG=%HB_CFG%  DIRECTWRITE=1 MSVC_VER=%MSVC_VER%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
ECHO ~~~~~~~~~~~~~~~~~~~ ERROR %~f0 ~~~~~~~~~~~~~~~~~~~
ECHO ERRORLEVEL^: %EL%

:DONE
ECHO ~~~~~~~~~~~~~~~~~~~ DONE %~f0 ~~~~~~~~~~~~~~~~~~~


CD %ROOTDIR%
EXIT /b %EL%
