USE [DAA]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetUserActionsJournalReport]    Script Date: 10.2.2023 г. 8:14:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_GetUserActionsJournalReport]
	@LinkedServer nvarchar(50),
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@EmployeeNames nvarchar(max) = null,
	@ArchiveCodes nvarchar(max) = null,
	@FundNumber nvarchar(10) = null,
	@InventoryNumber nvarchar(10) = null,
	@ArchiveEntityNumber nvarchar(10) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@Process nvarchar(max) = null,
	@KmfNumber nvarchar(10) = null,
	@DescriptionLevel nvarchar(max) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql NVARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by ArchiveName
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	DECLARE @remoteQuery NVARCHAR(max) = CONVERT(NVARCHAR(MAX),'
	SELECT
		   (select a.[Name] from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveName
		  ,(select a.Code from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveCode
		  ,(select n.[Value] from [Archiving].[dbo].Nomenclature as n where n.Gid = fund.LevelOfDescriptionGid) as DescriptionLevel
		  ,ISNULL((
		 		SELECT Title
		 		FROM  Nomenclature n
		 		WHERE n.Gid = fund.CountryGid
		 			AND n._retired=''3000-01-01'' AND n.Type=''FACountry''
		 	), '''') as Kmf
		  ,fund.Number as Fund
		  ,(select top 1 i.IntNumber from Inventory_Modified as i where ae.InventoryLGid = i.LGid) as Inventory
		  ,ae.Number as ArchivalEntity
		  ,ae.LGid as DocumentServiceNumber
		  ,(select u.[Name] from [User] as u where u._id = p.CreatedBy) as Employee
		  ,reh.DateCreated as [Date]
		  ,(select n.[Value] from [Archiving].[dbo].Nomenclature as n where n.Gid = p.TypeGid) as Process
		  ,(select n.[Value] from [Archiving].[dbo].Nomenclature as n where n.Gid = p.StepGid) as Steps
	FROM [Archiving].[dbo].ArchiveEntity_Modified as ae
	JOIN [Archiving].[dbo].RequestEntitiesHistory as reh on ae.LGid = reh.ArchiveEntityLGid
	JOIN [Archiving].[dbo].Process as p on reh.ProcessGid = p.Gid
	JOIN [Archiving].[dbo].Fund_Modified as fund on ae.FundLGid = fund.LGid
   WHERE ((''-999'' in (select element from dbo.SplitString(''') + @ArchiveCodes + CONVERT(VARCHAR(MAX),''', '',''))) 
			OR (select a.Code from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') in (select element from dbo.SplitString(''') + @ArchiveCodes +  CONVERT(VARCHAR(MAX),''', '','')))
		 
		 AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') 
			OR (fund.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')))  + CONVERT(NVARCHAR(MAX),'''))
		 AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') 
			OR ((select i.IntNumber from Inventory_Modified as i where ae.InventoryLGid = i.LGid) = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
		 AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') 
			OR (ae.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ArchiveEntityNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
		 AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@KmfNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(VARCHAR(MAX),''' = ''NULL'') 
			OR ((select Title from  Nomenclature n where n.Gid = fund.CountryGid and n._retired=''3000-01-01'' and n.Type=''FACountry'') = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@KmfNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
		 
		 
		 AND ((''-999'' in (select element from dbo.SplitString(''') + @DescriptionLevel + CONVERT(NVARCHAR(MAX),''', '',''))) 
			OR ((select n.[Value] from [Archiving].[dbo].Nomenclature as n where n.Gid = fund.LevelOfDescriptionGid) in (select element from dbo.SplitString(''') + @DescriptionLevel + CONVERT(NVARCHAR(MAX),''', '',''))))
		 AND ((''-999'' in (select element from dbo.SplitString(''') + @Process + CONVERT(NVARCHAR(MAX),''', '',''))) 
			OR ((select n.[Gid] from [Archiving].[dbo].Nomenclature as n where n.Gid = p.TypeGid) in (select element from dbo.SplitString(''') + @Process + CONVERT(NVARCHAR(MAX),''', '',''))))
		AND ((''-999'' in (select element from dbo.SplitString(''') + @EmployeeNames + CONVERT(NVARCHAR(MAX),''', '',''))) 
			OR ((select u.Gid from [User] as u where u._id = p.CreatedBy) in (select element from dbo.SplitString(''') + @EmployeeNames + CONVERT(NVARCHAR(MAX),''', '',''))))

		 AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
			OR (cast(reh.DateCreated as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
		 AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
			OR (cast(reh.DateCreated as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
			
	');

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	SET @sql = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery + @sqlFinalPart +''');';

	EXEC (@sql);

END
