@echo off
echo Toto je instalace programu TrEd

choice /C:AN Chcete pokracovat

if errorlevel 2 goto End

echo Instaluje se TrEd
rem Instalacni skript pro TrEd

set PERL=c:\perl
set TRED=c:\tred

rem if exist %PERL%\nul goto PerlTk
choice /C:AN Chcete nainstalovat ActiveState Perl
if errorlevel 2 goto PerlTk

if "%OS%" == "Windows_NT" goto Perl

if exist %WINDIR%\system\comcat.dll goto Perl

echo Vas pocitac zrejme neobsahuje DCOM potrebnou k instalaci Perlu.
echo Instaluje se DCOM pro Windows 95
echo Pokud pouzivate Windows 98 nebo NT nebo 2000, DCOM neinstalujte!

start /W dcom95.exe

echo Nyni zrestartujte pocitac a spustte instalaci znovu.

goto End

:Perl

echo 1. Instaluje se Perl

start /W APi522e.exe

rem goto PerlTk

echo Instalace dokoncena, restartujte pocitac
echo a pak znovu spustte tento program (setup.bat)
echo a instalace se dokonci

set PATH=%PERL%\bin;%PATH%
goto End

:PerlTk

choice /C:AN Chcete instalovat ci upgradovat PerlTk
if errorlevel 2 goto Tred

rem if exist %PERL%\bin\widget.bat goto Tred

echo 2. Instaluje/Aktualizuje se PerlTk
echo Pokus o odstraneni stavajici verze
call ppm.bat remove Tk
echo Instalace aktualni verze
cd PerlTk-cz
call ppm.bat install Tk.ppd
cd ..
:Tred
if exist %Tred%\tred.bat goto Upgrade

set PATH=%PERL%\bin;%PATH%

echo 3. Instaluje se TrEd
mkdir %TRED%
xcopy /E Tred %TRED%\

:Normal

xcopy tred.mac %TRED%\tredlib\

cd %TRED%
echo Creating %TRED%\tred.bat and %TRED%\btred.bat
copy pl2bat+%TRED%\tred+pl2batend %TRED%\tred.bat
copy pl2bat+%TRED%\btred+pl2batend %TRED%\btred.bat

start /W %PERL%\bin\perl trinstall.pl

echo -------------------------------------------
echo Instalace je dokoncena.
echo Zkontrolujte, ze vam na plose pribyla ikona
echo s obrazkem sileneho zvirete:)
goto End

:Upgrade

choice /C:AN TrEd je jiz nainstalovan. Chete provest aktualizaci? 
if errorlevel 2 goto EndEcho

echo 3. Upgraduje se TrEd
choice /C:AN Chcete zachovat vas osobni konfiguracni soubor
if errorlevel 1 goto SaveUpg
xcopy /E /R Tred %TRED%\ 
goto Nosav
:SaveUpg
if exist %TRED%\tredlib\tredrc.sav del %TRED%\tredlib\tredrc.sav
rename %TRED%\tredlib\tredrc tredrc.sav

xcopy /E /R Tred %TRED%\ 

if not exist %TRED%\tredlib\tredrc.sav goto Nosav
del  %TRED%\tredlib\tredrc
rename %TRED%\tredlib\tredrc.sav tredrc

:Nosav
xcopy tred.mac %TRED%\tredlib\

cd %TRED%
echo Creating %TRED%\tred.bat and %TRED%\btred.bat
copy pl2bat+%TRED%\tred+pl2batend %TRED%\tred.bat
copy pl2bat+%TRED%\btred+pl2batend %TRED%\btred.bat


echo -------------------------------------------
echo Aktualizace je dokoncena.
goto End

:EndEcho
echo TrEd je jiz nainstalovan. Chcete-li jej instalovat znovu,
echo nejprve odstrante celou slozku c:\tred a spustte znovu
echo tento program (setup.bat)
:End
