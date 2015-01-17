@echo off
SETLOCAL
SET EL=0
echo ------ libosmium -----
:: guard to make sure settings have been sourced
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

cd %ROOTDIR%\scripts

CALL build_boost.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_osmpbf.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_protobuf.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_zlib.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_expat.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_bzip2.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_proj4.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_geos.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_gdal.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL package_gdal.bat libosmium
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_sparsehash.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

CALL build_wingetopt.bat
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


GOTO DONE

:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR libosmium --------------

:DONE
echo ----------DONE libosmium --------------

cd %ROOTDIR%
EXIT /b %EL%
