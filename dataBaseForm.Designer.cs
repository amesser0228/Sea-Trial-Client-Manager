namespace Sea_Trials_Script_Launcher
{
    partial class dataBaseForm
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(dataBaseForm));
            this.dataGridView1 = new System.Windows.Forms.DataGridView();
            this.Department = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.TeamLead = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.GettingUnderway = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.ActiveWorkings = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.ClosedOut = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.RequestingUser = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Affiliation = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.CardsInOtherDept = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.Notes = new System.Windows.Forms.DataGridViewTextBoxColumn();
            this.label1 = new System.Windows.Forms.Label();
            this.cheklistSaveBtn = new System.Windows.Forms.Button();
            this.loadCKLBtn = new System.Windows.Forms.Button();
            this.pictureBox1 = new System.Windows.Forms.PictureBox();
            this.clearChklistBtn = new System.Windows.Forms.Button();
            this.menuStrip1 = new System.Windows.Forms.MenuStrip();
            this.optionsToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            this.saveToADifferentLocationToolStripMenuItem = new System.Windows.Forms.ToolStripMenuItem();
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).BeginInit();
            this.menuStrip1.SuspendLayout();
            this.SuspendLayout();
            // 
            // dataGridView1
            // 
            this.dataGridView1.ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode.AutoSize;
            this.dataGridView1.Columns.AddRange(new System.Windows.Forms.DataGridViewColumn[] {
            this.Department,
            this.TeamLead,
            this.GettingUnderway,
            this.ActiveWorkings,
            this.ClosedOut,
            this.RequestingUser,
            this.Affiliation,
            this.CardsInOtherDept,
            this.Notes});
            this.dataGridView1.Location = new System.Drawing.Point(26, 117);
            this.dataGridView1.Name = "dataGridView1";
            this.dataGridView1.RowHeadersWidth = 51;
            this.dataGridView1.Size = new System.Drawing.Size(944, 353);
            this.dataGridView1.TabIndex = 0;
            // 
            // Department
            // 
            this.Department.HeaderText = "Department";
            this.Department.MinimumWidth = 6;
            this.Department.Name = "Department";
            this.Department.Width = 125;
            // 
            // TeamLead
            // 
            this.TeamLead.HeaderText = "TeamLead";
            this.TeamLead.MinimumWidth = 6;
            this.TeamLead.Name = "TeamLead";
            this.TeamLead.Width = 125;
            // 
            // GettingUnderway
            // 
            this.GettingUnderway.AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.ColumnHeader;
            this.GettingUnderway.HeaderText = "GettingUnderway";
            this.GettingUnderway.MinimumWidth = 6;
            this.GettingUnderway.Name = "GettingUnderway";
            this.GettingUnderway.Width = 114;
            // 
            // ActiveWorkings
            // 
            this.ActiveWorkings.HeaderText = "ActiveWorkings";
            this.ActiveWorkings.MinimumWidth = 6;
            this.ActiveWorkings.Name = "ActiveWorkings";
            this.ActiveWorkings.Width = 125;
            // 
            // ClosedOut
            // 
            this.ClosedOut.HeaderText = "ClosedOut";
            this.ClosedOut.MinimumWidth = 6;
            this.ClosedOut.Name = "ClosedOut";
            this.ClosedOut.Width = 125;
            // 
            // RequestingUser
            // 
            this.RequestingUser.HeaderText = "RequestingUser";
            this.RequestingUser.MinimumWidth = 6;
            this.RequestingUser.Name = "RequestingUser";
            this.RequestingUser.Width = 125;
            // 
            // Affiliation
            // 
            this.Affiliation.HeaderText = "Affiliation";
            this.Affiliation.MinimumWidth = 6;
            this.Affiliation.Name = "Affiliation";
            this.Affiliation.Width = 125;
            // 
            // CardsInOtherDept
            // 
            this.CardsInOtherDept.HeaderText = "CardsInOtherDept";
            this.CardsInOtherDept.MinimumWidth = 6;
            this.CardsInOtherDept.Name = "CardsInOtherDept";
            this.CardsInOtherDept.Width = 125;
            // 
            // Notes
            // 
            this.Notes.HeaderText = "Notes";
            this.Notes.MinimumWidth = 6;
            this.Notes.Name = "Notes";
            this.Notes.Width = 185;
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Font = new System.Drawing.Font("Microsoft Sans Serif", 18F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.label1.Location = new System.Drawing.Point(400, 46);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(213, 29);
            this.label1.TabIndex = 1;
            this.label1.Text = "Closeout Checklist";
            // 
            // cheklistSaveBtn
            // 
            this.cheklistSaveBtn.Location = new System.Drawing.Point(352, 490);
            this.cheklistSaveBtn.Name = "cheklistSaveBtn";
            this.cheklistSaveBtn.Size = new System.Drawing.Size(93, 36);
            this.cheklistSaveBtn.TabIndex = 2;
            this.cheklistSaveBtn.Text = "Save";
            this.cheklistSaveBtn.UseVisualStyleBackColor = true;
            this.cheklistSaveBtn.Click += new System.EventHandler(this.cheklistSaveBtn_Click);
            // 
            // loadCKLBtn
            // 
            this.loadCKLBtn.Location = new System.Drawing.Point(452, 490);
            this.loadCKLBtn.Name = "loadCKLBtn";
            this.loadCKLBtn.Size = new System.Drawing.Size(93, 36);
            this.loadCKLBtn.TabIndex = 3;
            this.loadCKLBtn.Text = "Load";
            this.loadCKLBtn.UseVisualStyleBackColor = true;
            this.loadCKLBtn.Click += new System.EventHandler(this.loadCKLBtn_Click);
            // 
            // pictureBox1
            // 
            this.pictureBox1.Image = global::Sea_Trials_Script_Launcher.Properties.Resources.checkList_Ico;
            this.pictureBox1.Location = new System.Drawing.Point(870, 12);
            this.pictureBox1.Name = "pictureBox1";
            this.pictureBox1.Size = new System.Drawing.Size(98, 89);
            this.pictureBox1.SizeMode = System.Windows.Forms.PictureBoxSizeMode.StretchImage;
            this.pictureBox1.TabIndex = 4;
            this.pictureBox1.TabStop = false;
            // 
            // clearChklistBtn
            // 
            this.clearChklistBtn.Location = new System.Drawing.Point(550, 490);
            this.clearChklistBtn.Name = "clearChklistBtn";
            this.clearChklistBtn.Size = new System.Drawing.Size(93, 36);
            this.clearChklistBtn.TabIndex = 5;
            this.clearChklistBtn.Text = "Clear";
            this.clearChklistBtn.UseVisualStyleBackColor = true;
            this.clearChklistBtn.Click += new System.EventHandler(this.clearChklistBtn_Click);
            // 
            // menuStrip1
            // 
            this.menuStrip1.AutoSize = false;
            this.menuStrip1.Dock = System.Windows.Forms.DockStyle.None;
            this.menuStrip1.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.optionsToolStripMenuItem});
            this.menuStrip1.Location = new System.Drawing.Point(26, 9);
            this.menuStrip1.Name = "menuStrip1";
            this.menuStrip1.Size = new System.Drawing.Size(82, 24);
            this.menuStrip1.Stretch = false;
            this.menuStrip1.TabIndex = 6;
            this.menuStrip1.Text = "menuStrip1";
            // 
            // optionsToolStripMenuItem
            // 
            this.optionsToolStripMenuItem.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.saveToADifferentLocationToolStripMenuItem});
            this.optionsToolStripMenuItem.Name = "optionsToolStripMenuItem";
            this.optionsToolStripMenuItem.Size = new System.Drawing.Size(61, 20);
            this.optionsToolStripMenuItem.Text = "Options";
            // 
            // saveToADifferentLocationToolStripMenuItem
            // 
            this.saveToADifferentLocationToolStripMenuItem.Name = "saveToADifferentLocationToolStripMenuItem";
            this.saveToADifferentLocationToolStripMenuItem.Size = new System.Drawing.Size(215, 22);
            this.saveToADifferentLocationToolStripMenuItem.Text = "Save to a different location";
            this.saveToADifferentLocationToolStripMenuItem.Click += new System.EventHandler(this.saveToADifferentLocationToolStripMenuItem_Click);
            // 
            // dataBaseForm
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(997, 571);
            this.Controls.Add(this.clearChklistBtn);
            this.Controls.Add(this.pictureBox1);
            this.Controls.Add(this.loadCKLBtn);
            this.Controls.Add(this.cheklistSaveBtn);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.dataGridView1);
            this.Controls.Add(this.menuStrip1);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.MainMenuStrip = this.menuStrip1;
            this.Name = "dataBaseForm";
            this.Text = "Closeout Checklist";
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.Checklist_FormClosing);
            this.Load += new System.EventHandler(this.Form2_Load);
            ((System.ComponentModel.ISupportInitialize)(this.dataGridView1)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.pictureBox1)).EndInit();
            this.menuStrip1.ResumeLayout(false);
            this.menuStrip1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.DataGridView dataGridView1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Button cheklistSaveBtn;
        private System.Windows.Forms.Button loadCKLBtn;
        private System.Windows.Forms.PictureBox pictureBox1;
        private System.Windows.Forms.Button clearChklistBtn;
        private System.Windows.Forms.DataGridViewTextBoxColumn Department;
        private System.Windows.Forms.DataGridViewTextBoxColumn TeamLead;
        private System.Windows.Forms.DataGridViewTextBoxColumn GettingUnderway;
        private System.Windows.Forms.DataGridViewTextBoxColumn ActiveWorkings;
        private System.Windows.Forms.DataGridViewTextBoxColumn ClosedOut;
        private System.Windows.Forms.DataGridViewTextBoxColumn RequestingUser;
        private System.Windows.Forms.DataGridViewTextBoxColumn Affiliation;
        private System.Windows.Forms.DataGridViewTextBoxColumn CardsInOtherDept;
        private System.Windows.Forms.DataGridViewTextBoxColumn Notes;
        private System.Windows.Forms.MenuStrip menuStrip1;
        private System.Windows.Forms.ToolStripMenuItem optionsToolStripMenuItem;
        private System.Windows.Forms.ToolStripMenuItem saveToADifferentLocationToolStripMenuItem;
    }
}