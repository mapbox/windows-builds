@echo off
echo ------- JPEG --------


powershell scripts\deletedir -dir2del "%ROOTDIR%\jpeg"
IF ERRORLEVEL 1 GOTO ERROR
pause


echo If you receive an error about not finding Win32.mak, you may need to do something like:
echo "set INCLUDE=%include%;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Include"

SET INCLUDE=%include%;C:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Include

unzip %PKGDIR%\jpegsr%JPEG_VERSION%.zip
IF ERRORLEVEL 1 GOTO ERROR
echo JPEG unzipped

rename jpeg-%JPEG_VERSION% jpeg
IF ERRORLEVEL 1 GOTO ERROR

cd jpeg 
echo y | call copy jconfig.txt jconfig.h
IF ERRORLEVEL 1 GOTO ERROR

::NMAKE Options: http://msdn.microsoft.com/en-us/library/afyyse50%28v=vs.120%29.aspx
::NMAKE platform (32/64) used, depends on which Developer command prompt was opened
nmake /A /F Makefile.vc nodebug=1
IF ERRORLEVEL 1 GOTO ERROR



:ERROR

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%
