SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetSpecialRegistrationListReportSummary] 
	@LinkedServer NVARCHAR(50),
	@ArchiveCodes NVARCHAR(10) = null,
	@FundNumber NVARCHAR(50) = null,
	@InventoryNumber NVARCHAR(50) = null,
	@ArchiveEntityNumber NVARCHAR(50) = null,
	@IsInRisk BIT = null,
	@DescriptionLevel NVARCHAR(50) = null
AS
BEGIN

	DECLARE @isInRiskStr NVARCHAR(4) = CONVERT(NVARCHAR(4), @IsInRisk);
	IF @isInRiskStr IS NULL SET @isInRiskStr = N'NULL';

	declare @remoteQuery NVARCHAR(MAX) = N'
		SELECT
			COUNT_BIG(*) TotalRows
		FROM Document_Modified as doc
		WHERE
			doc.IsForSpecialRegistration = 1
				AND ((''-999'' IN (SELECT element FROM SplitString(''' + @ArchiveCodes + CONVERT(NVARCHAR(MAX), N''', '',''))) OR (SELECT a.Code FROM Archive a WHERE a.Gid=ArchiveGid) IN (SELECT element FROM dbo.SplitString(') + @ArchiveCodes + CONVERT(NVARCHAR(MAX), N', '','')))
				AND (''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR (SELECT Number FROM Fund_Modified f WHERE f.LGid = doc.FundLGid) = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''')
				AND (''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR (SELECT Number FROM Inventory_Modified i WHERE i.LGid = doc.FundLGid) = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''')
				AND (''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR (SELECT Number FROM ArchiveEntity_Modified ae WHERE ae.LGid = doc.FundLGid) = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''')
				AND (''') + @isInRiskStr + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR CONVERT(NVARCHAR(4), doc.IsInRisk) = ') + @isInRiskStr + CONVERT(NVARCHAR(MAX), N')
				AND ((''-999'' IN (SELECT element FROM dbo.SplitString(''') + @DescriptionLevel + CONVERT(NVARCHAR(MAX), N''', '',''))) 
					OR (SELECT f.LevelOfDescriptionGid FROM Fund_Modified f 
						INNER JOIN Nomenclature n on n.Gid=f.LevelOfDescriptionGid
						WHERE f.LGid = doc.FundLGid AND n._retired = ''3000-01-01'') IN (SELECT element FROM dbo.SplitString(''') + @DescriptionLevel + CONVERT(NVARCHAR(MAX), N''', '',''))				
				)');

	SET @remoteQuery = REPLACE(@remoteQuery, '''', N'''''');


	DECLARE @sql NVARCHAR(MAX) = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + ''');';	

	exec (@sql);
END
GO