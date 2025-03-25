using System;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Security.Cryptography.Xml;
using System.Xml;

namespace DAA.Shared.EAuthentication.Certificate
{
    public static class SignUtil
    {
        public static X509Certificate2 LoadCertificate(StoreName storeName, StoreLocation storeLocation, string thumbprint)
        {
            if (string.IsNullOrEmpty(thumbprint))
            {
                throw new ArgumentException(nameof(thumbprint));
            }
            using (X509Store store = new X509Store(storeName, storeLocation))
            {
                store.Open(OpenFlags.ReadOnly);
                X509Certificate2Collection certs = store.Certificates.Find(X509FindType.FindByThumbprint, thumbprint, false);
                return certs.Count > 0 ? certs[0] : null;
            }
        }

        public static XmlElement Sign(XmlDocument doc, X509Certificate2 cert, string? signatureNsPrefix, bool includePublicKey)
        {
            if (doc == null)
            {
                throw new ArgumentException(nameof(doc));
            }
            if (cert == null)
            {
                throw new ArgumentException(nameof(cert));
            }

            XmlElement signatureElement;
            try
            {
                using (AsymmetricAlgorithm privateKey = cert.GetRSAPrivateKey())
                {
                    signatureElement = SignWithPrivateKey(doc, cert, privateKey, signatureNsPrefix, includePublicKey);
                }
            }
            catch (NotSupportedException)
            {
                signatureElement = SignWithPrivateKey(doc, cert, cert.PrivateKey, signatureNsPrefix, includePublicKey);
            }

            return (XmlElement)doc.DocumentElement.AppendChild(doc.ImportNode(signatureElement, true));
        }

        private static XmlElement SignWithPrivateKey(XmlDocument doc, X509Certificate2 cert, AsymmetricAlgorithm privateKey, string signatureNsPrefix, bool includePublicKey)
        {
            SignedXmlWithPrefix signedXml = new SignedXmlWithPrefix(doc.DocumentElement)
            {
                SigningKey = privateKey
            };

            KeyInfo keyInfo = signedXml.KeyInfo;
            if (includePublicKey)
            {
                keyInfo.AddClause(new KeyInfoName("Public key of certificate"));
                keyInfo.AddClause(new RSAKeyValue((RSA)cert.PublicKey.Key));
            }
            KeyInfoX509Data x509data = new KeyInfoX509Data(cert);
            x509data.AddIssuerSerial(cert.Issuer, cert.SerialNumber);
            x509data.AddSubjectName(cert.Subject);
            keyInfo.AddClause(x509data);

            Reference reference = new Reference(string.Empty);
            reference.AddTransform(new XmlDsigEnvelopedSignatureTransform(true));
            reference.AddTransform(new XmlDsigC14NTransform());
            signedXml.AddReference(reference);

            // Връщат се старите алгоритми за подписване, използвани по подразбиране в .net framework
            // защото самият е-Автентикатор е стар и не разбира новите алгоритми, използвани по подразбиране в .net core.
            signedXml.SignedInfo.SignatureMethod = SignedXml.XmlDsigRSASHA1Url;
            reference.DigestMethod = SignedXml.XmlDsigSHA1Url;

            if (!string.IsNullOrEmpty(signatureNsPrefix))
            {
                signedXml.ComputeSignature(signatureNsPrefix);
                return signedXml.GetXml(signatureNsPrefix);
            }
            signedXml.ComputeSignature();
            return signedXml.GetXml();
        }

        public enum Status
        {
            Invalid,
            ValidSig,
            ValidSigAndCert
        }

        public static string FormatStatus(Status status)
        {
            return status == Status.ValidSigAndCert ? "ВАЛИДНИ подпис и сертификат" : status == Status.ValidSig ? "ВАЛИДЕН подпис" : "НЕвалиден подпис";
        }

        public static Status ValidateText(string xmlText)
        {
            if (string.IsNullOrEmpty(xmlText))
            {
                throw new ArgumentException(nameof(xmlText));
            }
            XmlDocument doc = new XmlDocument { PreserveWhitespace = true };
            doc.LoadXml(xmlText);
            return ValidateXmlDocument(doc);
        }

        public static Status ValidateFile(string filePath)
        {
            if (string.IsNullOrEmpty(filePath))
            {
                throw new ArgumentException(nameof(filePath));
            }

            XmlDocument doc = new XmlDocument { PreserveWhitespace = true };
            doc.Load(filePath);
            return ValidateXmlDocument(doc);
        }

        public const string SignatureElementName = "Signature";
        public const string CertificateElementName = "X509Certificate";
        public const string SignatureNamespace = SignedXml.XmlDsigNamespaceUrl;

        /// <summary>
        /// Важно: Документът трябва да е бил създаден с PreserveWhitespace = true;
        /// </summary>
        public static Status ValidateXmlDocument(XmlDocument doc)
        {
            XmlNodeList signatures = doc.GetElementsByTagName(SignatureElementName, SignatureNamespace);
            if (signatures.Count == 0)
            {
                throw new Exception($"XML документът не е подписан. Липсва елемент с име \"{SignatureElementName}\".");
            }
            XmlElement signature = (XmlElement)signatures[0];  // Не се поддържат няколко подписа в един документ.

            SignedXml signedXml = null;
            // Ако е подписан конкретен елемент, неговото id е записано в URI атрибута на Reference поделемента, с префикс "#".
            // В този случай в конструктора на SingedXml трябва да се подаде точно този елемент, а не целият документ.
            XmlNodeList references = signature.GetElementsByTagName("Reference", SignatureNamespace);
            if (references.Count > 0)
            {
                string signedElementId = references[0].Attributes["URI"]?.Value?.TrimStart('#');  // Не се поддържат няколко reference-а в един подпис.
                if (!string.IsNullOrEmpty(signedElementId))
                {
                    // По спефицикация името на атрибута трябва да бъде "Id", но масово се среща "id" и някои валидатори го приемат.
                    XmlNodeList signedElements = doc.SelectNodes($"//node()[@id='{signedElementId}' or @Id='{signedElementId}']");
                    if (signedElements.Count > 0)
                    {
                        signedXml = new SignedXml((XmlElement)signedElements[0]);
                    }
                }
            }

            // Ако не е подписан конкретен елемент, значи е подписан целият документ.
            if (signedXml == null)
            {
                signedXml = new SignedXml(doc);
            }
            signedXml.LoadXml(signature);

            XmlNodeList certificates = signature.GetElementsByTagName(CertificateElementName, SignatureNamespace);

            bool signatureIsValid;
            if (certificates.Count > 0)
            {
                X509Certificate2 x509cert = new X509Certificate2(Convert.FromBase64String(certificates[0].InnerText));
                signatureIsValid = signedXml.CheckSignature(x509cert, true);
                if (signatureIsValid && signedXml.CheckSignature(x509cert, false))
                {
                    return Status.ValidSigAndCert;
                }
            }
            else
            {
                signatureIsValid = signedXml.CheckSignatureReturningKey(out AsymmetricAlgorithm signingKey);
            }
            return signatureIsValid ? Status.ValidSig : Status.Invalid;
        }
    }
}
