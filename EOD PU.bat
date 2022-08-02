@echo off
title EOD PU
color a
:Restart
set /a debug=0
set today=%DATE:~4,2%/%DATE:~7,2%/%DATE:~10,4%
::Grabs yesterdays date
For /F %%A In ('PowerShell -NoP "(Get-Date).AddDays(-1).ToString('MM/dd/yyyy')"'
)Do Set "yesterday=%%A"
mode con: cols=60 lines=15
set /a totalTills=0
set /a count=0
set /a start=0
set /a num=0
set /a save=1
set /a safety=0
set /a warning=0
set /a totalLines=0
cd data

:: Updates old tillBalance.txt to new TillBalance.txt location and format
if NOT exist "%~dp0\TillBalance.txt" if exist "tillBalance.txt" (
rename "tillBalance.txt" "TillBalance.txt"
move TillBalance.txt %~dp0
)

:: If it still doesn't exist then come up with error
if NOT exist "%~dp0\TillBalance.txt" (
echo. > "%~dp0\TillBalance.txt"
set /a warning = 5
goto Error
)

set /a dataCorrect=0
FOR %%f in (..\TillBalance.txt) DO SET filedatetime=%%~tf
IF %filedatetime:~0, 10% == %date:~4% set /a dataCorrect=1

:: Detects total number of lines in tillBalance
for /F useback^ delims^=^ eol^= %%L in (..\TillBalance.txt) do set /A "totalLines+=1"

:: Detects total number of tills in scannedTills
for /F %%N in ('find /C "Till" ^< "scannedTills.txt"') do set totalTills=%%N
if %totalTills%==0 (
set /a warning = 4
goto Error
)

:Warning
cls
echo EOD PU V 2.1
echo Made by David Cannon
echo Press enter to continue...
set /p input=
if /i "%input%"=="M" (
cls
set /a start=1
goto Money
)
color c
mode con: cols=120 lines=20
cls
echo You MUST be using chrome for the script to work
echo Avoid touching the keyboard or mouse while the program is running unless attempting to close it
echo If the program starts messing things up you can immediately press ALT+F4 to close out of chrome to prevent errors
echo.
echo Make sure you inputted new and correct data to TillBalance.txt
if %dataCorrect%==0 echo WARNING: TillBalance.txt hasn't been updated in over a day, please update!
echo Please report issues to David Cannon
pause

:: Checks to make sure file has been updated recently
set /a dataCorrect=0
FOR %%f in (..\TillBalance.txt) DO SET filedatetime=%%~tf
IF %filedatetime:~0, 10% == %date:~4% set /a dataCorrect=1
cls
if %dataCorrect%==0 (
set /a warning = 3
goto Error
)

:: Checks to make sure lines in tillBalance is equal to the total amount of tills
cls
if NOT %totalLines%==%totalTills% (
if %totalLines% GTR %totalTills% echo TillBalance.txt has more lines then tills, please double check TillBalance.txt and make sure you didn't input too many tills 
if %totalLines% LSS %totalTills% echo TillBalance.txt has less lines then tills, please double check TillBalance.txt and make sure you entered every Till
echo If everything is correct already consider updating data/scannedTills.txt by running scanTills.bat
timeout 1 /nobreak >nul
echo Press anything to ignore...
pause >nul
)

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
if %num% LSS 0 set /a count=%totalTills%-(%totalTills%+%num%)

:: ^^ Allows you to say how many have currently been done using negatives
if %start%==1 (
cls
goto Money
)
echo Press anything to start the script...
set /a start=1
pause >nul

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

if "%yesterday%"=="%setDate%" goto Loop
cls

:: Shows CMD to ask
nircmd.exe win activate process cmd.exe
nircmd.exe win focus process cmd.exe

if %debug%==1 echo %yesterday% %today%
echo WARNING: The date you are altering is set to today, did you mean to set this to yesterday?
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
nircmd.exe setcursor 440 440
nircmd.exe sendmouse left click
timeout 0 /nobreak

::Sets till to the expected Till
set "expectedTill="
if %count% GTR 0 for /F "skip=%count% delims=" %%i in (scannedTills.txt) do if not defined expectedTill set "expectedTill=%%i"
if %count%==0 set /p expectedTill=< scannedTills.txt
nircmd.exe clipboard set "%expectedTill%"
nircmd.exe wait 10
nircmd.exe sendkeypress ctrl+v

:: Refreshes the till
nircmd.exe sendmouse wheel -120
nircmd.exe sendmouse wheel 120
nircmd.exe wait 10

nircmd.exe clipboard clear
echo > data.txt
::Copies current Till
nircmd.exe sendkeypress ctrl+a
nircmd.exe sendkeypress ctrl+c
nircmd.exe wait 5
nircmd.exe clipboard writefile "data.txt"
set /p currentTill=<data.txt

:: Checks if current Till is banned from being touched by the program
>nul find "%currentTill%" bannedTills.txt && goto Loop
find /c "Till9" data.txt && (
set /a warning=1
goto Error
)
nircmd.exe clipboard set "EOD PU (%today%)"

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
set "amount="
if %count% GTR 0 for /F "skip=%count% delims=" %%i in (..\TillBalance.txt) do if not defined amount set "amount=%%i"
if %count%==0 set /p amount=< "%~dp0\TillBalance.txt"

if NOT "%expectedTill%"=="%currentTill%" (
set /a warning = 2
goto Error
)

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
set /a warning=6
goto Error
)

:: Adds entered value to clipboard
nircmd.exe clipboard set "%amount%"
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
if NOT %value%==%amount% (
timeout 1 /nobreak >nul
set /a attemps=%attemps%+1
goto Retry2
)

:: Shows CMD
nircmd.exe win activate process cmd.exe
nircmd.exe win focus process cmd.exe

cls
echo Confirm all information looks correct
timeout 2
if %safety%==1 timeout 6

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
if %count% GEQ %totalTills% exit

::Loops program
goto Loop

:Error
set /a restart=0
color c
mode con: cols=120 lines=20

:: Shows CMD to ask
nircmd.exe win activate process cmd.exe
nircmd.exe win focus process cmd.exe

cls

:: Non-restartable warnings
if %warning%==1 echo Script cannot run with SCO
if %warning%==2 (
if %debug%==1 echo %expectedTill% %currentTill%
echo Wrong till has been selected...
)
if %warning%==4 echo data/scannedTills contains no tills, please run scanTills.bat to scan all Tills

:: Restartable warnings
if %warning%==3 set /a restart=1
if %warning%==5 set /a restart=1

:: Allows the program  to restart if error is easily fixible
if %restart%==1 (
if %warning%==3 echo TillBalance.txt hasn't been updated in over a day, please fill-in new values, then close and save the window to continue
if %warning%==5 echo TillBalance.txt didn't exist, empty file created, please input till balances, then close and save the window to continue
echo After that the script will restart
call "%~dp0\TillBalance.txt"
goto Restart
)

if %warning%==6 (
echo The script failed to validate money amount confirm everything is okay to continue...
pause
set /a attempts=0
goto Retry2
)

echo Press anything to close script...
pause >nul
exit
