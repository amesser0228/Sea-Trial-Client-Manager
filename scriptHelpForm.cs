using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using static System.Windows.Forms.VisualStyles.VisualStyleElement;

namespace Sea_Trials_Script_Launcher
{
    public partial class Script_Help_Form : Form
    {
        private string _scriptHelpText;

        public Script_Help_Form(string scriptHelpText)
        {
            InitializeComponent();
            _scriptHelpText = scriptHelpText;
        }

        private void scriptHelpTextBox1_TextChanged(object sender, EventArgs e)
        {
            ScriptHelpFormLabel.Text = _scriptHelpText; // Use the class-level variable
        }

        private void Script_Help_Form_Load(object sender, EventArgs e)
        {
            
        }
    }
}
