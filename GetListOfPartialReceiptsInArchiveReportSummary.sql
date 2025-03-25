SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfPartialReceiptsInArchiveReportSummary]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@Archives nvarchar(max) = null,
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
	@MethodOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
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

	DECLARE @sql NVARCHAR(MAX); 
	CREATE TABLE #temp (
				CountryCode nvarchar(50) NOT NULL,
				Archive nvarchar(256) NULL,
				FundNumber nvarchar(50) NULL,
				FundTitle nvarchar(max) NULL,
				CreationDate varchar(50) NULL,
				ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
				--FundType nvarchar(256) NULL, отпада по забележка на Архивите
				DocumentProperties nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				FundStatus nvarchar(256) NULL,
				MethodOfAcquisition nvarchar(256) NULL,
				ChronologicalScope nvarchar(256) NULL,
				-- махат се по забележка от ИСДА
				--ChronologicalScopeStartDate nvarchar(256) NULL,
				--ChronologicalScopeEndDate nvarchar(256) NULL,
				InventoryCount int NULL,
				AeCount int NULL,
				LinearMeters float NULL,
				Size bigint NULL,
				Duration nvarchar(14) NULL,
				DurationInt int NULL,
				EDocumentsCount int NULL,
				FileFormats nvarchar(MAX) NULL
			);

	INSERT INTO #temp(
				CountryCode,
				Archive,
				FundNumber,
				FundTitle,
				CreationDate,
				ImmediateSourceOfAcquisition,
				--FundType, отпада по забележка на Архивите
				DocumentProperties,
				Note,
				FundStatus,
				MethodOfAcquisition,
				ChronologicalScope,
				-- махат се по забележка от ИСДА
				--ChronologicalScopeStartDate,
				--ChronologicalScopeEndDate,
				InventoryCount,
				AeCount,
				LinearMeters,
				Size,
				Duration,
				DurationInt,
				EDocumentsCount,
				FileFormats
			)
	EXEC [sp_GetListOfPartialReceiptsInArchiveReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page,
		@Archives,
		@PeriodGids,
		@FundArraysInternal,
		@Statuses,
		@MethodOfAcquisitionGids,
		@MethodsOfAcquisitionInternal,
		@RegisteredFrom,
		@RegisteredTo,
		@ChronologicalScope,
		@ChronologicalScopeStartDate,
		@ChronologicalScopeEndDate

	SET @sql = '
	SELECT TOP 1 COUNT_BIG(*) as TotalRows
		FROM #temp as t'

	EXEC (@sql);
END
GO