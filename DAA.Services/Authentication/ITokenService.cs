using DAA.Models.Identity;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace DAA.Services.Authentication
{
    public interface ITokenService
    {
        JwtSecurityToken GenerateToken(ApplicationUser user, IEnumerable<string> roles);
        JwtSecurityToken GenerateToken(ClaimsPrincipal principal);
        string WriteToken(JwtSecurityToken token);
        string GenerateTokenString(ApplicationUser user, IEnumerable<string> roles);
        string GenerateTokenString(ClaimsPrincipal principal);
        string ReadToken(HttpContext context, string authorizationHeader);
        bool InvalidateToken();
        ClaimsPrincipal GetPrincipalFromToken(string token);
    }
}
