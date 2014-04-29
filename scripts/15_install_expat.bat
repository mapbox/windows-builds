@echo off
echo ------ expat -----
echo executing binary installer
echo.
echo !!!!!
echo Install into directory without whitespaces!!!
echo e.g. C:\Expat2.1.0

CALL %PKGDIR%\expat-win32bin-%EXPAT_VERSION%.exe
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR expat --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%