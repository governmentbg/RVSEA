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

-- sgenov App.FileUpload - support new upload type - ED
 IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'AutoGenerateDerivative'
          AND Object_ID = Object_ID(N'dbo.FileUploadQueue'))
BEGIN
    ALTER TABLE dbo.FileUploadQueue
    ADD AutoGenerateDerivative bit
END

GO
-- END sgenov App.FileUpload - support new upload type - ED


--ADD SCRIPTS HERE. USE GO AFTER EVERY BATCH

commit 