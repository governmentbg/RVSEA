using DAA.Models.FileUploadApp;
using System.CodeDom;
using System.Security.Cryptography;

namespace DAA.FileUtils
{
    public static class ChecksumUtil
    {

        public static async Task<string> Calculate(string fileName)
        {
            using var stream = File.OpenRead(fileName);
            return await Calculate(stream);
        }
        public static async Task<string> Calculate(Stream stream)
        {
            using (var md5 = MD5.Create())
            {
                byte[] hash = await md5.ComputeHashAsync(stream);
                return HashBytesToString(hash);
            }
        }
        public static string Calculate(byte[] bytes)
        {
            using (var md5 = MD5.Create())
            {
                byte[] hash = md5.ComputeHash(bytes);
                return HashBytesToString(hash);
            }
        }
        public static async Task<OperationResultModel> Verify1(string fileName, string checksum)
        {
            try
            {
                OperationResultModel result = new OperationResultModel();
                result.Success = await Calculate(fileName) == checksum;
                result.Message = $"Проверка на контролна сума: {(result.Success ? "Ок" : "Контролната сума на файла не отговаря на записаната!")}";
                return result;
            }
            catch (Exception e)
            {
                throw new Exception("Грешка при проверка на контролна сума: " + e.Message);
            }
        }
        public static async Task VerifyRequire(string fileName, string checksum)
        {
            OperationResultModel result = await Verify1(fileName, checksum);
            if (!result.Success) 
            { 
                throw new Exception(result.Message);
            }
        }

        private static string HashBytesToString(byte[] bytes)
        {
            return BitConverter.ToString(bytes).Replace("-", "").ToLowerInvariant();
        }
    }
}
