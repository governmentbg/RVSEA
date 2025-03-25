using DAA.Data;
using DAA.Extensions.DateTime;
using DAA.Models.Commission;
using DAA.Models.File;
using DAA.Services.Files;
using DAA.Services.Packages;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;

namespace DAA.Services.CommissionReports
{
    public class CommissionReportService : BaseService, ICommissionReportService
    {
        private readonly IUserInfo _userInfo;
        private readonly IFileService _fileService;
        private readonly IPackagesService _packagesService;

        public CommissionReportService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IUserInfo userInfo,
            IPackagesService packagesService,
        IFileService fileService)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _fileService = fileService;
            _packagesService = packagesService;
        }

        public async Task<OperationResult> CreateAsync(CommissionReportModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            int nextNumber = await GetNextReportNumber();
            Epkreport report = new()
            {
                ProcessId = model.ProcessId,
                Title = model.Title!,
                //AuthorName = _userInfo.CurrentUserUsername!,
                //AuthorPosition ="",
                Content = model.Content!,
                //EntityLink = model.EntityLink ?? "",
                //LinkTitle = model.LinkTitle ?? "",
                //Date = DateTime.UtcNow,
                Number = nextNumber,
            };

            if (model.IsDraft.HasValue)
            {
                report.IsDraft = model.IsDraft.Value;
            }

            _context.Epkreports.Add(report);

            await _context.SaveAsync("Commission report created");

            return OperationResult.Succeed(report.Id);
        }

        private async Task<int> GetNextReportNumber()
        {
            int? maxReport = 0;
            if (await _context.Epkreports.AnyAsync())
            {
                maxReport = await _context.Epkreports
                    .Where(x => !x.Deleted)
                    .MaxAsync(x => (int?)x.Number) ?? 0;
            }

            return maxReport.Value + 1;
        }

        public async Task<OperationResult> UpdateAsync(CommissionReportModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var report = await _context.Epkreports.FindAsync(model.Id);
            if (report == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            report.Title = model.Title!;
            report.Content = model.Content!;

            if (model.IsDraft.HasValue)
            {
                report.IsDraft = model.IsDraft.Value;
            }

            _context.Update(report);

            await _context.SaveAsync("Commission report updated");

            return OperationResult.Succeed(report.Id);
        }

        public async Task<CommissionReportModel?> GetByIdAsync(int reportId)
        {
            return await _context.Epkreports.Where(r => r.Id == reportId && !r.Deleted)
                .Select(r => new CommissionReportModel
                {
                    Id = r.Id,
                    ProcessId = r.ProcessId,
                    IsDraft = r.IsDraft,
                    Title = r.Title,
                    CreatedBy = r.CreatedBy,
                    CreatedByDisplayName = r.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == r.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    //CreatedByJobTitle = r.AuthorPosition,
                    Content = r.Content,
                    CreatedOn = r.CreatedOn.UtcToLocalTime(),
                    //EntityLink = r.EntityLink,
                    Number = r.Number,
                    //LinkTitle = r.LinkTitle,
                }).SingleOrDefaultAsync();
        }

        public async Task<CommissionReportModel?> GetByProcessIdAsync(int processId)
        {
            return await _context.Epkreports.Where(r => r.ProcessId == processId && !r.Deleted)
                .Select(r => new CommissionReportModel
                {
                    Id = r.Id,
                    ProcessId = r.ProcessId,
                    IsDraft = r.IsDraft,
                    Title = r.Title,
                    CreatedBy = r.CreatedBy,
                    CreatedByDisplayName = r.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == r.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    //CreatedByJobTitle = r.AuthorPosition,
                    Content = r.Content,
                    CreatedOn = r.CreatedOn.UtcToLocalTime(),
                    //EntityLink = r.EntityLink,
                    Number = r.Number,
                    //LinkTitle = r.LinkTitle,
                }).SingleOrDefaultAsync();
        }

        async Task<OperationResult> ICommissionReportServiceBase.DeleteReportInternalAsync(int reportId)
        {
            var report = await _context.Epkreports.FindAsync(reportId);
            if (report == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            var reportFiles = _context.CommissionReportFiles.Where(rf => rf.ReportId == reportId && !rf.Deleted).Select(rf => rf.Id);
            foreach (var reportFile in reportFiles)
            {
                var deleteResult = await DeleteReportFileAsync(reportFile, reportId);
                if (!deleteResult.Succeeded)
                {
                    return deleteResult;
                }
            }

            report.Deleted = true;
            report.DeletedBy = _userInfo.CurrentUserId;
            report.DeletedOn = DateTime.UtcNow;

            _context.Update(report);

            await _context.SaveAsync("Commission report deleted");

            return OperationResult.Succeed(report.Id);
        }

        public async Task<OperationResult> DeleteReportAsync(int reportId)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var reportExists = await _context.Epkreports.Where(r => r.Id == reportId && !r.Deleted).AnyAsync();
                if (!reportExists)
                {
                    transaction.Rollback();
                    return OperationResult.Failed($"Commission report {reportId} does not exists");
                }

                var result = await ((ICommissionReportServiceBase)this).DeleteReportInternalAsync(reportId);
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

        async Task<OperationResult> ICommissionReportServiceBase.UploadReportFileInternalAsync(IFormFile content, int reportId)
        {
            if (content == null)
            {
                throw new ArgumentNullException(nameof(content));
            }

            string? uncFilePath = String.Empty;
            string finalMessage = String.Empty;
            try
            {
                FileModel fileModel = await ParseAttachmentAsync(content);
                var createFileResult = await _fileService.CreateFileAsync(fileModel, FileStreamLocation.Buffer);
                if (!createFileResult.Succeeded)
                {
                    return createFileResult;
                }

                uncFilePath = createFileResult.Data?.ToString();

                var reportFile = new CommissionReportFile()
                {
                    ReportId = reportId,
                    ContentType = fileModel.ContentType,
                    FileType = fileModel.Type,
                    Name = fileModel.SystemName,
                    SourceName = fileModel.Name,
                    UncPath = uncFilePath!,
                };

                var processId = _context.Epkreports.Where(r => r.Id == reportId).Select(r => r.ProcessId).FirstOrDefault();

                int? packageId = (await _packagesService.GetPackageIdAByProcess(processId!.Value));

                if (packageId.HasValue)
                {
                    var packageFile = new PackageDocument()
                    {
                        PackageId = packageId.Value,
                        ContentType = content.ContentType,
                        FileType = fileModel.Type,
                        FileId = fileModel.SystemName,
                        FileName = fileModel.Name,
                        FileLocation = (int)FileStreamLocation.Buffer,
                        FilePath = uncFilePath!,
                        FileSizeInBytes = fileModel.Size,
                    };

                    _context.PackageDocuments.Add(packageFile);

                    finalMessage = "and Package 'A' document added";
                }

                _context.CommissionReportFiles.Add(reportFile);
                await _context.SaveAsync("Commission report file uploaded" + finalMessage);

                return OperationResult.Succeed(uncFilePath!);
            }
            catch (Exception exc)
            {
                if (!string.IsNullOrEmpty(uncFilePath))
                {
                    _fileService.DeleteFile(uncFilePath, FileStreamLocation.Buffer);
                }
                return OperationResult.Failed(exc.ToString());
            }
        }

        async Task<OperationResult> ICommissionReportServiceBase.UploadReportFilesInternalAsync(IEnumerable<IFormFile> contents, int reportId)
        {
            if (contents == null || !contents.Any())
            {
                throw new ArgumentNullException(nameof(contents));
            }

            try
            {
                foreach (var content in contents)
                {
                    var createFileResult = await ((ICommissionReportServiceBase)this).UploadReportFileInternalAsync(content, reportId);
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

        public async Task<OperationResult> UploadReportFilesAsync(IEnumerable<IFormFile> contents, int reportId)
        {
            if (contents == null || !contents.Any())
            {
                throw new ArgumentNullException(nameof(contents));
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var reportExists = await _context.Epkreports.Where(r => r.Id == reportId && !r.Deleted).AnyAsync();
                if (!reportExists)
                {
                    transaction.Rollback();
                    return OperationResult.Failed($"Commission report {reportId} does not exists");
                }

                var result = await ((ICommissionReportServiceBase)this).UploadReportFilesInternalAsync(contents, reportId);
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

        public async Task<OperationResult> DeleteReportFileAsync(int id, int reportId)
        {
            try
            {
                string finalMessage = String.Empty;

                var reportFile = await _context.CommissionReportFiles.Where(rf => rf.Id == id && rf.ReportId == reportId && !rf.Deleted).SingleOrDefaultAsync();
                if (reportFile == null)
                {
                    return OperationResult.Failed($"Commission report file {id} for report {reportId} does not exists");
                }

                reportFile.Deleted = true;
                reportFile.DeletedOn = DateTime.UtcNow;
                reportFile.DeletedBy = _userInfo.CurrentUserId;

                _context.Update(reportFile);

                var packageDocument = await _context.PackageDocuments
                                                .Where(p => p.DocTypeId == null
                                                           && p.FilePath == reportFile.UncPath
                                                           && !p.Deleted)
                                                .FirstOrDefaultAsync();
                if (packageDocument != null)
                {
                    packageDocument.Deleted = true;
                    packageDocument.DeletedOn = DateTime.UtcNow;
                    packageDocument.DeletedBy = _userInfo.CurrentUserId;


                    _context.Update(packageDocument);
                    finalMessage = "and packageA file deleted";
                }

                await _context.SaveAsync("Commission report file deleted" + finalMessage);

                var deleteResult = _fileService.DeleteFile(reportFile.UncPath, FileStreamLocation.Buffer);
                if (!deleteResult.Succeeded)
                {
                    return deleteResult;
                }

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public IQueryable<CommissionReportFileModel> GetReportFilesAsync(int reportId)
        {
            return _context.CommissionReportFiles
                        .Where(rf => rf.ReportId == reportId && !rf.Deleted)
                        .Select(rf => new CommissionReportFileModel()
                        {
                            Id = rf.Id,
                            ReportId = rf.ReportId,
                            ContentType = rf.ContentType,
                            FileType = rf.FileType,
                            Name = rf.Name,
                            SourceName = rf.SourceName,
                        });
        }

        public async Task<CommissionReportFileModel?> GetReportFileAsync(int id, int reportId)
        {
            return await _context.CommissionReportFiles
                        .Where(rf => rf.Id == id && rf.ReportId == reportId && !rf.Deleted)
                        .Select(rf => new CommissionReportFileModel()
                        {
                            Id = rf.Id,
                            ReportId = rf.ReportId,
                            ContentType = rf.ContentType,
                            FileType = rf.FileType,
                            Name = rf.Name,
                            SourceName = rf.SourceName,
                            UncPath = rf.UncPath,
                        })
                        .SingleOrDefaultAsync();
        }

        public IQueryable<CommissionReportModel> GetReports(int archiveId)
        {
            //TODO това трябва да се страницира
            var query =
                _context.Epkreports
                .Where(r => r.Process != null
                    && !r.Process.Completed
                    && r.Process.ArchiveId == archiveId
                    && !r.IsDraft!.Value
                    && !r.Deleted
                    && !r.SessionAgenda.Where(a => a.ReportId == r.Id && !a.Deleted).Any()
                    && r.Process.ProcessTimelines
                        .Where(step => !step.Completed
                                        && (step.StepTypeId == (int)ProcessStepType.CommissionSession
                                            || step.StepTypeId == (int)ProcessStepType.EditFundData_CommissionSession
                                            || step.StepTypeId == (int)ProcessStepType.RefineData_CommissionSession
                                            || step.StepTypeId == (int)ProcessStepType.ReconstructFundData_CommissionSession
                                            || step.StepTypeId == (int)ProcessStepType.DeductData_DecisionAfterAMeetingOfTheEPК
                                            || step.StepTypeId == (int)ProcessStepType.ProcessRawFundWithRawInventory_CommissionSession
                                            || step.StepTypeId == (int)ProcessStepType.ProcessFundWithRawInventory_CommissionSession
                                            || step.StepTypeId == (int)ProcessStepType.CommissionOpinions))
                        .Any())
               .Select(r => new CommissionReportModel()
               {
                   Id = r.Id,
                   ProcessTypeTitle = r.Process!.ProcessType!.Name,
                   ProcessId = r.ProcessId,
                   Title = r.Title,
                   IsDraft = r.IsDraft,
                   Content = r.Content,
                   Number = r.Number,
                   CreatedBy = r.CreatedBy,
                   CreatedByDisplayName = r.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == r.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                   CreatedOn = r.CreatedOn.UtcToLocalTime(),
               });

            return query;
        }
    }
}
