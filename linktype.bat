@echo off


::for /f %%G in ('dir /o:d /t:w *.java ^| find /n /v "~~~"') do echo %%G

::for /f %%G in ('dir /s *.lib ^| dumpbin /DIRECTIVES ^| %windir%\system32\find /i "LIBCMT"') do echo %%G

::For /R %%G in (*.lib) do (
::	dumpbin /DIRECTIVES %%G | %windir%\system32\find /i "LIBCMT" | echo %%G
::)

powershell Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -Force
IF "%1" EQU "" (
  powershell %~dp0\linktype.ps1 %~dp0
) ELSE (
  ECHO %1
  powershell %~dp0\linktype.ps1 %1%
)