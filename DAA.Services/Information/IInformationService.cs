

using DAA.Extensions.DynamicLinq;
using DAA.Models.Information;
using DAA.Shared;

namespace DAA.Services.Information
{
    public interface IInformationService
    {
        DataSourceResponseModel<InformationItemDisplayModel> List(DataSourceRequestModel model, bool includeInactive = false);
        Task<IEnumerable<CalendarDisplayModel>> ListCalendarItems(CalendarRequestModel model, CancellationToken cancellationToken);
        Task<InformationItemDisplayModel?> Get(int id, CancellationToken cancellationToken);
        Task<OperationResult> Create(InformationItemModel model);
        Task<OperationResult> Update(InformationItemModel model);
        Task<OperationResult> Delete(int id);
    }
}
