using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Reflection.Emit;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Diagnostics;
using System.IO;

namespace Sea_Trials_Script_Launcher
{
    public partial class helpRunningScriptsForm : Form
    {
        private string _helpRunningScriptsFormText;
        public helpRunningScriptsForm(string helpRunningScriptsFormText)
        {
            InitializeComponent();
            _helpRunningScriptsFormText = helpRunningScriptsFormText;
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void helpRunningScripts_Load(object sender, EventArgs e)
        {

        }

        private void button1_Click(object sender, EventArgs e)
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

    }
}
