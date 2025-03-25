using System.Xml;

namespace DAA.Shared.EAuthentication.Certificate
{
    internal class Utils
    {
        internal static List<XmlAttribute> GetPropagatedAttributes(XmlElement elem)
        {
            if (elem == null)
                return null;

            List<XmlAttribute> namespaces = new List<XmlAttribute>();
            XmlNode ancestorNode = elem;

            if (ancestorNode == null) return null;

            bool bDefNamespaceToAdd = true;

            while (ancestorNode != null)
            {
                XmlElement ancestorElement = ancestorNode as XmlElement;
                if (ancestorElement == null)
                {
                    ancestorNode = ancestorNode.ParentNode;
                    continue;
                }
                if (!IsCommittedNamespace(ancestorElement, ancestorElement.Prefix, ancestorElement.NamespaceURI))
                {
                    if (!IsRedundantNamespace(ancestorElement, ancestorElement.Prefix, ancestorElement.NamespaceURI))
                    {
                        string name = ((ancestorElement.Prefix.Length > 0) ? "xmlns:" + ancestorElement.Prefix : "xmlns");
                        XmlAttribute nsattrib = elem.OwnerDocument.CreateAttribute(name);
                        nsattrib.Value = ancestorElement.NamespaceURI;
                        namespaces.Add(nsattrib);
                    }
                }
                if (ancestorElement.HasAttributes)
                {
                    XmlAttributeCollection attribs = ancestorElement.Attributes;
                    foreach (XmlAttribute attrib in attribs)
                    {
                        if (bDefNamespaceToAdd && attrib.LocalName == "xmlns")
                        {
                            XmlAttribute nsattrib = elem.OwnerDocument.CreateAttribute("xmlns");
                            nsattrib.Value = attrib.Value;
                            namespaces.Add(nsattrib);
                            bDefNamespaceToAdd = false;
                            continue;
                        }

                        if (attrib.Prefix == "xmlns" || attrib.Prefix == "xml")
                        {
                            namespaces.Add(attrib);
                            continue;
                        }
                        if (attrib.NamespaceURI.Length > 0)
                        {
                            if (!IsCommittedNamespace(ancestorElement, attrib.Prefix, attrib.NamespaceURI))
                            {
                                if (!IsRedundantNamespace(ancestorElement, attrib.Prefix, attrib.NamespaceURI))
                                {
                                    string name = ((attrib.Prefix.Length > 0) ? "xmlns:" + attrib.Prefix : "xmlns");
                                    XmlAttribute nsattrib = elem.OwnerDocument.CreateAttribute(name);
                                    nsattrib.Value = attrib.NamespaceURI;
                                    namespaces.Add(nsattrib);
                                }
                            }
                        }
                    }
                }
                ancestorNode = ancestorNode.ParentNode;
            }

            return namespaces;
        }


        internal static bool IsCommittedNamespace(XmlElement element, string prefix, string value)
        {
            if (element == null)
                throw new ArgumentNullException("element");

            string name = ((prefix.Length > 0) ? "xmlns:" + prefix : "xmlns");
            if (element.HasAttribute(name) && element.GetAttribute(name) == value) return true;
            return false;
        }

        internal static bool IsRedundantNamespace(XmlElement element, string prefix, string value)
        {
            if (element == null)
                throw new ArgumentNullException("element");

            XmlNode ancestorNode = ((XmlNode)element).ParentNode;
            while (ancestorNode != null)
            {
                XmlElement ancestorElement = ancestorNode as XmlElement;
                if (ancestorElement != null)
                    if (HasNamespace(ancestorElement, prefix, value)) return true;
                ancestorNode = ancestorNode.ParentNode;
            }

            return false;
        }

        private static bool HasNamespace(XmlElement element, string prefix, string value)
        {
            if (IsCommittedNamespace(element, prefix, value)) return true;
            if (element.Prefix == prefix && element.NamespaceURI == value) return true;
            return false;
        }

        internal static void AddNamespaces(XmlElement elem, List<XmlAttribute> namespaces)
        {
            if (namespaces != null)
            {
                foreach (XmlNode attrib in namespaces)
                {
                    string name = ((attrib.Prefix.Length > 0) ? attrib.Prefix + ":" + attrib.LocalName : attrib.LocalName);

                    if (elem.HasAttribute(name)) continue;

                    XmlAttribute nsattrib = elem.OwnerDocument.CreateAttribute(name);
                    nsattrib.Value = attrib.Value;
                    elem.SetAttributeNode(nsattrib);
                }
            }
        }
    }
}
