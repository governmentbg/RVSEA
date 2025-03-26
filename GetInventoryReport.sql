SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryReport]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@Archives nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
	@FundNumber nvarchar(10) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@ChronologicalScope nvarchar(100) = null,
	@ChronologicalScopeStartDate nvarchar(100) = null,
	@ChronologicalScopeEndDate nvarchar(100) = null
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql NVARCHAR(MAX);
	DECLARE @sqlFinalPart NVARCHAR(MAX) = '
		order by Archive
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
		DECLARE @remoteQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
			SELECT
				a.Name as Archive,
				(SELECT Value FROM Nomenclature n5 where n5._retired = ''3000-01-01'' and n5.Gid = fund.LevelOfDescriptionGid ) as FundDescriptionLevel,
				fund.Number as FundNumber,
				fund.Title as FundTitle,
				inv.Number as InventoryNumber,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = inv.LevelOfDescriptionGid) as InventoryDescriptionLevel,
				(SELECT Value FROM Nomenclature WHERE _retired = ''3000-01-01'' and Gid = inv.StatusGid) as [Status],
				ISNULL(inv.AECount, 0) as AeCount,
				(SELECT COUNT(*) FROM ArchiveEntity_Modified as ae where InventoryLGid = inv.LGid and ISNUMERIC(RIGHT(ae.Number,1)) = 0) as AeWithCharCount,
				(SELECT COUNT(*) FROM ArchiveEntity_Modified as ae where InventoryLGid = inv.LGid and ISNUMERIC(RIGHT(ae.Number,1)) = 0) as EDocumentsCount,
				--null as EDocumentsCount,
				round(cast(isnull(inv.LinearMeter, 0) as decimal(18, 2)) ,2) as LinearMeters,
				NULL as FileFormat,
				NULL as Duration,
				null as Bytes,
				null as SystemIdentifier,
				inv.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource
				FROM Inventory as inv
				inner join Fund_Modified as fund on inv.FundLGid = fund.LGid
				inner join Archive a on inv.ArchiveGid = a.Gid
			WHERE
				fund._retired = ''3000-01-01'' AND inv.LevelOfDescriptionGid = 2171-- Inventory
				AND inv._retired = ''3000-01-01''
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (fund.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (inv.TextDate = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' = ''null'') OR (cast(inv.StartDate as date) >= cast(''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' = ''null'') OR (cast(inv.EndDate as date) <= cast(''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(inv.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(inv.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
					OR ((SELECT Code FROM Nomenclature where _retired = ''3000-01-01'' and Gid = inv.StatusGid) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives + ''', '',''))) OR (a.Code in (select element from dbo.SplitString(''' + @Archives + ''', '',''))))
		');
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		DECLARE @localQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
			SELECT
				a.[Name] as Archive
				,fdl.[Text] as FundDescriptionLevel
				,f.Number as FundNumber
				,f.Title as FundTitle
				,i.Number as InventoryNumber
				,idl.[Text] as InventoryDescriptionLevel
				,s.[Text] as [Status]
				,isi.EnrolledArchivalEntityCount as AeCount
				,(SELECT COUNT(*) FROM v_PublicArchivalEntities as ae where InventorySystemIdentifier = i.SystemIdentifier and ISNUMERIC(RIGHT(ae.Number,1)) = 0) as AeWithCharCount
				,isi.EnrolledDocumentCount as EDocumentsCount
				,null as LinearMeters
				,isi.FileTypes as FileFormat
				,(select sum(d.Duration) from Documents d where i.SystemIdentifier = d.InventorySystemIdentifier) as Duration
				,ISNULL(isi.EnrolledBytes, 0) as Bytes
				,i.SystemIdentifier
				,i.ExternalIdentifier
				,i.HasExternalSource
		     FROM v_PublicInventories as i
			 LEFT JOIN v_InventorySizeInfo isi ON isi.InventorySystemIdentifier = i.SystemIdentifier AND isi.IsDraft = 0
		     JOIN [Archives] as a
		       ON i.ArchiveId = a.Id
		     JOIN v_Funds as f
		       ON i.FundSystemIdentifier = f.SystemIdentifier
		     JOIN N.FundDescriptionLevel as fdl
		       ON f.DescriptionLevelCode = fdl.Code
		     JOIN N.InventoryDescriptionLevel as idl
		       ON i.DescriptionLevelCode = idl.Code
		     JOIN N.[Status] as s
		       ON i.StatusCode = s.Code
			FULL OUTER JOIN v_ArchivalEntities as ae
			   ON i.SystemIdentifier = ae.InventorySystemIdentifier
			WHERE i.Deleted = 0 AND i.DescriptionLevelCode <> 6
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @Archives + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '','')) AND i.StatusCode not in (''4'', ''5'', ''9'', ''10'', ''11'', ''13'')) 
					OR (convert(varchar(4), i.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.ApproxmateChronologicalScope = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
				OR (cast(i.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
				OR (cast(i.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' = ''null'') 
				OR (try_cast(coalesce(
								convert(varchar, i.StartDateYear, 104) + ''.'' + convert(varchar, i.StartDateMonth, 104) + ''.'' + convert(varchar, i.StartDateDay, 104),
								convert(varchar, i.StartDateYear, 104) + ''.'' + convert(varchar, i.StartDateMonth, 104),
								convert(varchar, i.StartDateYear, 104)) as date) >= cast(''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' = ''null'') 
				OR (try_cast(coalesce(
								convert(varchar, i.EndDateYear, 104) + ''.'' + convert(varchar, i.EndDateMonth, 104) + ''.'' + convert(varchar, i.EndDateDay, 104),
								convert(varchar, i.EndDateYear, 104) + ''.'' + convert(varchar, i.EndDateMonth, 104),
								convert(varchar, i.EndDateYear, 104)) as date) <= cast(''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' as datetime2)))
		 GROUP BY a.[Name], fdl.[Text], f.Number, f.[Title], i.Number, idl.[Text], s.[Text], i.SystemIdentifier, i.Bytes, i.Id, isi.EnrolledDocumentCount, 
			isi.EnrolledArchivalEntityCount, isi.FileTypes, isi.EnrolledBytes , i.ExternalIdentifier, i.HasExternalSource
		');
	END

		IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				Archive nvarchar(255) NULL,
				FundDescriptionLevel nvarchar(255) NULL,
				FundNumber nvarchar(255) NULL,
				FundTitle nvarchar(max) NULL,
				InventoryNumber nvarchar(255) NULL,
				InventoryDescriptionLevel nvarchar(255) NULL,
				[Status] nvarchar(255) NULL,
				AeCount int NULL,
				AeWithCharCount int NULL,
				EDocumentsCount int NULL,
				LinearMeters decimal(18, 2) NULL,
				FileFormat nvarchar(max) NULL,
				Duration int NULL,
				Bytes bigint NULL,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
			);

			INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteTable
			UNION ALL
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