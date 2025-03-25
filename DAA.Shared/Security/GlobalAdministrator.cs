using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Shared.Security
{
    public static class GlobalAdministrator
    {
        private static readonly string _displayName = "Global Administrator";
        private static readonly string _userName = "globaladmin@system.local";
        private static readonly string _password = "OIJ347%8urlfij";
        private static readonly string _email = "eatanasova@kontrax.bg";
        private static readonly string _salt = "66171F652E4946358B1982295EE2B034";
        private static readonly Guid _id = new Guid("11111111-1111-1111-1111-111111111111");

        public static string DisplayName { get; } = _displayName;
        public static string Username { get; } = _userName;
        public static string Email { get; } = _email;
        public static string PasswordHash { get; } = GetHashString(_password);
        public static Guid Id { get; } = _id;

        private static byte[] GetHash(string inputString)
        {
            string inputStringWithSalt = $"{inputString}{_salt}";
            using (HashAlgorithm algorithm = SHA256.Create())
                return algorithm.ComputeHash(Encoding.UTF8.GetBytes(inputString));
        }
        private static string GetHashString(string inputString)
        {
            return Convert.ToBase64String(GetHash(_password));
        }

        public static bool CheckUsername(string username)
        {
            return _userName.Equals(username, StringComparison.InvariantCulture);
        }
        public static bool CheckPassword(string password)
        {
            return GetHash(password).SequenceEqual(GetHash(_password));
        }
    }
}
