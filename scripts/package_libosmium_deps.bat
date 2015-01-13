@echo off
SETLOCAL
SET EL=0
echo ============ packing libosmium deps =========

:: guard to make sure settings have been sourced
IF "%PKGDIR%"=="" ( echo "PKGDIR variable not set" && GOTO DONE )
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && GOTO DONE )

echo TODO also check for individual files
IF NOT EXIST %PKGDIR%\boost ( echo "no boost dir" && GOTO DONE )
IF NOT EXIST %PKGDIR%\boost\stage\lib ( echo "no boost libs dir" && GOTO DONE )
IF NOT EXIST %PKGDIR%\OSM-binary ( echo "no osmpbf dir" && GOTO DONE )
IF NOT EXIST %PKGDIR%\protobuf ( echo "no protobuf dir" && GOTO DONE )
IF NOT EXIST %PKGDIR%\zlib ( echo "no zlib dir" && GOTO DONE )
IF NOT EXIST %PKGDIR%\expat ( echo "no expat dir" && GOTO DONE )
IF NOT EXIST %PKGDIR%\bzip2 ( echo "no bzip dir" && GOTO DONE )
IF NOT EXIST %PKGDIR%\gdal ( echo "no gdal dir" && GOTO DONE )
IF NOT EXIST %PKGDIR%\geos ( echo "no geos dir" && GOTO DONE )
IF NOT EXIST %PKGDIR%\proj ( echo "no proj dir" && GOTO DONE )
IF NOT EXIST %PKGDIR%\sparsehash ( echo "no sparsehash dir" && GOTO DONE )
IF NOT EXIST %PKGDIR%\wingetopt ( echo "no wingetopt dir" && GOTO DONE )

ECHO "TODO - copy only files that are really necessary"

SET SDKBASE=%PKGDIR%\libosmium-deps
SET LODEPSDIR=%SDKBASE%\libosmium-deps
ECHO packaging to %SDKBASE%

::remove previous SDK
ddt /Q %SDKBASE%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- boost
::boost headers
xcopy /S /Q %PKGDIR%\boost\boost\*.* %LODEPSDIR%\boost\boost\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::boost libs, TODO: copy only necessary files
xcopy /S /Q %PKGDIR%\boost\stage\lib\*.* %LODEPSDIR%\boost\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- OSMPBF
xcopy /S /Q %PKGDIR%\OSM-binary\deploy\*.* %LODEPSDIR%\osmpbf\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- protobuf
xcopy /S /Q %PKGDIR%\protobuf\src\*.h %LODEPSDIR%\protobuf\include\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\protobuf\vsprojects\%BUILDPLATFORM%\%BUILD_TYPE%\*.lib %LODEPSDIR%\protobuf\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- zlib
xcopy /S /Q %PKGDIR%\zlib\*.h %LODEPSDIR%\zlib\include\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\zlib\contrib\vstudio\vc10\%BUILDPLATFORM%\ZlibDll%BUILD_TYPE%\*.lib %LODEPSDIR%\zlib\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- expat
xcopy /S /Q %PKGDIR%\expat\lib\*.h %LODEPSDIR%\expat\include\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\expat\win32\bin\%BUILD_TYPE%\*.lib %LODEPSDIR%\expat\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- bzip2
xcopy /S /Q %PKGDIR%\bzip2\*.h %LODEPSDIR%\bzip2\include\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\bzip2\*.lib %LODEPSDIR%\bzip2\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- gdal
xcopy /S /Q %PKGDIR%\gdal-sdk\gdal\*.* %LODEPSDIR%\gdal\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- geos
xcopy /S /Q %PKGDIR%\geos\include\*.h %LODEPSDIR%\geos\include\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\geos\src\*.lib %LODEPSDIR%\geos\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- proj
xcopy /S /Q %PKGDIR%\proj\src\*.h %LODEPSDIR%\proj\include\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\proj\src\*.lib %LODEPSDIR%\proj\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- sparsehash
xcopy /S /Q %PKGDIR%\sparsehash\src\*.h %LODEPSDIR%\sparsehash\include\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
copy %PKGDIR%\sparsehash\src\google\sparsetable %LODEPSDIR%\sparsehash\include\google\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
copy %PKGDIR%\sparsehash\src\sparsehash\sparsetable %LODEPSDIR%\sparsehash\include\sparsehash\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- wingetopt
xcopy /S /Q %PKGDIR%\wingetopt\deploy\*.* %LODEPSDIR%\wingetopt\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR


::create zip
if %TARGET_ARCH% EQU 32 (
  SET ARCH=x86
) ELSE (
  SET ARCH=x64
)

SET PKGNAME=libosmium-deps-win-%TOOLS_VERSION%-%ARCH%.7z
ECHO packaging to
ECHO %SDKBASE%\%PKGNAME% ....

CD %LODEPSDIR%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF EXIST %PKGNAME% DEL %PKGNAME%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

7z a -r -mx9 ..\%PKGNAME% > NUL
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE


:ERROR
SET EL=%ERRORLEVEL%
echo ------------ ERROR packaging libosmium deps ------

:DONE
echo ============ DONE packing libosmium deps =========


cd %ROOTDIR%
EXIT /b %EL%
