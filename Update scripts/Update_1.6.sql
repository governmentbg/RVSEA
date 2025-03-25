SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.6'
where Code = 'DB_VERSION'


-- add scripts here

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
			''http://212.122.187.196:84/Process.aspx?type=Document&agid='' + cast(doc.ArchiveGid as nvarchar(255)) + ''&flgid='' + cast(doc.FundLGid as nvarchar(255)) + ''&ilgid='' + cast(doc.InventoryLGid as nvarchar(255)) + ''&aelgid='' + cast(doc.AELGid as nvarchar(255)) + ''&dlgid=''+ cast(doc.LGid as nvarchar(255)) as DocumentLink,
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
			--(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = doc.StatusGid) as DocStatus, -- отпада по искане на ДАА
			convert(varchar, doc.DOCreationDate, 104) as DigitalObjectCreationDate,
			COUNT(img.Gid) as ImageCount,
			SUM(isnull(img.ByteLenght, 0)) as BytesCount,
			--case when isnull(DigitalObjectDeleted, 0) = 0 then ''Активен'' else ''Заличен'' end as DigitalObjectStatus, -- отпада по искане на ДАА
			doc.DOCreationAuthor,
			--(
				--select convert(varchar, max(p.ModifiedOn), 104)  
				--from Document d
				--inner join Process p on p._retired = ''3000-01-01'' and p.Gid = d.ProcessGid and p.TypeGid = 2124 and p.StepGid = 75
				--where  d.LGid = doc.lgid
			--) as ModifiedOn,  -- отпада по искане на ДАА
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
			'''' as DocumentLink,
			(SELECT Name FROM [Archives] a where a.Id = ArchiveId) as ArchiveName,
			(SELECT Code FROM [Archives] a where a.Id = ArchiveId) as ArchiveCode,
			Id as SystemId,
			(SELECT Number FROM Funds f where f.SystemIdentifier = FundSystemIdentifier) as FundNumber,
			(SELECT Number FROM Inventories i where i.SystemIdentifier = InventorySystemIdentifier) as InventoryNumber,
			(SELECT Number FROM ArchivalEntities ae where ae.SystemIdentifier = ArchivalEntitySystemIdentifier) as ArchiveEntityNumber,
			(CAST(StartSheetNumber AS nvarchar(50)) + '' - '' + CAST(EndSheetNumber AS nvarchar(50))) as ListNumbers, -- todo: различава се от ИСДА
			Title as DocumentTitle,
			ApproxmateChronologicalScope as ChronologicalScope,
			-- (SELECT Text FROM [N].[Status] s where s.Code = StatusCode) as DocStatus, -- отпада по искане на ДАА
			NULL as DigitalObjectCreationDate, -- todo: къде е?
			NULL as ImageCount, -- todo
			NULL as BytesCount, -- todo
			-- NULL as DigitalObjectStatus, -- отпада по искане на ДАА
			NULL as DOCreationAuthor, --todo 
			-- convert(nvarchar,UpdatedOn, 104) as ModifiedOn, -- отпада по искане на ДАА
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
			-- DocStatus nvarchar(MAX) NULL, -- отпада по искане на ДАА
			DigitalObjectCreationDate nvarchar(50) NULL,
			ImageCount bigint NULL,
			BytesCount bigint NULL,
			-- DigitalObjectStatus nvarchar(50) NULL, -- отпада по искане на ДАА
			DOCreationAuthor nvarchar(256) NULL,
			-- ModifiedOn varchar(50) NULL, -- отпада по искане на ДАА
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

if not exists (select null from N.ProcessSteps)
begin 
	insert into N.ProcessSteps(Id,ProcessTypeId, Code, Text)
	values (246, 10, 'ReportChangesRequired', 'Връщане за корекции')
			
end
go
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetRegisterOfDigitizedDocumentsSummary]
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
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
    	




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
				ArchivalEntityIntNumber INT NULL
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
				ArchivalEntityIntNumber
			)
	EXEC [sp_GetRegisterOfDigitizedDocumentsReport]
	@LinkedServer,
	@ResultType,
	@RowsOfPage,
	@Page,
	@ArchiveGids,
	@ArchiveCodesInternal,
	@RegisteredFrom,
	@RegisteredTo

	SET @sql = '
		SELECT COUNT_BIG(*) as TotalRows
		FROM #temp'

	--print @sql;
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
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null,
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
				MbDO float NULL,
				StatusDO nvarchar(MAX) NULL,
				Operator nvarchar(MAX) NULL,
				CorrectionReturnDate nvarchar(50) NULL,
				FinalCorrectionDate nvarchar(50) NULL,
				DigitalObjectAcceptanceDate nvarchar(50) NULL,
				FundIntNumber INT NULL,
				InventoryIntNumber INT NULL,
				ArchivalEntityIntNumber INT NULL
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
				ArchivalEntityIntNumber
			)
	EXEC [sp_GetRegisterOfDigitizedDocumentsReport]
	@LinkedServer,
	@ResultType,
	2147483647,
	@Page,
	@ArchiveGids,
	@ArchiveCodesInternal,
	@RegisteredFrom,
	@RegisteredTo

	SET @sql = '
		SELECT TOP 1
			NULL as PeriodFrom,
			NULL as PeriodTo,
			NULL as Employee
		FROM #temp'

	--print @sql;
	EXEC (@sql);
END
GO


-- update Size in bytes for films and film drafts based on included documents
update F
set Size = (select IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) from FilmPackageDocuments D where D.PackageId = F.PackageBId and D.Deleted = 0) 
from Films F
where F.Deleted = 0
go


update F
set Size = (select IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) from FilmPackageDocuments D where D.PackageId = F.PackageBId and D.Deleted = 0) 
from FilmDrafts F
where F.IsCurrent = 1 and F.Deleted = 0
go

if not exists (select null from N.ProcessSteps)
begin 
	insert into N.ProcessSteps(Id,ProcessTypeId, Code, Text)
	values (246, 10, 'ReportChangesRequired', 'Връщане за корекции')
			
end
go

-- update Size and Format for film cards and film card drafts based on included documents
update F
set Size = (select IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) 
			from FilmPackageDocuments D
			join FilmCardDocuments FD on FD.PackageDocumentId = D.Id 
			where FD.CardId = F.Id and FD.IsDraft = 0 and D.Deleted = 0),
	DocumentsFormat = (select STRING_AGG(D.FileType, ', ') 
						from FilmPackageDocuments D
						join FilmCardDocuments FD on FD.PackageDocumentId = D.Id 
						where FD.CardId = F.Id and FD.IsDraft = 0 and D.Deleted = 0)
from FilmCards F
where F.Deleted = 0
go



update F
set Size = (select IsNull(sum(IsNull(D.FileSizeInBytes,0)),0) 
			from FilmPackageDocuments D
			join FilmCardDocuments FD on FD.PackageDocumentId = D.Id 
			where FD.CardId = F.Id and FD.IsDraft = 1 and D.Deleted = 0),
	DocumentsFormat = (select STRING_AGG(D.FileType, ', ') 
						from FilmPackageDocuments D
						join FilmCardDocuments FD on FD.PackageDocumentId = D.Id 
						where FD.CardId = F.Id and FD.IsDraft = 1 and D.Deleted = 0)
from FilmCardDrafts F
where F.IsCurrent = 1 and F.Deleted = 0
go

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
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@TextDate nvarchar(2000) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQueryWhereClause VARCHAR(MAX) = '((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR fund.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE( + @TextDate, 'null') + '''))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))';

		DECLARE @remoteQuery VARCHAR(MAX) = 
			'SELECT
				COUNT_BIG(*) TotalFunds,
				sum(isnull(convert(bigint, fund.InvetoryCount), 0)) TotalInventories,
				sum(isnull(convert(bigint, fund.AECount), 0)) TotalArchiveEntities,
				round(sum(fund.LinearMeters), 2) TotalLinearMeters,
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
			FROM Fund_Modified as fund
			WHERE ' + @remoteQueryWhereClause;

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQueryWhereClause VARCHAR(max) = '
			ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
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

		DECLARE @localQuery VARCHAR(max) = 
			'SELECT
				COUNT_BIG(*) TotalFunds,
				sum(isnull(InventoryCount, 0)) TotalInventories,
				sum(isnull(ArchivalEntityCount, 0)) TotalArchiveEntities,
				round(sum(LinearMeters), 2) TotalLinearMeters,
				cast((select sum(sizes.Size) 
				from 
					(select (select sum(isnull(d.Bytes, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Size
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) sizes) as decimal(10, 2)) TotalSize -- въпреки че колоната се казва Bytes, тя съдържа MB, затова няма превръщане на мерните ед.
				FROM Funds f
				WHERE ' + @localQueryWhereClause;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
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
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR fund.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))
			AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE( + @TextDate, 'null') + '''))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
		';
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT
				COUNT_BIG(*) TotalRows,
				SUM(round(isnull(cast(fund.LinearMeters as decimal(18,2)), 0),2)) TotalLinearMeters,
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
			FROM Fund_Modified as fund
			WHERE ' + @remoteQueryWhereClause;

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQueryWhereClause VARCHAR(MAX) = '
			ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
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
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
		';
		DECLARE @localQuery VARCHAR(max) = '
			SELECT
			COUNT_BIG(*) TotalRows,
			SUM(round(isnull(cast(LinearMeters as decimal(18,2)), 0),2)) TotalLinearMeters,
			cast((select sum(sizes.Size) 
				from 
					(select (select sum(isnull(d.Bytes, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Size
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) sizes) as decimal(10, 2)) TotalSize -- въпреки че колоната се казва Bytes, тя съдържа MB, затова няма превръщане на мерните ед.
			FROM Funds f
			WHERE ' + @localQueryWhereClause;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL,
				TotalLinearMeters decimal NULL,
				TotalSize decimal NULL
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

CREATE OR ALTER PROCEDURE [dbo].[GetFundMemoriesListReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveGid nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQueryWhereClause VARCHAR(MAX) = '
			(''-999'' in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '','')) OR fund.ArchiveGid in (select element from dbo.SplitString(''' + @ArchiveGid + ''', '',''))) 
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3)'
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT_BIG(*) TotalRows,
			round(sum(fund.LinearMeters), 2) TotalLinearMeters,
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
			FROM Fund_Modified as fund
			WHERE ' + @remoteQueryWhereClause;

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQueryWhereClause VARCHAR(MAX) = '
			ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode = 3 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))';
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows,
			round(sum(LinearMeters), 2) TotalLinearMeters,
			cast((select sum(sizes.Size) 
				from 
					(select (select sum(isnull(d.Bytes, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Size
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) sizes) as decimal(10, 2)) TotalSize -- въпреки че колоната се казва Bytes, тя съдържа MB, затова няма превръщане на мерните ед.
			FROM Funds 
			WHERE ' + @localQueryWhereClause;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL,
				TotalLinearMeters float NULL,
				TotalSize decimal NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows, sum(isnull(u.TotalLinearMeters, 0)) as TotalLinearMeters, sum(isnull(u.TotalSize, 0)) as TotalSize 
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
		''archival_entity'' AS EntityType, 
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
		+ @rankRemote;

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
			Rank
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
			Rank
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
			' + @rank + '
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
			Rank INT
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


if exists (select null from sys.columns where name = 'RelatedContentUrl' and object_id = object_id ('dbo.Tasks'))
begin 
	alter table dbo.Tasks alter column RelatedContentUrl nvarchar(512)
end
go

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
		FROM ArchiveEntity_Active ae
		WHERE 
			LGid = ' + CAST(@Identifier as varchar(10));

	set @sql = REPLACE(@sql, '''', '''''');
	declare @result varchar(max) = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''')';

	exec (@result);
END
GO

CREATE OR ALTER   PROCEDURE [dbo].[MainSearchComponent]
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
		[Rank] INT NULL 
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
		[Rank] 
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
	IF 'inventory' IN (SELECT element FROM @entityTypesArr) SET @includeLocalIventories = 1;
	IF NOT (@FundNumber IS NOT NULL AND @InventoryNumber IS NULL) 
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') SET @inventoriesInsert = '
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
	IF 'archival_entity' IN (SELECT element FROM @entityTypesArr) SET @includeLocalArchivalEntities = 1;
	IF NOT (@FundNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL)
		AND @KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') 	
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
	IF 'document' IN (SELECT element FROM @entityTypesArr) SET @includeLocalDocuments = 1;
	IF @FundNumber IS NULL AND @InventoryNumber IS NULL AND @ArchivalEntityNumber IS NULL
		AND @KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') 
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
	IF 'film' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFilms = 1;
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
	IF @FundNumber IS NULL 
		AND @InventoryNumber IS NULL 
		AND 'film_card' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFilmCards = 1;
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
			[Rank]
		FROM @result
		ORDER BY 
			[Rank] DESC,                                                                                                                                                                                                                  EntityType ASC,         -- RANK играе роля при full text search.                                                                                                                                    ArchiveName ASC,  -- колоните с ...Int... представляват числото от номера
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

CREATE OR ALTER   PROCEDURE [dbo].[MainSearchComponentInternal]
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
		[Rank] INT NULL 
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
		[Rank]
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
	IF NOT (@FundNumber IS NOT NULL AND @InventoryNumber IS NULL)  
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') 
		AND 'inventory' IN (SELECT element FROM @entityTypesArr) SET @inventoriesInsert = '
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
	IF NOT (@FundNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL) 
		AND @KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') 
		AND 'archival_entity' IN (SELECT element FROM @entityTypesArr)
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
	IF @FundNumber IS NULL AND @InventoryNumber IS NULL AND @ArchivalEntityNumber IS NULL
		AND @KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
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
			[Rank]
		FROM @result
		ORDER BY 
			[Rank] DESC,                                                                                                                                                                                                                  EntityType ASC,         -- RANK играе роля при full text search.                                                                                                                                    ArchiveName ASC,  -- колоните с ...Int... представляват числото от номера
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

update N.ProcessTypes
set Name = N'Регистриране на нов фонд с необработени документи'
where Id = 16
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
	if @LevelOfDescriptionGids is not null and @LevelOfDescriptionGids <> '-999' set @remoteQuery = @remoteQuery + '
		and (fund.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' ) and fund.LevelOfDescriptionGid <> 2185
	';
	set @remoteQuery = @remoteQuery + 'and fund.LevelOfDescriptionGid <> 2185';
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
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' inner join v_PublicDocuments d on d.FundSystemIdentifier = f.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' inner join v_Documents d on d.FundSystemIdentifier = f.SystemIdentifier';

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
	IF @SearchDrafts = 1 SET @table = 'v_Funds' ELSE SET @table = 'v_PublicFunds';

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';

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
				OR (f.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))) )'
			+ @fundNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @DescriptionLevelCodesInternal + ''', '',''))) 
				OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''' + @DescriptionLevelCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @digitalObjectsFilter
			+ @doNotGetAnythingFilter
			+ @isSuspenedFilter
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

CREATE OR ALTER PROCEDURE [dbo].[SearchFundsForMainSearchComponentInternal]  
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
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' inner join v_PublicDocuments d on d.FundSystemIdentifier = f.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' inner join v_Documents d on d.FundSystemIdentifier = f.SystemIdentifier';

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
	IF @SearchDrafts = 1 SET @table = 'v_Funds' ELSE SET @table = 'v_PublicFunds';

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
		+ @freeTextTableByTitleJoin + 
		+ @freeTextTableByKwdsJoin + 
		+ @documentsJoin + '
		WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))) 
				OR (f.NumberArray in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (f.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) )'
			+ @fundNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @DescriptionLevelCodes + ''', '',''))) 
				OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''' + @DescriptionLevelCodes + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @digitalObjectsFilter 
			+ @isSuspenedFilter + 
			+ @rankFilter + '
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
	if @LevelOfDescriptionGids is not null and @LevelOfDescriptionGids <> '-999' set @remoteQuery = @remoteQuery + '
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

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' inner join v_PublicDocuments d on d.InventorySystemIdentifier = i.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' inner join v_Documents d on d.InventorySystemIdentifier = i.SystemIdentifier';

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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))) 
				OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(i.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(i.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @doNotGetAnythingFilter
			+ @isSuspenedFilter
			+ @roughInventoriesFilter
			+ @digitalObjectsFilter
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

	--print @sql;
	EXEC (@sql);
END
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

	DECLARE @roughInventoriesFilter VARCHAR(MAX) = '';
	-- Грубите описи да са видими само в служебната част на системата
	IF @SearchDrafts = 0 SET @roughInventoriesFilter = ' AND i.DescriptionLevelCode <> ''6''';


	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' inner join v_PublicDocuments d on d.InventorySystemIdentifier = i.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' inner join v_Documents d on d.InventorySystemIdentifier = i.SystemIdentifier';

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
		WHERE i.ExternalIdentifier IS NULL AND i.HasExternalSource = 0 AND i.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArrays + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (i.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodes + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundDescriptionLevel fdl where fdl.Code = f.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodes + ''', '',''))) 
				OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodes + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(i.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(i.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @isSuspenedFilter
			+ @roughInventoriesFilter
			+ @digitalObjectsFilter
			+ @rankFilter;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
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
	if @LevelOfDescriptionGids is not null and @LevelOfDescriptionGids <> '-999' set @remoteQuery = @remoteQuery + '
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

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_ArchivalEntities' ELSE SET @table = 'v_PublicArchivalEntities';

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' inner join v_PublicDocuments d on d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' inner join v_Documents d on d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier';

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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodesInternal + ''', '',''))) 
				OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(ae.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(ae.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @doNotGetAnythingFilter
			+ @isSuspenedFilter
			+ @digitalObjectsFilter
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

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_ArchivalEntities' ELSE SET @table = 'v_PublicArchivalEntities';

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' inner join v_PublicDocuments d on d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' inner join v_Documents d on d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier';

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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodes + ''', '',''))) 
				OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodes + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(ae.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(ae.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @isSuspenedFilter
			+ @digitalObjectsFilter
			+ @rankFilter;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
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
			+ @archivalEntityNumberFilter + '
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
	if @LevelOfDescriptionGids is not null and @LevelOfDescriptionGids <> '-999' set @remoteQuery = @remoteQuery + '
		and (fund.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )
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
		WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
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
		WHERE c.ExternalIdentifier IS NULL AND c.HasExternalSource = 0 AND c.Deleted = 0 
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

	--DECLARE @keywordsUIAnnotatedColumn VARCHAR(MAX) = '';
	--IF @KeywordsUIAnnotated IS NULL SET @keywordsUIAnnotatedColumn = 'NULL' 
	--ELSE SET @keywordsUIAnnotatedColumn = convert(varchar(1), @KeywordsUIAnnotated, 104);

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
	IF 'inventory' IN (SELECT element FROM @entityTypesArr) SET @includeLocalIventories = 1;
	IF NOT (@FundNumber IS NOT NULL AND @InventoryNumber IS NULL) 
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') SET @inventoriesInsert = '
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
	IF 'archival_entity' IN (SELECT element FROM @entityTypesArr) SET @includeLocalArchivalEntities = 1;
	IF NOT (@FundNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL)
		AND @KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') 	
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
	IF 'document' IN (SELECT element FROM @entityTypesArr) SET @includeLocalDocuments = 1;
	IF @FundNumber IS NULL AND @InventoryNumber IS NULL AND @ArchivalEntityNumber IS NULL
		AND @KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') 
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
	IF 'film' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFilms = 1;
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
	IF @FundNumber IS NULL 
		AND @InventoryNumber IS NULL 
		AND 'film_card' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFilmCards = 1;
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
			[Rank] DESC,                                                                                                                                                                                                                  EntityType ASC,         -- RANK играе роля при full text search.                                                                                                                                    ArchiveName ASC,  -- колоните с ...Int... представляват числото от номера
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
	IF NOT (@FundNumber IS NOT NULL AND @InventoryNumber IS NULL)  
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') 
		AND 'inventory' IN (SELECT element FROM @entityTypesArr) SET @inventoriesInsert = '
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
	IF NOT (@FundNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL) 
		AND @KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') 
		AND 'archival_entity' IN (SELECT element FROM @entityTypesArr)
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
	IF @FundNumber IS NULL AND @InventoryNumber IS NULL AND @ArchivalEntityNumber IS NULL
		AND @KMFNumber IS NULL
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')
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
			[Rank] DESC,                                                                                                                                                                                                                  EntityType ASC,         -- RANK играе роля при full text search.                                                                                                                                    ArchiveName ASC,  -- колоните с ...Int... представляват числото от номера
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


DROP PROCEDURE IF EXISTS dbo.sp_GetArchiveEntitiesByInventory
GO

CREATE PROCEDURE dbo.sp_GetArchiveEntitiesByInventory
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


if not exists (select null from sys.columns where name = 'AllowTaskTemplate' and object_id = object_id ('N.ProcessSteps'))
begin 
	alter table N.ProcessSteps add AllowTaskTemplate bit null 
	exec('update N.ProcessSteps set AllowTaskTemplate = 0 ')
	exec('update N.ProcessSteps set AllowTaskTemplate = 1 where Id in (3, 5, 9, 11, 15, 17, 20, 21, 22, 23, 24, 26, 32, 33, 34, 35, 36, 37, 38, 64, 101, 107, 115, 116, 117, 118, 119, 120, 121, 122, 124, 125, 126, 128, 129, 131, 132, 133, 135, 136, 137, 139, 145, 147, 150, 151, 166, 167, 171, 174, 175, 177, 178, 179, 180, 181, 183, 185, 186, 193, 196, 197, 199, 200, 201, 202, 203, 205, 207, 208, 209, 211, 216, 220, 221, 222, 223, 224, 225, 226, 228, 230, 232, 234, 235, 237, 238, 244, 245, 1001, 1006, 1013)')
	alter table N.ProcessSteps add constraint [DF_ProcessSteps_AllowTaskTemplate] default (0) for AllowTaskTemplate
	alter table N.ProcessSteps alter column AllowTaskTemplate bit not null 
end
go



commit