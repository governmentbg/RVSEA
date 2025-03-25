using System.IO;
using System.Text;
using System.Xml;
using System.Xml.Linq;
using System.Xml.Serialization;
using System.Xml.XPath;

namespace DAA.Shared.EAuthentication.Certificate.XML
{
    public static class XmlUtil
    {
        /// <summary>
        /// Добавя indentation към подадения едноредов XML.
        /// </summary>
        public static string BeautifyXml(string xml)
        {
            if (!string.IsNullOrWhiteSpace(xml))
            {
                try
                {
                    return XDocument.Parse(xml).ToString();
                }
                catch
                {
                    // Подаденият текст вероятно не е XML, затова се връща в оригинал.
                }
            }
            return xml;
        }

        public static XmlDocument ToXmlDocument<T>(this T o, XmlSerializerNamespaces ns)
        {
            XmlDocument doc = new XmlDocument();
            XPathNavigator navigator = doc.CreateNavigator();
            XmlSerializer ser = new XmlSerializer(typeof(T));
            using (XmlWriter writer = navigator.AppendChild())
            {
                ser.Serialize(writer, o, ns);
            }
            return doc;
        }

        private static readonly Encoding _utf8WithoutBom = new UTF8Encoding(false);

        public static byte[] ToUtf8Xml<T>(this T o)
        {
            XmlSerializer ser = new XmlSerializer(typeof(T));
            XmlWriterSettings settings = new XmlWriterSettings
            {
                Indent = true,
                NewLineOnAttributes = true,
                Encoding = _utf8WithoutBom
            };
            using (MemoryStream memory = new MemoryStream())
            {
                using (var writer = XmlWriter.Create(memory, settings))
                {
                    ser.Serialize(writer, o);
                    return memory.ToArray();
                }
            }
        }

        public static T Deserialize<T>(string xmlText)
        {
            XmlSerializer ser = new XmlSerializer(typeof(T));
            using (StringReader reader = new StringReader(xmlText))
            {
                return (T)ser.Deserialize(reader);
            }
        }
    }
}
