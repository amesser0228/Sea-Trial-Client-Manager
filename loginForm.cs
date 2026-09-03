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
    public partial class loginForm : Form
    {
        public loginForm()
        {
            InitializeComponent();
        }

        private string correctPassword = "trials"; // private password string

        private void button1_Click(object sender, EventArgs e)
        {

            if (loginFormPasswordTextBox.Text == correctPassword)
            {
                this.DialogResult = DialogResult.OK; // successful login
                this.Close(); // Close the login form
            }
            else
            {
                MessageBox.Show("Incorrect password, please try again.");
            }
        }

        private void loginForm_Load(object sender, EventArgs e)
        {

        }

        private void loginFormPasswordTextBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter) {
                if (loginFormPasswordTextBox.Text == correctPassword) {
                    this.DialogResult = DialogResult.OK; // successful login
                    this.Close(); // Close the login form
                }
                else
                {
                    MessageBox.Show("Incorrect password, please try again.");
                }
            }
        }

        private void linkLabel1_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            string cuiPolicyFormText = "";
            CUIPolicy cuiPolicyText = new CUIPolicy(cuiPolicyFormText);
            cuiPolicyText.ShowDialog();     
        }

        private void linkLabel2_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            string requestAccessStr = "";
            requestAccessForm requestAccessText = new requestAccessForm(requestAccessStr);
            requestAccessText.ShowDialog();
        }

        private void label5_Click(object sender, EventArgs e)
        {
            MessageBox.Show("This feature is in development", "STCM", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void linkLabel3_LinkClicked(object sender, LinkLabelLinkClickedEventArgs e)
        {
            LoginHelpForm loginHelpForm = new LoginHelpForm();
            loginHelpForm.ShowDialog();
        }
    }
}
