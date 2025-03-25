using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Shared.Attributes
{
    [AttributeUsage(AttributeTargets.All, Inherited = false, AllowMultiple = false)]
    public class ValidateAgainstListAttribute : Attribute
    {
        public ExcelDropDownListType FKSourceName { get; }


        public ValidateAgainstListAttribute(ExcelDropDownListType fkSourceName)
        {
            this.FKSourceName = fkSourceName;
        }

    }
}
