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
# # # # # # # # # # # # # # # # # # #
#                                   #
#  Troubleshoot Connection Issues   #
#                                   #
# # # # # # # # # # # # # # # # # # #
`n`n"

Write-Host "Test the configuration of this computer for connection with trial clients `n" -ForegroundColor Yellow
Write-Host "Mobile and Marinette share the same Class C address, they are both in the LCS IP range.`n`n"


$whichBatch = Read-Host "
Which batch is this for?

    1 = LCS

    2 = CVN

Enter batch number"


###Get batch
if ($whichBatch -eq 1) {
    $batch = "192.168.56.*"
    }
elseif ($whichBatch -eq 2) {
    $batch = "192.168.79.*"
    }

###Get IP
# Get the hostname
$hostname = hostname

# Get all IP addresses associated with the hostname
$ipAddresses = [System.Net.Dns]::GetHostAddresses($hostname)

# Loop through the IP addresses and find the first IPv4 address which should be the LAN address
foreach ($ip in $ipAddresses) {
    if ($ip.AddressFamily -eq [System.Net.Sockets.AddressFamily]::InterNetwork) {
        $lanIP = $ip.ToString()
        break  # Exit loop after finding the first IPv4 address
    }
}



function enumerateNetworkStatus {
    
    param (
        [string]$batchParam,
        [string]$trustedHostsParam,
        [int]$batchNumParam,
        [string]$clientIPAddress

    )

    Write-Host "Checking trusted hosts configuration..."
    Start-Sleep 2

    $allIPsConfigured = $true

    foreach ($ip in $batchParam) {
        if ($trustedHostsParam -notcontains $ip) {
            Write-Host "$ip is not configured in local trusted hosts"
            $allIPsConfigured = $false
        } else {
            Write-Host "$ip is configured in local trusted hosts"
        }
    }

    if ($allIPsConfigured) {
        Write-Host "All batch $batchNumParam IPs are configured in your computer's trusted hosts" -ForegroundColor Green
    } else {
            Write-Host "`nSome or all of batch $batchNumParam IPs are not configured in your computer's trusted hosts." -ForegroundColor DarkYellow -BackgroundColor DarkRed

            $addTrustedHosts = Read-Host "
            Do you want to add the IP configuration for batch $batchNumParam to your computer's trusted hosts?

            1 = Yes

            2 = No

            Enter"
            if ($addTrustedHosts -eq 1) {
             Write-Host "`nAdding trusted hosts to your computer's security configuration."   
             Set-Item -Path WSMan:\localhost\Client\TrustedHosts -Value "$batch" -Force
             if ($?) {
                Write-host "success" -ForegroundColor Green
                }
                else {
                    Write-Host "Something went wrong, trusted hosts could not be added."
                    }
            } 
            elseif ($addTrustedHosts -eq 2) {
                Write-Host "Your computer's trsuted hosts configuration has not been updated. You will not be able to connect to batch $batchNumParam until you update your trusted hosts security settings."
            }
            
        else {
            Write-warning "Invalid selection"
            }
        }
    Write-Host "`n`nChecking Network IP configuration..."
    Start-Sleep 2
    if ($whichBatch -eq 1) {
        if($clientIPAddress -like "192.168.56.*") {
            Write-Host "Your IP address $clientIPAddress is configured for the LCS IP scope" -ForegroundColor Green
            }
        else {
        Write-Host "Your IP address is not correctly configured for the LCS IP scope.`n`nYour IP address: $clientIPAddress`n`nThe scope for LCS is 192.168.56.x" -ForegroundColor Yellow
        } 
        }
    if ($whichBatch -eq 2) {
        if ($clientIPAddress -like "192.168.79.*") {
            Write-Host "Your IP address $clientIPAddress is configured for the CVN IP scope" -ForegroundColor Green
            }
        else {
        Write-Host "Your IP address is not correctly configured for the CVN IP scope.`n`nYour IP address: $clientIPAddress`n`nThe scope for CVN is 192.168.79.x" -ForegroundColor Yellow
        }

    }
    }
       
    



#Check local trusted hosts for LCS IPs
$trustedHosts = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value
enumerateNetworkStatus -batchParam $batch -trustedHostsParam $trustedHosts -batchNumParam $whichBatch -clientIPAddress $lanIP
Read-Host "`nPress any key to exit"