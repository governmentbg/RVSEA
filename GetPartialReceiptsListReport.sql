SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetPartialReceiptsListReport] 
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

	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreationDate, 104) as CreationDate,
				CONCAT(fund.ImmediateSourceOfAcquisition, '' / '',
					(
						select Value + '';''
						from Nomenclature n1
						inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
						where n1._retired=''3000-01-01'' 
							and on1._retired=''3000-01-01''
							and on1.FundGid = fund.Gid 
							and n1.Type=''MethodOfAcquisition''
						FOR XML path(''''), elements
					)) as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				CONCAT(round(isnull(cast(fund.LinearMeters as decimal(18,2)), 0),2), '' / '', fund.ExtentOther) as VolumeInSheets,
				null as DigitalSize,
				fund.Note,
				fund.IntNumber,
				a.SortOrder,
				null as SystemIdentifier,
				fund.LGid as ExternalIdentifier,
				CAST(1 as bit) as HasExternalSource
			FROM Fund_Modified as fund
			INNER JOIN Archive a ON a.Gid = fund.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE 
				((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) 
				AND fund.LevelOfDescriptionGid = (select Gid from Nomenclature where _retired = ''3000-01-01'' AND [Type] = ''LevelOfDescription'' AND Code = 2)';

		SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END


	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				a.Name as Archive,
				fund.Number,
				convert(varchar, fund.CreatedOn, 104) as CreationDate,
				CONCAT(DocumentsProvider, '' / '', (select n1.Text from N.Nomenclatures n1 where fund.AcquisitionMethodId = n1.Id)) as ImmediateSourceOfAcquisitionPlusMethodOfAcquisition,
				fund.Title,
				CONCAT(round(isnull(cast(fund.LinearMeters as decimal(18,2)), 0),2), '' / '', OtherMetrics) as VolumeInSheets,
				fsi.EnrolledBytes as DigitalSize,
				fund.Notes as Note,
				fund.NumberNumeric as IntNumber,
				a.SortOrder,
				fund.SystemIdentifier,
				fund.ExternalIdentifier,
				fund.HasExternalSource
			FROM Funds fund
			INNER JOIN Archives a ON a.Id = fund.ArchiveId AND a.Deleted = 0
			LEFT JOIN v_FundSizeInfo fsi ON fsi.FundSystemIdentifier = fund.SystemIdentifier AND fsi.IsDraft = 0
			WHERE fund.ExternalIdentifier IS NULL AND fund.HasExternalSource = 0 AND fund.Deleted = 0 
				AND fund.DescriptionLevelCode = 4
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
				VolumeInSheets  nvarchar(300) NULL,
				DigitalSize bigint NULL,
				Note nvarchar(MAX) NULL,
				IntNumber int null,
				SortOrder int null,
				SystemIdentifier nvarchar(256) null,
				ExternalIdentifier int null,
				HasExternalSource bit
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