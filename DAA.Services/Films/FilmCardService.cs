using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Models;
using DAA.Models.Configuration;
using DAA.Models.Films;
using DAA.Services.Nomenclatures;
using DAA.Services.Process;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;
using System.Text;
using Task = System.Threading.Tasks.Task;

namespace DAA.Services.Films
{
    public class FilmCardService : BaseService, IFilmCardService
    {
        private readonly IUserInfo _userInfo;
        private readonly INomenclatureService _nomenclatureService;
        private readonly LinkedServerSettings _linkedServerSettings;
        private readonly IArchiveService _archiveService;
        private readonly IProcessService _processService;

        public FilmCardService(
            ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            IOptions<LinkedServerSettings> settings,
            IUserInfo userInfo,
            INomenclatureService nomenclatureService,
            IArchiveService archiveService,
            IProcessService processService)
            : base(context, localizer)
        {
            _userInfo = userInfo;
            _nomenclatureService = nomenclatureService;
            _linkedServerSettings = settings.Value;
            _archiveService = archiveService;
            _processService = processService;
        }

        public DataSourceResponseModel<FilmCardShortModel> GetAll(DataSourceRequestModel model, Guid? filmSysId, bool includeDeleted = false)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.VFilmCards
                .Where(x => x.FilmSystemIdentifier == filmSysId)
                .OrderBy(x => x.InventoryNumber)
                .AsQueryable();

            if (!includeDeleted)
            {
                query = query.Where(f => !f.Deleted);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }

            QueryResponseModel<VFilmCard> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<FilmCardShortModel> result = new DataSourceResponseModel<FilmCardShortModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(x => x.ToShortModel())
            };

            return result;
        }

        public async Task<DataSourceResponseModel<FilmCardShortModel>> GetAllFromExternalSourceAsync(DataSourceRequestModel model, int? externalIdentifier)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            int totalCount = 0;
            IEnumerable<FilmCardShortModel> items = Enumerable.Empty<FilmCardShortModel>();
            List<object> errors = new();

            try
            {
                string countQuery = "exec @ReturnValue = sp_GetFilmCardsCount @LinkedServer, @FundExternalIdentifier";

                List<SqlParameter> countQueryParams = new()
                {
                    new SqlParameter("LinkedServer", _linkedServerSettings.LinkedServer),
                    new SqlParameter("FundExternalIdentifier", externalIdentifier.HasValue ? externalIdentifier.Value : DBNull.Value),
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
                string query = "exec sp_GetFilmCards @LinkedServer, @PageSize, @PageNumber, @FundGid, @ArchiveEntityGid";
                List<SqlParameter> queryParams = new()
                {
                    new SqlParameter("LinkedServer", _linkedServerSettings.LinkedServer),
                    new SqlParameter("PageSize", model.ItemsPerPage),
                    new SqlParameter("PageNumber", model.Page),
                    new SqlParameter("FundGid", externalIdentifier.HasValue ? externalIdentifier.Value : DBNull.Value),
                    new SqlParameter("ArchiveEntityGid", DBNull.Value),
                };
                var queryResult =
                    await _context.RemoteFilmCards
                            .FromSqlRaw(query, queryParams.ToArray())
                            .AsNoTracking()
                            .ToListAsync();

                items =
                    queryResult.Select(x => new FilmCardShortModel()
                    {
                        Id = x.Id,
                        //SystemIdentifier = ??,
                        //IsDraft = ??,
                        //FilmSystemIdentifier = ??,
                        HasExternalSource = x.HasExternalSource,
                        ExternalIdentifier = x.ExternalIdentifier,
                        FilmExternalIdentifier = x.FilmExternalIdentifier,
                        CountryCode = x.CountryCode,
                        CountryName = x.CountryName,
                        InventoryNumber = x.InventoryNumber ?? "",
                        Title = x.Title,
                    });
            }
            catch (Exception exc)
            {
                errors.Add(exc.ToString());
            }

            DataSourceResponseModel<FilmCardShortModel> result = new()
            {
                TotalCount = totalCount,
                Errors = errors.Count > 0 ? errors : null,
                Items = items
            };

            return result;
        }

        public async Task<FilmDisplayModel> GetParentData(Guid filmSysId)
        {
            var film =
                await _context.VFilms
                .Where(x => x.SystemIdentifier == filmSysId && !x.Deleted)
                .Select(x => new FilmDisplayModel()
                {
                    Id = x.Id,
                    SystemIdentifier = x.SystemIdentifier,
                    ArchiveId = x.ArchiveId,
                    ArchiveName = x.ArchiveName,
                    InventoryNumber = x.InventoryNumber,
                    CountryId = x.CountryId,
                    CountryName = x.CountryName,
                    CountryCode = x.CountryCode,
                    Source = x.Source,
                })
                .FirstOrDefaultAsync();

            return film!;
        }

        private async Task<OperationResult> CanManipulateCard(Guid filmSystemIdentifier)
        {
            var activeProcess = await _processService.GetCurrentActiveProcess(BusinessObjectType.Film, filmSystemIdentifier);
            if (activeProcess == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_NoActiveProcess").ToString());
            }

            if (activeProcess.ActiveProcessStepTypeId != (int)ProcessStepType.Film_RegisterCardData &&
                activeProcess.ActiveProcessStepTypeId != (int)ProcessStepType.Film_ReturnCardForEdit &&
                activeProcess.ActiveProcessStepTypeId != (int)ProcessStepType.Film_EditAllData &&
                activeProcess.ActiveProcessStepTypeId != (int)ProcessStepType.Film_ReturnAllForEdit)
            {
                return OperationResult.Failed(_localizer.GetString("Error_NoEditStep").ToString());
            }

            return OperationResult.Success;
        }

        public async Task<OperationResult> CreateDraftAsync(FilmCardModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            using var transaction = _context.Database.BeginTransaction();

            try
            {
                OperationResult result = await doCreateDraft(model, true);
                if (!result.Succeeded)
                {
                    transaction.Rollback();
                    return result;
                }

                transaction.Commit();
                return result;
            }
            catch (Exception exc)
            {
                transaction.Rollback();
                return OperationResult.Failed(exc.ToString());
            }
        }

        private async Task<OperationResult> doCreateDraft(FilmCardModel model, bool generateGuid)
        {
            OperationResult manipulateResult = await CanManipulateCard(model.FilmSystemIdentifier);
            if (!manipulateResult.Succeeded)
            {
                return manipulateResult;
            }

            if (generateGuid)
            {
                model.SystemIdentifier = Guid.NewGuid();
            }

            if (await IsUniqueInventoryNumber(model.InventoryNumber, model.SystemIdentifier) == false)
            {
                return OperationResult.Failed(_localizer.GetString("Error_InventoryNumberExists").ToString());
            }

            if (await AreDocumentsUsed(model.DocumentIds, model.Id, model.SystemIdentifier) == true)
            {
                return OperationResult.Failed(_localizer.GetString("Error_CardDocumentAlreadyUsed").ToString());
            }

            var card = model.ToDraftEntity();
            _context.FilmCardDrafts.Add(card);
            await _context.SaveAsync("Film card draft created");

            await AddLanguageCodes(model, card.Id, true);
            await AddCardDocuments(model, card.Id, true);

            await UpdateFilmCardSizeAndFormat(card, model.DocumentIds);

            return OperationResult.Succeed(card.SystemIdentifier);
        }

        public async Task<OperationResult> UpdateDraftAsync(FilmCardDraftModel model)
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
                    transaction.Rollback();
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

        private async Task<OperationResult> doUpdateDraft(FilmCardDraftModel model)
        {
            OperationResult manipulateResult = await CanManipulateCard(model.FilmSystemIdentifier);
            if (!manipulateResult.Succeeded)
            {
                return manipulateResult;
            }

            var card = await _context.FilmCardDrafts
                .Where(x => x.SystemIdentifier == model.SystemIdentifier && x.IsCurrent)
                .FirstOrDefaultAsync();

            if (card == null)
            {
                OperationResult result = await doCreateDraft(model, false);
                if (!result.Succeeded)
                {
                    return result;
                }

                card = await _context.FilmCardDrafts
                    .Where(x => x.SystemIdentifier == model.SystemIdentifier && x.IsCurrent)
                    .FirstOrDefaultAsync();
            }

            if (card == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            if (await IsUniqueInventoryNumber(model.InventoryNumber, model.SystemIdentifier) == false)
            {
                return OperationResult.Failed(_localizer.GetString("Error_InventoryNumberExists").ToString());
            }

            if (await AreDocumentsUsed(model.DocumentIds, model.Id, model.SystemIdentifier) == true)
            {
                return OperationResult.Failed(_localizer.GetString("Error_CardDocumentAlreadyUsed").ToString());
            }

            model.IsCurrent = true;
            model.ReadOnly = false;
            card.UpdateEntity(model);
            _context.Update(card);

            model.Id = card.Id;

            await UpdateLanguageCodes(model, true);
            await UpdateCardDocuments(model, true);

            await _context.SaveAsync("Film card draft updated");

            await UpdateFilmCardSizeAndFormat(card, model.DocumentIds);

            return OperationResult.Success;
        }

        private async Task<OperationResult> doUpdateFilmCard(FilmCard card, FilmCardDraftModel model)
        {
            card.UpdateEntity(model);
            _context.Update(card);

            model.Id = card.Id;

            await UpdateLanguageCodes(model, false);
            await UpdateCardDocuments(model, false);

            await _context.SaveAsync("Film card updated");
            return OperationResult.Success;
        }

        private async Task AddLanguageCodes(FilmCardModel model, int cardId, bool isDraft)
        {
            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(model.LanguageCodes, null, Shared.NomenclatureCode.Language, cardId, BusinessObjectType.FilmCard, isDraft);

                if (languageValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(languageValuesToAdd!);
                    await _context.SaveAsync("Film card language codes created");
                }
            }
        }

        private async Task AddCardDocuments(FilmCardModel model, int cardId, bool isDraft)
        {
            if (model.DocumentIds == null || model.DocumentIds.Count() == 0)
            {
                return;
            }

            foreach (int docId in model.DocumentIds)
            {
                FilmCardDocument cardDoc = new FilmCardDocument
                {
                    CardId = cardId,
                    PackageDocumentId = docId,
                    IsDraft = isDraft,
                };
                _context.FilmCardDocuments.Add(cardDoc);
            }
            await _context.SaveAsync("Film card documents created");
        }

        private async Task UpdateLanguageCodes(FilmCardModel model, bool isDraft)
        {
            var existingValues = _nomenclatureService.GetEntityNomenclatureValues(model.Id, BusinessObjectType.FilmCard, isDraft, Shared.NomenclatureCode.Language);

            if (model.LanguageCodes?.Count() > 0)
            {
                var languageValuesToAdd = _nomenclatureService.GetEntityNomenclatureValuesToAdd(
                    model.LanguageCodes, existingValues, Shared.NomenclatureCode.Language, 
                    model.Id, BusinessObjectType.FilmCard, isDraft);

                if (languageValuesToAdd != null)
                {
                    _context.NomenclatureValues.AddRange(languageValuesToAdd);
                }
            }

            var languageValuesToDelete = _nomenclatureService.GetEntityNomenclatureValuesToDelete(model.LanguageCodes, existingValues, Shared.NomenclatureCode.Language);
            if(languageValuesToDelete != null)
            {
                _context.NomenclatureValues.RemoveRange(languageValuesToDelete);
            }

            await _context.SaveAsync("Film card language codes updated");
        }

        private async Task UpdateCardDocuments(FilmCardModel model, bool isDraft)
        {
            List<FilmCardDocument> docsToAdd = new List<FilmCardDocument>();
            List<FilmCardDocument> docsToDelete = new List<FilmCardDocument>();

            var existingDocs = await _context.FilmCardDocuments
                .Where(x => x.CardId == model.Id && x.IsDraft == isDraft)
                .ToListAsync();

            if (model.DocumentIds != null && model.DocumentIds.Count() > 0)
            {
                foreach (int id in model.DocumentIds)
                {
                    var existing = existingDocs
                        .Where(x => x.PackageDocumentId == id)
                        .FirstOrDefault();

                    if (existing == null)
                    {
                        FilmCardDocument cardDoc = new FilmCardDocument
                        {
                            CardId = model.Id,
                            PackageDocumentId = id,
                            IsDraft = isDraft
                        };
                        docsToAdd.Add(cardDoc);
                    }
                }

                docsToDelete = existingDocs.Where(x => !model.DocumentIds.Contains(x.PackageDocumentId)).ToList();
            }
            else
            {
                docsToDelete = existingDocs.ToList();
            }

            await _context.FilmCardDocuments.AddRangeAsync(docsToAdd);
            _context.FilmCardDocuments.RemoveRange(docsToDelete);
            await _context.SaveAsync("Film card documents updated");
        }

        private async Task<bool> IsUniqueInventoryNumber(string inventoryNumber, Guid id)
        {
            var existingCard = await _context.FilmCards
                .Where(x => x.InventoryNumber == inventoryNumber && x.SystemIdentifier != id && !x.Deleted)
                .ToListAsync();

            var existingDraft = await _context.FilmCardDrafts
                .Where(x => x.InventoryNumber == inventoryNumber && x.SystemIdentifier != id && !x.Deleted && x.IsCurrent)
                .ToListAsync();

            return (existingCard == null || existingCard.Count == 0) && (existingDraft == null || existingDraft.Count == 0);
        }

        private async Task<bool> AreDocumentsUsed(IEnumerable<int>? docIds, int cardId, Guid cardSysId)
        {
            if (docIds == null || docIds.Count() == 0)
            {
                return false;
            }

            var cardsUsingDocuments = await _context.FilmCardDocuments
                .Where(x => x.CardId != cardId && docIds.Contains(x.PackageDocumentId))
                .ToListAsync();

            var cardIds = cardsUsingDocuments.Where(x => !x.IsDraft).Select(x => x.CardId).ToList();
            var cardDraftIds = cardsUsingDocuments.Where(x => x.IsDraft).Select(x => x.CardId).ToList();

            var activeCards = await _context.FilmCards
                .Where(x => cardIds.Contains(x.Id) && x.SystemIdentifier != cardSysId && !x.Deleted)
                .Select(x => x.SystemIdentifier)
                .ToListAsync();

            // some active cards may have an active deleted draft!
            var deletedCards = await _context.FilmCardDrafts
                .Where(x => activeCards.Contains(x.SystemIdentifier) && x.Deleted && x.IsCurrent)
                .Select(x => x.SystemIdentifier)
                .ToListAsync();
            activeCards = activeCards.Where(x => !deletedCards.Contains(x)).ToList();

            // some active cards may have an active draft which does not use that document anymore!
            var editedCards = await _context.FilmCardDrafts
                .Where(x => activeCards.Contains(x.SystemIdentifier) && x.IsCurrent && !cardDraftIds.Contains(x.Id))
                .Select(x => x.SystemIdentifier)
                .ToListAsync();
            activeCards = activeCards.Where(x => !editedCards.Contains(x)).ToList();

            var activeDraftCards = await _context.FilmCardDrafts
                .Where(x => cardDraftIds.Contains(x.Id) && x.SystemIdentifier != cardSysId && !x.Deleted && x.IsCurrent)
                .Select(x => x.SystemIdentifier)
                .ToListAsync();

            return (activeCards != null && activeCards.Count > 0) || (activeDraftCards != null && activeDraftCards.Count > 0);
        }

        public async Task<FilmCardDisplayModel?> GetBySystemIdentifierAsync(Guid sysId)
        {
            var filmCardDraft = await GetCurrentDraftAsync(sysId);
            if (filmCardDraft != null)
            {
                return filmCardDraft;
            }

            var entity =
                await _context.VFilmCards
                .Where(x => x.SystemIdentifier == sysId && (!x.IsDraft.HasValue || x.IsDraft.Value == false) && !x.Deleted)
                .SingleOrDefaultAsync();

            if (entity != null)
            {
                var model = entity.ToDisplayModel();

                model.LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(entity.Id, BusinessObjectType.FilmCard, false, Shared.NomenclatureCode.Language);
                model.LanguageText = _nomenclatureService.GetEntityNomenclatureText(entity.Id, BusinessObjectType.FilmCard, false, Shared.NomenclatureCode.Language);

                model.DocumentIds = _context.FilmCardDocuments
                    .Include(x => x.PackageDocument)
                    .ThenInclude(d => d.Package)
                    .ThenInclude(p => p.FilmPackageBs)
                    .Where(x => x.CardId == entity.Id && !x.IsDraft &&
                        x.PackageDocument.Package.FilmPackageBs.Where(b => b.SystemIdentifier == model.FilmSystemIdentifier).Any())
                    .Select(d => d.PackageDocumentId).AsEnumerable();

                return model;
            }

            return null;
        }

        public async Task<FilmCardDisplayModel?> GetFromExternalSourceAsync(int externalIdentifier, Guid? systemIdentifier = null)
        {
            string query = "exec sp_GetFilmCards @LinkedServer, @PageSize, @PageNumber, @FundGid, @ArchiveEntityGid";
            List<SqlParameter> queryParams = new()
                {
                    new SqlParameter("LinkedServer", _linkedServerSettings.LinkedServer),
                    new SqlParameter("PageSize", 10),
                    new SqlParameter("PageNumber", 1),
                    new SqlParameter("FundGid", DBNull.Value),
                    new SqlParameter("ArchiveEntityGid", externalIdentifier),
                };

            var result =
                (await _context.RemoteFilmCards
                        .FromSqlRaw(query, queryParams.ToArray())
                        .AsNoTracking()
                        .ToListAsync())
                    .SingleOrDefault();

            if (result == null)
            {
                return null;
            }

            var archiveId = await _archiveService.GetArchiveIdByCodeAsync(result.ArchiveCode!.Value);
            //if (!systemIdentifier.HasValue)
            //{
            //    systemIdentifier = await GetSystemIdentifierByExternalIdentifierAsync(externalIdentifier);
            //}

            return new FilmCardDisplayModel()
            {
                Id = result.Id,
                SystemIdentifier = systemIdentifier.HasValue ? systemIdentifier.Value : default(Guid),
                //FilmSystemIdentifier = result.FilmSystemIdentifier,
                HasExternalSource = result.HasExternalSource,
                ExternalIdentifier = result.ExternalIdentifier,
                ArchiveId = archiveId,
                ArchiveName = String.Format("{0} - {1}", result.ArchiveName, result.ArchiveCode),
                CountryName = result.CountryName,
                CountryCode = result.CountryCode,
                City = result.City,
                DocumentsCypher = result.DocumentsCypher,
                Title = result.Title,
                ArchiveOriginals = result.ArchiveOriginals,
                StartDateDay = result.StartDateDay,
                StartDateMonth = result.StartDateMonth,
                StartDateYear = result.StartDateYear,
                EndDateDay = result.EndDateDay,
                EndDateMonth = result.EndDateMonth,
                EndDateYear = result.EndDateYear,
                AproximateDate = result.AproximateDate,
                FilmingExtentName = result.FilmingExtentName,
                Source = result.Source,
                InventoryNumber = result.InventoryNumber ?? "",
                FramesCount = result.FramesCount,
                MicrofilmNegativeCount = result.MicrofilmNegativeCount,
                MicrofilmPositiveCount = result.MicrofilmPositiveCount,
                PhotoCopy = result.PhotoCopy.HasValue ? result.PhotoCopy.Value.ToString() : null,
                DigitalCopy = result.DigitalCopy.HasValue ? result.DigitalCopy.Value.ToString() : null,
                Other = result.Other,
                Notes = result.Notes,
                DocumentsFormat = result.DocumentsFormat,
                DocumentsCharacteristics = result.DocumentsCharacteristics,
                LanguageText = result.Languages
            };
        }

        public async Task<FilmCardDisplayModel?> GetCurrentDraftAsync(Guid sysId)
        {
            var entity =
                await _context.VFilmCards
                .Where(x => x.SystemIdentifier == sysId && x.IsDraft.HasValue && x.IsDraft.Value == true)
                .SingleOrDefaultAsync();

            if (entity != null)
            {
                var model = entity.ToDisplayModel();
                model.LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(entity.Id, BusinessObjectType.FilmCard, true, Shared.NomenclatureCode.Language);
                model.LanguageText = _nomenclatureService.GetEntityNomenclatureText(entity.Id, BusinessObjectType.FilmCard, true, Shared.NomenclatureCode.Language);

                model.DocumentIds = _context.FilmCardDocuments
                    .Where(x => x.CardId == entity.Id && x.IsDraft)
                    .Select(d => d.PackageDocumentId).AsEnumerable();

                return model;
            }

            return null;
        }


        public async Task<int?> GetFilmCardArchiveAsync(Guid sysId)
        {
            var entity =
                await _context.VFilmCards
                .Where(x => x.SystemIdentifier == sysId && !x.Deleted && (!x.IsDraft.HasValue || x.IsDraft.Value == false))
                .SingleOrDefaultAsync();

            return entity?.ArchiveId;
        }

        public async Task<int?> GetFilmCardDraftArchiveAsync(int draftId)
        {
            var entity =
                await _context.VFilmCards
                .Where(x => x.Id == draftId && !x.Deleted && x.IsDraft.HasValue && x.IsDraft.Value == true)
                .SingleOrDefaultAsync();

            return entity?.ArchiveId;
        }

        public async Task<OperationResult> DeleteDraftAsync(int id)
        {
            var filmCardDraft = await _context.FilmCardDrafts
                .Where(x => x.Id == id && !x.Deleted && x.IsCurrent)
                .FirstOrDefaultAsync(); 
            
            if (filmCardDraft == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            OperationResult manipulateResult = await CanManipulateCard(filmCardDraft.FilmSystemIdentifier);
            if (!manipulateResult.Succeeded)
            {
                return manipulateResult;
            }

            using var transaction = _context.Database.BeginTransaction();
            try
            {
                OperationResult result = await doDeleteDraft(id, true);
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

        public async Task<OperationResult> DeleteDraftInternalAsync(int id)
        {
            try
            {
                OperationResult result = await doDeleteDraft(id, false);
                return result;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> DeleteCardInternalAsync(int id)
        {
            try
            {
                OperationResult result = await doDelete(id);
                return result;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> DeleteAllDraftsAsync(Guid filmSysId)
        {
            try
            {
                var cardDrafts = await _context.FilmCardDrafts
                .Where(x => x.FilmSystemIdentifier == filmSysId && x.IsCurrent)
                .ToListAsync();

                foreach (var draft in cardDrafts)
                {
                    OperationResult result = await doDeleteDraft(draft.Id, false);
                    if (!result.Succeeded)
                    {
                        throw new Exception(String.Join("; ", result.Errors));
                    }
                }

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        private async Task<OperationResult> doDeleteDraft(int id, bool keepCurrent)
        {
            var filmCardDraft = await _context.FilmCardDrafts.FindAsync(id);
            if (filmCardDraft == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            //if (!filmCardDraft.IsCurrent)
            //{
            //    return OperationResult.Failed(_localizer.GetString("Error_DraftNotCurrent").ToString());
            //}

            if (!keepCurrent)
            {
                filmCardDraft.IsCurrent = false;
            }
            filmCardDraft.ReadOnly = true;
            filmCardDraft.Deleted = true;
            filmCardDraft.DeletedOn = DateTime.UtcNow;
            filmCardDraft.DeletedBy = _userInfo.CurrentUserId;

            _context.Update(filmCardDraft);

            var draftNomValues = _nomenclatureService.GetEntityNomenclatureValues(filmCardDraft.Id, BusinessObjectType.FilmCard, true, null);
            if (draftNomValues != null && draftNomValues.Count() > 0)
            {
                draftNomValues.ToList().ForEach(nv =>
                {
                    nv.Deleted = true;
                    nv.DeletedBy = _userInfo.CurrentUserId;
                    nv.DeletedOn = DateTime.UtcNow;
                });

                _context.NomenclatureValues.UpdateRange(draftNomValues);
            }

            var existingDocs = await _context.FilmCardDocuments
                .Where(x => x.CardId == filmCardDraft.Id && x.IsDraft)
                .ToListAsync();
            _context.FilmCardDocuments.RemoveRange(existingDocs);

            await _context.SaveAsync("Film card draft deleted");
            return OperationResult.Success;
        }

        public async Task<OperationResult> DeleteFilmCardAsync(Guid id)
        {
            using var transaction = _context.Database.BeginTransaction();

            try
            {
                OperationResult result = await doPseudoDelete(id);
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

        private async Task<OperationResult> doPseudoDelete(Guid sysId)
        {
            var cardDraft = await _context.FilmCardDrafts
                .Where(x => x.SystemIdentifier == sysId && x.IsCurrent)
                .FirstOrDefaultAsync();

            if (cardDraft == null)
            {
                var filmCard = await _context.FilmCards
                .Where(x => x.SystemIdentifier == sysId && !x.Deleted)
                .SingleOrDefaultAsync();

                if (filmCard == null)
                {
                    return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                var model = filmCard.ToFilmCardModel();
                OperationResult result = await doCreateDraft(model, false);
                if (!result.Succeeded)
                {
                    throw new Exception(String.Join("; ", result.Errors));
                }
            }

            cardDraft = await _context.FilmCardDrafts
                .Where(x => x.SystemIdentifier == sysId && x.IsCurrent)
                .FirstOrDefaultAsync();

            if (cardDraft == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            return await doDeleteDraft(cardDraft.Id, true);
        }


        private async Task<OperationResult> doDelete(FilmCardDraft cardDraft, FilmCard card)
        {
            cardDraft.IsCurrent = false;
            cardDraft.ReadOnly = true;
            cardDraft.Deleted = true;
            cardDraft.DeletedOn = DateTime.UtcNow;
            cardDraft.DeletedBy = _userInfo.CurrentUserId;

            _context.Update(cardDraft);

            var draftNomValues = _nomenclatureService.GetEntityNomenclatureValues(cardDraft.Id, BusinessObjectType.FilmCard, true, null);
            if (draftNomValues != null && draftNomValues.Count() > 0)
            {
                draftNomValues.ToList().ForEach(nv =>
                {
                    nv.Deleted = true;
                    nv.DeletedBy = _userInfo.CurrentUserId;
                    nv.DeletedOn = DateTime.UtcNow;
                });

                _context.NomenclatureValues.UpdateRange(draftNomValues);
            }
            
            var existingDocs = await _context.FilmCardDocuments
                .Where(x => x.CardId == cardDraft.Id && x.IsDraft)
                .ToListAsync();
            _context.FilmCardDocuments.RemoveRange(existingDocs);

            if (card != null)
            {
                card.Deleted = true;
                card.DeletedOn = DateTime.UtcNow;
                card.DeletedBy = _userInfo.CurrentUserId;

                _context.Update(card);

                var entityNomValues = _nomenclatureService.GetEntityNomenclatureValues(card.Id, BusinessObjectType.FilmCard, false, null);
                if (entityNomValues != null && entityNomValues.Count() > 0)
                {
                    entityNomValues.ToList().ForEach(nv =>
                    {
                        nv.Deleted = true;
                        nv.DeletedBy = _userInfo.CurrentUserId;
                        nv.DeletedOn = DateTime.UtcNow;
                    });

                    _context.NomenclatureValues.UpdateRange(entityNomValues);
                }

                var existingCardDocs = await _context.FilmCardDocuments
                    .Where(x => x.CardId == card.Id && !x.IsDraft)
                    .ToListAsync();
                _context.FilmCardDocuments.RemoveRange(existingCardDocs);
            }

            await _context.SaveAsync("Film card deleted");

            return OperationResult.Success;
        }

        private async Task<OperationResult> doDelete(int cardId)
        {
            var filmCard = await _context.FilmCards.FindAsync(cardId);
            if (filmCard == null)
            {
                return OperationResult.Failed(_localizer.GetString("Error_ItemDoesNotExists").ToString());
            }

            filmCard.Deleted = true;
            filmCard.DeletedOn = DateTime.UtcNow;
            filmCard.DeletedBy = _userInfo.CurrentUserId;

            _context.Update(filmCard);

            var entityNomValues = _nomenclatureService.GetEntityNomenclatureValues(filmCard.Id, BusinessObjectType.FilmCard, false, null);
            if (entityNomValues != null && entityNomValues.Count() > 0)
            {
                entityNomValues.ToList().ForEach(nv =>
                {
                    nv.Deleted = true;
                    nv.DeletedBy = _userInfo.CurrentUserId;
                    nv.DeletedOn = DateTime.UtcNow;
                });

                _context.NomenclatureValues.UpdateRange(entityNomValues);
            }

            var existingDocs = await _context.FilmCardDocuments
                .Where(x => x.CardId == filmCard.Id && !x.IsDraft)
                .ToListAsync();
            _context.FilmCardDocuments.RemoveRange(existingDocs);

            await _context.SaveAsync("Film card deleted");
            return OperationResult.Success;
        }

        public async Task<OperationResult> CreateOrUpdateFilmCardsFromDraftAsync(Guid filmSysId)
        {
            try
            {
                var filmCardDrafts = await _context.FilmCardDrafts
                    .Where(x => x.FilmSystemIdentifier == filmSysId && x.IsCurrent)
                    .ToListAsync();

                if (filmCardDrafts == null)
                {
                    return OperationResult.Succeed(filmSysId);
                }

                foreach (var cardDraft in filmCardDrafts)
                {
                    var card =
                        await _context.FilmCards
                        .Where(x => x.SystemIdentifier == cardDraft.SystemIdentifier && !x.Deleted)
                        .SingleOrDefaultAsync();

                    if (cardDraft.Deleted)
                    {
                        var deleteResult = await doDelete(cardDraft, card);
                        if (!deleteResult.Succeeded)
                        {
                            return deleteResult;
                        }
                    }
                    else
                    {
                        var cardModel = cardDraft.ToFilmCardDraftModel();

                        cardModel.LanguageCodes = _nomenclatureService.GetEntityNomenclatureCodes(cardModel.Id, BusinessObjectType.FilmCard, true, Shared.NomenclatureCode.Language);

                        cardModel.DocumentIds = await _context.FilmCardDocuments
                            .Where(x => x.CardId == cardModel.Id && x.IsDraft && !x.PackageDocument.Deleted)
                            .Select(d => d.PackageDocument.CopiedFromId.HasValue ? d.PackageDocument.CopiedFromId.Value : d.PackageDocumentId)
                            .ToListAsync();


                        if (card != null)
                        {
                            var filmUpdateResult = await doUpdateFilmCard(card, cardModel);
                            if (!filmUpdateResult.Succeeded)
                            {
                                return filmUpdateResult;
                            }
                        }
                        else
                        {
                            var cardCreateResult = await CreateFilmCardAsync(cardModel);
                            if (!cardCreateResult.Succeeded)
                            {
                                return cardCreateResult;
                            }
                        }


                        cardDraft.IsCurrent = false;
                        cardDraft.ReadOnly = true;
                        _context.Update(cardDraft);
                    }
                }

                return OperationResult.Succeed(filmSysId);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        private async Task<OperationResult> CreateFilmCardAsync(FilmCardDraftModel model)
        {
            if (model == null)
            {
                throw new ArgumentException(nameof(model));
            }

            try
            {
                var filmCard = model.ToFilmCardEntity();
                _context.FilmCards.Add(filmCard);
                await _context.SaveAsync("Film card created");

                await AddLanguageCodes(model, filmCard.Id, false);
                await AddCardDocuments(model, filmCard.Id, false);

                return OperationResult.Succeed(filmCard.Id);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }


        public async Task<OperationResult> PrepareDraftsAsync(Guid filmSysId, int filmDraftId, int packageBId)
        {
            try
            {
                var filmCards = await _context.FilmCards
                    .Where(x => x.FilmSystemIdentifier == filmSysId && !x.Deleted)
                    .ToListAsync();

                foreach (var card in filmCards)
                {
                    var cardDraft = card.CopyEntity();
                    cardDraft.FilmDraftId = filmDraftId;
                    _context.FilmCardDrafts.Add(cardDraft);
                    await _context.SaveAsync("Film card draft created");

                    var entityNomValues = _nomenclatureService.GetEntityNomenclatureValues(card.Id, BusinessObjectType.FilmCard, false, null);
                    var draftNomValues = entityNomValues
                        .Select(ac => new NomenclatureValue()
                        {
                            EntityId = cardDraft.Id,
                            EntityType = BusinessObjectType.FilmCard,
                            EntityIsDraft = true,
                            NomenclatureCode = ac.NomenclatureCode,
                            NomenclatureId = ac.NomenclatureId,
                            ValueCode = ac.ValueCode,
                            ValueId = ac.ValueId,
                        });
                    await _context.NomenclatureValues.AddRangeAsync(draftNomValues!);

                    // approved card document ids
                    var cardDocsIds = await _context.FilmCardDocuments
                        .Where(x => x.CardId == card.Id && !x.IsDraft)
                        .Select(x => x.PackageDocumentId)
                        .ToListAsync();

                    // corresponding draft film documents
                    var draftPackageDocs = await _context.FilmPackageDocuments
                        .Where(x => x.PackageId == packageBId &&
                               x.CopiedFromId.HasValue &&
                               cardDocsIds.Contains(x.CopiedFromId.Value))
                        .ToListAsync();

                    var docs = cardDocsIds
                        .Select(d => new FilmCardDocument
                        {
                            CardId = cardDraft.Id,
                            PackageDocumentId = draftPackageDocs.Where(x => x.CopiedFromId.HasValue && x.CopiedFromId.Value == d).FirstOrDefault()!.Id,
                            IsDraft = true,
                        });
                    await _context.FilmCardDocuments.AddRangeAsync(docs);

                    await _context.SaveAsync("Film card draft documents created");
                }

                return OperationResult.Succeed(filmSysId);
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }


        public async Task<FilmCardPrintedModel?> GetPrintedBySystemIdentifierAsync(Guid sysId)
        {
            var entity = await _context.FilmCards
                .Include(x => x.Archive)
                .Include(x => x.FilmSystemIdentifierNavigation)
                .Include(x => x.FilmingExtent)
                .Where(x => x.SystemIdentifier == sysId && !x.Deleted)
                .Select(x => new
                {
                    Country = x.Country != null ? x.Country.Text : null,
                    CountryCode = x.Country != null ? x.Country.Code : null,
                    x.City,
                    x.ArchiveOriginals,
                    Archive = x.Archive.Name,
                    DocumentsCipher = x.DocumentsCypher,
                    Number = x.InventoryNumber,
                    x.Title,
                    x.StartDateDay,
                    x.StartDateMonth,
                    x.StartDateYear,
                    x.EndDateDay,
                    x.EndDateMonth,
                    x.EndDateYear,
                    x.DocumentsFormat,
                    DocumentsLanguage = _nomenclatureService.GetEntityNomenclatureText(x.Id, BusinessObjectType.FilmCard, false, Shared.NomenclatureCode.Language),
                    FilmingExtent = x.FilmingExtent != null ? x.FilmingExtent.Text : null,
                    x.FilmSystemIdentifierNavigation.AcceptedOnDay, // това не е сигурно, че се взима от тук
                    x.FilmSystemIdentifierNavigation.AcceptedOnMonth,
                    x.FilmSystemIdentifierNavigation.AcceptedOnYear,
                    x.FramesCount,
                    x.MicrofilmNegativeCount,
                    x.MicrofilmPositiveCount,
                    x.PhotoCopy,
                    x.DigitalCopy,
                    x.Size,
                    x.Source,
                    x.Notes,
                    CreatedByDisplayName = x.CreatedByNavigation!.AspNetUserProfileUsers.Where(up => up.UserId == x.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    x.CreatedOn,
                    x.DocumentsCharacteristics
                })
                .SingleOrDefaultAsync();

            if (entity != null)
            {
                var result = new FilmCardPrintedModel
                {
                    Country = entity.Country,
                    CountryCode = entity.CountryCode,
                    City = entity.City,
                    ArchiveOriginals = entity.ArchiveOriginals,
                    Archive = entity.Archive,
                    DocumentsCipher = entity.DocumentsCipher,
                    Number = entity.Number,
                    Title = entity.Title,
                    StartDateDay = entity.StartDateDay,
                    StartDateMonth = entity.StartDateMonth,
                    StartDateYear = entity.StartDateYear,
                    EndDateDay = entity.EndDateDay,
                    EndDateMonth = entity.EndDateMonth,
                    EndDateYear = entity.EndDateYear,
                    DocumentsFormat = entity.DocumentsFormat,
                    DocumentsLanguage = entity.DocumentsLanguage != null ? entity.DocumentsLanguage.Split(System.Globalization.CultureInfo.CurrentCulture.TextInfo.ListSeparator + " ") : null,
                    FilmingExtent = entity.FilmingExtent,
                    AcceptedOnDay = entity.AcceptedOnDay,
                    AcceptedOnMonth = entity.AcceptedOnMonth,
                    AcceptedOnYear = entity.AcceptedOnYear,
                    Source = entity.Source,
                    Notes = entity.Notes,
                    CreatedByDisplayName = entity.CreatedByDisplayName!,
                    CreatedOn = entity.CreatedOn!.Value,
                    DocumentsCharacteristics = entity.DocumentsCharacteristics,
                };

                // това не е сигурно дали е така по задание
                if (entity.PhotoCopy != null)
                {
                    result.CopyType = (int)CopyType.Photo;
                    result.CopyVolume = entity.PhotoCopy;
                }
                else if (entity.DigitalCopy != null)
                {
                    result.CopyType = (int)CopyType.Digital;
                    result.CopyVolume = entity.DigitalCopy;
                }
                else if (entity.FramesCount != null)
                {
                    result.CopyType = (int)CopyType.Film;
                    result.CopyVolume = entity.FramesCount.ToString();
                }
                else if (entity.MicrofilmNegativeCount != null)
                {
                    result.CopyType = (int)CopyType.MicrofilmNegative;
                    result.CopyVolume = entity.MicrofilmNegativeCount.ToString();
                }
                else if (entity.MicrofilmNegativeCount != null)
                {
                    result.CopyType = (int)CopyType.MicrofilmPositive;
                    result.CopyVolume = entity.MicrofilmPositiveCount.ToString();
                }

                return result;
            }

            return null;
        }

        private async Task UpdateFilmCardSizeAndFormat(FilmCardDraft card, IEnumerable<int>? documentIds)
        {
            long? size = 0;
            string format = String.Empty;

            if (documentIds != null && documentIds.Count() > 0)
            {
                var docs = await _context.FilmPackageDocuments
                    .Where(x => documentIds.Contains(x.Id))
                    .ToListAsync();

                if (docs != null && docs.Count > 0)
                {
                    size = docs.Select(x => x.FileSizeInBytes).ToList().Sum();
                    format = String.Join(", ", docs.DistinctBy(x => x.FileType).Select(x => x.FileType).ToList());
                }
            }

            card.Size = size.HasValue && size.Value > 0 ? size.Value.ToString() : "0";
            card.DocumentsFormat = format;
            _context.FilmCardDrafts.Update(card);
            await _context.SaveAsync("Calculated film card size");
        }

    }
}
