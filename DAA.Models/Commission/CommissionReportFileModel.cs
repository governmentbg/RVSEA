using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Commission
{
    public class CommissionReportFileModel
    {
        public int? Id { get; set; }
        public int ReportId { get; set; }
        public string Name { get; set; } = null!;
        public string SourceName { get; set; } = null!;
        public string? UncPath { get; set; }
        public string? FileType { get; set; }
        public string? ContentType { get; set; }
        public IFormFile? Content { get; set; }
    }
}
