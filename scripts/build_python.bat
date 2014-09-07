@echo off
SETLOCAL
SET EL=0

echo ------ python -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%

SET PKGNAME=win-python-%PYTHON_VERSION%-%TARGET_ARCH%.7z

if "%TARGET_ARCH%"=="64" (
    echo installing 64 bit python
    CALL %ROOTDIR%\scripts\download %PKGNAME%
    IF ERRORLEVEL 1 GOTO ERROR
    7z -y x %PKGNAME% -o%ROOTDIR%\tmp-bin\
    IF ERRORLEVEL 1 GOTO ERROR
) ELSE  (
    echo installing 32 bit python
    CALL %ROOTDIR%\scripts\download %PKGNAME%
    IF ERRORLEVEL 1 GOTO ERROR
    7z -y x %PKGNAME% -o%ROOTDIR%\tmp-bin\
    IF ERRORLEVEL 1 GOTO ERROR
)

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR python --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
