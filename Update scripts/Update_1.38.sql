SET XACT_ABORT ON
GO

begin transaction

update dbo._Version 
set Value = '1.38'
where Code = 'DB_VERSION'
go

update dbo._Version 
set Value = '1.1.32'
where Code = 'APP_VERSION'
go




CREATE OR ALTER view [dbo].[v_Documents]
AS

SELECT d.Id
	  ,d.SystemIdentifier
      ,CAST(0 as bit) as IsDraft
	  ,d.IsSuspended
      ,d.ArchiveId
      ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,NULL as FundDraftId
      ,d.FundSystemIdentifier
      ,f.Number as FundNumber
	  ,f.NumberNumeric as FundNumberNumeric
	  ,f.NumberArray as FundNumberArray
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
	  ,f.DescriptionLevelCode as FundDescriptionLevelCode
	  ,f.StatusCode as FundStatusCode
      ,NULL as InventoryDraftId
      ,d.InventorySystemIdentifier
	  ,i.Number as InventoryNumber
	  ,i.NumberNumeric as InventoryNumberNumeric
	  ,i.NumberArray as InventoryNumberArray
	  ,i.HasExternalSource as InventoryHasExternalSource
	  ,i.ExternalIdentifier as InventoryExternalIdentifier
	  ,i.AvailabilityStatusCode  as InventoryAvailabilityStatusCode
	  ,i.DescriptionLevelCode as InventoryDescriptionLevelCode
	  ,i.StatusCode as InventoryStatusCode
	  ,NULL as ArchivalEntityDraftId
      ,d.ArchivalEntitySystemIdentifier
	  ,ae.Number as ArchivalEntityNumber
	  ,ae.NumberNumeric AS ArchivalEntityNumberNumeric
	  ,ae.NumberArray as ArchivalEntityNumberArray
	  ,ae.HasExternalSource as ArchivalEntityHasExternalSource
	  ,ae.ExternalIdentifier as ArchivalEntityExternalIdentifier
	  ,ae.AvailabilityStatusCode as ArchivalEntityAvailabilityStatusCode
	  ,ae.DescriptionLevelCode as ArchivalEntityDescriptionLevelCode
	  ,ae.StatusCode as ArchivalEntityStatusCode
	  ,d.CreatedOn
      ,d.CreatedBy
      ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,d.UpdatedOn
      ,d.UpdatedBy
      ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,d.Deleted
      ,d.DeletedOn
      ,d.DeletedBy
      ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,d.HasExternalSource
      ,d.ExternalIdentifier
      ,d.ExternalSourceUpdatedOn
      ,d.Number
      ,d.Title
      ,d.DescriptionLevelCode
	  ,l.Text as DescriptionLevelText
	  ,d.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
      ,d.StatusCode
	  ,s.Text as StatusText
	  ,d.FileFormatCode
	  ,d.HasNoChronologicalScope
	  ,d.StartDateYear
	  ,d.StartDateMonth
	  ,d.StartDateDay
	  ,d.EndDateYear
	  ,d.EndDateMonth
	  ,d.EndDateDay
	  ,d.ApproxmateChronologicalScope
	  ,d.Author
	  ,d.Location
	  ,d.Bytes
	  ,d.SheetCount
	  ,d.StartSheetNumber
	  ,d.EndSheetNumber
	  ,d.DigitalDevice
	  ,d.OtherMetrics
	  ,d.SizeCm
	  ,d.Scaling
	  ,d.Duration
	  ,d.Description
	  ,d.DocumentsAccessDescription
	  ,d.Features
	  ,d.MicrofilmedCopyCount
	  ,d.DigitizedCopyCount
	  ,d.PaperCopyCount
	  ,d.NegativeFrameCount
	  ,d.PositiveFrameCount
	  ,d.OtherCopyCount
	  ,d.Transcription
	  ,d.Notes
	  ,d.IsImported
	  ,d.DescriptionAuthor
	  ,d.Cypher
	  ,d.TextDocsCount
	  ,d.GraphicalDocsCount
	  ,d.Phase
	  ,d.Part
	  ,d.Stage
	  ,d.OtherLanguage
	  , case when (select IsNull(count(A.Id),0) from v_DigitalObjects A 
				  where A.DocumentSystemIdentifier = d.SystemIdentifier 
				  and A.IsDraft = 0 
				  and A.IsDigitized = 1) > 0 
			 then 1 else 0 end as HasDigitizedDigitalObjects

  FROM dbo.Documents d
  JOIN dbo.Archives a ON d.ArchiveId = a.Id
  JOIN dbo.Funds f ON d.FundSystemIdentifier = f.SystemIdentifier
  JOIN dbo.Inventories i ON d.InventorySystemIdentifier = i.SystemIdentifier
  JOIN dbo.ArchivalEntities ae ON d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier 
  LEFT JOIN dbo.DocumentDrafts dd on d.SystemIdentifier = dd.SystemIdentifier and dd.IsCurrent = 1
  LEFT JOIN N.DocumentDescriptionLevel l ON d.DescriptionLevelCode = l.Code
  LEFT JOIN N.AvailabilityStatus ast ON d.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON d.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON d.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON d.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON d.CreatedBy = du.Id
 WHERE dd.Id IS NULL


 UNION

 
 SELECT dd.Id
	   ,dd.SystemIdentifier
       ,CAST(1 as bit) as IsDraft
	   ,CAST(0 as bit) as IsSuspended
       ,dd.ArchiveId
       ,a.Code as ArchiveCode
	   ,a.Name as ArchiveName
	   ,dd.FundDraftId
       ,dd.FundSystemIdentifier
       ,f.Number as FundNumber
	   ,f.NumberNumeric AS FundNumberNumeric
	   ,f.NumberArray as FundNumberArray
	   ,f.HasExternalSource as FundHasExternalSource
	   ,f.ExternalIdentifier as FundExternalIdentifier
	   ,f.DescriptionLevelCode as FundDescriptionLevelCode
	   ,f.StatusCode as FundStatusCode
       ,dd.InventoryDraftId
       ,dd.InventorySystemIdentifier
	   ,i.Number as InventoryNumber
	   ,i.NumberNumeric AS InventoryNumberNumeric
	   ,i.NumberArray as InventoryNumberArray
	   ,i.HasExternalSource as InventoryHasExternalSource
	   ,i.ExternalIdentifier as InventoryExternalIdentifier
	   ,i.AvailabilityStatusCode as InventoryAvailabilityStatusCode
	   ,i.DescriptionLevelCode as InventoryDescriptionLevelCode
	   ,i.StatusCode as InventoryStatusCode
	   ,dd.ArchivalEntityDraftId
       ,dd.ArchivalEntitySystemIdentifier
	   ,ae.Number as ArchivalEntityNumber
	   ,ae.NumberNumeric AS ArchivalEntityNumberNumeric
	   ,ae.NumberArray as ArchivalEntityNumberArray
	   ,ae.HasExternalSource as ArchivalEntityHasExternalSource
	   ,ae.ExternalIdentifier as ArchivalEntityExternalIdentifier
	   ,ae.AvailabilityStatusCode as ArchivalEntityAvailabilityStatusCode
	   ,ae.DescriptionLevelCode as ArchivalEntityDescriptionLevelCode
	   ,ae.StatusCode as ArchivalEntityStatusCode
	   ,dd.CreatedOn
       ,dd.CreatedBy
       ,cu.DisplayName as CreatedByDisplayName
	   ,cu.UserName as CreatedByUserName
	   ,dd.UpdatedOn
       ,dd.UpdatedBy
       ,uu.DisplayName as UpdatedByDisplayName
	   ,uu.UserName as UpdatedByUserName
       ,dd.Deleted
       ,dd.DeletedOn
       ,dd.DeletedBy
       ,du.DisplayName as DeletedByDisplayName
	   ,du.UserName as DeletedByUserName
       ,dd.HasExternalSource
       ,dd.ExternalIdentifier
       ,dd.ExternalSourceUpdatedOn
       ,dd.Number
       ,dd.Title
       ,dd.DescriptionLevelCode
	   ,l.Text as DescriptionLevelText
	   ,dd.AvailabilityStatusCode
	   ,ast.Text as AvailabilityStatusText
       ,dd.StatusCode
	   ,s.Text as StatusText
	   ,dd.FileFormatCode
	   ,dd.HasNoChronologicalScope
	   ,dd.StartDateYear
	   ,dd.StartDateMonth
	   ,dd.StartDateDay
	   ,dd.EndDateYear
	   ,dd.EndDateMonth
	   ,dd.EndDateDay
	   ,dd.ApproxmateChronologicalScope
	   ,dd.Author
	   ,dd.Location
	   ,dd.Bytes
	   ,dd.SheetCount
	   ,dd.StartSheetNumber
	   ,dd.EndSheetNumber
	   ,dd.DigitalDevice
	   ,dd.OtherMetrics
	   ,dd.SizeCm
	   ,dd.Scaling
	   ,dd.Duration
	   ,dd.Description
	   ,dd.DocumentsAccessDescription
	   ,dd.Features
	   ,dd.MicrofilmedCopyCount
	   ,dd.DigitizedCopyCount
	   ,dd.PaperCopyCount
	   ,dd.NegativeFrameCount
	   ,dd.PositiveFrameCount
	   ,dd.OtherCopyCount
	   ,dd.Transcription
	   ,dd.Notes
	   ,dd.IsImported
	   ,dd.DescriptionAuthor
	   ,dd.Cypher
	   ,dd.TextDocsCount
	   ,dd.GraphicalDocsCount
	   ,dd.Phase
	   ,dd.Part
	   ,dd.Stage
	   ,dd.OtherLanguage
	   , 0 as HasDigitizedDigitalObjects

  FROM dbo.DocumentDrafts dd
  JOIN dbo.Archives a ON dd.ArchiveId = a.Id
  LEFT JOIN dbo.Funds f ON dd.FundSystemIdentifier = f.SystemIdentifier
  LEFT JOIN dbo.FundDrafts fd ON dd.FundSystemIdentifier = fd.SystemIdentifier AND dd.FundDraftId = fd.Id 
  LEFT JOIN dbo.Inventories i ON dd.InventorySystemIdentifier = i.SystemIdentifier 
  LEFT JOIN dbo.InventoryDrafts id ON dd.InventorySystemIdentifier = id.SystemIdentifier AND dd.InventoryDraftId = id.Id
  LEFT JOIN dbo.ArchivalEntities ae ON dd.ArchivalEntitySystemIdentifier = ae.SystemIdentifier
  LEFT JOIN dbo.ArchivalEntityDrafts aed ON dd.ArchivalEntitySystemIdentifier = aed.SystemIdentifier AND dd.ArchivalEntityDraftId = aed.Id
  LEFT JOIN N.DocumentDescriptionLevel l ON dd.DescriptionLevelCode = l.Code
  LEFT JOIN N.AvailabilityStatus ast ON dd.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON dd.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON dd.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON dd.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON dd.CreatedBy = du.Id
 WHERE dd.IsCurrent = 1
GO




CREATE OR ALTER VIEW [dbo].[v_PublicDocuments] AS
	SELECT 
		d.Id, d.SystemIdentifier,
		CAST(0 AS bit) AS IsDraft,
		d.ArchiveId, 
		a.Code AS ArchiveCode,
		a.Name AS ArchiveName,
		NULL AS FundDraftId, 
		d.FundSystemIdentifier, 
		f.Number AS FundNumber, 
        f.NumberNumeric AS FundNumberNumeric,
		f.NumberArray as FundNumberArray,
		f.HasExternalSource AS FundHasExternalSource, 
		f.ExternalIdentifier AS FundExternalIdentifier,
		f.DescriptionLevelCode AS FundDescriptionLevelCode,
		f.StatusCode AS FundStatusCode,
		NULL AS InventoryDraftId, 
		d.InventorySystemIdentifier, 
		i.Number AS InventoryNumber, 
        i.NumberNumeric AS InventoryNumberNumeric,
		i.NumberArray AS InventoryNumberArray,
		i.HasExternalSource AS InventoryHasExternalSource,
		i.ExternalIdentifier AS InventoryExternalIdentifier,
		i.DescriptionLevelCode AS InventoryDescriptionLevelCode,
		i.StatusCode AS InventoryStatusCode,
		NULL AS ArchivalEntityDraftId, 
		d.ArchivalEntitySystemIdentifier, 
		ae.Number AS ArchivalEntityNumber, 
        ae.NumberNumeric AS ArchivalEntityNumberNumeric,
		ae.NumberArray as ArchivalEntityNumberArray,
		ae.HasExternalSource AS ArchivalEntityHasExternalSource, 
		ae.ExternalIdentifier AS ArchivalEntityExternalIdentifier,
		ae.DescriptionLevelCode AS ArchivalEntityDescriptionLevelCode,
		ae.StatusCode as ArchivalEntityStatusCode,
		d.CreatedOn,
		d.CreatedBy, 
		cu.DisplayName AS CreatedByDisplayName,
		cu.UserName AS CreatedByUserName, 
        d.UpdatedOn, 
		d.UpdatedBy, 
		uu.DisplayName AS UpdatedByDisplayName, 
		uu.UserName AS UpdatedByUserName,
		d.Deleted, 
		d.DeletedOn, 
		d.DeletedBy,
		du.DisplayName AS DeletedByDisplayName,
		du.UserName AS DeletedByUserName, 
        d.HasExternalSource, 
		d.ExternalIdentifier, 
		d.ExternalSourceUpdatedOn, 
		d.Number, 
		d.Title,
		d.DescriptionLevelCode, 
		l.Text AS DescriptionLevelText,
		d.StatusCode, 
		s.Text AS StatusText, 
		d.FileFormatCode, 
		d.HasNoChronologicalScope, 
        d.StartDateYear,
		d.StartDateMonth, 
		d.StartDateDay, 
		d.EndDateYear, 
		d.EndDateMonth, 
		d.EndDateDay, 
		d.ApproxmateChronologicalScope, 
		d.Author, 
		d.Location, 
		d.Bytes, 
		d.SheetCount,
		d.StartSheetNumber, 
		d.EndSheetNumber, 
        d.DigitalDevice,
		d.OtherMetrics,
		d.SizeCm, 
		d.Scaling,
		d.Duration, 
		d.Description, 
		d.DocumentsAccessDescription,
		d.Features,
		d.MicrofilmedCopyCount, 
		d.DigitizedCopyCount, 
		d.PaperCopyCount, 
		d.NegativeFrameCount, 
        d.PositiveFrameCount, 
		d.OtherCopyCount, 
		d.Transcription, 
		d.Notes,
		d.AvailabilityStatusCode,
		ast.Text as AvailabilityStatusText,
		case when (select IsNull(count(A.Id),0) from v_PublicDigitalObjects A 
				  where A.DocumentSystemIdentifier = d.SystemIdentifier 
				  and A.IsDraft = 0 
				  and A.IsDigitized = 1) > 0 
			 then 1 else 0 end as HasDigitizedDigitalObjects
	FROM dbo.Documents AS d 
		INNER JOIN dbo.Archives AS a ON d.ArchiveId = a.Id 
		INNER JOIN dbo.Funds AS f ON d.FundSystemIdentifier = f.SystemIdentifier
		INNER JOIN dbo.Inventories AS i ON d.InventorySystemIdentifier = i.SystemIdentifier 
		INNER JOIN dbo.ArchivalEntities AS ae ON d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier
		LEFT JOIN N.DocumentDescriptionLevel AS l ON d.DescriptionLevelCode = l.Code 
		LEFT JOIN N.Status AS s ON d.StatusCode = s.Code 
		LEFT JOIN dbo.AspNetUsers AS cu ON d.CreatedBy = cu.Id
		LEFT JOIN dbo.AspNetUsers AS uu ON d.UpdatedBy = uu.Id
		LEFT JOIN dbo.AspNetUsers AS du ON d.CreatedBy = du.Id
		LEFT JOIN N.AvailabilityStatus ast ON d.AvailabilityStatusCode = ast.Code
	WHERE f.IsSuspended = 0
	AND d.StatusCode <> 12 --статус отчислен
GO



CREATE OR ALTER PROCEDURE [dbo].[sp_GetDocumentsByArchiveEntity] 
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
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,ClassificationSchemeIndex nvarchar(250) null
		,HasDigitizedDigitalObjects bit
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
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,ClassificationSchemeIndex nvarchar(250) null
		,HasDigitizedDigitalObjects bit
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
		,d.[CreationDate] as CreatedOn
		,d.[CreationAuthor] as CreatedByDisplayName
		,d.[ModificationDate] as UpdatedOn
		,d.[ModificationAuthor] as UpdatedByDisplayName
		,null as ClassificationSchemeIndex
		,IsNull(d.[HasDigitalObject],0) as HasDigitizedDigitalObjects 
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
				,d.CreatedOn as CreatedOn
				,d.CreatedByDisplayName as CreatedByDisplayName
				,d.UpdatedOn as UpdatedOn
				,d.UpdatedBy as UpdatedByDisplayName
				,null as ClassificationSchemeIndex
				,d.HasDigitizedDigitalObjects
	     FROM [dbo].[v_Documents] d
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
	ORDER BY convert(int, Number)
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY

END
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
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,HasDigitizedDigitalObjects bit
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
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,HasDigitizedDigitalObjects bit
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
		,d.[CreationDate] as CreatedOn
		,d.[CreationAuthor] as CreatedByDisplayName
		,d.[ModificationDate] as UpdatedOn
		,d.[ModificationAuthor] as UpdatedByDisplayName
		,IsNull(d.[HasDigitalObject],0) as HasDigitizedDigitalObjects 
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
				,d.CreatedOn as CreatedOn
				,d.CreatedByDisplayName as CreatedByDisplayName
				,d.UpdatedOn as UpdatedOn
				,d.UpdatedBy as UpdatedByDisplayName
				,d.HasDigitizedDigitalObjects
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
	ORDER BY convert(int, Number)
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY	
END
GO





CREATE OR ALTER PROCEDURE [dbo].[SearchFundsForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@DescriptionLevelCodesInternal nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0,
	@SearchFileContent bit null = 0,
	@FileDbName nvarchar(50) = null,
	@FileBufferDbName nvarchar(50) = null
AS
BEGIN
	DECLARE @remoteFundQuery nvarchar(max), @kwds int, @fttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1
	if @Title is not null and len(@Title) >= 2 set @fttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @fttl IS NULL SET @rankRemote = ',kwds.[Rank] as Rank'; 
	IF @kwds <> 1 AND @fttl = 1 SET @rankRemote = ',fttl.[Rank] as Rank';
	IF @kwds = 1 AND @fttl = 1 SET @rankRemote = ',(isnull(kwds.[Rank], 0) + isnull(fttl.[Rank], 0)) as Rank';

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 AND @fttl IS NULL SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 
	IF @kwds <> 1 AND @fttl = 1 SET @rankFilterRemote = ' and fttl.[Rank] > 1';
	IF @kwds = 1 AND @fttl = 1 SET @rankFilterRemote = ' and isnull(kwds.[Rank], 0) > 1 and isnull(fttl.[Rank], 0) > 1';

	SET @remoteFundQuery = '';
	SET @remoteFundQuery = 'with fresults as (';
	set @remoteFundQuery = @remoteFundQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''fund'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = fund.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		NULL as InventoryNumber,
		NULL as ArchivalEntityNumber,
		NULL as KMFNumber,
		NULL as FilmCardNumber,
		fund.Title,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.TypeGid) as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.StatusGid) as StatusText,
		(select Value FROM Nomenclature n WHERE n.Gid= fund.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as FundDescriptionLevelText,		
		NULL as InventoryDescriptionLevelText,
		NULL as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		fund.LGid AS ExternalIdentifier,
		fund.TextDate as FundApproximateChronologicalScope,
		NULL as InventoryApproximateChronologicalScope,
		NULL as ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		fund.Gid AS FundGid,
		fund.IntNumber as FundIntNumber,
		NULL AS InventoryIntNumber,
		NULL AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		fund.Gid,
		fund.LGid'
		+ @rankRemote
		+ ',1 AS EntityTypeOrder
		, 0 as HasDigitizedDigitalObjects';

	if @SearchDrafts = 0 
		set @remoteFundQuery = @remoteFundQuery + '
			from Fund_Active as fund
		';
	else 
		set @remoteFundQuery = @remoteFundQuery + '
			from Fund_Modified as fund
		';

	if @kwds = 1 
		set @remoteFundQuery = @remoteFundQuery + '
			left join freetexttable(Fund,*,'''+ @KeyWords + ''') kwds on fund._id = kwds.[key]
		';

	if @fttl = 1 
		set @remoteFundQuery = @remoteFundQuery + '
			left join freetexttable(Fund,(Title,FundFormerNameChange), '''+ @Title + ''') fttl on fund._id = fttl.[key]
		';

	if @ArchiveGids is not null and @ArchiveGids <> '-999' 
		set @remoteFundQuery = @remoteFundQuery + '	
			where fund.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids);
	else 
		set @remoteFundQuery = @remoteFundQuery + '
			where 1 = 1'; 

	if @FundNumber is not null 
		set @remoteFundQuery = @remoteFundQuery + '
			and (fund.Number = ''' + @FundNumber + ''')
		';
	
	-- Ако е за публичната част се махат тези със статус отчислен <> 2115 статус Фонд с необр. документи <> 91
	--if @SearchDrafts = 0
	--	begin
	--		set @remoteFundQuery = @remoteFundQuery + 'and fund.StatusGid <> 2115';
	--		set @remoteFundQuery = @remoteFundQuery + 'and fund.LevelOfDescriptionGid <> 91';
	--	end
	
	-- Изключват се изрично КМФ
	set @remoteFundQuery = @remoteFundQuery + 'and fund.LevelOfDescriptionGid <> 2185';

	-- въведен е номер на фонд, но не е избрано някое от нивата на описание за фондове, така имплицитно се разбира, че нивото на описание е някое от нивата за фонд(така са го поискали в писмо)
	if @FundNumber is not null
		and not '20' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '21' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '22' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '91' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
	BEGIN
		if @SearchDrafts = 1
			begin
			set @remoteFundQuery = @remoteFundQuery + '
				and (fund.LevelOfDescriptionGid in (20,21,22,91))';
			end
		if @SearchDrafts = 0
			begin
				set @remoteFundQuery = @remoteFundQuery + '
					and (fund.LevelOfDescriptionGid in (20,21,22))';
			end
	END

	if @LevelOfDescriptionGids <> '-999'
		set @remoteFundQuery = @remoteFundQuery + 'and (fund.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )';

	if @ToDate is not null 
		set @remoteFundQuery = @remoteFundQuery + '
			and (''' + @ToDate +''' >= fund.CreationDate)
		';

	if @FromDate is not null 
		set @remoteFundQuery = @remoteFundQuery + '
			and (''' + @FromDate + ''' <= fund.CreationDate)
		';

	IF @SearchDigitalObject = 1
	BEGIN
		IF (@SearchDrafts = 1)
			set @remoteFundQuery = @remoteFundQuery + '
				AND (exists (select 1 from Document_Search_Modified doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
			';
		ELSE
			set @remoteFundQuery = @remoteFundQuery + '
				AND (exists (select 1 from Document_Search_Active doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
			';
	END
	ELSE IF @SearchDigitalObject = 0
	BEGIN
		IF (@SearchDrafts = 1)
			set @remoteFundQuery = @remoteFundQuery + '
				AND ( not exists (select 1 from Document_Search_Modified doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
			';
		ELSE
			set @remoteFundQuery = @remoteFundQuery + '
				AND ( not exists (select 1 from Document_Search_Active doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1)	)
			';
	END

	--if @SearchDigitalObject = 1 and  @SearchDrafts = 1  
	--	set @remoteFundQuery = @remoteFundQuery + '
	--		AND (exists (select 1 from Document_Search_Active doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
	--	';
	--else if @SearchDigitalObject = 1  
	--	set @remoteFundQuery = @remoteFundQuery + '
	--		AND (exists (select 1 from Document_Search_Modified doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
	--	';
	--else if @SearchDigitalObject = 0 and  @SearchDrafts = 1  
	--	set @remoteFundQuery = @remoteFundQuery + '
	--		AND ( not exists (select 1 from Document_Search_Active doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1)	)
	--	';
	--else if @SearchDigitalObject = 0  
	--	set @remoteFundQuery = @remoteFundQuery + '
	--		AND ( not exists (select 1 from Document_Search_Modified doc where doc.FundLGid = fund.LGid and doc.HasDigitalObject = 1))
	--	';

	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteFundQuery = @remoteFundQuery + '
		and ( fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	';

	set @remoteFundQuery = @remoteFundQuery + @rankFilterRemote;

	if @SearchDrafts = 1 set @remoteFundQuery=@remoteFundQuery+'),
		fresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,	
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder,
			HasDigitizedDigitalObjects
		from fresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = fresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131	)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteFundQuery=@remoteFundQuery+'),
		fresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,	
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder,
			HasDigitizedDigitalObjects
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteFundQuery = REPLACE(@remoteFundQuery, '''', '''''');

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	--if search file content exclude inventory metadata
	IF (@kwds = 1 AND @SearchFileContent <> 1)
	BEGIN
		SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsf.[KEY] as fId, null as fdId, kwdsf.[RANK] as RankKwds
			from freetexttable(Funds, *, ''' + @KeyWords + ''') kwdsf
			union 
			select null as fId, kwdsfd.[KEY] as fdId, kwdsfd.[RANK] as RankKwds  
			from freetexttable(FundDrafts, *, ''' + @KeyWords + ''') kwdsfd
		) kwds
		on (f.Id = kwds.fdId and f.IsDraft = 1) or (f.Id = kwds.fId and f.IsDraft = 0)';
	END
	--IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
	--	left join 
	--	(
	--		select kwdsf.[KEY] as fId, null as fdId, kwdsf.[RANK] as RankKwds
	--		from freetexttable(Funds, *, ''' + @KeyWords + ''') kwdsf
	--		union 
	--		select null as fId, kwdsfd.[KEY] as fdId, kwdsfd.[RANK] as RankKwds  
	--		from freetexttable(FundDrafts, *, ''' + @KeyWords + ''') kwdsfd
	--	) kwds
	--	on (f.Id = kwds.fdId and f.IsDraft = 1) or (f.Id = kwds.fId and f.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @fttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select fttf.[KEY] as fId, null as fdId, fttf.[RANK] as RankTitle   
			from freetexttable(Funds, (Title,FundCreatorTitleHistory), ''' + @Title + ''') fttf 
			union 
			select null as fId, fttfd.[KEY] as fdId, fttfd.[RANK] as RankTitle   
			from freetexttable(FundDrafts, (Title,FundCreatorTitleHistory), ''' + @Title + ''') fttfd
		) ftt
		on (f.Id = ftt.fdId and f.IsDraft = 1) or (f.Id = ftt.fId and f.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	--if searching file content exclude ranking from keywords
	IF (@SearchFileContent <> 1)
	BEGIN
		IF @kwds = 1 AND  @fttl IS NULL SET @rank = ',RankKwds as Rank';
		IF @kwds <> 1 AND @fttl = 1 SET @rank = ',RankTitle as Rank';
		IF @kwds = 1 AND @fttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';
	END
	ELSE
	BEGIN
		IF @fttl = 1 SET @rank = ',RankTitle as Rank';
	END
	--IF @kwds = 1 AND @fttl IS NULL SET @rank = ',RankKwds as Rank'; 
	--IF @kwds <> 1 AND @fttl = 1 SET @rank = ',RankTitle as Rank';
	--IF @kwds = 1 AND @fttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	DECLARE @rankKwdsGroupBy VARCHAR(MAX) = '';
	DECLARE @rankTitleGroupBy VARCHAR(MAX) = '';
	--if searching file content exclude ranking from keywords
	IF (@SearchFileContent <> 1)
	BEGIN
		IF @kwds = 1 AND @fttl IS NULL 
		BEGIN
			SET @rankFilter = ' and RankKwds > 1'; 
			SET @rankKwdsGroupBy = ',kwds.RankKwds';
		END
		IF @kwds <> 1 AND @fttl = 1 
		BEGIN
			SET @rankFilter = ' and RankTitle > 1';
			SET @rankTitleGroupBy = ',ftt.RankTitle';
		END
		IF @kwds = 1 AND @fttl = 1 
		BEGIN
			SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';
			SET @rankKwdsGroupBy = ',kwds.RankKwds';
			SET @rankTitleGroupBy = ',ftt.RankTitle';
		END
	END
	ELSE
	BEGIN
		IF @fttl = 1 
		BEGIN
			SET @rankFilter = ' and RankTitle > 1';
			SET @rankTitleGroupBy = ',ftt.RankTitle';
		END
	END
	--IF @kwds = 1 AND @fttl IS NULL
	--BEGIN
	--	 SET @rankFilter = ' and RankKwds > 1'; 
	--	 SET @rankKwdsGroupBy = ',kwds.RankKwds';
	--END
	--DECLARE @rankTitleGroupBy VARCHAR(MAX) = '';

	--IF @kwds <> 1 AND @fttl = 1 
	--BEGIN
	--	SET @rankFilter = ' and RankTitle > 1';
	--	SET @rankTitleGroupBy = ',ftt.RankTitle';
	--END

	--IF @kwds = 1 AND @fttl = 1
	--BEGIN
	--	SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';
	--	SET @rankKwdsGroupBy = ',kwds.RankKwds';
	--	SET @rankTitleGroupBy = ',ftt.RankTitle';
	--END

	--DECLARE @isSuspenedFilter VARCHAR(MAX) = '';
	--IF @SearchDrafts = 1  SET @isSuspenedFilter = '  AND f.IsSuspended = 0';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber IS NOT NULL SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' left join v_PublicDocuments d on d.FundSystemIdentifier = f.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' left join v_Documents d on d.FundSystemIdentifier = f.SystemIdentifier';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = f.StatusCode) <> 12';

	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	IF @SearchDrafts = 1 SET @digitalObjectsTable = 'v_DigitalObjects';
	
	DECLARE @digitalObjectsFilter VARCHAR(MAX) = '';
	IF @SearchDigitalObject = 1 SET @digitalObjectsFilter = ' and (exists(select 1 from ' + @digitalObjectsTable  + ' do 
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0'
			+ @suspended +
		'))';
	IF @SearchDigitalObject = 0 SET @digitalObjectsFilter = ' and (not exists(select 1 from ' + @digitalObjectsTable  + ' do
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0
		))';

	--Search in file content
	DECLARE @fileContentFilter VARCHAR(MAX) = '';
	IF @SearchFileContent = 1 AND @kwds = 1
	BEGIN
		DECLARE @fileContentBufferFilter nvarchar(max) = '';
		-- add search in buffer file content
		IF @SearchDrafts = 1
		BEGIN
			SET @fileContentBufferFilter = 
				'or EXISTS(
						select fc.stream_id, ffc.[KEY], ffc.[RANK], fc.name 
						  from [' + @FileBufferDbName + '].dbo.FileContent fc
						  join FREETEXTTABLE([' + @FileBufferDbName + '].dbo.FileContent, file_stream, ''' + @KeyWords + ''') ffc on fc.stream_id = ffc.[KEY]
						 where fc.name = fcdo.Name)';
		END

		--search file content in the registered file content
		SET @fileContentFilter = 
			'AND EXISTS(
				   select fcdo.FundSystemIdentifier, fcdo.InventorySystemIdentifier, fcdo.ArchivalEntitySystemIdentifier, fcdo.DocumentSystemIdentifier, fcdo.SystemIdentifier
				   from ' + @digitalObjectsTable + ' fcdo
				  where fcdo.FundSystemIdentifier = f.SystemIdentifier
					and (
						EXISTS(
							select fc.stream_id, ffc.[KEY], ffc.[RANK], fc.name 
							  from [' + @FileDbName + '].dbo.FileContent fc
							  join FREETEXTTABLE([' + @FileDbName + '].dbo.FileContent, file_stream, '''+ @KeyWords +''') ffc on fc.stream_id = ffc.[KEY]
							 where fc.name = fcdo.Name)
						' + @fileContentBufferFilter + '
					)
				)';
	END

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Funds' ELSE SET @table = 'v_PublicFunds';

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';

	DECLARE @descriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @FundNumber is not null and @DescriptionLevelCodesInternal = '-111' 
		set @descriptionLevelCodesFilter = '' 
	else
		set @descriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @DescriptionLevelCodesInternal + ''', '',''))) 
				OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''' + @DescriptionLevelCodesInternal + ''', '',''))))
		';

	DECLARE @localFundQuery VARCHAR(MAX) = '
		SELECT
			''fund'' AS EntityType,
			f.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = f.ArchiveId) as ArchiveName,
			f.Number as FundNumber,
			NULL as InventoryNumber,
			NULL as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			f.Title,
			(SELECT Text FROM [N].[FundType] ft where ft.Code = f.TypeCode) as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as StatusText,
			(SELECT Text FROM [N].[FundDescriptionLevel] dl where dl.Code = f.DescriptionLevelCode) as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			f.ApproxmateChronologicalScope as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as ArchivalEntityApproximateChronologicalScope,
			f.SystemIdentifier as FilmSystemIdentifier,
			NULL as FundGid,
			f.NumberNumeric AS FundIntNumber,
			NULL AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			1 as EntityTypeOrder,
			0 as HasDigitizedDigitalObjects
		FROM ' + @table + ' f'
		+ @freeTextTableByTitleJoin + 
		+ @freeTextTableByKwdsJoin + 
		+ @documentsJoin + '
		WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR (f.NumberArray in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (f.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @fundNumberFilter + '
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @descriptionLevelCodesFilter
			+ @digitalObjectsFilter
			+ @fileContentFilter
			+ @doNotGetAnythingFilter
			--+ @isSuspenedFilter
			+ @isDeductedFilter
			+ @rankFilter;

	--DECLARE @sql VARCHAR(MAX) = '
	--	DECLARE @remoteFundsTable TABLE (
	--		EntityType nvarchar(50) NULL,
	--		SystemIdentifier uniqueidentifier NULL,
	--		ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи го чупят в такъв случай
	--		FundNumber nvarchar(256) NULL,
	--		InventoryNumber nvarchar(256) NULL,
	--		ArchivalEntityNumber nvarchar(256) NULL, 
	--		KMFNumber nvarchar(256) NULL,
	--		FilmCardNumber nvarchar(256) NULL,
	--		Title nvarchar(MAX) NULL,
	--		TypeText nvarchar(MAX) NULL,
	--		StatusText nvarchar(MAX) NULL,
	--		FundDescriptionLevelText nvarchar(MAX) NULL,
	--		InventoryDescriptionLevelText nvarchar(MAX) NULL,
	--		ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
	--		HasExternalSource BIT NOT NULL,
	--		ExternalIdentifier INT NOT NULL,
	--		FundApproximateChronologicalScope nvarchar(256) NULL,
	--		InventoryApproximateChronologicalScope nvarchar(256) NULL,
	--		ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
	--		FilmSystemIdentifier uniqueidentifier NULL,
	--		FundGid int,
	--		FundIntNumber INT NULL,
	--		InventoryIntNumber INT NULL,
	--		ArchivalEntityIntNumber INT NULL,
	--		KMFIntNumber INT NULL,
	--		FilmCardIntNumber INT NULL,
	--		Rank INT,
	--		EntityTypeOrder INT
	--	);

	--	INSERT INTO @remoteFundsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteFundQuery +''');' + 

	--	'SELECT * FROM @remoteFundsTable
	--	UNION
	--	' +
	--	@localFundQuery + '
	--	GROUP BY 
	--		--f.EntityType, 
	--		f.SystemIdentifier,
	--		f.ArchiveName,
	--		f.Number,
	--		--f.InventoryNumber,
	--		--f.ArchivalEntityNumber,
	--		f.Title,
	--		--f.TypeText,
	--		--f.StatusText,
	--		--f.FundDescriptionLevelText,
	--		--f.InventoryDescriptionLevelText,
	--		f.HasExternalSource,
	--		f.ExternalIdentifier,
	--		--f.InventoryApproximateChronologicalScope,
	--		-- тези, ако ги няма, се чупи
	--		f.ArchiveId,
	--		f.TypeCode,
	--		f.StatusCode,
	--		f.DescriptionLevelCode,
	--		f.ApproxmateChronologicalScope
	--		' + @rankKwdsGroupBy + ' 
	--		' + @rankTitleGroupBy + ' 
	--		,f.NumberNumeric
	--';








	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteFundsTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи го чупят в такъв случай
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL, 
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NOT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT,
			HasDigitizedDigitalObjects BIT NULL
		);

		DECLARE @localFundsTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи го чупят в такъв случай
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL, 
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT,
			HasDigitizedDigitalObjects BIT NULL
		);

	';

	--if searching file content exclude external source rows (no file content in external source)
	IF (@SearchFileContent <> 1)
	BEGIN
		SET @sql = @sql + '
			INSERT INTO @remoteFundsTable SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @remoteFundQuery + ''' );'
	END
	
	SET @sql = @sql + '
		INSERT INTO @localFundsTable ' + @localFundQuery + '
			GROUP BY 
			--f.EntityType, 
			f.SystemIdentifier,
			f.ArchiveName,
			f.Number,
			--f.InventoryNumber,
			--f.ArchivalEntityNumber,
			f.Title,
			--f.TypeText,
			--f.StatusText,
			--f.FundDescriptionLevelText,
			--f.InventoryDescriptionLevelText,
			f.HasExternalSource,
			f.ExternalIdentifier,
			--f.InventoryApproximateChronologicalScope,
			-- тези, ако ги няма, се чупи
			f.ArchiveId,
			f.TypeCode,
			f.StatusCode,
			f.DescriptionLevelCode,
			f.ApproxmateChronologicalScope
			' + @rankKwdsGroupBy + ' 
			' + @rankTitleGroupBy + ' 
			,f.NumberNumeric
		';

	SET @sql = @sql + '
		SELECT *
		  FROM
		  (
			 SELECT *
			   FROM @remoteFundsTable
			  UNION
			 SELECT *
			   FROM @localFundsTable
		   ) funds
	';


	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
	--print @sql;
END
GO




CREATE OR ALTER PROCEDURE [dbo].[SearchInventoriesForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null,
	@FundArraysInternal nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0,
	@SearchFileContent bit null = 0,
	@FileDbName nvarchar(50) = null,
	@FileBufferDbName nvarchar(50) = null
AS
BEGIN
	DECLARE @remoteInventoryQuery nvarchar(max), @kwds int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1
	if @Title is not null and len(@Title) >= 2 set @ttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rankRemote = ',kwds.[Rank] as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankRemote = ',fttl.[Rank] as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rankRemote = ',(isnull(kwds.[Rank], 0) + isnull(fttl.[Rank], 0)) as Rank';

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilterRemote = ' and fttl.[Rank] > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilterRemote = ' and isnull(kwds.[Rank], 0) > 1 and isnull(fttl.[Rank], 0) > 1';

	SET @remoteInventoryQuery = '';
	SET @remoteInventoryQuery = 'with fresults as (';
	set @remoteInventoryQuery = @remoteInventoryQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''inventory'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = inventory.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		inventory.Number as InventoryNumber,
		NULL as ArchivalEntityNumber,
		NULL as KMFNumber,
		NULL as FilmCardNumber,
		fund.Title as Title,
		NULL as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = inventory.StatusGid) as StatusText,
		(select Value FROM Nomenclature n WHERE n.Gid= fund.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as FundDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= inventory.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as InventoryDescriptionLevelText,	
		NULL as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		inventory.LGid AS ExternalIdentifier,
		fund.TextDate AS FundApproximateChronologicalScope,
		inventory.TextDate AS InventoryApproximateChronologicalScope,
		NULL as ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		fund.Gid AS FundGid,
		fund.IntNumber as FundIntNumber,
		inventory.IntNumber AS InventoryIntNumber,
		NULL AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		inventory.Gid,
		inventory.LGid'
		+ @rankRemote
		+ ',2 AS EntityTypeOrder
		, 0 as HasDigitizedDigitalObjects';

	if @SearchDrafts = 0 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			from Inventory_Active as inventory
		';
	else 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			from Inventory_Modified as inventory
		';

	if @kwds = 1 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			left join freetexttable(Inventory,*, '''+ @KeyWords + ''') kwds on inventory._id = kwds.[key]
		';

	if @ttl = 1 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			left join freetexttable(Inventory,FundCreatorNameChanges, '''+ @Title + ''') fttl on inventory._id = fttl.[key]
		';

	if @SearchDrafts = 0 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			inner join Fund_Active fund on inventory.FundLGid = fund.LGid
		';

	if @SearchDrafts = 1 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			inner join Fund_Modified fund on inventory.FundLGid = fund.LGid
		';

	if @ArchiveGids is not null and @ArchiveGids <> '-999' 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
		where inventory.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
		where 1 = 1';

	if (@KMFCountriesOfOriginCodes is not null and @KMFCountriesOfOriginCodes <> '-999')
		set  @remoteInventoryQuery = @remoteInventoryQuery + '
			and ((select n.Value2 from Nomenclature n where n.Gid = fund.CountryGid and n.Type = ''FACountry'') in (''' + [dbo].[StringSplit3](@KMFCountriesOfOriginCodes) + '''))
			and (fund.LevelOfDescriptionGid = 2185 )
			and (inventory.LevelOfDescriptionGid = 2369 )
		';

	if @InventoryNumber is not null 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			and (inventory.Number = ''' + @InventoryNumber + ''')
		';

	if @FundNumber is not null 
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			and (fund.Number = ''' + @FundNumber + ''')
		';

	--if @FundLevelOfDescriptionGids is not null and @FundLevelOfDescriptionGids <> '-999' set @remoteInventoryQuery = @remoteInventoryQuery + '
		--and (fund.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@FundLevelOfDescriptionGids) + ' )
	--';
	
	if @InventoryNumber is not null  
		and not '2171' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2172' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2372' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			and (inventory.LevelOfDescriptionGid in (2171,2172,2372))
		';
	else if @InventoryNumber is null and @FundNumber is null
		and not '2171' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2172' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2372' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2369' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			and 1=2
		';
	else if @LevelOfDescriptionGids <> '-999'
		and ('2171' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')) 
			or '2172' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
			or '2372' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
			or '2369' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')))
		set @remoteInventoryQuery = @remoteInventoryQuery + '
			and (inventory.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )
		';

	-- Грубите описи да са видими само в служебната част на системата
	--if @SearchDrafts = 0 
	--	set @remoteInventoryQuery = @remoteInventoryQuery + '
	--	and (inventory.LevelOfDescriptionGid <> 2172)
	--	and (inventory.StatusGid <> 2115)
	--';

	if @ToDate is not null set @remoteInventoryQuery = @remoteInventoryQuery + '
		and (''' + @ToDate +''' >= inventory.CreationDate)
	';
	if @FromDate is not null set @remoteInventoryQuery = @remoteInventoryQuery + '
		and (''' + @FromDate + ''' <= inventory.CreationDate)
	';
	--if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteInventoryQuery = @remoteInventoryQuery + '
	--	and ((select FundArrayGid from ' + @fundsView + ' where LGid = inventory.FundLGid) in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	--';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteInventoryQuery = @remoteInventoryQuery + '
		and (fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +') 
	';
	set @remoteInventoryQuery = @remoteInventoryQuery + @rankFilterRemote;

	if @SearchDrafts = 1 set @remoteInventoryQuery=@remoteInventoryQuery+'),
		fresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder,
			HasDigitizedDigitalObjects
		from fresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = fresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131	)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteInventoryQuery=@remoteInventoryQuery+'),
		fresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,	
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder,
			HasDigitizedDigitalObjects
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	SET @remoteInventoryQuery = REPLACE(@remoteInventoryQuery, '''', '''''');

	DECLARE @fundsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = i.FundSystemIdentifier';
	IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = i.FundSystemIdentifier';

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	--if search file content exclude inventory metadata
	IF (@kwds = 1 AND @SearchFileContent <> 1)
	BEGIN
		SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsI.[KEY] as iId, null as iDId, kwdsI.[RANK] as RankKwds
			from freetexttable(Inventories, *, ''' + @KeyWords + ''') kwdsI
			union 
			select null as iId, kwdsID.[KEY] as iDId, kwdsID.[RANK] as RankKwds  
			from freetexttable(InventoryDrafts, *, ''' + @KeyWords + ''') kwdsID
		) kwds
		on (i.Id = kwds.iDId and i.IsDraft = 1) or (i.Id = kwds.iId and i.IsDraft = 0)';
	END
	--IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
	--	left join 
	--	(
	--		select kwdsI.[KEY] as iId, null as iDId, kwdsI.[RANK] as RankKwds
	--		from freetexttable(Inventories, *, ''' + @KeyWords + ''') kwdsI
	--		union 
	--		select null as iId, kwdsID.[KEY] as iDId, kwdsID.[RANK] as RankKwds  
	--		from freetexttable(InventoryDrafts, *, ''' + @KeyWords + ''') kwdsID
	--	) kwds
	--	on (i.Id = kwds.iDId and i.IsDraft = 1) or (i.Id = kwds.iId and i.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlI.[KEY] as iId, null as iDId, ttlI.[RANK] as RankTitle   
			from freetexttable(Inventories, FundCreatorTitleHistory, ''' + @Title + ''') ttlI 
			union 
			select null as iId, ttlId.[KEY] as iDId, ttlId.[RANK] as RankTitle   
			from freetexttable(InventoryDrafts, FundCreatorTitleHistory, ''' + @Title + ''') ttlId
		) ttl
		on (i.Id = ttl.iDId and i.IsDraft = 1) or (i.Id = ttl.iId and i.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	--if searching file content exclude ranking from keywords
	IF (@SearchFileContent <> 1)
	BEGIN
		IF @kwds = 1 AND  @ttl IS NULL SET @rank = ',RankKwds as Rank';
		IF @kwds <> 1 AND @ttl = 1 SET @rank = ',RankTitle as Rank';
		IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';
	END
	ELSE
	BEGIN
		IF @ttl = 1 SET @rank = ',RankTitle as Rank';
	END
	--IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	--IF @kwds <> 1 AND @ttl = 1 SET @rank = ',RankTitle as Rank';
	--IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	--if searching file content exclude ranking from keywords
	IF (@SearchFileContent <> 1)
	BEGIN
		IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
		IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
		IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';
	END
	ELSE
	BEGIN
		IF @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
	END
	--IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	--IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
	--IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';

	-- WTF? Suspended item must BE searchable!!!
	--DECLARE @isSuspenedFilter VARCHAR(MAX) = '';
	--IF @SearchDrafts = 1  SET @isSuspenedFilter = '  AND f.IsSuspended = 0 AND i.IsSuspended = 0';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';
	
	---??? Грубите описи са изключени още на ниво v_PublicInventories
	DECLARE @roughInventoriesFilter VARCHAR(MAX) = '';
	-- Грубите описи да са видими само в служебната част на системата
	IF @SearchDrafts = 0 SET @roughInventoriesFilter = ' AND i.DescriptionLevelCode <> ''6''';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = i.StatusCode) <> 12';

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' left join v_PublicDocuments d on d.InventorySystemIdentifier = i.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' left join v_Documents d on d.InventorySystemIdentifier = i.SystemIdentifier';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';

	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	IF @SearchDrafts = 1 SET @digitalObjectsTable = 'v_DigitalObjects';
	
	DECLARE @digitalObjectsFilter VARCHAR(MAX) = '';
	IF @SearchDigitalObject = 1 SET @digitalObjectsFilter = ' and (exists(select 1 from ' + @digitalObjectsTable  + ' do 
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0'
			+ @suspended +
		'))';
	IF @SearchDigitalObject = 0 SET @digitalObjectsFilter = ' and (not exists(select 1 from ' + @digitalObjectsTable  + ' do
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0
		))';

	--Search in file content
	DECLARE @fileContentFilter VARCHAR(MAX) = '';
	IF @SearchFileContent = 1 AND @kwds = 1
	BEGIN
		DECLARE @fileContentBufferFilter nvarchar(max) = '';
		-- add search in buffer file content
		IF @SearchDrafts = 1
		BEGIN
			SET @fileContentBufferFilter = 
				'or EXISTS(
						select fc.stream_id, ffc.[KEY], ffc.[RANK], fc.name 
						  from [' + @FileBufferDbName + '].dbo.FileContent fc
						  join FREETEXTTABLE([' + @FileBufferDbName + '].dbo.FileContent, file_stream, ''' + @KeyWords + ''') ffc on fc.stream_id = ffc.[KEY]
						 where fc.name = fcdo.Name)'
		END

		--search file content in the registered file content
		SET @fileContentFilter = 
			'AND EXISTS(
				   select fcdo.FundSystemIdentifier, fcdo.InventorySystemIdentifier, fcdo.ArchivalEntitySystemIdentifier, fcdo.DocumentSystemIdentifier, fcdo.SystemIdentifier
				   from ' + @digitalObjectsTable + ' fcdo
				  where fcdo.InventorySystemIdentifier = i.SystemIdentifier
					and (
						EXISTS(
							select fc.stream_id, ffc.[KEY], ffc.[RANK], fc.name 
							  from [' + @FileDbName + '].dbo.FileContent fc
							  join FREETEXTTABLE([' + @FileDbName + '].dbo.FileContent, file_stream, '''+ @KeyWords +''') ffc on fc.stream_id = ffc.[KEY]
							 where fc.name = fcdo.Name)
						' + @fileContentBufferFilter + '
					)
				)'
		
	END

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Inventories' ELSE SET @table = 'v_PublicInventories';

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';

	DECLARE @inventoryDescriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @InventoryNumber is not null and @FundDescriptionLevelCodesInternal = '-111' set @FundDescriptionLevelCodesInternal = '-999';
	if @InventoryNumber is not null and @InventoryDescriptionLevelCodesInternal = '-111' 
		set @inventoryDescriptionLevelCodesFilter = '' 
	else
		set @inventoryDescriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))) 
				OR (i.DescriptionLevelCode in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))))
		';

	DECLARE @localInventoryQuery VARCHAR(MAX) = '
		SELECT
			''inventory'' AS EntityType,
			i.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = i.ArchiveId) as ArchiveName,	
			f.Number as FundNumber,
			i.Number as InventoryNumber,
			NULL as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			NULL as Title,
			NULL as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = i.StatusCode) as StatusText,
			(SELECT Text FROM [N].[FundDescriptionLevel] fdl where fdl.Code = f.DescriptionLevelCode) as FundDescriptionLevelText,
			(SELECT Text FROM [N].[InventoryDescriptionLevel] idl where idl.Code = i.DescriptionLevelCode) as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			f.ApproxmateChronologicalScope as FundApproximateChronologicalScope,
			i.ApproxmateChronologicalScope as InventoryApproximateChronologicalScope,
			NULL as ArchivalEntityApproximateChronologicalScope,
			NULL as FilmSystemIdentifier,
			NULL as FundGid,
			i.FundNumberNumeric AS FundIntNumber,
			i.NumberNumeric AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			2 as EntityTypeOrder,
			0 as HasDigitizedDigitalObjects
		FROM ' + @table + ' i'
		+ @fundsJoin + 
		+ @documentsJoin +
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE i.ExternalIdentifier IS NULL AND i.HasExternalSource = 0 AND i.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (i.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundDescriptionLevel fdl where fdl.Code = f.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(i.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(i.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @inventoryDescriptionLevelCodesFilter
			+ @doNotGetAnythingFilter
			--+ @isSuspenedFilter
			+ @roughInventoriesFilter
			+ @digitalObjectsFilter
			+ @fileContentFilter
			+ @isDeductedFilter
			+ @rankFilter;



		DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteInventoriesTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL,
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL,
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NOT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT,
			HasDigitizedDigitalObjects INT NULL
		);

		DECLARE @localInventoriesTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL,
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL,
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT,
			HasDigitizedDigitalObjects BIT NULL
		);

	';

	--if searching file content exclude external source rows (no file content in external source)
	IF (@SearchFileContent <> 1)
	BEGIN
		SET @sql = @sql + '
			INSERT INTO @remoteInventoriesTable SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @remoteInventoryQuery + ''' );'
	END
	
	SET @sql = @sql + '
		INSERT INTO @localInventoriesTable ' + @localInventoryQuery;

	SET @sql = @sql + '
		SELECT *
		  FROM
		  (
			 SELECT *
			   FROM @remoteInventoriesTable
			  UNION
			 SELECT *
			   FROM @localInventoriesTable
		   ) inventories
	';


	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	PRINT (@sql);

	EXEC (@sql);
END
GO 




CREATE OR ALTER PROCEDURE [dbo].[SearchArchivalEntitiesForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodesInternal nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null,
	@FundArraysInternal nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0,
	@SearchFileContent bit null = 0,
	@FileDbName nvarchar(50) = null,
	@FileBufferDbName nvarchar(50) = null
AS
BEGIN
	DECLARE @remoteAEQuery nvarchar(max), @kwds int, @kwdsAnnotated int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1;
	--set @kwdsAnnotated=0;
	--if @KeywordsUIAnnotated is not null and len(@KeywordsUIAnnotated) >=2 set @kwdsAnnotated=1;
	if @Title is not null and len(@Title) >= 2 set @ttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rankRemote = ',kwds.[Rank] as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankRemote = ',fttl.[Rank] as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rankRemote = ',(isnull(kwds.[Rank], 0) + isnull(fttl.[Rank], 0)) as Rank';

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilterRemote = ' and fttl.[Rank] > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilterRemote = ' and isnull(kwds.[Rank], 0) > 1 and isnull(fttl.[Rank], 0) > 1';

	SET @remoteAEQuery = '';
	SET @remoteAEQuery = 'with fresults as (';
	set @remoteAEQuery = @remoteAEQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''archival_entity'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = ae.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		inventory.Number as InventoryNumber,
		ae.Number as ArchivalEntityNumber,
		NULL as KMFNumber,
		NULL as FilmCardNumber,
		ae.Title,
		NULL as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = ae.StatusGid) as StatusText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.LevelOfDescriptionGid) as FundDescriptionLevelText,	
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = inventory.LevelOfDescriptionGid) as InventoryDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		ae.LGid AS ExternalIdentifier,
		fund.TextDate AS FundApproximateChronologicalScope,
		inventory.TextDate AS InventoryApproximateChronologicalScope,
		ae.TextDate AS ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		NULL AS FundGid,
		fund.IntNumber as FundIntNumber,
		inventory.IntNumber AS InventoryIntNumber,
		ae.IntNumber AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		ae.Gid,
		ae.LGid'
		+ @rankRemote
		+ ',3 AS EntityTypeOrder
		, 0 as HasDigitizedDigitalObjects';

	if @SearchDrafts = 1 set @remoteAEQuery = @remoteAEQuery + '
		from ArchiveEntity_Active as ae
	';
	else set @remoteAEQuery = @remoteAEQuery + '
		from ArchiveEntity_Modified as ae
	';
	if @SearchDrafts = 1 set @remoteAEQuery = @remoteAEQuery + '
		inner join Inventory_Active inventory on inventory.LGid=ae.InventoryLGid
	';
	else set @remoteAEQuery = @remoteAEQuery + '
		inner join Inventory_Modified inventory on inventory.LGid=ae.InventoryLGid
	';
	if @SearchDrafts = 1 set @remoteAEQuery = @remoteAEQuery + '
		inner join Fund_Active fund on fund.LGid=ae.FundLGid
	';
	else set @remoteAEQuery = @remoteAEQuery + '
		inner join Fund_Modified fund on fund.LGid=ae.FundLGid
	';
	if @kwds = 1 set @remoteAEQuery = @remoteAEQuery + '
		left join freetexttable(ArchiveEntity,*, '''+ @KeyWords + ''') kwds on ae._id = kwds.[key]
	';
	if @ttl = 1 set @remoteAEQuery = @remoteAEQuery + '
		left join freetexttable(ArchiveEntity,Title, '''+ @Title + ''') fttl on ae._id = fttl.[key]
	';
	--if @kwdsAnnotated =1 set @remoteAEQuery = @remoteAEQuery + '
		--inner join ObjectNomenclature on1 on on1.ArchiveEntityGid = ae.Gid and on1._retired = ''3000-01-01''
		--inner join Nomenclature n1 on on1.NomenclatureGid = n1.Gid and n1.[Type] = ''Annotated'' and n1._retired = ''3000-01-01''
		--inner join freetexttable(Nomenclature,*,@KeywordsUIAnnotated) fts1 on n1._id = fts1.[key] ';
	if @ArchiveGids is not null and @ArchiveGids <> '-999' set @remoteAEQuery = @remoteAEQuery + '
		where ae.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else set @remoteAEQuery = @remoteAEQuery + '
		where 1 = 1
	';
	set @remoteAEQuery = @remoteAEQuery + '
		and (fund.LevelOfDescriptionGid <> 2185 or ae.LevelOfDescriptionGid <> 2371)
	';
	--if @ArchivalEntityNumber is not null set @remoteAEQuery = @remoteAEQuery + '
		--and (ae.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired = ''3000-01-01'' and [Type] = ''LevelOfDescription'' AND Code = 11)) --Арх.ед. - копия от чужди архиви
	--';
	if @FundNumber is not null set @remoteAEQuery = @remoteAEQuery + '
		and (fund.Number = ''' + @FundNumber + ''')
	';
	if @InventoryNumber is not null set @remoteAEQuery = @remoteAEQuery + '
		and (inventory.Number = ''' + @InventoryNumber + ''')
	';
	if @ArchivalEntityNumber is not null set @remoteAEQuery = @remoteAEQuery + '
		and (ae.Number = ''' + @ArchivalEntityNumber + ''')
	';
	if @ArchivalEntityNumber is not null
		and not '2174' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2373' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteAEQuery = @remoteAEQuery + '
			and (ae.LevelOfDescriptionGid in (2174,2373))
	' 
	else if @ArchivalEntityNumber is null
		and not '2174' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '2373' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		and not '-999' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ','))
		set @remoteAEQuery = @remoteAEQuery + '
			and 1=2
	' 
	else if @LevelOfDescriptionGids <> '-999'
		and ('2174' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')) or '2373' in (select element from dbo.SplitString(@LevelOfDescriptionGids, ',')))
		set @remoteAEQuery = @remoteAEQuery + '
			and (ae.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )
	';
	if @ToDate is not null set @remoteAEQuery = @remoteAEQuery + '
		and (''' + @ToDate +''' >= ae.CreationDate)
	';
	if @FromDate is not null set @remoteAEQuery = @remoteAEQuery + '
		and (''' + @FromDate + ''' <= ae.CreationDate)
	';
	--if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteAEQuery = @remoteAEQuery + '
	--	and ((select FundArrayGid from ' + @fundsView + ' where LGid = inventory.FundLGid) in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	--';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteAEQuery = @remoteAEQuery + '
		and (fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +') 
	'
	if @SearchDigitalObject = 1 and  @SearchDrafts = 1  set @remoteAEQuery = @remoteAEQuery + '
		AND (exists (select 1 from Document_Search_Active doc where doc.AELGid = ae.LGid and doc.HasDigitalObject = 1))
	';
	else if @SearchDigitalObject = 1  set @remoteAEQuery = @remoteAEQuery + '
		AND (exists (select 1 from Document_Search_Modified doc where doc.AELGid = ae.LGid and doc.HasDigitalObject = 1))
	';
	else if @SearchDigitalObject = 0 and  @SearchDrafts = 1  set @remoteAEQuery = @remoteAEQuery + '
		AND ( not exists (select 1 from Document_Search_Active doc where doc.AELGid = ae.LGid and doc.HasDigitalObject = 1)	)
	';
	else if @SearchDigitalObject = 0  set @remoteAEQuery = @remoteAEQuery + '
		AND (not exists (select 1 from Document_Search_Modified doc where doc.AELGid = ae.LGid and doc.HasDigitalObject = 1))
	';	
	set @remoteAEQuery = @remoteAEQuery + @rankFilterRemote;


	if @SearchDrafts = 1 set @remoteAEQuery=@remoteAEQuery+'),
		fresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder,
			HasDigitizedDigitalObjects
		from fresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = fresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131	)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteAEQuery=@remoteAEQuery+'),
		fresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,	
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder,
			HasDigitizedDigitalObjects
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	SET @remoteAEQuery = REPLACE(@remoteAEQuery, '''', '''''');

	DECLARE @fundsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = ae.FundSystemIdentifier';
	IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = ae.FundSystemIdentifier';

	DECLARE @inventoriesJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @inventoriesJoin = ' inner join v_Inventories i on i.SystemIdentifier = ae.InventorySystemIdentifier';
	IF @SearchDrafts = 0 SET @inventoriesJoin = ' inner join v_PublicInventories i on i.SystemIdentifier = ae.InventorySystemIdentifier';

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	--if search file content exclude AE metadata
	IF (@kwds = 1 AND @SearchFileContent <> 1)
	BEGIN
		SET @freeTextTableByKwdsJoin = ' 
			left join 
			(
				select kwdsAE.[KEY] as aeId, null as aeDId, kwdsAE.[RANK] as RankKwds
				from freetexttable(ArchivalEntities, *, ''' + @KeyWords + ''') kwdsAE
				union 
				select null as aeId, kwdsAED.[KEY] as aeDId, kwdsAED.[RANK] as RankKwds  
				from freetexttable(ArchivalEntityDrafts, *, ''' + @KeyWords + ''') kwdsAED
			) kwds
			on (ae.Id = kwds.aeDId and ae.IsDraft = 1) or (ae.Id = kwds.aeId and ae.IsDraft = 0)';
	END
	--IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
	--	left join 
	--	(
	--		select kwdsAE.[KEY] as aeId, null as aeDId, kwdsAE.[RANK] as RankKwds
	--		from freetexttable(ArchivalEntities, *, ''' + @KeyWords + ''') kwdsAE
	--		union 
	--		select null as aeId, kwdsAED.[KEY] as aeDId, kwdsAED.[RANK] as RankKwds  
	--		from freetexttable(ArchivalEntityDrafts, *, ''' + @KeyWords + ''') kwdsAED
	--	) kwds
	--	on (ae.Id = kwds.aeDId and ae.IsDraft = 1) or (ae.Id = kwds.aeId and ae.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlAE.[KEY] as aeId, null as aeDId, ttlAE.[RANK] as RankTitle   
			from freetexttable(ArchivalEntities, Title, ''' + @Title + ''') ttlAE 
			union 
			select null as aeId, ttlAEd.[KEY] as aeDId, ttlAEd.[RANK] as RankTitle   
			from freetexttable(ArchivalEntityDrafts, Title, ''' + @Title + ''') ttlAEd
		) ttl
		on (ae.Id = ttl.aeDId and ae.IsDraft = 1) or (ae.Id = ttl.aeId and ae.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	--if searching file content exclude ranking from keywords
	IF (@SearchFileContent <> 1)
	BEGIN
		IF @kwds = 1 AND  @ttl IS NULL SET @rank = ',RankKwds as Rank';
		IF @kwds <> 1 AND @ttl = 1 SET @rank = ',RankTitle as Rank';
		IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';
	END
	ELSE
	BEGIN
		IF @ttl = 1 SET @rank = ',RankTitle as Rank';
	END
	--IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	--IF @kwds <> 1 AND @ttl = 1 SET @rank = ',RankTitle as Rank';
	--IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	--if searching file content exclude ranking from keywords
	IF (@SearchFileContent <> 1)
	BEGIN
		IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
		IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
		IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';
	END
	ELSE
	BEGIN
		IF @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
	END
	--IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	--IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
	--IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';

	-- WTF? Suspended item must BE searchable!!!
	--DECLARE @isSuspenedFilter VARCHAR(MAX) = '';
	--IF @SearchDrafts = 1  SET @isSuspenedFilter = ' AND f.IsSuspended = 0 AND i.IsSuspended = 0 AND ae.IsSuspended = 0';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberFilter VARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NOT NULL SET @archivalEntityNumberFilter = ' AND ae.Number=''' + @ArchivalEntityNumber + '''';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND (SELECT s.Code FROM [N].[Status] s where s.Code = ae.StatusCode) <> 12';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_ArchivalEntities' ELSE SET @table = 'v_PublicArchivalEntities';

	DECLARE @documentsJoin VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin= ' left join v_PublicDocuments d on d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier';
	IF @SearchDrafts = 1 AND @SearchDigitalObject IS NOT NULL SET @documentsJoin = ' left join v_Documents d on d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';

	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	IF @SearchDrafts = 1 SET @digitalObjectsTable = 'v_DigitalObjects';
	DECLARE @digitalObjectsFilter VARCHAR(MAX) = '';
	IF @SearchDigitalObject = 1 SET @digitalObjectsFilter = ' and (exists(select 1 from ' + @digitalObjectsTable  + ' do 
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0'
			+ @suspended +
		'))';
	IF @SearchDigitalObject = 0 SET @digitalObjectsFilter = ' and (not exists(select 1 from ' + @digitalObjectsTable  + ' do
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0
		))';


	--Search in file content
	DECLARE @fileContentFilter VARCHAR(MAX) = '';
	IF @SearchFileContent = 1 AND @kwds = 1
	BEGIN
		DECLARE @fileContentBufferFilter nvarchar(max) = '';
		-- add search in buffer file content
		IF @SearchDrafts = 1
		BEGIN
			SET @fileContentBufferFilter = 
				'or EXISTS(
						select fc.stream_id, ffc.[KEY], ffc.[RANK], fc.name 
						  from [' + @FileBufferDbName + '].dbo.FileContent fc
						  join FREETEXTTABLE([' + @FileBufferDbName + '].dbo.FileContent, file_stream, ''' + @KeyWords + ''') ffc on fc.stream_id = ffc.[KEY]
						 where fc.name = fcdo.Name)'
		END

		--search file content in the registered file content
		SET @fileContentFilter = 
			'AND EXISTS(
				   select fcdo.FundSystemIdentifier, fcdo.InventorySystemIdentifier, fcdo.ArchivalEntitySystemIdentifier, fcdo.DocumentSystemIdentifier, fcdo.SystemIdentifier
				   from ' + @digitalObjectsTable + ' fcdo
				  where fcdo.ArchivalEntitySystemIdentifier = ae.SystemIdentifier
					and (
						EXISTS(
							select fc.stream_id, ffc.[KEY], ffc.[RANK], fc.name 
							  from [' + @FileDbName + '].dbo.FileContent fc
							  join FREETEXTTABLE([' + @FileDbName + '].dbo.FileContent, file_stream, '''+ @KeyWords +''') ffc on fc.stream_id = ffc.[KEY]
							 where fc.name = fcdo.Name)
						' + @fileContentBufferFilter + '
					)
				)'
		
	END

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';		

	DECLARE @archivalEntityDescriptionLevelCodesFilter VARCHAR(MAX) = '';
	if @ArchivalEntityNumber is not null and @FundDescriptionLevelCodesInternal = '-111' set @FundDescriptionLevelCodesInternal = '-999';
	if @ArchivalEntityNumber is not null and @InventoryDescriptionLevelCodesInternal = '-111' set @InventoryDescriptionLevelCodesInternal = '-999';
	if @ArchivalEntityNumber is not null and @ArchivalEntityDescriptionLevelCodesInternal = '-111' 
		set @archivalEntityDescriptionLevelCodesFilter = '' 
	else
		set @archivalEntityDescriptionLevelCodesFilter = '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodesInternal + ''', '',''))) 
				OR (ae.DescriptionLevelCode in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodesInternal + ''', '',''))))
		';

	DECLARE @localAEQuery VARCHAR(MAX) = '
		SELECT
			''archival_entity'' AS EntityType,
			ae.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = i.ArchiveId) as ArchiveName,	
			f.Number as FundNumber,
			i.Number as InventoryNumber,
			ae.Number as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			ae.Title as Title,
			NULL as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = ae.StatusCode) as StatusText,
			(SELECT Text FROM [N].[FundDescriptionLevel] fdl where fdl.Code = f.DescriptionLevelCode) as FundDescriptionLevelText,
			(SELECT Text FROM [N].[InventoryDescriptionLevel] idl where idl.Code = i.DescriptionLevelCode) as InventoryDescriptionLevelText,
			(SELECT Text FROM [N].[ArchivalEntityDescriptionLevel] aedl where aedl.Code = ae.DescriptionLevelCode) as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			f.ApproxmateChronologicalScope as FundApproximateChronologicalScope,
			i.ApproxmateChronologicalScope as InventoryApproximateChronologicalScope,
			ae.ApproxmateChronologicalScope as  ArchivalEntityApproximateChronologicalScope,
			NULL as FilmSystemIdentifier,
			NULL as FundGid,
			ae.FundNumberNumeric AS FundIntNumber,
			ae.InventoryNumberNumeric AS InventoryIntNumber,
			ae.NumberNumeric AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			3 as EntityTypeOrder,
			0 as HasDigitizedDigitalObjects
		FROM ' + @table + ' ae'
		+ @inventoriesJoin +
		+ @fundsJoin + 
		+ @documentsJoin +
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE ae.ExternalIdentifier IS NULL AND ae.HasExternalSource = 0 AND ae.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (ae.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + 
			+ @archivalEntityNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.FundDescriptionLevel fdl where fdl.Code = f.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))) 
				OR ((select convert(varchar(4), Code, 104) from N.InventoryDescriptionLevel idl where idl.Code = i.DescriptionLevelCode) in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(ae.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(ae.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @archivalEntityDescriptionLevelCodesFilter
			+ @doNotGetAnythingFilter
			--+ @isSuspenedFilter
			+ @digitalObjectsFilter
			+ @fileContentFilter
			+ @isDeductedFilter
			+ @rankFilter;


	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteAETable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL,
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL,
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NOT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT,
			HasDigitizedDigitalObjects BIT NULL
		);

		DECLARE @localAETable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL,
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL,
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT,
			HasDigitizedDigitalObjects BIT NULL
		);

	';

	--if searching file content exclude external source rows (no file content in external source)
	IF (@SearchFileContent <> 1)
	BEGIN
		SET @sql = @sql + '
			INSERT INTO @remoteAETable SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @remoteAEQuery + ''' );'
	END
	
	SET @sql = @sql + '
		INSERT INTO @localAETable ' + @localAEQuery;

	SET @sql = @sql + '
		SELECT *
		  FROM
		  (
			 SELECT *
			   FROM @remoteAETable
			  UNION
			 SELECT *
			   FROM @localAETable
		   ) archivalEntities
	';


	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO



CREATE OR ALTER PROCEDURE [dbo].[SearchDocumentsForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodesInternal nvarchar(256) = null,
	@DocumentDescriptionLevelCodesInternal nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	--@KeywordsUIAnnotated nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0,
	@SearchFileContent bit null = 0,
	@FileDbName nvarchar(50) = null,
	@FileBufferDbName nvarchar(50) = null
AS
BEGIN
	DECLARE @remoteDocumentsQuery nvarchar(max), @kwds int, @kwdsAnnotated int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1;
	--set @kwdsAnnotated=0;
	--if @KeywordsUIAnnotated is not null and len(@KeywordsUIAnnotated) >=2 set @kwdsAnnotated=1;
	if @Title is not null and len(@Title) >= 2 set @ttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rankRemote = ',kwds.[Rank] as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankRemote = ',fttl.[Rank] as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rankRemote = ',(isnull(kwds.[Rank], 0) + isnull(fttl.[Rank], 0)) as Rank';

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilterRemote = ' and fttl.[Rank] > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilterRemote = ' and isnull(kwds.[Rank], 0) > 1 and isnull(fttl.[Rank], 0) > 1';

	SET @remoteDocumentsQuery = '';
	SET @remoteDocumentsQuery = 'with dresults as (';
	set @remoteDocumentsQuery = @remoteDocumentsQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''document'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = doc.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		inventory.Number as InventoryNumber,
		ae.Number as ArchivalEntityNumber,
		NULL as KMFNumber,
		NULL as FilmCardNumber,
		doc.Title,
		NULL as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = doc.StatusGid) as StatusText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.LevelOfDescriptionGid) as FundDescriptionLevelText,	
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = inventory.LevelOfDescriptionGid) as InventoryDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		doc.LGid AS ExternalIdentifier,
		NULL AS FundApproximateChronologicalScope,
		NULL AS InventoryApproximateChronologicalScope,
		NULL AS ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		NULL AS FundGid,
		fund.IntNumber as FundIntNumber,
		inventory.IntNumber AS InventoryIntNumber,
		ae.IntNumber AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		doc.Gid,
		doc.LGid'
		+ @rankRemote
		+ ',4 AS EntityTypeOrder
		,IsNull(doc.HasDigitalObject, 0) as HasDigitizedDigitalObjects ';

	if @SearchDrafts = 1 set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		from Document_Active as doc
	';
	else set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		from Document_Modified as doc
	';
	if @SearchDrafts = 1 set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		inner join ArchiveEntity_Search_Active ae on ae.LGid=doc.AELGid
	';
	else set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		inner join ArchiveEntity_Search_Modified ae on ae.LGid=doc.AELGid
	';
	if @SearchDrafts = 1 set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		inner join Inventory_Search_Active inventory on inventory.LGid=doc.InventoryLGid
	';
	else set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		inner join Inventory_Search_Modified inventory on inventory.LGid=doc.InventoryLGid
	';
	if @SearchDrafts = 1 set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		inner join Fund_Search_Active fund on fund.LGid=doc.FundLGid
	';
	else set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		inner join Fund_Search_Modified fund on fund.LGid=doc.FundLGid
	';
	if @kwds = 1 set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		left join freetexttable(Document,*, '''+ @KeyWords + ''') kwds on doc._id = kwds.[key]
	';
	if @ttl = 1 set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		left join freetexttable(Document,Title, '''+ @Title + ''') fttl on doc._id = fttl.[key]
	';
	--if @kwdsAnnotated =1 set @sql = @sql + '
    --inner join ObjectNomenclature on1 on on1.DocumentGid = doc.Gid and on1._retired = ''3000-01-01''
	--inner join Nomenclature n1 on on1.NomenclatureGid = n1.Gid and n1.[Type] = ''Annotated'' and n1._retired = ''3000-01-01''
	--inner join freetexttable(Nomenclature,*,@KeywordsUIAnnotated) fts1 on n1._id = fts1.[key] '
	if @ArchiveGids is not null and @ArchiveGids <> '-999' set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		where doc.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		where 1 = 1
	';
	--if @ArchivalEntityNumber is not null set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		--and (ae.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired = ''3000-01-01'' and [Type] = ''LevelOfDescription'' AND Code = 11)) --Арх.ед. - копия от чужди архиви
	--';
	if @FundNumber is not null set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		and (fund.Number = ''' + @FundNumber + ''')
	';
	if @InventoryNumber is not null set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		and (inventory.Number = ''' + @InventoryNumber + ''')
	';
	if @ArchivalEntityNumber is not null set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		and (ae.Number = ''' + @ArchivalEntityNumber + ''')
	';
	if @LevelOfDescriptionGids is not null and @LevelOfDescriptionGids <> '-999' set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		and (doc.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) + ' )
	';
	if @ToDate is not null set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		and (''' + @ToDate +''' >= doc.CreationDate)
	';
	if @FromDate is not null set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		and (''' + @FromDate + ''' <= doc.CreationDate)
	';
	--if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteDocumentsQuery = @remoteDocumentsQuery + '
	--	and ((select FundArrayGid from ' + @fundsView + ' where LGid = inventory.FundLGid) in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	--';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		and (fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +') 
	'

	if @SearchDigitalObject = 1 set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		AND doc.HasDigitalObject = 1
	';
	else if @SearchDigitalObject = 0  set @remoteDocumentsQuery = @remoteDocumentsQuery + '
		AND doc.HasDigitalObject = 0
	';
	set @remoteDocumentsQuery = @remoteDocumentsQuery + @rankFilterRemote;

	if @SearchDrafts = 1 set @remoteDocumentsQuery=@remoteDocumentsQuery+'),
		dresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from dresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder,
			HasDigitizedDigitalObjects
		from dresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = dresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteDocumentsQuery=@remoteDocumentsQuery+'),
		dresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from dresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,	
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder,
			HasDigitizedDigitalObjects
		from dresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteDocumentsQuery = REPLACE(@remoteDocumentsQuery, '''', '''''');



	--DECLARE @fundsJoin VARCHAR(MAX) = '';
	--IF @SearchDrafts = 1 SET @fundsJoin = ' inner join v_Funds f on f.SystemIdentifier = d.FundSystemIdentifier';
	--IF @SearchDrafts = 0 SET @fundsJoin = ' inner join v_PublicFunds f on f.SystemIdentifier = d.FundSystemIdentifier';

	--DECLARE @inventoriesJoin VARCHAR(MAX) = '';
	--IF @SearchDrafts = 1 SET @inventoriesJoin = ' inner join v_Inventories i on i.SystemIdentifier = d.InventorySystemIdentifier';
	--IF @SearchDrafts = 0 SET @inventoriesJoin = ' inner join v_PublicInventories i on i.SystemIdentifier = d.InventorySystemIdentifier';

	--DECLARE @archivalEntitiesJoin VARCHAR(MAX) = '';
	--IF @SearchDrafts = 1 SET @archivalEntitiesJoin = ' inner join v_ArchivalEntities ae on ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier';
	--IF @SearchDrafts = 0 SET @archivalEntitiesJoin = ' inner join v_PublicArchivalEntities ae on ae.SystemIdentifier = d.ArchivalEntitySystemIdentifier';

	--Fix must be if drafts or no drafts
	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	--if search file content exclude document metadata
	IF (@kwds = 1 AND @SearchFileContent <> 1)
	BEGIN
		SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsD.[KEY] as dId, null as dDId, kwdsD.[RANK] as RankKwds
			from freetexttable(Documents, *, ''' + @KeyWords + ''') kwdsD
			union 
			select null as dId, kwdsDD.[KEY] as dDId, kwdsDD.[RANK] as RankKwds  
			from freetexttable(DocumentDrafts, *, ''' + @KeyWords + ''') kwdsDD
		) kwds
		on (d.Id = kwds.dDId and d.IsDraft = 1) or (d.Id = kwds.dId and d.IsDraft = 0)';
	END

	--Fix must be if drafts or no drafts
	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlD.[KEY] as dId, null as dDId, ttlD.[RANK] as RankTitle   
			from freetexttable(Documents, Title, ''' + @Title + ''') ttlD 
			union 
			select null as dId, ttlDd.[KEY] as dDId, ttlDd.[RANK] as RankTitle   
			from freetexttable(DocumentDrafts, Title, ''' + @Title + ''') ttlDd
		) ttl
		on (d.Id = ttl.dDId and d.IsDraft = 1) or (d.Id = ttl.dId and d.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	--if searching file content exclude ranking from keywords
	IF (@SearchFileContent <> 1)
	BEGIN
		IF @kwds = 1 AND  @ttl IS NULL SET @rank = ',RankKwds as Rank';
		IF @kwds <> 1 AND @ttl = 1 SET @rank = ',RankTitle as Rank';
		IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(RankTitle, 0)) as Rank';
	END
	ELSE
	BEGIN
		IF @ttl = 1 SET @rank = ',RankTitle as Rank';
	END

	
	DECLARE @rankFilter VARCHAR(MAX) = '';
	--if searching file content exclude ranking from keywords
	IF (@SearchFileContent <> 1)
	BEGIN
		IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
		IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
		IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(RankTitle, 0) > 1';
	END
	ELSE
	BEGIN
		IF @ttl = 1 SET @rankFilter = ' and RankTitle > 1';
	END
	

	-- WTF? Suspended item must BE searchable!!!
	--DECLARE @isSuspendedFilter VARCHAR(MAX) = '';
	--IF @SearchDrafts = 1  SET @isSuspendedFilter = '  AND f.IsSuspended = 0 AND i.IsSuspended = 0  AND ae.IsSuspended = 0 and d.IsSuspended = 0';

	DECLARE @fundNumberFilter VARCHAR(MAX) = '';
	--IF @FundNumber is not null  SET @fundNumberFilter = ' AND f.Number=''' + @FundNumber + '''';
	IF @FundNumber is not null  SET @fundNumberFilter = ' AND d.FundNumber=''' + @FundNumber + '''';

	DECLARE @inventoryNumberFilter VARCHAR(MAX) = '';
	--IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND i.Number=''' + @InventoryNumber + '''';
	IF @InventoryNumber IS NOT NULL SET @inventoryNumberFilter = ' AND d.InventoryNumber=''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberFilter VARCHAR(MAX) = '';
	--IF @ArchivalEntityNumber IS NOT NULL SET @archivalEntityNumberFilter = ' AND ae.Number=''' + @ArchivalEntityNumber + '''';
	IF @ArchivalEntityNumber IS NOT NULL SET @archivalEntityNumberFilter = ' AND d.ArchivalEntityNumber=''' + @ArchivalEntityNumber + '''';

	DECLARE @isDeductedFilter VARCHAR(MAX) = '';
	IF @SearchDrafts = 0  SET @isDeductedFilter = ' AND d.StatusCode <> 12';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Documents' ELSE SET @table = 'v_PublicDocuments';

	DECLARE @suspended VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 AND @SearchDigitalObject IS NOT NULL SET @suspended= ' and do.IsSuspended = 0';
	
	DECLARE @digitalObjectsTable VARCHAR(MAX) = '';
	IF @SearchDrafts = 0 SET @digitalObjectsTable = 'DigitalObjects';
	--IF @SearchDrafts = 0 SET @digitalObjectsTable = 'v_PublicDigitalObjects';
	IF @SearchDrafts = 1 SET @digitalObjectsTable = 'v_DigitalObjects';
	
	DECLARE @digitalObjectsFilter VARCHAR(MAX) = '';
	IF @SearchDigitalObject = 1 SET @digitalObjectsFilter = ' and (exists(select 1 from ' + @digitalObjectsTable  + ' do 
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0'
			+ @suspended +
		'))';
	IF @SearchDigitalObject = 0 SET @digitalObjectsFilter = ' and (not exists(select 1 from ' + @digitalObjectsTable  + ' do
		where 
			d.SystemIdentifier = do.DocumentSystemIdentifier
			and d.Deleted = 0
			and do.Deleted = 0
		))';

	--Search in file content
	DECLARE @fileContentFilter VARCHAR(MAX) = '';
	IF @SearchFileContent = 1 AND @kwds = 1
	BEGIN
		DECLARE @fileContentBufferFilter nvarchar(max) = '';
		-- add search in buffer file content
		IF @SearchDrafts = 1
		BEGIN
			SET @fileContentBufferFilter = 
				'or EXISTS(
						select fc.stream_id, ffc.[KEY], ffc.[RANK], fc.name 
						  from [' + @FileBufferDbName + '].dbo.FileContent fc
						  join FREETEXTTABLE([' + @FileBufferDbName + '].dbo.FileContent, file_stream, ''' + @KeyWords + ''') ffc on fc.stream_id = ffc.[KEY]
						 where fc.name = fcdo.Name)'
		END

		--search file content in the registered file content
		SET @fileContentFilter = 
			'AND EXISTS(
				   select fcdo.FundSystemIdentifier, fcdo.InventorySystemIdentifier, fcdo.ArchivalEntitySystemIdentifier, fcdo.DocumentSystemIdentifier, fcdo.SystemIdentifier
				   from ' + @digitalObjectsTable + ' fcdo
				  where fcdo.DocumentSystemIdentifier = d.SystemIdentifier
					and (
						EXISTS(
							select fc.stream_id, ffc.[KEY], ffc.[RANK], fc.name 
							  from [' + @FileDbName + '].dbo.FileContent fc
							  join FREETEXTTABLE([' + @FileDbName + '].dbo.FileContent, file_stream, '''+ @KeyWords +''') ffc on fc.stream_id = ffc.[KEY]
							 where fc.name = fcdo.Name)
						' + @fileContentBufferFilter + '
					)
				)'
		
	END
	


	--WTF???
	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';		

	DECLARE @localDocumentsQuery VARCHAR(MAX) = '
		SELECT
			''document'' AS EntityType,
			d.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = d.ArchiveId) as ArchiveName,	
			d.FundNumber as FundNumber,
			d.InventoryNumber as InventoryNumber,
			d.ArchivalEntityNumber as ArchivalEntityNumber,
			NULL as KMFNumber,
			NULL as FilmCardNumber,
			d.Title as Title,
			NULL as TypeText,
			(SELECT Text FROM [N].[Status] s where s.Code = d.StatusCode) as StatusText,
			NULL as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			NULL as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as  ArchivalEntityApproximateChronologicalScope,
			NULL as FilmSystemIdentifier,
			NULL as FundGid,
			d.FundNumberNumeric AS FundIntNumber,
			d.InventoryNumberNumeric AS InventoryIntNumber,
			d.ArchivalEntityNumberNumeric AS ArchivalEntityIntNumber,
			NULL AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			4 as EntityTypeOrder,
			d.HasDigitizedDigitalObjects
		FROM ' + @table + ' d'
		--+ @fundsJoin + 
		--+ @inventoriesJoin +
		--+ @archivalEntitiesJoin +
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE d.ExternalIdentifier IS NULL AND d.HasExternalSource = 0 AND d.Deleted = 0
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
				OR (d.FundNumberArray in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (d.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @fundNumberFilter + 
			+ @inventoryNumberFilter + 
			+ @archivalEntityNumberFilter + '
			AND ((''-999'' in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))) 
				OR (d.FundDescriptionLevelCode in (select element from dbo.SplitString(''' + @FundDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))) 
				OR (d.InventoryDescriptionLevelCode in (select element from dbo.SplitString(''' + @InventoryDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodesInternal + ''', '',''))) 
				OR (d.ArchivalEntityDescriptionLevelCode in (select element from dbo.SplitString(''' + @ArchivalEntityDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @DocumentDescriptionLevelCodesInternal + ''', '',''))) 
				OR (d.DescriptionLevelCode in (select element from dbo.SplitString(''' + @DocumentDescriptionLevelCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(d.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(d.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))'
			+ @doNotGetAnythingFilter
			--+ @isSuspendedFilter
			+ @digitalObjectsFilter
			+ @fileContentFilter
			+ @isDeductedFilter
			+ @rankFilter;


	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteDocumentsTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL,
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL,
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NOT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT,
			HasDigitizedDigitalObjects BIT NULL
		);

		DECLARE @localDocumentsTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL,
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL,
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT,
			HasDigitizedDigitalObjects BIT NULL
		);

	';

	--if searching file content exclude external source rows (no file content in external source)
	IF (@SearchFileContent <> 1)
	BEGIN
		SET @sql = @sql + '
			INSERT INTO @remoteDocumentsTable SELECT * FROM OPENQUERY(' +  @LinkedServer + ', ''' + @remoteDocumentsQuery + ''' );'
	END
	
	SET @sql = @sql + '
		INSERT INTO @localDocumentsTable ' + @localDocumentsQuery;

	SET @sql = @sql + '
		SELECT *
		  FROM
		  (
			 SELECT *
			   FROM @remoteDocumentsTable
			  UNION
			 SELECT *
			   FROM @localDocumentsTable
		   ) documents
	';

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');


	EXEC (@sql);
END
GO




CREATE OR ALTER PROCEDURE [dbo].[SearchKMFForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@KMFNumber nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@ForeignarchivesOnly bit = 0,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@KeyWords nvarchar(MAX) = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	DECLARE @remoteQuery nvarchar(max), @kwds int, @fttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1
		--set @kwdsAnnotated=0;
	--if @KeywordsUIAnnotated is not null and len(@KeywordsUIAnnotated) >=2 set @kwdsAnnotated=1;
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 SET @rankRemote = ',kwds.[Rank] as Rank'; 

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 

	SET @remoteQuery = '';
	SET @remoteQuery = 'with fresults as (';
	set @remoteQuery = @remoteQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''film'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = fund.ArchiveGid) AS ArchiveName,
		fund.Number as FundNumber,
		NULL as InventoryNumber,
		NULL as ArchivalEntityNumber,
		fund.Number as KMFNumber,
		NULL as FilmCardNumber,
		fund.Title,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.TypeGid) as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = fund.StatusGid) as StatusText,
		(select Value FROM Nomenclature n WHERE n.Gid= fund.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as FundDescriptionLevelText,
		NULL as InventoryDescriptionLevelText,
		NULL as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) as HasExternalSource,
		fund.LGid as ExternalIdentifier,
		fund.TextDate as FundApproximateChronologicalScope,
		NULL as InventoryApproximateChronologicalScope,
		NULL as ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		Gid AS FundGid,
		NULL as FundIntNumber,
		NULL AS InventoryIntNumber,
		NULL AS ArchivalEntityIntNumber,
		fund.IntNumber AS KMFIntNumber,
		NULL AS FilmCardIntNumber,
		fund.Gid,
		fund.LGid'
		+ @rankRemote
		+ ',5 AS EntityTypeOrder
		,0 as HasDigitizedDigitalObjects';

	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		from Fund_Active as fund
	'
	else set @remoteQuery = @remoteQuery + '
		from Fund_Modified as fund
	';
	if @kwds = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(Fund,*,'''+ @KeyWords + ''') kwds on fund._id = kwds.[key]
	';
	if @ArchiveGids is not null and @ArchiveGids <> '-999'set @remoteQuery = @remoteQuery + '
		where fund.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids) + '
		AND fund.LevelOfDescriptionGid = 2185
	'
	else set @remoteQuery = @remoteQuery + '
		where fund.LevelOfDescriptionGid = 2185
	';
	if @KMFCountriesOfOriginCodes is not null and @KMFCountriesOfOriginCodes <> '-999' set  @remoteQuery = @remoteQuery + '
		and ((select n.Value2 from Nomenclature n where n.Gid = fund.CountryGid and n.Type = ''FACountry'') in (''' + [dbo].[StringSplit3](@KMFCountriesOfOriginCodes) + '''))	
	';
	if @KMFNumber is not null set @remoteQuery = @remoteQuery + '
		and (fund.Number = ''' + @KMFNumber + ''')
	';
	if @KMFNumber is not null and @LevelOfDescriptionGids <> '-999' 
		set @remoteQuery = @remoteQuery + '
			and (fund.LevelOfDescriptionGid = 2185)
			'
	else set @remoteQuery = @remoteQuery + '
		and ((fund.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) +') or -999 in (' + @LevelOfDescriptionGids + '))
	';
	if @ToDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @ToDate +''' >= fund.CreationDate)
	';
	if @FromDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @FromDate + ''' <= fund.CreationDate)
	';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
		and ( fund.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	';
	set @remoteQuery = @remoteQuery + @rankFilterRemote;

	if @SearchDrafts = 1 set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder,
			HasDigitizedDigitalObjects
		from fresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = fresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131	)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,	
			InventoryDescriptionLevelText,
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder,
			HasDigitizedDigitalObjects
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsF.[KEY] as fId, null as fDId, kwdsF.[RANK] as RankKwds
			from freetexttable(Films, *, ''' + @KeyWords + ''') kwdsF
			union 
			select null as fId, kwdsFD.[KEY] as fDId, kwdsFD.[RANK] as RankKwds  
			from freetexttable(FilmDrafts, *, ''' + @KeyWords + ''') kwdsFD
		) kwds
		on (f.Id = kwds.fDId and f.IsDraft = 1) or (f.Id = kwds.fId and f.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 SET @rank = ',RankKwds as Rank'; 

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 SET @rankFilter = ' and RankKwds > 1'; 

	DECLARE @numberFilter VARCHAR(MAX) = '';
	IF @KMFNumber IS NOT NULL SET @numberFilter = ' AND f.InventoryNumber=''' + @KMFNumber + '''';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_Films' ELSE SET @table = 'v_PublicFilms';

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 1 SET @doNotGetAnythingFilter = '' ELSE SET @doNotGetAnythingFilter = ' AND 1 = 2';

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			''film'' AS EntityType,
			f.SystemIdentifier,
			(SELECT Name FROM [Archives] a where a.Id = f.ArchiveId) as ArchiveName,
			NULL AS FundNumber,
			NULL AS InventoryNumber,
			NULL AS ArchivalEntityNumber,
			convert(varchar(256), f.InventoryNumber, 104) AS KMFNumber,
			NULL AS FilmCardNumber,
			NULL AS Title,
			NULL as TypeText,
			NULL as StatusText,
			NULL as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			NULL as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as ArchivalEntityApproximateChronologicalScope,
			f.SystemIdentifier as FilmSystemIdentifier,
			NULL as FundGid,
			NULL AS FundIntNumber,
			NULL AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			f.InventoryNumber AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			5 as EntityTypeOrder,
			0 as HasDigitizedDigitalObjects
		FROM ' + @table + ' f'
		+ @freeTextTableByKwdsJoin + '
		WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))'
			+ @numberFilter + '
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @KMFCountriesOfOriginCodes + ''', '',''))) 
				OR (CountryCode in (select element from dbo.SplitString(''' + @KMFCountriesOfOriginCodes + ''', '',''))))'
			+ @doNotGetAnythingFilter
			+ @rankFilter;


	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NOT NULL,
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL, 
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NOT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
			FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT,
			HasDigitizedDigitalObjects BIT NULL
		);

		INSERT INTO @remoteTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteTable
		UNION
		' +
		@localQuery;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
END
GO



CREATE OR ALTER PROCEDURE [dbo].[SearchFilmCardsForMainSearchComponent]  
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@KMFNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	--@KeywordsUIAnnotated nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@IncludeLocalRecords bit null = null,
	@ExtendedSearch bit null = 0
AS
BEGIN
	DECLARE @remoteQuery nvarchar(max), @kwds int, @kwdsAnnotated int, @ttl int;
	
	set @kwds = 0;
	if @KeyWords is not null and len(@KeyWords) >= 2 set @kwds = 1;
	--set @kwdsAnnotated=0;
	--if @KeywordsUIAnnotated is not null and len(@KeywordsUIAnnotated) >=2 set @kwdsAnnotated=1;
	If @Title is not null and len(@Title) >= 2 set @ttl = 1
	IF  @ExtendedSearch <> 1 
	BEGIN
		SET @KeyWords = REPLACE(@KeyWords, '"','');
		SET @KeyWords = '"*' + @KeyWords + '*"';
		SET @Title = REPLACE(@Title, '"','');
		SET @Title = '"*' + @Title + '*"';
	END

	DECLARE @rankRemote VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rankRemote = ',kwds.[Rank] as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankRemote = ',fttl.[Rank] as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rankRemote = ',(isnull(kwds.[Rank], 0) + isnull(fttl.[Rank], 0)) as Rank';

	DECLARE @rankFilterRemote VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilterRemote = ' and kwds.[Rank] > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilterRemote = ' and fttl.[Rank] > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilterRemote = ' and isnull(kwds.[Rank], 0) > 1 and isnull(fttl.[Rank], 0) > 1';

	SET @remoteQuery = '';
	SET @remoteQuery = 'with fresults as (';
	set @remoteQuery = @remoteQuery + '
	select top(1000000000) -- The ORDER BY clause is invalid in views, inline functions, derived tables, subqueries, and common table expressions, unless TOP, OFFSET or FOR XML is also specified
		''film_card'' AS EntityType, 
		NULL AS SystemIdentifier,
		(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' AND archive.Gid = ae.ArchiveGid) AS ArchiveName,
		jf.Number as FundNumber,
		ji.Number as InventoryNumber,
		ae.Number as ArchivalEntityNumber,
		NULL as KMFNumber,
		ae.Number as FilmCardNumber,
		ae.Title as Title,
		NULL as TypeText,
		(SELECT Value FROM Nomenclature n WHERE _retired = ''3000-01-01'' AND n.Gid = ae.StatusGid) as StatusText,
		(select Value FROM Nomenclature n WHERE n.Gid= jf.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as FundDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= ji.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as InventoryDescriptionLevelText,	
		(select Value FROM Nomenclature n WHERE n.Gid= ae.LevelOfDescriptionGid AND n._retired = ''3000-01-01'') as ArchivalEntityDescriptionLevelText,
		CAST(1 as bit) AS HasExternalSource,
		ae.LGid AS ExternalIdentifier,
		jf.TextDate AS FundApproximateChronologicalScope,
		ji.TextDate AS InventoryApproximateChronologicalScope,
		ae.TextDate AS ArchivalEntityApproximateChronologicalScope,
		NULL AS FilmSystemIdentifier,
		jf.Gid AS FundGid,
		jf.IntNumber as FundIntNumber,
		ji.IntNumber AS InventoryIntNumber,
		ae.IntNumber AS ArchivalEntityIntNumber,
		NULL AS KMFIntNumber,
		ae.IntNumber AS FilmCardIntNumber,
		ae.Gid,
		ae.LGid'
		+ @rankRemote
		+ ',6 AS EntityTypeOrder
		,0 as HasDigitizedDigitalObjects';

	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		from ArchiveEntity_Active as ae
	';
	else set @remoteQuery = @remoteQuery + '
		from ArchiveEntity_Modified as ae
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Inventory_Active ji on ji.LGid=ae.InventoryLGid
	';
	else set @remoteQuery = @remoteQuery + '
		inner join Inventory_Modified ji on ji.LGid=ae.InventoryLGid
	';
	if @SearchDrafts = 1 set @remoteQuery = @remoteQuery + '
		inner join Fund_Active jf on jf.LGid=ae.FundLGid
	';
	else set @remoteQuery = @remoteQuery + '
		inner join Fund_Modified jf on jf.LGid=ae.FundLGid
	';
	if @kwds = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(ArchiveEntity,*, '''+ @KeyWords + ''') kwds on ae._id = kwds.[key]
	';
	if @ttl = 1 set @remoteQuery = @remoteQuery + '
		left join freetexttable(ArchiveEntity,Title, '''+ @Title + ''') fttl on ae._id = fttl.[key]
	';
	--if @kwdsAnnotated =1 set @remoteQuery = @remoteQuery + '
		--inner join ObjectNomenclature on1 on on1.ArchiveEntityGid = ae.Gid and on1._retired = ''3000-01-01''
		--inner join Nomenclature n1 on on1.NomenclatureGid = n1.Gid and n1.[Type] = ''Annotated'' and n1._retired = ''3000-01-01''
		--inner join freetexttable(Nomenclature,*,@KeywordsUIAnnotated) fts1 on n1._id = fts1.[key] ';
	if @ArchiveGids is not null and @ArchiveGids <> '-999' set @remoteQuery = @remoteQuery + '
		where ae.ArchiveGid in ' + [dbo].[StringSplit2](@ArchiveGids)
	else set @remoteQuery = @remoteQuery + '
		where 1 = 1';
	if @KMFCountriesOfOriginCodes is not null and @KMFCountriesOfOriginCodes <> '-999' set  @remoteQuery = @remoteQuery + '
		and ((select n.Value2 from Nomenclature n where n.Gid = jf.CountryGid and n.Type = ''FACountry'') in (''' + [dbo].[StringSplit3](@KMFCountriesOfOriginCodes) + '''))	
	';	
	set @remoteQuery = @remoteQuery + '
		and (jf.LevelOfDescriptionGid = 2185)
		and (ae.LevelOfDescriptionGid = 2371)
	';
	if @KMFNumber is not null or @ArchivalEntityNumber is not null and @LevelOfDescriptionGids <> '-999' set @remoteQuery = @remoteQuery + ''
	else set @remoteQuery = @remoteQuery + '
			and ((ae.LevelOfDescriptionGid in ' + [dbo].[StringSplit2](@LevelOfDescriptionGids) +') or -999 in (' + @LevelOfDescriptionGids + '))
		';
	--if @ArchivalEntityNumber is not null set @remoteQuery = @remoteQuery + '
		--and (ae.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired = ''3000-01-01'' and [Type] = ''LevelOfDescription'' AND Code = 11)) --Арх.ед. - копия от чужди архиви
	--';
	if @FundNumber is not null set @remoteQuery = @remoteQuery + '
		and (jf.Number = ''' + @FundNumber + ''')
	';
	if @InventoryNumber is not null set @remoteQuery = @remoteQuery + '
		and (ji.Number = ''' + @InventoryNumber + ''')
	';
	if @ArchivalEntityNumber is not null set @remoteQuery = @remoteQuery + '
		and (ae.Number = ''' + @ArchivalEntityNumber + ''')
	';
	if @KMFNumber is not null set @remoteQuery = @remoteQuery + '
		and (ae.Number = ''' + @KMFNumber + ''')
	';
	if @ToDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @ToDate +''' >= ae.CreationDate)
	';
	if @FromDate is not null set @remoteQuery = @remoteQuery + '
		and (''' + @FromDate + ''' <= ae.CreationDate)
	';
	--if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
	--	and ((select FundArrayGid from ' + @fundsView + ' where LGid = inventory.FundLGid) in ' + [dbo].[StringSplit2](@FundArrayGids) +' ) 
	--';
	if @FundArrayGids is not null and @FundArrayGids <> '-999' set @remoteQuery = @remoteQuery + '
		and (jf.FundArrayGid in ' + [dbo].[StringSplit2](@FundArrayGids) +') 
	';
	set @remoteQuery = @remoteQuery + @rankFilterRemote;

	if @SearchDrafts = 1 set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by ExternalIdentifier order by Gid asc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder,
			HasDigitizedDigitalObjects
		from fresrownum where not exists(
		select 1 from Fund f1
		where f1._retired=''3000-01-01''
		and f1.LGid = fresrownum.ExternalIdentifier
		and f1.RowStatusGid=72
		and exists (select 1 from Process p 
					where p._retired = ''3000-01-01'' 
					and p.Gid = f1.ProcessGid
					and p.TypeGid = 216 -- Пресъставяне
					and p.StepGid not in(2130, 2131	)) -- Иницииране на процес по пресъставяне, Спиране на достъпа
		)
	'
	else set @remoteQuery=@remoteQuery+'),
		fresrownum as
		(
		select row_number() over (partition by LGid order by Gid desc) rn, * from fresults)
		select 
			EntityType, 
			cast(SystemIdentifier as uniqueidentifier),
			ArchiveName,
			FundNumber,
			InventoryNumber,	
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			cast(FilmSystemIdentifier as uniqueidentifier),
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			Rank,
			EntityTypeOrder,
			HasDigitizedDigitalObjects
		from fresrownum where rn=1;
	'

	SET NOCOUNT ON;

	--declare @offset int = (@Page - 1) * @RowsOfPage;

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @freeTextTableByKwdsJoin VARCHAR(MAX) = '';
	IF @kwds = 1 SET @freeTextTableByKwdsJoin = ' 
		left join 
		(
			select kwdsFC.[KEY] as fcId, null as fcDId, kwdsFC.[RANK] as RankKwds
			from freetexttable(FilmCards, *, ''' + @KeyWords + ''') kwdsFC
			union 
			select null as fcId, kwdsFCD.[KEY] as fcDId, kwdsFCD.[RANK] as RankKwds  
			from freetexttable(FilmCardDrafts, *, ''' + @KeyWords + ''') kwdsFCD
		) kwds
		on (c.Id = kwds.fcDId and c.IsDraft = 1) or (c.Id = kwds.fcId and c.IsDraft = 0)';

	DECLARE @freeTextTableByTitleJoin VARCHAR(MAX) = '';
	IF @ttl = 1 SET @freeTextTableByTitleJoin = ' 
		left join 
		(
			select ttlFC.[KEY] as fcId, null as fcDId, ttlFC.[RANK] as RankTitle   
			from freetexttable(FilmCards, Title, ''' + @Title + ''') ttlFC 
			union 
			select null as fcId, ttlFCD.[KEY] as fcDId, ttlFCD.[RANK] as RankTitle   
			from freetexttable(FilmCardDrafts, Title, ''' + @Title + ''') ttlFCD
		) ttl
		on (c.Id = ttl.fcDId and c.IsDraft = 1) or (c.Id = ttl.fcId and c.IsDraft = 0)';

	DECLARE @rank VARCHAR(MAX) = ',null as Rank';
	IF @kwds = 1 AND @ttl IS NULL SET @rank = ',RankKwds as Rank'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rank = ',ttl.RankTitle as Rank';
	IF @kwds = 1 AND @ttl = 1 SET @rank = ',(isnull(RankKwds, 0) + isnull(ttl.RankTitle, 0)) as Rank';

	DECLARE @rankFilter VARCHAR(MAX) = '';
	IF @kwds = 1 AND @ttl IS NULL SET @rankFilter = ' and RankKwds > 1'; 
	IF @kwds <> 1 AND @ttl = 1 SET @rankFilter = ' and ttl.RankTitle > 1';
	IF @kwds = 1 AND @ttl = 1 SET @rankFilter = ' and isnull(RankKwds, 0) > 1 and isnull(ttl.RankTitle, 0) > 1';

	DECLARE @kmfCountriesOfOriginCodesFilter VARCHAR(MAX) = '';
	IF @KMFCountriesOfOriginCodes IS NOT NULL SET @kmfCountriesOfOriginCodesFilter = ' AND c.CountryId = ''' + @kmfCountriesOfOriginCodesFilter + '''';

	DECLARE @kmfNumberFilter VARCHAR(MAX) = '';
	IF @KMFNumber IS NOT NULL SET @kmfNumberFilter = ' AND c.FilmInventoryNumber=''' + @KMFNumber + '''';

	DECLARE @table VARCHAR(MAX) = '';
	IF @SearchDrafts = 1 SET @table = 'v_FilmCards' ELSE SET @table = 'v_PublicFilmCards'; -- къде е v_PublicFilmCards?

	DECLARE @doNotGetAnythingFilter VARCHAR(MAX) = '';
	IF @IncludeLocalRecords = 0 
		OR @FundNumber IS NOT NULL
		OR @InventoryNumber IS NOT NULL
		OR @ArchivalEntityNumber IS NOT NULL 
		SET @doNotGetAnythingFilter = ' AND 1 = 2' 
	ELSE SET @doNotGetAnythingFilter = '';	

	DECLARE @localQuery VARCHAR(MAX) = '
		SELECT
			''film_card'' AS EntityType,
			c.SystemIdentifier,
			(SELECT Name FROM Archives a where a.Id = c.ArchiveId) as ArchiveName,	
			NULL as FundNumber,
			NULL as InventoryNumber,
			NULL as ArchivalEntityNumber,
			c.FilmInventoryNumber as KMFNumber,
			c.InventoryNumber AS KMFNumber,
			c.Title as Title,
			NULL as TypeText,
			NULL as StatusText,
			NULL as FundDescriptionLevelText,
			NULL as InventoryDescriptionLevelText,
			NULL as ArchivalEntityDescriptionLevelText,
			CAST(0 as bit) AS HasExternalSource,
			NULL AS ExternalIdentifier,
			NULL as FundApproximateChronologicalScope,
			NULL as InventoryApproximateChronologicalScope,
			NULL as  ArchivalEntityApproximateChronologicalScope,
			c.FilmSystemIdentifier,
			NULL as FundGid,
			NULL as FundIntNumber,
			NULL AS InventoryIntNumber,
			NULL AS ArchivalEntityIntNumber,
			c.FilmInventoryNumber AS KMFIntNumber,
			NULL AS FilmCardIntNumber
			' + @rank + ',
			6 as EntityTypeOrder,
			0 as HasDigitizedDigitalObjects
		FROM ' + @table + ' c'
		+ @freeTextTableByTitleJoin
		+ @freeTextTableByKwdsJoin + '
		WHERE c.ExternalIdentifier IS NULL AND c.HasExternalSource = 0 AND c.Deleted = 0 
			AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodesInternal  + ''', '',''))) 
				OR (c.ArchiveCode in (select element from dbo.SplitString(''' + @ArchiveCodesInternal + ''', '',''))))
			AND ((''' + COALESCE(@FromDate, 'null') + ''' = ''null'') OR (cast(c.CreatedOn as date) >= cast(''' + COALESCE(@FromDate, 'null') + ''' as datetime2)))
			AND ((''' + COALESCE(@ToDate, 'null') + ''' = ''null'') OR (cast(c.CreatedOn as date) <= cast(''' + COALESCE(@ToDate, 'null') + ''' as datetime2)))
			AND ((''-999'' in (select element from dbo.SplitString(''' + @KMFCountriesOfOriginCodes + ''', '',''))) 
				OR (c.CountryCode in (select element from dbo.SplitString(''' + @KMFCountriesOfOriginCodes + ''', '',''))))'
			+ @kmfNumberFilter
			+ @doNotGetAnythingFilter
			+ @rankFilter;


	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @remoteFilmCardsTable TABLE (
			EntityType nvarchar(50) NULL,
			SystemIdentifier uniqueidentifier NULL,
			ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи го чупят в такъв случай	
			FundNumber nvarchar(256) NULL,
			InventoryNumber nvarchar(256) NULL,
			ArchivalEntityNumber nvarchar(256) NULL,
			KMFNumber nvarchar(256) NULL,
			FilmCardNumber nvarchar(256) NULL,
			Title nvarchar(MAX) NULL,
			TypeText nvarchar(MAX) NULL,
			StatusText nvarchar(MAX) NULL,
			FundDescriptionLevelText nvarchar(MAX) NULL,
			InventoryDescriptionLevelText nvarchar(MAX) NULL,
			ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
			HasExternalSource BIT NOT NULL,
			ExternalIdentifier INT NOT NULL,
			FundApproximateChronologicalScope nvarchar(256) NULL,
			InventoryApproximateChronologicalScope nvarchar(256) NULL,
			ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
			FilmSystemIdentifier uniqueidentifier NULL,
			FundGid int,
			FundIntNumber INT NULL,
			InventoryIntNumber INT NULL,
			ArchivalEntityIntNumber INT NULL,
			KMFIntNumber INT NULL,
		    FilmCardIntNumber INT NULL,
			Rank INT,
			EntityTypeOrder INT,
			HasDigitizedDigitalObjects BIT NULL
		);

		INSERT INTO @remoteFilmCardsTable SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');' + 

		'SELECT * FROM @remoteFilmCardsTable
		UNION
		' +
		@localQuery;

	IF  @ExtendedSearch <> 1 SET @sql = REPLACE(@sql, ' freetexttable(',' containstable(');

	EXEC (@sql);
	--print @sql;
END
GO



CREATE OR ALTER PROCEDURE [dbo].[MainSearchComponent]
	@LinkedServer nvarchar(50),
	@SearchDrafts bit = 0,
	@ArchiveGids nvarchar(10) = null,
	@ArchiveCodesInternal nvarchar(10) = null,
	@FundNumber nvarchar(256) = null,
	@InventoryNumber nvarchar(256) = null,
	@ArchivalEntityNumber nvarchar(256) = null,
	@LevelOfDescriptionGids nvarchar(256) = null,
	@FundDescriptionLevelCodesInternal nvarchar(256) = null,
	@InventoryDescriptionLevelCodesInternal nvarchar(256) = null,
	@ArchivalEntityDescriptionLevelCodesInternal nvarchar(256) = null,
	@DocumentDescriptionLevelCodesInternal nvarchar(256) = null,
	@FundArrayGids nvarchar(max) = null, -- това е наименованието на ArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@KMFNumber nvarchar(256) = null,
	@KMFCountriesOfOriginCodes nvarchar(256) = null,
	@ToDate nvarchar(100) = null,
	@FromDate nvarchar(100) = null,
	@Title nvarchar(MAX) = null,
	@KeyWords nvarchar(MAX) = null,
	@SearchDigitalObject bit null = null,
	@EntityType nvarchar(250) = null,
	@ExtendedSearch bit = 0,
	@SearchFileContent bit null = 0,
	@FileDbName nvarchar(50) = null,
	@FileBufferDbName nvarchar(50) = null,
	@RowsOfPage int = 5000,
	@Page int = 1
AS
BEGIN
	SET NOCOUNT ON;

	declare @offset int = (@Page - 1) * @RowsOfPage;

	DECLARE @resultColumnsDeclaration VARCHAR(MAX) = '
		EntityType nvarchar(50) NULL,
		SystemIdentifier uniqueidentifier NULL,
		ArchiveName nvarchar(256) NULL, -- трябва да е NOT NULL, но в ИСДА някои записи на фондове го чупят в такъв случай
		FundNumber nvarchar(256) NULL,
		InventoryNumber nvarchar(256) NULL,
		ArchivalEntityNumber nvarchar(256) NULL,
		KMFNumber nvarchar(256) NULL,
		FilmCardNumber nvarchar(256) NULL,
		Title nvarchar(MAX) NULL,
		TypeText nvarchar(MAX) NULL,
		StatusText nvarchar(MAX) NULL,
		FundDescriptionLevelText nvarchar(MAX) NULL,
		InventoryDescriptionLevelText nvarchar(MAX) NULL,
		ArchivalEntityDescriptionLevelText nvarchar(MAX) NULL,
		HasExternalSource BIT NOT NULL,
		ExternalIdentifier INT NULL,
		FundApproximateChronologicalScope nvarchar(256) NULL,
		InventoryApproximateChronologicalScope nvarchar(256) NULL,
		ArchivalEntityApproximateChronologicalScope nvarchar(256) NULL,
		FilmSystemIdentifier uniqueidentifier NULL,
		FundGid int,
		FundIntNumber INT NULL,
		InventoryIntNumber INT NULL,
		ArchivalEntityIntNumber INT NULL,
		KMFIntNumber INT NULL, 
		FilmCardIntNumber INT NULL,
		[Rank] INT NULL,
		EntityTypeOrder INT,
		HasDigitizedDigitalObjects BIT NULL
	';

	DECLARE @resultColumns VARCHAR(MAX) = '
		EntityType, 
		SystemIdentifier,
		ArchiveName,		
		FundNumber,
		InventoryNumber,
		ArchivalEntityNumber,
		KMFNumber,
		FilmCardNumber,
		Title,
		TypeText,
		StatusText,
		FundDescriptionLevelText,
		InventoryDescriptionLevelText,	
		ArchivalEntityDescriptionLevelText,
		HasExternalSource,
		ExternalIdentifier,
		FundApproximateChronologicalScope,
		InventoryApproximateChronologicalScope,
		ArchivalEntityApproximateChronologicalScope,
		FilmSystemIdentifier,
		FundGid,
		FundIntNumber,
		InventoryIntNumber,
		ArchivalEntityIntNumber,
		KMFIntNumber,
		FilmCardIntNumber,
		[Rank],
		EntityTypeOrder,
		HasDigitizedDigitalObjects
	';

	DECLARE @keyWordsColumn VARCHAR(MAX) = '';
	IF @KeyWords IS NULL SET @keyWordsColumn = 'NULL' 
	ELSE SET @keyWordsColumn = '''' + @KeyWords + '''';

	DECLARE @toDateColumn VARCHAR(MAX) = '';
	IF @ToDate IS NULL SET @toDateColumn = 'NULL' 
	ELSE SET @toDateColumn = '''' + @ToDate + '''';

	DECLARE @fromDateColumn VARCHAR(MAX) = '';
	IF @FromDate IS NULL SET @fromDateColumn = 'NULL' 
	ELSE SET @fromDateColumn = '''' + @FromDate + '''';

	DECLARE @titleColumn VARCHAR(MAX) = '';
	IF @Title IS NULL SET @titleColumn = 'NULL' 
	ELSE SET @titleColumn = '''' + @Title + '''';

	DECLARE @fundNumberColumn VARCHAR(MAX) = '';
	IF @FundNumber IS NULL SET @fundNumberColumn = 'NULL' 
	ELSE SET @fundNumberColumn = '''' + @FundNumber + '''';

	DECLARE @inventoryNumberColumn VARCHAR(MAX) = '';
	IF @InventoryNumber IS NULL SET @inventoryNumberColumn = 'NULL' 
	ELSE SET @inventoryNumberColumn = '''' + @InventoryNumber + '''';

	DECLARE @archivalEntityNumberColumn VARCHAR(MAX) = '';
	IF @ArchivalEntityNumber IS NULL SET @archivalEntityNumberColumn = 'NULL' 
	ELSE SET @archivalEntityNumberColumn = '''' + @ArchivalEntityNumber + '''';

	DECLARE @kmfNumberColumn VARCHAR(MAX) = '';
	IF @KMFNumber IS NULL SET @kmfNumberColumn = 'NULL' 
	ELSE SET @kmfNumberColumn = '''' + @KMFNumber + '''';

	DECLARE @searchDigitalObjectColumn VARCHAR(MAX) = '';
	IF @SearchDigitalObject IS NULL SET @searchDigitalObjectColumn = 'NULL' 
	ELSE SET @searchDigitalObjectColumn = convert(varchar(1), @searchDigitalObject, 104);

	DECLARE @searchDraftsColumn VARCHAR(MAX) = '';
	IF @SearchDrafts IS NULL SET @searchDraftsColumn = 'NULL' 
	ELSE SET @searchDraftsColumn = convert(varchar(1), @SearchDrafts, 104);

	DECLARE @extendedSearchColumn VARCHAR(MAX) = '';
	IF @ExtendedSearch IS NULL SET @extendedSearchColumn = 'NULL' 
	ELSE SET @extendedSearchColumn = convert(varchar(1), @ExtendedSearch, 104);

	DECLARE @entityTypesArr TABLE (element VARCHAR(50) NULL); 
	INSERT INTO @entityTypesArr SELECT element from dbo.SplitString(@EntityType, ',');

	DECLARE @fundsInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalFunds BIT = 0;
	IF 'fund' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFunds = 1;
	IF  @InventoryNumber IS NULL 
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL 
		AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999' OR @InventoryDescriptionLevelCodesInternal='-111')
		AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999' OR @ArchivalEntityDescriptionLevelCodesInternal='-111')
		AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999'  OR @DocumentDescriptionLevelCodesInternal='-111')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999') SET @fundsInsert = '
			INSERT INTO @funds EXEC [dbo].[SearchFundsForMainSearchComponent] 
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@FundNumber = ' + @fundNumberColumn + ',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@DescriptionLevelCodesInternal  = ''' + @FundDescriptionLevelCodesInternal + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@FundArraysInternal = ''' + @FundArraysInternal + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFunds) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
		';

	DECLARE @inventoriesInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalIventories BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfInventory TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfInventory (Gid) VALUES (2171),(2172),(2369); -- нива на описание за опис от ИСДА

	IF 'inventory' IN (SELECT element FROM @entityTypesArr) SET @includeLocalIventories = 1;
	IF (@FundNumber IS NOT NULL
		AND @ArchivalEntityNumber IS NULL 
		AND @KMFNumber IS NULL
		AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
		AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999')
		AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfInventory INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) 
		OR @InventoryNumber IS NOT NULL
		OR EXISTS(SELECT Code FROM N.InventoryDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@InventoryDescriptionLevelCodesInternal, ',')))
		
		SET @inventoriesInsert = '
			INSERT INTO @inventories EXEC [dbo].[SearchInventoriesForMainSearchComponent] 
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@FundNumber = ' + @fundNumberColumn + ',
				@InventoryNumber = ' + @inventoryNumberColumn + ',
				@KMFCountriesOfOriginCodes  = ''' + @KMFCountriesOfOriginCodes + ''',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@FundDescriptionLevelCodesInternal = ''' + @FundDescriptionLevelCodesInternal + ''',
				@InventoryDescriptionLevelCodesInternal = ''' + @InventoryDescriptionLevelCodesInternal + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@FundArraysInternal = ''' + @FundArraysInternal + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalIventories) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ',
				@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
				@FileDbName = ''' + @FileDbName + ''',
				@FileBufferDbName = ''' + @FileBufferDbName + ''';
		';

	DECLARE @archivalEntitiesInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalArchivalEntities BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfArchivalEntities TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfArchivalEntities (Gid) VALUES (2174),(2373); -- нива на описание за АЕ от ИСДА
	IF 'archival_entity' IN (SELECT element FROM @entityTypesArr) SET @includeLocalArchivalEntities = 1;
	IF (@FundNumber IS NOT NULL --AND @ArchivalEntityNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL)
		AND @KMFNumber IS NULL
		AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
		AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999')
		AND (@DocumentDescriptionLevelCodesInternal IS NULL OR @DocumentDescriptionLevelCodesInternal='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999')) 
		OR @ArchivalEntityNumber IS NOT NULL
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfArchivalEntities INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) -- 3493 от DevOps
		OR EXISTS(SELECT Code FROM N.ArchivalEntityDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@ArchivalEntityDescriptionLevelCodesInternal, ',')))
	SET @archivalEntitiesInsert = '
		INSERT INTO @archivalEntities EXEC [dbo].[SearchArchivalEntitiesForMainSearchComponent] 
			@LinkedServer = ''' + @LinkedServer + ''',
			@SearchDrafts = ' + @searchDraftsColumn + ',
			@ArchiveGids = ''' + @ArchiveGids + ''',
			@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
			@FundNumber = ' + @fundNumberColumn + ',
			@InventoryNumber = ' + @inventoryNumberColumn + ',
			@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
			@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
			@FundDescriptionLevelCodesInternal = ''' + @FundDescriptionLevelCodesInternal + ''',
			@InventoryDescriptionLevelCodesInternal = ''' + @InventoryDescriptionLevelCodesInternal + ''',
			@ArchivalEntityDescriptionLevelCodesInternal = ''' + @ArchivalEntityDescriptionLevelCodesInternal + ''',
			@ToDate = ' + @toDateColumn + ',
			@FromDate = ' + @fromDateColumn + ',
			@FundArrayGids = ''' + @FundArrayGids + ''',
			@FundArraysInternal = ''' + @FundArraysInternal + ''',
			@Title = ' + @titleColumn + ',
			@KeyWords = ' + @keyWordsColumn + ',		
			@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
			@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalArchivalEntities) + ',
			@ExtendedSearch = ' + @extendedSearchColumn + ',
			@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
			@FileDbName = ''' + @FileDbName + ''',
			@FileBufferDbName = ''' + @FileBufferDbName + ''';
	';

	DECLARE @documentsInsert VARCHAR(MAX) = '';
	DECLARE @includeLocalDocuments BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfDocuments TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfDocuments (Gid) VALUES (2173); -- ниво на описание за документ от ИСДА
	IF 'document' IN (SELECT element FROM @entityTypesArr) SET @includeLocalDocuments = 1;
	IF 
		-- това условие е било сложено нарочно, но искат да отпадне 
		--@FundNumber IS NULL AND @InventoryNumber IS NULL AND @ArchivalEntityNumber IS NULL
		--AND 
		(@KMFNumber IS NULL
		AND (@FundDescriptionLevelCodesInternal IS NULL OR @FundDescriptionLevelCodesInternal='-999')
		AND (@InventoryDescriptionLevelCodesInternal IS NULL OR @InventoryDescriptionLevelCodesInternal='-999')
		AND (@ArchivalEntityDescriptionLevelCodesInternal IS NULL OR @ArchivalEntityDescriptionLevelCodesInternal='-999')
		AND (@KMFCountriesOfOriginCodes IS NULL OR @KMFCountriesOfOriginCodes = '-999'))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfDocuments INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) -- 3493 от DevOps
		OR EXISTS(SELECT Code FROM N.DocumentDescriptionLevel INTERSECT (SELECT element FROM dbo.SplitString(@DocumentDescriptionLevelCodesInternal, ',')))
	SET @documentsInsert = '
		INSERT INTO @documents EXEC [dbo].[SearchDocumentsForMainSearchComponent] 
			@LinkedServer = ''' + @LinkedServer + ''',
			@SearchDrafts = ' + @searchDraftsColumn + ',
			@ArchiveGids = ''' + @ArchiveGids + ''',
			@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
			@FundNumber = ' + @fundNumberColumn + ',
			@InventoryNumber = ' + @inventoryNumberColumn + ',
			@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
			@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
			@FundDescriptionLevelCodesInternal = ''' + @FundDescriptionLevelCodesInternal + ''',
			@InventoryDescriptionLevelCodesInternal = ''' + @InventoryDescriptionLevelCodesInternal + ''',
			@ArchivalEntityDescriptionLevelCodesInternal = ''' + @ArchivalEntityDescriptionLevelCodesInternal + ''',
			@DocumentDescriptionLevelCodesInternal = ''' + @DocumentDescriptionLevelCodesInternal + ''',
			@ToDate = ' + @toDateColumn + ',
			@FromDate = ' + @fromDateColumn + ',
			@FundArrayGids = ''' + @FundArrayGids + ''',
			@FundArraysInternal = ''' + @FundArraysInternal + ''',
			@Title = ' + @titleColumn + ',
			@KeyWords = ' + @keyWordsColumn + ',		
			@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
			@IncludeLocalRecords = ' + convert(nvarchar(1), @includeLocalDocuments) + ',
			@ExtendedSearch = ' + @extendedSearchColumn + ',
			@SearchFileContent = ' + CONVERT(nvarchar(1), @SearchFileContent) + ',
			@FileDbName = ''' + @FileDbName + ''',
			@FileBufferDbName = ''' + @FileBufferDbName + ''';
		';

	DECLARE @filmsInsert VARCHAR(MAX) = ''; 
	DECLARE @includeLocalFilms BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfFilms TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfFilms (Gid) VALUES (2185); -- ниво на описание КМФ
	IF 'film' IN (SELECT element FROM @entityTypesArr) 
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilms INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ','))) 
		SET @includeLocalFilms = 1;
	IF @FundNumber IS NULL 
		AND @InventoryNumber IS NULL
		AND @ArchivalEntityNumber IS NULL 
		AND @Title IS NULL SET @filmsInsert = '
			INSERT INTO @films EXEC [dbo].[SearchKMFForMainSearchComponent]
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@KMFNumber = ' + @kmfNumberColumn + ',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@KMFCountriesOfOriginCodes = ''' + @KMFCountriesOfOriginCodes + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@KeyWords = ' + @keyWordsColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFilms, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
	';

	DECLARE @filmCardsInsert VARCHAR(MAX) = ''; 	
	DECLARE @includeLocalFilmCards BIT = 0;
	DECLARE @LevelOfDescriptionGidsOfFilmCards TABLE (Gid INT NOT NULL);
	INSERT INTO @LevelOfDescriptionGidsOfFilmCards (Gid) VALUES (2371); -- ниво на описание Архивна единица (КМФ)
	IF 'film_card' IN (SELECT element FROM @entityTypesArr) SET @includeLocalFilmCards = 1;
	IF (NOT ((@FundNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL AND @KMFNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @ArchivalEntityNumber IS NULL AND @KMFNumber IS NULL)))
		OR EXISTS(SELECT Gid FROM @LevelOfDescriptionGidsOfFilmCards INTERSECT (SELECT element FROM dbo.SplitString(@LevelOfDescriptionGids, ',')))
		--OR NOT ((@FundNumber IS NOT NULL AND @KMFNumber IS NULL) AND NOT (@InventoryNumber IS NOT NULL AND @KMFNumber IS NULL)) 
		SET @filmCardsInsert = '
			INSERT INTO @filmCards EXEC [dbo].[SearchFilmCardsForMainSearchComponent]
				@LinkedServer = ''' + @LinkedServer + ''',
				@SearchDrafts = ' + @searchDraftsColumn + ',
				@ArchiveGids = ''' + @ArchiveGids + ''',
				@ArchiveCodesInternal = ''' + @ArchiveCodesInternal + ''',
				@FundNumber  = ' + @fundNumberColumn + ',
				@InventoryNumber = ' + @inventoryNumberColumn + ',
				@ArchivalEntityNumber = ' + @archivalEntityNumberColumn + ',
				@KMFNumber = ' + @kmfNumberColumn + ',
				@KMFCountriesOfOriginCodes = ''' + @KMFCountriesOfOriginCodes + ''',
				@LevelOfDescriptionGids = ''' + @LevelOfDescriptionGids + ''',
				@ToDate = ' + @toDateColumn + ',
				@FromDate = ' + @fromDateColumn + ',
				@FundArrayGids = ''' + @FundArrayGids + ''',
				@Title = ' + @titleColumn + ',
				@KeyWords = ' + @keyWordsColumn + ',
				@SearchDigitalObject = ' + @searchDigitalObjectColumn + ',
				@IncludeLocalRecords = ' + convert(varchar(1), @includeLocalFilmCards, 104) + ',
				@ExtendedSearch = ' + @extendedSearchColumn + ';
		';

	DECLARE @sql VARCHAR(MAX) = '
		DECLARE @funds TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @inventories TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @archivalEntities TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @documents TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @films TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @filmCards TABLE ('
			+ @resultColumnsDeclaration +
		');

		DECLARE @result TABLE ('
			+ @resultColumnsDeclaration +
		');'

		+ @fundsInsert + 
		+ @inventoriesInsert + 
		+ @archivalEntitiesInsert + 	
		+ @documentsInsert + 
		+ @filmsInsert +
		+ @filmCardsInsert + '

		INSERT INTO @result SELECT * FROM
			(
				SELECT ' + @resultColumns + ' FROM @funds

				UNION
		
				SELECT ' + @resultColumns + ' FROM @inventories

				UNION

				SELECT ' + @resultColumns + ' FROM @archivalEntities

				UNION

				SELECT ' + @resultColumns + ' FROM @documents

				UNION

				SELECT ' + @resultColumns + ' FROM @films	

				UNION

				SELECT ' + @resultColumns + ' FROM @filmCards
			) x

		
		SELECT
			EntityType, 
			SystemIdentifier,
			ArchiveName,		
			FundNumber,
			InventoryNumber,
			ArchivalEntityNumber,
			KMFNumber,
			FilmCardNumber,
			Title,
			TypeText,
			StatusText,
			FundDescriptionLevelText,
			InventoryDescriptionLevelText,	
			ArchivalEntityDescriptionLevelText,
			HasExternalSource,
			ExternalIdentifier,
			FundApproximateChronologicalScope,
			InventoryApproximateChronologicalScope,
			ArchivalEntityApproximateChronologicalScope,
			FilmSystemIdentifier,
			FundGid,
			FundIntNumber,
			InventoryIntNumber,
			ArchivalEntityIntNumber,
			KMFIntNumber,
			FilmCardIntNumber,
			(SELECT COUNT(0) FROM @result) TotalRows,
			[Rank],
			EntityTypeOrder,
			HasDigitizedDigitalObjects
		FROM @result
		ORDER BY 
			EntityTypeOrder,
			[Rank] DESC,                                                                                                                               
			ArchiveName ASC,  -- колоните с ...Int... представляват числото от номера
            FundIntNumber ASC,
			KMFIntNumber ASC,
            FundNumber ASC,
            InventoryIntNumber ASC,
            InventoryNumber ASC,
            ArchivalEntityIntNumber ASC,
            ArchivalEntityNumber ASC,
			FilmCardIntNumber ASC
		OFFSET ' + CONVERT(varchar(10), @offset) + ' ROWS FETCH NEXT ' + CONVERT(varchar(10), @RowsOfPage) + ' ROWS ONLY
		';

	EXEC (@sql);
END
GO


CREATE OR ALTER PROCEDURE [dbo].[sp_GetDocument] 
	@LinkedServer nvarchar(50),
	@Identifier int
AS
BEGIN
	SET NOCOUNT ON;

	declare @sql varchar(max) = '
		SELECT
			-1 as Id
			,NULL as SystemIdentifier
			,CAST(1 as bit) as HasExternalSource
			,LGid as ExternalIdentifier
			,(select CAST(Code as nvarchar(50)) from Nomenclature n where n.Gid = StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusCode
			,(select Value from Nomenclature n where n.Gid = StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusText
			,(select Code from Nomenclature n where n.Gid = AveilabilityGid and n._retired = ''3000-01-01 00:00:00.000'') as AvailabilityStatusCode
			,(select Value from Nomenclature n where n.Gid = AveilabilityGid and n._retired = ''3000-01-01 00:00:00.000'') as AvailabilityStatusText
			,(select a.Code from Archive a where a.Gid = ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveCode
			,(select a.Name from Archive a where a.Gid = ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveName
			,CAST(1 AS BIT) as FundHasExternalSource
			,FundLGid as FundExternalIdentifier
			,(SELECT Number FROM Fund_Active AS fund WHERE fund.LGid = FundLGid) AS FundNumber
			,CAST(1 AS BIT) as InventoryHasExternalSource
			,InventoryLGid as InventoryExternalIdentifier
			,(SELECT Number FROM Inventory_Active AS inventory WHERE inventory.LGid = InventoryLGid) AS InventoryNumber
			,CAST(1 AS BIT) as ArchivalEntityHasExternalSource
			,AELGid as ArchivalEntityExternalIdentifier
			,(SELECT Number FROM ArchiveEntity_Active AS ae WHERE ae.LGid = AELGid) AS ArchivalEntityNumber
            ,Number
			,Title
			,(select CAST(Code as nvarchar(50)) from Nomenclature n where n.Gid= d.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelCode
			,(select Value from Nomenclature n where n.Gid= d.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelText
			,STUFF(
				(select ''; '' + Value 
				   from ObjectNomenclature obj 
				   join Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.DocumentGid = d.Gid and n.Type = ''CreatingType'' for XML PATH('''')), 1, 1, '''') as CreationMethodText
			  ,STUFF(
				(select ''; '' + Value 
				   from ObjectNomenclature obj 
				   join Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.DocumentGid = d.Gid and n.Type = ''Originality'' for XML PATH('''')), 1, 1, '''') as OriginalityText
			  ,STUFF(
				(select ''; '' + Value 
				   from ObjectNomenclature obj 
				   join Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.DocumentGid = d.Gid and n.Type = ''Language'' for XML PATH('''')), 1, 1, '''') as LanguageText
            ,[IsNoDate] as HasNoChronologicalScope
			,[StartDateYear]
			,[StartDateMonth]
			,[StartDateDay]
			,[EndDateYear]
			,[EndDateMonth]
			,[EndDateDay]
			,TextDate as ApproximateChronologicalScope
			,PlaceOfCreation AS Location
			--,[MagnetTapesCount] as TapeCount
			--,[MicrofilmsCount] as MicrofilmCount
			--,[FramesCount] as FrameCount
			--,[VideoTapesCount] as VideoTapeCount
			--,[ElectrCount] as DigitalDeviceCount
			,DimensionInCentimeters as SizeCm
			--,[ExtentOther] as OtherMetrics -- дали е това от ИСДА?
			,[ExtendedContentDescription] as Description
			,[SpecificDetails] as Features
			--,NULL as Condition -- не го намирам
			,[CopyMicrofilm] as MicrofilmedCopyCount
			,[CopyDigital] as DigitizedCopyCount
			,[CopyXerox] as PaperCopyCount
			,[CopyNegativFrames] as NegativeFrameCount
			,[CopyPositiveFrames] as PositiveFrameCount
			,[CopyOther] as OtherCopyCount
			--,NULL as EnrolledBytes
			--,[AveilabilityDocumentsCountAssigned] as EnrolledDocumentCount
			--,[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters
		    --,NULL as DeductedBytes
			--,[AveilabilityDocumentsCountDeducted] as DeductedDocumentCount
			--,[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
			,Note as Notes
			,null as DocumentsAccessDescription
			,d.CreationDate as CreatedOn
			,d.CreationAuthor as CreatedByDisplayName
			,d.ModificationDate as UpdatedOn
			,d.ModificationAuthor as UpdatedByDisplayName
			,[PaperCount] as SheetCount
			,IsNull(d.HasDigitalObject,0) as HasDigitizedDigitalObjects
		 FROM Document_Active d
		WHERE 
			LGid = ' + CAST(@Identifier as varchar(10));
			
	set @sql = REPLACE(@sql, '''', '''''');
	declare @result varchar(max) = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''')';

	exec (@result);
END
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
		RETURN;

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
	  		,ur.[Date] as AccessDate
			,d.SystemIdentifier
			,d.ExternalIdentifier
			,d.HasExternalSource
			,i.Number as InventoryNumber
			,ae.Number as ArchivalEntityNumber
			,d.Number as DocumentNumber
			
	      FROM [UserReviews] as ur
	 LEFT JOIN AspNetUserProfiles as up
	  	    ON ur.UserId = up.UserId
	  	  JOIN v_Documents as d
	  	    ON ur.DocumentSystemIdentifier = d.SystemIdentifier OR ur.DocumentExternalIdentifier = d.ExternalIdentifier
	 LEFT JOIN v_Funds as f
	  	    ON d.FundSystemIdentifier = f.SystemIdentifier OR ur.FundExternalIdentifier = f.ExternalIdentifier
	 LEFT JOIN v_Inventories as i
		    ON d.InventorySystemIdentifier = i.SystemIdentifier OR ur.InventoryExternalIdentifier = i.ExternalIdentifier
	 LEFT JOIN v_ArchivalEntities as ae
		    ON d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier OR ur.ArchivalEntityExternalIdentifier = ae.ExternalIdentifier
	 LEFT JOIN Archives as a
	  	    ON d.ArchiveId = a.Id
	 LEFT JOIN N.FundDescriptionLevel as fdl
	  	    ON f.DescriptionLevelCode = fdl.Code
	     WHERE ((select u.UserType from AspNetUsers as u where up.UserId = u.Id) <> ''EXT'')
		   AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
		   AND ((''-999'' in (select element from dbo.SplitString(''' + @Employee  + ''', '',''))) 
				OR (convert(varchar(max), up.UserId, 104) in (select element from dbo.SplitString(''' + @Employee + ''', '',''))))
		   AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
		   AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
		   AND ((''-999'' in (select element from dbo.SplitString(''') + @FundLevelOfdescriptionCodes + CONVERT(NVARCHAR(MAX),''', '',''))) 
				OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''') + @FundLevelOfdescriptionCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
		   AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(ur.[Date] as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
		   AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(ur.[Date] as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))');
	END

	BEGIN
	SET @sql = @localQuery + @sqlFinalPart;
	END

	--print @sql;
	EXEC (@sql);
END
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
		RETURN;

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
	  		,CASE WHEN i.SystemIdentifier IS NOT NULL THEN CONVERT(varchar(max), i.SystemIdentifier)
				  ELSE CONVERT(varchar(max), i.ExternalIdentifier)
				  END as Inventory
	  		,CASE WHEN ae.SystemIdentifier IS NOT NULL THEN CONVERT(varchar(max), ae.SystemIdentifier)
				  ELSE CONVERT(varchar(max), ae.ExternalIdentifier)
				  END as ArchiveEntity
	  		,CASE WHEN d.SystemIdentifier IS NOT NULL THEN CONVERT(varchar(max), d.SystemIdentifier)
				  ELSE CONVERT(varchar(max), d.ExternalIdentifier)
				  END as Document
	  		,ur.[Date] as AccessDate
			,d.SystemIdentifier
			,d.ExternalIdentifier
			,d.HasExternalSource
			,i.Number as InventoryNumber
			,ae.Number as ArchivalEntityNumber
			,d.Number as DocumentNumber

	      FROM [UserReviews] as ur
	 LEFT JOIN AspNetUserProfiles as up
	  	    ON ur.UserId = up.UserId
	  	  JOIN v_Documents as d
	  	    ON ur.DocumentSystemIdentifier = d.SystemIdentifier OR ur.DocumentExternalIdentifier = d.ExternalIdentifier
	 LEFT JOIN v_Funds as f
	  	    ON d.FundSystemIdentifier = f.SystemIdentifier OR ur.FundExternalIdentifier = f.ExternalIdentifier
	 LEFT JOIN v_Inventories as i
		    ON d.InventorySystemIdentifier = i.SystemIdentifier OR ur.InventoryExternalIdentifier = i.ExternalIdentifier
	 LEFT JOIN v_ArchivalEntities as ae
		    ON d.ArchivalEntitySystemIdentifier = ae.SystemIdentifier OR ur.ArchivalEntityExternalIdentifier = ae.ExternalIdentifier
	 LEFT JOIN Archives as a
	  	    ON d.ArchiveId = a.Id
	 LEFT JOIN N.FundDescriptionLevel as fdl
	  	    ON f.DescriptionLevelCode = fdl.Code
	     WHERE ((select u.UserType from AspNetUsers as u where up.UserId = u.Id) = ''EXT'')
		   AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
				OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))
		   AND ((''-999'' in (select element from dbo.SplitString(''') + @LibraryCardNumber + CONVERT(NVARCHAR(MAX),''', '',''))) 
				OR (up.LibraryCardNumber in (select element from dbo.SplitString(''') + @LibraryCardNumber + CONVERT(NVARCHAR(MAX),''', '',''))))
		   AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@FundNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
		   AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (i.Number = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@InventoryNumber, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
		   AND ((''-999'' in (select element from dbo.SplitString(''') + @FundLevelOfdescriptionCodes + CONVERT(NVARCHAR(MAX),''', '',''))) 
				OR (f.DescriptionLevelCode in (select element from dbo.SplitString(''') + @FundLevelOfdescriptionCodes + CONVERT(NVARCHAR(MAX),''', '',''))))
		   AND ((''' + COALESCE(@DateFrom, 'null') + ''' = ''null'') 
				OR (cast(ur.[Date] as date) >= cast(''' + COALESCE(@DateFrom, 'null') + ''' as datetime2)))
		   AND ((''' + COALESCE(@DateTo, 'null') + ''' = ''null'') 
				OR (cast(ur.[Date] as date) <= cast(''' + COALESCE(@DateTo, 'null') + ''' as datetime2)))');
	END

	BEGIN
	SET @sql = @localQuery + @sqlFinalPart;
	END

	--print @sql;
	EXEC (@sql);
END
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
				AccessDate varchar(50) NULL,
				SystemIdentifier uniqueidentifier NULL,
				ExternalIdentifier int NULL,
				HasExternalSource bit NULL,				
				InventoryNumber nvarchar(50) NULL,
				ArchivalEntityNumber nvarchar(50) NULL,
				DocumentNumber nvarchar(50) NULL
				
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
				AccessDate,
				SystemIdentifier,
				ExternalIdentifier,
				HasExternalSource,
				InventoryNumber,
				ArchivalEntityNumber,
				DocumentNumber

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
				AccessDate varchar(50) NULL,
				SystemIdentifier uniqueidentifier NULL,
				ExternalIdentifier int NULL,
				HasExternalSource bit NULL,				
				InventoryNumber nvarchar(50) NULL,
				ArchivalEntityNumber nvarchar(50) NULL,
				DocumentNumber nvarchar(50) NULL
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
				AccessDate,
				SystemIdentifier,
				ExternalIdentifier,
				HasExternalSource,
				InventoryNumber,
				ArchivalEntityNumber,
				DocumentNumber
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





CREATE OR ALTER view [dbo].[v_ArchivalEntities]
AS

SELECT ae.Id
	  ,ae.SystemIdentifier
      ,CAST(0 as bit) as IsDraft
	  ,ae.IsSuspended
      ,ae.ArchiveId
      ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,NULL as FundDraftId
      ,ae.FundSystemIdentifier
	  ,f.NumberArray as FundNumberArray
	  ,f.NumberNumeric as FundNumberNumeric
      ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,NULL as InventoryDraftId
      ,ae.InventorySystemIdentifier
	  ,i.NumberArray as InventoryNumberArray
	  ,i.NumberNumeric as InventoryNumberNumeric
	  ,i.Number as InventoryNumber
	  ,i.HasExternalSource as InventoryHasExternalSource
	  ,i.ExternalIdentifier as InventoryExternalIdentifier
	  ,i.AvailabilityStatusCode as InventoryAvailabilityStatusCode
	  ,ae.CreatedOn
      ,ae.CreatedBy
      ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,ae.UpdatedOn
      ,ae.UpdatedBy
      ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,ae.Deleted
      ,ae.DeletedOn
      ,ae.DeletedBy
      ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,ae.HasExternalSource
      ,ae.ExternalIdentifier
      ,ae.ExternalSourceUpdatedOn
      ,ae.Number
	  ,ae.NumberNumeric
	  ,ae.NumberArray
      ,ae.Title
	  ,ae.DescriptionLevelCode
	  ,l.Text as DescriptionLevelText
      ,ae.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
      ,ae.StatusCode
	  ,s.Text as StatusText
      ,ae.HasNoChronologicalScope
      ,ae.StartDateYear
      ,ae.StartDateMonth
      ,ae.StartDateDay
      ,ae.EndDateYear
      ,ae.EndDateMonth
      ,ae.EndDateDay
      ,ae.ApproxmateChronologicalScope
      ,ae.Author
      ,ae.Location
      ,ae.Bytes
      ,ae.SheetCount
      ,ae.TapeCount
      ,ae.MicrofilmCount
      ,ae.FrameCount
      ,ae.VideoTapeCount
      ,ae.DigitalDeviceCount
      ,ae.OtherMetrics
      ,ae.SizeCm
      ,ae.Scaling
      ,ae.Description
      ,ae.DocumentsAccessDescription
      ,ae.Features
      ,ae.Condition
      ,ae.MicrofilmedCopyCount
      ,ae.DigitizedCopyCount
      ,ae.PaperCopyCount
      ,ae.NegativeFrameCount
      ,ae.PositiveFrameCount
      ,ae.OtherCopyCount
      ,ae.Notes
      ,ae.EnrolledBytes
      ,ae.EnrolledDocumentCount
      ,ae.EnrolledLinearMeters
      ,ae.DeductedBytes
      ,ae.DeductedDocumentCount
      ,ae.DeductedLinearMeters
	  ,ae.IsImported
	  ,ae.DescriptionAuthor
	  ,ae.Cypher
	  ,ae.TextDocsCount
	  ,ae.GraphicalDocsCount
	  ,ae.Phase
	  ,ae.Part
	  ,ae.Stage
	  ,ae.OtherLanguage
	  ,ae.ClassificationSchemeIndex
	  , IsNull(
		(select top 1 HasDigitizedDigitalObjects from v_Documents doc 
		where doc.ArchivalEntitySystemIdentifier = ae.SystemIdentifier 
		and IsDraft = 0 and Deleted = 0
		and HasDigitizedDigitalObjects = 1), 0) HasDigitizedDigitalObjects

  FROM dbo.ArchivalEntities ae
  JOIN dbo.Archives a ON ae.ArchiveId = a.Id
  JOIN dbo.Funds f ON ae.FundSystemIdentifier = f.SystemIdentifier
  JOIN dbo.Inventories i ON ae.InventorySystemIdentifier = i.SystemIdentifier
  LEFT JOIN dbo.ArchivalEntityDrafts d on ae.SystemIdentifier = d.SystemIdentifier and d.IsCurrent = 1
  LEFT JOIN N.ArchivalEntityDescriptionLevel l ON ae.DescriptionLevelCode = l.Code
  LEFT JOIN N.AvailabilityStatus ast ON ae.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON ae.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON ae.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON ae.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON ae.DeletedBy = du.Id
 WHERE d.Id IS NULL

 UNION
 
SELECT d.Id
	  ,d.SystemIdentifier
      ,CAST(1 as bit) as IsDraft
	  ,CAST(0 as bit) as IsSuspended
      ,d.ArchiveId
      ,a.Code as ArchiveCode
	  ,a.Name as ArchiveName
	  ,d.FundDraftId
      ,d.FundSystemIdentifier
	  ,fd.NumberArray as FundNumberArray
	  ,fd.NumberNumeric as FundNumberNumeric
      ,f.Number as FundNumber
	  ,f.HasExternalSource as FundHasExternalSource
	  ,f.ExternalIdentifier as FundExternalIdentifier
      ,d.InventoryDraftId
      ,d.InventorySystemIdentifier
	  ,id.NumberArray as InventoryNumberArray
	  ,id.NumberNumeric as InventoryNumberNumeric
	  ,i.Number as InventoryNumber
	  ,i.HasExternalSource as InventoryHasExternalSource
	  ,i.ExternalIdentifier as InventoryExternalIdentifier
	  ,i.AvailabilityStatusCode as InventoryAvailabilityStatusCode
	  ,d.CreatedOn
      ,d.CreatedBy
      ,cu.DisplayName as CreatedByDisplayName
	  ,cu.UserName as CreatedByUserName
	  ,d.UpdatedOn
      ,d.UpdatedBy
      ,uu.DisplayName as UpdatedByDisplayName
	  ,uu.UserName as UpdatedByUserName
      ,d.Deleted
      ,d.DeletedOn
      ,d.DeletedBy
      ,du.DisplayName as DeletedByDisplayName
	  ,du.UserName as DeletedByUserName
      ,d.HasExternalSource
      ,d.ExternalIdentifier
      ,d.ExternalSourceUpdatedOn
      ,d.Number
	  ,d.NumberNumeric
	  ,d.NumberArray
      ,d.Title
      ,d.DescriptionLevelCode
	  ,l.Text as DescriptionLevelText
	  ,d.AvailabilityStatusCode
	  ,ast.Text as AvailabilityStatusText
      ,d.StatusCode
	  ,s.Text as StatusText
      ,d.HasNoChronologicalScope
      ,d.StartDateYear
      ,d.StartDateMonth
      ,d.StartDateDay
      ,d.EndDateYear
      ,d.EndDateMonth
      ,d.EndDateDay
      ,d.ApproxmateChronologicalScope
      ,d.Author
      ,d.Location
      ,d.Bytes
      ,d.SheetCount
      ,d.TapeCount
      ,d.MicrofilmCount
      ,d.FrameCount
      ,d.VideoTapeCount
      ,d.DigitalDeviceCount
      ,d.OtherMetrics
      ,d.SizeCm
      ,d.Scaling
      ,d.Description
      ,d.DocumentsAccessDescription
      ,d.Features
      ,d.Condition
      ,d.MicrofilmedCopyCount
      ,d.DigitizedCopyCount
      ,d.PaperCopyCount
      ,d.NegativeFrameCount
      ,d.PositiveFrameCount
      ,d.OtherCopyCount
      ,d.Notes
      ,d.EnrolledBytes
      ,d.EnrolledDocumentCount
      ,d.EnrolledLinearMeters
      ,d.DeductedBytes
      ,d.DeductedDocumentCount
      ,d.DeductedLinearMeters
	  ,d.IsImported
	  ,d.DescriptionAuthor
	  ,d.Cypher
	  ,d.TextDocsCount
	  ,d.GraphicalDocsCount
	  ,d.Phase
	  ,d.Part
	  ,d.Stage
	  ,d.OtherLanguage
	  ,d.ClassificationSchemeIndex
	  , 0 as HasDigitizedDigitalObjects


  FROM dbo.ArchivalEntityDrafts d
  JOIN dbo.Archives a ON d.ArchiveId = a.Id
  LEFT JOIN dbo.Funds f ON d.FundSystemIdentifier = f.SystemIdentifier
  LEFT JOIN dbo.FundDrafts fd ON d.FundSystemIdentifier = fd.SystemIdentifier AND d.FundDraftId = fd.Id 
  LEFT JOIN dbo.Inventories i ON d.InventorySystemIdentifier = i.SystemIdentifier 
  LEFT JOIN dbo.InventoryDrafts id ON d.InventorySystemIdentifier = id.SystemIdentifier AND d.InventoryDraftId = id.Id
  LEFT JOIN N.ArchivalEntityDescriptionLevel l ON d.DescriptionLevelCode = l.Code
  LEFT JOIN N.AvailabilityStatus ast ON d.AvailabilityStatusCode = ast.Code
  LEFT JOIN N.Status s ON d.StatusCode = s.Code
  LEFT JOIN dbo.AspNetUsers cu ON d.CreatedBy = cu.Id
  LEFT JOIN dbo.AspNetUsers uu ON d.UpdatedBy = uu.Id
  LEFT JOIN dbo.AspNetUsers du ON d.DeletedBy = du.Id
 WHERE d.IsCurrent = 1
GO





CREATE OR ALTER PROCEDURE [dbo].[sp_GetArchiveEntitiesByInventory]
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
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,NumberArray  nvarchar(250) null
		,ClassificationSchemeIndex nvarchar(250) null

		,DescriptionAuthor nvarchar(255) null
		,Cypher nvarchar(255) null
		,TextDocsCount int null
		,GraphicalDocsCount int null
		,Phase nvarchar(255) null
		,Part nvarchar(255) null
		,Stage nvarchar(255) null
		,Author nvarchar(255) null
		,HasDigitizedDigitalObjects bit null
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
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,NumberArray  nvarchar(250) null
		,ClassificationSchemeIndex nvarchar(250) null

		,DescriptionAuthor nvarchar(255) null
		,Cypher nvarchar(255) null
		,TextDocsCount int null
		,GraphicalDocsCount int null
		,Phase nvarchar(255) null
		,Part nvarchar(255) null
		,Stage nvarchar(255) null
		,Author nvarchar(255) null
		,HasDigitizedDigitalObjects bit null
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
		,ae.[CreationDate] as CreatedOn
		,ae.[CreationAuthor] as CreatedByDisplayName
		,ae.[ModificationDate] as UpdatedOn
		,ae.[ModificationAuthor] as UpdatedByDisplayName
		,null as NumberArray
		,null as ClassificationSchemeIndex
		
		,null as DescriptionAuthor 
		,null as Cypher 
		,null as TextDocsCount
		,null as GraphicalDocsCount
		,null as Phase
		,null as Part
		,null as Stage
		,null as Author
		,IsNull( 
			(select top 1 doc.HasDigitalObject 
			from Document_Search_Active doc 
			where doc.AELGid = ae.LGid 
			and doc.HasDigitalObject = 1), 0) as HasDigitizedDigitalObjects

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
				,ae.NumberNumeric as IntNumber
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
				,ae.CreatedOn as CreatedOn
				,ae.CreatedByDisplayName as CreatedByDisplayName
				,ae.UpdatedOn as UpdatedOn
				,ae.UpdatedBy as UpdatedByDisplayName
				,ae.NumberArray as NumberArray
				,ae.ClassificationSchemeIndex as ClassificationSchemeIndex

				,ae.DescriptionAuthor as DescriptionAuthor 
				,ae.Cypher as Cypher 
				,ae.TextDocsCount as TextDocsCount
				,ae.GraphicalDocsCount as GraphicalDocsCount
				,ae.Phase as Phase
				,ae.Part as Part
				,ae.Stage as Stage
				,ae.Author as Author
				,ae.HasDigitizedDigitalObjects
	     FROM [dbo].[v_ArchivalEntities] ae
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
	ORDER BY IntNumber, NumberArray
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END
GO




CREATE OR ALTER VIEW [dbo].[v_PublicArchivalEntities] AS
	SELECT 
		ae.Id, 
		ae.SystemIdentifier, 
		CAST(0 AS bit) AS IsDraft,
		ae.ArchiveId, 
		a.Code AS ArchiveCode,
		a.Name AS ArchiveName,
		NULL AS FundDraftId,
		ae.FundSystemIdentifier,
		f.Number AS FundNumber, 
        f.HasExternalSource AS FundHasExternalSource,
		f.ExternalIdentifier AS FundExternalIdentifier,
		NULL AS InventoryDraftId, 
		ae.InventorySystemIdentifier, 
		i.Number AS InventoryNumber, 
        i.HasExternalSource AS InventoryHasExternalSource, 
		i.ExternalIdentifier AS InventoryExternalIdentifier, 
		ae.CreatedOn, 
		ae.CreatedBy, 
		cu.DisplayName AS CreatedByDisplayName, 
		cu.UserName AS CreatedByUserName, 
		ae.UpdatedOn, 
        ae.UpdatedBy, 
		uu.DisplayName AS UpdatedByDisplayName,
		uu.UserName AS UpdatedByUserName, 
		ae.Deleted, 
		ae.DeletedOn,
		ae.DeletedBy, 
		du.DisplayName AS DeletedByDisplayName, 
		du.UserName AS DeletedByUserName, 
        ae.HasExternalSource, 
		ae.ExternalIdentifier, 
		ae.ExternalSourceUpdatedOn, 
		ae.Number,
		ae.Title, 
		ae.DescriptionLevelCode, 
		l.Text AS DescriptionLevelText, 
		ae.StatusCode,
		s.Text AS StatusText, 
		ae.HasNoChronologicalScope, 
        ae.StartDateYear,
		ae.StartDateMonth, 
		ae.StartDateDay, 
		ae.EndDateYear, 
		ae.EndDateMonth, 
		ae.EndDateDay, 
		ae.ApproxmateChronologicalScope, 
		ae.Author, 
		ae.Location, 
		ae.Bytes,
		ae.SheetCount, 
		ae.TapeCount,
		ae.MicrofilmCount, 
        ae.FrameCount,
		ae.VideoTapeCount,
		ae.DigitalDeviceCount,
		ae.OtherMetrics, 
		ae.SizeCm, 
		ae.Scaling, 
		ae.Description, 
		ae.DocumentsAccessDescription, 
		ae.Features, 
		ae.Condition, 
		ae.MicrofilmedCopyCount, 
		ae.DigitizedCopyCount, 
        ae.PaperCopyCount,
		ae.NegativeFrameCount, 
		ae.PositiveFrameCount,
		ae.OtherCopyCount, 
		ae.Notes, 
		ae.EnrolledBytes, 
		ae.EnrolledDocumentCount, 
		ae.EnrolledLinearMeters, 
		ae.DeductedBytes,
		ae.DeductedDocumentCount, 
        ae.DeductedLinearMeters, 
		f.NumberNumeric as FundNumberNumeric, 
		i.NumberNumeric as InventoryNumberNumeric, 
		ae.NumberNumeric,
		ae.NumberArray,
		ast.Text as AvailabilityStatusText, 
		i.AvailabilityStatusCode,
		IsNull(
		(select top 1 HasDigitizedDigitalObjects from v_PublicDocuments doc 
		where doc.ArchivalEntitySystemIdentifier = ae.SystemIdentifier 
		and IsDraft = 0 and Deleted = 0
		and HasDigitizedDigitalObjects = 1), 0) HasDigitizedDigitalObjects

	FROM dbo.ArchivalEntities AS ae
		INNER JOIN dbo.Archives AS a ON ae.ArchiveId = a.Id 
		INNER JOIN dbo.Funds AS f ON ae.FundSystemIdentifier = f.SystemIdentifier
		INNER JOIN dbo.Inventories AS i ON ae.InventorySystemIdentifier = i.SystemIdentifier 
		LEFT OUTER JOIN N.ArchivalEntityDescriptionLevel AS l ON ae.DescriptionLevelCode = l.Code 
		LEFT OUTER JOIN N.Status AS s ON ae.StatusCode = s.Code
		LEFT OUTER JOIN dbo.AspNetUsers AS cu ON ae.CreatedBy = cu.Id 
		LEFT OUTER JOIN dbo.AspNetUsers AS uu ON ae.UpdatedBy = uu.Id 
		LEFT OUTER JOIN dbo.AspNetUsers AS du ON ae.CreatedBy = du.Id
		LEFT JOIN N.AvailabilityStatus ast ON ae.AvailabilityStatusCode = ast.Code
	WHERE f.IsSuspended = 0
	AND ae.StatusCode <> 12 --статус отчислен
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
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,NumberArray  nvarchar(250) null
		,ClassificationSchemeIndex nvarchar(250) null

		,DescriptionAuthor nvarchar(255) null
		,Cypher nvarchar(255) null
		,TextDocsCount int null
		,GraphicalDocsCount int null
		,Phase nvarchar(255) null
		,Part nvarchar(255) null
		,Stage nvarchar(255) null
		,Author nvarchar(255) null
		,HasDigitizedDigitalObjects bit null
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
		,CreatedOn datetime2(7)
		,CreatedByDisplayName nvarchar(256)
		,UpdatedOn datetime2(7)
		,UpdatedByDisplayName nvarchar(256)
		,NumberArray  nvarchar(250) null
		,ClassificationSchemeIndex nvarchar(250) null

		,DescriptionAuthor nvarchar(255) null
		,Cypher nvarchar(255) null
		,TextDocsCount int null
		,GraphicalDocsCount int null
		,Phase nvarchar(255) null
		,Part nvarchar(255) null
		,Stage nvarchar(255) null
		,Author nvarchar(255) null
		,HasDigitizedDigitalObjects bit null
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
		,ae.[CreationDate] as CreatedOn
		,ae.[CreationAuthor] as CreatedByDisplayName
		,ae.[ModificationDate] as UpdatedOn
		,ae.[ModificationAuthor] as UpdatedByDisplayName
		,null as NumberArray
		,null as ClassificationSchemeIndex

			
		,null as DescriptionAuthor 
		,null as Cypher 
		,null as TextDocsCount
		,null as GraphicalDocsCount
		,null as Phase
		,null as Part
		,null as Stage
		,null as Author
		,IsNull( 
			(select top 1 doc.HasDigitalObject 
			from Document_Search_Active doc 
			where doc.AELGid = ae.LGid 
			and doc.HasDigitalObject = 1), 0) as HasDigitizedDigitalObjects

	FROM [Archiving].[dbo].[ArchiveEntity_Active] ae
	WHERE ae.InventoryLGid = ' + CAST(@InventoryExternalIdentifier as nvarchar(50));

		IF @SearchText IS NOT NULL
		BEGIN
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  ' AND (ae.Title LIKE ''''%' + @SearchText + '%'''' OR ae.Number LIKE ''''%' + @SearchText + '%'''')'
		END;
		
		IF @SearchNumber IS NOT NULL
		BEGIN
			SET @RemoteArchivalEntitiesQuery = @RemoteArchivalEntitiesQuery +  'AND (ae.Number LIKE ''''' + @SearchNumber + ''''')'
			--(ae.Number LIKE ' + @SearchNumber + ')'
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
				,ae.CreatedOn as CreatedOn
				,ae.CreatedByDisplayName as CreatedByDisplayName
				,ae.UpdatedOn as UpdatedOn
				,ae.UpdatedBy as UpdatedByDisplayName
				,ae.NumberArray as NumberArray
				,null as ClassificationSchemeIndex

				,null as DescriptionAuthor 
				,null as Cypher 
				,null as TextDocsCount
				,null as GraphicalDocsCount
				,null as Phase
				,null as Part
				,null as Stage
				,null as Author
				,ae.HasDigitizedDigitalObjects
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
	ORDER BY IntNumber, NumberArray
	OFFSET ((@PageNumber - 1) * @PageSize) ROWS FETCH NEXT @PageSize ROWS ONLY
END
GO





CREATE OR ALTER PROCEDURE [dbo].[sp_GetArchiveEntity] 
	@LinkedServer nvarchar(50),
	@Identifier int
AS
BEGIN
	SET NOCOUNT ON;
 
	declare @sql varchar(max) = '
		SELECT 
			-1 as Id
			,NULL as SystemIdentifier
			,CAST(1 as bit) as HasExternalSource
			,LGid as ExternalIdentifier
			,(select Code from Nomenclature n where n.Gid = AveilabilityGid and n._retired = ''3000-01-01 00:00:00.000'') as AvailabilityStatusCode
			,(select Value from Nomenclature n where n.Gid = AveilabilityGid and n._retired = ''3000-01-01 00:00:00.000'') as AvailabilityStatusText
			,(select CAST(Code as nvarchar(50)) from Nomenclature n where n.Gid = StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusCode
			,(select Value from Nomenclature n where n.Gid = StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusText
			,(select a.Code from Archive a where a.Gid = ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveCode
			,(select a.Name from Archive a where a.Gid = ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveName
			,CAST(1 AS BIT) as FundHasExternalSource
			,FundLGid as FundExternalIdentifier
			,(SELECT Number FROM Fund_Active AS fund WHERE fund.LGid = FundLGid) AS FundNumber
			,CAST(1 AS BIT) as InventoryHasExternalSource
			,InventoryLGid as InventoryExternalIdentifier
			,(SELECT Number FROM Inventory_Active AS inventory WHERE inventory.LGid = InventoryLGid) AS InventoryNumber
			,Number
			,Title
			,(select CAST(Code as nvarchar(50)) from Nomenclature n where n.Gid= LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelCode
			,(select Value from Nomenclature n where n.Gid= LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelText
			,STUFF(
				(select ''; '' + Value 
				   from ObjectNomenclature obj 
				   join Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.ArchiveEntityGid = ae.Gid and n.Type = ''CreatingType'' for XML PATH('''')), 1, 1, '''') as CreationMethodText
			  ,STUFF(
				(select ''; '' + Value 
				   from ObjectNomenclature obj 
				   join Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.ArchiveEntityGid = ae.Gid and n.Type = ''Originality'' for XML PATH('''')), 1, 1, '''') as OriginalityText
			  ,STUFF(
				(select ''; '' + Value 
				   from ObjectNomenclature obj 
				   join Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.ArchiveEntityGid = ae.Gid and n.Type = ''Language'' for XML PATH('''')), 1, 1, '''') as LanguageText
            ,[IsNoDate] as HasNoChronologicalScope
			,[StartDateYear]
			,[StartDateMonth]
			,[StartDateDay]
			,[EndDateYear]
			,[EndDateMonth]
			,[EndDateDay]
			,TextDate as ApproximateChronologicalScope
			,PlaceOfCreation AS Location 
			,AccessConditions as DocumentsAccessDescription
			,[MagnetTapesCount] as TapeCount
			,[MicrofilmsCount] as MicrofilmCount
			,[FramesCount] as FrameCount
			,[VideoTapesCount] as VideoTapeCount
			,[ElectrCount] as DigitalDeviceCount
			,[ExtentOther] as OtherMetrics -- дали е това от ИСДА?
			,[DimensionInCentimeters] as SizeCm
			,[ExtendedContentDescription] as Description
			,[SpecificDetails] as Features
			,[CopyMicrofilm] as MicrofilmedCopyCount
			,[CopyDigital] as DigitizedCopyCount
			,[CopyXerox] as PaperCopyCount
			,PaperCount as SheetCount
			,[CopyNegativFrames] as NegativeFrameCount
			,[CopyPositiveFrames] as PositiveFrameCount
			,[CopyOther] as OtherCopyCount
			,[AveilabilityDocumentsCountAssigned] as EnrolledDocumentCount
			,[AveilabilityLinearMetersAssigned] as EnrolledLinearMeters
			,[AveilabilityDocumentsCountDeducted] as DeductedDocumentCount
			,[AveilabilityLinearMetersDeducted] as DeductedLinearMeters
			,Note as Notes
			,ae.[CreationDate] as CreatedOn
			,ae.[CreationAuthor] as CreatedByDisplayName
			,ae.[ModificationDate] as UpdatedOn
			,ae.[ModificationAuthor] as UpdatedByDisplayName
			,null as ClassificationSchemeIndex

			,null as DescriptionAuthor 
			,null as Cypher 
			,null as TextDocsCount
			,null as GraphicalDocsCount
			,null as Phase
			,null as Part
			,null as Stage 
			,null as Author
			,IsNull( 
				(select top 1 doc.HasDigitalObject 
				from Document_Search_Active doc 
				where doc.AELGid = ae.LGid 
				and doc.HasDigitalObject = 1), 0) as HasDigitizedDigitalObjects

		FROM ArchiveEntity_Active ae
		WHERE 
			LGid = ' + CAST(@Identifier as varchar(10));

	set @sql = REPLACE(@sql, '''', '''''');
	declare @result varchar(max) = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''')';

	exec (@result);
END
GO



----------------------------------------------------------
--	THE SCRIPT IS CLOSED - USE THE NEW ONE!
----------------------------------------------------------

commit
