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

Write-Host "
RUN A SCRIPT ON ALL REMOTE HOSTS IN THE SELECTED BATCH`n`Some scripts may take a long time running remotely`n`n" -ForegroundColor Yellow


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

$scriptForm = New-Object System.Windows.Forms.Form
$scriptForm.Text = "Select Script Option"
#$scriptForm.Name = "ScriptForm"
$scriptForm.Size = New-Object System.Drawing.Size(400, 500)
$scriptForm.StartPosition = "CenterScreen"

# Create a FlowLayoutPanel with AutoScroll enabled
$flowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$flowLayoutPanel.AutoScroll = $true
$flowLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$flowLayoutPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$flowLayoutPanel.WrapContents = $false

# Create a FlowLayoutPanel with AutoScroll enabled
$scriptFlowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$scriptFlowLayoutPanel.AutoScroll = $true
$scriptFlowLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$scriptFlowLayoutPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$scriptFlowLayoutPanel.WrapContents = $false

# Add submit button for script selection form
$scriptOptionSubmitButton = New-Object System.Windows.Forms.Button
$scriptOptionSubmitButton.Text = "Submit"
$scriptOptionSubmitButton.Width = 80
$scriptOptionSubmitButton.Margin = New-Object System.Windows.Forms.Padding(3,30,10,0)

$scriptCheckbox1 = New-Object System.Windows.Forms.CheckBox
$scriptCheckbox1.Text = "Baseline image configuration (restarts machine)"
$scriptCheckbox1.AutoSize = $true
$scriptCheckbox1.Margin = New-Object System.Windows.Forms.Padding(3,10,10,15)

$scriptCheckbox2 = New-Object System.Windows.Forms.CheckBox
$scriptCheckbox2.Text = "Disk encryption (restarts machine and requires connection to Server3)"
$scriptCheckbox2.AutoSize = $true
$scriptCheckbox2.Margin = New-Object System.Windows.Forms.Padding(3,10,10,15)

$scriptCheckbox3 = New-Object System.Windows.Forms.CheckBox
$scriptCheckbox3.Text = "Eval-STIG setup and scan (requires disk encryption)"
$scriptCheckbox3.AutoSize = $true
$scriptCheckbox3.Margin = New-Object System.Windows.Forms.Padding(3,10,10,15)

$scriptCheckbox4 = New-Object System.Windows.Forms.CheckBox
$scriptCheckbox4.Text = "Disable WiFi, BT, enable SecureBoot (restarts machine) - (W11 Only)"
$scriptCheckbox4.AutoSize = $true
$scriptCheckbox4.Margin = New-Object System.Windows.Forms.Padding(3,10,10,15)

$scriptCheckbox5 = New-Object System.Windows.Forms.CheckBox
$scriptCheckbox5.Text = "Reload scripts (A,B,C,D)"
$scriptCheckbox5.AutoSize = $true
$scriptCheckbox5.Margin = New-Object System.Windows.Forms.Padding(3,10,10,15)

$scriptCheckbox6 = New-Object System.Windows.Forms.CheckBox
$scriptCheckbox6.Text = "Network time sync with client 001. Don't select 101 in the list"
$scriptCheckbox6.AutoSize = $true
$scriptCheckbox6.Margin = New-Object System.Windows.Forms.Padding(3,10,10,15)

$scriptCheckbox7 = New-Object System.Windows.Forms.CheckBox
$scriptCheckbox7.Text = "Update defender antivirus definitions"
$scriptCheckbox7.AutoSize = $true
$scriptCheckbox7.Margin = New-Object System.Windows.Forms.Padding(3,10,10,15)

$scriptCheckbox8 = New-Object System.Windows.Forms.CheckBox
$scriptCheckbox8.Text = "Set production policies"
$scriptCheckbox8.AutoSize = $true
$scriptCheckbox8.Margin = New-Object System.Windows.Forms.Padding(3,10,10,15)

$scriptCheckbox9 = New-Object System.Windows.Forms.CheckBox
$scriptCheckbox9.Text = "Run custom script"
$scriptCheckbox9.AutoSize = $true
$scriptCheckbox9.Margin = New-Object System.Windows.Forms.Padding(3,10,10,15)

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


$terminateScript = $false

#Get script selection
$scriptOptionSubmitButton.Add_Click({
$scriptForm.Close()
if ($scriptCheckbox1.Checked) {
    if ($whichBatch -eq 1 -or $whichBatch -eq 2) {
    $scriptPath = "C:\Admin Only\Powershell\Library\PMS501_BaselineImage_Configuration.ps1"
    }
    if ($whichBatch -eq 3) {
    $scriptPath = "C:\Admin Only\Powershell\Library\Script A\CVN_BaselineImage_Configuration.ps1"
    }
}
elseif ($scriptCheckbox2.Checked) {
    if ($whichBatch -eq 1 -or $whichBatch -eq 2) {
    $scriptPath = "C:\Admin Only\Powershell\Library\PMS501_Disk_Encryption.ps1"
    }
    if ($whichBatch -eq 3) {
    $scriptPath = "C:\Admin Only\Powershell\Library\Script C\CVN_Disk_Encryption.ps1"
    }
}
elseif ($scriptCheckbox3.Checked) {
    if ($whichBatch -eq 1 -or $whichBatch -eq 2) {
    $scriptPath = "C:\Admin Only\Powershell\Library\PMS501_E-S_Setup_Configuration.ps1"
    }
    if ($whichBatch -eq 3) {
    $scriptPath = "C:\Admin Only\Powershell\Library\Script D\CVN_E-S_Setup_Configuration.ps1"
    }
}
elseif ($scriptCheckbox4.Checked) {
    if ($whichBatch -eq 1 -or $whichBatch -eq 2) {
    [System.Windows.Forms.MessageBox]::Show("This option is not available for Windows 10", "STCM Error Handler")
    $scriptForm.Close()
    $terminateScript = $true
    }
    if ($whichBatch -eq 3) {
    $scriptPath = "C:\Admin Only\Powershell\Library\Script B\dellBIOSMod_BT_WLAN_SB.ps1"
    }
}
elseif ($scriptCheckbox5.Checked) {
    if ($whichBatch -eq 1 -or $whichBatch -eq 2) {
    $scriptPath = "C:\Admin Only\Batch\move_ScriptsABC_Back.bat"
    }
    if ($whichBatch -eq 3) {
    $scriptPath = "C:\Admin Only\Powershell\Library\move_ScriptsABCD_back.bat"
    }
}
elseif ($scriptCheckbox6.Checked) {
    
    $scriptPath = "C:\Admin Only\Batch\NTPtime.bat"
}
elseif ($scriptCheckbox7.Checked) {
    if ($whichBatch -eq 1 -or $whichBatch -eq 2) {}
    if ($whichBatch -eq 3) {
    $scriptPath = "C:\Admin Only\Powershell\Library\runWDAVUpdate.ps1"
    }
}
elseif ($scriptCheckbox8.Checked) {
    if ($whichBatch -eq 1 -or $whichBatch -eq 2) {}
    if ($whichBatch -eq 3) {
    $scriptPath = "C:\Admin Only\Powershell\Library\setProdPolicies.ps1"
    }
}
elseif ($scriptCheckbox9.Checked) {
    if ($whichBatch -eq 1 -or $whichBatch -eq 2) {}
    if ($whichBatch -eq 3) {
    $scriptPath = Read-Host "Enter script path:"
    }
}

if ($terminateScript) {
       return  # Exit the script gracefully
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
    Write-Host "Running $scriptPath on..."
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
                Write-Host $env:COMPUTERNAME -ForegroundColor Green
                }
                Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                param($scriptPath) & "$scriptPath" | Out-String
                } -ArgumentList "$scriptPath"

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
})
$scriptFlowLayoutPanel.Controls.Add($scriptCheckbox1)
$scriptFlowLayoutPanel.Controls.Add($scriptCheckbox2)
$scriptFlowLayoutPanel.Controls.Add($scriptCheckbox3)
$scriptFlowLayoutPanel.Controls.Add($scriptCheckbox4)
#$scriptFlowLayoutPanel.Controls.Add($scriptCheckbox5)
$scriptFlowLayoutPanel.Controls.Add($scriptCheckbox6)
$scriptFlowLayoutPanel.Controls.Add($scriptCheckbox7)
$scriptFlowLayoutPanel.Controls.Add($scriptCheckbox8)
$scriptFlowLayoutPanel.Controls.Add($scriptCheckbox9)
$scriptFlowLayoutPanel.Controls.Add($scriptOptionSubmitButton)
$scriptForm.controls.add($scriptFlowLayoutPanel)
[void] $scriptForm.ShowDialog()

Read-Host "Press any key to exit"
           


