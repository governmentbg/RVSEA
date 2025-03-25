var builder = WebApplication.CreateBuilder(args);
builder.RegisterServices();

var app = builder.Build();
app.SetupMiddleware();

app.AddGlobalAdmin();
app.AddGlobalRoles();
app.AddAnonymousSystemUser();

app.Run();