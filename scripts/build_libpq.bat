@echo off
SETLOCAL
SET EL=0
echo ------ libpq -----

:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%
CALL %ROOTDIR%\scripts\download postgresql-%POSTGRESQL_VERSION%.tar.bz2
IF ERRORLEVEL 1 GOTO ERROR

if EXIST postgresql (
  echo found extracted sources
)

if NOT EXIST postgresql (
  echo extracting
  CALL bsdtar xfz postgresql-%POSTGRESQL_VERSION%.tar.bz2
  rename postgresql-%POSTGRESQL_VERSION% postgresql
  IF ERRORLEVEL 1 GOTO ERROR
)


echo If you receive an error about not finding Win32.mak, you may need to do something like:
echo "set INCLUDE=%include%;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Include"
echo.

echo Error:
echo "libpq.lib(dirmod.obj) : error LNK2019: unresolved external symbol _pstrdup referenced in function _pgfnames"
echo "libpq.lib(dirmod.obj) : error LNK2019: unresolved external symbol _repalloc referenced in function _pgfnames"
echo "libpq.lib(dirmod.obj) : error LNK2019: unresolved external symbol _palloc referenced in function _pgfnames"
echo "libpq.lib(dirmod.obj) : error LNK2019: unresolved external symbol _pfree referenced in function _pgfnames_cleanup"
echo.
echo "apply patch http://postgresql.1045698.n5.nabble.com/Can-not-compile-libpq-version-9-3-td5770158.html"
echo "to src/interfaces/libpq/win32.mak"
echo.

::SET INCLUDE=%include%;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Include

::http://ftp.postgresql.org/pub/source/
::http://www.postgresql.org/docs/9.2/static/install-windows.html

cd postgresql
IF ERRORLEVEL 1 GOTO ERROR

patch -N -p1 < %PATCHES%/postgres.diff
::IF ERRORLEVEL 1 GOTO ERROR

cd src
IF ERRORLEVEL 1 GOTO ERROR

:: !! http://www.postgresql.org/docs/9.0/static/install-windows-libpq.html
::NMAKE Options: http://msdn.microsoft.com/en-us/library/afyyse50%28v=vs.120%29.aspx
::NMAKE platform (32/64) used, depends on which Developer command prompt was opened

::echo cleaning ...
::CALL nmake /F win32.mak clean

echo building ...

IF %BUILDPLATFORM% EQU x64 (
    CALL nmake /A /F win32.mak CPU=AMD64 MSVC_VER=%MSVC_VER%
) ELSE (
    CALL nmake /A /F win32.mak    
)
IF ERRORLEVEL 1 GOTO ERROR

::>%ROOTDIR%\build_libpg-%POSTGRESQL_VERSION%.log 2>&1

:: 2014
::..\..\port\chklocale.c(214): error C2037: left of 'lc_codepage' specifies undefined struct/union '__crt_locale_data'

::Note: The following errors occurred uring this process:
::.\Release\libpq.dll.manifest : general error c1010070: Failed to load and parse the manifest. The system cannot find the file specified.
::NMAKE : fatal error U1077: '"C:\Program Files (x86)\Windows Kits\8.0\bin\x86\mt.EXE"' : return code '0x1f' 
::However libpq.lib was successfully built.

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
ECHO ===== ERROR building libpq

:DONE

cd %ROOTDIR%
EXIT /b %EL%
