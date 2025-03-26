SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.22'
where Code = 'DB_VERSION'

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[v_PublicArchivalEntities] AS
SELECT ae.Id, ae.SystemIdentifier, CAST(0 AS bit) AS IsDraft, ae.ArchiveId, a.Code AS ArchiveCode, a.Name AS ArchiveName, NULL AS FundDraftId, ae.FundSystemIdentifier, f.Number AS FundNumber, 
                  f.HasExternalSource AS FundHasExternalSource, f.ExternalIdentifier AS FundExternalIdentifier, NULL AS InventoryDraftId, ae.InventorySystemIdentifier, i.Number AS InventoryNumber, 
                  i.HasExternalSource AS InventoryHasExternalSource, i.ExternalIdentifier AS InventoryExternalIdentifier, ae.CreatedOn, ae.CreatedBy, cu.DisplayName AS CreatedByDisplayName, cu.UserName AS CreatedByUserName, ae.UpdatedOn, 
                  ae.UpdatedBy, uu.DisplayName AS UpdatedByDisplayName, uu.UserName AS UpdatedByUserName, ae.Deleted, ae.DeletedOn, ae.DeletedBy, du.DisplayName AS DeletedByDisplayName, du.UserName AS DeletedByUserName, 
                  ae.HasExternalSource, ae.ExternalIdentifier, ae.ExternalSourceUpdatedOn, ae.Number, ae.Title, ae.DescriptionLevelCode, l.Text AS DescriptionLevelText, ae.StatusCode, s.Text AS StatusText, ae.HasNoChronologicalScope, 
                  ae.StartDateYear, ae.StartDateMonth, ae.StartDateDay, ae.EndDateYear, ae.EndDateMonth, ae.EndDateDay, ae.ApproxmateChronologicalScope, ae.Author, ae.Location, ae.Bytes, ae.SheetCount, ae.TapeCount, ae.MicrofilmCount, 
                  ae.FrameCount, ae.VideoTapeCount, ae.DigitalDeviceCount, ae.OtherMetrics, ae.SizeCm, ae.Scaling, ae.Description, ae.DocumentsAccessDescription, ae.Features, ae.Condition, ae.MicrofilmedCopyCount, ae.DigitizedCopyCount, 
                  ae.PaperCopyCount, ae.NegativeFrameCount, ae.PositiveFrameCount, ae.OtherCopyCount, ae.Notes, ae.EnrolledBytes, ae.EnrolledDocumentCount, ae.EnrolledLinearMeters, ae.DeductedBytes, ae.DeductedDocumentCount, 
                  ae.DeductedLinearMeters, f.NumberNumeric as FundNumberNumeric, i.NumberNumeric as InventoryNumberNumeric, ae.NumberNumeric, ast.Text as AvailabilityStatusText, i.AvailabilityStatusCode
FROM dbo.ArchivalEntities AS ae INNER JOIN
                  dbo.Archives AS a ON ae.ArchiveId = a.Id INNER JOIN
                  dbo.Funds AS f ON ae.FundSystemIdentifier = f.SystemIdentifier INNER JOIN
                  dbo.Inventories AS i ON ae.InventorySystemIdentifier = i.SystemIdentifier LEFT OUTER JOIN
                  N.ArchivalEntityDescriptionLevel AS l ON ae.DescriptionLevelCode = l.Code LEFT OUTER JOIN
                  N.Status AS s ON ae.StatusCode = s.Code LEFT OUTER JOIN
                  dbo.AspNetUsers AS cu ON ae.CreatedBy = cu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS uu ON ae.UpdatedBy = uu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS du ON ae.CreatedBy = du.Id
				  LEFT JOIN N.AvailabilityStatus ast ON ae.AvailabilityStatusCode = ast.Code
WHERE ae.IsSuspended = 0
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[v_PublicDocuments] AS
SELECT d.Id, d.SystemIdentifier, CAST(0 AS bit) AS IsDraft, d.ArchiveId, a.Code AS ArchiveCode, a.Name AS ArchiveName, NULL AS FundDraftId, d.FundSystemIdentifier, f.Number AS FundNumber, 
                  f.HasExternalSource AS FundHasExternalSource, f.ExternalIdentifier AS FundExternalIdentifier, NULL AS InventoryDraftId, d.InventorySystemIdentifier, i.Number AS InventoryNumber, 
                  i.HasExternalSource AS InventoryHasExternalSource, i.ExternalIdentifier AS InventoryExternalIdentifier, NULL AS ArchivalEntityDraftId, d.ArchivalEntitySystemIdentifier, ae.Number AS ArchivalEntityNumber, 
                  ae.HasExternalSource AS ArchivalEntityHasExternalSource, ae.ExternalIdentifier AS ArchivalEntityExternalIdentifier, d.CreatedOn, d.CreatedBy, cu.DisplayName AS CreatedByDisplayName, cu.UserName AS CreatedByUserName, 
                  d.UpdatedOn, d.UpdatedBy, uu.DisplayName AS UpdatedByDisplayName, uu.UserName AS UpdatedByUserName, d.Deleted, d.DeletedOn, d.DeletedBy, du.DisplayName AS DeletedByDisplayName, du.UserName AS DeletedByUserName, 
                  d.HasExternalSource, d.ExternalIdentifier, d.ExternalSourceUpdatedOn, d.Number, d.Title, d.DescriptionLevelCode, l.Text AS DescriptionLevelText, d.StatusCode, s.Text AS StatusText, d.FileFormatCode, d.HasNoChronologicalScope, 
                  d.StartDateYear, d.StartDateMonth, d.StartDateDay, d.EndDateYear, d.EndDateMonth, d.EndDateDay, d.ApproxmateChronologicalScope, d.Author, d.Location, d.Bytes, d.SheetCount, d.StartSheetNumber, d.EndSheetNumber, 
                  d.DigitalDevice, d.OtherMetrics, d.SizeCm, d.Scaling, d.Duration, d.Description, d.DocumentsAccessDescription, d.Features, d.MicrofilmedCopyCount, d.DigitizedCopyCount, d.PaperCopyCount, d.NegativeFrameCount, 
                  d.PositiveFrameCount, d.OtherCopyCount, d.Transcription, d.Notes, f.NumberNumeric AS FundNumberNumeric, i.NumberNumeric AS InventoryNumberNumeric, ae.NumberNumeric AS ArchivalEntityNumberNumeric,
				  d.AvailabilityStatusCode, ast.Text as AvailabilityStatusText
FROM dbo.Documents AS d INNER JOIN
                  dbo.Archives AS a ON d.ArchiveId = a.Id INNER JOIN
                  dbo.Funds AS f ON d.FundSystemIdentifier = f.SystemIdentifier INNER JOIN
                  dbo.Inventories AS i ON d.InventorySystemIdentifier = i.SystemIdentifier INNER JOIN
                  dbo.ArchivalEntities AS ae ON d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier LEFT OUTER JOIN
                  N.DocumentDescriptionLevel AS l ON d.DescriptionLevelCode = l.Code LEFT OUTER JOIN
                  N.Status AS s ON d.StatusCode = s.Code LEFT OUTER JOIN
                  dbo.AspNetUsers AS cu ON d.CreatedBy = cu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS uu ON d.UpdatedBy = uu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS du ON d.CreatedBy = du.Id
				  LEFT JOIN N.AvailabilityStatus ast ON d.AvailabilityStatusCode = ast.Code
WHERE ae.IsSuspended = 0
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW [dbo].[v_PublicInventories] AS
SELECT i.Id, i.SystemIdentifier, CAST(0 AS bit) AS IsDraft, i.ArchiveId, a.Code AS ArchiveCode, a.Name AS ArchiveName, NULL AS FundDraftId, i.FundSystemIdentifier, f.Number AS FundNumber, f.HasExternalSource AS FundHasExternalSource, 
                  f.ExternalIdentifier AS FundExternalIdentifier, i.CreatedOn, i.CreatedBy, cu.DisplayName AS CreatedByDisplayName, cu.UserName AS CreatedByUserName, i.UpdatedOn, i.UpdatedBy, uu.DisplayName AS UpdatedByDisplayName, 
                  uu.UserName AS UpdatedByUserName, i.Deleted, i.DeletedOn, i.DeletedBy, du.DisplayName AS DeletedByDisplayName, du.UserName AS DeletedByUserName, i.ExternalIdentifier, i.HasExternalSource, i.ExternalSourceUpdatedOn, 
                  i.NumberArray, i.Number, i.DescriptionLevelCode, idl.Text AS DescriptionLevelText, i.StatusCode, s.Text AS StatusText, i.HasNoChronologicalScope, i.StartDateYear, i.StartDateMonth, i.StartDateDay, i.EndDateYear, i.EndDateMonth, 
                  i.EndDateDay, i.ApproxmateChronologicalScope, i.Bytes, i.LinearMeters, i.OtherMetrics, i.ArchivalEntityCount, i.DocumentCount, i.BoxCount, i.RollCount, i.AudioDocumentArchivalEntityCount, i.PhotoDocumentArchivalEntityCount, 
                  i.VideoDocumentArchivalEntityCount, i.DigitalDocumentArchivalEntityCount, i.FundCreatorTitleHistory, i.FundCreatorBiographicalHistory, i.History, i.DocumentsProvider, i.DocumentsDescription, i.DocumentsAccessDescription, 
                  i.ClassificationScheme, i.AbbreviationList, i.MicrofilmedArchivalEntityCount, i.DigitizedArchivalEntityCount, i.NegativeFrameCount, i.PositiveFrameCount, i.Notes, i.NumberNumeric, f.NumberNumeric as FundNumberNumeric,
				  ast.Text as AvailabilityStatusText, i.AvailabilityStatusCode
FROM dbo.Inventories AS i INNER JOIN
                  dbo.Archives AS a ON i.ArchiveId = a.Id INNER JOIN
                  dbo.Funds AS f ON i.FundSystemIdentifier = f.SystemIdentifier LEFT OUTER JOIN
                  N.InventoryDescriptionLevel AS idl ON i.DescriptionLevelCode = idl.Code LEFT OUTER JOIN
                  N.Status AS s ON i.StatusCode = s.Code LEFT OUTER JOIN
                  dbo.AspNetUsers AS cu ON i.CreatedBy = cu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS uu ON i.UpdatedBy = uu.Id LEFT OUTER JOIN
                  dbo.AspNetUsers AS du ON i.CreatedBy = du.Id
				  LEFT JOIN N.AvailabilityStatus ast ON i.AvailabilityStatusCode = ast.Code
WHERE i.IsSuspended = 0
	AND i.DescriptionLevelCode <> 6 -- груб опис 					
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetFundInventories]
	@LinkedServer nvarchar(255) = '', 
	@FundIdentifier uniqueidentifier = NULL,
	@FundHasExternalSource bit,
	@FundExternalIdentifier int = NULL,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @RemoteInventoriesQuery nvarchar(max) = '';
    DECLARE @RemoteInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(256)
		,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,NumberNumeric int
		,Number nvarchar(50)
		,ApproxmateChronologicalScope nvarchar(max)
		,LinearMeters float
		,ArchivalEntityCount int
		,BoxCount int 
		,RollCount int
		,AudioDocumentArchivalEntityCount int
		,PhotoDocumentArchivalEntityCount int 
		,VideoDocumentArchivalEntityCount int
		,DigitalDocumentArchivalEntityCount int
		,OtherMetrics nvarchar(256)
		,FundCreatorTitleHistory nvarchar(max)
		,FundCreatorBiographicalHistory nvarchar(max)
		,History nvarchar(max)
		,DocumentsProvider nvarchar(max)
		,AcquisitionMethodText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,ClassificationScheme nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,AbbreviationList nvarchar(max)
		,MicrofilmedArchivalEntityCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,DigitizedArchivalEntityCount int
		,Notes nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(256)
		,DocumentsDescription nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
	);

	DECLARE @LocalInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(256)
		,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,NumberNumeric int
		,Number nvarchar(50)
		,ApproxmateChronologicalScope nvarchar(max)
		,LinearMeters float
		,ArchivalEntityCount int
		,BoxCount int 
		,RollCount int
		,AudioDocumentArchivalEntityCount int
		,PhotoDocumentArchivalEntityCount int 
		,VideoDocumentArchivalEntityCount int
		,DigitalDocumentArchivalEntityCount int
		,OtherMetrics nvarchar(256)
		,FundCreatorTitleHistory nvarchar(max)
		,FundCreatorBiographicalHistory nvarchar(max)
		,History nvarchar(max)
		,DocumentsProvider nvarchar(max)
		,AcquisitionMethodText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,ClassificationScheme nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,AbbreviationList nvarchar(max)
		,MicrofilmedArchivalEntityCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,DigitizedArchivalEntityCount int
		,Notes nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(256)
		,DocumentsDescription nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
	);

	IF @FundHasExternalSource = 1
	BEGIN 
		SET @RemoteInventoriesQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
			  ,CAST(NULL as uniqueidentifier) as SystemIdentifier
			  ,CAST(1 as bit) as HasExternalSource
			  ,inventory.[LGid] as ExternalIdentifier
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
			  ,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
			  ,CAST(1 as bit) as FundHasExternalSource
			  ,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
			  ,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
			  ,(select Code from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
			  ,(select Name from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
			  ,(select Value from [Archiving].[dbo].Nomenclature n where n.Gid = inventory.InventoryArrayGid and n._retired = ''''3000-01-01 00:00:00.000'''') as NumberArray
			  ,inventory.[IntNumber] as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.[TextDate] as ApproxmateChronologicalScope
			  ,inventory.[LinearMeter] as LinearMeters
			  ,inventory.[AECount] as ArchivalEntityCount ' + '
			  ,inventory.[BoxesCount] as BoxCount
			  ,inventory.[RuloniTubusiCount] as RollCount
			  ,inventory.[AEFonoDocsCount] as AudioDocumentArchivalEntityCount
			  ,inventory.[AEPhotoDocsCount] as PhotoDocumentArchivalEntityCount
			  ,inventory.[AEVideoAudioDocsCount] as VideoDocumentArchivalEntityCount
			  ,inventory.[AEElectrDocsCount] as DigitalDocumentArchivalEntityCount
			  ,inventory.[ExtentOther] as OtherMetrics
			  ,inventory.[FundCreatorNameChanges] as FundCreatorTitleHistory
			  ,inventory.[FundFormerHistory] as FundCreatorBiographicalHistory
			  ,inventory.[ArchivalHistory] as History
			  ,inventory.[ImmediateSourceOfAcquisition] as DocumentsProvider ' + '
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''MethodOfAcquisition'''' for XML PATH('''''''')), 1, 1, '''''''') as AcquisitionMethodText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
			  ,inventory.[ClassificationScheme] as ClassificationScheme
			  ,inventory.[AccessConditions] as DocumentsAccessDescription
			  ,inventory.[Abbreviations] as AbbreviationList
			  ,inventory.[CopyMicrofilmAE] as MicrofilmedArchivalEntityCount ' + '
			  ,inventory.[CopyNegativFrames] as NegativeFrameCount
			  ,inventory.[CopyPositiveFrames] as PositiveFrameCount
			  ,inventory.[CopyDigitizedAE] as DigitizedArchivalEntityCount
			  ,inventory.[Note] as Notes
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
			  ,inventory.[DocumentProperties] as DocumentsDescription
			  ,inventory.[StartDateYear] as StartDateYear
			  ,inventory.[StartDateMonth] as StartDateMonth
			  ,inventory.[StartDateDay] as StartDateDay
			  ,inventory.[EndDateYear] as EndDateYear
			  ,inventory.[EndDateMonth] as EndDateMonth
			  ,inventory.[EndDateDay] as EndDateDay
			  ,inventory.[IsNoDate] as HasNoChronologicalScope
		  FROM [Archiving].[dbo].[Inventory_Active] inventory
		  WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50));
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteInventoriesQuery + ''' )';
		
		INSERT INTO @RemoteInventories 
		EXEC(@RemoteQuery)
	END

	IF @FundIdentifier IS NOT NULL
	BEGIN
		INSERT INTO @LocalInventories
		SELECT inventory.Id
			  ,inventory.SystemIdentifier as SystemIdentifier
			  ,inventory.HasExternalSource
			  ,inventory.ExternalIdentifier
			  ,inventory.StatusCode
			  ,inventory.StatusText
			  ,inventory.AvailabilityStatusCode
			  ,inventory.AvailabilityStatusText
			  ,inventory.FundHasExternalSource
			  ,inventory.FundExternalIdentifier
			  ,inventory.FundNumber
			  ,inventory.ArchiveCode
			  ,inventory.ArchiveName
			  ,inventory.NumberArray
			  ,inventory.NumberNumeric as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.ApproxmateChronologicalScope
			  ,inventory.LinearMeters
			  ,inventory.ArchivalEntityCount
			  ,inventory.BoxCount
			  ,inventory.RollCount
			  ,inventory.AudioDocumentArchivalEntityCount
			  ,inventory.PhotoDocumentArchivalEntityCount
			  ,inventory.VideoDocumentArchivalEntityCount
			  ,inventory.DigitalDocumentArchivalEntityCount
			  ,inventory.OtherMetrics
			  ,inventory.FundCreatorTitleHistory
			  ,inventory.FundCreatorBiographicalHistory
			  ,inventory.History
			  ,inventory.DocumentsProvider
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'ACQUISITION_METHOD' for XML PATH('')), 1, 1, '') as AcquisitionMethodText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
			  ,inventory.ClassificationScheme
			  ,inventory.DocumentsAccessDescription
			  ,inventory.AbbreviationList
			  ,inventory.MicrofilmedArchivalEntityCount
			  ,inventory.NegativeFrameCount
			  ,inventory.PositiveFrameCount
			  ,inventory.DigitizedArchivalEntityCount
			  ,inventory.Notes
			  ,inventory.DescriptionLevelCode
			  ,inventory.DescriptionLevelText
			  ,inventory.DocumentsDescription
			  ,inventory.StartDateYear
			  ,inventory.StartDateMonth
			  ,inventory.StartDateDay
			  ,inventory.EndDateYear
			  ,inventory.EndDateMonth
			  ,inventory.EndDateDay
			  ,inventory.HasNoChronologicalScope
		FROM [dbo].[v_Inventories] inventory
		WHERE inventory.FundSystemIdentifier = @FundIdentifier 
			AND inventory.HasExternalSource = 0
			AND inventory.Deleted = 0
	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalInventories
		  UNION
		 SELECT *
		   FROM @RemoteInventories
	   ) inventories
	ORDER BY NumberNumeric
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetFundInventoriesCount]
	@LinkedServer nvarchar(255) = '', 
	@FundIdentifier uniqueidentifier = NULL,
	@FundHasExternalSource bit,
	@FundExternalIdentifier int = NULL
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @RemoteInventories TABLE ( InventoryCount int );
	DECLARE @RemoteInventoriesCount int = 0;
	DECLARE @LocalInventoriesCount int = 0;

	DECLARE @RemoteInventoriesQuery nvarchar(max) = '';
    
	IF @FundHasExternalSource = 1
	BEGIN 
		SET @RemoteInventoriesQuery = CAST('' as nvarchar(max)) + '
			SELECT inventory.[LGid]
			FROM [Archiving].[dbo].[Inventory_Active] inventory
			WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50)) + '';
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT COUNT(*) as InventoryCount FROM OPENQUERY(' +  @LinkedServer + ', ''SELECT inventory.[LGid]
			FROM [Archiving].[dbo].[Inventory_Active] inventory
			WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50)) + ''')';
		
		INSERT INTO @RemoteInventories
		EXEC(@RemoteQuery)

		SELECT TOP 1 @RemoteInventoriesCount = InventoryCount from @RemoteInventories
	END

	IF @FundIdentifier IS NOT NULL
	BEGIN
		SELECT @LocalInventoriesCount = COUNT(inventory.Id)
		FROM [dbo].[v_Inventories] inventory
		WHERE inventory.FundSystemIdentifier = @FundIdentifier 
		   AND inventory.HasExternalSource = 0
		   AND inventory.Deleted = 0
	END

	RETURN @LocalInventoriesCount + @RemoteInventoriesCount
END
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetDocumentsByArchiveEntityPublic] 
	@LinkedServer nvarchar(50),
	@ArchiveEntityIdentifier uniqueidentifier = NULL,
	@ArchiveEntityHasExternalSource bit,
	@ArchiveEntityExternalIdentifier int = NULL,
	@SearchText nvarchar(max) = NULL,
	@IncludeDeleted bit = false,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteDocumentsQuery nvarchar(max) = '';
    DECLARE @RemoteDocuments TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,ArchivalEntityHasExternalSource bit
        ,ArchivalEntityExternalIdentifier int
        ,ArchivalEntityNumber nvarchar(50)
        ,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Author nvarchar(max)
		,Location nvarchar(max)
		,FileTypeText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,Features nvarchar(max)
		,Notes nvarchar(max)
		,Description nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
	    ,Bytes bigint
	    ,SheetCount int 
	    ,StartSheetNumber int
	    ,EndSheetNumber int 
	    ,DigitalDevice nvarchar(max)
	    ,Scaling nvarchar(256)
	    ,Duration nvarchar(256)
	    ,Transcription nvarchar(max)
	);

	DECLARE @LocalDocuments TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,ArchivalEntityHasExternalSource bit
        ,ArchivalEntityExternalIdentifier int
        ,ArchivalEntityNumber nvarchar(50)
        ,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Author nvarchar(max)
		,Location nvarchar(max)
		,FileTypeText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,Features nvarchar(max)
		,Notes nvarchar(max)
		,Description nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
	    ,Bytes bigint
	    ,SheetCount int 
	    ,StartSheetNumber int
	    ,EndSheetNumber int 
	    ,DigitalDevice nvarchar(max)
	    ,Scaling nvarchar(256)
	    ,Duration nvarchar(256)
	    ,Transcription nvarchar(max)
	);

	IF @ArchiveEntityHasExternalSource = 1
	BEGIN 

		SET @RemoteDocumentsQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
		,CAST(NULL as uniqueidentifier) as SystemIdentifier
		,CAST(1 as bit) as HasExternalSource
		,d.[LGid] as ExternalIdentifier
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= d.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= d.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
		,CAST(1 as bit) as ArchivalEntityHasExternalSource
		,(select LGid from [Archiving].[dbo].ArchiveEntity_Active ae where ae.LGid = d.AELGid and ae._retired = ''''3000-01-01 00:00:00.000'''') as ArchivalEntityExternalIdentifier
		,(select Number from [Archiving].[dbo].ArchiveEntity_Active ae where ae.LGid = d.AELGid and ae._retired = ''''3000-01-01 00:00:00.000'''') as ArchivalEntityNumber
		,CAST(1 as bit) as InventoryHasExternalSource
		,(select LGid from [Archiving].[dbo].Inventory_Active i where i.LGid = d.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryExternalIdentifier
		,(select Number from [Archiving].[dbo].Inventory_Active i where i.LGid = d.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryNumber
		,CAST(1 as bit) as FundHasExternalSource
		,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = d.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
		,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = d.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
		,(select Code from [Archiving].[dbo].Archive a where a.Gid = d.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
		,(select Name from [Archiving].[dbo].Archive a where a.Gid = d.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
		,d.[Number] as Number
		,d.[Title] as Title
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= d.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= d.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
		,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= d.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= d.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
		,d.[TextDate] as ApproximateChronologicalScope  ' + '
		,d.CopyMicrofilm as MicrofilmedCopyCount
		,d.CopyDigital as DigitizedCopyCount
		,d.CopyXerox as PaperCopyCount
		,d.CopyNegativFrames as NegativeFrameCount
		,d.CopyPositiveFrames as PositiveFrameCount
		,d.CopyOther as OtherCopyCount
		,d.DimensionInCentimeters as SizeCm
		,NULL as OtherMetrics
		,d.Creator as Author
		,d.PlaceOfCreation as Location
		,NULL as FileTypeText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.DocumentGid = d.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.DocumentGid = d.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.DocumentGid = d.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
		,d.[AccessConditions] as DocumentsAccessDescription
		,d.SpecificDetails as Features
		,d.[Note] as Notes
		,d.[ExtendedContentDescription] as Description
		,d.[StartDateYear] as StartDateYear
		,d.[StartDateMonth] as StartDateMonth
		,d.[StartDateDay] as StartDateDay
		,d.[EndDateYear] as EndDateYear
		,d.[EndDateMonth] as EndDateMonth
		,d.[EndDateDay] as EndDateDay
		,d.[IsNoDate] as HasNoChronologicalScope
		,NULL as Bytes
	    ,d.PaperCount as SheetCount
	    ,NULL as StartSheetNumber
	    ,NULL as EndSheetNumber
	    ,NULL as DigitalDevice
	    ,d.Scale as Scaling
	    ,NULL Duration
	    ,d.Transcription as Transcription
	FROM [Archiving].[dbo].[Document_Active] d
	WHERE d.AELGid = ' + CAST(@ArchiveEntityExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
		BEGIN
			SET @RemoteDocumentsQuery = @RemoteDocumentsQuery +  ' AND (d.Title LIKE ''''%' + @SearchText + '%'''' )'
		END;

		PRINT @RemoteDocumentsQuery
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteDocumentsQuery + ''' )';
		
		INSERT INTO @RemoteDocuments 
		EXEC(@RemoteQuery)
	END

	IF @ArchiveEntityIdentifier IS NOT NULL
	BEGIN
		INSERT INTO @LocalDocuments
		SELECT	 d.Id
				,d.SystemIdentifier as SystemIdentifier
				,COALESCE(d.HasExternalSource, 0) as HasExternalSource
				,d.ExternalIdentifier
				,d.StatusCode
				,d.StatusText
				,d.ArchivalEntityHasExternalSource
				,d.ArchivalEntityExternalIdentifier
				,d.ArchivalEntityNumber
				,d.InventoryHasExternalSource
				,d.InventoryExternalIdentifier
				,d.InventoryNumber
				,d.FundHasExternalSource
				,d.FundExternalIdentifier
				,d.FundNumber
				,d.ArchiveCode
				,d.ArchiveName
				,d.Number as Number
				,d.Title
				,d.DescriptionLevelCode
				,d.DescriptionLevelText
				,d.AvailabilityStatusCode
				,d.AvailabilityStatusText
				,d.ApproxmateChronologicalScope as ApproximateChronologicalScope
				,d.MicrofilmedCopyCount
				,d.DigitizedCopyCount
				,d.PaperCopyCount
				,d.NegativeFrameCount
				,d.PositiveFrameCount
				,d.OtherCopyCount
				,d.SizeCm
				,d.OtherMetrics
				,d.Author
				,d.Location
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = d.Id and nv.EntityType = 'document' and nv.NomenclatureCode = 'FILE_TYPE' for XML PATH('')), 1, 1, '') as FileTypeText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = d.Id and nv.EntityType = 'document' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = d.Id and nv.EntityType = 'document' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = d.Id and nv.EntityType = 'document' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
				,d.DocumentsAccessDescription
				,d.Features
				,d.Notes
				,d.Description
				,d.StartDateYear
				,d.StartDateMonth
				,d.StartDateDay
				,d.EndDateYear
				,d.EndDateMonth
				,d.EndDateDay
				,d.HasNoChronologicalScope				
				,d.Bytes
				,d.SheetCount
				,d.StartSheetNumber
				,d.EndSheetNumber
				,d.DigitalDevice
				,d.Scaling
				,d.Duration
				,d.Transcription
	     FROM [dbo].[v_PublicDocuments] d
	    WHERE d.ArchivalEntitySystemIdentifier = @ArchiveEntityIdentifier 
		  AND (d.HasExternalSource IS NULL OR d.HasExternalSource = 0)
		  AND (@SearchText IS NULL OR d.Title LIKE '%'+ @SearchText +'%')
		  AND (@IncludeDeleted = 1 OR d.Deleted = 0)
	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalDocuments
		  UNION
		 SELECT *
		   FROM @RemoteDocuments
	   ) Documents
	ORDER BY Number
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY	
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetDocumentsByArchiveEntityCountPublic]
	@LinkedServer nvarchar(50),
	@ArchiveEntityIdentifier uniqueidentifier NULL,
	@ArchiveEntityHasExternalSource bit,
	@ArchiveEntityExternalIdentifier int NULL,
	@SearchText nvarchar(max) NULL = NULL,
	@IncludeDeleted bit = false
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteDocuments TABLE ( DocumentCount int );
	DECLARE @RemoteDocumentsCount int = 0;
	DECLARE @LocalDocumentsCount int = 0;

	DECLARE @RemoteDocumentsQuery nvarchar(max) = '';
		
	IF @ArchiveEntityHasExternalSource = 1
	BEGIN 
		SET @RemoteDocumentsQuery = CAST('' as nvarchar(max)) +
		'SELECT LGid
		 FROM [Archiving].[dbo].[Document_Active] d
		 WHERE d.AELGid = ' + CAST(@ArchiveEntityExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
			SET @RemoteDocumentsQuery = @RemoteDocumentsQuery + ' AND Title LIKE ''''%' + @SearchText + '%'''''
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT COUNT(*) as DocumentCount FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteDocumentsQuery + ''' )';
		
		PRINT @RemoteQuery
		
		INSERT INTO @RemoteDocuments
		EXEC(@RemoteQuery)

		SELECT TOP 1 @RemoteDocumentsCount = DocumentCount from @RemoteDocuments

	END

	IF @ArchiveEntityIdentifier IS NOT NULL
	BEGIN
		SELECT @LocalDocumentsCount = COUNT(d.Id)
		FROM [dbo].[v_PublicDocuments] d
		WHERE d.ArchivalEntitySystemIdentifier = @ArchiveEntityIdentifier 
		   AND (d.HasExternalSource IS NULL OR d.HasExternalSource = 0)
		   AND (@IncludeDeleted = 1 OR d.Deleted = 0)
	END

	RETURN @LocalDocumentsCount + @RemoteDocumentsCount	
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetArchiveEntitiesByInventoryPublic]
	@LinkedServer nvarchar(255) = '', 
	@InventoryIdentifier uniqueidentifier = NULL,
	@InventoryHasExternalSource bit,
	@InventoryExternalIdentifier int = NULL,
	@SearchText nvarchar(max) = NULL,
	@SearchNumber nvarchar(max) = NULL,
	@IncludeDeleted bit = false,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @RemoteArchivalEntitiesQuery nvarchar(max) = '';
    DECLARE @RemoteArchivalEntities TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,IntNumber int
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,TapeCount int
		,MicrofilmCount int 
		,FrameCount int
		,VideoTapeCount int
		,DigitalDeviceCount int 
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Location nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,Features nvarchar(max)
		,Notes nvarchar(max)
		,Description nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,EnrolledDocumentCount int
        ,EnrolledLinearMeters float
        ,DeductedDocumentCount int
        ,DeductedLinearMeters float
		,SheetCount int
	);

	DECLARE @LocalArchivalEntities TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,InventoryHasExternalSource bit
        ,InventoryExternalIdentifier int
        ,InventoryNumber nvarchar(50)
        ,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,Number nvarchar(50)
		,IntNumber int
		,Title nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(255)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(255)
		,ApproximateChronologicalScope nvarchar(max)
		,TapeCount int
		,MicrofilmCount int 
		,FrameCount int
		,VideoTapeCount int
		,DigitalDeviceCount int 
		,MicrofilmedCopyCount int
		,DigitizedCopyCount int
		,PaperCopyCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,OtherCopyCount nvarchar(255)
		,SizeCm nvarchar(255)
		,OtherMetrics nvarchar(256)
		,Location nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,Features nvarchar(max)
		,Notes nvarchar(max)
		,Description nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
		,EnrolledDocumentCount int
        ,EnrolledLinearMeters float
        ,DeductedDocumentCount int
        ,DeductedLinearMeters float
		,SheetCount int
	);

	IF @InventoryHasExternalSource = 1
	BEGIN 

		SET @RemoteArchivalEntitiesQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
		,CAST(NULL as uniqueidentifier) as SystemIdentifier
		,CAST(1 as bit) as HasExternalSource
		,ae.[LGid] as ExternalIdentifier
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
		,CAST(1 as bit) as InventoryHasExternalSource
		,(select LGid from [Archiving].[dbo].Inventory_Active i where i.LGid = ae.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryExternalIdentifier
		,(select Number from [Archiving].[dbo].Inventory_Active i where i.LGid = ae.InventoryLGid and i._retired = ''''3000-01-01 00:00:00.000'''') as InventoryNumber
		,CAST(1 as bit) as FundHasExternalSource
		,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = ae.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
		,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = ae.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
		,(select Code from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
		,(select Name from [Archiving].[dbo].Archive a where a.Gid = ae.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
		,ae.[Number] as Number
		,ae.[IntNumber] as IntNumber ' + '
		,ae.[Title] as Title
		,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
		,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
		,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= ae.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
		,ae.[TextDate] as ApproximateChronologicalScope
		,ae.[MagnetTapesCount] as TapeCount
		,ae.[MicrofilmsCount] as MicrofilmCount
		,ae.[FramesCount] as FrameCount
		,ae.[VideoTapesCount] as VideoTapeCount 
		,ae.[ElectrCount] as DigitalDeviceCount
		,ae.[CopyMicrofilm] as MicrofilmedCopyCount
		,ae.[CopyDigital] as DigitizedCopyCount
		,ae.[PaperCount] as PaperCopyCount
		,ae.[CopyNegativFrames] as NegativeFrameCount
		,ae.[CopyPositiveFrames] as PositiveFrameCount
		,ae.[CopyOther] as OtherCopyCount
		,ae.[DimensionInCentimeters] as SizeCm
		,ae.[ExtentOther] as OtherMetrics
		,ae.[PlaceOfCreation] as Location ' + '
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
		,STUFF(
		(select ''''; '''' + Value 
			from [Archiving].[dbo].ObjectNomenclature obj 
			join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
			where obj.ArchiveEntityGid = ae.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
		,ae.[AccessConditions] as DocumentsAccessDescription
		,ae.[DocumentProperties] as Features
		,ae.[Note] as Notes
		,ae.[ExtendedContentDescription] as Description
		,ae.[StartDateYear] as StartDateYear
		,ae.[StartDateMonth] as StartDateMonth
		,ae.[StartDateDay] as StartDateDay
		,ae.[EndDateYear] as EndDateYear
		,ae.[EndDateMonth] as EndDateMonth
		,ae.[EndDateDay] as EndDateDay
		,ae.[IsNoDate] as HasNoChronologicalScope
		,ae.[AveilabilityDocumentsCountAssigned] as EnrolledDocumentCount
        ,ae.[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters 
        ,ae.[AveilabilityDocumentsCountDeducted] as DeductedDocumentCount
        ,ae.[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
		,ae.PaperCount as SheetCount
	FROM [Archiving].[dbo].[ArchiveEntity_Active] ae
	WHERE ae.InventoryLGid = ' + CAST(@InventoryExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
		BEGIN
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  ' AND (ae.Title LIKE ''''%' + @SearchText + '%'''' OR ae.Number LIKE ''''%' + @SearchText + '%'''')'
		END;

		IF @SearchNumber IS NOT NULL
		BEGIN
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  'AND ( ae.Number LIKE '+ @SearchNumber +')'
		END;

		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteArchivalEntitiesQuery + ''' )';
		
		INSERT INTO @RemoteArchivalEntities 
		EXEC(@RemoteQuery)	
	END

	IF @InventoryIdentifier IS NOT NULL
	BEGIN

		INSERT INTO @LocalArchivalEntities
		SELECT	 ae.Id
				,ae.SystemIdentifier as SystemIdentifier
				,ae.HasExternalSource
				,ae.ExternalIdentifier
				,ae.StatusCode
				,ae.StatusText
				,ae.InventoryHasExternalSource
				,ae.InventoryExternalIdentifier
				,ae.InventoryNumber
				,ae.FundHasExternalSource
				,ae.FundExternalIdentifier
				,ae.FundNumber
				,ae.ArchiveCode
				,ae.ArchiveName
				,ae.Number as Number
				,NULL as IntNumber
				,ae.Title
				,ae.DescriptionLevelCode
				,ae.DescriptionLevelText
				,ae.AvailabilityStatusCode
				,ae.AvailabilityStatusText
				,ae.ApproxmateChronologicalScope
				,ae.TapeCount
				,ae.MicrofilmCount
				,ae.FrameCount
				,ae.VideoTapeCount
				,ae.DigitalDeviceCount
				,ae.MicrofilmedCopyCount
				,ae.DigitizedCopyCount
				,ae.PaperCopyCount
				,ae.NegativeFrameCount
				,ae.PositiveFrameCount
				,ae.OtherCopyCount
				,ae.SizeCm
				,ae.OtherMetrics
				,ae.Location
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
				,STUFF(
				(select '; ' +  n.Text
					from [dbo].[NomenclatureValues] nv 
					join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
					where nv.EntityId = ae.Id and nv.EntityType = 'archival_entity' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
				,ae.DocumentsAccessDescription
				,ae.Features
				,ae.Notes
				,ae.Description
				,ae.StartDateYear
				,ae.StartDateMonth
				,ae.StartDateDay
				,ae.EndDateYear
				,ae.EndDateMonth
				,ae.EndDateDay
				,ae.HasNoChronologicalScope
				,ae.EnrolledDocumentCount
				,ae.EnrolledLinearMeters
				,ae.DeductedDocumentCount
				,ae.DeductedLinearMeters
				,ae.SheetCount
	     FROM [dbo].[v_PublicArchivalEntities] ae
	    WHERE ae.InventorySystemIdentifier = @InventoryIdentifier 
		  AND ae.HasExternalSource = 0
		  AND ae.Deleted = 0
		  AND (@SearchText IS NULL OR (ae.Title LIKE '%'+ @SearchText +'%' OR ae.Number LIKE '%'+ @SearchText +'%'))
		  AND (@IncludeDeleted = 1 OR ae.Deleted = 0)
	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalArchivalEntities
		  UNION
		 SELECT *
		   FROM @RemoteArchivalEntities
	   ) ArchivalEntities
	ORDER BY IntNumber
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER   PROCEDURE [dbo].[sp_GetArchiveEntitiesByInventoryCountPublic]
	@LinkedServer nvarchar(255) = '', 
	@InventoryIdentifier uniqueidentifier = NULL,
	@InventoryHasExternalSource bit,
	@InventoryExternalIdentifier int = NULL,
	@SearchText nvarchar(max) = NULL,
	@SearchNumber nvarchar(max) = NULL,
	@IncludeDeleted bit = false	
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RemoteArchivalEntities TABLE ( ArchivalEntityCount int );
	DECLARE @RemoteArchivalEntitiesCount int = 0;
	DECLARE @LocalArchivalEntitiesCount int = 0;

	DECLARE @RemoteArchivalEntitiesQuery nvarchar(max) = '';
		
	IF @InventoryHasExternalSource = 1
	BEGIN 
		SET @RemoteArchivalEntitiesQuery = CAST('' as nvarchar(max)) +
		'SELECT LGid
		FROM [Archiving].[dbo].[ArchiveEntity_Active] ae
		WHERE ae.InventoryLGid = ' + CAST(@InventoryExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery + ' AND Title LIKE ''''%' + @SearchText + '%'''''
		
		IF @SearchNumber IS NOT NULL
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  'AND (ae.Number LIKE '+ @SearchNumber +')'

		DECLARE @RemoteQuery nvarchar(max) = 'SELECT COUNT(*) as ArchivalEntityCount FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteArchivalEntitiesQuery + ''' )';
		
		PRINT @RemoteQuery
		
		INSERT INTO @RemoteArchivalEntities
		EXEC(@RemoteQuery)

		SELECT TOP 1 @RemoteArchivalEntitiesCount = ArchivalEntityCount from @RemoteArchivalEntities
	END

	IF @InventoryIdentifier IS NOT NULL
	BEGIN
		SELECT @LocalArchivalEntitiesCount = COUNT(ae.Id)
		FROM [dbo].[v_PublicArchivalEntities] ae
		WHERE ae.InventorySystemIdentifier = @InventoryIdentifier 
		   AND ae.HasExternalSource = 0
		   AND (@IncludeDeleted = 1 OR ae.Deleted = 0)
	END

	RETURN @LocalArchivalEntitiesCount + @RemoteArchivalEntitiesCount	
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetFundInventoriesPublic]
	@LinkedServer nvarchar(255) = '', 
	@FundIdentifier uniqueidentifier = NULL,
	@FundHasExternalSource bit,
	@FundExternalIdentifier int = NULL,
	@Paging bit = 1,
	@PageNumber int = 1,
	@PageSize int = 20
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @RemoteInventoriesQuery nvarchar(max) = '';
    DECLARE @RemoteInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(256)
		,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,NumberNumeric int
		,Number nvarchar(50)
		,ApproxmateChronologicalScope nvarchar(max)
		,LinearMeters float
		,ArchivalEntityCount int
		,BoxCount int 
		,RollCount int
		,AudioDocumentArchivalEntityCount int
		,PhotoDocumentArchivalEntityCount int 
		,VideoDocumentArchivalEntityCount int
		,DigitalDocumentArchivalEntityCount int
		,OtherMetrics nvarchar(256)
		,FundCreatorTitleHistory nvarchar(max)
		,FundCreatorBiographicalHistory nvarchar(max)
		,History nvarchar(max)
		,DocumentsProvider nvarchar(max)
		,AcquisitionMethodText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,ClassificationScheme nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,AbbreviationList nvarchar(max)
		,MicrofilmedArchivalEntityCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,DigitizedArchivalEntityCount int
		,Notes nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(256)
		,DocumentsDescription nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
	);

	DECLARE @LocalInventories TABLE 
	(
		Id int
		,SystemIdentifier uniqueidentifier
		,HasExternalSource bit
		,ExternalIdentifier int
		,StatusCode nvarchar(50)
		,StatusText nvarchar(50)
		,AvailabilityStatusCode int
		,AvailabilityStatusText nvarchar(256)
		,FundHasExternalSource bit
		,FundExternalIdentifier int
		,FundNumber nvarchar(50)
		,ArchiveCode int
		,ArchiveName nvarchar(max)
		,NumberArray nvarchar(10)
		,NumberNumeric int
		,Number nvarchar(50)
		,ApproxmateChronologicalScope nvarchar(max)
		,LinearMeters float
		,ArchivalEntityCount int
		,BoxCount int 
		,RollCount int
		,AudioDocumentArchivalEntityCount int
		,PhotoDocumentArchivalEntityCount int 
		,VideoDocumentArchivalEntityCount int
		,DigitalDocumentArchivalEntityCount int
		,OtherMetrics nvarchar(256)
		,FundCreatorTitleHistory nvarchar(max)
		,FundCreatorBiographicalHistory nvarchar(max)
		,History nvarchar(max)
		,DocumentsProvider nvarchar(max)
		,AcquisitionMethodText nvarchar(max)
		,CreationMethodText nvarchar(max)
		,OriginalityText nvarchar(max)
		,LanguageText nvarchar(max)
		,ClassificationScheme nvarchar(max)
		,DocumentsAccessDescription nvarchar(max)
		,AbbreviationList nvarchar(max)
		,MicrofilmedArchivalEntityCount int
		,NegativeFrameCount int
		,PositiveFrameCount int
		,DigitizedArchivalEntityCount int
		,Notes nvarchar(max)
		,DescriptionLevelCode nvarchar(50)
		,DescriptionLevelText nvarchar(256)
		,DocumentsDescription nvarchar(max)
		,StartDateYear int
		,StartDateMonth int
		,StartDateDay int
		,EndDateYear int
		,EndDateMonth int
		,EndDateDay int
		,HasNoChronologicalScope bit
	);

	IF @FundHasExternalSource = 1
	BEGIN 
		SET @RemoteInventoriesQuery = CAST('' as nvarchar(max)) +
		'SELECT -1 as Id
			  ,CAST(NULL as uniqueidentifier) as SystemIdentifier
			  ,CAST(1 as bit) as HasExternalSource
			  ,inventory.[LGid] as ExternalIdentifier
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''''3000-01-01 00:00:00.000'''') as StatusText
			  ,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''''3000-01-01 00:00:00.000'''') as AvailabilityStatusText
			  ,CAST(1 as bit) as FundHasExternalSource
			  ,(select LGid from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundExternalIdentifier
			  ,(select Number from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''''3000-01-01 00:00:00.000'''') as FundNumber
			  ,(select Code from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveCode
			  ,(select Name from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''''3000-01-01 00:00:00.000'''') as ArchiveName
			  ,(select Value from [Archiving].[dbo].Nomenclature n where n.Gid = inventory.InventoryArrayGid and n._retired = ''''3000-01-01 00:00:00.000'''') as NumberArray
			  ,inventory.[IntNumber] as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.[TextDate] as ApproxmateChronologicalScope
			  ,inventory.[LinearMeter] as LinearMeters
			  ,inventory.[AECount] as ArchivalEntityCount ' + '
			  ,inventory.[BoxesCount] as BoxCount
			  ,inventory.[RuloniTubusiCount] as RollCount
			  ,inventory.[AEFonoDocsCount] as AudioDocumentArchivalEntityCount
			  ,inventory.[AEPhotoDocsCount] as PhotoDocumentArchivalEntityCount
			  ,inventory.[AEVideoAudioDocsCount] as VideoDocumentArchivalEntityCount
			  ,inventory.[AEElectrDocsCount] as DigitalDocumentArchivalEntityCount
			  ,inventory.[ExtentOther] as OtherMetrics
			  ,inventory.[FundCreatorNameChanges] as FundCreatorTitleHistory
			  ,inventory.[FundFormerHistory] as FundCreatorBiographicalHistory
			  ,inventory.[ArchivalHistory] as History
			  ,inventory.[ImmediateSourceOfAcquisition] as DocumentsProvider ' + '
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''MethodOfAcquisition'''' for XML PATH('''''''')), 1, 1, '''''''') as AcquisitionMethodText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''CreatingType'''' for XML PATH('''''''')), 1, 1, '''''''') as CreationMethodText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''Originality'''' for XML PATH('''''''')), 1, 1, '''''''') as OriginalityText
			  ,STUFF(
				(select ''''; '''' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''''Language'''' for XML PATH('''''''')), 1, 1, '''''''') as LanguageText
			  ,inventory.[ClassificationScheme] as ClassificationScheme
			  ,inventory.[AccessConditions] as DocumentsAccessDescription
			  ,inventory.[Abbreviations] as AbbreviationList
			  ,inventory.[CopyMicrofilmAE] as MicrofilmedArchivalEntityCount ' + '
			  ,inventory.[CopyNegativFrames] as NegativeFrameCount
			  ,inventory.[CopyPositiveFrames] as PositiveFrameCount
			  ,inventory.[CopyDigitizedAE] as DigitizedArchivalEntityCount
			  ,inventory.[Note] as Notes
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''''3000-01-01 00:00:00.000'''') as DescriptionLevelText
			  ,inventory.[DocumentProperties] as DocumentsDescription
			  ,inventory.[StartDateYear] as StartDateYear
			  ,inventory.[StartDateMonth] as StartDateMonth
			  ,inventory.[StartDateDay] as StartDateDay
			  ,inventory.[EndDateYear] as EndDateYear
			  ,inventory.[EndDateMonth] as EndDateMonth
			  ,inventory.[EndDateDay] as EndDateDay
			  ,inventory.[IsNoDate] as HasNoChronologicalScope
		  FROM [Archiving].[dbo].[Inventory_Active] inventory
		 WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50)) + '
			AND (SELECT Gid FROM [dbo].[Nomenclature] n1 WHERE n1.Gid = inventory.LevelOfDescriptionGid AND n1._retired = ''''3000-01-01 00:00:00.000'''') <> 2172
		 ';
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @RemoteInventoriesQuery + ''' )';
		
		INSERT INTO @RemoteInventories 
		EXEC(@RemoteQuery)
	END

	IF @FundIdentifier IS NOT NULL
	BEGIN
		INSERT INTO @LocalInventories
		SELECT inventory.Id
			  ,inventory.SystemIdentifier as SystemIdentifier
			  ,inventory.HasExternalSource
			  ,inventory.ExternalIdentifier
			  ,inventory.StatusCode
			  ,inventory.StatusText
			  ,inventory.AvailabilityStatusCode
			  ,inventory.AvailabilityStatusText
			  ,inventory.FundHasExternalSource
			  ,inventory.FundExternalIdentifier
			  ,inventory.FundNumber
			  ,inventory.ArchiveCode
			  ,inventory.ArchiveName
			  ,inventory.NumberArray
			  ,inventory.NumberNumeric as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.ApproxmateChronologicalScope
			  ,inventory.LinearMeters
			  ,inventory.ArchivalEntityCount
			  ,inventory.BoxCount
			  ,inventory.RollCount
			  ,inventory.AudioDocumentArchivalEntityCount
			  ,inventory.PhotoDocumentArchivalEntityCount
			  ,inventory.VideoDocumentArchivalEntityCount
			  ,inventory.DigitalDocumentArchivalEntityCount
			  ,inventory.OtherMetrics
			  ,inventory.FundCreatorTitleHistory
			  ,inventory.FundCreatorBiographicalHistory
			  ,inventory.History
			  ,inventory.DocumentsProvider
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'ACQUISITION_METHOD' for XML PATH('')), 1, 1, '') as AcquisitionMethodText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'CREATION_METHOD' for XML PATH('')), 1, 1, '') as CreationMethodText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'ORIGINALITY' for XML PATH('')), 1, 1, '') as OriginalityText
			  ,STUFF(
				(select '; ' +  n.Text
				   from [dbo].[NomenclatureValues] nv 
				   join [N].Nomenclatures n on n.Id = nv.NomenclatureId 
				  where nv.EntityId = inventory.Id and nv.EntityType = 'inventory' and nv.NomenclatureCode = 'LANGUAGE' for XML PATH('')), 1, 1, '') as LanguageText
			  ,inventory.ClassificationScheme
			  ,inventory.DocumentsAccessDescription
			  ,inventory.AbbreviationList
			  ,inventory.MicrofilmedArchivalEntityCount
			  ,inventory.NegativeFrameCount
			  ,inventory.PositiveFrameCount
			  ,inventory.DigitizedArchivalEntityCount
			  ,inventory.Notes
			  ,inventory.DescriptionLevelCode
			  ,inventory.DescriptionLevelText
			  ,inventory.DocumentsDescription
			  ,inventory.StartDateYear
			  ,inventory.StartDateMonth
			  ,inventory.StartDateDay
			  ,inventory.EndDateYear
			  ,inventory.EndDateMonth
			  ,inventory.EndDateDay
			  ,inventory.HasNoChronologicalScope
		 FROM [dbo].[v_PublicInventories] inventory
		 WHERE inventory.FundSystemIdentifier = @FundIdentifier 
		   AND inventory.HasExternalSource = 0
		   AND inventory.Deleted = 0 
	END

	SELECT *
	  FROM
	  (
		 SELECT *
		   FROM @LocalInventories
		  UNION
		 SELECT *
		   FROM @RemoteInventories
	   ) inventories
	ORDER BY NumberNumeric
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetFundInventoriesCountPublic]
	@LinkedServer nvarchar(255) = '', 
	@FundIdentifier uniqueidentifier = NULL,
	@FundHasExternalSource bit,
	@FundExternalIdentifier int = NULL
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @RemoteInventories TABLE ( InventoryCount int );
	DECLARE @RemoteInventoriesCount int = 0;
	DECLARE @LocalInventoriesCount int = 0;

	DECLARE @RemoteInventoriesQuery nvarchar(max) = '';
    
	IF @FundHasExternalSource = 1
	BEGIN 
		SET @RemoteInventoriesQuery = CAST('' as nvarchar(max)) + '
			SELECT inventory.[LGid]
			FROM [Archiving].[dbo].[Inventory_Active] inventory
			WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50)) + '';
		
		DECLARE @RemoteQuery nvarchar(max) = 'SELECT COUNT(*) as InventoryCount FROM OPENQUERY(' +  @LinkedServer + ', ''SELECT inventory.[LGid]
			FROM [Archiving].[dbo].[Inventory_Active] inventory
			WHERE inventory.FundLGid = ' + CAST(@FundExternalIdentifier as nvarchar(50)) + '
				AND (SELECT Gid FROM [dbo].[Nomenclature] n1 WHERE n1.Gid = inventory.LevelOfDescriptionGid AND n1._retired = ''''3000-01-01 00:00:00.000'''') <> 2172'')';
		
		INSERT INTO @RemoteInventories
		EXEC(@RemoteQuery)

		SELECT TOP 1 @RemoteInventoriesCount = InventoryCount from @RemoteInventories
	END

	IF @FundIdentifier IS NOT NULL
	BEGIN
		SELECT @LocalInventoriesCount = COUNT(inventory.Id)
		  FROM [dbo].[v_PublicInventories] inventory
		 WHERE inventory.FundSystemIdentifier = @FundIdentifier 
		   AND inventory.HasExternalSource = 0
		   AND inventory.Deleted = 0
	END

	RETURN @LocalInventoriesCount + @RemoteInventoriesCount
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
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by CreationDateAsDateTime
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
				cast(fund.CreationDate AS datetime2(7)) as CreationDateAsDateTime,
				COALESCE(
					fund.ImmediateSourceOfAcquisition + '' / '' + ' + @methodOfAcquisitionQueryRemote +  ', 
					fund.ImmediateSourceOfAcquisition + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryRemote + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				cast(fund.AECount as bigint) as ArchiveEntitiesCount,
				isnull(fund.LinearMeters, 0) as LinearMeters,
				null as DigitalSize,
				TextDate,
				fund.Note
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND (fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1) 
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreatedOn, 104) as CreationDate,
				fund.CreatedOn as CreationDateAsDateTime,
				COALESCE(
					fund.DocumentsProvider + '' / '' + ' + @methodOfAcquisitionQueryLocal +  ',
					fund.DocumentsProvider + '' / '', 
					'' / '' + ' + @methodOfAcquisitionQueryLocal + ') as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				cast(fund.ArchivalEntityCount as bigint) as ArchiveEntitiesCount,
				isnull(fund.LinearMeters, 0) as LinearMeters,
				cast(fund.Bytes AS BIGINT) as DigitalSize, -- реално е MB, името на колоната трябва да се смени
				ApproxmateChronologicalScope as TextDate,
				fund.Notes as Note
			FROM Funds fund
			INNER JOIN Archives a ON a.Id = fund.ArchiveId AND a.Deleted = 0
			WHERE fund.ExternalIdentifier IS NULL AND fund.HasExternalSource = 0 AND fund.Deleted = 0 
				AND fund.DescriptionLevelCode IN(1, 2, 4)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(fund.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Archive nvarchar(256) NOT NULL,
				Number nvarchar(256) NULL,
				CreationDate varchar(50) NULL,
				CreationDateAsDateTime varchar(50) NULL,
				ImmediateSourceOfAcquisitionPlusMethodOfAcquisition nvarchar(MAX) NULL,
				Title nvarchar(MAX) NULL,
				ArchiveEntitiesCount bigint NULL,
				LinearMeters float NULL, 
				DigitalSize bigint NULL,
				TextDate nvarchar(MAX) NULL, -- по забележка на ИСДА сменя DocumentsEndDates
				Note nvarchar(MAX) NULL
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

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetReceiptsListReportSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@ArchiveCodes nvarchar(max) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null,
	@Page int = 1
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Fund_Modified as fund
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR (select a.Code from Archive a where a.Gid=fund.ArchiveGid) in  (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
				AND (fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 1) 
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)
					OR fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 3))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Funds 
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0
				AND DescriptionLevelCode IN(1, 2, 4)
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryBook] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1
	-- ,@ArchiveCodes nvarchar(max) = null -- по искане не ИСДА се маха, понеже данните са само от архив ЦДА
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage;

	DECLARE @sql VARCHAR(MAX);
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by IntNumber, Number
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';


	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT
				fund.Number,		
				coalesce(
					convert(varchar, fund.FARevicedOnDay, 104) + ''.'' + convert(varchar, fund.FARevicedOnMonth, 104) + ''.'' + convert(varchar, fund.FARecivedOnYear, 104), 
					convert(varchar, fund.FARecivedOnYear, 104)) as ReceivedOn,
				(select Value from Nomenclature n where n.Gid = fund.CountryGid) as CountryOfOrigin,
				coalesce(
					convert(varchar(10), fund.CopyNegativeRolls) + ''-'' + convert(varchar(10), fund.CopyNegativeFrames), 
					convert(varchar(10), fund.CopyNegativeRolls) + ''-'', 
					''-'' + convert(varchar(10), fund.CopyNegativeFrames)) as Negatives,
				coalesce(
					convert(varchar(10), fund.CopyPositiveRolls) + ''-'' + convert(varchar(10), fund.CopyPositiveFrames), 
					convert(varchar(10), fund.CopyPositiveRolls) + ''-'', 
					''-'' + convert(varchar(10), fund.CopyPositiveFrames)) as Positives,
				CAST(fund.CopyXerox as nvarchar(250)) as CopyXerox,
				fund.CopyDigital,
				(select cast(1 as bit) where exists(select 1 from Inventory_Modified i where i.FundLGid=fund.LGid)) as HasInventory,
				fund.InventoryShortDescroption as ShortDescription,
				fund.CreationAuthor,
				fund.Note,
				fund.IntNumber
			FROM Fund_Modified as fund
			WHERE fund.ArchiveGid = 41
				  AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 9) -- LevelOfDescription=КМФ';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
			SELECT
				''E'' + convert(varchar(256), InventoryNumber) as Number,			
				(isnull(convert(varchar, AcceptedOnDay) + ''.'', '''') + isnull(convert(varchar, AcceptedOnMonth) + ''.'', '''') + isnull(convert(varchar, AcceptedOnYear), '''')) as ReceivedOn,
				(select Text from [N].[Nomenclatures] n where n.Id = CountryId) as CountryOfOrigin,
				coalesce(
					convert(varchar(10), MicrofilmNegativeRollsCount) + ''-'' + convert(varchar(10), MicrofilmNegativeFramesCount), 
					convert(varchar(10), MicrofilmNegativeRollsCount) + ''-'', 
					''-'' + convert(varchar(10), MicrofilmNegativeFramesCount)) as Negatives,
				coalesce(
					convert(varchar(10), MicrofilmPositiveRollsCount) + ''-'' + convert(varchar(10), MicrofilmPositiveFramesCount), 
					convert(varchar(10), MicrofilmPositiveRollsCount) + ''-'', 
					''-'' + convert(varchar(10), MicrofilmPositiveFramesCount)) as Positives,
				convert(varchar(250), PhotoCopy) as CopyXerox,
				convert(varchar(250), DigitalCopy) as CopyDigital,
				NULL as HasInventory,
				Content as ShortDescription,
				Source as CreationAuthor,
				Notes as Note,
				InventoryNumber as IntNumber
			FROM films
			WHERE --ExternalIdentifier IS NULL AND HasExternalSource = 0
				Deleted = 0 
				AND ArchiveId = 28';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE (
				Number nvarchar(256) NULL,			
				ReceivedOn varchar(50) NULL,
				CountryOfOrigin nvarchar(MAX) NULL,
				Negatives nvarchar(21) NULL,
				Positives nvarchar(21) NULL,
				CopyXerox nvarchar(250) NULL,
				CopyDigital nvarchar(250) NULL,
				-- DigitalImages
				HasInventory bit NULL,
				ShortDescription nvarchar(MAX) NULL,
				CreationAuthor nvarchar(256) NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null
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
Go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetInventoryBookSummary] 
	@LinkedServer nvarchar(50),
	@ResultType int = 1 -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	--,@ArchiveCodes nvarchar(10) = null -- по искане не ИСДА се маха, понеже данните са само от архив ЦДА
AS
BEGIN
	DECLARE @sql VARCHAR(MAX);

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Fund_Modified as fund
			WHERE fund.ArchiveGid = 41
				  AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 9) -- LevelOfDescription=КМФ';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END
	
	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Films 
			WHERE --ExternalIdentifier IS NULL AND HasExternalSource = 0
				Deleted = 0 
				AND ArchiveId = 28';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteFundsTable TABLE ( 
				TotalRows bigint NULL
			);

			INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + '
		
			SELECT sum(u.TotalRows) as TotalRows
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
				AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
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
				AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
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
				AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @UserIdsInternal  + ''', '',''))) OR CAST(p.CreatedBy AS VARCHAR(50)) in (SELECT Element from dbo.SplitString(''' + @UserIdsInternal + ''', '','')))
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
					AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
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
					AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
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
					AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR CAST(p.CreatedBy AS VARCHAR(50)) in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
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
					AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
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
					AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
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
					AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR p.CreatedBy in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @UserGids + ''', '',''))) OR CAST(p.CreatedBy AS VARCHAR(50)) in (SELECT Element from dbo.SplitString(''' + @UserGids + ''', '','')))
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCompilationAndNTOOfEDocumentsReport]
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

	@FileFormats nvarchar(max) = null




AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by SortOrder, IntNumber, FundNumber asc
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
    	
	
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
			CAST(funds.ArchivalEntityCount as int) as AeCount,
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
			(select SUM(d.Bytes) from Documents as d where d.FundSystemIdentifier = funds.SystemIdentifier) as Bytes,
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
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
				
				
				OR ((select top 1 convert(varchar(4), n.Text, 104) from NomenclatureValues as v join N.Nomenclatures as n on n.Id = v.NomenclatureId where v.EntityId = funds.Id and v.EntityType = ''fund'' and v.NomenclatureCode = ''ACQUISITION_METHOD''and n.Deleted = 0 and v.Deleted = 0) in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
			
			
			AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
				OR (''-998'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
				
				
				OR ((select top 1  ProcessTypeId from Process as p where p.FundSystemIdentifier = funds.SystemIdentifier and p.Deleted = 0 and p.Completed = 1 order by p.CreatedOn DESC) in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))))	
			
			
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
				

		SET @sql = @localQuery + @sqlFinalPart;
	END

	EXEC (@sql);
END
GO

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

	@FileFormats nvarchar(max) = null
AS
BEGIN

	SET NOCOUNT ON;

   	--DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка
	--DECLARE @sqlFinalPart VARCHAR(MAX) = '
	--	offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин
    	




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
				[SortOrder] int null
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
				[SortOrder]
			)
	EXEC [sp_GetCompilationAndNTOOfEDocumentsReport]
	2147483647,
	@Page,
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
	@FileFormats

	SET @sql = '
		SELECT 
			COUNT(t.[FundNumber]) as FundsCount,
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

	--DROP TABLE #temp

	--SET @sql = @sql + @sqlFinalPart

	--print @sql;
	EXEC (@sql);
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetCompilationAndNTOOfEDocumentsSummary] 
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

	@FileFormats nvarchar(max) = null
AS
BEGIN

	SET NOCOUNT ON;


	DECLARE @sql VARCHAR(MAX);

	
		DECLARE @localQuery VARCHAR(max) = '
			SELECT COUNT_BIG(*) TotalRows
			FROM Funds 
			WHERE ExternalIdentifier IS NULL AND HasExternalSource = 0 AND Deleted = 0 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray a where a.Code = NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
					OR ((select top 1 convert(varchar(4), n.Text, 104) from NomenclatureValues as v join N.Nomenclatures as n on n.Id = v.NomenclatureId where v.EntityId = funds.Id and v.EntityType = ''fund'' and v.NomenclatureCode = ''ACQUISITION_METHOD'') in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.Status s where s.Code = StatusCode) in (select element from dbo.SplitString(''' + @StatusesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundType t where t.Code = TypeCode) in (select element from dbo.SplitString(''' + @FundTypesInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))) 
					
					
					OR ((select top 1 convert(varchar(4), ProcessTypeId, 104) from Process as p where p.FundId = funds.Id) in (select element from dbo.SplitString(''' + @ProcessTypes + ''', '',''))))
				
				
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
					OR (cast((select Process.CreatedOn from Process where funds.Id = Process.FundId) as date) >= cast(''' + COALESCE(@ProcessStartDate, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@ProcessEndDate, 'null') + ''' = ''null'') 
					OR (cast((select Process.UpdatedOn from Process where funds.Id = Process.FundId) as date) <= cast(''' + COALESCE(@ProcessEndDate, 'null') + ''' as datetime2)))
				
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FileFormats + ''', '',''))) 
					OR ((select convert(varchar(4), n.Text, 104) from NomenclatureValues as v join N.Nomenclatures as n on n.Id = v.NomenclatureId join Documents as d on n.Id = d.FileFormatCode where d.FundSystemIdentifier = funds.SystemIdentifier) in (select element from dbo.SplitString(''' + @FileFormats + ''', '',''))))';



		SET @sql = @localQuery;

	--print @sql;
	EXEC (@sql);
END
GO

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
				isnull(fund.LinearMeters, 0) as LinearMeters,
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
				fund.Bytes as DigitalSize,
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfRoughDocumentsReport]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null,
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
			CAST(0 as bigint) as Bytes
			FROM Inventory as inv
			inner join Fund_Modified as fund on inv.FundLGid = fund.LGid
			join Nomenclature as n on inv.LevelOfDescriptionGid = n.Gid
			WHERE
			fund._retired = ''3000-01-01''
			AND inv._retired = ''3000-01-01''
			AND n.Code = 6
			AND inv.StatusGid = 192
			AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (inv.TextDate = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))) OR (fund.TypeGid in (select element from dbo.SplitString(''' + @FundTypeGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @IndustryIndexGids + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
			AND ((''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' = ''null'') OR (cast(inv.StartDate as date) >= cast(''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' = ''null'') OR (cast(inv.EndDate as date) <= cast(''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(inv.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(inv.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
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
				,ISNULL(CAST(i.Bytes as bigint), 0) as Bytes
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
			WHERE idl.Code = 6 AND i.Deleted = 0 AND i.StatusCode = 10
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveInternal  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveInternal + ''', '',''))))
				
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
				Bytes bigint NULL

			);

			INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteTable
			UNION ALL
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
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveInternal nvarchar(max) = null,
	@FundTypeGids nvarchar(max) = null,
	@FundTypesInternal nvarchar(max) = null,
	@IndustryIndexGids nvarchar(max) = null,
	@IndustryIndexesInternal nvarchar(max) = null,
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
				Bytes bigint NULL
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
				Bytes
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

CREATE OR ALTER PROCEDURE [dbo].[sp_GetRegisterOfDigitizedDocumentsReport]
	@LinkedServer nvarchar(50),
	@ResultType int = 1, -- 1 - вземи всичко; 2 - вземи от ИСДА само; 3 - вземи от локалната база само
	@RowsOfPage int = 5000,
	@Page int = 1,
	@ArchiveCodes nvarchar(10) = null,
	@RegisteredFrom nvarchar(100) = null,
	@RegisteredTo nvarchar(100) = null
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @offset INT = (@Page - 1) * @RowsOfPage; --От кой до кой резултат да се вземат за съответната страница

	DECLARE @sql VARCHAR(MAX); --Контейнер за побиране на сглобената заявка

	DECLARE @sqlFinalPart VARCHAR(MAX) = '
		order by ArchiveSortOrder, FundNumber, InventoryNumber, ArchiveEntityNumber -- ако се добавят FundIntNumber, InventoryIntNumber, ArchivalEntityIntNumber бави твърде много
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only'; -- Независимо от източника на резултата, той се форматира по този начин

	IF @ResultType = 2 OR @ResultType = 1
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT 
			'''' as DocumentLink, -- Link_todo
			(select CAST(a.Code as nvarchar(10)) from archive as a where _retired = ''3000-01-01'' and Gid = d.ArchiveGid) as ArchiveCode,
			a.Name as ArchiveName,
			CAST(d.Gid as nvarchar(256)) as SystemId,
			(select n.Value FROM Nomenclature as n where _retired = ''3000-01-01'' and Gid = (SELECT LevelOfDescriptionGid from Fund_Modified f where f.LGid = d.FundLGid)) as LevelOfDescription,
			(select top 1 Number from Fund_Modified f where f.LGid = d.FundLGid) as FundNumber,
			(select i.Number from Inventory_Modified as i where i.LGid = d.InventoryLGid) as InventoryNumber,
			(select ae.Number from ArchiveEntity_Modified as ae where ae.LGid = d.AELGid) as ArchiveEntityNumber,
			CAST(d.Title as nvarchar(256)) as Title,
			CAST(convert(varchar, d.DOCreationDate, 104) as nvarchar(50)) as DocCreationDate,
			(select n.Value + '', ''
				from Nomenclature n
				inner join ObjectNomenclature objn on n.Gid = objn.NomenclatureGid and objn._retired = ''3000-01-01'' and objn.DocumentGid = d.Gid
				where 
				n._retired = ''3000-01-01''
				and n.[Type] = ''Annotated''
				FOR XML path(''''), elements) as Themes,
			(select n.Value FROM Nomenclature as n where _retired = ''3000-01-01'' and Gid = d.StatusGid) as DocStatus,
			CAST((select top(1) img.CreatedOn from Image as img where d.Gid = img.DocumentGid and img._retired = ''3000-01-01'') as nvarchar(50)) as CreationDateDO,
			0 as RecordsCountDO,
			NULL as Duration,
			CAST((
				select convert(varchar, max(p.ModifiedOn), 104)  
				from Document doc
				inner join Process p on p._retired = ''3000-01-01'' and p.Gid = doc.ProcessGid and p.TypeGid = 2124 and p.StepGid = 75
				where doc.LGid = d.lgid
			) as nvarchar(50)) as DigitalObjectRecreationDate,
			CAST(0 as bigint) as BytesDO, -- това по тяхно искане не трябва да се отчита
			case when isnull(d.DigitalObjectDeleted, 0) = 0 then ''Активен'' else ''Заличен'' end as StatusDO,
			d.DOCreationAuthor as Operator,
			NULL as CorrectionReturnDate,
			NULL as FinalCorrectionDate,
			CAST((
				select convert(varchar, max(p.ModifiedOn), 104)  
				from Document doc
				inner join Process p on p._retired = ''3000-01-01'' and p.Gid = doc.ProcessGid and p.TypeGid = 2123 and p.StepGid = 75
				where doc.LGid = d.lgid
			) as nvarchar(50)) as DigitalObjectAcceptanceDate,
			(select top 1 IntNumber from Fund_Modified f where f.LGid = d.FundLGid) as FundIntNumber,
			(select i.IntNumber from Inventory_Modified as i where i.LGid = d.InventoryLGid) as InventoryIntNumber,
			(select ae.IntNumber from ArchiveEntity_Modified as ae where ae.LGid = d.AELGid) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder
		FROM Document_Modified as d
		INNER JOIN Archive a ON a.Gid = d.ArchiveGid AND a._retired = ''3000-01-01''
		--inner join Fund_Modified f on f.LGid = d.FundLGid
		--inner join Inventory_Modified i on i.LGid = d.InventoryLGid
		--inner join ArchiveEntity_Modified ae on ae.LGid = d.AELGid
		LEFT OUTER JOIN [Image] img on d.Gid = img.DocumentGid and img._retired = ''3000-01-01''
		WHERE ISNULL(d.HasDigitalObject, 0) = 1
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))
			  AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(d.StartDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			  AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(d.EndDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
		GROUP BY
			d.LGid, 
			d.ArchiveGid, 
			d.CreationDate, 
			d.Title, 
			d.StatusGid, 
			d.DigitalObjectDeleted, 
			d.DigitalObjectDeleted, 
			d.DOCreationDate, 
			d.FundLGid, 
			d.InventoryLGid, 
			d.AELGid, 
			d.Gid,
			d.StartDateDay,
			d.StartDateMonth,
			d.StartDateYear,
			d.EndDateDay,
			d.EndDateMonth,
			d.EndDateYear,
			d.TextDate,
			d.DOCreationAuthor,
			a.Name,
			a.SortOrder--,
			--f.Number,
			--i.Number,
			--ae.Number
		'
			  
		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 3 OR @ResultType = 1
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = '
		SELECT 
			''Link_todo'' as DocumentLink,
			CAST((select a.Code FROM [Archives] as a where a.Id = ArchiveId) as nvarchar(256)) as ArchiveCode,
			a.Name as ArchiveName,
			CAST(d.SystemIdentifier as nvarchar(256)) as SystemId,
			(select fdl.Text FROM [N].[FundDescriptionLevel] as fdl where fdl.Code = (select f.DescriptionLevelCode FROM Funds f where f.SystemIdentifier = d.FundSystemIdentifier)) as LevelOfDescription,
			CAST((select f.Number FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as nvarchar(256)) as FundNumber,
			CAST((select i.Number FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as nvarchar(256)) as InventoryNumber,
			CAST((select ae.Number FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as nvarchar(256)) as ArchiveEntityNumber,
			CAST(d.Title as nvarchar(256)) as Title,
			CAST(d.CreatedOn as nvarchar(50)) as DocCreationDate,
			NULL as Themes,
			(select n.Text from N.Nomenclatures as n where n.Id = d.StatusCode and n.Deleted = 0) as DocStatus,
			CAST((select top(1) do.CreatedOn from DigitalObjects as do where do.DocumentSystemIdentifier = d.SystemIdentifier) as nvarchar(50)) as CreationDateDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
			d.DigitizedCopyCount as RecordsCountDO,
			CAST(d.Duration as nvarchar(256)) as Duration,
			NULL as DigitalObjectRecreationDate,
			isnull(d.Bytes, 0) as BytesDO,
			(select top(1) n.Text from N.Nomenclatures as n join DigitalObjects as do on n.Id = do.StatusCode where do.DocumentSystemIdentifier = d.SystemIdentifier and n.Deleted = 0) as StatusDO, -- тук се ползва top(1), за да не се чупи, но трябва да се изясни заданието
			NULL as Operator,
			NULL as CorrectionReturnDate,
			NULL as FinalCorrectionDate,
			NULL as DigitalObjectAcceptanceDate,
			CAST((select f.NumberNumeric FROM Funds as f where f.SystemIdentifier = d.FundSystemIdentifier) as nvarchar(256)) as FundIntNumber,
			CAST((select i.NumberNumeric FROM Inventories as i where i.SystemIdentifier = d.InventorySystemIdentifier) as nvarchar(256)) as InventoryIntNumber,
			CAST((select ae.NumberNumeric FROM ArchivalEntities as ae where ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier) as nvarchar(256)) as ArchivalEntityIntNumber,
			a.SortOrder as ArchiveSortOrder
		FROM Documents as d
		INNER JOIN Archives a ON a.Id = d.ArchiveId AND a.Deleted = 0
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0 
			  AND exists(select 1 from DocumentDigitalObjects do where d.Id = do.DocumentId)
			  AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
			  OR ((select convert(varchar(4), Code, 104) from Archives a where a.Id = ArchiveId and a.deleted = 0) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
			  AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast((select top 1 DATEFROMPARTS(d.[StartDateYear], d.[StartDateMonth], d.[StartDateDay]) as result from Documents as d) as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
			  AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast((select top 1 DATEFROMPARTS(d.[EndDateYear], d.[EndDateMonth], d.[EndDateDay]) as result from Documents as d) as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))'

	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteDigitizedDocumentsTable TABLE (
				DocumentLink nvarchar(MAX) NULL,
				ArchiveCode nvarchar(256) NOT NULL,
				ArchiveName nvarchar(256) NOT NULL,
				SystemId nvarchar(256) NULL,
				LevelOfDescription nvarchar(MAX) NULL,
				FundNumber nvarchar(256) NULL,
				InventoryNumber nvarchar(256) NULL,
				ArchiveEntityNumber nvarchar(256) NULL,
				Title nvarchar(256) NULL,
				DocCreationDate nvarchar(50) NULL,
				Themes nvarchar(MAX) NULL,
				DocStatus nvarchar(MAX) NULL,
				CreationDateDO nvarchar(50) NULL,
				RecordsCountDO int NULL,
				Duration nvarchar(256) NULL,
				DigitalObjectRecreationDate nvarchar(50) NULL,
				BytesDO bigint NULL,
				StatusDO nvarchar(MAX) NULL,
				Operator nvarchar(MAX) NULL,
				CorrectionReturnDate nvarchar(50) NULL,
				FinalCorrectionDate nvarchar(50) NULL,
				DigitalObjectAcceptanceDate nvarchar(50) NULL,
				FundIntNumber INT NULL,
				InventoryIntNumber INT NULL,
				ArchivalEntityIntNumber INT NULL,
				ArchiveSortOrder int null
			);

			INSERT INTO @remoteDigitizedDocumentsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

			'SELECT * FROM @remoteDigitizedDocumentsTable
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

----------------------------------------------------------
--	THE SCRIPT IS CLOSED - USE THE NEW ONE!
----------------------------------------------------------


commit