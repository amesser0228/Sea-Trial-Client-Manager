function Get-Password {
    param (
        [string]$prompt = "Enter LCS Password: "
    )
    $password = Read-Host -AsSecureString $prompt
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
}

# Prompt for a password
$password = Get-Password
$correctPassword = "LCS"  # Set your secure password here

if ($password -ne $correctPassword) {
    Write-Host "Incorrect password. Exiting script."
    exit
}

powershell -sta -file "F:\Scripts\PS Scripts\VS Scripts\checkBox_PowerDownScripts.ps1"