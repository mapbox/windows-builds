@echo off
SETLOCAL
SET EL=0
echo ------ bzip2 -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download bzip2-%bzip2_VERSION%.tar.gz
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

if EXIST bzip2 (
  echo found extracted sources
)

if NOT EXIST "bzip2" (
  echo extracting
  CALL bsdtar xfz bzip2-%bzip2_VERSION%.tar.gz
  IF %ERRORLEVEL% NEQ 0 GOTO ERROR
  rename bzip2-%bzip2_VERSION% bzip2
  IF %ERRORLEVEL% NEQ 0 GOTO ERROR
)

cd bzip2
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

nmake /f makefile.msc
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:ERROR
echo ------ ERROR bzip2 -----
SET EL=%ERRORLEVEL%


:DONE
echo ------ DONE bzip2 -----
cd %ROOTDIR%
EXIT /b %EL%
