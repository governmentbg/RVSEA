USE [DAA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_GetLastArchiveEntityNumbers] 
	@LinkedServer NVARCHAR(50),
	@Archive INT,
	@InventoryLGid NVARCHAR(50)
AS
BEGIN
	declare @remoteQuery varchar(max) = '
		SELECT TOP(1)
			Number AS Num,
			(SELECT Code FROM Nomenclature n WHERE n.Gid = LevelOfDescriptionGid AND n.Type = ''LevelOfDescription'' AND _retired = ''3000-01-01'') AS LevelOfDescriptionCode,
			NULL AS Id
		FROM ArchiveEntity_Active ае
		WHERE (SELECT Code FROM Archive a WHERE a.Gid = ArchiveGid) = ' + convert(varchar, @Archive) + ' 
			AND ае.InventoryLGid =  ' + @InventoryLGid + '
			AND ае.LevelOfDescriptionGid = 2174 -- Архивна единица
			AND Number LIKE ''[0-9]%'' 
		ORDER BY IntNumber DESC;
	';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @openQuery nvarchar(MAX) = '

		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');
	';
	
	EXEC (@openQuery);
END