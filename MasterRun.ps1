Param($baseWindowsDir, $sourceZipFileName, $baseDefaultFolder, $setupFolder, $updateFolder, $powerShellFolder, $serviceLogFolder, $serverBinariesFolder, $serviceName, $applicationPort, $resourcePoolCount, $tempDiskSize, $virtualDiskSize, $msOfficeKeyFileName, $automateMMCFileName, $automationMode, $debugLog)

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

#PolicyAndElavated.ps1
. "$scriptPath\PolicyAndElavated.ps1" | Out-Null

#Global variables and Functions
. "$scriptPath\GlobalVar.ps1" $baseWindowsDir $sourceZipFileName $baseDefaultFolder $setupFolder $updateFolder $powerShellFolder $serviceLogFolder $serverBinariesFolder $serviceName $applicationPort $resourcePoolCount $tempDiskSize $virtualDiskSize $msOfficeKeyFileName $automateMMCFileName $automationMode $debugLog | Out-Null

#Create folders
. "$scriptPath\CreateFolders.ps1" | Out-Null

#ConfigIIS.ps1
. "$scriptPath\ConfigIIS.ps1" | Out-Null

#EnablePrivilege.ps1
. "$scriptPath\EnablePrivilege.ps1" | Out-Null

#IMdisk.ps1: Install IM-Disk and create Virtual Disk
. "$scriptPath\IMdisk.ps1" | Out-Null

#InstallMsOffice.ps1: Create config for silent installation and InstallMsOffice.ps1
. "$scriptPath\InstallMsOffice.ps1" | Out-Null

#RegistryEditor.ps1
##Disable ClientTelemetry
##Microsoft Word 97 - 2003 Document(RunAs Interactive User)
#To avoid MS OFFICE 'First things first' wizard
. "$scriptPath\RegistryEditor.ps1" | Out-Null

#LaunchAndActivationPermission.ps1 (Dcom settings: Launch And Activation Permission)
. "$scriptPath\LaunchAndActivationPermission.ps1" | Out-Null

#ChangingOwnership.ps1(Ownership to MS-Word AppID)
. "$scriptPath\ChangingOwnership.ps1" | Out-Null

#CreateWebsite.ps1: Create Virtual directory in ISS and AppPool
. "$scriptPath\CreateWebsite.ps1" | Out-Null

#UpdateConfigFiles.ps1: Update Conversion Service web.config and Client's app.config
. "$scriptPath\UpdateConfigFiles.ps1" | Out-Null

#ChangeTempPath.ps1: Change Environment TEMP variable path
. "$scriptPath\ChangeTempPath.ps1" | Out-Null

