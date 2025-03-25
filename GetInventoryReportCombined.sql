SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryReportCombined]
	@LinkedServer nvarchar(50),
	@ResultType int,
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
	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	SET @RowsOfPage = 2147483647
	SET @Page = 1

	DECLARE @sql VARCHAR(MAX); 
	CREATE TABLE #temp (
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
				Bytes bigint NULL
			);

	INSERT INTO #temp(
				Archive,
				FundDescriptionLevel,
				FundNumber,
				FundTitle,
				InventoryNumber,
				InventoryDescriptionLevel,
				[Status],
				AeCount,
				AeWithCharCount,
				EDocumentsCount,
				LinearMeters,
				FileFormat,
				Duration,
				Bytes
			)
	EXEC [sp_GetInventoryReport]
		@LinkedServer,
		@ResultType,
		@RowsOfPage,
		@Page,
		@Archives,
		@Statuses,
		@FundNumber,
		@RegisteredFrom,
		@RegisteredTo,
		@ChronologicalScope,
		@ChronologicalScopeStartDate,
		@ChronologicalScopeEndDate

	SET @sql = '
	SELECT TOP 1
		COUNT_BIG(1) as InventoryCount,
		CAST(SUM(t.AeCount) as bigint) as AeCount,
		CAST(SUM(t.EDocumentsCount) as bigint) as EDocumentsCount,
		CAST(SUM(t.Duration) as bigint) as Duration,
		CAST(SUM(t.LinearMeters) as decimal(18, 2)) as LinearMeters,
		CAST(SUM(t.Bytes) as bigint) as Bytes
		FROM #temp as t'

	EXEC (@sql);
END
GO