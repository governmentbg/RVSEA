using DAA.Models.Processes;
using DAA.Shared;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Services.EditDataProcess
{
    public interface IEditDataProcessService
    {
        Task<OperationResult> StartProcessAsync(ProcessModel model);
        Task<OperationResult> CompleteProcessAsync(int processId);
        Task<OperationResult> UndoProcessChangesAsync(int processId);
        string GetEntityType(ProcessModel model);
        Guid GetEntityId(ProcessModel model);
        Task<int?> GetEntityArchiveIdAsync(ProcessModel model);
        Task<int?> GetEntityArchiveIdAsync(int processId);
    }
}
