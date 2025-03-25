SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryBookSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1 -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	--,@ArchiveCodes nvarchar(10) = null -- по искане не ИСДА се маха, понеже данните са само от архив ЦДА
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Fund_Modified as fund
			WHERE fund.ArchiveGid = 41
				  AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 9) -- LevelOfDescription=КМФ';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Films 
			INNER JOIN Archives a ON a.Id = ArchiveId 
			WHERE films.ExternalIdentifier IS NULL AND films.HasExternalSource = 0
				AND films.Deleted = 0 
				AND a.Code = 12';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteFundsTable
					UNION
					' +
					@localQuery + ') lf) u';	
	END

	IF @ResultType = 2
	BEGIN
		SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';
	END

	IF @ResultType = 3
	BEGIN
		SET @sql = @localQuery;
	END


	EXEC (@sql);
END
GO