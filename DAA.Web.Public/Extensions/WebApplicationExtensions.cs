using DAA.Extensions.Builder;

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
        }
        else
        {
            // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
            app.UseHsts();
        }
        app.UseAuthentication();
        app.UseRequestLogging();

        app.UseLocalization();
        
        app.UseHttpsRedirection();
        app.UseRouting();

        app.UseCors();
        app.UseStaticFiles();

        app.UseAuthorization();

        app.AddSecurityHeaders();

        //app.MapControllers();
        //app.UseEndpoints(endpoints =>
        //{
        //    endpoints.MapControllers();
        //});
        app.UseDefaultEndpoints();

        return app;
    }
}
