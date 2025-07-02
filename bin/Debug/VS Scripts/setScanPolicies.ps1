# Checks if the script is running as an administrator #
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

<#DEVELOPED BY ANDREW MESSER

<# 
    PREAMBLE
This script performs a number of setup operations for the MSC Sea Trial Team.
1. Sets NIST LGPs required for SCC
2. Checks bitlocker encryption status is "FullyEncrypted"
3. Runs SCC scan and appends SCAP session to server shared folder
4. Sets LGPs for ETC-PKS use while onboard for trial
#>

Write-Host "
# # # # # # # # # # # # # # #
#                           #
#     Set Scan Policies     #
#                           #
# # # # # # # # # # # # # # #
`n`n"

Write-Host "Sets production policies on clients `n`n" -ForegroundColor Yellow

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

#loop Counter for num of reachable clients
$numReplied = 0

#loop Counter for num of clients that ran the script
$numRan = 0

#loop Counter for num of unreachable clients
$numFailed = 0

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

    Write-Host "Querying hosts. This may take a while...`n" -ForegroundColor Magenta
    $batch | ForEach-Object {
        $ip = $_
        $ping = New-Object System.Net.NetworkInformation.Ping
        $reply = $ping.Send($ip, $timeout)
        if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
            $numReplied += 1
            try {
                Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { Write-Host $env:COMPUTERNAME -ForegroundColor Green }
                Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                    <#
                    SETS POST-SCAP LOCAL GROUP POLICIES
                    ***********************************
                    #>
                    write-host "setting Sea Trial Post-SCAP Local Policies and Settings`n`n"

                    Start-Sleep -Seconds 1

                    # Set sleep settings to never when plugged in
                    powercfg -change -standby-timeout-ac 0
                    powercfg -change -hibernate-timeout-ac 0

                    # Set screen settings to never turn off when plugged in
                    powercfg -change -monitor-timeout-ac 0

                    # Set screen timeout and sleep settings to Never when not plugged in
                    powercfg -Change -monitor-timeout-dc 0
                    powercfg -change -standby-timeout-dc 0
                    powercfg -change -hibernate-timeout-dc 0
                    Write-Host "setting power and sleep setings`n`n"



                    ########################################################################


                    # Set AutoLogon
                    $DefaultRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                    $registryValue_DU = Get-ItemProperty -Path "$DefaultRegistryPath" -Name "DefaultUserName"
                    $registryValue_PW = Get-ItemProperty -Path "$DefaultRegistryPath" -Name "DefaultPassword"

                    if ($env:username -eq "LCS") {
                        if ($registryValue_DU -ne $null) {
                            # Removes any previous Auto admin logon registry values
                            Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName"
                            Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword"

                            # Creates new registry values for Auto admin logon
                            New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "LCS" -Force
                            New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force

                            # Enables Auto admin logon
                            Set-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

                            Write-Host "Removing old registry entries. Setting AutoLogon for LCS.`n"
                        } else {
                            # Creates new registry values for Auto admin logon
                            New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "LCS" -Force
                            New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force

                            # Enables Auto admin logon
                            Set-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

                            Write-Host "Setting AutoLogon for LCS."
                        }
                    }

                    if ($env:username -eq "CVN") {
                        if ($registryValue_DU -ne $null) {
                            # Removes any previous Auto admin logon registry values
                            Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName"
                            Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword"

                            # Creates new registry values for Auto admin logon
                            New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "CVN" -Force
                            New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force

                            # Enables Auto admin logon
                            Set-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

                            Write-Host "Removing old registry entries. Setting AutoLogon on CVN.`n"
                        } else {
                            # Creates new registry values for Auto admin logon
                            New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "CVN" -Force
                            New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force

                            # Enables Auto admin logon
                            Set-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

                            Write-Host "Setting AutoLogon on for CVN."
                        }
                    }

                    Write-Host "Sea Trial post-SCAP Policies and settings have been applied"

                    Start-Sleep -Seconds 1

                    #Add-Type -AssemblyName PresentationCore,PresentationFramework
                          #$Result = [System.Windows.MessageBox]::Show("Sea Trial Post-SCAP Policies have been applied", "501 Sea Trial LGP Editor",0,0)

                    #End
           
                } 
                $numRan += 1
                }catch {
                Write-Host "cannot deliver command to $ip"
                }
                }
                else {
                write-host "$ip is unavailable" -ForegroundColor Red
                $numFailed += 1
                }
              }

Write-Host "Number of clients that responded: " -NoNewline 
Write-Host "$numReplied" -ForegroundColor Green
Write-Host "Number of clients that ran the script: " -NoNewline 
Write-Host "$numRan" -ForegroundColor Green
Write-Host "Number of clients that failed: " -NoNewline
Write-Host "$numFailed" -ForegroundColor Red

}
else {
write-warning "a valid batch number was not entered.

Acceptable batch numbers:
1 = MOB
2 = MAR
3 = CVN"
start-sleep 5
}