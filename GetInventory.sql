USE [DAA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


DROP PROCEDURE IF EXISTS [dbo].[sp_GetInventory]
GO


CREATE PROCEDURE [dbo].[sp_GetInventory] 
	@LinkedServer nvarchar(50),
	@Identifier int
AS
BEGIN
	SET NOCOUNT ON;

	declare @sql varchar(max) = '
		SELECT -1 as Id
			  ,NULL as SystemIdentifier
			  ,CAST(1 as bit) as HasExternalSource
			  ,inventory.[LGid] as ExternalIdentifier
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusText
			  ,(select Code from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''3000-01-01 00:00:00.000'') as AvailabilityStatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.AveilabilityGid and n._retired = ''3000-01-01 00:00:00.000'') as AvailabilityStatusText
			  ,CAST(1 as bit) as FundHasExternalSource
			  ,(select f.LGid from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''3000-01-01 00:00:00.000'') as FundExternalIdentifier
			  ,(select f.Number from [Archiving].[dbo].Fund_Active f where f.LGid = inventory.FundLGid and f._retired = ''3000-01-01 00:00:00.000'') as FundNumber
			  ,(select a.Code from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveCode
			  ,(select a.Name from [Archiving].[dbo].Archive a where a.Gid = inventory.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveName
			  ,(select n.Value from [Archiving].[dbo].Nomenclature n where n.Gid = inventory.InventoryArrayGid and n._retired = ''3000-01-01 00:00:00.000'') as NumberArray
			  ,inventory.[IntNumber] as NumberNumeric
			  ,inventory.[Number] as Number
			  ,inventory.[TextDate] as ApproxmateChronologicalScope
			  ,inventory.[LinearMeter] as LinearMeters
			  ,inventory.[AECount] as ArchivalEntityCount
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
			  ,inventory.[ImmediateSourceOfAcquisition] as DocumentsProvider
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''MethodOfAcquisition'' for XML PATH('''')), 1, 1, '''') as AcquisitionMethodText
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''CreatingType'' for XML PATH('''')), 1, 1, '''') as CreationMethodText
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''Originality'' for XML PATH('''')), 1, 1, '''') as OriginalityText
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.InventoryGid = inventory.Gid and n.Type = ''Language'' for XML PATH('''')), 1, 1, '''') as LanguageText
			  ,inventory.[ClassificationScheme] as ClassificationScheme
			  ,inventory.[AccessConditions] as DocumentsAccessDescription
			  ,inventory.[Abbreviations] as AbbreviationList
			  ,inventory.[CopyMicrofilmAE] as MicrofilmedArchivalEntityCount
			  ,inventory.[CopyNegativFrames] as NegativeFrameCount
			  ,inventory.[CopyPositiveFrames] as PositiveFrameCount
			  ,inventory.[CopyDigitizedAE] as DigitizedArchivalEntityCount
			  ,inventory.[Note] as Notes
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid= inventory.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelText
			  ,inventory.[DocumentProperties] as DocumentsDescription
			  ,inventory.[StartDateYear] as StartDateYear
			  ,inventory.[StartDateMonth] as StartDateMonth
			  ,inventory.[StartDateDay] as StartDateDay
			  ,inventory.[EndDateYear] as EndDateYear
			  ,inventory.[EndDateMonth] as EndDateMonth
			  ,inventory.[EndDateDay] as EndDateDay
			  ,inventory.[IsNoDate] as HasNoChronologicalScope
		  FROM [Archiving].[dbo].[Inventory_Active] inventory
		 WHERE inventory.LGid = ' + CAST(@Identifier as varchar(10));

	set @sql = REPLACE(@sql, '''', '''''');
	declare @linkedServerQuery varchar(max) = '
		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''');';

	EXEC (@linkedServerQuery);	
END