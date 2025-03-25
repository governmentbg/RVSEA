USE [DAA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_GetLastFundNumbers] 
	@LinkedServer NVARCHAR(50),
	@Archive INT,
	@FundArray NVARCHAR(10)
AS
BEGIN
	declare @remoteQuery varchar(max) = '
		SELECT TOP(4) -- 4 са нивата на описание за фондове, това са максимума записи с един и същи номер
			Number AS Num,
			(SELECT Code FROM Nomenclature n WHERE n.Gid = LevelOfDescriptionGid AND n.Type = ''LevelOfDescription'' AND _retired = ''3000-01-01'') AS LevelOfDescriptionCode,
			NULL AS Id
		FROM Fund_Active AS fund
		WHERE (SELECT Code FROM Archive a WHERE a.Gid = ArchiveGid) = ' + convert(NVARCHAR, @Archive) + '
			AND (SELECT Value FROM Nomenclature n WHERE n.Gid = FundArrayGid AND n.Type = ''FundArray'' AND _retired = ''3000-01-01'') = N''' + @FundArray + '''
			AND Number IS NOT NULL
			AND Number LIKE ''[0-9]%'' 
		ORDER BY IntNumber DESC;
	';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @openQuery NVARCHAR(MAX) = '

		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');
	';
	
	--print @openQuery
	EXEC (@openQuery);
END