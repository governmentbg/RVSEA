using DAA.Services.Authentication;
using DAA.Shared.EAuthentication;
using DAA.Shared.EAuthentication.Certificate;
using DAA.Shared.EAuthentication.Certificate.XML;
using System.Text;
using System.Xml;

namespace DAA.Services.EAuthentication
{
    public class EAuthenticationService : IEAuthenticationService
    {
        private const string _eAuthUrl = "https://eauthn.egov.bg:9445/eAuthenticator/eAuthenticator.seam";

        public const string ClientCertNotSelected = EAuthPersonUtil.ClientCertNotSelected;

        public EAuthRequestViewModel CreateRequestAsync(string requestUrl, string callbackUrl, string serviceOid, string providerOid,
            string? signatureNsPrefix, bool includePublicKey, string sslCertificateThumbprint)
        {
            XmlDocument doc = EAuthPersonUtil.CreateSamlRequest(
                _eAuthUrl, ThisSystem.Oid, ThisSystem.Name, ThisSystem.Name, requestUrl, callbackUrl, serviceOid, providerOid,
                signatureNsPrefix, includePublicKey, sslCertificateThumbprint, out string requestId);

            string samlRequest = doc.OuterXml;
            string relayState = null;

            SignUtil.Status signatureStatus = SignUtil.ValidateText(samlRequest);

            return new EAuthRequestViewModel
            {
                RequestId = requestId,
                // Полета, необходими за скритата форма, която се POST-ва към еАвт.
                EAuthUrl = _eAuthUrl,
                SAMLRequest = EncodeSamlParameter(samlRequest),
                RelayState = EncodeSamlParameter(relayState),
                // Допълнителни полета за потребителя и за debug цели.
                SamlRequestBeautified = XmlUtil.BeautifyXml(samlRequest),
                SamlRequestDecoded = samlRequest,
                RelayStateDecoded = relayState,
                SignatureStatusName = SignUtil.FormatStatus(signatureStatus)
            };
        }

        public (EAuthResponseModel eAuthResponseModel, ResponseType response) Parse(Models.EAuthentication.EAuthCallbackModel callback)
        {
            return EAuthPersonUtil.ParseSamlResponse(callback.SAMLResponse, callback.RelayState);
        }

        public EAuthResponseViewModel GetResponseAsync(/*string requestId*/)
        {
            //ToDo parse ResponseSaml
            //string samlResponse = eAuth.ResponseSaml;
            string samlResponse = string.Empty;

            // Отговорът би трябвало да е подписан със сертификат за еАвт на физически лица
            // с thumbprint "16ebe0544fbd2f9295b3b49a32587614db37b444" (bgEgovEAuthenticatorSigning.cer).
            SignUtil.Status signatureStatus = SignUtil.Status.Invalid;
            XmlDocument doc = new XmlDocument { PreserveWhitespace = true };
            try
            {
                doc.LoadXml(samlResponse);
                signatureStatus = SignUtil.ValidateXmlDocument(doc);
            }
            catch
            {
            }

            // TODO: Всички тези детайли имат смисъл само за debug екран. Да се орежат за масовата употреба.
            return new EAuthResponseViewModel
            {
                //SamlResponseBeautified = XmlUtil.BeautifyXml(doc.OuterXml),
                //SamlResponse = samlResponse,
                //RelayState = eAuth.RelayState,
                //SignatureStatusCode = signatureStatus.ToString(),
                //SignatureStatusName = SignUtil.FormatStatus(signatureStatus),
                //Error = eAuth.Error,
                //PidTypeCode = eAuth.PidTypeCode,
                //PersonIdentifier = eAuth.PersonIdentifier,
                //PersonNamesLatin = eAuth.PersonName,
                //Email = eAuth.Email,
                //Phone = eAuth.Phone,
                //ExpirationDateTime = eAuth.ExpirationDateTime
            };
        }

        // Подаването на еАвт token към RegiX е премахнато, защото се оказа, че пречи.
        // Token-ът е алтернатива на сертификата и служи за идентифициране на системата.
        // Token-ът не е допълнителна информация за текущия потребител.
        //public async Task<string> GetLastNonExpiredResponseForRegiXAsync(string userId)
        //{
        //    string samlResponse = await (
        //        from a in _db.EAuths
        //        where a.UserId == userId && a.ExpirationDateTime > DateTime.Now
        //        orderby a.ResponseDateTime descending
        //        select a.ResponseSaml
        //    ).FirstOrDefaultAsync();
        //    // TODO: Да се проучи дали към RegiX се подава base64 кодирания вариант, xml-а като string или xml-а като структура.
        //    return EncodeSamlParameter(samlResponse);
        //}

        private static string EncodeSamlParameter(string parameter)
        {
            Encoding encoding = Encoding.UTF8;
            return parameter != null ? Convert.ToBase64String(encoding.GetBytes(parameter)) : null;
        }
    }
}
