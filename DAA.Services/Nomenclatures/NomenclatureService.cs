using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Extensions.Models;
using DAA.Models.Nomenclatures;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using System.Text;

namespace DAA.Services.Nomenclatures
{
    public class NomenclatureService : BaseService, INomenclatureService
    {
        private readonly IUserInfo _userInfo;

        public NomenclatureService(
            ArchivingContext context, 
            IStringLocalizer<SharedResources> localizer, 
            IUserInfo userInfo) 
            : base(context, localizer)
        {
            _userInfo = userInfo;
        }

        public async Task<OperationResult> CreateNomenclatureAsync(NomenclatureModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                var nomenclature = new Nomenclature()
                {
                    Code = model.Code,
                    Text = model.Text,
                    Description = model.Description,
                    Inactive = model.Inactive,
                    Locked = model.Locked,
                };
                _context.Nomenclatures.Add(nomenclature);
                await _context.SaveAsync($"Nomenclature created");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> CreateNomenclatureValueAsync(NomenclatureValueModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                var nomValue = new Nomenclature()
                {
                    HasExternalSource = model.ExternalIdentifier.HasValue ? true : false,
                    ExternalIdentifier = model.ExternalIdentifier ?? null,
                    ParentId = model.ParentId,
                    Code = model.Code,
                    Text = model.Text,
                    Description = model.Description,
                    SortOrder = model.SortOrder,
                    Inactive = model.Inactive,
                };

                _context.Nomenclatures.Add(nomValue);
                await _context.SaveAsync($"Nomenclature value created");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public DataSourceResponseModel<NomenclatureDisplayModel> GetNomenclatures(DataSourceRequestModel model, bool includeInactive = true)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query =
                _context.Nomenclatures
                .Where(nom => nom.ParentId == null && !nom.Deleted)
                .Select(nom => new NomenclatureDisplayModel()
                {
                    Id = nom.Id,
                    Code = nom.Code,
                    Text = nom.Text,
                    Description = nom.Description,
                    Inactive = nom.Inactive,
                    Locked = nom.Locked,
                    CreatedOn = nom.CreatedOn,
                    CreatedBy = nom.CreatedBy,
                    CreatedByDisplayName = nom.CreatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == nom.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = nom.CreatedByNavigation.UserName,
                    UpdatedOn = nom.UpdatedOn,
                    UpdatedBy = nom.UpdatedBy,
                    UpdatedByDisplayName = nom.UpdatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == nom.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = nom.UpdatedByNavigation.UserName,
                });
            if (!includeInactive)
            {
                query = query.Where(nom => !nom.Inactive);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }

            QueryResponseModel<NomenclatureDisplayModel> queryResponse = query.SortAndFilter(model);

            DataSourceResponseModel<NomenclatureDisplayModel> result = new DataSourceResponseModel<NomenclatureDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(nom => nom)
            };

            return result;
        }

        public DataSourceResponseModel<NomenclatureValueDisplayModel> GetNomenclatureValues(DataSourceRequestModel model, int parentId, bool includeInactive = true)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            var query = _context.Nomenclatures
                .Where(nv => nv.ParentId == parentId && !nv.Deleted)
                .Select(nv => new NomenclatureValueDisplayModel()
                {
                    Id = nv.Id,
                    ParentId = nv.ParentId,
                    ParentCode = nv.Parent.Code,
                    ParentText = nv.Parent.Text,
                    Code = nv.Code,
                    Text = nv.Text,
                    ExternalIdentifier= nv.ExternalIdentifier,
                    SortOrder = nv.SortOrder,
                    Description = nv.Description,
                    Inactive = nv.Inactive,
                    Locked = nv.Locked,
                    CreatedOn = nv.CreatedOn,
                    CreatedBy = nv.CreatedBy,
                    CreatedByDisplayName = nv.CreatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == nv.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = nv.CreatedByNavigation.UserName,
                    UpdatedOn = nv.UpdatedOn,
                    UpdatedBy = nv.UpdatedBy,
                    UpdatedByDisplayName = nv.UpdatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == nv.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = nv.UpdatedByNavigation.UserName,
                });
            if (!includeInactive)
            {
                query = query.Where(nom => !nom.Inactive);
            }

            if (!String.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.FilterBySearchText(model.SearchString);
            }

            QueryResponseModel<NomenclatureValueDisplayModel> queryResponse = query.SortAndFilter(model);
            DataSourceResponseModel<NomenclatureValueDisplayModel> result = new DataSourceResponseModel<NomenclatureValueDisplayModel>()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query.Select(nv => nv)
            };

            return result;
        }

        public IQueryable<Nomenclature> GetNomenclatureValues(string parentCode, bool includeInactive = true)
        {
            var nomenclatureValues = _context.Nomenclatures
                .Where(nv => nv.Parent.Code == parentCode && !nv.Deleted && (includeInactive || !nv.Inactive));

            return nomenclatureValues;
        }


        public Task<NomenclatureDisplayModel?> GetNomenclatureByIdAsync(int id)
        {
            return _context.Nomenclatures
                .Where(n => n.Id == id && !n.Deleted)
                .Select(nom => new NomenclatureDisplayModel()
                {
                    Id = nom.Id,
                    Code = nom.Code,
                    Text = nom.Text,
                    Description = nom.Description,
                    Inactive = nom.Inactive,
                    Locked = nom.Locked,
                    CreatedOn = nom.CreatedOn,
                    CreatedBy = nom.CreatedBy,
                    CreatedByDisplayName = nom.CreatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == nom.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = nom.CreatedByNavigation.UserName,
                    UpdatedOn = nom.UpdatedOn,
                    UpdatedBy = nom.UpdatedBy,
                    UpdatedByDisplayName = nom.UpdatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == nom.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = nom.UpdatedByNavigation.UserName,
                })
                .FirstOrDefaultAsync();
        }

        public Task<NomenclatureValueDisplayModel?> GetNomenclatureValueByIdAsync(int id, int parentId)
        {
            return _context.Nomenclatures
                .Where(nv => nv.Id == id && nv.ParentId == parentId && !nv.Deleted)
                .Select(nv => new NomenclatureValueDisplayModel()
                {
                    Id = nv.Id,
                    ParentId = nv.ParentId,
                    ParentCode = nv.Parent.Code,
                    ParentText = nv.Parent.Text,
                    Code = nv.Code,
                    Text = nv.Text,
                    SortOrder = nv.SortOrder,
                    Description = nv.Description,
                    Inactive = nv.Inactive,
                    ExternalIdentifier= nv.ExternalIdentifier,
                    Locked = nv.Locked,
                    CreatedOn = nv.CreatedOn,
                    CreatedBy = nv.CreatedBy,
                    CreatedByDisplayName = nv.CreatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == nv.CreatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    CreatedByUserName = nv.CreatedByNavigation.UserName,
                    UpdatedOn = nv.UpdatedOn,
                    UpdatedBy = nv.UpdatedBy,
                    UpdatedByDisplayName = nv.UpdatedByNavigation.AspNetUserProfileUsers.Where(up => up.UserId == nv.UpdatedBy && !up.Deleted).FirstOrDefault().DisplayName,
                    UpdatedByUserName = nv.UpdatedByNavigation.UserName,
                })
                .FirstOrDefaultAsync();
        }

        public async Task<OperationResult> UpdateNomenclatureAsync(NomenclatureModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                Nomenclature? nomValue = await _context.Nomenclatures.FindAsync(model.Id);
                if (nomValue == null)
                {
                    return OperationResult.Failed(false,_localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                if (nomValue.Locked)
                {
                    return OperationResult.Failed(false, String.Format(_localizer.GetString("Nomenclature_IsLocked").ToString(), nomValue.Text));
                }

                nomValue.Text = model.Text;
                nomValue.Description = model.Description;
                nomValue.Inactive = model.Inactive;
                nomValue.Locked = model.Locked;

                await _context.SaveAsync("Nomenclature edited");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> UpdateNomenclatureValueAsync(NomenclatureValueModel model)
        {
            if (model == null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            try
            {
                Nomenclature? nomValue = await _context.Nomenclatures.FindAsync(model.Id);
                if (nomValue == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                    
                }

                nomValue.HasExternalSource = model.ExternalIdentifier.HasValue ? true : false;
                nomValue.ExternalIdentifier = model.ExternalIdentifier ?? null;
                nomValue.Code = model.Code;
                nomValue.Text = model.Text;
                nomValue.Description = model.Description;
                nomValue.SortOrder = model.SortOrder;
                nomValue.Inactive = model.Inactive;

                await _context.SaveAsync("Nomenclature value edited");
                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> DeleteNomenclatureAsync(int id)
        {
            try
            {
                var nomenclatureValues = await _context.Nomenclatures
                    .Where(nv => nv.Id == id || nv.ParentId == id)
                    .ToListAsync();

                if (nomenclatureValues == null || nomenclatureValues.Count <= 0)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                var nomenclature = nomenclatureValues.Find(nv => nv.ParentId == null);
                if (nomenclature == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }
                if (nomenclature.Locked)
                {
                    return OperationResult.Failed(false, String.Format(_localizer.GetString("Nomenclature_IsLocked").ToString(), nomenclature.Text));
                }

                nomenclatureValues.ForEach(nv =>
                {
                    nv.Deleted = true;
                    nv.DeletedBy = _userInfo.CurrentUserId;
                    nv.DeletedOn = DateTime.UtcNow;
                });

                await _context.SaveAsync("Nomenclature deleted");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }

        public async Task<OperationResult> DeleteNomenclatureValueAsync(int id)
        {
            try
            {
                Nomenclature? nomValue = await _context.Nomenclatures.FindAsync(id);
                if (nomValue == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                nomValue.Deleted = true;
                nomValue.DeletedBy = _userInfo.CurrentUserId;
                nomValue.DeletedOn = DateTime.UtcNow;

                await _context.SaveAsync("Nomenclature value deleted");

                return OperationResult.Success;
            }
            catch (Exception exc)
            {
                return OperationResult.Failed(exc.ToString());
            }
        }




        public IEnumerable<string>? GetEntityNomenclatureCodes(int entityId, string objectType, bool isDraft, string nomenclatureCode)
        {
            IEnumerable<string> codes = _context.NomenclatureValues
                                            .Where(nv => nv.EntityId == entityId
                                                    && nv.EntityType == objectType
                                                    && nv.EntityIsDraft == isDraft
                                                    && nv.NomenclatureCode == nomenclatureCode)
                                            .Select(nv => nv.ValueCode)
                                            .AsEnumerable();
            return codes;
        }


        public string? GetEntityNomenclatureText(int entityId, string objectType, bool isDraft, string nomenclatureCode)
        {
            string text = String.Join(
                                    System.Globalization.CultureInfo.CurrentCulture.TextInfo.ListSeparator + " ",
                                    _context.Nomenclatures
                                    .Join(
                                        _context.NomenclatureValues
                                        .Where(nv => nv.EntityId == entityId
                                            && nv.EntityType == objectType
                                            && nv.EntityIsDraft == isDraft
                                            && nv.NomenclatureCode == nomenclatureCode),
                                        nom => nom.Id,
                                        nv => nv.ValueId,
                                        (nom, nv) => nom.Text));
            return text;
        }


        public IEnumerable<NomenclatureValue>? GetEntityNomenclatureValues(int entityId, string objectType, bool isDraft, string? nomenclatureCode)
        {
            return doGetEntityNomenclatureValues(new List<int>() { entityId }, objectType, isDraft, nomenclatureCode);
        }

        public IEnumerable<NomenclatureValue>? GetEntityNomenclatureValues(List<int> entityIds, string objectType, bool isDraft, string? nomenclatureCode)
        {
            return doGetEntityNomenclatureValues(entityIds, objectType, isDraft, nomenclatureCode);
        }

        private IEnumerable<NomenclatureValue>? doGetEntityNomenclatureValues(List<int> entityIds, string objectType, bool isDraft, string? nomenclatureCode)
        {
            IEnumerable<NomenclatureValue> nomenclatureValues =
                _context.NomenclatureValues
                .Where(nv =>
                    entityIds.Contains(nv.EntityId)
                    && nv.EntityType == objectType
                    && nv.EntityIsDraft == isDraft
                    && (String.IsNullOrWhiteSpace(nomenclatureCode) || nv.NomenclatureCode == nomenclatureCode)
                    && !nv.Deleted)
                .AsEnumerable();

            return nomenclatureValues;
        }


        public IEnumerable<NomenclatureValue>? GetEntityNomenclatureValuesToAdd(
            IEnumerable<string>? selectedValues, 
            IEnumerable<NomenclatureValue>? existingValues,
            string nomenclatureCode, int entityId, string objectType, bool isDraft,
            bool overwriteCreated = false, Guid? createdBy = null, DateTime? createdOn = null)
        {

            selectedValues = selectedValues ?? Enumerable.Empty<string>();
            existingValues = existingValues ?? Enumerable.Empty<NomenclatureValue>();

            IQueryable<Nomenclature> allValues = GetNomenclatureValues(nomenclatureCode);

            IEnumerable<NomenclatureValue>? nomenclatureValuesToAdd =
                    selectedValues?
                    .Where(ac =>
                        !existingValues
                        .Where(nv => nv.NomenclatureCode == nomenclatureCode)
                        .Any(nv => nv.ValueCode == ac))
                    .Select(ac => new NomenclatureValue()
                    {
                        EntityId = entityId,
                        EntityType = objectType,
                        EntityIsDraft = isDraft,
                        NomenclatureCode = nomenclatureCode,
                        NomenclatureId = allValues.Where(nv => nv.Code == ac).Select(nv => nv.ParentId!.Value).FirstOrDefault(),
                        ValueCode = ac,
                        ValueId = allValues.Where(nv => nv.Code == ac).Select(nv => nv.Id).FirstOrDefault(),
                        CreatedBy = overwriteCreated ? createdBy : null,
                        CreatedOn = overwriteCreated ? createdOn : null,
                    });

            return nomenclatureValuesToAdd;
        }

        public IEnumerable<NomenclatureValue>? GetEntityNomenclatureValuesToDelete(
            IEnumerable<string>? selectedValues, 
            IEnumerable<NomenclatureValue>? existingValues, 
            string nomenclatureCode)
        {

            selectedValues = selectedValues ?? Enumerable.Empty<string>();
            existingValues = existingValues ?? Enumerable.Empty<NomenclatureValue>();

            IEnumerable<NomenclatureValue>? nomenclatureValuesToDelete =
                existingValues
                .Where(nv =>
                    nv.NomenclatureCode == nomenclatureCode
                    && (selectedValues == null || !selectedValues.Contains(nv.ValueCode)));

            return nomenclatureValuesToDelete;
        }

    }
}
