param(
    [string]$CredentialUsernamePath,
    [string]$CredentialPasswordPath,
    [string]$BeginDeviceIDPath,
    [string]$EndDeviceIDPath,
    [string]$IPPrefixPath
)

$remoteUsername = Get-Content -Path $CredentialUsernamePath
$remotePassword = Get-Content -Path $CredentialPasswordPath
$beginningDeviceID = Get-Content -Path $BeginDeviceIDPath
$endingDeviceID = Get-Content -Path $EndDeviceIDPath
$remoteIPPrefix = Get-Content -Path $IPPrefixPath

Write-Host "Remote Username:" -NoNewline
Write-Host $remoteUsername -ForegroundColor Green
Write-Host Remote IP range: -NoNewline
Write-Host $remoteIPPrefix"."$beginningDeviceID "-" $endingDeviceID -ForegroundColor Green

$remoteUsername = Get-Content -Path $CredentialUsernamePath
$remotePassword = Get-Content -Path $CredentialPasswordPath
$beginningDeviceID = Get-Content -Path $BeginDeviceIDPath
$endingDeviceID = Get-Content -Path $EndDeviceIDPath
$remoteIPPrefix = Get-Content -Path $IPPrefixPath

# Provide credentials for hosts
$remoteSecurePassword = ConvertTo-SecureString $remotePassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($remoteUsername, $remoteSecurePassword)

#RemoteIPs
$remoteIPAddresses = @()
for ($i = [int]$beginningDeviceID; $i -le [int]$endingDeviceID; $i++) {
    $remoteIPAddresses += "$($remoteIPPrefix).$($i)"
}

# Checks if the script is running as an administrator #
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

<#DEVELOPED BY ANDREW MESSER

<# 
    PREAMBLE
This script performs a number of setup operations for the MSC Sea Trial Team.
1. Sets NIST LGPs required for SCC
2. Checks bitlocker encryption status is "FullyEncrypted"
3. Runs SCC scan and appends SCAP session to server shared folder
4. Sets LGPs for ETC-PKS use while onboard for trial
#>

Write-Host "
# # # # # # # # # # # # # # #
#                           #
#  Set Production Policies  #
#                           #
# # # # # # # # # # # # # # #
`n`n"

Write-Host "Sets production policies on clients `n`n" -ForegroundColor Yellow



    write-host "`nSetting production policies on:`n"
    $timeout = 100 # Timeout in milliseconds

    Write-Host "Querying hosts. This may take a while...`n" -ForegroundColor Magenta
    $remoteIPAddresses | ForEach-Object {
        $ip = $_
        <#
        $ping = New-Object System.Net.NetworkInformation.Ping
        $reply = $ping.Send($ip, $timeout)
        if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
        #>
            #<try {
            #>
                Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { Write-Host $env:COMPUTERNAME -ForegroundColor Green }
                Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                    <#
                    SETS POST-SCAP LOCAL GROUP POLICIES
                    ***********************************
                    #>
                    write-host "setting Sea Trial post-SCAP Local Policies and Settings`n`n"

                    Start-Sleep -Seconds 1

                    # Set sleep settings to never when plugged in
                    powercfg -change -standby-timeout-ac 0
                    powercfg -change -hibernate-timeout-ac 0

                    # Set screen settings to never turn off when plugged in
                    powercfg -change -monitor-timeout-ac 0
                    powercfg -change -standby-timeout-ac 0

                    # Set screen timeout and sleep settings to Never when not plugged in
                    powercfg -Change -monitor-timeout-dc 0
                    powercfg -change -standby-timeout-dc 0
                    Write-Host "setting power and sleep setings`n`n"

                    #Machine Inactivity Limit = 0 
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "InactivityTimeoutSecs" -Value 0 -Force
                    Write-Host "setting machine inactivity limit`n"

                    #Maximum Password Age = 999 days (maximum password age is not in regsitry and "net accounts" cannot set value to 0)
                    net accounts /maxpwage:999
                    Write-Host "setting max password age`n"

                    #Machine Lockout Threshold = 100 Attempts
                    net accounts /lockoutthreshold:100
                    Write-Host "setting machine lockout threshold`n"

                    #Machine Lockout Duration = 10 Min (smallest allowable value) (((Disabled since smallest allowable value is compliant with STIG)))
                    #net accounts /lockoutduration:10

                    <#
                    Firewall Profile Changes
                    #Windows Firewall Domain Inbound Connection = Allow
                    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Name "DefaultInboundAction" -Force 
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Name "DefaultInboundAction"  -Value 0 -Force
                    Write-Host "setting Windows Firewall Domain Inbound Connection`n"

                    #Windows Firewall Public Inbound Connection = Allow
                    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "DefaultInboundAction" -Force
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "DefaultInboundAction" -Value 0 -Force
                    Write-Host "setting Windows Firewall Public Inbound Connection`n"

                    #Windows Firewall Private Inbound Connection = Allow
                    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" -Name "DefaultInboundAction" -Force
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" -Name "DefaultInboundAction" -Value 0 -Force
                    Write-Host "setting Windows Firewall Private Inbound Connection`n" 
                    #>

                    #Group Policy Refresh Interval = 0
                    #$groupPolicyRefresh = "HKLM:\Software\Policies\Microsoft\Windows\System\GroupPolicyRefreshTime"
                    New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Force
                    New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "GroupPolicyRefreshTime" -Value 0 -PropertyType DWORD -Force
                    Write-Host "disabling Group Policy Refresh Interval`n`n"

                    #Set UAC to never prompt administrators for consent on the secure desktop
                    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0 -Force

                    Set Windows dialog box title for the legal banner to null
                    if ($testLegalNoticeCaptionPath.legalnoticecaption -ne "") {
                    Set-ItemProperty -Path $legalNoticeCaptionPath -Name "legalnoticecaption" -Value "" -Force
                    Write-Host "Legal notice title property set to null"
                    }
                    Else {
                    "Legal notice title property already null"
                    }

                    #Set required legal notice text to null
                    $legalNoticeCaptionPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
                    $testLegalNoticeTextPath = Get-ItemProperty -Path $legalNoticeCaptionPath -Name "legalnoticetext"
                    if ($testLegalNoticeTextPath.legalnoticetext -ne "") {
                        Set-ItemProperty -Path $legalNoticeCaptionPath -Name "legalnoticetext" -Value "" -Force
                        Write-Host "Legal notice text property set to null"
                        }
                        Else {
                        "Legal notice text property already null"
                        }

                    #Enables Built-in Local Administrator
                    Enable-LocalUser -Name "MSC_MOB"
                    if ($?) {
                    Write-Host "`nBuilt-in Local Administrator is enabled" -ForegroundColor Green
                    }
                    else {
                    Write-Warning "`nBuilt-in Local Administrator could not be enabled"
                    }
                    start-sleep -Seconds 1

                    #Disables AutoLogon
                    #Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Value "0"


                    ########################################################################

                    <#
                    ALLOW WORD AND EXCEL BINARY FILES
                    *********************************
                    #>

                    # Set the registry path for Word FileBlock policy
                    $wordRegPath = "HKCU:\Software\Policies\Microsoft\Office\16.0\Word\Security\FileBlock"
                    # Set the registry path for Excel FileBlock policy
                    $excelRegPath = "HKCU:\Software\Policies\Microsoft\Office\16.0\Excel\Security\FileBlock" #-ErrorAction SilentlyContinue
                    Write-Host "Checking Word and Excel FileBlock registry keys...`n`n"

                    #Word Registry Entries
                    if(Test-Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Word\Security\FileBlock")
                    {
                        Write-Host "Adding registry entries to allow Word binary files..." -ForegroundColor Yellow
                        New-ItemProperty -Path $wordRegPath -Name "word2000files" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "word2003files" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "word2007files" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "word2files" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "word60files" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "word95files" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "word97files" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "wordxp" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "word2000files" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "wordxml" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "wordxpfiles" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "OpenInProtectedView" -Value 2 -Force
                    }
                    else {
                        Write-Host "Creating new path in registry: ($wordRegPath). Adding registry entries to allow Word binary files..." -ForegroundColor Yellow
                        New-Item -Path $wordRegPath -Force
                        New-ItemProperty -Path $wordRegPath -Name "word2000files" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "word2003files" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "word2007files" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "word2files" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "word60files" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "word95files" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "word97files" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "wordxp" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "word2000files" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "wordxml" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "wordxpfiles" -Value 0 -Force
                        New-ItemProperty -Path $wordRegPath -Name "OpenInProtectedView" -Value 2 -Force
                    }

                    #Excel Registry Entries
                    if(Test-Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Excel\Security\FileBlock")
                    {
                        Write-Host "Adding registry entries to allow Excel binary files...`n" -ForegroundColor Yellow
                        New-ItemProperty -Path $excelRegPath -Name "xl2macros" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl2worksheets" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl3macros" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl3worksheets" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl4macros" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl4workbooks" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl4worksheets" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl9597workbooksandtemplates" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl95workbooks" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl97addins" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl97workbooksandtemplates" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xlamfiles" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xlsbfiles" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xlsmandxltmfiles" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xlsxandxltxfiles" -Value 0 -Force
                    }
                    else {
                        Write-Host "Creating new path in registry: ($excelRegPath). Adding registry entries to allow Excel binary files...`n" -ForegroundColor Yellow
                        New-Item -Path $excelRegPath -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl2macros" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl2worksheets" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl3macros" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl3worksheets" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl4macros" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl4workbooks" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl4worksheets" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl9597workbooksandtemplates" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl95workbooks" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl97addins" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xl97workbooksandtemplates" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xlamfiles" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xlsbfiles" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xlsmandxltmfiles" -Value 0 -Force
                        New-ItemProperty -Path $excelRegPath -Name "xlsxandxltxfiles" -Value 0 -Force
                    }



                    ########################################################################



                    #SETS REG PATH FOR LOGON WARNING MESSAGE
                    $policyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
                    $policyName = "legalnoticecaption"
                    $policyName2 = "legalnoticetext"

                    #DISABLES LOGON LEGAL NOTICE WARNING
                    Set-ItemProperty -Path $policyPath -Name $policyName -Value ""
                    Set-ItemProperty -Path $policyPath -Name $policyName2 -Value ""
                    Write-Host "disabling logon legal notice`n"


                    # Sets password for LCS account
                    if ($env:USERNAME -eq "LCS"){
                        write-host "setting password for user: $env:USERNAME"
                        $accountName = "LCS"
                        $newPassword = "L-3Communicati0ns!"

                        $securePassword = ConvertTo-SecureString -String $newPassword -AsPlainText -Force
                        Set-LocalUser -Name $accountName -Password $securePassword

                        $sysPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))
                        Write-Host "Password is: $sysPassword" -ForegroundColor Yellow
                    }
                    elseif ($env:USERNAME -eq "CVN"){
                        write-host "setting password for user: $env:USERNAME"
                        $accountName = "CVN"
                        $newPassword = "L-3Communicati0ns!"

                        $securePassword = ConvertTo-SecureString -String $newPassword -AsPlainText -Force
                        Set-LocalUser -Name $accountName -Password $securePassword

                        $sysPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))
                        Write-Host "Password is: $sysPassword" -ForegroundColor Yellow
                    }
                    else{
                        Write-Warning "User is currently not logged on as LCS or CVN. Password will not be set. `nCurrent user: $env:USERNAME"
                    }

                    # Set AutoLogon
                    $DefaultRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                    $registryValue_DU = Get-ItemProperty -Path "$DefaultRegistryPath" -Name "DefaultUserName"
                    $registryValue_PW = Get-ItemProperty -Path "$DefaultRegistryPath" -Name "DefaultPassword"

                    if ($env:username -eq "LCS") {
                        if ($registryValue_DU -ne $null) {
                            # Removes any previous Auto admin logon registry values
                            Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName"
                            Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword"

                            # Creates new registry values for Auto admin logon
                            New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "LCS" -Force
                            New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force

                            # Enables Auto admin logon
                            Set-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

                            Write-Host "Removing old registry entries. Setting AutoLogon for LCS.`n"
                        } else {
                            # Creates new registry values for Auto admin logon
                            New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "LCS" -Force
                            New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force

                            # Enables Auto admin logon
                            Set-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

                            Write-Host "Setting AutoLogon for LCS."
                        }
                    }

                    if ($env:username -eq "CVN") {
                        if ($registryValue_DU -ne $null) {
                            # Removes any previous Auto admin logon registry values
                            Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName"
                            Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword"

                            # Creates new registry values for Auto admin logon
                            New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "CVN" -Force
                            New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force

                            # Enables Auto admin logon
                            Set-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

                            Write-Host "Removing old registry entries. Setting AutoLogon on CVN.`n"
                        } else {
                            # Creates new registry values for Auto admin logon
                            New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "CVN" -Force
                            New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force

                            # Enables Auto admin logon
                            Set-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

                            Write-Host "Setting AutoLogon on for CVN."
                        }
                    }

                    Write-Host "Sea Trial post-Eval-STIG Policies and settings have been applied"

                    Start-Sleep -Seconds 1

                    #Add-Type -AssemblyName PresentationCore,PresentationFramework
                          #$Result = [System.Windows.MessageBox]::Show("Sea Trial Post-SCAP Policies have been applied", "501 Sea Trial LGP Editor",0,0)

                    #End
           
                } 
                }<#catch {
                Write-Host "cannot deliver command to $ip"
                }
                #>
                <#}
                else {
                write-host "$ip is unavailable" -ForegroundColor Red
                }
                #>
                }


else {
write-warning "a valid batch number was not entered.

Acceptable batch numbers:
1 = MOB
2 = MAR
3 = CVN
4 = DDG"
start-sleep 5
}

Read-Host