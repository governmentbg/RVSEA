USE [DAA]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetNumberOfArchiveEntitiesOrderedByReaderReport]    Script Date: 6.10.2022 г. 16:08:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetNumberOfArchiveEntitiesOrderedByReaderReport]
	@LinkedServer nvarchar(50),
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@InventoryGids nvarchar(max) = '-999',
	@InventoryInternal nvarchar(max) = '-999',
	@DateFrom nvarchar(100) = null,
	@LevelOfdescriptionGids nvarchar (max) = null,
	@LevelOfdescriptionInternal nvarchar (max) = null,
	@FundTypeGids nvarchar(max) = '-999',
	@FundTypesInternal nvarchar(max) = '-999',
	@DateTo nvarchar(100) = null,

	@StatisticDataOnly bit

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка

	IF @StatisticDataOnly = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteReadersTable TABLE (
				Reader nvarchar(max) NULL = NULL,
				Archive nvarchar(255) NULL = NULL,
				LevelOfDescription nvarchar(256) NULL = NULL,
				Fund nvarchar(256) NULL = NULL,
				Inventory nvarchar(256) NULL = NULL,
				ArchiveEntity nvarchar(256) NULL = NULL,
				Document nvarchar(2000) NULL = NULL,
				ApplicationDate varchar(50) NULL = NULL,
				AccessDate varchar(50) NULL = NULL
			);'

			RETURN
	END

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by Reader asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
 

	IF @InventoryGids IS NULL BEGIN SET @InventoryGids = '-999'; END
	IF @InventoryInternal IS NULL BEGIN SET @InventoryInternal = '-999'; END
	IF @FundTypeGids IS NULL BEGIN SET @FundTypeGids = '-999'; END
	IF @FundTypesInternal IS NULL BEGIN SET @FundTypesInternal = '-999'; END

	IF @InventoryGids = 0 BEGIN SET @InventoryGids = '-999'; END
	IF @InventoryInternal = 0 BEGIN SET @InventoryInternal = '-999'; END
	IF @FundTypeGids = 0 BEGIN SET @FundTypeGids = '-999'; END
	IF @FundTypesInternal = 0 BEGIN SET @FundTypesInternal = '-999'; END

	--IF (COUNT('(select element from dbo.SplitString(''' + @InventoryGids + ''', '',''))') = 0) BEGIN SET @InventoryGids = '-999'; END
	--IF (COUNT('(select element from dbo.SplitString(''' + @InventoryInternal + ''', '',''))') = 0) BEGIN SET @InventoryInternal = '-999'; END
	--IF (COUNT('(select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))') = 0) BEGIN SET @FundTypeGids = '-999'; END
	--IF (COUNT('(select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))') = 0) BEGIN SET @FundTypesInternal = '-999'; END

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT DISTINCT
			lc.Names as Reader,
			(select a.Name from Archive as a where a.Gid = ae.ArchiveGid) as Archive,
			(select n.Value from Nomenclature as n where n.Gid = ae.LevelOfDescriptionGid) as LevelOfDescription,
			(select f.Number from Fund_Modified as f where f.LGid = ae.FundLGid) as Fund,
			(select i.Number from Inventory_Modified as i where i.LGid = ae.InventoryLGid) as Inventory,
			ae.Number as ArchiveEntity,
			d.Number as Document,
			CAST(re.DateCreated as nvarchar(50)) as ApplicationDate,
			CAST(p.CreatedOn as nvarchar(50)) as AccessDate
		FROM RequestEntities as re
		INNER JOIN LibraryCards as lc
		ON lc.Id = re.LibraryCardGid
		INNER JOIN Process as p
		ON re.ProcessGid = p.Gid
		INNER JOIN ArchiveEntity_Modified as ae
		ON re.ArchiveEntityLGid = ae.LGid
		INNER JOIN Document as d
		ON d.AELGid = ae.LGId
		WHERE re.LibraryCardGid IS NOT NULL
		AND (p.TypeGid = 101581 
			OR p.TypeGid = 101582 
			OR p.TypeGid = 101574)
		AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) 
			OR (ae.ArchiveGid in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))))
		AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '','')))
			OR (ae.FundLGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
		AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryGids + ''', '','')))
			OR (ae.InventoryLGid in (select element from dbo.SplitString(''' + @InventoryGids + ''', '',''))))
		AND ((''-999'' in (select element from dbo.SplitString(''' + @LevelOfdescriptionGids + ''', '',''))) 
			OR (ae.LevelOfDescriptionGid in (select element from dbo.SplitString(''' + @LevelOfdescriptionGids + ''', '',''))))
		AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
			OR (cast(ae.CreatedOn as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
		AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
			OR (cast(ae.CreatedOn as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))'

			  
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			NULL as Reader,
			NULL as Archive,
			NULL as LevelOfDescription,
			NULL as Fund,
			NULL as Inventory,
			NULL as ArchiveEntity,
			NULL as Document,
			NULL as ApplicationDate,
			NULL as AccessDate
		FROM Process as p'

	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteReadersTable TABLE (
				Reader nvarchar(max) NULL,
				Archive nvarchar(255) NULL,
				LevelOfDescription nvarchar(256) NULL,
				Fund nvarchar(256) NULL,
				Inventory nvarchar(256) NULL,
				ArchiveEntity nvarchar(256) NULL,
				Document nvarchar(2000) NULL,
				ApplicationDate nvarchar(50) NULL,
				AccessDate nvarchar(50) NULL
			);

			INSERT INTO @remoteReadersTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteReadersTable
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

	--print @sql;
	EXEC (@sql);
END
