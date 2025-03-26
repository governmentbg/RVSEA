using DAA.Data;
using DAA.Models.Import;
using DAA.Models.Packages;
using DAA.Shared;
using Microsoft.AspNetCore.Http;
using Task = System.Threading.Tasks.Task;

namespace DAA.Services.Packages
{
    public interface IPackagesServiceBase
    {
        protected internal Task<int> CreatePackageInternalAsync(string packageType, Guid inventorySysId);
        protected internal Task<OperationResult> AddPackageFileInternalAsync(IFormFile content, int packageId, FileStreamLocation location);
        protected internal Task<OperationResult> AddPackageFilesInternalAsync(IEnumerable<IFormFile> contents, int packageId);
        protected internal Task<PackageDocument> CreateFileInternal(PackageDocumentBaseModel model, int packageId);
        protected internal IQueryable<PackageDocument> GetPackageDocumentsByIdInternal(int id);
    }
    public interface IPackagesService : IPackagesServiceBase
    {
        Task CreateApplicationPackages(ApplicationPackageModel model);
        Task<OperationResult> ApprovePackages(int applicationId);
        Task RejectPackage(int applicationId, string reason);
        Task CancelPackages(int applicationId, string reason);
        Task<ApplicationPackageDisplayModel> GetPackagesForApplication(int applicationId);
        Task<PackageDocument?> GetPackageDocument(int id);
        IQueryable<PackageDocumentDisplayModel> GetPackageDocumentsById(int id, bool? hasTemplate = null);
        IQueryable<PackageDocumentDisplayModel> GetPackageDocumentsBySignatureRequest(int packageId, int processId);
        Task<bool> HasPackageDocumentsBySignatureRequest(int packageId, int processId);
        Task<OperationResult> AddSignedPackageDocumentsAsync(IEnumerable<PackageDocumentBaseModel> packageDocuments, int applicationId, int packageId, int processId);
        Task<OperationResult> CreateFileAsync(PackageDocumentBaseModel model, int packageId, string? inventoryIdentifier = null);
        Task<OperationResult> CreateFilesAsync(PackageDocumentCreateModel model, int packageId);
        Task<int?> GetPackageIdAByProcess(int processId);
        Task<int?> GetPackageIdByApplication(int applicationId, string packageType);
        Task<int?> GetPackageIdByInventory(string packageType, Guid inventorySysId);
        Task<OperationResult> RemoveFileFromPackage(int id);
        Task<OperationResult> RemoveFileFromPackageAsync(int id);
        Task<OperationResult> UnitePackagesIntoNewPackageAsync(List<int>? packageIds, FileStreamLocation locationToCopyTo, string newPackageType);
        Task<OperationResult> CreatePackageAsync(string packageType, Guid inventorySysId);
        Task<OperationResult> DeletePackageAsync(int packageId);
        Task<List<PackageDocumentDisplayModel>> GetAvailablePackageDocumentsForArchivalEntity(Guid? inventorySystemIdentifier, int packageId);
        Task<OperationResult> AddPackageFilesAsync(IEnumerable<IFormFile> contents, int? packageId, string? packageType, Guid? inventorySysId);
        Task<OperationResult> DeletePackageFileAsync(int id, int packageId);
        Task<OperationResult> CommitApplicationPackages(int applicationId);
        Task CreateApplicationPackagesWithImport(ApplicationPackageModel model);
        Task<IQueryable<ArchivalEntityImportModel>> GetStructureForApplication(int applicationId);
        IQueryable<PackageDocument> GetAvailableRawPackageDocuments(Guid? inventorySystemIdentifier, int packageId);
        Task CreateInventoryPackageBWithImport(PackageBImportModel model);
        IQueryable<PackageDocumentDisplayModel> GetPackageBById(int packageId);
        Task<IQueryable<ArchivalEntityImportModel>> GetPackageBStructureForInventory(Guid inventoryId);
        Task<bool> PackageHasAnyDocumentsAsync(int packageId);
        Task<bool> PackageHasRequiredDocumentsAsync(int packageId, Shared.ProcessType processType);
        Task<int> CopyPackageAsync(int sourcePackageId);
    }
}
