using DAA.Models.Commission;
using DAA.Shared;
using Microsoft.AspNetCore.Http;

namespace DAA.Services.CommissionReports
{
    public interface ICommissionReportServiceBase
    {
        protected internal Task<OperationResult> DeleteReportInternalAsync(int reportId);
        protected internal Task<OperationResult> UploadReportFileInternalAsync(IFormFile content, int reportId);
        protected internal Task<OperationResult> UploadReportFilesInternalAsync(IEnumerable<IFormFile> content, int reportId);
    }

    public interface ICommissionReportService : ICommissionReportServiceBase
    {
        Task<CommissionReportModel?> GetByIdAsync(int id);
        Task<CommissionReportModel?> GetByProcessIdAsync(int processId);
        Task<CommissionReportFileModel?> GetReportFileAsync(int id, int reportId);
        IQueryable<CommissionReportFileModel> GetReportFilesAsync(int reportId);
        Task<OperationResult> CreateAsync(CommissionReportModel model);
        Task<OperationResult> UpdateAsync(CommissionReportModel model);
        Task<OperationResult> DeleteReportAsync(int reportId);
        IQueryable<CommissionReportModel> GetReports(int archiveId);
        Task<OperationResult> UploadReportFilesAsync(IEnumerable<IFormFile> contents, int reportId);
        Task<OperationResult> DeleteReportFileAsync(int id, int reportId);
    }
}
