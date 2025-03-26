SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.16'
where Code = 'DB_VERSION'

--add script here

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 
CREATE TABLE [dbo].[EmployeeReviews](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SystemIdentifier] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[Date] [datetime2](7) NOT NULL,
	[FundSystemIdentifier] [uniqueidentifier] NULL,
	[FundExternalIdentifier] [int] NULL,
	[InventorySystemIdentifier] [uniqueidentifier] NULL,
	[InventoryExternalIdentifier] [int] NULL,
	[ArchivalEntitySystemIdentifier] [uniqueidentifier] NULL,
	[ArchivalEntityExternalIdentifier] [int] NULL,
	[DocumentSystemIdentifier] [uniqueidentifier] NULL,
	[DocumentExternalIdentifier] [int] NULL,
	[IsDraft] [bit] NOT NULL,
 CONSTRAINT [PK_EmployeeReviews] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UI_EmployeeReviewsSystemIdentifier] UNIQUE NONCLUSTERED 
(
	[SystemIdentifier] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[EmployeeReviews]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[AspNetUsers] ([Id])
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetNumberOfDocumentsOrderedByReaderReport]
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(10) = null,
	@FundLevelOfdescriptionCodes nvarchar (10) = null,
	@InventoryNumber nvarchar(10) = null,
	@LibraryCardNumber nvarchar(10) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,

	@StatisticDataOnly bit
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql NVARCHAR(MAX);

	IF @FundLevelOfdescriptionCodes IS NULL BEGIN SET @FundLevelOfdescriptionCodes = '-999' END
	IF @LibraryCardNumber IS NULL BEGIN SET @LibraryCardNumber = '-999' END

	IF @StatisticDataOnly = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteReadersTable TABLE (
				Reader nvarchar(max) NULL = NULL,
				LibraryCardNumber nvarchar(256) NULL = NULL,
				Archive nvarchar(255) NULL = NULL,
				FundLevelOfDescription nvarchar(256) NULL = NULL,
				Fund nvarchar(256) NULL = NULL,
				Inventory nvarchar(256) NULL = NULL,
				ArchiveEntity nvarchar(256) NULL = NULL,
				Document nvarchar(2000) NULL = NULL,
				AccessDate varchar(50) NULL = NULL
			);'

		RETURN
	END

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sqlFinalPart NVARCHAR(MAX) =  CONVERT(NVARCHAR(MAX),'
		ORDER BY Reader, Archive, FundLevelOfDescription, Fund, Inventory, ArchiveEntity, Document, AccessDate
		offset ') + CONVERT(NVARCHAR(10), @offset) +  CONVERT(NVARCHAR(MAX),' rows fetch next ') + CONVERT(NVARCHAR(10), @RowsOfPage) +  CONVERT(VARCHAR(MAX),' rows only');

	BEGIN
		DECLARE @localQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
	  SELECT 
	  		 up.DisplayName as Reader
	  		,up.LibraryCardNumber as LibraryCardNumber
	  		,a.[Name] as Archive
	  		,fdl.[Text] as FundLevelOfDescription
	  		,f.Number as Fund
	  		,i.SystemIdentifier as Inventory
	  		,d.ArchivalEntitySystemIdentifier as ArchiveEntity
	  		,pr.DocumentSystemIdentifier as Document
	  		,pr.[Date] as AccessDate
	      FROM [PublicUserReviews] as pr
	 LEFT JOIN AspNetUserProfiles as up
	  	    ON pr.UserId = up.UserId
	  	  JOIN Documents as d
	  	    ON pr.DocumentSystemIdentifier = d.SystemIdentifier
	 LEFT JOIN Funds as f
	  	    ON d.FundSystemIdentifier = f.SystemIdentifier
	 LEFT JOIN Inventories as i
		    ON d.InventorySystemIdentifier = i.SystemIdentifier
	 LEFT JOIN Archives as a
	  	    ON d.ArchiveId = a.Id
	 LEFT JOIN N.FundDescriptionLevel as fdl
	  	    ON f.DescriptionLevelCode = fdl.Code
	     WHERE
			   ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
		   AND ((''-999'' in (select element from dbo.SplitString(''') + @LibraryCardNumber + CONVERT(NVARCHAR(MAX),''', '',''))) 
				OR (up.LibraryCardNumber in (select element from dbo.SplitString(''') + @LibraryCardNumber + CONVERT(NVARCHAR(MAX),''', '',''))))
		   AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
		   AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
		   AND ((''-999'' in (select element from dbo.SplitString(''') + @FundLevelOfdescriptionCodes + CONVERT(NVARCHAR(MAX),''', '',''))) 
				OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''') + @FundLevelOfdescriptionCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
		   AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(pr.[Date] as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
		   AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(pr.[Date] as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))');
	END

	BEGIN
	SET @sql = @localQuery + @sqlFinalPart;
	END

	--print @sql;
	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetNumberOfDocumentsOrderedByReaderReportCombined]
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(10) = null,
	@FundLevelOfdescriptionCodes nvarchar (max) = null,
	@InventoryNumber nvarchar(10) = null,
	@LibraryCardNumber nvarchar(max) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,

	@StatisticDataOnly bit

AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @sql NVARCHAR(MAX);

	SET @RowsOfPage = 2147483647
	SET @Page = 1

	CREATE TABLE #temp (
				Reader nvarchar(max) NULL,
				LibraryCardNumber nvarchar(256) NULL,
				Archive nvarchar(255) NULL,
				FundLevelOfDescription nvarchar(256) NULL,
				Fund nvarchar(256) NULL,
				Inventory nvarchar(256) NULL,
				ArchiveEntity nvarchar(256) NULL,
				Document nvarchar(2000) NULL,
				AccessDate varchar(50) NULL
				
			);

	INSERT INTO #temp(
				Reader,
				LibraryCardNumber,
				Archive,
				FundLevelOfDescription,
				Fund,
				Inventory,
				ArchiveEntity,
				Document,
				AccessDate
				
			)
	EXEC [sp_GetNumberOfDocumentsOrderedByReaderReport]
		 2147483647,
		 @Page,
		 @ArchiveCodes,
		 @FundNumber,
		 @FundLevelOfdescriptionCodes,
		 @InventoryNumber,
		 @LibraryCardNumber,
		 @DateFrom,
		 @DateTo,
		 
		 @StatisticDataOnly = 0
		
	SET @sql = '
		SELECT TOP 1
			 COUNT(DISTINCT #temp.ArchiveEntity) as DisticntAEsCount
			,COUNT(#temp.Document) as DocumentsReviewsCount
		FROM #temp'

	EXEC (@sql);

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetNumberOfDocumentsOrderedByReaderReportSummary]
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(10) = null,
	@FundLevelOfdescriptionCodes nvarchar (max) = null,
	@InventoryNumber nvarchar(10) = null,
	@LibraryCardNumber nvarchar(max) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,

	@StatisticDataOnly bit

AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @sql NVARCHAR(MAX);

	SET @RowsOfPage = 2147483647
	SET @Page = 1
	CREATE TABLE #temp (
				Reader nvarchar(max) NULL,
				LibraryCardNumber nvarchar(256) NULL,
				Archive nvarchar(255) NULL,
				FundLevelOfDescription nvarchar(256) NULL,
				Fund nvarchar(256) NULL,
				Inventory nvarchar(256) NULL,
				ArchiveEntity nvarchar(256) NULL,
				Document nvarchar(2000) NULL,
				AccessDate varchar(50) NULL
				
			);

	INSERT INTO #temp(
				Reader,
				LibraryCardNumber,
				Archive,
				FundLevelOfDescription,
				Fund,
				Inventory,
				ArchiveEntity,
				Document,
				AccessDate
				
			)
	EXEC [sp_GetNumberOfDocumentsOrderedByReaderReport]
		 @RowsOfPage,
		 @Page,
		 @ArchiveCodes,
		 @FundNumber,
		 @FundLevelOfdescriptionCodes,
		 @InventoryNumber,
		 @LibraryCardNumber,
		 @DateFrom,
		 @DateTo,
		 
		 @StatisticDataOnly = 0
		
	SET @sql = '
		SELECT COUNT_BIG(*) as TotalRows
		FROM #temp'

	EXEC (@sql);

END
GO

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
	BEGIN
		SET @sql = '
			DECLARE @remoteReadersTable TABLE (
				Employee nvarchar(max) NULL = NULL,
				Archive nvarchar(255) NULL = NULL,
				FundLevelOfDescription nvarchar(256) NULL = NULL,
				Fund nvarchar(256) NULL = NULL,
				Inventory nvarchar(256) NULL = NULL,
				ArchiveEntity nvarchar(256) NULL = NULL,
				Document nvarchar(2000) NULL = NULL,
				AccessDate varchar(50) NULL = NULL
			);'

		RETURN
	END

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
	  		,er.[Date] as AccessDate
	      FROM [EmployeeReviews] as er
	 LEFT JOIN AspNetUserProfiles as up
	  	    ON er.UserId = up.UserId
	  	  JOIN v_Documents as d
	  	    ON er.DocumentSystemIdentifier = d.SystemIdentifier OR er.DocumentExternalIdentifier = d.ExternalIdentifier
	 LEFT JOIN v_Funds as f
	  	    ON d.FundSystemIdentifier = f.SystemIdentifier OR er.FundExternalIdentifier = f.ExternalIdentifier
	 LEFT JOIN v_Inventories as i
		    ON d.InventorySystemIdentifier = i.SystemIdentifier OR er.InventoryExternalIdentifier = i.ExternalIdentifier
	 LEFT JOIN v_ArchivalEntities as ae
		    ON d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier OR er.ArchivalEntityExternalIdentifier = ae.ExternalIdentifier
	 LEFT JOIN Archives as a
	  	    ON d.ArchiveId = a.Id
	 LEFT JOIN N.FundDescriptionLevel as fdl
	  	    ON f.DescriptionLevelCode = fdl.Code
	     WHERE
			   ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
		   AND ((''-999'' in (select element from dbo.SplitString(''' + @Employee  + ''', '',''))) 
				OR (convert(varchar(max), up.UserId, 104) in (select element from dbo.SplitString(''' + @Employee + ''', '',''))))
		   AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
		   AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
		   AND ((''-999'' in (select element from dbo.SplitString(''') + @FundLevelOfdescriptionCodes + CONVERT(NVARCHAR(MAX),''', '',''))) 
				OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''') + @FundLevelOfdescriptionCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
		   AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(er.[Date] as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
		   AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(er.[Date] as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))');
	END

	BEGIN
	SET @sql = @localQuery + @sqlFinalPart;
	END

	--print @sql;
	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetNumberOfDocumentsOrderedByEmployeeReportCombined]
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(10) = null,
	@FundLevelOfdescriptionCodes nvarchar (max) = null,
	@InventoryNumber nvarchar(10) = null,
	@Employee nvarchar(max) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,

	@StatisticDataOnly bit

AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @sql NVARCHAR(MAX);

	SET @RowsOfPage = 2147483647
	SET @Page = 1

	CREATE TABLE #temp (
				Employee nvarchar(max) NULL,
				Archive nvarchar(255) NULL,
				FundLevelOfDescription nvarchar(256) NULL,
				Fund nvarchar(256) NULL,
				Inventory nvarchar(256) NULL,
				ArchiveEntity nvarchar(256) NULL,
				Document nvarchar(2000) NULL,
				AccessDate varchar(50) NULL
				
			);

	INSERT INTO #temp(
				Employee,
				Archive,
				FundLevelOfDescription,
				Fund,
				Inventory,
				ArchiveEntity,
				Document,
				AccessDate
				
			)
	EXEC [sp_GetNumberOfDocumentsOrderedByEmployeeReport]
		 2147483647,
		 @Page,
		 @ArchiveCodes,
		 @FundNumber,
		 @FundLevelOfdescriptionCodes,
		 @InventoryNumber,
		 @Employee,
		 @DateFrom,
		 @DateTo,
		 
		 @StatisticDataOnly = 0
		
	SET @sql = '
		SELECT TOP 1
			 COUNT(DISTINCT #temp.ArchiveEntity) as DisticntAEsCount
			,COUNT(#temp.Document) as DocumentsReviewsCount
		FROM #temp'

	EXEC (@sql);

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetNumberOfDocumentsOrderedByEmployeeReportSummary]
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber nvarchar(10) = null,
	@FundLevelOfdescriptionCodes nvarchar (max) = null,
	@InventoryNumber nvarchar(10) = null,
	@Employee nvarchar(max) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,

	@StatisticDataOnly bit

AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @sql NVARCHAR(MAX);

	SET @RowsOfPage = 2147483647
	SET @Page = 1
	CREATE TABLE #temp (
				Employee nvarchar(max) NULL,
				Archive nvarchar(255) NULL,
				FundLevelOfDescription nvarchar(256) NULL,
				Fund nvarchar(256) NULL,
				Inventory nvarchar(256) NULL,
				ArchiveEntity nvarchar(256) NULL,
				Document nvarchar(2000) NULL,
				AccessDate varchar(50) NULL
				
			);

	INSERT INTO #temp(
				Employee,
				Archive,
				FundLevelOfDescription,
				Fund,
				Inventory,
				ArchiveEntity,
				Document,
				AccessDate
				
			)
	EXEC [sp_GetNumberOfDocumentsOrderedByEmployeeReport]
		 @RowsOfPage,
		 @Page,
		 @ArchiveCodes,
		 @FundNumber,
		 @FundLevelOfdescriptionCodes,
		 @InventoryNumber,
		 @Employee,
		 @DateFrom,
		 @DateTo,
		 
		 @StatisticDataOnly = 0
		
	SET @sql = '
		SELECT COUNT_BIG(*) as TotalRows
		FROM #temp'

	EXEC (@sql);

END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetFundPublicReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null, 
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@TextDate nvarchar(2000) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by SortOrder, IntNumber, Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT
				isnull(fund.LinearMeters, 0) as LinearMeters,
				null as DigitalSize,
				fund.InvetoryCount as InventoryCount,
				fund.AECount as AECount,
				fund.ImmediateSourceOfAcquisition,
				a.Name as Archive,
				fund.Number,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.TypeGid) as FundType,
				(select Value + '';''
					from Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''IndustryIndex''
					FOR XML path(''''), elements) as IndustryIndex,
				(select Value + '';''
					from Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''MethodOfAcquisition''
					FOR XML path(''''), elements) as MethodOfAcquisition,
				fund.TextDate,
				(isnull(convert(varchar, StartDateDay) + ''.'', '''') + isnull(convert(varchar, StartDateMonth) + ''.'', '''') + isnull(convert(varchar, StartDateYear), '''')) as StartDate,
				(isnull(convert(varchar, fund.EndDateDay) + ''.'', '''') + isnull(convert(varchar, fund.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, fund.EndDateYear), '''')) as EndDate,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				fund.Title,
				fund.Note,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.StatusGid) as FundStatus,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.LevelOfDescriptionGid) as LevelOfDescription,
				fund.IntNumber,
				a.SortOrder
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE
				((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE(@TextDate, 'null') + '''))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				isnull(f.LinearMeters, 0) as LinearMeters,
				f.Bytes as DigitalSize, -- реално е MB, името на колоната трябва да се смени
				f.InventoryCount,
				f.ArchivalEntityCount as AECount,
				f.DocumentsProvider as ImmediateSourceOfAcquisition,
				a.Name as Archive,
				f.Number,
				(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
				(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''INDUSTRY_TYPE'' 
						and nv.EntityId=f.Id
					FOR XML path(''''), elements) as IndustryIndex,
				(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
						and nv.EntityId=f.Id
					FOR XML path(''''), elements) as MethodOfAcquisition,
				f.ApproxmateChronologicalScope as TextDate,
				(isnull(convert(varchar, f.StartDateDay) + ''.'', '''') + isnull(convert(varchar, f.StartDateMonth) + ''.'', '''') + isnull(convert(varchar, f.StartDateYear), '''')) as StartDate,
				(isnull(convert(varchar, f.EndDateDay) + ''.'', '''') + isnull(convert(varchar, f.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, f.EndDateYear), '''')) as EndDate,
				convert(varchar, f.CreatedOn, 104) as CreationDate,
				f.Title,
				f.Notes as Note,
				(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus,
				(SELECT Text FROM [N].[FundDescriptionLevel] dl where dl.Code = f.DescriptionLevelCode) as LevelOfDescription,
				f.NumberNumeric as IntNumber,
				a.SortOrder
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 1 -- fund 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = f.TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				LinearMeters float NULL, 
				DigitalSize bigint NULL,
				InventoryCount int NULL,
				AECount int NULL,
				ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				FundType nvarchar(MAX) NULL,
				IndustryIndex nvarchar(MAX) NULL,
				MethodOfAcquisition nvarchar(MAX) NULL,
				TextDate nvarchar(256) NULL,
				StartDate varchar(256) NULL,
				EndDate varchar(50) NULL,
				CreationDate varchar(50) NULL,
				Title nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				FundStatus nvarchar(MAX) NULL,
				LevelOfDescription nvarchar(MAX) NULL,
				IntNumber int null,
				SortOrder int null
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


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetFundReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null, 
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@TextDate nvarchar(2000) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQueryWhereClause VARCHAR(MAX) = '((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE( + @TextDate, 'null') + '''))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))';

		DECLARE @remoteQuery VARCHAR(MAX) = 
			'SELECT
				COUNT_BIG(*) TotalFunds,
				sum(isnull(convert(bigint, fund.InvetoryCount), 0)) TotalInventories,
				sum(isnull(convert(bigint, fund.AECount), 0)) TotalArchiveEntities,
				round(sum(fund.LinearMeters), 2) TotalLinearMeters,
				cast((select sum(sizes.Size) 
				from 
					(select (select sum(isnull(i.ByteLenght, 0)) 
						from Image i
						inner join Document_Modified d
						on i.DocumentGid = d.Gid
						where d.FundLGid = fund.LGid) as Size
						from [Archiving].[dbo].[Fund_Modified] fund
						WHERE ' + @remoteQueryWhereClause + '
					) sizes) * 0.000001 as decimal(10,2)) TotalSize
			FROM Fund_Modified as fund
			WHERE ' + @remoteQueryWhereClause;

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQueryWhereClause VARCHAR(max) = '
			ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
			AND DescriptionLevelCode = 1 -- fund
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
				) 
			)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
				) 
			)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))'; 

		DECLARE @localQuery VARCHAR(max) = 
			'SELECT
				COUNT_BIG(*) TotalFunds,
				sum(isnull(convert(bigint, InventoryCount), 0)) TotalInventories,
				sum(isnull(convert(bigint, ArchivalEntityCount), 0)) TotalArchiveEntities,
				round(sum(LinearMeters), 2) TotalLinearMeters,
				cast((select sum(sizes.Size) 
				from 
					(select (select sum(isnull(d.Bytes, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Size
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) sizes) as decimal(10, 2)) TotalSize -- въпреки че колоната се казва Bytes, тя съдържа MB, затова няма превръщане на мерните ед.
				FROM Funds f
				WHERE ' + @localQueryWhereClause;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalFunds bigint NULL,
				TotalInventories bigint NULL,
				TotalArchiveEntities bigint NULL,
				TotalLinearMeters float NULL,
				TotalSize decimal NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT 
				sum(u.TotalFunds) as TotalFunds, 
				sum(u.TotalInventories) as TotalInventories, 
				sum(u.TotalArchiveEntities) as TotalArchiveEntities, 
				sum(isnull(u.TotalLinearMeters, 0)) as TotalLinearMeters,
				sum(isnull(u.TotalSize, 0)) as TotalSize
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

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCompilationAndNTOOfEDocumentsReport]
	@LinkedServer nvarchar(50),
	@ResultType int, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,

	@ProcessStartDate nvarchar(100) = null,
	@ProcessEndDate nvarchar(100) = null,

	@ArchiveCodes nvarchar(10) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ProcessGids nvarchar(max) = null,
	@ProcessTypes nvarchar(max) = null,

	@FileFormats nvarchar(max) = null




AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by SortOrder, IntNumber, FundNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
    	
	IF @ResultType = 2 OR @ResultType = 1
	BEGIN

		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT
			a.Name as Archive,
			convert(nvarchar(256), fund.Number) as FundNumber,
			fund.Title as Title,
			STUFF(
				(select ''; '' + n.Value 
				   from ObjectNomenclature as obj 
				   join Nomenclature as n 
				     on n.Gid = obj.NomenclatureGid 
				  where obj.FundGid = fund.Gid for XML PATH('''')), 1, 1, '''') as MethodOfAcquisitions,
			(select n.Value from dbo.Nomenclature as n where n.Gid = fund.TypeGid) as Type,
			CAST(fund.TextDate as nvarchar(256)) as ChronologicalScope,
			fund.CreatedOn as DateOfFiling,
			(select n.Value from dbo.Nomenclature as n where n.Gid = fund.StatusGid) as Status,
			(select n.Value from dbo.Nomenclature as n where n.Gid = fund.LevelOfDescriptionGid) as LevelOfDescription,
			fund.InvetoryCount as InventoryCount,
			fund.AECount as AeCount,
			(select COUNT(d._id) from Document as d where d.FundLGid = fund.Gid) as DocumentCount,
			NULL as FileFormats,
			NULL as Mb,
			NULL as Duration,
			fund.Note as Note,
			fund.IntNumber,
			a.SortOrder
		FROM Fund_Modified as fund
		INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
		WHERE ((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) 
					OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) 
					OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) 
					OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
					OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
					OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
					OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
					OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) 
					OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessGids + ''', '',''))) 
					OR fund.ProcessGid in (select element from dbo.SplitString(''' + @ProcessGids + ''', '','')))
					
			    AND ((''' + COALESCE(@ProcessStartDate, 'null') + ''' = ''null'') 
					OR (cast((select Process.CreatedOn from Process where fund.ProcessGid = Process._id) as date) >= cast(''' + COALESCE(@ProcessStartDate, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@ProcessEndDate, 'null') + ''' = ''null'') 
					OR (cast((select Process.ModifiedOn from Process where fund.ProcessGid = Process._id) as date) <= cast(''' + COALESCE(@ProcessEndDate, 'null') + ''' as datetime2)))';	

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN

		DECLARE @localQuery VARCHAR(MAX) =  '
		SELECT
			a.Name as Archive,
			funds.Number as FundNumber,
			funds.Title as Title,
			STUFF(
				(select ''; '' + v.ValueCode  
					from NomenclatureValues as v 
					where v.EntityId = funds.Id and v.EntityType = ''fund'' and v.NomenclatureCode = ''ACQUISITION_METHOD'' and v.Deleted = 0 for XML PATH('''')), 1, 1, '''') as MethodOfAcquisitions,
			(select n.Text from N.Nomenclatures as n where n.Id = funds.TypeCode and n.Deleted = 0) as Type,
			CAST(funds.ApproxmateChronologicalScope as nvarchar(256)) as ChronologicalScope,
			funds.CreatedOn as DateOfFiling,
			(select n.Text from N.Nomenclatures as n where n.Id = funds.StatusCode and n.Deleted = 0) as Status,
			(select n.Text from N.Nomenclatures as n where n.Id = funds.DescriptionLevelCode and n.Deleted = 0) as LevelOfDescription,
			funds.InventoryCount as InventoryCount,
			funds.ArchivalEntityCount as AeCount,
			funds.DocumentCount as DocumentCount,
			--STRING_AGG((select n.Text from N.Nomenclatures as n join Documents as d on n.Id = d.FileFormatCode where d.FundSystemIdentifier = funds.SystemIdentifier and n.Deleted = 0), ''; '') as FileFormats,
			--STUFF(
			--	(select DISTINCT ''; '' + n.Text
			--		  from N.Nomenclatures as n
			--		  join Documents as d
			--		    on n.Id = d.FileFormatCode
			--		  where d.FundSystemIdentifier = funds.SystemIdentifier and n.Deleted = 0 for XML PATH('''')), 1, 1, '''') as FileFormats,
			STUFF((select n.Text + '';''
						from  NomenclatureValues nv
						join N.Nomenclatures n
						on nv.ValueCode = n.Code
						where nv.EntityType=''fund''
							and n.Deleted = 0
							and nv.Deleted = 0
							and nv.NomenclatureCode=''FILE_TYPE''
							and nv.EntityId=funds.Id
							and nv.EntityType=''fund''
							and n.ParentId=(select n1.Id from N.Nomenclatures n1 where n1.Code=''FILE_TYPE'')
						FOR XML path(''''), elements), 1, 1, '''') as FileFormats,
			CAST((select SUM(d.Bytes) from Documents as d where d.FundSystemIdentifier = funds.SystemIdentifier) as float) as Mb,
			--CAST((select SUM(CAST(d.Duration as int)) from Documents as d where d.FundSystemIdentifier = funds.SystemIdentifier) as nvarchar(256)) as Duration,
			CAST(dbo.FormatDuration((select sum(d.Duration) from Documents d where funds.SystemIdentifier = d.FundSystemIdentifier)) as nvarchar(256)) as Duration,
			--NULL as Duration,
			funds.Notes as Note,
			funds.NumberNumeric as IntNumber,
			a.SortOrder
		FROM Funds as funds
		INNER JOIN Archives a ON a.Id = funds.ArchiveId AND a.Deleted = 0
		WHERE funds.ExternalIdentifier IS NULL AND funds.HasExternalSource = 0 AND funds.Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
				OR ((select convert(varchar(4), n.Text, 104) from NomenclatureValues as v join N.Nomenclatures as n on n.Id = v.NomenclatureId where v.EntityId = funds.Id and v.EntityType = ''fund'' and v.NomenclatureCode = ''ACQUISITION_METHOD''and n.Deleted = 0 and v.Deleted = 0) in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
				OR (''-998'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
				OR ((select convert(varchar(4), Id, 104) from Process as p where p.FundSystemIdentifier = funds.SystemIdentifier and p.Deleted = 0 and p.Completed = 1) in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))))	
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
				OR (cast(funds.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
				OR (cast(funds.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(coalesce(
								convert(varchar, funds.StartDateYear, 104) + ''.'' + convert(varchar, funds.StartDateMonth, 104) + ''.'' + convert(varchar, funds.StartDateDay, 104),
								convert(varchar, funds.StartDateYear, 104) + ''.'' + convert(varchar, funds.StartDateMonth, 104),
								convert(varchar, funds.StartDateYear, 104)) as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(coalesce(
								convert(varchar, funds.EndDateYear, 104) + ''.'' + convert(varchar, funds.EndDateMonth, 104) + ''.'' + convert(varchar, funds.EndDateDay, 104),
								convert(varchar, funds.EndDateYear, 104) + ''.'' + convert(varchar, funds.EndDateMonth, 104),
								convert(varchar, funds.EndDateYear, 104)) as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))

			AND ((''' + COALESCE(@ProcessStartDate, 'null') + ''' = ''null'') 
				OR (cast((select top(1) Process.CreatedOn from Process where funds.SystemIdentifier = Process.FundSystemIdentifier) as date) >= cast(''' + COALESCE(@ProcessStartDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ProcessEndDate, 'null') + ''' = ''null'') 
				OR (cast((select top(1) Process.UpdatedOn from Process where funds.SystemIdentifier = Process.FundSystemIdentifier) as date) <= cast(''' + COALESCE(@ProcessEndDate, 'null') + ''' as datetime2)))
					
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FileFormats + ''', '','')))
				OR (exists((select nv.ValueCode
					from NomenclatureValues nv join N.Nomenclatures n on n.Id = nv.NomenclatureId
					join Funds as f1 on nv.EntityId = f1.Id
					where f1.Id=funds.Id and nv.NomenclatureCode=''FILE_TYPE''
					and n.Deleted=0 and nv.Deleted=0) INTERSECT (select element from dbo.SplitString(''' + @FileFormats + ''', '','')))))';
				
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Archive nvarchar(256) NULL,
				FundNumber nvarchar(256) NULL,
				Title nvarchar(MAX) NULL,
				MethodOfAcquisitions nvarchar(256) NULL,
				Type nvarchar(256) NULL,
				ChronologicalScope nvarchar(256) NULL,
				DateOfFiling nvarchar(256) NULL,
				Status nvarchar(256) NULL,
				LevelOfDescription nvarchar(256) NULL,
				InventoryCount int NULL,
				AeCount int NULL,
				DocumentCount int NULL,
				FileFormats nvarchar(256) NULL,
				Mb float NULL,
				Duration nvarchar(256) NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null,
				SortOrder int null
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

	--print @sql;
	EXEC (@sql);
END
GO

ALTER TABLE [PackageADocsTemplates] ADD [Static] bit NOT NULL DEFAULT 1
GO

UPDATE N.ProcessSteps SET AllowTaskTemplate = 1 WHERE ID IN (123, 130, 214)
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[GetActiveProcessesReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ProcessTypeGids nvarchar(max) = null,
	@ProcessTypeCodesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber NVARCHAR(50) = null,
	@CreatedFrom nvarchar(100) = null,
	@CreatedTo nvarchar(100) = null,
	@UserGids nvarchar(max)= null,
	@UserIdsInternal nvarchar(max)= null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		--GROUP BY p.Id, ps.Id, a.Name, fdl.Text, f.Number, f.Title, pt.Name, p.CreatedOn, u.DisplayName, f.NumberNumeric, a.SortOrder
		order by SortOrder, IntNumber, FundNumber
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				a.Name AS Archive,
				(SELECT Value FROM Nomenclature n5 where n5._retired = ''3000-01-01'' and n5.Gid = fund.LevelOfDescriptionGid ) as DescriptionLevel,
				NULL AS FundId,
				fund.Number AS FundNumber,
				fund.Title AS Title,
				NULL as DocumentId,
				NULL AS DocumentNumber,
				(cast((select Value from Nomenclature where _retired = ''3000-01-01'' and Gid = p.TypeGid) as nvarchar(500)) + '' Стъпка: '' 
					+ CAST((SELECT Value  from Nomenclature where _retired = ''3000-01-01'' and Gid = p.StepGid) AS NVARCHAR(500)))  ProcessName,
				convert(varchar, p.CreatedOn, 104) as ProcessStartDate,
				(SELECT Name FROM [User] where _retired = ''3000-01-01'' and Gid = p.CreatedBy) as Initiator, 
				fund.IntNumber,
				a.SortOrder,
				NULL AS ProcessStepId,
				''Fund'' AS EntityType
			FROM Process p
			--Няма активна стъпка 1
			INNER JOIN Fund_Modified fund ON fund.ProcessGid = p.Gid
				AND fund.RowStatusGid = 72
				AND (''' + ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')) + 
					 N''' = ''NULL'' OR fund.Number = ''' + 
					ISNULL(@FundNumber, N'NULL') +  N''')
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE p._retired = ''3000-01-01''
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND not exists(select 1 from Document_Search_Modified where ProcessGid = p.Gid)
				AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1)
				AND p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '',''))
				AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR p.TypeGid in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '','')))
				AND p.TypeGid not in (2377, 2126, 2123, 2124, 2125)
				
			UNION ALL
			
			SELECT
				a.Name AS Archive,
				NULL as DescriptionLevel,
				NULL AS FundId,
				NULL AS FundNumber,
				NULL AS Title,
				NULL AS DocumentId,
				NULL AS DocumentNumber,
				(cast((select Value from Nomenclature where _retired = ''3000-01-01'' and Gid = p.TypeGid) as nvarchar(500)) + '' Стъпка: '' 
					+ CAST((SELECT Value  from Nomenclature where _retired = ''3000-01-01'' and Gid = p.StepGid) AS NVARCHAR(500)))  ProcessName,
				convert(varchar, p.CreatedOn, 104) as ProcessStartDate,
				(SELECT Name FROM [User] where _retired = ''3000-01-01'' and Gid = p.CreatedBy) as Initiator, 
				NULL AS IntNumber,
				NULL AS SortOrder,
				NULL AS ProcessStepId,
				NULL AS EntityType
			FROM [Process] p
			INNER JOIN Archive a ON a.Gid = p.[CExportArchiveGid] AND a.Code IN (SELECT Element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')) AND a._retired = ''3000-01-01''
			WHERE p._retired = ''3000-01-01''
				AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1) --Няма активна стъпка 1 
				AND p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '',''))
				AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
				AND p.TypeGid in (SELECT [Gid] FROM Nomenclature WHERE [Type] = ''Process'' AND [_retired] = ''3000-01-01'' 
					AND [Code] IN (25, 26, 34) AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR [Gid] IN (SELECT Element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))))
			
			UNION ALL

			SELECT
				a.Name AS Archive,
				(SELECT Value FROM Nomenclature n5 where n5._retired = ''3000-01-01'' and n5.Gid = fund.LevelOfDescriptionGid ) as DescriptionLevel,
				NULL AS FundId,
				fund.Number AS FundNumber,
				fund.Title AS Title,
				cast(doc.LGid as nvarchar) as DocumentId,
				NULL AS DocumentNumber,
				(cast((select Value from Nomenclature where _retired = ''3000-01-01'' and Gid = p.TypeGid) as nvarchar(500)) + '' Стъпка: '' 
					+ CAST((SELECT Value  from Nomenclature where _retired = ''3000-01-01'' and Gid = p.StepGid) AS NVARCHAR(500)))  ProcessName,
				convert(varchar, p.CreatedOn, 104) as ProcessStartDate,
				(SELECT Name FROM [User] where _retired = ''3000-01-01'' and Gid = p.CreatedBy) as Initiator, 
				fund.IntNumber,
				a.SortOrder,
				NULL AS ProcessStepId,
				''Document'' AS EntityType
			FROM Process p
				inner join Document_Modified doc on doc.ProcessGid = p.Gid
				and doc.RowStatusGid = 72
				inner join Fund_Modified fund on fund.LGid = doc.FundLGid
					AND (''' + ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')) + 
						N''' = ''NULL'' OR fund.Number = ''' + 
						ISNULL(@FundNumber,  N'NULL') + N''')
				INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE p._retired = ''3000-01-01''
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1) --Няма активна стъпка 1
				AND p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '',''))
				AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR p.TypeGid in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '','')))
	';
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	DECLARE @localQueryWhereClause VARCHAR(MAX) = '
		AND p.Completed = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR ((select convert(varchar(4), a.Code, 104)) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND (''' + ISNULL(@FundNumber, N'NULL') + N''' = ''NULL'' OR f.Number = ''' + ISNULL(@FundNumber, N'NULL') +  N''')
			AND CAST(p.CreatedBy AS VARCHAR(50)) in (SELECT Element from dbo.SplitString(''' + @UserIdsInternal + ''', '',''))
			AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeCodesInternal + ''', '',''))) OR pt.Id in (select element from dbo.SplitString(''' + @ProcessTypeCodesInternal + ''', '','')))
	';

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT DISTINCT
				a.Name AS Archive,
				fdl.Text AS DescriptionLevel,
				NULL AS FundId,
				f.Number AS FundNumber,
				f.Title AS Title,
				cast(d.SystemIdentifier as nvarchar(50)) AS DocumentId,
				d.Number AS DocumentNumber,
				(pt.Name + '' Стъпка: '' + ps.Text) AS ProcessName,
				convert(varchar, p.CreatedOn, 104) as ProcessStartDate,
				u.DisplayName AS Initiator,
				f.NumberNumeric as IntNumber,
				a.SortOrder AS SortOrder,
				p.Id AS ProcessId,
				''Document'' AS EntityType
				--,ps.Id AS ProcessStepId
			FROM v_Documents d 
			INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
			INNER JOIN Funds f ON d.FundSystemIdentifier = f.SystemIdentifier
			INNER JOIN Process p ON p.DocumentSystemIdentifier = d.SystemIdentifier AND p.Deleted = 0 AND p.Completed = 0
			INNER JOIN AspNetUsers u ON u.Id = p.CreatedBy AND u.Deleted = 0
			LEFT JOIN N.ProcessTypes pt ON pt.Id = p.ProcessTypeId
			LEFT JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode
			INNER JOIN ProcessTimeline ptl ON ptl.ProcessId = p.Id AND ptl.completed = 0
			INNER JOIN N.ProcessSteps ps ON ps.Id = ptl.StepTypeId
			WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0'  
				+ @localQueryWhereClause + '

			UNION

			SELECT DISTINCT
				a.Name AS Archive,
				fdl.Text AS DescriptionLevel,
				f.SystemIdentifier AS FundId,
				f.Number AS FundNumber,
				f.Title AS Title,
				NULL AS DocumentId,
				NULL AS DocumentNumber,
				(pt.Name + '' Стъпка: '' + ps.Text) AS ProcessName,
				convert(varchar, p.CreatedOn, 104) as ProcessStartDate,
				u.DisplayName AS Initiator,
				f.NumberNumeric as IntNumber,
				a.SortOrder AS SortOrder,
				p.Id AS ProcessId,
				''Fund'' AS EntityType
				--,ps.Id AS ProcessStepId
			FROM v_Funds f 
			INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
			INNER JOIN Process p ON p.FundSystemIdentifier = f.SystemIdentifier AND p.Deleted = 0 AND p.Completed = 0
			INNER JOIN AspNetUsers u ON u.Id = p.CreatedBy AND u.Deleted = 0
			LEFT JOIN N.ProcessTypes pt ON pt.Id = p.ProcessTypeId
			LEFT JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode
			INNER JOIN ProcessTimeline ptl ON ptl.ProcessId = p.Id AND ptl.completed = 0
			INNER JOIN N.ProcessSteps ps ON ps.Id = ptl.StepTypeId
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0'
				+ @localQueryWhereClause
			;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				Archive nvarchar(256) NOT NULL,
				DescriptionLevel nvarchar(256) NOT NULL,
				FundId nvarchar(50) NULL,
				FundNumber nvarchar(256) NULL,
				Title nvarchar(MAX) NULL,
				DocumentId nvarchar(50) NULL,
				DocumentNumber nvarchar(256) NULL,
				ProcessName nvarchar(MAX) NULL,
				ProcessStartDate varchar(50) NULL,
				Initiator nvarchar(256) NULL,
				IntNumber int null,
				SortOrder int null,
				ProcessId INT NULL,
				EntityType nvarchar(50) NULL
				--,ProcessStepId INT NULL
			);

			INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteTable
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

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetActiveProcessesReportCount] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ProcessTypeGids nvarchar(max) = null,
	@ProcessTypeCodesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber NVARCHAR(50) = null,
	@CreatedFrom nvarchar(100) = null,
	@CreatedTo nvarchar(100) = null,
	@UserGids nvarchar(max)= null,
	@UserIdsInternal nvarchar(max)= null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT(Gid) as Total FROM
			(
				SELECT p.Gid Gid
				FROM Process p
				--Няма активна стъпка 1
				INNER JOIN Fund_Modified fund ON fund.ProcessGid = p.Gid
					AND fund.RowStatusGid = 72
					AND (''' + ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')) + 
						 N''' = ''NULL'' OR fund.Number = ''' + 
						ISNULL(@FundNumber, N'NULL') +  N''')
				INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
				WHERE p._retired = ''3000-01-01''
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
					AND not exists(select 1 from Document_Search_Modified where ProcessGid = p.Gid)
					AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1)
					AND p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '',''))
					AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR p.TypeGid in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '','')))
					AND p.TypeGid not in (2377, 2126, 2123, 2124, 2125) 

				UNION

				SELECT p.Gid Gid
				FROM [Process] p
				INNER JOIN Archive a ON a.Gid = p.[CExportArchiveGid] AND a.Code IN (SELECT Element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')) AND a._retired = ''3000-01-01''
				WHERE p._retired = ''3000-01-01''
					AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1) --Няма активна стъпка 1 
					AND p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '',''))
					AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
					AND p.TypeGid in (SELECT [Gid] FROM Nomenclature WHERE [Type] = ''Process'' AND [_retired] = ''3000-01-01'' 
						AND [Code] IN (25, 26, 34) AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR [Gid] IN (SELECT Element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))))
				UNION

				SELECT p.Gid Gid
				FROM Process p
					inner join Document_Modified doc on doc.ProcessGid = p.Gid
					and doc.RowStatusGid = 72
					inner join Fund_Modified fund on fund.LGid = doc.FundLGid
						AND (''' + ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')) + 
							N''' = ''NULL'' OR fund.Number = ''' + 
							ISNULL(@FundNumber,  N'NULL') + N''')
					INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
				WHERE p._retired = ''3000-01-01''
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
					AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1) --Няма активна стъпка 1
					AND p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '',''))
					AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR p.TypeGid in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '','')))
			) t
		';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	DECLARE @localQueryWhereClause VARCHAR(MAX) = '
		AND p.Completed = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR ((select convert(varchar(4), a.Code, 104)) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND (''' + ISNULL(@FundNumber, N'NULL') + N''' = ''NULL'' OR f.Number = ''' + ISNULL(@FundNumber, N'NULL') +  N''')
			AND CAST(p.CreatedBy AS VARCHAR(50)) in (SELECT Element from dbo.SplitString(''' + @UserIdsInternal + ''', '',''))
			AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeCodesInternal + ''', '',''))) OR pt.Id in (select element from dbo.SplitString(''' + @ProcessTypeCodesInternal + ''', '','')))
	';
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT(ProcessId) as Total FROM
			(
				SELECT p.Id ProcessId
				FROM v_Documents d 
				INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
				INNER JOIN Funds f ON d.FundSystemIdentifier = f.SystemIdentifier
				INNER JOIN Process p ON p.DocumentSystemIdentifier = d.SystemIdentifier AND p.Deleted = 0
				INNER JOIN AspNetUsers u ON u.Id = p.CreatedBy AND u.Deleted = 0
				INNER JOIN N.ProcessTypes pt ON pt.Id = p.ProcessTypeId
				INNER JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode
				WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0'  
					+ @localQueryWhereClause + '

				UNION

				SELECT p.Id ProcessId
				FROM v_Funds f 
				INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
				INNER JOIN Process p ON p.FundSystemIdentifier = f.SystemIdentifier AND p.Deleted = 0
				INNER JOIN AspNetUsers u ON u.Id = p.CreatedBy AND u.Deleted = 0
				INNER JOIN N.ProcessTypes pt ON pt.Id = p.ProcessTypeId
				INNER JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode
				WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0'
					+ @localQueryWhereClause + '
			) t'
		;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteRowsTable TABLE ( 
				Total int NULL
			);

			INSERT INTO @remoteRowsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.Total) as Total
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteRowsTable
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

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetActiveProcessesReportTotalRows] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ProcessTypeGids nvarchar(max) = null,
	@ProcessTypeCodesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@FundNumber NVARCHAR(50) = null,
	@CreatedFrom nvarchar(100) = null,
	@CreatedTo nvarchar(100) = null,
	@UserGids nvarchar(max)= null,
	@UserIdsInternal nvarchar(max)= null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT SUM( Rows) as TotalRows FROM
			(
				SELECT COUNT_BIG(*) Rows
				FROM Process p
				--Няма активна стъпка 1
				INNER JOIN Fund_Modified fund ON fund.ProcessGid = p.Gid
					AND fund.RowStatusGid = 72
					AND (''' + ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')) + 
						 N''' = ''NULL'' OR fund.Number = ''' + 
						ISNULL(@FundNumber, N'NULL') +  N''')
				INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
				WHERE p._retired = ''3000-01-01''
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
					AND not exists(select 1 from Document_Search_Modified where ProcessGid = p.Gid)
					AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1)
					AND p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '',''))
					AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR p.TypeGid in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '','')))
					AND p.TypeGid not in (2377, 2126, 2123, 2124, 2125) 

				UNION ALL

				SELECT COUNT_BIG(*) Rows
				FROM [Process] p
				INNER JOIN Archive a ON a.Gid = p.[CExportArchiveGid] AND a.Code IN (SELECT Element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')) AND a._retired = ''3000-01-01''
				WHERE p._retired = ''3000-01-01''
					AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1) --Няма активна стъпка 1 
					AND p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '',''))
					AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
					AND p.TypeGid in (SELECT [Gid] FROM Nomenclature WHERE [Type] = ''Process'' AND [_retired] = ''3000-01-01'' 
						AND [Code] IN (25, 26, 34) AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR [Gid] IN (SELECT Element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))))
				
				UNION ALL

				SELECT COUNT_BIG(*) Rows
				FROM Process p
					inner join Document_Modified doc on doc.ProcessGid = p.Gid
					and doc.RowStatusGid = 72
					inner join Fund_Modified fund on fund.LGid = doc.FundLGid
						AND (''' + ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL')) + 
							N''' = ''NULL'' OR fund.Number = ''' + 
							ISNULL(@FundNumber,  N'NULL') + N''')
					INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
				WHERE p._retired = ''3000-01-01''
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
					AND p.StepGid != (select Gid from Nomenclature where _retired = ''3000-01-01'' and type = ''step'' and Code = 1) --Няма активна стъпка 1
					AND p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '',''))
					AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '',''))) OR p.TypeGid in (select element from dbo.SplitString(''' + @ProcessTypeGids + ''', '','')))
			) t
		';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	DECLARE @localQueryWhereClause VARCHAR(MAX) = '
		AND p.Completed = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR ((select convert(varchar(4), a.Code, 104)) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND (''' + ISNULL(@FundNumber, N'NULL') + N''' = ''NULL'' OR f.Number = ''' + ISNULL(@FundNumber, N'NULL') +  N''')
			AND CAST(p.CreatedBy AS VARCHAR(50)) in (SELECT Element from dbo.SplitString(''' + @UserIdsInternal + ''', '',''))
			AND ((''' + COALESCE(@CreatedFrom, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) >= cast(''' + COALESCE(@CreatedFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@CreatedTo, 'null') + ''' = ''null'') OR (cast(p.CreatedOn as date) <= cast(''' + COALESCE(@CreatedTo, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypeCodesInternal + ''', '',''))) OR pt.Id in (select element from dbo.SplitString(''' + @ProcessTypeCodesInternal + ''', '','')))
	';
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT SUM(Rows) as TotalRows FROM
			(
				SELECT COUNT_BIG(*) Rows FROM (
					SELECT DISTINCT 
						NULL AS FundId,
						cast(d.SystemIdentifier as nvarchar(50)) AS DocumentId,
						p.Id AS ProcessId,
						''Document'' AS EntityType
					FROM v_Documents d 
					INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
					INNER JOIN Funds f ON d.FundSystemIdentifier = f.SystemIdentifier
					INNER JOIN Process p ON p.DocumentSystemIdentifier = d.SystemIdentifier AND p.Deleted = 0 AND p.Completed = 0
					INNER JOIN AspNetUsers u ON u.Id = p.CreatedBy AND u.Deleted = 0
					LEFT JOIN N.ProcessTypes pt ON pt.Id = p.ProcessTypeId
					LEFT JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode
					INNER JOIN ProcessTimeline ptl ON ptl.ProcessId = p.Id AND ptl.completed = 0
					--INNER JOIN N.ProcessSteps ps ON ps.Id = ptl.StepTypeId
					WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0'   
						+ @localQueryWhereClause + '
				) t1

				UNION

				SELECT COUNT_BIG(*) Rows FROM (
					SELECT DISTINCT
						f.SystemIdentifier AS FundId,
						NULL AS DocumentId,
						p.Id AS ProcessId,
						''Fund'' AS EntityType
					FROM v_Funds f 
					INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
					INNER JOIN Process p ON p.FundSystemIdentifier = f.SystemIdentifier AND p.Deleted = 0 AND p.Completed = 0
					INNER JOIN AspNetUsers u ON u.Id = p.CreatedBy AND u.Deleted = 0
					LEFT JOIN N.ProcessTypes pt ON pt.Id = p.ProcessTypeId
					LEFT JOIN N.FundDescriptionLevel fdl ON fdl.Code = f.DescriptionLevelCode
					INNER JOIN ProcessTimeline ptl ON ptl.ProcessId = p.Id AND ptl.completed = 0
					--INNER JOIN N.ProcessSteps ps ON ps.Id = ptl.StepTypeId
					WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0'
						+ @localQueryWhereClause + '
				) t2
			) t'
		;
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteRowsTable TABLE ( 
				TotalRows bigint NULL
			);

			INSERT INTO @remoteRowsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
			FROM (
				SELECT * 
				FROM (
					SELECT *    
					FROM @remoteRowsTable
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


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetFundMemoryPublicReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@PeriodGids nvarchar(max) = null,
	@FundArraysInternal nvarchar(max) = null,
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@TextDate nvarchar(2000) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by SortOrder, IntNumber, Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = 
			'SELECT
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				fund.Title,
				fund.ImmediateSourceOfAcquisition,
				fund.AccessConditions,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.TypeGid) as FundType,
				fund.Note,
				(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.StatusGid) as FundStatus,
				(select Value + '';''
					from  Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''MethodOfAcquisition''
					FOR XML path(''''), elements) as MethodOfAcquisition,
				fund.TextDate,
				(isnull(convert(varchar, StartDateDay) + ''.'', '''') + isnull(convert(varchar, StartDateMonth) + ''.'', '''') + isnull(convert(varchar, StartDateYear), '''')) as StartDate,
				(isnull(convert(varchar, fund.EndDateDay) + ''.'', '''') + isnull(convert(varchar, fund.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, fund.EndDateYear), '''')) as EndDate,
				isnull(fund.LinearMeters, 0),
				0 as Mb,
				fund.IntNumber,
				a.SortOrder
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE
				(''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 3)
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE( + @TextDate, 'null') + '''))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))';
		
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				a.Name as Archive,
				f.Number,
				convert(varchar, f.CreatedOn, 104) as CreationDate,
				f.Title,
				f.DocumentsProvider as ImmediateSourceOfAcquisition,
				f.DocumentsAccessDescription as AccessConditions,
				(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
				Notes as Note,
				(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus,
				(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
						and nv.EntityId=f.Id
					FOR XML path(''''), elements) as MethodOfAcquisition,
				f.ApproxmateChronologicalScope as TextDate,
				(isnull(convert(varchar, f.StartDateDay) + ''.'', '''') + isnull(convert(varchar, f.StartDateMonth) + ''.'', '''') + isnull(convert(varchar, f.StartDateYear), '''')) as StartDate,
				(isnull(convert(varchar, f.EndDateDay) + ''.'', '''') + isnull(convert(varchar, f.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, f.EndDateYear), '''')) as EndDate,
				isnull(f.LinearMeters, 0) as LinearMeters,
				isnull(f.Bytes, 0) as Mb,
				f.NumberNumeric as IntNumber,
				a.SortOrder
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 3 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				CreationDate varchar(50) NULL,
				Title nvarchar(MAX) NULL,
				ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
				AccessConditions nvarchar(MAX) NULL,
				FundType nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				FundStatus nvarchar(MAX) NULL,
				MethodOfAcquisition nvarchar(MAX) NULL,
				TextDate nvarchar(256) NULL,
				StartDate varchar(256) NULL,
				EndDate varchar(50) NULL,
				LinearMeters float NULL,
				Mb float NULL,
				IntNumber int null,
				SortOrder int null
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteFundsTable
			UNION
			' +
			@localQuery +  + @sqlFinalPart;	
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


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetFundMemoryPublicReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@PeriodGids nvarchar(max) = null,
	@FundArraysInternal nvarchar(max) = null,
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@TextDate nvarchar(2000) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 IF @ResultType = 1 OR @ResultType = 2
	BEGIN
	DECLARE @remoteQuery VARCHAR(MAX) = 
		'SELECT
				COUNT_BIG(*) TotalRows,
				SUM(fund.LinearMeters) TotalLinearMeters
			FROM Fund_Modified as fund
			WHERE
				(''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
				AND fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 3)
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE( + @TextDate, 'null') + '''))
				AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

 IF @ResultType = 1 OR @ResultType = 3
  BEGIN
	DECLARE @localQuery VARCHAR(max) = 
		'SELECT
			COUNT_BIG(*) TotalRows,
			SUM(LinearMeters) TotalLinearMeters
			FROM Funds f
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode = 3 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))';
    END

	declare @sql varchar(max);

 IF @ResultType = 1
  BEGIN
	 SET @sql = '
		DECLARE @remoteFundsTable TABLE ( 
			TotalRows bigint NULL,
			TotalLinearMeters float NULL
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
		SELECT sum(u.TotalRows) as TotalRows, sum(round(isnull(u.TotalLinearMeters, 0),2)) as TotalLinearMeters 
		FROM (
			SELECT * FROM (
				SELECT *    
				FROM @remoteFundsTable
				UNION
				' +
				@localQuery + ') lf) u';	

				
  END
  IF @ResultType = 3
   BEGIN
    SET @sql = @localQuery
   END
  
 --print @sql;
	exec (@sql);
END
GO


if not exists (select null from N.FundArray where Code = N'Е')
begin 
	insert into N.FundArray(Code, Text, SortOrder, HasExternalSource)
	values(N'Е', N'Е', 5, 0)
end 
go

update FundDrafts
set NumberArray = ''
where NumberArray is null
and IsCurrent = 1
go

update Funds
set NumberArray = ''
where NumberArray is null
and Deleted = 0
go


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryReport]
	@LinkedServer nvarchar(50),
	@ResultType int,
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveInternal nvarchar(max) = null,
	@StatusGids nvarchar(10) = null,
	@StatusesInternal nvarchar(max) = null,
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
		order by CountryCode
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
		DECLARE @remoteQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
			SELECT
			''BG'' as CountryCode,
			(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = inv.ArchiveGid) as Archive,
			(SELECT Value FROM Nomenclature n5 where n5._retired = ''3000-01-01'' and n5.Gid = fund.LevelOfDescriptionGid ) as FundDescriptionLevel,
			fund.Number as FundNumber,
			fund.Title as FundTitle,
			inv.Number as InventoryNumber,
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = inv.LevelOfDescriptionGid) as InventoryDescriptionLevel,
			(SELECT Value FROM Nomenclature WHERE _retired = ''3000-01-01'' and Gid = inv.StatusGid) as [Status],
			ISNULL(inv.AECount, 0) as AeCount,
			(SELECT COUNT(*) FROM ArchiveEntity_Modified as ae where InventoryLGid = inv.LGid and ISNUMERIC(RIGHT(ae.Number,1)) = 0) as AeWithCharCount,
			round(isnull(cast(inv.LinearMeter as decimal(18,2)), 0),2) as LinearMeters,
			0.0 as Mb
			FROM Inventory as inv
			inner join Fund_Modified as fund on inv.FundLGid = fund.LGid
			WHERE
			fund._retired = ''3000-01-01''
			AND inv._retired = ''3000-01-01''
			AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (fund.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
			AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (inv.TextDate = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
			AND ((''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' = ''null'') OR (cast(inv.StartDate as date) >= cast(''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' = ''null'') OR (cast(inv.EndDate as date) <= cast(''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(inv.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(inv.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR (inv.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR (inv.ArchiveGid in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))))
			AND inv.LevelOfDescriptionGid in(
			2171, -- Inventory
			2172  -- InventoryRough
			)
		');
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		DECLARE @localQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
			SELECT
				''BG'' as CountryCode
				,a.[Name] as Archive
				,fdl.[Text] as FundDescriptionLevel
				,f.Number as FundNumber
				,f.Title as FundTitle
				,i.Number as InventoryNumber
				,idl.[Text] as InventoryDescriptionLevel
				,s.[Text] as [Status]
				,COUNT(ae.SystemIdentifier) as AeCount
				,(SELECT COUNT(*) FROM v_ArchivalEntities as ae where InventorySystemIdentifier = i.SystemIdentifier and ISNUMERIC(RIGHT(ae.Number,1)) = 0) as AeWithCharCount
				,ROUND(ISNULL(CAST(i.LinearMeters as decimal(18,2)), 0), 2) as LinearMeters
				,ROUND(ISNULL(CAST(i.Bytes as decimal(18,2)), 0), 2) as Mb
		     FROM v_Inventories as i
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
			WHERE
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveInternal  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal  + ''', '',''))) 
				OR (convert(varchar(4), i.StatusCode, 104) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
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
		 GROUP BY a.[Name], fdl.[Text], f.Number, f.[Title], i.Number, idl.[Text], s.[Text], i.SystemIdentifier, i.LinearMeters, i.Bytes
		');
	END

		IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				CountryCode nvarchar(255) NULL,
				Archive nvarchar(255) NULL,
				FundDescriptionLevel nvarchar(255) NULL,
				FundNumber nvarchar(255) NULL,
				FundTitle nvarchar(max) NULL,
				InventoryNumber nvarchar(255) NULL,
				InventoryDescriptionLevel nvarchar(255) NULL,
				[Status] nvarchar(255) NULL,
				AeCount int NULL,
				AeWithCharCount int NULL,
				LinearMeters decimal NULL,
				Mb decimal NULL

			);

			INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteTable
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryReportCombined]
	@LinkedServer nvarchar(50),
	@ResultType int,
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveInternal nvarchar(max) = null,
	@StatusGids nvarchar(10) = null,
	@StatusesInternal nvarchar(max) = null,
	@FundNumber nvarchar(10) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@ChronologicalScope nvarchar(100) = null,
	@ChronologicalScopeStartDate nvarchar(100) = null,
	@ChronologicalScopeEndDate nvarchar(100) = null
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	SET @RowsOfPage = 2147483647
	SET @Page = 1

	DECLARE @sql VARCHAR(MAX); 
	CREATE TABLE #temp (
				CountryCode nvarchar(255) NULL,
				Archive nvarchar(255) NULL,
				FundDescriptionLevel nvarchar(255) NULL,
				FundNumber nvarchar(255) NULL,
				FundTitle nvarchar(max) NULL,
				InventoryNumber nvarchar(255) NULL,
				InventoryDescriptionLevel nvarchar(255) NULL,
				[Status] nvarchar(255) NULL,
				AeCount int NULL,
				AeWithCharCount int NULL,
				LinearMeters decimal NULL,
				Mb decimal NULL
			);

	INSERT INTO #temp(
				CountryCode,
				Archive,
				FundDescriptionLevel,
				FundNumber,
				FundTitle,
				InventoryNumber,
				InventoryDescriptionLevel,
				[Status],
				AeCount,
				AeWithCharCount,
				LinearMeters,
				Mb
			)
	EXEC [sp_GetInventoryReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page,
		@ArchiveGids,
		@ArchiveInternal,
		@StatusGids,
		@StatusesInternal,
		@FundNumber,
		@RegisteredFrom,
		@RegisteredTo,
		@ChronologicalScope,
		@ChronologicalScopeStartDate,
		@ChronologicalScopeEndDate

	SET @sql = '
	SELECT TOP 1
		COUNT_BIG(t.InventoryNumber) as InventoryCount,
		CAST(SUM(t.AeCount) as bigint) as AeCount,
		CAST(SUM(t.AeWithCharCount) as bigint) as AeWithCharCount,
		CAST(SUM(t.LinearMeters) as decimal) as LinearMeters,
		CAST(SUM(t.Mb) as decimal) as Mb
		FROM #temp as t'

	--print @sql;
	EXEC (@sql);
END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryReportSummary]
	@LinkedServer nvarchar(50),
	@ResultType int,
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveInternal nvarchar(max) = null,
	@StatusGids nvarchar(10) = null,
	@StatusesInternal nvarchar(max) = null,
	@FundNumber nvarchar(10) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@ChronologicalScope nvarchar(100) = null,
	@ChronologicalScopeStartDate nvarchar(100) = null,
	@ChronologicalScopeEndDate nvarchar(100) = null
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	SET @RowsOfPage = 2147483647
	SET @Page = 1

	DECLARE @sql VARCHAR(MAX); 
	CREATE TABLE #temp (
				CountryCode nvarchar(255) NULL,
				Archive nvarchar(255) NULL,
				FundDescriptionLevel nvarchar(255) NULL,
				FundNumber nvarchar(255) NULL,
				FundTitle nvarchar(max) NULL,
				InventoryNumber nvarchar(255) NULL,
				InventoryDescriptionLevel nvarchar(255) NULL,
				[Status] nvarchar(255) NULL,
				AeCount int NULL,
				AeWithCharCount int NULL,
				LinearMeters decimal NULL,
				Mb decimal NULL
			);

	INSERT INTO #temp(
				CountryCode,
				Archive,
				FundDescriptionLevel,
				FundNumber,
				FundTitle,
				InventoryNumber,
				InventoryDescriptionLevel,
				[Status],
				AeCount,
				AeWithCharCount,
				LinearMeters,
				Mb
			)
	EXEC [sp_GetInventoryReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page,
		@ArchiveGids,
		@ArchiveInternal,
		@StatusGids,
		@StatusesInternal,
		@FundNumber,
		@RegisteredFrom,
		@RegisteredTo,
		@ChronologicalScope,
		@ChronologicalScopeStartDate,
		@ChronologicalScopeEndDate

	SET @sql = '
		SELECT TOP 1 COUNT_BIG(*) as TotalRows
		FROM #temp as t'

	--print @sql;
	EXEC (@sql);
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetPartialReceiptsPublicReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само -- 2 до момента не се използва !!!
	@PeriodGids nvarchar(max) = null,
	@FundArraysInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@TextDate nvarchar(2000) = null,
	@DateFrom nvarchar(100) = NULL,
	@DateTo nvarchar(100) = null
AS
BEGIN

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
	DECLARE @remoteQueryWhereClause VARCHAR(MAX) = '(''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
			AND fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 2)
			AND (''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'' OR cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2))
			AND (''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'' OR cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2))
			AND (''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '','')) OR fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '','')))
			AND (''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))
				OR EXISTS(SELECT 1 FROM [Archiving].[dbo].ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
			AND (''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))	
			AND (''' + COALESCE(@TextDate, 'null') + ''' = ''null'' OR fund.TextDate = ''' + COALESCE(@TextDate, 'null') + ''')
			AND (''' + COALESCE(@DateFrom, 'null') + ''' = ''null'' OR cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2))
			AND (''' + COALESCE(@DateTo, 'null') + ''' = ''null'' OR cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2))';

	declare @remoteQuery varchar(max) = 
		'SELECT
			COUNT(*) TotalFunds,
			sum(isnull(fund.InvetoryCount, 0)) TotalInventories,
			sum(isnull(fund.AECount, 0)) TotalArchiveEntities,
			sum(fund.LinearMeters) TotalLinearMeters,
			cast((select sum(sizes.Size) 
				from 
					(select (select sum(isnull(i.ByteLenght, 0)) 
						from Image i
						inner join Document_Modified d
						on i.DocumentGid = d.Gid
						where d.FundLGid = fund.LGid) as Size
						from [Archiving].[dbo].[Fund_Modified] fund
						WHERE ' + @remoteQueryWhereClause + '
					) sizes) * 0.000001 as decimal(10,2)) TotalSize
		FROM [Archiving].[dbo].Fund_Modified as fund
		WHERE ' + @remoteQueryWhereClause;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

 IF @ResultType = 1 OR @ResultType = 3
	BEGIN

	DECLARE @localQueryWhereClause VARCHAR(max) = '
		ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode = 4 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))';

	
	DECLARE @localQuery VARCHAR(max) = 
		'SELECT
			COUNT_BIG(*) TotalFunds,
			cast(sum(isnull(InventoryCount, 0)) as bigint) TotalInventories,
			cast(sum(isnull(ArchivalEntityCount, 0)) as bigint) TotalArchiveEntities,
			SUM(LinearMeters) TotalLinearMeters,
			cast((select sum(sizes.Size) 
				from 
					(select (select sum(isnull(d.Bytes, 0)) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as Size
						from Funds f
						WHERE ' + @localQueryWhereClause + '
					) sizes) as decimal(10, 2)) TotalSize -- въпреки че колоната се казва Bytes, тя съдържа MB, затова няма превръщане на мерните ед.
				FROM Funds f
				WHERE ' + @localQueryWhereClause;
				
   END

 declare @sql varchar(max);

  IF @ResultType = 1 OR @ResultType = 2
   BEGIN
	SET @sql = '
		DECLARE @remoteFundsTable TABLE ( 
			TotalFunds bigint NULL,
			TotalInventories bigint NULL,
			TotalArchiveEntities bigint NULL,
			TotalLinearMeters float NULL,
			TotalSize decimal NULL
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
		SELECT 
			sum(u.TotalFunds) as TotalFunds, 
			sum(u.TotalInventories) as TotalInventories, 
			sum(u.TotalArchiveEntities) as TotalArchiveEntities, 
			sum(round(isnull(u.TotalLinearMeters, 0),2)) as TotalLinearMeters,
			sum(isnull(u.TotalSize, 0)) as TotalSize
		FROM (
			SELECT * 
			FROM (
				SELECT *    
				FROM @remoteFundsTable
				UNION
				' +
				@localQuery + ') lf) u';	
   END


  IF @ResultType = 3 
   BEGIN
	SET @sql = @localQuery;
   END

	exec (@sql);

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetPartialReceiptsPublicReport] -- Fund_CP_Report
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само -- 2 до момента не се използва !!!
	@PeriodGids nvarchar(max) = null,
	@FundArraysInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@TextDate nvarchar(2000) = null,
	@DateFrom nvarchar(100) = NULL,
	@DateTo nvarchar(100) = null,
	@RowsOfPage int = 50,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

  IF @ResultType = 1 OR @ResultType = 2
   BEGIN
	 DECLARE @remoteQuery VARCHAR(MAX) = 
		'SELECT
			fund.Title,
			a.Name as Archive,
			fund.Number,
			convert(varchar, fund.CreationDate, 104) as CreationDate,
			fund.ImmediateSourceOfAcquisition,
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.TypeGid) as FundType,
			fund.DocumentProperties,
			fund.Note,
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.StatusGid) as FundStatus,
			(select Value + '';''
				from  Nomenclature n1
				inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
				where n1._retired=''3000-01-01'' 
					and on1._retired=''3000-01-01''
					and on1.FundGid = fund.Gid 
					and n1.Type=''MethodOfAcquisition''
				FOR XML path(''''), elements) as MethodOfAcquisition,
			fund.TextDate,
			(isnull(convert(varchar, StartDateDay) + ''.'', '''') + isnull(convert(varchar, StartDateMonth) + ''.'', '''') + isnull(convert(varchar, StartDateYear), '''')) as StartDate,
			(isnull(convert(varchar, fund.EndDateDay) + ''.'', '''') + isnull(convert(varchar, fund.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, fund.EndDateYear), '''')) as EndDate,
			fund.InvetoryCount as InventoryCount,
			fund.AECount,
			isnull(fund.LinearMeters, 0) as LinearMeters,
			fund.IntNumber,
			a.SortOrder
		FROM Fund_Modified as fund
		INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
		WHERE
			(''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
			AND fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 2)
			AND (''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'' OR cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2))
			AND (''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'' OR cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2))
			AND (''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '','')) OR fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '','')))
			AND (''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))
				OR EXISTS(SELECT 1 FROM [Archiving].[dbo].ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
			AND (''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
			AND (''' + COALESCE(@TextDate, 'null') + ''' = ''null'' OR fund.TextDate = ''' + COALESCE(@TextDate, 'null') + ''')
			AND (''' + COALESCE(@DateFrom, 'null') + ''' = ''null'' OR cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2))
			AND (''' + COALESCE(@DateTo, 'null') + ''' = ''null'' OR cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2))';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

   END

   IF @ResultType = 1 OR @ResultType = 3
    BEGIN
	 DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			f.Title,
			a.Name as Archive,
			f.Number,
			convert(varchar, f.CreatedOn, 104) as CreationDate,
			f.DocumentsProvider as ImmediateSourceOfAcquisition,
			(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
			f.DocumentsDescription as DocumentProperties,
			f.Notes as Note,
			(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as MethodOfAcquisition,
			f.ApproxmateChronologicalScope as TextDate,
			(isnull(convert(varchar, f.StartDateDay) + ''.'', '''') + isnull(convert(varchar, f.StartDateMonth) + ''.'', '''') + isnull(convert(varchar, f.StartDateYear), '''')) as StartDate,
			(isnull(convert(varchar, f.EndDateDay) + ''.'', '''') + isnull(convert(varchar, f.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, f.EndDateYear), '''')) as EndDate,
			cast(f.InventoryCount as bigint) as InventoryCount , 
			cast(f.ArchivalEntityCount as bigint) as AECount,
			isnull(f.LinearMeters, 0) as LinearMeters,
			f.NumberNumeric as IntNumber,
			a.SortOrder
		FROM Funds f
		INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
		WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 4 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = f.TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))';
    END   

  DECLARE @sql VARCHAR(MAX);

 IF @ResultType = 1 OR @ResultType = 2
   BEGIN
	SET @sql = '
		DECLARE @remoteFundsTable TABLE (
			Title nvarchar(MAX) NULL,
			Archive nvarchar(256) NOT NULL,
			Number nvarchar(256) NULL,
			CreationDate varchar(50) NULL,
			ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
			FundType nvarchar(MAX) NULL,
			DocumentProperties nvarchar(max) NULL,
			Note nvarchar(MAX) NULL,
			FundStatus nvarchar(MAX) NULL,
			MethodOfAcquisition nvarchar(MAX) NULL,
			TextDate nvarchar(256) NULL,
			StartDate varchar(256) NULL,
			EndDate varchar(50) NULL,
			InventoryCount bigint NULL,
			AECount bigint NULL,
			LinearMeters float NULL,
			IntNumber int null,
			SortOrder int null
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteFundsTable
		UNION
		' +
		@localQuery + '
		order by SortOrder, IntNumber,  Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';
   END

  IF @ResultType = 3
   BEGIN
    SET @sql = @localQuery+ '
		order by SortOrder, IntNumber,  Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; 
   END

	EXEC (@sql);
END
GO

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfRoughDocumentsReport]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null,
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@StatusGids nvarchar(10) = null,
	@StatusesInternal nvarchar(max) = null,
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
		order by CountryCode
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
		DECLARE @remoteQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
			SELECT
			''BG'' as CountryCode,
			(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = inv.ArchiveGid) as Archive,
			fund.Number as FundNumber,
			fund.Title as FundTitle,
			inv.CreatedOn as EntryDate,
			inv.Number as RoughInventoryNumber,
			inv.ImmediateSourceOfAcquisition as AcquisitionMethod,
			(SELECT Value FROM Nomenclature WHERE _retired = ''3000-01-01'' and Gid = inv.StatusGid) as [Status],
			round(isnull(cast(inv.LinearMeter as decimal(18,2)), 0),2) as LinearMeters,
			0.0 as Mb
			FROM Inventory as inv
			inner join Fund_Modified as fund on inv.FundLGid = fund.LGid
			join Nomenclature as n on inv.LevelOfDescriptionGid = n.Gid
			WHERE
			fund._retired = ''3000-01-01''
			AND inv._retired = ''3000-01-01''
			AND n.Code = 6
			AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (inv.TextDate = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
			AND ((''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' = ''null'') OR (cast(inv.StartDate as date) >= cast(''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' = ''null'') OR (cast(inv.EndDate as date) <= cast(''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(inv.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(inv.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR (inv.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))) OR (inv.ArchiveGid in (select element from dbo.SplitString(''' + @ArchiveGids + ''', '',''))))
			AND inv.LevelOfDescriptionGid in(
			2171, -- Inventory
			2172  -- InventoryRough
			)
		');
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		DECLARE @localQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
			SELECT
				''BG'' as CountryCode
				,a.[Name] as Archive
				,f.Number as FundNumber
				,f.Title as FundTitle
				,i.CreatedOn as EntryDate
				,i.Number as RoughInventoryNumber
				,i.AcquisitionMethodText as AcquisitionMethod
				,s.[Text] as [Status]
				,ROUND(ISNULL(CAST(i.LinearMeters as decimal(18,2)), 0), 2) as LinearMeters
				,ROUND(ISNULL(CAST(i.Bytes as decimal(18,2)), 0), 2) as Mb
		     FROM v_Inventories as i
		     JOIN [Archives] as a
		       ON i.ArchiveId = a.Id
		     JOIN v_Funds as f
		       ON i.FundSystemIdentifier = f.SystemIdentifier
		     JOIN N.InventoryDescriptionLevel as idl
		       ON i.DescriptionLevelCode = idl.Code
		     JOIN N.[Status] as s
		       ON i.StatusCode = s.Code
  FULL OUTER JOIN v_ArchivalEntities as ae
			   ON i.SystemIdentifier = ae.InventorySystemIdentifier
			WHERE idl.Code = 6
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveInternal  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal  + ''', '',''))) 
				OR (convert(varchar(4), i.StatusCode, 104) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0
						and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = f.TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
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
		 GROUP BY a.[Name], f.Number, f.[Title], i.Number, i.CreatedOn, i.AcquisitionMethodText, idl.[Text], s.[Text], i.SystemIdentifier, i.LinearMeters, i.Bytes
		');
	END

		IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				CountryCode nvarchar(255) NULL,
				Archive nvarchar(255) NULL,
				FundNumber nvarchar(255) NULL,
				FundTitle nvarchar(max) NULL,
				EntryDate varchar(50) NULL,
				RoughInventoryNumber nvarchar(255) NULL,
				AcquisitionMethod nvarchar(max) NULL,
				[Status] nvarchar(255) NULL,
				LinearMeters decimal NULL,
				Mb decimal NULL

			);

			INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteTable
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfRoughDocumentsReportCombined]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null,
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@StatusGids nvarchar(10) = null,
	@StatusesInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@ChronologicalScope nvarchar(100) = null,
	@ChronologicalScopeStartDate nvarchar(100) = null,
	@ChronologicalScopeEndDate nvarchar(100) = null
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	SET @RowsOfPage = 2147483647
	SET @Page = 1

	DECLARE @sql VARCHAR(MAX); 
	CREATE TABLE #temp (
				CountryCode nvarchar(255) NULL,
				Archive nvarchar(255) NULL,
				FundNumber nvarchar(255) NULL,
				FundTitle nvarchar(max) NULL,
				EntryDate varchar(50) NULL,
				RoughInventoryNumber nvarchar(255) NULL,
				AcquisitionMethod nvarchar(max) NULL,
				[Status] nvarchar(255) NULL,
				LinearMeters decimal NULL,
				Mb decimal NULL
			);

	INSERT INTO #temp(
				CountryCode,
				Archive,
				FundNumber,
				FundTitle,
				EntryDate,
				RoughInventoryNumber,
				AcquisitionMethod,
				[Status],
				LinearMeters,
				Mb
			)
	EXEC [sp_GetListOfRoughDocumentsReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page ,
		@ArchiveGids,
		@ArchiveInternal,
		@FundTypeGids,
		@FundTypesInternal,
		@IndustryIndexGids,
		@IndustryIndexesInternal,
		@MethodOfAcquisitionGids,
		@MethodsOfAcquisitionInternal,
		@StatusGids,
		@StatusesInternal,
		@RegisteredFrom,
		@RegisteredTo,
		@ChronologicalScope,
		@ChronologicalScopeStartDate,
		@ChronologicalScopeEndDate

	SET @sql = '
	SELECT TOP 1
		COUNT_BIG(t.FundNumber) as FundCount,
		COUNT_BIG(t.RoughInventoryNumber) as InventoryCount,
		CAST(SUM(t.LinearMeters) as decimal) as LinearMeters,
		CAST(SUM(t.Mb) as decimal) as Mb
		FROM #temp as t'

	--print @sql;
	EXEC (@sql);
END


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfRoughDocumentsReportSummary]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null,
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@StatusGids nvarchar(10) = null,
	@StatusesInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@ChronologicalScope nvarchar(100) = null,
	@ChronologicalScopeStartDate nvarchar(100) = null,
	@ChronologicalScopeEndDate nvarchar(100) = null
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	SET @RowsOfPage = 2147483647
	SET @Page = 1

	DECLARE @sql VARCHAR(MAX); 
	CREATE TABLE #temp (
				CountryCode nvarchar(255) NULL,
				Archive nvarchar(255) NULL,
				FundNumber nvarchar(255) NULL,
				FundTitle nvarchar(max) NULL,
				EntryDate varchar(50) NULL,
				RoughInventoryNumber nvarchar(255) NULL,
				AcquisitionMethod nvarchar(max) NULL,
				[Status] nvarchar(255) NULL,
				LinearMeters decimal NULL,
				Mb decimal NULL
			);

	INSERT INTO #temp(
				CountryCode,
				Archive,
				FundNumber,
				FundTitle,
				EntryDate,
				RoughInventoryNumber,
				AcquisitionMethod,
				[Status],
				LinearMeters,
				Mb
			)
	EXEC [sp_GetListOfRoughDocumentsReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page ,
		@ArchiveGids,
		@ArchiveInternal,
		@FundTypeGids,
		@FundTypesInternal,
		@IndustryIndexGids,
		@IndustryIndexesInternal,
		@MethodOfAcquisitionGids,
		@MethodsOfAcquisitionInternal,
		@StatusGids,
		@StatusesInternal,
		@RegisteredFrom,
		@RegisteredTo,
		@ChronologicalScope,
		@ChronologicalScopeStartDate,
		@ChronologicalScopeEndDate

	SET @sql = '
		SELECT TOP 1 COUNT_BIG(*) as TotalRows
		FROM #temp as t'

	--print @sql;
	EXEC (@sql);
END

GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetFundDataPublicReport] -- REPORT_8_27_Fund_Report от ИСДА
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null, 
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@TextDate nvarchar(2000) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@LGid nvarchar(max) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	declare @offset int = (@Page - 1) * @RowsOfPage;

  IF @ResultType = 1 OR @ResultType = 2
   BEGIN 
	declare @remoteQuery varchar(max) =  '
		SELECT
			fund.LGid as SystemId,
			fund.CreationAuthor,
			convert(nvarchar,fund.ModificationDate, 104) as ModificationDate,
			fund.ModificationAuthor,
			isnull(fund.LinearMeters, 0) as LinearMeters,
			fund.InvetoryCount as InventoryCount,
			fund.BoxesCount,
			fund.RuloniTubusiCount as StorageTubesCount,
			fund.AECount,
			fund.ExtentOther,
			fund.FundFormerNameChange,
			fund.FundFormerFunction,
			fund.FundFormerHistory,
			fund.ArchivalHistory,
			fund.ImmediateSourceOfAcquisition,
			fund.DocumentProperties,
			(
				select Value + '';''
				from  Nomenclature n1
				inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
				where n1._retired=''3000-01-01'' 
					and on1._retired=''3000-01-01''
					and on1.FundGid = fund.Gid 
					and n1.Type=''Originality''
				FOR XML path(''''), elements
			) as Originality,
			(
				select Value + '';''
				from  Nomenclature n1
				inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
				where n1._retired=''3000-01-01'' 
					and on1._retired=''3000-01-01''
					and on1.FundGid = fund.Gid 
					and n1.Type=''CreatingType''
				FOR XML path(''''), elements
			) as CreatingType,
			(
				select Value + '';''
				from  Nomenclature n1
				inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
				where n1._retired=''3000-01-01'' 
					and on1._retired=''3000-01-01''
					and on1.FundGid = fund.Gid 
					and n1.Type=''Language''
				FOR XML path(''''), elements
			) as [Language],
			fund.AccessConditions,
			fund.FindingAids,
			fund.RelatedUnits,
			a.Name as Archive,
			fund.Number,
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.TypeGid) as FundType,
			(
				select Value + '';''
				from  Nomenclature n1
				inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
				where n1._retired=''3000-01-01'' 
					and on1._retired=''3000-01-01''
					and on1.FundGid = fund.Gid 
					and n1.Type=''IndustryIndex''
				FOR XML path(''''), elements
			) as IndustryIndex,
			(
				select Value + '';''
				from  Nomenclature n1
				inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
				where n1._retired=''3000-01-01'' 
					and on1._retired=''3000-01-01''
					and on1.FundGid = fund.Gid 
					and n1.Type=''MethodOfAcquisition''
				FOR XML path(''''), elements
			) as MethodOfAcquisition,
			fund.TextDate,
			(isnull(convert(varchar, StartDateDay) + ''.'', '''') + isnull(convert(varchar, StartDateMonth) + ''.'', '''') + isnull(convert(varchar, StartDateYear), '''')) as StartDate,
			(isnull(convert(varchar, fund.EndDateDay) + ''.'', '''') + isnull(convert(varchar, fund.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, fund.EndDateYear), '''')) as EndDate,
			convert(varchar, fund.CreationDate, 104) as CreationDate,
			fund.Title,
			fund.Note,
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.StatusGid) as FundStatus,
			fund.IntNumber,
			a.SortOrder
		FROM Fund_Modified as fund
		INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
		WHERE
			((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
			AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) 
				OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) 
				OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) 
				OR EXISTS(SELECT 1 FROM [dbo].ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))	
			AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE(@TextDate, 'null') + '''))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@LGid, 'null') + ''' = ''null'') OR (fund.LGid in (SELECT Element from dbo.SplitString(''' + COALESCE(@LGid, 'null') + ''', '',''))))';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
  END

  IF @ResultType= 1 OR @ResultType = 3
   BEGIN
	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			f.Id as SystemId,
			(SELECT DisplayName FROM [AspNetUsers] u where u.Id = f.CreatedBy) as CreationAuthor,
			convert(nvarchar, f.UpdatedOn, 104) as ModificationDate,
			(SELECT top 1 DisplayName FROM [AspNetUsers] u where u.Id = f.UpdatedBy) as ModificationAuthor, -- тук слагам top 1, за да не дава грешка, че подзаявката има повече от 1 резултат - не видях причината за тази грешка				
			isnull(f.LinearMeters, 0) as LinearMeters,
			CAST(f.InventoryCount AS BIGINT) as InventoryCount ,
			NULL as BoxesCount,
			NULL as StorageTubesCount,
			CAST(f.ArchivalEntityCount AS BIGINT) as AECount,
			f.OtherMetrics as ExtentOther,
			f.FundCreatorTitleHistory as FundFormerNameChange,
			f.FundCreatorActivityHistory as FundFormerFunction,
			f.FundCreatorBiographicalHistory as FundFormerHistory,
			f.History as ArchivalHistory,
			f.DocumentsProvider as ImmediateSourceOfAcquisition,
			f.DocumentsDescription as DocumentProperties,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''ORIGINALITY'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as Originality,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''CREATION_METHOD'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as CreatingType,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''LANGUAGE'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as Language,
			f.DocumentsAccessDescription as AccessConditions,
			NULL as FindingAids,
			f.RelatedFunds as RelatedUnits,
			a.Name as Archive,
			f.Number,
			(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as FundType,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''INDUSTRY_TYPE'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as IndustryIndex,
			(select ValueCode + '';''
				from  NomenclatureValues nv
				where nv.EntityType=''fund'' 
					and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
					and nv.EntityId=f.Id
				FOR XML path(''''), elements) as MethodOfAcquisition,
			f.ApproxmateChronologicalScope as TextDate,
			(isnull(convert(varchar, f.StartDateDay) + ''.'', '''') + isnull(convert(varchar, f.StartDateMonth) + ''.'', '''') + isnull(convert(varchar, f.StartDateYear), '''')) as StartDate,
			(isnull(convert(varchar, f.EndDateDay) + ''.'', '''') + isnull(convert(varchar, f.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, f.EndDateYear), '''')) as EndDate,
			convert(varchar, f.CreatedOn, 104) as CreationDate,
			f.Title,
			f.Notes as Note,
			(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus,
			f.NumberNumeric as IntNumber,
			a.SortOrder
		FROM Funds f
		INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
		WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
			AND f.DescriptionLevelCode = 1 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
				) 
			)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
				OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
					and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
				) 
			)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = f.TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))';

   END

    DECLARE @sql VARCHAR(MAX);

    IF @ResultType = 1 
	 BEGIN
	  SET @sql = '
		DECLARE @remoteFundsTable TABLE (
			SystemId int NOT NULL,
			CreationAuthor nvarchar(256) NULL,
			ModificationDate varchar(50) NULL,
			ModificationAuthor nvarchar(256) NULL,
			LinearMeters float NULL,
			InventoryCount bigint NULL, 
			BoxesCount int NULL,
			StorageTubesCount int NULL,	
			AECount bigint NULL,
			ExtentOther nvarchar(256) NULL,
			FundFormerNameChange nvarchar(MAX) NULL,
			FundFormerFunction nvarchar(MAX) NULL,
			FundFormerHistory nvarchar(MAX) NULL,
			ArchivalHistory nvarchar(MAX) NULL,
			ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
			DocumentProperties nvarchar(max) NULL,
			Originality nvarchar(2000) NULL,
			CreatingType nvarchar(2000) NULL,
			Language nvarchar(2000) NULL,
			AccessConditions nvarchar(MAX) NULL,
			FindingAids nvarchar(2000) NULL,
			RelatedUnits nvarchar(MAX) NULL,
			Archive nvarchar(256) NOT NULL,
			Number nvarchar(256) NULL,
			FundType nvarchar(MAX) NULL,
			IndustryIndex nvarchar(MAX) NULL,
			MethodOfAcquisition nvarchar(MAX) NULL,
			TextDate nvarchar(256) NULL,
			StartDate varchar(256) NULL,
			EndDate varchar(50) NULL,
			CreationDate varchar(50) NULL,
			Title nvarchar(MAX) NULL,
			Note nvarchar(MAX) NULL,
			FundStatus nvarchar(MAX) NULL,
			IntNumber int null,
			SortOrder int null
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteFundsTable
		UNION
		' +
		@localQuery + '
		order by SortOrder, IntNumber, Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';
     END
  IF @ResultType = 3
   BEGIN
    SET @sql = @localQuery + 'order by SortOrder, IntNumber, Number asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';
   END

	--print @sql;
	EXEC (@sql);

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetFundDataPublicReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null, 
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@TextDate nvarchar(2000) = null,
	@DateFrom nvarchar(100) = NULL,
	@DateTo nvarchar(100) = null,
	@LGid nvarchar(max) = null
AS
BEGIN
  IF @ResultType = 1 OR @ResultType = 2
   BEGIN 
	declare @remoteQuery varchar(max) = 
		'SELECT
			COUNT(*) TotalFunds,
			sum(isnull(fund.InvetoryCount, 0)) TotalInventories,
			sum(isnull(fund.AECount, 0)) TotalArchiveEntities,
			sum(fund.LinearMeters) TotalLinearMeters
		FROM Fund_Modified as fund
		WHERE
			((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
			AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) 
				OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) 
				OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) 
				OR EXISTS(SELECT 1 FROM [dbo].ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '',''))) OR fund.StatusGid in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
			AND ((''' + COALESCE(@TextDate, 'null') + ''' = ''null'') OR (fund.TextDate = ''' + COALESCE(@TextDate, 'null') + '''))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@LGid, 'null') + ''' = ''null'') OR (fund.LGid in (SELECT Element from dbo.SplitString(''' + COALESCE(@LGid, 'null') + ''', '',''))))';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
  END

  IF @ResultType = 1 OR @ResultType = 3
   BEGIN
	DECLARE @localQuery VARCHAR(max) = 
		'SELECT
			COUNT_BIG(*) TotalFunds,
			cast(sum(isnull(InventoryCount, 0)) as bigint) TotalInventories,
			cast(sum(isnull(ArchivalEntityCount, 0)) as bigint) TotalArchiveEntities,
			cast(SUM(LinearMeters) as decimal(10,2)) TotalLinearMeters
			FROM Funds f
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND DescriptionLevelCode = 1 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexesInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''INDUSTRY_TYPE'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @IndustryIndexesInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal  + ''', '',''))) 
					OR ((select count(Id) from NomenclatureValues nv where nv.EntityId = f.Id and nv.NomenclatureCode = ''ACQUISITION_METHOD'' and nv.deleted = 0  -- тук излезе, че е задължително да има f. пред Id, иначе не работи правилно
						and nv.ValueCode in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) = (select count(element) from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))
					) 
				)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))';
    END

  declare @sql varchar(max);

  IF @ResultType = 1 
   BEGIN
	SET @sql = '
		DECLARE @remoteFundsTable TABLE ( 
			TotalFunds bigint NULL,
			TotalInventories bigint NULL,
			TotalArchiveEntities bigint NULL,
			TotalLinearMeters float NULL
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
		SELECT sum(u.TotalFunds) as TotalFunds, sum(u.TotalInventories) as TotalInventories, sum(u.TotalArchiveEntities) as TotalArchiveEntities, sum(round(isnull(cast(u.TotalLinearMeters as decimal(18,2)), 0),2)) as TotalLinearMeters 
		FROM (
			SELECT * 
			FROM (
				SELECT *    
				FROM @remoteFundsTable
				UNION
				' +
				@localQuery + ') lf) u';	
   END

   IF @ResultType = 3
    BEGIN
	 SET @sql = @localQuery;
	END
 --print @sql;
	exec (@sql);
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[GetRegisterOfDigitalObjectsPublicReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@RegisteredFrom nvarchar(100) = NULL,
	@RegisteredTo nvarchar(100) = null,
	@DocLGid nvarchar(max) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
	
AS
BEGIN
SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

  IF @ResultType = 1 OR @ResultType = 2
   BEGIN
	DECLARE @remoteQuery VARCHAR(MAX) = 
		'SELECT
			(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = (SELECT LevelOfDescriptionGid from Fund_Modified f where f.LGid = doc.FundLGid)) as LevelOfDescription,
			''http://212.122.187.196:84/Process.aspx?type=Document&agid='' + cast(doc.ArchiveGid as nvarchar(255)) + ''&flgid='' + cast(doc.FundLGid as nvarchar(255)) + ''&ilgid='' + cast(doc.InventoryLGid as nvarchar(255)) + ''&aelgid='' + cast(doc.AELGid as nvarchar(255)) + ''&dlgid=''+ cast(doc.LGid as nvarchar(255)) as DocumentLink,
			a.Name as ArchiveName,
			(select CAST(Code as nvarchar(10)) from archive where _retired = ''3000-01-01'' and Gid = doc.ArchiveGid) ArchiveCode,
			doc.LGid as SystemId,
			(SELECT TOP 1 Number from Fund_Modified f where f.LGid = doc.FundLGid) as FundNumber,
			(SELECT Number from Inventory_Modified i where i.LGid = doc.InventoryLGid) as InventoryNumber,
			(SELECT Number from ArchiveEntity_Modified ae where ae.LGid = doc.AELGid) as ArchiveEntityNumber,
			(
				select ln1.ListFrom + '' - '' + ln1.ListTo + ''; ''
				from  ListNumber ln1	
				where ln1._retired=''3000-01-01'' and ln1.DocumentGid = doc.Gid 
				FOR XML path(''''), elements
			) as ListNumbers,
			doc.Title as DocumentTitle,
			doc.TextDate as ChronologicalScope,
			--(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = doc.StatusGid) as DocStatus, -- отпада по искане на ДАА
			convert(varchar, doc.DOCreationDate, 104) as DigitalObjectCreationDate,
			COUNT(img.Gid) as ImageCount,
			SUM(isnull(img.ByteLenght, 0)) as BytesCount,
			--case when isnull(DigitalObjectDeleted, 0) = 0 then ''Активен'' else ''Заличен'' end as DigitalObjectStatus, -- отпада по искане на ДАА
			--(
				--select convert(varchar, max(p.ModifiedOn), 104)  
				--from Document d
				--inner join Process p on p._retired = ''3000-01-01'' and p.Gid = d.ProcessGid and p.TypeGid = 2124 and p.StepGid = 75
				--where  d.LGid = doc.lgid
			--) as ModifiedOn,  -- отпада по искане на ДАА
			(SELECT TOP 1 IntNumber from Fund_Modified f where f.LGid = doc.FundLGid) as FundIntNumber,
			(SELECT IntNumber from Inventory_Modified i where i.LGid = doc.InventoryLGid) as InventoryIntNumber,
			(SELECT IntNumber from ArchiveEntity_Modified ae where ae.LGid = doc.AELGid) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder
		FROM
			Document_Active doc -- в ИСДА ползват Document_Active за тази справка
			INNER JOIN Archive a ON a.Gid = doc.ArchiveGid AND a._retired = ''3000-01-01''
			LEFT OUTER JOIN [Image] img ON doc.Gid = img.DocumentGid AND img._retired = ''3000-01-01''
		WHERE
			ISNULL(doc.HasDigitalObject, 0) = 1
			AND (''' + COALESCE(@DocLGid, 'null') + ''' = ''null'' OR doc.LGid = ''' + COALESCE(@DocLGid, 'null') + ''')
			AND (''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'' OR cast(doc.DOCreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2))
			AND (''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'' OR cast(doc.DOCreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2))
			AND ((''active'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1 and isnull(DigitalObjectDeleted, 0) = 0))
				OR (''deleted'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1 and isnull(DigitalObjectDeleted, 0) = 1))
				OR (''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
		group by 
		doc.LGid, 
		doc.ArchiveGid, 
		doc.CreationDate, 
		doc.Title, 
		doc.StatusGid, 
		doc.DigitalObjectDeleted, 
		doc.DigitalObjectDeleted, 
		doc.DOCreationDate, 
		doc.FundLGid, 
		doc.InventoryLGid, 
		doc.AELGid, 
		doc.Gid,
		doc.StartDateDay,
		doc.StartDateMonth,
		doc.StartDateYear,
		doc.EndDateDay,
		doc.EndDateMonth,
		doc.EndDateYear,
		doc.TextDate,
		a.Name,
		a.SortOrder';
   
	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

   END

  IF @ResultType = 1 OR @ResultType = 3
   BEGIN
	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			--(SELECT Text FROM [N].[DocumentDescriptionLevel] dl where dl.Code = DescriptionLevelCode) as LevelOfDescription,
			(SELECT Text FROM [N].[FundDescriptionLevel] fdl where fdl.Code = (SELECT DescriptionLevelCode FROM Funds f where f.SystemIdentifier = do.FundSystemIdentifier)) as LevelOfDescription,
			'''' as DocumentLink,
			a.Name as ArchiveName,
			a.Code as ArchiveCode,
			do.Id as SystemId,
			(SELECT Number FROM Funds f where f.SystemIdentifier = do.FundSystemIdentifier) as FundNumber,
			(SELECT Number FROM Inventories i where i.SystemIdentifier = do.InventorySystemIdentifier) as InventoryNumber,
			(SELECT Number FROM ArchivalEntities ae where ae.SystemIdentifier = do.ArchivalEntitySystemIdentifier) as ArchiveEntityNumber,
			(CAST(d.StartSheetNumber AS nvarchar(50)) + '' - '' + CAST(d.EndSheetNumber AS nvarchar(50))) as ListNumbers, -- различава се от ИСДА; има ли нужда от таква стойност в СЕА?
			d.Title as DocumentTitle,
			d.ApproxmateChronologicalScope as ChronologicalScope,
			-- (SELECT Text FROM [N].[Status] s where s.Code = StatusCode) as DocStatus, -- отпада по искане на ДАА
			convert(varchar, do.CreatedOn, 104) as DigitalObjectCreationDate,
			NULL as ImageCount, -- нямаме снимки при нас
			NULL as BytesCount, -- липсва колна в таблица DigitalObjects, трябва да се добави
			-- NULL as DigitalObjectStatus, -- отпада по искане на ДАА
			-- convert(nvarchar,UpdatedOn, 104) as ModifiedOn, -- отпада по искане на ДАА
			(SELECT NumberNumeric FROM Funds f where f.SystemIdentifier = do.FundSystemIdentifier) as FundIntNumber,
			(SELECT NumberNumeric FROM Inventories i where i.SystemIdentifier = do.InventorySystemIdentifier) as InventoryIntNumber,
			(SELECT NumberNumeric FROM ArchivalEntities ae where ae.SystemIdentifier = do.ArchivalEntitySystemIdentifier) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder 
		FROM DigitalObjects do
		INNER JOIN Archives a ON a.Id = do.ArchiveId AND a.Deleted = 0
		INNER JOIN Documents d ON d.SystemIdentifier = do.DocumentSystemIdentifier AND do.Deleted = 0
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
				AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
				AND do.TypeCode = 1 -- master
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				--AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					--OR ((select convert(varchar(4), Code, 104) from N.DocumentStatus s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))';
   END

  DECLARE @sql VARCHAR(MAX);

  IF @ResultType = 1
    BEGIN
	 SET @sql = '
		DECLARE @remoteFundsTable TABLE (
			LevelOfDescription nvarchar(MAX) NULL,
			DocumentLink nvarchar(MAX) NULL,
			ArchiveName nvarchar(256) NOT NULL,
			ArchiveCode int NOT NULL,
			SystemId int NOT NULL,
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchiveEntityNumber nvarchar(256) NULL,
			ListNumbers nvarchar(MAX) NULL,
			DocumentTitle nvarchar(MAX) NULL,
			ChronologicalScope nvarchar(256) NULL, 
			-- DocStatus nvarchar(MAX) NULL, -- отпада по искане на ДАА
			DigitalObjectCreationDate nvarchar(50) NULL,
			ImageCount bigint NULL,
			BytesCount bigint NULL,
			-- DigitalObjectStatus nvarchar(50) NULL, -- отпада по искане на ДАА
			-- ModifiedOn varchar(50) NULL, -- отпада по искане на ДАА
			FundIntNumber int null,
			InventoryIntNumber int null,
			ArchivalEntityIntNumber int null,
			ArchiveSortOrder int null
		);

		INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteFundsTable
		UNION
		' +
		@localQuery + '
		order by ArchiveSortOrder, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchivalEntityIntNumber, ArchiveEntityNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';
   END

  IF @ResultType = 3
   BEGIN
    SET @sql = @localQuery + '
		order by ArchiveSortOrder, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchivalEntityIntNumber, ArchiveEntityNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';
   END

  EXEC (@sql);

END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetRegisterOfDigitalObjectsPublicReportSummary] 
	@LinkedServer nvarchar(50),
    @ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@StatusGids nvarchar(max) = null,
	@StatusesInternal nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@RegisteredFrom nvarchar(100) = NULL,
	@RegisteredTo nvarchar(100) = null,
	@DocLGid nvarchar(max) = null
	
AS
BEGIN
  
  IF @ResultType = 1 OR @ResultType = 2
   BEGIN
	DECLARE @remoteQuery VARCHAR(MAX) = 
		'SELECT
			COUNT(*) TotalRows,
			SUM(isnull(x.BytesCount, 0)) as TotalBytesCount,
			sum(isnull(x.ImageCount, 0)) as TotalImageCount,
			sum(isnull(x.DOs, 0)) as TotalDOs
			FROM
			(
				SELECT 
					SUM(isnull(img.ByteLenght, 0)) as BytesCount,
					COUNT(img.Gid) as ImageCount,
					COUNT(distinct doc.LGid) as DOs
				FROM
					Document_Active doc -- в ИСДА ползват Document_Active за тази справка
					left outer join [Image] img on doc.Gid = img.DocumentGid and img._retired = ''3000-01-01''
				WHERE
					ISNULL(doc.HasDigitalObject, 0) = 1
					AND (''' + COALESCE(@DocLGid, 'null') + ''' = ''null'' OR doc.LGid = ''' + COALESCE(@DocLGid, 'null') + ''')
					AND (''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'' OR cast(doc.DOCreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2))
					AND (''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'' OR cast(doc.DOCreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2))
					AND ((''active'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1 and isnull(DigitalObjectDeleted, 0) = 0))
						OR (''deleted'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1 and isnull(DigitalObjectDeleted, 0) = 1))
						OR (''-999'' in (select element from dbo.SplitString(''' + @StatusGids + ''', '','')) and exists(select 1 from Document d1 where d1.LGid = doc.LGid and d1._retired = ''3000-01-01'' and d1.RowStatusGid = 71 and d1.HasDigitalObject = 1)))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=doc.ArchiveGid) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
					group by doc.LGid, doc.ArchiveGid, doc.CreationDate, doc.Title, doc.StatusGid, doc.DigitalObjectDeleted, doc.DigitalObjectDeleted, doc.DOCreationDate
				) x';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
   END

  IF @ResultType = 1 OR @ResultType = 3
   BEGIN
	-- todo: ипзолзвай реалните колони
	DECLARE @localQuery VARCHAR(max) = 
		'SELECT
			COUNT_BIG(*) TotalRows,
			COUNT_BIG(d.Bytes) AS TotalBytesCount,
			CAST(0 AS BIGINT) AS TotalImageCount ,
			CAST((select count(*) from DocumentDigitalObjects do where exists(select * from DocumentDigitalObjects do where 4 = do.DocumentId)) AS BIGINT) AS TotalDOs
		FROM Documents d
		WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
			AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
   END

  declare @sql varchar(max);

  IF @ResultType = 1
    BEGIN
	 SET @sql = '
		DECLARE @remoteTable TABLE ( 
			TotalRows bigint NULL,
			TotalBytesCount bigint NULL,
			TotalImageCount bigint NULL,
			TotalDOs bigint NULL
		);

		INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
		SELECT sum(u.TotalRows) as TotalRows, sum(u.TotalBytesCount) as TotalBytesCount, sum(u.TotalImageCount) as TotalImageCount, sum(u.TotalDOs) as TotalDOs 
		FROM (
			SELECT * 
			FROM (
				SELECT *    
				FROM @remoteTable
				UNION
				' +
				@localQuery + ') lf) u';
    END

  IF @ResultType = 3
    BEGIN
	 SET @sql = @localQuery;
	END

  --print @sql;
  exec (@sql);

END
GO




update N.ProcessSteps
set AllowTaskTemplate = 1
where Id = 1009
go



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetFundMemoriesListReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(10) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by SortOrder, IntNumber, Number
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	DECLARE @methodOfAcquisitionQueryRemote VARCHAR(MAX) = '
		(
			select Value + '';''
			from  Nomenclature n1
			inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
			where n1._retired=''3000-01-01'' 
				and on1._retired=''3000-01-01''
				and on1.FundGid = fund.Gid 
				and n1.Type=''MethodOfAcquisition''
			FOR XML path(''''), elements
		)';
	DECLARE @methodOfAcquisitionQueryLocal VARCHAR(MAX) = '
		(
			select ValueCode + '';''
			from  NomenclatureValues nv
			where nv.EntityType=''fund'' 
				and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
				and nv.EntityId=Id
			FOR XML path(''''), elements
		)';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				COALESCE(
					fund.ImmediateSourceOfAcquisition + '' / '' + ' + @methodOfAcquisitionQueryRemote +  ', 
					fund.ImmediateSourceOfAcquisition + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryRemote + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				(select Value + '';''
					from Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.FundGid = fund.Gid 
						and n1.Type=''CreatingType''
					FOR XML path(''''), elements) as CreatingType,
				isnull(fund.LinearMeters, 0),
				null as DigitalSize,
				fund.Note,
				fund.IntNumber,
				a.SortOrder
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3)';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreatedOn, 104) as CreationDate,
				COALESCE(
					fund.DocumentsProvider + '' / '' + ' + @methodOfAcquisitionQueryLocal +  ', 
					fund.DocumentsProvider + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryLocal + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				(select ValueCode + '';''
					from  NomenclatureValues nv
					where nv.EntityType=''fund'' 
						and nv.NomenclatureCode = ''CREATION_METHOD'' 
						and nv.EntityId=fund.Id
					FOR XML path(''''), elements) as CreatingType,
				isnull(fund.LinearMeters, 0) as LinearMeters ,
				fund.Bytes as DigitalSize, -- реално е MB, името на колоната трябва да се смени
				fund.Notes as Note,
				fund.NumberNumeric as IntNumber,
				a.SortOrder
			FROM Funds fund 
			INNER JOIN Archives a ON a.Id = ArchiveId AND a.Deleted = 0
			WHERE fund.ExternalIdentifier IS NULL AND fund.HasExternalSource = 0 AND fund.Deleted = 0 
				AND DescriptionLevelCode = 3 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				CreationDate varchar(50) NULL,
				ImmediateSourceOfAcquisitionPlusMethodOfAcquisition nvarchar(MAX) NULL,
				Title nvarchar(MAX) NULL,
				CreatingType nvarchar(2000) NULL,
				LinearMeters float NULL,
				DigitalSize bigint NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null,
				SortOrder int null
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

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetDigitalDocumentsUsageReport] 
	@LinkedServer nvarchar(50),
	@Statuses nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @condition VARCHAR(MAX) = '
		INNER JOIN Archives a ON a.Id = do.ArchiveId AND a.Deleted = 0
		INNER JOIN Funds f ON f.SystemIdentifier = do.FundSystemIdentifier
		INNER JOIN Inventories i ON i.SystemIdentifier = do.InventorySystemIdentifier
		INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = do.ArchivalEntitySystemIdentifier
		INNER JOIN Documents d ON d.SystemIdentifier = do.DocumentSystemIdentifier AND d.StatusCode <> ''12''-- 12 - отчислени
		INNER JOIN DigitalObjectReviews dor ON dor.DigitalObjectSystemIdentifier = do.SystemIdentifier
		LEFT JOIN AspNetUsers e ON e.Id = dor.UserSystemIdentifier AND e.UserProfileType =''EMP''
		LEFT JOIN AspNetUsers r ON r.Id = dor.UserSystemIdentifier AND r.UserProfileType = ''RRR''
		LEFT JOIN [N].[FundDescriptionLevel] fdl ON f.DescriptionLevelCode = fdl.Code
		WHERE do.ExternalIdentifier IS NULL AND do.HasExternalSource = 0 AND do.Deleted = 0 AND do.StatusCode <> ''12''-- 12 - отчислени
			AND (e.UserProfileType IS NOT NULL OR r.UserProfileType IS NOT NULL)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(dor.Date as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(dor.Date as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
	';

	DECLARE @condition1 VARCHAR(MAX) = '
		INNER JOIN Archives a1 ON a1.Id = do1.ArchiveId AND a1.Deleted = 0
		INNER JOIN Funds f1 ON f1.SystemIdentifier = do1.FundSystemIdentifier
		INNER JOIN ArchivalEntities ae1 ON ae1.SystemIdentifier = do1.ArchivalEntitySystemIdentifier
		INNER JOIN Documents d1 ON d1.SystemIdentifier = do1.DocumentSystemIdentifier AND d1.StatusCode <> ''12''-- 12 - отчислени
		INNER JOIN DigitalObjectReviews dor1 ON dor1.DigitalObjectSystemIdentifier = do1.SystemIdentifier
		LEFT JOIN AspNetUsers e1 ON e1.Id = dor1.UserSystemIdentifier AND e1.UserProfileType =''EMP''
		LEFT JOIN AspNetUsers r1 ON r1.Id = dor1.UserSystemIdentifier AND r1.UserProfileType = ''RRR''
		LEFT JOIN [N].[FundDescriptionLevel] fdl1 ON f1.DescriptionLevelCode = fdl1.Code
		WHERE do1.ExternalIdentifier IS NULL AND do1.HasExternalSource = 0 AND do1.Deleted = 0 AND do1.StatusCode <> ''12''-- 12 - отчислени
			AND f.SystemIdentifier = do1.FundSystemIdentifier
			AND (e1.UserProfileType IS NOT NULL OR r1.UserProfileType IS NOT NULL)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a1.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f1.StatusCode) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(dor1.Date as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(dor1.Date as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
	';

	DECLARE @sql VARCHAR(MAX) = 
		'SELECT
			a.Name AS Archive,
			convert(varchar(50), d.SystemIdentifier, 104) AS DocumentSystemIdentifier,
			f.DescriptionLevelCode AS FundDescriptionLevelCode,
			f.Number AS FundNumber,
			i.Number AS InventoryNumber,
			ae.Number AS ArchivalEntityNumber,
			convert(varchar, dor.Date, 104) AS UsageDate,
			e.UserName AS Employee,
			r.UserName AS Reader,
			(
				SELECT COUNT(*) FROM 
				(
					SELECT ae1.SystemIdentifier FROM DigitalObjects do1	
					' + @condition1 + '
					GROUP BY ae1.SystemIdentifier
				) t
			) AS ArchivalEntitiesOfFundCount,
			(
				SELECT COUNT(*) FROM 
				(
					SELECT d1.SystemIdentifier FROM DigitalObjects do1	
					' + @condition1 + '
					GROUP BY d1.SystemIdentifier
				) t
			) AS DocumentsOfFundCount,
			--xxx AS Size, -- тук трябва да се съхраняват MB - тази колона предстои да се добави, 
			--xxx AS TotalDurationPerFund,  - тази колона не може за момента да се добави, 
			f.NumberNumeric AS FundIntNumber,
			i.NumberNumeric AS InventoryIntNumber,
			ae.NumberNumeric AS ArchivalEntityIntNumber,
			d.Number AS DocumentNumber,
			a.SortOrder AS ArchiveSortOrder
			--,do.SystemIdentifier AS DOSystemIdentifier
			--,d.SystemIdentifier AS DocSystemIdentifier
			--,ae.SystemIdentifier AS AESystemIdentifier
			--,f.SystemIdentifier AS FundSystemIdentifier
		FROM DigitalObjects do
		' + @condition + '
		ORDER BY ArchiveSortOrder, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchivalEntityIntNumber, ArchivalEntityNumber, DocumentNumber ASC
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY
	';

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetDigitalDocumentsUsageReportSummary] 
	@LinkedServer nvarchar(50),
	@Statuses nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @employee VARCHAR(MAX) = '
		INNER JOIN AspNetUsers upt ON upt.Id = dor.UserSystemIdentifier AND upt.UserProfileType =''EMP''
	';
	DECLARE @reader VARCHAR(MAX) = '
		INNER JOIN AspNetUsers upt ON upt.Id = dor.UserSystemIdentifier AND upt.UserProfileType = ''RRR''
	';

	DECLARE @condition VARCHAR(MAX) = '
		INNER JOIN Archives a ON a.Id = do.ArchiveId AND a.Deleted = 0
		INNER JOIN Funds f ON f.SystemIdentifier = do.FundSystemIdentifier
		INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = do.ArchivalEntitySystemIdentifier
		INNER JOIN Documents d ON d.SystemIdentifier = do.DocumentSystemIdentifier AND d.StatusCode <> ''12''-- 12 - отчислени
		INNER JOIN DigitalObjectReviews dor ON dor.DigitalObjectSystemIdentifier = do.SystemIdentifier
		UserTypeCondition
		WHERE do.ExternalIdentifier IS NULL AND do.HasExternalSource = 0 AND do.Deleted = 0 AND do.StatusCode <> ''12''-- 12 - отчислени
			AND (upt.UserProfileType IS NOT NULL OR upt.UserProfileType IS NOT NULL)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(dor.Date as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(dor.Date as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
	';

	DECLARE @userTypeEmployeeCondition VARCHAR(MAX) = REPLACE(@condition, 'UserTypeCondition', @employee);
	DECLARE @userTypeReaderCondition VARCHAR(MAX) = REPLACE(@condition, 'UserTypeCondition', @reader);

	DECLARE @sql VARCHAR(max) = '
		DECLARE @result TABLE (
			RowType NVARCHAR(50),
			FundsCount INT null,
			ArchivalEntitiesOfFundCount INT null,
			DocumentsOfFundCount INT null
		);

		INSERT INTO @result  
			SELECT * FROM 
			(
				SELECT 
					(select ''Служител'') AS RowType,
					(
						SELECT COUNT(*) FROM 
						(
							SELECT f.SystemIdentifier FROM DigitalObjects do		
							' + @userTypeEmployeeCondition + '
							GROUP BY f.SystemIdentifier
						) t
					) AS FundsCount,
					(
						SELECT COUNT(*) FROM 
						(
							SELECT ae.SystemIdentifier FROM DigitalObjects do		
							' + @userTypeEmployeeCondition + '
							GROUP BY ae.SystemIdentifier
						) t
					) AS ArchivalEntitiesOfFundCount,
					(
						SELECT COUNT(*) FROM 
						(
							SELECT d.SystemIdentifier FROM DigitalObjects do		
							' + @userTypeEmployeeCondition + ' 
							GROUP BY d.SystemIdentifier
						) t
					) AS DocumentsOfFundCount--,
					-- Size - засега няма такава колона 
			) t1;

		INSERT INTO @result  
			SELECT * FROM 
			(
				SELECT 
					(select ''Читател'') AS RowType,
					(
						SELECT COUNT(*) FROM 
						(
							SELECT f.SystemIdentifier FROM DigitalObjects do		
							' + @userTypeReaderCondition + '
							GROUP BY f.SystemIdentifier
						) t
					) AS FundsCount,
					(
						SELECT COUNT(*) FROM 
						(
							SELECT ae.SystemIdentifier FROM DigitalObjects do		
							' + @userTypeReaderCondition + '
							GROUP BY ae.SystemIdentifier
						) t
					) AS ArchivalEntitiesOfFundCount,
					(
						SELECT COUNT(*) FROM 
						(
							SELECT d.SystemIdentifier FROM DigitalObjects do		
							' + @userTypeReaderCondition + ' 
							GROUP BY d.SystemIdentifier
						) t
					) AS DocumentsOfFundCount--,
					-- Size - засега няма такава колона 
			) t2;

		INSERT INTO @result  
			SELECT * FROM 
			(
				SELECT 
					(select ''Общо'') AS RowType,
					(
						SELECT SUM(FundsCount) FROM (SELECT FundsCount FROM @result) ft
					) AS FundsCount,
					(
						SELECT SUM(ArchivalEntitiesOfFundCount) FROM (SELECT ArchivalEntitiesOfFundCount FROM @result) aet
					) AS ArchivalEntitiesOfFundCount,
					(
						SELECT SUM(DocumentsOfFundCount) FROM (SELECT DocumentsOfFundCount FROM @result) dt
					) AS DocumentsOfFundCount--,
					-- Size - засега няма такава колона 
			) t3;

		SELECT * FROM @result;
	';

	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetDigitalDocumentsUsageReportTotalRows] 
	@LinkedServer nvarchar(50),
	@Statuses nvarchar(max) = null,
	@ArchiveCodes nvarchar(10) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(max) = '
		SELECT
			COUNT_BIG(*) TotalRows
		FROM DigitalObjects do
		INNER JOIN Archives a ON a.Id = do.ArchiveId AND a.Deleted = 0
		INNER JOIN Funds f ON f.SystemIdentifier = do.FundSystemIdentifier
		INNER JOIN Inventories i ON i.SystemIdentifier = do.InventorySystemIdentifier
		INNER JOIN ArchivalEntities ae ON ae.SystemIdentifier = do.ArchivalEntitySystemIdentifier
		INNER JOIN Documents d ON d.SystemIdentifier = do.DocumentSystemIdentifier AND d.StatusCode <> ''12''-- 12 - отчислени
		INNER JOIN DigitalObjectReviews dor ON dor.DigitalObjectSystemIdentifier = do.SystemIdentifier
		LEFT JOIN AspNetUsers e ON e.Id = dor.UserSystemIdentifier AND e.UserProfileType =''EMP''
		LEFT JOIN AspNetUsers r ON r.Id = dor.UserSystemIdentifier AND r.UserProfileType = ''RRR''
		LEFT JOIN [N].[FundDescriptionLevel] fdl ON f.DescriptionLevelCode = fdl.Code
		WHERE do.ExternalIdentifier IS NULL AND do.HasExternalSource = 0 AND do.Deleted = 0 AND do.StatusCode <> ''12''-- 12 - отчислени
			AND (e.UserProfileType IS NOT NULL OR r.UserProfileType IS NOT NULL)
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = f.StatusCode) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
			AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') OR (cast(dor.Date as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') OR (cast(dor.Date as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))
	';

	exec (@sql);
END
GO



SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetReceiptsListReport] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(max) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by SortOrder, IntNumber, Number
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	DECLARE @methodOfAcquisitionQueryRemote VARCHAR(MAX) = '
		(
			select Value + '';''
			from  Nomenclature n1
			inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
			where n1._retired=''3000-01-01'' 
				and on1._retired=''3000-01-01''
				and on1.FundGid = fund.Gid 
				and n1.Type=''MethodOfAcquisition''
			FOR XML path(''''), elements
		)';
	DECLARE @methodOfAcquisitionQueryLocal VARCHAR(MAX) = '
		(
			select ValueCode + '';''
			from  NomenclatureValues nv
			where nv.EntityType=''fund'' 
				and nv.NomenclatureCode = ''ACQUISITION_METHOD'' 
				and nv.EntityId=Id
			FOR XML path(''''), elements
		)';

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN	
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				COALESCE(
					fund.ImmediateSourceOfAcquisition + '' / '' + ' + @methodOfAcquisitionQueryRemote +  ', 
					fund.ImmediateSourceOfAcquisition + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryRemote + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				cast(fund.AECount as bigint) as ArchiveEntitiesCount,
				isnull(fund.LinearMeters, 0),
				null as DigitalSize,
				(
					select (isnull(convert(varchar, fund.EndDateDay) + ''.'', '''') + isnull(convert(varchar, fund.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, fund.EndDateYear), '''')) + ''; '' 
					from  Document_Modified d
					where d.FundLGid = fund.LGid 
					FOR XML path(''''), elements
				) as DocumentsEndDates,
				fund.Note,
				fund.IntNumber,
				a.SortOrder
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND (fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1) 
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3))';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreatedOn, 104) as CreationDate,
				COALESCE(
					fund.DocumentsProvider + '' / '' + ' + @methodOfAcquisitionQueryLocal +  ',
					fund.DocumentsProvider + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryLocal + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				cast(fund.ArchivalEntityCount as bigint) as ArchiveEntitiesCount,
				isnull(fund.LinearMeters, 0) as LinearMeters,
				cast(fund.Bytes AS BIGINT) as DigitalSize, -- реално е MB, името на колоната трябва да се смени
				(
					select (isnull(convert(varchar, EndDateDay) + ''.'', '''') + isnull(convert(varchar, EndDateMonth) + ''.'', '''') + isnull(convert(varchar, EndDateYear), '''')) + ''; '' 
					from  Documents d
					where d.FundSystemIdentifier = fund.SystemIdentifier 
					FOR XML path(''''), elements
				) as DocumentsEndDates,
				fund.Notes as Note,
				fund.NumberNumeric as IntNumber,
				a.SortOrder
			FROM Funds fund
			INNER JOIN Archives a ON a.Id = fund.ArchiveId AND a.Deleted = 0
			WHERE fund.ExternalIdentifier IS NULL AND fund.HasExternalSource = 0 AND fund.Deleted = 0 
				AND fund.DescriptionLevelCode IN(1, 2, 4)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				CreationDate varchar(50) NULL,
				ImmediateSourceOfAcquisitionPlusMethodOfAcquisition nvarchar(MAX) NULL,
				Title nvarchar(MAX) NULL,
				ArchiveEntitiesCount bigint NULL,
				LinearMeters float NULL, 
				DigitalSize bigint NULL,
				DocumentsEndDates nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null,
				SortOrder int null
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
		SET @sql = 'DECLARE @methodOfAcquisitionQueryLocal VARCHAR(MAX);' + @localQuery + @sqlFinalPart;
	END

	EXEC (@sql);
END
GO 

----------------------------------------------------------
--	THE SCRIPT IS CLOSED - USE THE NEW ONE!
----------------------------------------------------------

commit