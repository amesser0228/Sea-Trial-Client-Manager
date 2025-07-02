# Checks if the script is running as an administrator #
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

<#DEVELOPED BY ANDREW MESSER

<# 
    PREAMBLE
This script performs a number of setup operations for the MSC Sea Trial Team.
1. Adds network printer to trial batch
2. Sets printer to default
#>

Write-Host "
# # # # # # # # # # # # # # #
#                           #
#    Add Network Printer    #
#                           #
# # # # # # # # # # # # # # #
`n`n"

Write-Host "Add network printer to clients and set as default `n`n" -ForegroundColor Yellow


<# DEVELOPED BY ANDREW MESSER

SYNOPSIS:

    1. QUERIES PRINTERS INSTALLED ON HOST. 
    2. IF NON-VIRTUAL PRINTER LIST < 1, QUERIES AND ADDS NETWORK PRINTER HOST ID: 192.168.56.150 (MOB).
    3. SETS PRINTER AS DEFAULT.

    MOB Printer - 192.168.56.150
    MAR Printer 192.168.56.226
#>

# Define the list of remote clients

#$whichBatch = read-host "
#Which batch is this for?

 #   1 = MOB
  #  2 = MAR
   # 3 = CVN

#Enter batch number"

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

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select Remote Computers"
$form.Size = New-Object System.Drawing.Size(400, 500)
$form.StartPosition = "CenterScreen"

# Create a FlowLayoutPanel with AutoScroll enabled
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

$whichBatchNumber = Read-Host "Select batch number"

if ($whichBatchNumber -le 3) {

$securePassword = ConvertTo-SecureString "L-3Communicati0ns!" -AsPlainText -Force
$lcsCredential = New-Object System.Management.Automation.PSCredential ("LCS", $securePassword)
$cvnCredential = New-Object System.Management.Automation.PSCredential ("CVN", $securePassword)


#Get batch and credential
if ($whichBatchnumber -eq 1) {
        $batch = $mobClients 
        $credential = $lcsCredential
        $printerName = "Brother HL-L2370DW series Printer"
        $printerPath = "\\192.168.56.150\Brother HL-L2370DW series Printer"
        $driverName = "Microsoft IPP Class Driver"
        }
    elseif ($whichBatchNumber -eq 2) {
        $batch = $marClients
        $credential = $lcsCredential
        $printerName = "Brother HL-L2370DW series Printer"
        $printerPath = "\\192.168.56.150\Brother HL-L2370DW series Printer"
        $driverName = "Microsoft IPP Class Driver"
        }
    elseif ($whichBatchNumber -eq 3) {
        $batch = $cvnClients
        $credential = $cvnCredential
        $printerName = "Brother HL-L2370DW series Printer"
        $printerPath = "\\192.168.56.150\Brother HL-L2370DW series Printer"
        $driverName = "Microsoft IPP Class Driver"
        }

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

foreach ($client in $batch) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $client
    $checkbox.AutoSize = $true
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
    Write-Host "Adding printer..."
    foreach ($control in $flowLayoutPanel.Controls) {
        if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
            $ip = $control.Text
            $timeout = 150 # Timeout in milliseconds
            $ping = New-Object System.Net.NetworkInformation.Ping
            $reply = $ping.Send($ip, $timeout)
            if ($reply.Status -eq [System.Net.NetworkInformation.IPStatus]::Success) {
                $numReplied += 1
            try {
                Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock { Write-Host $env:COMPUTERNAME -ForegroundColor Green }
                Invoke-Command -ComputerName $ip -Credential $credential -ScriptBlock {
                param($printerName, $printerPath, $driverName)
                 # Get the list of installed printers excluding virtual printers
                 $printers = Get-Printer | Where-Object { $_.Name -notmatch "Microsoft Print to PDF|OneNote (Desktop)|OneNote for Windows10||Send To OneNote 2016|Fax|Microsoft XPS Document Writer" }

                    if ($printers.Count -lt 1) {
            # Add printer port
            Add-PrinterPort -Name $printerPath -PrinterHostAddress "192.168.56.150" -ErrorAction SilentlyContinue
            $existingPort = Get-PrinterPort | Where-Object {$_.PortName -eq $portName}
            if ($existingPort) {
            Write-Host "Printer port '$printerPath' already exists. Continuing to add printer..." -ForegroundColor Yellow
            }

            Add-PrinterDriver -Name $driverName

            # Add the printer
            Add-Printer -Name $printerName -PortName $printerPath -DriverName $driverName

            # Set Printer as default
             #$printerName = "Brother HL-L2370DW series Printer"
             $WshNetwork = New-Object -ComObject WScript.Network
             $WshNetwork.SetDefaultPrinter($printerName)
             $existingPrinter = Get-Printer | Where-Object {$_.Name -eq $printerName}
             if ($existingPrinter) {
             Write-Host "`nSuccess: $printerName added to $ENV:COMPUTERNAME" 
             }
             else {
             Write-Warning "Could not add $printerName to $ENV:COMPUTERNAME"
             }
             }
             } -ArgumentList $printerName, $printerPath, $driverName
             }catch {
             
                    Write-Host "cannot deliver command to $ip"
                    }
                  }
               }
           }
       })
        $flowLayoutPanel.Controls.Add($submitButton)
        $form.Controls.Add($flowLayoutPanel)
        $form.Add_Shown({$form.Activate()})
        [void] $form.ShowDialog()
        Read-Host "Press any key to exit"
    }
    else {
    Write-Host "$whichBatchNumber is not an available batch number"
    Read-Host "Press any key to exit"
    }
