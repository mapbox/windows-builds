@echo off
echo ------ pixman -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download pixman-%PIXMAN_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST pixman (
  echo found extracted sources
)

if NOT EXIST pixman (
  echo extracting
  CALL bsdtar xfz pixman-%PIXMAN_VERSION%.tar.gz
  rename pixman-%PIXMAN_VERSION% pixman
  IF ERRORLEVEL 1 GOTO ERROR
)

cd pixman
IF ERRORLEVEL 1 GOTO ERROR

patch -N -p1 < %PATCHES%/pixman.diff || true

cd pixman
IF ERRORLEVEL 1 GOTO ERROR

::ECHO cleaning ....
::CALL make -f Makefile.win32 "CFG=release" clean
::IF ERRORLEVEL 1 GOTO ERROR

echo ATTENTION using "MMX=off" to compile cairo with 64bit
echo.
ECHO building ...
set MKDIRP="C:\Program Files (x86)\Git\bin\mkdir.exe"
echo %PATH%
:: upgrade make in order to work around "Interrupt/Exception caught"
if NOT EXIST .\make.exe (
    call wget ftp://ftp.equation.com/make/32/make.exe
)
CALL .\make.exe -f Makefile.win32 "CFG=release" "MMX=off"
::>%ROOTDIR%\build_pixman-%PIXMAN_VERSION%.log 2>&1
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
ECHO ========= ERROR PIXMAN

:DONE
cd %ROOTDIR%
EXIT /b %ERRORLEVEL%