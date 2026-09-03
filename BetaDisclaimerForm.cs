using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Sea_Trials_Script_Launcher
{
    public partial class BetaDisclaimerForm : Form
    {
        public BetaDisclaimerForm()
        {
            InitializeComponent();
            versionLabel.Text = "Version: " + Assembly.GetExecutingAssembly().GetName().Version.ToString();
        }
    }
}
