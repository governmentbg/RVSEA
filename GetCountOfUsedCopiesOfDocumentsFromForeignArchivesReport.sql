USE [DAA]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesReport]    Script Date: 6.10.2022 г. 15:59:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCountOfUsedCopiesOfDocumentsFromForeignArchivesReport]
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
		order by KmfNumber asc, InventoryNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN

		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT
			--convert(nvarchar(255), (select n.Value2 from Nomenclature as n where n.Gid = fund.CountryGid)) as KmfNumber,
			NULL as KmfNumber,
			NULL as InventoryNumber,
			NULL as StatementDate,
			NULL as Employee,
			NULL as Reader,
			--COUNT((select ae.Gid 
			--		from ArchiveEntity as ae
			--		inner join RequestEntities as re
			--		on re.ArchiveEntityLGid = ae.LGid
			--		inner join Process as p
			--		on re.ProcessGid = p.Gid
			--		where ae.FundLGid = fund.Gid
			--		and p.TypeGid LIKE 101573 
			--		OR p.TypeGid LIKE 101574)) as AeCount,
			NULL as AeCount,
			NULL as ElectronicalDocumentsCount,
			NULL as ElectronicalDocumentsMB
		FROM Fund_Modified as fund'

		--SELECT
		--	NULL as KmfNumber,
		--	NULL as InventoryNumber,
		--	NULL as StatementDate,
		--	NULL as Employee,
		--	NULL as Reader,
		--	NULL as AeCount,
		--	NULL as ElectronicalDocumentsCount,
		--	NULL as ElectronicalDocumentsMB
		--FROM Fund_Modified as fund'

		--DECLARE @remoteQuery VARCHAR(MAX) = '
		--SELECT
		--	convert(nvarchar(255), (select Value from Nomenclature n where n.Gid = fund.CountryGid)) as KmfNumber,
		--	fund.Number as InventoryNumber,
		--	NULL as StatementDate,
		--	NULL as Employee,
		--	NULL as Reader,
		--	NULL as AeCount,
		--	NULL as ElectronicalDocumentsCount,
		--	NULL as ElectronicalDocumentsMB
		--FROM Fund_Modified as fund
		--JOIN ArchiveEntity as ae
		--ON fund.LGid = ae.FundLGid
		--JOIN RequestEntities as re
		--ON ae.LGid = re.ArchiveEntityLGid
		--JOIN Process as p
		--ON re.ProcessGid = p.Gid
		--WHERE p.TypeGid = 101573 OR p.TypeGid = 101574'
		
		--WHERE ISNULL(d.HasDigitalObject, 0) = 1
		--	  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR d.ArchiveGid in  (select element from dbo.SplitString(''' + @ArchiveGids + ''', '','')))'
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT 
			NULL as KmfNumber,
			NULL as InventoryNumber,
			NULL as StatementDate,
			NULL as Employee,
			NULL as Reader,
			NULL as AeCount,
			NULL as ElectronicalDocumentsCount,
			NULL as ElectronicalDocumentsMB
		FROM Films'
		--WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
		--	  AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
		--	  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
		--	  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))';
	END

		IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				KmfNumber nvarchar(255) NULL,			
				InventoryNumber nvarchar(256) NULL,
				StatementDate varchar(50) NULL,
				Employee nvarchar(255) NULL,
				Reader nvarchar(255) NULL,
				AeCount int NULL,
				ElectronicalDocumentsCount int NULL,
				ElectronicalDocumentsMB float NULL
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

	--print @sql;
	EXEC (@sql);
END
