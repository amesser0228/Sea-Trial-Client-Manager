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

namespace Sea_Trials_Script_Launcher
{
    public partial class Form1 : Form
    {
        // instance fields for dataBase class
        private SeaTrialsDatabase database;
        private DataGridView dataGridView1;

        public Form1()
        {
            InitializeComponent();
            SetVersionNumber();
            CopyScriptsToUserDirectory();
            GenerateSessionId();
            database = new SeaTrialsDatabase("SeaTrials.db");

            //tool tip text for script buttons
            toolTipHelper.SetToolTip(Remote_Command_Btn, "This script allows you to remotely send a command to all clients in the chosen batch.\n*This script can be edited*");

            toolTipHelper.SetToolTip(button3, "Enables connection to clinets through PSRemote and Trusted Hosts.");

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
        {/*
            using (loginForm loginFormWindow = new loginForm())
            {
                if (loginFormWindow.ShowDialog() != DialogResult.OK)
                {
                    this.Close(); // Close the main form if login fails
                }
            }
            */

            CopyScriptsToUserDirectory();
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

        private void SetVersionNumber()
        {
            Version version = Assembly.GetExecutingAssembly().GetName().Version;
            label7.Text = $"Version {version}";
        }

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
            RunScript("run_script_remote_host.ps1");
        }

        private void button4_Click(object sender, EventArgs e)
        {
            RunScript("run_command_remote_host.ps1");
        }

        private void button1_Click_1(object sender, EventArgs e)
        {
            RunScript("powerOffHosts.ps1");
        }

        private void button3_Click_1(object sender, EventArgs e)
        {
            string fileName = "enable_Connection_To_Clients.ps1";
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
            startInfo.Verb = "runas"; // Run as admin console

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
            startInfo.Verb = "runas"; // Run as admin console

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

            MessageBox.Show("Hostname: " + hostname + "\n\nLAN IP address: " + activeIP + "\n\nSession ID: " + sessionID, "Host Information");
        }
    }
}
