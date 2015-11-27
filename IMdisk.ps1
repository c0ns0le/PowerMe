Function Install_IMdisk_CreateVD()
{
    Param($imFilePath, $virtualDiskT, $virtualDiskV, $virtualDiskTSize, $virtualDiskVSize)
    
    $batFilePath = $imFilePath | split-path -parent
    
    Log "D" "Batch file path: $batFilePath"
    Log "I" "Creating Virtual disks '$virtualDiskT ($virtualDiskTSize)' and '$virtualDiskV ($virtualDiskVSize)'"
    #Commands    
    $installCommand = $imFilePath + ' /fullsilent /lang:English'

    $virtualDiskCommand = 'ImDisk.exe -a -t vm -m ' + $virtualDiskT + ' -o rw,fix,hd -s ' + $virtualDiskTSize + ' -p "/FS:NTFS /q /v:IMDISK /y"
ImDisk.exe -a -t vm -m ' + $virtualDiskV + ' -o rw,fix,hd -s ' + $virtualDiskVSize + ' -p "/FS:NTFS /q /v:IMDISK /y"'

    #Temp BAT file path
    $iMdiskInstallerFilename = "{0}\{1}" -f $batFilePath, $Global:installIMdiskBatName
    $virtualDiskBatFilename = "{0}\{1}" -f $batFilePath, $Global:CreateVirtualDiskBatName

    Log "D" "installFilename: $iMdiskInstallerFilename; virtualDiskBatFilename: $virtualDiskBatFilename"

    # Create file
    $installCommand | Set-Content $iMdiskInstallerFilename
    $virtualDiskCommand | Set-Content $virtualDiskBatFilename
        
    #Execute BAT files
    #cmd.exe "/wait /c $iMdiskInstallerFilename"
    Start-Process -FilePath $iMdiskInstallerFilename -Wait -passthru;
    Start-Sleep -Seconds 5
    #cmd.exe "/wait /c $virtualDiskBatFilename"
    Start-Process -FilePath $virtualDiskBatFilename -Wait -passthru;
    If($Global:is2012R2 -eq $false)
    {
        $mountMsOfficeSetupCommand = 'ImDisk.exe -a -m H: -f {0}' -f $Global:msOfficeImagePath
        $unMountMsOfficeSetupCommand = 'imdisk.exe -D -m H:'

        $mountMsOfficeSetupBatFilename = $batFilePath + "\MountMsOfficeISOfile.bat"
        $Global:unMountMsOfficeSetupBatFilename = $batFilePath + "\UnMountMsOfficeISOfile.bat"
        
        $mountMsOfficeSetupCommand | Set-Content $mountMsOfficeSetupBatFilename
        $unMountMsOfficeSetupCommand | Set-Content $Global:unMountMsOfficeSetupBatFilename

        #cmd.exe "/wait /c $mountMsOfficeSetupBatFilename"        
        Start-Process -FilePath $mountMsOfficeSetupBatFilename -Wait -passthru;

        Start-Sleep -Seconds 2
        Remove-Item $mountMsOfficeSetupBatFilename -Force -ErrorAction SilentlyContinue
    }
        
    CreateShortcut $iMdiskInstallerFilename $Global:IMdiskInstallerLinkName
    CreateShortcut $virtualDiskBatFilename $Global:IMdiskDiskCreationLinkName
        
    #Add VirtualDiskCreation batch file to startup registry
    New-ItemProperty -Name AutoRun -Path "HKLM:\Software\Microsoft\Command Processor" -PropertyType String -Value "$virtualDiskBatFilename" -ErrorAction SilentlyContinue    
}

Function AutomateMMCbat($pathToSave)
{
    $batFilePath = $Global:ImDiskExePath | split-path -parent
    
    $powershellPath = "{0}\{1}\{2}" -f $Global:setupPath, $Global:powerShellFolder, $Global:automateMMCpsFileName
    $WASPpath = "{0}\{1}\{2}" -f $Global:setupPath, $Global:powerShellFolder, $Global:waspDll
    $profilingClientBatPath = "{0}\{1}.bat" -f $Global:setupPath, $Global:ApplicationName
    $virtualDiskBatFilename = "{0}\{1}" -f $batFilePath, $Global:CreateVirtualDiskBatName
    
    $mmcAutomationBatFilename = "{0}\{1}" -f $pathToSave, $Global:AutomateMMCBatName

    $mmcAutomationCommand = '
@ECHO off
@echo off
powershell -Command Write-Host "Please do not click anywhere, kindly be patient until batch execution complete." -foreground "Red" -BackgroundColor "White";
Timeout /T 10 /NOBREAK
Powershell.exe ' + $powershellPath + ' ' + $WASPpath + ';'
        
    $mmcAutomationCommand | Set-Content $mmcAutomationBatFilename
    
    Log "I" "Create a shortcut on desktop for $Global:AutomateMMCBatName"
    CreateShortcut $mmcAutomationBatFilename $Global:AutomateMMCLinkName
    Log "D" "MMC automation .bat file path: $mmcAutomationBatFilename, shortcut link: '$Global:AutomateMMCLinkName' created on desktop"
}

Log "H" "IMdisk installation and virtual disk creation start"
Install_IMdisk_CreateVD $Global:ImDiskExePath $Global:tempDisk $Global:virtualDisk $Global:tempDiskSize $Global:VirtualDiskSize
Log "H" "IMdisk installation and virtual disk creation end"

Log "H" "Create .bat file to automate MMC navigation"
AutomateMMCbat $Global:baseSetupFolder
 
Start-Sleep -Seconds 2