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
#  Eval-STIG System Check #
#        and Scan         #
#                         #
# # # # # # # # # # # # # #
`n`n"

Write-Host "Check commonly changed Eval-STIG policies. Reload script D and run compliance scan" -ForegroundColor Yellow
Write-host "`nNote: A bug is preventing the DOTNET form from closing at the end of this script. It does not impact script execution,`nclick continue and close the PowerShell window"
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
                    Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                    $defenderSmartScreenParam = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" 
                    $defenderSmartScreen = $defenderSmartScreenParam.EnableSmartScreen
                    $inactivityMonitorParam = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "InactivityTimeoutSecs" 
                    $inactivityTimeoutSecs = $inactivityMonitorParam.InactivityTimeoutSecs
                    $maxPswdAgeParam = net accounts | findstr /C:"Maximum password age" 
                    $lockoutThresholdParam = net accounts | findstr /C:"Lockout threshold" 
                    $UACParam = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" 
                    $UAC = $UACParam.ConsentPromptBehaviorAdmin
                    $autoAdminLogonParam = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -ErrorAction SilentlyContinue
                    $defaultPasswordParam = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultPassword" -ErrorAction SilentlyContinue
                    $defaultUserNameParam = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "DefaultUserName" -ErrorAction SilentlyContinue
                    $legalLogonNoticeParam = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "legalnoticecaption" 
                    $egalLogonBannerParam = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LegalNoticeText" 
                    $word2000FilesParam = Get-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Word\Security\FileBlock" -Name "word2000files" 
                    $word2000Files = $word2000FilesParam.word2000files
                    $xl2MacrosParam = Get-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Office\16.0\Excel\Security\FileBlock" -Name "xl2macros" 
                    $xl2Macro = $xl2MacrosParam.xl2macros


                        Write-Host "
-------------------------------------------------------------------------------------------------------------------"
Write-Host "                                                    $env:computername" -ForegroundColor Yellow
write-host "-------------------------------------------------------------------------------------------------------------------
"
                        if ($defenderSmartScreen -eq 1) {
                            write-host "`nDefender smart screen is enabled. SAT" -ForegroundColor Green
                        }
                        else {
                            Write-Host "`nDefender Smart Screen is NOT enabled" -ForegroundColor Red -BackgroundColor White
                        }

                        if ($inactivityTimeoutSecs -eq 0) {
                            Write-Host "`nInactivity Monitor is disabled" -ForegroundColor Red -BackgroundColor White
                        }
                        elseif ($inactivityTimeoutSecs -le 900) {
                            Write-Host "`nInactivity Monitor is within 15 minutes. SAT" -ForegroundColor Green
                        }

                        if ($legalLogonNoticeParam -eq "") {
                            Write-Host "`nLegal Logon Notice is blank" -ForegroundColor Red -BackgroundColor White
                        }
                        else {
                            Write-Host "`nLegal Logon Notice is set. SAT" -ForegroundColor Green
                        }

                        if ($legalLogonBannerParam -eq "") {
                            Write-Host "`nLegal Logon Banner is blank" -ForegroundColor Red -BackgroundColor White
                        }
                        else {
                            Write-Host "`nLegal Logon Banner is set. SAT" -ForegroundColor Green
                        }

                        if ($word2000Files -eq 2) {
                            Write-Host "`nThe spot check of Word file block settings is correct. SAT" -ForegroundColor Green
                        }
                        else {
                            Write-Host "`nA spot check of the Word file block settings failed" -ForegroundColor Red -BackgroundColor White
                        }

                        if ($xl2Macro -eq 2) {
                            Write-Host "`nThe spot check of Excel file block settings is correct. SAT" -ForegroundColor Green
                        }
                        else {
                            Write-Host "`nA spot check of the Excel file block settings failed" -ForegroundColor Red -BackgroundColor White
                        } 

                        Write-Host "
------------------------------        
         MANUAL CHEKS
------------------------------
"

                        Write-Host "$maxPswdAgeParam" -ForegroundColor Yellow
                        Write-Host "Confirm value is (<= 60)"

                        Write-Host "`n$lockoutThresholdParam" -ForegroundColor Yellow
                        Write-Host "Confirm value is (<= 3)"

                        Write-Host "`nUAC is:                                               $UAC" -ForegroundColor Yellow
                        Write-Host "Confirm value is (2)"

                        
                        
                    }

                    write-host "`n"
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
    $continueEvalStigScan = Read-Host "`n
                        Did checks pass?
                        
                            1 = continue to Eval-STIG Scan
                            
                            2 = Exit script
                        Enter"

                        if ($continueEvalStigScan -eq 1) {
                            write-host "Moving script D back on clients...`n" -ForegroundColor Yellow
                            foreach ($control in $flowLayoutPanel.Controls) {
                            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                                $ip = $control.Text
                                $timeout = 100 # Timeout in milliseconds
                                $ping = New-Object System.Net.NetworkInformation.Ping
                                $reply = $ping.Send($ip, $timeout)
                                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                                    try {
                                    $scriptPath = "C:\Admin Only\Batch\moveScriptDBack.bat"
                                    Write-Host "Running $scriptPath on $ip..."
                                    Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                                    param($scriptPath) & $scriptPath | Out-String} -ArgumentList "$scriptPath"
                                    Write-Host "`nSuccess" -ForegroundColor Green
                                    $numRan += 1
                                    }
                                    catch {
                                            Write-Host "Cannot deliver script path to $ip"
                                        }
                                }
                                else {
                                    Write-Host "$ip is unavailable" -ForegroundColor Red
                                }
                            }

                            
                            }

                            write-host "`n
---------------------------------"
Write-Host "Number of clients that responded: " -NoNewline 
Write-Host "$numReplied" -ForegroundColor Green
Write-Host "Number of clients that ran the script: " -NoNewline 
Write-Host "$numRan" -ForegroundColor Green
Write-Host "Number of clients that failed: " -NoNewline
Write-Host "$numFailed" -ForegroundColor Red

                            $restartClients = Read-Host "
                            Restart clients to begin Eval-STIG scan
                            
                                1 = Restart

                                2 = Exit

                            Enter"

                            if ($restartClients -eq 1) {
                            write-host "Restarting...`n"
                            foreach ($control in $flowLayoutPanel.Controls) {
                            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                                $ip = $control.Text
                                $timeout = 100 # Timeout in milliseconds
                                $ping = New-Object System.Net.NetworkInformation.Ping
                                $reply = $ping.Send($ip, $timeout)
                                if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                                    try {
                                        Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                                            Write-Host $env:COMPUTERNAME -ForegroundColor Green
                                            Restart-Computer -Force # Restart client
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
                            else {
                                exit
                            }
                            
                            
                            
                               
                        }
                        else {
                        Write-Host "Exiting script..."
                        exit
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
    write-host "No valid selection made"
    start-sleep 5
}