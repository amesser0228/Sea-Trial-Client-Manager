<#DEVELOPED BY ANDREW MESSER

SYNOPSIS:

    1. Checks Eval-STIG policies changed by trial team
    2. Outputs results to Window
    3. Waits for user to continue to move script D back to selected clients
    4. Restarts selected clients
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
#    Nessus System Check  #
#        and Scan         #
#                         #
# # # # # # # # # # # # # #
`n`n"

Write-Host "Check AutoAdminLogon policies before Nessus scan" -ForegroundColor Yellow
Write-Host "`n`n" 

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

# Load Batch Selection Table
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

$whichBatchNumber = Read-Host "Select batch number"

if ($whichBatch -le 3) {

#Get batch and credential
if ($whichBatchnumber -eq "1") {
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


# Load host selection GUI and run remote tasks
foreach ($client in $batch) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $client
    $flowLayoutPanel.Controls.Add($checkbox)
}

# Add a button to select all IP addresses
$selectAllButton = New-Object System.Windows.Forms.Button
$selectAllButton.Text = "Select All"
$selectAllButton.Add_Click({
    Write-Host "Checking the following settings on:"
    foreach ($control in $flowLayoutPanel.Controls) {
        if ($control -is [System.Windows.Forms.CheckBox]) {
            $control.Checked = $true
        }
    }
})
$flowLayoutPanel.Controls.Add($selectAllButton)

$autoAdminLogonArray = @()

# Add a button to submit the selected IP addresses
$submitButton = New-Object System.Windows.Forms.Button
$submitButton.Text = "Submit"
Write-Host "Checking System Settings Before Eval-STIG Scan..."
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
                    $result = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                    $autoAdminLogon = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                    if (Get-ItemProperty -Path $autoAdminLogon -Name "AutoAdminLogon" -ErrorAction SilentlyContinue) {
                        $autoAdminLogonValue = Get-ItemProperty -Path $autoAdminLogon -Name "AutoAdminLogon"
                    }
                    else {
                        $autoAdminLogonValue = $null
                    }
                    $defaultPasswordParam = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -ErrorAction SilentlyContinue
                    $defaultUserNameParam = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -ErrorAction SilentlyContinue

                        Write-Host "
-------------------------------------------------------------------------------------------------------------------"
Write-Host "                                                    $env:computername" -ForegroundColor Yellow
write-host "-------------------------------------------------------------------------------------------------------------------
"
                        #Machine Inactivity Limit = 0 
                        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "InactivityTimeoutSecs" -Value 0 -Force
                        Write-Host "Disabling Inactivity Monitor`n"

                        if ($autoAdminLogonValue -ne $null) {
                            Write-Warning "`nAuto Admin Logon is enabled"
                            return $env:computername
                        } else {
                            Write-Host "`nAuto Admin Logon is removed. SAT" -ForegroundColor Green
                            return $null
                        }

                
                }
                $numRan += 1
                }

                catch {
                    Write-Host "Cannot deliver command to $ip"
                }
                if ($result -ne $null) {
                $autoAdminLogonArray += $result + ", "
                    }
                    }
            else {
                $numFailed += 1
                Write-Host "$ip is unavailable" -ForegroundColor Red
            }

            }

            }

    Write-Host "`n`nClients with Auto Admin Logon Enabled: $autoAdminLogonArray"

                            write-host "`n
---------------------------------"
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
}
else {
    write-host "No valid selection made"
    start-sleep 5
}