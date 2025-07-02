using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.Diagnostics;

namespace Sea_Trials_Script_Launcher
{
    public partial class internalScriptViewer : Form
    {
        private string _scriptViewer;

        public internalScriptViewer(string scriptViewer)
        {
            InitializeComponent();
            _scriptViewer = scriptViewer;
        }

        private void LoadScripts()
        {

            string internalDirctoryPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "VS Scripts");
            VS_Scripts_Helper vsscriptsHelper = new VS_Scripts_Helper(internalDirctoryPath);
            string[] scripts = vsscriptsHelper.GetScripts();

            foreach (string script in scripts)
            {

                internalScriptsBox.Items.Add(Path.GetFileName(script));
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            LoadScripts();
        }

        private void internalScriptsBox_DoubleClick(object sender, EventArgs e)
        {
            if (internalScriptsBox.SelectedItem != null)
            {
                DialogResult dialogueResult = MessageBox.Show("Editing the scripts in this application may cause runtime errors or damage government property. \nContinue at your own risk.", "WARNING!", MessageBoxButtons.OKCancel);
                if (dialogueResult == DialogResult.OK)
                {
                    string selectedScript = internalScriptsBox.SelectedItem.ToString();
                    string scriptPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "VS Scripts", selectedScript);
                    System.Diagnostics.Process.Start("notepad.exe", scriptPath);
                }
            }
        }

        private void ReadMe_Click(object sender, EventArgs e)
        {
            string readMeFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "VS Scripts", "README.txt");
            try
            {
                Process.Start(new ProcessStartInfo(readMeFilePath) { UseShellExecute = true });
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error opening directory: " + ex.Message);
            }
        }
    }
}
