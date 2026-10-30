namespace Sea_Trials_Script_Launcher
{
    partial class RemoteCredentialsForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(RemoteCredentialsForm));
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.remoteUsernameTxtBox = new System.Windows.Forms.TextBox();
            this.remotePasswordTxtBox = new System.Windows.Forms.TextBox();
            this.remoteIPRangeTxtBox = new System.Windows.Forms.TextBox();
            this.revealRemotePassword = new System.Windows.Forms.PictureBox();
            ((System.ComponentModel.ISupportInitialize)(this.revealRemotePassword)).BeginInit();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(298, 138);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(73, 16);
            this.label1.TabIndex = 0;
            this.label1.Text = "Username:";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(298, 199);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(70, 16);
            this.label2.TabIndex = 1;
            this.label2.Text = "Password:";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.Location = new System.Drawing.Point(305, 269);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(66, 16);
            this.label3.TabIndex = 2;
            this.label3.Text = "IP Range:";
            // 
            // remoteUsernameTxtBox
            // 
            this.remoteUsernameTxtBox.Location = new System.Drawing.Point(377, 138);
            this.remoteUsernameTxtBox.Name = "remoteUsernameTxtBox";
            this.remoteUsernameTxtBox.ReadOnly = true;
            this.remoteUsernameTxtBox.Size = new System.Drawing.Size(100, 20);
            this.remoteUsernameTxtBox.TabIndex = 3;
            // 
            // remotePasswordTxtBox
            // 
            this.remotePasswordTxtBox.Location = new System.Drawing.Point(377, 195);
            this.remotePasswordTxtBox.Name = "remotePasswordTxtBox";
            this.remotePasswordTxtBox.PasswordChar = '*';
            this.remotePasswordTxtBox.ReadOnly = true;
            this.remotePasswordTxtBox.Size = new System.Drawing.Size(100, 20);
            this.remotePasswordTxtBox.TabIndex = 4;
            // 
            // remoteIPRangeTxtBox
            // 
            this.remoteIPRangeTxtBox.Location = new System.Drawing.Point(377, 268);
            this.remoteIPRangeTxtBox.Multiline = true;
            this.remoteIPRangeTxtBox.Name = "remoteIPRangeTxtBox";
            this.remoteIPRangeTxtBox.ReadOnly = true;
            this.remoteIPRangeTxtBox.Size = new System.Drawing.Size(124, 20);
            this.remoteIPRangeTxtBox.TabIndex = 5;
            // 
            // revealRemotePassword
            // 
            this.revealRemotePassword.Cursor = System.Windows.Forms.Cursors.Hand;
            this.revealRemotePassword.Image = global::Sea_Trials_Script_Launcher.Properties.Resources.revealPasswordIcon;
            this.revealRemotePassword.Location = new System.Drawing.Point(483, 195);
            this.revealRemotePassword.Name = "revealRemotePassword";
            this.revealRemotePassword.Size = new System.Drawing.Size(20, 20);
            this.revealRemotePassword.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.revealRemotePassword.TabIndex = 6;
            this.revealRemotePassword.TabStop = false;
            this.revealRemotePassword.Click += new System.EventHandler(this.revealRemotePassword_Click);
            // 
            // RemoteCredentialsForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(800, 450);
            this.Controls.Add(this.revealRemotePassword);
            this.Controls.Add(this.remoteIPRangeTxtBox);
            this.Controls.Add(this.remotePasswordTxtBox);
            this.Controls.Add(this.remoteUsernameTxtBox);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "RemoteCredentialsForm";
            this.Text = "Remote Credentials";
            ((System.ComponentModel.ISupportInitialize)(this.revealRemotePassword)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.TextBox remoteUsernameTxtBox;
        private System.Windows.Forms.TextBox remotePasswordTxtBox;
        private System.Windows.Forms.TextBox remoteIPRangeTxtBox;
        private System.Windows.Forms.PictureBox revealRemotePassword;
    }
}