SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.14'
where Code = 'DB_VERSION'

-- add scripts here

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetPartialReceiptsPublicReportSummary] 
	@LinkedServer nvarchar(50),
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
			COUNT(*) TotalFunds,
			sum(isnull(fund.InvetoryCount, 0)) TotalInventories,
			sum(isnull(fund.AECount, 0)) TotalArchiveEntities,
			sum(fund.LinearMeters) TotalLinearMeters,
			cast((select sum(sizes.Size) 
				from 
					(select (select sum(isnull(i.ByteLenght, 0)) 
						from Image i
						inner join Document_Modified d
						on i.DocumentGid = d.Gid
						where d.FundLGid = fund.LGid) as Size
						from [Archiving].[dbo].[Fund_Modified] fund
						WHERE ' + @remoteQueryWhereClause + '
					) sizes) * 0.000001 as decimal(10,2)) TotalSize
		FROM [Archiving].[dbo].Fund_Modified as fund
		WHERE ' + @remoteQueryWhereClause;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @localQueryWhereClause VARCHAR(max) = '
		ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
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
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))';

	
	DECLARE @localQuery VARCHAR(max) = 
		'SELECT
			COUNT(*) TotalFunds,
			sum(isnull(InventoryCount, 0)) TotalInventories,
			sum(isnull(ArchivalEntityCount, 0)) TotalArchiveEntities,
			SUM(LinearMeters) TotalLinearMeters,
			cast((select sum(sizes.Size) 
				from 
					(select (select sum(isnull(d.Bytes, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Size
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) sizes) as decimal(10, 2)) TotalSize -- въпреки че колоната се казва Bytes, тя съдържа MB, затова няма превръщане на мерните ед.
				FROM Funds f
				WHERE ' + @localQueryWhereClause;

	declare @sql varchar(max) = '
		DECLARE @remoteFundsTable TABLE ( 
			TotalFunds bigint NULL,
			TotalInventories bigint NULL,
			TotalArchiveEntities bigint NULL,
			TotalLinearMeters float NULL,
			TotalSize decimal NULL
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
		SELECT 
			sum(u.TotalFunds) as TotalFunds, 
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

	exec (@sql);
END
GO

----------------------------------------------------------
--	THE SCRIPT IS CLOSED - USE THE NEW ONE!
----------------------------------------------------------

commit