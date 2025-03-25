using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Data
{
    [Keyless]
    public class AllDescriptionLevelsInOrder
    {
        public string Code { get; set; }
        public string Label { get; set; }
        public bool HasExternalSource { get; set; }
    }
}
