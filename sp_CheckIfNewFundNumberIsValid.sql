USE [DAA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CheckIfNewFundNumberIsValid] 
	@LinkedServer NVARCHAR(50),
	@Archive INT,
	@Number NVARCHAR(50),
	@FundArray NVARCHAR(10),
	@DescriptionLevelCode INT
AS
BEGIN
	declare @remoteQuery varchar(max) = '
		SELECT 1 AS Ok
		FROM Fund_Active AS fund
		WHERE (SELECT Code FROM Archive a WHERE a.Gid = ArchiveGid) = ' + CONVERT(NVARCHAR, @Archive) + ' 
			AND Number = ''' + @Number + '''
			AND (SELECT Value FROM Nomenclature n WHERE n.Gid = FundArrayGid AND n.Type = ''FundArray'' AND _retired = ''3000-01-01'') = ''' + @FundArray + ''' 
			AND (SELECT Code FROM Nomenclature n WHERE n.Gid = LevelOfDescriptionGid AND n.Type = ''LevelOfDescription'' AND _retired = ''3000-01-01'') = ' + CONVERT(NVARCHAR, @DescriptionLevelCode) + ';
	';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @openQuery nvarchar(MAX) = '

		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');
	';
	
	EXEC (@openQuery);
END