using DAA.Data;
using DAA.Extensions.Exceptions;
using DAA.Identity;
using DAA.Models.DigitalObjects;
using DAA.Models.File;
using DAA.Models.Import;
using DAA.Models.Packages;
using DAA.Models.Tasks;
using DAA.Services.DigitalObjects;
using DAA.Services.Files;
using DAA.Services.FileUploadApp;
using DAA.Services.Interfaces;
using DAA.Services.Notifications;
using DAA.Services.Process;
using DAA.Services.Tasks;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System;
using Task = System.Threading.Tasks.Task;

namespace DAA.Services.Packages
{
    public class PackagesService : BaseService, IPackagesService
    {
        private readonly IUserInfo _userInfo;
        private readonly ApplicationRoleManager _roleManager;
        private readonly IFileService _fileService;
        private readonly IProcessService _processService;
        private readonly ITaskService _taskService;
        private readonly INotificationEventService _notificationEventService;
        private readonly IUtilityService _utilityService;
        private readonly IFileUploadAppService _fileUploadAppService;

        public PackagesService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            ILogger<PackagesService> logger,
            IUserInfo userInfo,
            ApplicationRoleManager roleManager,
            IFileService fileService,
            IProcessService processService,
            ITaskService taskService,
            INotificationEventService notificationEventService,
            IUtilityService utilityService,
            IFileUploadAppService fileUploadAppService
            )
            : base(context, localizer, logger)
        {
            _userInfo = userInfo;
            _roleManager = roleManager;
            _fileService = fileService;
            _processService = processService;
            _taskService = taskService;
            _notificationEventService = notificationEventService;
            _utilityService = utilityService;
            _fileUploadAppService = fileUploadAppService;
        }

        public async Task CreateApplicationPackages(ApplicationPackageModel model)
        {
            EdocsCollectingApplication? application = await _context.EdocsCollectingApplications
                                                                    .Include(x => x.PackageA)
                                                                    .Include(x => x.PackageB)
                                                                    .SingleOrDefaultAsync(x => x.Id == model.ApplicationId);

            if (application == null)
            {
                throw new ItemNotFoundException("Application not found");
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {

                if (!application.PackageAid.HasValue)
                {
                    Package packageА = new Package()
                    {
                        Type = "A"
                    };
                    application.PackageA = packageА;
                    _context.Packages.Add(packageА);

                    Package packageB = new Package()
                    {
                        Type = "B"
                    };

                    application.PackageB = packageB;
                    _context.Packages.Add(packageB);

                    await _context.SaveAsync($"Packages updated for application {application.Id}");
                }

                await ProcessPackageFiles(model.PackageA, application.PackageAid!.Value, true);
                await ProcessPackageFiles(model.PackageB, application.PackageBid!.Value, false);

                transaction.Commit();
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                throw;
            }
        }

        public async Task CreateInventoryPackageBWithImport(PackageBImportModel model)
        {
            var inventory = await _context.InventoryDrafts.SingleOrDefaultAsync(x => x.SystemIdentifier == model.InventoryIdentifier
                                                                                  && x.IsCurrent
                                                                                  && !x.Deleted);

            if (inventory == null)
            {
                throw new NullReferenceException("Inventory draft not found");
            }

            if (!inventory.PackageBid.HasValue)
            {
                throw new NullReferenceException($"Package B for inventory draft {inventory.SystemIdentifier} not found");
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                foreach (PackageDocumentBaseModel f in model.PackageB)
                {
                    if (f.Id.HasValue && f.Id != default(int))
                    {
                        if (f._deleted) //Dhould update
                        {
                            //Delete DO
                            var docObj = await _context.DigitalObjectDrafts
                                .Where(dobj => dobj.TypeCode == (int)DigitalObjectType.MasterFile && dobj.DocumentSystemIdentifier == f.DocumentSystemIdentifier && dobj.IsCurrent && !dobj.Deleted)
                                .Select(dobj => dobj.Id)
                                .SingleOrDefaultAsync();

                            //If the digital object is deleted from the document display form, id = default
                            if (docObj != default)
                            {
                                await _utilityService.DeleteDODraftInternalAsync(docObj);
                            }

                            if (f.TypeCode == (int)DigitalObjectType.MasterFile)
                            {
                                var docObjts = _context.DigitalObjectDrafts.Where(d =>
                                                     d.DocumentSystemIdentifier == f.DocumentSystemIdentifier
                                                    && !d.Deleted && d.TypeCode == (int)DigitalObjectType.DerivativeFile).Select(d => d.Id);

                                if (docObjts != null)
                                {
                                    foreach (var item in docObjts)
                                    {
                                        await _utilityService.DeleteDODraftInternalAsync(item);
                                    }
                                }

                            }

                            //Update package file
                            var packageDoc = await UpdateFile(f);

                            if (f.File != null)
                            {
                                //Create new DO
                                await CreateDOAsync(f, packageDoc);
                            }
                        }
                    }
                    else if (f.File != null)
                    {
                        //Create
                        var packageDoc = await ((IPackagesServiceBase)this).CreateFileInternal(f, inventory.PackageBid.Value);
                        await CreateDOAsync(f, packageDoc);
                    }
                }

                await _context.SaveAsync($"Update inventory {inventory.Id} package B with import");
                transaction.Commit();
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        public async Task CreateApplicationPackagesWithImport(ApplicationPackageModel model)
        {
            EdocsCollectingApplication? application = await _context.EdocsCollectingApplications
                .Include(x => x.PackageA)
                .Include(x => x.PackageB)
                .Include(x => x.Status)
                .SingleOrDefaultAsync(x => x.Id == model.ApplicationId);

            if (application == null)
            {
                throw new ItemNotFoundException("Application not found");
            }

            int[] allowedStatuses = new int[]
            {
                (int)ApplicationStatus.AddPackages,
                (int)ApplicationStatus.EditPackages,
                (int)ApplicationStatus.ModificationRequest,
            };

            if (!allowedStatuses.Contains(application.StatusId))
            {
                throw new Exception(string.Format(_localizer.GetString("Error_ApplicationNotForEdit"), application.Status.Text));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                if (!application.PackageAid.HasValue)
                {
                    Package packageА = new Package()
                    {
                        Type = "A"
                    };
                    application.PackageA = packageА;
                    _context.Packages.Add(packageА);

                    Package packageB = new Package()
                    {
                        Type = "B"
                    };

                    application.PackageB = packageB;
                    _context.Packages.Add(packageB);

                    await _context.SaveAsync($"Packages updated for application {application.Id}");
                }

                await ProcessPackageFiles(model.PackageA, application.PackageAid!.Value, true);

                //Guid? masterSystemId = null;

                //If master digital object must be deleted, derivative digital object is deleted automatically
                //if (model.PackageB.Any(x => x._deleted && x.TypeCode == 1))
                //{
                //    foreach (var x in model.PackageB)
                //    {
                //        if (x.TypeCode == 2)
                //        {
                //            x._deleted = true;
                //        }
                //    }
                //}

                foreach (PackageDocumentBaseModel packageDocument in model.PackageB)
                {
                    if (packageDocument.Id.HasValue && packageDocument.Id != default(int))
                    {
                        if (packageDocument._deleted) //Should update
                        {
                            //Delete DO
                            //var docObj = await (from d in _context.DigitalObjectDrafts
                            //                    where d.DocumentSystemIdentifier == f.DocumentSystemIdentifier
                            //                    && !d.Deleted && d.TypeCode == f.TypeCode
                            //                    select d.Id).FirstOrDefaultAsync();

                            //await _utilityService.DeleteDODraftInternalAsync(docObj);

                            //Delete master and derivative digital objects
                            var digitalObjectIds = _context.DigitalObjectDrafts
                                                .Where(dobj => dobj.DocumentSystemIdentifier == packageDocument.DocumentSystemIdentifier && dobj.IsCurrent && !dobj.Deleted)
                                                .Select(dobj => dobj.Id);
                            foreach (var digitalObjectId in digitalObjectIds)
                            {
                                await _utilityService.DeleteDODraftInternalAsync(digitalObjectId);
                            }

                            //Update package file
                            var packageDoc = await UpdateFile(packageDocument);

                            //If new file is uploaded create new digital object
                            if (packageDocument.File != null)
                            {
                                await CreateDOAsync(packageDocument, packageDoc);
                            }
                        }
                    }
                    else if (packageDocument.File != null)
                    {
                        //Create new package document
                        var currentPackageDocument = await ((IPackagesServiceBase)this).CreateFileInternal(packageDocument, application.PackageBid!.Value);

                        //Ignoring the TypeCode. All files are master files.
                        //if (f.TypeCode == (int)DigitalObjectType.MasterFile)
                        //{
                        //    masterSystemId = await CreateDOAsync(f, packageDoc);

                        //    continue;
                        //}

                        //if (masterSystemId.HasValue)
                        //{
                        //    f.ParentSystemIdentifier = masterSystemId;
                        //}
                        //else
                        //{
                        //    masterSystemId = _context.DigitalObjectDrafts
                        //        .Where(d => d.DocumentSystemIdentifier == f.DocumentSystemIdentifier
                        //                && d.TypeCode == (int)DigitalObjectType.MasterFile
                        //                && !d.Deleted)
                        //        .Select(d => d.SystemIdentifier)
                        //        .FirstOrDefault();

                        //    if (!masterSystemId.HasValue)
                        //    {
                        //        continue;
                        //    }

                        //    f.ParentSystemIdentifier = masterSystemId;
                        //}

                        //Create new digital object
                        await CreateDOAsync(packageDocument, currentPackageDocument);
                    }
                }

                await _context.SaveAsync($"Create/Update application {application.Id} packages");

                transaction.Commit();
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        private async Task<Guid> CreateDOAsync(PackageDocumentBaseModel f, PackageDocument packageDoc)
        {

            var doc = await _context.DocumentDrafts
                        .Where(x => x.SystemIdentifier == f.DocumentSystemIdentifier && x.IsCurrent && !x.Deleted)
                        .SingleOrDefaultAsync();

            DigitalObjectDraftModel digitalObject = new DigitalObjectDraftModel
            {
                ArchiveId = doc.ArchiveId,
                FundSystemIdentifier = doc.FundSystemIdentifier,
                InventorySystemIdentifier = doc.InventorySystemIdentifier,
                ArchivalEntitySystemIdentifier = doc.ArchivalEntitySystemIdentifier,
                DocumentSystemIdentifier = doc.SystemIdentifier,
                //TypeCode = f.TypeCode.HasValue ? f.TypeCode : (int)DigitalObjectType.MasterFile,
                TypeCode = (int)DigitalObjectType.MasterFile,
                StatusCode = Shared.Status.New,
                ContentType = f.File.ContentType,
                ParentSystemIdentifier = f.ParentSystemIdentifier,
                SourceName = f.File.FileName,
                PackageDocumentId = packageDoc.Id,
                FileSize = f.File.Length,
                IsImported = true,
                IsDigitized = false,
            };

            var result = await _utilityService.CreateDODraftFromPackageDocumentInternalAsync(packageDoc, digitalObject);

            return result;
        }

        private async Task ProcessPackageFiles(IEnumerable<PackageDocumentBaseModel> files, int packageId, bool skipValidation = false)
        {
            foreach (PackageDocumentBaseModel f in files)
            {
                f.SkipValidation = skipValidation;

                if (f.Id.HasValue && f.Id != default(int))
                {
                    //Update
                    await UpdateFile(f);
                }
                else if (f.File != null)
                {
                    //Create
                    await ((IPackagesServiceBase)this).CreateFileInternal(f, packageId);
                }
            }
        }

        public async Task<OperationResult> CommitApplicationPackages(int applicationId)
        {
            EdocsCollectingApplication? application = await _context.EdocsCollectingApplications
                .Include(x => x.PackageA).ThenInclude(p => p.PackageDocuments.Where(p => !p.Deleted))
                .Include(x => x.PackageB).ThenInclude(p => p.PackageDocuments.Where(p => !p.Deleted))
                .Include(x => x.Status)
                .SingleOrDefaultAsync(x => x.Id == applicationId);

            if (application == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            InventoryDraft? inventory = await _context.InventoryDrafts
                .Where(x => x.ApplicationId == applicationId && x.IsCurrent && !x.Deleted)
                .FirstOrDefaultAsync();

            if (inventory == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ApplicationInventoryNotFound").ToString());
            }


            Data.Process? activeProcess = await _context.Processes
                .Where(x => (x.InventorySystemIdentifier == inventory!.SystemIdentifier
                            || x.FundSystemIdentifier == inventory.FundSystemIdentifier)
                        && !x.Completed && !x.Deleted)
                .FirstOrDefaultAsync();

            if (activeProcess == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ApplicationActiveProcessNotFound").ToString());
            }


            List<int> requiredDocTypeIds = await _context.PackageAdocsTemplates
                .Where(x => x.ProcedureId == activeProcess.ProcessTypeId && x.Required && !x.Deleted)
                .Select(x => x.Id)
                .ToListAsync();

            if (application.PackageAid == null && requiredDocTypeIds.Count > 0)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_MissingPackageADocs").ToString());
            }

            if (requiredDocTypeIds.Count > 0)
            {
                List<int?> uploadedDocTypeIds = application.PackageA!.PackageDocuments.Select(x => x.DocTypeId).ToList();
                List<int> missingDocTypeIds = requiredDocTypeIds.Where(x => !uploadedDocTypeIds.Contains(x)).ToList();

                if (missingDocTypeIds.Count > 0)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_MissingRequiredPackageADocs").ToString());
                }
            }

            if (application.PackageBid == null || !application.PackageB!.PackageDocuments.Any())
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_MissingPackageB").ToString());
            }

            if (activeProcess.ProcessTypeId == (int)Shared.ProcessType.AddFundAndInventory
                || activeProcess.ProcessTypeId == (int)Shared.ProcessType.AddInventory)
            {

                if (await _context.DocumentDrafts
                       .Where(doc => doc.InventorySystemIdentifier == inventory.SystemIdentifier
                           && doc.IsCurrent
                           && !doc.Deleted
                           && !doc.DigitalObjectDrafts.Where(dobj => dobj.IsCurrent && !dobj.Deleted).Any())
                       .AnyAsync())
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_MissingDocumentFiles").ToString());
                }
            }


            using var transaction = _context.Database.BeginTransaction();
            try
            {
                Guid? assignedToRoleId = null;
                Guid? assignedToUserId = null;
                string notificationType = Shared.NotificationType.ApplicationPackagesAdded;

                if (application.StatusId == (int)ApplicationStatus.AddPackages || application.StatusId == (int)ApplicationStatus.EditPackages)
                {
                    application.StatusId = (int)ApplicationStatus.PackagesApproval;

                    //send for package approval 
                    var role = await _roleManager.FindByNameAsync(_localizer.GetString("Role_B").ToString(), application.ArchiveId);
                    assignedToRoleId = role?.Id;
                }
                else if (application.StatusId == (int)ApplicationStatus.ModificationRequest)
                {
                    application.StatusId = (int)ApplicationStatus.ModificationApplied;

                    //send for package modifications revision
                    notificationType = Shared.NotificationType.ModificationApplied;
                    assignedToUserId = activeProcess.CreatedBy;
                }
                else
                {
                    transaction.Rollback();
                    _logger.LogWarning(String.Format(_localizer.GetString("Error_ApplicationNotForEdit"), application.Status.Text));
                    return OperationResult.Failed(String.Format(_localizer.GetString("Error_ApplicationNotForEdit"), application.Status.Text));
                }
                await _context.SaveAsync("Application commited");

                //send task
                //var roleName = _localizer.GetString("Role_B").ToString();
                //var role = await _context.AspNetRoles
                //        .Where(r => r.ArchiveId == application.ArchiveId && r.Name == roleName)
                //        .SingleOrDefaultAsync();
                //assignedToRoleId = role?.Id;

                if (assignedToRoleId.HasValue || assignedToUserId.HasValue)
                {
                    TaskCreateModel taskModel = new()
                    {
                        NotificationType = notificationType,
                        EntityType = BusinessObjectType.EDocsApplication,
                        EntityId = application.Id,
                        AssignedToRoleId = assignedToRoleId.HasValue ? assignedToRoleId.Value.ToString("D") : null,
                        AssignedToUserId = assignedToUserId.HasValue ? assignedToUserId.Value.ToString("D") : null,
                    };

                    var taskResult = await _taskService.CreateAsync(taskModel);
                    if (!taskResult.Succeeded)
                    {
                        _logger.LogError(taskResult.ToString());
                        return taskResult;
                    }
                }

                transaction.Commit();

                return OperationResult.Success;
            }
            catch (CustomException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(false, exc.Message.ToString());
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        public async Task<OperationResult> ApprovePackages(int applicationId)
        {
            var application = await _context.EdocsCollectingApplications
                                            .Include(x => x.PackageA)
                                            .Include(x => x.PackageB)
                                            .Include(x => x.InventoryDrafts)
                                            .FirstOrDefaultAsync(x => x.Id == applicationId && !x.Deleted);

            if (application == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            using var transaction = _context.Database.BeginTransaction();

            try
            {
                /*
                * Одобрението се прави в двата пакета понеже в бъдеще може да 
                * се наложи да разделим одобрението по отделно за всеки пакет
                */
                var packageA = _context.Packages.Find(application.PackageAid);
                var packageB = _context.Packages.Find(application.PackageBid);
                var date = DateTime.UtcNow;
                packageA.Approved = true;
                packageA.ApprovedBy = _userInfo.CurrentUserId;
                application.PackageA.ApprovedOn = date;

                packageB.Approved = true;
                packageB.ApprovedBy = _userInfo.CurrentUserId;
                packageB.ApprovedOn = date;

                //Add package A to inventory
                var inventory = application.InventoryDrafts.FirstOrDefault();

                if (inventory == null)
                {
                    throw new CustomException(_localizer.GetString("Error_NoInventoryForApplication", application.Number).ToString());
                }

                inventory.PackageAid = application.PackageAid;
                inventory.PackageBid = application.PackageBid;

                //inventory = await CalculateFundAndInventoryDocFields(inventory);

                application.StatusId = (int)ApplicationStatus.AwaitingCommittee;
                _context.EdocsCollectingApplications.Update(application);

                await UpdateProcessStep(inventory);
                await _context.SaveAsync($"Application {applicationId} packages approved");

                await _notificationEventService.AddNotificationEvent(application.Id, Shared.NotificationType.ApprovedApplicationPackages, null, application.CreatedBy);

                // complete previous task
                var completePrevTaskResult = await _taskService.CompletePreviousTask(ProcessStepType.NoStep, null, Shared.NotificationType.ApplicationPackagesAdded, application.Id);
                if (!completePrevTaskResult.Succeeded)
                {
                    throw new Exception(completePrevTaskResult.ToString());
                }

                transaction.Commit();

                return OperationResult.Success;
            }
            catch (CustomException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(false, exc.Message.ToString());
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        private async Task UpdateProcessStep(InventoryDraft inventory)
        {
            //var activeProcess = await _context.Processes
            //    .FirstOrDefaultAsync(x => (x.InventorySystemIdentifier == inventory.SystemIdentifier
            //                                || x.FundSystemIdentifier == inventory.FundSystemIdentifier)
            //                           && !x.Completed);
            var activeProcess = await _processService.GetCurrentActiveProcess(BusinessObjectType.Inventory, inventory.SystemIdentifier, true);
            if (activeProcess == null)
            {
                throw new NullReferenceException(nameof(activeProcess));
            }

            var activeStepResult = await _processService.SetActiveProcessStepAsync(activeProcess.Id!.Value, (int)ProcessStepType.CommissionReport);
            if (!activeStepResult.Succeeded)
            {
                throw new Exception(activeStepResult.ToString());
            }
        }

        public async Task RejectPackage(int applicationId, string reason)
        {
            using var transaction = _context.Database.BeginTransaction();

            try
            {
                var application = await _context.EdocsCollectingApplications
                                           .Include(x => x.PackageA)
                                           .Include(x => x.PackageB)
                                           .FirstOrDefaultAsync(x => x.Id == applicationId && !x.Deleted);

                if (application != null)
                {
                    /*
                     * Одобрението се прави в двата пакета понеже в бъдеще може да 
                     * се наложи да разделим одобрението по отделно за всеки пакет
                     */
                    var date = DateTime.UtcNow;
                    application.PackageA.Approved = false;
                    application.PackageA.ApprovedBy = _userInfo.CurrentUserId;
                    application.PackageA.ApprovedOn = date;
                    application.PackageA.RejectReason = reason;

                    application.PackageB.Approved = false;
                    application.PackageB.ApprovedBy = _userInfo.CurrentUserId;
                    application.PackageB.ApprovedOn = date;
                    application.PackageB.RejectReason = reason;

                    application.StatusId = (int)ApplicationStatus.EditPackages;

                    await _context.SaveAsync($"Application {applicationId} packages changes required");

                    await _notificationEventService.AddNotificationEvent(application.Id, Shared.NotificationType.ModifyApplicationPackages, null, application.CreatedBy);

                    // complete previous task
                    var completePrevTaskResult = await _taskService.CompletePreviousTask(ProcessStepType.NoStep, null, Shared.NotificationType.ApplicationPackagesAdded, application.Id);
                    if (!completePrevTaskResult.Succeeded)
                    {
                        throw new Exception(completePrevTaskResult.ToString());
                    }
                }

                transaction.Commit();
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                throw;
            }
        }

        public async Task CancelPackages(int applicationId, string reason)
        {
            using var transaction = _context.Database.BeginTransaction();

            try
            {
                var application = await _context.EdocsCollectingApplications
                                           .Include(x => x.PackageA)
                                           .Include(x => x.PackageB)
                                           .FirstOrDefaultAsync(x => x.Id == applicationId && !x.Deleted);

                if (application != null)
                {
                    var date = DateTime.UtcNow;
                    application.PackageA.Approved = false;
                    application.PackageA.Deleted = true;
                    application.PackageA.DeletedBy = _userInfo.CurrentUserId;
                    application.PackageA.DeletedOn = date;
                    application.PackageA.RejectReason = reason;

                    application.PackageB.Approved = false;
                    application.PackageB.Deleted = true;
                    application.PackageB.DeletedBy = _userInfo.CurrentUserId;
                    application.PackageB.DeletedOn = date;
                    application.PackageB.RejectReason = reason;

                    application.StatusId = (int)ApplicationStatus.Rejected;

                    await _context.SaveAsync($"Application {applicationId} packages changes required");

                    await _notificationEventService.AddNotificationEvent(application.Id, Shared.NotificationType.RejectedApplicationPackages, null, application.CreatedBy);

                    // complete previous task
                    var completePrevTaskResult = await _taskService.CompletePreviousTask(ProcessStepType.NoStep, null, Shared.NotificationType.ApplicationPackagesAdded, application.Id);
                    if (!completePrevTaskResult.Succeeded)
                    {
                        throw new Exception(completePrevTaskResult.ToString());
                    }
                    var packageAFiles = _context.PackageDocuments.Where(p => p.PackageId == application.PackageA.Id && !p.Deleted);
                    var packageBFiles = _context.PackageDocuments.Where(p => p.PackageId == application.PackageB.Id && !p.Deleted);

                    if (packageAFiles.Any())
                    {
                        foreach (var itemA in packageAFiles)
                        {
                            await RemoveFileFromPackage(itemA.Id);
                        }
                    }
                    if (packageBFiles.Any())
                    {
                        foreach (var itemB in packageBFiles)
                        {
                            await RemoveFileFromPackage(itemB.Id);
                        }
                    }

                }

                transaction.Commit();
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                throw;
            }
        }
        public async Task<ApplicationPackageDisplayModel?> GetPackagesForApplication(int applicationId)
        {
            var result = from a in _context.EdocsCollectingApplications
                         where a.Id == applicationId
                         select new ApplicationPackageDisplayModel()
                         {
                             ApplicationId = a.Id,
                             // InventoryIdentifier = a.InventoryDrafts.FirstOrDefault().SystemIdentifier, // There allways must be Inventory linked to the application
                             PackageA = a.PackageA != null ? a.PackageA.PackageDocuments.Where(d => !d.Deleted).Select(x => new PackageDocumentDisplayModel()
                             {
                                 Id = x.Id,
                                 Description = x.Description,
                                 DocumentTypeId = x.DocTypeId,
                                 DocumentType = x.DocTypeId.HasValue ? x.DocType.Title : String.Empty,
                                 FileName = x.FileName,
                                 FileId = x.FileId,
                                 FileSize = x.FileSizeInBytes
                             }) : null,
                             PackageB = a.PackageB != null ? a.PackageB.PackageDocuments.Where(d => !d.Deleted).Select(x => new PackageDocumentDisplayModel()
                             {
                                 Id = x.Id,
                                 Description = x.Description,
                                 FileName = x.FileName,
                                 FileId = x.FileId,
                                 FileSize = x.FileSizeInBytes,
                                 DocumentSystemIdentifier = x.DigitalObjectDrafts.Select(d => d.DocumentSystemIdentifier).FirstOrDefault(),
                                 TypeCode = x.DigitalObjectDrafts.Select(d => d.TypeCode).FirstOrDefault(),
                                 ParentId = x.ParentId,
                             }) : null
                         };
            //TODO derivatives

            bool isDraft = !_context.Inventories.Any(i => i.ApplicationId == applicationId);
            IEnumerable<PackageDocumentDisplayModel> derivatives;
            if (isDraft)
            {
                var inventoryDraftId = _context.InventoryDrafts.Where(i => i.ApplicationId == applicationId).Select(i => i.Id).First();
                derivatives = _context.DigitalObjectDrafts
                                      .Where(o => o.InventoryDraftId == inventoryDraftId && o.TypeCode == (int)DigitalObjectType.DerivativeFile && !o.Deleted)
                                      .Select(o => new PackageDocumentDisplayModel()
                                      {
                                          Id = o.Id,
                                          FileName = o.SourceName,
                                          FileId = o.SystemIdentifier.ToString(),
                                          FileSize = o.FileSize,
                                          DocumentSystemIdentifier = o.DocumentSystemIdentifier,
                                          TypeCode = o.TypeCode,
                                          ParentId = o.ParentId,
                                          ParentSourceName = _context.DigitalObjectDrafts
                                                                     .Where(po => po.Id == o.ParentId)
                                                                     .Select(po => po.SourceName).First()
                                      });
            }
            else
            {
                var inventorySystemIdentifier = _context.Inventories.Where(i => i.ApplicationId == applicationId).Select(i => i.SystemIdentifier).First();
                derivatives = _context.DigitalObjects
                                      .Where(o => o.InventorySystemIdentifier == inventorySystemIdentifier && o.TypeCode == (int)DigitalObjectType.DerivativeFile && !o.Deleted)
                                      .Select(o => new PackageDocumentDisplayModel()
                                      {
                                          Id = o.Id,
                                          FileName = o.SourceName,
                                          FileId = o.SystemIdentifier.ToString(),
                                          FileSize = o.FileSize,
                                          DocumentSystemIdentifier = o.DocumentSystemIdentifier,
                                          TypeCode = o.TypeCode,
                                          ParentId = o.ParentId,
                                          ParentSourceName = _context.DigitalObjects
                                                                     .Where(po => po.Id == o.ParentId)
                                                                     .Select(po => po.SourceName).First()
                                      });
            }

            var finalResult = await result.FirstOrDefaultAsync();
            if (finalResult != null)
            {
                var finalPackageB = new List<PackageDocumentDisplayModel>();
                if (finalResult.PackageB != null)
                {
                    finalPackageB.AddRange(finalResult.PackageB.ToList());
                }
                foreach (var item in derivatives)
                {
                    if (finalPackageB.Any(f => f.FileName == item.ParentSourceName))
                    {
                        finalPackageB.Add(item);
                    }
                }
                finalResult.PackageB = finalPackageB.OrderBy(x => x.TypeCode).ThenBy(x => x.Id).ThenBy(x => x.ParentId);
            }

            return finalResult;
        }

        public IQueryable<PackageDocumentDisplayModel> GetPackageBById(int packageId)
        {
            var result = from x in _context.PackageDocuments
                         where x.PackageId == packageId
                         && !x.Deleted
                         select new PackageDocumentDisplayModel()
                         {
                             Id = x.Id,
                             Description = x.Description,
                             FileName = x.FileName,
                             FileId = x.FileId,
                             FileSize = x.FileSizeInBytes,
                             DocumentSystemIdentifier = x.DigitalObjectDrafts.Select(d => d.DocumentSystemIdentifier).FirstOrDefault(),
                             TypeCode = x.DigitalObjectDrafts.Select(d => d.TypeCode).FirstOrDefault(),
                         };

            bool isDraft = !_context.Inventories.Any(i => i.PackageBid == packageId);
            IEnumerable<PackageDocumentDisplayModel> derivatives;
            if (isDraft)
            {
                var inventoryDraftId = _context.InventoryDrafts.Where(i => i.PackageBid == packageId).Select(i => i.Id).First();
                derivatives = _context.DigitalObjectDrafts
                                      .Where(o => o.InventoryDraftId == inventoryDraftId && o.TypeCode == (int)DigitalObjectType.DerivativeFile && !o.Deleted)
                                      .Select(o => new PackageDocumentDisplayModel()
                                      {
                                          Id = o.Id,
                                          FileName = o.SourceName,
                                          FileId = o.SystemIdentifier.ToString(),
                                          FileSize = o.FileSize,
                                          DocumentSystemIdentifier = o.DocumentSystemIdentifier,
                                          TypeCode = o.TypeCode,
                                          ParentId = o.ParentId,
                                          ParentSourceName = _context.DigitalObjectDrafts
                                                                     .Where(po => po.Id == o.ParentId)
                                                                     .Select(po => po.SourceName).First()
                                      });
            }
            else
            {
                var inventorySystemIdentifier = _context.Inventories.Where(i => i.PackageBid == packageId).Select(i => i.SystemIdentifier).First();
                derivatives = _context.DigitalObjects
                                      .Where(o => o.InventorySystemIdentifier == inventorySystemIdentifier && o.TypeCode == (int)DigitalObjectType.DerivativeFile && !o.Deleted)
                                      .Select(o => new PackageDocumentDisplayModel()
                                      {
                                          Id = o.Id,
                                          FileName = o.SourceName,
                                          FileId = o.SystemIdentifier.ToString(),
                                          FileSize = o.FileSize,
                                          DocumentSystemIdentifier = o.DocumentSystemIdentifier,
                                          TypeCode = o.TypeCode,
                                          ParentId = o.ParentId,
                                          ParentSourceName = _context.DigitalObjects
                                                                     .Where(po => po.Id == o.ParentId)
                                                                     .Select(po => po.SourceName).First()
                                      });
            }

            var finalResult = new List<PackageDocumentDisplayModel>();

            if (result != null)
            {
                finalResult.AddRange(result.ToList());
            }
            finalResult.AddRange(derivatives.ToList());

            return finalResult.AsQueryable();
        }

        public async Task<IQueryable<ArchivalEntityImportModel>> GetStructureForApplication(int applicationId)
        {
            var result = from a in _context.ArchivalEntityDrafts
                         where a.InventoryDraft.ApplicationId == applicationId
                         && !a.Deleted
                         && !a.InventoryDraft.Deleted
                         select new ArchivalEntityImportModel()
                         {
                             SystemIdentifier = a.SystemIdentifier,
                             NumberArray = a.NumberArray,
                             NumberNumeric = a.NumberNumeric ?? 0,
                             Title = a.Title,
                             Documents = a.DocumentDrafts.Select(d => new DocumentImportModel()
                             {
                                 SystemIdentifier = d.SystemIdentifier,
                                 DocumentNumber = CommonHelper.NullableTryParseInt32(d.Number) ?? 0,
                                 Title = d.Title,

                             })
                         };

            return result;
        }

        public async Task<IQueryable<ArchivalEntityImportModel>> GetPackageBStructureForInventory(Guid inventoryId)
        {
            var result = from a in _context.ArchivalEntityDrafts
                         where a.InventoryDraft.SystemIdentifier == inventoryId
                         && a.InventoryDraft.IsCurrent
                         && !a.InventoryDraft.Deleted
                         && !a.Deleted
                         && !a.InventoryDraft.Deleted
                         select new ArchivalEntityImportModel()
                         {
                             SystemIdentifier = a.SystemIdentifier,
                             Title = a.Title,
                             NumberNumeric = a.NumberNumeric.Value,
                             NumberArray = a.NumberArray,
                             Documents = a.DocumentDrafts.Select(d => new DocumentImportModel()
                             {
                                 SystemIdentifier = d.SystemIdentifier,
                                 Title = d.Title,
                             })
                         };

            return result;
        }

        public async Task<PackageDocument?> GetPackageDocument(int id)
        {
            return await _context.PackageDocuments.SingleOrDefaultAsync(x => x.Id == id && !x.Deleted);
        }

        public IQueryable<PackageDocumentDisplayModel> GetPackageDocumentsById(int id, bool? hasTemplate = null)
        {
            var result = from x in _context.PackageDocuments
                         where x.PackageId == id
                         && !x.Deleted
                         && (!hasTemplate.HasValue || (hasTemplate.Value && x.DocTypeId.HasValue))
                         select new PackageDocumentDisplayModel()
                         {
                             Id = x.Id,
                             Description = x.Description,
                             DocumentTypeId = x.DocTypeId,
                             DocumentType = x.DocTypeId.HasValue ? x.DocType.Title : String.Empty,
                             FileName = x.FileName,
                             FileId = x.FileId,
                             CreatedOn = x.CreatedOn,
                             CreatedByDisplayName = x.CreatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == x.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName ?? String.Empty,
                             CreatedByUserName = x.CreatedByNavigation.UserName,
                             FileSize = x.FileSizeInBytes,
                             FileTypeName = x.FileName != null ? Path.GetExtension(x.FileName).Substring(1) : String.Empty,
                             FileSizeInMB = x.FileSizeInBytes.HasValue ? MathF.Round((x.FileSizeInBytes.Value / 1024f) / 1024f, 2) : null,
                             IsSigned = _context.SignatureRequests.Where(s => s.PackageDocumentId == x.Id && s.PackageId == x.PackageId && s.Completed).Any(),
                             UpdatedOn = x.UpdatedOn,
                             UpdateOrCreateDate = x.UpdatedOn != null ? x.UpdatedOn : x.CreatedOn,
                         };

            return result;
        }

        IQueryable<PackageDocument> IPackagesServiceBase.GetPackageDocumentsByIdInternal(int id)
        {
            var result = _context.PackageDocuments.Where(pd => pd.PackageId == id && !pd.Deleted);
            return result;
        }

        public IQueryable<PackageDocumentDisplayModel> GetPackageDocumentsBySignatureRequest(int packageId, int processId)
        {
            return _context.SignatureRequests
                    .Where(req => req.ProcessId == processId && req.PackageId == packageId && !req.Completed && !req.Deleted)
                    .Select(req => new PackageDocumentDisplayModel()
                    {
                        Id = req.PackageDocument.Id,
                        Description = req.PackageDocument.Description,
                        DocumentTypeId = req.PackageDocument.DocTypeId,
                        DocumentType = req.PackageDocument.DocTypeId.HasValue ? req.PackageDocument.DocType!.Title : String.Empty,
                        FileName = req.PackageDocument.FileName,
                        FileId = req.PackageDocument.FileId!,
                        FileSize = req.PackageDocument.FileSizeInBytes
                    });
        }

        public async Task<bool> HasPackageDocumentsBySignatureRequest(int packageId, int processId)
        {
            return await _context.SignatureRequests
                        .Where(req => req.ProcessId == processId && req.PackageId == packageId && !req.Completed && !req.Deleted)
                        .AnyAsync();
        }

        public async Task<OperationResult> AddSignedPackageDocumentsAsync(IEnumerable<PackageDocumentBaseModel> packageDocuments, int applicationId, int packageId, int processId)
        {
            var transaction = _context.Database.BeginTransaction();
            try
            {
                foreach (var signedDocument in packageDocuments)
                {
                    if (signedDocument.Id != null)
                    {
                        var packageDocumentt = await UpdateFile(signedDocument);
                    }
                    else
                    {
                        var packageDocument = await ((IPackagesServiceBase)this).CreateFileInternal(signedDocument, packageId);
                    }
                }

                await _context.SignatureRequests
                    .Where(req => req.PackageId == packageId && req.ProcessId == processId && !req.Deleted && !req.Completed)
                    .ForEachAsync(req => { req.Completed = true; });

                var application = await _context.EdocsCollectingApplications.Where(app => app.Id == applicationId && !app.Deleted).SingleOrDefaultAsync();
                if (application == null)
                {
                    transaction.Rollback();
                    _logger.LogError($"{nameof(AddSignedPackageDocumentsAsync)}: No application with id {applicationId}");
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                application.StatusId = (int)ApplicationStatus.SignedDocuments;
                _context.Update(application);
                await _context.SaveAsync("Application status updated");

                var stepResult = await _processService.SetActiveProcessStepAsync(processId, (int)ProcessStepType.SignedDocuments);
                if (!stepResult.Succeeded)
                {
                    transaction.Rollback();
                    _logger.LogError(stepResult.ToString());
                    return stepResult;
                }

                int stepId = (int)stepResult.Data!;

                var assignedToId = await _context.Processes.Where(p => p.Id == processId && !p.Deleted && !p.Completed).Select(p => p.CreatedBy).SingleOrDefaultAsync();

                TaskCreateModel taskModel = new()
                {
                    ProcessId = processId,
                    TimelineId = stepId,
                    StepType = ProcessStepType.SignedDocuments,
                    NotificationType = Shared.NotificationType.SignedDocuments,
                    EntityType = BusinessObjectType.EDocsApplication,
                    EntityId = application.Id,
                    AssignedToUserId = assignedToId.Value.ToString("D"),
                };

                var taskResult = await _taskService.CreateAsync(taskModel);
                if (!taskResult.Succeeded)
                {
                    transaction.Rollback();
                    _logger.LogError(taskResult.ToString());
                    return taskResult;
                }

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (FileTypeNotSupportedException exc)
            {
                transaction.Rollback();

                _logger.LogError(exc, "Error adding signed package document");
                return OperationResult.Failed(false, exc.Message);
            }
            catch (CustomException exc)
            {
                transaction.Rollback();

                _logger.LogError(exc, "Error adding signed package document");
                return OperationResult.Failed(false, exc.Message);
            }
            catch (Exception exc)
            {
                transaction.Rollback();

                _logger.LogError(exc, "Error adding signed package document");
                return OperationResult.Failed(exc.ToString());
            }
        }

        async Task<PackageDocument> IPackagesServiceBase.CreateFileInternal(PackageDocumentBaseModel model, int packageId)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            if (model.File == null)
            {
                throw new ArgumentNullException(nameof(model.File));
            }

            PackageDocument doc = new PackageDocument
            {
                PackageId = packageId,
                Description = model.Description,
                DocTypeId = model.DocumentTypeId
            };

            FileModel fileModel = await ParseAttachmentAsync(model.File);

            bool isValidExtension = await _fileUploadAppService.IsFileExtensionValid(fileModel.Name);
            if (!isValidExtension)
            {
                throw new FileTypeNotSupportedException(_localizer.GetString("Error_UnsupportedFileType", fileModel.Type).ToString(), fileModel.Type);
            }

            var result = await _fileService.CreateFileAsync(fileModel, FileStreamLocation.Buffer);
            if (!result.Succeeded)
            {
                throw new Exception(result.ToString());
            }
            string? filePath = result.Data?.ToString();

            doc.FileId = fileModel.SystemName;
            doc.FilePath = filePath;
            doc.FileName = fileModel.Name;
            doc.FileType = fileModel.Type;
            doc.ContentType = fileModel.ContentType;
            doc.FileSizeInBytes = fileModel.Content?.Length;
            doc.FileLocation = (int)FileStreamLocation.Buffer;
            doc.HashCode = FileUtils.ChecksumUtil.Calculate(fileModel.Content!);
            doc.ParentId = model.ParentId.HasValue ? model.ParentId : null;

            _context.PackageDocuments.Add(doc);
            await _context.SaveAsync("Package document created");

            try
            {
                if (!model.SkipValidation)
                {
                    await _fileUploadAppService.ValidateFile(doc.FilePath!, doc.HashCode!, doc);
                }
                else
                {
                    _logger.LogInformation($"Skip validation for file {filePath} ({fileModel.Name})");
                    await _fileUploadAppService.ValidateFile(doc.FilePath!, doc.HashCode!, doc, true);
                }

                return doc;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error on validating package file");
                var errors = new List<string>() { _localizer.GetString("Error_InvalidFile", fileModel.Name) };


                var deleteFileResult = _fileService.DeleteFile(filePath!, FileStreamLocation.Buffer);
                if (!deleteFileResult.Succeeded)
                {
                    errors.Add(deleteFileResult.ToString());
                }

                _logger.LogInformation(deleteFileResult.ToString());
                throw new CustomException(String.Join("; ", errors.ToArray()));
            }
        }

        public async Task<OperationResult> CreateFileAsync(PackageDocumentBaseModel model, int packageId, string? inventoryIdentifier = null)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            if (model.File == null)
            {
                throw new ArgumentNullException(nameof(model.File));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                Package? package = await _context.Packages.Where(x => x.Id == packageId).FirstOrDefaultAsync();
                if (package != null && package.Type.ToUpper() == "A")
                {
                    model.SkipValidation = true;
                }

                if (package != null && package.Type.ToUpper() == PackageType.B)
                {
                    bool existFileWithTheSameName = await _context.PackageDocuments
                                                              .Where(p => p.PackageId == package.Id
                                                                    && p.FileName == model.File.FileName)
                                                              .AnyAsync();
                    if (existFileWithTheSameName)
                    {
                        return OperationResult.Failed(false, $"{_localizer.GetString("Error_FileNameExists")} {model.File.FileName}");
                    }
                }
                var doc = await ((IPackagesServiceBase)this).CreateFileInternal(model, packageId);

                if (model.SignatureFile == true && !String.IsNullOrEmpty(inventoryIdentifier))
                {
                    var inventory = _context.VInventories.Where(i => i.SystemIdentifier == new Guid(inventoryIdentifier)).FirstOrDefault();

                    if (inventory != null)
                    {
                        var currentProcess = await _context.Processes
                          .Where(x => x.InventorySystemIdentifier == inventory.SystemIdentifier && !x.Completed && !x.Deleted)
                          .Include(x => x.ProcessTimelines.Where(t => !t.Completed))
                          .FirstOrDefaultAsync();

                        var currentStep = currentProcess?.ProcessTimelines.FirstOrDefault();

                        SignatureRequest entity = new()
                        {
                            CreatedBy = _userInfo.CurrentUserId.HasValue ? _userInfo.CurrentUserId.Value : Guid.Empty,
                            CreatedOn = DateTime.UtcNow,
                            ArchiveId = inventory!.ArchiveId,
                            ProcessId = currentProcess!.Id,
                            ProcessStepId = currentStep!.Id!,
                            PackageId = packageId,
                            PackageDocumentId = doc.Id,
                            Completed = true,
                            SigningUserId = _userInfo.CurrentUserId.HasValue ? _userInfo.CurrentUserId.Value : Guid.Empty,
                        };

                        _context.SignatureRequests.Add(entity);
                        await _context.SaveAsync("");
                    }
                }


                transaction.Commit();
                return OperationResult.Succeed(doc.PackageId);
            }
            catch (FileTypeNotSupportedException exc)
            {
                transaction.Rollback();

                _logger.LogError(exc, "Error adding signed package document");
                return OperationResult.Failed(false, exc.Message);
            }
            catch (CustomException exc)
            {
                transaction.Rollback();

                _logger.LogError(exc, "Error adding signed package document");
                return OperationResult.Failed(false, exc.Message);
            }
            catch (Exception exc)
            {
                transaction.Rollback();

                _logger.LogError(exc, "Error adding signed package document");
                return OperationResult.Failed(exc.ToString());
            }

        }

        public async Task<OperationResult> CreateFilesAsync(PackageDocumentCreateModel model, int packageId)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            if (model.Files == null)
            {
                throw new ArgumentNullException(nameof(model.Files));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                Package? package = await _context.Packages.Where(x => x.Id == packageId).FirstOrDefaultAsync();
                if (package != null && package.Type.ToUpper() == "A")
                {
                    model.SkipValidation = true;
                }

                foreach (var file in model.Files)
                {
                    if (package != null && package.Type.ToUpper() == PackageType.B)
                    {
                        bool existFileWithTheSameName = await _context.PackageDocuments
                                                                  .Where(p => p.PackageId == package.Id
                                                                        && p.FileName == file.FileName)
                                                                  .AnyAsync();
                        if (existFileWithTheSameName)
                        {
                            return OperationResult.Failed(false, $"{_localizer.GetString($"Error_FileNameExists").ToString()} {file.FileName}");
                        }
                    }

                    PackageDocumentBaseModel baseModel = new()
                    {
                        File = file,
                        Description = model.Description,
                        SkipValidation = model.SkipValidation,
                        DocumentTypeId = model.DocumentTypeId,
                        FileName = model.FileName,
                        IsInvaluable = model.IsInvaluable,
                        FileSize = model.FileSize,
                        DocumentSystemIdentifier = model.DocumentSystemIdentifier,
                        Id = model.Id,
                    };
                    await ((IPackagesServiceBase)this).CreateFileInternal(baseModel, packageId);
                }

                transaction.Commit();
                return OperationResult.Succeed(packageId);
            }
            catch (FileTypeNotSupportedException exc)
            {
                transaction.Rollback();

                _logger.LogError(exc, "Error adding signed package document");
                return OperationResult.Failed(false, exc.Message);
            }
            catch (CustomException exc)
            {
                transaction.Rollback();

                _logger.LogError(exc, "Error adding signed package document");
                return OperationResult.Failed(false, exc.Message);
            }
            catch (Exception exc)
            {
                transaction.Rollback();

                _logger.LogError(exc, "Error adding signed package document");
                return OperationResult.Failed(exc.ToString());
            }

        }

        public async Task<PackageDocument> UpdateFile(PackageDocumentBaseModel model)
        {
            PackageDocument? doc = await _context.PackageDocuments.FindAsync(model.Id);

            if (doc == null)
            {
                throw new NullReferenceException($"Package document {model.Id} not found");
            }

            doc.Description = model.Description;

            if (model.File != null)
            {
                FileModel fileModel = await ParseAttachmentAsync(model.File);

                bool isValidExtension = await _fileUploadAppService.IsFileExtensionValid(fileModel.Name);
                if (!isValidExtension)
                {
                    throw new FileTypeNotSupportedException(_localizer.GetString("Error_UnsupportedFileType", fileModel.Type).ToString());
                }

                //Delete old file 
                var deleteResult = _fileService.DeleteFile(doc.FilePath, FileStreamLocation.Buffer);
                if (!deleteResult.Succeeded)
                {
                    _logger.LogError(deleteResult.ToString());
                    throw new Exception($"Can not delete old package file {doc.FilePath}");
                }

                //add new file
                var result = await _fileService.CreateFileAsync(fileModel, FileStreamLocation.Buffer);
                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    throw new Exception(result.ToString());
                }
                string? filePath = result.Data?.ToString();

                doc.FileId = fileModel.SystemName;
                doc.FilePath = filePath;
                doc.FileName = fileModel.Name;
                doc.FileType = fileModel.Type;
                doc.ContentType = fileModel.ContentType;
                doc.FileSizeInBytes = fileModel.Content?.Length;
                doc.FileLocation = (int)FileStreamLocation.Buffer;
            }

            else if (model._deleted)
            {
                //Delete old file 
                var result = _fileService.DeleteFile(doc.FilePath, FileStreamLocation.Buffer);

                if (!result.Succeeded)
                {
                    _logger.LogError(result.ToString());
                    throw new Exception($"Can not delete old package file {doc.FilePath}");
                }
                doc.Deleted = true;

                if (doc.ParentId == null)
                {
                    PackageDocument? docDerivativefile = await _context.PackageDocuments.Where(p => p.ParentId == doc.Id).FirstOrDefaultAsync();

                    if (docDerivativefile != null)
                    {
                        _fileService.DeleteFile(docDerivativefile.FilePath, FileStreamLocation.Buffer);

                        docDerivativefile.Deleted = true;
                    }
                }
            }

            await _context.SaveAsync("Package file/files updated");
            return doc;
        }

        public async Task RemovePackageAFile(PackageDocumentBaseModel model)
        {
            PackageDocument? doc = await _context.PackageDocuments.FindAsync(model.Id);

            if (doc == null)
            {
                throw new NullReferenceException($"Package document {model.Id} not found");
            }

            doc.Deleted = true;

            //doc.Description = model.Description;

            //if (model.File != null)
            //{
            //    FileModel fileModel = await ParseAttachmentAsync(model.File);

            //    bool isValidExtension = FileUtils.ValidateUtil.IsFileExtensionValid(fileModel.Name);
            //    if (!isValidExtension)
            //    {
            //        throw new Exception(_localizer.GetString("Error_UnsupportedFileType", fileModel.Type).ToString());
            //    }

            //    var result = await _fileService.CreateFileAsync(fileModel, FileStreamLocation.Buffer);
            //    if (!result.Succeeded)
            //    {
            //        throw new Exception(result.ToString());
            //    }
            //    string? filePath = result.Data?.ToString();

            //    doc.FileId = fileModel.SystemName;
            //    doc.FilePath = filePath;
            //    doc.FileName = fileModel.Name;
            //    doc.FileType = fileModel.Type;
            //    doc.ContentType = fileModel.ContentType;
            //    doc.FileSizeInBytes = fileModel.Content?.Length;
            //    doc.FileLocation = (int)FileStreamLocation.Buffer;
            //}

            //_context.PackageDocuments.Remove(doc);
            await _context.SaveAsync("Film package document created");
        }

        public async Task<int?> GetPackageIdAByProcess(int processId)
        {
            var process = await _context.Processes.FindAsync(processId);

            if (process.FundSystemIdentifier.HasValue)
            {
                return await (from i in _context.InventoryDrafts
                              where i.FundSystemIdentifier == process.FundSystemIdentifier && i.IsCurrent && i.PackageAid != null
                              select i.PackageAid).FirstOrDefaultAsync();
            }
            else if (process.InventorySystemIdentifier.HasValue)
            {
                return await (from i in _context.InventoryDrafts
                              where i.SystemIdentifier == process.InventorySystemIdentifier && i.IsCurrent
                              select i.PackageAid).SingleOrDefaultAsync();
            }

            return null;
        }

        public async Task<int?> GetPackageIdByApplication(int applicationId, string packageType)
        {
            int? packageId = null;

            var query = _context.VInventories.Where(inv => inv.ApplicationId == applicationId && !inv.Deleted);
            switch (packageType)
            {
                case PackageType.A:
                    packageId = await query.Select(inv => inv.PackageAid).SingleOrDefaultAsync();
                    break;
                case PackageType.B:
                    packageId = await query.Select(inv => inv.PackageBid).SingleOrDefaultAsync();
                    break;
                    //TODO: Add to view
                    //case PackageType.C:
                    //    packageId = await query.Select(inv => inv.PackageCid).SingleOrDefaultAsync();
                    //    break;
            }
            return packageId;
        }
        public async Task<OperationResult> RemoveFileFromPackageAsync(int id)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var result = await RemoveFileFromPackage(id);

                if (!result.Succeeded)
                {
                    transaction.Rollback();
                }

                transaction.Commit();

                return OperationResult.Succeed(result);
            }
            catch (ItemNotFoundException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }
        public async Task<OperationResult> RemoveFileFromPackage(int id)
        {
            try
            {
                var packageFile = await _context.PackageDocuments.FindAsync(id);

                if (packageFile != null)
                {
                    bool isCommissionReportFile = await _context.CommissionReportFiles
                                                        .Where(cF => cF.UncPath == packageFile.FilePath)
                                                        .AnyAsync();

                    var packageType = await _context.Packages
                                                .Where(p => p.Id == packageFile.PackageId)
                                                .Select(p => p.Type)
                                                .FirstOrDefaultAsync();

                    if (isCommissionReportFile && packageType == PackageType.A)
                    {
                        return OperationResult.Failed(_localizer.GetString("Error_PackageFileIsFromReport").ToString());
                    }
                    else
                    {
                        packageFile.Deleted = true;
                        await _context.SaveAsync("");
                    }
                }

                List<DigitalObjectDraft> digitalObjectDrafts = await _context.DigitalObjectDrafts
                    .Where(x => x.PackageDocumentId == id && x.IsCurrent == true && !x.Deleted)
                    .ToListAsync();

                foreach (DigitalObjectDraft digObject in digitalObjectDrafts)
                {
                    var digitalObjectDraft = await _context.DigitalObjectDrafts.FindAsync(digObject.Id);
                    if (digitalObjectDraft == null)
                    {
                        throw new ItemNotFoundException(_localizer.GetString("Error_ItemDoesNotExists").ToString(), id.ToString());
                    }

                    // Delete file
                    OperationResult result = _fileService.DeleteFile(digitalObjectDraft.UncPath, FileStreamLocation.Buffer);
                    if (!result.Succeeded)
                    {
                        throw new Exception(String.Join("; ", result.Errors));
                    }

                    digitalObjectDraft.IsCurrent = false;
                    digitalObjectDraft.Deleted = true;
                    digitalObjectDraft.DeletedOn = DateTime.UtcNow;
                    digitalObjectDraft.DeletedBy = _userInfo.CurrentUserId;

                    _context.Update(digitalObjectDraft);

                    await _context.SaveAsync("Digital object draft deleted");
                }
                return OperationResult.Succeed(id);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Error removing package document {id}");
                return OperationResult.Failed(ex.Message.ToString());
            }


        }

        public async Task<OperationResult> UnitePackagesIntoNewPackageAsync(List<int>? packageIds, FileStreamLocation locationToCopyTo, string newPackageType)
        {
            if (packageIds == null || packageIds.Count == 0)
            {
                return OperationResult.Success;
            }

            Package package = new Package { Type = newPackageType };
            _context.Packages.Add(package);
            await _context.SaveAsync("Created united package");

            var docs = await _context.PackageDocuments
                .Where(x => packageIds.Contains(x.PackageId) && !x.Deleted)
                .ToListAsync();

            foreach (var doc in docs)
            {
                await doCreateDocCopy(doc, package.Id, locationToCopyTo);
            }

            await _context.SaveAsync("Packages united");
            return OperationResult.Succeed(package);
        }

        private async Task<PackageDocument> doCreateDocCopy(PackageDocument doc, int destinationPackageId, FileStreamLocation locationToCopyTo)
        {
            var newDoc = new PackageDocument
            {
                PackageId = destinationPackageId,
                Description = doc.Description,
                DocTypeId = doc.DocTypeId,
                FileName = doc.FileName,
                FileType = doc.FileType,
                ContentType = doc.ContentType,
                FileSizeInBytes = doc.FileSizeInBytes,
                FileLocation = (int)locationToCopyTo,
            };

            FileModel? fileModel = null;
            if (doc != null && !String.IsNullOrWhiteSpace(doc.FilePath))
            {
                FileStreamLocation location = doc.FileLocation != null ? (FileStreamLocation)doc.FileLocation : FileStreamLocation.Buffer;
                fileModel = await _fileService.GetFileAsync(doc.FilePath, location);
                fileModel!.ContentType = doc.ContentType!;
                fileModel!.Name = doc.FileName!;
            }

            if (fileModel != null)
            {
                fileModel.SystemName = $"{Guid.NewGuid()}.{fileModel.Type}";
                newDoc.FileId = fileModel.SystemName;

                var result = await _fileService.CreateFileAsync(fileModel, locationToCopyTo);
                if (!result.Succeeded)
                {
                    throw new Exception(result.ToString());
                }
                newDoc.FilePath = result.Data?.ToString();
            }

            _context.PackageDocuments.Add(newDoc);

            return newDoc;
        }

        async Task<int> IPackagesServiceBase.CreatePackageInternalAsync(string packageType, Guid inventorySysId)
        {
            if (!packageType.Equals("A", StringComparison.OrdinalIgnoreCase)
                && !packageType.Equals("B", StringComparison.OrdinalIgnoreCase)
                && !packageType.Equals("C", StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidDataException($"Invalid package type {packageType}");
            }

            var inventory = await _context.Inventories
                            .Where(inv => inv.SystemIdentifier == inventorySysId && !inv.Deleted)
                            .SingleOrDefaultAsync();
            if (inventory == null)
            {
                throw new ItemNotFoundException("Inventory not found", inventorySysId.ToString("D"));
            }

            bool packageExists = false;
            switch (packageType)
            {
                case "A":
                    packageExists = inventory.PackageAid != null;
                    break;
                case "B":
                    packageExists = inventory.PackageBid != null;
                    break;
                case "C":
                    packageExists = inventory.PackageCid != null;
                    break;
            }

            if (packageExists)
            {
                throw new Exception($"Package with type {packageType} for inventory {inventorySysId} already exists");
            }

            var package = new Package()
            {
                InventoryIdentifier = inventorySysId,
                Type = packageType,
            };

            _context.Packages.Add(package);
            await _context.SaveAsync("Package created");

            switch (packageType)
            {
                case "A":
                    inventory.PackageAid = package.Id;
                    break;
                case "B":
                    inventory.PackageBid = package.Id;
                    break;
                case "C":
                    inventory.PackageCid = package.Id;
                    break;
            }

            _context.Update(inventory);
            await _context.SaveAsync("Inventory updated");

            return package.Id;
        }

        public async Task<OperationResult> CreatePackageAsync(string packageType, Guid inventorySysId)
        {
            var transaction = _context.Database.BeginTransaction();
            try
            {
                var packageId = await ((IPackagesServiceBase)this).CreatePackageInternalAsync(packageType, inventorySysId);
                transaction.Commit();
                return OperationResult.Succeed(packageId);
            }
            catch (Exception ex)
            {
                transaction.Rollback();
                return OperationResult.Failed(ex.ToString());
            }
        }

        public async Task<int> CopyPackageAsync(int sourcePackageId)
        {
            var package = await _context.Packages.Where(x => x.Id == sourcePackageId).SingleOrDefaultAsync();
            if (package == null)
            {
                throw new ItemNotFoundException("Package not found", sourcePackageId.ToString());
            }

            var newPackage = new Package()
            {
                Type = package.Type,
            };

            _context.Packages.Add(newPackage);
            await _context.SaveAsync("Package created");


            // copy files
            var docs = await _context.PackageDocuments
                .Where(x => x.PackageId == sourcePackageId && !x.Deleted)
                .ToListAsync();

            foreach (var doc in docs)
            {
                var newDoc = new PackageDocument
                {
                    PackageId = newPackage.Id,
                    Description = doc.Description,
                    DocTypeId = doc.DocTypeId,
                    CreatedOn = doc.CreatedOn,
                    CreatedBy = doc.CreatedBy,
                    FileName = doc.FileName,
                    FileType = doc.FileType,
                    ContentType = doc.ContentType,
                    FileSizeInBytes = doc.FileSizeInBytes,
                    FileLocation = doc.FileLocation,
                    ChecksumCheckResult = doc.ChecksumCheckResult,
                    FileFormatCheckResult = doc.FileFormatCheckResult,
                    AntivirusCheckResult = doc.AntivirusCheckResult,
                    AntivirusCheckInfo = doc.AntivirusCheckInfo,
                    FileInfo = doc.FileInfo,
                    ErrorMessage = doc.ErrorMessage,
                    IsInvaluable = doc.IsInvaluable
                };

                FileStreamLocation location = doc.FileLocation != null ? (FileStreamLocation)doc.FileLocation : FileStreamLocation.Buffer;
                var fileModel = await _fileService.GetFileAsync(doc.FilePath, location);
                if (fileModel != null)
                {
                    fileModel.ContentType = doc.ContentType!;
                    fileModel.Name = doc.FileName!;
                    fileModel.SystemName = $"{Guid.NewGuid()}.{fileModel.Type}";
                    newDoc.FileId = fileModel.SystemName;

                    var result = await _fileService.CreateFileAsync(fileModel, location);
                    if (!result.Succeeded)
                    {
                        throw new Exception(result.ToString());
                    }
                    newDoc.FilePath = result.Data?.ToString();
                    newDoc.HashCode = String.IsNullOrWhiteSpace(doc.HashCode) ? FileUtils.ChecksumUtil.Calculate(fileModel.Content!) : doc.HashCode!;
                }

                _context.PackageDocuments.Add(newDoc);
            }

            await _context.SaveAsync("Package documents copied");

            return newPackage.Id;
        }

        public async Task<OperationResult> DeletePackageAsync(int packageId)
        {
            try
            {
                var package = await _context.Packages.FindAsync(packageId);
                if (package == null)
                {
                    return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                package.Deleted = true;
                package.DeletedOn = DateTime.UtcNow;
                package.DeletedBy = _userInfo.CurrentUserId;

                _context.Update(package);

                var docs = _context.PackageDocuments.Where(x => x.PackageId == packageId && !x.Deleted).Select(x => x);

                await docs.ForEachAsync(async x =>
                {
                    x.Deleted = true;
                    x.DeletedBy = _userInfo.CurrentUserId;
                    x.DeletedOn = DateTime.UtcNow;

                    if (!String.IsNullOrWhiteSpace(x.FilePath) && x.FileLocation != null)
                    {
                        _fileService.DeleteFile(x.FilePath, (FileStreamLocation)x.FileLocation.Value);
                    }
                });

                await _context.SaveAsync("Package deleted");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<List<PackageDocumentDisplayModel>> GetAvailablePackageDocumentsForArchivalEntity(Guid? inventorySystemIdentifier, int packageId)
        {
            var result = await GetAvailableRawPackageDocuments(inventorySystemIdentifier, packageId)
                .Select(x => new PackageDocumentDisplayModel()
                {
                    Id = x.Id,
                    Description = x.Description,
                    DocumentTypeId = x.DocTypeId,
                    DocumentType = x.DocType != null ? x.DocType.Title : String.Empty,
                    FileName = x.FileName,
                    FileId = x.FileId!,
                    FileSize = x.FileSizeInBytes,
                    IsInvaluable = x.IsInvaluable,
                })
                .ToListAsync();

            return result;
        }

        public IQueryable<PackageDocument> GetAvailableRawPackageDocuments(Guid? inventorySystemIdentifier, int packageId)
        {
            var result = _context.PackageDocuments
                .Where(x => x.PackageId == packageId
                    && !x.Deleted
                    && !x.DigitalObjectDrafts.Where(d => d.InventorySystemIdentifier == inventorySystemIdentifier && !d.Deleted).Any())
                .AsQueryable();

            return result;
        }

        async Task<OperationResult> IPackagesServiceBase.AddPackageFileInternalAsync(IFormFile content, int packageId, FileStreamLocation location)
        {
            if (content == null)
            {
                throw new ArgumentNullException(nameof(content));
            }

            string? uncFilePath = String.Empty;

            try
            {
                FileModel fileModel = await ParseAttachmentAsync(content);
                var createFileResult = await _fileService.CreateFileAsync(fileModel, location);
                if (!createFileResult.Succeeded)
                {
                    return createFileResult;
                }

                uncFilePath = createFileResult.Data?.ToString();

                var packageFile = new PackageDocument()
                {
                    PackageId = packageId,
                    ContentType = fileModel.ContentType,
                    FileType = fileModel.Type,
                    FileId = fileModel.SystemName,
                    FileName = fileModel.Name,
                    FileLocation = (int)location,
                    FilePath = uncFilePath!,
                    FileSizeInBytes = fileModel.Size,
                };

                _context.PackageDocuments.Add(packageFile);
                await _context.SaveAsync("Package document added");

                return OperationResult.Succeed(uncFilePath!);
            }
            catch (Exception exc)
            {
                if (!string.IsNullOrEmpty(uncFilePath))
                {
                    _fileService.DeleteFile(uncFilePath, location);
                }
                return OperationResult.Failed(exc.ToString());
            }
        }

        async Task<OperationResult> IPackagesServiceBase.AddPackageFilesInternalAsync(IEnumerable<IFormFile> contents, int packageId)
        {
            if (contents == null || !contents.Any())
            {
                throw new ArgumentNullException(nameof(contents));
            }

            try
            {
                var packageType = await _context.Packages
                                    .Where(p => p.Id == packageId && !p.Deleted)
                                    .Select(p => p.Type)
                                    .SingleOrDefaultAsync();
                if (string.IsNullOrEmpty(packageType))
                {
                    throw new InvalidDataException(nameof(packageType));
                }

                var fileLocation = packageType.Equals("C", StringComparison.OrdinalIgnoreCase) ? FileStreamLocation.Adjunct : FileStreamLocation.Buffer;

                foreach (var content in contents)
                {
                    var createFileResult = await ((IPackagesServiceBase)this).AddPackageFileInternalAsync(content, packageId, fileLocation);
                    if (!createFileResult.Succeeded)
                    {
                        return createFileResult;
                    }
                }
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> AddPackageFilesAsync(IEnumerable<IFormFile> contents, int? packageId, string? packageType, Guid? inventorySysId)
        {
            if (contents == null || !contents.Any())
            {
                throw new ArgumentNullException(nameof(contents));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                if (!packageId.HasValue)
                {
                    packageId = await GetPackageIdByInventory(packageType!, inventorySysId!.Value);
                }

                if (!packageId.HasValue)
                {
                    packageId = await ((IPackagesServiceBase)this).CreatePackageInternalAsync(packageType!, inventorySysId!.Value);
                }

                var result = await ((IPackagesServiceBase)this).AddPackageFilesInternalAsync(contents, packageId!.Value);
                if (!result.Succeeded)
                {
                    return result;
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

        public async Task<OperationResult> DeletePackageFileAsync(int id, int packageId)
        {
            var transaction = _context.Database.BeginTransaction();
            try
            {
                var packageDocument = await _context.PackageDocuments
                                        .Where(doc => doc.Id == id && doc.PackageId == packageId && !doc.Deleted)
                                        .SingleOrDefaultAsync();

                if (packageDocument == null)
                {
                    transaction.Rollback();
                    return OperationResult.Failed($"Package document {id} does not exists in package {packageId}");
                }

                var fileDeleteResult = _fileService.DeleteFile(packageDocument.FilePath!, (FileStreamLocation)packageDocument.FileLocation!);
                if (!fileDeleteResult.Succeeded)
                {
                    transaction.Rollback();
                    return fileDeleteResult;
                }

                packageDocument.Deleted = true;
                packageDocument.DeletedBy = _userInfo.CurrentUserId;
                packageDocument.DeletedOn = DateTime.UtcNow;

                _context.Update(packageDocument);
                await _context.SaveAsync("Package document deleted");

                transaction.Commit();
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }

        }

        public async Task<int?> GetPackageIdByInventory(string packageType, Guid inventorySysId)
        {
            if (!packageType.Equals("A", StringComparison.OrdinalIgnoreCase)
                && !packageType.Equals("B", StringComparison.OrdinalIgnoreCase)
                && !packageType.Equals("C", StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidDataException($"Invalid package type {packageType}");
            }

            int? packageId = null;

            switch (packageType)
            {
                case "A":
                    packageId = await _context.VInventories
                            .Where(inv => inv.SystemIdentifier == inventorySysId && !inv.Deleted)
                            .Select(inv => inv.PackageAid)
                            .SingleOrDefaultAsync();
                    break;
                case "B":
                    packageId = await _context.VInventories
                            .Where(inv => inv.SystemIdentifier == inventorySysId && !inv.Deleted)
                            .Select(inv => inv.PackageBid)
                            .SingleOrDefaultAsync();
                    break;
                case "C":
                    packageId = await _context.Inventories
                            .Where(inv => inv.SystemIdentifier == inventorySysId && !inv.Deleted)
                            .Select(inv => inv.PackageCid)
                            .SingleOrDefaultAsync();
                    break;
            }

            return packageId;
        }

        public async Task<bool> PackageHasAnyDocumentsAsync(int packageId)
        {
            return await _context.PackageDocuments.Where(pd => pd.PackageId == packageId && !pd.Deleted).AnyAsync();
        }

        public async Task<bool> PackageHasRequiredDocumentsAsync(int packageId, Shared.ProcessType processType)
        {
            var hasNotAllRequired = await _context.PackageAdocsTemplates
                                        .Where(templ => templ.ProcedureId == (int)processType
                                                && templ.Required
                                                && !templ.Deleted
                                                && !templ.PackageDocuments.Where(pd => pd.PackageId == packageId && !pd.Deleted).Any())
                                        .AnyAsync();
            return !hasNotAllRequired;
        }
    }
}
