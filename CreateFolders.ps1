Function FolderCreation()
{
    Param($baseFolderPath, $folderName)
    
    Try
    {
        $parentFolderName = "{0}\{1}" -f $baseFolderPath, $folderName

        Log "D" $parentFolderName
        $folderExists = Test-Path $parentFolderName

        If($folderExists -eq $false)
        {
            Log "S" "'$parentFolderName' Folder created..."
            New-Item -ItemType directory -Path $parentFolderName
        }
        Else
        {
            Log "I" "'$parentFolderName' already exists"
        }
    }
    Catch
    {
        Log "e" "Unable to create folder: '$parentFolderName'"
    }
}

Function FolderCreation1()
{
    Param($fullPath)
    Try
    {
        $folderExists = Test-Path $fullPath
        Log "D" $folderExists
        If($folderExists -eq $false)
        {
            Log "S" "'$fullPath' Folder created..."
            New-Item -ItemType directory -Path $fullPath
        }
        Else
        {
            Log "I" "'$fullPath' already exists"
        }
    }
    Catch
    {
        Log "e" "Unable to create folder: '$fullPath'"
    }
}

Log "H" "Folder creation start"
FolderCreation1 $Global:appLogFolders
Log "H" "Folder creation end"


Start-Sleep -Seconds 3
