USE [DAA]
GO
/****** Object:  StoredProcedure [dbo].[sp_GetUserActionsJournalReportSummary]    Script Date: 10.2.2023 г. 14:41:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[sp_GetUserActionsJournalReportSummary]
	@LinkedServer nvarchar(50),
	@RowsOfPage int = 5000,
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

	DECLARE @sql NVARCHAR(MAX);

	SET @RowsOfPage = 2147483647
	SET @Page = 1
	CREATE TABLE #temp (
				ArchiveName nvarchar(max),
				ArchiveCode int,
				DescriptionLevel nvarchar(max),
				Kmf nvarchar(max),
				Fund nvarchar(max),
				Inventory int,
				ArchivalEntity nvarchar(max),
				DocumentServiceNumber int,
				Employee nvarchar(max),
				[Date] datetime,
				Process nvarchar(max),
				Steps nvarchar(max)
				
			);

	INSERT INTO #temp(
				ArchiveName,
				ArchiveCode,
				DescriptionLevel,
				Kmf,
				Fund,
				Inventory,
				ArchivalEntity,
				DocumentServiceNumber,
				Employee,
				[Date],
				Process,
				Steps
				
			)
	EXEC [sp_GetUserActionsJournalReport]
		 @LinkedServer,
		 @RowsOfPage,
		 @Page,
		 @EmployeeNames,
		 @ArchiveCodes,
		 @FundNumber,
		 @InventoryNumber,
		 @ArchiveEntityNumber,
		 @DateFrom,
		 @DateTo,
		 @Process,
		 @KmfNumber,
		 @DescriptionLevel
		
	SET @sql = '
		SELECT COUNT_BIG(*) as TotalRows
		FROM #temp'

	EXEC (@sql);

END
