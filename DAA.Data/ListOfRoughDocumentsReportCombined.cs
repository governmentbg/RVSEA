using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Data
{
    [Keyless]
    public class ListOfRoughDocumentsReportCombined
    {
        public long? FundCount { get; set; }
        public long? InventoryCount { get; set; }
        public decimal? LinearMeters { get; set; }
        public long? Bytes { get; set; }
    }
}
