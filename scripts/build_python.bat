@echo off
SETLOCAL
SET EL=0

echo ------ python -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

ECHO not necessary anymore
ECHO windows-builds-tmp-bin already contains Python 32bit and 64bit
GOTO DONE


cd %PKGDIR%

SET PKGNAME=win-python-%PYTHON_VERSION%-%TARGET_ARCH%.7z

::TODO
::think about how to distribute python PDBs
::the archive don't have directories within
::https://www.python.org/downloads/release/python-278/
::https://www.python.org/ftp/python/2.7.8/python-2.7.8-pdb.zip
::https://www.python.org/ftp/python/2.7.8/python-2.7.8.amd64-pdb.zip

if "%TARGET_ARCH%"=="64" (
    echo installing 64 bit python
    CALL %ROOTDIR%\scripts\download %PKGNAME%
    IF ERRORLEVEL 1 GOTO ERROR
    7z -y x %PKGNAME% -o%ROOTDIR%\tmp-bin\ | %windir%\system32\FIND "ing archive"
    IF ERRORLEVEL 1 GOTO ERROR
) ELSE  (
    echo installing 32 bit python
    CALL %ROOTDIR%\scripts\download %PKGNAME%
    IF ERRORLEVEL 1 GOTO ERROR
    7z -y x %PKGNAME% -o%ROOTDIR%\tmp-bin\ | %windir%\system32\FIND "ing archive"
    IF ERRORLEVEL 1 GOTO ERROR
)

GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR python --------------

:DONE

cd %ROOTDIR%
EXIT /b %EL%
