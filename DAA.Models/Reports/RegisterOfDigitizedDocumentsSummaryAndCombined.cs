using DAA.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Models.Reports
{
    public class RegisterOfDigitizedDocumentsSummaryAndCombined
    {
        public RegisterOfDigitizedDocumentsSummary? Summary { get; set; }
        public RegisterOfDigitizedDocumentsCombined? Combined { get; set; }
    }
}
