SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.23'
where Code = 'DB_VERSION'
go

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
			'''' as DocumentLink, -- Link_todo
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
			''Link_todo'' as DocumentLink,
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
			(select n.Text from N.Nomenclatures as n where n.Id = d.StatusCode and n.Deleted = 0) as DocStatus,
			CAST((select top(1) convert(varchar, do.CreatedOn, 104) from DigitalObjects as do where do.DocumentSystemIdentifier = d.SystemIdentifier) as nvarchar(50)) as CreationDateDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
			d.DigitizedCopyCount as RecordsCountDO,
			CAST(d.Duration as nvarchar(256)) as Duration,
			NULL as DigitalObjectRecreationDate,
			isnull(d.Bytes, 0) as BytesDO,
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
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
			  AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
			  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			  AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast((select top 1 DATEFROMPARTS(d.[StartDateYear], d.[StartDateMonth], d.[StartDateDay]) as result from Documents as d) as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			  AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast((select top 1 DATEFROMPARTS(d.[EndDateYear], d.[EndDateMonth], d.[EndDateDay]) as result from Documents as d) as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))'

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
				sum(isnull(InventoryCount, 0)) TotalInventories,
				sum(isnull(ArchivalEntityCount, 0)) TotalArchiveEntities,
				round(sum(LinearMeters), 2) TotalLinearMeters,
				(select sum(sizes.Size) 
				from 
					(select f.Bytes as Size
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) sizes) TotalSize, -- въпреки че колоната се казва Bytes, тя съдържа MB, затова няма превръщане на мерните ед.'
				+ @totalDuration + ' TotalDuration
			FROM Funds f
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
			COUNT(*) TotalFunds,
			sum(isnull(fund.InvetoryCount, 0)) TotalInventories,
			sum(isnull(fund.AECount, 0)) TotalArchiveEntities,
			sum(fund.LinearMeters) TotalLinearMeters,
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
						OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
					AND (select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) <> ''12''
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
				COUNT_BIG(*) TotalFunds,
				cast(sum(isnull(InventoryCount, 0)) as bigint) TotalInventories,
				cast(sum(isnull(ArchivalEntityCount, 0)) as bigint) TotalArchiveEntities,
				SUM(LinearMeters) TotalLinearMeters,
				(select sum(sizes.Size) 
					from 
						(select (select sum(isnull(d.Bytes, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Size
							from Funds f
							WHERE ' + @localQueryWhereClause + '
						) sizes) TotalSize
					FROM Funds f
					WHERE ' + @localQueryWhereClause;
				
	END

	declare @sql varchar(max);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalFunds bigint NULL,
				TotalInventories bigint NULL,
				TotalArchiveEntities bigint NULL,
				TotalLinearMeters float NULL,
				TotalSize bigint NULL
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

CREATE OR ALTER PROCEDURE [dbo].[GetRegisterOfDigitalObjectsPublicReportSummary] 
	@LinkedServer nvarchar(50),
    @ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
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
					AND ((''active'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1 and isnull(DigitalObjectDeleted, 0) = 0))
						OR (''deleted'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1 and isnull(DigitalObjectDeleted, 0) = 1))
						OR (''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1)))
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
						AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
							OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = do.StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
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
				SUM(round(isnull(cast(fund.LinearMeters as decimal(18,2)), 0),2)) TotalLinearMeters,
								--(select sum(sizes.Size) 
				--from 
					--(select (select sum(isnull(i.ByteLenght, 0)) 
						--from Image i
						--inner join Document_Modified d
						--on i.DocumentGid = d.Gid
						--where d.FundLGid = fund.LGid) as Size
						--from [Archiving].[dbo].[Fund_Modified] fund
						--WHERE + @remoteQueryWhereClause +
					--) sizes) TotalSize
				cast(0 as bigint) TotalSize -- по искане на клиента не се отчита
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
		DECLARE @localQuery VARCHAR(max) = '
			SELECT
			COUNT_BIG(*) TotalRows,
			SUM(round(isnull(cast(LinearMeters as decimal(18,2)), 0),2)) TotalLinearMeters,
			SUM(f.Bytes) TotalSize
			FROM Funds f
			WHERE ' + @localQueryWhereClause;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL,
				TotalLinearMeters decimal NULL,
				TotalSize bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows, sum(u.TotalLinearMeters) as TotalLinearMeters, sum(isnull(u.TotalSize, 0)) as TotalSize
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
				sum(isnull(InventoryCount, 0)) TotalInventories,
				sum(isnull(ArchivalEntityCount, 0)) TotalArchiveEntities,
				sum(f.Bytes) TotalSize,' + 
				@totalDuration + 'TotalDuration,
				round(sum(LinearMeters), 2) TotalLinearMeters
			FROM Funds f
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

if not exists (select null from sys.columns where name = 'HashCode' and object_id = object_id ('dbo.PackageDocument'))
begin 
	alter table dbo.PackageDocument add HashCode nvarchar(100)
end
go


if not exists (select null from sys.columns where name = 'ChecksumCheckResult' and object_id = object_id ('dbo.PackageDocument'))
begin 
	alter table dbo.PackageDocument add ChecksumCheckResult bit
end
go


if not exists (select null from sys.columns where name = 'FileFormatCheckResult' and object_id = object_id ('dbo.PackageDocument'))
begin 
	alter table dbo.PackageDocument add FileFormatCheckResult bit
end
go


if not exists (select null from sys.columns where name = 'AntivirusCheckResult' and object_id = object_id ('dbo.PackageDocument'))
begin 
	alter table dbo.PackageDocument add AntivirusCheckResult bit
end
go


if not exists (select null from sys.columns where name = 'AntivirusCheckInfo' and object_id = object_id ('dbo.PackageDocument'))
begin 
	alter table dbo.PackageDocument add AntivirusCheckInfo nvarchar(2000)
end
go

if not exists (select null from sys.columns where name = 'FileInfo' and object_id = object_id ('dbo.PackageDocument'))
begin 
	alter table dbo.PackageDocument add FileInfo nvarchar(2000)
end
go

if not exists (select null from sys.columns where name = 'ErrorMessage' and object_id = object_id ('dbo.PackageDocument'))
begin 
	alter table dbo.PackageDocument add ErrorMessage nvarchar(2000)
end
go

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
				round(cast(SUM(isnull(fund.LinearMeters, 0)) as decimal(18, 2)), 2) TotalLinearMeters
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
				COUNT(*) TotalFunds,
				sum(isnull(InventoryCount, 0)) TotalInventories,
				sum(isnull(ArchivalEntityCount, 0)) TotalArchiveEntities,
				sum(f.Bytes) TotalSize,' + 
				@totalDuration + 'TotalDuration,
				cast(0 as decimal(18, 2)) TotalLinearMeters
			FROM Funds f
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
				TotalDuration nvarchar(14) NULL,
				TotalLinearMeters decimal(18, 2) NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT 
				sum(u.TotalFunds) as TotalFunds, 
				sum(u.TotalInventories) as TotalInventories, 
				sum(u.TotalArchiveEntities) as TotalArchiveEntities, 
				sum(u.TotalSize) as TotalSize, 
				dbo.FormatDuration(sum(u.TotalDuration)) as TotalDuration,
				round(cast(sum(u.TotalLinearMeters) as decimal(18, 2)), 2) as TotalLinearMeters
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
				a.SortOrder
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
					(select n.Text + '';''
						from  NomenclatureValues nv
						join N.Nomenclatures n
						on nv.ValueCode=n.Code
						where nv.EntityType=''fund'' 
							and nv.NomenclatureCode=''ACQUISITION_METHOD'' 
							and nv.EntityId=f.Id
							and nv.EntityType=''fund''
							and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''ACQUISITION_METHOD'')
							and n.Deleted=0 and nv.Deleted=0
						FOR XML path(''''), elements) as MethodOfAcquisition,
				f.ApproxmateChronologicalScope as TextDate,
				convert(varchar, f.CreatedOn, 104) as CreationDate,
				(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus,
				(SELECT Text FROM [N].[FundDescriptionLevel] dl where dl.Code = f.DescriptionLevelCode) as LevelOfDescription,
				f.InventoryCount,
				f.ArchivalEntityCount as AECount,
				DocumentCount,
				(select n.Text + '';''
					from  NomenclatureValues nv
					join N.Nomenclatures n
					on nv.ValueCode=n.Code
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode=''FILE_TYPE'' 
						and nv.EntityId=f.Id
						and nv.EntityType=''fund''
						and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE''
						and n.Deleted=0 and nv.Deleted=0)
					FOR XML path(''''), elements) as FileFormats,
				fsi.EnrolledBytes as Size,
				dbo.FormatDuration((select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier)) as Duration,
				null as LinearMeters,
				f.Notes as Note,
				f.NumberNumeric as IntNumber,
				a.SortOrder
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			INNER JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode IN(1, 2, 3) 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0 -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
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
				f.Bytes as DigitalSize,
				cast((select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as bigint) as Duration,
				f.InventoryCount,
				f.ArchivalEntityCount as AECount,
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
				(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
						and nv.EntityId=f.Id
					FOR XML path(''''), elements) as MethodOfAcquisition,
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
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
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

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка

	SET @RowsOfPage = 2147483647
	SET @Page = 1

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT top 1
			(select top 1 (cast(cast(do.StartDate as date) as nvarchar(50))) as theDate 
				from Document_Modified as do 
				inner join Archive a ON a.Gid = do.ArchiveGid AND a._retired = ''3000-01-01'' 
				WHERE ISNULL(do.HasDigitalObject, 0) = 1
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(do.StartDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(do.EndDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				ORDER BY theDate) 
			as PeriodFrom,
			(select top 1 (cast(cast(do.EndDate as date) as nvarchar(50))) as theDate 
				from Document_Modified as do 
				inner join Archive a ON a.Gid = do.ArchiveGid AND a._retired = ''3000-01-01'' 
				WHERE ISNULL(do.HasDigitalObject, 0) = 1
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(do.StartDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(do.EndDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				ORDER BY theDate DESC) 
			as PeriodTo,
			NULL as Employee
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
		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT TOP 1
			(select top 1 cast(DATEFROMPARTS(dt.[StartDateYear], dt.[StartDateMonth], dt.[StartDateDay]) as nvarchar(50)) as theDate
				FROM Documents as dt
				INNER JOIN Archives a ON a.Id = dt.ArchiveId AND a.Deleted = 0
				WHERE dt.ExternalIdentifier IS NULL AND dt.HasExternalSource = 0 AND dt.Deleted = 0 
				  AND exists(select 1 from DocumentDigitalObjects do where dt.Id = do.DocumentId)
				  AND cast(DATEFROMPARTS(dt.[StartDateYear], dt.[StartDateMonth], dt.[StartDateDay]) as nvarchar(50)) IS NOT NULL
				  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
				  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				  AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[StartDateYear], d.[StartDateMonth], d.[StartDateDay]) as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				  AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[EndDateYear], d.[EndDateMonth], d.[EndDateDay]) as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				ORDER BY theDate
			) as PeriodFrom,
			(select top 1 cast(DATEFROMPARTS(dt.[EndDateYear], dt.[EndDateMonth], dt.[EndDateDay]) as nvarchar(50)) as theDate
				FROM Documents as dt
				INNER JOIN Archives a ON a.Id = dt.ArchiveId AND a.Deleted = 0
				WHERE dt.ExternalIdentifier IS NULL AND dt.HasExternalSource = 0 AND dt.Deleted = 0 
				  AND exists(select 1 from DocumentDigitalObjects do where dt.Id = do.DocumentId)
				  AND cast(DATEFROMPARTS(dt.[EndDateYear], dt.[EndDateMonth], dt.[EndDateDay]) as nvarchar(50)) IS NOT NULL
				  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
				  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				 AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[StartDateYear], d.[StartDateMonth], d.[StartDateDay]) as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				 AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(DATEFROMPARTS(d.[EndDateYear], d.[EndDateMonth], d.[EndDateDay]) as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				ORDER BY theDate DESC
			)  as PeriodTo,
			NULL as Employee
		FROM Documents as d
		INNER JOIN Archives a ON a.Id = d.ArchiveId AND a.Deleted = 0
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
			(select n.Text from N.Nomenclatures as n where n.Id = d.StatusCode and n.Deleted = 0) as DocStatus,
			CAST((select top(1) convert(varchar, do.CreatedOn, 104) from DigitalObjects as do where do.DocumentSystemIdentifier = d.SystemIdentifier) as nvarchar(50)) as CreationDateDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
			d.DigitizedCopyCount as RecordsCountDO,
			CAST(d.Duration as nvarchar(256)) as Duration,
			NULL as DigitalObjectRecreationDate,
			isnull(d.Bytes, 0) as BytesDO,
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundMemoriesListInternalReport] 
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
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
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
				(select n.Text + '';''
						from  NomenclatureValues nv
						join N.Nomenclatures n
						on nv.ValueCode=n.Code
						where nv.EntityType=''fund'' 
							and nv.NomenclatureCode=''FILE_TYPE'' 
							and nv.EntityId=f.Id
							and nv.EntityType=''fund''
							and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE''
							and n.Deleted=0 and nv.Deleted=0)
						FOR XML path(''''), elements) as FileFormats,
				(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
				f.Notes as Note,
				f.NumberNumeric as IntNumber,
				a.SortOrder,
				convert(varchar(50), f.SystemIdentifier, 104) as SystemIdentifier,
				convert(bit, 0) as HasExternalSource,
				NULL as ExternalIdentifier
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			INNER JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 3 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = f.TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
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
			INNER JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
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
					null as FileFormats
				FROM Fund_Modified as fund
				INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
				WHERE fund._retired = ''3000-01-01''
					AND fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 2)
					AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives + ''', '',''))) OR a.Code in  (select element from dbo.SplitString(''' + @Archives + ''', '','')))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) OR (select Code from Nomenclature where _retired=''3000-01-01'' and Gid = fund.StatusGid) in (select element from dbo.SplitString(''' + @Statuses + ''', '','')))
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
				,CONCAT(DocumentsProvider, '' / '',(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund''
						and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
						and nv.EntityId=f.Id
					FOR XML path(''''), elements)) as ImmediateSourceOfAcquisition
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
				,f.InventoryCount as InventoryCount
				,f.ArchivalEntityCount as AeCount
				,null as LinearMeters
				,f.EnrolledBytes as Size
				,dbo.FormatDuration((select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier)) as Duration
				,(select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as DurationInt
				,fsi.EnrolledDocumentCount as EDocumentsCount
				,(select n.Text + '';''
					from  NomenclatureValues nv
					join N.Nomenclatures n
					on nv.ValueCode=n.Code
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode=''FILE_TYPE'' 
						and nv.EntityId=f.Id
						and nv.EntityType=''fund''
						and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE''
						and n.Deleted=0 and nv.Deleted=0)
					FOR XML path(''''), elements) as FileFormats
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			INNER JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 4
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives  + ''', '',''))) 
					OR a.Code in (select element from dbo.SplitString(''' + @Archives + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '','')) AND f.StatusCode not in (''3'', ''4'',''5'', ''8'', ''9'', ''10'', ''13'')) 
					OR (convert(varchar(4), f.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0 -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
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
				FileFormats nvarchar(MAX) NULL
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

-- Fund and Inventory Arrays
ALTER TABLE FundDrafts DROP CONSTRAINT IF EXISTS [FK_FundDrafts_Array]
GO

ALTER TABLE Funds DROP CONSTRAINT IF EXISTS [FK_Funds_Array]
GO


UPDATE N.FundArray SET Code = 'Без индекс' WHERE Code = ''

UPDATE FundDrafts SET NumberArray = 'Без индекс' WHERE NumberArray = ''

UPDATE Funds SET NumberArray = 'Без индекс' WHERE NumberArray = ''

ALTER TABLE [dbo].[FundDrafts]  WITH CHECK ADD CONSTRAINT [FK_FundDrafts_Array] FOREIGN KEY([NumberArray])
REFERENCES [N].[FundArray] ([Code])
GO

ALTER TABLE [dbo].[FundDrafts] CHECK CONSTRAINT [FK_FundDrafts_Array]
GO

ALTER TABLE [dbo].[Funds]  WITH CHECK ADD CONSTRAINT [FK_Funds_Array] FOREIGN KEY([NumberArray])
REFERENCES [N].[FundArray] ([Code])
GO

ALTER TABLE [dbo].[Funds] CHECK CONSTRAINT [FK_Funds_Array]
GO


--Inventories
ALTER TABLE InventoryDrafts DROP CONSTRAINT IF EXISTS [FK_InventoryDrafts_Array]
GO

ALTER TABLE Inventories DROP CONSTRAINT IF EXISTS [FK_Inventories_Array]
GO

ALTER TABLE InventoryDrafts ALTER COLUMN [NumberArray] nvarchar(50)
GO

ALTER TABLE Inventories ALTER COLUMN [NumberArray] nvarchar(50)
GO


UPDATE N.InventoryArray SET Code = 'Без индекс' WHERE Code = ''

UPDATE InventoryDrafts SET NumberArray = 'Без индекс' WHERE NumberArray = ''

UPDATE Inventories SET NumberArray = 'Без индекс' WHERE NumberArray = ''

ALTER TABLE [dbo].[InventoryDrafts]  WITH CHECK ADD  CONSTRAINT [FK_InventoryDrafts_Array] FOREIGN KEY([NumberArray])
REFERENCES [N].[InventoryArray] ([Code])
GO

ALTER TABLE [dbo].[InventoryDrafts] CHECK CONSTRAINT [FK_InventoryDrafts_Array]
GO

ALTER TABLE [dbo].[Inventories]  WITH CHECK ADD CONSTRAINT [FK_Inventories_Array] FOREIGN KEY([NumberArray])
REFERENCES [N].[InventoryArray] ([Code])
GO

ALTER TABLE [dbo].[Inventories] CHECK CONSTRAINT [FK_Inventories_Array]
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
			(select n.Text + '';''
				from  NomenclatureValues nv
				join N.Nomenclatures n on n.Code=nv.NomenclatureCode
				where nv.EntityType=''fund'' 
					and n.Deleted = 0
					and nv.Deleted = 0
					and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
					and nv.EntityId=funds.Id
				FOR XML path(''''), elements) as MethodOfAcquisitions,
			(select t.Text from N.FundType as t where t.Code = funds.TypeCode) as Type,
			CAST(funds.ApproxmateChronologicalScope as nvarchar(256)) as ChronologicalScope,
			funds.CreatedOn as DateOfFiling,
			(select s.Text from N.Status as s where s.Code = funds.StatusCode) as Status,
			(select dl.Text from N.FundDescriptionLevel as dl where dl.Code = funds.DescriptionLevelCode) as LevelOfDescription,
			funds.InventoryCount as InventoryCount,
			CAST(funds.ArchivalEntityCount as int) as AeCount,
			funds.DocumentCount as DocumentCount,
			--STRING_AGG((select n.Text from N.Nomenclatures as n join Documents as d on n.Id = d.FileFormatCode where d.FundSystemIdentifier = funds.SystemIdentifier and n.Deleted = 0), ''; '') as FileFormats,
			--STUFF(
			--	(select DISTINCT ''; '' + n.Text
			--		  from N.Nomenclatures as n
			--		  join Documents as d
			--		    on n.Id = d.FileFormatCode
			--		  where d.FundSystemIdentifier = funds.SystemIdentifier and n.Deleted = 0 for XML PATH('''')), 1, 1, '''') as FileFormats,
			(select n.Text + '';''
				from  NomenclatureValues nv
				join N.Nomenclatures n
				on nv.ValueCode = n.Code
				where nv.EntityType=''fund''
					and n.Deleted = 0
					and nv.Deleted = 0
					and nv.NomenclatureCode=''FILE_TYPE''
					and nv.EntityId=funds.Id
					and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE'')
				FOR XML path(''''), elements) as FileFormats,
			(select SUM(d.Bytes) from Documents as d where d.FundSystemIdentifier = funds.SystemIdentifier) as Bytes,
			--CAST((select SUM(CAST(d.Duration as int)) from Documents as d where d.FundSystemIdentifier = funds.SystemIdentifier) as nvarchar(256)) as Duration,
			CAST(dbo.FormatDuration((select sum(d.Duration) from Documents d where funds.SystemIdentifier = d.FundSystemIdentifier)) as nvarchar(256)) as Duration,
			--NULL as Duration,
			funds.Notes as Note,
			funds.NumberNumeric as IntNumber,
			a.SortOrder
		FROM Funds as funds
		INNER JOIN Archives a ON a.Id = funds.ArchiveId AND a.Deleted = 0
		WHERE funds.ExternalIdentifier IS NULL AND funds.HasExternalSource = 0 AND funds.Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR (funds.NumberArray in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
				OR ((select top 1 convert(varchar(4), n.Text, 104) from NomenclatureValues as v join N.Nomenclatures as n on n.Id = v.NomenclatureId where v.EntityId = funds.Id and v.EntityType = ''fund'' 
					and v.NomenclatureCode = ''ACQUISITION_METHOD''and n.Deleted = 0 and v.Deleted = 0) in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
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
				null as EDocumentsCount,
				round(cast(isnull(inv.LinearMeter, 0) as decimal(18, 2)) ,2) as LinearMeters,
				NULL as FileFormat,
				NULL as Duration,
				null as Bytes
				FROM Inventory as inv
				inner join Fund_Modified as fund on inv.FundLGid = fund.LGid
				inner join Archive a on inv.ArchiveGid = a.Gid
			WHERE
				fund._retired = ''3000-01-01''
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
				AND inv.LevelOfDescriptionGid in(
				2171, -- Inventory
				2172  -- InventoryRough
			)
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
				,(SELECT COUNT(*) FROM v_ArchivalEntities as ae where InventorySystemIdentifier = i.SystemIdentifier and ISNUMERIC(RIGHT(ae.Number,1)) = 0) as AeWithCharCount
				,isi.EnrolledDocumentCount as EDocumentsCount
				,null as LinearMeters
				,STUFF((select n.Text + ''; ''
						from  NomenclatureValues nv
						join N.Nomenclatures n
						on nv.ValueCode = n.Code
						where nv.EntityId=i.Id
							and nv.EntityType=''inventory''
							and n.Deleted = 0
							and nv.Deleted = 0
							and nv.NomenclatureCode=''FILE_TYPE''
							and nv.EntityType=''inventory''
							and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE'')
						FOR XML path(''''), elements), 1, 1, '''') as FileFormat
				,(select sum(d.Duration) from Documents d where i.SystemIdentifier = d.InventorySystemIdentifier) as Duration
				,ISNULL(i.Bytes, 0) as Bytes
		     FROM v_Inventories as i
			 INNER JOIN v_InventorySizeInfo isi ON isi.InventorySystemIdentifier = i.SystemIdentifier
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
		 GROUP BY a.[Name], fdl.[Text], f.Number, f.[Title], i.Number, idl.[Text], s.[Text], i.SystemIdentifier, i.Bytes, i.Id, isi.EnrolledDocumentCount, isi.EnrolledArchivalEntityCount
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
				(select n.Text + '';''
						from  NomenclatureValues nv
						join N.Nomenclatures n
						on nv.ValueCode=n.Code
						where nv.EntityType=''fund'' 
							and nv.NomenclatureCode=''FILE_TYPE'' 
							and nv.EntityId=f.Id
							and nv.EntityType=''fund''
							and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE''
							and n.Deleted=0 and nv.Deleted=0)
						FOR XML path(''''), elements) as FileFormats,
				(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
				f.Notes as Note,
				f.NumberNumeric as IntNumber,
				a.SortOrder,
				convert(varchar(50), f.SystemIdentifier, 104) as SystemIdentifier,
				convert(bit, 0) as HasExternalSource,
				NULL as ExternalIdentifier
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			INNER JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
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
			INNER JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
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


if not exists (select null from sys.columns where name = 'IsInvaluable' and object_id = object_id ('dbo.PackageDocument'))
begin 
	alter table dbo.PackageDocument add IsInvaluable bit
	exec('update dbo.PackageDocument set IsInvaluable = 0')
end
go

if object_id('dbo.DF_PackageDocument_IsInvaluable') is null
begin
	ALTER TABLE PackageDocument WITH NOCHECK
	ADD CONSTRAINT DF_PackageDocument_IsInvaluable DEFAULT 0 FOR IsInvaluable
end
go

if exists (select null from sys.columns where name = 'IsInvaluable' and object_id = object_id ('dbo.PackageDocument'))
begin 
	alter table dbo.PackageDocument alter column IsInvaluable bit not null
end
go

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
				a.SortOrder
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
				f.Bytes as DigitalSize,
				cast((select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as bigint) as Duration,
				f.InventoryCount,
				f.ArchivalEntityCount as AECount,
				f.DocumentsProvider as ImmediateSourceOfAcquisition,
				a.Name as Archive,
				f.Number,
				(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
				(select n.Text + '';''
                        from  NomenclatureValues nv
                        join N.Nomenclatures n
                        on nv.ValueCode = n.Code
                        where nv.EntityType=''fund''
                            and n.Deleted = 0
                            and nv.Deleted = 0
                            and nv.NomenclatureCode=''FILE_TYPE''
                            and nv.EntityId=f.Id
                            and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''INDUSTRY_TYPE'')
                        FOR XML path(''''), elements) as IndustryIndex,
				(select n.Text + '';''
                        from  NomenclatureValues nv
                        join N.Nomenclatures n
                        on nv.ValueCode = n.Code
                        where nv.EntityType=''fund''
                            and n.Deleted = 0
                            and nv.Deleted = 0
                            and nv.NomenclatureCode=''ACQUISITION_METHOD''
                            and nv.EntityId=f.Id
                            and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''ACQUISITION_METHOD'')
                        FOR XML path(''''), elements) as MethodOfAcquisition,
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
			INNER JOIN N.Status s ON s.Code = f.StatusCode
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 1 -- fund 
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
			AND DescriptionLevelCode = 1 -- fund
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
				sum(isnull(InventoryCount, 0)) TotalInventories,
				sum(isnull(ArchivalEntityCount, 0)) TotalArchiveEntities,
				null TotalLinearMeters,
				(select sum(sizes.Size) 
				from 
					(select f.Bytes as Size
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) sizes) TotalSize, -- въпреки че колоната се казва Bytes, тя съдържа MB, затова няма превръщане на мерните ед.'
				+ @totalDuration + ' TotalDuration
			FROM Funds f
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfRoughDocumentsReport]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 5000,
	@Page int = 1,
	@Archives nvarchar(max) = null,
	@FundTypes nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null,
	@MethodsOfAcquisition nvarchar(max) = null,
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
			CAST(0 as bigint) as Bytes
			FROM Inventory as inv
			inner join Fund_Modified as fund on inv.FundLGid = fund.LGid
			join Nomenclature as n on inv.LevelOfDescriptionGid = n.Gid
			WHERE
			fund._retired = ''3000-01-01''
			AND inv._retired = ''3000-01-01''
			AND n.Code = 6
			AND inv.StatusGid <> 13
			AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (inv.TextDate = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypes + ''', '',''))) 
				OR ((select n.Code from Nomenclature as n where fund.TypeGid = n.Gid) in (select element from dbo.SplitString(''' + @FundTypes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) 
				OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisition + ''', '',''))) 
				OR EXISTS(SELECT 1 FROM Nomenclature as n join ObjectNomenclature as onc on n.Gid = onc.NomenclatureGid where onc._retired = ''3000-01-01'' and onc.FundGid = fund.Gid and n.Code in (select element from dbo.SplitString(''' + @MethodsOfAcquisition + ''', '',''))))
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
				,i.AcquisitionMethodText as AcquisitionMethod
				,s.[Text] as [Status]
				,ROUND(ISNULL(CAST(i.LinearMeters as decimal(18,2)), 0), 2) as LinearMeters
				,ISNULL(CAST(i.Bytes as bigint), 0) as Bytes
		     FROM v_Inventories as i
		     JOIN [Archives] as a
		       ON i.ArchiveId = a.Id
		     JOIN v_Funds as f
		       ON i.FundSystemIdentifier = f.SystemIdentifier
		     JOIN N.InventoryDescriptionLevel as idl
		       ON i.DescriptionLevelCode = idl.Code
		     JOIN N.[Status] as s
		       ON i.StatusCode = s.Code
  FULL OUTER JOIN v_ArchivalEntities as ae
			   ON i.SystemIdentifier = ae.InventorySystemIdentifier
			WHERE idl.Code = 6 AND i.Deleted = 0 AND i.StatusCode <> 13
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @Archives + ''', '',''))))
				
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0
						and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisition  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisition + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisition + ''', '',''))
					) 
				)

				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '',''))) 
					OR (convert(varchar(4), i.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))

				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypes + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = f.TypeCode) in (select element from dbo.SplitString(''' + @FundTypes + ''', '',''))))
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
		 GROUP BY a.[Name], f.Number, f.[Title], i.Number, i.CreatedOn, i.AcquisitionMethodText, idl.[Text], s.[Text], i.SystemIdentifier, i.LinearMeters, i.Bytes
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfRoughDocumentsReportCombined]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 5000,
	@Page int = 1,
	@Archives nvarchar(max) = null,
	@FundTypes nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null,
	@MethodsOfAcquisition nvarchar(max) = null,
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
				Bytes bigint NULL
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
				Bytes
			)
	EXEC [sp_GetListOfRoughDocumentsReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page,
		@Archives,
		@FundTypes,
		@IndustryIndexGids,
		@IndustryIndexesInternal,
		@MethodsOfAcquisition,
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfRoughDocumentsReportSummary]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 5000,
	@Page int = 1,
	@Archives nvarchar(max) = null,
	@FundTypes nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null,
	@MethodsOfAcquisition nvarchar(max) = null,
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
				Mb decimal NULL
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
				Mb
			)
	EXEC [sp_GetListOfRoughDocumentsReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page,
		@Archives,
		@FundTypes,
		@IndustryIndexGids,
		@IndustryIndexesInternal,
		@MethodsOfAcquisition,
		@Statuses,
		@RegisteredFrom,
		@RegisteredTo,
		@ChronologicalScope,
		@ChronologicalScopeStartDate,
		@ChronologicalScopeEndDate

	SET @sql = '
		SELECT TOP 1 COUNT_BIG(*) as TotalRows
		FROM #temp as t'

	--print @sql;
	EXEC (@sql);
END
GO

-- Add roles
INSERT AspNetRoles (Id, ArchiveId, Name, NormalizedName, Abbreviation)  
SELECT NEWID(), a.Id, 'Служител от група Б1 (B1)', UPPER('Служител от група Б1 (B1)'), 'B1'
  FROM Archives a
 WHERE NOT EXISTS ( SELECT r.ArchiveId, r.Abbreviation FROM AspNetRoles r WHERE a.Id = r.ArchiveId AND r.Abbreviation = 'B1')
GO
-- End Add roles


-- 3442 
	-- INTERNAL
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
				COALESCE(
					fund.ImmediateSourceOfAcquisition + '' / '' + ' + @methodOfAcquisitionQueryRemote +  ', 
					fund.ImmediateSourceOfAcquisition + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryRemote + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
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
				a.SortOrder
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
					fund.DocumentsProvider + '' / '' + ' + @methodOfAcquisitionQueryLocal +  ', 
					fund.DocumentsProvider + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryLocal + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''CREATION_METHOD'' 
						and nv.EntityId=fund.Id
					FOR XML path(''''), elements) as CreatingType,
				NULL as LinearMeters ,
				fund.Bytes as DigitalSize,
				fund.Notes as Note,
				fund.NumberNumeric as IntNumber,
				a.SortOrder
			FROM Funds fund 
			INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
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
		DECLARE @remoteQueryWhereClause VARCHAR(MAX) = '((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')) AND fund.FundArrayGid not in (2021, 2022)) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
                    OR ((SELECT Code FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.StatusGid) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE( + @TextDate, 'null') + '''))
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
				sum(isnull(InventoryCount, 0)) TotalInventories,
				sum(isnull(ArchivalEntityCount, 0)) TotalArchiveEntities,
				null TotalLinearMeters,
				(select sum(sizes.Size) 
				from 
					(select f.Bytes as Size
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) sizes) TotalSize, -- въпреки че колоната се казва Bytes, тя съдържа MB, затова няма превръщане на мерните ед.'
				+ @totalDuration + ' TotalDuration
			FROM Funds f
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
				sum(isnull(InventoryCount, 0)) TotalInventories,
				sum(isnull(ArchivalEntityCount, 0)) TotalArchiveEntities,
				sum(f.Bytes) TotalSize,' + 
				@totalDuration + 'TotalDuration,
				null as TotalLinearMeters
			FROM Funds f
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfRoughDocumentsReport]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 5000,
	@Page int = 1,
	@Archives nvarchar(max) = null,
	@FundTypes nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null,
	@MethodsOfAcquisition nvarchar(max) = null,
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
			CAST(0 as bigint) as Bytes
			FROM Inventory as inv
			inner join Fund_Modified as fund on inv.FundLGid = fund.LGid
			join Nomenclature as n on inv.LevelOfDescriptionGid = n.Gid
			WHERE
			fund._retired = ''3000-01-01''
			AND inv._retired = ''3000-01-01''
			AND n.Code = 6
			AND inv.StatusGid <> 13
			AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (inv.TextDate = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypes + ''', '',''))) 
				OR ((select n.Code from Nomenclature as n where fund.TypeGid = n.Gid) in (select element from dbo.SplitString(''' + @FundTypes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) 
				OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisition + ''', '',''))) 
				OR EXISTS(SELECT 1 FROM Nomenclature as n join ObjectNomenclature as onc on n.Gid = onc.NomenclatureGid where onc._retired = ''3000-01-01'' and onc.FundGid = fund.Gid and n.Code in (select element from dbo.SplitString(''' + @MethodsOfAcquisition + ''', '',''))))
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
				,i.AcquisitionMethodText as AcquisitionMethod
				,s.[Text] as [Status]
				,null as LinearMeters
				,ISNULL(CAST(i.Bytes as bigint), 0) as Bytes
		     FROM v_Inventories as i
		     JOIN [Archives] as a
		       ON i.ArchiveId = a.Id
		     JOIN v_Funds as f
		       ON i.FundSystemIdentifier = f.SystemIdentifier
		     JOIN N.InventoryDescriptionLevel as idl
		       ON i.DescriptionLevelCode = idl.Code
		     JOIN N.[Status] as s
		       ON i.StatusCode = s.Code
  FULL OUTER JOIN v_ArchivalEntities as ae
			   ON i.SystemIdentifier = ae.InventorySystemIdentifier
			WHERE idl.Code = 6 AND i.Deleted = 0 AND i.StatusCode <> 13
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @Archives + ''', '',''))))
				
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0
						and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisition  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisition + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisition + ''', '',''))
					) 
				)

				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '',''))) 
					OR (convert(varchar(4), i.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))

				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypes + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = f.TypeCode) in (select element from dbo.SplitString(''' + @FundTypes + ''', '',''))))
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
		 GROUP BY a.[Name], f.Number, f.[Title], i.Number, i.CreatedOn, i.AcquisitionMethodText, idl.[Text], s.[Text], i.SystemIdentifier, i.LinearMeters, i.Bytes
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
				null as LinearMeters,
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

	-- PUBLIC

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
				(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
						and nv.EntityId=f.Id
					FOR XML path(''''), elements) as MethodOfAcquisition,
				f.ApproxmateChronologicalScope as TextDate,
				(isnull(convert(varchar, f.StartDateDay) + ''.'', '''') + isnull(convert(varchar, f.StartDateMonth) + ''.'', '''') + isnull(convert(varchar, f.StartDateYear), '''')) as StartDate,
				(isnull(convert(varchar, f.EndDateDay) + ''.'', '''') + isnull(convert(varchar, f.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, f.EndDateYear), '''')) as EndDate,
				null as LinearMeters,
				isnull(f.Bytes, 0) as Bytes,
				f.NumberNumeric as IntNumber,
				a.SortOrder
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			INNER JOIN N.Status s ON s.Code = f.StatusCode AND s.Code <> 12
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 3 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
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

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN 
		declare @remoteQuery varchar(max) =  '
			SELECT
				fund.LGid as SystemId,
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
			f.Id as SystemId,
			(SELECT DisplayName FROM [AspNetUsers] u where u.Id = f.CreatedBy) as CreationAuthor,
			convert(nvarchar, f.UpdatedOn, 104) as ModificationDate,
			(SELECT top 1 DisplayName FROM [AspNetUsers] u where u.Id = f.UpdatedBy) as ModificationAuthor, -- тук слагам top 1, за да не дава грешка, че подзаявката има повече от 1 резултат - не видях причината за тази грешка				
			null as LinearMeters,
			CAST(f.InventoryCount AS BIGINT) as InventoryCount ,
			NULL as BoxesCount,
			NULL as StorageTubesCount,
			CAST(f.ArchivalEntityCount AS BIGINT) as AECount,
			f.OtherMetrics as ExtentOther,
			fsi.EnrolledDocumentCount as EDocumentsCount,
			fsi.EnrolledBytes as Size,
			(select n.Text + '';''
				from  NomenclatureValues nv
				join N.Nomenclatures n
				on nv.ValueCode = n.Code
				where nv.EntityType=''fund''
					and n.Deleted = 0
					and nv.Deleted = 0
					and nv.NomenclatureCode=''FILE_TYPE''
					and nv.EntityId=f.Id
					and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE'')
				FOR XML path(''''), elements) as FileFormats,
			(select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration,
			f.FundCreatorTitleHistory as FundFormerNameChange,
			f.FundCreatorActivityHistory as FundFormerFunction,
			f.FundCreatorBiographicalHistory as FundFormerHistory,
			f.History as ArchivalHistory,
			f.DocumentsProvider as ImmediateSourceOfAcquisition,
			f.DocumentsDescription as DocumentProperties,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''ORIGINALITY'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as Originality,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''CREATION_METHOD'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as CreatingType,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''LANGUAGE'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as Language,
			f.DocumentsAccessDescription as AccessConditions,
			NULL as FindingAids,
			f.RelatedFunds as RelatedUnits,
			a.Name as Archive,
			f.Number,
			(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''INDUSTRY_TYPE'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as IndustryIndex,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as MethodOfAcquisition,
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
		INNER JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
				) 
			)
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
			SystemId int NOT NULL,
			CreationAuthor nvarchar(256) NULL,
			ModificationDate varchar(50) NULL,
			ModificationAuthor nvarchar(256) NULL,
			LinearMeters float NULL,
			InventoryCount bigint NULL, 
			BoxesCount int NULL,
			StorageTubesCount int NULL,	
			AECount bigint NULL,
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
		@localQuery + '
		order by SortOrder, IntNumber, Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';
     END
  IF @ResultType = 3
   BEGIN
    SET @sql = @localQuery + 'order by SortOrder, IntNumber, Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';
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
			COUNT(*) TotalFunds,
			sum(isnull(fund.InvetoryCount, 0)) TotalInventories,
			sum(isnull(fund.AECount, 0)) TotalArchiveEntities,
			sum(fund.LinearMeters) TotalLinearMeters,
			null TotalSize, -- по искане на клиента не се отчита
			null as TotalDuration,
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
			COUNT_BIG(*) TotalFunds,
			sum(isnull(InventoryCount, 0)) TotalInventories,
			sum(isnull(ArchivalEntityCount, 0)) TotalArchiveEntities,
			null TotalLinearMeters,
			cast(sum(isnull(fsi.EnrolledBytes, 0)) as bigint) TotalSize,'
			+ @totalDuration + ' Duration,
			sum(isnull(fsi.EnrolledDocumentCount, 0)) EDocumentsCount
		FROM Funds f
		INNER JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
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
			Funds bigint NULL,
			Inventories bigint NULL,
			ArchiveEntities bigint NULL,
			LinearMeters float NULL,
			Size bigint NULL,
			Duration bigint NULL,
			EDocumentsCount int NULL
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
		SELECT 
			sum(u.TotalFunds) as TotalFunds, 
			sum(u.TotalInventories) as TotalInventories, 
			sum(u.TotalArchiveEntities) as TotalArchiveEntities, 
			sum(round(isnull(cast(u.TotalLinearMeters as decimal(18,2)), 0),2)) as TotalLinearMeters,
			cast(sum(isnull(u.TotalSize, 0)) as bigint) as Size,
			sum(u.TotalDuration) as TotalDuration,
			sum(t.EDocumentsCount) as EDocumentsCount
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
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as MethodOfAcquisition,
			f.ApproxmateChronologicalScope as TextDate,
			(isnull(convert(varchar, f.StartDateDay) + ''.'', '''') + isnull(convert(varchar, f.StartDateMonth) + ''.'', '''') + isnull(convert(varchar, f.StartDateYear), '''')) as StartDate,
			(isnull(convert(varchar, f.EndDateDay) + ''.'', '''') + isnull(convert(varchar, f.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, f.EndDateYear), '''')) as EndDate,
			cast(f.InventoryCount as bigint) as InventoryCount , 
			cast(f.ArchivalEntityCount as bigint) as AECount,
			null as LinearMeters,
			f.NumberNumeric as IntNumber,
			a.SortOrder
		FROM Funds f
		INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
		INNER JOIN N.Status s ON s.Code = f.StatusCode AND s.Code <> 12
		WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
			AND f.DescriptionLevelCode = 4 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
				) 
			)
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

-- END 3442

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
				sum(isnull(InventoryCount, 0)) Inventories,
				sum(isnull(ArchivalEntityCount, 0)) ArchiveEntities,
				null LinearMeters,
				cast(sum(isnull(fsi.EnrolledBytes, 0)) as bigint) Size,'
				+ @totalDuration + ' Duration,
				sum(isnull(fsi.EnrolledDocumentCount, 0)) EDocumentsCount
			FROM Funds f
			INNER JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
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
				fund.LGid as SystemId,
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
			f.Id as SystemId,
			(SELECT DisplayName FROM [AspNetUsers] u where u.Id = f.CreatedBy) as CreationAuthor,
			convert(nvarchar, f.UpdatedOn, 104) as ModificationDate,
			(SELECT top 1 DisplayName FROM [AspNetUsers] u where u.Id = f.UpdatedBy) as ModificationAuthor, -- тук слагам top 1, за да не дава грешка, че подзаявката има повече от 1 резултат - не видях причината за тази грешка				
			null as LinearMeters,
			f.InventoryCount as InventoryCount ,
			NULL as BoxesCount,
			NULL as StorageTubesCount,
			f.ArchivalEntityCount as AECount,
			f.OtherMetrics as ExtentOther,
			fsi.EnrolledDocumentCount as EDocumentsCount,
			fsi.EnrolledBytes as Size,
			(select n.Text + '';''
				from  NomenclatureValues nv
				join N.Nomenclatures n
				on nv.ValueCode = n.Code
				where nv.EntityType=''fund''
					and n.Deleted = 0
					and nv.Deleted = 0
					and nv.NomenclatureCode=''FILE_TYPE''
					and nv.EntityId=f.Id
					and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE'')
				FOR XML path(''''), elements) as FileFormats,
			(select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration,
			f.FundCreatorTitleHistory as FundFormerNameChange,
			f.FundCreatorActivityHistory as FundFormerFunction,
			f.FundCreatorBiographicalHistory as FundFormerHistory,
			f.History as ArchivalHistory,
			f.DocumentsProvider as ImmediateSourceOfAcquisition,
			f.DocumentsDescription as DocumentProperties,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''ORIGINALITY'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as Originality,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''CREATION_METHOD'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as CreatingType,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''LANGUAGE'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as Language,
			f.DocumentsAccessDescription as AccessConditions,
			NULL as FindingAids,
			f.RelatedFunds as RelatedUnits,
			a.Name as Archive,
			f.Number,
			(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''INDUSTRY_TYPE'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as IndustryIndex,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as MethodOfAcquisition,
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
		INNER JOIN N.Status s ON s.Code = f.StatusCode
		INNER JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
				) 
			)
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
			SystemId int NOT NULL,
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
				fund.LGid as SystemId,
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
			f.Id as SystemId,
			(SELECT DisplayName FROM [AspNetUsers] u where u.Id = f.CreatedBy) as CreationAuthor,
			convert(nvarchar, f.UpdatedOn, 104) as ModificationDate,
			(SELECT top 1 DisplayName FROM [AspNetUsers] u where u.Id = f.UpdatedBy) as ModificationAuthor, -- тук слагам top 1, за да не дава грешка, че подзаявката има повече от 1 резултат - не видях причината за тази грешка				
			null as LinearMeters,
			f.InventoryCount as InventoryCount ,
			NULL as BoxesCount,
			NULL as StorageTubesCount,
			f.ArchivalEntityCount as AECount,
			f.OtherMetrics as ExtentOther,
			fsi.EnrolledDocumentCount as EDocumentsCount,
			fsi.EnrolledBytes as Size,
			(select n.Text + '';''
				from  NomenclatureValues nv
				join N.Nomenclatures n
				on nv.ValueCode = n.Code
				where nv.EntityType=''fund''
					and n.Deleted = 0
					and nv.Deleted = 0
					and nv.NomenclatureCode=''FILE_TYPE''
					and nv.EntityId=f.Id
					and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE'')
				FOR XML path(''''), elements) as FileFormats,
			(select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration,
			f.FundCreatorTitleHistory as FundFormerNameChange,
			f.FundCreatorActivityHistory as FundFormerFunction,
			f.FundCreatorBiographicalHistory as FundFormerHistory,
			f.History as ArchivalHistory,
			f.DocumentsProvider as ImmediateSourceOfAcquisition,
			f.DocumentsDescription as DocumentProperties,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''ORIGINALITY'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as Originality,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''CREATION_METHOD'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as CreatingType,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''LANGUAGE'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as Language,
			f.DocumentsAccessDescription as AccessConditions,
			NULL as FindingAids,
			f.RelatedFunds as RelatedUnits,
			a.Name as Archive,
			f.Number,
			(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''INDUSTRY_TYPE'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as IndustryIndex,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as MethodOfAcquisition,
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
		INNER JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
				) 
			)
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
			SystemId int NOT NULL,
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
			INNER JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
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

update ProcessRelatedSteps set NextStepId = 1013 where ProcessTypeId = 15 and StepId = 1012
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetUsers] 
	@LinkedServer nvarchar(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql NVARCHAR(MAX);

	declare @remoteQuery nvarchar(max) =
		'SELECT 
			Gid,
			[Name]
		FROM [Archiving].[dbo].[User]
		WHERE _retired = ''3000-01-01 00:00:00.000''
			  AND [Name] IS NOT NULL 
			  AND [Name] <> ''''';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');';

	exec (@sql);
END
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
			AND DescriptionLevelCode = 1 -- fund
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
				sum(isnull(InventoryCount, 0)) TotalInventories,
				sum(isnull(ArchivalEntityCount, 0)) TotalArchiveEntities,
				null TotalLinearMeters,
				(select sum(sizes.Size) 
				from 
					(select f.Bytes as Size
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) sizes) TotalSize,'
				+ @totalDuration + ' TotalDuration
			FROM Funds f
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
				sum(isnull(InventoryCount, 0)) TotalInventories,
				sum(isnull(ArchivalEntityCount, 0)) TotalArchiveEntities,
				round(sum(LinearMeters), 2) TotalLinearMeters,
				(select sum(sizes.Size) 
				from 
					(select f.Bytes as Size
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) sizes) TotalSize, -- въпреки че колоната се казва Bytes, тя съдържа MB, затова няма превръщане на мерните ед.'
				+ @totalDuration + ' TotalDuration
			FROM Funds f
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
				a.SortOrder
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
					(select n.Text + '';''
						from  NomenclatureValues nv
						join N.Nomenclatures n
						on nv.ValueCode=n.Code
						where nv.EntityType=''fund'' 
							and nv.NomenclatureCode=''ACQUISITION_METHOD'' 
							and nv.EntityId=f.Id
							and nv.EntityType=''fund''
							and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''ACQUISITION_METHOD'')
							and n.Deleted=0 and nv.Deleted=0
						FOR XML path(''''), elements) as MethodOfAcquisition,
				f.ApproxmateChronologicalScope as TextDate,
				convert(varchar, f.CreatedOn, 104) as CreationDate,
				(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus,
				(SELECT Text FROM [N].[FundDescriptionLevel] dl where dl.Code = f.DescriptionLevelCode) as LevelOfDescription,
				f.InventoryCount,
				f.ArchivalEntityCount as AECount,
				DocumentCount,
				(select n.Text + '';''
					from  NomenclatureValues nv
					join N.Nomenclatures n
					on nv.ValueCode=n.Code
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode=''FILE_TYPE'' 
						and nv.EntityId=f.Id
						and nv.EntityType=''fund''
						and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE''
						and n.Deleted=0 and nv.Deleted=0)
					FOR XML path(''''), elements) as FileFormats,
				fsi.EnrolledBytes as Size,
				dbo.FormatDuration((select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier)) as Duration,
				null as LinearMeters,
				f.Notes as Note,
				f.NumberNumeric as IntNumber,
				a.SortOrder
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode IN(1, 2, 3) 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0 -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
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
				fund.LGid as SystemId,
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
			f.Id as SystemId,
			(SELECT DisplayName FROM [AspNetUsers] u where u.Id = f.CreatedBy) as CreationAuthor,
			convert(nvarchar, f.UpdatedOn, 104) as ModificationDate,
			(SELECT top 1 DisplayName FROM [AspNetUsers] u where u.Id = f.UpdatedBy) as ModificationAuthor, -- тук слагам top 1, за да не дава грешка, че подзаявката има повече от 1 резултат - не видях причината за тази грешка				
			null as LinearMeters,
			f.InventoryCount as InventoryCount ,
			NULL as BoxesCount,
			NULL as StorageTubesCount,
			f.ArchivalEntityCount as AECount,
			f.OtherMetrics as ExtentOther,
			fsi.EnrolledDocumentCount as EDocumentsCount,
			fsi.EnrolledBytes as Size,
			(select n.Text + '';''
				from  NomenclatureValues nv
				join N.Nomenclatures n
				on nv.ValueCode = n.Code
				where nv.EntityType=''fund''
					and n.Deleted = 0
					and nv.Deleted = 0
					and nv.NomenclatureCode=''FILE_TYPE''
					and nv.EntityId=f.Id
					and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE'')
				FOR XML path(''''), elements) as FileFormats,
			(select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration,
			f.FundCreatorTitleHistory as FundFormerNameChange,
			f.FundCreatorActivityHistory as FundFormerFunction,
			f.FundCreatorBiographicalHistory as FundFormerHistory,
			f.History as ArchivalHistory,
			f.DocumentsProvider as ImmediateSourceOfAcquisition,
			f.DocumentsDescription as DocumentProperties,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''ORIGINALITY'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as Originality,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''CREATION_METHOD'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as CreatingType,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''LANGUAGE'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as Language,
			f.DocumentsAccessDescription as AccessConditions,
			NULL as FindingAids,
			f.RelatedFunds as RelatedUnits,
			a.Name as Archive,
			f.Number,
			(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''INDUSTRY_TYPE'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as IndustryIndex,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as MethodOfAcquisition,
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
		LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
				) 
			)
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
			SystemId int NOT NULL,
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
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
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
				(select n.Text + '';''
						from  NomenclatureValues nv
						join N.Nomenclatures n
						on nv.ValueCode=n.Code
						where nv.EntityType=''fund'' 
							and nv.NomenclatureCode=''FILE_TYPE'' 
							and nv.EntityId=f.Id
							and nv.EntityType=''fund''
							and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE''
							and n.Deleted=0 and nv.Deleted=0)
						FOR XML path(''''), elements) as FileFormats,
				(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
				f.Notes as Note,
				f.NumberNumeric as IntNumber,
				a.SortOrder,
				convert(varchar(50), f.SystemIdentifier, 104) as SystemIdentifier,
				convert(bit, 0) as HasExternalSource,
				NULL as ExternalIdentifier
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
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

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetFundMemoriesListInternalReportSummary] 
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
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQueryWhereClause VARCHAR(MAX) = '
			fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 3)
			AND  (''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
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
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
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
					null as FileFormats
				FROM Fund_Modified as fund
				INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
				WHERE fund._retired = ''3000-01-01''
					AND fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 2)
					AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives + ''', '',''))) OR a.Code in  (select element from dbo.SplitString(''' + @Archives + ''', '','')))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) OR (select Code from Nomenclature where _retired=''3000-01-01'' and Gid = fund.StatusGid) in (select element from dbo.SplitString(''' + @Statuses + ''', '','')))
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
				,CONCAT(DocumentsProvider, '' / '',(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund''
						and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
						and nv.EntityId=f.Id
					FOR XML path(''''), elements)) as ImmediateSourceOfAcquisition
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
				,f.InventoryCount as InventoryCount
				,f.ArchivalEntityCount as AeCount
				,null as LinearMeters
				,f.EnrolledBytes as Size
				,dbo.FormatDuration((select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier)) as Duration
				,(select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as DurationInt
				,fsi.EnrolledDocumentCount as EDocumentsCount
				,(select n.Text + '';''
					from  NomenclatureValues nv
					join N.Nomenclatures n
					on nv.ValueCode=n.Code
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode=''FILE_TYPE'' 
						and nv.EntityId=f.Id
						and nv.EntityType=''fund''
						and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE''
						and n.Deleted=0 and nv.Deleted=0)
					FOR XML path(''''), elements) as FileFormats
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 4
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives  + ''', '',''))) 
					OR a.Code in (select element from dbo.SplitString(''' + @Archives + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '','')) AND f.StatusCode not in (''3'', ''4'',''5'', ''8'', ''9'', ''10'', ''13'')) 
					OR (convert(varchar(4), f.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0 -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
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
				FileFormats nvarchar(MAX) NULL
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
				fund.LGid as SystemId,
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
			f.Id as SystemId,
			(SELECT DisplayName FROM [AspNetUsers] u where u.Id = f.CreatedBy) as CreationAuthor,
			convert(nvarchar, f.UpdatedOn, 104) as ModificationDate,
			(SELECT top 1 DisplayName FROM [AspNetUsers] u where u.Id = f.UpdatedBy) as ModificationAuthor, -- тук слагам top 1, за да не дава грешка, че подзаявката има повече от 1 резултат - не видях причината за тази грешка				
			null as LinearMeters,
			f.InventoryCount as InventoryCount ,
			NULL as BoxesCount,
			NULL as StorageTubesCount,
			f.ArchivalEntityCount as AECount,
			f.OtherMetrics as ExtentOther,
			fsi.EnrolledDocumentCount as EDocumentsCount,
			fsi.EnrolledBytes as Size,
			(select n.Text + '';''
				from  NomenclatureValues nv
				join N.Nomenclatures n
				on nv.ValueCode = n.Code
				where nv.EntityType=''fund''
					and n.Deleted = 0
					and nv.Deleted = 0
					and nv.NomenclatureCode=''FILE_TYPE''
					and nv.EntityId=f.Id
					and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE'')
				FOR XML path(''''), elements) as FileFormats,
			(select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration,
			f.FundCreatorTitleHistory as FundFormerNameChange,
			f.FundCreatorActivityHistory as FundFormerFunction,
			f.FundCreatorBiographicalHistory as FundFormerHistory,
			f.History as ArchivalHistory,
			f.DocumentsProvider as ImmediateSourceOfAcquisition,
			f.DocumentsDescription as DocumentProperties,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''ORIGINALITY'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as Originality,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''CREATION_METHOD'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as CreatingType,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''LANGUAGE'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as Language,
			f.DocumentsAccessDescription as AccessConditions,
			NULL as FindingAids,
			f.RelatedFunds as RelatedUnits,
			a.Name as Archive,
			f.Number,
			(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''INDUSTRY_TYPE'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as IndustryIndex,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as MethodOfAcquisition,
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
		INNER JOIN N.Status s ON s.Code = f.StatusCode
		LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
				) 
			)
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
			SystemId int NOT NULL,
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
				sum(isnull(InventoryCount, 0)) Inventories,
				sum(isnull(ArchivalEntityCount, 0)) ArchiveEntities,
				null LinearMeters,
				cast(sum(isnull(fsi.EnrolledBytes, 0)) as bigint) Size,'
				+ @totalDuration + ' Duration,
				sum(isnull(fsi.EnrolledDocumentCount, 0)) EDocumentsCount
			FROM Funds f
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier
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
				null as Bytes
				FROM Inventory as inv
				inner join Fund_Modified as fund on inv.FundLGid = fund.LGid
				inner join Archive a on inv.ArchiveGid = a.Gid
			WHERE
				fund._retired = ''3000-01-01''
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
				AND inv.LevelOfDescriptionGid in(
				2171, -- Inventory
				2172  -- InventoryRough
			)
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
				,(SELECT COUNT(*) FROM v_ArchivalEntities as ae where InventorySystemIdentifier = i.SystemIdentifier and ISNUMERIC(RIGHT(ae.Number,1)) = 0) as AeWithCharCount
				,isi.EnrolledDocumentCount as EDocumentsCount
				,null as LinearMeters
				,STUFF((select n.Text + ''; ''
						from  NomenclatureValues nv
						join N.Nomenclatures n
						on nv.ValueCode = n.Code
						where nv.EntityId=i.Id
							and nv.EntityType=''inventory''
							and n.Deleted = 0
							and nv.Deleted = 0
							and nv.NomenclatureCode=''FILE_TYPE''
							and nv.EntityType=''inventory''
							and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE'')
						FOR XML path(''''), elements), 1, 1, '''') as FileFormat
				,(select sum(d.Duration) from Documents d where i.SystemIdentifier = d.InventorySystemIdentifier) as Duration
				,ISNULL(i.Bytes, 0) as Bytes
		     FROM v_Inventories as i
			 LEFT JOIN v_InventorySizeInfo isi ON isi.InventorySystemIdentifier = i.SystemIdentifier
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
		 GROUP BY a.[Name], fdl.[Text], f.Number, f.[Title], i.Number, idl.[Text], s.[Text], i.SystemIdentifier, i.Bytes, i.Id, isi.EnrolledDocumentCount, isi.EnrolledArchivalEntityCount
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfRoughDocumentsReport]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 5000,
	@Page int = 1,
	@Archives nvarchar(max) = null,
	@FundTypes nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null,
	@MethodsOfAcquisition nvarchar(max) = null,
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
			CAST(0 as bigint) as Bytes
			FROM Inventory as inv
			inner join Fund_Modified as fund on inv.FundLGid = fund.LGid
			join Nomenclature as n on inv.LevelOfDescriptionGid = n.Gid
			WHERE
			fund._retired = ''3000-01-01''
			AND inv._retired = ''3000-01-01''
			AND n.Code = 6
			AND inv.StatusGid <> 13
			AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (inv.TextDate = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypes + ''', '',''))) 
				OR ((select n.Code from Nomenclature as n where fund.TypeGid = n.Gid) in (select element from dbo.SplitString(''' + @FundTypes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) 
				OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisition + ''', '',''))) 
				OR EXISTS(SELECT 1 FROM Nomenclature as n join ObjectNomenclature as onc on n.Gid = onc.NomenclatureGid where onc._retired = ''3000-01-01'' and onc.FundGid = fund.Gid and n.Code in (select element from dbo.SplitString(''' + @MethodsOfAcquisition + ''', '',''))))
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
				,i.AcquisitionMethodText as AcquisitionMethod
				,s.[Text] as [Status]
				,null as LinearMeters
				,ISNULL(CAST(i.Bytes as bigint), 0) as Bytes
		     FROM v_Inventories as i
		     JOIN [Archives] as a
		       ON i.ArchiveId = a.Id
		     JOIN v_Funds as f
		       ON i.FundSystemIdentifier = f.SystemIdentifier
		     JOIN N.InventoryDescriptionLevel as idl
		       ON i.DescriptionLevelCode = idl.Code
		     JOIN N.[Status] as s
		       ON i.StatusCode = s.Code
  FULL OUTER JOIN v_ArchivalEntities as ae
			   ON i.SystemIdentifier = ae.InventorySystemIdentifier
			WHERE idl.Code = 6 AND i.Deleted = 0 AND i.StatusCode <> 13
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @Archives + ''', '',''))))
				
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0
						and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisition  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisition + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisition + ''', '',''))
					) 
				)

				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '',''))) 
					OR (convert(varchar(4), i.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))

				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypes + ''', '','')) AND TypeCode not in (''4'', ''5'')) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = f.TypeCode) in (select element from dbo.SplitString(''' + @FundTypes + ''', '',''))))
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
		 GROUP BY a.[Name], f.Number, f.[Title], i.Number, i.CreatedOn, i.AcquisitionMethodText, idl.[Text], s.[Text], i.SystemIdentifier, i.LinearMeters, i.Bytes
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

----------------------------------------------------------
--	THE SCRIPT IS CLOSED - USE THE NEW ONE!
----------------------------------------------------------

commit