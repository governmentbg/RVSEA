using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Models.Processes;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using System.Text;

namespace DAA.Services.Process
{
    public class ProcessService : BaseService, IProcessService
    {
        private readonly IUserInfo _userInfo;

        public ProcessService(
             ArchivingContext context,
             IStringLocalizer<SharedResources> localizer,
             ILogger<ProcessService> logger,
             IUserInfo userInfo)
             : base(context, localizer, logger)
        {
            _userInfo = userInfo;
        }

        public async Task<OperationResult> StartProcessAsync(ProcessModel model)
        {
            try
            {
                if (GetEntitySystemIdentifier(model) == Guid.Empty)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_CannotStartProcess", _localizer.GetString("Error_ExternalSourceDataOnly")).ToString());
                }
                if (await HasCurrentActiveProcess(model))
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_EntityAlreadyHasProcess").ToString());
                }
                if (!await HasValidEntityStatus(model))
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_InvalidEntityStatus").ToString());
                }

                Data.Process newProcess = await CreateProcessAsync(model);

                return OperationResult.Succeed(newProcess.Id);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<Data.Process> CreateProcessAsync(ProcessModel model)
        {
            Data.Process newProcess = new Data.Process
            {
                ProcessTypeId = model.ProcessTypeId!.Value,
                ArchiveId = model.ArchiveId,
                FilmSystemIdentifier = model.FilmSystemIdentifier,
                DocumentSystemIdentifier = model.DocumentSystemIdentifier,
                ArchivalEntitySystemIdentifier = model.ArchivalEntitySystemIdentifier,
                InventorySystemIdentifier = model.InventorySystemIdentifier,
                FundSystemIdentifier = model.FundSystemIdentifier,
                Completed = false
            };


            _context.Processes.Add(newProcess);
            await _context.SaveAsync($"Process created");
            return newProcess;
        }

        public async Task<Data.ProcessTimeline> AddStepAsync(int processId, int stepType)
        {
            ProcessTimeline step = new ProcessTimeline
            {
                ProcessId = processId,
                StepTypeId = stepType,
            };

            _context.ProcessTimelines.Add(step);
            await _context.SaveAsync($"Process step created");
            return step;
        }

        public async Task<OperationResult> CompleteProcessAsync(int processId)
        {
            try
            {
                var processStep =
                    await _context.ProcessTimelines
                    .Where(step => step.ProcessId == processId && !step.Completed)
                    .SingleOrDefaultAsync();
                if (processStep != null)
                {
                    processStep.Completed = true;
                    _context.Update(processStep);
                }

                var process = await _context.Processes.FindAsync(processId);
                if (process == null)
                {
                    return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                process.Completed = true;
                _context.Update(process);

                await _context.SaveAsync("Process completed");
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
            return OperationResult.Success;
        }

        public async Task<OperationResult> SetActiveProcessStepAsync(int processId, int stepTypeId)
        {
            try
            {
                var processStep =
                    await _context.ProcessTimelines
                    .Where(step => step.ProcessId == processId && !step.Completed)
                    .SingleOrDefaultAsync();
                if (processStep != null)
                {
                    processStep.Completed = true;
                    _context.Update(processStep);
                }

                processStep = new ProcessTimeline()
                {
                    ProcessId = processId,
                    StepTypeId = stepTypeId,
                    Completed = false,
                };
                _context.ProcessTimelines.Add(processStep);
                await _context.SaveAsync("Active process step set");

                return OperationResult.Succeed(processStep.Id);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> SetActiveProcessStepAsync(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                var processStep =
                    await _context.ProcessTimelines
                    .Where(step => step.ProcessId == model.ProcessId && !step.Completed)
                    .SingleOrDefaultAsync();
                if (processStep != null)
                {
                    processStep.Completed = true;
                    _context.Update(processStep);
                }

                processStep = new ProcessTimeline()
                {
                    ProcessId = model.ProcessId,
                    StepTypeId = model.StepTypeId,
                    AssignedToRoleId = model.AssignedToRoleId,
                    AssignedToUserId = model.AssignedToUserId,
                    Comment = model.Comment,
                    EndDate = model.EndDate,
                    Completed = false,
                };
                _context.ProcessTimelines.Add(processStep);
                await _context.SaveAsync("Active process step set");

                return OperationResult.Succeed(processStep.Id);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }

        }

        public async Task<OperationResult> MoveToNextStep(ProcessStepModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                var processTypeId = await _context.Processes.Where(x => x.Id == model.ProcessId)
                                                            .Select(x => x.ProcessTypeId)
                                                            .SingleOrDefaultAsync();
                var step = await (from t in _context.ProcessTimelines
                                  let s = t.StepType.ProcessRelatedStepSteps.Where(x => x.ProcessTypeId == processTypeId).FirstOrDefault()
                                  where t.ProcessId == model.ProcessId
                                  && !t.Completed
                                  select s).SingleOrDefaultAsync();


                if (step != null && step.NextStepId.HasValue)
                {
                    model.StepTypeId = step.NextStepId.Value;
                    var nextStepResult = await SetActiveProcessStepAsync(model);
                    if (!nextStepResult.Succeeded)
                    {
                        _logger.LogError(nextStepResult.ToString());
                        return nextStepResult;
                    }

                    //TODO Notifications 

                    //return OperationResult.Succeed(step.NextStepId.Value);
                    return OperationResult.Succeed(nextStepResult.Data!);
                }

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                _logger.LogError(exc, "Error moving to next process step.");
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<List<ProcessTimelineModel>> GetTimelineAsync(int processId)
        {
            var result = await
                _context.ProcessTimelines
                //.Include(x => x.StepType)
                //.Include(x => x.CreatedByNavigation)
                //.Include(x => x.AssignedToUser)
                //.Include(x => x.AssignedToRole)
                .Where(x => x.ProcessId == processId)
                .Select(x => new ProcessTimelineModel()
                {
                    Id = x.Id,
                    ProcessId = x.ProcessId,
                    StepTypeId = x.StepTypeId,
                    StepTypeName = x.StepType != null ? x.StepType.Text : null,
                    Completed = x.Completed,
                    CreatedBy = x.CreatedBy,
                    CreatedByDisplayName = x.CreatedByNavigation != null ? x.CreatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == x.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName : null,
                    CreatedByUserName = x.CreatedByNavigation != null ? x.CreatedByNavigation.UserName : null,
                    CreatedOn = x.CreatedOn.UtcToLocalTime(),
                    Comment = x.Comment,
                    AssignedToUserId = x.AssignedToUserId.ToString(),
                    AssignedToUserName = x.AssignedToUser != null ? x.AssignedToUser.UserName : null,
                    AssignedToUserDisplayName = x.AssignedToUser != null ? x.AssignedToUser.AspNetUserProfileUsers.Where(up => up.UserId == x.AssignedToUserId && !up.Deleted).FirstOrDefault().DisplayName : null,
                    AssignedToRoleName = x.AssignedToRole != null ? x.AssignedToRole.Name : null,
                    EndDate = x.EndDate.HasValue ? x.EndDate.UtcToLocalTime() : null,
                })
                .ToListAsync();



            return result;
        }

        public async Task<ProcessTimelineModel?> GetActiveProcessStepAsync(int processId)
        {
            var currentStep = await
                _context.ProcessTimelines
                .Where(ps => ps.ProcessId == processId && !ps.Completed)
                .Select(ps => new ProcessTimelineModel()
                {
                    Id = ps.Id,
                    ProcessId = ps.ProcessId,
                    StepTypeId = ps.StepTypeId,
                    StepTypeName = ps.StepType.Text,
                    Completed = ps.Completed,
                    CreatedBy = ps.CreatedBy,
                    CreatedByDisplayName = ps.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == ps.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = ps.CreatedByNavigation.UserName,
                    CreatedOn = ps.CreatedOn.UtcToLocalTime(),
                    Comment = ps.Comment,
                    AssignedToUserId = ps.AssignedToUserId!.Value.ToString("D"),
                    AssignedToUserName = ps.AssignedToUser!.UserName,
                    AssignedToUserDisplayName = ps.AssignedToUser.AspNetUserProfileUsers.Where(up => up.UserId == ps.AssignedToUserId && !up.Deleted).FirstOrDefault().DisplayName,
                    AssignedToRoleName = ps.AssignedToRole!.Name,
                    EndDate = ps.EndDate.UtcToLocalTime(),
                })
                .SingleOrDefaultAsync();

            return currentStep;
        }

        public async Task<ProcessDisplayModel?> GetProcessAsync(int processId)
        {
            var process = await _context.Processes
                .Where(p => p.Id == processId && !p.Deleted)
                .Select(p => new ProcessDisplayModel()
                {
                    Id = p.Id,
                    ProcessTypeId = p.ProcessTypeId,
                    ProcessTypeTitle = p.ProcessType.Name,
                    ArchiveId = p.ArchiveId,
                    ArchiveName = p.Archive!.Name,
                    CreatedBy = p.CreatedBy,
                    CreatedByDisplayName = p.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = p.CreatedByNavigation.UserName,
                    CreatedOn = p.CreatedOn,
                    Deleted = p.Deleted,
                    DeletedBy = p.DeletedBy,
                    DeletedByDisplayName = p.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    DeletedByUserName = p.DeletedByNavigation.UserName,
                    DeletedOn = p.DeletedOn,
                    FundSystemIdentifier = p.FundSystemIdentifier,
                    InventorySystemIdentifier = p.InventorySystemIdentifier,
                    ArchivalEntitySystemIdentifier = p.ArchivalEntitySystemIdentifier,
                    DocumentSystemIdentifier = p.DocumentSystemIdentifier,
                    FilmSystemIdentifier = p.FilmSystemIdentifier,
                    UpdatedBy = p.UpdatedBy,
                    UpdatedByDisplayName = p.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = p.UpdatedByNavigation!.UserName,
                    UpdatedOn = p.UpdatedOn,
                    Completed = p.Completed,
                })
                .SingleOrDefaultAsync();

            if (process != null)
            {
                var processStep = await GetActiveProcessStepAsync(process.Id!.Value);
                process.ActiveProcessStepId = processStep?.Id;
                process.ActiveProcessStepTypeId = processStep?.StepTypeId;
                process.ActiveProcessStepName = processStep?.StepTypeName;
                if (processStep != null)
                {
                    process.IsCurrentUserInActiveProcessStep = await IsCurrentUserInProcessStepAsync(process.Id.Value, processStep.Id);
                }
            }

            return process;
        }

        public async Task<ProcessStepModel?> GetProcessStepAsync(int stepId)
        {
            var processStep =
                await _context.ProcessTimelines
                .Where(step => step.Id == stepId)
                .Select(step => new ProcessStepModel()
                {
                    Id = step.Id,
                    ProcessId = step.ProcessId,
                    StepTypeId = step.StepTypeId,
                    AssignedToRoleId = step.AssignedToRoleId,
                    AssignedToUserId = step.AssignedToUserId,
                    Comment = step.Comment,
                    EndDate = step.EndDate,
                })
                .SingleOrDefaultAsync();

            return processStep;
        }

        public async Task<ProcessStepModel?> GetProcessStepAsync(int processId, ProcessStepType stepType)
        {
            var processSteps =
                _context.ProcessTimelines
                .Where(step => step.ProcessId == processId && step.StepTypeId == (int)stepType)
                .Select(step => new ProcessStepModel()
                {
                    Id = step.Id,
                    ProcessId = step.ProcessId,
                    StepTypeId = step.StepTypeId,
                    AssignedToRoleId = step.AssignedToRoleId,
                    AssignedToUserId = step.AssignedToUserId,
                    Comment = step.Comment,
                    EndDate = step.EndDate,
                });

            return await processSteps.FirstOrDefaultAsync();
        }

        public async Task<ProcessDisplayModel?> GetCurrentActiveProcess(string entityType, Guid? entitySysId, bool? includeParent = null, int? externalIdentifier = null)
        {
            ProcessDisplayModel? process = null;

            if (externalIdentifier.HasValue && (entitySysId.HasValue && entitySysId.Value == Guid.Empty || !entitySysId.HasValue))
            {
                switch (entityType)
                {
                    case BusinessObjectType.Fund:
                        entitySysId = _context.VFunds.Where(f => f.ExternalIdentifier == externalIdentifier && !f.Deleted).Select(f => f.SystemIdentifier).FirstOrDefault();
                        break;
                    case BusinessObjectType.Inventory:
                        entitySysId = _context.VInventories.Where(i => i.ExternalIdentifier == externalIdentifier && !i.Deleted).Select(i => i.SystemIdentifier).FirstOrDefault();
                        break;
                    case BusinessObjectType.ArchivalEntity:
                        entitySysId = _context.VArchivalEntities.Where(a => a.ExternalIdentifier == externalIdentifier && !a.Deleted).Select(a => a.SystemIdentifier).FirstOrDefault();
                        break;
                    case BusinessObjectType.Document:
                        entitySysId = _context.VDocuments.Where(d => d.ExternalIdentifier == externalIdentifier && !d.Deleted).Select(d => d.SystemIdentifier).FirstOrDefault();
                        break;
                }

                if (entitySysId == Guid.Empty)
                {
                    return process;
                }
            }

            switch (entityType)
            {
                case BusinessObjectType.Fund:
                    process =
                        await _context.VFunds
                        .GroupJoin(
                            _context.Processes,
                            fund => fund.SystemIdentifier,
                            proc => proc.FundSystemIdentifier,
                            (fund, proc) => new { Fund = fund, Processes = proc })
                        .SelectMany(
                            fundProcesses => fundProcesses.Processes.DefaultIfEmpty(),
                            (fundProcesses, proc) => new { Fund = fundProcesses.Fund, Process = proc })
                        .Where(fp => fp.Fund.SystemIdentifier == entitySysId && !fp.Process!.Completed)
                        .Select(p => new ProcessDisplayModel()
                        {
                            Id = p.Process!.Id,
                            ProcessTypeId = p.Process!.ProcessTypeId,
                            ProcessTypeTitle = p.Process.ProcessType.Name,
                            ArchiveId = p.Process.ArchiveId,
                            ArchiveName = p.Process.Archive!.Name,
                            CreatedBy = p.Process.CreatedBy,
                            CreatedByDisplayName = p.Process.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            CreatedByUserName = p.Process.CreatedByNavigation.UserName,
                            CreatedOn = p.Process.CreatedOn,
                            Deleted = p.Process.Deleted,
                            DeletedBy = p.Process.DeletedBy,
                            DeletedByDisplayName = p.Process.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            DeletedByUserName = p.Process.DeletedByNavigation.UserName,
                            DeletedOn = p.Process.DeletedOn,
                            FundId = p.Process.FundId,
                            FundSystemIdentifier = p.Process.FundSystemIdentifier,
                            FundNumber = p.Fund!.Number,
                            UpdatedBy = p.Process.UpdatedBy,
                            UpdatedByDisplayName = p.Process.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            UpdatedByUserName = p.Process.UpdatedByNavigation!.UserName,
                            UpdatedOn = p.Process.UpdatedOn,
                            Completed = p.Process.Completed,
                        })
                        .SingleOrDefaultAsync();

                    break;
                case BusinessObjectType.Inventory:
                    process =
                        await _context.VInventories
                        .GroupJoin(
                            _context.Processes,
                            inv => inv.SystemIdentifier,
                            proc => proc.InventorySystemIdentifier,
                            (inv, proc) => new { Inventory = inv, Processes = proc })
                        .SelectMany(
                            inventoryProcesses => inventoryProcesses.Processes.DefaultIfEmpty(),
                            (inventoryProcesses, proc) => new { Inventory = inventoryProcesses.Inventory, Process = proc })
                        .Where(invp => invp.Inventory.SystemIdentifier == entitySysId && !invp.Process!.Completed)
                        .Select(p => new ProcessDisplayModel()
                        {
                            Id = p.Process!.Id,
                            ProcessTypeId = p.Process!.ProcessTypeId,
                            ProcessTypeTitle = p.Process.ProcessType.Name,
                            ArchiveId = p.Process.ArchiveId,
                            ArchiveName = p.Process.Archive!.Name,
                            CreatedBy = p.Process.CreatedBy,
                            CreatedByDisplayName = p.Process.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            CreatedByUserName = p.Process.CreatedByNavigation.UserName,
                            CreatedOn = p.Process.CreatedOn,
                            Deleted = p.Process.Deleted,
                            DeletedBy = p.Process.DeletedBy,
                            DeletedByDisplayName = p.Process.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            DeletedByUserName = p.Process.DeletedByNavigation.UserName,
                            DeletedOn = p.Process.DeletedOn,
                            InventoryId = p.Process.InventoryId,
                            InventorySystemIdentifier = p.Process.InventorySystemIdentifier,
                            InventoryNumber = p.Inventory!.Number,
                            UpdatedBy = p.Process.UpdatedBy,
                            UpdatedByDisplayName = p.Process.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            UpdatedByUserName = p.Process.UpdatedByNavigation!.UserName,
                            UpdatedOn = p.Process.UpdatedOn,
                            Completed = p.Process.Completed,
                        })
                        .SingleOrDefaultAsync();

                    if (process == null && includeParent.HasValue && includeParent.Value)
                    {
                        process =
                            await _context.Processes
                            .Join(
                                _context.VInventories,
                                process => process.FundSystemIdentifier,
                                inventory => inventory.FundSystemIdentifier,
                                (process, inventory) => new { Process = process, Inventory = inventory })
                            .Where(process => process.Inventory.SystemIdentifier == entitySysId && !process.Process.Completed)
                            .Select(p => new ProcessDisplayModel()
                            {
                                Id = p.Process.Id,
                                ProcessTypeId = p.Process.ProcessTypeId,
                                ProcessTypeTitle = p.Process.ProcessType.Name,
                                ArchiveId = p.Process.ArchiveId,
                                ArchiveName = p.Process.Archive!.Name,
                                CreatedBy = p.Process.CreatedBy,
                                CreatedByDisplayName = p.Process.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                CreatedByUserName = p.Process.CreatedByNavigation.UserName,
                                CreatedOn = p.Process.CreatedOn,
                                Deleted = p.Process.Deleted,
                                DeletedBy = p.Process.DeletedBy,
                                DeletedByDisplayName = p.Process.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                DeletedByUserName = p.Process.DeletedByNavigation.UserName,
                                DeletedOn = p.Process.DeletedOn,
                                FundId = p.Process.FundId,
                                FundSystemIdentifier = p.Process.FundSystemIdentifier,
                                FundNumber = p.Inventory.FundNumber,
                                UpdatedBy = p.Process.UpdatedBy,
                                UpdatedByDisplayName = p.Process.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                UpdatedByUserName = p.Process.UpdatedByNavigation!.UserName,
                                UpdatedOn = p.Process.UpdatedOn,
                                Completed = p.Process.Completed,
                            })
                            .SingleOrDefaultAsync();
                    }
                    break;
                case BusinessObjectType.ArchivalEntity:
                    process =
                        await _context.VArchivalEntities
                        .GroupJoin(
                            _context.Processes,
                            ae => ae.SystemIdentifier,
                            proc => proc.ArchivalEntitySystemIdentifier,
                            (ae, proc) => new { ArchivalEntity = ae, Processes = proc })
                        .SelectMany(
                            aeProcesses => aeProcesses.Processes.DefaultIfEmpty(),
                            (aeProcesses, proc) => new { ArchivalEntity = aeProcesses.ArchivalEntity, Process = proc })
                        .Where(aep => aep.ArchivalEntity.SystemIdentifier == entitySysId && !aep.Process!.Completed)
                        .Select(p => new ProcessDisplayModel()
                        {
                            Id = p.Process!.Id,
                            ProcessTypeId = p.Process!.ProcessTypeId,
                            ProcessTypeTitle = p.Process.ProcessType.Name,
                            ArchiveId = p.Process.ArchiveId,
                            ArchiveName = p.Process.Archive!.Name,
                            CreatedBy = p.Process.CreatedBy,
                            CreatedByDisplayName = p.Process.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            CreatedByUserName = p.Process.CreatedByNavigation.UserName,
                            CreatedOn = p.Process.CreatedOn,
                            Deleted = p.Process.Deleted,
                            DeletedBy = p.Process.DeletedBy,
                            DeletedByDisplayName = p.Process.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            DeletedByUserName = p.Process.DeletedByNavigation.UserName,
                            DeletedOn = p.Process.DeletedOn,
                            ArchivalEntityId = p.Process.ArchivalEntityId,
                            ArchivalEntitySystemIdentifier = p.Process.ArchivalEntitySystemIdentifier,
                            ArchivalEntityNumber = p.ArchivalEntity.Number,
                            UpdatedBy = p.Process.UpdatedBy,
                            UpdatedByDisplayName = p.Process.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            UpdatedByUserName = p.Process.UpdatedByNavigation!.UserName,
                            UpdatedOn = p.Process.UpdatedOn,
                            Completed = p.Process.Completed,
                        })
                        .SingleOrDefaultAsync();

                    if (process == null && includeParent.HasValue && includeParent.Value)
                    {
                        process =
                            await _context.Processes
                            .Join(
                                _context.VArchivalEntities,
                                process => process.InventorySystemIdentifier,
                                archivalEntity => archivalEntity.InventorySystemIdentifier,
                                (process, archivalEntity) => new { Process = process, ArchivalEntity = archivalEntity })
                            .Where(process => process.ArchivalEntity.SystemIdentifier == entitySysId && !process.Process.Completed)
                            .Select(p => new ProcessDisplayModel()
                            {
                                Id = p.Process!.Id,
                                ProcessTypeId = p.Process!.ProcessTypeId,
                                ProcessTypeTitle = p.Process.ProcessType.Name,
                                ArchiveId = p.Process.ArchiveId,
                                ArchiveName = p.Process.Archive!.Name,
                                CreatedBy = p.Process.CreatedBy,
                                CreatedByDisplayName = p.Process.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                CreatedByUserName = p.Process.CreatedByNavigation.UserName,
                                CreatedOn = p.Process.CreatedOn,
                                Deleted = p.Process.Deleted,
                                DeletedBy = p.Process.DeletedBy,
                                DeletedByDisplayName = p.Process.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                DeletedByUserName = p.Process.DeletedByNavigation.UserName,
                                DeletedOn = p.Process.DeletedOn,
                                InventoryId = p.Process.InventoryId,
                                InventorySystemIdentifier = p.Process.InventorySystemIdentifier,
                                InventoryNumber = p.ArchivalEntity.InventoryNumber,
                                UpdatedBy = p.Process.UpdatedBy,
                                UpdatedByDisplayName = p.Process.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                UpdatedByUserName = p.Process.UpdatedByNavigation!.UserName,
                                UpdatedOn = p.Process.UpdatedOn,
                                Completed = p.Process.Completed,
                            })
                            .SingleOrDefaultAsync()
                            ??
                            await _context.Processes
                            .Join(
                                _context.VArchivalEntities,
                                process => process.FundSystemIdentifier,
                                archivalEntity => archivalEntity.FundSystemIdentifier,
                                (process, archivalEntity) => new { Process = process, ArchivalEntity = archivalEntity })
                            .Where(process => process.ArchivalEntity.SystemIdentifier == entitySysId && !process.Process.Completed)
                            .Select(p => new ProcessDisplayModel()
                            {
                                Id = p.Process.Id,
                                ProcessTypeId = p.Process.ProcessTypeId,
                                ProcessTypeTitle = p.Process.ProcessType.Name,
                                ArchiveId = p.Process.ArchiveId,
                                ArchiveName = p.Process.Archive!.Name,
                                CreatedBy = p.Process.CreatedBy,
                                CreatedByDisplayName = p.Process.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                CreatedByUserName = p.Process.CreatedByNavigation.UserName,
                                CreatedOn = p.Process.CreatedOn,
                                Deleted = p.Process.Deleted,
                                DeletedBy = p.Process.DeletedBy,
                                DeletedByDisplayName = p.Process.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                DeletedByUserName = p.Process.DeletedByNavigation.UserName,
                                DeletedOn = p.Process.DeletedOn,
                                FundId = p.Process.FundId,
                                FundSystemIdentifier = p.Process.FundSystemIdentifier,
                                FundNumber = p.ArchivalEntity.FundNumber,
                                UpdatedBy = p.Process.UpdatedBy,
                                UpdatedByDisplayName = p.Process.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                UpdatedByUserName = p.Process.UpdatedByNavigation!.UserName,
                                UpdatedOn = p.Process.UpdatedOn,
                                Completed = p.Process.Completed,
                            })
                            .SingleOrDefaultAsync();
                    }

                    break;
                case BusinessObjectType.Document:
                    process =
                        await _context.VDocuments
                        .GroupJoin(
                            _context.Processes,
                            doc => doc.SystemIdentifier,
                            proc => proc.DocumentSystemIdentifier,
                            (doc, proc) => new { Document = doc, Processes = proc })
                        .SelectMany(
                            docProcesses => docProcesses.Processes.DefaultIfEmpty(),
                            (docProcesses, proc) => new { Document = docProcesses.Document, Process = proc })
                        .Where(docp => docp.Document.SystemIdentifier == entitySysId && !docp.Process!.Completed)
                        .Select(p => new ProcessDisplayModel()
                        {
                            Id = p.Process!.Id,
                            ProcessTypeId = p.Process!.ProcessTypeId,
                            ProcessTypeTitle = p.Process.ProcessType.Name,
                            ArchiveId = p.Process.ArchiveId,
                            ArchiveName = p.Process.Archive!.Name,
                            CreatedBy = p.Process.CreatedBy,
                            CreatedByDisplayName = p.Process.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            CreatedByUserName = p.Process.CreatedByNavigation.UserName,
                            CreatedOn = p.Process.CreatedOn,
                            Deleted = p.Process.Deleted,
                            DeletedBy = p.Process.DeletedBy,
                            DeletedByDisplayName = p.Process.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            DeletedByUserName = p.Process.DeletedByNavigation.UserName,
                            DeletedOn = p.Process.DeletedOn,
                            DocumentId = p.Process.DocumentId,
                            DocumentSystemIdentifier = p.Process.DocumentSystemIdentifier,
                            DocumentTitle = p.Document.Title,
                            UpdatedBy = p.Process.UpdatedBy,
                            UpdatedByDisplayName = p.Process.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            UpdatedByUserName = p.Process.UpdatedByNavigation!.UserName,
                            UpdatedOn = p.Process.UpdatedOn,
                            Completed = p.Process.Completed,
                        })
                        .SingleOrDefaultAsync();

                    if (process == null && includeParent.HasValue && includeParent.Value)
                    {
                        process =
                            await _context.Processes
                            .Join(
                                _context.VDocuments,
                                process => process.ArchivalEntitySystemIdentifier,
                                document => document.ArchivalEntitySystemIdentifier,
                                (process, document) => new { Process = process, Document = document })
                            .Where(process => process.Document.SystemIdentifier == entitySysId && !process.Process.Completed)
                            .Select(p => new ProcessDisplayModel()
                            {
                                Id = p.Process!.Id,
                                ProcessTypeId = p.Process!.ProcessTypeId,
                                ProcessTypeTitle = p.Process.ProcessType.Name,
                                ArchiveId = p.Process.ArchiveId,
                                ArchiveName = p.Process.Archive!.Name,
                                CreatedBy = p.Process.CreatedBy,
                                CreatedByDisplayName = p.Process.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                CreatedByUserName = p.Process.CreatedByNavigation.UserName,
                                CreatedOn = p.Process.CreatedOn,
                                Deleted = p.Process.Deleted,
                                DeletedBy = p.Process.DeletedBy,
                                DeletedByDisplayName = p.Process.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                DeletedByUserName = p.Process.DeletedByNavigation.UserName,
                                DeletedOn = p.Process.DeletedOn,
                                ArchivalEntityId = p.Process.ArchivalEntityId,
                                ArchivalEntitySystemIdentifier = p.Process.ArchivalEntitySystemIdentifier,
                                ArchivalEntityNumber = p.Document.ArchivalEntityNumber,
                                UpdatedBy = p.Process.UpdatedBy,
                                UpdatedByDisplayName = p.Process.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                UpdatedByUserName = p.Process.UpdatedByNavigation!.UserName,
                                UpdatedOn = p.Process.UpdatedOn,
                                Completed = p.Process.Completed,
                            })
                        .SingleOrDefaultAsync()
                        ??
                        await _context.Processes
                        .Join(
                            _context.VDocuments,
                            process => process.InventorySystemIdentifier,
                            document => document.InventorySystemIdentifier,
                            (process, document) => new { Process = process, Document = document })
                        .Where(process => process.Document.SystemIdentifier == entitySysId && !process.Process.Completed)
                        .Select(p => new ProcessDisplayModel()
                        {
                            Id = p.Process!.Id,
                            ProcessTypeId = p.Process!.ProcessTypeId,
                            ProcessTypeTitle = p.Process.ProcessType.Name,
                            ArchiveId = p.Process.ArchiveId,
                            ArchiveName = p.Process.Archive!.Name,
                            CreatedBy = p.Process.CreatedBy,
                            CreatedByDisplayName = p.Process.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            CreatedByUserName = p.Process.CreatedByNavigation.UserName,
                            CreatedOn = p.Process.CreatedOn,
                            Deleted = p.Process.Deleted,
                            DeletedBy = p.Process.DeletedBy,
                            DeletedByDisplayName = p.Process.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            DeletedByUserName = p.Process.DeletedByNavigation.UserName,
                            DeletedOn = p.Process.DeletedOn,
                            InventoryId = p.Process.InventoryId,
                            InventorySystemIdentifier = p.Process.InventorySystemIdentifier,
                            InventoryNumber = p.Document.InventoryNumber,
                            UpdatedBy = p.Process.UpdatedBy,
                            UpdatedByDisplayName = p.Process.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            UpdatedByUserName = p.Process.UpdatedByNavigation!.UserName,
                            UpdatedOn = p.Process.UpdatedOn,
                            Completed = p.Process.Completed,
                        })
                        .SingleOrDefaultAsync()
                        ??
                        await _context.Processes
                        .Join(
                            _context.VDocuments,
                            process => process.FundSystemIdentifier,
                            document => document.FundSystemIdentifier,
                            (process, document) => new { Process = process, Document = document })
                        .Where(process => process.Document.SystemIdentifier == entitySysId && !process.Process.Completed)
                        .Select(p => new ProcessDisplayModel()
                        {
                            Id = p.Process!.Id,
                            ProcessTypeId = p.Process!.ProcessTypeId,
                            ProcessTypeTitle = p.Process.ProcessType.Name,
                            ArchiveId = p.Process.ArchiveId,
                            ArchiveName = p.Process.Archive!.Name,
                            CreatedBy = p.Process.CreatedBy,
                            CreatedByDisplayName = p.Process.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            CreatedByUserName = p.Process.CreatedByNavigation.UserName,
                            CreatedOn = p.Process.CreatedOn,
                            Deleted = p.Process.Deleted,
                            DeletedBy = p.Process.DeletedBy,
                            DeletedByDisplayName = p.Process.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            DeletedByUserName = p.Process.DeletedByNavigation.UserName,
                            DeletedOn = p.Process.DeletedOn,
                            FundId = p.Process.FundId,
                            FundSystemIdentifier = p.Process.FundSystemIdentifier,
                            FundNumber = p.Document.FundNumber,
                            UpdatedBy = p.Process.UpdatedBy,
                            UpdatedByDisplayName = p.Process.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            UpdatedByUserName = p.Process.UpdatedByNavigation!.UserName,
                            UpdatedOn = p.Process.UpdatedOn,
                            Completed = p.Process.Completed,
                        })
                        .SingleOrDefaultAsync();
                    }

                    break;
                case BusinessObjectType.Film:
                    process =
                        await _context.VFilms
                        .GroupJoin(
                            _context.Processes,
                            film => film.SystemIdentifier,
                            proc => proc.FilmSystemIdentifier,
                            (film, proc) => new { Film = film, Processes = proc })
                        .SelectMany(
                            filmProcesses => filmProcesses.Processes.DefaultIfEmpty(),
                            (filmProcesses, proc) => new { Film = filmProcesses.Film, Process = proc })
                        .Where(filmp => filmp.Film.SystemIdentifier == entitySysId && !filmp.Process!.Completed)
                        .Select(p => new ProcessDisplayModel()
                        {
                            Id = p.Process!.Id,
                            ProcessTypeId = p.Process!.ProcessTypeId,
                            ProcessTypeTitle = p.Process.ProcessType.Name,
                            ArchiveId = p.Process.ArchiveId,
                            ArchiveName = p.Process.Archive!.Name,
                            CreatedBy = p.Process.CreatedBy,
                            CreatedByDisplayName = p.Process.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            CreatedByUserName = p.Process.CreatedByNavigation.UserName,
                            CreatedOn = p.Process.CreatedOn,
                            Deleted = p.Process.Deleted,
                            DeletedBy = p.Process.DeletedBy,
                            DeletedByDisplayName = p.Process.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            DeletedByUserName = p.Process.DeletedByNavigation.UserName,
                            DeletedOn = p.Process.DeletedOn,
                            FilmSystemIdentifier = p.Process.FilmSystemIdentifier,
                            FilmNumber = p.Film.InventoryNumber.ToString(),
                            UpdatedBy = p.Process.UpdatedBy,
                            UpdatedByDisplayName = p.Process.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                            UpdatedByUserName = p.Process.UpdatedByNavigation!.UserName,
                            UpdatedOn = p.Process.UpdatedOn,
                            Completed = p.Process.Completed,
                        })
                        .SingleOrDefaultAsync();
                    break;
                case BusinessObjectType.FilmCard:
                    if (includeParent.HasValue && includeParent.Value)
                    {
                        process =
                            await _context.Processes
                            .Join(
                                _context.VFilmCards,
                                process => process.FilmSystemIdentifier,
                                filmCard => filmCard.FilmSystemIdentifier,
                                (process, filmCard) => new { Process = process, FilmCard = filmCard })
                            .Where(process => process.FilmCard.SystemIdentifier == entitySysId && !process.Process.Completed)
                            .Select(p => new ProcessDisplayModel()
                            {
                                Id = p.Process.Id,
                                ProcessTypeId = p.Process.ProcessTypeId,
                                ProcessTypeTitle = p.Process.ProcessType.Name,
                                ArchiveId = p.Process.ArchiveId,
                                ArchiveName = p.Process.Archive!.Name,
                                CreatedBy = p.Process.CreatedBy,
                                CreatedByDisplayName = p.Process.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                CreatedByUserName = p.Process.CreatedByNavigation.UserName,
                                CreatedOn = p.Process.CreatedOn,
                                Deleted = p.Process.Deleted,
                                DeletedBy = p.Process.DeletedBy,
                                DeletedByDisplayName = p.Process.DeletedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.DeletedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                DeletedByUserName = p.Process.DeletedByNavigation.UserName,
                                DeletedOn = p.Process.DeletedOn,
                                FilmSystemIdentifier = p.Process.FilmSystemIdentifier,
                                FilmNumber = p.FilmCard.FilmInventoryNumber.HasValue ? p.FilmCard.FilmInventoryNumber.Value.ToString() : string.Empty,
                                UpdatedBy = p.Process.UpdatedBy,
                                UpdatedByDisplayName = p.Process.UpdatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == p.Process.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                                UpdatedByUserName = p.Process.UpdatedByNavigation!.UserName,
                                UpdatedOn = p.Process.UpdatedOn,
                                Completed = p.Process.Completed,
                            })
                            .SingleOrDefaultAsync();
                    }
                    break;
                default:
                    break;
            }

            if (process != null)
            {
                var processStep = await GetActiveProcessStepAsync(process.Id!.Value);
                process.ActiveProcessStepId = processStep?.Id;
                process.ActiveProcessStepTypeId = processStep?.StepTypeId;
                process.ActiveProcessStepName = processStep?.StepTypeName;
                if (processStep != null)
                {
                    process.IsCurrentUserInActiveProcessStep = await IsCurrentUserInProcessStepAsync(process.Id.Value, processStep.Id);
                }
            }

            return process;
        }

        public async Task<bool> HasCurrentActiveProcess(string entityType, Guid entitySysId)
        {
            bool hasActiveProcess = false;

            switch (entityType)
            {
                case BusinessObjectType.Fund:
                    hasActiveProcess =
                        //Проверява дали самото ентити има активни процеси
                        await _context.Processes
                        .Where(process => process.FundSystemIdentifier == entitySysId && !process.Completed)
                        .AnyAsync()
                        ||
                        //Проверява дали надолу по нивата на свързаните ентитита има активни процеси
                        await _context.Processes
                        .Join(
                            _context.VInventories,
                            process => process.InventorySystemIdentifier,
                            inventory => inventory.SystemIdentifier,
                            (process, inventory) => new { Process = process, Inventory = inventory })
                        .Where(process => process.Inventory.FundSystemIdentifier == entitySysId && !process.Process.Completed)
                        .AnyAsync()
                        ||
                        await _context.Processes
                        .Join(
                            _context.VArchivalEntities,
                            process => process.ArchivalEntitySystemIdentifier,
                            archivalEntity => archivalEntity.SystemIdentifier,
                            (process, archivalEntity) => new { Process = process, ArchivalEntity = archivalEntity })
                        .Where(process => process.ArchivalEntity.FundSystemIdentifier == entitySysId && !process.Process.Completed)
                        .AnyAsync()
                        ||
                        await _context.Processes
                        .Join(
                            _context.VDocuments,
                            process => process.DocumentSystemIdentifier,
                            document => document.SystemIdentifier,
                            (process, document) => new { Process = process, Document = document })
                        .Where(process => process.Document.FundSystemIdentifier == entitySysId && !process.Process.Completed)
                        .AnyAsync();
                    break;
                case BusinessObjectType.Inventory:
                    hasActiveProcess =
                        //Проверява дали самото ентити има активни процеси
                        await _context.Processes
                        .Where(process => process.InventorySystemIdentifier == entitySysId && !process.Completed)
                        .AnyAsync()
                        ||
                        //Проверява дали нагоре по нивата на свързаните ентитита има активни процеси
                        await _context.Processes
                        .Join(
                            _context.VInventories,
                            process => process.FundSystemIdentifier,
                            inventory => inventory.FundSystemIdentifier,
                            (process, inventory) => new { Process = process, Inventory = inventory })
                        .Where(process => process.Inventory.SystemIdentifier == entitySysId && !process.Process.Completed)
                        .AnyAsync()
                        ||
                        //Проверява дали надолу по нивата на свързаните ентитита има активни процеси
                        await _context.Processes
                        .Join(
                            _context.VArchivalEntities,
                            process => process.ArchivalEntitySystemIdentifier,
                            archivalEntity => archivalEntity.SystemIdentifier,
                            (process, archivalEntity) => new { Process = process, ArchivalEntity = archivalEntity })
                        .Where(process => process.ArchivalEntity.InventorySystemIdentifier == entitySysId && !process.Process.Completed)
                        .AnyAsync()
                        ||
                        await _context.Processes
                        .Join(
                            _context.VDocuments,
                            process => process.DocumentSystemIdentifier,
                            document => document.SystemIdentifier,
                            (process, document) => new { Process = process, Document = document })
                        .Where(process => process.Document.InventorySystemIdentifier == entitySysId && !process.Process.Completed)
                        .AnyAsync();
                    break;
                case BusinessObjectType.ArchivalEntity:
                    hasActiveProcess =
                        //Проверява дали самото ентити има активни процеси
                        await _context.Processes
                        .Where(process => process.ArchivalEntitySystemIdentifier == entitySysId && !process.Completed)
                        .AnyAsync()
                        ||
                        //Проверява дали нагоре по нивата на свързаните ентитита има активни процеси
                        await _context.Processes
                        .Join(
                            _context.VArchivalEntities,
                            process => process.InventorySystemIdentifier,
                            archivalEntity => archivalEntity.InventorySystemIdentifier,
                            (process, archivalEntity) => new { Process = process, ArchivalEntity = archivalEntity })
                        .Where(process => process.ArchivalEntity.SystemIdentifier == entitySysId && !process.Process.Completed)
                        .AnyAsync()
                        ||
                        await _context.Processes
                        .Join(
                            _context.VArchivalEntities,
                            process => process.FundSystemIdentifier,
                            archivalEntity => archivalEntity.FundSystemIdentifier,
                            (process, archivalEntity) => new { Process = process, ArchivalEntity = archivalEntity })
                        .Where(process => process.ArchivalEntity.SystemIdentifier == entitySysId && !process.Process.Completed)
                        .AnyAsync()
                        ||
                        //Проверява дали надолу по нивата на свързаните ентитита има активни процеси
                        await _context.Processes
                        .Join(
                            _context.VDocuments,
                            process => process.DocumentSystemIdentifier,
                            document => document.SystemIdentifier,
                            (process, document) => new { Process = process, Document = document })
                        .Where(process => process.Document.ArchivalEntitySystemIdentifier == entitySysId && !process.Process.Completed)
                        .AnyAsync();
                    break;
                case BusinessObjectType.Document:
                    hasActiveProcess =
                        //Проверява дали самото ентити има активни процеси
                        await _context.Processes
                        .Where(process => process.DocumentSystemIdentifier == entitySysId && !process.Completed)
                        .AnyAsync()
                        ||
                        //Проверява дали нагоре по нивата на свързаните ентитита има активни процеси
                        await _context.Processes
                        .Join(
                            _context.VDocuments,
                            process => process.ArchivalEntitySystemIdentifier,
                            document => document.ArchivalEntitySystemIdentifier,
                            (process, document) => new { Process = process, Document = document })
                        .Where(process => process.Document.SystemIdentifier == entitySysId && !process.Process.Completed)
                        .AnyAsync()
                        ||
                        await _context.Processes
                        .Join(
                            _context.VDocuments,
                            process => process.InventorySystemIdentifier,
                            document => document.InventorySystemIdentifier,
                            (process, document) => new { Process = process, Document = document })
                        .Where(process => process.Document.SystemIdentifier == entitySysId && !process.Process.Completed)
                        .AnyAsync()
                        ||
                        await _context.Processes
                        .Join(
                            _context.VDocuments,
                            process => process.FundSystemIdentifier,
                            document => document.FundSystemIdentifier,
                            (process, document) => new { Process = process, Document = document })
                        .Where(process => process.Document.SystemIdentifier == entitySysId && !process.Process.Completed)
                        .AnyAsync();
                    break;
                case BusinessObjectType.Film:
                    hasActiveProcess =
                        await _context.Processes
                        .Where(process => process.FilmSystemIdentifier == entitySysId && !process.Completed)
                        .AnyAsync();
                    break;
            }

            return hasActiveProcess;
        }

        public async Task<bool> HasCurrentActiveProcess(ProcessModel model)
        {
            if (model == null)
                throw new ArgumentNullException(nameof(model));

            bool hasActiveProcess = false;
            if (model.FundSystemIdentifier.HasValue)
            {
                hasActiveProcess = await HasCurrentActiveProcess(BusinessObjectType.Fund, model.FundSystemIdentifier.Value);
            }
            if (model.InventorySystemIdentifier.HasValue)
            {
                hasActiveProcess = await HasCurrentActiveProcess(BusinessObjectType.Inventory, model.InventorySystemIdentifier.Value);
            }
            if (model.ArchivalEntitySystemIdentifier.HasValue)
            {
                hasActiveProcess = await HasCurrentActiveProcess(BusinessObjectType.ArchivalEntity, model.ArchivalEntitySystemIdentifier.Value);
            }
            if (model.DocumentSystemIdentifier.HasValue)
            {
                hasActiveProcess = await HasCurrentActiveProcess(BusinessObjectType.Document, model.DocumentSystemIdentifier.Value);
            }
            if (model.FilmSystemIdentifier.HasValue)
            {
                hasActiveProcess = await HasCurrentActiveProcess(BusinessObjectType.Film, model.FilmSystemIdentifier.Value);
            }

            return hasActiveProcess;
        }

        public OperationResult ValidateProcess(ProcessModel? process, Shared.ProcessType processType)
        {
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (process.ProcessTypeId!.Value != (int)processType)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), ((ProcessDisplayModel)process).ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), ((ProcessDisplayModel)process).ProcessTypeTitle));
            }

            return OperationResult.Success;
        }

        public OperationResult ValidateProcess(ProcessModel? process, params Shared.ProcessType[] processTypes)
        {
            if (process == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (!processTypes.Contains((Shared.ProcessType)process.ProcessTypeId!.Value))
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_InvalidProcessType").ToString(), ((ProcessDisplayModel)process).ProcessTypeTitle));
            }
            if (process.Completed)
            {
                return OperationResult.Failed(false, string.Format(_localizer.GetString("Error_ProcessAlreadyCompleted").ToString(), ((ProcessDisplayModel)process).ProcessTypeTitle));
            }

            return OperationResult.Success;
        }

        public OperationResult ValidateProcessStep(ProcessModel? process, ProcessStepModel? processStep, ProcessStepType stepType)
        {
            if (process == null || processStep == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (processStep.StepTypeId != (int)stepType)
            {
                return OperationResult.Failed(
                    false,
                    string.Format(
                        _localizer.GetString("Error_InvalidProcessStepType").ToString(),
                        processStep.StepTypeId,
                        ((ProcessDisplayModel)process).ProcessTypeTitle));
            }

            return OperationResult.Success;
        }

        public OperationResult ValidateProcessStep(ProcessModel? process, ProcessStepModel? processStep, params ProcessStepType[] stepTypes)
        {
            if (process == null || processStep == null)
            {
                return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (!stepTypes.Contains((Shared.ProcessStepType)processStep.StepTypeId))
            {
                return OperationResult.Failed(
                    false,
                    string.Format(
                        _localizer.GetString("Error_InvalidProcessStepType").ToString(),
                        processStep.StepTypeId,
                        ((ProcessDisplayModel)process).ProcessTypeTitle));
            }

            return OperationResult.Success;
        }

        public async Task<bool> IsCurrentUserInProcessAsync(int processId)
        {
            bool isInProcess = false;
            //Дали е стартиралия процеса
            isInProcess = await _context.Processes.Where(p => p.Id == processId && p.CreatedBy == _userInfo.CurrentUserId).AnyAsync();
            if (!isInProcess)
            {
                //Дали е пряк участник или в роля
                isInProcess =
                    await _context.ProcessTimelines
                        .Where(ps =>
                            ps.ProcessId == processId
                            && (ps.AssignedToUserId == _userInfo.CurrentUserId
                                || ps.AssignedToRole!.Users.Where(u => u.Id == _userInfo.CurrentUserId).Any())).AnyAsync();
            }

            return isInProcess;
        }

        public async Task<bool> IsCurrentUserInProcessStepAsync(int processId, int stepId)
        {
            //Дали е пряк участник или в роля
            bool isInProcessStep =
                    await _context.ProcessTimelines
                        .Where(ps =>
                            ps.Id == stepId
                            && ps.ProcessId == processId
                            && (ps.AssignedToUserId == _userInfo.CurrentUserId
                                || ps.AssignedToRole!.Users.Where(u => u.Id == _userInfo.CurrentUserId).Any())).AnyAsync();

            return isInProcessStep;
        }

        public async Task<OperationResult> HasEntitiesInCEA(ProcessModel model)
        {
            string entityType = GetEntityType(model);

            bool result = false;

            switch (entityType)
            {
                case BusinessObjectType.Fund:
                    result = await FundHasEntitiesInCEA(model.FundSystemIdentifier!.Value);
                    if (!result)
                    {
                        return OperationResult.Failed("No entities for fund in CEA");
                    }
                    break;
                case BusinessObjectType.Inventory:
                    result = await InventoryHasEntitiesInCEA(model.InventorySystemIdentifier!.Value);
                    if (!result)
                    {
                        return OperationResult.Failed("No entities for inventory in CEA");
                    }
                    break;
                case BusinessObjectType.ArchivalEntity:
                    result = await ArchiveEntityHasEntitiesInCEA(model.ArchivalEntitySystemIdentifier!.Value);
                    if (!result)
                    {
                        return OperationResult.Failed("No entities for archiveEntity in CEA");
                    }
                    break;
                case BusinessObjectType.Document:
                    result = await DocumentInCEA(model.DocumentSystemIdentifier!.Value);
                    if (!result)
                    {
                        return OperationResult.Failed("No entities for document in CEA");
                    }
                    break;
                default: return OperationResult.Failed("Unknown entity type");
            }
            return OperationResult.Success;
        }

        private async Task<bool> FundHasEntitiesInCEA(Guid sysId)
        {
            return await _context.Inventories
                        .Where(inv => inv.FundSystemIdentifier == sysId && !inv.Deleted && !inv.HasExternalSource)
                        .AnyAsync()
                ||
                   await _context.ArchivalEntities
                        .Where(ae => ae.FundSystemIdentifier == sysId && !ae.Deleted && !ae.HasExternalSource)
                        .AnyAsync()
                ||
                   await _context.Documents
                        .Where(doc => doc.FundSystemIdentifier == sysId && !doc.Deleted && !doc.HasExternalSource)
                        .AnyAsync();

            //var inventories = _context.Inventories
            //                          .Where(f => f.FundSystemIdentifier.ToString() == sysId && (f.HasExternalSource! || f.SystemIdentifier.ToString() != null));
            //if (inventories.ToArray().Length != 0)
            //{
            //    return true;
            //}

            //var allInventories = _context.Inventories
            //                             .Where(f => f.FundSystemIdentifier.ToString() == sysId);

            //if (allInventories.ToArray().Length != 0)
            //{
            //    foreach (var item in allInventories)
            //    {
            //        if (item.SystemIdentifier != null && await InventoryHasEntitiesInCEA(item.SystemIdentifier.ToString()))
            //        {
            //            return true;
            //        }
            //    }
            //}

            //return false;
        }

        private async Task<bool> InventoryHasEntitiesInCEA(Guid sysId)
        {
            return await _context.ArchivalEntities
                        .Where(ae => ae.InventorySystemIdentifier == sysId && !ae.Deleted && !ae.HasExternalSource)
                        .AnyAsync()
                  ||
                  await _context.Documents
                        .Where(doc => doc.InventorySystemIdentifier == sysId && !doc.Deleted && !doc.HasExternalSource)
                        .AnyAsync();

            //var archiveEntities = _context.ArchivalEntities
            //                              .Where(ae => ae.InventorySystemIdentifier.ToString() == sysId && (ae.HasExternalSource! || ae.SystemIdentifier.ToString() != null));
            //if (archiveEntities.ToArray().Length == 0)
            //{
            //    return false;
            //}

            //var allArchiveEntities = _context.ArchivalEntities
            //                                 .Where(f => f.InventorySystemIdentifier.ToString() == sysId);

            //if (allArchiveEntities.ToArray().Length != 0)
            //{
            //    foreach (var item in allArchiveEntities)
            //    {
            //        if (await ArchiveEntityHasEntitiesInCEA(item.SystemIdentifier))
            //        {
            //            return true;
            //        }
            //    }
            //}

            //return true;
        }

        private async Task<bool> ArchiveEntityHasEntitiesInCEA(Guid sysId)
        {
            return await _context.Documents
                        .Where(doc =>
                            doc.ArchivalEntitySystemIdentifier == sysId
                            && !doc.Deleted
                            && !doc.HasExternalSource)
                        .AnyAsync();

            //var documents = _context.Documents
            //                        .Where(d => d.ArchivalEntitySystemIdentifier == sysId && (d.HasExternalSource! || d.SystemIdentifier.ToString() != null));
            //if (documents.ToArray().Length == 0)
            //{
            //    return false;
            //}

            //return true;
        }

        private async Task<bool> DocumentInCEA(Guid sysId)
        {
            return await _context.Documents
                        .Where(d => d.SystemIdentifier == sysId && !d.Deleted)
                        .AnyAsync();
        }

        public async Task<int> GetLastProcessType(Guid sysId)
        {
            return await _context.Processes
                           .Where(d =>
                           (d.FundSystemIdentifier == sysId
                           || d.InventorySystemIdentifier == sysId
                           || d.ArchivalEntitySystemIdentifier == sysId
                           || d.DocumentSystemIdentifier == sysId
                           ) && !d.Deleted)
                           .Select(d => d.ProcessType.Id)
                           .FirstOrDefaultAsync();
        }

        public string GetEntityType(ProcessModel process)
        {
            if (process.FundSystemIdentifier.HasValue)
            {
                return BusinessObjectType.Fund;
            }
            if (process.InventorySystemIdentifier.HasValue)
            {
                return BusinessObjectType.Inventory;
            }
            if (process.ArchivalEntitySystemIdentifier.HasValue)
            {
                return BusinessObjectType.ArchivalEntity;
            }
            if (process.DocumentSystemIdentifier.HasValue)
            {
                return BusinessObjectType.Document;
            }
            return BusinessObjectType.Unknown;
        }

        public Guid GetEntitySystemIdentifier(ProcessModel process)
        {
            if (process.FundSystemIdentifier.HasValue)
            {
                return process.FundSystemIdentifier.Value;
            }
            if (process.InventorySystemIdentifier.HasValue)
            {
                return process.InventorySystemIdentifier.Value;
            }
            if (process.ArchivalEntitySystemIdentifier.HasValue)
            {
                return process.ArchivalEntitySystemIdentifier.Value;
            }
            if (process.DocumentSystemIdentifier.HasValue)
            {
                return process.DocumentSystemIdentifier.Value;
            }
            if (process.FilmSystemIdentifier.HasValue)
            {
                return process.FilmSystemIdentifier.Value;
            }
            return Guid.Empty;
        }

        private async Task<bool> HasValidEntityStatus(string entityType, Guid systemIdentifier)
        {
            bool isValidStatus = true;

            switch (entityType)
            {
                case BusinessObjectType.Fund:
                    isValidStatus = !await _context.Funds
                                    .Where(f =>
                                        f.SystemIdentifier == systemIdentifier
                                        && (f.Deleted
                                            || (f.StatusCode == Shared.Status.Deducted || f.StatusCode == Shared.Status.Deleted)))
                                    .AnyAsync();
                    break;
                case BusinessObjectType.Inventory:
                    isValidStatus = !await _context.Inventories
                                    .Where(inv =>
                                        inv.SystemIdentifier == systemIdentifier
                                        && (inv.Deleted
                                            || (inv.StatusCode == Shared.Status.Deducted || inv.StatusCode == Shared.Status.Deleted)))
                                    .AnyAsync();
                    break;
                case BusinessObjectType.ArchivalEntity:
                    isValidStatus = !await _context.ArchivalEntities
                                    .Where(ae =>
                                        ae.SystemIdentifier == systemIdentifier
                                        && (ae.Deleted
                                            || (ae.StatusCode == Shared.Status.Deducted || ae.StatusCode == Shared.Status.Deleted)))
                                    .AnyAsync();
                    break;
                case BusinessObjectType.Document:
                    isValidStatus = !await _context.Documents
                                    .Where(doc =>
                                        doc.SystemIdentifier == systemIdentifier
                                        && (doc.Deleted
                                            || (doc.StatusCode == Shared.Status.Deducted || doc.StatusCode == Shared.Status.Deleted)))
                                    .AnyAsync();
                    break;
                case BusinessObjectType.Film:
                    isValidStatus = !await _context.Films
                                    .Where(film =>
                                        film.SystemIdentifier == systemIdentifier
                                        && film.Deleted)
                                    .AnyAsync();
                    break;
            }

            return isValidStatus;
        }

        private async Task<bool> HasValidEntityStatus(ProcessModel model)
        {
            if (model == null)
                throw new ArgumentNullException(nameof(model));

            bool hasValidStatus = true;
            if (model.FundSystemIdentifier.HasValue)
            {
                hasValidStatus = await HasValidEntityStatus(BusinessObjectType.Fund, model.FundSystemIdentifier.Value);
            }
            if (model.InventorySystemIdentifier.HasValue)
            {
                hasValidStatus = await HasValidEntityStatus(BusinessObjectType.Inventory, model.InventorySystemIdentifier.Value);
            }
            if (model.ArchivalEntitySystemIdentifier.HasValue)
            {
                hasValidStatus = await HasValidEntityStatus(BusinessObjectType.ArchivalEntity, model.ArchivalEntitySystemIdentifier.Value);
            }
            if (model.DocumentSystemIdentifier.HasValue)
            {
                hasValidStatus = await HasValidEntityStatus(BusinessObjectType.Document, model.DocumentSystemIdentifier.Value);
            }
            if (model.FilmSystemIdentifier.HasValue)
            {
                hasValidStatus = await HasValidEntityStatus(BusinessObjectType.Film, model.FilmSystemIdentifier.Value);
            }

            return hasValidStatus;
        }
    }
}