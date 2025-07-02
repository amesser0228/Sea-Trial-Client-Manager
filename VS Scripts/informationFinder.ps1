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
#  Computer Information   #
#         Finder          #
#                         #
# # # # # # # # # # # # # #
`n`n"

Write-Host "
Find information about a computer including:
 Mac Address
 S/N (Service tag)
 Firmware


 `n`n" -ForegroundColor Yellow

$mobClients = @(
#MOB
"192.168.56.201",
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
"192.168.79.147",
"192.168.79.148")

$securePassword = ConvertTo-SecureString "L-3Communicati0ns!" -AsPlainText -Force
$lcsCredential = New-Object System.Management.Automation.PSCredential ("LCS", $securePassword)
$cvnCredential = New-Object System.Management.Automation.PSCredential ("CVN", $securePassword)


#### RUN THE PIPELINE FOR INFRASTRUCTURE
    # A global try/catch doesn't seem to work in this pipeline so the try/catch has been
    # nested within each condition. The code readibility has not been negatively affected.

    # Load Windows Forms assembly
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # Create the form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Select Remote Computers"
    $form.Size = New-Object System.Drawing.Size(350, 500)
    $form.StartPosition = "CenterScreen"

    # Create a FlowLayoutPanel with AutoScroll enabled
    $flowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
    $flowLayoutPanel.AutoScroll = $true
    $flowLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $flowLayoutPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
    $flowLayoutPanel.WrapContents = $false

$whichBatchNumber = Read-Host "`n
Which batch is the client in?

    1 = MOB

    2 = MAR

    3 = CVN

Enter batch number"

#Get batch and credential
if ($whichBatchnumber -eq 1) {
        $batch = $mobClients 
        $credential = $lcsCredential}
    elseif ($whichBatchNumber -eq 2) {
        $batch = $marClients
        $credential = $lcsCredential}
    elseif ($whichBatchNumber -eq 3) {
        $batch = $cvnClients
        $credential = $cvnCredential}


## CONDITIONS TO RUN COMMANDS ##

# 1. Restart client
###################
    foreach ($client in $batch) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        $flowLayoutPanel.Controls.Add($checkbox)
    }

    # Add a button to select all IP addresses
    $selectAllButton = New-Object System.Windows.Forms.Button
    $selectAllButton.Text = "Select All"
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox]) {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to submit the selected IP addresses
    $submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"
    $submitButton.Add_Click({
        Write-Host "Querying host. This may take a while...`n" -ForegroundColor Magenta
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 100 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    try {
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
                    }
                    catch {
                        Write-Host "Cannot deliver command to $ip"
                    }

                    # (Create a custom object to store the collected data)
                    $result = [PSCustomObject]@{
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
                    #Inbound_FireWall_Private = $fireWallPrivate
                    #Inbound_FireWall_Public  = $fireWallPublic
                    #Inbound_FireWall_Domain  = $fireWallDomain
                    <#Inbound_FireWall_Private = $fireWallPrivate.DefaultInboundAction
                    Inbound_FireWall_Public = $fireWallPublic.DefaultInboundAction
                    Inbound_FireWall_Domain = $fireWallDomain.DefaultInboundAction
                    FireWall = $fireWall#>
                    #FirewallProfileStates = $firewallProfiles | ForEach-Object { $_.Name + ": " + $_.Enabled }
                    #FirewallProfileStates = $firewallProfiles
                    }
                }
                else {
                    Write-Host "
                    $ip is unavailable.
                    Here's the information available for batch $whichBatchNumber." -ForegroundColor Red
                    if ($whichBatchNumber -eq 1) {
                        Write-Host "
                        MOB batch:
                            Last reported FW version: 1.28.0
                            Make: Dell
                            Model: Latitude 5510
                            IP Range: 192.168.56.201 - 223
                            Windows Version: 10 Enterprise
                            "
                        }
                    elseif ($whichBatchNumber -eq 2) {
                        Write-Host "
                        MAR batch:
                            Last reported FW version: 1.25.0
                            Make: Dell
                            Model: Latitude 5531
                            IP Range: 192.168.56.101 - 123
                            Windows Version: 10 Enterprise"
                        }
                    elseif ($whichBatchNumber -eq 3) {
                        Write-Host "
                        CVN batch:
                            Last reported FW version
                                5540: 1.17.0
                                5550: 1.10.0
                            Make: Dell
                            Model: (CVN-001-002: Latitude 5540), (CVN-003-048: Latitude 5550)
                            IP Range: 192.168.79.101 - 148
                            Windows Version: 11 Enterprise LTSC"
                    }
                    }
                }
            }
        $form.Close()
    })
    $flowLayoutPanel.Controls.Add($submitButton)

    $form.Controls.Add($flowLayoutPanel)
    $form.Add_Shown({$form.Activate()})
    [void] $form.ShowDialog()

    Read-Host "`nPress any key to exit"
      
        
     
        
        
    
     
                             
                             