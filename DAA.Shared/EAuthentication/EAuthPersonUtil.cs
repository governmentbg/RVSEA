/*
Особености на услугата за физически лица.

Връща Status 400 - Incorrect input data! ако:
- XML-ът не отговаря стриктно на схемата, например ако подписът е в края, а не по средата.
- подписът е грешен (данните на заявката не отговарят на подписа).
- id-то на заявката започва с цифра.
- RequestedService.Provider или Service не започва с 2.16.100.

еАвт проверява RequestedService още преди сертификата, при което връща прекалено обща грешка.
При невалиден RequestedService.Service, дори да не се избере сертификат
(т.е. ако те натисне Cancel в диалога за избор), грешката не е "NOT_DETECTED_QES",
както пише в документа, а е по-общото "Некоректни данни".

В успешния отговор има два подписа - на целия документ и на част от него.
Новите редове в base64-кодирания сертификат на вложения подпис са важни.
Освен това, те са само '\n', а не '\r\n'.

RequestedService
-----------------
Provider трябва да започва с "2.16.100", след което може да пише всичко.
За Service трябва да се подаде съществуващо OID и да се уцели "работещо" такова.
Работещите OID са на услуги или версии, както и на администрации или ИС, които предоставят услуга.

За доста OID-та обаче връща SAML резултат с грешка "Некоректни данни", например за:
2.16.100.1.1.1.1.1.1.1*  // Услуга: Извличане на данни за обектен идентификатор (и всички версии).
2.16.100.1.1.1.1.2*  // ИС: Регистър на ресурсите (и всички негови услуги).
2.16.100.1.1.1.1.3  // ИС: Справочник за атрибути.
2.16.100.1.1.1.1.6  // ИС: Шина за услуги.
2.16.100.1.1.1.1.9  // ИС: Портал на електронното управление.
2.16.100.1.1.1.1.11  // ИС: Система за удостоверение на време.
2.16.100.1.1.1.1.14  // ИС: Система за електронно валидиране.
2.16.100.1.1.43.1.1  // ИС: RegUX.

За следните OID-та се забавя и гърми:
2.16.100
2.16.100.1
2.16.100.1.1
За следните OID-та се забавя много, но връща Destination="http://172.23.107.76:8080/oidRegistry/OIDRegistryPort"
2.16.100.1.1.1 (Администрация МТИТС)
2.16.100.1.1.1.1 (няма такова)
2.16.100.1.1.1.1.1 (Регистър на обектните идентификатори)

За следните OID-та работи:
За 2.16.100.1.1.1.1.4* (Компонент за еднократна автентификация) връща Destination="http://egov.bg/bes/wsEauth/"
За 2.16.100.1.1.1.1.8*  (Журнал на достъпа, например) връща Destination="http://172.23.107.71:8080/auditLogReport/eventsReport.seam"
Пример: 2.16.100.1.1.1.1.8.3.1.1 (Версия 1.0 на услуга за справки в журнала на събития, свързани с жизнения цикъл на ЕАУ)
За 2.16.100.1.1.1.1.12 (Система за електронни плащания) връща Destination=" https://miro.abbaty.com:8443/account/eauthlogin"
За 2.16.100.1.1.1.1.13 (Система за електронно връчване) връща Destination="http://egov.bg/bes/wse-service/v1/port1"
За 2.16.100.1.1.7 (Министерство на правосъдието) връща Destination="https://cs.mjs.bg/account/eauthlogin"
...
*/

using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Xml;
using System.Xml.Serialization;
using DAA.Shared.EAuthentication.Certificate;
using DAA.Shared.EAuthentication.Certificate.XML;

namespace DAA.Shared.EAuthentication
{
    public static class EAuthPersonUtil
    {
        public const string PidTypeEgn = "EGN";
        // Към 2018-02 не за известни други видове идентификатор.
        //public const string PidType??? = "???";

        //        Неуспешен опит за вход с електронен подпис. Най-често това се случва:
        //а) когато затворите списъка за избор на сертификат без да изберете нищо.
        //б) когато не е инсталиран нито един валиден сертификат - тогава списъкът не се появява.

        //Преди да опитате отново трябва да затворите всички страници т.е. да рестартирате браузъра. В противен случай ще продължите да виждате това съобщение.;
        public const string ClientCertNotSelected = "ClientCertNotSelected";

        private const string _requestIdDateTimeFormat = "yyyyMMddHHmmssfff";

        // Много от генерираните класове и property-та са анотирани с тези namespaces. Тук просто се прочитат от произволнен клас, за да се преизползват.
        // urn:oasis:names:tc:SAML:2.0:protocol
        private static readonly string _samlProtocolNs = GetTypeNs(typeof(AuthnRequestType));
        // urn:bg:egov:eauth:1.0:saml:ext
        private static readonly string _eauthExtNs = GetTypeNs(typeof(RequestedServiceType));
        // urn:oasis:names:tc:SAML:2.0:assertion
        private static readonly string _samlAssertionNs = GetTypeNs(typeof(NameIDType));

        private static string GetTypeNs(Type type)
        {
            return ((XmlTypeAttribute)type.GetCustomAttributes(typeof(XmlTypeAttribute), true)[0]).Namespace;
        }

        public static XmlDocument CreateSamlRequest(
            string eAuthUrl,
            string callerOid,
            string callerName,
            string idPrefix,  // Не трябва да започва с цифра.
            string requestUrl,
            string callbackUrl,
            string requestedServiceOid,
            string requestedProviderOid,
            // Параметри за подписването.
            string? signatureNsPrefix,
            bool includePublicKey,
            string sslCertificateThumbprint,
            out string id)
        {
            DateTime now = DateTime.Now;
            // Закръгление до милисекунди.
            now = new DateTime(now.Year, now.Month, now.Day, now.Hour, now.Minute, now.Second, now.Millisecond);
            id = $"{idPrefix ?? "ID"}_{now.ToString(_requestIdDateTimeFormat, System.Globalization.CultureInfo.InvariantCulture)}";

            AuthnRequestType authnRequest = new AuthnRequestType
            {
                ID = id,
                Version = "2.0",
                // Според дадения пример, IssueInstant="2015-06-29T03:00:09", т.е. стойността е закръглена до секунда и няма time zone.
                IssueInstant = new DateTime(now.Year, now.Month, now.Day, now.Hour, now.Minute, now.Second, DateTimeKind.Unspecified),
                ProtocolBinding = "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST",
                Destination = eAuthUrl,
                ForceAuthn = true,
                ForceAuthnSpecified = true,
                IsPassive = false,
                IsPassiveSpecified = true,
                ProviderName = callerName,
                AssertionConsumerServiceURL = callbackUrl,
                // Информационна система, която инициира автентификация.
                Issuer = new NameIDType
                {
                    SPProvidedID = callerOid,
                    Value = requestUrl
                },
                // Според документацията: версия на услугата + информационна система, която я предоставя.
                // Реално работи също и с информационна система + администрация-собственик.
                Extensions = new ExtensionsType
                {
                    RequestedService = new RequestedServiceType
                    {
                        Service = requestedServiceOid,
                        Provider = requestedProviderOid
                    }
                }
            };

            return SignSamlRequest(authnRequest, signatureNsPrefix, includePublicKey, sslCertificateThumbprint);
        }

        private static XmlDocument SignSamlRequest(AuthnRequestType request, string? signatureNsPrefix, bool includePublicKey, string sslCertificateThumbprint)
        {
            X509Certificate2 cert = SignUtil.LoadCertificate(StoreName.My, StoreLocation.LocalMachine, sslCertificateThumbprint);

            XmlSerializerNamespaces ns = new XmlSerializerNamespaces();
            ns.Add("samlp", _samlProtocolNs);
            if (!string.IsNullOrEmpty(signatureNsPrefix))
            {
                ns.Add(signatureNsPrefix, SignUtil.SignatureNamespace);
            }
            ns.Add("egovbga", _eauthExtNs);
            ns.Add("saml", _samlAssertionNs);
            XmlDocument doc = request.ToXmlDocument(ns);

            XmlElement signatureElement = SignUtil.Sign(doc, cert, signatureNsPrefix, includePublicKey);

            // Подписът вече е добавен в XML документа и по подразбиране е в края му. Според "saml-schema-protocol-2.0.xsd" обаче,
            // подписът трябва да бъде между елементите Issuer и Extensions. InsertAfter() го маха от старото място и го закача на новото.
            XmlNode issuerElement = doc.GetElementsByTagName(nameof(request.Issuer), _samlAssertionNs)[0];
            doc.DocumentElement.InsertAfter(signatureElement, issuerElement);

            return doc;
        }

        public static DateTime ExtractDateTimeFromId(string samlRequestId)
        {
            if (string.IsNullOrEmpty(samlRequestId))
            {
                throw new ArgumentNullException(nameof(samlRequestId));
            }
            int startPos = samlRequestId.LastIndexOf('_');
            string dateText = samlRequestId.Substring(startPos + 1);
            return DateTime.ParseExact(dateText, _requestIdDateTimeFormat, System.Globalization.CultureInfo.InvariantCulture);
        }

        public static (EAuthResponseModel eAuthResponseModel, ResponseType response) ParseSamlResponse(string encodedSamlResponse, string encodedRelayState)
        {
            EAuthResponseModel model = new EAuthResponseModel { Errors = new List<string>() };
            ResponseType response = null;
            if (encodedSamlResponse != null)
            {
                string stepName = "декодиране на base64 текста";
                try
                {
                    model.SamlResponse = DecodeSamlParameter(encodedSamlResponse);

                    stepName = "десериализиране на отговора";
                    response = XmlUtil.Deserialize<ResponseType>(model.SamlResponse);

                    stepName = "четене на полетата от отговора";
                    InterpretResponse(response, model);
                }
                catch (Exception ex)
                {
                    model.Errors.Add($"Грешка при {stepName}: {ex.Message}");
                }
            }
            else
            {
                model.Errors.Add("Отговорът е празен");
            }

            if (encodedRelayState != null)
            {
                try
                {
                    model.RelayState = DecodeSamlParameter(encodedRelayState);
                }
                catch (Exception ex)
                {
                    model.Errors.Add($"Грешка при декодиране на base64 relayState: {ex.Message}");
                }
            }

            return (model, response);
        }

        private static void InterpretResponse(ResponseType response, EAuthResponseModel model)
        {
            model.RequestId = response.InResponseTo;

            // Пример за грешка:
            // <samlp:Status>
            //   <samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Responder"><samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:AuthnFailed" /></samlp:StatusCode>
            //   <samlp:StatusMessage>NOT_DETECTED_QES ***ИЛИ*** Некоректни данни</samlp:StatusMessage>
            // </samlp:Status>
            // Пример за успех:
            // <samlp:Status>
            //   <samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success" />
            //   <samlp:StatusMessage>Успешен отговор на заявката</samlp:StatusMessage>
            // </samlp:Status>
            StatusType status = response.Status;
            if (status != null)
            {
                bool isSuccessful = status.StatusCode?.Value.EndsWith("Success") ?? false;

                string statusMessage = status.StatusMessage;
                // Ако в заявката към еАвт не е подаден сертификат, системата вместо съобщение за грешка връща код NOT_DETECTED_QES
                // ИЛИ съобщение "STS Exception: STSToken exception: bg.egov.mtits.eauthn.delegate.exceptions.STSDelegateException : null".
                if (statusMessage == "NOT_DETECTED_QES" || statusMessage != null && statusMessage.Contains("STSDelegateException"))
                {
                    model.NotDetectedQes = true;
                    model.Errors.Add(ClientCertNotSelected);
                }
                else if (!isSuccessful)  // Съобщението за успех не се пази.
                {
                    if (!string.IsNullOrEmpty(statusMessage))
                    {
                        model.Errors.Add(statusMessage);
                    }

                    XmlElement[] details = status.StatusDetail?.Any;
                    if (details != null)
                    {
                        model.Errors.AddRange(details.Select(e => e.OuterXml));
                    }
                }
            }

            if (response.Items?[0] is AssertionType assertion)
            {
                ConditionsType conditions = assertion.Conditions;
                if (conditions != null && conditions.NotOnOrAfterSpecified)
                {
                    model.ExpirationDateTime = conditions.NotOnOrAfter;
                }

                // Пример за ЕГН:
                // <saml2:Subject>
                //   <saml2:NameID Format="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" NameQualifier="urn:egov:bg:eauth:1.0:attributes:eIdentifier:EGN">8012311234</saml2:NameID>
                //   <saml2:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:sender-vouches"><saml2:SubjectConfirmationData /></saml2:SubjectConfirmation>
                // </saml2:Subject>
                NameIDType nameId = assertion.Subject?.Items?.OfType<NameIDType>().FirstOrDefault();
                if (nameId != null)
                {
                    model.PidTypeCode = nameId.NameQualifier?.Split(':').Last();  // Към 2018-02 е известен само вид "EGN".
                    model.PersonIdentifier = nameId.Value;
                }

                // Пример за име и контакти:
                // <saml2:AttributeStatement>
                //   <saml2:Attribute Name="urn:egov:bg:eauth:1.0:attributes:personNamesLatin" NameFormat="urn:egov:bg:eauth:1.0:attributes:personNamesLatin">
                //     <saml2:AttributeValue xsi:type="xs:string">Ivan Dilyanov Dilov</saml2:AttributeValue>
                //   </saml2:Attribute>
                //   <saml2:Attribute Name="urn:egov:bg:eauth:1.0:attributes:eMail" NameFormat="urn:egov:bg:eauth:1.0:attributes:eMail">
                //     <saml2:AttributeValue xsi:type="xs:string">idilov@gmail.com</saml2:AttributeValue>
                //   </saml2:Attribute>
                //   <saml2:Attribute Name="urn:egov:bg:eauth:1.0:attributes:phone" NameFormat="urn:egov:bg:eauth:1.0:attributes:phone">
                //     <saml2:AttributeValue xsi:type="xs:string">+359 888476663</saml2:AttributeValue>
                //   </saml2:Attribute>
                // </saml2:AttributeStatement>
                if (assertion.Items != null)
                {
                    foreach (AttributeStatementType attributes in assertion.Items.OfType<AttributeStatementType>())
                    {
                        if (attributes.Items != null)
                        {
                            foreach (AttributeType attribute in attributes.Items.OfType<AttributeType>())
                            {
                                string type = attribute.Name?.Split(':').Last().ToLower();
                                string value = attribute.AttributeValue != null ? string.Join(Environment.NewLine, attribute.AttributeValue.Where(v => v != null)) : null;
                                if (type == "personnameslatin")
                                {
                                    model.PersonNamesLatin = value;
                                }
                                else if (type == "email")
                                {
                                    model.Email = value;
                                }
                                else if (type == "phone")
                                {
                                    model.Phone = value;
                                }
                            }
                        }
                    }
                }
            }
        }

        private static string DecodeSamlParameter(string parameter)
        {
            Encoding encoding = Encoding.UTF8;
            return parameter != null ? encoding.GetString(Convert.FromBase64String(parameter)) : null;
        }
    }
}
