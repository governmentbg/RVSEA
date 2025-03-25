using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Shared.EAuthentication
{
    public class EAuthResponseViewModel
    {
        #region Текстов вид на данните

        public string SamlResponseBeautified { get; set; }

        public string SamlResponse { get; set; }

        public string RelayState { get; set; }

        #endregion

        #region Състояние

        public string SignatureStatusCode { get; set; }

        public string SignatureStatusName { get; set; }

        public string Error { get; set; }

        #endregion

        #region Интерпретация на резултата

        public string PidTypeCode { get; set; }

        public string PersonIdentifier { get; set; }

        public string PersonNamesLatin { get; set; }

        public string Email { get; set; }

        public string Phone { get; set; }

        public DateTime? ExpirationDateTime { get; set; }

        #endregion
    }
}
