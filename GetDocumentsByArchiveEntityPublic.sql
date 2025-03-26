
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE IF EXISTS dbo.sp_GetDocumentsByArchiveEntity
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
