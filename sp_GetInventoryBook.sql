SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryBook] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1
	-- ,@ArchiveCodes nvarchar(max) = null -- по искане не ИСДА се маха, понеже данните са само от архив ЦДА
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
				fund.Number,		
				coalesce(
					convert(varchar, fund.FARevicedOnDay, 104) + ''.'' + convert(varchar, fund.FARevicedOnMonth, 104) + ''.'' + convert(varchar, fund.FARecivedOnYear, 104), 
					convert(varchar, fund.FARecivedOnYear, 104)) as ReceivedOn,
				(select Value from Nomenclature n where n.Gid = fund.CountryGid) as CountryOfOrigin,
				coalesce(
					convert(varchar(10), fund.CopyNegativeRolls) + ''-'' + convert(varchar(10), fund.CopyNegativeFrames), 
					convert(varchar(10), fund.CopyNegativeRolls) + ''-'', 
					''-'' + convert(varchar(10), fund.CopyNegativeFrames)) as Negatives,
				coalesce(
					convert(varchar(10), fund.CopyPositiveRolls) + ''-'' + convert(varchar(10), fund.CopyPositiveFrames), 
					convert(varchar(10), fund.CopyPositiveRolls) + ''-'', 
					''-'' + convert(varchar(10), fund.CopyPositiveFrames)) as Positives,
				CAST(fund.CopyXerox as nvarchar(250)) as CopyXerox,
				fund.CopyDigital,
				(select cast(1 as bit) where exists(select 1 from Inventory_Modified i where i.FundLGid=fund.LGid)) as HasInventory,
				fund.InventoryShortDescroption as ShortDescription,
				fund.CreationAuthor,
				fund.Note,
				fund.IntNumber,
				null as SystemIdentifier,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource
			FROM Fund_Modified as fund
			WHERE fund.ArchiveGid = 41
				  AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 9) -- LevelOfDescription=КМФ';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				''E'' + convert(varchar(256), films.InventoryNumber) as Number,			
				(isnull(convert(varchar, films.AcceptedOnDay) + ''.'', '''') + isnull(convert(varchar, films.AcceptedOnMonth) + ''.'', '''') + isnull(convert(varchar, films.AcceptedOnYear), '''')) as ReceivedOn,
				(select Text from [N].[Nomenclatures] n where n.Id = films.CountryId) as CountryOfOrigin,
				coalesce(
					convert(varchar(10), films.MicrofilmNegativeRollsCount) + ''-'' + convert(varchar(10), films.MicrofilmNegativeFramesCount), 
					convert(varchar(10), films.MicrofilmNegativeRollsCount) + ''-'', 
					''-'' + convert(varchar(10), films.MicrofilmNegativeFramesCount)) as Negatives,
				coalesce(
					convert(varchar(10), films.MicrofilmPositiveRollsCount) + ''-'' + convert(varchar(10), films.MicrofilmPositiveFramesCount), 
					convert(varchar(10), films.MicrofilmPositiveRollsCount) + ''-'', 
					''-'' + convert(varchar(10), films.MicrofilmPositiveFramesCount)) as Positives,
				convert(varchar(250), films.PhotoCopy) as CopyXerox,
				convert(varchar(250), films.DigitalCopy) as CopyDigital,
				NULL as HasInventory,
				films.Content as ShortDescription,
				films.Source as CreationAuthor,
				films.Notes as Note,
				films.InventoryNumber as IntNumber,
				films.SystemIdentifier,
				films.ExternalIdentifier,
				films.HasExternalSource
			FROM films
			INNER JOIN Archives a ON a.Id = ArchiveId 
			WHERE films.ExternalIdentifier IS NULL AND films.HasExternalSource = 0
				AND films.Deleted = 0 
				AND a.Code = 12';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Number nvarchar(256) NULL,			
				ReceivedOn varchar(50) NULL,
				CountryOfOrigin nvarchar(MAX) NULL,
				Negatives nvarchar(21) NULL,
				Positives nvarchar(21) NULL,
				CopyXerox nvarchar(250) NULL,
				CopyDigital nvarchar(250) NULL,
				-- DigitalImages
				HasInventory bit NULL,
				ShortDescription nvarchar(MAX) NULL,
				CreationAuthor nvarchar(256) NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
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