@echo off
echo ------ libpq -----

echo If you receive an error about not finding Win32.mak, you may need to do something like:
echo "set INCLUDE=%include%;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Include"

SET INCLUDE=%include%;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Include


::http://ftp.postgresql.org/pub/source/
::http://www.postgresql.org/docs/9.2/static/install-windows.html

CALL bsdtar xvfz "%PKGDIR%\postgresql-%POSTGRESQL_VERSION%.tar.gz"
IF ERRORLEVEL 1 GOTO ERROR

rename postgresql-%POSTGRESQL_VERSION% postgresql
IF ERRORLEVEL 1 GOTO ERROR
cd postgresql\src

echo building ...
:: !! http://www.postgresql.org/docs/9.0/static/install-windows-libpq.html
::NMAKE Options: http://msdn.microsoft.com/en-us/library/afyyse50%28v=vs.120%29.aspx
::NMAKE platform (32/64) used, depends on which Developer command prompt was opened
IF %BUILDPLATFORM% EQU x64 (CALL nmake /A /B /F win32.mak CPU=AMD64) ELSE (CALL nmake /A /B /F win32.mak)
IF ERRORLEVEL 1 GOTO ERROR

::Note: The following errors occurred uring this process:
::.\Release\libpq.dll.manifest : general error c1010070: Failed to load and parse the manifest. The system cannot find the file specified.
::NMAKE : fatal error U1077: '"C:\Program Files (x86)\Windows Kits\8.0\bin\x86\mt.EXE"' : return code '0x1f' 
::However libpq.lib was successfully built.


:ERROR
ECHO ===== ERROR building libpq

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%