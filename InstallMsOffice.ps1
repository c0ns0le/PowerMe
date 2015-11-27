Function CreateMsOfficeSetupConfig()
{
    Param($msOfficeKey, $configFilePath)
    
    # get an XMLTextWriter to create the XML
    $XmlWriter = New-Object System.XMl.XmlTextWriter($configFilePath,$Null)
 
    # choose a pretty formatting:
    $xmlWriter.Formatting = 'Indented'
    $xmlWriter.Indentation = 1
    $XmlWriter.IndentChar = "`t"
 
    # write the header
    $xmlWriter.WriteStartDocument()
  
    $xmlWriter.WriteStartElement('Configuration')
    $XmlWriter.WriteAttributeString('Product', 'ProPlusr')
    
        #Display Node
        $xmlWriter.WriteStartElement('Display')
        $XmlWriter.WriteAttributeString('Level', 'none')
        $XmlWriter.WriteAttributeString('CompletionNotice', 'no')
        $XmlWriter.WriteAttributeString('SuppressModal', 'yes')
        $XmlWriter.WriteAttributeString('AcceptEula', 'yes')
        $xmlWriter.WriteEndElement()

        $xmlWriter.WriteStartElement('Setting')
        $XmlWriter.WriteAttributeString('Id', 'SETUP_REBOOT')
        $XmlWriter.WriteAttributeString('Value', 'Never')
        $xmlWriter.WriteEndElement()

        $xmlWriter.WriteStartElement('Setting')
        $XmlWriter.WriteAttributeString('Id', 'REBOOT')
        $XmlWriter.WriteAttributeString('Value', 'ReallySuppress')
        $xmlWriter.WriteEndElement()

        $xmlWriter.WriteStartElement('PIDKEY')
        $XmlWriter.WriteAttributeString('Value', $msOfficeKey)        
        $xmlWriter.WriteEndElement()

        $xmlWriter.WriteStartElement('Setting')
        $XmlWriter.WriteAttributeString('Id', 'AUTO_ACTIVATE')
        $XmlWriter.WriteAttributeString('Value', '1')
        $xmlWriter.WriteEndElement()

    # close the "Configuration" node
    $xmlWriter.WriteEndElement()

    # finalize the document:
    $xmlWriter.WriteEndDocument()
    $xmlWriter.Flush()
    $xmlWriter.Close()

    Log "I" "Created config file for MS-Office installation with Product Key: $msOfficeKey"
 
}

Function InstallOffice()
{
    Param($officeSetupPath, $officeConfigPath)
    
    $isConfigExists = Test-Path($officeConfigPath)
    $isSetUpExists = Test-Path($officeConfigPath)

    Try
    {
        If($isConfigExists -eq $true -and $isSetUpExists -eq $true)
        {
            Log "H" "Installing MS-Office... Please wait..."
            
            $configPath = "/Config " + $officeConfigPath
            $process = [Diagnostics.Process]::Start($officeSetupPath, $configPath)
            $process.WaitForExit()            
            Log "S" "MS-Office installed..."
        }
        Else
        {
            Log "F" "Office installation failed, either '$officeConfigPath' file or '$officeSetupPath' not available."
        }
    }
    Catch [Exception]
    {
        Log "E" $_.Exception.Message
    }
}

Function InstallMSoffice()
{   
    Param ($officeImgPath)
    Try
    {        
        If($Global:msOfficeProductKey -eq "")
        {
            Log "F" "MS-Office key is not available, cannot proceed MS Office installation...`n Check $Global:officeKeyFilePath"
            return
        }
        #Mount MsOfficeImageFile
        If($Global:is2012R2 -eq $true)
        {
            Mount-DiskImage -ImagePath $officeImgPath  
            Start-Sleep -Seconds 3  
        }        
        $serverDrives = [System.IO.DriveInfo]::GetDrives() | ? {$_.DriveType -eq "CDRom" -and $_.VolumeLabel -ne $null}
        Log "I" "MS-Office image file mounted to drive: $($serverDrives.Name)"
                
        $Global:officeSetupPath = "{0}{1}" -f $serverDrives, "setup.exe"

        If(Test-Path $Global:officeSetupPath)
        {
            Log "I" "MS-Office installation starts here... $Global:officeSetupPath"
            CreateMsOfficeSetupConfig $Global:msOfficeProductKey $Global:silentInstallationConfig
            InstallOffice $Global:officeSetupPath $Global:silentInstallationConfig

            Start-Sleep -Seconds 3
            #Dismount MsOfficeImageFile
            If($Global:is2012R2 -eq $true)
            {
                Dismount-DiskImage -ImagePath $officeImgPath
            }
            Else
            {
                cmd.exe "/wait /c $Global:unMountMsOfficeSetupBatFilename"
                Start-Sleep -Seconds 2
                Remove-Item $Global:unMountMsOfficeSetupBatFilename -Force -ErrorAction SilentlyContinue
            }            
            Log "I" "Image file $officeImgPath dismounted from $Global:officeSetupPath"
        }
        Else
        {
            Log "F" "$Global:officeSetupPath not found. MS-Office installation failed."
        }
    }
    Catch [Exception]
    {
        Log "E" $_.Exception.Message
    }
}

Log "H" "MS-Office installation start"

InstallMSoffice $Global:msOfficeImagePath

Log "H" "MS-Office installation end"

Start-Sleep -Seconds 5