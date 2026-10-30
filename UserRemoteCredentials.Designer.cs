namespace Sea_Trials_Script_Launcher
{
    partial class UserCredentialForm
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(UserCredentialForm));
            this.UsernameCredentialBox = new System.Windows.Forms.TextBox();
            this.UsernameCredentialSubmitBtn = new System.Windows.Forms.Button();
            this.PasswordCredentialBox = new System.Windows.Forms.TextBox();
            this.PasswordCredentialSubmitBtn = new System.Windows.Forms.Button();
            this.notifyClientUsernameFileCreated = new System.Windows.Forms.NotifyIcon(this.components);
            this.resetUserCredentialsBtn = new System.Windows.Forms.Button();
            this.notifyClientUserCredentialsDeleted = new System.Windows.Forms.NotifyIcon(this.components);
            this.notifyClientUserCredentialsNotResetFilesExist = new System.Windows.Forms.NotifyIcon(this.components);
            this.notifyIcon1 = new System.Windows.Forms.NotifyIcon(this.components);
            this.notifyCredentialFolderCreated = new System.Windows.Forms.NotifyIcon(this.components);
            this.SuspendLayout();
            // 
            // UsernameCredentialBox
            // 
            this.UsernameCredentialBox.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.UsernameCredentialBox.ForeColor = System.Drawing.SystemColors.GrayText;
            this.UsernameCredentialBox.Location = new System.Drawing.Point(329, 118);
            this.UsernameCredentialBox.Margin = new System.Windows.Forms.Padding(4);
            this.UsernameCredentialBox.Name = "UsernameCredentialBox";
            this.UsernameCredentialBox.Size = new System.Drawing.Size(407, 26);
            this.UsernameCredentialBox.TabIndex = 1;
            this.UsernameCredentialBox.Text = "Enter Remote Username";
            this.UsernameCredentialBox.Enter += new System.EventHandler(this.UsernameCredentialBox_Enter);
            this.UsernameCredentialBox.Leave += new System.EventHandler(this.UsernameCredentialBox_Leave);
            // 
            // UsernameCredentialSubmitBtn
            // 
            this.UsernameCredentialSubmitBtn.Location = new System.Drawing.Point(484, 153);
            this.UsernameCredentialSubmitBtn.Margin = new System.Windows.Forms.Padding(4);
            this.UsernameCredentialSubmitBtn.Name = "UsernameCredentialSubmitBtn";
            this.UsernameCredentialSubmitBtn.Size = new System.Drawing.Size(100, 28);
            this.UsernameCredentialSubmitBtn.TabIndex = 0;
            this.UsernameCredentialSubmitBtn.Text = "Submit";
            this.UsernameCredentialSubmitBtn.UseVisualStyleBackColor = true;
            this.UsernameCredentialSubmitBtn.Click += new System.EventHandler(this.UsernameCredentialSubmitBtn_Click);
            // 
            // PasswordCredentialBox
            // 
            this.PasswordCredentialBox.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.PasswordCredentialBox.ForeColor = System.Drawing.SystemColors.GrayText;
            this.PasswordCredentialBox.Location = new System.Drawing.Point(329, 276);
            this.PasswordCredentialBox.Margin = new System.Windows.Forms.Padding(4);
            this.PasswordCredentialBox.Name = "PasswordCredentialBox";
            this.PasswordCredentialBox.Size = new System.Drawing.Size(407, 26);
            this.PasswordCredentialBox.TabIndex = 2;
            this.PasswordCredentialBox.Text = "Enter Remote Password";
            this.PasswordCredentialBox.Enter += new System.EventHandler(this.PasswordCredentialBox_Enter);
            this.PasswordCredentialBox.Leave += new System.EventHandler(this.PasswordCredentialBox_Leave);
            // 
            // PasswordCredentialSubmitBtn
            // 
            this.PasswordCredentialSubmitBtn.Location = new System.Drawing.Point(484, 310);
            this.PasswordCredentialSubmitBtn.Margin = new System.Windows.Forms.Padding(4);
            this.PasswordCredentialSubmitBtn.Name = "PasswordCredentialSubmitBtn";
            this.PasswordCredentialSubmitBtn.Size = new System.Drawing.Size(100, 28);
            this.PasswordCredentialSubmitBtn.TabIndex = 3;
            this.PasswordCredentialSubmitBtn.Text = "Submit";
            this.PasswordCredentialSubmitBtn.UseVisualStyleBackColor = true;
            this.PasswordCredentialSubmitBtn.Click += new System.EventHandler(this.PasswordCredentialSubmitBtn_Click);
            // 
            // notifyClientUsernameFileCreated
            // 
            this.notifyClientUsernameFileCreated.Icon = ((System.Drawing.Icon)(resources.GetObject("notifyClientUsernameFileCreated.Icon")));
            this.notifyClientUsernameFileCreated.Text = "notifyIcon1";
            this.notifyClientUsernameFileCreated.Visible = true;
            // 
            // resetUserCredentialsBtn
            // 
            this.resetUserCredentialsBtn.Location = new System.Drawing.Point(453, 506);
            this.resetUserCredentialsBtn.Name = "resetUserCredentialsBtn";
            this.resetUserCredentialsBtn.Size = new System.Drawing.Size(161, 23);
            this.resetUserCredentialsBtn.TabIndex = 4;
            this.resetUserCredentialsBtn.Text = "Reset Credentials";
            this.resetUserCredentialsBtn.UseVisualStyleBackColor = true;
            this.resetUserCredentialsBtn.Click += new System.EventHandler(this.resetUserCredentialsBtn_Click);
            // 
            // notifyClientUserCredentialsDeleted
            // 
            this.notifyClientUserCredentialsDeleted.Icon = ((System.Drawing.Icon)(resources.GetObject("notifyClientUserCredentialsDeleted.Icon")));
            this.notifyClientUserCredentialsDeleted.Text = "notifyIcon1";
            this.notifyClientUserCredentialsDeleted.Visible = true;
            // 
            // notifyClientUserCredentialsNotResetFilesExist
            // 
            this.notifyClientUserCredentialsNotResetFilesExist.Text = "notifyIcon1";
            this.notifyClientUserCredentialsNotResetFilesExist.Visible = true;
            // 
            // notifyIcon1
            // 
            this.notifyIcon1.Text = "notifyIcon1";
            this.notifyIcon1.Visible = true;
            // 
            // notifyCredentialFolderCreated
            // 
            this.notifyCredentialFolderCreated.Text = "notifyIcon2";
            this.notifyCredentialFolderCreated.Visible = true;
            // 
            // UserCredentialForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1067, 554);
            this.Controls.Add(this.resetUserCredentialsBtn);
            this.Controls.Add(this.PasswordCredentialSubmitBtn);
            this.Controls.Add(this.PasswordCredentialBox);
            this.Controls.Add(this.UsernameCredentialSubmitBtn);
            this.Controls.Add(this.UsernameCredentialBox);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(4);
            this.Name = "UserCredentialForm";
            this.Text = "Enter Remote User Credentials";
            this.Load += new System.EventHandler(this.UserCredentialForm_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox UsernameCredentialBox;
        private System.Windows.Forms.Button UsernameCredentialSubmitBtn;
        private System.Windows.Forms.TextBox PasswordCredentialBox;
        private System.Windows.Forms.Button PasswordCredentialSubmitBtn;
        private System.Windows.Forms.NotifyIcon notifyClientUsernameFileCreated;
        private System.Windows.Forms.Button resetUserCredentialsBtn;
        private System.Windows.Forms.NotifyIcon notifyClientUserCredentialsDeleted;
        private System.Windows.Forms.NotifyIcon notifyClientUserCredentialsNotResetFilesExist;
        private System.Windows.Forms.NotifyIcon notifyIcon1;
        private System.Windows.Forms.NotifyIcon notifyCredentialFolderCreated;
    }
}