namespace Sea_Trials_Script_Launcher
{
    partial class TrialNotesForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TrialNotesForm));
            this.NotesHeader = new System.Windows.Forms.Label();
            this.HullNameLabel = new System.Windows.Forms.Label();
            this.TrialNotesTextBox = new System.Windows.Forms.RichTextBox();
            this.ChangeHullBtn = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // NotesHeader
            // 
            this.NotesHeader.AutoSize = true;
            this.NotesHeader.Font = new System.Drawing.Font("Microsoft Sans Serif", 16.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.NotesHeader.Location = new System.Drawing.Point(532, 11);
            this.NotesHeader.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.NotesHeader.Name = "NotesHeader";
            this.NotesHeader.Size = new System.Drawing.Size(209, 32);
            this.NotesHeader.TabIndex = 0;
            this.NotesHeader.Text = "Sea Trial Notes";
            // 
            // HullNameLabel
            // 
            this.HullNameLabel.AutoSize = true;
            this.HullNameLabel.Font = new System.Drawing.Font("Consolas", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.HullNameLabel.Location = new System.Drawing.Point(582, 59);
            this.HullNameLabel.Margin = new System.Windows.Forms.Padding(4, 0, 4, 0);
            this.HullNameLabel.Name = "HullNameLabel";
            this.HullNameLabel.Size = new System.Drawing.Size(108, 20);
            this.HullNameLabel.TabIndex = 1;
            this.HullNameLabel.Text = "HullNameLbl";
            this.HullNameLabel.TextAlign = System.Drawing.ContentAlignment.TopCenter;
            // 
            // TrialNotesTextBox
            // 
            this.TrialNotesTextBox.Font = new System.Drawing.Font("Microsoft Sans Serif", 10.2F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.TrialNotesTextBox.Location = new System.Drawing.Point(44, 101);
            this.TrialNotesTextBox.Margin = new System.Windows.Forms.Padding(4);
            this.TrialNotesTextBox.Name = "TrialNotesTextBox";
            this.TrialNotesTextBox.Size = new System.Drawing.Size(1184, 518);
            this.TrialNotesTextBox.TabIndex = 2;
            this.TrialNotesTextBox.Text = "";
            // 
            // ChangeHullBtn
            // 
            this.ChangeHullBtn.Location = new System.Drawing.Point(560, 631);
            this.ChangeHullBtn.Margin = new System.Windows.Forms.Padding(4);
            this.ChangeHullBtn.Name = "ChangeHullBtn";
            this.ChangeHullBtn.Size = new System.Drawing.Size(152, 28);
            this.ChangeHullBtn.TabIndex = 3;
            this.ChangeHullBtn.Text = "Change Hull/Trial";
            this.ChangeHullBtn.UseVisualStyleBackColor = true;
            this.ChangeHullBtn.Click += new System.EventHandler(this.ChangeHullBtn_Click);
            // 
            // TrialNotesForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1273, 671);
            this.Controls.Add(this.ChangeHullBtn);
            this.Controls.Add(this.TrialNotesTextBox);
            this.Controls.Add(this.HullNameLabel);
            this.Controls.Add(this.NotesHeader);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Margin = new System.Windows.Forms.Padding(4);
            this.Name = "TrialNotesForm";
            this.Text = "STCM Trial Notes";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.TrialNotesForm_FormClosing);
            this.Load += new System.EventHandler(this.Form1_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label NotesHeader;
        private System.Windows.Forms.Label HullNameLabel;
        private System.Windows.Forms.RichTextBox TrialNotesTextBox;
        private System.Windows.Forms.Button ChangeHullBtn;
    }
}