#Open dialog box prompt to select file
Add-Type -AssemblyName System.Windows.Forms

$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Title = "Select a Checklist File"
$openFileDialog.Filter = "CKL Files (*.ckl)|*.ckl" #for all file types:  "All Files (*.*)|*.*"
"Select a CKL file w/o a host number"

if ($openFileDialog.ShowDialog() -eq 'OK') {
    $filePath = $openFileDialog.FileName
    Write-Host "You selected the file: $filePath`n`n" -ForegroundColor Yellow

$sourceFile = $filePath

$baseName = [System.IO.Path]::GetFileNameWithoutExtension($sourceFile)
$extension = [System.IO.Path]::GetExtension($sourceFile)

$prefix = $baseName.Substring(0, 4)
$middlePart = $baseName.Substring(4, 3)
$number = $baseName.Substring(3, 1) -as [int]

for ($i = 1; $i -le 23; $i++) {
    $paddedNumber = "{0:D3}" -f ($number + $i)
    $newFileName = $prefix + "-" + $paddedNumber <#+ "_" + $middlePart#> + $baseName.Substring(7) + $extension
    $newFileName = $newFileName.Replace("--", "-")  # Remove extra dash
    $destinationFile = Join-Path -Path (Split-Path -Path $sourceFile) -ChildPath $newFileName
    Copy-Item -Path $sourceFile -Destination $destinationFile -ErrorAction SilentlyContinue
    # Test to make sure script executed
    if ($?) {
    Write-Host "Source file: $newFileName has been copied to destination"
    }else {
    "Files copied with possibe error"
    }
}
} else {
    Write-Host "No file was selected."
}
Start-Sleep -Seconds 8