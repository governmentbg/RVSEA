USE [DAA]
GO
/****** Object:  StoredProcedure [dbo].[sp_CheckIfNewInventoryNumberIsValid]    Script Date: 9.11.2022 г. 10:24:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CheckIfNewInventoryNumberIsValid] 
	@LinkedServer NVARCHAR(50),
	@Archive INT,
	@FundLGid NVARCHAR(50),
	@Number NVARCHAR(50),
	@InventoryArray nvarchar(10),
	@DescriptionLevelCode INT
AS
BEGIN
	declare @remoteQuery varchar(max) = '
		SELECT 1 AS Ok
		FROM Inventory_Active AS fund
		WHERE (SELECT Code FROM Archive a WHERE a.Gid = ArchiveGid) = ' + CONVERT(NVARCHAR, @Archive) + ' 
			AND FundLGid = ' + @FundLGid + '
			AND Number = ''' + @Number + '''
			AND (SELECT Value FROM Nomenclature n WHERE n.Gid = InventoryArrayGid AND n.Type = ''InventoryArray'' AND _retired = ''3000-01-01'') = ''' + @InventoryArray + ''' 
			AND (SELECT Code FROM Nomenclature n WHERE n.Gid = LevelOfDescriptionGid AND n.Type = ''LevelOfDescription'' AND _retired = ''3000-01-01'') = ' + CONVERT(NVARCHAR, @DescriptionLevelCode) + ';
	';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @openQuery nvarchar(MAX) = '

		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');
	';
	
	EXEC (@openQuery);
END