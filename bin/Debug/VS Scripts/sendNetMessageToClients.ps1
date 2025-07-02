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
# # # # # # # # # # # # # # # # #
#                               #
#   Remotely message a client   #
#                               #
# # # # # # # # # # # # # # # # #
`n`n"

Write-Host "SEND A MESSAGE TO SELECTED CLIENTS`n`n" -ForegroundColor Yellow


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

# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the message options form
$messageOptionsForm = New-Object System.Windows.Forms.Form
$messageOptionsForm.Text = "Select message option"
$messageOptionsForm.Size = New-Object System.Drawing.Size(350, 500)
$messageOptionsForm.StartPosition = "CenterScreen"

# Create the message intake form
$messageInputForm = New-Object System.Windows.Forms.Form
$messageInputForm.Text = "Enter message"
$messageInputForm.Size = New-Object System.Drawing.Size(350, 500)
$messageInputForm.StartPosition = "CenterScreen"


# Create the computer info options form
$ComputerInfoForm = New-Object System.Windows.Forms.Form
$ComputerInfoForm.Text = "Select Computer Info"
$ComputerInfoForm.Size = New-Object System.Drawing.Size(350, 500)
$ComputerInfoForm.StartPosition = "CenterScreen"

# Create the custom IP textbox form
$customIPForm = New-Object System.Windows.Forms.Form
$customIPForm.Text = "Enter IP Address"
$customIPForm.Size = New-Object System.Drawing.Size(300, 400)
$customIPForm.StartPosition = "CenterScreen"

# Add a label to message intake form
$userMessageLabel = New-Object System.Windows.Forms.Label
$userMessageLabel.Text = "Enter your message"
$userMessageLabel.Width = 200
$userMessageLabel.Font = New-Object System.Drawing.Font($userMessageLabel.Font.FontFamily, 11)
$userMessageLabel.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 80)

# Add a label to message options form
$messageOptionsLabel = New-Object System.Windows.Forms.Label
$messageOptionsLabel.Text = "
Select a message option
____________________"
$messageOptionsLabel.Width = 240
$messageOptionsLabel.Height = 100
$messageOptionsLabel.Font = New-Object System.Drawing.Font($userMessageLabel.Font.FontFamily, 12)
$messageOptionsLabel.Margin = New-Object System.Windows.Forms.Padding(10, 30, 10, 6)

# Create the client form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select Remote Computers"
$form.Size = New-Object System.Drawing.Size(350, 500)
$form.StartPosition = "CenterScreen"

# Create a FlowLayoutPanel for message options with AutoScroll enabled
$messageOptionsFlowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$messageOptionsFlowLayoutPanel.AutoScroll = $true
$messageOptionsFlowLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$messageOptionsFlowLayoutPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$messageOptionsFlowLayoutPanel.WrapContents = $false

# Create a FlowLayoutPanel for message options with AutoScroll enabled
$userMessageIntakeFlowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$userMessageIntakeFlowLayoutPanel.AutoScroll = $true
$userMessageIntakeFlowLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$userMessageIntakeFlowLayoutPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$userMessageIntakeFlowLayoutPanel.WrapContents = $false


# Create a FlowLayoutPanel for computer info options with AutoScroll enabled
$ComputerInfoFlowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$ComputerInfoFlowLayoutPanel.AutoScroll = $true
$ComputerInfoFlowLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$ComputerInfoFlowLayoutPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$ComputerInfoFlowLayoutPanel.WrapContents = $false

# Create a FlowLayoutPanel for custom IP with AutoScroll enabled
$customIPFlowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$customIPFlowLayoutPanel.AutoScroll = $true
$customIPFlowLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$customIPFlowLayoutPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$customIPFlowLayoutPanel.WrapContents = $false

# Create a FlowLayoutPanel for clients with AutoScroll enabled
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

$whichBatch = Read-Host "Select batch number"

if ($whichBatch -le 3) {


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

# Add checkboxes to message options form
$checkBox1 = New-Object System.Windows.Forms.CheckBox
$checkBox1.Text = "Send your own message"
$checkBox1.AutoSize = $false
$checkBox1.width = 200
$checkBox1.Margin = New-Object System.Windows.Forms.Padding(10,10,10,10)

$checkBox2 = New-Object System.Windows.Forms.CheckBox
$checkBox2.Text = "Display Remote Host Info"
$checkBox2.AutoSize = $false
$checkBox2.width = 200
$checkBox2.Margin = New-Object System.Windows.Forms.Padding(10,10,10,10)

$checkBox3 = New-Object System.Windows.Forms.CheckBox
$checkBox3.Text = "Computer Name"
$checkBox3.AutoSize = $false
$checkBox3.width = 200
$checkBox3.Margin = New-Object System.Windows.Forms.Padding(10,10,10,10)

$checkBox4 = New-Object System.Windows.Forms.CheckBox
$checkBox4.Text = "Mac Address"
$checkBox4.AutoSize = $false
$checkBox4.width = 200
$checkBox4.Margin = New-Object System.Windows.Forms.Padding(10,10,10,10)

$systemreservedcheckBox = New-Object System.Windows.Forms.CheckBox
$systemreservedcheckBox.Text = "Reserved"
$systemreservedcheckBox.Enabled = $false
$systemreservedcheckBox.AutoSize = $false
$systemreservedcheckBox.width = 200
$systemreservedcheckBox.Margin = New-Object System.Windows.Forms.Padding(10,10,10,10)

# Add textbox to message input form
$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Location = New-Object System.Drawing.Point(10,10)
$textbox.Multiline = $true
$textbox.Size = New-Object System.Drawing.Size(340,500)
$textbox.Height = 150

# Add textbox to message input form
$textboxCustomIP = New-Object System.Windows.Forms.TextBox
$textboxCustomIP.Location = New-Object System.Drawing.Point(10,10)
$textboxCustomIP.Multiline = $true
$textboxCustomIP.Size = New-Object System.Drawing.Size(200,200)
$textboxCustomIP.Height = 80

$textBoxLabel = New-Object System.Windows.Forms.Label
$textBoxLabel.Text = "Enter IP address"
$textBoxLabel.Width = 200
$textBoxLabel.Font = New-Object System.Drawing.Font($userMessageLabel.Font.FontFamily, 11)
$textBoxLabel.Margin = New-Object System.Windows.Forms.Padding(10, 10, 10, 80)

# Add submit button to message input form
$textboxSubmitButton = New-Object System.Windows.Forms.Button
$textboxSubmitButton.Text = "Submit"
$textboxSubmitButton.Width = 80
$textboxSubmitButton.Margin = New-Object System.Windows.Forms.Padding(10,110,10,10)

# Add submit button for computer info options
$computerInfoSubmitButton = New-Object System.Windows.Forms.Button
$computerInfoSubmitButton.Text = "Submit"
$computerInfoSubmitButton.Width = 80
$computerInfoSubmitButton.Margin = New-Object System.Windows.Forms.Padding(10,110,10,10)

# Add button to select custom IP option
$buttonCustomIP = New-Object System.Windows.Forms.Button
$buttonCustomIP.Text = "Enter a different IP"
$buttonCustomIP.Width = 120
$buttonCustomIP.Margin = New-Object System.Windows.Forms.Padding(10,20,10,20)

# Button to add custom IP address to object
$customIPSubmitButton = New-Object System.Windows.Forms.Button
$customIPSubmitButton.Text = "Done"
$customIPSubmitButton.Width = 80
$customIPSubmitButton.Margin = New-Object System.Windows.Forms.Padding(10,110,10,10)

# Add flow layout panel to message options form
$messageOptionsForm.Controls.Add($messageOptionsFlowLayoutPanel)
$messageOptionsFlowLayoutPanel.Controls.Add($messageOptionsLabel)
$messageOptionsFlowLayoutPanel.Controls.Add($checkBox1)
$messageOptionsFlowLayoutPanel.Controls.Add($checkBox2)
$messageOptionsFlowLayoutPanel.Controls.Add($messageOptionsSubmitButton)

$messageOptionsSubmitButton = New-Object System.Windows.Forms.Button
$messageOptionsSubmitButton.Text = "Submit"
$messageOptionsSubmitButton.Width = 80
$messageOptionsSubmitButton.Margin = New-Object System.Windows.Forms.Padding(10,180,10,10)


#Point of Entry for script
$messageOptionsSubmitButton.Add_Click({
if ($checkBox1.Checked) {
$messageOptionsForm.Close()
$textboxSubmitButton.Add_click({
$messageInputForm.Close()
$userMessage = $textbox.Text
foreach ($client in $batch) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        $checkbox.Width = 200
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
    $selectAllButton = New-Object System.Windows.Forms.Button
    $selectAllButton.Text = "Select All"
    $selectAllButton.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Text -notlike "Reserved" ) {
                $control.Checked = $true
            }
        }
    })
    $flowLayoutPanel.Controls.Add($selectAllButton)

    # Add a button to submit the selected IP addresses
    $submitButton = New-Object System.Windows.Forms.Button
    $submitButton.Text = "Submit"
    $submitButton.Add_Click({
        Write-Host "All messages will start with: 'Message from ETC administrator'"
        Write-Host "Sending message to:"
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked -or $customIPInput -eq $true) {
                $ip = $control.Text
                

                $timeout = 120 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    try {
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                            param($userMessage)
                                $fullMessage = "Message from ETC administrator:`n`n$userMessage"
                                write-host "$env:COMPUTERNAME" -ForegroundColor Green
                                msg * $fullMessage
                        } -ArgumentList $userMessage
                        }
                    catch {
                        Write-Host "Cannot deliver command to $ip"
                    }
                    }
               
                else {
                    Write-Host "$ip is unavailable" -ForegroundColor Red
                }
            }
        }
        write-host "`nAll messages sent"
        Start-Sleep 2
        $form.Close()
    })
    $flowLayoutPanel.Controls.Add($submitButton)

    $form.Controls.Add($flowLayoutPanel)
    $form.Add_Shown({$form.Activate()})
    [void] $form.ShowDialog()
    })
    $messageInputForm.Controls.Add($userMessageIntakeFlowLayoutPanel)
    $userMessageIntakeFlowLayoutPanel.Controls.Add($userMessageLabel)
    $userMessageIntakeFlowLayoutPanel.Controls.Add($textbox)
    $userMessageIntakeFlowLayoutPanel.Controls.Add($textboxSubmitButton)
    [void] $messageInputForm.ShowDialog()
    }

    
            

if ($checkBox2.Checked) {
$messageOptionsForm.Close()
$computerInfoSubmitButton.Add_Click({
foreach ($client in $batch) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $client
        $checkbox.Width = 200
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
    $ComputerInfoForm.Close()
    })
    $customIPForm.Controls.Add($customIPFlowLayoutPanel)
    $customIPFlowLayoutPanel.Controls.Add($textboxCustomIP)
    $customIPFlowLayoutPanel.Controls.Add($customIPSubmitButton)
    [void] $customIPForm.ShowDialog()
    })

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
        Write-Host "All messages will start with: 'Message from ETC administrator'"
        Write-Host "Sending message to:"
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                $ip = $control.Text
                $timeout = 120 # Timeout in milliseconds
                $ping = New-Object System.Net.NetworkInformation.Ping
                $reply = $ping.Send($ip, $timeout)
                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                    try {
                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                                $fullMessage = "Message from ETC administrator:`n`n"
                                write-host "$env:COMPUTERNAME" -ForegroundColor Green
                                msg * $env:COMPUTERNAME
                        } 
                        }
                    catch {
                        Write-Host "Cannot deliver command to $ip"
                    }
                    }
               
                else {
                    Write-Host "$ip is unavailable" -ForegroundColor Red
                }
            }
        }
        write-host "`nAll messages sent"
        Start-Sleep 2
        $form.Close()
    })
    $flowLayoutPanel.Controls.Add($submitButton)

    $form.Controls.Add($flowLayoutPanel)
    $form.Add_Shown({$form.Activate()})
    [void] $form.ShowDialog()
        })
    $ComputerInfoForm.Controls.Add($ComputerInfoFlowLayoutPanel)
    $ComputerInfoFlowLayoutPanel.Controls.Add($checkBox3)
    $ComputerInfoFlowLayoutPanel.Controls.Add($computerInfoSubmitButton)
    [void] $ComputerInfoForm.ShowDialog()

        }
            
        })
        
        
    $messageOptionsFlowLayoutPanel.Controls.Add($messageOptionsSubmitButton)
    [void] $messageOptionsForm.ShowDialog()
    }
    else {
    Write-Warning "Your selection was not valid"
    }
    Read-Host "`nPress any key to exit"