USE [DAA]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CheckIfNewArchivalEntityNumberIsValid] 
	@LinkedServer NVARCHAR(50),
	@Archive INT,
	@InventoryLGid NVARCHAR(50),
	@Number NVARCHAR(50)
AS
BEGIN
	declare @remoteQuery varchar(max) = '
		SELECT 1 AS Ok
		FROM ArchiveEntity_Active
		WHERE (SELECT Code FROM Archive a WHERE a.Gid = ArchiveGid) = ' + CONVERT(NVARCHAR, @Archive) + ' 
			AND InventoryLGid = ' + @InventoryLGid + '
			AND Number=''' + @Number + ''';
	';

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	DECLARE @openQuery nvarchar(MAX) = '

		SELECT * FROM openquery(' + @LinkedServer + ', ''' + @remoteQuery +''');
	';
	
	EXEC (@openQuery);
END