@echo off
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set 	PSubst_Name=PSubst3
set 	PSubst_Author=by Cyberponk
:: Changelog:
set PSubst_Version=v3.20 - 08/12/2016
::      v3.20 - 08/12/2016 - Fixed reg add bug when path ended with \ char. Other minor bugs fixed.
::			v3.10 - 23/08/2016 - Updated RequestAdminElevation function to v1.5
::			v3.03 - 20/11/2015 - Minor string modifications, removed the need of /P argument
::			v3.02 - 01/08/2015 - Updated RequestAdminElevation v1.3
:: 			v3.01 - 30/07/2015 - Updated RequestAdminElevation v1.2, added pause on exit
::		  v3    - 02/06/2015
:: 
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set PSubst_Header=%PSubst_Name% %PSubst_Version% - %PSubst_Author%
setlocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
set "_ThisFile=%~dpf0" &set "_Drive=" &set "_Path=" &set "_Persistent=" &set "_Delete=" &set "_Force="
set _RegQuery="HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices"
set LF=^&echo.

if "%~1" == "/?" goto :ShowInfo
if "%~1" == "" goto :PrintDrives
goto :main

:ShowInfo
  echo/%PSubst_Header%
  echo/ Manages reboot-persistent SUBST'ed ^(virtual^) drives.
:ShowUsage
  echo/
  echo/ PSUBST  [drive1: [drive2:]path] [/F]
  echo/ PSUBST  drive1: /D
  echo/
  echo/   drive1:        Specifies the new reboot-persistent virtual drive.
  echo/   [drive2:]path  Specifies the source path for the virtual drive.
  echo/
  echo/   /D             Deletes a ^(virtual^) drive (whether it is reboot-persistent or not).
  echo/   /F             Forces the overwriting of a reboot-persistent drive letter
  echo/
  echo/ Returns:
  echo/   -1 or 1       An error occured
  echo/    0            Command successfull
  echo/ Type PSUBST with no parameters to display a list of created virtual drives.
endlocal & goto:eof

:main
  :ProcessAllArgumentsLoop
    Shift 
    set "_Arg=%~0 "
  if "!_Arg!" NEQ " " (call :ProcessArgument &goto:ProcessAllArgumentsLoop)

  :: Check if all parameters are correct
  if "%_Drive%"=="" (set _Error=No drive letter chosen ^&call:ShowUsage)
  if "%_Error%" NEQ "" goto:ExitWithError

  Call :CheckPersistent
  if "%_Delete%"=="TRUE" goto:RemoveDrive

  :CreateDrive
    echo/Creating drive !_Drive!...
    if NOT exist "%_Path%" (set _Error=Source path not chosen or invalid. For help type psubst /? &goto:ExitWithError)
    if "%_Path:~-1%"=="\" if NOT "%_Path:~-2%"==":\" set "_Path=%_Path:~0,-1%"
    :: Check if persistent drive already exists, and if _Force not set, exit with error
    if "%_IsPersistent%"=="TRUE" (if "%_Force%" NEQ "TRUE" (set _Error=Persistent Drive Letter already in use - use /F option to force overwrite &goto:ExitWithError))
    if "%_Force%"=="TRUE" (subst %_Drive% /D >nul && echo A reboot may be required if drive letter is not mapped correctly by now.)
    subst %_Drive% "%_Path%"
    :: Add registry entry
      call :RequestAdminElevation "!_ThisFile!" %* || goto:eof )
      call :AddPersistent
      call :CheckPersistent
      if "%_IsPersistent%" NEQ "TRUE" (set _Error=Could not create registry entry &goto:ExitWithError) else (fc;: 2>nul)
  goto:end

:RemoveDrive
    echo/Removing drive !_Drive!...
    if "!_Path!" NEQ "" (set _Error=Do not type path and /D arguments at the same time ^&call:ShowUsage &goto:ExitWithError)
    :: Delete Subst drive
    subst %_Drive% /D
    :: If drive is persistent, get admin rights and remove registry entry
    if "%_IsPersistent%"=="TRUE" ((call :RequestAdminElevation "!_ThisFile!" %* || goto:eof ) & call :RemovePersistent ) else (echo Drive was not persistent.&goto:end)
    :: Check if persistent drive removal was successfull
    Call :CheckPersistent
    if "%_IsPersistent%"=="TRUE" (set _Error=Could not remove registry entry &goto:ExitWithError) else (echo Persistent drive removed. A reboot may be required to completely remove the drive letter.&ver >nul)

:end
pause & endlocal & goto:eof

:ExitWithError
    echo/ERROR: %_Error%
    echo/ 
    fc;: 2>nul
goto:end

:ProcessArgument
  if /i "!_Arg!"=="/D " (set "_Delete=TRUE"     & goto:eof)    &:: Check for /D flag
  if /i "!_Arg!"=="/F " (set "_Force=TRUE"      & goto:eof)    &:: Check for /F flag
    
  if "!_Arg:~1,10!"==": "  (if "!_Drive!"=="" (set "_Drive=!_Arg:~0,2!"  &goto:eof) else (set _Error=Type only 1 drive letter ^&call:ShowUsage))
  if "!_Arg:~1,2!" ==":\"  (if "!_Path!" =="" (set  "_Path=!_Arg:~0,-1!" &goto:eof) else (set _Error=Type only 1 path ^&call:ShowUsage))
goto:eof &:: End ProcessArgument

:CheckPersistent 
  reg query !_RegQuery! /v !_Drive! >nul 2>&1 && (set "_IsPersistent=TRUE" ) || ( set "_IsPersistent=")
goto:eof &:: End CheckPersistent 

:AddPersistent
  if "%_Path:~-1%"=="\" set "_Path=%_Path%\"
  reg add %_RegQuery%  /F /v %_Drive% /t REG_SZ /d "\??\%_Path%"
goto:eof &:: End AddPersistent

:RemovePersistent
  reg delete %_RegQuery% /v %_Drive% /F
goto:eof &:: End RemovePersistent

:PrintDrives
  echo/%PSubst_Header%
  echo  Use /? argument for usage information
  echo/
  echo/*SUBSTed drives currently set:
  subst
  echo/
  echo/*Reboot-persistent virtual drives currently set:
  for /f "tokens=1,2,*" %%a in ( 'reg query !_RegQuery! ^| findstr ??' ) do (
    set "_RegPath=%%~c"
    set "_RegPath=!_RegPath:\??\=!"
    echo/%%~a\: =^> !_RegPath!
  )
goto:eof &:: End PrintDrives


:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:RequestAdminElevation FilePath %* || goto:eof
:: 
:: By:   Cyberponk, 	v1.5 - 10/06/2016 - Changed the admin rights test method from cacls to fltmc
::			v1.4 - 17/05/2016 - Added instructions for arguments with ! char
::			v1.3 - 01/08/2015 - Fixed not returning to original folder after elevation successful
:: 			v1.2 - 30/07/2015 - Added error message when running from mapped drive
::			v1.1 - 01/06/2015
:: 
:: Func: opens an admin elevation prompt. If elevated, runs everything after the function call, with elevated rights.
:: Returns: -1 if elevation was requested
::           0 if elevation was successful
::           1 if an error occured
:: 
:: USAGE:
:: If function is copied to a batch file:
::     call :RequestAdminElevation "%~dpf0" %* || goto:eof
::
:: If called as an external library (from a separate batch file):
::     set "_DeleteOnExit=0" on Options
::     (call :RequestAdminElevation "%~dpf0" %* || goto:eof) && CD /D %CD%
::
:: If called from inside another CALL, you must set "_ThisFile=%~dpf0" at the beginning of the file
::     call :RequestAdminElevation "%_ThisFile%" %* || goto:eof
::
:: If you need to use the ! char in the arguments, the calling must be done like this, and afterwards you must use %args% to get the correct arguments:
::      set "args=%* "
::      call :RequestAdminElevation .....   use one of the above but replace the %* with %args:!={a)%
::      set "args=%args:{a)=!%" 
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
setlocal ENABLEDELAYEDEXPANSION & set "_FilePath=%~1"
  if NOT EXIST "!_FilePath!" (echo/Read RequestAdminElevation usage information)
  :: UAC.ShellExecute only works with 8.3 filename, so use %~s1
  set "_FN=_%~ns1" & echo/%TEMP%| findstr /C:"(" >nul && (echo/ERROR: %%TEMP%% path can not contain parenthesis &pause &endlocal &fc;: 2>nul & goto:eof)
  :: Remove parenthesis from the temp filename
  set _FN=%_FN:(=%
  set _vbspath="%temp:~%\%_FN:)=%.vbs" & set "_batpath=%temp:~%\%_FN:)=%.bat"

  :: Test if we gave admin rights
  fltmc >nul 2>&1 || goto :_getElevation

  :: Elevation successful
  (if exist %_vbspath% ( del %_vbspath% )) & (if exist %_batpath% ( del %_batpath% )) 
  :: Set ERRORLEVEL 0, set original folder and exit
  endlocal & CD /D "%~dp1" & ver >nul & goto:eof

  :_getElevation
  echo/Requesting elevation...
  :: Try to create %_vbspath% file. If failed, exit with ERRORLEVEL 1
  echo/Set UAC = CreateObject^("Shell.Application"^) > %_vbspath% || (echo/&echo/Unable to create %_vbspath% & endlocal &md; 2>nul &goto:eof) 
  echo/UAC.ShellExecute "%_batpath%", "", "", "runas", 1 >> %_vbspath% & echo/wscript.Quit(1)>> %_vbspath%
  :: Try to create %_batpath% file. If failed, exit with ERRORLEVEL 1
  echo/@%* > "%_batpath%" || (echo/&echo/Unable to create %_batpath% & endlocal &md; 2>nul &goto:eof)
  echo/@if %%errorlevel%%==9009 (echo/^&echo/Admin user could not read the batch file. If running from a mapped drive or UNC path, check if Admin user can read it.)^&echo/^& @if %%errorlevel%% NEQ 0 pause >> "%_batpath%"

  :: Run %_vbspath%, that calls %_batpath%, that calls the original file
  %_vbspath% && (echo/&echo/Failed to run VBscript %_vbspath% &endlocal &md; 2>nul & goto:eof)
  
  :: Vbscript has been run, exit with ERRORLEVEL -1
  echo/&echo/Elevation was requested on a new CMD window &endlocal &fc;: 2>nul & goto:eof
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
