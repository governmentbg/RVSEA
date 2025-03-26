USE [DAA]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetNumberOfArchiveEntitiesOrderedByEmployeeReport]    Script Date: 6.10.2022 г. 16:05:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetNumberOfArchiveEntitiesOrderedByEmployeeReport]
	@LinkedServer nvarchar(50),
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@EmployeeNameGids nvarchar(max) = null,
	@EmployeeNameInternal nvarchar(max) = null,
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

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка

	IF @StatisticDataOnly = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteReadersTable TABLE (
				EmployeeName nvarchar(255) NULL = NULL,
				Archive nvarchar(255) NULL = NULL,
				LevelOfDescription nvarchar(256) NULL = NULL,
				Fund nvarchar(256) NULL = NULL,
				Inventory nvarchar(256) NULL = NULL,
				ArchiveEntity nvarchar(256) NULL = NULL,
				Document nvarchar(2000) NULL = NULL,
				AccessDate varchar(50) NULL = NULL
			);'

			RETURN
	END

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by EmployeeName asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT DISTINCT
			NULL as EmployeeName,
			NULL as Archive,
			NULL as LevelOfDescription,
			NULL as Fund,
			NULL as Inventory,
			NULL as ArchiveEntity,
			NULL as Document,
			NULL as AccessDate
		FROM RequestEntities as re'

			  
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			NULL as EmployeeName,
			NULL as Archive,
			NULL as LevelOfDescription,
			NULL as Fund,
			NULL as Inventory,
			NULL as ArchiveEntity,
			NULL as Document,
			NULL as AccessDate
		FROM Process as p'

	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteReadersTable TABLE (
				EmployeeName nvarchar(255) NULL,
				Archive nvarchar(255) NULL,
				LevelOfDescription nvarchar(256) NULL,
				Fund nvarchar(256) NULL,
				Inventory nvarchar(256) NULL,
				ArchiveEntity nvarchar(256) NULL,
				Document nvarchar(2000) NULL,
				AccessDate varchar(50) NULL
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
