@echo off
:fetch
::
SETLOCAL
IF "%~1"=="" ( echo "error downloading: please pass the basename of a file to download" && GOTO:EOF )

SET DOWNLOAD_CMD=curl -s -S -f -O -L -k --retry 3
set S3_BASE=http://mapnik.s3.amazonaws.com/deps
set ARG=%~1
set FULL_DOWNLOAD=%S3_BASE%/%ARG%
set BASENAME=%ARG%
if not "%ARG%" == "%ARG:http=%" (
    set FULL_DOWNLOAD=%ARG%
    for /F %%i in ("%ARG%") do set BASENAME=%%~ni%%~xi
)
echo "checking for %BASENAME%"
IF EXIST "%BASENAME%" (
  echo "using cached %~1"
)
IF NOT EXIST "%BASENAME%" (
  echo "downloading %FULL_DOWNLOAD%"
  %DOWNLOAD_CMD% %FULL_DOWNLOAD%
)
GOTO:EOF