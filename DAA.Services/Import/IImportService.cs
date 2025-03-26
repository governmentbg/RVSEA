using DAA.Models.File;
using DAA.Models.Import;
using DAA.Shared;
using DocFlow.Models.File;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Services.Import
{
    public interface IImportService
    {
        Task<FileModel> ParseFile(IFormFile file);
        Task<OperationResult> ImportArchivalEntitesFromExcelAsync(IFormFile model, Guid inventorySysId, bool readPackageSheet, bool createEntities, bool readInventorySheet);
        Task<FileDownloadModel> ExportFileTemplateToExcel();
    }
}
