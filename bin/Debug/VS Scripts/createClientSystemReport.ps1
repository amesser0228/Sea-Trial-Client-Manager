# TRIAL CLIENT SYSTEM REPORT DEVELOPED BY ANDREW MESSER

<#Synopsis
    1. Retrieves report data from client array
    2. Converts data to PSCustomObject
    3. Writes object to CSV file in the filepath below.
#>


Write-Host " 
##### #####  #####   #   #        ##### #     ##### ##### #   # #####    ##### ##### #####  ####  ##### #####
  #   #   #    #    # #  #        #     #       #   #     ##  #   #      #   # #     # # # #    # #   #   #
  #   ####     #   #   # #        #     #       #   ####  # # #   #      ####  ####  ####  #    # ####    #
  #   #   #    #   # # # #        #     #       #   #     #  ##   #      #   # #     #     #    # #   #   #
  #   #   #  ##### #   # #####    ##### ##### ##### ##### #   #   #      #   # ##### #      ####  #   #   #
  
  Remote Host Report for PMS-501/CVN Reporting - MSC v.3.1
 `n`n`n" -ForegroundColor DarkCyan
 
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

$securePassword = ConvertTo-SecureString "L-3Communicati0ns!" -AsPlainText -Force

$credential = New-Object System.Management.Automation.PSCredential ("LCS", $securePassword)
$cvnCredential = New-Object System.Management.Automation.PSCredential ("CVN", $securePassword)

# Create an empty array to store the results
$results = @()

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

Write-Host "Generating Report...`n"

if ($whichBatch -eq 1) {

Write-Host "Collecting Report Data from:`n`n"
Start-Sleep 1

    $timeout = 100 # Timeout in milliseconds

Write-Host "Querying hosts. This may take a while...`n" -ForegroundColor Magenta
Start-Sleep 1
$marClients | ForEach-Object {
    $ip = $_
    $ping = New-Object System.Net.NetworkInformation.Ping
    $reply = $ping.Send($ip, $timeout)
    if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
        try {
            Write-Host "$ip is available for data collection" -ForegroundColor Green

            # Collect information from the available computer
            $computerName = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
            $env:COMPUTERNAME
            } -ErrorAction SilentlyContinue

            $os = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { 
            Get-WmiObject -Class Win32_OperatingSystem
            }

            # Get the computer system information
            $cs = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { 
            Get-WmiObject -Class Win32_ComputerSystem
            }

            $IP_Address = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { 
                $activeAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
                $ipAddress = (Get-NetIPAddress | Where-Object { $_.InterfaceAlias -eq $activeAdapter.Name -and $_.AddressFamily -eq 'IPv4' }).IPAddress
                return $ipAddress
            }

            $disk = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { 
            Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
            }

            # Get the default printer
            $defaultPrinter = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { 
            Get-WmiObject -Query "SELECT * FROM Win32_Printer WHERE Default = TRUE"
            }

            #Get Interactive Display Timeout
            $inactivityTimeout = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {  
            Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "InactivityTimeoutSecs"
            }

            $fireWallPrivate = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                    Get-NetFirewallProfile -Name Private
                    }

            $fireWallPublic = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                    Get-NetFirewallProfile -Name Public
                    }

            $fireWallDomain = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                    Get-NetFirewallProfile -Name Domain
                    }

            #Battery Health Info
            $battery_Health = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
            $DesignedCapacity = (Get-WmiObject -Class "BatteryStaticData" -Namespace "ROOT\WMI").DesignedCapacity
            $FullChargedCapacity = (Get-WmiObject -Class "BatteryFullChargedCapacity" -Namespace "ROOT\WMI").FullChargedCapacity
            $BatteryHealth = 100*$FullChargedCapacity/$DesignedCapacity
            $batteryHealthString = $BatteryHealth.ToString() + "%"
            return $batteryHealthString
            }

            # (Function to map numeric values to readable strings)
            function Convert-FirewallAction {
                param ($action)
                Write-Output $action # Debugging line

                <#if ($action -is [string]) {
                    return $actio
                }
                switch ($action) {
                    0 { return 'Block' }
                    1 { return 'Allow' }
                    3 { return 'NotConfigured' }
                    4 { return 'Block' }
                    default { return 'Unknown' }
                }#>

    }

            # (Create a custom object to store the collected data)
            $result = [PSCustomObject]@{
            Client_Trial_System_Report = $null
            ComputerName = $computerName
            IPAddress    = $IP_Address
            OSName       = $os.Caption
            OSVersion    = $os.Version
            Model        = $cs.Model
            Drive_Capacity_GB  = [math]::Round($disk.Size / 1GB, 2)
            FreeSpace_Capacity_GB    =  [math]::Round($disk.FreeSpace / 1GB, 2)
            DefaultPrinter = $defaultPrinter.Name
            MachineInactivityLimit = $inactivityTimeout
            Battery_Health = $battery_Health
            #FirewallMap  = $firewallMap
            Inbound_FireWall_Private = $fireWallPrivate | ForEach-Object { $_.Name + " State" + ": " + (Convert-FirewallAction $_.DefaultInboundAction) }
            Inbound_FireWall_Public  = $fireWallPublic | ForEach-Object { $_.Name + " State" + ": " + (Convert-FirewallAction $_.DefaultInboundAction) }
            Inbound_FireWall_Domain  = $fireWallDomain | ForEach-Object { $_.Name + " State" + ": " + (Convert-FirewallAction $_.DefaultInboundAction) }
            <#Inbound_FireWall_Private = $fireWallPrivate.DefaultInboundAction
            Inbound_FireWall_Public = $fireWallPublic.DefaultInboundAction
            Inbound_FireWall_Domain = $fireWallDomain.DefaultInboundAction
            FireWall = $fireWall#>
            #FirewallProfileStates = $firewallProfiles | ForEach-Object { $_.Name + ": " + $_.Enabled }
            #FirewallProfileStates = $firewallProfiles
        }

            #Add the result to the results array
            $results += $result

        } catch {
            Write-Host "An error occurred while processing $ip" -ForegroundColor Red
        }
    } else {
        Write-Host "$ip is unavailable" -ForegroundColor Red
    }
}
# Open dialog box prompt to select folder
    Add-Type -AssemblyName System.Windows.Forms #opens folder dialog box
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowserDialog.Description = "Select a folder to save report"

if ($folderBrowserDialog.ShowDialog() -eq 'OK') {
    #Save file in user selected dir
    $folderPath = $folderBrowserDialog.SelectedPath
    $results | Export-Csv -Path "$folderPath\MOBComputerInfo.csv" -NoTypeInformation
    Add-Content -Value " " -LiteralPath "$folderPath\MOBComputerInfo.csv"
    Add-Content -Value "FW: 4=Block | 3=Not Configured | 2=Allow | 0=Disabled" -LiteralPath "$folderPath\MOBComputerInfo.csv"
    Add-Content -Value "Report Developed by Andrew Messer" -LiteralPath "$folderPath\MOBComputerInfo.csv"
    Write-Host "Report generated successfully at $folderPath\MOBComputerInfo.csv. Opening file..." -ForegroundColor Green
    Start-Sleep 2
    Start-Process -FilePath "$folderPath\MOBComputerInfo.csv"
}
}

# MAR BATCH REPORT
elseif ($whichBatch -eq 2) {

    Write-Host "Collecting Report Data from:`n`n"
    Start-Sleep 1

    $timeout = 100 # Timeout in milliseconds

Write-Host "Querying hosts. This may take a while...`n" -ForegroundColor Magenta
Start-Sleep 1
$marClients | ForEach-Object {
    $ip = $_
    $ping = New-Object System.Net.NetworkInformation.Ping
    $reply = $ping.Send($ip, $timeout)
    if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
        try {
            Write-Host "$ip is available for data collection" -ForegroundColor Green

            # Collect information from the available computer
            $computerName = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
            $env:COMPUTERNAME
            } -ErrorAction SilentlyContinue

            $os = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { 
            Get-WmiObject -Class Win32_OperatingSystem
            }

            # Get the computer system information
            $cs = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { 
            Get-WmiObject -Class Win32_ComputerSystem
            }

            $IP_Address = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { 
                $activeAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
                $ipAddress = (Get-NetIPAddress | Where-Object { $_.InterfaceAlias -eq $activeAdapter.Name -and $_.AddressFamily -eq 'IPv4' }).IPAddress
                return $ipAddress
            }

            $disk = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { 
            Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
            }

            # Get the default printer
            $defaultPrinter = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { 
            Get-WmiObject -Query "SELECT * FROM Win32_Printer WHERE Default = TRUE"
            }

            #Get Interactive Display Timeout
            $inactivityTimeout = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {  
            Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "InactivityTimeoutSecs"
            }

            $fireWallPrivate = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                    Get-NetFirewallProfile -Name Private
                    }

            $fireWallPublic = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                    Get-NetFirewallProfile -Name Public
                    }

            $fireWallDomain = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                    Get-NetFirewallProfile -Name Domain
                    }

            #Battery Health Info
            $battery_Health = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
            $DesignedCapacity = (Get-WmiObject -Class "BatteryStaticData" -Namespace "ROOT\WMI").DesignedCapacity
            $FullChargedCapacity = (Get-WmiObject -Class "BatteryFullChargedCapacity" -Namespace "ROOT\WMI").FullChargedCapacity
            $BatteryHealth = 100*$FullChargedCapacity/$DesignedCapacity
            $batteryHealthString = $BatteryHealth.ToString() + "%"
            return $batteryHealthString
            }

            # (Function to map numeric values to readable strings)
            function Convert-FirewallAction {
                param ($action)
                Write-Output $action # Debugging line

                <#if ($action -is [string]) {
                    return $actio
                }
                switch ($action) {
                    0 { return 'Block' }
                    1 { return 'Allow' }
                    3 { return 'NotConfigured' }
                    4 { return 'Block' }
                    default { return 'Unknown' }
                }#>

    }

            # (Create a custom object to store the collected data)
            $result = [PSCustomObject]@{
            Client_Trial_System_Report = $null
            ComputerName = $computerName
            IPAddress    = $IP_Address
            OSName       = $os.Caption
            OSVersion    = $os.Version
            Model        = $cs.Model
            Drive_Capacity_GB  = [math]::Round($disk.Size / 1GB, 2)
            FreeSpace_Capacity_GB    =  [math]::Round($disk.FreeSpace / 1GB, 2)
            DefaultPrinter = $defaultPrinter.Name
            MachineInactivityLimit = $inactivityTimeout
            Battery_Health = $battery_Health
            #FirewallMap  = $firewallMap
            Inbound_FireWall_Private = $fireWallPrivate | ForEach-Object { $_.Name + " State" + ": " + (Convert-FirewallAction $_.DefaultInboundAction) }
            Inbound_FireWall_Public  = $fireWallPublic | ForEach-Object { $_.Name + " State" + ": " + (Convert-FirewallAction $_.DefaultInboundAction) }
            Inbound_FireWall_Domain  = $fireWallDomain | ForEach-Object { $_.Name + " State" + ": " + (Convert-FirewallAction $_.DefaultInboundAction) }
            <#Inbound_FireWall_Private = $fireWallPrivate.DefaultInboundAction
            Inbound_FireWall_Public = $fireWallPublic.DefaultInboundAction
            Inbound_FireWall_Domain = $fireWallDomain.DefaultInboundAction
            FireWall = $fireWall#>
            #FirewallProfileStates = $firewallProfiles | ForEach-Object { $_.Name + ": " + $_.Enabled }
            #FirewallProfileStates = $firewallProfiles
        }

            #Add the result to the results array
            $results += $result

        } catch {
            Write-Host "An error occurred while processing $ip" -ForegroundColor Red
        }
    } else {
        Write-Host "$ip is unavailable" -ForegroundColor Red
    }
}
# Open dialog box prompt to select folder
    Add-Type -AssemblyName System.Windows.Forms #opens folder dialog box
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowserDialog.Description = "Select a folder to save report"

if ($folderBrowserDialog.ShowDialog() -eq 'OK') {
    #Save file in user selected dir
    $folderPath = $folderBrowserDialog.SelectedPath
    $results | Export-Csv -Path "$folderPath\MARComputerInfo.csv" -NoTypeInformation
    Add-Content -Value " " -LiteralPath "$folderPath\MARComputerInfo.csv"
    Add-Content -Value "FW: 4=Block | 3=Not Configured | 2=Allow | 0=Disabled" -LiteralPath "$folderPath\MARComputerInfo.csv"
    Add-Content -Value "Report Developed by Andrew Messer" -LiteralPath "$folderPath\MARComputerInfo.csv"
    Write-Host "Report generated successfully at $folderPath\MARComputerInfo.csv. Opening file..." -ForegroundColor Green
    Start-Sleep 2
    Start-Process -FilePath "$folderPath\MARComputerInfo.csv"
}
}

#  BATCH REPORT
elseif ($whichBatch -eq 3) {

    Write-Host "Collecting Report Data from:`n`n"
    Start-Sleep 1

    $timeout = 100 # Timeout in milliseconds

Write-Host "Querying hosts. This may take a while...`n" -ForegroundColor Magenta
Start-Sleep 1
$cvnClients | ForEach-Object {
    $ip = $_
    $ping = New-Object System.Net.NetworkInformation.Ping
    $reply = $ping.Send($ip, $timeout)
    if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
        try {
            Write-Host "$ip is available for data collection" -ForegroundColor Green

            # Collect information from the available computer
            $computerName = Invoke-Command -ComputerName $ip -Credential $cvnCredential -ScriptBlock {
            $env:COMPUTERNAME
            } -ErrorAction SilentlyContinue

            $os = Invoke-Command -ComputerName $ip -Credential $cvnCredential -ScriptBlock { 
            Get-WmiObject -Class Win32_OperatingSystem
            }

            # Get the computer system information
            $cs = Invoke-Command -ComputerName $ip -Credential $cvnCredential -ScriptBlock { 
            Get-WmiObject -Class Win32_ComputerSystem
            }

            $IP_Address = Invoke-Command -ComputerName $ip -Credential $cvnCredential -ScriptBlock { 
                $activeAdapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object -First 1
                $ipAddress = (Get-NetIPAddress | Where-Object { $_.InterfaceAlias -eq $activeAdapter.Name -and $_.AddressFamily -eq 'IPv4' }).IPAddress
                return $ipAddress
            }

            $disk = Invoke-Command -ComputerName $ip -Credential $cvnCredential -ScriptBlock { 
            Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
            }

            # Get the default printer
            $defaultPrinter = Invoke-Command -ComputerName $ip -Credential $cvnCredential -ScriptBlock { 
            Get-WmiObject -Query "SELECT * FROM Win32_Printer WHERE Default = TRUE"
            }

            #Get Interactive Display Timeout
            $inactivityTimeout = Invoke-Command -ComputerName $ip -Credential $cvnCredential -ScriptBlock {  
            Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "InactivityTimeoutSecs"
            }

            $zDrive = Invoke-Command -ComputerName $ip -Credential $cvnCredential -ScriptBlock {
            if (Test-Path "\\192.168.79.251\ETCDATA") {
                "Connected to Drive Z"
            } else {
                "Not connected to Drive Z"
            }
            }

            $yDrive = Invoke-Command -ComputerName $ip -Credential $cvnCredential -ScriptBlock {
            if (Test-Path "\\192.168.79.252\SHIPSPECS") {
                "Connected to Drive Y"
            } else {
                "Not connected to Drive Y"
            }
            }

            $fireWallPrivate = Invoke-Command -ComputerName $ip -Credential $cvnCredential -ScriptBlock {
                    Get-NetFirewallProfile -Name Private
                    }

            $fireWallPublic = Invoke-Command -ComputerName $ip -Credential $cvnCredential -ScriptBlock {
                    Get-NetFirewallProfile -Name Public
                    }

            $fireWallDomain = Invoke-Command -ComputerName $ip -Credential $cvnCredential -ScriptBlock {
                    Get-NetFirewallProfile -Name Domain
                    }

            #Battery Health Info
            $battery_Health = Invoke-Command -ComputerName $ip -Credential $cvnCredential -ScriptBlock {
            $DesignedCapacity = (Get-WmiObject -Class "BatteryStaticData" -Namespace "ROOT\WMI").DesignedCapacity
            $FullChargedCapacity = (Get-WmiObject -Class "BatteryFullChargedCapacity" -Namespace "ROOT\WMI").FullChargedCapacity
            $BatteryHealth = 100*$FullChargedCapacity/$DesignedCapacity
            $batteryHealthString = $BatteryHealth.ToString() + "%"
            return $batteryHealthString
            }

            # (Function to map numeric values to readable strings)
            function Convert-FirewallAction {
                param ($action)
                Write-Output $action # Debugging line

                <#if ($action -is [string]) {
                    return $actio
                }
                switch ($action) {
                    0 { return 'Block' }
                    1 { return 'Allow' }
                    3 { return 'NotConfigured' }
                    4 { return 'Block' }
                    default { return 'Unknown' }
                }#>

    }

            # (Create a custom object to store the collected data)
            $result = [PSCustomObject]@{
            Client_Trial_System_Report = $null
            ComputerName = $computerName
            IPAddress    = $IP_Address
            ZDrive       = $zDrive
            YDrive       = $yDrive
            OSName       = $os.Caption
            OSVersion    = $os.Version
            Model        = $cs.Model
            Drive_Capacity_GB  = [math]::Round($disk.Size / 1GB, 2)
            FreeSpace_Capacity_GB    =  [math]::Round($disk.FreeSpace / 1GB, 2)
            DefaultPrinter = $defaultPrinter.Name
            MachineInactivityLimit = $inactivityTimeout
            Battery_Health = $battery_Health
            #FirewallMap  = $firewallMap
            Inbound_FireWall_Private = $fireWallPrivate | ForEach-Object { $_.Name + " State" + ": " + (Convert-FirewallAction $_.DefaultInboundAction) }
            Inbound_FireWall_Public  = $fireWallPublic | ForEach-Object { $_.Name + " State" + ": " + (Convert-FirewallAction $_.DefaultInboundAction) }
            Inbound_FireWall_Domain  = $fireWallDomain | ForEach-Object { $_.Name + " State" + ": " + (Convert-FirewallAction $_.DefaultInboundAction) }
            <#Inbound_FireWall_Private = $fireWallPrivate.DefaultInboundAction
            Inbound_FireWall_Public = $fireWallPublic.DefaultInboundAction
            Inbound_FireWall_Domain = $fireWallDomain.DefaultInboundAction
            FireWall = $fireWall#>
            #FirewallProfileStates = $firewallProfiles | ForEach-Object { $_.Name + ": " + $_.Enabled }
            #FirewallProfileStates = $firewallProfiles
        }

            #Add the result to the results array
            $results += $result

        } catch {
            Write-Host "An error occurred while processing $ip" -ForegroundColor Red
        }
    } else {
        Write-Host "$ip is unavailable" -ForegroundColor Red
    }
}
# Open dialog box prompt to select folder
    Add-Type -AssemblyName System.Windows.Forms #opens folder dialog box
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowserDialog.Description = "Select a folder to save report"

if ($folderBrowserDialog.ShowDialog() -eq 'OK') {
    #Save file in user selected dir
    $folderPath = $folderBrowserDialog.SelectedPath
    $results | Export-Csv -Path "$folderPath\CVNComputerInfo.csv" -NoTypeInformation
    Add-Content -Value " " -LiteralPath "$folderPath\CVNComputerInfo.csv"
    Add-Content -Value "FW: 4=Block | 3=Not Configured | 2=Allow | 0=Disabled" -LiteralPath "$folderPath\CVNComputerInfo.csv"
    Add-Content -Value "Report Developed by Andrew Messer" -LiteralPath "$folderPath\CVNComputerInfo.csv"
    Write-Host "Report generated successfully at $folderPath\CVNComputerInfo.csv. Opening file..." -ForegroundColor Green
    Start-Sleep 2
    Start-Process -FilePath "$folderPath\CVNComputerInfo.csv"
}
}

Start-Sleep 5