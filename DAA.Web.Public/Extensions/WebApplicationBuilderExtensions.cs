using DAA.Extensions.Builder;
using DAA.Services;
using DAA.Services.Admin;
using DAA.Services.Applications;
using DAA.Services.ApplicationStore;
using DAA.Services.ArchivalEntities;
using DAA.Services.Authentication;
using DAA.Services.Authorization;
using DAA.Services.DigitalObjects;
using DAA.Services.Documents;
using DAA.Services.EAuthentication;
using DAA.Services.Files;
using DAA.Services.FileUploadApp;
using DAA.Services.Films;
using DAA.Services.Funds;
using DAA.Services.Import;
using DAA.Services.Interfaces;
using DAA.Services.Inventories;
using DAA.Services.LibraryCardService;
using DAA.Services.Nomenclatures;
using DAA.Services.Notifications;
using DAA.Services.Packages;
using DAA.Services.Process;
using DAA.Services.Search;
using DAA.Services.Roles;
using DAA.Services.Settings;
using DAA.Services.Tasks;
using DAA.Services.Users;
using DocFlow.Services.Interfaces;
using DAA.Services.Numbers;
using DAA.Services.Information;

public static class WebApplicationBuilderExtensions
{
    public static WebApplicationBuilder RegisterServices(this WebApplicationBuilder builder)
    {
        builder.AddDbContext();

        builder.AddLocalization();

        builder.AddOptions();

        builder.AddIdentity();
        builder.AddBearerAuthentication();
        builder.AddCertificateAuthentication();
        builder.Services.AddAuthorization();

        builder.Services.AddHttpContextAccessor();

        builder.Services.AddControllers();

        builder.AddSwagger();

        builder.AddLogging();

        builder.InjectServices();

        return builder;
    }

    //Add service here
    private static WebApplicationBuilder InjectServices(this WebApplicationBuilder builder)
    {
        builder.AddUserInfo();
        builder.Services.AddTransient<IGlobalAdministratorService, GlobalAdministratorService>();
        builder.Services.AddTransient<IReportService, ReportService>();
        
        builder.Services.AddTransient<ITokenService, TokenService>();
        builder.Services.AddTransient<IUserProfileService, UserProfileService>();
        builder.Services.AddTransient<IEmailService, EmailService>();
        builder.Services.AddTransient<IExportService, ExportService>();
        builder.Services.AddTransient<IDropdownService, DropdownService>();
        //builder.Services.AddTransient<IDocsCollectingProcedureService, DocsCollectingProcedureService>();
        builder.Services.AddTransient<IApplicationsService, ApplicationsService>();
        
        builder.Services.AddTransient<INomenclatureService, NomenclatureService>();
        builder.Services.AddTransient<IFundPublicService, FundPublicService>();
        builder.Services.AddTransient<IInventoryPublicService, InventoryPublicService>();
        builder.Services.AddTransient<IArchivalEntityPublicService, ArchivalEntityPublicService>();
        builder.Services.AddTransient<IDocumentPublicService, DocumentPublicService>();
        builder.Services.AddTransient<ISearchService, SearchService>();

        builder.Services.AddTransient<IPackagesService, PackagesService>();
        builder.Services.AddTransient<IFileService, FileService>();
        builder.Services.AddTransient<IPackageATemplatesService, PackageATemplatesService>();
        builder.Services.AddTransient<IEAuthenticationService, EAuthenticationService>();
        builder.Services.AddSingleton<IApplicationStoreService, ApplicationStoreService>();
        builder.Services.AddTransient<ILibraryCardService, LibraryCardService>();
        builder.Services.AddTransient<IProcessService, ProcessService>();
        builder.Services.AddTransient<IFilmPublicService, FilmPublicService>();
        builder.Services.AddTransient<IFilmDocumentPublicService, FilmDocumentPublicService>();
        builder.Services.AddTransient<IDigitalObjectPublicService, DigitalObjectPublicService>();
        builder.Services.AddTransient<IArchiveService, ArchiveService>();
        builder.Services.AddTransient<IRoleService, RoleService>();
        builder.Services.AddTransient<IFilmCardService, FilmCardService>();
        builder.Services.AddTransient<ILinksService, LinksService>();
        builder.Services.AddTransient<INotificationService, NotificationService>();
        builder.Services.AddTransient<INotificationEventService, NotificationEventService>();
        builder.Services.AddTransient<ITaskService, TaskService>();
        builder.Services.AddTransient<IUserService, UserService>();
        builder.Services.AddTransient<IFilmCardPublicService, FilmCardPublicService>();
        builder.Services.AddTransient<IUtilityService, UtilityService>();
        builder.Services.AddTransient<INumberService, NumberService>();

        builder.Services.AddTransient<IImportService, ImportService>();
        builder.Services.AddTransient<IModelValidationService, ModelValidationService>();
        builder.Services.AddTransient<IFileUploadAppService, FileUploadAppService>();
        builder.Services.AddTransient<IAuthorizationService, AuthorizationService>();
        builder.Services.AddTransient<IInformationService, InformationService>();

        return builder;
    }
}

