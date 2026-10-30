# Checks if the script is running as an administrator #
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

# If the script is not running as an administrator, re-launches the script with elevated privileges #
if (-not $isAdmin) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$printerName = "VersaLink B400"
$printerPath = "\\192.168.79.249\VersaLink B400"
$driverName = "Microsoft IPP Class Driver"

$printers = Get-Printer | Where-Object { $_.Name -notmatch "Microsoft Print to PDF|OneNote (Desktop)|OneNote for Windows10||Send To OneNote 2016|Fax|Microsoft XPS Document Writer" }

                    if ($printers.Count -lt 1) {
            # Remove printer port
            Remove-PrinterPort -Name $printerPath -PrinterHostAddress "192.168.79.249" -ErrorAction SilentlyContinue
            $existingPort = Get-PrinterPort | Where-Object {$_.PortName -eq $portName}
            if ($existingPort) {
            Write-Host "Printer port '$printerPath' already exists. Continuing to remove printer..." -ForegroundColor Yellow
            }

            Remove-PrinterDriver -Name $driverName
            Write-Host "Removing $($driverName)"

            # Add the printer
            Remove-Printer -Name $printerName -PortName $printerPath -DriverName $driverName

             $WshNetwork = New-Object -ComObject WScript.Network
             $WshNetwork.SetDefaultPrinter($printerName)
             #Write-Host "Setting $($printerName) as default"
             $existingPrinter = Get-Printer | Where-Object {$_.Name -eq $printerName}
             if ($existingPrinter) {
             Write-Host "`nSuccess: $printerName removed from $ENV:COMPUTERNAME" 
             }
             else {
             Write-Warning "Could not remove $printerName from $ENV:COMPUTERNAME"
             }
            }
            else {
            Write-Host "$($printerName) does not exist on $($ENV:COMPUTERNAME)"
            }