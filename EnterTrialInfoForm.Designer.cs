namespace Sea_Trials_Script_Launcher
{
    partial class EnterTrialInfoForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(EnterTrialInfoForm));
            this.label1 = new System.Windows.Forms.Label();
            this.TrialInfoTextBox = new System.Windows.Forms.TextBox();
            this.TrialInfoSubmitBtn = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(112, 99);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(375, 40);
            this.label1.TabIndex = 0;
            this.label1.Text = "Enter Trial Information: (Ship class, Hull#, Trial Type)\r\nEx: LCS 38 AT";
            // 
            // TrialInfoTextBox
            // 
            this.TrialInfoTextBox.Location = new System.Drawing.Point(166, 158);
            this.TrialInfoTextBox.Name = "TrialInfoTextBox";
            this.TrialInfoTextBox.Size = new System.Drawing.Size(267, 20);
            this.TrialInfoTextBox.TabIndex = 1;
            // 
            // TrialInfoSubmitBtn
            // 
            this.TrialInfoSubmitBtn.Location = new System.Drawing.Point(262, 216);
            this.TrialInfoSubmitBtn.Name = "TrialInfoSubmitBtn";
            this.TrialInfoSubmitBtn.Size = new System.Drawing.Size(75, 23);
            this.TrialInfoSubmitBtn.TabIndex = 2;
            this.TrialInfoSubmitBtn.Text = "Submit";
            this.TrialInfoSubmitBtn.UseVisualStyleBackColor = true;
            this.TrialInfoSubmitBtn.Click += new System.EventHandler(this.TrialInfoSubmitBtn_Click);
            // 
            // Form2
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(598, 338);
            this.Controls.Add(this.TrialInfoSubmitBtn);
            this.Controls.Add(this.TrialInfoTextBox);
            this.Controls.Add(this.label1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "Form2";
            this.Text = "Enter Trial Information";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.TextBox TrialInfoTextBox;
        private System.Windows.Forms.Button TrialInfoSubmitBtn;
    }
}