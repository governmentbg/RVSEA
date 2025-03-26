
namespace DAA.Extensions.Recapitulation
{
    public class NumberInWordsExtension
    {
        private static readonly Dictionary<string, string> resources = new()
        {
            { "oneF", "една" },
            { "oneM", "един" },
            { "minus", "минус" },
            { "zero", "нула" },
            { "twoM", "двe" },
            { "twoF", "две" },
            { "three", "три" },
            { "four", "четири" },
            { "five", "пет" },
            { "six", "шест" },
            { "seven", "седем" },
            { "eight", "осем" },
            { "nine", "девет" },
            { "ten", "десет" },
            { "eleven", "единадесет" },
            { "teen", "надесет" },
            { "hundred", "сто" },
            { "hundreds1", "ста" },
            { "hundreds2", "стотин" },
            { "thousand", "хиляда" },
            { "thousands", "хиляди" },
            { "million", "един милион" },
            { "millions", "милиона" },
            { "milliard", "милиард" },
            { "milliards", "милиарда" },
            { "and", "и" },
        };

        private static readonly string[] primaryDigitInWords = new string[]
        {
            "нула",
            "един",
            "два",
            "три",
            "четири",
            "пет",
            "шест",
            "седем",
            "осем",
            "девет",
            "десет"
        };

        public static string GetBGResource(string key)
        {
            return resources[key];
        }

        public static string BGCurrencyToBGText(double cValue)
        {
            long tmpLV = (long)Math.Floor(Math.Abs(cValue));
            long tmpST = (long)Math.Round(cValue * 100) % 100;
            string theNumberSign = (cValue < 0) ? GetBGResource("minus") + " " : ""; // /*"минус "*/ 
            return theNumberSign
                    + NumberInWords(tmpLV, true);
                   
        }

        public static string NumberInWordsToEleven(long num, bool grammarGenderM)
        {
            if (num <= 0)
            {
                return GetBGResource("zero");//"нула"
            }
            else if (num == 1)
            {
                if (grammarGenderM)
                {
                    return GetBGResource("oneM");//"един";
                }
                else
                {
                    return GetBGResource("oneF");//"една";
                }
            }
            else if (num == 2)
            {
                if (grammarGenderM)
                {
                    return GetBGResource("twoM");//"два";
                }
                else
                {
                    return GetBGResource("twoF");//"две";
                }
            }
            else if (num == 3)
            {
                return GetBGResource("three");//"три";
            }
            else if (num == 4)
            {
                return GetBGResource("four");//"четири";
            }
            else if (num == 5)
            {
                return GetBGResource("five");//"пет";
            }
            else if (num == 6)
            {
                return GetBGResource("six");//"шест";
            }
            else if (num == 7)
            {
                return GetBGResource("seven");//"седем";
            }
            else if (num == 8)
            {
                return GetBGResource("eight");//"осем";
            }
            else if (num == 9)
            {
                return GetBGResource("nine");//"девет";
            }
            else if (num == 10)
            {
                return GetBGResource("ten");//"десет";
            }
            else if (num == 11)
            {
                return GetBGResource("eleven");//"единадесет";
            }
            else
            {
                return "";
            }
        }

        public static string NumberInWordsThousands(long num, bool grammarGenderM)
        {
            if (num == 1000)
            {
                return GetBGResource("thousand");//"хиляда";
            }
            else if ((num < 1000000) && (num % 1000 == 0))
            {
                return NumberInWords(num / 1000, false) + " " + GetBGResource("thousands"); //" хиляди";
            }
            else if (num < 1000000 && ((num % 100 == 0) || (num % 1000 < 21) || ((num % 1000 < 99) && (num % 10 == 0))))
            {
                return NumberInWords(num / 1000 * 1000, false) + " " + GetBGResource("and") + " " + NumberInWords(num % 1000, grammarGenderM);
            }
            else if (num < 1000000)
            {
                return NumberInWords(num / 1000 * 1000, false) + " " + NumberInWords(num % 1000, grammarGenderM);
            }
            else if (num == 1000000)
            {
                return GetBGResource("million");//"един милион";
            }
            else if (num < 1000000000 && num % 1000000 == 0)
            {
                return NumberInWords(num / 1000000, true) + " " + GetBGResource("millions");//" милионa";
            }
            else if (num < 1000000000)
            {
                string thousandsToWords = NumberInWords(num % 1000000, grammarGenderM);
                return NumberInWords(num / 1000000 * 1000000, true)
                        + ((thousandsToWords.IndexOf(" " + GetBGResource("and") + " ", StringComparison.InvariantCulture) < 0) ? " " + GetBGResource("and") + " " : " ")
                        + thousandsToWords;
            }

            else if (num == 1000000000)
            {
                return GetBGResource("milliard");//"милиард"; 
            }
            else if (num < long.MaxValue && num % 1000000000 == 0)
            {
                return NumberInWords(num / 1000000000, true) + " " + GetBGResource("milliards");//" милиарда";
            }
            else if (num < long.MaxValue)
            {
                string millionsToWords = NumberInWords(num % 1000000000, true);
                return NumberInWords(num / 1000000000 * 1000000000, grammarGenderM)
                        + ((millionsToWords.IndexOf(" " + GetBGResource("and") + " ", StringComparison.InvariantCulture) < 0) ? " " + GetBGResource("and") + " " : " ")
                        + millionsToWords;
            }
            else
            {
                return "";
            }
        }

        /***************************************************************************************/
        /*** num - integer number                                                            ***/
        /*** grammarGenderM - denotes wether the gender of the counted objects is masculine  ***/
        /***************************************************************************************/
        public static string NumberInWords(long num, bool grammarGenderM)
        {
            if (num <= 11)
            {
                return NumberInWordsToEleven(num, grammarGenderM);
            }
            else if (num / 10 == 1)
            {
                return NumberInWords(num % 10, true) + GetBGResource("teen");//"надесет";
            }
            else if ((num % 10 == 0) && (num < 100))
            {
                return NumberInWords(num / 10, true) + GetBGResource("ten");//"десет";
            }
            else if (num < 100)
            {
                return NumberInWords(num - (num % 10), grammarGenderM) + /*" и "*/ " "
                                        + GetBGResource("and") + " " + NumberInWords(num % 10, grammarGenderM);
            }
            else if (num == 100)
            {
                return GetBGResource("hundred");//"сто";
            }
            else if (num is 200 or 300)
            {
                return NumberInWords(num / 100, false) + GetBGResource("hundreds1");//"ста";
            }
            else if ((num % 100 == 0) && (num < 1000))
            {
                return NumberInWords(num / 100, false) + GetBGResource("hundreds2");//"стотин";
            }
            else
            {
                return (num < 1000) && ((num % 10 == 0) || (num % 100 / 10 < 2))
                    ? NumberInWords(num - (num % 100), grammarGenderM) + /*" и "*/ " "
                                + GetBGResource("and") + " " + NumberInWords(num % 100, grammarGenderM)
                    : num < 1000
                                    ? NumberInWords(num - (num % 100), grammarGenderM) + " " + NumberInWords(num % 100, grammarGenderM)
                                    : num >= 1000 ? NumberInWordsThousands(num, grammarGenderM) : "";
            }
        }


        public static string FormatSmallInteger(short n)
        {
            if (n is >= 0 and <= 10)
            {
                return primaryDigitInWords[n];
            }
            else if (n <= 19)
            {
                return n == 11 ? "единадесет" : $"{primaryDigitInWords[n - 10]}надесет";
            }
            else if (n <= 99)
            {
                int firstDigit = n % 10;
                int secondDigit = (n - firstDigit) / 10;

                return $"{primaryDigitInWords[secondDigit]}десет{(firstDigit > 0 ? " и " + primaryDigitInWords[firstDigit] : string.Empty)}";
            }
            else if (n <= 999)
            {
                return FormatHundreds(n);
            }

            return string.Empty;
        }

        private static string FormatHundreds(short n)
        {
            int firstDigit = n % 10;
            int secondDigit = (n - firstDigit) / 10 % 10;
            int thirdDigit = (n - firstDigit - (secondDigit * 10)) / 100;

            string prefix =
                thirdDigit == 1 ? "сто" :
                thirdDigit == 2 ? "двеста" :
                thirdDigit == 3 ? "триста" :
                $"{primaryDigitInWords[n]}стотин";

            string result = prefix;
            if (firstDigit > 0 || secondDigit > 0)
            {
                if (secondDigit == 1 && firstDigit == 0)
                {
                    result += " и десет";
                }
                else if (secondDigit == 1 && firstDigit == 1)
                {
                    result += " и единадесет";
                }
                else if (secondDigit == 1 && firstDigit > 1)
                {
                    result += $" и {primaryDigitInWords[firstDigit]}надесет";
                }
                else if (firstDigit == 0)
                {
                    result += $" и {primaryDigitInWords[secondDigit]}десет";
                }
                else if (secondDigit == 0)
                {
                    return $" и {primaryDigitInWords[firstDigit]}";
                }
                else
                {
                    result += $" {primaryDigitInWords[secondDigit]}десет и {primaryDigitInWords[firstDigit]}";
                }
            }
            return result;
        }
    }
}

