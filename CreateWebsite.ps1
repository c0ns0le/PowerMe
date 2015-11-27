# Load IIS tools
Import-Module WebAdministration
sleep 2 #see http://stackoverflow.com/questions/14862854/powershell-command-get-childitem-iis-sites-causes-an-error
 
Function CreateWebSite()
{
    # Get SiteName and AppPool from script args
    $siteName    = $Global:ApplicationName  # "default web site"
    $appPoolName = $Global:ApplicationPoolName  # "DefaultAppPool"
    $port        = $Global:ApplicationPort
    $alternativePort = $Global:alternativePort
    $path        = $Global:ApplicationFilePath
    $user        = $Global:appPoolUN
    $password    = $Global:appPoolPwd
    $appIdentity = $Global:applicationIdentityType
    $appPipelineMode = $Global:applicationPipelineMode
    $appRuntimeVersion = $Global:appRuntimeVersion
    $idleTimeoutAction = $Global:idleTimeoutAction
    $workerStartMode = $Global:workerStartMode
     
    if($siteName -eq $null)    { throw "Empty site name, Argument one is missing" }
    if($appPoolName -eq $null) { throw "Empty AppPool name, Argument two is missing" }
    if($port -eq $null)        { throw "Empty port, Argument three is missing" }
    if($path -eq $null)        { throw "Empty path, Argument four is missing" }
     
    $backupName = "$(Get-date -format "yyyyMMdd-HHmmss")-$siteName"
    "Backing up IIS config to backup named $backupName"
    $backup = Backup-WebConfiguration $backupName
     
    try { 
        # delete the website & app pool if needed
        Log "d" "delete the website & app pool if needed"
        if (Test-Path "IIS:\Sites\$siteName") {
            Log "I" "Removing existing website $siteName"
            Remove-Website -Name $siteName
        }
     
        if (Test-Path "IIS:\AppPools\$appPoolName") {
            Log "I" "Removing existing AppPool $appPoolName"
            Remove-WebAppPool -Name $appPoolName
        }
     
        #remove anything already using that port
        foreach($site in Get-ChildItem IIS:\Sites) {
            if( $site.Bindings.Collection.bindingInformation -eq ("*:" + $port + ":")){
                Log "I" "Warning: Found an existing site '$($site.Name)' already using port $port. Changing it..."
                 #Remove-Website -Name  $site.Name 
                 #Set-Website -Name $site.Name -Port $alternativePort
                 $temp = "*:" + $port + ":"
                 Set-WebBinding -Name $site.Name -BindingInformation $temp -PropertyName Port -Value $alternativePort
                 Log "I" "Website '$($site.Name)' port changed to '$alternativePort'"
            }
        }
     
        Log "I" "Create an appPool named $appPoolName under $appRuntimeVersion runtime, $appPipelineMode pipeline"
        $pool = New-WebAppPool $appPoolName
        $pool.ProcessModel.IdentityType = $appIdentity # LocalSystem
        If($Global:is2012R2 -eq $true)
        {
            $pool.ProcessModel.IdleTimeoutAction = $idleTimeoutAction
        }
        $pool.ProcessModel.IdleTimeout = [TimeSpan]::FromMinutes(0) # Remove idle timeout so the site doesn't randomly slow down
        $pool.Recycling.PeriodicRestart.Time = [TimeSpan]::FromMinutes(0) # Remove the default 29 hourly recycle
        $pool.ManagedRuntimeVersion = $appRuntimeVersion # .NET 4.X
        $pool.ManagedPipelineMode = $appPipelineMode
        $pool.StartMode = $workerStartMode # Worker is always running - requires application initialization module to be installed
    	
    	if ($user -ne $null -AND $password -ne $null) 
        {
    	    Log "I" "Setting AppPool to run as $user"
    		$pool.processmodel.identityType = $appIdentity
    		$pool.processmodel.username = $user
    		$pool.processmodel.password = $password        
    	} 
    	#set items
        $pool | Set-Item
     
        if ((Get-WebAppPoolState -Name $appPoolName).Value -ne "Started") {
            Log "I" "App pool $appPoolName was created but did not start automatically. Probably something is broken!"
            throw "App pool $appPoolName was created but did not start automatically. Probably something is broken!"
        }
     
        Log "I" "Create a website $siteName from directory $path on port $port"
        $website = New-Website -Name $siteName -PhysicalPath $path -ApplicationPool $appPoolName -Port $port
     
        if ((Get-WebsiteState -Name $siteName).Value -ne "Started") {
            Log "I" "Website $siteName was created but did not start automatically. Probably something is broken!"
            throw "Website $siteName was created but did not start automatically. Probably something is broken!"
        }
     
        Log "I" "Website and AppPool created and started successfully"
    } 
    catch 
    {
        Log "E" "Error detected, running command 'Restore-WebConfiguration $backupName' to restore the web server to its initial state. Please wait..."
        sleep 3 #allow backup to unlock files
        Restore-WebConfiguration $backupName
        Log "I" "IIS Restore complete. Throwing original error."
        pause
        throw
    }
}

Log "H" "Website creation start"
CreateWebSite
Log "H" "Website creation end"

Start-Sleep -Seconds 5
