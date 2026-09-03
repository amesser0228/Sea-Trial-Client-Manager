using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Diagnostics;
using System.Windows.Forms;

namespace Sea_Trials_Script_Launcher
{
    public partial class remoteCommandsForm : Form
    {
        private string _commandHelpText;
        public remoteCommandsForm(string commandHelpText)
        {
            InitializeComponent();
            _commandHelpText = commandHelpText;
        }

        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            string filePath = "PowerShellCommands.docx";
            Process.Start(filePath);
        }

        private void remoteCommandsForm_Load(object sender, EventArgs e)
        {

        }

        private void richTextBox1_TextChanged(object sender, EventArgs e)
        {
            richTextBox1.Text = _commandHelpText;
        }
    }
}
