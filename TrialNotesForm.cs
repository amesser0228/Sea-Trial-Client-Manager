using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Sea_Trials_Script_Launcher
{
    public partial class TrialNotesForm : Form
    {
        private string STCM_NotesFilePath;
        private string Trial_HullInfoFilePath;
        public TrialNotesForm()
        {
            STCM_NotesFilePath = Path.Combine(Application.StartupPath, "STCMNotesFile.txt");
            Trial_HullInfoFilePath = Path.Combine(Application.StartupPath, "Trial_HullInfoFile.txt");
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            if (File.Exists(Trial_HullInfoFilePath))
            {
                string TrialInfo = File.ReadAllText(Trial_HullInfoFilePath);
                if (!string.IsNullOrEmpty(TrialInfo))
                {
                    HullNameLabel.Text = TrialInfo;
                }
            }
            populateTrialNotes();

        }

        private void populateTrialNotes()
        {
            if (!string.IsNullOrEmpty(STCM_NotesFilePath) && File.Exists(STCM_NotesFilePath))
            {
                try
                {
                    TrialNotesTextBox.Text = File.ReadAllText(STCM_NotesFilePath);
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error reading file: {ex.Message}");
                }
            }
            else
            {
                TrialNotesTextBox.Text = "No notes available."; // Optional: Display a message if the file doesn't exist
            }
        }

        

        private void TrialNotesForm_FormClosing(object sender, FormClosingEventArgs e)
        {
            string filePath = STCM_NotesFilePath; // Use the file path here
            try
            {
                File.WriteAllText(filePath, TrialNotesTextBox.Text); // Write the textbox content to the file
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error saving file: {ex.Message}"); // Show error message
            }
        }

        private void ChangeHullBtn_Click(object sender, EventArgs e)
        {
            EnterTrialInfoForm enterTrialInfoForm = new EnterTrialInfoForm();
            enterTrialInfoForm.ShowDialog();
            this.Close();
        }
    }
}
