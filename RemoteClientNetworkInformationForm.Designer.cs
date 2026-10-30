namespace Sea_Trials_Script_Launcher
{
    partial class RemoteClientNetworkInformationForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(RemoteClientNetworkInformationForm));
            this.beginningRemoteClientIPDeviceID = new System.Windows.Forms.TextBox();
            this.remoteCientIPSubmitBtn = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.endingRemoteClientIPDeviceID = new System.Windows.Forms.TextBox();
            this.label2 = new System.Windows.Forms.Label();
            this.label3 = new System.Windows.Forms.Label();
            this.label4 = new System.Windows.Forms.Label();
            this.remoteClientPrefixTextBox = new System.Windows.Forms.TextBox();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.remoteClientIPInfoHelp = new System.Windows.Forms.RichTextBox();
            this.hideRemoteClientIPInfoHelp = new System.Windows.Forms.Label();
            this.notifyBeginIPDeviceIDFile = new System.Windows.Forms.NotifyIcon(this.components);
            this.notifyEndIPDeviceIDFile = new System.Windows.Forms.NotifyIcon(this.components);
            this.notifyIPPrefixFile = new System.Windows.Forms.NotifyIcon(this.components);
            this.resetIPConfigBtn = new System.Windows.Forms.Button();
            this.notifyIPConfigReset = new System.Windows.Forms.NotifyIcon(this.components);
            this.notifIPConfigNotReset = new System.Windows.Forms.NotifyIcon(this.components);
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.SuspendLayout();
            // 
            // beginningRemoteClientIPDeviceID
            // 
            this.beginningRemoteClientIPDeviceID.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.beginningRemoteClientIPDeviceID.ForeColor = System.Drawing.SystemColors.GrayText;
            this.beginningRemoteClientIPDeviceID.Location = new System.Drawing.Point(456, 242);
            this.beginningRemoteClientIPDeviceID.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.beginningRemoteClientIPDeviceID.Name = "beginningRemoteClientIPDeviceID";
            this.beginningRemoteClientIPDeviceID.Size = new System.Drawing.Size(61, 24);
            this.beginningRemoteClientIPDeviceID.TabIndex = 1;
            this.beginningRemoteClientIPDeviceID.Text = "Start ID";
            this.beginningRemoteClientIPDeviceID.Enter += new System.EventHandler(this.beginningRemoteClientIPDeviceID_Enter);
            this.beginningRemoteClientIPDeviceID.Leave += new System.EventHandler(this.beginningRemoteClientIPDeviceID_Leave);
            // 
            // remoteCientIPSubmitBtn
            // 
            this.remoteCientIPSubmitBtn.Location = new System.Drawing.Point(472, 438);
            this.remoteCientIPSubmitBtn.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.remoteCientIPSubmitBtn.Name = "remoteCientIPSubmitBtn";
            this.remoteCientIPSubmitBtn.Size = new System.Drawing.Size(123, 43);
            this.remoteCientIPSubmitBtn.TabIndex = 0;
            this.remoteCientIPSubmitBtn.Text = "Submit";
            this.remoteCientIPSubmitBtn.UseVisualStyleBackColor = true;
            this.remoteCientIPSubmitBtn.Click += new System.EventHandler(this.remoteCientIPSubmitBtn_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(316, 241);
            this.label1.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(119, 29);
            this.label1.TabIndex = 2;
            this.label1.Text = "xxx.xxx.xx.";
            // 
            // endingRemoteClientIPDeviceID
            // 
            this.endingRemoteClientIPDeviceID.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.endingRemoteClientIPDeviceID.ForeColor = System.Drawing.SystemColors.GrayText;
            this.endingRemoteClientIPDeviceID.Location = new System.Drawing.Point(693, 242);
            this.endingRemoteClientIPDeviceID.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.endingRemoteClientIPDeviceID.Name = "endingRemoteClientIPDeviceID";
            this.endingRemoteClientIPDeviceID.Size = new System.Drawing.Size(57, 24);
            this.endingRemoteClientIPDeviceID.TabIndex = 3;
            this.endingRemoteClientIPDeviceID.Text = "End ID";
            this.endingRemoteClientIPDeviceID.Enter += new System.EventHandler(this.endingRemoteClientIPDeviceID_Enter);
            this.endingRemoteClientIPDeviceID.Leave += new System.EventHandler(this.endingRemoteClientIPDeviceID_Leave);
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label2.Location = new System.Drawing.Point(559, 241);
            this.label2.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(119, 29);
            this.label2.TabIndex = 4;
            this.label2.Text = "xxx.xxx.xx.";
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label3.Location = new System.Drawing.Point(531, 241);
            this.label3.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(21, 29);
            this.label3.TabIndex = 5;
            this.label3.Text = "-";
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label4.Location = new System.Drawing.Point(320, 57);
            this.label4.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(414, 29);
            this.label4.TabIndex = 6;
            this.label4.Text = "Remote Client IP Address Information";
            // 
            // remoteClientPrefixTextBox
            // 
            this.remoteClientPrefixTextBox.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.remoteClientPrefixTextBox.ForeColor = System.Drawing.SystemColors.GrayText;
            this.remoteClientPrefixTextBox.Location = new System.Drawing.Point(436, 321);
            this.remoteClientPrefixTextBox.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.remoteClientPrefixTextBox.Name = "remoteClientPrefixTextBox";
            this.remoteClientPrefixTextBox.Size = new System.Drawing.Size(195, 24);
            this.remoteClientPrefixTextBox.TabIndex = 7;
            this.remoteClientPrefixTextBox.Text = "Enter prefix(192.168.56)";
            this.remoteClientPrefixTextBox.Enter += new System.EventHandler(this.remoteClientPrefixTextBox_Enter);
            this.remoteClientPrefixTextBox.Leave += new System.EventHandler(this.remoteClientPrefixTextBox_Leave);
            // 
            // pictureBox1
            // 
            this.pictureBox1.Cursor = System.Windows.Forms.Cursors.Hand;
            this.pictureBox1.Image = global::Sea_Trials_Script_Launcher.Properties.Resources.info;
            this.pictureBox1.Location = new System.Drawing.Point(603, 438);
            this.pictureBox1.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(32, 22);
            this.pictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pictureBox1.TabIndex = 8;
            this.pictureBox1.TabStop = false;
            this.pictureBox1.Click += new System.EventHandler(this.pictureBox1_Click);
            // 
            // remoteClientIPInfoHelp
            // 
            this.remoteClientIPInfoHelp.Font = new System.Drawing.Font("Microsoft Sans Serif", 9F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.remoteClientIPInfoHelp.Location = new System.Drawing.Point(16, 276);
            this.remoteClientIPInfoHelp.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.remoteClientIPInfoHelp.Name = "remoteClientIPInfoHelp";
            this.remoteClientIPInfoHelp.ReadOnly = true;
            this.remoteClientIPInfoHelp.Size = new System.Drawing.Size(411, 262);
            this.remoteClientIPInfoHelp.TabIndex = 9;
            this.remoteClientIPInfoHelp.Text = resources.GetString("remoteClientIPInfoHelp.Text");
            this.remoteClientIPInfoHelp.Visible = false;
            // 
            // hideRemoteClientIPInfoHelp
            // 
            this.hideRemoteClientIPInfoHelp.AutoSize = true;
            this.hideRemoteClientIPInfoHelp.Cursor = System.Windows.Forms.Cursors.Hand;
            this.hideRemoteClientIPInfoHelp.ForeColor = System.Drawing.SystemColors.HotTrack;
            this.hideRemoteClientIPInfoHelp.Location = new System.Drawing.Point(432, 523);
            this.hideRemoteClientIPInfoHelp.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.hideRemoteClientIPInfoHelp.Name = "hideRemoteClientIPInfoHelp";
            this.hideRemoteClientIPInfoHelp.Size = new System.Drawing.Size(36, 16);
            this.hideRemoteClientIPInfoHelp.TabIndex = 10;
            this.hideRemoteClientIPInfoHelp.Text = "Hide";
            this.hideRemoteClientIPInfoHelp.Visible = false;
            this.hideRemoteClientIPInfoHelp.Click += new System.EventHandler(this.hideRemoteClientIPInfoHelp_Click);
            // 
            // notifyBeginIPDeviceIDFile
            // 
            this.notifyBeginIPDeviceIDFile.Icon = ((System.Drawing.Icon)(resources.GetObject("notifyBeginIPDeviceIDFile.Icon")));
            this.notifyBeginIPDeviceIDFile.Text = "notifyIcon1";
            this.notifyBeginIPDeviceIDFile.Visible = true;
            // 
            // notifyEndIPDeviceIDFile
            // 
            this.notifyEndIPDeviceIDFile.Text = "notifyIcon1";
            this.notifyEndIPDeviceIDFile.Visible = true;
            // 
            // notifyIPPrefixFile
            // 
            this.notifyIPPrefixFile.Text = "notifyIcon1";
            this.notifyIPPrefixFile.Visible = true;
            // 
            // resetIPConfigBtn
            // 
            this.resetIPConfigBtn.Location = new System.Drawing.Point(472, 523);
            this.resetIPConfigBtn.Name = "resetIPConfigBtn";
            this.resetIPConfigBtn.Size = new System.Drawing.Size(122, 28);
            this.resetIPConfigBtn.TabIndex = 11;
            this.resetIPConfigBtn.Text = "Reset IP Config";
            this.resetIPConfigBtn.UseVisualStyleBackColor = true;
            this.resetIPConfigBtn.Click += new System.EventHandler(this.resetIPConfigBtn_Click);
            // 
            // notifyIPConfigReset
            // 
            this.notifyIPConfigReset.Text = "notifyIcon1";
            this.notifyIPConfigReset.Visible = true;
            // 
            // notifIPConfigNotReset
            // 
            this.notifIPConfigNotReset.Text = "notifyIcon1";
            this.notifIPConfigNotReset.Visible = true;
            // 
            // RemoteClientNetworkInformationForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1067, 554);
            this.Controls.Add(this.resetIPConfigBtn);
            this.Controls.Add(this.hideRemoteClientIPInfoHelp);
            this.Controls.Add(this.remoteClientIPInfoHelp);
            this.Controls.Add(this.pictureBox1);
            this.Controls.Add(this.remoteClientPrefixTextBox);
            this.Controls.Add(this.label4);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.endingRemoteClientIPDeviceID);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.remoteCientIPSubmitBtn);
            this.Controls.Add(this.beginningRemoteClientIPDeviceID);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.Name = "RemoteClientNetworkInformationForm";
            this.Text = "Remote Client Network Information";
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox beginningRemoteClientIPDeviceID;
        private System.Windows.Forms.Button remoteCientIPSubmitBtn;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox endingRemoteClientIPDeviceID;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.TextBox remoteClientPrefixTextBox;
        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.RichTextBox remoteClientIPInfoHelp;
        private System.Windows.Forms.Label hideRemoteClientIPInfoHelp;
        private System.Windows.Forms.NotifyIcon notifyBeginIPDeviceIDFile;
        private System.Windows.Forms.NotifyIcon notifyEndIPDeviceIDFile;
        private System.Windows.Forms.NotifyIcon notifyIPPrefixFile;
        private System.Windows.Forms.Button resetIPConfigBtn;
        private System.Windows.Forms.NotifyIcon notifyIPConfigReset;
        private System.Windows.Forms.NotifyIcon notifIPConfigNotReset;
    }
}