using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.IO;
using System.Net;

namespace Sea_Trials_Script_Launcher
{
    public partial class UserCredentialForm : Form
    {
        string sourceDirectory = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "CredentialFiles");
        public UserCredentialForm()
        {
            InitializeComponent();
            this.ActiveControl = null;
            if (!Directory.Exists(sourceDirectory))
            {
                Directory.CreateDirectory(sourceDirectory);
                notifyCredentialFolderCreated.ShowBalloonTip(3000, "Folder Created", "Credentials folder has been created succesfully", ToolTipIcon.Info);
            }
        }

        string remoteUserCredentialFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"CredentialFiles\RemoteUsername.txt");
        string remotePasswordCredentialFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"CredentialFiles\RemotePassword.txt");

        private void UsernameCredentialSubmitBtn_Click(object sender, EventArgs e)
        {
            if (!File.Exists(remoteUserCredentialFilePath))
            {
                File.WriteAllText(remoteUserCredentialFilePath, UsernameCredentialBox.Text);
                notifyClientUsernameFileCreated.ShowBalloonTip(3000, "File Created", "Created remote username file successfully", ToolTipIcon.Info);
            }
            else
            {
                MessageBox.Show("Remote username text file already exists.");
            }
            UsernameCredentialBox.Clear();
            
            //notifyClientUsernameFileCreated.ShowBalloonTip(3000, "File Created", "Created remote username file successfully", ToolTipIcon.Info);
        }

        private void PasswordCredentialSubmitBtn_Click(object sender, EventArgs e)
        {
            if (!File.Exists(remotePasswordCredentialFilePath))
            {
                File.WriteAllText(remotePasswordCredentialFilePath, PasswordCredentialBox.Text);
                notifyClientUsernameFileCreated.ShowBalloonTip(3000, "File Created", "Created remote password file successfully", ToolTipIcon.Info);
            }
            PasswordCredentialBox.Clear();
        }

        private void UserCredentialForm_Load(object sender, EventArgs e)
        {

        }

        private void UsernameCredentialBox_Enter(object sender, EventArgs e)
        {
            if(UsernameCredentialBox.Text == "Enter Remote Username") 
            {
                UsernameCredentialBox.Clear();
                UsernameCredentialBox.ForeColor = Color.Black;
            }
        }

        private void UsernameCredentialBox_Leave(object sender, EventArgs e)
        {
            TextBox tb = sender as TextBox;
            if (tb != null && string.IsNullOrWhiteSpace(tb.Text))
            {
                tb.Text = "Enter Remote Username";
                tb.ForeColor = Color.Gray;
            }
        }

        private void PasswordCredentialBox_Enter(object sender, EventArgs e)
        {
            if(PasswordCredentialBox.Text == "Enter Remote Password")
            {
                PasswordCredentialBox.Text = "";
                PasswordCredentialBox.ForeColor = Color.Black;
            }
        }

        private void PasswordCredentialBox_Leave(object sender, EventArgs e)
        {
            TextBox tb = sender as TextBox;
            if (tb != null && string.IsNullOrWhiteSpace(tb.Text))
            {
                tb.Text = "Enter Remote Password";
                tb.ForeColor = Color.Gray;
            }
        }

        private void resetUserCredentialsBtn_Click(object sender, EventArgs e)
        {
            DialogResult resetCredentialsDialogResult = MessageBox.Show("Do you you want to reset the remote user credentials?", "Warning", MessageBoxButtons.YesNo);
            if (resetCredentialsDialogResult == DialogResult.Yes)
            {
                if (File.Exists(remoteUserCredentialFilePath) && File.Exists(remotePasswordCredentialFilePath))
                {
                    File.Delete(remoteUserCredentialFilePath);
                    File.Delete(remotePasswordCredentialFilePath);
                    notifyClientUserCredentialsDeleted.ShowBalloonTip(3000, "CredentiLals Reset", "remote client credentials have been reset", ToolTipIcon.Info);
                }
                else if(!File.Exists(remoteUserCredentialFilePath) && !File.Exists(remotePasswordCredentialFilePath))
                {
                    notifyClientUserCredentialsNotResetFilesExist.ShowBalloonTip(3000, "ERROR", "Credential files could not be reset because they could not be found.", ToolTipIcon.Error);
                }
            }
        }
    }
}
