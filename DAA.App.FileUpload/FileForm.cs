using DAA.Models.FileUploadApp;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace DAA.App.FileUpload
{
    public partial class FileForm : Form
    {
        private ImageList _imageList;
        private EventHandler<FileActionType> _onAction;
        public int QueueItemId { get; set; }
        private string _progressText { get; set; } = "";
        private string? _errorText { get; set; }
        public FileForm(ImageList imageList, EventHandler<FileActionType> onAction)
        {
            InitializeComponent();

            _imageList = imageList;
            _onAction = onAction;

            InitComponents();
        }

        public void LoadFromModel(QueueItemModel model)
        {
            QueueItemId = model.Id;
            FileNameTextBox.Text = model.LocalFileName;
            FileNameTextBox.SelectionStart = FileNameTextBox.Text.Length;
            FileNameTextBox.SelectionLength = 0;

            _progressText = $"{bytesToMbString(model.Position, false)}/{bytesToMbString(model.Size)}";
            int progressPercent = model.Size == 0 ? 100 : (int)(100 * ((decimal)model.Position / model.Size));
            progressBar.Value = progressPercent;

            _errorText = model.ErrorMessage;

            statusLabel.Text =
                !string.IsNullOrEmpty(_errorText) ? "Грешка!" :
                model.Finished ? "Качен" :
                progressPercent == 0 ? $"Чака" :
                model.JobStatus == JobStatus.Running ? "Качва се" :
                model.JobStatus == JobStatus.StopSignalled ? "Спира" :
                model.JobStatus == JobStatus.Stopped ? "Спрял" :
                "Прекъснат";

            sizeLabel.Text = _progressText;

            bool running = model.JobStatus == JobStatus.Running;

            stopButton.Visible = running;
            uploadButton.Visible = !running && !model.Finished;
            progressBar.Visible = running;
            sizeLabel.Visible = !running;
            editButton.Visible = !running && model.Position == 0;
            deleteButton.Visible = true; // model.Position == 0 || model.Finished;

            this.ContextMenuStrip = model.FileKind == FileKind.Master ? ContextMenuStrip : null;

            this.BackColor = GetFileKindColor(model.FileKind);

            toolTip.SetToolTip(this, 
                $"QueueId: {model.Id}, Process: {model.ProcessKind}, Kind: {model.FileKind},{Environment.NewLine}" + 
                $"Created guid: {model.CreatedGuid}, Finished guid: {model.FinishedGuid},{Environment.NewLine}" + 
                $"Master guid: {model.MasterDocumentId}"
            );
        }

        private void InitComponents()
        {
            deleteButton.ImageList = _imageList;
            uploadButton.ImageList = _imageList;
            stopButton.ImageList = _imageList;
            editButton.ImageList = _imageList;

            if (_imageList != null)
            {
                deleteButton.ImageIndex = 2;
                uploadButton.ImageIndex = 4;
                stopButton.ImageIndex = 5;
                editButton.ImageIndex = 1;

                deleteButton.Text = null;
                uploadButton.Text = null;
                stopButton.Text = null;
                editButton.Text = null;
            }
        }

        private void editButton_Click(object sender, EventArgs e)
        {
            _onAction(sender, FileActionType.Edit);
        }
        private void deleteButton_Click(object sender, EventArgs e)
        {
            _onAction(sender, FileActionType.Delete);
        }

        private void uploadButton_Click(object sender, EventArgs e)
        {
            _onAction(sender, FileActionType.Upload);
        }
        private void stopButton_Click(object sender, EventArgs e)
        {
            _onAction(sender, FileActionType.UploadStop);
        }

        private void addDemoMenuItem_Click(object sender, EventArgs e)
        {
            _onAction(this, FileActionType.AddDemo);
        }

        private void addDerivativeMenuItem_Click(object sender, EventArgs e)
        {
            _onAction(this, FileActionType.AddDerivative);
        }

        private void progressBar_MouseEnter(object sender, EventArgs e)
        {
            toolTip.ToolTipIcon = ToolTipIcon.Info;
            toolTip.SetToolTip(progressBar, _progressText);
        }

        private void progressBar_MouseLeave(object sender, EventArgs e)
        {
            toolTip.Hide(progressBar);
        }

        private string bytesToMbString(long bytes, bool withMbText = true)
        {
            decimal sizeMb = 1m * bytes / 1024 / 1024;
            return sizeMb.ToString(sizeMb > 10 ? "0" : "0.##") + (withMbText ? " MB" : "");
        }

        private void statusLabel_MouseEnter(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(_errorText))
            {
                toolTip.ToolTipIcon = ToolTipIcon.Error;
                toolTip.SetToolTip(statusLabel, _errorText);
            }
        }

        private void statusLabel_MouseLeave(object sender, EventArgs e)
        {
            toolTip.Hide(statusLabel);
        }

        private void statusLabel_Click(object sender, EventArgs e)
        {
            Clipboard.SetText($"{statusLabel.Text}{Environment.NewLine}{_errorText}");
        }

        private Color GetFileKindColor(FileKind? fileKind)
        {
            return
                //fileKind == FileKind.Master ? Color.FromArgb(134, 245, 239) :
                fileKind == FileKind.Master ? Color.FromArgb(234, 245, 239) :
                fileKind == FileKind.Derivative ? Color.FromArgb(250, 241, 228) :
                fileKind == FileKind.Demo ? Color.FromArgb(249, 231, 231) :
                Color.FromKnownColor(KnownColor.ButtonFace);
        }

        private void FileForm_Resize(object sender, EventArgs e)
        {
            FileNameTextBox.SelectionStart = 0;
            FileNameTextBox.SelectionStart = FileNameTextBox.Text.Length;
            FileNameTextBox.SelectionLength = 0;
        }
    }
}
