using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics.Metrics;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Sea_Trials_Script_Launcher
{
    public partial class RemoteClientNetworkInformationForm : Form
    {
        string sourceDirectory = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "CredentialFiles");
        string remoteCredentialBeginDeviceIDFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"CredentialFiles\EndIPDeviceID.txt");
        string remoteCredentialEndDeviceIDFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"CredentialFiles\EndIPDeviceID.txt");
        string remoteCredentialIPPrefixFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"CredentialFiles\IPPrefix.txt");

        public RemoteClientNetworkInformationForm()
        {
            InitializeComponent();
            this.ActiveControl = null;
        }

        private void remoteCientIPSubmitBtn_Click(object sender, EventArgs e)
        {
            if (!Directory.Exists(sourceDirectory))
            {
                Directory.CreateDirectory(sourceDirectory);
            }
            if (!File.Exists(remoteCredentialBeginDeviceIDFilePath))
            {
                File.WriteAllText(remoteCredentialBeginDeviceIDFilePath, beginningRemoteClientIPDeviceID.Text);
                notifyBeginIPDeviceIDFile.ShowBalloonTip(3000, "File Created", "Created remote network credentials successfully", ToolTipIcon.Info);
            }
            if (!File.Exists(remoteCredentialEndDeviceIDFilePath))
            {
                File.WriteAllText(remoteCredentialEndDeviceIDFilePath, endingRemoteClientIPDeviceID.Text);
                notifyEndIPDeviceIDFile.ShowBalloonTip(3000, "File Created", "Created remote network credentials successfully", ToolTipIcon.Info);
            }
            if (!File.Exists(remoteCredentialIPPrefixFilePath))
            {
                File.WriteAllText(remoteCredentialIPPrefixFilePath, remoteClientPrefixTextBox.Text);
                notifyIPPrefixFile.ShowBalloonTip(3000, "File Created", "Created remote network credentials successfully", ToolTipIcon.Info);
            }
        }

        private void pictureBox1_Click(object sender, EventArgs e)
        {
            remoteClientIPInfoHelp.Visible = true;
            hideRemoteClientIPInfoHelp.Visible = true;
        }

        private void hideRemoteClientIPInfoHelp_Click(object sender, EventArgs e)
        {
            remoteClientIPInfoHelp.Visible = false;
            hideRemoteClientIPInfoHelp.Visible = false;
        }

        private void beginningRemoteClientIPDeviceID_Enter(object sender, EventArgs e)
        {
            if(beginningRemoteClientIPDeviceID.Text == "Start ID")
            {
                beginningRemoteClientIPDeviceID.Clear();
                beginningRemoteClientIPDeviceID.ForeColor = Color.Black;
            }
        }

        private void endingRemoteClientIPDeviceID_Enter(object sender, EventArgs e)
        {
            if(endingRemoteClientIPDeviceID.Text == "End ID")
            {
                endingRemoteClientIPDeviceID.Clear();
                endingRemoteClientIPDeviceID.ForeColor = Color.Black;
            }
        }

        private void remoteClientPrefixTextBox_Enter(object sender, EventArgs e)
        {
            if(remoteClientPrefixTextBox.Text == "Enter prefix(192.168.56)")
            {
                remoteClientPrefixTextBox.Clear();
                remoteClientPrefixTextBox.ForeColor = Color.Black;
            }
        }

        private void Generic_Leave(object sender, EventArgs e)
        {

        }

        private void beginningRemoteClientIPDeviceID_Leave(object sender, EventArgs e)
        {
            TextBox tb = sender as TextBox;
            if (tb != null && string.IsNullOrWhiteSpace(tb.Text))
            {
                tb.Text = "Start ID";
                tb.ForeColor = Color.Gray;
            }
        }

        private void endingRemoteClientIPDeviceID_Leave(object sender, EventArgs e)
        {
            TextBox tb = sender as TextBox;
            if (tb != null && string.IsNullOrWhiteSpace(tb.Text))
            {
                tb.Text = "End ID";
                tb.ForeColor = Color.Gray;
            }
        }

        private void remoteClientPrefixTextBox_Leave(object sender, EventArgs e)
        {
            TextBox tb = sender as TextBox;
            if (tb != null && string.IsNullOrWhiteSpace(tb.Text))
            {
                tb.Text = "Enter prefix(192.168.56)";
                tb.ForeColor = Color.Gray;
            }
        }

        private void resetIPConfigBtn_Click(object sender, EventArgs e)
        {
            DialogResult resetCredentialsDialogResult = MessageBox.Show("Do you you want to reset the remote network configuration?", "Warning", MessageBoxButtons.YesNo);
            if (resetCredentialsDialogResult == DialogResult.Yes)
            {
                if (File.Exists(remoteCredentialBeginDeviceIDFilePath) && File.Exists(remoteCredentialEndDeviceIDFilePath) && File.Exists(remoteCredentialIPPrefixFilePath))

                {
                    File.Delete(remoteCredentialBeginDeviceIDFilePath);
                    File.Delete(remoteCredentialEndDeviceIDFilePath);
                    File.Delete(remoteCredentialIPPrefixFilePath);
                    notifyIPConfigReset.ShowBalloonTip(3000, "IP Info Reset", "Network configuration has been reset", ToolTipIcon.Info);
                }
                else if (!File.Exists(remoteCredentialBeginDeviceIDFilePath) && File.Exists(remoteCredentialEndDeviceIDFilePath) && File.Exists(remoteCredentialIPPrefixFilePath))
                {
                    notifIPConfigNotReset.ShowBalloonTip(3000, "ERROR", "Network configuration files could not be reset because they could not be found.", ToolTipIcon.Error);
                }
            }
        }
    }
}
