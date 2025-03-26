USE [DAA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DROP PROCEDURE IF EXISTS [dbo].[sp_GetFund]
GO

CREATE PROCEDURE [dbo].[sp_GetFund] 
	@LinkedServer nvarchar(50),
	@Identifier int
AS
BEGIN
	SET NOCOUNT ON;

	declare @sql varchar(max) = '
		SELECT 
			   -1 as Id
			  ,CAST(1 as bit) as HasExternalSource
			  ,fund.[LGid] as ExternalIdentifier
			  ,(select Code from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveCode
			  ,(select Name from [Archiving].[dbo].Archive a where a.Gid = fund.ArchiveGid and a._retired = ''3000-01-01 00:00:00.000'') as ArchiveName
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid= fund.StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid=fund.StatusGid and n._retired = ''3000-01-01 00:00:00.000'') as StatusText
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid=fund.FundArrayGid and n._retired = ''3000-01-01 00:00:00.000'') as NumberArray
			  ,fund.[IntNumber] as NumberNumeric
			  ,fund.[Number] as Number
			  ,(select CAST(Code as nvarchar(50)) from  [Archiving].[dbo].Nomenclature n where n.Gid=fund.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelCode
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid=fund.LevelOfDescriptionGid and n._retired = ''3000-01-01 00:00:00.000'') as DescriptionLevelText
			  ,fund.[Title] as Title
			  ,(select Value from  [Archiving].[dbo].Nomenclature n where n.Gid = fund.TypeGid and n._retired = ''3000-01-01 00:00:00.000'') as TypeText
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.FundGid = fund.Gid and n.Type = ''MethodOfAcquisition'' for XML PATH('''')), 1, 1, '''') as AcquisitionMethodText
			  ,STUFF(
				(select ''; '' + Value2 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.FundGid = fund.Gid and n.Type = ''IndustryIndex'' for XML PATH('''')), 1, 1, '''') as IndustryTypeText
			  ,STUFF(
				(select ''; '' + Value 
				   from [Archiving].[dbo].ObjectNomenclature obj 
				   join [Archiving].[dbo].Nomenclature n on n.Gid = obj.NomenclatureGid 
				  where obj.FundGid = fund.Gid and n.Type = ''Language'' for XML PATH('''')), 1, 1, '''') as LanguageText
			  ,fund.[TextDate] as ApproxmateChronologicalScope
			  ,fund.[LinearMeters] as LinearMeters
			  ,fund.[InvetoryCount] as InventoryCount
			  ,fund.[AECount] as ArchivalEntityCount
			  ,fund.[ExtentOther] as OtherMetrics
			  ,fund.[FundFormerFunction] as FundCreatorActivityHistory
			  ,fund.[FundFormerHistory] as FundCreatorBiographicalHistory
			  ,fund.[ArchivalHistory] as History
			  ,fund.[ImmediateSourceOfAcquisition] as DocumentsProvider
			  ,fund.[AccessConditions] as DocumentsAccessDescription
			  ,fund.[AveilabilityInventoryCountAssigned] as EnrolledInventoryCount
			  ,fund.[AveilabilityInventoryCountDeducted] as DeductedInventoryCount
			  ,fund.[RelatedUnits] as RelatedFunds
			  ,fund.[Note] as Notes
			  ,fund.[DocumentProperties] as DocumentsDescription
			  ,fund.[FundFormerNameChange] as FundCreatorTitleHistory
			  ,fund.[StartDateYear] as StartDateYear
			  ,fund.[StartDateMonth] as StartDateMonth
			  ,fund.[StartDateDay] as StartDateDay
			  ,fund.[EndDateYear] as EndDateYear
			  ,fund.[EndDateMonth] as EndDateMonth
			  ,fund.[EndDateDay] as EndDateDay
			  ,fund.[IsNoDate] as HasNoChronologicalScope
		 FROM [Archiving].[dbo].Fund_Active as fund
		WHERE fund.LGId = ' + CAST(@Identifier as nvarchar(50)) 



	set @sql = REPLACE(@sql, '''', '''''');
	declare @linkedServerQuery varchar(max) = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''');';
	EXEC (@linkedServerQuery);	
END