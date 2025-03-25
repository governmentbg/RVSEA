USE [DAA]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetCompilationAndNTOOfEDocumentsReport]    Script Date: 6.10.2022 г. 15:43:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCompilationAndNTOOfEDocumentsReport]
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
	@ArchiveCodesInternal nvarchar(10) = null,
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

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by Archive asc, FundNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
    	
	IF @ResultType = 2 OR @ResultType = 1
	BEGIN

		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT
			(select a.Name from dbo.Archive as a where a.Gid = fund.ArchiveGid) as Archive,
			convert(nvarchar(256), fund.Number) as FundNumber,
			fund.Title as Title,
			STUFF(
				(select ''; '' + n.Value 
				   from ObjectNomenclature as obj 
				   join Nomenclature as n 
				     on n.Gid = obj.NomenclatureGid 
				  where obj.FundGid = fund.Gid for XML PATH('''')), 1, 1, '''') as MethodOfAcquisitions,
			(select n.Value from dbo.Nomenclature as n where n.Gid = fund.TypeGid) as Type,
			CAST(fund.TextDate as nvarchar(256)) as ChronologicalScope,
			CAST(fund.CreatedOn as nvarchar(256)) as DateOfFiling,
			(select n.Value from dbo.Nomenclature as n where n.Gid = fund.StatusGid) as Status,
			(select n.Value from dbo.Nomenclature as n where n.Gid = fund.LevelOfDescriptionGid) as LevelOfDescription,
			fund.InvetoryCount as InventoryCount,
			fund.AECount as AeCount,
			(select COUNT(d._id) from Document as d where d.FundLGid = fund.Gid) as DocumentCount,
			NULL as FileFormats,
			NULL as Mb,
			NULL as Duration,
			fund.Note as Note
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
				AND((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) 
					OR fund.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
					OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
					OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) 
					OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessGids + ''', '',''))) 
					OR fund.ProcessGid in (select element from dbo.SplitString(''' + @ProcessGids + ''', '','')))
					
			    AND ((''' + COALESCE(@ProcessStartDate, 'null') + ''' = ''null'') 
					OR (cast((select Process.CreatedOn from Process where fund.ProcessGid = Process._id) as date) >= cast(''' + COALESCE(@ProcessStartDate, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@ProcessEndDate, 'null') + ''' = ''null'') 
					OR (cast((select Process.ModifiedOn from Process where fund.ProcessGid = Process._id) as date) <= cast(''' + COALESCE(@ProcessEndDate, 'null') + ''' as datetime2)))';	

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN

		DECLARE @localQuery VARCHAR(MAX) =  '
		SELECT
			(select a.Name from dbo.Archives as a where a.Id = funds.ArchiveId) as Archive,
			funds.Number as FundNumber,
			funds.Title as Title,
			STUFF(
				(select ''; '' + v.ValueCode  
				   from NomenclatureValues as v 
				  where v.EntityId = funds.Id and v.EntityType = ''fund'' and v.NomenclatureCode = ''ACQUISITION_METHOD'' and v.Deleted = 0 for XML PATH('''')), 1, 1, '''') as MethodOfAcquisitions,
			(select n.Text from N.Nomenclatures as n where n.Id = funds.TypeCode and n.Deleted = 0) as Type,
			CAST(funds.ApproxmateChronologicalScope as nvarchar(256)) as ChronologicalScope,
			CAST(funds.CreatedOn as nvarchar(256)) as DateOfFiling,
			(select n.Text from N.Nomenclatures as n where n.Id = funds.StatusCode and n.Deleted = 0) as Status,
			(select n.Text from N.Nomenclatures as n where n.Id = funds.DescriptionLevelCode and n.Deleted = 0) as LevelOfDescription,
			funds.InventoryCount as InventoryCount,
			funds.ArchivalEntityCount as AeCount,
			funds.DocumentCount as DocumentCount,
			--STRING_AGG((select n.Text from N.Nomenclatures as n join Documents as d on n.Id = d.FileFormatCode where d.FundSystemIdentifier = funds.SystemIdentifier and n.Deleted = 0), ''; '') as FileFormats,
			--STUFF(
			--	(select DISTINCT ''; '' + n.Text
			--		  from N.Nomenclatures as n
			--		  join Documents as d
			--		    on n.Id = d.FileFormatCode
			--		  where d.FundSystemIdentifier = funds.SystemIdentifier and n.Deleted = 0 for XML PATH('''')), 1, 1, '''') as FileFormats,
			STUFF((select n.Text + '';''
                        from  NomenclatureValues nv
                        join N.Nomenclatures n
                        on nv.ValueCode = n.Code
                        where nv.EntityType=''fund''
							and n.Deleted = 0
							and nv.Deleted = 0
                            and nv.NomenclatureCode=''FILE_TYPE''
                            and nv.EntityId=funds.Id
                            and nv.EntityType=''fund''
                            and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE'')
                        FOR XML path(''''), elements), 1, 1, '''') as FileFormats,
			CAST((select SUM(d.Bytes) * 0.000001 from Documents as d where d.FundSystemIdentifier = funds.SystemIdentifier) as float) as Mb,
			--CAST((select SUM(CAST(d.Duration as int)) from Documents as d where d.FundSystemIdentifier = funds.SystemIdentifier) as nvarchar(256)) as Duration,
			CAST(dbo.FormatDuration((select sum(d.Duration) from Documents d where funds.SystemIdentifier = d.FundSystemIdentifier)) as nvarchar(256)) as Duration,
			--NULL as Duration,
			funds.Notes as Note
			FROM Funds as funds
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
					OR ((select convert(varchar(4), n.Text, 104) from NomenclatureValues as v join N.Nomenclatures as n on n.Id = v.NomenclatureId where v.EntityId = funds.Id and v.EntityType = ''fund'' and v.NomenclatureCode = ''ACQUISITION_METHOD''and n.Deleted = 0 and v.Deleted = 0) in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
				    OR (''-998'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
					OR ((select convert(varchar(4), Id, 104) from Process as p where p.FundSystemIdentifier = funds.SystemIdentifier and p.Deleted = 0 and p.Completed = 1) in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))))	
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
                        and n.Deleted=0 and nv.Deleted=0) INTERSECT (select element from dbo.SplitString(''' + @FileFormats + ''', '','')))))';
				
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Archive nvarchar(256) NULL,
				FundNumber nvarchar(256) NULL,
				Title nvarchar(MAX) NULL,
				MethodOfAcquisitions nvarchar(256) NULL,
				Type nvarchar(256) NULL,
				ChronologicalScope nvarchar(256) NULL,
				DateOfFiling nvarchar(256) NULL,
				Status nvarchar(256) NULL,
				LevelOfDescription nvarchar(256) NULL,
				InventoryCount int NULL,
				AeCount int NULL,
				DocumentCount int NULL,
				FileFormats nvarchar(256) NULL,
				Mb float NULL,
				Duration nvarchar(256) NULL,
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

	--print @sql;
	EXEC (@sql);
END
--GO
