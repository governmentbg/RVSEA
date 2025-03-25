namespace DAA.App.FileUpload
{
    partial class MainForm
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
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
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(MainForm));
            newButton = new Button();
            imageList = new ImageList(components);
            filePanel = new Panel();
            loadingPanel = new Panel();
            loadingTextLabel = new Label();
            filesLinePanel = new Panel();
            startAllButton = new Button();
            stopAllButton = new Button();
            timeStartDateTimePicker = new DateTimePicker();
            timeEndDateTimePicker = new DateTimePicker();
            label1 = new Label();
            label2 = new Label();
            timer = new System.Windows.Forms.Timer(components);
            deleteFinishedButton = new Button();
            toolTip = new ToolTip(components);
            reloadQueueButton = new Button();
            loadingPanel.SuspendLayout();
            SuspendLayout();
            // 
            // newButton
            // 
            newButton.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            newButton.Font = new Font("Segoe UI", 9.75F, FontStyle.Regular, GraphicsUnit.Point);
            newButton.ImageIndex = 0;
            newButton.ImageList = imageList;
            newButton.Location = new Point(713, 12);
            newButton.Name = "newButton";
            newButton.Size = new Size(75, 32);
            newButton.TabIndex = 0;
            newButton.Text = "Нов";
            newButton.TextImageRelation = TextImageRelation.ImageBeforeText;
            newButton.UseVisualStyleBackColor = true;
            newButton.Click += newButton_Click;
            // 
            // imageList
            // 
            imageList.ColorDepth = ColorDepth.Depth8Bit;
            imageList.ImageStream = (ImageListStreamer)resources.GetObject("imageList.ImageStream");
            imageList.TransparentColor = Color.Transparent;
            imageList.Images.SetKeyName(0, "add.png");
            imageList.Images.SetKeyName(1, "edit.png");
            imageList.Images.SetKeyName(2, "Trash.png");
            imageList.Images.SetKeyName(3, "folder.png");
            imageList.Images.SetKeyName(4, "Upload.png");
            imageList.Images.SetKeyName(5, "stop.png");
            // 
            // filePanel
            // 
            filePanel.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            filePanel.AutoScroll = true;
            filePanel.Location = new Point(12, 52);
            filePanel.Name = "filePanel";
            filePanel.Size = new Size(776, 386);
            filePanel.TabIndex = 1;
            // 
            // loadingPanel
            // 
            loadingPanel.Anchor = AnchorStyles.Top | AnchorStyles.Bottom | AnchorStyles.Left | AnchorStyles.Right;
            loadingPanel.Controls.Add(loadingTextLabel);
            loadingPanel.Location = new Point(0, 0);
            loadingPanel.Name = "loadingPanel";
            loadingPanel.Size = new Size(801, 448);
            loadingPanel.TabIndex = 0;
            // 
            // loadingTextLabel
            // 
            loadingTextLabel.AutoSize = true;
            loadingTextLabel.Font = new Font("Segoe UI", 15.75F, FontStyle.Bold, GraphicsUnit.Point);
            loadingTextLabel.Location = new Point(53, 50);
            loadingTextLabel.Name = "loadingTextLabel";
            loadingTextLabel.Size = new Size(418, 30);
            loadingTextLabel.TabIndex = 0;
            loadingTextLabel.Text = "Зареждане на информация от сървъра";
            // 
            // filesLinePanel
            // 
            filesLinePanel.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;
            filesLinePanel.BackColor = SystemColors.ActiveBorder;
            filesLinePanel.Location = new Point(12, 50);
            filesLinePanel.Name = "filesLinePanel";
            filesLinePanel.Size = new Size(776, 2);
            filesLinePanel.TabIndex = 10;
            // 
            // startAllButton
            // 
            startAllButton.Font = new Font("Segoe UI", 9.75F, FontStyle.Regular, GraphicsUnit.Point);
            startAllButton.Location = new Point(12, 12);
            startAllButton.Name = "startAllButton";
            startAllButton.Size = new Size(75, 32);
            startAllButton.TabIndex = 0;
            startAllButton.Text = "Старт";
            startAllButton.UseVisualStyleBackColor = true;
            startAllButton.Click += startAllButton_Click;
            // 
            // stopAllButton
            // 
            stopAllButton.Font = new Font("Segoe UI", 9.75F, FontStyle.Regular, GraphicsUnit.Point);
            stopAllButton.Location = new Point(93, 12);
            stopAllButton.Name = "stopAllButton";
            stopAllButton.Size = new Size(75, 32);
            stopAllButton.TabIndex = 1;
            stopAllButton.Text = "Стоп";
            stopAllButton.UseVisualStyleBackColor = true;
            stopAllButton.Click += stopAllButton_Click;
            // 
            // timeStartDateTimePicker
            // 
            timeStartDateTimePicker.CalendarFont = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point);
            timeStartDateTimePicker.CustomFormat = "";
            timeStartDateTimePicker.Font = new Font("Segoe UI", 11.25F, FontStyle.Regular, GraphicsUnit.Point);
            timeStartDateTimePicker.Format = DateTimePickerFormat.Time;
            timeStartDateTimePicker.Location = new Point(230, 15);
            timeStartDateTimePicker.Name = "timeStartDateTimePicker";
            timeStartDateTimePicker.ShowUpDown = true;
            timeStartDateTimePicker.Size = new Size(84, 27);
            timeStartDateTimePicker.TabIndex = 2;
            timeStartDateTimePicker.Value = new DateTime(2022, 10, 31, 8, 0, 0, 0);
            // 
            // timeEndDateTimePicker
            // 
            timeEndDateTimePicker.CalendarFont = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point);
            timeEndDateTimePicker.CustomFormat = "";
            timeEndDateTimePicker.Font = new Font("Segoe UI", 11.25F, FontStyle.Regular, GraphicsUnit.Point);
            timeEndDateTimePicker.Format = DateTimePickerFormat.Time;
            timeEndDateTimePicker.Location = new Point(371, 15);
            timeEndDateTimePicker.Name = "timeEndDateTimePicker";
            timeEndDateTimePicker.ShowUpDown = true;
            timeEndDateTimePicker.Size = new Size(84, 27);
            timeEndDateTimePicker.TabIndex = 3;
            timeEndDateTimePicker.Value = new DateTime(2022, 10, 31, 18, 0, 0, 0);
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Font = new Font("Segoe UI", 11.25F, FontStyle.Regular, GraphicsUnit.Point);
            label1.Location = new Point(198, 18);
            label1.Name = "label1";
            label1.Size = new Size(26, 20);
            label1.TabIndex = 4;
            label1.Text = "От";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Font = new Font("Segoe UI", 11.25F, FontStyle.Regular, GraphicsUnit.Point);
            label2.Location = new Point(339, 18);
            label2.Name = "label2";
            label2.Size = new Size(28, 20);
            label2.TabIndex = 5;
            label2.Text = "До";
            // 
            // timer
            // 
            timer.Enabled = true;
            timer.Interval = 3000;
            timer.Tick += timer_Tick;
            // 
            // deleteFinishedButton
            // 
            deleteFinishedButton.AccessibleDescription = "";
            deleteFinishedButton.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            deleteFinishedButton.Font = new Font("Segoe UI", 14F, FontStyle.Regular, GraphicsUnit.Point);
            deleteFinishedButton.ImageList = imageList;
            deleteFinishedButton.Location = new Point(654, 12);
            deleteFinishedButton.Name = "deleteFinishedButton";
            deleteFinishedButton.Size = new Size(34, 32);
            deleteFinishedButton.TabIndex = 24;
            deleteFinishedButton.Text = "";
            deleteFinishedButton.TextAlign = ContentAlignment.TopCenter;
            deleteFinishedButton.TextImageRelation = TextImageRelation.ImageBeforeText;
            deleteFinishedButton.UseVisualStyleBackColor = true;
            deleteFinishedButton.Click += deleteFinishedButton_Click;
            // 
            // toolTip
            // 
            toolTip.IsBalloon = true;
            toolTip.ToolTipTitle = "File Upload App";
            // 
            // reloadQueueButton
            // 
            reloadQueueButton.AccessibleDescription = "";
            reloadQueueButton.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            reloadQueueButton.Font = new Font("Segoe UI", 12F, FontStyle.Regular, GraphicsUnit.Point);
            reloadQueueButton.ImageList = imageList;
            reloadQueueButton.Location = new Point(620, 12);
            reloadQueueButton.Name = "reloadQueueButton";
            reloadQueueButton.Size = new Size(34, 32);
            reloadQueueButton.TabIndex = 12;
            reloadQueueButton.Text = "";
            reloadQueueButton.TextImageRelation = TextImageRelation.ImageBeforeText;
            reloadQueueButton.UseVisualStyleBackColor = true;
            reloadQueueButton.Click += reloadQueueButton_Click;
            // 
            // MainForm
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(800, 450);
            Controls.Add(loadingPanel);
            Controls.Add(reloadQueueButton);
            Controls.Add(deleteFinishedButton);
            Controls.Add(filesLinePanel);
            Controls.Add(label2);
            Controls.Add(label1);
            Controls.Add(timeEndDateTimePicker);
            Controls.Add(timeStartDateTimePicker);
            Controls.Add(startAllButton);
            Controls.Add(stopAllButton);
            Controls.Add(newButton);
            Controls.Add(filePanel);
            Name = "MainForm";
            Text = "СЕА Импорт";
            Load += MainForm_Load;
            loadingPanel.ResumeLayout(false);
            loadingPanel.PerformLayout();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Button newButton;
        private Panel filePanel;
        private ImageList imageList;
        private Button startAllButton;
        private Button stopAllButton;
        private DateTimePicker timeStartDateTimePicker;
        private Panel loadingPanel;
        private Label loadingTextLabel;
        private DateTimePicker timeEndDateTimePicker;
        private Label label1;
        private Label label2;
        private System.Windows.Forms.Timer timer;
        private Button reloadQueueButton;
        private Panel filesLinePanel;
        private Button deleteFinishedButton;
        private ToolTip toolTip;
    }
}