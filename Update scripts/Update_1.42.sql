--SCRIPT CLOSED! USE THE NEXT ONE!

SET XACT_ABORT ON
GO

BEGIN TRANSACTION

update dbo._Version 
set Value = '1.42'
where Code = 'DB_VERSION'
go

update dbo._Version 
set Value = '1.1.34.1'
where Code = 'APP_VERSION'
go


-- Справка "Използване на цифровизирани документи" отново брои и анонимните достъпи от външни потребители
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

	DECLARE @dateCondition VARCHAR(MAX) = '
		AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(r.Date as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
		AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(r.Date as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))'

	DECLARE @condition VARCHAR(MAX) = '
		JOIN DigitalObjects do ON dor.DigitalObjectSystemIdentifier = do.SystemIdentifier
		JOIN Archives a ON a.Id = do.ArchiveId AND a.Deleted = 0
		JOIN Funds f ON f.SystemIdentifier = do.FundSystemIdentifier
		JOIN Documents d ON d.SystemIdentifier = dor.DocumentSystemIdentifier AND d.StatusCode <> ''12''-- 12 - отчислени
		WHERE do.ExternalIdentifier IS NULL AND do.HasExternalSource = 0 AND do.Deleted = 0 AND do.StatusCode <> ''12''-- 12 - отчислени
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(dor.Date as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(dor.Date as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
	';

	DECLARE @sql VARCHAR(MAX) = 
		'SELECT a.[Name] as ArchiveName, 
		 d.SystemIdentifier as DocumentSystemIdentifier,
		 d.Title as DocumentTitle,

	   (SELECT COUNT(*)
		FROM DigitalObjectReviews r
		JOIN AspNetUsers as u
		ON r.UserSystemIdentifier = u.Id
		LEFT JOIN AspNetUserProfiles up
		ON u.Id = up.UserId
		WHERE r.DocumentSystemIdentifier = d.SystemIdentifier
		AND up.ProfileType = ''EMP''
		' + @dateCondition + ') as EmpCount,

	   (SELECT COUNT(*)
		FROM DigitalObjectReviews r
		JOIN AspNetUsers as u
		ON r.UserSystemIdentifier = u.Id
		LEFT JOIN AspNetUserProfiles up
		ON u.Id = up.UserId
		WHERE r.DocumentSystemIdentifier = d.SystemIdentifier
		AND up.ProfileType = ''CDH''
		' + @dateCondition + ') as CdhCount,

	   (SELECT COUNT(*)
		FROM DigitalObjectReviews r
		JOIN AspNetUsers as u
		ON r.UserSystemIdentifier = u.Id
		LEFT JOIN AspNetUserProfiles up
		ON u.Id = up.UserId
		WHERE r.DocumentSystemIdentifier = d.SystemIdentifier
		AND (u.Id = ''22222222-2222-2222-2222-222222222222''
			OR (up.ProfileType <> ''EMP'' AND up.ProfileType <> ''CDH''))
		' + @dateCondition + ') as OtherCount

		FROM DigitalObjectReviews as dor
		' + @condition + '
		GROUP BY d.SystemIdentifier, a.[Name], d.Title
		ORDER BY ArchiveName
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY';

	EXEC (@sql);
END
GO
-- END Справка "Използване на цифровизирани документи" отново брои и анонимните достъпи от външни потребители

-- Справка "Регистър на цифровизирани документи" вече брои правилно "дигитални обекти"
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
	@RegisteredFrom datetime2(7) = null,
	@RegisteredTo datetime2(7) = null
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
			convert(varchar, d.ModifiedOn, 104) as FinalCorrectionDate,
			(
				select convert(varchar, max(p.ModifiedOn), 104)  
				from Document doc
				inner join Process p on p._retired = ''3000-01-01'' and p.Gid = doc.ProcessGid and p.TypeGid = 2123 and p.StepGid = 75
				where doc.LGid = d.lgid
			) as DigitalObjectAcceptanceDate,
			(select top 1 IntNumber from Fund_Modified f where f.LGid = d.FundLGid) as FundIntNumber,
			(select i.IntNumber from Inventory_Modified as i where i.LGid = d.InventoryLGid) as InventoryIntNumber,
			(select ae.IntNumber from ArchiveEntity_Modified as ae where ae.LGid = d.AELGid) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder,
			NULL as MastersCount,
			1 as AllDOCount
		FROM Document_Modified as d
		INNER JOIN Archive a ON a.Gid = d.ArchiveGid AND a._retired = ''3000-01-01''
		--inner join Fund_Modified f on f.LGid = d.FundLGid
		--inner join Inventory_Modified i on i.LGid = d.InventoryLGid
		--inner join ArchiveEntity_Modified ae on ae.LGid = d.AELGid
		LEFT OUTER JOIN [Image] img on d.Gid = img.DocumentGid and img._retired = ''3000-01-01''
		WHERE ISNULL(d.HasDigitalObject, 0) = 1
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) '

		IF (@RegisteredFrom IS NOT NULL)
		BEGIN
			SET @remoteQuery += 'AND cast(d.DOCreationDate as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
		END

		IF(@RegisteredTo IS NOT NULL)
		BEGIN
			SET @remoteQuery +='AND cast(d.DOCreationDate as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
		END
		
		SET @remoteQuery += ' GROUP BY
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
			d.ModifiedOn,
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
			CAST((select top(1) convert(varchar, do.CreatedOn, 104) from DigitalObjects as do where do.DocumentSystemIdentifier = d.SystemIdentifier) as nvarchar(50)) as CreationDateDO, 
			d.DigitizedCopyCount as RecordsCountDO,
			CAST(d.Duration as nvarchar(256)) as Duration,
			(select convert(varchar, d.UpdatedOn, 104) where d.StatusCode = 9) as DigitalObjectRecreationDate,
			isnull(dsi.EnrolledBytes, 0) as BytesDO,
			(select top(1) n.Text from N.Nomenclatures as n join DigitalObjects as do on n.Id = do.StatusCode where do.DocumentSystemIdentifier = d.SystemIdentifier and n.Deleted = 0) as StatusDO, 
			(select top(1) up.DisplayName from AspNetUserProfiles as up join DigitalObjects as do on up.UserId = do.CreatedBy where do.DocumentSystemIdentifier = d.SystemIdentifier and do.Deleted = 0) as Operator,
			(select top(1) convert(varchar, p.CreatedOn, 104) from Process as p where p.DocumentSystemIdentifier = d.SystemIdentifier and p.ProcessTypeId = 4 and p.Deleted = 0 order by p.CreatedOn desc) as CorrectionReturnDate,
			isnull(convert(varchar, d.UpdatedOn, 104), convert(varchar, d.CreatedOn, 104)) as FinalCorrectionDate,
			(select top(1) convert(varchar, p.UpdatedOn, 104) from Process as p where p.DocumentSystemIdentifier = d.SystemIdentifier and p.ProcessTypeId = 8 and p.Deleted = 0 order by p.UpdatedOn DESC) as DigitalObjectAcceptanceDate,
			(select f.NumberNumeric FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as FundIntNumber,
			(select i.NumberNumeric FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as InventoryIntNumber,
			(select ae.NumberNumeric FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder,
			(select COUNT(*) from DigitalObjects as do where d.SystemIdentifier = do.DocumentSystemIdentifier and do.Deleted = 0 and do.IsDigitized = 1 and TypeCode = 1) as MastersCount,
			1 as AllDOCount
		FROM Documents as d
		INNER JOIN Archives a ON a.Id = d.ArchiveId AND a.Deleted = 0
		LEFT JOIN v_DocumentSizeInfo dsi ON dsi.DocumentSystemIdentifier = d.SystemIdentifier AND dsi.IsDraft = 0
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
			  AND exists(select 1 from DigitalObjects do where d.SystemIdentifier = do.DocumentSystemIdentifier and do.Deleted = 0 and do.IsDigitized =1)
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
			  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))) '
		

		IF (@RegisteredFrom IS NOT NULL)
		BEGIN
			SET @localQuery += 'AND cast(d.CreatedOn as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
		END

		IF(@RegisteredTo IS NOT NULL)
		BEGIN
			SET @localQuery +='AND cast(d.CreatedOn as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
		END

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
				ArchiveSortOrder int null,
				MastersCount int NULL,
				AllDOCount int NULL
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

CREATE OR ALTER PROCEDURE [dbo].[GetRegisterOfDigitalObjectsPublicReportSummary] 
	@LinkedServer nvarchar(50),
    @ResultType int = 3, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@DigitalObjectStatuses VARCHAR(MAX) = NULL,
	@ArchiveCodes nvarchar(10) = null,
	@RegisteredFrom datetime2(7) = NULL,
	@RegisteredTo datetime2(7) = null,
	@DocLGid int = null,
	@SystemIdentifier nvarchar(50) = null	
AS

BEGIN
  -- Екипът реши да се взима Duration от Document, а не от DocumentObject, където няма такава колона
	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
	DECLARE @remoteQuery VARCHAR(MAX) = 
		'SELECT
			1 as TotalRows,
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
					ISNULL(doc.HasDigitalObject, 0) = 1 '

	IF (@DocLGId IS NOT NULL)
	BEGIN
		SET @remoteQuery += 'AND doc.LGid = ' + cast(@DocLGid as nvarchar(50)) + ' '
	END

	IF (@RegisteredFrom IS NOT NULL)
	BEGIN
		SET @remoteQuery += 'AND cast(doc.DOCreationDate as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
	END

	IF(@RegisteredTo IS NOT NULL)
	BEGIN
		SET @remoteQuery +='AND cast(doc.DOCreationDate as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
	END				
	
	SET @remoteQuery += '
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
				CAST(ISNULL(SUM(TotalImageCount), 0) AS BIGINT)  TotalImageCount
			from
			(
				SELECT
					1 AS DOsPerDocument,
					MAX(do.FileSize) AS BytesCountPerDocument,
					MAX(d.Duration) AS DurationPerDocument,
					COUNT(case when do.TypeCode = 1 then do.SystemIdentifier end) AS TotalImageCount
				FROM DigitalObjects do
				INNER JOIN Archives a ON a.Id = do.ArchiveId AND a.Deleted = 0
				INNER JOIN Documents d ON d.SystemIdentifier = do.DocumentSystemIdentifier AND do.Deleted = 0 AND do.IsDigitized = 1
				WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
						AND (''' + COALESCE(@SystemIdentifier, 'null') + ''' = ''null'' OR CAST(do.SystemIdentifier AS nvarchar(50)) = ''' + COALESCE(@SystemIdentifier, 'null') + ''')
						--AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
						--AND do.TypeCode = 1 -- master
						AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
							OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
						AND (''' + @DigitalObjectStatuses + ''' = ''-999'' 
							OR do.Deleted = 0 AND 1 IN (SELECT element FROM dbo.SplitString(''' + @DigitalObjectStatuses + ''', '',''))
							OR do.Deleted = 1 AND 2 IN (SELECT element FROM dbo.SplitString(''' + @DigitalObjectStatuses + ''', '','')))
						AND (select convert(varchar(4), Code, 104) from N.Status s where s.Code = do.StatusCode) <> ''12'' '

		IF (@RegisteredFrom IS NOT NULL)
		BEGIN
			SET @localQuery += 'AND cast(do.CreatedOn as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
		END

		IF(@RegisteredTo IS NOT NULL)
		BEGIN
			SET @localQuery +='AND cast(do.CreatedOn as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
		END

		SET @localQuery += '
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
-- END Справка "Регистър на цифровизирани документи" вече брои правилно "дигитални обекти"


-- Справка "Контрол по качеството" към "Извършена работа по дигитални обекти" - добавени са всички стъпки за връщане към филтъра за Върнати обекти
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetQualityControlReport]
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveCodes nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
	@Employee nvarchar(max) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	DECLARE @condition VARCHAR(MAX) = '
			 AND ((''-999'' in (select element from dbo.SplitString(''' + @Employee  + ''', '',''))) 
				OR (convert(varchar(36), pt.CreatedBy, 104) in (select element from dbo.SplitString(''' + @Employee + ''', '',''))))
			 AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '',''))) 
				OR (convert(varchar(4), do.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			 AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			 AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(pt.CreatedOn as date) >= CONVERT(nvarchar(50),''' + COALESCE(@DateFrom, 'null') + ''', 23)))
			 AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(pt.CreatedOn as date) <= CONVERT(nvarchar(50),''' + COALESCE(@DateTo, 'null') + ''', 23)))
	'

	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT 
		 a.Name as Archive
		,up.DisplayName as Employer
		,SUM(AcceptedDocuments) + SUM(ReturnedDocuments) as CheckedDocuments
		,SUM(AcceptedDo) + SUM(ReturnedDo) as CheckedDo
		,SUM(AcceptedDocuments) as AcceptedDocuments
		,SUM(AcceptedDo) as AcceptedDo
		,SUM(ReturnedDocuments) as ReturnedDocuments
		,SUM(ReturnedDo) as ReturnedDo
     FROM
   (SELECT 
        ISNULL(Returned.ArchiveId, Accepted.ArchiveId) as ArchiveId
	   ,ISNULL(Returned.UserId, Accepted.UserId) as UserId
	   ,ISNULL(COUNT(Accepted.DocumentSystemIdentifier), 0) as AcceptedDocuments
	   ,SUM(ISNULL(Accepted.DoCount, 0)) as AcceptedDo
	   ,ISNULL(COUNT(Returned.DocumentSystemIdentifier), 0) as ReturnedDocuments
	   ,SUM(ISNULL(Returned.DoCount, 0)) as ReturnedDo
	  FROM 
			(SELECT 
	    		 d.SystemIdentifier as DocumentSystemIdentifier
	    		,d.ArchiveId as ArchiveId
	    		,COUNT(do.SystemIdentifier) as DoCount
				,pt.CreatedBy as UserId
	    	   FROM Documents as d
	      LEFT JOIN DigitalObjects as do
	             ON d.SystemIdentifier = do.DocumentSystemIdentifier
			   JOIN Process as p
	    	     ON p.DocumentSystemIdentifier = d.SystemIdentifier
	    	   JOIN ProcessTimeline as pt
	    	     ON p.Id = pt.ProcessId
			   JOIN Archives as a
			     ON a.Id = d.ArchiveId
	    	  WHERE pt.StepTypeId IN (5, 11, 22, 27, 28, 31, 17, 125, 132, 180, 202, 225, 236, 237, 238, 244, 245, 246)
	    	    AND pt.Completed = 1
	       	    AND p.Completed = 0
				' + @condition + '
	       GROUP BY d.SystemIdentifier, d.ArchiveId, pt.CreatedBy) as Returned
 FULL JOIN
			(SELECT 
	    		 d.SystemIdentifier as DocumentSystemIdentifier
	    		,d.ArchiveId as ArchiveId
	    		,COUNT(do.SystemIdentifier) as DoCount
				,pt.CreatedBy as UserId
	    	   FROM Documents as d
	      LEFT JOIN DigitalObjects as do
	             ON d.SystemIdentifier = do.DocumentSystemIdentifier
			   JOIN Process as p
	    	     ON p.DocumentSystemIdentifier = d.SystemIdentifier
	    	   JOIN ProcessTimeline as pt
	    	     ON p.Id = pt.ProcessId
			   JOIN Archives as a
			     ON a.Id = d.ArchiveId
	    	  WHERE pt.StepTypeId IN (56, 57, 58)
		        AND pt.Completed = 1
				' + @condition + '
	       GROUP BY d.SystemIdentifier, d.ArchiveId, pt.CreatedBy) as Accepted
	   ON Returned.documentSystemIdentifier = Accepted.documentSystemIdentifier
 GROUP BY ISNULL(Returned.ArchiveId, Accepted.ArchiveId), ISNULL(Returned.DocumentSystemIdentifier, Accepted.DocumentSystemIdentifier), ISNULL(Returned.DoCount, Accepted.DoCount), ISNULL(Returned.UserId, Accepted.UserId)) as Final
     JOIN Archives as a
	   ON a.Id = Final.ArchiveId
	 JOIN AspNetUsers as u
	   ON Final.UserId = u.Id
LEFT JOIN AspNetUserProfiles as up
	   ON u.Id = up.UserId
 GROUP BY a.Name, up.DisplayName
 ORDER BY Archive, Employer'
	END

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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetQualityControlCombined]
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveCodes nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
	@Employee nvarchar(max) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @minDate nvarchar(100) = '1753-01-01 00:00:00.000'
    DECLARE @maxDate nvarchar(100) = '9999-12-31 23:59:59.997'

	CREATE TABLE #temp (
		Archive nvarchar(255) NULL,
		Employer nvarchar(256) NULL,
		CheckedDocuments int NULL,
		CheckedDo int NULL,
		AcceptedDocuments int NULL,
		AcceptedDo int NULL,
		ReturnedDocuments int NULL,
		ReturnedDo int NULL
	)

	INSERT INTO #temp (
		Archive,
		Employer,
		CheckedDocuments,
		CheckedDo,
		AcceptedDocuments,
		AcceptedDo,
		ReturnedDocuments,
		ReturnedDo
	)
	EXEC [sp_GetQualityControlReport]
	@RowsOfPage,
	@Page,
	@ArchiveCodes,
	@Statuses,
	@Employee,
	@DateFrom,
	@DateTo

	CREATE TABLE #temp2 (
		PeriodFrom datetime2(7) NULL,
		PeriodTo datetime2(7) NULL
	)

	INSERT INTO #temp2 (
		PeriodFrom,
		PeriodTo
	)
		SELECT 
		 (CASE WHEN MIN(ISNULL(MinAcceptDate, @maxDate)) < MIN(ISNULL(MinReturnedDate, @maxDate))
			   THEN MIN(ISNULL(MinAcceptDate, @maxDate )) ELSE MIN(ISNULL(MinReturnedDate, @maxDate)) END) as PeriodFrom
		,(CASE WHEN MAX(ISNULL(MaxAcceptDate, @minDate)) > MAX(ISNULL(MaxReturnedDate, @minDate))
			   THEN MAX(ISNULL(MaxAcceptDate, @minDate)) ELSE MAX(ISNULL(MaxReturnedDate, @minDate)) END) as PeriodTo
     FROM
   (SELECT
		MIN(Accepted.CreatedOn) as MinAcceptDate
	   ,MAX(Accepted.CreatedOn) as MaxAcceptDate
	   ,MIN(Returned.CreatedOn) as MinReturnedDate
	   ,MAX(Returned.CreatedOn) as MaxReturnedDate
	  FROM 
			(SELECT 
	    		 d.SystemIdentifier as DocumentSystemIdentifier
	    		,d.ArchiveId as ArchiveId
	    		,COUNT(do.SystemIdentifier) as DoCount
				,pt.CreatedBy as UserId
				,pt.CreatedOn as CreatedOn
	    	   FROM Documents as d
	      LEFT JOIN DigitalObjects as do
	             ON d.SystemIdentifier = do.DocumentSystemIdentifier
			   JOIN Process as p
	    	     ON p.DocumentSystemIdentifier = d.SystemIdentifier
	    	   JOIN ProcessTimeline as pt
	    	     ON p.Id = pt.ProcessId
			   JOIN Archives as a
			     ON a.Id = d.ArchiveId
	    	  WHERE pt.StepTypeId IN (5, 11, 22, 27, 28, 31, 17, 125, 132, 180, 202, 225, 236, 237, 238, 244, 245, 246)
	    	    AND pt.Completed = 1
	       	    AND p.Completed = 0
				
				AND (('-999' in (select element from dbo.SplitString(@Employee, ','))) 
					OR (convert(varchar(36), pt.CreatedBy, 104) in (select element from dbo.SplitString( @Employee, ','))))
			    AND (('-999' in (select element from dbo.SplitString(@Statuses, ','))) 
					OR (convert(varchar(4), do.StatusCode, 104) in (select element from dbo.SplitString(@Statuses, ','))))
			    AND (('-999' in (select element from dbo.SplitString(@ArchiveCodes, ','))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(@ArchiveCodes, ','))))
			    AND ((COALESCE(@DateFrom, null) IS NULL) 
					OR (pt.CreatedOn >= cast(@DateFrom as datetime2)))
			    AND ((COALESCE(@DateTo, null) IS NULL) 
					OR (pt.CreatedOn <= cast(@DateTo as datetime2)))

	       GROUP BY d.SystemIdentifier, d.ArchiveId, pt.CreatedBy, pt.CreatedOn) as Returned
 FULL JOIN
			(SELECT 
	    		 d.SystemIdentifier as DocumentSystemIdentifier
	    		,d.ArchiveId as ArchiveId
	    		,COUNT(do.SystemIdentifier) as DoCount
				,pt.CreatedBy as UserId
				,pt.CreatedOn as CreatedOn
	    	   FROM Documents as d
	      LEFT JOIN DigitalObjects as do
	             ON d.SystemIdentifier = do.DocumentSystemIdentifier
			   JOIN Process as p
	    	     ON p.DocumentSystemIdentifier = d.SystemIdentifier
	    	   JOIN ProcessTimeline as pt
	    	     ON p.Id = pt.ProcessId
			   JOIN Archives as a
			     ON a.Id = d.ArchiveId
	    	  WHERE pt.StepTypeId IN (56, 57, 58)
		        AND pt.Completed = 1
				
				AND (('-999' in (select element from dbo.SplitString(@Employee, ','))) 
					OR (convert(varchar(36), pt.CreatedBy, 104) in (select element from dbo.SplitString( @Employee, ','))))
			    AND (('-999' in (select element from dbo.SplitString(@Statuses, ','))) 
					OR (convert(varchar(4), do.StatusCode, 104) in (select element from dbo.SplitString(@Statuses, ','))))
			    AND (('-999' in (select element from dbo.SplitString(@ArchiveCodes, ','))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(@ArchiveCodes, ','))))
			    AND ((COALESCE(@DateFrom, null) IS NULL) 
					OR (pt.CreatedOn >= cast(@DateFrom as datetime2)))
			    AND ((COALESCE(@DateTo, null) IS NULL) 
					OR (pt.CreatedOn <= cast(@DateTo as datetime2)))
				
	       GROUP BY d.SystemIdentifier, d.ArchiveId, pt.CreatedBy, pt.CreatedOn) as Accepted
	   ON Returned.documentSystemIdentifier = Accepted.documentSystemIdentifier
 GROUP BY ISNULL(Returned.DocumentSystemIdentifier, Accepted.DocumentSystemIdentifier), ISNULL(Returned.DoCount, Accepted.DoCount), Accepted.CreatedOn, Returned.CreatedOn) as Final


 
	DECLARE @sql NVARCHAR(MAX) = '
		SELECT
			 (SELECT PeriodFrom FROM #temp2) as PeriodFrom
			,(SELECT PeriodTo FROM #temp2) as PeriodTo
			,SUM(AcceptedDocuments) + SUM(ReturnedDocuments) as CheckedDocuments
			,SUM(AcceptedDo) + SUM(ReturnedDo) as CheckedDo
			,SUM(AcceptedDocuments) as AcceptedDocuments
			,SUM(AcceptedDo) as AcceptedDo
			,SUM(ReturnedDocuments) as ReturnedDocuments
			,SUM(ReturnedDo) as ReturnedDo
		  FROM #temp
	'

	--print @sql;
	EXEC (@sql);

END
GO
-- END Справка "Контрол по качеството" към "Извършена работа по дигитални обекти" - добавени са всички стъпки за връщане към филтъра за Върнати обекти


COMMIT 