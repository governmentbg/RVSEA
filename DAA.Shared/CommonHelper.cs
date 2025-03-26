namespace DAA.Shared
{
    public static class CommonHelper
    {
        public static string GetShortTitle(string? title, int maxLength)
        {
            if (string.IsNullOrEmpty(title))
            {
                return string.Empty;
            }

            return title.Substring(0, Math.Min(maxLength, title.Length));
        }

        public static string GenerateCompositeName(string? number = "", string? title = "")
        {
            var delimeter = string.IsNullOrEmpty(title) ? string.Empty : "/";

            return $"{number} {delimeter} {GetShortTitle(title, 100)}";
        }

        public static string GetApproximateDateString(
            int? startDateDay, int? startDateMonth, int startDateYear,
            int? endDateDay, int? endDateMonth, int endDateYear)
        {
            string dateStr = String.Empty;
            
            List<string> startData = new List<string>()
            {
                (startDateDay != null && startDateDay.HasValue) ? startDateDay.Value.ToString() : String.Empty,
                (startDateMonth != null && startDateMonth.HasValue) ? StringifyMonth(startDateMonth.Value): String.Empty,
                startDateYear.ToString()
            };
            string startDateStr = String.Join(" ", startData.Where(x => x != null && x != String.Empty));


            List<string> endData = new List<string>()
            {
                (endDateDay != null && endDateDay.HasValue) ? endDateDay.Value.ToString() : String.Empty,
                (endDateMonth != null && endDateMonth.HasValue) ? StringifyMonth(endDateMonth.Value): String.Empty,
                endDateYear.ToString()
            };
            string endDateStr = String.Join(" ", endData.Where(x => x != null && x != String.Empty));

            if(!String.IsNullOrEmpty(startDateStr) && !String.IsNullOrEmpty(endDateStr))
            {
                dateStr = $"{startDateStr} - {endDateStr}";
            }
            else
            {
                dateStr = !String.IsNullOrEmpty(startDateStr) ? startDateStr : endDateStr;
            }

            return dateStr;
        }

        public static string StringifyMonth(int? month)
        {
            if (!month.HasValue)
            {
                return "";
            }

            switch (month)
            {
                case 1:
                    return "ян.";
                case 2:
                    return "февр.";
                case 3:
                    return "март";
                case 4:
                    return "апр.";
                case 5:
                    return "май";
                case 6:
                    return "юни";
                case 7:
                    return "юли";
                case 8:
                    return "авг.";
                case 9:
                    return "септ.";
                case 10:
                    return "окт.";
                case 11:
                    return "ноем.";
                case 12:
                    return "дек.";
                default:
                    return "";
            }
        }

        public static int? NullableTryParseInt32(string text)
        {
            int value;
            return int.TryParse(text, out value) ? (int?)value : null;
        }
    }
}
