<#DEVELOPED BY ANDREW MESSER

SYNOPSIS:

    1. QUERIES HOSTS IN CLIENT ARRAY
    2. RUNS HOST-ACCESIBLE SCRIPT WITH REMOTE CREDENTIALS TO EACH HOST
    #>



# Checks if the script is running as an administrator #
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "
# # # # # # # # # # # # # #
#                         #
#   Run a Remote Script   #
#                         #
# # # # # # # # # # # # # #
`n`n"

Write-Host "RUN A SCRIPT ON ALL REMOTE HOSTS IN THE SELECTED BATCH`n`n" -ForegroundColor Yellow


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


$scriptNumber = Read-Host "Select script:

    1 = baseline image configuration (restarts machine)

    2 = disk encryption (restarts machine and requires connection to Server3)

    3 = evaluate-STIG setup and scan (requires disk encryption)

    4 = disable WiFi, BT, enable SecureBoot (restarts machine)

    5 = reload scripts (A,B,C,D)

    6 = networtk time sync with client 001. Don't select 101 in the list

    7 = update defender antivirus definitions

    8 = set production policies

    9 = Run custom script

Enter script number"

#Get script selection
if ($scriptNumber -eq 1) {
    $scriptPath = "C:\Admin Only\Powershell\Library\Script A\CVN_BaselineImage_Configuration.ps1"
}
elseif ($scriptNumber -eq 2) {
    $scriptPath = "C:\Admin Only\Powershell\Library\Script C\CVN_Disk_Encryption.ps1"
}
elseif ($scriptNumber -eq 3) {
    $scriptPath = "C:\Admin Only\Powershell\Library\Script D\CVN_E-S_Setup_Configuration.ps1"
}
elseif ($scriptNumber -eq 4) {
    $scriptPath = "C:\Admin Only\Powershell\Library\Script B\dellBIOSMod_BT_WLAN_SB.ps1"
}
elseif ($scriptNumber -eq 5) {
    $scriptPath = "C:\Admin Only\Powershell\Library\move_ScriptsABCD_back.bat"
}
elseif ($scriptNumber -eq 6) {
    $scriptPath = "C:\Admin Only\Batch\NTPtime.bat"
}
elseif ($scriptNumber -eq 7) {
    $scriptPath = "C:\Admin Only\Powershell\Library\runWDAVUpdate.ps1"
}
elseif ($scriptNumber -eq 8) {
    $scriptPath = "C:\Admin Only\Powershell\Library\setProdPolicies.ps1"
}
elseif ($scriptNumber -eq 9) {
    $scriptPath = Read-Host "Enter script path:"
}

Write-Host "`nQuerying hosts. This may take a while...`n" -ForegroundColor Magenta

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
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
            $ip = $control.Text
            $timeout = 100 # Timeout in milliseconds
            $ping = New-Object System.Net.NetworkInformation.Ping
            $reply = $ping.Send($ip, $timeout)
            if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                $numReplied += 1
                try {
            Write-Host "Running $scriptPath on $ip..."
            Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
            param($scriptPath) & $scriptPath | Out-String} -ArgumentList "$scriptPath"
            Write-Host "`nSuccess`n" -ForegroundColor Green
            $numRan += 1
            }
            catch {
                    Write-Host "Cannot deliver script path to $ip"
                }
            }
            else {
                $numFailed += 1
                Write-Host "$ip is unavailable" -ForegroundColor Red
            }
        }
    }
    Write-Host "All remote scripts have completed on selected remote computers`n"
    Write-Host "Number of clients that responded: " -NoNewline 
    Write-Host "$numReplied" -ForegroundColor Green
    Write-Host "Number of clients that ran the script: " -NoNewline 
    Write-Host "$numRan" -ForegroundColor Green
    Write-Host "Number of clients that failed: " -NoNewline
    Write-Host "$numFailed" -ForegroundColor Red
    $form.Close()
})
$flowLayoutPanel.Controls.Add($submitButton)

    $form.Controls.Add($flowLayoutPanel)
    $form.Add_Shown({$form.Activate()})
    [void] $form.ShowDialog()

Read-Host "Press any key to exit"
           


