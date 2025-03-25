

begin transaction

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetAccountAndDescriptionOfFilmDocumentsBook] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by IntNumber, Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT
				Number,		
				coalesce(
					convert(varchar, FARevicedOnDay, 104) + ''.'' + convert(varchar, FARevicedOnMonth, 104) + ''.'' + convert(varchar, FARecivedOnYear, 104), 
					convert(varchar, FARecivedOnYear, 104)) as ReceivedOn,
				-- Title, null за всички редове 
				CreationAuthor,
				-- оригинал/копие,
				ImmediateSourceOfAcquisition, -- null за всички рдеове 
				(select Value3 from Nomenclature n where n.Gid = CountryGid) as CountryOfOrigin,
				--NULL as DocumentsCharacteristics,
				--InventoryShortDescroption as InventoryShortDescription, съпроводителна текстова документация
				--документ, въз основа на който е приет, 
				coalesce(
					(Number + '' / '' 
						+ (select Number from Inventory_Modified i where i.FundLGid = LGid) + '' / ''
						+ (select top(1) Number from ArchiveEntity_Modified ae where ae.FundLGid = LGid)),
					(Number + '' / '' 
						+ (select Number from Inventory_Modified i where i.FundLGid = LGid) + '' / ''),
					(Number + '' / / '' 
						+ (select top(1) Number from ArchiveEntity_Modified ae where ae.FundLGid = LGid))					
					) as FundNumberAndInventoryAndArchiveEntiry, -- отнесен към фонд №, инвентарен опис, архивна единица  -- този ред гърми гърми за някой ред от данните, затова слагам top(1)!
				--наличие на застрахователно копие/вид носител
				Note,
				IntNumber
			FROM Fund_Modified as fund
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				  AND LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 9) -- LevelOfDescription=КМФ';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				convert(varchar(256), InventoryNumber) as Number,			
				(isnull(convert(varchar, AcceptedOnDay) + ''.'', '''') + isnull(convert(varchar, AcceptedOnMonth) + ''.'', '''') + isnull(convert(varchar, AcceptedOnYear), '''')) as ReceivedOn,
				-- NULL as Title, -- няма го при нас
				NULL as CreationAuthor, -- това не е много ясно
				-- оригинал/копие,
				Source as ImmediateSourceOfAcquisition,
				(select Text from [N].[Nomenclatures] n where n.Id = CountryId) as CountryOfOrigin,
				--DocumentsCharacteristics,
				-- съпроводителна текстова документация,
				-- документ, въз основа на който е приет, 
				NULL as FundNumberAndInventoryAndArchiveEntiry,
				--наличие на застрахователно копие/вид носител,
				Notes as Note,
				InventoryNumber as IntNumber
			FROM Films
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Number nvarchar(256) NULL,			
				ReceivedOn varchar(50) NULL,
				-- Title,
				CreationAuthor nvarchar(256) NULL,
				-- оригинал/копие,
				ImmediateSourceOfAcquisition nvarchar(2000) NULL,
				CountryOfOrigin nvarchar(MAX) NULL,
				-- DocumentsCharacteristics,
				-- съпроводителна текстова документация,
				-- документ, въз основа на който е приет,
				FundNumberAndInventoryAndArchiveEntiry nvarchar(50) NULL,
				--наличие на застрахователно копие/вид носител,
				Note nvarchar(MAX) NULL,
				IntNumber int null			
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

CREATE OR ALTER PROCEDURE [dbo].[GetAccountAndDescriptionOfFilmDocumentsBookSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(10) = null
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Fund_Modified as fund
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				  AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 9) -- LevelOfDescription=КМФ';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Films 
			WHERE --ExternalIdentifier IS NULL AND HasExternalSource = 0
				Deleted = 0 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundAvailabilityReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
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
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@ProcessGids nvarchar(max) = null,
	@ProcessTypes nvarchar(4) = null,
	@FileFormats nvarchar(4) = null,
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
				fund.Title,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.TypeGid) as FundType,
				(select Value + '';''
					from Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''MethodOfAcquisition''
					FOR XML path(''''), elements) as MethodOfAcquisition,
				fund.TextDate,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.StatusGid) as FundStatus,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.LevelOfDescriptionGid) as LevelOfDescription,
				convert(int, fund.InvetoryCount) as InventoryCount,
				convert(int, fund.AECount) as AECount,
				(select count(*) from Document_Modified d where d.FundLGid = fund.LGid) as DocumentCount,
				NULL as FileFormats,
				(select sum(isnull(i.ByteLenght, 0)) 
					from Image i
					inner join Document_Modified d
					on i.DocumentGid = d.Gid
					where d.FundLGid = fund.LGid) as Size,
				NULL as Duration,
				isnull(fund.LinearMeters, 0) LinearMeters,
				fund.Note,
				fund.IntNumber,
				a.SortOrder,
				null as SystemIdentifier,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE
				(fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE(@TextDate, 'null') + '''))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessGids + ''', '','')))  
					OR exists((select cast(TypeGid as nvarchar(50)) from Process p where p.Gid=fund.ProcessGid) intersect (select element from dbo.SplitString(''' + @ProcessGids + ''', '','')))
				)		
				--AND n._retired=''3000-01-01''';

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
				a.Name as Archive,	
				f.Number,
				f.Title,
				(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
				(select n1.Text from N.Nomenclatures n1 where f.AcquisitionMethodId = n1.Id) as MethodOfAcquisition,
				f.ApproxmateChronologicalScope as TextDate,
				convert(varchar, f.CreatedOn, 104) as CreationDate,
				(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus,
				(SELECT Text FROM [N].[FundDescriptionLevel] dl where dl.Code = f.DescriptionLevelCode) as LevelOfDescription,
				fsi.EnrolledInventoryCount as InventoryCount,
				fsi.EnrolledArchivalEntityCount as AECount,
				fsi.EnrolledDocumentCount as DocumentCount,
				fsi.FileTypes as FileFormats,
				fsi.EnrolledBytes as Size,
				dbo.FormatDuration((select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier)) as Duration,
				null as LinearMeters,
				f.Notes as Note,
				f.NumberNumeric as IntNumber,
				a.SortOrder,
				f.SystemIdentifier,
				f.ExternalIdentifier,
				f.HasExternalSource
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier AND fsi.IsDraft = 0
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode IN(1, 2, 3) 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
					OR ((select Code from N.Nomenclatures n1 where n1.Id = f.AcquisitionMethodId) in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = f.TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
					OR ((select convert(varchar(4), ProcessTypeId, 104) from Process as p where p.FundSystemIdentifier = f.SystemIdentifier and p.Deleted = 0 and p.Completed=1) in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '','')))
					--това е при случай Няма активен процес OR (''-899'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '','')) 
						--AND (exists(select convert(varchar(4), ProcessTypeId, 104) from Process as p where p.FundSystemIdentifier = SystemIdentifier and p.Deleted = 0 and p.Completed=0))
							--OR ((select convert(varchar(4), ProcessTypeId, 104) from Process as p where p.FundSystemIdentifier = SystemIdentifier and p.Deleted = 0 and p.Completed=1) in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))
						--)
					--) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FileFormats + ''', '',''))) 
					OR (exists((select nv.ValueCode 
						from NomenclatureValues nv join N.Nomenclatures n on n.Id = nv.NomenclatureId 
						join Funds as f1 on nv.EntityId = f1.Id
						where f1.Id=f.Id and nv.NomenclatureCode=''FILE_TYPE''
						and n.Deleted=0 and nv.Deleted=0) INTERSECT (select element from dbo.SplitString(''' + @FileFormats + ''', '','')))))
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
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				Title nvarchar(MAX) NULL,
				FundType nvarchar(MAX) NULL,
				MethodOfAcquisition nvarchar(MAX) NULL,
				TextDate nvarchar(256) NULL,
				CreationDate varchar(50) NULL,
				FundStatus nvarchar(MAX) NULL,
				LevelOfDescription nvarchar(MAX) NULL,
				InventoryCount int NULL,
				AECount int NULL,
				DocumentCount int NULL,
				FileFormats nvarchar(MAX) NULL,
				Size bigint NULL,
				Duration nvarchar(14) NULL,
				LinearMeters float NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null,
				SortOrder int null,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundAvailabilityReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
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
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@ProcessGids nvarchar(max) = null,
	@ProcessTypes nvarchar(4) = null,
	@FileFormats nvarchar(4) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX);

	DECLARE @remoteQueryWhereClause VARCHAR(MAX) = '
		(LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)
			OR LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)
			OR LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3))
		AND ((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
		AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
		AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
		AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
		AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
		AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
		AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
		AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE(@TextDate, 'null') + '''))
		AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
		AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
		AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessGids + ''', '','')))  
			OR exists((select cast(TypeGid as nvarchar(50)) from Process p where p.Gid=fund.ProcessGid) intersect (select element from dbo.SplitString(''' + @ProcessGids + ''', '','')))
		)		
		--AND n._retired=''3000-01-01''';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		declare @remoteQuery varchar(max) = 
			'SELECT
				COUNT(*) TotalFunds,
				sum(isnull(fund.InvetoryCount, 0)) TotalInventories,
				sum(isnull(fund.AECount, 0)) TotalArchiveEntities,
				--(select sum(sizes.Size) 
				--from 
					--(select (select sum(isnull(i.ByteLenght, 0)) 
						--from Image i
						--inner join Document_Modified d
						--on i.DocumentGid = d.Gid
						--where d.FundLGid = fund.LGid) as Size
						--from [Archiving].[dbo].[Fund_Modified] fund
						--WHERE  + @remoteQueryWhereClause + 
					--) sizes) TotalSize,
				cast(0 as bigint) TotalSize, -- по искане на клиента не се отчита
				NULL as TotalDuration,
				round(sum(fund.LinearMeters), 2) TotalLinearMeters
			FROM Fund_Modified as fund
			WHERE ' + @remoteQueryWhereClause;

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

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

	DECLARE @localQueryWhereClause VARCHAR(MAX) = '
		ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
			AND DescriptionLevelCode IN(1, 2, 3) 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0 -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
				) 
			)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
				OR ((select convert(varchar(4), ProcessTypeId, 104) from Process as p where p.FundSystemIdentifier = SystemIdentifier and p.Deleted = 0 and p.Completed=1) in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '','')))
				--това е при случай Няма активен процес OR (''-899'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '','')) 
					--AND (exists(select convert(varchar(4), ProcessTypeId, 104) from Process as p where p.FundSystemIdentifier = SystemIdentifier and p.Deleted = 0 and p.Completed=0))
						--OR ((select convert(varchar(4), ProcessTypeId, 104) from Process as p where p.FundSystemIdentifier = SystemIdentifier and p.Deleted = 0 and p.Completed=1) in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))
					--)
				--) 
			)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FileFormats + ''', '',''))) 
				OR (exists((select nv.ValueCode 
					from NomenclatureValues nv join N.Nomenclatures n on n.Id = nv.NomenclatureId 
					join Funds as f1 on nv.EntityId = f1.Id
					where f1.Id=f.Id and nv.NomenclatureCode=''FILE_TYPE''
					and n.Deleted=0 and nv.Deleted=0) INTERSECT (select element from dbo.SplitString(''' + @FileFormats + ''', '','')))))
			AND ((''' + ISNULL(@TextDate,  N'NULL') + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.ApproxmateChronologicalScope = ''') + ISNULL(@TextDate, N'NULL') + '''))
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
				OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
				OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))	
			'
			+ @DateFromCondition
			+ @DateToCondition;

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @totalDuration VARCHAR(MAX) = '' 

		IF @ResultType = 1
		BEGIN
			SET @totalDuration = '
				(select cast(sum(durations.Duration) as bigint) 
				from 
					(select (select sum(isnull(d.Duration, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) durations)';
		END

		IF @ResultType = 3
		BEGIN
			SET @totalDuration = ' 
				(select cast(sum(durations.Duration) as bigint)  
				from 
					(select (select sum(isnull(d.Duration, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) durations)
				';
		END

		DECLARE @localQuery VARCHAR(max) = '
			SELECT
				COUNT(*) TotalFunds,
				sum(isnull(fsi.EnrolledInventoryCount, 0)) TotalInventories,
				sum(isnull(fsi.EnrolledArchivalEntityCount, 0)) TotalArchiveEntities,
				sum(fsi.EnrolledBytes) TotalSize,' + 
				@totalDuration + 'TotalDuration,
				null as TotalLinearMeters
			FROM Funds f
			LEFT JOIN v_FundSizeInfo as fsi ON f.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
			WHERE ' + @localQueryWhereClause;
	END
				
	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalFunds int NULL,
				TotalInventories int NULL,
				TotalArchiveEntities int NULL,
				TotalSize bigint NULL,
				TotalDuration bigint NULL,
				TotalLinearMeters float NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT 
				sum(u.TotalFunds) as TotalFunds, 
				sum(u.TotalInventories) as TotalInventories, 
				sum(u.TotalArchiveEntities) as TotalArchiveEntities, 
				sum(u.TotalSize) as TotalSize, 
				sum(u.TotalDuration) as TotalDuration,
				sum(isnull(u.TotalLinearMeters, 0)) as TotalLinearMeters
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery;
	END

	exec (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetFundAvailabilityReportTotalRows] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
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
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@ProcessGids nvarchar(max) = null,
	@ProcessTypes nvarchar(4) = null,
	@FileFormats nvarchar(4) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = 
			'SELECT COUNT_BIG(*) TotalRows
			FROM Fund_Modified as fund	
			WHERE
				(LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)
					OR LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)
					OR LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE(@TextDate, 'null') + '''))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessGids + ''', '','')))  
					OR exists((select cast(TypeGid as nvarchar(50)) from Process p where p.Gid=fund.ProcessGid) intersect (select element from dbo.SplitString(''' + @ProcessGids + ''', '','')))
				)		
				--AND n._retired=''3000-01-01''';

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

		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Funds f
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode IN(1, 2, 3) 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0 -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
					OR ((select convert(varchar(4), ProcessTypeId, 104) from Process as p where p.FundSystemIdentifier = SystemIdentifier and p.Deleted = 0 and p.Completed=1) in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '','')))
					--това е при случай Няма активен процес OR (''-899'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '','')) 
						--AND (exists(select convert(varchar(4), ProcessTypeId, 104) from Process as p where p.FundSystemIdentifier = SystemIdentifier and p.Deleted = 0 and p.Completed=0))
							--OR ((select convert(varchar(4), ProcessTypeId, 104) from Process as p where p.FundSystemIdentifier = SystemIdentifier and p.Deleted = 0 and p.Completed=1) in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))
						--)
					--) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FileFormats + ''', '',''))) 
					OR (exists((select nv.ValueCode 
						from NomenclatureValues nv join N.Nomenclatures n on n.Id = nv.NomenclatureId 
						join Funds as f1 on nv.EntityId = f1.Id
						where f1.Id=f.Id and nv.NomenclatureCode=''FILE_TYPE''
						and n.Deleted=0 and nv.Deleted=0) INTERSECT (select element from dbo.SplitString(''' + @FileFormats + ''', '','')))))
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
				TotalRows bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
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
				a.SortOrder
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
			a.SortOrder
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
			SortOrder int null
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundDataPublicReportSummary] 
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
	@DateFrom nvarchar(100) = NULL,
	@DateTo nvarchar(100) = null,
	@LGid nvarchar(max) = null
AS
BEGIN
	IF @ResultType = 1 OR @ResultType = 2
	BEGIN 
		declare @remoteQuery varchar(max) = 
			'SELECT
				COUNT(*) Funds,
				sum(isnull(fund.InvetoryCount, 0)) Inventories,
				sum(isnull(fund.AECount, 0)) ArchiveEntities,
				cast(sum(fund.LinearMeters) as decimal(18,2)) LinearMeters,
				null Size, -- по искане на клиента не се отчита
				null as Duration,
				null as EDocumentsCount
			FROM Fund_Modified as fund
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
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE(@TextDate, 'null') + '''))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@LGid, 'null') + ''' = ''null'') OR (fund.LGid in (SELECT Element from dbo.SplitString(''' + COALESCE(@LGid, 'null') + ''', '',''))))';

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
		
		DECLARE @localQueryWhereClause VARCHAR(max) = '
			ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
					AND DescriptionLevelCode = 1 
					AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
						OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
						OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
						OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
							and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
						) 
					)
					AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
						OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
							and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
						) 
					)
					AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
						OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
					AND f.StatusCode <> ''12''
					AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
						OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
					AND ((''' + ISNULL(@TextDate,  N'NULL') + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.ApproxmateChronologicalScope = ''') + ISNULL(@TextDate, N'NULL') + '''))
					AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
						OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
						OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))	
					'
					+ @DateFromCondition
					+ @DateToCondition;

		DECLARE @totalDuration VARCHAR(MAX) = '' 

		IF @ResultType = 1
		BEGIN
			SET @totalDuration = '
				(select cast(sum(durations.Duration) as bigint) 
				from 
					(select (select sum(isnull(d.Duration, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) durations)';
		END

		IF @ResultType = 3
		BEGIN
			SET @totalDuration = ' 
				(select cast(sum(durations.Duration) as bigint)  
				from 
					(select (select sum(isnull(d.Duration, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) durations)
				';
		END

		DECLARE @localQuery VARCHAR(max) = 
			'SELECT
				count(*) Funds,
				sum(isnull(InventoryCount, 0)) Inventories,
				sum(isnull(ArchivalEntityCount, 0)) ArchiveEntities,
				null LinearMeters,
				cast(sum(isnull(fsi.EnrolledBytes, 0)) as bigint) Size,'
				+ @totalDuration + ' Duration,
				sum(isnull(fsi.EnrolledDocumentCount, 0)) EDocumentsCount
			FROM Funds f
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier AND fsi.IsDraft = 0
			WHERE'
				+ @localQueryWhereClause +
				+ @DateFromCondition +
				+ @DateToCondition;
    END

	declare @sql varchar(max);

	IF @ResultType = 1 
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				Funds int NULL,
				Inventories int NULL,
				ArchiveEntities int NULL,
				LinearMeters decimal(18, 2) NULL,
				Size bigint NULL,
				Duration bigint NULL,
				EDocumentsCount int NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT 
				sum(u.Funds) as Funds, 
				sum(u.Inventories) as Inventories, 
				sum(u.ArchiveEntities) as ArchiveEntities, 
				sum(isnull(cast(u.LinearMeters as decimal(18,2)), 0)) as LinearMeters,
				cast(sum(isnull(u.Size, 0)) as bigint) as Size,
				cast(sum(u.Duration) as bigint) as Duration,
				sum(u.EDocumentsCount) as EDocumentsCount
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery;
	END

	exec (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetFundMemoriesListInternalReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@PeriodGids nvarchar(max) = null,
	@FundArraysInternal nvarchar(max) = null,
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
		DECLARE @remoteQuery VARCHAR(MAX) = 
			'SELECT
				a.Name as Archive,
				fund.Number,
				fund.Title,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.StatusGid) as FundStatus,
				STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				   where obj.InventoryGid = fund.Gid and n.Type = ''CreatingType'' for XML PATH('''')), 1, 1, '''') as CreationMethod,
				fund.ImmediateSourceOfAcquisition,
				fund.AccessConditions,
				isnull(fund.LinearMeters, 0) LinearMeters,
				NULL as Size,
				NULL as Duration,
				NULL as FileFormats,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.TypeGid) as FundType,
				fund.Note,
				fund.IntNumber,
				a.SortOrder,
				NULL as SystemIdentifier,
				convert(bit, 1) as HasExternalSource,
				LGid as ExternalIdentifier
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE
				fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 3)
				AND  (''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE( + @TextDate, 'null') + '''))
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

		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				a.Name as Archive,
				f.Number,
				f.Title,
				convert(varchar, f.CreatedOn, 104) as CreationDate,
				(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus,
				(select n.Text + '';''
					from  NomenclatureValues nv
					join N.Nomenclatures n
					on nv.ValueCode=n.Code
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode=''CREATION_METHOD'' 
						and nv.EntityId=f.Id
						and nv.EntityType=''fund''
						and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''CREATION_METHOD''
						and n.Deleted=0 and nv.Deleted=0)
					FOR XML path(''''), elements) as CreationMethod,
				f.DocumentsProvider as ImmediateSourceOfAcquisition,
				f.DocumentsAccessDescription as AccessConditions,
				null as LinearMeters,
				fsi.EnrolledBytes as Size,
				dbo.FormatDuration((select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier)) as Duration,
				fsi.FileTypes as FileFormats,
				(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
				f.Notes as Note,
				f.NumberNumeric as IntNumber,
				a.SortOrder,
				convert(varchar(50), f.SystemIdentifier, 104) as SystemIdentifier,
				convert(bit, 0) as HasExternalSource,
				NULL as ExternalIdentifier
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier AND fsi.IsDraft = 0
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 3 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
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
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				Title nvarchar(MAX) NULL,
				CreationDate varchar(50) NULL,
				FundStatus nvarchar(MAX) NULL,
				CreationMethod nvarchar(MAX) NULL,
				ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
				AccessConditions nvarchar(MAX) NULL,
				LinearMeters float NULL,
				Size bigint NULL,
				Duration nvarchar(14) NULL,
				FileFormats nvarchar(MAX) NULL,
				FundType nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null,
				SortOrder int null,
				SystemIdentifier nvarchar(MAX) NULL,
				HasExternalSource BIT,
				ExternalIdentifier INT NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteFundsTable
			UNION
			' +
			@localQuery +  + @sqlFinalPart;	
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundMemoriesListInternalReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
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
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQueryWhereClause VARCHAR(MAX) = '
			fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 3)
			AND  (''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
			AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE( + @TextDate, 'null') + '''))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
		';
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT
				COUNT_BIG(*) TotalRows,
				round(cast(SUM(isnull(fund.LinearMeters, 0)) as decimal(18, 2)), 2) TotalLinearMeters,
				--(select sum(sizes.Size) 
				--from 
					--(select (select sum(isnull(i.ByteLenght, 0)) 
						--from Image i
						--inner join Document_Modified d
						--on i.DocumentGid = d.Gid
						--where d.FundLGid = fund.LGid) as Size
						--from [Archiving].[dbo].[Fund_Modified] fund
						--WHERE + @remoteQueryWhereClause +
					--) sizes) TotalSize,
				cast(0 as bigint) TotalSize, -- по искане на клиента не се отчита
				NULL as TotalDuration
			FROM Fund_Modified as fund
			WHERE ' + @remoteQueryWhereClause;

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

		DECLARE @localQueryWhereClause VARCHAR(MAX) = '
			ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
			AND DescriptionLevelCode = 3 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
				) 
			)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
			AND ((''' + ISNULL(@TextDate,  N'NULL') + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.ApproxmateChronologicalScope = ''') + ISNULL(@TextDate, N'NULL') + '''))
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
				OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
			'
			+ @DateFromCondition
			+ @DateToCondition;
		;

		DECLARE @totalDuration VARCHAR(MAX) = '' 

		IF @ResultType = 1
		BEGIN
			SET @totalDuration = '
				(select sum(sizes.Size) 
				from 
					(select (select sum(isnull(d.Duration, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Size
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) sizes)';
		END

		IF @ResultType = 3
		BEGIN
			SET @totalDuration = ' 
				dbo.FormatDuration(
					(select sum(sizes.Size) 
					from 
						(select (select sum(isnull(d.Duration, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Size
							from Funds f
							WHERE ' + @localQueryWhereClause + '
						) sizes)
				)';
		END

		DECLARE @localQuery VARCHAR(max) = '
			SELECT
			COUNT_BIG(*) TotalRows,
			cast(0 as decimal(18, 2)) TotalLinearMeters,
			SUM(fsi.EnrolledBytes) TotalSize,'
			+ @totalDuration + 'TotalDuration
			FROM Funds f
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier AND fsi.IsDraft = 0
			WHERE ' + @localQueryWhereClause;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL,
				TotalLinearMeters decimal(18, 2) NULL,
				TotalSize bigint NULL,
				TotalDuration nvarchar(14) NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT
				sum(u.TotalRows) as TotalRows, 
				round(cast(sum(u.TotalLinearMeters) as decimal(18, 2)), 2) as TotalLinearMeters,
				sum(isnull(u.TotalSize, 0)) as TotalSize,
				dbo.FormatDuration(sum(u.TotalDuration)) as TotalDuration
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundMemoriesListReport] 
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
				fund.Note,
				fund.IntNumber,
				a.SortOrder,
				null as SystemIdentifier,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
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
				fsi.EnrolledBytes as DigitalSize,
				fund.Notes as Note,
				fund.NumberNumeric as IntNumber,
				a.SortOrder,
				fund.SystemIdentifier,
				fund.ExternalIdentifier,
				fund.HasExternalSource
			FROM Funds fund 
			INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = fund.SystemIdentifier AND fsi.IsDraft = 0
			WHERE fund.ExternalIdentifier IS NULL AND fund.HasExternalSource = 0 AND fund.Deleted = 0 
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
				Note nvarchar(MAX) NULL,
				IntNumber int null,
				SortOrder int null,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundMemoriesListReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(max) = null
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQueryWhereClause VARCHAR(MAX) = '
			((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3)'
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT_BIG(*) TotalRows,
			cast(round(sum(fund.LinearMeters), 2) as decimal(18, 2)) TotalLinearMeters,
			-- това не се отчита по искане на клиента:
			--(select sum(sizes.Size) 
				--from 
					--(select (select sum(isnull(i.ByteLenght, 0)) 
						--from Image i
						--inner join Document_Modified d
						--on i.DocumentGid = d.Gid
						--where d.FundLGid = fund.LGid) as Size
						--from [Archiving].[dbo].[Fund_Modified] fund
						--WHERE @remoteQueryWhereClause
					--) sizes) TotalSize
				null as TotalSize
			FROM Fund_Modified as fund
			WHERE ' + @remoteQueryWhereClause;

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQueryWhereClause VARCHAR(MAX) = '
			ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode = 3 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows,
			null TotalLinearMeters,
			SUM(fsi.EnrolledBytes) TotalSize
			FROM Funds 
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = SystemIdentifier AND fsi.IsDraft = 0
			WHERE ' + @localQueryWhereClause;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL,
				TotalLinearMeters decimal(18, 2) NULL,
				TotalSize bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT 
				sum(u.TotalRows) as TotalRows, 
				sum(isnull(u.TotalLinearMeters, 0)) as TotalLinearMeters, 
				sum(isnull(u.TotalSize, 0)) as TotalSize 
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundMemoryPublicReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@PeriodGids nvarchar(max) = null,
	@FundArraysInternal nvarchar(max) = null,
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
		DECLARE @remoteQuery VARCHAR(MAX) = 
			'SELECT
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				fund.Title,
				fund.ImmediateSourceOfAcquisition,
				fund.AccessConditions,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.TypeGid) as FundType,
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
				isnull(fund.LinearMeters, 0),
				0 as Bytes,
				fund.IntNumber,
				a.SortOrder
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE
				(''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 3)
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE( + @TextDate, 'null') + '''))
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
		
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				a.Name as Archive,
				f.Number,
				convert(varchar, f.CreatedOn, 104) as CreationDate,
				f.Title,
				f.DocumentsProvider as ImmediateSourceOfAcquisition,
				f.DocumentsAccessDescription as AccessConditions,
				(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
				Notes as Note,
				(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus,
				(select n1.Text from N.Nomenclatures n1 where f.AcquisitionMethodId = n1.Id) as MethodOfAcquisition,
				f.ApproxmateChronologicalScope as TextDate,
				(isnull(convert(varchar, f.StartDateDay) + ''.'', '''') + isnull(convert(varchar, f.StartDateMonth) + ''.'', '''') + isnull(convert(varchar, f.StartDateYear), '''')) as StartDate,
				(isnull(convert(varchar, f.EndDateDay) + ''.'', '''') + isnull(convert(varchar, f.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, f.EndDateYear), '''')) as EndDate,
				null as LinearMeters,
				isnull(fsi.EnrolledBytes, 0) as Bytes,
				f.NumberNumeric as IntNumber,
				a.SortOrder
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			INNER JOIN N.Status s ON s.Code = f.StatusCode AND s.Code <> 12
			LEFT JOIN v_FundSizeInfo as fsi ON f.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 3 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
					OR ((select Code from N.Nomenclatures n1 where n1.Id = f.AcquisitionMethodId) in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					OR (convert(varchar(4), s.Code, 104) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
				AND ((''' + ISNULL(@TextDate,  N'NULL') + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.ApproxmateChronologicalScope = ''') + ISNULL(@TextDate, N'NULL') + '''))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
					OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))'
				+ @DateFromCondition
				+ @DateToCondition;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				CreationDate varchar(50) NULL,
				Title nvarchar(MAX) NULL,
				ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
				AccessConditions nvarchar(MAX) NULL,
				FundType nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				FundStatus nvarchar(MAX) NULL,
				MethodOfAcquisition nvarchar(MAX) NULL,
				TextDate nvarchar(256) NULL,
				StartDate varchar(256) NULL,
				EndDate varchar(50) NULL,
				LinearMeters float NULL,
				Bytes bigint NULL,
				IntNumber int null,
				SortOrder int null
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteFundsTable
			UNION
			' +
			@localQuery +  + @sqlFinalPart;	
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundMemoryPublicReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@PeriodGids nvarchar(max) = null,
	@FundArraysInternal nvarchar(max) = null,
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@TextDate nvarchar(2000) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 IF @ResultType = 1 OR @ResultType = 2
	BEGIN
	DECLARE @remoteQuery VARCHAR(MAX) = 
		'SELECT
				COUNT_BIG(*) TotalRows,
				SUM(fund.LinearMeters) TotalLinearMeters
			FROM Fund_Modified as fund
			WHERE
				(''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 3)
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE( + @TextDate, 'null') + '''))
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

	DECLARE @localQuery VARCHAR(max) = 
		'SELECT
			COUNT_BIG(*) TotalRows,
			SUM(LinearMeters) TotalLinearMeters
			FROM Funds f
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode = 3 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
				AND (select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) <> ''12''
				AND ((''' + ISNULL(@TextDate,  N'NULL') + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.ApproxmateChronologicalScope = ''') + ISNULL(@TextDate, N'NULL') + '''))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
					OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))'
				+ @DateFromCondition
				+ @DateToCondition;
    END

	declare @sql varchar(max);

 IF @ResultType = 1
  BEGIN
	 SET @sql = '
		DECLARE @remoteFundsTable TABLE ( 
			TotalRows bigint NULL,
			TotalLinearMeters float NULL
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
		SELECT sum(u.TotalRows) as TotalRows, sum(round(isnull(u.TotalLinearMeters, 0),2)) as TotalLinearMeters 
		FROM (
			SELECT * FROM (
				SELECT *    
				FROM @remoteFundsTable
				UNION
				' +
				@localQuery + ') lf) u';				
  END
  IF @ResultType = 3
   BEGIN
    SET @sql = @localQuery
   END
  
	exec (@sql);
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
				a.SortOrder
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
				a.SortOrder
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
				SortOrder int null
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundReportSummary] 
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
	@DateTo nvarchar(100) = null
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQueryWhereClause VARCHAR(MAX) = '
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

		DECLARE @remoteQuery VARCHAR(MAX) = 
			'SELECT
				count(*) TotalFunds,
				sum(isnull(fund.InvetoryCount, 0)) TotalInventories,
				sum(isnull(fund.AECount, 0)) TotalArchiveEntities,
				round(sum(fund.LinearMeters), 2) TotalLinearMeters,
				--(select sum(sizes.Size)
				--from 
					--(select (select sum(isnull(i.ByteLenght, 0)) 
						--from Image i
						--inner join Document_Modified d
						--on i.DocumentGid = d.Gid
						--where d.FundLGid = fund.LGid) as Size
						--from [Archiving].[dbo].[Fund_Modified] fund
						--WHERE  + @remoteQueryWhereClause + 
					--) sizes) TotalSize
				null TotalSize, -- по искане на клиента не се отчита
				NULL as TotalDuration
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE ' + @remoteQueryWhereClause;

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

		DECLARE @localQueryWhereClause VARCHAR(max) = '
			ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
			AND DescriptionLevelCode = 1 -- fund
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
				) 
			)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
				) 
			)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			AND (select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) <> ''12''
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
			AND ((''' + ISNULL(@TextDate,  N'NULL') + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.ApproxmateChronologicalScope = ''') + ISNULL(@TextDate, N'NULL') + '''))
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
				OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
				OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
			' 
			+ @DateFromCondition
			+ @DateToCondition;

		DECLARE @totalDuration VARCHAR(MAX) = '' 

		IF @ResultType = 1
		BEGIN
			SET @totalDuration = '
				(select cast(sum(durations.Duration) as bigint) 
				from 
					(select (select sum(isnull(d.Duration, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) durations)';
		END

		IF @ResultType = 3
		BEGIN
			SET @totalDuration = ' 
				(select cast(sum(durations.Duration) as bigint)  
				from 
					(select (select sum(isnull(d.Duration, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) durations)
				';
		END

		DECLARE @localQuery VARCHAR(max) = 
			'SELECT
				count(*) TotalFunds,
				sum(isnull(fsi.EnrolledInventoryCount, 0)) TotalInventories,
				sum(isnull(fsi.EnrolledArchivalEntityCount, 0)) TotalArchiveEntities,
				round(sum(LinearMeters), 2) TotalLinearMeters,
				(select sum(sizes.Size) 
				from 
					(select fsi.EnrolledBytes as Size
						from Funds f
						LEFT JOIN v_FundSizeInfo as fsi ON f.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
						WHERE ' + @localQueryWhereClause + '
					) sizes) TotalSize, -- въпреки че колоната се казва Bytes, тя съдържа MB, затова няма превръщане на мерните ед.'
				+ @totalDuration + ' TotalDuration
			FROM Funds f
			LEFT JOIN v_FundSizeInfo as fsi ON f.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
			WHERE ' + @localQueryWhereClause;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalFunds int NULL,
				TotalInventories int NULL,
				TotalArchiveEntities int NULL,
				TotalLinearMeters float NULL,
				TotalSize bigint NULL,
				TotalDuration bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT 
				sum(u.TotalFunds) as TotalFunds, 
				sum(u.TotalInventories) as TotalInventories, 
				sum(u.TotalArchiveEntities) as TotalArchiveEntities, 
				sum(isnull(u.TotalLinearMeters, 0)) as TotalLinearMeters,
				cast(sum(isnull(u.TotalSize, 0)) as bigint) as TotalSize,
				sum(u.TotalDuration) as TotalDuration
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
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
				a.SortOrder
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
				a.SortOrder
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
				SortOrder int null
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundsListReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(max) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = 
			'SELECT COUNT_BIG(*) TotalRows
			FROM Fund_Modified as fund	
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Funds f
			INNER JOIN N.Status s ON s.Code = StatusCode AND s.Code <> 12
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND Deleted = 0 
				AND f.DescriptionLevelCode = 1
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), a.Code, 104) from Archives a where a.Id = f.ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
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

CREATE OR ALTER PROCEDURE [dbo].[GetInsuranceFundOfCopiesOfForeignArchives] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by IntNumber, Number
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT
				(select Value2 from Nomenclature n where n.Gid = fund.CountryGid) as KmfNumber,
				fund.Number,
				convert(varchar(10), fund.CopyNegativeRolls) as CopyNegativeRolls,
				convert(varchar(10), fund.CopyNegativeFrames) as CopyNegativeFrames,
				convert(varchar(10), fund.CopyPositiveRolls) as CopyPositiveRolls,
				convert(varchar(10), fund.CopyPositiveFrames) as CopyPositiveFrames,
				cast(fund.CopyXerox as nvarchar(250)) as CopyXerox,
				fund.CopyDigital,
				NULL as ElectronicDocumentsCount,
				NULL as ElectronicDocumentsSize,
				fund.ExtentOther as Other,
				fund.InsNegativeCount as DoublesNegativeCount,
				(SELECT Value from Nomenclature where _retired =''3000-01-01'' and type = ''FAInsurancePlace'' and Gid = fund.InsNegativePlaceGid) as DoublesNegativeLocation,
				InsPositiveCount as DoublesPositiveCount,
				(SELECT Value from Nomenclature where _retired =''3000-01-01'' and type = ''FAInsurancePlace'' and Gid = fund.InsPositivePlaceGid) as DoublesPositiveLocation,
				fund.InsFotolabDeliveryDate as PhotolabDeliveryDate,
				fund.InsNote,
				fund.IntNumber
			FROM Fund_Modified as fund
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' 
				AND [Type] = ''LevelOfDescription'' AND Code = 9 
				AND exists(select 1 from Process p where p.Gid = fund.ProcessGid and p.TypeGid = 2128)) -- Добавяне на данни за застрахователен фонд'; 

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				(select Code from N.Nomenclatures n where n.Id = CountryId) as KmfNumber,
				convert(varchar(256), InventoryNumber) as Number,	
				MicrofilmNegativeRollsCount as CopyNegativeRolls,
				MicrofilmNegativeFramesCount as CopyNegativeFrames,
				MicrofilmPositiveRollsCount as CopyPositiveRolls,
				MicrofilmPositiveFramesCount as CopyPositiveFrames,
				convert(varchar(250), PhotoCopy) as CopyXerox,
				convert(varchar(250), DigitalCopy) as CopyDigital,
				(select COUNT(fpd.Id) from FilmPackageDocuments as fpd join FilmPackages as fp on fpd.PackageId = fp.Id where fp.Id = PackageBId AND fpd.Deleted = 0 AND fp.Deleted = 0) as ElectronicDocumentsCount,
				(select SUM(fpd.FileSizeInBytes) from FilmPackageDocuments as fpd join FilmPackages as fp on fpd.PackageId = fp.Id where fp.Id = PackageBId AND fpd.Deleted = 0 AND fp.Deleted = 0) as ElectronicDocumentsSize,
				Other as Other,
				null as DoublesNegativeCount, -- няма го
				null as DoublesNegativeLocation, -- няма го
				null as DoublesPositiveCount, -- няма го
				null as DoublesPositiveLocation, -- няма го
				null as PhotolabDeliveryDate, -- няма го
				Notes as Note,
				InventoryNumber as IntNumber
			FROM Films
			WHERE --ExternalIdentifier IS NULL AND HasExternalSource = 0
				Deleted = 0 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))'; -- Дали трябва да се добави условие за процес?
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				KmfNumber nvarchar(255) NULL,	
				Number nvarchar(256) NULL,
				CopyNegativeRolls int NULL,
				CopyNegativeFrames int NULL,
				CopyPositiveRolls int NULL,
				CopyPositiveFrames int NULL,
				CopyXerox nvarchar(250) NULL,
				CopyDigital nvarchar(250) NULL,
				ElectronicDocumentsCount int NULL,
				ElectronicDocumentsSize bigint NULL,
				Other nvarchar(max) NULL,
				DoublesNegativeCount int NULL,
				DoublesNegativeLocation int NULL,
				DoublesPositiveCount int NULL,
				DoublesPositiveLocation int NULL,
				PhotolabDeliveryDate datetime NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null			
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

CREATE OR ALTER PROCEDURE [dbo].[GetInsuranceFundOfCopiesOfForeignArchivesSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(max) = null
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Fund_Modified as fund
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' 
				AND [Type] = ''LevelOfDescription'' AND Code = 9 
				AND exists(select 1 from Process p where p.Gid = fund.ProcessGid and p.TypeGid = 2128)) -- Добавяне на данни за застрахователен фонд';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Films 
			WHERE --ExternalIdentifier IS NULL AND HasExternalSource = 0
				Deleted = 0 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))'; -- Дали трябва да се добави условие за процес?
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
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

CREATE OR ALTER PROCEDURE [dbo].[GetLibraryCard] 
	@LinkedServer NVARCHAR(50),
	@Number INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX);

	DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT
			ValidFrom,
			ValidTo
		FROM LibraryCards
		WHERE Id = ' + CONVERT(VARCHAR(10), @Number);

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	SET @sql = 'SELECT * FROM OPENQUERY(' + @LinkedServer + ', ''' + @remoteQuery + ''');';

	EXEC (@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[GetMostUsedRequestEntitiesReport]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetMostUsedRequestEntitiesReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveGid int,
	@ArchiveCodesInternal nvarchar(10) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = fund.ArchiveGid) as Archive,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.LevelOfDescriptionGid) as LevelOfDescription,
				fund.Number,


				convert(varchar, fund.CreationDate, 104) as CreationDate,
				fund.Title,
				fund.Note
			FROM Fund_Modified as fund
			WHERE 
				fund.ArchiveGid = ' + CAST(@ArchiveGid as varchar(max)) + 
					' AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)';
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				ArchivalEntityCount as AECount,
				(SELECT Text FROM [N].[FundDescriptionLevel] dl where dl.Code = DescriptionLevelCode) as LevelOfDescription,
				Number,

				convert(varchar, CreatedOn, 104) as CreationDate,
				Title,
				Notes as Note
			FROM Funds 
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode = 1 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Number nvarchar(256) NULL,
				CreationDate varchar(50) NULL,
				Title nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL
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

CREATE OR ALTER PROCEDURE [dbo].[GetPartialReceiptsListReport] 
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

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				CONCAT(fund.ImmediateSourceOfAcquisition, '' / '',
					(
						select Value + '';''
						from Nomenclature n1
						inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
						where n1._retired=''3000-01-01'' 
							and on1._retired=''3000-01-01''
							and on1.FundGid = fund.Gid 
							and n1.Type=''MethodOfAcquisition''
						FOR XML path(''''), elements
					)) as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				CONCAT(round(isnull(cast(fund.LinearMeters as decimal(18,2)), 0),2), '' / '', fund.ExtentOther) as VolumeInSheets,
				null as DigitalSize,
				fund.Note,
				fund.IntNumber,
				a.SortOrder,
				null as SystemIdentifier,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END


	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreatedOn, 104) as CreationDate,
				CONCAT(DocumentsProvider, '' / '', (select n1.Text from N.Nomenclatures n1 where fund.AcquisitionMethodId = n1.Id)) as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				CONCAT(round(isnull(cast(fund.LinearMeters as decimal(18,2)), 0),2), '' / '', OtherMetrics) as VolumeInSheets,
				fsi.EnrolledBytes as DigitalSize,
				fund.Notes as Note,
				fund.NumberNumeric as IntNumber,
				a.SortOrder,
				fund.SystemIdentifier,
				fund.ExternalIdentifier,
				fund.HasExternalSource
			FROM Funds fund
			INNER JOIN Archives a ON a.Id = fund.ArchiveId AND a.Deleted = 0
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = fund.SystemIdentifier AND fsi.IsDraft = 0
			WHERE fund.ExternalIdentifier IS NULL AND fund.HasExternalSource = 0 AND fund.Deleted = 0 
				AND fund.DescriptionLevelCode = 4
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
				VolumeInSheets  nvarchar(300) NULL,
				DigitalSize bigint NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null,
				SortOrder int null,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
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

CREATE OR ALTER PROCEDURE [dbo].[GetPartialReceiptsListReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(10) = null
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				COUNT_BIG(*) TotalRows,
				CAST(SUM(isnull(fund.InvetoryCount, 0)) AS BIGINT) TotalInventories,
				CAST(SUM(isnull(fund.AECount, 0)) AS BIGINT) TotalArchiveEntities,
				CAST(ROUND(SUM(fund.LinearMeters), 2) AS DECIMAL(18, 2)) TotalLinearMeters,
				CAST(0 as BIGINT) TotalSize -- по искане на клиента не се отчита
			FROM Fund_Modified AS fund
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)';
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT 
				COUNT_BIG(*) TotalRows,
				CAST(sum(isnull(fsi.EnrolledInventoryCount, 0)) AS BIGINT) TotalInventories,
				CAST(sum(isnull(fsi.EnrolledArchivalEntityCount, 0)) AS BIGINT) TotalArchiveEntities,
				NULL TotalLinearMeters,
				CAST(sum(isnull(fsi.EnrolledBytes, 0)) AS BIGINT) TotalSize
			FROM Funds F
			LEFT JOIN v_FundSizeInfo as fsi ON f.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 4
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), a.Code, 104) from Archives a where a.Id = f.ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows BIGINT NULL,
				TotalInventories BIGINT NULL,
				TotalArchiveEntities BIGINT NULL,
				TotalLinearMeters DECIMAL(18, 2) NULL,
				TotalSize BIGINT NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT 
				SUM(u.TotalRows) AS TotalRows,
				SUM(u.TotalInventories) AS TotalInventories, 
				SUM(u.TotalArchiveEntities) AS TotalArchiveEntities, 
				SUM(ISNULL(u.TotalLinearMeters, 0)) TotalLinearMeters,
				SUM(ISNULL(u.TotalSize, 0)) AS TotalSize	
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
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

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetPartialReceiptsPublicReportSummary] 
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
	@DateTo nvarchar(100) = null
AS
BEGIN

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
	DECLARE @remoteQueryWhereClause VARCHAR(MAX) = '(''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
			AND fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 2)
			AND (''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'' OR cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2))
			AND (''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'' OR cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2))
			AND (''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '','')) OR fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '','')))
			AND (''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))
				OR EXISTS(SELECT 1 FROM [Archiving].[dbo].ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
			AND (''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))	
			AND (''' + COALESCE(@TextDate, 'null') + ''' = ''null'' OR fund.TextDate = ''' + COALESCE(@TextDate, 'null') + ''')
			AND (''' + COALESCE(@DateFrom, 'null') + ''' = ''null'' OR cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2))
			AND (''' + COALESCE(@DateTo, 'null') + ''' = ''null'' OR cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2))';

	declare @remoteQuery varchar(max) = 
		'SELECT
			COUNT(*) TotalRows,
			sum(isnull(fund.InvetoryCount, 0)) TotalInventories,
			sum(isnull(fund.AECount, 0)) TotalArchiveEntities,
			CAST(ROUND(SUM(fund.LinearMeters), 2) AS DECIMAL(18, 2)) TotalLinearMeters,
			--(select sum(sizes.Size) 
				--from 
					--(select (select sum(isnull(i.ByteLenght, 0)) 
						--from Image i
						--inner join Document_Modified d
						--on i.DocumentGid = d.Gid
						--where d.FundLGid = fund.LGid) as Size
						--from [Archiving].[dbo].[Fund_Modified] fund
						--WHERE  + @remoteQueryWhereClause + 
					--) sizes) TotalSize
			cast(0 as bigint) TotalSize -- по искане на клиента не се отчита
		FROM [Archiving].[dbo].Fund_Modified as fund
		WHERE ' + @remoteQueryWhereClause;

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

		DECLARE @localQueryWhereClause VARCHAR(max) = '
			f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
					AND DescriptionLevelCode = 4 
					AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
						OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
						OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
						OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
							and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
						) 
					)
					AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
						OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
						OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
					AND ((''' + ISNULL(@TextDate,  N'NULL') + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.ApproxmateChronologicalScope = ''') + ISNULL(@TextDate, N'NULL') + '''))
					AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
						OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
						OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))'
				+ @DateFromCondition
				+ @DateToCondition;

	
		DECLARE @localQuery VARCHAR(max) = 
			'SELECT
				COUNT_BIG(*) TotalRows,
				cast(sum(isnull(fsi.EnrolledInventoryCount, 0)) as bigint) TotalInventories,
				cast(sum(isnull(fsi.EnrolledArchivalEntityCount, 0)) as bigint) TotalArchiveEntities,
				null TotalLinearMeters,
				cast(sum(isnull(fsi.EnrolledBytes, 0)) as bigint) TotalSize
				FROM Funds f
				LEFT JOIN v_FundSizeInfo as fsi ON f.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
				INNER JOIN N.Status s ON s.Code = f.StatusCode AND s.Code <> 12
				WHERE ' + @localQueryWhereClause;
				
	END

	declare @sql varchar(max);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL,
				TotalInventories bigint NULL,
				TotalArchiveEntities bigint NULL,
				TotalLinearMeters DECIMAL(18, 2) NULL,
				TotalSize bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT 
				sum(u.TotalRows) as TotalRows, 
				sum(u.TotalInventories) as TotalInventories, 
				sum(u.TotalArchiveEntities) as TotalArchiveEntities, 
				sum(round(isnull(u.TotalLinearMeters, 0),2)) as TotalLinearMeters,
				sum(isnull(u.TotalSize, 0)) as TotalSize
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 3 
	BEGIN
		SET @sql = @localQuery;
	END

	exec (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetReceiptsListReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by CreationDateAsDateTime
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	DECLARE @methodOfAcquisitionQueryRemote VARCHAR(MAX) = '
		(
			select Value + '';''
			from  Nomenclature n1
			inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
			where n1._retired=''3000-01-01'' 
				and on1._retired=''3000-01-01''
				and on1.FundGid = fund.Gid 
				and n1.Type=''MethodOfAcquisition''
			FOR XML path(''''), elements
		)';
	DECLARE @methodOfAcquisitionQueryLocal VARCHAR(MAX) = '
		(
			select n1.Text + '';''
			from N.Nomenclatures n1 where fund.AcquisitionMethodId = n1.Id
			FOR XML path(''''), elements
		)';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN	
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				ROW_NUMBER() OVER(ORDER BY fund.CreationDate ASC) AS RowNumber,
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				cast(fund.CreationDate AS datetime2(7)) as CreationDateAsDateTime,
				COALESCE(
					fund.ImmediateSourceOfAcquisition + '' / '' + ' + @methodOfAcquisitionQueryRemote +  ', 
					fund.ImmediateSourceOfAcquisition + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryRemote + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				cast(fund.AECount as bigint) as ArchiveEntitiesCount,
				isnull(fund.LinearMeters, 0) as LinearMeters,
				null as DigitalSize,
				TextDate,
				(select n.Value from Nomenclature as n where fund.LevelOfDescriptionGid = n.Gid) as FundOwnership,
				fund.Note,
				null as SystemIdentifier,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND (fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1) 
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				ROW_NUMBER() OVER(ORDER BY fund.CreatedOn ASC) AS RowNumber,
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreatedOn, 104) as CreationDate,
				fund.CreatedOn as CreationDateAsDateTime,
				COALESCE(
					fund.DocumentsProvider + '' / '' + ' + @methodOfAcquisitionQueryLocal +  ',
					fund.DocumentsProvider + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryLocal + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				cast(fund.ArchivalEntityCount as bigint) as ArchiveEntitiesCount,
				null as LinearMeters,
				cast(fsi.EnrolledBytes AS BIGINT) as DigitalSize, -- реално е MB, името на колоната трябва да се смени
				ApproxmateChronologicalScope as TextDate,
				(select dl.Text from N.FundDescriptionLevel as dl where dl.Code = fund.DescriptionLevelCode) as FundOwnership,
				fund.Notes as Note,
				fund.SystemIdentifier,
				fund.ExternalIdentifier,
				fund.HasExternalSource
			FROM Funds fund
			INNER JOIN Archives a ON a.Id = fund.ArchiveId AND a.Deleted = 0
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = fund.SystemIdentifier AND fsi.IsDraft = 0
			WHERE fund.ExternalIdentifier IS NULL AND fund.HasExternalSource = 0 AND fund.Deleted = 0 
				AND fund.DescriptionLevelCode IN(1, 2, 4)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(fund.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				RowNumber INT NOT NULL,
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				CreationDate varchar(50) NULL,
				CreationDateAsDateTime varchar(50) NULL,
				ImmediateSourceOfAcquisitionPlusMethodOfAcquisition nvarchar(MAX) NULL,
				Title nvarchar(MAX) NULL,
				ArchiveEntitiesCount bigint NULL,
				LinearMeters float NULL, 
				DigitalSize bigint NULL,
				TextDate nvarchar(MAX) NULL, -- по забележка на ИСДА сменя DocumentsEndDates
				FundOwnership nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'
			SELECT 
				ROW_NUMBER() OVER(ORDER BY CreationDateAsDateTime ASC) AS RowNumber,
				Archive,
				Number,
				CreationDate,
				CreationDateAsDateTime,
				ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				Title,
				ArchiveEntitiesCount,
				LinearMeters, 
				DigitalSize,
				TextDate,
				FundOwnership,
				Note,
				SystemIdentifier,
				ExternalIdentifier,
				HasExternalSource
			FROM (
				SELECT *
				FROM @remoteFundsTable
				UNION
				' +
				@localQuery + ') t
				' + @sqlFinalPart;	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + @sqlFinalPart +''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = 'DECLARE @methodOfAcquisitionQueryLocal VARCHAR(MAX);' + @localQuery + @sqlFinalPart;
	END

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetReceiptsListReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@Page int = 1
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT_BIG(*) TotalRows,
			cast(round(sum(fund.LinearMeters), 2) as decimal(18, 2)) TotalLinearMeters,
			null as TotalSize
			FROM Fund_Modified as fund
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND (fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1) 
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows,
			null TotalLinearMeters,
			SUM(fsi.EnrolledBytes) TotalSize
			FROM Funds 
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = SystemIdentifier AND fsi.IsDraft = 0
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0
				AND DescriptionLevelCode IN(1, 2, 4)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL,
				TotalLinearMeters decimal(18, 2) NULL,
				TotalSize bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT 
				SUM(u.TotalRows) AS TotalRows,
				SUM(isnull(u.TotalLinearMeters, 0)) AS TotalLinearMeters, 
				SUM(isnull(u.TotalSize, 0)) AS TotalSize 
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
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

CREATE OR ALTER PROCEDURE [dbo].[GetRegisterOfDigitalObjectsPublicReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@DigitalObjectStatuses VARCHAR(MAX) = NULL,
	@ArchiveCodes nvarchar(10) = null,
	@RegisteredFrom nvarchar(100) = NULL,
	@RegisteredTo nvarchar(100) = null,
	@DocLGid int = null,
	@SystemIdentifier nvarchar(50) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
	
AS
BEGIN
SET NOCOUNT ON;
	-- Екипът реши да се взима Duration от Document, а не от DocumentObject, където няма такава колона

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by ArchiveSortOrder, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchivalEntityIntNumber, ArchiveEntityNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
	DECLARE @remoteQuery VARCHAR(MAX) = 
		'SELECT
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = (SELECT LevelOfDescriptionGid from Fund_Modified f where f.LGid = doc.FundLGid)) as LevelOfDescription,
			--''http://212.122.187.196:84/Process.aspx?type=Document&agid='' + cast(doc.ArchiveGid as nvarchar(255)) + ''&flgid='' + cast(doc.FundLGid as nvarchar(255)) + ''&ilgid='' + cast(doc.InventoryLGid as nvarchar(255)) + ''&aelgid='' + cast(doc.AELGid as nvarchar(255)) + ''&dlgid=''+ cast(doc.LGid as nvarchar(255)) as DocumentLink,
			a.Name as ArchiveName,
			(select CAST(Code as nvarchar(10)) from archive where _retired = ''3000-01-01'' and Gid = doc.ArchiveGid) ArchiveCode,
			CAST(doc.LGid AS nvarchar(50)) as SystemId,
			CAST(1 AS BIT) as HasExternalSource,
			(SELECT TOP 1 Number from Fund_Modified f where f.LGid = doc.FundLGid) as FundNumber,
			(SELECT Number from Inventory_Modified i where i.LGid = doc.InventoryLGid) as InventoryNumber,
			(SELECT Number from ArchiveEntity_Modified ae where ae.LGid = doc.AELGid) as ArchiveEntityNumber,
			(
				select ln1.ListFrom + '' - '' + ln1.ListTo + ''; ''
				from  ListNumber ln1	
				where ln1._retired=''3000-01-01'' and ln1.DocumentGid = doc.Gid 
				FOR XML path(''''), elements
			) as ListNumbers,
			doc.Title as DocumentTitle,
			doc.TextDate as ChronologicalScope,
			--(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = doc.StatusGid) as DocStatus, -- отпада по искане на ДАА
			convert(varchar, doc.DOCreationDate, 104) as DigitalObjectCreationDate,
			COUNT(img.Gid) as ImageCount,
			SUM(isnull(img.ByteLenght, 0)) as BytesCount,
			null as Duration,
			--case when isnull(DigitalObjectDeleted, 0) = 0 then ''Активен'' else ''Заличен'' end as DigitalObjectStatus, -- отпада по искане на ДАА
			--(
				--select convert(varchar, max(p.ModifiedOn), 104)  
				--from Document d
				--inner join Process p on p._retired = ''3000-01-01'' and p.Gid = d.ProcessGid and p.TypeGid = 2124 and p.StepGid = 75
				--where  d.LGid = doc.lgid
			--) as ModifiedOn,  -- отпада по искане на ДАА
			(SELECT TOP 1 IntNumber from Fund_Modified f where f.LGid = doc.FundLGid) as FundIntNumber,
			(SELECT IntNumber from Inventory_Modified i where i.LGid = doc.InventoryLGid) as InventoryIntNumber,
			(SELECT IntNumber from ArchiveEntity_Modified ae where ae.LGid = doc.AELGid) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder
		FROM
			Document_Active doc -- в ИСДА ползват Document_Active за тази справка
			INNER JOIN Archive a ON a.Gid = doc.ArchiveGid AND a._retired = ''3000-01-01''
			LEFT OUTER JOIN [Image] img ON doc.Gid = img.DocumentGid AND img._retired = ''3000-01-01''
		WHERE
			ISNULL(doc.HasDigitalObject, 0) = 1
			AND (''' + COALESCE(cast(@DocLGid as nvarchar(50)), 'null') + ''' = ''null'' OR doc.LGid = ''' + COALESCE(cast(@DocLGid as nvarchar(50)), 'null') + ''')
			AND (''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'' OR cast(doc.DOCreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2))
			AND (''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'' OR cast(doc.DOCreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @DigitalObjectStatuses + ''', '',''))) 
				OR ((isnull(doc.DigitalObjectDeleted, 0) = 0) and 1 in (select element from dbo.SplitString(''' + @DigitalObjectStatuses + ''', '','')))
				OR ((isnull(doc.DigitalObjectDeleted, 0) = 1) and 2 in (select element from dbo.SplitString(''' + @DigitalObjectStatuses + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
		group by 
		doc.LGid, 
		doc.ArchiveGid, 
		doc.CreationDate, 
		doc.Title, 
		doc.StatusGid, 
		doc.DigitalObjectDeleted, 
		doc.DigitalObjectDeleted, 
		doc.DOCreationDate, 
		doc.FundLGid, 
		doc.InventoryLGid, 
		doc.AELGid, 
		doc.Gid,
		doc.StartDateDay,
		doc.StartDateMonth,
		doc.StartDateYear,
		doc.EndDateDay,
		doc.EndDateMonth,
		doc.EndDateYear,
		doc.TextDate,
		a.Name,
		a.SortOrder';
   
	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			--(SELECT Text FROM [N].[DocumentDescriptionLevel] dl where dl.Code = DescriptionLevelCode) as LevelOfDescription,
			(SELECT Text FROM [N].[FundDescriptionLevel] fdl where fdl.Code = (SELECT DescriptionLevelCode FROM Funds f where f.SystemIdentifier = do.FundSystemIdentifier)) as LevelOfDescription,
			--'''' as DocumentLink,
			a.Name as ArchiveName,
			a.Code as ArchiveCode,
			CAST(d.SystemIdentifier AS nvarchar(50)) as SystemId,
			CAST(0 AS BIT) as HasExternalSource,
			(SELECT Number FROM Funds f where f.SystemIdentifier = do.FundSystemIdentifier) as FundNumber,
			(SELECT Number FROM Inventories i where i.SystemIdentifier = do.InventorySystemIdentifier) as InventoryNumber,
			(SELECT Number FROM ArchivalEntities ae where ae.SystemIdentifier = do.ArchivalEntitySystemIdentifier) as ArchiveEntityNumber,
			(CAST(d.StartSheetNumber AS nvarchar(50)) + '' - '' + CAST(d.EndSheetNumber AS nvarchar(50))) as ListNumbers, -- различава се от ИСДА; има ли нужда от таква стойност в СЕА?
			d.Title as DocumentTitle,
			d.ApproxmateChronologicalScope as ChronologicalScope,
			-- (SELECT Text FROM [N].[Status] s where s.Code = StatusCode) as DocStatus, -- отпада по искане на ДАА
			convert(varchar, do.CreatedOn, 104) as DigitalObjectCreationDate,
			NULL as ImageCount, -- нямаме снимки при нас
			do.FileSize as BytesCount,
			d.Duration,
			-- NULL as DigitalObjectStatus, -- отпада по искане на ДАА
			-- convert(nvarchar,UpdatedOn, 104) as ModifiedOn, -- отпада по искане на ДАА
			(SELECT NumberNumeric FROM Funds f where f.SystemIdentifier = do.FundSystemIdentifier) as FundIntNumber,
			(SELECT NumberNumeric FROM Inventories i where i.SystemIdentifier = do.InventorySystemIdentifier) as InventoryIntNumber,
			(SELECT NumberNumeric FROM ArchivalEntities ae where ae.SystemIdentifier = do.ArchivalEntitySystemIdentifier) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder 
		FROM DigitalObjects do
		INNER JOIN Archives a ON a.Id = do.ArchiveId AND a.Deleted = 0
		INNER JOIN Documents d ON d.SystemIdentifier = do.DocumentSystemIdentifier AND do.Deleted = 0
		INNER JOIN N.Status s ON s.Code = do.StatusCode AND s.Code <> 12
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
				AND (''' + COALESCE(@SystemIdentifier, 'null') + ''' = ''null'' OR CAST(do.SystemIdentifier AS nvarchar(50)) = ''' + COALESCE(@SystemIdentifier, 'null') + ''')
				--AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
				AND do.TypeCode = 1 -- master
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND (''' + @DigitalObjectStatuses + ''' = ''-999'' 
					OR do.Deleted = 0 AND 1 IN (SELECT element FROM dbo.SplitString(''' + @DigitalObjectStatuses + ''', '',''))
					OR do.Deleted = 1 AND 2 IN (SELECT element FROM dbo.SplitString(''' + @DigitalObjectStatuses + ''', '','')))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(do.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
					OR (cast(do.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))'
		;
	END

	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1
	BEGIN
		 SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				LevelOfDescription nvarchar(MAX) NULL,
				--DocumentLink nvarchar(MAX) NULL,
				ArchiveName nvarchar(256) NOT NULL,
				ArchiveCode int NOT NULL,
				SystemId nvarchar(50) NOT NULL,
				HasExternalSource BIT NOT NULL,
				FundNumber nvarchar(256) NULL,
				InventoryNumber nvarchar(256) NULL,
				ArchiveEntityNumber nvarchar(256) NULL,
				ListNumbers nvarchar(MAX) NULL,
				DocumentTitle nvarchar(MAX) NULL,
				ChronologicalScope nvarchar(256) NULL, 
				-- DocStatus nvarchar(MAX) NULL, -- отпада по искане на ДАА
				DigitalObjectCreationDate nvarchar(50) NULL,
				ImageCount bigint NULL,
				BytesCount bigint NULL,
				Duration int NULL,
				-- DigitalObjectStatus nvarchar(50) NULL, -- отпада по искане на ДАА
				-- ModifiedOn varchar(50) NULL, -- отпада по искане на ДАА
				FundIntNumber int null,
				InventoryIntNumber int null,
				ArchivalEntityIntNumber int null,
				ArchiveSortOrder int null
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
    SET @sql = @localQuery + '
		order by ArchiveSortOrder, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchivalEntityIntNumber, ArchiveEntityNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';
	END

  EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetRegisterOfDigitalObjectsPublicReportSummary] 
	@LinkedServer nvarchar(50),
    @ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@DigitalObjectStatuses VARCHAR(MAX) = NULL,
	@ArchiveCodes nvarchar(10) = null,
	@RegisteredFrom nvarchar(100) = NULL,
	@RegisteredTo nvarchar(100) = null,
	@DocLGid int = null,
	@SystemIdentifier nvarchar(50) = null	
AS
BEGIN
  -- Екипът реши да се взима Duration от Document, а не от DocumentObject, където няма такава колона
	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
	DECLARE @remoteQuery VARCHAR(MAX) = 
		'SELECT
			ISNULL(COUNT(*), 0) TotalRows,
			CAST(0 AS BIGINT) as TotalBytesCount, -- по искане на клиента не се отчита
			CAST(0 AS BIGINT) as TotalDuration,
			CAST(SUM(isnull(x.ImageCount, 0)) AS BIGINT) as TotalImageCount
			--,SUM(isnull(x.DOs, 0)) as TotalDOs
			FROM
			(
				SELECT 
					SUM(isnull(img.ByteLenght, 0)) as BytesCount,
					COUNT_BIG(img.Gid) as ImageCount,
					COUNT_BIG(distinct doc.LGid) as DOs
				FROM
					Document_Active doc -- в ИСДА ползват Document_Active за тази справка
					left outer join [Image] img on doc.Gid = img.DocumentGid and img._retired = ''3000-01-01''
				WHERE
					ISNULL(doc.HasDigitalObject, 0) = 1
					AND (''' + COALESCE(cast(@DocLGid as nvarchar(50)), 'null') + ''' = ''null'' OR doc.LGid = ''' + COALESCE(cast(@DocLGid as nvarchar(50)), 'null') + ''')
					AND (''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'' OR cast(doc.DOCreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2))
					AND (''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'' OR cast(doc.DOCreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @DigitalObjectStatuses + ''', '',''))) 
						OR ((isnull(doc.DigitalObjectDeleted, 0) = 0) and 1 in (select element from dbo.SplitString(''' + @DigitalObjectStatuses + ''', '','')))
						OR ((isnull(doc.DigitalObjectDeleted, 0) = 1) and 2 in (select element from dbo.SplitString(''' + @DigitalObjectStatuses + ''', '',''))))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=doc.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
					group by doc.LGid, doc.ArchiveGid, doc.CreationDate, doc.Title, doc.StatusGid, doc.DigitalObjectDeleted, doc.DigitalObjectDeleted, doc.DOCreationDate
				) x';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT 
				ISNULL(SUM(DOsPerDocument), 0) TotalRows,
				CAST(SUM(BytesCountPerDocument) AS BIGINT) AS TotalBytesCount,
				CAST(SUM(DurationPerDocument) AS BIGINT) AS TotalDuration,
				NULL AS TotalImageCount
				--,count(DOsPerDocument) AS TotalDOs
			from
			(
				SELECT
					COUNT(do.SystemIdentifier) AS DOsPerDocument,
					MAX(d.Bytes) AS BytesCountPerDocument,
					MAX(d.Duration) AS DurationPerDocument
				FROM DigitalObjects do
				INNER JOIN Archives a ON a.Id = do.ArchiveId AND a.Deleted = 0
				INNER JOIN Documents d ON d.SystemIdentifier = do.DocumentSystemIdentifier AND do.Deleted = 0
				WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
						AND (''' + COALESCE(@SystemIdentifier, 'null') + ''' = ''null'' OR CAST(do.SystemIdentifier AS nvarchar(50)) = ''' + COALESCE(@SystemIdentifier, 'null') + ''')
						--AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
						AND do.TypeCode = 1 -- master
						AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
							OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
						AND (''' + @DigitalObjectStatuses + ''' = ''-999'' 
							OR do.Deleted = 0 AND 1 IN (SELECT element FROM dbo.SplitString(''' + @DigitalObjectStatuses + ''', '',''))
							OR do.Deleted = 1 AND 2 IN (SELECT element FROM dbo.SplitString(''' + @DigitalObjectStatuses + ''', '','')))
						AND (select convert(varchar(4), Code, 104) from N.Status s where s.Code = do.StatusCode) <> ''12''
						AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
							OR (cast(do.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
						AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
							OR (cast(do.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				group by d.SystemIdentifier
			) x			
			';
	END

	declare @sql varchar(max);

	IF @ResultType = 1
    BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE ( 
				TotalRows int,
				TotalBytesCount bigint NULL,
				TotalDuration bigint NULL,
				TotalImageCount bigint NULL
				-- ,TotalDOs bigint NULL -- Понеже не се знае дали се иска да се покажат всички диг. обекти, дори да не са уникални или само уникалните, махам колоната
			);

			INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows, sum(u.TotalBytesCount) as TotalBytesCount, sum(u.TotalDuration) as TotalDuration, sum(u.TotalImageCount) as TotalImageCount
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteTable
					UNION
					' +
					@localQuery + ') lf) u';
    END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
	END

	IF @ResultType = 3
    BEGIN
		SET @sql = @localQuery;
	END

  exec (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetSpecialRegistrationListReport] 
	@LinkedServer NVARCHAR(50),
	@ArchiveCodes NVARCHAR(10) = null,
	@FundNumber NVARCHAR(50) = null,
	@InventoryNumber NVARCHAR(50) = null,
	@ArchiveEntityNumber NVARCHAR(50) = null,
	@IsInRisk BIT = null,
	@DescriptionLevel NVARCHAR(50) = null,
	@RowsOfPage INT = 5000,
	@Page INT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @isInRiskStr NVARCHAR(4) = CONVERT(NVARCHAR(4), @IsInRisk);
	IF @isInRiskStr IS NULL SET @isInRiskStr = N'NULL';

	-- Трябва всеки литерал да се преобразува до NVARCHAR, защото иначе общият стринг бива отрязан на 4000-я символ
	DECLARE @remoteQuery NVARCHAR(MAX) = N'
		SELECT
			doc.Title,
			a.Name as Archive,
			(SELECT n.Value FROM Fund_Modified f 
				INNER JOIN Nomenclature n
				ON n.Gid = f.LevelOfDescriptionGid
				WHERE n._retired = ''3000-01-01'' AND n.Type=''LevelOfDescription'' AND f.LGid = doc.FundLGid 
			) AS DescriptionLevel,
			(SELECT Number FROM Fund_Modified f1 WHERE f1.LGid = doc.FundLGid) AS FundNumber,
			(SELECT Number FROM Inventory_Modified i1 WHERE i1.LGid = doc.InventoryLGid) AS InventoryNumber,
			(SELECT Number FROM ArchiveEntity_Modified ae WHERE ae.LGid = doc.AELGid) AS ArchiveEntityNumber,
			(select sum(isnull(i.ByteLenght, 0)) from Image i where i.DocumentGid = doc.Gid) as Size,
			doc.PaperCount AS PapersCount,
			(ISNULL(CONVERT(NVARCHAR, doc.StartDateDay) + ''.'', '''') + ISNULL(convert(NVARCHAR, doc.StartDateMonth) + ''.'', '''') + isnull(convert(NVARCHAR, doc.StartDateYear), '''')) AS StartDate,
			(ISNULL(CONVERT(NVARCHAR, doc.EndDateDay) + ''.'', '''') + ISNULL(convert(NVARCHAR, doc.EndDateMonth) + ''.'', '''') + isnull(convert(NVARCHAR, doc.EndDateYear), '''')) AS EndDate,
			doc.PhisicalConditionOther as PhysicalCondition,
			doc.IsInRisk,
			(SELECT n.Value FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				INNER JOIN Nomenclature n
				ON n.Gid = ti.LocationGid
				WHERE ti._retired = ''3000-01-01'' AND n._retired = ''3000-01-01'' AND n.Type=''ArchiveLocation'' AND i.LGid = doc.InventoryLGid 
			) AS Location,
			(SELECT ti.BuildingNumber FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				WHERE ti._retired = ''3000-01-01'' AND i.LGid = doc.InventoryLGid 		
			) AS BuildingNumber,
			(SELECT ti.FloorNumber FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				WHERE ti._retired = ''3000-01-01'' AND i.LGid = doc.InventoryLGid 		
			) AS FloorNumber,
			(SELECT ti.PremisesNumber FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				WHERE ti._retired = ''3000-01-01'' AND i.LGid = doc.InventoryLGid 		
			) AS PremisesNumber,
			(SELECT ti.RoomNumber FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				WHERE ti._retired = ''3000-01-01'' AND i.LGid = doc.InventoryLGid 		
			) AS RoomNumber,
			(SELECT ti.StillageNumber FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				WHERE ti._retired = ''3000-01-01'' AND i.LGid = doc.InventoryLGid 		
			) AS StillageNumber,
			(SELECT n.Value FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				INNER JOIN Nomenclature n
				ON n.Gid = ti.StillageSideGid
				WHERE ti._retired = ''3000-01-01'' AND n._retired = ''3000-01-01'' AND n.Type=''StillageSide'' AND i.LGid = doc.InventoryLGid 			
			) AS StillageSide,
			(SELECT ti.RowNumber FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				WHERE ti._retired = ''3000-01-01'' AND i.LGid = doc.InventoryLGid 		
			) AS RowNumber,
			(SELECT ti.CellNumber FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				WHERE ti._retired = ''3000-01-01'' AND i.LGid = doc.InventoryLGid 		
			) AS CellNumber,
			(SELECT IntNumber FROM Fund_Modified f1 WHERE f1.LGid = doc.FundLGid) AS FundIntNumber,
			(SELECT IntNumber FROM Inventory_Modified i1 WHERE i1.LGid = doc.InventoryLGid) AS InventoryIntNumber,
			(SELECT IntNumber FROM ArchiveEntity_Modified ae WHERE ae.LGid = doc.AELGid) AS ArchiveEntityIntNumber
		FROM Document_Modified AS doc
		INNER JOIN Archive a ON a.Gid = doc.ArchiveGid AND a._retired = ''3000-01-01''
		WHERE
			doc.IsForSpecialRegistration = 1
				AND ((''-999'' IN (SELECT element FROM SplitString(''' + @ArchiveCodes + CONVERT(NVARCHAR(MAX), N''', '',''))) OR a.Code IN (SELECT element FROM dbo.SplitString(') + @ArchiveCodes + CONVERT(NVARCHAR(MAX), N', '','')))
				AND (''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR (SELECT Number FROM Fund_Modified f WHERE f.LGid = doc.FundLGid) = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''')
				AND (''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR (SELECT Number FROM Inventory_Modified i WHERE i.LGid = doc.FundLGid) = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''')
				AND (''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR (SELECT Number FROM ArchiveEntity_Modified ae WHERE ae.LGid = doc.FundLGid) = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''')
				AND (''') + @isInRiskStr + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR CONVERT(NVARCHAR(4), doc.IsInRisk) = ') + @isInRiskStr + CONVERT(NVARCHAR(MAX), N')
				AND ((''-999'' IN (SELECT element FROM dbo.SplitString(''') + @DescriptionLevel + CONVERT(NVARCHAR(MAX), N''', '',''))) 
					OR (SELECT f.LevelOfDescriptionGid FROM Fund_Modified f 
						INNER JOIN Nomenclature n on n.Gid=f.LevelOfDescriptionGid
						WHERE f.LGid = doc.FundLGid AND n._retired = ''3000-01-01'') IN (SELECT element FROM dbo.SplitString(''') + @DescriptionLevel + CONVERT(NVARCHAR(MAX), N''', '',''))				
				)
		ORDER BY SortOrder, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchiveEntityIntNumber, ArchiveEntityNumber ASC
		OFFSET ') + CONVERT(NVARCHAR(10), @offset) + CONVERT(NVARCHAR(MAX), N' ROWS FETCH NEXT ') + CONVERT(NVARCHAR(10), @RowsOfPage) + CONVERT(NVARCHAR(MAX), N' ROWS ONLY');

	SET @remoteQuery = REPLACE(@remoteQuery, '''', N'''''');

	-- Тук може и да не е задължително да се ползва openquery, но е ползвано, за да може да се преизползва кода по-лесно там, където е нужен openquery
	DECLARE @sql NVARCHAR(MAX) = N'SELECT * FROM OPENQUERY(' + @LinkedServer + N', ''' + @remoteQuery + N''');';

	EXEC (@sql);
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetSpecialRegistrationListReportSummary] 
	@LinkedServer NVARCHAR(50),
	@ArchiveCodes NVARCHAR(10) = null,
	@FundNumber NVARCHAR(50) = null,
	@InventoryNumber NVARCHAR(50) = null,
	@ArchiveEntityNumber NVARCHAR(50) = null,
	@IsInRisk BIT = null,
	@DescriptionLevel NVARCHAR(50) = null
AS
BEGIN

	DECLARE @isInRiskStr NVARCHAR(4) = CONVERT(NVARCHAR(4), @IsInRisk);
	IF @isInRiskStr IS NULL SET @isInRiskStr = N'NULL';

	declare @remoteQuery NVARCHAR(MAX) = N'
		SELECT
			COUNT_BIG(*) TotalRows
		FROM Document_Modified as doc
		WHERE
			doc.IsForSpecialRegistration = 1
				AND ((''-999'' IN (SELECT element FROM SplitString(''' + @ArchiveCodes + CONVERT(NVARCHAR(MAX), N''', '',''))) OR (SELECT a.Code FROM Archive a WHERE a.Gid=ArchiveGid) IN (SELECT element FROM dbo.SplitString(') + @ArchiveCodes + CONVERT(NVARCHAR(MAX), N', '','')))
				AND (''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR (SELECT Number FROM Fund_Modified f WHERE f.LGid = doc.FundLGid) = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''')
				AND (''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR (SELECT Number FROM Inventory_Modified i WHERE i.LGid = doc.FundLGid) = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''')
				AND (''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR (SELECT Number FROM ArchiveEntity_Modified ae WHERE ae.LGid = doc.FundLGid) = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''')
				AND (''') + @isInRiskStr + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR CONVERT(NVARCHAR(4), doc.IsInRisk) = ') + @isInRiskStr + CONVERT(NVARCHAR(MAX), N')
				AND ((''-999'' IN (SELECT element FROM dbo.SplitString(''') + @DescriptionLevel + CONVERT(NVARCHAR(MAX), N''', '',''))) 
					OR (SELECT f.LevelOfDescriptionGid FROM Fund_Modified f 
						INNER JOIN Nomenclature n on n.Gid=f.LevelOfDescriptionGid
						WHERE f.LGid = doc.FundLGid AND n._retired = ''3000-01-01'') IN (SELECT element FROM dbo.SplitString(''') + @DescriptionLevel + CONVERT(NVARCHAR(MAX), N''', '',''))				
				)');

	SET @remoteQuery = REPLACE(@remoteQuery, '''', N'''''');


	DECLARE @sql NVARCHAR(MAX) = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';	

	exec (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetWorkListForPriorityRestorationReport] 
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
		order by Archive, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchivalEntityIntNumber, ArchiveEntityNumber
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	--PhysicalCondition дава грешка за някои заявки към ИСДА
	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = doc.ArchiveGid) as Archive,
				(SELECT fund.Number FROM Fund_Modified as fund WHERE fund.LGid = doc.FundLGid) as FundNumber,
				(SELECT inventory.Number FROM Inventory_Modified as inventory WHERE inventory.LGid = doc.InventoryLGid) as InventoryNumber,
				(SELECT ae.Number FROM ArchiveEntity_Modified as ae WHERE ae.LGid = doc.AELGid) as ArchiveEntityNumber,
				doc.LGid as DocumentSystemId,
				doc.PaperCount,
				(
					select top(1) Value -- слягам top(1), защото има записи, за които се чупи
					from  Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.DocumentGid = doc.Gid 
						and n1.Type=''PhisicalCondition''
				) as PhysicalCondition,
				doc.CopyDigital,
				doc.CopyMicrofilm,
				(SELECT fund.IntNumber FROM Fund_Modified as fund WHERE fund.LGid = doc.FundLGid) as FundIntNumber,
				(SELECT inventory.IntNumber FROM Inventory_Modified as inventory WHERE inventory.LGid = doc.InventoryLGid) as InventoryIntNumber,
				(SELECT ae.IntNumber FROM ArchiveEntity_Modified as ae WHERE ae.LGid = doc.AELGid) as ArchivalEntityIntNumber
			FROM Document_Modified as doc
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=doc.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))'

			SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				(SELECT Name FROM [Archives] a where a.Id = ArchiveId) as Archive,	
				(SELECT Number FROM Funds f where f.SystemIdentifier = FundSystemIdentifier) as FundNumber,
				(SELECT Number FROM Inventories i where i.SystemIdentifier = InventorySystemIdentifier) as InventoryNumber,
				(SELECT Number FROM ArchivalEntities ae where ae.SystemIdentifier = ArchivalEntitySystemIdentifier) as ArchiveEntityNumber,
				Id as DocumentSystemId,
				SheetCount as PaperCount,
				NULL as PhysicalCondition,
				DigitizedCopyCount as CopyDigital,
				MicrofilmedCopyCount as CopyMicrofilm,
				(SELECT NumberNumeric FROM Funds f where f.SystemIdentifier = FundSystemIdentifier) as FundIntNumber,
				(SELECT NumberNumeric FROM Inventories i where i.SystemIdentifier = InventorySystemIdentifier) as InventoryIntNumber,
				(SELECT NumberNumeric FROM ArchivalEntities ae where ae.SystemIdentifier = ArchivalEntitySystemIdentifier) as ArchivalEntityIntNumber
			FROM Documents 
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				Archive nvarchar(256) NOT NULL,
				FundNumber nvarchar(256) NULL,
				InventoryNumber nvarchar(256) NULL,
				ArchiveEntityNumber nvarchar(256) NULL,
				DocumentSystemId int NOT NULL,
				PaperCount int NULL,
				PhysicalCondition nvarchar(MAX) NULL,
				CopyDigital int NULL,
				CopyMicrofilm int NULL,
				FundIntNumber int null,
				InventoryIntNumber int null,
				ArchivalEntityIntNumber int null
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

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetWorkListForPriorityRestorationReportSummary]
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(10) = null,
	@Page int = 1
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Document_Modified as doc
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=doc.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))'

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Documents 
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE ( 
				TotalRows bigint NULL
			);

			INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
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

CREATE OR ALTER PROCEDURE [dbo].[MainSearchComponent]
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodesInternal nvarchar(256) = null,
	@DocumentDescriptionLevelCodesInternal nvarchar(256) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на ArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@KMFNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@EntityType nvarchar(250) = null,
	@ExtendedSearch bit = 0,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	declare @offset int = (@Page - 1) * @RowsOfPage;

	DECLARE @resultColumnsDeclaration VARCHAR(MAX) = '
		EntityType nvarchar(50) NULL,
		SystemIdentifier uniqueidentifier NULL,
		ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи на фондове го чупят в такъв случай
		FundNumber nvarchar(256) NULL,
		InventoryNumber nvarchar(256) NULL,
		ArchivalEntityNumber nvarchar(256) NULL,
		KMFNumber nvarchar(256) NULL,
		FilmCardNumber nvarchar(256) NULL,
		Title nvarchar(MAX) NULL,
		TypeText nvarchar(MAX) NULL,
		StatusText nvarchar(MAX) NULL,
		FundDescriptionLevelText nvarchar(MAX) NULL,
		InventoryDescriptionLevelText nvarchar(MAX) NULL,
		ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
		HasExternalSource BIT NOT NULL,
		ExternalIdentifier INT NULL,
		FundApproximateChronologicalScope nvarchar(256) NULL,
		InventoryApproximateChronologicalScope nvarchar(256) NULL,
		ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
		FilmSystemIdentifier uniqueidentifier NULL,
		FundGid int,
		FundIntNumber INT NULL,
		InventoryIntNumber INT NULL,
		ArchivalEntityIntNumber INT NULL,
		KMFIntNumber INT NULL, 
		FilmCardIntNumber INT NULL,
		[Rank] INT NULL,
		EntityTypeOrder INT
	';

	DECLARE @resultColumns VARCHAR(MAX) = '
		EntityType, 
		SystemIdentifier,
		ArchiveName,		
		FundNumber,
		InventoryNumber,
		ArchivalEntityNumber,
		KMFNumber,
		FilmCardNumber,
		Title,
		TypeText,
		StatusText,
		FundDescriptionLevelText,
		InventoryDescriptionLevelText,	
		ArchivalEntityDescriptionLevelText,
		HasExternalSource,
		ExternalIdentifier,
		FundApproximateChronologicalScope,
		InventoryApproximateChronologicalScope,
		ArchivalEntityApproximateChronologicalScope,
		FilmSystemIdentifier,
		FundGid,
		FundIntNumber,
		InventoryIntNumber,
		ArchivalEntityIntNumber,
		KMFIntNumber,
		FilmCardIntNumber,
		[Rank],
		EntityTypeOrder
	';

	DECLARE @keyWordsColumn VARCHAR(MAX) = '';
	IF @KeyWords IS NULL SET @keyWordsColumn = 'NULL' 
	ELSE SET @keyWordsColumn = '''' + @KeyWords + '''';

	DECLARE @toDateColumn VARCHAR(MAX) = '';
	IF @ToDate IS NULL SET @toDateColumn = 'NULL' 
	ELSE SET @toDateColumn = '''' + @ToDate + '''';

	DECLARE @fromDateColumn VARCHAR(MAX) = '';
	IF @FromDate IS NULL SET @fromDateColumn = 'NULL' 
	ELSE SET @fromDateColumn = '''' + @FromDate + '''';

	DECLARE @titleColumn VARCHAR(MAX) = '';
	IF @Title IS NULL SET @titleColumn = 'NULL' 
	ELSE SET @titleColumn = '''' + @Title + '''';

	DECLARE @fundNumberColumn VARCHAR(MAX) = '';
	IF @FundNumber IS NULL SET @fundNumberColumn = 'NULL' 
	ELSE SET @fundNumberColumn = '''' + @FundNumber + '''';

	DECLARE @inventoryNumberColumn VARCHAR(MAX) = '';
	IF @InventoryNumber IS NULL SET @inventoryNumberColumn = 'NULL' 
	ELSE SET @inventoryNumberColumn = '''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberColumn VARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NULL SET @archivalEntityNumberColumn = 'NULL' 
	ELSE SET @archivalEntityNumberColumn = '''' + @ArchivalEntityNumber + '''';

	DECLARE @kmfNumberColumn VARCHAR(MAX) = '';
	IF @KMFNumber IS NULL SET @kmfNumberColumn = 'NULL' 
	ELSE SET @kmfNumberColumn = '''' + @KMFNumber + '''';

	DECLARE @searchDigitalObjectColumn VARCHAR(MAX) = '';
	IF @SearchDigitalObject IS NULL SET @searchDigitalObjectColumn = 'NULL' 
	ELSE SET @searchDigitalObjectColumn = convert(varchar(1), @searchDigitalObject, 104);

	DECLARE @searchDraftsColumn VARCHAR(MAX) = '';
	IF @SearchDrafts IS NULL SET @searchDraftsColumn = 'NULL' 
	ELSE SET @searchDraftsColumn = convert(varchar(1), @SearchDrafts, 104);

	DECLARE @extendedSearchColumn VARCHAR(MAX) = '';
	IF @ExtendedSearch IS NULL SET @extendedSearchColumn = 'NULL' 
	ELSE SET @extendedSearchColumn = convert(varchar(1), @ExtendedSearch, 104);

	DECLARE @entityTypesArr TABLE (element VARCHAR(50) NULL); 
	INSERT INTO @entityTypesArr SELECT element from dbo.SplitString(@EntityType, ',');

	DECLARE @fundsInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalFunds BIT = 0;
	IF 'fund' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFunds = 1;
	IF  @InventoryNumber IS NULL 
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL 
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') SET @fundsInsert = '
			INSERT INTO @funds EXEC [dbo].[SearchFundsForMainSearchComponent] 
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@FundNumber = ' + @fundNumberColumn + ',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@DescriptionLevelCodesInternal  = ''' + @FundDescriptionLevelCodesInternal + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@FundArraysInternal = ''' + @FundArraysInternal + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFunds, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @inventoriesInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalIventories BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfInventory TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfInventory (Gid) VALUES (2171),(2172); -- нива на описание за опис от ИСДА
	IF 'inventory' IN (SELECT element FROM @entityTypesArr) SET @includeLocalIventories = 1;
	IF (NOT (@FundNumber IS NOT NULL AND @InventoryNumber IS NULL) 
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')) 
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfInventory INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) -- 3493 от DevOps
		OR EXISTS(SELECT Code FROM N.InventoryDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@InventoryDescriptionLevelCodesInternal, ',')))
		SET @inventoriesInsert = '
			INSERT INTO @inventories EXEC [dbo].[SearchInventoriesForMainSearchComponent] 
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@FundNumber = ' + @fundNumberColumn + ',
				@InventoryNumber = ' + @inventoryNumberColumn + ',
				@KMFCountriesOfOriginCodes  = ''' + @KMFCountriesOfOriginCodes + ''',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@FundDescriptionLevelCodesInternal = ''' + @FundDescriptionLevelCodesInternal + ''',
				@InventoryDescriptionLevelCodesInternal = ''' + @InventoryDescriptionLevelCodesInternal + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@FundArraysInternal = ''' + @FundArraysInternal + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalIventories, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @archivalEntitiesInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalArchivalEntities BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfArchivalEntities TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfArchivalEntities (Gid) VALUES (2174),(2373); -- нива на описание за АЕ от ИСДА
	IF 'archival_entity' IN (SELECT element FROM @entityTypesArr) SET @includeLocalArchivalEntities = 1;
	IF (NOT (@FundNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL)
		AND @KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')) 
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfArchivalEntities INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) -- 3493 от DevOps
		OR EXISTS(SELECT Code FROM N.ArchivalEntityDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@ArchivalEntityDescriptionLevelCodesInternal, ',')))
	SET @archivalEntitiesInsert = '
		INSERT INTO @archivalEntities EXEC [dbo].[SearchArchivalEntitiesForMainSearchComponent] 
			@LinkedServer = ''' + @LinkedServer + ''',
			@SearchDrafts = ' + @searchDraftsColumn + ',
			@ArchiveGids = ''' + @ArchiveGids + ''',
			@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
			@FundNumber = ' + @fundNumberColumn + ',
			@InventoryNumber = ' + @inventoryNumberColumn + ',
			@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
			@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
			@FundDescriptionLevelCodesInternal = ''' + @FundDescriptionLevelCodesInternal + ''',
			@InventoryDescriptionLevelCodesInternal = ''' + @InventoryDescriptionLevelCodesInternal + ''',
			@ArchivalEntityDescriptionLevelCodesInternal = ''' + @ArchivalEntityDescriptionLevelCodesInternal + ''',
			@ToDate = ' + @toDateColumn + ',
			@FromDate = ' + @fromDateColumn + ',
			@FundArrayGids = ''' + @FundArrayGids + ''',
			@FundArraysInternal = ''' + @FundArraysInternal + ''',
			@Title = ' + @titleColumn + ',
			@KeyWords = ' + @keyWordsColumn + ',
			--@KeywordsUIAnnotated = + @keywordsUIAnnotatedColumn + 		
			@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
			@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalArchivalEntities, 104) + ',
			@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @documentsInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalDocuments BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfDocuments TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfDocuments (Gid) VALUES (2173); -- ниво на описание за документ от ИСДА
	IF 'document' IN (SELECT element FROM @entityTypesArr) SET @includeLocalDocuments = 1;
	IF 
		-- това условие е било сложено нарочно, но искат да отпадне 
		--@FundNumber IS NULL AND @InventoryNumber IS NULL AND @ArchivalEntityNumber IS NULL
		--AND 
		(@KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfDocuments INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) -- 3493 от DevOps
		OR EXISTS(SELECT Code FROM N.DocumentDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@DocumentDescriptionLevelCodesInternal, ',')))
	SET @documentsInsert = '
		INSERT INTO @documents EXEC [dbo].[SearchDocumentsForMainSearchComponent] 
			@LinkedServer = ''' + @LinkedServer + ''',
			@SearchDrafts = ' + @searchDraftsColumn + ',
			@ArchiveGids = ''' + @ArchiveGids + ''',
			@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
			@FundNumber = ' + @fundNumberColumn + ',
			@InventoryNumber = ' + @inventoryNumberColumn + ',
			@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
			@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
			@FundDescriptionLevelCodesInternal = ''' + @FundDescriptionLevelCodesInternal + ''',
			@InventoryDescriptionLevelCodesInternal = ''' + @InventoryDescriptionLevelCodesInternal + ''',
			@ArchivalEntityDescriptionLevelCodesInternal = ''' + @ArchivalEntityDescriptionLevelCodesInternal + ''',
			@DocumentDescriptionLevelCodesInternal = ''' + @DocumentDescriptionLevelCodesInternal + ''',
			@ToDate = ' + @toDateColumn + ',
			@FromDate = ' + @fromDateColumn + ',
			@FundArrayGids = ''' + @FundArrayGids + ''',
			@FundArraysInternal = ''' + @FundArraysInternal + ''',
			@Title = ' + @titleColumn + ',
			@KeyWords = ' + @keyWordsColumn + ',
			--@KeywordsUIAnnotated = + @keywordsUIAnnotatedColumn + 		
			@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
			@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalDocuments, 104) + ',
			@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @filmsInsert VARCHAR(MAX) = ''; 
	DECLARE @includeLocalFilms BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfFilms TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfFilms (Gid) VALUES (2185); -- ниво на описание КМФ
	IF 'film' IN (SELECT element FROM @entityTypesArr) 
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilms INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) 
		SET @includeLocalFilms = 1;
	IF @FundNumber IS NULL 
		AND @InventoryNumber IS NULL
		AND @ArchivalEntityNumber IS NULL 
		AND @Title IS NULL SET @filmsInsert = '
			INSERT INTO @films EXEC [dbo].[SearchKMFForMainSearchComponent]
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@KMFNumber = ' + @kmfNumberColumn + ',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@KMFCountriesOfOriginCodes = ''' + @KMFCountriesOfOriginCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@KeyWords = ' + @keyWordsColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFilms, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @filmCardsInsert VARCHAR(MAX) = ''; 	
	DECLARE @includeLocalFilmCards BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfFilmCards TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfFilmCards (Gid) VALUES (2371); -- ниво на описание Архивна единица (КМФ)
	IF 'film_card' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFilmCards = 1;
	IF (NOT ((@FundNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL AND @KMFNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL AND @KMFNumber IS NULL)))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilmCards INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ',')))
		--OR NOT ((@FundNumber IS NOT NULL AND @KMFNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @KMFNumber IS NULL)) 
		SET @filmCardsInsert = '
			INSERT INTO @filmCards EXEC [dbo].[SearchFilmCardsForMainSearchComponent]
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@FundNumber  = ' + @fundNumberColumn + ',
				@InventoryNumber = ' + @inventoryNumberColumn + ',
				@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
				@KMFNumber = ' + @kmfNumberColumn + ',
				@KMFCountriesOfOriginCodes = ''' + @KMFCountriesOfOriginCodes + ''',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				--@KeywordsUIAnnotated =  + @keywordsUIAnnotatedColumn + 	
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFilmCards, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
		';

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @funds TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @inventories TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @archivalEntities TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @documents TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @films TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @filmCards TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @result TABLE ('
			+ @resultColumnsDeclaration +
		');'

		+ @fundsInsert + 
		+ @inventoriesInsert + 
		+ @archivalEntitiesInsert + 	
		+ @documentsInsert + 
		+ @filmsInsert +
		+ @filmCardsInsert + '

		INSERT INTO @result SELECT * FROM
			(
				SELECT ' + @resultColumns + ' FROM @funds

				UNION
		
				SELECT ' + @resultColumns + ' FROM @inventories

				UNION

				SELECT ' + @resultColumns + ' FROM @archivalEntities

				UNION

				SELECT ' + @resultColumns + ' FROM @documents

				UNION

				SELECT ' + @resultColumns + ' FROM @films	

				UNION

				SELECT ' + @resultColumns + ' FROM @filmCards
			) x

		
		SELECT
			EntityType, 
			SystemIdentifier,
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			FilmSystemIdentifier,
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			(SELECT COUNT(0) FROM @result) TotalRows,
			[Rank],
			EntityTypeOrder
		FROM @result
		ORDER BY 
			EntityTypeOrder,
			[Rank] DESC,                                                                                                                               
			ArchiveName ASC,  -- колоните с ...Int... представляват числото от номера
            FundIntNumber ASC,
			KMFIntNumber ASC,
            FundNumber ASC,
            InventoryIntNumber ASC,
            InventoryNumber ASC,
            ArchivalEntityIntNumber ASC,
            ArchivalEntityNumber ASC,
			FilmCardIntNumber ASC
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY
		';
	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[MainSearchComponentInternal]
	@LinkedServer nvarchar(50) = 'X', -- бърз фикс, не се ползва
	@SearchDrafts bit = 0,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@FundDescriptionLevelCodes nvarchar(256) = null,
	@InventoryDescriptionLevelCodes nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodes nvarchar(256) = null,
	@DocumentDescriptionLevelCodes nvarchar(256) = null,
	@FundArrays nvarchar(max) = null,
	@KMFNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@EntityType nvarchar(250) = null,
	@ExtendedSearch bit = 0,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	declare @offset int = (@Page - 1) * @RowsOfPage;

	DECLARE @resultColumnsDeclaration VARCHAR(MAX) = '
		EntityType nvarchar(50) NULL,
		SystemIdentifier uniqueidentifier NULL,
		ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи на фондове го чупят в такъв случай
		FundNumber nvarchar(256) NULL,
		InventoryNumber nvarchar(256) NULL,
		ArchivalEntityNumber nvarchar(256) NULL,
		KMFNumber nvarchar(256) NULL,
		FilmCardNumber nvarchar(256) NULL,
		Title nvarchar(MAX) NULL,
		TypeText nvarchar(MAX) NULL,
		StatusText nvarchar(MAX) NULL,
		FundDescriptionLevelText nvarchar(MAX) NULL,
		InventoryDescriptionLevelText nvarchar(MAX) NULL,
		ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
		HasExternalSource BIT NOT NULL,
		ExternalIdentifier INT NULL,
		FundApproximateChronologicalScope nvarchar(256) NULL,
		InventoryApproximateChronologicalScope nvarchar(256) NULL,
		ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
		FilmSystemIdentifier uniqueidentifier NULL,
		FundGid int,
		FundIntNumber INT NULL,
		InventoryIntNumber INT NULL,
		ArchivalEntityIntNumber INT NULL,
		KMFIntNumber INT NULL, 
		FilmCardIntNumber INT NULL,
		[Rank] INT NULL,
		EntityTypeOrder INT
	';

	DECLARE @resultColumns VARCHAR(MAX) = '
		EntityType, 
		SystemIdentifier,
		ArchiveName,		
		FundNumber,
		InventoryNumber,
		ArchivalEntityNumber,
		KMFNumber,
		FilmCardNumber,
		Title,
		TypeText,
		StatusText,
		FundDescriptionLevelText,
		InventoryDescriptionLevelText,	
		ArchivalEntityDescriptionLevelText,
		HasExternalSource,
		ExternalIdentifier,
		FundApproximateChronologicalScope,
		InventoryApproximateChronologicalScope,
		ArchivalEntityApproximateChronologicalScope,
		FilmSystemIdentifier,
		FundGid,
		FundIntNumber,
		InventoryIntNumber,
		ArchivalEntityIntNumber,
		KMFIntNumber,
		FilmCardIntNumber,
		[Rank],
		EntityTypeOrder
	';

	DECLARE @keyWordsColumn VARCHAR(MAX) = '';
	IF @KeyWords IS NULL SET @keyWordsColumn = 'NULL' 
	ELSE SET @keyWordsColumn = '''' + @KeyWords + '''';

	DECLARE @toDateColumn VARCHAR(MAX) = '';
	IF @ToDate IS NULL SET @toDateColumn = 'NULL' 
	ELSE SET @toDateColumn = '''' + @ToDate + '''';

	DECLARE @fromDateColumn VARCHAR(MAX) = '';
	IF @FromDate IS NULL SET @fromDateColumn = 'NULL' 
	ELSE SET @fromDateColumn = '''' + @FromDate + '''';

	DECLARE @titleColumn VARCHAR(MAX) = '';
	IF @Title IS NULL SET @titleColumn = 'NULL' 
	ELSE SET @titleColumn = '''' + @Title + '''';

	DECLARE @fundNumberColumn VARCHAR(MAX) = '';
	IF @FundNumber IS NULL SET @fundNumberColumn = 'NULL' 
	ELSE SET @fundNumberColumn = '''' + @FundNumber + '''';

	DECLARE @inventoryNumberColumn VARCHAR(MAX) = '';
	IF @InventoryNumber IS NULL SET @inventoryNumberColumn = 'NULL' 
	ELSE SET @inventoryNumberColumn = '''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberColumn VARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NULL SET @archivalEntityNumberColumn = 'NULL' 
	ELSE SET @archivalEntityNumberColumn = '''' + @ArchivalEntityNumber + '''';

	DECLARE @kmfNumberColumn VARCHAR(MAX) = '';
	IF @KMFNumber IS NULL SET @kmfNumberColumn = 'NULL' 
	ELSE SET @kmfNumberColumn = '''' + @KMFNumber + '''';

	DECLARE @searchDigitalObjectColumn VARCHAR(MAX) = '';
	IF @SearchDigitalObject IS NULL SET @searchDigitalObjectColumn = 'NULL' 
	ELSE SET @searchDigitalObjectColumn = convert(varchar(1), @searchDigitalObject, 104);

	DECLARE @searchDraftsColumn VARCHAR(MAX) = '';
	IF @SearchDrafts IS NULL SET @searchDraftsColumn = 'NULL' 
	ELSE SET @searchDraftsColumn = convert(varchar(1), @SearchDrafts, 104);

	DECLARE @extendedSearchColumn VARCHAR(MAX) = '';
	IF @ExtendedSearch IS NULL SET @extendedSearchColumn = 'NULL' 
	ELSE SET @extendedSearchColumn = convert(varchar(1), @ExtendedSearch, 104);

	--DECLARE @keywordsUIAnnotatedColumn VARCHAR(MAX) = '';
	--IF @KeywordsUIAnnotated IS NULL SET @keywordsUIAnnotatedColumn = 'NULL' 
	--ELSE SET @keywordsUIAnnotatedColumn = convert(varchar(1), @KeywordsUIAnnotated, 104);

	DECLARE @entityTypesArr TABLE (element VARCHAR(50) NULL); 
	INSERT INTO @entityTypesArr SELECT element from dbo.SplitString(@EntityType, ',');

	DECLARE @fundsInsert VARCHAR(MAX) = '';
	IF  @InventoryNumber IS NULL 
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL 
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') 
		AND 'fund' IN (SELECT element FROM @entityTypesArr) SET @fundsInsert = '
			INSERT INTO @funds EXEC [dbo].[SearchFundsForMainSearchComponentInternal] 
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveCodes = ''' + @ArchiveCodes + ''',
				@FundNumber = ' + @fundNumberColumn + ',
				@DescriptionLevelCodes  = ''' + @FundDescriptionLevelCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FundArrays = ''' + @FundArrays + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @inventoriesInsert VARCHAR(MAX) = '';
	IF (NOT (@FundNumber IS NOT NULL AND @InventoryNumber IS NULL)  
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') 
		AND 'inventory' IN (SELECT element FROM @entityTypesArr)) 
		OR EXISTS(SELECT Code FROM N.InventoryDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@InventoryDescriptionLevelCodes, ',')))
		SET @inventoriesInsert = '
			INSERT INTO @inventories EXEC [dbo].[SearchInventoriesForMainSearchComponentInternal] 
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveCodes = ''' + @ArchiveCodes + ''',
				@FundNumber = ' + @fundNumberColumn + ',
				@InventoryNumber = ' + @inventoryNumberColumn + ',
				@KMFCountriesOfOriginCodes  = ''' + @KMFCountriesOfOriginCodes + ''',
				@FundDescriptionLevelCodes = ''' + @FundDescriptionLevelCodes + ''',
				@InventoryDescriptionLevelCodes = ''' + @InventoryDescriptionLevelCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrays = ''' + @FundArrays + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @archivalEntitiesInsert VARCHAR(MAX) = '';
	IF (NOT (@FundNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL) 
		AND @KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') 
		AND 'archival_entity' IN (SELECT element FROM @entityTypesArr))
		OR EXISTS(SELECT Code FROM N.ArchivalEntityDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@ArchivalEntityDescriptionLevelCodes, ',')))
	SET @archivalEntitiesInsert = '
		INSERT INTO @archivalEntities EXEC [dbo].[SearchArchivalEntitiesForMainSearchComponentInternal] 
			@LinkedServer = ''' + @LinkedServer + ''',
			@SearchDrafts = ' + @searchDraftsColumn + ',
			@ArchiveCodes = ''' + @ArchiveCodes + ''',
			@FundNumber = ' + @fundNumberColumn + ',
			@InventoryNumber = ' + @inventoryNumberColumn + ',
			@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
			@FundDescriptionLevelCodes = ''' + @FundDescriptionLevelCodes + ''',
			@InventoryDescriptionLevelCodes = ''' + @InventoryDescriptionLevelCodes + ''',
			@ArchivalEntityDescriptionLevelCodes = ''' + @ArchivalEntityDescriptionLevelCodes + ''',
			@ToDate = ' + @toDateColumn + ',
			@FromDate = ' + @fromDateColumn + ',
			@FundArrays = ''' + @FundArrays + ''',
			@Title = ' + @titleColumn + ',
			@KeyWords = ' + @keyWordsColumn + ',
			--@KeywordsUIAnnotated = + @keywordsUIAnnotatedColumn + 		
			@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
			@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @documentsInsert VARCHAR(MAX) = '';
	IF 
		-- това условие е било сложено нарочно, но искат да отпадне 
		--@FundNumber IS NULL AND @InventoryNumber IS NULL AND @ArchivalEntityNumber IS NULL
		--AND 
		(@KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		OR EXISTS(SELECT Code FROM N.DocumentDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@DocumentDescriptionLevelCodes, ',')))
	SET @documentsInsert = '
		INSERT INTO @documents EXEC [dbo].[SearchDocumentsForMainSearchComponentInternal] 
			@LinkedServer = ''' + @LinkedServer + ''',
			@SearchDrafts = ' + @searchDraftsColumn + ',
			@ArchiveCodes = ''' + @ArchiveCodes + ''',
			@FundNumber = ' + @fundNumberColumn + ',
			@InventoryNumber = ' + @inventoryNumberColumn + ',
			@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
			@FundDescriptionLevelCodes = ''' + @FundDescriptionLevelCodes + ''',
			@InventoryDescriptionLevelCodes = ''' + @InventoryDescriptionLevelCodes + ''',
			@ArchivalEntityDescriptionLevelCodes = ''' + @ArchivalEntityDescriptionLevelCodes + ''',
			@DocumentDescriptionLevelCodes = ''' + @DocumentDescriptionLevelCodes + ''',
			@ToDate = ' + @toDateColumn + ',
			@FromDate = ' + @fromDateColumn + ',
			@FundArrays = ''' + @FundArrays + ''',
			@Title = ' + @titleColumn + ',
			@KeyWords = ' + @keyWordsColumn + ',
			--@KeywordsUIAnnotated = + @keywordsUIAnnotatedColumn + 		
			@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
			@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @filmsInsert VARCHAR(MAX) = ''; 
	IF @FundNumber IS NULL 
		AND @InventoryNumber IS NULL
		AND @ArchivalEntityNumber IS NULL 
		AND 'film' IN (SELECT element FROM @entityTypesArr) SET @filmsInsert = '
			INSERT INTO @films EXEC [dbo].[SearchKMFForMainSearchComponentInternal]
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveCodes = ''' + @ArchiveCodes + ''',
				@KMFNumber = ' + @kmfNumberColumn + ',
				@KMFCountriesOfOriginCodes = ''' + @KMFCountriesOfOriginCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @filmCardsInsert VARCHAR(MAX) = ''; 	
	IF @FundNumber IS NULL 
		AND @InventoryNumber IS NULL 
		AND 'film_card' IN (SELECT element FROM @entityTypesArr) SET @filmCardsInsert = '
			INSERT INTO @filmCards EXEC [dbo].[SearchFilmCardsForMainSearchComponentInternal]
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveCodes = ''' + @ArchiveCodes + ''',
				@KMFNumber = ' + @kmfNumberColumn + ',
				@KMFCountriesOfOriginCodes = ''' + @KMFCountriesOfOriginCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				--@KeywordsUIAnnotated =  + @keywordsUIAnnotatedColumn + 	
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @funds TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @inventories TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @archivalEntities TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @documents TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @films TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @filmCards TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @result TABLE ('
			+ @resultColumnsDeclaration +
		');'

		+ @fundsInsert + 
		+ @inventoriesInsert + 
		+ @archivalEntitiesInsert + 
		+ @documentsInsert + 
		+ @filmsInsert +
		+ @filmCardsInsert + '

		INSERT INTO @result SELECT * FROM
			(
				SELECT ' + @resultColumns + ' FROM @funds

				UNION
		
				SELECT ' + @resultColumns + ' FROM @inventories

				UNION

				SELECT ' + @resultColumns + ' FROM @archivalEntities

				UNION

				SELECT ' + @resultColumns + ' FROM @documents

				UNION

				SELECT ' + @resultColumns + ' FROM @films	

				UNION

				SELECT ' + @resultColumns + ' FROM @filmCards
			) x

		
		SELECT
			EntityType, 
			SystemIdentifier,
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			FilmSystemIdentifier,
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			(SELECT COUNT(0) FROM @result) TotalRows,
			[Rank],
			EntityTypeOrder
		FROM @result
		ORDER BY 
			EntityTypeOrder,
			[Rank] DESC,
			ArchiveName ASC,  -- колоните с ...Int... представляват числото от номера
            FundIntNumber ASC,
			KMFIntNumber ASC,
            FundNumber ASC,
            InventoryIntNumber ASC,
            InventoryNumber ASC,
            ArchivalEntityIntNumber ASC,
            ArchivalEntityNumber ASC,
			FilmCardIntNumber ASC
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY
		';

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[SearchArchivalEntitiesForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodesInternal nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	--@KeywordsUIAnnotated nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	DECLARE @remoteQuery nvarchar(max), @kwds int, @kwdsAnnotated int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1;
	--set @kwdsAnnotated=0;
	--if @KeywordsUIAnnotated is not null and len(@KeywordsUIAnnotated) >=2 set @kwdsAnnotated=1;
	if @Title is not null and len(@Title) >= 2 set @ttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rankRemote = ',kwds.[Rank] as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankRemote = ',fttl.[Rank] as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rankRemote = ',(isnull(kwds.[Rank], 0) + isnull(fttl.[Rank], 0)) as Rank';

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilterRemote = ' and fttl.[Rank] > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilterRemote = ' and isnull(kwds.[Rank], 0) > 1 and isnull(fttl.[Rank], 0) > 1';

	SET @remoteQuery = '';
	SET @remoteQuery = 'with fresults as (';
	set @remoteQuery = @remoteQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''archival_entity'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = ae.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		inventory.Number as InventoryNumber,
		ae.Number as ArchivalEntityNumber,
		NULL as KMFNumber,
		NULL as FilmCardNumber,
		ae.Title,
		NULL as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = ae.StatusGid) as StatusText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.LevelOfDescriptionGid) as FundDescriptionLevelText,	
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = inventory.LevelOfDescriptionGid) as InventoryDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		ae.LGid AS ExternalIdentifier,
		fund.TextDate AS FundApproximateChronologicalScope,
		inventory.TextDate AS InventoryApproximateChronologicalScope,
		ae.TextDate AS ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		NULL AS FundGid,
		fund.IntNumber as FundIntNumber,
		inventory.IntNumber AS InventoryIntNumber,
		ae.IntNumber AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		ae.Gid,
		ae.LGid'
		+ @rankRemote
		+ ',3 AS EntityTypeOrder';

	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		from ArchiveEntity_Active as ae
	';
	else set @remoteQuery = @remoteQuery + '
		from ArchiveEntity_Modified as ae
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Inventory_Active inventory on inventory.LGid=ae.InventoryLGid
	';
	else set @remoteQuery = @remoteQuery + '
		inner join Inventory_Modified inventory on inventory.LGid=ae.InventoryLGid
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Fund_Active fund on fund.LGid=ae.FundLGid
	';
	else set @remoteQuery = @remoteQuery + '
		inner join Fund_Modified fund on fund.LGid=ae.FundLGid
	';
	if @kwds = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(ArchiveEntity,*, '''+ @KeyWords + ''') kwds on ae._id = kwds.[key]
	';
	if @ttl = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(ArchiveEntity,Title, '''+ @Title + ''') fttl on ae._id = fttl.[key]
	';
	--if @kwdsAnnotated =1 set @remoteQuery = @remoteQuery + '
		--inner join ObjectNomenclature on1 on on1.ArchiveEntityGid = ae.Gid and on1._retired = ''3000-01-01''
		--inner join Nomenclature n1 on on1.NomenclatureGid = n1.Gid and n1.[Type] = ''Annotated'' and n1._retired = ''3000-01-01''
		--inner join freetexttable(Nomenclature,*,@KeywordsUIAnnotated) fts1 on n1._id = fts1.[key] ';
	if @ArchiveGids is not null and @ArchiveGids <> '-999' set @remoteQuery = @remoteQuery + '
		where ae.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else set @remoteQuery = @remoteQuery + '
		where 1 = 1
	';
	set @remoteQuery = @remoteQuery + '
		and (fund.LevelOfDescriptionGid <> 2185 or ae.LevelOfDescriptionGid <> 2371)
	';
	--if @ArchivalEntityNumber is not null set @remoteQuery = @remoteQuery + '
		--and (ae.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired = ''3000-01-01'' and [Type] = ''LevelOfDescription'' AND Code = 11)) --Арх.ед. - копия от чужди архиви
	--';
	if @FundNumber is not null set @remoteQuery = @remoteQuery + '
		and (fund.Number = ''' + @FundNumber + ''')
	';
	if @InventoryNumber is not null set @remoteQuery = @remoteQuery + '
		and (inventory.Number = ''' + @InventoryNumber + ''')
	';
	if @ArchivalEntityNumber is not null set @remoteQuery = @remoteQuery + '
		and (ae.Number = ''' + @ArchivalEntityNumber + ''')
	';
	if @ArchivalEntityNumber is not null
		and not '2174' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2373' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteQuery = @remoteQuery + '
			and (ae.LevelOfDescriptionGid in (2174,2373))
	' 
	else if @ArchivalEntityNumber is null
		and not '2174' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2373' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteQuery = @remoteQuery + '
			and 1=2
	' 
	else if @LevelOfDescriptionGids <> '-999'
		and ('2174' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')) or '2373' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')))
		set @remoteQuery = @remoteQuery + '
			and (ae.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )
	';
	if @ToDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @ToDate +''' >= ae.CreationDate)
	';
	if @FromDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @FromDate + ''' <= ae.CreationDate)
	';
	--if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
	--	and ((select FundArrayGid from ' + @fundsView + ' where LGid = inventory.FundLGid) in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	--';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
		and (fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +') 
	'
	if @SearchDigitalObject = 1 and  @SearchDrafts = 1  set @remoteQuery = @remoteQuery + '
		AND (exists (select 1 from Document_Search_Active doc where doc.AELGid = ae.LGid and doc.HasDigitalObject = 1))
	';
	else if @SearchDigitalObject = 1  set @remoteQuery = @remoteQuery + '
		AND (exists (select 1 from Document_Search_Modified doc where doc.AELGid = ae.LGid and doc.HasDigitalObject = 1))
	';
	else if @SearchDigitalObject = 0 and  @SearchDrafts = 1  set @remoteQuery = @remoteQuery + '
		AND ( not exists (select 1 from Document_Search_Active doc where doc.AELGid = ae.LGid and doc.HasDigitalObject = 1)	)
	';
	else if @SearchDigitalObject = 0  set @remoteQuery = @remoteQuery + '
		AND (not exists (select 1 from Document_Search_Modified doc where doc.AELGid = ae.LGid and doc.HasDigitalObject = 1))
	';	
	set @remoteQuery = @remoteQuery + @rankFilterRemote;


	if @SearchDrafts = 1 set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = fresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131	)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,	
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @fundsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = ae.FundSystemIdentifier';
	IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = ae.FundSystemIdentifier';

	DECLARE @inventoriesJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @inventoriesJoin = ' inner join v_Inventories i on i.SystemIdentifier = ae.InventorySystemIdentifier';
	IF @SearchDrafts = 0 SET @inventoriesJoin = ' inner join v_PublicInventories i on i.SystemIdentifier = ae.InventorySystemIdentifier';

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsAE.[KEY] as aeId, null as aeDId, kwdsAE.[RANK] as RankKwds
			from freetexttable(ArchivalEntities, *, ''' + @KeyWords + ''') kwdsAE
			union 
			select null as aeId, kwdsAED.[KEY] as aeDId, kwdsAED.[RANK] as RankKwds  
			from freetexttable(ArchivalEntityDrafts, *, ''' + @KeyWords + ''') kwdsAED
		) kwds
		on (ae.Id = kwds.aeDId and ae.IsDraft = 1) or (ae.Id = kwds.aeId and ae.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlAE.[KEY] as aeId, null as aeDId, ttlAE.[RANK] as RankTitle   
			from freetexttable(ArchivalEntities, Title, ''' + @Title + ''') ttlAE 
			union 
			select null as aeId, ttlAEd.[KEY] as aeDId, ttlAEd.[RANK] as RankTitle   
			from freetexttable(ArchivalEntityDrafts, Title, ''' + @Title + ''') ttlAEd
		) ttl
		on (ae.Id = ttl.aeDId and ae.IsDraft = 1) or (ae.Id = ttl.aeId and ae.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rank = ',RankTitle as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';

	DECLARE @isSuspenedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 1  SET @isSuspenedFilter = ' AND f.IsSuspended = 0 AND i.IsSuspended = 0 AND ae.IsSuspended = 0';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberFilter VARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NOT NULL SET @archivalEntityNumberFilter = ' AND ae.Number=''' + @ArchivalEntityNumber + '''';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = ae.StatusCode) <> 12';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_ArchivalEntities' ELSE SET @table = 'v_PublicArchivalEntities';

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' left join v_PublicDocuments d on d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' left join v_Documents d on d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';

	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	IF @SearchDrafts = 1 SET @digitalObjectsTable = 'v_DigitalObjects';
	DECLARE @digitalObjectsFilter VARCHAR(MAX) = '';
	IF @SearchDigitalObject = 1 SET @digitalObjectsFilter = ' and (exists(select 1 from ' + @digitalObjectsTable  + ' do 
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0'
			+ @suspended +
		'))';
	IF @SearchDigitalObject = 0 SET @digitalObjectsFilter = ' and (not exists(select 1 from ' + @digitalObjectsTable  + ' do
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0
		))';

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';		

	DECLARE @archivalEntityDescriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @ArchivalEntityNumber is not null and @FundDescriptionLevelCodesInternal = '-111' set @FundDescriptionLevelCodesInternal = '-999';
	if @ArchivalEntityNumber is not null and @InventoryDescriptionLevelCodesInternal = '-111' set @InventoryDescriptionLevelCodesInternal = '-999';
	if @ArchivalEntityNumber is not null and @ArchivalEntityDescriptionLevelCodesInternal = '-111' 
		set @archivalEntityDescriptionLevelCodesFilter = '' 
	else
		set @archivalEntityDescriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodesInternal + ''', '',''))) 
				OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodesInternal + ''', '',''))))
		';

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			''archival_entity'' AS EntityType,
			ae.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = i.ArchiveId) as ArchiveName,	
			f.Number as FundNumber,
			i.Number as InventoryNumber,
			ae.Number as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			ae.Title as Title,
			NULL as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = ae.StatusCode) as StatusText,
			(SELECT Text FROM [N].[FundDescriptionLevel] fdl where fdl.Code = f.DescriptionLevelCode) as FundDescriptionLevelText,
			(SELECT Text FROM [N].[InventoryDescriptionLevel] idl where idl.Code = i.DescriptionLevelCode) as InventoryDescriptionLevelText,
			(SELECT Text FROM [N].[ArchivalEntityDescriptionLevel] aedl where aedl.Code = ae.DescriptionLevelCode) as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			f.ApproxmateChronologicalScope as FundApproximateChronologicalScope,
			i.ApproxmateChronologicalScope as InventoryApproximateChronologicalScope,
			ae.ApproxmateChronologicalScope as  ArchivalEntityApproximateChronologicalScope,
			NULL as FilmSystemIdentifier,
			NULL as FundGid,
			ae.FundNumberNumeric AS FundIntNumber,
			ae.InventoryNumberNumeric AS InventoryIntNumber,
			ae.NumberNumeric AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			3 as EntityTypeOrder
		FROM ' + @table + ' ae'
		+ @inventoriesJoin +
		+ @fundsJoin + 
		+ @documentsJoin +
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE ae.ExternalIdentifier IS NULL AND ae.HasExternalSource = 0 AND ae.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (ae.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + 
			+ @archivalEntityNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundDescriptionLevel fdl where fdl.Code = f.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.InventoryDescriptionLevel idl where idl.Code = i.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(ae.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(ae.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @archivalEntityDescriptionLevelCodesFilter
			+ @doNotGetAnythingFilter
			+ @isSuspenedFilter
			+ @digitalObjectsFilter
			+ @isDeductedFilter
			+ @rankFilter;

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteInventoriesTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи го чупят в такъв случай	
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL,
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NOT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT
		);

		INSERT INTO @remoteInventoriesTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteInventoriesTable
		UNION
		' +
		@localQuery;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[SearchArchivalEntitiesForMainSearchComponentInternal]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@FundDescriptionLevelCodes nvarchar(256) = null,
	@InventoryDescriptionLevelCodes nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrays nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	--@KeywordsUIAnnotated nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @kwds int, @kwdsAnnotated int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1;
	--set @kwdsAnnotated=0;
	--if @KeywordsUIAnnotated is not null and len(@KeywordsUIAnnotated) >=2 set @kwdsAnnotated=1;
	if @Title is not null and len(@Title) >= 2 set @ttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @fundsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = ae.FundSystemIdentifier';
	IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = ae.FundSystemIdentifier';

	DECLARE @inventoriesJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @inventoriesJoin = ' inner join v_Inventories i on i.SystemIdentifier = ae.InventorySystemIdentifier';
	IF @SearchDrafts = 0 SET @inventoriesJoin = ' inner join v_PublicInventories i on i.SystemIdentifier = ae.InventorySystemIdentifier';

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsAE.[KEY] as aeId, null as aeDId, kwdsAE.[RANK] as RankKwds
			from freetexttable(ArchivalEntities, *, ''' + @KeyWords + ''') kwdsAE
			union 
			select null as aeId, kwdsAED.[KEY] as aeDId, kwdsAED.[RANK] as RankKwds  
			from freetexttable(ArchivalEntityDrafts, *, ''' + @KeyWords + ''') kwdsAED
		) kwds
		on (ae.Id = kwds.aeDId and ae.IsDraft = 1) or (ae.Id = kwds.aeId and ae.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlAE.[KEY] as aeId, null as aeDId, ttlAE.[RANK] as RankTitle   
			from freetexttable(ArchivalEntities, Title, ''' + @Title + ''') ttlAE 
			union 
			select null as aeId, ttlAEd.[KEY] as aeDId, ttlAEd.[RANK] as RankTitle   
			from freetexttable(ArchivalEntityDrafts, Title, ''' + @Title + ''') ttlAEd
		) ttl
		on (ae.Id = ttl.aeDId and ae.IsDraft = 1) or (ae.Id = ttl.aeId and ae.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rank = ',RankTitle as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';

	DECLARE @isSuspenedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 1  SET @isSuspenedFilter = '  AND f.IsSuspended = 0 AND i.IsSuspended = 0 AND ae.IsSuspended = 0';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberFilter VARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NOT NULL SET @archivalEntityNumberFilter = ' AND ae.Number=''' + @ArchivalEntityNumber + '''';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = ae.StatusCode) <> 12';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_ArchivalEntities' ELSE SET @table = 'v_PublicArchivalEntities';

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' left join v_PublicDocuments d on d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' left join v_Documents d on d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';
	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	IF @SearchDrafts = 1 SET @digitalObjectsTable = 'v_DigitalObjects';
	DECLARE @digitalObjectsFilter VARCHAR(MAX) = '';
	IF @SearchDigitalObject = 1 SET @digitalObjectsFilter = ' and (exists(select 1 from ' + @digitalObjectsTable  + ' do 
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0'
			+ @suspended +
		'))';
	IF @SearchDigitalObject = 0 SET @digitalObjectsFilter = ' and (not exists(select 1 from ' + @digitalObjectsTable  + ' do
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0
		))';	
		
	DECLARE @archivalEntityDescriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @ArchivalEntityNumber is not null and @FundDescriptionLevelCodes = '-111' set @FundDescriptionLevelCodes = '-999';
	if @ArchivalEntityNumber is not null and @InventoryDescriptionLevelCodes = '-111' set @InventoryDescriptionLevelCodes = '-999';
	if @ArchivalEntityNumber is not null and @ArchivalEntityDescriptionLevelCodes = '-111' 
		set @archivalEntityDescriptionLevelCodesFilter = '' 
	else
		set @archivalEntityDescriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodes + ''', '',''))) 
				OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodes + ''', '',''))))
		';

	DECLARE @sql VARCHAR(MAX) = '
		SELECT
			''archival_entity'' AS EntityType,
			ae.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = i.ArchiveId) as ArchiveName,	
			f.Number as FundNumber,
			i.Number as InventoryNumber,
			ae.Number as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			ae.Title as Title,
			NULL as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = ae.StatusCode) as StatusText,
			(SELECT Text FROM [N].[FundDescriptionLevel] fdl where fdl.Code = f.DescriptionLevelCode) as FundDescriptionLevelText,
			(SELECT Text FROM [N].[InventoryDescriptionLevel] idl where idl.Code = i.DescriptionLevelCode) as InventoryDescriptionLevelText,
			(SELECT Text FROM [N].[ArchivalEntityDescriptionLevel] aedl where aedl.Code = ae.DescriptionLevelCode) as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			f.ApproxmateChronologicalScope as FundApproximateChronologicalScope,
			i.ApproxmateChronologicalScope as InventoryApproximateChronologicalScope,
			ae.ApproxmateChronologicalScope as  ArchivalEntityApproximateChronologicalScope,
			NULL as FilmSystemIdentifier,
			NULL as FundGid,
			ae.FundNumberNumeric AS FundIntNumber,
			ae.InventoryNumberNumeric AS InventoryIntNumber,
			ae.NumberNumeric AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			3 as EntityTypeOrder
		FROM ' + @table + ' ae'
		+ @inventoriesJoin +
		+ @fundsJoin + 
		+ @documentsJoin +
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE ae.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (ae.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + 
			+ @archivalEntityNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodes + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundDescriptionLevel fdl where fdl.Code = f.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodes + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.InventoryDescriptionLevel idl where idl.Code = i.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodes + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(ae.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(ae.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @archivalEntityDescriptionLevelCodesFilter
			+ @isSuspenedFilter
			+ @digitalObjectsFilter
			+ @isDeductedFilter
			+ @rankFilter;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[SearchDocumentsForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodesInternal nvarchar(256) = null,
	@DocumentDescriptionLevelCodesInternal nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	--@KeywordsUIAnnotated nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	DECLARE @remoteQuery nvarchar(max), @kwds int, @kwdsAnnotated int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1;
	--set @kwdsAnnotated=0;
	--if @KeywordsUIAnnotated is not null and len(@KeywordsUIAnnotated) >=2 set @kwdsAnnotated=1;
	if @Title is not null and len(@Title) >= 2 set @ttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rankRemote = ',kwds.[Rank] as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankRemote = ',fttl.[Rank] as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rankRemote = ',(isnull(kwds.[Rank], 0) + isnull(fttl.[Rank], 0)) as Rank';

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilterRemote = ' and fttl.[Rank] > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilterRemote = ' and isnull(kwds.[Rank], 0) > 1 and isnull(fttl.[Rank], 0) > 1';

	SET @remoteQuery = '';
	SET @remoteQuery = 'with dresults as (';
	set @remoteQuery = @remoteQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''document'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = doc.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		inventory.Number as InventoryNumber,
		ae.Number as ArchivalEntityNumber,
		NULL as KMFNumber,
		NULL as FilmCardNumber,
		doc.Title,
		NULL as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = doc.StatusGid) as StatusText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.LevelOfDescriptionGid) as FundDescriptionLevelText,	
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = inventory.LevelOfDescriptionGid) as InventoryDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		doc.LGid AS ExternalIdentifier,
		NULL AS FundApproximateChronologicalScope,
		NULL AS InventoryApproximateChronologicalScope,
		NULL AS ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		NULL AS FundGid,
		fund.IntNumber as FundIntNumber,
		inventory.IntNumber AS InventoryIntNumber,
		ae.IntNumber AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		doc.Gid,
		doc.LGid'
		+ @rankRemote
		+ ',4 AS EntityTypeOrder';

	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		from Document_Active as doc
	';
	else set @remoteQuery = @remoteQuery + '
		from Document_Modified as doc
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join ArchiveEntity_Search_Active ae on ae.LGid=doc.AELGid
	';
	else set @remoteQuery = @remoteQuery + '
		inner join ArchiveEntity_Search_Modified ae on ae.LGid=doc.AELGid
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Inventory_Search_Active inventory on inventory.LGid=doc.InventoryLGid
	';
	else set @remoteQuery = @remoteQuery + '
		inner join Inventory_Search_Modified inventory on inventory.LGid=doc.InventoryLGid
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Fund_Search_Active fund on fund.LGid=doc.FundLGid
	';
	else set @remoteQuery = @remoteQuery + '
		inner join Fund_Search_Modified fund on fund.LGid=doc.FundLGid
	';
	if @kwds = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(Document,*, '''+ @KeyWords + ''') kwds on doc._id = kwds.[key]
	';
	if @ttl = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(Document,Title, '''+ @Title + ''') fttl on doc._id = fttl.[key]
	';
	--if @kwdsAnnotated =1 set @sql = @sql + '
    --inner join ObjectNomenclature on1 on on1.DocumentGid = doc.Gid and on1._retired = ''3000-01-01''
	--inner join Nomenclature n1 on on1.NomenclatureGid = n1.Gid and n1.[Type] = ''Annotated'' and n1._retired = ''3000-01-01''
	--inner join freetexttable(Nomenclature,*,@KeywordsUIAnnotated) fts1 on n1._id = fts1.[key] '
	if @ArchiveGids is not null and @ArchiveGids <> '-999' set @remoteQuery = @remoteQuery + '
		where doc.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else set @remoteQuery = @remoteQuery + '
		where 1 = 1
	';
	--if @ArchivalEntityNumber is not null set @remoteQuery = @remoteQuery + '
		--and (ae.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired = ''3000-01-01'' and [Type] = ''LevelOfDescription'' AND Code = 11)) --Арх.ед. - копия от чужди архиви
	--';
	if @FundNumber is not null set @remoteQuery = @remoteQuery + '
		and (fund.Number = ''' + @FundNumber + ''')
	';
	if @InventoryNumber is not null set @remoteQuery = @remoteQuery + '
		and (inventory.Number = ''' + @InventoryNumber + ''')
	';
	if @ArchivalEntityNumber is not null set @remoteQuery = @remoteQuery + '
		and (ae.Number = ''' + @ArchivalEntityNumber + ''')
	';
	if @LevelOfDescriptionGids is not null and @LevelOfDescriptionGids <> '-999' set @remoteQuery = @remoteQuery + '
		and (doc.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )
	';
	if @ToDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @ToDate +''' >= doc.CreationDate)
	';
	if @FromDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @FromDate + ''' <= doc.CreationDate)
	';
	--if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
	--	and ((select FundArrayGid from ' + @fundsView + ' where LGid = inventory.FundLGid) in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	--';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
		and (fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +') 
	'

	if @SearchDigitalObject = 1 set @remoteQuery = @remoteQuery + '
		AND doc.HasDigitalObject = 1
	';
	else if @SearchDigitalObject = 0  set @remoteQuery = @remoteQuery + '
		AND doc.HasDigitalObject = 0
	';
	set @remoteQuery = @remoteQuery + @rankFilterRemote;

	if @SearchDrafts = 1 set @remoteQuery=@remoteQuery+'),
		dresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from dresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from dresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = dresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteQuery=@remoteQuery+'),
		dresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from dresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,	
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from dresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @fundsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = d.FundSystemIdentifier';
	IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = d.FundSystemIdentifier';

	DECLARE @inventoriesJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @inventoriesJoin = ' inner join v_Inventories i on i.SystemIdentifier = d.InventorySystemIdentifier';
	IF @SearchDrafts = 0 SET @inventoriesJoin = ' inner join v_PublicInventories i on i.SystemIdentifier = d.InventorySystemIdentifier';

	DECLARE @archivalEntitiesJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @archivalEntitiesJoin = ' inner join v_ArchivalEntities ae on ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier';
	IF @SearchDrafts = 0 SET @archivalEntitiesJoin = ' inner join v_PublicArchivalEntities ae on ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier';

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsD.[KEY] as dId, null as dDId, kwdsD.[RANK] as RankKwds
			from freetexttable(Documents, *, ''' + @KeyWords + ''') kwdsD
			union 
			select null as dId, kwdsDD.[KEY] as dDId, kwdsDD.[RANK] as RankKwds  
			from freetexttable(DocumentDrafts, *, ''' + @KeyWords + ''') kwdsDD
		) kwds
		on (d.Id = kwds.dDId and d.IsDraft = 1) or (d.Id = kwds.dId and d.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlD.[KEY] as dId, null as dDId, ttlD.[RANK] as RankTitle   
			from freetexttable(Documents, Title, ''' + @Title + ''') ttlD 
			union 
			select null as dId, ttlDd.[KEY] as dDId, ttlDd.[RANK] as RankTitle   
			from freetexttable(DocumentDrafts, Title, ''' + @Title + ''') ttlDd
		) ttl
		on (d.Id = ttl.dDId and d.IsDraft = 1) or (d.Id = ttl.dId and d.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rank = ',RankTitle as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';

	DECLARE @isSuspendedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 1  SET @isSuspendedFilter = '  AND f.IsSuspended = 0 AND i.IsSuspended = 0  AND ae.IsSuspended = 0 and d.IsSuspended = 0';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberFilter VARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NOT NULL SET @archivalEntityNumberFilter = ' AND ae.Number=''' + @ArchivalEntityNumber + '''';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = d.StatusCode) <> 12';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Documents' ELSE SET @table = 'v_PublicDocuments';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';
	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	IF @SearchDrafts = 1 SET @digitalObjectsTable = 'v_DigitalObjects';
	DECLARE @digitalObjectsFilter VARCHAR(MAX) = '';
	IF @SearchDigitalObject = 1 SET @digitalObjectsFilter = ' and (exists(select 1 from ' + @digitalObjectsTable  + ' do 
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0'
			+ @suspended +
		'))';
	IF @SearchDigitalObject = 0 SET @digitalObjectsFilter = ' and (not exists(select 1 from ' + @digitalObjectsTable  + ' do
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0
		))';

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';		

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			''document'' AS EntityType,
			d.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = d.ArchiveId) as ArchiveName,	
			f.Number as FundNumber,
			i.Number as InventoryNumber,
			ae.Number as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			d.Title as Title,
			NULL as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = d.StatusCode) as StatusText,
			NULL as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			NULL as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as  ArchivalEntityApproximateChronologicalScope,
			NULL as FilmSystemIdentifier,
			NULL as FundGid,
			d.FundNumberNumeric AS FundIntNumber,
			d.InventoryNumberNumeric AS InventoryIntNumber,
			d.ArchivalEntityNumberNumeric AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			4 as EntityTypeOrder
		FROM ' + @table + ' d'
		+ @fundsJoin + 
		+ @inventoriesJoin +
		+ @archivalEntitiesJoin +
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (d.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + 
			+ @archivalEntityNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))) 
				OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))) 
				OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodesInternal + ''', '',''))) 
				OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @DocumentDescriptionLevelCodesInternal + ''', '',''))) 
				OR (d.DescriptionLevelCode in (select element from dbo.SplitString(''' + @DocumentDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(d.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(d.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @doNotGetAnythingFilter
			+ @isSuspendedFilter
			+ @digitalObjectsFilter
			+ @isDeductedFilter
			+ @rankFilter;


	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteDocumentsTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи го чупят в такъв случай	
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL,
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NOT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT
		);

		INSERT INTO @remoteDocumentsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteDocumentsTable
		UNION
		' +
		@localQuery;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[SearchDocumentsForMainSearchComponentInternal]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@FundDescriptionLevelCodes nvarchar(256) = null,
	@InventoryDescriptionLevelCodes nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodes nvarchar(256) = null,
	@DocumentDescriptionLevelCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrays nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	--@KeywordsUIAnnotated nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @kwds int, @kwdsAnnotated int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1;
	--set @kwdsAnnotated=0;
	--if @KeywordsUIAnnotated is not null and len(@KeywordsUIAnnotated) >=2 set @kwdsAnnotated=1;
	-------------------------------------------------------------------------

	DECLARE @fundsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = d.FundSystemIdentifier';
	IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = d.FundSystemIdentifier';

	DECLARE @inventoriesJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @inventoriesJoin = ' inner join v_Inventories i on i.SystemIdentifier = d.InventorySystemIdentifier';
	IF @SearchDrafts = 0 SET @inventoriesJoin = ' inner join v_PublicInventories i on i.SystemIdentifier = d.InventorySystemIdentifier';

	DECLARE @archivalEntitiesJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @archivalEntitiesJoin = ' inner join v_ArchivalEntities ae on ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier';
	IF @SearchDrafts = 0 SET @archivalEntitiesJoin = ' inner join v_PublicArchivalEntities ae on ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier';

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsD.[KEY] as dId, null as dDId, kwdsD.[RANK] as RankKwds
			from freetexttable(Documents, *, ''' + @KeyWords + ''') kwdsD
			union 
			select null as dId, kwdsDD.[KEY] as dDId, kwdsDD.[RANK] as RankKwds  
			from freetexttable(DocumentDrafts, *, ''' + @KeyWords + ''') kwdsDD
		) kwds
		on (d.Id = kwds.dDId and d.IsDraft = 1) or (d.Id = kwds.dId and d.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlD.[KEY] as dId, null as dDId, ttlD.[RANK] as RankTitle   
			from freetexttable(Documents, Title, ''' + @Title + ''') ttlD 
			union 
			select null as dId, ttlDd.[KEY] as dDId, ttlDd.[RANK] as RankTitle   
			from freetexttable(DocumentDrafts, Title, ''' + @Title + ''') ttlDd
		) ttl
		on (d.Id = ttl.dDId and d.IsDraft = 1) or (d.Id = ttl.dId and d.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rank = ',RankTitle as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';

	DECLARE @isSuspendedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 1  SET @isSuspendedFilter = '  AND f.IsSuspended = 0 AND i.IsSuspended = 0  AND ae.IsSuspended = 0 and d.IsSuspended = 0';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberFilter VARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NOT NULL SET @archivalEntityNumberFilter = ' AND ae.Number=''' + @ArchivalEntityNumber + '''';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = d.StatusCode) <> 12';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Documents' ELSE SET @table = 'v_PublicDocuments';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';
	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	IF @SearchDrafts = 1 SET @digitalObjectsTable = 'v_DigitalObjects';
	DECLARE @digitalObjectsFilter VARCHAR(MAX) = '';
	IF @SearchDigitalObject = 1 SET @digitalObjectsFilter = ' and (exists(select 1 from ' + @digitalObjectsTable  + ' do 
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0'
			+ @suspended +
		'))';
	IF @SearchDigitalObject = 0 SET @digitalObjectsFilter = ' and (not exists(select 1 from ' + @digitalObjectsTable  + ' do
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0
		))';		

	DECLARE @sql VARCHAR(MAX) = '
		SELECT
			''document'' AS EntityType,
			d.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = d.ArchiveId) as ArchiveName,	
			f.Number as FundNumber,
			i.Number as InventoryNumber,
			ae.Number as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			d.Title as Title,
			NULL as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = d.StatusCode) as StatusText,
			NULL as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			NULL as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as  ArchivalEntityApproximateChronologicalScope,
			NULL as FilmSystemIdentifier,
			NULL as FundGid,
			d.FundNumberNumeric AS FundIntNumber,
			d.InventoryNumberNumeric AS InventoryIntNumber,
			d.ArchivalEntityNumberNumeric AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			4 as EntityTypeOrder
		FROM ' + @table + ' d'
		+ @fundsJoin + 
		+ @inventoriesJoin +
		+ @archivalEntitiesJoin +
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (d.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + 
			+ @archivalEntityNumberFilter + 
			+ @isDeductedFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodes + ''', '',''))) 
				OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodes + ''', '',''))) 
				OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodes + ''', '',''))) 
				OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @DocumentDescriptionLevelCodes + ''', '',''))) 
				OR (d.DescriptionLevelCode in (select element from dbo.SplitString(''' + @DocumentDescriptionLevelCodes + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(d.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(d.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @isSuspendedFilter
			+ @digitalObjectsFilter
			+ @rankFilter;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[SearchFilmCardsForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@KMFNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	--@KeywordsUIAnnotated nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	DECLARE @remoteQuery nvarchar(max), @kwds int, @kwdsAnnotated int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1;
	--set @kwdsAnnotated=0;
	--if @KeywordsUIAnnotated is not null and len(@KeywordsUIAnnotated) >=2 set @kwdsAnnotated=1;
	If @Title is not null and len(@Title) >= 2 set @ttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rankRemote = ',kwds.[Rank] as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankRemote = ',fttl.[Rank] as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rankRemote = ',(isnull(kwds.[Rank], 0) + isnull(fttl.[Rank], 0)) as Rank';

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilterRemote = ' and fttl.[Rank] > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilterRemote = ' and isnull(kwds.[Rank], 0) > 1 and isnull(fttl.[Rank], 0) > 1';

	SET @remoteQuery = '';
	SET @remoteQuery = 'with fresults as (';
	set @remoteQuery = @remoteQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''film_card'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = ae.ArchiveGid) AS ArchiveName,
		jf.Number as FundNumber,
		ji.Number as InventoryNumber,
		ae.Number as ArchivalEntityNumber,
		NULL as KMFNumber,
		ae.Number as FilmCardNumber,
		ae.Title as Title,
		NULL as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = ae.StatusGid) as StatusText,
		(select Value FROM Nomenclature n WHERE n.Gid= jf.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as FundDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= ji.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as InventoryDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		ae.LGid AS ExternalIdentifier,
		jf.TextDate AS FundApproximateChronologicalScope,
		ji.TextDate AS InventoryApproximateChronologicalScope,
		ae.TextDate AS ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		jf.Gid AS FundGid,
		jf.IntNumber as FundIntNumber,
		ji.IntNumber AS InventoryIntNumber,
		ae.IntNumber AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		ae.IntNumber AS FilmCardIntNumber,
		ae.Gid,
		ae.LGid'
		+ @rankRemote
		+ ',6 AS EntityTypeOrder';

	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		from ArchiveEntity_Active as ae
	';
	else set @remoteQuery = @remoteQuery + '
		from ArchiveEntity_Modified as ae
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Inventory_Active ji on ji.LGid=ae.InventoryLGid
	';
	else set @remoteQuery = @remoteQuery + '
		inner join Inventory_Modified ji on ji.LGid=ae.InventoryLGid
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Fund_Active jf on jf.LGid=ae.FundLGid
	';
	else set @remoteQuery = @remoteQuery + '
		inner join Fund_Modified jf on jf.LGid=ae.FundLGid
	';
	if @kwds = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(ArchiveEntity,*, '''+ @KeyWords + ''') kwds on ae._id = kwds.[key]
	';
	if @ttl = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(ArchiveEntity,Title, '''+ @Title + ''') fttl on ae._id = fttl.[key]
	';
	--if @kwdsAnnotated =1 set @remoteQuery = @remoteQuery + '
		--inner join ObjectNomenclature on1 on on1.ArchiveEntityGid = ae.Gid and on1._retired = ''3000-01-01''
		--inner join Nomenclature n1 on on1.NomenclatureGid = n1.Gid and n1.[Type] = ''Annotated'' and n1._retired = ''3000-01-01''
		--inner join freetexttable(Nomenclature,*,@KeywordsUIAnnotated) fts1 on n1._id = fts1.[key] ';
	if @ArchiveGids is not null and @ArchiveGids <> '-999' set @remoteQuery = @remoteQuery + '
		where ae.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else set @remoteQuery = @remoteQuery + '
		where 1 = 1';
	if @KMFCountriesOfOriginCodes is not null and @KMFCountriesOfOriginCodes <> '-999' set  @remoteQuery = @remoteQuery + '
		and ((select n.Value2 from Nomenclature n where n.Gid = jf.CountryGid and n.Type = ''FACountry'') in (''' + [dbo].[StringSplit3](@KMFCountriesOfOriginCodes) + '''))	
	';	
	set @remoteQuery = @remoteQuery + '
		and (jf.LevelOfDescriptionGid = 2185)
		and (ae.LevelOfDescriptionGid = 2371)
	';
	if @KMFNumber is not null or @ArchivalEntityNumber is not null and @LevelOfDescriptionGids <> '-999' set @remoteQuery = @remoteQuery + ''
	else set @remoteQuery = @remoteQuery + '
			and ((ae.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) +') or -999 in (' + @LevelOfDescriptionGids + '))
		';
	--if @ArchivalEntityNumber is not null set @remoteQuery = @remoteQuery + '
		--and (ae.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired = ''3000-01-01'' and [Type] = ''LevelOfDescription'' AND Code = 11)) --Арх.ед. - копия от чужди архиви
	--';
	if @FundNumber is not null set @remoteQuery = @remoteQuery + '
		and (jf.Number = ''' + @FundNumber + ''')
	';
	if @InventoryNumber is not null set @remoteQuery = @remoteQuery + '
		and (ji.Number = ''' + @InventoryNumber + ''')
	';
	if @ArchivalEntityNumber is not null set @remoteQuery = @remoteQuery + '
		and (ae.Number = ''' + @ArchivalEntityNumber + ''')
	';
	if @KMFNumber is not null set @remoteQuery = @remoteQuery + '
		and (ae.Number = ''' + @KMFNumber + ''')
	';
	if @ToDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @ToDate +''' >= ae.CreationDate)
	';
	if @FromDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @FromDate + ''' <= ae.CreationDate)
	';
	--if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
	--	and ((select FundArrayGid from ' + @fundsView + ' where LGid = inventory.FundLGid) in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	--';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
		and (jf.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +') 
	';
	set @remoteQuery = @remoteQuery + @rankFilterRemote;

	if @SearchDrafts = 1 set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = fresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131	)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,	
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsFC.[KEY] as fcId, null as fcDId, kwdsFC.[RANK] as RankKwds
			from freetexttable(FilmCards, *, ''' + @KeyWords + ''') kwdsFC
			union 
			select null as fcId, kwdsFCD.[KEY] as fcDId, kwdsFCD.[RANK] as RankKwds  
			from freetexttable(FilmCardDrafts, *, ''' + @KeyWords + ''') kwdsFCD
		) kwds
		on (c.Id = kwds.fcDId and c.IsDraft = 1) or (c.Id = kwds.fcId and c.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlFC.[KEY] as fcId, null as fcDId, ttlFC.[RANK] as RankTitle   
			from freetexttable(FilmCards, Title, ''' + @Title + ''') ttlFC 
			union 
			select null as fcId, ttlFCD.[KEY] as fcDId, ttlFCD.[RANK] as RankTitle   
			from freetexttable(FilmCardDrafts, Title, ''' + @Title + ''') ttlFCD
		) ttl
		on (c.Id = ttl.fcDId and c.IsDraft = 1) or (c.Id = ttl.fcId and c.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rank = ',ttl.RankTitle as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(ttl.RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and ttl.RankTitle > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(ttl.RankTitle, 0) > 1';

	DECLARE @kmfCountriesOfOriginCodesFilter VARCHAR(MAX) = '';
	IF @KMFCountriesOfOriginCodes IS NOT NULL SET @kmfCountriesOfOriginCodesFilter = ' AND c.CountryId = ''' + @kmfCountriesOfOriginCodesFilter + '''';

	DECLARE @kmfNumberFilter VARCHAR(MAX) = '';
	IF @KMFNumber IS NOT NULL SET @kmfNumberFilter = ' AND c.FilmInventoryNumber=''' + @KMFNumber + '''';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_FilmCards' ELSE SET @table = 'v_PublicFilmCards'; -- къде е v_PublicFilmCards?

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 0 
		OR @FundNumber IS NOT NULL
		OR @InventoryNumber IS NOT NULL
		OR @ArchivalEntityNumber IS NOT NULL 
		SET @doNotGetAnythingFilter = ' AND 1 = 2' 
	ELSE SET @doNotGetAnythingFilter = '';	

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			''film_card'' AS EntityType,
			c.SystemIdentifier,
			(SELECT Name FROM Archives a where a.Id = c.ArchiveId) as ArchiveName,	
			NULL as FundNumber,
			NULL as InventoryNumber,
			NULL as ArchivalEntityNumber,
			c.FilmInventoryNumber as KMFNumber,
			c.InventoryNumber AS KMFNumber,
			c.Title as Title,
			NULL as TypeText,
			NULL as StatusText,
			NULL as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			NULL as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as  ArchivalEntityApproximateChronologicalScope,
			c.FilmSystemIdentifier,
			NULL as FundGid,
			NULL as FundIntNumber,
			NULL AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			c.FilmInventoryNumber AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			6 as EntityTypeOrder
		FROM ' + @table + ' c'
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE c.ExternalIdentifier IS NULL AND c.HasExternalSource = 0 AND c.Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (c.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(c.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(c.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @KMFCountriesOfOriginCodes + ''', '',''))) 
				OR (c.CountryCode in (select element from dbo.SplitString(''' + @KMFCountriesOfOriginCodes + ''', '',''))))'
			+ @kmfNumberFilter
			+ @doNotGetAnythingFilter
			+ @rankFilter;


	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteFilmCardsTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи го чупят в такъв случай	
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL,
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NOT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
		    FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT
		);

		INSERT INTO @remoteFilmCardsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteFilmCardsTable
		UNION
		' +
		@localQuery;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[SearchFilmCardsForMainSearchComponentInternal]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveCodes nvarchar(10) = null,
	@KMFNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	--@KeywordsUIAnnotated nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @kwds int, @kwdsAnnotated int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1;
	--set @kwdsAnnotated=0;
	--if @KeywordsUIAnnotated is not null and len(@KeywordsUIAnnotated) >=2 set @kwdsAnnotated=1;
	if @Title is not null and len(@Title) >= 2 set @ttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsFC.[KEY] as fcId, null as fcDId, kwdsFC.[RANK] as RankKwds
			from freetexttable(FilmCards, *, ''' + @KeyWords + ''') kwdsFC
			union 
			select null as fcId, kwdsFCD.[KEY] as fcDId, kwdsFCD.[RANK] as RankKwds  
			from freetexttable(FilmCardDrafts, *, ''' + @KeyWords + ''') kwdsFCD
		) kwds
		on (c.Id = kwds.fcDId and c.IsDraft = 1) or (c.Id = kwds.fcId and c.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlFC.[KEY] as fcId, null as fcDId, ttlFC.[RANK] as RankTitle   
			from freetexttable(FilmCards, Title, ''' + @Title + ''') ttlFC 
			union 
			select null as fcId, ttlFCD.[KEY] as fcDId, ttlFCD.[RANK] as RankTitle   
			from freetexttable(FilmCardDrafts, Title, ''' + @Title + ''') ttlFCD
		) ttl
		on (c.Id = ttl.fcDId and c.IsDraft = 1) or (c.Id = ttl.fcId and c.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rank = ',ttl.RankTitle as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(ttl.RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and ttl.RankTitle > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(ttl.RankTitle, 0) > 1';

	DECLARE @kmfCountriesOfOriginCodesFilter VARCHAR(MAX) = '';
	IF @KMFCountriesOfOriginCodes IS NOT NULL SET @kmfCountriesOfOriginCodesFilter = ' AND c.CountryId = ''' + @kmfCountriesOfOriginCodesFilter + '''';

	DECLARE @kmfNumberFilter VARCHAR(MAX) = '';
	IF @KMFNumber IS NOT NULL SET @kmfNumberFilter = ' AND f.InventoryNumber=''' + @KMFNumber + '''';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_FilmCards' ELSE SET @table = 'v_PublicFilmCards'; -- къде е v_PublicFilmCards?

	DECLARE @sql VARCHAR(MAX) = '
		SELECT
			''film_card'' AS EntityType,
			c.SystemIdentifier,
			(SELECT Name FROM Archives a where a.Id = c.ArchiveId) as ArchiveName,	
			NULL as FundNumber,
			NULL as InventoryNumber,
			NULL as ArchivalEntityNumber,
			c.FilmInventoryNumber as KMFNumber,
			c.InventoryNumber AS KMFNumber,
			c.Title as Title,
			NULL as TypeText,
			NULL as StatusText,
			NULL as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			NULL as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as  ArchivalEntityApproximateChronologicalScope,
			c.FilmSystemIdentifier,
			NULL as FundGid,
			NULL as FundIntNumber,
			NULL AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			c.FilmInventoryNumber AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			6 as EntityTypeOrder
		FROM ' + @table + ' c'
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE c.Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (c.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(c.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(c.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @KMFCountriesOfOriginCodes + ''', '',''))) 
				OR (c.CountryCode in (select element from dbo.SplitString(''' + @KMFCountriesOfOriginCodes + ''', '',''))))'
			+ @kmfNumberFilter
			+ @rankFilter;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[SearchFundsForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@DescriptionLevelCodesInternal nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	DECLARE @remoteQuery nvarchar(max), @kwds int, @fttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1
	if @Title is not null and len(@Title) >= 2 set @fttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @fttl IS NULL SET @rankRemote = ',kwds.[Rank] as Rank'; 
	IF @kwds <> 1 AND @fttl = 1 SET @rankRemote = ',fttl.[Rank] as Rank';
	IF @kwds = 1 AND @fttl = 1 SET @rankRemote = ',(isnull(kwds.[Rank], 0) + isnull(fttl.[Rank], 0)) as Rank';

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 AND @fttl IS NULL SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 
	IF @kwds <> 1 AND @fttl = 1 SET @rankFilterRemote = ' and fttl.[Rank] > 1';
	IF @kwds = 1 AND @fttl = 1 SET @rankFilterRemote = ' and isnull(kwds.[Rank], 0) > 1 and isnull(fttl.[Rank], 0) > 1';

	SET @remoteQuery = '';
	SET @remoteQuery = 'with fresults as (';
	set @remoteQuery = @remoteQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''fund'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = fund.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		NULL as InventoryNumber,
		NULL as ArchivalEntityNumber,
		NULL as KMFNumber,
		NULL as FilmCardNumber,
		fund.Title,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.TypeGid) as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.StatusGid) as StatusText,
		(select Value FROM Nomenclature n WHERE n.Gid= fund.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as FundDescriptionLevelText,		
		NULL as InventoryDescriptionLevelText,
		NULL as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		fund.LGid AS ExternalIdentifier,
		fund.TextDate as FundApproximateChronologicalScope,
		NULL as InventoryApproximateChronologicalScope,
		NULL as ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		fund.Gid AS FundGid,
		fund.IntNumber as FundIntNumber,
		NULL AS InventoryIntNumber,
		NULL AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		fund.Gid,
		fund.LGid'
		+ @rankRemote
		+ ',1 AS EntityTypeOrder';

	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		from Fund_Active as fund
	'
	else set @remoteQuery = @remoteQuery + '
		from Fund_Modified as fund
	';
	if @kwds = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(Fund,*,'''+ @KeyWords + ''') kwds on fund._id = kwds.[key]
	';
	if @fttl = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(Fund,(Title,FundFormerNameChange), '''+ @Title + ''') fttl on fund._id = fttl.[key]
	';
	if @ArchiveGids is not null and @ArchiveGids <> '-999' set @remoteQuery = @remoteQuery + '
		where fund.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else set @remoteQuery = @remoteQuery + '
		where 1 = 1'; 
	if @FundNumber is not null set @remoteQuery = @remoteQuery + '
		and (fund.Number = ''' + @FundNumber + ''')
	';
	
	set @remoteQuery = @remoteQuery + 'and fund.LevelOfDescriptionGid <> 2185';
	-- въведен е номер на фонд, но не е избрано някое от нивата на описание за фондове, така имплицитно се разбира, че нивото на описание е някое от нивата за фонд(така са го поискали в писмо)
	if @FundNumber is not null
		and not '20' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '21' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '22' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '91' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteQuery = @remoteQuery + '
			and (fund.LevelOfDescriptionGid in (20,21,22,91))
	' 
	else if @LevelOfDescriptionGids <> '-999' 
		set @remoteQuery = @remoteQuery + '
			and (fund.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )
	';
	if @ToDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @ToDate +''' >= fund.CreationDate)
	';
	if @FromDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @FromDate + ''' <= fund.CreationDate)
	';
	if @SearchDigitalObject = 1 and  @SearchDrafts = 1  set @remoteQuery = @remoteQuery + '
		AND (exists (select 1 from Document_Search_Active doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
	';
	else if @SearchDigitalObject = 1  set @remoteQuery = @remoteQuery + '
		AND (exists (select 1 from Document_Search_Modified doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
	';
	else if @SearchDigitalObject = 0 and  @SearchDrafts = 1  set @remoteQuery = @remoteQuery + '
		AND ( not exists (select 1 from Document_Search_Active doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1)	)
	';
	else if @SearchDigitalObject = 0  set @remoteQuery = @remoteQuery + '
		AND ( not exists (select 1 from Document_Search_Modified doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
	';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
		and ( fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	';
	set @remoteQuery = @remoteQuery + @rankFilterRemote;

	if @SearchDrafts = 1 set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,	
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = fresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131	)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,	
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsf.[KEY] as fId, null as fdId, kwdsf.[RANK] as RankKwds
			from freetexttable(Funds, *, ''' + @KeyWords + ''') kwdsf
			union 
			select null as fId, kwdsfd.[KEY] as fdId, kwdsfd.[RANK] as RankKwds  
			from freetexttable(FundDrafts, *, ''' + @KeyWords + ''') kwdsfd
		) kwds
		on (f.Id = kwds.fdId and f.IsDraft = 1) or (f.Id = kwds.fId and f.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @fttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select fttf.[KEY] as fId, null as fdId, fttf.[RANK] as RankTitle   
			from freetexttable(Funds, (Title,FundCreatorTitleHistory), ''' + @Title + ''') fttf 
			union 
			select null as fId, fttfd.[KEY] as fdId, fttfd.[RANK] as RankTitle   
			from freetexttable(FundDrafts, (Title,FundCreatorTitleHistory), ''' + @Title + ''') fttfd
		) ftt
		on (f.Id = ftt.fdId and f.IsDraft = 1) or (f.Id = ftt.fId and f.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @fttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @fttl = 1 SET @rank = ',RankTitle as Rank';
	IF @kwds = 1 AND @fttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	DECLARE @rankKwdsGroupBy VARCHAR(MAX) = '';
	IF @kwds = 1 AND @fttl IS NULL
	BEGIN
		 SET @rankFilter = ' and RankKwds > 1'; 
		 SET @rankKwdsGroupBy = ',kwds.RankKwds';
	END
	DECLARE @rankTitleGroupBy VARCHAR(MAX) = '';
	IF @kwds <> 1 AND @fttl = 1 
	BEGIN
		SET @rankFilter = ' and RankTitle > 1';
		SET @rankTitleGroupBy = ',ftt.RankTitle';
	END
	IF @kwds = 1 AND @fttl = 1
	BEGIN
		SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';
		SET @rankKwdsGroupBy = ',kwds.RankKwds';
		SET @rankTitleGroupBy = ',ftt.RankTitle';
	END

	DECLARE @isSuspenedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 1  SET @isSuspenedFilter = '  AND f.IsSuspended = 0';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber IS NOT NULL SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' left join v_PublicDocuments d on d.FundSystemIdentifier = f.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' left join v_Documents d on d.FundSystemIdentifier = f.SystemIdentifier';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = f.StatusCode) <> 12';

	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	IF @SearchDrafts = 1 SET @digitalObjectsTable = 'v_DigitalObjects';
	DECLARE @digitalObjectsFilter VARCHAR(MAX) = '';
	IF @SearchDigitalObject = 1 SET @digitalObjectsFilter = ' and (exists(select 1 from ' + @digitalObjectsTable  + ' do 
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0'
			+ @suspended +
		'))';
	IF @SearchDigitalObject = 0 SET @digitalObjectsFilter = ' and (not exists(select 1 from ' + @digitalObjectsTable  + ' do
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0
		))';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Funds' ELSE SET @table = 'v_PublicFunds';

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';

	DECLARE @descriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @FundNumber is not null and @DescriptionLevelCodesInternal = '-111' 
		set @descriptionLevelCodesFilter = '' 
	else
		set @descriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @DescriptionLevelCodesInternal + ''', '',''))) 
				OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''' + @DescriptionLevelCodesInternal + ''', '',''))))
		';

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			''fund'' AS EntityType,
			f.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = f.ArchiveId) as ArchiveName,
			f.Number as FundNumber,
			NULL as InventoryNumber,
			NULL as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			f.Title,
			(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as StatusText,
			(SELECT Text FROM [N].[FundDescriptionLevel] dl where dl.Code = f.DescriptionLevelCode) as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			f.ApproxmateChronologicalScope as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as ArchivalEntityApproximateChronologicalScope,
			f.SystemIdentifier as FilmSystemIdentifier,
			NULL as FundGid,
			f.NumberNumeric AS FundIntNumber,
			NULL AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			1 as EntityTypeOrder
		FROM ' + @table + ' f'
		+ @freeTextTableByTitleJoin + 
		+ @freeTextTableByKwdsJoin + 
		+ @documentsJoin + '
		WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR (f.NumberArray in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (f.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @fundNumberFilter + '
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @descriptionLevelCodesFilter
			+ @digitalObjectsFilter
			+ @doNotGetAnythingFilter
			+ @isSuspenedFilter
			+ @isDeductedFilter
			+ @rankFilter;

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteFundsTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи го чупят в такъв случай
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL, 
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NOT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteFundsTable
		UNION
		' +
		@localQuery + '
		GROUP BY 
			--f.EntityType, 
			f.SystemIdentifier,
			f.ArchiveName,
			f.Number,
			--f.InventoryNumber,
			--f.ArchivalEntityNumber,
			f.Title,
			--f.TypeText,
			--f.StatusText,
			--f.FundDescriptionLevelText,
			--f.InventoryDescriptionLevelText,
			f.HasExternalSource,
			f.ExternalIdentifier,
			--f.InventoryApproximateChronologicalScope,
			-- тези, ако ги няма, се чупи
			f.ArchiveId,
			f.TypeCode,
			f.StatusCode,
			f.DescriptionLevelCode,
			f.ApproxmateChronologicalScope
			' + @rankKwdsGroupBy + ' 
			' + @rankTitleGroupBy + ' 
			,f.NumberNumeric
	';

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[SearchFundsForMainSearchComponentInternal]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@DescriptionLevelCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrays nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @remoteQuery nvarchar(max), @kwds int, @fttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1
	if @Title is not null and len(@Title) >= 2 set @fttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsf.[KEY] as fId, null as fdId, kwdsf.[RANK] as RankKwds
			from freetexttable(Funds, *, ''' + @KeyWords + ''') kwdsf
			union 
			select null as fId, kwdsfd.[KEY] as fdId, kwdsfd.[RANK] as RankKwds  
			from freetexttable(FundDrafts, *, ''' + @KeyWords + ''') kwdsfd
		) kwds
		on (f.Id = kwds.fdId and f.IsDraft = 1) or (f.Id = kwds.fId and f.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @fttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select fttf.[KEY] as fId, null as fdId, fttf.[RANK] as RankTitle   
			from freetexttable(Funds, (Title,FundCreatorTitleHistory), ''' + @Title + ''') fttf 
			union 
			select null as fId, fttfd.[KEY] as fdId, fttfd.[RANK] as RankTitle   
			from freetexttable(FundDrafts, (Title,FundCreatorTitleHistory), ''' + @Title + ''') fttfd
		) ftt
		on (f.Id = ftt.fdId and f.IsDraft = 1) or (f.Id = ftt.fId and f.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @fttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @fttl = 1 SET @rank = ',RankTitle as Rank';
	IF @kwds = 1 AND @fttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	DECLARE @rankKwdsGroupBy VARCHAR(MAX) = '';
	IF @kwds = 1 AND @fttl IS NULL
	BEGIN
		 SET @rankFilter = ' and RankKwds > 1'; 
		 SET @rankKwdsGroupBy = ',kwds.RankKwds';
	END
	DECLARE @rankTitleGroupBy VARCHAR(MAX) = '';
	IF @kwds <> 1 AND @fttl = 1 
	BEGIN
		SET @rankFilter = ' and RankTitle > 1';
		SET @rankTitleGroupBy = ',ftt.RankTitle';
	END
	IF @kwds = 1 AND @fttl = 1
	BEGIN
		SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';
		SET @rankKwdsGroupBy = ',kwds.RankKwds';
		SET @rankTitleGroupBy = ',ftt.RankTitle';
	END

	DECLARE @isSuspenedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 1  SET @isSuspenedFilter = '  AND f.IsSuspended = 0';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber IS NOT NULL SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @titleFilter VARCHAR(MAX) = '';
	IF @Title IS NOT NULL SET @titleFilter = ' AND (f.Title LIKE ''%' + @Title + '%'' OR f.FundCreatorTitleHistory LIKE ''%' + @Title + '%'')';

	DECLARE @kewWordsFilter VARCHAR(MAX) = '';
	IF @KeyWords IS NOT NULL SET @kewWordsFilter = ' AND (f.Title LIKE ''%' + @KeyWords + '%'' OR f.FundCreatorTitleHistory LIKE ''%' + @KeyWords + '%'')';

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' left join v_PublicDocuments d on d.FundSystemIdentifier = f.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' left join v_Documents d on d.FundSystemIdentifier = f.SystemIdentifier';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = f.StatusCode) <> 12';

	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	IF @SearchDrafts = 1 SET @digitalObjectsTable = 'v_DigitalObjects';
	DECLARE @digitalObjectsFilter VARCHAR(MAX) = '';
	IF @SearchDigitalObject = 1 SET @digitalObjectsFilter = ' and (exists(select 1 from ' + @digitalObjectsTable  + ' do 
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0'
			+ @suspended +
		'))';
	IF @SearchDigitalObject = 0 SET @digitalObjectsFilter = ' and (not exists(select 1 from ' + @digitalObjectsTable  + ' do
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0
		))';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Funds' ELSE SET @table = 'v_PublicFunds';

	DECLARE @descriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @FundNumber is not null and @DescriptionLevelCodes = '-111' 
		set @descriptionLevelCodesFilter = '' 
	else
		set @descriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @DescriptionLevelCodes + ''', '',''))) 
				OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''' + @DescriptionLevelCodes + ''', '',''))))
		';

	DECLARE @sql VARCHAR(MAX) = '
		SELECT
			''fund'' AS EntityType,
			f.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = f.ArchiveId) as ArchiveName,
			f.Number as FundNumber,
			NULL as InventoryNumber,
			NULL as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			f.Title,
			(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as StatusText,
			(SELECT Text FROM [N].[FundDescriptionLevel] dl where dl.Code = f.DescriptionLevelCode) as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			f.ApproxmateChronologicalScope as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as ArchivalEntityApproximateChronologicalScope,
			f.SystemIdentifier as FilmSystemIdentifier,
			NULL as FundGid,
			f.NumberNumeric AS FundIntNumber,
			NULL AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			1 as EntityTypeOrder
		FROM ' + @table + ' f'
		+ @freeTextTableByTitleJoin 
		+ @freeTextTableByKwdsJoin 
		+ @documentsJoin + '
		WHERE f.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))) 
				OR (f.NumberArray in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (f.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) )'
			+ @fundNumberFilter + '
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @descriptionLevelCodesFilter
			+ @digitalObjectsFilter 
			+ @isSuspenedFilter
			+ @isDeductedFilter
			+ @rankFilter 
			+ '
		GROUP BY 
			--f.EntityType, 
			f.SystemIdentifier,
			f.ArchiveName,
			f.Number,
			--f.InventoryNumber,
			--f.ArchivalEntityNumber,
			f.Title,
			--f.TypeText,
			--f.StatusText,
			--f.FundDescriptionLevelText,
			--f.InventoryDescriptionLevelText,
			f.HasExternalSource,
			f.ExternalIdentifier,
			--f.InventoryApproximateChronologicalScope,
			-- тези, ако ги няма, се чупи
			f.ArchiveId,
			f.TypeCode,
			f.StatusCode,
			f.DescriptionLevelCode,
			f.ApproxmateChronologicalScope
			' + @rankKwdsGroupBy + ' 
			' + @rankTitleGroupBy + ' 
			,f.NumberNumeric
		';

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[SearchInventoriesForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	DECLARE @remoteQuery nvarchar(max), @kwds int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1
	if @Title is not null and len(@Title) >= 2 set @ttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rankRemote = ',kwds.[Rank] as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankRemote = ',fttl.[Rank] as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rankRemote = ',(isnull(kwds.[Rank], 0) + isnull(fttl.[Rank], 0)) as Rank';

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilterRemote = ' and fttl.[Rank] > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilterRemote = ' and isnull(kwds.[Rank], 0) > 1 and isnull(fttl.[Rank], 0) > 1';

	SET @remoteQuery = '';
	SET @remoteQuery = 'with fresults as (';
	set @remoteQuery = @remoteQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''inventory'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = inventory.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		inventory.Number as InventoryNumber,
		NULL as ArchivalEntityNumber,
		NULL as KMFNumber,
		NULL as FilmCardNumber,
		fund.Title as Title,
		NULL as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = inventory.StatusGid) as StatusText,
		(select Value FROM Nomenclature n WHERE n.Gid= fund.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as FundDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= inventory.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as InventoryDescriptionLevelText,	
		NULL as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		inventory.LGid AS ExternalIdentifier,
		fund.TextDate AS FundApproximateChronologicalScope,
		inventory.TextDate AS InventoryApproximateChronologicalScope,
		NULL as ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		fund.Gid AS FundGid,
		fund.IntNumber as FundIntNumber,
		inventory.IntNumber AS InventoryIntNumber,
		NULL AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		inventory.Gid,
		inventory.LGid'
		+ @rankRemote
		+ ',2 AS EntityTypeOrder';

	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		from Inventory_Active as inventory
	'
	else set @remoteQuery = @remoteQuery + '
		from Inventory_Modified as inventory
	';
	if @kwds = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(Inventory,*, '''+ @KeyWords + ''') kwds on inventory._id = kwds.[key]
	';
	if @ttl = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(Inventory,FundCreatorNameChanges, '''+ @Title + ''') fttl on inventory._id = fttl.[key]
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Fund_Active fund on inventory.FundLGid = fund.LGid
	'
	if @SearchDrafts = 0 set @remoteQuery = @remoteQuery + '
		inner join Fund_Modified fund on inventory.FundLGid = fund.LGid
	'
	if @ArchiveGids is not null and @ArchiveGids <> '-999' set @remoteQuery = @remoteQuery + '
		where inventory.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else set @remoteQuery = @remoteQuery + '
		where 1 = 1';
	if @KMFCountriesOfOriginCodes is not null and @KMFCountriesOfOriginCodes <> '-999' set  @remoteQuery = @remoteQuery + '
		and ((select n.Value2 from Nomenclature n where n.Gid = fund.CountryGid and n.Type = ''FACountry'') in (''' + [dbo].[StringSplit3](@KMFCountriesOfOriginCodes) + '''))
		and (fund.LevelOfDescriptionGid = 2185 )
		and (inventory.LevelOfDescriptionGid = 2369 )
	';
	if @InventoryNumber is not null set @remoteQuery = @remoteQuery + '
		and (inventory.Number = ''' + @InventoryNumber + ''')
	';
	if @FundNumber is not null set @remoteQuery = @remoteQuery + '
		and (fund.Number = ''' + @FundNumber + ''')
	';
	--if @FundLevelOfDescriptionGids is not null and @FundLevelOfDescriptionGids <> '-999' set @remoteQuery = @remoteQuery + '
		--and (fund.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@FundLevelOfDescriptionGids) + ' )
	--';
	-- въведен е номер на опис, но не е избрано някое от нивата на описание за описи, така имплицитно се разбира, че нивото на описание е някое от нивата за опис(така са го поискали в писмо)
	if @InventoryNumber is not null  
		and not '2171' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2172' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2372' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteQuery = @remoteQuery + '
			and (inventory.LevelOfDescriptionGid in (2171,2172,2372))
	' 
	else if @InventoryNumber is null and @FundNumber is null
		and not '2171' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2172' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2372' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteQuery = @remoteQuery + '
			and 1=2
	' 
	else if @LevelOfDescriptionGids <> '-999'
		and ('2171' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')) 
			or '2172' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
			or '2372' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')))
		set @remoteQuery = @remoteQuery + '
			and (inventory.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )
	';
	-- Грубите описи да са видими само в служебната част на системата
	if @SearchDrafts = 0 set @remoteQuery = @remoteQuery + '
		and (inventory.LevelOfDescriptionGid <> 2172)
	';
	if @ToDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @ToDate +''' >= inventory.CreationDate)
	';
	if @FromDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @FromDate + ''' <= inventory.CreationDate)
	';
	--if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
	--	and ((select FundArrayGid from ' + @fundsView + ' where LGid = inventory.FundLGid) in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	--';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
		and (fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +') 
	';
	set @remoteQuery = @remoteQuery + @rankFilterRemote;

	if @SearchDrafts = 1 set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = fresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131	)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,	
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @fundsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = i.FundSystemIdentifier';
	IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = i.FundSystemIdentifier';

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsI.[KEY] as iId, null as iDId, kwdsI.[RANK] as RankKwds
			from freetexttable(Inventories, *, ''' + @KeyWords + ''') kwdsI
			union 
			select null as iId, kwdsID.[KEY] as iDId, kwdsID.[RANK] as RankKwds  
			from freetexttable(InventoryDrafts, *, ''' + @KeyWords + ''') kwdsID
		) kwds
		on (i.Id = kwds.iDId and i.IsDraft = 1) or (i.Id = kwds.iId and i.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlI.[KEY] as iId, null as iDId, ttlI.[RANK] as RankTitle   
			from freetexttable(Inventories, FundCreatorTitleHistory, ''' + @Title + ''') ttlI 
			union 
			select null as iId, ttlId.[KEY] as iDId, ttlId.[RANK] as RankTitle   
			from freetexttable(InventoryDrafts, FundCreatorTitleHistory, ''' + @Title + ''') ttlId
		) ttl
		on (i.Id = ttl.iDId and i.IsDraft = 1) or (i.Id = ttl.iId and i.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rank = ',RankTitle as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';

	DECLARE @isSuspenedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 1  SET @isSuspenedFilter = '  AND f.IsSuspended = 0 AND i.IsSuspended = 0';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @roughInventoriesFilter VARCHAR(MAX) = '';
	-- Грубите описи да са видими само в служебната част на системата
	IF @SearchDrafts = 0 SET @roughInventoriesFilter = ' AND i.DescriptionLevelCode <> ''6''';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = i.StatusCode) <> 12';

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' left join v_PublicDocuments d on d.InventorySystemIdentifier = i.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' left join v_Documents d on d.InventorySystemIdentifier = i.SystemIdentifier';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';

	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	IF @SearchDrafts = 1 SET @digitalObjectsTable = 'v_DigitalObjects';
	DECLARE @digitalObjectsFilter VARCHAR(MAX) = '';
	IF @SearchDigitalObject = 1 SET @digitalObjectsFilter = ' and (exists(select 1 from ' + @digitalObjectsTable  + ' do 
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0'
			+ @suspended +
		'))';
	IF @SearchDigitalObject = 0 SET @digitalObjectsFilter = ' and (not exists(select 1 from ' + @digitalObjectsTable  + ' do
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0
		))';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Inventories' ELSE SET @table = 'v_PublicInventories';

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';

	DECLARE @inventoryDescriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @InventoryNumber is not null and @FundDescriptionLevelCodesInternal = '-111' set @FundDescriptionLevelCodesInternal = '-999';
	if @InventoryNumber is not null and @InventoryDescriptionLevelCodesInternal = '-111' 
		set @inventoryDescriptionLevelCodesFilter = '' 
	else
		set @inventoryDescriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))) 
				OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))))
		';

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			''inventory'' AS EntityType,
			i.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = i.ArchiveId) as ArchiveName,	
			f.Number as FundNumber,
			i.Number as InventoryNumber,
			NULL as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			NULL as Title,
			NULL as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = i.StatusCode) as StatusText,
			(SELECT Text FROM [N].[FundDescriptionLevel] fdl where fdl.Code = f.DescriptionLevelCode) as FundDescriptionLevelText,
			(SELECT Text FROM [N].[InventoryDescriptionLevel] idl where idl.Code = i.DescriptionLevelCode) as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			f.ApproxmateChronologicalScope as FundApproximateChronologicalScope,
			i.ApproxmateChronologicalScope as InventoryApproximateChronologicalScope,
			NULL as ArchivalEntityApproximateChronologicalScope,
			NULL as FilmSystemIdentifier,
			NULL as FundGid,
			i.FundNumberNumeric AS FundIntNumber,
			i.NumberNumeric AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			2 as EntityTypeOrder
		FROM ' + @table + ' i'
		+ @fundsJoin + 
		+ @documentsJoin +
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE i.ExternalIdentifier IS NULL AND i.HasExternalSource = 0 AND i.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (i.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundDescriptionLevel fdl where fdl.Code = f.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(i.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(i.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @inventoryDescriptionLevelCodesFilter
			+ @doNotGetAnythingFilter
			+ @isSuspenedFilter
			+ @roughInventoriesFilter
			+ @digitalObjectsFilter
			+ @isDeductedFilter
			+ @rankFilter;

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteInventoriesTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи го чупят в такъв случай	
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL,
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NOT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT
		);

		INSERT INTO @remoteInventoriesTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteInventoriesTable
		UNION
		' +
		@localQuery;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[SearchInventoriesForMainSearchComponentInternal]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@FundDescriptionLevelCodes nvarchar(256) = null,
	@InventoryDescriptionLevelCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrays nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @kwds int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1
	if @Title is not null and len(@Title) >= 2 set @ttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @fundsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = i.FundSystemIdentifier';
	IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = i.FundSystemIdentifier';

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsI.[KEY] as iId, null as iDId, kwdsI.[RANK] as RankKwds
			from freetexttable(Inventories, *, ''' + @KeyWords + ''') kwdsI
			union 
			select null as iId, kwdsID.[KEY] as iDId, kwdsID.[RANK] as RankKwds  
			from freetexttable(InventoryDrafts, *, ''' + @KeyWords + ''') kwdsID
		) kwds
		on (i.Id = kwds.iDId and i.IsDraft = 1) or (i.Id = kwds.iId and i.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlI.[KEY] as iId, null as iDId, ttlI.[RANK] as RankTitle   
			from freetexttable(Inventories, FundCreatorTitleHistory, ''' + @Title + ''') ttlI 
			union 
			select null as iId, ttlId.[KEY] as iDId, ttlId.[RANK] as RankTitle   
			from freetexttable(InventoryDrafts, FundCreatorTitleHistory, ''' + @Title + ''') ttlId
		) ttl
		on (i.Id = ttl.iDId and i.IsDraft = 1) or (i.Id = ttl.iId and i.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rank = ',RankTitle as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';

	DECLARE @isSuspenedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 1  SET @isSuspenedFilter = '  AND f.IsSuspended = 0 AND i.IsSuspended = 0';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = i.StatusCode) <> 12';

	DECLARE @roughInventoriesFilter VARCHAR(MAX) = '';
	-- Грубите описи да са видими само в служебната част на системата
	IF @SearchDrafts = 0 SET @roughInventoriesFilter = ' AND i.DescriptionLevelCode <> ''6''';

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' left join v_PublicDocuments d on d.InventorySystemIdentifier = i.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' left join v_Documents d on d.InventorySystemIdentifier = i.SystemIdentifier';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';

	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	IF @SearchDrafts = 1 SET @digitalObjectsTable = 'v_DigitalObjects';
	DECLARE @digitalObjectsFilter VARCHAR(MAX) = '';
	IF @SearchDigitalObject = 1 SET @digitalObjectsFilter = ' and (exists(select 1 from ' + @digitalObjectsTable  + ' do 
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0'
			+ @suspended +
		'))';
	IF @SearchDigitalObject = 0 SET @digitalObjectsFilter = ' and (not exists(select 1 from ' + @digitalObjectsTable  + ' do
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0
		))';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Inventories' ELSE SET @table = 'v_PublicInventories';

	DECLARE @inventoryDescriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @InventoryNumber is not null and @FundDescriptionLevelCodes = '-111' set @FundDescriptionLevelCodes = '-999';
	if @InventoryNumber is not null and @InventoryDescriptionLevelCodes = '-111' 
		set @inventoryDescriptionLevelCodesFilter = '' 
	else
		set @inventoryDescriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodes + ''', '',''))) 
				OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodes + ''', '',''))))
		';

	DECLARE @sql VARCHAR(MAX) = '
		SELECT
			''inventory'' AS EntityType,
			i.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = i.ArchiveId) as ArchiveName,	
			f.Number as FundNumber,
			i.Number as InventoryNumber,
			NULL as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			NULL as Title,
			NULL as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = i.StatusCode) as StatusText,
			(SELECT Text FROM [N].[FundDescriptionLevel] fdl where fdl.Code = f.DescriptionLevelCode) as FundDescriptionLevelText,
			(SELECT Text FROM [N].[InventoryDescriptionLevel] idl where idl.Code = i.DescriptionLevelCode) as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			f.ApproxmateChronologicalScope as FundApproximateChronologicalScope,
			i.ApproxmateChronologicalScope as InventoryApproximateChronologicalScope,
			NULL as ArchivalEntityApproximateChronologicalScope,
			NULL as FilmSystemIdentifier,
			NULL as FundGid,
			i.FundNumberNumeric AS FundIntNumber,
			i.NumberNumeric AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			2 as EntityTypeOrder
		FROM ' + @table + ' i'
		+ @fundsJoin + 
		+ @documentsJoin +
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE i.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (i.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodes + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundDescriptionLevel fdl where fdl.Code = f.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodes + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(i.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(i.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @inventoryDescriptionLevelCodesFilter
			+ @isSuspenedFilter
			+ @roughInventoriesFilter
			+ @digitalObjectsFilter
			+ @isDeductedFilter
			+ @rankFilter;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[SearchKMFForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@KMFNumber nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@ForeignarchivesOnly bit = 0,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@KeyWords nvarchar(MAX) = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	DECLARE @remoteQuery nvarchar(max), @kwds int, @fttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1
		--set @kwdsAnnotated=0;
	--if @KeywordsUIAnnotated is not null and len(@KeywordsUIAnnotated) >=2 set @kwdsAnnotated=1;
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 SET @rankRemote = ',kwds.[Rank] as Rank'; 

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 

	SET @remoteQuery = '';
	SET @remoteQuery = 'with fresults as (';
	set @remoteQuery = @remoteQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''film'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = fund.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		NULL as InventoryNumber,
		NULL as ArchivalEntityNumber,
		fund.Number as KMFNumber,
		NULL as FilmCardNumber,
		fund.Title,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.TypeGid) as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.StatusGid) as StatusText,
		(select Value FROM Nomenclature n WHERE n.Gid= fund.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as FundDescriptionLevelText,
		NULL as InventoryDescriptionLevelText,
		NULL as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) as HasExternalSource,
		fund.LGid as ExternalIdentifier,
		fund.TextDate as FundApproximateChronologicalScope,
		NULL as InventoryApproximateChronologicalScope,
		NULL as ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		Gid AS FundGid,
		NULL as FundIntNumber,
		NULL AS InventoryIntNumber,
		NULL AS ArchivalEntityIntNumber,
		fund.IntNumber AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		fund.Gid,
		fund.LGid'
		+ @rankRemote
		+ ',5 AS EntityTypeOrder';

	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		from Fund_Active as fund
	'
	else set @remoteQuery = @remoteQuery + '
		from Fund_Modified as fund
	';
	if @kwds = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(Fund,*,'''+ @KeyWords + ''') kwds on fund._id = kwds.[key]
	';
	if @ArchiveGids is not null and @ArchiveGids <> '-999'set @remoteQuery = @remoteQuery + '
		where fund.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids) + '
		AND fund.LevelOfDescriptionGid = 2185
	'
	else set @remoteQuery = @remoteQuery + '
		where fund.LevelOfDescriptionGid = 2185
	';
	if @KMFCountriesOfOriginCodes is not null and @KMFCountriesOfOriginCodes <> '-999' set  @remoteQuery = @remoteQuery + '
		and ((select n.Value2 from Nomenclature n where n.Gid = fund.CountryGid and n.Type = ''FACountry'') in (''' + [dbo].[StringSplit3](@KMFCountriesOfOriginCodes) + '''))	
	';
	if @KMFNumber is not null set @remoteQuery = @remoteQuery + '
		and (fund.Number = ''' + @KMFNumber + ''')
	';
	if @KMFNumber is not null and @LevelOfDescriptionGids <> '-999' 
		set @remoteQuery = @remoteQuery + '
			and (fund.LevelOfDescriptionGid = 2185)
			'
	else set @remoteQuery = @remoteQuery + '
		and ((fund.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) +') or -999 in (' + @LevelOfDescriptionGids + '))
	';
	if @ToDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @ToDate +''' >= fund.CreationDate)
	';
	if @FromDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @FromDate + ''' <= fund.CreationDate)
	';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
		and ( fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	';
	set @remoteQuery = @remoteQuery + @rankFilterRemote;

	if @SearchDrafts = 1 set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = fresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131	)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,	
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsF.[KEY] as fId, null as fDId, kwdsF.[RANK] as RankKwds
			from freetexttable(Films, *, ''' + @KeyWords + ''') kwdsF
			union 
			select null as fId, kwdsFD.[KEY] as fDId, kwdsFD.[RANK] as RankKwds  
			from freetexttable(FilmDrafts, *, ''' + @KeyWords + ''') kwdsFD
		) kwds
		on (f.Id = kwds.fDId and f.IsDraft = 1) or (f.Id = kwds.fId and f.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 SET @rank = ',RankKwds as Rank'; 

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 SET @rankFilter = ' and RankKwds > 1'; 

	DECLARE @numberFilter VARCHAR(MAX) = '';
	IF @KMFNumber IS NOT NULL SET @numberFilter = ' AND f.InventoryNumber=''' + @KMFNumber + '''';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Films' ELSE SET @table = 'v_PublicFilms';

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			''film'' AS EntityType,
			f.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = f.ArchiveId) as ArchiveName,
			NULL AS FundNumber,
			NULL AS InventoryNumber,
			NULL AS ArchivalEntityNumber,
			convert(varchar(256), f.InventoryNumber, 104) AS KMFNumber,
			NULL AS FilmCardNumber,
			NULL AS Title,
			NULL as TypeText,
			NULL as StatusText,
			NULL as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			NULL as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as ArchivalEntityApproximateChronologicalScope,
			f.SystemIdentifier as FilmSystemIdentifier,
			NULL as FundGid,
			NULL AS FundIntNumber,
			NULL AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			f.InventoryNumber AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			5 as EntityTypeOrder
		FROM ' + @table + ' f'
		+ @freeTextTableByKwdsJoin + '
		WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @numberFilter + '
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @KMFCountriesOfOriginCodes + ''', '',''))) 
				OR (CountryCode in (select element from dbo.SplitString(''' + @KMFCountriesOfOriginCodes + ''', '',''))))'
			+ @doNotGetAnythingFilter
			+ @rankFilter;


	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NOT NULL,
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL, 
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NOT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT
		);

		INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteTable
		UNION
		' +
		@localQuery;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[SearchKMFForMainSearchComponentInternal]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveCodes nvarchar(10) = null,
	@KMFNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@ForeignarchivesOnly bit = 0,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@KeyWords nvarchar(MAX) = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @kwds int, @fttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1
	
	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsF.[KEY] as fId, null as fDId, kwdsF.[RANK] as RankKwds
			from freetexttable(Films, *, ''' + @KeyWords + ''') kwdsF
			union 
			select null as fId, kwdsFD.[KEY] as fDId, kwdsFD.[RANK] as RankKwds  
			from freetexttable(FilmDrafts, *, ''' + @KeyWords + ''') kwdsFD
		) kwds
		on (f.Id = kwds.fDId and f.IsDraft = 1) or (f.Id = kwds.fId and f.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 SET @rank = ',RankKwds as Rank'; 

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 SET @rankFilter = ' and RankKwds > 1'; 

	DECLARE @numberFilter VARCHAR(MAX) = '';
	IF @KMFNumber IS NOT NULL SET @numberFilter = ' AND f.InventoryNumber=''' + @KMFNumber + '''';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Films' ELSE SET @table = 'v_PublicFilms';

	DECLARE @sql VARCHAR(MAX) = '
		SELECT
			''film'' AS EntityType,
			f.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = f.ArchiveId) as ArchiveName,
			NULL AS FundNumber,
			NULL AS InventoryNumber,
			NULL AS ArchivalEntityNumber,
			convert(varchar(256), f.InventoryNumber, 104) AS KMFNumber,
			NULL AS FilmCardNumber,
			NULL AS Title,
			NULL as TypeText,
			NULL as StatusText,
			NULL as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			NULL as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as ArchivalEntityApproximateChronologicalScope,
			f.SystemIdentifier as FilmSystemIdentifier,
			NULL as FundGid,
			NULL AS FundIntNumber,
			NULL AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			f.InventoryNumber AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			5 as EntityTypeOrder
		FROM ' + @table + ' f'
		+ @freeTextTableByKwdsJoin + '
		WHERE f.Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))'
			+ @numberFilter + '
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @KMFCountriesOfOriginCodes + ''', '',''))) 
				OR (CountryCode in (select element from dbo.SplitString(''' + @KMFCountriesOfOriginCodes + ''', '',''))))'
			+ @rankFilter ;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[sp_CheckIfNewArchivalEntityNumberIsValid]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[sp_CheckIfNewArchivalEntityNumberIsValid] 
	@LinkedServer NVARCHAR(50),
	@Archive INT,
	@InventoryLGid NVARCHAR(50),
	@Number NVARCHAR(50)
AS
BEGIN
	declare @remoteQuery varchar(max) = '
		SELECT 1 AS Ok
		FROM ArchiveEntity_Active
		WHERE (SELECT Code FROM Archive a WHERE a.Gid = ArchiveGid) = ' + CONVERT(NVARCHAR, @Archive) + ' 
			AND InventoryLGid = ' + @InventoryLGid + '
			AND Number=''' + @Number + ''';
	';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @openQuery nvarchar(MAX) = '

		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');
	';
	
	--print @openQuery
	EXEC (@openQuery);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_CheckIfNewFundNumberIsValid]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[sp_CheckIfNewFundNumberIsValid] 
	@LinkedServer NVARCHAR(50),
	@Archive INT,
	@Number NVARCHAR(50),
	@FundArray NVARCHAR(10),
	@DescriptionLevelCode INT
AS
BEGIN
	declare @remoteQuery varchar(max) = '
		SELECT 1 AS Ok
		FROM Fund_Active AS fund
		WHERE (SELECT Code FROM Archive a WHERE a.Gid = ArchiveGid) = ' + CONVERT(NVARCHAR, @Archive) + ' 
			AND Number = ''' + @Number + '''
			AND (SELECT Value FROM Nomenclature n WHERE n.Gid = FundArrayGid AND n.Type = ''FundArray'' AND _retired = ''3000-01-01'') = ''' + @FundArray + ''' 
			AND (SELECT Code FROM Nomenclature n WHERE n.Gid = LevelOfDescriptionGid AND n.Type = ''LevelOfDescription'' AND _retired = ''3000-01-01'') = ' + CONVERT(NVARCHAR, @DescriptionLevelCode) + ';
	';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @openQuery nvarchar(MAX) = '

		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');
	';
	
	--print @openQuery
	EXEC (@openQuery);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_CheckIfNewInventoryNumberIsValid]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[sp_CheckIfNewInventoryNumberIsValid] 
	@LinkedServer NVARCHAR(50),
	@Archive INT,
	@FundLGid NVARCHAR(50),
	@Number NVARCHAR(50),
	@InventoryArray nvarchar(10),
	@DescriptionLevelCode INT
AS
BEGIN
	declare @remoteQuery varchar(max) = '
		SELECT 1 AS Ok
		FROM Inventory_Active AS fund
		WHERE (SELECT Code FROM Archive a WHERE a.Gid = ArchiveGid) = ' + CONVERT(NVARCHAR, @Archive) + ' 
			AND FundLGid = ' + @FundLGid + '
			AND Number = ''' + @Number + '''
			AND (SELECT Value FROM Nomenclature n WHERE n.Gid = InventoryArrayGid AND n.Type = ''InventoryArray'' AND _retired = ''3000-01-01'') = ''' + @InventoryArray + ''' 
			AND (SELECT Code FROM Nomenclature n WHERE n.Gid = LevelOfDescriptionGid AND n.Type = ''LevelOfDescription'' AND _retired = ''3000-01-01'') = ' + CONVERT(NVARCHAR, @DescriptionLevelCode) + ';
	';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @openQuery nvarchar(MAX) = '

		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');
	';
	
	--print @openQuery
	EXEC (@openQuery);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetArchive]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetArchive] 
	@LinkedServer nvarchar(255) = '',
	@Identifier int
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Query nvarchar(MAX)= '
		SELECT TOP 1 
			   -1 as Id
			  ,NULL as CreatedOn
			  ,NULL as CreatedBy
			  ,NULL as UpdatedBy
			  ,NULL as UpdatedOn
			  ,CAST(0 as bit) as Deleted
			  ,NULL as DeletedBy
			  ,NULL as DeletedOn
			  ,CAST(1 as bit) as HasExternalSource
			  ,arc.Gid as ExternalIdentifier
			  ,arc.Code as Code
			  ,arc.Name as Name
			  ,arc.SortOrder as SortOrder
		  FROM [Archiving].[dbo].[Archive] arc
		 WHERE arc._retired = ''''3000-01-01 00:00:00.000''''
		   AND arc.Gid = ' + CAST(@Identifier as nvarchar(255))

	DECLARE @OpenQuery nvarchar(MAX) = 'SELECT * FROM OPENQUERY(' + @LinkedServer + ', ''' + @Query + ''')'

	EXEC (@OpenQuery)
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetArchiveEntitiesByInventory]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetArchiveEntitiesByInventory]
	@LinkedServer nvarchar(255) = '', 
	@InventoryIdentifier uniqueidentifier = NULL,
	@InventoryHasExternalSource bit,
	@InventoryExternalIdentifier int = NULL,
	@SearchText nvarchar(max) = NULL,
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
	FROM [Archiving].[dbo].[ArchiveEntity_Active] ae
	WHERE ae.InventoryLGid = ' + CAST(@InventoryExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
		BEGIN
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  ' AND (ae.Title LIKE ''''%' + @SearchText + '%'''' OR ae.Number LIKE ''''%' + @SearchText + '%'''')'
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
	ORDER BY IntNumber
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetArchiveEntitiesByInventoryCount]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetArchiveEntitiesByInventoryCount]
	@LinkedServer nvarchar(255) = '', 
	@InventoryIdentifier uniqueidentifier = NULL,
	@InventoryHasExternalSource bit,
	@InventoryExternalIdentifier int = NULL,
	@SearchText nvarchar(max) = NULL,
	@IncludeDeleted bit = false
AS
BEGIN
	SET NOCOUNT ON;


	DECLARE @RemoteArchivalEntities TABLE ( ArchivalEntityCount int );
	DECLARE @RemoteArchivalEntitiesCount int = 0;
	DECLARE @LocalArchivalEntitiesCount int = 0;

	DECLARE @RemoteArchivalEntitiesQuery nvarchar(max) = '';
		
	IF @InventoryHasExternalSource = 1
	BEGIN 
		SET @RemoteArchivalEntitiesQuery = CAST('' as nvarchar(max)) +
		'SELECT LGid
		   FROM [Archiving].[dbo].[ArchiveEntity_Active] ae
		  WHERE ae.InventoryLGid = ' + CAST(@InventoryExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery + ' AND Title LIKE ''''%' + @SearchText + '%'''''
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT COUNT(*) as ArchivalEntityCount FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteArchivalEntitiesQuery + ''' )';
		
		PRINT @RemoteQuery
		
		INSERT INTO @RemoteArchivalEntities
		EXEC(@RemoteQuery)

		SELECT TOP 1 @RemoteArchivalEntitiesCount = ArchivalEntityCount from @RemoteArchivalEntities

	END

	IF @InventoryIdentifier IS NOT NULL
	BEGIN
		SELECT @LocalArchivalEntitiesCount = COUNT(ae.Id)
		  FROM [dbo].[v_ArchivalEntities] ae
		 WHERE ae.InventorySystemIdentifier = @InventoryIdentifier 
		   AND ae.HasExternalSource = 0
		   AND (@IncludeDeleted = 1 OR ae.Deleted = 0)
	END

	RETURN @LocalArchivalEntitiesCount + @RemoteArchivalEntitiesCount

	
	
	
	--IF @InventoryExternalIdentifier is NULL SET @InventoryExternalIdentifier=-1;
	--IF @InventoryInternalIdentifier is NULL SET @InventoryInternalIdentifier=-1;

	--declare @searchStringContition varchar(max) = '';
	--IF @SearchString IS NOT NULL SET @searchStringContition=' AND Title LIKE ''%' + @SearchString + '%''';

	--declare @sql varchar(max) = 
	--	'SELECT LGid as ExternalIdentifier, CAST(0 AS BIT) as Deleted
	--	FROM [Archiving].[dbo].ArchiveEntity_Active
	--	WHERE InventoryLGid = ' + CAST(@InventoryExternalIdentifier as varchar(10)) + @searchStringContition + ';';

	--set @sql = REPLACE(@sql, '''', '''''');

	--declare @finalQuery varchar(max) = '';

	--declare @declareRemoteArchiveEntitiesTable varchar(max) =
	--	'DECLARE @remoteArchiveEntitiesTable TABLE (
	--		[ExternalIdentifier] [int] NULL,
	--		[Deleted] BIT NOT NULL
	--	);';
	--declare @declareRemoteArchiveEntitiesTable1 varchar(max) = '';
	--declare @declareRemoteArchiveEntitiesTable2 varchar(max) = '';
	--declare @localServerQuerySelect varchar(max) = '';

	--IF @HasInventoryExternalSource=0 
	--BEGIN
	--	SET @declareRemoteArchiveEntitiesTable1 = @declareRemoteArchiveEntitiesTable;
	--	SET @localServerQuerySelect = 'SELECT COUNT_BIG(*) TotalRows ';
	--END;
	--IF @HasInventoryExternalSource=1 
	--BEGIN
	--	SET @declareRemoteArchiveEntitiesTable2 = @declareRemoteArchiveEntitiesTable;
	--	SET @localServerQuerySelect = 'SELECT ExternalIdentifier, Deleted ';
	--END;

	--declare @includeDeletedCondition varchar(max) = '';
	--IF @IncludeDeleted=0 SET @includeDeletedCondition = ' AND Deleted = 0';

	--declare @localServerQuery varchar(max) = @declareRemoteArchiveEntitiesTable1 + 
	--	@localServerQuerySelect + '
	--	FROM dbo.ArchivalEntities ae
	--	WHERE InventoryId = ' + CAST(@InventoryInternalIdentifier as varchar(10))
	--		+ ' AND not exists(SELECT 1 FROM @remoteArchiveEntitiesTable raet where ae.ExternalIdentifier = raet.ExternalIdentifier)' +  @searchStringContition + @includeDeletedCondition;

	--declare @bothServerQueries varchar(max) = @declareRemoteArchiveEntitiesTable2 + '
	--	INSERT INTO @remoteArchiveEntitiesTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''');

	--	SELECT COUNT_BIG(*) TotalRows FROM
	--		(SELECT * FROM @remoteArchiveEntitiesTable
	--		UNION '
	--			+ @localServerQuery + ') AS c';

	--IF @HasInventoryExternalSource=1
	--BEGIN
	--	SET @finalQuery = @bothServerQueries; 
	--END;
	--IF @HasInventoryExternalSource=0 
	--BEGIN
	--	SET @finalQuery = @localServerQuery;
	--END;

	--EXEC (@finalQuery);	
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetArchiveEntity]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
			,[CopyNegativFrames] as NegativeFrameCount
			,[CopyPositiveFrames] as PositiveFrameCount
			,[CopyOther] as OtherCopyCount
			,[AveilabilityDocumentsCountAssigned] as EnrolledDocumentCount
			,[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters
			,[AveilabilityDocumentsCountDeducted] as DeductedDocumentCount
			,[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
			,Note as Notes
		FROM ArchiveEntity_Active ae
		WHERE 
			LGid = ' + CAST(@Identifier as varchar(10));

	set @sql = REPLACE(@sql, '''', '''''');
	declare @result varchar(max) = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''')';

	exec (@result);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetArchives]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetArchives] 
	@LinkedServer nvarchar(255) = '',
	@SearchText nvarchar(255)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @Query nvarchar(MAX)= '
		SELECT -1 as Id
			  ,NULL as CreatedOn
			  ,NULL as CreatedBy
			  ,NULL as UpdatedBy
			  ,NULL as UpdatedOn
			  ,CAST(0 as bit) as Deleted
			  ,NULL as DeletedBy
			  ,NULL as DeletedOn
			  ,CAST(1 as bit) as HasExternalSource
			  ,arc.Gid as ExternalIdentifier
			  ,arc.Code as Code
			  ,arc.Name as Name
			  ,arc.SortOrder as SortOrder
		  FROM [Archiving].[dbo].[Archive] arc
		 WHERE arc._retired = ''''3000-01-01 00:00:00.000''''
		   AND (arc.Name LIKE ''''%' + @SearchText + '%''''
				OR (ISNUMERIC(''''' + @SearchText + ''''') = 1  AND arc.Code = TRY_CAST(''''' + @SearchText + ''''' as int)))
	'
	DECLARE @OpenQuery nvarchar(MAX) = 'SELECT * FROM OPENQUERY(' + @LinkedServer + ', ''' + @Query + ''')'

	EXEC (@OpenQuery)
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCompilationAndNTOOfEDocumentsCombinedData]  
	@RowsOfPage int = 5000,
	@Page int = 1,
	@FundArraysInternal nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@ProcessStartDate nvarchar(100) = null,
	@ProcessEndDate nvarchar(100) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@StatusesInternal nvarchar(max) = null,
	@ProcessTypes nvarchar(max) = null,
	@FileFormats nvarchar(max) = null,
	@FundLevelOfdescriptionCodes nvarchar(max) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка

	CREATE TABLE #temp (
		[Archive] nvarchar(256),
		[FundNumber] nvarchar(256),
		[Title] nvarchar(MAX),
		[MethodOfAcquisitions] nvarchar(256),
		[Type] nvarchar(256),
		[ChronologicalScope] nvarchar(256),
		[DateOfFiling] nvarchar(256),
		[Status] nvarchar(256),
		[LevelOfDescription] nvarchar(256),
		[InvetoryCount] int,
		[AeCount] int,
		[DocumentCount] int,
		[FileFormats] nvarchar(256),
		[Bytes] bigint,
		[Duration] nvarchar(256),
		[Note] nvarchar(MAX),
		[IntNumber] int null,
		[SortOrder] int null
	);

	INSERT INTO #temp(
		[Archive],
		[FundNumber],
		[Title],
		[MethodOfAcquisitions],
		[Type],
		[ChronologicalScope],
		[DateOfFiling],
		[Status],
		[LevelOfDescription],
		[InvetoryCount],
		[AeCount],
		[DocumentCount],
		[FileFormats],
		[Bytes],
		[Duration],
		[Note],
		[IntNumber],
		[SortOrder]
	)
	EXEC [sp_GetCompilationAndNTOOfEDocumentsReport]
		2147483647,
		1,
		@FundArraysInternal,
		@FundTypesInternal,
		@MethodsOfAcquisitionInternal,
		@RegisteredFrom,
		@RegisteredTo,
		@ProcessStartDate,
		@ProcessEndDate,
		@ArchiveCodesInternal,
		@DateFrom,
		@DateTo,
		@StatusesInternal,
		@ProcessTypes,
		@FileFormats,
		@FundLevelOfdescriptionCodes

	SET @sql = '
		SELECT 
			COUNT(1) as FundsCount,
			isnull(SUM(t.[InvetoryCount]), ''0'') as InventoriesCount,
			isnull(SUM(t.[AeCount]), ''0'') as AesCount,
			isnull(SUM(t.[Bytes]), ''0'') as Bytes,
			--CAST((isnull(
			--			coalesce(
			--				convert(nvarchar, (select SUM(CAST(t.Duration as TIMESTAMP))/3600), 108) + '':'' + convert(nvarchar, (select (SUM(CAST(t.Duration as TIMESTAMP)) % 3600)/60), 108) + '':'' + convert(nvarchar, (select (SUM(CAST(t.Duration as TIMESTAMP)) % 3600) % 60), 108),
			--				convert(nvarchar, (select (SUM(CAST(t.Duration as TIMESTAMP)) % 3600)/60), 108) + '':'' + convert(nvarchar, (select (SUM(CAST(t.Duration as TIMESTAMP)) % 3600) % 60), 108),
			--				convert(nvarchar, (SUM(CAST(t.Duration as TIMESTAMP)))), ''0''), 108)) as nvarchar(256)) as Duration
			isnull(CAST(CAST(DATEADD(ms, SUM(DATEDIFF(ms, ''00:00:00.000'', t.[Duration])), ''00:00:00.000'')as time) as nvarchar(256)), ''0'') as Duration
		FROM #temp as t'

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCompilationAndNTOOfEDocumentsCombinedDataSimple]  
	@LinkedServer nvarchar(50),
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,

	@ProcessStartDate nvarchar(100) = null,
	@ProcessEndDate nvarchar(100) = null,

	@ArchiveCodes nvarchar(10) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ProcessGids nvarchar(max) = null,
	@ProcessTypes nvarchar(max) = null,

	@FileFormats nvarchar(max) = null
AS
BEGIN

	DECLARE @remoteQuery VARCHAR(MAX) = 
		'SELECT
			convert(nvarchar(256), fund.Number) as FundsCount,
			fund.InvetoryCount as InventoriesCount,
			fund.AECount as AesCount,
			NULL as Mb,
			NULL as Duration
		FROM Fund_Modified as fund
		WHERE ((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) 
						OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) 
					OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) 
					OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
					OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
					OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
					OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
					OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) 
					OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessGids + ''', '',''))) 
					OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @ProcessGids + ''', '','')))
					
			    AND ((''' + COALESCE(@ProcessStartDate, 'null') + ''' = ''null'') 
					OR (cast((select Process.CreatedOn from Process where fund.ProcessGid = Process._id) as date) >= cast(''' + COALESCE(@ProcessStartDate, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@ProcessEndDate, 'null') + ''' = ''null'') 
					OR (cast((select Process.ModifiedOn from Process where fund.ProcessGid = Process._id) as date) <= cast(''' + COALESCE(@ProcessEndDate, 'null') + ''' as datetime2)))';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	-- todo: ипзолзвай реалните колони
	DECLARE @localQuery VARCHAR(max) = 
		'SELECT
			funds.Number as FundsCount,
			funds.InventoryCount as InventoriesCount,
			funds.ArchivalEntityCount as AesCount,
			(select SUM(d.Bytes) from Documents as d where d.FundSystemIdentifier = funds.SystemIdentifier) as Mb,
			NULL as Duration
		FROM Funds as funds
		WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
				OR ((select convert(varchar(4), n.Text, 104) from NomenclatureValues as v join N.Nomenclatures as n on n.Id = v.NomenclatureId where v.EntityId = funds.Id and v.EntityType = ''fund'' and v.NomenclatureCode = ''ACQUISITION_METHOD'') in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
				OR ((select convert(varchar(4), Id, 104) from Process as p where p.FundId = funds.Id) in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))))	
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
				OR (cast(funds.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
				OR (cast(funds.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(coalesce(
								convert(varchar, funds.StartDateYear, 104) + ''.'' + convert(varchar, funds.StartDateMonth, 104) + ''.'' + convert(varchar, funds.StartDateDay, 104),
								convert(varchar, funds.StartDateYear, 104) + ''.'' + convert(varchar, funds.StartDateMonth, 104),
								convert(varchar, funds.StartDateYear, 104)) as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(coalesce(
								convert(varchar, funds.EndDateYear, 104) + ''.'' + convert(varchar, funds.EndDateMonth, 104) + ''.'' + convert(varchar, funds.EndDateDay, 104),
								convert(varchar, funds.EndDateYear, 104) + ''.'' + convert(varchar, funds.EndDateMonth, 104),
								convert(varchar, funds.EndDateYear, 104)) as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))

			AND ((''' + COALESCE(@ProcessStartDate, 'null') + ''' = ''null'') 
				OR (cast((select Process.CreatedOn from Process where funds.Id = Process.FundId) as date) >= cast(''' + COALESCE(@ProcessStartDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ProcessEndDate, 'null') + ''' = ''null'') 
				OR (cast((select Process.UpdatedOn from Process where funds.Id = Process.FundId) as date) <= cast(''' + COALESCE(@ProcessEndDate, 'null') + ''' as datetime2)))
				
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FileFormats + ''', '',''))) 
				OR ((select convert(varchar(4), n.Text, 104) from NomenclatureValues as v join N.Nomenclatures as n on n.Id = v.NomenclatureId join Documents as d on n.Id = d.FileFormatCode where d.FundSystemIdentifier = funds.SystemIdentifier) in (select element from dbo.SplitString(''' + @FileFormats + ''', '',''))))';

	declare @sql varchar(max) = '
		DECLARE @remoteTable TABLE ( 
				FundsCount nvarchar(256) NULL,
				InventoriesCount int NULL,
				AesCount int NULL,
				Mb bigint NULL,
				Duration nvarchar(256) NULL
		);

		INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
		SELECT count(u.FundsCount) as FundsCount, sum(u.InventoriesCount) as InventoriesCount, sum(u.AesCount) as AesCount, sum(u.Mb) as Mb, count(u.Duration) as Duration 
		FROM (
			SELECT * 
			FROM (
				SELECT *    
				FROM @remoteTable
				UNION
				' +
				@localQuery + ') lf) u';	

				--print @sql;
	exec (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCompilationAndNTOOfEDocumentsReport]
	@RowsOfPage int = 5000,
	@Page int = 1,
	@FundArraysInternal nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@ProcessStartDate nvarchar(100) = null,
	@ProcessEndDate nvarchar(100) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@StatusesInternal nvarchar(max) = null,
	@ProcessTypes nvarchar(max) = null,
	@FileFormats nvarchar(max) = null,
	@FundLevelOfdescriptionCodes nvarchar(max) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by SortOrder, IntNumber, FundNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
    	
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) =  '
		SELECT
			a.Name as Archive,
			funds.Number as FundNumber,
			funds.Title as Title,
			(select n1.Text from N.Nomenclatures n1 where funds.AcquisitionMethodId = n1.Id) as MethodOfAcquisitions,
			(select t.Text from N.FundType as t where t.Code = funds.TypeCode) as Type,
			CAST(funds.ApproxmateChronologicalScope as nvarchar(256)) as ChronologicalScope,
			funds.CreatedOn as DateOfFiling,
			(select s.Text from N.Status as s where s.Code = funds.StatusCode) as Status,
			(select dl.Text from N.FundDescriptionLevel as dl where dl.Code = funds.DescriptionLevelCode) as LevelOfDescription,
			fsi.EnrolledInventoryCount as InventoryCount,
			fsi.EnrolledArchivalEntityCount as AeCount,
			fsi.EnrolledDocumentCount as DocumentCount,
			fsi.FileTypes as FileFormats,
			fsi.EnrolledBytes as Bytes,
			--CAST((select SUM(CAST(d.Duration as int)) from Documents as d where d.FundSystemIdentifier = funds.SystemIdentifier) as nvarchar(256)) as Duration,
			CAST(dbo.FormatDuration((select sum(d.Duration) from Documents d where funds.SystemIdentifier = d.FundSystemIdentifier)) as nvarchar(256)) as Duration,
			--NULL as Duration,
			funds.Notes as Note,
			funds.NumberNumeric as IntNumber,
			a.SortOrder,
			funds.SystemIdentifier,
			funds.ExternalIdentifier,
			funds.HasExternalSource
		FROM Funds as funds
		LEFT JOIN v_FundSizeInfo as fsi ON funds.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
		INNER JOIN Archives a ON a.Id = funds.ArchiveId AND a.Deleted = 0
		WHERE funds.ExternalIdentifier IS NULL AND funds.HasExternalSource = 0 AND funds.Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR (funds.NumberArray in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
				OR ((select Code from N.Nomenclatures n1 where n1.Id = funds.AcquisitionMethodId) in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '','')) AND TypeCode not in (''4'', ''5'')) 
				OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
				OR (''-998'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
				OR ((select top 1  ProcessTypeId from Process as p where p.FundSystemIdentifier = funds.SystemIdentifier and p.Deleted = 0 and p.Completed = 1 order by p.CreatedOn DESC) in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))))	
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
				OR (cast(funds.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
				OR (cast(funds.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(coalesce(
					convert(varchar, funds.StartDateYear, 104) + ''.'' + convert(varchar, funds.StartDateMonth, 104) + ''.'' + convert(varchar, funds.StartDateDay, 104),
					convert(varchar, funds.StartDateYear, 104) + ''.'' + convert(varchar, funds.StartDateMonth, 104),
					convert(varchar, funds.StartDateYear, 104)) as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(coalesce(
					convert(varchar, funds.EndDateYear, 104) + ''.'' + convert(varchar, funds.EndDateMonth, 104) + ''.'' + convert(varchar, funds.EndDateDay, 104),
					convert(varchar, funds.EndDateYear, 104) + ''.'' + convert(varchar, funds.EndDateMonth, 104),
					convert(varchar, funds.EndDateYear, 104)) as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ProcessStartDate, 'null') + ''' = ''null'') 
				OR (cast((select top(1) Process.CreatedOn from Process where funds.SystemIdentifier = Process.FundSystemIdentifier) as date) >= cast(''' + COALESCE(@ProcessStartDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ProcessEndDate, 'null') + ''' = ''null'') 
				OR (cast((select top(1) Process.UpdatedOn from Process where funds.SystemIdentifier = Process.FundSystemIdentifier) as date) <= cast(''' + COALESCE(@ProcessEndDate, 'null') + ''' as datetime2)))				
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FileFormats + ''', '','')))
				OR (exists((select nv.ValueCode
					from NomenclatureValues nv join N.Nomenclatures n on n.Id = nv.NomenclatureId
					join Funds as f1 on nv.EntityId = f1.Id
					where f1.Id=funds.Id and nv.NomenclatureCode=''FILE_TYPE''
					and n.Deleted=0 and nv.Deleted=0) INTERSECT (select element from dbo.SplitString(''' + @FileFormats + ''', '','')))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundLevelOfdescriptionCodes + ''', '',''))) 
				OR (funds.DescriptionLevelCode in (select element from dbo.SplitString(''' + @FundLevelOfdescriptionCodes + ''', '',''))))	
		';
				
		SET @sql = @localQuery + @sqlFinalPart;
	END

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCompilationAndNTOOfEDocumentsSummary] 
	@RowsOfPage int = 5000,
	@Page int = 1,
	@FundArraysInternal nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@ProcessStartDate nvarchar(100) = null,
	@ProcessEndDate nvarchar(100) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@StatusesInternal nvarchar(max) = null,
	@ProcessTypes nvarchar(max) = null,
	@FileFormats nvarchar(max) = null,
	@FundLevelOfdescriptionCodes nvarchar(max) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @localQuery VARCHAR(max) = '
		SELECT COUNT_BIG(*) TotalRows
		FROM Funds 
		WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR (funds.NumberArray in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
				OR ((select top 1 convert(varchar(4), n.Text, 104) from NomenclatureValues as v join N.Nomenclatures as n on n.Id = v.NomenclatureId where v.EntityId = funds.Id and v.EntityType = ''fund'' and v.NomenclatureCode = ''ACQUISITION_METHOD'') in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '','')) AND TypeCode not in (''4'', ''5'')) 
				OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
				OR ((select top 1 convert(varchar(4), ProcessTypeId, 104) from Process as p where p.FundId = funds.Id) in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))))
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
				OR (cast(funds.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
				OR (cast(funds.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(coalesce(
					convert(varchar, funds.StartDateYear, 104) + ''.'' + convert(varchar, funds.StartDateMonth, 104) + ''.'' + convert(varchar, funds.StartDateDay, 104),
					convert(varchar, funds.StartDateYear, 104) + ''.'' + convert(varchar, funds.StartDateMonth, 104),
					convert(varchar, funds.StartDateYear, 104)) as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(coalesce(
					convert(varchar, funds.EndDateYear, 104) + ''.'' + convert(varchar, funds.EndDateMonth, 104) + ''.'' + convert(varchar, funds.EndDateDay, 104),
					convert(varchar, funds.EndDateYear, 104) + ''.'' + convert(varchar, funds.EndDateMonth, 104),
					convert(varchar, funds.EndDateYear, 104)) as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ProcessStartDate, 'null') + ''' = ''null'') 
				OR (cast((select Process.CreatedOn from Process where funds.Id = Process.FundId) as date) >= cast(''' + COALESCE(@ProcessStartDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ProcessEndDate, 'null') + ''' = ''null'') 
				OR (cast((select Process.UpdatedOn from Process where funds.Id = Process.FundId) as date) <= cast(''' + COALESCE(@ProcessEndDate, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FileFormats + ''', '',''))) 
				OR ((select convert(varchar(4), n.Text, 104) from NomenclatureValues as v join N.Nomenclatures as n on n.Id = v.NomenclatureId join Documents as d on n.Id = d.FileFormatCode where d.FundSystemIdentifier = funds.SystemIdentifier) in (select element from dbo.SplitString(''' + @FileFormats + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundLevelOfdescriptionCodes + ''', '',''))) 
				OR (funds.DescriptionLevelCode in (select element from dbo.SplitString(''' + @FundLevelOfdescriptionCodes + ''', '',''))))		
	';

	SET @sql = @localQuery;
	EXEC (@sql);
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesCombined]
	@LinkedServer nvarchar(50), -- Посочване на външната база
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveCodes nvarchar(10) = null

AS
BEGIN
	SET NOCOUNT ON;

	--DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	--DECLARE @sqlFinalPart VARCHAR(MAX) = '
	--	offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	CREATE TABLE #temp (
				KmfNumber nvarchar(255) NULL,			
				InventoryNumber nvarchar(256) NULL,
				StatementDate varchar(50) NULL,
				Employee nvarchar(255) NULL,
				Reader nvarchar(255) NULL,
				AeCount int NULL,
				ElectronicalDocumentsCount int NULL,
				ElectronicalDocumentsMB bigint NULL
			);

	INSERT INTO #temp(
				KmfNumber,			
				InventoryNumber,
				StatementDate,
				Employee,
				Reader,
				AeCount,
				ElectronicalDocumentsCount,
				ElectronicalDocumentsMB
			)
	EXEC [sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesReport]
	@LinkedServer,
	@ResultType,
	2147483647,
	@Page,
	@ArchiveCodes

	SET @sql = '
		SELECT TOP 1
		''Служител'' as EmployeeRowName,
		(SELECT COUNT(t.Employee) 
		 FROM #temp as t) as EmployeeKMFCount,
        (SELECT SUM(t.AeCount) 
		 FROM #temp as t
		 WHERE t.Employee IS NOT NULL) as EmployeeAECount,
        (SELECT SUM(t.ElectronicalDocumentsCount) 
		 FROM #temp as t
		 WHERE t.Employee IS NOT NULL) as EmployeeElDocsCount,
         (SELECT SUM(t.ElectronicalDocumentsMB) 
		 FROM #temp as t
		 WHERE t.Employee IS NOT NULL) as EmployeeElDocsMB,

		''Читател'' as ReaderRowName,
        (SELECT COUNT(t.Reader) 
		 FROM #temp as t) as ReaderKMFCount,
        (SELECT SUM(t.AeCount) 
		 FROM #temp as t
		 WHERE t.Reader IS NOT NULL) as ReaderAECount,
        (SELECT SUM(t.ElectronicalDocumentsCount) 
		 FROM #temp as t
		 WHERE t.Reader IS NOT NULL) as ReaderElDocsCount,
        (SELECT SUM(t.ElectronicalDocumentsMB) 
		 FROM #temp as t
		 WHERE t.Reader IS NOT NULL) as ReaderElDocsMB,

		''Общо:'' as TotalRowName,
        (SELECT COUNT(t.KmfNumber)
		 FROM #temp as t) as TotalKMFCount,
        (SELECT SUM(t.AeCount)
		 FROM #temp as t) as TotalAECount,
        (SELECT SUM(t.ElectronicalDocumentsCount)
		 FROM #temp as t) as TotalElDocsCount,
        (SELECT SUM(t.ElectronicalDocumentsMB)
		 FROM #temp as t) as TotalElDocsMB
		FROM #temp as t'

		--SET @sql = '
		--SELECT TOP 1
		--''Служител'' as EmployeeRowName,
		--ISNULL(COUNT(t.KmfNumber), 0) as EmployeeKMFCount,
        --NULL as EmployeeAECount,
        --NULL as EmployeeElDocsCount,
        --NULL as EmployeeElDocsMB
		--FROM #temp as t
		--WHERE t.Employee IS NOT NULL
		--SELECT TOP 1
		--''Читател''  as ReaderRowName,
        --NULL as ReaderKMFCount,
        --NULL as ReaderAECount,
        --NULL as ReaderElDocsCount,
        --NULL as ReaderElDocsMB
		--FROM #temp as t
		--WHERE t.Reader IS NOT NULL
		--SELECT TOP 1
		--''Общо:''  as TotalRowName,
        --NULL as TotalKMFCount,
        --NULL as TotalAECount,
        --NULL as TotalElDocsCount,
        --NULL as TotalElDocsMB
		--FROM #temp as t'

		--NULL as RowName
		--NULL as KmfCount,
        --NULL as AeCount,
        --NULL as ElDocsCount,
        --NULL as ElDocsMB
		--FROM #temp'
	--print @sql;
	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesReport]
	@LinkedServer nvarchar(50), -- Посочване на външната база
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveCodes nvarchar(10) = null

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by KmfNumber asc, InventoryNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN

		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT
			--convert(nvarchar(255), (select n.Value2 from Nomenclature as n where n.Gid = fund.CountryGid)) as KmfNumber,
			NULL as KmfNumber,
			NULL as InventoryNumber,
			NULL as StatementDate,
			NULL as Employee,
			NULL as Reader,
			--COUNT((select ae.Gid 
			--		from ArchiveEntity as ae
			--		inner join RequestEntities as re
			--		on re.ArchiveEntityLGid = ae.LGid
			--		inner join Process as p
			--		on re.ProcessGid = p.Gid
			--		where ae.FundLGid = fund.Gid
			--		and p.TypeGid LIKE 101573 
			--		OR p.TypeGid LIKE 101574)) as AeCount,
			NULL as AeCount,
			NULL as ElectronicalDocumentsCount,
			NULL as ElectronicalDocumentsMB
		FROM Fund_Modified as fund'

		--SELECT
		--	NULL as KmfNumber,
		--	NULL as InventoryNumber,
		--	NULL as StatementDate,
		--	NULL as Employee,
		--	NULL as Reader,
		--	NULL as AeCount,
		--	NULL as ElectronicalDocumentsCount,
		--	NULL as ElectronicalDocumentsMB
		--FROM Fund_Modified as fund'

		--DECLARE @remoteQuery VARCHAR(MAX) = '
		--SELECT
		--	convert(nvarchar(255), (select Value from Nomenclature n where n.Gid = fund.CountryGid)) as KmfNumber,
		--	fund.Number as InventoryNumber,
		--	NULL as StatementDate,
		--	NULL as Employee,
		--	NULL as Reader,
		--	NULL as AeCount,
		--	NULL as ElectronicalDocumentsCount,
		--	NULL as ElectronicalDocumentsMB
		--FROM Fund_Modified as fund
		--JOIN ArchiveEntity as ae
		--ON fund.LGid = ae.FundLGid
		--JOIN RequestEntities as re
		--ON ae.LGid = re.ArchiveEntityLGid
		--JOIN Process as p
		--ON re.ProcessGid = p.Gid
		--WHERE p.TypeGid = 101573 OR p.TypeGid = 101574'
		
		--WHERE ISNULL(d.HasDigitalObject, 0) = 1
		--	  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR d.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))'
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT 
			NULL as KmfNumber,
			NULL as InventoryNumber,
			NULL as StatementDate,
			NULL as Employee,
			NULL as Reader,
			NULL as AeCount,
			NULL as ElectronicalDocumentsCount,
			NULL as ElectronicalDocumentsMB
		FROM Films'
		--WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
		--	  AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
		--	  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
		--	  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))';
	END

		IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				KmfNumber nvarchar(255) NULL,			
				InventoryNumber nvarchar(256) NULL,
				StatementDate varchar(50) NULL,
				Employee nvarchar(255) NULL,
				Reader nvarchar(255) NULL,
				AeCount int NULL,
				ElectronicalDocumentsCount int NULL,
				ElectronicalDocumentsMB bigint NULL
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

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesSummary]
	@LinkedServer nvarchar(50), -- Посочване на външната база
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveCodes nvarchar(10) = null

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
    	




	CREATE TABLE #temp (
				KmfNumber nvarchar(255) NULL,			
				InventoryNumber nvarchar(256) NULL,
				StatementDate varchar(50) NULL,
				Employee nvarchar(255) NULL,
				Reader nvarchar(255) NULL,
				AeCount int NULL,
				ElectronicalDocumentsCount int NULL,
				ElectronicalDocumentsMB nvarchar(256) NULL
			);

	INSERT INTO #temp(
				KmfNumber,			
				InventoryNumber,
				StatementDate,
				Employee,
				Reader,
				AeCount,
				ElectronicalDocumentsCount,
				ElectronicalDocumentsMB
			)
	EXEC [sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesReport]
	@LinkedServer,
	@ResultType,
	@RowsOfPage,
	@Page,
	@ArchiveCodes

	SET @sql = '
		SELECT COUNT_BIG(*) as TotalRows
		FROM #temp'

	EXEC (@sql);
END
GO


/****** Object:  StoredProcedure [dbo].[sp_GetDocument]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetDocument] 
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
			,(select CAST(Code as nvarchar(50)) from Nomenclature n where n.Gid = StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusCode
			,(select Value from Nomenclature n where n.Gid = StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusText
			,(select Code from Nomenclature n where n.Gid = AveilabilityGid and n._retired = ''3000-01-01 00:00:00.000'') as AvailabilityStatusCode
			,(select Value from Nomenclature n where n.Gid = AveilabilityGid and n._retired = ''3000-01-01 00:00:00.000'') as AvailabilityStatusText
			,(select a.Code from Archive a where a.Gid = ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveCode
			,(select a.Name from Archive a where a.Gid = ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveName
			,CAST(1 AS BIT) as FundHasExternalSource
			,FundLGid as FundExternalIdentifier
			,(SELECT Number FROM Fund_Active AS fund WHERE fund.LGid = FundLGid) AS FundNumber
			,CAST(1 AS BIT) as InventoryHasExternalSource
			,InventoryLGid as InventoryExternalIdentifier
			,(SELECT Number FROM Inventory_Active AS inventory WHERE inventory.LGid = InventoryLGid) AS InventoryNumber
			,CAST(1 AS BIT) as ArchivalEntityHasExternalSource
			,AELGid as ArchivalEntityExternalIdentifier
			,(SELECT Number FROM ArchiveEntity_Active AS ae WHERE ae.LGid = AELGid) AS ArchivalEntityNumber
            ,Number
			,Title
			,(select CAST(Code as nvarchar(50)) from Nomenclature n where n.Gid= d.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelCode
			,(select Value from Nomenclature n where n.Gid= d.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelText
			,STUFF(
				(select ''; '' + Value 
				   from ObjectNomenclature obj 
				   join Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.DocumentGid = d.Gid and n.Type = ''CreatingType'' for XML PATH('''')), 1, 1, '''') as CreationMethodText
			  ,STUFF(
				(select ''; '' + Value 
				   from ObjectNomenclature obj 
				   join Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.DocumentGid = d.Gid and n.Type = ''Originality'' for XML PATH('''')), 1, 1, '''') as OriginalityText
			  ,STUFF(
				(select ''; '' + Value 
				   from ObjectNomenclature obj 
				   join Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.DocumentGid = d.Gid and n.Type = ''Language'' for XML PATH('''')), 1, 1, '''') as LanguageText
            ,[IsNoDate] as HasNoChronologicalScope
			,[StartDateYear]
			,[StartDateMonth]
			,[StartDateDay]
			,[EndDateYear]
			,[EndDateMonth]
			,[EndDateDay]
			,TextDate as ApproximateChronologicalScope
			,PlaceOfCreation AS Location
			--,[MagnetTapesCount] as TapeCount
			--,[MicrofilmsCount] as MicrofilmCount
			--,[FramesCount] as FrameCount
			--,[VideoTapesCount] as VideoTapeCount
			--,[ElectrCount] as DigitalDeviceCount
			,DimensionInCentimeters as SizeCm
			--,[ExtentOther] as OtherMetrics -- дали е това от ИСДА?
			,[ExtendedContentDescription] as Description
			,[SpecificDetails] as Features
			--,NULL as Condition -- не го намирам
			,[CopyMicrofilm] as MicrofilmedCopyCount
			,[CopyDigital] as DigitizedCopyCount
			,[CopyXerox] as PaperCopyCount
			,[CopyNegativFrames] as NegativeFrameCount
			,[CopyPositiveFrames] as PositiveFrameCount
			,[CopyOther] as OtherCopyCount
			--,NULL as EnrolledBytes
			--,[AveilabilityDocumentsCountAssigned] as EnrolledDocumentCount
			--,[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters
		    --,NULL as DeductedBytes
			--,[AveilabilityDocumentsCountDeducted] as DeductedDocumentCount
			--,[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
			,Note as Notes
		FROM Document_Active d
		WHERE 
			LGid = ' + CAST(@Identifier as varchar(10));
			
	set @sql = REPLACE(@sql, '''', '''''');
	declare @result varchar(max) = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''')';

	exec (@result);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetDocumentAncestorsData]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetDocumentAncestorsData] 
	@LinkedServer nvarchar(50),
	@ArchiveEntityIdentifier int
AS
BEGIN
	SET NOCOUNT ON;
 
	declare @sql varchar(max) = '
		SELECT
			(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' and archive.Gid = ArchiveGid) AS [ArchiveName]
			,ArchiveGid as ArchiveCode
			,FundLGid as FundExternalIdentifier
			,(SELECT Number FROM Fund_Active AS fund WHERE fund.LGid = FundLGid) AS FundNumber
			,InventoryLGid as InventoryExternalIdentifier
			,(SELECT Number FROM Inventory_Active AS inventory WHERE inventory.LGid = InventoryLGid) AS InventoryNumber
			,Number as ArchiveEntityNumber
		FROM ArchiveEntity_Active
		WHERE 
			LGid = ' + CAST(@ArchiveEntityIdentifier as varchar(10));

	set @sql = REPLACE(@sql, '''', '''''');
	declare @result varchar(max) = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''')';

	exec (@result);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetDocumentsByArchiveEntity]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetDocumentsByArchiveEntity] 
	@LinkedServer nvarchar(50),
	@ArchiveEntityIdentifier uniqueidentifier = NULL,
	@ArchiveEntityHasExternalSource bit,
	@ArchiveEntityExternalIdentifier int = NULL,
	@SearchText nvarchar(max) = NULL,
	@IncludeDeleted bit = false,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteDocumentsQuery nvarchar(max) = '';
    DECLARE @RemoteDocuments TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,ArchivalEntityHasExternalSource bit
        ,ArchivalEntityExternalIdentifier int
        ,ArchivalEntityNumber nvarchar(50)
        ,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Author nvarchar(max)
		,Location nvarchar(max)
		,FileTypeText nvarchar(max)
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
	    ,Bytes bigint
	    ,SheetCount int 
	    ,StartSheetNumber int
	    ,EndSheetNumber int 
	    ,DigitalDevice nvarchar(max)
	    ,Scaling nvarchar(256)
	    ,Duration nvarchar(256)
	    ,Transcription nvarchar(max)
	);

	DECLARE @LocalDocuments TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,ArchivalEntityHasExternalSource bit
        ,ArchivalEntityExternalIdentifier int
        ,ArchivalEntityNumber nvarchar(50)
        ,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Author nvarchar(max)
		,Location nvarchar(max)
		,FileTypeText nvarchar(max)
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
	    ,Bytes bigint
	    ,SheetCount int 
	    ,StartSheetNumber int
	    ,EndSheetNumber int 
	    ,DigitalDevice nvarchar(max)
	    ,Scaling nvarchar(256)
	    ,Duration nvarchar(256)
	    ,Transcription nvarchar(max)
	);

	IF @ArchiveEntityHasExternalSource = 1
	BEGIN 

		SET @RemoteDocumentsQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
		,CAST(NULL as uniqueidentifier) as SystemIdentifier
		,CAST(1 as bit) as HasExternalSource
		,d.[LGid] as ExternalIdentifier
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= d.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= d.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
		,CAST(1 as bit) as ArchivalEntityHasExternalSource
		,(select LGid from [Archiving].[dbo].ArchiveEntity_Active ae where ae.LGid = d.AELGid and ae._retired = ''''3000-01-01 00:00:00.000'''') as ArchivalEntityExternalIdentifier
		,(select Number from [Archiving].[dbo].ArchiveEntity_Active ae where ae.LGid = d.AELGid and ae._retired = ''''3000-01-01 00:00:00.000'''') as ArchivalEntityNumber
		,CAST(1 as bit) as InventoryHasExternalSource
		,(select LGid from [Archiving].[dbo].Inventory_Active i where i.LGid = d.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryExternalIdentifier
		,(select Number from [Archiving].[dbo].Inventory_Active i where i.LGid = d.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryNumber
		,CAST(1 as bit) as FundHasExternalSource
		,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = d.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
		,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = d.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
		,(select Code from [Archiving].[dbo].Archive a where a.Gid = d.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
		,(select Name from [Archiving].[dbo].Archive a where a.Gid = d.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
		,d.[Number] as Number
		,d.[Title] as Title
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= d.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= d.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
		,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= d.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= d.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
		,d.[TextDate] as ApproximateChronologicalScope  ' + '
		,d.CopyMicrofilm as MicrofilmedCopyCount
		,d.CopyDigital as DigitizedCopyCount
		,d.CopyXerox as PaperCopyCount
		,d.CopyNegativFrames as NegativeFrameCount
		,d.CopyPositiveFrames as PositiveFrameCount
		,d.CopyOther as OtherCopyCount
		,d.DimensionInCentimeters as SizeCm
		,NULL as OtherMetrics
		,d.Creator as Author
		,d.PlaceOfCreation as Location
		,NULL as FileTypeText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.DocumentGid = d.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.DocumentGid = d.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.DocumentGid = d.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
		,d.[AccessConditions] as DocumentsAccessDescription
		,d.SpecificDetails as Features
		,d.[Note] as Notes
		,d.[ExtendedContentDescription] as Description
		,d.[StartDateYear] as StartDateYear
		,d.[StartDateMonth] as StartDateMonth
		,d.[StartDateDay] as StartDateDay
		,d.[EndDateYear] as EndDateYear
		,d.[EndDateMonth] as EndDateMonth
		,d.[EndDateDay] as EndDateDay
		,d.[IsNoDate] as HasNoChronologicalScope
		,NULL as Bytes
	    ,d.PaperCount as SheetCount
	    ,NULL as StartSheetNumber
	    ,NULL as EndSheetNumber
	    ,NULL as DigitalDevice
	    ,d.Scale as Scaling
	    ,NULL Duration
	    ,d.Transcription as Transcription
	FROM [Archiving].[dbo].[Document_Active] d
	WHERE d.AELGid = ' + CAST(@ArchiveEntityExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
		BEGIN
			SET @RemoteDocumentsQuery = @RemoteDocumentsQuery +  ' AND (d.Title LIKE ''''%' + @SearchText + '%'''' )'
		END;

		PRINT @RemoteDocumentsQuery
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteDocumentsQuery + ''' )';
		
		INSERT INTO @RemoteDocuments 
		EXEC(@RemoteQuery)

		
	END

	IF @ArchiveEntityIdentifier IS NOT NULL
	BEGIN

		INSERT INTO @LocalDocuments
		SELECT	 d.Id
				,d.SystemIdentifier as SystemIdentifier
				,COALESCE(d.HasExternalSource, 0) as HasExternalSource
				,d.ExternalIdentifier
				,d.StatusCode
				,d.StatusText
				,d.ArchivalEntityHasExternalSource
				,d.ArchivalEntityExternalIdentifier
				,d.ArchivalEntityNumber
				,d.InventoryHasExternalSource
				,d.InventoryExternalIdentifier
				,d.InventoryNumber
				,d.FundHasExternalSource
				,d.FundExternalIdentifier
				,d.FundNumber
				,d.ArchiveCode
				,d.ArchiveName
				,d.Number as Number
				,d.Title
				,d.DescriptionLevelCode
				,d.DescriptionLevelText
				,d.AvailabilityStatusCode
				,d.AvailabilityStatusText
				,d.ApproxmateChronologicalScope as ApproximateChronologicalScope
				,d.MicrofilmedCopyCount
				,d.DigitizedCopyCount
				,d.PaperCopyCount
				,d.NegativeFrameCount
				,d.PositiveFrameCount
				,d.OtherCopyCount
				,d.SizeCm
				,d.OtherMetrics
				,d.Author
				,d.Location
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = d.Id and nv.EntityType = 'document' and nv.NomenclatureCode = 'FILE_TYPE' for XML PATH('')), 1, 1, '') as FileTypeText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = d.Id and nv.EntityType = 'document' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = d.Id and nv.EntityType = 'document' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = d.Id and nv.EntityType = 'document' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
				,d.DocumentsAccessDescription
				,d.Features
				,d.Notes
				,d.Description
				,d.StartDateYear
				,d.StartDateMonth
				,d.StartDateDay
				,d.EndDateYear
				,d.EndDateMonth
				,d.EndDateDay
				,d.HasNoChronologicalScope				
				,d.Bytes
				,d.SheetCount
				,d.StartSheetNumber
				,d.EndSheetNumber
				,d.DigitalDevice
				,d.Scaling
				,d.Duration
				,d.Transcription
	     FROM [dbo].[v_Documents] d
	    WHERE d.ArchivalEntitySystemIdentifier = @ArchiveEntityIdentifier 
		  AND (d.HasExternalSource IS NULL OR d.HasExternalSource = 0)
		  AND (@SearchText IS NULL OR d.Title LIKE '%'+ @SearchText +'%')
		  AND (@IncludeDeleted = 1 OR d.Deleted = 0)

	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalDocuments
		  UNION
		 SELECT *
		   FROM @RemoteDocuments
	   ) Documents
	ORDER BY Number
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY




	--declare @offset int = (@Page - 1) * @RowsOfPage;

	--IF @ArchiveEntityExternalIdentifier is NULL SET @ArchiveEntityExternalIdentifier=-1;
	--IF @ArchiveEntityInternalIdentifier is NULL SET @ArchiveEntityInternalIdentifier=-1;

	--declare @searchStringContition varchar(max) = '';
	--IF @SearchString IS NOT NULL SET @searchStringContition=' AND Title LIKE ''%' + @SearchString + '%''';

	--declare @sql varchar(max) = 
	--	'SELECT TOP 1000000 -- top го слагам, за да не дава грешка
	--		NULL as Id,
	--		LGid as ExternalIdentifier,	
	--		Number,
	--		Title,
	--		CAST(1 AS BIT) as HasExternalSource,
	--		CAST(0 AS BIT) as Deleted,
	--		TextDate as ApproximateChronologicalScope,
	--		(SELECT Value FROM [Archiving].[dbo].Nomenclature n WHERE n.Gid=LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as DescriptionLevel
	--	FROM [Archiving].[dbo].Document_Active
	--	WHERE AELGid = ' + CAST(@ArchiveEntityExternalIdentifier as varchar(10)) + @searchStringContition + ';';

	--set @sql = REPLACE(@sql, '''', '''''');

	--declare @finalQuery varchar(max) = '';

	--declare @declareRemoteDocumentsTable varchar(max) =
	--	'DECLARE @remoteDocumentsTable TABLE (
	--		[Id] [int] NULL,
	--		[ExternalIdentifier] [int] NULL,
	--		[Number] [nvarchar](50) NULL,
	--		[Title] [nvarchar](max) NULL,
	--		[HasExternalSource] BIT NOT NULL,
	--		[Deleted] BIT NOT NULL,
	--		[ApproximateChronologicalScope] [nvarchar](256) NULL,
	--		[DescriptionLevel] [nvarchar](max) NULL
	--	);';
	--declare @declareRemoteDocumentsTable1 varchar(max) = '';
	--declare @declareRemoteDocumentsTable2 varchar(max) = '';

	--IF @HasArchiveEntityExternalSource=0 
	--BEGIN
	--	SET @declareRemoteDocumentsTable1 = @declareRemoteDocumentsTable;
	--END;
	--IF @HasArchiveEntityExternalSource=1 
	--BEGIN
	--	SET @declareRemoteDocumentsTable2 = @declareRemoteDocumentsTable;
	--END;

	--declare @includeDeletedCondition varchar(max) = '';
	--IF @IncludeDeleted=0 SET @includeDeletedCondition = ' AND Deleted = 0';


	--declare @localServerQuery varchar(max) = @declareRemoteDocumentsTable1 + '
	--	SELECT TOP 1000000 -- top го слагам, за да не дава грешка
	--		Id,
	--		ExternalIdentifier,	
	--		Number,
	--		Title,
	--		CAST(0 AS BIT) as HasExternalSource,
	--		Deleted,
	--		ApproxmateChronologicalScope as ApproximateChronologicalScope,
	--		(SELECT Text FROM [DAA].[N].[ArchivalEntityDescriptionLevel] n WHERE n.Code=StatusCode) as DescriptionLevel
	--	FROM dbo.Documents d
	--	WHERE ArchivalEntityId = ' + CAST(@ArchiveEntityInternalIdentifier as varchar(10))
	--		+ ' AND not exists(SELECT 1 FROM @remoteDocumentsTable rdt where d.ExternalIdentifier = rdt.ExternalIdentifier)' +  @searchStringContition + @includeDeletedCondition + ' 
	--	ORDER BY Number';

	--declare @bothServersQuery varchar(max) = @declareRemoteDocumentsTable2 + '
	--	INSERT INTO @remoteDocumentsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''');

	--	SELECT 
	--		Id,
	--		ExternalIdentifier,
	--		Number,
	--		Title,
	--		HasExternalSource,
	--		Deleted,
	--		ApproximateChronologicalScope,
	--		DescriptionLevel
	--	FROM
	--		(SELECT * FROM @remoteDocumentsTable
	--		UNION '
	--			+ @localServerQuery + ') results ' +
	--	'ORDER BY Number ASC 
	--	OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY';

	--IF @HasArchiveEntityExternalSource=1
	--BEGIN
	--	SET @finalQuery = @bothServersQuery; 
	--END;
	--IF @HasArchiveEntityExternalSource=0 
	--BEGIN
	--	SET @finalQuery = @localServerQuery;
	--END;

	--EXEC (@finalQuery);	
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetDocumentsByArchiveEntityCount]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetDocumentsByArchiveEntityCount]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_GetFilmCards]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[sp_GetFilmCards] 
	@LinkedServer nvarchar(50),
	@PageSize int = 10,
	@PageNumber int = 1,
	@FundGid int = 0,
	@ArchiveEntityGid int = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteFilmCardsQuery nvarchar(max) = '';
    DECLARE @RemoteFilmCards TABLE 
	(
		Id int
		, HasExternalSource bit		
		, ExternalIdentifier int
		, FilmExternalIdentifier int
		, InventoryNumber nvarchar(50)
		, CountryName nvarchar(255)
		, CountryCode nvarchar(255)
		, Title nvarchar(max)
		, City nvarchar(256)
		, DocumentsCypher nvarchar(2000)
		, ArchiveOriginals nvarchar(2000)
		, StartDateDay int
		, StartDateMonth int
		, StartDateYear int
		, EndDateDay int
		, EndDateMonth int
		, EndDateYear int
		, AproximateDate nvarchar(256)
		, FilmingExtentName nvarchar(max)
		, FramesCount int
		, MicrofilmNegativeCount int
		, MicrofilmPositiveCount int
		, PhotoCopy int
		, DigitalCopy int
		, Other nvarchar(256)
		, Notes nvarchar(max)
		, DocumentsFormat nvarchar(2000)
		, DocumentsCharacteristics nvarchar(max)
		, ArchiveCode int
		, ArchiveName nvarchar(255)
		, Source nvarchar(256)
		, Languages nvarchar(max)
	);
	

		SET @RemoteFilmCardsQuery = CAST('' as nvarchar(max)) +
		'SELECT
			-1 as Id
			, CAST(1 as bit) as HasExternalSource
			, ae.LGid as ExternalIdentifier
			, ae.FundLGid as FilmExternalIdentifier
			, ae.Number AS InventoryNumber
			, (
				SELECT Value3
				FROM  Nomenclature n
				WHERE n.Gid = (SELECT CountryGid FROM Fund_Modified f WHERE f.LGid = ae.FundLGid)
					AND n._retired = ''3000-01-01'' AND n.Type=''FACountry''
			) AS CountryName
			, (
				SELECT Value2
				FROM  Nomenclature n
				WHERE n.Gid = (SELECT CountryGid FROM Fund_Modified f WHERE f.LGid = ae.FundLGid)
					AND n._retired=''3000-01-01'' AND n.Type=''FACountry''
			) AS CountryCode
			, ae.Title
			, ae.City
			, ae.ChyperOfDocuments AS DocumentsCypher
			, ae.ArchiveOriginal AS ArchiveOriginals
			, ae.StartDateDay
			, ae.StartDateMonth
			, ae.StartDateYear
			, ae.EndDateDay
			, ae.EndDateMonth
			, ae.EndDateYear
			, ae.TextDate AS AproximateDate
			, (SELECT Value FROM Nomenclature n WHERE n._retired = ''3000-01-01'' AND n.Type=''FALevelOfCapture'' AND ae.LevelOfCaptureGid = n.Gid) AS FilmingExtentName
			, ae.FramesCount
			, ae.CopyNegativFrames AS MicrofilmNegativeCount
			, ae.CopyPositiveFrames AS MicrofilmPositiveCount
			, ae.CopyXerox AS PhotoCopy
			, ae.CopyDigital AS DigitalCopy
			, ae.CopyOther AS Other
			, ae.Note AS Notes
			, ae.Format AS DocumentsFormat
			, ae.DocumentProperties AS DocumentsCharacteristics
			, (select Code from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveCode
			, (select Name from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveName
			, (select CreationAuthor from [Archiving].[dbo].Fund_Modified a where a.LGid = ae.FundLGid and a._retired = ''3000-01-01 00:00:00.000'') as Source
			,(
				SELECT STRING_AGG(Value, ''; '') 
				FROM Nomenclature n
				INNER JOIN ObjectNomenclature on1 on n.Gid = on1.NomenclatureGid
				WHERE n._retired = ''3000-01-01'' 
					AND on1._retired = ''3000-01-01''
					AND on1.ArchiveEntityGid = ae.LGid 
					AND n.Type = ''FALanguage''
			) AS Languages

		FROM ArchiveEntity_Modified AS ae'

		if IsNull(@ArchiveEntityGid, 0) > 0
		begin 
			set @RemoteFilmCardsQuery = @RemoteFilmCardsQuery + '
			WHERE ae.LGid = ' + CAST(@ArchiveEntityGid as nvarchar(50));			
		end
		else 
		begin 
			set @RemoteFilmCardsQuery = @RemoteFilmCardsQuery + '
			WHERE FundLGid = ' + CAST(@FundGid as nvarchar(50));
		end



		SET @RemoteFilmCardsQuery = REPLACE(@RemoteFilmCardsQuery, '''', '''''');

		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteFilmCardsQuery + ''' )';
		
		INSERT INTO @RemoteFilmCards 
		EXEC(@RemoteQuery)

			
	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @RemoteFilmCards
	   ) inventories
	ORDER BY ExternalIdentifier
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
	
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetFilmCardsCount]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetFilmCardsCount] 
	@LinkedServer nvarchar(50),
	@FundExternalIdentifier int = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @RemoteFilmCards TABLE ( FilmCardsCount int );
	DECLARE @RemoteFilmCardsCount int = 0;
	DECLARE @sql VARCHAR(MAX);

	DECLARE @remoteFilmCardsQuery VARCHAR(MAX) = '
		SELECT
			-1 as Id
			, CAST(1 as bit) as HasExternalSource
			, ae.LGid as ExternalIdentifier
			, ae.FundLGid as FilmExternalIdentifier

		FROM ArchiveEntity_Modified AS ae
		WHERE FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50));

	SET @remoteFilmCardsQuery = REPLACE(@remoteFilmCardsQuery, '''', '''''');
	
	SET @sql = 'SELECT COUNT(*) as FilmCardsCount FROM OPENQUERY(' + @LinkedServer + ', ''' + @remoteFilmCardsQuery + ''');';
			
	INSERT INTO @RemoteFilmCards
	EXEC(@sql)

	SELECT TOP 1 @RemoteFilmCardsCount = FilmCardsCount from @RemoteFilmCards

	RETURN @RemoteFilmCardsCount
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetFilms]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetFilms] 
	@LinkedServer nvarchar(50),
	@PageSize int = 10,
	@PageNumber int = 1,
	@FundGid int = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteFilmsQuery nvarchar(max) = '';
    DECLARE @RemoteFilms TABLE 
	(
		Id int
		, HasExternalSource bit		
		, ExternalIdentifier int
		, ArchiveCode int
		, ArchiveName nvarchar(255)
		, InventoryNumber nvarchar(256)
		, Notes nvarchar(max)
		, Source nvarchar(256)
		, CountryCode nvarchar(255)
		, CountryName nvarchar(max)
		, MicrofilmNegativeFramesCount int
		, MicrofilmPositiveFramesCount int
		, PhotoCopy int
		, DigitalCopy int
		, Other nvarchar(256)
		, Content nvarchar(max)
		, FramesCount int
		, AcceptedOnDay int
		, AcceptedOnMonth int
		, AcceptedOnYear int
		, MicrofilmNegativeRollsCount int
		, MicrofilmPositiveRollsCount int
	);
	
	/*
	SELECT 
			   -1 as Id
			  ,CAST(1 as bit) as HasExternalSource
			  ,fund.[LGid] as ExternalIdentifier
			  ,(select Code from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = '3000-01-01 00:00:00.000') as ArchiveCode
			  ,(select Name from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = '3000-01-01 00:00:00.000') as ArchiveName
			  ,fund.[Number] as InventoryNumber
			  ,fund.[Note] as Notes
			  ,fund.[CreationAuthor] as Source
			  			  ,(
					SELECT Value2
					FROM  Nomenclature n
					WHERE n.Gid = fund.CountryGid
						AND n._retired=''3000-01-01'' AND n.Type=''FACountry''
				) AS CountryCode
			  ,(
					SELECT Value3
					FROM  Nomenclature n
					WHERE n.Gid = fund.CountryGid
						AND n._retired = ''3000-01-01'' AND n.Type=''FACountry''
			   ) AS CountryName
			  ,fund.[CopyNegativeFrames] as MicrofilmNegativeFramesCount
			  ,fund.[CopyPositiveFrames] as MicrofilmPositiveFramesCount
			  ,fund.[CopyXerox] as PhotoCopy
			  ,fund.[CopyDigital] as DigitalCopy
			  ,fund.[CopyOther] as Other
			  ,fund.[InventoryShortDescroption] as Content
			  ,fund.[FramesCount]
			  ,fund.[FARevicedOnDay] as AcceptedOnDay
			  ,fund.[FARevicedOnMonth] as AcceptedOnMonth
			  ,fund.[FARecivedOnYear] as AcceptedOnYear
			  ,fund.[CopyNegativeRolls] as MicrofilmNegativeRollsCount
			  ,fund.[CopyPositiveRolls] as MicrofilmPositiveRollsCount
		 FROM [Archiving].[dbo].Fund_Modified as fund
		 JOIN [Archiving].[dbo].Nomenclature nom on nom.Gid = fund.LevelOfDescriptionGid
		 WHERE nom.Code = 9 /*КМФ*/
		 and fund.LGId = 10000536
	*/

		SET @RemoteFilmsQuery = CAST('' as nvarchar(max)) + '		
		SELECT 
			   -1 as Id
			  ,CAST(1 as bit) as HasExternalSource
			  ,fund.[LGid] as ExternalIdentifier
			  ,(select Code from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveCode
			  ,(select Name from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveName
			  ,fund.[Number] as InventoryNumber
			  ,fund.[Note] as Notes
			  ,fund.[CreationAuthor] as Source
			  ,(
					SELECT Value2
					FROM  Nomenclature n
					WHERE n.Gid = fund.CountryGid
						AND n._retired=''3000-01-01'' AND n.Type=''FACountry''
				) AS CountryCode
			  ,(
					SELECT Value3
					FROM  Nomenclature n
					WHERE n.Gid = fund.CountryGid
						AND n._retired = ''3000-01-01'' AND n.Type=''FACountry''
			   ) AS CountryName
			  ,fund.[CopyNegativeFrames] as MicrofilmNegativeFramesCount
			  ,fund.[CopyPositiveFrames] as MicrofilmPositiveFramesCount
			  ,fund.[CopyXerox] as PhotoCopy
			  ,fund.[CopyDigital] as DigitalCopy
			  ,fund.[CopyOther] as Other
			  ,fund.[InventoryShortDescroption] as Content
			  ,fund.[FramesCount]
			  ,fund.[FARevicedOnDay] as AcceptedOnDay
			  ,fund.[FARevicedOnMonth] as AcceptedOnMonth
			  ,fund.[FARecivedOnYear] as AcceptedOnYear
			  ,fund.[CopyNegativeRolls] as MicrofilmNegativeRollsCount
			  ,fund.[CopyPositiveRolls] as MicrofilmPositiveRollsCount
		 FROM [Archiving].[dbo].Fund_Modified as fund
		 JOIN [Archiving].[dbo].Nomenclature nom on nom.Gid = fund.LevelOfDescriptionGid
		 WHERE nom.Code = 9 /*КМФ*/'

		if IsNull(@FundGid, 0) > 0
		begin 
			set @RemoteFilmsQuery = @RemoteFilmsQuery + '
			AND fund.LGId = ' + CAST(@FundGid as nvarchar(50));
		end

		SET @RemoteFilmsQuery = REPLACE(@RemoteFilmsQuery, '''', '''''');

		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteFilmsQuery + ''' )';
		
		INSERT INTO @RemoteFilms 
		EXEC(@RemoteQuery)

			
	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @RemoteFilms
	   ) films
	ORDER BY ExternalIdentifier
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
	
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetFilmsCount]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetFilmsCount] 
	@LinkedServer nvarchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @RemoteFilms TABLE ( FilmsCount int );
	DECLARE @RemoteFilmsCount int = 0;
	DECLARE @sql VARCHAR(MAX);

	DECLARE @remoteFilmsQuery VARCHAR(MAX) = '
		SELECT 
			   -1 as Id
			  ,CAST(1 as bit) as HasExternalSource
			  ,fund.[LGid] as ExternalIdentifier
		 FROM [Archiving].[dbo].Fund_Modified as fund
		 JOIN [Archiving].[dbo].Nomenclature nom on nom.Gid = fund.LevelOfDescriptionGid
		 WHERE nom.Code = 9 /*КМФ*/';

	SET @remoteFilmsQuery = REPLACE(@remoteFilmsQuery, '''', '''''');
	
	SET @sql = 'SELECT COUNT(*) as FilmsCount FROM OPENQUERY(' + @LinkedServer + ', ''' + @remoteFilmsQuery + ''');';
			
	INSERT INTO @RemoteFilms
	EXEC(@sql)

	SELECT TOP 1 @RemoteFilmsCount = FilmsCount from @RemoteFilms

	RETURN @RemoteFilmsCount
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetFund]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetFund] 
	@LinkedServer nvarchar(50),
	@Identifier int
AS
BEGIN
	SET NOCOUNT ON;

--	SELECT 
--	   -1 as Id
--	  ,CAST(1 as bit) as HasExternalSource
--	  --,fund.[Gid]
--	  ,fund.[LGid] as ExternalIdentifier
--      ,(select Name from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = '3000-01-01 00:00:00.000') as ArchiveName
--      --,fund.[StatusGid]
--	  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid=fund.StatusGid and n._retired = '3000-01-01 00:00:00.000') as StatusText
--      --,fund.[RowStatusGid]
--      --,fund.[ProcessGid]
--      ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid=fund.FundArrayGid and n._retired = '3000-01-01 00:00:00.000') as NumberArray
--      ,fund.[Number] as Number
--      --,fund.[LevelOfDescriptionGid]
--	  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid=fund.LevelOfDescriptionGid and n._retired = '3000-01-01 00:00:00.000') as DescriptionLevelText
--      ,fund.[Title] as Title
--      --,fund.[TypeGid]
--	  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid = fund.TypeGid and n._retired = '3000-01-01 00:00:00.000') as TypeText
--	  ,STUFF(
--		(select '; ' + Value 
--		   from [Archiving].[dbo].ObjectNomenclature obj 
--		   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
--		  where obj.FundGid = fund.Gid and n.Type = 'MethodOfAcquisition' for XML PATH('')), 1, 1, '') as AcquisitionMethodText
--	  ,STUFF(
--		(select '; ' + Value 
--		   from [Archiving].[dbo].ObjectNomenclature obj 
--		   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
--		  where obj.FundGid = fund.Gid and n.Type = 'IndustryIndex' for XML PATH('')), 1, 1, '') as IndustryTypeText
--	  ,STUFF(
--		(select '; ' + Value 
--		   from [Archiving].[dbo].ObjectNomenclature obj 
--		   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
--		  where obj.FundGid = fund.Gid and n.Type = 'Language' for XML PATH('')), 1, 1, '') as LanguageText
--      --,fund.[StartDate]
--      --,fund.[EndDate]
--      ,fund.[TextDate] as ApproxmateChronologicalScope
--      ,fund.[LinearMeters] as LinearMeters
--      ,fund.[InvetoryCount] as InventoryCount
--      ,fund.[AECount] as ArchivalEntityCount
--      --,[BoxesCount]
--      --,[RuloniTubusiCount]
--      ,fund.[ExtentOther] as OtherMetrics
--      ,fund.[FundFormerFunction] as FundCreatorActivityHistory
--      ,fund.[FundFormerHistory] as FundCreatorBiographicalHistory
--      ,fund.[ArchivalHistory] as History
--      ,fund.[ImmediateSourceOfAcquisition] as DocumentsProvider
--      ,fund.[AccessConditions] as DocumentsAccessDescription
--      --,fund.[OriginalityOther]
--      --,fund.[CreatingTypeOther]
--      --,fund.[LanguageOther]
--      --,fund.[AveilabilityGid]
--      --,fund.[AveilabilityLinearMetersAssigned]
--      ,fund.[AveilabilityInventoryCountAssigned] as EnrolledInventoryCount
--      --,fund.[AveilabilityLinearMetersDeducted]
--      ,fund.[AveilabilityInventoryCountDeducted] as DeductedInventoryCount
--      --,fund.[FindingAids]
--      ,fund.[RelatedUnits] as RelatedFunds
--      ,fund.[Note] as Notes
--      --,fund.[RulesGid]
--      --,fund.[RulesOther]
--      ,fund.[DocumentProperties] as DocumentsDescription
--      --,fund.[CreationDate]
--      --,fund.[CreationAuthor]
--      --,fund.[ModificationDate]
--      --,fund.[ModificationAuthor]
--      --,fund.[ValidationFlag]
--      --,fund.[IsSavedOnceLOD]
--      --,fund.[IsSavedOnceArray]
--      --,fund.[ModifiedByProcessGid]
--      --,fund.[CountryGid]
--      --,fund.[City]
--      --,fund.[ArchiveOriginal]
--      --,fund.[ChyperOfDocuments]
--      --,fund.[CopyNegativeFrames]
--      --,fund.[CopyPositiveFrames]
--      --,fund.[CopyXerox]
--      --,fund.[CopyDigital]
--      --,fund.[CopyOther]
--      --,fund.[LevelOfCaptureGid]
--      --,fund.[HasInventory]
--      --,fund.[InventoryNote]
--      --,fund.[InventoryShortDescroption]
--      --,fund.[InsNegativeCount]
--      --,fund.[InsNegativePlaceGid]
--      --,fund.[InsPositiveCount]
--      --,fund.[InsPositivePlaceGid]
--      --,fund.[InsFotolabTransferDate]
--      --,fund.[InsFotolabTransferredBy]
--      --,fund.[InsFotolabAcceptedBy]
--      --,fund.[InsNote]
--      --,fund.[FundSourceLGid]
--      --,fund.[FundSourceNumber]
--      ,fund.[FundFormerNameChange] as FundCreatorTitleHistory
--      --,fund.[FundSourceArchiveName]
--      --,fund.[FundDestinationLGid]
--      --,fund.[FundDestinationNumber]
--      --,fund.[FundDestinationArchiveName]
--      --,fund.[FramesCount]
--      --,fund.[Format]
--      --,fund.[InsFotolabDeliveryDate]
--      ,fund.[StartDateYear] as StartDateYear
--      ,fund.[StartDateMonth] as StartDateMonth
--      ,fund.[StartDateDay] as StartDateDay
--      ,fund.[EndDateYear] as EndDateYear
--      ,fund.[EndDateMonth] as EndDateMonth
--      ,fund.[EndDateDay] as EndDateDay
--      ,fund.[IsNoDate] as HasNoChronologicalScope
--      --,fund.[FARevicedOnDay]
--      --,fund.[FARevicedOnMonth]
--      --,fund.[FARecivedOnYear]
--      --,fund.[FARecivedOn]
--      --,fund.[ChyperOfDocumentsWithIndex]
--      --,fund.[CopyNegativeRolls]
--      --,fund.[CopyPositiveRolls]
--      --,fund.[TFTimeStamp]
--      --,fund.[IntNumber]
-- FROM [Archiving].[dbo].Fund_Active as fund
--WHERE fund.LGId = 25124 





	declare @sql varchar(max) = '
		SELECT 
			   -1 as Id
			  ,CAST(1 as bit) as HasExternalSource
			  ,fund.[LGid] as ExternalIdentifier
			  ,(select Code from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveCode
			  ,(select Name from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveName
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid=fund.StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusText
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid=fund.FundArrayGid and n._retired = ''3000-01-01 00:00:00.000'') as NumberArray
			  ,fund.[Number] as Number
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid=fund.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelText
			  ,fund.[Title] as Title
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid = fund.TypeGid and n._retired = ''3000-01-01 00:00:00.000'') as TypeText
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.FundGid = fund.Gid and n.Type = ''MethodOfAcquisition'' for XML PATH('''')), 1, 1, '''') as AcquisitionMethodText
			  ,STUFF(
				(select ''; '' + Value2 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.FundGid = fund.Gid and n.Type = ''IndustryIndex'' for XML PATH('''')), 1, 1, '''') as IndustryTypeText
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.FundGid = fund.Gid and n.Type = ''Language'' for XML PATH('''')), 1, 1, '''') as LanguageText
			  ,fund.[TextDate] as ApproxmateChronologicalScope
			  ,fund.[LinearMeters] as LinearMeters
			  ,fund.[InvetoryCount] as InventoryCount
			  ,fund.[AECount] as ArchivalEntityCount
			  ,fund.[ExtentOther] as OtherMetrics
			  ,fund.[FundFormerFunction] as FundCreatorActivityHistory
			  ,fund.[FundFormerHistory] as FundCreatorBiographicalHistory
			  ,fund.[ArchivalHistory] as History
			  ,fund.[ImmediateSourceOfAcquisition] as DocumentsProvider
			  ,fund.[AccessConditions] as DocumentsAccessDescription
			  ,fund.[AveilabilityInventoryCountAssigned] as EnrolledInventoryCount
			  ,fund.[AveilabilityInventoryCountDeducted] as DeductedInventoryCount
			  ,fund.[RelatedUnits] as RelatedFunds
			  ,fund.[Note] as Notes
			  ,fund.[DocumentProperties] as DocumentsDescription
			  ,fund.[FundFormerNameChange] as FundCreatorTitleHistory
			  ,fund.[StartDateYear] as StartDateYear
			  ,fund.[StartDateMonth] as StartDateMonth
			  ,fund.[StartDateDay] as StartDateDay
			  ,fund.[EndDateYear] as EndDateYear
			  ,fund.[EndDateMonth] as EndDateMonth
			  ,fund.[EndDateDay] as EndDateDay
			  ,fund.[IsNoDate] as HasNoChronologicalScope
		 FROM [Archiving].[dbo].Fund_Active as fund
		WHERE fund.LGId = ' + CAST(@Identifier as nvarchar(50)) 



	set @sql = REPLACE(@sql, '''', '''''');
	declare @linkedServerQuery varchar(max) = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''');';
	EXEC (@linkedServerQuery);	
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetFundInventories]
	@LinkedServer nvarchar(255) = '', 
	@FundIdentifier uniqueidentifier = NULL,
	@FundHasExternalSource bit,
	@FundExternalIdentifier int = NULL,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @RemoteInventoriesQuery nvarchar(max) = '';
    DECLARE @RemoteInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(256)
		,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,NumberNumeric int
		,Number nvarchar(50)
		,ApproxmateChronologicalScope nvarchar(max)
		,LinearMeters float
		,ArchivalEntityCount int
		,BoxCount int 
		,RollCount int
		,AudioDocumentArchivalEntityCount int
		,PhotoDocumentArchivalEntityCount int 
		,VideoDocumentArchivalEntityCount int
		,DigitalDocumentArchivalEntityCount int
		,OtherMetrics nvarchar(256)
		,FundCreatorTitleHistory nvarchar(max)
		,FundCreatorBiographicalHistory nvarchar(max)
		,History nvarchar(max)
		,DocumentsProvider nvarchar(max)
		,AcquisitionMethodText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,ClassificationScheme nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,AbbreviationList nvarchar(max)
		,MicrofilmedArchivalEntityCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,DigitizedArchivalEntityCount int
		,Notes nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(256)
		,DocumentsDescription nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
	);

	DECLARE @LocalInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(256)
		,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,NumberNumeric int
		,Number nvarchar(50)
		,ApproxmateChronologicalScope nvarchar(max)
		,LinearMeters float
		,ArchivalEntityCount int
		,BoxCount int 
		,RollCount int
		,AudioDocumentArchivalEntityCount int
		,PhotoDocumentArchivalEntityCount int 
		,VideoDocumentArchivalEntityCount int
		,DigitalDocumentArchivalEntityCount int
		,OtherMetrics nvarchar(256)
		,FundCreatorTitleHistory nvarchar(max)
		,FundCreatorBiographicalHistory nvarchar(max)
		,History nvarchar(max)
		,DocumentsProvider nvarchar(max)
		,AcquisitionMethodText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,ClassificationScheme nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,AbbreviationList nvarchar(max)
		,MicrofilmedArchivalEntityCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,DigitizedArchivalEntityCount int
		,Notes nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(256)
		,DocumentsDescription nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
	);

	IF @FundHasExternalSource = 1
	BEGIN 
		SET @RemoteInventoriesQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
			  ,CAST(NULL as uniqueidentifier) as SystemIdentifier
			  ,CAST(1 as bit) as HasExternalSource
			  ,inventory.[LGid] as ExternalIdentifier
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
			  ,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
			  ,CAST(1 as bit) as FundHasExternalSource
			  ,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
			  ,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
			  ,(select Code from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
			  ,(select Name from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
			  ,(select Value from [Archiving].[dbo].Nomenclature n where n.Gid = inventory.InventoryArrayGid and n._retired = ''''3000-01-01 00:00:00.000'''') as NumberArray
			  ,inventory.[IntNumber] as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.[TextDate] as ApproxmateChronologicalScope
			  ,inventory.[LinearMeter] as LinearMeters
			  ,inventory.[AECount] as ArchivalEntityCount ' + '
			  ,inventory.[BoxesCount] as BoxCount
			  ,inventory.[RuloniTubusiCount] as RollCount
			  ,inventory.[AEFonoDocsCount] as AudioDocumentArchivalEntityCount
			  ,inventory.[AEPhotoDocsCount] as PhotoDocumentArchivalEntityCount
			  ,inventory.[AEVideoAudioDocsCount] as VideoDocumentArchivalEntityCount
			  ,inventory.[AEElectrDocsCount] as DigitalDocumentArchivalEntityCount
			  ,inventory.[ExtentOther] as OtherMetrics
			  ,inventory.[FundCreatorNameChanges] as FundCreatorTitleHistory
			  ,inventory.[FundFormerHistory] as FundCreatorBiographicalHistory
			  ,inventory.[ArchivalHistory] as History
			  ,inventory.[ImmediateSourceOfAcquisition] as DocumentsProvider ' + '
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''MethodOfAcquisition'''' for XML PATH('''''''')), 1, 1, '''''''') as AcquisitionMethodText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
			  ,inventory.[ClassificationScheme] as ClassificationScheme
			  ,inventory.[AccessConditions] as DocumentsAccessDescription
			  ,inventory.[Abbreviations] as AbbreviationList
			  ,inventory.[CopyMicrofilmAE] as MicrofilmedArchivalEntityCount ' + '
			  ,inventory.[CopyNegativFrames] as NegativeFrameCount
			  ,inventory.[CopyPositiveFrames] as PositiveFrameCount
			  ,inventory.[CopyDigitizedAE] as DigitizedArchivalEntityCount
			  ,inventory.[Note] as Notes
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
			  ,inventory.[DocumentProperties] as DocumentsDescription
			  ,inventory.[StartDateYear] as StartDateYear
			  ,inventory.[StartDateMonth] as StartDateMonth
			  ,inventory.[StartDateDay] as StartDateDay
			  ,inventory.[EndDateYear] as EndDateYear
			  ,inventory.[EndDateMonth] as EndDateMonth
			  ,inventory.[EndDateDay] as EndDateDay
			  ,inventory.[IsNoDate] as HasNoChronologicalScope
		  FROM [Archiving].[dbo].[Inventory_Active] inventory
		  WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50));
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteInventoriesQuery + ''' )';
		
		INSERT INTO @RemoteInventories 
		EXEC(@RemoteQuery)
	END

	IF @FundIdentifier IS NOT NULL
	BEGIN
		INSERT INTO @LocalInventories
		SELECT inventory.Id
			  ,inventory.SystemIdentifier as SystemIdentifier
			  ,inventory.HasExternalSource
			  ,inventory.ExternalIdentifier
			  ,inventory.StatusCode
			  ,inventory.StatusText
			  ,inventory.AvailabilityStatusCode
			  ,inventory.AvailabilityStatusText
			  ,inventory.FundHasExternalSource
			  ,inventory.FundExternalIdentifier
			  ,inventory.FundNumber
			  ,inventory.ArchiveCode
			  ,inventory.ArchiveName
			  ,inventory.NumberArray
			  ,inventory.NumberNumeric as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.ApproxmateChronologicalScope
			  ,inventory.LinearMeters
			  ,inventory.ArchivalEntityCount
			  ,inventory.BoxCount
			  ,inventory.RollCount
			  ,inventory.AudioDocumentArchivalEntityCount
			  ,inventory.PhotoDocumentArchivalEntityCount
			  ,inventory.VideoDocumentArchivalEntityCount
			  ,inventory.DigitalDocumentArchivalEntityCount
			  ,inventory.OtherMetrics
			  ,inventory.FundCreatorTitleHistory
			  ,inventory.FundCreatorBiographicalHistory
			  ,inventory.History
			  ,inventory.DocumentsProvider
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'ACQUISITION_METHOD' for XML PATH('')), 1, 1, '') as AcquisitionMethodText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
			  ,inventory.ClassificationScheme
			  ,inventory.DocumentsAccessDescription
			  ,inventory.AbbreviationList
			  ,inventory.MicrofilmedArchivalEntityCount
			  ,inventory.NegativeFrameCount
			  ,inventory.PositiveFrameCount
			  ,inventory.DigitizedArchivalEntityCount
			  ,inventory.Notes
			  ,inventory.DescriptionLevelCode
			  ,inventory.DescriptionLevelText
			  ,inventory.DocumentsDescription
			  ,inventory.StartDateYear
			  ,inventory.StartDateMonth
			  ,inventory.StartDateDay
			  ,inventory.EndDateYear
			  ,inventory.EndDateMonth
			  ,inventory.EndDateDay
			  ,inventory.HasNoChronologicalScope
		FROM [dbo].[v_Inventories] inventory
		WHERE inventory.FundSystemIdentifier = @FundIdentifier 
			AND inventory.HasExternalSource = 0
			AND inventory.Deleted = 0
	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalInventories
		  UNION
		 SELECT *
		   FROM @RemoteInventories
	   ) inventories
	ORDER BY NumberNumeric
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetFundInventoriesCount]
	@LinkedServer nvarchar(255) = '', 
	@FundIdentifier uniqueidentifier = NULL,
	@FundHasExternalSource bit,
	@FundExternalIdentifier int = NULL
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @RemoteInventories TABLE ( InventoryCount int );
	DECLARE @RemoteInventoriesCount int = 0;
	DECLARE @LocalInventoriesCount int = 0;

	DECLARE @RemoteInventoriesQuery nvarchar(max) = '';
    
	IF @FundHasExternalSource = 1
	BEGIN 
		SET @RemoteInventoriesQuery = CAST('' as nvarchar(max)) + '
			SELECT inventory.[LGid]
			FROM [Archiving].[dbo].[Inventory_Active] inventory
			WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50)) + '';
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT COUNT(*) as InventoryCount FROM OPENQUERY(' +  @LinkedServer + ', ''SELECT inventory.[LGid]
			FROM [Archiving].[dbo].[Inventory_Active] inventory
			WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50)) + ''')';
		
		INSERT INTO @RemoteInventories
		EXEC(@RemoteQuery)

		SELECT TOP 1 @RemoteInventoriesCount = InventoryCount from @RemoteInventories
	END

	IF @FundIdentifier IS NOT NULL
	BEGIN
		SELECT @LocalInventoriesCount = COUNT(inventory.Id)
		FROM [dbo].[v_Inventories] inventory
		WHERE inventory.FundSystemIdentifier = @FundIdentifier 
		   AND inventory.HasExternalSource = 0
		   AND inventory.Deleted = 0
	END

	RETURN @LocalInventoriesCount + @RemoteInventoriesCount
END
GO

/****** Object:  StoredProcedure [dbo].[sp_GetInventory]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventory] 
	@LinkedServer nvarchar(50),
	@Identifier int
AS
BEGIN
	SET NOCOUNT ON;

	--SELECT -1 as Id
	--  ,CAST(1 as bit) as HasExternalSource
 --     --,inventory.[_created]
 --     --,inventory.[_retired]
 --     --,inventory.[Gid]
 --     ,inventory.[LGid] as ExternalIdentifier
 --     --,inventory.[CreatedBy]
 --     --,inventory.[CreatedOn]
 --     --,inventory.[ModifiedBy]
 --     --,inventory.[ModifiedOn]
 --     --,inventory.[StatusGid]
	--  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = '3000-01-01 00:00:00.000') as StatusText
 --     --,inventory.[RowStatusGid]
 --     --,inventory.[ProcessGid]
 --     --,inventory.[FundLGid]
	--  ,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = '3000-01-01 00:00:00.000') as FundNumber
 --     --,inventory.[ArchiveGid]
	--  ,(select Name from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = '3000-01-01 00:00:00.000') as ArchiveName
 --     ,inventory.[InventoryArrayGid]
	--  ,(select Value from [Archiving].[dbo].Nomenclature n where n.Gid = inventory.InventoryArrayGid and n._retired = '3000-01-01 00:00:00.000') as NumberPrefix
 --     --,inventory.[TopographicIndexGid]
 --     ,inventory.[Number] as Number
 --     --,inventory.[StartDate]
 --     --,inventory.[EndDate]
 --     ,inventory.[TextDate] as ApproxmateChronologicalScope
 --     ,inventory.[LinearMeter] as LinearMeters
 --     ,inventory.[AECount] as ArchivalEntityCount
 --     ,inventory.[BoxesCount] as BoxCount
 --     ,inventory.[RuloniTubusiCount] as RollCount
 --     ,inventory.[AEFonoDocsCount] as AudioDocumentArchivalEntityCount
 --     ,inventory.[AEPhotoDocsCount] as PhotoDocumentArchivalEntityCount
 --     ,inventory.[AEVideoAudioDocsCount] as VideoDocumentArchivalEntityCount
 --     ,inventory.[AEElectrDocsCount] as DigitalDocumentArchivalEntityCount
 --     ,inventory.[ExtentOther] as OtherMetrics
 --     ,inventory.[FundCreatorNameChanges] as FundCreatorTitleHistory
 --     ,inventory.[FundFormerHistory] as FundCreatorBiographicalHistory
 --     ,inventory.[ArchivalHistory] as History
 --     ,inventory.[ImmediateSourceOfAcquisition] as DocumentsProvider
	--  ,STUFF(
	--	(select '; ' + Value 
	--	   from [Archiving].[dbo].ObjectNomenclature obj 
	--	   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
	--	  where obj.InventoryGid = inventory.Gid and n.Type = 'MethodOfAcquisition' for XML PATH('')), 1, 1, '') as AcquisitionMethodText
	--  ,STUFF(
	--	(select '; ' + Value 
	--	   from [Archiving].[dbo].ObjectNomenclature obj 
	--	   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
	--	  where obj.InventoryGid = inventory.Gid and n.Type = 'CreatingType' for XML PATH('')), 1, 1, '') as CreationMethodText
	--  ,STUFF(
	--	(select '; ' + Value 
	--	   from [Archiving].[dbo].ObjectNomenclature obj 
	--	   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
	--	  where obj.InventoryGid = inventory.Gid and n.Type = 'Originality' for XML PATH('')), 1, 1, '') as OriginalityText
	--  ,STUFF(
	--	(select '; ' + Value 
	--	   from [Archiving].[dbo].ObjectNomenclature obj 
	--	   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
	--	  where obj.InventoryGid = inventory.Gid and n.Type = 'Language' for XML PATH('')), 1, 1, '') as LanguageText
 --     ,inventory.[ClassificationScheme] as ClassificationScheme
 --     ,inventory.[AccessConditions] as DocumentsAccessDescription
 --     --,inventory.[OriginalityOther]
 --     --,inventory.[CreatingTypeOther]
 --     --,inventory.[LanguageOther]
 --     --,inventory.[AveilabilityGid]
 --     --,inventory.[AveilabilityLinearMetersAssigned]
 --     --,inventory.[AveilabilityAECountAssigned]
 --     --,inventory.[AveilabilityLinearMetersDeducted]
 --     --,inventory.[AveilabilityAECountDeducted]
 --     ,inventory.[Abbreviations] as AbbreviationList
 --     ,inventory.[CopyMicrofilmAE] as MicrofilmedArchivalEntityCount
 --     ,inventory.[CopyNegativFrames] as NegativeFrameCount
 --     ,inventory.[CopyPositiveFrames] as PositiveFrameCount
 --     ,inventory.[CopyDigitizedAE] as DigitizedArchivalEntityCount
 --     --,inventory.[CopyCapturedAE]
 --     ,inventory.[Note] as Notes
 --     --,inventory.[LevelOfDescriptionGid]
	--  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = '3000-01-01 00:00:00.000') as DescriptionLevelText
 --     ,inventory.[DocumentProperties] as DocumentsDescription
 --     --,inventory.[CreationDate]
 --     --,inventory.[CreationAuthor]
 --     --,inventory.[ModificationDate]
 --     --,inventory.[ModificationAuthor]
 --     --,inventory.[ValidationFlag]
 --     --,inventory.[MarkedForProcessed]
 --     --,inventory.[IsSavedOnceArray]
 --     --,inventory.[ModifiedByProcessGid]
 --     ,inventory.[StartDateYear] as StartDateYear
 --     ,inventory.[StartDateMonth] as StartDateMonth
 --     ,inventory.[StartDateDay] as StartDateDay
 --     ,inventory.[EndDateYear] as EndDateYear
 --     ,inventory.[EndDateMonth] as EndDateMonth
 --     ,inventory.[EndDateDay] as EndDateDay
 --     ,inventory.[IsNoDate] as HasNoChronologicalScope
 --     --,inventory.[TFTimeStamp]
 --     --,inventory.[IntNumber]
 -- FROM [Archiving].[dbo].[Inventory_Active] inventory
 --WHERE inventory.LGid = 64834 

	declare @sql varchar(max) = '
		SELECT -1 as Id
			  ,NULL as SystemIdentifier
			  ,CAST(1 as bit) as HasExternalSource
			  ,inventory.[LGid] as ExternalIdentifier
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusText
			  ,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''3000-01-01 00:00:00.000'') as AvailabilityStatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''3000-01-01 00:00:00.000'') as AvailabilityStatusText
			  ,CAST(1 as bit) as FundHasExternalSource
			  ,(select f.LGid from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''3000-01-01 00:00:00.000'') as FundExternalIdentifier
			  ,(select f.Number from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''3000-01-01 00:00:00.000'') as FundNumber
			  ,(select a.Code from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveCode
			  ,(select a.Name from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveName
			  ,(select n.Value from [Archiving].[dbo].Nomenclature n where n.Gid = inventory.InventoryArrayGid and n._retired = ''3000-01-01 00:00:00.000'') as NumberArray
			  ,inventory.[Number] as Number
			  ,inventory.[TextDate] as ApproxmateChronologicalScope
			  ,inventory.[LinearMeter] as LinearMeters
			  ,inventory.[AECount] as ArchivalEntityCount
			  ,inventory.[BoxesCount] as BoxCount
			  ,inventory.[RuloniTubusiCount] as RollCount
			  ,inventory.[AEFonoDocsCount] as AudioDocumentArchivalEntityCount
			  ,inventory.[AEPhotoDocsCount] as PhotoDocumentArchivalEntityCount
			  ,inventory.[AEVideoAudioDocsCount] as VideoDocumentArchivalEntityCount
			  ,inventory.[AEElectrDocsCount] as DigitalDocumentArchivalEntityCount
			  ,inventory.[ExtentOther] as OtherMetrics
			  ,inventory.[FundCreatorNameChanges] as FundCreatorTitleHistory
			  ,inventory.[FundFormerHistory] as FundCreatorBiographicalHistory
			  ,inventory.[ArchivalHistory] as History
			  ,inventory.[ImmediateSourceOfAcquisition] as DocumentsProvider
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''MethodOfAcquisition'' for XML PATH('''')), 1, 1, '''') as AcquisitionMethodText
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''CreatingType'' for XML PATH('''')), 1, 1, '''') as CreationMethodText
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''Originality'' for XML PATH('''')), 1, 1, '''') as OriginalityText
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''Language'' for XML PATH('''')), 1, 1, '''') as LanguageText
			  ,inventory.[ClassificationScheme] as ClassificationScheme
			  ,inventory.[AccessConditions] as DocumentsAccessDescription
			  ,inventory.[Abbreviations] as AbbreviationList
			  ,inventory.[CopyMicrofilmAE] as MicrofilmedArchivalEntityCount
			  ,inventory.[CopyNegativFrames] as NegativeFrameCount
			  ,inventory.[CopyPositiveFrames] as PositiveFrameCount
			  ,inventory.[CopyDigitizedAE] as DigitizedArchivalEntityCount
			  ,inventory.[Note] as Notes
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelText
			  ,inventory.[DocumentProperties] as DocumentsDescription
			  ,inventory.[StartDateYear] as StartDateYear
			  ,inventory.[StartDateMonth] as StartDateMonth
			  ,inventory.[StartDateDay] as StartDateDay
			  ,inventory.[EndDateYear] as EndDateYear
			  ,inventory.[EndDateMonth] as EndDateMonth
			  ,inventory.[EndDateDay] as EndDateDay
			  ,inventory.[IsNoDate] as HasNoChronologicalScope
		  FROM [Archiving].[dbo].[Inventory_Active] inventory
		 WHERE inventory.LGid = ' + CAST(@Identifier as varchar(10));

	set @sql = REPLACE(@sql, '''', '''''');
	declare @linkedServerQuery varchar(max) = '
		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''');';

	EXEC (@linkedServerQuery);	
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryBook] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1
	-- ,@ArchiveCodes nvarchar(max) = null -- по искане не ИСДА се маха, понеже данните са само от архив ЦДА
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by IntNumber, Number
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT
				fund.Number,		
				coalesce(
					convert(varchar, fund.FARevicedOnDay, 104) + ''.'' + convert(varchar, fund.FARevicedOnMonth, 104) + ''.'' + convert(varchar, fund.FARecivedOnYear, 104), 
					convert(varchar, fund.FARecivedOnYear, 104)) as ReceivedOn,
				(select Value from Nomenclature n where n.Gid = fund.CountryGid) as CountryOfOrigin,
				coalesce(
					convert(varchar(10), fund.CopyNegativeRolls) + ''-'' + convert(varchar(10), fund.CopyNegativeFrames), 
					convert(varchar(10), fund.CopyNegativeRolls) + ''-'', 
					''-'' + convert(varchar(10), fund.CopyNegativeFrames)) as Negatives,
				coalesce(
					convert(varchar(10), fund.CopyPositiveRolls) + ''-'' + convert(varchar(10), fund.CopyPositiveFrames), 
					convert(varchar(10), fund.CopyPositiveRolls) + ''-'', 
					''-'' + convert(varchar(10), fund.CopyPositiveFrames)) as Positives,
				CAST(fund.CopyXerox as nvarchar(250)) as CopyXerox,
				fund.CopyDigital,
				(select cast(1 as bit) where exists(select 1 from Inventory_Modified i where i.FundLGid=fund.LGid)) as HasInventory,
				fund.InventoryShortDescroption as ShortDescription,
				fund.CreationAuthor,
				fund.Note,
				fund.IntNumber,
				null as SystemIdentifier,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource
			FROM Fund_Modified as fund
			WHERE fund.ArchiveGid = 41
				  AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 9) -- LevelOfDescription=КМФ';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				''E'' + convert(varchar(256), films.InventoryNumber) as Number,			
				(isnull(convert(varchar, films.AcceptedOnDay) + ''.'', '''') + isnull(convert(varchar, films.AcceptedOnMonth) + ''.'', '''') + isnull(convert(varchar, films.AcceptedOnYear), '''')) as ReceivedOn,
				(select Text from [N].[Nomenclatures] n where n.Id = films.CountryId) as CountryOfOrigin,
				coalesce(
					convert(varchar(10), films.MicrofilmNegativeRollsCount) + ''-'' + convert(varchar(10), films.MicrofilmNegativeFramesCount), 
					convert(varchar(10), films.MicrofilmNegativeRollsCount) + ''-'', 
					''-'' + convert(varchar(10), films.MicrofilmNegativeFramesCount)) as Negatives,
				coalesce(
					convert(varchar(10), films.MicrofilmPositiveRollsCount) + ''-'' + convert(varchar(10), films.MicrofilmPositiveFramesCount), 
					convert(varchar(10), films.MicrofilmPositiveRollsCount) + ''-'', 
					''-'' + convert(varchar(10), films.MicrofilmPositiveFramesCount)) as Positives,
				convert(varchar(250), films.PhotoCopy) as CopyXerox,
				convert(varchar(250), films.DigitalCopy) as CopyDigital,
				NULL as HasInventory,
				films.Content as ShortDescription,
				films.Source as CreationAuthor,
				films.Notes as Note,
				films.InventoryNumber as IntNumber,
				films.SystemIdentifier,
				films.ExternalIdentifier,
				films.HasExternalSource
			FROM films
			INNER JOIN Archives a ON a.Id = ArchiveId 
			WHERE films.ExternalIdentifier IS NULL AND films.HasExternalSource = 0
				AND films.Deleted = 0 
				AND a.Code = 12';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Number nvarchar(256) NULL,			
				ReceivedOn varchar(50) NULL,
				CountryOfOrigin nvarchar(MAX) NULL,
				Negatives nvarchar(21) NULL,
				Positives nvarchar(21) NULL,
				CopyXerox nvarchar(250) NULL,
				CopyDigital nvarchar(250) NULL,
				-- DigitalImages
				HasInventory bit NULL,
				ShortDescription nvarchar(MAX) NULL,
				CreationAuthor nvarchar(256) NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
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

CREATE OR ALTER   PROCEDURE [dbo].[sp_GetInventoryBookOfCopiesFromForeignArchivesReport]
	@LinkedServer nvarchar(50), -- Посочване на външната база
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveCodes nvarchar(10) = null	
AS
BEGIN
	SET NOCOUNT ON;  --Не се връща броят на засегнатите редове при изпълнение

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by IntNumber, InventoryNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
	--coalesce() - В колекция от стойности, сред която има NULL, връща първата стойност, която не е NULL

		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT 
			convert(nvarchar(255), (select n.Value2 from Nomenclature as n where n.Gid = fund.CountryGid)) as KmfNumber,
			fund.Number as InventoryNumber,
			coalesce(
				convert(varchar, fund.FARevicedOnDay, 104) + ''.'' + convert(varchar, fund.FARevicedOnMonth, 104) + ''.'' + convert(varchar, fund.FARecivedOnYear, 104),
				convert(varchar, fund.FARevicedOnMonth, 104) + ''.'' + convert(varchar, fund.FARecivedOnYear, 104),
				convert(varchar, fund.FARecivedOnYear, 104)) as ReceivedOn,
			(select n.Value from Nomenclature as n where n.Gid = fund.CountryGid) as CountryOfOrigin,
			fund.FramesCount,
			fund.CopyNegativeRolls as MicrofilmNegativeRollsCount,
			fund.CopyNegativeFrames as MicrofilmNegativeFramesCount,
			fund.CopyPositiveRolls as MicrofilmPositiveRollsCount,
			fund.CopyPositiveFrames as MicrofilmPositiveFramesCount,
			CAST(fund.CopyXerox as nvarchar(256)) as XeroxCopy,
			fund.CopyDigital as DigitalCopy,
			NULL as ElectronicDocumentsCount,
			NULL as ElectronicDocumentsSize,
			fund.CopyOther as Other,
			(select cast(1 as bit) where exists(select 1 from Inventory_Modified i where i.FundLGid=fund.LGid)) as HasInventory,
			fund.InventoryShortDescroption as InventoryShortDescription,
			fund.CreationAuthor,
			fund.IntNumber
		FROM Fund_Modified as fund
		WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 9) -- LevelOfDescription=КМФ'
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT 
			convert(nvarchar(255), (select n.Code from N.Nomenclatures as n where n.Id = films.CountryId)) as KmfNumber,
			convert(nvarchar(256), films.InventoryNumber) as InventoryNumber,
			coalesce(
				convert(varchar, films.AcceptedOnDay, 104) + ''.'' + convert(varchar, films.AcceptedOnMonth, 104) + ''.'' + convert(varchar, films.AcceptedOnYear, 104),
				convert(varchar, films.AcceptedOnMonth, 104) + ''.'' + convert(varchar, films.AcceptedOnYear, 104),
				convert(varchar, films.AcceptedOnYear, 104)) as ReceivedOn,
			(select n.Text from N.Nomenclatures as n where n.id = films.CountryId) as CountryOfOrigin,
			films.FramesCount,
			films.MicrofilmNegativeRollsCount,
			films.MicrofilmNegativeFramesCount,
			films.MicrofilmPositiveRollsCount,
			films.MicrofilmPositiveFramesCount,
			films.PhotoCopy as XeroxCopy,
			films.DigitalCopy,
			(select COUNT(fpd.Id) from FilmPackageDocuments as fpd join FilmPackages as fp on fpd.PackageId = fp.Id where fp.Id = films.PackageBId AND fpd.Deleted = 0 AND fp.Deleted = 0) as ElectronicDocumentsCount,
			(select SUM(fpd.FileSizeInBytes) from FilmPackageDocuments as fpd join FilmPackages as fp on fpd.PackageId = fp.Id where fp.Id = films.PackageBId AND fpd.Deleted = 0) as ElectronicDocumentsSize,
			films.Other,
			NULL as HasInventory,
			films.Content as InventoryShortDescription,
			films.Source as CreationAuthor,
			films.InventoryNumber as IntNumber
		FROM Films as films
		WHERE --ExternalIdentifier IS NULL AND HasExternalSource = 0 
			Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

		IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				KmfNumber nvarchar(255) NULL,			
				InventoryNumber nvarchar(256) NULL,			
				ReceivedOn varchar(50) NULL,
				CountryOfOrigin nvarchar(MAX) NULL,
				FramesCount int NULL,
				MicrofilmNegativeRollsCount int NULL,
				MicrofilmNegativeFramesCount int NULL,
				MicrofilmPositiveRollsCount int NULL,
				MicrofilmPositiveFramesCount int NULL,
				XeroxCopy nvarchar(256) NULL,
				DigitalCopy nvarchar(256) NULL,
				ElectronicDocumentsCount int NULL,
				ElectronicDocumentsSize nvarchar(256) NULL,
				Other nvarchar(256) NULL,
				HasInventory bit NULL,
				InventoryShortDescription nvarchar(MAX) NULL,
				CreationAuthor nvarchar(256) NULL,
				IntNumber int null
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryBookOfCopiesFromForeignArchivesSummary]
	@LinkedServer nvarchar(50), -- Посочване на външната база
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(10) = null

AS
BEGIN
	SET NOCOUNT ON;  --Не се връща броят на засегнатите редове при изпълнение

	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Fund_Modified as fund
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 9) -- LevelOfDescription=КМФ';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Funds 
			WHERE --ExternalIdentifier IS NULL AND HasExternalSource = 0 
				Deleted = 0 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryBookSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1 -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	--,@ArchiveCodes nvarchar(10) = null -- по искане не ИСДА се маха, понеже данните са само от архив ЦДА
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Fund_Modified as fund
			WHERE fund.ArchiveGid = 41
				  AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 9) -- LevelOfDescription=КМФ';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Films 
			INNER JOIN Archives a ON a.Id = ArchiveId 
			WHERE films.ExternalIdentifier IS NULL AND films.HasExternalSource = 0
				AND films.Deleted = 0 
				AND a.Code = 12';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery;
	END


	EXEC (@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[sp_GetLastArchiveEntityNumbers]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[sp_GetLastArchiveEntityNumbers] 
	@LinkedServer NVARCHAR(50),
	@Archive INT,
	@InventoryLGid NVARCHAR(50)
AS
BEGIN
	declare @remoteQuery varchar(max) = '
		SELECT TOP(1)
			Number AS Num,
			(SELECT Code FROM Nomenclature n WHERE n.Gid = LevelOfDescriptionGid AND n.Type = ''LevelOfDescription'' AND _retired = ''3000-01-01'') AS LevelOfDescriptionCode,
			NULL AS Id
		FROM ArchiveEntity_Active ае
		WHERE (SELECT Code FROM Archive a WHERE a.Gid = ArchiveGid) = ' + convert(varchar, @Archive) + ' 
			AND ае.InventoryLGid =  ' + @InventoryLGid + '
			AND ае.LevelOfDescriptionGid = 2174 -- Архивна единица
			AND Number LIKE ''[0-9]%'' 
		ORDER BY IntNumber DESC;
	';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @openQuery nvarchar(MAX) = '

		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');
	';
	
	--print @openQuery
	EXEC (@openQuery);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetLastFundNumbers]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[sp_GetLastFundNumbers] 
	@LinkedServer NVARCHAR(50),
	@Archive INT,
	@FundArray NVARCHAR(10)
AS
BEGIN
	declare @remoteQuery varchar(max) = '
		SELECT TOP(4) -- 4 са нивата на описание за фондове, това са максимума записи с един и същи номер
			Number AS Num,
			(SELECT Code FROM Nomenclature n WHERE n.Gid = LevelOfDescriptionGid AND n.Type = ''LevelOfDescription'' AND _retired = ''3000-01-01'') AS LevelOfDescriptionCode,
			NULL AS Id
		FROM Fund_Active AS fund
		WHERE (SELECT Code FROM Archive a WHERE a.Gid = ArchiveGid) = ' + convert(NVARCHAR, @Archive) + '
			AND (SELECT Value FROM Nomenclature n WHERE n.Gid = FundArrayGid AND n.Type = ''FundArray'' AND _retired = ''3000-01-01'') = N''' + @FundArray + '''
			AND Number IS NOT NULL
			AND Number LIKE ''[0-9]%'' 
		ORDER BY IntNumber DESC;
	';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @openQuery NVARCHAR(MAX) = '

		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');
	';
	
	--print @openQuery
	EXEC (@openQuery);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetLastInventoryNumbers]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[sp_GetLastInventoryNumbers] 
	@LinkedServer NVARCHAR(50),
	@Archive INT,
	@FundLGid NVARCHAR(50),
	@InventoryArray nvarchar(10)
AS
BEGIN
	declare @remoteQuery1 varchar(max) = '
		SELECT TOP(4) -- 4 са нивата на описание за фондове, това са максимума записи с един и същи номер
			Number AS Num,
			(SELECT Code FROM Nomenclature n WHERE n.Gid = LevelOfDescriptionGid AND n.Type = ''LevelOfDescription'' AND _retired = ''3000-01-01'') AS LevelOfDescriptionCode,
			NULL AS Id
		FROM Inventory_Active
		WHERE (SELECT Code FROM Archive a WHERE a.Gid = ArchiveGid) = ' + convert(varchar, @Archive) + ' 
			AND FundLGid =  ' + @FundLGid + '
			AND (SELECT Value FROM Nomenclature n WHERE n.Gid = InventoryArrayGid AND n.Type = ''InventoryArray'' AND _retired = ''3000-01-01'') = ''' + @InventoryArray + ''' 
			AND Number IS NOT NULL
			AND Number LIKE ''[0-9]%'' 
		ORDER BY IntNumber DESC;
	';

	SET @remoteQuery1 = REPLACE(@remoteQuery1, '''', '''''');

	DECLARE @openQuery nvarchar(MAX) = '

		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery1 +''');
	';
	
	--print @openQuery
	EXEC (@openQuery);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_GetNomenclatureByType]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetNomenclatureByType] 
	@LinkedServer nvarchar(255) = '',
	@Type nvarchar(255) = ''
AS
BEGIN
	SET NOCOUNT ON;

	declare @name varchar(50) = 'Value';	
	if @Type = 'IndustryIndex' set @name  ='Value2'

	declare @sql varchar(max) =
		'SELECT 
			Gid,
			' + @name + ' as Name
		FROM '  + @LinkedServer + '.[Archiving].[dbo].[Nomenclature]
		WHERE _retired = ''3000-01-01 00:00:00.000'' AND Type = ''' + @Type + '''';

	exec (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetNumberOfArchiveEntitiesOrderedByEmployeeCombined]
	@LinkedServer nvarchar(50),
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@EmployeeNameGids nvarchar(max) = null,
	@EmployeeNameInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
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
				EmployeeName nvarchar(255) NULL,
				Archive nvarchar(255) NULL,
				LevelOfDescription nvarchar(256) NULL,
				Fund nvarchar(256) NULL,
				Inventory nvarchar(256) NULL,
				ArchiveEntity nvarchar(256) NULL,
				Document nvarchar(2000) NULL,
				AccessDate varchar(50) NULL
			);

	INSERT INTO #temp(
				EmployeeName,
				Archive,
				LevelOfDescription,
				Fund,
				Inventory,
				ArchiveEntity,
				Document,
				AccessDate
			)
	EXEC [sp_GetNumberOfArchiveEntitiesOrderedByEmployeeReport]
		@LinkedServer,
		@ResultType,
		2147483647,
		@Page,
		@EmployeeNameGids,
		@EmployeeNameInternal,
		@ArchiveCodes,
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

	EXEC (@sql);
END
GO

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
	@ArchiveCodes nvarchar(10) = null,
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

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetNumberOfArchiveEntitiesOrderedByEmployeeSummary]
	@LinkedServer nvarchar(50),
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@EmployeeNameGids nvarchar(max) = null,
	@EmployeeNameInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
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

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
    	


	CREATE TABLE #temp (
				EmployeeName nvarchar(255) NULL,
				Archive nvarchar(255) NULL,
				LevelOfDescription nvarchar(256) NULL,
				Fund nvarchar(256) NULL,
				Inventory nvarchar(256) NULL,
				ArchiveEntity nvarchar(256) NULL,
				Document nvarchar(2000) NULL,
				AccessDate varchar(50) NULL
			);

	INSERT INTO #temp(
				EmployeeName,
				Archive,
				LevelOfDescription,
				Fund,
				Inventory,
				ArchiveEntity,
				Document,
				AccessDate
			)
	EXEC [sp_GetNumberOfArchiveEntitiesOrderedByEmployeeReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page,
		@EmployeeNameGids,
		@EmployeeNameInternal,
		@ArchiveCodes,
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
		SELECT COUNT_BIG(*) as TotalRows
		FROM #temp'

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetNumberOfArchiveEntitiesOrderedByReaderCombined]
	@LinkedServer nvarchar(50),
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null,
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
		@ArchiveCodes,
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

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetNumberOfArchiveEntitiesOrderedByReaderReport]
	@LinkedServer nvarchar(50),
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null,
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
		AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
			OR (select a.Code from Archive a where a.Gid=ae.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
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

	EXEC (@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[sp_GetNumberOfArchiveEntitiesOrderedByReaderReport_Test]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetNumberOfArchiveEntitiesOrderedByReaderReport_Test]
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

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT 
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
		--AND p.TypeGid in (101581, 101582, 101574)
		AND((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) 
			OR ae.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
		AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) 
			OR (ae.FundLGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
		AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryGids + ''', '',''))) 
			OR (ae.Gid in (select element from dbo.SplitString(''' + @InventoryGids + ''', '',''))))
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
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetNumberOfArchiveEntitiesOrderedByReaderSummary]
	@LinkedServer nvarchar(50),
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null,
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

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
    	




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
		@RowsOfPage,
		@Page,
		@ArchiveCodes,
		@InventoryGids,
		@InventoryInternal,
		@DateFrom,
		@LevelOfdescriptionGids,
		@LevelOfdescriptionInternal,
		@FundTypeGids,
		@FundTypesInternal,
		@DateTo,

		@StatisticDataOnly

	SET @sql = '
		SELECT COUNT_BIG(*) as TotalRows
		FROM #temp'

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetQualityControlCombined]
	@LinkedServer nvarchar(50), -- Посочване на външната база
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveCodes nvarchar(10) = null

AS
BEGIN

	SET NOCOUNT ON;

	--DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	--DECLARE @sqlFinalPart VARCHAR(MAX) = '
	--	offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
    	




	CREATE TABLE #temp (
				Archive nvarchar(255) NULL,
				TotalNumberOfCheckedObjects int NULL,
				TotalNumberOfCheckedRecords int NULL,
				TotalNumberOfAcceptedObjects int NULL,
				TotalNumberOfAcceptedRecords int NULL,
				TotalNumberOfReturnedObjects int NULL,
				TotalNumberOfReturnedRecords int NULL
			);

	INSERT INTO #temp(
				Archive,
				TotalNumberOfCheckedObjects,
				TotalNumberOfCheckedRecords,
				TotalNumberOfAcceptedObjects,
				TotalNumberOfAcceptedRecords,
				TotalNumberOfReturnedObjects,
				TotalNumberOfReturnedRecords
			)
	EXEC [sp_GetQualityControlReport]
	@LinkedServer,
	@ResultType,
	2147483647,
	@Page,
	@ArchiveCodes

	SET @sql = '
		SELECT 
		NULL as PeriodFrom,
		NULL as PeriodTo,
		NULL as Employee
		FROM #temp'

	EXEC (@sql);
END


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetQualityControlReport]
	@LinkedServer nvarchar(50), -- Посочване на външната база
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveCodes nvarchar(10) = null

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

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetQualityControlSummary]
	@LinkedServer nvarchar(50), -- Посочване на външната база
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveCodes nvarchar(10) = null

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
    	




	CREATE TABLE #temp (
				Archive nvarchar(255) NULL,
				TotalNumberOfCheckedObjects int NULL,
				TotalNumberOfCheckedRecords int NULL,
				TotalNumberOfAcceptedObjects int NULL,
				TotalNumberOfAcceptedRecords int NULL,
				TotalNumberOfReturnedObjects int NULL,
				TotalNumberOfReturnedRecords int NULL
			);

	INSERT INTO #temp(
				Archive,
				TotalNumberOfCheckedObjects,
				TotalNumberOfCheckedRecords,
				TotalNumberOfAcceptedObjects,
				TotalNumberOfAcceptedRecords,
				TotalNumberOfReturnedObjects,
				TotalNumberOfReturnedRecords
			)
	EXEC [sp_GetQualityControlReport]
	@LinkedServer,
	@ResultType,
	@RowsOfPage,
	@Page,
	@ArchiveCodes

	SET @sql = '
		SELECT COUNT_BIG(*) as TotalRows
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
	@RowsOfPage int = 2147483647,
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
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null
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
			NULL as FinalCorrectionDate,
			(
				select convert(varchar, max(p.ModifiedOn), 104)  
				from Document doc
				inner join Process p on p._retired = ''3000-01-01'' and p.Gid = doc.ProcessGid and p.TypeGid = 2123 and p.StepGid = 75
				where doc.LGid = d.lgid
			) as DigitalObjectAcceptanceDate,
			(select top 1 IntNumber from Fund_Modified f where f.LGid = d.FundLGid) as FundIntNumber,
			(select i.IntNumber from Inventory_Modified as i where i.LGid = d.InventoryLGid) as InventoryIntNumber,
			(select ae.IntNumber from ArchiveEntity_Modified as ae where ae.LGid = d.AELGid) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder
		FROM Document_Modified as d
		INNER JOIN Archive a ON a.Gid = d.ArchiveGid AND a._retired = ''3000-01-01''
		--inner join Fund_Modified f on f.LGid = d.FundLGid
		--inner join Inventory_Modified i on i.LGid = d.InventoryLGid
		--inner join ArchiveEntity_Modified ae on ae.LGid = d.AELGid
		LEFT OUTER JOIN [Image] img on d.Gid = img.DocumentGid and img._retired = ''3000-01-01''
		WHERE ISNULL(d.HasDigitalObject, 0) = 1
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
			  AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(d.StartDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			  AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(d.EndDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
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
			NULL as DigitalObjectRecreationDate,
			isnull(dsi.EnrolledBytes, 0) as BytesDO,
			(select top(1) n.Text from N.Nomenclatures as n join DigitalObjects as do on n.Id = do.StatusCode where do.DocumentSystemIdentifier = d.SystemIdentifier and n.Deleted = 0) as StatusDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
			NULL as Operator,
			NULL as CorrectionReturnDate,
			NULL as FinalCorrectionDate,
			NULL as DigitalObjectAcceptanceDate,
			CAST((select f.NumberNumeric FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as nvarchar(256)) as FundIntNumber,
			CAST((select i.NumberNumeric FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as nvarchar(256)) as InventoryIntNumber,
			CAST((select ae.NumberNumeric FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as nvarchar(256)) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder
		FROM Documents as d
		INNER JOIN Archives a ON a.Id = d.ArchiveId AND a.Deleted = 0
		LEFT JOIN v_DocumentSizeInfo dsi ON dsi.DocumentSystemIdentifier = d.SystemIdentifier AND dsi.IsDraft = 0
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
			  AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
			  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			  AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[StartDateYear], d.[StartDateMonth], d.[StartDateDay]) as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			  AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[EndDateYear], d.[EndDateMonth], d.[EndDateDay]) as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))'

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
				ArchiveSortOrder int null
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
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка

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
				MbDO float NULL,
				StatusDO nvarchar(MAX) NULL,
				Operator nvarchar(MAX) NULL,
				CorrectionReturnDate nvarchar(50) NULL,
				FinalCorrectionDate nvarchar(50) NULL,
				DigitalObjectAcceptanceDate nvarchar(50) NULL,
				FundIntNumber INT NULL,
				InventoryIntNumber INT NULL,
				ArchivalEntityIntNumber INT NULL,
				ArchiveSortOrder INT NULL
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
				ArchiveSortOrder
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
		SELECT COUNT_BIG(*) as TotalRows
		FROM #temp'

	EXEC (@sql);
END
GO

/****** Object:  StoredProcedure [dbo].[sp_GetUsers]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetUsers] 
	@LinkedServer nvarchar(255) = ''
AS
BEGIN
	SET NOCOUNT ON;

	declare @name varchar(50) = 'Name';

	declare @sql varchar(max) =
		'SELECT 
			Gid,
			' + @name + ' as Name
		FROM '  + @LinkedServer + '.[Archiving].[dbo].[User]
		WHERE _retired = ''3000-01-01 00:00:00.000''';

	exec (@sql);
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SearchArchiveEntities]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_SearchArchiveEntities] 
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

		--print @FundInternalIdentifier;
	EXEC (@finalQuery);	
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SearchFunds]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_SearchFunds] 
	@LinkedServer nvarchar(50),
	@ArchiveCode int,
	@DescriptionLevel nvarchar(255),
	@SearchText nvarchar(255) = '',
	@Limit int = 1000000
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteFundsQuery nvarchar(max) = '';
    DECLARE @RemoteFunds TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,IsDraft bit
		,ArchiveId int
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,Number nvarchar(50)
		,Title nvarchar(max)
	);

	DECLARE @LocalFunds TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,IsDraft bit
		,ArchiveId int
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,Number nvarchar(50)
		,Title nvarchar(max)
	);

	DECLARE @DescriptionLevelCodes nvarchar(255) = '1,2,3,4'

	IF @DescriptionLevel IS NOT NULL
		SET @DescriptionLevelCodes = @DescriptionLevel


	SET @RemoteFundsQuery = CAST('' as nvarchar(max)) +
	'SELECT TOP(' + CAST(@Limit as nvarchar(50)) + ') 
			-1 as Id
			,CAST(NULL as uniqueidentifier) as SystemIdentifier
			,CAST(1 as bit) as HasExternalSource
			,fund.[LGid] as ExternalIdentifier
			,CAST(0 as bit) as IsDraft
			,CAST(NULL as int) as ArchiveId
			,(select Code from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
			,(select Name from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
			,(select Value from [Archiving].[dbo].Nomenclature n where n.Gid = fund.FundArrayGid and n._retired = ''''3000-01-01 00:00:00.000'''') as NumberArray
			,fund.[Number] as Number
			,fund.[Title] as Title
		FROM [Archiving].[dbo].[Fund_Active] fund
		WHERE fund.ArchiveGid in (select a.Gid from [Archiving].[dbo].[Archive] a where a.Code = ' + CAST(@ArchiveCode as nvarchar(5)) + ')
		AND fund.LevelOfDescriptionGid in (select n.Gid from [Archiving].[dbo].[Nomenclature] n where n.type = ''''LevelOfDescription'''' and n.Code in (' + @DescriptionLevelCodes + '))
		AND fund.Number LIKE ''''%' + @SearchText + '%'''''

	PRINT @RemoteFundsQuery
		
	DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteFundsQuery + ''' )';
		
	INSERT INTO @RemoteFunds 
	EXEC(@RemoteQuery)

		
	

	INSERT INTO @LocalFunds
	SELECT TOP (@Limit) 
			fund.Id
			,fund.SystemIdentifier as SystemIdentifier
			,fund.HasExternalSource
			,fund.ExternalIdentifier
			,fund.IsDraft
			,fund.ArchiveId
			,fund.ArchiveCode
			,fund.ArchiveName
			,fund.NumberArray
			,fund.[Number] as Number
			,fund.Title
		FROM [dbo].[v_Funds] fund
		WHERE fund.ArchiveId in (select a.Id from dbo.Archives a where a.Code = @ArchiveCode)
		AND fund.DescriptionLevelCode IN (select trim(value) from  STRING_SPLIT (@DescriptionLevelCodes, ','))
		AND fund.HasExternalSource = 0
		AND fund.Deleted = 0
		AND fund.Number LIKE '%' + @SearchText + '%'


	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalFunds
		  UNION
		 SELECT *
		   FROM @RemoteFunds
	   ) inventories
	ORDER BY Number




	--declare @sql varchar(max) = 
	--	'SELECT TOP ' + CAST(@Limit AS nvarchar(10)) + ' -- top го слагам, за да не дава грешка
	--		NULL as Id,
	--		fund.LGid as ExternalIdentifier,	
	--		fund.Number,
	--		fund.Title,
	--		CAST(1 AS BIT) as HasExternalSource
	--	FROM [Archiving].[dbo].Fund_Active as fund
	--	WHERE fund.ArchiveGid = ' + CAST(@ArchiveCodeExternal as varchar(10)) + ' AND
	--		(fund.LevelOfDescriptionGid = (select Gid from [Archiving].[dbo].Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1))
	--			AND fund.Number LIKE ''%' + @SearchText + '%''';

	--set @sql = REPLACE(@sql, '''', '''''');
	--declare @linkedServerQuery varchar(max) = '
	--	DECLARE @remoteFundsTable TABLE (
	--		[Id] [int] NULL,
	--		[ExternalIdentifier] [int] NOT NULL,
	--		[Number] [nvarchar](50) NULL,
	--		[Title] [nvarchar](max) NOT NULL,
	--		[HasExternalSource] BIT NOT NULL
	--	);

	--	INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''');

	--	SELECT * FROM @remoteFundsTable
	--	UNION 
	--	SELECT TOP ' + CAST(@Limit AS nvarchar(10)) + ' -- top го слагам, за да не дава грешка
	--		Id,
	--		ExternalIdentifier,	
	--		Number,
	--		Title,
	--		HasExternalSource
	--	FROM dbo.Funds f 
	--	WHERE (SELECT a.Code FROM dbo.Archives a WHERE a.Id=f.ArchiveId) = ' + CAST(@ArchiveCodeInternal as varchar(10)) + ' AND f.Number LIKE ''%' + @SearchText + '%''
	--		AND NOT EXISTS(SELECT 1 FROM @remoteFundsTable rft WHERE f.ExternalIdentifier = rft.ExternalIdentifier)
	--	ORDER BY Number';

	--	--print @linkedServerQuery;
	--EXEC (@linkedServerQuery);	
END
GO
/****** Object:  StoredProcedure [dbo].[sp_SearchInventories]    Script Date: 30.11.2022 г. 11:17:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_SearchInventories] 
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
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetMostUsedRequestEntitiesReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(10) = null,
	@InventoryNumber nvarchar(10) = null,
	@ArchiveEntityNumber nvarchar(10) = null,
	@DocumentNumber nvarchar(10) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodesInternal nvarchar(256) = null,
	@DocumentDescriptionLevelCodesInternal nvarchar(256) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	-- Ползвам CONVERT(NVARCHAR(MAX), ''), защото при конкатениране броят на символите в NVARCHAR(MAX) променливата се ограничава на макс. 4000

	DECLARE @sql NVARCHAR(MAX);
	DECLARE @sqlFinalPart NVARCHAR(MAX) =  CONVERT(NVARCHAR(MAX),'
		order by UsageCount desc
		offset ') + CONVERT(NVARCHAR(10), @offset) +  CONVERT(NVARCHAR(MAX),' rows fetch next ') + CONVERT(NVARCHAR(10), @RowsOfPage) +  CONVERT(VARCHAR(MAX),' rows only');

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery NVARCHAR(MAX) = '
			SELECT 
				a.Name AS Archive,
				n.Value AS DescriptionLevel,
				f.Number AS FundNumber,
				i.Number AS InventoryNumber,
				ae.Number AS ArchiveEntityNumber,
				NULL AS DocumentNumber,
				COUNT_BIG (*) UsageCount,
				''External'' AS Source
			FROM ArchiveEntity_Active as ae
			INNER JOIN RequestEntities re ON re.ArchiveEntityLGid = ae.LGid 
			INNER JOIN Archive a ON a.Gid = ae.ArchiveGid
			INNER JOIN Fund_Active f ON f.LGid = ae.FundLGid
			INNER JOIN Inventory_Active i ON i.LGid = ae.InventoryLGid
			LEFT JOIN Nomenclature n ON n.Gid = ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01''
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + CONVERT(VARCHAR(MAX),''', '',''))) OR a.Code in (select element from dbo.SplitString(''') + @ArchiveCodes +  CONVERT(VARCHAR(MAX),''', '','')))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')))  + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @LevelOfDescriptionGids + CONVERT(NVARCHAR(MAX),''', '',''))) OR (ae.LevelOfDescriptionGid in (select element from dbo.SplitString(''') + @LevelOfDescriptionGids + CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY ArchiveEntityLGid, f.Number, i.Number, ae.Number, a.Name, n.Value
			');
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
			SELECT
				a.Name AS Archive,
				fdl.Text AS DescriptionLevel,
				f.Number AS FundNumber,
				NULL AS InventoryNumber,
				NULL AS ArchiveEntityNumber,
				NULL AS DocumentNumber,
				COUNT_BIG (*) AS UsageCount,
				''Internal'' AS Source
			FROM PublicUserReviews pur
			INNER JOIN Funds f ON f.SystemIdentifier = pur.FundSystemIdentifier 
			INNER JOIN Archives a ON a.Id = f.ArchiveId
			LEFT JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode 
			WHERE f.Deleted = 0 
				AND pur.FundSystemIdentifier IS NOT NULL
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @FundDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''') + @FundDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY f.SystemIdentifier, f.Number, a.Name, fdl.Text

			UNION

			SELECT
				a.Name AS Archive,
				idl.Text AS DescriptionLevel,
				f.Number AS FundNumber,
				i.Number AS InventoryNumber,
				NULL AS ArchiveEntityNumber,
				NULL AS DocumentNumber,
				COUNT_BIG (*) AS UsageCount,
				''Internal'' AS Source
			FROM PublicUserReviews pur
			INNER JOIN Inventories i ON i.SystemIdentifier = pur.InventorySystemIdentifier 
			INNER JOIN Funds f ON f.SystemIdentifier = i.FundSystemIdentifier 
			INNER JOIN Archives a ON a.Id = i.ArchiveId
			LEFT JOIN N.InventoryDescriptionLevel idl ON idl.Code = i.DescriptionLevelCode 
			WHERE i.Deleted = 0 
				AND pur.InventorySystemIdentifier IS NOT NULL
				AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @InventoryDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''') + @InventoryDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY i.SystemIdentifier, f.Number, i.Number, a.Name, idl.Text

			UNION

			SELECT
				a.Name AS Archive,
				aedl.Text AS DescriptionLevel,
				f.Number AS FundNumber,
				i.Number AS InventoryNumber,
				ae.Number AS ArchiveEntityNumber,
				NULL AS DocumentNumber,
				COUNT_BIG (*) AS UsageCount,
				''Internal'' AS Source
			FROM PublicUserReviews pur
			INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = pur.ArchivalEntitySystemIdentifier 
			INNER JOIN Funds f ON f.SystemIdentifier = ae.FundSystemIdentifier 
			INNER JOIN Inventories i ON i.SystemIdentifier = ae.InventorySystemIdentifier 
			INNER JOIN Archives a ON a.Id = ae.ArchiveId
			LEFT JOIN N.ArchivalEntityDescriptionLevel aedl ON aedl.Code = ae.DescriptionLevelCode 
			WHERE ae.Deleted = 0 
				AND pur.ArchivalEntitySystemIdentifier IS NOT NULL
				AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchivalEntityDescriptionLevelCodesInternal +  CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''') + @ArchivalEntityDescriptionLevelCodesInternal +  CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY ae.SystemIdentifier, f.Number, i.Number, ae.Number, a.Name, aedl.Text

			UNION

			SELECT
				a.Name AS Archive,
				ddl.Text AS DescriptionLevel,
				f.Number AS FundNumber,
				i.Number AS InventoryNumber,
				ae.Number AS ArchiveEntityNumber,
				d.Number AS DocumentNumber,
				COUNT_BIG (*) AS UsageCount,
				''Internal'' Source
			FROM PublicUserReviews pur
			INNER JOIN Documents d ON d.SystemIdentifier = pur.DocumentSystemIdentifier 
			INNER JOIN Archives a ON a.Id = d.ArchiveId
			INNER JOIN Funds f ON f.SystemIdentifier = d.FundSystemIdentifier 
			INNER JOIN Inventories i ON i.SystemIdentifier = d.InventorySystemIdentifier 
			INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier 		
			LEFT JOIN N.DocumentDescriptionLevel ddl ON ddl.Code = d.DescriptionLevelCode
			WHERE d.Deleted = 0 
				AND pur.DocumentSystemIdentifier IS NOT NULL
				AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  +  CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes +  CONVERT(NVARCHAR(MAX),''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@DocumentNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (d.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@DocumentNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @DocumentDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (d.DescriptionLevelCode in (select element from dbo.SplitString(''') + @DocumentDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY d.SystemIdentifier, f.Number, i.Number, ae.Number, d.Number, a.Name, ddl.Text
			');
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Archive nvarchar(256) NOT NULL,
				DescriptionLevel nvarchar(MAX) NULL,
				FundNumber nvarchar(256) NULL,
				InventoryNumber nvarchar(256) NULL,
				ArchiveEntityNumber nvarchar(256) NULL,
				DocumentNumber nvarchar(256) NULL,
				UsageCount BIGINT,
				Source VARCHAR(50)
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

CREATE OR ALTER PROCEDURE [dbo].[GetMostUsedRequestEntitiesReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(10) = null,
	@InventoryNumber nvarchar(10) = null,
	@ArchiveEntityNumber nvarchar(10) = null,
	@DocumentNumber nvarchar(10) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodesInternal nvarchar(256) = null,
	@DocumentDescriptionLevelCodesInternal nvarchar(256) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT_BIG(*) TotalRows FROM 
			(
				SELECT COUNT_BIG(*) TotalRows
				FROM ArchiveEntity_Active as ae
				INNER JOIN RequestEntities re ON re.ArchiveEntityLGid = ae.LGid 
				INNER JOIN Archive a ON a.Gid = ae.ArchiveGid
				INNER JOIN Fund_Active f ON f.LGid = ae.FundLGid
				INNER JOIN Inventory_Active i ON i.LGid = ae.InventoryLGid
				LEFT JOIN Nomenclature n ON n.Gid = ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01''
				WHERE 
					((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + CONVERT(VARCHAR(MAX),''', '',''))) OR a.Code in (select element from dbo.SplitString(''') + @ArchiveCodes +  CONVERT(VARCHAR(MAX),''', '','')))
					AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')))  + CONVERT(NVARCHAR(MAX),'''))
					AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
					AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
					AND ((''-999'' in (select element from dbo.SplitString(''') + @LevelOfDescriptionGids + CONVERT(NVARCHAR(MAX),''', '',''))) OR (ae.LevelOfDescriptionGid in (select element from dbo.SplitString(''') + @LevelOfDescriptionGids + CONVERT(NVARCHAR(MAX),''', '',''))))
				GROUP BY ArchiveEntityLGid, f.Number, i.Number, ae.Number, a.Name, n.Value
			) t1
		');

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = CONVERT(NVARCHAR(MAX),'
			SELECT SUM(Rows) TotalRows FROM (
				SELECT COUNT_BIG(*) Rows FROM 
				(
					SELECT COUNT_BIG(*) Rows
					FROM PublicUserReviews pur
					INNER JOIN Funds f ON f.SystemIdentifier = pur.FundSystemIdentifier 
					INNER JOIN Archives a ON a.Id = f.ArchiveId
					LEFT JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode 
					WHERE f.Deleted = 0 
						AND pur.FundSystemIdentifier IS NOT NULL
						AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
							OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
						AND ((''-999'' in (select element from dbo.SplitString(''') + @FundDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
							OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''') + @FundDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
					GROUP BY f.SystemIdentifier, f.Number, a.Name, fdl.Text
				) t1

				UNION ALL

				SELECT COUNT_BIG(*) Rows FROM 
				(
					SELECT COUNT_BIG(*) Rows
					FROM PublicUserReviews pur
					INNER JOIN Inventories i ON i.SystemIdentifier = pur.InventorySystemIdentifier 
					INNER JOIN Funds f ON f.SystemIdentifier = i.FundSystemIdentifier 
					INNER JOIN Archives a ON a.Id = i.ArchiveId
					LEFT JOIN N.InventoryDescriptionLevel idl ON idl.Code = i.DescriptionLevelCode 
					WHERE i.Deleted = 0 
						AND pur.InventorySystemIdentifier IS NOT NULL
						AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  + CONVERT(NVARCHAR(MAX),''', '',''))) 
							OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
						AND ((''-999'' in (select element from dbo.SplitString(''') + @InventoryDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
							OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''') + @InventoryDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
					GROUP BY i.SystemIdentifier, f.Number, i.Number, a.Name, idl.Text
				) t2

				UNION ALL

				SELECT COUNT_BIG(*) Rows FROM 
				(
					SELECT COUNT_BIG(*) Rows
					FROM PublicUserReviews pur
					INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = pur.ArchivalEntitySystemIdentifier 
					INNER JOIN Funds f ON f.SystemIdentifier = ae.FundSystemIdentifier 
					INNER JOIN Inventories i ON i.SystemIdentifier = ae.InventorySystemIdentifier 
					INNER JOIN Archives a ON a.Id = ae.ArchiveId
					LEFT JOIN N.ArchivalEntityDescriptionLevel aedl ON aedl.Code = ae.DescriptionLevelCode 
					WHERE ae.Deleted = 0 
						AND pur.ArchivalEntitySystemIdentifier IS NOT NULL
						AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  + CONVERT(NVARCHAR(MAX),''', '',''))) 
							OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),'''))
						AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchivalEntityDescriptionLevelCodesInternal +  CONVERT(NVARCHAR(MAX),''', '',''))) 
							OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''') + @ArchivalEntityDescriptionLevelCodesInternal +  CONVERT(NVARCHAR(MAX),''', '',''))))
					GROUP BY ae.SystemIdentifier, f.Number, i.Number, ae.Number, a.Name, aedl.Text
				) t3

				UNION ALL

				SELECT COUNT_BIG(*) Rows FROM 
				(
					SELECT COUNT_BIG(*) Rows
					FROM PublicUserReviews pur
					INNER JOIN Documents d ON d.SystemIdentifier = pur.DocumentSystemIdentifier 
					INNER JOIN Archives a ON a.Id = d.ArchiveId
					INNER JOIN Funds f ON f.SystemIdentifier = d.FundSystemIdentifier 
					INNER JOIN Inventories i ON i.SystemIdentifier = d.InventorySystemIdentifier 
					INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier 		
					LEFT JOIN N.DocumentDescriptionLevel ddl ON ddl.Code = d.DescriptionLevelCode
					WHERE d.Deleted = 0 
						AND pur.DocumentSystemIdentifier IS NOT NULL
						AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  +  CONVERT(NVARCHAR(MAX),''', '',''))) 
							OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes +  CONVERT(NVARCHAR(MAX),''', '',''))))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),'''))
						AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@DocumentNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (d.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@DocumentNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
						AND ((''-999'' in (select element from dbo.SplitString(''') + @DocumentDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
							OR (d.DescriptionLevelCode in (select element from dbo.SplitString(''') + @DocumentDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
					GROUP BY d.SystemIdentifier, f.Number, i.Number, ae.Number, d.Number, a.Name, ddl.Text
				) t4
			) t
					
		');
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE ( 
				TotalRows bigint NULL
			);

			INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
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

CREATE OR ALTER PROCEDURE [dbo].[GetMostUsedRequestEntitiesReportTotalCount] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(10) = null,
	@InventoryNumber nvarchar(10) = null,
	@ArchiveEntityNumber nvarchar(10) = null,
	@DocumentNumber nvarchar(10) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodesInternal nvarchar(256) = null,
	@DocumentDescriptionLevelCodesInternal nvarchar(256) = null
AS
BEGIN
	SET NOCOUNT ON;

	-- Ползвам CONVERT(NVARCHAR(MAX), ''), защото при конкатениране броят на символите в NVARCHAR(MAX) променливата се ограничава на макс. 4000

	DECLARE @sql NVARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery NVARCHAR(MAX) = '
			SELECT 
				COUNT_BIG (*) UsageCount
			FROM ArchiveEntity_Active as ae
			INNER JOIN RequestEntities re ON re.ArchiveEntityLGid = ae.LGid 
			INNER JOIN Archive a ON a.Gid = ae.ArchiveGid
			INNER JOIN Fund_Active f ON f.LGid = ae.FundLGid
			INNER JOIN Inventory_Active i ON i.LGid = ae.InventoryLGid
			LEFT JOIN Nomenclature n ON n.Gid = ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01''
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + CONVERT(VARCHAR(MAX),''', '',''))) OR a.Code in (select element from dbo.SplitString(''') + @ArchiveCodes +  CONVERT(VARCHAR(MAX),''', '','')))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')))  + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @LevelOfDescriptionGids + CONVERT(NVARCHAR(MAX),''', '',''))) OR (ae.LevelOfDescriptionGid in (select element from dbo.SplitString(''') + @LevelOfDescriptionGids + CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY ArchiveEntityLGid, f.Number, i.Number, ae.Number, a.Name, n.Value
			');
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
			SELECT
				COUNT_BIG (*) AS UsageCount
			FROM PublicUserReviews pur
			INNER JOIN Funds f ON f.SystemIdentifier = pur.FundSystemIdentifier 
			INNER JOIN Archives a ON a.Id = f.ArchiveId
			LEFT JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode 
			WHERE f.Deleted = 0 
				AND pur.FundSystemIdentifier IS NOT NULL
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @FundDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''') + @FundDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY f.SystemIdentifier, f.Number, a.Name, fdl.Text

			UNION ALL

			SELECT
				COUNT_BIG (*) AS UsageCount
			FROM PublicUserReviews pur
			INNER JOIN Inventories i ON i.SystemIdentifier = pur.InventorySystemIdentifier 
			INNER JOIN Funds f ON f.SystemIdentifier = i.FundSystemIdentifier 
			INNER JOIN Archives a ON a.Id = i.ArchiveId
			LEFT JOIN N.InventoryDescriptionLevel idl ON idl.Code = i.DescriptionLevelCode 
			WHERE i.Deleted = 0 
				AND pur.InventorySystemIdentifier IS NOT NULL
				AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @InventoryDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''') + @InventoryDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY i.SystemIdentifier, f.Number, i.Number, a.Name, idl.Text

			UNION ALL

			SELECT
				COUNT_BIG (*) AS UsageCount
			FROM PublicUserReviews pur
			INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = pur.ArchivalEntitySystemIdentifier 
			INNER JOIN Funds f ON f.SystemIdentifier = ae.FundSystemIdentifier 
			INNER JOIN Inventories i ON i.SystemIdentifier = ae.InventorySystemIdentifier 
			INNER JOIN Archives a ON a.Id = ae.ArchiveId
			LEFT JOIN N.ArchivalEntityDescriptionLevel aedl ON aedl.Code = ae.DescriptionLevelCode 
			WHERE ae.Deleted = 0 
				AND pur.ArchivalEntitySystemIdentifier IS NOT NULL
				AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchivalEntityDescriptionLevelCodesInternal +  CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''') + @ArchivalEntityDescriptionLevelCodesInternal +  CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY ae.SystemIdentifier, f.Number, i.Number, ae.Number, a.Name, aedl.Text

			UNION ALL

			SELECT
				COUNT_BIG (*) AS UsageCount
			FROM PublicUserReviews pur
			INNER JOIN Documents d ON d.SystemIdentifier = pur.DocumentSystemIdentifier 
			INNER JOIN Archives a ON a.Id = d.ArchiveId
			INNER JOIN Funds f ON f.SystemIdentifier = d.FundSystemIdentifier 
			INNER JOIN Inventories i ON i.SystemIdentifier = d.InventorySystemIdentifier 
			INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier 		
			LEFT JOIN N.DocumentDescriptionLevel ddl ON ddl.Code = d.DescriptionLevelCode
			WHERE d.Deleted = 0 
				AND pur.DocumentSystemIdentifier IS NOT NULL
				AND ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes  +  CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''') + @ArchiveCodes +  CONVERT(NVARCHAR(MAX),''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) +  CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@DocumentNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (d.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@DocumentNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''-999'' in (select element from dbo.SplitString(''') + @DocumentDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))) 
					OR (d.DescriptionLevelCode in (select element from dbo.SplitString(''') + @DocumentDescriptionLevelCodesInternal + CONVERT(NVARCHAR(MAX),''', '',''))))
			GROUP BY d.SystemIdentifier, f.Number, i.Number, ae.Number, d.Number, a.Name, ddl.Text
			');
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				UsageCount BIGINT
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT SUM(UsageCount) UsageCountTotal FROM (
				SELECT UsageCount FROM @remoteFundsTable
				UNION ALL
				' +
				@localQuery + ') t';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''SELECT SUM(UsageCount) UsageCountTotal FROM (' + @remoteQuery + ') t'');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = 'SELECT SUM(UsageCount) UsageCountTotal FROM (' + @localQuery + ') t';
	END

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[GetActiveProcessesReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ProcessTypeGids nvarchar(max) = null,
	@ProcessTypeCodesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber NVARCHAR(50) = null,
	@CreatedFrom nvarchar(100) = null,
	@CreatedTo nvarchar(100) = null,
	@UserGids nvarchar(max)= null,
	@UserIdsInternal nvarchar(max)= null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		--GROUP BY p.Id, ps.Id, a.Name, fdl.Text, f.Number, f.Title, pt.Name, p.CreatedOn, u.DisplayName, f.NumberNumeric, a.SortOrder
		order by SortOrder, IntNumber, FundNumber
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				a.Name AS Archive,
				(SELECT Value FROM Nomenclature n5 where n5._retired = ''3000-01-01'' and n5.Gid = fund.LevelOfDescriptionGid ) as DescriptionLevel,
				NULL AS FundId,
				fund.Number AS FundNumber,
				fund.Title AS Title,
				NULL as DocumentId,
				NULL AS DocumentNumber,
				(cast((select Value from Nomenclature where _retired = ''3000-01-01'' and Gid = p.TypeGid) as nvarchar(500)) + '' Стъпка: '' 
					+ CAST((SELECT Value  from Nomenclature where _retired = ''3000-01-01'' and Gid = p.StepGid) AS NVARCHAR(500)))  ProcessName,
				convert(varchar, p.CreatedOn, 104) as ProcessStartDate,
				(SELECT Name FROM [User] where _retired = ''3000-01-01'' and Gid = p.CreatedBy) as Initiator, 
				fund.IntNumber,
				a.SortOrder,
				NULL AS ProcessStepId,
				''Fund'' AS EntityType
			FROM Process p
			--Няма активна стъпка 1
			INNER JOIN Fund_Modified fund ON fund.ProcessGid = p.Gid
				AND fund.RowStatusGid = 72
				AND (''' + ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')) + 
					 N''' = ''NULL'' OR fund.Number = ''' + 
					ISNULL(@FundNumber, N'NULL') +  N''')
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE p._retired = ''3000-01-01''
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND not exists(select 1 from Document_Search_Modified where ProcessGid = p.Gid)
				AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
				AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR p.TypeGid in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '','')))
				AND p.TypeGid not in (2377, 2126, 2123, 2124, 2125)
				
			UNION ALL
			
			SELECT
				a.Name AS Archive,
				NULL as DescriptionLevel,
				NULL AS FundId,
				NULL AS FundNumber,
				NULL AS Title,
				NULL AS DocumentId,
				NULL AS DocumentNumber,
				(cast((select Value from Nomenclature where _retired = ''3000-01-01'' and Gid = p.TypeGid) as nvarchar(500)) + '' Стъпка: '' 
					+ CAST((SELECT Value  from Nomenclature where _retired = ''3000-01-01'' and Gid = p.StepGid) AS NVARCHAR(500)))  ProcessName,
				convert(varchar, p.CreatedOn, 104) as ProcessStartDate,
				(SELECT Name FROM [User] where _retired = ''3000-01-01'' and Gid = p.CreatedBy) as Initiator, 
				NULL AS IntNumber,
				NULL AS SortOrder,
				NULL AS ProcessStepId,
				NULL AS EntityType
			FROM [Process] p
			INNER JOIN Archive a ON a.Gid = p.[CExportArchiveGid] AND a.Code IN (SELECT Element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')) AND a._retired = ''3000-01-01''
			WHERE p._retired = ''3000-01-01''
				AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1) --Няма активна стъпка 1 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
				AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
				AND p.TypeGid in (SELECT [Gid] FROM Nomenclature WHERE [Type] = ''Process'' AND [_retired] = ''3000-01-01'' 
					AND [Code] IN (25, 26, 34) AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR [Gid] IN (SELECT Element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))))
			
			UNION ALL

			SELECT
				a.Name AS Archive,
				(SELECT Value FROM Nomenclature n5 where n5._retired = ''3000-01-01'' and n5.Gid = fund.LevelOfDescriptionGid ) as DescriptionLevel,
				NULL AS FundId,
				fund.Number AS FundNumber,
				fund.Title AS Title,
				cast(doc.LGid as nvarchar) as DocumentId,
				NULL AS DocumentNumber,
				(cast((select Value from Nomenclature where _retired = ''3000-01-01'' and Gid = p.TypeGid) as nvarchar(500)) + '' Стъпка: '' 
					+ CAST((SELECT Value  from Nomenclature where _retired = ''3000-01-01'' and Gid = p.StepGid) AS NVARCHAR(500)))  ProcessName,
				convert(varchar, p.CreatedOn, 104) as ProcessStartDate,
				(SELECT Name FROM [User] where _retired = ''3000-01-01'' and Gid = p.CreatedBy) as Initiator, 
				fund.IntNumber,
				a.SortOrder,
				NULL AS ProcessStepId,
				''Document'' AS EntityType
			FROM Process p
				inner join Document_Modified doc on doc.ProcessGid = p.Gid
				and doc.RowStatusGid = 72
				inner join Fund_Modified fund on fund.LGid = doc.FundLGid
					AND (''' + ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')) + 
						N''' = ''NULL'' OR fund.Number = ''' + 
						ISNULL(@FundNumber,  N'NULL') + N''')
				INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE p._retired = ''3000-01-01''
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1) --Няма активна стъпка 1
				AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
				AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR p.TypeGid in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '','')))
	';
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	DECLARE @localQueryWhereClause VARCHAR(MAX) = '
		AND p.Completed = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR ((select convert(varchar(4), a.Code, 104)) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND (''' + ISNULL(@FundNumber, N'NULL') + N''' = ''NULL'' OR f.Number = ''' + ISNULL(@FundNumber, N'NULL') +  N''')
			AND ((''-999'' in (select element from dbo.SplitString(''' + @UserIdsInternal  + ''', '',''))) OR CAST(p.CreatedBy AS VARCHAR(50)) in (SELECT Element from dbo.SplitString(''' + @UserIdsInternal + ''', '','')))
			AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeCodesInternal + ''', '',''))) OR pt.Id in (select element from dbo.SplitString(''' + @ProcessTypeCodesInternal + ''', '','')))
	';

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT DISTINCT
				a.Name AS Archive,
				fdl.Text AS DescriptionLevel,
				NULL AS FundId,
				f.Number AS FundNumber,
				f.Title AS Title,
				cast(d.SystemIdentifier as nvarchar(50)) AS DocumentId,
				d.Number AS DocumentNumber,
				(pt.Name + '' Стъпка: '' + ps.Text) AS ProcessName,
				convert(varchar, p.CreatedOn, 104) as ProcessStartDate,
				u.DisplayName AS Initiator,
				f.NumberNumeric as IntNumber,
				a.SortOrder AS SortOrder,
				p.Id AS ProcessId,
				''Document'' AS EntityType
				--,ps.Id AS ProcessStepId
			FROM v_Documents d 
			INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
			INNER JOIN Funds f ON d.FundSystemIdentifier = f.SystemIdentifier
			INNER JOIN Process p ON p.DocumentSystemIdentifier = d.SystemIdentifier AND p.Deleted = 0 AND p.Completed = 0
			INNER JOIN AspNetUsers u ON u.Id = p.CreatedBy AND u.Deleted = 0
			LEFT JOIN N.ProcessTypes pt ON pt.Id = p.ProcessTypeId
			LEFT JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode
			INNER JOIN ProcessTimeline ptl ON ptl.ProcessId = p.Id AND ptl.completed = 0
			INNER JOIN N.ProcessSteps ps ON ps.Id = ptl.StepTypeId
			WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0'  
				+ @localQueryWhereClause + '

			UNION

			SELECT DISTINCT
				a.Name AS Archive,
				fdl.Text AS DescriptionLevel,
				f.SystemIdentifier AS FundId,
				f.Number AS FundNumber,
				f.Title AS Title,
				NULL AS DocumentId,
				NULL AS DocumentNumber,
				(pt.Name + '' Стъпка: '' + ps.Text) AS ProcessName,
				convert(varchar, p.CreatedOn, 104) as ProcessStartDate,
				u.DisplayName AS Initiator,
				f.NumberNumeric as IntNumber,
				a.SortOrder AS SortOrder,
				p.Id AS ProcessId,
				''Fund'' AS EntityType
				--,ps.Id AS ProcessStepId
			FROM v_Funds f 
			INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
			INNER JOIN Process p ON p.FundSystemIdentifier = f.SystemIdentifier AND p.Deleted = 0 AND p.Completed = 0
			INNER JOIN AspNetUsers u ON u.Id = p.CreatedBy AND u.Deleted = 0
			LEFT JOIN N.ProcessTypes pt ON pt.Id = p.ProcessTypeId
			LEFT JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode
			INNER JOIN ProcessTimeline ptl ON ptl.ProcessId = p.Id AND ptl.completed = 0
			INNER JOIN N.ProcessSteps ps ON ps.Id = ptl.StepTypeId
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0'
				+ @localQueryWhereClause
			;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				Archive nvarchar(256) NOT NULL,
				DescriptionLevel nvarchar(256) NOT NULL,
				FundId nvarchar(50) NULL,
				FundNumber nvarchar(256) NULL,
				Title nvarchar(MAX) NULL,
				DocumentId nvarchar(50) NULL,
				DocumentNumber nvarchar(256) NULL,
				ProcessName nvarchar(MAX) NULL,
				ProcessStartDate varchar(50) NULL,
				Initiator nvarchar(256) NULL,
				IntNumber int null,
				SortOrder int null,
				ProcessId INT NULL,
				EntityType nvarchar(50) NULL
				--,ProcessStepId INT NULL
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

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetActiveProcessesReportCount] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ProcessTypeGids nvarchar(max) = null,
	@ProcessTypeCodesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber NVARCHAR(50) = null,
	@CreatedFrom nvarchar(100) = null,
	@CreatedTo nvarchar(100) = null,
	@UserGids nvarchar(max)= null,
	@UserIdsInternal nvarchar(max)= null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT(Gid) as Total FROM
			(
				SELECT p.Gid Gid
				FROM Process p
				--Няма активна стъпка 1
				INNER JOIN Fund_Modified fund ON fund.ProcessGid = p.Gid
					AND fund.RowStatusGid = 72
					AND (''' + ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')) + 
						 N''' = ''NULL'' OR fund.Number = ''' + 
						ISNULL(@FundNumber, N'NULL') +  N''')
				INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
				WHERE p._retired = ''3000-01-01''
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
					AND not exists(select 1 from Document_Search_Modified where ProcessGid = p.Gid)
					AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1)
					AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
					AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR p.TypeGid in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '','')))
					AND p.TypeGid not in (2377, 2126, 2123, 2124, 2125) 

				UNION

				SELECT p.Gid Gid
				FROM [Process] p
				INNER JOIN Archive a ON a.Gid = p.[CExportArchiveGid] AND a.Code IN (SELECT Element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')) AND a._retired = ''3000-01-01''
				WHERE p._retired = ''3000-01-01''
					AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1) --Няма активна стъпка 1 
					AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
					AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
					AND p.TypeGid in (SELECT [Gid] FROM Nomenclature WHERE [Type] = ''Process'' AND [_retired] = ''3000-01-01'' 
						AND [Code] IN (25, 26, 34) AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR [Gid] IN (SELECT Element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))))
				UNION

				SELECT p.Gid Gid
				FROM Process p
					inner join Document_Modified doc on doc.ProcessGid = p.Gid
					and doc.RowStatusGid = 72
					inner join Fund_Modified fund on fund.LGid = doc.FundLGid
						AND (''' + ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')) + 
							N''' = ''NULL'' OR fund.Number = ''' + 
							ISNULL(@FundNumber,  N'NULL') + N''')
					INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
				WHERE p._retired = ''3000-01-01''
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
					AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1) --Няма активна стъпка 1
					AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
					AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR p.TypeGid in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '','')))
			) t
		';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	DECLARE @localQueryWhereClause VARCHAR(MAX) = '
		AND p.Completed = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR ((select convert(varchar(4), a.Code, 104)) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND (''' + ISNULL(@FundNumber, N'NULL') + N''' = ''NULL'' OR f.Number = ''' + ISNULL(@FundNumber, N'NULL') +  N''')
			AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR CAST(p.CreatedBy AS VARCHAR(50)) in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
			AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeCodesInternal + ''', '',''))) OR pt.Id in (select element from dbo.SplitString(''' + @ProcessTypeCodesInternal + ''', '','')))
	';
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT(ProcessId) as Total FROM
			(
				SELECT p.Id ProcessId
				FROM v_Documents d 
				INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
				INNER JOIN Funds f ON d.FundSystemIdentifier = f.SystemIdentifier
				INNER JOIN Process p ON p.DocumentSystemIdentifier = d.SystemIdentifier AND p.Deleted = 0
				INNER JOIN AspNetUsers u ON u.Id = p.CreatedBy AND u.Deleted = 0
				INNER JOIN N.ProcessTypes pt ON pt.Id = p.ProcessTypeId
				INNER JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode
				WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0'  
					+ @localQueryWhereClause + '

				UNION

				SELECT p.Id ProcessId
				FROM v_Funds f 
				INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
				INNER JOIN Process p ON p.FundSystemIdentifier = f.SystemIdentifier AND p.Deleted = 0
				INNER JOIN AspNetUsers u ON u.Id = p.CreatedBy AND u.Deleted = 0
				INNER JOIN N.ProcessTypes pt ON pt.Id = p.ProcessTypeId
				INNER JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode
				WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0'
					+ @localQueryWhereClause + '
			) t'
		;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteRowsTable TABLE ( 
				Total int NULL
			);

			INSERT INTO @remoteRowsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.Total) as Total
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteRowsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
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

CREATE OR ALTER PROCEDURE [dbo].[GetActiveProcessesReportTotalRows] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ProcessTypeGids nvarchar(max) = null,
	@ProcessTypeCodesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber NVARCHAR(50) = null,
	@CreatedFrom nvarchar(100) = null,
	@CreatedTo nvarchar(100) = null,
	@UserGids nvarchar(max)= null,
	@UserIdsInternal nvarchar(max)= null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT SUM( Rows) as TotalRows FROM
			(
				SELECT COUNT_BIG(*) Rows
				FROM Process p
				--Няма активна стъпка 1
				INNER JOIN Fund_Modified fund ON fund.ProcessGid = p.Gid
					AND fund.RowStatusGid = 72
					AND (''' + ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')) + 
						 N''' = ''NULL'' OR fund.Number = ''' + 
						ISNULL(@FundNumber, N'NULL') +  N''')
				INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
				WHERE p._retired = ''3000-01-01''
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
					AND not exists(select 1 from Document_Search_Modified where ProcessGid = p.Gid)
					AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1)
					AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
					AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR p.TypeGid in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '','')))
					AND p.TypeGid not in (2377, 2126, 2123, 2124, 2125) 

				UNION ALL

				SELECT COUNT_BIG(*) Rows
				FROM [Process] p
				INNER JOIN Archive a ON a.Gid = p.[CExportArchiveGid] AND a.Code IN (SELECT Element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')) AND a._retired = ''3000-01-01''
				WHERE p._retired = ''3000-01-01''
					AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1) --Няма активна стъпка 1 
					AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
					AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
					AND p.TypeGid in (SELECT [Gid] FROM Nomenclature WHERE [Type] = ''Process'' AND [_retired] = ''3000-01-01'' 
						AND [Code] IN (25, 26, 34) AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR [Gid] IN (SELECT Element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))))
				
				UNION ALL

				SELECT COUNT_BIG(*) Rows
				FROM Process p
					inner join Document_Modified doc on doc.ProcessGid = p.Gid
					and doc.RowStatusGid = 72
					inner join Fund_Modified fund on fund.LGid = doc.FundLGid
						AND (''' + ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')) + 
							N''' = ''NULL'' OR fund.Number = ''' + 
							ISNULL(@FundNumber,  N'NULL') + N''')
					INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
				WHERE p._retired = ''3000-01-01''
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
					AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1) --Няма активна стъпка 1
					AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
					AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR p.TypeGid in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '','')))
			) t
		';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	DECLARE @localQueryWhereClause VARCHAR(MAX) = '
		AND p.Completed = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR ((select convert(varchar(4), a.Code, 104)) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND (''' + ISNULL(@FundNumber, N'NULL') + N''' = ''NULL'' OR f.Number = ''' + ISNULL(@FundNumber, N'NULL') +  N''')
			AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR CAST(p.CreatedBy AS VARCHAR(50)) in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
			AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeCodesInternal + ''', '',''))) OR pt.Id in (select element from dbo.SplitString(''' + @ProcessTypeCodesInternal + ''', '','')))
	';
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT SUM(Rows) as TotalRows FROM
			(
				SELECT COUNT_BIG(*) Rows FROM (
					SELECT DISTINCT 
						NULL AS FundId,
						cast(d.SystemIdentifier as nvarchar(50)) AS DocumentId,
						p.Id AS ProcessId,
						''Document'' AS EntityType
					FROM v_Documents d 
					INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
					INNER JOIN Funds f ON d.FundSystemIdentifier = f.SystemIdentifier
					INNER JOIN Process p ON p.DocumentSystemIdentifier = d.SystemIdentifier AND p.Deleted = 0 AND p.Completed = 0
					INNER JOIN AspNetUsers u ON u.Id = p.CreatedBy AND u.Deleted = 0
					LEFT JOIN N.ProcessTypes pt ON pt.Id = p.ProcessTypeId
					LEFT JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode
					INNER JOIN ProcessTimeline ptl ON ptl.ProcessId = p.Id AND ptl.completed = 0
					--INNER JOIN N.ProcessSteps ps ON ps.Id = ptl.StepTypeId
					WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0'   
						+ @localQueryWhereClause + '
				) t1

				UNION

				SELECT COUNT_BIG(*) Rows FROM (
					SELECT DISTINCT
						f.SystemIdentifier AS FundId,
						NULL AS DocumentId,
						p.Id AS ProcessId,
						''Fund'' AS EntityType
					FROM v_Funds f 
					INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
					INNER JOIN Process p ON p.FundSystemIdentifier = f.SystemIdentifier AND p.Deleted = 0 AND p.Completed = 0
					INNER JOIN AspNetUsers u ON u.Id = p.CreatedBy AND u.Deleted = 0
					LEFT JOIN N.ProcessTypes pt ON pt.Id = p.ProcessTypeId
					LEFT JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode
					INNER JOIN ProcessTimeline ptl ON ptl.ProcessId = p.Id AND ptl.completed = 0
					--INNER JOIN N.ProcessSteps ps ON ps.Id = ptl.StepTypeId
					WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0'
						+ @localQueryWhereClause + '
				) t2
			) t'
		;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteRowsTable TABLE ( 
				TotalRows bigint NULL
			);

			INSERT INTO @remoteRowsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteRowsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
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

CREATE OR ALTER PROCEDURE [dbo].[GetDigitalDocumentsUsageReport] 
	@Statuses nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @condition VARCHAR(MAX) = '
		INNER JOIN Archives a ON a.Id = do.ArchiveId AND a.Deleted = 0
		INNER JOIN Funds f ON f.SystemIdentifier = do.FundSystemIdentifier
		INNER JOIN Inventories i ON i.SystemIdentifier = do.InventorySystemIdentifier
		INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = do.ArchivalEntitySystemIdentifier
		INNER JOIN Documents d ON d.SystemIdentifier = do.DocumentSystemIdentifier AND d.StatusCode <> ''12''-- 12 - отчислени
		INNER JOIN DigitalObjectReviews dor ON dor.DigitalObjectSystemIdentifier = do.SystemIdentifier
		LEFT JOIN AspNetUsers e ON e.Id = dor.UserSystemIdentifier AND e.UserProfileType =''EMP''
		LEFT JOIN AspNetUsers r ON r.Id = dor.UserSystemIdentifier AND r.UserProfileType = ''RRR''
		LEFT JOIN [N].[FundDescriptionLevel] fdl ON f.DescriptionLevelCode = fdl.Code
		WHERE do.ExternalIdentifier IS NULL AND do.HasExternalSource = 0 AND do.Deleted = 0 AND do.StatusCode <> ''12''-- 12 - отчислени
			AND (e.UserProfileType IS NOT NULL OR r.UserProfileType IS NOT NULL)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(dor.Date as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(dor.Date as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
	';

	DECLARE @condition1 VARCHAR(MAX) = '
		INNER JOIN Archives a1 ON a1.Id = do1.ArchiveId AND a1.Deleted = 0
		INNER JOIN Funds f1 ON f1.SystemIdentifier = do1.FundSystemIdentifier
		INNER JOIN ArchivalEntities ae1 ON ae1.SystemIdentifier = do1.ArchivalEntitySystemIdentifier
		INNER JOIN Documents d1 ON d1.SystemIdentifier = do1.DocumentSystemIdentifier AND d1.StatusCode <> ''12''-- 12 - отчислени
		INNER JOIN DigitalObjectReviews dor1 ON dor1.DigitalObjectSystemIdentifier = do1.SystemIdentifier
		LEFT JOIN AspNetUsers e1 ON e1.Id = dor1.UserSystemIdentifier AND e1.UserProfileType =''EMP''
		LEFT JOIN AspNetUsers r1 ON r1.Id = dor1.UserSystemIdentifier AND r1.UserProfileType = ''RRR''
		LEFT JOIN [N].[FundDescriptionLevel] fdl1 ON f1.DescriptionLevelCode = fdl1.Code
		WHERE do1.ExternalIdentifier IS NULL AND do1.HasExternalSource = 0 AND do1.Deleted = 0 AND do1.StatusCode <> ''12''-- 12 - отчислени
			AND f.SystemIdentifier = do1.FundSystemIdentifier
			AND (e1.UserProfileType IS NOT NULL OR r1.UserProfileType IS NOT NULL)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a1.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f1.StatusCode) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(dor1.Date as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(dor1.Date as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
	';

	DECLARE @sql VARCHAR(MAX) = 
		'SELECT
			a.Name AS Archive,
			convert(varchar(50), d.SystemIdentifier, 104) AS DocumentSystemIdentifier,
			f.DescriptionLevelCode AS FundDescriptionLevelCode,
			f.Number AS FundNumber,
			i.Number AS InventoryNumber,
			ae.Number AS ArchivalEntityNumber,
			convert(varchar, dor.Date, 104) AS UsageDate,
			e.UserName AS Employee,
			r.UserName AS Reader,
			(
				SELECT COUNT(*) FROM 
				(
					SELECT ae1.SystemIdentifier FROM DigitalObjects do1	
					' + @condition1 + '
					GROUP BY ae1.SystemIdentifier
				) t
			) AS ArchivalEntitiesOfFundCount,
			(
				SELECT COUNT(*) FROM 
				(
					SELECT d1.SystemIdentifier FROM DigitalObjects do1	
					' + @condition1 + '
					GROUP BY d1.SystemIdentifier
				) t
			) AS DocumentsOfFundCount,
			(
				SELECT SUM(FileSize) FROM 
				(
					SELECT 
						do1.SystemIdentifier,
						do1.FileSize
					FROM DigitalObjects do1	
					' + @condition1 + '
					GROUP BY do1.FileSize, do1.SystemIdentifier
				) t
			) AS Size, 
			--xxx AS TotalDurationPerFund,  - тази колона не може за момента да се добави, 
			f.NumberNumeric AS FundIntNumber,
			i.NumberNumeric AS InventoryIntNumber,
			ae.NumberNumeric AS ArchivalEntityIntNumber,
			d.Number AS DocumentNumber,
			a.SortOrder AS ArchiveSortOrder
			--,do.SystemIdentifier AS DOSystemIdentifier
			--,d.SystemIdentifier AS DocSystemIdentifier
			--,ae.SystemIdentifier AS AESystemIdentifier
			--,f.SystemIdentifier AS FundSystemIdentifier
		FROM DigitalObjects do
		' + @condition + '
		ORDER BY ArchiveSortOrder, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchivalEntityIntNumber, ArchivalEntityNumber, DocumentNumber ASC
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY
	';

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetDigitalDocumentsUsageReportSummary] 
	@Statuses nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @employee VARCHAR(MAX) = '
		INNER JOIN AspNetUsers upt ON upt.Id = dor.UserSystemIdentifier AND upt.UserProfileType =''EMP''
	';
	DECLARE @reader VARCHAR(MAX) = '
		INNER JOIN AspNetUsers upt ON upt.Id = dor.UserSystemIdentifier AND upt.UserProfileType = ''RRR''
	';

	DECLARE @condition VARCHAR(MAX) = '
		INNER JOIN Archives a ON a.Id = do.ArchiveId AND a.Deleted = 0
		INNER JOIN Funds f ON f.SystemIdentifier = do.FundSystemIdentifier
		INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = do.ArchivalEntitySystemIdentifier
		INNER JOIN Documents d ON d.SystemIdentifier = do.DocumentSystemIdentifier AND d.StatusCode <> ''12''-- 12 - отчислени
		INNER JOIN DigitalObjectReviews dor ON dor.DigitalObjectSystemIdentifier = do.SystemIdentifier
		UserTypeCondition
		WHERE do.ExternalIdentifier IS NULL AND do.HasExternalSource = 0 AND do.Deleted = 0 AND do.StatusCode <> ''12''-- 12 - отчислени
			AND (upt.UserProfileType IS NOT NULL OR upt.UserProfileType IS NOT NULL)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(dor.Date as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(dor.Date as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
	';

	DECLARE @userTypeEmployeeCondition VARCHAR(MAX) = REPLACE(@condition, 'UserTypeCondition', @employee);
	DECLARE @userTypeReaderCondition VARCHAR(MAX) = REPLACE(@condition, 'UserTypeCondition', @reader);

	DECLARE @sql VARCHAR(max) = '
		DECLARE @result TABLE (
			RowType NVARCHAR(50),
			FundsCount INT null,
			ArchivalEntitiesOfFundCount INT null,
			DocumentsOfFundCount INT null,
			Size BIGINT null
		);

		INSERT INTO @result  
			SELECT * FROM 
			(
				SELECT 
					(select ''Служител'') AS RowType,
					(
						SELECT COUNT(*) FROM 
						(
							SELECT f.SystemIdentifier FROM DigitalObjects do		
							' + @userTypeEmployeeCondition + '
							GROUP BY f.SystemIdentifier
						) t
					) AS FundsCount,
					(
						SELECT COUNT(*) FROM 
						(
							SELECT ae.SystemIdentifier FROM DigitalObjects do		
							' + @userTypeEmployeeCondition + '
							GROUP BY ae.SystemIdentifier
						) t
					) AS ArchivalEntitiesOfFundCount,
					(
						SELECT COUNT(*) FROM 
						(
							SELECT d.SystemIdentifier FROM DigitalObjects do		
							' + @userTypeEmployeeCondition + ' 
							GROUP BY d.SystemIdentifier
						) t
					) AS DocumentsOfFundCount,
					(
						SELECT SUM(FileSize) FROM 
						(
							SELECT 
								do.SystemIdentifier, 
								do.FileSize 
							FROM DigitalObjects do		
							' + @userTypeEmployeeCondition + ' 
							GROUP BY do.SystemIdentifier, do.FileSize
						) t
					) AS Size
			) t1;

		INSERT INTO @result  
			SELECT * FROM 
			(
				SELECT 
					(select ''Читател'') AS RowType,
					(
						SELECT COUNT(*) FROM 
						(
							SELECT f.SystemIdentifier FROM DigitalObjects do		
							' + @userTypeReaderCondition + '
							GROUP BY f.SystemIdentifier
						) t
					) AS FundsCount,
					(
						SELECT COUNT(*) FROM 
						(
							SELECT ae.SystemIdentifier FROM DigitalObjects do		
							' + @userTypeReaderCondition + '
							GROUP BY ae.SystemIdentifier
						) t
					) AS ArchivalEntitiesOfFundCount,
					(
						SELECT COUNT(*) FROM 
						(
							SELECT d.SystemIdentifier FROM DigitalObjects do		
							' + @userTypeReaderCondition + ' 
							GROUP BY d.SystemIdentifier
						) t
					) AS DocumentsOfFundCount,
					(
						SELECT SUM(FileSize) FROM 
						(
							SELECT 
								do.SystemIdentifier, 
								do.FileSize 
							FROM DigitalObjects do		
							' + @userTypeEmployeeCondition + ' 
							GROUP BY do.SystemIdentifier, do.FileSize
						) t
					) AS Size 
			) t2;

		INSERT INTO @result  
			SELECT * FROM 
			(
				SELECT 
					(select ''Общо'') AS RowType,
					(
						SELECT SUM(FundsCount) FROM (SELECT FundsCount FROM @result) ft
					) AS FundsCount,
					(
						SELECT SUM(ArchivalEntitiesOfFundCount) FROM (SELECT ArchivalEntitiesOfFundCount FROM @result) aet
					) AS ArchivalEntitiesOfFundCount,
					(
						SELECT SUM(DocumentsOfFundCount) FROM (SELECT DocumentsOfFundCount FROM @result) dt
					) AS DocumentsOfFundCount,
					(
						SELECT SUM(Size) FROM (SELECT Size FROM @result) dt
					) AS Size
			) t3;

		SELECT * FROM @result;
	';

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetDigitalDocumentsUsageReportTotalRows] 
	@Statuses nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(max) = '
		SELECT
			COUNT_BIG(*) TotalRows
		FROM DigitalObjects do
		INNER JOIN Archives a ON a.Id = do.ArchiveId AND a.Deleted = 0
		INNER JOIN Funds f ON f.SystemIdentifier = do.FundSystemIdentifier
		INNER JOIN Inventories i ON i.SystemIdentifier = do.InventorySystemIdentifier
		INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = do.ArchivalEntitySystemIdentifier
		INNER JOIN Documents d ON d.SystemIdentifier = do.DocumentSystemIdentifier AND d.StatusCode <> ''12''-- 12 - отчислени
		INNER JOIN DigitalObjectReviews dor ON dor.DigitalObjectSystemIdentifier = do.SystemIdentifier
		LEFT JOIN AspNetUsers e ON e.Id = dor.UserSystemIdentifier AND e.UserProfileType =''EMP''
		LEFT JOIN AspNetUsers r ON r.Id = dor.UserSystemIdentifier AND r.UserProfileType = ''RRR''
		LEFT JOIN [N].[FundDescriptionLevel] fdl ON f.DescriptionLevelCode = fdl.Code
		WHERE do.ExternalIdentifier IS NULL AND do.HasExternalSource = 0 AND do.Deleted = 0 AND do.StatusCode <> ''12''-- 12 - отчислени
			AND (e.UserProfileType IS NOT NULL OR r.UserProfileType IS NOT NULL)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(dor.Date as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(dor.Date as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
	';

	exec (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetCardForm1External] 
	@LinkedServer NVARCHAR(50),
	@FundLGid INT = NULL,
	@RowsOfPage INT = 5000,
	@Page INT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @resultTable TABLE
		(
			LGid INT NULL, -- за тест
			--Gid INT NULL, -- за тест
			YearCreatedAndInventoryNumber VARCHAR(50) NULL,
			EndDates VARCHAR(50) NULL,
			InventorizedCount VARCHAR(50) NULL,  -- да се види как се получават
			UninventorizedCount VARCHAR(50) NULL,   -- да се види как се получават
			DeductedCount VARCHAR(50) NULL,  -- да се види как се получават
			AvailableArchivalEntitiesCountAndSize VARCHAR(50) NULL,
			MicrofilmedArchivalOfEntityCount INT NULL,
			NegativeFramesCount INT NULL,
			PositiveFramesCount INT NULL,
			PhonoDocumentsCount INT NULL,
			PhotoDocumentsCount INT NULL,
			VideoDocumentsCount INT NULL,
			DigitalDocumentCount INT NULL,
			IntNumber INT NULL,
			Number NVARCHAR(256) NULL,
			_id INT NULL
		);		
				
		SET NOCOUNT ON;
		SET FMTONLY OFF;	

		DECLARE @inventoriesTable TABLE
		(
			LGid INT NULL,
			RowNumber INT NOT NULL
		);


		INSERT INTO @inventoriesTable 
			SELECT 
				LGid, 
				ROW_NUMBER() OVER(ORDER BY LGid ASC) AS RowNumber
			FROM Inventory
			WHERE FundLGid = ''' + CONVERT(VARCHAR(10), @FundLGid) + ''' AND _retired = ''3000-01-01''
			GROUP BY LGid;

		DECLARE @Counter INT; 
		SET @Counter = 1;
		DECLARE @inventoriesCount INT = 
		( 
			SELECT COUNT(LGid) c 
			FROM @inventoriesTable
		);
		WHILE (@Counter <= @inventoriesCount)
		BEGIN
			DECLARE @currentLGid INT = 
			(
				SELECT LGid 
				FROM @inventoriesTable
				WHERE RowNumber = @Counter
			);

			-- Insert first inventory state row
			INSERT INTO @resultTable
				SELECT TOP(1)
					@currentLGid AS LGid, 
					CONVERT(VARCHAR(50), YEAR(i1.CreationDate), 104) 
						+ '';'' + ISNULL(i1.Number, '''') AS YearCreatedAndInventoryNumber,
					COALESCE
					(
						CONVERT(VARCHAR(10), i1.StartDateYear, 104) + '';'' + CONVERT(VARCHAR(100), i1.EndDateYear, 104),
						CONVERT(VARCHAR(10), i1.StartDateYear, 104) + '';'',
						'';'' + CONVERT(VARCHAR(100), i1.EndDateYear, 104)
					) AS EndDates,
					CASE
						WHEN i1.LevelOfDescriptionGid IN (2171, 2372) THEN i1.AECount
						ELSE NULL
					END AS InventorizedCount,
					CASE
						WHEN i1.LevelOfDescriptionGid = 2172 THEN i1.AECount
						ELSE NULL
					END AS UnInventorizedCount,
					NULL AS DeductedCount,
					CONVERT(VARCHAR(50), i1.AECount, 104) 
						+ '';'' + CONVERT(VARCHAR(50), i1.LinearMeter, 104) AS AvailableArchivalEntitiesCountAndSize,
					i1.CopyMicrofilmAE AS MicrofilmedArchivalOfEntityCount, -- може би е CopyCapturedAE или CopyMicrofilmAE
					i1.CopyNegativFrames AS NegativeFramesCount, -- не съм напълно сигурен за това, но не знам кое друго е
					i1.CopyPositiveFrames AS PositiveFramesCount, -- не съм напълно сигурен за това, но не знам кое друго е
					i1.AEFonoDocsCount AS PhonoDocumentsCount,
					i1.AEPhotoDocsCount AS PhotoDocumentsCount,
					i1.AEVideoAudioDocsCount AS VideoDocumentsCount,
					i1.AEElectrDocsCount AS DigitalDocumentsArchivalOfEntityCountExternal, -- има и колона CopyDigitizedAE
					i1.IntNumber,
					i1.Number,
					i1._id
				FROM (
					SELECT 
						ROW_NUMBER() OVER(ORDER BY Gid ASC) AS RowNumber,
						LGid, 
						CreationDate, 
						Number, 
						StartDateYear, 
						EndDateYear, 
						AECount,
						LinearMeter, 
						LevelOfDescriptionGid, 
						CopyMicrofilmAE,
						CopyNegativFrames,
						CopyPositiveFrames,
						AEFonoDocsCount,
						AEPhotoDocsCount,
						AEVideoAudioDocsCount,
						AEElectrDocsCount,
						IntNumber,
						_id
					FROM Inventory
					WHERE LGid = @currentLGid
						AND EXISTS (SELECT 1 FROM Inventory i0 WHERE i0._retired = ''3000-01-01'' AND LGid = i0.LGid) -- няма активен процес
				) i1;
		
			INSERT INTO @resultTable
				SELECT  
					@currentLGid AS LGid,
					--i1._id, -- test
					CONVERT(VARCHAR(50), YEAR(i2.CreationDate), 104) 
						+ '';'' + ISNULL(i2.Number, '''') AS YearCreatedAndInventoryNumber,
					COALESCE
					(
						CONVERT(VARCHAR(10), i2.StartDateYear, 104) + '';'' + CONVERT(VARCHAR(100), i2.EndDateYear, 104),
						CONVERT(VARCHAR(10), i2.StartDateYear, 104) + '';'',
						'';'' + CONVERT(VARCHAR(100), i2.EndDateYear, 104)
					) AS EndDates,
					CASE
						WHEN ISNULL(i2.AECount, 0) - ISNULL(i1.AECount, 0) > 0 AND i2.LevelOfDescriptionGid IN (2171, 2372) 
							THEN CONVERT(VARCHAR(50), ABS(ISNULL(i2.AECount, 0) - ISNULL(i1.AECount, 0))) 
								+ '';'' + CONVERT(VARCHAR(50), ABS(ISNULL(i2.LinearMeter, 0) - ISNULL(i1.LinearMeter, 0)))
						ELSE NULL
					END AS InventorizedCount,
					CASE
						WHEN ISNULL(i2.AECount, 0) - ISNULL(i1.AECount, 0) > 0 AND i2.LevelOfDescriptionGid = 2172
							THEN CONVERT(VARCHAR(50), ABS(ISNULL(i2.AECount, 0) - ISNULL(i1.AECount, 0))) 
								+ '';'' + CONVERT(VARCHAR(50), ABS(ISNULL(i2.LinearMeter, 0) - ISNULL(i1.LinearMeter, 0)))
						ELSE NULL
					END AS UninventorizedCount,
					CASE
						WHEN ISNULL(i2.AECount, 0) - ISNULL(i1.AECount, 0) < 0
							THEN CONVERT(VARCHAR(50), ABS(ISNULL(i2.AECount, 0) - ISNULL(i1.AECount, 0))) 
								+ '';'' + CONVERT(VARCHAR(50), ABS(ISNULL(i2.LinearMeter, 0) - ISNULL(i1.LinearMeter, 0)))
						ELSE NULL
					END AS DeductedCount,
					CONVERT(VARCHAR(50), i2.AECount, 104) 
						+ '';'' + CONVERT(VARCHAR(50), i2.LinearMeter, 104) AS AvailableArchivalEntitiesCountAndSize,
					i2.CopyMicrofilmAE AS MicrofilmedArchivalOfEntityCount, -- може би е CopyCapturedAE или CopyMicrofilmAE
					i2.CopyNegativFrames AS NegativeFramesCount, -- не съм напълно сигурен за това, но не знам кое друго е
					i2.CopyPositiveFrames AS PositiveFramesCount, -- не съм напълно сигурен за това, но не знам кое друго е
					i2.AEFonoDocsCount AS PhonoDocumentsCount,
					i2.AEPhotoDocsCount AS PhotoDocumentsCount,
					i2.AEVideoAudioDocsCount AS VideoDocumentsCount,
					i2.AEElectrDocsCount AS DigitalDocumentsArchivalOfEntityCountExternal, -- има и колона CopyDigitizedAE
					i2.IntNumber,
					i2.Number,
					i2._id
				FROM (
					SELECT 
						ROW_NUMBER() OVER(ORDER BY _id ASC) AS RowNumber, 
						LGid, 
						--_id, -- test
						CreationDate, 
						Number, 
						StartDateYear, 
						EndDateYear, 
						AECount,
						LinearMeter 
					FROM Inventory
					WHERE LGid = @currentLGid
						AND EXISTS (SELECT 1 FROM Inventory i0 WHERE i0._retired = ''3000-01-01'' AND LGid = i0.LGid) -- няма активен процес
				) i1
				INNER JOIN 
				(
					SELECT 
						ROW_NUMBER() OVER(ORDER BY _id ASC) AS RowNumber, 
						LGid, 
						CreationDate, 
						Number, 
						StartDateYear, 
						EndDateYear, 
						AECount,
						LinearMeter, 
						LevelOfDescriptionGid, 
						CopyMicrofilmAE,
						CopyNegativFrames,
						CopyPositiveFrames,
						AEFonoDocsCount,
						AEPhotoDocsCount,
						AEVideoAudioDocsCount,
						AEElectrDocsCount,
						IntNumber,
						_id
					FROM Inventory
					WHERE LGid = @currentLGid
						AND EXISTS (SELECT 1 FROM Inventory i0 WHERE i0._retired = ''3000-01-01'' AND LGid = i0.LGid) -- няма активен процес
				) i2 ON 
				i2.RowNumber=i1.RowNumber + 1 
					AND (ISNULL(i2.AECount, 0) - ISNULL(i1.AECount, 0) <> 0 OR ABS(ISNULL(i2.LinearMeter, 0) - ISNULL(i1.LinearMeter, 0)) > 0.01) 
			SET @Counter  = @Counter  + 1;
		END

		SELECT * FROM @resultTable
		ORDER BY IntNumber, Number, _id
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY;
	'; 

	SET @sql = REPLACE(@sql, '''', '''''');

	EXEC ('SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''')');
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetCardForm1ExternalTotalRows] 
	@LinkedServer NVARCHAR(50),
	@FundLGid INT = NULL,
	@RowsOfPage INT = 5000,
	@Page INT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @resultTable TABLE
		(
			Rows INT NULL
		);		
				
		SET NOCOUNT ON;
		SET FMTONLY OFF;	

		DECLARE @inventoriesTable TABLE
		(
			LGid INT NULL,
			RowNumber INT NOT NULL
		);

		INSERT INTO @inventoriesTable 
			SELECT 
				LGid, 
				ROW_NUMBER() OVER(ORDER BY LGid ASC) AS RowNumber
			FROM Inventory
			WHERE FundLGid = ''' + CONVERT(VARCHAR(10), @FundLGid) + ''' AND _retired = ''3000-01-01''
			GROUP BY LGid;

		DECLARE @Counter INT; 
		SET @Counter = 1;
		DECLARE @inventoriesCount INT = 
		( 
			SELECT COUNT(LGid) c 
			FROM @inventoriesTable
		);
		WHILE (@Counter <= @inventoriesCount)
		BEGIN
			DECLARE @currentLGid INT = 
			(
				SELECT LGid 
				FROM @inventoriesTable
				WHERE RowNumber = @Counter
			);

			INSERT INTO @resultTable
				SELECT TOP(1) 1
				FROM (
					SELECT 
						ROW_NUMBER() OVER(ORDER BY Gid ASC) AS RowNumber,
						LGid
					FROM Inventory
					WHERE LGid = @currentLGid
						AND EXISTS (SELECT 1 FROM Inventory i0 WHERE i0._retired = ''3000-01-01'' AND LGid = i0.LGid) -- няма активен процес
				) i1;
		
			INSERT INTO @resultTable
				SELECT  
					COUNT_BIG(*)
				FROM 
				(
					SELECT 
						ROW_NUMBER() OVER(ORDER BY _id ASC) AS RowNumber, 
						LGid,
						AECount,
						LinearMeter
					FROM Inventory
					WHERE LGid = @currentLGid
				) i1
				INNER JOIN 
				(
					SELECT 
						ROW_NUMBER() OVER(ORDER BY _id ASC) AS RowNumber, 
						LGid,
						AECount,
						LinearMeter
					FROM Inventory
					WHERE LGid = @currentLGid
						AND EXISTS (SELECT 1 FROM Inventory i0 WHERE i0._retired = ''3000-01-01'' AND LGid = i0.LGid) -- няма активен процес
				) i2 ON 
				i2.RowNumber=i1.RowNumber + 1 
					AND (ISNULL(i2.AECount, 0) - ISNULL(i1.AECount, 0) <> 0 OR ABS(ISNULL(i2.LinearMeter, 0) - ISNULL(i1.LinearMeter, 0)) > 0.01); 
			SET @Counter  = @Counter  + 1; 
		END

		SELECT ISNULL(SUM(CAST(Rows AS BIGINT)), 0) AS TotalRows FROM @resultTable; -- тук няма нужда от bigint, но това се очаква
	'; 

	SET @sql = REPLACE(@sql, '''', '''''');

	EXEC ('SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''')');
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetCardForm1FundDataExternal] 
	@LinkedServer NVARCHAR(50),
	@LGid INT = NULL,
	@RowsOfPage INT = 5000,
	@Page INT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX) = '';

	IF @LGid IS NOT NULL
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '	
			SELECT
				a.Name as Archive,
				a.Code as ArchiveCode,
				fund.Number,
				fund.Title,
				(SELECT Value FROM Nomenclature n WHERE n._retired=''3000-01-01'' AND n.Type = ''FundType'' AND n.Gid = fund.TypeGid) AS Type,
				convert(varchar, fund.CreationDate, 104) AS CreationDate,
				(
					select Value2 + '';''
					from  Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''IndustryIndex''
					FOR XML path(''''), elements
				) AS IndustryIndex,
				(select Value + '';''
					from  Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''MethodOfAcquisition''
					FOR XML path(''''), elements
				) as MethodOfAcquisition,
				fund.InvetoryCount AS InventoriesCount,
				fund.AECount AS ArchivalEntitiesCount,
				fund.LinearMeters
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE LGid = ''' + CONVERT(VARCHAR(10), @LGid) + ''';
		';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');	

		EXEC ('SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');')	
		RETURN;
	END
END
GO

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

CREATE OR ALTER PROCEDURE [dbo].[GetCardForm1InternalTotalRows] 
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
			Rows INT NULL
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
		FROM [DAA].[dbo].[InventoryDrafts] 
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
				SELECT TOP(1) 1
				FROM (
					SELECT 
						SystemIdentifier
					FROM [DAA].[dbo].[InventoryDrafts]
					WHERE SystemIdentifier=@currentSystemIdentifier
				) i1;
		
			INSERT INTO @resultTable
				SELECT  
					COUNT_BIG(*)
				FROM (
					SELECT 
						ROW_NUMBER() OVER(ORDER BY Id ASC) AS RowNumber, 
						SystemIdentifier,
						ArchivalEntityCount, 
						Bytes
					FROM [DAA].[dbo].[InventoryDrafts]
					WHERE SystemIdentifier = @currentSystemIdentifier 
						AND Deleted = 0 
						AND ReadOnly = 1
				) i1
				INNER JOIN 
				(
					SELECT
						ROW_NUMBER() OVER(ORDER BY Id ASC) AS RowNumber, 
						SystemIdentifier,
						ArchivalEntityCount, 
						Bytes
					FROM [DAA].[dbo].[InventoryDrafts] 
					WHERE SystemIdentifier = @currentSystemIdentifier 
						AND Deleted = 0 
						AND ReadOnly = 1
				) i2 ON 
				i2.RowNumber=i1.RowNumber + 1 
					AND (ISNULL(i2.ArchivalEntityCount, 0) - ISNULL(i1.ArchivalEntityCount, 0) <> 0 OR ISNULL(i2.Bytes, 0) - ISNULL(i1.Bytes, 0) <> 0) 
			SET @Counter  = @Counter  + 1;
		END

		SELECT ISNULL(SUM(CAST(Rows AS BIGINT)), 0) AS TotalRows FROM @resultTable; -- тук няма нужда от bigint, но това се очаква
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
		(select Text + ';'
			from NomenclatureValues nv
			join N.Nomenclatures n1 on 
				nv.EntityType='fund' 
				and nv.Deleted=0
				and n1.Deleted=0
				and nv.NomenclatureCode='INDUSTRY_TYPE'
				and nv.EntityId=fund.Id
				and n1.Id=nv.ValueId
			FOR XML path(''), elements) as IndustryIndex,
		n1.Text as MethodOfAcquisition,
		fsi.EnrolledInventoryCount AS InventoriesCount,
		fsi.EnrolledArchivalEntityCount AS ArchivalEntitiesCount,
		fsi.EnrolledBytes AS Size
	FROM Funds as fund
	LEFT JOIN N.Nomenclatures n1 ON fund.AcquisitionMethodId = n1.Id
	LEFT JOIN v_FundSizeInfo as fsi ON fund.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
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
	@Archives nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
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
		order by Archive
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
		DECLARE @remoteQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
			SELECT
				a.Name as Archive,
				(SELECT Value FROM Nomenclature n5 where n5._retired = ''3000-01-01'' and n5.Gid = fund.LevelOfDescriptionGid ) as FundDescriptionLevel,
				fund.Number as FundNumber,
				fund.Title as FundTitle,
				inv.Number as InventoryNumber,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = inv.LevelOfDescriptionGid) as InventoryDescriptionLevel,
				(SELECT Value FROM Nomenclature WHERE _retired = ''3000-01-01'' and Gid = inv.StatusGid) as [Status],
				ISNULL(inv.AECount, 0) as AeCount,
				(SELECT COUNT(*) FROM ArchiveEntity_Modified as ae where InventoryLGid = inv.LGid and ISNUMERIC(RIGHT(ae.Number,1)) = 0) as AeWithCharCount,
				(SELECT COUNT(*) FROM ArchiveEntity_Modified as ae where InventoryLGid = inv.LGid and ISNUMERIC(RIGHT(ae.Number,1)) = 0) as EDocumentsCount,
				--null as EDocumentsCount,
				round(cast(isnull(inv.LinearMeter, 0) as decimal(18, 2)) ,2) as LinearMeters,
				NULL as FileFormat,
				NULL as Duration,
				null as Bytes,
				null as SystemIdentifier,
				inv.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource
				FROM Inventory as inv
				inner join Fund_Modified as fund on inv.FundLGid = fund.LGid
				inner join Archive a on inv.ArchiveGid = a.Gid
			WHERE
				fund._retired = ''3000-01-01'' AND inv.LevelOfDescriptionGid = 2171-- Inventory
				AND inv._retired = ''3000-01-01''
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (fund.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (inv.TextDate = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' = ''null'') OR (cast(inv.StartDate as date) >= cast(''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' = ''null'') OR (cast(inv.EndDate as date) <= cast(''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(inv.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(inv.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
					OR ((SELECT Code FROM Nomenclature where _retired = ''3000-01-01'' and Gid = inv.StatusGid) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives + ''', '',''))) OR (a.Code in (select element from dbo.SplitString(''' + @Archives + ''', '',''))))
		');
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		DECLARE @localQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
			SELECT
				a.[Name] as Archive
				,fdl.[Text] as FundDescriptionLevel
				,f.Number as FundNumber
				,f.Title as FundTitle
				,i.Number as InventoryNumber
				,idl.[Text] as InventoryDescriptionLevel
				,s.[Text] as [Status]
				,isi.EnrolledArchivalEntityCount as AeCount
				,(SELECT COUNT(*) FROM v_PublicArchivalEntities as ae where InventorySystemIdentifier = i.SystemIdentifier and ISNUMERIC(RIGHT(ae.Number,1)) = 0) as AeWithCharCount
				,isi.EnrolledDocumentCount as EDocumentsCount
				,null as LinearMeters
				,isi.FileTypes as FileFormat
				,(select sum(d.Duration) from Documents d where i.SystemIdentifier = d.InventorySystemIdentifier) as Duration
				,ISNULL(isi.EnrolledBytes, 0) as Bytes
				,i.SystemIdentifier
				,i.ExternalIdentifier
				,i.HasExternalSource
		     FROM v_PublicInventories as i
			 LEFT JOIN v_InventorySizeInfo isi ON isi.InventorySystemIdentifier = i.SystemIdentifier AND isi.IsDraft = 0
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
			WHERE i.Deleted = 0 AND i.DescriptionLevelCode <> 6
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @Archives + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '','')) AND i.StatusCode not in (''4'', ''5'', ''9'', ''10'', ''11'', ''13'')) 
					OR (convert(varchar(4), i.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.ApproxmateChronologicalScope = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
				OR (cast(i.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
				OR (cast(i.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' = ''null'') 
				OR (try_cast(coalesce(
								convert(varchar, i.StartDateYear, 104) + ''.'' + convert(varchar, i.StartDateMonth, 104) + ''.'' + convert(varchar, i.StartDateDay, 104),
								convert(varchar, i.StartDateYear, 104) + ''.'' + convert(varchar, i.StartDateMonth, 104),
								convert(varchar, i.StartDateYear, 104)) as date) >= cast(''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' = ''null'') 
				OR (try_cast(coalesce(
								convert(varchar, i.EndDateYear, 104) + ''.'' + convert(varchar, i.EndDateMonth, 104) + ''.'' + convert(varchar, i.EndDateDay, 104),
								convert(varchar, i.EndDateYear, 104) + ''.'' + convert(varchar, i.EndDateMonth, 104),
								convert(varchar, i.EndDateYear, 104)) as date) <= cast(''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' as datetime2)))
		 GROUP BY a.[Name], fdl.[Text], f.Number, f.[Title], i.Number, idl.[Text], s.[Text], i.SystemIdentifier, i.Bytes, i.Id, isi.EnrolledDocumentCount, 
			isi.EnrolledArchivalEntityCount, isi.FileTypes, isi.EnrolledBytes , i.ExternalIdentifier, i.HasExternalSource
		');
	END

		IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				Archive nvarchar(255) NULL,
				FundDescriptionLevel nvarchar(255) NULL,
				FundNumber nvarchar(255) NULL,
				FundTitle nvarchar(max) NULL,
				InventoryNumber nvarchar(255) NULL,
				InventoryDescriptionLevel nvarchar(255) NULL,
				[Status] nvarchar(255) NULL,
				AeCount int NULL,
				AeWithCharCount int NULL,
				EDocumentsCount int NULL,
				LinearMeters decimal(18, 2) NULL,
				FileFormat nvarchar(max) NULL,
				Duration int NULL,
				Bytes bigint NULL,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
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
	@Archives nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
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
				Archive nvarchar(255) NULL,
				FundDescriptionLevel nvarchar(255) NULL,
				FundNumber nvarchar(255) NULL,
				FundTitle nvarchar(max) NULL,
				InventoryNumber nvarchar(255) NULL,
				InventoryDescriptionLevel nvarchar(255) NULL,
				[Status] nvarchar(255) NULL,
				AeCount int NULL,
				AeWithCharCount int NULL,
				EDocumentsCount int NULL,
				LinearMeters decimal(18, 2) NULL,
				FileFormat nvarchar(max) NULL,
				Duration int NULL,
				Bytes bigint NULL
			);

	INSERT INTO #temp(
				Archive,
				FundDescriptionLevel,
				FundNumber,
				FundTitle,
				InventoryNumber,
				InventoryDescriptionLevel,
				[Status],
				AeCount,
				AeWithCharCount,
				EDocumentsCount,
				LinearMeters,
				FileFormat,
				Duration,
				Bytes
			)
	EXEC [sp_GetInventoryReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page,
		@Archives,
		@Statuses,
		@FundNumber,
		@RegisteredFrom,
		@RegisteredTo,
		@ChronologicalScope,
		@ChronologicalScopeStartDate,
		@ChronologicalScopeEndDate

	SET @sql = '
	SELECT TOP 1
		COUNT_BIG(1) as InventoryCount,
		CAST(SUM(t.AeCount) as bigint) as AeCount,
		CAST(SUM(t.EDocumentsCount) as bigint) as EDocumentsCount,
		CAST(SUM(t.Duration) as bigint) as Duration,
		CAST(SUM(t.LinearMeters) as decimal(18, 2)) as LinearMeters,
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
	@Archives nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
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
				Archive nvarchar(255) NULL,
				FundDescriptionLevel nvarchar(255) NULL,
				FundNumber nvarchar(255) NULL,
				FundTitle nvarchar(max) NULL,
				InventoryNumber nvarchar(255) NULL,
				InventoryDescriptionLevel nvarchar(255) NULL,
				[Status] nvarchar(255) NULL,
				AeCount int NULL,
				AeWithCharCount int NULL,
				EDocumentsCount int NULL,
				LinearMeters decimal NULL,
				FileFormat nvarchar(max) NULL,
				Duration nvarchar(256) NULL,
				Bytes bigint NULL
			);

	INSERT INTO #temp(
				Archive,
				FundDescriptionLevel,
				FundNumber,
				FundTitle,
				InventoryNumber,
				InventoryDescriptionLevel,
				[Status],
				AeCount,
				AeWithCharCount,
				EDocumentsCount,
				LinearMeters,
				FileFormat,
				Duration,
				Bytes
			)
	EXEC [sp_GetInventoryReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page,
		@Archives,
		@Statuses,
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfRoughDocumentsReport]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 5000,
	@Page int = 1,
	@Archives nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null,
	@MethodsOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
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
			fund.Number as FundNumber,
			fund.Title as FundTitle,
			inv.CreatedOn as EntryDate,
			inv.Number as RoughInventoryNumber,
			STUFF((SELECT n.Value + ''; '' 
				   	 FROM Nomenclature as n 
					 JOIN ObjectNomenclature as onc 
					   ON n.Gid = onc.NomenclatureGid 
					WHERE onc._retired = ''3000-01-01'' 
						AND onc.FundGid = fund.Gid 
						AND n.Type = ''MethodOfAcquisition''
						FOR XML path(''''), elements), 1, 0, '''') as AcquisitionMethod,
			(SELECT Value FROM Nomenclature WHERE _retired = ''3000-01-01'' and Gid = inv.StatusGid) as [Status],
			round(isnull(cast(inv.LinearMeter as decimal(18,2)), 0),2) as LinearMeters,
			CAST(0 as bigint) as Bytes,
			null as SystemIdentifier,
			inv.LGid as ExternalIdentifier,
			CAST(1 as bit) as HasExternalSource
			FROM Inventory as inv
			inner join Fund_Modified as fund on inv.FundLGid = fund.LGid
			join Nomenclature as n on inv.LevelOfDescriptionGid = n.Gid
			WHERE
			fund._retired = ''3000-01-01''
			AND inv._retired = ''3000-01-01''
			AND n.Code = 6
			AND inv.StatusGid <> 13
			AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (inv.TextDate = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) 
				OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionGids + ''', '',''))) 
				OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionGids + ''', '',''))))
			AND ((''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' = ''null'') OR (cast(inv.StartDate as date) >= cast(''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' = ''null'') OR (cast(inv.EndDate as date) <= cast(''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(inv.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(inv.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives + ''', '',''))) OR ((select a.Code from Archive as a where a.Gid = inv.ArchiveGid) in (select element from dbo.SplitString(''' + @Archives + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) OR ((select n.Code from Nomenclature as n where n.Gid = inv.StatusGid and n.Type = ''Status'' and n._retired = ''3000-01-01'') in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			AND inv.LevelOfDescriptionGid in(
			2171, -- Inventory
			2172  -- InventoryRough
			)
		');
		--AND inv.StatusGid = 192
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		DECLARE @localQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
			SELECT
				''BG'' as CountryCode
				,a.[Name] as Archive
				,f.Number as FundNumber
				,f.Title as FundTitle
				,i.CreatedOn as EntryDate
				,i.Number as RoughInventoryNumber
				,(select n1.Text from N.Nomenclatures n1 where i.AcquisitionMethodId = n1.Id) as AcquisitionMethod
				,s.[Text] as [Status]
				,null as LinearMeters
				,ISNULL(CAST(isi.EnrolledBytes as bigint), 0) as Bytes
				,i.SystemIdentifier
				,i.ExternalIdentifier
				,i.HasExternalSource
		     FROM Inventories as i
		     JOIN [Archives] as a
		       ON i.ArchiveId = a.Id
		     JOIN v_PublicFunds as f
		       ON i.FundSystemIdentifier = f.SystemIdentifier
		     JOIN N.InventoryDescriptionLevel as idl
		       ON i.DescriptionLevelCode = idl.Code
		     JOIN N.[Status] as s
		       ON i.StatusCode = s.Code
			FULL OUTER JOIN v_PublicArchivalEntities as ae
			   ON i.SystemIdentifier = ae.InventorySystemIdentifier
			LEFT JOIN v_InventorySizeInfo isi ON isi.InventorySystemIdentifier = i.SystemIdentifier AND isi.IsDraft = 0
			WHERE idl.Code = 6 AND i.Deleted = 0 AND i.StatusCode <> 13
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @Archives + ''', '',''))))
				
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0
						and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
					OR ((select Code from N.Nomenclatures n1 where n1.Id = i.AcquisitionMethodId) in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '',''))) 
					OR (convert(varchar(4), i.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))

				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '','')) AND TypeCode not in (''4'', ''5'')) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = f.TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.ApproxmateChronologicalScope = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
				OR (cast(i.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
				OR (cast(i.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' = ''null'') 
				OR (try_cast(coalesce(
								convert(varchar, i.StartDateYear, 104) + ''.'' + convert(varchar, i.StartDateMonth, 104) + ''.'' + convert(varchar, i.StartDateDay, 104),
								convert(varchar, i.StartDateYear, 104) + ''.'' + convert(varchar, i.StartDateMonth, 104),
								convert(varchar, i.StartDateYear, 104)) as date) >= cast(''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' = ''null'') 
				OR (try_cast(coalesce(
								convert(varchar, i.EndDateYear, 104) + ''.'' + convert(varchar, i.EndDateMonth, 104) + ''.'' + convert(varchar, i.EndDateDay, 104),
								convert(varchar, i.EndDateYear, 104) + ''.'' + convert(varchar, i.EndDateMonth, 104),
								convert(varchar, i.EndDateYear, 104)) as date) <= cast(''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' as datetime2)))
		 GROUP BY a.[Name], f.Number, f.[Title], i.Number, i.CreatedOn, idl.[Text], s.[Text], i.SystemIdentifier, i.LinearMeters, isi.EnrolledBytes, i.ExternalIdentifier, i.HasExternalSource, i.AcquisitionMethodId
		');
		--AND i.StatusCode = 10
	END

		IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				CountryCode nvarchar(255) NULL,
				Archive nvarchar(255) NULL,
				FundNumber nvarchar(255) NULL,
				FundTitle nvarchar(max) NULL,
				EntryDate varchar(50) NULL,
				RoughInventoryNumber nvarchar(255) NULL,
				AcquisitionMethod nvarchar(max) NULL,
				[Status] nvarchar(255) NULL,
				LinearMeters decimal NULL,
				Bytes bigint NULL,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit

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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfRoughDocumentsReportCombined]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 5000,
	@Page int = 1,
	@Archives nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null,
	@MethodsOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
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
				FundNumber nvarchar(255) NULL,
				FundTitle nvarchar(max) NULL,
				EntryDate varchar(50) NULL,
				RoughInventoryNumber nvarchar(255) NULL,
				AcquisitionMethod nvarchar(max) NULL,
				[Status] nvarchar(255) NULL,
				LinearMeters decimal NULL,
				Bytes bigint NULL,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
			);

	INSERT INTO #temp(
				CountryCode,
				Archive,
				FundNumber,
				FundTitle,
				EntryDate,
				RoughInventoryNumber,
				AcquisitionMethod,
				[Status],
				LinearMeters,
				Bytes,
				SystemIdentifier,
				ExternalIdentifier,
				HasExternalSource
			)
	EXEC [sp_GetListOfRoughDocumentsReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page,
		@Archives,
		@FundTypeGids,
		@FundTypesInternal,
		@IndustryIndexGids,
		@IndustryIndexesInternal,
		@MethodsOfAcquisitionGids,
		@MethodsOfAcquisitionInternal,
		@Statuses,
		@RegisteredFrom,
		@RegisteredTo,
		@ChronologicalScope,
		@ChronologicalScopeStartDate,
		@ChronologicalScopeEndDate

	SET @sql = '
	SELECT TOP 1
		COUNT_BIG(t.FundNumber) as FundCount,
		COUNT_BIG(t.RoughInventoryNumber) as InventoryCount,
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfPartialReceiptsInArchiveReport]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@Archives nvarchar(max) = null,
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
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

	DECLARE @sqlFinalPart NVARCHAR(MAX) =  CONVERT(NVARCHAR(MAX),'
		order by CountryCode, Archive
		offset ') + CONVERT(NVARCHAR(10), @offset) +  CONVERT(NVARCHAR(MAX),' rows fetch next ') + CONVERT(NVARCHAR(10), @RowsOfPage) +  CONVERT(VARCHAR(MAX),' rows only');

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
				SELECT
					''BG'' as CountryCode,
					(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = fund.ArchiveGid) as Archive,
					fund.Number as FundNumber,
					fund.Title as FundTitle,
					convert(varchar(50), fund.CreationDate, 104) as CreationDate,
					fund.ImmediateSourceOfAcquisition,
					-- (SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.TypeGid) as FundType, отпада по забележка на Архивите
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
					fund.TextDate as ChronologicalScope,
					-- махат се по забележка от ИСДА
					--(isnull(convert(varchar, StartDateDay) + ''.'', '''') + isnull(convert(varchar, StartDateMonth) + ''.'', '''') + isnull(convert(varchar, StartDateYear), '''')) as ChronologicalScopeStartDate,
					--(isnull(convert(varchar, fund.EndDateDay) + ''.'', '''') + isnull(convert(varchar, fund.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, fund.EndDateYear), '''')) as ChronologicalScopeEndDate,
					fund.InvetoryCount as InventoryCount,
					fund.AeCount,
					round(isnull(fund.LinearMeters, 0),2) as LinearMeters,
					null as Size,
					null as Duration,
					null as DurationInt,
					null as EDocumentsCount,
					null as FileFormats,
					null as SystemIdentifier,
					fund.LGid as ExternalIdentifier,
					CAST(1 as bit) as HasExternalSource
				FROM Fund_Modified as fund
				INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
				WHERE fund._retired = ''3000-01-01''
					AND fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 2)
					AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives + ''', '',''))) OR a.Code in  (select element from dbo.SplitString(''' + @Archives + ''', '','')))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
						OR (select Code from Nomenclature where _retired=''3000-01-01'' and Gid = fund.StatusGid) in (select element from dbo.SplitString(''' + @Statuses + ''', '','')))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
					AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' as datetime2)))
					AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (fund.TextDate = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
					');

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
				SELECT
				''BG'' as CountryCode
				,a.Name as Archive
				,f.Number as FundNumber
				,f.Title as FundTitle
				,convert(varchar(50), f.CreatedOn, 104) as CreationDate
				,CONCAT(DocumentsProvider, '' / '', (select n1.Text from N.Nomenclatures n1 where f.AcquisitionMethodId = n1.Id)) as ImmediateSourceOfAcquisition
				--,f.TypeText as FundType отпада по забележка на Архивите
				,f.DocumentsDescription as DocumentProperties
				,f.Notes as Note
				,(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus
				,STUFF(
					(select ''; '' + n.Text 
						from N.Nomenclatures as n
						where n.Id = f.AcquisitionMethodId and n.Deleted = 0 for XML PATH('''')), 1, 1, '''') as MethodOfAcquisition
				,f.ApproxmateChronologicalScope as ChronologicalScope
				-- махат се по забележка от ИСДА
				--,coalesce(convert(varchar, f.StartDateYear, 104) + ''.'' + convert(varchar, f.StartDateMonth, 104) + ''.'' + convert(varchar, f.StartDateDay, 104),
						  --convert(varchar, f.StartDateYear, 104) + ''.'' + convert(varchar, f.StartDateMonth, 104),
						  --convert(varchar, f.StartDateYear, 104)) as ChronologicalScopeStartDate
				--,coalesce(convert(varchar, f.EndDateYear, 104) + ''.'' + convert(varchar, f.EndDateMonth, 104) + ''.'' + convert(varchar, f.EndDateDay, 104),
						  --convert(varchar, f.EndDateYear, 104) + ''.'' + convert(varchar, f.EndDateMonth, 104),
						  --convert(varchar, f.EndDateYear, 104)) as ChronologicalScopeEndDate
				,fsi.EnrolledInventoryCount as InventoryCount
				,fsi.EnrolledArchivalEntityCount as AeCount
				,null as LinearMeters
				,fsi.EnrolledBytes as Size
				,dbo.FormatDuration((select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier)) as Duration
				,(select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as DurationInt
				,fsi.EnrolledDocumentCount as EDocumentsCount
				,fsi.FileTypes as FileFormats
				,f.SystemIdentifier
				,f.ExternalIdentifier
				,f.HasExternalSource
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier AND fsi.IsDraft = 0
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 4
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives  + ''', '',''))) 
					OR a.Code in (select element from dbo.SplitString(''' + @Archives + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '','')) AND f.StatusCode not in (''3'', ''4'',''5'', ''8'', ''9'', ''10'', ''13'')) 
					OR (convert(varchar(4), f.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
					OR ((select Code from N.Nomenclatures n1 where n1.Id = f.AcquisitionMethodId) in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.ApproxmateChronologicalScope = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
					OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' = ''null'') 
					OR (try_cast(coalesce(
								convert(varchar, f.StartDateYear, 104) + ''.'' + convert(varchar, f.StartDateMonth, 104) + ''.'' + convert(varchar, f.StartDateDay, 104),
								convert(varchar, f.StartDateYear, 104) + ''.'' + convert(varchar, f.StartDateMonth, 104),
								convert(varchar, f.StartDateYear, 104)) as date) >= cast(''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' = ''null'') 
					OR (try_cast(coalesce(
								convert(varchar, f.EndDateYear, 104) + ''.'' + convert(varchar, f.EndDateMonth, 104) + ''.'' + convert(varchar, f.EndDateDay, 104),
								convert(varchar, f.EndDateYear, 104) + ''.'' + convert(varchar, f.EndDateMonth, 104),
								convert(varchar, f.EndDateYear, 104)) as date) <= cast(''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' as datetime2)))
			');
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				CountryCode nvarchar(50) NOT NULL,
				Archive nvarchar(256) NULL,
				FundNumber nvarchar(50) NULL,
				FundTitle nvarchar(max) NULL,
				CreationDate varchar(50) NULL,
				ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
				--FundType nvarchar(256) NULL, отпада по забележка на Архивите
				DocumentProperties nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				FundStatus nvarchar(256) NULL,
				MethodOfAcquisition nvarchar(256) NULL,
				ChronologicalScope nvarchar(256) NULL,
				-- махат се по забележка от ИСДА
				--ChronologicalScopeStartDate nvarchar(256) NULL,
				--ChronologicalScopeEndDate nvarchar(256) NULL,
				InventoryCount int NULL,
				AeCount int NULL,
				LinearMeters float NULL,
				Size bigint NULL,
				Duration nvarchar(14) NULL,
				DurationInt int NULL,
				EDocumentsCount int NULL,
				FileFormats nvarchar(MAX) NULL,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfPartialReceiptsInArchiveReportCombined]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@Archives nvarchar(max) = null,
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
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

	DECLARE @sql NVARCHAR(MAX); 
	CREATE TABLE #temp (
				CountryCode nvarchar(50) NOT NULL,
				Archive nvarchar(256) NULL,
				FundNumber nvarchar(50) NULL,
				FundTitle nvarchar(max) NULL,
				CreationDate varchar(50) NULL,
				ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
				--FundType nvarchar(256) NULL, отпада по забележка на Архивите
				DocumentProperties nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				FundStatus nvarchar(256) NULL,
				MethodOfAcquisition nvarchar(256) NULL,
				ChronologicalScope nvarchar(256) NULL,
				-- махат се по забележка от ИСДА
				--ChronologicalScopeStartDate nvarchar(256) NULL,
				--ChronologicalScopeEndDate nvarchar(256) NULL,
				InventoryCount int NULL,
				AeCount int NULL,
				LinearMeters float NULL,
				Size bigint NULL,
				Duration nvarchar(14) NULL,
				DurationInt int NULL,
				EDocumentsCount int NULL,
				FileFormats nvarchar(MAX) NULL
			);

	INSERT INTO #temp(
				CountryCode,
				Archive,
				FundNumber,
				FundTitle,
				CreationDate,
				ImmediateSourceOfAcquisition,
				--FundType, отпада по забележка на Архивите
				DocumentProperties,
				Note,
				FundStatus,
				MethodOfAcquisition,
				ChronologicalScope,
				-- махат се по забележка от ИСДА
				--ChronologicalScopeStartDate,
				--ChronologicalScopeEndDate,
				InventoryCount,
				AeCount,
				LinearMeters,
				Size,
				Duration,
				DurationInt,
				EDocumentsCount,
				FileFormats
			)
	EXEC [sp_GetListOfPartialReceiptsInArchiveReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page,
		@Archives,
		@PeriodGids,
		@FundArraysInternal,
		@Statuses,
		@MethodOfAcquisitionGids,
		@MethodsOfAcquisitionInternal,
		@RegisteredFrom,
		@RegisteredTo,
		@ChronologicalScope,
		@ChronologicalScopeStartDate,
		@ChronologicalScopeEndDate

	SET @sql = '
		SELECT TOP 1
			COUNT_BIG(*) as FundCount,
			CAST(SUM(t.InventoryCount) as BIGINT) as InventoryCount,
			CAST(SUM(t.AeCount) as BIGINT) as AeCount,
			ROUND(SUM(t.LinearMeters), 2) as LinearMeters,
			CAST(SUM(t.Size) as BIGINT) as Size,
			dbo.FormatDuration(SUM(t.DurationInt)) as Duration,
			SUM(t.EDocumentsCount) as EDocumentsCount
		FROM #temp as t'

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfPartialReceiptsInArchiveReportSummary]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@Archives nvarchar(max) = null,
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
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

	DECLARE @sql NVARCHAR(MAX); 
	CREATE TABLE #temp (
				CountryCode nvarchar(50) NOT NULL,
				Archive nvarchar(256) NULL,
				FundNumber nvarchar(50) NULL,
				FundTitle nvarchar(max) NULL,
				CreationDate varchar(50) NULL,
				ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
				--FundType nvarchar(256) NULL, отпада по забележка на Архивите
				DocumentProperties nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				FundStatus nvarchar(256) NULL,
				MethodOfAcquisition nvarchar(256) NULL,
				ChronologicalScope nvarchar(256) NULL,
				-- махат се по забележка от ИСДА
				--ChronologicalScopeStartDate nvarchar(256) NULL,
				--ChronologicalScopeEndDate nvarchar(256) NULL,
				InventoryCount int NULL,
				AeCount int NULL,
				LinearMeters float NULL,
				Size bigint NULL,
				Duration nvarchar(14) NULL,
				DurationInt int NULL,
				EDocumentsCount int NULL,
				FileFormats nvarchar(MAX) NULL
			);

	INSERT INTO #temp(
				CountryCode,
				Archive,
				FundNumber,
				FundTitle,
				CreationDate,
				ImmediateSourceOfAcquisition,
				--FundType, отпада по забележка на Архивите
				DocumentProperties,
				Note,
				FundStatus,
				MethodOfAcquisition,
				ChronologicalScope,
				-- махат се по забележка от ИСДА
				--ChronologicalScopeStartDate,
				--ChronologicalScopeEndDate,
				InventoryCount,
				AeCount,
				LinearMeters,
				Size,
				Duration,
				DurationInt,
				EDocumentsCount,
				FileFormats
			)
	EXEC [sp_GetListOfPartialReceiptsInArchiveReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page,
		@Archives,
		@PeriodGids,
		@FundArraysInternal,
		@Statuses,
		@MethodOfAcquisitionGids,
		@MethodsOfAcquisitionInternal,
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetAllDescriptionLevelsInOrder]
	@LinkedServer nvarchar(50),
	@ResultType int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql NVARCHAR(MAX);

	DECLARE @FinalPart NVARCHAR(max) = 'ORDER BY CASE
											WHEN SortOrder = 1 AND [Label] LIKE ''Фонд'' THEN 1
											WHEN SortOrder = 1 AND [Label] LIKE ''Фонд с н%'' THEN 2
											WHEN SortOrder = 1 AND [Label] LIKE ''Ч%'' THEN 3
											WHEN SortOrder = 1 AND [Label] LIKE ''С%'' THEN 4
											WHEN SortOrder = 1 AND [Label] LIKE ''К%'' THEN 5
											WHEN SortOrder = 2 AND [Label] LIKE ''И%'' THEN 6
											WHEN SortOrder = 2 AND [Label] LIKE ''Г%'' THEN 7
											WHEN SortOrder = 2 AND [Label] LIKE ''С%'' THEN 8
											WHEN SortOrder = 3 AND [Label] LIKE ''А%'' THEN 9
											WHEN SortOrder = 3 AND [Label] LIKE ''С%'' THEN 10
											WHEN SortOrder = 4 THEN 11
										END ASC
										OFFSET 0 ROWS'

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remote NVARCHAR(MAX) = '
		SELECT * FROM (SELECT  CAST(Gid as varchar(10)) as Code
	   ,[Value] as Label
	   ,CAST(1 as bit) as HasExternalSource
	   ,1 as SortOrder
  FROM [Archiving].[dbo].[Nomenclature]
 WHERE [Type] = ''LevelOfDescription'' AND [Title] NOT LIKE ''%Inventory%'' AND [Title] NOT LIKE ''%Entit%'' AND [Title] NOT LIKE ''%Document%'') as f1
 UNION ALL
SELECT  CAST(Gid as varchar(10)) as Code
	   ,[Value] as Label
	   ,CAST(1 as bit) as HasExternalSource
	   ,2 as SortOrder
  FROM [Archiving].[dbo].[Nomenclature]
 WHERE [Type] = ''LevelOfDescription'' AND [Title] LIKE ''%Inventory%''
 UNION ALL
SELECT  CAST(Gid as varchar(10)) as Code
	   ,[Value] as Label
	   ,CAST(1 as bit) as HasExternalSource
	   ,3 as SortOrder
  FROM [Archiving].[dbo].[Nomenclature]
 WHERE [Type] = ''LevelOfDescription'' AND [Title] LIKE ''%Entit%''
 UNION ALL
SELECT  CAST(Gid as varchar(10)) as Code
	   ,[Value] as Label
	   ,CAST(1 as bit) as HasExternalSource
	   ,4 as SortOrder
  FROM [Archiving].[dbo].[Nomenclature]
 WHERE [Type] = ''LevelOfDescription'' AND [Title] LIKE ''%Document%''
		'
		SET @remote = REPLACE(@remote, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @local NVARCHAR(MAX) = '
SELECT  ''fund_'' + CAST(Code as varchar(10)) as Code
	   ,[Text] as Label
	   ,CAST(0 as bit) as HasExternalSource
	   ,1 as SortOrder
  FROM N.FundDescriptionLevel
 UNION ALL
SELECT TOP 1 ''film_0'' as Code
	   ,''КМФ'' as Label
	   ,CAST(0 as bit) as HasExternalSource
	   ,1 as SortOrder
  FROM N.FundDescriptionLevel
  UNION ALL
SELECT TOP 1 ''fc_0'' as Code
	   ,''КМФ картон'' as Label
	   ,CAST(0 as bit) as HasExternalSource
	   ,1 as SortOrder
  FROM N.FundDescriptionLevel
  UNION ALL
SELECT  ''inv_'' + CAST(Code as varchar(10)) as Code
	   ,[Text] as Label
	   ,CAST(0 as bit) as HasExternalSource
	   ,2 as SortOrder
  FROM N.InventoryDescriptionLevel
 UNION ALL
SELECT  ''ae_'' + CAST(Code as varchar(10)) as Code
	   ,[Text] as Label
	   ,CAST(0 as bit) as HasExternalSource
	   ,3 as SortOrder
  FROM N.ArchivalEntityDescriptionLevel
 UNION ALL
SELECT  ''doc_'' + CAST(Code as varchar(10)) as Code
	   ,[Text] as Label
	   ,CAST(0 as bit) as HasExternalSource
	   ,4 as SortOrder
  FROM N.DocumentDescriptionLevel
		'
	END

	IF @ResultType = 1
	BEGIN

	DECLARE @rT NVARCHAR(max) = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remote + ''')';
	DECLARE @lT NVARCHAR(max) = 'SELECT * FROM (' + @local + ') as t';

	DECLARE @both NVARCHAR(max) = '
	SELECT * FROM (' + @rT + ' UNION ALL ' + @lT + ') as bt ' + @FinalPart

	SET @sql = 'SELECT [Code], [Label], [HasExternalSource] FROM (' + @both + ') as t';

	END

	IF @ResultType = 2
	BEGIN
			SET @sql = 'SELECT [Code], [Label], [HasExternalSource] FROM (SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remote + ''') as rt ' + @FinalPart + ') as t';
	END

	IF @ResultType = 3
	BEGIN
			SET @sql ='SELECT [Code], [Label], [HasExternalSource] FROM ( SELECT * FROM (' + @local + ') as lt ' + @FinalPart + ') as t';
	END

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetDocumentsByArchiveEntityPublic] 
	@LinkedServer nvarchar(50),
	@ArchiveEntityIdentifier uniqueidentifier = NULL,
	@ArchiveEntityHasExternalSource bit,
	@ArchiveEntityExternalIdentifier int = NULL,
	@SearchText nvarchar(max) = NULL,
	@IncludeDeleted bit = false,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteDocumentsQuery nvarchar(max) = '';
    DECLARE @RemoteDocuments TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,ArchivalEntityHasExternalSource bit
        ,ArchivalEntityExternalIdentifier int
        ,ArchivalEntityNumber nvarchar(50)
        ,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Author nvarchar(max)
		,Location nvarchar(max)
		,FileTypeText nvarchar(max)
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
	    ,Bytes bigint
	    ,SheetCount int 
	    ,StartSheetNumber int
	    ,EndSheetNumber int 
	    ,DigitalDevice nvarchar(max)
	    ,Scaling nvarchar(256)
	    ,Duration nvarchar(256)
	    ,Transcription nvarchar(max)
	);

	DECLARE @LocalDocuments TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,ArchivalEntityHasExternalSource bit
        ,ArchivalEntityExternalIdentifier int
        ,ArchivalEntityNumber nvarchar(50)
        ,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Author nvarchar(max)
		,Location nvarchar(max)
		,FileTypeText nvarchar(max)
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
	    ,Bytes bigint
	    ,SheetCount int 
	    ,StartSheetNumber int
	    ,EndSheetNumber int 
	    ,DigitalDevice nvarchar(max)
	    ,Scaling nvarchar(256)
	    ,Duration nvarchar(256)
	    ,Transcription nvarchar(max)
	);

	IF @ArchiveEntityHasExternalSource = 1
	BEGIN 

		SET @RemoteDocumentsQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
		,CAST(NULL as uniqueidentifier) as SystemIdentifier
		,CAST(1 as bit) as HasExternalSource
		,d.[LGid] as ExternalIdentifier
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= d.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= d.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
		,CAST(1 as bit) as ArchivalEntityHasExternalSource
		,(select LGid from [Archiving].[dbo].ArchiveEntity_Active ae where ae.LGid = d.AELGid and ae._retired = ''''3000-01-01 00:00:00.000'''') as ArchivalEntityExternalIdentifier
		,(select Number from [Archiving].[dbo].ArchiveEntity_Active ae where ae.LGid = d.AELGid and ae._retired = ''''3000-01-01 00:00:00.000'''') as ArchivalEntityNumber
		,CAST(1 as bit) as InventoryHasExternalSource
		,(select LGid from [Archiving].[dbo].Inventory_Active i where i.LGid = d.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryExternalIdentifier
		,(select Number from [Archiving].[dbo].Inventory_Active i where i.LGid = d.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryNumber
		,CAST(1 as bit) as FundHasExternalSource
		,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = d.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
		,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = d.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
		,(select Code from [Archiving].[dbo].Archive a where a.Gid = d.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
		,(select Name from [Archiving].[dbo].Archive a where a.Gid = d.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
		,d.[Number] as Number
		,d.[Title] as Title
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= d.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= d.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
		,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= d.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= d.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
		,d.[TextDate] as ApproximateChronologicalScope  ' + '
		,d.CopyMicrofilm as MicrofilmedCopyCount
		,d.CopyDigital as DigitizedCopyCount
		,d.CopyXerox as PaperCopyCount
		,d.CopyNegativFrames as NegativeFrameCount
		,d.CopyPositiveFrames as PositiveFrameCount
		,d.CopyOther as OtherCopyCount
		,d.DimensionInCentimeters as SizeCm
		,NULL as OtherMetrics
		,d.Creator as Author
		,d.PlaceOfCreation as Location
		,NULL as FileTypeText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.DocumentGid = d.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.DocumentGid = d.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.DocumentGid = d.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
		,d.[AccessConditions] as DocumentsAccessDescription
		,d.SpecificDetails as Features
		,d.[Note] as Notes
		,d.[ExtendedContentDescription] as Description
		,d.[StartDateYear] as StartDateYear
		,d.[StartDateMonth] as StartDateMonth
		,d.[StartDateDay] as StartDateDay
		,d.[EndDateYear] as EndDateYear
		,d.[EndDateMonth] as EndDateMonth
		,d.[EndDateDay] as EndDateDay
		,d.[IsNoDate] as HasNoChronologicalScope
		,NULL as Bytes
	    ,d.PaperCount as SheetCount
	    ,NULL as StartSheetNumber
	    ,NULL as EndSheetNumber
	    ,NULL as DigitalDevice
	    ,d.Scale as Scaling
	    ,NULL Duration
	    ,d.Transcription as Transcription
	FROM [Archiving].[dbo].[Document_Active] d
	WHERE d.AELGid = ' + CAST(@ArchiveEntityExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
		BEGIN
			SET @RemoteDocumentsQuery = @RemoteDocumentsQuery +  ' AND (d.Title LIKE ''''%' + @SearchText + '%'''' )'
		END;

		PRINT @RemoteDocumentsQuery
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteDocumentsQuery + ''' )';
		
		INSERT INTO @RemoteDocuments 
		EXEC(@RemoteQuery)
	END

	IF @ArchiveEntityIdentifier IS NOT NULL
	BEGIN
		INSERT INTO @LocalDocuments
		SELECT	 d.Id
				,d.SystemIdentifier as SystemIdentifier
				,COALESCE(d.HasExternalSource, 0) as HasExternalSource
				,d.ExternalIdentifier
				,d.StatusCode
				,d.StatusText
				,d.ArchivalEntityHasExternalSource
				,d.ArchivalEntityExternalIdentifier
				,d.ArchivalEntityNumber
				,d.InventoryHasExternalSource
				,d.InventoryExternalIdentifier
				,d.InventoryNumber
				,d.FundHasExternalSource
				,d.FundExternalIdentifier
				,d.FundNumber
				,d.ArchiveCode
				,d.ArchiveName
				,d.Number as Number
				,d.Title
				,d.DescriptionLevelCode
				,d.DescriptionLevelText
				,d.AvailabilityStatusCode
				,d.AvailabilityStatusText
				,d.ApproxmateChronologicalScope as ApproximateChronologicalScope
				,d.MicrofilmedCopyCount
				,d.DigitizedCopyCount
				,d.PaperCopyCount
				,d.NegativeFrameCount
				,d.PositiveFrameCount
				,d.OtherCopyCount
				,d.SizeCm
				,d.OtherMetrics
				,d.Author
				,d.Location
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = d.Id and nv.EntityType = 'document' and nv.NomenclatureCode = 'FILE_TYPE' for XML PATH('')), 1, 1, '') as FileTypeText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = d.Id and nv.EntityType = 'document' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = d.Id and nv.EntityType = 'document' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = d.Id and nv.EntityType = 'document' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
				,d.DocumentsAccessDescription
				,d.Features
				,d.Notes
				,d.Description
				,d.StartDateYear
				,d.StartDateMonth
				,d.StartDateDay
				,d.EndDateYear
				,d.EndDateMonth
				,d.EndDateDay
				,d.HasNoChronologicalScope				
				,d.Bytes
				,d.SheetCount
				,d.StartSheetNumber
				,d.EndSheetNumber
				,d.DigitalDevice
				,d.Scaling
				,d.Duration
				,d.Transcription
	     FROM [dbo].[v_PublicDocuments] d
	    WHERE d.ArchivalEntitySystemIdentifier = @ArchiveEntityIdentifier 
		  AND (d.HasExternalSource IS NULL OR d.HasExternalSource = 0)
		  AND (@SearchText IS NULL OR d.Title LIKE '%'+ @SearchText +'%')
		  AND (@IncludeDeleted = 1 OR d.Deleted = 0)
	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalDocuments
		  UNION
		 SELECT *
		   FROM @RemoteDocuments
	   ) Documents
	ORDER BY Number
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY	
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetDocumentsByArchiveEntityCountPublic]
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
		FROM [dbo].[v_PublicDocuments] d
		WHERE d.ArchivalEntitySystemIdentifier = @ArchiveEntityIdentifier 
		   AND (d.HasExternalSource IS NULL OR d.HasExternalSource = 0)
		   AND (@IncludeDeleted = 1 OR d.Deleted = 0)
	END

	RETURN @LocalDocumentsCount + @RemoteDocumentsCount	
END
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
	ORDER BY IntNumber
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[sp_GetArchiveEntitiesByInventoryCountPublic]
	@LinkedServer nvarchar(255) = '', 
	@InventoryIdentifier uniqueidentifier = NULL,
	@InventoryHasExternalSource bit,
	@InventoryExternalIdentifier int = NULL,
	@SearchText nvarchar(max) = NULL,
	@SearchNumber nvarchar(max) = NULL,
	@IncludeDeleted bit = false	
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteArchivalEntities TABLE ( ArchivalEntityCount int );
	DECLARE @RemoteArchivalEntitiesCount int = 0;
	DECLARE @LocalArchivalEntitiesCount int = 0;

	DECLARE @RemoteArchivalEntitiesQuery nvarchar(max) = '';
		
	IF @InventoryHasExternalSource = 1
	BEGIN 
		SET @RemoteArchivalEntitiesQuery = CAST('' as nvarchar(max)) +
		'SELECT LGid
		FROM [Archiving].[dbo].[ArchiveEntity_Active] ae
		WHERE ae.InventoryLGid = ' + CAST(@InventoryExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery + ' AND Title LIKE ''''%' + @SearchText + '%'''''
		
		IF @SearchNumber IS NOT NULL
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  'AND (ae.Number LIKE '+ @SearchNumber +')'

		DECLARE @RemoteQuery nvarchar(max) = 'SELECT COUNT(*) as ArchivalEntityCount FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteArchivalEntitiesQuery + ''' )';
		
		PRINT @RemoteQuery
		
		INSERT INTO @RemoteArchivalEntities
		EXEC(@RemoteQuery)

		SELECT TOP 1 @RemoteArchivalEntitiesCount = ArchivalEntityCount from @RemoteArchivalEntities
	END

	IF @InventoryIdentifier IS NOT NULL
	BEGIN
		SELECT @LocalArchivalEntitiesCount = COUNT(ae.Id)
		FROM [dbo].[v_PublicArchivalEntities] ae
		WHERE ae.InventorySystemIdentifier = @InventoryIdentifier 
		   AND ae.HasExternalSource = 0
		   AND (@IncludeDeleted = 1 OR ae.Deleted = 0)
	END

	RETURN @LocalArchivalEntitiesCount + @RemoteArchivalEntitiesCount	
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetFundInventoriesPublic]
	@LinkedServer nvarchar(255) = '', 
	@FundIdentifier uniqueidentifier = NULL,
	@FundHasExternalSource bit,
	@FundExternalIdentifier int = NULL,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @RemoteInventoriesQuery nvarchar(max) = '';
    DECLARE @RemoteInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(256)
		,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,NumberNumeric int
		,Number nvarchar(50)
		,ApproxmateChronologicalScope nvarchar(max)
		,LinearMeters float
		,ArchivalEntityCount int
		,BoxCount int 
		,RollCount int
		,AudioDocumentArchivalEntityCount int
		,PhotoDocumentArchivalEntityCount int 
		,VideoDocumentArchivalEntityCount int
		,DigitalDocumentArchivalEntityCount int
		,OtherMetrics nvarchar(256)
		,FundCreatorTitleHistory nvarchar(max)
		,FundCreatorBiographicalHistory nvarchar(max)
		,History nvarchar(max)
		,DocumentsProvider nvarchar(max)
		,AcquisitionMethodText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,ClassificationScheme nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,AbbreviationList nvarchar(max)
		,MicrofilmedArchivalEntityCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,DigitizedArchivalEntityCount int
		,Notes nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(256)
		,DocumentsDescription nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
	);

	DECLARE @LocalInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(256)
		,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,NumberNumeric int
		,Number nvarchar(50)
		,ApproxmateChronologicalScope nvarchar(max)
		,LinearMeters float
		,ArchivalEntityCount int
		,BoxCount int 
		,RollCount int
		,AudioDocumentArchivalEntityCount int
		,PhotoDocumentArchivalEntityCount int 
		,VideoDocumentArchivalEntityCount int
		,DigitalDocumentArchivalEntityCount int
		,OtherMetrics nvarchar(256)
		,FundCreatorTitleHistory nvarchar(max)
		,FundCreatorBiographicalHistory nvarchar(max)
		,History nvarchar(max)
		,DocumentsProvider nvarchar(max)
		,AcquisitionMethodText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,ClassificationScheme nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,AbbreviationList nvarchar(max)
		,MicrofilmedArchivalEntityCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,DigitizedArchivalEntityCount int
		,Notes nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(256)
		,DocumentsDescription nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
	);

	IF @FundHasExternalSource = 1
	BEGIN 
		SET @RemoteInventoriesQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
			  ,CAST(NULL as uniqueidentifier) as SystemIdentifier
			  ,CAST(1 as bit) as HasExternalSource
			  ,inventory.[LGid] as ExternalIdentifier
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
			  ,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
			  ,CAST(1 as bit) as FundHasExternalSource
			  ,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
			  ,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
			  ,(select Code from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
			  ,(select Name from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
			  ,(select Value from [Archiving].[dbo].Nomenclature n where n.Gid = inventory.InventoryArrayGid and n._retired = ''''3000-01-01 00:00:00.000'''') as NumberArray
			  ,inventory.[IntNumber] as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.[TextDate] as ApproxmateChronologicalScope
			  ,inventory.[LinearMeter] as LinearMeters
			  ,inventory.[AECount] as ArchivalEntityCount ' + '
			  ,inventory.[BoxesCount] as BoxCount
			  ,inventory.[RuloniTubusiCount] as RollCount
			  ,inventory.[AEFonoDocsCount] as AudioDocumentArchivalEntityCount
			  ,inventory.[AEPhotoDocsCount] as PhotoDocumentArchivalEntityCount
			  ,inventory.[AEVideoAudioDocsCount] as VideoDocumentArchivalEntityCount
			  ,inventory.[AEElectrDocsCount] as DigitalDocumentArchivalEntityCount
			  ,inventory.[ExtentOther] as OtherMetrics
			  ,inventory.[FundCreatorNameChanges] as FundCreatorTitleHistory
			  ,inventory.[FundFormerHistory] as FundCreatorBiographicalHistory
			  ,inventory.[ArchivalHistory] as History
			  ,inventory.[ImmediateSourceOfAcquisition] as DocumentsProvider ' + '
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''MethodOfAcquisition'''' for XML PATH('''''''')), 1, 1, '''''''') as AcquisitionMethodText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
			  ,inventory.[ClassificationScheme] as ClassificationScheme
			  ,inventory.[AccessConditions] as DocumentsAccessDescription
			  ,inventory.[Abbreviations] as AbbreviationList
			  ,inventory.[CopyMicrofilmAE] as MicrofilmedArchivalEntityCount ' + '
			  ,inventory.[CopyNegativFrames] as NegativeFrameCount
			  ,inventory.[CopyPositiveFrames] as PositiveFrameCount
			  ,inventory.[CopyDigitizedAE] as DigitizedArchivalEntityCount
			  ,inventory.[Note] as Notes
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
			  ,inventory.[DocumentProperties] as DocumentsDescription
			  ,inventory.[StartDateYear] as StartDateYear
			  ,inventory.[StartDateMonth] as StartDateMonth
			  ,inventory.[StartDateDay] as StartDateDay
			  ,inventory.[EndDateYear] as EndDateYear
			  ,inventory.[EndDateMonth] as EndDateMonth
			  ,inventory.[EndDateDay] as EndDateDay
			  ,inventory.[IsNoDate] as HasNoChronologicalScope
		  FROM [Archiving].[dbo].[Inventory_Active] inventory
		 WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50)) + '
			AND (SELECT Gid FROM [dbo].[Nomenclature] n1 WHERE n1.Gid = inventory.LevelOfDescriptionGid AND n1._retired = ''''3000-01-01 00:00:00.000'''') <> 2172
		 ';
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteInventoriesQuery + ''' )';
		
		INSERT INTO @RemoteInventories 
		EXEC(@RemoteQuery)
	END

	IF @FundIdentifier IS NOT NULL
	BEGIN
		INSERT INTO @LocalInventories
		SELECT inventory.Id
			  ,inventory.SystemIdentifier as SystemIdentifier
			  ,inventory.HasExternalSource
			  ,inventory.ExternalIdentifier
			  ,inventory.StatusCode
			  ,inventory.StatusText
			  ,inventory.AvailabilityStatusCode
			  ,inventory.AvailabilityStatusText
			  ,inventory.FundHasExternalSource
			  ,inventory.FundExternalIdentifier
			  ,inventory.FundNumber
			  ,inventory.ArchiveCode
			  ,inventory.ArchiveName
			  ,inventory.NumberArray
			  ,inventory.NumberNumeric as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.ApproxmateChronologicalScope
			  ,inventory.LinearMeters
			  ,inventory.ArchivalEntityCount
			  ,inventory.BoxCount
			  ,inventory.RollCount
			  ,inventory.AudioDocumentArchivalEntityCount
			  ,inventory.PhotoDocumentArchivalEntityCount
			  ,inventory.VideoDocumentArchivalEntityCount
			  ,inventory.DigitalDocumentArchivalEntityCount
			  ,inventory.OtherMetrics
			  ,inventory.FundCreatorTitleHistory
			  ,inventory.FundCreatorBiographicalHistory
			  ,inventory.History
			  ,inventory.DocumentsProvider
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'ACQUISITION_METHOD' for XML PATH('')), 1, 1, '') as AcquisitionMethodText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
			  ,inventory.ClassificationScheme
			  ,inventory.DocumentsAccessDescription
			  ,inventory.AbbreviationList
			  ,inventory.MicrofilmedArchivalEntityCount
			  ,inventory.NegativeFrameCount
			  ,inventory.PositiveFrameCount
			  ,inventory.DigitizedArchivalEntityCount
			  ,inventory.Notes
			  ,inventory.DescriptionLevelCode
			  ,inventory.DescriptionLevelText
			  ,inventory.DocumentsDescription
			  ,inventory.StartDateYear
			  ,inventory.StartDateMonth
			  ,inventory.StartDateDay
			  ,inventory.EndDateYear
			  ,inventory.EndDateMonth
			  ,inventory.EndDateDay
			  ,inventory.HasNoChronologicalScope
		 FROM [dbo].[v_PublicInventories] inventory
		 WHERE inventory.FundSystemIdentifier = @FundIdentifier 
		   AND inventory.HasExternalSource = 0
		   AND inventory.Deleted = 0 
	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalInventories
		  UNION
		 SELECT *
		   FROM @RemoteInventories
	   ) inventories
	ORDER BY NumberNumeric
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetFundInventoriesCountPublic]
	@LinkedServer nvarchar(255) = '', 
	@FundIdentifier uniqueidentifier = NULL,
	@FundHasExternalSource bit,
	@FundExternalIdentifier int = NULL
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @RemoteInventories TABLE ( InventoryCount int );
	DECLARE @RemoteInventoriesCount int = 0;
	DECLARE @LocalInventoriesCount int = 0;

	DECLARE @RemoteInventoriesQuery nvarchar(max) = '';
    
	IF @FundHasExternalSource = 1
	BEGIN 
		SET @RemoteInventoriesQuery = CAST('' as nvarchar(max)) + '
			SELECT inventory.[LGid]
			FROM [Archiving].[dbo].[Inventory_Active] inventory
			WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50)) + '';
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT COUNT(*) as InventoryCount FROM OPENQUERY(' +  @LinkedServer + ', ''SELECT inventory.[LGid]
			FROM [Archiving].[dbo].[Inventory_Active] inventory
			WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50)) + '
				AND (SELECT Gid FROM [dbo].[Nomenclature] n1 WHERE n1.Gid = inventory.LevelOfDescriptionGid AND n1._retired = ''''3000-01-01 00:00:00.000'''') <> 2172'')';
		
		INSERT INTO @RemoteInventories
		EXEC(@RemoteQuery)

		SELECT TOP 1 @RemoteInventoriesCount = InventoryCount from @RemoteInventories
	END

	IF @FundIdentifier IS NOT NULL
	BEGIN
		SELECT @LocalInventoriesCount = COUNT(inventory.Id)
		  FROM [dbo].[v_PublicInventories] inventory
		 WHERE inventory.FundSystemIdentifier = @FundIdentifier 
		   AND inventory.HasExternalSource = 0
		   AND inventory.Deleted = 0
	END

	RETURN @LocalInventoriesCount + @RemoteInventoriesCount
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetReceiptsListReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by CreationDateAsDateTime
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	DECLARE @methodOfAcquisitionQueryRemote VARCHAR(MAX) = '
		(
			select Value + '';''
			from  Nomenclature n1
			inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
			where n1._retired=''3000-01-01'' 
				and on1._retired=''3000-01-01''
				and on1.FundGid = fund.Gid 
				and n1.Type=''MethodOfAcquisition''
			FOR XML path(''''), elements
		)';
	DECLARE @methodOfAcquisitionQueryLocal VARCHAR(MAX) = '
		(
			select ValueCode + '';''
			from  NomenclatureValues nv
			where nv.EntityType=''fund'' 
				and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
				and nv.EntityId=Id
			FOR XML path(''''), elements
		)';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN	
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				cast(fund.CreationDate AS datetime2(7)) as CreationDateAsDateTime,
				COALESCE(
					fund.ImmediateSourceOfAcquisition + '' / '' + ' + @methodOfAcquisitionQueryRemote +  ', 
					fund.ImmediateSourceOfAcquisition + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryRemote + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				cast(fund.AECount as bigint) as ArchiveEntitiesCount,
				isnull(fund.LinearMeters, 0) as LinearMeters,
				null as DigitalSize,
				TextDate,
				fund.Note
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND (fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1) 
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreatedOn, 104) as CreationDate,
				fund.CreatedOn as CreationDateAsDateTime,
				COALESCE(
					fund.DocumentsProvider + '' / '' + ' + @methodOfAcquisitionQueryLocal +  ',
					fund.DocumentsProvider + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryLocal + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				cast(fund.ArchivalEntityCount as bigint) as ArchiveEntitiesCount,
				isnull(fund.LinearMeters, 0) as LinearMeters,
				cast(fund.Bytes AS BIGINT) as DigitalSize, -- реално е MB, името на колоната трябва да се смени
				ApproxmateChronologicalScope as TextDate,
				fund.Notes as Note
			FROM Funds fund
			INNER JOIN Archives a ON a.Id = fund.ArchiveId AND a.Deleted = 0
			WHERE fund.ExternalIdentifier IS NULL AND fund.HasExternalSource = 0 AND fund.Deleted = 0 
				AND fund.DescriptionLevelCode IN(1, 2, 4)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(fund.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				CreationDate varchar(50) NULL,
				CreationDateAsDateTime varchar(50) NULL,
				ImmediateSourceOfAcquisitionPlusMethodOfAcquisition nvarchar(MAX) NULL,
				Title nvarchar(MAX) NULL,
				ArchiveEntitiesCount bigint NULL,
				LinearMeters float NULL, 
				DigitalSize bigint NULL,
				TextDate nvarchar(MAX) NULL, -- по забележка на ИСДА сменя DocumentsEndDates
				Note nvarchar(MAX) NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'
			SELECT 
				ROW_NUMBER() OVER(ORDER BY CreationDateAsDateTime ASC) AS RowNumber,
				Archive,
				Number,
				CreationDate,
				CreationDateAsDateTime,
				ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				Title,
				ArchiveEntitiesCount,
				LinearMeters, 
				DigitalSize,
				TextDate,
				Note
			FROM (
				SELECT *
				FROM @remoteFundsTable
				UNION
				' +
				@localQuery + ') t
				' + @sqlFinalPart;	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + @sqlFinalPart +''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = 'DECLARE @methodOfAcquisitionQueryLocal VARCHAR(MAX);' + @localQuery + @sqlFinalPart;
	END

	EXEC (@sql);
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetReceiptsListReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@Page int = 1
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Fund_Modified as fund
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND (fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1) 
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Funds 
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0
				AND DescriptionLevelCode IN(1, 2, 4)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundInternalReport] 
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
				null as SystemIdentifier,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE
				((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')) AND fund.FundArrayGid not in (2021, 2022)) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
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
				f.SystemIdentifier,
				f.ExternalIdentifier,
				f.HasExternalSource
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			INNER JOIN N.Status s ON s.Code = f.StatusCode
			LEFT JOIN v_FundSizeInfo as fsi ON f.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 1 OR f.DescriptionLevelCode = 2 -- fund 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '','')) AND f.NumberArray not in (''4'', ''5'')) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
					OR (convert(varchar(4), s.Code, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '','')))) 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '','')) AND f.TypeCode not in (''Б'', ''В'')) 
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
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundInternalReportSummary] 
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
	@DateTo nvarchar(100) = null
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQueryWhereClause VARCHAR(MAX) = '
				((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')) AND fund.FundArrayGid not in (2021, 2022)) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
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

		DECLARE @remoteQuery VARCHAR(MAX) = 
			'SELECT
				count(*) TotalFunds,
				sum(isnull(fund.InvetoryCount, 0)) TotalInventories,
				sum(isnull(fund.AECount, 0)) TotalArchiveEntities,
				round(sum(fund.LinearMeters), 2) TotalLinearMeters,
				--(select sum(sizes.Size)
				--from 
					--(select (select sum(isnull(i.ByteLenght, 0)) 
						--from Image i
						--inner join Document_Modified d
						--on i.DocumentGid = d.Gid
						--where d.FundLGid = fund.LGid) as Size
						--from [Archiving].[dbo].[Fund_Modified] fund
						--WHERE  + @remoteQueryWhereClause + 
					--) sizes) TotalSize
				null TotalSize, -- по искане на клиента не се отчита
				NULL as TotalDuration
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE ' + @remoteQueryWhereClause;

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

		DECLARE @localQueryWhereClause VARCHAR(max) = '
			ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
			AND DescriptionLevelCode = 1 OR f.DescriptionLevelCode = 2-- fund
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '','')) AND f.NumberArray not in (''4'', ''5'')) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
				) 
			)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
				) 
			)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '','')) AND f.TypeCode not in (''Б'', ''В'')) 
				OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
			AND ((''' + ISNULL(@TextDate,  N'NULL') + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.ApproxmateChronologicalScope = ''') + ISNULL(@TextDate, N'NULL') + '''))
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
				OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
				OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
			' 
			+ @DateFromCondition
			+ @DateToCondition;

		DECLARE @totalDuration VARCHAR(MAX) = '' 

		IF @ResultType = 1
		BEGIN
			SET @totalDuration = '
				(select cast(sum(durations.Duration) as bigint) 
				from 
					(select (select sum(isnull(d.Duration, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) durations)';
		END

		IF @ResultType = 3
		BEGIN
			SET @totalDuration = ' 
				(select cast(sum(durations.Duration) as bigint)  
				from 
					(select (select sum(isnull(d.Duration, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) durations)
				';
		END

		DECLARE @localQuery VARCHAR(max) = 
			'SELECT
				count(*) TotalFunds,
				sum(isnull(fsi.EnrolledInventoryCount, 0)) TotalInventories,
				sum(isnull(fsi.EnrolledArchivalEntityCount, 0)) TotalArchiveEntities,
				null TotalLinearMeters,
				(select sum(sizes.Size) 
				from 
					(select fsi.EnrolledBytes as Size
						from Funds f
						LEFT JOIN v_FundSizeInfo as fsi ON f.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
						WHERE ' + @localQueryWhereClause + '
					) sizes) TotalSize, -- въпреки че колоната се казва Bytes, тя съдържа MB, затова няма превръщане на мерните ед.'
				+ @totalDuration + ' TotalDuration
			FROM Funds f
			LEFT JOIN v_FundSizeInfo as fsi ON f.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
			WHERE ' + @localQueryWhereClause;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalFunds int NULL,
				TotalInventories int NULL,
				TotalArchiveEntities int NULL,
				TotalLinearMeters float NULL,
				TotalSize bigint NULL,
				TotalDuration bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT 
				sum(u.TotalFunds) as TotalFunds, 
				sum(u.TotalInventories) as TotalInventories, 
				sum(u.TotalArchiveEntities) as TotalArchiveEntities, 
				sum(isnull(u.TotalLinearMeters, 0)) as TotalLinearMeters,
				cast(sum(isnull(u.TotalSize, 0)) as bigint) as TotalSize,
				sum(u.TotalDuration) as TotalDuration
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundDataInternalReport] -- REPORT_8_27_Fund_Report от ИСДА
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
				null as SystemIdentifier,
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
					and nv.NomenclatureCode=''ORIGINALITY'' 
					and nv.EntityId=f.Id
					and n1.Id=nv.ValueId
				FOR XML path(''''), elements) as Originality,
			(select Text + '';''
				from NomenclatureValues nv
				join N.Nomenclatures n1 on 
					nv.EntityType=''fund'' 
					and nv.NomenclatureCode=''CREATION_METHOD'' 
					and nv.EntityId=f.Id
					and n1.Id=nv.ValueId
				FOR XML path(''''), elements) as CreatingType,
			(select Text + '';''
				from NomenclatureValues nv
				join N.Nomenclatures n1 on 
					nv.EntityType=''fund'' 
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
			f.SystemIdentifier,
			f.ExternalIdentifier,
			f.HasExternalSource
		FROM Funds f
		INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
		INNER JOIN N.Status s ON s.Code = f.StatusCode
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
			SystemIdentifier nvarchar(256) null,
			ExternalIdentifier int null,
			HasExternalSource bit
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteFundsTable
		UNION
		' +
		+ @localQuery +
		+ @sqlFinalPart;;
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundDataInternalReportSummary] 
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
	@DateFrom nvarchar(100) = NULL,
	@DateTo nvarchar(100) = null,
	@LGid nvarchar(max) = null
AS
BEGIN
	IF @ResultType = 1 OR @ResultType = 2
	BEGIN 
		declare @remoteQuery varchar(max) = 
			'SELECT
				COUNT(*) Funds,
				sum(isnull(fund.InvetoryCount, 0)) Inventories,
				sum(isnull(fund.AECount, 0)) ArchiveEntities,
				cast(sum(fund.LinearMeters) as decimal(18,2)) LinearMeters,
				null Size, -- по искане на клиента не се отчита
				null as Duration,
				null as EDocumentsCount
			FROM Fund_Modified as fund
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
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE(@TextDate, 'null') + '''))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@LGid, 'null') + ''' = ''null'') OR (fund.LGid in (SELECT Element from dbo.SplitString(''' + COALESCE(@LGid, 'null') + ''', '',''))))';

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
		
		DECLARE @localQueryWhereClause VARCHAR(max) = '
			ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
					AND DescriptionLevelCode = 1 
					AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
						OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
						OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
						OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
							and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
						) 
					)
					AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
						OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
							and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
						) 
					)
					AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
						OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
						OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
					AND ((''' + ISNULL(@TextDate,  N'NULL') + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.ApproxmateChronologicalScope = ''') + ISNULL(@TextDate, N'NULL') + '''))
					AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
						OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
						OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))	
					'
					+ @DateFromCondition
					+ @DateToCondition;

		DECLARE @totalDuration VARCHAR(MAX) = '' 

		IF @ResultType = 1
		BEGIN
			SET @totalDuration = '
				(select cast(sum(durations.Duration) as bigint) 
				from 
					(select (select sum(isnull(d.Duration, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) durations)';
		END

		IF @ResultType = 3
		BEGIN
			SET @totalDuration = ' 
				(select cast(sum(durations.Duration) as bigint)  
				from 
					(select (select sum(isnull(d.Duration, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) durations)
				';
		END

		DECLARE @localQuery VARCHAR(max) = 
			'SELECT
				count(*) Funds,
				sum(isnull(fsi.EnrolledInventoryCount, 0)) Inventories,
				sum(isnull(fsi.EnrolledArchivalEntityCount, 0)) ArchiveEntities,
				null LinearMeters,
				cast(sum(isnull(fsi.EnrolledBytes, 0)) as bigint) Size,'
				+ @totalDuration + ' Duration,
				sum(isnull(fsi.EnrolledDocumentCount, 0)) EDocumentsCount
			FROM Funds f
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier AND fsi.IsDraft = 0
			WHERE'
				+ @localQueryWhereClause +
				+ @DateFromCondition +
				+ @DateToCondition;
    END

	declare @sql varchar(max);

	IF @ResultType = 1 
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				Funds int NULL,
				Inventories int NULL,
				ArchiveEntities int NULL,
				LinearMeters decimal(18, 2) NULL,
				Size bigint NULL,
				Duration bigint NULL,
				EDocumentsCount int NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT 
				sum(u.Funds) as Funds, 
				sum(u.Inventories) as Inventories, 
				sum(u.ArchiveEntities) as ArchiveEntities, 
				sum(isnull(cast(u.LinearMeters as decimal(18,2)), 0)) as LinearMeters,
				cast(sum(isnull(u.Size, 0)) as bigint) as Size,
				cast(sum(u.Duration) as bigint) as Duration,
				sum(u.EDocumentsCount) as EDocumentsCount
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery;
	END

	exec (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfRoughDocumentsReportSummary]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 5000,
	@Page int = 1,
	@Archives nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null,
	@MethodsOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
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
				FundNumber nvarchar(255) NULL,
				FundTitle nvarchar(max) NULL,
				EntryDate varchar(50) NULL,
				RoughInventoryNumber nvarchar(255) NULL,
				AcquisitionMethod nvarchar(max) NULL,
				[Status] nvarchar(255) NULL,
				LinearMeters decimal NULL,
				Bytes decimal NULL,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
			);

	INSERT INTO #temp(
				CountryCode,
				Archive,
				FundNumber,
				FundTitle,
				EntryDate,
				RoughInventoryNumber,
				AcquisitionMethod,
				[Status],
				LinearMeters,
				Bytes,
				SystemIdentifier,
				ExternalIdentifier,
				HasExternalSource
			)
	EXEC [sp_GetListOfRoughDocumentsReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page,
		@Archives,
		@FundTypeGids,
		@FundTypesInternal,
		@IndustryIndexGids,
		@IndustryIndexesInternal,
		@MethodsOfAcquisitionGids,
		@MethodsOfAcquisitionInternal,
		@Statuses,
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

CREATE OR ALTER PROCEDURE [dbo].[GetWorkDoneOnDigitalObjectsReport] 
	@ArchiveCodes VARCHAR(MAX) = NULL,
	@FundArrays VARCHAR(MAX) = NULL,
	@UserIds VARCHAR(MAX) = NULL,
	@ProcessSteps VARCHAR(MAX) = NULL,
	@DigitalObjectStatuses VARCHAR(MAX) = NULL,
	@CreatedFrom VARCHAR(100) = NULL,
	@CreatedTo VARCHAR(100) = NULL,
	@RowsOfPage INT = 5000,
	@Page INT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	SELECT 
		u.DisplayName UserName, 
		a.Name Archive, 
		COUNT(1) DigitalObjectsCount,
		(SELECT SUM(u) FROM (
			SELECT 
			1 u
			FROM DigitalObjects do
			INNER JOIN Archives a on a.Id = do.ArchiveId
			INNER JOIN Funds f on f.SystemIdentifier = do.FundSystemIdentifier
			INNER JOIN Documents d on d.SystemIdentifier = do.DocumentSystemIdentifier
			LEFT JOIN Process p on p.DocumentSystemIdentifier = d.SystemIdentifier
			LEFT JOIN ProcessTimeline ptl on ptl.ProcessId = p.Id
			INNER JOIN N.ProcessTypes pt on pt.Id = p.ProcessTypeId
			INNER JOIN N.ProcessSteps ps on ps.Id = ptl.StepTypeId
			LEFT JOIN AspNetUsers u on u.Id = ptl.AssignedToUserId
			WHERE pt.Code = 'PreparationOfADigitalObject'
				AND (ps.Code = 'PreparationOfADigitalObject' or ps.Code = 'QualityControl')
				AND (@ArchiveCodes = '-999' OR a.Code IN (SELECT element FROM dbo.SplitString(@ArchiveCodes, ',')))
				AND (@FundArrays = '-999' OR f.NumberArray IN (SELECT element FROM dbo.SplitString(@FundArrays, ',')))
				AND (@UserIds = '-999' OR ptl.AssignedToUserId IN (SELECT element FROM dbo.SplitString(@UserIds, ',')))
				AND (@ProcessSteps = '-999' OR ps.Code IN (SELECT element FROM dbo.SplitString(@ProcessSteps, ',')))
				AND (@DigitalObjectStatuses = '-999' 
					OR do.Deleted = 0 AND 1 IN (SELECT element FROM dbo.SplitString(@DigitalObjectStatuses, ','))
					OR do.Deleted = 1 AND 2 IN (SELECT element FROM dbo.SplitString(@DigitalObjectStatuses, ',')))
				AND (@CreatedFrom IS NULL OR @CreatedFrom <= do.CreatedOn)
				AND (@CreatedTo IS NULL OR @CreatedTo >= do.CreatedOn)
			GROUP BY a.Code, a.SortOrder, a.Name, ptl.AssignedToUserId, u.DisplayName) t) TotalCount
	FROM DigitalObjects do
	INNER JOIN Archives a on a.Id = do.ArchiveId
	INNER JOIN Funds f on f.SystemIdentifier = do.FundSystemIdentifier
	INNER JOIN Documents d on d.SystemIdentifier = do.DocumentSystemIdentifier
	LEFT JOIN Process p on p.DocumentSystemIdentifier = d.SystemIdentifier
	LEFT JOIN ProcessTimeline ptl on ptl.ProcessId = p.Id
	INNER JOIN N.ProcessTypes pt on pt.Id = p.ProcessTypeId
	INNER JOIN N.ProcessSteps ps on ps.Id = ptl.StepTypeId
	LEFT JOIN AspNetUsers u on u.Id = ptl.AssignedToUserId
	WHERE pt.Code = 'PreparationOfADigitalObject'
		AND (ps.Code = 'PreparationOfADigitalObject' or ps.Code = 'QualityControl')
		AND (@ArchiveCodes = '-999' OR a.Code IN (SELECT element FROM dbo.SplitString(@ArchiveCodes, ',')))
		AND (@FundArrays = '-999' OR f.NumberArray IN (SELECT element FROM dbo.SplitString(@FundArrays, ',')))
		AND (@UserIds = '-999' OR ptl.AssignedToUserId IN (SELECT element FROM dbo.SplitString(@UserIds, ',')))
		AND (@ProcessSteps = '-999' OR ps.Code IN (SELECT element FROM dbo.SplitString(@ProcessSteps, ',')))
		AND (@DigitalObjectStatuses = '-999' 
			OR do.Deleted = 0 AND 1 IN (SELECT element FROM dbo.SplitString(@DigitalObjectStatuses, ','))
			OR do.Deleted = 1 AND 2 IN (SELECT element FROM dbo.SplitString(@DigitalObjectStatuses, ',')))
		AND (@CreatedFrom IS NULL OR @CreatedFrom <= do.CreatedOn)
		AND (@CreatedTo IS NULL OR @CreatedTo >= do.CreatedOn)
	GROUP BY a.Code, a.SortOrder, a.Name, ptl.AssignedToUserId, u.DisplayName
	ORDER BY a.SortOrder
	OFFSET @offset ROWS FETCH NEXT @RowsOfPage ROWS ONLY;
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetFundsListInternalReport] 
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
				null as SystemIdentifier,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource
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
				fund.SystemIdentifier,
				fund.ExternalIdentifier,
				fund.HasExternalSource
			FROM Funds fund 
			INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
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
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundsListInternalReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(max) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = 
			'SELECT COUNT_BIG(*) TotalRows
			FROM Fund_Modified as fund	
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Funds 
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode = 1
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery;
	END

	EXEC (@sql);
END
GO

commit
--rollback