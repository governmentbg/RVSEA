SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfRoughDocumentsReportCombined]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 5000,
	@Page int = 1,
	@Archives nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null,
	@MethodsOfAcquisitionGids nvarchar(max) = null,
	@MethodsOfAcquisitionInternal nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
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
				Bytes bigint NULL,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
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
				Bytes,
				SystemIdentifier,
				ExternalIdentifier,
				HasExternalSource
			)
	EXEC [sp_GetListOfRoughDocumentsReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page,
		@Archives,
		@FundTypeGids,
		@FundTypesInternal,
		@IndustryIndexGids,
		@IndustryIndexesInternal,
		@MethodsOfAcquisitionGids,
		@MethodsOfAcquisitionInternal,
		@Statuses,
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
		CAST(SUM(t.Bytes) as bigint) as Bytes
		FROM #temp as t'

	EXEC (@sql);
END
GO