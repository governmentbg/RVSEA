USE [DAA]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetCompilationAndNTOOfEDocumentsCombinedData]    Script Date: 28.9.2022 г. 11:41:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCompilationAndNTOOfEDocumentsCombinedData]  
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

	@ArchiveGids nvarchar(max) = null,
	@ArchiveCodesInternal nvarchar(max) = null,
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


	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	




	CREATE TABLE #temp (
				[Archive] nvarchar(256),
				[FundNumber] nvarchar(256),
				[Title] nvarchar(MAX),
				[MethodOfAcquisitions] nvarchar(256),
				[Type] nvarchar(256),
				[ChronologicalScope] nvarchar(256),
				[DateOfFiling] nvarchar(256),
				[Status] nvarchar(256),
				[LevelOfDescription] nvarchar(256),
				[InvetoryCount] int,
				[AeCount] int,
				[DocumentCount] int,
				[FileFormats] nvarchar(256),
				[Mb] float,
				[Duration] nvarchar(256),
				[Note] nvarchar(MAX)
			);

	INSERT INTO #temp(
				[Archive],
				[FundNumber],
				[Title],
				[MethodOfAcquisitions],
				[Type],
				[ChronologicalScope],
				[DateOfFiling],
				[Status],
				[LevelOfDescription],
				[InvetoryCount],
				[AeCount],
				[DocumentCount],
				[FileFormats],
				[Mb],
				[Duration],
				[Note]
			)
	EXEC [sp_GetCompilationAndNTOOfEDocumentsReport]
	@LinkedServer,
	@ResultType,
	2147483647,
	@Page,
	@PeriodGids,
	@FundArraysInternal,
	@FundTypeGids,
	@FundTypesInternal,
	@MethodOfAcquisitionGids,
	@MethodsOfAcquisitionInternal,
	@RegisteredFrom,
	@RegisteredTo,
	@ProcessStartDate,
	@ProcessEndDate,
	@ArchiveGids,
	@ArchiveCodesInternal,
	@DateFrom,
	@DateTo,
	@StatusGids,
	@StatusesInternal,
	@ProcessGids,
	@ProcessTypes,
	@FileFormats

	SET @sql = '
		SELECT 
			COUNT(t.[FundNumber]) as FundsCount,
			isnull(SUM(t.[InvetoryCount]), ''0'') as InventoriesCount,
			isnull(SUM(t.[AeCount]), ''0'') as AesCount,
			CAST(isnull(SUM(t.[Mb]), ''0'') as float) as Mb,
			--CAST((isnull(
			--			coalesce(
			--				convert(nvarchar, (select SUM(CAST(t.Duration as TIMESTAMP))/3600), 108) + '':'' + convert(nvarchar, (select (SUM(CAST(t.Duration as TIMESTAMP)) % 3600)/60), 108) + '':'' + convert(nvarchar, (select (SUM(CAST(t.Duration as TIMESTAMP)) % 3600) % 60), 108),
			--				convert(nvarchar, (select (SUM(CAST(t.Duration as TIMESTAMP)) % 3600)/60), 108) + '':'' + convert(nvarchar, (select (SUM(CAST(t.Duration as TIMESTAMP)) % 3600) % 60), 108),
			--				convert(nvarchar, (SUM(CAST(t.Duration as TIMESTAMP)))), ''0''), 108)) as nvarchar(256)) as Duration
			isnull(CAST(CAST(DATEADD(ms, SUM(DATEDIFF(ms, ''00:00:00.000'', t.[Duration])), ''00:00:00.000'')as time) as nvarchar(256)), ''0'') as Duration
		FROM #temp as t'

	--DROP TABLE #temp

	--SET @sql = @sql + @sqlFinalPart

	--print @sql;
	EXEC (@sql);
END
