namespace DAA.Models.Configuration
{
    public class EAuthSettings
    {
        public const string Name = "EAuthConfig";
        public string? CertificateThumbprint { get; set; }
        public string? RequestedServiceOid { get; set; }
        public string? RequestedProviderOid { get; set; }
    }
}
