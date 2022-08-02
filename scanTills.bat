@echo off
title Scan Tills
color a
cd data

:: Checks if in proper directory
if not exist "..\%~n0%~x0" goto Error

:Warning
cls
echo Scan Tills V 1.2
echo WARNING: Only run this if you need to update data/scannedTills.txt
echo How to use:
echo Go to Activities / Tender Pickup
echo You MUST be using chrome for the script to work
echo Avoid touching the keyboard or mouse while the program is running unless attempting to close it
echo Press anything to start the script...
pause >nul

:: Hides program
nircmd.exe win min process cmd.exe
nircmd.exe win min process explorer.exe
:: Maximizes chrome
nircmd.exe win max process chrome.exe
nircmd.exe win focus process chrome.exe
nircmd.exe wait 10
del scannedTills.txt

:: First loop
:: Clicks on the till
nircmd.exe setcursor 440 440
nircmd.exe sendmouse left click
nircmd.exe wait 10
nircmd.exe sendkey backspace press

:Loop
:: Clicks on the till
nircmd.exe setcursor 440 440
nircmd.exe sendmouse left click
nircmd.exe wait 10
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
find /c "Till9" data.txt && ( exit )
find /c "Till" data.txt && (
nircmd.exe clipboard addfile "scannedTills.txt"
goto Loop
)
echo Till not found
echo Press anything to end program...
pause >nul
exit

:Error
color c
cls
echo Please make a copy of "Cash Office Scripts" to your desktop
echo You can do this manually or by running updater.bat
echo Do not run this script in the shared folder
pause
exit