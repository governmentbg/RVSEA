using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Shared.Data
{
    public interface IDeletable
    {
        bool Deleted { get; set; }
        Guid? DeletedBy { get; set; }
        DateTime? DeletedOn { get; set; }
    }
}
