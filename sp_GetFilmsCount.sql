
CREATE PROCEDURE [dbo].[sp_GetFilmsCount] 
	@LinkedServer nvarchar(50)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @RemoteFilms TABLE ( FilmsCount int );
	DECLARE @RemoteFilmsCount int = 0;
	DECLARE @sql VARCHAR(MAX);

	DECLARE @remoteFilmsQuery VARCHAR(MAX) = '
		SELECT 
			   -1 as Id
			  ,CAST(1 as bit) as HasExternalSource
			  ,fund.[LGid] as ExternalIdentifier
		 FROM [Archiving].[dbo].Fund_Modified as fund
		 JOIN [Archiving].[dbo].Nomenclature nom on nom.Gid = fund.LevelOfDescriptionGid
		 WHERE nom.Code = 9 /* Ã‘*/';

	SET @remoteFilmsQuery = REPLACE(@remoteFilmsQuery, '''', '''''');
	
	SET @sql = 'SELECT COUNT(*) as FilmsCount FROM OPENQUERY(' + @LinkedServer + ', ''' + @remoteFilmsQuery + ''');';
			
	INSERT INTO @RemoteFilms
	EXEC(@sql)

	SELECT TOP 1 @RemoteFilmsCount = FilmsCount from @RemoteFilms

	RETURN @RemoteFilmsCount
END
