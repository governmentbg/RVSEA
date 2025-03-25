using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Information;
using DAA.Models.Nomenclatures;
using DAA.Shared;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Logging;

namespace DAA.Services.Information
{
    public class InformationService : BaseService, IInformationService
    {
        private readonly IUserInfo _userInfo;

        public InformationService(ArchivingContext context,
            IStringLocalizer<SharedResources> localizer,
            ILogger<InformationService> logger,
            IUserInfo userInfo)
            : base(context, localizer, logger)
        {
            _userInfo = userInfo;
        }

        public DataSourceResponseModel<InformationItemDisplayModel> List(DataSourceRequestModel model, bool includeInactive = false)
        {
            ArgumentNullException.ThrowIfNull(model, nameof(model));

            IQueryable<InformationItem> query = _context.InformationItems
                .AsQueryable();

            if (!includeInactive)
            {
                DateTime now = DateTime.Now.Date;
                query = query.Where(x => !x.Deleted && x.StartDate.Date <= now && (x.EndDate == null || now <= x.EndDate));
            }

            if (!string.IsNullOrWhiteSpace(model.SearchString))
            {
                query = query.Where(x => x.Title.Contains(model.SearchString)
                    || x.Content.Contains(model.SearchString));
            }

            IQueryable<InformationItemDisplayModel> listQuery = query
                .OrderByDescending(x => x.Deleted)
                .OrderByDescending(x => x.StartDate)
                .ThenByDescending(x => x.CreatedOn)
                .Select(x => new InformationItemDisplayModel
                {
                    Id = x.Id,
                    Title = x.Title,
                    Content = x.Content,
                    StartDate = x.StartDate,
                    EndDate = x.EndDate,
                    Deleted = x.Deleted,
                });

            QueryResponseModel<InformationItemDisplayModel> queryResponse = listQuery.SortAndFilter(model);

            DataSourceResponseModel<InformationItemDisplayModel> result = new()
            {
                TotalCount = queryResponse.TotalCount,
                Errors = queryResponse.Errors,
                Items = queryResponse.Query
            };

            return result;
        }

        public async Task<IEnumerable<CalendarDisplayModel>> ListCalendarItems(CalendarRequestModel model, CancellationToken cancellationToken)
        {
            ArgumentNullException.ThrowIfNull(model, nameof(model));

            DateTime from = (model.Dates ?? Array.Empty<DateTime>()).Min();
            DateTime to = (model.Dates ?? Array.Empty<DateTime>()).Max();

            IQueryable<VTask> query = _context.VTasks
                .Where(x =>
                    x.AssignedToUserId == _userInfo.CurrentUserId
                    && (x.StatusCode == Shared.TaskStatus.Pending || x.StatusCode == Shared.TaskStatus.NotStarted)
                    && (x.CreatedOn ?? from) <= to && from <= (x.EndDate ?? to));

            var items = await query
                .Take(20)
                .Select(x => new CalendarDisplayModel
                {
                    Id = x.Id,
                    Title = x.Title,
                    StartDate = x.CreatedOn ?? from,
                    EndDate = x.EndDate ?? to,
                    Status = x.StatusCode
                })
                .ToArrayAsync(cancellationToken);

            foreach (var item in items)
            {
                item.StartDate = from > item.StartDate ? from : item.StartDate;
                item.EndDate = to < item.EndDate ? to : item.EndDate;
            }

            return items;
        }
        public Task<InformationItemDisplayModel?> Get(int id, CancellationToken cancellationToken = default)
        {
            return _context.InformationItems
                .Where(x => x.Id == id && !x.Deleted)
                .Select(x => new InformationItemDisplayModel()
                {
                    Id = x.Id,
                    Title = x.Title,
                    Content = x.Content,
                    StartDate = x.StartDate,
                    EndDate = x.EndDate,
                    Deleted = x.Deleted,
                })
                .FirstOrDefaultAsync(cancellationToken);
        }

        public async Task<OperationResult> Create(InformationItemModel model)
        {
            ArgumentNullException.ThrowIfNull(model, nameof(model));

            try
            {
                InformationItem entry = new InformationItem
                {
                    Title = model.Title ?? "",
                    Content = model.Content,
                    StartDate = model.StartDate ?? DateTime.Now.Date,
                    EndDate = model.EndDate,
                    Deleted = false
                };

                _context.InformationItems.Add(entry);

                await _context.SaveAsync($"Information item created");

                return OperationResult.Success;
            }
            catch (Exception ex)
            {
                return OperationResult.Failed(ex.ToString());
            }
        }

        public async Task<OperationResult> Update(InformationItemModel model)
        {
            ArgumentNullException.ThrowIfNull(model, nameof(model));

            try
            {
                InformationItem? entity = await _context.InformationItems.FindAsync(model.Id);
                if (entity == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                entity.Title = model.Title ?? "";
                entity.Content = model.Content;
                entity.StartDate = model.StartDate ?? DateTime.Now.Date;
                entity.EndDate = model.EndDate;

                await _context.SaveAsync("Information item edited");

                return OperationResult.Success;
            }
            catch (Exception ex)
            {
                return OperationResult.Failed(ex.ToString());
            }
        }

        public async Task<OperationResult> Delete(int id)
        {
            try
            {
                InformationItem? entity = await _context.InformationItems.FindAsync(id);
                if (entity == null)
                {
                    return OperationResult.Failed(false, _localizer.GetString("Error_ItemDoesNotExists").ToString());
                }

                entity.Deleted = true;
                entity.DeletedBy = _userInfo.CurrentUserId;
                entity.DeletedOn = DateTime.UtcNow;

                await _context.SaveAsync("Information item deleted");

                return OperationResult.Success;
            }
            catch (Exception ex)
            {
                return OperationResult.Failed(ex.ToString());
            }
        }

    }
}
