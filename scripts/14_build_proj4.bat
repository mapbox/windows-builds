@echo off
echo ------ proj4 -----


powershell scripts\deletedir -dir2del "%ROOTDIR%\proj"
IF ERRORLEVEL 1 GOTO ERROR
PAUSE


CALL bsdtar xfz %PKGDIR%\proj-%PROJ_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

CALL rename proj-%PROJ_VERSION% proj
IF ERRORLEVEL 1 GOTO ERROR

cd proj/nad

CALL unzip -o ../../packages/proj-datumgrid-%PROJ_GRIDS_VERSION%.zip
IF ERRORLEVEL 1 GOTO ERROR

cd ..
ECHO cleaning ....
CALL nmake /F Makefile.vc clean
IF ERRORLEVEL 1 GOTO ERROR


ECHO building ....
CALL nmake /A /F Makefile.vc
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR proj4 --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%