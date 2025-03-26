SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.15'
where Code = 'DB_VERSION'

--add script here

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetLibraryCard] 
	@LinkedServer NVARCHAR(50),
	@Number INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX);

	DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT
			ValidFrom,
			ValidTo
		FROM LibraryCards
		WHERE Id = ' + CONVERT(VARCHAR(10), @Number);

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	SET @sql = 'SELECT * FROM OPENQUERY(' + @LinkedServer + ', ''' + @remoteQuery + ''');';

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetQualityControlReport]
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveCodes nvarchar(10) = null,
	@Statuses nvarchar(10) = null,
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

	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT 
			 a.[Name] as Archive
			,SUM(TotalNumberOfReturnedObjects + TotalNumberOfAcceptedObjects) as TotalNumberOfCheckedObjects
			,SUM(TotalNumberOfReturnedRecords + TotalNumberOfAcceptedRecords) as TotalNumberOfCheckedRecords
			,SUM(TotalNumberOfReturnedObjects) as TotalNumberOfReturnedObjects
			,SUM(TotalNumberOfAcceptedObjects) as TotalNumberOfAcceptedObjects
			,SUM(TotalNumberOfReturnedRecords) as TotalNumberOfReturnedRecords
			,SUM(TotalNumberOfAcceptedRecords) as TotalNumberOfAcceptedRecords
		FROM
		(SELECT
			 ISNULL(Returned.ArchiveId, Accepted.ArchiveId) as ArchiveId
			,ISNULL(COUNT(Returned.[Document SystemIdentifier]), 0) as TotalNumberOfReturnedObjects
			,ISNULL(COUNT(Accepted.[Document SystemIdentifier]), 0) as TotalNumberOfAcceptedObjects
			,ISNULL(SUM(Returned.[DOs Count]), 0) as TotalNumberOfReturnedRecords
			,ISNULL(SUM(Accepted.[DOs Count]), 0) as TotalNumberOfAcceptedRecords
			FROM
		(SELECT 
			 d.SystemIdentifier as [Document SystemIdentifier]
			,d.ArchiveId as ArchiveId
			,COUNT(do.SystemIdentifier) as [DOs Count]
		    FROM Documents as d
	   LEFT JOIN DigitalObjects as do
	          ON d.SystemIdentifier = do.DocumentSystemIdentifier
			JOIN Process as p
			  ON p.DocumentSystemIdentifier = d.SystemIdentifier
			JOIN ProcessTimeline as pt
			  ON p.Id = pt.ProcessId
		   WHERE pt.StepTypeId IN (22, 27, 28, 31)
		     AND pt.Completed = 1
			 AND p.Completed = 0
			 AND pt.CreatedBy = '''+ @Employee +'''
			 AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '',''))) 
				OR (convert(varchar(4), do.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			 AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(pt.CreatedOn as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			 AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(pt.CreatedOn as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
		GROUP BY d.SystemIdentifier, d.ArchiveId) as Returned
	   FULL JOIN
		(SELECT 
			 d.SystemIdentifier as [Document SystemIdentifier]
			,d.ArchiveId as ArchiveId
			,COUNT(do.SystemIdentifier) as [DOs Count]
		    FROM Documents as d
	   LEFT JOIN DigitalObjects as do
	          ON d.SystemIdentifier = do.DocumentSystemIdentifier
			JOIN Process as p
			  ON p.DocumentSystemIdentifier = d.SystemIdentifier
			JOIN ProcessTimeline as pt
			  ON p.Id = pt.ProcessId
		   WHERE pt.StepTypeId IN (56, 57, 58)
		     AND pt.Completed = 1
			 AND pt.CreatedBy = '''+ @Employee +'''
			 AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '',''))) 
				OR (convert(varchar(4), do.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			 AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(pt.CreatedOn as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			 AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(pt.CreatedOn as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
		GROUP BY d.SystemIdentifier, d.ArchiveId) as Accepted
			  ON Returned.[Document SystemIdentifier] = Accepted.[Document SystemIdentifier]
		GROUP BY ISNULL(Returned.[Document SystemIdentifier], Accepted.[Document SystemIdentifier]), ISNULL(Returned.ArchiveId, Accepted.ArchiveId)) as Final
		    JOIN Archives as a
			  ON a.Id = Final.ArchiveId
		   WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
		GROUP BY a.[Name]
		ORDER BY a.[Name]'
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetQualityControlSummary]
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveCodes nvarchar(10) = null,
	@Statuses nvarchar(10) = null,
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
    	




	CREATE TABLE #temp (
				Archive nvarchar(255) NULL,
				TotalNumberOfCheckedObjects int NULL,
				TotalNumberOfCheckedRecords int NULL,
				TotalNumberOfReturnedObjects int NULL,
				TotalNumberOfReturnedRecords int NULL,
				TotalNumberOfAcceptedObjects int NULL,
				TotalNumberOfAcceptedRecords int NULL
			);

	INSERT INTO #temp(
				Archive,
				TotalNumberOfCheckedObjects,
				TotalNumberOfCheckedRecords,
				TotalNumberOfReturnedObjects,
				TotalNumberOfReturnedRecords,
				TotalNumberOfAcceptedObjects,
				TotalNumberOfAcceptedRecords
			)
	EXEC [sp_GetQualityControlReport]
	@RowsOfPage,
	@Page,
	@ArchiveCodes,
	@Statuses,
	@Employee,
	@DateFrom,
	@DateTo

	SET @sql = '
		SELECT COUNT_BIG(*) as TotalRows
		FROM #temp'

	--print @sql;
	EXEC (@sql);

END
GO
----------------------------------------------------------
--	THE SCRIPT IS CLOSED - USE THE NEW ONE!
----------------------------------------------------------


commit