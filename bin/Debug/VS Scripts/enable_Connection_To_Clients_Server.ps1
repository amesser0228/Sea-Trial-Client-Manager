<#DEVELOPED BY ANDREW MESSER

SYNOPSIS:

    1. QUERIES HOSTS IN CLIENT ARRAY
    2. RUNS COMMAND WITH REMOTE CREDENTIALS TO EACH HOST
    #>

#PREVENT WINDOWS SCRIPTS FROM RUNNING ON SERVER
$OS_Name = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption

if ($OS_Name -notlike '*Microsoft Windows*') {

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
#    Enable Connection to   #
#   Clients on this Server  #
#                           #
# # # # # # # # # # # # # # #
`n`n"

#ENABLE PSREMOTING ON HOST
Enable-PSRemoting -SKIPNETWORKPROFILECHECK -Force
if($?) {
Write-Host "PSRemoting service has been started on $ENV:COMPUTERNAME"
}
start-Sleep 1

$whichBatch = Read-Host "
Which batch is this for?

    1 = LCS

    2 = CVN

Enter batch number"

#ADD ALL REMOTE HOSTS TO TRUSTED HOSTS
if ($whichBatch -eq 1) {
Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value "192.168.56.*" -Force
Write-Host "Configuring trusted hosts for LCS IP Scope."
}
elseif ($whichBatch -eq 2) {
Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value "192.168.79.*" -Force
$trustedHosts = Get-Item -Path WSMan:\localhost\Client\TrustedHosts
Write-Host "Configuring trusted hosts for CVN IP Scope."
}
if ($?) {
Write-Host "Trusted hosts have been added to localhost"
}
Start-Sleep -Seconds 3
Write-Host "Complete" -foregroundcolor green
start-sleep -seconds 2

#Get-Help about_Remote_Troubleshooting
}
else {
Write-Warning 'This script version is only for Windows server.'
}