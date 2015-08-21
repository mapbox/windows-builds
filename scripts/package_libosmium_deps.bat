@echo off
SETLOCAL
SET EL=0
ECHO ~~~~~~~~~~~~~~~~~~~ %~f0 ~~~~~~~~~~~~~~~~~~~

:: guard to make sure settings have been sourced
IF "%PKGDIR%"=="" ( echo "PKGDIR variable not set" && SET ERRORLEVEL=1 && GOTO ERROR )
IF "%ROOTDIR%"=="" ( echo "ROOTDIR variable not set" && SET ERRORLEVEL=1 && GOTO ERROR )

echo TODO also check for individual files
IF NOT EXIST %PKGDIR%\boost ( echo "no boost dir" && SET ERRORLEVEL=1 && GOTO ERROR )
IF NOT EXIST %PKGDIR%\boost\stage\lib ( echo "no boost libs dir" && SET ERRORLEVEL=1 && GOTO ERROR )
::IF NOT EXIST %PKGDIR%\OSM-binary ( echo "no osmpbf dir" && SET ERRORLEVEL=1 && GOTO ERROR )
::IF NOT EXIST %PKGDIR%\protobuf ( echo "no protobuf dir" && SET ERRORLEVEL=1 && GOTO ERROR )
IF NOT EXIST %PKGDIR%\zlib ( echo "no zlib dir" && SET ERRORLEVEL=1 && GOTO ERROR )
IF NOT EXIST %PKGDIR%\expat ( echo "no expat dir" && SET ERRORLEVEL=1 && GOTO ERROR )
IF NOT EXIST %PKGDIR%\bzip2 ( echo "no bzip dir" && SET ERRORLEVEL=1 && GOTO ERROR )
IF NOT EXIST %PKGDIR%\gdal ( echo "no gdal dir" && SET ERRORLEVEL=1 && GOTO ERROR )
IF NOT EXIST %PKGDIR%\geos ( echo "no geos dir" && SET ERRORLEVEL=1 && GOTO ERROR )
IF NOT EXIST %PKGDIR%\proj ( echo "no proj dir" && SET ERRORLEVEL=1 && GOTO ERROR )
IF NOT EXIST %PKGDIR%\sparsehash ( echo "no sparsehash dir" &&SET ERRORLEVEL=1 && GOTO ERROR )
IF NOT EXIST %PKGDIR%\wingetopt ( echo "no wingetopt dir" && SET ERRORLEVEL=1 && GOTO ERROR )

ECHO "TODO - copy only files that are really necessary"

SET SDKBASE=%PKGDIR%\libosmium-deps
SET LODEPSDIR=%SDKBASE%\libosmium-deps
ECHO packaging to %SDKBASE%

::remove previous SDK
IF EXIST %SDKBASE% ECHO deleting existing SDK dir... && ddt /Q %SDKBASE%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- boost
::boost headers
xcopy /S /Q %PKGDIR%\boost\boost\*.* %LODEPSDIR%\boost\boost\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::boost libs, TODO: copy only necessary files
xcopy /S /Q %PKGDIR%\boost\stage\lib\*.* %LODEPSDIR%\boost\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::ECHO copying ---------------- OSMPBF
::xcopy /S /Q %PKGDIR%\OSM-binary\deploy\*.* %LODEPSDIR%\osmpbf\
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR

::ECHO copying ---------------- protobuf
::xcopy /S /Q %PKGDIR%\protobuf\src\*.h %LODEPSDIR%\protobuf\include\
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR
::xcopy /S /Q %PKGDIR%\protobuf\vsprojects\%BUILDPLATFORM%\%BUILD_TYPE%\*.lib %LODEPSDIR%\protobuf\lib\
::IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- zlib
SET BT=Debug
IF "%BUILD_TYPE%"=="Release" SET BT=ReleaseWithoutAsm
xcopy /S /Q %PKGDIR%\zlib\*.h %LODEPSDIR%\zlib\include\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\zlib\contrib\vstudio\vc11\%BUILDPLATFORM%\ZlibDll%BT%\*.lib %LODEPSDIR%\zlib\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\zlib\contrib\vstudio\vc11\%BUILDPLATFORM%\ZlibDll%BT%\*.dll %LODEPSDIR%\zlib\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- expat
xcopy /S /Q %PKGDIR%\expat\lib\*.h %LODEPSDIR%\expat\include\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\expat\win32\bin\%BUILD_TYPE%\*.lib %LODEPSDIR%\expat\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\expat\win32\bin\%BUILD_TYPE%\*.dll %LODEPSDIR%\expat\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- bzip2
xcopy /S /Q %PKGDIR%\bzip2\*.h %LODEPSDIR%\bzip2\include\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\bzip2\*.lib %LODEPSDIR%\bzip2\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- libtiff
xcopy /S /Q %PKGDIR%\libtiff\libtiff\*.h %LODEPSDIR%\libtiff\include\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\libtiff\libtiff\*.lib %LODEPSDIR%\libtiff\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\libtiff\libtiff\*.dll %LODEPSDIR%\libtiff\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- jpeg
xcopy /S /Q %PKGDIR%\libjpegturbo\build\sharedlib\Release\*.dll %LODEPSDIR%\jpeg\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- gdal
xcopy /S /Q %PKGDIR%\gdal-sdk\gdal\*.* %LODEPSDIR%\gdal\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- geos
xcopy /S /Q %PKGDIR%\geos\include\*.h %LODEPSDIR%\geos\include\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\geos\build\include\geos\platform.h %LODEPSDIR%\geos\include\geos\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\geos\build\lib\%BUILD_TYPE%\geos.lib %LODEPSDIR%\geos\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\geos\build\bin\%BUILD_TYPE%\geos.dll %LODEPSDIR%\geos\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

ECHO copying ---------------- proj
xcopy /S /Q %PKGDIR%\proj\src\*.h %LODEPSDIR%\proj\include\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /S /Q %PKGDIR%\proj\src\*.lib %LODEPSDIR%\proj\lib\
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
xcopy /Q %PKGDIR%\proj\nad\epsg %LODEPSDIR%\proj\share\
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

CD %SDKBASE%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF EXIST %PKGNAME% DEL %PKGNAME%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

7z a -r -mx9 %PKGNAME% %LODEPSDIR% | %windir%\system32\FIND "ing archive"
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE


:ERROR
SET EL=%ERRORLEVEL%
ECHO ~~~~~~~~~~~~~~~~~~~ ERROR %~f0 ~~~~~~~~~~~~~~~~~~~
ECHO ERRORLEVEL^: %EL%

:DONE
ECHO ~~~~~~~~~~~~~~~~~~~ DONE %~f0 ~~~~~~~~~~~~~~~~~~~


cd %ROOTDIR%
EXIT /b %EL%
