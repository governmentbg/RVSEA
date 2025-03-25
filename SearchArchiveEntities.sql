USE [DAA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_SearchArchiveEntities] 
	@LinkedServer nvarchar(50),
	@HasInventoryExternalSource BIT,
	@Number nvarchar(255) = '',
	@InventoryExternalIdentifier int NULL,
	@InventoryInternalIdentifier int NULL
AS
BEGIN
	SET NOCOUNT ON;

	IF @InventoryExternalIdentifier is NULL SET @InventoryExternalIdentifier=-1;
	IF @InventoryInternalIdentifier is NULL SET @InventoryInternalIdentifier=-1;

	declare @sql varchar(max) = 
		'SELECT TOP 1000000 -- top го слагам, за да не дава грешка
			NULL as Id,
			(select a.Name
				from  [Archiving].[dbo].Archive a
				where a._retired=''3000-01-01'' and a.Gid=ArchiveGid) as ArchiveName,
			--(select fund.Title
				--from  [Archiving].[dbo].Fund_Active fund
				--where fund.LGid=FundLGid) as FundTitle,
			LGid as ExternalIdentifier,	
			Number,
			Title,
			CAST(1 AS BIT) as HasExternalSource
		FROM [Archiving].[dbo].ArchiveEntity_Active
		WHERE InventoryLGid = ' + CAST(@InventoryExternalIdentifier as varchar(10)) + ' AND + Number LIKE ''%' + @Number + '%''';

	set @sql = REPLACE(@sql, '''', '''''');

	declare @finalQuery varchar(max) = '';

	declare @declareRemoteDocumentsTable varchar(max) =
		'DECLARE @remoteDocumentsTable TABLE (
			[Id] [int] NULL,
			[ArchiveName] [nvarchar](255) NOT NULL,
			--[FundTitle] nvarchar(2000) NULL, 
			[ExternalIdentifier] [int] NULL,
			[Number] [nvarchar](50) NULL,
			[Title] [nvarchar](max) NULL,
			[HasExternalSource] BIT NOT NULL
		);';
	declare @declareRemoteDocumentsTable1 varchar(max) = '';
	declare @declareRemoteDocumentsTable2 varchar(max) = '';

	IF @HasInventoryExternalSource=0 
	BEGIN
		SET @declareRemoteDocumentsTable1 = @declareRemoteDocumentsTable;
	END;
	IF @HasInventoryExternalSource=1 
	BEGIN
		SET @declareRemoteDocumentsTable2 = @declareRemoteDocumentsTable;
	END;

	declare @localServerQuery varchar(max) = @declareRemoteDocumentsTable1 + '
		SELECT TOP 1000000 -- top го слагам, за да не дава грешка
			Id,
			(select a.Name from  dbo.Archives a where a.Id=ArchiveId) as ArchiveName,
			--(
				--select f.Title
				--from dbo.Funds f
				--where f.Id=i.FundId) as FundTitle,
			ExternalIdentifier,	
			Number,
			Title,
			CAST(0 AS BIT) as HasExternalSource
		FROM dbo.ArchivalEntities
		WHERE InventoryId = ' + CAST(@InventoryInternalIdentifier as varchar(10))
			+ ' AND Number LIKE ''%' + @Number + '%'' AND not exists(SELECT 1 FROM @remoteDocumentsTable rdt where ExternalIdentifier = rdt.ExternalIdentifier) 
		ORDER BY Number';

	declare @bothServerQuery varchar(max) = @declareRemoteDocumentsTable2 + '
		INSERT INTO @remoteDocumentsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''');

		SELECT * FROM @remoteDocumentsTable rdt
		UNION '
			+ @localServerQuery;

	IF @HasInventoryExternalSource=1
	BEGIN
		SET @finalQuery = @bothServerQuery; 
	END;
	IF @HasInventoryExternalSource=0 
	BEGIN
		SET @finalQuery = @localServerQuery;
	END;

	EXEC (@finalQuery);	
END