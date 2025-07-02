# Checks if the script is running as an administrator #
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

<#DEVELOPED BY ANDREW MESSER

SYNOPSIS:

    1. QUERIES HOSTS IN CLIENT ARRAY
    2. RUNS COMMAND WITH REMOTE CREDENTIALS TO EACH HOST
    #>

Write-Host "
# # # # # # # # # # # # # #
#                         #
#  Enter a Remote Session #
#   with a Single Client  #
#                         #
# # # # # # # # # # # # # #
`n`n"

Write-Host "Enter a remote PowerShell Session with a single client.`n`n" -ForegroundColor Yellow

$whichBatch = Read-Host "Which batch is this for?

    1 = MOB
    2 = MAR
    3 = CVN

Enter batch number"

# Load Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Select Computers to Power Off"
$form.Size = New-Object System.Drawing.Size(300, 400)
$form.StartPosition = "CenterScreen"

# Create a FlowLayoutPanel with AutoScroll enabled
$flowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$flowLayoutPanel.AutoScroll = $true
$flowLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$flowLayoutPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$flowLayoutPanel.WrapContents = $false

$mobClients = @(
#MOB
"192.168.56.201"
"192.168.56.202",
"192.168.56.203",
"192.168.56.204",
"192.168.56.205",
"192.168.56.206",
"192.168.56.207",
"192.168.56.208",
"192.168.56.209",
"192.168.56.210",
"192.168.56.211",
"192.168.56.212",
"192.168.56.213",
"192.168.56.214",
"192.168.56.215",
"192.168.56.216",
"192.168.56.217",
"192.168.56.218",
"192.168.56.219",
"192.168.56.220",
"192.168.56.221",
"192.168.56.222",
"192.168.56.223")

$marClients = @(
#MAR
"192.168.56.101"
"192.168.56.102",
"192.168.56.103",
"192.168.56.104",
"192.168.56.105",
"192.168.56.106",
"192.168.56.107",
"192.168.56.108",
"192.168.56.109",
"192.168.56.110",
"192.168.56.111",
"192.168.56.112",
"192.168.56.113",
"192.168.56.114",
"192.168.56.115",
"192.168.56.116",
"192.168.56.117",
"192.168.56.118",
"192.168.56.119",
"192.168.56.120",
"192.168.56.121",
"192.168.56.122",
"192.168.56.123")

$cvnClients = @(
#CVN
"192.168.79.101",
"192.168.79.102",
"192.168.79.103",
"192.168.79.104",
"192.168.79.105",
"192.168.79.106",
"192.168.79.107",
"192.168.79.108",
"192.168.79.109",
"192.168.79.110",
"192.168.79.111",
"192.168.79.112",
"192.168.79.113",
"192.168.79.114",
"192.168.79.115",
"192.168.79.116",
"192.168.79.117",
"192.168.79.118",
"192.168.79.119",
"192.168.79.120",
"192.168.79.121",
"192.168.79.122",
"192.168.79.123",
"192.168.79.124",
"192.168.79.125",
"192.168.79.126",
"192.168.79.127",
"192.168.79.128",
"192.168.79.129",
"192.168.79.130",
"192.168.79.131",
"192.168.79.132",
"192.168.79.133",
"192.168.79.134",
"192.168.79.135",
"192.168.79.136",
"192.168.79.137",
"192.168.79.138",
"192.168.79.139",
"192.168.79.140",
"192.168.79.141",
"192.168.79.142",
"192.168.79.143",
"192.168.79.144",
"192.168.79.145",
"192.168.79.146",
"192.168.79.147"
"192.168.79.148")

$securePassword = ConvertTo-SecureString "L-3Communicati0ns!" -AsPlainText -Force
$lcsCredential = New-Object System.Management.Automation.PSCredential ("LCS", $securePassword)
$cvnCredential = New-Object System.Management.Automation.PSCredential ("CVN", $securePassword)


#Get credential
if ($whichBatch -eq 1) {
        $credential = $lcsCredential}
    elseif ($whichBatch -eq 2) {
        $credential = $lcsCredential}
    elseif ($whichBatch -eq 3) {
        $credential = $cvnCredential}
  

#Get batch
if ($whichBatch -eq 1) {
        $batch = $mobClients}
    elseif ($whichBatch -eq 2) {
        $batch = $marClients}
    elseif ($whichBatch -eq 3) {
        $batch = $cvnClients}

foreach ($computer in $batch) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $computer
    $flowLayoutPanel.Controls.Add($checkbox)
}

    # Add a button to submit the selected IP addresses
    $button = New-Object System.Windows.Forms.Button
    $button.Text = "Submit"
    $button.Add_Click({
        foreach ($control in $flowLayoutPanel.Controls) {
            if ($control -is [System.Windows.Forms.CheckBox] -and $control.Checked) {
                Write-Host "Entering Remote Session on $($control.Text)..."
                New-PSSession -ComputerName $control.Text -Credential $credential
            }
        }
        $form.Close()
    })
    $flowLayoutPanel.Controls.Add($button)

    $form.Controls.Add($flowLayoutPanel)
    $form.Add_Shown({$form.Activate()})
    [void] $form.ShowDialog()

