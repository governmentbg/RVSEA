using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Shared.Excel
{
    public class ExcelDDL
    {
        public ExcelDropDownListType ListType { get; set; }
        public IList<ExcelDDLItem> Collection { get; set; }
    }

    public class ExcelDDLItem
    {
        public object Value { get; set; }
        public string DisplayName { get; set; }
        public object ParentValue { get; set; }
    }
}
