using DAA.Shared.Localization;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Localization;
using System.Text;
using SystemIdentityErrorDescriber = Microsoft.AspNetCore.Identity.IdentityErrorDescriber;

namespace DAA.Identity
{
    public class IdentityErrorDescriber : SystemIdentityErrorDescriber
    {
        private readonly IStringLocalizer<SharedResources> _localizer;

        public IdentityErrorDescriber(IStringLocalizer<SharedResources> localizer = null!)
        {
            _localizer = localizer;
        }

        /// <summary>
        /// Returns the default <see cref="IdentityError"/>.
        /// </summary>
        /// <returns>The default <see cref="IdentityError"/>.</returns>
        //public virtual IdentityError DefaultError()
        //{
        //    return new IdentityError
        //    {
        //        Code = nameof(DefaultError),
        //        Description = Resources.DefaultError
        //    };
        //}

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating a concurrency failure.
        /// </summary>
        /// <returns>An <see cref="IdentityError"/> indicating a concurrency failure.</returns>
        //public virtual IdentityError ConcurrencyFailure()
        //{
        //    return new IdentityError
        //    {
        //        Code = nameof(ConcurrencyFailure),
        //        Description = Resources.ConcurrencyFailure
        //    };
        //}

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating a password mismatch.
        /// </summary>
        /// <returns>An <see cref="IdentityError"/> indicating a password mismatch.</returns>
        public override IdentityError PasswordMismatch()
        {
            return new IdentityError
            {
                Code = nameof(PasswordMismatch),
                Description = _localizer.GetString("Error_PasswordMismatch").ToString()
            };
        }

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating an invalid token.
        /// </summary>
        /// <returns>An <see cref="IdentityError"/> indicating an invalid token.</returns>
        public override IdentityError InvalidToken()
        {
            return new IdentityError
            {
                Code = nameof(InvalidToken),
                Description = _localizer.GetString("Error_InvalidToken").ToString()
            };
        }

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating a recovery code was not redeemed.
        /// </summary>
        /// <returns>An <see cref="IdentityError"/> indicating a recovery code was not redeemed.</returns>
        //public virtual IdentityError RecoveryCodeRedemptionFailed()
        //{
        //    return new IdentityError
        //    {
        //        Code = nameof(RecoveryCodeRedemptionFailed),
        //        Description = Resources.RecoveryCodeRedemptionFailed
        //    };
        //}

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating an external login is already associated with an account.
        /// </summary>
        /// <returns>An <see cref="IdentityError"/> indicating an external login is already associated with an account.</returns>
        //public virtual IdentityError LoginAlreadyAssociated()
        //{
        //    return new IdentityError
        //    {
        //        Code = nameof(LoginAlreadyAssociated),
        //        Description = Resources.LoginAlreadyAssociated
        //    };
        //}

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating the specified user <paramref name="userName"/> is invalid.
        /// </summary>
        /// <param name="userName">The user name that is invalid.</param>
        /// <returns>An <see cref="IdentityError"/> indicating the specified user <paramref name="userName"/> is invalid.</returns>
        public override IdentityError InvalidUserName(string userName)
        {
            return new IdentityError
            {
                Code = nameof(InvalidUserName),
                Description = String.Format(_localizer.GetString("Error_InvalidUserName").ToString(), userName)
            };
        }

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating the specified <paramref name="email"/> is invalid.
        /// </summary>
        /// <param name="email">The email that is invalid.</param>
        /// <returns>An <see cref="IdentityError"/> indicating the specified <paramref name="email"/> is invalid.</returns>
        //public virtual IdentityError InvalidEmail(string email)
        //{
        //    return new IdentityError
        //    {
        //        Code = nameof(InvalidEmail),
        //        Description = Resources.FormatInvalidEmail(email)
        //    };
        //}

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating the specified <paramref name="userName"/> already exists.
        /// </summary>
        /// <param name="userName">The user name that already exists.</param>
        /// <returns>An <see cref="IdentityError"/> indicating the specified <paramref name="userName"/> already exists.</returns>
        //public virtual IdentityError DuplicateUserName(string userName)
        //{
        //    return new IdentityError
        //    {
        //        Code = nameof(DuplicateUserName),
        //        Description = Resources.FormatDuplicateUserName(userName)
        //    };
        //}

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating the specified <paramref name="email"/> is already associated with an account.
        /// </summary>
        /// <param name="email">The email that is already associated with an account.</param>
        /// <returns>An <see cref="IdentityError"/> indicating the specified <paramref name="email"/> is already associated with an account.</returns>
        //public virtual IdentityError DuplicateEmail(string email)
        //{
        //    return new IdentityError
        //    {
        //        Code = nameof(DuplicateEmail),
        //        Description = Resources.FormatDuplicateEmail(email)
        //    };
        //}

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating the specified <paramref name="role"/> name is invalid.
        /// </summary>
        /// <param name="role">The invalid role.</param>
        /// <returns>An <see cref="IdentityError"/> indicating the specific role <paramref name="role"/> name is invalid.</returns>
        //public virtual IdentityError InvalidRoleName(string role)
        //{
        //    return new IdentityError
        //    {
        //        Code = nameof(InvalidRoleName),
        //        Description = Resources.FormatInvalidRoleName(role)
        //    };
        //}

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating the specified <paramref name="role"/> name already exists.
        /// </summary>
        /// <param name="role">The duplicate role.</param>
        /// <returns>An <see cref="IdentityError"/> indicating the specific role <paramref name="role"/> name already exists.</returns>
        //public virtual IdentityError DuplicateRoleName(string role)
        //{
        //    return new IdentityError
        //    {
        //        Code = nameof(DuplicateRoleName),
        //        Description = Resources.FormatDuplicateRoleName(role)
        //    };
        //}

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating a user already has a password.
        /// </summary>
        /// <returns>An <see cref="IdentityError"/> indicating a user already has a password.</returns>
        //public virtual IdentityError UserAlreadyHasPassword()
        //{
        //    return new IdentityError
        //    {
        //        Code = nameof(UserAlreadyHasPassword),
        //        Description = Resources.UserAlreadyHasPassword
        //    };
        //}

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating user lockout is not enabled.
        /// </summary>
        /// <returns>An <see cref="IdentityError"/> indicating user lockout is not enabled.</returns>
        //public virtual IdentityError UserLockoutNotEnabled()
        //{
        //    return new IdentityError
        //    {
        //        Code = nameof(UserLockoutNotEnabled),
        //        Description = Resources.UserLockoutNotEnabled
        //    };
        //}

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating a user is already in the specified <paramref name="role"/>.
        /// </summary>
        /// <param name="role">The duplicate role.</param>
        /// <returns>An <see cref="IdentityError"/> indicating a user is already in the specified <paramref name="role"/>.</returns>
        public override IdentityError UserAlreadyInRole(string role)
        {
            return new IdentityError
            {
                Code = nameof(UserAlreadyInRole),
                Description = String.Format(_localizer.GetString("Error_UserAlreadyInRole").ToString(), role)
            };
        }

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating a user is not in the specified <paramref name="role"/>.
        /// </summary>
        /// <param name="role">The duplicate role.</param>
        /// <returns>An <see cref="IdentityError"/> indicating a user is not in the specified <paramref name="role"/>.</returns>
        public override IdentityError UserNotInRole(string role)
        {
            return new IdentityError
            {
                Code = nameof(UserNotInRole),
                Description = String.Format(_localizer.GetString("Error_UserNotInRole").ToString(), role)
            };
        }

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating a password of the specified <paramref name="length"/> does not meet the minimum length requirements.
        /// </summary>
        /// <param name="length">The length that is not long enough.</param>
        /// <returns>An <see cref="IdentityError"/> indicating a password of the specified <paramref name="length"/> does not meet the minimum length requirements.</returns>
        public override IdentityError PasswordTooShort(int length)
        {
            return new IdentityError
            {
                Code = nameof(PasswordTooShort),
                Description = String.Format(_localizer.GetString("Error_PasswordTooShort").ToString(), length)
            };
        }

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating a password does not meet the minimum number <paramref name="uniqueChars"/> of unique chars.
        /// </summary>
        /// <param name="uniqueChars">The number of different chars that must be used.</param>
        /// <returns>An <see cref="IdentityError"/> indicating a password does not meet the minimum number <paramref name="uniqueChars"/> of unique chars.</returns>
        public override IdentityError PasswordRequiresUniqueChars(int uniqueChars)
        {
            return new IdentityError
            {
                Code = nameof(PasswordRequiresUniqueChars),
                Description = String.Format(_localizer.GetString("Error_PasswordRequiresUniqueChars").ToString(), uniqueChars)
            };
        }

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating a password entered does not contain a non-alphanumeric character, which is required by the password policy.
        /// </summary>
        /// <returns>An <see cref="IdentityError"/> indicating a password entered does not contain a non-alphanumeric character.</returns>
        public override IdentityError PasswordRequiresNonAlphanumeric()
        {
            return new IdentityError
            {
                Code = nameof(PasswordRequiresNonAlphanumeric),
                Description = _localizer.GetString("Error_PasswordRequiresNonAlphanumeric").ToString()
            };
        }

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating a password entered does not contain a numeric character, which is required by the password policy.
        /// </summary>
        /// <returns>An <see cref="IdentityError"/> indicating a password entered does not contain a numeric character.</returns>
        public override IdentityError PasswordRequiresDigit()
        {
            return new IdentityError
            {
                Code = nameof(PasswordRequiresDigit),
                Description = _localizer.GetString("Error_PasswordRequiresDigit").ToString()
            };
        }

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating a password entered does not contain a lower case letter, which is required by the password policy.
        /// </summary>
        /// <returns>An <see cref="IdentityError"/> indicating a password entered does not contain a lower case letter.</returns>
        public override IdentityError PasswordRequiresLower()
        {
            return new IdentityError
            {
                Code = nameof(PasswordRequiresLower),
                Description = _localizer.GetString("Error_PasswordRequiresLower").ToString()
            };
        }

        /// <summary>
        /// Returns an <see cref="IdentityError"/> indicating a password entered does not contain an upper case letter, which is required by the password policy.
        /// </summary>
        /// <returns>An <see cref="IdentityError"/> indicating a password entered does not contain an upper case letter.</returns>
        public override IdentityError PasswordRequiresUpper()
        {
            return new IdentityError
            {
                Code = nameof(PasswordRequiresUpper),
                Description = _localizer.GetString("Error_PasswordRequiresUpper").ToString()
            };
        }
    }
}
