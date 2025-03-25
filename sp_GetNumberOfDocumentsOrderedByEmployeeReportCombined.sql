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
				AccessDate varchar(50) NULL,
				SystemIdentifier uniqueidentifier NULL,
				ExternalIdentifier int NULL,
				HasExternalSource bit NULL,				
				InventoryNumber nvarchar(50) NULL,
				ArchivalEntityNumber nvarchar(50) NULL,
				DocumentNumber nvarchar(50) NULL				
			);

	INSERT INTO #temp(
				Employee,
				Archive,
				FundLevelOfDescription,
				Fund,
				Inventory,
				ArchiveEntity,
				Document,
				AccessDate,
				SystemIdentifier,
				ExternalIdentifier,
				HasExternalSource,
				InventoryNumber,
				ArchivalEntityNumber,
				DocumentNumber
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