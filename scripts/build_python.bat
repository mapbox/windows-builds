@echo off
echo ------ python -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %PKGDIR%

if "%TARGET_ARCH%"=="64" (
    CALL %ROOTDIR%\scripts\download python-%PYTHON_VERSION%.amd64.msi
    IF ERRORLEVEL 1 GOTO ERROR
    msiexec /i python-%PYTHON_VERSION%.amd64.msi /qn
    IF ERRORLEVEL 1 GOTO ERROR
) ELSE  (
    CALL %ROOTDIR%\scripts\download python-%PYTHON_VERSION%.msi
    IF ERRORLEVEL 1 GOTO ERROR
    msiexec /i python-%PYTHON_VERSION%.msi /qn
    IF ERRORLEVEL 1 GOTO ERROR
)

GOTO DONE

:ERROR
echo ----------ERROR python --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%