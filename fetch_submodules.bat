::::::::::::::::::::::::::::::::::::::::::::::::::
::	RUN ELEVATED
:: 	see "https://stackoverflow.com/a/12264592/1016343" for description
::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off

cls

setlocal DisableDelayedExpansion
set cmdInvoke=1
set winSysFolder=System32
set "batchPath=%~0"
for %%k in (%0) do set batchName=%%~nk
set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
setlocal EnableDelayedExpansion

:checkPrivileges
net file 1>nul 2>nul
if "%errorlevel%"=="0" ( 
	goto gotPrivileges 
) else ( 
	goto getPrivileges 
)

:getPrivileges
if "%1"=="elev" (
	echo elev & shift /1 & goto gotPrivileges
)

echo.
echo **************************************
echo Invoking UAC for privilege escalation
echo **************************************

echo Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
echo args = "elev " >> "%vbsGetPrivileges%"
echo For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
echo args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
echo Next >> "%vbsGetPrivileges%"

if "%cmdInvoke%"=="1" (
	goto invokeCmd 
)

echo UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
goto runElevation

:invokeCmd
echo args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
echo UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:runElevation
"%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
exit /B

:gotPrivileges
setlocal & cd /d %~dp0
if "%1"=="elev" (
	del "%vbsGetPrivileges%" 1>nul 2>nul & shift /1
)

::::::::::::::::::::::::::::::::::::::::::::::::::
::	SETUP
::::::::::::::::::::::::::::::::::::::::::::::::::

set gitCmd=git

call :checkCmd %gitCmd% --version
if "%errorlevel%" neq "0" (
	set gitPath=%ProgramFiles%\Git\bin
	if exist "!gitPath!\git.exe" (
		echo Found git at "!gitPath!"
		set gitCmd="!gitPath!\git.exe"
	)
	call :checkCmd !gitCmd! --version
	if "!errorlevel!" neq "0" (
		echo git not found
		goto eof
	)
)

echo.
echo **************************************
echo Fetching submodules
echo **************************************

for /d %%S in (submodules\*) do (
	pushd %%S
	%gitCmd% submodule init
	%gitCmd% submodule update
	popd
)

goto eof

:eof
pause
exit /b %errorlevel%

:checkCmd
set cmd=%1
shift
set "args="
	:checkCmd_parse
	if "%~1" neq "" (
	  set args=%args%%1
	  shift
	  goto :checkCmd_parse
	)
%cmd% %args% >nul 2>&1 && (
	exit /b 0
) || (
	exit /b -1
)