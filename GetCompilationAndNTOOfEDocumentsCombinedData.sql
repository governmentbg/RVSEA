SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCompilationAndNTOOfEDocumentsCombinedData]  
	@RowsOfPage int = 5000,
	@Page int = 1,
	@FundArraysInternal nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@ProcessStartDate nvarchar(100) = null,
	@ProcessEndDate nvarchar(100) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@DateFrom nvarchar(100) = null,
	@DateTo nvarchar(100) = null,
	@StatusesInternal nvarchar(max) = null,
	@ProcessTypes nvarchar(max) = null,
	@FileFormats nvarchar(max) = null,
	@FundLevelOfdescriptionCodes nvarchar(max) = null
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
		[Bytes] bigint,
		[Duration] nvarchar(256),
		[Note] nvarchar(MAX),
		[IntNumber] int null,
		[SortOrder] int null,
		[SystemIdentifier] nvarchar(256) null,
		[ExternalIdentifier] nvarchar(256) null,
		[HasExternalSource] bit
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
		[Bytes],
		[Duration],
		[Note],
		[IntNumber],
		[SortOrder],
		[SystemIdentifier],
		[ExternalIdentifier],
		[HasExternalSource]
	)
	EXEC [sp_GetCompilationAndNTOOfEDocumentsReport]
		2147483647,
		1,
		@FundArraysInternal,
		@FundTypesInternal,
		@MethodsOfAcquisitionInternal,
		@RegisteredFrom,
		@RegisteredTo,
		@ProcessStartDate,
		@ProcessEndDate,
		@ArchiveCodesInternal,
		@DateFrom,
		@DateTo,
		@StatusesInternal,
		@ProcessTypes,
		@FileFormats,
		@FundLevelOfdescriptionCodes

	SET @sql = '
		SELECT 
			COUNT(1) as FundsCount,
			isnull(SUM(t.[InvetoryCount]), ''0'') as InventoriesCount,
			isnull(SUM(t.[AeCount]), ''0'') as AesCount,
			isnull(SUM(t.[Bytes]), ''0'') as Bytes,
			--CAST((isnull(
			--			coalesce(
			--				convert(nvarchar, (select SUM(CAST(t.Duration as TIMESTAMP))/3600), 108) + '':'' + convert(nvarchar, (select (SUM(CAST(t.Duration as TIMESTAMP)) % 3600)/60), 108) + '':'' + convert(nvarchar, (select (SUM(CAST(t.Duration as TIMESTAMP)) % 3600) % 60), 108),
			--				convert(nvarchar, (select (SUM(CAST(t.Duration as TIMESTAMP)) % 3600)/60), 108) + '':'' + convert(nvarchar, (select (SUM(CAST(t.Duration as TIMESTAMP)) % 3600) % 60), 108),
			--				convert(nvarchar, (SUM(CAST(t.Duration as TIMESTAMP)))), ''0''), 108)) as nvarchar(256)) as Duration
			isnull(CAST(CAST(DATEADD(ms, SUM(DATEDIFF(ms, ''00:00:00.000'', t.[Duration])), ''00:00:00.000'')as time) as nvarchar(256)), ''0'') as Duration
		FROM #temp as t'

	EXEC (@sql);
END
