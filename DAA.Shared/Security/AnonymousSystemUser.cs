using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Shared.Security
{
    public  static class AnonymousSystemUser
    {
        private static readonly string _displayName = "Anonymous User";
        private static readonly string _userName = "anonymous@system.local";
        private static readonly string _email = "eatanasova@kontrax.bg";
        private static readonly Guid _id = new Guid("22222222-2222-2222-2222-222222222222");

        public static string DisplayName { get; } = _displayName;
        public static string Username { get; } = _userName;
        public static string Email { get; } = _email;
        public static Guid Id { get; } = _id;
    }
}
