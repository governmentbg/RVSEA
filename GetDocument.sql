
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE IF EXISTS [dbo].[sp_GetDocument]
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