USE [DAA]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesSummary]    Script Date: 6.10.2022 г. 16:01:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesSummary]
	@LinkedServer nvarchar(50), -- Посочване на външната база
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(10) = null

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
    	




	CREATE TABLE #temp (
				KmfNumber nvarchar(255) NULL,			
				InventoryNumber nvarchar(256) NULL,
				StatementDate varchar(50) NULL,
				Employee nvarchar(255) NULL,
				Reader nvarchar(255) NULL,
				AeCount int NULL,
				ElectronicalDocumentsCount int NULL,
				ElectronicalDocumentsMB nvarchar(256) NULL
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
	@RowsOfPage,
	@Page,
	@ArchiveGids,
	@ArchiveCodesInternal

	SET @sql = '
		SELECT COUNT_BIG(*) as TotalRows
		FROM #temp'

	--print @sql;
	EXEC (@sql);

END
