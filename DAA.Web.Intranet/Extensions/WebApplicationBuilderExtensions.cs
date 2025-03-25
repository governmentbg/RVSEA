using DAA.Extensions.Builder;
using DAA.Services;
using DAA.Services.Admin;
using DAA.Services.Applications;
using DAA.Services.ArchivalEntities;
using DAA.Services.Authentication;
using DAA.Services.Authorization;
using DAA.Services.Comments;
using DAA.Services.CommissionDecisions;
using DAA.Services.CommissionReports;
using DAA.Services.CommissionSessions;
using DAA.Services.DeductionProcess;
using DAA.Services.DigitalObjects;
using DAA.Services.DocsCollectingProc;
using DAA.Services.DocsCreatingProc;
using DAA.Services.Documents;
using DAA.Services.EditDataProcess;
using DAA.Services.EditFundDataProcess;
using DAA.Services.Files;
using DAA.Services.FileUploadApp;
using DAA.Services.Films;
using DAA.Services.FundReconstructions;
using DAA.Services.Funds;
using DAA.Services.Interfaces;
using DAA.Services.Inventories;
using DAA.Services.Nomenclatures;
using DAA.Services.Notifications;
using DAA.Services.Packages;
using DAA.Services.Process;
using DAA.Services.ProcessRawInventoriesProcess;
using DAA.Services.Search;
using DAA.Services.ReconstructFundDataProcess;
using DAA.Services.RefineDataProcess;
using DAA.Services.Roles;
using DAA.Services.Settings;
using DAA.Services.Tasks;
using DAA.Services.Users;
using DAA.Shared.Hubs;
using DocFlow.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using IArchivingAuhorizationService = DAA.Services.Authorization.IAuthorizationService;
using DAA.Services.Numbers;
using DAA.Services.Import;
using DAA.Services.Watermark;
using DAA.Services.Information;
using Microsoft.Extensions.Options;
using DAA.Models.Configuration;
using DAA.Services.OpenData;

public static class WebApplicationBuilderExtensions
{
    public static WebApplicationBuilder RegisterServices(this WebApplicationBuilder builder)
    {
        builder.AddDbContext();

        builder.AddLocalization();

        builder.AddOptions();

        builder.AddIdentity();
        builder.AddNegotiateAuthentication();
        //builder.AddBearerAuthentication();
        builder.Services.AddAuthorization();

        builder.Services.AddHttpContextAccessor();

        builder.Services.AddHttpClient("openData", (serviceProvider, client) =>
        {
            var settings = serviceProvider.GetRequiredService<IOptions<OpenDataSettings>>().Value;

            client.BaseAddress = new Uri(settings.Url);
            client.Timeout = TimeSpan.FromMinutes(15);
        });

        builder.AddHangFire();
        builder.Services.AddSignalR();

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
        builder.Services.AddSingleton<IAuthorizationPolicyProvider, AuthorizationPolicyProvider>();
        builder.Services.AddScoped<IAuthorizationHandler, AdminAuthorizationHandler>();
        builder.Services.AddScoped<IAuthorizationHandler, RolesAuthorizationHandler>();
        builder.Services.AddScoped<IAuthorizationHandler, ArchiveAuthorizationHandler>();
        builder.Services.AddTransient<IArchivingAuhorizationService, AuthorizationService>();
        builder.Services.AddTransient<IGlobalAdministratorService, GlobalAdministratorService>();
        builder.Services.AddTransient<ITokenService, TokenService>();
        builder.Services.AddTransient<IUserService, UserService>();
        builder.Services.AddTransient<IUserProfileService, UserProfileService>();
        builder.Services.AddTransient<IRoleService, RoleService>();
      
        builder.Services.AddTransient<IEmailService, EmailService>();
        builder.Services.AddTransient<INotificationService, NotificationService>();
        builder.Services.AddTransient<INotificationTaskService, NotificationTaskService>();
        builder.Services.AddTransient<IExportService, ExportService>(); 
        builder.Services.AddTransient<IDropdownService, DropdownService>();
        builder.Services.AddTransient<INomenclatureService, NomenclatureService>();
        
        builder.Services.AddTransient<IArchiveService, ArchiveService>();
        builder.Services.AddTransient<IFundService, FundService>();
        builder.Services.AddTransient<IInventoryService, InventoryService>();
        builder.Services.AddTransient<IArchivalEntityService, ArchivalEntityService>();
        builder.Services.AddTransient<IDocumentService, DocumentService>();
        builder.Services.AddTransient<IDigitalObjectService, DigitalObjectService>();
        builder.Services.AddTransient<IFileService, FileService>();
        builder.Services.AddTransient<IFileUploadAppService, FileUploadAppService>();
        builder.Services.AddTransient<IDocsCollectingProcedureService, DocsCollectingProcedureService>();
        builder.Services.AddTransient<IFilmService, FilmService>();
        builder.Services.AddTransient<IFilmCardService, FilmCardService>();
        builder.Services.AddTransient<IFilmDocumentService, FilmDocumentService>();
        builder.Services.AddTransient<IDocsCreatingProcedureService, DocsCreatingProcedureService>();
        builder.Services.AddTransient<IReportService, ReportService>();
        builder.Services.AddTransient<IPackageATemplatesService, PackageATemplatesService>();
        builder.Services.AddTransient<IProcessService, ProcessService>();
        builder.Services.AddTransient<IEditDataProcessService, EditDataProcessService>();
        builder.Services.AddTransient<IRefineDataProcessService, RefineDataProcessService>();
        builder.Services.AddTransient<IEditFundDataProcessService, EditFundDataProcessService>();
        builder.Services.AddTransient<IReconstructFundDataProcessService, ReconstructFundDataProcessService>();
        builder.Services.AddTransient<IFundReconstructionService, FundReconstructionService>();
        builder.Services.AddTransient<IDeductionProcessService, DeductionProcessService>();
        builder.Services.AddTransient<ICommissionReportService, CommissionReportService>();
        builder.Services.AddTransient<ICommissionSessionService, CommissionSessionService>();
        builder.Services.AddTransient<ISessionAgendaService, SessionAgendaService>();
        builder.Services.AddTransient<ICommentsService, CommentsService>();
        builder.Services.AddTransient<ITaskService, TaskService>();
        builder.Services.AddTransient<ITaskNotificationServiceJob, TaskNotificationServiceJob>();
        builder.Services.AddTransient<ISignalRNotificationsService, SignalRNotificationsService>();
        builder.Services.AddTransient<IApplicationsService, ApplicationsService>();
        builder.Services.AddSingleton<IUserIdProvider, CustomUserIdProvider>();
        builder.Services.AddTransient<ICommissionDecisionService, CommissionDecisionService>();
        builder.Services.AddTransient<IPackagesService, PackagesService>();
        builder.Services.AddTransient<ISearchService, SearchService>();
        builder.Services.AddTransient<IProcessRawInventoriesProcessService, ProcessRawInventoriesProcessService>();
        builder.Services.AddTransient<ITaskTemplatesService, TaskTemplatesService>();
        builder.Services.AddTransient<ISettingsService, SettingsService>();
        builder.Services.AddTransient<INumberService, NumberService>();
        builder.Services.AddTransient<ILinksService, LinksService>();
        builder.Services.AddTransient<INotificationEventService, NotificationEventService>();
        builder.Services.AddTransient<INotificationPureService, NotificationPureService>();
        builder.Services.AddTransient<IPureNotificationServiceJob, PureNotificationServiceJob>();
        builder.Services.AddTransient<IUtilityService, UtilityService>();
        builder.Services.AddTransient<IImportService, ImportService>();
        builder.Services.AddTransient<IModelValidationService, ModelValidationService>();
        builder.Services.AddTransient<IWatermarkService, WatermarkService>();
        builder.Services.AddTransient<IOpenDataService, OpenDataService>();
        builder.Services.AddTransient<IOpenDataServiceJob, OpenDataServiceJob>();
        builder.Services.AddTransient<IInformationService, InformationService>();

        return builder;
    }
}

