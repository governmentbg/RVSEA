SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetAccountAndDescriptionOfFilmDocumentsBook] 
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
		order by IntNumber, Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT
				Number,		
				coalesce(
					convert(varchar, FARevicedOnDay, 104) + ''.'' + convert(varchar, FARevicedOnMonth, 104) + ''.'' + convert(varchar, FARecivedOnYear, 104), 
					convert(varchar, FARecivedOnYear, 104)) as ReceivedOn,
				-- Title, null за всички редове 
				CreationAuthor,
				-- оригинал/копие,
				ImmediateSourceOfAcquisition, -- null за всички рдеове 
				(select Value3 from Nomenclature n where n.Gid = CountryGid) as CountryOfOrigin,
				--NULL as DocumentsCharacteristics,
				--InventoryShortDescroption as InventoryShortDescription, съпроводителна текстова документация
				--документ, въз основа на който е приет, 
				coalesce(
					(Number + '' / '' 
						+ (select Number from Inventory_Modified i where i.FundLGid = LGid) + '' / ''
						+ (select top(1) Number from ArchiveEntity_Modified ae where ae.FundLGid = LGid)),
					(Number + '' / '' 
						+ (select Number from Inventory_Modified i where i.FundLGid = LGid) + '' / ''),
					(Number + '' / / '' 
						+ (select top(1) Number from ArchiveEntity_Modified ae where ae.FundLGid = LGid))					
					) as FundNumberAndInventoryAndArchiveEntiry, -- отнесен към фонд №, инвентарен опис, архивна единица  -- този ред гърми гърми за някой ред от данните, затова слагам top(1)!
				--наличие на застрахователно копие/вид носител
				Note,
				IntNumber
			FROM Fund_Modified as fund
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				  AND LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 9) -- LevelOfDescription=КМФ';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				convert(varchar(256), InventoryNumber) as Number,			
				(isnull(convert(varchar, AcceptedOnDay) + ''.'', '''') + isnull(convert(varchar, AcceptedOnMonth) + ''.'', '''') + isnull(convert(varchar, AcceptedOnYear), '''')) as ReceivedOn,
				-- NULL as Title, -- няма го при нас
				NULL as CreationAuthor, -- това не е много ясно
				-- оригинал/копие,
				Source as ImmediateSourceOfAcquisition,
				(select Text from [N].[Nomenclatures] n where n.Id = CountryId) as CountryOfOrigin,
				--DocumentsCharacteristics,
				-- съпроводителна текстова документация,
				-- документ, въз основа на който е приет, 
				NULL as FundNumberAndInventoryAndArchiveEntiry,
				--наличие на застрахователно копие/вид носител,
				Notes as Note,
				InventoryNumber as IntNumber
			FROM Films
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Number nvarchar(256) NULL,			
				ReceivedOn varchar(50) NULL,
				-- Title,
				CreationAuthor nvarchar(256) NULL,
				-- оригинал/копие,
				ImmediateSourceOfAcquisition nvarchar(2000) NULL,
				CountryOfOrigin nvarchar(MAX) NULL,
				-- DocumentsCharacteristics,
				-- съпроводителна текстова документация,
				-- документ, въз основа на който е приет,
				FundNumberAndInventoryAndArchiveEntiry nvarchar(50) NULL,
				--наличие на застрахователно копие/вид носител,
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
