USE [DAA]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetRegisterOfDigitizedDocumentsCombined]    Script Date: 22.3.2023 г. 15:34:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER  PROCEDURE [dbo].[sp_GetRegisterOfDigitizedDocumentsCombined]
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
