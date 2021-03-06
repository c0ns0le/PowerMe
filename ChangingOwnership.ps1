Function ChangeOwnership()
{
    Param($AppID, $Owners, $accessLevels)
    #ChangeOwnership $Global:WordAppID $Global:OwnerTo $Global:UserAccessLevel
    
    #$AppID = $Global:WordAppID
    #$Owners = $Global:OwnerTo
    #$accessLevels = $Global:UserAccessLevel
    $Keys = "HKLM:\Software\Classes\AppID\$AppID"
    
    # Checking OS Version and changing Registry Key permissions accordingly. We do need
    # to change reg-key ownership for Win Server 2012 R2, owner of one of
    # the required keys is TrustedInstaller instead of Administrator. Thus we need to
    # change the owner back to Admin in order to make any changes to that key.
    Log "I" "Checking Operating System Version..."
    $cv = (gi "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion")
    $wv = $cv.GetValue("ProductName")
    Log "I" "OS: $wv"
    
    $acl = Get-Acl $Keys
    $owner = $acl.Owner

    # Case 48188: Because Windows has server version like Windows Web Server 2008 R2, we
    # cannot validate the version name using "Windows Server 2008 R2". We will only
    # check if the name contains "Server 2008 R2".
    Log "I" "Server version: $wv"
    Log "I" "Owner of the key $Keys : $owner"

    #if($wv.Contains("Server 2008 R2") -and !$owner.Contains("Administrators"))
    if($wv.Contains("Server 2012 R2"))
    {
      Log "I" "Setting Administrators Group privileges in Windows Registry..."
      #Call a method from EnablePrivilege.ps1
      $boolResult = enable-privilege SeTakeOwnershipPrivilege
        if(-not $boolResult)
        {
          echo "Privileges could not be elevated. Changing ownership of the registry"
          echo "key would fail. Please change ownership of key"
          echo "$Keys to Administrators"
          echo "Group manually."
          return
        }
      $key = [Microsoft.Win32.Registry]::ClassesRoot.OpenSubKey("AppID\{0}" -f $AppID, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,
                                                                [System.Security.AccessControl.RegistryRights]::takeownership)
  
      # You must get a blank acl for the key b/c you do not currently have access
      $acl = $key.GetAccessControl([System.Security.AccessControl.AccessControlSections]::None)
  
      $owner = [System.Security.Principal.NTAccount]$Owners
      $acl.SetOwner($owner)
      $key.SetAccessControl($acl)

      # After you have set owner you need to get the acl with the perms so you can modify it.
      $acl = $key.GetAccessControl()
      $person = [System.Security.Principal.NTAccount]$Owners
      $access = [System.Security.AccessControl.RegistryRights]$accessLevels
      $inheritance = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit"
      $propagation = [System.Security.AccessControl.PropagationFlags]"None"
      $type = [System.Security.AccessControl.AccessControlType]"Allow"

      $rule = New-Object System.Security.AccessControl.RegistryAccessRule($person,$access,$inheritance,$propagation,$type)
      $acl.SetAccessRule($rule)
      $key.SetAccessControl($acl)

      $key.Close()
      Log "I" "Administrators Group ownership privileges set."
    }

}

Log "H" "Changing MS-Word AppID Ownership start"
ChangeOwnership $Global:WordAppID $Global:OwnerTo $Global:UserAccessLevel
Log "H" "Changing MS-Word AppID Ownership end"

Start-Sleep -Seconds 3