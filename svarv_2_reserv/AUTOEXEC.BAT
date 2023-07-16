@echo off
rem --------------------------------
rem $Date:   07 Nov 2000 14:41:40  $
rem $Revision:   1.6  $
rem $Author:   MVERMEUL  $
rem --------------------------------

prompt $p$g
path c:\dos;c:\util;c:\
if exist c:\util\enbreset.com enbreset
if exist c:\util\sram.exe set cmloaded=0
if exist c:\label.txt c:\dos\attrib -r -h c:\label.txt >nul

rem Systems have two or three partitions
rem Ramdisk will be d: or e:
rem Due to Interlink there might be additional drives beyond the ramdrive
set tmp=c:

:testDLabel
if not exist d:\nul goto uselastone
set tmp=d:
vol d:>c:\label.txt
find "MS-RAMDRIVE" c:\label.txt >nul
if not errorlevel 1 goto found

:testELabel
if not exist e:\nul goto uselastone
set tmp=e:
vol e:>c:\label.txt
find "MS-RAMDRIVE" c:\label.txt >nul
if not errorlevel 1 goto found

:testFLabel
if not exist f:\nul goto uselastone
set tmp=f:
vol f:>c:\label.txt
find "MS-RAMDRIVE" c:\label.txt >nul
if not errorlevel 1 goto found

:testGLabel
if not exist g:\nul goto uselastone
set tmp=g:
vol g:>c:\label.txt
find "MS-RAMDRIVE" c:\label.txt >nul
if not errorlevel 1 goto found

:uselastone
:found
%tmp%
if exist c:\system\set_vers.bat call c:\system\set_vers.bat

:testcom
  wait4com -c1 -b9600 -t3
  rem wait4com -c2 -b9600 -t3
  if not errorlevel 1 goto testcom

if not exist c:\util\menu.bat goto startup
copy c:\util\menu.bat %tmp%\
call %tmp%\menu.bat

:startup
c:
if not "%config%" == "" goto %config%
:Normal
if exist c:\system\startup.bat c:\system\startup.bat
goto end

:Verbose
if exist c:\system\startup.bat c:\system\startup.bat V
goto end

:Static
if exist c:\system\startup.bat c:\system\startup.bat S
goto end

:end
echo.
echo.
echo Use the HEIDENHAIN NUMERIC installation tool CNCINST to load a CNC SW version
echo.
:exit
