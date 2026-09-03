using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Sea_Trials_Script_Launcher
{
    public partial class requestAccessForm : Form
    {
        string _requestAccessText;
        public requestAccessForm(string requestAccessText)
        {
            InitializeComponent();
            _requestAccessText = requestAccessText;
        }
    }
}
