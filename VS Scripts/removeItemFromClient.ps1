# Checks if the script is running as an administrator #
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
    }


# Provide credentials for hosts
$securePassword = ConvertTo-SecureString "L-3Communicati0ns!" -AsPlainText -Force
$lcsCredential = New-Object System.Management.Automation.PSCredential ("LCS", $securePassword)
$cvnCredential = New-Object System.Management.Automation.PSCredential ("CVN", $securePassword)



# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select Computers to Power Off"
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
    $fullDestinationPath = Read-Host "`n`n`n`nEnter the location to remove the item from the selcted clients"
    Write-Host "Removing file from..."
    foreach ($control in $flowLayoutPanel.Controls) {
        if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
        $ip = $control.Text
        $timeout = 100 # Timeout in milliseconds
        $ping = New-Object System.Net.NetworkInformation.Ping
        $reply = $ping.Send($ip, $timeout)
        if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
            try {
            Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
            param($fullDestinationPath)
            Remove-Item -Path "$fullDestinationPath" -Force
            Write-Host $env:COMPUTERNAME -ForegroundColor Green
            } -ArgumentList $fullDestinationPath
            }
            catch {
            Write-Warning "File could not be removed destination because there was an issue connecting to $ip or the supplied parameters were incorrect."
            Start-Sleep 5
            }
                        }
            else {
                Write-Host "$ip is unavailable" -ForegroundColor Red
            }
        }
    }
    $form.Close()
})
$flowLayoutPanel.Controls.Add($submitButton)

    $form.Controls.Add($flowLayoutPanel)
    $form.Add_Shown({$form.Activate()})
    [void] $form.ShowDialog()

Read-Host "Press any key to exit"
    
