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
    public partial class RemoteCredentialsForm : Form
    {
        public RemoteCredentialsForm()
        {
            InitializeComponent();
            if (File.Exists(remoteUserCredentialFilePath) && File.Exists(remotePasswordCredentialFilePath))
            {

                using (StreamReader sr = new StreamReader(remoteUserCredentialFilePath))
                {
                    remoteUsernameTxtBox.Text = sr.ReadToEnd();
                }
                using (StreamReader sr = new StreamReader(remotePasswordCredentialFilePath))
                {
                    remotePasswordTxtBox.Text = sr.ReadToEnd();
                }
            }
            else
            {
                MessageBox.Show("Remote credential files are not configured");
                return;
            }
            string prefix = File.ReadAllText(remoteCredentialIPPrefixFilePath);
            string startID = File.ReadAllText(remoteCredentialBeginDeviceIDFilePath);
            string endID = File.ReadAllText(remoteCredentialEndDeviceIDFilePath);

            remoteIPRangeTxtBox.Text = prefix + "." + startID + " - " + endID;
        }

        string remotePasswordCredentialFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"CredentialFiles\RemotePassword.txt");
        string remoteUserCredentialFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"CredentialFiles\RemoteUsername.txt");
        string remoteCredentialBeginDeviceIDFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"CredentialFiles\BeginIPDeviceID.txt");
        string remoteCredentialEndDeviceIDFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"CredentialFiles\EndIPDeviceID.txt");
        string remoteCredentialIPPrefixFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"CredentialFiles\IPPrefix.txt");

        private void revealRemotePassword_Click(object sender, EventArgs e)
        {
            if (Properties.Settings.Default.ShowLoginScreenSetting)
            {
                using (loginForm loginFormWindow = new loginForm())
                {
                    if (loginFormWindow.ShowDialog() != DialogResult.OK)
                    {
                        this.Close();
                    }
                }
                remotePasswordTxtBox.PasswordChar = '\0';
            }
            else
            {
                remotePasswordTxtBox.PasswordChar = '\0';
            }
        }
    }
}
