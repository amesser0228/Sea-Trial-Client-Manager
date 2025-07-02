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

Write-Host "
# # # # # # # # # # # # # #
#                         # 
#   Client Status Check   #
#                         #
# # # # # # # # # # # # # #
`n`n"

Write-Host "Runs a quick query to each client in the selected batch to check if its online.`n`n" -ForegroundColor Yellow

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


$mobClients = @(
#MOB
"192.168.56.201"
"192.168.56.202",
"192.168.56.203",
"192.168.56.204",
"192.168.56.205",
"192.168.56.206",
"192.168.56.207",
"192.168.56.208",
"192.168.56.209",
"192.168.56.210",
"192.168.56.211",
"192.168.56.212",
"192.168.56.213",
"192.168.56.214",
"192.168.56.215",
"192.168.56.216",
"192.168.56.217",
"192.168.56.218",
"192.168.56.219",
"192.168.56.220",
"192.168.56.221",
"192.168.56.222",
"192.168.56.223")

$marClients = @(
#MAR
"192.168.56.101"
"192.168.56.102",
"192.168.56.103",
"192.168.56.104",
"192.168.56.105",
"192.168.56.106",
"192.168.56.107",
"192.168.56.108",
"192.168.56.109",
"192.168.56.110",
"192.168.56.111",
"192.168.56.112",
"192.168.56.113",
"192.168.56.114",
"192.168.56.115",
"192.168.56.116",
"192.168.56.117",
"192.168.56.118",
"192.168.56.119",
"192.168.56.120",
"192.168.56.121",
"192.168.56.122",
"192.168.56.123")

$cvnClients = @(
#CVN
"192.168.79.101",
"192.168.79.102",
"192.168.79.103",
"192.168.79.104",
"192.168.79.105",
"192.168.79.106",
"192.168.79.107",
"192.168.79.108",
"192.168.79.109",
"192.168.79.110",
"192.168.79.111",
"192.168.79.112",
"192.168.79.113",
"192.168.79.114",
"192.168.79.115",
"192.168.79.116",
"192.168.79.117",
"192.168.79.118",
"192.168.79.119",
"192.168.79.120",
"192.168.79.121",
"192.168.79.122",
"192.168.79.123",
"192.168.79.124",
"192.168.79.125",
"192.168.79.126",
"192.168.79.127",
"192.168.79.128",
"192.168.79.129",
"192.168.79.130",
"192.168.79.131",
"192.168.79.132",
"192.168.79.133",
"192.168.79.134",
"192.168.79.135",
"192.168.79.136",
"192.168.79.137",
"192.168.79.138",
"192.168.79.139",
"192.168.79.140",
"192.168.79.141",
"192.168.79.142",
"192.168.79.143",
"192.168.79.144",
"192.168.79.145",
"192.168.79.146",
"192.168.79.147"
"192.168.79.148")

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


#Check if clients in batch respond online
Write-Host "Querying hosts. This may take a while...`n" -ForegroundColor Magenta
Start-Sleep 2
$timeout = 100 # Timeout in milliseconds
$batch | ForEach-Object {
    $ip = $_
    $ping = New-Object System.Net.NetworkInformation.Ping
    $reply = $ping.Send($ip, $timeout)
    if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
        try {
                    Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { 
                    Write-Host "$env:COMPUTERNAME is online" -ForegroundColor Green
                }
                }                                                                                            
                catch {
                Write-Host "cannot deliver command to $ip"
                }
                }
                else {
                write-host "$ip is unavailable" -ForegroundColor Red
                }
                }
    Read-Host "Press any key to exit"
