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
    public partial class aboutForm : Form
    {
        private string _aboutText;
        public aboutForm(string aboutText)
        {
            InitializeComponent();
            _aboutText = aboutText;
            SetVersionNumber();
        }

        //private void textBox1_TextChanged(object sender, EventArgs e)
        //{
        //    richTextBox1.Text = _aboutText;
        //}

        private void SetVersionNumber()
        {
            Version version = Assembly.GetExecutingAssembly().GetName().Version;
            label2.Text = $"Version {version}";
        }

        private void richTextBox1_TextChanged(object sender, EventArgs e)
        {

        }

        private void aboutForm_Load(object sender, EventArgs e)
        {

        }

        private void label2_Click(object sender, EventArgs e)
        {

        }

        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start("https://messerunlimited.w3spaces.com/");
        }

        private void label2_Click_1(object sender, EventArgs e)
        {

        }

        private void linkLabel1_LinkClicked_1(object sender, LinkLabelLinkClickedEventArgs e)
        {
            System.Diagnostics.Process.Start("https://messerunlimited.w3spaces.com/");
        }
    }
}
