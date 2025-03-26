USE [DAA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE IF EXISTS [dbo].[sp_SearchInventories]
GO

CREATE PROCEDURE [dbo].[sp_SearchInventories] 
	--@LinkedServer nvarchar(50),
	--@HasFundExternalSource BIT,
	--@Number nvarchar(255) = '',
	--@FundExternalIdentifier int NULL,
	--@FundInternalIdentifier int NULL
	@LinkedServer nvarchar(50),
	@FundSystemIdentifier uniqueidentifier,
	@FundHasExternalSource bit,
	@FundExternalIdentifier int,
	@DescriptionLevel nvarchar(255),
	@SearchText nvarchar(255) = '',
	@Limit int = 1000000
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteInventoryQuery nvarchar(max) = '';
    DECLARE @RemoteInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,IsDraft bit
		,ArchiveId int
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,FundDraftId int
        ,FundSystemIdentifier uniqueidentifier
        ,FundHasExternalSource bit
        ,FundExternalIdentifier int
        ,FundNumber nvarchar(255)
		,NumberArray nvarchar(10)
		,Number nvarchar(50)
	);

	DECLARE @LocalInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,IsDraft bit
		,ArchiveId int
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,FundDraftId int
        ,FundSystemIdentifier uniqueidentifier
        ,FundHasExternalSource bit
        ,FundExternalIdentifier int
        ,FundNumber nvarchar(255)
		,NumberArray nvarchar(10)
		,Number nvarchar(50)
	);

	DECLARE @DescriptionLevelCodes nvarchar(255) = '5,6,12'

	IF @DescriptionLevel IS NOT NULL
		SET @DescriptionLevelCodes = @DescriptionLevel

	IF @FundHasExternalSource = 1
	BEGIN

		SET @RemoteInventoryQuery = CAST('' as nvarchar(max)) +
		'SELECT TOP(' + CAST(@Limit as nvarchar(50)) + ') 
				-1 as Id
				,CAST(NULL as uniqueidentifier) as SystemIdentifier
				,CAST(1 as bit) as HasExternalSource
				,inventory.[LGid] as ExternalIdentifier
				,CAST(0 as bit) as IsDraft
				,CAST(NULL as int) as ArchiveId
				,(select Code from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
				,(select Name from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
				,CAST(NULL as int) as FundDraftId
				,CAST(NULL as uniqueidentifier) as FundSystemIdentifier
				,CAST(1 as bit) as FundHasExternalSource
				,inventory.FundLGid as FundExternalIdentifier
				,(select fund.Number from  [Archiving].[dbo].Fund_Active fund where fund.LGid = inventory.FundLGid) as FundNumber
				,(select Value from [Archiving].[dbo].Nomenclature n where n.Gid = inventory.InventoryArrayGid and n._retired = ''''3000-01-01 00:00:00.000'''') as NumberArray
				,inventory.[Number] as Number
			FROM [Archiving].[dbo].Inventory_Active as inventory
			WHERE inventory.FundLGid  = ' + CAST(@FundExternalIdentifier as nvarchar(50)) + '
			AND inventory.LevelOfDescriptionGid in (select n.Gid from [Archiving].[dbo].[Nomenclature] n where n.type = ''''LevelOfDescription'''' and n.Code in (' + @DescriptionLevelCodes + '))
			AND inventory.Number LIKE ''''%' + @SearchText + '%'''''

		PRINT @RemoteInventoryQuery
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteInventoryQuery + ''' )';
		
		INSERT INTO @RemoteInventories 
		EXEC(@RemoteQuery)

	END
	

	INSERT INTO @LocalInventories
	SELECT TOP (@Limit) 
			inventory.Id
			,inventory.SystemIdentifier as SystemIdentifier
			,inventory.HasExternalSource
			,inventory.ExternalIdentifier
			,inventory.IsDraft
			,inventory.ArchiveId
			,inventory.ArchiveCode
			,inventory.ArchiveName
			,inventory.FundDraftId
			,inventory.FundSystemIdentifier
			,inventory.FundHasExternalSource
			,inventory.FundExternalIdentifier
			,inventory.FundNumber
			,inventory.NumberArray
			,inventory.Number
		FROM [dbo].[v_Inventories] inventory
		WHERE inventory.FundSystemIdentifier = @FundSystemIdentifier
		AND inventory.DescriptionLevelCode IN (select trim(value) from  STRING_SPLIT (@DescriptionLevelCodes, ','))
		AND inventory.HasExternalSource = 0
		AND inventory.Deleted = 0
		AND inventory.Number LIKE '%' + @SearchText + '%'


	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalInventories
		  UNION
		 SELECT *
		   FROM @RemoteInventories
	   ) inventories
	ORDER BY Number



	--IF @FundExternalIdentifier is NULL SET @FundExternalIdentifier=-1;
	--IF @FundInternalIdentifier is NULL SET @FundInternalIdentifier=-1;

	--declare @sql varchar(max) = 
	--	'SELECT TOP 1000000 -- top го слагам, за да не дава грешка
	--		NULL as Id,
	--		(select a.Name
	--			from  [Archiving].[dbo].Archive a
	--			where a._retired=''3000-01-01'' and a.Gid=inventory.ArchiveGid) as ArchiveName,
	--		(select fund.Title
	--			from  [Archiving].[dbo].Fund_Active fund
	--			where fund.LGid=inventory.FundLGid) as FundTitle,
	--		inventory.LGid as ExternalIdentifier,	
	--		inventory.Number,
	--		NULL as Title,
	--		CAST(1 AS BIT) as HasExternalSource
	--	FROM [Archiving].[dbo].Inventory_Active as inventory
	--	WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as varchar(10)) + ' AND + inventory.Number LIKE ''%' + @Number + '%''';

	--set @sql = REPLACE(@sql, '''', '''''');

	--declare @finalQuery varchar(max) = '';

	--declare @declareRemoteInventoriesTable varchar(max) =
	--	'DECLARE @remoteInventoriesTable TABLE (
	--		[Id] [int] NULL,
	--		[ArchiveName] [nvarchar](255) NOT NULL,
	--		[FundTitle] nvarchar(2000) NULL, 
	--		[ExternalIdentifier] [int] NULL,
	--		[Number] [nvarchar](50) NULL,
	--		[Title] [nvarchar](max) NULL,
	--		[HasExternalSource] BIT NOT NULL
	--	);';
	--declare @declareRemoteInventoriesTable1 varchar(max) = '';
	--declare @declareRemoteInventoriesTable2 varchar(max) = '';

	--IF @HasFundExternalSource=0 
	--BEGIN
	--	SET @declareRemoteInventoriesTable1 = @declareRemoteInventoriesTable;
	--END;
	--IF @HasFundExternalSource=1 
	--BEGIN
	--	SET @declareRemoteInventoriesTable2 = @declareRemoteInventoriesTable;
	--END;

	--declare @localServerQuery varchar(max) = @declareRemoteInventoriesTable1 + '
	--	SELECT TOP 1000000 -- top го слагам, за да не дава грешка
	--		Id,
	--		(select a.Name from  dbo.Archives a where a.Id=i.ArchiveId) as ArchiveName,
	--		(
	--			select f.Title
	--			from dbo.Funds f
	--			where f.Id=i.FundId) as FundTitle,
	--		ExternalIdentifier,	
	--		Number,
	--		Title,
	--		CAST(0 AS BIT) as HasExternalSource
	--	FROM dbo.Inventories i
	--	WHERE i.FundId = ' + CAST(@FundInternalIdentifier as varchar(10))
	--		+ ' AND i.Number LIKE ''%' + @Number + '%'' AND not exists(SELECT 1 FROM @remoteInventoriesTable rit where i.ExternalIdentifier = rit.ExternalIdentifier) 
	--	ORDER BY Number';

	--declare @bothServerQuery varchar(max) = @declareRemoteInventoriesTable2 + '
	--	INSERT INTO @remoteInventoriesTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''');

	--	SELECT * FROM @remoteInventoriesTable rit
	--	UNION '
	--		+ @localServerQuery;

	--IF @HasFundExternalSource=1
	--BEGIN
	--	SET @finalQuery = @bothServerQuery; 
	--END;
	--IF @HasFundExternalSource=0 
	--BEGIN
	--	SET @finalQuery = @localServerQuery;
	--END;

	--EXEC (@finalQuery);	
END