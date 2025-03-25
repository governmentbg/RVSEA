using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Nomenclatures
{
    public class NomenclatureModel
    {
        public int? Id { get; set; }
        public string Code { get; set; } = null!;
        public string Text { get; set; } = null!;
        public string? Description { get; set; }
        public int? SortOrder { get; set; }
        public bool Inactive { get; set; }
        public bool Locked { get; set; }
    }
}
