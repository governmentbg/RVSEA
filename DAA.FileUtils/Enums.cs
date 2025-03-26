using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace DAA.FileUtils
{
    [JsonConverter(typeof(StringEnumConverter))]
    public enum FileType { None, Document, DocumentHtml, DocumentXml, DocumentPdf, DocumentMs, DocumentMsX, Image, Audio, Video, Other, OtherFromNom }
}
