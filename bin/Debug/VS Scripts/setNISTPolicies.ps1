##############################################
####  TRIALS IMAGE CONFIGURATION FOR W10  ####
####      DEVELOPED BY ANDREW MESSER      ####
##############################################

<# 
    PREAMBLE
This script performs a number of setup operations for the MSC Sea Trial Team.
1. Sets NIST LGPs required for SCC
#>

# Checks if the script is running as an administrator #
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "
# # # # # # # # # # # # # # #
#                           #
#     Set NIST Policies     #
#                           #
# # # # # # # # # # # # # # #
`n`n"

Write-Host "Sets NIST(STIG) policies on clients `n`n" -ForegroundColor Yellow

$data = @(
    @{ Name = "Mobile"; Value = "1" },
    @{ Name = "Marinette"; Value = "2" }
    @{ Name = "CVN"; Value = "3" }
)

# Create a border and format the table
$border = "┌────────────┬──────────┐"
$borderBottom = "└────────────┴──────────┘"

Write-Output $border
Write-Output "│ Batch      │ Number   │"
Write-Output $border.Replace("┌", "├").Replace("┐", "┤")

foreach ($item in $data) {
    Write-Output ("│ {0,-9}  │ {1,-9}│" -f $item.Name, $item.Value)
}

Write-Output $borderBottom

$whichBatch = Read-Host "Select batch number"

if ($whichBatch -le 3) {

#MOB
$mobClients = @()
for ($i = 201; $i -le 223; $i++) {
    $mobClients += "192.168.56.$i"
}

#MAR
$marClients = @()
for ($i = 101; $i -le 123; $i++) {
    $marClients += "192.168.56.$i"
}

#CVN
$cvnClients = @()
for ($i = 101; $i -le 148; $i++) {
    $cvnClients += "192.168.79.$i"
}


# Provide credentials for hosts
$securePassword = ConvertTo-SecureString "L-3Communicati0ns!" -AsPlainText -Force
$lcsCredential = New-Object System.Management.Automation.PSCredential ("LCS", $securePassword)
$cvnCredential = New-Object System.Management.Automation.PSCredential ("CVN", $securePassword)

#Get batch and credential
if ($whichBatch -eq 1) {
        $batch = $mobClients 
        $credential = $lcsCredential}
    elseif ($whichBatch -eq 2) {
        $batch = $marClients
        $credential = $lcsCredential}
    elseif ($whichBatch -eq 3) {
        $batch = $cvnClients
        $credential = $cvnCredential}


    write-host "`nSetting production policies on:`n"
    $timeout = 100 # Timeout in milliseconds

    # Filepath arguments for invoke-command block 
    #$logonNoticeTextPath = "C:\Users\$($env:USERNAME)\AppData\Roaming\VS_Scripts\legalLogonNotice.txt"

    Write-Host "Querying hosts. This may take a while...`n" -ForegroundColor Magenta
    $batch | ForEach-Object {
        $ip = $_
        $ping = New-Object System.Net.NetworkInformation.Ping
        $reply = $ping.Send($ip, $timeout)
        if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
            try {
                Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { Write-Host $env:COMPUTERNAME -ForegroundColor Green }
                Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                #param($logonNoticeTextPath)


                Write-Host "Running Pre-SCAP Scan Local Group Policies..." -ForegroundColor Yellow -BackgroundColor Black

                Start-Sleep -Seconds 1

                #Machine Inactivity Limit = 900 (V-220920)
                Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "InactivityTimeoutSecs" -Value 900 -Force

                #Maximum Password Age = 60 days (V-220743)
                net accounts /maxpwage:60

                #Account Lockout Threshold = 3 Attempts (V-220740)
                net accounts /lockoutthreshold:3

                <#
                #The Windows Firewall with Advanced Security must block unsolicited inbound connections when connected to a domain (V-241992)
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Name "DefaultInboundAction" -Force
                New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\DomainProfile" -Name "DefaultInboundAction" -Value 1 -PropertyType DWORD -Force

                #The Windows Firewall with Advanced Security must block unsolicited inbound connections when connected to a private network (V-241997)
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" -Name "DefaultInboundAction" -Force
                New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PrivateProfile" -Name "DefaultInboundAction" -Value 1 -PropertyType DWORD -Force

                #The Windows Firewall with Advanced Security must block unsolicited inbound connections when connected to a public network (V-242002)
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "DefaultInboundAction" -Force
                New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\WindowsFirewall\PublicProfile" -Name "DefaultInboundAction" -Value 1 -PropertyType DWORD -Force
                #>

                #Set UAC to always prompt administrators for consent on the secure desktop (V-220945)
                Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2 -Force
                "UAC Set to always prompt admins`n"

                #Disables AutoLogon
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -Force
                "Auto admin logon Removed`n"
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -Force
                "DefaultPassword Removed`n"
                Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -Force
                "DefaultUserName Removed`n"

                #Set Windows dialog box title for the legal banner (V-220922)
                $legalNoticeCaptionPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
                $testLegalNoticeCaptionPath = Get-ItemProperty -Path $legalNoticeCaptionPath -Name "legalnoticecaption"
                Set-ItemProperty -Path $legalNoticeCaptionPath -Name "legalnoticecaption" -Value "US Department of Defense Warning Statement" -Force
                Write-Host "Property set to $($testLegalNoticeCaptionPath.legalnoticecaption)"

                #Set required legal notice to display before console logon (V-220921)
                #$logonNoticeTextPath = "C:\Admin Only\DoD Banners\V-253445_DoD_Logon_Text.txt"
                #$textFileContent = Get-Content -Path $logonNoticeTextPath
                $legalNoticeText = @"
You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only.

By using this IS (which includes any device attached to this IS), you consent to the following conditions:

-The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations.

-At any time, the USG may inspect and seize data stored on this IS.

-Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG-authorized purpose.

-This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your personal benefit or privacy.

-Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants.  Such communications and work product are private and confidential.  See User Agreement for details.
"@.Trim()
                Set-ItemProperty -Path $legalNoticeCaptionPath -Name "legalnoticetext" -Value $legalNoticeText -Force

                
                Write-Host "Legal Notice Text Property Set"

                #Disables Built-in Local Administrator
                Disable-LocalUser -Name "MSC_MOB"
                if ($?) {
                Write-Host "Built-in Local Administrator is disabled"
                }
                else {
                Write-Warning "Built-in Local Administrator could not be disabled"
                }

                #SET OFFICE FILEBLOCK STIG POLICIES (V-223314 - V-223414)
                # Set the registry path for Word FileBlock policy
                $wordRegPath = "HKCU:\Software\Policies\Microsoft\Office\16.0\Word\Security\FileBlock"
                # Set the registry path for Excel FileBlock policy
                $excelRegPath = "HKCU:\Software\Policies\Microsoft\Office\16.0\Excel\Security\FileBlock" #-ErrorAction SilentlyContinue
                Write-Host "Checking Word and Excel FileBlock registry keys...`n`n"

                #Word Registry Entries
                if(Test-Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Word\Security\FileBlock")
                {
                    Write-Host "Adding registry entries to allow Word binary files..." -ForegroundColor Yellow
                    New-ItemProperty -Path $wordRegPath -Name "word2000files" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "word2003files" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "word2007files" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "word2files" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "word60files" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "word95files" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "word97files" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "wordxp" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "word2000files" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "wordxml" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "wordxpfiles" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "OpenInProtectedView" -Value 0 -Force
                }
                else {
                    Write-Host "Creating new path in registry: ($wordRegPath). Adding registry entries to allow Word and Excel binary files..." -ForegroundColor Yellow
                    New-Item -Path $wordRegPath -Force
                    New-ItemProperty -Path $wordRegPath -Name "word2000files" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "word2003files" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "word2007files" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "word2files" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "word60files" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "word95files" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "word97files" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "wordxp" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "word2000files" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "wordxml" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "wordxpfiles" -Value 2 -Force
                    New-ItemProperty -Path $wordRegPath -Name "OpenInProtectedView" -Value 0 -Force
                }

                #Excel Registry Entries
                if(Test-Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Excel\Security\FileBlock")
                {
                    Write-Host "Adding registry entries to allow Excel binary files...`n" -ForegroundColor Yellow
                    New-ItemProperty -Path $excelRegPath -Name "xl2macros" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl2worksheets" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl3macros" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl3worksheets" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl4macros" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl4workbooks" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl4worksheets" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl9597workbooksandtemplates" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl95workbooks" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl97addins" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl97workbooksandtemplates" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xlamfiles" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xlsbfiles" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xlsmandxltmfiles" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xlsxandxltxfiles" -Value 2 -Force
                }
                else {
                    Write-Host "Creating new path in registry: ($excelRegPath). Adding registry entries to allow Excel binary files...`n" -ForegroundColor Yellow
                    New-Item -Path $excelRegPath -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl2macros" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl2worksheets" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl3macros" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl3worksheets" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl4macros" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl4workbooks" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl4worksheets" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl9597workbooksandtemplates" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl95workbooks" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl97addins" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xl97workbooksandtemplates" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xlamfiles" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xlsbfiles" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xlsmandxltmfiles" -Value 2 -Force
                    New-ItemProperty -Path $excelRegPath -Name "xlsxandxltxfiles" -Value 2 -Force
                }

                # V-220861 - The Windows Explorer Preview pane must be disabled for Windows 10. 
                New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoPreviewPane" -Value 1 -PropertyType DWORD -Force
                New-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoReadingPane" -Value 1 -PropertyType DWORD -Force

                # V-220954 - Toast notifications to the lock screen must be turned off.
                New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" -Force
                New-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "NoToastApplicationNotificationOnLockScreen" -Value 1 -PropertyType DWORD -Force

                # V-220716 - Accounts must be configured to require password expiration.
                Set-LocalUser -Name "MSC_MOB" -PasswordNeverExpires $false

                Set-LocalUser -Name "LCS" -PasswordNeverExpires $false

                Set-LocalUser -Name "CVN" -PasswordNeverExpires $false

                # V-260465 - Visual Search must be disabled.
                New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "VisualSearchEnabled" -Value 0 -PropertyType DWORD -Force
                New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "HubsSidebarEnabled" -Value 0 -PropertyType DWORD -Force
                New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Name "DefaultCookiesSetting" -Value 4 -PropertyType DWORD -Force

                "`nUpdating Group Policy..."
                start-sleep -Seconds 5

                #Updates local group policy
                Start-Process -FilePath "C:\Admin Only\Batch\gpUpdate.bat" -Wait

                Start-Sleep -Seconds 1

                #END PRE-SCAP LOCAL GROUP POLICY

                Write-Host "Pre-SCAP Scan Local Group Policies set.`n`n"

                Start-Sleep -Seconds 1

                } -ArgumentList $logonNoticeTextPath           
                }catch {
                Write-Host "cannot deliver command to $ip"
                }
                }
            else {
            write-host "$ip is unavailable" -ForegroundColor Red
            }
            }
}
else {
write-warning "a valid batch number was not entered.

Acceptable batch numbers:
1 = MOB
2 = MAR
3 = CVN"
start-sleep 5
}  