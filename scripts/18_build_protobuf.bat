echo off
echo ------ protobuf -----

CALL unzip %PKGDIR%\protobuf-%PROTOBUF_VERSION%.zip
IF ERRORLEVEL 1 GOTO ERROR

CALL rename protobuf-%PROTOBUF_VERSION% protobuf
IF ERRORLEVEL 1 GOTO ERROR

cd protobuf\vsprojects

::vcupgrade libprotobuf-lite.vcproj
::vcupgrade libprotobuf.vcproj
::vcupgrade protoc.vcproj
::msbuild libprotobuf-lite.vcxproj /p:Configuration="Release" /p:Platform=Win32
::msbuild libprotobuf.vcxproj /p:Configuration="Release" /p:Platform=Win32
:: fails linking so I used binary from google code
::msbuild protoc.vcxproj /p:Configuration="Release" /p:Platform=Win32

ECHO upgrading solution
CALL devenv.exe /upgrade protobuf.sln
IF ERRORLEVEL 1 GOTO ERROR

echo.
echo APPLY PATCH to src/google/protobuf/stubs/common.h
echo https://code.google.com/p/protobuf/issues/detail?id=531
echo.
pause

ECHO extracting includes ...
CALL extract_includes.bat
IF ERRORLEVEL 1 GOTO ERROR

ECHO building ...
CALL msbuild protobuf.sln /p:Configuration="Release" /p:Platform=Win32
IF ERRORLEVEL 1 GOTO ERROR


CALL extract_includes.bat
IF ERRORLEVEL 1 GOTO ERROR

GOTO DONE

:ERROR
echo ----------ERROR protobuf --------------

:DONE

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%