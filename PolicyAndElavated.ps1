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
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   Write-Host "Script is getting executed in Administrator rights..."
   # We are running "as Administrator" - so change the title and background color to indicate this
   #$Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.WindowTitle = "Admin (Elevated)"
   $Host.UI.RawUI.BackgroundColor = "Blue"
   #Clear-host
   }
else
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

# Run your code that needs to be elevated here
#Write-Host -NoNewLine "Press any key to continue..."
#$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

AdminElavated 
CheckExecutionPolicy "RemoteSigned"