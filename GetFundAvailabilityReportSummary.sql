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