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
    public partial class ConfigMenuForm : Form
    {
        public Version appVersion;
        public ConfigMenuForm()
        {
            InitializeComponent();
            setAppVersion();
        }

        public String GetAppVersion()
        {
            appVersion = Assembly.GetExecutingAssembly().GetName().Version;
            return $"v.{appVersion}";
        }

        public void setAppVersion()
        {
            appVersionLabel.Text = GetAppVersion();
        }

    }
}
