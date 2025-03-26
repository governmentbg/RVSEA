SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.18'
where Code = 'DB_VERSION'

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetCardForm1Internal] 
	@FundSystemIdentifier UNIQUEIDENTIFIER,
	@RowsOfPage INT = 5000,
	@Page INT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @resultTable TABLE
		(
			SystemIdentifier uniqueidentifier NULL, -- за тест
			YearCreatedAndInventoryNumber VARCHAR(50) NULL,
			EndDates VARCHAR(50) NULL,
			InventorizedCount VARCHAR(50) NULL,
			UninventorizedCount VARCHAR(50) NULL,  
			DeductedCount VARCHAR(50) NULL, 
			AvailableArchivalEntitiesCountAndSize VARCHAR(50) NULL,
			DocumentsCount INT NULL,
			IntNumber INT NULL,
			Number NVARCHAR(256) NULL,
			Id INT NULL
		);		
				
		DECLARE @inventoriesTable TABLE
		(
			[SystemIdentifier] [uniqueidentifier] NOT NULL,
			RowNumber INT NOT NULL
		)

		INSERT INTO @inventoriesTable 
		SELECT 
			SystemIdentifier, 
			ROW_NUMBER() OVER(ORDER BY SystemIdentifier ASC) AS RowNumber
		FROM [dbo].[InventoryDrafts] 
		WHERE Deleted = 0 AND FundSystemIdentifier = ''' + CONVERT(VARCHAR(50), @FundSystemIdentifier) + '''
		GROUP BY SystemIdentifier;

		DECLARE @Counter INT; 
		SET @Counter=1;
		DECLARE @inventoriesCount INT = (SELECT COUNT(SystemIdentifier) c FROM @inventoriesTable);
		WHILE (@Counter <= @inventoriesCount)
		BEGIN
			DECLARE @currentSystemIdentifier uniqueidentifier = (SELECT SystemIdentifier  FROM @inventoriesTable WHERE RowNumber = @Counter);

			-- Insert first inventory state row
			INSERT INTO @resultTable
				SELECT TOP(1)
					@currentSystemIdentifier AS SystemIdentifier,
					CONVERT(VARCHAR(50), i1.CreatedOn, 104) 
						+ '';'' + ISNULL(i1.Number,'''') AS YearCreatedAndInventoryNumber,
					COALESCE(
						CONVERT(VARCHAR(50), i1.StartDateYear, 104) + '';'' + CONVERT(VARCHAR(50), i1.EndDateYear, 104),
						CONVERT(VARCHAR(50), i1.StartDateYear, 104) + '';'',
						'';'' + CONVERT(VARCHAR(50), i1.EndDateYear, 104)
					) AS EndDates,
					CASE
						WHEN i1.DescriptionLevelCode <> 6 THEN CONVERT(VARCHAR(50), i1.ArchivalEntityCount, 10) 
							+ '';'' + CONVERT(VARCHAR(50), ISNULL(dbo.ConvertBytesToMB(i1.Bytes), 0)) + '' MB''
						ELSE NULL
					END AS InventorizedCount,
					CASE
						WHEN i1.DescriptionLevelCode = 6 THEN CONVERT(VARCHAR(50), i1.ArchivalEntityCount, 10) 
						ELSE NULL
					END AS UnInventorizedCount,
					NULL AS DeductedCount,
					CONVERT(VARCHAR(50), i1.ArchivalEntityCount, 104) 
						+ '';'' + CONVERT(VARCHAR(50), dbo.ConvertBytesToMB(ISNULL(i1.Bytes, 0)), 104) + '' MB'' AS AvailableArchivalEntitiesCountAndSize,
					i1.DocumentCount AS DocumentsCount,
					i1.NumberNumeric AS IntNumber,
					i1.Number,
					i1.Id
				FROM (
					SELECT 
						ROW_NUMBER() OVER(ORDER BY Id ASC) AS RowNumber, 
						SystemIdentifier,
						CreatedOn, 
						Number, 
						StartDateYear, 
						EndDateYear, 
						ArchivalEntityCount,
						Bytes, 
						DescriptionLevelCode, 
						DocumentCount,
						NumberNumeric,
						Id
					FROM [dbo].[InventoryDrafts]
					WHERE SystemIdentifier=@currentSystemIdentifier
						AND Deleted = 0 
						AND EXISTS(SELECT 1 FROM [dbo].[Process] p WHERE p.InventorySystemIdentifier = SystemIdentifier AND p.Completed = 1)
				) i1;
		
			INSERT INTO @resultTable
				SELECT  
					@currentSystemIdentifier AS SystemIdentifier,
					CONVERT(VARCHAR(50), i2.CreatedOn, 104) 
						+ '';'' + ISNULL(i2.Number, '''') AS YearCreatedAndInventoryNumber,
					COALESCE(
						CONVERT(VARCHAR(50), i2.StartDateYear, 104) + '';'' + CONVERT(VARCHAR(50), i2.EndDateYear, 104),
						CONVERT(VARCHAR(50), i2.StartDateYear, 104) + '';'',
						'';'' + CONVERT(VARCHAR(50), i2.EndDateYear, 104)
					) AS EndDates,
					CASE
						WHEN (ISNULL(i2.ArchivalEntityCount, 0) - ISNULL(i1.ArchivalEntityCount, 0) > 0 
								OR dbo.ConvertBytesToMB(ABS(ISNULL(i2.Bytes, 0) - ISNULL(i1.Bytes, 0))) <> 0)
							AND i2.DescriptionLevelCode <> 6 
							THEN CONVERT(VARCHAR(50), ABS(ISNULL(i2.ArchivalEntityCount, 0) - ISNULL(i1.ArchivalEntityCount, 0))) 
								+ '';'' + CONVERT(VARCHAR(50), dbo.ConvertBytesToMB(ABS(ISNULL(i2.Bytes, 0) - ISNULL(i1.Bytes, 0)))) + '' MB''
						ELSE NULL
					END AS InventorizedCount,
					CASE
						WHEN dbo.ConvertBytesToMB(ABS(ISNULL(i2.Bytes, 0) - ISNULL(i1.Bytes, 0))) <> 0 AND i2.DescriptionLevelCode = 6 
							THEN CONVERT(VARCHAR(50), dbo.ConvertBytesToMB(ABS(ISNULL(i2.Bytes, 0) - ISNULL(i1.Bytes, 0)))) + '' MB''
						ELSE NULL
					END AS UninventorizedCount,
					CASE
						WHEN (ISNULL(i2.ArchivalEntityCount, 0) - ISNULL(i1.ArchivalEntityCount, 0) > 0 
								OR dbo.ConvertBytesToMB(ABS(ISNULL(i2.Bytes, 0) - ISNULL(i1.Bytes, 0))) <> 0)
							AND i2.DescriptionLevelCode = 6
							THEN CONVERT(VARCHAR(50), ABS(ISNULL(i2.ArchivalEntityCount, 0) - ISNULL(i1.ArchivalEntityCount, 0))) 
								+ '';'' + CONVERT(VARCHAR(50), dbo.ConvertBytesToMB(ABS(ISNULL(i2.Bytes, 0) - ISNULL(i1.Bytes, 0)))) + '' MB''
						ELSE NULL
					END AS DeductedCount,
					CONVERT(VARCHAR(50), ISNULL(i2.ArchivalEntityCount, 0), 104) 
						+ '';'' + CONVERT(VARCHAR(50), ISNULL(dbo.ConvertBytesToMB(i2.Bytes), 0), 104) + '' MB'' AS AvailableArchivalEntitiesCountAndSize,
					i2.DocumentCount AS DocumentsCount,
					i2.NumberNumeric AS IntNumber,
					i2.Number,
					i2.Id
				FROM (
					SELECT 
						ROW_NUMBER() OVER(ORDER BY Id ASC) AS RowNumber, 
						SystemIdentifier,
						DescriptionLevelCode,
						ArchivalEntityCount, 
						Bytes
					FROM [dbo].[InventoryDrafts]
					WHERE SystemIdentifier = @currentSystemIdentifier 
						AND Deleted = 0 
						AND EXISTS(SELECT 1 FROM [dbo].[Process] p WHERE p.InventorySystemIdentifier = SystemIdentifier AND p.Completed = 1)
				) i1
				INNER JOIN 
				(
					SELECT
						ROW_NUMBER() OVER(ORDER BY Id ASC) AS RowNumber, 
						SystemIdentifier,
						CreatedOn,
						Number,
						StartDateYear,
						EndDateYear,
						ArchivalEntityCount, 
						Bytes, 
						DescriptionLevelCode, 
						DocumentCount,
						NumberNumeric,
						Id
					FROM [dbo].[InventoryDrafts] 
					WHERE SystemIdentifier = @currentSystemIdentifier 
						AND Deleted = 0 
						AND EXISTS(SELECT 1 FROM [dbo].[Process] p WHERE p.InventorySystemIdentifier = SystemIdentifier AND p.Completed = 1)
				) i2 ON 
				i2.RowNumber=i1.RowNumber + 1 
					AND (ISNULL(i2.ArchivalEntityCount, 0) - ISNULL(i1.ArchivalEntityCount, 0) <> 0 OR ISNULL(i2.Bytes, 0) - ISNULL(i1.Bytes, 0) <> 0) 
			SET @Counter  = @Counter  + 1;
		END

		SELECT * FROM @resultTable
		ORDER BY IntNumber, Number, Id
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY;
	'; 

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetCardForm1FundDataInernal] 
	@SystemIdentifier UNIQUEIDENTIFIER = NULL,
	@RowsOfPage INT = 5000,
	@Page INT = 1
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
		a.[Name] AS Archive,
		a.Code AS ArchiveCode,
		fund.Number AS Number,
		fund.Title,
		t.Text AS Type,
		convert(varchar, fund.CreatedOn, 104) AS CreationDate,
		(select ValueCode + ';'
			from  NomenclatureValues nv
			where nv.EntityType='fund' 
				and nv.NomenclatureCode = 'INDUSTRY_TYPE'
				and nv.EntityId=fund.Id
			FOR XML path(''), elements) as IndustryIndex,
		fund.InventoryCount AS InventoriesCount,
		fund.ArchivalEntityCount AS ArchivalEntitiesCount,
		Bytes AS Size
	FROM Funds as fund
	INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
	LEFT JOIN N.FundType t ON t.Code = TypeCode 
	WHERE SystemIdentifier = @SystemIdentifier;
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryReport]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveInternal nvarchar(max) = null,
	@StatusGids nvarchar(10) = null,
	@StatusesInternal nvarchar(max) = null,
	@FundNumber nvarchar(10) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@ChronologicalScope nvarchar(100) = null,
	@ChronologicalScopeStartDate nvarchar(100) = null,
	@ChronologicalScopeEndDate nvarchar(100) = null
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql NVARCHAR(MAX);
	DECLARE @sqlFinalPart NVARCHAR(MAX) = '
		order by CountryCode
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
		DECLARE @remoteQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
			SELECT
			''BG'' as CountryCode,
			(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = inv.ArchiveGid) as Archive,
			(SELECT Value FROM Nomenclature n5 where n5._retired = ''3000-01-01'' and n5.Gid = fund.LevelOfDescriptionGid ) as FundDescriptionLevel,
			fund.Number as FundNumber,
			fund.Title as FundTitle,
			inv.Number as InventoryNumber,
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = inv.LevelOfDescriptionGid) as InventoryDescriptionLevel,
			(SELECT Value FROM Nomenclature WHERE _retired = ''3000-01-01'' and Gid = inv.StatusGid) as [Status],
			ISNULL(inv.AECount, 0) as AeCount,
			(SELECT COUNT(*) FROM ArchiveEntity_Modified as ae where InventoryLGid = inv.LGid and ISNUMERIC(RIGHT(ae.Number,1)) = 0) as AeWithCharCount,
			round(isnull(cast(inv.LinearMeter as decimal(18,2)), 0),2) as LinearMeters,
			0.0 as Bytes
			FROM Inventory as inv
			inner join Fund_Modified as fund on inv.FundLGid = fund.LGid
			WHERE
			fund._retired = ''3000-01-01''
			AND inv._retired = ''3000-01-01''
			AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (fund.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
			AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (inv.TextDate = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
			AND ((''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' = ''null'') OR (cast(inv.StartDate as date) >= cast(''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' = ''null'') OR (cast(inv.EndDate as date) <= cast(''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(inv.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(inv.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR (inv.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR (inv.ArchiveGid in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))))
			AND inv.LevelOfDescriptionGid in(
			2171, -- Inventory
			2172  -- InventoryRough
			)
		');
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		DECLARE @ChronologicalScopeStartDateCondition VARCHAR(MAX) = '';
		IF @ChronologicalScopeStartDate IS NOT NULL SET @ChronologicalScopeStartDateCondition = 
		'AND 
			try_cast
			(
				coalesce(
					convert(varchar, i.StartDateYear, 104) + ''-'' + convert(varchar, i.StartDateMonth, 104) + ''-'' + convert(varchar, i.StartDateDay, 104),
					convert(varchar, i.StartDateYear, 104) + ''-'' + convert(varchar, i.StartDateMonth, 104) + ''-'' + convert(varchar, ' + convert(varchar, day(cast(@ChronologicalScopeStartDate as date)), 104) +', 104), -- пренебрегва се деня
					convert(varchar, i.StartDateYear, 104) + ''-'' + convert(varchar, ' + convert(varchar, Month(cast(@ChronologicalScopeStartDate as date)), 104) +', 104) + ''-'' + convert(varchar, ' + convert(varchar, day(cast(@ChronologicalScopeStartDate as date)), 104) +', 104) -- пренебрегват се месеца и деня
				) as date
			) >= cast(''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' as date)
		';
		DECLARE @ChronologicalScopeEndDateCondition VARCHAR(MAX) = '';
		IF @ChronologicalScopeEndDate IS NOT NULL SET @ChronologicalScopeEndDateCondition = 
		'AND 
			try_cast
			(
				coalesce(
					convert(varchar, i.EndDateYear, 104) + ''-'' + convert(varchar, i.EndDateMonth, 104) + ''-'' + convert(varchar, i.EndDateDay, 104),
					convert(varchar, i.EndDateYear, 104) + ''-'' + convert(varchar, i.EndDateMonth, 104) + ''-'' + convert(varchar, ' + convert(varchar, day(cast(@ChronologicalScopeEndDate as date)), 104) +', 104), -- пренебрегва се деня
					convert(varchar, i.EndDateYear, 104) + ''-'' + convert(varchar, ' + convert(varchar, Month(cast(@ChronologicalScopeEndDate as date)), 104) +', 104) + ''-'' + convert(varchar, ' + convert(varchar, day(cast(@ChronologicalScopeEndDate as date)), 104) +', 104)-- пренебрегват се месеца и деня
				) as date
			) >= cast(''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' as date)
		';

		DECLARE @localQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
			SELECT
				''BG'' as CountryCode
				,a.[Name] as Archive
				,fdl.[Text] as FundDescriptionLevel
				,f.Number as FundNumber
				,f.Title as FundTitle
				,i.Number as InventoryNumber
				,idl.[Text] as InventoryDescriptionLevel
				,s.[Text] as [Status]
				,COUNT(ae.SystemIdentifier) as AeCount
				,(SELECT COUNT(*) FROM v_ArchivalEntities as ae where InventorySystemIdentifier = i.SystemIdentifier and ISNUMERIC(RIGHT(ae.Number,1)) = 0) as AeWithCharCount
				,ROUND(ISNULL(CAST(i.LinearMeters as decimal(18,2)), 0), 2) as LinearMeters
				,ISNULL(i.Bytes, 0) as Bytes
		     FROM v_Inventories as i
		     JOIN [Archives] as a
		       ON i.ArchiveId = a.Id
		     JOIN v_Funds as f
		       ON i.FundSystemIdentifier = f.SystemIdentifier
		     JOIN N.FundDescriptionLevel as fdl
		       ON f.DescriptionLevelCode = fdl.Code
		     JOIN N.InventoryDescriptionLevel as idl
		       ON i.DescriptionLevelCode = idl.Code
		     JOIN N.[Status] as s
		       ON i.StatusCode = s.Code
			FULL OUTER JOIN v_ArchivalEntities as ae
			   ON i.SystemIdentifier = ae.InventorySystemIdentifier
			WHERE i.Deleted = 0
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveInternal  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal  + ''', '',''))) 
					OR (convert(varchar(4), i.StatusCode, 104) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.ApproxmateChronologicalScope = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(i.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
					OR (cast(i.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))	
				'
				+ @ChronologicalScopeStartDateCondition
				+ @ChronologicalScopeEndDateCondition +					
		 'GROUP BY a.[Name], fdl.[Text], f.Number, f.[Title], i.Number, idl.[Text], s.[Text], i.SystemIdentifier, i.LinearMeters, i.Bytes
		');
	END

		IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				CountryCode nvarchar(255) NULL,
				Archive nvarchar(255) NULL,
				FundDescriptionLevel nvarchar(255) NULL,
				FundNumber nvarchar(255) NULL,
				FundTitle nvarchar(max) NULL,
				InventoryNumber nvarchar(255) NULL,
				InventoryDescriptionLevel nvarchar(255) NULL,
				[Status] nvarchar(255) NULL,
				AeCount int NULL,
				AeWithCharCount int NULL,
				LinearMeters decimal NULL,
				Bytes bigint NULL

			);

			INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteTable
			UNION ALL
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

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryReportCombined]
	@LinkedServer nvarchar(50),
	@ResultType int,
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveInternal nvarchar(max) = null,
	@StatusGids nvarchar(10) = null,
	@StatusesInternal nvarchar(max) = null,
	@FundNumber nvarchar(10) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@ChronologicalScope nvarchar(100) = null,
	@ChronologicalScopeStartDate nvarchar(100) = null,
	@ChronologicalScopeEndDate nvarchar(100) = null
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	SET @RowsOfPage = 2147483647
	SET @Page = 1

	DECLARE @sql VARCHAR(MAX); 
	CREATE TABLE #temp (
				CountryCode nvarchar(255) NULL,
				Archive nvarchar(255) NULL,
				FundDescriptionLevel nvarchar(255) NULL,
				FundNumber nvarchar(255) NULL,
				FundTitle nvarchar(max) NULL,
				InventoryNumber nvarchar(255) NULL,
				InventoryDescriptionLevel nvarchar(255) NULL,
				[Status] nvarchar(255) NULL,
				AeCount int NULL,
				AeWithCharCount int NULL,
				LinearMeters decimal NULL,
				Bytes bigint NULL
			);

	INSERT INTO #temp(
				CountryCode,
				Archive,
				FundDescriptionLevel,
				FundNumber,
				FundTitle,
				InventoryNumber,
				InventoryDescriptionLevel,
				[Status],
				AeCount,
				AeWithCharCount,
				LinearMeters,
				Bytes
			)
	EXEC [sp_GetInventoryReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page,
		@ArchiveGids,
		@ArchiveInternal,
		@StatusGids,
		@StatusesInternal,
		@FundNumber,
		@RegisteredFrom,
		@RegisteredTo,
		@ChronologicalScope,
		@ChronologicalScopeStartDate,
		@ChronologicalScopeEndDate

	SET @sql = '
	SELECT TOP 1
		COUNT_BIG(t.InventoryNumber) as InventoryCount,
		CAST(SUM(t.AeCount) as bigint) as AeCount,
		CAST(SUM(t.AeWithCharCount) as bigint) as AeWithCharCount,
		CAST(SUM(t.LinearMeters) as decimal) as LinearMeters,
		CAST(SUM(t.Bytes) as bigint) as Bytes
		FROM #temp as t'

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryReportSummary]
	@LinkedServer nvarchar(50),
	@ResultType int,
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveInternal nvarchar(max) = null,
	@StatusGids nvarchar(10) = null,
	@StatusesInternal nvarchar(max) = null,
	@FundNumber nvarchar(10) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@ChronologicalScope nvarchar(100) = null,
	@ChronologicalScopeStartDate nvarchar(100) = null,
	@ChronologicalScopeEndDate nvarchar(100) = null
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	SET @RowsOfPage = 2147483647
	SET @Page = 1

	DECLARE @sql VARCHAR(MAX); 
	CREATE TABLE #temp (
				CountryCode nvarchar(255) NULL,
				Archive nvarchar(255) NULL,
				FundDescriptionLevel nvarchar(255) NULL,
				FundNumber nvarchar(255) NULL,
				FundTitle nvarchar(max) NULL,
				InventoryNumber nvarchar(255) NULL,
				InventoryDescriptionLevel nvarchar(255) NULL,
				[Status] nvarchar(255) NULL,
				AeCount int NULL,
				AeWithCharCount int NULL,
				LinearMeters decimal NULL,
				Bytes bigint NULL
			);

	INSERT INTO #temp(
				CountryCode,
				Archive,
				FundDescriptionLevel,
				FundNumber,
				FundTitle,
				InventoryNumber,
				InventoryDescriptionLevel,
				[Status],
				AeCount,
				AeWithCharCount,
				LinearMeters,
				Bytes
			)
	EXEC [sp_GetInventoryReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page,
		@ArchiveGids,
		@ArchiveInternal,
		@StatusGids,
		@StatusesInternal,
		@FundNumber,
		@RegisteredFrom,
		@RegisteredTo,
		@ChronologicalScope,
		@ChronologicalScopeStartDate,
		@ChronologicalScopeEndDate

	SET @sql = '
		SELECT TOP 1 COUNT_BIG(*) as TotalRows
		FROM #temp as t'

	EXEC (@sql);
END
GO

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
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null
AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	--DECLARE @sqlFinalPart VARCHAR(MAX) = '
	--	offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
 
	CREATE TABLE #temp (
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
				ArchiveSortOrder int null
			);

	INSERT INTO #temp(
				DocumentLink,
				ArchiveCode,
				ArchiveName,
				SystemId,
				LevelOfDescription,
				FundNumber,
				InventoryNumber,
				ArchiveEntityNumber,
				Title,
				DocCreationDate,
				Themes,
				DocStatus,
				CreationDateDO,
				RecordsCountDO,
				Duration,
				DigitalObjectRecreationDate,
				BytesDO,
				StatusDO,
				Operator,
				CorrectionReturnDate,
				FinalCorrectionDate,
				DigitalObjectAcceptanceDate,
				FundIntNumber,
				InventoryIntNumber,
				ArchivalEntityIntNumber,
				ArchiveSortOrder
			)
	EXEC [sp_GetRegisterOfDigitizedDocumentsReport]
	@LinkedServer,
	@ResultType,
	2147483647,
	@Page,
	@ArchiveCodes,
	@RegisteredFrom,
	@RegisteredTo

	SET @sql = '
		SELECT TOP 1
			NULL as PeriodFrom,
			NULL as PeriodTo,
			NULL as Employee
		FROM #temp'
	EXEC (@sql);
END
GO

UPDATE N.ProcessSteps SET AllowTaskTemplate = 1 WHERE Id = 236
GO

DECLARE @SourceTaskTemplateId int;
DECLARE @TargetTaskTemplateId int;

SELECT TOP 1 @SourceTaskTemplateId = TaskTemplate_Id
   FROM dbo.TaskTemplatesSteps
  WHERE ProcessStep_Id = 237;

PRINT @SourceTaskTemplateId;

SELECT TOP 1 @TargetTaskTemplateId = TaskTemplate_Id
   FROM dbo.TaskTemplatesSteps
  WHERE ProcessStep_Id = 236;

PRINT @TargetTaskTemplateId;

IF (@TargetTaskTemplateId IS NULL)
BEGIN
	PRINT '@TargetTaskTemplateId is null';

	INSERT INTO dbo.TaskTemplatesSteps (TaskTemplate_Id, ProcessStep_Id)
	VALUES (@SourceTaskTemplateId, 236);
END
GO

----------------------------------------------------------
--	THE SCRIPT IS CLOSED - USE THE NEW ONE!
----------------------------------------------------------



commit