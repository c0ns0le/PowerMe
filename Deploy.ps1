Clear-Host

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

#PolicyAndElavated.ps1
. "$scriptPath\PolicyAndElavated.ps1" | Out-Null

#Global variables and Functions
. "$scriptPath\GlobalVar.ps1" | Out-Null


Function Deploy()
{
    Log "H" "Deploy start"
    $deployZip = "ConversionService.zip"
    $sourceZipFile = "{0}\{1}" -f $Global:updatePath, $deployZip #"C:\temp\update\ConversionService.zip"    
    $destLocation = $Global:ApplicationFilePath  #"C:\temp\setup\ConversionService"
    
    $binariesBkpUpFolder = $Global:prevBinariesBackupFolder
    $backupLocation = $Global:updatePath #Split-Path $sourceZipFile
    $revertedConversionService = "{0}\{1}" -f $Global:updatePath, $Global:revertedBinariesFolder
    
    $prevConversionService = "{0}\{1}" -f $backupLocation, $binariesBkpUpFolder
    $extractedLocation = "{0}\{1}" -f  $destLocation, [io.path]::GetFileNameWithoutExtension($sourceZipFile)
        
    if ((Test-Path "$destLocation"))
    {        
        Try
        {
            RestartIIS "stop"
            
            Log "I" "Taking back-up of $destLocation to $prevConversionService"
            Remove-Item $prevConversionService -Recurse -ErrorAction SilentlyContinue

            Move-Item $destLocation $prevConversionService
            
            Log "I" "Extracting $sourceZipFile"
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($sourceZipFile, $destLocation)        

            Log "I" "Updating $destLocation with newly extracted files."            
            $tempLocation = "{0}{1}" -f $destLocation, "tmp"

            Move-Item $extractedLocation -Destination $tempLocation
            Remove-Item $destLocation -Recurse
            Rename-Item $tempLocation $destLocation
            Remove-Item $revertedConversionService -Recurse -ErrorAction SilentlyContinue

            RestartIIS "start"
        }
        Catch [Exception]
        {
            Log "F" "Deployment failed.`n $($_.Exception.GetType().FullName) $($_.Exception.Message )"
            throw
        }
    }
    Else
    {
        Log "F" "$destLocation does not exist" 
        throw 
    }
    Log "H" "Deploy end"
}

Deploy

Start-Sleep -Seconds 3