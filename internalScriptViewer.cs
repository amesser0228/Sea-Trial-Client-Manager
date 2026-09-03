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
        string internalDirctoryPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "VS Scripts");

        public internalScriptViewer(string scriptViewer)
        {
            InitializeComponent();
            _scriptViewer = scriptViewer;
        }

        private void LoadScripts()
        {
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

        private void shellScriptsListBoxDeleteBtn_Click(object sender, EventArgs e)
        {
            if (internalScriptsBox.SelectedItem != null)
            {
                string selectedScriptScriptFile = internalScriptsBox.SelectedItem.ToString();
                string scriptFileToDelete = Path.Combine(internalDirctoryPath, selectedScriptScriptFile);

                DialogResult confirmDelete = MessageBox.Show($"Are you sure you want to delete '{selectedScriptScriptFile}'?", "Confirm Delete", MessageBoxButtons.YesNo, MessageBoxIcon.Warning);
                
                if (confirmDelete == DialogResult.Yes)
                {
                    try
                    {
                        if (File.Exists(scriptFileToDelete))
                        {
                            File.Delete(scriptFileToDelete);
                            internalScriptsBox.Items.Remove(internalScriptsBox.SelectedItem);
                            MessageBox.Show($"{selectedScriptScriptFile} has been deleted", "File Deleted", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                        else
                        {
                            MessageBox.Show("File not found", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        }
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Error deleting file: {ex.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
            }
            else
            {
                MessageBox.Show("Please select an item to delete.", "No item selected", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
        }

        private void RefreshInternalScriptsBox()
        {
            internalScriptsBox.Items.Clear();

            if (Directory.Exists(internalDirctoryPath))
            {
                string[] files = Directory.GetFiles(internalDirctoryPath);
                foreach (string file in files)
                {
                    internalScriptsBox.Items.Add(Path.GetFileName(file)); // Add just the filename
                }
            }
        }

        private void shellScriptsListBoxAddBtn_Click(object sender, EventArgs e)
        {
            OpenFileDialog addScriptFile = new OpenFileDialog();
            addScriptFile.Multiselect = false;
            addScriptFile.Title = "Select a PowerShell script to add";
            addScriptFile.Filter = "PowerShell Script Files (*.ps1)|*.ps1|PowerShell Module Files (*.psm1)|*.psm1|PowerShell Data Files (*.psd1)|*.psd1"; addScriptFile.CheckFileExists = true; addScriptFile.CheckPathExists = true;

            if (addScriptFile.ShowDialog() == DialogResult.OK)
            {
                string scriptFile = addScriptFile.FileName;
                string selectedScriptFile = scriptFile.ToString();
                string selectedScriptFileToAdd = Path.Combine(internalDirctoryPath, Path.GetFileName(selectedScriptFile));
                if (File.Exists(scriptFile))
                {
                    try
                    {

                        internalScriptsBox.Items.Add(scriptFile);
                        File.Copy(selectedScriptFile, selectedScriptFileToAdd, true);
                        RefreshInternalScriptsBox();

                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"STCM encountered an error trying to add '{selectedScriptFile}': {ex.Message}", "Error adding file", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
                else
                {
                    MessageBox.Show("selected script file does not exist or can't accessed");
                }
            }
            else
            {
                MessageBox.Show("No file selected to add");
            }
        }
    }
}
