SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetSpecialRegistrationListReport] 
	@LinkedServer NVARCHAR(50),
	@ArchiveCodes NVARCHAR(10) = null,
	@FundNumber NVARCHAR(50) = null,
	@InventoryNumber NVARCHAR(50) = null,
	@ArchiveEntityNumber NVARCHAR(50) = null,
	@IsInRisk BIT = null,
	@DescriptionLevel NVARCHAR(50) = null,
	@RowsOfPage INT = 5000,
	@Page INT = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @isInRiskStr NVARCHAR(4) = CONVERT(NVARCHAR(4), @IsInRisk);
	IF @isInRiskStr IS NULL SET @isInRiskStr = N'NULL';

	-- Трябва всеки литерал да се преобразува до NVARCHAR, защото иначе общият стринг бива отрязан на 4000-я символ
	DECLARE @remoteQuery NVARCHAR(MAX) = N'
		SELECT
			doc.Title,
			a.Name as Archive,
			(SELECT n.Value FROM Fund_Modified f 
				INNER JOIN Nomenclature n
				ON n.Gid = f.LevelOfDescriptionGid
				WHERE n._retired = ''3000-01-01'' AND n.Type=''LevelOfDescription'' AND f.LGid = doc.FundLGid 
			) AS DescriptionLevel,
			(SELECT Number FROM Fund_Modified f1 WHERE f1.LGid = doc.FundLGid) AS FundNumber,
			(SELECT Number FROM Inventory_Modified i1 WHERE i1.LGid = doc.InventoryLGid) AS InventoryNumber,
			(SELECT Number FROM ArchiveEntity_Modified ae WHERE ae.LGid = doc.AELGid) AS ArchiveEntityNumber,
			(select sum(isnull(i.ByteLenght, 0)) from Image i where i.DocumentGid = doc.Gid) as Size,
			doc.PaperCount AS PapersCount,
			(ISNULL(CONVERT(NVARCHAR, doc.StartDateDay) + ''.'', '''') + ISNULL(convert(NVARCHAR, doc.StartDateMonth) + ''.'', '''') + isnull(convert(NVARCHAR, doc.StartDateYear), '''')) AS StartDate,
			(ISNULL(CONVERT(NVARCHAR, doc.EndDateDay) + ''.'', '''') + ISNULL(convert(NVARCHAR, doc.EndDateMonth) + ''.'', '''') + isnull(convert(NVARCHAR, doc.EndDateYear), '''')) AS EndDate,
			doc.PhisicalConditionOther as PhysicalCondition,
			doc.IsInRisk,
			(SELECT n.Value FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				INNER JOIN Nomenclature n
				ON n.Gid = ti.LocationGid
				WHERE ti._retired = ''3000-01-01'' AND n._retired = ''3000-01-01'' AND n.Type=''ArchiveLocation'' AND i.LGid = doc.InventoryLGid 
			) AS Location,
			(SELECT ti.BuildingNumber FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				WHERE ti._retired = ''3000-01-01'' AND i.LGid = doc.InventoryLGid 		
			) AS BuildingNumber,
			(SELECT ti.FloorNumber FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				WHERE ti._retired = ''3000-01-01'' AND i.LGid = doc.InventoryLGid 		
			) AS FloorNumber,
			(SELECT ti.PremisesNumber FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				WHERE ti._retired = ''3000-01-01'' AND i.LGid = doc.InventoryLGid 		
			) AS PremisesNumber,
			(SELECT ti.RoomNumber FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				WHERE ti._retired = ''3000-01-01'' AND i.LGid = doc.InventoryLGid 		
			) AS RoomNumber,
			(SELECT ti.StillageNumber FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				WHERE ti._retired = ''3000-01-01'' AND i.LGid = doc.InventoryLGid 		
			) AS StillageNumber,
			(SELECT n.Value FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				INNER JOIN Nomenclature n
				ON n.Gid = ti.StillageSideGid
				WHERE ti._retired = ''3000-01-01'' AND n._retired = ''3000-01-01'' AND n.Type=''StillageSide'' AND i.LGid = doc.InventoryLGid 			
			) AS StillageSide,
			(SELECT ti.RowNumber FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				WHERE ti._retired = ''3000-01-01'' AND i.LGid = doc.InventoryLGid 		
			) AS RowNumber,
			(SELECT ti.CellNumber FROM Inventory_Modified i 
				INNER JOIN TopographicIndex ti
				ON i.TopographicIndexGid = ti.Gid
				WHERE ti._retired = ''3000-01-01'' AND i.LGid = doc.InventoryLGid 		
			) AS CellNumber,
			(SELECT IntNumber FROM Fund_Modified f1 WHERE f1.LGid = doc.FundLGid) AS FundIntNumber,
			(SELECT IntNumber FROM Inventory_Modified i1 WHERE i1.LGid = doc.InventoryLGid) AS InventoryIntNumber,
			(SELECT IntNumber FROM ArchiveEntity_Modified ae WHERE ae.LGid = doc.AELGid) AS ArchiveEntityIntNumber
		FROM Document_Modified AS doc
		INNER JOIN Archive a ON a.Gid = doc.ArchiveGid AND a._retired = ''3000-01-01''
		WHERE
			doc.IsForSpecialRegistration = 1
				AND ((''-999'' IN (SELECT element FROM SplitString(''' + @ArchiveCodes + CONVERT(NVARCHAR(MAX), N''', '',''))) OR a.Code IN (SELECT element FROM dbo.SplitString(') + @ArchiveCodes + CONVERT(NVARCHAR(MAX), N', '','')))
				AND (''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR (SELECT Number FROM Fund_Modified f WHERE f.LGid = doc.FundLGid) = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''')
				AND (''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR (SELECT Number FROM Inventory_Modified i WHERE i.LGid = doc.FundLGid) = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''')
				AND (''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR (SELECT Number FROM ArchiveEntity_Modified ae WHERE ae.LGid = doc.FundLGid) = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX), N''')
				AND (''') + @isInRiskStr + CONVERT(NVARCHAR(MAX), N''' = ''NULL'' OR CONVERT(NVARCHAR(4), doc.IsInRisk) = ') + @isInRiskStr + CONVERT(NVARCHAR(MAX), N')
				AND ((''-999'' IN (SELECT element FROM dbo.SplitString(''') + @DescriptionLevel + CONVERT(NVARCHAR(MAX), N''', '',''))) 
					OR (SELECT f.LevelOfDescriptionGid FROM Fund_Modified f 
						INNER JOIN Nomenclature n on n.Gid=f.LevelOfDescriptionGid
						WHERE f.LGid = doc.FundLGid AND n._retired = ''3000-01-01'') IN (SELECT element FROM dbo.SplitString(''') + @DescriptionLevel + CONVERT(NVARCHAR(MAX), N''', '',''))				
				)
		ORDER BY SortOrder, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchiveEntityIntNumber, ArchiveEntityNumber ASC
		OFFSET ') + CONVERT(NVARCHAR(10), @offset) + CONVERT(NVARCHAR(MAX), N' ROWS FETCH NEXT ') + CONVERT(NVARCHAR(10), @RowsOfPage) + CONVERT(NVARCHAR(MAX), N' ROWS ONLY');

	SET @remoteQuery = REPLACE(@remoteQuery, '''', N'''''');

	-- Тук може и да не е задължително да се ползва openquery, но е ползвано, за да може да се преизползва кода по-лесно там, където е нужен openquery
	DECLARE @sql NVARCHAR(MAX) = N'SELECT * FROM OPENQUERY(' + @LinkedServer + N', ''' + @remoteQuery + N''');';

	EXEC (@sql);
END
GO
