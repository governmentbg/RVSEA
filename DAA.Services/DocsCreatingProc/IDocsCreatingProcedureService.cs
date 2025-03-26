using DAA.Models.Documents.DocumentsProcedure;
using DAA.Shared;

namespace DAA.Services.DocsCreatingProc
{
    public interface IDocsCreatingProcedureService
    {
        Task<OperationResult> Start(DocumentProcedureCreateModel model);
        Task<OperationResult> UpdateStep(DocumentProcedureUpdateModel model);
        Task<OperationResult> SaveChanges(DocumentProcedureUpdateModel model);
        Task<OperationResult> StepBack(DocumentProdecureViewModel model);
        Task<DocumentProdecureViewModel> Get(string procId);
    }

}

