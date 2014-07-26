@echo off
echo ------ pixman -----

CALL bsdtar xvfz %PKGDIR%\pixman-%PIXMAN_VERSION%.tar.gz
IF ERRORLEVEL 1 GOTO ERROR

CALL rename pixman-%PIXMAN_VERSION% pixman
IF ERRORLEVEL 1 GOTO ERROR

cd pixman\pixman

ECHO cleaning ....
CALL make -f Makefile.win32 "CFG=release" clean
IF ERRORLEVEL 1 GOTO ERROR

echo ATTENTION using "MMX=off" to compile cairo with 64bit
echo.
PAUSE
ECHO building ...
::CALL make -f Makefile.win32 "CFG=release"
CALL make -f Makefile.win32 "CFG=release" "MMX=off" >%ROOTDIR%\build_pixman-%PIXMAN_VERSION%.log 2>&1
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
ECHO ========= ERROR PIXMAN

:DONE
cd %ROOTDIR%
EXIT /b %ERRORLEVEL%