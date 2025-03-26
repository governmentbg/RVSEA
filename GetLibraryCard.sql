SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[GetLibraryCard] 
	@LinkedServer NVARCHAR(50),
	@Number INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @sql VARCHAR(MAX);

	DECLARE @remoteQuery VARCHAR(MAX) = '
		SELECT
			ValidFrom,
			ValidTo
		FROM LibraryCards
		WHERE Id = ' + CONVERT(VARCHAR(10), @Number);

	SET @remoteQuery = REPLACE(@remoteQuery, '''', '''''');

	SET @sql = 'SELECT * FROM OPENQUERY(' + @LinkedServer + ', ''' + @remoteQuery + ''');';

	EXEC (@sql);
END
GO