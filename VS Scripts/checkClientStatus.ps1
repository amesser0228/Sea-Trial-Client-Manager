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

SYNOPSIS:

    1. QUERIES HOSTS IN CLIENT ARRAY
    2. RUNS COMMAND WITH REMOTE CREDENTIALS TO EACH HOST
    #>

$runScript = Read-Host "`n`nPress enter to continue or Q to quit"
if($runScript -eq "Q" -or $runScript -eq "q") {
    return
}
else {}

Write-Host "
# # # # # # # # # # # # # #
#                         # 
#   Client Status Check   #
#                         #
# # # # # # # # # # # # # #
`n`n"

Write-Host "Runs a quick query to each client in the selected batch to check if its online.`n`n" -ForegroundColor Yellow


#Check if clients in batch respond online
Write-Host "Querying hosts. This may take a while...`n" -ForegroundColor Magenta

#loop Counter for num of reachable clients
$numReplied = 0

#loop Counter for num of clients that ran the script
$numRan = 0

#loop Counter for num of unreachable clients
$numFailed = 0

Start-Sleep 2
$timeout = 100 # Timeout in milliseconds
$remoteIPAddresses | ForEach-Object {
    $ip = $_
    $ping = New-Object System.Net.NetworkInformation.Ping
    $reply = $ping.Send($ip, $timeout)
    if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
        $numReplied += 1
        try {
                    Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { 
                    Write-Host "$env:COMPUTERNAME is online" -ForegroundColor Green
                }
                $numRan += 1
                }   
                catch {
                Write-Host "cannot deliver command to $ip"
                }
                }
                else {
                $numFailed += 1
                write-host "$ip is unavailable" -ForegroundColor Red
                }
                }
        Write-Host "Number of clients that responded: " -NoNewline 
        Write-Host "$numReplied" -ForegroundColor Green
        Write-Host "Number of clients that ran the script: " -NoNewline 
        Write-Host "$numRan" -ForegroundColor Green
        Write-Host "Number of clients that failed to respond: " -NoNewline
        Write-Host "$numFailed" -ForegroundColor Red
    Read-Host "Press any key to exit"
