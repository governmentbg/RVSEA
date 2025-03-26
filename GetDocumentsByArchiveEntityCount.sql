USE [DAA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE IF EXISTS dbo.sp_GetDocumentsByArchiveEntityCount
GO

CREATE PROCEDURE dbo.sp_GetDocumentsByArchiveEntityCount
	@LinkedServer nvarchar(50),
	@ArchiveEntityIdentifier uniqueidentifier NULL,
	@ArchiveEntityHasExternalSource bit,
	@ArchiveEntityExternalIdentifier int NULL,
	@SearchText nvarchar(max) NULL = NULL,
	@IncludeDeleted bit = false
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteDocuments TABLE ( DocumentCount int );
	DECLARE @RemoteDocumentsCount int = 0;
	DECLARE @LocalDocumentsCount int = 0;

	DECLARE @RemoteDocumentsQuery nvarchar(max) = '';
		
	IF @ArchiveEntityHasExternalSource = 1
	BEGIN 
		SET @RemoteDocumentsQuery = CAST('' as nvarchar(max)) +
		'SELECT LGid
		   FROM [Archiving].[dbo].[Document_Active] d
		  WHERE d.AELGid = ' + CAST(@ArchiveEntityExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
			SET @RemoteDocumentsQuery = @RemoteDocumentsQuery + ' AND Title LIKE ''''%' + @SearchText + '%'''''
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT COUNT(*) as DocumentCount FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteDocumentsQuery + ''' )';
		
		PRINT @RemoteQuery
		
		INSERT INTO @RemoteDocuments
		EXEC(@RemoteQuery)

		SELECT TOP 1 @RemoteDocumentsCount = DocumentCount from @RemoteDocuments

	END

	IF @ArchiveEntityIdentifier IS NOT NULL
	BEGIN
		SELECT @LocalDocumentsCount = COUNT(d.Id)
		  FROM [dbo].[v_Documents] d
		 WHERE d.ArchivalEntitySystemIdentifier = @ArchiveEntityIdentifier 
		   AND (d.HasExternalSource IS NULL OR d.HasExternalSource = 0)
		   AND (@IncludeDeleted = 1 OR d.Deleted = 0)
	END

	RETURN @LocalDocumentsCount + @RemoteDocumentsCount


	--IF @ArchiveEntityExternalIdentifier is NULL SET @ArchiveEntityExternalIdentifier=-1;
	--IF @ArchiveEntityInternalIdentifier is NULL SET @ArchiveEntityInternalIdentifier=-1;

	--declare @searchStringContition varchar(max) = '';
	--IF @SearchString IS NOT NULL SET @searchStringContition=' AND Title LIKE ''%' + @SearchString + '%''';

	--declare @sql varchar(max) = 
	--	'SELECT LGid as ExternalIdentifier, CAST(0 AS BIT) as Deleted
	--	FROM [Archiving].[dbo].Document_Active
	--	WHERE AELGid = ' + CAST(@ArchiveEntityExternalIdentifier as varchar(10)) + @searchStringContition + ';';

	--set @sql = REPLACE(@sql, '''', '''''');

	--declare @finalQuery varchar(max) = '';

	--declare @declareRemoteDocumentsTable varchar(max) =
	--	'DECLARE @remoteDocumentsTable TABLE (
	--		[ExternalIdentifier] [int] NULL,
	--		[Deleted] BIT NOT NULL
	--	);';
	--declare @declareRemoteDocumentsTable1 varchar(max) = '';
	--declare @declareRemoteDocumentsTable2 varchar(max) = '';
	--declare @localServerQuerySelect varchar(max) = '';

	--IF @HasArchiveEntityExternalSource=0 
	--BEGIN
	--	SET @declareRemoteDocumentsTable1 = @declareRemoteDocumentsTable;
	--	SET @localServerQuerySelect = 'SELECT COUNT_BIG(*) TotalRows ';
	--END;
	--IF @HasArchiveEntityExternalSource=1 
	--BEGIN
	--	SET @declareRemoteDocumentsTable2 = @declareRemoteDocumentsTable;
	--	SET @localServerQuerySelect = 'SELECT ExternalIdentifier, Deleted ';
	--END;

	--declare @includeDeletedCondition varchar(max) = '';
	--IF @IncludeDeleted=0 SET @includeDeletedCondition = ' AND Deleted = 0';

	--declare @localServerQuery varchar(max) = @declareRemoteDocumentsTable1 + 
	--	@localServerQuerySelect + '
	--	FROM dbo.Documents d
	--	WHERE ArchivalEntityId = ' + CAST(@ArchiveEntityInternalIdentifier as varchar(10))
	--		+ ' AND not exists(SELECT 1 FROM @remoteDocumentsTable rdt where d.ExternalIdentifier = rdt.ExternalIdentifier)' +  @searchStringContition + @includeDeletedCondition;

	--declare @bothServerQueries varchar(max) = @declareRemoteDocumentsTable2 + '
	--	INSERT INTO @remoteDocumentsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''');

	--	SELECT COUNT_BIG(*) TotalRows FROM
	--		(SELECT * FROM @remoteDocumentsTable
	--		UNION '
	--			+ @localServerQuery + ') AS c';

	--IF @HasArchiveEntityExternalSource=1
	--BEGIN
	--	SET @finalQuery = @bothServerQueries; 
	--END;
	--IF @HasArchiveEntityExternalSource=0 
	--BEGIN
	--	SET @finalQuery = @localServerQuery;
	--END;

	--EXEC (@finalQuery);	
END