@echo off
title Opening Loan 300
color a
cd data

:Restart
set /a debug=0
set today=%DATE:~4,2%/%DATE:~7,2%/%DATE:~10,4%
::
:: Yesterday's date not neeeded
::
mode con: cols=60 lines=15
set /a totalTills=0
set /a count=0
::set /a start=0
set /a num=0
set /a save=1
set /a safety=0
set /a warning=0
::set /a totalLines=0
set /p version=<version.txt

:: Checks if in proper directory
if not exist "..\%~n0%~x0" (
set /a warning = 5
goto Error
)

:: Checks logTo.txt to see where you would like to log data
if exist logTo.txt set /p logTo=<logTo.txt

::Checks latest version
PUSHD %logTo%\Cash Office Scripts\data\
if not exist version.txt goto SkipUpdate
set /p latestVer=<version.txt
if NOT %latestVer%==%version% (
POPD
cls
echo A new update is avaliable
echo Press anything to update...
pause >nul
call "%~dp0/Updater.bat"
exit
)

:SkipUpdate
POPD

:: Detects total number of tills in scannedTills
for /F %%N in ('find /C "Till" ^< "scannedTills.txt"') do set totalTills=%%N
if %totalTills%==0 (
set /a warning = 3
goto Error
)

:Warning
color a
cls
echo Opening Loan 300 V %version%
echo Made by David Cannon
pause
color c
mode con: cols=120 lines=15
PUSHD %logTo%
echo %username% %date% %time% %version% Opened Opening Loan 300 Script (Warning Screen)>> Logs/%date:~10,4%%date:~4,2%%date:~7,2%.txt
POPD
cls
echo IMPORTANT: Please make sure you have the last loan till you've done selected in Retalix before starting the program
echo You MUST be using chrome for the script to work
echo Avoid touching the keyboard or mouse while the program is running unless attempting to close it
echo If the program starts messing things up you can immediately press ALT+F4 to close out of chrome to prevent errors
echo Please report issues to David Cannon
pause
cls

:Start
mode con: cols=60 lines=15
color a
cls
echo How many loan tills still need to be done? (%totalTills% total)
echo You can also simply press enter to default to %totalTills%
set /p num=
set /a num=%num%
:: ^^ This basically makes it so that if you enter ANY letters it'll run it as if you typed nothing

if %num% GTR %totalTills% (
cls
echo WARNING: Tills entered is greater than total tills
timeout 1 /nobreak >nul
echo Press anything to ignore...
pause>nul
set /a totalTills=%num%
)

if %num%==0 set /a num=%totalTills%
set /a count=%totalTills%-%num%
if %num% LSS 0 set /a count=%totalTills%+%num%

:: ^^ Allows you to say how many have currently been done using negatives
echo Press anything to start the script...
pause >nul

PUSHD %logTo%
echo %username% %date% %time:~0,5% %version% Script started>> Logs/%date:~10,4%%date:~4,2%%date:~7,2%.txt
POPD

:: Hides program
nircmd.exe win min process cmd.exe
nircmd.exe win min process explorer.exe
:: Maximizes chrome
nircmd.exe win max process chrome.exe
nircmd.exe win focus process chrome.exe
nircmd.exe wait 10

:: Checking date
nircmd.exe setcursor 625 315
nircmd.exe sendmouse left click
nircmd.exe sendmouse left click
nircmd.exe wait 10
::Copies current date
nircmd.exe sendkeypress ctrl+a
nircmd.exe wait 10
nircmd.exe sendkeypress ctrl+c
nircmd.exe wait 10
nircmd.exe clipboard writefile "data.txt"
set /p setDate=<data.txt

if "%today%"=="%setDate%" goto Loop
cls

:: Shows CMD to ask
nircmd.exe win activate process cmd.exe
nircmd.exe win focus process cmd.exe

echo WARNING: The date you are altering is not set to today
echo Opening Loans should be set for the current date
timeout 1 /nobreak >nul
echo Press any key to ignore and run script anyways...
pause >nul

:: Hides program
nircmd.exe win min process cmd.exe
nircmd.exe win min process explorer.exe
:: Maximizes chrome
nircmd.exe win max process chrome.exe
nircmd.exe win focus process chrome.exe
nircmd.exe wait 10

:Loop
:: Clicks on the till
nircmd.exe setcursor 725 440
nircmd.exe sendmouse left click
timeout 0 /nobreak

:: Scrolls down a till
nircmd.exe sendmouse wheel -120
nircmd.exe wait 10

::Copies current Till
nircmd.exe sendkeypress ctrl+a
nircmd.exe wait 10
nircmd.exe sendkeypress ctrl+c
nircmd.exe wait 10
nircmd.exe clipboard writefile "data.txt"
set /p currentTill=<data.txt

:: Checks if current Till is banned from being touched by the program
>nul find "%currentTill%" bannedTills.txt && goto Loop
find /c "Till9" data.txt && (
set /a warning=1
goto Error
)
nircmd.exe clipboard set "Opening Loan (%today%)"

:: Checks if a Till was found, if no till is found the program likely finished
find /c "Till" data.txt && ( goto Skip )

:: Shows CMD
nircmd.exe win activate process cmd.exe
nircmd.exe win focus process cmd.exe

cls
echo Till not found
echo Click any button to retry, otherwise close the program...
pause >nul
set /a count=%count%-1
goto Retry

:Skip
:: Clicks on ref
nircmd.exe setcursor 1050 440
nircmd.exe sendmouse left click
nircmd.exe sendmouse left click
nircmd.exe wait 10
nircmd.exe sendkeypress ctrl+v
timeout 1 /nobreak

::Clicks on add
nircmd.exe setcursor 1200 440
nircmd.exe sendmouse left click

timeout 0 /nobreak

set /a attempts=0
:Retry2
if %attempts% GTR 4 (
set /a warning = 4
goto Error
)

:: Adds entered value to clipboard
nircmd.exe clipboard set "300"
nircmd.exe wait 10

::Clicks on money amount
nircmd.exe setcursor 810 710
nircmd.exe sendmouse left click
nircmd.exe sendmouse left click
timeout 0 /nobreak
nircmd.exe sendkeypress ctrl+v
timeout 0 /nobreak

nircmd.exe clipboard clear
echo 0 > data.txt
::Double-checks that value went through
nircmd.exe sendkeypress ctrl+a
nircmd.exe sendkeypress ctrl+c
nircmd.exe wait 5
nircmd.exe clipboard writefile "data.txt"
set /p value=<data.txt
if NOT %value%=="300" (
timeout 1 /nobreak >nul
set /a attempts=%attempts%+1
goto Retry2
)

:: Shows CMD
nircmd.exe win activate process cmd.exe
nircmd.exe win focus process cmd.exe

PUSHD %logTo%
echo %username% %date% %time:~0,5% %version% Added $300 to %currentTill%>> Logs/%date:~10,4%%date:~4,2%%date:~7,2%.txt
POPD
cls
echo Confirm all information looks correct
timeout 2
if %safety%==1 timeout 4

:: Hides program
nircmd.exe win min process cmd.exe
nircmd.exe win min process explorer.exe
:: Maximizes chrome
nircmd.exe win max process chrome.exe
nircmd.exe win focus process chrome.exe
nircmd.exe wait 10

::Clicks on save button
nircmd.exe setcursor 1770 470
if %save%==1 nircmd.exe sendmouse left click
if %save%==0 pause
timeout 0 /nobreak
if %safety%==1 timeout 6 /nobreak

::Confirms save
nircmd.exe setcursor 920 620
nircmd.exe sendmouse left click
timeout 3 /nobreak

:Retry
:: Don't print
nircmd.exe setcursor 1000 620
nircmd.exe sendmouse left click
timeout 1 /nobreak
if %safety%==1 timeout 4 /nobreak

set /a count=%count%+1
if %count% GEQ %totalTills% (
PUSHD %logTo%
echo %username% %date% %time:~0,5% %version% Script successfully completed>> Logs/%date:~10,4%%date:~4,2%%date:~7,2%.txt
POPD
exit
)

::Loops program
goto Loop

:Error
color c
mode con: cols=120 lines=20

:: Shows CMD to ask
nircmd.exe win activate process cmd.exe
nircmd.exe win focus process cmd.exe

PUSHD %logTo%
echo %username% %date% %version% Error %warning%>> log.txt
cls
POPD

if %warning%==1 echo Script cannot run with SCO
if %warning%==3 echo data/scannedTills contains no tills, please run scanTills.bat to scan all Tills
if %warning%==4 (
echo The script failed to validate money amount confirm everything is okay to continue...
pause
set /a attempts=0
goto Retry2
)
if %warning%==5 (
echo Please make a copy of "Cash Office Scripts" to your desktop
echo You can do this manually or by running updater.bat
echo Do not run this script in the shared folder
)

echo Press anything to close script...
pause >nul
exit