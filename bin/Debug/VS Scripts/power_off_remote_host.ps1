<#
Developed by Andrew Messer
Synospsis:
    1. Stops running tasks
    2. Shuts down all hosts in IP scope.
#>


Write-Host "
#####  ###  #           # #####  #####      ###   #####  #####     #   #   ###    #####   #####   #####
#   # #   #  #         #  #      #   #     #   #  #      #         #   #  #   #  #          #    #
####  #   #   #   #   #   ###    ####      #   #  ###    ###       #####  #   #   ####      #     ####
#     #   #    # # # #    #      #   #     #   #  #      #         #   #  #   #       #     #         #
#      ###      #   #     #####  #   #      ###   #      #         #   #   ###   #####      #    #####

                                         -PMS501/CVN ETC Clients-

NOTES:
1. Check Remote Targets in Script
2. Verify ative machines before running this script.
3. Password is LCS password.
" -ForegroundColor Yellow

# Checks if the script is running as an administrator #
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
    }

# Prompt for the password
$password = Read-Host -AsSecureString "Enter the password"

# Convert the secure string to plain text for verification 
$plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

# Define the correct password
$correctPassword = "L-3Communicati0ns!"

# Check if the entered password matches the correct password
if ($plainPassword -eq $correctPassword) {
    Write-Host "Password is correct. Running the script..." -ForegroundColor Green
    Start-Sleep 1

    $computers = @(
    #MOB
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
    "192.168.56.218"
    "192.168.56.219",
    "192.168.56.220",
    "192.168.56.221",
    "192.168.56.222",
    "192.168.56.223"
    <#MAR
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
    "192.168.56.123"
    #>
)
    # Provide credentials for hosts
    $securePassword = ConvertTo-SecureString "L-3Communicati0ns!" -AsPlainText -Force

    $credential = New-Object System.Management.Automation.PSCredential ("LCS", $securePassword)

    foreach ($computer in $computers) {
        # Get all running processes and stop before shutting down
        #Get-Process | Where-Object {$_.Name -notlike "*powershell*"} | Stop-Process -force
        #Start-Sleep 5 # allow applications to close properly
        Stop-Computer -ComputerName $computer -Credential $credential -Force #Shut down clients
        }

        Write-Output "Power Off Command has been sent to remote host(s): $computers"
        Start-Sleep 3
        } 
else {
    Write-Warning "Incorrect password. Exiting script..."
    Start-Sleep 3
    exit
    }

    Start-Sleep 3



