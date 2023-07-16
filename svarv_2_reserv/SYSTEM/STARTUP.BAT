@echo off
rem --------------------------------
rem $Date:   04 Jan 2001 08:54:54  $
rem $Revision:   1.10  $
rem $Author:   MVERMEUL  $
rem --------------------------------

if "%1" == "v" goto Verbose
if "%1" == "V" goto Verbose
if "%1" == "-v" goto Verbose
if "%1" == "-V" goto Verbose
if "%1" == "s" goto Static
if "%1" == "S" goto Static
if "%1" == "-s" goto Static
if "%1" == "-S" goto Static
if "%1" == "cm" goto cncinst
if "%1" == "CM" goto cncinst
echo [37;44;1m
cls
echo.
echo [4;17HÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
echo [5;17Hº                 HEIDENHAIN                  º
echo [6;17HÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
echo.
echo.     ÛÝ  ÞÛ  ÞÛÛÝ  ÛÝ   Û Û    Û  ÞÛÛÝ  Û           Û               ÛÝ   Û
echo.     ÛÛ  ÛÛ  Û  Û  ÛÛÝ  Û Û    Û  Û  Û  Û           Û               ÛÛ  ÛÛ
echo.     ÛÞÝÞÝÛ ÞÝ  ÞÝ Û ÛÝ Û Û    Û ÞÝ  ÞÝ Û     ÜÜÜÜÜ Û Ü   Ü ÜÜÜÜÜ   ÛÞÝÞÝÛ
echo.     Û ÛÛ Û Û    Û Û  ÛÝÛ Û    Û Û    Û Û     Û   Û Û Û   Û Û       Û ÛÛ Û
echo.     Û ÞÝ Û ÛÛÛÛÛÛ Û   ÛÛ Û    Û ÛÛÛÛÛÛ Û     Û   Û Û Û   Û ßßßßÛ   Û ÞÝ Û
echo.     Û    Û Û    Û Û   ÞÛ ÞÛÛÛÛÝ Û    Û ÛÛÛÛÛ ÛÜÜÜÛ Û ÛÜÜÜÛ ÜÜÜÜÛ   Û    Û
echo.                                              Û
echo.                                              Û
echo.
rem Show software version, use variables set with set_vers.bat in Autoexec.bat
echo                       Version %HNR%%VNR%04.%VERS_NR%/%EXT% (ID = %SW_NR%)

echo [37;44;1m[21;1H   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
echo    ³                                                                       ³
echo    ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
echo [0;37;44m                                    Copyright HEIDENHAIN NUMERIC B.V., 2001
echo [34;44;2m[1;1H
cd\util >nul
set langdir=c:\system
echo [0;37;44m[21;32H System Loading 
echo [22;5H±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
echo [19;1H[K   Checking system configuration...[34m
echo [34;44;2m[1;1H
dgn2 -dm -iSCAN2.cmd -o%tmp%\SCAN2.mok -b%tmp%\setpcenv.bat
echo [34;44;2m[1;1H
call %tmp%\SETPCENV.bat >nul
echo [22;5H[37mÛÛÛÛÛÛÛÛÛÛÛÛ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
echo [19;1H[K   Checking system configuration...[34m
echo [34;44;2m[1;1H
moktrans -i%tmp%\SCAN2.mok -o%tmp%\TEST2.cmd -c%tmp%\SYS.cfg -pTEST.pre >nul
echo [22;5H[37mÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
echo [19;1H[K   Testing hardware modules...[34m
echo [34;44;2m[1;1H
dgn2 -dm -i%tmp%\TEST2.cmd -o%tmp%\TEST.mok
echo [22;5H[37mÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
echo [19;1H[K   Testing hardware modules...[34m
echo [34;44;2m[1;1H
cnctrans -i%tmp%\TEST.mok -o%tmp%\SYSTEM.cfg >nul
echo [34;44;2m[1;1H
echo [22;5H[37mÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ±±±±±±±±±±±±±±±±±±±±±±±±
echo [19;1H[K   Loading firmware...[34m
echo [1;1H

%tmp%
echo y>y
echo [1;1H
if exist c:\system\ccu430.exe c:\system\ccu430.exe <y >nul
echo [1;1H
if exist c:\system\ccu430s.exe c:\system\ccu430s.exe <y >nul
echo [1;1H
dtl -dm -tCCU00=ccu430.sys -tCCU01=ccu430s.sys system.cfg

echo [22;5H[37mÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ±±±±±±±±±±±±
echo [19;1H[K   Loading CNC software...
echo [34;44;2m[1;1H
c:
cd\system
goto Startup

:Verbose
cd\util
set langdir=c:\system
dgn2 -ds -iSCAN2.cmd -o%tmp%\SCAN2.mok -b%tmp%\setpcenv.bat
call %tmp%\SETPCENV.bat
moktrans -i%tmp%\SCAN2.mok -o%tmp%\TEST2.cmd -c%tmp%\SYS.cfg -pTEST.pre
dgn2 -ds -i%tmp%\TEST2.cmd -o%tmp%\TEST.mok
cnctrans -i%tmp%\TEST.mok -o%tmp%\SYSTEM.cfg
%tmp%
echo y>y
if exist c:\system\ccu430.exe c:\system\ccu430.exe <y >nul
if exist c:\system\ccu430s.exe c:\system\ccu430s.exe <y >nul
dtl -ds -tCCU00=ccu430.sys -tCCU01=ccu430s.sys system.cfg
c:
cd\system
goto Startup

:Static
echo. Cpu00 = error:0 cpu:80586 mhz:85 x87:1 dramSize:800000 \> %tmp%\system.cfg
echo.         hardDiskSize:3c0000 hwString:PC_411 dosVersion:6.20 \>> %tmp%\system.cfg
echo.         sramBase:f8d00000 sramSize:100000 matrixId:2 \>> %tmp%\system.cfg
echo.         pcics2Base:f8c00000 pcics3Base:f9000000>> %tmp%\system.cfg
echo. Plu00 = error:0 inBase:f9008800 outBase:f9008800 digiIn:20 digiOut:1f>> %tmp%\system.cfg
echo. Plu01 = error:0 inBase:f9008820                  digiIn:19 digiOut:0>> %tmp%\system.cfg
set pc_type=PC_411
%tmp%
echo y>y
if exist c:\system\ccu430.exe c:\system\ccu430.exe <y >nul
if exist c:\system\ccu430s.exe c:\system\ccu430s.exe <y >nul
dtl -ds -tCCU00=ccu430.sys -tCCU01=ccu430s.sys system.cfg
c:
cd\system
goto Startup


:Startup
sram /dm /s /f%tmp%\system.cfg /a%tmp%\cm.cm /mc10
if not exist c:\dos\find.exe goto standaard
if not exist %tmp%\cm.cm goto standaard
c:\dos\find.exe "N5 " %tmp%\cm.cm > %tmp%\language.cm
c:\dos\find.exe "C12" %tmp%\language.cm > %tmp%\lang.nr
if not errorlevel 1 goto RUS
c:\dos\find.exe "C11" %tmp%\language.cm > %tmp%\lang.nr
if not errorlevel 1 goto H
c:\dos\find.exe "C10" %tmp%\language.cm > %tmp%\lang.nr
if not errorlevel 1 goto CZ
c:\dos\find.exe "C9" %tmp%\language.cm > %tmp%\lang.nr
if not errorlevel 1 goto P
c:\dos\find.exe "C8" %tmp%\language.cm > %tmp%\lang.nr
if not errorlevel 1 goto SF
c:\dos\find.exe "C7" %tmp%\language.cm > %tmp%\lang.nr
if not errorlevel 1 goto S
c:\dos\find.exe "C6" %tmp%\language.cm > %tmp%\lang.nr
if not errorlevel 1 goto DK
c:\dos\find.exe "C5" %tmp%\language.cm > %tmp%\lang.nr
if not errorlevel 1 goto E
c:\dos\find.exe "C4" %tmp%\language.cm > %tmp%\lang.nr
if not errorlevel 1 goto I
c:\dos\find.exe "C3" %tmp%\language.cm > %tmp%\lang.nr
if not errorlevel 1 goto NL
c:\dos\find.exe "C2" %tmp%\language.cm > %tmp%\lang.nr
if not errorlevel 1 goto F
c:\dos\find.exe "C1" %tmp%\language.cm > %tmp%\lang.nr
if not errorlevel 1 goto GB
c:\dos\find.exe "C0" %tmp%\language.cm > %tmp%\lang.nr
if not errorlevel 1 goto D
goto standaard

:RUS
set Language=RUS
goto custom

:H
set Language=H
goto custom

:CZ
set Language=CZ
goto custom

:P
set Language=P
goto custom

:SF
set Language=SF
goto custom

:S
set Language=S
goto custom

:DK
set Language=DK
goto custom

:E
set Language=E
goto custom

:I
set Language=I
goto custom

:NL
set Language=NL
goto custom

:F
set Language=F
goto custom

:GB
set Language=GB
goto custom

:standaard
:D
set Language=D
goto custom


:custom
for %%f in (u*.3??) do set uims=%%f
for %%f in (u????%Language%.3??) do set uims=%%f
for %%f in (c:\oem\i*.*) do set iplc=%%f
for %%f in (c:\oem\i*.%Language%) do set iplc=%%f
call menu.bat makemotordat 
btl -b -pDO0PV15 -c%tmp%\system.cfg -m%tmp%\motor.dat %iplc% s*.3?? %uims% >nul
goto end


:cncinst
if not exist c:\util\menu.bat goto load_cm
call c:\util\menu LoadMc nul
goto end

:load_cm
rem Do diagnose to find the location of SRAM
cd\util
dgn2 -ds -iSCAN2.cmd -o%tmp%\SCAN2.mok -b%tmp%\setpcenv.bat
call %tmp%\SETPCENV.bat
moktrans -i%tmp%\SCAN2.mok -o%tmp%\TEST2.cmd -c%tmp%\SYS.cfg -pTEST.pre
dgn2 -ds -i%tmp%\TEST2.cmd -o%tmp%\TEST.mok
cnctrans -i%tmp%\TEST.mok -o%tmp%\SYSTEM.cfg
set cmloaded=1
if not exist c:\util\sram.exe goto Load_fls
if not exist c:\util\motor_mc.def goto clear
if not exist c:\system\_motor.dat goto clear
if not "%MAXMC%" == "" goto maxMcSet
if exist c:\system\set_vers.bat call c:\system\set_vers.bat
if "%MAXMC%" == "" set MAXMC=5739
:maxMcSet
rem  Save text mach.const. in %tmp%\txt_mc.tmp
sram /dm /g /f%tmp%\system.cfg /ic:\util\motor_mc.def /jc:\system\_motor.dat /a%tmp%\txt_mc.tmp /mc%MAXMC%
:clear
rem Clear sram
sram /dm /c /f%tmp%\system.cfg
rem Load all installed mach.const. files
if exist DEFAULT.CM sram /dm /r /f%tmp%\system.cfg /aDEFAULT.CM /mc%MAXMC%
for %%f in (*.CM) do if not "%%f"=="DEFAULT.CM" sram /dm /r /f%tmp%\system.cfg /a%%f /mc%MAXMC%
if not exist %tmp%\txt_mc.tmp goto copy_motor
rem Restore the saved text mach.const.
sram /dm /p /f%tmp%\system.cfg /ic:\util\motor_mc.def /jc:\system\motor.dat /a%tmp%\txt_mc.tmp /mc%MAXMC%
:copy_motor
if exist c:\system\_motor.dat attrib -r c:\system\_motor.dat >nul
if exist c:\system\_motor.dat del c:\system\_motor.dat >nul
copy c:\system\motor.dat c:\system\_motor.dat >nul
attrib +r c:\system\_motor.dat >nul
goto end

:end
echo [37m
