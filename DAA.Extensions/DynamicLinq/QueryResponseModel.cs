using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Extensions.DynamicLinq
{
    public class QueryResponseModel<T>
    {
        public long TotalCount { get; set; }

        public IEnumerable<T> Query { get; set; } = Enumerable.Empty<T>();
        public List<object>? Errors { get; set; }
    }
}
