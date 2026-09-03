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

namespace Sea_Trials_Script_Launcher
{
    public partial class Help_Form : Form
    {
        private string _helpText; // Declare a class-level variable

        public Help_Form(string helpText)
        {
            InitializeComponent();
            _helpText = helpText; // Store the parameter in the class-level variable
            SetVersionNumber();
        }

        private void SetVersionNumber()
        {
            Version version = Assembly.GetExecutingAssembly().GetName().Version;
            label1.Text = $"Version {version}";
        }

        private void textBox1_TextChanged(object sender, EventArgs e)
        {
            GeneralHelpFormLabel.Text = _helpText; // Use the class-level variable
        }

        private void Help_Form_Load(object sender, EventArgs e)
        {

        }

        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start("https://mscorp.sharepoint.us/:w:/s/MSCorpTrialSupport/ESUk77nqgyxIv3VFJ4ZhZvkBkfedpgjarpbwQppiDSYJ9Q?e=O4lHWz");
        }

        private void label7_Click(object sender, EventArgs e)
        {

        }

        private void panel1_Paint(object sender, PaintEventArgs e)
        {

        }
    }
}
