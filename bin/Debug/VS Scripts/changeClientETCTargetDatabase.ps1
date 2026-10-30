<#
Developed by Andrew Messer
Synospsis:
    1. Stops running tasks
    2. Shuts down all hosts in IP scope.
#>

param(
    [string]$CredentialUsernamePath,
    [string]$CredentialPasswordPath,
    [string]$BeginDeviceIDPath,
    [string]$EndDeviceIDPath,
    [string]$IPPrefixPath
)

$remoteUsername = Get-Content -Path $CredentialUsernamePath
$remotePassword = Get-Content -Path $CredentialPasswordPath
$beginningDeviceID = Get-Content -Path $BeginDeviceIDPath
$endingDeviceID = Get-Content -Path $EndDeviceIDPath
$remoteIPPrefix = Get-Content -Path $IPPrefixPath

Write-Host "Remote Username:" -NoNewline
Write-Host $remoteUsername -ForegroundColor Green
Write-Host Remote IP range: -NoNewline
Write-Host $remoteIPPrefix"."$beginningDeviceID "-" $endingDeviceID -ForegroundColor Green

$remoteUsername = Get-Content -Path $CredentialUsernamePath
$remotePassword = Get-Content -Path $CredentialPasswordPath
$beginningDeviceID = Get-Content -Path $BeginDeviceIDPath
$endingDeviceID = Get-Content -Path $EndDeviceIDPath
$remoteIPPrefix = Get-Content -Path $IPPrefixPath

# Provide credentials for hosts
$remoteSecurePassword = ConvertTo-SecureString $remotePassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($remoteUsername, $remoteSecurePassword)

#RemoteIPs
$remoteIPAddresses = @()
for ($i = [int]$beginningDeviceID; $i -le [int]$endingDeviceID; $i++) {
    $remoteIPAddresses += "$($remoteIPPrefix).$($i)"
}


Write-Host "
# # # # # # # # # # # # # # # # #
#                               #
#  Change ETC Target Database   #
#          On Clients           #
#                               #
# # # # # # # # # # # # # # # # #
`n`n"

Write-Host "Change ETC Target Database on Clients `n`n" -ForegroundColor Yellow

<# Checks if the script is running as an administrator #
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
    }
#>


# Checks if script is running in STA mode. Required for Windows Forms.
if ($Host.Runspace.ApartmentState -ne "STA") {
    throw "This script must be run in STA mode."
}


# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select Computers"
$form.Size = New-Object System.Drawing.Size(350, 500)
$form.StartPosition = "CenterScreen"

# Create a FlowLayoutPanel with AutoScroll enabled
$flowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$flowLayoutPanel.AutoScroll = $true
$flowLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$flowLayoutPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$flowLayoutPanel.WrapContents = $false


#loop Counter for num of reachable clients
$numReplied = 0

#loop Counter for num of clients that ran the script
$numRan = 0

#loop Counter for num of unreachable clients
$numFailed = 0

#Open dialog box prompt to select file
Add-Type -AssemblyName System.Windows.Forms

$runScript = Read-Host "`n`nPress enter to continue or Q to quit"
if($runScript -eq "Q" -or $runScript -eq "q") {
    return
}
elseif($runScript -eq "") {
    Write-Host "`n`nRunning script..." -ForegroundColor Green
}
else {
    Write-Host "Invalid Selection"
    return
}

$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Title = "Select ETC Access Database File"
$openFileDialog.Filter = "Accdb Files (*.accdb)|*.accdb" #for all file types:  "All Files (*.*)|*.*"

if ($openFileDialog.ShowDialog() -eq 'OK') {
    $filePath = $openFileDialog.FileName
    Write-Host "You selected the file: $filePath`n`n" -ForegroundColor Yellow

$sourceFile = $filePath
}


foreach ($client in $remoteIPAddresses) {
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

### ETC DATABASE CLIENT REGISTRY ENTRY PATH ###
$ETC_ClientDBRegPath = "HKCU:\Software\TMAC\ETC"

#ETC Database Reg Entry Header
$ETCPrimaryDatabaseRegEntryHeader = "Provider=Microsoft.ACE.OLEDB.12.0;OLE DB Services=-4;Persist Security Info=False;Mode=Share Deny None;Data Source="

$computerName = $env:COMPUTERNAME

    # Add a button to submit the selected IP addresses
    $submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"
    $submitButton.Add_Click({
        Write-Host "Attempting to retrieve ETC database data from Server...`n"
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
                    param($hostRegPath, $hostRegPathHeader, $compName, $ETCTargetPath)
                    Write-Host "Setting new ETC database target location " -NoNewline
                    Write-Host "$($ETCTargetPath) " -ForegroundColor Yellow -NoNewline
                    Write-Host "on " -NoNewline
                    Write-Host "$ENV:COMPUTERNAME`n" -ForegroundColor Green
                    Set-ItemProperty -Path $hostRegPath -Name "Primary Database" -Value "$($hostRegPathHeader)$($ETCTargetPath)" -Force
                } -ArgumentList $ETC_ClientDBRegPath, $ETCPrimaryDatabaseRegEntryHeader, $computerName, $sourceFile
                $numRan += 1
                }
                catch {
                    Write-Host "Cannot deliver command to $ip"
                }
                }

            else {
                Write-Host "$ip is unavailable" -ForegroundColor Red
                $numFailed += 1
            }
        
        }
        }
        
        
    
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
Read-Host "`nPress any key to exit"