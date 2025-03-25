USE [DAA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_GetLastInventoryNumbers] 
	@LinkedServer NVARCHAR(50),
	@Archive INT,
	@FundLGid NVARCHAR(50),
	@InventoryArray nvarchar(10)
AS
BEGIN
	declare @remoteQuery1 varchar(max) = '
		SELECT TOP(4) -- 4 са нивата на описание за фондове, това са максимума записи с един и същи номер
			Number AS Num,
			(SELECT Code FROM Nomenclature n WHERE n.Gid = LevelOfDescriptionGid AND n.Type = ''LevelOfDescription'' AND _retired = ''3000-01-01'') AS LevelOfDescriptionCode,
			NULL AS Id
		FROM Inventory_Active
		WHERE (SELECT Code FROM Archive a WHERE a.Gid = ArchiveGid) = ' + convert(varchar, @Archive) + ' 
			AND FundLGid =  ' + @FundLGid + '
			AND (SELECT Value FROM Nomenclature n WHERE n.Gid = InventoryArrayGid AND n.Type = ''InventoryArray'' AND _retired = ''3000-01-01'') = ''' + @InventoryArray + ''' 
			AND Number IS NOT NULL
			AND Number LIKE ''[0-9]%'' 
		ORDER BY IntNumber DESC;
	';

	SET @remoteQuery1 = REPLACE(@remoteQuery1, '''', '''''');

	DECLARE @openQuery nvarchar(MAX) = '

		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery1 +''');
	';
	
	EXEC (@openQuery);
END