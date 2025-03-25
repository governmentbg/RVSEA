using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Shared.Data
{
    public interface IEditable
    {
        Guid? UpdatedBy { get; set; }
        DateTime? UpdatedOn { get; set; }
    }
}
