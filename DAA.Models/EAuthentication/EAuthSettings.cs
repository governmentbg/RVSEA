namespace DAA.Models.EAuthentication
{
    public class EAuthSettings
    {
        public string CertificateThumbprint { get; set; }

        /// <summary>
        /// За някои OID-та на заявена услуга се връща резултат с грешка "Некоректни данни",
        /// затова по подразбиране се използват тези проверени OID-та.
        /// </summary>
        public string RequestedServiceOid { get; set; }
        /// <summary>
        /// За някои OID-та на заявена услуга се връща резултат с грешка "Некоректни данни",
        /// затова по подразбиране се използват тези проверени OID-та.
        /// </summary>
        public string RequestedProviderOid { get; set; }
    }
}
