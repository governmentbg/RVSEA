SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetPartialReceiptsPublicReport] -- Fund_CP_Report
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само -- 2 до момента не се използва !!!
	@PeriodGids nvarchar(max) = null,
	@FundArraysInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@TextDate nvarchar(2000) = null,
	@DateFrom nvarchar(100) = NULL,
	@DateTo nvarchar(100) = null,
	@RowsOfPage int = 50,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
	DECLARE @remoteQuery VARCHAR(MAX) = 
		'SELECT
			fund.Title,
			a.Name as Archive,
			fund.Number,
			convert(varchar, fund.CreationDate, 104) as CreationDate,
			fund.ImmediateSourceOfAcquisition,
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.TypeGid) as FundType,
			fund.DocumentProperties,
			fund.Note,
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.StatusGid) as FundStatus,
			(select Value + '';''
				from  Nomenclature n1
				inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
				where n1._retired=''3000-01-01'' 
					and on1._retired=''3000-01-01''
					and on1.FundGid = fund.Gid 
					and n1.Type=''MethodOfAcquisition''
				FOR XML path(''''), elements) as MethodOfAcquisition,
			fund.TextDate,
			(isnull(convert(varchar, StartDateDay) + ''.'', '''') + isnull(convert(varchar, StartDateMonth) + ''.'', '''') + isnull(convert(varchar, StartDateYear), '''')) as StartDate,
			(isnull(convert(varchar, fund.EndDateDay) + ''.'', '''') + isnull(convert(varchar, fund.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, fund.EndDateYear), '''')) as EndDate,
			fund.InvetoryCount as InventoryCount,
			fund.AECount,
			isnull(fund.LinearMeters, 0) as LinearMeters,
			fund.IntNumber,
			a.SortOrder
		FROM Fund_Modified as fund
		INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
		WHERE
			(''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
			AND fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 2)
			AND (''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'' OR cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2))
			AND (''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'' OR cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2))
			AND (''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '','')) OR fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '','')))
			AND (''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))
				OR EXISTS(SELECT 1 FROM [Archiving].[dbo].ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
			AND (''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
			AND (''' + COALESCE(@TextDate, 'null') + ''' = ''null'' OR fund.TextDate = ''' + COALESCE(@TextDate, 'null') + ''')
			AND (''' + COALESCE(@DateFrom, 'null') + ''' = ''null'' OR cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2))
			AND (''' + COALESCE(@DateTo, 'null') + ''' = ''null'' OR cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2))';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	END

	IF @ResultType = 1 OR @ResultType = 3
    BEGIN
		DECLARE @DateFromCondition VARCHAR(MAX) = '';
		IF @DateFrom IS NOT NULL SET @DateFromCondition = 
		'AND 
			try_cast
			(
				coalesce(
					convert(varchar, f.StartDateYear, 104) + ''-'' + convert(varchar, f.StartDateMonth, 104) + ''-'' + convert(varchar, f.StartDateDay, 104),
					convert(varchar, f.StartDateYear, 104) + ''-'' + convert(varchar, f.StartDateMonth, 104) + ''-'' + convert(varchar, ' + convert(varchar, day(cast(@DateFrom as date)), 104) +', 104), -- пренебрегва се деня
					convert(varchar, f.StartDateYear, 104) + ''-'' + convert(varchar, ' + convert(varchar, Month(cast(@DateFrom as date)), 104) +', 104) + ''-'' + convert(varchar, ' + convert(varchar, day(cast(@DateFrom as date)), 104) +', 104) -- пренебрегват се месеца и деня
				) as date
			) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as date)
		';
		DECLARE @DateToCondition VARCHAR(MAX) = '';
		IF @DateTo IS NOT NULL SET @DateToCondition = 
		'AND 
			try_cast
			(
				coalesce(
					convert(varchar, f.EndDateYear, 104) + ''-'' + convert(varchar, f.EndDateMonth, 104) + ''-'' + convert(varchar, f.EndDateDay, 104),
					convert(varchar, f.EndDateYear, 104) + ''-'' + convert(varchar, f.EndDateMonth, 104) + ''-'' + convert(varchar, ' + convert(varchar, day(cast(@DateTo as date)), 104) +', 104), -- пренебрегва се деня
					convert(varchar, f.EndDateYear, 104) + ''-'' + convert(varchar, ' + convert(varchar, Month(cast(@DateTo as date)), 104) +', 104) + ''-'' + convert(varchar, ' + convert(varchar, day(cast(@DateTo as date)), 104) +', 104)-- пренебрегват се месеца и деня
				) as date
			) >= cast(''' + COALESCE(@DateTo, 'null') + ''' as date)
		';

	 DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			f.Title,
			a.Name as Archive,
			f.Number,
			convert(varchar, f.CreatedOn, 104) as CreationDate,
			f.DocumentsProvider as ImmediateSourceOfAcquisition,
			(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
			f.DocumentsDescription as DocumentProperties,
			f.Notes as Note,
			(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus,
			(select n1.Text from N.Nomenclatures n1 where f.AcquisitionMethodId = n1.Id) as MethodOfAcquisition,
			f.ApproxmateChronologicalScope as TextDate,
			(isnull(convert(varchar, f.StartDateDay) + ''.'', '''') + isnull(convert(varchar, f.StartDateMonth) + ''.'', '''') + isnull(convert(varchar, f.StartDateYear), '''')) as StartDate,
			(isnull(convert(varchar, f.EndDateDay) + ''.'', '''') + isnull(convert(varchar, f.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, f.EndDateYear), '''')) as EndDate,
			cast(fsi.EnrolledInventoryCount as bigint) as InventoryCount , 
			cast(fsi.EnrolledArchivalEntityCount as bigint) as AECount,
			null as LinearMeters,
			f.NumberNumeric as IntNumber,
			a.SortOrder
		FROM Funds f
		INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
		INNER JOIN N.Status s ON s.Code = f.StatusCode AND s.Code <> 12
		LEFT JOIN v_FundSizeInfo as fsi ON f.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
		WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
			AND f.DescriptionLevelCode = 4
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
				OR ((select Code from N.Nomenclatures n1 where n1.Id = f.AcquisitionMethodId) in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
				OR (convert(varchar(4), s.Code, 104) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '','')))) 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = f.TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
			AND ((''' + ISNULL(@TextDate,  N'NULL') + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.ApproxmateChronologicalScope = ''') + ISNULL(@TextDate, N'NULL') + '''))
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
				OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
				OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))'
			+ @DateFromCondition
			+ @DateToCondition;
	END   

	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
	SET @sql = '
		DECLARE @remoteFundsTable TABLE (
			Title nvarchar(MAX) NULL,
			Archive nvarchar(256) NOT NULL,
			Number nvarchar(256) NULL,
			CreationDate varchar(50) NULL,
			ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
			FundType nvarchar(MAX) NULL,
			DocumentProperties nvarchar(max) NULL,
			Note nvarchar(MAX) NULL,
			FundStatus nvarchar(MAX) NULL,
			MethodOfAcquisition nvarchar(MAX) NULL,
			TextDate nvarchar(256) NULL,
			StartDate varchar(256) NULL,
			EndDate varchar(50) NULL,
			InventoryCount bigint NULL,
			AECount bigint NULL,
			LinearMeters float NULL,
			IntNumber int null,
			SortOrder int null
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteFundsTable
		UNION
		' +
		@localQuery + '
		order by SortOrder, IntNumber,  Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery+ '
		order by SortOrder, IntNumber,  Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; 
	END

	EXEC (@sql);
END
GO