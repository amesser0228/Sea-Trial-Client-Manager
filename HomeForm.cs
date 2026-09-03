using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Deployment.Application;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;
using Sea_Trials_Script_Launcher;
using System.Data.SQLite;
using Microsoft.VisualBasic.Devices;
using System.Net;
using System.Drawing.Text;
using System.Management;
using System.Runtime.CompilerServices;
using System.Diagnostics.Eventing.Reader;

namespace Sea_Trials_Script_Launcher
{
    public partial class HomeForm : Form
    {
        private System.Windows.Forms.ToolTip toolTip;
        // instance fields for dataBase class
        private SeaTrialsDatabase database;
        private DataGridView dataGridView1;
        public string OSCaption;
        public string STCM_NotesFilePath;
        public string Trial_HullInfoFilePath;
        public Version appVersion;

        public HomeForm()
        {
            InitializeComponent();
            //SetVersionNumber();
            SetFormTitleVersion();
            CopyScriptsToUserDirectory();
            GenerateSessionId();
            database = new SeaTrialsDatabase("SeaTrials.db");
            LockBtn.Text = "Lock 🔒";
            STCM_NotesFilePath = Path.Combine(Application.StartupPath, "STCMNotesFile.txt");
            Trial_HullInfoFilePath = Path.Combine(Application.StartupPath, "Trial_HullInfoFile.txt");
            checkAndCreateNotesFiles();
            toolTip = new System.Windows.Forms.ToolTip();

            //menuItemsToolTip.Popup += new PopupEventHandler(menuItemsToolTip_Popup);

            //tool tip text for script buttons
            toolTipHelper.SetToolTip(Remote_Command_Btn, "This script allows you to remotely send a command to all clients in the chosen batch.\n*This script can be edited*");

            toolTipHelper.SetToolTip(button3, "Enables connection to clinets through PSRemote and Trusted Hosts. *THIS ONLY NEEDS TO BE RUN ONCE");

            toolTipHelper.SetToolTip(button1, "This script allows you to select and power down all clients on the network.\n*This script can be edited*");

            toolTipHelper.SetToolTip(removeItemBtn, "This script adds the network printer per its batch to its clients.\n*This script can be edited*");

            toolTipHelper.SetToolTip(button12, "This script allows you to set production policies including AutoAdminLogon and no machine inactivity timeout to all clients in the selected batch.");

            toolTipHelper.SetToolTip(button13, "This script undoes the production policies and sets NIST policies on all clients in the selected batch.");

            toolTipHelper.SetToolTip(button4, "This script allows you to run a report on all clients in the selected batch. A CSV file is exported after the report data is collected.");

            toolTipHelper.SetToolTip(button2, "This script lets you make 23 copies of a local CKL file with incrementing host numbers in the filenames.");

            toolTipHelper.SetToolTip(CKL_Edit_Btn, "This script lets you modify all CKL files in a single folder according to each filename.");

            toolTipHelper.SetToolTip(button8, "This script lets you modify Evaluate-STIG generated CKL files correcting files with missing finding details or comments.");

            toolTipHelper.SetToolTip(button5, "This script allows you to check the network status of all clients in the selected batch.");

            toolTipHelper.SetToolTip(Remote_Script_Btn, "This script allows you to run a client-side script on all clients in the selected batch.");

            openScriptsDirectoryToolStripMenuItem.ToolTipText = "WARNING! Modifying scripts in this folder can break this application.";

            toolsToolStripMenuItem.ToolTipText = "help";

            OSCaption = GetOSCaption();
        }
        private void SetFormTitleVersion()
        {
            string versionString = GetTitleVersionNumber();
            this.Text = $"Sea Trial Client Manager {versionString} - (CUI) PMS 501/378";
        }

        // Set version number in form title
        private string GetTitleVersionNumber()
        {
            appVersion = Assembly.GetExecutingAssembly().GetName().Version;
            return $"v.{appVersion}";
        }

        

        public void checkAndCreateNotesFiles()
        {
            if (!File.Exists(STCM_NotesFilePath))
            {
                File.Create(STCM_NotesFilePath).Close();
            }
            if (!File.Exists(Trial_HullInfoFilePath))
            {
                File.Create(Trial_HullInfoFilePath).Close();
            }
        }

        public string GetOSCaption()
        {
            try
            {
                ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT Caption FROM Win32_OperatingSystem");
                foreach (ManagementObject obj in searcher.Get())
                {
                    OSCaption = obj["Caption"].ToString();
                    break;
                }
                //MessageBox.Show(OSCaption);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error retrieving OS caption " + ex.Message);
            }
            return OSCaption;
        }

        public void ApplyMachineType()
        {
            if (OSCaption.Contains("Windows 10") || OSCaption.Contains("Windows 11"))
            {
                OSNameLabel.Text = "Workstation";
            }
            else if (OSCaption.Contains("Windows Server"))
            {
                OSNameLabel.Text = "Server";
            }
            else
            {
                OSNameLabel.Text = "UNAVAILABLE";
            }
        }


        //Private helper to load DataTable data to export view
        private void LoadData()
        {
            DataTable dataTable = database.GetData();
            dataGridView1.DataSource = dataTable;
        }


        // helper method for Form1_Load()
        public void CopyScriptsToUserDirectory()
        {
            string sourceDirectory = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "VS Scripts");
            string targetDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "VS_Scripts");

            if (!Directory.Exists(targetDirectory))
            {
                Directory.CreateDirectory(targetDirectory);
                foreach (var file in Directory.GetFiles(sourceDirectory))
                {
                    string fileName = Path.GetFileName(file);
                    string destFile = Path.Combine(targetDirectory, fileName);
                    File.Copy(file, destFile, true);
                }
            }
        }

        //main form load method
        private void Form1_Load(object sender, EventArgs e)
        {

            dontShowLoginScreenToolStripMenuItem.Checked = Properties.Settings.Default.ShowLoginScreenSetting;

            if (!Properties.Settings.Default.ShowLoginScreenSetting)
            {
                using (loginForm loginFormWindow = new loginForm())
                {
                    if (loginFormWindow.ShowDialog() != DialogResult.OK)
                    {
                        this.Close(); // Close the main form if login fails
                    }
                }
            }

            menuItemsToolTip.Active = true;
            menuItemsToolTip.AutomaticDelay = 500;
            menuItemsToolTip.ReshowDelay = 100;
            menuItemsToolTip.AutoPopDelay = 5000;
            menuItemsToolTip.InitialDelay = 500;
            menuItemsToolTip.OwnerDraw = false;
            menuItemsToolTip.ShowAlways = true;
            menuItemsToolTip.ToolTipIcon = ToolTipIcon.Info;

            CopyScriptsToUserDirectory();
            ApplyMachineType();

            string osType = GetOperatingSystemType();

            if (osType == "Server")
            {
                OSNameLabel.Text = "SERVER OS";
            }
            else if (osType == "Client")
            {
                OSNameLabel.Text = "WINDOWS OS";
            }
            else
            {
                OSNameLabel.Text = "Unknown OS";
            }

        }

        private string GetOperatingSystemType()
        {
            try
            {
                using (ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT Caption FROM Win32_OperatingSystem"))
                {
                    foreach (ManagementObject os in searcher.Get())
                    {
                        string caption = os["Caption"].ToString();
                        if (caption.Contains("Server"))
                        {
                            return "Server";
                        }
                        else
                        {
                            return "Client";
                        }
                    }
                }
                return "Unknown";
            }
            catch
            {
                return "Unknown";
            }
}


        //Helper method for editable PS scripts
        private void RunScript(string scriptName)
        {
            string folderPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "VS_Scripts");
            string scriptPath = Path.Combine(folderPath, scriptName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{scriptPath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
            // Execute the script from the user-accessible directory
        }

        //private void SetVersionNumber()
        //{
        //    Version version = Assembly.GetExecutingAssembly().GetName().Version;
        //    label7.Text = $"Version {version}";
        //}

        

        ////////// BUTTON EVENT HANDLERS //////////

        private void button1_Click(object sender, EventArgs e)
        {
            //string scriptPath = @"D:\Scripts\PS Scripts\Working\Script A\PMS501_BaselineImage_Configuration.ps1";
            string fileName = "PMS501_BaselineImage_Configuration.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void button2_Click(object sender, EventArgs e)
        {
            string fileName = "PMS501-CACI_CKL_EDITOR.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.RedirectStandardOutput = true;
            startInfo.RedirectStandardError = true;
            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = true;

            Process process = new Process();
            process.StartInfo = startInfo;
            process.OutputDataReceived += (s, ev) => { if (ev.Data != null) MessageBox.Show(ev.Data); };
            process.ErrorDataReceived += (s, ev) => { if (ev.Data != null) MessageBox.Show(ev.Data); };
            process.Start();
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
            process.WaitForExit();
        }

        private void button3_Click(object sender, EventArgs e)
        {
            RunScript("run_script_remote_host_v2.7.ps1");
        }

        private void button4_Click(object sender, EventArgs e)
        {
            RunScript("run_command_remote_host_v2.8.ps1");
        }

        private void button1_Click_1(object sender, EventArgs e)
        {
            RunScript("powerOffHosts.ps1");
        }

        private void button3_Click_1(object sender, EventArgs e)
        {
            string fileName;
            fileName = "enable_Connection_To_Clients.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void button2_Click_1(object sender, EventArgs e)
        {
            string fileName = "PMS501-CACI_CKL_COPIER_Evaluate-STIG.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }


        private void button4_Click_1(object sender, EventArgs e)
        {
            string fileName = "createClientSystemReport.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void restartAllClientsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string fileName = "restart_all_clients.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void generalInformationToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string helpText = "Here is the help information you need to add for the user to see.";
            Help_Form helpForm = new Help_Form(helpText);
            helpForm.ShowDialog();
        }

        private void scriptHelpToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string scriptHelpText = "Here is the help information you need to add for the user to see.";
            Script_Help_Form helpFormScript = new Script_Help_Form(scriptHelpText);
            helpFormScript.ShowDialog();
        }

        private void aboutToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string aboutText = "Here is the help information you need to add for the user to see.";
            aboutForm aboutFormText = new aboutForm(aboutText);
            aboutFormText.ShowDialog();
        }

        private void remoteCommandsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string commandHelpText = "Here is the help information you need to add for the user to see.";
            remoteCommandsForm commandText = new remoteCommandsForm(commandHelpText);
            commandText.ShowDialog();
        }

        private void internalScriptsDiorectoryToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string scriptViewer = "";
            internalScriptViewer viewerForm = new internalScriptViewer(scriptViewer);
            viewerForm.ShowDialog();
        }



        private void setProdPoliciesOnClientsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string fileName = "set_Prod_Policies_On_Windows.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void addNetworkmToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string fileName = "addNetworkPrinter.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }


        private void refreshToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Application.Restart();
        }

        private void openScriptsDirectoryToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string password = "L-3Communicati0ns!"; // Set your password here
            string input = Microsoft.VisualBasic.Interaction.InputBox("*WARNING*\nChanging automation scripts can cause bugs and damage computers. \n\nEnter the password to open the scripts directory:", "Password Required", "");

            if (input == password)
            {
                string folderPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "VS_Scripts");
                Process.Start("explorer.exe", folderPath);
            }
            else
            {
                MessageBox.Show("Incorrect password. Access denied.");
            }
        }

        private void button6_Click(object sender, EventArgs e)
        {
            // Define the target directory
            string targetDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "VS_Scripts");

            // Add your logic to remove the directory
            if (Directory.Exists(targetDirectory))
            {
                Directory.Delete(targetDirectory, true); // 'true' to remove any subdirectories and files
                Console.WriteLine($"{targetDirectory} has been deleted.");
                MessageBox.Show("Script folder has been removed.");
            }
            else
            {
                Console.WriteLine($"{targetDirectory} does not exist.");
                MessageBox.Show("location does not exist or the folder has already been removed.");
            }
        }


        private void button5_Click(object sender, EventArgs e)
        {
            string fileName = "checkClientStatus.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void button7_Click_1(object sender, EventArgs e)
        {
            RunScript("addNetworkPrinter.ps1");
        }


        private void button8_Click(object sender, EventArgs e)
        {
            RunScript("e-s_Ckl_Edit.ps1");
        }


        private void button12_Click(object sender, EventArgs e)
        {
            string fileName = "set_Prod_Policies_On_Windows.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void button13_Click(object sender, EventArgs e)
        {
            string fileName = "setNISTPolicies.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void enableAutoAdminLogonToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string fileName = "enableAutoAdminLogon.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void copyAllScriptsToLocalMachineToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string fileName = "save_VS_Script_ToLocalMachine.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.RedirectStandardOutput = true;
            startInfo.RedirectStandardError = true;
            startInfo.UseShellExecute = false;
            startInfo.CreateNoWindow = true;

            Process process = new Process();
            process.StartInfo = startInfo;
            process.OutputDataReceived += (s, ev) => { if (ev.Data != null) MessageBox.Show(ev.Data); };
            process.ErrorDataReceived += (s, ev) => { if (ev.Data != null) MessageBox.Show(ev.Data); };
            process.Start();
            process.BeginOutputReadLine();
            process.BeginErrorReadLine();
            process.WaitForExit();
        }

        private void helpRunningScriptsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string helpRunningScriptsText = "Here is the help information you need to add for the user to see.";
            helpRunningScriptsForm helpRunningScriptsFormText = new helpRunningScriptsForm(helpRunningScriptsText);
            helpRunningScriptsFormText.ShowDialog();
        }

        private void button17_Click(object sender, EventArgs e)
        {
            string fileName = "informationFinder.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void troubleshooterToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string fileName = "troubleshootConnectionIssues.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void button18_Click(object sender, EventArgs e)
        {
            string fileName = "copyItemToClient.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            //startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void copyFolderToClients_Click(object sender, EventArgs e)
        {
            string fileName = "copyFolderToClients.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            //startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void removeItemBtn_Click(object sender, EventArgs e)
        {
            string fileName = "removeItemFromClient.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void sendMsgToClientsBtn_Click(object sender, EventArgs e)
        {
            string fileName = "sendNetMessageToClients.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void copyAllEvalSTIGCKLsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string fileName = "copyE-SCKLFiles.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void prepAndRunEvalSTIGOnClientsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string fileName = "eval-STIGScanPrep.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void nessusScanPrepToolStripMenuItem1_Click(object sender, EventArgs e)
        {
            string fileName = "nessusScanPrep.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void button7_Click_2(object sender, EventArgs e)
        {
            string fileName = "setScanPolicies.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void clearEvalSTIGOutputFolderToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string fileName = "clearEval-STIGOutputFolder.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void clearFolderContentsBtn_Click(object sender, EventArgs e)
        {
            string fileName = "removeFolderContents.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void closeoutChecklistToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string dataBaseFormTextField = "Here is the help information you need to add for the user to see.";
            dataBaseForm dataBaseFormText = new dataBaseForm(dataBaseFormTextField);
            dataBaseFormText.ShowDialog();
        }

        private string sessionID;

        private void GenerateSessionId()
        {
            Random rand = new Random();
            sessionID = "STCM-" + rand.Next(50, 205 + 75);
        }

        private void hostInfoBtn_Click(object sender, EventArgs e)
        {
            //get hostname
            string hostname = Dns.GetHostName();

            //get IP address
            var ipAddresses = Dns.GetHostAddresses(hostname);
            string activeIP = "";

            foreach (var ip in ipAddresses)
            {
                if (ip.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork) // IPv4
                {
                    activeIP = ip.ToString();
                    break; // Get the first active IPv4 address
                }
            }

            MessageBox.Show("Hostname: " + hostname + "\n\nLAN IP address: " + activeIP + "\n\nSession ID: " + sessionID + " (Not Needed)", "Host Information");
        }

        private void button24_Click(object sender, EventArgs e)
        {
            string directoryPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "VS Scripts");

            try
            {
                Process.Start(new ProcessStartInfo(directoryPath) { UseShellExecute = true });
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error opening directory: " + ex.Message);
            }
        }


        private void pictureBox1_Click(object sender, EventArgs e)
        {
            string password = "   ";
            string input = Microsoft.VisualBasic.Interaction.InputBox("Secret", "Password Required", "");

            if (input == password)
            {
                string directoryPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "VS Scripts");

                try
                {
                    Process.Start(new ProcessStartInfo(directoryPath) { UseShellExecute = true });
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Error opening directory: " + ex.Message);
                }
            }
            else
            {
                MessageBox.Show("Incorrect password. Access denied.");
            }
        }

        private void LockBtn_Click(object sender, EventArgs e)
        {
            this.Hide();

            loginForm loginFormWindow = new loginForm();
            if (loginFormWindow.ShowDialog() == DialogResult.OK)
            {
                this.Show(); // Show the main form if login is successful
            }
            else
            {
                this.Close(); // Close the main form if login fails
            }
            loginFormWindow.Dispose();

        }

        private void enterTrialAndHullInfoToolStripMenuItem_Click(object sender, EventArgs e)
        {
            EnterTrialInfoForm trialInfoForm = new EnterTrialInfoForm();
            trialInfoForm.ShowDialog();
        }

        private void seaTrialNotesToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (File.Exists(Trial_HullInfoFilePath))
            {
                if (new FileInfo(Trial_HullInfoFilePath).Length == 0)
                {
                    EnterTrialInfoForm enterTrialInfoForm = new EnterTrialInfoForm();
                    enterTrialInfoForm.ShowDialog();
                }
            }
            TrialNotesForm trialNotesForm = new TrialNotesForm();
            trialNotesForm.ShowDialog();
        }

        //Fix Me: ToolTip class is not correctly converting from a forms control object to a menu item object.
        //private void menuItemsToolTip_Popup(object sender, PopupEventArgs e)
        //{
        //    if (e.AssociatedControl == toolsToolStripMenuItem.DropDown)
        //    {
        //        //Point mousePosition = toolsToolStripMenuItem.GetCurrentParent().PointToClient(Control.MousePosition);
        //        //if (toolsToolStripMenuItem.Bounds.Contains(mousePosition))
        //        //{
        //            menuItemsToolTip.ToolTipTitle = "Tools";
        //            menuItemsToolTip.IsBalloon = true;
        //            menuItemsToolTip.Show("More remote scripts, Prep for scans, Closeout checklist, Edit PowerShell scripts, Trial notes", toolsToolStripMenuItem.DropDown);
        //        //}
        //    }
        //    if (e.AssociatedControl != null)
        //    {
        //        Debug.WriteLine("Associated Control: " + e.AssociatedControl.GetType().ToString());
        //    }
        //    else
        //    {
        //        Debug.WriteLine("Associated Control is NULL");
        //    }
        //    Debug.WriteLine("Parent Control: " + toolsToolStripMenuItem.GetCurrentParent().GetType().ToString());

        //}

        //private void toolsToolStripMenuItem_MouseHover(object sender, EventArgs e)
        //{
        //    menuItemsToolTip.ToolTipTitle = "Options Menu Info";
        //    menuItemsToolTip.IsBalloon = true;

        //    ToolStripMenuItem menuItem = (ToolStripMenuItem)sender;

        //    ToolStripDropDown parent = menuItem.DropDown;

        //    Point position = parent.PointToScreen(menuItem.Bounds.Location);
        //    menuItemsToolTip.Show("More remote scripts, Prep for scans, Closeout checklist, Edit PowerShell scripts, Trial notes", parent, position.X + menuItem.Width, position.Y);
        //}

        private void toolsToolStripMenuItem_MouseLeave(object sender, EventArgs e)
        {
            menuItemsToolTip.Hide(toolsToolStripMenuItem.DropDown);
        }

        //private void helpToolStripMenuItem_MouseHover(object sender, EventArgs e)
        //{
        //    menuItemsToolTip.ToolTipTitle = "Help Menu Info";
        //    menuItemsToolTip.IsBalloon = true;
        //    menuItemsToolTip.Show("Find general help, troubleshoot connection issues to trial clients, get PowerShell commands and more.", helpToolStripMenuItem.DropDown);
        //}

        //private void helpToolStripMenuItem_MouseLeave(object sender, EventArgs e)
        //{
        //    menuItemsToolTip.Hide(helpToolStripMenuItem.DropDown);
        //}

        //private void fileToolStripMenuItem_MouseHover(object sender, EventArgs e)
        //{
        //    menuItemsToolTip.ToolTipTitle = "File Menu Info";
        //    menuItemsToolTip.IsBalloon = true;
        //    menuItemsToolTip.Show("refresh application, open local script folder, copy PowerShell scripts to local machine.", fileToolStripMenuItem.DropDown);
        //}

        private void fileToolStripMenuItem_MouseLeave(object sender, EventArgs e)
        {
            menuItemsToolTip.Hide(fileToolStripMenuItem.DropDown);
        }

        private void label9_Click(object sender, EventArgs e)
        {
            BetaDisclaimerForm betaDisclaimerForm = new BetaDisclaimerForm();
            betaDisclaimerForm.ShowDialog();
        }

        private void eTCOptionsToolStripMenuItem_Click(object sender, EventArgs e)
        {

        }

        private void changeETCDatabaseTargetOnClientsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            string fileName = "changeClientETCTargetDatabase.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void addNetPrinterBtn_Click(object sender, EventArgs e)
        {
            string fileName = "addNetworkPrinter.ps1";
            string folderPath = @"VS Scripts\";
            string filePath = Path.Combine(Environment.CurrentDirectory, folderPath, fileName);

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = "powershell.exe";
            startInfo.Arguments = $"-ExecutionPolicy Bypass -File \"{filePath}\"";
            startInfo.Verb = "runas"; // Run as admin console

            Process process = new Process();
            process.StartInfo = startInfo;
            process.Start();
        }

        private void removeScriptsFolderToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // Define the target directory
            string targetDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "VS_Scripts");

            // Remove directory
            if (Directory.Exists(targetDirectory))
            {
                Directory.Delete(targetDirectory, true); // 'true' to remove any subdirectories and files
                Console.WriteLine($"{targetDirectory} has been deleted.");
                MessageBox.Show("Script folder has been removed.");
            }
            else
            {
                Console.WriteLine($"{targetDirectory} does not exist.");
                MessageBox.Show("location does not exist or the folder has already been removed.");
            }
        }

        

        private void dontShowLoginScreenToolStripMenuItem_CheckedChanged(object sender, EventArgs e)
        {
            Properties.Settings.Default.ShowLoginScreenSetting = dontShowLoginScreenToolStripMenuItem.Checked;
            Properties.Settings.Default.Save();
        }

        private void appVersionToolStripMenuItem_Click(object sender, EventArgs e)
        {
            MessageBox.Show("App version: " + appVersion.ToString(), "App Information");
        }
    }
}