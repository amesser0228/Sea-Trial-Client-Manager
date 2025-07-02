# Checks if the script is running as an administrator #
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
    }

#Open dialog box prompt to select file
Add-Type -AssemblyName System.Windows.Forms

$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Title = "Select a file"
$openFileDialog.Filter = "All Files (*.*)|*.*" #for all file types:  "All Files (*.*)|*.*"

if ($openFileDialog.ShowDialog() -eq 'OK') {
    $filePath = $openFileDialog.FileName

# Provide credentials for hosts
$securePassword = ConvertTo-SecureString "L-3Communicati0ns!" -AsPlainText -Force
$lcsCredential = New-Object System.Management.Automation.PSCredential ("LCS", $securePassword)
$cvnCredential = New-Object System.Management.Automation.PSCredential ("CVN", $securePassword)


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

Write-Host "File selected to copy: $filePath`n`n" -ForegroundColor Yellow

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
    $directoryOptionShown = $false
    foreach ($control in $flowLayoutPanel.Controls) {
        if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
        $ip = $control.Text
        $timeout = 100 # Timeout in milliseconds
        $ping = New-Object System.Net.NetworkInformation.Ping
        $reply = $ping.Send($ip, $timeout)
        if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
            try {
            if (-not $directoryOptionShown) {
            write-host "
Admin Only Directory:
--------------------"
            # Get directories of Admin Only from remote host
             $remoteDirectories = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                    Get-ChildItem -Path "C:\Admin Only" -Directory
                }
                 

            # Display the directories
            $remoteDirectories | ForEach-Object {
                Write-Host $_.FullName
            }

            $userPath = Read-Host "
            Select a folder option to add file:
        
                1 = MOB Firmware Folder
                2 = MAR Firmware Folder
                3 = CVN Firmware Folder
                4 = Enter a custom path
            
            Enter option number"

            $fullDestinationPath = ""

            if ($userPath -eq 1) {
                $fullDestinationPath = "Admin Only\Firmware\5510"
            }
            elseif ($userPath -eq 2) {
                $fullDestinationPath = "Admin Only\Firmware\5531"
            }
            elseif ($userPath -eq 3) {
                $fullDestinationPath = "Admin Only\Firmware\5550"
            }
            
            elseif ($userPath -eq 4) {
                $fullDestinationPath = Read-Host "Enter custom path without 'C:\'"
            }

            
            $directoryOptionShown = $true
            }

            New-PSDrive -Name "Remote" -PSProvider FileSystem -Root "\\$ip\C$" -Credential $credential -Scope Global -ErrorAction SilentlyContinue

            Copy-Item -Path "$filePath" -Destination "Remote:\$fullDestinationPath"

            Remove-PSDrive -Name "Remote"

            Start-Sleep 1

            Write-Host "`nFile copied to " -NoNewline
            Write-Host "$ip " -NoNewline -ForegroundColor Green
            Write-Host "succesfully. " -NoNewline
            Write-Host "Temporary PSDrive " -NoNewline
            Write-Host "Remote " -ForegroundColor Cyan -NoNewline
            Write-Host "has been removed."
            }
            catch {
            Write-Warning "File could not be copied to destination because there was an issue connecting to $ip or the supplied parameters were incorrect."
            Start-Sleep 5
            }
                        }
            else {
                Write-Host "$ip is unavailable" -ForegroundColor Red
            }
        }
    }
    write-Host "`nAll files copied" -ForegroundColor Green
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
    
