####################################################
######     BITLOCKER CONFIGURATION FOR W10    ######
######       DEVELOPED BY ANDREW MESSER       ######
####################################################

<# 
    PREAMBLE
This script performs a number of setup operations for the MSC Sea Trial Team.
1. Enables Bitlocker on C: and copies security key to server share 
#>

#REVENT WINDOWS SCRIPTS FROM RUNNING ON SERVER
$OS_Name = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption

if ($OS_Name -notlike '*Windows Server*') {

# Checks if the script is running as an administrator
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


#############################################


#LOOKS FOR DESTINATION DRIVE BEFORE BITLOCKER ENCRYPTING
$filePath = "\\192.168.56.252\etcdata\BitLockerKeys"
if (Test-Path $filePath) {
Write-Host "Established Connection to: $filePath`n`n" -ForegroundColor Green

#RUNS BDE AND ENCRYPTS DRIVE
manage-bde -on C: -RecoveryPassword -EncryptionMethod AES256
$recoveryInfo = Get-BitLockerVolume -MountPoint "C:" | Select-Object -ExpandProperty KeyProtector | Where-Object {$_.KeyProtectorType -eq 'RecoveryPassword'}
$recoveryID = $recoveryInfo.KeyProtectorId
$recoveryPassword = $recoveryInfo.RecoveryPassword
$computerName = $env:COMPUTERNAME.Substring(0,3)
$shortComputerName = $computerName

#SAVES RECOVERY ID AND PASSWORD (WARNING: **when changing file path, leave "\$shortComputerName-$recoveryID.txt"**)
$bdeKeyPath = "$filePath\$shortComputerName-$recoveryID.txt"
$recoveryInfo | Out-File -FilePath $bdeKeyPath
Write-Host "BitLocker recovery ID and password saved to: $filepath" -ForegroundColor Yellow -BackgroundColor Black
Start-Sleep -Seconds 8
#Restart-Computer
} 
else {
    write-warning "Filepath: $filePath is not available. BitLocker encryption cannot be started."
    start-sleep -Seconds 5
}
}
else {
Write-Warning 'Cannot run script on windows server'
}