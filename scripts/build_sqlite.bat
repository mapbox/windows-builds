@echo off
SETLOCAL
SET EL=0

ECHO ~~~~~~~~~~~~~~~~~~~ %~f0 ~~~~~~~~~~~~~~~~~~~

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download sqlite-autoconf-%SQLITE_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

if EXIST sqlite (
  echo found extracted sources
)

if NOT EXIST sqlite (
  echo extracting
  CALL bsdtar xfz sqlite-autoconf-%SQLITE_VERSION%.tar.gz
  rename sqlite-autoconf-%SQLITE_VERSION% sqlite
  IF ERRORLEVEL 1 GOTO ERROR
)

cd sqlite
IF ERRORLEVEL 1 GOTO ERROR

IF %BUILD_TYPE% EQU Release (
	cl /MD /Zi /Fdsqlite3.pdb /nologo /EHsc /D NDEBUG /D SQLITE_ENABLE_RTREE sqlite3.c /c
	IF ERRORLEVEL 1 GOTO ERROR
) ELSE (
	cl /DEBUG /MDd /Zi /Fdsqlite3.pdb /nologo /EHsc /D _DEBUG /D SQLITE_ENABLE_RTREE sqlite3.c /c
	IF ERRORLEVEL 1 GOTO ERROR
)

lib sqlite3.obj
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
ECHO ~~~~~~~~~~~~~~~~~~~ ERROR %~f0 ~~~~~~~~~~~~~~~~~~~
ECHO ERRORLEVEL^: %EL%

:DONE
ECHO ~~~~~~~~~~~~~~~~~~~ DONE %~f0 ~~~~~~~~~~~~~~~~~~~

cd %ROOTDIR%
EXIT /b %EL%
