using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Shared.Data
{
    public interface ICreatable
    {
        // TODO !!! CreatedBy и CreatedOn не може да са nullable, попълват се при създаване на обекта !!!
        Guid? CreatedBy { get; set; }
        DateTime? CreatedOn { get; set; }
    }
}
