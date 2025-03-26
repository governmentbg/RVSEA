using DAA.Extensions.Builder;
using DAA.Services.Admin;
using DAA.Services.AutoTasks;
using DAA.Services.Roles;

public static class WebApplicationExtensions
{
    public static WebApplication SetupMiddleware(this WebApplication app)
    {
        //Configure the HTTP request pipeline.
        if (app.Environment.IsDevelopment())
        {
            app.UseDeveloperExceptionPage();
            app.UseSwagger();
            app.UseSwaggerUI();
            app.UseCors();
        }
        else
        {
            // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
            app.UseHsts();
        }

        app.UseRequestLogging();

        app.UseLocalization();
        app.UseHangfireDashboard();
                
        app.UseHttpsRedirection();
        app.UseRouting();
        app.UseAuthentication();
        app.UseAuthorization();
        app.UseDefaultEndpoints();
        app.UseStaticFiles();

        app.AddSecurityHeaders();

        HangfireJobScheduler.ScheduleRecurringJobs(app.Services);

        app.UseNotificationsHub();

        return app;
    }

    internal static WebApplication AddGlobalAdmin(this WebApplication app)
    {
        using (var scope = app.Services.CreateScope())
        {
            var adminService = scope.ServiceProvider.GetService<IGlobalAdministratorService>();
            var result = adminService?.CreateAdmin();
            result?.Wait();
        }

        return app;
    }

    internal static WebApplication AddGlobalRoles(this WebApplication app)
    {
        using (var scope = app.Services.CreateScope())
        {
            var roleService = scope.ServiceProvider.GetService<IRoleService>();
            var result = roleService?.CreateGlobalRolesAsync();
            result?.Wait();
        }

        return app;
    }

    internal static WebApplication AddAnonymousSystemUser(this WebApplication app)
    {
        using (var scope = app.Services.CreateScope())
        {
            var adminService = scope.ServiceProvider.GetService<IGlobalAdministratorService>();
            var result = adminService?.CreateAnonymousUser();
            result?.Wait();
        }

        return app;
    }
}
