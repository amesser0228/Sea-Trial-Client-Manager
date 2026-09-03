namespace Sea_Trials_Script_Launcher
{
    partial class internalScriptViewer
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
            this.label1 = new System.Windows.Forms.Label();
            this.internalScriptsBox = new System.Windows.Forms.ListBox();
            this.label3 = new System.Windows.Forms.Label();
            this.ReadMe = new System.Windows.Forms.Button();
            this.shellScriptsListBoxDeleteBtn = new System.Windows.Forms.Button();
            this.shellScriptsListBoxAddBtn = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(284, 15);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(233, 29);
            this.label1.TabIndex = 0;
            this.label1.Text = "Internal Shell Scripts";
            // 
            // internalScriptsBox
            // 
            this.internalScriptsBox.FormattingEnabled = true;
            this.internalScriptsBox.Location = new System.Drawing.Point(266, 132);
            this.internalScriptsBox.Name = "internalScriptsBox";
            this.internalScriptsBox.Size = new System.Drawing.Size(268, 264);
            this.internalScriptsBox.TabIndex = 1;
            this.internalScriptsBox.DoubleClick += new System.EventHandler(this.internalScriptsBox_DoubleClick);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Location = new System.Drawing.Point(317, 399);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(166, 13);
            this.label3.TabIndex = 4;
            this.label3.Text = "Double click a script file to open it";
            // 
            // ReadMe
            // 
            this.ReadMe.Location = new System.Drawing.Point(357, 57);
            this.ReadMe.Name = "ReadMe";
            this.ReadMe.Size = new System.Drawing.Size(75, 23);
            this.ReadMe.TabIndex = 5;
            this.ReadMe.Text = "Read Me";
            this.ReadMe.UseVisualStyleBackColor = true;
            this.ReadMe.Click += new System.EventHandler(this.ReadMe_Click);
            // 
            // shellScriptsListBoxDeleteBtn
            // 
            this.shellScriptsListBoxDeleteBtn.Cursor = System.Windows.Forms.Cursors.Hand;
            this.shellScriptsListBoxDeleteBtn.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.shellScriptsListBoxDeleteBtn.Location = new System.Drawing.Point(313, 103);
            this.shellScriptsListBoxDeleteBtn.Name = "shellScriptsListBoxDeleteBtn";
            this.shellScriptsListBoxDeleteBtn.Size = new System.Drawing.Size(75, 23);
            this.shellScriptsListBoxDeleteBtn.TabIndex = 6;
            this.shellScriptsListBoxDeleteBtn.Text = "Delete";
            this.shellScriptsListBoxDeleteBtn.UseVisualStyleBackColor = true;
            this.shellScriptsListBoxDeleteBtn.Click += new System.EventHandler(this.shellScriptsListBoxDeleteBtn_Click);
            // 
            // shellScriptsListBoxAddBtn
            // 
            this.shellScriptsListBoxAddBtn.Cursor = System.Windows.Forms.Cursors.Hand;
            this.shellScriptsListBoxAddBtn.Font = new System.Drawing.Font("Microsoft Sans Serif", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.shellScriptsListBoxAddBtn.Location = new System.Drawing.Point(413, 103);
            this.shellScriptsListBoxAddBtn.Name = "shellScriptsListBoxAddBtn";
            this.shellScriptsListBoxAddBtn.Size = new System.Drawing.Size(75, 23);
            this.shellScriptsListBoxAddBtn.TabIndex = 7;
            this.shellScriptsListBoxAddBtn.Text = "Add";
            this.shellScriptsListBoxAddBtn.UseVisualStyleBackColor = true;
            this.shellScriptsListBoxAddBtn.Click += new System.EventHandler(this.shellScriptsListBoxAddBtn_Click);
            // 
            // internalScriptViewer
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(800, 450);
            this.Controls.Add(this.shellScriptsListBoxAddBtn);
            this.Controls.Add(this.shellScriptsListBoxDeleteBtn);
            this.Controls.Add(this.ReadMe);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.internalScriptsBox);
            this.Controls.Add(this.label1);
            this.Name = "internalScriptViewer";
            this.Text = "Script Viewer";
            this.Load += new System.EventHandler(this.Form1_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.ListBox internalScriptsBox;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Button ReadMe;
        private System.Windows.Forms.Button shellScriptsListBoxDeleteBtn;
        private System.Windows.Forms.Button shellScriptsListBoxAddBtn;
    }
}