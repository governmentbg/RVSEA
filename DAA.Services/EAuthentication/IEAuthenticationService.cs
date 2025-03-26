using DAA.Shared.EAuthentication;

namespace DAA.Services.Authentication
{
    public interface IEAuthenticationService
    {
        EAuthRequestViewModel CreateRequestAsync(string requestUrl, string callbackUrl, string serviceOid, string providerOid,
            string? signatureNsPrefix, bool includePublicKey, string sslCertificateThumbprint);
        (EAuthResponseModel eAuthResponseModel, ResponseType response) Parse(Models.EAuthentication.EAuthCallbackModel callback);
        EAuthResponseViewModel GetResponseAsync();
    }
}
