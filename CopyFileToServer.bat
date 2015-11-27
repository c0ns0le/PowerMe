@ECHO off
SETLOCAL
COLOR 0f
SET automationTitlePrefix=Automation
TITLE %automationTitlePrefix%
SET /P serverIP=Please enter Server IP(Ex: 10.xx.xx.xxx):
SET /P serverUserName=Please enter Username to logon(Ex: Administrator):
SET /P serverPassword=Please enter your password:

::SET serverIP=10.0.30.248
::SET serverUserName=Administrator
::SET serverPassword=OFSW0rd

SET automationTitlePrefix=Automation[%serverIP%]:
SET currentPath=%~dp0

SET automationMode=Remote
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
SET serverDirectoryName=C
SET serverBaseDefaultFolder=temp
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

SET serverDirectory=%serverDirectoryName%:
SET serverDefaultShareName=%serverDirectoryName%$
SET serverBaseSetupPath=%serverDirectory%\%serverBaseDefaultFolder%\%serverContainerFolder%
SET serverPowershellPath=%serverDirectory%\%serverBaseDefaultFolder%\%serverContainerFolder%\%serverPowershellFolder%
SET WASPPath=%serverPowershellPath%\WASP.dll
SET automateMMCbatPath=%serverBaseSetupPath%\%automateMMCFileName%.bat

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
Powershell -NoProfile -ExecutionPolicy Bypass "& '%clientUnZipPsPath%' '%clientContainerZIP%' '%profilingClientFolder%' '%svcName%' '%conversionClientEXEname%' '%serverIP%' '%outputFolder%' '%clientFolder%' '%serverFolder%' '%totalRequest%' '%parallelBatch%'";

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
REM To establish connectivity to server path
SET serverNetPath=\\%serverIP%\%serverDefaultShareName%
REM "C:" directory is shared under C$ on server, by default 
SET serverZipFilePath=\\%serverIP%\%serverDefaultShareName%\%serverDestFolder%
SET serverPSFilePath=\\%serverIP%\%serverDefaultShareName%\%serverUnZipPsName%
REM set username with domain Ex: 10.X.X.XXX\Administrator(mydomain\username)
SET usrName=%serverIP%\%serverUserName%

SET serverWarmUpTime=10
SET pingRetryTimer=5

REM Validation
IF NOT "%serverIP%"=="" (
    IF NOT "%serverUserName%"=="" (
            IF "%serverPassword%"=="" (
                ECHO Password is empty...
                GOTO End
            )
    ) ELSE (
        ECHO Username is empty...
        GOTO End
    )
) ELSE (
    ECHO Server IP is empty...
    GOTO End
)

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

ECHO Username: %usrName%
ECHO server Zip File Path: %serverZipPath%
ECHO ServerUnZip.ps1 File Path: %serverUnZipPSFile%

TITLE %automationTitlePrefix% Connecting %serverIP%
REM Use net use to connect to and disconnect from a network resource
net use "%serverNetPath%" %serverPassword% /user:%usrName%

TITLE %automationTitlePrefix% Copying Server Container zip to %serverIP%
:COPY
ECHO Copying Container zip file to %serverZipFilePath% .... Please wait...
REM Copy Zip file
COPY "%serverZipPath%" "%serverZipFilePath%" 

TITLE %automationTitlePrefix% Copying PS file to %serverIP%
ECHO Copying Powershell file to %serverPSFilePath% .... Please wait...
REM Copy ServerUnZip.ps1 file
COPY "%serverUnZipPSFile%" "%serverPSFilePath%" 

REM Calling PsExec
TITLE %automationTitlePrefix% Change Powershell ExecutionPolicy
ECHO Changing Powershell ExecutionPolicy to RemoteSigned in server %serverIP%
%psEXECfilePath% \\%serverIP% -u %usrName% -p %serverPassword% powershell.exe Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

TITLE %automationTitlePrefix% unzip %serverUnZipPsName%
ECHO Executing ServerUnZip.ps1 in %serverIP% Powershell session
%psEXECfilePath% \\%serverIP% -u %usrName% -p %serverPassword% powershell.exe "& '%serverDirectory%\%serverUnZipPsName%' '%serverDirectory%' '%serverZipName%' '%serverBaseDefaultFolder%' '%serverContainerFolder%' '%serverUpdateFolder%' '%serverPowershellFolder%' '%serverServiceLogFolder%'";

TITLE %automationTitlePrefix% Run %serverMasterPS%
ECHO Server configuration starts...
ECHO Executing %serverMasterPS% in %serverIP% Powershell session
%psEXECfilePath% \\%serverIP% -u %usrName% -p %serverPassword% powershell.exe "& '%serverPowershellPath%\%serverMasterPS%' '%serverDirectory%' '%serverZipName%' '%serverBaseDefaultFolder%' '%serverContainerFolder%' '%serverUpdateFolder%' '%serverPowershellFolder%' '%serverServiceLogFolder%' '%serverBinariesFolder%' '%serviceName%' '%applicationPort%' '%resourcePoolCount%' '%tempDiskSize%' '%virtualDiskSize%' '%msOfficeKeyFileName%' '%automateMMCFileName%' '%automationMode%' '%debugLog%'";

TITLE %automationTitlePrefix% Re-start
%psEXECfilePath% \\%serverIP% -u %usrName% -p %serverPassword% powershell.exe "& '%serverPowershellPath%\MasterEnd.ps1'";

ECHO.
ECHO.
REM Let server re-start
@ECHO Server restarted Please wait...
Timeout /T 30 /NOBREAK

REM ************************************************
REM Ping server
REM Call Conversion Profiling Client on successful ping
REM ************************************************

:StartPing
TITLE %automationTitlePrefix% Ping %serverIP%
COLOR 0f
PING -n 1 %serverIP%
IF %errorlevel% == 0 GOTO ServerAvailable 

REM Wait for X seconds before trying again
TITLE %automationTitlePrefix% %serverIP% not available. Re-connecting...
COLOR 06
@ECHO Waiting for %pingRetryTimer% seconds to check server availability...
PING -n %pingRetryTimer% %serverIP% > NUL

REM Loopback to StartPing
GOTO StartPing 

REM Initiate remote desktop session
:ServerAvailable
TITLE %automationTitlePrefix% %serverIP% available
COLOR 0f
ECHO.
@ECHO ***************************************
@ECHO *Server: %serverIP% is available now
@ECHO ***************************************

ECHO.
@ECHO Please wait...
TIMEOUT %serverWarmUpTime% >NUL

TITLE %automationTitlePrefix% Open %serverIP% RDP session
CMDKEY /generic:TERMSRV/%serverIP% /user:%serverUserName% /pass:%serverPassword%
START MSTSC /v:%serverIP%

ECHO.
REM Let server boot up...
@ECHO Please do not disturb RDP session
Timeout /T 45 /NOBREAK

REM Open dcomcnfg.mmc console
::%psEXECfilePath% \\%serverIP% -u %usrName% -p %serverPassword% powershell.exe "& '%serverPowershellPath%\AutomateMMC.ps1' '%automateMMCbatPath%'";

@ECHO Please click %automateMMCFileName% shortcut link on server[%serverIP%] desktop to continue... and
Pause

TITLE %automationTitlePrefix% Change Powershell ExecutionPolicy
ECHO Changing Powershell ExecutionPolicy to Restricted in server %serverIP%
%psEXECfilePath% \\%serverIP% -u %usrName% -p %serverPassword% powershell.exe Set-ExecutionPolicy -ExecutionPolicy Restricted

TITLE %automationTitlePrefix% Calling Conversion Profiling Client
ECHO.
ECHO.
@ECHO Calling Conversion Profiling Client... Please wait...
Timeout /T 45 /NOBREAK

ECHO.
ECHO.

START /B CMD /C CALL %conversionClientEXE%

:End
ECHO.

ENDLOCAL
