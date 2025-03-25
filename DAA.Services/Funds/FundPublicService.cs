using DAA.Data;
using DAA.Models.Configuration;
using DAA.Models.Funds;
using DAA.Services.Nomenclatures;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System.Data.SqlClient;

namespace DAA.Services.Funds
{
    public class FundPublicService : BaseService, IFundPublicService
    {
        private readonly INomenclatureService _nomenclatureService;
        private readonly LinkedServerSettings _settings;
        private readonly IUserInfo _userInfo;

        public FundPublicService(ArchivingContext context,
            INomenclatureService nomenclatureService,
            IOptions<LinkedServerSettings> settings,
            IUserInfo userInfo,
            ILogger<IFundPublicService> logger,
            IStringLocalizer<SharedResources> localizer)
           : base(context, localizer, logger)
        {
            _nomenclatureService = nomenclatureService;
            _settings = settings.Value;
            _userInfo = userInfo;
        }

        public async Task<FundPublicDisplayModel?> GetFromExternalSourceAsync(int externalIdentifier, Guid? systemIdentifier = null)
        {
            string query = "exec sp_GetFund @LinkedServer, @Identifier";

            SqlParameter[] queryParams = new[]
            {
                new SqlParameter("LinkedServer", _settings.LinkedServer),
                new SqlParameter("Identifier", externalIdentifier),
            };

            var result = (await _context.RemoteFunds
                        .FromSqlRaw($"exec sp_GetFund @LinkedServer = {_settings.LinkedServer}, @Identifier='{externalIdentifier}'")
                        .AsNoTracking()
                        .ToListAsync())
                    .FirstOrDefault();

            if (result == null)
            {
                return null;
            }

            if (!systemIdentifier.HasValue)
            {
                systemIdentifier = await _context.Funds
                 .Where(f => f.ExternalIdentifier == externalIdentifier)
                 .Select(f => f.SystemIdentifier)
                 .SingleOrDefaultAsync();
            }

            return new FundPublicDisplayModel()
            {
             
                SystemIdentifier = systemIdentifier,
                ArchiveName = result.ArchiveName,
                Number = result.Number,
                StatusText = result.StatusText,
                DescriptionLevelText = result.DescriptionLevelText,
                Title = result.Title,
                HasNoChronologicalScope = result.HasNoChronologicalScope,
                StartDateDay = result.StartDateDay,
                StartDateMonth = result.StartDateMonth,
                StartDateYear = result.StartDateYear,
                EndDateDay = result.EndDateDay,
                EndDateMonth = result.EndDateMonth,
                EndDateYear = result.EndDateYear,
                ApproxmateChronologicalScope = result.ApproxmateChronologicalScope,
                InventoryCount = result.InventoryCount,
                ArchivalEntityCount = result.ArchivalEntityCount,
                OtherMetrics = result.OtherMetrics,
                FundCreatorTitleHistory = result.FundCreatorTitleHistory,
                FundCreatorBiographicalHistory = result.FundCreatorBiographicalHistory,
                History = result.History,
                DocumentsDescription = result.DocumentsDescription,
                DocumentsAccessDescription = result.DocumentsAccessDescription,
                RelatedFunds = result.RelatedFunds,
                Notes = result.Notes,
                HasExternalSource = result.HasExternalSource,
                ExternalIdentifier = result.ExternalIdentifier,
                IndustryTypeText = result.IndustryTypeText,
                LanguageText = result.LanguageText,
            };
        }

        public async Task<FundPublicDisplayModel?> GetFundBySystemIdentifierAsync(Guid sysId)
        {
            //FIX Да се оправи статуса да се чете от enum, a НЕ да се забива текст в кода!
            var fund =
                await _context.Funds
                .Where(f => f.SystemIdentifier == sysId && !f.Deleted && f.StatusCode != "12")
                .Select(f => new FundPublicDisplayModel()
                {
                    SystemIdentifier = f.SystemIdentifier,
                    ArchiveName = f.Archive.Name,
                    Number = f.Number,
                    StatusText = f.StatusCodeNavigation!.Text,
                    DescriptionLevelText = f.DescriptionLevelCodeNavigation!.Text,
                    Title = f.Title,
                    HasNoChronologicalScope = f.HasNoChronologicalScope,
                    StartDateDay = f.StartDateDay,
                    StartDateMonth = f.StartDateMonth,
                    StartDateYear = f.StartDateYear,
                    EndDateDay = f.EndDateDay,
                    EndDateMonth = f.EndDateMonth,
                    EndDateYear = f.EndDateYear,
                    ApproxmateChronologicalScope = f.ApproxmateChronologicalScope,
                    InventoryCount = f.InventoryCount,
                    ArchivalEntityCount = f.ArchivalEntityCount,
                    DocumentCount = f.DocumentCount,
                    OtherMetrics = f.OtherMetrics,
                    FundCreatorTitleHistory = f.FundCreatorTitleHistory,
                    FundCreatorBiographicalHistory = f.FundCreatorBiographicalHistory,
                    History = f.History,
                    DocumentsDescription = f.DocumentsDescription,
                    DocumentsAccessDescription = f.DocumentsAccessDescription,
                    RelatedFunds = f.RelatedFunds,
                    Notes = f.Notes,
                    HasExternalSource = f.HasExternalSource,
                    ExternalIdentifier = f.ExternalIdentifier,
                    LinearMeters = f.LinearMeters,
                    FileTypeText = _nomenclatureService.GetEntityNomenclatureText(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.FileType),
                    IndustryTypeText = _nomenclatureService.GetEntityNomenclatureText(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.IndustryType),
                    LanguageText = _nomenclatureService.GetEntityNomenclatureText(f.Id, BusinessObjectType.Fund, false, Shared.NomenclatureCode.Language),
                }).FirstOrDefaultAsync();

            if (fund != null)
            {
                var sizeInfo = await _context.VFundSizeInfos
                    .Where(x => x.FundSystemIdentifier == sysId && x.IsDraft == 0)
                    .SingleOrDefaultAsync();
                if (sizeInfo != null)
                {
                    fund.InventoryCount = sizeInfo.EnrolledInventoryCount;
                    fund.ArchivalEntityCount = sizeInfo.EnrolledArchivalEntityCount;
                    fund.DocumentCount = sizeInfo.EnrolledDocumentCount;
                    fund.Bytes = sizeInfo.EnrolledBytes;
                    string fileTypes = sizeInfo.FileTypes != null
                        ? String.Join(
                            System.Globalization.CultureInfo.CurrentCulture.TextInfo.ListSeparator + " ",
                            sizeInfo.FileTypes.Split("; ").Distinct()).ToUpper()
                        : String.Empty;
                    fund.FileTypeText = fileTypes;
                }
            }

            if (fund != null && fund.HasExternalSource && fund.ExternalIdentifier.HasValue)
            {
                try
                {
                    fund = await GetFromExternalSourceAsync(fund.ExternalIdentifier.Value, fund.SystemIdentifier);
                }
                catch (Exception)
                {
                    _logger.LogWarning("Error retrieving fund data from ISDA");

                    fund!.ResultMessage = Constants.ISDADataCannotBeDisplayedMessageKey; // тук, ако няма fund, вече трябва да се хвърли грешка
                }
            }

            return fund;
        }

        public async Task<OperationResult?> CreateFundReviewAsync(Guid? fundSystemIdentifier, int? fundExternalIdentifier)
        {
            if (!_userInfo.CurrentUserId.HasValue || _userInfo.CurrentUserId.Value == Guid.Empty)
            {
                return OperationResult.Success;
            }

            Guid systemIdentifier = Guid.NewGuid();

            UserReview publicUserReview = new UserReview
            {
                SystemIdentifier = systemIdentifier,
                UserId = _userInfo.CurrentUserId.Value,
                Date = DateTime.UtcNow
            };

            if ((fundSystemIdentifier.HasValue && fundSystemIdentifier.Value != Guid.Empty) || fundExternalIdentifier.HasValue)
            {
                if (fundSystemIdentifier.HasValue && fundSystemIdentifier.Value != Guid.Empty)
                {
                    publicUserReview.FundSystemIdentifier = fundSystemIdentifier.Value;
                }
                if (fundExternalIdentifier.HasValue)
                {
                    publicUserReview.FundExternalIdentifier = fundExternalIdentifier;
                }
            }
            else
            {
                return OperationResult.Succeed("No review for missing fund system identifier");
            }

            await _context.UserReviews.AddAsync(publicUserReview);
            await _context.SaveAsync("Public user review created");

            return OperationResult.Success;
        }
    }
}
