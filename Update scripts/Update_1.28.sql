SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.28'
where Code = 'DB_VERSION'
go


update dbo._Version 
set Value = '1.1.23'
where Code = 'APP_VERSION'
go


IF NOT EXISTS (SELECT 1 FROM N.NotificationType WHERE Code = 'ModifyApplicationPackages')
BEGIN
	INSERT INTO N.NotificationType (Code, Text)
	VALUES ('ModifyApplicationPackages', 'Изискани корекции в пакети към заявление')
END
GO

IF NOT EXISTS(SELECT 1 FROM Notification.NotificationTemplate WHERE NotificationTypeCode = 'ModifyApplicationPackages')
BEGIN
	INSERT INTO Notification.NotificationTemplate (NotificationTypeCode, Subject, Body)
	VALUES('ModifyApplicationPackages', 'Изискани са корекции в пакети към заявление', '<p>Изискани са следните корекции в пакетите, прикачени към #applicationType# с номер #applicationNumber#: #applicationPackageRejectReason#. </p>')
END
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER view [dbo].[v_Inventories]
AS

SELECT i.Id
      ,i.SystemIdentifier
	  ,CAST(0 as bit) as IsDraft
	  ,i.IsSuspended
      ,i.ArchiveId
	  ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,NULL as FundDraftId
      ,i.FundSystemIdentifier
	  ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,i.CreatedOn
      ,i.CreatedBy
      ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,i.UpdatedOn
      ,i.UpdatedBy
      ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,i.Deleted
      ,i.DeletedOn
      ,i.DeletedBy
      ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,i.ExternalIdentifier
      ,i.HasExternalSource
      ,i.ExternalSourceUpdatedOn
      ,i.NumberArray
	  ,i.NumberNumeric
	  ,f.NumberNumeric as FundNumberNumeric
      ,i.Number
      ,i.DescriptionLevelCode
      ,idl.Text as DescriptionLevelText
      ,i.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
      ,i.StatusCode
      ,s.Text as StatusText
	  ,i.AcquisitionMethodId
	  ,acq.Code as AcquisitionMethodCode
	  ,acq.Text as AcquisitionMethodText
      ,i.HasNoChronologicalScope
      ,i.StartDateYear
      ,i.StartDateMonth
      ,i.StartDateDay
      ,i.EndDateYear
      ,i.EndDateMonth
      ,i.EndDateDay
      ,i.ApproxmateChronologicalScope
      ,i.Bytes
      ,i.LinearMeters
      ,i.OtherMetrics
      ,i.ArchivalEntityCount
      ,i.DocumentCount
      ,i.BoxCount
      ,i.RollCount
      ,i.AudioDocumentArchivalEntityCount
      ,i.PhotoDocumentArchivalEntityCount
      ,i.VideoDocumentArchivalEntityCount
      ,i.DigitalDocumentArchivalEntityCount
      ,i.FundCreatorTitleHistory
      ,i.FundCreatorBiographicalHistory
      ,i.History
      ,i.DocumentsProvider
      ,i.DocumentsDescription
      ,i.DocumentsAccessDescription
      ,i.ClassificationScheme
      ,i.AbbreviationList
      ,i.MicrofilmedArchivalEntityCount
      ,i.DigitizedArchivalEntityCount
      ,i.NegativeFrameCount
      ,i.PositiveFrameCount
      ,i.Notes
	  ,i.ApplicationId
	  ,i.PackageAId
	  ,i.PackageBId
  FROM Inventories i
  JOIN Archives a ON i.ArchiveId = a.Id
  JOIN Funds f ON i.FundSystemIdentifier = f.SystemIdentifier
  LEFT JOIN InventoryDrafts id on i.SystemIdentifier = id.SystemIdentifier and id.IsCurrent = 1
  LEFT JOIN N.InventoryDescriptionLevel idl ON i.DescriptionLevelCode = idl.Code
  LEFT JOIN N.AvailabilityStatus ast ON i.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON i.StatusCode = s.Code
  LEFT JOIN N.Nomenclatures acq ON i.AcquisitionMethodId = acq.Id
  LEFT JOIN AspNetUsers cu ON i.CreatedBy = cu.Id
  LEFT JOIN AspNetUsers uu ON i.UpdatedBy = uu.Id
  LEFT JOIN AspNetUsers du ON i.CreatedBy = du.Id
 WHERE id.Id IS NULL

 UNION

 SELECT id.Id
      ,id.SystemIdentifier
	  ,CAST(1 as bit) as IsDraft
	  ,CAST(0 as bit) as IsSuspended
      ,id.ArchiveId
	  ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,id.FundDraftId
      ,id.FundSystemIdentifier
	  ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,id.CreatedOn
      ,id.CreatedBy
      ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,id.UpdatedOn
      ,id.UpdatedBy
      ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,id.Deleted
      ,id.DeletedOn
      ,id.DeletedBy
      ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,id.ExternalIdentifier
      ,id.HasExternalSource
      ,id.ExternalSourceUpdatedOn
      ,id.NumberArray
	  ,id.NumberNumeric
	  ,fd.NumberNumeric as FundNumberNumeric
      ,id.Number
      ,id.DescriptionLevelCode
      ,idl.Text as DescriptionLevelText
      ,id.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
      ,id.StatusCode
      ,s.Text as StatusText
	  ,id.AcquisitionMethodId
	  ,acq.Code as AcquisitionMethodCode
	  ,acq.Text as AcquisitionMethodText
      ,id.HasNoChronologicalScope
      ,id.StartDateYear
      ,id.StartDateMonth
      ,id.StartDateDay
      ,id.EndDateYear
      ,id.EndDateMonth
      ,id.EndDateDay
      ,id.ApproxmateChronologicalScope
      ,id.Bytes
      ,id.LinearMeters
      ,id.OtherMetrics
      ,id.ArchivalEntityCount
      ,id.DocumentCount
      ,id.BoxCount
      ,id.RollCount
      ,id.AudioDocumentArchivalEntityCount
      ,id.PhotoDocumentArchivalEntityCount
      ,id.VideoDocumentArchivalEntityCount
      ,id.DigitalDocumentArchivalEntityCount
      ,id.FundCreatorTitleHistory
      ,id.FundCreatorBiographicalHistory
      ,id.History
      ,id.DocumentsProvider
      ,id.DocumentsDescription
      ,id.DocumentsAccessDescription
      ,id.ClassificationScheme
      ,id.AbbreviationList
      ,id.MicrofilmedArchivalEntityCount
      ,id.DigitizedArchivalEntityCount
      ,id.NegativeFrameCount
      ,id.PositiveFrameCount
      ,id.Notes
	  ,id.ApplicationId
	  ,id.PackageAId
	  ,id.PackageBId
  FROM InventoryDrafts id
  JOIN Archives a ON id.ArchiveId = a.Id
  LEFT JOIN Funds f ON id.FundSystemIdentifier = f.SystemIdentifier
  LEFT JOIN FundDrafts fd ON id.FundSystemIdentifier = fd.SystemIdentifier AND id.FundDraftId = fd.Id 
  LEFT JOIN N.InventoryDescriptionLevel idl ON id.DescriptionLevelCode = idl.Code
  LEFT JOIN N.AvailabilityStatus ast ON id.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON id.StatusCode = s.Code
  LEFT JOIN N.Nomenclatures acq ON id.AcquisitionMethodId = acq.Id
  LEFT JOIN AspNetUsers cu ON id.CreatedBy = cu.Id
  LEFT JOIN AspNetUsers uu ON id.UpdatedBy = uu.Id
  LEFT JOIN AspNetUsers du ON id.CreatedBy = du.Id
 WHERE id.IsCurrent = 1
GO



---- Digital objects
--ALTER TABLE [dbo].[DigitalObjectDrafts]
--ALTER COLUMN [InventorySystemIdentifier] uniqueidentifier NULL
--GO

--ALTER TABLE [dbo].[DigitalObjectDrafts]
--ALTER COLUMN [ArchivalEntitySystemIdentifier] uniqueidentifier NULL
--GO

--ALTER TABLE [dbo].[DigitalObjects]
--ALTER COLUMN [InventorySystemIdentifier] uniqueidentifier NULL
--GO

--ALTER TABLE [dbo].[DigitalObjects]
--ALTER COLUMN [ArchivalEntitySystemIdentifier] uniqueidentifier NULL
--GO
----END Digital objects

----Documents
--ALTER TABLE [dbo].[DocumentDrafts]
--ALTER COLUMN [InventorySystemIdentifier] uniqueidentifier NULL
--GO

--ALTER TABLE [dbo].[DocumentDrafts]
--ALTER COLUMN [ArchivalEntitySystemIdentifier] uniqueidentifier NULL
--GO

--ALTER TABLE [dbo].[Documents]
--ALTER COLUMN [InventorySystemIdentifier] uniqueidentifier NULL
--GO

--ALTER TABLE [dbo].[Documents]
--ALTER COLUMN [ArchivalEntitySystemIdentifier] uniqueidentifier NULL
--GO
----END Documents

----Digital object reviews
--ALTER TABLE dbo.DigitalObjectReviews
--ALTER COLUMN [ArchivalEntitySystemIdentifier] uniqueidentifier NULL
--GO
----END Digital object reviews





IF NOT EXISTS(SELECT * 
			  FROM INFORMATION_SCHEMA.COLUMNS 
			  WHERE table_name = 'dbo.ArchivalEntityDrafts'
			  AND column_name = 'ClassificationSchemeIndex')
BEGIN
  ALTER TABLE dbo.ArchivalEntityDrafts
  ADD ClassificationSchemeIndex nvarchar(250)
END
GO


IF NOT EXISTS(SELECT * 
			  FROM INFORMATION_SCHEMA.COLUMNS 
			  WHERE table_name = 'dbo.ArchivalEntities'
			  AND column_name = 'ClassificationSchemeIndex')
BEGIN
  ALTER TABLE dbo.ArchivalEntities
  ADD ClassificationSchemeIndex nvarchar(250)
END
GO




CREATE OR ALTER   view [dbo].[v_ArchivalEntities]
AS

SELECT ae.Id
	  ,ae.SystemIdentifier
      ,CAST(0 as bit) as IsDraft
	  ,ae.IsSuspended
      ,ae.ArchiveId
      ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,NULL as FundDraftId
      ,ae.FundSystemIdentifier
	  ,f.NumberArray as FundNumberArray
	  ,f.NumberNumeric as FundNumberNumeric
      ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,NULL as InventoryDraftId
      ,ae.InventorySystemIdentifier
	  ,i.NumberArray as InventoryNumberArray
	  ,i.NumberNumeric as InventoryNumberNumeric
	  ,i.Number as InventoryNumber
	  ,i.HasExternalSource as InventoryHasExternalSource
	  ,i.ExternalIdentifier as InventoryExternalIdentifier
	  ,i.AvailabilityStatusCode as InventoryAvailabilityStatusCode
	  ,ae.CreatedOn
      ,ae.CreatedBy
      ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,ae.UpdatedOn
      ,ae.UpdatedBy
      ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,ae.Deleted
      ,ae.DeletedOn
      ,ae.DeletedBy
      ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,ae.HasExternalSource
      ,ae.ExternalIdentifier
      ,ae.ExternalSourceUpdatedOn
      ,ae.Number
	  ,ae.NumberNumeric
	  ,ae.NumberArray
      ,ae.Title
	  ,ae.DescriptionLevelCode
	  ,l.Text as DescriptionLevelText
      ,ae.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
      ,ae.StatusCode
	  ,s.Text as StatusText
      ,ae.HasNoChronologicalScope
      ,ae.StartDateYear
      ,ae.StartDateMonth
      ,ae.StartDateDay
      ,ae.EndDateYear
      ,ae.EndDateMonth
      ,ae.EndDateDay
      ,ae.ApproxmateChronologicalScope
      ,ae.Author
      ,ae.Location
      ,ae.Bytes
      ,ae.SheetCount
      ,ae.TapeCount
      ,ae.MicrofilmCount
      ,ae.FrameCount
      ,ae.VideoTapeCount
      ,ae.DigitalDeviceCount
      ,ae.OtherMetrics
      ,ae.SizeCm
      ,ae.Scaling
      ,ae.Description
      ,ae.DocumentsAccessDescription
      ,ae.Features
      ,ae.Condition
      ,ae.MicrofilmedCopyCount
      ,ae.DigitizedCopyCount
      ,ae.PaperCopyCount
      ,ae.NegativeFrameCount
      ,ae.PositiveFrameCount
      ,ae.OtherCopyCount
      ,ae.Notes
      ,ae.EnrolledBytes
      ,ae.EnrolledDocumentCount
      ,ae.EnrolledLinearMeters
      ,ae.DeductedBytes
      ,ae.DeductedDocumentCount
      ,ae.DeductedLinearMeters
	  ,ae.IsImported
	  ,ae.DescriptionAuthor
	  ,ae.Cypher
	  ,ae.TextDocsCount
	  ,ae.GraphicalDocsCount
	  ,ae.Phase
	  ,ae.Part
	  ,ae.Stage
	  ,ae.OtherLanguage
	  ,ae.ClassificationSchemeIndex

  FROM dbo.ArchivalEntities ae
  JOIN dbo.Archives a ON ae.ArchiveId = a.Id
  JOIN dbo.Funds f ON ae.FundSystemIdentifier = f.SystemIdentifier
  JOIN dbo.Inventories i ON ae.InventorySystemIdentifier = i.SystemIdentifier
  LEFT JOIN dbo.ArchivalEntityDrafts d on ae.SystemIdentifier = d.SystemIdentifier and d.IsCurrent = 1
  LEFT JOIN N.ArchivalEntityDescriptionLevel l ON ae.DescriptionLevelCode = l.Code
  LEFT JOIN N.AvailabilityStatus ast ON ae.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON ae.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON ae.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON ae.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON ae.DeletedBy = du.Id
 WHERE d.Id IS NULL

 UNION
 
SELECT d.Id
	  ,d.SystemIdentifier
      ,CAST(1 as bit) as IsDraft
	  ,CAST(0 as bit) as IsSuspended
      ,d.ArchiveId
      ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,d.FundDraftId
      ,d.FundSystemIdentifier
	  ,fd.NumberArray as FundNumberArray
	  ,fd.NumberNumeric as FundNumberNumeric
      ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,d.InventoryDraftId
      ,d.InventorySystemIdentifier
	  ,id.NumberArray as InventoryNumberArray
	  ,id.NumberNumeric as InventoryNumberNumeric
	  ,i.Number as InventoryNumber
	  ,i.HasExternalSource as InventoryHasExternalSource
	  ,i.ExternalIdentifier as InventoryExternalIdentifier
	  ,i.AvailabilityStatusCode as InventoryAvailabilityStatusCode
	  ,d.CreatedOn
      ,d.CreatedBy
      ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,d.UpdatedOn
      ,d.UpdatedBy
      ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,d.Deleted
      ,d.DeletedOn
      ,d.DeletedBy
      ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,d.HasExternalSource
      ,d.ExternalIdentifier
      ,d.ExternalSourceUpdatedOn
      ,d.Number
	  ,d.NumberNumeric
	  ,d.NumberArray
      ,d.Title
      ,d.DescriptionLevelCode
	  ,l.Text as DescriptionLevelText
	  ,d.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
      ,d.StatusCode
	  ,s.Text as StatusText
      ,d.HasNoChronologicalScope
      ,d.StartDateYear
      ,d.StartDateMonth
      ,d.StartDateDay
      ,d.EndDateYear
      ,d.EndDateMonth
      ,d.EndDateDay
      ,d.ApproxmateChronologicalScope
      ,d.Author
      ,d.Location
      ,d.Bytes
      ,d.SheetCount
      ,d.TapeCount
      ,d.MicrofilmCount
      ,d.FrameCount
      ,d.VideoTapeCount
      ,d.DigitalDeviceCount
      ,d.OtherMetrics
      ,d.SizeCm
      ,d.Scaling
      ,d.Description
      ,d.DocumentsAccessDescription
      ,d.Features
      ,d.Condition
      ,d.MicrofilmedCopyCount
      ,d.DigitizedCopyCount
      ,d.PaperCopyCount
      ,d.NegativeFrameCount
      ,d.PositiveFrameCount
      ,d.OtherCopyCount
      ,d.Notes
      ,d.EnrolledBytes
      ,d.EnrolledDocumentCount
      ,d.EnrolledLinearMeters
      ,d.DeductedBytes
      ,d.DeductedDocumentCount
      ,d.DeductedLinearMeters
	  ,d.IsImported
	  ,d.DescriptionAuthor
	  ,d.Cypher
	  ,d.TextDocsCount
	  ,d.GraphicalDocsCount
	  ,d.Phase
	  ,d.Part
	  ,d.Stage
	  ,d.OtherLanguage
	  ,d.ClassificationSchemeIndex

  FROM dbo.ArchivalEntityDrafts d
  JOIN dbo.Archives a ON d.ArchiveId = a.Id
  LEFT JOIN dbo.Funds f ON d.FundSystemIdentifier = f.SystemIdentifier
  LEFT JOIN dbo.FundDrafts fd ON d.FundSystemIdentifier = fd.SystemIdentifier AND d.FundDraftId = fd.Id 
  LEFT JOIN dbo.Inventories i ON d.InventorySystemIdentifier = i.SystemIdentifier 
  LEFT JOIN dbo.InventoryDrafts id ON d.InventorySystemIdentifier = id.SystemIdentifier AND d.InventoryDraftId = id.Id
  LEFT JOIN N.ArchivalEntityDescriptionLevel l ON d.DescriptionLevelCode = l.Code
  LEFT JOIN N.AvailabilityStatus ast ON d.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON d.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON d.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON d.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON d.DeletedBy = du.Id
 WHERE d.IsCurrent = 1
GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

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


CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventory] 
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
		  FROM [Archiving].[dbo].[Inventory_Modified] inventory
		 WHERE inventory.LGid = ' + CAST(@Identifier as varchar(10));

	set @sql = REPLACE(@sql, '''', '''''');
	declare @linkedServerQuery varchar(max) = '
		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''');';

	EXEC (@linkedServerQuery);	
END
GO
----------------------------------------------------------
--	THE SCRIPT IS CLOSED - USE THE NEW ONE!
----------------------------------------------------------

commit