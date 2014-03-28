@echo off
echo ------ proj4 -----

CALL bsdtar xfz %PKGDIR%\proj-%PROJ_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

CALL rename proj-%PROJ_VERSION% proj
IF ERRORLEVEL 1 GOTO ERROR

cd proj/nad

CALL unzip -o ../../packages/proj-datumgrid-%PROJ_GRIDS_VERSION%.zip
IF ERRORLEVEL 1 GOTO ERROR

cd ..
CALL nmake /f Makefile.vc
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR proj4 --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%