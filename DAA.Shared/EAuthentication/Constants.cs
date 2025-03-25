using System;
using System.Collections.Generic;
using System.Linq;
namespace DAA.Shared.EAuthentication
{
    public static class Role
    {
        public const string GlobalAdmin = "GlobalAdmin";
        public const string GlobalAdminName = "Централен администратор";
    }

    public static class AccessLevel
    {
        public const string Admin = "Admin";
        public const string Manager = "Manager";
        public const string Employee = "Employee";
    }

    public static class LocalRoleName
    {
        public const string None = "(без ограничение)";
    }

    public static class Oid
    {
        public const string OidMask = @"2\.16\.100\.1(\.([0-9]+))+";
        public const string OidErrorMessage = "Моля въведете валидно OID! Пример: 2.16.100.1.1.234";
    }

    public static class ThisSystem
    {
        public const string Name = "RegUX";
        public const string Oid = "2.16.100.1.1.43.1.1";
    }

    public static class Format
    {
        public const string DateTime = "{0:dd.MM.yy HH:mm}";
    }
}
