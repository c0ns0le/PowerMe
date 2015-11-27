Param($baseWindowsDir, $sourceZipFileName, $baseDefaultFolder, $setupFolder, $updateFolder, $powerShellFolder, $serviceLogFolder, $serverBinariesFolder, $serviceName, $applicationPort, $resourcePoolCount, $tempDiskSize, $virtualDiskSize, $msOfficeKeyFileName, $automateMMCFileName, $automationMode, $debugLog)

$Global:ScripStartTimestamp = $(get-date -f MM-dd-yyyy) + "_" + $(get-date -f HH-mm-ss)

#AppLevel
$Global:AutomationDebuggerLog = $debugLog

#Automation Log file name
$Global:automationLogFileName = "AutomationLog_{0}.log" -f $Global:ScripStartTimestamp

#User input
#Base Folders
$Global:baseDefaultFolder = $baseDefaultFolder
$Global:setupFolder = $setupFolder
$Global:updateFolder = $updateFolder
$Global:powerShellFolder = $powerShellFolder
$Global:serviceLogFolder = $serviceLogFolder

#Path setter
$baseDirName = GET-WMIOBJECT –query "SELECT * from win32_logicaldisk where DriveType = '3'"
$Global:baseWindowsDir = "{0}" -f $baseWindowsDir

$Global:baseDefaultLocation = "{0}\{1}" -f $Global:baseWindowsDir, $Global:baseDefaultFolder # "C:\temp"
$Global:setupPath = "{0}\{1}" -f $Global:baseDefaultLocation, $Global:setupFolder
$Global:updatePath = "{0}\{1}" -f $Global:baseDefaultLocation, $Global:updateFolder

#Deploy and Revert Folders
$Global:prevBinariesBackupFolder = "Previous.{0}" -f $serverBinariesFolder # "Previous.ConversionService"
$Global:revertedBinariesFolder = "Reverted.{0}" -f $serverBinariesFolder # "Reverted.ConversionService"

#Zip folder content details
$Global:msOfficeImageFilename = "OfficeProfessionalPlus_x64_en-us.iso"
$Global:officeKeyFileName = $msOfficeKeyFileName #"MsOfficeKey.txt"
$Global:conversionServiceAppFolder = $serverBinariesFolder #"ConversionService"

#Application Service core details
$Global:ApplicationName = $serviceName #"ConversionService"
$Global:ApplicationPoolName = $Global:ApplicationName

#ConversionService Config
$Global:resourcePoolCount = $resourcePoolCount

#Virtual disk(IMdisk) details
$Global:tempDisk = "T:"
$Global:tempDiskSize = $tempDiskSize

$Global:virtualDisk = "V:"
$Global:VirtualDiskSize = $virtualDiskSize

$myDirectoryPath = Split-Path $script:MyInvocation.MyCommand.Path

$Global:baseSetupFolder = $Global:setupPath
$Global:baseFolder = $myDirectoryPath
$Global:parentFolderPath = $Global:baseSetupFolder # (Get-Item $Global:baseFolder).parent.fullname

#Powershell automation log path
$Global:logfile = "{0}\{1}" -f $Global:parentFolderPath, $Global:automationLogFileName

#Service Application and Pool Details
$Global:DefaultWebSite = "Default Web Site"
$Global:DefaultIISpoolPath = "IIS:\AppPools\"
$Global:DefaultApplicationPoolName = "DefaultAppPool"
$Global:ApplicationPort = $applicationPort
$Global:applicationIdentityType = "LocalSystem"
$Global:applicationPipelineMode = "Classic"
$Global:appRuntimeVersion = "v4.0"
$Global:idleTimeoutAction = "Suspend"
$Global:workerStartMode = "AlwaysRunning"
$Global:alternativePort = "8081"
$Global:ApplicationFilePath = "{0}\{1}" -f $Global:parentFolderPath, $Global:conversionServiceAppFolder
$Global:appPoolUN = $null
$Global:appPoolPwd = $null
$Global:appLogFolders = "{0}\{1}" -f $Global:setupPath, $Global:serviceLogFolder
$Global:applicationWebConfig = "{0}\Web.config" -f $Global:ApplicationFilePath

#MMC-AutoNavigation
$Global:automateMMCpsFileName = "StartUp.ps1"
$Global:waspDll = "WASP.dll"

#FileNames
$Global:installIMdiskBatName = "installImDisk.bat"
$Global:CreateVirtualDiskBatName = "CreateVirtualDisk.bat"
$Global:AutomateMMCBatName = "{0}.bat" -f $automateMMCFileName
$Global:AutomateMMCLinkName = $automateMMCFileName
$Global:IMdiskInstallerLinkName = "InstallIMdisk"
$Global:IMdiskDiskCreationLinkName = "CreateVirtualDisk"

#MS-Office
##reference: InstallMsOffice.ps1
$Global:msOfficeImagePath = "{0}\{1}" -f $Global:parentFolderPath, $Global:msOfficeImageFilename

$Global:officeKeyFilePath = "{0}\{1}" -f $Global:parentFolderPath, $Global:officeKeyFileName
$Global:officeSetupPath = "{0}\MsOffice\setup.exe" -f $Global:parentFolderPath #Getting updated in InstallMsOffice.ps1
$Global:unMountMsOfficeSetupBatFilename = ""

$Global:silentInstallationConfig = "{0}\dynamicMsOfficeConfig.xml" -f $Global:parentFolderPath
#$Global:msOfficeProductKey = "2MQHJ-9N49X-7WVMH-PTWCH-XD43F"
$Global:msOfficeProductKey = Get-Content $Global:officeKeyFilePath -ErrorAction SilentlyContinue

#RegistryEdit
##Get AppID from location: HKLM:\Software\Classes\AppID
$Global:WordAppID = "{03837503-098b-11d8-9414-505054503030}"

$Global:adminUser = "{0}\{1}" -f $env:COMPUTERNAME, "Administrator"

##Microsoft Word 97 - 2003 Document(RunAs Interactive User) HKEY_CLASSES_ROOT\AppID\{00020906-0000-0000-C000-000000000046}
$Global:MSWkeyPath = "Registry::HKEY_CLASSES_ROOT\AppID\"
$Global:MSWordAppID = "{00020906-0000-0000-C000-000000000046}"
$Global:MSWProperty = "RunAs"
$Global:MSWType = "String"
#$Global:MSWValue = $Global:adminUser #"Interactive User"
$Global:MSWValue = "Interactive User"

##To ignore MS office First things first
$Global:regDWordType = "DWORD"
$Global:regDWordValue1 = "00000001"
$Global:regDWordValue0 = "00000000"

$Global:office2013RegPath = "HKLM:\Software\Microsoft\Office\15.0\"
$Global:office2013RegPathHKCU = "HKCU:\Software\Microsoft\Office\15.0\"
$Global:regItemRegistration = "Registration"
$Global:regItemFirstRun = "FirstRun"
$Global:regPropCommon = "Common"

$Global:regOffice2013CommonPath = "{0}{1}\" -f $Global:office2013RegPath, $Global:regPropCommon
$Global:regOffice2013CommonPathHKCU = "{0}{1}\" -f $Global:office2013RegPathHKCU, $Global:regPropCommon

##Run Once
$Global:regCurrentVersion = "HKLM:\Software\Microsoft\Windows\CurrentVersion\"
$Global:regItemRunOnce = "RunOnce"

#Users
$Global:OwnerTo = "Administrators"
$Global:AllUser = "Everyone"
$Global:LaunchAndActivationPermissionTo = "Everyone"

#User Access
$Global:UserAccessLevel = "FullControl"

#ClientTelemetry variables
$Global:keyTelePath = "HKLM:\Software\Microsoft\Office\Common\"
$Global:itemTeleNode = "ClientTelemetry"
$Global:itemTeleProperty = "DisableTelemetry"
$Global:itemTeleType = "String"
$Global:itemTeleValue = "1"

#ImDisk
$Global:ImDiskExePath = "{0}\ImDiskTk.exe" -f $Global:parentFolderPath

#Environment variable path
$Global:tempEnvPath = "HKLM:\System\CurrentControlSet\Control\Session Manager\Environment\"
$Global:tempEnvProp = "Temp"
$Global:tmpEnvProp = "TMP"

#Messages
$Global:infoMessageTag = "Info: "
$Global:successMessageTag = "Executed successfully: "
$Global:failureMessageTag = "Failure: "
$Global:exceptionMessageTag = "Exception: "
$Global:neutralMessageTag = ""
$Global:debugMessageTag = "Debug Info: "
$Global:headerMessageTag = "`n"

#CmdLet Colors
$Global:infoColor = "Green"
$Global:successColor = "Yellow"
$Global:failureColor = "Red"
$Global:exceptionColor = "White"
$Global:neutralColor = "White"
$Global:debugColor = "Blue"
$Global:headerColor = "Blue"

$Global:debugBGColor = "White"
$Global:exceptionBGColor = "Red"
$Global:headerBGColor = "White"

#Global functions
Function InitAutomation()
{
    if ((Test-Path $Global:Logfile))
    {
        Log "D" "Removing existing $Global:Logfile ..."   
        Remove-Item -Path $Global:Logfile -Force
    }       
}

Function Log($MsgType, $Msg)
{
    $LogType = ''
    #MessageType: Info; Success; Failure; Exception; Header; Debug
    If($MsgType -eq "Info" -or $MsgType -eq "info" -or $MsgType -eq "I" -or $MsgType -eq "i")
    {
        $LogType = $Global:infoMessageTag
        Write-Host -ForegroundColor $Global:infoColor ($Global:infoMessageTag + $Msg)
        WriteLogToFile "$LogType - $Msg"
    }
    ElseIf($MsgType -eq "Success" -or $MsgType -eq "success" -or $MsgType -eq "S" -or $MsgType -eq "s")
    {
        $LogType = $Global:successMessageTag
        Write-Host -ForegroundColor $Global:successColor ($Global:successMessageTag + $Msg)
        WriteLogToFile "$LogType - $Msg"
    }
    ElseIf($MsgType -eq "Failure" -or $MsgType -eq "failure" -or $MsgType -eq "F" -or $MsgType -eq "f")
    {
        $LogType = $Global:failureMessageTag
        Write-Host -ForegroundColor $Global:failureColor ($Global:failureMessageTag + $Msg)
        WriteLogToFile "$LogType - $Msg"
    }
    ElseIf($MsgType -eq "Exception" -or $MsgType -eq "exception" -or $MsgType -eq "E" -or $MsgType -eq "e")
    {
        $LogType = $Global:exceptionMessageTag
        Write-Host -ForegroundColor $Global:exceptionColor -BackgroundColor $Global:exceptionBGColor ($Global:exceptionMessageTag + $Msg)
        WriteLogToFile "$LogType - $Msg"
    }
    ElseIf($MsgType -eq "Header" -or $MsgType -eq "header" -or $MsgType -eq "H" -or $MsgType -eq "h")
    {
        $LogType = "=>"
        Write-Host -ForegroundColor $Global:headerColor -BackgroundColor $Global:headerBGColor ($Global:headerMessageTag + $Msg + $Global:headerMessageTag)
        WriteLogToFile "$LogType - $Msg"
    }
    ElseIf($MsgType -eq "Debug" -or $MsgType -eq "debug" -or $MsgType -eq "D" -or $MsgType -eq "d")
    {
        $LogType = $Global:debugMessageTag
        If($Global:AutomationDebuggerLog -eq $true)
        {
            Write-Host -ForegroundColor $Global:debugColor -BackgroundColor $Global:debugBGColor ($Global:debugMessageTag + $Msg)
            WriteLogToFile "$LogType - $Msg"
        }
    }
    Else
    {
        $LogType = $Global:neutralMessageTag
        Write-Host -ForegroundColor $Global:neutralColor ($Global:neutralMessageTag + $Msg)
        WriteLogToFile "$LogType - $Msg"
    }
}

Function WriteLogToFile()
{
    Param ([string]$logstring)
    
    if (!(Test-Path $Global:parentFolderPath)) 
    {
        New-Item -ItemType directory -Path $Global:parentFolderPath -Force -ErrorAction SilentlyContinue
        
        New-Item -ItemType file -Path $Global:logfile -Force -ErrorAction SilentlyContinue
    }
    
    Add-content $Global:logfile -value $logstring -ErrorAction SilentlyContinue
}

$Global:serverIPv4 = ""

Function OSdetails()
{
    $serverOS = Get-WmiObject -class Win32_OperatingSystem -computername .
    $serverOS | Select-Object Description, Caption, OSArchitecture, ServicePackMajorVersion | Format-List

    $Global:is2012R2 = $false
    If($serverOS.Caption -Match "2012 R2")
    {
        $Global:is2012R2 = $true
        
        $ip4 = Get-NetIPAddress –InterfaceIndex 12 -AddressFamily IPv4 -ErrorAction SilentlyContinue
        $Global:serverIPv4 = $ip4.IPAddress
    }
    $Global:serverOScaption = $serverOS.Caption
    $Global:serverDetails = "{0}({1}) [Service Pack: {2}]" -f $serverOS.Caption, $serverOS.OSArchitecture, $serverOS.ServicePackMajorVersion
}

OSdetails

Function AppSettingsInfo()
{
    Log "H" "-------------------Application Setup information-------------------"
    Log "" "$Global:serverDetails [IPv4: $Global:serverIPv4] `n
`Application name: $Global:ApplicationName `n
`Application Pool name: $Global:ApplicationPoolName `n
`Application Port: $Global:ApplicationPort `n
`Application Path:  $Global:ApplicationFilePath `n
`MS Office setup path: $Global:msOfficeImagePath `n
`MS Office Key: $Global:msOfficeProductKey `n
`MS Office Dynamic Config: $Global:silentInstallationConfig `n
`ImDiskExe: $Global:ImDiskExePath `n
`Automation log file: $Global:logfile"
    Log "H" "-------------------****************************-------------------"
}

Function RestartIIS($command = "IISRESET")
{
    If(($command -eq "stop") -or ($command -eq "STOP"))
    {
        Log "H" "Stoping IIS"
        $command = "IISRESET /STOP"
        Invoke-Expression -Command:$command
    }
    ElseIf(($command -eq "start") -or ($command -eq "START"))
    {
        Log "H" "Starting IIS"
        $command = "IISRESET /START"
        Invoke-Expression -Command:$command
    }
    Else
    {
        Log "H" "Resetting IIS"
        $command = "IISRESET"
        Invoke-Expression -Command:$command
    }
}

Function LogOffUsers()
{
    Log "H" "Logging off all users from server: $Global:serverIPv4"
    $SERVER = $Global:serverIPv4
    Try 
    {
        query user /server:$SERVER 2>&1 | select -skip 1 | foreach {
            logoff ($_ -split "\s+")[-6] /server:$SERVER
        }
    }
    Catch {}
}

Function CreateShortcut($TargetFile, $linkName)
{
    #Create a Shortcut on All User Desktops
    $ShortcutFile = "$env:Public\Desktop\$linkName.lnk"
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = $TargetFile
    $Shortcut.Save()
}


InitAutomation

AppSettingsInfo

Log "D" "Set global Variables and Functions..."
Log "I" "Automation script execution: $automationMode"
