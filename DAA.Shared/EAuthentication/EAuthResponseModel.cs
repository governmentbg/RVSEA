using System;
using System.Collections.Generic;

namespace DAA.Shared.EAuthentication
{
    public class EAuthResponseModel
    {
        public string SamlResponse { get; set; }

        public string RelayState { get; set; }

        public bool NotDetectedQes { get; set; }

        public List<string> Errors { get; set; }

        public string RequestId { get; set; }

        public string PidTypeCode { get; set; }

        public string PersonIdentifier { get; set; }

        public string PersonNamesLatin { get; set; }

        public string Email { get; set; }

        public string Phone { get; set; }

        public DateTime? ExpirationDateTime { get; set; }
    }
}
