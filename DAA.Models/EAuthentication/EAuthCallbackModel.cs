namespace DAA.Models.EAuthentication
{
    public class EAuthCallbackModel
    {
        /// <summary>
        /// Base64 кодиран.
        /// Думата SAML е с главни букви, защото това е изискване на SAML протокола и в частност на еАвт.
        /// </summary>
        public string SAMLResponse { get; set; }

        /// <summary>
        /// Base64 кодиран.
        /// </summary>
        public string? RelayState { get; set; }
    }
}
