SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetWorkListForPriorityRestorationReport] 
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
		order by SortOrder, FundIntNumber, FundNumber, InventoryIntNumber, InventoryNumber, ArchivalEntityIntNumber, ArchiveEntityNumber
		offset ' + CONVERT(varchar(10), @offset) + ' rows fetch next ' + CONVERT(varchar(10), @RowsOfPage) + ' rows only';

	--PhysicalCondition дава грешка за някои заявки към ИСДА
	IF @ResultType = 1 OR @ResultType = 2
	BEGIN
		DECLARE @remoteQuery VARCHAR(MAX) = '
			SELECT 
				a.Name as Archive,
				(SELECT fund.Number FROM Fund_Modified as fund WHERE fund.LGid = doc.FundLGid) as FundNumber,
				(SELECT inventory.Number FROM Inventory_Modified as inventory WHERE inventory.LGid = doc.InventoryLGid) as InventoryNumber,
				(SELECT ae.Number FROM ArchiveEntity_Modified as ae WHERE ae.LGid = doc.AELGid) as ArchiveEntityNumber,
				doc.LGid as DocumentSystemId,
				doc.PaperCount,
				(
					select top(1) Value -- слягам top(1), защото има записи, за които се чупи
					from  Nomenclature n1
					inner join ObjectNomenclature on1 on n1.Gid = on1.NomenclatureGid
					where n1._retired=''3000-01-01'' 
						and on1._retired=''3000-01-01''
						and on1.DocumentGid = doc.Gid 
						and n1.Type=''PhisicalCondition''
				) as PhysicalCondition,
				doc.CopyDigital,
				doc.CopyMicrofilm,
				(SELECT fund.IntNumber FROM Fund_Modified as fund WHERE fund.LGid = doc.FundLGid) as FundIntNumber,
				(SELECT inventory.IntNumber FROM Inventory_Modified as inventory WHERE inventory.LGid = doc.InventoryLGid) as InventoryIntNumber,
				(SELECT ae.IntNumber FROM ArchiveEntity_Modified as ae WHERE ae.LGid = doc.AELGid) as ArchivalEntityIntNumber,
				a.SortOrder
			FROM Document_Modified as doc
			INNER JOIN Archive a ON a.Gid = doc.ArchiveGid AND a._retired = ''3000-01-01''
			WHERE ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))) OR a.Code in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '','')))'

			SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');
	END

	IF @ResultType = 1 OR @ResultType = 3
	BEGIN
		DECLARE @localQuery VARCHAR(MAX) = 
			'SELECT
				a.Name as Archive,	
				(SELECT Number FROM Funds f where f.SystemIdentifier = doc.FundSystemIdentifier) as FundNumber,
				(SELECT Number FROM Inventories i where i.SystemIdentifier = doc.InventorySystemIdentifier) as InventoryNumber,
				(SELECT Number FROM ArchivalEntities ae where ae.SystemIdentifier = doc.ArchivalEntitySystemIdentifier) as ArchiveEntityNumber,
				doc.Id as DocumentSystemId,
				doc.SheetCount as PaperCount,
				NULL as PhysicalCondition,
				doc.DigitizedCopyCount as CopyDigital,
				doc.MicrofilmedCopyCount as CopyMicrofilm,
				(SELECT NumberNumeric FROM Funds f where f.SystemIdentifier =doc. FundSystemIdentifier) as FundIntNumber,
				(SELECT NumberNumeric FROM Inventories i where i.SystemIdentifier = doc.InventorySystemIdentifier) as InventoryIntNumber,
				(SELECT NumberNumeric FROM ArchivalEntities ae where ae.SystemIdentifier = doc.ArchivalEntitySystemIdentifier) as ArchivalEntityIntNumber,
				a.SortOrder
			FROM Documents doc
			INNER JOIN Archives a ON a.Id = doc.ArchiveId AND a.Deleted = 0
			WHERE doc.ExternalIdentifier IS NULL AND doc.HasExternalSource = 0 AND doc.Deleted = 0 
				AND ((''-999'' in (select element from dbo.SplitString(''' + @ArchiveCodes  + ''', '',''))) 
					OR (convert(varchar(4), a.Code, 104) in (select element from dbo.SplitString(''' + @ArchiveCodes + ''', '',''))))';
	END

	IF @ResultType = 1
	BEGIN
		SET @sql = '
			DECLARE @remoteTable TABLE (
				Archive nvarchar(256) NOT NULL,
				FundNumber nvarchar(256) NULL,
				InventoryNumber nvarchar(256) NULL,
				ArchiveEntityNumber nvarchar(256) NULL,
				DocumentSystemId int NOT NULL,
				PaperCount int NULL,
				PhysicalCondition nvarchar(MAX) NULL,
				CopyDigital int NULL,
				CopyMicrofilm int NULL,
				FundIntNumber int null,
				InventoryIntNumber int null,
				ArchivalEntityIntNumber int null,
				SortOrder int null
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