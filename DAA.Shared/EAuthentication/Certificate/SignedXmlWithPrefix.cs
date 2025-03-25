using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Security.Cryptography;
using System.Security.Cryptography.Xml;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace DAA.Shared.EAuthentication.Certificate
{
    public class SignedXmlWithPrefix : SignedXml
    {
        private XmlElement _xmlElement;

        public SignedXmlWithPrefix(XmlElement xmlElement)
            : base(xmlElement)
        {
            _xmlElement = xmlElement;
        }

        public XmlElement GetXml(string prefix)
        {
            XmlElement e = GetXml();
            SetPrefix(prefix, e);
            return e;
        }

        public void ComputeSignature(string prefix)
        {
            BuildDigestedReferences();
            AsymmetricAlgorithm signingKey = SigningKey;
            if (signingKey == null)
            {
                throw new CryptographicException("Cryptography_Xml_LoadKeyFailed");
            }
            if (SignedInfo.SignatureMethod == null)
            {
                if (!(signingKey is DSA))
                {
                    if (!(signingKey is RSA))
                    {
                        throw new CryptographicException("Cryptography_Xml_CreatedKeyFailed");
                    }
                    if (SignedInfo.SignatureMethod == null)
                    {
                        SignedInfo.SignatureMethod = XmlDsigRSASHA1Url;
                    }
                }
                else
                {
                    SignedInfo.SignatureMethod = XmlDsigDSAUrl;
                }
            }
            SignatureDescription description = CryptoConfig.CreateFromName(SignedInfo.SignatureMethod) as SignatureDescription;
            if (description == null)
            {
                throw new CryptographicException("Cryptography_Xml_SignatureDescriptionNotCreated");
            }
            HashAlgorithm hash = description.CreateDigest();
            if (hash == null)
            {
                throw new CryptographicException("Cryptography_Xml_CreateHashAlgorithmFailed");
            }
            GetC14NDigest(hash, prefix);
            m_signature.SignatureValue = description.CreateFormatter(signingKey).CreateSignature(hash);
        }

        private byte[] GetC14NDigest(HashAlgorithm hash, string prefix)
        {
            XmlDocument doc = new XmlDocument
            {
                PreserveWhitespace = false
            };
            XmlElement e = SignedInfo.GetXml();
            doc.AppendChild(doc.ImportNode(e, true));

            List<XmlAttribute> namespaces = Utils.GetPropagatedAttributes(_xmlElement);
            Utils.AddNamespaces(doc.DocumentElement, namespaces);

            Transform canonicalizationMethodObject = SignedInfo.CanonicalizationMethodObject;
            SetPrefix(prefix, doc.DocumentElement);
            canonicalizationMethodObject.LoadInput(doc);
            return canonicalizationMethodObject.GetDigestedOutput(hash);
        }

        private void BuildDigestedReferences()
        {
            Type t = typeof(SignedXml);
            MethodInfo m = t.GetMethod(nameof(BuildDigestedReferences), BindingFlags.NonPublic | BindingFlags.Instance);
            m.Invoke(this, new object[] { });
        }

        private static void SetPrefix(string prefix, XmlNode node)
        {
            foreach (XmlNode n in node.ChildNodes)
            {
                SetPrefix(prefix, n);
            }
            node.Prefix = prefix;
        }
    }
}
