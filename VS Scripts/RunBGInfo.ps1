# RunBGInfo.ps1

# Checks if the script is running as an administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}
Write-Host "Updating BGInfo desktop information`nDO NOT close GBInfo Window, the script will handle the form closing"

# Path to BGInfo
$bginfoPath = "C:\Systernals\Bginfo.exe"  # Change this to your actual BGInfo path

# Disable UAC admin prompt
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0 -Force

# Run BGInfo as Administrator
Start-Process -FilePath $bginfoPath -Verb RunAs

# Wait for BGInfo to launch
Start-Sleep -Seconds 3

# Close the BGInfo form with Enter keystroke
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

# Enable UAC admin prompt
#Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2 -Force