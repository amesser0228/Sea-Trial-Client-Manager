# Checks if the script is running as an administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Define the list of remote clients
$mobClients = @(
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
"192.168.56.101",
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

Write-Host "
# # # # # # # # # # # # # # #
#                           #
#   Enable AutoAdminLogon   #
#                           #
# # # # # # # # # # # # # # #
`n`n"

$securePassword = ConvertTo-SecureString "L-3Communicati0ns!" -AsPlainText -Force

$credential = New-Object System.Management.Automation.PSCredential ("LCS", $securePassword)
$cvnCredential = New-Object System.Management.Automation.PSCredential ("CVN", $securePassword)


$whichBatch = Read-Host "
Which batch is this report for?

    1 = MOB

    2 = MAR 

    3 = CVN

Enter batch number"

if ($whichBatch -eq 1) {

    write-host "`nSetting production policies on:`n"
    $timeout = 100 # Timeout in milliseconds

    Write-Host "Querying hosts. This may take a while...`n" -ForegroundColor Magenta
    $mobClients | ForEach-Object {
        $ip = $_
        $ping = New-Object System.Net.NetworkInformation.Ping
        $reply = $ping.Send($ip, $timeout)
        if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
            try {
                Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { Write-Host $env:COMPUTERNAME -ForegroundColor Green }
                Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {

                    # Set AutoLogon
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
                    }
                    } 
                }catch {
                Write-Host "cannot deliver command to $ip"
                }
                }
                else {
                write-host "$ip is unavailable" -ForegroundColor Red
                }
                }
            }

elseif ($whichBatch -eq 2) {

    write-host "`nSetting production policies on:`n"
    $timeout = 100 # Timeout in milliseconds

    Write-Host "Querying hosts. This may take a while...`n" -ForegroundColor Magenta
    $marClients | ForEach-Object {
        $ip = $_
        $ping = New-Object System.Net.NetworkInformation.Ping
        $reply = $ping.Send($ip, $timeout)
        if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
            try {
                Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { Write-Host $env:COMPUTERNAME -ForegroundColor Green }
                Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {

                    # Set AutoLogon
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
                    }
                    } 
                }catch {
                Write-Host "cannot deliver command to $ip"
                }
                }
                else {
                write-host "$ip is unavailable" -ForegroundColor Red
                }
                }
            }

elseif ($whichBatch -eq 3) {

    write-host "`nSetting production policies on:`n"
    $timeout = 100 # Timeout in milliseconds

    Write-Host "Querying hosts. This may take a while...`n" -ForegroundColor Magenta
    $cvnClients | ForEach-Object {
        $ip = $_
        $ping = New-Object System.Net.NetworkInformation.Ping
        $reply = $ping.Send($ip, $timeout)
        if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
            try {
                Invoke-Command -ComputerName $ip -Credential $cvnCredential -ScriptBlock { Write-Host $env:COMPUTERNAME -ForegroundColor Green }
                Invoke-Command -ComputerName $ip -Credential $cvnCredential -ScriptBlock {

                    # Set AutoLogon
                    $DefaultRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                    $registryValue_DU = Get-ItemProperty -Path "$DefaultRegistryPath" -Name "DefaultUserName"
                    $registryValue_PW = Get-ItemProperty -Path "$DefaultRegistryPath" -Name "DefaultPassword"

                    if ($registryValue_DU -ne $null) {
                        # Removes any previous Auto admin logon registry values
                        Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName"
                        Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword"

                        # Creates new registry values for Auto admin logon
                        New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "CVN" -Force
                        New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force

                        # Enables Auto admin logon
                        Set-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

                        Write-Host "Removing old registry entries. Setting AutoLogon.`n"
                    } else {
                        # Creates new registry values for Auto admin logon
                        New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "CVN" -Force
                        New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force

                        # Enables Auto admin logon
                        Set-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

                        Write-Host "Setting AutoLogon."
                    }
                    } 
                }catch {
                Write-Host "cannot deliver command to $ip"
                }
                }
                else {
                write-host "$ip is unavailable" -ForegroundColor Red
                }
                }
            }