SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.37'
where Code = 'DB_VERSION'
go


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetFundPublicReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null, 
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@Statuses nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@TextDate nvarchar(2000) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by SortOrder, IntNumber, Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT
				isnull(fund.LinearMeters, 0) as LinearMeters,
				null as DigitalSize,
				null as Duration,
				fund.InvetoryCount as InventoryCount,
				fund.AECount as AECount,
				fund.ImmediateSourceOfAcquisition,
				a.Name as Archive,
				fund.Number,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.TypeGid) as FundType,
				(select Value + '';''
					from Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''IndustryIndex''
					FOR XML path(''''), elements) as IndustryIndex,
				(select Value + '';''
					from Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''MethodOfAcquisition''
					FOR XML path(''''), elements) as MethodOfAcquisition,
				fund.TextDate,
				(isnull(convert(varchar, StartDateDay) + ''.'', '''') + isnull(convert(varchar, StartDateMonth) + ''.'', '''') + isnull(convert(varchar, StartDateYear), '''')) as StartDate,
				(isnull(convert(varchar, fund.EndDateDay) + ''.'', '''') + isnull(convert(varchar, fund.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, fund.EndDateYear), '''')) as EndDate,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				fund.Title,
				fund.Note,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.StatusGid) as FundStatus,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.LevelOfDescriptionGid) as LevelOfDescription,
				fund.IntNumber,
				a.SortOrder,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource,
				null as SystemIdentifier
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE
				((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND (fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1) 
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 4))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
                    OR ((SELECT Code FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.StatusGid) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE(@TextDate, 'null') + '''))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))';

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

		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				null as LinearMeters,
				fsi.EnrolledBytes as DigitalSize,
				cast((select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as bigint) as Duration,
				fsi.EnrolledInventoryCount as InventoryCount,
				fsi.EnrolledArchivalEntityCount as AECount,
				f.DocumentsProvider as ImmediateSourceOfAcquisition,
				a.Name as Archive,
				f.Number,
				(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
				(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''INDUSTRY_TYPE'' 
						and nv.EntityId=f.Id
					FOR XML path(''''), elements) as IndustryIndex,
				(select n1.Text from N.Nomenclatures n1 where f.AcquisitionMethodId = n1.Id) as MethodOfAcquisition,
				f.ApproxmateChronologicalScope as TextDate,
				(isnull(convert(varchar, f.StartDateDay) + ''.'', '''') + isnull(convert(varchar, f.StartDateMonth) + ''.'', '''') + isnull(convert(varchar, f.StartDateYear), '''')) as StartDate,
				(isnull(convert(varchar, f.EndDateDay) + ''.'', '''') + isnull(convert(varchar, f.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, f.EndDateYear), '''')) as EndDate,
				convert(varchar, f.CreatedOn, 104) as CreationDate,
				f.Title,
				f.Notes as Note,
				(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus,
				(SELECT Text FROM [N].[FundDescriptionLevel] dl where dl.Code = f.DescriptionLevelCode) as LevelOfDescription,
				f.NumberNumeric as IntNumber,
				a.SortOrder,
				f.ExternalIdentifier,
				f.HasExternalSource,
				f.SystemIdentifier
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			INNER JOIN N.Status s ON s.Code = f.StatusCode AND s.Code <> 12
			LEFT JOIN v_FundSizeInfo as fsi ON f.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 1 -- fund 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
					OR ((select Code from N.Nomenclatures n1 where n1.Id = f.AcquisitionMethodId) in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
					OR (convert(varchar(4), s.Code, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '','')))) 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = f.TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
				AND ((''' + ISNULL(@TextDate,  N'NULL') + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.ApproxmateChronologicalScope = ''') + ISNULL(@TextDate, N'NULL') + '''))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
					OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))	
					'
				+ @DateFromCondition
				+ @DateToCondition;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				LinearMeters float NULL, 
				DigitalSize bigint NULL,
				Duration nvarchar(14) NULL,
				InventoryCount int NULL,
				AECount int NULL,
				ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				FundType nvarchar(MAX) NULL,
				IndustryIndex nvarchar(MAX) NULL,
				MethodOfAcquisition nvarchar(MAX) NULL,
				TextDate nvarchar(256) NULL,
				StartDate varchar(256) NULL,
				EndDate varchar(50) NULL,
				CreationDate varchar(50) NULL,
				Title nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				FundStatus nvarchar(MAX) NULL,
				LevelOfDescription nvarchar(MAX) NULL,
				IntNumber int null,
				SortOrder int null,
				ExternalIdentifier int null,
				HasExternalSource bit,
				SystemIdentifier uniqueidentifier null
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteFundsTable
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

	EXEC (@sql);
END
GO



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
			a.SortOrder,
			null as Size,
			fund.LGid as ExternalIdentifier,
			CAST(1 as bit) as HasExternalSource,
			null as SystemIdentifier
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
			a.SortOrder,
			isnull(fsi.EnrolledBytes, 0) as Size,
			f.ExternalIdentifier,
			f.HasExternalSource,
			f.SystemIdentifier
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
			SortOrder int null,
			Size float Null,
			ExternalIdentifier int null,
			HasExternalSource bit,
			SystemIdentifier nvarchar(256) null
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



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetFundMemoryPublicReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(10) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by SortOrder, IntNumber, Number
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	DECLARE @organisation VARCHAR(MAX) = '
		(
			select a.Organization
			    from EDocsCollectingApplication as a
			   where a.Id = ApplicationId
			   FOR XML path(''''), elements
		)';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				fund.ImmediateSourceOfAcquisition as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				(select Value + '';''
					from Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''CreatingType''
					FOR XML path(''''), elements) as CreatingType,
				isnull(fund.LinearMeters, 0) as LinearMeters,
				null as DigitalSize,
				null as Duration,
				fund.Note,
				fund.IntNumber,
				a.SortOrder,
				null as SystemIdentifier,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource,
				null as FileTypes
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
			OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
			AND	fund.StatusGid <> 2115 
			AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3)';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreatedOn, 104) as CreationDate,
				COALESCE(
					fund.DocumentsProvider + '' / '' + ' + @organisation +  ', 
					fund.DocumentsProvider + '' / '', 
					'' / '' + ' + @organisation + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				(select Text + '';''
					from NomenclatureValues nv
					join N.Nomenclatures n1 on 
						nv.EntityType=''fund'' 
						and n1.deleted=0
						and nv.deleted=0
						and nv.NomenclatureCode=''CREATION_METHOD'' 
						and nv.EntityId=fund.Id
						and n1.Id=nv.ValueId
					FOR XML path(''''), elements) as CreatingType,
				NULL as LinearMeters ,
				(select sum(d.FileSize) from v_DigitalObjects d where d.FundSystemIdentifier = fund.SystemIdentifier AND d.Deleted = 0 AND d.IsDraft=0 AND d.StatusCode <> 12)  as DigitalSize,
				(select cast(sum(d.Duration) as bigint) from v_DigitalObjects d where d.FundSystemIdentifier = fund.SystemIdentifier AND d.Deleted = 0 AND d.IsDraft=0 AND d.StatusCode <> 12)  as Duration,
				fund.Notes as Note,
				fund.NumberNumeric as IntNumber,
				a.SortOrder,
				fund.SystemIdentifier,
				fund.ExternalIdentifier,
				fund.HasExternalSource,
			(select f.FileTypes from v_FundSizeInfo f where f.FundSystemIdentifier = fund.SystemIdentifier AND f.IsDraft=0) as FileTypes
			FROM Funds fund 
			INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
			WHERE fund.ExternalIdentifier IS NULL 
			AND fund.HasExternalSource = 0
			AND fund.Deleted = 0 
			AND fund.StatusCode <> 12
				AND DescriptionLevelCode = 3 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				CreationDate varchar(50) NULL,
				ImmediateSourceOfAcquisitionPlusMethodOfAcquisition nvarchar(MAX) NULL,
				Title nvarchar(MAX) NULL,
				CreatingType nvarchar(2000) NULL,
				LinearMeters float NULL,
				DigitalSize bigint NULL,
				Duration bigint NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null,
				SortOrder int null,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit,
				FileTypes nvarchar(2000) NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteFundsTable
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

	EXEC (@sql);
END
GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetFundDataPublicReport] -- REPORT_8_27_Fund_Report от ИСДА
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null, 
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@TextDate nvarchar(2000) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@LGid nvarchar(max) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	declare @offset int = (@Page - 1) * @RowsOfPage;

	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by SortOrder, IntNumber, Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN 
		declare @remoteQuery varchar(max) =  '
			SELECT
				convert(varchar(50), fund.LGid, 104) as SystemId,
				fund.CreationAuthor,
				convert(nvarchar,fund.ModificationDate, 104) as ModificationDate,
				fund.ModificationAuthor,
				isnull(fund.LinearMeters, 0) as LinearMeters,
				fund.InvetoryCount as InventoryCount,
				fund.BoxesCount,
				fund.RuloniTubusiCount as StorageTubesCount,
				fund.AECount,
				fund.ExtentOther,
				null EDocumentsCount,
				null as Size,
				null as FileFormats,
				null as Duration,
				fund.FundFormerNameChange,
				fund.FundFormerFunction,
				fund.FundFormerHistory,
				fund.ArchivalHistory,
				fund.ImmediateSourceOfAcquisition,
				fund.DocumentProperties,
				(
					select Value + '';''
					from  Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''Originality''
					FOR XML path(''''), elements
				) as Originality,
				(
					select Value + '';''
					from  Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''CreatingType''
					FOR XML path(''''), elements
				) as CreatingType,
				(
					select Value + '';''
					from  Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''Language''
					FOR XML path(''''), elements
				) as [Language],
				fund.AccessConditions,
				fund.FindingAids,
				fund.RelatedUnits,
				a.Name as Archive,
				fund.Number,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.TypeGid) as FundType,
				(
					select Value + '';''
					from  Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''IndustryIndex''
					FOR XML path(''''), elements
				) as IndustryIndex,
				(
					select Value + '';''
					from  Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''MethodOfAcquisition''
					FOR XML path(''''), elements
				) as MethodOfAcquisition,
				fund.TextDate,
				(isnull(convert(varchar, StartDateDay) + ''.'', '''') + isnull(convert(varchar, StartDateMonth) + ''.'', '''') + isnull(convert(varchar, StartDateYear), '''')) as StartDate,
				(isnull(convert(varchar, fund.EndDateDay) + ''.'', '''') + isnull(convert(varchar, fund.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, fund.EndDateYear), '''')) as EndDate,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				fund.Title,
				fund.Note,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.StatusGid) as FundStatus,
				fund.IntNumber,
				a.SortOrder,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE
				((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) 
					OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) 
					OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) 
					OR EXISTS(SELECT 1 FROM [dbo].ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))	
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE(@TextDate, 'null') + '''))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@LGid, 'null') + ''' = ''null'') OR (fund.LGid in (SELECT Element from dbo.SplitString(''' + COALESCE(@LGid, 'null') + ''', '',''))))';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType= 1 OR @ResultType = 3
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
			convert(varchar(50), f.SystemIdentifier, 104) as SystemId,
			(SELECT DisplayName FROM [AspNetUsers] u where u.Id = f.CreatedBy) as CreationAuthor,
			convert(nvarchar, f.UpdatedOn, 104) as ModificationDate,
			(SELECT top 1 DisplayName FROM [AspNetUsers] u where u.Id = f.UpdatedBy) as ModificationAuthor, -- тук слагам top 1, за да не дава грешка, че подзаявката има повече от 1 резултат - не видях причината за тази грешка				
			null as LinearMeters,
			fsi.EnrolledInventoryCount as InventoryCount,
			NULL as BoxesCount,
			NULL as StorageTubesCount,
			fsi.EnrolledArchivalEntityCount as AECount,
			f.OtherMetrics as ExtentOther,
			fsi.EnrolledDocumentCount as EDocumentsCount,
			fsi.EnrolledBytes as Size,
			fsi.FileTypes as FileFormats,
			(select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration,
			f.FundCreatorTitleHistory as FundFormerNameChange,
			f.FundCreatorActivityHistory as FundFormerFunction,
			f.FundCreatorBiographicalHistory as FundFormerHistory,
			f.History as ArchivalHistory,
			f.DocumentsProvider as ImmediateSourceOfAcquisition,
			f.DocumentsDescription as DocumentProperties,
			(select Text + '';''
				from NomenclatureValues nv
				join N.Nomenclatures n1 on 
					nv.EntityType=''fund'' 
					and n1.deleted=0
					and nv.deleted=0
					and nv.NomenclatureCode=''ORIGINALITY'' 
					and nv.EntityId=f.Id
					and n1.Id=nv.ValueId
				FOR XML path(''''), elements) as Originality,
			(select Text + '';''
				from NomenclatureValues nv
				join N.Nomenclatures n1 on 
					nv.EntityType=''fund'' 
					and n1.deleted=0
					and nv.deleted=0
					and nv.NomenclatureCode=''CREATION_METHOD'' 
					and nv.EntityId=f.Id
					and n1.Id=nv.ValueId
				FOR XML path(''''), elements) as CreatingType,
			(select Text + '';''
				from NomenclatureValues nv
				join N.Nomenclatures n1 on 
					nv.EntityType=''fund'' 
					and n1.deleted=0
					and nv.deleted=0
					and nv.NomenclatureCode=''LANGUAGE'' 
					and nv.EntityId=f.Id
					and n1.Id=nv.ValueId
				FOR XML path(''''), elements) as Language,
			f.DocumentsAccessDescription as AccessConditions,
			NULL as FindingAids,
			f.RelatedFunds as RelatedUnits,
			a.Name as Archive,
			f.Number,
			(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
			(select ValueCode + '';''
				from NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.deleted=0
					and nv.NomenclatureCode = ''INDUSTRY_TYPE'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as IndustryIndex,
			(select n1.Text from N.Nomenclatures n1 where f.AcquisitionMethodId = n1.Id) as MethodOfAcquisition,
			f.ApproxmateChronologicalScope as TextDate,
			(isnull(convert(varchar, f.StartDateDay) + ''.'', '''') + isnull(convert(varchar, f.StartDateMonth) + ''.'', '''') + isnull(convert(varchar, f.StartDateYear), '''')) as StartDate,
			(isnull(convert(varchar, f.EndDateDay) + ''.'', '''') + isnull(convert(varchar, f.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, f.EndDateYear), '''')) as EndDate,
			convert(varchar, f.CreatedOn, 104) as CreationDate,
			f.Title,
			f.Notes as Note,
			(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus,
			f.NumberNumeric as IntNumber,
			a.SortOrder,
			f.ExternalIdentifier,
			f.HasExternalSource
		FROM Funds f
		INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
		INNER JOIN N.Status s ON s.Code = f.StatusCode AND s.Code <> 12
		LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier AND fsi.IsDraft = 0
		WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
			AND f.DescriptionLevelCode = 1 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
				) 
			)
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
				OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))	
				'
			+ @DateFromCondition
			+ @DateToCondition;
   END

    DECLARE @sql VARCHAR(MAX);

    IF @ResultType = 1 
	 BEGIN
	  SET @sql = '
		DECLARE @remoteFundsTable TABLE (
			SystemId varchar(50) NOT NULL,
			CreationAuthor nvarchar(256) NULL,
			ModificationDate varchar(50) NULL,
			ModificationAuthor nvarchar(256) NULL,
			LinearMeters float NULL,
			InventoryCount int NULL, 
			BoxesCount int NULL,
			StorageTubesCount int NULL,	
			AECount int NULL,
			ExtentOther nvarchar(256) NULL,
			EDocumentsCount int NULL,
			Size bigint NULL,
			FileFormats nvarchar(MAX) NULL,
			Duration nvarchar(14) NULL,
			FundFormerNameChange nvarchar(MAX) NULL,
			FundFormerFunction nvarchar(MAX) NULL,
			FundFormerHistory nvarchar(MAX) NULL,
			ArchivalHistory nvarchar(MAX) NULL,
			ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
			DocumentProperties nvarchar(max) NULL,
			Originality nvarchar(2000) NULL,
			CreatingType nvarchar(2000) NULL,
			Language nvarchar(2000) NULL,
			AccessConditions nvarchar(MAX) NULL,
			FindingAids nvarchar(2000) NULL,
			RelatedUnits nvarchar(MAX) NULL,
			Archive nvarchar(256) NOT NULL,
			Number nvarchar(256) NULL,
			FundType nvarchar(MAX) NULL,
			IndustryIndex nvarchar(MAX) NULL,
			MethodOfAcquisition nvarchar(MAX) NULL,
			TextDate nvarchar(256) NULL,
			StartDate varchar(256) NULL,
			EndDate varchar(50) NULL,
			CreationDate varchar(50) NULL,
			Title nvarchar(MAX) NULL,
			Note nvarchar(MAX) NULL,
			FundStatus nvarchar(MAX) NULL,
			IntNumber int null,
			SortOrder int null,
			ExternalIdentifier int null,
			HasExternalSource bit
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteFundsTable
		UNION
		' +
		+ @localQuery +
		+ @sqlFinalPart;
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundsListReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(max) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by SortOrder, IntNumber, Number
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				fund.Title,
				fund.Note,
				fund.IntNumber,
				a.SortOrder,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource,
				null as SystemIdentifier
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)';
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreatedOn, 104) as CreationDate,
				fund.Title,
				fund.Notes as Note,
				fund.NumberNumeric as IntNumber,
				a.SortOrder,				
				fund.ExternalIdentifier,
				fund.HasExternalSource,
				fund.SystemIdentifier
			FROM Funds fund 
			INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
			INNER JOIN N.Status s ON s.Code = fund.StatusCode AND s.Code <> 12
			WHERE fund.ExternalIdentifier IS NULL AND fund.HasExternalSource = 0 AND fund.Deleted = 0 
				AND fund.DescriptionLevelCode = 1 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), a.Code, 104)) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				CreationDate varchar(50) NULL,
				Title nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null,
				SortOrder int null,
				ExternalIdentifier int null,
				HasExternalSource bit,
				SystemIdentifier uniqueidentifier null
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteFundsTable
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

	EXEC (@sql);
END
GO



update Notification.NotificationTemplate
set Body = '<p>Получено е ново #applicationType# от #applicantFullName#, #applicantEmail# с #documentsOrigin#. Физическо или юридическо лице, чийто документи се предават: #documentsOwner#</p>'
where NotificationTypeCode = 'NewApplication'
go

update TaskTemplates
set Description = '<p>Получено е ново #applicationType# от #applicantFullName#, #applicantEmail# с #documentsOrigin#. Физическо или юридическо лице, чийто документи се предават: #documentsOwner#</p>'
where NotificationType = 'NewApplication'
go



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER view [dbo].[v_InventorySizeInfo]
AS

select distinct
	A.SystemIdentifier InventorySystemIdentifier
	, A.FundSystemIdentifier 
	
	, IsNull(A.AvailabilityStatusCode,0) InventoryAvailabilityStatusCode
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledInventory
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedInventory

	, IsNull(sum(D.EnrolledArchivalEntity),0) EnrolledArchivalEntityCount
	, IsNull(sum(D.DeductedArchivalEntity),0) DeductedArchivalEntityCount

	, IsNull(sum(D.EnrolledDocumentCount),0) EnrolledDocumentCount
	, IsNull(sum(D.DeductedDocumentCount),0) DeductedDocumentCount

	, IsNull(sum(D.EnrolledBytes),0) EnrolledBytes
	, IsNull(sum(D.DeductedBytes),0) DeductedBytes
	, (
		select t2.AllSplitAndDistinct from (
			select 
				STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
				from (
					select distinct trim(element) E
					from dbo.SplitString(STRING_AGG(D.FileTypes, '; '), '; ')
				) t1) t2) FileTypes
	, 1 IsDraft
	, 1 IsNormalInventory
	, sum(IsNull(D.TextDocsCount,0)) TextDocsCount
	, sum(IsNull(D.GraphicalDocsCount,0)) GraphicalDocsCount

from 
  InventoryDrafts A
left outer join v_ArchivalEntitySizeInfo D on D.InventorySystemIdentifier = A.SystemIdentifier
where A.Deleted = 0 and A.IsCurrent = 1 and IsNull(A.DescriptionLevelCode,'5') = '5' -- normal inventory
and (D.InventorySystemIdentifier is null or D.IsDraft = 1)
group by A.SystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode

union all

select distinct
	A.SystemIdentifier InventorySystemIdentifier
	, A.FundSystemIdentifier 
	
	, IsNull(A.AvailabilityStatusCode,0) InventoryAvailabilityStatusCode
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledInventory
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedInventory

	, IsNull(sum(D.EnrolledArchivalEntity),0) EnrolledArchivalEntityCount
	, IsNull(sum(D.DeductedArchivalEntity),0) DeductedArchivalEntityCount

	, IsNull(sum(D.EnrolledDocumentCount),0) EnrolledDocumentCount
	, IsNull(sum(D.DeductedDocumentCount),0) DeductedDocumentCount

	, IsNull(sum(D.EnrolledBytes),0) EnrolledBytes
	, IsNull(sum(D.DeductedBytes),0) DeductedBytes
	, (
		select t2.AllSplitAndDistinct from (
			select 
				STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
				from (
					select distinct trim(element) E
					from dbo.SplitString(STRING_AGG(D.FileTypes, '; '), '; ')
				) t1) t2) FileTypes
	, 0 IsDraft
	, 1 IsNormalInventory
	, sum(IsNull(D.TextDocsCount,0)) TextDocsCount
	, sum(IsNull(D.GraphicalDocsCount,0)) GraphicalDocsCount

from 
  Inventories A
left outer join v_ArchivalEntitySizeInfo D on D.InventorySystemIdentifier = A.SystemIdentifier
where A.Deleted = 0 and IsNull(A.DescriptionLevelCode,'5') = '5' -- normal inventory
and (D.InventorySystemIdentifier is null or D.IsDraft = 0)
group by A.SystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode


union all


select distinct
	A.SystemIdentifier InventorySystemIdentifier
	, A.FundSystemIdentifier 
	
	, IsNull(A.AvailabilityStatusCode,0) InventoryAvailabilityStatusCode
	-- 13.04.23 - do not count raw inventories as enrolled or deducted
	--, case when IsNull(A.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledInventory
	--, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedInventory
	, 0 as EnrolledInventory
	, 0 as DeductedInventory

	, 0 EnrolledArchivalEntityCount
	, 0 DeductedArchivalEntityCount

	-- 13.04.23 - files count expected as document count
	--, 0 EnrolledDocumentCount
	--, 0 DeductedDocumentCount
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then IsNull(count(D.Id), 0) else 0 end EnrolledDocumentCount
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then IsNull(count(D.Id), 0) else 0 end DeductedDocumentCount

	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) else 0 end EnrolledBytes
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) else 0 end DeductedBytes
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then STRING_AGG(D.FileType, '; ') else null end FileTypes
	, 1 IsDraft
	, 0 IsNormalInventory
	, 0 TextDocsCount
	, 0 GraphicalDocsCount

from 
  InventoryDrafts A
join PackageDocument D on D.PackageId = A.PackageBId
where A.Deleted = 0 and A.IsCurrent = 1 and (A.DescriptionLevelCode = '6' OR A.DescriptionLevelCode = '12') -- raw inventory
and A.StatusCode in ('1', '10') -- Нов, Необработен
and D.Deleted = 0
group by A.SystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode



union all


select distinct
	A.SystemIdentifier InventorySystemIdentifier
	, A.FundSystemIdentifier 
	
	, IsNull(A.AvailabilityStatusCode,0) InventoryAvailabilityStatusCode
	-- 13.04.23 - do not count raw inventories as enrolled or deducted
	--, case when IsNull(A.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledInventory
	--, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedInventory
	, 0 as EnrolledInventory
	, 0 as DeductedInventory

	, 0 EnrolledArchivalEntityCount
	, 0 DeductedArchivalEntityCount

	-- 13.04.23 - files count expected as document count
	--, 0 EnrolledDocumentCount
	--, 0 DeductedDocumentCount
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then IsNull(count(D.Id), 0) else 0 end EnrolledDocumentCount
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then IsNull(count(D.Id), 0) else 0 end DeductedDocumentCount

	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) else 0 end EnrolledBytes
	, case when IsNull(A.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) else 0 end DeductedBytes
	, case when IsNull(A.AvailabilityStatusCode,0) = 1 then STRING_AGG(D.FileType, '; ') else null end FileTypes
	, 0 IsDraft
	, 0 IsNormalInventory
	, 0 TextDocsCount
	, 0 GraphicalDocsCount

from 
  Inventories A
join PackageDocument D on D.PackageId = A.PackageBId
where A.Deleted = 0 and (A.DescriptionLevelCode = '6' OR A.DescriptionLevelCode = '12') -- raw inventory
and A.StatusCode in ('1', '10') -- Нов, Необработен
and D.Deleted = 0
group by A.SystemIdentifier, A.FundSystemIdentifier, A.AvailabilityStatusCode

GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetRegisterOfDigitizedDocumentsReport]
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null,
	@RegisteredFrom datetime2(7) = null,
	@RegisteredTo datetime2(7) = null
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка

	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by ArchiveSortOrder, FundNumber, InventoryNumber, ArchiveEntityNumber -- ако се добавят FundIntNumber, InventoryIntNumber, ArchivalEntityIntNumber бави твърде много
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT 
			''document'' as DocumentLink, -- Link_todo
			(select CAST(a.Code as nvarchar(10)) from archive as a where _retired = ''3000-01-01'' and Gid = d.ArchiveGid) as ArchiveCode,
			a.Name as ArchiveName,
			CAST(d.Gid as nvarchar(256)) as SystemId,
			(select n.Value FROM Nomenclature as n where _retired = ''3000-01-01'' and Gid = (SELECT LevelOfDescriptionGid from Fund_Modified f where f.LGid = d.FundLGid)) as LevelOfDescription,
			(select top 1 Number from Fund_Modified f where f.LGid = d.FundLGid) as FundNumber,
			(select i.Number from Inventory_Modified as i where i.LGid = d.InventoryLGid) as InventoryNumber,
			(select ae.Number from ArchiveEntity_Modified as ae where ae.LGid = d.AELGid) as ArchiveEntityNumber,
			CAST(d.Title as nvarchar(256)) as Title,
			convert(varchar, d.DOCreationDate, 104) as DocCreationDate,
			(select n.Value + '', ''
				from Nomenclature n
				inner join ObjectNomenclature objn on n.Gid = objn.NomenclatureGid and objn._retired = ''3000-01-01'' and objn.DocumentGid = d.Gid
				where 
				n._retired = ''3000-01-01''
				and n.[Type] = ''Annotated''
				FOR XML path(''''), elements) as Themes,
			(select n.Value FROM Nomenclature as n where _retired = ''3000-01-01'' and Gid = d.StatusGid) as DocStatus,
			(select top(1) convert(varchar, img.CreatedOn, 104) from Image as img where d.Gid = img.DocumentGid and img._retired = ''3000-01-01'') as CreationDateDO,
			0 as RecordsCountDO,
			NULL as Duration,
			(
				select convert(varchar, max(p.ModifiedOn), 104)  
				from Document doc
				inner join Process p on p._retired = ''3000-01-01'' and p.Gid = doc.ProcessGid and p.TypeGid = 2124 and p.StepGid = 75
				where doc.LGid = d.lgid
			) as DigitalObjectRecreationDate,
			CAST(0 as bigint) as BytesDO, -- това по тяхно искане не трябва да се отчита
			case when isnull(d.DigitalObjectDeleted, 0) = 0 then ''Активен'' else ''Заличен'' end as StatusDO,
			d.DOCreationAuthor as Operator,
			NULL as CorrectionReturnDate,
			convert(varchar, d.ModifiedOn, 104) as FinalCorrectionDate,
			(
				select convert(varchar, max(p.ModifiedOn), 104)  
				from Document doc
				inner join Process p on p._retired = ''3000-01-01'' and p.Gid = doc.ProcessGid and p.TypeGid = 2123 and p.StepGid = 75
				where doc.LGid = d.lgid
			) as DigitalObjectAcceptanceDate,
			(select top 1 IntNumber from Fund_Modified f where f.LGid = d.FundLGid) as FundIntNumber,
			(select i.IntNumber from Inventory_Modified as i where i.LGid = d.InventoryLGid) as InventoryIntNumber,
			(select ae.IntNumber from ArchiveEntity_Modified as ae where ae.LGid = d.AELGid) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder,
			NULL as MastersCount,
			NULL as AllDOCount
		FROM Document_Modified as d
		INNER JOIN Archive a ON a.Gid = d.ArchiveGid AND a._retired = ''3000-01-01''
		--inner join Fund_Modified f on f.LGid = d.FundLGid
		--inner join Inventory_Modified i on i.LGid = d.InventoryLGid
		--inner join ArchiveEntity_Modified ae on ae.LGid = d.AELGid
		LEFT OUTER JOIN [Image] img on d.Gid = img.DocumentGid and img._retired = ''3000-01-01''
		WHERE ISNULL(d.HasDigitalObject, 0) = 1
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) '

		IF (@RegisteredFrom IS NOT NULL)
		BEGIN
			SET @remoteQuery += 'AND cast(d.DOCreationDate as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
		END

		IF(@RegisteredTo IS NOT NULL)
		BEGIN
			SET @remoteQuery +='AND cast(d.DOCreationDate as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
		END
		
		SET @remoteQuery += ' GROUP BY
			d.LGid, 
			d.ArchiveGid, 
			d.CreationDate, 
			d.Title, 
			d.StatusGid, 
			d.DigitalObjectDeleted, 
			d.DigitalObjectDeleted, 
			d.DOCreationDate, 
			d.FundLGid, 
			d.InventoryLGid, 
			d.AELGid, 
			d.Gid,
			d.StartDateDay,
			d.StartDateMonth,
			d.StartDateYear,
			d.EndDateDay,
			d.EndDateMonth,
			d.EndDateYear,
			d.TextDate,
			d.DOCreationAuthor,
			d.ModifiedOn,
			a.Name,
			a.SortOrder--,
			--f.Number,
			--i.Number,
			--ae.Number
		'
			  
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT 
			''document'' as DocumentLink,
			CAST((select a.Code FROM [Archives] as a where a.Id = ArchiveId) as nvarchar(256)) as ArchiveCode,
			a.Name as ArchiveName,
			CAST(d.SystemIdentifier as nvarchar(256)) as SystemId,
			(select fdl.Text FROM [N].[FundDescriptionLevel] as fdl where fdl.Code = (select f.DescriptionLevelCode FROM Funds f where f.SystemIdentifier = d.FundSystemIdentifier)) as LevelOfDescription,
			CAST((select f.Number FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as nvarchar(256)) as FundNumber,
			CAST((select i.Number FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as nvarchar(256)) as InventoryNumber,
			CAST((select ae.Number FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as nvarchar(256)) as ArchiveEntityNumber,
			CAST(d.Title as nvarchar(256)) as Title,
			convert(varchar, d.CreatedOn, 104) as DocCreationDate,
			NULL as Themes,
			(select s.Text from N.Status as s where s.Code = d.StatusCode) as DocStatus,
			CAST((select top(1) convert(varchar, do.CreatedOn, 104) from DigitalObjects as do where do.DocumentSystemIdentifier = d.SystemIdentifier) as nvarchar(50)) as CreationDateDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
			d.DigitizedCopyCount as RecordsCountDO,
			CAST(d.Duration as nvarchar(256)) as Duration,
			(select convert(varchar, d.UpdatedOn, 104) where d.StatusCode = 9) as DigitalObjectRecreationDate,
			isnull(dsi.EnrolledBytes, 0) as BytesDO,
			(select top(1) n.Text from N.Nomenclatures as n join DigitalObjects as do on n.Id = do.StatusCode where do.DocumentSystemIdentifier = d.SystemIdentifier and n.Deleted = 0) as StatusDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
			(select top(1) u.DisplayName from AspNetUsers as u join DigitalObjects as do on u.Id = do.CreatedBy where do.DocumentSystemIdentifier = d.SystemIdentifier and do.Deleted = 0) as Operator,
			(select top(1) convert(varchar, p.CreatedOn, 104) from Process as p where p.DocumentSystemIdentifier = d.SystemIdentifier and p.ProcessTypeId = 4 and p.Deleted = 0 order by p.CreatedOn desc) as CorrectionReturnDate,
			isnull(convert(varchar, d.UpdatedOn, 104), convert(varchar, d.CreatedOn, 104)) as FinalCorrectionDate,
			(select top(1) convert(varchar, p.UpdatedOn, 104) from Process as p where p.DocumentSystemIdentifier = d.SystemIdentifier and p.ProcessTypeId = 8 and p.Deleted = 0 order by p.UpdatedOn DESC) as DigitalObjectAcceptanceDate,
			(select f.NumberNumeric FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as FundIntNumber,
			(select i.NumberNumeric FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as InventoryIntNumber,
			(select ae.NumberNumeric FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder,
			(select COUNT(*) from DigitalObjects as do where d.SystemIdentifier = do.DocumentSystemIdentifier and do.Deleted = 0 and do.IsDigitized = 1 and TypeCode = 1) as MastersCount,
			(select COUNT(*) from DigitalObjects as do where d.SystemIdentifier = do.DocumentSystemIdentifier and do.Deleted = 0 and do.IsDigitized = 1) as AllDOCount
		FROM Documents as d
		INNER JOIN Archives a ON a.Id = d.ArchiveId AND a.Deleted = 0
		LEFT JOIN v_DocumentSizeInfo dsi ON dsi.DocumentSystemIdentifier = d.SystemIdentifier AND dsi.IsDraft = 0
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
			  AND exists(select 1 from DigitalObjects do where d.SystemIdentifier = do.DocumentSystemIdentifier and do.Deleted = 0 and do.IsDigitized =1)
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
			  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))) '
		

		IF (@RegisteredFrom IS NOT NULL)
		BEGIN
			SET @localQuery += 'AND cast(d.CreatedOn as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
		END

		IF(@RegisteredTo IS NOT NULL)
		BEGIN
			SET @localQuery +='AND cast(d.CreatedOn as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
		END

	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteDigitizedDocumentsTable TABLE (
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
				ArchiveSortOrder int null,
				MastersCount int NULL,
				AllDOCount int NULL
			);

			INSERT INTO @remoteDigitizedDocumentsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteDigitizedDocumentsTable
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

	EXEC (@sql);
END
GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetRegisterOfDigitizedDocumentsSummary]
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null,
	@RegisteredFrom datetime2(7) = null,
	@RegisteredTo datetime2(7) = null
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка

	SET @RowsOfPage = 2147483647
	SET @Page = 1

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
				Duration bigint NULL,
				DigitalObjectRecreationDate nvarchar(50) NULL,
				MbDO float NULL,
				StatusDO nvarchar(MAX) NULL,
				Operator nvarchar(MAX) NULL,
				CorrectionReturnDate nvarchar(50) NULL,
				FinalCorrectionDate nvarchar(50) NULL,
				DigitalObjectAcceptanceDate nvarchar(50) NULL,
				FundIntNumber INT NULL,
				InventoryIntNumber INT NULL,
				ArchivalEntityIntNumber INT NULL,
				ArchiveSortOrder INT NULL,
				MastersCount INT NULL,
				AllDOCount INT NULL
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
				MbDO,
				StatusDO,
				Operator,
				CorrectionReturnDate,
				FinalCorrectionDate,
				DigitalObjectAcceptanceDate,
				FundIntNumber,
				InventoryIntNumber,
				ArchivalEntityIntNumber,
				ArchiveSortOrder,
				MastersCount,
				AllDOCount
			)
	EXEC [sp_GetRegisterOfDigitizedDocumentsReport]
	@LinkedServer,
	@ResultType,
	@RowsOfPage,
	@Page,
	@ArchiveCodes,
	@RegisteredFrom,
	@RegisteredTo

	

	SET @sql = '
		SELECT COUNT_BIG(*) as TotalRows, sum(ISNULL(MbDO, 0)) as TotalBytesCount, sum(ISNULL(Duration, 0)) as TotalDuration, SUM(ISNULL(MastersCount, 0)) as MastersCount, SUM(ISNULL(AllDOCount, 0)) as AllDOCount
		FROM #temp'

	
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
	@RegisteredFrom datetime2(7) = null,
	@RegisteredTo datetime2(7) = null
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка

	SET @RowsOfPage = 2147483647
	SET @Page = 1

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT top 1
			''' + ISNULL(CONVERT(nvarchar(50), @RegisteredFrom, 23), '') + '''  as PeriodFrom,
			''' + ISNULL(CONVERT(nvarchar(50), @RegisteredTo, 23), '') + ''' as PeriodTo,
			NULL as Employee
		FROM Document_Modified as d
		INNER JOIN Archive a ON a.Gid = d.ArchiveGid AND a._retired = ''3000-01-01''
		--inner join Fund_Modified f on f.LGid = d.FundLGid
		--inner join Inventory_Modified i on i.LGid = d.InventoryLGid
		--inner join ArchiveEntity_Modified ae on ae.LGid = d.AELGid
		LEFT OUTER JOIN [Image] img on d.Gid = img.DocumentGid and img._retired = ''3000-01-01''
		WHERE ISNULL(d.HasDigitalObject, 0) = 1
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) '

		IF (@RegisteredFrom IS NOT NULL)
		BEGIN
			SET @remoteQuery += 'AND cast(d.DOCreationDate as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
		END

		IF(@RegisteredTo IS NOT NULL)
		BEGIN
			SET @remoteQuery +='AND cast(d.DOCreationDate as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
		END

		SET @remoteQuery += '
		GROUP BY
			d.LGid, 
			d.ArchiveGid, 
			d.CreationDate, 
			d.Title, 
			d.StatusGid, 
			d.DigitalObjectDeleted, 
			d.DigitalObjectDeleted, 
			d.DOCreationDate, 
			d.FundLGid, 
			d.InventoryLGid, 
			d.AELGid, 
			d.Gid,
			d.StartDateDay,
			d.StartDateMonth,
			d.StartDateYear,
			d.EndDateDay,
			d.EndDateMonth,
			d.EndDateYear,
			d.TextDate,
			d.DOCreationAuthor,
			a.Name,
			a.SortOrder,
			(cast(d.StartDate as date)),
			(cast(d.EndDate as date))
			--f.Number,
			--i.Number,
			--ae.Number
		'
			  
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		--DECLARE @localQuery VARCHAR(MAX) = '
		--SELECT TOP 1
		--	''' + COALESCE(@RegisteredFrom, '') + '''  as PeriodFrom,
		--	''' + COALESCE(@RegisteredTo, '') + ''' as PeriodTo,
		--	NULL as Employee
		--FROM Documents as d
		--INNER JOIN Archives a ON a.Id = d.ArchiveId AND a.Deleted = 0
		--WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
		--	  AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
		--	  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
		--	  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
		--	  AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[StartDateYear], d.[StartDateMonth], d.[StartDateDay]) as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
		--	  AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[EndDateYear], d.[EndDateMonth], d.[EndDateDay]) as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))'

		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT TOP 1
			''' + ISNULL(CONVERT(nvarchar(50), @RegisteredFrom, 23), '') + '''  as PeriodFrom,
			''' + ISNULL(CONVERT(nvarchar(50), @RegisteredTo, 23), '') + ''' as PeriodTo,
			NULL as Employee
		FROM Documents as d
		INNER JOIN Archives a ON a.Id = d.ArchiveId AND a.Deleted = 0
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
			  AND exists(select 1 from DigitalObjects do where d.SystemIdentifier = do.DocumentSystemIdentifier and do.Deleted = 0)
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
			  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))) '

		IF (@RegisteredFrom IS NOT NULL)
		BEGIN
			SET @localQuery += 'AND cast(d.CreatedOn as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
		END

		IF(@RegisteredTo IS NOT NULL)
		BEGIN
			SET @localQuery +='AND cast(d.CreatedOn as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
		END

	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteDigitizedDocumentsTable TABLE (
				PeriodFrom nvarchar(50) NULL,
				PeriodTo nvarchar(50) NULL,
				Employee nvarchar(max) NULL
			);

			INSERT INTO @remoteDigitizedDocumentsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteDigitizedDocumentsTable
			UNION ALL
			' +
			@localQuery;
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery;
	END


	EXEC (@sql);
END
GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER view [dbo].[v_DigitalObjectSizeInfo]
AS

select 
	DO.SystemIdentifier DOSystemIdentifier
	, DO.DocumentSystemIdentifier
	, DO.ArchivalEntitySystemIdentifier
	, DO.InventorySystemIdentifier
	, DO.FundSystemIdentifier
	, DO.TypeCode
	, DO.FileType
	, 1 IsDraft
from 
	DigitalObjectDrafts DO
where DO.Deleted = 0 and DO.IsCurrent = 1 


union all

select 
	DO.SystemIdentifier DOSystemIdentifier
	, DO.DocumentSystemIdentifier
	, DO.ArchivalEntitySystemIdentifier
	, DO.InventorySystemIdentifier
	, DO.FundSystemIdentifier
	, DO.TypeCode
	, DO.FileType
	, 0 IsDraft
from 
	DigitalObjects DO
where DO.Deleted = 0 

GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   view [dbo].[v_DocumentSizeInfo]
AS

select distinct
	D.SystemIdentifier DocumentSystemIdentifier
	, D.ArchivalEntitySystemIdentifier
	, D.InventorySystemIdentifier
	, D.FundSystemIdentifier
		
	, IsNull(D.AvailabilityStatusCode,0) DocAvailabilityStatusCode
	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledDocument
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedDocument

	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then IsNull(count(DO.Id),0) else 0 end EnrolledDigitalObjectsCount
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then IsNull(count(DO.Id),0) else 0 end DeductedDigitalObjectsCount

	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(DO.FileSize,0)),0) else 0 end EnrolledBytes
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(DO.FileSize,0)),0) else 0 end DeductedBytes

	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(DO.Duration,0)),0) else 0 end EnrolledDuration
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(DO.Duration,0)),0) else 0 end DeductedDuration

	, case 
		when IsNull(D.AvailabilityStatusCode,0) = 1 then  (
			select t2.AllSplitAndDistinct from (
				select 
					STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
					from (
						select distinct trim(element) E
						from dbo.SplitString(STRING_AGG(VDO.FileType, '; '), '; ')
					) t1) t2) 
		else null end FileTypes
	, 1 IsDraft
	, IsNull(D.TextDocsCount, 0) TextDocsCount
	, IsNull(D.GraphicalDocsCount, 0) GraphicalDocsCount
from 
	DocumentDrafts D
left outer join DigitalObjectDrafts DO on DO.DocumentSystemIdentifier = D.SystemIdentifier
left outer join v_DigitalObjectSizeInfo VDO on VDO.DocumentSystemIdentifier = D.SystemIdentifier
where D.Deleted = 0 and D.IsCurrent = 1
and (DO.Id is null or (DO.Deleted = 0 and DO.IsCurrent = 1 and DO.TypeCode = 1)) -- master file
and (VDO.DOSystemIdentifier is null or VDO.IsDraft = 1)
group by D.SystemIdentifier, D.ArchivalEntitySystemIdentifier, D.InventorySystemIdentifier, D.FundSystemIdentifier, D.AvailabilityStatusCode, D.TextDocsCount, D.GraphicalDocsCount


union all

select distinct
	D.SystemIdentifier DocumentSystemIdentifier
	, D.ArchivalEntitySystemIdentifier
	, D.InventorySystemIdentifier
	, D.FundSystemIdentifier

	, IsNull(D.AvailabilityStatusCode,0) DocAvailabilityStatusCode
	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then 1 else 0 end EnrolledDocument
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then 1 else 0 end DeductedDocument
	
	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then IsNull(count(DO.Id),0) else 0 end EnrolledDigitalObjectsCount
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then IsNull(count(DO.Id),0) else 0 end DeductedDigitalObjectsCount

	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(DO.FileSize,0)),0) else 0 end EnrolledBytes
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(DO.FileSize,0)),0) else 0 end DeductedBytes

	, case when IsNull(D.AvailabilityStatusCode,0) = 1 then IsNull(sum(IsNull(DO.Duration,0)),0) else 0 end EnrolledDuration
	, case when IsNull(D.AvailabilityStatusCode,0) <> 1 then IsNull(sum(IsNull(DO.Duration,0)),0) else 0 end DeductedDuration

	, case 
		when IsNull(D.AvailabilityStatusCode,0) = 1 then  (
			select t2.AllSplitAndDistinct from (
				select 
					STRING_AGG(t1.E,  '; ') AllSplitAndDistinct
					from (
						select distinct trim(element) E
						from dbo.SplitString(STRING_AGG(VDO.FileType, '; '), '; ')
					) t1) t2) 
		else null end FileTypes
	, 0 IsDraft
	, IsNull(D.TextDocsCount, 0) TextDocsCount
	, IsNull(D.GraphicalDocsCount, 0) GraphicalDocsCount
from 
	Documents D
left outer join DigitalObjects DO on DO.DocumentSystemIdentifier = D.SystemIdentifier
left outer join v_DigitalObjectSizeInfo VDO on VDO.DocumentSystemIdentifier = D.SystemIdentifier
where D.Deleted = 0 
and (DO.Id is null or (DO.Deleted = 0 and DO.TypeCode = 1)) -- master file
and (VDO.DOSystemIdentifier is null or VDO.IsDraft = 0)
group by D.SystemIdentifier, D.ArchivalEntitySystemIdentifier, D.InventorySystemIdentifier, D.FundSystemIdentifier, D.AvailabilityStatusCode, D.TextDocsCount, D.GraphicalDocsCount

GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[sp_GetArchiveEntitiesByInventoryPublic]
	@LinkedServer nvarchar(255) = '', 
	@InventoryIdentifier uniqueidentifier = NULL,
	@InventoryHasExternalSource bit,
	@InventoryExternalIdentifier int = NULL,
	@SearchText nvarchar(max) = NULL,
	@SearchNumber nvarchar(max) = NULL,
	@IncludeDeleted bit = false,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @RemoteArchivalEntitiesQuery nvarchar(max) = '';
    DECLARE @RemoteArchivalEntities TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,IntNumber int
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,TapeCount int
		,MicrofilmCount int 
		,FrameCount int
		,VideoTapeCount int
		,DigitalDeviceCount int 
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Location nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,Features nvarchar(max)
		,Notes nvarchar(max)
		,Description nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,EnrolledDocumentCount int
        ,EnrolledLinearMeters float
        ,DeductedDocumentCount int
        ,DeductedLinearMeters float
		,SheetCount int
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,NumberArray  nvarchar(250) null
		,ClassificationSchemeIndex nvarchar(250) null
	);

	DECLARE @LocalArchivalEntities TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,IntNumber int
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,TapeCount int
		,MicrofilmCount int 
		,FrameCount int
		,VideoTapeCount int
		,DigitalDeviceCount int 
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Location nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,Features nvarchar(max)
		,Notes nvarchar(max)
		,Description nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,EnrolledDocumentCount int
        ,EnrolledLinearMeters float
        ,DeductedDocumentCount int
        ,DeductedLinearMeters float
		,SheetCount int
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,NumberArray  nvarchar(250) null
		,ClassificationSchemeIndex nvarchar(250) null
	);

	IF @InventoryHasExternalSource = 1
	BEGIN 

		SET @RemoteArchivalEntitiesQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
		,CAST(NULL as uniqueidentifier) as SystemIdentifier
		,CAST(1 as bit) as HasExternalSource
		,ae.[LGid] as ExternalIdentifier
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
		,CAST(1 as bit) as InventoryHasExternalSource
		,(select LGid from [Archiving].[dbo].Inventory_Active i where i.LGid = ae.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryExternalIdentifier
		,(select Number from [Archiving].[dbo].Inventory_Active i where i.LGid = ae.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryNumber
		,CAST(1 as bit) as FundHasExternalSource
		,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = ae.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
		,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = ae.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
		,(select Code from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
		,(select Name from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
		,ae.[Number] as Number
		,ae.[IntNumber] as IntNumber ' + '
		,ae.[Title] as Title
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
		,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
		,ae.[TextDate] as ApproximateChronologicalScope
		,ae.[MagnetTapesCount] as TapeCount
		,ae.[MicrofilmsCount] as MicrofilmCount
		,ae.[FramesCount] as FrameCount
		,ae.[VideoTapesCount] as VideoTapeCount 
		,ae.[ElectrCount] as DigitalDeviceCount
		,ae.[CopyMicrofilm] as MicrofilmedCopyCount
		,ae.[CopyDigital] as DigitizedCopyCount
		,ae.[PaperCount] as PaperCopyCount
		,ae.[CopyNegativFrames] as NegativeFrameCount
		,ae.[CopyPositiveFrames] as PositiveFrameCount
		,ae.[CopyOther] as OtherCopyCount
		,ae.[DimensionInCentimeters] as SizeCm
		,ae.[ExtentOther] as OtherMetrics
		,ae.[PlaceOfCreation] as Location ' + '
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
		,ae.[AccessConditions] as DocumentsAccessDescription
		,ae.[DocumentProperties] as Features
		,ae.[Note] as Notes
		,ae.[ExtendedContentDescription] as Description
		,ae.[StartDateYear] as StartDateYear
		,ae.[StartDateMonth] as StartDateMonth
		,ae.[StartDateDay] as StartDateDay
		,ae.[EndDateYear] as EndDateYear
		,ae.[EndDateMonth] as EndDateMonth
		,ae.[EndDateDay] as EndDateDay
		,ae.[IsNoDate] as HasNoChronologicalScope
		,ae.[AveilabilityDocumentsCountAssigned] as EnrolledDocumentCount
        ,ae.[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters 
        ,ae.[AveilabilityDocumentsCountDeducted] as DeductedDocumentCount
        ,ae.[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
		,ae.PaperCount as SheetCount
		,ae.[CreationDate] as CreatedOn
		,ae.[CreationAuthor] as CreatedByDisplayName
		,ae.[ModificationDate] as UpdatedOn
		,ae.[ModificationAuthor] as UpdatedByDisplayName
		,null as NumberArray
		,null as ClassificationSchemeIndex
	FROM [Archiving].[dbo].[ArchiveEntity_Active] ae
	WHERE ae.InventoryLGid = ' + CAST(@InventoryExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
		BEGIN
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  ' AND (ae.Title LIKE ''''%' + @SearchText + '%'''' OR ae.Number LIKE ''''%' + @SearchText + '%'''')'
		END;
		
		IF @SearchNumber IS NOT NULL
		BEGIN
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  'AND (ae.Number LIKE ''''' + @SearchNumber + ''''')'
			--(ae.Number LIKE ' + @SearchNumber + ')'
		END;
	

		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteArchivalEntitiesQuery + ''' )';
		
		INSERT INTO @RemoteArchivalEntities 
		EXEC(@RemoteQuery)	
	END

	IF @InventoryIdentifier IS NOT NULL
	BEGIN

		INSERT INTO @LocalArchivalEntities
		SELECT	 ae.Id
				,ae.SystemIdentifier as SystemIdentifier
				,ae.HasExternalSource
				,ae.ExternalIdentifier
				,ae.StatusCode
				,ae.StatusText
				,ae.InventoryHasExternalSource
				,ae.InventoryExternalIdentifier
				,ae.InventoryNumber
				,ae.FundHasExternalSource
				,ae.FundExternalIdentifier
				,ae.FundNumber
				,ae.ArchiveCode
				,ae.ArchiveName
				,ae.Number as Number
				,NULL as IntNumber
				,ae.Title
				,ae.DescriptionLevelCode
				,ae.DescriptionLevelText
				,ae.AvailabilityStatusCode
				,ae.AvailabilityStatusText
				,ae.ApproxmateChronologicalScope
				,ae.TapeCount
				,ae.MicrofilmCount
				,ae.FrameCount
				,ae.VideoTapeCount
				,ae.DigitalDeviceCount
				,ae.MicrofilmedCopyCount
				,ae.DigitizedCopyCount
				,ae.PaperCopyCount
				,ae.NegativeFrameCount
				,ae.PositiveFrameCount
				,ae.OtherCopyCount
				,ae.SizeCm
				,ae.OtherMetrics
				,ae.Location
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
				,ae.DocumentsAccessDescription
				,ae.Features
				,ae.Notes
				,ae.Description
				,ae.StartDateYear
				,ae.StartDateMonth
				,ae.StartDateDay
				,ae.EndDateYear
				,ae.EndDateMonth
				,ae.EndDateDay
				,ae.HasNoChronologicalScope
				,ae.EnrolledDocumentCount
				,ae.EnrolledLinearMeters
				,ae.DeductedDocumentCount
				,ae.DeductedLinearMeters
				,ae.SheetCount
				,ae.CreatedOn as CreatedOn
				,ae.CreatedByDisplayName as CreatedByDisplayName
				,ae.UpdatedOn as UpdatedOn
				,ae.UpdatedBy as UpdatedByDisplayName
				,ae.NumberArray as NumberArray
				,null as ClassificationSchemeIndex
	     FROM [dbo].[v_PublicArchivalEntities] ae
	    WHERE ae.InventorySystemIdentifier = @InventoryIdentifier 
		  AND ae.HasExternalSource = 0
		  AND ae.Deleted = 0
		  AND (@SearchText IS NULL OR (ae.Title LIKE '%'+ @SearchText +'%' OR ae.Number LIKE '%'+ @SearchText +'%'))
		  AND (@IncludeDeleted = 1 OR ae.Deleted = 0)
	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalArchivalEntities
		  UNION
		 SELECT *
		   FROM @RemoteArchivalEntities
	   ) ArchivalEntities
	ORDER BY IntNumber, NumberArray
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE OR ALTER PROCEDURE [dbo].[GetFundPublicReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null, 
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@Statuses nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@TextDate nvarchar(2000) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by SortOrder, IntNumber, Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT
				isnull(fund.LinearMeters, 0) as LinearMeters,
				null as DigitalSize,
				null as Duration,
				fund.InvetoryCount as InventoryCount,
				fund.AECount as AECount,
				fund.ImmediateSourceOfAcquisition,
				a.Name as Archive,
				fund.Number,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.TypeGid) as FundType,
				(select Value + '';''
					from Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''IndustryIndex''
					FOR XML path(''''), elements) as IndustryIndex,
				(select Value + '';''
					from Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''MethodOfAcquisition''
					FOR XML path(''''), elements) as MethodOfAcquisition,
				fund.TextDate,
				(isnull(convert(varchar, StartDateDay) + ''.'', '''') + isnull(convert(varchar, StartDateMonth) + ''.'', '''') + isnull(convert(varchar, StartDateYear), '''')) as StartDate,
				(isnull(convert(varchar, fund.EndDateDay) + ''.'', '''') + isnull(convert(varchar, fund.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, fund.EndDateYear), '''')) as EndDate,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				fund.Title,
				fund.Note,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.StatusGid) as FundStatus,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.LevelOfDescriptionGid) as LevelOfDescription,
				fund.IntNumber,
				a.SortOrder,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource,
				CAST(null as uniqueidentifier) as SystemIdentifier
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE
				((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND (fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1) 
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 4))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
                    OR ((SELECT Code FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.StatusGid) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE(@TextDate, 'null') + '''))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))';

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

		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				null as LinearMeters,
				fsi.EnrolledBytes as DigitalSize,
				cast((select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as bigint) as Duration,
				fsi.EnrolledInventoryCount as InventoryCount,
				fsi.EnrolledArchivalEntityCount as AECount,
				f.DocumentsProvider as ImmediateSourceOfAcquisition,
				a.Name as Archive,
				f.Number,
				(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
				(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''INDUSTRY_TYPE'' 
						and nv.EntityId=f.Id
					FOR XML path(''''), elements) as IndustryIndex,
				(select n1.Text from N.Nomenclatures n1 where f.AcquisitionMethodId = n1.Id) as MethodOfAcquisition,
				f.ApproxmateChronologicalScope as TextDate,
				(isnull(convert(varchar, f.StartDateDay) + ''.'', '''') + isnull(convert(varchar, f.StartDateMonth) + ''.'', '''') + isnull(convert(varchar, f.StartDateYear), '''')) as StartDate,
				(isnull(convert(varchar, f.EndDateDay) + ''.'', '''') + isnull(convert(varchar, f.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, f.EndDateYear), '''')) as EndDate,
				convert(varchar, f.CreatedOn, 104) as CreationDate,
				f.Title,
				f.Notes as Note,
				(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus,
				(SELECT Text FROM [N].[FundDescriptionLevel] dl where dl.Code = f.DescriptionLevelCode) as LevelOfDescription,
				f.NumberNumeric as IntNumber,
				a.SortOrder,
				f.ExternalIdentifier,
				f.HasExternalSource,
				f.SystemIdentifier
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			INNER JOIN N.Status s ON s.Code = f.StatusCode AND s.Code <> 12
			LEFT JOIN v_FundSizeInfo as fsi ON f.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 1 -- fund 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
					OR ((select Code from N.Nomenclatures n1 where n1.Id = f.AcquisitionMethodId) in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
					OR (convert(varchar(4), s.Code, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '','')))) 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = f.TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
				AND ((''' + ISNULL(@TextDate,  N'NULL') + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.ApproxmateChronologicalScope = ''') + ISNULL(@TextDate, N'NULL') + '''))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
					OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))	
					'
				+ @DateFromCondition
				+ @DateToCondition;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				LinearMeters float NULL, 
				DigitalSize bigint NULL,
				Duration nvarchar(14) NULL,
				InventoryCount int NULL,
				AECount int NULL,
				ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				FundType nvarchar(MAX) NULL,
				IndustryIndex nvarchar(MAX) NULL,
				MethodOfAcquisition nvarchar(MAX) NULL,
				TextDate nvarchar(256) NULL,
				StartDate varchar(256) NULL,
				EndDate varchar(50) NULL,
				CreationDate varchar(50) NULL,
				Title nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				FundStatus nvarchar(MAX) NULL,
				LevelOfDescription nvarchar(MAX) NULL,
				IntNumber int null,
				SortOrder int null,
				ExternalIdentifier int null,
				HasExternalSource bit,
				SystemIdentifier uniqueidentifier null
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteFundsTable
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

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER PROCEDURE [dbo].[GetFundsListReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(max) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by SortOrder, IntNumber, Number
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				fund.Title,
				fund.Note,
				fund.IntNumber,
				a.SortOrder,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource,
				CAST(null as uniqueidentifier) as SystemIdentifier
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)';
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreatedOn, 104) as CreationDate,
				fund.Title,
				fund.Notes as Note,
				fund.NumberNumeric as IntNumber,
				a.SortOrder,				
				fund.ExternalIdentifier,
				fund.HasExternalSource,
				fund.SystemIdentifier
			FROM Funds fund 
			INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
			INNER JOIN N.Status s ON s.Code = fund.StatusCode AND s.Code <> 12
			WHERE fund.ExternalIdentifier IS NULL AND fund.HasExternalSource = 0 AND fund.Deleted = 0 
				AND fund.DescriptionLevelCode = 1 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), a.Code, 104)) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				CreationDate varchar(50) NULL,
				Title nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null,
				SortOrder int null,
				ExternalIdentifier int null,
				HasExternalSource bit,
				SystemIdentifier uniqueidentifier null
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteFundsTable
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

	EXEC (@sql);
END
GO





-- complete old tasks 
update T
set T.ProcessId = S.ProcessId
from Tasks T
join ProcessTimeline S on S.Id = T.StepId
where T.StepId is not null
and T.ProcessId is null
go


update T
set StatusCode = 'Complete'
from Tasks T
join Process P on P.Id = T.ProcessId
where T.StatusCode = 'Pending'
and P.Completed = 1
go


update T
set StatusCode = 'Complete'
from Tasks T
join Sessions S on S.Id = T.RelatedEntityId
join SessionMinutesOfMeeting M on M.Id = S.MinutesOfMeetingId
where T.StatusCode = 'Pending'
and T.NotificationType = 'SendProtocolForApproval'
and M.Status = '3' -- Affirmed protocol
go



update T
set StatusCode = 'Complete'
from Tasks T
join EDocsCollectingApplication A on A.Id = T.RelatedEntityId 
join N.EDocsCollectingApplicationStatuses S on S.Id = A.StatusId
where T.StatusCode = 'Pending'
and NotificationType = 'ApplicationPackagesAdded'
and A.StatusId = 11 -- Завършена регистрация
go


update T
set StatusCode = 'Complete'
from Tasks T
join EDocsCollectingApplication A on A.Id = T.RelatedEntityId 
join N.EDocsCollectingApplicationStatuses S on S.Id = A.StatusId
where T.StatusCode = 'Pending'
and NotificationType = 'ApplicationPackagesAdded'
and A.StatusId = 17 -- Пренасочено към друг архив
go


-- не са нито към чернова, нито към белова на опис
update T
set StatusCode = 'Complete'
from Tasks T
join EDocsCollectingApplication A  on A.Id = T.RelatedEntityId
left join InventoryDrafts I on I.ApplicationId = T.RelatedEntityId and I.IsCurrent = 1
left join Inventories II on II.ApplicationId = T.RelatedEntityId
where T.StatusCode = 'Pending'
and NotificationType = 'ApplicationPackagesAdded'
and I.SystemIdentifier is null and II.SystemIdentifier is null
go


-- заявление в статус "Завършена регистрация"
update T
set StatusCode = 'Complete'
from Tasks T
join EDocsCollectingApplication A  on A.Id = T.RelatedEntityId
left join N.EDocsCollectingApplicationStatuses S on S.Id = A.StatusId
where T.StatusCode = 'Pending'
and NotificationType is not  null
and S.Id = 11
go




update N.ProcessSteps
set AllowTaskTemplate = 1
where Id = 236
go


-- unused tables
drop table dbo.ValuableDocsCollectingProceduresHistory
go
drop table dbo.ValuableDocsCollectingProceduresSteps
go
drop table dbo.ValuableDocsCollectingProcedures
go
drop table dbo.ValuableDocsCollectingRequest
go
drop table N.DocsCollectingProcedureSteps
go
drop table N.DocsCollectingProcedureTypes
go



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--READY
CREATE OR ALTER PROCEDURE [dbo].[sp_GetArchiveEntitiesByInventory]
	@LinkedServer nvarchar(255) = '', 
	@InventoryIdentifier uniqueidentifier = NULL,
	@InventoryHasExternalSource bit,
	@InventoryExternalIdentifier int = NULL,
	@SearchText nvarchar(max) = NULL,
	@SearchNumber nvarchar(max) = NULL,
	@IncludeDeleted bit = false,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20

AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @RemoteArchivalEntitiesQuery nvarchar(max) = '';
    DECLARE @RemoteArchivalEntities TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,IntNumber int
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,TapeCount int
		,MicrofilmCount int 
		,FrameCount int
		,VideoTapeCount int
		,DigitalDeviceCount int 
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Location nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,Features nvarchar(max)
		,Notes nvarchar(max)
		,Description nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,EnrolledDocumentCount int
        ,EnrolledLinearMeters float
        ,DeductedDocumentCount int
        ,DeductedLinearMeters float
		,SheetCount int
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,NumberArray  nvarchar(250) null
		,ClassificationSchemeIndex nvarchar(250) null

		,DescriptionAuthor nvarchar(255) null
		,Cypher nvarchar(255) null
		,TextDocsCount int null
		,GraphicalDocsCount int null
		,Phase nvarchar(255) null
		,Part nvarchar(255) null
		,Stage nvarchar(255) null
		,Author nvarchar(255) null
	);

	DECLARE @LocalArchivalEntities TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,IntNumber int
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,TapeCount int
		,MicrofilmCount int 
		,FrameCount int
		,VideoTapeCount int
		,DigitalDeviceCount int 
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Location nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,Features nvarchar(max)
		,Notes nvarchar(max)
		,Description nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,EnrolledDocumentCount int
        ,EnrolledLinearMeters float
        ,DeductedDocumentCount int
        ,DeductedLinearMeters float
		,SheetCount int
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,NumberArray  nvarchar(250) null
		,ClassificationSchemeIndex nvarchar(250) null

		,DescriptionAuthor nvarchar(255) null
		,Cypher nvarchar(255) null
		,TextDocsCount int null
		,GraphicalDocsCount int null
		,Phase nvarchar(255) null
		,Part nvarchar(255) null
		,Stage nvarchar(255) null
		,Author nvarchar(255) null
	);

	IF @InventoryHasExternalSource = 1
	BEGIN 

		SET @RemoteArchivalEntitiesQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
		,CAST(NULL as uniqueidentifier) as SystemIdentifier
		,CAST(1 as bit) as HasExternalSource
		,ae.[LGid] as ExternalIdentifier
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
		,CAST(1 as bit) as InventoryHasExternalSource
		,(select LGid from [Archiving].[dbo].Inventory_Active i where i.LGid = ae.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryExternalIdentifier
		,(select Number from [Archiving].[dbo].Inventory_Active i where i.LGid = ae.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryNumber
		,CAST(1 as bit) as FundHasExternalSource
		,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = ae.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
		,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = ae.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
		,(select Code from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
		,(select Name from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
		,ae.[Number] as Number
		,ae.[IntNumber] as IntNumber ' + '
		,ae.[Title] as Title
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
		,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
		,ae.[TextDate] as ApproximateChronologicalScope
		,ae.[MagnetTapesCount] as TapeCount
		,ae.[MicrofilmsCount] as MicrofilmCount
		,ae.[FramesCount] as FrameCount
		,ae.[VideoTapesCount] as VideoTapeCount 
		,ae.[ElectrCount] as DigitalDeviceCount
		,ae.[CopyMicrofilm] as MicrofilmedCopyCount
		,ae.[CopyDigital] as DigitizedCopyCount
		,ae.[PaperCount] as PaperCopyCount
		,ae.[CopyNegativFrames] as NegativeFrameCount
		,ae.[CopyPositiveFrames] as PositiveFrameCount
		,ae.[CopyOther] as OtherCopyCount
		,ae.[DimensionInCentimeters] as SizeCm
		,ae.[ExtentOther] as OtherMetrics
		,ae.[PlaceOfCreation] as Location ' + '
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
		,ae.[AccessConditions] as DocumentsAccessDescription
		,ae.[DocumentProperties] as Features
		,ae.[Note] as Notes
		,ae.[ExtendedContentDescription] as Description
		,ae.[StartDateYear] as StartDateYear
		,ae.[StartDateMonth] as StartDateMonth
		,ae.[StartDateDay] as StartDateDay
		,ae.[EndDateYear] as EndDateYear
		,ae.[EndDateMonth] as EndDateMonth
		,ae.[EndDateDay] as EndDateDay
		,ae.[IsNoDate] as HasNoChronologicalScope
		,ae.[AveilabilityDocumentsCountAssigned] as EnrolledDocumentCount
        ,ae.[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters 
        ,ae.[AveilabilityDocumentsCountDeducted] as DeductedDocumentCount
        ,ae.[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
		,ae.PaperCount as SheetCount
		,ae.[CreationDate] as CreatedOn
		,ae.[CreationAuthor] as CreatedByDisplayName
		,ae.[ModificationDate] as UpdatedOn
		,ae.[ModificationAuthor] as UpdatedByDisplayName
		,null as NumberArray
		,null as ClassificationSchemeIndex
		
		,null as DescriptionAuthor 
		,null as Cypher 
		,null as TextDocsCount
		,null as GraphicalDocsCount
		,null as Phase
		,null as Part
		,null as Stage
		,null as Author
	FROM [Archiving].[dbo].[ArchiveEntity_Active] ae
	WHERE ae.InventoryLGid = ' + CAST(@InventoryExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
		BEGIN
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  ' AND (ae.Title LIKE ''''%' + @SearchText + '%'''' OR ae.Number LIKE ''''%' + @SearchText + '%'''')'
		END;

		IF @SearchNumber IS NOT NULL
		BEGIN
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  'AND ( ae.Number LIKE '+ @SearchNumber +')'
		END;

		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteArchivalEntitiesQuery + ''' )';
		
		INSERT INTO @RemoteArchivalEntities 
		EXEC(@RemoteQuery)

		
	END

	IF @InventoryIdentifier IS NOT NULL
	BEGIN

		INSERT INTO @LocalArchivalEntities
		SELECT	 ae.Id
				,ae.SystemIdentifier as SystemIdentifier
				,ae.HasExternalSource
				,ae.ExternalIdentifier
				,ae.StatusCode
				,ae.StatusText
				,ae.InventoryHasExternalSource
				,ae.InventoryExternalIdentifier
				,ae.InventoryNumber
				,ae.FundHasExternalSource
				,ae.FundExternalIdentifier
				,ae.FundNumber
				,ae.ArchiveCode
				,ae.ArchiveName
				,ae.Number as Number
				,ae.NumberNumeric as IntNumber
				,ae.Title
				,ae.DescriptionLevelCode
				,ae.DescriptionLevelText
				,ae.AvailabilityStatusCode
				,ae.AvailabilityStatusText
				,ae.ApproxmateChronologicalScope
				,ae.TapeCount
				,ae.MicrofilmCount
				,ae.FrameCount
				,ae.VideoTapeCount
				,ae.DigitalDeviceCount
				,ae.MicrofilmedCopyCount
				,ae.DigitizedCopyCount
				,ae.PaperCopyCount
				,ae.NegativeFrameCount
				,ae.PositiveFrameCount
				,ae.OtherCopyCount
				,ae.SizeCm
				,ae.OtherMetrics
				,ae.Location
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
				,ae.DocumentsAccessDescription
				,ae.Features
				,ae.Notes
				,ae.Description
				,ae.StartDateYear
				,ae.StartDateMonth
				,ae.StartDateDay
				,ae.EndDateYear
				,ae.EndDateMonth
				,ae.EndDateDay
				,ae.HasNoChronologicalScope
				,ae.EnrolledDocumentCount
				,ae.EnrolledLinearMeters
				,ae.DeductedDocumentCount
				,ae.DeductedLinearMeters
				,ae.SheetCount
				,ae.CreatedOn as CreatedOn
				,ae.CreatedByDisplayName as CreatedByDisplayName
				,ae.UpdatedOn as UpdatedOn
				,ae.UpdatedBy as UpdatedByDisplayName
				,ae.NumberArray as NumberArray
				,ae.ClassificationSchemeIndex as ClassificationSchemeIndex

				,ae.DescriptionAuthor as DescriptionAuthor 
				,ae.Cypher as Cypher 
				,ae.TextDocsCount as TextDocsCount
				,ae.GraphicalDocsCount as GraphicalDocsCount
				,ae.Phase as Phase
				,ae.Part as Part
				,ae.Stage as Stage
				,ae.Author as Author
	     FROM [dbo].[v_ArchivalEntities] ae
	    WHERE ae.InventorySystemIdentifier = @InventoryIdentifier 
		  AND ae.HasExternalSource = 0
		  AND ae.Deleted = 0
		  AND (@SearchText IS NULL OR (ae.Title LIKE '%'+ @SearchText +'%' OR ae.Number LIKE '%'+ @SearchText +'%'))
		  AND (@IncludeDeleted = 1 OR ae.Deleted = 0)

	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalArchivalEntities
		  UNION
		 SELECT *
		   FROM @RemoteArchivalEntities
	   ) ArchivalEntities
	ORDER BY IntNumber, NumberArray
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END
GO

  

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--READY
CREATE OR ALTER PROCEDURE [dbo].[sp_GetArchiveEntity] 
	@LinkedServer nvarchar(50),
	@Identifier int
AS
BEGIN
	SET NOCOUNT ON;
 
	declare @sql varchar(max) = '
		SELECT 
			-1 as Id
			,NULL as SystemIdentifier
			,CAST(1 as bit) as HasExternalSource
			,LGid as ExternalIdentifier
			,(select Code from Nomenclature n where n.Gid = AveilabilityGid and n._retired = ''3000-01-01 00:00:00.000'') as AvailabilityStatusCode
			,(select Value from Nomenclature n where n.Gid = AveilabilityGid and n._retired = ''3000-01-01 00:00:00.000'') as AvailabilityStatusText
			,(select CAST(Code as nvarchar(50)) from Nomenclature n where n.Gid = StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusCode
			,(select Value from Nomenclature n where n.Gid = StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusText
			,(select a.Code from Archive a where a.Gid = ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveCode
			,(select a.Name from Archive a where a.Gid = ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveName
			,CAST(1 AS BIT) as FundHasExternalSource
			,FundLGid as FundExternalIdentifier
			,(SELECT Number FROM Fund_Active AS fund WHERE fund.LGid = FundLGid) AS FundNumber
			,CAST(1 AS BIT) as InventoryHasExternalSource
			,InventoryLGid as InventoryExternalIdentifier
			,(SELECT Number FROM Inventory_Active AS inventory WHERE inventory.LGid = InventoryLGid) AS InventoryNumber
			,Number
			,Title
			,(select CAST(Code as nvarchar(50)) from Nomenclature n where n.Gid= LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelCode
			,(select Value from Nomenclature n where n.Gid= LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelText
			,STUFF(
				(select ''; '' + Value 
				   from ObjectNomenclature obj 
				   join Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.ArchiveEntityGid = ae.Gid and n.Type = ''CreatingType'' for XML PATH('''')), 1, 1, '''') as CreationMethodText
			  ,STUFF(
				(select ''; '' + Value 
				   from ObjectNomenclature obj 
				   join Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.ArchiveEntityGid = ae.Gid and n.Type = ''Originality'' for XML PATH('''')), 1, 1, '''') as OriginalityText
			  ,STUFF(
				(select ''; '' + Value 
				   from ObjectNomenclature obj 
				   join Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.ArchiveEntityGid = ae.Gid and n.Type = ''Language'' for XML PATH('''')), 1, 1, '''') as LanguageText
            ,[IsNoDate] as HasNoChronologicalScope
			,[StartDateYear]
			,[StartDateMonth]
			,[StartDateDay]
			,[EndDateYear]
			,[EndDateMonth]
			,[EndDateDay]
			,TextDate as ApproximateChronologicalScope
			,PlaceOfCreation AS Location 
			,AccessConditions as DocumentsAccessDescription
			,[MagnetTapesCount] as TapeCount
			,[MicrofilmsCount] as MicrofilmCount
			,[FramesCount] as FrameCount
			,[VideoTapesCount] as VideoTapeCount
			,[ElectrCount] as DigitalDeviceCount
			,[ExtentOther] as OtherMetrics -- дали е това от ИСДА?
			,[DimensionInCentimeters] as SizeCm
			,[ExtendedContentDescription] as Description
			,[SpecificDetails] as Features
			,[CopyMicrofilm] as MicrofilmedCopyCount
			,[CopyDigital] as DigitizedCopyCount
			,[CopyXerox] as PaperCopyCount
			,PaperCount as SheetCount
			,[CopyNegativFrames] as NegativeFrameCount
			,[CopyPositiveFrames] as PositiveFrameCount
			,[CopyOther] as OtherCopyCount
			,[AveilabilityDocumentsCountAssigned] as EnrolledDocumentCount
			,[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters
			,[AveilabilityDocumentsCountDeducted] as DeductedDocumentCount
			,[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
			,Note as Notes
			,ae.[CreationDate] as CreatedOn
			,ae.[CreationAuthor] as CreatedByDisplayName
			,ae.[ModificationDate] as UpdatedOn
			,ae.[ModificationAuthor] as UpdatedByDisplayName
			,null as ClassificationSchemeIndex

			,null as DescriptionAuthor 
			,null as Cypher 
			,null as TextDocsCount
			,null as GraphicalDocsCount
			,null as Phase
			,null as Part
			,null as Stage
			,null as Author
		FROM ArchiveEntity_Active ae
		WHERE 
			LGid = ' + CAST(@Identifier as varchar(10));

	set @sql = REPLACE(@sql, '''', '''''');
	declare @result varchar(max) = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''')';

	exec (@result);
END
GO



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--READY
CREATE or alter PROCEDURE [dbo].[sp_GetArchiveEntitiesByInventoryPublic]
	@LinkedServer nvarchar(255) = '', 
	@InventoryIdentifier uniqueidentifier = NULL,
	@InventoryHasExternalSource bit,
	@InventoryExternalIdentifier int = NULL,
	@SearchText nvarchar(max) = NULL,
	@SearchNumber nvarchar(max) = NULL,
	@IncludeDeleted bit = false,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @RemoteArchivalEntitiesQuery nvarchar(max) = '';
    DECLARE @RemoteArchivalEntities TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,IntNumber int
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,TapeCount int
		,MicrofilmCount int 
		,FrameCount int
		,VideoTapeCount int
		,DigitalDeviceCount int 
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Location nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,Features nvarchar(max)
		,Notes nvarchar(max)
		,Description nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,EnrolledDocumentCount int
        ,EnrolledLinearMeters float
        ,DeductedDocumentCount int
        ,DeductedLinearMeters float
		,SheetCount int
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,NumberArray  nvarchar(250) null
		,ClassificationSchemeIndex nvarchar(250) null

		,DescriptionAuthor nvarchar(255) null
		,Cypher nvarchar(255) null
		,TextDocsCount int null
		,GraphicalDocsCount int null
		,Phase nvarchar(255) null
		,Part nvarchar(255) null
		,Stage nvarchar(255) null
		,Author nvarchar(255) null
	);

	DECLARE @LocalArchivalEntities TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,IntNumber int
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,TapeCount int
		,MicrofilmCount int 
		,FrameCount int
		,VideoTapeCount int
		,DigitalDeviceCount int 
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Location nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,Features nvarchar(max)
		,Notes nvarchar(max)
		,Description nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,EnrolledDocumentCount int
        ,EnrolledLinearMeters float
        ,DeductedDocumentCount int
        ,DeductedLinearMeters float
		,SheetCount int
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,NumberArray  nvarchar(250) null
		,ClassificationSchemeIndex nvarchar(250) null

		,DescriptionAuthor nvarchar(255) null
		,Cypher nvarchar(255) null
		,TextDocsCount int null
		,GraphicalDocsCount int null
		,Phase nvarchar(255) null
		,Part nvarchar(255) null
		,Stage nvarchar(255) null
		,Author nvarchar(255) null
	);

	IF @InventoryHasExternalSource = 1
	BEGIN 

		SET @RemoteArchivalEntitiesQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
		,CAST(NULL as uniqueidentifier) as SystemIdentifier
		,CAST(1 as bit) as HasExternalSource
		,ae.[LGid] as ExternalIdentifier
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
		,CAST(1 as bit) as InventoryHasExternalSource
		,(select LGid from [Archiving].[dbo].Inventory_Active i where i.LGid = ae.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryExternalIdentifier
		,(select Number from [Archiving].[dbo].Inventory_Active i where i.LGid = ae.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryNumber
		,CAST(1 as bit) as FundHasExternalSource
		,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = ae.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
		,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = ae.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
		,(select Code from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
		,(select Name from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
		,ae.[Number] as Number
		,ae.[IntNumber] as IntNumber ' + '
		,ae.[Title] as Title
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
		,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
		,ae.[TextDate] as ApproximateChronologicalScope
		,ae.[MagnetTapesCount] as TapeCount
		,ae.[MicrofilmsCount] as MicrofilmCount
		,ae.[FramesCount] as FrameCount
		,ae.[VideoTapesCount] as VideoTapeCount 
		,ae.[ElectrCount] as DigitalDeviceCount
		,ae.[CopyMicrofilm] as MicrofilmedCopyCount
		,ae.[CopyDigital] as DigitizedCopyCount
		,ae.[PaperCount] as PaperCopyCount
		,ae.[CopyNegativFrames] as NegativeFrameCount
		,ae.[CopyPositiveFrames] as PositiveFrameCount
		,ae.[CopyOther] as OtherCopyCount
		,ae.[DimensionInCentimeters] as SizeCm
		,ae.[ExtentOther] as OtherMetrics
		,ae.[PlaceOfCreation] as Location ' + '
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
		,ae.[AccessConditions] as DocumentsAccessDescription
		,ae.[DocumentProperties] as Features
		,ae.[Note] as Notes
		,ae.[ExtendedContentDescription] as Description
		,ae.[StartDateYear] as StartDateYear
		,ae.[StartDateMonth] as StartDateMonth
		,ae.[StartDateDay] as StartDateDay
		,ae.[EndDateYear] as EndDateYear
		,ae.[EndDateMonth] as EndDateMonth
		,ae.[EndDateDay] as EndDateDay
		,ae.[IsNoDate] as HasNoChronologicalScope
		,ae.[AveilabilityDocumentsCountAssigned] as EnrolledDocumentCount
        ,ae.[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters 
        ,ae.[AveilabilityDocumentsCountDeducted] as DeductedDocumentCount
        ,ae.[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
		,ae.PaperCount as SheetCount
		,ae.[CreationDate] as CreatedOn
		,ae.[CreationAuthor] as CreatedByDisplayName
		,ae.[ModificationDate] as UpdatedOn
		,ae.[ModificationAuthor] as UpdatedByDisplayName
		,null as NumberArray
		,null as ClassificationSchemeIndex

			
		,null as DescriptionAuthor 
		,null as Cypher 
		,null as TextDocsCount
		,null as GraphicalDocsCount
		,null as Phase
		,null as Part
		,null as Stage
		,null as Author 
	FROM [Archiving].[dbo].[ArchiveEntity_Active] ae
	WHERE ae.InventoryLGid = ' + CAST(@InventoryExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
		BEGIN
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  ' AND (ae.Title LIKE ''''%' + @SearchText + '%'''' OR ae.Number LIKE ''''%' + @SearchText + '%'''')'
		END;
		
		IF @SearchNumber IS NOT NULL
		BEGIN
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  'AND (ae.Number LIKE ''''' + @SearchNumber + ''''')'
			--(ae.Number LIKE ' + @SearchNumber + ')'
		END;
	

		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteArchivalEntitiesQuery + ''' )';
		
		INSERT INTO @RemoteArchivalEntities 
		EXEC(@RemoteQuery)	
	END

	IF @InventoryIdentifier IS NOT NULL
	BEGIN

		INSERT INTO @LocalArchivalEntities
		SELECT	 ae.Id
				,ae.SystemIdentifier as SystemIdentifier
				,ae.HasExternalSource
				,ae.ExternalIdentifier
				,ae.StatusCode
				,ae.StatusText
				,ae.InventoryHasExternalSource
				,ae.InventoryExternalIdentifier
				,ae.InventoryNumber
				,ae.FundHasExternalSource
				,ae.FundExternalIdentifier
				,ae.FundNumber
				,ae.ArchiveCode
				,ae.ArchiveName
				,ae.Number as Number
				,NULL as IntNumber
				,ae.Title
				,ae.DescriptionLevelCode
				,ae.DescriptionLevelText
				,ae.AvailabilityStatusCode
				,ae.AvailabilityStatusText
				,ae.ApproxmateChronologicalScope
				,ae.TapeCount
				,ae.MicrofilmCount
				,ae.FrameCount
				,ae.VideoTapeCount
				,ae.DigitalDeviceCount
				,ae.MicrofilmedCopyCount
				,ae.DigitizedCopyCount
				,ae.PaperCopyCount
				,ae.NegativeFrameCount
				,ae.PositiveFrameCount
				,ae.OtherCopyCount
				,ae.SizeCm
				,ae.OtherMetrics
				,ae.Location
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
				,ae.DocumentsAccessDescription
				,ae.Features
				,ae.Notes
				,ae.Description
				,ae.StartDateYear
				,ae.StartDateMonth
				,ae.StartDateDay
				,ae.EndDateYear
				,ae.EndDateMonth
				,ae.EndDateDay
				,ae.HasNoChronologicalScope
				,ae.EnrolledDocumentCount
				,ae.EnrolledLinearMeters
				,ae.DeductedDocumentCount
				,ae.DeductedLinearMeters
				,ae.SheetCount
				,ae.CreatedOn as CreatedOn
				,ae.CreatedByDisplayName as CreatedByDisplayName
				,ae.UpdatedOn as UpdatedOn
				,ae.UpdatedBy as UpdatedByDisplayName
				,ae.NumberArray as NumberArray
				,null as ClassificationSchemeIndex

				,null as DescriptionAuthor 
				,null as Cypher 
				,null as TextDocsCount
				,null as GraphicalDocsCount
				,null as Phase
				,null as Part
				,null as Stage
				,null as Author 
	     FROM [dbo].[v_PublicArchivalEntities] ae
	    WHERE ae.InventorySystemIdentifier = @InventoryIdentifier 
		  AND ae.HasExternalSource = 0
		  AND ae.Deleted = 0
		  AND (@SearchText IS NULL OR (ae.Title LIKE '%'+ @SearchText +'%' OR ae.Number LIKE '%'+ @SearchText +'%'))
		  AND (@IncludeDeleted = 1 OR ae.Deleted = 0)
	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalArchivalEntities
		  UNION
		 SELECT *
		   FROM @RemoteArchivalEntities
	   ) ArchivalEntities
	ORDER BY IntNumber, NumberArray
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END
GO


--ADD SCRIPTS ABOVE THIS LINE. USE GO AFTER EVERY BATCH



----------------------------------------------------------
--	THE SCRIPT IS CLOSED - USE THE NEW ONE!
----------------------------------------------------------

commit
