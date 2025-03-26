USE [DAA]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetQualityControlReport]    Script Date: 6.10.2022 г. 16:13:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetQualityControlReport]
	@LinkedServer nvarchar(50), -- Посочване на външната база
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(10) = null

AS
BEGIN

	SET NOCOUNT ON;

		DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by Archive asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN

		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT
			NULL as Archive,
			NULL as TotalNumberOfCheckedObjects,
			NULL as TotalNumberOfCheckedRecords,
			NULL as TotalNumberOfAcceptedObjects,
			NULL as TotalNumberOfAcceptedRecords,
			NULL as TotalNumberOfReturnedObjects,
			NULL as TotalNumberOfReturnedRecords
		FROM Fund_Modified as fund'
	
	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT 
			NULL as Archive,
			NULL as TotalNumberOfCheckedObjects,
			NULL as TotalNumberOfCheckedRecords,
			NULL as TotalNumberOfAcceptedObjects,
			NULL as TotalNumberOfAcceptedRecords,
			NULL as TotalNumberOfReturnedObjects,
			NULL as TotalNumberOfReturnedRecords
		FROM Films'
	END

		IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				Archive nvarchar(255) NULL,
				TotalNumberOfCheckedObjects int NULL,
				TotalNumberOfCheckedRecords int NULL,
				TotalNumberOfAcceptedObjects int NULL,
				TotalNumberOfAcceptedRecords int NULL,
				TotalNumberOfReturnedObjects int NULL,
				TotalNumberOfReturnedRecords int NULL
			);

			INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteTable
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
