using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Data
{
    [Keyless]
    public class NumberOfDocumentsOrderedByEmployeeReportCombined
    {
        public int? DisticntAEsCount { get; set; }
        public int? DocumentsReviewsCount { get; set; }
    }
}
