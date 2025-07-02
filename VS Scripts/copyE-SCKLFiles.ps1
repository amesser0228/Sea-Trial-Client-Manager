<#DEVELOPED BY ANDREW MESSER>

SYNOPSIS:
1. SELECT CKL FOLDER
2. RECURSE THROUGH FOLDER PATH
3. APPENDS ALL .CKL FILES TO SELECTED OUTPUT LOCATION
#>

# Open dialog box prompt to select folder
Add-Type -AssemblyName System.Windows.Forms #opens folder dialog box
$folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowserDialog.Description = "Select the main Eval-STIG scan folder"
if ($folderBrowserDialog.ShowDialog() -eq 'OK') {
    $folderPath = $folderBrowserDialog.SelectedPath
    Write-Host "You selected folder: $folderPath" -ForegroundColor Yellow

    # Open dialog box prompt to select destination folder
    $folderBrowserDialog.Description = "Select the destination folder"
    if ($folderBrowserDialog.ShowDialog() -eq 'OK') {
        $destinationFolderPath = $folderBrowserDialog.SelectedPath
        Write-Host "Destination folder: $destinationFolderPath" -ForegroundColor Yellow

        # Get all CVN folders within the selected folder
        $clientScanFolder = Get-ChildItem -Path $folderPath -Directory
        foreach ($folder in $clientScanFolder) {
            # Check if the folder name starts with "CVN-"
            if ($folder.Name -like "CVN-*") {
                Write-Host "Folder Name: $($folder.Name)" -ForegroundColor Green

                # Path to the Checklist subfolder
                $checklistPath = Join-Path -Path $folder.FullName -ChildPath "Checklist"
                if (Test-Path $checklistPath) {
                    $checklistFiles = Get-ChildItem -Path $checklistPath
                    Write-Host "Files in Checklist folder:" -ForegroundColor Cyan
                    foreach ($file in $checklistFiles) {
                        if ($file.Extension -eq ".ckl") {
                        $sourceFilePath = $file.FullName
                        Copy-Item $sourceFilePath -Destination $destinationFolderPath
                        Write-Host "Copying $($file.Name) to $destinationFolderPath"
                        }
                    }
                }
            }
        }
    }
    Write-Host "`nDone" -ForegroundColor Green
    Read-Host "`nPress any key to exit"
}
else {
    write-host "No folder selected"
    start-sleep 3
}