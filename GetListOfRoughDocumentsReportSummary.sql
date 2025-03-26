USE [DAA]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetInventoryReportSummary]    Script Date: 31.1.2023 г. 12:04:27 ******/
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
