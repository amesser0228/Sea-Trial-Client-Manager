using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Diagnostics;
using System.IO;

namespace Sea_Trials_Script_Launcher
{
    public partial class CUIPolicy : Form
    {
        public string _cuiPolicyText;

        public CUIPolicy(string cuiPolicyText)
        {
            InitializeComponent();
            _cuiPolicyText = cuiPolicyText;
        }

        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            string infoPaperPath = "Resources\\InfoPaperDoDCUIProgram.pdf";
            Process.Start(infoPaperPath);
        }
    }
}
