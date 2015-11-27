@ECHO off
@echo off
SETLOCAL
COLOR 0f
SET automationTitlePrefix=Automation
TITLE %automationTitlePrefix%

FOR /F "tokens=2 delims=:" %%a IN ('ipconfig ^| findstr /IC:"IPv4 Address"') DO SET serverIP=%%a
::SET serverIP=ipconfig | findstr /R /C:"IPv4 Address"
SET serverUserName=%username%

SET automationTitlePrefix=Automation[%serverIP%]:
SET currentPath=%~dp0

SET automationMode=Local
REM Server Files/Folders details
SET serverZipName=ServerContainer.zip
SET serverUnZipPsName=ServerUnZip.ps1
REM Client Files/Folders details
SET clientContainerZIP=ClientContainer.zip
SET clientUnZipName=ClientUnZip.ps1
REM Client Profiler(ClientContainer)
SET profilingClientFolder=CoversionProfilingClient
SET conversionClientEXEname=CoversionProfilingClient.exe
REM PsTools
SET psEXECfolder=PsTools
SET psEXECfile=PsExec.exe

REM Client PS parameters
SET svcName=DocumentConversion
SET outputFolder=output
SET clientFolder=client
SET serverFolder=server
SET totalRequest=10
SET parallelBatch=2

REM server PS parameters
SET serverDirectoryName=C:
SET serverBaseDefaultFolder=test
SET serverContainerFolder=setup
SET serverUpdateFolder=update
SET serverBinariesFolder=ConversionService
SET serverPowershellFolder=PowershellScripts
SET serverServiceLogFolder=server
SET serverMasterPS=MasterRun.ps1
SET serviceName=ConversionService
SET applicationPort=21300
SET resourcePoolCount=6
SET tempDiskSize=512M
SET virtualDiskSize=512M
SET msOfficeKeyFileName=MsOfficeKey.txt
SET debugLog=True
SET automateMMCFileName=AutomateMMC

SET serverDirectory=%serverDirectoryName%
SET serverBaseSetupPath=%serverDirectory%\%serverBaseDefaultFolder%\%serverContainerFolder%
SET serverPowershellPath=%serverDirectory%\%serverBaseDefaultFolder%\%serverContainerFolder%\%serverPowershellFolder%
SET WASPPath=%serverPowershellPath%\WASP.dll
SET automateMMCbatPath=%serverBaseSetupPath%\%automateMMCFileName%.bat
SET ProfilingClientBat=%serviceName%.bat

SET clientContainerZipPath=%currentPath%%clientContainerZIP%
SET clientUnZipPsPath=%currentPath%%clientUnZipName%


IF NOT "%clientContainerZipPath%"=="" (
    IF NOT EXIST "%clientContainerZipPath%" (
        ECHO Client container Zip: %clientContainerZipPath% doesn't exists...
        GOTO End
    )
)

IF NOT "%clientUnZipPsPath%"=="" (
    IF NOT EXIST "%clientUnZipPsPath%" (
        ECHO ClientUnZip.ps1: %clientUnZipPsPath% doesn't exists...
        GOTO End
    )
)

TITLE %automationTitlePrefix% Extracting Client Container
REM UnZip Client Container using PS script
Powershell -NoProfile -ExecutionPolicy Remotesigned "& '%clientUnZipPsPath%' '%clientContainerZIP%' '%profilingClientFolder%' '%svcName%' '%conversionClientEXEname%' '%serverIP%' '%outputFolder%' '%clientFolder%' '%serverFolder%' '%totalRequest%' '%parallelBatch%'";

FOR /f %%i IN ("%clientContainerZipPath%") DO (
SET clientContainerFolder=%%~ni
SET psEXECfileDrive=%%~di
)

SET conversionClientPath=%currentPath%%clientContainerFolder%\%profilingClientFolder%
SET conversionClientEXE=%conversionClientPath%\%conversionClientEXEname%

REM PsExec (ClientContainer)
SET psEXECPath=%currentPath%%clientContainerFolder%\%psEXECfolder%
SET psEXECfilePath=%psEXECPath%\%psEXECfile%

REM Server Files/Folders details
SET serverZipPath=%currentPath%%serverZipName%
SET serverUnZipPSFile=%currentPath%%serverUnZipPsName%

REM Server path settings
SET serverDestFolder=%serverZipName%

REM "C:" directory is shared under C$ on server, by default 
SET serverZipFilePath=%serverBaseSetupPath%\%serverDestFolder%
SET serverPSFilePath=%serverBaseSetupPath%\%serverUnZipPsName%

SET serverWarmUpTime=10
SET pingRetryTimer=5

REM Validation
IF NOT "%serverZipPath%"=="" (
    IF NOT EXIST "%serverZipPath%" (
        ECHO Server Container Zip file: %serverZipPath% doesn't exists...
        GOTO End
    )
)

IF NOT "%serverUnZipPSFile%"=="" (
    IF NOT EXIST "%serverUnZipPSFile%" (
        ECHO ServerUnZip.ps1 file %serverUnZipPSFile% doesn't exists...
        GOTO End
    )
)

IF NOT "%psEXECfilePath%"=="" (
    IF NOT EXIST "%psEXECfilePath%" (
        ECHO PsExec.exe: %psEXECfilePath% doesn't exists...
        GOTO End
    )
)

IF NOT "%conversionClientEXE%"=="" (
    IF NOT EXIST "%conversionClientEXE%" (
        ECHO Profiler Client exe: %conversionClientEXE% doesn't exists...
        GOTO End
    )
)

ECHO server Zip File Path: %serverZipPath%
ECHO ServerUnZip.ps1 File Path: %serverUnZipPSFile%

ECHO Please wait...
Copy %serverZipPath% %serverDirectory%\
Copy %serverUnZipPSFile% %serverDirectory%\

TITLE %automationTitlePrefix% unzip %serverUnZipPsName%
ECHO Executing ServerUnZip.ps1 in %serverIP% Powershell session
Powershell -NoProfile -ExecutionPolicy Remotesigned "& '%currentPath%\%serverUnZipPsName%' '%serverDirectory%' '%serverZipName%' '%serverBaseDefaultFolder%' '%serverContainerFolder%' '%serverUpdateFolder%' '%serverPowershellFolder%' '%serverServiceLogFolder%' '%serverServiceLogFolder%'";

TITLE %automationTitlePrefix% Run %serverMasterPS%
ECHO Server configuration starts...
ECHO Executing %serverMasterPS% in %serverIP% Powershell session
Powershell -NoProfile -ExecutionPolicy Remotesigned "& '%serverPowershellPath%\%serverMasterPS%' '%serverDirectory%' '%serverZipName%' '%serverBaseDefaultFolder%' '%serverContainerFolder%' '%serverUpdateFolder%' '%serverPowershellFolder%' '%serverServiceLogFolder%' '%serverBinariesFolder%' '%serviceName%' '%applicationPort%' '%resourcePoolCount%' '%tempDiskSize%' '%virtualDiskSize%' '%msOfficeKeyFileName%' '%automateMMCFileName%' '%automationMode%' '%debugLog%'";

mkdir %serverBaseSetupPath%\%profilingClientFolder%\
Copy %conversionClientPath% %serverBaseSetupPath%\%profilingClientFolder%\

SET conversionClientPath=%serverBaseSetupPath%\%profilingClientFolder%
SET conversionClientEXE=%conversionClientPath%\%conversionClientEXEname%
SET ProfilingClientBatPath=%serverBaseSetupPath%\%ProfilingClientBat%

REM Create batch file to call Conversion Client
echo @ECHO off > %ProfilingClientBatPath% 
echo @echo off >> %ProfilingClientBatPath%
echo ECHO. >> %ProfilingClientBatPath%
echo @ECHO Calling Conversion Profiling Client... Please wait... >> %ProfilingClientBatPath%
echo START /B CMD /C CALL %conversionClientEXE% >> %ProfilingClientBatPath%

Timeout /T 5

SET linkName="ProfilerClient.lnk"
SET linkLocation="%userprofile%\desktop"
SET targetFile=%ProfilingClientBatPath%

IF EXIST "%linkLocation%\%linkName%" (
	del %linkLocation%\%linkName%
	)
mklink "%linkLocation%"\%linkName% %targetFile%

ECHO.

ECHO Please wait...
Timeout /T 10 /NOBREAK

powershell -Command Write-Host "Please stop doing any activity in server until server restarts, automatic navigation is going to happen in Component Service DCOM CONFIG window...." -foreground "Black" -BackgroundColor "Yellow"
Pause
START /B /wait CMD /C CALL %automateMMCbatPath%

TITLE %automationTitlePrefix% Restart alert
REM Alert user about server restart
powershell -Command Write-Host "Please save your work, server will restart..." -foreground "Red" -BackgroundColor "White"

Timeout /T 15

REM Let server re-start
TITLE %automationTitlePrefix% Re-start
Powershell -NoProfile -ExecutionPolicy Remotesigned "& '%serverPowershellPath%\MasterEnd.ps1'";


:End
Pause&Exit