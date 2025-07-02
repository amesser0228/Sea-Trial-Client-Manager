##############################################
####    ISSE SCAN CONFIGURATION FOR W10   ####
####      DEVELOPED BY ANDREW MESSER      ####
##############################################

<# 
    PREAMBLE
This script performs a number of setup operations for the MSC Sea Trial Team...
1. Disables and attempts to remove WiFi/BT Drivers
2. Checks bitlocker encryption status.
2. Runs E-S scan and appends results to server folder.
3. Displays SCC HTML Summary Viewer to screen.

#>

#PREVENT WINDOWS SCRIPTS FROM RUNNING ON SERVER
$OS_Name = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption

if ($OS_Name -notlike '*Windows Server*') {

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


# DISABLE/REMOVE WIFI AND BLUETOOTH DRIVERS
###########################################


# DISABLE/REMOVE WIFI-DRIVER IF PRESENT IN WINDOWS
"Attempting to disable Wi-Fi driver..."
Start-Sleep 1
Disable-NetAdapter -Name "Wi-Fi" -Confirm:$false -ErrorAction SilentlyContinue
if ($?) {
Write-Host 'Success. Wi-Fi driver $driver disabled' -ForegroundColor Green
}
else {
Write-Warning "Wi-Fi Driver could not be disabled or driver package has already been removed."
}

$WiFi_Drivers = Get-PnpDevice -Class Net | Where-Object {$_.Description -like "*Wi-Fi*"} | Select-Object -First 1 | Select-Object -ExpandProperty InstanceID

foreach ($driver in $WiFi_Drivers) {
pnputil /remove-device $driver
}

# DISABLE/REMOVE BLUETOOTH DRIVER IF PRESENT IN WINDOWS
"`n`n"

"Attempting to disable Blueooth driver..."
Start-Sleep 1
$bluetoothDriver = Get-PnpDevice -Class Bluetooth | Where-Object {$_.Status -eq "OK"}

foreach ($driver in $bluetoothDriver) {
Disable-PnpDevice -InstanceId $driver.InstanceId -Confirm:$false
}
if ($?) {
Write-Host "Success. Bluetooth driver $driver disabled" -ForegroundColor Green
}
else {
Write-Warning "$driver could not be disabled"
}

# BITLOCKER CHECK
###########################################

# CHECKS BITLOCKER STATUS
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
        Write-Warning "Bitlocker is not enabled. SCC scan cannot run. Exiting..."
        Start-Sleep -Seconds 5
        exit
        }

    # Pause script while encrypting
    Start-Sleep -Seconds 20
} until ($encryptionStatus -eq "FullyEncrypted")

# Encryption is complete
Write-Host "BitLocker encryption is complete on Drive: C:`n`n"
start-sleep -Seconds 2

# ENABLE BITLOCKER PIN POLICIES FOR E-S SCAN
Write-Host "Enabling Bitlocker PIN Policies for Evaluate-STIG Scan"

$bdePINPath = "HKLM:SOFTWARE\Policies\Microsoft\FVE"

New-Item -Path $bdePINPath
New-ItemProperty -Path $bdePINPath -Name "UseTPMPIN" -Value 1 -Force
New-ItemProperty -Path $bdePINPath -Name "UseTPMKeyPIN" -Value 1 -Force
New-ItemProperty -Path $bdePINPath -Name "MinimumPIN" -Value 6 -Force
New-ItemProperty -Path $bdePINPath -Name "EnableBDEWithNoTPM" -Value 1 -Force 
New-ItemProperty -Path $bdePINPath -Name "UseAdvancedStartup" -Value 1 -Force 

Start-Sleep 2

# FOLDER ASSIGNMENT AND E-S SCAN
###########################################

# ASSIGN E-S SESSION DESTINATION FILEPATH
$destinationFilePath = "\\192.168.56.252\etcdata\Evaluate-STIG" #confirm name of folder for E-S on server

if(Test-Path $destinationFilePath){
    write-host("Conection Established to $destinationFilePath") -ForegroundColor Green

Set-Location "C:\Admin Only\Evaluate-STIG\Evaluate-STIG"

.\Evaluate-STIG.ps1  -Output CKL,Summary -VulnTimeout 15 -PreviousToKeep 1 -ScanType Unclassified -AFPath "C:\Admin Only\Evaluate-STIG\Evaluate-STIG\AnswerFiles" -OutputPath "\\192.168.56.252\etcdata\Evaluate-Stig"

<#Copy E-S results to another destination
$evaluateSTIG_SourcePath = "C:\Admin Only\Evaluate-STIG\Output"
Get-ChildItem -Path $evaluateSTIG_SourcePath | Copy-Item -Destination "C:\Users\LCS\Documents" -Recurse -ErrorAction SilentlyContinue
#>
}
}

else {
Write-Warning 'Cannot run script on Server.'
}