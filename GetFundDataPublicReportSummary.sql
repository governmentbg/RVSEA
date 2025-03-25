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