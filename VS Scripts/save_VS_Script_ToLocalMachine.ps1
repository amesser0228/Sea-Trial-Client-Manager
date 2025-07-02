# Open dialog box prompt to select folder
Add-Type -AssemblyName System.Windows.Forms #opens folder dialog box
$folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowserDialog.Description = "Select where you want to save the Script Folder"

$VSScriptFolderPath = Join-Path -Path (Get-Item -Path Env:APPDATA).Value -ChildPath "VS_Scripts"

if ($folderBrowserDialog.ShowDialog() -eq 'OK') {
    try {
        #Save file in user selected dir
        $folderPath = $folderBrowserDialog.SelectedPath
        Copy-Item -Path $VSScriptFolderPath -Destination $folderPath -Recurse -Force
        Add-Type -AssemblyName PresentationCore,PresentationFramework
        $Result = [System.Windows.MessageBox]::Show("VS_Scripts Folder has been saved to $folderPath", "STCM.SaveVSFolder",0,0)
        }
    catch {
        Write-Host "Error. Cannot process command."
        }
}
else {
        Add-Type -AssemblyName PresentationCore,PresentationFramework
        $Result = [System.Windows.MessageBox]::Show("No folder was selected.", "STCM.SaveVSFolder",0,0)
    }