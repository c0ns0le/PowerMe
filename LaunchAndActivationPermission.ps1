Function get-sid
{
    Param ($DSIdentity)

    $ID = new-object System.Security.Principal.NTAccount($DSIdentity)
    return $ID.Translate( [System.Security.Principal.SecurityIdentifier] ).toString()
}

Function LaunchAndActivationPermission()
{
    Log "H" "Enabling DCOM settings..."
    #$sid = get-sid "ANONYMOUS LOGON"
    $sid = get-sid $Global:LaunchAndActivationPermissionTo
    $computers = $Global:ServerName

    #MachineLaunchRestriction - Local Launch, Remote Launch, Local Activation, Remote Activation
    $DCOMSDDLMachineLaunchRestriction = "A;;CCDCLCSWRP;;;$sid"

    #MachineAccessRestriction - Local Access, Remote Access
    $DCOMSDDLMachineAccessRestriction = "A;;CCDCLC;;;$sid"

    #DefaultLaunchPermission - Local Launch, Remote Launch, Local Activation, Remote Activation
    $DCOMSDDLDefaultLaunchPermission = "A;;CCDCLCSWRP;;;$sid"

    #DefaultAccessPermision - Local Access, Remote Access
    $DCOMSDDLDefaultAccessPermision = "A;;CCDCLC;;;$sid"

    #PartialMatch
    $DCOMSDDLPartialMatch = "A;;\w+;;;$sid"

    foreach ($strcomputer in $computers)
    {
        Log "I" "Working on $strcomputer with principal ($sid)"

        # Get the respective binary values of the DCOM registry entries
        $Reg = [WMIClass]"\\$strcomputer\root\default:StdRegProv"
        $DCOMMachineLaunchRestriction = $Reg.GetBinaryValue(2147483650,"software\microsoft\ole","MachineLaunchRestriction").uValue
        $DCOMMachineAccessRestriction = $Reg.GetBinaryValue(2147483650,"software\microsoft\ole","MachineAccessRestriction").uValue
        $DCOMDefaultLaunchPermission = $Reg.GetBinaryValue(2147483650,"software\microsoft\ole","DefaultLaunchPermission").uValue
        $DCOMDefaultAccessPermission = $Reg.GetBinaryValue(2147483650,"software\microsoft\ole","DefaultAccessPermission").uValue 
     
        $security = Get-WmiObject -ComputerName $strcomputer -Namespace root/cimv2 -Class __SystemSecurity
        $converter = new-object system.management.ManagementClass Win32_SecurityDescriptorHelper
        $binarySD = @($null)
        $result = $security.PsBase.InvokeMethod("GetSD",$binarySD)
     
        # Convert the current permissions to SDDL
        Log "I" "Converting current permissions to SDDL format..."  
     
        $CurrentDCOMSDDLMachineLaunchRestriction = $converter.BinarySDToSDDL($DCOMMachineLaunchRestriction)
        $CurrentDCOMSDDLMachineAccessRestriction = $converter.BinarySDToSDDL($DCOMMachineAccessRestriction)
        $CurrentDCOMSDDLDefaultLaunchPermission = $converter.BinarySDToSDDL($DCOMDefaultLaunchPermission)
        $CurrentDCOMSDDLDefaultAccessPermission = $converter.BinarySDToSDDL($DCOMDefaultAccessPermission)

        # Building the new permissions
        Log "I" "Building the new permissions..."
        if (($CurrentDCOMSDDLMachineLaunchRestriction.SDDL -match $DCOMSDDLPartialMatch) -and ($CurrentDCOMSDDLMachineLaunchRestriction.SDDL -notmatch $DCOMSDDLMachineLaunchRestriction))
        {
            $NewDCOMSDDLMachineLaunchRestriction = $CurrentDCOMSDDLMachineLaunchRestriction.SDDL -replace $DCOMSDDLPartialMatch, $DCOMSDDLMachineLaunchRestriction
        }
        else
        {
            $NewDCOMSDDLMachineLaunchRestriction = $CurrentDCOMSDDLMachineLaunchRestriction.SDDL += "(" + $DCOMSDDLMachineLaunchRestriction + ")"
        }
      
        if (($CurrentDCOMSDDLMachineAccessRestriction.SDDL -match $DCOMSDDLPartialMatch) -and ($CurrentDCOMSDDLMachineAccessRestriction.SDDL -notmatch $DCOMSDDLMachineAccessRestriction))
        {
            $NewDCOMSDDLMachineAccessRestriction = $CurrentDCOMSDDLMachineAccessRestriction.SDDL -replace $DCOMSDDLPartialMatch, $DCOMSDDLMachineLaunchRestriction
        }
        else
        {
            $NewDCOMSDDLMachineAccessRestriction = $CurrentDCOMSDDLMachineAccessRestriction.SDDL += "(" + $DCOMSDDLMachineAccessRestriction + ")"
        }

        if (($CurrentDCOMSDDLDefaultLaunchPermission.SDDL -match $DCOMSDDLPartialMatch) -and ($CurrentDCOMSDDLDefaultLaunchPermission.SDDL -notmatch $DCOMSDDLDefaultLaunchPermission))
        {
            $NewDCOMSDDLDefaultLaunchPermission = $CurrentDCOMSDDLDefaultLaunchPermission.SDDL -replace $DCOMSDDLPartialMatch, $DCOMSDDLDefaultLaunchPermission
        }
        else
        {
            $NewDCOMSDDLDefaultLaunchPermission = $CurrentDCOMSDDLDefaultLaunchPermission.SDDL += "(" + $DCOMSDDLDefaultLaunchPermission + ")"
        }

        if (($CurrentDCOMSDDLDefaultAccessPermission.SDDL -match $DCOMSDDLPartialMatch) -and ($CurrentDCOMSDDLDefaultAccessPermission.SDDL -notmatch $DCOMSDDLDefaultAccessPermision))
        {
            $NewDCOMSDDLDefaultAccessPermission = $CurrentDCOMSDDLDefaultAccessPermission.SDDL -replace $DCOMSDDLPartialMatch, $DCOMSDDLDefaultAccessPermision
        }
        else
        {
            $NewDCOMSDDLDefaultAccessPermission = $CurrentDCOMSDDLDefaultAccessPermission.SDDL += "(" + $DCOMSDDLDefaultAccessPermision + ")"
        }

        # Convert SDDL back to Binary
        Log "I" "Converting SDDL back into binary form..."
        $DCOMbinarySDMachineLaunchRestriction = $converter.SDDLToBinarySD($NewDCOMSDDLMachineLaunchRestriction)
        $DCOMconvertedPermissionsMachineLaunchRestriction = ,$DCOMbinarySDMachineLaunchRestriction.BinarySD

        $DCOMbinarySDMachineAccessRestriction = $converter.SDDLToBinarySD($NewDCOMSDDLMachineAccessRestriction)
        $DCOMconvertedPermissionsMachineAccessRestriction = ,$DCOMbinarySDMachineAccessRestriction.BinarySD

        $DCOMbinarySDDefaultLaunchPermission = $converter.SDDLToBinarySD($NewDCOMSDDLDefaultLaunchPermission)
        $DCOMconvertedPermissionDefaultLaunchPermission = ,$DCOMbinarySDDefaultLaunchPermission.BinarySD

        $DCOMbinarySDDefaultAccessPermission = $converter.SDDLToBinarySD($NewDCOMSDDLDefaultAccessPermission)
        $DCOMconvertedPermissionsDefaultAccessPermission = ,$DCOMbinarySDDefaultAccessPermission.BinarySD

        # Apply the changes
        Log "I" "Applying changes..." 
            
        #$result = $security.PsBase.InvokeMethod("SetSD",$WMIconvertedPermissions)
        $result = $Reg.SetBinaryValue(2147483650,"software\microsoft\ole","MachineLaunchRestriction", $DCOMbinarySDMachineLaunchRestriction.binarySD)
        if($result.ReturnValue='0'){Log "I" "Applied MachineLaunchRestricition complete."}
     
             
        $result = $Reg.SetBinaryValue(2147483650,"software\microsoft\ole","MachineAccessRestriction", $DCOMbinarySDMachineAccessRestriction.binarySD)
        if($result.ReturnValue='0'){Log "I" "Applied MachineAccessRestricition complete."}
         
        $result = $Reg.SetBinaryValue(2147483650,"software\microsoft\ole","DefaultLaunchPermission", $DCOMbinarySDDefaultLaunchPermission.binarySD)
        if($result.ReturnValue='0'){Log "I" "Applied DefaultLaunchPermission complete."}
     
             
        $result = $Reg.SetBinaryValue(2147483650,"software\microsoft\ole","DefaultAccessPermission", $DCOMbinarySDDefaultAccessPermission.binarySD)
        if($result.ReturnValue='0'){Log "I" "Applied DefaultAccessPermission complete."} 
    }
}

Log "H" "DCOM settings: LaunchAndActivationPermission start..."
LaunchAndActivationPermission
Log "H" "DCOM settings: LaunchAndActivationPermission end..."

Start-Sleep -Seconds 3
