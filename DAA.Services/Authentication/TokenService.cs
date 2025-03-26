using DAA.Data;
using DAA.Models.Configuration;
using DAA.Models.Identity;
using DAA.Shared.Localization;
using Microsoft.Extensions.Localization;
using Microsoft.Extensions.Options;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using SystemClaimTypes = System.Security.Claims.ClaimTypes;
using ArchivingClaimTypes = DAA.Shared.Security.ClaimTypes;
using Microsoft.IdentityModel.Tokens;
using Microsoft.AspNetCore.Http;

namespace DAA.Services.Authentication
{
    public class TokenService : BaseService, ITokenService
    {
        private readonly TokenSettings _settings;

        public TokenService(ArchivingContext context, IStringLocalizer<SharedResources> localizer, IOptions<TokenSettings> settings)
            : base(context, localizer) 
        {
            _settings = settings.Value;
        }

        public JwtSecurityToken GenerateToken(ApplicationUser user, IEnumerable<string> roles)
        {
            var claims = new List<Claim>
            {
                new Claim(SystemClaimTypes.NameIdentifier, user.Id.ToString("D")),
                new Claim(SystemClaimTypes.Name, user.UserName),
                //new Claim(SystemClaimTypes.GivenName, user.DisplayName!),
                new Claim(SystemClaimTypes.Email, user.Email),
                new Claim(ArchivingClaimTypes.IsAdmin, user.IsAdmin.ToString()),
            };
            if (!string.IsNullOrEmpty(user.AdminType))
            {
                claims.Add(new Claim(ArchivingClaimTypes.AdminType, user.AdminType));
            }

            if (roles != null)
            {
                claims.AddRange(roles.Select(role => new Claim(SystemClaimTypes.Role, role)));
            }

            var signingKey =
                new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_settings.Secret!));

            var token = new JwtSecurityToken
            (
                issuer: _settings.Issuer,
                audience: _settings.Audience,
                claims: claims,
                expires: DateTime.Now.AddHours(_settings.ExpirationHours),
                signingCredentials: new SigningCredentials(signingKey, SecurityAlgorithms.HmacSha256)
            );

            return token;
        }

        public JwtSecurityToken GenerateToken(ClaimsPrincipal principal)
        {
            var signingKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_settings.Secret!));

            var token = new JwtSecurityToken
            (
                issuer: _settings.Issuer,
                audience: _settings.Audience,
                claims: principal.Claims,
                expires: DateTime.Now.AddHours(_settings.ExpirationHours),
                signingCredentials: new SigningCredentials(signingKey, SecurityAlgorithms.HmacSha256)
            );

            return token;
        }

        public string WriteToken(JwtSecurityToken token)
        {
            string tokenString = string.Empty;
            JwtSecurityTokenHandler handler = new JwtSecurityTokenHandler();
            tokenString = handler.WriteToken(token);
            return tokenString;
        }

        public string GenerateTokenString(ApplicationUser user, IEnumerable<string> roles)
        {
            JwtSecurityToken token = GenerateToken(user, roles);
            return WriteToken(token);
        }

        public string GenerateTokenString(ClaimsPrincipal principal)
        {
            JwtSecurityToken token = GenerateToken(principal);
            return WriteToken(token);
        }

        public string ReadToken(HttpContext context, string authorizationHeader)
        {
            var headerValues = context.Request.Headers[authorizationHeader].FirstOrDefault()?.Split(" ");

            //var authorizationType = context.Request.Headers[authorizationHeader].FirstOrDefault()?.Split(" ").First();
            //var token = context.Request.Headers[authorizationHeader].FirstOrDefault()?.Split(" ").Last();

            var authorizationType = headerValues?.First();
            var token = authorizationType == "Bearer" ? headerValues?.Last() : String.Empty;

            return token!;
        }

        public bool InvalidateToken()
        {
            throw new NotImplementedException();
        }

        public ClaimsPrincipal GetPrincipalFromToken(string token)
        {
            TokenValidationParameters tokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidAudience = _settings.Audience,
                ValidIssuer = _settings.Issuer,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_settings.Secret!)),
                ValidateLifetime = true
            };

            JwtSecurityTokenHandler tokenHandler = new JwtSecurityTokenHandler();
            SecurityToken securityToken;
            ClaimsPrincipal principal = tokenHandler.ValidateToken(token, tokenValidationParameters, out securityToken);
            JwtSecurityToken? jwtSecurityToken = securityToken as JwtSecurityToken;
            if (jwtSecurityToken == null)
            {
                throw new SecurityTokenException("Invalid token");
            }
            return principal;
        }
    }
}
