using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Reports
{
    public class CountOfUsedCopiesOfDocumentsFromForeignArchivesReportInputModel
    {
        public int ReportResultType { get; set; }
        public IList<string>? ArchiveGids { get; set; }
        public IList<string>? ArchiveCodesInternal { get; set; }
    }
}
