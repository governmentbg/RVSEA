using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Shared.Security
{
    public static class AuthenticationType
    {
        /// <summary>
        /// Authentication using a digital signature.
        /// </summary>
        public const string Signature = "SIGNATURE";
        /// <summary>
        /// Username and password authentication.
        /// </summary>
        public const string Password = "PASSWORD";
        /// <summary>
        /// Negotiated authentication.
        /// </summary>
        public const string Negotiate = "NEGOTIATE";
        /// <summary>
        /// Authentication using E-authentication platform
        /// </summary>
        public const string EAuth = "EAUTH";
    }
}
