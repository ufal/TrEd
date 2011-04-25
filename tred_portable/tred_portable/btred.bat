@echo off

REM Strawberry perl config
set drive=%~dp0
set drivep=%drive%
If $#\#$==$#%drive:~-1%#$ set drivep=%drive:~0,-1%
echo %drivep%
set PATH=%drivep%\..\perl-5.12\perl\site\bin;%drivep%\..\perl-5.12\perl\bin;%drivep%\..\perl-5.12\c\bin;%PATH%
set TERM=dumb

REM TrEd config
set PATH=%drivep%\bin;%drivep%\dependencies\bin;%PATH%
set PERL5LIB=%drivep%\dependencies\lib\perl5;%drivep%\dependencies\lib\perl5\MSWin32-x86-multi-thread;%PERL5LIB%
set TRED_DIR=%TEMP%

if "%OS%" == "Windows_NT" goto WinNT
%drivep%\..\perl-5.12\perl\bin\perl.exe %drivep%\btred %1 %2 %3 %4 %5 %6 %7 %8 %9
goto end
:WinNT
"%drivep%\..\perl-5.12\perl\bin\perl.exe" "%drivep%\btred" %*
:end
