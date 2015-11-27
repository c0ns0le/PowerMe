Param($baseWindowsDir, $sourceZipFileName, $baseDefaultFolder, $setupFolder, $updateFolder, $powerShellFolder, $serviceLogFolder)

Function CheckExecutionPolicy()
{
    Param($Policy)
    Set-ExecutionPolicy -ExecutionPolicy $Policy -Scope LocalMachine -Force
    If ((get-ExecutionPolicy) -ne $Policy) 
    {
      Write-Host "Script Execution is disabled. Enabling it now"
      Set-ExecutionPolicy $Policy -Force
      Write-Host "Please Re-Run this script in a new powershell enviroment"
      Exit
    }
    Write-Host "Powershell script execution Policy: $Policy"
}

Function AdminElavated()
{
    # Get the ID and security principal of the current user account
    $myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
    $myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

    # Get the security principal for the Administrator role
    $adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

    # Check to see if we are currently running "as Administrator"
    If ($myWindowsPrincipal.IsInRole($adminRole))
    {
        Write-Host "Script is getting executed in Administrator rights..."
        # We are running "as Administrator" - so change the title and background color to indicate this
        #$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
        $Host.UI.RawUI.WindowTitle = "Admin (Elevated)"
        $Host.UI.RawUI.BackgroundColor = "Blue"
        #Clear-host
    }
    Else
    {
        # We are not running "as Administrator" - so relaunch as administrator   
        # Create a new process object that starts PowerShell
        $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
        # Specify the current script path and name as a parameter
        $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
        # Indicate that the process should be elevated
        $newProcess.Verb = "runas";
   
        # Start the new process
        [System.Diagnostics.Process]::Start($newProcess);
   
        # Exit from the current, unelevated, process
        #Exit
    }
}

Function ServerUnZip
{       
    $zipfilename = "{0}\{1}" -f  $baseWindowsDir, $sourceZipFileName

    $baseDefaultLocation = "{0}\{1}" -f $baseWindowsDir, $baseDefaultFolder # "C:\temp"
    $setupPath = "{0}\{1}" -f $baseDefaultLocation, $setupFolder
    $updatePath = "{0}\{1}" -f $baseDefaultLocation, $updateFolder
    
    $fileName = split-path $zipfilename -Leaf
    If($fileName.Contains("."))
    {
        $fileNameSplit = $fileName.split(".")
        $fileNameWithoutExt = $fileNameSplit[$fileNameSplit.Count - 2] #Get filename without extension
    }
    $folderName = $fileNameWithoutExt
    $parentPath = Split-Path $zipfilename -Parent #Get parent path from .zip file path  
    $destination = "{0}{1}" -f  $parentPath, $folderName
    
    Remove-Item -Path $destination -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType directory -Path $destination -Force -ErrorAction SilentlyContinue
    
    Remove-Item -Path $setupPath -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType directory -Path $setupPath -Force -ErrorAction SilentlyContinue

	If(Test-Path($zipfilename))
	{	
        Write-Host "Extracting: $zipfilename to $setupPath"
		$shellApplication = new-object -com shell.application
		$zipPackage = $shellApplication.NameSpace($zipfilename)
		$destinationFolder = $shellApplication.NameSpace($destination)
        Write-Host "`nExtracting & moving files... Please wait..."
		$destinationFolder.MoveHere($zipPackage.Items(), 0x14)
                
        $movedPath = "{0}\{1}" -f $destination, $folderName                
        DIR $movedPath | MV -dest $setupPath

        Remove-Item $destination -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $zipfilename -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item $movedPath -Recurse -Force -ErrorAction SilentlyContinue
                
        Write-Host "`nExtraction done..."
	}
    Else
    {
        Write-Host "$zipfilename doesn't exists."
    }  
}

AdminElavated 
CheckExecutionPolicy "RemoteSigned"

Write-Host "Unzip start..."
ServerUnZip
Write-Host "Unzip End..."

Start-Sleep -Seconds 3