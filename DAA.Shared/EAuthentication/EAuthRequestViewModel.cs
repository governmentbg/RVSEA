namespace DAA.Shared.EAuthentication
{
    public class EAuthRequestViewModel
    {
        public string RequestId { get; set; }

        #region Полета, необходими за скритата форма, която се POST-ва към еАвт.

        public string EAuthUrl { get; set; }

        /// <summary>
        /// Base64 кодиран.
        /// Думата SAML е с главни букви, защото това е изискване на SAML протокола и в частност на еАвт.
        /// </summary>
        public string SAMLRequest { get; set; }

        /// <summary>
        /// Base64 кодиран.
        /// </summary>
        public string RelayState { get; set; }

        #endregion

        #region Допълнителни полета за потребителя и за debug цели.

        public string SamlRequestBeautified { get; set; }

        public string SamlRequestDecoded { get; set; }

        public string RelayStateDecoded { get; set; }

        public string SignatureStatusName { get; set; }

        #endregion
    }
}
