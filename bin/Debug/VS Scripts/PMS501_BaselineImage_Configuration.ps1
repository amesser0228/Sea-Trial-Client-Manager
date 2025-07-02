####################################################
######  BASELINE IMAGE CONFIGURATION FOR W10  ######
######       DEVELOPED BY ANDREW MESSER       ######
####################################################

<# 
    PREAMBLE
This script performs a number of setup operations for the MSC Sea Trial Team.
1. Updates BIOS Firmware
2. Applies IPv4 Aaddress
3. Applies Hostname 
4. DEPRECATED<Enables Bitlocker on C: and copies security key to server share>
#>

#PREVENT WINDOWS SCRIPTS FROM RUNNING ON SERVER
$OS_Name = Get-WmiObject -Class Win32_OperatingSystem | Select-Object -ExpandProperty Caption

if ($OS_Name -notlike '*Windows Server*') {

# Checks if the script is running as an administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$scriptName = $MyInvocation.MyCommand.Name
########################################################################
write-host "
##   ##   #######  #######
# # # #  #         #         
#  #  #   ######   #          
#     #         #  #              
#     #  #######   #######  

MARINE SYSTEMS CORPORATION`n`nRunning Sea Trial Script ($scriptName...) on $env:COMPUTERNAME"
Start-Sleep -Seconds 5

#############################################


#UPDATES FIRMWARE (5531/5510)#

function progressFirmware { #function to display the progress of firmware install
    Write-Host "Installing $firmwareToInstall..."

    Start-Sleep -Seconds 10

    Write-Progress -Activity $activity -Status "Progress" -PercentComplete 0

    Start-Sleep -Seconds 10

    Write-Progress -Activity $activity -Status "Progress" -PercentComplete 20

    Start-Sleep -Seconds 15

    Write-Progress -Activity $activity -Status "Progress" -PercentComplete 30

    Start-Sleep -Seconds 15

    Write-Progress -Activity $activity -Status "Progress" -PercentComplete 50

    Start-Sleep -Seconds 15

    Write-Progress -Activity $activity -Status "Progress" -PercentComplete 80

    Start-Sleep -Seconds 10

    Write-Progress -Activity $activity -Status "Progress" -PercentComplete 100

    Start-Sleep -Seconds 5

    Clear-Host

    write-host "`n`n`n`n`n`n`n`n`n"

    Write-Warning "Computer will restart and the end of this script to begin BIOS flash. *DO NOT TURN OFF THE COMPUTER*"

    Start-Sleep -Seconds 5

    Clear-Host

    <#$durationInSeconds = 10  # Sets duration of the timer in seconds

    Write-Host "Timer started. Press Ctrl+C to stop`n"

    while ($durationInSeconds -gt 0) {
        Write-Host -NoNewline ("Computer restart in: {0:D2} seconds`r" -f $durationInSeconds)
        Start-Sleep -Seconds 1
        $durationInSeconds--
        }
        #>
    

    #Restart-Computer
}

$firmware = (Get-CimInstance -ClassName CIM_BIOSElement).SMBIOSBIOSVersion #defines varible to retrieve firmware 
$computerModel = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Model #defines variable to retrieve model
$firmwareComponents = $firmware -split '\.'
$majorVersion = [int]$firmwareComponents[0]
$minorVersion = [int]$firmwareComponents[1]
$revision = [int]$firmwareComponents[2]
$tableData = [PSCustomObject]@{ #defines PS objects to return firmware and model values in a table format
    Firmware = $firmware
    Model = $computerModel
}


Write-Host "Checking computer Firmware and Model. Please wait..."
Start-Sleep -Seconds 3

if($majorVersion -eq 1 -and $minorVersion -lt 23 -and $computerModel -eq "Latitude 5531"){
    $firmwareToInstall = "Precision_3571_Latitude_5531_1.23.0.exe"
    $activity = "Installing Latitude 5531 Firmware: $firmwareToInstall"
    Write-Host "Firmware Version: $firmware. `nComputer Model: $computerModel."
    Start-Sleep -Seconds 3
    Start-Process -FilePath "C:\Admin Only\Firmware\5531\Precision_3571_Latitude_5531_1.23.0.exe"/s
    progressFirmware
    }

ElseIf($majorVersion -eq 1 -and $minorVersion -lt 28 -and $computerModel -eq "Latitude 5510"){
    $firmwareToInstall = "Latitude_5X10_Precision_3550_1.28.0.exe"
    $activity = "Installing Latitude 5510 Firmware: $firmwareToInstall"
    Write-Host "Firmware Version: $firmware. `nComputer Model: $computerModel."
    Start-Sleep -Seconds 3
    Start-Process -FilePath "C:\Admin Only\Firmware\5510\Latitude_5X10_Precision_3550_1.28.0.exe"/s
    progressFirmware
    }

else {
    write-host "`nFirmware update cannot be started. This may be because the firmware is already up to date.`n" -ForegroundColor Yellow
    write-host "Required firmware for 5531 is (1.22.0) `nRequired firmware for 5510 is (1.24.0)`n`nYour system information is:"
    Start-Sleep -Seconds 2
    $tableData | Format-Table -Property Firmware, Model
    }


# REMOVE BITLOCKER PIN POLICIES
$bdePINPath = "HKLM:SOFTWARE\Policies\Microsoft\FVE"
Remove-Item -Path $bdePINPath -Force
    

#APPLIES IPV4/HOSTNAME

#MAC ARRAY
$macAddresses = @(
"74:78:27:15:30:23",
"74:78:27:15:4E:F2",
"74:78:27:15:30:3D",
"74:78:27:15:31:7E",
"74:78:27:15:2F:BB",
"74:78:27:15:4E:E3",
"74:78:27:15:2F:BA",
"74:78:27:15:31:98",
"74:78:27:15:31:08",
"74:78:27:15:31:97",
"74:78:27:15:4E:EC",
"74:78:27:15:30:3A",
"74:78:27:15:2F:AF",
"74:78:27:54:AE:24",
"74:78:27:15:2C:6A",
"74:78:27:15:32:61",
"CC:48:3A:5D:87:66",
"74:78:27:15:31:7D",
"74:78:27:11:C9:97",
"74:78:27:15:31:83",
"74:78:27:15:2F:6D",
"74:78:27:15:2C:69",
"74:78:27:15:30:2C",
"C8:4B:D6:4C:47:C6",
"C8:4B:D6:4C:47:D4",
"C8:4B:D6:4C:47:CC",
"C8:4B:D6:4C:47:3A",
"C8:4B:D6:4C:48:0A",
"C8:4B:D6:4C:48:30",
"C8:4B:D6:4C:47:C4",
"C8:4B:D6:4C:47:D2",
"C8:4B:D6:4C:47:CA",
"C8:4B:D6:4C:47:50",
"C8:4B:D6:4C:47:42",
"C8:4B:D6:4C:48:8A",
"C8:4B:D6:4C:47:CE",
"C8:4B:D6:4C:48:38",
"C8:4B:D6:4C:47:C8",
"C8:4B:D6:4C:47:D6",
"C8:4B:D6:4C:49:22",
"C8:4B:D6:4C:47:D8",
"C8:4B:D6:4C:46:FE",
"C8:4B:D6:4C:47:52",
"C8:4B:D6:4C:47:40",
"C8:4B:D6:4C:49:20",
"C8:4B:D6:4C:48:32",
"C8:4B:D6:4C:47:DA")

#IP ARRAY (200=MOB, 100=MAR)
$ipAddresses = @(
"192.168.56.201",
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
"192.168.56.223",
"192.168.56.101",
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
"192.168.56.123",
"192.168.56.124")

#HOSTNAME ARRAY
$computerNames = @(
"MOB-001",
"MOB-002",
"MOB-003",
"MOB-004",
"MOB-005",
"MOB-006",
"MOB-007",
"MOB-008",
"MOB-009",
"MOB-010",
"MOB-011",
"MOB-012",
"MOB-013",
"MOB-014",
"MOB-015",
"MOB-016",
"MOB-017",
"MOB-018",
"MOB-019",
"MOB-020",
"MOB-021",
"MOB-022",
"MOB-023",
"MAR-001",
"MAR-002",
"MAR-003",
"MAR-004",
"MAR-005",
"MAR-006",
"MAR-007",
"MAR-008",
"MAR-009",
"MAR-010",
"MAR-011",
"MAR-012",
"MAR-013",
"MAR-014",
"MAR-015",
"MAR-016",
"MAR-017",
"MAR-018",
"MAR-019",
"MAR-020",
"MAR-021",
"MAR-022",
"MAR-023",
"Master-Image")

#############################################

#SETS IPV4 AND HOST NAME
for ($i = 0; $i -lt $macAddresses.Count; $i++) {
    $networkAdapter = Get-WmiObject -Class Win32_NetworkAdapter | Where-Object {$_.MacAddress -eq $macAddresses[$i]}

if ($networkAdapter) {
        $newipAddress = $ipAddresses[$i]
        $adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' -and $_.InterfaceDescription -like '*Ethernet*' } #Get-NetAdapter -Name "Ethernet 2"
        $ipConfig = $adapter | Get-NetIPConfiguration
        $ipConfig | Remove-NetIPAddress -Confirm:$false
        $ipConfig | New-NetIPAddress -AddressFamily IPv4 -IPAddress $newipAddress -PrefixLength 24
        $newComputerName = $computerNames[$i]
        Rename-Computer -NewName $newComputerName #-Restart
        write-host "Computer name changed to $newComputerName for MAC address $($macAddresses[$i]) successfully." -ForegroundColor Green -BackgroundColor Black
        Start-Sleep -Seconds 1
        Write-Host "IP Address $newipAddress has been set for MAC adrress $($macAddresses[$i])." -ForegroundColor Green -BackgroundColor Black
        Start-Sleep -Seconds 5
        write-host "`n`nRestarting in 10 seconds..." -ForegroundColor Yellow
        Start-Sleep -Seconds 10
        Restart-Computer
        #Add-Type -AssemblyName PresentationCore,PresentationFramework
      #$Result = [System.Windows.MessageBox]::Show("IP Address $newipAddress has been set for MAC adrress $($macAddresses[$i]).", "501 Trial IPv4 Address Editor",0,0)
    }
    #"No network adapter found with MAC address $($macAddresses[$i])."
    }

<#SETS HOSTNAME
for ($i = 0; $i -lt $macAddresses.Count; $i++) {
    $networkAdapter = Get-WmiObject -Class Win32_NetworkAdapter | Where-Object {$_.MacAddress -eq $macAddresses[$i]}
    
    if ($networkAdapter) {
        $newComputerName = $computerNames[$i]
        Rename-Computer -NewName $newComputerName #-Restart
        write-host "Computer name changed to $newComputerName for MAC address $($macAddresses[$i]) successfully." -ForegroundColor Yellow -BackgroundColor Black
        Start-Sleep -Seconds 5
        #Restart-Computer
    } 
    else {"No network adapter found with MAC address $($macAddresses[$i])."
    }
    }
    #>

#############################################

#BITLOCKER ENCRYPTION DEPRECATED TO STANDALONE SCRIPT FOR BETTER REPORTING
}
else {
Write-Warning 'Cannot run script on Server.'
}