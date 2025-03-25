using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace DAA.App.FileUpload
{
    public partial class LoginForm : Form
    {
        private readonly string key;
        public LoginForm()
        {
            InitializeComponent();

            key = "$%^&#$&^%$TUgjp;";
        }

        private void LoginForm_Load(object sender, EventArgs e)
        {
            //return;

            if (Properties.Settings.Default.UpgradeNeeded)
            {
                Properties.Settings.Default.Upgrade();
                Properties.Settings.Default.UpgradeNeeded = false;
                Properties.Settings.Default.Save(); 
            }
            usernameTextBox.Text = Properties.Settings.Default.UserName;
            passwordTextBox.Text = string.IsNullOrEmpty(Properties.Settings.Default.Password) ? "" :
                EncryptUtil.Decrypt(Properties.Settings.Default.Password, key);
            savePasswordCheckBox.Checked = Properties.Settings.Default.SavePassword;
        }

        private void okButton_Click(object sender, EventArgs e)
        {
            //return;

            Properties.Settings.Default.UserName = usernameTextBox.Text;
            Properties.Settings.Default.Password = !savePasswordCheckBox.Checked ? "" :
                EncryptUtil.Encrypt(passwordTextBox.Text, key);
            Properties.Settings.Default.SavePassword = savePasswordCheckBox.Checked;
            Properties.Settings.Default.Save();
        }
    }
}
