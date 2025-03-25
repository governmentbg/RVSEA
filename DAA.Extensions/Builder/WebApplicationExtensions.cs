using Hangfire.Dashboard;
using Hangfire;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Localization;
using Serilog;
using DAA.Extensions.AutoTasks;
using DAA.Shared.Hubs;
using Microsoft.Extensions.Hosting;

namespace DAA.Extensions.Builder
{
    public static class WebApplicationExtensions
    {
        public static WebApplication UseCors(this WebApplication app)
        {
            app.UseCors(options =>
            {
                options.AllowAnyHeader();
                options.AllowAnyMethod();
                options.AllowCredentials();
                options.WithOrigins(new string[]
                    {
                        "http://localhost:8080",
                        "http://localhost:8080/#/",
                        "http://localhost:8081",
                        "http://localhost:8081/#"
                    });
            });

            return app;
        }

        public static WebApplication UseDefaultEndpoints(this WebApplication app)
        {
            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute(
                    name: "default",
                    pattern: "{controller=Home}/{action=Index}/{id?}");
                endpoints.MapFallbackToController("Index", "Home");
            });

            return app;
        }

        public static WebApplication UseLocalization(this WebApplication app)
        {
            var supportedCultures = new string[] { "bg", "en" };
            app.UseRequestLocalization(options =>
                options
                    .AddSupportedCultures(supportedCultures)
                    .AddSupportedUICultures(supportedCultures)
                    .SetDefaultCulture("bg")
                    .RequestCultureProviders.Insert(0, new CustomRequestCultureProvider(context =>
                    {
                        string userLangs = context.Request.Headers["Accept-Language"].ToString();
                        string firstLang = userLangs.Split(',').FirstOrDefault()!;
                        string defaultLang = string.IsNullOrEmpty(firstLang) ? "bg" : firstLang;
                        return Task.FromResult(new ProviderCultureResult(defaultLang, defaultLang));
                    }))
            );

            return app;
        }

        public static WebApplication UseRequestLogging(this WebApplication app)
        {
            app.UseSerilogRequestLogging();

            return app;
        }

        public static WebApplication UseHangfireDashboard(this WebApplication app)
        {
            app.UseHangfireDashboard("/hangfire", new DashboardOptions
            {
                Authorization = new IDashboardAuthorizationFilter[]
                  {
                    new HangfireAuthorizationFilter()
                  }
            });

            return app;
        }

        public static WebApplication UseNotificationsHub(this WebApplication app)
        {
            app.UseEndpoints(endpoints =>
            {
                endpoints.MapHub<NotificationsHub>("/notificationsHub");
            });

            return app;
        }

        public static WebApplication AddSecurityHeaders(this WebApplication app)
        {
            bool isProduction = !app.Environment.IsDevelopment();

            app.Use(async (context, next) =>
            {
                if (isProduction)
                {
                    context.Response.Headers.Add("Referrer-Policy", "same-origin");
                }
                context.Response.Headers.Add("X-Xss-Protection", "1; mode=block");
                context.Response.Headers.Add("X-Frame-Options", "DENY");
                context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
                context.Response.Headers.Add("Permissions-Policy", "accelerometer=(), camera=(), geolocation=(), gyroscope=(), magnetometer=(), microphone=(), payment=(), usb=()");
                // Strict policy below
                // context.Response.Headers.Add("Content-Security-Policy", "script-src 'self';style-src 'self' 'unsafe-inline';img-src 'self';font-src 'self';form-action 'self';frame-ancestors 'self';block-all-mixed-content; report-uri /api/error/cspreport");
                // Very permissive policy
                context.Response.Headers.Add("Content-Security-Policy", "default-src *  data: blob: filesystem: about: ws: wss: 'unsafe-inline' 'unsafe-eval' 'unsafe-dynamic'; script-src * 'unsafe-inline' 'unsafe-eval';  connect-src * 'unsafe-inline';   img-src * data: blob: 'unsafe-inline';                frame-src * blob:;                style-src * data: blob: 'unsafe-inline'; font-src * data: blob: 'unsafe-inline'; report-uri /api/error/cspreport");
                await next();
            });
            return app;
        }
    }
}
