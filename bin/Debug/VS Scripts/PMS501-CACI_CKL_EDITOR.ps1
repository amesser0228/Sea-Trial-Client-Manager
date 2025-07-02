#MAC ARRAY
$hostMACArray = @(
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
"C8:4B:D6:4C:48:32")

#IP ARRAY (200=MOB, 100=MAR)
$hostIPArray = @(
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
"192.168.56.123")

#HOSTNAME ARRAY
$hostNameArray = @(
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
"MAR-023")


# Open dialog box prompt to select folder
Add-Type -AssemblyName System.Windows.Forms #opens folder dialog box
$folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowserDialog.Description = "Select a Checklist Folder"
#"Select a folder containing CKL files"

if ($folderBrowserDialog.ShowDialog() -eq 'OK') {
    $folderPath = $folderBrowserDialog.SelectedPath
    Write-Host "You selected folder: $folderPath" -ForegroundColor Yellow
    Write-Host "Parsing ckl files..."
    Start-Sleep 3

    $files = Get-ChildItem -Path $folderPath -File #parses folder for files 
    foreach ($file in $files) { #iterates through folder for files
    $compFileName = $file.Name.Substring(0, 7) #selector for host in filename

    # XPath expressions targeting XML tag elements in host file
    $xpathExpression_Marking = "//ASSET/MARKING"
    $xpathExpression_HostName = "//ASSET/HOST_NAME"
    $xpathExpression_HostFQDN = "//ASSET/HOST_FQDN"
    $xpathExpression_HostIP = "//ASSET/HOST_IP"
    $xpathExpression_HostMAC = "//ASSET/HOST_MAC"


# Retrieve and update the MOB Marking element
if ($compFileName -eq "MOB-001") {
$markingValue = "CUI"
$selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
$selectedTags_Marking.Node.InnerText = $markingValue
$selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
}

    elseif ($compFileName -eq "MOB-002") {
    $markingValue = "CUI"
    $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
    $selectedTags_Marking.Node.InnerText = $markingValue
    $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
    }

        elseif ($compFileName -eq "MOB-003") {
        $markingValue = "CUI"
        $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
        $selectedTags_Marking.Node.InnerText = $markingValue
        $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
        }

            elseif ($compFileName -eq "MOB-004") {
            $markingValue = "CUI"
            $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
            $selectedTags_Marking.Node.InnerText = $markingValue
            $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
            }

                elseif ($compFileName -eq "MOB-005") {
                $markingValue = "CUI"
                $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                $selectedTags_Marking.Node.InnerText = $markingValue
                $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                }

                    elseif ($compFileName -eq "MOB-006") {
                    $markingValue = "CUI"
                    $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                    $selectedTags_Marking.Node.InnerText = $markingValue
                    $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                    }

                        elseif ($compFileName -eq "MOB-007") {
                        $markingValue = "CUI"
                        $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                        $selectedTags_Marking.Node.InnerText = $markingValue
                        $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                        }

                            elseif ($compFileName -eq "MOB-008") {
                            $markingValue = "CUI"
                            $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                            $selectedTags_Marking.Node.InnerText = $markingValue
                            $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                            }

                                elseif ($compFileName -eq "MOB-009") {
                                $markingValue = "CUI"
                                $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                $selectedTags_Marking.Node.InnerText = $markingValue
                                $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                }

                                    elseif ($compFileName -eq "MOB-010") {
                                    $markingValue = "CUI"
                                    $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                    $selectedTags_Marking.Node.InnerText = $markingValue
                                    $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                    }

                                        elseif ($compFileName -eq "MOB-011") {
                                        $markingValue = "CUI"
                                        $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                        $selectedTags_Marking.Node.InnerText = $markingValue
                                        $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                        }

                                            elseif ($compFileName -eq "MOB-012") {
                                            $markingValue = "CUI"
                                            $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                            $selectedTags_Marking.Node.InnerText = $markingValue
                                            $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                            }

                                                elseif ($compFileName -eq "MOB-013") {
                                                $markingValue = "CUI"
                                                $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                $selectedTags_Marking.Node.InnerText = $markingValue
                                                $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                }

                                                    elseif ($compFileName -eq "MOB-014") {
                                                    $markingValue = "CUI"
                                                    $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                    $selectedTags_Marking.Node.InnerText = $markingValue
                                                    $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                    }

                                                        elseif ($compFileName -eq "MOB-015") {
                                                        $markingValue = "CUI"
                                                        $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                        $selectedTags_Marking.Node.InnerText = $markingValue
                                                        $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                        }

                                                            elseif ($compFileName -eq "MOB-016") {
                                                            $markingValue = "CUI"
                                                            $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                            $selectedTags_Marking.Node.InnerText = $markingValue
                                                            $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                            }

                                                                elseif ($compFileName -eq "MOB-017") {
                                                                $markingValue = "CUI"
                                                                $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                                $selectedTags_Marking.Node.InnerText = $markingValue
                                                                $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                                }

                                                                    elseif ($compFileName -eq "MOB-018") {
                                                                    $markingValue = "CUI"
                                                                    $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                                    $selectedTags_Marking.Node.InnerText = $markingValue
                                                                    $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                                    }

                                                                        elseif ($compFileName -eq "MOB-019") {
                                                                        $markingValue = "CUI"
                                                                        $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                                        $selectedTags_Marking.Node.InnerText = $markingValue
                                                                        $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                                        }

                                                                            elseif ($compFileName -eq "MOB-020") {
                                                                            $markingValue = "CUI"
                                                                            $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                                            $selectedTags_Marking.Node.InnerText = $markingValue
                                                                            $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                                            }

                                                                                elseif ($compFileName -eq "MOB-021") {
                                                                                $markingValue = "CUI"
                                                                                $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                                                $selectedTags_Marking.Node.InnerText = $markingValue
                                                                                $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                                                }

                                                                                    elseif ($compFileName -eq "MOB-022") {
                                                                                    $markingValue = "CUI"
                                                                                    $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                                                    $selectedTags_Marking.Node.InnerText = $markingValue
                                                                                    $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                                                    }

                                                                                        elseif ($compFileName -eq "MOB-023") {
                                                                                        $markingValue = "CUI"
                                                                                        $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                                                        $selectedTags_Marking.Node.InnerText = $markingValue
                                                                                        $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                                                        }


                                                                                        if ($compFileName -eq "MAR-001") {
                                                                                        $markingValue = "CUI"
                                                                                        $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                                                        $selectedTags_Marking.Node.InnerText = $markingValue
                                                                                        $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                                                        }

                                                                                    elseif ($compFileName -eq "MAR-002") {
                                                                                    $markingValue = "CUI"
                                                                                    $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                                                    $selectedTags_Marking.Node.InnerText = $markingValue
                                                                                    $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                                                    }

                                                                                elseif ($compFileName -eq "MAR-003") {
                                                                                $markingValue = "CUI"
                                                                                $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                                                $selectedTags_Marking.Node.InnerText = $markingValue
                                                                                $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                                                }

                                                                            elseif ($compFileName -eq "MAR-004") {
                                                                            $markingValue = "CUI"
                                                                            $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                                            $selectedTags_Marking.Node.InnerText = $markingValue
                                                                            $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                                            }

                                                                        elseif ($compFileName -eq "MAR-005") {
                                                                        $markingValue = "CUI"
                                                                        $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                                        $selectedTags_Marking.Node.InnerText = $markingValue
                                                                        $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                                        }

                                                                    elseif ($compFileName -eq "MAR-006") {
                                                                    $markingValue = "CUI"
                                                                    $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                                    $selectedTags_Marking.Node.InnerText = $markingValue
                                                                    $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                                    }

                                                                elseif ($compFileName -eq "MAR-007") {
                                                                $markingValue = "CUI"
                                                                $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                                $selectedTags_Marking.Node.InnerText = $markingValue
                                                                $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                                }

                                                            elseif ($compFileName -eq "MAR-008") {
                                                            $markingValue = "CUI"
                                                            $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                            $selectedTags_Marking.Node.InnerText = $markingValue
                                                            $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                            }

                                                        elseif ($compFileName -eq "MAR-009") {
                                                        $markingValue = "CUI"
                                                        $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                        $selectedTags_Marking.Node.InnerText = $markingValue
                                                        $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                        }

                                                    elseif ($compFileName -eq "MOB-010") {
                                                    $markingValue = "CUI"
                                                    $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                    $selectedTags_Marking.Node.InnerText = $markingValue
                                                    $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                    }

                                                elseif ($compFileName -eq "MAR-011") {
                                                $markingValue = "CUI"
                                                $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                                $selectedTags_Marking.Node.InnerText = $markingValue
                                                $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                                }
                                            

                                            elseif ($compFileName -eq "MAR-012") {
                                            $markingValue = "CUI"
                                            $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                            $selectedTags_Marking.Node.InnerText = $markingValue
                                            $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                            }

                                        elseif ($compFileName -eq "MAR-013") {
                                        $markingValue = "CUI"
                                        $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                        $selectedTags_Marking.Node.InnerText = $markingValue
                                        $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                        }

                                    elseif ($compFileName -eq "MAR-014") {
                                    $markingValue = "CUI"
                                    $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                    $selectedTags_Marking.Node.InnerText = $markingValue
                                    $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                    }

                                elseif ($compFileName -eq "MAR-015") {
                                $markingValue = "CUI"
                                $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                                $selectedTags_Marking.Node.InnerText = $markingValue
                                $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                                }

                            elseif ($compFileName -eq "MAR-016") {
                            $markingValue = "CUI"
                            $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                            $selectedTags_Marking.Node.InnerText = $markingValue
                            $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                            }

                        elseif ($compFileName -eq "MAR-017") {
                        $markingValue = "CUI"
                        $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                        $selectedTags_Marking.Node.InnerText = $markingValue
                        $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                        }

                    elseif ($compFileName -eq "MAR-018") {
                    $markingValue = "CUI"
                    $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                    $selectedTags_Marking.Node.InnerText = $markingValue
                    $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                    }

                elseif ($compFileName -eq "MAR-019") {
                $markingValue = "CUI"
                $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
                $selectedTags_Marking.Node.InnerText = $markingValue
                $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
                }

            elseif ($compFileName -eq "MAR-020") {
            $markingValue = "CUI"
            $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
            $selectedTags_Marking.Node.InnerText = $markingValue
            $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
            }

        elseif ($compFileName -eq "MAR-021") {
        $markingValue = "CUI"
        $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
        $selectedTags_Marking.Node.InnerText = $markingValue
        $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
        }

    elseif ($compFileName -eq "MAR-022") {
    $markingValue = "CUI"
    $selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
    $selectedTags_Marking.Node.InnerText = $markingValue
    $selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
    }

elseif ($compFileName -eq "MAR-023") {
$markingValue = "CUI"
$selectedTags_Marking = Select-Xml -Path $file.FullName -XPath $xpathExpression_Marking
$selectedTags_Marking.Node.InnerText = $markingValue
$selectedTags_Marking.Node.OwnerDocument.Save($file.FullName)
}

# Retrieve and update the MOB HOST_NAME element
if ($compFileName -eq "MOB-001") {
$hostNameValue = $hostNameArray[0]
$selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
$selectedTags_HostName.Node.InnerText = $hostNameValue
$selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
}
    elseif ($compFileName -eq "MOB-002") {
    $hostNameValue = $hostNameArray[1]
    $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
    $selectedTags_HostName.Node.InnerText = $hostNameValue
    $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
    }
        elseif ($compFileName -eq "MOB-003") {
        $hostNameValue = $hostNameArray[2]
        $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
        $selectedTags_HostName.Node.InnerText = $hostNameValue
        $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
        }                   
            elseif ($compFileName -eq "MOB-004") {
            $hostNameValue = $hostNameArray[3]
            $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
            $selectedTags_HostName.Node.InnerText = $hostNameValue
            $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
            }
                elseif ($compFileName -eq "MOB-005") {
                $hostNameValue = $hostNameArray[4]
                $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                $selectedTags_HostName.Node.InnerText = $hostNameValue
                $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                }
                    elseif ($compFileName -eq "MOB-006") {
                    $hostNameValue = $hostNameArray[5]
                    $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                    $selectedTags_HostName.Node.InnerText = $hostNameValue
                    $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                    }
                        elseif ($compFileName -eq "MOB-007") {
                        $hostNameValue = $hostNameArray[6]
                        $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                        $selectedTags_HostName.Node.InnerText = $hostNameValue
                        $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                        }
                            elseif ($compFileName -eq "MOB-008") {
                            $hostNameValue = $hostNameArray[7]
                            $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                            $selectedTags_HostName.Node.InnerText = $hostNameValue
                            $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                            }  
                                elseif ($compFileName -eq "MOB-009") {
                                $hostNameValue = $hostNameArray[8]
                                $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                $selectedTags_HostName.Node.InnerText = $hostNameValue
                                $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                }
                                    elseif ($compFileName -eq "MOB-010") {
                                    $hostNameValue = $hostNameArray[9]
                                    $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                    $selectedTags_HostName.Node.InnerText = $hostNameValue
                                    $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                    } 
                                        elseif ($compFileName -eq "MOB-011") {
                                        $hostNameValue = $hostNameArray[10]
                                        $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                        $selectedTags_HostName.Node.InnerText = $hostNameValue
                                        $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                        }
                                            elseif ($compFileName -eq "MOB-012") {
                                            $hostNameValue = $hostNameArray[11]
                                            $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                            $selectedTags_HostName.Node.InnerText = $hostNameValue
                                            $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                            }
                                                elseif ($compFileName -eq "MOB-013") {
                                                $hostNameValue = $hostNameArray[12]
                                                $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                }  
                                                    elseif ($compFileName -eq "MOB-014") {
                                                    $hostNameValue = $hostNameArray[13]
                                                    $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                    $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                    $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                    }
                                                        elseif ($compFileName -eq "MOB-015") {
                                                        $hostNameValue = $hostNameArray[14]
                                                        $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                        $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                        $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                        }
                                                            elseif ($compFileName -eq "MOB-016") {
                                                            $hostNameValue = $hostNameArray[15]
                                                            $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                            $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                            $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                            }
                                                                elseif ($compFileName -eq "MOB-017") {
                                                                $hostNameValue = $hostNameArray[16]
                                                                $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                                $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                                $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                                }
                                                                    elseif ($compFileName -eq "MOB-018") {
                                                                    $hostNameValue = $hostNameArray[17]
                                                                    $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                                    $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                                    $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                                    }
                                                                        elseif ($compFileName -eq "MOB-019") {
                                                                        $hostNameValue = $hostNameArray[18]
                                                                        $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                                        $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                                        $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                                        }
                                                                            elseif ($compFileName -eq "MOB-020") {
                                                                            $hostNameValue = $hostNameArray[19]
                                                                            $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                                            $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                                            $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                                            }
                                                                                elseif ($compFileName -eq "MOB-021") {
                                                                                $hostNameValue = $hostNameArray[20]
                                                                                $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                                                $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                                                $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                                                }
                                                                                    elseif ($compFileName -eq "MOB-022") {
                                                                                    $hostNameValue = $hostNameArray[21]
                                                                                    $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                                                    $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                                                    $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                                                    }
                                                                                        elseif ($compFileName -eq "MOB-023") {
                                                                                        $hostNameValue = $hostNameArray[22]
                                                                                        $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                                                        $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                                                        $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                                                        }
            
                                                                                        # Retrieve and update the MAR HOST_NAME element
                                                                                        elseif ($compFileName -eq "MAR-001") {
                                                                                        $hostNameValue = $hostNameArray[23]
                                                                                        $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                                                        $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                                                        $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                                                        }
                                                                                    elseif ($compFileName -eq "MAR-002") {
                                                                                    $hostNameValue = $hostNameArray[24]
                                                                                    $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                                                    $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                                                    $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                                                    }
                                                                                elseif ($compFileName -eq "MAR-003") {
                                                                                $hostNameValue = $hostNameArray[25]
                                                                                $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                                                $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                                                $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                                                }                    
                                                                            elseif ($compFileName -eq "MAR-004") {
                                                                            $hostNameValue = $hostNameArray[26]
                                                                            $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                                            $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                                            $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                                            }                   
                                                                        elseif ($compFileName -eq "MAR-005") {
                                                                        $hostNameValue = $hostNameArray[27]
                                                                        $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                                        $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                                        $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                                        }
                                                                    elseif ($compFileName -eq "MAR-006") {
                                                                    $hostNameValue = $hostNameArray[28]
                                                                    $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                                    $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                                    $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                                    }
                                                                elseif ($compFileName -eq "MAR-007") {
                                                                $hostIPValue = $hostNameArray[29]
                                                                $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                                $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                                $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                                }
                                                            elseif ($compFileName -eq "MAR-008") {
                                                            $hostNameValue = $hostNameArray[30]
                                                            $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                            $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                            $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                            }  
                                                        elseif ($compFileName -eq "MAR-009") {
                                                        $hostNameValue = $hostNameArray[31]
                                                        $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                        $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                        $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                        }
                                                    elseif ($compFileName -eq "MAR-010") {
                                                    $hostNameValue = $hostNameArray[32]
                                                    $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                    $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                    $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                    } 
                                                elseif ($compFileName -eq "MAR-011") {
                                                $hostNameValue = $hostNameArray[33]
                                                $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                                $selectedTags_HostName.Node.InnerText = $hostNameValue
                                                $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                                }
                                            elseif ($compFileName -eq "MAR-012") {
                                            $hostNameValue = $hostNameArray[34]
                                            $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                            $selectedTags_HostName.Node.InnerText = $hostNameValue
                                            $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                            }
                                        elseif ($compFileName -eq "MAR-013") {
                                        $hostNameValue = $hostNameArray[35]
                                        $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                        $selectedTags_HostName.Node.InnerText = $hostNameValue
                                        $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                        }  
                                    elseif ($compFileName -eq "MAR-014") {
                                    $hostNameValue = $hostNameArray[36]
                                    $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                    $selectedTags_HostName.Node.InnerText = $hostNameValue
                                    $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                    }
                                elseif ($compFileName -eq "MAR-015") {
                                $hostNameValue = $hostNameArray[37]
                                $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                                $selectedTags_HostName.Node.InnerText = $hostNameValue
                                $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                                }
                            elseif ($compFileName -eq "MAR-016") {
                            $hostNameValue = $hostNameArray[38]
                            $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                            $selectedTags_HostName.Node.InnerText = $hostNameValue
                            $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                            }
                        elseif ($compFileName -eq "MAR-017") {
                        $hostNameValue = $hostNameArray[39]
                        $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                        $selectedTags_HostName.Node.InnerText = $hostNameValue
                        $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                        }
                    elseif ($compFileName -eq "MAR-018") {
                    $hostNameValue = $hostNameArray[40]
                    $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                    $selectedTags_HostName.Node.InnerText = $hostNameValue
                    $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                    }
                elseif ($compFileName -eq "MAR-019") {
                $hostNameValue = $hostNameArray[41]
                $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
                $selectedTags_HostName.Node.InnerText = $hostNameValue
                $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
                }
            elseif ($compFileName -eq "MAR-020") {
            $hostNameValue = $hostNameArray[42]
            $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
            $selectedTags_HostName.Node.InnerText = $hostNameValue
            $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
            }
        elseif ($compFileName -eq "MAR-021") {
        $hostNameValue = $hostNameArray[43]
        $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
        $selectedTags_HostName.Node.InnerText = $hostNameValue
        $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
        }
    elseif ($compFileName -eq "MAR-022") {
    $hostNameValue = $hostNameArray[44]
    $selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
    $selectedTags_HostName.Node.InnerText = $hostNameValue
    $selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
    }
elseif ($compFileName -eq "MAR-023") {
$hostNameValue = $hostNameArray[45]
$selectedTags_HostName = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostName
$selectedTags_HostName.Node.InnerText = $hostNameValue
$selectedTags_HostName.Node.OwnerDocument.Save($file.FullName)
}
                    

# Retrieve and update the MOB HOST_IP element
if ($compFileName -eq "MOB-001") {
$hostIPValue = $hostIPArray[0]
$selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
$selectedTags_HostIP.Node.InnerText = $hostIPValue
$selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
}
    elseif ($compFileName -eq "MOB-002") {
    $hostIPValue = $hostIPArray[1]
    $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
    $selectedTags_HostIP.Node.InnerText = $hostIPValue
    $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
    }
        elseif ($compFileName -eq "MOB-003") {
        $hostIPValue = $hostIPArray[2]
        $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
        $selectedTags_HostIP.Node.InnerText = $hostIPValue
        $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
        }
            elseif ($compFileName -eq "MOB-004") {
            $hostIPValue = $hostIPArray[3]
            $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
            $selectedTags_HostIP.Node.InnerText = $hostIPValue
            $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
            }
                elseif ($compFileName -eq "MOB-005") {
                $hostIPValue = $hostIPArray[4]
                $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                $selectedTags_HostIP.Node.InnerText = $hostIPValue
                $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                }
                    elseif ($compFileName -eq "MOB-006") {
                    $hostIPValue = $hostIPArray[5]
                    $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                    $selectedTags_HostIP.Node.InnerText = $hostIPValue
                    $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                    }
                        elseif ($compFileName -eq "MOB-007") {
                        $hostIPValue = $hostIPArray[6]
                        $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                        $selectedTags_HostIP.Node.InnerText = $hostIPValue
                        $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                        }
                            elseif ($compFileName -eq "MOB-008") {
                            $hostIPValue = $hostIPArray[7]
                            $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                            $selectedTags_HostIP.Node.InnerText = $hostIPValue
                            $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                            }
                                elseif ($compFileName -eq "MOB-009") {
                                $hostIPValue = $hostIPArray[8]
                                $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                }
                                    elseif ($compFileName -eq "MOB-010") {
                                    $hostIPValue = $hostIPArray[9]
                                    $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                    $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                    $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                    }
                                        elseif ($compFileName -eq "MOB-011") {
                                        $hostIPValue = $hostIPArray[10]
                                        $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                        $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                        $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                        }
                                            elseif ($compFileName -eq "MOB-012") {
                                            $hostIPValue = $hostIPArray[11]
                                            $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                            $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                            $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                            }
                                                elseif ($compFileName -eq "MOB-013") {
                                                $hostIPValue = $hostIPArray[12]
                                                $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                }
                                                    elseif ($compFileName -eq "MOB-014") {
                                                    $hostIPValue = $hostIPArray[13]
                                                    $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                    $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                    $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                    }
                                                        elseif ($compFileName -eq "MOB-015") {
                                                        $hostIPValue = $hostIPArray[14]
                                                        $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                        $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                        $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                        }
                                                            elseif ($compFileName -eq "MOB-016") {
                                                            $hostIPValue = $hostIPArray[15]
                                                            $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                            $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                            $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                            }
                                                                elseif ($compFileName -eq "MOB-017") {
                                                                $hostIPValue = $hostIPArray[16]
                                                                $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                                $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                                $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                                }
                                                                    elseif ($compFileName -eq "MOB-018") {
                                                                    $hostIPValue = $hostIPArray[17]
                                                                    $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                                    $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                                    $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                                    }
                                                                        elseif ($compFileName -eq "MOB-019") {
                                                                        $hostIPValue = $hostIPArray[18]
                                                                        $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                                        $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                                        $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                                        }
                                                                            elseif ($compFileName -eq "MOB-020") {
                                                                            $hostIPValue = $hostIPArray[19]
                                                                            $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                                            $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                                            $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                                            }
                                                                                elseif ($compFileName -eq "MOB-021") {
                                                                                $hostIPValue = $hostIPArray[20]
                                                                                $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                                                $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                                                $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                                                }
                                                                                    elseif ($compFileName -eq "MOB-022") {
                                                                                    $hostIPValue = $hostIPArray[21]
                                                                                    $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                                                    $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                                                    $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                                                    }
                                                                                        elseif ($compFileName -eq "MOB-023") {
                                                                                        $hostIPValue = $hostIPArray[22]
                                                                                        $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                                                        $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                                                        $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                                                        }
        
        
                                                                                        # Retrieve and update the MAR HOST_IP element
                                                                                        elseif ($compFileName -eq "MAR-001") {
                                                                                        $hostIPValue = $hostIPArray[23]
                                                                                        $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                                                        $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                                                        $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                                                        }
                                                                                    elseif ($compFileName -eq "MAR-002") {
                                                                                    $hostIPValue = $hostIPArray[24]
                                                                                    $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                                                    $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                                                    $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                                                    }
                                                                                elseif ($compFileName -eq "MAR-003") {
                                                                                $hostIPValue = $hostIPArray[25]
                                                                                $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                                                $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                                                $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                                                }
                                                                            elseif ($compFileName -eq "MAR-004") {
                                                                            $hostIPValue = $hostIPArray[26]
                                                                            $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                                            $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                                            $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                                            }
                                                                        elseif ($compFileName -eq "MAR-005") {
                                                                        $hostIPValue = $hostIPArray[27]
                                                                        $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                                        $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                                        $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                                        }
                                                                    elseif ($compFileName -eq "MAR-006") {
                                                                    $hostIPValue = $hostIPArray[28]
                                                                    $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                                    $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                                    $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                                    }
                                                                elseif ($compFileName -eq "MAR-007") {
                                                                $hostIPValue = $hostIPArray[29]
                                                                $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                                $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                                $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                                }
                                                            elseif ($compFileName -eq "MAR-008") {
                                                            $hostIPValue = $hostIPArray[30]
                                                            $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                            $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                            $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                            }
                                                        elseif ($compFileName -eq "MAR-009") {
                                                        $hostIPValue = $hostIPArray[31]
                                                        $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                        $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                        $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                        }
                                                    elseif ($compFileName -eq "MAR-010") {
                                                    $hostIPValue = $hostIPArray[32]
                                                    $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                    $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                    $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                    }
                                                elseif ($compFileName -eq "MAR-011") {
                                                $hostIPValue = $hostIPArray[33]
                                                $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                                $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                                $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                                }
                                            elseif ($compFileName -eq "MAR-012") {
                                            $hostIPValue = $hostIPArray[34]
                                            $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                            $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                            $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                            }
                                        elseif ($compFileName -eq "MAR-013") {
                                        $hostIPValue = $hostIPArray[35]
                                        $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                        $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                        $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                        }
                                    elseif ($compFileName -eq "MAR-014") {
                                    $hostIPValue = $hostIPArray[36]
                                    $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                    $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                    $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                    }
                                elseif ($compFileName -eq "MAR-015") {
                                $hostIPValue = $hostIPArray[37]
                                $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                                $selectedTags_HostIP.Node.InnerText = $hostIPValue
                                $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                                }
                            elseif ($compFileName -eq "MAR-016") {
                            $hostIPValue = $hostIPArray[38]
                            $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                            $selectedTags_HostIP.Node.InnerText = $hostIPValue
                            $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                            }
                        elseif ($compFileName -eq "MAR-017") {
                        $hostIPValue = $hostIPArray[39]
                        $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                        $selectedTags_HostIP.Node.InnerText = $hostIPValue
                        $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                        }
                    elseif ($compFileName -eq "MAR-018") {
                    $hostIPValue = $hostIPArray[40]
                    $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                    $selectedTags_HostIP.Node.InnerText = $hostIPValue
                    $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                    }
                elseif ($compFileName -eq "MAR-019") {
                $hostIPValue = $hostIPArray[41]
                $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
                $selectedTags_HostIP.Node.InnerText = $hostIPValue
                $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
                }
            elseif ($compFileName -eq "MAR-020") {
            $hostIPValue = $hostIPArray[42]
            $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
            $selectedTags_HostIP.Node.InnerText = $hostIPValue
            $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
            }
        elseif ($compFileName -eq "MAR-021") {
        $hostIPValue = $hostIPArray[43]
        $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
        $selectedTags_HostIP.Node.InnerText = $hostIPValue
        $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
        }
    elseif ($compFileName -eq "MAR-022") {
    $hostIPValue = $hostIPArray[44]
    $selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
    $selectedTags_HostIP.Node.InnerText = $hostIPValue
    $selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
    }
elseif ($compFileName -eq "MAR-023") {
$hostIPValue = $hostIPArray[45]
$selectedTags_HostIP = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostIP
$selectedTags_HostIP.Node.InnerText = $hostIPValue
$selectedTags_HostIP.Node.OwnerDocument.Save($file.FullName)
}




# Retrieve and update the MOB HOST_MAC element
if ($compFileName -eq "MOB-001") {
$hostMACValue = $hostMACArray[0]
$selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
$selectedTags_HostMAC.Node.InnerText = $hostMACValue
$selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
}
    elseif ($compFileName -eq "MOB-002") {
    $hostMACValue = $hostMACArray[1]
    $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
    $selectedTags_HostMAC.Node.InnerText = $hostMACValue
    $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
    }
        elseif ($compFileName -eq "MOB-003") {
        $hostMACValue = $hostMACArray[2]
        $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
        $selectedTags_HostMAC.Node.InnerText = $hostMACValue
        $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
        }
            elseif ($compFileName -eq "MOB-004") {
            $hostMACValue = $hostMACArray[3]
            $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
            $selectedTags_HostMAC.Node.InnerText = $hostMACValue
            $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
            }
                elseif ($compFileName -eq "MOB-005") {
                $hostMACValue = $hostMACArray[4]
                $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                }
                    elseif ($compFileName -eq "MOB-006") {
                    $hostMACValue = $hostMACArray[5]
                    $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                    $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                    $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                    }
                        elseif ($compFileName -eq "MOB-007") {
                        $hostMACValue = $hostMACArray[6]
                        $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                        $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                        $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                        }
                            elseif ($compFileName -eq "MOB-008") {
                            $hostMACValue = $hostMACArray[7]
                            $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                            $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                            $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                            }
                                elseif ($compFileName -eq "MOB-009") {
                                $hostMACValue = $hostMACArray[8]
                                $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                }
                                    elseif ($compFileName -eq "MOB-010") {
                                    $hostMACValue = $hostMACArray[9]
                                    $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                    $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                    $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                    }
                                        elseif ($compFileName -eq "MOB-011") {
                                        $hostMACValue = $hostMACArray[10]
                                        $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                        $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                        $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                        }
                                            elseif ($compFileName -eq "MOB-012") {
                                            $hostMACValue = $hostMACArray[11]
                                            $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                            $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                            $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                            }
                                                elseif ($compFileName -eq "MOB-013") {
                                                $hostMACValue = $hostMACArray[12]
                                                $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                }
                                                    elseif ($compFileName -eq "MOB-014") {
                                                    $hostMACValue = $hostMACArray[13]
                                                    $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                    $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                    $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                    }
                                                        elseif ($compFileName -eq "MOB-015") {
                                                        $hostMACValue = $hostMACArray[14]
                                                        $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                        $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                        $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                        }
                                                            elseif ($compFileName -eq "MOB-016") {
                                                            $hostMACValue = $hostMACArray[15]
                                                            $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                            $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                            $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                            }
                                                                elseif ($compFileName -eq "MOB-017") {
                                                                $hostMACValue = $hostMACArray[16]
                                                                $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                                $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                                $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                                }
                                                                    elseif ($compFileName -eq "MOB-018") {
                                                                    $hostMACValue = $hostMACArray[17]
                                                                    $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                                    $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                                    $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                                    }
                                                                        elseif ($compFileName -eq "MOB-019") {
                                                                        $hostMACValue = $hostMACArray[18]
                                                                        $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                                        $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                                        $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                                        }
                                                                            elseif ($compFileName -eq "MOB-020") {
                                                                            $hostMACValue = $hostMACArray[19]
                                                                            $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                                            $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                                            $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                                            }
                                                                                elseif ($compFileName -eq "MOB-021") {
                                                                                $hostMACValue = $hostMACArray[20]
                                                                                $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                                                $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                                                $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                                                }
                                                                                    elseif ($compFileName -eq "MOB-022") {
                                                                                    $hostMACValue = $hostMACArray[21]
                                                                                    $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                                                    $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                                                    $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                                                    }
                                                                                        elseif ($compFileName -eq "MOB-023") {
                                                                                        $hostMACValue = $hostMACArray[22]
                                                                                        $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                                                        $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                                                        $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                                                        }                                                                                                                                                                               
                                                                                        
                                                                                        # Retrieve and update the MAR HOST_MAC element
                                                                                        elseif ($compFileName -eq "MAR-001") {
                                                                                        $hostMACValue = $hostMACArray[23]
                                                                                        $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                                                        $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                                                        $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName) 
                                                                                        }                                                                                       
                                                                                    elseif ($compFileName -eq "MAR-002") {
                                                                                    $hostMACValue = $hostMACArray[24]
                                                                                    $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                                                    $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                                                    $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                                                    }                                                                                    
                                                                                elseif ($compFileName -eq "MAR-003") {
                                                                                $hostMACValue = $hostMACArray[25]
                                                                                $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                                                $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                                                $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                                                }
                                                                            elseif ($compFileName -eq "MAR-004") {
                                                                            $hostMACValue = $hostMACArray[26]
                                                                            $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                                            $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                                            $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                                            }
                                                                        elseif ($compFileName -eq "MAR-005") {
                                                                        $hostMACValue = $hostMACArray[27]
                                                                        $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                                        $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                                        $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                                        }
                                                                    elseif ($compFileName -eq "MAR-006") {
                                                                    $hostMACValue = $hostMACArray[28]
                                                                    $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                                    $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                                    $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                                    }
                                                                elseif ($compFileName -eq "MAR-007") {
                                                                $hostMACValue = $hostMACArray[29]
                                                                $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                                $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                                $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                                }
                                                            elseif ($compFileName -eq "MAR-008") {
                                                            $hostMACValue = $hostMACArray[30]
                                                            $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                            $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                            $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                            }
                                                        elseif ($compFileName -eq "MAR-009") {
                                                        $hostMACValue = $hostMACArray[31]
                                                        $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                        $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                        $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                        }
                                                    elseif ($compFileName -eq "MAR-010") {
                                                    $hostMACValue = $hostMACArray[32]
                                                    $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                    $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                    $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                    }
                                                elseif ($compFileName -eq "MAR-011") {
                                                $hostMACValue = $hostMACArray[33]
                                                $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                                $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                                $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                                }
                                            elseif ($compFileName -eq "MAR-012") {
                                            $hostMACValue = $hostMACArray[34]
                                            $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                            $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                            $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                            }
                                        elseif ($compFileName -eq "MAR-013") {
                                        $hostMACValue = $hostMACArray[35]
                                        $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                        $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                        $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                        }
                                    elseif ($compFileName -eq "MAR-014") {
                                    $hostMACValue = $hostMACArray[36]
                                    $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                    $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                    $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                    }
                                elseif ($compFileName -eq "MAR-015") {
                                $hostMACValue = $hostMACArray[37]
                                $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                                $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                                $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                                }
                            elseif ($compFileName -eq "MAR-016") {
                            $hostMACValue = $hostMACArray[38]
                            $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                            $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                            $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                            }
                        elseif ($compFileName -eq "MAR-017") {
                        $hostMACValue = $hostMACArray[39]
                        $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                        $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                        $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                        }
                    elseif ($compFileName -eq "MAR-018") {
                    $hostMACValue = $hostMACArray[40]
                    $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                    $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                    $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                    }
                elseif ($compFileName -eq "MAR-019") {
                $hostMACValue = $hostMACArray[41]
                $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
                $selectedTags_HostMAC.Node.InnerText = $hostMACValue
                $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
                }
            elseif ($compFileName -eq "MAR-020") {
            $hostMACValue = $hostMACArray[42]
            $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
            $selectedTags_HostMAC.Node.InnerText = $hostMACValue
            $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
            }
        elseif ($compFileName -eq "MAR-021") {
        $hostMACValue = $hostMACArray[43]
        $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
        $selectedTags_HostMAC.Node.InnerText = $hostMACValue
        $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
        }
    elseif ($compFileName -eq "MAR-022") {
    $hostMACValue = $hostMACArray[44]
    $selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
    $selectedTags_HostMAC.Node.InnerText = $hostMACValue
    $selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
    }
elseif ($compFileName -eq "MAR-023") {
$hostMACValue = $hostMACArray[45]
$selectedTags_HostMAC = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostMAC
$selectedTags_HostMAC.Node.InnerText = $hostMACValue
$selectedTags_HostMAC.Node.OwnerDocument.Save($file.FullName)
}


    
    

    
# Retrieve and update the MOB Host_FQDN element
if ($compFileName -eq "MOB-001") {
$hostFQDNValue = $hostNameArray[0] + "."
$selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
$selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
$selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
}
    elseif ($compFileName -eq "MOB-002") {
    $hostFQDNValue = $hostNameArray[1] + "."
    $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
    $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
    $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
    }
        elseif ($compFileName -eq "MOB-003") {
        $hostFQDNValue = $hostNameArray[2] + "."
        $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
        $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
        $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
        }
            elseif ($compFileName -eq "MOB-004") {
            $hostFQDNValue = $hostNameArray[3] + "."
            $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
            $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
            $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
            }
                elseif ($compFileName -eq "MOB-005") {
                $hostFQDNValue = $hostNameArray[4] + "."
                $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                }
                    elseif ($compFileName -eq "MOB-006") {
                    $hostFQDNValue = $hostNameArray[5] + "."
                    $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                    $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                    $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                    }
                        elseif ($compFileName -eq "MOB-007") {
                        $hostFQDNValue = $hostNameArray[6] + "."
                        $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                        $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                        $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                        }
                            elseif ($compFileName -eq "MOB-008") {
                            $hostFQDNValue = $hostNameArray[7] + "."
                            $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                            $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                            $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                            }
                                elseif ($compFileName -eq "MOB-009") {
                                $hostFQDNValue = $hostNameArray[8] + "."
                                $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                }
                                    elseif ($compFileName -eq "MOB-010") {
                                    $hostFQDNValue = $hostNameArray[9] + "."
                                    $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                    $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                    $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                    }
                                        elseif ($compFileName -eq "MOB-011") {
                                        $hostFQDNValue = $hostNameArray[10] + "."
                                        $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                        $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                        $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                        }
                                            elseif ($compFileName -eq "MOB-012") {
                                            $hostFQDNValue = $hostNameArray[11] + "."
                                            $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                            $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                            $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                            }
                                                elseif ($compFileName -eq "MOB-013") {
                                                $hostFQDNValue = $hostNameArray[12] + "."
                                                $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                }
                                                    elseif ($compFileName -eq "MOB-014") {
                                                    $hostFQDNValue = $hostNameArray[13] + "."
                                                    $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                    $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                    $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                    }
                                                        elseif ($compFileName -eq "MOB-015") {
                                                        $hostFQDNValue = $hostNameArray[14] + "."
                                                        $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                        $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                        $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                        }
                                                            elseif ($compFileName -eq "MOB-016") {
                                                            $hostFQDNValue = $hostNameArray[15] + "."
                                                            $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                            $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                            $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                            }
                                                                elseif ($compFileName -eq "MOB-017") {
                                                                $hostFQDNValue = $hostNameArray[16] + "."
                                                                $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                                $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                                $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                                }
                                                                    elseif ($compFileName -eq "MOB-018") {
                                                                    $hostFQDNValue = $hostNameArray[17] + "."
                                                                    $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                                    $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                                    $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                                    }
                                                                        elseif ($compFileName -eq "MOB-019") {
                                                                        $hostFQDNValue = $hostNameArray[18] + "."
                                                                        $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                                        $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                                        $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                                        }
                                                                            elseif ($compFileName -eq "MOB-020") {
                                                                            $hostFQDNValue = $hostNameArray[19] + "."
                                                                            $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                                            $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                                            $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                                            }
                                                                                elseif ($compFileName -eq "MOB-021") {
                                                                                $hostFQDNValue = $hostNameArray[20] + "."
                                                                                $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                                                $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                                                $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                                                }
                                                                                    elseif ($compFileName -eq "MOB-022") {
                                                                                    $hostFQDNValue = $hostNameArray[21] + "."
                                                                                    $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                                                    $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                                                    $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                                                    }
                                                                                        elseif ($compFileName -eq "MOB-023") {
                                                                                        $hostFQDNValue = $hostNameArray[22] + "."
                                                                                        $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                                                        $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                                                        $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                                                        }
                                                                                        
                                                                                        # Retrieve and update the MAR Host_FQDN element
                                                                                        elseif ($compFileName -eq "MAR-001") {
                                                                                        $hostFQDNValue = $hostNameArray[23] + "."
                                                                                        $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                                                        $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                                                        $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                                                        }
                                                                                    elseif ($compFileName -eq "MAR-002") {
                                                                                    $hostFQDNValue = $hostNameArray[24] + "."
                                                                                    $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                                                    $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                                                    $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                                                    }
                                                                                elseif ($compFileName -eq "MAR-003") {
                                                                                $hostFQDNValue = $hostNameArray[25] + "."
                                                                                $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                                                $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                                                $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                                                }
                                                                            elseif ($compFileName -eq "MAR-004") {
                                                                            $hostFQDNValue = $hostNameArray[26] + "."
                                                                            $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                                            $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                                            $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                                            }
                                                                        elseif ($compFileName -eq "MAR-005") {
                                                                        $hostFQDNValue = $hostNameArray[27] + "."
                                                                        $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                                        $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                                        $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                                        }
                                                                    elseif ($compFileName -eq "MAR-006") {
                                                                    $hostFQDNValue = $hostNameArray[28] + "."
                                                                    $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                                    $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                                    $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                                    }
                                                                elseif ($compFileName -eq "MAR-007") {
                                                                $hostFQDNValue = $hostNameArray[29] + "."
                                                                $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                                $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                                $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                                }
                                                            elseif ($compFileName -eq "MAR-008") {
                                                            $hostFQDNValue = $hostNameArray[30] + "."
                                                            $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                            $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                            $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                            }
                                                        elseif ($compFileName -eq "MAR-009") {
                                                        $hostFQDNValue = $hostNameArray[31] + "."
                                                        $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                        $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                        $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                        }
                                                    elseif ($compFileName -eq "MAR-010") {
                                                    $hostFQDNValue = $hostNameArray[32] + "."
                                                    $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                    $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                    $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                    }
                                                elseif ($compFileName -eq "MAR-011") {
                                                $hostFQDNValue = $hostNameArray[33] + "."
                                                $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                                $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                                $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                                }
                                            elseif ($compFileName -eq "MAR-012") {
                                            $hostFQDNValue = $hostNameArray[34] + "."
                                            $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                            $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                            $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                            }
                                        elseif ($compFileName -eq "MAR-013") {
                                        $hostFQDNValue = $hostNameArray[35] + "."
                                        $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                        $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                        $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                        }
                                    elseif ($compFileName -eq "MAR-014") {
                                    $hostFQDNValue = $hostNameArray[36] + "."
                                    $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                    $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                    $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                    }
                                elseif ($compFileName -eq "MAR-015") {
                                $hostFQDNValue = $hostNameArray[37] + "."
                                $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                                $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                                $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                                }
                            elseif ($compFileName -eq "MAR-016") {
                            $hostFQDNValue = $hostNameArray[38] + "."
                            $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                            $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                            $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                            }
                        elseif ($compFileName -eq "MAR-017") {
                        $hostFQDNValue = $hostNameArray[39] + "."
                        $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                        $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                        $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                        }
                    elseif ($compFileName -eq "MAR-018") {
                    $hostFQDNValue = $hostNameArray[40] + "."
                    $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                    $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                    $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                    }
                elseif ($compFileName -eq "MAR-019") {
                $hostFQDNValue = $hostNameArray[41] + "."
                $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
                $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
                $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
                }
            elseif ($compFileName -eq "MAR-020") {
            $hostFQDNValue = $hostNameArray[42] + "."
            $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
            $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
            $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
            }
        elseif ($compFileName -eq "MAR-021") {
        $hostFQDNValue = $hostNameArray[43] + "."
        $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
        $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
        $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
        }
    elseif ($compFileName -eq "MAR-022") {
    $hostFQDNValue = $hostNameArray[44] + "."
    $selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
    $selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
    $selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
    }
elseif ($compFileName -eq "MAR-023") {
$hostFQDNValue = $hostNameArray[45] + "."
$selectedTags_HostFQDN = Select-Xml -Path $file.FullName -XPath $xpathExpression_HostFQDN
$selectedTags_HostFQDN.Node.InnerText = $hostFQDNValue
$selectedTags_HostFQDN.Node.OwnerDocument.Save($file.FullName)
}
    
    <#
    # Modify Client ID in filename
    $newFileName = "New_" + (Get-Item $filePath).Name.Substring(7)
    $newFilePath = Join-Path (Split-Path $filePath) $newFileName
    Rename-Item -Path $filePath -NewName $newFileName
    #>


<#Output XML changes to terminal
$xpathExpression = "//ASSET/MARKING | //ASSET/HOST_NAME | //ASSET/HOST_IP | //ASSET/HOST_MAC | //ASSET/HOST_FQDN"
$selectedTags = Select-Xml -Path $file.FullName -XPath $xpathExpression
    $scriptOutput = foreach ($tag in $selectedTags) {
    
    $tagName = $tag.Node.Name
    $tagValue = $tag.Node.InnerText
    Write-Output "file: $($file.FullName)`nTag: $tagName, Value: $tagValue`n
    ---------------------------------------------- 
    "
    
    }#>

}   
$countPath = $folderPath
    $files = Get-ChildItem -Path $folderPath -File # Parse CKL files
    # Count the number of files
    $fileCount = $files | Measure-Object | Select-Object -ExpandProperty Count
    Write-Output "$fileCount files appended to: $folderPath" 
} 
else {
    Write-Host "No file was selected."
}
Start-Sleep 2
Write-Host "Done."