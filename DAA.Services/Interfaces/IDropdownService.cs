using DAA.Models;
using System.Threading.Tasks;

namespace DAA.Services.Interfaces
{
    public interface IDropdownService
    {
        IQueryable<DropdownOption> GetArchives();
        IQueryable<DropdownOption> GetPublicArchives();
        Task<IEnumerable<DropdownOption>> GetExternalSourceArchivesAsync();
        Task<IEnumerable<DropdownOption>> GetAllArchivesAsync(bool includeExternalSource = false);
        IQueryable<DropdownOption> GetStatuses();
        IQueryable<DropdownOption> GetStatusesReduced2();
        IQueryable<DropdownOption> GetStatusesReduced(); 
        IQueryable<DropdownOption> GetFundTypesReducedCHP(); 
        IQueryable<DropdownOption> GetRoughDocumentsStatuses();
        IQueryable<DropdownOption> GetAvailabilityStatuses();
        IQueryable<DropdownOption> GetRoles();
        IQueryable<DropdownOption> GetRolesInArchive(int archiveId, string[] roles);
        IQueryable<DropdownOption> GetFundArrays();
        Task<IEnumerable<DropdownOption>> GetAllFundArraysAsync(int reportResultType);
        IQueryable<DropdownOption> GetFundArraysReduced();
        Task<IEnumerable<DropdownOption>> GetFundArraysInternalAndExternalReducedAsync(int reportResultType);
        IQueryable<DropdownOption> GetFundTypes();
        IList<DropdownOption> GetFundTypesReduced();
        IList<DropdownOption> GetFundTypesInternalAndExternal(int reportResultType);
        IList<DropdownOption> GetFundTypesInternalAndExternalReduced(int reportResultType);
        //IQueryable<DropdownOption> GetFundStatuses();
        IList<DropdownOption> GetFundStatusesInternal(int reportResultType);
        IQueryable<DropdownOption> GetFundStatusesNTOReportReduced();
        IList<DropdownOption> GetFundStatusesInternalAndExternal(int reportResultType);
        IQueryable<DropdownOption> GetFundDescriptionLevels();
        IList<DropdownOption> GetDescriptionLevelsExternal();
        //IQueryable<DropdownOption> GetInventoryStatuses();
        IQueryable<DropdownOption> GetInventoryArrays();
        IQueryable<DropdownOption> GetInventoryDescriptionLevels(int? fundDescriptionLevel = null);
        IList<DropdownOption> GetAcquisitionMethodsInternal();
        IList<DropdownOption> GetAcquisitionMethodsInternalAndExternal(int reportResultType);
        //IQueryable<DropdownOption> GetProcessTypes(string? entityType = null);
        IQueryable<DropdownOption> GetProcessTypes(string[]? entityType = null);
        Task<IEnumerable<DAA.Models.Funds.FundShortDisplayModel>> GetFunds(string searchText, int archiveCode, string[]? descriptionLevel);
        Task<IEnumerable<DAA.Models.Inventories.InventoryShortDisplayModel>> GetInventories(
            string searchText,
            Guid? fundSysId,
            bool? fundHasExternalSource,
            int? fundExternalIdentifier,
            string[]? descriptionLevel);
        IQueryable<DropdownOption> GetNomenclatures(int? parentId = null);
        IQueryable<DropdownOption> GetNomenclatures(string code);
        IQueryable<DropdownOption> GetNomenclatureCodes();
        IQueryable<DropdownOption> GetArchiveEntityDescriptionLevels();
        IList<DropdownOption> GetArchiveEntityDescriptionLevelsInternalAndExternal();
        IQueryable<DropdownOption> GetCentralArchive();
        IQueryable<DropdownOption> GetDocumentDescriptionLevels();
        IQueryable<DropdownOption> GetIndustryIndexes();
        IList<DropdownOption> GetIndustryIndexesInternalAndExternal(int systemCode);
        IList<DropdownOption> GetAllDescriptionLevelsExternalAndInternal(bool getOnlyInternal = false);
        //IList<DropdownOption> GetAllPublicDescriptionLevels();
        Task<IEnumerable<DropdownOption>> GetAllPublicDescriptionLevelsAsync(int resultType = 1);
        IList<DropdownOption> GetFundInventoryAEDocumentDescriptionLevelsExternalAndInternal(int reportResultType);
        IQueryable<DropdownOption> GetCollectingProcedures();
        IList<DropdownOption> GetProcessTypesInternalAndExternal(int reportResultType);
        IQueryable<DropdownOption> GetReportResultTypes();
        IQueryable<DropdownOption> GetFilmDocTypes(string packageType);
        IQueryable<DropdownOption> GetFilmPackageBDocs(string filmSysId);
        Task<List<DropdownOption>> GetUnusedFilmPackageBDocs(string filmSysId, Guid cardSysId);
        IQueryable<DropdownOption> GetUsersInRoles(int archiveId, string[] roles);
        IQueryable<DropdownOption> GetUsersInRolesAllArchives(string[] roles);
        IQueryable<DropdownOption> GetCommissionSessions(int archiveId);
        IList<DropdownOption> GetFileFormats();
        IList<DropdownOption> GetInventoryArraysInternalAndExternal();
        IList<DropdownOption> GetEmployeeNamesExternalViaProcedure();
        IList<DropdownOption> GetEmployeeNamesInternalAndExternal(int reportResultType);
        IList<DropdownOption> GetEmployeeNamesInternal();
        IQueryable<DropdownOption> GetAssignedToUserApplications(Guid userId, string? applicationType = null, Guid? inventorySysId = null, int? archiveId = null);
        IQueryable<DropdownOption> GetReaderProfiles();
        IQueryable<DropdownOption> GetAllFilms();
        IQueryable<DropdownOption> GetSessionTypes();
        IQueryable<DropdownOption> GetProcessesSteps();
        IQueryable<DropdownOption> GetPreparationOfDigitalObjectProcessSteps();
        IQueryable<DropdownOption> GetFilmCountries();
        IQueryable<DropdownOption> GetApplicationTypes();
        IQueryable<DropdownOption> GetLibraryCards();
        IList<DropdownOption> GeProcessesExternal();
        IQueryable<DropdownOption> GetFundMemoriesReportStatuses();
        IList<DropdownOption> GetAllDescLevelsForPublicSearch();
    }
}
