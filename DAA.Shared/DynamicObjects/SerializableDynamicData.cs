using System;
using System.Collections.Generic;
using System.Linq;
using System.Security;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Schema;
using System.Xml.Serialization;


namespace DAA.Shared.DynamicObjects
{
    public class SerializableDynamicData : IXmlSerializable
    {
        public List<dynamic> Data { get; set; }

        public XmlSchema GetSchema()
        {
            return new XmlSchema();
        }

        public void ReadXml(XmlReader reader)
        {

        }

        public void WriteXml(XmlWriter writer)
        {
            foreach (dynamic obj in Data)
            {
                var dictionary = obj as IDictionary<string, object>;

                if (dictionary.Count > 0)
                {
                    writer.WriteStartElement("Row");
                    foreach (KeyValuePair<string, object> propertyInfo in dictionary)
                    {
                        string validElementName = XmlConvert.EncodeName(propertyInfo.Key);
                        string validElementValue = propertyInfo.Value?.ToString();
                        writer.WriteElementString(validElementName, SecurityElement.Escape(validElementValue));
                    }
                    writer.WriteEndElement();
                }


            }
        }
    }
}
