using System.Collections.Generic;
using System.IO;
using System.Xml;
using System.Xml.Schema;

namespace DAA.Shared.EAuthentication.Certificate.XML
{
    public static class XsdUtil
    {
        public static List<string> ValidateText(string xml, string xsdPath)
        {
            List<string> errors = new List<string>();
            if (xml != null && xsdPath != null)
            {
                XmlReaderSettings settings = new XmlReaderSettings
                {
                    ValidationType = ValidationType.Schema,
                    ValidationFlags = XmlSchemaValidationFlags.ReportValidationWarnings
                };

                settings.Schemas.Add(null, xsdPath);

                settings.ValidationEventHandler += (sender, args) =>
                {
                    errors.Add((args.Severity == XmlSeverityType.Warning ? "Внимание: " : null) + args.Message);
                };

                using (StringReader stringReader = new StringReader(xml))
                {
                    using (XmlReader xmlReader = XmlReader.Create(stringReader, settings))
                    {
                        while (xmlReader.Read()) ;
                    }
                }
            }
            return errors;
        }
    }
}
