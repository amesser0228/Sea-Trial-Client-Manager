<#DEVELOPED BY ANDREW MESSER

SYNOPSIS:

    1. QUERIES HOSTS IN CLIENT ARRAY
    2. RUNS COMMAND WITH REMOTE CREDENTIALS TO EACH HOST
    3. COMMAND OPTIONS ON REMOTE HOSTS:
	    1. RESTART
	    2. END SPECIIFIED TASK
	    3. ENABLE/DISABLE AUTOLOGON
	    4. ENABLE/DISABLE SMARTSCREEN
	    5. START PROCESS
	    6. CHANGE POWER SETTINGS
	    7. ENABLE/DISABLE INACTIVITY MONITOR
	    8. RELOAD LCS PRODUCTION SCRIPTS
	    9. UNLOAD LCS PRODUCTION SCRIPTS
	    10. RUN CUSTOM COMMAND

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

# Checks if the script is running as an administrator #
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$scriptName = $MyInvocation.MyCommand.Name
$substring = $scriptName.Substring(24,4)
Write-Host "Script Version: "$($substring)


Write-Host "
# # # # # # # # # # # # # #
#                         #
#  Run a Remote Command   #
#                         #
# # # # # # # # # # # # # #
`n`n"

Write-Host "RUN A COMMAND ON REMOTE HOST `n`n" -ForegroundColor Yellow

Write-Host "Remote Username:" -NoNewline
Write-Host $remoteUsername -ForegroundColor Green
Write-Host Remote IP range: -NoNewline
Write-Host $remoteIPPrefix"."$beginningDeviceID "-" $endingDeviceID -ForegroundColor Green
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


#RemoteIPs
$remoteIPAddresses = @()
for ($i = [int]$beginningDeviceID; $i -le [int]$endingDeviceID; $i++) {
    $remoteIPAddresses += "$($remoteIPPrefix).$($i)"
}

#loop Counter for num of reachable clients
$numReplied = 0

#loop Counter for num of clients that ran the script
$numRan = 0

#loop Counter for num of unreachable clients
$numFailed = 0

#Infrastructure and batch conditions are not indented to retain the appearance of the CLI Interface


# A global try/catch doesn't seem to work in this pipeline so the try/catch has been
# nested within each condition. The code readibility has not been negatively affected.

# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing


############# FORMS #############

# Create the client form
$clientForm = New-Object System.Windows.Forms.Form
$clientForm.Text = "Select Command"
$clientForm.Size = New-Object System.Drawing.Size(400, 740) 
$clientForm.StartPosition = "CenterScreen"

# Create the custom IP textbox form
$customIPForm = New-Object System.Windows.Forms.Form
$customIPForm.Text = "Enter IP Address"
$customIPForm.Size = New-Object System.Drawing.Size(300, 400)
$customIPForm.StartPosition = "CenterScreen"

# Create the client form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select Remote Computers"
$form.Size = New-Object System.Drawing.Size(400, 560)
$form.StartPosition = "CenterScreen"


############# FLOW LAYOUT PANELS #############

# Create a FlowLayoutPanel with AutoScroll enabled
$flowLayoutPanelOptions = New-Object System.Windows.Forms.FlowLayoutPanel
$flowLayoutPanelOptions.AutoScroll = $true
$flowLayoutPanelOptions.Dock = [System.Windows.Forms.DockStyle]::Fill
$flowLayoutPanelOptions.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$flowLayoutPanelOptions.WrapContents = $false

# Create a FlowLayoutPanel for custom IP with AutoScroll enabled
$customIPFlowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$customIPFlowLayoutPanel.AutoScroll = $true
$customIPFlowLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$customIPFlowLayoutPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$customIPFlowLayoutPanel.WrapContents = $false

# Create a FlowLayoutPanel with AutoScroll enabled
$flowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$flowLayoutPanel.AutoScroll = $true
$flowLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$flowLayoutPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$flowLayoutPanel.WrapContents = $false


############# TEXTBOXES #############

# Add textbox to enter custom IP
$textboxCustomIP = New-Object System.Windows.Forms.TextBox
$textboxCustomIP.Location = New-Object System.Drawing.Point(10,10)
$textboxCustomIP.Multiline = $true
$textboxCustomIP.Size = New-Object System.Drawing.Size(200,200)
$textboxCustomIP.Height = 80


############# BUTTONS #############

# Add button to select custom IP option
$buttonCustomIP = New-Object System.Windows.Forms.Button
$buttonCustomIP.Text = "Enter a different IP"
$buttonCustomIP.Width = 112
$buttonCustomIP.Margin = New-Object System.Windows.Forms.Padding(4, 11, 10, 20)

# Button to add custom IP address to object
$customIPSubmitButton = New-Object System.Windows.Forms.Button
$customIPSubmitButton.Text = "Done"
$customIPSubmitButton.Width = 80
$customIPSubmitButton.Margin = New-Object System.Windows.Forms.Padding(10, 110, 10, 10)

# Button to select all IPs
$selectAllButton = New-Object System.Windows.Forms.Button
$selectAllButton.Text = "Select All"
$selectAllButton.Width = 80

# Button to select all IPs
$unSelectAllButton = New-Object System.Windows.Forms.Button
$unSelectAllButton.Text = "Unselect All"
$unSelectAllButton.Width = 80

# Button to submit IP selection
$submitButton = New-Object System.Windows.Forms.Button
$submitButton.Text = "Submit"
$submitButton.Width = 80
$submitButton.Height = 40
$submitButton.BackColor = [System.Drawing.Color]::Green
$submitButton.ForeColor = [System.Drawing.Color]::White


############# CHECKBOXES #############

$checkbox1 = New-Object System.Windows.Forms.CheckBox
$checkbox1.Text = "Restart client(s)"
$checkbox1.AutoSize = $true
$checkbox1.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

$checkbox2 = New-Object System.Windows.Forms.CheckBox
$checkbox2.Text = " End a task on client(s). Task name must be provided"
$checkbox2.AutoSize = $true
$checkbox2.Margin = New-Object System.Windows.Forms.Padding(10, 12, 10, 10)

$checkbox3 = New-Object System.Windows.Forms.CheckBox
$checkbox3.Text = "Enable/Disable Auto_admin_logon"
$checkbox3.AutoSize = $true 
$checkbox3.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

$checkbox4 = New-Object System.Windows.Forms.CheckBox
$checkbox4.Text = "Enable/Disable Defender Smartscreen blocking"
$checkbox4.AutoSize = $true 
$checkbox4.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

$checkbox5 = New-Object System.Windows.Forms.CheckBox
$checkbox5.Text = "Start a process. Filepath required"
$checkbox5.AutoSize = $true 
$checkbox5.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

$checkbox6 = New-Object System.Windows.Forms.CheckBox
$checkbox6.Text = "Change Power and Sleep settings"
$checkbox6.AutoSize = $true  
$checkbox6.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

$checkbox7 = New-Object System.Windows.Forms.CheckBox
$checkbox7.Text = "Enable/Disable Inactivity Monitor"
$checkbox7.AutoSize = $true  
$checkbox7.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

$checkbox8 = New-Object System.Windows.Forms.CheckBox
$checkbox8.Text = "Reload Production Scripts (LCS)"
$checkbox8.AutoSize = $true
$checkbox8.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

$checkbox9 = New-Object System.Windows.Forms.CheckBox
$checkbox9.Text = "Reload Production Scripts (CVN)"
$checkbox9.AutoSize = $true
$checkbox9.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

$checkbox10 = New-Object System.Windows.Forms.CheckBox
$checkbox10.Text = "Run Custom Command"
$checkbox10.AutoSize = $true  
$checkbox10.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

$checkbox11 = New-Object System.Windows.Forms.CheckBox
$checkbox11.Text = "Set default gateway"
$checkbox11.AutoSize = $true
$checkbox11.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

$checkbox12 = New-Object System.Windows.Forms.CheckBox
$checkbox12.Text = "Set Office Fileblock to Allow"
$checkbox12.AutoSize = $true
$checkbox12.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 14)

$checkbox13 = New-Object System.Windows.Forms.CheckBox
$checkbox13.Text = "Set password scan policies (age/lockout)"
$checkbox13.AutoSize = $true
$checkbox13.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 14)

$checkbox15 = New-Object System.Windows.Forms.CheckBox
$checkbox15.Text = "Disable Bitlocker"
$checkbox15.AutoSize = $true
$checkbox15.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 14)

$tasksListBox = New-Object System.Windows.Forms.CheckedListBox
[void]$tasksListBox.Items.Add("Run Scheduled Task")
[void]$tasksListBox.Items.Add("Enable Scheduled Task")
[void]$tasksListBox.Items.Add("Disable Scheduled Task")
$tasksListBox.AutoSize = $true
$tasksListBox.Margin = New-Object System.Windows.Forms.Padding(10, 3, 10, 14)

<#
$checkbox16 = New-Object System.Windows.Forms.CheckBox
$checkbox16.Text = "Run Scheduled Task"
$checkbox16.AutoSize = $true
$checkbox16.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 14)

$checkbox17 = New-Object System.Windows.Forms.CheckBox
$checkbox17.Text = "Enable Scheduled Task"
$checkbox17.AutoSize = $true
$checkbox17.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 14)
#>

$systemreservedcheckBox = New-Object System.Windows.Forms.CheckBox
$systemreservedcheckBox.Text = "Reserved"
$systemreservedcheckBox.Enabled = $false
$systemreservedcheckBox.AutoSize = $false
$systemreservedcheckBox.width = 200
$systemreservedcheckBox.Margin = New-Object System.Windows.Forms.Padding(4, 10, 10, 10)


############# LABELS #############

$taskLabel = New-Object System.Windows.Forms.Label
$taskLabel.Font = New-Object System.Drawing.Font($taskLabel.Font.FontFamily, 11)
$taskLabel.Text = "Scheduled Task Options"
$taskLabel.AutoSize = $true
$taskLabel.Location = New-Object System.Drawing.Point(10, 10)

# Add the controls to the FlowLayoutPanel in the desired order
#$flowLayoutPanel.Controls.Add($label1)
#$flowLayoutPanel.Controls.Add($labelLine)
$flowLayoutPanelOptions.Controls.Add($checkbox1)
#$flowLayoutPanelOptions.Controls.Add($label1)
#$flowLayoutPanelOptions.Controls.Add($label1Line)
#$flowLayoutPanelOptions.Controls.Add($label1Disclaimer)
$flowLayoutPanelOptions.Controls.Add($checkbox2)
$flowLayoutPanelOptions.Controls.Add($checkbox3)
$flowLayoutPanelOptions.Controls.Add($checkbox4)
$flowLayoutPanelOptions.Controls.Add($checkbox5) 
$flowLayoutPanelOptions.Controls.Add($checkbox6)
$flowLayoutPanelOptions.Controls.Add($checkbox7)
$flowLayoutPanelOptions.Controls.Add($checkbox8)
$flowLayoutPanelOptions.Controls.Add($checkbox9)
$flowLayoutPanelOptions.Controls.Add($checkbox10)
$flowLayoutPanelOptions.Controls.Add($checkbox11)
$flowLayoutPanelOptions.Controls.Add($checkbox12)
$flowLayoutPanelOptions.Controls.Add($checkbox13)
$flowLayoutPanelOptions.Controls.Add($checkbox15)
$flowLayoutPanelOptions.Controls.Add($checkbox16)
$flowLayoutPanelOptions.Controls.Add($checkbox17)
$flowLayoutPanelOptions.Controls.Add($taskLabel)
$flowLayoutPanelOptions.Controls.Add($tasksListBox)



# Add the FlowLayoutPanel to the form
$clientForm.Controls.Add($flowLayoutPanelOptions)

# Show the form
#$clientForm.Add_Shown({$clientForm.Activate()})
#$clientForm.ShowDialog()


# Provide credentials for hosts
$remoteSecurePassword = ConvertTo-SecureString $remotePassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($remoteUsername, $remoteSecurePassword)
    
    


## CONDITIONS TO RUN COMMANDS ##

# 1. Restart client
###################
# Add a button to submit the selected command options
$submitButtonClient = New-Object System.Windows.Forms.Button
$submitButtonClient.Text = "Submit"
$submitButtonClient.Add_Click({
if ($checkbox1.Checked) {
    $clientForm.Close()
    foreach ($client in $remoteIPAddresses) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        #$checkbox.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 5)
        $flowLayoutPanel.Controls.Add($checkbox)
    }

        #Custom IP intake form logic
        $flowLayoutPanel.Controls.Add($systemreservedcheckBox)
        $flowLayoutPanel.Controls.Add($buttonCustomIP)

        $customIPInput = $false

        $buttonCustomIP.Add_Click({
        $customIPInput = $true
        $customIPSubmitButton.Add_Click({
        $systemreservedcheckBox.Checked = $true
        $systemreservedcheckBox.Text = $textboxCustomIP.Text
        $customIPForm.Close()
        })
        $customIPForm.Controls.Add($customIPFlowLayoutPanel)
        $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
        $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
        [void] $customIPForm.ShowDialog()
        })

    # Add a button to select all IP addresses
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to unselect all IP addresses
    $unSelectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
                $control.Checked = $false
            }
        }
    })
    $flowLayoutPanel.Controls.Add($unSelectAllButton)

    # Add a button to submit the selected IP addresses
    <#$submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"#>
    $submitButton.Add_Click({
    $form.Close()
        Write-Host "Restarting..."
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 150 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                            Write-Host $env:COMPUTERNAME -ForegroundColor Green
                            #Restart machine
                            Restart-Computer -Force
                        }
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
}

# 11. Set default gateway
### To change default gateway address: edit the NextHop field ###
###################
# Add a button to submit the selected command options
if ($checkbox11.Checked) {
    $clientForm.Close()
    foreach ($client in $remoteIPAddresses) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        #$checkbox.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 5)
        $flowLayoutPanel.Controls.Add($checkbox)
    }

        #Custom IP intake form logic
        $flowLayoutPanel.Controls.Add($systemreservedcheckBox)
        $flowLayoutPanel.Controls.Add($buttonCustomIP)

        $customIPInput = $false

        $buttonCustomIP.Add_Click({
        $customIPInput = $true
        $customIPSubmitButton.Add_Click({
        $systemreservedcheckBox.Checked = $true
        $systemreservedcheckBox.Text = $textboxCustomIP.Text
        $customIPForm.Close()
        })
        $customIPForm.Controls.Add($customIPFlowLayoutPanel)
        $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
        $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
        [void] $customIPForm.ShowDialog()
        })

    # Add a button to select all IP addresses
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to submit the selected IP addresses
    <#$submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"#>
    $submitButton.Add_Click({
    $form.Close()
        Write-Host "Setting default gateway on..."
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 150 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                            param($whichBatch)
                            Write-Host $env:COMPUTERNAME -ForegroundColor Green
                            $interfaceIndex = (Get-NetAdapter | Where-Object { $_.InterfaceDescription -like '*Ethernet*' }).InterfaceIndex

                            #$newDefaultGateway = Read-Host "enter default gateway"

                            #Remove-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceAlias $interfaceIndex

                            $interfaceIndex = (Get-NetAdapter | Where-Object { $_.InterfaceDescription -like '*Ethernet*' }).InterfaceIndex
                            
                            if ($whichBatch -eq 1 -or $whichBatch -eq 2) {
                            New-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceIndex $interfaceIndex -NextHop "192.168.56.1" -ErrorAction SilentlyContinue
                            }

                            if ($whichBatch -eq 3) {
                            New-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceIndex $interfaceIndex -NextHop "192.168.79.1" -ErrorAction SilentlyContinue
                            }

                            $defaultGateway = Get-NetRoute -InterfaceIndex $interfaceIndex | Where-Object { $_.DestinationPrefix -eq "0.0.0.0/0" } | Select-Object -ExpandProperty NextHop
                            Write-Host "New default gateway: " -NoNewline
                            Write-Host "$($defaultGateway)`n" -ForegroundColor Cyan
                            } -ArgumentList $whichBatchNumber
                    $numRan += 1
                    }
                    catch  {
                        Write-Host "Cannot deliver command to $ip"
                        Write-Host "Error: $($_.Exception.Message)"
                        Write-Host "Ssystem Error: $($_.Exception.Inner.Message)"
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
}
    

# 12 Set Office Fileblock to allow
### To change default gateway address: edit the NextHop field ###
###################
# Add a button to submit the selected command options
if ($checkbox12.Checked) {
    $clientForm.Close()
    foreach ($client in $remoteIPAddresses) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        #$checkbox.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 5)
        $flowLayoutPanel.Controls.Add($checkbox)
    }

        #Custom IP intake form logic
        $flowLayoutPanel.Controls.Add($systemreservedcheckBox)
        $flowLayoutPanel.Controls.Add($buttonCustomIP)

        $customIPInput = $false

        $buttonCustomIP.Add_Click({
        $customIPInput = $true
        $customIPSubmitButton.Add_Click({
        $systemreservedcheckBox.Checked = $true
        $systemreservedcheckBox.Text = $textboxCustomIP.Text
        $customIPForm.Close()
        })
        $customIPForm.Controls.Add($customIPFlowLayoutPanel)
        $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
        $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
        [void] $customIPForm.ShowDialog()
        })

    # Add a button to select all IP addresses
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to submit the selected IP addresses
    <#$submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"#>
    $submitButton.Add_Click({
    $form.Close()
        Write-Host "Seting Office Fileblock to allow on..."
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 150 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                            Write-Host "$($env:COMPUTERNAME)" -ForegroundColor Green
                            $wordRegPath = "HKCU:\Software\Policies\Microsoft\Office\16.0\Word\Security\FileBlock"
                            # Set the registry path for Excel file block policy
                            $excelRegPath = "HKCU:\Software\Policies\Microsoft\Office\16.0\Excel\Security\FileBlock" #-ErrorAction SilentlyContinue
                            Write-Host "Checking Word and Excel fileblock registry keys...`n`n"

                            #Word Registry Entries
                            if(Test-Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Word\Security\FileBlock")
                            {
                                Write-Host "Changing reg entries to allow Word binary files..." -ForegroundColor Yellow
                                New-ItemProperty -Path $wordRegPath -Name "word2000files" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "word2003files" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "word2007files" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "word2files" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "word60files" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "word95files" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "word97files" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "wordxp" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "word2000files" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "wordxml" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "wordxpfiles" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "openinprotectedview" -Value 0 -Force
                            }
                            else {
                                Write-Host "Creating new path in registry: $wordRegPath. Adding reg entries to allow Word and Excel binary files..." -ForegroundColor Yellow
                                New-Item -Path $wordRegPath -Force
                                New-ItemProperty -Path $wordRegPath -Name "word2000files" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "word2003files" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "word2007files" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "word2files" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "word60files" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "word95files" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "word97files" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "wordxp" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "word2000files" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "wordxml" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "wordxpfiles" -Value 0 -Force
                                New-ItemProperty -Path $wordRegPath -Name "openinprotectedview" -Value 0 -Force
                            }

                            #Excel Registry Entries
                            if(Test-Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Excel\Security\FileBlock")
                            {
                                Write-Host "Changing reg entries to allow Excel binary files...`n" -ForegroundColor Yellow
                                New-ItemProperty -Path $excelRegPath -Name "xl2macros" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl2worksheets" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl3macros" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl3worksheets" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl4macros" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl4workbooks" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl4worksheets" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl9597workbooksandtemplates" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl95workbooks" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl97addins" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl97workbooksandtemplates" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xlamfiles" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xlsbfiles" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xlsmandxltmfiles" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xlsxandxltxfiles" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "dbasefiles" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "difandsylkfiles" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "htmlandxmlssfiles" -Value 0 -Force

                            }
                            else {
                                Write-Host "Creating new path in registry: $excelRegPath. Adding reg entries to allow Excel binary files...`n" -ForegroundColor Yellow
                                New-Item -Path $excelRegPath -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl2macros" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl2worksheets" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl3macros" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl3worksheets" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl4macros" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl4workbooks" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl4worksheets" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl9597workbooksandtemplates" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl95workbooks" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl97addins" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xl97workbooksandtemplates" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xlamfiles" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xlsbfiles" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xlsmandxltmfiles" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "xlsxandxltxfiles" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "dbasefiles" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "difandsylkfiles" -Value 0 -Force
                                New-ItemProperty -Path $excelRegPath -Name "htmlandxmlssfiles" -Value 0 -Force
                            }
                            }
                    $numRan += 1
                    }
                    catch  {
                        Write-Host "Cannot deliver command to $ip"
                        Write-Host "Error: $($_.Exception.Message)"
                        Write-Host "Ssystem Error: $($_.Exception.Inner.Message)"
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
}

# 13 Set Password age and Lockout
###################
# Add a button to submit the selected command options
if ($checkbox13.Checked) {
    $clientForm.Close()
    foreach ($client in $remoteIPAddresses) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        #$checkbox.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 5)
        $flowLayoutPanel.Controls.Add($checkbox)
    }

        #Custom IP intake form logic
        $flowLayoutPanel.Controls.Add($systemreservedcheckBox)
        $flowLayoutPanel.Controls.Add($buttonCustomIP)

        $customIPInput = $false

        $buttonCustomIP.Add_Click({
        $customIPInput = $true
        $customIPSubmitButton.Add_Click({
        $systemreservedcheckBox.Checked = $true
        $systemreservedcheckBox.Text = $textboxCustomIP.Text
        $customIPForm.Close()
        })
        $customIPForm.Controls.Add($customIPFlowLayoutPanel)
        $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
        $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
        [void] $customIPForm.ShowDialog()
        })

    # Add a button to select all IP addresses
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to submit the selected IP addresses
    <#$submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"#>
    $submitButton.Add_Click({
    $form.Close()
        Write-Host "Setting password scan policies on..."
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 150 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                    Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { Write-Host "$($env:COMPUTERNAME)" -ForegroundColor Green }
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                            #Maximum Password Age = 60 days (V-220743)
                                net accounts /maxpwage:60

                                #Account Lockout Threshold = 3 Attempts (V-220740)
                                net accounts /lockoutthreshold:3
                            }
                    $numRan += 1
                    }
                    catch  {
                        Write-Host "Cannot deliver command to $ip"
                        Write-Host "Error: $($_.Exception.Message)"
                        Write-Host "Ssystem Error: $($_.Exception.Inner.Message)"
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
}



# 2. Kill task on client
########################
if ($checkbox2.Checked) {
$clientForm.Close()
    foreach ($client in $remoteIPAddresses) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        $flowLayoutPanel.Controls.Add($checkbox)
    }

        #Custom IP intake form logic
        $flowLayoutPanel.Controls.Add($systemreservedcheckBox)
        $flowLayoutPanel.Controls.Add($buttonCustomIP)

        $customIPInput = $false

        $buttonCustomIP.Add_Click({
        $customIPInput = $true
        $customIPSubmitButton.Add_Click({
        $systemreservedcheckBox.Checked = $true
        $systemreservedcheckBox.Text = $textboxCustomIP.Text
        $customIPForm.Close()
        })
        $customIPForm.Controls.Add($customIPFlowLayoutPanel)
        $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
        $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
        [void] $customIPForm.ShowDialog()
        })

    # Add a button to select all IP addresses
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to submit the selected IP addresses
    <#$submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"
    $submitButton.Width = 80
    $submitButton.Height = 40
    $submitButton.BackColor = [System.Drawing.Color]::Green
    $submitButton.ForeColor = [System.Drawing.Color]::White#>
    $submitButton.Add_Click({
    $form.Close()
        $taskName = Read-Host "`nEnter task name to end. Ex: etc, msedge, winword"
        Write-Host "Killing $taskName on..."
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 150 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                                param($task)
                                if(Get-Process | Where-Object {$_.Name -like "*$($task)*"}) {
                                Write-Host $env:COMPUTERNAME -ForegroundColor Green
                                Stop-Process -Name $task -Force
                                }
                                else {
                                Write-Host "$($task) is not running on $($env:COMPUTERNAME)" -ForegroundColor Yellow
                                }
                                } -ArgumentList $taskName
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
        Write-Host "Number of clients that failed: " -NoNewline
        Write-Host "$numFailed" -ForegroundColor Red
    })
    $flowLayoutPanel.Controls.Add($submitButton)

    $form.Controls.Add($flowLayoutPanel)
    $form.Add_Shown({$form.Activate()})
    [void] $form.ShowDialog()
}

                    

# 3. Enable AutoAdminLogon on client
####################################
if ($checkbox3.Checked) {
$clientForm.Close()
    $enableOrDisable = Read-Host "
    Enable/Disable Autoadminlogon
    _____________________________

        1 = Enable

        2 = Disable

        Enter"
    
    $statusOfAIL = ""
    if ($enableOrDisable -eq 1) {
        $statusOfAIL = "Enabling"
    }
    elseif ($enableOrDisable -eq 2) {
        $statusOfAIL = "Disabling"
    }
    foreach ($client in $remoteIPAddresses) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        $flowLayoutPanel.Controls.Add($checkbox)
    }

        #Custom IP intake form logic
        $flowLayoutPanel.Controls.Add($systemreservedcheckBox)
        $flowLayoutPanel.Controls.Add($buttonCustomIP)

        $customIPInput = $false

        $buttonCustomIP.Add_Click({
        $customIPInput = $true
        $customIPSubmitButton.Add_Click({
        $systemreservedcheckBox.Checked = $true
        $systemreservedcheckBox.Text = $textboxCustomIP.Text
        $customIPForm.Close()
        })
        $customIPForm.Controls.Add($customIPFlowLayoutPanel)
        $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
        $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
        [void] $customIPForm.ShowDialog()
        })

    # Add a button to select all IP addresses
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to submit the selected IP addresses
    $submitButton.Add_Click({
        Write-Host "$statusOfAIL AutoAdminLogon on..."
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 150 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                        param($enableOrDisable, $autoLogonUser)
                        $DefaultRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                        $registryValue_DU = "$DefaultRegistryPath\DefaultUserName"
                        $registryValue_PW = "$DefaultRegistryPath\DefaultPassword"
                        $registryValue_AAL = Get-ItemPropertyValue -Path $DefaultRegistryPath -Name "AutoAdminLogon"
                            Write-Host $env:COMPUTERNAME -ForegroundColor Green
                            if ($enableOrDisable -eq 1) {
                            # Set AutoLogon
                            # LCS/CVN AutoAdminLogon Block
                            if ($registryValue_AAL -eq 1) {

                                # Removes any previous Auto admin logon registry values
                                Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName"
                                Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword"
                                Remove-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon"

                                # Creates new registry values for Auto admin logon
                                New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value $autoLogonUser -Force
                                New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force
                                New-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

                                Write-Host "`nRemoving old registry entries. `n`nSetting AutoLogon for $($autoLogonUser).`n" -ForegroundColor DarkCyan
                            } else {
                                # Creates new registry values for Auto admin logon
                                New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value $autoLogonUser -Force
                                New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force
                                New-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

                                Write-Host "`nSetting AutoLogon for $($autoLogonUser)." -ForegroundColor DarkCyan
                                Start-Sleep 2

                                        }
                                    }
                            elseif ($enableOrDisable -eq 2) {

                            $DefaultRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                            $registryValue_DU = "$DefaultRegistryPath\DefaultUserName"
                            $registryValue_PW = "$DefaultRegistryPath\DefaultPassword"
                            $registryValue_AAL = "$DefaultRegistryPath\AutoAdminLogon"

                                if ($registryValue_AAL -ne $null) {

                                    # Check if each property exists before trying to remove it
                                    if ($registryValue_DU -ne "") {
                                        Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Force -ErrorAction SilentlyContinue
                                    }
    
                                    if ($registryValue_PW -ne "") {
                                        Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Force -ErrorAction SilentlyContinue
                                    }
    
                                    if ($registryValue_AAL -ne "") {
                                        Remove-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Force -ErrorAction SilentlyContinue
                                    }

                                    Write-Host "`nRemoving old registry entries. `n`nRemoving and disabling AutoLogon.`n"

                                } else {

                                    Write-Host "`nNo AutoAdminLogon entries exist in registry key {HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon}" -ForegroundColor Yellow
                                }
                            }
                        } -ArgumentList $enableOrDisable, $autoLogonUser
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
        Write-Host "Number of clients that failed: " -NoNewline
        Write-Host "$numFailed" -ForegroundColor Red
        $form.Close()
    })
    $flowLayoutPanel.Controls.Add($submitButton)

    $form.Controls.Add($flowLayoutPanel)
    $form.Add_Shown({$form.Activate()})
    [void] $form.ShowDialog()
}



# 4. Enable/Disable defender smartscreen
########################################
if ($checkbox4.Checked) {
$clientForm.Close()
    $enableOrDisable = Read-Host "
    Enable/Disable defender smartscreen
    ___________________________________

        1 = Enable

        2 = Disable

        Enter"
    foreach ($client in $remoteIPAddresses) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        $flowLayoutPanel.Controls.Add($checkbox)
    }

        #Custom IP intake form logic
        $flowLayoutPanel.Controls.Add($systemreservedcheckBox)
        $flowLayoutPanel.Controls.Add($buttonCustomIP)

        $customIPInput = $false

        $buttonCustomIP.Add_Click({
        $customIPInput = $true
        $customIPSubmitButton.Add_Click({
        $systemreservedcheckBox.Checked = $true
        $systemreservedcheckBox.Text = $textboxCustomIP.Text
        $customIPForm.Close()
        })
        $customIPForm.Controls.Add($customIPFlowLayoutPanel)
        $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
        $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
        [void] $customIPForm.ShowDialog()
        })

    # Add a button to select all IP addresses
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to submit the selected IP addresses
    <#$submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"#>
    $submitButton.Add_Click({
    $form.Close()
        Write-Host "Processing option $enableOrDisable on selected clients" -ForegroundColor Yellow
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 150 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                        $numRan += 1
                    if ($enableOrDisable -eq 1) {
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                            Write-Host "Enabling defender smartscreen on $env:COMPUTERNAME" -ForegroundColor Green
                            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -Value 1 -Force
                        } -Verbose
                    }
                    elseif ($enableOrDisable -eq 2) {
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                            Write-Host "Disabling defender smartscreen on $env:COMPUTERNAME" -ForegroundColor Green
                            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -Value 0 -Force
                        } -Verbose
                        $numRan += 1
                        }
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
        Write-Host "Number of clients that failed: " -NoNewline
        Write-Host "$numFailed" -ForegroundColor Red
    })
    $flowLayoutPanel.Controls.Add($submitButton)

    $form.Controls.Add($flowLayoutPanel)
    $form.Add_Shown({$form.Activate()})
    [void] $form.ShowDialog()
    start-sleep 2
}


# 5. Start a process
####################
if ($checkbox5.Checked) {
$clientForm.Close()
    foreach ($client in $remoteIPAddresses) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        $flowLayoutPanel.Controls.Add($checkbox)
    }

        #Custom IP intake form logic
        $flowLayoutPanel.Controls.Add($systemreservedcheckBox)
        $flowLayoutPanel.Controls.Add($buttonCustomIP)

        $customIPInput = $false

        $buttonCustomIP.Add_Click({
        $customIPInput = $true
        $customIPSubmitButton.Add_Click({
        $systemreservedcheckBox.Checked = $true
        $systemreservedcheckBox.Text = $textboxCustomIP.Text
        $customIPForm.Close()
        })
        $customIPForm.Controls.Add($customIPFlowLayoutPanel)
        $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
        $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
        [void] $customIPForm.ShowDialog()
        })

    # Add a button to select all IP addresses
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to submit the selected IP addresses
    <#$submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"#>
    $submitButton.Add_Click({
    $form.Close()
        Write-Host "Starting process after user entry on "
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 150 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                        $numRan += 1
                        # Get directories of Admin Only from remote host
                        $remoteDirectories = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                            Get-ChildItem -Path "C:\Admin Only" -Directory
                        }
                        # Display the directories
                        $remoteDirectories | ForEach-Object {
                            Write-Host $_.FullName
                        }
                        $processPath = Read-Host "Enter file path of process to start"
                        
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                            param($processPath)
                            Write-Host $env:COMPUTERNAME -ForegroundColor Green
                            Start-Process -FilePath "$processPath"
                            $numRan += 1
                        } -ArgumentList $processPath
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
        Write-Host "Number of clients that failed: " -NoNewline
        Write-Host "$numFailed" -ForegroundColor Red
    })
    $flowLayoutPanel.Controls.Add($submitButton)

    $form.Controls.Add($flowLayoutPanel)
    $form.Add_Shown({$form.Activate()})
    [void] $form.ShowDialog()
    start-sleep 2
}

# 6. Power and sleep settings
#############################
if ($checkbox6.Checked) {
$clientForm.Close()
        $powerType = Read-Host "
        Set power and sleep settings
        ____________________________

        1 = Plugged-in power settings

        2 = Unplugged power settings

        3 = Set both power settings at once

        Enter"

        
        if ($powerType -eq 1) {
            $powerTimeMinutes = [int](Read-Host "
            0  = Disable all timeoutes while plugged in

            30 = Set timeouts to 30 minutes while plugged

            60 = Set timeouts to 1 hour while plugged in

            Enter")
            }

        if ($powerType -eq 2) {
            $powerTimeMinutes = [int](Read-Host "
            0  = Disable all timeoutes while plugged in

            30 = Set timeouts to 30 minutes while plugged

            60 = Set timeouts to 1 hour while plugged in

            Enter")
            }

        if ($powerType -eq 3) {
            $powerTimeMinutes = [int](Read-Host "
            0  = Disable all timeoutes while plugged in

            30 = Set timeouts to 30 minutes while plugged

            60 = Set timeouts to 1 hour while plugged in

            Enter")
            }


foreach ($client in $remoteIPAddresses) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $client
    $flowLayoutPanel.Controls.Add($checkbox)
}

    #Custom IP intake form logic
    $flowLayoutPanel.Controls.Add($systemreservedcheckBox)
    $flowLayoutPanel.Controls.Add($buttonCustomIP)

    $customIPInput = $false

    $buttonCustomIP.Add_Click({
    $customIPInput = $true
    $customIPSubmitButton.Add_Click({
    $systemreservedcheckBox.Checked = $true
    $systemreservedcheckBox.Text = $textboxCustomIP.Text
    $customIPForm.Close()
    })
    $customIPForm.Controls.Add($customIPFlowLayoutPanel)
    $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
    $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
    [void] $customIPForm.ShowDialog()
    })

# Add a button to select all IP addresses
$selectAllButton.Add_Click({
    foreach ($control in $flowLayoutPanel.Controls) {
        if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
            $control.Checked = $true
        }
    }
})
$flowLayoutPanel.Controls.Add($selectAllButton)

$selectedPowerSettings = ""
if ($powerType -eq 1) {
    $selectedPowerSettings = "Plugged-in power settings"
}
elseif ($powerType -eq 2) {
    $selectedPowerSettings = "Unplugged power settings"
}
elseif ($powerType -eq 3) {
   $selectedPowerSettings = "All power settings" 
}

# Add a button to submit the selected IP addresses
<#$submitButton = New-Object System.Windows.Forms.Button
$submitButton.Text = "Submit"#>
$submitButton.Add_Click({
$form.Close()
    Write-Host "Applying $selectedPowerSettings of $powerTimeMinutes on:"
    foreach ($control in $flowLayoutPanel.Controls) {
        if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
            $ip = $control.Text
            $timeout = 150 # Timeout in milliseconds
            $ping = New-Object System.Net.NetworkInformation.Ping
            $reply = $ping.Send($ip, $timeout)
            if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                $numReplied += 1
                try {
                    $numRan += 1
                    Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                    param($powerType, $powerTimeMinutes)
                        Write-Host $env:COMPUTERNAME -ForegroundColor Green

                        if ($powerType -eq 1) {
                            powercfg -change -monitor-timeout-ac $powerTimeMinutes
                            powercfg -change -standby-timeout-ac $powerTimeMinutes
                            }

                        if ($powerType -eq 2) {
                            powercfg -change -monitor-timeout-dc $powerTimeMinutes
                            powercfg -change -standby-timeout-dc $powerTimeMinutes
                        }

                        if ($powerType -eq 3) {
                            powercfg -change -monitor-timeout-ac $powerTimeMinutes
                            powercfg -change -standby-timeout-ac $powerTimeMinutes
                            powercfg -change -monitor-timeout-dc $powerTimeMinutes
                            powercfg -change -standby-timeout-dc $powerTimeMinutes
                        }
                        $numRan += 1

                } -ArgumentList $powerType, $powerTimeMinutes
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
    Write-Host "Number of clients that failed: " -NoNewline
    Write-Host "$numFailed" -ForegroundColor Red
    })
    $flowLayoutPanel.Controls.Add($submitButton)

    $form.Controls.Add($flowLayoutPanel)
    $form.Add_Shown({$form.Activate()})
    [void] $form.ShowDialog()
    start-sleep 2
}

# 7. Enable/Disable Inactivity Monitor
######################################
if ($checkbox7.Checked) {
$clientForm.Close()
    $enableOrDisable = Read-Host "
    Enable/Disable Inactivity Monitor
    _________________________________

        1 = Enable

        2 = Disable

    Enter"
    foreach ($client in $remoteIPAddresses) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        $flowLayoutPanel.Controls.Add($checkbox)
    }

        #Custom IP intake form logic
        $flowLayoutPanel.Controls.Add($systemreservedcheckBox)
        $flowLayoutPanel.Controls.Add($buttonCustomIP)

        $customIPInput = $false

        $buttonCustomIP.Add_Click({
        $customIPInput = $true
        $customIPSubmitButton.Add_Click({
        $systemreservedcheckBox.Checked = $true
        $systemreservedcheckBox.Text = $textboxCustomIP.Text
        $customIPForm.Close()
        })
        $customIPForm.Controls.Add($customIPFlowLayoutPanel)
        $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
        $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
        [void] $customIPForm.ShowDialog()
        })

    # Add a button to select all IP addresses
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to submit the selected IP addresses
    <#$submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"#>
    $submitButton.Add_Click({
    $form.Close()
        Write-Host "Applying Inactivity Monitor Settings...`n"
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 150 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                        param($enableOrDisable)
                        if ($enableOrDisable -eq 1){
                            #Machine Inactivity Limit = 900 
                            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "InactivityTimeoutSecs" -Value 900 -Force
                            Write-Host "Enabling Inactivity Monitor on " -NoNewline
                            Write-Host "$env:computername`n" -ForegroundColor Green
                            }
                        elseif ($enableOrDisable -eq 2) {
                            #Machine Inactivity Limit = 0 
                            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "InactivityTimeoutSecs" -Value 0 -Force
                            Write-Host "Disabling Inactivity Monitor on " -NoNewline
                            Write-Host "$env:computername`n" -ForegroundColor Green
                        }
                            
                        } -ArgumentList $enableOrDisable

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
    })
    $flowLayoutPanel.Controls.Add($submitButton)

    $form.Controls.Add($flowLayoutPanel)
    $form.Add_Shown({$form.Activate()})
    [void] $form.ShowDialog()
    start-sleep 2
}

# 9. Reload CVN Production Scripts
##############################
if ($checkbox9.Checked) {
    $clientForm.Close()
    foreach ($client in $remoteIPAddresses) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        #$checkbox.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 5)
        $flowLayoutPanel.Controls.Add($checkbox)
    }

        #Custom IP intake form logic
        $flowLayoutPanel.Controls.Add($systemreservedcheckBox)
        $flowLayoutPanel.Controls.Add($buttonCustomIP)

        $customIPInput = $false

        $buttonCustomIP.Add_Click({
        $customIPInput = $true
        $customIPSubmitButton.Add_Click({
        $systemreservedcheckBox.Checked = $true
        $systemreservedcheckBox.Text = $textboxCustomIP.Text
        $customIPForm.Close()
        })
        $customIPForm.Controls.Add($customIPFlowLayoutPanel)
        $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
        $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
        [void] $customIPForm.ShowDialog()
        })

    # Add a button to select all IP addresses
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to submit the selected IP addresses
    <#$submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"#>
    $submitButton.Add_Click({
    $form.Close()
        $ReloadScript = Read-Host "Which script do you want to reload?
        `n1 = Script D: CVN_E-S_Setup_Configuration"
        if ($ReloadScript -eq 1) {
        $ScriptOption = "D"
        }
        
        Write-Host "Reloading Production Script $($ScriptOption) on..."
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 150 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                        param($reloadscript)
                            Write-Host $env:COMPUTERNAME -ForegroundColor Green
                            if ($reloadscript -eq 1) {
                            if (Test-Path "C:\Admin Only\Completed\CVN_E-S_Setup_Configuration.ps1") {
                                Move-Item "C:\Admin Only\Completed\CVN_E-S_Setup_Configuration.ps1" "C:\Admin Only\Powershell\Script D" -Force
                                Write-Host "Script D is now loaded"
                            } else {
                                Write-Warning "Script A is already loaded"
                            }
                            }

                            <#if (Test-Path "C:\Admin Only\Completed\PMS501_Disk_Encryption.ps1") {
                                Move-Item "C:\Admin Only\Completed\PMS501_Disk_Encryption.ps1" "C:\Admin Only\Powershell\Script B" -Force
                                Write-Host "Script B is now loaded"
                            } else {
                                Write-Warning "Script B is already loaded"
                            }

                            if (Test-Path "C:\Admin Only\Completed\PMS501_E-S_Setup_Configuration.ps1") {
                                Move-Item "C:\Admin Only\Completed\PMS501_E-S_Setup_Configuration.ps1" "C:\Admin Only\Powershell\Script C" -Force
                                Write-Host "Script C is now loaded`n"
                            } else {
                                Write-Warning "Script C is already loaded`n"
                            }
                            #>
                        } -ArgumentList $ReloadScript
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
}

# 8. Reload LCS Production Scripts
##############################
if ($checkbox8.Checked) {
    $clientForm.Close()
    foreach ($client in $remoteIPAddresses) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        #$checkbox.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 5)
        $flowLayoutPanel.Controls.Add($checkbox)
    }

        #Custom IP intake form logic
        $flowLayoutPanel.Controls.Add($systemreservedcheckBox)
        $flowLayoutPanel.Controls.Add($buttonCustomIP)

        $customIPInput = $false

        $buttonCustomIP.Add_Click({
        $customIPInput = $true
        $customIPSubmitButton.Add_Click({
        $systemreservedcheckBox.Checked = $true
        $systemreservedcheckBox.Text = $textboxCustomIP.Text
        $customIPForm.Close()
        })
        $customIPForm.Controls.Add($customIPFlowLayoutPanel)
        $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
        $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
        [void] $customIPForm.ShowDialog()
        })

    # Add a button to select all IP addresses
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to submit the selected IP addresses
    <#$submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"#>
    $submitButton.Add_Click({
    $form.Close()
        Write-Host "Reloading Production Scripts on..."
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 150 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                            Write-Host $env:COMPUTERNAME -ForegroundColor Green
                            if (Test-Path "C:\Admin Only\Completed\PMS501_BaselineImage_Configuration.ps1") {
                                Move-Item "C:\Admin Only\Completed\PMS501_BaselineImage_Configuration.ps1" "C:\Admin Only\Powershell\Script A" -Force
                                Write-Host "Script A is now loaded"
                            } else {
                                Write-Warning "Script A is already loaded"
                            }

                            if (Test-Path "C:\Admin Only\Completed\PMS501_Disk_Encryption.ps1") {
                                Move-Item "C:\Admin Only\Completed\PMS501_Disk_Encryption.ps1" "C:\Admin Only\Powershell\Script B" -Force
                                Write-Host "Script B is now loaded"
                            } else {
                                Write-Warning "Script B is already loaded"
                            }

                            if (Test-Path "C:\Admin Only\Completed\PMS501_E-S_Setup_Configuration.ps1") {
                                Move-Item "C:\Admin Only\Completed\PMS501_E-S_Setup_Configuration.ps1" "C:\Admin Only\Powershell\Script C" -Force
                                Write-Host "Script C is now loaded`n"
                            } else {
                                Write-Warning "Script C is already loaded`n"
                            }
                        }
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
}

# 10. Run custom command on client
#################################
if ($checkbox10.Checked) {
$clientForm.Close()
    foreach ($client in $remoteIPAddresses) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        $flowLayoutPanel.Controls.Add($checkbox)
    }

        #Custom IP intake form logic
        $flowLayoutPanel.Controls.Add($systemreservedcheckBox)
        $flowLayoutPanel.Controls.Add($buttonCustomIP)

        $customIPInput = $false

        $buttonCustomIP.Add_Click({
        $customIPInput = $true
        $customIPSubmitButton.Add_Click({
        $systemreservedcheckBox.Checked = $true
        $systemreservedcheckBox.Text = $textboxCustomIP.Text
        $customIPForm.Close()
        })
        $customIPForm.Controls.Add($customIPFlowLayoutPanel)
        $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
        $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
        [void] $customIPForm.ShowDialog()
        })

    # Add a button to select all IP addresses
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to submit the selected IP addresses
    <#$submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"#>
    $submitButton.Add_Click({
    $form.Close()
        $elevatedPermission = Read-Host "
        Run a custom command
        ____________________

        Does this command require admin rights?
            1 = yes
        
            2 = no
        Enter"

        if ($elevatedPermission -eq 1) {
            $customCommand = Read-Host "Enter your custom command"
            Write-Host "Running custom command on..."
            foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 150 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                        $numRan += 1
                        $result = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                            param($cmd)
                            Invoke-Expression "$cmd -Force"
                        } -ArgumentList $customCommand
                        Write-Host "$ip" -ForegroundColor Green
                        Write-Host "Output from $ip"
                        Write-Host $result
                        $numRan += 1
                    } catch {
                        Write-Host "Cannot deliver command to $ip"
                    }
                } else {
                    $numFailed += 1
                    Write-Host "$ip is unavailable" -ForegroundColor Red
                }
            }
        }
    }

        elseif ($elevatedPermission -eq 2) {
            $customCommand = Read-Host "Enter your custom command"
            Write-Host "Running custom command on..."
            foreach ($control in $flowLayoutPanel.Controls) {
                if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                    $ip = $control.Text
                    $timeout = 100 # Timeout in milliseconds
                    $ping = New-Object System.Net.NetworkInformation.Ping
                    $reply = $ping.Send($ip, $timeout)
                    if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                        try {
                            $numRan += 1
                            $result = Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                                param($cmd)
                                Invoke-Expression "$cmd"
                            } -ArgumentList $customCommand
                            Write-Host "$ip" -ForegroundColor Green
                            Write-Host "Output from $ip"
                            write-host $result
                            $numRan += 1
                            Start-Sleep 2
                        } catch {
                            Write-Host "Cannot deliver command to $ip"
                        }
                    } else {
                        $numFailed += 1
                        Write-Host "$ip is unavailable" -ForegroundColor Red
                    }
                }
            }
        }
        Write-Host "Number of clients that responded: " -NoNewline 
        Write-Host "$numReplied" -ForegroundColor Green
        Write-Host "Number of clients that ran the script: " -NoNewline 
        Write-Host "$numRan" -ForegroundColor Green
        Write-Host "Number of clients that failed: " -NoNewline
        Write-Host "$numFailed" -ForegroundColor Red
        })
        $flowLayoutPanel.Controls.Add($submitButton)

        $form.Controls.Add($flowLayoutPanel)
        $form.Add_Shown({$form.Activate()})
        [void] $form.ShowDialog()
}

# 15. Reload LCS Production Scripts
##################################
if ($checkbox15.Checked) {
    $clientForm.Close()
    foreach ($client in $remoteIPAddresses) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        #$checkbox.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 5)
        $flowLayoutPanel.Controls.Add($checkbox)
    }

        #Custom IP intake form logic
        $flowLayoutPanel.Controls.Add($systemreservedcheckBox)
        $flowLayoutPanel.Controls.Add($buttonCustomIP)

        $customIPInput = $false

        $buttonCustomIP.Add_Click({
        $customIPInput = $true
        $customIPSubmitButton.Add_Click({
        $systemreservedcheckBox.Checked = $true
        $systemreservedcheckBox.Text = $textboxCustomIP.Text
        $customIPForm.Close()
        })
        $customIPForm.Controls.Add($customIPFlowLayoutPanel)
        $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
        $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
        [void] $customIPForm.ShowDialog()
        })

    # Add a button to select all IP addresses
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to submit the selected IP addresses
    <#$submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"#>
    $submitButton.Add_Click({
    $form.Close()
        Write-Host "Reloading Production Scripts on..."
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 150 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                            Write-Host $env:COMPUTERNAME -ForegroundColor Green
                            if (Test-Path "C:\Admin Only\Completed\PMS501_BaselineImage_Configuration.ps1") {
                                Move-Item "C:\Admin Only\Completed\PMS501_BaselineImage_Configuration.ps1" "C:\Admin Only\Powershell\Script A" -Force
                                Write-Host "Script A is now loaded"
                            } else {
                                Write-Warning "Script A is already loaded"
                            }

                            if (Test-Path "C:\Admin Only\Completed\PMS501_Disk_Encryption.ps1") {
                                Move-Item "C:\Admin Only\Completed\PMS501_Disk_Encryption.ps1" "C:\Admin Only\Powershell\Script B" -Force
                                Write-Host "Script B is now loaded"
                            } else {
                                Write-Warning "Script B is already loaded"
                            }

                            if (Test-Path "C:\Admin Only\Completed\PMS501_E-S_Setup_Configuration.ps1") {
                                Move-Item "C:\Admin Only\Completed\PMS501_E-S_Setup_Configuration.ps1" "C:\Admin Only\Powershell\Script C" -Force
                                Write-Host "Script C is now loaded`n"
                            } else {
                                Write-Warning "Script C is already loaded`n"
                            }
                        }
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
}

# 16. Run scheduled task
##################################
if ($tasksListBox.CheckedItems.Contains("Run Scheduled Task")) {
    $clientForm.Close()
    foreach ($client in $remoteIPAddresses) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        #$checkbox.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 5)
        $flowLayoutPanel.Controls.Add($checkbox)
    }

        #Custom IP intake form logic
        $flowLayoutPanel.Controls.Add($systemreservedcheckBox)
        $flowLayoutPanel.Controls.Add($buttonCustomIP)

        $customIPInput = $false

        $buttonCustomIP.Add_Click({
        $customIPInput = $true
        $customIPSubmitButton.Add_Click({
        $systemreservedcheckBox.Checked = $true
        $systemreservedcheckBox.Text = $textboxCustomIP.Text
        $customIPForm.Close()
        })
        $customIPForm.Controls.Add($customIPFlowLayoutPanel)
        $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
        $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
        [void] $customIPForm.ShowDialog()
        })

    # Add a button to select all IP addresses
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to submit the selected IP addresses
    <#$submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"#>
    $submitButton.Add_Click({
    $form.Close()
    Write-Host "`nAvailable Scheduled Tasks:`n"
    foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 150 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                $tasks = Get-ScheduledTask | Where-Object {$_.TaskPath -eq '\' -and $_.State -ne 'Disabled' -and $_.TaskName -notlike "*Microsoft*"}
                foreach($task in $tasks) {
                Write-Host $task.TaskName -ForegroundColor Cyan
                }
                }
        $scheduledTaskName = Read-Host "`nCopy and paste the task name to run from the list above"
        Write-Host "Running scheduled task '$($scheduledTaskName)' on:"
        
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                        param($taskName)
                            Write-Host $env:COMPUTERNAME -ForegroundColor Green
                            try {
                            Start-ScheduledTask -TaskName $taskName
                            }
                            catch {Write-Host "Could not run scheduled task. Error:" $_.Exception.Message}
                            
                        } -ArgumentList $scheduledTaskName
                    $numRan += 1
                    }
                    catch {
                        Write-Host "Cannot deliver command to $ip" $_.Exception.Message
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
}

# 17. Enable Scheduled task
##################################
if ($tasksListBox.CheckedItems.Contains("Enable Scheduled Task")) {
    $clientForm.Close()
    foreach ($client in $remoteIPAddresses) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        #$checkbox.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 5)
        $flowLayoutPanel.Controls.Add($checkbox)
    }

        #Custom IP intake form logic
        $flowLayoutPanel.Controls.Add($systemreservedcheckBox)
        $flowLayoutPanel.Controls.Add($buttonCustomIP)

        $customIPInput = $false

        $buttonCustomIP.Add_Click({
        $customIPInput = $true
        $customIPSubmitButton.Add_Click({
        $systemreservedcheckBox.Checked = $true
        $systemreservedcheckBox.Text = $textboxCustomIP.Text
        $customIPForm.Close()
        })
        $customIPForm.Controls.Add($customIPFlowLayoutPanel)
        $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
        $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
        [void] $customIPForm.ShowDialog()
        })

    # Add a button to select all IP addresses
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved") {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to submit the selected IP addresses
    <#$submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"#>
    $submitButton.Add_Click({
    $form.Close()
    Write-Host "`nDisabled Scheduled Tasks:`n"
    foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 150 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                $tasks = Get-ScheduledTask | Where-Object {$_.TaskPath -eq '\' -and $_.State -eq 'Disabled' -and $_.TaskName -notlike "*Microsoft*"}
                foreach($task in $tasks) {
                Write-Host $task.TaskName -ForegroundColor Cyan
                }
                }
        $scheduledTaskName = Read-Host "`nCopy and paste the task name to enable from the list above"
        Write-Host "Enabling scheduled task '$($scheduledTaskName)' on:"
        
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                        param($taskName)
                            Write-Host $env:COMPUTERNAME -ForegroundColor Green
                            try {
                            Enable-ScheduledTask -TaskName $taskName
                            }
                            catch {Write-Host "Could not run scheduled task. Error:" $_.Exception.Message}
                            
                        } -ArgumentList $scheduledTaskName
                    $numRan += 1
                    }
                    catch {
                        Write-Host "Cannot deliver command to $ip" $_.Exception.Message
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
}


})

$flowLayoutPanelOptions.Controls.Add($submitButtonClient)
# Show the form
[void]$clientForm.ShowDialog()

Read-Host "`nPress any key to exit"   