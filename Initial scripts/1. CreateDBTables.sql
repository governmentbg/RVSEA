
begin transaction 
GO

/****** Object:  Schema [A]    Script Date: 30.11.2022 г. 10:53:44 ******/
CREATE SCHEMA [A]
GO
/****** Object:  Schema [HangFire]    Script Date: 30.11.2022 г. 10:53:44 ******/
CREATE SCHEMA [HangFire]
GO
/****** Object:  Schema [N]    Script Date: 30.11.2022 г. 10:53:44 ******/
CREATE SCHEMA [N]
GO
/****** Object:  Schema [Notification]    Script Date: 30.11.2022 г. 10:53:44 ******/
CREATE SCHEMA [Notification]
GO
/****** Object:  Table [A].[AuditEntries]    Script Date: 30.11.2022 г. 10:53:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [A].[AuditEntries](
	[AuditEntryID] [int] IDENTITY(1,1) NOT NULL,
	[EntitySetName] [nvarchar](255) NULL,
	[EntityTypeName] [nvarchar](255) NULL,
	[State] [int] NOT NULL,
	[StateName] [nvarchar](255) NULL,
	[Ip] [nvarchar](40) NULL,
	[UserAgent] [nvarchar](255) NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[CreatedByUsername] [nvarchar](256) NOT NULL,
	[CorrelationId] [nvarchar](36) NULL,
	[Lease] [int] NULL,
	[Description] [nvarchar](max) NULL,
 CONSTRAINT [PK_AuditEntries] PRIMARY KEY CLUSTERED 
(
	[AuditEntryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [A].[AuditEntryProperties]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [A].[AuditEntryProperties](
	[AuditEntryPropertyID] [int] IDENTITY(1,1) NOT NULL,
	[AuditEntryID] [int] NOT NULL,
	[RelationName] [nvarchar](255) NULL,
	[PropertyName] [nvarchar](255) NULL,
	[OldValue] [nvarchar](max) NULL,
	[NewValue] [nvarchar](max) NULL,
	[IsKey] [bit] NOT NULL,
 CONSTRAINT [PK_AuditEntryProperties] PRIMARY KEY CLUSTERED 
(
	[AuditEntryPropertyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[_Version]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[_Version](
	[Code] [nvarchar](50) NOT NULL,
	[Value] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Version] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ArchivalEntities]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ArchivalEntities](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ArchiveId] [int] NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
	[Number] [nvarchar](50) NULL,
	[Title] [nvarchar](max) NULL,
	[DescriptionLevelCode] [nvarchar](50) NULL,
	[StatusCode] [nvarchar](50) NULL,
	[HasNoChronologicalScope] [bit] NOT NULL,
	[StartDateYear] [int] NULL,
	[StartDateMonth] [int] NULL,
	[StartDateDay] [int] NULL,
	[EndDateYear] [int] NULL,
	[EndDateMonth] [int] NULL,
	[EndDateDay] [int] NULL,
	[ApproxmateChronologicalScope] [nvarchar](256) NULL,
	[Author] [nvarchar](max) NULL,
	[Location] [nvarchar](max) NULL,
	[Bytes] [bigint] NULL,
	[SheetCount] [int] NULL,
	[TapeCount] [int] NULL,
	[MicrofilmCount] [int] NULL,
	[FrameCount] [int] NULL,
	[VideoTapeCount] [int] NULL,
	[DigitalDeviceCount] [int] NULL,
	[OtherMetrics] [nvarchar](256) NULL,
	[SizeCm] [nvarchar](256) NULL,
	[Scaling] [nvarchar](256) NULL,
	[Description] [nvarchar](max) NULL,
	[DocumentsAccessDescription] [nvarchar](max) NULL,
	[Features] [nvarchar](max) NULL,
	[Condition] [nvarchar](max) NULL,
	[MicrofilmedCopyCount] [int] NULL,
	[DigitizedCopyCount] [int] NULL,
	[PaperCopyCount] [int] NULL,
	[NegativeFrameCount] [int] NULL,
	[PositiveFrameCount] [int] NULL,
	[OtherCopyCount] [nvarchar](max) NULL,
	[Notes] [nvarchar](max) NULL,
	[EnrolledBytes] [bigint] NULL,
	[EnrolledDocumentCount] [int] NULL,
	[EnrolledLinearMeters] [float] NULL,
	[DeductedBytes] [bigint] NULL,
	[DeductedDocumentCount] [int] NULL,
	[DeductedLinearMeters] [float] NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[FundSystemIdentifier] [uniqueidentifier] NOT NULL,
	[InventorySystemIdentifier] [uniqueidentifier] NOT NULL,
	[IsSuspended] [bit] NOT NULL,
	[AvailabilityStatusCode] [int] NULL,
 CONSTRAINT [PK_ArchivalEntities] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UI_ArchivalEntitySystemIdentifier] UNIQUE NONCLUSTERED 
(
	[SystemIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ArchivalEntityDrafts]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ArchivalEntityDrafts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[ArchiveId] [int] NOT NULL,
	[FundDraftId] [int] NULL,
	[FundSystemIdentifier] [uniqueidentifier] NOT NULL,
	[InventoryDraftId] [int] NULL,
	[InventorySystemIdentifier] [uniqueidentifier] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
	[ReadOnly] [bit] NOT NULL,
	[WorkflowTypeCode] [nvarchar](50) NULL,
	[WorkflowId] [int] NULL,
	[WorkflowStepTypeCode] [nvarchar](50) NULL,
	[WorkflowStepId] [int] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
	[Number] [nvarchar](50) NULL,
	[Title] [nvarchar](max) NULL,
	[DescriptionLevelCode] [nvarchar](50) NOT NULL,
	[StatusCode] [nvarchar](50) NOT NULL,
	[HasNoChronologicalScope] [bit] NOT NULL,
	[StartDateYear] [int] NULL,
	[StartDateMonth] [int] NULL,
	[StartDateDay] [int] NULL,
	[EndDateYear] [int] NULL,
	[EndDateMonth] [int] NULL,
	[EndDateDay] [int] NULL,
	[ApproxmateChronologicalScope] [nvarchar](256) NULL,
	[Author] [nvarchar](max) NULL,
	[Location] [nvarchar](max) NULL,
	[Bytes] [bigint] NULL,
	[SheetCount] [int] NULL,
	[TapeCount] [int] NULL,
	[MicrofilmCount] [int] NULL,
	[FrameCount] [int] NULL,
	[VideoTapeCount] [int] NULL,
	[DigitalDeviceCount] [int] NULL,
	[OtherMetrics] [nvarchar](256) NULL,
	[SizeCm] [nvarchar](256) NULL,
	[Scaling] [nvarchar](256) NULL,
	[Description] [nvarchar](max) NULL,
	[DocumentsAccessDescription] [nvarchar](max) NULL,
	[Features] [nvarchar](max) NULL,
	[Condition] [nvarchar](max) NULL,
	[MicrofilmedCopyCount] [int] NULL,
	[DigitizedCopyCount] [int] NULL,
	[PaperCopyCount] [int] NULL,
	[NegativeFrameCount] [int] NULL,
	[PositiveFrameCount] [int] NULL,
	[OtherCopyCount] [nvarchar](max) NULL,
	[Notes] [nvarchar](max) NULL,
	[EnrolledBytes] [bigint] NULL,
	[EnrolledDocumentCount] [int] NULL,
	[EnrolledLinearMeters] [float] NULL,
	[DeductedBytes] [bigint] NULL,
	[DeductedDocumentCount] [int] NULL,
	[DeductedLinearMeters] [float] NULL,
	[AvailabilityStatusCode] [int] NULL,
 CONSTRAINT [PK_ArchivalEntityDrafts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Archives]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Archives](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[Name] [nvarchar](255) NOT NULL,
	[Code] [int] NOT NULL,
	[SortOrder] [int] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
 CONSTRAINT [PK_Archives] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ArchivesSpecificOrder]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ArchivesSpecificOrder](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ArchiveId] [int] NOT NULL,
	[SortOrder] [int] NULL,
 CONSTRAINT [PK_ArchivesSpecificOrder] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetRoleClaims]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoleClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetRoleClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetRoles]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetRoles](
	[Id] [uniqueidentifier] NOT NULL,
	[ArchiveId] [int] NULL,
	[Name] [nvarchar](256) NULL,
	[NormalizedName] [nvarchar](256) NULL,
	[ConcurrencyStamp] [nvarchar](max) NULL,
	[Abbreviation] [nvarchar](5) NULL,
 CONSTRAINT [PK_AspNetRoles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserArchives]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserArchives](
	[UserId] [uniqueidentifier] NOT NULL,
	[ArchiveId] [int] NOT NULL,
	[Inactive] [bit] NULL,
 CONSTRAINT [PK_AspNetUserArchives] PRIMARY KEY CLUSTERED 
(
	[ArchiveId] ASC,
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserClaims]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserClaims](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[ClaimType] [nvarchar](max) NULL,
	[ClaimValue] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetUserClaims] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserLogins]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserLogins](
	[LoginProvider] [nvarchar](128) NOT NULL,
	[ProviderKey] [nvarchar](256) NOT NULL,
	[ProviderDisplayName] [nvarchar](max) NULL,
	[UserId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_AspNetUserLogins] PRIMARY KEY CLUSTERED 
(
	[LoginProvider] ASC,
	[ProviderKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserProfiles]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserProfiles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[ProfileType] [nchar](3) NULL,
	[EntityType] [nvarchar](20) NULL,
	[FirstName] [nvarchar](256) NOT NULL,
	[Surname] [nvarchar](256) NULL,
	[LastName] [nvarchar](256) NOT NULL,
	[DisplayName]  AS (concat([FirstName],' ',[Surname],' ',[LastName])) PERSISTED NOT NULL,
	[Organization] [nvarchar](max) NULL,
	[Department] [nvarchar](max) NULL,
	[JobTitle] [nvarchar](max) NULL,
	[Address] [nvarchar](max) NULL,
	[LibraryCardNumber] [nvarchar](256) NULL,
 CONSTRAINT [PK_AspNetUserProfiles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserRoles]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserRoles](
	[UserId] [uniqueidentifier] NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_AspNetUserRoles] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUsers]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUsers](
	[Id] [uniqueidentifier] NOT NULL,
	[AuthenticationType] [nvarchar](20) NOT NULL,
	[UserType] [nchar](3) NOT NULL,
	[UserProfileType] [nchar](3) NULL,
	[UserName] [nvarchar](256) NULL,
	[NormalizedUserName] [nvarchar](256) NULL,
	[DisplayName] [nvarchar](256) NULL,
	[Email] [nvarchar](256) NULL,
	[NormalizedEmail] [nvarchar](256) NULL,
	[Certificate] [varbinary](max) NULL,
	[CertificateThumbprint] [nvarchar](max) NULL,
	[CertificateName] [nvarchar](256) NULL,
	[CertificateUniqueIdentifier] [nvarchar](256) NULL,
	[EmailConfirmed] [bit] NOT NULL,
	[PasswordHash] [nvarchar](max) NULL,
	[SecurityStamp] [nvarchar](max) NULL,
	[ConcurrencyStamp] [nvarchar](max) NULL,
	[PhoneNumber] [nvarchar](max) NULL,
	[PhoneNumberConfirmed] [bit] NOT NULL,
	[TwoFactorEnabled] [bit] NOT NULL,
	[LockoutEnd] [datetimeoffset](7) NULL,
	[LockoutEnabled] [bit] NOT NULL,
	[AccessFailedCount] [int] NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
 CONSTRAINT [PK_AspNetUsers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AspNetUserTokens]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AspNetUserTokens](
	[UserId] [uniqueidentifier] NOT NULL,
	[LoginProvider] [nvarchar](128) NOT NULL,
	[Name] [nvarchar](128) NOT NULL,
	[Value] [nvarchar](max) NULL,
 CONSTRAINT [PK_AspNetUserTokens] PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[LoginProvider] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Comments]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Comments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Text] [nvarchar](max) NULL,
	[UserName] [nvarchar](255) NULL,
	[ProcessId] [int] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[DeletedOn] [datetime2](7) NULL,
	[Deleted] [bit] NOT NULL,
	[ProcessStepId] [int] NULL,
	[IsDraft] [bit] NOT NULL,
	[SessionAgendaStandpointId] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CommissionReportFiles]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CommissionReportFiles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ReportId] [int] NOT NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Name] [nvarchar](max) NOT NULL,
	[SourceName] [nvarchar](max) NOT NULL,
	[UncPath] [nvarchar](max) NOT NULL,
	[FileType] [nvarchar](50) NOT NULL,
	[ContentType] [nvarchar](max) NULL,
 CONSTRAINT [PK_CommissionReportFiles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DigitalObjectDrafts]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DigitalObjectDrafts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[ParentId] [int] NULL,
	[ParentSystemIdentifier] [uniqueidentifier] NULL,
	[ArchiveId] [int] NOT NULL,
	[FundDraftId] [int] NULL,
	[FundSystemIdentifier] [uniqueidentifier] NOT NULL,
	[InventoryDraftId] [int] NULL,
	[InventorySystemIdentifier] [uniqueidentifier] NOT NULL,
	[ArchivalEntityDraftId] [int] NULL,
	[ArchivalEntitySystemIdentifier] [uniqueidentifier] NOT NULL,
	[DocumentDraftId] [int] NULL,
	[DocumentSystemIdentifier] [uniqueidentifier] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
	[ReadOnly] [bit] NOT NULL,
	[WorkflowTypeCode] [nvarchar](50) NULL,
	[WorkflowId] [int] NULL,
	[WorkflowStepTypeCode] [nvarchar](50) NULL,
	[WorkflowStepId] [int] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
	[Name] [nvarchar](max) NOT NULL,
	[SourceName] [nvarchar](max) NOT NULL,
	[UncPath] [nvarchar](max) NOT NULL,
	[FileType] [nvarchar](50) NOT NULL,
	[StatusCode] [nvarchar](50) NOT NULL,
	[ContentType] [nvarchar](max) NULL,
	[TypeCode] [int] NOT NULL,
	[AvailabilityStatusCode] [int] NULL,
	[WatermarkName] [nvarchar](max) NULL,
	[WatermarkUncPath] [nvarchar](max) NULL,
	[HashCode] [nvarchar](100) NULL,
 CONSTRAINT [PK_DigitalObjectDrafts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DigitalObjectReviews]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DigitalObjectReviews](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[DigitalObjectSystemIdentifier] [uniqueidentifier] NOT NULL,
	[DocumentSystemIdentifier] [uniqueidentifier] NOT NULL,
	[ArchivalEntitySystemIdentifier] [uniqueidentifier] NOT NULL,
	[UserSystemIdentifier] [uniqueidentifier] NOT NULL,
	[UserDisplayName] [nvarchar](256) NULL,
	[UserType] [nchar](3) NOT NULL,
	[Date] [datetime2](7) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DigitalObjects]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DigitalObjects](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[ParentId] [int] NULL,
	[ParentSystemIdentifier] [uniqueidentifier] NULL,
	[ArchiveId] [int] NOT NULL,
	[FundSystemIdentifier] [uniqueidentifier] NOT NULL,
	[InventorySystemIdentifier] [uniqueidentifier] NOT NULL,
	[ArchivalEntitySystemIdentifier] [uniqueidentifier] NOT NULL,
	[DocumentSystemIdentifier] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
	[Name] [nvarchar](max) NOT NULL,
	[SourceName] [nvarchar](max) NOT NULL,
	[UncPath] [nvarchar](max) NOT NULL,
	[FileType] [nvarchar](50) NOT NULL,
	[StatusCode] [nvarchar](50) NOT NULL,
	[ContentType] [nvarchar](max) NULL,
	[TypeCode] [int] NOT NULL,
	[IsSuspended] [bit] NOT NULL,
	[AvailabilityStatusCode] [int] NULL,
	[WatermarkName] [nvarchar](max) NULL,
	[WatermarkUncPath] [nvarchar](max) NULL,
	[HashCode] [nvarchar](100) NULL,
 CONSTRAINT [PK_DigitalObjects] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UI_DigitalObjectSystemIdentifier] UNIQUE NONCLUSTERED 
(
	[SystemIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DocumentDigitalObjects]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentDigitalObjects](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DocumentId] [int] NULL,
	[FileId] [nvarchar](max) NULL,
	[Approved] [bit] NULL,
	[FileName] [nvarchar](255) NULL,
	[FileType] [nvarchar](255) NULL,
	[IsMaster] [bit] NOT NULL,
	[DocumentSystemIdentifier] [uniqueidentifier] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DocumentDrafts]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DocumentDrafts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[ArchiveId] [int] NOT NULL,
	[FundDraftId] [int] NULL,
	[FundSystemIdentifier] [uniqueidentifier] NOT NULL,
	[InventoryDraftId] [int] NULL,
	[InventorySystemIdentifier] [uniqueidentifier] NOT NULL,
	[ArchivalEntityDraftId] [int] NULL,
	[ArchivalEntitySystemIdentifier] [uniqueidentifier] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
	[ReadOnly] [bit] NOT NULL,
	[WorkflowTypeCode] [nvarchar](50) NULL,
	[WorkflowId] [int] NULL,
	[WorkflowStepTypeCode] [nvarchar](50) NULL,
	[WorkflowStepId] [int] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
	[Number] [nvarchar](50) NULL,
	[Title] [nvarchar](max) NULL,
	[FileFormatCode] [nvarchar](50) NULL,
	[DescriptionLevelCode] [nvarchar](50) NOT NULL,
	[StatusCode] [nvarchar](50) NOT NULL,
	[HasNoChronologicalScope] [bit] NOT NULL,
	[StartDateYear] [int] NULL,
	[StartDateMonth] [int] NULL,
	[StartDateDay] [int] NULL,
	[EndDateYear] [int] NULL,
	[EndDateMonth] [int] NULL,
	[EndDateDay] [int] NULL,
	[ApproxmateChronologicalScope] [nvarchar](256) NULL,
	[Author] [nvarchar](max) NULL,
	[Location] [nvarchar](max) NULL,
	[Bytes] [bigint] NULL,
	[SheetCount] [int] NULL,
	[StartSheetNumber] [int] NULL,
	[EndSheetNumber] [int] NULL,
	[DigitalDevice] [nvarchar](max) NULL,
	[OtherMetrics] [nvarchar](256) NULL,
	[SizeCm] [nvarchar](256) NULL,
	[Scaling] [nvarchar](256) NULL,
	[Duration] [int] NULL,
	[Description] [nvarchar](max) NULL,
	[DocumentsAccessDescription] [nvarchar](max) NULL,
	[Features] [nvarchar](max) NULL,
	[MicrofilmedCopyCount] [int] NULL,
	[DigitizedCopyCount] [int] NULL,
	[PaperCopyCount] [int] NULL,
	[NegativeFrameCount] [int] NULL,
	[PositiveFrameCount] [int] NULL,
	[OtherCopyCount] [nvarchar](max) NULL,
	[Transcription] [nvarchar](max) NULL,
	[Notes] [nvarchar](max) NULL,
	[AvailabilityStatusCode] [int] NULL,
 CONSTRAINT [PK_DocumentDrafts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Documents]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Documents](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ArchiveId] [int] NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
	[Number] [nvarchar](50) NULL,
	[Title] [nvarchar](max) NULL,
	[FileFormatCode] [nvarchar](50) NULL,
	[DescriptionLevelCode] [nvarchar](50) NOT NULL,
	[StatusCode] [nvarchar](50) NOT NULL,
	[HasNoChronologicalScope] [bit] NOT NULL,
	[StartDateYear] [int] NULL,
	[StartDateMonth] [int] NULL,
	[StartDateDay] [int] NULL,
	[EndDateYear] [int] NULL,
	[EndDateMonth] [int] NULL,
	[EndDateDay] [int] NULL,
	[ApproxmateChronologicalScope] [nvarchar](256) NULL,
	[Author] [nvarchar](max) NULL,
	[Location] [nvarchar](max) NULL,
	[Bytes] [bigint] NULL,
	[SheetCount] [int] NULL,
	[StartSheetNumber] [int] NULL,
	[EndSheetNumber] [int] NULL,
	[DigitalDevice] [nvarchar](max) NULL,
	[OtherMetrics] [nvarchar](256) NULL,
	[SizeCm] [nvarchar](256) NULL,
	[Scaling] [nvarchar](256) NULL,
	[Duration] [int] NULL,
	[Description] [nvarchar](max) NULL,
	[DocumentsAccessDescription] [nvarchar](max) NULL,
	[Features] [nvarchar](max) NULL,
	[MicrofilmedCopyCount] [int] NULL,
	[DigitizedCopyCount] [int] NULL,
	[PaperCopyCount] [int] NULL,
	[NegativeFrameCount] [int] NULL,
	[PositiveFrameCount] [int] NULL,
	[OtherCopyCount] [nvarchar](max) NULL,
	[Transcription] [nvarchar](max) NULL,
	[Notes] [nvarchar](max) NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[FundSystemIdentifier] [uniqueidentifier] NOT NULL,
	[InventorySystemIdentifier] [uniqueidentifier] NOT NULL,
	[ArchivalEntitySystemIdentifier] [uniqueidentifier] NOT NULL,
	[IsSuspended] [bit] NOT NULL,
	[AvailabilityStatusCode] [int] NULL,
 CONSTRAINT [PK_Documents] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UI_DocumentSystemIdentifier] UNIQUE NONCLUSTERED 
(
	[SystemIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EDocsCollectingApplication]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EDocsCollectingApplication](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ArchiveId] [int] NOT NULL,
	[Number] [int] NOT NULL,
	[Type] [nvarchar](50) NOT NULL,
	[ApplicantId] [uniqueidentifier] NOT NULL,
	[FileId] [int] NOT NULL,
	[StatusId] [int] NOT NULL,
	[AssignToUserId] [uniqueidentifier] NULL,
	[RejectReason] [nvarchar](max) NULL,
	[PackageAId] [int] NULL,
	[PackageBId] [int] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
 CONSTRAINT [PK_EDocsCollectingApplication] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EPKReports]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EPKReports](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Date] [datetime2](7) NOT NULL,
	[Number] [int] NOT NULL,
	[FundName] [nvarchar](255) NULL,
	[AuthorName] [nvarchar](255) NULL,
	[AuthorPosition] [nvarchar](255) NULL,
	[About] [nvarchar](255) NOT NULL,
	[Content] [nvarchar](max) NOT NULL,
	[EntityLink] [nvarchar](255) NOT NULL,
	[ProcessId] [int] NULL,
	[IsDraft] [bit] NOT NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[DeletedOn] [datetime2](7) NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[LinkTitle] [nvarchar](250) NULL,
	[Deleted] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Files]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Files](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FileName] [nvarchar](500) NOT NULL,
	[Content] [varbinary](max) NOT NULL,
	[ContentType] [nvarchar](500) NOT NULL,
	[FileType] [nvarchar](50) NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Files] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FileUploadQueue]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FileUploadQueue](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[ComputerName] [varchar](256) NOT NULL,
	[LocalFileName] [nvarchar](2000) NOT NULL,
	[Checksum] [varchar](100) NOT NULL,
	[FileName] [nvarchar](2000) NOT NULL,
	[ProcessKindCode] [varchar](20) NOT NULL,
	[FileKindCode] [varchar](20) NULL,
	[DocumentId] [uniqueidentifier] NOT NULL,
	[MasterDocumentId] [uniqueidentifier] NULL,
	[Notes] [nvarchar](2000) NULL,
	[Size] [bigint] NOT NULL,
	[Position] [bigint] NOT NULL,
	[Finished] [bit] NOT NULL,
	[DbFileName] [nvarchar](2000) NOT NULL,
	[UncFileName] [nvarchar](2000) NULL,
	[ChecksumCheckResult] [bit] NULL,
	[FileFormatCheckResult] [bit] NULL,
	[AntivirusCheckResult] [bit] NULL,
	[AntivirusCheckInfo] [nvarchar](2000) NULL,
	[FileInfo] [nvarchar](2000) NULL,
	[ErrorMessage] [nvarchar](2000) NULL,
 CONSTRAINT [Pk_FileUploadQueue] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FilmCardDocuments]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FilmCardDocuments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CardId] [int] NOT NULL,
	[PackageDocumentId] [int] NOT NULL,
	[IsDraft] [bit] NOT NULL,
 CONSTRAINT [PK_FilmCardDocuments] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FilmCardDrafts]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FilmCardDrafts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[ArchiveId] [int] NOT NULL,
	[FilmDraftId] [int] NULL,
	[FilmSystemIdentifier] [uniqueidentifier] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
	[ReadOnly] [bit] NOT NULL,
	[WorkflowTypeCode] [nvarchar](50) NULL,
	[WorkflowId] [int] NULL,
	[WorkflowStepTypeCode] [nvarchar](50) NULL,
	[WorkflowStepId] [int] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
	[CountryId] [int] NULL,
	[City] [nvarchar](250) NULL,
	[DocumentsCypher] [nvarchar](2000) NULL,
	[Title] [nvarchar](500) NULL,
	[ArchiveOriginals] [nvarchar](2000) NULL,
	[StartDateDay] [int] NULL,
	[StartDateMonth] [int] NULL,
	[StartDateYear] [int] NULL,
	[EndDateDay] [int] NULL,
	[EndDateMonth] [int] NULL,
	[EndDateYear] [int] NULL,
	[AproximateDate] [nvarchar](250) NULL,
	[FilmingExtentId] [int] NULL,
	[Source] [nvarchar](250) NULL,
	[InventoryNumber] [nvarchar](50) NOT NULL,
	[FramesCount] [int] NULL,
	[MicrofilmNegativeCount] [int] NULL,
	[MicrofilmPositiveCount] [int] NULL,
	[PhotoCopy] [nvarchar](250) NULL,
	[DigitalCopy] [nvarchar](250) NULL,
	[Size] [nvarchar](250) NULL,
	[Other] [nvarchar](max) NULL,
	[Notes] [nvarchar](max) NULL,
	[DocumentsFormat] [nvarchar](250) NULL,
	[DocumentsCharacteristics] [nvarchar](max) NULL,
 CONSTRAINT [PK_FilmCardDrafts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FilmCards]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FilmCards](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[FilmId] [int] NULL,
	[FilmSystemIdentifier] [uniqueidentifier] NOT NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
	[ArchiveId] [int] NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[CountryId] [int] NULL,
	[City] [nvarchar](250) NULL,
	[DocumentsCypher] [nvarchar](2000) NULL,
	[Title] [nvarchar](500) NULL,
	[ArchiveOriginals] [nvarchar](2000) NULL,
	[StartDateDay] [int] NULL,
	[StartDateMonth] [int] NULL,
	[StartDateYear] [int] NULL,
	[EndDateDay] [int] NULL,
	[EndDateMonth] [int] NULL,
	[EndDateYear] [int] NULL,
	[AproximateDate] [nvarchar](250) NULL,
	[FilmingExtentId] [int] NULL,
	[Source] [nvarchar](250) NULL,
	[InventoryNumber] [nvarchar](50) NOT NULL,
	[FramesCount] [int] NULL,
	[MicrofilmNegativeCount] [int] NULL,
	[MicrofilmPositiveCount] [int] NULL,
	[PhotoCopy] [nvarchar](250) NULL,
	[DigitalCopy] [nvarchar](250) NULL,
	[Size] [nvarchar](250) NULL,
	[Other] [nvarchar](max) NULL,
	[Notes] [nvarchar](max) NULL,
	[DocumentsFormat] [nvarchar](250) NULL,
	[DocumentsCharacteristics] [nvarchar](max) NULL,
 CONSTRAINT [PK_FilmCards] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FilmDrafts]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FilmDrafts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ArchiveId] [int] NOT NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
	[ReadOnly] [bit] NOT NULL,
	[WorkflowTypeCode] [nvarchar](50) NULL,
	[WorkflowId] [int] NULL,
	[WorkflowStepTypeCode] [nvarchar](50) NULL,
	[WorkflowStepId] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalIdentifier] [int] NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[InventoryNumber] [int] NOT NULL,
	[CountryId] [int] NULL,
	[FramesCount] [int] NULL,
	[MicrofilmNegativeRollsCount] [int] NULL,
	[MicrofilmNegativeFramesCount] [int] NULL,
	[MicrofilmPositiveRollsCount] [int] NULL,
	[MicrofilmPositiveFramesCount] [int] NULL,
	[PhotoCopy] [nvarchar](250) NULL,
	[DigitalCopy] [nvarchar](250) NULL,
	[Size] [nvarchar](250) NULL,
	[Other] [nvarchar](max) NULL,
	[AcceptedOnDay] [int] NULL,
	[AcceptedOnMonth] [int] NULL,
	[AcceptedOnYear] [int] NULL,
	[Source] [nvarchar](250) NULL,
	[Content] [nvarchar](max) NULL,
	[Notes] [nvarchar](max) NULL,
	[PackageAId] [int] NULL,
	[PackageBId] [int] NULL,
 CONSTRAINT [PK_FilmDrafts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FilmPackageDocuments]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FilmPackageDocuments](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PackageId] [int] NOT NULL,
	[DocumentTypeId] [int] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[FileId] [nvarchar](450) NULL,
	[FilePath] [nvarchar](450) NULL,
	[FileName] [nvarchar](500) NULL,
	[FileType] [nvarchar](10) NULL,
	[ContentType] [nvarchar](max) NULL,
	[FileSizeInBytes] [bigint] NULL,
	[FileLocation] [int] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[CopiedFromId] [int] NULL,
	[HashCode] [nvarchar](100) NULL,
 CONSTRAINT [PK_FilmPackageDocuments] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FilmPackages]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FilmPackages](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [nvarchar](1) NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
 CONSTRAINT [PK_FilmPackages] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FilmReviews]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FilmReviews](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[ReaderName] [nvarchar](256) NOT NULL,
	[FilmSystemIdentifier] [uniqueidentifier] NOT NULL,
	[AccessAllowed] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Films]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Films](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalIdentifier] [int] NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
	[ArchiveId] [int] NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[InventoryNumber] [int] NOT NULL,
	[CountryId] [int] NULL,
	[FramesCount] [int] NULL,
	[MicrofilmNegativeRollsCount] [int] NULL,
	[MicrofilmNegativeFramesCount] [int] NULL,
	[MicrofilmPositiveRollsCount] [int] NULL,
	[MicrofilmPositiveFramesCount] [int] NULL,
	[PhotoCopy] [nvarchar](250) NULL,
	[DigitalCopy] [nvarchar](250) NULL,
	[Size] [nvarchar](250) NULL,
	[Other] [nvarchar](max) NULL,
	[AcceptedOnDay] [int] NULL,
	[AcceptedOnMonth] [int] NULL,
	[AcceptedOnYear] [int] NULL,
	[Source] [nvarchar](250) NULL,
	[Content] [nvarchar](max) NULL,
	[Notes] [nvarchar](max) NULL,
	[PackageAId] [int] NULL,
	[PackageBId] [int] NULL,
 CONSTRAINT [PK_Film] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UI_FilmSystemIdentifier] UNIQUE NONCLUSTERED 
(
	[SystemIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FundDrafts]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FundDrafts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ArchiveId] [int] NOT NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
	[ReadOnly] [bit] NOT NULL,
	[WorkflowTypeCode] [nvarchar](50) NULL,
	[WorkflowId] [int] NULL,
	[WorkflowStepTypeCode] [nvarchar](50) NULL,
	[WorkflowStepId] [int] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
	[NumberArray] [nvarchar](50) NULL,
	[Number] [nvarchar](50) NULL,
	[Title] [nvarchar](max) NOT NULL,
	[DescriptionLevelCode] [nvarchar](50) NULL,
	[TypeCode] [nvarchar](50) NULL,
	[StatusCode] [nvarchar](50) NULL,
	[HasNoChronologicalScope] [bit] NOT NULL,
	[StartDateYear] [int] NULL,
	[StartDateMonth] [int] NULL,
	[StartDateDay] [int] NULL,
	[EndDateYear] [int] NULL,
	[EndDateMonth] [int] NULL,
	[EndDateDay] [int] NULL,
	[ApproxmateChronologicalScope] [nvarchar](256) NULL,
	[Bytes] [bigint] NULL,
	[LinearMeters] [float] NULL,
	[OtherMetrics] [nvarchar](256) NULL,
	[InventoryCount] [int] NULL,
	[ArchivalEntityCount] [int] NULL,
	[DocumentCount] [int] NULL,
	[FundCreatorTitleHistory] [nvarchar](max) NULL,
	[FundCreatorActivityHistory] [nvarchar](max) NULL,
	[FundCreatorBiographicalHistory] [nvarchar](max) NULL,
	[DocumentsProvider] [nvarchar](max) NULL,
	[DocumentsDescription] [nvarchar](max) NULL,
	[ValuableDocumentsInventoryCount] [nvarchar](max) NULL,
	[InvaluableDocumentsInventoryCount] [nvarchar](max) NULL,
	[DocumentsAccessDescription] [nvarchar](max) NULL,
	[History] [nvarchar](max) NULL,
	[RelatedFunds] [nvarchar](max) NULL,
	[Notes] [nvarchar](max) NULL,
	[EnrolledBytes] [bigint] NULL,
	[EnrolledInventoryCount] [bigint] NULL,
	[DeductedBytes] [bigint] NULL,
	[DeductedInventoryCount] [bigint] NULL,
	[ApplicationId] [int] NULL,
 CONSTRAINT [PK_FundDrafts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FundReconstructions]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FundReconstructions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProcessId] [int] NOT NULL,
	[ArchiveId] [int] NOT NULL,
	[FundSystemIdentifier] [uniqueidentifier] NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[SourceInventorySystemIdentifier] [uniqueidentifier] NULL,
	[SourceArchivalEntitySystemIdentifier] [uniqueidentifier] NULL,
	[SourceDocumentSystemIdentifier] [uniqueidentifier] NULL,
	[TargetInventorySystemIdentifier] [uniqueidentifier] NULL,
	[TargetArchivalEntitySystemIdentifier] [uniqueidentifier] NULL,
	[TargetDocumentSystemIdentifier] [uniqueidentifier] NULL,
	[AvailabilityStatusCode] [int] NULL,
 CONSTRAINT [PK_FundReconstructions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Funds]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Funds](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ArchiveId] [int] NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
	[NumberArray] [nvarchar](50) NULL,
	[Number] [nvarchar](50) NULL,
	[Title] [nvarchar](max) NOT NULL,
	[DescriptionLevelCode] [nvarchar](50) NULL,
	[TypeCode] [nvarchar](50) NULL,
	[StatusCode] [nvarchar](50) NULL,
	[HasNoChronologicalScope] [bit] NOT NULL,
	[StartDateYear] [int] NULL,
	[StartDateMonth] [int] NULL,
	[StartDateDay] [int] NULL,
	[EndDateYear] [int] NULL,
	[EndDateMonth] [int] NULL,
	[EndDateDay] [int] NULL,
	[ApproxmateChronologicalScope] [nvarchar](256) NULL,
	[Bytes] [bigint] NULL,
	[LinearMeters] [float] NULL,
	[OtherMetrics] [nvarchar](256) NULL,
	[InventoryCount] [int] NULL,
	[ArchivalEntityCount] [int] NULL,
	[DocumentCount] [int] NULL,
	[FundCreatorTitleHistory] [nvarchar](max) NULL,
	[FundCreatorActivityHistory] [nvarchar](max) NULL,
	[FundCreatorBiographicalHistory] [nvarchar](max) NULL,
	[DocumentsProvider] [nvarchar](max) NULL,
	[DocumentsDescription] [nvarchar](max) NULL,
	[ValuableDocumentsInventoryCount] [nvarchar](max) NULL,
	[InvaluableDocumentsInventoryCount] [nvarchar](max) NULL,
	[DocumentsAccessDescription] [nvarchar](max) NULL,
	[History] [nvarchar](max) NULL,
	[RelatedFunds] [nvarchar](max) NULL,
	[Notes] [nvarchar](max) NULL,
	[EnrolledBytes] [bigint] NULL,
	[EnrolledInventoryCount] [bigint] NULL,
	[DeductedBytes] [bigint] NULL,
	[DeductedInventoryCount] [bigint] NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[Registered] [bit] NOT NULL,
	[Locked] [bit] NOT NULL,
	[LockedByProcessId] [int] NULL,
	[ApplicationId] [int] NULL,
	[IsSuspended] [bit] NOT NULL,
 CONSTRAINT [PK_Funds] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UI_FundSystemIdentifier] UNIQUE NONCLUSTERED 
(
	[SystemIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Inventories]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Inventories](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ArchiveId] [int] NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
	[NumberArray] [nvarchar](10) NULL,
	[Number] [nvarchar](50) NULL,
	[DescriptionLevelCode] [nvarchar](50) NULL,
	[StatusCode] [nvarchar](50) NULL,
	[HasNoChronologicalScope] [bit] NOT NULL,
	[StartDateYear] [int] NULL,
	[StartDateMonth] [int] NULL,
	[StartDateDay] [int] NULL,
	[EndDateYear] [int] NULL,
	[EndDateMonth] [int] NULL,
	[EndDateDay] [int] NULL,
	[ApproxmateChronologicalScope] [nvarchar](256) NULL,
	[Bytes] [bigint] NULL,
	[LinearMeters] [float] NULL,
	[OtherMetrics] [nvarchar](256) NULL,
	[ArchivalEntityCount] [int] NULL,
	[DocumentCount] [int] NULL,
	[BoxCount] [int] NULL,
	[RollCount] [int] NULL,
	[AudioDocumentArchivalEntityCount] [int] NULL,
	[PhotoDocumentArchivalEntityCount] [int] NULL,
	[VideoDocumentArchivalEntityCount] [int] NULL,
	[DigitalDocumentArchivalEntityCount] [int] NULL,
	[FundCreatorTitleHistory] [nvarchar](max) NULL,
	[FundCreatorBiographicalHistory] [nvarchar](max) NULL,
	[History] [nvarchar](max) NULL,
	[DocumentsProvider] [nvarchar](max) NULL,
	[DocumentsDescription] [nvarchar](max) NULL,
	[DocumentsAccessDescription] [nvarchar](max) NULL,
	[ClassificationScheme] [nvarchar](max) NULL,
	[AbbreviationList] [nvarchar](max) NULL,
	[MicrofilmedArchivalEntityCount] [int] NULL,
	[DigitizedArchivalEntityCount] [int] NULL,
	[NegativeFrameCount] [int] NULL,
	[PositiveFrameCount] [int] NULL,
	[Notes] [nvarchar](max) NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[FundSystemIdentifier] [uniqueidentifier] NOT NULL,
	[Registered] [bit] NOT NULL,
	[Locked] [bit] NOT NULL,
	[LockedByProcessId] [int] NULL,
	[ApplicationId] [int] NULL,
	[PackageAId] [int] NULL,
	[PackageBId] [int] NULL,
	[IsSuspended] [bit] NOT NULL,
	[AvailabilityStatusCode] [int] NULL,
 CONSTRAINT [PK_Inventories] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UI_InventorySystemIdentifier] UNIQUE NONCLUSTERED 
(
	[SystemIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryDrafts]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryDrafts](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[ArchiveId] [int] NOT NULL,
	[FundDraftId] [int] NULL,
	[FundSystemIdentifier] [uniqueidentifier] NOT NULL,
	[IsCurrent] [bit] NOT NULL,
	[ReadOnly] [bit] NOT NULL,
	[WorkflowTypeCode] [nvarchar](50) NULL,
	[WorkflowId] [int] NULL,
	[WorkflowStepTypeCode] [nvarchar](50) NULL,
	[WorkflowStepId] [int] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
	[NumberArray] [nvarchar](10) NULL,
	[Number] [nvarchar](50) NULL,
	[DescriptionLevelCode] [nvarchar](50) NULL,
	[StatusCode] [nvarchar](50) NULL,
	[HasNoChronologicalScope] [bit] NOT NULL,
	[StartDateYear] [int] NULL,
	[StartDateMonth] [int] NULL,
	[StartDateDay] [int] NULL,
	[EndDateYear] [int] NULL,
	[EndDateMonth] [int] NULL,
	[EndDateDay] [int] NULL,
	[ApproxmateChronologicalScope] [nvarchar](256) NULL,
	[Bytes] [bigint] NULL,
	[LinearMeters] [float] NULL,
	[OtherMetrics] [nvarchar](256) NULL,
	[ArchivalEntityCount] [int] NULL,
	[DocumentCount] [int] NULL,
	[BoxCount] [int] NULL,
	[RollCount] [int] NULL,
	[AudioDocumentArchivalEntityCount] [int] NULL,
	[PhotoDocumentArchivalEntityCount] [int] NULL,
	[VideoDocumentArchivalEntityCount] [int] NULL,
	[DigitalDocumentArchivalEntityCount] [int] NULL,
	[FundCreatorTitleHistory] [nvarchar](max) NULL,
	[FundCreatorBiographicalHistory] [nvarchar](max) NULL,
	[History] [nvarchar](max) NULL,
	[DocumentsProvider] [nvarchar](max) NULL,
	[DocumentsDescription] [nvarchar](max) NULL,
	[DocumentsAccessDescription] [nvarchar](max) NULL,
	[ClassificationScheme] [nvarchar](max) NULL,
	[AbbreviationList] [nvarchar](max) NULL,
	[MicrofilmedArchivalEntityCount] [int] NULL,
	[DigitizedArchivalEntityCount] [int] NULL,
	[NegativeFrameCount] [int] NULL,
	[PositiveFrameCount] [int] NULL,
	[Notes] [nvarchar](max) NULL,
	[ApplicationId] [int] NULL,
	[PackageAId] [int] NULL,
	[PackageBId] [int] NULL,
	[AvailabilityStatusCode] [int] NULL,
 CONSTRAINT [PK_InventoryDrafts] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[InventoryRawToNormal]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[InventoryRawToNormal](
	[ArchiveId] [int] NOT NULL,
	[FundSystemIdentifier] [uniqueidentifier] NOT NULL,
	[RawInventorySystemIdentifier] [uniqueidentifier] NOT NULL,
	[NormalInventorySystemIdentifier] [uniqueidentifier] NULL,
	[ProcessId] [int] NULL,
	[IsRejected] [bit] NOT NULL,
	[Id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_InventoryRawToNormal] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[NomenclatureValues]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NomenclatureValues](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[EntityId] [int] NOT NULL,
	[EntityType] [nvarchar](50) NOT NULL,
	[NomenclatureId] [int] NOT NULL,
	[NomenclatureCode] [nvarchar](50) NOT NULL,
	[ValueId] [int] NOT NULL,
	[ValueCode] [nvarchar](50) NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[EntityIsDraft] [bit] NOT NULL,
 CONSTRAINT [PK_NomenclatureValues] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PackageADocsTemplates]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PackageADocsTemplates](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProcedureId] [int] NOT NULL,
	[DocumentId] [int] NOT NULL,
	[Required] [bit] NOT NULL,
	[Sort] [int] NOT NULL,
	[Title] [nvarchar](500) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
 CONSTRAINT [PK_PackageADocsTemplates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PackageDocument]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PackageDocument](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[PackageId] [int] NOT NULL,
	[Description] [nvarchar](max) NULL,
	[DocTypeId] [int] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[FileId] [nvarchar](450) NULL,
	[FilePath] [nvarchar](450) NULL,
	[FileName] [nvarchar](500) NULL,
	[FileType] [nvarchar](10) NULL,
	[ContentType] [nvarchar](max) NULL,
	[FileSizeInBytes] [bigint] NULL,
	[FileLocation] [int] NULL,
 CONSTRAINT [PK_PackageDocument] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Packages]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Packages](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Type] [nvarchar](1) NOT NULL,
	[InventoryIdentifier] [uniqueidentifier] NULL,
	[ApplicationId] [int] NULL,
	[Approved] [bit] NULL,
	[ApprovedBy] [uniqueidentifier] NULL,
	[ApprovedOn] [datetime2](7) NULL,
	[RejectReason] [nvarchar](max) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Packages] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Process]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Process](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProcessTypeId] [int] NOT NULL,
	[ArchiveId] [int] NULL,
	[DocumentId] [int] NULL,
	[InventoryId] [int] NULL,
	[Completed] [bit] NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[FundId] [int] NULL,
	[ArchivalEntityId] [int] NULL,
	[FilmSystemIdentifier] [uniqueidentifier] NULL,
	[FundSystemIdentifier] [uniqueidentifier] NULL,
	[InventorySystemIdentifier] [uniqueidentifier] NULL,
	[ArchivalEntitySystemIdentifier] [uniqueidentifier] NULL,
	[DocumentSystemIdentifier] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Process] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProcessRelatedSteps]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProcessRelatedSteps](
	[ProcessTypeId] [int] NOT NULL,
	[StepId] [int] NOT NULL,
	[NextStepId] [int] NULL,
	[PrevStepId] [int] NULL,
	[AsigneeGoups] [nvarchar](150) NULL,
 CONSTRAINT [PK_ProcessRelatedSteps] PRIMARY KEY CLUSTERED 
(
	[ProcessTypeId] ASC,
	[StepId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProcessTimeline]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProcessTimeline](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProcessId] [int] NOT NULL,
	[StepTypeId] [int] NOT NULL,
	[Completed] [bit] NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[Comment] [nvarchar](1000) NULL,
	[AssignedToUserId] [uniqueidentifier] NULL,
	[AssignedToRoleId] [uniqueidentifier] NULL,
	[EndDate] [datetime2](7) NULL,
 CONSTRAINT [PK_ProcessTimeline] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SessionAgenda]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SessionAgenda](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProcessId] [int] NULL,
	[SessionId] [int] NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[ReportId] [int] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
 CONSTRAINT [PK_SessionAgenda] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SessionAgendaStandpoints]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SessionAgendaStandpoints](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SessionAgendaItemId] [int] NOT NULL,
	[Content] [nvarchar](max) NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[IsDraft] [bit] NOT NULL,
 CONSTRAINT [PK_SessionAgendaStandpoints] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SessionDecisions]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SessionDecisions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProtocolDate] [datetime2](7) NULL,
	[ProtocolNumber] [int] NULL,
	[DeadlineForApproval] [datetime2](7) NULL,
	[SessionAgendaId] [int] NOT NULL,
	[DecisionText] [nvarchar](max) NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[IsDraft] [bit] NOT NULL,
 CONSTRAINT [PK_SessionDecisions] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SessionMinutesOfMeeting]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SessionMinutesOfMeeting](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Number] [nvarchar](50) NOT NULL,
	[NumberNumeric] [int] NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[Content] [nvarchar](max) NOT NULL,
	[IsDraft] [bit] NOT NULL,
	[UncPath] [nvarchar](max) NULL,
	[Status] [nvarchar](50) NULL,
	[RejectReason] [nvarchar](max) NULL,
 CONSTRAINT [PK_SessionMinutesOfMeeting] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sessions]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sessions](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SessionDate] [datetime2](7) NOT NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[DeletedOn] [datetime2](7) NULL,
	[Deleted] [bit] NOT NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[MinutesOfMeetingId] [int] NULL,
	[ArchiveId] [int] NOT NULL,
	[SessionType] [nvarchar](100) NULL,
	[AssignedToChairmanId] [uniqueidentifier] NULL,
	[AssignedToSecretarId] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Session] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Tasks]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tasks](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProcessId] [int] NULL,
	[StepId] [int] NULL,
	[Title] [nvarchar](255) NULL,
	[Description] [nvarchar](max) NULL,
	[AssignedToUserId] [uniqueidentifier] NOT NULL,
	[EndDate] [datetime2](7) NULL,
	[RelatedEntityId] [int] NULL,
	[RelatedEntitySystemIdentifier] [uniqueidentifier] NULL,
	[RelatedEntityType] [nvarchar](50) NOT NULL,
	[RelatedContentUrl] [nvarchar](255) NULL,
	[StatusCode] [nvarchar](50) NOT NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
 CONSTRAINT [PK_Tasks] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TaskTemplates]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaskTemplates](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProcessStepTypeId] [int] NULL,
	[Title] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](max) NOT NULL,
	[RelatedContentUrl] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_TaskTemplates] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TaskTemplatesSteps]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TaskTemplatesSteps](
	[TaskTemplate_Id] [int] NOT NULL,
	[ProcessStep_Id] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[TaskTemplate_Id] ASC,
	[ProcessStep_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ValuableDocsCollectingProcedures]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValuableDocsCollectingProcedures](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TypeId] [int] NOT NULL,
	[ArchiveId] [int] NOT NULL,
	[FundId] [int] NULL,
	[InventoryId] [int] NULL,
	[PackageAId] [int] NULL,
	[PackageBId] [int] NULL,
	[RequestId] [int] NULL,
	[StatusCode] [nvarchar](50) NOT NULL,
	[RedirectedTo] [nvarchar](500) NULL,
	[RedirectedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[DeletedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_ValuableDocsCollectingProcedure] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ValuableDocsCollectingProceduresHistory]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValuableDocsCollectingProceduresHistory](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProcId] [int] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[Action] [nvarchar](max) NOT NULL,
	[Date] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_ValuableDocsCollectingProceduresHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ValuableDocsCollectingProceduresSteps]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValuableDocsCollectingProceduresSteps](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ProcId] [int] NOT NULL,
	[StepId] [int] NOT NULL,
	[ResultNote] [int] NULL,
	[ResponsibleUserId] [uniqueidentifier] NOT NULL,
 CONSTRAINT [PK_ValuableDocsCollectingProceduresSteps] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ValuableDocsCollectingRequest]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ValuableDocsCollectingRequest](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Approved] [bit] NULL,
	[ApprovedBy] [uniqueidentifier] NULL,
	[ApprovedOn] [datetime2](7) NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[CreatedBy] [uniqueidentifier] NOT NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[DeletedOn] [datetime2](7) NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
 CONSTRAINT [PK_ValuableDocsCollectingRequest] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[AggregatedCounter]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[AggregatedCounter](
	[Key] [nvarchar](100) NOT NULL,
	[Value] [bigint] NOT NULL,
	[ExpireAt] [datetime] NULL,
 CONSTRAINT [PK_HangFire_CounterAggregated] PRIMARY KEY CLUSTERED 
(
	[Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Counter]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Counter](
	[Key] [nvarchar](100) NOT NULL,
	[Value] [int] NOT NULL,
	[ExpireAt] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Hash]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Hash](
	[Key] [nvarchar](100) NOT NULL,
	[Field] [nvarchar](100) NOT NULL,
	[Value] [nvarchar](max) NULL,
	[ExpireAt] [datetime2](7) NULL,
 CONSTRAINT [PK_HangFire_Hash] PRIMARY KEY CLUSTERED 
(
	[Key] ASC,
	[Field] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Job]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Job](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[StateId] [bigint] NULL,
	[StateName] [nvarchar](20) NULL,
	[InvocationData] [nvarchar](max) NOT NULL,
	[Arguments] [nvarchar](max) NOT NULL,
	[CreatedAt] [datetime] NOT NULL,
	[ExpireAt] [datetime] NULL,
 CONSTRAINT [PK_HangFire_Job] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[JobParameter]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[JobParameter](
	[JobId] [bigint] NOT NULL,
	[Name] [nvarchar](40) NOT NULL,
	[Value] [nvarchar](max) NULL,
 CONSTRAINT [PK_HangFire_JobParameter] PRIMARY KEY CLUSTERED 
(
	[JobId] ASC,
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[JobQueue]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[JobQueue](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[JobId] [bigint] NOT NULL,
	[Queue] [nvarchar](50) NOT NULL,
	[FetchedAt] [datetime] NULL,
 CONSTRAINT [PK_HangFire_JobQueue] PRIMARY KEY CLUSTERED 
(
	[Queue] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[List]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[List](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Key] [nvarchar](100) NOT NULL,
	[Value] [nvarchar](max) NULL,
	[ExpireAt] [datetime] NULL,
 CONSTRAINT [PK_HangFire_List] PRIMARY KEY CLUSTERED 
(
	[Key] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Schema]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Schema](
	[Version] [int] NOT NULL,
 CONSTRAINT [PK_HangFire_Schema] PRIMARY KEY CLUSTERED 
(
	[Version] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Server]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Server](
	[Id] [nvarchar](200) NOT NULL,
	[Data] [nvarchar](max) NULL,
	[LastHeartbeat] [datetime] NOT NULL,
 CONSTRAINT [PK_HangFire_Server] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[Set]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[Set](
	[Key] [nvarchar](100) NOT NULL,
	[Score] [float] NOT NULL,
	[Value] [nvarchar](256) NOT NULL,
	[ExpireAt] [datetime] NULL,
 CONSTRAINT [PK_HangFire_Set] PRIMARY KEY CLUSTERED 
(
	[Key] ASC,
	[Value] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [HangFire].[State]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [HangFire].[State](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[JobId] [bigint] NOT NULL,
	[Name] [nvarchar](20) NOT NULL,
	[Reason] [nvarchar](100) NULL,
	[CreatedAt] [datetime] NOT NULL,
	[Data] [nvarchar](max) NULL,
 CONSTRAINT [PK_HangFire_State] PRIMARY KEY CLUSTERED 
(
	[JobId] ASC,
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [N].[ArchivalEntityDescriptionLevel]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[ArchivalEntityDescriptionLevel](
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[SortOrder] [int] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_EntityDescriptionLevel] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [N].[AvailabilityStatus]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[AvailabilityStatus](
	[Code] [int] NOT NULL,
	[Text] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[SortOrder] [int] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_AvailabilityStatus] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [N].[DocsCollectingProcedureSteps]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[DocsCollectingProcedureSteps](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](500) NOT NULL,
	[Sort] [nchar](10) NOT NULL,
	[ResponsibleUserType] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_DocsCollectingProcedureSteps] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [N].[DocsCollectingProcedureTypes]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[DocsCollectingProcedureTypes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](max) NOT NULL,
 CONSTRAINT [PK_DocsCollectingProcedureTypes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [N].[DocumentDescriptionLevel]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[DocumentDescriptionLevel](
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[SortOrder] [int] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_DocumentDescriptionLevel] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [N].[EDocsCollectingApplicationStatuses]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[EDocsCollectingApplicationStatuses](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Text] [nvarchar](50) NOT NULL,
	[TextEn] [nvarchar](50) NULL,
 CONSTRAINT [PK_EDocsCollectingApplicationStatuses] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [N].[EDocsCollectingApplicationTypes]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[EDocsCollectingApplicationTypes](
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](150) NOT NULL,
	[TextEn] [nvarchar](150) NOT NULL,
 CONSTRAINT [PK_EDocsCollectingApplicationTypes] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [N].[FilmDocumentType]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[FilmDocumentType](
	[Id] [int] NOT NULL,
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](250) NOT NULL,
	[PackageType] [nvarchar](1) NOT NULL,
	[IsRequired] [bit] NOT NULL,
 CONSTRAINT [PK_N.FilmDocumentType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [N].[FundArray]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[FundArray](
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[SortOrder] [int] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_FundArray] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [N].[FundDescriptionLevel]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[FundDescriptionLevel](
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[SortOrder] [int] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_FundDescriptionLevel] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [N].[FundType]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[FundType](
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[SortOrder] [int] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_FundType] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [N].[InventoryArray]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[InventoryArray](
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[SortOrder] [int] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_InventoryArray] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [N].[InventoryDescriptionLevel]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[InventoryDescriptionLevel](
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[SortOrder] [int] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_InventoryDescriptionLevel] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [N].[NomenclatureCode]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[NomenclatureCode](
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[SortOrder] [int] NULL,
 CONSTRAINT [PK_NomenclatureCode] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [N].[Nomenclatures]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[Nomenclatures](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ParentId] [int] NULL,
	[CreatedOn] [datetime2](7) NULL,
	[CreatedBy] [uniqueidentifier] NULL,
	[UpdatedOn] [datetime2](7) NULL,
	[UpdatedBy] [uniqueidentifier] NULL,
	[Deleted] [bit] NOT NULL,
	[DeletedOn] [datetime2](7) NULL,
	[DeletedBy] [uniqueidentifier] NULL,
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[SortOrder] [int] NULL,
	[Inactive] [bit] NOT NULL,
	[Locked] [bit] NOT NULL,
 CONSTRAINT [PK_Nomenclatures] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [N].[NotificationType]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[NotificationType](
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](256) NOT NULL,
 CONSTRAINT [PK_N.NotificationType] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [N].[ProcessSteps]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[ProcessSteps](
	[Id] [int] NOT NULL,
	[ProcessTypeId] [int] NULL,
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](250) NOT NULL,
 CONSTRAINT [PK_N.ProcessStep] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [N].[ProcessTypes]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[ProcessTypes](
	[Id] [int] NOT NULL,
	[Type] [nvarchar](50) NOT NULL,
	[Name] [nvarchar](max) NOT NULL,
	[Code] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_ProcessType] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [N].[ReportResultType]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[ReportResultType](
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](256) NOT NULL,
 CONSTRAINT [PK_ReportResultType] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [N].[SessionTypes]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[SessionTypes](
	[Code] [nvarchar](100) NOT NULL,
	[Text] [nvarchar](250) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [N].[Status]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[Status](
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[SortOrder] [int] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
	[ExternalSourceUpdatedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_N.Status] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [N].[TaskStatus]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [N].[TaskStatus](
	[Code] [nvarchar](50) NOT NULL,
	[Text] [nvarchar](255) NOT NULL,
	[Description] [nvarchar](max) NULL,
	[SortOrder] [int] NULL,
	[ExternalIdentifier] [int] NULL,
	[HasExternalSource] [bit] NOT NULL,
 CONSTRAINT [PK_TaskStatus] PRIMARY KEY CLUSTERED 
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Notification].[Notification]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Notification].[Notification](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[NotificationTemplateId] [int] NOT NULL,
	[ToUserId] [uniqueidentifier] NOT NULL,
	[To] [nvarchar](max) NOT NULL,
	[Subject] [nvarchar](450) NULL,
	[Body] [nvarchar](max) NULL,
	[CreatedOn] [datetime2](7) NOT NULL,
	[SentOn] [datetime2](7) NULL,
	[IsSeen] [bit] NOT NULL,
	[IsSent] [bit] NOT NULL,
 CONSTRAINT [PK_Notification] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [Notification].[NotificationEvent]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Notification].[NotificationEvent](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ObjectId] [int] NOT NULL,
	[NotificationTypeCode] [nvarchar](50) NOT NULL,
	[IsChecked] [bit] NOT NULL,
	[CheckedOn] [datetime2](7) NULL,
 CONSTRAINT [PK_NotificationEvent] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Notification].[NotificationTemplate]    Script Date: 30.11.2022 г. 10:53:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Notification].[NotificationTemplate](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[NotificationTypeCode] [nvarchar](50) NOT NULL,
	[Subject] [nvarchar](450) NULL,
	[Body] [nvarchar](max) NULL,
 CONSTRAINT [PK_NotificationTemplate] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

--INDEXES
/****** Object:  Index [UI_IsCurrentDraft] ******/
CREATE UNIQUE NONCLUSTERED INDEX [UI_IsCurrentDraft] ON [dbo].[ArchivalEntityDrafts]
(
	[SystemIdentifier] ASC
)
WHERE ([IsCurrent]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UI_ArchiveCode] ******/
CREATE UNIQUE NONCLUSTERED INDEX [UI_ArchiveCode] ON [dbo].[Archives]
(
	[Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_AspNetRoleClaims_RoleId] ******/
CREATE NONCLUSTERED INDEX [IX_AspNetRoleClaims_RoleId] ON [dbo].[AspNetRoleClaims]
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [RoleNameIndex] ******/
CREATE UNIQUE NONCLUSTERED INDEX [RoleNameIndex] ON [dbo].[AspNetRoles]
(
	[ArchiveId] ASC,
	[NormalizedName] ASC
)
WHERE ([NormalizedName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_AspNetUserClaims_UserId] ******/
CREATE NONCLUSTERED INDEX [IX_AspNetUserClaims_UserId] ON [dbo].[AspNetUserClaims]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_AspNetUserLogins_UserId]    ******/
CREATE NONCLUSTERED INDEX [IX_AspNetUserLogins_UserId] ON [dbo].[AspNetUserLogins]
(
	[UserId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_AspNetUserRoles_RoleId]    Script Date: 31.1.2023 г. 19:17:03 ******/
CREATE NONCLUSTERED INDEX [IX_AspNetUserRoles_RoleId] ON [dbo].[AspNetUserRoles]
(
	[RoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [EmailIndex]    Script Date: 31.1.2023 г. 19:17:03 ******/
CREATE NONCLUSTERED INDEX [EmailIndex] ON [dbo].[AspNetUsers]
(
	[NormalizedEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UserNameIndex]    Script Date: 31.1.2023 г. 19:17:03 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UserNameIndex] ON [dbo].[AspNetUsers]
(
	[NormalizedUserName] ASC
)
WHERE ([NormalizedUserName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UI_IsCurrentDraft]    Script Date: 31.1.2023 г. 19:17:03 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UI_IsCurrentDraft] ON [dbo].[DigitalObjectDrafts]
(
	[SystemIdentifier] ASC
)
WHERE ([IsCurrent]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UI_IsCurrentDraft]    Script Date: 31.1.2023 г. 19:17:03 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UI_IsCurrentDraft] ON [dbo].[DocumentDrafts]
(
	[SystemIdentifier] ASC
)
WHERE ([IsCurrent]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UI_IsCurrentDraft]    Script Date: 31.1.2023 г. 19:17:03 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UI_IsCurrentDraft] ON [dbo].[FilmCardDrafts]
(
	[SystemIdentifier] ASC
)
WHERE ([IsCurrent]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UI_IsCurrentDraft]    Script Date: 31.1.2023 г. 19:17:03 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UI_IsCurrentDraft] ON [dbo].[FilmDrafts]
(
	[SystemIdentifier] ASC
)
WHERE ([IsCurrent]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [ID_FilmReviews]    Script Date: 31.1.2023 г. 19:17:03 ******/
CREATE UNIQUE NONCLUSTERED INDEX [ID_FilmReviews] ON [dbo].[FilmReviews]
(
	[SystemIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UI_IsCurrentDraft]    Script Date: 31.1.2023 г. 19:17:03 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UI_IsCurrentDraft] ON [dbo].[FundDrafts]
(
	[SystemIdentifier] ASC
)
WHERE ([IsCurrent]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UI_IsCurrentDraft]    Script Date: 31.1.2023 г. 19:17:03 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UI_IsCurrentDraft] ON [dbo].[InventoryDrafts]
(
	[SystemIdentifier] ASC
)
WHERE ([IsCurrent]=(1))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UI_NomenclatureValue_Entity]    Script Date: 31.1.2023 г. 19:17:03 ******/
CREATE UNIQUE NONCLUSTERED INDEX [UI_NomenclatureValue_Entity] ON [dbo].[NomenclatureValues]
(
	[EntityId] ASC,
	[EntityType] ASC,
	[EntityIsDraft] ASC,
	[NomenclatureId] ASC,
	[NomenclatureCode] ASC,
	[ValueId] ASC,
	[ValueCode] ASC
)
WHERE ([Deleted]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [CX_HangFire_Counter] ******/
CREATE CLUSTERED INDEX [CX_HangFire_Counter] ON [HangFire].[Counter]
(
	[Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_HangFire_AggregatedCounter_ExpireAt]    Script Date: 31.1.2023 г. 19:17:03 ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_AggregatedCounter_ExpireAt] ON [HangFire].[AggregatedCounter]
(
	[ExpireAt] ASC
)
WHERE ([ExpireAt] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_HangFire_Hash_ExpireAt]    Script Date: 31.1.2023 г. 19:17:03 ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_Hash_ExpireAt] ON [HangFire].[Hash]
(
	[ExpireAt] ASC
)
WHERE ([ExpireAt] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_HangFire_Job_ExpireAt]    Script Date: 31.1.2023 г. 19:17:03 ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_Job_ExpireAt] ON [HangFire].[Job]
(
	[ExpireAt] ASC
)
INCLUDE([StateName]) 
WHERE ([ExpireAt] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_HangFire_Job_StateName]    Script Date: 31.1.2023 г. 19:17:03 ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_Job_StateName] ON [HangFire].[Job]
(
	[StateName] ASC
)
WHERE ([StateName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_HangFire_List_ExpireAt] ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_List_ExpireAt] ON [HangFire].[List]
(
	[ExpireAt] ASC
)
WHERE ([ExpireAt] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_HangFire_Server_LastHeartbeat] ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_Server_LastHeartbeat] ON [HangFire].[Server]
(
	[LastHeartbeat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_HangFire_Set_ExpireAt] ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_Set_ExpireAt] ON [HangFire].[Set]
(
	[ExpireAt] ASC
)
WHERE ([ExpireAt] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_HangFire_Set_Score] ******/
CREATE NONCLUSTERED INDEX [IX_HangFire_Set_Score] ON [HangFire].[Set]
(
	[Key] ASC,
	[Score] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UI_Nomenclature_Code] ******/
CREATE UNIQUE NONCLUSTERED INDEX [UI_Nomenclature_Code] ON [N].[Nomenclatures]
(
	[ParentId] ASC,
	[Code] ASC
)
WHERE ([ParentId] IS NULL AND [Code] IS NOT NULL AND [Deleted]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UI_NomenclatureValue_Code] ******/
CREATE UNIQUE NONCLUSTERED INDEX [UI_NomenclatureValue_Code] ON [N].[Nomenclatures]
(
	[ParentId] ASC,
	[Code] ASC
)
WHERE ([ParentId] IS NOT NULL AND [Code] IS NOT NULL AND [Deleted]=(0))
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO

--DEFAULT CONSTRAINT
ALTER TABLE [A].[AuditEntries] ADD  CONSTRAINT [DF_AuditEntries_CreatedOn]  DEFAULT (getutcdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[ArchivalEntities] ADD  CONSTRAINT [DF_ArchivalEntity_IsSuspended]  DEFAULT ((0)) FOR [IsSuspended]
GO
ALTER TABLE [dbo].[AspNetUserProfiles] ADD  CONSTRAINT [DF_AspNetUserProfiles_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[AspNetUsers] ADD  CONSTRAINT [DF_AspNetUsers_CreatedOn]  DEFAULT (getdate()) FOR [CreatedOn]
GO
ALTER TABLE [dbo].[Comments] ADD  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[Comments] ADD  DEFAULT ((1)) FOR [IsDraft]
GO
ALTER TABLE [dbo].[DigitalObjects] ADD  CONSTRAINT [DF_DigitalObject_IsSuspended]  DEFAULT ((0)) FOR [IsSuspended]
GO
ALTER TABLE [dbo].[DocumentDigitalObjects] ADD  DEFAULT ((0)) FOR [Approved]
GO
ALTER TABLE [dbo].[DocumentDigitalObjects] ADD  DEFAULT ((0)) FOR [IsMaster]
GO
ALTER TABLE [dbo].[Documents] ADD  CONSTRAINT [DF_Document_IsSuspended]  DEFAULT ((0)) FOR [IsSuspended]
GO
ALTER TABLE [dbo].[EDocsCollectingApplication] ADD  CONSTRAINT [DF_EDocsCollectingApplication_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[EPKReports] ADD  DEFAULT ((0)) FOR [IsDraft]
GO
ALTER TABLE [dbo].[EPKReports] ADD  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[Files] ADD  CONSTRAINT [DF_Files_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[FilmCardDocuments] ADD  CONSTRAINT [DF_FilmCardDocument_IsDraft]  DEFAULT ((0)) FOR [IsDraft]
GO
ALTER TABLE [dbo].[FilmCardDrafts] ADD  CONSTRAINT [DF_FilmCardDrafts_HasExternalSource]  DEFAULT ((0)) FOR [HasExternalSource]
GO
ALTER TABLE [dbo].[FilmCards] ADD  CONSTRAINT [DF_FilmCards_HasExternalSource]  DEFAULT ((0)) FOR [HasExternalSource]
GO
ALTER TABLE [dbo].[FilmCards] ADD  CONSTRAINT [DF_FilmCards_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[FilmDrafts] ADD  CONSTRAINT [DF_FilmDraft_HasExternalSource]  DEFAULT ((0)) FOR [HasExternalSource]
GO
ALTER TABLE [dbo].[FilmPackageDocuments] ADD  CONSTRAINT [DF_FilmPackageDocuments_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[FilmPackages] ADD  CONSTRAINT [DF_FilmPackages_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[FilmReviews] ADD  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[FilmReviews] ADD  DEFAULT ((1)) FOR [AccessAllowed]
GO
ALTER TABLE [dbo].[Films] ADD  CONSTRAINT [DF_Film_HasExternalSource]  DEFAULT ((0)) FOR [HasExternalSource]
GO
ALTER TABLE [dbo].[Films] ADD  CONSTRAINT [DF_InventoryNumber_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[Funds] ADD  DEFAULT ((0)) FOR [Registered]
GO
ALTER TABLE [dbo].[Funds] ADD  DEFAULT ((0)) FOR [Locked]
GO
ALTER TABLE [dbo].[Funds] ADD  CONSTRAINT [DF_Fund_IsSuspended]  DEFAULT ((0)) FOR [IsSuspended]
GO
ALTER TABLE [dbo].[Inventories] ADD  DEFAULT ((0)) FOR [Registered]
GO
ALTER TABLE [dbo].[Inventories] ADD  DEFAULT ((0)) FOR [Locked]
GO
ALTER TABLE [dbo].[Inventories] ADD  CONSTRAINT [DF_Inventory_IsSuspended]  DEFAULT ((0)) FOR [IsSuspended]
GO
ALTER TABLE [dbo].[InventoryRawToNormal] ADD  CONSTRAINT [DF_InventoryRawToNormal_IsRejected]  DEFAULT ((0)) FOR [IsRejected]
GO
ALTER TABLE [dbo].[PackageADocsTemplates] ADD  CONSTRAINT [DF_PackageADocsTemplates_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[PackageDocument] ADD  CONSTRAINT [DF_PackageDocument_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[Packages] ADD  CONSTRAINT [DF_Packages_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[Process] ADD  CONSTRAINT [DF_FilmProcess_Completed]  DEFAULT ((0)) FOR [Completed]
GO
ALTER TABLE [dbo].[Process] ADD  CONSTRAINT [DF_FilmProcess_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[ProcessTimeline] ADD  CONSTRAINT [DF_FilmTimeline_Completed]  DEFAULT ((0)) FOR [Completed]
GO
ALTER TABLE [dbo].[SessionAgenda] ADD  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[SessionDecisions] ADD  CONSTRAINT [DF_SessionDecisions_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[SessionDecisions] ADD  CONSTRAINT [DF_SessionDecisions_IsDraft]  DEFAULT ((1)) FOR [IsDraft]
GO
ALTER TABLE [dbo].[SessionMinutesOfMeeting] ADD  CONSTRAINT [DF_SessionMinOfMeeting_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[SessionMinutesOfMeeting] ADD  CONSTRAINT [DF_SessionMinOfMeeting_IsDraft]  DEFAULT ((1)) FOR [IsDraft]
GO
ALTER TABLE [dbo].[Sessions] ADD  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[Tasks] ADD  CONSTRAINT [DF_Tasks_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProcedures] ADD  CONSTRAINT [DF_ValuableDocsCollectingProcedure_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [dbo].[ValuableDocsCollectingRequest] ADD  CONSTRAINT [DF_ValuableDocsCollectingRequest_Deleted]  DEFAULT ((0)) FOR [Deleted]
GO
ALTER TABLE [N].[FilmDocumentType] ADD  DEFAULT ((0)) FOR [IsRequired]
GO
ALTER TABLE [N].[TaskStatus] ADD  CONSTRAINT [DF_TaskStatus_HasExternalSource]  DEFAULT ((0)) FOR [HasExternalSource]
GO
ALTER TABLE [Notification].[Notification] ADD  CONSTRAINT [DF_Notification_IsSeen]  DEFAULT ((0)) FOR [IsSeen]
GO
ALTER TABLE [Notification].[Notification] ADD  CONSTRAINT [DF_Notification_IsSent]  DEFAULT ((0)) FOR [IsSent]
GO
ALTER TABLE [Notification].[NotificationEvent] ADD  CONSTRAINT [DF_NotificationEvent_IsChecked]  DEFAULT ((0)) FOR [IsChecked]
GO

--FOREIGN KEYS
ALTER TABLE [A].[AuditEntries]  WITH CHECK ADD  CONSTRAINT [FK_AuditEntries_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [A].[AuditEntries] CHECK CONSTRAINT [FK_AuditEntries_CreatedBy]
GO
ALTER TABLE [A].[AuditEntryProperties]  WITH CHECK ADD  CONSTRAINT [FK_AuditEntryProperties_AuditEntry] FOREIGN KEY([AuditEntryID])
REFERENCES [A].[AuditEntries] ([AuditEntryID])
ON DELETE CASCADE
GO
ALTER TABLE [A].[AuditEntryProperties] CHECK CONSTRAINT [FK_AuditEntryProperties_AuditEntry]
GO
ALTER TABLE [dbo].[ArchivalEntities]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntities_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[ArchivalEntities] CHECK CONSTRAINT [FK_ArchivalEntities_Archive]
GO
ALTER TABLE [dbo].[ArchivalEntities]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntities_AvailabilityStatus] FOREIGN KEY([AvailabilityStatusCode])
REFERENCES [N].[AvailabilityStatus] ([Code])
GO
ALTER TABLE [dbo].[ArchivalEntities] CHECK CONSTRAINT [FK_ArchivalEntities_AvailabilityStatus]
GO
ALTER TABLE [dbo].[ArchivalEntities]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntities_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ArchivalEntities] CHECK CONSTRAINT [FK_ArchivalEntities_CreatedBy]
GO
ALTER TABLE [dbo].[ArchivalEntities]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntities_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ArchivalEntities] CHECK CONSTRAINT [FK_ArchivalEntities_DeletedBy]
GO
ALTER TABLE [dbo].[ArchivalEntities]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntities_DescriptionLevel] FOREIGN KEY([DescriptionLevelCode])
REFERENCES [N].[ArchivalEntityDescriptionLevel] ([Code])
GO
ALTER TABLE [dbo].[ArchivalEntities] CHECK CONSTRAINT [FK_ArchivalEntities_DescriptionLevel]
GO
ALTER TABLE [dbo].[ArchivalEntities]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntities_Fund] FOREIGN KEY([FundSystemIdentifier])
REFERENCES [dbo].[Funds] ([SystemIdentifier])
GO
ALTER TABLE [dbo].[ArchivalEntities] CHECK CONSTRAINT [FK_ArchivalEntities_Fund]
GO
ALTER TABLE [dbo].[ArchivalEntities]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntities_Inventory] FOREIGN KEY([InventorySystemIdentifier])
REFERENCES [dbo].[Inventories] ([SystemIdentifier])
GO
ALTER TABLE [dbo].[ArchivalEntities] CHECK CONSTRAINT [FK_ArchivalEntities_Inventory]
GO
ALTER TABLE [dbo].[ArchivalEntities]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntities_Status] FOREIGN KEY([StatusCode])
REFERENCES [N].[Status] ([Code])
GO
ALTER TABLE [dbo].[ArchivalEntities] CHECK CONSTRAINT [FK_ArchivalEntities_Status]
GO
ALTER TABLE [dbo].[ArchivalEntities]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntities_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ArchivalEntities] CHECK CONSTRAINT [FK_ArchivalEntities_UpdatedBy]
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntityDrafts_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts] CHECK CONSTRAINT [FK_ArchivalEntityDrafts_Archive]
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntityDrafts_AvailabilityStatus] FOREIGN KEY([AvailabilityStatusCode])
REFERENCES [N].[AvailabilityStatus] ([Code])
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts] CHECK CONSTRAINT [FK_ArchivalEntityDrafts_AvailabilityStatus]
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntityDrafts_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts] CHECK CONSTRAINT [FK_ArchivalEntityDrafts_CreatedBy]
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntityDrafts_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts] CHECK CONSTRAINT [FK_ArchivalEntityDrafts_DeletedBy]
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntityDrafts_DescriptionLevel] FOREIGN KEY([DescriptionLevelCode])
REFERENCES [N].[ArchivalEntityDescriptionLevel] ([Code])
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts] CHECK CONSTRAINT [FK_ArchivalEntityDrafts_DescriptionLevel]
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntityDrafts_FundDraft] FOREIGN KEY([FundDraftId])
REFERENCES [dbo].[FundDrafts] ([Id])
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts] CHECK CONSTRAINT [FK_ArchivalEntityDrafts_FundDraft]
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntityDrafts_InventoryDraft] FOREIGN KEY([InventoryDraftId])
REFERENCES [dbo].[InventoryDrafts] ([Id])
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts] CHECK CONSTRAINT [FK_ArchivalEntityDrafts_InventoryDraft]
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntityDrafts_Status] FOREIGN KEY([StatusCode])
REFERENCES [N].[Status] ([Code])
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts] CHECK CONSTRAINT [FK_ArchivalEntityDrafts_Status]
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts]  WITH CHECK ADD  CONSTRAINT [FK_ArchivalEntityDrafts_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ArchivalEntityDrafts] CHECK CONSTRAINT [FK_ArchivalEntityDrafts_UpdatedBy]
GO
ALTER TABLE [dbo].[Archives]  WITH CHECK ADD  CONSTRAINT [FK_Archives_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Archives] CHECK CONSTRAINT [FK_Archives_CreatedBy]
GO
ALTER TABLE [dbo].[Archives]  WITH CHECK ADD  CONSTRAINT [FK_Archives_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Archives] CHECK CONSTRAINT [FK_Archives_DeletedBy]
GO
ALTER TABLE [dbo].[Archives]  WITH CHECK ADD  CONSTRAINT [FK_Archives_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Archives] CHECK CONSTRAINT [FK_Archives_UpdatedBy]
GO
ALTER TABLE [dbo].[ArchivesSpecificOrder]  WITH CHECK ADD  CONSTRAINT [FK_ArchivesSpecificOrder_ArchiveId] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[ArchivesSpecificOrder] CHECK CONSTRAINT [FK_ArchivesSpecificOrder_ArchiveId]
GO
ALTER TABLE [dbo].[AspNetRoleClaims]  WITH CHECK ADD  CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetRoleClaims] CHECK CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId]
GO
ALTER TABLE [dbo].[AspNetRoles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetRoles_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[AspNetRoles] CHECK CONSTRAINT [FK_AspNetRoles_Archive]
GO
ALTER TABLE [dbo].[AspNetUserArchives]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserArchives_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[AspNetUserArchives] CHECK CONSTRAINT [FK_AspNetUserArchives_Archive]
GO
ALTER TABLE [dbo].[AspNetUserArchives]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserArchives_User] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserArchives] CHECK CONSTRAINT [FK_AspNetUserArchives_User]
GO
ALTER TABLE [dbo].[AspNetUserClaims]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserClaims] CHECK CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserLogins]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserLogins] CHECK CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUserProfiles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserProfiles_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[AspNetUserProfiles] CHECK CONSTRAINT [FK_AspNetUserProfiles_CreatedBy]
GO
ALTER TABLE [dbo].[AspNetUserProfiles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserProfiles_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[AspNetUserProfiles] CHECK CONSTRAINT [FK_AspNetUserProfiles_DeletedBy]
GO
ALTER TABLE [dbo].[AspNetUserProfiles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserProfiles_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[AspNetUserProfiles] CHECK CONSTRAINT [FK_AspNetUserProfiles_UpdatedBy]
GO
ALTER TABLE [dbo].[AspNetUserProfiles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserProfiles_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserProfiles] CHECK CONSTRAINT [FK_AspNetUserProfiles_UserId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId]
GO
ALTER TABLE [dbo].[AspNetUserRoles]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserRoles] CHECK CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[AspNetUsers]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUsers_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[AspNetUsers] CHECK CONSTRAINT [FK_AspNetUsers_CreatedBy]
GO
ALTER TABLE [dbo].[AspNetUsers]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUsers_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[AspNetUsers] CHECK CONSTRAINT [FK_AspNetUsers_DeletedBy]
GO
ALTER TABLE [dbo].[AspNetUsers]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUsers_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[AspNetUsers] CHECK CONSTRAINT [FK_AspNetUsers_UpdatedBy]
GO
ALTER TABLE [dbo].[AspNetUserTokens]  WITH CHECK ADD  CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[AspNetUserTokens] CHECK CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId]
GO
ALTER TABLE [dbo].[Comments]  WITH CHECK ADD FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Comments]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Comments]  WITH CHECK ADD  CONSTRAINT [FK__Comments__Proces__064DE20A] FOREIGN KEY([ProcessStepId])
REFERENCES [N].[ProcessSteps] ([Id])
GO
ALTER TABLE [dbo].[Comments] CHECK CONSTRAINT [FK__Comments__Proces__064DE20A]
GO
ALTER TABLE [dbo].[Comments]  WITH CHECK ADD FOREIGN KEY([ProcessId])
REFERENCES [dbo].[Process] ([Id])
GO
ALTER TABLE [dbo].[Comments]  WITH CHECK ADD FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Comments]  WITH CHECK ADD  CONSTRAINT [FK_Comments_SessionAgendaStandpoint] FOREIGN KEY([SessionAgendaStandpointId])
REFERENCES [dbo].[SessionAgendaStandpoints] ([Id])
GO
ALTER TABLE [dbo].[Comments] CHECK CONSTRAINT [FK_Comments_SessionAgendaStandpoint]
GO
ALTER TABLE [dbo].[CommissionReportFiles]  WITH CHECK ADD  CONSTRAINT [FK_ReportFiles_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[CommissionReportFiles] CHECK CONSTRAINT [FK_ReportFiles_CreatedBy]
GO
ALTER TABLE [dbo].[CommissionReportFiles]  WITH CHECK ADD  CONSTRAINT [FK_ReportFiles_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[CommissionReportFiles] CHECK CONSTRAINT [FK_ReportFiles_DeletedBy]
GO
ALTER TABLE [dbo].[CommissionReportFiles]  WITH CHECK ADD  CONSTRAINT [FK_ReportFiles_Report] FOREIGN KEY([ReportId])
REFERENCES [dbo].[EPKReports] ([Id])
GO
ALTER TABLE [dbo].[CommissionReportFiles] CHECK CONSTRAINT [FK_ReportFiles_Report]
GO
ALTER TABLE [dbo].[CommissionReportFiles]  WITH CHECK ADD  CONSTRAINT [FK_ReportFiles_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[CommissionReportFiles] CHECK CONSTRAINT [FK_ReportFiles_UpdatedBy]
GO
ALTER TABLE [dbo].[DigitalObjectDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjectDrafts_ArchivalEntityDraft] FOREIGN KEY([ArchivalEntityDraftId])
REFERENCES [dbo].[ArchivalEntityDrafts] ([Id])
GO
ALTER TABLE [dbo].[DigitalObjectDrafts] CHECK CONSTRAINT [FK_DigitalObjectDrafts_ArchivalEntityDraft]
GO
ALTER TABLE [dbo].[DigitalObjectDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjectDrafts_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[DigitalObjectDrafts] CHECK CONSTRAINT [FK_DigitalObjectDrafts_Archive]
GO
ALTER TABLE [dbo].[DigitalObjectDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjectDrafts_AvailabilityStatus] FOREIGN KEY([AvailabilityStatusCode])
REFERENCES [N].[AvailabilityStatus] ([Code])
GO
ALTER TABLE [dbo].[DigitalObjectDrafts] CHECK CONSTRAINT [FK_DigitalObjectDrafts_AvailabilityStatus]
GO
ALTER TABLE [dbo].[DigitalObjectDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjectDrafts_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[DigitalObjectDrafts] CHECK CONSTRAINT [FK_DigitalObjectDrafts_CreatedBy]
GO
ALTER TABLE [dbo].[DigitalObjectDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjectDrafts_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[DigitalObjectDrafts] CHECK CONSTRAINT [FK_DigitalObjectDrafts_DeletedBy]
GO
ALTER TABLE [dbo].[DigitalObjectDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjectDrafts_DocumentDraft] FOREIGN KEY([DocumentDraftId])
REFERENCES [dbo].[DocumentDrafts] ([Id])
GO
ALTER TABLE [dbo].[DigitalObjectDrafts] CHECK CONSTRAINT [FK_DigitalObjectDrafts_DocumentDraft]
GO
ALTER TABLE [dbo].[DigitalObjectDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjectDrafts_FundDraft] FOREIGN KEY([FundDraftId])
REFERENCES [dbo].[FundDrafts] ([Id])
GO
ALTER TABLE [dbo].[DigitalObjectDrafts] CHECK CONSTRAINT [FK_DigitalObjectDrafts_FundDraft]
GO
ALTER TABLE [dbo].[DigitalObjectDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjectDrafts_InventoryDraft] FOREIGN KEY([InventoryDraftId])
REFERENCES [dbo].[InventoryDrafts] ([Id])
GO
ALTER TABLE [dbo].[DigitalObjectDrafts] CHECK CONSTRAINT [FK_DigitalObjectDrafts_InventoryDraft]
GO
ALTER TABLE [dbo].[DigitalObjectDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjectDrafts_Status] FOREIGN KEY([StatusCode])
REFERENCES [N].[Status] ([Code])
GO
ALTER TABLE [dbo].[DigitalObjectDrafts] CHECK CONSTRAINT [FK_DigitalObjectDrafts_Status]
GO
ALTER TABLE [dbo].[DigitalObjectDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjectDrafts_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[DigitalObjectDrafts] CHECK CONSTRAINT [FK_DigitalObjectDrafts_UpdatedBy]
GO
ALTER TABLE [dbo].[DigitalObjectReviews]  WITH CHECK ADD FOREIGN KEY([ArchivalEntitySystemIdentifier])
REFERENCES [dbo].[ArchivalEntities] ([SystemIdentifier])
GO
ALTER TABLE [dbo].[DigitalObjectReviews]  WITH CHECK ADD FOREIGN KEY([DigitalObjectSystemIdentifier])
REFERENCES [dbo].[DigitalObjects] ([SystemIdentifier])
GO
ALTER TABLE [dbo].[DigitalObjectReviews]  WITH CHECK ADD FOREIGN KEY([DocumentSystemIdentifier])
REFERENCES [dbo].[Documents] ([SystemIdentifier])
GO
ALTER TABLE [dbo].[DigitalObjectReviews]  WITH CHECK ADD FOREIGN KEY([UserSystemIdentifier])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[DigitalObjects]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjects_ArchivalEntity] FOREIGN KEY([ArchivalEntitySystemIdentifier])
REFERENCES [dbo].[ArchivalEntities] ([SystemIdentifier])
GO
ALTER TABLE [dbo].[DigitalObjects] CHECK CONSTRAINT [FK_DigitalObjects_ArchivalEntity]
GO
ALTER TABLE [dbo].[DigitalObjects]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjects_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[DigitalObjects] CHECK CONSTRAINT [FK_DigitalObjects_Archive]
GO
ALTER TABLE [dbo].[DigitalObjects]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjects_AvailabilityStatus] FOREIGN KEY([AvailabilityStatusCode])
REFERENCES [N].[AvailabilityStatus] ([Code])
GO
ALTER TABLE [dbo].[DigitalObjects] CHECK CONSTRAINT [FK_DigitalObjects_AvailabilityStatus]
GO
ALTER TABLE [dbo].[DigitalObjects]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjects_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[DigitalObjects] CHECK CONSTRAINT [FK_DigitalObjects_CreatedBy]
GO
ALTER TABLE [dbo].[DigitalObjects]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjects_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[DigitalObjects] CHECK CONSTRAINT [FK_DigitalObjects_DeletedBy]
GO
ALTER TABLE [dbo].[DigitalObjects]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjects_Document] FOREIGN KEY([DocumentSystemIdentifier])
REFERENCES [dbo].[Documents] ([SystemIdentifier])
GO
ALTER TABLE [dbo].[DigitalObjects] CHECK CONSTRAINT [FK_DigitalObjects_Document]
GO
ALTER TABLE [dbo].[DigitalObjects]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjects_Fund] FOREIGN KEY([FundSystemIdentifier])
REFERENCES [dbo].[Funds] ([SystemIdentifier])
GO
ALTER TABLE [dbo].[DigitalObjects] CHECK CONSTRAINT [FK_DigitalObjects_Fund]
GO
ALTER TABLE [dbo].[DigitalObjects]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjects_Inventory] FOREIGN KEY([InventorySystemIdentifier])
REFERENCES [dbo].[Inventories] ([SystemIdentifier])
GO
ALTER TABLE [dbo].[DigitalObjects] CHECK CONSTRAINT [FK_DigitalObjects_Inventory]
GO
ALTER TABLE [dbo].[DigitalObjects]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjects_Status] FOREIGN KEY([StatusCode])
REFERENCES [N].[Status] ([Code])
GO
ALTER TABLE [dbo].[DigitalObjects] CHECK CONSTRAINT [FK_DigitalObjects_Status]
GO
ALTER TABLE [dbo].[DigitalObjects]  WITH CHECK ADD  CONSTRAINT [FK_DigitalObjects_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[DigitalObjects] CHECK CONSTRAINT [FK_DigitalObjects_UpdatedBy]
GO
ALTER TABLE [dbo].[DocumentDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DocumentDrafts_ArchivalEntityDraft] FOREIGN KEY([ArchivalEntityDraftId])
REFERENCES [dbo].[ArchivalEntityDrafts] ([Id])
GO
ALTER TABLE [dbo].[DocumentDrafts] CHECK CONSTRAINT [FK_DocumentDrafts_ArchivalEntityDraft]
GO
ALTER TABLE [dbo].[DocumentDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DocumentDrafts_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[DocumentDrafts] CHECK CONSTRAINT [FK_DocumentDrafts_Archive]
GO
ALTER TABLE [dbo].[DocumentDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DocumentDrafts_AvailabilityStatus] FOREIGN KEY([AvailabilityStatusCode])
REFERENCES [N].[AvailabilityStatus] ([Code])
GO
ALTER TABLE [dbo].[DocumentDrafts] CHECK CONSTRAINT [FK_DocumentDrafts_AvailabilityStatus]
GO
ALTER TABLE [dbo].[DocumentDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DocumentDrafts_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[DocumentDrafts] CHECK CONSTRAINT [FK_DocumentDrafts_CreatedBy]
GO
ALTER TABLE [dbo].[DocumentDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DocumentDrafts_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[DocumentDrafts] CHECK CONSTRAINT [FK_DocumentDrafts_DeletedBy]
GO
ALTER TABLE [dbo].[DocumentDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DocumentDrafts_DocumentDescriptionLevel] FOREIGN KEY([DescriptionLevelCode])
REFERENCES [N].[DocumentDescriptionLevel] ([Code])
GO
ALTER TABLE [dbo].[DocumentDrafts] CHECK CONSTRAINT [FK_DocumentDrafts_DocumentDescriptionLevel]
GO
ALTER TABLE [dbo].[DocumentDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DocumentDrafts_FundDraft] FOREIGN KEY([FundDraftId])
REFERENCES [dbo].[FundDrafts] ([Id])
GO
ALTER TABLE [dbo].[DocumentDrafts] CHECK CONSTRAINT [FK_DocumentDrafts_FundDraft]
GO
ALTER TABLE [dbo].[DocumentDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DocumentDrafts_InventoryDraft] FOREIGN KEY([InventoryDraftId])
REFERENCES [dbo].[InventoryDrafts] ([Id])
GO
ALTER TABLE [dbo].[DocumentDrafts] CHECK CONSTRAINT [FK_DocumentDrafts_InventoryDraft]
GO
ALTER TABLE [dbo].[DocumentDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DocumentDrafts_Status] FOREIGN KEY([StatusCode])
REFERENCES [N].[Status] ([Code])
GO
ALTER TABLE [dbo].[DocumentDrafts] CHECK CONSTRAINT [FK_DocumentDrafts_Status]
GO
ALTER TABLE [dbo].[DocumentDrafts]  WITH CHECK ADD  CONSTRAINT [FK_DocumentDrafts_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[DocumentDrafts] CHECK CONSTRAINT [FK_DocumentDrafts_UpdatedBy]
GO
ALTER TABLE [dbo].[Documents]  WITH CHECK ADD  CONSTRAINT [FK_Documents_ArchivalEntity] FOREIGN KEY([ArchivalEntitySystemIdentifier])
REFERENCES [dbo].[ArchivalEntities] ([SystemIdentifier])
GO
ALTER TABLE [dbo].[Documents] CHECK CONSTRAINT [FK_Documents_ArchivalEntity]
GO
ALTER TABLE [dbo].[Documents]  WITH CHECK ADD  CONSTRAINT [FK_Documents_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[Documents] CHECK CONSTRAINT [FK_Documents_Archive]
GO
ALTER TABLE [dbo].[Documents]  WITH CHECK ADD  CONSTRAINT [FK_Documents_AvailabilityStatus] FOREIGN KEY([AvailabilityStatusCode])
REFERENCES [N].[AvailabilityStatus] ([Code])
GO
ALTER TABLE [dbo].[Documents] CHECK CONSTRAINT [FK_Documents_AvailabilityStatus]
GO
ALTER TABLE [dbo].[Documents]  WITH CHECK ADD  CONSTRAINT [FK_Documents_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Documents] CHECK CONSTRAINT [FK_Documents_CreatedBy]
GO
ALTER TABLE [dbo].[Documents]  WITH CHECK ADD  CONSTRAINT [FK_Documents_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Documents] CHECK CONSTRAINT [FK_Documents_DeletedBy]
GO
ALTER TABLE [dbo].[Documents]  WITH CHECK ADD  CONSTRAINT [FK_Documents_DocumentDescriptionLevel] FOREIGN KEY([DescriptionLevelCode])
REFERENCES [N].[DocumentDescriptionLevel] ([Code])
GO
ALTER TABLE [dbo].[Documents] CHECK CONSTRAINT [FK_Documents_DocumentDescriptionLevel]
GO
ALTER TABLE [dbo].[Documents]  WITH CHECK ADD  CONSTRAINT [FK_Documents_Fund] FOREIGN KEY([FundSystemIdentifier])
REFERENCES [dbo].[Funds] ([SystemIdentifier])
GO
ALTER TABLE [dbo].[Documents] CHECK CONSTRAINT [FK_Documents_Fund]
GO
ALTER TABLE [dbo].[Documents]  WITH CHECK ADD  CONSTRAINT [FK_Documents_Inventory] FOREIGN KEY([InventorySystemIdentifier])
REFERENCES [dbo].[Inventories] ([SystemIdentifier])
GO
ALTER TABLE [dbo].[Documents] CHECK CONSTRAINT [FK_Documents_Inventory]
GO
ALTER TABLE [dbo].[Documents]  WITH CHECK ADD  CONSTRAINT [FK_Documents_Status] FOREIGN KEY([StatusCode])
REFERENCES [N].[Status] ([Code])
GO
ALTER TABLE [dbo].[Documents] CHECK CONSTRAINT [FK_Documents_Status]
GO
ALTER TABLE [dbo].[Documents]  WITH CHECK ADD  CONSTRAINT [FK_Documents_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Documents] CHECK CONSTRAINT [FK_Documents_UpdatedBy]
GO
ALTER TABLE [dbo].[EDocsCollectingApplication]  WITH CHECK ADD  CONSTRAINT [FK_EDocsCollectingApplication_Applicant] FOREIGN KEY([ApplicantId])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[EDocsCollectingApplication] CHECK CONSTRAINT [FK_EDocsCollectingApplication_Applicant]
GO
ALTER TABLE [dbo].[EDocsCollectingApplication]  WITH CHECK ADD  CONSTRAINT [FK_EDocsCollectingApplication_ApplicationFile] FOREIGN KEY([FileId])
REFERENCES [dbo].[Files] ([Id])
GO
ALTER TABLE [dbo].[EDocsCollectingApplication] CHECK CONSTRAINT [FK_EDocsCollectingApplication_ApplicationFile]
GO
ALTER TABLE [dbo].[EDocsCollectingApplication]  WITH CHECK ADD  CONSTRAINT [FK_EDocsCollectingApplication_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[EDocsCollectingApplication] CHECK CONSTRAINT [FK_EDocsCollectingApplication_Archive]
GO
ALTER TABLE [dbo].[EDocsCollectingApplication]  WITH CHECK ADD  CONSTRAINT [FK_EDocsCollectingApplication_AssignTo] FOREIGN KEY([AssignToUserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[EDocsCollectingApplication] CHECK CONSTRAINT [FK_EDocsCollectingApplication_AssignTo]
GO
ALTER TABLE [dbo].[EDocsCollectingApplication]  WITH CHECK ADD  CONSTRAINT [FK_EDocsCollectingApplication_Creator] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[EDocsCollectingApplication] CHECK CONSTRAINT [FK_EDocsCollectingApplication_Creator]
GO
ALTER TABLE [dbo].[EDocsCollectingApplication]  WITH CHECK ADD  CONSTRAINT [FK_EDocsCollectingApplication_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[EDocsCollectingApplication] CHECK CONSTRAINT [FK_EDocsCollectingApplication_DeletedBy]
GO
ALTER TABLE [dbo].[EDocsCollectingApplication]  WITH CHECK ADD  CONSTRAINT [FK_EDocsCollectingApplication_PackageA] FOREIGN KEY([PackageAId])
REFERENCES [dbo].[Packages] ([Id])
GO
ALTER TABLE [dbo].[EDocsCollectingApplication] CHECK CONSTRAINT [FK_EDocsCollectingApplication_PackageA]
GO
ALTER TABLE [dbo].[EDocsCollectingApplication]  WITH CHECK ADD  CONSTRAINT [FK_EDocsCollectingApplication_PackageB] FOREIGN KEY([PackageBId])
REFERENCES [dbo].[Packages] ([Id])
GO
ALTER TABLE [dbo].[EDocsCollectingApplication] CHECK CONSTRAINT [FK_EDocsCollectingApplication_PackageB]
GO
ALTER TABLE [dbo].[EDocsCollectingApplication]  WITH CHECK ADD  CONSTRAINT [FK_EDocsCollectingApplication_Status] FOREIGN KEY([StatusId])
REFERENCES [N].[EDocsCollectingApplicationStatuses] ([Id])
GO
ALTER TABLE [dbo].[EDocsCollectingApplication] CHECK CONSTRAINT [FK_EDocsCollectingApplication_Status]
GO
ALTER TABLE [dbo].[EDocsCollectingApplication]  WITH CHECK ADD  CONSTRAINT [FK_EDocsCollectingApplication_Type] FOREIGN KEY([Type])
REFERENCES [N].[EDocsCollectingApplicationTypes] ([Code])
GO
ALTER TABLE [dbo].[EDocsCollectingApplication] CHECK CONSTRAINT [FK_EDocsCollectingApplication_Type]
GO
ALTER TABLE [dbo].[EDocsCollectingApplication]  WITH CHECK ADD  CONSTRAINT [FK_EDocsCollectingApplication_Updator] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[EDocsCollectingApplication] CHECK CONSTRAINT [FK_EDocsCollectingApplication_Updator]
GO
ALTER TABLE [dbo].[EPKReports]  WITH CHECK ADD FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[EPKReports]  WITH CHECK ADD FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[EPKReports]  WITH CHECK ADD FOREIGN KEY([ProcessId])
REFERENCES [dbo].[Process] ([Id])
GO
ALTER TABLE [dbo].[EPKReports]  WITH CHECK ADD FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Files]  WITH CHECK ADD  CONSTRAINT [FK_Files_AspNetUsers] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Files] CHECK CONSTRAINT [FK_Files_AspNetUsers]
GO
ALTER TABLE [dbo].[Files]  WITH CHECK ADD  CONSTRAINT [FK_Files_AspNetUsers1] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Files] CHECK CONSTRAINT [FK_Files_AspNetUsers1]
GO
ALTER TABLE [dbo].[FilmCardDocuments]  WITH CHECK ADD  CONSTRAINT [FK_FilmCardDoc_FilmPackageDocument] FOREIGN KEY([PackageDocumentId])
REFERENCES [dbo].[FilmPackageDocuments] ([Id])
GO
ALTER TABLE [dbo].[FilmCardDocuments] CHECK CONSTRAINT [FK_FilmCardDoc_FilmPackageDocument]
GO
ALTER TABLE [dbo].[FilmCardDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FilmCardDraft_Country] FOREIGN KEY([CountryId])
REFERENCES [N].[Nomenclatures] ([Id])
GO
ALTER TABLE [dbo].[FilmCardDrafts] CHECK CONSTRAINT [FK_FilmCardDraft_Country]
GO
ALTER TABLE [dbo].[FilmCardDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FilmCardDrafts_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[FilmCardDrafts] CHECK CONSTRAINT [FK_FilmCardDrafts_Archive]
GO
ALTER TABLE [dbo].[FilmCardDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FilmCardDrafts_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmCardDrafts] CHECK CONSTRAINT [FK_FilmCardDrafts_CreatedBy]
GO
ALTER TABLE [dbo].[FilmCardDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FilmCardDrafts_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmCardDrafts] CHECK CONSTRAINT [FK_FilmCardDrafts_DeletedBy]
GO
ALTER TABLE [dbo].[FilmCardDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FilmCardDrafts_FilmDraft] FOREIGN KEY([FilmDraftId])
REFERENCES [dbo].[FilmDrafts] ([Id])
GO
ALTER TABLE [dbo].[FilmCardDrafts] CHECK CONSTRAINT [FK_FilmCardDrafts_FilmDraft]
GO
ALTER TABLE [dbo].[FilmCardDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FilmCardDrafts_FilmingExtent] FOREIGN KEY([FilmingExtentId])
REFERENCES [N].[Nomenclatures] ([Id])
GO
ALTER TABLE [dbo].[FilmCardDrafts] CHECK CONSTRAINT [FK_FilmCardDrafts_FilmingExtent]
GO
ALTER TABLE [dbo].[FilmCardDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FilmCardDrafts_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmCardDrafts] CHECK CONSTRAINT [FK_FilmCardDrafts_UpdatedBy]
GO
ALTER TABLE [dbo].[FilmCards]  WITH CHECK ADD  CONSTRAINT [FK_FilmCard_ArchiveCopy] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[FilmCards] CHECK CONSTRAINT [FK_FilmCard_ArchiveCopy]
GO
ALTER TABLE [dbo].[FilmCards]  WITH CHECK ADD  CONSTRAINT [FK_FilmCard_Country] FOREIGN KEY([CountryId])
REFERENCES [N].[Nomenclatures] ([Id])
GO
ALTER TABLE [dbo].[FilmCards] CHECK CONSTRAINT [FK_FilmCard_Country]
GO
ALTER TABLE [dbo].[FilmCards]  WITH CHECK ADD  CONSTRAINT [FK_FilmCard_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmCards] CHECK CONSTRAINT [FK_FilmCard_CreatedBy]
GO
ALTER TABLE [dbo].[FilmCards]  WITH CHECK ADD  CONSTRAINT [FK_FilmCard_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmCards] CHECK CONSTRAINT [FK_FilmCard_DeletedBy]
GO
ALTER TABLE [dbo].[FilmCards]  WITH CHECK ADD  CONSTRAINT [FK_FilmCard_Film] FOREIGN KEY([FilmSystemIdentifier])
REFERENCES [dbo].[Films] ([SystemIdentifier])
GO
ALTER TABLE [dbo].[FilmCards] CHECK CONSTRAINT [FK_FilmCard_Film]
GO
ALTER TABLE [dbo].[FilmCards]  WITH CHECK ADD  CONSTRAINT [FK_FilmCard_FilmingExtent] FOREIGN KEY([FilmingExtentId])
REFERENCES [N].[Nomenclatures] ([Id])
GO
ALTER TABLE [dbo].[FilmCards] CHECK CONSTRAINT [FK_FilmCard_FilmingExtent]
GO
ALTER TABLE [dbo].[FilmCards]  WITH CHECK ADD  CONSTRAINT [FK_FilmCard_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmCards] CHECK CONSTRAINT [FK_FilmCard_UpdatedBy]
GO
ALTER TABLE [dbo].[FilmDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FilmDrafts_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[FilmDrafts] CHECK CONSTRAINT [FK_FilmDrafts_Archive]
GO
ALTER TABLE [dbo].[FilmDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FilmDrafts_Country] FOREIGN KEY([CountryId])
REFERENCES [N].[Nomenclatures] ([Id])
GO
ALTER TABLE [dbo].[FilmDrafts] CHECK CONSTRAINT [FK_FilmDrafts_Country]
GO
ALTER TABLE [dbo].[FilmDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FilmDrafts_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmDrafts] CHECK CONSTRAINT [FK_FilmDrafts_CreatedBy]
GO
ALTER TABLE [dbo].[FilmDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FilmDrafts_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmDrafts] CHECK CONSTRAINT [FK_FilmDrafts_DeletedBy]
GO
ALTER TABLE [dbo].[FilmDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FilmDrafts_PackageA] FOREIGN KEY([PackageAId])
REFERENCES [dbo].[FilmPackages] ([Id])
GO
ALTER TABLE [dbo].[FilmDrafts] CHECK CONSTRAINT [FK_FilmDrafts_PackageA]
GO
ALTER TABLE [dbo].[FilmDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FilmDrafts_PackageB] FOREIGN KEY([PackageBId])
REFERENCES [dbo].[FilmPackages] ([Id])
GO
ALTER TABLE [dbo].[FilmDrafts] CHECK CONSTRAINT [FK_FilmDrafts_PackageB]
GO
ALTER TABLE [dbo].[FilmDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FilmDrafts_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmDrafts] CHECK CONSTRAINT [FK_FilmDrafts_UpdatedBy]
GO
ALTER TABLE [dbo].[FilmPackageDocuments]  WITH CHECK ADD  CONSTRAINT [FK_FilmPackageDocument_CopyId] FOREIGN KEY([CopiedFromId])
REFERENCES [dbo].[FilmPackageDocuments] ([Id])
GO
ALTER TABLE [dbo].[FilmPackageDocuments] CHECK CONSTRAINT [FK_FilmPackageDocument_CopyId]
GO
ALTER TABLE [dbo].[FilmPackageDocuments]  WITH CHECK ADD  CONSTRAINT [FK_FilmPackageDocument_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmPackageDocuments] CHECK CONSTRAINT [FK_FilmPackageDocument_CreatedBy]
GO
ALTER TABLE [dbo].[FilmPackageDocuments]  WITH CHECK ADD  CONSTRAINT [FK_FilmPackageDocument_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmPackageDocuments] CHECK CONSTRAINT [FK_FilmPackageDocument_DeletedBy]
GO
ALTER TABLE [dbo].[FilmPackageDocuments]  WITH CHECK ADD  CONSTRAINT [FK_FilmPackageDocument_DocType] FOREIGN KEY([DocumentTypeId])
REFERENCES [N].[FilmDocumentType] ([Id])
GO
ALTER TABLE [dbo].[FilmPackageDocuments] CHECK CONSTRAINT [FK_FilmPackageDocument_DocType]
GO
ALTER TABLE [dbo].[FilmPackageDocuments]  WITH CHECK ADD  CONSTRAINT [FK_FilmPackageDocument_Package] FOREIGN KEY([PackageId])
REFERENCES [dbo].[FilmPackages] ([Id])
GO
ALTER TABLE [dbo].[FilmPackageDocuments] CHECK CONSTRAINT [FK_FilmPackageDocument_Package]
GO
ALTER TABLE [dbo].[FilmPackageDocuments]  WITH CHECK ADD  CONSTRAINT [FK_FilmPackageDocument_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmPackageDocuments] CHECK CONSTRAINT [FK_FilmPackageDocument_UpdatedBy]
GO
ALTER TABLE [dbo].[FilmPackages]  WITH CHECK ADD  CONSTRAINT [FK_FilmPackage_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmPackages] CHECK CONSTRAINT [FK_FilmPackage_CreatedBy]
GO
ALTER TABLE [dbo].[FilmPackages]  WITH CHECK ADD  CONSTRAINT [FK_FilmPackage_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmPackages] CHECK CONSTRAINT [FK_FilmPackage_DeletedBy]
GO
ALTER TABLE [dbo].[FilmPackages]  WITH CHECK ADD  CONSTRAINT [FK_FilmPackage_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmPackages] CHECK CONSTRAINT [FK_FilmPackage_UpdatedBy]
GO
ALTER TABLE [dbo].[FilmReviews]  WITH CHECK ADD FOREIGN KEY([FilmSystemIdentifier])
REFERENCES [dbo].[Films] ([SystemIdentifier])
GO
ALTER TABLE [dbo].[FilmReviews]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmReviews]  WITH CHECK ADD  CONSTRAINT [FK_FilmReviews_CreatedByAspNetUser] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmReviews] CHECK CONSTRAINT [FK_FilmReviews_CreatedByAspNetUser]
GO
ALTER TABLE [dbo].[FilmReviews]  WITH CHECK ADD  CONSTRAINT [FK_FilmReviews_DeletedByAspNetUser] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmReviews] CHECK CONSTRAINT [FK_FilmReviews_DeletedByAspNetUser]
GO
ALTER TABLE [dbo].[FilmReviews]  WITH CHECK ADD  CONSTRAINT [FK_FilmReviews_UpdatedByAspNetUser] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FilmReviews] CHECK CONSTRAINT [FK_FilmReviews_UpdatedByAspNetUser]
GO
ALTER TABLE [dbo].[Films]  WITH CHECK ADD  CONSTRAINT [FK_Film_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[Films] CHECK CONSTRAINT [FK_Film_Archive]
GO
ALTER TABLE [dbo].[Films]  WITH CHECK ADD  CONSTRAINT [FK_Film_Country] FOREIGN KEY([CountryId])
REFERENCES [N].[Nomenclatures] ([Id])
GO
ALTER TABLE [dbo].[Films] CHECK CONSTRAINT [FK_Film_Country]
GO
ALTER TABLE [dbo].[Films]  WITH CHECK ADD  CONSTRAINT [FK_Film_CreatedByAspNetUser] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Films] CHECK CONSTRAINT [FK_Film_CreatedByAspNetUser]
GO
ALTER TABLE [dbo].[Films]  WITH CHECK ADD  CONSTRAINT [FK_Film_DeletedByAspNetUser] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Films] CHECK CONSTRAINT [FK_Film_DeletedByAspNetUser]
GO
ALTER TABLE [dbo].[Films]  WITH CHECK ADD  CONSTRAINT [FK_Film_PackageA] FOREIGN KEY([PackageAId])
REFERENCES [dbo].[FilmPackages] ([Id])
GO
ALTER TABLE [dbo].[Films] CHECK CONSTRAINT [FK_Film_PackageA]
GO
ALTER TABLE [dbo].[Films]  WITH CHECK ADD  CONSTRAINT [FK_Film_PackageB] FOREIGN KEY([PackageBId])
REFERENCES [dbo].[FilmPackages] ([Id])
GO
ALTER TABLE [dbo].[Films] CHECK CONSTRAINT [FK_Film_PackageB]
GO
ALTER TABLE [dbo].[Films]  WITH CHECK ADD  CONSTRAINT [FK_Film_UpdatedByAspNetUser] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Films] CHECK CONSTRAINT [FK_Film_UpdatedByAspNetUser]
GO
ALTER TABLE [dbo].[FundDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FundDrafts_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[EDocsCollectingApplication] ([Id])
GO
ALTER TABLE [dbo].[FundDrafts] CHECK CONSTRAINT [FK_FundDrafts_Applications]
GO
ALTER TABLE [dbo].[FundDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FundDrafts_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[FundDrafts] CHECK CONSTRAINT [FK_FundDrafts_Archive]
GO
ALTER TABLE [dbo].[FundDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FundDrafts_Array] FOREIGN KEY([NumberArray])
REFERENCES [N].[FundArray] ([Code])
GO
ALTER TABLE [dbo].[FundDrafts] CHECK CONSTRAINT [FK_FundDrafts_Array]
GO
ALTER TABLE [dbo].[FundDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FundDrafts_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FundDrafts] CHECK CONSTRAINT [FK_FundDrafts_CreatedBy]
GO
ALTER TABLE [dbo].[FundDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FundDrafts_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FundDrafts] CHECK CONSTRAINT [FK_FundDrafts_DeletedBy]
GO
ALTER TABLE [dbo].[FundDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FundDrafts_DescriptionLevel] FOREIGN KEY([DescriptionLevelCode])
REFERENCES [N].[FundDescriptionLevel] ([Code])
GO
ALTER TABLE [dbo].[FundDrafts] CHECK CONSTRAINT [FK_FundDrafts_DescriptionLevel]
GO
ALTER TABLE [dbo].[FundDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FundDrafts_Status] FOREIGN KEY([StatusCode])
REFERENCES [N].[Status] ([Code])
GO
ALTER TABLE [dbo].[FundDrafts] CHECK CONSTRAINT [FK_FundDrafts_Status]
GO
ALTER TABLE [dbo].[FundDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FundDrafts_Type] FOREIGN KEY([TypeCode])
REFERENCES [N].[FundType] ([Code])
GO
ALTER TABLE [dbo].[FundDrafts] CHECK CONSTRAINT [FK_FundDrafts_Type]
GO
ALTER TABLE [dbo].[FundDrafts]  WITH CHECK ADD  CONSTRAINT [FK_FundDrafts_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FundDrafts] CHECK CONSTRAINT [FK_FundDrafts_UpdatedBy]
GO
ALTER TABLE [dbo].[FundReconstructions]  WITH CHECK ADD  CONSTRAINT [FK_FundReconstructions_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[FundReconstructions] CHECK CONSTRAINT [FK_FundReconstructions_Archive]
GO
ALTER TABLE [dbo].[FundReconstructions]  WITH CHECK ADD  CONSTRAINT [FK_FundReconstructions_AvailabilityStatus] FOREIGN KEY([AvailabilityStatusCode])
REFERENCES [N].[AvailabilityStatus] ([Code])
GO
ALTER TABLE [dbo].[FundReconstructions] CHECK CONSTRAINT [FK_FundReconstructions_AvailabilityStatus]
GO
ALTER TABLE [dbo].[FundReconstructions]  WITH CHECK ADD  CONSTRAINT [FK_FundReconstructions_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FundReconstructions] CHECK CONSTRAINT [FK_FundReconstructions_CreatedBy]
GO
ALTER TABLE [dbo].[FundReconstructions]  WITH CHECK ADD  CONSTRAINT [FK_FundReconstructions_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FundReconstructions] CHECK CONSTRAINT [FK_FundReconstructions_DeletedBy]
GO
ALTER TABLE [dbo].[FundReconstructions]  WITH CHECK ADD  CONSTRAINT [FK_FundReconstructions_Fund] FOREIGN KEY([FundSystemIdentifier])
REFERENCES [dbo].[Funds] ([SystemIdentifier])
GO
ALTER TABLE [dbo].[FundReconstructions] CHECK CONSTRAINT [FK_FundReconstructions_Fund]
GO
ALTER TABLE [dbo].[FundReconstructions]  WITH CHECK ADD  CONSTRAINT [FK_FundReconstructions_Process] FOREIGN KEY([ProcessId])
REFERENCES [dbo].[Process] ([Id])
GO
ALTER TABLE [dbo].[FundReconstructions] CHECK CONSTRAINT [FK_FundReconstructions_Process]
GO
ALTER TABLE [dbo].[FundReconstructions]  WITH CHECK ADD  CONSTRAINT [FK_FundReconstructions_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[FundReconstructions] CHECK CONSTRAINT [FK_FundReconstructions_UpdatedBy]
GO
ALTER TABLE [dbo].[Funds]  WITH CHECK ADD  CONSTRAINT [FK_Funds_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[EDocsCollectingApplication] ([Id])
GO
ALTER TABLE [dbo].[Funds] CHECK CONSTRAINT [FK_Funds_Applications]
GO
ALTER TABLE [dbo].[Funds]  WITH CHECK ADD  CONSTRAINT [FK_Funds_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[Funds] CHECK CONSTRAINT [FK_Funds_Archive]
GO
ALTER TABLE [dbo].[Funds]  WITH CHECK ADD  CONSTRAINT [FK_Funds_Array] FOREIGN KEY([NumberArray])
REFERENCES [N].[FundArray] ([Code])
GO
ALTER TABLE [dbo].[Funds] CHECK CONSTRAINT [FK_Funds_Array]
GO
ALTER TABLE [dbo].[Funds]  WITH CHECK ADD  CONSTRAINT [FK_Funds_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Funds] CHECK CONSTRAINT [FK_Funds_CreatedBy]
GO
ALTER TABLE [dbo].[Funds]  WITH CHECK ADD  CONSTRAINT [FK_Funds_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Funds] CHECK CONSTRAINT [FK_Funds_DeletedBy]
GO
ALTER TABLE [dbo].[Funds]  WITH CHECK ADD  CONSTRAINT [FK_Funds_DescriptionLevel] FOREIGN KEY([DescriptionLevelCode])
REFERENCES [N].[FundDescriptionLevel] ([Code])
GO
ALTER TABLE [dbo].[Funds] CHECK CONSTRAINT [FK_Funds_DescriptionLevel]
GO
ALTER TABLE [dbo].[Funds]  WITH CHECK ADD  CONSTRAINT [FK_Funds_LockingProcess] FOREIGN KEY([LockedByProcessId])
REFERENCES [dbo].[Process] ([Id])
GO
ALTER TABLE [dbo].[Funds] CHECK CONSTRAINT [FK_Funds_LockingProcess]
GO
ALTER TABLE [dbo].[Funds]  WITH CHECK ADD  CONSTRAINT [FK_Funds_Status] FOREIGN KEY([StatusCode])
REFERENCES [N].[Status] ([Code])
GO
ALTER TABLE [dbo].[Funds] CHECK CONSTRAINT [FK_Funds_Status]
GO
ALTER TABLE [dbo].[Funds]  WITH CHECK ADD  CONSTRAINT [FK_Funds_Type] FOREIGN KEY([TypeCode])
REFERENCES [N].[FundType] ([Code])
GO
ALTER TABLE [dbo].[Funds] CHECK CONSTRAINT [FK_Funds_Type]
GO
ALTER TABLE [dbo].[Funds]  WITH CHECK ADD  CONSTRAINT [FK_Funds_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Funds] CHECK CONSTRAINT [FK_Funds_UpdatedBy]
GO
ALTER TABLE [dbo].[Inventories]  WITH CHECK ADD  CONSTRAINT [FK_Inventories_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[EDocsCollectingApplication] ([Id])
GO
ALTER TABLE [dbo].[Inventories] CHECK CONSTRAINT [FK_Inventories_Applications]
GO
ALTER TABLE [dbo].[Inventories]  WITH CHECK ADD  CONSTRAINT [FK_Inventories_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[Inventories] CHECK CONSTRAINT [FK_Inventories_Archive]
GO
ALTER TABLE [dbo].[Inventories]  WITH CHECK ADD  CONSTRAINT [FK_Inventories_AvailabilityStatus] FOREIGN KEY([AvailabilityStatusCode])
REFERENCES [N].[AvailabilityStatus] ([Code])
GO
ALTER TABLE [dbo].[Inventories] CHECK CONSTRAINT [FK_Inventories_AvailabilityStatus]
GO
ALTER TABLE [dbo].[Inventories]  WITH CHECK ADD  CONSTRAINT [FK_Inventories_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Inventories] CHECK CONSTRAINT [FK_Inventories_CreatedBy]
GO
ALTER TABLE [dbo].[Inventories]  WITH CHECK ADD  CONSTRAINT [FK_Inventories_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Inventories] CHECK CONSTRAINT [FK_Inventories_DeletedBy]
GO
ALTER TABLE [dbo].[Inventories]  WITH CHECK ADD  CONSTRAINT [FK_Inventories_DescriptionLevel] FOREIGN KEY([DescriptionLevelCode])
REFERENCES [N].[InventoryDescriptionLevel] ([Code])
GO
ALTER TABLE [dbo].[Inventories] CHECK CONSTRAINT [FK_Inventories_DescriptionLevel]
GO
ALTER TABLE [dbo].[Inventories]  WITH CHECK ADD  CONSTRAINT [FK_Inventories_Fund] FOREIGN KEY([FundSystemIdentifier])
REFERENCES [dbo].[Funds] ([SystemIdentifier])
GO
ALTER TABLE [dbo].[Inventories] CHECK CONSTRAINT [FK_Inventories_Fund]
GO
ALTER TABLE [dbo].[Inventories]  WITH CHECK ADD  CONSTRAINT [FK_Inventories_PackageA] FOREIGN KEY([PackageAId])
REFERENCES [dbo].[Packages] ([Id])
GO
ALTER TABLE [dbo].[Inventories] CHECK CONSTRAINT [FK_Inventories_PackageA]
GO
ALTER TABLE [dbo].[Inventories]  WITH CHECK ADD  CONSTRAINT [FK_Inventories_PackageB] FOREIGN KEY([PackageBId])
REFERENCES [dbo].[Packages] ([Id])
GO
ALTER TABLE [dbo].[Inventories] CHECK CONSTRAINT [FK_Inventories_PackageB]
GO
ALTER TABLE [dbo].[Inventories]  WITH CHECK ADD  CONSTRAINT [FK_Inventories_Status] FOREIGN KEY([StatusCode])
REFERENCES [N].[Status] ([Code])
GO
ALTER TABLE [dbo].[Inventories] CHECK CONSTRAINT [FK_Inventories_Status]
GO
ALTER TABLE [dbo].[Inventories]  WITH CHECK ADD  CONSTRAINT [FK_Inventories_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Inventories] CHECK CONSTRAINT [FK_Inventories_UpdatedBy]
GO
ALTER TABLE [dbo].[Inventories]  WITH CHECK ADD  CONSTRAINT [FK_Inventory_LockingProcess] FOREIGN KEY([LockedByProcessId])
REFERENCES [dbo].[Process] ([Id])
GO
ALTER TABLE [dbo].[Inventories] CHECK CONSTRAINT [FK_Inventory_LockingProcess]
GO
ALTER TABLE [dbo].[InventoryDrafts]  WITH CHECK ADD  CONSTRAINT [FK_InventoryDrafts_Applications] FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[EDocsCollectingApplication] ([Id])
GO
ALTER TABLE [dbo].[InventoryDrafts] CHECK CONSTRAINT [FK_InventoryDrafts_Applications]
GO
ALTER TABLE [dbo].[InventoryDrafts]  WITH CHECK ADD  CONSTRAINT [FK_InventoryDrafts_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[InventoryDrafts] CHECK CONSTRAINT [FK_InventoryDrafts_Archive]
GO
ALTER TABLE [dbo].[InventoryDrafts]  WITH CHECK ADD  CONSTRAINT [FK_InventoryDrafts_AvailabilityStatus] FOREIGN KEY([AvailabilityStatusCode])
REFERENCES [N].[AvailabilityStatus] ([Code])
GO
ALTER TABLE [dbo].[InventoryDrafts] CHECK CONSTRAINT [FK_InventoryDrafts_AvailabilityStatus]
GO
ALTER TABLE [dbo].[InventoryDrafts]  WITH CHECK ADD  CONSTRAINT [FK_InventoryDrafts_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[InventoryDrafts] CHECK CONSTRAINT [FK_InventoryDrafts_CreatedBy]
GO
ALTER TABLE [dbo].[InventoryDrafts]  WITH CHECK ADD  CONSTRAINT [FK_InventoryDrafts_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[InventoryDrafts] CHECK CONSTRAINT [FK_InventoryDrafts_DeletedBy]
GO
ALTER TABLE [dbo].[InventoryDrafts]  WITH CHECK ADD  CONSTRAINT [FK_InventoryDrafts_DescriptionLevel] FOREIGN KEY([DescriptionLevelCode])
REFERENCES [N].[InventoryDescriptionLevel] ([Code])
GO
ALTER TABLE [dbo].[InventoryDrafts] CHECK CONSTRAINT [FK_InventoryDrafts_DescriptionLevel]
GO
ALTER TABLE [dbo].[InventoryDrafts]  WITH CHECK ADD  CONSTRAINT [FK_InventoryDrafts_FundDraft] FOREIGN KEY([FundDraftId])
REFERENCES [dbo].[FundDrafts] ([Id])
GO
ALTER TABLE [dbo].[InventoryDrafts] CHECK CONSTRAINT [FK_InventoryDrafts_FundDraft]
GO
ALTER TABLE [dbo].[InventoryDrafts]  WITH CHECK ADD  CONSTRAINT [FK_InventoryDrafts_PackageA] FOREIGN KEY([PackageAId])
REFERENCES [dbo].[Packages] ([Id])
GO
ALTER TABLE [dbo].[InventoryDrafts] CHECK CONSTRAINT [FK_InventoryDrafts_PackageA]
GO
ALTER TABLE [dbo].[InventoryDrafts]  WITH CHECK ADD  CONSTRAINT [FK_InventoryDrafts_PakageB] FOREIGN KEY([PackageBId])
REFERENCES [dbo].[Packages] ([Id])
GO
ALTER TABLE [dbo].[InventoryDrafts] CHECK CONSTRAINT [FK_InventoryDrafts_PakageB]
GO
ALTER TABLE [dbo].[InventoryDrafts]  WITH CHECK ADD  CONSTRAINT [FK_InventoryDrafts_Status] FOREIGN KEY([StatusCode])
REFERENCES [N].[Status] ([Code])
GO
ALTER TABLE [dbo].[InventoryDrafts] CHECK CONSTRAINT [FK_InventoryDrafts_Status]
GO
ALTER TABLE [dbo].[InventoryDrafts]  WITH CHECK ADD  CONSTRAINT [FK_InventoryDrafts_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[InventoryDrafts] CHECK CONSTRAINT [FK_InventoryDrafts_UpdatedBy]
GO
ALTER TABLE [dbo].[InventoryRawToNormal]  WITH CHECK ADD  CONSTRAINT [FK_InventoryRawToNormal_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[InventoryRawToNormal] CHECK CONSTRAINT [FK_InventoryRawToNormal_Archive]
GO
ALTER TABLE [dbo].[InventoryRawToNormal]  WITH CHECK ADD  CONSTRAINT [FK_InventoryRawToNormal_Process] FOREIGN KEY([ProcessId])
REFERENCES [dbo].[Process] ([Id])
GO
ALTER TABLE [dbo].[InventoryRawToNormal] CHECK CONSTRAINT [FK_InventoryRawToNormal_Process]
GO
ALTER TABLE [dbo].[NomenclatureValues]  WITH CHECK ADD  CONSTRAINT [FK_NomenclatureValues_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[NomenclatureValues] CHECK CONSTRAINT [FK_NomenclatureValues_CreatedBy]
GO
ALTER TABLE [dbo].[NomenclatureValues]  WITH CHECK ADD  CONSTRAINT [FK_NomenclatureValues_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[NomenclatureValues] CHECK CONSTRAINT [FK_NomenclatureValues_DeletedBy]
GO
ALTER TABLE [dbo].[NomenclatureValues]  WITH CHECK ADD  CONSTRAINT [FK_NomenclatureValues_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[NomenclatureValues] CHECK CONSTRAINT [FK_NomenclatureValues_UpdatedBy]
GO
ALTER TABLE [dbo].[PackageADocsTemplates]  WITH CHECK ADD  CONSTRAINT [FK_PackageADocsTemplates_AspNetUsers] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[PackageADocsTemplates] CHECK CONSTRAINT [FK_PackageADocsTemplates_AspNetUsers]
GO
ALTER TABLE [dbo].[PackageADocsTemplates]  WITH CHECK ADD  CONSTRAINT [FK_PackageADocsTemplates_AspNetUsers1] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[PackageADocsTemplates] CHECK CONSTRAINT [FK_PackageADocsTemplates_AspNetUsers1]
GO
ALTER TABLE [dbo].[PackageADocsTemplates]  WITH CHECK ADD  CONSTRAINT [FK_PackageADocsTemplates_Files] FOREIGN KEY([DocumentId])
REFERENCES [dbo].[Files] ([Id])
GO
ALTER TABLE [dbo].[PackageADocsTemplates] CHECK CONSTRAINT [FK_PackageADocsTemplates_Files]
GO
ALTER TABLE [dbo].[PackageADocsTemplates]  WITH CHECK ADD  CONSTRAINT [FK_PackageADocsTemplates_Procedures] FOREIGN KEY([ProcedureId])
REFERENCES [N].[ProcessTypes] ([Id])
GO
ALTER TABLE [dbo].[PackageADocsTemplates] CHECK CONSTRAINT [FK_PackageADocsTemplates_Procedures]
GO
ALTER TABLE [dbo].[PackageADocsTemplates]  WITH CHECK ADD  CONSTRAINT [FK_PackageADocsTemplates_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[PackageADocsTemplates] CHECK CONSTRAINT [FK_PackageADocsTemplates_UpdatedBy]
GO
ALTER TABLE [dbo].[PackageDocument]  WITH CHECK ADD  CONSTRAINT [FK_PackageDocument_AspNetUsers] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[PackageDocument] CHECK CONSTRAINT [FK_PackageDocument_AspNetUsers]
GO
ALTER TABLE [dbo].[PackageDocument]  WITH CHECK ADD  CONSTRAINT [FK_PackageDocument_AspNetUsers1] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[PackageDocument] CHECK CONSTRAINT [FK_PackageDocument_AspNetUsers1]
GO
ALTER TABLE [dbo].[PackageDocument]  WITH CHECK ADD  CONSTRAINT [FK_PackageDocument_AspNetUsers2] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[PackageDocument] CHECK CONSTRAINT [FK_PackageDocument_AspNetUsers2]
GO
ALTER TABLE [dbo].[PackageDocument]  WITH CHECK ADD  CONSTRAINT [FK_PackageDocument_Packages] FOREIGN KEY([PackageId])
REFERENCES [dbo].[Packages] ([Id])
GO
ALTER TABLE [dbo].[PackageDocument] CHECK CONSTRAINT [FK_PackageDocument_Packages]
GO
ALTER TABLE [dbo].[PackageDocument]  WITH CHECK ADD  CONSTRAINT [FK_PackageDocument_ProcDocType] FOREIGN KEY([DocTypeId])
REFERENCES [dbo].[PackageADocsTemplates] ([Id])
GO
ALTER TABLE [dbo].[PackageDocument] CHECK CONSTRAINT [FK_PackageDocument_ProcDocType]
GO
ALTER TABLE [dbo].[Packages]  WITH CHECK ADD  CONSTRAINT [FK_Packages_AspNetUsers] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Packages] CHECK CONSTRAINT [FK_Packages_AspNetUsers]
GO
ALTER TABLE [dbo].[Packages]  WITH CHECK ADD  CONSTRAINT [FK_Packages_AspNetUsers1] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Packages] CHECK CONSTRAINT [FK_Packages_AspNetUsers1]
GO
ALTER TABLE [dbo].[Packages]  WITH CHECK ADD  CONSTRAINT [FK_Packages_AspNetUsers2] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Packages] CHECK CONSTRAINT [FK_Packages_AspNetUsers2]
GO
ALTER TABLE [dbo].[Packages]  WITH CHECK ADD  CONSTRAINT [FK_Packages_Inventory] FOREIGN KEY([Id])
REFERENCES [dbo].[Packages] ([Id])
GO
ALTER TABLE [dbo].[Packages] CHECK CONSTRAINT [FK_Packages_Inventory]
GO
ALTER TABLE [dbo].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Process_ArchivalEntity] FOREIGN KEY([ArchivalEntityId])
REFERENCES [dbo].[ArchivalEntities] ([Id])
GO
ALTER TABLE [dbo].[Process] CHECK CONSTRAINT [FK_Process_ArchivalEntity]
GO
ALTER TABLE [dbo].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Process_Archive] FOREIGN KEY([ArchiveId])
REFERENCES [dbo].[Archives] ([Id])
GO
ALTER TABLE [dbo].[Process] CHECK CONSTRAINT [FK_Process_Archive]
GO
ALTER TABLE [dbo].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Process_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Process] CHECK CONSTRAINT [FK_Process_CreatedBy]
GO
ALTER TABLE [dbo].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Process_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Process] CHECK CONSTRAINT [FK_Process_DeletedBy]
GO
ALTER TABLE [dbo].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Process_Document] FOREIGN KEY([DocumentId])
REFERENCES [dbo].[Documents] ([Id])
GO
ALTER TABLE [dbo].[Process] CHECK CONSTRAINT [FK_Process_Document]
GO
ALTER TABLE [dbo].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Process_Fund] FOREIGN KEY([FundId])
REFERENCES [dbo].[Funds] ([Id])
GO
ALTER TABLE [dbo].[Process] CHECK CONSTRAINT [FK_Process_Fund]
GO
ALTER TABLE [dbo].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Process_Inventory] FOREIGN KEY([InventoryId])
REFERENCES [dbo].[Inventories] ([Id])
GO
ALTER TABLE [dbo].[Process] CHECK CONSTRAINT [FK_Process_Inventory]
GO
ALTER TABLE [dbo].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Process_ProcessType] FOREIGN KEY([ProcessTypeId])
REFERENCES [N].[ProcessTypes] ([Id])
GO
ALTER TABLE [dbo].[Process] CHECK CONSTRAINT [FK_Process_ProcessType]
GO
ALTER TABLE [dbo].[Process]  WITH CHECK ADD  CONSTRAINT [FK_Process_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Process] CHECK CONSTRAINT [FK_Process_UpdatedBy]
GO
ALTER TABLE [dbo].[ProcessRelatedSteps]  WITH CHECK ADD  CONSTRAINT [FK_ProcessRelatedSteps_ProcessSteps] FOREIGN KEY([StepId])
REFERENCES [N].[ProcessSteps] ([Id])
GO
ALTER TABLE [dbo].[ProcessRelatedSteps] CHECK CONSTRAINT [FK_ProcessRelatedSteps_ProcessSteps]
GO
ALTER TABLE [dbo].[ProcessRelatedSteps]  WITH CHECK ADD  CONSTRAINT [FK_ProcessRelatedSteps_ProcessSteps1] FOREIGN KEY([NextStepId])
REFERENCES [N].[ProcessSteps] ([Id])
GO
ALTER TABLE [dbo].[ProcessRelatedSteps] CHECK CONSTRAINT [FK_ProcessRelatedSteps_ProcessSteps1]
GO
ALTER TABLE [dbo].[ProcessRelatedSteps]  WITH CHECK ADD  CONSTRAINT [FK_ProcessRelatedSteps_ProcessSteps2] FOREIGN KEY([PrevStepId])
REFERENCES [N].[ProcessSteps] ([Id])
GO
ALTER TABLE [dbo].[ProcessRelatedSteps] CHECK CONSTRAINT [FK_ProcessRelatedSteps_ProcessSteps2]
GO
ALTER TABLE [dbo].[ProcessRelatedSteps]  WITH CHECK ADD  CONSTRAINT [FK_ProcessRelatedSteps_ProcessTypes] FOREIGN KEY([ProcessTypeId])
REFERENCES [N].[ProcessTypes] ([Id])
GO
ALTER TABLE [dbo].[ProcessRelatedSteps] CHECK CONSTRAINT [FK_ProcessRelatedSteps_ProcessTypes]
GO
ALTER TABLE [dbo].[ProcessTimeline]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTimeline_AssignedTo] FOREIGN KEY([AssignedToUserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ProcessTimeline] CHECK CONSTRAINT [FK_ProcessTimeline_AssignedTo]
GO
ALTER TABLE [dbo].[ProcessTimeline]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTimeline_AssignedToRole] FOREIGN KEY([AssignedToRoleId])
REFERENCES [dbo].[AspNetRoles] ([Id])
GO
ALTER TABLE [dbo].[ProcessTimeline] CHECK CONSTRAINT [FK_ProcessTimeline_AssignedToRole]
GO
ALTER TABLE [dbo].[ProcessTimeline]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTimeline_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ProcessTimeline] CHECK CONSTRAINT [FK_ProcessTimeline_CreatedBy]
GO
ALTER TABLE [dbo].[ProcessTimeline]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTimeline_Process] FOREIGN KEY([ProcessId])
REFERENCES [dbo].[Process] ([Id])
GO
ALTER TABLE [dbo].[ProcessTimeline] CHECK CONSTRAINT [FK_ProcessTimeline_Process]
GO
ALTER TABLE [dbo].[ProcessTimeline]  WITH CHECK ADD  CONSTRAINT [FK_ProcessTimeline_StepType] FOREIGN KEY([StepTypeId])
REFERENCES [N].[ProcessSteps] ([Id])
GO
ALTER TABLE [dbo].[ProcessTimeline] CHECK CONSTRAINT [FK_ProcessTimeline_StepType]
GO
ALTER TABLE [dbo].[SessionAgenda]  WITH CHECK ADD  CONSTRAINT [FK_SessionAgenda_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[SessionAgenda] CHECK CONSTRAINT [FK_SessionAgenda_CreatedBy]
GO
ALTER TABLE [dbo].[SessionAgenda]  WITH CHECK ADD  CONSTRAINT [FK_SessionAgenda_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[SessionAgenda] CHECK CONSTRAINT [FK_SessionAgenda_DeletedBy]
GO
ALTER TABLE [dbo].[SessionAgenda]  WITH CHECK ADD  CONSTRAINT [FK_SessionAgenda_Process] FOREIGN KEY([ProcessId])
REFERENCES [dbo].[Process] ([Id])
GO
ALTER TABLE [dbo].[SessionAgenda] CHECK CONSTRAINT [FK_SessionAgenda_Process]
GO
ALTER TABLE [dbo].[SessionAgenda]  WITH CHECK ADD  CONSTRAINT [FK_SessionAgenda_Report] FOREIGN KEY([ReportId])
REFERENCES [dbo].[EPKReports] ([Id])
GO
ALTER TABLE [dbo].[SessionAgenda] CHECK CONSTRAINT [FK_SessionAgenda_Report]
GO
ALTER TABLE [dbo].[SessionAgenda]  WITH CHECK ADD  CONSTRAINT [FK_SessionAgenda_Session] FOREIGN KEY([SessionId])
REFERENCES [dbo].[Sessions] ([Id])
GO
ALTER TABLE [dbo].[SessionAgenda] CHECK CONSTRAINT [FK_SessionAgenda_Session]
GO
ALTER TABLE [dbo].[SessionAgenda]  WITH CHECK ADD  CONSTRAINT [FK_SessionAgenda_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[SessionAgenda] CHECK CONSTRAINT [FK_SessionAgenda_UpdatedBy]
GO
ALTER TABLE [dbo].[SessionAgendaStandpoints]  WITH CHECK ADD  CONSTRAINT [FK_SessionAgendaStandpoint_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[SessionAgendaStandpoints] CHECK CONSTRAINT [FK_SessionAgendaStandpoint_CreatedBy]
GO
ALTER TABLE [dbo].[SessionAgendaStandpoints]  WITH CHECK ADD  CONSTRAINT [FK_SessionAgendaStandpoint_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[SessionAgendaStandpoints] CHECK CONSTRAINT [FK_SessionAgendaStandpoint_DeletedBy]
GO
ALTER TABLE [dbo].[SessionAgendaStandpoints]  WITH CHECK ADD  CONSTRAINT [FK_SessionAgendaStandpoint_SessionAgenda] FOREIGN KEY([SessionAgendaItemId])
REFERENCES [dbo].[SessionAgenda] ([Id])
GO
ALTER TABLE [dbo].[SessionAgendaStandpoints] CHECK CONSTRAINT [FK_SessionAgendaStandpoint_SessionAgenda]
GO
ALTER TABLE [dbo].[SessionAgendaStandpoints]  WITH CHECK ADD  CONSTRAINT [FK_SessionAgendaStandpoint_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[SessionAgendaStandpoints] CHECK CONSTRAINT [FK_SessionAgendaStandpoint_UpdatedBy]
GO
ALTER TABLE [dbo].[SessionDecisions]  WITH CHECK ADD  CONSTRAINT [FK_SessionDecisions_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[SessionDecisions] CHECK CONSTRAINT [FK_SessionDecisions_CreatedBy]
GO
ALTER TABLE [dbo].[SessionDecisions]  WITH CHECK ADD  CONSTRAINT [FK_SessionDecisions_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[SessionDecisions] CHECK CONSTRAINT [FK_SessionDecisions_DeletedBy]
GO
ALTER TABLE [dbo].[SessionDecisions]  WITH CHECK ADD  CONSTRAINT [FK_SessionDecisions_SessionAgenda] FOREIGN KEY([SessionAgendaId])
REFERENCES [dbo].[SessionAgenda] ([Id])
GO
ALTER TABLE [dbo].[SessionDecisions] CHECK CONSTRAINT [FK_SessionDecisions_SessionAgenda]
GO
ALTER TABLE [dbo].[SessionDecisions]  WITH CHECK ADD  CONSTRAINT [FK_SessionDecisions_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[SessionDecisions] CHECK CONSTRAINT [FK_SessionDecisions_UpdatedBy]
GO
ALTER TABLE [dbo].[SessionMinutesOfMeeting]  WITH CHECK ADD  CONSTRAINT [FK_SessionMinOfMeeting_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[SessionMinutesOfMeeting] CHECK CONSTRAINT [FK_SessionMinOfMeeting_CreatedBy]
GO
ALTER TABLE [dbo].[SessionMinutesOfMeeting]  WITH CHECK ADD  CONSTRAINT [FK_SessionMinOfMeeting_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[SessionMinutesOfMeeting] CHECK CONSTRAINT [FK_SessionMinOfMeeting_DeletedBy]
GO
ALTER TABLE [dbo].[SessionMinutesOfMeeting]  WITH CHECK ADD  CONSTRAINT [FK_SessionMinOfMeeting_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[SessionMinutesOfMeeting] CHECK CONSTRAINT [FK_SessionMinOfMeeting_UpdatedBy]
GO
ALTER TABLE [dbo].[Sessions]  WITH CHECK ADD FOREIGN KEY([AssignedToChairmanId])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Sessions]  WITH CHECK ADD FOREIGN KEY([AssignedToSecretarId])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Sessions]  WITH CHECK ADD FOREIGN KEY([SessionType])
REFERENCES [N].[SessionTypes] ([Code])
GO
ALTER TABLE [dbo].[Sessions]  WITH CHECK ADD  CONSTRAINT [FK_Session_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Sessions] CHECK CONSTRAINT [FK_Session_CreatedBy]
GO
ALTER TABLE [dbo].[Sessions]  WITH CHECK ADD  CONSTRAINT [FK_Session_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Sessions] CHECK CONSTRAINT [FK_Session_DeletedBy]
GO
ALTER TABLE [dbo].[Sessions]  WITH CHECK ADD  CONSTRAINT [FK_Session_MinutesOfMeeting] FOREIGN KEY([MinutesOfMeetingId])
REFERENCES [dbo].[SessionMinutesOfMeeting] ([Id])
GO
ALTER TABLE [dbo].[Sessions] CHECK CONSTRAINT [FK_Session_MinutesOfMeeting]
GO
ALTER TABLE [dbo].[Sessions]  WITH CHECK ADD  CONSTRAINT [FK_Session_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Sessions] CHECK CONSTRAINT [FK_Session_UpdatedBy]
GO
ALTER TABLE [dbo].[Tasks]  WITH CHECK ADD  CONSTRAINT [FK_Task_Status] FOREIGN KEY([StatusCode])
REFERENCES [N].[TaskStatus] ([Code])
GO
ALTER TABLE [dbo].[Tasks] CHECK CONSTRAINT [FK_Task_Status]
GO
ALTER TABLE [dbo].[Tasks]  WITH CHECK ADD  CONSTRAINT [FK_Tasks_AssignedToUser] FOREIGN KEY([AssignedToUserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Tasks] CHECK CONSTRAINT [FK_Tasks_AssignedToUser]
GO
ALTER TABLE [dbo].[Tasks]  WITH CHECK ADD  CONSTRAINT [FK_Tasks_CreatedByUser] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Tasks] CHECK CONSTRAINT [FK_Tasks_CreatedByUser]
GO
ALTER TABLE [dbo].[Tasks]  WITH CHECK ADD  CONSTRAINT [FK_Tasks_DeletedByUser] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Tasks] CHECK CONSTRAINT [FK_Tasks_DeletedByUser]
GO
ALTER TABLE [dbo].[Tasks]  WITH CHECK ADD  CONSTRAINT [FK_Tasks_Process] FOREIGN KEY([ProcessId])
REFERENCES [dbo].[Process] ([Id])
GO
ALTER TABLE [dbo].[Tasks] CHECK CONSTRAINT [FK_Tasks_Process]
GO
ALTER TABLE [dbo].[Tasks]  WITH CHECK ADD  CONSTRAINT [FK_Tasks_TimelineStep] FOREIGN KEY([StepId])
REFERENCES [dbo].[ProcessTimeline] ([Id])
GO
ALTER TABLE [dbo].[Tasks] CHECK CONSTRAINT [FK_Tasks_TimelineStep]
GO
ALTER TABLE [dbo].[Tasks]  WITH CHECK ADD  CONSTRAINT [FK_Tasks_UpdatedByUser] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[Tasks] CHECK CONSTRAINT [FK_Tasks_UpdatedByUser]
GO
ALTER TABLE [dbo].[TaskTemplates]  WITH CHECK ADD  CONSTRAINT [FK_TaskTemplate_StepType] FOREIGN KEY([ProcessStepTypeId])
REFERENCES [N].[ProcessSteps] ([Id])
GO
ALTER TABLE [dbo].[TaskTemplates] CHECK CONSTRAINT [FK_TaskTemplate_StepType]
GO
ALTER TABLE [dbo].[TaskTemplatesSteps]  WITH CHECK ADD  CONSTRAINT [FK__TaskTempl__Proce__561FABFB] FOREIGN KEY([ProcessStep_Id])
REFERENCES [N].[ProcessSteps] ([Id])
GO
ALTER TABLE [dbo].[TaskTemplatesSteps] CHECK CONSTRAINT [FK__TaskTempl__Proce__561FABFB]
GO
ALTER TABLE [dbo].[TaskTemplatesSteps]  WITH CHECK ADD FOREIGN KEY([TaskTemplate_Id])
REFERENCES [dbo].[TaskTemplates] ([Id])
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProcedures]  WITH CHECK ADD  CONSTRAINT [FK_ValuableDocsCollectingProcedures_AspNetUsers] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProcedures] CHECK CONSTRAINT [FK_ValuableDocsCollectingProcedures_AspNetUsers]
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProcedures]  WITH CHECK ADD  CONSTRAINT [FK_ValuableDocsCollectingProcedures_AspNetUsers1] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProcedures] CHECK CONSTRAINT [FK_ValuableDocsCollectingProcedures_AspNetUsers1]
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProcedures]  WITH CHECK ADD  CONSTRAINT [FK_ValuableDocsCollectingProcedures_AspNetUsers2] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProcedures] CHECK CONSTRAINT [FK_ValuableDocsCollectingProcedures_AspNetUsers2]
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProcedures]  WITH CHECK ADD  CONSTRAINT [FK_ValuableDocsCollectingProcedures_DocsCollectingProcedureTypes] FOREIGN KEY([TypeId])
REFERENCES [N].[DocsCollectingProcedureTypes] ([Id])
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProcedures] CHECK CONSTRAINT [FK_ValuableDocsCollectingProcedures_DocsCollectingProcedureTypes]
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProcedures]  WITH CHECK ADD  CONSTRAINT [FK_ValuableDocsCollectingProcedures_ValuableDocsCollectingRequest] FOREIGN KEY([RequestId])
REFERENCES [dbo].[ValuableDocsCollectingRequest] ([Id])
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProcedures] CHECK CONSTRAINT [FK_ValuableDocsCollectingProcedures_ValuableDocsCollectingRequest]
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProceduresHistory]  WITH CHECK ADD  CONSTRAINT [FK_ValuableDocsCollectingProceduresHistory_AspNetUsers] FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProceduresHistory] CHECK CONSTRAINT [FK_ValuableDocsCollectingProceduresHistory_AspNetUsers]
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProceduresHistory]  WITH CHECK ADD  CONSTRAINT [FK_ValuableDocsCollectingProceduresHistory_ValuableDocsCollectingProcedures] FOREIGN KEY([ProcId])
REFERENCES [dbo].[ValuableDocsCollectingProcedures] ([Id])
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProceduresHistory] CHECK CONSTRAINT [FK_ValuableDocsCollectingProceduresHistory_ValuableDocsCollectingProcedures]
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProceduresSteps]  WITH CHECK ADD  CONSTRAINT [FK_ValuableDocsCollectingProceduresSteps_AspNetUsers] FOREIGN KEY([ResponsibleUserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProceduresSteps] CHECK CONSTRAINT [FK_ValuableDocsCollectingProceduresSteps_AspNetUsers]
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProceduresSteps]  WITH CHECK ADD  CONSTRAINT [FK_ValuableDocsCollectingProceduresSteps_DocsCollectingProcedureSteps] FOREIGN KEY([StepId])
REFERENCES [N].[DocsCollectingProcedureSteps] ([Id])
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProceduresSteps] CHECK CONSTRAINT [FK_ValuableDocsCollectingProceduresSteps_DocsCollectingProcedureSteps]
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProceduresSteps]  WITH CHECK ADD  CONSTRAINT [FK_ValuableDocsCollectingProceduresSteps_ValuableDocsCollectingProcedures] FOREIGN KEY([ProcId])
REFERENCES [dbo].[ValuableDocsCollectingProcedures] ([Id])
GO
ALTER TABLE [dbo].[ValuableDocsCollectingProceduresSteps] CHECK CONSTRAINT [FK_ValuableDocsCollectingProceduresSteps_ValuableDocsCollectingProcedures]
GO
ALTER TABLE [dbo].[ValuableDocsCollectingRequest]  WITH CHECK ADD  CONSTRAINT [FK_ValuableDocsCollectingRequest_AspNetUsers] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ValuableDocsCollectingRequest] CHECK CONSTRAINT [FK_ValuableDocsCollectingRequest_AspNetUsers]
GO
ALTER TABLE [dbo].[ValuableDocsCollectingRequest]  WITH CHECK ADD  CONSTRAINT [FK_ValuableDocsCollectingRequest_AspNetUsers1] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ValuableDocsCollectingRequest] CHECK CONSTRAINT [FK_ValuableDocsCollectingRequest_AspNetUsers1]
GO
ALTER TABLE [dbo].[ValuableDocsCollectingRequest]  WITH CHECK ADD  CONSTRAINT [FK_ValuableDocsCollectingRequest_AspNetUsers2] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [dbo].[ValuableDocsCollectingRequest] CHECK CONSTRAINT [FK_ValuableDocsCollectingRequest_AspNetUsers2]
GO
ALTER TABLE [HangFire].[JobParameter]  WITH CHECK ADD  CONSTRAINT [FK_HangFire_JobParameter_Job] FOREIGN KEY([JobId])
REFERENCES [HangFire].[Job] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [HangFire].[JobParameter] CHECK CONSTRAINT [FK_HangFire_JobParameter_Job]
GO
ALTER TABLE [HangFire].[State]  WITH CHECK ADD  CONSTRAINT [FK_HangFire_State_Job] FOREIGN KEY([JobId])
REFERENCES [HangFire].[Job] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [HangFire].[State] CHECK CONSTRAINT [FK_HangFire_State_Job]
GO
ALTER TABLE [N].[Nomenclatures]  WITH CHECK ADD  CONSTRAINT [FK_Nomenclatures_CreatedBy] FOREIGN KEY([CreatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [N].[Nomenclatures] CHECK CONSTRAINT [FK_Nomenclatures_CreatedBy]
GO
ALTER TABLE [N].[Nomenclatures]  WITH CHECK ADD  CONSTRAINT [FK_Nomenclatures_DeletedBy] FOREIGN KEY([DeletedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [N].[Nomenclatures] CHECK CONSTRAINT [FK_Nomenclatures_DeletedBy]
GO
ALTER TABLE [N].[Nomenclatures]  WITH CHECK ADD  CONSTRAINT [FK_Nomenclatures_Parent] FOREIGN KEY([ParentId])
REFERENCES [N].[Nomenclatures] ([Id])
GO
ALTER TABLE [N].[Nomenclatures] CHECK CONSTRAINT [FK_Nomenclatures_Parent]
GO
ALTER TABLE [N].[Nomenclatures]  WITH CHECK ADD  CONSTRAINT [FK_Nomenclatures_UpdatedBy] FOREIGN KEY([UpdatedBy])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [N].[Nomenclatures] CHECK CONSTRAINT [FK_Nomenclatures_UpdatedBy]
GO
ALTER TABLE [N].[ProcessSteps]  WITH CHECK ADD  CONSTRAINT [FK_ProcessStep_ProcessType] FOREIGN KEY([ProcessTypeId])
REFERENCES [N].[ProcessTypes] ([Id])
GO
ALTER TABLE [N].[ProcessSteps] CHECK CONSTRAINT [FK_ProcessStep_ProcessType]
GO
ALTER TABLE [Notification].[Notification]  WITH CHECK ADD  CONSTRAINT [FK_Notification_Template] FOREIGN KEY([NotificationTemplateId])
REFERENCES [Notification].[NotificationTemplate] ([Id])
GO
ALTER TABLE [Notification].[Notification] CHECK CONSTRAINT [FK_Notification_Template]
GO
ALTER TABLE [Notification].[Notification]  WITH CHECK ADD  CONSTRAINT [FK_Notification_ToUser] FOREIGN KEY([ToUserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO
ALTER TABLE [Notification].[Notification] CHECK CONSTRAINT [FK_Notification_ToUser]
GO
ALTER TABLE [Notification].[NotificationEvent]  WITH CHECK ADD  CONSTRAINT [FK_NotificationEvent_NotificationType] FOREIGN KEY([NotificationTypeCode])
REFERENCES [N].[NotificationType] ([Code])
GO
ALTER TABLE [Notification].[NotificationEvent] CHECK CONSTRAINT [FK_NotificationEvent_NotificationType]
GO
ALTER TABLE [Notification].[NotificationTemplate]  WITH CHECK ADD  CONSTRAINT [FK_NotificationTemplate_NotificationType] FOREIGN KEY([NotificationTypeCode])
REFERENCES [N].[NotificationType] ([Code])
GO
ALTER TABLE [Notification].[NotificationTemplate] CHECK CONSTRAINT [FK_NotificationTemplate_NotificationType]
GO



commit
-- rollback