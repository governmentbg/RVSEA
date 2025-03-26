SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetInsuranceFundOfCopiesOfForeignArchives] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null
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
				NULL as ElectronicDocumentsSize,
				fund.ExtentOther as Other,
				fund.InsNegativeCount as DoublesNegativeCount,
				(SELECT Value from Nomenclature where _retired =''3000-01-01'' and type = ''FAInsurancePlace'' and Gid = fund.InsNegativePlaceGid) as DoublesNegativeLocation,
				InsPositiveCount as DoublesPositiveCount,
				(SELECT Value from Nomenclature where _retired =''3000-01-01'' and type = ''FAInsurancePlace'' and Gid = fund.InsPositivePlaceGid) as DoublesPositiveLocation,
				fund.InsFotolabDeliveryDate as PhotolabDeliveryDate,
				fund.InsNote,
				fund.IntNumber
			FROM Fund_Modified as fund
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
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
				(select SUM(fpd.FileSizeInBytes) from FilmPackageDocuments as fpd join FilmPackages as fp on fpd.PackageId = fp.Id where fp.Id = PackageBId AND fpd.Deleted = 0 AND fp.Deleted = 0) as ElectronicDocumentsSize,
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
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))'; -- Дали трябва да се добави условие за процес?
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
				ElectronicDocumentsSize bigint NULL,
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
