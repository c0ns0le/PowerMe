Function ChangeTempVarPath
{
    Param($envTempPath, $envProp, $newPath)

    #ChangeTempVarPath "HKLM:\System\CurrentControlSet\Control\Session Manager\Environment\" "TEMP" "C:\tools\"
    #ChangeTempVarPath $Global:tempEnvPath $Global:tempEnvProp $Global:tempDisk
    #$newPath = %USERPROFILE%\AppData\Local\Temp
    
    Log "I" "Changing '$envProp' variable path to $newPath"
    Log "D" "oldPath: $envTempPath <> newPath: $newPath"

    If(Test-Path $envTempPath)
    {
        If(Test-Path $newPath)
        {
            Set-ItemProperty -Name $envProp -Path $envTempPath -Value $newPath            
        }
        Else
        {
            Log "F" "'$newPath' doesn't exists..."
        }
    }
    Else
    {
        Log "F" "'$envTempPath' doesn't exists..."
    }
}

#ChangeTempVarPath "HKLM:\System\CurrentControlSet\Control\Session Manager\Environment\" "TEMP" "C:\tools\"

Log "H" "ChangeTempPath start"
ChangeTempVarPath $Global:tempEnvPath $Global:tempEnvProp $Global:tempDisk
ChangeTempVarPath $Global:tempEnvPath $Global:tmpEnvProp $Global:virtualDisk
Log "H" "ChangeTempPath end"

Start-Sleep -Seconds 3
