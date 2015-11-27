Function UpdateConversionServiceConfig()
{
    Param ($ConversionServiceConfigPath, $DestinationFilePath, $MasterPath, $PoolingCount)

    [xml]$conversionClientConfig = Get-Content $ConversionServiceConfigPath
    
    Log "I" "Updating Config file"
    foreach($keys in $conversionClientConfig.configuration.appSettings.add | Where-Object {$_.Key -match "DestinationFilePath" -or $_.Key -match "MasterPath" -or $_.Key -match "PoolingCount"}) 
    {
        If($keys.Key -eq "DestinationFilePath")
        {            
            $keys.Value = $DestinationFilePath         
        }
        ElseIf($keys.Key -eq "MasterPath")
        {
            $keys.Value = $MasterPath         
        }
        ElseIf($keys.Key -eq "PoolingCount")
        {
            $keys.Value = [string]$PoolingCount         
        }
    }
    $conversionClientConfig.Save($ConversionServiceConfigPath)
}

Log "H" "Update config files start"
UpdateConversionServiceConfig $Global:applicationWebConfig $Global:virtualDisk $Global:appLogFolders $Global:resourcePoolCount
Log "H" "Update config files end"

Start-Sleep -Seconds 3