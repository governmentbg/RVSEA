SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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