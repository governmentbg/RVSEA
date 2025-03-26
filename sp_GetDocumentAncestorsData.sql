USE [DAA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_GetDocumentAncestorsData] 
	@LinkedServer nvarchar(50),
	@ArchiveEntityIdentifier int
AS
BEGIN
	SET NOCOUNT ON;
 
	declare @sql varchar(max) = '
		SELECT
			(SELECT Name FROM Archive AS archive WHERE archive._retired = ''3000-01-01'' and archive.Gid = ArchiveGid) AS [ArchiveName],
			ArchiveGid as ArchiveCode,
			FundLGid as FundExternalIdentifier,
			(SELECT Number FROM Fund_Active AS fund WHERE fund.LGid = FundLGid) AS FundNumber,
			InventoryLGid as InventoryExternalIdentifier,
			(SELECT Number FROM Inventory_Active AS inventory WHERE inventory.LGid = InventoryLGid) AS InventoryNumber,
			Number as ArchiveEntityNumber
		FROM ArchiveEntity_Active
		WHERE 
			LGid = ' + CAST(@ArchiveEntityIdentifier as varchar(10));

	set @sql = REPLACE(@sql, '''', '''''');
	declare @result varchar(max) = 'SELECT * FROM openquery(' + @LinkedServer + ', ''' + @sql +''')';

	exec (@result);
END