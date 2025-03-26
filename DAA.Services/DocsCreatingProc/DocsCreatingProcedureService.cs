using DAA.Data;
using DAA.Extensions.Exceptions;
using DAA.Models.DigitalObjects;
using DAA.Models.Documents;
using DAA.Models.Documents.DocumentsProcedure;
using DAA.Models.Processes;
using DAA.Models.Tasks;
using DAA.Services.DigitalObjects;
using DAA.Services.Documents;
using DAA.Services.Process;
using DAA.Services.Tasks;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;

namespace DAA.Services.DocsCreatingProc
{
    public class DocsCreatingProcedureService : BaseService, IDocsCreatingProcedureService
    {

        private readonly IProcessService _processService;
        private readonly IUserInfo _userInfo;
        private readonly ITaskService _taskService;
        private readonly IDocumentService _documentService;
        private readonly IDigitalObjectService _digitalObjectService;

        public DocsCreatingProcedureService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IProcessService processService,
            IUserInfo userInfo,
            ITaskService taskService,
            IDigitalObjectService digitalObjectService,
            IDocumentService documentService
            ) : base(context, localizer)
        {
            _processService = processService;
            _userInfo = userInfo;
            _taskService = taskService;
            _documentService = documentService;
            _digitalObjectService = digitalObjectService;
        }
        public async Task<OperationResult> Start(DocumentProcedureCreateModel model)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                var result = await _processService.StartProcessAsync(new Models.Processes.ProcessModel
                {
                    DocumentSystemIdentifier = new Guid(model.DocumentSys),
                    Completed = false,
                    ArchiveId = model.ArchiveId,
                    ProcessTypeId = model.ProcedureType!.Value
                });

                if (result.Data != null)
                {
                    if (model.ProcedureType == (int)Shared.ProcessType.AddDocument)
                    {
                        ProcessStepModel step = new()
                        {
                            AssignedToUserId = _userInfo.CurrentUserId,
                            ProcessId = (int)result.Data,
                            StepTypeId = (int)Shared.ProcessStepType.Document_InitiatingAProcess,
                        };

                        await _processService.SetActiveProcessStepAsync(step);

                    }

                    else if (model.ProcedureType == (int)Shared.ProcessType.PreparationOfADigitalObject)
                    {
                        ProcessStepModel step = new()
                        {
                            AssignedToUserId = _userInfo.CurrentUserId,
                            ProcessId = (int)result.Data,
                            StepTypeId = (int)Shared.ProcessStepType.Documentt_InitiatingAProcess,
                        };
                        await _processService.SetActiveProcessStepAsync(step);
                    }

                    else if (model.ProcedureType == (int)Shared.ProcessType.ImportDigitalObject)
                    {
                        //FIX: Защо няма проверка за null?
                        //var doc = _context.Documents.Where(d => d.SystemIdentifier == new Guid(model.DocumentSys)).FirstOrDefault();
                        var doc = await _documentService.GetDocumentBySystemIdentifierAsync(Guid.Parse(model.DocumentSys));

                        //var documentDraft = new DocumentDraftModel()
                        //{
                        //    IsCurrent = true,
                        //    ReadOnly = false,
                        //    SystemIdentifier = doc.SystemIdentifier,
                        //    ArchiveId = doc.ArchiveId,
                        //    FundSystemIdentifier = doc.FundSystemIdentifier,
                        //    InventorySystemIdentifier = doc.InventorySystemIdentifier,
                        //    ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                        //    DescriptionLevelCode = doc.DescriptionLevelCode,
                        //    StatusCode = doc.StatusCode,
                        //    Number = doc.Number,
                        //    Title = doc.Title,
                        //    DigitalDevice = doc.DigitalDevice,
                        //    Duration = doc.Duration,
                        //    StartSheetNumber = doc.StartSheetNumber,
                        //    EndSheetNumber = doc.EndSheetNumber,
                        //    HasNoChronologicalScope = doc.HasNoChronologicalScope,
                        //    Transcription = doc.Transcription,
                        //    Location = doc.Location,
                        //    Bytes = doc.Bytes,
                        //    SheetCount = doc.SheetCount,
                        //    OtherMetrics = doc.OtherMetrics,
                        //    SizeCm = doc.SizeCm,
                        //    Scaling = doc.Scaling,
                        //    Description = doc.Description,
                        //    DocumentsAccessDescription = doc.DocumentsAccessDescription,
                        //    Features = doc.Features,
                        //    MicrofilmedCopyCount = doc.MicrofilmedCopyCount,
                        //    DigitizedCopyCount = doc.DigitizedCopyCount,
                        //    PaperCopyCount = doc.PaperCopyCount,
                        //    NegativeFrameCount = doc.NegativeFrameCount,
                        //    PositiveFrameCount = doc.PositiveFrameCount,
                        //    OtherCopyCount = doc.OtherCopyCount,
                        //    Notes = doc.Notes,
                        //    StartDateYear = doc.StartDateYear,
                        //    StartDateMonth = doc.StartDateMonth,
                        //    StartDateDay = doc.StartDateDay,
                        //    EndDateYear = doc.EndDateYear,
                        //    EndDateMonth = doc.EndDateMonth,
                        //    EndDateDay = doc.EndDateDay,
                        //    HasExternalSource = doc.HasExternalSource,
                        //    ExternalIdentifier = doc.ExternalIdentifier,
                        //};
                        var documentDraft = new DocumentDraftModel();
                        documentDraft.Assign(doc);
                        documentDraft.IsCurrent = true;
                        documentDraft.ReadOnly = false;

                        var ress = await _documentService.CreateDraftInternalAsync(documentDraft);

                        if (!result.Succeeded)
                        {
                            return OperationResult.Failed(result.Errors.First());
                        }
                        ProcessStepModel step = new()
                        {
                            ProcessId = (int)result.Data,
                            StepTypeId = (int)Shared.ProcessStepType.Documentt_PreparationOfADigitalObject,
                        };

                        if (!String.IsNullOrEmpty(model.AssignToUserId))
                        {
                            step.AssignedToUserId = new Guid(model.AssignToUserId);
                        }
                        else if (!String.IsNullOrEmpty(model.AssignToRoleId))
                        {
                            step.AssignedToRoleId = new Guid(model.AssignToRoleId!);
                        }

                        var newStep = await _processService.SetActiveProcessStepAsync(step);


                        TaskCreateModel taskModel = new()
                        {
                            StepType = ProcessStepType.Document_PreparationOfADigitalObject,
                            ProcessId = (int)result.Data,
                            TimelineId = (int)newStep.Data,
                            EntitySystemIdentifier = new Guid(model.DocumentSys),
                            AssignedToUserId = model.AssignToUserId,
                            AssignedToRoleId = model.AssignToRoleId,
                            EntityType = EntityType.document
                        };

                        await _taskService.CreateAsync(taskModel);

                        await _context.SaveAsync("");
                    }

                    await transaction.CommitAsync();

                    return OperationResult.Succeed(result);
                }
                else
                {
                    await transaction.CommitAsync();
                    return OperationResult.Failed(result.Errors.First());
                }


            }
            catch (Exception exc)
            {
                await transaction.RollbackAsync();
                return OperationResult.Failed(exc.ToString());
            }
        }
        public async Task<DocumentProdecureViewModel> Get(string procId)
        {
            var documentGuidId = Guid.Parse(procId);

            var result = await _context.Processes
                .Where(x => x.DocumentSystemIdentifier == documentGuidId && !x.Completed)
                .Include(x => x.ProcessType)
                .Include(x => x.ProcessTimelines.Where(t => !t.Completed))
                 .Select(x => new DocumentProdecureViewModel
                 {
                     Id = x.Id,
                     Completed = x.Completed,
                     DocumentSystemIdentifier = x.DocumentSystemIdentifier.ToString(),
                     ProcedureStepId = x.ProcessTimelines.Where(x => !x.Completed).Select(x => x.Id).FirstOrDefault(),
                     ProcedureStepTypeId = x.ProcessTimelines.Where(x => !x.Completed).Select(x => x.StepTypeId).FirstOrDefault(),
                     ProcedureType = x.ProcessType.Id,
                     ArchiveId = x.ArchiveId
                 }).FirstOrDefaultAsync();

            result!.ProcedureStepName = _context.ProcessSteps.Where(x => x.Id == result.ProcedureStepTypeId).Select(x => x.Text).FirstOrDefault();
            result!.DocumentId = _context.DocumentDrafts.Where(d => d.SystemIdentifier == documentGuidId).Select(d => d.Id).FirstOrDefault();
            result.AssignedToUserId = _context.ProcessTimelines
                .Where(x => x.ProcessId == result.Id && !x.Completed)
                .Select(x => x.AssignedToUserId)
                .FirstOrDefault()
                .ToString();
            result.AssignedToRoleId = _context.ProcessTimelines
              .Where(x => x.ProcessId == result.Id && !x.Completed)
              .Select(x => x.AssignedToRoleId)
              .FirstOrDefault()
              .ToString();

            return result;
        }
        public async Task<OperationResult> UpdateStep(DocumentProcedureUpdateModel model)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                bool hasFileWithSameName = false;

                var documentSystemIdentifier = Guid.Parse(model.DocumentSystemIdentifier!);

                var currentProcess = await _context.Processes
                         .Where(x => x.DocumentSystemIdentifier == documentSystemIdentifier && !x.Completed && !x.Deleted)
                         .Include(x => x.ProcessTimelines.Where(t => !t.Completed))
                         .FirstOrDefaultAsync();

                var hasDigitalObjectList = await _context.DigitalObjectDrafts
                                            .Where(d => !d.Deleted && d.DocumentSystemIdentifier == documentSystemIdentifier)
                                            .AnyAsync();

                var currentStep = currentProcess?.ProcessTimelines.FirstOrDefault();

                if (currentProcess == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }
                if (currentStep == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }
                if ((currentStep.AssignedToUserId != null) && (currentStep.AssignedToUserId != _userInfo.CurrentUserId))
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_NotAssignedStep").ToString());
                    //return OperationResult.Failed("Access denied");
                }


                var tasks = _context.Tasks
                .Where(x => x.ProcessId == model.Id && x.StatusCode == Shared.TaskStatus.Pending)
                .AsQueryable();
                if (tasks != null && tasks.Count() > 0)
                {
                    OperationResult taskResult = OperationResult.Success;
                    foreach (var task in tasks)
                    {
                        taskResult = await _taskService.ChangeTaskStatus(task.Id, Shared.TaskStatus.Completed);
                        if (!taskResult.Succeeded)
                        {
                            return taskResult;
                        }
                    }
                }

                if (model.ProcedureStepTypeId == (int)ProcessStepType.Document_InitiatingAProcess)
                {
                    TaskCreateModel taskModel = new()
                    {
                        StepType = ProcessStepType.Document_InitiatingAProcess,
                        ProcessId = currentProcess!.Id,
                        TimelineId = currentStep.Id,
                        EntitySystemIdentifier = new Guid(model.DocumentSystemIdentifier),
                        AssignedToUserId = model.AssignToUserId,
                        AssignedToRoleId = model.AssignToRoleId,
                        EntityType = EntityType.document
                    };

                    await _taskService.CreateAsync(taskModel);

                    await _context.SaveChangesAsync();

                    ProcessStepModel processStep = new()
                    {
                        ProcessId = currentProcess!.Id,
                        StepTypeId = (int)ProcessStepType.Document_ViewMetadataAndSelectAScanning,
                    };

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }
                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);
                }
                else if (model.ProcedureStepTypeId == (int)ProcessStepType.Document_ViewMetadataAndSelectAScanning)
                {
                    ProcessStepModel processStep = new()
                    {
                        ProcessId = currentProcess!.Id,
                        StepTypeId = (int)ProcessStepType.Document_ProcessFinalization,
                    };

                    await _processService.SetActiveProcessStepAsync(processStep);

                    await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(currentProcess.DocumentSystemIdentifier!.Value);

                    await _processService.CompleteProcessAsync(currentProcess.Id);

                    if ((model.AssignToUserId != null && model.AssignToUserId != "")
                     || (model.AssignToRoleId != null && model.AssignToRoleId != ""))
                    {
                        //FIX: Защо няма проверки за null?
                        //var doc = _context.Documents.Where(d => d.SystemIdentifier == new Guid(model.DocumentSystemIdentifier)).FirstOrDefault();
                        var doc = await _documentService.GetDocumentBySystemIdentifierAsync(Guid.Parse(model.DocumentSystemIdentifier));

                        //var newDraft = new DocumentDraftModel()
                        //{
                        //    IsCurrent = true,
                        //    ReadOnly = false,
                        //    SystemIdentifier = doc.SystemIdentifier,
                        //    ArchiveId = doc.ArchiveId,
                        //    FundSystemIdentifier = doc.FundSystemIdentifier,
                        //    InventorySystemIdentifier = doc.InventorySystemIdentifier,
                        //    ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                        //    DescriptionLevelCode = doc.DescriptionLevelCode,
                        //    StatusCode = doc.StatusCode,
                        //    Number = doc.Number,
                        //    Title = doc.Title,
                        //    DigitalDevice = doc.DigitalDevice,
                        //    Duration = doc.Duration,
                        //    StartSheetNumber = doc.StartSheetNumber,
                        //    EndSheetNumber = doc.EndSheetNumber,
                        //    HasNoChronologicalScope = doc.HasNoChronologicalScope,
                        //    Transcription = doc.Transcription,
                        //    Location = doc.Location,
                        //    Bytes = doc.Bytes,
                        //    SheetCount = doc.SheetCount,
                        //    OtherMetrics = doc.OtherMetrics,
                        //    SizeCm = doc.SizeCm,
                        //    Scaling = doc.Scaling,
                        //    Description = doc.Description,
                        //    DocumentsAccessDescription = doc.DocumentsAccessDescription,
                        //    Features = doc.Features,
                        //    MicrofilmedCopyCount = doc.MicrofilmedCopyCount,
                        //    DigitizedCopyCount = doc.DigitizedCopyCount,
                        //    PaperCopyCount = doc.PaperCopyCount,
                        //    NegativeFrameCount = doc.NegativeFrameCount,
                        //    PositiveFrameCount = doc.PositiveFrameCount,
                        //    OtherCopyCount = doc.OtherCopyCount,
                        //    Notes = doc.Notes,
                        //    StartDateYear = doc.StartDateYear,
                        //    StartDateMonth = doc.StartDateMonth,
                        //    StartDateDay = doc.StartDateDay,
                        //    EndDateYear = doc.EndDateYear,
                        //    EndDateMonth = doc.EndDateMonth,
                        //    EndDateDay = doc.EndDateDay,
                        //    HasExternalSource = doc.HasExternalSource,
                        //    ExternalIdentifier = doc.ExternalIdentifier,
                        //};
                        var newDraft = new DocumentDraftModel();
                        newDraft.Assign(doc);
                        newDraft.IsCurrent = true;
                        newDraft.ReadOnly = false;

                        await _documentService.CreateDraftInternalAsync(newDraft);

                        var result = await _processService.StartProcessAsync(new Models.Processes.ProcessModel
                        {
                            DocumentSystemIdentifier = new Guid(model.DocumentSystemIdentifier),
                            Completed = false,
                            ProcessTypeId = (int)Shared.ProcessType.ImportDigitalObject,
                            ArchiveId = newDraft.ArchiveId,
                        });

                        if (result.Data == null)
                        {
                            return OperationResult.Failed(result.Errors.First());
                        }
                        else
                        {

                            var newStep = await _processService.SetActiveProcessStepAsync(new ProcessStepModel()
                            {
                                AssignedToUserId = !String.IsNullOrEmpty(model.AssignToUserId) ? new Guid(model.AssignToUserId!) : null,
                                ProcessId = (int)result.Data,
                                StepTypeId = (int)Shared.ProcessStepType.Documentt_PreparationOfADigitalObject,
                                AssignedToRoleId = !String.IsNullOrEmpty(model.AssignToRoleId) ? new Guid(model.AssignToRoleId!) : null,

                            });

                            TaskCreateModel taskModel = new()
                            {
                                StepType = ProcessStepType.Documentt_InitiatingAProcess,
                                ProcessId = (int)result.Data,
                                TimelineId = (int)newStep.Data,
                                EntitySystemIdentifier = new Guid(model.DocumentSystemIdentifier),
                                AssignedToUserId = model.AssignToUserId,
                                AssignedToRoleId = model.AssignToRoleId,
                                EntityType = EntityType.document
                            };

                            await _taskService.CreateAsync(taskModel);

                            await _context.SaveChangesAsync();
                        }
                    }
                }
                else if (model.ProcedureStepTypeId == (int)ProcessStepType.Document_ReturnedForEditingMetadata)
                {
                    ProcessStepModel newStep = new()
                    {
                        ProcessId = currentProcess!.Id,
                        StepTypeId = (int)ProcessStepType.Document_ViewMetadataAndSelectAScanning,
                    };
                    if (!string.IsNullOrWhiteSpace(model.AssignToUserId))
                    {
                        newStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }
                    if (!string.IsNullOrWhiteSpace(model.AssignToRoleId))
                    {
                        newStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    await _processService.SetActiveProcessStepAsync(newStep);

                    TaskCreateModel taskModel = new()
                    {
                        StepType = ProcessStepType.Document_ReturnedForEditingMetadata,
                        ProcessId = currentProcess!.Id,
                        TimelineId = currentStep.Id,
                        EntityId = model.DocumentId,
                        EntitySystemIdentifier = new Guid(model.DocumentSystemIdentifier),
                        AssignedToUserId = model.AssignToUserId,
                        AssignedToRoleId = model.AssignToRoleId,
                        EntityType = EntityType.document,
                    };

                    await _taskService.CreateAsync(taskModel);
                    await _context.SaveChangesAsync();
                }
                else if (model.ProcedureStepTypeId == (int)ProcessStepType.Document_PreparationOfADigitalObject)
                {
                    if (model.MasterFiles == null && !hasDigitalObjectList)
                    {
                        return OperationResult.Failed(false, _localizer.GetString("CantGoNextStepWithDigObj").ToString());
                    }

                    Guid gl = new(model.DocumentSystemIdentifier!);

                    string masterFileId = string.Empty;

                    var doc = await _documentService.GetCurrentDraftAsync(new Guid(model.DocumentSystemIdentifier!));

                    if (model.MasterFiles != null && model.MasterFiles.Length > 0)
                    {
                        foreach (var file in model.MasterFiles)
                        {
                            DigitalObjectDraftModel master = new()
                            {
                                IsCurrent = true,
                                ArchiveId = currentProcess!.ArchiveId,
                                FundDraftId = doc.FundDraftId,
                                FundSystemIdentifier = doc.FundSystemIdentifier,
                                FundExternalIdentifier = doc.FundExternalIdentifier,
                                FundHasExternalSource = doc.FundHasExternalSource,
                                InventoryDraftId = doc.InventoryDraftId,
                                InventorySystemIdentifier = doc.InventorySystemIdentifier,
                                InventoryHasExternalSource = doc.InventoryHasExternalSource,
                                InventoryExternalIdentifier = doc.InventoryExternalIdentifier,
                                ArchivalEntityDraftId = doc.ArchivalEntityDraftId,
                                ArchivalEntityExternalIdentifier = doc.ArchivalEntityExternalIdentifier,
                                ArchivalEntityHasExternalSource = doc.ArchivalEntityHasExternalSource,
                                ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                                DocumentDraftId = doc.Id,
                                DocumentSystemIdentifier = gl,
                                DocumentHasExternalSource = doc.HasExternalSource.Value,
                                DocumentExternalIdentifier = doc.ExternalIdentifier,
                                Name = file.Name,
                                SourceName = file.Name,
                                FileType = file.ContentDisposition,
                                StatusCode = "1",
                                Content = file,
                                IsDigitized= true,
                                TypeCode = (int)DigitalObjectType.MasterFile,
                            };

                            hasFileWithSameName = await HasFileWithTheSameName(file.FileName, new Guid(model.DocumentSystemIdentifier!));

                            if (hasFileWithSameName)
                            {
                                return OperationResult.Failed(false, _localizer.GetString("Error_FileNameExists").ToString() + " " + file.FileName);
                            }

                            var parentSys = await _digitalObjectService.CreateDraftInternalAsync(master);

                            masterFileId = parentSys.ToString();
                        }
                        if (model.DerivativesFiles != null && model.DerivativesFiles.Length > 0)
                        {
                            foreach (var file in model.DerivativesFiles)
                            {
                                DigitalObjectDraftModel derivativesFile = new()
                                {
                                    IsCurrent = true,
                                    ArchiveId = currentProcess!.ArchiveId,
                                    FundDraftId = doc.FundDraftId,
                                    FundSystemIdentifier = doc.FundSystemIdentifier,
                                    FundExternalIdentifier = doc.FundExternalIdentifier,
                                    FundHasExternalSource = doc.FundHasExternalSource,
                                    InventoryDraftId = doc.InventoryDraftId,
                                    InventorySystemIdentifier = doc.InventorySystemIdentifier,
                                    InventoryHasExternalSource = doc.InventoryHasExternalSource,
                                    InventoryExternalIdentifier = doc.InventoryExternalIdentifier,
                                    ArchivalEntityDraftId = doc.ArchivalEntityDraftId,
                                    ArchivalEntityExternalIdentifier = doc.ArchivalEntityExternalIdentifier,
                                    ArchivalEntityHasExternalSource = doc.ArchivalEntityHasExternalSource,
                                    ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                                    DocumentDraftId = doc.Id,
                                    DocumentSystemIdentifier = gl,
                                    DocumentHasExternalSource = doc.HasExternalSource.Value,
                                    DocumentExternalIdentifier = doc.ExternalIdentifier,
                                    Name = file.Name,
                                    SourceName = file.Name,
                                    FileType = file.ContentDisposition,
                                    StatusCode = "1",
                                    Content = file,
                                    ParentSystemIdentifier = new Guid(masterFileId),
                                    TypeCode = (int)DigitalObjectType.DerivativeFile,
                                    IsDigitized = true
                                };

                                hasFileWithSameName = await HasFileWithTheSameName(file.FileName, new Guid(model.DocumentSystemIdentifier!));

                                if (hasFileWithSameName)
                                {
                                    return OperationResult.Failed(false, _localizer.GetString("Error_FileNameExists").ToString() + " " + file.FileName);
                                }

                                await _digitalObjectService.CreateDraftInternalAsync(derivativesFile);
                            }
                        }
                        if (model.Files != null && model.Files.Length > 0)
                        {
                            foreach (var file in model.Files)
                            {
                                DigitalObjectDraftModel demoFile = new()
                                {
                                    IsCurrent = true,
                                    ArchiveId = currentProcess!.ArchiveId,
                                    FundDraftId = doc.FundDraftId,
                                    FundSystemIdentifier = doc.FundSystemIdentifier,
                                    FundExternalIdentifier = doc.FundExternalIdentifier,
                                    FundHasExternalSource = doc.FundHasExternalSource,
                                    InventoryDraftId = doc.InventoryDraftId,
                                    InventorySystemIdentifier = doc.InventorySystemIdentifier,
                                    InventoryHasExternalSource = doc.InventoryHasExternalSource,
                                    InventoryExternalIdentifier = doc.InventoryExternalIdentifier,
                                    ArchivalEntityDraftId = doc.ArchivalEntityDraftId,
                                    ArchivalEntityExternalIdentifier = doc.ArchivalEntityExternalIdentifier,
                                    ArchivalEntityHasExternalSource = doc.ArchivalEntityHasExternalSource,
                                    ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                                    DocumentDraftId = doc.Id,
                                    DocumentSystemIdentifier = gl,
                                    DocumentHasExternalSource = doc.HasExternalSource.Value,
                                    DocumentExternalIdentifier = doc.ExternalIdentifier,
                                    Name = file.Name,
                                    SourceName = file.Name,
                                    FileType = file.ContentDisposition,
                                    StatusCode = "1",
                                    Content = file,
                                    ParentSystemIdentifier = new Guid(masterFileId),
                                    TypeCode = (int)DigitalObjectType.DemoFile,
                                    IsDigitized = true
                                };

                                hasFileWithSameName = await HasFileWithTheSameName(file.FileName, new Guid(model.DocumentSystemIdentifier!));

                                if (hasFileWithSameName)
                                {
                                    return OperationResult.Failed(false, _localizer.GetString("Error_FileNameExists").ToString() + " " + file.FileName);
                                }

                                await _digitalObjectService.CreateDraftInternalAsync(demoFile);
                            }
                        }
                    }
                    ProcessStepModel newStep = new()
                    {
                        ProcessId = currentProcess!.Id,
                        StepTypeId = (int)ProcessStepType.Document_QualityControl,
                    };

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        newStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }
                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        newStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    await _processService.SetActiveProcessStepAsync(newStep);

                    TaskCreateModel taskModel = new()
                    {
                        StepType = ProcessStepType.Document_PreparationOfADigitalObject,
                        ProcessId = currentProcess!.Id,
                        TimelineId = currentStep.Id,
                        EntityId = model.DocumentId,
                        EntitySystemIdentifier = new Guid(model.DocumentSystemIdentifier),
                        AssignedToUserId = model.AssignToUserId,
                        AssignedToRoleId = model.AssignToRoleId,
                        EntityType = EntityType.document
                    };

                    await _taskService.CreateAsync(taskModel);
                    await _context.SaveChangesAsync();
                }
                else if (model.ProcedureStepTypeId == (int)ProcessStepType.Document_QualityControl)
                {
                    ProcessStepModel processStep = new()
                    {
                        ProcessId = currentProcess!.Id,
                        StepTypeId = (int)ProcessStepType.Documentt_ProcessInitiation,
                    };

                    await _processService.SetActiveProcessStepAsync(processStep);

                    var documentDraft = await _documentService.GetCurrentDraftAsync(currentProcess.DocumentSystemIdentifier!.Value);

                    if (documentDraft == null)
                    {
                        return OperationResult.Failed(_localizer.GetString("There is no current draft"));
                    }

                    await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(new Guid(model.DocumentSystemIdentifier!));

                    await _processService.CompleteProcessAsync(currentProcess.Id);

                    var itemsSys = _context.DigitalObjectDrafts
                          .Where(d => d.DocumentSystemIdentifier == new Guid(model.DocumentSystemIdentifier!) && d.IsCurrent && !d.Deleted)
                          .Select(d => d.SystemIdentifier);

                    foreach (var item in itemsSys)
                    {
                        await _digitalObjectService.CreateOrUpdateDigitalObjectFromDraftInternalAsync(item, false);
                    }
                }
                else if (model.ProcedureStepTypeId == (int)ProcessStepType.Documentt_ViewMetadataAndSelectAScanning)
                {
                    ProcessStepModel newStep = new()
                    {
                        ProcessId = currentProcess!.Id,
                        StepTypeId = (int)ProcessStepType.Document_PreparationOfADigitalObject,
                    };

                    if (model.AssignToRoleId != null && model.AssignToRoleId != "")
                    {
                        newStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }
                    if (model.AssignToUserId != null && model.AssignToUserId != "")
                    {
                        newStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    await _processService.SetActiveProcessStepAsync(newStep);

                    TaskCreateModel taskModel = new()
                    {
                        StepType = ProcessStepType.Documentt_ViewMetadataAndSelectAScanning,
                        ProcessId = currentProcess!.Id,
                        TimelineId = currentStep.Id,
                        EntityId = model.DocumentId,
                        EntitySystemIdentifier = new Guid(model.DocumentSystemIdentifier),
                        AssignedToUserId = model.AssignToUserId,
                        AssignedToRoleId = model.AssignToRoleId,
                        EntityType = EntityType.document
                    };

                    await _taskService.CreateAsync(taskModel);
                    await _context.SaveChangesAsync();
                }
                else if (model.ProcedureStepTypeId == (int)ProcessStepType.Documentt_InitiatingAProcess)
                {
                    ProcessStepModel newStep = new()
                    {
                        ProcessId = currentProcess!.Id,
                        StepTypeId = (int)ProcessStepType.Documentt_ViewMetadataAndSelectAScanning,
                    };

                    if (model.AssignToRoleId != null)
                    {
                        newStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }
                    if (model.AssignToUserId != null)
                    {
                        newStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }

                    await _processService.SetActiveProcessStepAsync(newStep);

                    TaskCreateModel taskModel = new()
                    {
                        StepType = ProcessStepType.Documentt_ViewMetadataAndSelectAScanning,
                        ProcessId = currentProcess!.Id,
                        TimelineId = currentStep.Id,
                        EntityId = model.DocumentId,
                        EntitySystemIdentifier = new Guid(model.DocumentSystemIdentifier),
                        AssignedToUserId = model.AssignToUserId,
                        AssignedToRoleId = model.AssignToRoleId,
                        EntityType = EntityType.document
                    };

                    await _taskService.CreateAsync(taskModel);
                    await _context.SaveChangesAsync();
                }
                else if (model.ProcedureStepTypeId == (int)ProcessStepType.Documentt_ReturnedForEditingMetadata)
                {
                    ProcessStepModel processStep = new()
                    {
                        ProcessId = currentProcess!.Id,
                        StepTypeId = (int)Shared.ProcessStepType.Documentt_ViewMetadataAndSelectAScanning,
                    };
                    if (model.AssignToUserId != null)
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }
                    if (model.AssignToRoleId != null)
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);

                    TaskCreateModel taskModel = new()
                    {
                        StepType = Shared.ProcessStepType.Document_ReturnedForEditingMetadata,
                        ProcessId = currentProcess!.Id,
                        TimelineId = currentStep.Id,
                        EntityId = model.DocumentId,
                        EntitySystemIdentifier = new Guid(model.DocumentSystemIdentifier),
                        AssignedToUserId = model.AssignToUserId,
                        AssignedToRoleId = model.AssignToRoleId,
                        EntityType = EntityType.document
                    };

                    await _taskService.CreateAsync(taskModel);
                    await _context.SaveChangesAsync();
                }
                else if (model.ProcedureStepTypeId == (int)ProcessStepType.Document_ReturnedForEditingDigitalData)
                {
                    if (model.MasterFiles == null && !hasDigitalObjectList)
                    {
                        return OperationResult.Failed(false, _localizer.GetString("CantGoNextStepWithDigObj").ToString());
                    }

                    Guid gl = new(model.DocumentSystemIdentifier!);

                    string masterFileId = string.Empty;

                    var doc = await _documentService.GetCurrentDraftAsync(new Guid(model.DocumentSystemIdentifier!));

                    if (model.MasterFiles != null && model.MasterFiles.Length > 0)
                    {
                        foreach (var file in model.MasterFiles)
                        {
                            DigitalObjectDraftModel master = new()
                            {
                                IsCurrent = true,
                                ArchiveId = currentProcess!.ArchiveId,
                                FundDraftId = doc.FundDraftId,
                                FundSystemIdentifier = doc.FundSystemIdentifier,
                                FundExternalIdentifier = doc.FundExternalIdentifier,
                                FundHasExternalSource = doc.FundHasExternalSource,
                                InventoryDraftId = doc.InventoryDraftId,
                                InventorySystemIdentifier = doc.InventorySystemIdentifier,
                                InventoryHasExternalSource = doc.InventoryHasExternalSource,
                                InventoryExternalIdentifier = doc.InventoryExternalIdentifier,
                                ArchivalEntityDraftId = doc.ArchivalEntityDraftId,
                                ArchivalEntityExternalIdentifier = doc.ArchivalEntityExternalIdentifier,
                                ArchivalEntityHasExternalSource = doc.ArchivalEntityHasExternalSource,
                                ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                                DocumentDraftId = doc.Id,
                                DocumentSystemIdentifier = gl,
                                DocumentHasExternalSource = doc.HasExternalSource.Value,
                                DocumentExternalIdentifier = doc.ExternalIdentifier,
                                Name = file.Name,
                                SourceName = file.Name,
                                FileType = file.ContentDisposition,
                                StatusCode = "1",
                                IsDigitized = true,
                                Content = file,
                                TypeCode = (int)DigitalObjectType.MasterFile,
                            };

                            hasFileWithSameName = await HasFileWithTheSameName(file.FileName, new Guid(model.DocumentSystemIdentifier!));

                            if (hasFileWithSameName)
                            {
                                return OperationResult.Failed(false, _localizer.GetString("Error_FileNameExists").ToString() + " " + file.FileName);
                            }

                            var parentSys = await _digitalObjectService.CreateDraftInternalAsync(master);

                            masterFileId = parentSys.ToString();
                        }
                        if (model.DerivativesFiles != null && model.DerivativesFiles.Length > 0)
                        {
                            foreach (var file in model.DerivativesFiles)
                            {
                                DigitalObjectDraftModel derivativesFile = new()
                                {
                                    IsCurrent = true,
                                    ArchiveId = currentProcess!.ArchiveId,
                                    FundDraftId = doc.FundDraftId,
                                    FundSystemIdentifier = doc.FundSystemIdentifier,
                                    FundExternalIdentifier = doc.FundExternalIdentifier,
                                    FundHasExternalSource = doc.FundHasExternalSource,
                                    InventoryDraftId = doc.InventoryDraftId,
                                    InventorySystemIdentifier = doc.InventorySystemIdentifier,
                                    InventoryHasExternalSource = doc.InventoryHasExternalSource,
                                    InventoryExternalIdentifier = doc.InventoryExternalIdentifier,
                                    ArchivalEntityDraftId = doc.ArchivalEntityDraftId,
                                    ArchivalEntityExternalIdentifier = doc.ArchivalEntityExternalIdentifier,
                                    ArchivalEntityHasExternalSource = doc.ArchivalEntityHasExternalSource,
                                    ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                                    DocumentDraftId = doc.Id,
                                    DocumentSystemIdentifier = gl,
                                    IsDigitized = true,
                                    DocumentHasExternalSource = doc.HasExternalSource.Value,
                                    DocumentExternalIdentifier = doc.ExternalIdentifier,
                                    Name = file.Name,
                                    SourceName = file.Name,
                                    FileType = file.ContentDisposition,
                                    StatusCode = "1",
                                    Content = file,
                                    ParentSystemIdentifier = new Guid(masterFileId),
                                    TypeCode = (int)DigitalObjectType.DerivativeFile,
                                };

                                hasFileWithSameName = await HasFileWithTheSameName(file.FileName, new Guid(model.DocumentSystemIdentifier!));

                                if (hasFileWithSameName)
                                {
                                    return OperationResult.Failed(false, _localizer.GetString("Error_FileNameExists").ToString() + " " + file.FileName);
                                }

                                var result = await _digitalObjectService.CreateDraftInternalAsync(derivativesFile);
                            }
                        }
                        if (model.Files != null && model.Files.Length > 0)
                        {
                            foreach (var file in model.Files)
                            {
                                DigitalObjectDraftModel demoFile = new()
                                {
                                    IsCurrent = true,
                                    ArchiveId = currentProcess!.ArchiveId,
                                    FundDraftId = doc.FundDraftId,
                                    FundSystemIdentifier = doc.FundSystemIdentifier,
                                    FundExternalIdentifier = doc.FundExternalIdentifier,
                                    FundHasExternalSource = doc.FundHasExternalSource,
                                    InventoryDraftId = doc.InventoryDraftId,
                                    InventorySystemIdentifier = doc.InventorySystemIdentifier,
                                    InventoryHasExternalSource = doc.InventoryHasExternalSource,
                                    InventoryExternalIdentifier = doc.InventoryExternalIdentifier,
                                    ArchivalEntityDraftId = doc.ArchivalEntityDraftId,
                                    ArchivalEntityExternalIdentifier = doc.ArchivalEntityExternalIdentifier,
                                    ArchivalEntityHasExternalSource = doc.ArchivalEntityHasExternalSource,
                                    ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                                    DocumentDraftId = doc.Id,
                                    DocumentSystemIdentifier = gl,
                                    DocumentHasExternalSource = doc.HasExternalSource.Value,
                                    DocumentExternalIdentifier = doc.ExternalIdentifier,
                                    Name = file.Name,
                                    IsDigitized = true,
                                    SourceName = file.Name,
                                    FileType = file.ContentDisposition,
                                    StatusCode = "1",
                                    Content = file,
                                    ParentSystemIdentifier = new Guid(masterFileId),
                                    TypeCode = (int)DigitalObjectType.DemoFile,
                                };


                                hasFileWithSameName = await HasFileWithTheSameName(file.FileName, new Guid(model.DocumentSystemIdentifier!));

                                if (hasFileWithSameName)
                                {
                                    return OperationResult.Failed(false, _localizer.GetString("Error_FileNameExists").ToString() + " " + file.FileName);
                                }

                                var result = await _digitalObjectService.CreateDraftInternalAsync(demoFile);
                            }
                        }
                    }

                    ProcessStepModel processStep = new()
                    {
                        ProcessId = currentProcess!.Id,
                        StepTypeId = (int)ProcessStepType.Document_QualityControl,

                    };

                    if (!string.IsNullOrWhiteSpace(model.AssignToUserId))
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }
                    if (!string.IsNullOrWhiteSpace(model.AssignToRoleId))
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);

                    TaskCreateModel taskModel = new()
                    {
                        StepType = ProcessStepType.Document_PreparationOfADigitalObject,
                        ProcessId = currentProcess!.Id,
                        TimelineId = currentStep.Id,
                        EntityId = model.DocumentId,
                        EntitySystemIdentifier = new Guid(model.DocumentSystemIdentifier),
                        AssignedToUserId = model.AssignToUserId,
                        AssignedToRoleId = model.AssignToRoleId,
                        EntityType = EntityType.document
                    };

                    await _taskService.CreateAsync(taskModel);
                    await _context.SaveChangesAsync();
                }
                else if (model.ProcedureStepTypeId == (int)ProcessStepType.Documentt_PreparationOfADigitalObject)
                {
                    if (model.MasterFiles == null && !hasDigitalObjectList)
                    {
                        return OperationResult.Failed(_localizer.GetString("CantGoNextStepWithDigObj").ToString());
                    }

                    Guid gl = new(model.DocumentSystemIdentifier!);

                    string masterFileId = string.Empty;

                    var doc = await _documentService.GetCurrentDraftAsync(new Guid(model.DocumentSystemIdentifier!));

                    if (model.MasterFiles != null && model.MasterFiles.Length > 0)
                    {
                        foreach (var file in model.MasterFiles)
                        {
                            DigitalObjectDraftModel master = new()
                            {
                                IsCurrent = true,

                                ArchiveId = currentProcess!.ArchiveId,
                                FundDraftId = doc.FundDraftId,
                                FundSystemIdentifier = doc.FundSystemIdentifier,
                                FundExternalIdentifier = doc.FundExternalIdentifier,
                                FundHasExternalSource = doc.FundHasExternalSource,
                                InventoryDraftId = doc.InventoryDraftId,
                                InventorySystemIdentifier = doc.InventorySystemIdentifier,
                                InventoryHasExternalSource = doc.InventoryHasExternalSource,
                                InventoryExternalIdentifier = doc.InventoryExternalIdentifier,
                                ArchivalEntityDraftId = doc.ArchivalEntityDraftId,
                                ArchivalEntityExternalIdentifier = doc.ArchivalEntityExternalIdentifier,
                                ArchivalEntityHasExternalSource = doc.ArchivalEntityHasExternalSource,
                                ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                                DocumentDraftId = doc.Id,
                                DocumentSystemIdentifier = gl,
                                DocumentHasExternalSource = doc.HasExternalSource.Value,
                                DocumentExternalIdentifier = doc.ExternalIdentifier,
                                Name = file.Name,
                                SourceName = file.Name,
                                FileType = file.ContentDisposition,
                                StatusCode = "1",
                                IsDigitized = true,
                                Content = file,
                                TypeCode = (int)DigitalObjectType.MasterFile,
                            };


                            hasFileWithSameName = await HasFileWithTheSameName(file.FileName, new Guid(model.DocumentSystemIdentifier!));

                            if (hasFileWithSameName)
                            {
                                return OperationResult.Failed(false, _localizer.GetString("Error_FileNameExists").ToString() + " " + file.FileName);
                            }

                            var parentSys = await _digitalObjectService.CreateDraftInternalAsync(master);

                            masterFileId = parentSys.ToString();
                        }
                        if (model.DerivativesFiles != null && model.DerivativesFiles.Length > 0)
                        {
                            foreach (var file in model.DerivativesFiles)
                            {
                                DigitalObjectDraftModel derivativesFile = new()
                                {
                                    IsCurrent = true,
                                    ArchiveId = currentProcess!.ArchiveId,
                                    FundDraftId = doc.FundDraftId,
                                    FundSystemIdentifier = doc.FundSystemIdentifier,
                                    FundExternalIdentifier = doc.FundExternalIdentifier,
                                    FundHasExternalSource = doc.FundHasExternalSource,
                                    InventoryDraftId = doc.InventoryDraftId,
                                    InventorySystemIdentifier = doc.InventorySystemIdentifier,
                                    InventoryHasExternalSource = doc.InventoryHasExternalSource,
                                    InventoryExternalIdentifier = doc.InventoryExternalIdentifier,
                                    ArchivalEntityDraftId = doc.ArchivalEntityDraftId,
                                    ArchivalEntityExternalIdentifier = doc.ArchivalEntityExternalIdentifier,
                                    ArchivalEntityHasExternalSource = doc.ArchivalEntityHasExternalSource,
                                    ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                                    DocumentDraftId = doc.Id,
                                    DocumentSystemIdentifier = gl,
                                    IsDigitized = true,
                                    DocumentHasExternalSource = doc.HasExternalSource.Value,
                                    DocumentExternalIdentifier = doc.ExternalIdentifier,
                                    Name = file.Name,
                                    SourceName = file.Name,
                                    FileType = file.ContentDisposition,
                                    StatusCode = "1",
                                    Content = file,
                                    ParentSystemIdentifier = new Guid(masterFileId),
                                    TypeCode = (int)DigitalObjectType.DerivativeFile,
                                };


                                hasFileWithSameName = await HasFileWithTheSameName(file.FileName, new Guid(model.DocumentSystemIdentifier!));

                                if (hasFileWithSameName)
                                {
                                    return OperationResult.Failed(false, _localizer.GetString("Error_FileNameExists").ToString() + " " + file.FileName);
                                }

                                await _digitalObjectService.CreateDraftInternalAsync(derivativesFile);
                            }
                        }
                        if (model.Files != null && model.Files.Length > 0)
                        {
                            foreach (var file in model.Files)
                            {
                                DigitalObjectDraftModel demoFile = new()
                                {
                                    IsCurrent = true,
                                    ArchiveId = currentProcess!.ArchiveId,
                                    FundDraftId = doc.FundDraftId,
                                    FundSystemIdentifier = doc.FundSystemIdentifier,
                                    FundExternalIdentifier = doc.FundExternalIdentifier,
                                    FundHasExternalSource = doc.FundHasExternalSource,
                                    InventoryDraftId = doc.InventoryDraftId,
                                    InventorySystemIdentifier = doc.InventorySystemIdentifier,
                                    InventoryHasExternalSource = doc.InventoryHasExternalSource,
                                    InventoryExternalIdentifier = doc.InventoryExternalIdentifier,
                                    ArchivalEntityDraftId = doc.ArchivalEntityDraftId,
                                    ArchivalEntityExternalIdentifier = doc.ArchivalEntityExternalIdentifier,
                                    ArchivalEntityHasExternalSource = doc.ArchivalEntityHasExternalSource,
                                    ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                                    DocumentDraftId = doc.Id,
                                    DocumentSystemIdentifier = gl,
                                    DocumentHasExternalSource = doc.HasExternalSource.Value,
                                    DocumentExternalIdentifier = doc.ExternalIdentifier,
                                    Name = file.Name,
                                    SourceName = file.Name,
                                    FileType = file.ContentDisposition,
                                    StatusCode = "1",
                                    Content = file,
                                    IsDigitized = true,
                                    ParentSystemIdentifier = new Guid(masterFileId),
                                    TypeCode = (int)DigitalObjectType.DemoFile,
                                };


                                hasFileWithSameName = await HasFileWithTheSameName(file.FileName, new Guid(model.DocumentSystemIdentifier!));

                                if (hasFileWithSameName)
                                {
                                    return OperationResult.Failed(false, _localizer.GetString("Error_FileNameExists").ToString() + " " + file.FileName);
                                }

                                await _digitalObjectService.CreateDraftInternalAsync(demoFile);
                            }
                        }
                    }

                    ProcessStepModel processStep = new()
                    {
                        ProcessId = currentProcess!.Id,
                        StepTypeId = (int)ProcessStepType.Documentt_QualityControl,
                    };
                    if (model.AssignToUserId != null)
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }
                    if (model.AssignToRoleId != null)
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);

                    TaskCreateModel taskModel = new()
                    {
                        StepType = ProcessStepType.Document_PreparationOfADigitalObject,
                        ProcessId = currentProcess!.Id,
                        TimelineId = currentStep.Id,
                        EntityId = model.DocumentId,
                        EntitySystemIdentifier = new Guid(model.DocumentSystemIdentifier),
                        AssignedToUserId = model.AssignToUserId,
                        AssignedToRoleId = model.AssignToRoleId,
                        EntityType = EntityType.document
                    };

                    await _taskService.CreateAsync(taskModel);

                    await _context.SaveChangesAsync();
                }
                else if (model.ProcedureStepTypeId == (int)ProcessStepType.Documentt_QualityControl)
                {
                    await _processService.SetActiveProcessStepAsync(currentProcess!.Id, (int)ProcessStepType.Documenttt_ProcessFinalization);
                    await _processService.CompleteProcessAsync(currentProcess!.Id);

                    await _documentService.CreateOrUpdateDocumentFromDraftInternalAsync(Guid.Parse(model.DocumentSystemIdentifier!));

                    var itemsSys = _context.DigitalObjectDrafts
                         .Where(d => d.DocumentSystemIdentifier == Guid.Parse(model.DocumentSystemIdentifier!) && !d.Deleted && d.IsCurrent)
                         .Select(d => d.SystemIdentifier);

                    foreach (var item in itemsSys)
                    {
                        await _digitalObjectService.CreateOrUpdateDigitalObjectFromDraftInternalAsync(item, true);
                    }
                }
                else if (model.ProcedureStepTypeId == (int)ProcessStepType.Documentt_ReturnedForEditingDigitalData)
                {
                    if (model.MasterFiles == null && !hasDigitalObjectList)
                    {
                        return OperationResult.Failed(_localizer.GetString("CantGoNextStepWithDigObj").ToString());
                    }

                    Guid gl = new(model.DocumentSystemIdentifier!);

                    string masterFileId = string.Empty;

                    var doc = await _documentService.GetCurrentDraftAsync(new Guid(model.DocumentSystemIdentifier!));

                    if (model.MasterFiles != null && model.MasterFiles.Length > 0)
                    {
                        foreach (var file in model.MasterFiles)
                        {
                            DigitalObjectDraftModel master = new()
                            {
                                IsCurrent = true,
                                ArchiveId = currentProcess!.ArchiveId,
                                FundDraftId = doc.FundDraftId,
                                FundSystemIdentifier = doc.FundSystemIdentifier,
                                FundExternalIdentifier = doc.FundExternalIdentifier,
                                FundHasExternalSource = doc.FundHasExternalSource,
                                InventoryDraftId = doc.InventoryDraftId,
                                InventorySystemIdentifier = doc.InventorySystemIdentifier,
                                InventoryHasExternalSource = doc.InventoryHasExternalSource,
                                InventoryExternalIdentifier = doc.InventoryExternalIdentifier,
                                ArchivalEntityDraftId = doc.ArchivalEntityDraftId,
                                ArchivalEntityExternalIdentifier = doc.ArchivalEntityExternalIdentifier,
                                ArchivalEntityHasExternalSource = doc.ArchivalEntityHasExternalSource,
                                ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                                DocumentDraftId = doc.Id,
                                DocumentSystemIdentifier = gl,
                                DocumentHasExternalSource = doc.HasExternalSource.Value,
                                DocumentExternalIdentifier = doc.ExternalIdentifier,
                                Name = file.Name,
                                IsDigitized = true,
                                SourceName = file.Name,
                                FileType = file.ContentDisposition,
                                StatusCode = "1",
                                Content = file,
                                TypeCode = (int)DigitalObjectType.MasterFile,
                            };


                            hasFileWithSameName = await HasFileWithTheSameName(file.FileName, new Guid(model.DocumentSystemIdentifier!));

                            if (hasFileWithSameName)
                            {
                                return OperationResult.Failed(false, _localizer.GetString("Error_FileNameExists").ToString() + " " + file.FileName);
                            }

                            var parentSys = await _digitalObjectService.CreateDraftInternalAsync(master);

                            masterFileId = parentSys.ToString();
                        }
                        if (model.DerivativesFiles != null && model.DerivativesFiles.Length > 0)
                        {
                            foreach (var file in model.DerivativesFiles)
                            {
                                DigitalObjectDraftModel derivativesFile = new()
                                {
                                    IsCurrent = true,
                                    ArchiveId = currentProcess!.ArchiveId,
                                    FundDraftId = doc.FundDraftId,
                                    FundSystemIdentifier = doc.FundSystemIdentifier,
                                    FundExternalIdentifier = doc.FundExternalIdentifier,
                                    FundHasExternalSource = doc.FundHasExternalSource,
                                    InventoryDraftId = doc.InventoryDraftId,
                                    InventorySystemIdentifier = doc.InventorySystemIdentifier,
                                    InventoryHasExternalSource = doc.InventoryHasExternalSource,
                                    InventoryExternalIdentifier = doc.InventoryExternalIdentifier,
                                    ArchivalEntityDraftId = doc.ArchivalEntityDraftId,
                                    ArchivalEntityExternalIdentifier = doc.ArchivalEntityExternalIdentifier,
                                    ArchivalEntityHasExternalSource = doc.ArchivalEntityHasExternalSource,
                                    ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                                    DocumentDraftId = doc.Id,
                                    DocumentSystemIdentifier = gl,
                                    DocumentHasExternalSource = doc.HasExternalSource.Value,
                                    DocumentExternalIdentifier = doc.ExternalIdentifier,
                                    Name = file.Name,
                                    SourceName = file.Name,
                                    IsDigitized = true,
                                    FileType = file.ContentDisposition,
                                    StatusCode = "1",
                                    Content = file,
                                    ParentSystemIdentifier = new Guid(masterFileId),
                                    TypeCode = (int)DigitalObjectType.DerivativeFile,
                                };


                                hasFileWithSameName = await HasFileWithTheSameName(file.FileName, new Guid(model.DocumentSystemIdentifier!));

                                if (hasFileWithSameName)
                                {
                                    return OperationResult.Failed(false, _localizer.GetString("Error_FileNameExists").ToString() + " " + file.FileName);
                                }

                                await _digitalObjectService.CreateDraftInternalAsync(derivativesFile);
                            }
                        }
                        if (model.Files != null && model.Files.Length > 0)
                        {
                            foreach (var file in model.Files)
                            {
                                DigitalObjectDraftModel demoFile = new()
                                {
                                    IsCurrent = true,
                                    ArchiveId = currentProcess!.ArchiveId,
                                    FundDraftId = doc.FundDraftId,
                                    FundSystemIdentifier = doc.FundSystemIdentifier,
                                    FundExternalIdentifier = doc.FundExternalIdentifier,
                                    FundHasExternalSource = doc.FundHasExternalSource,
                                    InventoryDraftId = doc.InventoryDraftId,
                                    InventorySystemIdentifier = doc.InventorySystemIdentifier,
                                    InventoryHasExternalSource = doc.InventoryHasExternalSource,
                                    InventoryExternalIdentifier = doc.InventoryExternalIdentifier,
                                    ArchivalEntityDraftId = doc.ArchivalEntityDraftId,
                                    ArchivalEntityExternalIdentifier = doc.ArchivalEntityExternalIdentifier,
                                    ArchivalEntityHasExternalSource = doc.ArchivalEntityHasExternalSource,
                                    ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                                    DocumentDraftId = doc.Id,
                                    DocumentSystemIdentifier = gl,
                                    DocumentHasExternalSource = doc.HasExternalSource.Value,
                                    DocumentExternalIdentifier = doc.ExternalIdentifier,
                                    Name = file.Name,
                                    SourceName = file.Name,
                                    IsDigitized = true,
                                    FileType = file.ContentDisposition,
                                    StatusCode = "1",
                                    Content = file,
                                    ParentSystemIdentifier = new Guid(masterFileId),
                                    TypeCode = (int)DigitalObjectType.DemoFile,
                                };


                                hasFileWithSameName = await HasFileWithTheSameName(file.FileName, new Guid(model.DocumentSystemIdentifier!));

                                if (hasFileWithSameName)
                                {
                                    return OperationResult.Failed(false, _localizer.GetString("Error_FileNameExists").ToString() + " " + file.FileName);
                                }

                                await _digitalObjectService.CreateDraftInternalAsync(demoFile);
                            }
                        }
                    }

                    ProcessStepModel processStep = new()
                    {
                        ProcessId = currentProcess!.Id,
                        StepTypeId = (int)ProcessStepType.Documentt_QualityControl,
                    };
                    if (model.AssignToUserId != null)
                    {
                        processStep.AssignedToUserId = new Guid(model.AssignToUserId);
                    }
                    if (model.AssignToRoleId != null)
                    {
                        processStep.AssignedToRoleId = new Guid(model.AssignToRoleId);
                    }

                    await _processService.SetActiveProcessStepAsync(processStep);

                    TaskCreateModel taskModel = new()
                    {
                        StepType = ProcessStepType.Document_PreparationOfADigitalObject,
                        ProcessId = currentProcess!.Id,
                        TimelineId = currentStep.Id,
                        EntitySystemIdentifier = new Guid(model.DocumentSystemIdentifier),
                        EntityId = model.DocumentId,
                        AssignedToUserId = model.AssignToUserId,
                        AssignedToRoleId = model.AssignToRoleId,
                        EntityType = EntityType.document
                    };

                    await _taskService.CreateAsync(taskModel);
                    await _context.SaveChangesAsync();
                }

                transaction.Commit();

                return OperationResult.Success;
            }
            catch (FileTypeNotSupportedException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(false, exc.Message.ToString());
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }
        public async Task<OperationResult> StepBack(DocumentProdecureViewModel model)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var coment = 
                    _context.Comments
                    .Where(c => 
                        c.ProcessId == model.Id 
                        && c.ProcessStepId == model.ProcedureStepTypeId
                        && !c.Deleted 
                        && c.IsDraft.Value).FirstOrDefault();

                var DocumentSystemIdentifier = Guid.Parse(model.DocumentSystemIdentifier!);

                var currentProcess = await _context.Processes
                       .Where(x => x.DocumentSystemIdentifier == DocumentSystemIdentifier && !x.Completed && !x.Deleted)
                       .Include(x => x.ProcessTimelines.Where(t => !t.Completed))
                       .FirstOrDefaultAsync();

                if (currentProcess == null)
                {
                    return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                var currentStep = currentProcess?.ProcessTimelines.FirstOrDefault();

                if (currentStep == null)
                {
                    return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                if ((currentStep.AssignedToUserId != null) && (currentStep.AssignedToUserId != _userInfo.CurrentUserId))
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_NotAssignedStep").ToString());
                    //return OperationResult.Failed("Access denied");
                }

                var tasks = _context.Tasks
                   .Where(x => x.ProcessId == model.Id && x.StepId == model.ProcedureStepTypeId && x.StatusCode == Shared.TaskStatus.Pending)
                   .AsQueryable();
                if (tasks != null && tasks.Count() > 0)
                {
                    OperationResult taskResult = OperationResult.Success;
                    foreach (var task in tasks)
                    {
                        taskResult = await _taskService.ChangeTaskStatus(task.Id, Shared.TaskStatus.Completed);
                        if (!taskResult.Succeeded)
                        {
                            return taskResult;
                        }
                    }
                }

                if (model.ProcedureStepTypeId == (int)ProcessStepType.Document_ViewMetadataAndSelectAScanning)
                {
                    ProcessStepModel newStep = new()
                    {
                        ProcessId = currentProcess!.Id,
                        StepTypeId = (int)ProcessStepType.Document_ReturnedForEditingMetadata,
                        AssignedToUserId = currentProcess.CreatedBy,
                        Comment = coment!.Text,
                    };

                    await _processService.SetActiveProcessStepAsync(newStep);

                    TaskCreateModel taskModel = new()
                    {
                        StepType = ProcessStepType.Document_ViewMetadataAndSelectAScanning,
                        ProcessId = currentProcess!.Id,
                        TimelineId = currentStep.Id,
                        EntitySystemIdentifier = new Guid(model.DocumentSystemIdentifier),
                        AssignedToUserId = currentProcess.CreatedBy.ToString(),
                        EntityType = EntityType.document
                    };

                    await _taskService.CreateAsync(taskModel);
                    await _context.SaveChangesAsync();

                }
                else if (model.ProcedureStepTypeId == (int)ProcessStepType.Document_QualityControl)
                {

                    ProcessStepModel newStep = new()
                    {
                        ProcessId = currentProcess!.Id,
                        StepTypeId = (int)ProcessStepType.Document_ReturnedForEditingDigitalData,
                        AssignedToUserId = currentProcess.CreatedBy,
                        Comment = coment!.Text,
                    };

                    await _processService.SetActiveProcessStepAsync(newStep);

                    var asgnUser = _context.ProcessTimelines
                        .Where(t => t.ProcessId == model.Id && t.StepTypeId == (int)ProcessStepType.Document_PreparationOfADigitalObject)
                        .Select(t => t.CreatedBy).FirstOrDefault();

                    TaskCreateModel taskModel = new()
                    {
                        StepType = ProcessStepType.Document_QualityControl,
                        ProcessId = currentProcess!.Id,
                        EntityId = model.DocumentId,
                        TimelineId = currentStep.Id,
                        EntitySystemIdentifier = new Guid(model.DocumentSystemIdentifier),
                        AssignedToUserId = asgnUser.ToString(),
                        EntityType = EntityType.document
                    };

                    await _taskService.CreateAsync(taskModel);

                    await _context.SaveChangesAsync();
                }
                else if (model.ProcedureStepTypeId == (int)ProcessStepType.Documentt_ViewMetadataAndSelectAScanning)
                {
                    ProcessStepModel newStep = new()
                    {
                        ProcessId = currentProcess!.Id,
                        StepTypeId = (int)ProcessStepType.Documentt_ReturnedForEditingMetadata,
                        Comment = coment!.Text,
                        AssignedToUserId = currentProcess.CreatedBy
                    };

                    await _processService.SetActiveProcessStepAsync(newStep);

                    TaskCreateModel taskModel = new()
                    {
                        StepType = ProcessStepType.Document_ViewMetadataAndSelectAScanning,
                        ProcessId = currentProcess!.Id,
                        TimelineId = currentStep.Id,
                        EntityId = model.DocumentId,
                        EntitySystemIdentifier = new Guid(model.DocumentSystemIdentifier),
                        AssignedToUserId = currentProcess.CreatedBy.ToString(),
                        EntityType = EntityType.document,
                    };

                    await _taskService.CreateAsync(taskModel);
                    await _context.SaveChangesAsync();
                }
                else if (model.ProcedureStepTypeId == (int)ProcessStepType.Documentt_QualityControl)
                {
                    var asgnUser = _context.ProcessTimelines.Where(t => t.ProcessId == model.Id && t.StepTypeId == (int)ProcessStepType.Documentt_PreparationOfADigitalObject).Select(t => t.CreatedBy).FirstOrDefault();

                    ProcessStepModel newStep = new()
                    {
                        ProcessId = currentProcess!.Id,
                        StepTypeId = (int)ProcessStepType.Documentt_ReturnedForEditingDigitalData,
                        Comment = coment!.Text,
                        AssignedToUserId = asgnUser
                    };

                    await _processService.SetActiveProcessStepAsync(newStep);

                    TaskCreateModel taskModel = new()
                    {
                        StepType = ProcessStepType.Document_QualityControl,
                        ProcessId = currentProcess!.Id,
                        TimelineId = currentStep.Id,
                        EntityId = model.DocumentId,
                        EntitySystemIdentifier = new Guid(model.DocumentSystemIdentifier),
                        AssignedToUserId = asgnUser.ToString(),
                        EntityType = EntityType.document
                    };

                    await _taskService.CreateAsync(taskModel);
                    await _context.SaveChangesAsync();
                }

                if (coment != null)
                {
                    coment.IsDraft = false;

                    _context.Comments.Update(coment);
                    _context.SaveChanges();
                }
                transaction.Commit();

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }
        public async Task<OperationResult> SaveChanges(DocumentProcedureUpdateModel model)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                bool hasFileWithSameName = false;

                var DocumentSystemIdentifier = Guid.Parse(model.DocumentSystemIdentifier!);

                var currentProcess = await _context.Processes
                       .Where(x => x.DocumentSystemIdentifier == DocumentSystemIdentifier && !x.Completed && !x.Deleted)
                       .Include(x => x.ProcessTimelines.Where(t => !t.Completed))
                       .FirstOrDefaultAsync();

                if (currentProcess == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                var currentStep = currentProcess?.ProcessTimelines.FirstOrDefault();

                if (currentStep == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                if ((currentStep.AssignedToUserId != null) && (currentStep.AssignedToUserId != _userInfo.CurrentUserId))
                {
                    return OperationResult.Failed("Access denied");
                }

                Guid gl = new(model.DocumentSystemIdentifier!);

                Guid? masterFileSystemIdentifier = null;

                var doc = await _documentService.GetCurrentDraftAsync(new Guid(model.DocumentSystemIdentifier!));

                var fundCode = _context.VFunds
                    .Where(f => f.SystemIdentifier == doc.FundSystemIdentifier && !f.Deleted)
                    .Select(f => f.StatusCode)
                    .FirstOrDefault();

                if (model.MasterFiles != null && model.MasterFiles.Length > 0)
                {
                    foreach (var file in model.MasterFiles)
                    {
                        DigitalObjectDraftModel master = new()
                        {
                            IsCurrent = true,
                            HasExternalSource = false,
                            IsDigitized = true,
                            ArchiveId = currentProcess!.ArchiveId,
                            FundDraftId = doc.FundDraftId,
                            FundSystemIdentifier = doc.FundSystemIdentifier,
                            FundExternalIdentifier = doc.FundExternalIdentifier,
                            FundHasExternalSource = doc.FundHasExternalSource,
                            InventoryDraftId = doc.InventoryDraftId,
                            InventorySystemIdentifier = doc.InventorySystemIdentifier,
                            InventoryHasExternalSource = doc.InventoryHasExternalSource,
                            InventoryExternalIdentifier = doc.InventoryExternalIdentifier,
                            ArchivalEntityDraftId = doc.ArchivalEntityDraftId,
                            ArchivalEntityExternalIdentifier = doc.ArchivalEntityExternalIdentifier,
                            ArchivalEntityHasExternalSource = doc.ArchivalEntityHasExternalSource,
                            ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                            DocumentDraftId = doc.Id,
                            DocumentSystemIdentifier = gl,
                            DocumentHasExternalSource = doc.HasExternalSource ?? false,
                            DocumentExternalIdentifier = doc.ExternalIdentifier,
                            TypeCode = (int)DigitalObjectType.MasterFile,
                            ContentType = file.ContentType,
                            Name = file.Name,
                            SourceName = file.Name,
                            FileType = file.ContentDisposition,
                            StatusCode = Shared.Status.New,
                            Content = file,
                            SkipValidation = model.SkipMasterValidation ?? false,
                        };

                        hasFileWithSameName = await HasFileWithTheSameName(file.FileName, new Guid(model.DocumentSystemIdentifier!));

                        if (hasFileWithSameName)
                        {
                            return OperationResult.Failed(false, _localizer.GetString("Error_FileNameExists").ToString() + " " + file.FileName);
                        }

                        masterFileSystemIdentifier = await _digitalObjectService.CreateDraftInternalAsync(master);
                    }
                    if (model.DerivativesFiles != null && model.DerivativesFiles.Length > 0)
                    {
                        foreach (var file in model.DerivativesFiles)
                        {
                            DigitalObjectDraftModel derivativesFile = new()
                            {
                                IsCurrent = true,
                                HasExternalSource = false,
                                IsDigitized = true,
                                ArchiveId = currentProcess!.ArchiveId,
                                FundDraftId = doc.FundDraftId,
                                FundSystemIdentifier = doc.FundSystemIdentifier,
                                FundExternalIdentifier = doc.FundExternalIdentifier,
                                FundHasExternalSource = doc.FundHasExternalSource,
                                InventoryDraftId = doc.InventoryDraftId,
                                InventorySystemIdentifier = doc.InventorySystemIdentifier,
                                InventoryHasExternalSource = doc.InventoryHasExternalSource,
                                InventoryExternalIdentifier = doc.InventoryExternalIdentifier,
                                ArchivalEntityDraftId = doc.ArchivalEntityDraftId,
                                ArchivalEntityExternalIdentifier = doc.ArchivalEntityExternalIdentifier,
                                ArchivalEntityHasExternalSource = doc.ArchivalEntityHasExternalSource,
                                ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                                DocumentDraftId = doc.Id,
                                DocumentSystemIdentifier = gl,
                                DocumentHasExternalSource = doc.HasExternalSource ?? false,
                                DocumentExternalIdentifier = doc.ExternalIdentifier,
                                Name = file.Name,
                                SourceName = file.Name,
                                FileType = file.ContentDisposition,
                                StatusCode = Shared.Status.New,
                                Content = file,
                                ParentSystemIdentifier = masterFileSystemIdentifier,
                                TypeCode = (int)DigitalObjectType.DerivativeFile,
                                SkipValidation = model.SkipDerivativeValidation ?? false,
                            };

                            hasFileWithSameName = await HasFileWithTheSameName(file.FileName, new Guid(model.DocumentSystemIdentifier!));

                            if (hasFileWithSameName)
                            {
                                return OperationResult.Failed(false, _localizer.GetString("Error_FileNameExists").ToString() + " " + file.FileName);
                            }

                            await _digitalObjectService.CreateDraftInternalAsync(derivativesFile);
                        }
                    }                   

                    if (model.Files != null && model.Files.Length > 0)
                    {
                        foreach (var file in model.Files)
                        {
                            DigitalObjectDraftModel demoFile = new()
                            {
                                IsCurrent = true,
                                HasExternalSource = false,
                                IsDigitized = true,
                                ArchiveId = currentProcess!.ArchiveId,
                                FundDraftId = doc.FundDraftId,
                                FundSystemIdentifier = doc.FundSystemIdentifier,
                                FundExternalIdentifier = doc.FundExternalIdentifier,
                                FundHasExternalSource = doc.FundHasExternalSource,
                                InventoryDraftId = doc.InventoryDraftId,
                                InventorySystemIdentifier = doc.InventorySystemIdentifier,
                                InventoryHasExternalSource = doc.InventoryHasExternalSource,
                                InventoryExternalIdentifier = doc.InventoryExternalIdentifier,
                                ArchivalEntityDraftId = doc.ArchivalEntityDraftId,
                                ArchivalEntityExternalIdentifier = doc.ArchivalEntityExternalIdentifier,
                                ArchivalEntityHasExternalSource = doc.ArchivalEntityHasExternalSource,
                                ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                                DocumentDraftId = doc.Id,
                                DocumentSystemIdentifier = gl,
                                DocumentHasExternalSource = doc.HasExternalSource ?? false,
                                DocumentExternalIdentifier = doc.ExternalIdentifier,
                                ContentType = file.ContentType,
                                Name = file.Name,
                                SourceName = file.Name,
                                FileType = file.ContentDisposition,
                                StatusCode = Shared.Status.New,
                                Content = file,
                                ParentSystemIdentifier = masterFileSystemIdentifier,
                                TypeCode = (int)DigitalObjectType.DemoFile,
                                SkipValidation = model.SkipDemoValidation ?? false,
                            };

                            hasFileWithSameName = await HasFileWithTheSameName(file.FileName, new Guid(model.DocumentSystemIdentifier!));

                            if (hasFileWithSameName)
                            {
                                return OperationResult.Failed(false, _localizer.GetString("Error_FileNameExists").ToString() + " " + file.FileName);
                            }

                            await _digitalObjectService.CreateDraftInternalAsync(demoFile);
                        }
                    }
                }
                transaction.Commit();

                return OperationResult.Success;
            }
            catch (FileTypeNotSupportedException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(false, exc.Message);
            }
            catch (CustomException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(false, exc.Message);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }
        private async Task<bool> HasFileWithTheSameName(string digitalObjectName, Guid documentSysId)
        {
            return await _context.VDigitalObjects
           .Where(d => d.DocumentSystemIdentifier == documentSysId && d.SourceName == digitalObjectName && !d.Deleted).AnyAsync();
        }
    }
}
