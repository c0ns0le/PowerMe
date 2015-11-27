Clear-Host

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

#PolicyAndElavated.ps1
. "$scriptPath\PolicyAndElavated.ps1" | Out-Null

#Global variables and Functions
. "$scriptPath\GlobalVar.ps1" | Out-Null


Function Revert()
{
    Log "H" "Revert start"
    Try
    {
        $binariesBkpUpFolder = $Global:prevBinariesBackupFolder
        $appLocation = $Global:ApplicationFilePath  #"C:\temp\setup\ConversionService"

        $prevConversionService = "{0}\{1}" -f $Global:updatePath, $binariesBkpUpFolder    
        $revertedConversionService = "{0}\{1}" -f $Global:updatePath, $Global:revertedBinariesFolder

        If ((Test-Path "$prevConversionService"))
        {
            RestartIIS "stop"
            Log "I" "Moving binaries to: $revertedConversionService"
            Move-Item $appLocation $revertedConversionService
            Log "I" "Restoring binaries with previous backup: $prevConversionService"
            Move-Item $prevConversionService $appLocation
            RestartIIS "start"
        }
        Else
        {
            Log "F" "Restoration failed. Backup location: $prevConversionService does not exist."
            throw
        }
    }
    Catch [Exception]
    {
        Log "F" "Restoration failed.`n $($_.Exception.GetType().FullName) $($_.Exception.Message )"
        throw
    }
    Log "H" "Revert end"
}

Revert

Start-Sleep -Seconds 3