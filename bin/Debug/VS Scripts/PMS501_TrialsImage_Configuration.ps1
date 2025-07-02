##############################################
####  TRIALS IMAGE CONFIGURATION FOR W10  ####
####      DEVELOPED BY ANDREW MESSER      ####
##############################################

<# 
    PREAMBLE
This script performs a number of setup operations for the MSC Sea Trial Team.
1. Sets NIST LGPs required for SCC
2. Checks bitlocker encryption status is "FullyEncrypted"
3. Runs SCC scan and appends SCAP session to server shared folder
4. Sets LGPs for ETC-PKS use while onboard for trial
#>

# Checks if the script is running as an administrator #
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$scriptName = $MyInvocation.MyCommand.Name
########################################################################
write-host "
##   ##   #######  #######
# # # #  #         #         
#  #  #   ######   #          
#     #         #  #              
#     #  #######   #######  

MARINE SYSTEMS CORPORATION`n`nRunning Sea Trial Script ($scriptName...) on $env:COMPUTERNAME"
Start-Sleep -Seconds 5


########################################################################

<#
SET PRE-SCAP LOCAL GROUP POLICIES
**********************************
#>
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

#Set Windows dialog box title for the legal banner (V-220922)
$legalNoticeCaptionPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$testLegalNoticeCaptionPath = Get-ItemProperty -Path $legalNoticeCaptionPath -Name "legalnoticecaption"

if ($testLegalNoticeCaptionPath.legalnoticecaption -ne "US Department of Defense Warning Statement") {
Set-ItemProperty -Path $legalNoticeCaptionPath -Name "legalnoticecaption" -Value "US Department of Defense Warning Statement" -Force
Write-Host "Property set to $($testLegalNoticeCaptionPath.legalnoticecaption)"
}
Else {
"Property Exists"
}

#Set required legal notice to display before console logon (V-220921)
$legalNoticeCaptionPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
$testLegalNoticeTextPath = Get-ItemProperty -Path $legalNoticeCaptionPath -Name "LegalNoticeText"
if ($testLegalNoticeTextPath.legalnoticetext -eq "") {
    Set-ItemProperty -Path $legalNoticeCaptionPath -Name "legalnoticetext" -Value "You are accessing a U.S. Government (USG) Information System (IS) that is provided for USG-authorized use only.
By using this IS (which includes any device attached to this IS), you consent to the following conditions:
-The USG routinely intercepts and monitors communications on this IS for purposes including, but not limited to, penetration testing, COMSEC monitoring, network operations and defense, personnel misconduct (PM), law enforcement (LE), and counterintelligence (CI) investigations.
-At any time, the USG may inspect and seize data stored on this IS.
-Communications using, or data stored on, this IS are not private, are subject to routine monitoring, interception, and search, and may be disclosed or used for any USG-authorized purpose.
-This IS includes security measures (e.g., authentication and access controls) to protect USG interests--not for your personal benefit or privacy.
-Notwithstanding the above, using this IS does not constitute consent to PM, LE or CI investigative searching or monitoring of the content of privileged communications, or work product, related to personal representation or services by attorneys, psychotherapists, or clergy, and their assistants. 
Such communications and work product are private and confidential. See User Agreement for details." -Force
    Write-Host "Property Set"
    }
    Else {
    "Property Exists"
    }

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

########################################################################

Write-Host "Checking Bitlocker Encryption status...`n`n"
start-sleep -Seconds 3

#CHECKS BITLOCKER STATUS
do {
    # Get BitLocker encryption status
    $encryptionStatus = (Get-BitLockerVolume -MountPoint "C:").VolumeStatus
    write-host "encryption status: $encryptionStatus"

    # Check if encryption is complete
    if ($encryptionStatus -eq "FullyEncrypted") {
        break
        }
    
    # If bitlocker is not enabled, end the script
    if ($encryptionStatus -eq "FullyDecrypted") {
        Write-Warning "Bitlocker is not enabled. SCC scan cannot run. Exiting"
        Start-Sleep -Seconds 5
        exit
        }

    # Pause script while encrypting
    Start-Sleep -Seconds 10
} until ($encryptionStatus -eq "FullyEncrypted")

# Encryption is complete
Write-Host "BitLocker encryption is complete on Drive: C:`n`n"
start-sleep -Seconds 1

########################################################################

#ASSIGNS SCAP SESSION SOURCE AND DESTINATION FILEPATH
$sourceFilePath = "C:\Users\LCS\SCC\Sessions"
$destinationFilePath = "\\192.168.56.252\etcdata\SCAP"

if(Test-Path $destinationFilePath){
    write-host("Conection Established to $destinationFilePath") -ForegroundColor Green
}else{
    Write-Warning("Filepath $destinationFilePath could not be found. Please locate SCAP session in {C:\Users\LCS\SCC\Sessions} after scan.")
}

#DELETES SCAP SOURCE AND DESTINATION SESSION FOLDER CONTENTS
Get-ChildItem -Path $sourceFilePath | Remove-Item -Recurse
#Get-ChildItem -Path $destinationFilePath | Remove-Item -Recurse

Write-Host "Deleting previous SCAP scan sessions. `nRunning SCAP v5.9 CLI scan...`n`n"
Start-Sleep -Seconds 3

#Runs SCAP v.5.9 scan
Start-Process -FilePath "C:\Program Files\SCAP Compliance Checker 5.9\cscc.exe" -Wait


#CONCATENATES FILENAME
$staticText = "SCAP-Scan."
$shortComputerName = $env:COMPUTERNAME
$scanFilenameDestination = Join-Path -Path $destinationFilePath\$staticText$shortComputerName -ChildPath ("SCC-SESSION")
#WARNING: **when changing file path, leave \$shortComputerName-$recoveryID.txt"**

#COPIES SCAP SESSION FOLDER FROM SOURCE TO DESTINATION
$scapSession = Get-ChildItem -Path $sourceFilePath -Exclude "*.db"
Get-ChildItem -Path $sourceFilePath | Copy-Item -Destination $scanFilenameDestination -Recurse -Exclude "*.db" -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
if(Test-Path $destinationFilePath){
    Write-Host "SCAP Session folder $scapSession has been copied to $destinationFilePath`n`n" -ForegroundColor Yellow -BackgroundColor Black
}

#Displays SCAP HTML Results to the screen
$sessions = "C:\Users\LCS\SCC\Sessions"

$scapResults = Get-ChildItem -Path $sessions -Directory

foreach ($scapResult in $scapResults) {
    $htmlFiles = Get-ChildItem -Path $scapResult.FullName -Filter *.html -File

    foreach ($htmlFile in $htmlFiles) {
        Start-Process $htmlFile.FullName
    }
}


########################################################################>

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

#Set Windows dialog box title for the legal banner to null
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
start-sleep -Seconds 5

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
else{
    Write-Warning "User is currently not logged on as LCS. Password will not be set. `nCurrent user: $env:USERNAME"
}

<# Set AutoLogon
$DefaultRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$registryValue_DU = Get-ItemProperty -Path "$DefaultRegistryPath" -Name "DefaultUserName"
$registryValue_PW = Get-ItemProperty -Path "$DefaultRegistryPath" -Name "DefaultPassword"

if ($registryValue_DU -ne $null) {
    # Removes any previous Auto admin logon registry values
    Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName"
    Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword"

    # Creates new registry values for Auto admin logon
    New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "LCS" -Force
    New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force

    # Enables Auto admin logon
    Set-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

    Write-Host "Removing old registry entries. Setting AutoLogon.`n"
} else {
    # Creates new registry values for Auto admin logon
    New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "LCS" -Force
    New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force

    # Enables Auto admin logon
    Set-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

    Write-Host "Setting AutoLogon."
}#>

Write-Host "Sea Trial post-SCAP Policies and settings have been applied"

Start-Sleep -Seconds 5

#Add-Type -AssemblyName PresentationCore,PresentationFramework
      #$Result = [System.Windows.MessageBox]::Show("Sea Trial Post-SCAP Policies have been applied", "501 Sea Trial LGP Editor",0,0)

#End