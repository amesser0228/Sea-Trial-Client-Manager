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

<# Checks if the script is running as an administrator #
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
    }
    #>

# Open dialog box prompt to select folder
Add-Type -AssemblyName System.Windows.Forms #opens folder dialog box
$folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowserDialog.Description = "Select a folder"
#"Select a folder containing CKL files"

if ($folderBrowserDialog.ShowDialog() -eq 'OK') {
    $folderPath = $folderBrowserDialog.SelectedPath
    Write-Host "You selected folder: $folderPath`n" -ForegroundColor Yellow

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
            try {

            # Define the remote computer name

            # Use Invoke-Command to run a script block on the remote computer
             $remoteDirectories = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                    Get-ChildItem -Path "C:\Admin Only" -Directory
                }

            # Display the directories
            $remoteDirectories | ForEach-Object {
                Write-Host $_.FullName
            }

            New-PSDrive -Name "Remote" -PSProvider FileSystem -Root "\\$ip\C$" -Credential $credential -Scope Global

            $fullDestinationPath = Read-Host "`nEnter the location from the list to copy the folder. Do not include 'C:\'"

            Copy-Item -Path "$folderPath" -Destination "Remote:\$fullDestinationPath" -Recurse

            Remove-PSDrive -Name "Remote"

            Start-Sleep 1

            Write-Host "`nFolder copied to " -NoNewline
            Write-Host "$ip " -NoNewline -ForegroundColor Green
            Write-Host "succesfully. " -NoNewline
            Write-Host "Temporary PSDrive " -NoNewline
            Write-Host "Remote " -ForegroundColor Cyan -NoNewline
            Write-Host "has been removed."
            }
            catch {
            Write-Warning "Folder could not be copied to destination because there was an issue connecting to $ip or the supplied parameters were incorrect."
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
}
else {
Write-Host "No file selected"
}

Read-Host "Press any key to exit"
    
