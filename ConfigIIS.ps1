Import-Module ServerManager

Function EnableIISfeatures()
{
	Log "I" 'Enabling IIS and sub-features'
    
    Log "I" "Enabling Web-Server"
    Add-WindowsFeature Web-Server -ErrorAction SilentlyContinue
        Log "I" "Enabling Web-Common-Http"
	    Add-WindowsFeature Web-Common-Http -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-Default-Doc"
	        Add-WindowsFeature Web-Default-Doc -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-Dir-Browsing"
	        Add-WindowsFeature Web-Dir-Browsing -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-Static-Content"
            Add-WindowsFeature Web-Static-Content -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-Http-Redirect"
            Add-WindowsFeature Web-Http-Redirect -ErrorAction SilentlyContinue
        Log "I" "Enabling Web-Health"
        Add-WindowsFeature Web-Health -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-Http-Logging"            
            Add-WindowsFeature Web-Http-Logging -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-Custom-Logging"
            Add-WindowsFeature Web-Custom-Logging -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-Log-Libraries"
            Add-WindowsFeature Web-Log-Libraries -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-ODBC-Logging"
            Add-WindowsFeature Web-ODBC-Logging -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-Request-Monitor"
            Add-WindowsFeature Web-Request-Monitor -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-Http-Tracing"
            Add-WindowsFeature Web-Http-Tracing -ErrorAction SilentlyContinue
        Log "I" "Enabling Web-Performance"
        Add-WindowsFeature Web-Performance -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-Stat-Compression"
            Add-WindowsFeature Web-Stat-Compression -ErrorAction SilentlyContinue
        Log "I" "Enabling Web-Security"
        Add-WindowsFeature Web-Security -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-Filtering"
            Add-WindowsFeature Web-Filtering -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-Basic-Auth"
            Add-WindowsFeature Web-Basic-Auth -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-Windows-Auth"
            Add-WindowsFeature Web-Windows-Auth -ErrorAction SilentlyContinue

        Log "I" "Enabling Web-App-Dev"
        Add-WindowsFeature Web-App-Dev -ErrorAction SilentlyContinue
            If($Global:is2012R2 -eq $true)
            {
                Log "I" "Enabling Web-Net-Ext45"
                Add-WindowsFeature Web-Net-Ext45 -ErrorAction SilentlyContinue
           
                Log "I" "Enabling Web-Asp-Net45"
                Add-WindowsFeature Web-Asp-Net45 -ErrorAction SilentlyContinue
            }
            Log "I" "Enabling Web-ISAPI-Ext"
            Add-WindowsFeature Web-ISAPI-Ext -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-ISAPI-Filter"
            Add-WindowsFeature Web-ISAPI-Filter -ErrorAction SilentlyContinue
        Log "I" "Enabling Web-Mgmt-Tools"
        Add-WindowsFeature Web-Mgmt-Tools -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-Mgmt-Console"
            Add-WindowsFeature Web-Mgmt-Console -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-Scripting-Tools"
            Add-WindowsFeature Web-Scripting-Tools -ErrorAction SilentlyContinue
            Log "I" "Enabling Web-Mgmt-Service"
            Add-WindowsFeature Web-Mgmt-Service -ErrorAction SilentlyContinue    
                        
	           
    #Add-WindowsFeature Application-Server #------------
    
    #----------------
    If($Global:is2012R2 -eq $true)
    {
        Log "I" "Enabling NET-WCF-Services45"
        Add-WindowsFeature NET-WCF-Services45 -ErrorAction SilentlyContinue
    }
    #NET-WCF-HTTP-Activation45

    Log "I" "Enabling MSMQ-Services"
    Add-WindowsFeature MSMQ-Services -ErrorAction SilentlyContinue
    If($Global:is2012R2 -eq $true)
    {
        Log "I" "Enabling NET-WCF-MSMQ-Activation45"
        Add-WindowsFeature NET-WCF-MSMQ-Activation45 -ErrorAction SilentlyContinue
    
        Log "I" "Enabling NET-WCF-Pipe-Activation45"
        Add-WindowsFeature NET-WCF-Pipe-Activation45 -ErrorAction SilentlyContinue
        Log "I" "Enabling NET-WCF-TCP-Activation45"
        Add-WindowsFeature NET-WCF-TCP-Activation45 -ErrorAction SilentlyContinue
        Log "I" "Enabling NET-WCF-TCP-PortSharing45"
        Add-WindowsFeature NET-WCF-TCP-PortSharing45 -ErrorAction SilentlyContinue
    }
    #----------------

    Log "I" "Enabling WAS"
    Add-WindowsFeature WAS -ErrorAction SilentlyContinue
    Log "I" "Enabling WAS-Process-Model"
    Add-WindowsFeature WAS-Process-Model -ErrorAction SilentlyContinue
    #Log "I" "Enabling WAS-NET-Environment"
    #Add-WindowsFeature WAS-NET-Environment #------------
    Log "I" "Enabling WAS-Config-APIs"
    Add-WindowsFeature WAS-Config-APIs -ErrorAction SilentlyContinue    
		
    #Get-WindowsFeature | Export-Csv -Path "C:\tools\winFeatures.txt"
}

Log "H" "IIS configuration start"
EnableIISfeatures
Log "H" "IIS configuration end"


Start-Sleep -Seconds 5