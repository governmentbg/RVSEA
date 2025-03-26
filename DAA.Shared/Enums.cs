using Newtonsoft.Json.Serialization;

namespace DAA.Shared
{
    public enum CommitieApprovalStatus
    {
        Accepted = 1,
        AcceptedWithChanges = 2,
        Rejected = 3,
        Redirected = 4,
    }

    public enum ReportResultType
    {
        AllDB = 1,
        ExternalDB = 2,
        InternalDB = 3
    }

    public enum ApplicationStatus
    {
        New = 1,
        Approved = 2,
        Rejected = 3,
        AddPackages = 4,
        EditPackages = 5,
        CommitteeRejected = 6,
        CommitteeApproved = 7,
        AwaitingCommittee = 8,
        CommitteeDecisionUpdate = 9,
        Registration = 10,
        RegistrationComplete = 11,
        PackagesApproval = 12,
        RejectedByCommission = 13,
        AcquisitionContract = 14,
        SignatureRequest = 15,
        SignedDocuments = 16,
        Redirected = 17,
        ModificationRequest = 18,
        ModificationApplied = 19,
    }

    public class ApplicationType
    {
        public const string Assembled = "assembled";
        public const string Raw = "raw";
    }

    public class ApplicationDocumentsOriginType
    {
        public const string Institutional = "insitutional";
        public const string InstitutionalRaw = "insitutional_raw";
        public const string PersonalRaw = "personal_raw";
    }

    public enum FundDescriptionLevel
    {
        Fund = 1,
        RawFund = 2,
        Memory = 3,
        ChP = 4
    }

    public enum FundType
    {
        Group = 1,
        Collection = 2,
        Personal = 3,
        Generic = 4,
        Family = 5,
        Institutional = 6,
    }

    public class TaskStatus
    {
        public const string Pending = "Pending";
        public const string Completed = "Complete";
        public const string Canceled = "Cancelled";
        public const string NotStarted = "NotStarted";
    }

    public class EntityType
    {
        public const string unknown = "";
        public const string eDocsCollecting = "eDocsCollecting";
        public const string film = "film";
        public const string fund = "fund";
        public const string inventory = "inventory";
        public const string archivalEntity = "archival entity";
        public const string document = "document";
        public const string allLevels = "all levels";
        public const string session = "session";
        public const string eDocsApplication = "eDocsApplication";

    }

    public class NotificationType
    {
        public const string None = "";
        public const string NewTask = "NewTask";
        public const string CompletedTask = "CompletedTask";
        public const string CancelledTask = "CancelledTask";
        public const string NewApplication = "NewApplication";
        public const string RejectedApplication = "RejectedApplication";
        public const string ApprovedApplication = "ApprovedApplication";
        public const string AssignedApplication = "AssignedApplication";
        public const string AddApplicationPackages = "AddApplicationPackages";
        public const string ApplicationPackagesAdded = "ApplicationPackagesAdded";
        public const string ApprovedApplicationPackages = "ApprovedApplicationPackages";
        public const string RejectedApplicationPackages = "RejectedApplicationPackages";
        public const string ModifyApplicationPackages = "ModifyApplicationPackages";
        public const string SendProtocolForApproval = "SendProtocolForApproval";
        public const string RequestModification = "RequestModification";
        public const string ModificationApplied = "AppliedModification";
        public const string RequestSignature = "RequestSignature";
        public const string SignedDocuments = "SignedDocuments";
        public const string RedirectedApplication = "RedirectedApplication";
    }

    public enum CopyType
    {
        Photo = 1,
        Digital = 2,
        Film = 3,
        MicrofilmNegative = 4,
        MicrofilmPositive = 5,
    }

    public enum InventoryDescriptionLevel
    {
        Inventory = 5,
        RawInventory = 6,
        SystemInventory = 12,
    }

    public enum ArchivalEntityDescriptionLevel
    {
        ArchivalEntity = 1,
        SystemArchivalEntity = 2,
    }

    public enum DocumentDescriptionLevel
    {
        Document = 1,
        SystemDocument = 14,
    }

    public enum SessionType
    {
        EPK = 1,
        EOK = 2,
        REOK = 3
    }

    public enum FilmDocumentType
    {
        Declaration = 1,
        Protocol = 2,
        Other = 3,
        FilmFile = 4
    }

    public enum ExcelDropDownListType
    {
        None = 0,
        Language = 1,
        AcquisitionMethod = 2,
        InventoryNumberArray = 3,

    }

    public enum DescriptionLevelExternalIdentifier
    {
        Fund = 20,                   // Фонд
        RawFund = 91,               //'Фонд с необработени документи'
        Memory = 22,               //'Спомен'
        CHP = 21,                 //'ЧП'
        RawInventory = 2172,      //'Груб опис'
        Inventory = 2171,    //'Инвентарен опис'
        CPMemoryInventory = 2372, //'Служебен опис'
        ArchivalEntity = 2174,   //'Архивна единица'
        CPMemoryArchiveEntity = 2373, // 	'Служебна архивна единица'
        Document = 2173, // 'Документ'
        CMF = 2185,  //'КМФ'
        FAInventory = 2369, //'Инвентарен номер (КМФ)'
        FAArchiveEntity = 2371//'Архивна единица (КМФ)'
    }
}
