using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Data
{
    [Keyless]
    public class DigitalObjectsPreparationCombined
    {
        public DateTime? PeriodFrom { get; set; }
        public DateTime? PeriodTo { get; set; }
        public int? NewDocuments { get; set; }
        public int? NewDo { get; set; }
        public int? RecreatedDocuments { get; set; }
        public int? RecreatedDo { get; set; }
    }
}
