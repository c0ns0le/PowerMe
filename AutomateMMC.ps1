Param($automationScriptPath)
#Start-Process 'C:\Windows\System32\dcomcnfg.exe' -PassThru

#$automationScriptPath = "C:\temp\setup\CreateVirtualDisk.bat"

Write-Host "Call $automationScriptPath"


cmd.exe "/c $automationScriptPath" 
Write-Host "The Exit code from $automationScriptPath is " $LastExitCode

#cmd.exe "/wait /c $automationScriptPath"