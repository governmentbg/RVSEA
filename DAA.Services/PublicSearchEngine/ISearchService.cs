
using DAA.Data;
using DAA.Extensions.DynamicLinq;
using DAA.Models.Search;

namespace DAA.Services.Search
{
    public interface ISearchService
    {
       public Task<DataSourceResponseModel<SearchResult>?> GetAll(CancellationToken token, SearchModel model, bool includeDrafts = false);
       
    }
}
