using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Archives
{
    public class ArchiveModel
    {
        public int? Id { get; set; }
        public string Name { get; set; } = null!;
        public int Code { get; set; }
        public int? SortOrder { get; set; }
        public int? ExternalIdentifier { get; set; }
        public bool HasExternalSource { get; set; }
    }
}
