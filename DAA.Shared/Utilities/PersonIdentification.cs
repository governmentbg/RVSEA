using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace DAA.Shared.Utilities
{
    public static class PersonIdentification
    {
        public static bool CheckEgn(string egn)
        {
            //TODO Checksum is not enough for egn check
            if (!String.IsNullOrWhiteSpace(egn) && (egn.Equals("7777777777") ||
                                                    egn.Equals("1909090909")))
                return true;

            Regex regex = new Regex(@"^\d{10}$");
            if (!regex.Match(egn).Success)
                return false;

            int sum = 0;
            byte[] checkDigits = { 2, 4, 8, 5, 10, 9, 7, 3, 6 };
            byte[] egnDigits = Encoding.ASCII.GetBytes(egn);
            for (int k = 0; k < 9; k++)
            {
                sum += (int)(checkDigits[k] * (egnDigits[k] - 48));
            }
            byte checkDigit = (byte)((sum % 11) % 10);
            return (checkDigit == (egnDigits[9] - 48));
        }

        public static bool CheckLNCH(string lnch)
        {
            byte[] checkDigits = { 21, 19, 17, 13, 11, 9, 7, 3, 1 };
            Regex regex = new Regex(@"^\d{10}$");
            if (!regex.Match(lnch).Success)
                return false;

            int sum = 0;

            byte[] egnDigits = Encoding.ASCII.GetBytes(lnch);
            for (int k = 0; k < 9; k++)
            {
                sum += (int)(checkDigits[k] * (egnDigits[k] - 48));
            }
            byte checkDigit = (byte)(sum % 10);
            return (checkDigit == (egnDigits[9] - 48));
        }

        public static bool IsEIKValid(string eik)
        {
            if (String.IsNullOrWhiteSpace(eik))
                return false;

            if (eik.Length == 9)
            {
                return IsEIK9Valid(eik);
            }
            else if (eik.Length == 13)
            {
                return IsEIK13Valid(eik);
            }

            return false;
        }

        private static bool IsEIK9Valid(string eik)
        {
            Regex regex = new Regex(@"^\d{9}$");
            if (!regex.Match(eik).Success)
                return false;

            // Определя се контролното число за деветцифровия Единен идентификационен код 
            int ninthDigit = GetEIKNinthControlDigit(eik);

            // ако съвпада с деветата цифра, значи ЕИК е верен
            int[] eikDigits = eik.Select(n => n - '0').ToArray();
            return ninthDigit == eikDigits[8];
        }

        private static bool IsEIK13Valid(string eik)
        {
            Regex regex = new Regex(@"^\d{13}$");
            if (!regex.Match(eik).Success)
                return false;

            // Тринадесетзначният Единен идентификационен код се присвоява на клоновете и поделенията.
            // Определя се контролното число за тринадесетцифровия Единен идентификационен код 
            int thirteenthDigit = GetEIKThirteenthControlDigit(eik);

            // ако съвпада с тринадесетата цифра, значи ЕИК е верен
            int[] eikDigits = eik.Select(n => n - '0').ToArray();
            return thirteenthDigit == eikDigits[12];
        }

        private static int GetEIKNinthControlDigit(string eik)
        {
            if (String.IsNullOrWhiteSpace(eik) || eik.Length < 9)
                return -1;

            // Контролното число за деветцифровия Единен идентификационен код се изчислява по
            // следния начин:
            // - изчислява се сумата: 1*а1+2*а2+3*а3+4*а4+5*а5+6*а6+7*а7+8*а8
            // където а1 e първата цифра от ЕИК, а2 - втората и т.н.

            int sum = 0;
            int[] eikDigits = eik.Select(n => n - '0').ToArray();
            for (int k = 0; k < 8; k++)
            {
                sum += ((k + 1) * eikDigits[k]);
            }

            // - изчислява се остатъкът по модул 11 от сумата
            int checkDigit = sum % 11;

            // - ако остатъкът е различен от 10, се определя като девета цифра
            if (checkDigit != 10)
                return checkDigit;

            // - ако остатъкът е 10, се изчислява сумата 3*а1+4*а2+5*а3+6*а4+7*а5+8*а6+9*а7+10*а8
            sum = 0;
            for (int k = 0; k < 8; k++)
            {
                sum += (int)((k + 3) * eikDigits[k]);
            }

            // - изчислява се остатъкът по модул 11 от новата сума
            checkDigit = sum % 11;

            // - ако остатъкът е различен от 10, се определя като девета цифра, 
            // а ако е десет - за девета цифра се определя “0” 
            return (checkDigit != 10) ? checkDigit : 0;
        }

        private static int GetEIKThirteenthControlDigit(string eik)
        {
            if (String.IsNullOrWhiteSpace(eik) || eik.Length < 13)
                return -1;

            // - изчислява се деветата цифра по начина, описан за деветцифровия ЕИК
            int ninthDigit = GetEIKNinthControlDigit(eik);
            int[] eikDigits = eik.Select(n => n - '0').ToArray();
            if (ninthDigit != eikDigits[8])
                return -1;

            // изчислява се сумата 2*а9 + 7*а10 + 3*а11 +5*а12
            // където а9 e деветата цифра от ЕИК, а10 - десетата и т.н.
            int sum = 2 * eikDigits[8] + 7 * eikDigits[9] + 3 * eikDigits[10] + 5 * eikDigits[11];

            // - изчислява се остатъкът по модул 11 от сумата
            int checkDigit = sum % 11;

            // - ако остатъкът е различен от 10, се определя като тринадесета цифра
            if (checkDigit != 10)
                return checkDigit;

            // - ако остатъкът е 10, се изчислява сумата 4*а9+9*а10+5*а11+7*а12
            sum = 4 * eikDigits[8] + 9 * eikDigits[9] + 5 * eikDigits[10] + 7 * eikDigits[11];

            // - изчислява се остатъкът по модул 11 от новата сума
            checkDigit = sum % 11;

            // ако остатъкът е различен от 10, се определя като тринадесета цифра, 
            // а ако е десет - за тринадесета цифра се определя “0”
            return (checkDigit != 10) ? checkDigit : 0;
        }
    }
}
