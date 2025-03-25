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