@echo off
title Opening Loan 300
color a
set /a debug=1
set today=%DATE:~4,2%/%DATE:~7,2%/%DATE:~10,4%
mode con: cols=60 lines=15
set /a totalTills=18
set /a safety=0
set /a count=0
set /a num=0

:Warning
cls
echo Opening Loan 300 V 1.0
echo Made by David Cannon
pause
color c
mode con: cols=120 lines=15
cls
echo You MUST be using chrome for the script to work
echo Please make sure you have the last loan till you've done selected in Retalix before starting the program
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
if %num% GTR %totalTills% set /a num=%totalTills%
:: This prevents errors ^^
if %num%==0 set /a num=%totalTills%
set /a count=%totalTills%-%num%
if %num% LSS 0 set /a count=%totalTills%-(%totalTills%+%num%)
:: ^^ Allows you to say how many have currently been done using negatives
echo Press anything to start the script...
pause >nul
timeout 1 /nobreak
nircmd.exe win min process cmd.exe
nircmd.exe win min process explorer.exe

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
nircmd.exe clipboard writefile "lasttill.txt"
set /p currentTill=<lasttill.txt
if "%currentTill%"=="Till213" goto Loop
if "%currentTill%"=="Till214" goto Loop
if "%currentTill%"=="Till215" goto Loop
find /c "Till9" lasttill.txt && ( goto Warning )
nircmd.exe clipboard set "Opening Loan (%today%)"

:: Checks if a Till was found, if no till is found the program likely finished
find /c "Till" lasttill.txt && ( goto Skip )
cls
echo Till not found, click any button if everything is okay otherwise close the program.
pause

:Skip
:: Clicks on ref
nircmd.exe setcursor 1050 440
nircmd.exe sendmouse left click
nircmd.exe sendmouse left click
nircmd.exe wait 300
nircmd.exe sendkeypress ctrl+v
timeout 1 /nobreak

::Clicks on add
nircmd.exe setcursor 1200 440
nircmd.exe sendmouse left click
:: GIVES TIME TO LOAD
timeout 3 /nobreak

::Clicks on money amount
nircmd.exe setcursor 810 710
nircmd.exe sendmouse left click
nircmd.exe sendmouse left click
timeout 0 /nobreak
nircmd.exe sendkey 3 press
nircmd.exe sendkey 0 press
nircmd.exe sendkey 0 press
nircmd.exe wait 10
nircmd.exe win activate process cmd.exe
nircmd.exe win focus process cmd.exe
cls
echo Confirm all information looks correct
if %safety%==0 timeout 3
if %safety%==1 timeout 10
:: Hides CMD
nircmd.exe win min process cmd.exe
nircmd.exe win focus process chrome.exe
nircmd.exe wait 300

::Clicks on save button
nircmd.exe setcursor 1770 470
nircmd.exe sendmouse left click
nircmd.exe wait 500

::Confirms save
nircmd.exe setcursor 920 620
nircmd.exe sendmouse left click
timeout 3 /nobreak

:: Don't print
nircmd.exe setcursor 1000 620
nircmd.exe sendmouse left click
nircmd.exe wait 500

set /a count=%count%+1
if %count% GEQ %totalTills% exit
::Loops program
goto Loop

:Warning
nircmd.exe win activate process cmd.exe
nircmd.exe win focus process cmd.exe
cls
echo Script cannot run with SCO
echo Press anything to close script...
pause >nul
exit