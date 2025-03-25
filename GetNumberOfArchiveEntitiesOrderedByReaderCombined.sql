USE [DAA]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetNumberOfArchiveEntitiesOrderedByReaderCombined]    Script Date: 6.10.2022 г. 16:07:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetNumberOfArchiveEntitiesOrderedByReaderCombined]
	@LinkedServer nvarchar(50),
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@InventoryGids nvarchar(max) = null,
	@InventoryInternal nvarchar(max) = null,
	@DateFrom nvarchar(100) = null,
	@LevelOfdescriptionGids nvarchar (max) = null,
	@LevelOfdescriptionInternal nvarchar (max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@DateTo nvarchar(100) = null,

	@StatisticDataOnly bit
AS
BEGIN

	SET NOCOUNT ON;

	--DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	--DECLARE @sqlFinalPart VARCHAR(MAX) = '
	--	offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
    	




	CREATE TABLE #temp (
				Reader nvarchar(max) NULL,
				Archive nvarchar(255) NULL,
				LevelOfDescription nvarchar(256) NULL,
				Fund nvarchar(256) NULL,
				Inventory nvarchar(256) NULL,
				ArchiveEntity nvarchar(256) NULL,
				Document nvarchar(2000) NULL,
				ApplicationDate varchar(50) NULL,
				AccessDate varchar(50) NULL
			);

	INSERT INTO #temp(
				Reader,
				Archive,
				LevelOfDescription,
				Fund,
				Inventory,
				ArchiveEntity,
				Document,
				ApplicationDate,
				AccessDate
			)
	EXEC [sp_GetNumberOfArchiveEntitiesOrderedByReaderReport]
		@LinkedServer,
		@ResultType,
		2147483647,
		@Page,
		@ArchiveGids,
		@ArchiveCodesInternal,
		@InventoryGids,
		@InventoryInternal,
		@DateFrom,
		@LevelOfdescriptionGids,
		@LevelOfdescriptionInternal,
		@FundTypeGids,
		@FundTypesInternal,
		@DateTo,

		@StatisticDataOnly = 0

	SET @sql = '
		SELECT COUNT_BIG(*) as TotalCount,
		COUNT_BIG(t.Document) as TotalDocumentsCount
		FROM #temp as t'

	--print @sql;
	EXEC (@sql);
END
