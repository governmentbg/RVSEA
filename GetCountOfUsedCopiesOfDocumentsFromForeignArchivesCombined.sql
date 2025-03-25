USE [DAA]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesCombined]    Script Date: 6.10.2022 г. 16:00:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesCombined]
	@LinkedServer nvarchar(50), -- Посочване на външната база
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(10) = null

AS
BEGIN

	SET NOCOUNT ON;

	--DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	--DECLARE @sqlFinalPart VARCHAR(MAX) = '
	--	offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
    	




	CREATE TABLE #temp (
				KmfNumber nvarchar(255) NULL,			
				InventoryNumber nvarchar(256) NULL,
				StatementDate varchar(50) NULL,
				Employee nvarchar(255) NULL,
				Reader nvarchar(255) NULL,
				AeCount int NULL,
				ElectronicalDocumentsCount int NULL,
				ElectronicalDocumentsMB float NULL
			);

	INSERT INTO #temp(
				KmfNumber,			
				InventoryNumber,
				StatementDate,
				Employee,
				Reader,
				AeCount,
				ElectronicalDocumentsCount,
				ElectronicalDocumentsMB
			)
	EXEC [sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesReport]
	@LinkedServer,
	@ResultType,
	2147483647,
	@Page,
	@ArchiveGids,
	@ArchiveCodesInternal

	SET @sql = '
		SELECT TOP 1
		''Служител'' as EmployeeRowName,
		(SELECT COUNT(t.Employee) 
		 FROM #temp as t) as EmployeeKMFCount,
        (SELECT SUM(t.AeCount) 
		 FROM #temp as t
		 WHERE t.Employee IS NOT NULL) as EmployeeAECount,
        (SELECT SUM(t.ElectronicalDocumentsCount) 
		 FROM #temp as t
		 WHERE t.Employee IS NOT NULL) as EmployeeElDocsCount,
         (SELECT SUM(t.ElectronicalDocumentsMB) 
		 FROM #temp as t
		 WHERE t.Employee IS NOT NULL) as EmployeeElDocsMB,

		''Читател'' as ReaderRowName,
        (SELECT COUNT(t.Reader) 
		 FROM #temp as t) as ReaderKMFCount,
        (SELECT SUM(t.AeCount) 
		 FROM #temp as t
		 WHERE t.Reader IS NOT NULL) as ReaderAECount,
        (SELECT SUM(t.ElectronicalDocumentsCount) 
		 FROM #temp as t
		 WHERE t.Reader IS NOT NULL) as ReaderElDocsCount,
        (SELECT SUM(t.ElectronicalDocumentsMB) 
		 FROM #temp as t
		 WHERE t.Reader IS NOT NULL) as ReaderElDocsMB,

		''Общо:'' as TotalRowName,
        (SELECT COUNT(t.KmfNumber)
		 FROM #temp as t) as TotalKMFCount,
        (SELECT SUM(t.AeCount)
		 FROM #temp as t) as TotalAECount,
        (SELECT SUM(t.ElectronicalDocumentsCount)
		 FROM #temp as t) as TotalElDocsCount,
        (SELECT SUM(t.ElectronicalDocumentsMB)
		 FROM #temp as t) as TotalElDocsMB
		FROM #temp as t'

		--SET @sql = '
		--SELECT TOP 1
		--''Служител'' as EmployeeRowName,
		--ISNULL(COUNT(t.KmfNumber), 0) as EmployeeKMFCount,
        --NULL as EmployeeAECount,
        --NULL as EmployeeElDocsCount,
        --NULL as EmployeeElDocsMB
		--FROM #temp as t
		--WHERE t.Employee IS NOT NULL
		--SELECT TOP 1
		--''Читател''  as ReaderRowName,
        --NULL as ReaderKMFCount,
        --NULL as ReaderAECount,
        --NULL as ReaderElDocsCount,
        --NULL as ReaderElDocsMB
		--FROM #temp as t
		--WHERE t.Reader IS NOT NULL
		--SELECT TOP 1
		--''Общо:''  as TotalRowName,
        --NULL as TotalKMFCount,
        --NULL as TotalAECount,
        --NULL as TotalElDocsCount,
        --NULL as TotalElDocsMB
		--FROM #temp as t'

		--NULL as RowName
		--NULL as KmfCount,
        --NULL as AeCount,
        --NULL as ElDocsCount,
        --NULL as ElDocsMB
		--FROM #temp'
	--print @sql;
	EXEC (@sql);

END
