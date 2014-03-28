@echo off
echo ------ libpq -----

CALL bsdtar xvfz "%PKGDIR%\postgresql-%POSTGRESQL_VERSION%.tar.gz"
IF ERRORLEVEL 1 GOTO ERROR

rename postgresql-%POSTGRESQL_VERSION% postgresql
IF ERRORLEVEL 1 GOTO ERROR
cd postgresql\src

CALL nmake /f win32.mak
IF ERRORLEVEL 1 GOTO ERROR

::Note: The following errors occurred uring this process:
::.\Release\libpq.dll.manifest : general error c1010070: Failed to load and parse the manifest. The system cannot find the file specified.
::NMAKE : fatal error U1077: '"C:\Program Files (x86)\Windows Kits\8.0\bin\x86\mt.EXE"' : return code '0x1f' 
::However libpq.lib was successfully built.


:ERROR

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%