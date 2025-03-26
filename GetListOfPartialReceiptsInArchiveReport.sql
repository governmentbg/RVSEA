SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[sp_GetListOfPartialReceiptsInArchiveReport]
	@LinkedServer nvarchar(50),
	@ResultType int = 1,
	@RowsOfPage int = 2147483647,
	@Page int = 1,
	@Archives nvarchar(max) = null,
	@PeriodGids nvarchar(max) = null, -- това е наименованието на FundArraysExternal в ИСДА
	@FundArraysInternal nvarchar(max) = null,
	@Statuses nvarchar(max) = null,
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

	DECLARE @sqlFinalPart NVARCHAR(MAX) =  CONVERT(NVARCHAR(MAX),'
		order by CountryCode, Archive
		offset ') + CONVERT(NVARCHAR(10), @offset) +  CONVERT(NVARCHAR(MAX),' rows fetch next ') + CONVERT(NVARCHAR(10), @RowsOfPage) +  CONVERT(VARCHAR(MAX),' rows only');

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
				SELECT
					''BG'' as CountryCode,
					(SELECT Name FROM Archive as archive where archive._retired = ''3000-01-01'' and archive.Gid = fund.ArchiveGid) as Archive,
					fund.Number as FundNumber,
					fund.Title as FundTitle,
					convert(varchar(50), fund.CreationDate, 104) as CreationDate,
					fund.ImmediateSourceOfAcquisition,
					-- (SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.TypeGid) as FundType, отпада по забележка на Архивите
					fund.DocumentProperties,
					fund.Note,
					(SELECT Value FROM Nomenclature where _retired = ''3000-01-01'' and Gid = fund.StatusGid) as FundStatus,
					(select Value + '';''
						from  Nomenclature n1
						inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
						where n1._retired=''3000-01-01'' 
							and on1._retired=''3000-01-01''
							and on1.FundGid = fund.Gid 
							and n1.Type=''MethodOfAcquisition''
						FOR XML path(''''), elements) as MethodOfAcquisition,
					fund.TextDate as ChronologicalScope,
					-- махат се по забележка от ИСДА
					--(isnull(convert(varchar, StartDateDay) + ''.'', '''') + isnull(convert(varchar, StartDateMonth) + ''.'', '''') + isnull(convert(varchar, StartDateYear), '''')) as ChronologicalScopeStartDate,
					--(isnull(convert(varchar, fund.EndDateDay) + ''.'', '''') + isnull(convert(varchar, fund.EndDateMonth) + ''.'', '''') + isnull(convert(varchar, fund.EndDateYear), '''')) as ChronologicalScopeEndDate,
					fund.InvetoryCount as InventoryCount,
					fund.AeCount,
					round(isnull(fund.LinearMeters, 0),2) as LinearMeters,
					null as Size,
					null as Duration,
					null as DurationInt,
					null as EDocumentsCount,
					null as FileFormats,
					null as SystemIdentifier,
					fund.LGid as ExternalIdentifier,
					CAST(1 as bit) as HasExternalSource
				FROM Fund_Modified as fund
				INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
				WHERE fund._retired = ''3000-01-01''
					AND fund.LevelOfDescriptionGid = (SELECT Gid FROM Nomenclature where _retired=''3000-01-01'' and Type=''LevelOfDescription'' and Code = 2)
					AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives + ''', '',''))) OR a.Code in  (select element from dbo.SplitString(''' + @Archives + ''', '','')))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @PeriodGids + ''', '',''))) OR fund.FundArrayGid in (select element from dbo.SplitString(''' + @PeriodGids + ''', '','')))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))) 
						OR (select Code from Nomenclature where _retired=''3000-01-01'' and Gid = fund.StatusGid) in (select element from dbo.SplitString(''' + @Statuses + ''', '','')))
					AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))) OR EXISTS(SELECT 1 FROM ObjectNomenclature where _retired = ''3000-01-01'' and FundGid = fund.Gid and NomenclatureGid in (select element from dbo.SplitString(''' + @MethodOfAcquisitionGids + ''', '',''))))
					AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') OR (cast(fund.CreationDate as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' = ''null'') OR (cast(fund.StartDate as date) >= cast(''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' as datetime2)))
					AND ((''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' = ''null'') OR (cast(fund.EndDate as date) <= cast(''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' as datetime2)))
					AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (fund.TextDate = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
					');

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery NVARCHAR(MAX) = CONVERT(NVARCHAR(MAX),'
				SELECT
				''BG'' as CountryCode
				,a.Name as Archive
				,f.Number as FundNumber
				,f.Title as FundTitle
				,convert(varchar(50), f.CreatedOn, 104) as CreationDate
				,CONCAT(DocumentsProvider, '' / '', (select n1.Text from N.Nomenclatures n1 where f.AcquisitionMethodId = n1.Id)) as ImmediateSourceOfAcquisition
				--,f.TypeText as FundType отпада по забележка на Архивите
				,f.DocumentsDescription as DocumentProperties
				,f.Notes as Note
				,(SELECT Text FROM [N].[Status] s where s.Code = f.StatusCode) as FundStatus
				,STUFF(
					(select ''; '' + n.Text 
						from N.Nomenclatures as n
						where n.Id = f.AcquisitionMethodId and n.Deleted = 0 for XML PATH('''')), 1, 1, '''') as MethodOfAcquisition
				,f.ApproxmateChronologicalScope as ChronologicalScope
				-- махат се по забележка от ИСДА
				--,coalesce(convert(varchar, f.StartDateYear, 104) + ''.'' + convert(varchar, f.StartDateMonth, 104) + ''.'' + convert(varchar, f.StartDateDay, 104),
						  --convert(varchar, f.StartDateYear, 104) + ''.'' + convert(varchar, f.StartDateMonth, 104),
						  --convert(varchar, f.StartDateYear, 104)) as ChronologicalScopeStartDate
				--,coalesce(convert(varchar, f.EndDateYear, 104) + ''.'' + convert(varchar, f.EndDateMonth, 104) + ''.'' + convert(varchar, f.EndDateDay, 104),
						  --convert(varchar, f.EndDateYear, 104) + ''.'' + convert(varchar, f.EndDateMonth, 104),
						  --convert(varchar, f.EndDateYear, 104)) as ChronologicalScopeEndDate
				,fsi.EnrolledInventoryCount as InventoryCount
				,fsi.EnrolledArchivalEntityCount as AeCount
				,null as LinearMeters
				,fsi.EnrolledBytes as Size
				,dbo.FormatDuration((select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier)) as Duration
				,(select sum(d.Duration) from Documents d where f.SystemIdentifier = d.FundSystemIdentifier) as DurationInt
				,fsi.EnrolledDocumentCount as EDocumentsCount
				,fsi.FileTypes as FileFormats
				,f.SystemIdentifier
				,f.ExternalIdentifier
				,f.HasExternalSource
			FROM Funds f
			INNER JOIN Archives a ON a.Id = f.ArchiveId AND a.Deleted = 0
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = f.SystemIdentifier AND fsi.IsDraft = 0
			WHERE f.ExternalIdentifier IS NULL AND f.HasExternalSource = 0 AND f.Deleted = 0 
				AND f.DescriptionLevelCode = 4
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Archives  + ''', '',''))) 
					OR a.Code in (select element from dbo.SplitString(''' + @Archives + ''', '','')))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @Statuses  + ''', '','')) AND f.StatusCode not in (''3'', ''4'',''5'', ''8'', ''9'', ''10'', ''13'')) 
					OR (convert(varchar(4), f.StatusCode, 104) in (select element from dbo.SplitString(''' + @Statuses + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))) 
					OR ((select convert(varchar(4), Code, 104) from N.FundArray fa where fa.Code = f.NumberArray) in (select element from dbo.SplitString(''' + @FundArraysInternal + ''', '',''))))
				AND ((''-999'' in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))) 
					OR ((select Code from N.Nomenclatures n1 where n1.Id = f.AcquisitionMethodId) in (select element from dbo.SplitString(''' + @MethodsOfAcquisitionInternal + ''', '',''))))
				AND ((''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),''' = ''NULL'') OR (f.ApproxmateChronologicalScope = ''') + CONVERT(NVARCHAR(MAX), ISNULL(@ChronologicalScope, CONVERT(NVARCHAR(MAX), N'NULL'))) + CONVERT(NVARCHAR(MAX),'''))
				AND ((''' + COALESCE(@RegisteredFrom, 'null') + ''' = ''null'') 
					OR (cast(f.CreatedOn as date) >= cast(''' + COALESCE(@RegisteredFrom, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@RegisteredTo, 'null') + ''' = ''null'') 
					OR (cast(f.CreatedOn as date) <= cast(''' + COALESCE(@RegisteredTo, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' = ''null'') 
					OR (try_cast(coalesce(
								convert(varchar, f.StartDateYear, 104) + ''.'' + convert(varchar, f.StartDateMonth, 104) + ''.'' + convert(varchar, f.StartDateDay, 104),
								convert(varchar, f.StartDateYear, 104) + ''.'' + convert(varchar, f.StartDateMonth, 104),
								convert(varchar, f.StartDateYear, 104)) as date) >= cast(''' + COALESCE(@ChronologicalScopeStartDate, 'null') + ''' as datetime2)))
				AND ((''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' = ''null'') 
					OR (try_cast(coalesce(
								convert(varchar, f.EndDateYear, 104) + ''.'' + convert(varchar, f.EndDateMonth, 104) + ''.'' + convert(varchar, f.EndDateDay, 104),
								convert(varchar, f.EndDateYear, 104) + ''.'' + convert(varchar, f.EndDateMonth, 104),
								convert(varchar, f.EndDateYear, 104)) as date) <= cast(''' + COALESCE(@ChronologicalScopeEndDate, 'null') + ''' as datetime2)))
			');
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				CountryCode nvarchar(50) NOT NULL,
				Archive nvarchar(256) NULL,
				FundNumber nvarchar(50) NULL,
				FundTitle nvarchar(max) NULL,
				CreationDate varchar(50) NULL,
				ImmediateSourceOfAcquisition nvarchar(MAX) NULL,
				--FundType nvarchar(256) NULL, отпада по забележка на Архивите
				DocumentProperties nvarchar(MAX) NULL,
				Note nvarchar(MAX) NULL,
				FundStatus nvarchar(256) NULL,
				MethodOfAcquisition nvarchar(256) NULL,
				ChronologicalScope nvarchar(256) NULL,
				-- махат се по забележка от ИСДА
				--ChronologicalScopeStartDate nvarchar(256) NULL,
				--ChronologicalScopeEndDate nvarchar(256) NULL,
				InventoryCount int NULL,
				AeCount int NULL,
				LinearMeters float NULL,
				Size bigint NULL,
				Duration nvarchar(14) NULL,
				DurationInt int NULL,
				EDocumentsCount int NULL,
				FileFormats nvarchar(MAX) NULL,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
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