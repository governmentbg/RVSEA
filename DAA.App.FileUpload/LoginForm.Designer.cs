namespace DAA.App.FileUpload
{
    partial class LoginForm
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
            label1 = new Label();
            okButton = new Button();
            usernameTextBox = new TextBox();
            cancelButton = new Button();
            passwordTextBox = new TextBox();
            label2 = new Label();
            savePasswordCheckBox = new CheckBox();
            SuspendLayout();
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Location = new Point(12, 25);
            label1.Name = "label1";
            label1.Size = new Size(73, 15);
            label1.TabIndex = 0;
            label1.Text = "Потребител";
            // 
            // okButton
            // 
            okButton.DialogResult = DialogResult.OK;
            okButton.Location = new Point(110, 105);
            okButton.Name = "okButton";
            okButton.Size = new Size(75, 23);
            okButton.TabIndex = 4;
            okButton.Text = "Вход";
            okButton.UseVisualStyleBackColor = true;
            okButton.Click += okButton_Click;
            // 
            // usernameTextBox
            // 
            usernameTextBox.Location = new Point(110, 22);
            usernameTextBox.Name = "usernameTextBox";
            usernameTextBox.Size = new Size(156, 23);
            usernameTextBox.TabIndex = 1;
            usernameTextBox.Text = "kontrax\\ttest";
            // 
            // cancelButton
            // 
            cancelButton.DialogResult = DialogResult.Cancel;
            cancelButton.Location = new Point(191, 105);
            cancelButton.Name = "cancelButton";
            cancelButton.Size = new Size(75, 23);
            cancelButton.TabIndex = 5;
            cancelButton.Text = "Отказ";
            cancelButton.UseVisualStyleBackColor = true;
            // 
            // passwordTextBox
            // 
            passwordTextBox.Location = new Point(110, 51);
            passwordTextBox.Name = "passwordTextBox";
            passwordTextBox.PasswordChar = '●';
            passwordTextBox.Size = new Size(156, 23);
            passwordTextBox.TabIndex = 3;
            passwordTextBox.Text = "Kontrax1234&";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Location = new Point(12, 54);
            label2.Name = "label2";
            label2.Size = new Size(49, 15);
            label2.TabIndex = 2;
            label2.Text = "Парола";
            // 
            // savePasswordCheckBox
            // 
            savePasswordCheckBox.AutoSize = true;
            savePasswordCheckBox.Location = new Point(110, 80);
            savePasswordCheckBox.Name = "savePasswordCheckBox";
            savePasswordCheckBox.Size = new Size(128, 19);
            savePasswordCheckBox.TabIndex = 6;
            savePasswordCheckBox.Text = "запомни паролата";
            savePasswordCheckBox.UseVisualStyleBackColor = true;
            // 
            // LoginForm
            // 
            AcceptButton = okButton;
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(284, 146);
            Controls.Add(savePasswordCheckBox);
            Controls.Add(passwordTextBox);
            Controls.Add(label2);
            Controls.Add(cancelButton);
            Controls.Add(usernameTextBox);
            Controls.Add(okButton);
            Controls.Add(label1);
            Name = "LoginForm";
            Text = "Вход в ИСДА";
            Load += LoginForm_Load;
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Label label1;
        private Button okButton;
        private Button cancelButton;
        private Label label2;
        public TextBox usernameTextBox;
        public TextBox passwordTextBox;
        private CheckBox savePasswordCheckBox;
    }
}