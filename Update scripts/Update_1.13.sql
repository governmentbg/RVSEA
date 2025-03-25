SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.13'
where Code = 'DB_VERSION'

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'AcquisitionMethodId'
          AND Object_ID = Object_ID(N'dbo.FundDrafts'))
BEGIN
    ALTER TABLE dbo.FundDrafts
    ADD AcquisitionMethodId int NULL
END

IF OBJECT_ID('dbo.FK_FundDrafts_AcquisitionMethod') IS NOT NULL 
    ALTER TABLE dbo.FundDrafts DROP CONSTRAINT FK_FundDrafts_AcquisitionMethod
GO

ALTER TABLE dbo.FundDrafts  WITH CHECK ADD CONSTRAINT FK_FundDrafts_AcquisitionMethod FOREIGN KEY(AcquisitionMethodId)
REFERENCES N.Nomenclatures(Id)

ALTER TABLE dbo.FundDrafts CHECK CONSTRAINT FK_FundDrafts_AcquisitionMethod
GO

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'AcquisitionMethodId'
          AND Object_ID = Object_ID(N'dbo.Funds'))
BEGIN
    ALTER TABLE dbo.Funds
    ADD AcquisitionMethodId int NULL
END

IF OBJECT_ID('dbo.FK_Funds_AcquisitionMethod') IS NOT NULL 
    ALTER TABLE dbo.Funds DROP CONSTRAINT FK_Funds_AcquisitionMethod
GO

ALTER TABLE dbo.Funds  WITH CHECK ADD CONSTRAINT FK_Funds_AcquisitionMethod FOREIGN KEY(AcquisitionMethodId)
REFERENCES N.Nomenclatures(Id)

ALTER TABLE dbo.Funds CHECK CONSTRAINT FK_Funds_AcquisitionMethod
GO

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'AcquisitionMethodId'
          AND Object_ID = Object_ID(N'dbo.InventoryDrafts'))
BEGIN
    ALTER TABLE dbo.InventoryDrafts
    ADD AcquisitionMethodId int NULL
END

IF OBJECT_ID('dbo.FK_InventoryDrafts_AcquisitionMethod') IS NOT NULL 
    ALTER TABLE dbo.InventoryDrafts DROP CONSTRAINT FK_InventoryDrafts_AcquisitionMethod
GO

ALTER TABLE dbo.InventoryDrafts  WITH CHECK ADD CONSTRAINT FK_InventoryDrafts_AcquisitionMethod FOREIGN KEY(AcquisitionMethodId)
REFERENCES N.Nomenclatures(Id)

ALTER TABLE dbo.InventoryDrafts CHECK CONSTRAINT FK_InventoryDrafts_AcquisitionMethod
GO

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'AcquisitionMethodId'
          AND Object_ID = Object_ID(N'dbo.Inventories'))
BEGIN
    ALTER TABLE dbo.Inventories
    ADD AcquisitionMethodId int NULL
END

IF OBJECT_ID('dbo.FK_Inventories_AcquisitionMethod') IS NOT NULL 
    ALTER TABLE dbo.Inventories DROP CONSTRAINT FK_Inventories_AcquisitionMethod
GO

ALTER TABLE dbo.Inventories  WITH CHECK ADD CONSTRAINT FK_Inventories_AcquisitionMethod FOREIGN KEY(AcquisitionMethodId)
REFERENCES N.Nomenclatures(Id)

ALTER TABLE dbo.Inventories CHECK CONSTRAINT FK_Inventories_AcquisitionMethod
GO


CREATE OR ALTER view [dbo].[v_Funds]
AS
SELECT 
	   fd.Id
	  ,fd.SystemIdentifier
	  ,CAST(1 as bit) as IsDraft
	  ,CAST(0 as bit) as IsSuspended
      ,fd.ArchiveId
	  ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
      ,fd.CreatedOn
      ,fd.CreatedBy
	  ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,fd.UpdatedOn
      ,fd.UpdatedBy
	  ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,fd.Deleted
      ,fd.DeletedOn
      ,fd.DeletedBy
	  ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,fd.ExternalIdentifier
      ,fd.HasExternalSource
      ,fd.ExternalSourceUpdatedOn
      ,fd.NumberArray
	  ,fd.NumberNumeric
      ,fd.Number
      ,fd.Title
      ,fd.DescriptionLevelCode
	  ,dl.Text as DescriptionLevelText
      ,fd.TypeCode
	  ,ft.Text as TypeText
      ,fd.StatusCode
	  ,s.Text as StatusText
      ,fd.AcquisitionMethodId
	  ,acq.Code as AcquisitionMethodCode
	  ,acq.Text as AcquisitionMethodText
      ,fd.HasNoChronologicalScope
      ,fd.StartDateYear
      ,fd.StartDateMonth
      ,fd.StartDateDay
      ,fd.EndDateYear
      ,fd.EndDateMonth
      ,fd.EndDateDay
      ,fd.ApproxmateChronologicalScope
      ,fd.Bytes
      ,fd.LinearMeters
      ,fd.OtherMetrics
      ,fd.InventoryCount
      ,fd.ArchivalEntityCount
      ,fd.DocumentCount
      ,fd.FundCreatorTitleHistory
      ,fd.FundCreatorActivityHistory
      ,fd.FundCreatorBiographicalHistory
      ,fd.DocumentsProvider
      ,fd.DocumentsDescription
      ,fd.ValuableDocumentsInventoryCount
      ,fd.InvaluableDocumentsInventoryCount
      ,fd.DocumentsAccessDescription
      ,fd.History
      ,fd.RelatedFunds
      ,fd.Notes
      ,fd.EnrolledBytes
      ,fd.EnrolledInventoryCount
      ,fd.DeductedBytes
      ,fd.DeductedInventoryCount
    FROM FundDrafts fd
	JOIN Archives a ON fd.ArchiveId = a.Id
	LEFT JOIN N.FundDescriptionLevel dl ON fd.DescriptionLevelCode = dl.Code
	LEFT JOIN N.FundType ft ON fd.TypeCode = ft.Code
	LEFT JOIN N.Status s ON fd.StatusCode = s.Code
    LEFT JOIN N.Nomenclatures acq ON fd.AcquisitionMethodId = acq.Id
	LEFT JOIN AspNetUsers cu ON fd.CreatedBy = cu.Id
	LEFT JOIN AspNetUsers uu ON fd.UpdatedBy = uu.Id
	LEFT JOIN AspNetUsers du ON fd.CreatedBy = du.Id
   WHERE fd.IsCurrent = 1
   UNION
   SELECT 
	   f.Id
	  ,f.SystemIdentifier
	  ,CAST(0 as bit) as IsDraft
	  ,f.IsSuspended
      ,f.ArchiveId
	  ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
      ,f.CreatedOn
      ,f.CreatedBy
      ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,f.UpdatedOn
      ,f.UpdatedBy
      ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,f.Deleted
      ,f.DeletedOn
      ,f.DeletedBy
      ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,f.ExternalIdentifier
      ,f.HasExternalSource
      ,f.ExternalSourceUpdatedOn
      ,f.NumberArray
	  ,f.NumberNumeric
      ,f.Number
      ,f.Title
      ,f.DescriptionLevelCode
	  ,dl.Text as DescriptionLevelText
      ,f.TypeCode
	  ,ft.Text as TypeText
      ,f.StatusCode
	  ,s.Text as StatusText
	  ,f.AcquisitionMethodId
	  ,acq.Code as AcquisitionMethodCode
	  ,acq.Text as AcquisitionMethodText
      ,f.HasNoChronologicalScope
      ,f.StartDateYear
      ,f.StartDateMonth
      ,f.StartDateDay
      ,f.EndDateYear
      ,f.EndDateMonth
      ,f.EndDateDay
      ,f.ApproxmateChronologicalScope
      ,f.Bytes
      ,f.LinearMeters
      ,f.OtherMetrics
      ,f.InventoryCount
      ,f.ArchivalEntityCount
      ,f.DocumentCount
      ,f.FundCreatorTitleHistory
      ,f.FundCreatorActivityHistory
      ,f.FundCreatorBiographicalHistory
      ,f.DocumentsProvider
      ,f.DocumentsDescription
      ,f.ValuableDocumentsInventoryCount
      ,f.InvaluableDocumentsInventoryCount
      ,f.DocumentsAccessDescription
      ,f.History
      ,f.RelatedFunds
      ,f.Notes
      ,f.EnrolledBytes
      ,f.EnrolledInventoryCount
      ,f.DeductedBytes
      ,f.DeductedInventoryCount
    FROM Funds f
	JOIN Archives a ON f.ArchiveId = a.Id
	LEFT JOIN FundDrafts fd on f.SystemIdentifier = fd.SystemIdentifier and fd.IsCurrent = 1
	LEFT JOIN N.FundDescriptionLevel dl ON f.DescriptionLevelCode = dl.Code
	LEFT JOIN N.FundType ft ON f.TypeCode = ft.Code
	LEFT JOIN N.Status s ON f.StatusCode = s.Code
	LEFT JOIN N.Nomenclatures acq ON f.AcquisitionMethodId = acq.Id
	LEFT JOIN AspNetUsers cu ON f.CreatedBy = cu.Id
	LEFT JOIN AspNetUsers uu ON f.UpdatedBy = uu.Id
	LEFT JOIN AspNetUsers du ON f.CreatedBy = du.Id
   WHERE fd.id is null
GO


CREATE OR ALTER  view [dbo].[v_Inventories]
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
-- add scripts here


-- better add the file formats from UI!
--declare @fileTypeParentId int 
--select @fileTypeParentId = Id from N.Nomenclatures where Code = 'FILE_TYPE' and Deleted = 0



--if not exists (select null from N.Nomenclatures where ParentId = @fileTypeParentId and Text = 'DOC' and Deleted = 0)
--begin
--	insert into N.Nomenclatures([ParentId], [CreatedOn], [Code], [Text], [SortOrder], Inactive, Locked, Deleted)
--	values(@fileTypeParentId, GETDATE(), 5, 'DOC', 5, 0, 0, 0)
--end 


--if not exists (select null from N.Nomenclatures where ParentId = @fileTypeParentId and Text = 'XLS' and Deleted = 0)
--begin
--	insert into N.Nomenclatures([ParentId], [CreatedOn], [Code], [Text], [SortOrder], Inactive, Locked, Deleted)
--	values(@fileTypeParentId, GETDATE(), 6, 'XLS', 6, 0, 0, 0)
--end 


--if not exists (select null from N.Nomenclatures where ParentId = @fileTypeParentId and Text = 'XLSX' and Deleted = 0)
--begin
--	insert into N.Nomenclatures([ParentId], [CreatedOn], [Code], [Text], [SortOrder], Inactive, Locked, Deleted)
--	values(@fileTypeParentId, GETDATE(), 7, 'XLSX', 7, 0, 0, 0)
--end 


--if not exists (select null from N.Nomenclatures where ParentId = @fileTypeParentId and Text = 'PPT' and Deleted = 0)
--begin
--	insert into N.Nomenclatures([ParentId], [CreatedOn], [Code], [Text], [SortOrder], Inactive, Locked, Deleted)
--	values(@fileTypeParentId, GETDATE(), 8, 'PPT', 8, 0, 0, 0)
--end 

--if not exists (select null from N.Nomenclatures where ParentId = @fileTypeParentId and Text = 'PPTX' and Deleted = 0)
--begin
--	insert into N.Nomenclatures([ParentId], [CreatedOn], [Code], [Text], [SortOrder], Inactive, Locked, Deleted)
--	values(@fileTypeParentId, GETDATE(), 9, 'PPTX', 9, 0, 0, 0)
--end 


--if not exists (select null from N.Nomenclatures where ParentId = @fileTypeParentId and Text = 'TIFF' and Deleted = 0)
--begin
--	insert into N.Nomenclatures([ParentId], [CreatedOn], [Code], [Text], [SortOrder], Inactive, Locked, Deleted)
--	values(@fileTypeParentId, GETDATE(), 10, 'TIFF', 10, 0, 0, 0)
--end 


--if not exists (select null from N.Nomenclatures where ParentId = @fileTypeParentId and Text = 'PNG' and Deleted = 0)
--begin
--	insert into N.Nomenclatures([ParentId], [CreatedOn], [Code], [Text], [SortOrder], Inactive, Locked, Deleted)
--	values(@fileTypeParentId, GETDATE(), 11, 'PNG', 11, 0, 0, 0)
--end 


--if not exists (select null from N.Nomenclatures where ParentId = @fileTypeParentId and Text = 'WAVE' and Deleted = 0)
--begin
--	insert into N.Nomenclatures([ParentId], [CreatedOn], [Code], [Text], [SortOrder], Inactive, Locked, Deleted)
--	values(@fileTypeParentId, GETDATE(), 12, 'WAVE', 12, 0, 0, 0)
--end 


--if not exists (select null from N.Nomenclatures where ParentId = @fileTypeParentId and Text = 'WAV' and Deleted = 0)
--begin
--	insert into N.Nomenclatures([ParentId], [CreatedOn], [Code], [Text], [SortOrder], Inactive, Locked, Deleted)
--	values(@fileTypeParentId, GETDATE(), 13, 'WAV', 13, 0, 0, 0)
--end 

--if not exists (select null from N.Nomenclatures where ParentId = @fileTypeParentId and Text = 'MPEG' and Deleted = 0)
--begin
--	insert into N.Nomenclatures([ParentId], [CreatedOn], [Code], [Text], [SortOrder], Inactive, Locked, Deleted)
--	values(@fileTypeParentId, GETDATE(), 14, 'MPEG', 14, 0, 0, 0)
--end 


--if not exists (select null from N.Nomenclatures where ParentId = @fileTypeParentId and Text = 'DRAWIO' and Deleted = 0)
--begin
--	insert into N.Nomenclatures([ParentId], [CreatedOn], [Code], [Text], [SortOrder], Inactive, Locked, Deleted)
--	values(@fileTypeParentId, GETDATE(), 15, 'DRAWIO', 15, 0, 0, 0)
--end 


--if not exists (select null from N.Nomenclatures where ParentId = @fileTypeParentId and Text = 'JPEG' and Deleted = 0)
--begin
--	insert into N.Nomenclatures([ParentId], [CreatedOn], [Code], [Text], [SortOrder], Inactive, Locked, Deleted)
--	values(@fileTypeParentId, GETDATE(), 16, 'JPEG', 16, 0, 0, 0)
--end 


--if not exists (select null from N.Nomenclatures where ParentId = @fileTypeParentId and Text = 'JPG' and Deleted = 0)
--begin
--	insert into N.Nomenclatures([ParentId], [CreatedOn], [Code], [Text], [SortOrder], Inactive, Locked, Deleted)
--	values(@fileTypeParentId, GETDATE(), 17, 'JPG', 17, 0, 0, 0)
--end 


--if not exists (select null from N.Nomenclatures where ParentId = @fileTypeParentId and Text = 'TXT' and Deleted = 0)
--begin
--	insert into N.Nomenclatures([ParentId], [CreatedOn], [Code], [Text], [SortOrder], Inactive, Locked, Deleted)
--	values(@fileTypeParentId, GETDATE(), 18, 'TXT', 18, 0, 0, 0)
--end 

--if not exists (select null from N.Nomenclatures where ParentId = @fileTypeParentId and Text = 'MP4' and Deleted = 0)
--begin
--	insert into N.Nomenclatures([ParentId], [CreatedOn], [Code], [Text], [SortOrder], Inactive, Locked, Deleted)
--	values(@fileTypeParentId, GETDATE(), 19, 'MP4', 19, 0, 0, 0)
--end 
--go



update N.Nomenclatures
set Text = 'PNG'
where Text = 'РNG'
go


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetArchiveEntitiesByInventory]
	@LinkedServer nvarchar(255) = '', 
	@InventoryIdentifier uniqueidentifier = NULL,
	@InventoryHasExternalSource bit,
	@InventoryExternalIdentifier int = NULL,
	@SearchText nvarchar(max) = NULL,
	@SearchNumber nvarchar(max) = NULL,
	@IncludeDeleted bit = false,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20

AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @RemoteArchivalEntitiesQuery nvarchar(max) = '';
    DECLARE @RemoteArchivalEntities TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,IntNumber int
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,TapeCount int
		,MicrofilmCount int 
		,FrameCount int
		,VideoTapeCount int
		,DigitalDeviceCount int 
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Location nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,Features nvarchar(max)
		,Notes nvarchar(max)
		,Description nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,EnrolledDocumentCount int
        ,EnrolledLinearMeters float
        ,DeductedDocumentCount int
        ,DeductedLinearMeters float
		,SheetCount int
	);

	DECLARE @LocalArchivalEntities TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,IntNumber int
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,TapeCount int
		,MicrofilmCount int 
		,FrameCount int
		,VideoTapeCount int
		,DigitalDeviceCount int 
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Location nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,Features nvarchar(max)
		,Notes nvarchar(max)
		,Description nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,EnrolledDocumentCount int
        ,EnrolledLinearMeters float
        ,DeductedDocumentCount int
        ,DeductedLinearMeters float
		,SheetCount int
	);

	IF @InventoryHasExternalSource = 1
	BEGIN 

		SET @RemoteArchivalEntitiesQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
		,CAST(NULL as uniqueidentifier) as SystemIdentifier
		,CAST(1 as bit) as HasExternalSource
		,ae.[LGid] as ExternalIdentifier
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
		,CAST(1 as bit) as InventoryHasExternalSource
		,(select LGid from [Archiving].[dbo].Inventory_Active i where i.LGid = ae.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryExternalIdentifier
		,(select Number from [Archiving].[dbo].Inventory_Active i where i.LGid = ae.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryNumber
		,CAST(1 as bit) as FundHasExternalSource
		,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = ae.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
		,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = ae.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
		,(select Code from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
		,(select Name from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
		,ae.[Number] as Number
		,ae.[IntNumber] as IntNumber ' + '
		,ae.[Title] as Title
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
		,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
		,ae.[TextDate] as ApproximateChronologicalScope
		,ae.[MagnetTapesCount] as TapeCount
		,ae.[MicrofilmsCount] as MicrofilmCount
		,ae.[FramesCount] as FrameCount
		,ae.[VideoTapesCount] as VideoTapeCount 
		,ae.[ElectrCount] as DigitalDeviceCount
		,ae.[CopyMicrofilm] as MicrofilmedCopyCount
		,ae.[CopyDigital] as DigitizedCopyCount
		,ae.[PaperCount] as PaperCopyCount
		,ae.[CopyNegativFrames] as NegativeFrameCount
		,ae.[CopyPositiveFrames] as PositiveFrameCount
		,ae.[CopyOther] as OtherCopyCount
		,ae.[DimensionInCentimeters] as SizeCm
		,ae.[ExtentOther] as OtherMetrics
		,ae.[PlaceOfCreation] as Location ' + '
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
		,ae.[AccessConditions] as DocumentsAccessDescription
		,ae.[DocumentProperties] as Features
		,ae.[Note] as Notes
		,ae.[ExtendedContentDescription] as Description
		,ae.[StartDateYear] as StartDateYear
		,ae.[StartDateMonth] as StartDateMonth
		,ae.[StartDateDay] as StartDateDay
		,ae.[EndDateYear] as EndDateYear
		,ae.[EndDateMonth] as EndDateMonth
		,ae.[EndDateDay] as EndDateDay
		,ae.[IsNoDate] as HasNoChronologicalScope
		,ae.[AveilabilityDocumentsCountAssigned] as EnrolledDocumentCount
        ,ae.[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters 
        ,ae.[AveilabilityDocumentsCountDeducted] as DeductedDocumentCount
        ,ae.[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
		,ae.PaperCount as SheetCount
	FROM [Archiving].[dbo].[ArchiveEntity_Active] ae
	WHERE ae.InventoryLGid = ' + CAST(@InventoryExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
		BEGIN
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  ' AND (ae.Title LIKE ''''%' + @SearchText + '%'''' OR ae.Number LIKE ''''%' + @SearchText + '%'''')'
		END;

		IF @SearchNumber IS NOT NULL
		BEGIN
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  'AND ( ae.Number LIKE '+ @SearchNumber +')'
		END;

		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteArchivalEntitiesQuery + ''' )';
		
		INSERT INTO @RemoteArchivalEntities 
		EXEC(@RemoteQuery)

		
	END

	IF @InventoryIdentifier IS NOT NULL
	BEGIN

		INSERT INTO @LocalArchivalEntities
		SELECT	 ae.Id
				,ae.SystemIdentifier as SystemIdentifier
				,ae.HasExternalSource
				,ae.ExternalIdentifier
				,ae.StatusCode
				,ae.StatusText
				,ae.InventoryHasExternalSource
				,ae.InventoryExternalIdentifier
				,ae.InventoryNumber
				,ae.FundHasExternalSource
				,ae.FundExternalIdentifier
				,ae.FundNumber
				,ae.ArchiveCode
				,ae.ArchiveName
				,ae.Number as Number
				,NULL as IntNumber
				,ae.Title
				,ae.DescriptionLevelCode
				,ae.DescriptionLevelText
				,ae.AvailabilityStatusCode
				,ae.AvailabilityStatusText
				,ae.ApproxmateChronologicalScope
				,ae.TapeCount
				,ae.MicrofilmCount
				,ae.FrameCount
				,ae.VideoTapeCount
				,ae.DigitalDeviceCount
				,ae.MicrofilmedCopyCount
				,ae.DigitizedCopyCount
				,ae.PaperCopyCount
				,ae.NegativeFrameCount
				,ae.PositiveFrameCount
				,ae.OtherCopyCount
				,ae.SizeCm
				,ae.OtherMetrics
				,ae.Location
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
				,ae.DocumentsAccessDescription
				,ae.Features
				,ae.Notes
				,ae.Description
				,ae.StartDateYear
				,ae.StartDateMonth
				,ae.StartDateDay
				,ae.EndDateYear
				,ae.EndDateMonth
				,ae.EndDateDay
				,ae.HasNoChronologicalScope
				,ae.EnrolledDocumentCount
				,ae.EnrolledLinearMeters
				,ae.DeductedDocumentCount
				,ae.DeductedLinearMeters
				,ae.SheetCount
	     FROM [dbo].[v_ArchivalEntities] ae
	    WHERE ae.InventorySystemIdentifier = @InventoryIdentifier 
		  AND ae.HasExternalSource = 0
		  AND ae.Deleted = 0
		  AND (@SearchText IS NULL OR (ae.Title LIKE '%'+ @SearchText +'%' OR ae.Number LIKE '%'+ @SearchText +'%'))
		  AND (@IncludeDeleted = 1 OR ae.Deleted = 0)

	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalArchivalEntities
		  UNION
		 SELECT *
		   FROM @RemoteArchivalEntities
	   ) ArchivalEntities
	ORDER BY IntNumber
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetArchiveEntitiesByInventoryCount]
	@LinkedServer nvarchar(255) = '', 
	@InventoryIdentifier uniqueidentifier = NULL,
	@InventoryHasExternalSource bit,
	@InventoryExternalIdentifier int = NULL,
	@SearchText nvarchar(max) = NULL,
	@SearchNumber nvarchar(max) = NULL,
	@IncludeDeleted bit = false
	
AS
BEGIN
	SET NOCOUNT ON;


	DECLARE @RemoteArchivalEntities TABLE ( ArchivalEntityCount int );
	DECLARE @RemoteArchivalEntitiesCount int = 0;
	DECLARE @LocalArchivalEntitiesCount int = 0;

	DECLARE @RemoteArchivalEntitiesQuery nvarchar(max) = '';
		
	IF @InventoryHasExternalSource = 1
	BEGIN 
		SET @RemoteArchivalEntitiesQuery = CAST('' as nvarchar(max)) +
		'SELECT LGid
		   FROM [Archiving].[dbo].[ArchiveEntity_Active] ae
		  WHERE ae.InventoryLGid = ' + CAST(@InventoryExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery + ' AND Title LIKE ''''%' + @SearchText + '%'''''
		
		IF @SearchNumber IS NOT NULL
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  'AND ( ae.Number LIKE '+ @SearchNumber +')'

		DECLARE @RemoteQuery nvarchar(max) = 'SELECT COUNT(*) as ArchivalEntityCount FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteArchivalEntitiesQuery + ''' )';
		
		PRINT @RemoteQuery
		
		INSERT INTO @RemoteArchivalEntities
		EXEC(@RemoteQuery)

		SELECT TOP 1 @RemoteArchivalEntitiesCount = ArchivalEntityCount from @RemoteArchivalEntities

	END

	IF @InventoryIdentifier IS NOT NULL
	BEGIN
		SELECT @LocalArchivalEntitiesCount = COUNT(ae.Id)
		  FROM [dbo].[v_ArchivalEntities] ae
		 WHERE ae.InventorySystemIdentifier = @InventoryIdentifier 
		   AND ae.HasExternalSource = 0
		   AND (@IncludeDeleted = 1 OR ae.Deleted = 0)
	END

	RETURN @LocalArchivalEntitiesCount + @RemoteArchivalEntitiesCount

	
	
	
	--IF @InventoryExternalIdentifier is NULL SET @InventoryExternalIdentifier=-1;
	--IF @InventoryInternalIdentifier is NULL SET @InventoryInternalIdentifier=-1;

	--declare @searchStringContition varchar(max) = '';
	--IF @SearchString IS NOT NULL SET @searchStringContition=' AND Title LIKE ''%' + @SearchString + '%''';

	--declare @sql varchar(max) = 
	--	'SELECT LGid as ExternalIdentifier, CAST(0 AS BIT) as Deleted
	--	FROM [Archiving].[dbo].ArchiveEntity_Active
	--	WHERE InventoryLGid = ' + CAST(@InventoryExternalIdentifier as varchar(10)) + @searchStringContition + ';';

	--set @sql = REPLACE(@sql, '''', '''''');

	--declare @finalQuery varchar(max) = '';

	--declare @declareRemoteArchiveEntitiesTable varchar(max) =
	--	'DECLARE @remoteArchiveEntitiesTable TABLE (
	--		[ExternalIdentifier] [int] NULL,
	--		[Deleted] BIT NOT NULL
	--	);';
	--declare @declareRemoteArchiveEntitiesTable1 varchar(max) = '';
	--declare @declareRemoteArchiveEntitiesTable2 varchar(max) = '';
	--declare @localServerQuerySelect varchar(max) = '';

	--IF @HasInventoryExternalSource=0 
	--BEGIN
	--	SET @declareRemoteArchiveEntitiesTable1 = @declareRemoteArchiveEntitiesTable;
	--	SET @localServerQuerySelect = 'SELECT COUNT_BIG(*) TotalRows ';
	--END;
	--IF @HasInventoryExternalSource=1 
	--BEGIN
	--	SET @declareRemoteArchiveEntitiesTable2 = @declareRemoteArchiveEntitiesTable;
	--	SET @localServerQuerySelect = 'SELECT ExternalIdentifier, Deleted ';
	--END;

	--declare @includeDeletedCondition varchar(max) = '';
	--IF @IncludeDeleted=0 SET @includeDeletedCondition = ' AND Deleted = 0';

	--declare @localServerQuery varchar(max) = @declareRemoteArchiveEntitiesTable1 + 
	--	@localServerQuerySelect + '
	--	FROM dbo.ArchivalEntities ae
	--	WHERE InventoryId = ' + CAST(@InventoryInternalIdentifier as varchar(10))
	--		+ ' AND not exists(SELECT 1 FROM @remoteArchiveEntitiesTable raet where ae.ExternalIdentifier = raet.ExternalIdentifier)' +  @searchStringContition + @includeDeletedCondition;

	--declare @bothServerQueries varchar(max) = @declareRemoteArchiveEntitiesTable2 + '
	--	INSERT INTO @remoteArchiveEntitiesTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''');

	--	SELECT COUNT_BIG(*) TotalRows FROM
	--		(SELECT * FROM @remoteArchiveEntitiesTable
	--		UNION '
	--			+ @localServerQuery + ') AS c';

	--IF @HasInventoryExternalSource=1
	--BEGIN
	--	SET @finalQuery = @bothServerQueries; 
	--END;
	--IF @HasInventoryExternalSource=0 
	--BEGIN
	--	SET @finalQuery = @localServerQuery;
	--END;

	--EXEC (@finalQuery);	
END
GO


if not exists (select null from sys.columns where name = 'PhoneNumber' and object_id = object_id ('dbo.AspNetUserProfiles'))
begin 
	alter table dbo.AspNetUserProfiles add PhoneNumber nvarchar(max) null
end
go


if not exists (select null from sys.columns where name = 'Eik' and object_id = object_id ('dbo.AspNetUserProfiles'))
begin 
	alter table dbo.AspNetUserProfiles add Eik nvarchar(max) null
end
go


if not exists (select null from N.ProcessSteps)
begin 
	insert into N.ProcessSteps(Id, ProcessTypeId, Code,Text,AllowTaskTemplate)
	values (247, 10, 'Introduction of an opinion by EPK members', 'Въвеждане на становище от членове на ЕПК ',1),
		   (248, 10, 'Entering comments', 'Въвеждане на коментари',1)
end
go

if not exists (select null from dbo.TaskTemplatesSteps)
begin 
	insert into dbo.TaskTemplatesSteps(TaskTemplate_Id, ProcessStep_Id)
	values (54,247),
		   (27,248)
end
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetMostUsedRequestEntitiesReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(10) = null,
	@InventoryNumber nvarchar(10) = null,
	@ArchiveEntityNumber nvarchar(10) = null,
	@DocumentNumber nvarchar(10) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodesInternal nvarchar(256) = null,
	@DocumentDescriptionLevelCodesInternal nvarchar(256) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	-- Ползвам CONVERT(NVARCHAR(MAX), ''), защото при конкатениране броят на символите в NVARCHAR(MAX) променливата се ограничава на макс. 4000

	DECLARE @sql NVARCHAR(MAX);
	DECLARE @sqlFinalPart NVARCHAR(MAX) =  CONVERT(NVARCHAR(MAX),'
		order by UsageCount desc
		offset ') + CONVERT(NVARCHAR(10), @offset) +  CONVERT(NVARCHAR(MAX),' rows fetch next ') + CONVERT(NVARCHAR(10), @RowsOfPage) +  CONVERT(VARCHAR(MAX),' rows only');

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery NVARCHAR(MAX) = '
			SELECT 
				a.Name AS Archive,
				n.Value AS DescriptionLevel,
				f.Number AS FundNumber,
				i.Number AS InventoryNumber,
				ae.Number AS ArchiveEntityNumber,
				NULL AS DocumentNumber,
				COUNT_BIG (*) UsageCount,
				''External'' AS Source
			FROM ArchiveEntity_Active as ae
			INNER JOIN RequestEntities re ON re.ArchiveEntityLGid = ae.LGid 
			INNER JOIN Archive a ON a.Gid = ae.ArchiveGid
			INNER JOIN Fund_Active f ON f.LGid = ae.FundLGid
			INNER JOIN Inventory_Active i ON i.LGid = ae.InventoryLGid
			LEFT JOIN Nomenclature n ON n.Gid = ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01''
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + CONVERT(VARCHAR(MAX),''', '',''))) OR a.Code in (select element from dbo.SplitString(''') + @ArchiveCodes +  CONVERT(VARCHAR(MAX),''', '','')))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')))  + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @LevelOfDescriptionGids + CONVERT(NVARCHAR(MAX),''', '',''))) OR (ae.LevelOfDescriptionGid in (select element from dbo.SplitString(''') + @LevelOfDescriptionGids + CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY ArchiveEntityLGid, f.Number, i.Number, ae.Number, a.Name, n.Value
			');
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
			SELECT
				a.Name AS Archive,
				fdl.Text AS DescriptionLevel,
				f.Number AS FundNumber,
				NULL AS InventoryNumber,
				NULL AS ArchiveEntityNumber,
				NULL AS DocumentNumber,
				COUNT_BIG (*) AS UsageCount,
				''Internal'' AS Source
			FROM PublicUserReviews pur
			INNER JOIN Funds f ON f.SystemIdentifier = pur.FundSystemIdentifier 
			INNER JOIN Archives a ON a.Id = f.ArchiveId
			LEFT JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode 
			WHERE f.Deleted = 0 
				AND pur.FundSystemIdentifier IS NOT NULL
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @FundDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''') + @FundDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY f.SystemIdentifier, f.Number, a.Name, fdl.Text

			UNION

			SELECT
				a.Name AS Archive,
				idl.Text AS DescriptionLevel,
				f.Number AS FundNumber,
				i.Number AS InventoryNumber,
				NULL AS ArchiveEntityNumber,
				NULL AS DocumentNumber,
				COUNT_BIG (*) AS UsageCount,
				''Internal'' AS Source
			FROM PublicUserReviews pur
			INNER JOIN Inventories i ON i.SystemIdentifier = pur.InventorySystemIdentifier 
			INNER JOIN Funds f ON f.SystemIdentifier = i.FundSystemIdentifier 
			INNER JOIN Archives a ON a.Id = i.ArchiveId
			LEFT JOIN N.InventoryDescriptionLevel idl ON idl.Code = i.DescriptionLevelCode 
			WHERE i.Deleted = 0 
				AND pur.InventorySystemIdentifier IS NOT NULL
				AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @InventoryDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''') + @InventoryDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY i.SystemIdentifier, f.Number, i.Number, a.Name, idl.Text

			UNION

			SELECT
				a.Name AS Archive,
				aedl.Text AS DescriptionLevel,
				f.Number AS FundNumber,
				i.Number AS InventoryNumber,
				ae.Number AS ArchiveEntityNumber,
				NULL AS DocumentNumber,
				COUNT_BIG (*) AS UsageCount,
				''Internal'' AS Source
			FROM PublicUserReviews pur
			INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = pur.ArchivalEntitySystemIdentifier 
			INNER JOIN Funds f ON f.SystemIdentifier = ae.FundSystemIdentifier 
			INNER JOIN Inventories i ON i.SystemIdentifier = ae.InventorySystemIdentifier 
			INNER JOIN Archives a ON a.Id = ae.ArchiveId
			LEFT JOIN N.ArchivalEntityDescriptionLevel aedl ON aedl.Code = ae.DescriptionLevelCode 
			WHERE ae.Deleted = 0 
				AND pur.ArchivalEntitySystemIdentifier IS NOT NULL
				AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchivalEntityDescriptionLevelCodesInternal +  CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''') + @ArchivalEntityDescriptionLevelCodesInternal +  CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY ae.SystemIdentifier, f.Number, i.Number, ae.Number, a.Name, aedl.Text

			UNION

			SELECT
				a.Name AS Archive,
				ddl.Text AS DescriptionLevel,
				f.Number AS FundNumber,
				i.Number AS InventoryNumber,
				ae.Number AS ArchiveEntityNumber,
				d.Number AS DocumentNumber,
				COUNT_BIG (*) AS UsageCount,
				''Internal'' Source
			FROM PublicUserReviews pur
			INNER JOIN Documents d ON d.SystemIdentifier = pur.DocumentSystemIdentifier 
			INNER JOIN Archives a ON a.Id = d.ArchiveId
			INNER JOIN Funds f ON f.SystemIdentifier = d.FundSystemIdentifier 
			INNER JOIN Inventories i ON i.SystemIdentifier = d.InventorySystemIdentifier 
			INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier 		
			LEFT JOIN N.DocumentDescriptionLevel ddl ON ddl.Code = d.DescriptionLevelCode
			WHERE d.Deleted = 0 
				AND pur.DocumentSystemIdentifier IS NOT NULL
				AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  +  CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes +  CONVERT(NVARCHAR(MAX),''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@DocumentNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (d.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@DocumentNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @DocumentDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (d.DescriptionLevelCode in (select element from dbo.SplitString(''') + @DocumentDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY d.SystemIdentifier, f.Number, i.Number, ae.Number, d.Number, a.Name, ddl.Text
			');
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Archive nvarchar(256) NOT NULL,
				DescriptionLevel nvarchar(MAX) NULL,
				FundNumber nvarchar(256) NULL,
				InventoryNumber nvarchar(256) NULL,
				ArchiveEntityNumber nvarchar(256) NULL,
				DocumentNumber nvarchar(256) NULL,
				UsageCount BIGINT,
				Source VARCHAR(50)
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteFundsTable
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

CREATE OR ALTER PROCEDURE [dbo].[GetMostUsedRequestEntitiesReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(10) = null,
	@InventoryNumber nvarchar(10) = null,
	@ArchiveEntityNumber nvarchar(10) = null,
	@DocumentNumber nvarchar(10) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodesInternal nvarchar(256) = null,
	@DocumentDescriptionLevelCodesInternal nvarchar(256) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT_BIG(*) TotalRows FROM 
			(
				SELECT COUNT_BIG(*) TotalRows
				FROM ArchiveEntity_Active as ae
				INNER JOIN RequestEntities re ON re.ArchiveEntityLGid = ae.LGid 
				INNER JOIN Archive a ON a.Gid = ae.ArchiveGid
				INNER JOIN Fund_Active f ON f.LGid = ae.FundLGid
				INNER JOIN Inventory_Active i ON i.LGid = ae.InventoryLGid
				LEFT JOIN Nomenclature n ON n.Gid = ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01''
				WHERE 
					((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + CONVERT(VARCHAR(MAX),''', '',''))) OR a.Code in (select element from dbo.SplitString(''') + @ArchiveCodes +  CONVERT(VARCHAR(MAX),''', '','')))
					AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')))  + CONVERT(NVARCHAR(MAX),'''))
					AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
					AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
					AND ((''-999'' in (select element from dbo.SplitString(''') + @LevelOfDescriptionGids + CONVERT(NVARCHAR(MAX),''', '',''))) OR (ae.LevelOfDescriptionGid in (select element from dbo.SplitString(''') + @LevelOfDescriptionGids + CONVERT(NVARCHAR(MAX),''', '',''))))
				GROUP BY ArchiveEntityLGid, f.Number, i.Number, ae.Number, a.Name, n.Value
			) t1
		');

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = CONVERT(NVARCHAR(MAX),'
			SELECT SUM(Rows) TotalRows FROM (
				SELECT COUNT_BIG(*) Rows FROM 
				(
					SELECT COUNT_BIG(*) Rows
					FROM PublicUserReviews pur
					INNER JOIN Funds f ON f.SystemIdentifier = pur.FundSystemIdentifier 
					INNER JOIN Archives a ON a.Id = f.ArchiveId
					LEFT JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode 
					WHERE f.Deleted = 0 
						AND pur.FundSystemIdentifier IS NOT NULL
						AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
							OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
						AND ((''-999'' in (select element from dbo.SplitString(''') + @FundDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
							OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''') + @FundDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
					GROUP BY f.SystemIdentifier, f.Number, a.Name, fdl.Text
				) t1

				UNION ALL

				SELECT COUNT_BIG(*) Rows FROM 
				(
					SELECT COUNT_BIG(*) Rows
					FROM PublicUserReviews pur
					INNER JOIN Inventories i ON i.SystemIdentifier = pur.InventorySystemIdentifier 
					INNER JOIN Funds f ON f.SystemIdentifier = i.FundSystemIdentifier 
					INNER JOIN Archives a ON a.Id = i.ArchiveId
					LEFT JOIN N.InventoryDescriptionLevel idl ON idl.Code = i.DescriptionLevelCode 
					WHERE i.Deleted = 0 
						AND pur.InventorySystemIdentifier IS NOT NULL
						AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  + CONVERT(NVARCHAR(MAX),''', '',''))) 
							OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
						AND ((''-999'' in (select element from dbo.SplitString(''') + @InventoryDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
							OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''') + @InventoryDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
					GROUP BY i.SystemIdentifier, f.Number, i.Number, a.Name, idl.Text
				) t2

				UNION ALL

				SELECT COUNT_BIG(*) Rows FROM 
				(
					SELECT COUNT_BIG(*) Rows
					FROM PublicUserReviews pur
					INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = pur.ArchivalEntitySystemIdentifier 
					INNER JOIN Funds f ON f.SystemIdentifier = ae.FundSystemIdentifier 
					INNER JOIN Inventories i ON i.SystemIdentifier = ae.InventorySystemIdentifier 
					INNER JOIN Archives a ON a.Id = ae.ArchiveId
					LEFT JOIN N.ArchivalEntityDescriptionLevel aedl ON aedl.Code = ae.DescriptionLevelCode 
					WHERE ae.Deleted = 0 
						AND pur.ArchivalEntitySystemIdentifier IS NOT NULL
						AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  + CONVERT(NVARCHAR(MAX),''', '',''))) 
							OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),'''))
						AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchivalEntityDescriptionLevelCodesInternal +  CONVERT(NVARCHAR(MAX),''', '',''))) 
							OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''') + @ArchivalEntityDescriptionLevelCodesInternal +  CONVERT(NVARCHAR(MAX),''', '',''))))
					GROUP BY ae.SystemIdentifier, f.Number, i.Number, ae.Number, a.Name, aedl.Text
				) t3

				UNION ALL

				SELECT COUNT_BIG(*) Rows FROM 
				(
					SELECT COUNT_BIG(*) Rows
					FROM PublicUserReviews pur
					INNER JOIN Documents d ON d.SystemIdentifier = pur.DocumentSystemIdentifier 
					INNER JOIN Archives a ON a.Id = d.ArchiveId
					INNER JOIN Funds f ON f.SystemIdentifier = d.FundSystemIdentifier 
					INNER JOIN Inventories i ON i.SystemIdentifier = d.InventorySystemIdentifier 
					INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier 		
					LEFT JOIN N.DocumentDescriptionLevel ddl ON ddl.Code = d.DescriptionLevelCode
					WHERE d.Deleted = 0 
						AND pur.DocumentSystemIdentifier IS NOT NULL
						AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  +  CONVERT(NVARCHAR(MAX),''', '',''))) 
							OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes +  CONVERT(NVARCHAR(MAX),''', '',''))))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),'''))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@DocumentNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (d.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@DocumentNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
						AND ((''-999'' in (select element from dbo.SplitString(''') + @DocumentDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
							OR (d.DescriptionLevelCode in (select element from dbo.SplitString(''') + @DocumentDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
					GROUP BY d.SystemIdentifier, f.Number, i.Number, ae.Number, d.Number, a.Name, ddl.Text
				) t4
			) t
					
		');
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE ( 
				TotalRows bigint NULL
			);

			INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery;
	END

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetMostUsedRequestEntitiesReportTotalCount] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(10) = null,
	@InventoryNumber nvarchar(10) = null,
	@ArchiveEntityNumber nvarchar(10) = null,
	@DocumentNumber nvarchar(10) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodesInternal nvarchar(256) = null,
	@DocumentDescriptionLevelCodesInternal nvarchar(256) = null
AS
BEGIN
	SET NOCOUNT ON;

	-- Ползвам CONVERT(NVARCHAR(MAX), ''), защото при конкатениране броят на символите в NVARCHAR(MAX) променливата се ограничава на макс. 4000

	DECLARE @sql NVARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery NVARCHAR(MAX) = '
			SELECT 
				COUNT_BIG (*) UsageCount
			FROM ArchiveEntity_Active as ae
			INNER JOIN RequestEntities re ON re.ArchiveEntityLGid = ae.LGid 
			INNER JOIN Archive a ON a.Gid = ae.ArchiveGid
			INNER JOIN Fund_Active f ON f.LGid = ae.FundLGid
			INNER JOIN Inventory_Active i ON i.LGid = ae.InventoryLGid
			LEFT JOIN Nomenclature n ON n.Gid = ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01''
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + CONVERT(VARCHAR(MAX),''', '',''))) OR a.Code in (select element from dbo.SplitString(''') + @ArchiveCodes +  CONVERT(VARCHAR(MAX),''', '','')))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')))  + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @LevelOfDescriptionGids + CONVERT(NVARCHAR(MAX),''', '',''))) OR (ae.LevelOfDescriptionGid in (select element from dbo.SplitString(''') + @LevelOfDescriptionGids + CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY ArchiveEntityLGid, f.Number, i.Number, ae.Number, a.Name, n.Value
			');
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
			SELECT
				COUNT_BIG (*) AS UsageCount
			FROM PublicUserReviews pur
			INNER JOIN Funds f ON f.SystemIdentifier = pur.FundSystemIdentifier 
			INNER JOIN Archives a ON a.Id = f.ArchiveId
			LEFT JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode 
			WHERE f.Deleted = 0 
				AND pur.FundSystemIdentifier IS NOT NULL
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @FundDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''') + @FundDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY f.SystemIdentifier, f.Number, a.Name, fdl.Text

			UNION ALL

			SELECT
				COUNT_BIG (*) AS UsageCount
			FROM PublicUserReviews pur
			INNER JOIN Inventories i ON i.SystemIdentifier = pur.InventorySystemIdentifier 
			INNER JOIN Funds f ON f.SystemIdentifier = i.FundSystemIdentifier 
			INNER JOIN Archives a ON a.Id = i.ArchiveId
			LEFT JOIN N.InventoryDescriptionLevel idl ON idl.Code = i.DescriptionLevelCode 
			WHERE i.Deleted = 0 
				AND pur.InventorySystemIdentifier IS NOT NULL
				AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @InventoryDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''') + @InventoryDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY i.SystemIdentifier, f.Number, i.Number, a.Name, idl.Text

			UNION ALL

			SELECT
				COUNT_BIG (*) AS UsageCount
			FROM PublicUserReviews pur
			INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = pur.ArchivalEntitySystemIdentifier 
			INNER JOIN Funds f ON f.SystemIdentifier = ae.FundSystemIdentifier 
			INNER JOIN Inventories i ON i.SystemIdentifier = ae.InventorySystemIdentifier 
			INNER JOIN Archives a ON a.Id = ae.ArchiveId
			LEFT JOIN N.ArchivalEntityDescriptionLevel aedl ON aedl.Code = ae.DescriptionLevelCode 
			WHERE ae.Deleted = 0 
				AND pur.ArchivalEntitySystemIdentifier IS NOT NULL
				AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchivalEntityDescriptionLevelCodesInternal +  CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''') + @ArchivalEntityDescriptionLevelCodesInternal +  CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY ae.SystemIdentifier, f.Number, i.Number, ae.Number, a.Name, aedl.Text

			UNION ALL

			SELECT
				COUNT_BIG (*) AS UsageCount
			FROM PublicUserReviews pur
			INNER JOIN Documents d ON d.SystemIdentifier = pur.DocumentSystemIdentifier 
			INNER JOIN Archives a ON a.Id = d.ArchiveId
			INNER JOIN Funds f ON f.SystemIdentifier = d.FundSystemIdentifier 
			INNER JOIN Inventories i ON i.SystemIdentifier = d.InventorySystemIdentifier 
			INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier 		
			LEFT JOIN N.DocumentDescriptionLevel ddl ON ddl.Code = d.DescriptionLevelCode
			WHERE d.Deleted = 0 
				AND pur.DocumentSystemIdentifier IS NOT NULL
				AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  +  CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes +  CONVERT(NVARCHAR(MAX),''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@DocumentNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (d.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@DocumentNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @DocumentDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (d.DescriptionLevelCode in (select element from dbo.SplitString(''') + @DocumentDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY d.SystemIdentifier, f.Number, i.Number, ae.Number, d.Number, a.Name, ddl.Text
			');
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				UsageCount BIGINT
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT SUM(UsageCount) UsageCountTotal FROM (
				SELECT UsageCount FROM @remoteFundsTable
				UNION ALL
				' +
				@localQuery + ') t';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''SELECT SUM(UsageCount) UsageCountTotal FROM (' + @remoteQuery + ') t'');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = 'SELECT SUM(UsageCount) UsageCountTotal FROM (' + @localQuery + ') t';
	END

	EXEC (@sql);
END
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

if (OBJECT_ID ('dbo.PublicUserReviews') is null)
begin
	CREATE TABLE [PublicUserReviews] (
		Id int IDENTITY(1,1) NOT NULL,
		SystemIdentifier uniqueidentifier NOT NULL, 
		UserId uniqueidentifier NOT NULL FOREIGN KEY REFERENCES [AspNetUsers](Id),
		[Date] datetime2(7) NOT NULL,
		FundSystemIdentifier uniqueidentifier NULL FOREIGN KEY REFERENCES [Funds](SystemIdentifier),
		InventorySystemIdentifier uniqueidentifier NULL FOREIGN KEY REFERENCES [Inventories](SystemIdentifier),
		ArchivalEntitySystemIdentifier uniqueidentifier NULL FOREIGN KEY REFERENCES [ArchivalEntities](SystemIdentifier),
		DocumentSystemIdentifier uniqueidentifier NULL FOREIGN KEY REFERENCES [Documents](SystemIdentifier),

	 CONSTRAINT [PK_PublicUserReviews] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
	 CONSTRAINT [UI_PublicUserReviewsSystemIdentifier] UNIQUE NONCLUSTERED 
	(
		[SystemIdentifier] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
end
GO

SET ANSI_NULLS ON
GO

if exists (select null from sys.columns where name = 'UserDisplayName' and object_id ('dbo.DigitalObjectReviews') = object_id)
begin
	alter table dbo.DigitalObjectReviews drop column UserDisplayName
end
go

if exists (select null from sys.columns where name = 'UserType' and object_id ('dbo.DigitalObjectReviews') = object_id)
begin
	alter table dbo.DigitalObjectReviews drop column UserType
end
go


DROP PROCEDURE IF EXISTS [dbo].[sp_GetInventory]
GO

CREATE PROCEDURE [dbo].[sp_GetInventory] 
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
		  FROM [Archiving].[dbo].[Inventory_Active] inventory
		 WHERE inventory.LGid = ' + CAST(@Identifier as varchar(10));

	set @sql = REPLACE(@sql, '''', '''''');
	declare @linkedServerQuery varchar(max) = '
		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''');';

	EXEC (@linkedServerQuery);	
END
GO

DROP PROCEDURE IF EXISTS dbo.sp_GetFundInventories
GO

CREATE PROCEDURE dbo.sp_GetFundInventories
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
		  FROM [Archiving].[dbo].[Inventory_Active] inventory
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
		  FROM [dbo].[v_Inventories] inventory
		  --JOIN [dbo].[Funds] fund ON fund.SystemIdentifier = inventory.FundSystemIdentifier
		  --JOIN [dbo].[Archives] archive ON archive.Id = inventory.ArchiveId
		  --LEFT JOIN [N].[InventoryDescriptionLevel] descLevel ON descLevel.Code = inventory.DescriptionLevelCode
		  --LEFT JOIN [N].[InventoryStatus] s ON s.Code = inventory.StatusCode
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
	--OFFSET 0 ROWS FETCH NEXT 20 ROWS ONLY
END
GO

DROP PROCEDURE IF EXISTS [dbo].[sp_GetFund]
GO

CREATE PROCEDURE [dbo].[sp_GetFund] 
	@LinkedServer nvarchar(50),
	@Identifier int
AS
BEGIN
	SET NOCOUNT ON;

	declare @sql varchar(max) = '
		SELECT 
			   -1 as Id
			  ,CAST(1 as bit) as HasExternalSource
			  ,fund.[LGid] as ExternalIdentifier
			  ,(select Code from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveCode
			  ,(select Name from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveName
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= fund.StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid=fund.StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusText
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid=fund.FundArrayGid and n._retired = ''3000-01-01 00:00:00.000'') as NumberArray
			  ,fund.[IntNumber] as NumberNumeric
			  ,fund.[Number] as Number
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid=fund.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid=fund.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelText
			  ,fund.[Title] as Title
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid = fund.TypeGid and n._retired = ''3000-01-01 00:00:00.000'') as TypeText
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.FundGid = fund.Gid and n.Type = ''MethodOfAcquisition'' for XML PATH('''')), 1, 1, '''') as AcquisitionMethodText
			  ,STUFF(
				(select ''; '' + Value2 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.FundGid = fund.Gid and n.Type = ''IndustryIndex'' for XML PATH('''')), 1, 1, '''') as IndustryTypeText
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.FundGid = fund.Gid and n.Type = ''Language'' for XML PATH('''')), 1, 1, '''') as LanguageText
			  ,fund.[TextDate] as ApproxmateChronologicalScope
			  ,fund.[LinearMeters] as LinearMeters
			  ,fund.[InvetoryCount] as InventoryCount
			  ,fund.[AECount] as ArchivalEntityCount
			  ,fund.[ExtentOther] as OtherMetrics
			  ,fund.[FundFormerFunction] as FundCreatorActivityHistory
			  ,fund.[FundFormerHistory] as FundCreatorBiographicalHistory
			  ,fund.[ArchivalHistory] as History
			  ,fund.[ImmediateSourceOfAcquisition] as DocumentsProvider
			  ,fund.[AccessConditions] as DocumentsAccessDescription
			  ,fund.[AveilabilityInventoryCountAssigned] as EnrolledInventoryCount
			  ,fund.[AveilabilityInventoryCountDeducted] as DeductedInventoryCount
			  ,fund.[RelatedUnits] as RelatedFunds
			  ,fund.[Note] as Notes
			  ,fund.[DocumentProperties] as DocumentsDescription
			  ,fund.[FundFormerNameChange] as FundCreatorTitleHistory
			  ,fund.[StartDateYear] as StartDateYear
			  ,fund.[StartDateMonth] as StartDateMonth
			  ,fund.[StartDateDay] as StartDateDay
			  ,fund.[EndDateYear] as EndDateYear
			  ,fund.[EndDateMonth] as EndDateMonth
			  ,fund.[EndDateDay] as EndDateDay
			  ,fund.[IsNoDate] as HasNoChronologicalScope
		 FROM [Archiving].[dbo].Fund_Active as fund
		WHERE fund.LGId = ' + CAST(@Identifier as nvarchar(50)) 



	set @sql = REPLACE(@sql, '''', '''''');
	declare @linkedServerQuery varchar(max) = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''');';
	EXEC (@linkedServerQuery);	
END
GO


-- FilmPackageDocuments

if not exists (select null from sys.columns where name = 'ChecksumCheckResult' and object_id = object_id ('dbo.FilmPackageDocuments'))
begin 
	alter table dbo.FilmPackageDocuments add ChecksumCheckResult bit
end
go

if not exists (select null from sys.columns where name = 'FileFormatCheckResult' and object_id = object_id ('dbo.FilmPackageDocuments'))
begin 
	alter table dbo.FilmPackageDocuments add FileFormatCheckResult bit
end
go

if not exists (select null from sys.columns where name = 'AntivirusCheckResult' and object_id = object_id ('dbo.FilmPackageDocuments'))
begin 
	alter table dbo.FilmPackageDocuments add AntivirusCheckResult bit
end
go

if not exists (select null from sys.columns where name = 'AntivirusCheckInfo' and object_id = object_id ('dbo.FilmPackageDocuments'))
begin 
	alter table dbo.FilmPackageDocuments add AntivirusCheckInfo nvarchar(2000)
end
go

if not exists (select null from sys.columns where name = 'FileInfo' and object_id = object_id ('dbo.FilmPackageDocuments'))
begin 
	alter table dbo.FilmPackageDocuments add FileInfo nvarchar(2000)
end
go


if not exists (select null from sys.columns where name = 'ErrorMessage' and object_id = object_id ('dbo.FilmPackageDocuments'))
begin 
	alter table dbo.FilmPackageDocuments add ErrorMessage nvarchar(2000)
end
go



-- DigitalObjectDrafts

if not exists (select null from sys.columns where name = 'ChecksumCheckResult' and object_id = object_id ('dbo.DigitalObjectDrafts'))
begin 
	alter table dbo.DigitalObjectDrafts add ChecksumCheckResult bit
end
go

if not exists (select null from sys.columns where name = 'FileFormatCheckResult' and object_id = object_id ('dbo.DigitalObjectDrafts'))
begin 
	alter table dbo.DigitalObjectDrafts add FileFormatCheckResult bit
end
go

if not exists (select null from sys.columns where name = 'AntivirusCheckResult' and object_id = object_id ('dbo.DigitalObjectDrafts'))
begin 
	alter table dbo.DigitalObjectDrafts add AntivirusCheckResult bit
end
go

if not exists (select null from sys.columns where name = 'AntivirusCheckInfo' and object_id = object_id ('dbo.DigitalObjectDrafts'))
begin 
	alter table dbo.DigitalObjectDrafts add AntivirusCheckInfo nvarchar(2000)
end
go

if not exists (select null from sys.columns where name = 'FileInfo' and object_id = object_id ('dbo.DigitalObjectDrafts'))
begin 
	alter table dbo.DigitalObjectDrafts add FileInfo nvarchar(2000)
end
go


if not exists (select null from sys.columns where name = 'ErrorMessage' and object_id = object_id ('dbo.DigitalObjectDrafts'))
begin 
	alter table dbo.DigitalObjectDrafts add ErrorMessage nvarchar(2000)
end
go


-- DigitalObjects

if not exists (select null from sys.columns where name = 'ChecksumCheckResult' and object_id = object_id ('dbo.DigitalObjects'))
begin 
	alter table dbo.DigitalObjects add ChecksumCheckResult bit
end
go

if not exists (select null from sys.columns where name = 'FileFormatCheckResult' and object_id = object_id ('dbo.DigitalObjects'))
begin 
	alter table dbo.DigitalObjects add FileFormatCheckResult bit
end
go

if not exists (select null from sys.columns where name = 'AntivirusCheckResult' and object_id = object_id ('dbo.DigitalObjects'))
begin 
	alter table dbo.DigitalObjects add AntivirusCheckResult bit
end
go

if not exists (select null from sys.columns where name = 'AntivirusCheckInfo' and object_id = object_id ('dbo.DigitalObjects'))
begin 
	alter table dbo.DigitalObjects add AntivirusCheckInfo nvarchar(2000)
end
go

if not exists (select null from sys.columns where name = 'FileInfo' and object_id = object_id ('dbo.DigitalObjects'))
begin 
	alter table dbo.DigitalObjects add FileInfo nvarchar(2000)
end
go


if not exists (select null from sys.columns where name = 'ErrorMessage' and object_id = object_id ('dbo.DigitalObjects'))
begin 
	alter table dbo.DigitalObjects add ErrorMessage nvarchar(2000)
end
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetRegisterOfDigitalObjectsPublicReport] 
	@LinkedServer nvarchar(50),
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@RegisteredFrom nvarchar(100) = NULL,
	@RegisteredTo nvarchar(100) = null,
	@DocLGid nvarchar(max) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
	
AS
BEGIN
SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @remoteQuery VARCHAR(MAX) = 
		'SELECT
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = (SELECT LevelOfDescriptionGid from Fund_Modified f where f.LGid = doc.FundLGid)) as LevelOfDescription,
			''http://212.122.187.196:84/Process.aspx?type=Document&agid='' + cast(doc.ArchiveGid as nvarchar(255)) + ''&flgid='' + cast(doc.FundLGid as nvarchar(255)) + ''&ilgid='' + cast(doc.InventoryLGid as nvarchar(255)) + ''&aelgid='' + cast(doc.AELGid as nvarchar(255)) + ''&dlgid=''+ cast(doc.LGid as nvarchar(255)) as DocumentLink,
			a.Name as ArchiveName,
			(select CAST(Code as nvarchar(10)) from archive where _retired = ''3000-01-01'' and Gid = doc.ArchiveGid) ArchiveCode,
			doc.LGid as SystemId,
			(SELECT TOP 1 Number from Fund_Modified f where f.LGid = doc.FundLGid) as FundNumber,
			(SELECT Number from Inventory_Modified i where i.LGid = doc.InventoryLGid) as InventoryNumber,
			(SELECT Number from ArchiveEntity_Modified ae where ae.LGid = doc.AELGid) as ArchiveEntityNumber,
			(
				select ln1.ListFrom + '' - '' + ln1.ListTo + ''; ''
				from  ListNumber ln1	
				where ln1._retired=''3000-01-01'' and ln1.DocumentGid = doc.Gid 
				FOR XML path(''''), elements
			) as ListNumbers,
			doc.Title as DocumentTitle,
			doc.TextDate as ChronologicalScope,
			--(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = doc.StatusGid) as DocStatus, -- отпада по искане на ДАА
			convert(varchar, doc.DOCreationDate, 104) as DigitalObjectCreationDate,
			COUNT(img.Gid) as ImageCount,
			SUM(isnull(img.ByteLenght, 0)) as BytesCount,
			--case when isnull(DigitalObjectDeleted, 0) = 0 then ''Активен'' else ''Заличен'' end as DigitalObjectStatus, -- отпада по искане на ДАА
			--(
				--select convert(varchar, max(p.ModifiedOn), 104)  
				--from Document d
				--inner join Process p on p._retired = ''3000-01-01'' and p.Gid = d.ProcessGid and p.TypeGid = 2124 and p.StepGid = 75
				--where  d.LGid = doc.lgid
			--) as ModifiedOn,  -- отпада по искане на ДАА
			(SELECT TOP 1 IntNumber from Fund_Modified f where f.LGid = doc.FundLGid) as FundIntNumber,
			(SELECT IntNumber from Inventory_Modified i where i.LGid = doc.InventoryLGid) as InventoryIntNumber,
			(SELECT IntNumber from ArchiveEntity_Modified ae where ae.LGid = doc.AELGid) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder
		FROM
			Document_Active doc -- в ИСДА ползват Document_Active за тази справка
			INNER JOIN Archive a ON a.Gid = doc.ArchiveGid AND a._retired = ''3000-01-01''
			LEFT OUTER JOIN [Image] img ON doc.Gid = img.DocumentGid AND img._retired = ''3000-01-01''
		WHERE
			ISNULL(doc.HasDigitalObject, 0) = 1
			AND (''' + COALESCE(@DocLGid, 'null') + ''' = ''null'' OR doc.LGid = ''' + COALESCE(@DocLGid, 'null') + ''')
			AND (''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'' OR cast(doc.DOCreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2))
			AND (''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'' OR cast(doc.DOCreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2))
			AND ((''active'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1 and isnull(DigitalObjectDeleted, 0) = 0))
				OR (''deleted'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1 and isnull(DigitalObjectDeleted, 0) = 1))
				OR (''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
		group by 
		doc.LGid, 
		doc.ArchiveGid, 
		doc.CreationDate, 
		doc.Title, 
		doc.StatusGid, 
		doc.DigitalObjectDeleted, 
		doc.DigitalObjectDeleted, 
		doc.DOCreationDate, 
		doc.FundLGid, 
		doc.InventoryLGid, 
		doc.AELGid, 
		doc.Gid,
		doc.StartDateDay,
		doc.StartDateMonth,
		doc.StartDateYear,
		doc.EndDateDay,
		doc.EndDateMonth,
		doc.EndDateYear,
		doc.TextDate,
		a.Name,
		a.SortOrder';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			--(SELECT Text FROM [N].[DocumentDescriptionLevel] dl where dl.Code = DescriptionLevelCode) as LevelOfDescription,
			(SELECT Text FROM [N].[FundDescriptionLevel] fdl where fdl.Code = (SELECT DescriptionLevelCode FROM Funds f where f.SystemIdentifier = do.FundSystemIdentifier)) as LevelOfDescription,
			'''' as DocumentLink,
			a.Name as ArchiveName,
			a.Code as ArchiveCode,
			do.Id as SystemId,
			(SELECT Number FROM Funds f where f.SystemIdentifier = do.FundSystemIdentifier) as FundNumber,
			(SELECT Number FROM Inventories i where i.SystemIdentifier = do.InventorySystemIdentifier) as InventoryNumber,
			(SELECT Number FROM ArchivalEntities ae where ae.SystemIdentifier = do.ArchivalEntitySystemIdentifier) as ArchiveEntityNumber,
			(CAST(d.StartSheetNumber AS nvarchar(50)) + '' - '' + CAST(d.EndSheetNumber AS nvarchar(50))) as ListNumbers, -- различава се от ИСДА; има ли нужда от таква стойност в СЕА?
			d.Title as DocumentTitle,
			d.ApproxmateChronologicalScope as ChronologicalScope,
			-- (SELECT Text FROM [N].[Status] s where s.Code = StatusCode) as DocStatus, -- отпада по искане на ДАА
			convert(varchar, do.CreatedOn, 104) as DigitalObjectCreationDate,
			NULL as ImageCount, -- нямаме снимки при нас
			NULL as BytesCount, -- липсва колна в таблица DigitalObjects, трябва да се добави
			-- NULL as DigitalObjectStatus, -- отпада по искане на ДАА
			-- convert(nvarchar,UpdatedOn, 104) as ModifiedOn, -- отпада по искане на ДАА
			(SELECT NumberNumeric FROM Funds f where f.SystemIdentifier = do.FundSystemIdentifier) as FundIntNumber,
			(SELECT NumberNumeric FROM Inventories i where i.SystemIdentifier = do.InventorySystemIdentifier) as InventoryIntNumber,
			(SELECT NumberNumeric FROM ArchivalEntities ae where ae.SystemIdentifier = do.ArchivalEntitySystemIdentifier) as ArchivalEntityIntNumber,
			a.SortOrder
		FROM DigitalObjects do
		INNER JOIN Archives a ON a.Id = do.ArchiveId AND a.Deleted = 0
		INNER JOIN Documents d ON d.SystemIdentifier = do.DocumentSystemIdentifier AND do.Deleted = 0
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
				AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
				AND do.TypeCode = 1 -- master
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				--AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					--OR ((select convert(varchar(4), Code, 104) from N.DocumentStatus s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))';

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteFundsTable TABLE (
			LevelOfDescription nvarchar(MAX) NULL,
			DocumentLink nvarchar(MAX) NULL,
			ArchiveName nvarchar(256) NOT NULL,
			ArchiveCode int NOT NULL,
			SystemId int NOT NULL,
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchiveEntityNumber nvarchar(256) NULL,
			ListNumbers nvarchar(MAX) NULL,
			DocumentTitle nvarchar(MAX) NULL,
			ChronologicalScope nvarchar(256) NULL, 
			-- DocStatus nvarchar(MAX) NULL, -- отпада по искане на ДАА
			DigitalObjectCreationDate nvarchar(50) NULL,
			ImageCount bigint NULL,
			BytesCount bigint NULL,
			-- DigitalObjectStatus nvarchar(50) NULL, -- отпада по искане на ДАА
			-- ModifiedOn varchar(50) NULL, -- отпада по искане на ДАА
			FundIntNumber int null,
			InventoryIntNumber int null,
			ArchivalEntityIntNumber int null,
			ArchiveSortOrder int null
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteFundsTable
		UNION
		' +
		@localQuery + '
		order by ArchiveSortOrder, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchivalEntityIntNumber, ArchiveEntityNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	EXEC (@sql);
END
GO

----------------------------------------------------------
--	THE SCRIPT IS CLOSED - USE THE NEW ONE!
----------------------------------------------------------



commit