using HtmlAgilityPack;
using System.Web;

namespace DAA.Shared
{
    public static class HtmlHelper
    {
        public static string GetHtmlInnerText(string html)
        {
            if (string.IsNullOrWhiteSpace(html))
            {
                return "";
            }
            var doc = new HtmlDocument();
            doc.LoadHtml(html);
            string innerText = GetHtmlNodeText(doc.DocumentNode);

            return innerText;
        }

        private static string GetHtmlNodeText(HtmlNode node)
        {
            if (node == null)
            {
                return "";
            }

            if (!node.ChildNodes.Any())
            {
                string decodedText = HttpUtility.HtmlDecode(node.InnerText.Trim());
                return decodedText;
            }

            string text = string.Join(
                                    " ",
                                    node.ChildNodes
                                        .Select(x => GetHtmlNodeText(x))
                                        .Where(x => !string.IsNullOrWhiteSpace(x))
                                  );
            return text;
        }
    }
}
