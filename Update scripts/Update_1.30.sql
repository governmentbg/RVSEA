SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.30'
where Code = 'DB_VERSION'
go

--Process mappings
ALTER TABLE N.ProcessTypes
ALTER COLUMN [Type] NVARCHAR(50) NULL
GO

CREATE TABLE dbo.ProcessTypeLevels (
	[ProcessTypeId] int NOT NULL,
	[EntityType] nvarchar(50) NOT NULL,
	[Inactive] bit NOT NULL CONSTRAINT [DF_Inactive] DEFAULT 0
 CONSTRAINT [PK_ProcessTypeLevels] PRIMARY KEY CLUSTERED 
(
	[ProcessTypeId], [EntityType]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE dbo.ProcessTypeLevels  WITH CHECK ADD  CONSTRAINT [FK_ProcessTypeLevels_ProcessType] FOREIGN KEY(ProcessTypeId)
REFERENCES N.ProcessTypes (Id)
GO

ALTER TABLE dbo.ProcessTypeLevels CHECK CONSTRAINT [FK_ProcessTypeLevels_ProcessType]
GO


IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 1 and EntityType = 'fund')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (1,'fund')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 2 and EntityType = 'fund')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (2, 'fund')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 4 and EntityType = 'film')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (4, 'film')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 5 and EntityType = 'film')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (5, 'film')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 6 and EntityType = 'film')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (6, 'film')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 7 and EntityType = 'archival_entity')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (7, 'archival_entity')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 8 and EntityType = 'archival_entity')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (8, 'archival_entity')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 9 and EntityType = 'document')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (9,	'document')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 10 and EntityType = 'fund')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (10,	'fund')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 10 and EntityType = 'raw_fund')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (10,	'raw_fund')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 10 and EntityType = 'chp')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (10,	'chp')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 10 and EntityType = 'memory')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (10,	'memory')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 10 and EntityType = 'inventory')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (10,	'inventory')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 10 and EntityType = 'raw_inventory')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (10,	'raw_inventory')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 10 and EntityType = 'archival_entity')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (10,	'archival_entity')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 10 and EntityType = 'document')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (10,	'document')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 11 and EntityType = 'fund')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (11,	'fund')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 11 and EntityType = 'raw_fund')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (11,	'raw_fund')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 11 and EntityType = 'chp')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (11,	'chp')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 11 and EntityType = 'memory')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (11,	'memory')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 11 and EntityType = 'inventory')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (11,	'inventory')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 11 and EntityType = 'raw_inventory')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (11,	'raw_inventory')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 11 and EntityType = 'archival_entity')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (11,	'archival_entity')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 11 and EntityType = 'document')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (11,	'document')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 12 and EntityType = 'fund')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (12,	'fund')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 12 and EntityType = 'chp')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (12,	'chp')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 12 and EntityType = 'memory')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (12,	'memory')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 12 and EntityType = 'inventory')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (12,	'inventory')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 12 and EntityType = 'archival_entity')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (12,	'archival_entity')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 12 and EntityType = 'document')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (12,	'document')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 13 and EntityType = 'fund')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (13,	'fund')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 13 and EntityType = 'raw_fund')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (13,	'raw_fund')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 14 and EntityType = 'raw_fund')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (14,	'raw_fund')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 15 and EntityType = 'archive')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (15,	'archive')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 16 and EntityType = 'archive')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (16,	'archive')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 17 and EntityType = 'raw_fund')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (17,	'raw_fund')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 18 and EntityType = 'fund')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (18,	'fund')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 19 and EntityType = 'fund')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (19,	'fund')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 10 and EntityType = 'system_inventory')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (10,	'system_inventory')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 11 and EntityType = 'system_inventory')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (11,	'system_inventory')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 12 and EntityType = 'system_inventory')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (12,	'system_inventory')
GO

--END Process mappings

--CLEANUP
DROP TABLE IF EXISTS dbo.DocumentDigitalObjects

--END CLEANUP

-- ProcessTypes
IF NOT EXISTS (SELECT 1 FROM N.ProcessTypes WHERE Id = 20)
INSERT INTO N.ProcessTypes (Id, Name, Code) VALUES (20, 'Регистриране на служебен опис', 'AddSystemInventory')
GO

IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 20 and EntityType = 'chp')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (20,'chp')
IF NOT EXISTS(select 1 from dbo.ProcessTypeLevels where ProcessTypeId = 20 and EntityType = 'memory')
INSERT INTO dbo.ProcessTypeLevels (ProcessTypeId, EntityType) VALUES (20,'memory')
GO
--END ProcessTypes

--Task templates

--Check tempplate name!
IF NOT EXISTS (SELECT 1 FROM TaskTemplatesSteps WHERE ProcessStep_Id = 1003)
INSERT INTO TaskTemplatesSteps (TaskTemplate_Id, ProcessStep_Id)
SELECT Id, 1003 FROM TaskTemplates WHERE Title = 'Изискани са корекции' AND ProcessStepTypeId IS NULL
GO

UPDATE N.ProcessSteps SET  AllowTaskTemplate = 1 WHERE Id = 1010
GO
--Check tempplate name!
IF NOT EXISTS (SELECT 1 FROM TaskTemplatesSteps WHERE ProcessStep_Id = 1010)
INSERT INTO TaskTemplatesSteps (TaskTemplate_Id, ProcessStep_Id)
SELECT Id, 1010 FROM TaskTemplates WHERE Title = 'Връщане за корекции' AND ProcessStepTypeId IS NULL
GO

IF NOT EXISTS (SELECT 1 FROM TaskTemplatesSteps WHERE ProcessStep_Id = 1013)
INSERT INTO TaskTemplatesSteps (TaskTemplate_Id, ProcessStep_Id)
SELECT Id, 1013 FROM TaskTemplates WHERE Title = 'Одобрение на доклад' AND ProcessStepTypeId IS NULL
GO

UPDATE N.ProcessSteps SET  AllowTaskTemplate = 1 WHERE Id = 1014
GO
--Check tempplate name!
IF NOT EXISTS (SELECT 1 FROM TaskTemplatesSteps WHERE ProcessStep_Id = 1014)
INSERT INTO TaskTemplatesSteps (TaskTemplate_Id, ProcessStep_Id)
SELECT Id, 1014 FROM TaskTemplates WHERE Title = 'Регистриране' AND ProcessStepTypeId IS NULL
GO
--END Task templates

--Process related steps
IF NOT EXISTS (SELECT 1 FROM ProcessRelatedSteps WHERE  ProcessTypeId = 20 AND StepId = 1010)
INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId, PrevStepId, AsigneeGoups) VALUES(20, 1010, 1012, 1011, 'B')
GO

IF NOT EXISTS (SELECT 1 FROM ProcessRelatedSteps WHERE  ProcessTypeId = 20 AND StepId = 1000)
INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId, PrevStepId, AsigneeGoups) VALUES(20,	1000,	1001,	NULL,	'B')
IF NOT EXISTS (SELECT 1 FROM ProcessRelatedSteps WHERE  ProcessTypeId = 20 AND StepId = 1001)
INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId, PrevStepId, AsigneeGoups) VALUES(20,	1001,	1002,	1000,	'B')
IF NOT EXISTS (SELECT 1 FROM ProcessRelatedSteps WHERE  ProcessTypeId = 20 AND StepId = 1002)
INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId, PrevStepId, AsigneeGoups) VALUES(20,	1002,	1005,	1001,	'B')
IF NOT EXISTS (SELECT 1 FROM ProcessRelatedSteps WHERE  ProcessTypeId = 20 AND StepId = 1003)
INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId, PrevStepId, AsigneeGoups) VALUES(20,	1003,	1005,	1004,	'B')
IF NOT EXISTS (SELECT 1 FROM ProcessRelatedSteps WHERE  ProcessTypeId = 20 AND StepId = 1004)
INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId, PrevStepId, AsigneeGoups) VALUES(20,	1004,	1003,	NULL,	'B')
IF NOT EXISTS (SELECT 1 FROM ProcessRelatedSteps WHERE  ProcessTypeId = 20 AND StepId = 1005)
INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId, PrevStepId, AsigneeGoups) VALUES(20,	1005,	1006,	1002,	'V1')
IF NOT EXISTS (SELECT 1 FROM ProcessRelatedSteps WHERE  ProcessTypeId = 20 AND StepId = 1006)
INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId, PrevStepId, AsigneeGoups) VALUES(20,	1006,	1007,	1005,	'V4')
IF NOT EXISTS (SELECT 1 FROM ProcessRelatedSteps WHERE  ProcessTypeId = 20 AND StepId = 1007)
INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId, PrevStepId, AsigneeGoups) VALUES(20,	1007,	1008,	1006,	'V1')
IF NOT EXISTS (SELECT 1 FROM ProcessRelatedSteps WHERE  ProcessTypeId = 20 AND StepId = 1008)
INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId, PrevStepId, AsigneeGoups) VALUES(20,	1008,	1009,	1007,	'G,G2')
IF NOT EXISTS (SELECT 1 FROM ProcessRelatedSteps WHERE  ProcessTypeId = 20 AND StepId = 1009)
INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId, PrevStepId, AsigneeGoups) VALUES(20,	1009,	1014,	1008,	NULL)
IF NOT EXISTS (SELECT 1 FROM ProcessRelatedSteps WHERE  ProcessTypeId = 20 AND StepId = 1011)
INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId, PrevStepId, AsigneeGoups) VALUES(20,	1011,	1010,	NULL,	'B')
IF NOT EXISTS (SELECT 1 FROM ProcessRelatedSteps WHERE  ProcessTypeId = 20 AND StepId = 1012)
INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId, PrevStepId, AsigneeGoups) VALUES(20,	1012,	1013,	1010,	'V1')
IF NOT EXISTS (SELECT 1 FROM ProcessRelatedSteps WHERE  ProcessTypeId = 20 AND StepId = 1013)
INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId, PrevStepId, AsigneeGoups) VALUES(20,	1013,	1014,	1012,	'B')
IF NOT EXISTS (SELECT 1 FROM ProcessRelatedSteps WHERE  ProcessTypeId = 20 AND StepId = 1014)
INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId, PrevStepId, AsigneeGoups) VALUES(20,	1014,	1015,	1013,	'A')
IF NOT EXISTS (SELECT 1 FROM ProcessRelatedSteps WHERE  ProcessTypeId = 20 AND StepId = 1015)
INSERT INTO ProcessRelatedSteps (ProcessTypeId, StepId, NextStepId, PrevStepId, AsigneeGoups) VALUES(20,	1015,	NULL,	1015,	NULL)
GO
--END Process related steps


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE or ALTER   PROCEDURE [dbo].[sp_GetInventory] 
	@LinkedServer nvarchar(50),
	@Identifier int
AS
BEGIN
	SET NOCOUNT ON;

	declare @sql varchar(max) = '
		SELECT -1 as Id
			  ,NULL as SystemIdentifier
			  ,CAST(1 as bit) as HasExternalSource
			  ,inventory.[LGid] as ExternalIdentifier
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusText
			  ,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''3000-01-01 00:00:00.000'') as AvailabilityStatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''3000-01-01 00:00:00.000'') as AvailabilityStatusText
			  ,CAST(1 as bit) as FundHasExternalSource
			  ,(select f.LGid from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''3000-01-01 00:00:00.000'') as FundExternalIdentifier
			  ,(select f.Number from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''3000-01-01 00:00:00.000'') as FundNumber
			  ,(select a.Code from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveCode
			  ,(select a.Name from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveName
			  ,(select n.Value from [Archiving].[dbo].Nomenclature n where n.Gid = inventory.InventoryArrayGid and n._retired = ''3000-01-01 00:00:00.000'') as NumberArray
			  ,inventory.[IntNumber] as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.[TextDate] as ApproxmateChronologicalScope
			  ,inventory.[LinearMeter] as LinearMeters
			  ,inventory.[AECount] as ArchivalEntityCount
			  ,inventory.[BoxesCount] as BoxCount
			  ,inventory.[RuloniTubusiCount] as RollCount
			  ,inventory.[AEFonoDocsCount] as AudioDocumentArchivalEntityCount
			  ,inventory.[AEPhotoDocsCount] as PhotoDocumentArchivalEntityCount
			  ,inventory.[AEVideoAudioDocsCount] as VideoDocumentArchivalEntityCount
			  ,inventory.[AEElectrDocsCount] as DigitalDocumentArchivalEntityCount
			  ,inventory.[ExtentOther] as OtherMetrics
			  ,inventory.[FundCreatorNameChanges] as FundCreatorTitleHistory
			  ,inventory.[FundFormerHistory] as FundCreatorBiographicalHistory
			  ,inventory.[ArchivalHistory] as History
			  ,inventory.[ImmediateSourceOfAcquisition] as DocumentsProvider
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''MethodOfAcquisition'' for XML PATH('''')), 1, 1, '''') as AcquisitionMethodText
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''CreatingType'' for XML PATH('''')), 1, 1, '''') as CreationMethodText
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''Originality'' for XML PATH('''')), 1, 1, '''') as OriginalityText
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''Language'' for XML PATH('''')), 1, 1, '''') as LanguageText
			  ,inventory.[ClassificationScheme] as ClassificationScheme
			  ,inventory.[AccessConditions] as DocumentsAccessDescription
			  ,inventory.[Abbreviations] as AbbreviationList
			  ,inventory.[CopyMicrofilmAE] as MicrofilmedArchivalEntityCount
			  ,inventory.[CopyNegativFrames] as NegativeFrameCount
			  ,inventory.[CopyPositiveFrames] as PositiveFrameCount
			  ,inventory.[CopyDigitizedAE] as DigitizedArchivalEntityCount
			  ,inventory.[Note] as Notes
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelText
			  ,inventory.[DocumentProperties] as DocumentsDescription
			  ,inventory.[StartDateYear] as StartDateYear
			  ,inventory.[StartDateMonth] as StartDateMonth
			  ,inventory.[StartDateDay] as StartDateDay
			  ,inventory.[EndDateYear] as EndDateYear
			  ,inventory.[EndDateMonth] as EndDateMonth
			  ,inventory.[EndDateDay] as EndDateDay
			  ,inventory.[IsNoDate] as HasNoChronologicalScope
			  ,inventory.[CreationDate] as CreatedOn
			  ,inventory.[CreationAuthor] as CreatedByDisplayName
			  ,inventory.[ModificationDate] as UpdatedOn
			  ,inventory.[ModificationAuthor] as UpdatedByDisplayName
			  ,inventory.[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters
			  ,inventory.[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
			  ,inventory.[AveilabilityAECountAssigned] as EnrolledAECount
			  ,inventory.[AveilabilityAECountDeducted] as DeductedAECount
			  ,null as EnrolledBytes
			  ,null as DeductedBytes 
		  FROM [Archiving].[dbo].[Inventory_Modified] inventory
		 WHERE inventory.LGid = ' + CAST(@Identifier as varchar(10));

	set @sql = REPLACE(@sql, '''', '''''');
	declare @linkedServerQuery varchar(max) = '
		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''');';

	EXEC (@linkedServerQuery);	
END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER  PROCEDURE [dbo].[sp_GetFundInventories]
	@LinkedServer nvarchar(255) = '', 
	@FundIdentifier uniqueidentifier = NULL,
	@FundHasExternalSource bit,
	@FundExternalIdentifier int = NULL,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @RemoteInventoriesQuery nvarchar(max) = '';
    DECLARE @RemoteInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(256)
		,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,NumberNumeric int
		,Number nvarchar(50)
		,ApproxmateChronologicalScope nvarchar(max)
		,LinearMeters float
		,ArchivalEntityCount int
		,BoxCount int 
		,RollCount int
		,AudioDocumentArchivalEntityCount int
		,PhotoDocumentArchivalEntityCount int 
		,VideoDocumentArchivalEntityCount int
		,DigitalDocumentArchivalEntityCount int
		,OtherMetrics nvarchar(256)
		,FundCreatorTitleHistory nvarchar(max)
		,FundCreatorBiographicalHistory nvarchar(max)
		,History nvarchar(max)
		,DocumentsProvider nvarchar(max)
		,AcquisitionMethodText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,ClassificationScheme nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,AbbreviationList nvarchar(max)
		,MicrofilmedArchivalEntityCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,DigitizedArchivalEntityCount int
		,Notes nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(256)
		,DocumentsDescription nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,EnrolledLinearMeters decimal(7,2)
		,DeductedLinearMeters decimal(7,2)
		,EnrolledAECount int
		,DeductedAECount int
		,EnrolledBytes bigint
		,DeductedBytes bigint
	);

	DECLARE @LocalInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(256)
		,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,NumberNumeric int
		,Number nvarchar(50)
		,ApproxmateChronologicalScope nvarchar(max)
		,LinearMeters float
		,ArchivalEntityCount int
		,BoxCount int 
		,RollCount int
		,AudioDocumentArchivalEntityCount int
		,PhotoDocumentArchivalEntityCount int 
		,VideoDocumentArchivalEntityCount int
		,DigitalDocumentArchivalEntityCount int
		,OtherMetrics nvarchar(256)
		,FundCreatorTitleHistory nvarchar(max)
		,FundCreatorBiographicalHistory nvarchar(max)
		,History nvarchar(max)
		,DocumentsProvider nvarchar(max)
		,AcquisitionMethodText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,ClassificationScheme nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,AbbreviationList nvarchar(max)
		,MicrofilmedArchivalEntityCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,DigitizedArchivalEntityCount int
		,Notes nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(256)
		,DocumentsDescription nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,EnrolledLinearMeters decimal(9,2)
		,DeductedLinearMeters decimal(9,2)
		,EnrolledAECount int
		,DeductedAECount int
		,EnrolledBytes bigint
		,DeductedBytes bigint
	);

	IF @FundHasExternalSource = 1
	BEGIN 
		SET @RemoteInventoriesQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
			  ,CAST(NULL as uniqueidentifier) as SystemIdentifier
			  ,CAST(1 as bit) as HasExternalSource
			  ,inventory.[LGid] as ExternalIdentifier
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
			  ,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
			  ,CAST(1 as bit) as FundHasExternalSource
			  ,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
			  ,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
			  ,(select Code from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
			  ,(select Name from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
			  ,(select Value from [Archiving].[dbo].Nomenclature n where n.Gid = inventory.InventoryArrayGid and n._retired = ''''3000-01-01 00:00:00.000'''') as NumberArray
			  ,inventory.[IntNumber] as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.[TextDate] as ApproxmateChronologicalScope
			  ,inventory.[LinearMeter] as LinearMeters
			  ,inventory.[AECount] as ArchivalEntityCount ' + '
			  ,inventory.[BoxesCount] as BoxCount
			  ,inventory.[RuloniTubusiCount] as RollCount
			  ,inventory.[AEFonoDocsCount] as AudioDocumentArchivalEntityCount
			  ,inventory.[AEPhotoDocsCount] as PhotoDocumentArchivalEntityCount
			  ,inventory.[AEVideoAudioDocsCount] as VideoDocumentArchivalEntityCount
			  ,inventory.[AEElectrDocsCount] as DigitalDocumentArchivalEntityCount
			  ,inventory.[ExtentOther] as OtherMetrics
			  ,inventory.[FundCreatorNameChanges] as FundCreatorTitleHistory
			  ,inventory.[FundFormerHistory] as FundCreatorBiographicalHistory
			  ,inventory.[ArchivalHistory] as History
			  ,inventory.[ImmediateSourceOfAcquisition] as DocumentsProvider ' + '
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''MethodOfAcquisition'''' for XML PATH('''''''')), 1, 1, '''''''') as AcquisitionMethodText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
			  ,inventory.[ClassificationScheme] as ClassificationScheme
			  ,inventory.[AccessConditions] as DocumentsAccessDescription
			  ,inventory.[Abbreviations] as AbbreviationList
			  ,inventory.[CopyMicrofilmAE] as MicrofilmedArchivalEntityCount ' + '
			  ,inventory.[CopyNegativFrames] as NegativeFrameCount
			  ,inventory.[CopyPositiveFrames] as PositiveFrameCount
			  ,inventory.[CopyDigitizedAE] as DigitizedArchivalEntityCount
			  ,inventory.[Note] as Notes
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
			  ,inventory.[DocumentProperties] as DocumentsDescription
			  ,inventory.[StartDateYear] as StartDateYear
			  ,inventory.[StartDateMonth] as StartDateMonth
			  ,inventory.[StartDateDay] as StartDateDay
			  ,inventory.[EndDateYear] as EndDateYear
			  ,inventory.[EndDateMonth] as EndDateMonth
			  ,inventory.[EndDateDay] as EndDateDay
			  ,inventory.[IsNoDate] as HasNoChronologicalScope
			  ,inventory.[CreationDate] as CreatedOn
			  ,inventory.[CreationAuthor] as CreatedByDisplayName
			  ,inventory.[ModificationDate] as UpdatedOn
			  ,inventory.[ModificationAuthor] as UpdatedByDisplayName
			  ,inventory.[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters
			  ,inventory.[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
			  ,inventory.[AveilabilityAECountAssigned] as EnrolledAECount
			  ,inventory.[AveilabilityAECountDeducted] as DeductedAECount
			  ,null as EnrolledBytes
			  ,null as DeductedBytes 
		  FROM [Archiving].[dbo].[Inventory_Modified] inventory
		 WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50));
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteInventoriesQuery + ''' )';
		
		INSERT INTO @RemoteInventories 
		EXEC(@RemoteQuery)
	END

	IF @FundIdentifier IS NOT NULL
	BEGIN
		INSERT INTO @LocalInventories
		SELECT inventory.Id
			  ,inventory.SystemIdentifier as SystemIdentifier
			  ,inventory.HasExternalSource
			  ,inventory.ExternalIdentifier
			  ,inventory.StatusCode
			  ,inventory.StatusText
			  ,inventory.AvailabilityStatusCode
			  ,inventory.AvailabilityStatusText
			  ,inventory.FundHasExternalSource
			  ,inventory.FundExternalIdentifier
			  ,inventory.FundNumber
			  ,inventory.ArchiveCode
			  ,inventory.ArchiveName
			  ,inventory.NumberArray
			  ,inventory.NumberNumeric as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.ApproxmateChronologicalScope
			  ,inventory.LinearMeters
			  ,inventory.ArchivalEntityCount
			  ,inventory.BoxCount
			  ,inventory.RollCount
			  ,inventory.AudioDocumentArchivalEntityCount
			  ,inventory.PhotoDocumentArchivalEntityCount
			  ,inventory.VideoDocumentArchivalEntityCount
			  ,inventory.DigitalDocumentArchivalEntityCount
			  ,inventory.OtherMetrics
			  ,inventory.FundCreatorTitleHistory
			  ,inventory.FundCreatorBiographicalHistory
			  ,inventory.History
			  ,inventory.DocumentsProvider
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'ACQUISITION_METHOD' for XML PATH('')), 1, 1, '') as AcquisitionMethodText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
			  ,inventory.ClassificationScheme
			  ,inventory.DocumentsAccessDescription
			  ,inventory.AbbreviationList
			  ,inventory.MicrofilmedArchivalEntityCount
			  ,inventory.NegativeFrameCount
			  ,inventory.PositiveFrameCount
			  ,inventory.DigitizedArchivalEntityCount
			  ,inventory.Notes
			  ,inventory.DescriptionLevelCode
			  ,inventory.DescriptionLevelText
			  ,inventory.DocumentsDescription
			  ,inventory.StartDateYear
			  ,inventory.StartDateMonth
			  ,inventory.StartDateDay
			  ,inventory.EndDateYear
			  ,inventory.EndDateMonth
			  ,inventory.EndDateDay
			  ,inventory.HasNoChronologicalScope
			  ,inventory.CreatedOn as CreatedOn
			  ,inventory.CreatedByDisplayName as CreatedByDisplayName
			  ,inventory.UpdatedOn as UpdatedOn
			  ,inventory.UpdatedByDisplayName as UpdatedByDisplayName
			  ,null
			  ,null
			  ,null
			  ,null
		      ,null
			  ,null
		FROM [dbo].[v_Inventories] inventory
		WHERE inventory.FundSystemIdentifier = @FundIdentifier 
			AND inventory.HasExternalSource = 0
			AND inventory.Deleted = 0
	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalInventories
		  UNION
		 SELECT *
		   FROM @RemoteInventories
	   ) inventories
	ORDER BY DescriptionLevelCode, NumberNumeric, NumberArray
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END

GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER   PROCEDURE [dbo].[sp_GetFundInventories]
	@LinkedServer nvarchar(255) = '', 
	@FundIdentifier uniqueidentifier = NULL,
	@FundHasExternalSource bit,
	@FundExternalIdentifier int = NULL,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @RemoteInventoriesQuery nvarchar(max) = '';
    DECLARE @RemoteInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(256)
		,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,NumberNumeric int
		,Number nvarchar(50)
		,ApproxmateChronologicalScope nvarchar(max)
		,LinearMeters float
		,ArchivalEntityCount int
		,BoxCount int 
		,RollCount int
		,AudioDocumentArchivalEntityCount int
		,PhotoDocumentArchivalEntityCount int 
		,VideoDocumentArchivalEntityCount int
		,DigitalDocumentArchivalEntityCount int
		,OtherMetrics nvarchar(256)
		,FundCreatorTitleHistory nvarchar(max)
		,FundCreatorBiographicalHistory nvarchar(max)
		,History nvarchar(max)
		,DocumentsProvider nvarchar(max)
		,AcquisitionMethodText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,ClassificationScheme nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,AbbreviationList nvarchar(max)
		,MicrofilmedArchivalEntityCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,DigitizedArchivalEntityCount int
		,Notes nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(256)
		,DocumentsDescription nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,EnrolledLinearMeters decimal(9,2)
		,DeductedLinearMeters decimal(9,2)
		,EnrolledAECount int
		,DeductedAECount int
		,EnrolledBytes bigint
		,DeductedBytes bigint
	);

	DECLARE @LocalInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(256)
		,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,NumberNumeric int
		,Number nvarchar(50)
		,ApproxmateChronologicalScope nvarchar(max)
		,LinearMeters float
		,ArchivalEntityCount int
		,BoxCount int 
		,RollCount int
		,AudioDocumentArchivalEntityCount int
		,PhotoDocumentArchivalEntityCount int 
		,VideoDocumentArchivalEntityCount int
		,DigitalDocumentArchivalEntityCount int
		,OtherMetrics nvarchar(256)
		,FundCreatorTitleHistory nvarchar(max)
		,FundCreatorBiographicalHistory nvarchar(max)
		,History nvarchar(max)
		,DocumentsProvider nvarchar(max)
		,AcquisitionMethodText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,ClassificationScheme nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,AbbreviationList nvarchar(max)
		,MicrofilmedArchivalEntityCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,DigitizedArchivalEntityCount int
		,Notes nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(256)
		,DocumentsDescription nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,EnrolledLinearMeters decimal(9,2)
		,DeductedLinearMeters decimal(9,2)
		,EnrolledAECount int
		,DeductedAECount int
		,EnrolledBytes bigint
		,DeductedBytes bigint
	);

	IF @FundHasExternalSource = 1
	BEGIN 
		SET @RemoteInventoriesQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
			  ,CAST(NULL as uniqueidentifier) as SystemIdentifier
			  ,CAST(1 as bit) as HasExternalSource
			  ,inventory.[LGid] as ExternalIdentifier
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
			  ,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
			  ,CAST(1 as bit) as FundHasExternalSource
			  ,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
			  ,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
			  ,(select Code from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
			  ,(select Name from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
			  ,(select Value from [Archiving].[dbo].Nomenclature n where n.Gid = inventory.InventoryArrayGid and n._retired = ''''3000-01-01 00:00:00.000'''') as NumberArray
			  ,inventory.[IntNumber] as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.[TextDate] as ApproxmateChronologicalScope
			  ,inventory.[LinearMeter] as LinearMeters
			  ,inventory.[AECount] as ArchivalEntityCount ' + '
			  ,inventory.[BoxesCount] as BoxCount
			  ,inventory.[RuloniTubusiCount] as RollCount
			  ,inventory.[AEFonoDocsCount] as AudioDocumentArchivalEntityCount
			  ,inventory.[AEPhotoDocsCount] as PhotoDocumentArchivalEntityCount
			  ,inventory.[AEVideoAudioDocsCount] as VideoDocumentArchivalEntityCount
			  ,inventory.[AEElectrDocsCount] as DigitalDocumentArchivalEntityCount
			  ,inventory.[ExtentOther] as OtherMetrics
			  ,inventory.[FundCreatorNameChanges] as FundCreatorTitleHistory
			  ,inventory.[FundFormerHistory] as FundCreatorBiographicalHistory
			  ,inventory.[ArchivalHistory] as History
			  ,inventory.[ImmediateSourceOfAcquisition] as DocumentsProvider ' + '
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''MethodOfAcquisition'''' for XML PATH('''''''')), 1, 1, '''''''') as AcquisitionMethodText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
			  ,inventory.[ClassificationScheme] as ClassificationScheme
			  ,inventory.[AccessConditions] as DocumentsAccessDescription
			  ,inventory.[Abbreviations] as AbbreviationList
			  ,inventory.[CopyMicrofilmAE] as MicrofilmedArchivalEntityCount ' + '
			  ,inventory.[CopyNegativFrames] as NegativeFrameCount
			  ,inventory.[CopyPositiveFrames] as PositiveFrameCount
			  ,inventory.[CopyDigitizedAE] as DigitizedArchivalEntityCount
			  ,inventory.[Note] as Notes
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
			  ,inventory.[DocumentProperties] as DocumentsDescription
			  ,inventory.[StartDateYear] as StartDateYear
			  ,inventory.[StartDateMonth] as StartDateMonth
			  ,inventory.[StartDateDay] as StartDateDay
			  ,inventory.[EndDateYear] as EndDateYear
			  ,inventory.[EndDateMonth] as EndDateMonth
			  ,inventory.[EndDateDay] as EndDateDay
			  ,inventory.[IsNoDate] as HasNoChronologicalScope
			  ,inventory.[CreationDate] as CreatedOn
			  ,inventory.[CreationAuthor] as CreatedByDisplayName
			  ,inventory.[ModificationDate] as UpdatedOn
			  ,inventory.[ModificationAuthor] as UpdatedByDisplayName
			  ,inventory.[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters
			  ,inventory.[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
			  ,inventory.[AveilabilityAECountAssigned] as EnrolledAECount
			  ,inventory.[AveilabilityAECountDeducted] as DeductedAECount
			  ,null as EnrolledBytes
			  ,null as DeductedBytes 
		  FROM [Archiving].[dbo].[Inventory_Modified] inventory
		 WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50));
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteInventoriesQuery + ''' )';
		
		INSERT INTO @RemoteInventories 
		EXEC(@RemoteQuery)
	END

	IF @FundIdentifier IS NOT NULL
	BEGIN
		INSERT INTO @LocalInventories
		SELECT inventory.Id
			  ,inventory.SystemIdentifier as SystemIdentifier
			  ,inventory.HasExternalSource
			  ,inventory.ExternalIdentifier
			  ,inventory.StatusCode
			  ,inventory.StatusText
			  ,inventory.AvailabilityStatusCode
			  ,inventory.AvailabilityStatusText
			  ,inventory.FundHasExternalSource
			  ,inventory.FundExternalIdentifier
			  ,inventory.FundNumber
			  ,inventory.ArchiveCode
			  ,inventory.ArchiveName
			  ,inventory.NumberArray
			  ,inventory.NumberNumeric as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.ApproxmateChronologicalScope
			  ,inventory.LinearMeters
			  ,inventory.ArchivalEntityCount
			  ,inventory.BoxCount
			  ,inventory.RollCount
			  ,inventory.AudioDocumentArchivalEntityCount
			  ,inventory.PhotoDocumentArchivalEntityCount
			  ,inventory.VideoDocumentArchivalEntityCount
			  ,inventory.DigitalDocumentArchivalEntityCount
			  ,inventory.OtherMetrics
			  ,inventory.FundCreatorTitleHistory
			  ,inventory.FundCreatorBiographicalHistory
			  ,inventory.History
			  ,inventory.DocumentsProvider
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'ACQUISITION_METHOD' for XML PATH('')), 1, 1, '') as AcquisitionMethodText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
			  ,inventory.ClassificationScheme
			  ,inventory.DocumentsAccessDescription
			  ,inventory.AbbreviationList
			  ,inventory.MicrofilmedArchivalEntityCount
			  ,inventory.NegativeFrameCount
			  ,inventory.PositiveFrameCount
			  ,inventory.DigitizedArchivalEntityCount
			  ,inventory.Notes
			  ,inventory.DescriptionLevelCode
			  ,inventory.DescriptionLevelText
			  ,inventory.DocumentsDescription
			  ,inventory.StartDateYear
			  ,inventory.StartDateMonth
			  ,inventory.StartDateDay
			  ,inventory.EndDateYear
			  ,inventory.EndDateMonth
			  ,inventory.EndDateDay
			  ,inventory.HasNoChronologicalScope
			  ,inventory.CreatedOn as CreatedOn
			  ,inventory.CreatedByDisplayName as CreatedByDisplayName
			  ,inventory.UpdatedOn as UpdatedOn
			  ,inventory.UpdatedByDisplayName as UpdatedByDisplayName
		      ,null as EnrolledLinearMeters
			  ,null as DeductedLinearMeters
			  ,inv.EnrolledArchivalEntityCount as EnrolledAECount 
		      ,inv.DeductedArchivalEntityCount as DeductedAECount 
		      ,inv.EnrolledBytes as EnrolledBytes
		      ,inv.DeductedBytes as DeductedBytes
		FROM [dbo].[v_Inventories] inventory
		left outer join  [dbo].[v_InventorySizeInfo] inv 
		on inv.InventorySystemIdentifier = inventory.SystemIdentifier
		--outer apply (select top 1 i.DeductedArchivalEntityCount 
		--from  [dbo].[v_InventorySizeInfo] i 
		--where i.InventorySystemIdentifier = inventory.SystemIdentifier) as inv1
		WHERE inventory.FundSystemIdentifier = @FundIdentifier 
			AND inventory.HasExternalSource = 0
			AND inventory.Deleted = 0
		 
	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalInventories
		  UNION
		 SELECT *
		   FROM @RemoteInventories
	   ) inventories
	ORDER BY DescriptionLevelCode, NumberNumeric, NumberArray
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END

GO

if not exists (select null from [dbo].[Files]  where [FileName] = 'Печат на инвентарен опис')
  INSERT INTO [dbo].[Files] 
  (FileName, Content, ContentType, FileType, CreatedOn,CreatedBy, Deleted, DeletedOn, DeletedBy)
  values('Инвентарен опис.txt', 0xFFD8FFE00013AFAE45B435B29EB212418DB6D5F4C21D8C87D8DE5B4EC2584E, 'text/plain', 'txt', getDate(), '11111111-1111-1111-1111-111111111111', 0, null, null)

 if not exists (select null from [dbo].[PackageADocsTemplates]  where [Title]='Печат на инвентарен опис')
  INSERT INTO [dbo].[PackageADocsTemplates]([ProcedureId],[DocumentId],[Required],[Sort],[Title],[Description],[CreatedOn],[CreatedBy],[UpdatedOn],[UpdatedBy],[Deleted],[DeletedOn] ,[DeletedBy],[Static])
values((select Id from [N].[ProcessTypes] where [Code]='AddFundAndInventory'),(select max(Id) from  [dbo].[Files]),0,0,'Печат на инвентарен опис',null, null, null, null,null,0,null, null,1)

GO

-- Document description levels
IF NOT EXISTS (SELECT 1 FROM N.DocumentDescriptionLevel WHERE Code = '14')
INSERT INTO N.DocumentDescriptionLevel (Code, Text, SortOrder, HasExternalSource)
VALUES ('14', 'Служебен документ', 2, 0)
GO
--END Document description levels



CREATE OR ALTER PROCEDURE [dbo].[sp_GetFundInventories]
	@LinkedServer nvarchar(255) = '', 
	@FundIdentifier uniqueidentifier = NULL,
	@FundHasExternalSource bit,
	@FundExternalIdentifier int = NULL,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @RemoteInventoriesQuery nvarchar(max) = '';
    DECLARE @RemoteInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(256)
		,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,NumberNumeric int
		,Number nvarchar(50)
		,ApproxmateChronologicalScope nvarchar(max)
		,LinearMeters float
		,ArchivalEntityCount int
		,BoxCount int 
		,RollCount int
		,AudioDocumentArchivalEntityCount int
		,PhotoDocumentArchivalEntityCount int 
		,VideoDocumentArchivalEntityCount int
		,DigitalDocumentArchivalEntityCount int
		,OtherMetrics nvarchar(256)
		,FundCreatorTitleHistory nvarchar(max)
		,FundCreatorBiographicalHistory nvarchar(max)
		,History nvarchar(max)
		,DocumentsProvider nvarchar(max)
		,AcquisitionMethodText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,ClassificationScheme nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,AbbreviationList nvarchar(max)
		,MicrofilmedArchivalEntityCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,DigitizedArchivalEntityCount int
		,Notes nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(256)
		,DocumentsDescription nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,EnrolledLinearMeters float
		,DeductedLinearMeters float
		,EnrolledAECount int
		,DeductedAECount int
		,EnrolledBytes bigint
		,DeductedBytes bigint
	);

	DECLARE @LocalInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(256)
		,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,NumberNumeric int
		,Number nvarchar(50)
		,ApproxmateChronologicalScope nvarchar(max)
		,LinearMeters float
		,ArchivalEntityCount int
		,BoxCount int 
		,RollCount int
		,AudioDocumentArchivalEntityCount int
		,PhotoDocumentArchivalEntityCount int 
		,VideoDocumentArchivalEntityCount int
		,DigitalDocumentArchivalEntityCount int
		,OtherMetrics nvarchar(256)
		,FundCreatorTitleHistory nvarchar(max)
		,FundCreatorBiographicalHistory nvarchar(max)
		,History nvarchar(max)
		,DocumentsProvider nvarchar(max)
		,AcquisitionMethodText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,ClassificationScheme nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,AbbreviationList nvarchar(max)
		,MicrofilmedArchivalEntityCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,DigitizedArchivalEntityCount int
		,Notes nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(256)
		,DocumentsDescription nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,EnrolledLinearMeters float
		,DeductedLinearMeters float
		,EnrolledAECount int
		,DeductedAECount int
		,EnrolledBytes bigint
		,DeductedBytes bigint
	);

	IF @FundHasExternalSource = 1
	BEGIN 
		SET @RemoteInventoriesQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
			  ,CAST(NULL as uniqueidentifier) as SystemIdentifier
			  ,CAST(1 as bit) as HasExternalSource
			  ,inventory.[LGid] as ExternalIdentifier
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
			  ,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
			  ,CAST(1 as bit) as FundHasExternalSource
			  ,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
			  ,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
			  ,(select Code from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
			  ,(select Name from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
			  ,(select Value from [Archiving].[dbo].Nomenclature n where n.Gid = inventory.InventoryArrayGid and n._retired = ''''3000-01-01 00:00:00.000'''') as NumberArray
			  ,inventory.[IntNumber] as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.[TextDate] as ApproxmateChronologicalScope
			  ,inventory.[LinearMeter] as LinearMeters
			  ,inventory.[AECount] as ArchivalEntityCount ' + '
			  ,inventory.[BoxesCount] as BoxCount
			  ,inventory.[RuloniTubusiCount] as RollCount
			  ,inventory.[AEFonoDocsCount] as AudioDocumentArchivalEntityCount
			  ,inventory.[AEPhotoDocsCount] as PhotoDocumentArchivalEntityCount
			  ,inventory.[AEVideoAudioDocsCount] as VideoDocumentArchivalEntityCount
			  ,inventory.[AEElectrDocsCount] as DigitalDocumentArchivalEntityCount
			  ,inventory.[ExtentOther] as OtherMetrics
			  ,inventory.[FundCreatorNameChanges] as FundCreatorTitleHistory
			  ,inventory.[FundFormerHistory] as FundCreatorBiographicalHistory
			  ,inventory.[ArchivalHistory] as History
			  ,inventory.[ImmediateSourceOfAcquisition] as DocumentsProvider ' + '
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''MethodOfAcquisition'''' for XML PATH('''''''')), 1, 1, '''''''') as AcquisitionMethodText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
			  ,inventory.[ClassificationScheme] as ClassificationScheme
			  ,inventory.[AccessConditions] as DocumentsAccessDescription
			  ,inventory.[Abbreviations] as AbbreviationList
			  ,inventory.[CopyMicrofilmAE] as MicrofilmedArchivalEntityCount ' + '
			  ,inventory.[CopyNegativFrames] as NegativeFrameCount
			  ,inventory.[CopyPositiveFrames] as PositiveFrameCount
			  ,inventory.[CopyDigitizedAE] as DigitizedArchivalEntityCount
			  ,inventory.[Note] as Notes
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
			  ,inventory.[DocumentProperties] as DocumentsDescription
			  ,inventory.[StartDateYear] as StartDateYear
			  ,inventory.[StartDateMonth] as StartDateMonth
			  ,inventory.[StartDateDay] as StartDateDay
			  ,inventory.[EndDateYear] as EndDateYear
			  ,inventory.[EndDateMonth] as EndDateMonth
			  ,inventory.[EndDateDay] as EndDateDay
			  ,inventory.[IsNoDate] as HasNoChronologicalScope
			  ,inventory.[CreationDate] as CreatedOn
			  ,inventory.[CreationAuthor] as CreatedByDisplayName
			  ,inventory.[ModificationDate] as UpdatedOn
			  ,inventory.[ModificationAuthor] as UpdatedByDisplayName
			  ,inventory.[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters
			  ,inventory.[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
			  ,inventory.[AveilabilityAECountAssigned] as EnrolledAECount
			  ,inventory.[AveilabilityAECountDeducted] as DeductedAECount
			  ,null as EnrolledBytes
			  ,null as DeductedBytes 
		  FROM [Archiving].[dbo].[Inventory_Modified] inventory
		 WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50));
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteInventoriesQuery + ''' )';
		
		INSERT INTO @RemoteInventories 
		EXEC(@RemoteQuery)
	END

	IF @FundIdentifier IS NOT NULL
	BEGIN
		INSERT INTO @LocalInventories
		SELECT inventory.Id
			  ,inventory.SystemIdentifier as SystemIdentifier
			  ,inventory.HasExternalSource
			  ,inventory.ExternalIdentifier
			  ,inventory.StatusCode
			  ,inventory.StatusText
			  ,inventory.AvailabilityStatusCode
			  ,inventory.AvailabilityStatusText
			  ,inventory.FundHasExternalSource
			  ,inventory.FundExternalIdentifier
			  ,inventory.FundNumber
			  ,inventory.ArchiveCode
			  ,inventory.ArchiveName
			  ,inventory.NumberArray
			  ,inventory.NumberNumeric as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.ApproxmateChronologicalScope
			  ,inventory.LinearMeters
			  ,inventory.ArchivalEntityCount
			  ,inventory.BoxCount
			  ,inventory.RollCount
			  ,inventory.AudioDocumentArchivalEntityCount
			  ,inventory.PhotoDocumentArchivalEntityCount
			  ,inventory.VideoDocumentArchivalEntityCount
			  ,inventory.DigitalDocumentArchivalEntityCount
			  ,inventory.OtherMetrics
			  ,inventory.FundCreatorTitleHistory
			  ,inventory.FundCreatorBiographicalHistory
			  ,inventory.History
			  ,inventory.DocumentsProvider
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'ACQUISITION_METHOD' for XML PATH('')), 1, 1, '') as AcquisitionMethodText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
			  ,inventory.ClassificationScheme
			  ,inventory.DocumentsAccessDescription
			  ,inventory.AbbreviationList
			  ,inventory.MicrofilmedArchivalEntityCount
			  ,inventory.NegativeFrameCount
			  ,inventory.PositiveFrameCount
			  ,inventory.DigitizedArchivalEntityCount
			  ,inventory.Notes
			  ,inventory.DescriptionLevelCode
			  ,inventory.DescriptionLevelText
			  ,inventory.DocumentsDescription
			  ,inventory.StartDateYear
			  ,inventory.StartDateMonth
			  ,inventory.StartDateDay
			  ,inventory.EndDateYear
			  ,inventory.EndDateMonth
			  ,inventory.EndDateDay
			  ,inventory.HasNoChronologicalScope
			  ,inventory.CreatedOn as CreatedOn
			  ,inventory.CreatedByDisplayName as CreatedByDisplayName
			  ,inventory.UpdatedOn as UpdatedOn
			  ,inventory.UpdatedByDisplayName as UpdatedByDisplayName
		      ,null as EnrolledLinearMeters
			  ,null as DeductedLinearMeters
			  ,inv.EnrolledArchivalEntityCount as EnrolledAECount 
		      ,inv.DeductedArchivalEntityCount as DeductedAECount 
		      ,inv.EnrolledBytes as EnrolledBytes
		      ,inv.DeductedBytes as DeductedBytes
		FROM [dbo].[v_Inventories] inventory
		left outer join  [dbo].[v_InventorySizeInfo] inv 
		on inv.InventorySystemIdentifier = inventory.SystemIdentifier
		--outer apply (select top 1 i.DeductedArchivalEntityCount 
		--from  [dbo].[v_InventorySizeInfo] i 
		--where i.InventorySystemIdentifier = inventory.SystemIdentifier) as inv1
		WHERE inventory.FundSystemIdentifier = @FundIdentifier 
			AND inventory.HasExternalSource = 0
			AND inventory.Deleted = 0
		 
	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalInventories
		  UNION
		 SELECT *
		   FROM @RemoteInventories
	   ) inventories
	ORDER BY DescriptionLevelCode, NumberNumeric, NumberArray
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END
GO



CREATE OR ALTER PROCEDURE [dbo].[sp_GetFundInventoriesPublic]
	@LinkedServer nvarchar(255) = '', 
	@FundIdentifier uniqueidentifier = NULL,
	@FundHasExternalSource bit,
	@FundExternalIdentifier int = NULL,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @RemoteInventoriesQuery nvarchar(max) = '';
    DECLARE @RemoteInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(256)
		,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,NumberNumeric int
		,Number nvarchar(50)
		,ApproxmateChronologicalScope nvarchar(max)
		,LinearMeters float
		,ArchivalEntityCount int
		,BoxCount int 
		,RollCount int
		,AudioDocumentArchivalEntityCount int
		,PhotoDocumentArchivalEntityCount int 
		,VideoDocumentArchivalEntityCount int
		,DigitalDocumentArchivalEntityCount int
		,OtherMetrics nvarchar(256)
		,FundCreatorTitleHistory nvarchar(max)
		,FundCreatorBiographicalHistory nvarchar(max)
		,History nvarchar(max)
		,DocumentsProvider nvarchar(max)
		,AcquisitionMethodText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,ClassificationScheme nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,AbbreviationList nvarchar(max)
		,MicrofilmedArchivalEntityCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,DigitizedArchivalEntityCount int
		,Notes nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(256)
		,DocumentsDescription nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,EnrolledLinearMeters float
		,DeductedLinearMeters float
		,EnrolledAECount int
		,DeductedAECount int
		,EnrolledBytes bigint
		,DeductedBytes bigint
	);

	DECLARE @LocalInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(256)
		,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,NumberNumeric int
		,Number nvarchar(50)
		,ApproxmateChronologicalScope nvarchar(max)
		,LinearMeters float
		,ArchivalEntityCount int
		,BoxCount int 
		,RollCount int
		,AudioDocumentArchivalEntityCount int
		,PhotoDocumentArchivalEntityCount int 
		,VideoDocumentArchivalEntityCount int
		,DigitalDocumentArchivalEntityCount int
		,OtherMetrics nvarchar(256)
		,FundCreatorTitleHistory nvarchar(max)
		,FundCreatorBiographicalHistory nvarchar(max)
		,History nvarchar(max)
		,DocumentsProvider nvarchar(max)
		,AcquisitionMethodText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,ClassificationScheme nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,AbbreviationList nvarchar(max)
		,MicrofilmedArchivalEntityCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,DigitizedArchivalEntityCount int
		,Notes nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(256)
		,DocumentsDescription nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,EnrolledLinearMeters float
		,DeductedLinearMeters float
		,EnrolledAECount int
		,DeductedAECount int
		,EnrolledBytes bigint
		,DeductedBytes bigint
	);

	IF @FundHasExternalSource = 1
	BEGIN 
		SET @RemoteInventoriesQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
			  ,CAST(NULL as uniqueidentifier) as SystemIdentifier
			  ,CAST(1 as bit) as HasExternalSource
			  ,inventory.[LGid] as ExternalIdentifier
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
			  ,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
			  ,CAST(1 as bit) as FundHasExternalSource
			  ,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
			  ,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
			  ,(select Code from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
			  ,(select Name from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
			  ,(select Value from [Archiving].[dbo].Nomenclature n where n.Gid = inventory.InventoryArrayGid and n._retired = ''''3000-01-01 00:00:00.000'''') as NumberArray
			  ,inventory.[IntNumber] as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.[TextDate] as ApproxmateChronologicalScope
			  ,inventory.[LinearMeter] as LinearMeters
			  ,inventory.[AECount] as ArchivalEntityCount ' + '
			  ,inventory.[BoxesCount] as BoxCount
			  ,inventory.[RuloniTubusiCount] as RollCount
			  ,inventory.[AEFonoDocsCount] as AudioDocumentArchivalEntityCount
			  ,inventory.[AEPhotoDocsCount] as PhotoDocumentArchivalEntityCount
			  ,inventory.[AEVideoAudioDocsCount] as VideoDocumentArchivalEntityCount
			  ,inventory.[AEElectrDocsCount] as DigitalDocumentArchivalEntityCount
			  ,inventory.[ExtentOther] as OtherMetrics
			  ,inventory.[FundCreatorNameChanges] as FundCreatorTitleHistory
			  ,inventory.[FundFormerHistory] as FundCreatorBiographicalHistory
			  ,inventory.[ArchivalHistory] as History
			  ,inventory.[ImmediateSourceOfAcquisition] as DocumentsProvider ' + '
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''MethodOfAcquisition'''' for XML PATH('''''''')), 1, 1, '''''''') as AcquisitionMethodText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
			  ,inventory.[ClassificationScheme] as ClassificationScheme
			  ,inventory.[AccessConditions] as DocumentsAccessDescription
			  ,inventory.[Abbreviations] as AbbreviationList
			  ,inventory.[CopyMicrofilmAE] as MicrofilmedArchivalEntityCount ' + '
			  ,inventory.[CopyNegativFrames] as NegativeFrameCount
			  ,inventory.[CopyPositiveFrames] as PositiveFrameCount
			  ,inventory.[CopyDigitizedAE] as DigitizedArchivalEntityCount
			  ,inventory.[Note] as Notes
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
			  ,inventory.[DocumentProperties] as DocumentsDescription
			  ,inventory.[StartDateYear] as StartDateYear
			  ,inventory.[StartDateMonth] as StartDateMonth
			  ,inventory.[StartDateDay] as StartDateDay
			  ,inventory.[EndDateYear] as EndDateYear
			  ,inventory.[EndDateMonth] as EndDateMonth
			  ,inventory.[EndDateDay] as EndDateDay
			  ,inventory.[IsNoDate] as HasNoChronologicalScope
			  ,inventory.[CreationDate] as CreatedOn
			  ,inventory.[CreationAuthor] as CreatedByDisplayName
			  ,inventory.[ModificationDate] as UpdatedOn
			  ,inventory.[ModificationAuthor] as UpdatedByDisplayName
			  ,inventory.[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters
			  ,inventory.[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
			  ,inventory.[AveilabilityAECountAssigned] as EnrolledAECount
			  ,inventory.[AveilabilityAECountDeducted] as DeductedAECount
			  ,null as EnrolledBytes
			  ,null as DeductedBytes 
		  FROM [Archiving].[dbo].[Inventory_Active] inventory
		 WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50)) + '
			AND (SELECT Gid FROM [dbo].[Nomenclature] n1 WHERE n1.Gid = inventory.LevelOfDescriptionGid AND n1._retired = ''''3000-01-01 00:00:00.000'''') <> 2172
		 ';
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteInventoriesQuery + ''' )';
		
		INSERT INTO @RemoteInventories 
		EXEC(@RemoteQuery)
	END

	IF @FundIdentifier IS NOT NULL
	BEGIN
		INSERT INTO @LocalInventories
		SELECT inventory.Id
			  ,inventory.SystemIdentifier as SystemIdentifier
			  ,inventory.HasExternalSource
			  ,inventory.ExternalIdentifier
			  ,inventory.StatusCode
			  ,inventory.StatusText
			  ,inventory.AvailabilityStatusCode
			  ,inventory.AvailabilityStatusText
			  ,inventory.FundHasExternalSource
			  ,inventory.FundExternalIdentifier
			  ,inventory.FundNumber
			  ,inventory.ArchiveCode
			  ,inventory.ArchiveName
			  ,inventory.NumberArray
			  ,inventory.NumberNumeric as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.ApproxmateChronologicalScope
			  ,inventory.LinearMeters
			  ,inventory.ArchivalEntityCount
			  ,inventory.BoxCount
			  ,inventory.RollCount
			  ,inventory.AudioDocumentArchivalEntityCount
			  ,inventory.PhotoDocumentArchivalEntityCount
			  ,inventory.VideoDocumentArchivalEntityCount
			  ,inventory.DigitalDocumentArchivalEntityCount
			  ,inventory.OtherMetrics
			  ,inventory.FundCreatorTitleHistory
			  ,inventory.FundCreatorBiographicalHistory
			  ,inventory.History
			  ,inventory.DocumentsProvider
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'ACQUISITION_METHOD' for XML PATH('')), 1, 1, '') as AcquisitionMethodText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
			  ,inventory.ClassificationScheme
			  ,inventory.DocumentsAccessDescription
			  ,inventory.AbbreviationList
			  ,inventory.MicrofilmedArchivalEntityCount
			  ,inventory.NegativeFrameCount
			  ,inventory.PositiveFrameCount
			  ,inventory.DigitizedArchivalEntityCount
			  ,inventory.Notes
			  ,inventory.DescriptionLevelCode
			  ,inventory.DescriptionLevelText
			  ,inventory.DocumentsDescription
			  ,inventory.StartDateYear
			  ,inventory.StartDateMonth
			  ,inventory.StartDateDay
			  ,inventory.EndDateYear
			  ,inventory.EndDateMonth
			  ,inventory.EndDateDay
			  ,inventory.HasNoChronologicalScope
			  ,inventory.CreatedOn as CreatedOn
			  ,inventory.CreatedByDisplayName as CreatedByDisplayName
			  ,inventory.UpdatedOn as UpdatedOn
			  ,inventory.UpdatedByDisplayName as UpdatedByDisplayName
			  ,null as EnrolledLinearMeters
			  ,null as DeductedLinearMeters
			  ,sizeInfo.EnrolledArchivalEntityCount as EnrolledAECount 
		      ,sizeInfo.DeductedArchivalEntityCount as DeductedAECount 
		      ,sizeInfo.EnrolledBytes as EnrolledBytes
		      ,sizeInfo.DeductedBytes as DeductedBytes
		 FROM [dbo].[v_PublicInventories] inventory
		 LEFT JOIN [dbo].[v_InventorySizeInfo] sizeInfo on sizeInfo.InventorySystemIdentifier = inventory.SystemIdentifier
		 WHERE inventory.FundSystemIdentifier = @FundIdentifier 
		   AND inventory.HasExternalSource = 0
		   AND inventory.Deleted = 0 
	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalInventories
		  UNION
		 SELECT *
		   FROM @RemoteInventories
	   ) inventories
	ORDER BY NumberNumeric
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[sp_GetRegisterOfDigitizedDocumentsReport]
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка

	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by ArchiveSortOrder, FundNumber, InventoryNumber, ArchiveEntityNumber -- ако се добавят FundIntNumber, InventoryIntNumber, ArchivalEntityIntNumber бави твърде много
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT 
			''document'' as DocumentLink, -- Link_todo
			(select CAST(a.Code as nvarchar(10)) from archive as a where _retired = ''3000-01-01'' and Gid = d.ArchiveGid) as ArchiveCode,
			a.Name as ArchiveName,
			CAST(d.Gid as nvarchar(256)) as SystemId,
			(select n.Value FROM Nomenclature as n where _retired = ''3000-01-01'' and Gid = (SELECT LevelOfDescriptionGid from Fund_Modified f where f.LGid = d.FundLGid)) as LevelOfDescription,
			(select top 1 Number from Fund_Modified f where f.LGid = d.FundLGid) as FundNumber,
			(select i.Number from Inventory_Modified as i where i.LGid = d.InventoryLGid) as InventoryNumber,
			(select ae.Number from ArchiveEntity_Modified as ae where ae.LGid = d.AELGid) as ArchiveEntityNumber,
			CAST(d.Title as nvarchar(256)) as Title,
			convert(varchar, d.DOCreationDate, 104) as DocCreationDate,
			(select n.Value + '', ''
				from Nomenclature n
				inner join ObjectNomenclature objn on n.Gid = objn.NomenclatureGid and objn._retired = ''3000-01-01'' and objn.DocumentGid = d.Gid
				where 
				n._retired = ''3000-01-01''
				and n.[Type] = ''Annotated''
				FOR XML path(''''), elements) as Themes,
			(select n.Value FROM Nomenclature as n where _retired = ''3000-01-01'' and Gid = d.StatusGid) as DocStatus,
			(select top(1) convert(varchar, img.CreatedOn, 104) from Image as img where d.Gid = img.DocumentGid and img._retired = ''3000-01-01'') as CreationDateDO,
			0 as RecordsCountDO,
			NULL as Duration,
			(
				select convert(varchar, max(p.ModifiedOn), 104)  
				from Document doc
				inner join Process p on p._retired = ''3000-01-01'' and p.Gid = doc.ProcessGid and p.TypeGid = 2124 and p.StepGid = 75
				where doc.LGid = d.lgid
			) as DigitalObjectRecreationDate,
			CAST(0 as bigint) as BytesDO, -- това по тяхно искане не трябва да се отчита
			case when isnull(d.DigitalObjectDeleted, 0) = 0 then ''Активен'' else ''Заличен'' end as StatusDO,
			d.DOCreationAuthor as Operator,
			NULL as CorrectionReturnDate,
			NULL as FinalCorrectionDate,
			(
				select convert(varchar, max(p.ModifiedOn), 104)  
				from Document doc
				inner join Process p on p._retired = ''3000-01-01'' and p.Gid = doc.ProcessGid and p.TypeGid = 2123 and p.StepGid = 75
				where doc.LGid = d.lgid
			) as DigitalObjectAcceptanceDate,
			(select top 1 IntNumber from Fund_Modified f where f.LGid = d.FundLGid) as FundIntNumber,
			(select i.IntNumber from Inventory_Modified as i where i.LGid = d.InventoryLGid) as InventoryIntNumber,
			(select ae.IntNumber from ArchiveEntity_Modified as ae where ae.LGid = d.AELGid) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder
		FROM Document_Modified as d
		INNER JOIN Archive a ON a.Gid = d.ArchiveGid AND a._retired = ''3000-01-01''
		--inner join Fund_Modified f on f.LGid = d.FundLGid
		--inner join Inventory_Modified i on i.LGid = d.InventoryLGid
		--inner join ArchiveEntity_Modified ae on ae.LGid = d.AELGid
		LEFT OUTER JOIN [Image] img on d.Gid = img.DocumentGid and img._retired = ''3000-01-01''
		WHERE ISNULL(d.HasDigitalObject, 0) = 1
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
			  AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(d.StartDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			  AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(d.EndDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
		GROUP BY
			d.LGid, 
			d.ArchiveGid, 
			d.CreationDate, 
			d.Title, 
			d.StatusGid, 
			d.DigitalObjectDeleted, 
			d.DigitalObjectDeleted, 
			d.DOCreationDate, 
			d.FundLGid, 
			d.InventoryLGid, 
			d.AELGid, 
			d.Gid,
			d.StartDateDay,
			d.StartDateMonth,
			d.StartDateYear,
			d.EndDateDay,
			d.EndDateMonth,
			d.EndDateYear,
			d.TextDate,
			d.DOCreationAuthor,
			a.Name,
			a.SortOrder--,
			--f.Number,
			--i.Number,
			--ae.Number
		'
			  
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		--DECLARE @localQuery VARCHAR(MAX) = '
		--SELECT 
		--	''document'' as DocumentLink,
		--	CAST((select a.Code FROM [Archives] as a where a.Id = ArchiveId) as nvarchar(256)) as ArchiveCode,
		--	a.Name as ArchiveName,
		--	CAST(d.SystemIdentifier as nvarchar(256)) as SystemId,
		--	(select fdl.Text FROM [N].[FundDescriptionLevel] as fdl where fdl.Code = (select f.DescriptionLevelCode FROM Funds f where f.SystemIdentifier = d.FundSystemIdentifier)) as LevelOfDescription,
		--	CAST((select f.Number FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as nvarchar(256)) as FundNumber,
		--	CAST((select i.Number FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as nvarchar(256)) as InventoryNumber,
		--	CAST((select ae.Number FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as nvarchar(256)) as ArchiveEntityNumber,
		--	CAST(d.Title as nvarchar(256)) as Title,
		--	convert(varchar, d.CreatedOn, 104) as DocCreationDate,
		--	NULL as Themes,
		--	(select s.Text from N.Status as s where s.Code = d.StatusCode) as DocStatus,
		--	CAST((select top(1) convert(varchar, do.CreatedOn, 104) from DigitalObjects as do where do.DocumentSystemIdentifier = d.SystemIdentifier) as nvarchar(50)) as CreationDateDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
		--	d.DigitizedCopyCount as RecordsCountDO,
		--	CAST(d.Duration as nvarchar(256)) as Duration,
		--	NULL as DigitalObjectRecreationDate,
		--	isnull(dsi.EnrolledBytes, 0) as BytesDO,
		--	(select top(1) n.Text from N.Nomenclatures as n join DigitalObjects as do on n.Id = do.StatusCode where do.DocumentSystemIdentifier = d.SystemIdentifier and n.Deleted = 0) as StatusDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
		--	NULL as Operator,
		--	NULL as CorrectionReturnDate,
		--	NULL as FinalCorrectionDate,
		--	NULL as DigitalObjectAcceptanceDate,
		--	CAST((select f.NumberNumeric FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as nvarchar(256)) as FundIntNumber,
		--	CAST((select i.NumberNumeric FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as nvarchar(256)) as InventoryIntNumber,
		--	CAST((select ae.NumberNumeric FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as nvarchar(256)) as ArchivalEntityIntNumber,
		--	a.SortOrder as ArchiveSortOrder
		--FROM Documents as d
		--INNER JOIN Archives a ON a.Id = d.ArchiveId AND a.Deleted = 0
		--LEFT JOIN v_DocumentSizeInfo dsi ON dsi.DocumentSystemIdentifier = d.SystemIdentifier AND dsi.IsDraft = 0
		--WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
		--	  AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
		--	  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
		--	  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
		--	  AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[StartDateYear], d.[StartDateMonth], d.[StartDateDay]) as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
		--	  AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[EndDateYear], d.[EndDateMonth], d.[EndDateDay]) as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))'

		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT 
			''document'' as DocumentLink,
			CAST((select a.Code FROM [Archives] as a where a.Id = ArchiveId) as nvarchar(256)) as ArchiveCode,
			a.Name as ArchiveName,
			CAST(d.SystemIdentifier as nvarchar(256)) as SystemId,
			(select fdl.Text FROM [N].[FundDescriptionLevel] as fdl where fdl.Code = (select f.DescriptionLevelCode FROM Funds f where f.SystemIdentifier = d.FundSystemIdentifier)) as LevelOfDescription,
			CAST((select f.Number FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as nvarchar(256)) as FundNumber,
			CAST((select i.Number FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as nvarchar(256)) as InventoryNumber,
			CAST((select ae.Number FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as nvarchar(256)) as ArchiveEntityNumber,
			CAST(d.Title as nvarchar(256)) as Title,
			convert(varchar, d.CreatedOn, 104) as DocCreationDate,
			NULL as Themes,
			(select s.Text from N.Status as s where s.Code = d.StatusCode) as DocStatus,
			CAST((select top(1) convert(varchar, do.CreatedOn, 104) from DigitalObjects as do where do.DocumentSystemIdentifier = d.SystemIdentifier) as nvarchar(50)) as CreationDateDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
			d.DigitizedCopyCount as RecordsCountDO,
			CAST(d.Duration as nvarchar(256)) as Duration,
			NULL as DigitalObjectRecreationDate,
			isnull(dsi.EnrolledBytes, 0) as BytesDO,
			(select top(1) n.Text from N.Nomenclatures as n join DigitalObjects as do on n.Id = do.StatusCode where do.DocumentSystemIdentifier = d.SystemIdentifier and n.Deleted = 0) as StatusDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
			NULL as Operator,
			NULL as CorrectionReturnDate,
			NULL as FinalCorrectionDate,
			NULL as DigitalObjectAcceptanceDate,
			CAST((select f.NumberNumeric FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as nvarchar(256)) as FundIntNumber,
			CAST((select i.NumberNumeric FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as nvarchar(256)) as InventoryIntNumber,
			CAST((select ae.NumberNumeric FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as nvarchar(256)) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder
		FROM Documents as d
		INNER JOIN Archives a ON a.Id = d.ArchiveId AND a.Deleted = 0
		LEFT JOIN v_DocumentSizeInfo dsi ON dsi.DocumentSystemIdentifier = d.SystemIdentifier AND dsi.IsDraft = 0
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
			  AND exists(select 1 from DigitalObjects do where d.SystemIdentifier = do.DocumentSystemIdentifier and do.Deleted = 0)
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
			  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			  AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[StartDateYear], d.[StartDateMonth], d.[StartDateDay]) as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			  AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[EndDateYear], d.[EndDateMonth], d.[EndDateDay]) as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))'

	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteDigitizedDocumentsTable TABLE (
				DocumentLink nvarchar(MAX) NULL,
				ArchiveCode nvarchar(256) NOT NULL,
				ArchiveName nvarchar(256) NOT NULL,
				SystemId nvarchar(256) NULL,
				LevelOfDescription nvarchar(MAX) NULL,
				FundNumber nvarchar(256) NULL,
				InventoryNumber nvarchar(256) NULL,
				ArchiveEntityNumber nvarchar(256) NULL,
				Title nvarchar(256) NULL,
				DocCreationDate nvarchar(50) NULL,
				Themes nvarchar(MAX) NULL,
				DocStatus nvarchar(MAX) NULL,
				CreationDateDO nvarchar(50) NULL,
				RecordsCountDO int NULL,
				Duration nvarchar(256) NULL,
				DigitalObjectRecreationDate nvarchar(50) NULL,
				BytesDO bigint NULL,
				StatusDO nvarchar(MAX) NULL,
				Operator nvarchar(MAX) NULL,
				CorrectionReturnDate nvarchar(50) NULL,
				FinalCorrectionDate nvarchar(50) NULL,
				DigitalObjectAcceptanceDate nvarchar(50) NULL,
				FundIntNumber INT NULL,
				InventoryIntNumber INT NULL,
				ArchivalEntityIntNumber INT NULL,
				ArchiveSortOrder int null
			);

			INSERT INTO @remoteDigitizedDocumentsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteDigitizedDocumentsTable
			UNION
			' +
			@localQuery + @sqlFinalPart;	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + @sqlFinalPart +''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery + @sqlFinalPart;
	END

	EXEC (@sql);
END
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[sp_GetRegisterOfDigitizedDocumentsCombined]
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка

	SET @RowsOfPage = 2147483647
	SET @Page = 1

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT top 1
			''' + COALESCE(@RegisteredFrom, '') + '''  as PeriodFrom,
			''' + COALESCE(@RegisteredTo, '') + ''' as PeriodTo,
			NULL as Employee
		FROM Document_Modified as d
		INNER JOIN Archive a ON a.Gid = d.ArchiveGid AND a._retired = ''3000-01-01''
		--inner join Fund_Modified f on f.LGid = d.FundLGid
		--inner join Inventory_Modified i on i.LGid = d.InventoryLGid
		--inner join ArchiveEntity_Modified ae on ae.LGid = d.AELGid
		LEFT OUTER JOIN [Image] img on d.Gid = img.DocumentGid and img._retired = ''3000-01-01''
		WHERE ISNULL(d.HasDigitalObject, 0) = 1
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
			  AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(d.StartDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			  AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(d.EndDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
		GROUP BY
			d.LGid, 
			d.ArchiveGid, 
			d.CreationDate, 
			d.Title, 
			d.StatusGid, 
			d.DigitalObjectDeleted, 
			d.DigitalObjectDeleted, 
			d.DOCreationDate, 
			d.FundLGid, 
			d.InventoryLGid, 
			d.AELGid, 
			d.Gid,
			d.StartDateDay,
			d.StartDateMonth,
			d.StartDateYear,
			d.EndDateDay,
			d.EndDateMonth,
			d.EndDateYear,
			d.TextDate,
			d.DOCreationAuthor,
			a.Name,
			a.SortOrder,
			(cast(d.StartDate as date)),
			(cast(d.EndDate as date))
			--f.Number,
			--i.Number,
			--ae.Number
		'
			  
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		--DECLARE @localQuery VARCHAR(MAX) = '
		--SELECT TOP 1
		--	''' + COALESCE(@RegisteredFrom, '') + '''  as PeriodFrom,
		--	''' + COALESCE(@RegisteredTo, '') + ''' as PeriodTo,
		--	NULL as Employee
		--FROM Documents as d
		--INNER JOIN Archives a ON a.Id = d.ArchiveId AND a.Deleted = 0
		--WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
		--	  AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
		--	  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
		--	  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
		--	  AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[StartDateYear], d.[StartDateMonth], d.[StartDateDay]) as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
		--	  AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[EndDateYear], d.[EndDateMonth], d.[EndDateDay]) as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))'

		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT TOP 1
			''' + COALESCE(@RegisteredFrom, '') + '''  as PeriodFrom,
			''' + COALESCE(@RegisteredTo, '') + ''' as PeriodTo,
			NULL as Employee
		FROM Documents as d
		INNER JOIN Archives a ON a.Id = d.ArchiveId AND a.Deleted = 0
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
			  AND exists(select 1 from DigitalObjects do where d.SystemIdentifier = do.DocumentSystemIdentifier and do.Deleted = 0)
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
			  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			  AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[StartDateYear], d.[StartDateMonth], d.[StartDateDay]) as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			  AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[EndDateYear], d.[EndDateMonth], d.[EndDateDay]) as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))'

	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteDigitizedDocumentsTable TABLE (
				PeriodFrom nvarchar(50) NULL,
				PeriodTo nvarchar(50) NULL,
				Employee nvarchar(max) NULL
			);

			INSERT INTO @remoteDigitizedDocumentsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteDigitizedDocumentsTable
			UNION ALL
			' +
			@localQuery;
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery;
	END


	EXEC (@sql);
END
GO



----------------------------------------------------------
--	THE SCRIPT IS CLOSED - USE THE NEW ONE!
----------------------------------------------------------

commit