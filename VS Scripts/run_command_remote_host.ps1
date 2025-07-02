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


Write-Host "
# # # # # # # # # # # # # #
#                         #
#  Run a Remote Command   #
#                         #
# # # # # # # # # # # # # #
`n`n"

Write-Host "RUN A COMMAND ON REMOTE HOST `n`n" -ForegroundColor Yellow

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

# Create the client form
$clientForm = New-Object System.Windows.Forms.Form
$clientForm.Text = "Select Command"
$clientForm.Size = New-Object System.Drawing.Size(400, 520)
$clientForm.StartPosition = "CenterScreen"

# Create a FlowLayoutPanel with AutoScroll enabled
$flowLayoutPanelOptions = New-Object System.Windows.Forms.FlowLayoutPanel
$flowLayoutPanelOptions.AutoScroll = $true
$flowLayoutPanelOptions.Dock = [System.Windows.Forms.DockStyle]::Fill
$flowLayoutPanelOptions.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$flowLayoutPanelOptions.WrapContents = $false

# Create a label
$label1 = New-Object System.Windows.Forms.Label
$label1.Text = "
Can be combined
________________________________"
$label1.Font = New-Object System.Drawing.Font($label1.Font.FontFamily, 11)
$label1.AutoSize = $true  # This makes the label size adjust to the text
$label1.Margin = New-Object System.Windows.Forms.Padding(8, -20, 2, -40)  # (0-left margin, 0-top margin, 0-right margin, 0-bottom margin)

# Create a label
$label1Disclaimer = New-Object System.Windows.Forms.Label
$label1Disclaimer.Text = "Disclaimer: Combine feature is in beta mode and may not function properly"
$label1Disclaimer.Font = New-Object System.Drawing.Font($label1Disclaimer.Font.FontFamily, 7.5)
$label1Disclaimer.ForeColor = [System.Drawing.Color]::Red
$label1Disclaimer.AutoSize = $true  # This makes the label size adjust to the text
$label1Disclaimer.Margin = New-Object System.Windows.Forms.Padding(8, -15, 2, -20)

# Create a label
$label1Line = New-Object System.Windows.Forms.Label
$label1Line.Text = "
_______________________________________________"
$label1Line.AutoSize = $true  # This makes the label size adjust to the text
$label1Line.Margin = New-Object System.Windows.Forms.Padding(10, -50, 2, 0)

# Create the client form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select Remote Computers"
$form.Size = New-Object System.Drawing.Size(400, 520)
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

$whichBatchNumber = Read-Host "Select batch number"

if ($whichBatchNumber -le 3) {

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
    
    $checkbox1 = New-Object System.Windows.Forms.CheckBox
    $checkbox1.Text = "Restart client(s)"
    $checkbox1.AutoSize = $false
    $checkbox1.Width = 360 
    $checkbox1.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 14)

    $checkbox2 = New-Object System.Windows.Forms.CheckBox
    $checkbox2.Text = " End a task on client(s). Task name must be provided"
    $checkbox2.AutoSize = $false
    $checkbox2.Width = 360  
    $checkbox2.Margin = New-Object System.Windows.Forms.Padding(10, 12, 10, 10)

    $checkbox3 = New-Object System.Windows.Forms.CheckBox
    $checkbox3.Text = "Enable/Disable Auto_admin_logon"
    $checkbox3.AutoSize = $false
    $checkbox3.Width = 360  
    $checkbox3.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

    $checkbox4 = New-Object System.Windows.Forms.CheckBox
    $checkbox4.Text = "Enable/Disable Defender Smartscreen blocking"
    $checkbox4.AutoSize = $false
    $checkbox4.Width = 360  
    $checkbox4.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

    $checkbox5 = New-Object System.Windows.Forms.CheckBox
    $checkbox5.Text = "Start a process. Filepath required"
    $checkbox5.AutoSize = $false
    $checkbox5.Width = 360  
    $checkbox5.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

    $checkbox6 = New-Object System.Windows.Forms.CheckBox
    $checkbox6.Text = "Change Power and Sleep settings"
    $checkbox6.AutoSize = $false
    $checkbox6.Width = 360  
    $checkbox6.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

    $checkbox7 = New-Object System.Windows.Forms.CheckBox
    $checkbox7.Text = "Enable/Disable Inactivity Monitor"
    $checkbox7.AutoSize = $false
    $checkbox7.Width = 360  
    $checkbox7.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

    $checkbox8 = New-Object System.Windows.Forms.CheckBox
    $checkbox8.Text = "Run a custom command"
    $checkbox8.AutoSize = $false
    $checkbox8.Width = 360  
    $checkbox8.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)

    # Add the controls to the FlowLayoutPanel in the desired order
    #$flowLayoutPanel.Controls.Add($label1)
    #$flowLayoutPanel.Controls.Add($labelLine)
    $flowLayoutPanelOptions.Controls.Add($checkbox1)
    $flowLayoutPanelOptions.Controls.Add($label1)
    #$flowLayoutPanelOptions.Controls.Add($label1Line)
    $flowLayoutPanelOptions.Controls.Add($label1Disclaimer)
    $flowLayoutPanelOptions.Controls.Add($checkbox2)
    $flowLayoutPanelOptions.Controls.Add($checkbox3)
    $flowLayoutPanelOptions.Controls.Add($checkbox4)
    $flowLayoutPanelOptions.Controls.Add($checkbox5) 
    $flowLayoutPanelOptions.Controls.Add($checkbox6)
    $flowLayoutPanelOptions.Controls.Add($checkbox7)
    $flowLayoutPanelOptions.Controls.Add($checkbox8)

    
    

    # Add the FlowLayoutPanel to the form
    $clientForm.Controls.Add($flowLayoutPanelOptions)

    # Show the form
    #$clientForm.Add_Shown({$clientForm.Activate()})
    #$clientForm.ShowDialog()


## CONDITIONS TO RUN COMMANDS ##

# 1. Restart client
###################
# Add a button to submit the selected command options
$submitButtonClient = New-Object System.Windows.Forms.Button
$submitButtonClient.Text = "Submit"
$submitButtonClient.Add_Click({
if ($checkbox1.Checked) {
    $clientForm.Close()
    foreach ($client in $batch) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        $checkbox.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 10)
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
                            Restart-Computer -Force # Restart client
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

    

# 2. Kill task on client
########################
if ($checkbox2.Checked) {
$clientForm.Close()
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
    $form.Close()
        $taskName = Read-Host "`nEnter task name to end. Ex: etc, msedge, winword"
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 150 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    $numReplied += 1
                    try {
                        Write-Host "Killing $taskName on..."
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                                param($task)
                                Write-Host $env:COMPUTERNAME -ForegroundColor Green
                                Stop-Process -Name $task -Force
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
                        param($whichBatchNumber, $enableOrDisable)
                            Write-Host $env:COMPUTERNAME -ForegroundColor Green
                            if ($whichBatchNumber -eq 1 -or $whichBatchNumber -eq 2) {
                            if ($enableOrDisable -eq 1) {
                            # Set AutoLogon
                            $DefaultRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                            $registryValue_DU = Get-ItemProperty -Path "$DefaultRegistryPath" -Name "DefaultUserName"
                            $registryValue_PW = Get-ItemProperty -Path "$DefaultRegistryPath" -Name "DefaultPassword"

                            if ($registryValue_DU -ne $null) {
                                # Removes any previous Auto admin logon registry values
                                Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName"
                                Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword"

                                # Creates new registry values for Auto admin logon
                                New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "LCS" -Force
                                New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force

                                # Enables Auto admin logon
                                Set-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

                                Write-Host "Removing old registry entries. `n`nSetting AutoLogon for LCS.`n"
                            } else {
                                # Creates new registry values for Auto admin logon
                                New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "LCS" -Force
                                New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force

                                # Enables Auto admin logon
                                Set-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

                                Write-Host "Setting AutoLogon for LCS."
                                Start-Sleep 2
                                        }
                                    }
                            elseif ($enableOrDisable -eq 2) {
                                $DefaultRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                                $registryValue_DU = Get-ItemProperty -Path "$DefaultRegistryPath" -Name "DefaultUserName"
                                $registryValue_PW = Get-ItemProperty -Path "$DefaultRegistryPath" -Name "DefaultPassword"

                                if ($registryValue_DU -ne $null) {
                                    # Removes any previous Auto admin logon registry values
                                    Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName"
                                    Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword"

                                    # Disables Auto admin logon
                                    Remove-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Force

                                    Write-Host "Removing old registry entries. `n`nRemoving and disabling AutoLogon.`n"
                                } else {
                                    # Removes any previous Auto admin logon registry values
                                    Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Force
                                    Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword"  -Force 

                                    # Enables Auto admin logon
                                    Remove-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Force

                                    Write-Host "Removing and disabling AutoLogon."
                                    Start-Sleep 2
                                        }
                                    }
                                }

                                if ($whichBatchNumber -eq 3) {
                                    if ($enableOrDisable -eq 1) {
                                    $DefaultRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                                    $registryValue_DU = Get-ItemProperty -Path "$DefaultRegistryPath" -Name "DefaultUserName" -ErrorAction SilentlyContinue
                                    $registryValue_PW = Get-ItemProperty -Path "$DefaultRegistryPath" -Name "DefaultPassword" -ErrorAction SilentlyContinue

                                    if ($registryValue_DU -ne $null) {
                                        # Removes any previous Auto admin logon registry values
                                        Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -ErrorAction SilentlyContinue
                                        Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -ErrorAction SilentlyContinue

                                        # Creates new registry values for Auto admin logon
                                        New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "CVN" -Force
                                        New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force

                                        # Enables Auto admin logon
                                        Set-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

                                        Write-Host "Removing old registry entries. `n`nSetting AutoLogon for CVN.`n"
                                    } else {
                                        # Creates new registry values for Auto admin logon
                                        New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "CVN" -Force
                                        New-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force

                                        # Enables Auto admin logon
                                        Set-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Value "1" -Force

                                        Write-Host "Adding new AutoLogon registry entries. Setting AutoLogon for CVN."
                                        Start-Sleep 2
                                        }
                                    }
                                    elseif ($enableOrDisable -eq 2) {
                                        $DefaultRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                                        $registryValue_DU = Get-ItemProperty -Path "$DefaultRegistryPath" -Name "DefaultUserName"
                                        $registryValue_PW = Get-ItemProperty -Path "$DefaultRegistryPath" -Name "DefaultPassword"

                                        if ($registryValue_DU -ne $null) {
                                            # Removes any previous Auto admin logon registry values
                                            Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName"
                                            Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword"

                                            # Disables Auto admin logon
                                            Remove-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Force

                                            Write-Host "Removing old registry entries. `n`nRemoving and disabling AutoLogon.`n"
                                        } else {
                                            # Creates new registry values for Auto admin logon
                                            Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultUserName" -Value "CVN" -Force -ErrorAction SilentlyContinue
                                            Remove-ItemProperty -Path $DefaultRegistryPath -Name "DefaultPassword" -Value "L-3Communicati0ns!" -Force -ErrorAction SilentlyContinue

                                            # Enables Auto admin logon
                                            Remove-ItemProperty -Path $DefaultRegistryPath -Name "AutoAdminLogon" -Force

                                            Write-Host "Removing and disabling AutoLogon."
                                            Start-Sleep 2
                                            }
                                        }
                                    }
                                    } -ArgumentList $whichBatchNumber, $enableOrDisable
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
$submitButton = New-Object System.Windows.Forms.Button
$submitButton.Text = "Submit"
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

# 8. Run custom command on client
#################################
if ($checkbox8.Checked) {
$clientForm.Close()
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
})
$flowLayoutPanelOptions.Controls.Add($submitButtonClient)
# Show the form
[void]$clientForm.ShowDialog()

#>
Read-Host "`nPress any key to exit"
}
else {
Write-Warning "A valid command type was not selected."
Start-Sleep 5
}
                        