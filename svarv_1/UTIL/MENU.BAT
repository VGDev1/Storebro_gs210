@echo off
rem --------------------------------
rem $Date:   28 Sep 2000 11:26:02  $
rem $Revision:   1.15  $
rem $Author:   MVERMEUL  $
rem --------------------------------

rem %1 = [-q][-s][:label]
rem %2 = [nul][logfile]

rem When parameter 1 = -s, always show the menu
if "%1" == "-s" goto Menu
if "%1" == "-S" goto Menu

if "%1" == "-q" goto Menu
if "%1" == "-Q" goto Menu

rem Direct function call (parameter 1 must match label)
if not "%1" == "" goto %1

:Menu

echo Loading keyboard driver ....
if exist c:\system\set_vers.bat call c:\system\set_vers.bat
if exist c:\util\key_tnc.exe c:\util\key_tnc.exe >nul

rem Skip the S-key test when param 1 = -s or -S, or when a new version has been detected
if "%1" == "-s" goto showMenu
if "%1" == "-S" goto showMenu
if exist d:\startup\*.exe goto showMenu
rem The 'S' or '='key must be pressed within 4 seconds to activate the service menu
cls
choice /c:S=Q /tQ,4 /n "  HEIDENHAIN NUMERIC Service Menu  "
if errorlevel 3 goto exit

:again
	rem Exit from direct function call
	if "%1" == "-s" goto showMenu
	if "%1" == "-S" goto showMenu
	if "%1" == "-q" goto showMenu
	if "%1" == "-Q" goto showMenu
	if not "%1" == "" goto exit1

:showMenu
cls
echo.  HEIDENHAIN NUMERIC Service Menu -- Version %HNR%%VNR%04.%VERS_NR%/%EXT% (ID = %SW_NR%)

if not exist e:\nul echo [3;1H[K[01;30;40m   1. Download new software[0m (start Interserver on PC, reset CNC)
if exist e:\nul     echo [3;1H   1. Download new software from PC (\man_plus.m\manpl_dl.exe)
echo [4;1H   2. Load default machine constants and clear all memories
echo [5;1H   3. Install new software
if not exist e:\nul echo [6;1H   4. Start FastLynx-slave to download new software
if exist e:\nul echo [6;1H[K[01;30;40m   4. Start FastLynx-slave to download new software[0m 
if not exist e:\nul echo [7;1H[K[01;30;40m   5. Backup current version[0m (start Interserver on PC, reset CNC)
if exist e:\nul     echo [7;1H   5. Backup current version
if not exist e:\nul echo [8;1H[K[01;30;40m   6. Restore backup version[0m (start Interserver on PC, reset CNC)
if exist e:\nul     echo [8;1H   6. Restore backup version
echo [10;1H   D. DOS shell standalone (external PC-keyboard required)
echo [12;1H   9. Exit (Start CNC-software)

if exist d:\startup\*.exe echo [16;1H New SW version(s) detected in D:\Startup. 
if exist d:\startup\*.exe echo  Select menu entry 3 to install.
echo [13;1H
if "%mustBoot%" == "1" goto mustBoot
if not exist e:\nul choice /c:123456D9Q /n "  Select a menu item [2..4], press D for DOS, press 9 to exit "
if exist e:\nul     choice /c:123456D9Q /n "  Select a menu item [1..3,5,6], press D for DOS, press 9 to exit "
goto parser
:mustBoot
if not exist e:\nul choice /c:123456D9Q /n "  Select a menu item [2..4], press D for DOS, press 9 to restart CNC "
if exist e:\nul     choice /c:123456D9Q /n "  Select a menu item [1..3,5,6], press D for DOS, press 9 to restart CNC "
:parser
if errorlevel 10 goto exit
if errorlevel 9 goto exit
if errorlevel 8 goto exit
if errorlevel 7 goto dosShell
if exist e:\nul     if errorlevel 6 goto restore
if not exist e:\nul if errorlevel 6 goto again
if exist e:\nul     if errorlevel 5 goto backup
if not exist e:\nul if errorlevel 5 goto again
if not exist e:\nul if errorlevel 4 goto fastlynx
if exist e:\nul     if errorlevel 4 goto again
if errorlevel 3 goto install
if errorlevel 2 goto MCload
if exist e:\nul     if errorlevel 1 goto interlink
if not exist e:\nul if errorlevel 1 goto again
if errorlevel 0 goto exit

:interlink
rem =========================================================================
rem === SW download                                                       ===
rem =========================================================================
	if not exist d:\startup\nul 		md d:\startup >nul
	d:
	cd \
	cd startup
	if exist d:\startup\sram\nul deltree /y d:\startup\sram >nul
	if exist d:\startup\*.exe goto choice
	goto source

:choice
	echo [19;1H
	choice /c:1Y0N /n " Do you want to overwrite the existing file in D:\Startup\ , (Y=1 / N=0): "
	if errorlevel 5 goto again
	if errorlevel 4 goto again
	if errorlevel 3 goto again
	if errorlevel 2 goto source
	if errorlevel 1 goto source
	if errorlevel 0 goto again

:source
	if exist d:\startup\*.exe del d:\startup\*.exe
	if exist f:\man_plus.m\manpl_dl.exe goto foundOnD
	if exist e:\man_plus.m\manpl_dl.exe goto foundOnC
	echo [19;1H No software version found on extern PC
	goto again

:foundOnC
	echo [22;1H Copying C:\man_plus.m\manpl_dl.exe (from your PC)
	echo Please wait, this takes several minutes...
	copy e:\man_plus.m\manpl_dl.exe
	goto again

:foundOnD
	echo [22;1H Copying D:\man_plus.m\manpl_dl.exe (from your PC)
	echo Please wait, this takes several minutes...
	copy f:\man_plus.m\manpl_dl.exe
	goto again

:fastlynx
	if not exist d:\startup\nul 		md d:\startup >nul
	d:
	cd \
	cd startup
	cls
	echo [K[01;33;40mStart FastLynx on your PC for connection
	echo Select 'Exit Remote' in FastLynx on your PC or 
	echo press the Process (Upper-Right) button on the CNC to exit
	echo.[0m
	if exist c:\util\sl.exe c:\util\sl.exe
	goto again

:install
rem =========================================================================
rem === SW installation                                                   ===
rem =========================================================================
	if exist d:\startup\*.exe goto install1
	echo [16;1H[K
	echo [15;1H[KD:\Startup does not contain any(more) software versions to install
	pause Press any Numeric key to continue...
	goto again

:install1
	rem -------------------------------------------------------------------------
	cls

:install2
	rem -------------------------------------------------------------------------
	set $$new=
	for %%f in (d:\startup\*.exe) do set $$new=%%f
	if "%$$new%" == "" goto install3
	echo Deleting temporary files...
	if exist d:\install.tmp\nul deltree /y d:\install.tmp >nul
	echo Unpacking New Version %$$new%
	echo Please wait, this may take a while...
	rem Do not change the sequence of -d and parameter. Now the command
	rem works wih the sfx stub of both Pkware and FZip
	%$$new% -o -d d:\install.tmp >nul
	REM D-Drive is full if errorlevel 50 is set
	if errorlevel 50 goto E_diskFull
	d:\install.tmp\cncinst\cncsetup
	if errorlevel 1 goto again
	rem When autoexec.bat or config.sys are installed a reboot is required
	if exist d:\install.tmp\root\autoexec.bat set mustBoot=1
	if exist d:\install.tmp\root\config.sys set mustBoot=1
	if exist d:\install.tmp\util\menu.bat set mustBoot=1

	del %$$new%
	rem If there are more version-files on D:\Startup, 
	rem they have to be installed also.
	goto install2

:install3
	rem -------------------------------------------------------------------------
	rem All version-files are unzipped and installed.
	rem -------------------------------------------------------------------------
	echo Deleting temporary files...
	if exist d:\install.tmp\nul deltree /y d:\install.tmp >nul
	if exist %tmp%\after.log type %tmp%\after.log >>d:\startup\install.log
	rem Set the version variables to their new settings
	if exist c:\system\set_vers.bat call c:\system\set_vers.bat
	rem create new motor.dat file
	goto makemotordat

:backup
rem =========================================================================
rem === Make a backup copy of the current version                         ===
rem =========================================================================
    if not exist c:\system\s%HNR%%VNR%04.%VERS_NR% goto E_Backup
	cls
	choice /c:y1n0 /n "Are you sure you want to backup the current-version, (Y=1 / N=0): "
	if errorlevel 4 goto again
	if errorlevel 3 goto again

		rem If exist directory man_plus.m on D:-drive on extern PC
	if exist f:\man_plus.m\nul goto back_OnD
		rem If exist directory man_plus.m on C:-drive on extern PC
	if exist e:\man_plus.m\nul goto back_OnC
		rem If D:-drive not exist, backup on C:-drive
	if not exist f:\nul goto back_OnC

:back_OnD
	rem -------------------------------------------------------------------------
	echo Deleting Old Backup Version...
	rem -------------------------------------------------------------------------
	if exist f:\man_plus.m\backup\sram\nul			deltree /y f:\man_plus.m\backup\sram >nul
	if exist f:\man_plus.m\backup\version\nul		deltree /y f:\man_plus.m\backup\version >nul
	if not exist f:\man_plus.m\nul					md f:\man_plus.m >nul
	if not exist f:\man_plus.m\backup\nul			md f:\man_plus.m\backup >nul
	if not exist f:\man_plus.m\backup\sram\nul		md f:\man_plus.m\backup\sram >nul
	if not exist f:\man_plus.m\backup\version\nul 	md f:\man_plus.m\backup\version >nul

	rem -------------------------------------------------------------------------
	echo Saving SRAM to file d:\Startup\backup\sram\SRAM.SAV
	rem -------------------------------------------------------------------------
	call menu.bat makecfg %2

	if "%message%" == "NO_DGN" goto E_Dgn
	if "%message%" == "NO_CFG" goto E_Cfg

	if not exist d:\startup\nul 		md d:\startup >nul
	if not exist d:\startup\sram\nul	md d:\startup\sram >nul

	if exist d:\startup\sram\sram.sav attrib -r d:\startup\sram\sram.sav
	sram /s /f%tmp%\system.cfg /bd:\startup\sram\sram.sav

	echo Copying current version to d:\man_plus.m\backup\version on your extern PC
	echo Please wait, this takes several minutes...
	xcopy c:\*.* f:\man_plus.m\backup\version /s /e >nul

	echo Copying saved SRAM to d:\man_plus.m\backup\sram on your extern PC
	echo Please wait, this takes several minutes...
	copy /y d:\startup\sram\sram.sav f:\man_plus.m\backup\sram >nul
	deltree /y d:\startup\sram >nul
	goto again

:back_OnC
	rem -------------------------------------------------------------------------
	echo Deleting Old Backup Version...
	rem -------------------------------------------------------------------------
	if exist e:\man_plus.m\backup\sram\nul			deltree /y e:\man_plus.m\backup\sram >nul
	if exist e:\man_plus.m\backup\version\nul		deltree /y e:\man_plus.m\backup\version >nul
	if not exist e:\man_plus.m\nul					md e:\man_plus.m >nul
	if not exist e:\man_plus.m\backup\nul			md e:\man_plus.m\backup >nul
	if not exist e:\man_plus.m\backup\sram\nul		md e:\man_plus.m\backup\sram >nul
	if not exist e:\man_plus.m\backup\version\nul 	md e:\man_plus.m\backup\version >nul

	rem -------------------------------------------------------------------------
	echo Saving SRAM to file d:\Startup\backup\sram\SRAM.SAV
	rem -------------------------------------------------------------------------
	call menu.bat makecfg %2

	if "%message%" == "NO_DGN" goto E_Dgn
	if "%message%" == "NO_CFG" goto E_Cfg

	if not exist d:\startup\nul 		md d:\startup >nul
	if not exist d:\startup\sram\nul	md d:\startup\sram >nul

	if exist d:\startup\sram\sram.sav attrib -r d:\startup\sram\sram.sav
	sram /s /f%tmp%\system.cfg /bd:\startup\sram\sram.sav

	echo Copying current version to c:\man_plus.m\backup\version on your extern PC
	echo Please wait, this takes several minutes...
	xcopy c:\*.* e:\man_plus.m\backup\version /s /e >nul

	echo Copying saved SRAM to c:\man_plus.m\backup\sram on your extern PC
	echo Please wait, this takes several minutes...
	copy /y d:\startup\sram\sram.sav e:\man_plus.m\backup\sram >nul
	deltree /y d:\startup\sram >nul
	goto again

:restore
rem =========================================================================
rem === Restore saved version                                             ===
rem =========================================================================
	cls
	choice /c:y1n0 /n "Are you sure you want to restore the backup version, (Y=1 / N=0): "
	if errorlevel 4 goto again
	if errorlevel 3 goto again

	rem If exist directory man_plus.m\version\dos on D:-drive on extern PC
	if exist f:\man_plus.m\backup\version\dos\nul goto dRestore
	rem If exist directory man_plus.m\version\dos on C:-drive on extern PC
	if exist e:\man_plus.m\backup\version\dos\nul goto cRestore

	cls
	echo [16;1H[K
	echo [15;1H[KThere is no backup version present on your extern PC
	pause Press any Numeric key to continue...
	goto again

:dRestore
	cls
	rem -------------------------------------------------------------------------
	echo Restoring from D-drive of extern PC
	rem -------------------------------------------------------------------------
	echo.
	echo Removing Attributes 
	echo.
	f:\man_plus.m\backup\version\dos\attrib -r c:\*.* /s >nul

	echo Deleting Dos...
	f:\man_plus.m\backup\version\dos\deltree /y c:\dos\*.*  >nul
	echo Restoring Root and Dos...
	echo Please wait, this takes several minutes...
	if not exist c:\dos\nul 			md c:\dos >nul
	copy f:\man_plus.m\backup\version\*.*     c:\  /y >nul
	f:\man_plus.m\backup\version\dos\xcopy f:\man_plus.m\backup\version\dos\*.* c:\dos\ /s /e >nul

	echo.
	echo Deleting Util...
	f:\man_plus.m\backup\version\dos\deltree /y c:\util\*.*  >nul
	echo Restoring Util...
	echo Please wait, this takes several minutes...
	if not exist c:\util\nul 			md c:\util >nul
	f:\man_plus.m\backup\version\dos\xcopy f:\man_plus.m\backup\version\util\*.* c:\util\ /s /e >nul

	echo.
	echo Deleting System...
	f:\man_plus.m\backup\version\dos\deltree /y c:\system\*.* >nul
	echo Restoring System...
	echo Please wait, this takes several minutes...
	if not exist c:\system\nul 			md c:\system >nul
	f:\man_plus.m\backup\version\dos\xcopy f:\man_plus.m\backup\version\system\*.* c:\system\ /s /e >nul

	echo.
	echo Deleting Oem...
	f:\man_plus.m\backup\version\dos\deltree /y c:\oem\*.*  >nul
	echo Restoring Oem...
	echo Please wait, this takes several minutes...
	if not exist c:\oem\nul 			md c:\oem >nul
	f:\man_plus.m\backup\version\dos\xcopy f:\man_plus.m\backup\version\oem\*.* c:\oem\ /s /e >nul

	echo.
	echo Copying SRAM-storage in d:\Startup\sram...
	echo Please wait, this takes several minutes...
	if not exist d:\startup\nul 		md d:\startup >nul
	if not exist d:\startup\sram\nul	md d:\startup\sram >nul
	f:\man_plus.m\backup\version\dos\xcopy f:\man_plus.m\backup\sram\sram.sav d:\startup\sram\  /e >nul

	echo.
	echo Restoring SRAM from file d:\Startup\sram\SRAM.SAV
	call menu.bat makecfg %2

	if "%message%" == "NO_DGN" goto E_Dgn
	if "%message%" == "NO_CFG" goto E_Cfg

	sram /r /f%tmp%\system.cfg /bd:\startup\sram\sram.sav 
	rem Restore the version variables to their old settings

	if exist c:\system\set_vers.bat call c:\system\set_vers.bat

		rem After a restore a reboot is required
	set mustBoot=1
	deltree /y d:\startup\sram >nul
	goto again

:cRestore
	cls
	rem -------------------------------------------------------------------------
	echo Restoring from C-drive of extern PC
	rem -------------------------------------------------------------------------
	echo.
	echo Removing Attributes 
	echo.
	e:\man_plus.m\backup\version\dos\attrib -r c:\*.* /s >nul

	echo Deleting Dos...
	e:\man_plus.m\backup\version\dos\deltree /y c:\dos\*.*  >nul
	echo Restoring Root and Dos...
	echo Please wait, this takes several minutes...
	if not exist c:\dos\nul 			md c:\dos >nul
	copy e:\man_plus.m\backup\version\*.*     c:\  /y >nul
	e:\man_plus.m\backup\version\dos\xcopy e:\man_plus.m\backup\version\dos\*.* c:\dos\ /s /e >nul

	echo.
	echo Deleting Util...
	e:\man_plus.m\backup\version\dos\deltree /y c:\util\*.*  >nul
	echo Restoring Util...
	echo Please wait, this takes several minutes...
	if not exist c:\util\nul 			md c:\util >nul
	e:\man_plus.m\backup\version\dos\xcopy e:\man_plus.m\backup\version\util\*.* c:\util\ /s /e >nul

	echo.
	echo Deleting System...
	e:\man_plus.m\backup\version\dos\deltree /y c:\system\*.* >nul
	echo Restoring System...
	echo Please wait, this takes several minutes...
	if not exist c:\system\nul 			md c:\system >nul
	e:\man_plus.m\backup\version\dos\xcopy e:\man_plus.m\backup\version\system\*.* c:\system\ /s /e >nul

	echo.
	echo Deleting Oem...
	e:\man_plus.m\backup\version\dos\deltree /y c:\oem\*.*  >nul
	echo Restoring Oem...
	echo Please wait, this takes several minutes...
	if not exist c:\oem\nul 			md c:\oem >nul
	e:\man_plus.m\backup\version\dos\xcopy e:\man_plus.m\backup\version\oem\*.* c:\oem\ /s /e >nul

	echo.
	echo Copying SRAM-storage in d:\Startup\sram...
	echo Please wait, this takes several minutes...
	if not exist d:\startup\nul 		md d:\startup >nul
	if not exist d:\startup\sram\nul	md d:\startup\sram >nul
	e:\man_plus.m\backup\version\dos\xcopy e:\man_plus.m\backup\sram\sram.sav d:\startup\sram\ /s /e >nul

	echo.
	echo Restoring SRAM from file d:\Startup\sram\SRAM.SAV
	call menu.bat makecfg %2

	if "%message%" == "NO_DGN" goto E_Dgn
	if "%message%" == "NO_CFG" goto E_Cfg

	sram /r /f%tmp%\system.cfg /bd:\startup\sram\sram.sav 
	rem Restore the version variables to their old settings

	if exist c:\system\set_vers.bat call c:\system\set_vers.bat
	
		rem After a restore a reboot is required
	set mustBoot=1
	deltree /y d:\startup\sram >nul
	goto again

:dosShell
rem =========================================================================
rem === DOS command entry                                                 ===
rem =========================================================================
	if exist c:\util\key_tnc.exe c:\util\key_tnc.exe /u >nul
	if not exist d:\startup\nul 		md d:\startup >nul
	cls
	d:
	cd \startup
	c:\command /e:1024 /k prompt Type EXIT to return to the HEIDENHAIN NUMERIC Service Menu$_$p$g
	prompt $p$g
	rem -------------------------------------------------------------------------
	rem Return to a local HD drive, because the user might have been fooling 
	rem around on an interlink drive.
	rem -------------------------------------------------------------------------
	d:
	cd \startup
	if exist c:\util\key_tnc.exe c:\util\key_tnc.exe >nul
	goto again

:MCload
rem =========================================================================
rem === Load default MCs: entry point from menu                           ===
rem =========================================================================
	cls
	choice /c:y1n0 /n "Are you sure you want to load the default MC's, (Y=1 / N=0): "
	if errorlevel 4 goto again
	if errorlevel 3 goto again
	set message=
	cls
	if not exist d:\startup\nul 		md d:\startup >nul
	call menu loadMc nul
	if "%message%" == "NO_VERS"		goto E_Vers
	if "%message%" == "FILE_ERR"	goto E_File
	if "%message%" == "NO_OLD"		goto mcL_Motor
	if "%message%" == "OK"			goto mcL_Ok
	goto again

:mcL_Motor
	echo [16;1H[K
	echo [15;1H[K Motor/Amp settings not upgraded: Could not detect old motor files.
	pause Press any Numeric key to continue...
	goto again

:mcL_Ok
	echo [22;1H[K
	echo [21;1H[KDefault MC's loaded successfully.
	pause Press any Numeric key to continue...
	goto again

:makeCfg
rem =========================================================================
echo Make system.cfg file for SRAM info and set PC_TYPE variable
rem =========================================================================
	if not exist c:\util\dgn2.exe goto noDgn
	
	rem Find LE4xx (03) SRAM (04)
	echo TSDG1000 03 01 05> %tmp%\scan.cmd
	echo TSSY>> %tmp%\scan.cmd
	dgn2 /dm /i%tmp%\scan.cmd /o%tmp%\scan.mok /b%tmp%\setpc.bat
	call %tmp%\setpc.bat
	cnctrans -i%tmp%\scan.mok -o%tmp%\system.cfg> nul 
	
	if not exist %tmp%\system.cfg set message=NO_CFG
	goto again
	
:noDgn
	set message=NO_DGN
	echo Command not possible: Could not detect diagnostics software >>%2
	goto again

:makemotordat
rem =========================================================================
echo Combine amplifiers, synchronous motors and asynchronous motors data 
rem =========================================================================
	if not exist c:\system\motor.amp goto nomotorfiles
	if not exist c:\system\motor.sn  goto nomotorfiles
	if not exist c:\system\motor.asn goto nomotorfiles
	copy /y c:\system\motor.amp+c:\system\motor.sn+c:\system\motor.asn %tmp%\motor.dat >nul
	goto again

:nomotorfiles
	rem -------------------------------------------------------------------------
	rem -- no error message, because this could be a SDC system
	echo No motor files found in c:\system >>%2
	goto again

:loadMc
rem =========================================================================
rem === Load default MCs:                                                 ===
rem === entry point for external calls without user interaction           ===
rem =========================================================================
	if not "%MAXMC%" == "" goto continLoadMc
	if not exist c:\system\set_vers.bat goto novers
	set MAXMC=5739

	:continLoadMc
	rem -- make system.cfg and motor.dat --
	call menu.bat makecfg %2

	if "%message%" == "NO_DGN" goto E_Dgn
	if "%message%" == "NO_CFG" goto E_Cfg
	
	call menu.bat makemotordat %2
	
	rem -- Read motor/amp settings from SRAM and save into file --
	call menu.bat mcMotorUpgrade %2
	
	rem -- To enable a shorter commandline, change to the temp directory --
	%tmp%
	
	rem -------------------------------------------------------------------------
	rem -- Check for a HNE default CM file in the system directory --

	:noUtilMc
	set hnefile=c:\system\cm.cm
	if exist %hnefile% goto LoadHne
	goto LoadExit

:LoadHne
rem -------------------------------------------------------------------------
echo.
echo Loading MC-file %hnefile%...
echo Loading MC-file %hnefile%... >>%2
rem -------------------------------------------------------------------------
rem     /dm     'display mute'
rem     /c      clears SRAM
rem     /p      puts data into SRAM
rem     /f      in: configuration file containing SRAM size and location
rem     /i      in: definition file linking MC numbers to motor database files
rem     /j      in: combined file of all motor database files (motor.amp,motor.sn,motor.asn)
rem     /a      in: ASCII MC source file
rem     /mc     total number of MC's to put
rem -------------------------------------------------------------------------
echo sram /c /p /f%tmp%\system.cfg /ic:\util\motor_mc.def /j%tmp%\motor.dat echo /a%hnefile% /mc%MAXMC%>>%2
sram /c /p /f%tmp%\system.cfg /ic:\util\motor_mc.def /j%tmp%\motor.dat /a%hnefile% /mc%MAXMC%

rem -------------------------------------------------------------------------
rem -- Then check for an OEM CM file in the util directory,                --
rem -- because that is the location CncInst puts it                        --
rem -- note that if more files are available, the last one is used         --
	set oemfile=
	for %%i in (c:\util\*.cm) do set oemfile=%%i
	
	if "%oemfile%" == ""   goto LoadExit
	if not exist %oemfile% goto LoadExit
	goto loadOem

:LoadOem
rem -------------------------------------------------------------------------
echo.
echo Loading MC-file %oemfile%...
echo Loading MC-file %oemfile%... >>%2
rem -------------------------------------------------------------------------
rem     /p      puts data into SRAM
rem     /f      in: configuration file containing SRAM size and location
rem     /i      in: definition file linking MC numbers to motor database files
rem     /j      in: combined file of all motor database files (motor.amp,motor.sn,motor.asn)
rem     /a      in: ASCII MC source file
rem     /mc     total number of MC's to put
rem -------------------------------------------------------------------------
	echo sram /p /f%tmp%\system.cfg /ic:\util\motor_mc.def /j%tmp%\motor.dat /a%oemfile% /mc%MAXMC%>>%2
	sram /p /f%tmp%\system.cfg /ic:\util\motor_mc.def /j%tmp%\motor.dat /a%oemfile% /mc%MAXMC%

:LoadExit
	if "%hnefile%" == ""   goto checkOem
	if not exist %hnefile% goto checkOem
	goto cmLeave

:checkOem
	if "%oemfile%" == ""   goto mcFileError
	if not exist %oemfile% goto mcFileError
	goto cmLeave

:cmLeave
	if not "%message%" == "NO_DGN" set message=OK
	set hnefile=
	set oemfile=
	goto again

:mcFileError
	set message=FILE_ERR
	echo Default MC's not loaded: Could not find file. >>%2
	set hnefile=
	set oemfile=
	goto again

:mcMotorUpgrade
	echo == menu.bat mcMotorUpgrade == >>%2
rem =========================================================================
rem    Upgrade amp/motor selection according to new motor.dat for LE4xx.
rem 
rem -- Before updating the SRAM, the current amp/motor selection is read   --
rem -- from the SRAM. The corresponding types are looked up in the old     --
rem -- motor.dat and saved as strings.                                     --
rem -- After the default MC's are written to the SRAM, the saved amp/motor --
rem -- types are looked up in the new motor.dat and the corresponding      --
rem -- numbers are written to the SRAM.                                    --
rem =========================================================================
	if not exist %tmp%\system.cfg call menu.bat makecfg %2
	if "%pc_type%" == "" call menu.bat makecfg %2
	if not exist %tmp%\system.cfg goto again
	
	if not exist %tmp%\motor.dat  call menu.bat makemotordat %2
	
	if not "%MAXMC%" == "" goto continMcMotorUpgrade
	if not exist c:\system\set_vers.bat goto novers
	set MAXMC=5739

	:continMcMotorUpgrade
	if not exist c:\util\motor_mc.def goto again
	if not exist c:\system\motordat.old goto noOldMotorDat
	
	rem -- To enable a shorter commandline, change to the temp directory --
	%tmp%
	
:saveMotorSetting
rem -------------------------------------------------------------------------
echo.
echo Save the current SRAM motor/amp settings
echo Save the current SRAM motor/amp settings >>%2
rem -------------------------------------------------------------------------
rem     /dm     'display mute'
rem     /g      gets data from SRAM
rem     /f      in: configuration file containing SRAM size and location
rem     /i      in: definition file linking MC numbers to motor database files
rem     /j      in: combined file of all motor database files 
rem                (motor.amp,motor.sn,motor.asn) of previous SW version
rem     /a      out: ASCII MC result file
rem     /mc     total number of MC's to put
rem -------------------------------------------------------------------------
	echo sram /g /f%tmp%\system.cfg /ic:\util\motor_mc.def /jc:\system\motordat.old /a%tmp%\motor_mc.txt /mc%MAXMC%>>%2
    sram /g /f%tmp%\system.cfg /ic:\util\motor_mc.def /jc:\system\motordat.old /a%tmp%\motor_mc.txt /mc%MAXMC%
	
	rem -- No saved motor settings: skip restore --
	if errorlevel 1 goto copyMotorDat
	if not exist %tmp%\motor_mc.txt goto copyMotorDat >nul
	
	rem -------------------------------------------------------------------------
	echo.
	echo Restore the saved motor/amp settings to SRAM
	echo Restore the saved motor/amp settings to SRAM >>%2
	rem -------------------------------------------------------------------------
	rem     /dm     'display mute'
	rem     /p      puts data into SRAM
	rem     /f      in: configuration file containing SRAM size and location
	rem     /i      in: definition file linking MC numbers to motor database files
	rem     /j      in: combined file of all motor database files (motor.amp,motor.sn,motor.asn)
	rem                of current SW version
	rem     /a      in: ASCII MC file with saved motor/amp settings
	rem     /mc     total number of MC's to put
	rem -------------------------------------------------------------------------
	echo sram /p /f%tmp%\system.cfg /ic:\util\motor_mc.def /j%tmp%\motor.dat /a%tmp%\motor_mc.txt /mc%MAXMC%>>%2
	sram /p /f%tmp%\system.cfg /ic:\util\motor_mc.def /j%tmp%\motor.dat /a%tmp%\motor_mc.txt /mc%MAXMC%

:copyMotorDat
rem -------------------------------------------------------------------------
echo Save old motor.dat >>%2
rem -------------------------------------------------------------------------
	rem -- Remove write-protection, save motor.dat file, restore write-protection
	if exist c:\system\motordat.old attrib -r c:\system\motordat.old 
	copy /y %tmp%\motor.dat c:\system\motordat.old >nul
	attrib +r c:\system\motordat.old >nul
	goto again

:noOldMotorDat
	rem -------------------------------------------------------------------------
	set message=NO_OLD
	echo Motor/Amp settings not upgraded: Could not detect old motor files. >>%2
	goto copyMotorDat

:noVers
	set message=NO_VERS
	echo Version information (set_vers.bat) missing. >>%2
	goto again

:E_diskFull
	echo.
	echo ERROR: Insufficient diskspace on Drive D
	echo Deleting temporary files...
	if exist d:\install.tmp\nul deltree /y d:\install.tmp >nul
	pause
	goto again

:E_Dgn
	echo [16;1H[K
	echo [15;1H[KCommand not possible: Could not detect diagnostics software
	pause Press any Numeric key to continue...
	goto again

:E_Backup
	echo [16;1H[K
	echo [15;1H[KCommand not possible: Could not detect installed software to backup
	pause Press any Numeric key to continue...
	goto again

:E_Cfg
	echo [16;1H[K
	echo [15;1H[KCommand not possible: Could not detect system.cfg
	pause Press any Numeric key to continue...
	goto again

:E_Vers
	echo [16;1H[K
	echo [15;1H[KCannot continue, version information (set_vers.bat) missing.
	pause Press any Numeric key to continue...
	goto again

:E_File
	echo [16;1H[K
	echo [15;1H[KDefault MC's not loaded: Could not find file.
	pause Press any Numeric key to continue...
	goto again
	
:exit
	rem =========================================================================
	if "%mustBoot%" == "1" echo [20;1H
	if "%mustBoot%" == "1" choice /c:abcdefghijklmnopqrstuvwxyz.123456789 /t.,2 /n " New version installed. Must reboot..."
	if "%mustBoot%" == "1" reboot
	
	if not exist c:\system\set_vers.bat goto E_Vers
	
	if exist c:\util\key_tnc.exe c:\util\key_tnc.exe /u >nul
	goto exit1

:exit1
	rem =========================================================================
	rem for direct function call
