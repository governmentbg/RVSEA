SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetNumberOfDocumentsOrderedByEmployeeReport]
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(10) = null,
	@FundLevelOfdescriptionCodes nvarchar (10) = null,
	@InventoryNumber nvarchar(10) = null,
	@Employee nvarchar(max) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,

	@StatisticDataOnly bit
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql NVARCHAR(MAX);
	IF @FundLevelOfdescriptionCodes IS NULL BEGIN SET @FundLevelOfdescriptionCodes = '-999' END
	IF @Employee IS NULL BEGIN SET @Employee = '-999' END
	IF @StatisticDataOnly = 1 
		RETURN;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sqlFinalPart NVARCHAR(MAX) =  CONVERT(NVARCHAR(MAX),'
		ORDER BY Employee, Archive, FundLevelOfDescription, Fund, Inventory, ArchiveEntity, Document, AccessDate
		offset ') + CONVERT(NVARCHAR(10), @offset) +  CONVERT(NVARCHAR(MAX),' rows fetch next ') + CONVERT(NVARCHAR(10), @RowsOfPage) +  CONVERT(VARCHAR(MAX),' rows only');

	BEGIN
		DECLARE @localQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
	  SELECT 
	  		 up.DisplayName as Employee
	  		,a.[Name] as Archive
	  		,fdl.[Text] as FundLevelOfDescription
	  		,f.Number as Fund
	  		,CASE WHEN i.SystemIdentifier IS NOT NULL THEN CONVERT(varchar(max), i.SystemIdentifier)
				  ELSE CONVERT(varchar(max), i.ExternalIdentifier)
				  END as Inventory
	  		,CASE WHEN ae.SystemIdentifier IS NOT NULL THEN CONVERT(varchar(max), ae.SystemIdentifier)
				  ELSE CONVERT(varchar(max), ae.ExternalIdentifier)
				  END as ArchiveEntity
	  		,CASE WHEN d.SystemIdentifier IS NOT NULL THEN CONVERT(varchar(max), d.SystemIdentifier)
				  ELSE CONVERT(varchar(max), d.ExternalIdentifier)
				  END as Document
	  		,ur.[Date] as AccessDate
			,d.SystemIdentifier
			,d.ExternalIdentifier
			,d.HasExternalSource
			,i.Number as InventoryNumber
			,ae.Number as ArchivalEntityNumber
			,d.Number as DocumentNumber
			
	      FROM [UserReviews] as ur
	 LEFT JOIN AspNetUserProfiles as up
	  	    ON ur.UserId = up.UserId
	  	  JOIN v_Documents as d
	  	    ON ur.DocumentSystemIdentifier = d.SystemIdentifier OR ur.DocumentExternalIdentifier = d.ExternalIdentifier
	 LEFT JOIN v_Funds as f
	  	    ON d.FundSystemIdentifier = f.SystemIdentifier OR ur.FundExternalIdentifier = f.ExternalIdentifier
	 LEFT JOIN v_Inventories as i
		    ON d.InventorySystemIdentifier = i.SystemIdentifier OR ur.InventoryExternalIdentifier = i.ExternalIdentifier
	 LEFT JOIN v_ArchivalEntities as ae
		    ON d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier OR ur.ArchivalEntityExternalIdentifier = ae.ExternalIdentifier
	 LEFT JOIN Archives as a
	  	    ON d.ArchiveId = a.Id
	 LEFT JOIN N.FundDescriptionLevel as fdl
	  	    ON f.DescriptionLevelCode = fdl.Code
	     WHERE ((select u.UserType from AspNetUsers as u where up.UserId = u.Id) <> ''EXT'')
		   AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
		   AND ((''-999'' in (select element from dbo.SplitString(''' + @Employee  + ''', '',''))) 
				OR (convert(varchar(max), up.UserId, 104) in (select element from dbo.SplitString(''' + @Employee + ''', '',''))))
		   AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
		   AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
		   AND ((''-999'' in (select element from dbo.SplitString(''') + @FundLevelOfdescriptionCodes + CONVERT(NVARCHAR(MAX),''', '',''))) 
				OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''') + @FundLevelOfdescriptionCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
		   AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(ur.[Date] as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
		   AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(ur.[Date] as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))');
	END

	BEGIN
	SET @sql = @localQuery + @sqlFinalPart;
	END

	--print @sql;
	EXEC (@sql);
END
GO