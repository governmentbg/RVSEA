--SCRIPT CLOSED! USE THE NEXT ONE!

SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.40'
where Code = 'DB_VERSION'
go

update dbo._Version 
set Value = '1.1.34'
where Code = 'APP_VERSION'
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetDocumentDigitalObjects]
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
		,IsDraft bit
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
		,IsImported bit
	);

	DECLARE @LocalDigitalObjectsQuery nvarchar(max) = '';
	DECLARE @LocalDigitalObjects TABLE (
		Id int 
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,IsDraft bit
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
		,IsImported bit
	);


	IF (@DocumentHasExternalSource = 1 AND (@Digitized IS NULL OR @Digitized = 1))
	BEGIN 
		SET @RemoteDigitalObjectsQuery = CAST('' as nvarchar(max)) +
		'select -1 as Id
				,CAST(NULL as uniqueidentifier) as SystemIdentifier
				,CAST(1 as bit) as HasExternalSource
				,img.Gid as ExternalIdentifier
				,CAST(0 as bit) as IsDraft
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
				,CAST(0 as bit) as IsImported
		   from dbo.Image img 
		   join dbo.Document_Active doc on img.DocumentGid = doc.Gid and doc._retired = ''''3000-01-01 00:00:00.000''''
		  where doc.LGid = ' + CAST(@DocumentExternalIdentifier as nvarchar(50)) + ' and img._retired = ''''3000-01-01 00:00:00.000''''' + '

		  union ' + '
		
		 select -1 as Id
				,CAST(NULL as uniqueidentifier) as SystemIdentifier
				,CAST(1 as bit) as HasExternalSource
				,img.Gid as ExternalIdentifier
				,CAST(0 as bit) as IsDraft
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
				,CAST(0 as bit) as IsImported
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
				,dig.IsDraft
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
				,dig.IsImported as IsImported
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


-- Public document digital objects
CREATE OR ALTER PROCEDURE [dbo].[sp_GetPublicDocumentDigitalObjectsCount]
	@LinkedServer nvarchar(50),
	@DocumentIdentifier uniqueidentifier NULL,
	@DocumentHasExternalSource bit,
	@DocumentExternalIdentifier int NULL,
	@PublicAccessOnly bit
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteDigitalObjects TABLE ( DigitalObjectCount int );
	DECLARE @RemoteDigitalObjectsCount int = 0;
	DECLARE @LocalDigitalObjectsCount int = 0;

	DECLARE @RemoteDigitalObjectsQuery nvarchar(max) = '';
		
	IF @DocumentHasExternalSource = 1
	BEGIN 
		SET @RemoteDigitalObjectsQuery = CAST('' as nvarchar(max)) +
		'SELECT img.Gid
		   FROM [Archiving].[dbo].[Image] img
		   JOIN dbo.Document_Active doc on img.DocumentGid = doc.Gid and doc._retired = ''''3000-01-01 00:00:00.000''''
		  WHERE doc.LGid = ' + CAST(@DocumentExternalIdentifier as nvarchar(50)) + ' and img._retired = ''''3000-01-01 00:00:00.000''''';
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT COUNT(*) as DigitalObjectCount FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteDigitalObjectsQuery + ''' )';
		
		PRINT @RemoteQuery
		
		INSERT INTO @RemoteDigitalObjects
		EXEC(@RemoteQuery)

		SELECT TOP 1 @RemoteDigitalObjectsCount = DigitalObjectCount from @RemoteDigitalObjects

	END

	IF @DocumentIdentifier IS NOT NULL
	BEGIN
		SELECT @LocalDigitalObjectsCount = COUNT(do.Id)
		  FROM [dbo].[v_PublicDigitalObjects] do
		 WHERE do.DocumentSystemIdentifier = @DocumentIdentifier 
		   AND do.Deleted = 0
		   AND (do.HasExternalSource IS NULL OR do.HasExternalSource = 0)
		   AND (@PublicAccessOnly = 0 OR (@PublicAccessOnly = 1 AND do.TypeCode = 3)) -- Само демо файлове
	END

	PRINT @LocalDigitalObjectsCount;
	PRINT @RemoteDigitalObjectsCount;

	RETURN @LocalDigitalObjectsCount + @RemoteDigitalObjectsCount;
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
		,IsDraft bit
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
		,IsImported bit
	);

	DECLARE @LocalDigitalObjectsQuery nvarchar(max) = '';
	DECLARE @LocalDigitalObjects TABLE (
		Id int 
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,IsDraft bit
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
		,IsImported bit
	);


	IF @DocumentHasExternalSource = 1
	BEGIN 
		SET @RemoteDigitalObjectsQuery = CAST('' as nvarchar(max)) + 
		'select -1 as Id
				,CAST(NULL as uniqueidentifier) as SystemIdentifier
				,CAST(1 as bit) as HasExternalSource
				,img.Gid as ExternalIdentifier
				,CAST(0 as bit) as IsDraft
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
				,CAST(0 as bit) as IsImported
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
				,dig.IsDraft
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
				,dig.IsImported as IsImported
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
-- END Public document digital objects





if not exists (select null from sys.columns where name = 'AssignedToRoleId' and object_id = object_id ('dbo.Tasks'))
begin 
	alter table dbo.Tasks add AssignedToRoleId uniqueidentifier Constraint FK_Tasks_AssignedToRoleId Foreign Key References AspNetRoles(Id)
end
go


CREATE OR ALTER   view [dbo].[v_PublicDigitalObjects]
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
	  ,CAST(do.IsDigitized as bit) as IsDigitized
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




CREATE OR ALTER   VIEW [dbo].[v_PublicDocuments] AS
	SELECT 
		d.Id, d.SystemIdentifier,
		CAST(0 AS bit) AS IsDraft,
		d.ArchiveId, 
		a.Code AS ArchiveCode,
		a.Name AS ArchiveName,
		NULL AS FundDraftId, 
		d.FundSystemIdentifier, 
		f.Number AS FundNumber, 
        f.NumberNumeric AS FundNumberNumeric,
		f.NumberArray as FundNumberArray,
		f.HasExternalSource AS FundHasExternalSource, 
		f.ExternalIdentifier AS FundExternalIdentifier,
		f.DescriptionLevelCode AS FundDescriptionLevelCode,
		f.StatusCode AS FundStatusCode,
		NULL AS InventoryDraftId, 
		d.InventorySystemIdentifier, 
		i.Number AS InventoryNumber, 
        i.NumberNumeric AS InventoryNumberNumeric,
		i.NumberArray AS InventoryNumberArray,
		i.HasExternalSource AS InventoryHasExternalSource,
		i.ExternalIdentifier AS InventoryExternalIdentifier,
		i.DescriptionLevelCode AS InventoryDescriptionLevelCode,
		i.StatusCode AS InventoryStatusCode,
		NULL AS ArchivalEntityDraftId, 
		d.ArchivalEntitySystemIdentifier, 
		ae.Number AS ArchivalEntityNumber, 
        ae.NumberNumeric AS ArchivalEntityNumberNumeric,
		ae.NumberArray as ArchivalEntityNumberArray,
		ae.HasExternalSource AS ArchivalEntityHasExternalSource, 
		ae.ExternalIdentifier AS ArchivalEntityExternalIdentifier,
		ae.DescriptionLevelCode AS ArchivalEntityDescriptionLevelCode,
		ae.StatusCode as ArchivalEntityStatusCode,
		d.CreatedOn,
		d.CreatedBy, 
		cu.DisplayName AS CreatedByDisplayName,
		cu.UserName AS CreatedByUserName, 
        d.UpdatedOn, 
		d.UpdatedBy, 
		uu.DisplayName AS UpdatedByDisplayName, 
		uu.UserName AS UpdatedByUserName,
		d.Deleted, 
		d.DeletedOn, 
		d.DeletedBy,
		du.DisplayName AS DeletedByDisplayName,
		du.UserName AS DeletedByUserName, 
        d.HasExternalSource, 
		d.ExternalIdentifier, 
		d.ExternalSourceUpdatedOn, 
		d.Number, 
		d.Title,
		d.DescriptionLevelCode, 
		l.Text AS DescriptionLevelText,
		d.StatusCode, 
		s.Text AS StatusText, 
		d.FileFormatCode, 
		d.HasNoChronologicalScope, 
        d.StartDateYear,
		d.StartDateMonth, 
		d.StartDateDay, 
		d.EndDateYear, 
		d.EndDateMonth, 
		d.EndDateDay, 
		d.ApproxmateChronologicalScope, 
		d.Author, 
		d.Location, 
		d.Bytes, 
		d.SheetCount,
		d.StartSheetNumber, 
		d.EndSheetNumber, 
        d.DigitalDevice,
		d.OtherMetrics,
		d.SizeCm, 
		d.Scaling,
		d.Duration, 
		d.Description, 
		d.DocumentsAccessDescription,
		d.Features,
		d.MicrofilmedCopyCount, 
		d.DigitizedCopyCount, 
		d.PaperCopyCount, 
		d.NegativeFrameCount, 
        d.PositiveFrameCount, 
		d.OtherCopyCount, 
		d.Transcription, 
		d.Notes,
		d.AvailabilityStatusCode,
		ast.Text as AvailabilityStatusText,
		case when (select IsNull(count(A.Id),0) from v_PublicDigitalObjects A 
				  where A.DocumentSystemIdentifier = d.SystemIdentifier 
				  and A.IsDraft = 0 
				  and A.IsDigitized = 1) > 0 
			 then CAST(1 AS bit) else CAST(0 AS bit) end as HasDigitizedDigitalObjects
	FROM dbo.Documents AS d 
		INNER JOIN dbo.Archives AS a ON d.ArchiveId = a.Id 
		INNER JOIN dbo.Funds AS f ON d.FundSystemIdentifier = f.SystemIdentifier
		INNER JOIN dbo.Inventories AS i ON d.InventorySystemIdentifier = i.SystemIdentifier 
		INNER JOIN dbo.ArchivalEntities AS ae ON d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier
		LEFT JOIN N.DocumentDescriptionLevel AS l ON d.DescriptionLevelCode = l.Code 
		LEFT JOIN N.Status AS s ON d.StatusCode = s.Code 
		LEFT JOIN dbo.AspNetUsers AS cu ON d.CreatedBy = cu.Id
		LEFT JOIN dbo.AspNetUsers AS uu ON d.UpdatedBy = uu.Id
		LEFT JOIN dbo.AspNetUsers AS du ON d.CreatedBy = du.Id
		LEFT JOIN N.AvailabilityStatus ast ON d.AvailabilityStatusCode = ast.Code
	WHERE f.IsSuspended = 0
	AND d.StatusCode <> 12 --статус отчислен
GO





CREATE OR ALTER VIEW [dbo].[v_PublicArchivalEntities] AS
	SELECT 
		ae.Id, 
		ae.SystemIdentifier, 
		CAST(0 AS bit) AS IsDraft,
		ae.ArchiveId, 
		a.Code AS ArchiveCode,
		a.Name AS ArchiveName,
		NULL AS FundDraftId,
		ae.FundSystemIdentifier,
		f.Number AS FundNumber, 
        f.HasExternalSource AS FundHasExternalSource,
		f.ExternalIdentifier AS FundExternalIdentifier,
		NULL AS InventoryDraftId, 
		ae.InventorySystemIdentifier, 
		i.Number AS InventoryNumber, 
        i.HasExternalSource AS InventoryHasExternalSource, 
		i.ExternalIdentifier AS InventoryExternalIdentifier, 
		ae.CreatedOn, 
		ae.CreatedBy, 
		cu.DisplayName AS CreatedByDisplayName, 
		cu.UserName AS CreatedByUserName, 
		ae.UpdatedOn, 
        ae.UpdatedBy, 
		uu.DisplayName AS UpdatedByDisplayName,
		uu.UserName AS UpdatedByUserName, 
		ae.Deleted, 
		ae.DeletedOn,
		ae.DeletedBy, 
		du.DisplayName AS DeletedByDisplayName, 
		du.UserName AS DeletedByUserName, 
        ae.HasExternalSource, 
		ae.ExternalIdentifier, 
		ae.ExternalSourceUpdatedOn, 
		ae.Number,
		ae.Title, 
		ae.DescriptionLevelCode, 
		l.Text AS DescriptionLevelText, 
		ae.StatusCode,
		s.Text AS StatusText, 
		ae.HasNoChronologicalScope, 
        ae.StartDateYear,
		ae.StartDateMonth, 
		ae.StartDateDay, 
		ae.EndDateYear, 
		ae.EndDateMonth, 
		ae.EndDateDay, 
		ae.ApproxmateChronologicalScope, 
		ae.Author, 
		ae.Location, 
		ae.Bytes,
		ae.SheetCount, 
		ae.TapeCount,
		ae.MicrofilmCount, 
        ae.FrameCount,
		ae.VideoTapeCount,
		ae.DigitalDeviceCount,
		ae.OtherMetrics, 
		ae.SizeCm, 
		ae.Scaling, 
		ae.Description, 
		ae.DocumentsAccessDescription, 
		ae.Features, 
		ae.Condition, 
		ae.MicrofilmedCopyCount, 
		ae.DigitizedCopyCount, 
        ae.PaperCopyCount,
		ae.NegativeFrameCount, 
		ae.PositiveFrameCount,
		ae.OtherCopyCount, 
		ae.Notes, 
		ae.EnrolledBytes, 
		ae.EnrolledDocumentCount, 
		ae.EnrolledLinearMeters, 
		ae.DeductedBytes,
		ae.DeductedDocumentCount, 
        ae.DeductedLinearMeters, 
		f.NumberNumeric as FundNumberNumeric, 
		i.NumberNumeric as InventoryNumberNumeric, 
		ae.NumberNumeric,
		ae.NumberArray,
		ast.Text as AvailabilityStatusText, 
		i.AvailabilityStatusCode,
		IsNull(
		(select top 1 HasDigitizedDigitalObjects from v_PublicDocuments doc 
		where doc.ArchivalEntitySystemIdentifier = ae.SystemIdentifier 
		and IsDraft = 0 and Deleted = 0
		and HasDigitizedDigitalObjects = 1), 0) HasDigitizedDigitalObjects

	FROM dbo.ArchivalEntities AS ae
		INNER JOIN dbo.Archives AS a ON ae.ArchiveId = a.Id 
		INNER JOIN dbo.Funds AS f ON ae.FundSystemIdentifier = f.SystemIdentifier
		INNER JOIN dbo.Inventories AS i ON ae.InventorySystemIdentifier = i.SystemIdentifier 
		LEFT OUTER JOIN N.ArchivalEntityDescriptionLevel AS l ON ae.DescriptionLevelCode = l.Code 
		LEFT OUTER JOIN N.Status AS s ON ae.StatusCode = s.Code
		LEFT OUTER JOIN dbo.AspNetUsers AS cu ON ae.CreatedBy = cu.Id 
		LEFT OUTER JOIN dbo.AspNetUsers AS uu ON ae.UpdatedBy = uu.Id 
		LEFT OUTER JOIN dbo.AspNetUsers AS du ON ae.CreatedBy = du.Id
		LEFT JOIN N.AvailabilityStatus ast ON ae.AvailabilityStatusCode = ast.Code
	WHERE f.IsSuspended = 0
	AND ae.StatusCode <> 12 --статус отчислен
GO




CREATE OR ALTER     view [dbo].[v_Documents]
AS

SELECT d.Id
	  ,d.SystemIdentifier
      ,CAST(0 as bit) as IsDraft
	  ,d.IsSuspended
      ,d.ArchiveId
      ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,NULL as FundDraftId
      ,d.FundSystemIdentifier
      ,f.Number as FundNumber
	  ,f.NumberNumeric as FundNumberNumeric
	  ,f.NumberArray as FundNumberArray
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
	  ,f.DescriptionLevelCode as FundDescriptionLevelCode
	  ,f.StatusCode as FundStatusCode
      ,NULL as InventoryDraftId
      ,d.InventorySystemIdentifier
	  ,i.Number as InventoryNumber
	  ,i.NumberNumeric as InventoryNumberNumeric
	  ,i.NumberArray as InventoryNumberArray
	  ,i.HasExternalSource as InventoryHasExternalSource
	  ,i.ExternalIdentifier as InventoryExternalIdentifier
	  ,i.AvailabilityStatusCode  as InventoryAvailabilityStatusCode
	  ,i.DescriptionLevelCode as InventoryDescriptionLevelCode
	  ,i.StatusCode as InventoryStatusCode
	  ,NULL as ArchivalEntityDraftId
      ,d.ArchivalEntitySystemIdentifier
	  ,ae.Number as ArchivalEntityNumber
	  ,ae.NumberNumeric AS ArchivalEntityNumberNumeric
	  ,ae.NumberArray as ArchivalEntityNumberArray
	  ,ae.HasExternalSource as ArchivalEntityHasExternalSource
	  ,ae.ExternalIdentifier as ArchivalEntityExternalIdentifier
	  ,ae.AvailabilityStatusCode as ArchivalEntityAvailabilityStatusCode
	  ,ae.DescriptionLevelCode as ArchivalEntityDescriptionLevelCode
	  ,ae.StatusCode as ArchivalEntityStatusCode
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
      ,d.Title
      ,d.DescriptionLevelCode
	  ,l.Text as DescriptionLevelText
	  ,d.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
      ,d.StatusCode
	  ,s.Text as StatusText
	  ,d.FileFormatCode
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
	  ,d.StartSheetNumber
	  ,d.EndSheetNumber
	  ,d.DigitalDevice
	  ,d.OtherMetrics
	  ,d.SizeCm
	  ,d.Scaling
	  ,d.Duration
	  ,d.Description
	  ,d.DocumentsAccessDescription
	  ,d.Features
	  ,d.MicrofilmedCopyCount
	  ,d.DigitizedCopyCount
	  ,d.PaperCopyCount
	  ,d.NegativeFrameCount
	  ,d.PositiveFrameCount
	  ,d.OtherCopyCount
	  ,d.Transcription
	  ,d.Notes
	  ,d.IsImported
	  ,d.DescriptionAuthor
	  ,d.Cypher
	  ,d.TextDocsCount
	  ,d.GraphicalDocsCount
	  ,d.Phase
	  ,d.Part
	  ,d.Stage
	  ,d.OtherLanguage
	  , case when (select IsNull(count(A.Id),0) from v_DigitalObjects A 
				  where A.DocumentSystemIdentifier = d.SystemIdentifier 
				  and A.IsDraft = 0 
				  and A.IsDigitized = 1) > 0 
			 then CAST(1 as bit) else CAST(0 as bit) end as HasDigitizedDigitalObjects

  FROM dbo.Documents d
  JOIN dbo.Archives a ON d.ArchiveId = a.Id
  JOIN dbo.Funds f ON d.FundSystemIdentifier = f.SystemIdentifier
  JOIN dbo.Inventories i ON d.InventorySystemIdentifier = i.SystemIdentifier
  JOIN dbo.ArchivalEntities ae ON d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier 
  LEFT JOIN dbo.DocumentDrafts dd on d.SystemIdentifier = dd.SystemIdentifier and dd.IsCurrent = 1
  LEFT JOIN N.DocumentDescriptionLevel l ON d.DescriptionLevelCode = l.Code
  LEFT JOIN N.AvailabilityStatus ast ON d.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON d.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON d.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON d.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON d.CreatedBy = du.Id
 WHERE dd.Id IS NULL


 UNION

 
 SELECT dd.Id
	   ,dd.SystemIdentifier
       ,CAST(1 as bit) as IsDraft
	   ,CAST(0 as bit) as IsSuspended
       ,dd.ArchiveId
       ,a.Code as ArchiveCode
	   ,a.Name as ArchiveName
	   ,dd.FundDraftId
       ,dd.FundSystemIdentifier
       ,f.Number as FundNumber
	   ,f.NumberNumeric AS FundNumberNumeric
	   ,f.NumberArray as FundNumberArray
	   ,f.HasExternalSource as FundHasExternalSource
	   ,f.ExternalIdentifier as FundExternalIdentifier
	   ,f.DescriptionLevelCode as FundDescriptionLevelCode
	   ,f.StatusCode as FundStatusCode
       ,dd.InventoryDraftId
       ,dd.InventorySystemIdentifier
	   ,i.Number as InventoryNumber
	   ,i.NumberNumeric AS InventoryNumberNumeric
	   ,i.NumberArray as InventoryNumberArray
	   ,i.HasExternalSource as InventoryHasExternalSource
	   ,i.ExternalIdentifier as InventoryExternalIdentifier
	   ,i.AvailabilityStatusCode as InventoryAvailabilityStatusCode
	   ,i.DescriptionLevelCode as InventoryDescriptionLevelCode
	   ,i.StatusCode as InventoryStatusCode
	   ,dd.ArchivalEntityDraftId
       ,dd.ArchivalEntitySystemIdentifier
	   ,ae.Number as ArchivalEntityNumber
	   ,ae.NumberNumeric AS ArchivalEntityNumberNumeric
	   ,ae.NumberArray as ArchivalEntityNumberArray
	   ,ae.HasExternalSource as ArchivalEntityHasExternalSource
	   ,ae.ExternalIdentifier as ArchivalEntityExternalIdentifier
	   ,ae.AvailabilityStatusCode as ArchivalEntityAvailabilityStatusCode
	   ,ae.DescriptionLevelCode as ArchivalEntityDescriptionLevelCode
	   ,ae.StatusCode as ArchivalEntityStatusCode
	   ,dd.CreatedOn
       ,dd.CreatedBy
       ,cu.DisplayName as CreatedByDisplayName
	   ,cu.UserName as CreatedByUserName
	   ,dd.UpdatedOn
       ,dd.UpdatedBy
       ,uu.DisplayName as UpdatedByDisplayName
	   ,uu.UserName as UpdatedByUserName
       ,dd.Deleted
       ,dd.DeletedOn
       ,dd.DeletedBy
       ,du.DisplayName as DeletedByDisplayName
	   ,du.UserName as DeletedByUserName
       ,dd.HasExternalSource
       ,dd.ExternalIdentifier
       ,dd.ExternalSourceUpdatedOn
       ,dd.Number
       ,dd.Title
       ,dd.DescriptionLevelCode
	   ,l.Text as DescriptionLevelText
	   ,dd.AvailabilityStatusCode
	   ,ast.Text as AvailabilityStatusText
       ,dd.StatusCode
	   ,s.Text as StatusText
	   ,dd.FileFormatCode
	   ,dd.HasNoChronologicalScope
	   ,dd.StartDateYear
	   ,dd.StartDateMonth
	   ,dd.StartDateDay
	   ,dd.EndDateYear
	   ,dd.EndDateMonth
	   ,dd.EndDateDay
	   ,dd.ApproxmateChronologicalScope
	   ,dd.Author
	   ,dd.Location
	   ,dd.Bytes
	   ,dd.SheetCount
	   ,dd.StartSheetNumber
	   ,dd.EndSheetNumber
	   ,dd.DigitalDevice
	   ,dd.OtherMetrics
	   ,dd.SizeCm
	   ,dd.Scaling
	   ,dd.Duration
	   ,dd.Description
	   ,dd.DocumentsAccessDescription
	   ,dd.Features
	   ,dd.MicrofilmedCopyCount
	   ,dd.DigitizedCopyCount
	   ,dd.PaperCopyCount
	   ,dd.NegativeFrameCount
	   ,dd.PositiveFrameCount
	   ,dd.OtherCopyCount
	   ,dd.Transcription
	   ,dd.Notes
	   ,dd.IsImported
	   ,dd.DescriptionAuthor
	   ,dd.Cypher
	   ,dd.TextDocsCount
	   ,dd.GraphicalDocsCount
	   ,dd.Phase
	   ,dd.Part
	   ,dd.Stage
	   ,dd.OtherLanguage
	   ,CAST(0 as bit) as HasDigitizedDigitalObjects

  FROM dbo.DocumentDrafts dd
  JOIN dbo.Archives a ON dd.ArchiveId = a.Id
  LEFT JOIN dbo.Funds f ON dd.FundSystemIdentifier = f.SystemIdentifier
  LEFT JOIN dbo.FundDrafts fd ON dd.FundSystemIdentifier = fd.SystemIdentifier AND dd.FundDraftId = fd.Id 
  LEFT JOIN dbo.Inventories i ON dd.InventorySystemIdentifier = i.SystemIdentifier 
  LEFT JOIN dbo.InventoryDrafts id ON dd.InventorySystemIdentifier = id.SystemIdentifier AND dd.InventoryDraftId = id.Id
  LEFT JOIN dbo.ArchivalEntities ae ON dd.ArchivalEntitySystemIdentifier = ae.SystemIdentifier
  LEFT JOIN dbo.ArchivalEntityDrafts aed ON dd.ArchivalEntitySystemIdentifier = aed.SystemIdentifier AND dd.ArchivalEntityDraftId = aed.Id
  LEFT JOIN N.DocumentDescriptionLevel l ON dd.DescriptionLevelCode = l.Code
  LEFT JOIN N.AvailabilityStatus ast ON dd.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON dd.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON dd.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON dd.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON dd.CreatedBy = du.Id
 WHERE dd.IsCurrent = 1
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
	  , IsNull(
		(select top 1 HasDigitizedDigitalObjects from v_Documents doc 
		where doc.ArchivalEntitySystemIdentifier = ae.SystemIdentifier 
		and IsDraft = 0 and Deleted = 0
		and HasDigitizedDigitalObjects = 1), 0) HasDigitizedDigitalObjects

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
	  ,CAST(0 as bit) as HasDigitizedDigitalObjects


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

--20240516
--Search component

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
	@SearchFileContent bit null = 0,
	@FileDbName nvarchar(50) = null,
	@FileBufferDbName nvarchar(50) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	declare @offset int = (@Page - 1) * @RowsOfPage;

	DECLARE @resultColumnsDeclaration NVARCHAR(MAX) = '
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
		EntityTypeOrder INT,
		HasDigitizedDigitalObjects BIT NULL,
		DocumentNumber nvarchar(256) NULL
	';

	DECLARE @resultColumns NVARCHAR(MAX) = '
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
		EntityTypeOrder,
		HasDigitizedDigitalObjects,
		DocumentNumber
	';

	DECLARE @keyWordsColumn NVARCHAR(MAX) = '';
	IF @KeyWords IS NULL SET @keyWordsColumn = 'NULL' 
	ELSE SET @keyWordsColumn = '''' + @KeyWords + '''';

	DECLARE @toDateColumn NVARCHAR(MAX) = '';
	IF @ToDate IS NULL SET @toDateColumn = 'NULL' 
	ELSE SET @toDateColumn = '''' + @ToDate + '''';

	DECLARE @fromDateColumn NVARCHAR(MAX) = '';
	IF @FromDate IS NULL SET @fromDateColumn = 'NULL' 
	ELSE SET @fromDateColumn = '''' + @FromDate + '''';

	DECLARE @titleColumn NVARCHAR(MAX) = '';
	IF @Title IS NULL SET @titleColumn = 'NULL' 
	ELSE SET @titleColumn = '''' + @Title + '''';

	DECLARE @fundNumberColumn NVARCHAR(MAX) = '';
	IF @FundNumber IS NULL SET @fundNumberColumn = 'NULL' 
	ELSE SET @fundNumberColumn = '''' + @FundNumber + '''';

	DECLARE @inventoryNumberColumn NVARCHAR(MAX) = '';
	IF @InventoryNumber IS NULL SET @inventoryNumberColumn = 'NULL' 
	ELSE SET @inventoryNumberColumn = '''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberColumn NVARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NULL SET @archivalEntityNumberColumn = 'NULL' 
	ELSE SET @archivalEntityNumberColumn = '''' + @ArchivalEntityNumber + '''';

	DECLARE @kmfNumberColumn NVARCHAR(MAX) = '';
	IF @KMFNumber IS NULL SET @kmfNumberColumn = 'NULL' 
	ELSE SET @kmfNumberColumn = '''' + @KMFNumber + '''';

	DECLARE @searchDigitalObjectColumn NVARCHAR(MAX) = '';
	IF @SearchDigitalObject IS NULL SET @searchDigitalObjectColumn = 'NULL' 
	ELSE SET @searchDigitalObjectColumn = convert(varchar(1), @searchDigitalObject, 104);

	DECLARE @searchDraftsColumn NVARCHAR(MAX) = '';
	IF @SearchDrafts IS NULL SET @searchDraftsColumn = 'NULL' 
	ELSE SET @searchDraftsColumn = convert(varchar(1), @SearchDrafts, 104);

	DECLARE @extendedSearchColumn NVARCHAR(MAX) = '';
	IF @ExtendedSearch IS NULL SET @extendedSearchColumn = 'NULL' 
	ELSE SET @extendedSearchColumn = convert(varchar(1), @ExtendedSearch, 104);

	DECLARE @entityTypesArr TABLE (element NVARCHAR(50) NULL); 
	INSERT INTO @entityTypesArr SELECT element from dbo.SplitString(@EntityType, ',');

	--if no description levels are selected or all description levels are selected search is executed for all description levels
	DECLARE @searchAllDescriptionLevels BIT = 0;
	IF (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal = '-999' OR @FundDescriptionLevelCodesInternal = '-111')
		AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal = '-999' OR @InventoryDescriptionLevelCodesInternal = '-111')
		AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal = '-999' OR @ArchivalEntityDescriptionLevelCodesInternal = '-111')
		AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal = '-999' OR @DocumentDescriptionLevelCodesInternal = '-111')
		AND (@LevelOfDescriptionGids IS NULL OR @LevelOfDescriptionGids = '-999' OR @LevelOfDescriptionGids = '-111')
	BEGIN
		SET @searchAllDescriptionLevels = 1;
	END
		
	
	DECLARE @includeLocalFunds BIT = 0;
	IF 'fund' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFunds = 1;

	DECLARE @FundLevelOfDescriptionGids TABLE (Gid INT NOT NULL);
	INSERT INTO @FundLevelOfDescriptionGids (Gid) -- нива на описание за фонд от ИСДА
	VALUES (20) -- Фонд
		,(21) -- ЧП
		,(22) -- Спомен
		,(91); -- Фонд с необраб. документи

	DECLARE @searchFunds BIT = 0;
	DECLARE @fundsInsert NVARCHAR(MAX) = '';
		
	IF (EXISTS(SELECT Code FROM N.FundDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@FundDescriptionLevelCodesInternal, ',')))
		OR	EXISTS(SELECT Gid FROM @FundLevelOfDescriptionGids INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ',')))) -- избрано е ниво на описание за фонд
	   OR (@searchAllDescriptionLevels = 1 
			AND (@FundNumber IS NOT NULL 
				AND @InventoryNumber IS NULL 
				AND @ArchivalEntityNumber IS NULL 
				AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
				AND @KMFNumber IS NULL)) -- попълнен е само номер на фонд (извежда фонд и всички нива надолу)
	BEGIN
		SET @searchFunds = 1;
	END
	
	--20240510
	--IF  @InventoryNumber IS NULL 
	--	AND @ArchivalEntityNumber IS NULL 
	--	AND @KMFNumber IS NULL 
	--	AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999' OR @InventoryDescriptionLevelCodesInternal='-111')
	--	AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999' OR @ArchivalEntityDescriptionLevelCodesInternal='-111')
	--	AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999'  OR @DocumentDescriptionLevelCodesInternal='-111')
	--	AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') 
	IF @searchFunds = 1
	BEGIN	
		SET @fundsInsert = N'
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
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFunds) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
		';
	END

	DECLARE @includeLocalIventories BIT = 0;
	IF 'inventory' IN (SELECT element FROM @entityTypesArr) SET @includeLocalIventories = 1;
	
	DECLARE @LevelOfDescriptionGidsOfInventory TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfInventory (Gid) -- нива на описание за опис от ИСДА
	VALUES (2171) -- Инвентарен опис
		  ,(2172) -- Груб опис
		  ,(2372); -- Служебен опис
		  --,(2369); -- Инвентарен номер (КМФ)

	DECLARE @searchInventories BIT = 0;
	DECLARE @inventoriesInsert VARCHAR(MAX) = '';
	
	IF (EXISTS(SELECT Code FROM N.InventoryDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@InventoryDescriptionLevelCodesInternal, ',')))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfInventory INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ',')))) -- избрано е ниво на описание за опис
		OR (@searchAllDescriptionLevels = 1
			AND (@InventoryNumber IS NOT NULL 
				AND @ArchivalEntityNumber IS NULL 
				AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
				AND @KMFNumber IS NULL)) -- попълнен е само номер на опис (извежда опис и всички нива надолу)
	BEGIN
		SET @searchInventories = 1;
	END
	
	
	--20240510
	--IF (@FundNumber IS NOT NULL
	--	AND @ArchivalEntityNumber IS NULL 
	--	AND @KMFNumber IS NULL
	--	AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
	--	AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999')
	--	AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999')
	--	AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
	--	OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfInventory INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) 
	--	OR @InventoryNumber IS NOT NULL
	--	OR EXISTS(SELECT Code FROM N.InventoryDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@InventoryDescriptionLevelCodesInternal, ',')))
	IF @searchInventories = 1
	BEGIN
		SET @inventoriesInsert = N'
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
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalIventories) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
		'
	END

	DECLARE @LevelOfDescriptionGidsOfArchivalEntities TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfArchivalEntities (Gid) -- нива на описание за АЕ от ИСДА
	VALUES (2174) -- Архивна единица
		  ,(2373); -- Служебна архивна единица
	
	DECLARE @includeLocalArchivalEntities BIT = 0;
	IF 'archival_entity' IN (SELECT element FROM @entityTypesArr) SET @includeLocalArchivalEntities = 1;
	
	DECLARE @searchArchivalEntities BIT = 0;
	DECLARE @archivalEntitiesInsert VARCHAR(MAX) = '';

	IF (EXISTS(SELECT Code FROM N.ArchivalEntityDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@ArchivalEntityDescriptionLevelCodesInternal, ',')))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfArchivalEntities INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ',')))) -- избрано е ниво на описание за АЕ
	   OR (@searchAllDescriptionLevels = 1 
			AND (@ArchivalEntityNumber IS NOT NULL 
				AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
				AND @KMFNumber IS NULL)) -- попълнен е само номер на AE (извежда AE и всички нива надолу)
	BEGIN
		SET @searchArchivalEntities = 1;
	END


	--20240510
	--IF (@FundNumber IS NOT NULL --AND @ArchivalEntityNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL)
	--	AND @KMFNumber IS NULL
	--	AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
	--	AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999')
	--	AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999')
	--	AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')) 
	--	OR @ArchivalEntityNumber IS NOT NULL
	--	OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfArchivalEntities INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) -- 3493 от DevOps
	--	OR EXISTS(SELECT Code FROM N.ArchivalEntityDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@ArchivalEntityDescriptionLevelCodesInternal, ',')))
	IF @searchArchivalEntities = 1
	BEGIN
		SET @archivalEntitiesInsert = N'
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
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalArchivalEntities) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
		'
	END

	DECLARE @LevelOfDescriptionGidsOfDocuments TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfDocuments (Gid) VALUES (2173); -- ниво на описание за документ от ИСДА

	DECLARE @includeLocalDocuments BIT = 0;
	IF N'document' IN (SELECT element FROM @entityTypesArr) SET @includeLocalDocuments = 1;
	
	DECLARE @searchDocuments BIT = 0;
	DECLARE @documentsInsert NVARCHAR(MAX) = N'';

	IF (EXISTS(SELECT Code FROM N.DocumentDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@DocumentDescriptionLevelCodesInternal, ',')))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfDocuments INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))))
		OR (@searchAllDescriptionLevels = 1
			AND ((@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
				AND @KMFNumber IS NULL))
	BEGIN
		SET @searchDocuments = 1;
	END
	
	--20240510
	--IF 
	--	-- това условие е било сложено нарочно, но искат да отпадне 
	--	--@FundNumber IS NULL AND @InventoryNumber IS NULL AND @ArchivalEntityNumber IS NULL
	--	--AND 
	--	(@KMFNumber IS NULL
	--	AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
	--	AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999')
	--	AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999')
	--	AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
	--	OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfDocuments INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) -- 3493 от DevOps
	--	OR EXISTS(SELECT Code FROM N.DocumentDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@DocumentDescriptionLevelCodesInternal, ',')))
	IF @searchDocuments = 1
	BEGIN
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
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(nvarchar(1), @includeLocalDocuments) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
			'
	END

	DECLARE @LevelOfDescriptionGidsOfFilms TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfFilms (Gid) VALUES (2185); -- ниво на описание КМФ

	DECLARE @includeLocalFilms BIT = 0;
	--20240510
	--IF 'film' IN (SELECT element FROM @entityTypesArr) 
	--	OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilms INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) 
	--	SET @includeLocalFilms = 1;
	IF 'film' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFilms = 1;
	
	DECLARE @searchFilms BIT = 0;
	DECLARE @filmsInsert VARCHAR(MAX) = ''; 
	
	IF ('film' IN (SELECT element FROM @entityTypesArr)
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilms INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))))
		OR (@searchAllDescriptionLevels = 1
			AND (@KMFCountriesOfOriginCodes IS NOT NULL OR @KMFNumber IS NOT NULL)
			AND @FundNumber IS NULL
			AND @InventoryNumber IS NULL
			AND @ArchivalEntityNumber IS NULL)
	BEGIN
		SET @searchFilms = 1;
	END
	
	--20240510
	--IF @FundNumber IS NULL 
	--	AND @InventoryNumber IS NULL
	--	AND @ArchivalEntityNumber IS NULL 
	--	AND @Title IS NULL 
	IF @searchFilms = 1
	BEGIN
		SET @filmsInsert = N'
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
	END

	
	DECLARE @LevelOfDescriptionGidsOfFilmCards TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfFilmCards (Gid) VALUES (2371); -- ниво на описание Архивна единица (КМФ)
	
	DECLARE @includeLocalFilmCards BIT = 0;
	IF 'film_card' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFilmCards = 1;
	
	DECLARE @searchFilmCards BIT = 0;
	DECLARE @filmCardsInsert VARCHAR(MAX) = ''; 	

	IF ('film_card' IN (SELECT element FROM @entityTypesArr)
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilmCards INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))))
		OR (@searchAllDescriptionLevels = 1
			AND (@KMFCountriesOfOriginCodes IS NOT NULL OR @KMFNumber IS NOT NULL)
			AND @FundNumber IS NULL
			AND @InventoryNumber IS NULL
			AND @ArchivalEntityNumber IS NULL)
	BEGIN
		SET @searchFilmCards = 1;
	END
	

	--20240510
	--IF (NOT ((@FundNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL AND @KMFNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL AND @KMFNumber IS NULL)))
	--	OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilmCards INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ',')))
	--	--OR NOT ((@FundNumber IS NOT NULL AND @KMFNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @KMFNumber IS NULL)) 
	IF @searchFilmCards = 1
	BEGIN
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
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFilmCards, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
		';
	END

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
			EntityTypeOrder,
			HasDigitizedDigitalObjects,
			DocumentNumber
		FROM @result
		ORDER BY 
			EntityTypeOrder,
			[Rank] DESC,                                                                                                                               
			ArchiveName ASC,
            FundIntNumber ASC,
			KMFIntNumber ASC,
            FundNumber ASC,
            InventoryIntNumber ASC,
            InventoryNumber ASC,
            ArchivalEntityIntNumber ASC,
            DocumentNumber ASC,
            ArchivalEntityNumber ASC,
			FilmCardIntNumber ASC
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY
		';

	EXEC (@sql);
END
GO




CREATE OR ALTER PROCEDURE [dbo].[SearchKMFForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@KMFNumber nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@ForeignarchivesOnly bit = 0,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@KeyWords nvarchar(MAX) = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	DECLARE @remoteQuery nvarchar(max), @kwds int, @fttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1
		--set @kwdsAnnotated=0;
	--if @KeywordsUIAnnotated is not null and len(@KeywordsUIAnnotated) >=2 set @kwdsAnnotated=1;
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 SET @rankRemote = ',kwds.[Rank] as Rank'; 

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 

	SET @remoteQuery = '';
	SET @remoteQuery = 'with fresults as (';
	set @remoteQuery = @remoteQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''film'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = fund.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		NULL as InventoryNumber,
		NULL as ArchivalEntityNumber,
		fund.Number as KMFNumber,
		NULL as FilmCardNumber,
		fund.Title,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.TypeGid) as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.StatusGid) as StatusText,
		(select Value FROM Nomenclature n WHERE n.Gid= fund.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as FundDescriptionLevelText,
		NULL as InventoryDescriptionLevelText,
		NULL as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) as HasExternalSource,
		fund.LGid as ExternalIdentifier,
		fund.TextDate as FundApproximateChronologicalScope,
		NULL as InventoryApproximateChronologicalScope,
		NULL as ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		Gid AS FundGid,
		NULL as FundIntNumber,
		NULL AS InventoryIntNumber,
		NULL AS ArchivalEntityIntNumber,
		fund.IntNumber AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		fund.Gid,
		fund.LGid'
		+ @rankRemote
		+ ',5 AS EntityTypeOrder
		,0 as HasDigitizedDigitalObjects,
		NULL as DocumentNumber';

	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		from Fund_Active as fund
	'
	else set @remoteQuery = @remoteQuery + '
		from Fund_Modified as fund
	';
	if @kwds = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(Fund,*,'''+ @KeyWords + ''') kwds on fund._id = kwds.[key]
	';
	if @ArchiveGids is not null and @ArchiveGids <> '-999'set @remoteQuery = @remoteQuery + '
		where fund.ArchiveGid in (' + @ArchiveGids + ')
		AND fund.LevelOfDescriptionGid = 2185
	'
	else set @remoteQuery = @remoteQuery + '
		where fund.LevelOfDescriptionGid = 2185
	';
	if @KMFCountriesOfOriginCodes is not null and @KMFCountriesOfOriginCodes <> '-999' 
	begin
		declare @countryCodes nvarchar(max) = N'';

		select @countryCodes = STRING_AGG(CONCAT('''',value,''''), ',') from STRING_SPLIT(@KMFCountriesOfOriginCodes, ',');

		set  @remoteQuery = @remoteQuery + '
			and ((select n.Value2 from Nomenclature n where n.Gid = fund.CountryGid and n.Type = ''FACountry'') in (' + @countryCodes + '))	
		';
	end

	if @KMFNumber is not null set @remoteQuery = @remoteQuery + '
		and (fund.Number = ''' + @KMFNumber + ''')
	';
	if @KMFNumber is not null and @LevelOfDescriptionGids <> '-999' 
		set @remoteQuery = @remoteQuery + '
			and (fund.LevelOfDescriptionGid = 2185)
			'
	else set @remoteQuery = @remoteQuery + '
		and ((fund.LevelOfDescriptionGid in (' + @LevelOfDescriptionGids +')) or -999 in (' + @LevelOfDescriptionGids + '))
	';
	if @ToDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @ToDate +''' >= fund.CreationDate)
	';
	if @FromDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @FromDate + ''' <= fund.CreationDate)
	';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
		and ( fund.FundArrayGid in (' + @FundArrayGids +') ) 
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
			EntityTypeOrder,
			HasDigitizedDigitalObjects,
			DocumentNumber
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
			EntityTypeOrder,
			HasDigitizedDigitalObjects,
			DocumentNumber
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsF.[KEY] as fId, null as fDId, kwdsF.[RANK] as RankKwds
			from freetexttable(Films, *, ''' + @KeyWords + ''') kwdsF
			union 
			select null as fId, kwdsFD.[KEY] as fDId, kwdsFD.[RANK] as RankKwds  
			from freetexttable(FilmDrafts, *, ''' + @KeyWords + ''') kwdsFD
		) kwds
		on (f.Id = kwds.fDId and f.IsDraft = 1) or (f.Id = kwds.fId and f.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 SET @rank = ',RankKwds as Rank'; 

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 SET @rankFilter = ' and RankKwds > 1'; 

	DECLARE @numberFilter VARCHAR(MAX) = '';
	IF @KMFNumber IS NOT NULL SET @numberFilter = ' AND f.InventoryNumber=''' + @KMFNumber + '''';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Films' ELSE SET @table = 'v_PublicFilms';

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			''film'' AS EntityType,
			f.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = f.ArchiveId) as ArchiveName,
			NULL AS FundNumber,
			NULL AS InventoryNumber,
			NULL AS ArchivalEntityNumber,
			convert(varchar(256), f.InventoryNumber, 104) AS KMFNumber,
			NULL AS FilmCardNumber,
			NULL AS Title,
			NULL as TypeText,
			NULL as StatusText,
			NULL as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			NULL as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as ArchivalEntityApproximateChronologicalScope,
			f.SystemIdentifier as FilmSystemIdentifier,
			NULL as FundGid,
			NULL AS FundIntNumber,
			NULL AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			f.InventoryNumber AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			5 as EntityTypeOrder,
			0 as HasDigitizedDigitalObjects,
			NULL as DocumentNumber
		FROM ' + @table + ' f'
		+ @freeTextTableByKwdsJoin + '
		WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @numberFilter + '
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select value from STRING_SPLIT( ''' + @KMFCountriesOfOriginCodes + ''', '',''))) 
				OR (CountryCode in (select value from STRING_SPLIT(''' + @KMFCountriesOfOriginCodes + ''', '',''))))'
			+ @doNotGetAnythingFilter
			+ @rankFilter;


	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NOT NULL,
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
			EntityTypeOrder INT,
			HasDigitizedDigitalObjects BIT NULL,
			DocumentNumber nvarchar(256) NULL
		);

		INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteTable
		UNION
		' +
		@localQuery;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO




CREATE OR ALTER PROCEDURE [dbo].[SearchFilmCardsForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@KMFNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
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
	If @Title is not null and len(@Title) >= 2 set @ttl = 1
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
		''film_card'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = ae.ArchiveGid) AS ArchiveName,
		jf.Number as FundNumber,
		ji.Number as InventoryNumber,
		ae.Number as ArchivalEntityNumber,
		NULL as KMFNumber,
		ae.Number as FilmCardNumber,
		ae.Title as Title,
		NULL as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = ae.StatusGid) as StatusText,
		(select Value FROM Nomenclature n WHERE n.Gid= jf.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as FundDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= ji.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as InventoryDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		ae.LGid AS ExternalIdentifier,
		jf.TextDate AS FundApproximateChronologicalScope,
		ji.TextDate AS InventoryApproximateChronologicalScope,
		ae.TextDate AS ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		jf.Gid AS FundGid,
		jf.IntNumber as FundIntNumber,
		ji.IntNumber AS InventoryIntNumber,
		ae.IntNumber AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		ae.IntNumber AS FilmCardIntNumber,
		ae.Gid,
		ae.LGid'
		+ @rankRemote
		+ ',6 AS EntityTypeOrder
		,0 as HasDigitizedDigitalObjects,
		NULL as DocumentNumber';

	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		from ArchiveEntity_Active as ae
	';
	else set @remoteQuery = @remoteQuery + '
		from ArchiveEntity_Modified as ae
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Inventory_Active ji on ji.LGid=ae.InventoryLGid
	';
	else set @remoteQuery = @remoteQuery + '
		inner join Inventory_Modified ji on ji.LGid=ae.InventoryLGid
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Fund_Active jf on jf.LGid=ae.FundLGid
	';
	else set @remoteQuery = @remoteQuery + '
		inner join Fund_Modified jf on jf.LGid=ae.FundLGid
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
		where 1 = 1';
	if @KMFCountriesOfOriginCodes is not null and @KMFCountriesOfOriginCodes <> '-999' 
	begin
		declare @countryCodes nvarchar(max) = N'';
		select @countryCodes = STRING_AGG(CONCAT('''',value,''''), ',') from STRING_SPLIT(@KMFCountriesOfOriginCodes, ',');
		
		set  @remoteQuery = @remoteQuery + '
			and ((select n.Value2 from Nomenclature n where n.Gid = jf.CountryGid and n.Type = ''FACountry'') in (' + @countryCodes + '))	
		';	
	end

	set @remoteQuery = @remoteQuery + '
		and (jf.LevelOfDescriptionGid = 2185)
		and (ae.LevelOfDescriptionGid = 2371)
	';
	if @KMFNumber is not null or @ArchivalEntityNumber is not null and @LevelOfDescriptionGids <> '-999' set @remoteQuery = @remoteQuery + ''
	else set @remoteQuery = @remoteQuery + '
			and ((ae.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) +') or -999 in (' + @LevelOfDescriptionGids + '))
		';
	--if @ArchivalEntityNumber is not null set @remoteQuery = @remoteQuery + '
		--and (ae.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired = ''3000-01-01'' and [Type] = ''LevelOfDescription'' AND Code = 11)) --Арх.ед. - копия от чужди архиви
	--';
	if @FundNumber is not null set @remoteQuery = @remoteQuery + '
		and (jf.Number = ''' + @FundNumber + ''')
	';
	if @InventoryNumber is not null set @remoteQuery = @remoteQuery + '
		and (ji.Number = ''' + @InventoryNumber + ''')
	';
	if @ArchivalEntityNumber is not null set @remoteQuery = @remoteQuery + '
		and (ae.Number = ''' + @ArchivalEntityNumber + ''')
	';
	if @KMFNumber is not null set @remoteQuery = @remoteQuery + '
		and (ae.Number = ''' + @KMFNumber + ''')
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
		and (jf.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +') 
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
			EntityTypeOrder,
			HasDigitizedDigitalObjects,
			NULL as DocumentNumber
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
			EntityTypeOrder,
			HasDigitizedDigitalObjects,
			DocumentNumber
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsFC.[KEY] as fcId, null as fcDId, kwdsFC.[RANK] as RankKwds
			from freetexttable(FilmCards, *, ''' + @KeyWords + ''') kwdsFC
			union 
			select null as fcId, kwdsFCD.[KEY] as fcDId, kwdsFCD.[RANK] as RankKwds  
			from freetexttable(FilmCardDrafts, *, ''' + @KeyWords + ''') kwdsFCD
		) kwds
		on (c.Id = kwds.fcDId and c.IsDraft = 1) or (c.Id = kwds.fcId and c.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlFC.[KEY] as fcId, null as fcDId, ttlFC.[RANK] as RankTitle   
			from freetexttable(FilmCards, Title, ''' + @Title + ''') ttlFC 
			union 
			select null as fcId, ttlFCD.[KEY] as fcDId, ttlFCD.[RANK] as RankTitle   
			from freetexttable(FilmCardDrafts, Title, ''' + @Title + ''') ttlFCD
		) ttl
		on (c.Id = ttl.fcDId and c.IsDraft = 1) or (c.Id = ttl.fcId and c.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rank = ',ttl.RankTitle as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(ttl.RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and ttl.RankTitle > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(ttl.RankTitle, 0) > 1';

	--DECLARE @kmfCountriesOfOriginCodesFilter VARCHAR(MAX) = '';
	--IF @KMFCountriesOfOriginCodes IS NOT NULL 
	--SET @kmfCountriesOfOriginCodesFilter = ' AND c.CountryId = ''' + @kmfCountriesOfOriginCodesFilter + '''';

	DECLARE @kmfNumberFilter VARCHAR(MAX) = '';
	IF @KMFNumber IS NOT NULL SET @kmfNumberFilter = ' AND c.FilmInventoryNumber=''' + @KMFNumber + '''';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_FilmCards' ELSE SET @table = 'v_PublicFilmCards'; -- къде е v_PublicFilmCards?

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 0 
		OR @FundNumber IS NOT NULL
		OR @InventoryNumber IS NOT NULL
		OR @ArchivalEntityNumber IS NOT NULL 
		SET @doNotGetAnythingFilter = ' AND 1 = 2' 
	ELSE SET @doNotGetAnythingFilter = '';	

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			''film_card'' AS EntityType,
			c.SystemIdentifier,
			(SELECT Name FROM Archives a where a.Id = c.ArchiveId) as ArchiveName,	
			NULL as FundNumber,
			NULL as InventoryNumber,
			NULL as ArchivalEntityNumber,
			c.FilmInventoryNumber as KMFNumber,
			c.InventoryNumber AS KMFNumber,
			c.Title as Title,
			NULL as TypeText,
			NULL as StatusText,
			NULL as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			NULL as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as  ArchivalEntityApproximateChronologicalScope,
			c.FilmSystemIdentifier,
			NULL as FundGid,
			NULL as FundIntNumber,
			NULL AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			c.FilmInventoryNumber AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			6 as EntityTypeOrder,
			0 as HasDigitizedDigitalObjects,
			NULL as DocumentNumber
		FROM ' + @table + ' c'
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE c.ExternalIdentifier IS NULL AND c.HasExternalSource = 0 AND c.Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (c.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(c.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(c.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select value from STRING_SPLIT(''' + @KMFCountriesOfOriginCodes + ''', '',''))) 
				OR (c.CountryCode in (select value from STRING_SPLIT( ''' + @KMFCountriesOfOriginCodes + ''', '',''))))'
			+ @kmfNumberFilter
			+ @doNotGetAnythingFilter
			+ @rankFilter;


	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteFilmCardsTable TABLE (
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
			EntityTypeOrder INT,
			HasDigitizedDigitalObjects BIT NULL,
			DocumentNumber nvarchar(256) NULL
		);

		INSERT INTO @remoteFilmCardsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteFilmCardsTable
		UNION
		' +
		@localQuery;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO



 CREATE OR ALTER PROCEDURE [dbo].[MainSearchComponentInternal]
	@LinkedServer nvarchar(50),
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
	@SearchFileContent bit null = 0,
	@FileDbName nvarchar(50) = null,
	@FileBufferDbName nvarchar(50) = null,
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
		EntityTypeOrder INT,
		DocumentNumber nvarchar(256) NULL
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
		EntityTypeOrder,
		DocumentNumber
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

	--if no description levels are selected or all description levels are selected search is executed for all description levels
	DECLARE @searchAllDescriptionLevels BIT = 0;
	IF (@FundDescriptionLevelCodes IS NULL OR @FundDescriptionLevelCodes = '-999' OR @FundDescriptionLevelCodes = '-111')
		AND (@InventoryDescriptionLevelCodes IS NULL OR @InventoryDescriptionLevelCodes = '-999' OR @InventoryDescriptionLevelCodes = '-111')
		AND (@ArchivalEntityDescriptionLevelCodes IS NULL OR @ArchivalEntityDescriptionLevelCodes = '-999' OR @ArchivalEntityDescriptionLevelCodes = '-111')
		AND (@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes = '-999' OR @DocumentDescriptionLevelCodes = '-111')
	BEGIN
		SET @searchAllDescriptionLevels = 1;
	END

	DECLARE @searchFunds BIT = 0;
	DECLARE @fundsInsert VARCHAR(MAX) = '';

	IF (EXISTS(SELECT Code FROM N.FundDescriptionLevel INTERSECT (SELECT value FROM STRING_SPLIT(@FundDescriptionLevelCodes, ',')))
		OR (@searchAllDescriptionLevels = 1 
			AND (@FundNumber IS NOT NULL 
				AND @InventoryNumber IS NULL 
				AND @ArchivalEntityNumber IS NULL 
				AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
				AND @KMFNumber IS NULL))) -- попълнен е само номер на фонд (извежда фонд и всички нива надолу
	BEGIN
		SET @searchFunds = 1;
	END
	
	--20240515
	--IF (@InventoryNumber IS NULL 
	--	AND @ArchivalEntityNumber IS NULL 
	--	AND @KMFNumber IS NULL
	--	AND(@InventoryDescriptionLevelCodes IS NULL OR @InventoryDescriptionLevelCodes='-999')
	--	AND(@ArchivalEntityDescriptionLevelCodes IS NULL OR @ArchivalEntityDescriptionLevelCodes='-999')
	--	AND(@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999')
	--	AND(@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
	--	OR (EXISTS(SELECT Code FROM N.FundDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@FundDescriptionLevelCodes, ',')))
	--	AND @InventoryNumber IS NULL 
	--	AND @ArchivalEntityNumber IS NULL 
	--	AND @KMFNumber IS NULL
	--	AND(@InventoryDescriptionLevelCodes IS NULL OR @InventoryDescriptionLevelCodes='-999' OR @InventoryDescriptionLevelCodes='-111')
	--	AND(@ArchivalEntityDescriptionLevelCodes IS NULL OR @ArchivalEntityDescriptionLevelCodes='-999' OR @ArchivalEntityDescriptionLevelCodes='-111')
	--	AND(@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999' OR @DocumentDescriptionLevelCodes='-111')
	--	AND(@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
	--	--OR (EXISTS(SELECT Code FROM N.FundDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@FundDescriptionLevelCodes, ','))) AND @FundNumber IS NOT NULL)
	--	AND 'fund' IN (SELECT element FROM @entityTypesArr) 
	IF @searchFunds = 1	
	BEGIN
		SET @fundsInsert = '
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
				@ExtendedSearch = ' + @extendedSearchColumn + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
		';
	END

	DECLARE @searchInventories BIT = 0;
	DECLARE @inventoriesInsert VARCHAR(MAX) = '';

	IF (EXISTS(SELECT Code FROM N.InventoryDescriptionLevel INTERSECT (SELECT value FROM STRING_SPLIT(@InventoryDescriptionLevelCodes, ',')))
		OR (@searchAllDescriptionLevels = 1
			AND (@InventoryNumber IS NOT NULL 
				AND @ArchivalEntityNumber IS NULL 
				AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
				AND @KMFNumber IS NULL))) -- попълнен е само номер на опис (извежда опис и всички нива надолу)
	BEGIN
		SET @searchInventories = 1;
	END
	
	--20240515
	--IF (@FundNumber IS NOT NULL
	--	AND @ArchivalEntityNumber IS NULL 
	--	AND @KMFNumber IS NULL
	--	AND(@FundDescriptionLevelCodes IS NULL OR @FundDescriptionLevelCodes='-999')
	--	AND(@ArchivalEntityDescriptionLevelCodes IS NULL OR @ArchivalEntityDescriptionLevelCodes='-999')
	--	AND(@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999')
	--	AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') 
	--	AND 'inventory' IN (SELECT element FROM @entityTypesArr))
	--	OR (@InventoryNumber IS NOT NULL
	--	AND @ArchivalEntityNumber IS NULL 
	--	AND(@FundDescriptionLevelCodes IS NULL OR @FundDescriptionLevelCodes='-999' OR @FundDescriptionLevelCodes='-111')
	--	AND(@ArchivalEntityDescriptionLevelCodes IS NULL OR @ArchivalEntityDescriptionLevelCodes='-999' OR @ArchivalEntityDescriptionLevelCodes='-111')
	--	AND(@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999' OR @DocumentDescriptionLevelCodes='-111')
	--	AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999' OR @KMFCountriesOfOriginCodes='-111'))
	--	OR EXISTS(SELECT Code FROM N.InventoryDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@InventoryDescriptionLevelCodes, ',')))
	IF @searchInventories = 1
	BEGIN
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
				@ExtendedSearch = ' + @extendedSearchColumn  + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
		';
	END

	DECLARE @searchArchivalEntities BIT = 0;
	DECLARE @archivalEntitiesInsert VARCHAR(MAX) = '';
	
	IF (EXISTS(SELECT Code FROM N.ArchivalEntityDescriptionLevel INTERSECT (SELECT value FROM STRING_SPLIT(@ArchivalEntityDescriptionLevelCodes, ',')))
		OR (@searchAllDescriptionLevels = 1 
			AND (@ArchivalEntityNumber IS NOT NULL 
				AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
				AND @KMFNumber IS NULL))) -- попълнен е само номер на AE (извежда AE и всички нива надолу)
	BEGIN
		SET @searchArchivalEntities = 1;
	END

	--20240515
	--IF ((@FundNumber IS NOT NULL OR @InventoryNumber IS NOT NULL)
	--	AND @KMFNumber IS NULL
	--	AND (@FundDescriptionLevelCodes IS NULL OR @FundDescriptionLevelCodes='-999')
	--	AND (@InventoryDescriptionLevelCodes IS NULL OR @InventoryDescriptionLevelCodes='-999')
	--	AND (@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999')
	--	AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
	--	AND 'archival_entity' IN (SELECT element FROM @entityTypesArr))
	--	OR (@ArchivalEntityNumber IS NOT NULL
	--	AND @KMFNumber IS NULL
	--	AND (@FundDescriptionLevelCodes IS NULL OR @FundDescriptionLevelCodes='-999')
	--	AND (@InventoryDescriptionLevelCodes IS NULL OR @InventoryDescriptionLevelCodes='-999')
	--	AND (@DocumentDescriptionLevelCodes IS NULL OR @DocumentDescriptionLevelCodes='-999')
	--	AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
	--	OR EXISTS(SELECT Code FROM N.ArchivalEntityDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@ArchivalEntityDescriptionLevelCodes, ',')))
	IF @searchArchivalEntities = 1
	BEGIN
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
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
		';
	END

	DECLARE @searchDocuments BIT = 0;
	DECLARE @documentsInsert VARCHAR(MAX) = '';
	
	IF (EXISTS(SELECT Code FROM N.DocumentDescriptionLevel INTERSECT (SELECT value FROM STRING_SPLIT(@DocumentDescriptionLevelCodes, ',')))
		OR (@searchAllDescriptionLevels = 1
			AND ((@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
				AND @KMFNumber IS NULL)))
	BEGIN
		SET @searchDocuments = 1;
	END

	--20240515
	--IF 
	--	-- това условие е било сложено нарочно, но искат да отпадне 
	--	--@FundNumber IS NULL AND @InventoryNumber IS NULL AND @ArchivalEntityNumber IS NULL
	--	--AND 
	--	(@KMFNumber IS NULL
	--	AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
	--	OR EXISTS(SELECT Code FROM N.DocumentDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@DocumentDescriptionLevelCodes, ',')))
	IF @searchDocuments = 1
	BEGIN
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
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
		';
	END

	DECLARE @searchFilms BIT = 0;
	DECLARE @filmsInsert VARCHAR(MAX) = ''; 

	IF ('film' IN (SELECT element FROM @entityTypesArr)
		OR (@searchAllDescriptionLevels = 1
			AND (@KMFCountriesOfOriginCodes IS NOT NULL OR @KMFNumber IS NOT NULL)
			AND @FundNumber IS NULL
			AND @InventoryNumber IS NULL
			AND @ArchivalEntityNumber IS NULL))
	BEGIN
		SET @searchFilms = 1;
	END

	--20240515
	--IF @FundNumber IS NULL 
	--	AND @InventoryNumber IS NULL
	--	AND @ArchivalEntityNumber IS NULL 
	--	AND 'film' IN (SELECT element FROM @entityTypesArr)
	IF @searchFilms = 1
	BEGIN
		SET @filmsInsert = '
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
	END

	DECLARE @searchFilmCards BIT = 0;
	DECLARE @filmCardsInsert VARCHAR(MAX) = ''; 	

	IF ('film_card' IN (SELECT element FROM @entityTypesArr)
		OR (@searchAllDescriptionLevels = 1
			AND (@KMFCountriesOfOriginCodes IS NOT NULL OR @KMFNumber IS NOT NULL)
			AND @FundNumber IS NULL
			AND @InventoryNumber IS NULL
			AND @ArchivalEntityNumber IS NULL))
	BEGIN
		SET @searchFilmCards = 1;
	END

	--20240515
	--IF @FundNumber IS NULL 
	--	AND @InventoryNumber IS NULL 
	--	AND 'film_card' IN (SELECT element FROM @entityTypesArr) 
	IF @searchFilmCards = 1
	BEGIN
		SET @filmCardsInsert = '
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
	END

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
			EntityTypeOrder,
			DocumentNumber
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
            DocumentNumber ASC,
            ArchivalEntityNumber ASC,
			FilmCardIntNumber ASC
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY
		';

	EXEC (@sql);
END
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
	@SearchFileContent bit null = 0,
	@FileDbName nvarchar(50) = null,
	@FileBufferDbName nvarchar(50) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	declare @offset int = (@Page - 1) * @RowsOfPage;

	DECLARE @resultColumnsDeclaration NVARCHAR(MAX) = '
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
		EntityTypeOrder INT,
		HasDigitizedDigitalObjects BIT NULL,
		DocumentNumber nvarchar(256) NULL
	';

	DECLARE @resultColumns NVARCHAR(MAX) = '
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
		EntityTypeOrder,
		HasDigitizedDigitalObjects,
		DocumentNumber
	';

	DECLARE @keyWordsColumn NVARCHAR(MAX) = '';
	IF @KeyWords IS NULL SET @keyWordsColumn = 'NULL' 
	ELSE SET @keyWordsColumn = '''' + @KeyWords + '''';

	DECLARE @toDateColumn NVARCHAR(MAX) = '';
	IF @ToDate IS NULL SET @toDateColumn = 'NULL' 
	ELSE SET @toDateColumn = '''' + @ToDate + '''';

	DECLARE @fromDateColumn NVARCHAR(MAX) = '';
	IF @FromDate IS NULL SET @fromDateColumn = 'NULL' 
	ELSE SET @fromDateColumn = '''' + @FromDate + '''';

	DECLARE @titleColumn NVARCHAR(MAX) = '';
	IF @Title IS NULL SET @titleColumn = 'NULL' 
	ELSE SET @titleColumn = '''' + @Title + '''';

	DECLARE @fundNumberColumn NVARCHAR(MAX) = '';
	IF @FundNumber IS NULL SET @fundNumberColumn = 'NULL' 
	ELSE SET @fundNumberColumn = '''' + @FundNumber + '''';

	DECLARE @inventoryNumberColumn NVARCHAR(MAX) = '';
	IF @InventoryNumber IS NULL SET @inventoryNumberColumn = 'NULL' 
	ELSE SET @inventoryNumberColumn = '''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberColumn NVARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NULL SET @archivalEntityNumberColumn = 'NULL' 
	ELSE SET @archivalEntityNumberColumn = '''' + @ArchivalEntityNumber + '''';

	DECLARE @kmfNumberColumn NVARCHAR(MAX) = '';
	IF @KMFNumber IS NULL SET @kmfNumberColumn = 'NULL' 
	ELSE SET @kmfNumberColumn = '''' + @KMFNumber + '''';

	DECLARE @searchDigitalObjectColumn NVARCHAR(MAX) = '';
	IF @SearchDigitalObject IS NULL SET @searchDigitalObjectColumn = 'NULL' 
	ELSE SET @searchDigitalObjectColumn = convert(varchar(1), @searchDigitalObject, 104);

	DECLARE @searchDraftsColumn NVARCHAR(MAX) = '';
	IF @SearchDrafts IS NULL SET @searchDraftsColumn = 'NULL' 
	ELSE SET @searchDraftsColumn = convert(varchar(1), @SearchDrafts, 104);

	DECLARE @extendedSearchColumn NVARCHAR(MAX) = '';
	IF @ExtendedSearch IS NULL SET @extendedSearchColumn = 'NULL' 
	ELSE SET @extendedSearchColumn = convert(varchar(1), @ExtendedSearch, 104);

	DECLARE @entityTypesArr TABLE (element NVARCHAR(50) NULL); 
	INSERT INTO @entityTypesArr SELECT element from dbo.SplitString(@EntityType, ',');

	--if no description levels are selected or all description levels are selected search is executed for all description levels
	DECLARE @searchAllDescriptionLevels BIT = 0;
	IF (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal = '-999' OR @FundDescriptionLevelCodesInternal = '-111')
		AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal = '-999' OR @InventoryDescriptionLevelCodesInternal = '-111')
		AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal = '-999' OR @ArchivalEntityDescriptionLevelCodesInternal = '-111')
		AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal = '-999' OR @DocumentDescriptionLevelCodesInternal = '-111')
		AND (@LevelOfDescriptionGids IS NULL OR @LevelOfDescriptionGids = '-999' OR @LevelOfDescriptionGids = '-111')
	BEGIN
		SET @searchAllDescriptionLevels = 1;
	END
		
	
	DECLARE @includeLocalFunds BIT = 0;
	IF 'fund' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFunds = 1;

	DECLARE @FundLevelOfDescriptionGids TABLE (Gid INT NOT NULL);
	INSERT INTO @FundLevelOfDescriptionGids (Gid) -- нива на описание за фонд от ИСДА
	VALUES (20) -- Фонд
		,(21) -- ЧП
		,(22) -- Спомен
		,(91); -- Фонд с необраб. документи

	DECLARE @searchFunds BIT = 0;
	DECLARE @fundsInsert NVARCHAR(MAX) = '';
		
	IF (EXISTS(SELECT Code FROM N.FundDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@FundDescriptionLevelCodesInternal, ',')))
		OR	EXISTS(SELECT Gid FROM @FundLevelOfDescriptionGids INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ',')))) -- избрано е ниво на описание за фонд
	   OR (@searchAllDescriptionLevels = 1 
			AND (@FundNumber IS NOT NULL 
				AND @InventoryNumber IS NULL 
				AND @ArchivalEntityNumber IS NULL 
				AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
				AND @KMFNumber IS NULL)) -- попълнен е само номер на фонд (извежда фонд и всички нива надолу)
	BEGIN
		SET @searchFunds = 1;
	END
	
	--20240510
	--IF  @InventoryNumber IS NULL 
	--	AND @ArchivalEntityNumber IS NULL 
	--	AND @KMFNumber IS NULL 
	--	AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999' OR @InventoryDescriptionLevelCodesInternal='-111')
	--	AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999' OR @ArchivalEntityDescriptionLevelCodesInternal='-111')
	--	AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999'  OR @DocumentDescriptionLevelCodesInternal='-111')
	--	AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') 
	IF @searchFunds = 1
	BEGIN	
		SET @fundsInsert = N'
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
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFunds) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
		';

		PRINT 'GET FUNDS';
	END

	DECLARE @includeLocalIventories BIT = 0;
	IF 'inventory' IN (SELECT element FROM @entityTypesArr) SET @includeLocalIventories = 1;
	
	DECLARE @LevelOfDescriptionGidsOfInventory TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfInventory (Gid) -- нива на описание за опис от ИСДА
	VALUES (2171) -- Инвентарен опис
		  ,(2172) -- Груб опис
		  ,(2372) -- Служебен опис
		  ,(2369); -- Инвентарен номер (КМФ)

	DECLARE @searchInventories BIT = 0;
	DECLARE @inventoriesInsert VARCHAR(MAX) = '';
	
	IF (EXISTS(SELECT Code FROM N.InventoryDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@InventoryDescriptionLevelCodesInternal, ',')))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfInventory INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ',')))) -- избрано е ниво на описание за опис
		OR (@searchAllDescriptionLevels = 1
			AND (@InventoryNumber IS NOT NULL 
				AND @ArchivalEntityNumber IS NULL 
				AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
				AND @KMFNumber IS NULL)) -- попълнен е само номер на опис (извежда опис и всички нива надолу)
	BEGIN
		SET @searchInventories = 1;
	END
	
	
	--20240510
	--IF (@FundNumber IS NOT NULL
	--	AND @ArchivalEntityNumber IS NULL 
	--	AND @KMFNumber IS NULL
	--	AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
	--	AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999')
	--	AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999')
	--	AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
	--	OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfInventory INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) 
	--	OR @InventoryNumber IS NOT NULL
	--	OR EXISTS(SELECT Code FROM N.InventoryDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@InventoryDescriptionLevelCodesInternal, ',')))
	IF @searchInventories = 1
	BEGIN
		SET @inventoriesInsert = N'
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
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalIventories) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
		'

		PRINT 'GET INVENTORIES';
	END

	DECLARE @LevelOfDescriptionGidsOfArchivalEntities TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfArchivalEntities (Gid) -- нива на описание за АЕ от ИСДА
	VALUES (2174) -- Архивна единица
		  ,(2373) -- Служебна архивна единица
		  ,(2371); -- ниво на описание Архивна единица (КМФ)
	
	DECLARE @includeLocalArchivalEntities BIT = 0;
	IF 'archival_entity' IN (SELECT element FROM @entityTypesArr) SET @includeLocalArchivalEntities = 1;
	
	DECLARE @searchArchivalEntities BIT = 0;
	DECLARE @archivalEntitiesInsert VARCHAR(MAX) = '';

	IF (EXISTS(SELECT Code FROM N.ArchivalEntityDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@ArchivalEntityDescriptionLevelCodesInternal, ',')))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfArchivalEntities INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ',')))) -- избрано е ниво на описание за АЕ
	   OR (@searchAllDescriptionLevels = 1 
			AND (@ArchivalEntityNumber IS NOT NULL 
				AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
				AND @KMFNumber IS NULL)) -- попълнен е само номер на AE (извежда AE и всички нива надолу)
	BEGIN
		SET @searchArchivalEntities = 1;
	END


	--20240510
	--IF (@FundNumber IS NOT NULL --AND @ArchivalEntityNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL)
	--	AND @KMFNumber IS NULL
	--	AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
	--	AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999')
	--	AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999')
	--	AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')) 
	--	OR @ArchivalEntityNumber IS NOT NULL
	--	OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfArchivalEntities INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) -- 3493 от DevOps
	--	OR EXISTS(SELECT Code FROM N.ArchivalEntityDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@ArchivalEntityDescriptionLevelCodesInternal, ',')))
	IF @searchArchivalEntities = 1
	BEGIN
		SET @archivalEntitiesInsert = N'
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
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalArchivalEntities) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
		'

		PRINT 'GET ARCHIVAL ENTITIES'
	END

	DECLARE @LevelOfDescriptionGidsOfDocuments TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfDocuments (Gid) VALUES (2173); -- ниво на описание за документ от ИСДА

	DECLARE @includeLocalDocuments BIT = 0;
	IF N'document' IN (SELECT element FROM @entityTypesArr) SET @includeLocalDocuments = 1;
	
	DECLARE @searchDocuments BIT = 0;
	DECLARE @documentsInsert NVARCHAR(MAX) = N'';

	IF (EXISTS(SELECT Code FROM N.DocumentDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@DocumentDescriptionLevelCodesInternal, ',')))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfDocuments INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))))
		OR (@searchAllDescriptionLevels = 1
			AND ((@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
				AND @KMFNumber IS NULL))
	BEGIN
		SET @searchDocuments = 1;
	END
	
	--20240510
	--IF 
	--	-- това условие е било сложено нарочно, но искат да отпадне 
	--	--@FundNumber IS NULL AND @InventoryNumber IS NULL AND @ArchivalEntityNumber IS NULL
	--	--AND 
	--	(@KMFNumber IS NULL
	--	AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
	--	AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999')
	--	AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999')
	--	AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
	--	OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfDocuments INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) -- 3493 от DevOps
	--	OR EXISTS(SELECT Code FROM N.DocumentDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@DocumentDescriptionLevelCodesInternal, ',')))
	IF @searchDocuments = 1
	BEGIN
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
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(nvarchar(1), @includeLocalDocuments) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
			'

			PRINT 'GET DOCUMENTS'
	END

	DECLARE @LevelOfDescriptionGidsOfFilms TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfFilms (Gid) VALUES (2185); -- ниво на описание КМФ

	DECLARE @includeLocalFilms BIT = 0;
	--20240510
	--IF 'film' IN (SELECT element FROM @entityTypesArr) 
	--	OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilms INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) 
	--	SET @includeLocalFilms = 1;
	IF 'film' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFilms = 1;
	
	DECLARE @searchFilms BIT = 0;
	DECLARE @filmsInsert VARCHAR(MAX) = ''; 
	
	IF (('film' IN (SELECT element FROM @entityTypesArr)
			AND NOT EXISTS(SELECT value FROM string_split(@LevelOfDescriptionGids, ',') where value = 2369) -- не търсим Инвентарен номер (КМФ)
			AND NOT EXISTS(SELECT value FROM string_split(@LevelOfDescriptionGids, ',') where value = 2371)) -- не търсим Архивна единица (КМФ)
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilms INTERSECT (SELECT value FROM string_split(@LevelOfDescriptionGids, ','))))
		OR (@searchAllDescriptionLevels = 1
			AND (@KMFCountriesOfOriginCodes IS NOT NULL OR @KMFNumber IS NOT NULL)
			AND @FundNumber IS NULL
			AND @InventoryNumber IS NULL
			AND @ArchivalEntityNumber IS NULL)
	BEGIN
		SET @searchFilms = 1;
	END
	
	--20240510
	--IF @FundNumber IS NULL 
	--	AND @InventoryNumber IS NULL
	--	AND @ArchivalEntityNumber IS NULL 
	--	AND @Title IS NULL 
	IF @searchFilms = 1
	BEGIN
		SET @filmsInsert = N'
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
		
		PRINT 'GET FILMS';
	END

	
	DECLARE @LevelOfDescriptionGidsOfFilmCards TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfFilmCards (Gid) VALUES (2371); -- ниво на описание Архивна единица (КМФ)
	
	DECLARE @includeLocalFilmCards BIT = 0;
	IF 'film_card' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFilmCards = 1;
	
	DECLARE @searchFilmCards BIT = 0;
	DECLARE @filmCardsInsert VARCHAR(MAX) = ''; 	

	IF ('film_card' IN (SELECT element FROM @entityTypesArr)
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilmCards INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))))
		OR (@searchAllDescriptionLevels = 1
			AND (@KMFCountriesOfOriginCodes IS NOT NULL OR @KMFNumber IS NOT NULL)
			AND @FundNumber IS NULL
			AND @InventoryNumber IS NULL
			AND @ArchivalEntityNumber IS NULL)
	BEGIN
		SET @searchFilmCards = 1;
	END
	

	--20240510
	--IF (NOT ((@FundNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL AND @KMFNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL AND @KMFNumber IS NULL)))
	--	OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilmCards INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ',')))
	--	--OR NOT ((@FundNumber IS NOT NULL AND @KMFNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @KMFNumber IS NULL)) 
	IF @searchFilmCards = 1
	BEGIN
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
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFilmCards, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
		';

		PRINT 'GET FILM CARDS';
	END

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
			EntityTypeOrder,
			HasDigitizedDigitalObjects,
			DocumentNumber
		FROM @result
		ORDER BY 
			EntityTypeOrder,
			[Rank] DESC,                                                                                                                               
			ArchiveName ASC,
            FundIntNumber ASC,
			KMFIntNumber ASC,
            FundNumber ASC,
            InventoryIntNumber ASC,
            InventoryNumber ASC,
            ArchivalEntityIntNumber ASC,
            DocumentNumber ASC,
            ArchivalEntityNumber ASC,
			FilmCardIntNumber ASC
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY
		';

	EXEC (@sql);
END
GO


--END Search component


-- sgenov App.FileUpload - support new upload type - ED, add deriv/demo to unfinished master files
 IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'AutoGenerateDerivative'
          AND Object_ID = Object_ID(N'dbo.FileUploadQueue'))
BEGIN
    ALTER TABLE dbo.FileUploadQueue
    ADD AutoGenerateDerivative bit
END

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'CreatedGuid'
          AND Object_ID = Object_ID(N'dbo.FileUploadQueue'))
BEGIN
    ALTER TABLE dbo.FileUploadQueue
    ADD CreatedGuid uniqueidentifier
END
GO
UPDATE FileUploadQueue SET CreatedGuid = NEWID() WHERE CreatedGuid IS NULL;
ALTER TABLE dbo.FileUploadQueue ALTER COLUMN CreatedGuid uniqueidentifier NOT NULL;

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'FinishedGuid'
          AND Object_ID = Object_ID(N'dbo.FileUploadQueue'))
BEGIN
    ALTER TABLE dbo.FileUploadQueue
    ADD FinishedGuid uniqueidentifier
END

GO
-- END sgenov App.FileUpload - support new upload type - ED, add deriv/demo to unfinished master files

IF (NOT EXISTS(select object_id from sys.objects where object_id = OBJECT_ID(N'dbo.InformationItems') and type = 'U'))
BEGIN
create table dbo.InformationItems(
	Id int not null constraint PK_InformationItems primary key identity(1,1)
	, Title nvarchar(1000) not null
	, Content nvarchar(max) null
	, StartDate datetime2 not null
	, EndDate datetime2 null
	, Deleted bit not null constraint DF_InformationItems_Deleted default(0)
	, CreatedOn datetime2 null
	, CreatedBy uniqueidentifier null constraint FK_InformationItems_CreatedBy foreign key references dbo.AspNetUsers(Id)
	, UpdatedOn datetime2 null
	, UpdatedBy uniqueidentifier null constraint FK_InformationItems_UpdatedBy foreign key references dbo.AspNetUsers(Id)
	, DeletedOn datetime2 null
	, DeletedBy uniqueidentifier null constraint FK_InformationItems_DeletedBy foreign key references dbo.AspNetUsers(Id)
)
END
go

-- ADD Registered Inventories in v_InventorySizeInfo

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER view [dbo].[v_InventorySizeInfo]
AS

select distinct
	A.SystemIdentifier InventorySystemIdentifier
	, A.FundSystemIdentifier 
	
	, IsNull(A.AvailabilityStatusCode,0) InventoryAvailabilityStatusCode
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledInventory
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedInventory

	, IsNull(sum(D.EnrolledArchivalEntity),0) EnrolledArchivalEntityCount
	, IsNull(sum(D.DeductedArchivalEntity),0) DeductedArchivalEntityCount

	, IsNull(sum(D.EnrolledDocumentCount),0) EnrolledDocumentCount
	, IsNull(sum(D.DeductedDocumentCount),0) DeductedDocumentCount

	, IsNull(sum(D.EnrolledBytes),0) EnrolledBytes
	, IsNull(sum(D.DeductedBytes),0) DeductedBytes
	, (
		select t2.AllSplitAndDistinct from (
			select 
				STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
				from (
					select distinct trim(element) E
					from dbo.SplitString(STRING_AGG(D.FileTypes, '; '), '; ')
				) t1) t2) FileTypes
	, 1 IsDraft
	, 1 IsNormalInventory
	, sum(IsNull(D.TextDocsCount,0)) TextDocsCount
	, sum(IsNull(D.GraphicalDocsCount,0)) GraphicalDocsCount

from 
  InventoryDrafts A
left outer join v_ArchivalEntitySizeInfo D on D.InventorySystemIdentifier = A.SystemIdentifier
where A.Deleted = 0 and A.IsCurrent = 1 and IsNull(A.DescriptionLevelCode,'5') = '5' -- normal inventory
and (D.InventorySystemIdentifier is null or D.IsDraft = 1)
group by A.SystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode

union all

select distinct
	A.SystemIdentifier InventorySystemIdentifier
	, A.FundSystemIdentifier 
	
	, IsNull(A.AvailabilityStatusCode,0) InventoryAvailabilityStatusCode
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledInventory
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedInventory

	, IsNull(sum(D.EnrolledArchivalEntity),0) EnrolledArchivalEntityCount
	, IsNull(sum(D.DeductedArchivalEntity),0) DeductedArchivalEntityCount

	, IsNull(sum(D.EnrolledDocumentCount),0) EnrolledDocumentCount
	, IsNull(sum(D.DeductedDocumentCount),0) DeductedDocumentCount

	, IsNull(sum(D.EnrolledBytes),0) EnrolledBytes
	, IsNull(sum(D.DeductedBytes),0) DeductedBytes
	, (
		select t2.AllSplitAndDistinct from (
			select 
				STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
				from (
					select distinct trim(element) E
					from dbo.SplitString(STRING_AGG(D.FileTypes, '; '), '; ')
				) t1) t2) FileTypes
	, 0 IsDraft
	, 1 IsNormalInventory
	, sum(IsNull(D.TextDocsCount,0)) TextDocsCount
	, sum(IsNull(D.GraphicalDocsCount,0)) GraphicalDocsCount

from 
  Inventories A
left outer join v_ArchivalEntitySizeInfo D on D.InventorySystemIdentifier = A.SystemIdentifier
where A.Deleted = 0 and IsNull(A.DescriptionLevelCode,'5') = '5' -- normal inventory
and (D.InventorySystemIdentifier is null or D.IsDraft = 0)
group by A.SystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode


union all


select distinct
	A.SystemIdentifier InventorySystemIdentifier
	, A.FundSystemIdentifier 
	
	, IsNull(A.AvailabilityStatusCode,0) InventoryAvailabilityStatusCode
	-- 13.04.23 - do not count raw inventories as enrolled or deducted
	--, case when IsNull(A.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledInventory
	--, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedInventory
	, 0 as EnrolledInventory
	, 0 as DeductedInventory

	, 0 EnrolledArchivalEntityCount
	, 0 DeductedArchivalEntityCount

	-- 13.04.23 - files count expected as document count
	--, 0 EnrolledDocumentCount
	--, 0 DeductedDocumentCount
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then IsNull(count(D.Id), 0) else 0 end EnrolledDocumentCount
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then IsNull(count(D.Id), 0) else 0 end DeductedDocumentCount

	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) else 0 end EnrolledBytes
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) else 0 end DeductedBytes
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then STRING_AGG(D.FileType, '; ') else null end FileTypes
	, 1 IsDraft
	, 0 IsNormalInventory
	, 0 TextDocsCount
	, 0 GraphicalDocsCount

from 
  InventoryDrafts A
join PackageDocument D on D.PackageId = A.PackageBId
where A.Deleted = 0 and A.IsCurrent = 1 and (A.DescriptionLevelCode = '6' OR A.DescriptionLevelCode = '12') -- raw inventory
and A.StatusCode in ('1', '2', '10') -- Нов, Регистриран, Необработен
and D.Deleted = 0
group by A.SystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode



union all


select distinct
	A.SystemIdentifier InventorySystemIdentifier
	, A.FundSystemIdentifier 
	
	, IsNull(A.AvailabilityStatusCode,0) InventoryAvailabilityStatusCode
	-- 13.04.23 - do not count raw inventories as enrolled or deducted
	--, case when IsNull(A.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledInventory
	--, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedInventory
	, 0 as EnrolledInventory
	, 0 as DeductedInventory

	, 0 EnrolledArchivalEntityCount
	, 0 DeductedArchivalEntityCount

	-- 13.04.23 - files count expected as document count
	--, 0 EnrolledDocumentCount
	--, 0 DeductedDocumentCount
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then IsNull(count(D.Id), 0) else 0 end EnrolledDocumentCount
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then IsNull(count(D.Id), 0) else 0 end DeductedDocumentCount

	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) else 0 end EnrolledBytes
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) else 0 end DeductedBytes
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then STRING_AGG(D.FileType, '; ') else null end FileTypes
	, 0 IsDraft
	, 0 IsNormalInventory
	, 0 TextDocsCount
	, 0 GraphicalDocsCount

from 
  Inventories A
join PackageDocument D on D.PackageId = A.PackageBId
where A.Deleted = 0 and (A.DescriptionLevelCode = '6' OR A.DescriptionLevelCode = '12') -- raw inventory
and A.StatusCode in ('1', '2', '10') -- Нов, Регистриран, Необработен
and D.Deleted = 0
group by A.SystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode



GO

-- END Add Registered Inventories in v_InventorySizeInfo


-- 4770 ДАА Забележки - Проблем с хронологичен обхват

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetQualityControlReport]
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveCodes nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
	@Employee nvarchar(max) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	DECLARE @condition VARCHAR(MAX) = '
			 AND ((''-999'' in (select element from dbo.SplitString(''' + @Employee  + ''', '',''))) 
				OR (convert(varchar(36), pt.CreatedBy, 104) in (select element from dbo.SplitString(''' + @Employee + ''', '',''))))
			 AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '',''))) 
				OR (convert(varchar(4), do.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			 AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			 AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(pt.CreatedOn as date) >= CONVERT(nvarchar(50),''' + COALESCE(@DateFrom, 'null') + ''', 23)))
			 AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(pt.CreatedOn as date) <= CONVERT(nvarchar(50),''' + COALESCE(@DateTo, 'null') + ''', 23)))
	'

	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT 
		 a.Name as Archive
		,u.DisplayName as Employer
		,SUM(AcceptedDocuments) + SUM(ReturnedDocuments) as CheckedDocuments
		,SUM(AcceptedDo) + SUM(ReturnedDo) as CheckedDo
		,SUM(AcceptedDocuments) as AcceptedDocuments
		,SUM(AcceptedDo) as AcceptedDo
		,SUM(ReturnedDocuments) as ReturnedDocuments
		,SUM(ReturnedDo) as ReturnedDo
     FROM
   (SELECT 
        ISNULL(Returned.ArchiveId, Accepted.ArchiveId) as ArchiveId
	   ,ISNULL(Returned.UserId, Accepted.UserId) as UserId
	   ,ISNULL(COUNT(Accepted.DocumentSystemIdentifier), 0) as AcceptedDocuments
	   ,SUM(ISNULL(Accepted.DoCount, 0)) as AcceptedDo
	   ,ISNULL(COUNT(Returned.DocumentSystemIdentifier), 0) as ReturnedDocuments
	   ,SUM(ISNULL(Returned.DoCount, 0)) as ReturnedDo
	  FROM 
			(SELECT 
	    		 d.SystemIdentifier as DocumentSystemIdentifier
	    		,d.ArchiveId as ArchiveId
	    		,COUNT(do.SystemIdentifier) as DoCount
				,pt.CreatedBy as UserId
	    	   FROM Documents as d
	      LEFT JOIN DigitalObjects as do
	             ON d.SystemIdentifier = do.DocumentSystemIdentifier
			   JOIN Process as p
	    	     ON p.DocumentSystemIdentifier = d.SystemIdentifier
	    	   JOIN ProcessTimeline as pt
	    	     ON p.Id = pt.ProcessId
			   JOIN Archives as a
			     ON a.Id = d.ArchiveId
	    	  WHERE pt.StepTypeId IN (22, 27, 28, 31)
	    	    AND pt.Completed = 1
	       	    AND p.Completed = 0
				' + @condition + '
	       GROUP BY d.SystemIdentifier, d.ArchiveId, pt.CreatedBy) as Returned
 FULL JOIN
			(SELECT 
	    		 d.SystemIdentifier as DocumentSystemIdentifier
	    		,d.ArchiveId as ArchiveId
	    		,COUNT(do.SystemIdentifier) as DoCount
				,pt.CreatedBy as UserId
	    	   FROM Documents as d
	      LEFT JOIN DigitalObjects as do
	             ON d.SystemIdentifier = do.DocumentSystemIdentifier
			   JOIN Process as p
	    	     ON p.DocumentSystemIdentifier = d.SystemIdentifier
	    	   JOIN ProcessTimeline as pt
	    	     ON p.Id = pt.ProcessId
			   JOIN Archives as a
			     ON a.Id = d.ArchiveId
	    	  WHERE pt.StepTypeId IN (56, 57, 58)
		        AND pt.Completed = 1
				' + @condition + '
	       GROUP BY d.SystemIdentifier, d.ArchiveId, pt.CreatedBy) as Accepted
	   ON Returned.documentSystemIdentifier = Accepted.documentSystemIdentifier
 GROUP BY ISNULL(Returned.ArchiveId, Accepted.ArchiveId), ISNULL(Returned.DocumentSystemIdentifier, Accepted.DocumentSystemIdentifier), ISNULL(Returned.DoCount, Accepted.DoCount), ISNULL(Returned.UserId, Accepted.UserId)) as Final
     JOIN Archives as a
	   ON a.Id = Final.ArchiveId
	 JOIN AspNetUsers as u
	   ON Final.UserId = u.Id
 GROUP BY a.Name, u.DisplayName
 ORDER BY Archive, Employer'
	END

	BEGIN
		SET @sql = @localQuery + @sqlFinalPart;
	END

	EXEC (@sql);
END
GO

-- END 4770 ДАА Забележки - Проблем с хронологичен обхват


-- 4777 ДАА Забележки - Без антетката „Служител” / 4778 ДАА Забележки - Липсва инфо за период на справката

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
	@RegisteredFrom datetime2(7) = null,
	@RegisteredTo datetime2(7) = null
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
		SELECT 
			MIN(t.PeriodFrom) as PeriodFrom, 
			MAX(t.PeriodTo) as PeriodTo
		FROM (
		SELECT
			d.DOCreationDate as PeriodFrom,
			d.DOCreationDate as PeriodTo
		FROM Document_Modified as d
		INNER JOIN Archive a ON a.Gid = d.ArchiveGid AND a._retired = ''3000-01-01''
		--inner join Fund_Modified f on f.LGid = d.FundLGid
		--inner join Inventory_Modified i on i.LGid = d.InventoryLGid
		--inner join ArchiveEntity_Modified ae on ae.LGid = d.AELGid
		LEFT OUTER JOIN [Image] img on d.Gid = img.DocumentGid and img._retired = ''3000-01-01''
		WHERE ISNULL(d.HasDigitalObject, 0) = 1
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) '

		IF (@RegisteredFrom IS NOT NULL)
		BEGIN
			SET @remoteQuery += 'AND cast(d.DOCreationDate as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
		END

		IF(@RegisteredTo IS NOT NULL)
		BEGIN
			SET @remoteQuery +='AND cast(d.DOCreationDate as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
		END

		SET @remoteQuery += '
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
			d.ModifiedOn,
			a.Name,
			a.SortOrder
			) as t
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
		SELECT 
			MIN(t.PeriodFrom) as PeriodFrom, 
			MAX(t.PeriodTo) as PeriodTo
		FROM (
		SELECT
			d.CreatedOn as PeriodFrom,
			d.CreatedOn as PeriodTo
		FROM Documents as d
		INNER JOIN Archives a ON a.Id = d.ArchiveId AND a.Deleted = 0
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
			  AND exists(select 1 from DigitalObjects do where d.SystemIdentifier = do.DocumentSystemIdentifier and do.Deleted = 0 and do.IsDigitized =1)
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
			  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))) '

		IF (@RegisteredFrom IS NOT NULL)
		BEGIN
			SET @localQuery += 'AND cast(d.CreatedOn as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
		END

		IF(@RegisteredTo IS NOT NULL)
		BEGIN
			SET @localQuery +='AND cast(d.CreatedOn as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
		END

		SET @localQuery += ') as t'

	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteDigitizedDocumentsTable TABLE (
				PeriodFrom datetime NULL,
				PeriodTo datetime NULL
			);

			INSERT INTO @remoteDigitizedDocumentsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT
				CONVERT(nvarchar(50), MIN(f.PeriodFrom), 23) as PeriodFrom,
				CONVERT(nvarchar(50), MAX(f.PeriodTo), 23) as PeriodTo
			FROM (SELECT * FROM @remoteDigitizedDocumentsTable
			UNION ALL
			' +
			@localQuery + ') as f';
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT 
			CONVERT(nvarchar(50), PeriodFrom, 23) as PeriodFrom,
			CONVERT(nvarchar(50), PeriodTo, 23) as PeriodTo
			FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = 'SELECT
			CONVERT(nvarchar(50), f.PeriodFrom, 23) as PeriodFrom,
			CONVERT(nvarchar(50), f.PeriodTo, 23) as PeriodTo
			FROM (' + @localQuery + ') as f';
	END


	EXEC (@sql);
END
GO
-- END 4777 ДАА Забележки - Без антетката „Служител” / 4778 ДАА Забележки - Липсва инфо за период на справката


-- 4858 Оптимизиране на информация, свързана с имената на потребител
IF EXISTS (SELECT 1
		   FROM sys.columns
		   WHERE name = 'UserProfileType'
		   and object_id = object_id('dbo.AspNetUsers'))
BEGIN
  ALTER TABLE AspNetUsers
  DROP COLUMN UserProfileType
END

IF EXISTS (SELECT 1
		   FROM sys.columns
		   WHERE name = 'DisplayName'
		   and object_id = object_id('dbo.AspNetUsers'))
BEGIN
  ALTER TABLE AspNetUsers
  DROP COLUMN DisplayName
END


GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER view [dbo].[v_ArchivalEntities]
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
      ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,ae.UpdatedOn
      ,ae.UpdatedBy
      ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,ae.Deleted
      ,ae.DeletedOn
      ,ae.DeletedBy
      ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
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
	  , IsNull(
		(select top 1 HasDigitizedDigitalObjects from v_Documents doc 
		where doc.ArchivalEntitySystemIdentifier = ae.SystemIdentifier 
		and IsDraft = 0 and Deleted = 0
		and HasDigitizedDigitalObjects = 1), 0) HasDigitizedDigitalObjects

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
      ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,d.UpdatedOn
      ,d.UpdatedBy
      ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,d.Deleted
      ,d.DeletedOn
      ,d.DeletedBy
      ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
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
	  ,CAST(0 as bit) as HasDigitizedDigitalObjects


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
	  ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,do.UpdatedOn
      ,do.UpdatedBy
	  ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,do.Deleted
      ,do.DeletedOn
      ,do.DeletedBy
	  ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
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
	  ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,dod.UpdatedOn
      ,dod.UpdatedBy
	  ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,dod.Deleted
      ,dod.DeletedOn
      ,dod.DeletedBy
	  ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER  view [dbo].[v_Documents]
AS

SELECT d.Id
	  ,d.SystemIdentifier
      ,CAST(0 as bit) as IsDraft
	  ,d.IsSuspended
      ,d.ArchiveId
      ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,NULL as FundDraftId
      ,d.FundSystemIdentifier
      ,f.Number as FundNumber
	  ,f.NumberNumeric as FundNumberNumeric
	  ,f.NumberArray as FundNumberArray
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
	  ,f.DescriptionLevelCode as FundDescriptionLevelCode
	  ,f.StatusCode as FundStatusCode
      ,NULL as InventoryDraftId
      ,d.InventorySystemIdentifier
	  ,i.Number as InventoryNumber
	  ,i.NumberNumeric as InventoryNumberNumeric
	  ,i.NumberArray as InventoryNumberArray
	  ,i.HasExternalSource as InventoryHasExternalSource
	  ,i.ExternalIdentifier as InventoryExternalIdentifier
	  ,i.AvailabilityStatusCode  as InventoryAvailabilityStatusCode
	  ,i.DescriptionLevelCode as InventoryDescriptionLevelCode
	  ,i.StatusCode as InventoryStatusCode
	  ,NULL as ArchivalEntityDraftId
      ,d.ArchivalEntitySystemIdentifier
	  ,ae.Number as ArchivalEntityNumber
	  ,ae.NumberNumeric AS ArchivalEntityNumberNumeric
	  ,ae.NumberArray as ArchivalEntityNumberArray
	  ,ae.HasExternalSource as ArchivalEntityHasExternalSource
	  ,ae.ExternalIdentifier as ArchivalEntityExternalIdentifier
	  ,ae.AvailabilityStatusCode as ArchivalEntityAvailabilityStatusCode
	  ,ae.DescriptionLevelCode as ArchivalEntityDescriptionLevelCode
	  ,ae.StatusCode as ArchivalEntityStatusCode
	  ,d.CreatedOn
      ,d.CreatedBy
      ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,d.UpdatedOn
      ,d.UpdatedBy
      ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,d.Deleted
      ,d.DeletedOn
      ,d.DeletedBy
      ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,d.HasExternalSource
      ,d.ExternalIdentifier
      ,d.ExternalSourceUpdatedOn
      ,d.Number
      ,d.Title
      ,d.DescriptionLevelCode
	  ,l.Text as DescriptionLevelText
	  ,d.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
      ,d.StatusCode
	  ,s.Text as StatusText
	  ,d.FileFormatCode
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
	  ,d.StartSheetNumber
	  ,d.EndSheetNumber
	  ,d.DigitalDevice
	  ,d.OtherMetrics
	  ,d.SizeCm
	  ,d.Scaling
	  ,d.Duration
	  ,d.Description
	  ,d.DocumentsAccessDescription
	  ,d.Features
	  ,d.MicrofilmedCopyCount
	  ,d.DigitizedCopyCount
	  ,d.PaperCopyCount
	  ,d.NegativeFrameCount
	  ,d.PositiveFrameCount
	  ,d.OtherCopyCount
	  ,d.Transcription
	  ,d.Notes
	  ,d.IsImported
	  ,d.DescriptionAuthor
	  ,d.Cypher
	  ,d.TextDocsCount
	  ,d.GraphicalDocsCount
	  ,d.Phase
	  ,d.Part
	  ,d.Stage
	  ,d.OtherLanguage
	  , case when (select IsNull(count(A.Id),0) from v_DigitalObjects A 
				  where A.DocumentSystemIdentifier = d.SystemIdentifier 
				  and A.IsDraft = 0 
				  and A.IsDigitized = 1) > 0 
			 then CAST(1 as bit) else CAST(0 as bit) end as HasDigitizedDigitalObjects

  FROM dbo.Documents d
  JOIN dbo.Archives a ON d.ArchiveId = a.Id
  JOIN dbo.Funds f ON d.FundSystemIdentifier = f.SystemIdentifier
  JOIN dbo.Inventories i ON d.InventorySystemIdentifier = i.SystemIdentifier
  JOIN dbo.ArchivalEntities ae ON d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier 
  LEFT JOIN dbo.DocumentDrafts dd on d.SystemIdentifier = dd.SystemIdentifier and dd.IsCurrent = 1
  LEFT JOIN N.DocumentDescriptionLevel l ON d.DescriptionLevelCode = l.Code
  LEFT JOIN N.AvailabilityStatus ast ON d.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON d.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON d.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON d.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON d.CreatedBy = du.Id
 WHERE dd.Id IS NULL


 UNION

 
 SELECT dd.Id
	   ,dd.SystemIdentifier
       ,CAST(1 as bit) as IsDraft
	   ,CAST(0 as bit) as IsSuspended
       ,dd.ArchiveId
       ,a.Code as ArchiveCode
	   ,a.Name as ArchiveName
	   ,dd.FundDraftId
       ,dd.FundSystemIdentifier
       ,f.Number as FundNumber
	   ,f.NumberNumeric AS FundNumberNumeric
	   ,f.NumberArray as FundNumberArray
	   ,f.HasExternalSource as FundHasExternalSource
	   ,f.ExternalIdentifier as FundExternalIdentifier
	   ,f.DescriptionLevelCode as FundDescriptionLevelCode
	   ,f.StatusCode as FundStatusCode
       ,dd.InventoryDraftId
       ,dd.InventorySystemIdentifier
	   ,i.Number as InventoryNumber
	   ,i.NumberNumeric AS InventoryNumberNumeric
	   ,i.NumberArray as InventoryNumberArray
	   ,i.HasExternalSource as InventoryHasExternalSource
	   ,i.ExternalIdentifier as InventoryExternalIdentifier
	   ,i.AvailabilityStatusCode as InventoryAvailabilityStatusCode
	   ,i.DescriptionLevelCode as InventoryDescriptionLevelCode
	   ,i.StatusCode as InventoryStatusCode
	   ,dd.ArchivalEntityDraftId
       ,dd.ArchivalEntitySystemIdentifier
	   ,ae.Number as ArchivalEntityNumber
	   ,ae.NumberNumeric AS ArchivalEntityNumberNumeric
	   ,ae.NumberArray as ArchivalEntityNumberArray
	   ,ae.HasExternalSource as ArchivalEntityHasExternalSource
	   ,ae.ExternalIdentifier as ArchivalEntityExternalIdentifier
	   ,ae.AvailabilityStatusCode as ArchivalEntityAvailabilityStatusCode
	   ,ae.DescriptionLevelCode as ArchivalEntityDescriptionLevelCode
	   ,ae.StatusCode as ArchivalEntityStatusCode
	   ,dd.CreatedOn
       ,dd.CreatedBy
       ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	   ,cu.UserName as CreatedByUserName
	   ,dd.UpdatedOn
       ,dd.UpdatedBy
       ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	   ,uu.UserName as UpdatedByUserName
       ,dd.Deleted
       ,dd.DeletedOn
       ,dd.DeletedBy
       ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
	   ,du.UserName as DeletedByUserName
       ,dd.HasExternalSource
       ,dd.ExternalIdentifier
       ,dd.ExternalSourceUpdatedOn
       ,dd.Number
       ,dd.Title
       ,dd.DescriptionLevelCode
	   ,l.Text as DescriptionLevelText
	   ,dd.AvailabilityStatusCode
	   ,ast.Text as AvailabilityStatusText
       ,dd.StatusCode
	   ,s.Text as StatusText
	   ,dd.FileFormatCode
	   ,dd.HasNoChronologicalScope
	   ,dd.StartDateYear
	   ,dd.StartDateMonth
	   ,dd.StartDateDay
	   ,dd.EndDateYear
	   ,dd.EndDateMonth
	   ,dd.EndDateDay
	   ,dd.ApproxmateChronologicalScope
	   ,dd.Author
	   ,dd.Location
	   ,dd.Bytes
	   ,dd.SheetCount
	   ,dd.StartSheetNumber
	   ,dd.EndSheetNumber
	   ,dd.DigitalDevice
	   ,dd.OtherMetrics
	   ,dd.SizeCm
	   ,dd.Scaling
	   ,dd.Duration
	   ,dd.Description
	   ,dd.DocumentsAccessDescription
	   ,dd.Features
	   ,dd.MicrofilmedCopyCount
	   ,dd.DigitizedCopyCount
	   ,dd.PaperCopyCount
	   ,dd.NegativeFrameCount
	   ,dd.PositiveFrameCount
	   ,dd.OtherCopyCount
	   ,dd.Transcription
	   ,dd.Notes
	   ,dd.IsImported
	   ,dd.DescriptionAuthor
	   ,dd.Cypher
	   ,dd.TextDocsCount
	   ,dd.GraphicalDocsCount
	   ,dd.Phase
	   ,dd.Part
	   ,dd.Stage
	   ,dd.OtherLanguage
	   ,CAST(0 as bit) as HasDigitizedDigitalObjects

  FROM dbo.DocumentDrafts dd
  JOIN dbo.Archives a ON dd.ArchiveId = a.Id
  LEFT JOIN dbo.Funds f ON dd.FundSystemIdentifier = f.SystemIdentifier
  LEFT JOIN dbo.FundDrafts fd ON dd.FundSystemIdentifier = fd.SystemIdentifier AND dd.FundDraftId = fd.Id 
  LEFT JOIN dbo.Inventories i ON dd.InventorySystemIdentifier = i.SystemIdentifier 
  LEFT JOIN dbo.InventoryDrafts id ON dd.InventorySystemIdentifier = id.SystemIdentifier AND dd.InventoryDraftId = id.Id
  LEFT JOIN dbo.ArchivalEntities ae ON dd.ArchivalEntitySystemIdentifier = ae.SystemIdentifier
  LEFT JOIN dbo.ArchivalEntityDrafts aed ON dd.ArchivalEntitySystemIdentifier = aed.SystemIdentifier AND dd.ArchivalEntityDraftId = aed.Id
  LEFT JOIN N.DocumentDescriptionLevel l ON dd.DescriptionLevelCode = l.Code
  LEFT JOIN N.AvailabilityStatus ast ON dd.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON dd.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON dd.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON dd.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON dd.CreatedBy = du.Id
 WHERE dd.IsCurrent = 1
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER view [dbo].[v_FilmCards]
AS
SELECT 
	   fd.Id
	  ,fd.SystemIdentifier
	  ,CAST(1 as bit) as IsDraft
      ,fd.ArchiveId
	  ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,fd.FilmSystemIdentifier
      ,fd.CreatedOn
      ,fd.CreatedBy
	  ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,fd.UpdatedOn
      ,fd.UpdatedBy
	  ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,fd.Deleted
      ,fd.DeletedOn
      ,fd.DeletedBy
	  ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,fd.ExternalIdentifier
      ,fd.HasExternalSource
      ,fd.ExternalSourceUpdatedOn

	  ,fd.CountryId
	  ,nc.Text CountryName
	  ,nc.Code CountryCode
	  ,fd.City
	  ,fd.DocumentsCypher
	  ,fd.Title
	  ,fd.ArchiveOriginals
	  ,fd.StartDateDay
	  ,fd.StartDateMonth
	  ,fd.StartDateYear
	  ,fd.EndDateDay
	  ,fd.EndDateMonth
	  ,fd.EndDateYear
	  ,fd.AproximateDate
	  ,fd.FilmingExtentId
	  ,ne.Text FilmingExtentName
	  ,fd.Source
      ,fd.InventoryNumber   
	  ,fid.InventoryNumber as FilmInventoryNumber
      ,fd.FramesCount
      ,fd.MicrofilmNegativeCount
	  ,fd.MicrofilmPositiveCount
	  ,fd.PhotoCopy
	  ,fd.DigitalCopy
	  ,fd.Size
	  ,fd.Other
	  ,fd.Notes
	  ,fd.DocumentsFormat
	  ,fd.DocumentsCharacteristics

    FROM FilmCardDrafts fd
	JOIN Archives a ON fd.ArchiveId = a.Id
	LEFT JOIN FilmDrafts fid on fd.FilmSystemIdentifier = fid.SystemIdentifier and fid.IsCurrent = 1
	LEFT JOIN N.Nomenclatures nc ON nc.Id = fd.CountryId
	LEFT JOIN N.Nomenclatures ne ON ne.Id = fd.FilmingExtentId
	LEFT JOIN AspNetUsers cu ON fd.CreatedBy = cu.Id
	LEFT JOIN AspNetUsers uu ON fd.UpdatedBy = uu.Id
	LEFT JOIN AspNetUsers du ON fd.CreatedBy = du.Id
   WHERE fd.IsCurrent = 1
   UNION
   SELECT 
	   f.Id
	  ,f.SystemIdentifier
	  ,CAST(0 as bit) as IsDraft
      ,f.ArchiveId
	  ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,f.FilmSystemIdentifier
      ,f.CreatedOn
      ,f.CreatedBy
	  ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,f.UpdatedOn
      ,f.UpdatedBy
	  ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,f.Deleted
      ,f.DeletedOn
      ,f.DeletedBy
	  ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,f.ExternalIdentifier
      ,f.HasExternalSource
      ,f.ExternalSourceUpdatedOn

	  ,f.CountryId
	  ,nc.Text CountryName
	  ,nc.Code CountryCode
	  ,f.City
	  ,f.DocumentsCypher
	  ,f.Title
	  ,f.ArchiveOriginals
	  ,f.StartDateDay
	  ,f.StartDateMonth
	  ,f.StartDateYear
	  ,f.EndDateDay
	  ,f.EndDateMonth
	  ,f.EndDateYear
	  ,f.AproximateDate
	  ,f.FilmingExtentId
	  ,ne.Text FilmingExtentName
	  ,f.Source
      ,f.InventoryNumber  
	  ,fi.InventoryNumber as FilmInventoryNumber
      ,f.FramesCount
      ,f.MicrofilmNegativeCount
	  ,f.MicrofilmPositiveCount
	  ,f.PhotoCopy
	  ,f.DigitalCopy
	  ,f.Size
	  ,f.Other
	  ,f.Notes
	  ,f.DocumentsFormat
	  ,f.DocumentsCharacteristics

    FROM FilmCards f
	JOIN Archives a ON f.ArchiveId = a.Id
	LEFT JOIN Films fi on f.FilmSystemIdentifier = fi.SystemIdentifier
	LEFT JOIN FilmCardDrafts fd on f.SystemIdentifier = fd.SystemIdentifier and fd.IsCurrent = 1
	LEFT JOIN N.Nomenclatures nc ON nc.Id = f.CountryId
	LEFT JOIN N.Nomenclatures ne ON ne.Id = f.FilmingExtentId
	LEFT JOIN AspNetUsers cu ON f.CreatedBy = cu.Id
	LEFT JOIN AspNetUsers uu ON f.UpdatedBy = uu.Id
	LEFT JOIN AspNetUsers du ON f.CreatedBy = du.Id
   WHERE fd.id is null
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER view [dbo].[v_FilmReviews]
AS
SELECT fr.Id,
	   fr.SystemIdentifier,
	   fr.CreatedOn,
	   fr.CreatedBy,
	   fr.UpdatedOn,
	   fr.UpdatedBy,
	   fr.Deleted,
	   fr.DeletedOn,
	   fr.DeletedBy,
	   fr.UserId,
	   u.UserName as Username,
	   fr.ReaderName,
	   fr.FilmSystemIdentifier,
	   fr.AccessAllowed,
	   (select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName,
	   cu.UserName as CreatedByUserName,
	   (select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName,
	   uu.UserName as UpdatedByUserName,
	   (select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName,
	   du.UserName as DeletedByUserName,
	   f.InventoryNumber as FilmInventoryNumber,
	   n.[Text] as FilmNumber
FROM FilmReviews as fr
LEFT JOIN AspNetUsers cu ON fr.CreatedBy = cu.Id
LEFT JOIN AspNetUsers uu ON fr.UpdatedBy = uu.Id
LEFT JOIN AspNetUsers du ON fr.DeletedBy = du.Id
LEFT JOIN AspNetUsers u ON fr.UserId = u.Id
LEFT JOIN Films f ON fr.FilmSystemIdentifier = f.SystemIdentifier
LEFT JOIN N.Nomenclatures n ON f.CountryId = n.Id
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER view [dbo].[v_Films]
AS
SELECT 
	   fd.Id
	  ,fd.SystemIdentifier
	  ,CAST(1 as bit) as IsDraft
      ,fd.ArchiveId
	  ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
      ,fd.CreatedOn
      ,fd.CreatedBy
	  ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,fd.UpdatedOn
      ,fd.UpdatedBy
	  ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,fd.Deleted
      ,fd.DeletedOn
      ,fd.DeletedBy
	  ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,fd.ExternalIdentifier
      ,fd.HasExternalSource
      ,fd.ExternalSourceUpdatedOn

      ,fd.InventoryNumber
      ,fd.CountryId
	  ,fc.Text CountryName
	  ,fc.Code CountryCode
      ,fd.FramesCount
      ,fd.MicrofilmNegativeRollsCount
      ,fd.MicrofilmNegativeFramesCount
	  ,fd.MicrofilmPositiveRollsCount
      ,fd.MicrofilmPositiveFramesCount
	  ,fd.PhotoCopy
	  ,fd.DigitalCopy
	  ,fd.Size
	  ,fd.Other
	  ,fd.AcceptedOnDay
	  ,fd.AcceptedOnMonth
	  ,fd.AcceptedOnYear
	  ,fd.Source
	  ,fd.Content
	  ,fd.Notes
	  ,fd.PackageAId
	  ,fd.PackageBId

    FROM FilmDrafts fd
	JOIN Archives a ON fd.ArchiveId = a.Id
	LEFT JOIN N.Nomenclatures fc ON fc.Id = fd.CountryId
	LEFT JOIN AspNetUsers cu ON fd.CreatedBy = cu.Id
	LEFT JOIN AspNetUsers uu ON fd.UpdatedBy = uu.Id
	LEFT JOIN AspNetUsers du ON fd.CreatedBy = du.Id
   WHERE fd.IsCurrent = 1
   UNION
   SELECT 
	   f.Id
	  ,f.SystemIdentifier
	  ,CAST(0 as bit) as IsDraft
      ,f.ArchiveId
	  ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
      ,f.CreatedOn
      ,f.CreatedBy
	  ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,f.UpdatedOn
      ,f.UpdatedBy
	  ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,f.Deleted
      ,f.DeletedOn
      ,f.DeletedBy
	  ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,f.ExternalIdentifier
      ,f.HasExternalSource
      ,f.ExternalSourceUpdatedOn

      ,f.InventoryNumber
      ,f.CountryId
	  ,fc.Text CountryName
	  ,fc.Code CountryCode
      ,f.FramesCount
      ,f.MicrofilmNegativeRollsCount
      ,f.MicrofilmNegativeFramesCount
	  ,f.MicrofilmPositiveRollsCount
      ,f.MicrofilmPositiveFramesCount
	  ,f.PhotoCopy
	  ,f.DigitalCopy
	  ,f.Size
	  ,f.Other
	  ,f.AcceptedOnDay
	  ,f.AcceptedOnMonth
	  ,f.AcceptedOnYear
	  ,f.Source
	  ,f.Content
	  ,f.Notes
	  ,f.PackageAId
	  ,f.PackageBId

    FROM Films f
	JOIN Archives a ON f.ArchiveId = a.Id
	LEFT JOIN FilmDrafts fd on f.SystemIdentifier = fd.SystemIdentifier and fd.IsCurrent = 1
	LEFT JOIN N.Nomenclatures fc ON fc.Id = f.CountryId
	LEFT JOIN AspNetUsers cu ON f.CreatedBy = cu.Id
	LEFT JOIN AspNetUsers uu ON f.UpdatedBy = uu.Id
	LEFT JOIN AspNetUsers du ON f.CreatedBy = du.Id
   WHERE fd.id is null
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   view [dbo].[v_FundReconstructions]
AS

SELECT fr.Id
      ,fr.ProcessId
	  ,fr.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
      ,fr.ArchiveId
      ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,fr.FundSystemIdentifier
	  ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,fr.CreatedOn
      ,fr.CreatedBy
	  ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,fr.UpdatedOn
      ,fr.UpdatedBy
	  ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,fr.Deleted
      ,fr.DeletedOn
      ,fr.DeletedBy
	  ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,fr.SourceInventorySystemIdentifier
	  ,sinv.Number as SourceInventoryNumber
	  ,sinv.DescriptionLevelCode as SourceInventoryDescriptionLevelCode
	  ,sinv.DescriptionLevelText as SourceInventoryDescriptionLevelText
	  ,sinv.AvailabilityStatusCode as SourceInventoryAvailabilityStatusCode
	  ,sinv.AvailabilityStatusText as SourceInventoryAvailabilityStatusText
	  ,sinv.ApproxmateChronologicalScope as SourceInventoryApproximateChronologicalScope
	  ,sinv.HasExternalSource as SourceInventoryHasExternalSource
	  ,sinv.ExternalIdentifier as SourceInventoryExternalIdentifier
      ,fr.SourceArchivalEntitySystemIdentifier
	  ,sae.Number as SourceArchivalEntityNumber
	  ,sae.Title as SourceArchivalEntityTitle
	  ,sae.DescriptionLevelCode as SourceArchivalEntityDescriptionLevelCode
	  ,sae.DescriptionLevelText as SourceArchivalEntityDescriptionLevelText
	  ,sae.AvailabilityStatusCode as SourceArchivalEntityAvailabilityStatusCode
	  ,sae.AvailabilityStatusText as SourceArchivalEntityAvailabilityStatusText
	  ,sae.ApproxmateChronologicalScope as SourceArchivalEntityApproximateChronologicalScope
	  ,sae.HasExternalSource as SourceArchivalEntityHasExternalSource
	  ,sae.ExternalIdentifier as SourceArchivalEntityExternalIdentifier
      ,fr.SourceDocumentSystemIdentifier
	  ,sd.Title as SourceDocumentTitle
	  ,sd.DescriptionLevelCode as SourceDocumentDescriptionLevelCode
	  ,sd.DescriptionLevelText as SourceDocumentDescriptionLevelText
	  ,sd.AvailabilityStatusCode as SourceDocumentAvailabilityStatusCode
	  ,sd.AvailabilityStatusText as SourceDocumentAvailabilityStatusText
	  ,sd.ApproxmateChronologicalScope as SourceDocumentApproxmateChronologicalScope
	  ,sd.HasExternalSource as SourceDocumentHasExternalSource
	  ,sd.ExternalIdentifier as SourceDocumentExternalIdentifier
      ,fr.TargetInventorySystemIdentifier
	  ,tinv.Number as TargetInventoryNumber
	  ,tinv.DescriptionLevelCode as TargetInventoryDescriptionLevelCode
	  ,tinv.DescriptionLevelText as TargetInventoryDescriptionLevelText
	  ,tinv.AvailabilityStatusCode as TargetInventoryAvailabilityStatusCode
	  ,tinv.AvailabilityStatusText as TargetInventoryAvailabilityStatusText
	  ,tinv.ApproxmateChronologicalScope as TargetInventoryApproximateChronologicalScope
      ,fr.TargetArchivalEntitySystemIdentifier
	  ,tae.Number as TargetArchivalEntityNumber
	  ,tae.Title as TargetArchivalEntityTitle
	  ,tae.DescriptionLevelCode as TargetArchivalEntityDescriptionLevelCode
	  ,tae.DescriptionLevelText as TargetArchivalEntityDescriptionLevelText
	  ,tae.AvailabilityStatusCode as TargetArchivalEntityAvailabilityStatusCode
	  ,tae.AvailabilityStatusText as TargetArchivalEntityAvailabilityStatusText
	  ,tae.ApproxmateChronologicalScope as TargetArchivalEntityApproximateChronologicalScope
	  ,tae.HasExternalSource as TargetArchivalEntityHasExternalSource
	  ,tae.ExternalIdentifier as TargetArchivalEntityExternalIdentifier
      ,fr.TargetDocumentSystemIdentifier
	  ,td.Title as TargetDocumentTitle
	  ,td.DescriptionLevelCode as TargetDocumentDescriptionLevelCode
	  ,td.DescriptionLevelText as TargetDocumentDescriptionLevelText
	  ,td.AvailabilityStatusCode as TargetDocumentAvailabilityStatusCode
	  ,td.AvailabilityStatusText as TargetDocumentAvailabilityStatusText
	  ,td.ApproxmateChronologicalScope as TargetDocumentApproxmateChronologicalScope
	  ,td.HasExternalSource as TargetDocumentHasExternalSource
	  ,td.ExternalIdentifier as TargetDocumentExternalIdentifier
      
  FROM dbo.FundReconstructions fr
  JOIN dbo.Archives a ON fr.ArchiveId = a.Id
  JOIN dbo.v_Funds f ON fr.FundSystemIdentifier = f.SystemIdentifier
  LEFT JOIN v_Inventories sinv ON fr.SourceInventorySystemIdentifier = sinv.SystemIdentifier
  LEFT JOIN v_ArchivalEntities sae ON fr.SourceArchivalEntitySystemIdentifier = sae.SystemIdentifier
  LEFT JOIN v_Documents sd ON fr.SourceDocumentSystemIdentifier = sd.SystemIdentifier
  LEFT JOIN v_Inventories tinv ON fr.TargetInventorySystemIdentifier = tinv.SystemIdentifier
  LEFT JOIN v_ArchivalEntities tae ON fr.TargetArchivalEntitySystemIdentifier = tae.SystemIdentifier
  LEFT JOIN v_Documents td ON fr.TargetDocumentSystemIdentifier = td.SystemIdentifier
  LEFT JOIN N.AvailabilityStatus ast ON fr.AvailabilityStatusCode = ast.Code
  LEFT JOIN dbo.AspNetUsers cu ON fr.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON fr.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON fr.CreatedBy = du.Id

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   view [dbo].[v_Funds]
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
	  ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,fd.UpdatedOn
      ,fd.UpdatedBy
	  ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,fd.Deleted
      ,fd.DeletedOn
      ,fd.DeletedBy
	  ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
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
      ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,f.UpdatedOn
      ,f.UpdatedBy
      ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,f.Deleted
      ,f.DeletedOn
      ,f.DeletedBy
      ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   view [dbo].[v_Inventories]
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
      ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,i.UpdatedOn
      ,i.UpdatedBy
      ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,i.Deleted
      ,i.DeletedOn
      ,i.DeletedBy
      ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
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
	  ,i.OtherLanguage
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
      ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,id.UpdatedOn
      ,id.UpdatedBy
      ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,id.Deleted
      ,id.DeletedOn
      ,id.DeletedBy
      ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
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
	  ,id.OtherLanguage
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

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
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
	  ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
      ,do.UpdatedOn
      ,do.UpdatedBy
	  ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,do.Deleted
      ,do.DeletedOn
      ,do.DeletedBy
	  ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
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
	  ,CAST(do.IsDigitized as bit) as IsDigitized
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


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER VIEW [dbo].[v_PublicDocuments] AS
	SELECT 
		d.Id, d.SystemIdentifier,
		CAST(0 AS bit) AS IsDraft,
		d.ArchiveId, 
		a.Code AS ArchiveCode,
		a.Name AS ArchiveName,
		NULL AS FundDraftId, 
		d.FundSystemIdentifier, 
		f.Number AS FundNumber, 
        f.NumberNumeric AS FundNumberNumeric,
		f.NumberArray as FundNumberArray,
		f.HasExternalSource AS FundHasExternalSource, 
		f.ExternalIdentifier AS FundExternalIdentifier,
		f.DescriptionLevelCode AS FundDescriptionLevelCode,
		f.StatusCode AS FundStatusCode,
		NULL AS InventoryDraftId, 
		d.InventorySystemIdentifier, 
		i.Number AS InventoryNumber, 
        i.NumberNumeric AS InventoryNumberNumeric,
		i.NumberArray AS InventoryNumberArray,
		i.HasExternalSource AS InventoryHasExternalSource,
		i.ExternalIdentifier AS InventoryExternalIdentifier,
		i.DescriptionLevelCode AS InventoryDescriptionLevelCode,
		i.StatusCode AS InventoryStatusCode,
		NULL AS ArchivalEntityDraftId, 
		d.ArchivalEntitySystemIdentifier, 
		ae.Number AS ArchivalEntityNumber, 
        ae.NumberNumeric AS ArchivalEntityNumberNumeric,
		ae.NumberArray as ArchivalEntityNumberArray,
		ae.HasExternalSource AS ArchivalEntityHasExternalSource, 
		ae.ExternalIdentifier AS ArchivalEntityExternalIdentifier,
		ae.DescriptionLevelCode AS ArchivalEntityDescriptionLevelCode,
		ae.StatusCode as ArchivalEntityStatusCode,
		d.CreatedOn,
		d.CreatedBy, 
		(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) AS CreatedByDisplayName,
		cu.UserName AS CreatedByUserName, 
        d.UpdatedOn, 
		d.UpdatedBy, 
		(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) AS UpdatedByDisplayName, 
		uu.UserName AS UpdatedByUserName,
		d.Deleted, 
		d.DeletedOn, 
		d.DeletedBy,
		(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) AS DeletedByDisplayName,
		du.UserName AS DeletedByUserName, 
        d.HasExternalSource, 
		d.ExternalIdentifier, 
		d.ExternalSourceUpdatedOn, 
		d.Number, 
		d.Title,
		d.DescriptionLevelCode, 
		l.Text AS DescriptionLevelText,
		d.StatusCode, 
		s.Text AS StatusText, 
		d.FileFormatCode, 
		d.HasNoChronologicalScope, 
        d.StartDateYear,
		d.StartDateMonth, 
		d.StartDateDay, 
		d.EndDateYear, 
		d.EndDateMonth, 
		d.EndDateDay, 
		d.ApproxmateChronologicalScope, 
		d.Author, 
		d.Location, 
		d.Bytes, 
		d.SheetCount,
		d.StartSheetNumber, 
		d.EndSheetNumber, 
        d.DigitalDevice,
		d.OtherMetrics,
		d.SizeCm, 
		d.Scaling,
		d.Duration, 
		d.Description, 
		d.DocumentsAccessDescription,
		d.Features,
		d.MicrofilmedCopyCount, 
		d.DigitizedCopyCount, 
		d.PaperCopyCount, 
		d.NegativeFrameCount, 
        d.PositiveFrameCount, 
		d.OtherCopyCount, 
		d.Transcription, 
		d.Notes,
		d.AvailabilityStatusCode,
		ast.Text as AvailabilityStatusText,
		case when (select IsNull(count(A.Id),0) from v_PublicDigitalObjects A 
				  where A.DocumentSystemIdentifier = d.SystemIdentifier 
				  and A.IsDraft = 0 
				  and A.IsDigitized = 1) > 0 
			 then CAST(1 AS bit) else CAST(0 AS bit) end as HasDigitizedDigitalObjects
	FROM dbo.Documents AS d 
		INNER JOIN dbo.Archives AS a ON d.ArchiveId = a.Id 
		INNER JOIN dbo.Funds AS f ON d.FundSystemIdentifier = f.SystemIdentifier
		INNER JOIN dbo.Inventories AS i ON d.InventorySystemIdentifier = i.SystemIdentifier 
		INNER JOIN dbo.ArchivalEntities AS ae ON d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier
		LEFT JOIN N.DocumentDescriptionLevel AS l ON d.DescriptionLevelCode = l.Code 
		LEFT JOIN N.Status AS s ON d.StatusCode = s.Code 
		LEFT JOIN dbo.AspNetUsers AS cu ON d.CreatedBy = cu.Id
		LEFT JOIN dbo.AspNetUsers AS uu ON d.UpdatedBy = uu.Id
		LEFT JOIN dbo.AspNetUsers AS du ON d.CreatedBy = du.Id
		LEFT JOIN N.AvailabilityStatus ast ON d.AvailabilityStatusCode = ast.Code
	WHERE f.IsSuspended = 0
	AND d.StatusCode <> 12 --статус отчислен
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER   VIEW [dbo].[v_PublicArchivalEntities] AS
	SELECT 
		ae.Id, 
		ae.SystemIdentifier, 
		CAST(0 AS bit) AS IsDraft,
		ae.ArchiveId, 
		a.Code AS ArchiveCode,
		a.Name AS ArchiveName,
		NULL AS FundDraftId,
		ae.FundSystemIdentifier,
		f.Number AS FundNumber, 
        f.HasExternalSource AS FundHasExternalSource,
		f.ExternalIdentifier AS FundExternalIdentifier,
		NULL AS InventoryDraftId, 
		ae.InventorySystemIdentifier, 
		i.Number AS InventoryNumber, 
        i.HasExternalSource AS InventoryHasExternalSource, 
		i.ExternalIdentifier AS InventoryExternalIdentifier, 
		ae.CreatedOn, 
		ae.CreatedBy, 
		(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) AS CreatedByDisplayName, 
		cu.UserName AS CreatedByUserName, 
		ae.UpdatedOn, 
        ae.UpdatedBy, 
		(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) AS UpdatedByDisplayName,
		uu.UserName AS UpdatedByUserName, 
		ae.Deleted, 
		ae.DeletedOn,
		ae.DeletedBy, 
		(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) AS DeletedByDisplayName, 
		du.UserName AS DeletedByUserName, 
        ae.HasExternalSource, 
		ae.ExternalIdentifier, 
		ae.ExternalSourceUpdatedOn, 
		ae.Number,
		ae.Title, 
		ae.DescriptionLevelCode, 
		l.Text AS DescriptionLevelText, 
		ae.StatusCode,
		s.Text AS StatusText, 
		ae.HasNoChronologicalScope, 
        ae.StartDateYear,
		ae.StartDateMonth, 
		ae.StartDateDay, 
		ae.EndDateYear, 
		ae.EndDateMonth, 
		ae.EndDateDay, 
		ae.ApproxmateChronologicalScope, 
		ae.Author, 
		ae.Location, 
		ae.Bytes,
		ae.SheetCount, 
		ae.TapeCount,
		ae.MicrofilmCount, 
        ae.FrameCount,
		ae.VideoTapeCount,
		ae.DigitalDeviceCount,
		ae.OtherMetrics, 
		ae.SizeCm, 
		ae.Scaling, 
		ae.Description, 
		ae.DocumentsAccessDescription, 
		ae.Features, 
		ae.Condition, 
		ae.MicrofilmedCopyCount, 
		ae.DigitizedCopyCount, 
        ae.PaperCopyCount,
		ae.NegativeFrameCount, 
		ae.PositiveFrameCount,
		ae.OtherCopyCount, 
		ae.Notes, 
		ae.EnrolledBytes, 
		ae.EnrolledDocumentCount, 
		ae.EnrolledLinearMeters, 
		ae.DeductedBytes,
		ae.DeductedDocumentCount, 
        ae.DeductedLinearMeters, 
		f.NumberNumeric as FundNumberNumeric, 
		i.NumberNumeric as InventoryNumberNumeric, 
		ae.NumberNumeric,
		ae.NumberArray,
		ast.Text as AvailabilityStatusText, 
		i.AvailabilityStatusCode,
		IsNull(
		(select top 1 HasDigitizedDigitalObjects from v_PublicDocuments doc 
		where doc.ArchivalEntitySystemIdentifier = ae.SystemIdentifier 
		and IsDraft = 0 and Deleted = 0
		and HasDigitizedDigitalObjects = 1), 0) HasDigitizedDigitalObjects

	FROM dbo.ArchivalEntities AS ae
		INNER JOIN dbo.Archives AS a ON ae.ArchiveId = a.Id 
		INNER JOIN dbo.Funds AS f ON ae.FundSystemIdentifier = f.SystemIdentifier
		INNER JOIN dbo.Inventories AS i ON ae.InventorySystemIdentifier = i.SystemIdentifier 
		LEFT OUTER JOIN N.ArchivalEntityDescriptionLevel AS l ON ae.DescriptionLevelCode = l.Code 
		LEFT OUTER JOIN N.Status AS s ON ae.StatusCode = s.Code
		LEFT OUTER JOIN dbo.AspNetUsers AS cu ON ae.CreatedBy = cu.Id 
		LEFT OUTER JOIN dbo.AspNetUsers AS uu ON ae.UpdatedBy = uu.Id 
		LEFT OUTER JOIN dbo.AspNetUsers AS du ON ae.CreatedBy = du.Id
		LEFT JOIN N.AvailabilityStatus ast ON ae.AvailabilityStatusCode = ast.Code
	WHERE f.IsSuspended = 0
	AND ae.StatusCode <> 12 --статус отчислен
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[v_PublicFunds] AS
	SELECT 
		f.Id,
		f.SystemIdentifier,
		CAST(0 AS bit) AS IsDraft,
		f.ArchiveId, a.Code AS ArchiveCode,
		a.Name AS ArchiveName,
		f.CreatedOn,
		f.CreatedBy,
		(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) AS CreatedByDisplayName,
		cu.UserName AS CreatedByUserName,
		f.UpdatedOn, 
        f.UpdatedBy,
		(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) AS UpdatedByDisplayName,
		uu.UserName AS UpdatedByUserName,
		f.Deleted,
		f.DeletedOn,
		f.DeletedBy,
		(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) AS DeletedByDisplayName,
		du.UserName AS DeletedByUserName, 
        f.ExternalIdentifier,
		f.HasExternalSource,
		f.ExternalSourceUpdatedOn,
		f.NumberArray,
		f.Number,
		f.Title,
		f.DescriptionLevelCode,
		dl.Text AS DescriptionLevelText,
		f.TypeCode,
		ft.Text AS TypeText,
		f.StatusCode,
		s.Text AS StatusText, 
        f.HasNoChronologicalScope,
		f.StartDateYear, 
		f.StartDateMonth, 
		f.StartDateDay, 
		f.EndDateYear,
		f.EndDateMonth, 
		f.EndDateDay, 
		f.ApproxmateChronologicalScope, 
		f.Bytes,
		f.LinearMeters,
		f.OtherMetrics,
		f.InventoryCount, 
        f.ArchivalEntityCount, 
		f.DocumentCount,
		f.FundCreatorTitleHistory,
		f.FundCreatorActivityHistory,
		f.FundCreatorBiographicalHistory, 
		f.DocumentsProvider, 
		f.DocumentsDescription, 
		f.ValuableDocumentsInventoryCount, 
        f.InvaluableDocumentsInventoryCount, 
		f.DocumentsAccessDescription,
		f.History, 
		f.RelatedFunds,
		f.Notes,
		f.EnrolledBytes, 
		f.EnrolledInventoryCount,
		f.DeductedBytes,
		f.DeductedInventoryCount,
		f.NumberNumeric
	FROM dbo.Funds AS f 
		INNER JOIN dbo.Archives AS a ON f.ArchiveId = a.Id
		LEFT OUTER JOIN N.FundDescriptionLevel AS dl ON f.DescriptionLevelCode = dl.Code 
		LEFT OUTER JOIN N.FundType AS ft ON f.TypeCode = ft.Code 
		LEFT OUTER JOIN N.Status AS s ON f.StatusCode = s.Code 
		LEFT OUTER JOIN dbo.AspNetUsers AS cu ON f.CreatedBy = cu.Id 
		LEFT OUTER JOIN dbo.AspNetUsers AS uu ON f.UpdatedBy = uu.Id 
		LEFT OUTER JOIN dbo.AspNetUsers AS du ON f.CreatedBy = du.Id
	WHERE f.IsSuspended = 0
	AND f.DescriptionLevelCode <> 2 -- фонд с необработени документи	
	AND f.StatusCode <> 12 -- Отчислен	
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[v_PublicInventories] AS
	SELECT
		i.Id, i.SystemIdentifier,
		CAST(0 AS bit) AS IsDraft,
		i.ArchiveId, 
		a.Code AS ArchiveCode,
		a.Name AS ArchiveName,
		NULL AS FundDraftId,
		i.FundSystemIdentifier,
		f.Number AS FundNumber,
		f.HasExternalSource AS FundHasExternalSource,
		f.ExternalIdentifier AS FundExternalIdentifier,
		i.CreatedOn, i.CreatedBy,
		(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) AS CreatedByDisplayName,
		cu.UserName AS CreatedByUserName,
		i.UpdatedOn, i.UpdatedBy,
		(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) AS UpdatedByDisplayName, 
        uu.UserName AS UpdatedByUserName,
		i.Deleted, i.DeletedOn,
		i.DeletedBy,
		(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) AS DeletedByDisplayName,
		du.UserName AS DeletedByUserName,
		i.ExternalIdentifier, i.HasExternalSource,
		i.ExternalSourceUpdatedOn, 
        i.NumberArray, i.Number,
		i.DescriptionLevelCode,
		idl.Text AS DescriptionLevelText,
		i.StatusCode, s.Text AS StatusText,
		i.HasNoChronologicalScope, i.StartDateYear,
		i.StartDateMonth, i.StartDateDay,
		i.EndDateYear,
		i.EndDateMonth, 
        i.EndDateDay,
		i.ApproxmateChronologicalScope,
		i.Bytes,
		i.LinearMeters,
		i.OtherMetrics,
		i.ArchivalEntityCount,
		i.DocumentCount,
		i.BoxCount,
		i.RollCount,
		i.AudioDocumentArchivalEntityCount,
		i.PhotoDocumentArchivalEntityCount, 
        i.VideoDocumentArchivalEntityCount,
		i.DigitalDocumentArchivalEntityCount,
		i.FundCreatorTitleHistory,
		i.FundCreatorBiographicalHistory,
		i.History,
		i.DocumentsProvider,
		i.DocumentsDescription,
		i.DocumentsAccessDescription, 
        i.ClassificationScheme,
		i.AbbreviationList,
		i.MicrofilmedArchivalEntityCount,
		i.DigitizedArchivalEntityCount,
		i.NegativeFrameCount,
		i.PositiveFrameCount,
		i.Notes,
		i.NumberNumeric,
		f.NumberNumeric as FundNumberNumeric,
		ast.Text as AvailabilityStatusText,
		i.AvailabilityStatusCode
	FROM dbo.Inventories AS i 
		INNER JOIN dbo.Archives AS a ON i.ArchiveId = a.Id
		INNER JOIN dbo.Funds AS f ON i.FundSystemIdentifier = f.SystemIdentifier 
		LEFT OUTER JOIN N.InventoryDescriptionLevel AS idl ON i.DescriptionLevelCode = idl.Code
		LEFT OUTER JOIN N.Status AS s ON i.StatusCode = s.Code 
		LEFT OUTER JOIN dbo.AspNetUsers AS cu ON i.CreatedBy = cu.Id 
		LEFT OUTER JOIN dbo.AspNetUsers AS uu ON i.UpdatedBy = uu.Id
		LEFT OUTER JOIN dbo.AspNetUsers AS du ON i.CreatedBy = du.Id
		LEFT JOIN N.AvailabilityStatus ast ON i.AvailabilityStatusCode = ast.Code
	WHERE f.IsSuspended = 0
	AND i.DescriptionLevelCode <> 6 -- груб опис 	
	AND i.StatusCode <> 12 -- отчислен			
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   view [dbo].[v_Tasks]
AS
SELECT 
	   t.Id
	  ,t.ProcessId
	  ,p.Completed as ProcessCompleted
	  ,pt.Name as ProcessTypeName
	  ,t.StepId
	  ,stt.Text as StepTypeName
      ,t.Title
	  ,t.Description

	  ,t.AssignedToUserId
	  ,(select top 1 aup.DisplayName from dbo.AspNetUserProfiles as aup where au.Id = aup.UserId) as AssignedToDisplayName
	  ,au.UserName as AssignedToUserName

      ,t.EndDate
      ,t.RelatedEntityId
	  ,t.RelatedEntitySystemIdentifier
	  ,t.RelatedEntityType
      ,t.RelatedContentUrl

      ,t.StatusCode
	  ,s.Text as StatusName

	  ,t.CreatedOn
	  ,t.CreatedBy
	  ,(select top 1 cup.DisplayName from dbo.AspNetUserProfiles as cup where cu.Id = cup.UserId) as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,t.UpdatedOn
	  ,t.UpdatedBy
	  ,(select top 1 uup.DisplayName from dbo.AspNetUserProfiles as uup where uu.Id = uup.UserId) as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
	  ,t.Deleted
	  ,t.DeletedOn
	  ,t.DeletedBy
	  ,(select top 1 dup.DisplayName from dbo.AspNetUserProfiles as dup where du.Id = dup.UserId) as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
	  
	  ,t.NotificationType
	  ,n.Text as NotificationTypeName

	  ,t.AssignedToRoleId
	  ,ar.Name as AssignedToRoleName
	  
    FROM Tasks t
	LEFT JOIN Process p on p.Id = t.ProcessId
	LEFT JOIN N.ProcessTypes pt on pt.Id = p.ProcessTypeId
	LEFT JOIN ProcessTimeline st on st.Id = t.StepId
	LEFT JOIN N.ProcessSteps stt on stt.Id = st.StepTypeId
	JOIN N.TaskStatus s on s.Code = t.StatusCode
	LEFT JOIN N.NotificationType n on n.Code = t.NotificationType
	LEFT JOIN AspNetUsers cu ON t.CreatedBy = cu.Id
	LEFT JOIN AspNetUsers uu ON t.UpdatedBy = uu.Id
	LEFT JOIN AspNetUsers du ON t.CreatedBy = du.Id
    LEFT JOIN AspNetUsers au ON t.AssignedToUserId = au.Id
    LEFT JOIN AspNetRoles ar ON t.AssignedToRoleId = ar.Id
   
GO

-- END 4858 Оптимизиране на информация, свързана с имената на потребител

-- Корекция на справка "Регистър на цифровизирани обекти", след премахване на DisplayName колоната от AspNetUsers
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER     PROCEDURE [dbo].[sp_GetRegisterOfDigitizedDocumentsReport]
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null,
	@RegisteredFrom datetime2(7) = null,
	@RegisteredTo datetime2(7) = null
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
			convert(varchar, d.ModifiedOn, 104) as FinalCorrectionDate,
			(
				select convert(varchar, max(p.ModifiedOn), 104)  
				from Document doc
				inner join Process p on p._retired = ''3000-01-01'' and p.Gid = doc.ProcessGid and p.TypeGid = 2123 and p.StepGid = 75
				where doc.LGid = d.lgid
			) as DigitalObjectAcceptanceDate,
			(select top 1 IntNumber from Fund_Modified f where f.LGid = d.FundLGid) as FundIntNumber,
			(select i.IntNumber from Inventory_Modified as i where i.LGid = d.InventoryLGid) as InventoryIntNumber,
			(select ae.IntNumber from ArchiveEntity_Modified as ae where ae.LGid = d.AELGid) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder,
			NULL as MastersCount,
			NULL as AllDOCount
		FROM Document_Modified as d
		INNER JOIN Archive a ON a.Gid = d.ArchiveGid AND a._retired = ''3000-01-01''
		--inner join Fund_Modified f on f.LGid = d.FundLGid
		--inner join Inventory_Modified i on i.LGid = d.InventoryLGid
		--inner join ArchiveEntity_Modified ae on ae.LGid = d.AELGid
		LEFT OUTER JOIN [Image] img on d.Gid = img.DocumentGid and img._retired = ''3000-01-01''
		WHERE ISNULL(d.HasDigitalObject, 0) = 1
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) '

		IF (@RegisteredFrom IS NOT NULL)
		BEGIN
			SET @remoteQuery += 'AND cast(d.DOCreationDate as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
		END

		IF(@RegisteredTo IS NOT NULL)
		BEGIN
			SET @remoteQuery +='AND cast(d.DOCreationDate as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
		END
		
		SET @remoteQuery += ' GROUP BY
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
			d.ModifiedOn,
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
			CAST((select top(1) convert(varchar, do.CreatedOn, 104) from DigitalObjects as do where do.DocumentSystemIdentifier = d.SystemIdentifier) as nvarchar(50)) as CreationDateDO, 
			d.DigitizedCopyCount as RecordsCountDO,
			CAST(d.Duration as nvarchar(256)) as Duration,
			(select convert(varchar, d.UpdatedOn, 104) where d.StatusCode = 9) as DigitalObjectRecreationDate,
			isnull(dsi.EnrolledBytes, 0) as BytesDO,
			(select top(1) n.Text from N.Nomenclatures as n join DigitalObjects as do on n.Id = do.StatusCode where do.DocumentSystemIdentifier = d.SystemIdentifier and n.Deleted = 0) as StatusDO, 
			(select top(1) up.DisplayName from AspNetUserProfiles as up join DigitalObjects as do on up.UserId = do.CreatedBy where do.DocumentSystemIdentifier = d.SystemIdentifier and do.Deleted = 0) as Operator,
			(select top(1) convert(varchar, p.CreatedOn, 104) from Process as p where p.DocumentSystemIdentifier = d.SystemIdentifier and p.ProcessTypeId = 4 and p.Deleted = 0 order by p.CreatedOn desc) as CorrectionReturnDate,
			isnull(convert(varchar, d.UpdatedOn, 104), convert(varchar, d.CreatedOn, 104)) as FinalCorrectionDate,
			(select top(1) convert(varchar, p.UpdatedOn, 104) from Process as p where p.DocumentSystemIdentifier = d.SystemIdentifier and p.ProcessTypeId = 8 and p.Deleted = 0 order by p.UpdatedOn DESC) as DigitalObjectAcceptanceDate,
			(select f.NumberNumeric FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as FundIntNumber,
			(select i.NumberNumeric FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as InventoryIntNumber,
			(select ae.NumberNumeric FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder,
			(select COUNT(*) from DigitalObjects as do where d.SystemIdentifier = do.DocumentSystemIdentifier and do.Deleted = 0 and do.IsDigitized = 1 and TypeCode = 1) as MastersCount,
			(select COUNT(*) from DigitalObjects as do where d.SystemIdentifier = do.DocumentSystemIdentifier and do.Deleted = 0 and do.IsDigitized = 1) as AllDOCount
		FROM Documents as d
		INNER JOIN Archives a ON a.Id = d.ArchiveId AND a.Deleted = 0
		LEFT JOIN v_DocumentSizeInfo dsi ON dsi.DocumentSystemIdentifier = d.SystemIdentifier AND dsi.IsDraft = 0
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
			  AND exists(select 1 from DigitalObjects do where d.SystemIdentifier = do.DocumentSystemIdentifier and do.Deleted = 0 and do.IsDigitized =1)
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
			  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))) '
		

		IF (@RegisteredFrom IS NOT NULL)
		BEGIN
			SET @localQuery += 'AND cast(d.CreatedOn as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
		END

		IF(@RegisteredTo IS NOT NULL)
		BEGIN
			SET @localQuery +='AND cast(d.CreatedOn as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
		END

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
				ArchiveSortOrder int null,
				MastersCount int NULL,
				AllDOCount int NULL
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

-- END Корекция на справка "Регистър на цифровизирани обекти", след премахване на DisplayName колоната от AspNetUsers

commit 