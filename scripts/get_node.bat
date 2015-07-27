@echo off
SETLOCAL
SET EL=0
ECHO ------ %~f0 -----


::delete node.exe from previous runs
IF EXIST node.exe ECHO deleting existing node.exe && DEL /F node.exe
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF EXIST node.pdb ECHO deleting existing node.pdb && DEL /F node.pdb
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

IF DEFINED PREFER_LOCAL_NODE_EXE (ECHO PREFER_LOCAL_NODE_EXE %PREFER_LOCAL_NODE_EXE%) ELSE (SET PREFER_LOCAL_NODE_EXE=0)
IF %PREFER_LOCAL_NODE_EXE% EQU 0 GOTO USE_REMOTE_NODE

::prefer local node.exe
SET LOCAL_NODE_EXE=%PKGDIR%\node-v%NODE_VERSION%-%BUILDPLATFORM%\%BUILD_TYPE%\node.exe
SET LOCAL_NODE_PDB=%PKGDIR%\node-v%NODE_VERSION%-%BUILDPLATFORM%\%BUILD_TYPE%\node.pdb
IF %PREFER_LOCAL_NODE_EXE% EQU 1 IF NOT EXIST %LOCAL_NODE_EXE% ECHO local node not found && GOTO USE_REMOTE_NODE

ECHO ============= using ----LOCAL---- node.exe ==========
ECHO %LOCAL_NODE_EXE%
ECHO %LOCAL_NODE_PDB%
COPY %LOCAL_NODE_EXE%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR
IF EXIST %LOCAL_NODE_PDB% COPY %LOCAL_NODE_PDB%
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE

:USE_REMOTE_NODE
ECHO ============= using ----REMOTE---- node.exe ==========
::download custom Mapbox node.exe
::ALWAYS download in case there is another version of node.exe
::here from another build
SET ARCHPATH=
IF "%PLATFORMX%"=="x64" SET ARCHPATH=x64/
SET MBNODEURL=https://mapbox.s3.amazonaws.com/node-cpp11/v%NODE_VER%/%ARCHPATH%node.exe
ECHO downloading custom node.exe %MBNODEURL%
curl --insecure %MBNODEURL% > node.exe
IF %ERRORLEVEL% NEQ 0 GOTO ERROR

GOTO DONE


:ERROR
SET EL=%ERRORLEVEL%
echo ----------ERROR %~f0 --------------

:DONE
echo ----------DONE %~f0--------------

EXIT /b %EL%
