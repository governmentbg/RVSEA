using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Exceptions;
using DAA.Extensions.Models;
using DAA.Models.Configuration;
using DAA.Models.Films;
using DAA.Models.Processes;
using DAA.Models.Tasks;
using DAA.Services.Process;
using DAA.Services.Tasks;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;
using System.Text;

namespace DAA.Services.Films
{
    public class FilmService : BaseService, IFilmService
    {
        private readonly IUserInfo _userInfo;
        private readonly ITaskService _taskService;
        private readonly LinkedServerSettings _linkedServerSettings;
        private readonly IFilmDocumentService _docService;
        private readonly IFilmCardService _cardService;
        private readonly IProcessService _processService;
        private readonly IArchiveService _archiveService;

        public FilmService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IOptions<LinkedServerSettings> settings,
            IUserInfo userInfo,
            ITaskService taskService,
            IFilmDocumentService docService,
            IFilmCardService cardService,
            IProcessService processService,
            IArchiveService archiveService)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _taskService = taskService;
            _linkedServerSettings = settings.Value;
            _docService = docService;
            _cardService = cardService;
            _processService = processService;
            _archiveService = archiveService;
        }

        public DataSourceResponseModel<FilmShortModel> GetAll(DataSourceRequestModel model, bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.VFilms
                .OrderByDescending(f => f.InventoryNumber)
                .AsQueryable();

            if (!includeDeleted)
            {
                query = query.Where(f => !f.Deleted);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }

            QueryResponseModel<VFilm> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<FilmShortModel> result = new DataSourceResponseModel<FilmShortModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => x.ToShortModel())
            };

            return result;
        }

        public async Task<DataSourceResponseModel<FilmShortModel>> GetAllFromExternalSourceAsync(DataSourceRequestModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            int totalCount = 0;
            IEnumerable<FilmShortModel> items = Enumerable.Empty<FilmShortModel>();
            List<object> errors = new();

            try
            {
                string countQuery = "exec @ReturnValue = sp_GetFilmsCount @LinkedServer";

                List<SqlParameter> countQueryParams = new()
                {
                    new SqlParameter("LinkedServer", _linkedServerSettings.LinkedServer),
                };

                SqlParameter countQueryReturnValue = new()
                {
                    ParameterName = "ReturnValue",
                    SqlDbType = System.Data.SqlDbType.Int,
                    Direction = System.Data.ParameterDirection.Output
                };
                countQueryParams.Add(countQueryReturnValue);
                await _context.Database.ExecuteSqlRawAsync(countQuery, countQueryParams.ToArray());

                totalCount = (int)countQueryReturnValue.Value;
            }
            catch (Exception exc)
            {
                errors.Add(exc.ToString());
            }

            try
            {
                string query = "exec sp_GetFilms @LinkedServer, @PageSize, @PageNumber, @FundGid";
                List<SqlParameter> queryParams = new()
                {
                    new SqlParameter("LinkedServer", _linkedServerSettings.LinkedServer),
                    new SqlParameter("PageSize", model.ItemsPerPage),
                    new SqlParameter("PageNumber", model.Page),
                    new SqlParameter("FundGid", DBNull.Value),
                };
                var queryResult =
                    await _context.RemoteFilms
                            .FromSqlRaw(query, queryParams.ToArray())
                            .AsNoTracking()
                            .ToListAsync();

                items =
                    queryResult.Select(x => new FilmShortModel()
                    {
                        Id = x.Id.HasValue ? x.Id.Value : default(int),
                        HasExternalSource = x.HasExternalSource,
                        ExternalIdentifier = x.ExternalIdentifier,
                        ArchiveName = x.ArchiveName,
                        InventoryNumber = x.InventoryNumber,
                        CountryName = x.CountryName,
                        CountryCode = x.CountryCode,
                    });
            }
            catch (Exception exc)
            {
                errors.Add(exc.ToString());
            }

            DataSourceResponseModel<FilmShortModel> result = new()
            {
                TotalCount = totalCount,
                Errors = errors.Count > 0 ? errors : null,
                Items = items
            };

            return result;
        }

        public async Task<int?> GetFilmArchiveAsync(Guid filmSysId)
        {
            var entity =
                await _context.VFilms
                .Where(x => x.SystemIdentifier == filmSysId && !x.Deleted)
                .SingleOrDefaultAsync();

            return entity?.ArchiveId;
        }

        public async Task<int?> GetFilmDraftArchiveAsync(int draftId)
        {
            var entity =
                await _context.VFilms
                .Where(x => x.Id == draftId && !x.Deleted && x.IsDraft.HasValue && x.IsDraft.Value == true)
                .SingleOrDefaultAsync();

            return entity?.ArchiveId;
        }

        public async Task<FilmDisplayModel?> GetBySystemIdentifierAsync(Guid sysId)
        {
            var entity =
                await _context.VFilms
                .Where(x => x.SystemIdentifier == sysId && !x.Deleted)
                .SingleOrDefaultAsync();

            var model = entity?.ToDisplayModel();
            model = await SetProcessInfo(model);

            return model;
        }

        private async Task<FilmDisplayModel?> SetProcessInfo(FilmDisplayModel? model)
        {
            if (model == null)
            {
                return model;
            }

            var process = await _context.Processes
               .Include(t => t.ProcessType)
               .Include(s => s.ProcessTimelines)
               .Include(s => s.ProcessTimelines).ThenInclude(t => t.StepType)
               .Where(x => x.FilmSystemIdentifier == model.SystemIdentifier && !x.Deleted && !x.Completed)
               .SingleOrDefaultAsync();

            if (process != null)
            {
                var currentStep = process.ProcessTimelines.Where(t => !t.Completed).FirstOrDefault();

                model.CurrentProcessId = process.Id;
                model.CurrentProcessTypeId = process.ProcessTypeId;
                model.CurrentProcessTypeName = process.ProcessType.Name;
                model.CurrentStepId = currentStep?.Id;
                model.CurrentStepTypeId = currentStep?.StepTypeId;
                model.CurrentStepTypeName = currentStep?.StepType.Text;
                model.Comment = currentStep?.Comment;
            }

            var completedCardsProcess = await _context.ProcessTimelines
                .Where(x => x.StepTypeId == (int)ProcessStepType.Film_CardApproval
                    && x.Process.Completed
                    && x.Process.ProcessTypeId == (int)Shared.ProcessType.FilmRegisterCard
                    && x.Process.FilmSystemIdentifier == model.SystemIdentifier)
                .FirstOrDefaultAsync();

            model.HasCompletedCardsProcess = completedCardsProcess != null;

            return model;
        }

        public async Task<FilmDisplayModel?> GetFromExternalSourceAsync(int externalIdentifier, Guid? systemIdentifier = null)
        {
            string query = "exec sp_GetFilms @LinkedServer, @PageSize, @PageNumber, @FundGid";
            List<SqlParameter> queryParams = new List<SqlParameter>()
            {
                new SqlParameter("LinkedServer", _linkedServerSettings.LinkedServer),
                new SqlParameter("PageSize", 10),
                new SqlParameter("PageNumber", 1),
                new SqlParameter("FundGid", externalIdentifier),
            };
            var result =
                (await _context.RemoteFilms
                        .FromSqlRaw(query, queryParams.ToArray())
                        .AsNoTracking()
                        .ToListAsync())
                    .SingleOrDefault();

            if (result == null)
            {
                return null;
            }

            var archiveId = await _archiveService.GetArchiveIdByCodeAsync(result.ArchiveCode!.Value);
            if (!systemIdentifier.HasValue)
            {
                systemIdentifier = await GetSystemIdentifierByExternalIdentifierAsync(externalIdentifier);
            }

            return new FilmDisplayModel()
            {
                Id = result.Id!.Value,
                SystemIdentifier = systemIdentifier!.Value,
                ArchiveId = archiveId,
                ArchiveName = result.ArchiveName,
                InventoryNumber = int.Parse(result.InventoryNumber!),
                HasExternalSource = result.HasExternalSource,
                ExternalIdentifier = result.ExternalIdentifier,

                CountryName = result.CountryName,
                CountryCode = result.CountryCode,
                Content = result.Content,
                FramesCount = result.FramesCount,
                MicrofilmNegativeRollsCount = result.MicrofilmNegativeRollsCount,
                MicrofilmNegativeFramesCount = result.MicrofilmNegativeFramesCount,
                MicrofilmPositiveRollsCount = result.MicrofilmPositiveRollsCount,
                MicrofilmPositiveFramesCount = result.MicrofilmPositiveFramesCount,
                PhotoCopy = result.PhotoCopy.HasValue ? result.PhotoCopy.Value.ToString() : null,
                DigitalCopy = result.DigitalCopy.HasValue ? result.DigitalCopy.Value.ToString() : null,
                Other = result.Other,
                AcceptedOnDay = result.AcceptedOnDay,
                AcceptedOnMonth = result.AcceptedOnMonth,
                AcceptedOnYear = result.AcceptedOnYear,
                Source = result.Source,
                Notes = result.Notes,
            };
        }

        public async Task<Guid?> GetSystemIdentifierByExternalIdentifierAsync(int externalIdentifier)
        {
            return await _context.Films
                .Where(f => f.ExternalIdentifier == externalIdentifier)
                .Select(f => f.SystemIdentifier)
                .SingleOrDefaultAsync();
        }

        public async Task<OperationResult> CreateDraftAsync(FilmModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            using var transaction = _context.Database.BeginTransaction();

            try
            {
                model.SystemIdentifier = Guid.NewGuid();
                if (await IsUniqueInventoryNumber(model.InventoryNumber, model.SystemIdentifier) == false)
                {
                    throw new CustomException(_localizer.GetString("Error_InventoryNumberExists").ToString());
                }

                var film = model.ToDraftEntity();

                _context.FilmDrafts.Add(film);
                await _context.SaveAsync("Film draft created");


                Data.Process newProcess = new Data.Process
                {
                    ProcessTypeId = (int)Shared.ProcessType.FilmRegisterData,
                    ArchiveId = film.ArchiveId,
                    FilmSystemIdentifier = film.SystemIdentifier,
                    Completed = false
                };

                _context.Processes.Add(newProcess);
                await _context.SaveAsync("Film process created");


                ProcessTimeline step = new ProcessTimeline
                {
                    ProcessId = newProcess.Id,
                    StepTypeId = (int)ProcessStepType.Film_RegisterData,
                };

                _context.ProcessTimelines.Add(step);
                await _context.SaveAsync("Film process step created");

                transaction.Commit();
                return OperationResult.Succeed(film.SystemIdentifier);
            }
            catch (CustomException exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.Message);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        private async Task<OperationResult> CreateFilmAsync(FilmModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            try
            {
                var film = model.ToFilmEntity();

                var packageA = new FilmPackage
                {
                    Type = "A",
                };
                _context.FilmPackages.Add(packageA);
                await _context.SaveAsync("Created film package A");
                film.PackageAid = packageA.Id;

                var packageB = new FilmPackage
                {
                    Type = "B",
                };
                _context.FilmPackages.Add(packageB);
                await _context.SaveAsync("Created film package B");
                film.PackageBid = packageB.Id;


                _context.Films.Add(film);
                await _context.SaveAsync("Film created");

                await _docService.CopyPackageAsync(model.PackageAId!.Value, packageA.Id, FileStreamLocation.Adjunct, false);
                await _docService.CopyPackageAsync(model.PackageBId!.Value, packageB.Id, FileStreamLocation.Master, false);

                return OperationResult.Succeed(film.Id);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> PrepareDraftAsync(Guid sysId)
        {
            try
            {
                var film = await _context.Films.Where(x => x.SystemIdentifier == sysId).SingleAsync();
                if (film == null)
                {
                    return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                var draft = film.CopyEntity();

                var packageA = new FilmPackage { Type = "A" };
                _context.FilmPackages.Add(packageA);
                await _context.SaveAsync("Created film package A");
                draft.PackageAid = packageA.Id;
                await _docService.CopyPackageAsync(film.PackageAid!.Value, packageA.Id, FileStreamLocation.Buffer, true);

                var packageB = new FilmPackage { Type = "B" };
                _context.FilmPackages.Add(packageB);
                await _context.SaveAsync("Created film package B");
                draft.PackageBid = packageB.Id;
                await _docService.CopyPackageAsync(film.PackageBid!.Value, packageB.Id, FileStreamLocation.Buffer, true);

                _context.FilmDrafts.Add(draft);
                await _context.SaveAsync("Film draft created");

                var cardResult = await _cardService.PrepareDraftsAsync(sysId, draft.Id, packageB.Id);
                if (!cardResult.Succeeded)
                {
                    throw new Exception(String.Join("; ", cardResult.Errors));
                }

                return OperationResult.Succeed(film.Id);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> UpdateDraftAsync(FilmDraftModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            using var transaction = _context.Database.BeginTransaction();

            try
            {
                OperationResult result = await doUpdateDraft(model);
                if (!result.Succeeded)
                {
                    throw new Exception(String.Join("; ", result.Errors));
                }

                transaction.Commit();
                return OperationResult.Succeed(model.SystemIdentifier);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.Message.ToString());
            }
        }

        private async Task<OperationResult> doUpdateDraft(FilmDraftModel model)
        {
            var film = await _context.FilmDrafts
                .Where(x => x.Id == model.Id && !x.Deleted && x.IsCurrent && !x.ReadOnly)
                .FirstOrDefaultAsync();

            if (film == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_ItemOrDraftDoesNotExist").ToString());
            }

            var activeProcess = await _processService.GetCurrentActiveProcess(BusinessObjectType.Film, model.SystemIdentifier);
            if (activeProcess == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_NoActiveProcess").ToString());
            }

            if (activeProcess.ActiveProcessStepTypeId != (int)ProcessStepType.Film_RegisterData &&
                activeProcess.ActiveProcessStepTypeId != (int)ProcessStepType.Film_ReturnForEdit &&
                activeProcess.ActiveProcessStepTypeId != (int)ProcessStepType.Film_EditAllData &&
                activeProcess.ActiveProcessStepTypeId != (int)ProcessStepType.Film_ReturnAllForEdit)
            {
                return OperationResult.Failed(_localizer.GetString("Error_NoEditStep").ToString());
            }

            if (await IsUniqueInventoryNumber(model.InventoryNumber, model.SystemIdentifier) == false)
            {
                return OperationResult.Failed(_localizer.GetString("Error_InventoryNumberExists").ToString());
            }

            film.UpdateEntity(model);

            _context.Update(film);
            await _context.SaveAsync("Film draft updated");
            return OperationResult.Success;
        }


        public async Task<OperationResult> DeleteFilmAsync(Guid id)
        {
            using var transaction = _context.Database.BeginTransaction();

            try
            {
                bool hasActiveProcess = await _processService.HasCurrentActiveProcess(BusinessObjectType.Film, id);
                if (hasActiveProcess)
                {
                    transaction.Rollback();
                    return OperationResult.Failed(_localizer.GetString("Error_ItemHasActiveProcess").ToString());
                }

                OperationResult result = await doDelete(id);
                if (!result.Succeeded)
                {
                    throw new Exception(String.Join("; ", result.Errors));
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

        private async Task<OperationResult> doDelete(Guid sysId)
        {
            // delete film drafts
            var filmDrafts =
                    _context.FilmDrafts
                    .Where(x => x.SystemIdentifier == sysId && !x.Deleted)
                    .Select(x => x);

            foreach (var filmDraft in filmDrafts)
            {
                filmDraft.IsCurrent = false;
                filmDraft.ReadOnly = true;
                filmDraft.Deleted = true;
                filmDraft.DeletedBy = _userInfo.CurrentUserId;
                filmDraft.DeletedOn = DateTime.UtcNow;
                _context.Update(filmDraft);

                // delete draft packages
                if (filmDraft.PackageAid.HasValue)
                {
                    var result = await _docService.DeletePackageAsync(filmDraft.PackageAid.Value);
                    if (!result.Succeeded)
                    {
                        return result;
                    }
                }

                if (filmDraft.PackageBid.HasValue)
                {
                    var result = await _docService.DeletePackageAsync(filmDraft.PackageBid.Value);
                    if (!result.Succeeded)
                    {
                        return result;
                    }
                }

                // delete draft cards 
                var filmCardDrafts = _context.FilmCardDrafts
                    .Where(x => x.FilmSystemIdentifier == sysId && !x.Deleted)
                    .Select(x => x);

                foreach (var cardDraft in filmCardDrafts)
                {
                    var result = await _cardService.DeleteDraftInternalAsync(cardDraft.Id);
                    if (!result.Succeeded)
                    {
                        return result;
                    }
                }
            }

            // delete film 
            var film = await _context.Films
                .Where(x => x.SystemIdentifier == sysId && !x.Deleted)
                .SingleOrDefaultAsync();

            if (film == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            film.Deleted = true;
            film.DeletedOn = DateTime.UtcNow;
            film.DeletedBy = _userInfo.CurrentUserId;

            _context.Update(film);

            // delete film packages
            if (film.PackageAid.HasValue)
            {
                var result = await _docService.DeletePackageAsync(film.PackageAid.Value);
                if (!result.Succeeded)
                {
                    return result;
                }
            }

            if (film.PackageBid.HasValue)
            {
                var result = await _docService.DeletePackageAsync(film.PackageBid.Value);
                if (!result.Succeeded)
                {
                    return result;
                }
            }

            // delete cards 
            var filmCards = _context.FilmCards
                .Where(x => x.FilmSystemIdentifier == sysId && !x.Deleted)
                .Select(x => x);

            foreach (var card in filmCards)
            {
                var result = await _cardService.DeleteCardInternalAsync(card.Id);
                if (!result.Succeeded)
                {
                    return result;
                }
            }

            await _context.SaveAsync("Film deleted");

            return OperationResult.Success;
        }

        public async Task<OperationResult> DeleteDraftAsync(int id)
        {
            return OperationResult.Failed(_localizer.GetString("Error_ItemHasActiveProcess").ToString());

            //using var transaction = _context.Database.BeginTransaction();
            //try
            //{
            //    OperationResult result = await doDeleteDraft(id);
            //    if (!result.Succeeded)
            //    {
            //        throw new Exception(String.Join("; ", result.Errors));
            //    }

            //    transaction.Commit();
            //    return OperationResult.Success;
            //}
            //catch (Exception exc)
            //{
            //    transaction.Rollback();
            //    return OperationResult.Failed(exc.ToString());
            //}
        }

        private async Task<OperationResult> doDeleteDraft(int id)
        {
            var filmDraft = await _context.FilmDrafts.FindAsync(id);
            if (filmDraft == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (!filmDraft.IsCurrent)
            {
                return OperationResult.Failed(_localizer.GetString("Error_DraftNotCurrent").ToString());
            }

            filmDraft.IsCurrent = false;
            filmDraft.ReadOnly = true;
            filmDraft.Deleted = true;
            filmDraft.DeletedOn = DateTime.UtcNow;
            filmDraft.DeletedBy = _userInfo.CurrentUserId;

            _context.Update(filmDraft);

            //TODO: изтриване на пакети, картони, документи?

            //if(filmDraft.PackageAid != null)
            //{
            //    var result = await _docService.DeletePackageAsync(filmDraft.PackageAid.Value);
            //    if (!result.Succeeded)
            //    {
            //        throw new Exception(String.Join("; ", result.Errors));
            //    }
            //}

            //if (filmDraft.PackageBid != null)
            //{
            //    var result = await _docService.DeletePackageAsync(filmDraft.PackageBid.Value);
            //    if (!result.Succeeded)
            //    {
            //        throw new Exception(String.Join("; ", result.Errors));
            //    }
            //}            

            await _context.SaveAsync("Film draft deleted");
            return OperationResult.Success;
        }

        public async Task<OperationResult> ChangeStepAsync(FilmChangeStepModel model)
        {
            var film = await _context.FilmDrafts
                .Where(x => x.Id == model.FilmId && x.IsCurrent && !x.Deleted)
                .FirstOrDefaultAsync();

            if (film == null && !IsFilmCardStep(model))
            {
                return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            var currentProcess = await _context.Processes
                .Where(x => x.FilmSystemIdentifier == model.FilmSystemIdentifier && !x.Completed && !x.Deleted)
                .Include(x => x.ProcessTimelines)
                .FirstOrDefaultAsync();

            if (currentProcess == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            var currentStep = currentProcess?.ProcessTimelines.Where(t => !t.Completed).FirstOrDefault();
            if (currentStep == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (currentStep.StepTypeId == (int)model.StepType)
            {
                return OperationResult.Failed(_localizer.GetString("Error_SameStep").ToString());
            }

            if (film != null)
            {
                string validationErrors = await GetValidationErrors(film.Id, model.StepType);
                if (!String.IsNullOrWhiteSpace(validationErrors))
                {
                    return OperationResult.Failed(validationErrors);
                }
            }

            using var transaction = _context.Database.BeginTransaction();

            try
            {
                currentStep.Completed = true;
                _context.ProcessTimelines.Update(currentStep);
                await _context.SaveAsync("Completed film process step");

                bool isNewStepCompleted =
                    model.StepType == ProcessStepType.Film_Approval || model.StepType == ProcessStepType.Film_Rejection ||
                    model.StepType == ProcessStepType.Film_CardApproval || model.StepType == ProcessStepType.Film_CardRejection ||
                    model.StepType == ProcessStepType.Film_AllApproval || model.StepType == ProcessStepType.Film_AllRejection
                    ? true
                    : false;

                ProcessTimeline newStep = new ProcessTimeline
                {
                    ProcessId = currentStep.ProcessId,
                    StepTypeId = (int)model.StepType,
                    Completed = isNewStepCompleted,
                    Comment = String.IsNullOrWhiteSpace(model.Comment) ? null : model.Comment,
                    AssignedToUserId = String.IsNullOrWhiteSpace(model.AssignedToUserId) ? null : new Guid(model.AssignedToUserId),
                    AssignedToRoleId = String.IsNullOrWhiteSpace(model.AssignedToRoleId) ? null : new Guid(model.AssignedToRoleId),
                    EndDate = model.EndDate,
                };
                _context.ProcessTimelines.Add(newStep);
                await _context.SaveAsync("Film process step created");

                if (isNewStepCompleted)
                {
                    currentProcess.Completed = true;
                    _context.Processes.Update(currentProcess);
                    await _context.SaveAsync("Completed film process");
                }


                OperationResult finResult = await FinalizeStep(model, currentProcess!.Id, newStep.Id, currentProcess.CreatedBy, film);
                if (!finResult.Succeeded)
                {
                    transaction.Rollback();
                    return OperationResult.Failed(false, String.Join("; ", finResult.Errors));
                }

                transaction.Commit();

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                throw;
            }
        }

        private bool IsFilmCardStep(FilmChangeStepModel model)
        {
            return (model.StepType == ProcessStepType.Film_RegisterCardData ||
                model.StepType == ProcessStepType.Film_SendCardForApproval ||
                model.StepType == ProcessStepType.Film_CardApproval ||
                model.StepType == ProcessStepType.Film_ReturnCardForEdit ||
                model.StepType == ProcessStepType.Film_EditCardData ||
                model.StepType == ProcessStepType.Film_CardRejection);
        }

        public async Task<OperationResult> CreateOrUpdateFilmFromDraftAsync(Guid sysId)
        {
            try
            {
                var filmDraft = await _context.FilmDrafts
                    .Where(x => x.SystemIdentifier == sysId && x.IsCurrent && !x.Deleted)
                    .SingleOrDefaultAsync();

                if (filmDraft == null)
                {
                    return OperationResult.Failed($"There is no current draft for system identifier {sysId}");
                }

                var filmModel = filmDraft.ToFilmDraftModel();

                var film =
                    await _context.Films
                    .Where(x => x.SystemIdentifier == sysId && !x.Deleted)
                    .SingleOrDefaultAsync();

                if (film != null)
                {
                    film.UpdateEntity(filmDraft);

                    await _docService.UpdatePackageAsync(filmDraft.PackageAid!.Value, film.PackageAid!.Value, FileStreamLocation.Adjunct);
                    await _docService.UpdatePackageAsync(filmDraft.PackageBid!.Value, film.PackageBid!.Value, FileStreamLocation.Master);
                }
                else
                {
                    var filmCreateResult = await CreateFilmAsync(filmModel);
                    if (!filmCreateResult.Succeeded)
                    {
                        return filmCreateResult;
                    }
                }

                filmDraft.IsCurrent = false;
                filmDraft.ReadOnly = true;
                _context.Update(filmDraft);

                return OperationResult.Succeed(sysId);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }


        public async Task<int> GetNextInventoryNumber()
        {
            int? maxFilm = 0;
            int? maxDraft = 0;
            if (await _context.Films.AnyAsync())
            {
                maxFilm = await _context.Films
                    .Where(x => !x.Deleted)
                    .MaxAsync(x => (int?)x.InventoryNumber) ?? 0;
            }

            if (await _context.FilmDrafts.AnyAsync())
            {
                maxDraft = await _context.FilmDrafts
                    .Where(x => !x.Deleted && x.IsCurrent)
                    .MaxAsync(x => (int?)x.InventoryNumber) ?? 0;
            }

            return maxFilm.Value > maxDraft.Value ? maxFilm.Value + 1 : maxDraft.Value + 1;
        }

        private async Task<bool> IsUniqueInventoryNumber(int inventoryNumber, Guid id)
        {
            var existingFilm = await _context.Films
                .Where(x => x.InventoryNumber == inventoryNumber && x.SystemIdentifier != id && !x.Deleted)
                .ToListAsync();

            var existingDraft = await _context.FilmDrafts
                .Where(x => x.InventoryNumber == inventoryNumber && x.SystemIdentifier != id && !x.Deleted && x.IsCurrent)
                .ToListAsync();

            return (existingFilm == null || existingFilm.Count == 0) && (existingDraft == null || existingDraft.Count == 0);
        }

        private async Task<string> GetValidationErrors(int draftId, ProcessStepType stepType)
        {
            List<string> errors = new List<string>();

            if (stepType == ProcessStepType.Film_SendForApproval)
            {
                if (await IsPackageDataValid(draftId, "A") == false)
                {
                    errors.Add(_localizer.GetString("MissingRequiredFilmPackageADocument").ToString());
                }

                if (await IsPackageDataValid(draftId, "B") == false)
                {
                    errors.Add(_localizer.GetString("MissingRequiredFilmPackageBDocument").ToString());
                }
            }

            return String.Join(Environment.NewLine, errors);
        }

        private async Task<bool> IsPackageDataValid(int filmDraftId, string packageType)
        {
            var requiredDocTypes = await _context.FilmDocumentTypes
                .Where(x => x.PackageType == packageType && x.IsRequired == true)
                .Select(x => x.Id)
                .ToListAsync();

            var film = await _context.FilmDrafts
                .Include(x => x.PackageA).ThenInclude(p => p.FilmPackageDocuments.Where(d => !d.Deleted && d.FilePath != null))
                .Include(x => x.PackageB).ThenInclude(p => p.FilmPackageDocuments.Where(d => !d.Deleted && d.FilePath != null))
                .Where(x => x.Id == filmDraftId)
                .FirstOrDefaultAsync();

            var filmADocTypes = film?.PackageA?.FilmPackageDocuments.Select(x => x.DocumentTypeId).ToList();
            var filmBDocTypes = film?.PackageB?.FilmPackageDocuments.Select(x => x.DocumentTypeId).ToList();
            var docsCount = 0;

            bool existMissingRequired = false;
            if (packageType == "A")
            {
                existMissingRequired = requiredDocTypes.Count() > 0
                    ? requiredDocTypes.Where(x => !filmADocTypes!.Contains(x)).Count() > 0
                    : false;
                docsCount = filmADocTypes!.Count();
            }
            else if (packageType == "B")
            {
                existMissingRequired = requiredDocTypes.Count() > 0
                    ? requiredDocTypes.Where(x => !filmBDocTypes!.Contains(x)).Count() > 0
                    : false;
                docsCount = filmBDocTypes!.Count();
            }

            var result = !existMissingRequired && (docsCount > 0);
            return result;
        }

        private async Task<OperationResult> FinalizeStep(FilmChangeStepModel model, int processId, int timelineId, Guid? processCreatedBy, FilmDraft film)
        {
            switch (model.StepType)
            {
                case ProcessStepType.Film_CreatePackages:
                    if (!film.PackageAid.HasValue)
                    {
                        var packageA = new FilmPackage
                        {
                            Type = "A",
                        };
                        _context.FilmPackages.Add(packageA);
                        await _context.SaveAsync("Created film packages");

                        film.PackageAid = packageA.Id;
                    }

                    if (!film.PackageBid.HasValue)
                    {
                        var packageB = new FilmPackage
                        {
                            Type = "B",
                        };
                        _context.FilmPackages.Add(packageB);
                        await _context.SaveAsync("Created film packages");

                        film.PackageBid = packageB.Id;
                    }

                    _context.FilmDrafts.Update(film);
                    await _context.SaveAsync("Updated film draft");
                    break;

                case ProcessStepType.Film_SendForApproval:
                case ProcessStepType.Film_SendCardForApproval:
                case ProcessStepType.Film_SendAllForApproval:
                    int editStep =
                        model.StepType == ProcessStepType.Film_SendForApproval
                        ? (int)ProcessStepType.Film_ReturnForEdit
                        : model.StepType == ProcessStepType.Film_SendCardForApproval
                            ? (int)ProcessStepType.Film_ReturnCardForEdit
                            : model.StepType == ProcessStepType.Film_SendAllForApproval
                                ? (int)ProcessStepType.Film_ReturnAllForEdit
                                : (int)ProcessStepType.NoStep;


                    var editTasks = _context.Tasks
                    .Where(x => x.ProcessId == processId && x.Step.StepTypeId == editStep && x.StatusCode == Shared.TaskStatus.Pending)
                    .AsQueryable();

                    if (editTasks != null && editTasks.Count() > 0)
                    {
                        OperationResult taskResult = OperationResult.Success;
                        foreach (var task in editTasks)
                        {
                            taskResult = await _taskService.ChangeTaskStatus(task.Id, Shared.TaskStatus.Completed);
                            if (!taskResult.Succeeded)
                            {
                                return taskResult;
                            }
                        }
                    }

                    TaskCreateModel taskModel = new TaskCreateModel
                    {
                        StepType = model.StepType,
                        ProcessId = processId,
                        TimelineId = timelineId,
                        EntityType = EntityType.film,
                        EntityId = model.FilmId,
                        EntitySystemIdentifier = model.FilmSystemIdentifier,
                        AssignedToUserId = model.AssignedToUserId,
                        AssignedToRoleId = model.AssignedToRoleId,
                        EndDate = model.EndDate
                    };
                    return await _taskService.CreateAsync(taskModel);

                case ProcessStepType.Film_Approval:
                case ProcessStepType.Film_ReturnForEdit:
                case ProcessStepType.Film_Rejection:

                case ProcessStepType.Film_CardApproval:
                case ProcessStepType.Film_ReturnCardForEdit:
                case ProcessStepType.Film_CardRejection:

                case ProcessStepType.Film_AllApproval:
                case ProcessStepType.Film_ReturnAllForEdit:
                case ProcessStepType.Film_AllRejection:
                    if (model.StepType == ProcessStepType.Film_Rejection || model.StepType == ProcessStepType.Film_AllRejection)
                    {
                        OperationResult result = await doDeleteDraft(model.FilmId);
                        if (!result.Succeeded)
                        {
                            return result;
                        }
                    }

                    if (model.StepType == ProcessStepType.Film_CardRejection || model.StepType == ProcessStepType.Film_AllRejection)
                    {
                        OperationResult result = await _cardService.DeleteAllDraftsAsync(model.FilmSystemIdentifier);
                        if (!result.Succeeded)
                        {
                            return result;
                        }
                    }

                    if (model.StepType == ProcessStepType.Film_Approval || model.StepType == ProcessStepType.Film_AllApproval)
                    {
                        OperationResult result = await CreateOrUpdateFilmFromDraftAsync(model.FilmSystemIdentifier);
                        if (!result.Succeeded)
                        {
                            return result;
                        }
                    }

                    if (model.StepType == ProcessStepType.Film_CardApproval || model.StepType == ProcessStepType.Film_AllApproval)
                    {
                        OperationResult result = await _cardService.CreateOrUpdateFilmCardsFromDraftAsync(model.FilmSystemIdentifier);
                        if (!result.Succeeded)
                        {
                            return result;
                        }
                    }

                    int approvalStep =
                        model.StepType == ProcessStepType.Film_Approval || model.StepType == ProcessStepType.Film_ReturnForEdit || model.StepType == ProcessStepType.Film_Rejection
                        ? (int)ProcessStepType.Film_SendForApproval
                        : model.StepType == ProcessStepType.Film_CardApproval || model.StepType == ProcessStepType.Film_ReturnCardForEdit || model.StepType == ProcessStepType.Film_CardRejection
                            ? (int)ProcessStepType.Film_SendCardForApproval
                            : model.StepType == ProcessStepType.Film_AllApproval || model.StepType == ProcessStepType.Film_ReturnAllForEdit || model.StepType == ProcessStepType.Film_AllRejection
                                ? (int)ProcessStepType.Film_SendAllForApproval
                                : (int)ProcessStepType.NoStep;


                    var tasks = _context.Tasks
                    .Where(x => x.ProcessId == processId && x.Step.StepTypeId == approvalStep && x.StatusCode == Shared.TaskStatus.Pending)
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

                    if (model.StepType == ProcessStepType.Film_ReturnForEdit ||
                        model.StepType == ProcessStepType.Film_ReturnCardForEdit ||
                        model.StepType == ProcessStepType.Film_ReturnAllForEdit)
                    {
                        TaskCreateModel returnForEditTaskModel = new TaskCreateModel
                        {
                            StepType = model.StepType,
                            ProcessId = processId,
                            TimelineId = timelineId,
                            EntityType = EntityType.film,
                            EntityId = model.FilmId,
                            EntitySystemIdentifier = model.FilmSystemIdentifier,
                            AssignedToUserId = processCreatedBy != null ? processCreatedBy!.Value.ToString("D") : "",
                            EndDate = model.EndDate
                        };

                        OperationResult returnForEditTaskResult = await _taskService.CreateAsync(returnForEditTaskModel);
                        if (!returnForEditTaskResult.Succeeded)
                        {
                            return returnForEditTaskResult;
                        }
                    }

                    break;

                default:
                    break;
            }

            return OperationResult.Success;
        }

        public async Task<OperationResult> StartProcessAsync(ProcessModel model)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                bool hasActiveProcess = false;
                if (model.FilmSystemIdentifier.HasValue)
                {
                    hasActiveProcess = await _processService.HasCurrentActiveProcess(BusinessObjectType.Film, model.FilmSystemIdentifier.Value);
                }

                if (hasActiveProcess)
                {
                    throw new CustomException(_localizer.GetString("Error_EntityAlreadyHasProcess").ToString());
                }

                Data.Process newProcess = await _processService.CreateProcessAsync(model);

                Shared.ProcessType processTypeId = (Shared.ProcessType)model.ProcessTypeId;
                ProcessStepType stepType = ProcessStepType.NoStep;
                if (model.FilmSystemIdentifier.HasValue)
                {
                    switch (processTypeId)
                    {
                        case Shared.ProcessType.FilmEditData:
                            stepType = ProcessStepType.Film_EditAllData;

                            OperationResult filmDraftResult = await PrepareDraftAsync(model.FilmSystemIdentifier.Value);
                            if (!filmDraftResult.Succeeded)
                            {
                                throw new CustomException(_localizer.GetString("Error_CreatingDraft").ToString());
                            }
                            break;
                        default:
                            stepType = ProcessStepType.Film_RegisterCardData;
                            break;
                    }
                }

                await _processService.AddStepAsync(newProcess.Id, (int)stepType);
                transaction.Commit();

                return OperationResult.Succeed(newProcess.Id);
            }
            catch (CustomException ex)
            {
                transaction.Rollback();
                return OperationResult.Failed(ex.Message);
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        public DataSourceResponseModel<FilmReviewDisplayModel> GetAllFilmReviews(DataSourceRequestModel model, bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.VFilmReviews
                .Select(f => new FilmReviewDisplayModel()
                {
                    SystemIdentifier = f.SystemIdentifier,
                    CreatedOn = f.CreatedOn,
                    CreatedBy = f.CreatedBy,
                    UpdatedOn = f.UpdatedOn,
                    UpdatedBy = f.UpdatedBy,
                    UserId = f.UserId,
                    Username = f.Username,
                    ReaderName = f.ReaderName,
                    FilmSystemIdentifier = f.FilmSystemIdentifier,
                    AccessAllowed = f.AccessAllowed!,
                    Deleted = f.Deleted,
                    CreatedByDisplayName = f.CreatedByDisplayName,
                    UpdatedByDisplayName = f.UpdatedByDisplayName,
                    CreatedByUserName = f.CreatedByUserName,
                    UpdatedByUserName = f.UpdatedByUserName,
                    DeletedByDisplayName = f.DeletedByUserName,
                    DeletedByUserName = f.DeletedByUserName,
                    DeletedBy = f.DeletedBy,
                    DeletedOn = f.DeletedOn,
                    FilmInventoryNumber = f.FilmInventoryNumber,
                    FilmNumber = f.FilmNumber,
                });

            if (!includeDeleted)
            {
                query = query.Where(f => !f.Deleted);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }

            QueryResponseModel<FilmReviewDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<FilmReviewDisplayModel> result = new DataSourceResponseModel<FilmReviewDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => x)
            };

            return result;
        }

        public async Task<OperationResult> CreateFilmReviewAsync(FilmReviewModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            try
            {
                model.SystemIdentifier = Guid.NewGuid();
                FilmReview entity = new()
                {
                    SystemIdentifier = model.SystemIdentifier,
                    ReaderName = model.ReaderName,
                    FilmSystemIdentifier = model.FilmSystemIdentifier,
                    UserId = model.UserId,
                    CreatedBy = _userInfo.CurrentUserId,
                    CreatedOn = DateTime.Now,
                };


                _context.FilmReviews.Add(entity);

                _context.SaveChanges();

                return OperationResult.Succeed(entity.Id);
            }
            catch (Exception ex)
            {
                return OperationResult.Failed(ex.ToString());
            }
        }

        public async Task<OperationResult> UpdateFilmReviewAsync(FilmReviewModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            try
            {
                var result = await _context.FilmReviews.Where(f => f.SystemIdentifier == model.SystemIdentifier).FirstOrDefaultAsync();

                if (result != null)
                {
                    result.AccessAllowed = false;
                    result.UpdatedOn = DateTime.Now;
                    result.UpdatedBy = _userInfo.CurrentUserId;

                    _context.FilmReviews.Update(result);

                    _context.SaveChanges();

                    return OperationResult.Success;
                }

                return OperationResult.Failed("");
            }
            catch (Exception ex)
            {
                return OperationResult.Failed(ex.ToString());
            }
        }
    }
}
