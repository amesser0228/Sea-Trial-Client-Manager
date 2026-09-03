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

namespace Sea_Trials_Script_Launcher
{
    public partial class EnterTrialInfoForm : Form
    {
        private string Trial_HullInfoFilePath;
        public EnterTrialInfoForm()
        {
            Trial_HullInfoFilePath = Path.Combine(Application.StartupPath, "Trial_HullInfoFile.txt");
            InitializeComponent();
        }

        private void TrialInfoSubmitBtn_Click(object sender, EventArgs e)
        {
            string filePath = "Trial_HullInfoFile.txt";
            File.WriteAllText(filePath, TrialInfoTextBox.Text);

            //foreach (Form form in Application.OpenForms)
            //{
            //    if (form is TrialNotesForm)
            //    {
            //        (form as TrialNotesForm).Close();
                    
            //        break; // Assuming you only have one instance
            //    }
            //}

            TrialNotesForm trialNotesForm = new TrialNotesForm();
            trialNotesForm.ShowDialog();

            this.Close();
        }
    }
}
