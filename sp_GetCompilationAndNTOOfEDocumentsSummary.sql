USE [DAA]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetCompilationAndNTOOfEDocumentsSummary]    Script Date: 28.9.2022 г. 16:18:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCompilationAndNTOOfEDocumentsSummary] 
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

	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ProcessGids nvarchar(max) = null,
	@ProcessTypes nvarchar(max) = null,

	@FileFormats nvarchar(max) = null
AS
BEGIN

	SET NOCOUNT ON;


	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Fund_Modified as fund
			WHERE		((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) 
						OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) 
					OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) 
					OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
					OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) 
					OR fund.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
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
	END
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Funds 
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
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

	--print @sql;
	EXEC (@sql);
END
--GO
