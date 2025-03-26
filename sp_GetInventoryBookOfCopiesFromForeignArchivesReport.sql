SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryBookOfCopiesFromForeignArchivesReport]
	@LinkedServer nvarchar(50), -- Посочване на външната база
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000, -- Default брой записи на страница
	@Page int = 1, -- Започва от първа страница
	@ArchiveCodes nvarchar(10) = null	
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
			NULL as ElectronicDocumentsSize,
			fund.CopyOther as Other,
			(select cast(1 as bit) where exists(select 1 from Inventory_Modified i where i.FundLGid=fund.LGid)) as HasInventory,
			fund.InventoryShortDescroption as InventoryShortDescription,
			fund.CreationAuthor,
			fund.IntNumber
		FROM Fund_Modified as fund
		WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
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
			(select SUM(fpd.FileSizeInBytes) from FilmPackageDocuments as fpd join FilmPackages as fp on fpd.PackageId = fp.Id where fp.Id = films.PackageBId AND fpd.Deleted = 0) as ElectronicDocumentsSize,
			films.Other,
			NULL as HasInventory,
			films.Content as InventoryShortDescription,
			films.Source as CreationAuthor,
			films.InventoryNumber as IntNumber
		FROM Films as films
		WHERE --ExternalIdentifier IS NULL AND HasExternalSource = 0 
			Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
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
				ElectronicDocumentsSize nvarchar(256) NULL,
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