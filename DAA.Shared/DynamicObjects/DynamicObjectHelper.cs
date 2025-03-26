using DAA.Shared.Attributes;
using DAA.Shared.Localization;
using Microsoft.Extensions.Localization;
using Newtonsoft.Json.Linq;
using System.Dynamic;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Text;

namespace DAA.Shared.DynamicObjects
{
    public static class DynamicObjectHelper
    {
        public static List<dynamic> GetGridDataForExport<T>(
            IEnumerable<T>? gridColumns,
            IEnumerable<object>? gridData,
            IStringLocalizer<SharedResources> localizer,
            bool useColumnTitleAsKey)
        {
            var records = new List<dynamic>();
            var headers = PrepareHeadersForExport(gridColumns);
            if (headers == null || headers.Count == 0 || gridData == null || !gridData.Any())
            {
                return records;
            }

            foreach (object rowItem in gridData)
            {
                dynamic row = new ExpandoObject();
                var dictionary = row as IDictionary<string, object>;

                foreach (dynamic columnItem in headers)
                {
                    string dictionaryKey = columnItem.dataMetaPropertyValue;
                    if (useColumnTitleAsKey)
                    {
                        dictionaryKey = columnItem.headerValue;
                        if (dictionary?.ContainsKey(dictionaryKey) == true)
                        {
                            continue;
                        }
                    }

                    string dataPropertyValue = String.Empty;
                    if (rowItem is JObject)
                    {
                        JObject rowAsJson = JObject.Parse(rowItem.ToString()!);
                        JProperty? dataPropertyJson = rowAsJson.Properties().Where(x => x.Name.ToLower() == columnItem.dataMetaPropertyValue.ToLower()).FirstOrDefault();
                        dataPropertyValue = dataPropertyJson != null ? dataPropertyJson.Value.ToString() : "";
                    }
                    else
                    {
                        PropertyInfo? dataProperty = rowItem.GetType().GetProperties().Where(x => x.Name.ToLower() == columnItem.dataMetaPropertyValue.ToLower()).FirstOrDefault();
                        //dataPropertyValue = dataProperty != null ? dataProperty!.GetValue(rowItem)!.ToString()! : "";
                        dataPropertyValue = dataProperty?.GetValue(rowItem)?.ToString() ?? String.Empty;
                    }

                    if (!dictionary.ContainsKey(dictionaryKey))
                    {
                        if (dictionaryKey.ToLower() == "bytes")
                        {
                            dataPropertyValue = ConvertBytesToMegabytes(dataPropertyValue);

                            dictionary?.Add(dictionaryKey, dataPropertyValue);
                        }
                        else
                        {
                            dictionary?.Add(dictionaryKey, dataPropertyValue);
                        }
                    }

                    if (dictionary != null)
                    {
                        if (string.Equals(columnItem.typeValue, "html"))
                        {
                            dictionary[dictionaryKey] = HtmlHelper.GetHtmlInnerText(dataPropertyValue);
                        }
                        else if (string.Equals(columnItem.typeValue, "date"))
                        {
                            DateTime dateValue = DateTime.MinValue;
                            DateTime.TryParse(dataPropertyValue, out dateValue);
                            if (dateValue != DateTime.MinValue)
                            {
                                dictionary[dictionaryKey] = dateValue.ToString(Constants.DateTimeFormatStr);
                            }
                        }
                        else if (string.Equals(columnItem.typeValue, "int"))
                        {
                            long numberValue = long.MinValue;
                            if (long.TryParse(dataPropertyValue, out numberValue) && numberValue != long.MinValue)
                            {
                                dictionary[dictionaryKey] = numberValue;
                            }
                        }
                        else if (string.Equals(columnItem.typeValue, "number"))
                        {
                            decimal numberValue = decimal.MinValue;
                            if (decimal.TryParse(dataPropertyValue, NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out numberValue) && numberValue != decimal.MinValue)
                            {
                                dictionary[dictionaryKey] = numberValue;
                            }
                        }
                        else if (string.Equals(columnItem.typeValue, "boolean"))
                        {
                            dictionary[dictionaryKey] =
                                string.Equals(dataPropertyValue.ToLower(), "true")
                                ? localizer.GetString("Yes").Value
                                : localizer.GetString("No").Value;
                        }
                    }
                }

                records.Add(row);
            }

            return records;

        }

        public static List<dynamic> PrepareHeadersForExport<T>(IEnumerable<T>? gridColumns)
        {
            var headers = new List<dynamic>();

            if (gridColumns == null || !gridColumns.Any())
            {
                return headers;
            }

            MemberInfo? headerInfo = ExportGridAttributeHelper.GetGridHeaderProperty<T>();
            if (headerInfo == null)
            {
                return headers;
            }

            MemberInfo? dataInfo = ExportGridAttributeHelper.GetGridDataProperty<T>();
            if (dataInfo == null)
            {
                return headers;
            }

            MemberInfo? typeInfo = ExportGridAttributeHelper.GetGridColumnTypeProperty<T>();

            foreach (T columnItem in gridColumns)
            {
                PropertyInfo? headerProperty = columnItem!.GetType().GetProperties().Where(p => p.Name == headerInfo.Name).FirstOrDefault();
                string? headerValue = headerProperty!.GetValue(columnItem)!.ToString();




                PropertyInfo? dataMetaProperty = columnItem.GetType().GetProperties().Where(p => p.Name.ToLower() == dataInfo.Name.ToLower()).FirstOrDefault();
                string? dataMetaPropertyValue = dataMetaProperty!.GetValue(columnItem)?.ToString();
                if (string.IsNullOrEmpty(dataMetaPropertyValue))
                {
                    continue;
                }

                PropertyInfo? typeProperty = columnItem.GetType().GetProperties().Where(p => p.Name == typeInfo!.Name).FirstOrDefault();
                string? typeValue = typeProperty!.GetValue(columnItem)!.ToString();


                dynamic header = new ExpandoObject();
                header.headerValue = headerValue;
                header.dataMetaPropertyValue = dataMetaPropertyValue;
                header.typeValue = typeValue;
                headers.Add(header);
            }

            return headers;

        }

        //TODO Архивите искат да се закръгля след 3 да се промени ли??
        private static string ConvertBytesToMegabytes(string bytes)
        {
            const int k = 1024;

            if (!String.IsNullOrEmpty(bytes))
            {
                var converted = decimal.Parse(bytes);
                return Math.Round((converted / k) / k, 2).ToString();
            }

            return bytes;
        }
    }
}
