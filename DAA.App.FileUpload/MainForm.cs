using DAA.App.FileUpload.Service;
using DAA.Models.FileUploadApp;
using System.Reflection;

namespace DAA.App.FileUpload
{
    public partial class MainForm : Form
    {
        private readonly Dictionary<int, QueueItemModel> queue = new();
        private readonly Dictionary<int, FileForm> formItems = new();
        private readonly FileEditForm _fileEditForm;
        private bool startAllPending = false;
        private bool startAllRunning = false;
        private bool stopAllSignalled = false;

        public MainForm()
        {
            InitializeComponent();
            _fileEditForm = new FileEditForm(imageList);
        }
        private async void MainForm_Load(object sender, EventArgs e)
        {
            this.Text += " - " + CurrentVersion + (Settings.WebServiceBaseAddress.Contains("sea-internal") ? "" : " - " + Settings.WebServiceBaseAddress);

            if (!await WebApiClientService.Authenticate())
            {
                MessageBox.Show("Не сте активен потребител на СЕА и нямате достъп до това приложение.", "DAA.Local", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                Close();
            }
            else if (!Settings.CanQueueFund && !Settings.CanQueueKmf && !Settings.CanQueueEd && !Settings.CanQueueRaw)
            {
                MessageBox.Show("Нямате права да качвате файлове в нито един от процесите.", "DAA.Local", MessageBoxButtons.OK, MessageBoxIcon.Stop);
                Close();
            }

            await LoadQueue();
            await _fileEditForm.InitProcesses();

            toolTip.SetToolTip(deleteFinishedButton, "Изтриване от списъка на качените");
            toolTip.SetToolTip(reloadQueueButton, "Презареждане на списъка");

            loadingPanel.Hide();
        }

        public string? CurrentVersion
        {
            get
            {
                try
                {
                    Assembly assembly = Assembly.GetExecutingAssembly();

                    return assembly.FullName?.Split(",")[1].Replace("Version=", "").Trim();

                    // след publish, assembly.Location е празно??
                    //FileVersionInfo fileVersionInfo = FileVersionInfo.GetVersionInfo(assembly.Location);
                    //return fileVersionInfo?.ProductVersion;
                }
                catch
                {
                    return "???";
                }
            }
        }

        private async void newButton_Click(object sender, EventArgs e)
        {
            await New();
        }

        private async Task LoadQueue()
        {
            QueueItemModel[] items = await WebApiClientService.ListQueue(GetComputerName());
            SetQueueSortOrder(items);
            filePanel.Hide();

            foreach(FileForm form in formItems.Values)
            {
                form.Hide();
                form.Dispose();
            }
            formItems.Clear();
            queue.Clear();

            QueueItemModel[] sortedItems = SortedItems(items);
            foreach (QueueItemModel item in sortedItems)
            {
                queue.Add(item.Id, item);
                AddFileForm(item);
            }
            ReorderForms();
            filePanel.Show();
        }

        private void SetQueueSortOrder(QueueItemModel[] items)
        {
            foreach (QueueItemModel item in items)
            {
                SetQueueItemSortOrder(items, item);
            }
        }


        private void SetQueueItemSortOrder(IEnumerable<QueueItemModel> items, QueueItemModel item)
        {
            if (item.FileKind == FileKind.Derivative || item.FileKind == FileKind.Demo)
            {
                int? masterId = items.Where(i => i.FileKind == FileKind.Master
                    && (i.CreatedGuid == item.MasterDocumentId || i.FinishedGuid == item.MasterDocumentId)).Select(i => (int?)i.Id).SingleOrDefault();

                if (masterId.HasValue)
                {
                    item.Sort1 = masterId.Value;
                    item.Sort2 = item.Id;
                }
                else
                {
                    item.Sort1 = item.Id;
                    item.Sort2 = 0;
                }
            }
            else
            {
                item.Sort1 = item.Id;
                item.Sort2 = 0;
            }
        }

        private QueueItemModel[] SortedItems(IEnumerable<QueueItemModel>? items)
        {
            items ??= queue.Values;
            return items.OrderBy(i => i.Sort1).ThenBy(i => i.Sort2).ToArray();
        }

        private FileForm AddFileForm(QueueItemModel item)
        {
            FileForm form = new FileForm(imageList, OnFileAction);
            form.TopLevel = false;
            form.Parent = filePanel;
            form.Visible = true;
            form.Width = filePanel.ClientSize.Width;
            form.Left = 0;
            form.Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right;

            // опити за сортиране на формите в родителския filePanel
            //filePanel.Controls.SetChildIndex(form, filePanel.Controls.Count);
            // най-предната форма е най-отдолу в DockStyle.Top
            //form.BringToFront();
            //form.Dock = DockStyle.Top;
            form.LoadFromModel(item);
            form.Show();
            formItems[item.Id] = form;
            return form;
        }
        private void ReorderForms()
        {
            filePanel.Hide();
            // подрежда не с DockStyle.Top и BringToFront()
            //foreach (QueueItemModel item in SortedItems(null))
            //{
            //    FileForm fileForm = formItems[item.Id];
            //    fileForm.BringToFront();
            //}
            QueueItemModel[] items = SortedItems(null);
            for(int i = 0; i < items.Length; i++)
            {
                QueueItemModel item = items[i];
                FileForm fileForm = formItems[item.Id];
                fileForm.Top = i * fileForm.Height;

                bool hasMasterInList = item.Sort2 != 0;
                fileForm.Left = hasMasterInList ? 20 : 0;
                fileForm.Width = filePanel.ClientSize.Width - (hasMasterInList ? 20 : 0);
            }

            filePanel.Show();
        }


        private FileForm GetSenderForm(object? sender)
        {
            _ = sender ?? throw new ArgumentNullException(nameof(sender));
            if (sender is Control)
            {
                return (FileForm)((Control)sender).FindForm();
            }
            else
            {
                throw new Exception($"GetSenderForm: Unsupported invoker - sender: {sender}.");
            }
        }

        private string GetComputerName()
        {
            return System.Environment.MachineName;
        }
        private async void OnFileAction(object? sender, FileActionType e)
        {
            if (startAllRunning)
            {
                return;
            }

            FileForm fileForm = GetSenderForm(sender);
            int queueItemId = fileForm.QueueItemId;
            QueueItemModel model = queue[queueItemId];

            if (e == FileActionType.Edit)
            {
                await Edit(model, fileForm);
            }
            else if (e == FileActionType.Delete)
            {
                await Delete(model, fileForm);
            }
            else if (e == FileActionType.Upload)
            {
                await UploadFile(model);
            }
            else if (e == FileActionType.UploadStop)
            {
                model.JobStatus = JobStatus.StopSignalled;
                fileForm.LoadFromModel(model);
            }
            else if (e == FileActionType.AddDerivative)
            {
                await New(model, FileKind.Derivative);
            }
            else if (e == FileActionType.AddDemo)
            {
                await New(model, FileKind.Demo);
            }
        }

        private async Task New()
        {
            _fileEditForm.New();
            await NewHelp();
        }

        private async Task New(QueueItemModel srcModel, FileKind fileKind)
        {
            QueueItemModel templateModel = srcModel.Clone();

            templateModel.FileKind = fileKind;
            templateModel.DbFileName = null;
            templateModel.LocalFileName = "";
            templateModel.Notes = null;
            templateModel.MasterDocumentId = templateModel.FinishedGuid ?? srcModel.CreatedGuid;

            await _fileEditForm.NewForMaster(templateModel);

            await NewHelp();
        }

        private async Task NewHelp()
        {
            if (_fileEditForm.ShowDialog() == DialogResult.OK)
            {
                // при нов документ е разрешено прикачването на няколко файла наведнъж
                string[] fileNames = _fileEditForm.FileNames;

                foreach (string fileName in fileNames)
                {
                    QueueItemModel newItem = new()
                    {
                        CreatedGuid = Guid.NewGuid(),
                        ComputerName = GetComputerName(),
                    };

                    await _fileEditForm.SaveToModel(fileName, newItem);
                    AddToQueueResultModel addResult = await WebApiClientService.AddToQueue(newItem);
                    if (addResult?.Success == true)
                    {
                        newItem.Id = addResult.Id;
                        newItem.DbFileName = addResult.DbFileName;
                        queue.Add(newItem.Id, newItem);
                        SetQueueItemSortOrder(queue.Values, newItem);
                        AddFileForm(newItem);
                        ReorderForms();
                    }
                }
            }
        }
        private async Task Edit(QueueItemModel model, FileForm fileForm)
        {
            await _fileEditForm.LoadFromModel(model);
            if (_fileEditForm.ShowDialog() == DialogResult.OK)
            {
                QueueItemModel editedModel = model.Clone();
                await _fileEditForm.SaveToModel(_fileEditForm.FileNames[0], editedModel);
                AddToQueueResultModel updateResult = await WebApiClientService.UpdateQueue(editedModel);

                // възможно е клиентът да е сменил файла - да е с ново разширение - което трябва да доведе до прегенериране на DbFileName на сървъра
                // разширението на DbFileName се ползва за валидацията на сървъра, затова е важно да е вярно.
                editedModel.DbFileName = updateResult.DbFileName;
                if (updateResult?.Success == true)
                {
                    fileForm.LoadFromModel(editedModel);
                    queue[model.Id] = editedModel;
                    SetQueueItemSortOrder(queue.Values, editedModel);
                    ReorderForms();
                }
            }
        }

        private async Task Delete(QueueItemModel model, FileForm fileForm)
        {
            string message =
                (!model.Finished) && (model.Position > 0) ? "Внимание, файлът е вече частично качен. Потвърдете изтриването!" :
                "Изтриване на файла от опашката.";
            MessageBoxIcon icon = model.Position > 0 ? MessageBoxIcon.Warning : MessageBoxIcon.Exclamation;


            if (MessageBox.Show(message, "Изтриване", MessageBoxButtons.OKCancel, icon, MessageBoxDefaultButton.Button2) == DialogResult.OK)
            {
                OperationResultModel deleteResult = await WebApiClientService.DeleteFromQueue(model.Id);
                if (deleteResult?.Success == true)
                {
                    fileForm.Hide();
                    fileForm.Dispose();
                    queue.Remove(model.Id);
                    formItems.Remove(model.Id);
                    ReorderForms();
                }
            }
        }

        private async Task DeleteFinished()
        {
            string message = "Внимание! Изтриване от списъка на всички успешно качени файлове?";

            if (MessageBox.Show(message, "Изтриване от списъка", MessageBoxButtons.OKCancel, MessageBoxIcon.Warning, MessageBoxDefaultButton.Button2) == DialogResult.OK)
            {
                int[] finishedNonMasters = queue.Where(i => i.Value.Finished && i.Value.FileKind != FileKind.Master).Select(i => i.Key).ToArray();
                Guid[] nonFinishedDetailMasters = queue.Where(i => !i.Value.Finished
                    // това условие май е излишно
                    && (i.Value.FileKind == FileKind.Derivative || i.Value.FileKind == FileKind.Demo)
                    && i.Value.MasterDocumentId != null
                    ).Select(i => i.Value.MasterDocumentId!.Value).ToArray();

                int[] finishedMastersWoNotFinishedDetails = queue
                    .Where(i => i.Value.Finished && i.Value.FileKind == FileKind.Master && !nonFinishedDetailMasters.Contains(i.Value.CreatedGuid))
                    .Select(i => i.Key)
                    .ToArray();

                int[] idsToDelete = finishedNonMasters.Concat(finishedMastersWoNotFinishedDetails).ToArray();

                List<OperationResultModel> deleteResults = new();

                foreach(int id in idsToDelete)
                {
                    OperationResultModel deleteResult = await WebApiClientService.DeleteFromQueue(id);
                    deleteResults.Add(deleteResult);

                    if (deleteResult?.Success == true)
                    {
                        FileForm fileForm = formItems[id];
                        fileForm.Hide();
                        fileForm.Dispose();
                        queue.Remove(id);
                        formItems.Remove(id);
                    }
                }

                ReorderForms();

                OperationResultModel[] errorResults = deleteResults.Where(r => !r.Success).ToArray();
                if (errorResults.Any())
                {
                    MessageBox.Show($"Общ брой за изтриване: {idsToDelete.Length}, грешки: {errorResults.Length}{Environment.NewLine}" +
                        string.Join(Environment.NewLine, errorResults.Select(r => r.Message)));
                }
            }
        }

        private async Task UploadFile(QueueItemModel model)
        {
            //QueueItemModel model = queue[queueItemId];
            model.JobStatus = JobStatus.Running;
            FileForm fileForm = formItems[model.Id];
            fileForm.LoadFromModel(model);
            try
            {


                string dbFileName = model.DbFileName ?? throw new ArgumentNullException($"Не е получен DbFileName за queueItemId {model.Id}.");
                await WebApiClientService.UploadFile(model.Id, model.LocalFileName, dbFileName, model.Position, OnUploadProgress);

                if (model.Position == model.Size)
                {
                    QueueItemResultModel result = await WebApiClientService.ValidateAndFinish(model.Id);
                    if (result.Success)
                    {
                        model.ErrorMessage = result.QueueItemModel.ErrorMessage;
                        model.ChecksumCheckResult = result.QueueItemModel.ChecksumCheckResult;
                        model.AntivirusCheckResult = result.QueueItemModel.AntivirusCheckResult;
                        model.FileFormatCheckResult = result.QueueItemModel.FileFormatCheckResult;
                        model.AntivirusCheckInfo = result.QueueItemModel.AntivirusCheckInfo;
                        model.FileInfo = result.QueueItemModel.FileInfo;
                        model.FinishedGuid = result.QueueItemModel.FinishedGuid;
                        model.Finished = result.QueueItemModel.Finished;
                    }
                    else
                    {
                        model.ErrorMessage = result.Message;
                    }
                }
            }
            catch (Exception e)
            {
                model.ErrorMessage = e.Message;
            }

            model.JobStatus = JobStatus.Idle;
            fileForm.LoadFromModel(model);
        }

        private async Task<bool> OnUploadProgress(UploadProgressModel progressModel)
        {
            int queueItemId = progressModel.Id;
            QueueItemModel model = queue[queueItemId];
            FileForm fileForm = formItems[queueItemId];

            if (model.Position != progressModel.Position)
            {
                QueueItemModel updateModel = model.Clone();
                updateModel.Position = progressModel.Position;

                if ((await WebApiClientService.UpdateQueue(updateModel)).Success)
                {
                    model.Position = updateModel.Position;
                    fileForm.LoadFromModel(model);
                }
            }

            // очаква се статусът да е Running
            // ако е натиснат бутон за стоп, функцията за качване на файл ще спре при следващата итерация (100МБ)
            return !(stopAllSignalled || model.JobStatus == JobStatus.StopSignalled);
        }

        #region ProcessAll in queue
        private void startAllButton_Click(object sender, EventArgs e)
        {
            stopAllSignalled = false;
            startAllPending = true;
        }

        private void stopAllButton_Click(object sender, EventArgs e)
        {
            stopAllSignalled = true;
            startAllPending = false;
        }

        private async Task StartAllHelp()
        {
            startAllRunning = true;
            QueueItemModel[] queueItems = queue.Values.Where(q => !q.Finished && string.IsNullOrEmpty(q.ErrorMessage)).OrderBy(q => q.Id).ToArray();
            foreach (QueueItemModel item in queueItems)
            {
                if (isInWorkingHours() && !stopAllSignalled)
                {
                    await UploadFile(item);
                }
            }
            stopAllSignalled = false;
            startAllRunning = false;
        }

        private bool isInWorkingHours()
        {
            TimeSpan now = DateTime.Now.TimeOfDay;
            return timeStartDateTimePicker.Value.TimeOfDay <= now && now <= timeEndDateTimePicker.Value.TimeOfDay;
        }

        private async void timer_Tick(object sender, EventArgs e)
        {
            ((System.Windows.Forms.Timer)sender).Enabled = false;
            if (isInWorkingHours() && startAllPending && !startAllRunning)
            {
                await StartAllHelp();
            }
            ((System.Windows.Forms.Timer)sender).Enabled = true;
        }
        #endregion

        private async void reloadQueueButton_Click(object sender, EventArgs e)
        {
            await LoadQueue();
        }
        private async void deleteFinishedButton_Click(object sender, EventArgs e)
        {
            await DeleteFinished();
        }
    }
}