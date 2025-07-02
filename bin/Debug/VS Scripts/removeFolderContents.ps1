<#DEVELOPED BY ANDREW MESSER

SYNOPSIS:

    1. QUERIES HOSTS IN CLIENT ARRAY
    2. RUNS COMMAND WITH REMOTE CREDENTIALS TO EACH HOST
    #>

# Checks if the script is running as an administrator #
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}


Write-Host "Clear Folder Conntents `n`n" -ForegroundColor Yellow

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

$securePassword = ConvertTo-SecureString "L-3Communicati0ns!" -AsPlainText -Force
$lcsCredential = New-Object System.Management.Automation.PSCredential ("LCS", $securePassword)
$cvnCredential = New-Object System.Management.Automation.PSCredential ("CVN", $securePassword)

#Infrastructure and batch conditions are not indented to retain the appearance of the CLI Interface


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

$data = @(
    @{ Name = "Mobile"; Value = "1 (56.200)" },
    @{ Name = "Marinette"; Value = "2 (56.100)" },
    @{ Name = "CVN"; Value = "3 (79.100)" }
)

# Create a border and format the table
$border = "┌────────────┬────────────┐"
$borderBottom = "└────────────┴────────────┘"

Write-Output $border
Write-Output "│ Batch      │ Number     │"
Write-Output $border.Replace("┌", "├").Replace("┐", "┤")

foreach ($item in $data) {
    Write-Output ("│ {0,-9}  │ {1,-10} │" -f $item.Name, $item.Value)  # Adjusted spacing for Value
}

Write-Output $borderBottom

$whichBatchNumber = Read-Host "Select batch number"

if ($whichBatch -le 3) {

#Get batch and credential
if ($whichBatchnumber -eq 1) {
        $batch = $mobClients 
        $credential = $lcsCredential
        $autoLogonUser = 'LCS'}
    elseif ($whichBatchNumber -eq 2) {
        $batch = $marClients
        $credential = $lcsCredential
        $autoLogonUser = 'LCS'}
    elseif ($whichBatchNumber -eq 3) {
        $batch = $cvnClients
        $credential = $cvnCredential
        $autoLogonUser = 'CVN'}
    



## CONDITIONS TO RUN COMMANDS ##

# Clear Folder Contents
##########################
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
        $userPath = Read-Host "
        Select a folder option:
        
            1 = MOB Firmware Folder
            2 = MAR Firmware Folder
            3 = CVN Firmware Folder
            4 = Enter a custom path
            
        Enter option number"



    $selectedFolderPath = ""

    if ($userPath -eq 1) {
        $selectedFolderPath = "C:\Admin Only\Firmware\5510"
    }
    elseif ($userPath -eq 2) {
        $selectedFolderPath = "C:\Admin Only\Firmware\5531"
    }
    elseif ($userPath -eq 3) {
        $selectedFolderPath = "C:\Admin Only\Firmware\5550"
    }
    elseif ($userPath -eq 4) {
        $selectedFolderPath = Read-Host "Enter custom path"
    }


        Write-Host "Clearing folder $filePath..."
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 100 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                        param($selectedFolderPath)
                            Write-Host $env:COMPUTERNAME -ForegroundColor Green
                            Get-ChildItem -Path $selectedFolderPath -Recurse | Remove-Item -Recurse -Force
                            $numRan += 1
                        } -ArgumentList $selectedFolderPath
                    $numRan += 1
                    }
                    catch {
                        Write-Host "Cannot deliver command to $ip"
                    }
                }
                else {
                    $numFailed += 1
                    Write-Host "$ip is unavailable" -ForegroundColor Red
                }
            }
        }
        Write-Host "Number of clients that responded: " -NoNewline 
        Write-Host "$numReplied" -ForegroundColor Green
        Write-Host "Number of clients that ran the script: " -NoNewline 
        Write-Host "$numRan" -ForegroundColor Green
        Write-Host "Number of clients that failed to respond: " -NoNewline
        Write-Host "$numFailed" -ForegroundColor Red
        $form.Close()
    })
    $flowLayoutPanel.Controls.Add($submitButton)

    $form.Controls.Add($flowLayoutPanel)
    $form.Add_Shown({$form.Activate()})
    [void] $form.ShowDialog()
    Read-Host "Press any key to exit"
}
else {
Write-Host "A valid selection was not made"
}