@echo off
echo DOWNLOADING

cd %PKGDIR%

curl http://iweb.dl.sourceforge.net/project/boost/boost/1.%BOOST_VERSION%.0/boost_1_%BOOST_VERSION%_0.tar.gz -O
IF ERRORLEVEL 1 GOTO ERROR

::If BOOST and EXPAT don't seem to download properly by CURL, check the file you get. It probably contains
::an error/redirect, telling you to visit their project download URLs like these to select a mirror:
::http://sourceforge.net/projects/boost/files/boost/1.49.0/boost_1_49_0.tar.gz/download
::http://downloads.sourceforge.net/project/expat/expat_win32/2.1.0/expat-win32bin-2.1.0.exe

:ERROR

cd %ROOTDIR%
EXIT /b %ERRORLEVEL%