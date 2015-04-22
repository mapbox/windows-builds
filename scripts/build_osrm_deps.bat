@echo off
SETLOCAL
SET EL=0
echo ------ osrm DEPS -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %ROOTDIR%\scripts

CALL build_bzip2.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_zlib.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_expat.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_lua.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_wingetopt.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_protobuf-%PROTOBUF_VERSION%.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_osmpbf.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_icu.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_python.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_boost.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR osrm DEPS --------------

:DONE
echo ----------DONE osrm DEPS --------------

cd %ROOTDIR%
EXIT /b %EL%
