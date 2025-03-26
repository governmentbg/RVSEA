namespace DAA.App.FileUpload
{
    partial class FileForm
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
            components = new System.ComponentModel.Container();
            FileNameTextBox = new TextBox();
            deleteButton = new Button();
            progressBar = new ProgressBar();
            editButton = new Button();
            uploadButton = new Button();
            toolTip = new ToolTip(components);
            statusLabel = new Label();
            stopButton = new Button();
            sizeLabel = new Label();
            panel1 = new Panel();
            contextMenu = new ContextMenuStrip(components);
            addDerivativeMenuItem = new ToolStripMenuItem();
            addDemoMenuItem = new ToolStripMenuItem();
            contextMenu.SuspendLayout();
            SuspendLayout();
            // 
            // FileNameTextBox
            // 
            FileNameTextBox.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
            FileNameTextBox.Font = new Font("Segoe UI", 10F, FontStyle.Regular, GraphicsUnit.Point);
            FileNameTextBox.Location = new Point(23, 0);
            FileNameTextBox.Name = "FileNameTextBox";
            FileNameTextBox.ReadOnly = true;
            FileNameTextBox.Size = new Size(234, 25);
            FileNameTextBox.TabIndex = 0;
            // 
            // deleteButton
            // 
            deleteButton.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            deleteButton.Location = new Point(552, 0);
            deleteButton.Name = "deleteButton";
            deleteButton.Size = new Size(24, 24);
            deleteButton.TabIndex = 1;
            deleteButton.Text = "X";
            deleteButton.UseVisualStyleBackColor = true;
            deleteButton.Click += deleteButton_Click;
            // 
            // progressBar
            // 
            progressBar.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            progressBar.Location = new Point(263, 0);
            progressBar.Name = "progressBar";
            progressBar.Size = new Size(144, 23);
            progressBar.Style = ProgressBarStyle.Continuous;
            progressBar.TabIndex = 2;
            progressBar.Value = 40;
            progressBar.MouseEnter += progressBar_MouseEnter;
            progressBar.MouseLeave += progressBar_MouseLeave;
            // 
            // editButton
            // 
            editButton.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            editButton.Location = new Point(529, 0);
            editButton.Name = "editButton";
            editButton.Size = new Size(24, 24);
            editButton.TabIndex = 3;
            editButton.Text = "E";
            editButton.UseVisualStyleBackColor = true;
            editButton.Click += editButton_Click;
            // 
            // uploadButton
            // 
            uploadButton.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            uploadButton.Location = new Point(506, 0);
            uploadButton.Name = "uploadButton";
            uploadButton.Size = new Size(24, 24);
            uploadButton.TabIndex = 4;
            uploadButton.Text = "U";
            uploadButton.UseVisualStyleBackColor = true;
            uploadButton.Click += uploadButton_Click;
            // 
            // toolTip
            // 
            toolTip.IsBalloon = true;
            toolTip.ToolTipTitle = "File Upload App";
            // 
            // statusLabel
            // 
            statusLabel.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            statusLabel.Font = new Font("Segoe UI", 10F, FontStyle.Bold, GraphicsUnit.Point);
            statusLabel.Location = new Point(404, 0);
            statusLabel.Name = "statusLabel";
            statusLabel.Size = new Size(96, 23);
            statusLabel.TabIndex = 5;
            statusLabel.Text = "label1";
            statusLabel.TextAlign = ContentAlignment.MiddleCenter;
            statusLabel.Click += statusLabel_Click;
            statusLabel.MouseEnter += statusLabel_MouseEnter;
            statusLabel.MouseLeave += statusLabel_MouseLeave;
            // 
            // stopButton
            // 
            stopButton.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            stopButton.Location = new Point(506, 0);
            stopButton.Name = "stopButton";
            stopButton.Size = new Size(24, 24);
            stopButton.TabIndex = 6;
            stopButton.Text = "S";
            stopButton.UseVisualStyleBackColor = true;
            stopButton.Click += stopButton_Click;
            // 
            // sizeLabel
            // 
            sizeLabel.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            sizeLabel.Font = new Font("Segoe UI", 10F, FontStyle.Regular, GraphicsUnit.Point);
            sizeLabel.Location = new Point(263, 0);
            sizeLabel.Name = "sizeLabel";
            sizeLabel.Size = new Size(149, 23);
            sizeLabel.TabIndex = 7;
            sizeLabel.Text = "xxx / yyy MB";
            sizeLabel.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // panel1
            // 
            panel1.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
            panel1.BackColor = SystemColors.ActiveBorder;
            panel1.Location = new Point(0, 24);
            panel1.Name = "panel1";
            panel1.Size = new Size(576, 2);
            panel1.TabIndex = 8;
            // 
            // contextMenu
            // 
            contextMenu.Items.AddRange(new ToolStripItem[] { addDerivativeMenuItem, addDemoMenuItem });
            contextMenu.Name = "contextMenuStrip1";
            contextMenu.Size = new Size(184, 48);
            // 
            // addDerivativeMenuItem
            // 
            addDerivativeMenuItem.Name = "addDerivativeMenuItem";
            addDerivativeMenuItem.Size = new Size(183, 22);
            addDerivativeMenuItem.Text = "Добави производен";
            addDerivativeMenuItem.Click += addDerivativeMenuItem_Click;
            // 
            // addDemoMenuItem
            // 
            addDemoMenuItem.Name = "addDemoMenuItem";
            addDemoMenuItem.Size = new Size(183, 22);
            addDemoMenuItem.Text = "Добави демо";
            addDemoMenuItem.Click += addDemoMenuItem_Click;
            // 
            // FileForm
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(578, 26);
            ContextMenuStrip = contextMenu;
            Controls.Add(sizeLabel);
            Controls.Add(stopButton);
            Controls.Add(statusLabel);
            Controls.Add(uploadButton);
            Controls.Add(editButton);
            Controls.Add(progressBar);
            Controls.Add(deleteButton);
            Controls.Add(FileNameTextBox);
            Controls.Add(panel1);
            FormBorderStyle = FormBorderStyle.None;
            Name = "FileForm";
            Text = "Form2";
            Resize += FileForm_Resize;
            contextMenu.ResumeLayout(false);
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private TextBox FileNameTextBox;
        private Button deleteButton;
        private ProgressBar progressBar;
        private Button editButton;
        private Button uploadButton;
        private ToolTip toolTip;
        private Label statusLabel;
        private Button stopButton;
        private Label sizeLabel;
        private Panel panel1;
        private ContextMenuStrip contextMenu;
        private ToolStripMenuItem addDerivativeMenuItem;
        private ToolStripMenuItem addDemoMenuItem;
    }
}