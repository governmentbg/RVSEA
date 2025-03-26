SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetPartialReceiptsListReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(10) = null
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				COUNT_BIG(*) TotalRows,
				CAST(SUM(isnull(fund.InvetoryCount, 0)) AS BIGINT) TotalInventories,
				CAST(SUM(isnull(fund.AECount, 0)) AS BIGINT) TotalArchiveEntities,
				CAST(ROUND(SUM(fund.LinearMeters), 2) AS DECIMAL(18, 2)) TotalLinearMeters,
				CAST(0 as BIGINT) TotalSize -- по искане на клиента не се отчита
			FROM Fund_Modified AS fund
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)';
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT 
				COUNT_BIG(*) TotalRows,
				CAST(sum(isnull(fsi.EnrolledInventoryCount, 0)) AS BIGINT) TotalInventories,
				CAST(sum(isnull(fsi.EnrolledArchivalEntityCount, 0)) AS BIGINT) TotalArchiveEntities,
				NULL TotalLinearMeters,
				CAST(sum(isnull(fsi.EnrolledBytes, 0)) AS BIGINT) TotalSize
			FROM Funds F
			LEFT JOIN v_FundSizeInfo as fsi ON f.SystemIdentifier = fsi.FundSystemIdentifier AND fsi.IsDraft = 0
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 4
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), a.Code, 104) from Archives a where a.Id = f.ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows BIGINT NULL,
				TotalInventories BIGINT NULL,
				TotalArchiveEntities BIGINT NULL,
				TotalLinearMeters DECIMAL(18, 2) NULL,
				TotalSize BIGINT NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT 
				SUM(u.TotalRows) AS TotalRows,
				SUM(u.TotalInventories) AS TotalInventories, 
				SUM(u.TotalArchiveEntities) AS TotalArchiveEntities, 
				SUM(ISNULL(u.TotalLinearMeters, 0)) TotalLinearMeters,
				SUM(ISNULL(u.TotalSize, 0)) AS TotalSize	
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