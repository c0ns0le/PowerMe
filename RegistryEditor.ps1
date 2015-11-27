Function RegEdit()
{
    Param ($keyPath, $itemName, $propName, $propType, $propValue)
    #RegEdit  "HKLM:\Software\Microsoft\Office\15.0\" "FirstRun" "BootedRTM" "DWORD" "00000001"

    $propPath = $keyPath + $itemName
    $isExists = Test-Path $propPath
    Log "D" "$isExists : $propPath"
    If($isExists -eq $true)
    {
        If(!((Get-ItemProperty $propPath).$propName -eq $null))
        {
            Try 
            {
                Log "I" "Property '$propName' available, updating value: '$propValue' to Property: $propName in Path: $propPath "
                Set-ItemProperty -Path $propPath -Name $propName -Value $propValue -ErrorAction SilentlyContinue
            }
            Catch [Exception]
            {
                Log "E" "Updating registry '$itemPropPath' is unsuccessful...`n $($_.Exception.GetType().FullName) $($_.Exception.Message)"
            }
        }
        Else
        {
            Try 
            {
                Log "I" "Creating Property '$propName' in Path: $propPath is updated with value: '$propValue' "
                New-ItemProperty -Path $propPath -Name $propName -PropertyType $propType -Value $propValue -ErrorAction SilentlyContinue
            }
            Catch [Exception]
            {
                Log "E" "Creating Property '$propName' in Path: $propPath is unsuccessful...`n $($_.Exception.GetType().FullName) $($_.Exception.Message)"
            }
        }
    }
    Else
    {
        Try
        {
            Log "I" "Creating Path: $propPath "
            Log "I" "Creating item '$itemName' in Path: $propPath "
            New-Item $propPath -Force -ErrorAction SilentlyContinue | New-ItemProperty -Name $propName -PropertyType $propType -Value $propValue -Force -ErrorAction SilentlyContinue | Out-Null
        }
        Catch [Exception]
        {
            Log "E" "Creating item '$path' is unsuccessful...`n $($_.Exception.GetType().FullName) $($_.Exception.Message)"
        }
    }    
}

Log "H" "Registry Editor start"

##Disable ClientTelemetry
RegEdit $Global:keyTelePath $Global:itemTeleNode $Global:itemTeleProperty $Global:itemTeleType $Global:itemTeleValue

##Microsoft Word 97 - 2003 Document(RunAs Administrator User(Identity Tab in DCOM config))
RegEdit $Global:MSWkeyPath $Global:MSWordAppID $Global:MSWProperty $Global:MSWType $Global:MSWValue

#Local Machine
##To avoid MS OFFICE 'First things first' wizard
RegEdit $Global:office2013RegPath $Global:regItemRegistration "AcceptEulas" $Global:regDWordType $Global:regDWordValue1
RegEdit $Global:office2013RegPath $Global:regItemFirstRun "disablemovie" $Global:regDWordType $Global:regDWordValue1

RegEdit $Global:office2013RegPath $Global:regItemFirstRun "BootedRTM" $Global:regDWordType $Global:regDWordValue1
RegEdit $Global:office2013RegPath $Global:regPropCommon "QMEnable" $Global:regDWordType $Global:regDWordValue0

RegEdit $Global:regOffice2013CommonPath "PTWatson" "PTWOptIn" $Global:regDWordType $Global:regDWordValue0

RegEdit $Global:regOffice2013CommonPath "General" "ShownFirstRunOptin" $Global:regDWordType $Global:regDWordValue1
RegEdit $Global:regOffice2013CommonPath "Internet" "ShownFirstRunOptin" $Global:regDWordType $Global:regDWordValue1
RegEdit $Global:regOffice2013CommonPath "Internet" "UseOnlineContent" $Global:regDWordType $Global:regDWordValue1

##Disable Microsoft Office 2013's Start Screen 
RegEdit $Global:regOffice2013CommonPath "General" "DisableBootToOfficeStart" $Global:regDWordType $Global:regDWordValue1
RegEdit "HKLM:\Software\Microsoft\Office\15.0\Word\" "Options" "DisableBootToOfficeStart" $Global:regDWordType $Global:regDWordValue1
RegEdit "HKLM:\Software\Microsoft\Office\15.0\Excel\" "Options" "DisableBootToOfficeStart" $Global:regDWordType $Global:regDWordValue1

##Disable feedback buttons
RegEdit $Global:regOffice2013CommonPath "Feedback" "Enabled" $Global:regDWordType $Global:regDWordValue0

Start-Sleep -Seconds 5

#Current User
##To avoid MS OFFICE 'First things first' wizard
RegEdit $Global:office2013RegPathHKCU $Global:regItemRegistration "AcceptEulas" $Global:regDWordType $Global:regDWordValue1
RegEdit $Global:office2013RegPathHKCU $Global:regItemFirstRun "disablemovie" $Global:regDWordType $Global:regDWordValue1

RegEdit $Global:office2013RegPathHKCU $Global:regItemFirstRun "BootedRTM" $Global:regDWordType $Global:regDWordValue1
RegEdit $Global:office2013RegPathHKCU $Global:regPropCommon "QMEnable" $Global:regDWordType $Global:regDWordValue0

RegEdit $Global:regOffice2013CommonPathHKCU "PTWatson" "PTWOptIn" $Global:regDWordType $Global:regDWordValue0

RegEdit $Global:regOffice2013CommonPathHKCU "General" "ShownFirstRunOptin" $Global:regDWordType $Global:regDWordValue1
RegEdit $Global:regOffice2013CommonPathHKCU "Internet" "ShownFirstRunOptin" $Global:regDWordType $Global:regDWordValue1
RegEdit $Global:regOffice2013CommonPathHKCU "Internet" "UseOnlineContent" $Global:regDWordType $Global:regDWordValue1

##Disable Microsoft Office 2013's Start Screen 
RegEdit $Global:regOffice2013CommonPathHKCU "General" "DisableBootToOfficeStart" $Global:regDWordType $Global:regDWordValue1
RegEdit "HKCU:\Software\Microsoft\Office\15.0\Word\" "Options" "DisableBootToOfficeStart" $Global:regDWordType $Global:regDWordValue1
RegEdit "HKCU:\Software\Microsoft\Office\15.0\Excel\" "Options" "DisableBootToOfficeStart" $Global:regDWordType $Global:regDWordValue1
RegEdit "HKCU:\Software\Microsoft\Office\15.0\Word\" "Options" "BulletProofOnCorruption" $Global:regDWordType $Global:regDWordValue1

##Disable feedback buttons
RegEdit $Global:regOffice2013CommonPathHKCU "Feedback" "Enabled" $Global:regDWordType $Global:regDWordValue0

Log "H" "Registry Editor end"


Start-Sleep -Seconds 2
