@echo off
SETLOCAL
SET EL=0
echo ------ pixman -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download pixman-%PIXMAN_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST pixman (
  echo found extracted sources
)


SETLOCAL ENABLEDELAYEDEXPANSION
if NOT EXIST pixman (
  echo extracting
  CALL bsdtar xfz pixman-%PIXMAN_VERSION%.tar.gz
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  rename pixman-%PIXMAN_VERSION% pixman
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  cd %PKGDIR%\pixman
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
  ECHO patching ...
  patch -N -p1 < %PATCHES%/pixman.diff || %SKIP_FAILED_PATCH%
  IF !ERRORLEVEL! NEQ 0 GOTO ERROR
)
ENDLOCAL


cd %PKGDIR%\pixman\pixman
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::ECHO cleaning ....
::CALL make -f Makefile.win32 "CFG=release" clean
::IF ERRORLEVEL 1 GOTO ERROR

SET CFG_TYPE=release
IF %BUILD_TYPE% EQU Debug (SET CFG_TYPE=debug)


echo ATTENTION using "MMX=off" to compile cairo with 64bit
echo.
ECHO building ...
set MKDIRP="C:\Program Files (x86)\Git\bin\mkdir.exe"
echo %PATH%
CALL make.exe -f Makefile.win32 CFG=%CFG_TYPE% MMX=off MSVC_VER=%MSVC_VER%
::>%ROOTDIR%\build_pixman-%PIXMAN_VERSION%.log 2>&1
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
ECHO ========= ERROR PIXMAN

:DONE
cd %ROOTDIR%
EXIT /b %EL%
