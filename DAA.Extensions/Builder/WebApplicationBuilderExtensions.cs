using DAA.Data;
using DAA.Data.Files;
using DAA.Extensions.Authentication;
using DAA.Extensions.Data;
using DAA.Identity;
using DAA.Models.Configuration;
using DAA.Models.Identity;
using DAA.Shared.Identity;
using DAA.Shared.Localization;
using Hangfire;
using Hangfire.SqlServer;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authentication.Negotiate;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc.Razor;
using Microsoft.AspNetCore.Server.Kestrel.Https;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using Serilog;
using System.Security.Claims;
using System.Text;
using DAAIdentityErrorDescriber = DAA.Identity.IdentityErrorDescriber;

namespace DAA.Extensions.Builder
{
    public static class WebApplicationBuilderExtensions
    {
        public static WebApplicationBuilder AddOptions(this WebApplicationBuilder builder)
        {
            builder.Services.AddOptions();
            builder.Services.Configure<TokenSettings>(builder.Configuration.GetSection(TokenSettings.Name));
            builder.Services.Configure<EmailTokenSettings>(builder.Configuration.GetSection(EmailTokenSettings.Name));
            builder.Services.Configure<EmailSettings>(builder.Configuration.GetSection(EmailSettings.Name));
            builder.Services.Configure<LinkedServerSettings>(builder.Configuration.GetSection(LinkedServerSettings.Name));
            builder.Services.Configure<BusinessSettings>(builder.Configuration.GetSection(BusinessSettings.Name));
            builder.Services.Configure<ApplicationSettings>(builder.Configuration.GetSection(ApplicationSettings.Name));
            builder.Services.Configure<HangFireJobSettings>(builder.Configuration.GetSection(HangFireJobSettings.Name));
            builder.Services.Configure<FileStreamSettings>(builder.Configuration.GetSection(FileStreamSettings.Name));
            builder.Services.Configure<EAuthSettings>(builder.Configuration.GetSection(EAuthSettings.Name));
            builder.Services.Configure<ExternalSourceSettings>(builder.Configuration.GetSection(ExternalSourceSettings.Name));
            builder.Services.Configure<IsdaEServicesLink>(builder.Configuration.GetSection(IsdaEServicesLink.Name));
            builder.Services.Configure<IsdaOfficeRRRMail>(builder.Configuration.GetSection(IsdaOfficeRRRMail.Name));
            builder.Services.Configure<FileUploaderAppSettings>(builder.Configuration.GetSection(FileUploaderAppSettings.Name));
            builder.Services.Configure<DaaSurveysLink>(builder.Configuration.GetSection(DaaSurveysLink.Name));
            builder.Services.Configure<ImportSettings>(builder.Configuration.GetSection(ImportSettings.Name));
            builder.Services.Configure<OpenDataSettings>(builder.Configuration.GetSection(OpenDataSettings.Name));

            return builder;
        }

        public static WebApplicationBuilder AddDbContext(this Microsoft.AspNetCore.Builder.WebApplicationBuilder builder)
        {
            builder.Services.AddDbContext<ApplicationIdentityContext>(options =>
            {
                options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
            });
            builder.Services.AddDbContext<ArchivingContext>(options =>
            {
                options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
            });
            builder.Services.AddDbContext<FileContext>(options =>
            {
                options.UseSqlServer(builder.Configuration.GetConnectionString("FilesConnection"));
            });
            builder.Services.AddDbContext<AdjunctFileContext>(options =>
            {
                options.UseSqlServer(builder.Configuration.GetConnectionString("AdjunctFilesConnection"));
            });
            builder.Services.AddDbContext<BufferFileContext>(options =>
            {
                options.UseSqlServer(builder.Configuration.GetConnectionString("BufferFilesConnection"));
            });
            builder.Services.AddDbContext<MasterFileContext>(options =>
            {
                options.UseSqlServer(builder.Configuration.GetConnectionString("MasterFilesConnection"));
            });


            // this services are used in order to use transactions with 2 DB contexts
            builder.Services.AddScoped<ArchivingContextConnection>();
            builder.Services.AddScoped<ExtendedArchivingContext>();
            builder.Services.AddScoped<ExtendedFileContent>();
            builder.Services.AddScoped<ExtendedAdjunctFileContext>();
            builder.Services.AddScoped<ExtendendBufferFileContext>();
            builder.Services.AddScoped<ExtendendMasterFileContext>();
            //builder.Services.AddScoped<MasterFilesContextExtension>(); // this class is used in order to user trnasaction with 2 DB contexts
            //builder.Services.AddScoped<ArchivingContextExtension>(); // this class is used in order to user trnasaction with 2 DB contexts

            return builder;
        }

        public static WebApplicationBuilder AddIdentity(this WebApplicationBuilder builder)
        {
            builder.Services.AddScoped<IRoleValidator<ApplicationRole>, ApplicationRoleValidator>();
            builder.Services.AddTransient<IApplicationUserStore, ApplicationUserStore<ApplicationIdentityContext>>();
            builder.Services.AddTransient<IApplicationRoleStore, ApplicationRoleStore<ApplicationIdentityContext>>();

            builder.Services.AddIdentity<ApplicationUser, ApplicationRole>(options =>
            {
                options.Password.RequireNonAlphanumeric = false;
                options.Password.RequireDigit = false;
                options.Password.RequireUppercase = false;
                //This settings shortens reset password token
                options.Tokens.PasswordResetTokenProvider = TokenOptions.DefaultEmailProvider;
                options.Tokens.EmailConfirmationTokenProvider = TokenOptions.DefaultEmailProvider;

                // User settings.
                options.User.AllowedUserNameCharacters =
                    "абвгдежзийклмнопрстуфхцчшщъьюяАБЖГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЬЮЯabcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._@\\ ";
                options.User.RequireUniqueEmail = true;
            })
                .AddEntityFrameworkStores<ApplicationIdentityContext>()
                // using the next line resulted in email confirmation links being valid only for 5 minutes
                //.AddDefaultTokenProviders()
                // using the next line generates tokens with a little longer validity
                // but it needs to be combined with explicitly setting the TokenLifespan (see below)
                // neither of the two works if applied separately
                .AddTokenProvider<DataProtectorTokenProvider<ApplicationUser>>(TokenOptions.DefaultEmailProvider)
                .AddEntityFrameworkStores<ApplicationIdentityContext>()   
                .AddErrorDescriber<DAAIdentityErrorDescriber>()
                .AddUserManager<ApplicationUserManager>()
                .AddRoleManager<ApplicationRoleManager>();

            // explicitly set the TokenLifespan 
            int expirationHours = builder.Configuration.GetSection(EmailTokenSettings.Name).GetValue("ExpirationHours", 24);
            builder.Services.Configure<DataProtectionTokenProviderOptions>(options =>
                options.TokenLifespan = TimeSpan.FromHours(expirationHours)
            );

            return builder;
        }

        public static WebApplicationBuilder AddBearerAuthentication(this WebApplicationBuilder builder)
        {
            var tokenSettings = builder.Configuration.GetSection(TokenSettings.Name).Get<TokenSettings>();

            builder.Services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            })
                .AddJwtBearer(options =>
                {
                    options.SaveToken = true;
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuerSigningKey = true,
                        ValidateIssuer = true,
                        ValidateAudience = true,
                        ValidAudience = tokenSettings.Audience,
                        ValidIssuer = tokenSettings.Issuer,
                        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(tokenSettings.Secret!))
                    };
                    options.Events = new JwtBearerEvents
                    {
                        OnMessageReceived = context =>
                        {
                            var accessToken = context.Request.Query["access_token"];

                            // If the request is for our hub...
                            var path = context.HttpContext.Request.Path;
                            if (!string.IsNullOrEmpty(accessToken) && (path.StartsWithSegments("/notificationsHub")))
                            {
                                // Read the token out of the query string
                                context.Token = accessToken;
                            }
                            return System.Threading.Tasks.Task.CompletedTask;
                        }
                    };
                });

            return builder;
        }

        public static WebApplicationBuilder AddNegotiateAuthentication(this WebApplicationBuilder builder)
        {
            var tokenSettings = builder.Configuration.GetSection(TokenSettings.Name).Get<TokenSettings>();

            builder.Services.AddScoped<IClaimsTransformation, ClaimsTransformationService>();
            builder.Services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = NegotiateDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            })
                .AddNegotiate()
                .AddJwtBearer(options =>
                {
                    options.SaveToken = true;
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuerSigningKey = true,
                        ValidateIssuer = true,
                        ValidateAudience = true,
                        ValidAudience = tokenSettings.Audience,
                        ValidIssuer = tokenSettings.Issuer,
                        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(tokenSettings.Secret!))
                    };
                    options.Events = new JwtBearerEvents
                    {
                        OnMessageReceived = context =>
                        {
                            var accessToken = context.Request.Query["access_token"];

                            // If the request is for our hub...
                            var path = context.HttpContext.Request.Path;
                            if (!string.IsNullOrEmpty(accessToken) && (path.StartsWithSegments("/notificationsHub")))
                            {
                                // Read the token out of the query string
                                context.Token = accessToken;
                            }
                            return System.Threading.Tasks.Task.CompletedTask;
                        }
                    };
                });

            return builder;
        }

        public static WebApplicationBuilder AddCertificateAuthentication(this WebApplicationBuilder builder)
        {
            builder.Services.Configure<HttpsConnectionAdapterOptions>(options =>
            {
                options.ClientCertificateMode = ClientCertificateMode.RequireCertificate;
                options.CheckCertificateRevocation = false;
                options.ClientCertificateValidation = (certificate2, chain, policyErrors) =>
                {
                    // accept any cert (testing purposes only)
                    return true;
                };
            });
            return builder;
        }

        public static WebApplicationBuilder AddSwagger(this WebApplicationBuilder builder)
        {
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            return builder;
        }

        public static WebApplicationBuilder AddLocalization(this WebApplicationBuilder builder)
        {
            builder.Services.AddControllersWithViews().AddNewtonsoftJson();

            builder.Services
                .AddMvc()
                .AddViewLocalization(LanguageViewLocationExpanderFormat.Suffix)
                .AddDataAnnotationsLocalization(options =>
                {
                    options.DataAnnotationLocalizerProvider = (type, factory) =>
                        factory.Create(typeof(SharedResources));
                });

            builder.Services.Configure<RequestLocalizationOptions>(options => { });

            return builder;
        }

        public static WebApplicationBuilder AddUserInfo(this WebApplicationBuilder builder)
        {
            builder.Services.AddScoped<IUserInfo>(provider =>
            {
                IHttpContextAccessor context = provider.GetService<IHttpContextAccessor>()!;
                ClaimsPrincipal httpContextUser = context.HttpContext?.User!;
                //var clientIp = context.HttpContext?.Connection.RemoteIpAddress?.ToString();
                return new UserInfo(httpContextUser!);
            });

            return builder;
        }

        public static WebApplicationBuilder AddLogging(this WebApplicationBuilder builder)
        {
            var logger = new LoggerConfiguration()
                .ReadFrom.Configuration(builder.Configuration)
                .Enrich.FromLogContext()
                .MinimumLevel.Debug()
                .CreateLogger();
            
            //builder.Logging.ClearProviders();
            //builder.Logging.AddSerilog(logger);
            builder.Host.UseSerilog(logger);
            return builder;
        }

        public static WebApplicationBuilder AddHangFire(this WebApplicationBuilder builder)
        {
            // Add Hangfire services.
            builder.Services.AddHangfire(configuration => configuration
                .SetDataCompatibilityLevel(CompatibilityLevel.Version_170)
                .UseSimpleAssemblyNameTypeSerializer()
                .UseRecommendedSerializerSettings()
                .UseSqlServerStorage(builder.Configuration.GetConnectionString("DefaultConnection"), new SqlServerStorageOptions
                {
                    CommandBatchMaxTimeout = TimeSpan.FromMinutes(5),
                    SlidingInvisibilityTimeout = TimeSpan.FromMinutes(5),
                    QueuePollInterval = TimeSpan.Zero,
                    UseRecommendedIsolationLevel = true,
                    DisableGlobalLocks = true,
                    PrepareSchemaIfNecessary = true,
                }));

            // Add the processing server as IHostedService
            builder.Services.AddHangfireServer();

            return builder;
        }

    }
}
