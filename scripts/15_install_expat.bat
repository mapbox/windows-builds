@echo off
echo ------ expat -----
echo executing binary installer

CALL %PKGDIR%\expat-win32bin-%EXPAT_VERSION%.exe
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR expat --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%