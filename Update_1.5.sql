SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.5'
where Code = 'DB_VERSION'


-- add scripts here

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
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
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
		order by Archive, IntNumber, Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = 
			'SELECT
				(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = fund.ArchiveGid) as Archive,
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
				fund.IntNumber
			FROM Fund_Modified as fund
			WHERE
				(''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 3)
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR fund.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE( + @TextDate, 'null') + '''))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))';
		
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				(SELECT Name FROM [Archives] a where a.Id = ArchiveId) as Archive,
				Number,
				convert(varchar, CreatedOn, 104) as CreationDate,
				Title,
				DocumentsProvider as ImmediateSourceOfAcquisition,
				DocumentsAccessDescription as AccessConditions,
				(SELECT Text FROM [N].[FundType] ft where ft.Code = TypeCode) as FundType,
				Notes as Note,
				(SELECT Text FROM [N].[Status] s where s.Code = StatusCode) as FundStatus,
				(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
						and nv.EntityId=Id
					FOR XML path(''''), elements) as MethodOfAcquisition,
				ApproxmateChronologicalScope as TextDate,
				(isnull(convert(varchar, StartDateDay) + ''.'', '''') + isnull(convert(varchar, StartDateMonth) + ''.'', '''') + isnull(convert(varchar, StartDateYear), '''')) as StartDate,
				(isnull(convert(varchar, EndDateDay) + ''.'', '''') + isnull(convert(varchar, EndDateMonth) + ''.'', '''') + isnull(convert(varchar, EndDateYear), '''')) as EndDate,
				isnull(LinearMeters, 0),
				NumberNumeric as IntNumber
			FROM Funds f
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode = 3 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))';
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
				IntNumber int null
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

CREATE OR ALTER PROCEDURE [dbo].[GetAccountAndDescriptionOfFilmDocumentsBook] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null
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
						+ (select Number from Inventory_Active i where i.FundLGid = LGid) + '' / ''
						+ (select top(1) Number from ArchiveEntity_Active ae where ae.FundLGid = LGid)),
					(Number + '' / '' 
						+ (select Number from Inventory_Active i where i.FundLGid = LGid) + '' / ''),
					(Number + '' / / '' 
						+ (select top(1) Number from ArchiveEntity_Active ae where ae.FundLGid = LGid))					
					) as FundNumberAndInventoryAndArchiveEntiry, -- отнесен към фонд №, инвентарен опис, архивна единица  -- този ред гърми гърми за някой ред от данните, затова слагам top(1)!
				--наличие на застрахователно копие/вид носител
				Note,
				IntNumber
			FROM Fund_Active as fund
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
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
			WHERE --ExternalIdentifier IS NULL AND HasExternalSource = 0
				Deleted = 0 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))';
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
		order by Archive asc, IntNumber, FundNumber asc
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
			fund.Note as Note,
			fund.IntNumber
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
			funds.Notes as Note,
			NumberNumeric as IntNumber
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
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
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
		order by Archive, IntNumber, Number
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT
				(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = fund.ArchiveGid) as Archive,
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
				cast((select sum(isnull(i.ByteLenght, 0)) 
					from Image i
					inner join Document_Modified d
					on i.DocumentGid = d.Gid
					where d.FundLGid = fund.LGid) * 0.000001 as decimal(10, 2)) as Size,
				NULL as Duration,
				fund.Note,
				fund.IntNumber
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
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR fund.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
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
		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				(SELECT Name FROM [Archives] a where a.Id = ArchiveId) as Archive,	
				Number,
				Title,
				(SELECT Text FROM [N].[FundType] ft where ft.Code = TypeCode) as FundType,
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
				ApproxmateChronologicalScope as TextDate,
				convert(varchar, CreatedOn, 104) as CreationDate,
				(SELECT Text FROM [N].[Status] s where s.Code = StatusCode) as FundStatus,
				(SELECT Text FROM [N].[FundDescriptionLevel] dl where dl.Code = DescriptionLevelCode) as LevelOfDescription,
				InventoryCount,
				ArchivalEntityCount as AECount,
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
				cast((select sum(isnull(d.Bytes, 0) * 0.000001) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as decimal(10, 2)) as Size,
				dbo.FormatDuration((select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier)) as Duration,
				Notes as Note,
				NumberNumeric as IntNumber
			FROM Funds f
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode IN(1, 2, 3) 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
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
						and n.Deleted=0 and nv.Deleted=0) INTERSECT (select element from dbo.SplitString(''' + @FileFormats + ''', '','')))))';
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
				Size decimal NULL,
				Duration nvarchar(14) NULL,
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundDataPublicReport] -- REPORT_8_27_Fund_Report от ИСДА
	@LinkedServer nvarchar(50),
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
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
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
			(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = fund.ArchiveGid) as Archive,
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
			fund.IntNumber
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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR fund.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
			AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE(@TextDate, 'null') + '''))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@LGid, 'null') + ''' = ''null'') OR (fund.LGid in (SELECT Element from dbo.SplitString(''' + COALESCE(@LGid, 'null') + ''', '',''))))';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			Id as SystemId,
			(SELECT DisplayName FROM [AspNetUsers] u where u.Id = CreatedBy) as CreationAuthor,
			convert(nvarchar, UpdatedOn, 104) as ModificationDate,
			(SELECT top 1 DisplayName FROM [AspNetUsers] u where u.Id = UpdatedBy) as ModificationAuthor, -- тук слагам top 1, за да не дава грешка, че подзаявката има повече от 1 резултат - не видях причината за тази грешка				
			isnull(LinearMeters, 0) as LinearMeters,
			InventoryCount,
			NULL as BoxesCount,
			NULL as StorageTubesCount,
			ArchivalEntityCount as AECount,
			OtherMetrics as ExtentOther,
			FundCreatorTitleHistory as FundFormerNameChange,
			FundCreatorActivityHistory as FundFormerFunction,
			FundCreatorBiographicalHistory as FundFormerHistory,
			History as ArchivalHistory,
			DocumentsProvider as ImmediateSourceOfAcquisition,
			DocumentsDescription as DocumentProperties,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''ORIGINALITY'' 
					and nv.EntityId=Id
				FOR XML path(''''), elements) as Originality,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''CREATION_METHOD'' 
					and nv.EntityId=Id
				FOR XML path(''''), elements) as CreatingType,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''LANGUAGE'' 
					and nv.EntityId=Id
				FOR XML path(''''), elements) as Language,
			DocumentsAccessDescription as AccessConditions,
			NULL as FindingAids,
			RelatedFunds as RelatedUnits,
			(SELECT Name FROM [Archives] a where a.Id = ArchiveId) as Archive,
			Number,
			(SELECT Text FROM [N].[FundType] ft where ft.Code = TypeCode) as FundType,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''INDUSTRY_TYPE'' 
					and nv.EntityId=Id
				FOR XML path(''''), elements) as IndustryIndex,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
					and nv.EntityId=Id
				FOR XML path(''''), elements) as MethodOfAcquisition,
			ApproxmateChronologicalScope as TextDate,
			(isnull(convert(varchar, StartDateDay) + ''.'', '''') + isnull(convert(varchar, StartDateMonth) + ''.'', '''') + isnull(convert(varchar, StartDateYear), '''')) as StartDate,
			(isnull(convert(varchar, EndDateDay) + ''.'', '''') + isnull(convert(varchar, EndDateMonth) + ''.'', '''') + isnull(convert(varchar, EndDateYear), '''')) as EndDate,
			convert(varchar, CreatedOn, 104) as CreationDate,
			Title,
			Notes as Note,
			(SELECT Text FROM [N].[Status] s where s.Code = StatusCode) as FundStatus,
			NumberNumeric as IntNumber
		FROM Funds f
		WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
			AND DescriptionLevelCode = 1 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
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
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))';


	DECLARE @sql VARCHAR(MAX) = '
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
			IntNumber int null
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteFundsTable
		UNION
		' +
		@localQuery + '
		order by Archive, IntNumber, Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

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
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
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
		order by Archive, IntNumber, Number
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = 
			'SELECT
				(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = fund.ArchiveGid) as Archive,
				fund.Number,
				fund.Title,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.StatusGid) as FundStatus,
				fund.ImmediateSourceOfAcquisition,
				fund.AccessConditions,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.TypeGid) as FundType,
				fund.Note,
				fund.IntNumber
			FROM Fund_Modified as fund
			WHERE
				fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 3)
				AND  (''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR fund.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE( + @TextDate, 'null') + '''))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))';
		
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				(SELECT Name FROM [Archives] a where a.Id = ArchiveId) as Archive,
				Number,
				Title,
				convert(varchar, CreatedOn, 104) as CreationDate,
				(SELECT Text FROM [N].[Status] s where s.Code = StatusCode) as FundStatus,
				DocumentsProvider as ImmediateSourceOfAcquisition,
				DocumentsAccessDescription as AccessConditions,
				(SELECT Text FROM [N].[FundType] ft where ft.Code = TypeCode) as FundType,
				Notes as Note,
				NumberNumeric as IntNumber
			FROM Funds f
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode = 3 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))';
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
				ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
				AccessConditions nvarchar(MAX) NULL,
				FundType nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundMemoriesListReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveGid nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by Archive, IntNumber, Number
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
				(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = fund.ArchiveGid) as Archive,
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
				isnull(fund.LinearMeters, 0),
				fund.Note,
				fund.IntNumber
			FROM Fund_Modified as fund
			WHERE (''-999'' in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '','')) OR fund.ArchiveGid in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '',''))) 
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3)';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				(SELECT Name FROM [Archives] a where a.Id = ArchiveId) as Archive,
				Number,
				convert(varchar, CreatedOn, 104) as CreationDate,
				COALESCE(
					DocumentsProvider + '' / '' + ' + @methodOfAcquisitionQueryLocal +  ', 
					DocumentsProvider + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryLocal + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				Title,
				(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''CREATION_METHOD'' 
						and nv.EntityId=Id
					FOR XML path(''''), elements) as CreatingType,
				isnull(LinearMeters, 0),
				Notes as Note,
				NumberNumeric as IntNumber
			FROM Funds 
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode = 3 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))';
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
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
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
		order by Archive, IntNumber, Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT
				isnull(fund.LinearMeters, 0) as LinearMeters,
				null as DigitalSize,
				convert(bigint, fund.InvetoryCount) as InventoryCount,
				convert(bigint, fund.AECount) as AECount,
				fund.ImmediateSourceOfAcquisition,
				(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = fund.ArchiveGid) as Archive,
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
				fund.IntNumber
			FROM Fund_Modified as fund
			WHERE
				((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR fund.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE(@TextDate, 'null') + '''))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				isnull(LinearMeters, 0) as LinearMeters,
				isnull(Bytes, 0) as DigitalSize, -- реално е MB, името на колоната трябва да се смени
				InventoryCount,
				ArchivalEntityCount as AECount,
				DocumentsProvider as ImmediateSourceOfAcquisition,
				(SELECT Name FROM [Archives] a where a.Id = ArchiveId) as Archive,
				Number,
				(SELECT Text FROM [N].[FundType] ft where ft.Code = TypeCode) as FundType,
				(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''INDUSTRY_TYPE'' 
						and nv.EntityId=Id
					FOR XML path(''''), elements) as IndustryIndex,
				(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
						and nv.EntityId=Id
					FOR XML path(''''), elements) as MethodOfAcquisition,
				ApproxmateChronologicalScope as TextDate,
				(isnull(convert(varchar, StartDateDay) + ''.'', '''') + isnull(convert(varchar, StartDateMonth) + ''.'', '''') + isnull(convert(varchar, StartDateYear), '''')) as StartDate,
				(isnull(convert(varchar, EndDateDay) + ''.'', '''') + isnull(convert(varchar, EndDateMonth) + ''.'', '''') + isnull(convert(varchar, EndDateYear), '''')) as EndDate,
				convert(varchar, CreatedOn, 104) as CreationDate,
				Title,
				Notes as Note,
				(SELECT Text FROM [N].[Status] s where s.Code = StatusCode) as FundStatus,
				(SELECT Text FROM [N].[FundDescriptionLevel] dl where dl.Code = DescriptionLevelCode) as LevelOfDescription,
				f.NumberNumeric as IntNumber
			FROM Funds f
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode = 1 -- fund 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
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
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				LinearMeters float NULL, 
				DigitalSize bigint NULL,
				InventoryCount bigint NULL,
				AECount bigint NULL,
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundsListReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveGid nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by Archive, IntNumber, Number
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = fund.ArchiveGid) as Archive,
				fund.Number,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				fund.Title,
				fund.Note,
				fund.IntNumber
			FROM Fund_Modified as fund
			WHERE 
				(''-999'' in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '','')) OR fund.ArchiveGid in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)';
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				(SELECT Name FROM [Archives] a where a.Id = ArchiveId) as Archive,
				Number,
				convert(varchar, CreatedOn, 104) as CreationDate,
				Title,
				Notes as Note,
				NumberNumeric as IntNumber
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
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				CreationDate varchar(50) NULL,
				Title nvarchar(MAX) NULL,
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

CREATE OR ALTER PROCEDURE [dbo].[GetInsuranceFundOfCopiesOfForeignArchives] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null
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
				NULL as ElectronicDocumentsMB,
				fund.ExtentOther as Other,
				fund.InsNegativeCount as DoublesNegativeCount,
				(SELECT Value from Nomenclature where _retired =''3000-01-01'' and type = ''FAInsurancePlace'' and Gid = fund.InsNegativePlaceGid) as DoublesNegativeLocation,
				InsPositiveCount as DoublesPositiveCount,
				(SELECT Value from Nomenclature where _retired =''3000-01-01'' and type = ''FAInsurancePlace'' and Gid = fund.InsPositivePlaceGid) as DoublesPositiveLocation,
				fund.InsFotolabDeliveryDate as PhotolabDeliveryDate,
				fund.InsNote,
				fund.IntNumber
			FROM Fund_Modified as fund
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR fund.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
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
				(select SUM(fpd.FileSizeInBytes) * 0.000001 from FilmPackageDocuments as fpd join FilmPackages as fp on fpd.PackageId = fp.Id where fp.Id = PackageBId AND fpd.Deleted = 0 AND fp.Deleted = 0) as ElectronicDocumentsMB,
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
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'; -- Дали трябва да се добави условие за процес?
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
				ElectronicDocumentsMB int NULL,
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

CREATE OR ALTER PROCEDURE [dbo].[GetPartialReceiptsListReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveGid nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by Archive, IntNumber, Number
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = fund.ArchiveGid) as Archive,
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
				fund.Note,
				fund.IntNumber
			FROM Fund_Modified as fund
			WHERE 
				(''-999'' in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '','')) OR fund.ArchiveGid in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '','')))  
					AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END


	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				(SELECT Name FROM [Archives] a where a.Id = ArchiveId) as Archive,
				Number,
				convert(varchar, CreatedOn, 104) as CreationDate,
				CONCAT(DocumentsProvider, '' / '',(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
						and nv.EntityId=Id
					FOR XML path(''''), elements)) as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				Title,
				CONCAT(round(isnull(cast(LinearMeters as decimal(18,2)), 0),2), '' / '', OtherMetrics) as VolumeInSheets,
				Notes as Note,
				NumberNumeric as IntNumber
			FROM Funds 
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode = 4
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))';
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

CREATE OR ALTER PROCEDURE [dbo].[GetReceiptsListReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveGid nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by Archive, IntNumber, Number
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
				(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = fund.ArchiveGid) as Archive,
				fund.Number,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				COALESCE(
					fund.ImmediateSourceOfAcquisition + '' / '' + ' + @methodOfAcquisitionQueryRemote +  ', 
					fund.ImmediateSourceOfAcquisition + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryRemote + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				cast(fund.AECount as bigint) as ArchiveEntitiesCount,
				isnull(fund.LinearMeters, 0),
				(
					select (isnull(convert(varchar, fund.EndDateDay) + ''.'', '''') + isnull(convert(varchar, fund.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, fund.EndDateYear), '''')) + ''; '' 
					from  Document_Modified d
					where d.FundLGid = fund.LGid 
					FOR XML path(''''), elements
				) as DocumentsEndDates,
				fund.Note,
				fund.IntNumber
			FROM Fund_Modified as fund
			WHERE 
				(''-999'' in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '','')) OR fund.ArchiveGid in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '',''))) 
					AND (fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1) 
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3))';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				(SELECT Name FROM [Archives] a where a.Id = ArchiveId) as Archive,
				Number,
				convert(varchar, CreatedOn, 104) as CreationDate,
				COALESCE(
					DocumentsProvider + '' / '' + ' + @methodOfAcquisitionQueryLocal +  ',
					DocumentsProvider + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryLocal + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				Title,
				ArchivalEntityCount as ArchiveEntitiesCount,
				isnull(LinearMeters, 0) as LinearMeters,
				(
					select (isnull(convert(varchar, EndDateDay) + ''.'', '''') + isnull(convert(varchar, EndDateMonth) + ''.'', '''') + isnull(convert(varchar, EndDateYear), '''')) + ''; '' 
					from  Documents d
					where d.FundSystemIdentifier = SystemIdentifier 
					FOR XML path(''''), elements
				) as DocumentsEndDates,
				Notes as Note,
				NumberNumeric as IntNumber
			FROM Funds 
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode IN(1, 2, 4)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))';
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
				ArchiveEntitiesCount bigint NULL,
				LinearMeters float NULL, 
				DocumentsEndDates nvarchar(MAX) NULL,
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
		SET @sql = 'DECLARE @methodOfAcquisitionQueryLocal VARCHAR(MAX);' + @localQuery + @sqlFinalPart;
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
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@RegisteredFrom nvarchar(100) = NULL,
	@RegisteredTo nvarchar(100) = null,
	@DocLGid nvarchar(max) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
	
AS
BEGIN
SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @remoteQuery VARCHAR(MAX) = 
		'SELECT
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = (SELECT LevelOfDescriptionGid from Fund_Modified f where f.LGid = doc.FundLGid)) as LevelOfDescription,
			''Process.aspx?type=Document&agid='' + cast(doc.ArchiveGid as nvarchar(255)) + ''&flgid='' + cast(doc.FundLGid as nvarchar(255)) + ''&ilgid='' + cast(doc.InventoryLGid as nvarchar(255)) + ''&aelgid='' + cast(doc.AELGid as nvarchar(255)) + ''&dlgid=''+ cast(doc.LGid as nvarchar(255)) as DocumentLink,
			(select Name from archive where _retired = ''3000-01-01'' and Gid = doc.ArchiveGid) ArchiveName,
			(select CAST(Code as nvarchar(10)) from archive where _retired = ''3000-01-01'' and Gid = doc.ArchiveGid) ArchiveCode,
			doc.LGid as SystemId,
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
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = doc.StatusGid) as DocStatus,
			convert(varchar, doc.DOCreationDate, 104) as DigitalObjectCreationDate,
			COUNT(img.Gid) as ImageCount,
			SUM(isnull(img.ByteLenght, 0)) as BytesCount,
			case when isnull(DigitalObjectDeleted, 0) = 0 then ''Активен'' else ''Заличен'' end as DigitalObjectStatus,
			doc.DOCreationAuthor,
			(
				select convert(varchar, max(p.ModifiedOn), 104)  
				from Document d
				inner join Process p on p._retired = ''3000-01-01'' and p.Gid = d.ProcessGid and p.TypeGid = 2124 and p.StepGid = 75
				where  d.LGid = doc.lgid
			) as ModifiedOn,
			(SELECT TOP 1 IntNumber from Fund_Modified f where f.LGid = doc.FundLGid) as FundIntNumber,
			(SELECT IntNumber from Inventory_Modified i where i.LGid = doc.InventoryLGid) as InventoryIntNumber,
			(SELECT IntNumber from ArchiveEntity_Modified ae where ae.LGid = doc.AELGid) as ArchivalEntityIntNumber
		FROM
			Document_Active doc -- в ИСДА ползват Document_Active за тази справка
			left outer join [Image] img on doc.Gid = img.DocumentGid and img._retired = ''3000-01-01''
		WHERE
			ISNULL(doc.HasDigitalObject, 0) = 1
			AND (''' + COALESCE(@DocLGid, 'null') + ''' = ''null'' OR doc.LGid = ''' + COALESCE(@DocLGid, 'null') + ''')
			AND (''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'' OR cast(doc.DOCreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2))
			AND (''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'' OR cast(doc.DOCreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2))
			AND ((''active'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1 and isnull(DigitalObjectDeleted, 0) = 0))
				OR (''deleted'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1 and isnull(DigitalObjectDeleted, 0) = 1))
				OR (''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1)))
			AND (''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')) OR doc.ArchiveGid in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
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
		doc.DOCreationAuthor';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			--(SELECT Text FROM [N].[DocumentDescriptionLevel] dl where dl.Code = DescriptionLevelCode) as LevelOfDescription,
			(SELECT Text FROM [N].[FundDescriptionLevel] fdl where fdl.Code = (SELECT DescriptionLevelCode FROM Funds f where f.SystemIdentifier = FundSystemIdentifier)) as LevelOfDescription,
			''todo: link'' as DocumentLink,
			(SELECT Name FROM [Archives] a where a.Id = ArchiveId) as ArchiveName,
			(SELECT Code FROM [Archives] a where a.Id = ArchiveId) as ArchiveCode,
			Id as SystemId,
			(SELECT Number FROM Funds f where f.SystemIdentifier = FundSystemIdentifier) as FundNumber,
			(SELECT Number FROM Inventories i where i.SystemIdentifier = InventorySystemIdentifier) as InventoryNumber,
			(SELECT Number FROM ArchivalEntities ae where ae.SystemIdentifier = ArchivalEntitySystemIdentifier) as ArchiveEntityNumber,
			(CAST(StartSheetNumber AS nvarchar(50)) + '' - '' + CAST(EndSheetNumber AS nvarchar(50))) as ListNumbers, -- todo: различава се от ИСДА
			Title as DocumentTitle,
			ApproxmateChronologicalScope as ChronologicalScope,
			(SELECT Text FROM [N].[Status] s where s.Code = StatusCode) as DocStatus,
			NULL as DigitalObjectCreationDate, -- todo: къде е?
			NULL as ImageCount, -- todo
			NULL as BytesCount, -- todo
			NULL as DigitalObjectStatus, --todo
			NULL as DOCreationAuthor, --todo 
			convert(nvarchar,UpdatedOn, 104) as ModifiedOn,
			(SELECT NumberNumeric FROM Funds f where f.SystemIdentifier = FundSystemIdentifier) as FundIntNumber,
			(SELECT NumberNumeric FROM Inventories i where i.SystemIdentifier = InventorySystemIdentifier) as InventoryIntNumber,
			(SELECT NumberNumeric FROM ArchivalEntities ae where ae.SystemIdentifier = ArchivalEntitySystemIdentifier) as ArchivalEntityIntNumber
		FROM Documents d
		WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
				--AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					--OR ((select convert(varchar(4), Code, 104) from N.DocumentStatus s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))';

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteFundsTable TABLE (
			LevelOfDescription nvarchar(MAX) NULL,
			DocumentLink nvarchar(MAX) NULL,
			ArchiveName nvarchar(256) NOT NULL,
			ArchiveCode int NOT NULL,
			SystemId int NOT NULL,
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchiveEntityNumber nvarchar(256) NULL,
			ListNumbers nvarchar(MAX) NULL,
			DocumentTitle nvarchar(MAX) NULL,
			ChronologicalScope nvarchar(256) NULL, 
			DocStatus nvarchar(MAX) NULL,
			DigitalObjectCreationDate nvarchar(50) NULL,
			ImageCount bigint NULL,
			BytesCount bigint NULL,
			DigitalObjectStatus nvarchar(50) NULL,
			DOCreationAuthor nvarchar(256) NULL,
			ModifiedOn varchar(50) NULL,
			FundIntNumber int null,
			InventoryIntNumber int null,
			ArchivalEntityIntNumber int null
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteFundsTable
		UNION
		' +
		@localQuery + '
		order by ArchiveName, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchivalEntityIntNumber, ArchiveEntityNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetSpecialRegistrationListReport] 
	@LinkedServer NVARCHAR(50),
	@ArchiveGids NVARCHAR(10) = null,
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
			(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = doc.ArchiveGid) as Archive,
			(SELECT n.Value FROM Fund_Modified f 
				INNER JOIN Nomenclature n
				ON n.Gid = f.LevelOfDescriptionGid
				WHERE n._retired = ''3000-01-01'' AND n.Type=''LevelOfDescription'' AND f.LGid = doc.FundLGid 
			) AS DescriptionLevel,
			(SELECT Number FROM Fund_Modified f1 WHERE f1.LGid = doc.FundLGid) AS FundNumber,
			(SELECT Number FROM Inventory_Modified i1 WHERE i1.LGid = doc.InventoryLGid) AS InventoryNumber,
			(SELECT Number FROM ArchiveEntity_Modified ae WHERE ae.LGid = doc.AELGid) AS ArchiveEntityNumber,
			cast((select sum(isnull(i.ByteLenght, 0)) from Image i where i.DocumentGid = doc.Gid) * 0.000001 as decimal(10, 2)) as Size,
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
		WHERE
			doc.IsForSpecialRegistration = 1
				AND ((''-999'' IN (SELECT element FROM SplitString(''' + @ArchiveGids + CONVERT(NVARCHAR(MAX), N''', '',''))) OR ArchiveGid IN (SELECT element FROM dbo.SplitString(') + @ArchiveGids + CONVERT(NVARCHAR(MAX), N', '','')))
				AND (''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR (SELECT Number FROM Fund_Modified f WHERE f.LGid = doc.FundLGid) = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''')
				AND (''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR (SELECT Number FROM Inventory_Modified i WHERE i.LGid = doc.FundLGid) = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''')
				AND (''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR (SELECT Number FROM ArchiveEntity_Modified ae WHERE ae.LGid = doc.FundLGid) = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''')
				AND (''') + @isInRiskStr + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR CONVERT(NVARCHAR(4), doc.IsInRisk) = ') + @isInRiskStr + CONVERT(NVARCHAR(MAX), N')
				AND ((''-999'' IN (SELECT element FROM dbo.SplitString(''') + @DescriptionLevel + CONVERT(NVARCHAR(MAX), N''', '',''))) 
					OR (SELECT f.LevelOfDescriptionGid FROM Fund_Modified f 
						INNER JOIN Nomenclature n on n.Gid=f.LevelOfDescriptionGid
						WHERE f.LGid = doc.FundLGid AND n._retired = ''3000-01-01'') IN (SELECT element FROM dbo.SplitString(''') + @DescriptionLevel + CONVERT(NVARCHAR(MAX), N''', '',''))				
				)
		ORDER BY Archive, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchiveEntityIntNumber, ArchiveEntityNumber ASC
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

CREATE OR ALTER PROCEDURE [dbo].[GetWorkListForPriorityRestorationReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveGid nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null,
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
			WHERE (''-999'' in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '','')) OR doc.ArchiveGid in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '','')))'

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
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))';
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryBook] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null
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
				fund.IntNumber
			FROM Fund_Modified as fund
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR fund.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
				  AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 9) -- LevelOfDescription=КМФ';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				''E'' + convert(varchar(256), InventoryNumber) as Number,			
				(isnull(convert(varchar, AcceptedOnDay) + ''.'', '''') + isnull(convert(varchar, AcceptedOnMonth) + ''.'', '''') + isnull(convert(varchar, AcceptedOnYear), '''')) as ReceivedOn,
				(select Text from [N].[Nomenclatures] n where n.Id = CountryId) as CountryOfOrigin,
				coalesce(
					convert(varchar(10), MicrofilmNegativeRollsCount) + ''-'' + convert(varchar(10), MicrofilmNegativeFramesCount), 
					convert(varchar(10), MicrofilmNegativeRollsCount) + ''-'', 
					''-'' + convert(varchar(10), MicrofilmNegativeFramesCount)) as Negatives,
				coalesce(
					convert(varchar(10), MicrofilmPositiveRollsCount) + ''-'' + convert(varchar(10), MicrofilmPositiveFramesCount), 
					convert(varchar(10), MicrofilmPositiveRollsCount) + ''-'', 
					''-'' + convert(varchar(10), MicrofilmPositiveFramesCount)) as Positives,
				convert(varchar(250), PhotoCopy) as CopyXerox,
				convert(varchar(250), DigitalCopy) as CopyDigital,
				NULL as HasInventory,
				Content as ShortDescription,
				Source as CreationAuthor,
				Notes as Note,
				InventoryNumber as IntNumber
			FROM films
			WHERE --ExternalIdentifier IS NULL AND HasExternalSource = 0
				Deleted = 0 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))';
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryBookOfCopiesFromForeignArchivesReport]
	@LinkedServer nvarchar(50), -- Посочване на външната база
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null	
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
			NULL as ElectronicDocumentsMB,
			fund.CopyOther as Other,
			(select cast(1 as bit) where exists(select 1 from Inventory_Modified i where i.FundLGid=fund.LGid)) as HasInventory,
			fund.InventoryShortDescroption as InventoryShortDescription,
			fund.CreationAuthor,
			fund.IntNumber
		FROM Fund_Modified as fund
		WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR fund.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
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
			(select SUM(fpd.FileSizeInBytes) * 0.000001 from FilmPackageDocuments as fpd join FilmPackages as fp on fpd.PackageId = fp.Id where fp.Id = films.PackageBId AND fpd.Deleted = 0) as ElectronicDocumentsMB,
			films.Other,
			NULL as HasInventory,
			films.Content as InventoryShortDescription,
			films.Source as CreationAuthor,
			films.InventoryNumber as IntNumber
		FROM Films as films
		WHERE --ExternalIdentifier IS NULL AND HasExternalSource = 0 
			Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))';
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
				ElectronicDocumentsMB nvarchar(256) NULL,
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetRegisterOfDigitizedDocumentsReport]
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by ArchiveName, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchivalEntityIntNumber, ArchiveEntityNumber
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT 
			''Link_todo'' as DocumentLink,
			(select CAST(a.Code as nvarchar(10)) from archive as a where _retired = ''3000-01-01'' and Gid = d.ArchiveGid) as ArchiveCode,
			(select a.Name from archive as a where _retired = ''3000-01-01'' and Gid = d.ArchiveGid) as ArchiveName,
			CAST(d.Gid as nvarchar(256)) as SystemId,
			(select n.Value FROM Nomenclature as n where _retired = ''3000-01-01'' and Gid = (SELECT LevelOfDescriptionGid from Fund_Modified f where f.LGid = d.FundLGid)) as LevelOfDescription,
			(select top 1 Number from Fund_Modified f where f.LGid = d.FundLGid) as FundNumber,
			(select i.Number from Inventory_Modified as i where i.LGid = d.InventoryLGid) as InventoryNumber,
			(select ae.Number from ArchiveEntity_Modified as ae where ae.LGid = d.AELGid) as ArchiveEntityNumber,
			CAST(d.Title as nvarchar(256)) as Title,
			CAST(convert(varchar, d.DOCreationDate, 104) as nvarchar(50)) as DocCreationDate,
			(select n.Value + '', ''
				from Nomenclature n
				inner join ObjectNomenclature objn on n.Gid = objn.NomenclatureGid and objn._retired = ''3000-01-01'' and objn.DocumentGid = d.Gid
				where 
				n._retired = ''3000-01-01''
				and n.[Type] = ''Annotated''
				FOR XML path(''''), elements) as Themes,
			(select n.Value FROM Nomenclature as n where _retired = ''3000-01-01'' and Gid = d.StatusGid) as DocStatus,
			CAST((select top(1) img.CreatedOn from Image as img where d.Gid = img.DocumentGid and img._retired = ''3000-01-01'') as nvarchar(50)) as CreationDateDO,
			COUNT(img.Gid) as RecordsCountDO,
			NULL as Duration,
			CAST((
				select convert(varchar, max(p.ModifiedOn), 104)  
				from Document doc
				inner join Process p on p._retired = ''3000-01-01'' and p.Gid = doc.ProcessGid and p.TypeGid = 2124 and p.StepGid = 75
				where doc.LGid = d.lgid
			) as nvarchar(50)) as DigitalObjectRecreationDate,
			CAST((SUM(isnull(img.ByteLenght, 0))*0.000001) as nvarchar(256)) as MbDO,
			case when isnull(d.DigitalObjectDeleted, 0) = 0 then ''Активен'' else ''Заличен'' end as StatusDO,
			d.DOCreationAuthor as Operator,
			NULL as CorrectionReturnDate,
			NULL as FinalCorrectionDate,
			CAST((
				select convert(varchar, max(p.ModifiedOn), 104)  
				from Document doc
				inner join Process p on p._retired = ''3000-01-01'' and p.Gid = doc.ProcessGid and p.TypeGid = 2123 and p.StepGid = 75
				where doc.LGid = d.lgid
			) as nvarchar(50)) as DigitalObjectAcceptanceDate,
			(select top 1 IntNumber from Fund_Modified f where f.LGid = d.FundLGid) as FundIntNumber,
			(select i.IntNumber from Inventory_Modified as i where i.LGid = d.InventoryLGid) as InventoryIntNumber,
			(select ae.IntNumber from ArchiveEntity_Modified as ae where ae.LGid = d.AELGid) as ArchivalEntityIntNumber
		FROM Document_Modified as d
		LEFT OUTER JOIN [Image] img on d.Gid = img.DocumentGid and img._retired = ''3000-01-01''
		WHERE ISNULL(d.HasDigitalObject, 0) = 1
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR d.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
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
			d.DOCreationAuthor'
			  
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT 
			''Link_todo'' as DocumentLink,
			CAST((select a.Code FROM [Archives] as a where a.Id = ArchiveId) as nvarchar(256)) as ArchiveCode,
			(select a.Name FROM [Archives] as a where a.Id = d.ArchiveId) as ArchiveName,
			CAST(d.SystemIdentifier as nvarchar(256)) as SystemId,
			(select fdl.Text FROM [N].[FundDescriptionLevel] as fdl where fdl.Code = (select f.DescriptionLevelCode FROM Funds f where f.SystemIdentifier = d.FundSystemIdentifier)) as LevelOfDescription,
			CAST((select f.Number FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as nvarchar(256)) as FundNumber,
			CAST((select i.Number FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as nvarchar(256)) as InventoryNumber,
			CAST((select ae.Number FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as nvarchar(256)) as ArchiveEntityNumber,
			CAST(d.Title as nvarchar(256)) as Title,
			CAST(d.CreatedOn as nvarchar(50)) as DocCreationDate,
			NULL as Themes,
			(select n.Text from N.Nomenclatures as n where n.Id = d.StatusCode and n.Deleted = 0) as DocStatus,
			CAST((select top(1) do.CreatedOn from DigitalObjects as do where do.DocumentSystemIdentifier = d.SystemIdentifier) as nvarchar(50)) as CreationDateDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
			d.DigitizedCopyCount as RecordsCountDO,
			CAST(d.Duration as nvarchar(256)) as Duration,
			NULL as DigitalObjectRecreationDate,
			CAST(isnull(d.Bytes, 0)*0.000001 as nvarchar(256)) as MbDO,
			(select top(1) n.Text from N.Nomenclatures as n join DigitalObjects as do on n.Id = do.StatusCode where do.DocumentSystemIdentifier = d.SystemIdentifier and n.Deleted = 0) as StatusDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
			NULL as Operator,
			NULL as CorrectionReturnDate,
			NULL as FinalCorrectionDate,
			NULL as DigitalObjectAcceptanceDate,
			CAST((select f.NumberNumeric FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as nvarchar(256)) as FundIntNumber,
			CAST((select i.NumberNumeric FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as nvarchar(256)) as InventoryIntNumber,
			CAST((select ae.NumberNumeric FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as nvarchar(256)) as ArchivalEntityIntNumber
		FROM Documents as d
		WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
			  AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
			  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
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
				MbDO nvarchar(256) NULL,
				StatusDO nvarchar(MAX) NULL,
				Operator nvarchar(MAX) NULL,
				CorrectionReturnDate nvarchar(50) NULL,
				FinalCorrectionDate nvarchar(50) NULL,
				DigitalObjectAcceptanceDate nvarchar(50) NULL,
				FundIntNumber INT NULL,
				InventoryIntNumber INT NULL,
				ArchivalEntityIntNumber INT NULL
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


commit