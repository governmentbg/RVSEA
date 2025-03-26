--SCRIPT CLOSED! USE THE NEXT ONE!

SET XACT_ABORT ON
GO

BEGIN TRANSACTION

update dbo._Version 
set Value = '1.41'
where Code = 'DB_VERSION'
go

update dbo._Version 
set Value = '1.1.34.1'
where Code = 'APP_VERSION'
go

-- Корекция на справка "Контрол по качеството", след премахване на DisplayName колоната от AspNetUsers
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
	    	  WHERE pt.StepTypeId IN (22, 27, 28, 31)
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
-- END Корекция на справка "Контрол по качеството", след премахване на DisplayName колоната от AspNetUsers


-- Корекция на справка "Изготвяне на дигитални обекти", след премахване на DisplayName колоната от AspNetUsers
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetDigitalObjectsPreparationReport]
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
				OR (convert(varchar(36), d.CreatedBy, 104) in (select element from dbo.SplitString(''' + @Employee + ''', '',''))))
			 AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '',''))) 
				OR (convert(varchar(4), do.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			 AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			 AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(d.CreatedOn as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			 AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(d.CreatedOn as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
	'

	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT 
		 a.Name as Archive
		,up.DisplayName as Employer
		,SUM(NewDocuments) as NewDocuments
		,SUM(NewDo) as NewDo
		,SUM(RecreatedDocuments) as RecreatedDocuments
		,SUM(RecreatedDo) as RecreatedDo
     FROM
   (SELECT 
        ISNULL(New.ArchiveId, Recreated.ArchiveId) as ArchiveId
	   ,ISNULL(New.UserId, Recreated.UserId) as UserId
	   ,ISNULL(COUNT(New.DocumentSystemIdentifier), 0) as NewDocuments
	   ,SUM(ISNULL(New.DoCount, 0)) as NewDo
	   ,ISNULL(COUNT(Recreated.DocumentSystemIdentifier), 0) as RecreatedDocuments
	   ,SUM(ISNULL(Recreated.DoCount, 0)) as RecreatedDo
	  FROM 
			(SELECT 
	    		 d.SystemIdentifier as DocumentSystemIdentifier
				,d.ArchiveId as ArchiveId
				,COUNT(do.SystemIdentifier) as DoCount
				,d.CreatedBy as UserId
			  FROM Documents as d
	     LEFT JOIN DigitalObjects as do
	            ON d.SystemIdentifier = do.DocumentSystemIdentifier
			  JOIN Archives as a
			    ON a.Id = d.ArchiveId
		     WHERE d.StatusCode = 1
			 ' + @condition + '
		  GROUP BY d.SystemIdentifier, d.ArchiveId, d.CreatedBy) as New
 FULL JOIN
			(SELECT 
	    		  d.SystemIdentifier as DocumentSystemIdentifier
				 ,d.ArchiveId as ArchiveId
			     ,COUNT(do.SystemIdentifier) as DoCount
				 ,d.CreatedBy as UserId
		       FROM Documents as d
	      LEFT JOIN DigitalObjects as do
	             ON d.SystemIdentifier = do.DocumentSystemIdentifier
			   JOIN Archives as a
			     ON a.Id = d.ArchiveId
		      WHERE d.StatusCode = 9
			  ' + @condition + '
		   GROUP BY d.SystemIdentifier, d.ArchiveId, d.CreatedBy) as Recreated
	   ON New.documentSystemIdentifier = Recreated.documentSystemIdentifier
 GROUP BY ISNULL(New.ArchiveId, Recreated.ArchiveId), ISNULL(New.UserId, Recreated.UserId)) as Final
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
-- END Корекция на справка "Изготвяне на дигитални обекти", след премахване на DisplayName колоната от AspNetUsers

-- Корекция на справка "Използване на цифровизирани документи", след премахване на UserProfileType колоната от AspNetUsers

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
		JOIN AspNetUserProfiles up
		ON u.Id = up.UserId
		WHERE r.DocumentSystemIdentifier = d.SystemIdentifier
		AND up.ProfileType = ''EMP''
		' + @dateCondition + ') as EmpCount,

	   (SELECT COUNT(*)
		FROM DigitalObjectReviews r
		JOIN AspNetUsers as u
		ON r.UserSystemIdentifier = u.Id
		JOIN AspNetUserProfiles up
		ON u.Id = up.UserId
		WHERE r.DocumentSystemIdentifier = d.SystemIdentifier
		AND up.ProfileType = ''CDH''
		' + @dateCondition + ') as CdhCount,

	   (SELECT COUNT(*)
		FROM DigitalObjectReviews r
		JOIN AspNetUsers as u
		ON r.UserSystemIdentifier = u.Id
		JOIN AspNetUserProfiles up
		ON u.Id = up.UserId
		WHERE r.DocumentSystemIdentifier = d.SystemIdentifier
		AND up.ProfileType <> ''EMP''
		AND up.ProfileType <> ''CDH''
		' + @dateCondition + ') as OtherCount

		FROM DigitalObjectReviews as dor
		' + @condition + '
		GROUP BY d.SystemIdentifier, a.[Name], d.Title
		ORDER BY ArchiveName
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY';

	EXEC (@sql);
END
GO
-- END Корекция на справка "Използване на цифровизирани документи", след премахване на UserProfileType колоната от AspNetUsers

-- При експорт поле Времетраене не е в часови формат
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE OR ALTER PROCEDURE [dbo].[GetRegisterOfDigitalObjectsPublicReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@DigitalObjectStatuses VARCHAR(MAX) = NULL,
	@ArchiveCodes nvarchar(10) = null,
	@RegisteredFrom datetime2(7) = NULL,
	@RegisteredTo datetime2(7) = null,
	@DocLGid int = null,
	@SystemIdentifier nvarchar(50) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
	
AS
BEGIN
SET NOCOUNT ON;
	-- Екипът реши да се взима Duration от Document, а не от DocumentObject, където няма такава колона

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by ArchiveSortOrder, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchivalEntityIntNumber, ArchiveEntityNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
	DECLARE @remoteQuery VARCHAR(MAX) = 
		'SELECT
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = (SELECT LevelOfDescriptionGid from Fund_Modified f where f.LGid = doc.FundLGid)) as LevelOfDescription,
			--''http://212.122.187.196:84/Process.aspx?type=Document&agid='' + cast(doc.ArchiveGid as nvarchar(255)) + ''&flgid='' + cast(doc.FundLGid as nvarchar(255)) + ''&ilgid='' + cast(doc.InventoryLGid as nvarchar(255)) + ''&aelgid='' + cast(doc.AELGid as nvarchar(255)) + ''&dlgid=''+ cast(doc.LGid as nvarchar(255)) as DocumentLink,
			a.Name as ArchiveName,
			(select CAST(Code as nvarchar(10)) from archive where _retired = ''3000-01-01'' and Gid = doc.ArchiveGid) ArchiveCode,
			CAST(doc.LGid AS nvarchar(50)) as SystemId,
			CAST(1 AS BIT) as HasExternalSource,
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
			null as Duration,
			--case when isnull(DigitalObjectDeleted, 0) = 0 then ''Активен'' else ''Заличен'' end as DigitalObjectStatus, -- отпада по искане на ДАА
			--(
				--select convert(varchar, max(p.ModifiedOn), 104)  
				--from Document d
				--inner join Process p on p._retired = ''3000-01-01'' and p.Gid = d.ProcessGid and p.TypeGid = 2124 and p.StepGid = 75
				--where  d.LGid = doc.lgid
			--) as ModifiedOn,  -- отпада по искане на ДАА
			(SELECT TOP 1 IntNumber from Fund_Modified f where f.LGid = doc.FundLGid) as FundIntNumber,
			(SELECT IntNumber from Inventory_Modified i where i.LGid = doc.InventoryLGid) as InventoryIntNumber,
			(SELECT IntNumber from ArchiveEntity_Modified ae where ae.LGid = doc.AELGid) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder
		FROM
			Document_Active doc -- в ИСДА ползват Document_Active за тази справка
			INNER JOIN Archive a ON a.Gid = doc.ArchiveGid AND a._retired = ''3000-01-01''
			LEFT OUTER JOIN [Image] img ON doc.Gid = img.DocumentGid AND img._retired = ''3000-01-01''
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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
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
		a.Name,
		a.SortOrder';
   
	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			--(SELECT Text FROM [N].[DocumentDescriptionLevel] dl where dl.Code = DescriptionLevelCode) as LevelOfDescription,
			(SELECT Text FROM [N].[FundDescriptionLevel] fdl where fdl.Code = (SELECT DescriptionLevelCode FROM Funds f where f.SystemIdentifier = do.FundSystemIdentifier)) as LevelOfDescription,
			--'''' as DocumentLink,
			a.Name as ArchiveName,
			a.Code as ArchiveCode,
			CAST(d.SystemIdentifier AS nvarchar(50)) as SystemId,
			CAST(0 AS BIT) as HasExternalSource,
			(SELECT Number FROM Funds f where f.SystemIdentifier = do.FundSystemIdentifier) as FundNumber,
			(SELECT Number FROM Inventories i where i.SystemIdentifier = do.InventorySystemIdentifier) as InventoryNumber,
			(SELECT Number FROM ArchivalEntities ae where ae.SystemIdentifier = do.ArchivalEntitySystemIdentifier) as ArchiveEntityNumber,
			(CAST(d.StartSheetNumber AS nvarchar(50)) + '' - '' + CAST(d.EndSheetNumber AS nvarchar(50))) as ListNumbers, -- различава се от ИСДА; има ли нужда от таква стойност в СЕА?
			d.Title as DocumentTitle,
			d.ApproxmateChronologicalScope as ChronologicalScope,
			-- (SELECT Text FROM [N].[Status] s where s.Code = StatusCode) as DocStatus, -- отпада по искане на ДАА
			convert(varchar, do.CreatedOn, 104) as DigitalObjectCreationDate,
			NULL as ImageCount, -- нямаме снимки при нас
			do.FileSize as BytesCount,
			CAST(d.Duration as nvarchar(256)) as Duration,
			-- NULL as DigitalObjectStatus, -- отпада по искане на ДАА
			-- convert(nvarchar,UpdatedOn, 104) as ModifiedOn, -- отпада по искане на ДАА
			(SELECT NumberNumeric FROM Funds f where f.SystemIdentifier = do.FundSystemIdentifier) as FundIntNumber,
			(SELECT NumberNumeric FROM Inventories i where i.SystemIdentifier = do.InventorySystemIdentifier) as InventoryIntNumber,
			(SELECT NumberNumeric FROM ArchivalEntities ae where ae.SystemIdentifier = do.ArchivalEntitySystemIdentifier) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder 
		FROM DigitalObjects do
		INNER JOIN Archives a ON a.Id = do.ArchiveId AND a.Deleted = 0
		INNER JOIN Documents d ON d.SystemIdentifier = do.DocumentSystemIdentifier AND do.Deleted = 0 AND do.IsDigitized = 1 
		INNER JOIN N.Status s ON s.Code = do.StatusCode AND s.Code <> 12
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0
				AND (''' + COALESCE(@SystemIdentifier, 'null') + ''' = ''null'' OR CAST(do.SystemIdentifier AS nvarchar(50)) = ''' + COALESCE(@SystemIdentifier, 'null') + ''')
				--AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
				AND do.TypeCode = 1 -- master
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND (''' + @DigitalObjectStatuses + ''' = ''-999'' 
					OR do.Deleted = 0 AND 1 IN (SELECT element FROM dbo.SplitString(''' + @DigitalObjectStatuses + ''', '',''))
					OR do.Deleted = 1 AND 2 IN (SELECT element FROM dbo.SplitString(''' + @DigitalObjectStatuses + ''', '',''))) '

		IF (@RegisteredFrom IS NOT NULL)
		BEGIN
			SET @localQuery += 'AND cast(do.CreatedOn as date) >= ''' + CONVERT(nvarchar(50), @RegisteredFrom, 23) + ''' '
		END

		IF(@RegisteredTo IS NOT NULL)
		BEGIN
			SET @localQuery +='AND cast(do.CreatedOn as date) <= ''' + CONVERT(nvarchar(50), @RegisteredTo, 23) + ''' '
		END
	END
	--
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1
	BEGIN
		 SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				LevelOfDescription nvarchar(MAX) NULL,
				--DocumentLink nvarchar(MAX) NULL,
				ArchiveName nvarchar(256) NOT NULL,
				ArchiveCode int NOT NULL,
				SystemId nvarchar(50) NOT NULL,
				HasExternalSource BIT NOT NULL,
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
				Duration nvarchar(256) NULL,
				-- DigitalObjectStatus nvarchar(50) NULL, -- отпада по искане на ДАА
				-- ModifiedOn varchar(50) NULL, -- отпада по искане на ДАА
				FundIntNumber int null,
				InventoryIntNumber int null,
				ArchivalEntityIntNumber int null,
				ArchiveSortOrder int null
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
    SET @sql = @localQuery + '
		order by ArchiveSortOrder, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchivalEntityIntNumber, ArchiveEntityNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';
	END

  EXEC (@sql);
END
GO
-- END При експорт поле Времетраене не е в часови формат


-- Корекция на справка "Данни на ниво фонд"(външна), след премахване на DisplayName колоната от AspNetUsers
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
				convert(varchar(50), fund.LGid, 104) as SystemId,
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
				a.SortOrder,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource
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
			convert(varchar(50), f.SystemIdentifier, 104) as SystemId,
			(SELECT DisplayName FROM [AspNetUserProfiles] u where u.UserId = f.CreatedBy) as CreationAuthor,
			convert(nvarchar, f.UpdatedOn, 104) as ModificationDate,
			(SELECT top 1 DisplayName FROM [AspNetUserProfiles] u where u.UserId = f.UpdatedBy) as ModificationAuthor, -- тук слагам top 1, за да не дава грешка, че подзаявката има повече от 1 резултат - не видях причината за тази грешка				
			null as LinearMeters,
			fsi.EnrolledInventoryCount as InventoryCount,
			NULL as BoxesCount,
			NULL as StorageTubesCount,
			fsi.EnrolledArchivalEntityCount as AECount,
			f.OtherMetrics as ExtentOther,
			fsi.EnrolledDocumentCount as EDocumentsCount,
			fsi.EnrolledBytes as Size,
			fsi.FileTypes as FileFormats,
			(select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration,
			f.FundCreatorTitleHistory as FundFormerNameChange,
			f.FundCreatorActivityHistory as FundFormerFunction,
			f.FundCreatorBiographicalHistory as FundFormerHistory,
			f.History as ArchivalHistory,
			f.DocumentsProvider as ImmediateSourceOfAcquisition,
			f.DocumentsDescription as DocumentProperties,
			(select Text + '';''
				from NomenclatureValues nv
				join N.Nomenclatures n1 on 
					nv.EntityType=''fund'' 
					and n1.deleted=0
					and nv.deleted=0
					and nv.NomenclatureCode=''ORIGINALITY'' 
					and nv.EntityId=f.Id
					and n1.Id=nv.ValueId
				FOR XML path(''''), elements) as Originality,
			(select Text + '';''
				from NomenclatureValues nv
				join N.Nomenclatures n1 on 
					nv.EntityType=''fund'' 
					and n1.deleted=0
					and nv.deleted=0
					and nv.NomenclatureCode=''CREATION_METHOD'' 
					and nv.EntityId=f.Id
					and n1.Id=nv.ValueId
				FOR XML path(''''), elements) as CreatingType,
			(select Text + '';''
				from NomenclatureValues nv
				join N.Nomenclatures n1 on 
					nv.EntityType=''fund'' 
					and n1.deleted=0
					and nv.deleted=0
					and nv.NomenclatureCode=''LANGUAGE'' 
					and nv.EntityId=f.Id
					and n1.Id=nv.ValueId
				FOR XML path(''''), elements) as Language,
			f.DocumentsAccessDescription as AccessConditions,
			NULL as FindingAids,
			f.RelatedFunds as RelatedUnits,
			a.Name as Archive,
			f.Number,
			(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
			(select ValueCode + '';''
				from NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.deleted=0
					and nv.NomenclatureCode = ''INDUSTRY_TYPE'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as IndustryIndex,
			(select n1.Text from N.Nomenclatures n1 where f.AcquisitionMethodId = n1.Id) as MethodOfAcquisition,
			f.ApproxmateChronologicalScope as TextDate,
			(isnull(convert(varchar, f.StartDateDay) + ''.'', '''') + isnull(convert(varchar, f.StartDateMonth) + ''.'', '''') + isnull(convert(varchar, f.StartDateYear), '''')) as StartDate,
			(isnull(convert(varchar, f.EndDateDay) + ''.'', '''') + isnull(convert(varchar, f.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, f.EndDateYear), '''')) as EndDate,
			convert(varchar, f.CreatedOn, 104) as CreationDate,
			f.Title,
			f.Notes as Note,
			(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus,
			f.NumberNumeric as IntNumber,
			a.SortOrder,
			f.ExternalIdentifier,
			f.HasExternalSource
		FROM Funds f
		INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
		INNER JOIN N.Status s ON s.Code = f.StatusCode AND s.Code <> 12
		LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier AND fsi.IsDraft = 0
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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
				OR ((select Code from N.Nomenclatures n1 where n1.Id = f.AcquisitionMethodId) in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
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
			SystemId varchar(50) NOT NULL,
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
			SortOrder int null,
			ExternalIdentifier int null,
			HasExternalSource bit
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteFundsTable
		UNION
		' +
		+ @localQuery +
		+ @sqlFinalPart;
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
-- END Корекция на справка "Данни на ниво фонд"(външна), след премахване на DisplayName колоната от AspNetUsers

-- Корекция на справка "Активни процеси", след премахване на DisplayName колоната от AspNetUsers
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetActiveProcessesReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ProcessTypeGids nvarchar(max) = null,
	@ProcessTypeCodesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber NVARCHAR(50) = null,
	@CreatedFrom nvarchar(100) = null,
	@CreatedTo nvarchar(100) = null,
	@UserGids nvarchar(max)= null,
	@UserIdsInternal nvarchar(max)= null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		--GROUP BY p.Id, ps.Id, a.Name, fdl.Text, f.Number, f.Title, pt.Name, p.CreatedOn, up.DisplayName, f.NumberNumeric, a.SortOrder
		order by SortOrder, IntNumber, FundNumber
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				a.Name AS Archive,
				(SELECT Value FROM Nomenclature n5 where n5._retired = ''3000-01-01'' and n5.Gid = fund.LevelOfDescriptionGid ) as DescriptionLevel,
				NULL AS FundId,
				fund.Number AS FundNumber,
				fund.Title AS Title,
				NULL as DocumentId,
				NULL AS DocumentNumber,
				(cast((select Value from Nomenclature where _retired = ''3000-01-01'' and Gid = p.TypeGid) as nvarchar(500)) + '' Стъпка: '' 
					+ CAST((SELECT Value  from Nomenclature where _retired = ''3000-01-01'' and Gid = p.StepGid) AS NVARCHAR(500)))  ProcessName,
				convert(varchar, p.CreatedOn, 104) as ProcessStartDate,
				(SELECT Name FROM [User] where _retired = ''3000-01-01'' and Gid = p.CreatedBy) as Initiator, 
				fund.IntNumber,
				a.SortOrder,
				NULL AS ProcessStepId,
				null as SystemIdentifier,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource,
				''Fund'' AS EntityType
			FROM Process p
			--Няма активна стъпка 1
			INNER JOIN Fund_Modified fund ON fund.ProcessGid = p.Gid
				AND fund.RowStatusGid = 72
				AND (''' + ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')) + 
					 N''' = ''NULL'' OR fund.Number = ''' + 
					ISNULL(@FundNumber, N'NULL') +  N''')
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE p._retired = ''3000-01-01''
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND not exists(select 1 from Document_Search_Modified where ProcessGid = p.Gid)
				AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
				AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR p.TypeGid in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '','')))
				AND p.TypeGid not in (2377, 2126, 2123, 2124, 2125)
				
			UNION ALL
			
			SELECT
				a.Name AS Archive,
				NULL as DescriptionLevel,
				NULL AS FundId,
				NULL AS FundNumber,
				NULL AS Title,
				NULL AS DocumentId,
				NULL AS DocumentNumber,
				(cast((select Value from Nomenclature where _retired = ''3000-01-01'' and Gid = p.TypeGid) as nvarchar(500)) + '' Стъпка: '' 
					+ CAST((SELECT Value  from Nomenclature where _retired = ''3000-01-01'' and Gid = p.StepGid) AS NVARCHAR(500)))  ProcessName,
				convert(varchar, p.CreatedOn, 104) as ProcessStartDate,
				(SELECT Name FROM [User] where _retired = ''3000-01-01'' and Gid = p.CreatedBy) as Initiator, 
				NULL AS IntNumber,
				NULL AS SortOrder,
				NULL AS ProcessStepId,
				NULL as SystemIdentifier,
				NULL as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource,
				NULL AS EntityType
			FROM [Process] p
			INNER JOIN Archive a ON a.Gid = p.[CExportArchiveGid] AND a.Code IN (SELECT Element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')) AND a._retired = ''3000-01-01''
			WHERE p._retired = ''3000-01-01''
				AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1) --Няма активна стъпка 1 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
				AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
				AND p.TypeGid in (SELECT [Gid] FROM Nomenclature WHERE [Type] = ''Process'' AND [_retired] = ''3000-01-01'' 
					AND [Code] IN (25, 26, 34) AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR [Gid] IN (SELECT Element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))))
			
			UNION ALL

			SELECT
				a.Name AS Archive,
				(SELECT Value FROM Nomenclature n5 where n5._retired = ''3000-01-01'' and n5.Gid = fund.LevelOfDescriptionGid ) as DescriptionLevel,
				NULL AS FundId,
				fund.Number AS FundNumber,
				fund.Title AS Title,
				cast(doc.LGid as nvarchar) as DocumentId,
				NULL AS DocumentNumber,
				(cast((select Value from Nomenclature where _retired = ''3000-01-01'' and Gid = p.TypeGid) as nvarchar(500)) + '' Стъпка: '' 
					+ CAST((SELECT Value  from Nomenclature where _retired = ''3000-01-01'' and Gid = p.StepGid) AS NVARCHAR(500)))  ProcessName,
				convert(varchar, p.CreatedOn, 104) as ProcessStartDate,
				(SELECT Name FROM [User] where _retired = ''3000-01-01'' and Gid = p.CreatedBy) as Initiator, 
				fund.IntNumber,
				a.SortOrder,
				NULL AS ProcessStepId,
				null as SystemIdentifier,
				doc.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource,
				''Document'' AS EntityType
			FROM Process p
				inner join Document_Modified doc on doc.ProcessGid = p.Gid
				and doc.RowStatusGid = 72
				inner join Fund_Modified fund on fund.LGid = doc.FundLGid
					AND (''' + ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')) + 
						N''' = ''NULL'' OR fund.Number = ''' + 
						ISNULL(@FundNumber,  N'NULL') + N''')
				INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE p._retired = ''3000-01-01''
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1) --Няма активна стъпка 1
				AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
				AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR p.TypeGid in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '','')))
	';
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	DECLARE @localQueryWhereClause VARCHAR(MAX) = '
		AND p.Completed = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR ((select convert(varchar(4), a.Code, 104)) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND (''' + ISNULL(@FundNumber, N'NULL') + N''' = ''NULL'' OR f.Number = ''' + ISNULL(@FundNumber, N'NULL') +  N''')
			AND ((''-999'' in (select element from dbo.SplitString(''' + @UserIdsInternal  + ''', '',''))) OR CAST(p.CreatedBy AS VARCHAR(50)) in (SELECT Element from dbo.SplitString(''' + @UserIdsInternal + ''', '','')))
			AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeCodesInternal + ''', '',''))) OR pt.Id in (select element from dbo.SplitString(''' + @ProcessTypeCodesInternal + ''', '','')))
	';

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT DISTINCT
				a.Name AS Archive,
				fdl.Text AS DescriptionLevel,
				NULL AS FundId,
				f.Number AS FundNumber,
				f.Title AS Title,
				cast(d.SystemIdentifier as nvarchar(50)) AS DocumentId,
				d.Number AS DocumentNumber,
				(pt.Name + '' Стъпка: '' + ps.Text) AS ProcessName,
				convert(varchar, p.CreatedOn, 104) as ProcessStartDate,
				up.DisplayName AS Initiator,
				f.NumberNumeric as IntNumber,
				a.SortOrder AS SortOrder,
				p.Id AS ProcessId,
				d.SystemIdentifier,
				d.ExternalIdentifier,
				d.HasExternalSource,
				''Document'' AS EntityType
				--,ps.Id AS ProcessStepId
			FROM v_Documents d 
			INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
			INNER JOIN Funds f ON d.FundSystemIdentifier = f.SystemIdentifier
			INNER JOIN Process p ON p.DocumentSystemIdentifier = d.SystemIdentifier AND p.Deleted = 0 AND p.Completed = 0
			INNER JOIN AspNetUsers u ON u.Id = p.CreatedBy AND u.Deleted = 0
			INNER JOIN AspNetUserProfiles up ON u.Id = up.UserId AND u.Deleted = 0
			LEFT JOIN N.ProcessTypes pt ON pt.Id = p.ProcessTypeId
			LEFT JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode
			INNER JOIN ProcessTimeline ptl ON ptl.ProcessId = p.Id AND ptl.completed = 0
			INNER JOIN N.ProcessSteps ps ON ps.Id = ptl.StepTypeId
			WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0'  
				+ @localQueryWhereClause + '

			UNION

			SELECT DISTINCT
				a.Name AS Archive,
				fdl.Text AS DescriptionLevel,
				f.SystemIdentifier AS FundId,
				f.Number AS FundNumber,
				f.Title AS Title,
				NULL AS DocumentId,
				NULL AS DocumentNumber,
				(pt.Name + '' Стъпка: '' + ps.Text) AS ProcessName,
				convert(varchar, p.CreatedOn, 104) as ProcessStartDate,
				up.DisplayName AS Initiator,
				f.NumberNumeric as IntNumber,
				a.SortOrder AS SortOrder,
				p.Id AS ProcessId,
				f.SystemIdentifier,
				f.ExternalIdentifier,
				f.HasExternalSource,
				''Fund'' AS EntityType
				--,ps.Id AS ProcessStepId
			FROM v_Funds f 
			INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
			INNER JOIN Process p ON p.FundSystemIdentifier = f.SystemIdentifier AND p.Deleted = 0 AND p.Completed = 0
			INNER JOIN AspNetUsers u ON u.Id = p.CreatedBy AND u.Deleted = 0
			INNER JOIN AspNetUserProfiles up ON u.Id = up.UserId AND u.Deleted = 0
			LEFT JOIN N.ProcessTypes pt ON pt.Id = p.ProcessTypeId
			LEFT JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode
			INNER JOIN ProcessTimeline ptl ON ptl.ProcessId = p.Id AND ptl.completed = 0
			INNER JOIN N.ProcessSteps ps ON ps.Id = ptl.StepTypeId
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0'
				+ @localQueryWhereClause
			;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				Archive nvarchar(256) NOT NULL,
				DescriptionLevel nvarchar(256) NOT NULL,
				FundId nvarchar(50) NULL,
				FundNumber nvarchar(256) NULL,
				Title nvarchar(MAX) NULL,
				DocumentId nvarchar(50) NULL,
				DocumentNumber nvarchar(256) NULL,
				ProcessName nvarchar(MAX) NULL,
				ProcessStartDate varchar(50) NULL,
				Initiator nvarchar(256) NULL,
				IntNumber int null,
				SortOrder int null,
				ProcessId INT NULL,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit,
				EntityType nvarchar(50) NULL
				--,ProcessStepId INT NULL
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

	--print @sql
	EXEC (@sql);
END
GO
-- END Корекция на справка "Активни процеси", след премахване на DisplayName колоната от AspNetUsers

-- Корекция на справка "Данни от ниво фонд"(вътрешна), след премахване на DisplayName колоната от AspNetUsers
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
				convert(varchar(50), fund.LGid, 104) as SystemId,
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
				a.SortOrder,
				null as SystemIdentifier,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource
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
			convert(varchar(50), f.SystemIdentifier, 104) as SystemId,
			(SELECT DisplayName FROM [AspNetUserProfiles] u where u.UserId = f.CreatedBy) as CreationAuthor,
			convert(nvarchar, f.UpdatedOn, 104) as ModificationDate,
			(SELECT top 1 DisplayName FROM [AspNetUserProfiles] u where u.UserId = f.UpdatedBy) as ModificationAuthor, -- тук слагам top 1, за да не дава грешка, че подзаявката има повече от 1 резултат - не видях причината за тази грешка				
			null as LinearMeters,
			fsi.EnrolledInventoryCount as InventoryCount,
			NULL as BoxesCount,
			NULL as StorageTubesCount,
			fsi.EnrolledArchivalEntityCount as AECount,
			f.OtherMetrics as ExtentOther,
			fsi.EnrolledDocumentCount as EDocumentsCount,
			fsi.EnrolledBytes as Size,
			fsi.FileTypes as FileFormats,
			(select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Duration,
			f.FundCreatorTitleHistory as FundFormerNameChange,
			f.FundCreatorActivityHistory as FundFormerFunction,
			f.FundCreatorBiographicalHistory as FundFormerHistory,
			f.History as ArchivalHistory,
			f.DocumentsProvider as ImmediateSourceOfAcquisition,
			f.DocumentsDescription as DocumentProperties,
			(select Text + '';''
				from NomenclatureValues nv
				join N.Nomenclatures n1 on 
					nv.EntityType=''fund'' 
					and nv.NomenclatureCode=''ORIGINALITY'' 
					and nv.EntityId=f.Id
					and n1.Id=nv.ValueId
				FOR XML path(''''), elements) as Originality,
			(select Text + '';''
				from NomenclatureValues nv
				join N.Nomenclatures n1 on 
					nv.EntityType=''fund'' 
					and nv.NomenclatureCode=''CREATION_METHOD'' 
					and nv.EntityId=f.Id
					and n1.Id=nv.ValueId
				FOR XML path(''''), elements) as CreatingType,
			(select Text + '';''
				from NomenclatureValues nv
				join N.Nomenclatures n1 on 
					nv.EntityType=''fund'' 
					and nv.NomenclatureCode=''LANGUAGE'' 
					and nv.EntityId=f.Id
					and n1.Id=nv.ValueId
				FOR XML path(''''), elements) as Language,
			f.DocumentsAccessDescription as AccessConditions,
			NULL as FindingAids,
			f.RelatedFunds as RelatedUnits,
			a.Name as Archive,
			f.Number,
			(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
			(select ValueCode + '';''
				from NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''INDUSTRY_TYPE'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as IndustryIndex,
			(select n1.Text from N.Nomenclatures n1 where f.AcquisitionMethodId = n1.Id) as MethodOfAcquisition,
			f.ApproxmateChronologicalScope as TextDate,
			(isnull(convert(varchar, f.StartDateDay) + ''.'', '''') + isnull(convert(varchar, f.StartDateMonth) + ''.'', '''') + isnull(convert(varchar, f.StartDateYear), '''')) as StartDate,
			(isnull(convert(varchar, f.EndDateDay) + ''.'', '''') + isnull(convert(varchar, f.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, f.EndDateYear), '''')) as EndDate,
			convert(varchar, f.CreatedOn, 104) as CreationDate,
			f.Title,
			f.Notes as Note,
			(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus,
			f.NumberNumeric as IntNumber,
			a.SortOrder,
			f.SystemIdentifier,
			f.ExternalIdentifier,
			f.HasExternalSource
		FROM Funds f
		INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
		INNER JOIN N.Status s ON s.Code = f.StatusCode
		LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier AND fsi.IsDraft = 0
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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
				OR ((select Code from N.Nomenclatures n1 where n1.Id = f.AcquisitionMethodId) in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
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
			SystemId varchar(50) NOT NULL,
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
			SortOrder int null,
			SystemIdentifier nvarchar(256) null,
			ExternalIdentifier int null,
			HasExternalSource bit
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
-- END Корекция на справка "Данни от ниво фонд"(вътрешна), след премахване на DisplayName колоната от AspNetUsers


-- Преработка на метод н авзимане на служебен идентификатор в справка "Работен списък за приоритетно реставриране"
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER  PROCEDURE [dbo].[GetWorkListForPriorityRestorationReport] 
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
		order by SortOrder, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchivalEntityIntNumber, ArchiveEntityNumber
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	--PhysicalCondition дава грешка за някои заявки към ИСДА
	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				a.Name as Archive,
				(SELECT fund.Number FROM Fund_Modified as fund WHERE fund.LGid = doc.FundLGid) as FundNumber,
				(SELECT inventory.Number FROM Inventory_Modified as inventory WHERE inventory.LGid = doc.InventoryLGid) as InventoryNumber,
				(SELECT ae.Number FROM ArchiveEntity_Modified as ae WHERE ae.LGid = doc.AELGid) as ArchiveEntityNumber,
				CAST(doc.LGid as nvarchar(256)) as DocumentSystemId,
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
				(SELECT ae.IntNumber FROM ArchiveEntity_Modified as ae WHERE ae.LGid = doc.AELGid) as ArchivalEntityIntNumber,
				a.SortOrder,
				null as SystemIdentifier,
				doc.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource
			FROM Document_Modified as doc
			INNER JOIN Archive a ON a.Gid = doc.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))'

			SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				a.Name as Archive,	
				(SELECT Number FROM Funds f where f.SystemIdentifier = doc.FundSystemIdentifier) as FundNumber,
				(SELECT Number FROM Inventories i where i.SystemIdentifier = doc.InventorySystemIdentifier) as InventoryNumber,
				(SELECT Number FROM ArchivalEntities ae where ae.SystemIdentifier = doc.ArchivalEntitySystemIdentifier) as ArchiveEntityNumber,
				CAST(doc.SystemIdentifier as nvarchar(256)) as DocumentSystemId,
				doc.SheetCount as PaperCount,
				NULL as PhysicalCondition,
				doc.DigitizedCopyCount as CopyDigital,
				doc.MicrofilmedCopyCount as CopyMicrofilm,
				(SELECT NumberNumeric FROM Funds f where f.SystemIdentifier =doc. FundSystemIdentifier) as FundIntNumber,
				(SELECT NumberNumeric FROM Inventories i where i.SystemIdentifier = doc.InventorySystemIdentifier) as InventoryIntNumber,
				(SELECT NumberNumeric FROM ArchivalEntities ae where ae.SystemIdentifier = doc.ArchivalEntitySystemIdentifier) as ArchivalEntityIntNumber,
				a.SortOrder,
				doc.SystemIdentifier,
				doc.ExternalIdentifier,
				doc.HasExternalSource
			FROM Documents doc
			INNER JOIN Archives a ON a.Id = doc.ArchiveId AND a.Deleted = 0
			WHERE doc.ExternalIdentifier IS NULL AND doc.HasExternalSource = 0 AND doc.Deleted = 0 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				Archive nvarchar(256) NOT NULL,
				FundNumber nvarchar(256) NULL,
				InventoryNumber nvarchar(256) NULL,
				ArchiveEntityNumber nvarchar(256) NULL,
				DocumentSystemId nvarchar(256) NOT NULL,
				PaperCount int NULL,
				PhysicalCondition nvarchar(MAX) NULL,
				CopyDigital int NULL,
				CopyMicrofilm int NULL,
				FundIntNumber int null,
				InventoryIntNumber int null,
				ArchivalEntityIntNumber int null,
				SortOrder int null,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
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
-- END Преработка на метод н авзимане на служебен идентификатор в справка "Работен списък за приоритетно реставриране"


COMMIT 