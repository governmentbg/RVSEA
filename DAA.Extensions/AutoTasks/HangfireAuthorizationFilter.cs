using Hangfire.Dashboard;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics.CodeAnalysis;

namespace DAA.Extensions.AutoTasks
{
    public class HangfireAuthorizationFilter : ControllerBase, IDashboardAuthorizationFilter
    {
        public bool Authorize([NotNull] DashboardContext context)
        {
            return true;
            //try
            //{
            //    var httpContext = context.GetHttpContext();
            //    var userRole = httpContext.Request.Cookies["UserRole"];
            //    return false;
            //}
            //catch
            //{
            //    return false;
            //}
        }

        //public bool Authorize(DashboardContext context)
        //{
        //    // Security на дашборда на hangfire.
        //    return context.GetHttpContext().User.Identity.IsAuthenticated;

        //    //return httpContext.User.IsInRole(Role.DevAdmin);
        //}
    }
}
