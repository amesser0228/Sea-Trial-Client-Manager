<#
*********
E-S CKL editor script
written by Bert Favreau
GUI and output written by Andrew Messer
*********
#>

Write-Host "
# # # # # # # # # # # # # # # # # # # # # # # #
#                                             #
#  Remediate an Evaluate-STIG checklist file  #
#   with missing vuln details and comments    #
#                                             #
# # # # # # # # # # # # # # # # # # # # # # # #"

Add-Type -AssemblyName System.Windows.Forms #opens folder dialog box
$folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowserDialog.Description = "add your text here"

if ($folderBrowserDialog.ShowDialog() -eq 'OK') {
    $folderPath = $folderBrowserDialog.SelectedPath

# Get all CKL files in the folder

$cklFiles = Get-ChildItem -Path $folderPath -Filter *.ckl

 
try {
foreach ($file in $cklFiles) {
#output progress to user
write-host "parsing file: $file"

    # Load the CKL file

    [xml]$ckl = Get-Content -Path $file.FullName

 

    # Loop through each vulnerability item in the CKL file

    foreach ($vuln in $ckl.Checklist.STIGS.iSTIG.VULN) {

        $vulnID = $vuln.VulnID

        $status = $vuln.Status

                                $comments = $vuln.Comments

        $findings = $vuln.Finding_Details

 

    # Check if Comments are blank

    if ($comments -eq "") {

   

      # Check Status of Vuln

        # First condition

        if ($status -eq "NotAFinding") {

            $vuln.Comments = "Not a Finding"

        }

        # Second condition

        elseif ($status -eq "Not_Applicable" -or "Not Applicable") {

            $vuln.Comments = "Not Applicable"

        }

        # Default condition if the above conditions are not met

        else {

            $vuln.Comments = "Needs Review"

        }

    } # End If

 

    # Check if Finding_Details are blank

    if ($findings -eq "") {

   

      # Check Status of Vuln

        if ($comments -ne "") {

          $vuln.Finding_Details = $vuln.Comments

        }

    } # End If

 

} # End Loop

    # Save the updated CKL file

    $ckl.Save($file.FullName)

} # End For Each
Write-Host "`nchecklist files have been parsed for vulnerability details and comments succesfully" -ForegroundColor Green
}
catch {
Write-Host "Could not find any ckl files in $folderPath"
}
}
else {
write-host "no folder selected"
Start-Sleep 2
}
Start-Sleep 5