SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.32'
where Code = 'DB_VERSION'
go

-- Process type levels
update ProcessTypeLevels set Inactive = 1 where ProcessTypeId = 12 and EntityType <> 'inventory'
go
--END Process type levels

--Digital objects
IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'IsDigitized'
          AND Object_ID = Object_ID(N'dbo.DigitalObjectDrafts'))
BEGIN
	ALTER TABLE [dbo].[DigitalObjectDrafts]
	ADD [IsDigitized] bit NULL
END
GO

UPDATE DigitalObjectDrafts SET IsDigitized = 0 WHERE IsDigitized IS NULL
GO

ALTER TABLE [dbo].[DigitalObjectDrafts]
ALTER COLUMN [IsDigitized] bit NOT NULL
GO

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'IsDigitized'
          AND Object_ID = Object_ID(N'dbo.DigitalObjects'))
BEGIN
	ALTER TABLE [dbo].[DigitalObjects]
	ADD [IsDigitized] bit NULL
END
GO

UPDATE DigitalObjects SET IsDigitized = 0 WHERE IsDigitized IS NULL
GO

ALTER TABLE [dbo].[DigitalObjects]
ALTER COLUMN [IsDigitized] bit NOT NULL
GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER view [dbo].[v_DigitalObjects]
AS

SELECT do.Id
      ,do.SystemIdentifier
	  ,CAST(0 as bit) as IsDraft
	  ,do.IsSuspended
      ,do.ParentId
      ,do.ParentSystemIdentifier
	  ,do.ArchiveId
      ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,NULL as FundDraftId
      ,do.FundSystemIdentifier
      ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,NULL as InventoryDraftId
      ,do.InventorySystemIdentifier
	  ,i.Number as InventoryNumber
	  ,i.HasExternalSource as InventoryHasExternalSource
	  ,i.ExternalIdentifier as InventoryExternalIdentifier
	  ,NULL as ArchivalEntityDraftId
      ,do.ArchivalEntitySystemIdentifier
	  ,ae.Number as ArchivalEntityNumber
	  ,ae.HasExternalSource as ArchivalEntityHasExternalSource
	  ,ae.ExternalIdentifier as ArchivalEntityExternalIdentifier
      ,NULL as DocumentDraftId
	  ,do.DocumentSystemIdentifier
	  ,d.Number as DocumentNumber
	  ,d.HasExternalSource as DocumentHasExternalSource
	  ,d.ExternalIdentifier as DocumentExternalIdentifier
      ,do.CreatedOn
      ,do.CreatedBy
	  ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,do.UpdatedOn
      ,do.UpdatedBy
	  ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,do.Deleted
      ,do.DeletedOn
      ,do.DeletedBy
	  ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,do.ExternalIdentifier
      ,do.HasExternalSource
      ,do.ExternalSourceUpdatedOn
	  ,do.TypeCode
      ,do.Name
      ,do.SourceName
      ,do.UncPath
      ,do.FileType
	  ,do.FileSize
      ,do.StatusCode
      ,do.ContentType
	  ,do.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
	  ,do.WatermarkName
	  ,do.WatermarkUncPath
	  ,do.HashCode
	  ,do.Duration
	  ,do.IsImported
	  ,do.IsDigitized
  FROM dbo.DigitalObjects do
  JOIN dbo.Archives a ON do.ArchiveId = a.Id
  JOIN dbo.Funds f ON do.FundSystemIdentifier = f.SystemIdentifier
  JOIN dbo.Inventories i ON do.InventorySystemIdentifier = i.SystemIdentifier
  JOIN dbo.ArchivalEntities ae ON do.ArchivalEntitySystemIdentifier = ae.SystemIdentifier 
  JOIN dbo.Documents d ON do.DocumentSystemIdentifier = d.SystemIdentifier
  LEFT JOIN dbo.DigitalObjectDrafts dod on do.SystemIdentifier = dod.SystemIdentifier and dod.IsCurrent = 1
  LEFT JOIN N.AvailabilityStatus ast ON do.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON do.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON do.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON do.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON do.CreatedBy = du.Id
 WHERE dod.Id IS NULL

 UNION

 
 SELECT dod.Id
      ,dod.SystemIdentifier
      ,CAST(1 as bit) as IsDraft
	  ,CAST(0 as bit) as IsSuspended
      ,dod.ParentId
      ,dod.ParentSystemIdentifier
	  ,dod.ArchiveId
	  ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
      ,dod.FundDraftId
      ,dod.FundSystemIdentifier
	  ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,dod.InventoryDraftId
      ,dod.InventorySystemIdentifier
	  ,i.Number as InventoryNumber
	  ,i.HasExternalSource as InventoryHasExternalSource
	  ,i.ExternalIdentifier as InventoryExternalIdentifier
      ,dod.ArchivalEntityDraftId
      ,dod.ArchivalEntitySystemIdentifier
	  ,ae.Number as ArchivalEntityNumber
	  ,ae.HasExternalSource as ArchivalEntityHasExternalSource
	  ,ae.ExternalIdentifier as ArchivalEntityExternalIdentifier
      ,dod.DocumentDraftId
      ,dod.DocumentSystemIdentifier
	  ,d.Number as DocumentNumber
	  ,d.HasExternalSource as DocumentHasExternalSource
	  ,d.ExternalIdentifier as DocumentExternalIdentifier
      ,dod.CreatedOn
      ,dod.CreatedBy
	  ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,dod.UpdatedOn
      ,dod.UpdatedBy
	  ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,dod.Deleted
      ,dod.DeletedOn
      ,dod.DeletedBy
	  ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,dod.ExternalIdentifier
      ,dod.HasExternalSource
      ,dod.ExternalSourceUpdatedOn
	  ,dod.TypeCode
      ,dod.Name
      ,dod.SourceName
      ,dod.UncPath
      ,dod.FileType
	  ,dod.FileSize
      ,dod.StatusCode
      ,dod.ContentType
	  ,dod.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
	  ,dod.WatermarkName
	  ,dod.WatermarkUncPath
	  ,dod.HashCode
	  ,dod.Duration
	  ,dod.IsImported
	  ,dod.IsDigitized
  FROM dbo.DigitalObjectDrafts dod
  JOIN dbo.Archives a ON dod.ArchiveId = a.Id
  LEFT JOIN dbo.Funds f ON dod.FundSystemIdentifier = f.SystemIdentifier
  LEFT JOIN dbo.FundDrafts fd ON dod.FundSystemIdentifier = fd.SystemIdentifier AND dod.FundDraftId = fd.Id 
  LEFT JOIN dbo.Inventories i ON dod.InventorySystemIdentifier = i.SystemIdentifier 
  LEFT JOIN dbo.InventoryDrafts id ON dod.InventorySystemIdentifier = id.SystemIdentifier AND dod.InventoryDraftId = id.Id
  LEFT JOIN dbo.ArchivalEntities ae ON dod.ArchivalEntitySystemIdentifier = ae.SystemIdentifier
  LEFT JOIN dbo.ArchivalEntityDrafts aed ON dod.ArchivalEntitySystemIdentifier = aed.SystemIdentifier AND dod.ArchivalEntityDraftId = aed.Id
  LEFT JOIN dbo.Documents d ON dod.DocumentSystemIdentifier = d.SystemIdentifier
  LEFT JOIN dbo.DocumentDrafts dd ON dod.DocumentSystemIdentifier = dd.SystemIdentifier AND dod.DocumentDraftId = dd.Id
  LEFT JOIN N.AvailabilityStatus ast ON dod.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON dod.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON dod.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON dod.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON dod.CreatedBy = du.Id
 WHERE dod.IsCurrent = 1
GO


CREATE OR ALTER view [dbo].[v_PublicDigitalObjects]
AS

SELECT do.Id
      ,do.SystemIdentifier
	  ,CAST(0 as bit) as IsDraft
	  ,do.IsSuspended
      ,do.ParentId
      ,do.ParentSystemIdentifier
	  ,do.ArchiveId
      ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,NULL as FundDraftId
      ,do.FundSystemIdentifier
      ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,NULL as InventoryDraftId
      ,do.InventorySystemIdentifier
	  ,i.Number as InventoryNumber
	  ,i.HasExternalSource as InventoryHasExternalSource
	  ,i.ExternalIdentifier as InventoryExternalIdentifier
	  ,NULL as ArchivalEntityDraftId
      ,do.ArchivalEntitySystemIdentifier
	  ,ae.Number as ArchivalEntityNumber
	  ,ae.HasExternalSource as ArchivalEntityHasExternalSource
	  ,ae.ExternalIdentifier as ArchivalEntityExternalIdentifier
      ,NULL as DocumentDraftId
	  ,do.DocumentSystemIdentifier
	  ,d.Number as DocumentNumber
	  ,d.HasExternalSource as DocumentHasExternalSource
	  ,d.ExternalIdentifier as DocumentExternalIdentifier
      ,do.CreatedOn
      ,do.CreatedBy
	  ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,do.UpdatedOn
      ,do.UpdatedBy
	  ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,do.Deleted
      ,do.DeletedOn
      ,do.DeletedBy
	  ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,do.ExternalIdentifier
      ,do.HasExternalSource
      ,do.ExternalSourceUpdatedOn
	  ,do.TypeCode
      ,do.Name
      ,do.SourceName
      ,do.UncPath
      ,do.FileType
	  ,do.FileSize
      ,do.StatusCode
      ,do.ContentType
	  ,do.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
	  ,do.WatermarkName
	  ,do.WatermarkUncPath
	  ,do.HashCode
	  ,do.Duration
	  ,do.IsImported
	  ,do.IsDigitized
  FROM dbo.DigitalObjects do
  JOIN dbo.Archives a ON do.ArchiveId = a.Id
  JOIN dbo.Funds f ON do.FundSystemIdentifier = f.SystemIdentifier
  JOIN dbo.Inventories i ON do.InventorySystemIdentifier = i.SystemIdentifier
  JOIN dbo.ArchivalEntities ae ON do.ArchivalEntitySystemIdentifier = ae.SystemIdentifier 
  JOIN dbo.Documents d ON do.DocumentSystemIdentifier = d.SystemIdentifier
  LEFT JOIN N.AvailabilityStatus ast ON do.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON do.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON do.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON do.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON do.CreatedBy = du.Id
 WHERE do.IsSuspended = 0
   AND do.TypeCode <> 1 --Само демо и производни образи
GO


CREATE OR ALTER PROCEDURE sp_GetDocumentDigitalObjects
	@LinkedServer nvarchar(255) = '', 
	@DocumentIdentifier uniqueidentifier = NULL,
	@DocumentHasExternalSource bit,
	@DocumentExternalIdentifier int = NULL,
	@IncludeDeleted bit = false,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteDigitalObjectsQuery nvarchar(max) = '';
	DECLARE @RemoteDigitalObjects TABLE (
		Id int 
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,ParentId int
		,ParentSystemIdentifier uniqueidentifier
		,ArchiveCode int
		,ArchiveName nvarchar(255)
		,DocumentHasExternalSource bit
		,DocumentExternalIdentifier int
		,DocumentNumber nvarchar(50)
		,ArchivalEntityHasExternalSource bit
		,ArchivalEntityExternalIdentifier int
		,ArchivalEntityNumber nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,TypeCode int
		,Name nvarchar(max)
		,SourceName nvarchar(max)
		,FileType nvarchar(50)
		,UncPath nvarchar(max)
		,IsDigitized bit
	);

	DECLARE @LocalDigitalObjectsQuery nvarchar(max) = '';
	DECLARE @LocalDigitalObjects TABLE (
		Id int 
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,ParentId int
		,ParentSystemIdentifier uniqueidentifier
		,ArchiveCode int
		,ArchiveName nvarchar(255)
		,DocumentHasExternalSource bit
		,DocumentExternalIdentifier int
		,DocumentNumber nvarchar(50)
		,ArchivalEntityHasExternalSource bit
		,ArchivalEntityExternalIdentifier int
		,ArchivalEntityNumber nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,TypeCode int
		,Name nvarchar(max)
		,SourceName nvarchar(max)
		,FileType nvarchar(50)
		,UncPath nvarchar(max)
		,IsDigitized bit
	);


	IF @DocumentHasExternalSource = 1
	BEGIN 
		SET @RemoteDigitalObjectsQuery = CAST('' as nvarchar(max)) +
		'select -1 as Id
				,CAST(NULL as uniqueidentifier) as SystemIdentifier
				,CAST(1 as bit) as HasExternalSource
				,img.Gid as ExternalIdentifier
				,CAST(NULL as int) ParentId
				,CAST(NULL as uniqueidentifier) ParentSystemIdentifier
				,(select Code from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
				,(select Name from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
				,CAST(1 as bit) as DocumentHasExternalSource
				,doc.LGid as DocumentExternalIdentifier
				,doc.Number as DocumentNumber
				,CAST(1 as bit) as ArchivalEntityHasExternalSource
				,doc.AELGid as ArchivalEntityExternalIdentifier
				,(select Number from [Archiving].[dbo].ArchiveEntity_Active ae where ae.LGid = doc.AELGid and ae._retired = ''''3000-01-01 00:00:00.000'''') as ArchivalEntityNumber
				,CAST(1 as bit) as InventoryHasExternalSource
				,doc.InventoryLGid as InventoryExternalIdentifier
				,(select Number from [Archiving].[dbo].Inventory_Active inv where inv.LGid = doc.InventoryLGid and inv._retired = ''''3000-01-01 00:00:00.000'''') as InventoryNumber
				,CAST(1 as bit) as FundHasExternalSource
				,doc.FundLGid as FundExternalIdentifier
				,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = doc.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
				,CAST(2 as int) as TypeCode' + '
				,CONCAT((select Code from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000''''), ''''_'''',doc.LGid, ''''_'''', REVERSE(SUBSTRiNG(REVERSE(LEFT(img.FilePath, LEN(img.FilePath) - LEN(REVERSE(SUBSTRING(REVERSE(img.FilePath),1,CHARINDEX(''''_'''',REVERSE(img.FilePath))))))),0, CHARINDEX(''''_'''',REVERSE(LEFT(img.FilePath, LEN(img.FilePath) - LEN(REVERSE(SUBSTRING(REVERSE(img.FilePath),1,CHARINDEX(''''_'''',REVERSE(img.FilePath)))))))))), ''''_d'''', ''''.jpg'''') as Name
				,CONCAT((select Code from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000''''), ''''_'''',doc.LGid, ''''_'''', REVERSE(SUBSTRiNG(REVERSE(LEFT(img.FilePath, LEN(img.FilePath) - LEN(REVERSE(SUBSTRING(REVERSE(img.FilePath),1,CHARINDEX(''''_'''',REVERSE(img.FilePath))))))),0, CHARINDEX(''''_'''',REVERSE(LEFT(img.FilePath, LEN(img.FilePath) - LEN(REVERSE(SUBSTRING(REVERSE(img.FilePath),1,CHARINDEX(''''_'''',REVERSE(img.FilePath)))))))))), ''''_d'''', ''''.jpg'''') as SourceName
				,''''jpg'''' as FileType
				,img.FilePath as UncPath
				,CAST(1 as bit) as IsDigitized
		   from dbo.Image img 
		   join dbo.Document_Active doc on img.DocumentGid = doc.Gid and doc._retired = ''''3000-01-01 00:00:00.000''''
		  where doc.LGid = ' + CAST(@DocumentExternalIdentifier as nvarchar(50)) + ' and img._retired = ''''3000-01-01 00:00:00.000''''' + '

		  union ' + '
		
		 select -1 as Id
				,CAST(NULL as uniqueidentifier) as SystemIdentifier
				,CAST(1 as bit) as HasExternalSource
				,img.Gid as ExternalIdentifier
				,CAST(NULL as int) ParentId
				,CAST(NULL as uniqueidentifier) ParentSystemIdentifier
				,(select Code from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
				,(select Name from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
				,CAST(1 as bit) as DocumentHasExternalSource
				,doc.LGid as DocumentExternalIdentifier
				,doc.Number as DocumentNumber
				,CAST(1 as bit) as ArchivalEntityHasExternalSource
				,doc.AELGid as ArchivalEntityExternalIdentifier
				,(select Number from [Archiving].[dbo].ArchiveEntity_Active ae where ae.LGid = doc.AELGid and ae._retired = ''''3000-01-01 00:00:00.000'''') as ArchivalEntityNumber
				,CAST(1 as bit) as InventoryHasExternalSource
				,doc.InventoryLGid as InventoryExternalIdentifier
				,(select Number from [Archiving].[dbo].Inventory_Active inv where inv.LGid = doc.InventoryLGid and inv._retired = ''''3000-01-01 00:00:00.000'''') as InventoryNumber
				,CAST(1 as bit) as FundHasExternalSource
				,doc.FundLGid as FundExternalIdentifier
				,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = doc.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
				,CAST(1 as int) as TypeCode
				,REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''\'''',REVERSE(img.FilePath)))) as Name
				,REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''\'''',REVERSE(img.FilePath)))) as SourceName
				,REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''.'''',REVERSE(img.FilePath)))) as FileType
				,img.FilePath as UncPath
				,CAST(1 as bit) as IsDigitized
		   from dbo.Image img 
		   join dbo.Document_Active doc on img.DocumentGid = doc.Gid and doc._retired = ''''3000-01-01 00:00:00.000''''
		  where doc.LGid = ' + CAST(@DocumentExternalIdentifier as nvarchar(50)) + ' and img._retired = ''''3000-01-01 00:00:00.000''''';

		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteDigitalObjectsQuery + ''' )';
		
		INSERT INTO @RemoteDigitalObjects 
		EXEC(@RemoteQuery)

	END

	IF @DocumentIdentifier IS NOT NULL
	BEGIN
		PRINT(@DocumentIdentifier);

		INSERT INTO @LocalDigitalObjects
		SELECT	dig.Id as Id
				,dig.SystemIdentifier as SystemIdentifier
				,ISNULL(dig.HasExternalSource, CAST(0 as bit)) as HasExternalSource
				,dig.ExternalIdentifier as ExternalIdentifier
				,dig.ParentId as ParentId
				,dig.ParentSystemIdentifier as ParentSystemIdentifier
				,dig.ArchiveCode as ArchiveCode
				,dig.ArchiveName as ArchiveName
				,dig.DocumentHasExternalSource as DocumentHasExternalSource
				,dig.DocumentExternalIdentifier as DocumentExternalIdentifier
				,dig.DocumentNumber as DocumentNumber
				,dig.ArchivalEntityHasExternalSource as ArchivalEntityHasExternalSource
				,dig.ArchivalEntityExternalIdentifier as ArchivalEntityExternalIdentifier
				,dig.ArchivalEntityNumber as ArchivalEntityNumber
				,dig.InventoryHasExternalSource as InventoryHasExternalSource
				,dig.InventoryExternalIdentifier as InventoryExternalIdentifier
				,dig.InventoryNumber as InventoryNumber
				,dig.FundHasExternalSource as FundHasExternalSource
				,dig.FundExternalIdentifier as FundExternalIdentifier
				,dig.FundNumber FundNumber
				,dig.TypeCode as TypeCode
				,dig.Name as Name
				,dig.SourceName as SourceName
				,dig.FileType
				,dig.UncPath as UncPath
				,dig.IsDigitized as IsDigitized
		  FROM dbo.v_DigitalObjects dig
		 WHERE dig.DocumentSystemIdentifier = @DocumentIdentifier
		   AND (dig.HasExternalSource IS NULL OR dig.HasExternalSource = 0)
		   AND (@IncludeDeleted = 1 OR dig.Deleted = 0)

	END
	IF (@Paging = 1)
	BEGIN
		SELECT *
		  FROM
		  (
			 SELECT *
			   FROM @LocalDigitalObjects
			  UNION
			 SELECT *
			   FROM @RemoteDigitalObjects
		   ) Documents
		ORDER BY SourceName
		OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
	END
	ELSE
	BEGIN
		SELECT *
		  FROM
		  (
			 SELECT *
			   FROM @LocalDigitalObjects
			  UNION
			 SELECT *
			   FROM @RemoteDigitalObjects
		   ) Documents
		ORDER BY SourceName
	END
END
GO


CREATE OR ALTER PROCEDURE [dbo].[sp_GetPublicDocumentDigitalObjects]
	@LinkedServer nvarchar(255) = '', 
	@DocumentIdentifier uniqueidentifier = NULL,
	@DocumentHasExternalSource bit,
	@DocumentExternalIdentifier int = NULL,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteDigitalObjectsQuery nvarchar(max) = '';
	DECLARE @RemoteDigitalObjects TABLE (
		Id int 
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,ParentId int
		,ParentSystemIdentifier uniqueidentifier
		,ArchiveCode int
		,ArchiveName nvarchar(255)
		,DocumentHasExternalSource bit
		,DocumentExternalIdentifier int
		,DocumentNumber nvarchar(50)
		,ArchivalEntityHasExternalSource bit
		,ArchivalEntityExternalIdentifier int
		,ArchivalEntityNumber nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,TypeCode int
		,Name nvarchar(max)
		,SourceName nvarchar(max)
		,FileType nvarchar(50)
		,UncPath nvarchar(max)
		,IsDigitized bit
	);

	DECLARE @LocalDigitalObjectsQuery nvarchar(max) = '';
	DECLARE @LocalDigitalObjects TABLE (
		Id int 
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,ParentId int
		,ParentSystemIdentifier uniqueidentifier
		,ArchiveCode int
		,ArchiveName nvarchar(255)
		,DocumentHasExternalSource bit
		,DocumentExternalIdentifier int
		,DocumentNumber nvarchar(50)
		,ArchivalEntityHasExternalSource bit
		,ArchivalEntityExternalIdentifier int
		,ArchivalEntityNumber nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,TypeCode int
		,Name nvarchar(max)
		,SourceName nvarchar(max)
		,FileType nvarchar(50)
		,UncPath nvarchar(max)
		,IsDigitized bit
	);


	IF @DocumentHasExternalSource = 1
	BEGIN 
		SET @RemoteDigitalObjectsQuery = CAST('' as nvarchar(max)) + 
		'select -1 as Id
				,CAST(NULL as uniqueidentifier) as SystemIdentifier
				,CAST(1 as bit) as HasExternalSource
				,img.Gid as ExternalIdentifier
				,CAST(NULL as int) ParentId
				,CAST(NULL as uniqueidentifier) ParentSystemIdentifier
				,(select Code from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
				,(select Name from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
				,CAST(1 as bit) as DocumentHasExternalSource
				,doc.LGid as DocumentExternalIdentifier
				,doc.Number as DocumentNumber
				,CAST(1 as bit) as ArchivalEntityHasExternalSource
				,doc.AELGid as ArchivalEntityExternalIdentifier
				,(select Number from [Archiving].[dbo].ArchiveEntity_Active ae where ae.LGid = doc.AELGid and ae._retired = ''''3000-01-01 00:00:00.000'''') as ArchivalEntityNumber
				,CAST(1 as bit) as InventoryHasExternalSource
				,doc.InventoryLGid as InventoryExternalIdentifier
				,(select Number from [Archiving].[dbo].Inventory_Active inv where inv.LGid = doc.InventoryLGid and inv._retired = ''''3000-01-01 00:00:00.000'''') as InventoryNumber
				,CAST(1 as bit) as FundHasExternalSource
				,doc.FundLGid as FundExternalIdentifier
				,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = doc.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
				,CAST(2 as int) as TypeCode
				,CONCAT((select Code from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000''''), ''''_'''',doc.LGid, ''''_'''', REVERSE(SUBSTRiNG(REVERSE(LEFT(img.FilePath, LEN(img.FilePath) - LEN(REVERSE(SUBSTRING(REVERSE(img.FilePath),1,CHARINDEX(''''_'''',REVERSE(img.FilePath))))))),0, CHARINDEX(''''_'''',REVERSE(LEFT(img.FilePath, LEN(img.FilePath) - LEN(REVERSE(SUBSTRING(REVERSE(img.FilePath),1,CHARINDEX(''''_'''',REVERSE(img.FilePath)))))))))), ''''_d'''', ''''.jpg'''') as Name
				,CONCAT((select Code from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000''''), ''''_'''',doc.LGid, ''''_'''', REVERSE(SUBSTRiNG(REVERSE(LEFT(img.FilePath, LEN(img.FilePath) - LEN(REVERSE(SUBSTRING(REVERSE(img.FilePath),1,CHARINDEX(''''_'''',REVERSE(img.FilePath))))))),0, CHARINDEX(''''_'''',REVERSE(LEFT(img.FilePath, LEN(img.FilePath) - LEN(REVERSE(SUBSTRING(REVERSE(img.FilePath),1,CHARINDEX(''''_'''',REVERSE(img.FilePath)))))))))), ''''_d'''', ''''.jpg'''') as SourceName
				,''''jpg'''' as FileType
				,img.FilePath as UncPath
				,CAST(1 as bit) as IsDigitized
		   from dbo.Image img 
		   join dbo.Document_Active doc on img.DocumentGid = doc.Gid and doc._retired = ''''3000-01-01 00:00:00.000''''
		  where doc.LGid = ' + CAST(@DocumentExternalIdentifier as nvarchar(50)) + ' and img._retired = ''''3000-01-01 00:00:00.000''''';


		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteDigitalObjectsQuery + ''' )';
		
		INSERT INTO @RemoteDigitalObjects 
		EXEC(@RemoteQuery)

	END

	IF @DocumentIdentifier IS NOT NULL
	BEGIN

		INSERT INTO @LocalDigitalObjects
		SELECT	dig.Id as Id
				,dig.SystemIdentifier as SystemIdentifier
				,dig.HasExternalSource as HasExternalSource
				,dig.ExternalIdentifier as ExternalIdentifier
				,dig.ParentId as ParentId
				,dig.ParentSystemIdentifier as ParentSystemIdentifier
				,dig.ArchiveCode as ArchiveCode
				,dig.ArchiveName as ArchiveName
				,dig.DocumentHasExternalSource as DocumentHasExternalSource
				,dig.DocumentExternalIdentifier as DocumentExternalIdentifier
				,dig.DocumentNumber as DocumentNumber
				,dig.ArchivalEntityHasExternalSource as ArchivalEntityHasExternalSource
				,dig.ArchivalEntityExternalIdentifier as ArchivalEntityExternalIdentifier
				,dig.ArchivalEntityNumber as ArchivalEntityNumber
				,dig.InventoryHasExternalSource as InventoryHasExternalSource
				,dig.InventoryExternalIdentifier as InventoryExternalIdentifier
				,dig.InventoryNumber as InventoryNumber
				,dig.FundHasExternalSource as FundHasExternalSource
				,dig.FundExternalIdentifier as FundExternalIdentifier
				,dig.FundNumber FundNumber
				,dig.TypeCode as TypeCode
				,dig.Name as Name
				,dig.SourceName as SourceName
				,dig.FileType
				,dig.UncPath as UncPath
				,dig.IsDigitized as IsDigitized
		  FROM dbo.v_PublicDigitalObjects dig
		 WHERE dig.DocumentSystemIdentifier = @DocumentIdentifier
		   AND dig.Deleted = 0
		   AND (dig.HasExternalSource IS NULL OR dig.HasExternalSource = 0)

	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalDigitalObjects
		  UNION
		 SELECT *
		   FROM @RemoteDigitalObjects
	   ) Documents
	ORDER BY SourceName
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY

END
GO

--END Digital objects


  IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'SourceName'
          AND Object_ID = Object_ID(N'dbo.SessionMinutesOfMeeting'))
BEGIN
    ALTER TABLE dbo.SessionMinutesOfMeeting
    ADD SourceName NVARCHAR(max) NULL
END
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[SearchArchivalEntitiesForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodesInternal nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	--@KeywordsUIAnnotated nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	DECLARE @remoteQuery nvarchar(max), @kwds int, @kwdsAnnotated int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1;
	--set @kwdsAnnotated=0;
	--if @KeywordsUIAnnotated is not null and len(@KeywordsUIAnnotated) >=2 set @kwdsAnnotated=1;
	if @Title is not null and len(@Title) >= 2 set @ttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rankRemote = ',kwds.[Rank] as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankRemote = ',fttl.[Rank] as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rankRemote = ',(isnull(kwds.[Rank], 0) + isnull(fttl.[Rank], 0)) as Rank';

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilterRemote = ' and fttl.[Rank] > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilterRemote = ' and isnull(kwds.[Rank], 0) > 1 and isnull(fttl.[Rank], 0) > 1';

	SET @remoteQuery = '';
	SET @remoteQuery = 'with fresults as (';
	set @remoteQuery = @remoteQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''archival_entity'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = ae.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		inventory.Number as InventoryNumber,
		ae.Number as ArchivalEntityNumber,
		NULL as KMFNumber,
		NULL as FilmCardNumber,
		ae.Title,
		NULL as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = ae.StatusGid) as StatusText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.LevelOfDescriptionGid) as FundDescriptionLevelText,	
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = inventory.LevelOfDescriptionGid) as InventoryDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		ae.LGid AS ExternalIdentifier,
		fund.TextDate AS FundApproximateChronologicalScope,
		inventory.TextDate AS InventoryApproximateChronologicalScope,
		ae.TextDate AS ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		NULL AS FundGid,
		fund.IntNumber as FundIntNumber,
		inventory.IntNumber AS InventoryIntNumber,
		ae.IntNumber AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		ae.Gid,
		ae.LGid'
		+ @rankRemote
		+ ',3 AS EntityTypeOrder';

	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		from ArchiveEntity_Active as ae
	';
	else set @remoteQuery = @remoteQuery + '
		from ArchiveEntity_Modified as ae
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Inventory_Active inventory on inventory.LGid=ae.InventoryLGid
	';
	else set @remoteQuery = @remoteQuery + '
		inner join Inventory_Modified inventory on inventory.LGid=ae.InventoryLGid
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Fund_Active fund on fund.LGid=ae.FundLGid
	';
	else set @remoteQuery = @remoteQuery + '
		inner join Fund_Modified fund on fund.LGid=ae.FundLGid
	';
	if @kwds = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(ArchiveEntity,*, '''+ @KeyWords + ''') kwds on ae._id = kwds.[key]
	';
	if @ttl = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(ArchiveEntity,Title, '''+ @Title + ''') fttl on ae._id = fttl.[key]
	';
	--if @kwdsAnnotated =1 set @remoteQuery = @remoteQuery + '
		--inner join ObjectNomenclature on1 on on1.ArchiveEntityGid = ae.Gid and on1._retired = ''3000-01-01''
		--inner join Nomenclature n1 on on1.NomenclatureGid = n1.Gid and n1.[Type] = ''Annotated'' and n1._retired = ''3000-01-01''
		--inner join freetexttable(Nomenclature,*,@KeywordsUIAnnotated) fts1 on n1._id = fts1.[key] ';
	if @ArchiveGids is not null and @ArchiveGids <> '-999' set @remoteQuery = @remoteQuery + '
		where ae.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else set @remoteQuery = @remoteQuery + '
		where 1 = 1
	';
	set @remoteQuery = @remoteQuery + '
		and (fund.LevelOfDescriptionGid <> 2185 or ae.LevelOfDescriptionGid <> 2371)
	';
	--if @ArchivalEntityNumber is not null set @remoteQuery = @remoteQuery + '
		--and (ae.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired = ''3000-01-01'' and [Type] = ''LevelOfDescription'' AND Code = 11)) --Арх.ед. - копия от чужди архиви
	--';
	if @FundNumber is not null set @remoteQuery = @remoteQuery + '
		and (fund.Number = ''' + @FundNumber + ''')
	';
	if @InventoryNumber is not null set @remoteQuery = @remoteQuery + '
		and (inventory.Number = ''' + @InventoryNumber + ''')
	';
	if @ArchivalEntityNumber is not null set @remoteQuery = @remoteQuery + '
		and (ae.Number = ''' + @ArchivalEntityNumber + ''')
	';
	if @ArchivalEntityNumber is not null
		and not '2174' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2373' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteQuery = @remoteQuery + '
			and (ae.LevelOfDescriptionGid in (2174,2373))
	' 
	else if @ArchivalEntityNumber is null
		and not '2174' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2373' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '-999' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteQuery = @remoteQuery + '
			and 1=2
	' 
	else if @LevelOfDescriptionGids <> '-999'
		and ('2174' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')) or '2373' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')))
		set @remoteQuery = @remoteQuery + '
			and (ae.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )
	';
	if @ToDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @ToDate +''' >= ae.CreationDate)
	';
	if @FromDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @FromDate + ''' <= ae.CreationDate)
	';
	--if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
	--	and ((select FundArrayGid from ' + @fundsView + ' where LGid = inventory.FundLGid) in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	--';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
		and (fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +') 
	'
	if @SearchDigitalObject = 1 and  @SearchDrafts = 1  set @remoteQuery = @remoteQuery + '
		AND (exists (select 1 from Document_Search_Active doc where doc.AELGid = ae.LGid and doc.HasDigitalObject = 1))
	';
	else if @SearchDigitalObject = 1  set @remoteQuery = @remoteQuery + '
		AND (exists (select 1 from Document_Search_Modified doc where doc.AELGid = ae.LGid and doc.HasDigitalObject = 1))
	';
	else if @SearchDigitalObject = 0 and  @SearchDrafts = 1  set @remoteQuery = @remoteQuery + '
		AND ( not exists (select 1 from Document_Search_Active doc where doc.AELGid = ae.LGid and doc.HasDigitalObject = 1)	)
	';
	else if @SearchDigitalObject = 0  set @remoteQuery = @remoteQuery + '
		AND (not exists (select 1 from Document_Search_Modified doc where doc.AELGid = ae.LGid and doc.HasDigitalObject = 1))
	';	
	set @remoteQuery = @remoteQuery + @rankFilterRemote;


	if @SearchDrafts = 1 set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = fresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131	)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,	
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @fundsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = ae.FundSystemIdentifier';
	IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = ae.FundSystemIdentifier';

	DECLARE @inventoriesJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @inventoriesJoin = ' inner join v_Inventories i on i.SystemIdentifier = ae.InventorySystemIdentifier';
	IF @SearchDrafts = 0 SET @inventoriesJoin = ' inner join v_PublicInventories i on i.SystemIdentifier = ae.InventorySystemIdentifier';

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsAE.[KEY] as aeId, null as aeDId, kwdsAE.[RANK] as RankKwds
			from freetexttable(ArchivalEntities, *, ''' + @KeyWords + ''') kwdsAE
			union 
			select null as aeId, kwdsAED.[KEY] as aeDId, kwdsAED.[RANK] as RankKwds  
			from freetexttable(ArchivalEntityDrafts, *, ''' + @KeyWords + ''') kwdsAED
		) kwds
		on (ae.Id = kwds.aeDId and ae.IsDraft = 1) or (ae.Id = kwds.aeId and ae.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlAE.[KEY] as aeId, null as aeDId, ttlAE.[RANK] as RankTitle   
			from freetexttable(ArchivalEntities, Title, ''' + @Title + ''') ttlAE 
			union 
			select null as aeId, ttlAEd.[KEY] as aeDId, ttlAEd.[RANK] as RankTitle   
			from freetexttable(ArchivalEntityDrafts, Title, ''' + @Title + ''') ttlAEd
		) ttl
		on (ae.Id = ttl.aeDId and ae.IsDraft = 1) or (ae.Id = ttl.aeId and ae.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rank = ',RankTitle as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';

	DECLARE @isSuspenedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 1  SET @isSuspenedFilter = ' AND f.IsSuspended = 0 AND i.IsSuspended = 0 AND ae.IsSuspended = 0';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberFilter VARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NOT NULL SET @archivalEntityNumberFilter = ' AND ae.Number=''' + @ArchivalEntityNumber + '''';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = ae.StatusCode) <> 12';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_ArchivalEntities' ELSE SET @table = 'v_PublicArchivalEntities';

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' left join v_PublicDocuments d on d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' left join v_Documents d on d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';

	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	IF @SearchDrafts = 1 SET @digitalObjectsTable = 'v_DigitalObjects';
	DECLARE @digitalObjectsFilter VARCHAR(MAX) = '';
	IF @SearchDigitalObject = 1 SET @digitalObjectsFilter = ' and (exists(select 1 from ' + @digitalObjectsTable  + ' do 
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0'
			+ @suspended +
		'))';
	IF @SearchDigitalObject = 0 SET @digitalObjectsFilter = ' and (not exists(select 1 from ' + @digitalObjectsTable  + ' do
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0
		))';

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';		

	DECLARE @archivalEntityDescriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @ArchivalEntityNumber is not null and @FundDescriptionLevelCodesInternal = '-111' set @FundDescriptionLevelCodesInternal = '-999';
	if @ArchivalEntityNumber is not null and @InventoryDescriptionLevelCodesInternal = '-111' set @InventoryDescriptionLevelCodesInternal = '-999';
	if @ArchivalEntityNumber is not null and @ArchivalEntityDescriptionLevelCodesInternal = '-111' 
		set @archivalEntityDescriptionLevelCodesFilter = '' 
	else
		set @archivalEntityDescriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodesInternal + ''', '',''))) 
				OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodesInternal + ''', '',''))))
		';

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			''archival_entity'' AS EntityType,
			ae.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = i.ArchiveId) as ArchiveName,	
			f.Number as FundNumber,
			i.Number as InventoryNumber,
			ae.Number as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			ae.Title as Title,
			NULL as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = ae.StatusCode) as StatusText,
			(SELECT Text FROM [N].[FundDescriptionLevel] fdl where fdl.Code = f.DescriptionLevelCode) as FundDescriptionLevelText,
			(SELECT Text FROM [N].[InventoryDescriptionLevel] idl where idl.Code = i.DescriptionLevelCode) as InventoryDescriptionLevelText,
			(SELECT Text FROM [N].[ArchivalEntityDescriptionLevel] aedl where aedl.Code = ae.DescriptionLevelCode) as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			f.ApproxmateChronologicalScope as FundApproximateChronologicalScope,
			i.ApproxmateChronologicalScope as InventoryApproximateChronologicalScope,
			ae.ApproxmateChronologicalScope as  ArchivalEntityApproximateChronologicalScope,
			NULL as FilmSystemIdentifier,
			NULL as FundGid,
			ae.FundNumberNumeric AS FundIntNumber,
			ae.InventoryNumberNumeric AS InventoryIntNumber,
			ae.NumberNumeric AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			3 as EntityTypeOrder
		FROM ' + @table + ' ae'
		+ @inventoriesJoin +
		+ @fundsJoin + 
		+ @documentsJoin +
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE ae.ExternalIdentifier IS NULL AND ae.HasExternalSource = 0 AND ae.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (ae.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + 
			+ @archivalEntityNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundDescriptionLevel fdl where fdl.Code = f.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.InventoryDescriptionLevel idl where idl.Code = i.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(ae.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(ae.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @archivalEntityDescriptionLevelCodesFilter
			+ @doNotGetAnythingFilter
			+ @isSuspenedFilter
			+ @digitalObjectsFilter
			+ @isDeductedFilter
			+ @rankFilter;

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteInventoriesTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи го чупят в такъв случай	
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL,
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NOT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT
		);

		INSERT INTO @remoteInventoriesTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteInventoriesTable
		UNION
		' +
		@localQuery;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[SearchInventoriesForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	DECLARE @remoteQuery nvarchar(max), @kwds int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1
	if @Title is not null and len(@Title) >= 2 set @ttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rankRemote = ',kwds.[Rank] as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankRemote = ',fttl.[Rank] as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rankRemote = ',(isnull(kwds.[Rank], 0) + isnull(fttl.[Rank], 0)) as Rank';

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilterRemote = ' and fttl.[Rank] > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilterRemote = ' and isnull(kwds.[Rank], 0) > 1 and isnull(fttl.[Rank], 0) > 1';

	SET @remoteQuery = '';
	SET @remoteQuery = 'with fresults as (';
	set @remoteQuery = @remoteQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''inventory'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = inventory.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		inventory.Number as InventoryNumber,
		NULL as ArchivalEntityNumber,
		NULL as KMFNumber,
		NULL as FilmCardNumber,
		fund.Title as Title,
		NULL as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = inventory.StatusGid) as StatusText,
		(select Value FROM Nomenclature n WHERE n.Gid= fund.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as FundDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= inventory.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as InventoryDescriptionLevelText,	
		NULL as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		inventory.LGid AS ExternalIdentifier,
		fund.TextDate AS FundApproximateChronologicalScope,
		inventory.TextDate AS InventoryApproximateChronologicalScope,
		NULL as ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		fund.Gid AS FundGid,
		fund.IntNumber as FundIntNumber,
		inventory.IntNumber AS InventoryIntNumber,
		NULL AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		inventory.Gid,
		inventory.LGid'
		+ @rankRemote
		+ ',2 AS EntityTypeOrder';

	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		from Inventory_Active as inventory
	'
	else set @remoteQuery = @remoteQuery + '
		from Inventory_Modified as inventory
	';
	if @kwds = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(Inventory,*, '''+ @KeyWords + ''') kwds on inventory._id = kwds.[key]
	';
	if @ttl = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(Inventory,FundCreatorNameChanges, '''+ @Title + ''') fttl on inventory._id = fttl.[key]
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Fund_Active fund on inventory.FundLGid = fund.LGid
	'
	if @SearchDrafts = 0 set @remoteQuery = @remoteQuery + '
		inner join Fund_Modified fund on inventory.FundLGid = fund.LGid
	'
	if @ArchiveGids is not null and @ArchiveGids <> '-999' set @remoteQuery = @remoteQuery + '
		where inventory.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else set @remoteQuery = @remoteQuery + '
		where 1 = 1';
	if (@KMFCountriesOfOriginCodes is not null and @KMFCountriesOfOriginCodes <> '-999')
	 set  @remoteQuery = @remoteQuery + '
		and ((select n.Value2 from Nomenclature n where n.Gid = fund.CountryGid and n.Type = ''FACountry'') in (''' + [dbo].[StringSplit3](@KMFCountriesOfOriginCodes) + '''))
		and (fund.LevelOfDescriptionGid = 2185 )
		and (inventory.LevelOfDescriptionGid = 2369 )
	';
	if @InventoryNumber is not null set @remoteQuery = @remoteQuery + '
		and (inventory.Number = ''' + @InventoryNumber + ''')
	';
	if @FundNumber is not null set @remoteQuery = @remoteQuery + '
		and (fund.Number = ''' + @FundNumber + ''')
	';
	--if @FundLevelOfDescriptionGids is not null and @FundLevelOfDescriptionGids <> '-999' set @remoteQuery = @remoteQuery + '
		--and (fund.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@FundLevelOfDescriptionGids) + ' )
	--';
	-- въведен е номер на опис, но не е избрано някое от нивата на описание за описи, така имплицитно се разбира, че нивото на описание е някое от нивата за опис(така са го поискали в писмо)
	if @InventoryNumber is not null  
		and not '2171' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2172' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2372' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteQuery = @remoteQuery + '
			and (inventory.LevelOfDescriptionGid in (2171,2172,2372))
	' 
	else if @InventoryNumber is null and @FundNumber is null
		and not '2171' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2172' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2372' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2369' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteQuery = @remoteQuery + '
			and 1=2
	' 

	else if @LevelOfDescriptionGids <> '-999'
		and ('2171' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')) 
			or '2172' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
			or '2372' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
			or '2369' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')))
		set @remoteQuery = @remoteQuery + '
			and (inventory.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )
	';
	-- Грубите описи да са видими само в служебната част на системата
	if @SearchDrafts = 0 set @remoteQuery = @remoteQuery + '
		and (inventory.LevelOfDescriptionGid <> 2172)
		and (inventory.StatusGid <> 2115)
	';
	if @ToDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @ToDate +''' >= inventory.CreationDate)
	';
	if @FromDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @FromDate + ''' <= inventory.CreationDate)
	';
	--if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
	--	and ((select FundArrayGid from ' + @fundsView + ' where LGid = inventory.FundLGid) in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	--';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
		and (fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +') 
	';
	set @remoteQuery = @remoteQuery + @rankFilterRemote;

	if @SearchDrafts = 1 set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = fresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131	)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,	
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @fundsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = i.FundSystemIdentifier';
	IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = i.FundSystemIdentifier';

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsI.[KEY] as iId, null as iDId, kwdsI.[RANK] as RankKwds
			from freetexttable(Inventories, *, ''' + @KeyWords + ''') kwdsI
			union 
			select null as iId, kwdsID.[KEY] as iDId, kwdsID.[RANK] as RankKwds  
			from freetexttable(InventoryDrafts, *, ''' + @KeyWords + ''') kwdsID
		) kwds
		on (i.Id = kwds.iDId and i.IsDraft = 1) or (i.Id = kwds.iId and i.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlI.[KEY] as iId, null as iDId, ttlI.[RANK] as RankTitle   
			from freetexttable(Inventories, FundCreatorTitleHistory, ''' + @Title + ''') ttlI 
			union 
			select null as iId, ttlId.[KEY] as iDId, ttlId.[RANK] as RankTitle   
			from freetexttable(InventoryDrafts, FundCreatorTitleHistory, ''' + @Title + ''') ttlId
		) ttl
		on (i.Id = ttl.iDId and i.IsDraft = 1) or (i.Id = ttl.iId and i.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rank = ',RankTitle as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';

	DECLARE @isSuspenedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 1  SET @isSuspenedFilter = '  AND f.IsSuspended = 0 AND i.IsSuspended = 0';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @roughInventoriesFilter VARCHAR(MAX) = '';
	-- Грубите описи да са видими само в служебната част на системата
	IF @SearchDrafts = 0 SET @roughInventoriesFilter = ' AND i.DescriptionLevelCode <> ''6''';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = i.StatusCode) <> 12';

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' left join v_PublicDocuments d on d.InventorySystemIdentifier = i.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' left join v_Documents d on d.InventorySystemIdentifier = i.SystemIdentifier';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';

	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	IF @SearchDrafts = 1 SET @digitalObjectsTable = 'v_DigitalObjects';
	DECLARE @digitalObjectsFilter VARCHAR(MAX) = '';
	IF @SearchDigitalObject = 1 SET @digitalObjectsFilter = ' and (exists(select 1 from ' + @digitalObjectsTable  + ' do 
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0'
			+ @suspended +
		'))';
	IF @SearchDigitalObject = 0 SET @digitalObjectsFilter = ' and (not exists(select 1 from ' + @digitalObjectsTable  + ' do
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0
		))';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Inventories' ELSE SET @table = 'v_PublicInventories';

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';

	DECLARE @inventoryDescriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @InventoryNumber is not null and @FundDescriptionLevelCodesInternal = '-111' set @FundDescriptionLevelCodesInternal = '-999';
	if @InventoryNumber is not null and @InventoryDescriptionLevelCodesInternal = '-111' 
		set @inventoryDescriptionLevelCodesFilter = '' 
	else
		set @inventoryDescriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))) 
				OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))))
		';

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			''inventory'' AS EntityType,
			i.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = i.ArchiveId) as ArchiveName,	
			f.Number as FundNumber,
			i.Number as InventoryNumber,
			NULL as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			NULL as Title,
			NULL as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = i.StatusCode) as StatusText,
			(SELECT Text FROM [N].[FundDescriptionLevel] fdl where fdl.Code = f.DescriptionLevelCode) as FundDescriptionLevelText,
			(SELECT Text FROM [N].[InventoryDescriptionLevel] idl where idl.Code = i.DescriptionLevelCode) as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			f.ApproxmateChronologicalScope as FundApproximateChronologicalScope,
			i.ApproxmateChronologicalScope as InventoryApproximateChronologicalScope,
			NULL as ArchivalEntityApproximateChronologicalScope,
			NULL as FilmSystemIdentifier,
			NULL as FundGid,
			i.FundNumberNumeric AS FundIntNumber,
			i.NumberNumeric AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			2 as EntityTypeOrder
		FROM ' + @table + ' i'
		+ @fundsJoin + 
		+ @documentsJoin +
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE i.ExternalIdentifier IS NULL AND i.HasExternalSource = 0 AND i.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (i.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundDescriptionLevel fdl where fdl.Code = f.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(i.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(i.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @inventoryDescriptionLevelCodesFilter
			+ @doNotGetAnythingFilter
			+ @isSuspenedFilter
			+ @roughInventoriesFilter
			+ @digitalObjectsFilter
			+ @isDeductedFilter
			+ @rankFilter;

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteInventoriesTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи го чупят в такъв случай	
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL,
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NOT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT
		);

		INSERT INTO @remoteInventoriesTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteInventoriesTable
		UNION
		' +
		@localQuery;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER PROCEDURE [dbo].[MainSearchComponent]
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodesInternal nvarchar(256) = null,
	@DocumentDescriptionLevelCodesInternal nvarchar(256) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на ArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@KMFNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@EntityType nvarchar(250) = null,
	@ExtendedSearch bit = 0,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	declare @offset int = (@Page - 1) * @RowsOfPage;

	DECLARE @resultColumnsDeclaration VARCHAR(MAX) = '
		EntityType nvarchar(50) NULL,
		SystemIdentifier uniqueidentifier NULL,
		ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи на фондове го чупят в такъв случай
		FundNumber nvarchar(256) NULL,
		InventoryNumber nvarchar(256) NULL,
		ArchivalEntityNumber nvarchar(256) NULL,
		KMFNumber nvarchar(256) NULL,
		FilmCardNumber nvarchar(256) NULL,
		Title nvarchar(MAX) NULL,
		TypeText nvarchar(MAX) NULL,
		StatusText nvarchar(MAX) NULL,
		FundDescriptionLevelText nvarchar(MAX) NULL,
		InventoryDescriptionLevelText nvarchar(MAX) NULL,
		ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
		HasExternalSource BIT NOT NULL,
		ExternalIdentifier INT NULL,
		FundApproximateChronologicalScope nvarchar(256) NULL,
		InventoryApproximateChronologicalScope nvarchar(256) NULL,
		ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
		FilmSystemIdentifier uniqueidentifier NULL,
		FundGid int,
		FundIntNumber INT NULL,
		InventoryIntNumber INT NULL,
		ArchivalEntityIntNumber INT NULL,
		KMFIntNumber INT NULL, 
		FilmCardIntNumber INT NULL,
		[Rank] INT NULL,
		EntityTypeOrder INT
	';

	DECLARE @resultColumns VARCHAR(MAX) = '
		EntityType, 
		SystemIdentifier,
		ArchiveName,		
		FundNumber,
		InventoryNumber,
		ArchivalEntityNumber,
		KMFNumber,
		FilmCardNumber,
		Title,
		TypeText,
		StatusText,
		FundDescriptionLevelText,
		InventoryDescriptionLevelText,	
		ArchivalEntityDescriptionLevelText,
		HasExternalSource,
		ExternalIdentifier,
		FundApproximateChronologicalScope,
		InventoryApproximateChronologicalScope,
		ArchivalEntityApproximateChronologicalScope,
		FilmSystemIdentifier,
		FundGid,
		FundIntNumber,
		InventoryIntNumber,
		ArchivalEntityIntNumber,
		KMFIntNumber,
		FilmCardIntNumber,
		[Rank],
		EntityTypeOrder
	';

	DECLARE @keyWordsColumn VARCHAR(MAX) = '';
	IF @KeyWords IS NULL SET @keyWordsColumn = 'NULL' 
	ELSE SET @keyWordsColumn = '''' + @KeyWords + '''';

	DECLARE @toDateColumn VARCHAR(MAX) = '';
	IF @ToDate IS NULL SET @toDateColumn = 'NULL' 
	ELSE SET @toDateColumn = '''' + @ToDate + '''';

	DECLARE @fromDateColumn VARCHAR(MAX) = '';
	IF @FromDate IS NULL SET @fromDateColumn = 'NULL' 
	ELSE SET @fromDateColumn = '''' + @FromDate + '''';

	DECLARE @titleColumn VARCHAR(MAX) = '';
	IF @Title IS NULL SET @titleColumn = 'NULL' 
	ELSE SET @titleColumn = '''' + @Title + '''';

	DECLARE @fundNumberColumn VARCHAR(MAX) = '';
	IF @FundNumber IS NULL SET @fundNumberColumn = 'NULL' 
	ELSE SET @fundNumberColumn = '''' + @FundNumber + '''';

	DECLARE @inventoryNumberColumn VARCHAR(MAX) = '';
	IF @InventoryNumber IS NULL SET @inventoryNumberColumn = 'NULL' 
	ELSE SET @inventoryNumberColumn = '''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberColumn VARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NULL SET @archivalEntityNumberColumn = 'NULL' 
	ELSE SET @archivalEntityNumberColumn = '''' + @ArchivalEntityNumber + '''';

	DECLARE @kmfNumberColumn VARCHAR(MAX) = '';
	IF @KMFNumber IS NULL SET @kmfNumberColumn = 'NULL' 
	ELSE SET @kmfNumberColumn = '''' + @KMFNumber + '''';

	DECLARE @searchDigitalObjectColumn VARCHAR(MAX) = '';
	IF @SearchDigitalObject IS NULL SET @searchDigitalObjectColumn = 'NULL' 
	ELSE SET @searchDigitalObjectColumn = convert(varchar(1), @searchDigitalObject, 104);

	DECLARE @searchDraftsColumn VARCHAR(MAX) = '';
	IF @SearchDrafts IS NULL SET @searchDraftsColumn = 'NULL' 
	ELSE SET @searchDraftsColumn = convert(varchar(1), @SearchDrafts, 104);

	DECLARE @extendedSearchColumn VARCHAR(MAX) = '';
	IF @ExtendedSearch IS NULL SET @extendedSearchColumn = 'NULL' 
	ELSE SET @extendedSearchColumn = convert(varchar(1), @ExtendedSearch, 104);

	DECLARE @entityTypesArr TABLE (element VARCHAR(50) NULL); 
	INSERT INTO @entityTypesArr SELECT element from dbo.SplitString(@EntityType, ',');

	DECLARE @fundsInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalFunds BIT = 0;
	IF 'fund' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFunds = 1;
	IF  @InventoryNumber IS NULL 
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL 
		AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999' OR @InventoryDescriptionLevelCodesInternal='-111')
		AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999' OR @ArchivalEntityDescriptionLevelCodesInternal='-111')
		AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999'  OR @DocumentDescriptionLevelCodesInternal='-111')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') SET @fundsInsert = '
			INSERT INTO @funds EXEC [dbo].[SearchFundsForMainSearchComponent] 
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@FundNumber = ' + @fundNumberColumn + ',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@DescriptionLevelCodesInternal  = ''' + @FundDescriptionLevelCodesInternal + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@FundArraysInternal = ''' + @FundArraysInternal + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFunds, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @inventoriesInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalIventories BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfInventory TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfInventory (Gid) VALUES (2171),(2172),(2369); -- нива на описание за опис от ИСДА

	IF 'inventory' IN (SELECT element FROM @entityTypesArr) SET @includeLocalIventories = 1;
	IF (@FundNumber IS NOT NULL
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL
		AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
		AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999')
		AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfInventory INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) 
		OR EXISTS(SELECT Code FROM N.InventoryDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@InventoryDescriptionLevelCodesInternal, ',')))
		
		SET @inventoriesInsert = '
			INSERT INTO @inventories EXEC [dbo].[SearchInventoriesForMainSearchComponent] 
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@FundNumber = ' + @fundNumberColumn + ',
				@InventoryNumber = ' + @inventoryNumberColumn + ',
				@KMFCountriesOfOriginCodes  = ''' + @KMFCountriesOfOriginCodes + ''',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@FundDescriptionLevelCodesInternal = ''' + @FundDescriptionLevelCodesInternal + ''',
				@InventoryDescriptionLevelCodesInternal = ''' + @InventoryDescriptionLevelCodesInternal + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@FundArraysInternal = ''' + @FundArraysInternal + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalIventories, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @archivalEntitiesInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalArchivalEntities BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfArchivalEntities TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfArchivalEntities (Gid) VALUES (2174),(2373); -- нива на описание за АЕ от ИСДА
	IF 'archival_entity' IN (SELECT element FROM @entityTypesArr) SET @includeLocalArchivalEntities = 1;
	IF (@FundNumber IS NOT NULL --AND @ArchivalEntityNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL)
		AND @KMFNumber IS NULL
		AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
		AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999')
		AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')) 
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfArchivalEntities INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) -- 3493 от DevOps
		OR EXISTS(SELECT Code FROM N.ArchivalEntityDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@ArchivalEntityDescriptionLevelCodesInternal, ',')))
	SET @archivalEntitiesInsert = '
		INSERT INTO @archivalEntities EXEC [dbo].[SearchArchivalEntitiesForMainSearchComponent] 
			@LinkedServer = ''' + @LinkedServer + ''',
			@SearchDrafts = ' + @searchDraftsColumn + ',
			@ArchiveGids = ''' + @ArchiveGids + ''',
			@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
			@FundNumber = ' + @fundNumberColumn + ',
			@InventoryNumber = ' + @inventoryNumberColumn + ',
			@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
			@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
			@FundDescriptionLevelCodesInternal = ''' + @FundDescriptionLevelCodesInternal + ''',
			@InventoryDescriptionLevelCodesInternal = ''' + @InventoryDescriptionLevelCodesInternal + ''',
			@ArchivalEntityDescriptionLevelCodesInternal = ''' + @ArchivalEntityDescriptionLevelCodesInternal + ''',
			@ToDate = ' + @toDateColumn + ',
			@FromDate = ' + @fromDateColumn + ',
			@FundArrayGids = ''' + @FundArrayGids + ''',
			@FundArraysInternal = ''' + @FundArraysInternal + ''',
			@Title = ' + @titleColumn + ',
			@KeyWords = ' + @keyWordsColumn + ',
			--@KeywordsUIAnnotated = + @keywordsUIAnnotatedColumn + 		
			@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
			@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalArchivalEntities, 104) + ',
			@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @documentsInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalDocuments BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfDocuments TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfDocuments (Gid) VALUES (2173); -- ниво на описание за документ от ИСДА
	IF 'document' IN (SELECT element FROM @entityTypesArr) SET @includeLocalDocuments = 1;
	IF 
		-- това условие е било сложено нарочно, но искат да отпадне 
		--@FundNumber IS NULL AND @InventoryNumber IS NULL AND @ArchivalEntityNumber IS NULL
		--AND 
		(@KMFNumber IS NULL
		AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
		AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999')
		AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfDocuments INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) -- 3493 от DevOps
		OR EXISTS(SELECT Code FROM N.DocumentDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@DocumentDescriptionLevelCodesInternal, ',')))
	SET @documentsInsert = '
		INSERT INTO @documents EXEC [dbo].[SearchDocumentsForMainSearchComponent] 
			@LinkedServer = ''' + @LinkedServer + ''',
			@SearchDrafts = ' + @searchDraftsColumn + ',
			@ArchiveGids = ''' + @ArchiveGids + ''',
			@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
			@FundNumber = ' + @fundNumberColumn + ',
			@InventoryNumber = ' + @inventoryNumberColumn + ',
			@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
			@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
			@FundDescriptionLevelCodesInternal = ''' + @FundDescriptionLevelCodesInternal + ''',
			@InventoryDescriptionLevelCodesInternal = ''' + @InventoryDescriptionLevelCodesInternal + ''',
			@ArchivalEntityDescriptionLevelCodesInternal = ''' + @ArchivalEntityDescriptionLevelCodesInternal + ''',
			@DocumentDescriptionLevelCodesInternal = ''' + @DocumentDescriptionLevelCodesInternal + ''',
			@ToDate = ' + @toDateColumn + ',
			@FromDate = ' + @fromDateColumn + ',
			@FundArrayGids = ''' + @FundArrayGids + ''',
			@FundArraysInternal = ''' + @FundArraysInternal + ''',
			@Title = ' + @titleColumn + ',
			@KeyWords = ' + @keyWordsColumn + ',
			--@KeywordsUIAnnotated = + @keywordsUIAnnotatedColumn + 		
			@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
			@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalDocuments, 104) + ',
			@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @filmsInsert VARCHAR(MAX) = ''; 
	DECLARE @includeLocalFilms BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfFilms TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfFilms (Gid) VALUES (2185); -- ниво на описание КМФ
	IF 'film' IN (SELECT element FROM @entityTypesArr) 
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilms INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) 
		SET @includeLocalFilms = 1;
	IF @FundNumber IS NULL 
		AND @InventoryNumber IS NULL
		AND @ArchivalEntityNumber IS NULL 
		AND @Title IS NULL SET @filmsInsert = '
			INSERT INTO @films EXEC [dbo].[SearchKMFForMainSearchComponent]
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@KMFNumber = ' + @kmfNumberColumn + ',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@KMFCountriesOfOriginCodes = ''' + @KMFCountriesOfOriginCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@KeyWords = ' + @keyWordsColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFilms, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @filmCardsInsert VARCHAR(MAX) = ''; 	
	DECLARE @includeLocalFilmCards BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfFilmCards TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfFilmCards (Gid) VALUES (2371); -- ниво на описание Архивна единица (КМФ)
	IF 'film_card' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFilmCards = 1;
	IF (NOT ((@FundNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL AND @KMFNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL AND @KMFNumber IS NULL)))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilmCards INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ',')))
		--OR NOT ((@FundNumber IS NOT NULL AND @KMFNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @KMFNumber IS NULL)) 
		SET @filmCardsInsert = '
			INSERT INTO @filmCards EXEC [dbo].[SearchFilmCardsForMainSearchComponent]
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@FundNumber  = ' + @fundNumberColumn + ',
				@InventoryNumber = ' + @inventoryNumberColumn + ',
				@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
				@KMFNumber = ' + @kmfNumberColumn + ',
				@KMFCountriesOfOriginCodes = ''' + @KMFCountriesOfOriginCodes + ''',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				--@KeywordsUIAnnotated =  + @keywordsUIAnnotatedColumn + 	
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFilmCards, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
		';

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @funds TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @inventories TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @archivalEntities TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @documents TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @films TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @filmCards TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @result TABLE ('
			+ @resultColumnsDeclaration +
		');'

		+ @fundsInsert + 
		+ @inventoriesInsert + 
		+ @archivalEntitiesInsert + 	
		+ @documentsInsert + 
		+ @filmsInsert +
		+ @filmCardsInsert + '

		INSERT INTO @result SELECT * FROM
			(
				SELECT ' + @resultColumns + ' FROM @funds

				UNION
		
				SELECT ' + @resultColumns + ' FROM @inventories

				UNION

				SELECT ' + @resultColumns + ' FROM @archivalEntities

				UNION

				SELECT ' + @resultColumns + ' FROM @documents

				UNION

				SELECT ' + @resultColumns + ' FROM @films	

				UNION

				SELECT ' + @resultColumns + ' FROM @filmCards
			) x

		
		SELECT
			EntityType, 
			SystemIdentifier,
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			FilmSystemIdentifier,
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			(SELECT COUNT(0) FROM @result) TotalRows,
			[Rank],
			EntityTypeOrder
		FROM @result
		ORDER BY 
			EntityTypeOrder,
			[Rank] DESC,                                                                                                                               
			ArchiveName ASC,  -- колоните с ...Int... представляват числото от номера
            FundIntNumber ASC,
			KMFIntNumber ASC,
            FundNumber ASC,
            InventoryIntNumber ASC,
            InventoryNumber ASC,
            ArchivalEntityIntNumber ASC,
            ArchivalEntityNumber ASC,
			FilmCardIntNumber ASC
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY
		';
	EXEC (@sql);
END
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[MainSearchComponent]
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodesInternal nvarchar(256) = null,
	@DocumentDescriptionLevelCodesInternal nvarchar(256) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на ArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@KMFNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@EntityType nvarchar(250) = null,
	@ExtendedSearch bit = 0,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	declare @offset int = (@Page - 1) * @RowsOfPage;

	DECLARE @resultColumnsDeclaration VARCHAR(MAX) = '
		EntityType nvarchar(50) NULL,
		SystemIdentifier uniqueidentifier NULL,
		ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи на фондове го чупят в такъв случай
		FundNumber nvarchar(256) NULL,
		InventoryNumber nvarchar(256) NULL,
		ArchivalEntityNumber nvarchar(256) NULL,
		KMFNumber nvarchar(256) NULL,
		FilmCardNumber nvarchar(256) NULL,
		Title nvarchar(MAX) NULL,
		TypeText nvarchar(MAX) NULL,
		StatusText nvarchar(MAX) NULL,
		FundDescriptionLevelText nvarchar(MAX) NULL,
		InventoryDescriptionLevelText nvarchar(MAX) NULL,
		ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
		HasExternalSource BIT NOT NULL,
		ExternalIdentifier INT NULL,
		FundApproximateChronologicalScope nvarchar(256) NULL,
		InventoryApproximateChronologicalScope nvarchar(256) NULL,
		ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
		FilmSystemIdentifier uniqueidentifier NULL,
		FundGid int,
		FundIntNumber INT NULL,
		InventoryIntNumber INT NULL,
		ArchivalEntityIntNumber INT NULL,
		KMFIntNumber INT NULL, 
		FilmCardIntNumber INT NULL,
		[Rank] INT NULL,
		EntityTypeOrder INT
	';

	DECLARE @resultColumns VARCHAR(MAX) = '
		EntityType, 
		SystemIdentifier,
		ArchiveName,		
		FundNumber,
		InventoryNumber,
		ArchivalEntityNumber,
		KMFNumber,
		FilmCardNumber,
		Title,
		TypeText,
		StatusText,
		FundDescriptionLevelText,
		InventoryDescriptionLevelText,	
		ArchivalEntityDescriptionLevelText,
		HasExternalSource,
		ExternalIdentifier,
		FundApproximateChronologicalScope,
		InventoryApproximateChronologicalScope,
		ArchivalEntityApproximateChronologicalScope,
		FilmSystemIdentifier,
		FundGid,
		FundIntNumber,
		InventoryIntNumber,
		ArchivalEntityIntNumber,
		KMFIntNumber,
		FilmCardIntNumber,
		[Rank],
		EntityTypeOrder
	';

	DECLARE @keyWordsColumn VARCHAR(MAX) = '';
	IF @KeyWords IS NULL SET @keyWordsColumn = 'NULL' 
	ELSE SET @keyWordsColumn = '''' + @KeyWords + '''';

	DECLARE @toDateColumn VARCHAR(MAX) = '';
	IF @ToDate IS NULL SET @toDateColumn = 'NULL' 
	ELSE SET @toDateColumn = '''' + @ToDate + '''';

	DECLARE @fromDateColumn VARCHAR(MAX) = '';
	IF @FromDate IS NULL SET @fromDateColumn = 'NULL' 
	ELSE SET @fromDateColumn = '''' + @FromDate + '''';

	DECLARE @titleColumn VARCHAR(MAX) = '';
	IF @Title IS NULL SET @titleColumn = 'NULL' 
	ELSE SET @titleColumn = '''' + @Title + '''';

	DECLARE @fundNumberColumn VARCHAR(MAX) = '';
	IF @FundNumber IS NULL SET @fundNumberColumn = 'NULL' 
	ELSE SET @fundNumberColumn = '''' + @FundNumber + '''';

	DECLARE @inventoryNumberColumn VARCHAR(MAX) = '';
	IF @InventoryNumber IS NULL SET @inventoryNumberColumn = 'NULL' 
	ELSE SET @inventoryNumberColumn = '''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberColumn VARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NULL SET @archivalEntityNumberColumn = 'NULL' 
	ELSE SET @archivalEntityNumberColumn = '''' + @ArchivalEntityNumber + '''';

	DECLARE @kmfNumberColumn VARCHAR(MAX) = '';
	IF @KMFNumber IS NULL SET @kmfNumberColumn = 'NULL' 
	ELSE SET @kmfNumberColumn = '''' + @KMFNumber + '''';

	DECLARE @searchDigitalObjectColumn VARCHAR(MAX) = '';
	IF @SearchDigitalObject IS NULL SET @searchDigitalObjectColumn = 'NULL' 
	ELSE SET @searchDigitalObjectColumn = convert(varchar(1), @searchDigitalObject, 104);

	DECLARE @searchDraftsColumn VARCHAR(MAX) = '';
	IF @SearchDrafts IS NULL SET @searchDraftsColumn = 'NULL' 
	ELSE SET @searchDraftsColumn = convert(varchar(1), @SearchDrafts, 104);

	DECLARE @extendedSearchColumn VARCHAR(MAX) = '';
	IF @ExtendedSearch IS NULL SET @extendedSearchColumn = 'NULL' 
	ELSE SET @extendedSearchColumn = convert(varchar(1), @ExtendedSearch, 104);

	DECLARE @entityTypesArr TABLE (element VARCHAR(50) NULL); 
	INSERT INTO @entityTypesArr SELECT element from dbo.SplitString(@EntityType, ',');

	DECLARE @fundsInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalFunds BIT = 0;
	IF 'fund' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFunds = 1;
	IF  @InventoryNumber IS NULL 
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL 
		AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999' OR @InventoryDescriptionLevelCodesInternal='-111')
		AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999' OR @ArchivalEntityDescriptionLevelCodesInternal='-111')
		AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999'  OR @DocumentDescriptionLevelCodesInternal='-111')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') SET @fundsInsert = '
			INSERT INTO @funds EXEC [dbo].[SearchFundsForMainSearchComponent] 
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@FundNumber = ' + @fundNumberColumn + ',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@DescriptionLevelCodesInternal  = ''' + @FundDescriptionLevelCodesInternal + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@FundArraysInternal = ''' + @FundArraysInternal + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFunds, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @inventoriesInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalIventories BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfInventory TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfInventory (Gid) VALUES (2171),(2172),(2369); -- нива на описание за опис от ИСДА

	IF 'inventory' IN (SELECT element FROM @entityTypesArr) SET @includeLocalIventories = 1;
	IF (@FundNumber IS NOT NULL
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL
		AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
		AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999')
		AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfInventory INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) 
		OR @InventoryNumber IS NOT NULL
		OR EXISTS(SELECT Code FROM N.InventoryDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@InventoryDescriptionLevelCodesInternal, ',')))
		
		SET @inventoriesInsert = '
			INSERT INTO @inventories EXEC [dbo].[SearchInventoriesForMainSearchComponent] 
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@FundNumber = ' + @fundNumberColumn + ',
				@InventoryNumber = ' + @inventoryNumberColumn + ',
				@KMFCountriesOfOriginCodes  = ''' + @KMFCountriesOfOriginCodes + ''',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@FundDescriptionLevelCodesInternal = ''' + @FundDescriptionLevelCodesInternal + ''',
				@InventoryDescriptionLevelCodesInternal = ''' + @InventoryDescriptionLevelCodesInternal + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@FundArraysInternal = ''' + @FundArraysInternal + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalIventories, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @archivalEntitiesInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalArchivalEntities BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfArchivalEntities TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfArchivalEntities (Gid) VALUES (2174),(2373); -- нива на описание за АЕ от ИСДА
	IF 'archival_entity' IN (SELECT element FROM @entityTypesArr) SET @includeLocalArchivalEntities = 1;
	IF (@FundNumber IS NOT NULL --AND @ArchivalEntityNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL)
		AND @KMFNumber IS NULL
		AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
		AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999')
		AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')) 
		OR @ArchivalEntityNumber IS NOT NULL
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfArchivalEntities INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) -- 3493 от DevOps
		OR EXISTS(SELECT Code FROM N.ArchivalEntityDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@ArchivalEntityDescriptionLevelCodesInternal, ',')))
	SET @archivalEntitiesInsert = '
		INSERT INTO @archivalEntities EXEC [dbo].[SearchArchivalEntitiesForMainSearchComponent] 
			@LinkedServer = ''' + @LinkedServer + ''',
			@SearchDrafts = ' + @searchDraftsColumn + ',
			@ArchiveGids = ''' + @ArchiveGids + ''',
			@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
			@FundNumber = ' + @fundNumberColumn + ',
			@InventoryNumber = ' + @inventoryNumberColumn + ',
			@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
			@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
			@FundDescriptionLevelCodesInternal = ''' + @FundDescriptionLevelCodesInternal + ''',
			@InventoryDescriptionLevelCodesInternal = ''' + @InventoryDescriptionLevelCodesInternal + ''',
			@ArchivalEntityDescriptionLevelCodesInternal = ''' + @ArchivalEntityDescriptionLevelCodesInternal + ''',
			@ToDate = ' + @toDateColumn + ',
			@FromDate = ' + @fromDateColumn + ',
			@FundArrayGids = ''' + @FundArrayGids + ''',
			@FundArraysInternal = ''' + @FundArraysInternal + ''',
			@Title = ' + @titleColumn + ',
			@KeyWords = ' + @keyWordsColumn + ',
			--@KeywordsUIAnnotated = + @keywordsUIAnnotatedColumn + 		
			@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
			@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalArchivalEntities, 104) + ',
			@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @documentsInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalDocuments BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfDocuments TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfDocuments (Gid) VALUES (2173); -- ниво на описание за документ от ИСДА
	IF 'document' IN (SELECT element FROM @entityTypesArr) SET @includeLocalDocuments = 1;
	IF 
		-- това условие е било сложено нарочно, но искат да отпадне 
		--@FundNumber IS NULL AND @InventoryNumber IS NULL AND @ArchivalEntityNumber IS NULL
		--AND 
		(@KMFNumber IS NULL
		AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
		AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999')
		AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfDocuments INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) -- 3493 от DevOps
		OR EXISTS(SELECT Code FROM N.DocumentDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@DocumentDescriptionLevelCodesInternal, ',')))
	SET @documentsInsert = '
		INSERT INTO @documents EXEC [dbo].[SearchDocumentsForMainSearchComponent] 
			@LinkedServer = ''' + @LinkedServer + ''',
			@SearchDrafts = ' + @searchDraftsColumn + ',
			@ArchiveGids = ''' + @ArchiveGids + ''',
			@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
			@FundNumber = ' + @fundNumberColumn + ',
			@InventoryNumber = ' + @inventoryNumberColumn + ',
			@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
			@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
			@FundDescriptionLevelCodesInternal = ''' + @FundDescriptionLevelCodesInternal + ''',
			@InventoryDescriptionLevelCodesInternal = ''' + @InventoryDescriptionLevelCodesInternal + ''',
			@ArchivalEntityDescriptionLevelCodesInternal = ''' + @ArchivalEntityDescriptionLevelCodesInternal + ''',
			@DocumentDescriptionLevelCodesInternal = ''' + @DocumentDescriptionLevelCodesInternal + ''',
			@ToDate = ' + @toDateColumn + ',
			@FromDate = ' + @fromDateColumn + ',
			@FundArrayGids = ''' + @FundArrayGids + ''',
			@FundArraysInternal = ''' + @FundArraysInternal + ''',
			@Title = ' + @titleColumn + ',
			@KeyWords = ' + @keyWordsColumn + ',
			--@KeywordsUIAnnotated = + @keywordsUIAnnotatedColumn + 		
			@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
			@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalDocuments, 104) + ',
			@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @filmsInsert VARCHAR(MAX) = ''; 
	DECLARE @includeLocalFilms BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfFilms TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfFilms (Gid) VALUES (2185); -- ниво на описание КМФ
	IF 'film' IN (SELECT element FROM @entityTypesArr) 
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilms INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) 
		SET @includeLocalFilms = 1;
	IF @FundNumber IS NULL 
		AND @InventoryNumber IS NULL
		AND @ArchivalEntityNumber IS NULL 
		AND @Title IS NULL SET @filmsInsert = '
			INSERT INTO @films EXEC [dbo].[SearchKMFForMainSearchComponent]
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@KMFNumber = ' + @kmfNumberColumn + ',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@KMFCountriesOfOriginCodes = ''' + @KMFCountriesOfOriginCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@KeyWords = ' + @keyWordsColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFilms, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @filmCardsInsert VARCHAR(MAX) = ''; 	
	DECLARE @includeLocalFilmCards BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfFilmCards TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfFilmCards (Gid) VALUES (2371); -- ниво на описание Архивна единица (КМФ)
	IF 'film_card' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFilmCards = 1;
	IF (NOT ((@FundNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL AND @KMFNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL AND @KMFNumber IS NULL)))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilmCards INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ',')))
		--OR NOT ((@FundNumber IS NOT NULL AND @KMFNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @KMFNumber IS NULL)) 
		SET @filmCardsInsert = '
			INSERT INTO @filmCards EXEC [dbo].[SearchFilmCardsForMainSearchComponent]
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@FundNumber  = ' + @fundNumberColumn + ',
				@InventoryNumber = ' + @inventoryNumberColumn + ',
				@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
				@KMFNumber = ' + @kmfNumberColumn + ',
				@KMFCountriesOfOriginCodes = ''' + @KMFCountriesOfOriginCodes + ''',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				--@KeywordsUIAnnotated =  + @keywordsUIAnnotatedColumn + 	
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFilmCards, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
		';

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @funds TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @inventories TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @archivalEntities TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @documents TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @films TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @filmCards TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @result TABLE ('
			+ @resultColumnsDeclaration +
		');'

		+ @fundsInsert + 
		+ @inventoriesInsert + 
		+ @archivalEntitiesInsert + 	
		+ @documentsInsert + 
		+ @filmsInsert +
		+ @filmCardsInsert + '

		INSERT INTO @result SELECT * FROM
			(
				SELECT ' + @resultColumns + ' FROM @funds

				UNION
		
				SELECT ' + @resultColumns + ' FROM @inventories

				UNION

				SELECT ' + @resultColumns + ' FROM @archivalEntities

				UNION

				SELECT ' + @resultColumns + ' FROM @documents

				UNION

				SELECT ' + @resultColumns + ' FROM @films	

				UNION

				SELECT ' + @resultColumns + ' FROM @filmCards
			) x

		
		SELECT
			EntityType, 
			SystemIdentifier,
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			FilmSystemIdentifier,
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			(SELECT COUNT(0) FROM @result) TotalRows,
			[Rank],
			EntityTypeOrder
		FROM @result
		ORDER BY 
			EntityTypeOrder,
			[Rank] DESC,                                                                                                                               
			ArchiveName ASC,  -- колоните с ...Int... представляват числото от номера
            FundIntNumber ASC,
			KMFIntNumber ASC,
            FundNumber ASC,
            InventoryIntNumber ASC,
            InventoryNumber ASC,
            ArchivalEntityIntNumber ASC,
            ArchivalEntityNumber ASC,
			FilmCardIntNumber ASC
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY
		';
	EXEC (@sql);
END
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER PROCEDURE [dbo].[MainSearchComponentInternal]
	@LinkedServer nvarchar(50) = 'X', -- бърз фикс, не се ползва
	@SearchDrafts bit = 0,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@FundDescriptionLevelCodes nvarchar(256) = null,
	@InventoryDescriptionLevelCodes nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodes nvarchar(256) = null,
	@DocumentDescriptionLevelCodes nvarchar(256) = null,
	@FundArrays nvarchar(max) = null,
	@KMFNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@EntityType nvarchar(250) = null,
	@ExtendedSearch bit = 0,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	declare @offset int = (@Page - 1) * @RowsOfPage;

	DECLARE @resultColumnsDeclaration VARCHAR(MAX) = '
		EntityType nvarchar(50) NULL,
		SystemIdentifier uniqueidentifier NULL,
		ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи на фондове го чупят в такъв случай
		FundNumber nvarchar(256) NULL,
		InventoryNumber nvarchar(256) NULL,
		ArchivalEntityNumber nvarchar(256) NULL,
		KMFNumber nvarchar(256) NULL,
		FilmCardNumber nvarchar(256) NULL,
		Title nvarchar(MAX) NULL,
		TypeText nvarchar(MAX) NULL,
		StatusText nvarchar(MAX) NULL,
		FundDescriptionLevelText nvarchar(MAX) NULL,
		InventoryDescriptionLevelText nvarchar(MAX) NULL,
		ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
		HasExternalSource BIT NOT NULL,
		ExternalIdentifier INT NULL,
		FundApproximateChronologicalScope nvarchar(256) NULL,
		InventoryApproximateChronologicalScope nvarchar(256) NULL,
		ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
		FilmSystemIdentifier uniqueidentifier NULL,
		FundGid int,
		FundIntNumber INT NULL,
		InventoryIntNumber INT NULL,
		ArchivalEntityIntNumber INT NULL,
		KMFIntNumber INT NULL, 
		FilmCardIntNumber INT NULL,
		[Rank] INT NULL,
		EntityTypeOrder INT
	';

	DECLARE @resultColumns VARCHAR(MAX) = '
		EntityType, 
		SystemIdentifier,
		ArchiveName,		
		FundNumber,
		InventoryNumber,
		ArchivalEntityNumber,
		KMFNumber,
		FilmCardNumber,
		Title,
		TypeText,
		StatusText,
		FundDescriptionLevelText,
		InventoryDescriptionLevelText,	
		ArchivalEntityDescriptionLevelText,
		HasExternalSource,
		ExternalIdentifier,
		FundApproximateChronologicalScope,
		InventoryApproximateChronologicalScope,
		ArchivalEntityApproximateChronologicalScope,
		FilmSystemIdentifier,
		FundGid,
		FundIntNumber,
		InventoryIntNumber,
		ArchivalEntityIntNumber,
		KMFIntNumber,
		FilmCardIntNumber,
		[Rank],
		EntityTypeOrder
	';

	DECLARE @keyWordsColumn VARCHAR(MAX) = '';
	IF @KeyWords IS NULL SET @keyWordsColumn = 'NULL' 
	ELSE SET @keyWordsColumn = '''' + @KeyWords + '''';

	DECLARE @toDateColumn VARCHAR(MAX) = '';
	IF @ToDate IS NULL SET @toDateColumn = 'NULL' 
	ELSE SET @toDateColumn = '''' + @ToDate + '''';

	DECLARE @fromDateColumn VARCHAR(MAX) = '';
	IF @FromDate IS NULL SET @fromDateColumn = 'NULL' 
	ELSE SET @fromDateColumn = '''' + @FromDate + '''';

	DECLARE @titleColumn VARCHAR(MAX) = '';
	IF @Title IS NULL SET @titleColumn = 'NULL' 
	ELSE SET @titleColumn = '''' + @Title + '''';

	DECLARE @fundNumberColumn VARCHAR(MAX) = '';
	IF @FundNumber IS NULL SET @fundNumberColumn = 'NULL' 
	ELSE SET @fundNumberColumn = '''' + @FundNumber + '''';

	DECLARE @inventoryNumberColumn VARCHAR(MAX) = '';
	IF @InventoryNumber IS NULL SET @inventoryNumberColumn = 'NULL' 
	ELSE SET @inventoryNumberColumn = '''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberColumn VARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NULL SET @archivalEntityNumberColumn = 'NULL' 
	ELSE SET @archivalEntityNumberColumn = '''' + @ArchivalEntityNumber + '''';

	DECLARE @kmfNumberColumn VARCHAR(MAX) = '';
	IF @KMFNumber IS NULL SET @kmfNumberColumn = 'NULL' 
	ELSE SET @kmfNumberColumn = '''' + @KMFNumber + '''';

	DECLARE @searchDigitalObjectColumn VARCHAR(MAX) = '';
	IF @SearchDigitalObject IS NULL SET @searchDigitalObjectColumn = 'NULL' 
	ELSE SET @searchDigitalObjectColumn = convert(varchar(1), @searchDigitalObject, 104);

	DECLARE @searchDraftsColumn VARCHAR(MAX) = '';
	IF @SearchDrafts IS NULL SET @searchDraftsColumn = 'NULL' 
	ELSE SET @searchDraftsColumn = convert(varchar(1), @SearchDrafts, 104);

	DECLARE @extendedSearchColumn VARCHAR(MAX) = '';
	IF @ExtendedSearch IS NULL SET @extendedSearchColumn = 'NULL' 
	ELSE SET @extendedSearchColumn = convert(varchar(1), @ExtendedSearch, 104);

	--DECLARE @keywordsUIAnnotatedColumn VARCHAR(MAX) = '';
	--IF @KeywordsUIAnnotated IS NULL SET @keywordsUIAnnotatedColumn = 'NULL' 
	--ELSE SET @keywordsUIAnnotatedColumn = convert(varchar(1), @KeywordsUIAnnotated, 104);

	DECLARE @entityTypesArr TABLE (element VARCHAR(50) NULL); 
	INSERT INTO @entityTypesArr SELECT element from dbo.SplitString(@EntityType, ',');

	DECLARE @fundsInsert VARCHAR(MAX) = '';
	IF (@InventoryNumber IS NULL 
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL
		AND(@InventoryDescriptionLevelCodes IS NULL OR @InventoryDescriptionLevelCodes='-999')
		AND(@ArchivalEntityDescriptionLevelCodes IS NULL OR @ArchivalEntityDescriptionLevelCodes='-999')
		AND(@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999')
		AND(@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		OR (EXISTS(SELECT Code FROM N.FundDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@FundDescriptionLevelCodes, ',')))
		AND @InventoryNumber IS NULL 
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL
		AND(@InventoryDescriptionLevelCodes IS NULL OR @InventoryDescriptionLevelCodes='-999' OR @InventoryDescriptionLevelCodes='-111')
		AND(@ArchivalEntityDescriptionLevelCodes IS NULL OR @ArchivalEntityDescriptionLevelCodes='-999' OR @ArchivalEntityDescriptionLevelCodes='-111')
		AND(@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999' OR @DocumentDescriptionLevelCodes='-111')
		AND(@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		--OR (EXISTS(SELECT Code FROM N.FundDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@FundDescriptionLevelCodes, ','))) AND @FundNumber IS NOT NULL)
		AND 'fund' IN (SELECT element FROM @entityTypesArr) SET @fundsInsert = '
			INSERT INTO @funds EXEC [dbo].[SearchFundsForMainSearchComponentInternal] 
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveCodes = ''' + @ArchiveCodes + ''',
				@FundNumber = ' + @fundNumberColumn + ',
				@DescriptionLevelCodes  = ''' + @FundDescriptionLevelCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FundArrays = ''' + @FundArrays + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @inventoriesInsert VARCHAR(MAX) = ''; --NULL AND @InventoryNumber IS NULL)  
	IF (@FundNumber IS NOT NULL
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL
		AND(@FundDescriptionLevelCodes IS NULL OR @FundDescriptionLevelCodes='-999')
		AND(@ArchivalEntityDescriptionLevelCodes IS NULL OR @ArchivalEntityDescriptionLevelCodes='-999')
		AND(@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') 
		AND 'inventory' IN (SELECT element FROM @entityTypesArr))
		OR (@InventoryNumber IS NOT NULL
		AND @ArchivalEntityNumber IS NULL 
		AND(@FundDescriptionLevelCodes IS NULL OR @FundDescriptionLevelCodes='-999' OR @FundDescriptionLevelCodes='-111')
		AND(@ArchivalEntityDescriptionLevelCodes IS NULL OR @ArchivalEntityDescriptionLevelCodes='-999' OR @ArchivalEntityDescriptionLevelCodes='-111')
		AND(@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999' OR @DocumentDescriptionLevelCodes='-111')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999' OR @KMFCountriesOfOriginCodes='-111'))
		OR EXISTS(SELECT Code FROM N.InventoryDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@InventoryDescriptionLevelCodes, ',')))
		SET @inventoriesInsert = '
			INSERT INTO @inventories EXEC [dbo].[SearchInventoriesForMainSearchComponentInternal] 
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveCodes = ''' + @ArchiveCodes + ''',
				@FundNumber = ' + @fundNumberColumn + ',
				@InventoryNumber = ' + @inventoryNumberColumn + ',
				@KMFCountriesOfOriginCodes  = ''' + @KMFCountriesOfOriginCodes + ''',
				@FundDescriptionLevelCodes = ''' + @FundDescriptionLevelCodes + ''',
				@InventoryDescriptionLevelCodes = ''' + @InventoryDescriptionLevelCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrays = ''' + @FundArrays + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @archivalEntitiesInsert VARCHAR(MAX) = '';
	IF ((@FundNumber IS NOT NULL OR @InventoryNumber IS NOT NULL)
		AND @KMFNumber IS NULL
		AND (@FundDescriptionLevelCodes IS NULL OR @FundDescriptionLevelCodes='-999')
		AND (@InventoryDescriptionLevelCodes IS NULL OR @InventoryDescriptionLevelCodes='-999')
		AND (@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
		AND 'archival_entity' IN (SELECT element FROM @entityTypesArr))
		OR (@ArchivalEntityNumber IS NOT NULL
		AND @KMFNumber IS NULL
		AND (@FundDescriptionLevelCodes IS NULL OR @FundDescriptionLevelCodes='-999')
		AND (@InventoryDescriptionLevelCodes IS NULL OR @InventoryDescriptionLevelCodes='-999')
		AND (@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		OR EXISTS(SELECT Code FROM N.ArchivalEntityDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@ArchivalEntityDescriptionLevelCodes, ',')))
	SET @archivalEntitiesInsert = '
		INSERT INTO @archivalEntities EXEC [dbo].[SearchArchivalEntitiesForMainSearchComponentInternal] 
			@LinkedServer = ''' + @LinkedServer + ''',
			@SearchDrafts = ' + @searchDraftsColumn + ',
			@ArchiveCodes = ''' + @ArchiveCodes + ''',
			@FundNumber = ' + @fundNumberColumn + ',
			@InventoryNumber = ' + @inventoryNumberColumn + ',
			@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
			@FundDescriptionLevelCodes = ''' + @FundDescriptionLevelCodes + ''',
			@InventoryDescriptionLevelCodes = ''' + @InventoryDescriptionLevelCodes + ''',
			@ArchivalEntityDescriptionLevelCodes = ''' + @ArchivalEntityDescriptionLevelCodes + ''',
			@ToDate = ' + @toDateColumn + ',
			@FromDate = ' + @fromDateColumn + ',
			@FundArrays = ''' + @FundArrays + ''',
			@Title = ' + @titleColumn + ',
			@KeyWords = ' + @keyWordsColumn + ',
			--@KeywordsUIAnnotated = + @keywordsUIAnnotatedColumn + 		
			@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
			@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @documentsInsert VARCHAR(MAX) = '';
	IF 
		-- това условие е било сложено нарочно, но искат да отпадне 
		--@FundNumber IS NULL AND @InventoryNumber IS NULL AND @ArchivalEntityNumber IS NULL
		--AND 
		(@KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		OR EXISTS(SELECT Code FROM N.DocumentDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@DocumentDescriptionLevelCodes, ',')))
	SET @documentsInsert = '
		INSERT INTO @documents EXEC [dbo].[SearchDocumentsForMainSearchComponentInternal] 
			@LinkedServer = ''' + @LinkedServer + ''',
			@SearchDrafts = ' + @searchDraftsColumn + ',
			@ArchiveCodes = ''' + @ArchiveCodes + ''',
			@FundNumber = ' + @fundNumberColumn + ',
			@InventoryNumber = ' + @inventoryNumberColumn + ',
			@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
			@FundDescriptionLevelCodes = ''' + @FundDescriptionLevelCodes + ''',
			@InventoryDescriptionLevelCodes = ''' + @InventoryDescriptionLevelCodes + ''',
			@ArchivalEntityDescriptionLevelCodes = ''' + @ArchivalEntityDescriptionLevelCodes + ''',
			@DocumentDescriptionLevelCodes = ''' + @DocumentDescriptionLevelCodes + ''',
			@ToDate = ' + @toDateColumn + ',
			@FromDate = ' + @fromDateColumn + ',
			@FundArrays = ''' + @FundArrays + ''',
			@Title = ' + @titleColumn + ',
			@KeyWords = ' + @keyWordsColumn + ',
			--@KeywordsUIAnnotated = + @keywordsUIAnnotatedColumn + 		
			@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
			@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @filmsInsert VARCHAR(MAX) = ''; 
	IF @FundNumber IS NULL 
		AND @InventoryNumber IS NULL
		AND @ArchivalEntityNumber IS NULL 
		AND 'film' IN (SELECT element FROM @entityTypesArr) SET @filmsInsert = '
			INSERT INTO @films EXEC [dbo].[SearchKMFForMainSearchComponentInternal]
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveCodes = ''' + @ArchiveCodes + ''',
				@KMFNumber = ' + @kmfNumberColumn + ',
				@KMFCountriesOfOriginCodes = ''' + @KMFCountriesOfOriginCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @filmCardsInsert VARCHAR(MAX) = ''; 	
	IF @FundNumber IS NULL 
		AND @InventoryNumber IS NULL 
		AND 'film_card' IN (SELECT element FROM @entityTypesArr) SET @filmCardsInsert = '
			INSERT INTO @filmCards EXEC [dbo].[SearchFilmCardsForMainSearchComponentInternal]
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveCodes = ''' + @ArchiveCodes + ''',
				@KMFNumber = ' + @kmfNumberColumn + ',
				@KMFCountriesOfOriginCodes = ''' + @KMFCountriesOfOriginCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				--@KeywordsUIAnnotated =  + @keywordsUIAnnotatedColumn + 	
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @funds TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @inventories TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @archivalEntities TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @documents TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @films TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @filmCards TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @result TABLE ('
			+ @resultColumnsDeclaration +
		');'

		+ @fundsInsert + 
		+ @inventoriesInsert + 
		+ @archivalEntitiesInsert + 
		+ @documentsInsert + 
		+ @filmsInsert +
		+ @filmCardsInsert + '

		INSERT INTO @result SELECT * FROM
			(
				SELECT ' + @resultColumns + ' FROM @funds

				UNION
		
				SELECT ' + @resultColumns + ' FROM @inventories

				UNION

				SELECT ' + @resultColumns + ' FROM @archivalEntities

				UNION

				SELECT ' + @resultColumns + ' FROM @documents

				UNION

				SELECT ' + @resultColumns + ' FROM @films	

				UNION

				SELECT ' + @resultColumns + ' FROM @filmCards
			) x

		
		SELECT
			EntityType, 
			SystemIdentifier,
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			FilmSystemIdentifier,
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			(SELECT COUNT(0) FROM @result) TotalRows,
			[Rank],
			EntityTypeOrder
		FROM @result
		ORDER BY 
			EntityTypeOrder,
			[Rank] DESC,
			ArchiveName ASC,  -- колоните с ...Int... представляват числото от номера
            FundIntNumber ASC,
			KMFIntNumber ASC,
            FundNumber ASC,
            InventoryIntNumber ASC,
            InventoryNumber ASC,
            ArchivalEntityIntNumber ASC,
            ArchivalEntityNumber ASC,
			FilmCardIntNumber ASC
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY
		';

	EXEC (@sql);
END
GO

--Digital objects
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[sp_GetDocumentDigitalObjectsCount]
	@LinkedServer nvarchar(50),
	@DocumentIdentifier uniqueidentifier NULL,
	@DocumentHasExternalSource bit,
	@DocumentExternalIdentifier int NULL,
	@Digitized bit NULL,
	@IncludeDeleted bit = false
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteDigitalObjects TABLE ( DigitalObjectCount int );
	DECLARE @RemoteDigitalObjectsCount int = 0;
	DECLARE @LocalDigitalObjectsCount int = 0;

	DECLARE @RemoteDigitalObjectsQuery nvarchar(max) = '';
		
	IF ( @DocumentHasExternalSource = 1 AND (@Digitized IS NULL OR @Digitized = 1))
	BEGIN 
		SET @RemoteDigitalObjectsQuery = CAST('' as nvarchar(max)) +
		'SELECT img.Gid
		   FROM [Archiving].[dbo].[Image] img
		   JOIN dbo.Document_Active doc on img.DocumentGid = doc.Gid and doc._retired = ''''3000-01-01 00:00:00.000''''
		  WHERE doc.LGid = ' + CAST(@DocumentExternalIdentifier as nvarchar(50));
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT COUNT(*) as DigitalObjectCount FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteDigitalObjectsQuery + ''' )';
		
		PRINT @RemoteQuery
		
		INSERT INTO @RemoteDigitalObjects
		EXEC(@RemoteQuery)

		SELECT TOP 1 @RemoteDigitalObjectsCount = DigitalObjectCount from @RemoteDigitalObjects

	END

	IF @DocumentIdentifier IS NOT NULL
	BEGIN
		SELECT @LocalDigitalObjectsCount = COUNT(do.Id)
		  FROM [dbo].[v_DigitalObjects] do
		 WHERE do.DocumentSystemIdentifier = @DocumentIdentifier 
		   AND (do.HasExternalSource IS NULL OR do.HasExternalSource = 0)
		   AND (@Digitized IS NULL OR do.IsDigitized = @Digitized)
		   AND (@IncludeDeleted = 1 OR do.Deleted = 0)

	END

	RETURN @LocalDigitalObjectsCount + @RemoteDigitalObjectsCount;
END
GO


CREATE OR ALTER PROCEDURE sp_GetDocumentDigitalObjects
	@LinkedServer nvarchar(255) = '', 
	@DocumentIdentifier uniqueidentifier = NULL,
	@DocumentHasExternalSource bit,
	@DocumentExternalIdentifier int = NULL,
	@Digitized bit NULL,
	@IncludeDeleted bit = false,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteDigitalObjectsQuery nvarchar(max) = '';
	DECLARE @RemoteDigitalObjects TABLE (
		Id int 
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,ParentId int
		,ParentSystemIdentifier uniqueidentifier
		,ArchiveCode int
		,ArchiveName nvarchar(255)
		,DocumentHasExternalSource bit
		,DocumentExternalIdentifier int
		,DocumentNumber nvarchar(50)
		,ArchivalEntityHasExternalSource bit
		,ArchivalEntityExternalIdentifier int
		,ArchivalEntityNumber nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,TypeCode int
		,Name nvarchar(max)
		,SourceName nvarchar(max)
		,FileType nvarchar(50)
		,UncPath nvarchar(max)
		,IsDigitized bit
	);

	DECLARE @LocalDigitalObjectsQuery nvarchar(max) = '';
	DECLARE @LocalDigitalObjects TABLE (
		Id int 
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,ParentId int
		,ParentSystemIdentifier uniqueidentifier
		,ArchiveCode int
		,ArchiveName nvarchar(255)
		,DocumentHasExternalSource bit
		,DocumentExternalIdentifier int
		,DocumentNumber nvarchar(50)
		,ArchivalEntityHasExternalSource bit
		,ArchivalEntityExternalIdentifier int
		,ArchivalEntityNumber nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,TypeCode int
		,Name nvarchar(max)
		,SourceName nvarchar(max)
		,FileType nvarchar(50)
		,UncPath nvarchar(max)
		,IsDigitized bit
	);


	IF (@DocumentHasExternalSource = 1 AND (@Digitized IS NULL OR @Digitized = 1))
	BEGIN 
		SET @RemoteDigitalObjectsQuery = CAST('' as nvarchar(max)) +
		'select -1 as Id
				,CAST(NULL as uniqueidentifier) as SystemIdentifier
				,CAST(1 as bit) as HasExternalSource
				,img.Gid as ExternalIdentifier
				,CAST(NULL as int) ParentId
				,CAST(NULL as uniqueidentifier) ParentSystemIdentifier
				,(select Code from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
				,(select Name from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
				,CAST(1 as bit) as DocumentHasExternalSource
				,doc.LGid as DocumentExternalIdentifier
				,doc.Number as DocumentNumber
				,CAST(1 as bit) as ArchivalEntityHasExternalSource
				,doc.AELGid as ArchivalEntityExternalIdentifier
				,(select Number from [Archiving].[dbo].ArchiveEntity_Active ae where ae.LGid = doc.AELGid and ae._retired = ''''3000-01-01 00:00:00.000'''') as ArchivalEntityNumber
				,CAST(1 as bit) as InventoryHasExternalSource
				,doc.InventoryLGid as InventoryExternalIdentifier
				,(select Number from [Archiving].[dbo].Inventory_Active inv where inv.LGid = doc.InventoryLGid and inv._retired = ''''3000-01-01 00:00:00.000'''') as InventoryNumber
				,CAST(1 as bit) as FundHasExternalSource
				,doc.FundLGid as FundExternalIdentifier
				,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = doc.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
				,CAST(2 as int) as TypeCode' + '
				,CONCAT((select Code from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000''''), ''''_'''',doc.LGid, ''''_'''', REVERSE(SUBSTRiNG(REVERSE(LEFT(img.FilePath, LEN(img.FilePath) - LEN(REVERSE(SUBSTRING(REVERSE(img.FilePath),1,CHARINDEX(''''_'''',REVERSE(img.FilePath))))))),0, CHARINDEX(''''_'''',REVERSE(LEFT(img.FilePath, LEN(img.FilePath) - LEN(REVERSE(SUBSTRING(REVERSE(img.FilePath),1,CHARINDEX(''''_'''',REVERSE(img.FilePath)))))))))), ''''_d'''', ''''.jpg'''') as Name
				,CONCAT((select Code from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000''''), ''''_'''',doc.LGid, ''''_'''', REVERSE(SUBSTRiNG(REVERSE(LEFT(img.FilePath, LEN(img.FilePath) - LEN(REVERSE(SUBSTRING(REVERSE(img.FilePath),1,CHARINDEX(''''_'''',REVERSE(img.FilePath))))))),0, CHARINDEX(''''_'''',REVERSE(LEFT(img.FilePath, LEN(img.FilePath) - LEN(REVERSE(SUBSTRING(REVERSE(img.FilePath),1,CHARINDEX(''''_'''',REVERSE(img.FilePath)))))))))), ''''_d'''', ''''.jpg'''') as SourceName
				,''''jpg'''' as FileType
				,img.FilePath as UncPath
				,CAST(1 as bit) as IsDigitized
		   from dbo.Image img 
		   join dbo.Document_Active doc on img.DocumentGid = doc.Gid and doc._retired = ''''3000-01-01 00:00:00.000''''
		  where doc.LGid = ' + CAST(@DocumentExternalIdentifier as nvarchar(50)) + ' and img._retired = ''''3000-01-01 00:00:00.000''''' + '

		  union ' + '
		
		 select -1 as Id
				,CAST(NULL as uniqueidentifier) as SystemIdentifier
				,CAST(1 as bit) as HasExternalSource
				,img.Gid as ExternalIdentifier
				,CAST(NULL as int) ParentId
				,CAST(NULL as uniqueidentifier) ParentSystemIdentifier
				,(select Code from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
				,(select Name from [Archiving].[dbo].Archive a where a.Gid = doc.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
				,CAST(1 as bit) as DocumentHasExternalSource
				,doc.LGid as DocumentExternalIdentifier
				,doc.Number as DocumentNumber
				,CAST(1 as bit) as ArchivalEntityHasExternalSource
				,doc.AELGid as ArchivalEntityExternalIdentifier
				,(select Number from [Archiving].[dbo].ArchiveEntity_Active ae where ae.LGid = doc.AELGid and ae._retired = ''''3000-01-01 00:00:00.000'''') as ArchivalEntityNumber
				,CAST(1 as bit) as InventoryHasExternalSource
				,doc.InventoryLGid as InventoryExternalIdentifier
				,(select Number from [Archiving].[dbo].Inventory_Active inv where inv.LGid = doc.InventoryLGid and inv._retired = ''''3000-01-01 00:00:00.000'''') as InventoryNumber
				,CAST(1 as bit) as FundHasExternalSource
				,doc.FundLGid as FundExternalIdentifier
				,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = doc.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
				,CAST(1 as int) as TypeCode
				,REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''\'''',REVERSE(img.FilePath)))) as Name
				,REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''\'''',REVERSE(img.FilePath)))) as SourceName
				,REVERSE(SUBSTRING(REVERSE(img.FilePath),0,CHARINDEX(''''.'''',REVERSE(img.FilePath)))) as FileType
				,img.FilePath as UncPath
				,CAST(1 as bit) as IsDigitized
		   from dbo.Image img 
		   join dbo.Document_Active doc on img.DocumentGid = doc.Gid and doc._retired = ''''3000-01-01 00:00:00.000''''
		  where doc.LGid = ' + CAST(@DocumentExternalIdentifier as nvarchar(50)) + ' and img._retired = ''''3000-01-01 00:00:00.000''''';

		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteDigitalObjectsQuery + ''' )';
		
		INSERT INTO @RemoteDigitalObjects 
		EXEC(@RemoteQuery)

	END

	IF @DocumentIdentifier IS NOT NULL
	BEGIN
		PRINT(@DocumentIdentifier);

		INSERT INTO @LocalDigitalObjects
		SELECT	dig.Id as Id
				,dig.SystemIdentifier as SystemIdentifier
				,ISNULL(dig.HasExternalSource, CAST(0 as bit)) as HasExternalSource
				,dig.ExternalIdentifier as ExternalIdentifier
				,dig.ParentId as ParentId
				,dig.ParentSystemIdentifier as ParentSystemIdentifier
				,dig.ArchiveCode as ArchiveCode
				,dig.ArchiveName as ArchiveName
				,dig.DocumentHasExternalSource as DocumentHasExternalSource
				,dig.DocumentExternalIdentifier as DocumentExternalIdentifier
				,dig.DocumentNumber as DocumentNumber
				,dig.ArchivalEntityHasExternalSource as ArchivalEntityHasExternalSource
				,dig.ArchivalEntityExternalIdentifier as ArchivalEntityExternalIdentifier
				,dig.ArchivalEntityNumber as ArchivalEntityNumber
				,dig.InventoryHasExternalSource as InventoryHasExternalSource
				,dig.InventoryExternalIdentifier as InventoryExternalIdentifier
				,dig.InventoryNumber as InventoryNumber
				,dig.FundHasExternalSource as FundHasExternalSource
				,dig.FundExternalIdentifier as FundExternalIdentifier
				,dig.FundNumber FundNumber
				,dig.TypeCode as TypeCode
				,dig.Name as Name
				,dig.SourceName as SourceName
				,dig.FileType
				,dig.UncPath as UncPath
				,dig.IsDigitized as IsDigitized
		  FROM dbo.v_DigitalObjects dig
		 WHERE dig.DocumentSystemIdentifier = @DocumentIdentifier
		   AND (dig.HasExternalSource IS NULL OR dig.HasExternalSource = 0)
		   AND (@Digitized IS NULL OR dig.IsDigitized = @Digitized)
		   AND (@IncludeDeleted = 1 OR dig.Deleted = 0)

	END
	IF (@Paging = 1)
	BEGIN
		SELECT *
		  FROM
		  (
			 SELECT *
			   FROM @LocalDigitalObjects
			  UNION
			 SELECT *
			   FROM @RemoteDigitalObjects
		   ) Documents
		ORDER BY SourceName
		OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
	END
	ELSE
	BEGIN
		SELECT *
		  FROM
		  (
			 SELECT *
			   FROM @LocalDigitalObjects
			  UNION
			 SELECT *
			   FROM @RemoteDigitalObjects
		   ) Documents
		ORDER BY SourceName
	END
END
GO

--END Digital objects

----------------------------------------------------------
--	THE SCRIPT IS CLOSED - USE THE NEW ONE!
----------------------------------------------------------
commit


--!!!TODO UPDATE MANUALLY Digital objects and drafts from process types 7,8,9!!!

--select distinct DocumentSystemIdentifier from Process where ProcessTypeId in (
--  7
--  ,8
--  ,9
--  )
--  and  DocumentSystemIdentifier is not null

--begin transaction
-- update DigitalObjects set IsDigitized = 1 
-- where DocumentSystemIdentifier in (

--  select distinct DocumentSystemIdentifier from Process where ProcessTypeId in (
--  7
--  ,8
--  ,9
--  )
--  and  DocumentSystemIdentifier is not null

-- )
-- commit


-- select * from DigitalObjectDrafts

-- begin transaction
-- update DigitalObjectDrafts set IsDigitized = 1 
-- where DocumentSystemIdentifier in (

--  select distinct DocumentSystemIdentifier from Process where ProcessTypeId in (
--  7
--  ,8
--  ,9
--  )
--  and  DocumentSystemIdentifier is not null

-- )
-- commit

--!!!END TODO UPDATE MANUALLY Digital objects and drafts from process types 7,8,9 !!!